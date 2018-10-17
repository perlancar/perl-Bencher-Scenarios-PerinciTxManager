package Bencher::Scenario::PerinciTxManager::ViaPeriAS;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

our $scenario = {
    summary => 'Benchmark using transaction via Perinci::Access::Schemeless',
    modules => {
        'Perinci::Access::Schemeless' => 0,
        'Setup::File' => 0,
        'UUID::Random' => 0,
        'File::Temp' => 0,
    },
    participants => [
        {name => 'perias',
         code_template => q{

use 5.010;
use Perinci::Access::Schemeless;
use Perinci::Tx::Manager;
use UUID::Random;

if (!$main::tempdir) {
    require File::Temp;
    $main::tempdir = File::Temp::tempdir();
    mkdir "$main::tempdir/tm"    or die "Can't mkdir $main::tempdir/tm: $!";
    mkdir "$main::tempdir/setup" or die "Can't mkdir $main::tempdir/setup: $!";
}

state $pa = Perinci::Access::Schemeless->new(
    wrap => 0,
    use_tx => 1,
    custom_tx_manager => sub {
        my $pa = shift;
        Perinci::Tx::Manager->new(pa => $pa, data_dir=>"$main::tempdir/tm");
    },
);

for my $i (1..<num_txs>) {
    my $txid = UUID::Random::generate(); $txid =~ s/-.+//;
    my $res;
    $res = $pa->request(begin_tx => "/", {tx_id=>$txid, summary=>""});
    $res->[0] == 200 or die "Can't begin_tx: $res->[0] - $res->[1]";
    for my $j (1..<num_actions_per_tx>) {
        $res = $pa->request(call => "/Setup/File/setup_dir", {args=>{path=>"$main::tempdir/setup/$j", should_exist=>1}, tx_id=>$txid});
        $res->[0] =~ /\A(200|304)\z/ or die "Can't call #$j: $res->[0] - $res->[1]";
    } # action
    $res = $pa->request(commit_tx => "/", {tx_id=>$txid});
    $res->[0] == 200 or die "Can't commit_tx: $res->[0] - $res->[1]";
} # tx

}
     }],
    datasets => [
        {name=>"tx=1 actions=1"  , args=>{num_txs=>1, num_actions_per_tx=>1}},
        {name=>"tx=1 actions=10" , args=>{num_txs=>1, num_actions_per_tx=>10}},
        {name=>"tx=1 actions=100", args=>{num_txs=>1, num_actions_per_tx=>100}},
    ],
};

1;
# ABSTRACT:

=head1 BENCHMARK NOTES

actions=100 is (2/s) indeed much slower than actions=10 (18/s, 9.7x) and
actions=1 (90/s, 50x).

=head1 PROFILE NOTES

For "tx=1 actions=100" (100 actions in a single transaction, ~1.2s), 1314 SQL
execute() (~0.6s, 0.46ms per execute()) and 1413 do() are performed. The bulk of
the exclusive time is inside execute() (~0.6s, >50%). That means ~13 SQL query
per function action. Or about 6ms SQL execute() overhead per function action.

This makes L<Perinci::Tx::Manager> generally quite slow when we involve a large
number of function actions. To speed things up, we need: 1) a much faster
database; 2) group multiple actions inside a single function action (which is
not always easy to do).

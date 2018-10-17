package Bencher::Scenario::PerinciTxManager::Pericmd;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use File::Temp qw(tempdir);

my $dir = tempdir();

our $scenario = {
    summary => 'Benchmark using transaction via Perinci::CmdLine::Classic',
    modules => {
        'Perinci::CmdLine::Classic' => 0,
        'Setup::File' => 0,
        'Perinci::Tx::Util' => 0,
    },
    participants => [
        {name=>'mkdir'         , perl_cmdline => ['-MPerinci::CmdLine::Classic', '-e', 'Perinci::CmdLine::Classic->new(url=>"/Setup/File/mkdir",     undo=>1)->run', '--', '--path', "$dir/1"]},
        {name=>'setup_dir'     , perl_cmdline => ['-MPerinci::CmdLine::Classic', '-e', 'Perinci::CmdLine::Classic->new(url=>"/Setup/File/setup_dir", undo=>1)->run', '--', '--path', "$dir/2"]},
        {name=>'setup_dir x10' , perl_cmdline => ['-MPerinci::CmdLine::Classic', '-MSetup::File', '-MPerinci::Tx::Util=use_other_actions', '-e',
                                                  join('',
                                                       '$SPEC{app} = {v=>1.1, args=>{}, features=>{tx=>{v=>2}, idempotent=>1}}; ',
                                                       'sub app { use_other_actions(actions=>[map {["Setup::File::setup_dir",{path=>"'.$dir.'/3$_"}]} 1..10]) } ',
                                                       'Perinci::CmdLine::Classic->new(url=>"/main/app", undo=>1)->run',
                                                   )]},
        {name=>'setup_dir x100', perl_cmdline => ['-MPerinci::CmdLine::Classic', '-MSetup::File', '-MPerinci::Tx::Util=use_other_actions', '-e',
                                                  join('',
                                                       '$SPEC{app} = {v=>1.1, args=>{}, features=>{tx=>{v=>2}, idempotent=>1}}; ',
                                                       'sub app { use_other_actions(actions=>[map {["Setup::File::setup_dir",{path=>"'.$dir.'/4$_"}]} 1..100]) } ',
                                                       'Perinci::CmdLine::Classic->new(url=>"/main/app", undo=>1)->run',
                                                   )]},
    ],
};

1;
# ABSTRACT:

=head1 BENCHMARK NOTES

Startup/setup by L<Perinci::CmdLine::Classic> dominates.

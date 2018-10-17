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
        'Setup::File' => 0,
    },
    participants => [
        {name=>'Setup::File::mkdir', perl_cmdline => ['-MPerinci::CmdLine::Classic', '-MFile::Temp=tempdir', '-e', 'Perinci::CmdLine::Classic->new(url=>"/Setup/File/mkdir", undo=>1)->run', '--', '--path', "$dir/1"]},
    ],
};

1;
# ABSTRACT:

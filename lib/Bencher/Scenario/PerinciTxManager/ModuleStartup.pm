package Bencher::Scenario::PerinciTxManager::ModuleStartup;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our $scenario = {
    summary => 'Benchmark module startup',
    module_startup => 1,
    participants => [
        {module=>'Perinci::Tx::Manager'},
    ],
};

1;
# ABSTRACT:

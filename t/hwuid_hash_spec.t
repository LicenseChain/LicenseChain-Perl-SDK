use strict;
use warnings;
use Test::More;

use LicenseChain::Services::LicenseService ();

my $h1 = LicenseChain::Services::LicenseService::_default_hwuid();
my $h2 = LicenseChain::Services::LicenseService::_default_hwuid();

is($h1, $h2, 'default hwuid is deterministic');
like($h1, qr/\A[a-f0-9]{64}\z/, 'default hwuid is lowercase sha256 hex');

done_testing();

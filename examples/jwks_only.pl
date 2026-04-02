#!/usr/bin/env perl
use strict;
use warnings;

# JWKS-only: verify license_token with token + JWKS URI (parity with Go/Rust/PHP jwks_only).
#   export LICENSECHAIN_LICENSE_TOKEN="eyJ..."
#   export LICENSECHAIN_LICENSE_JWKS_URI="https://api.licensechain.app/v1/licenses/jwks"
#   # optional: LICENSECHAIN_EXPECTED_APP_ID=<uuid>
#   perl examples/jwks_only.pl

use lib '../lib';
use JSON qw(encode_json);
use LicenseChain::LicenseAssertion;

my $token = $ENV{LICENSECHAIN_LICENSE_TOKEN} // '';
my $jwks  = $ENV{LICENSECHAIN_LICENSE_JWKS_URI} // '';
$token =~ s/^\s+|\s+$//g;
$jwks  =~ s/^\s+|\s+$//g;
if ( $token eq '' || $jwks eq '' ) {
    die "Set LICENSECHAIN_LICENSE_TOKEN and LICENSECHAIN_LICENSE_JWKS_URI\n";
}

my $opts = {};
if ( my $app = $ENV{LICENSECHAIN_EXPECTED_APP_ID} ) {
    $app =~ s/^\s+|\s+$//g;
    $opts->{expected_app_id} = $app if $app ne '';
}

my $payload = LicenseChain::LicenseAssertion->verify_license_assertion_jwt( $token, $jwks, $opts );
print encode_json($payload), "\n";

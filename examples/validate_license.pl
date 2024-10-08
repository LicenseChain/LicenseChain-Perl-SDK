#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';  # Adjust if needed
use LicenseChain;

my $api_key = 'your_api_key_here';
my $license_key = 'your_license_key_here';

my $lc = LicenseChain->new($api_key);
my $response = $lc->validate_license($license_key);

if (exists $response->{error}) {
    print "Error: $response->{error}
";
} else {
    print "License is valid: " . $response->{valid} . "
";
}

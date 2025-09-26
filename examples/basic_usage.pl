#!/usr/bin/perl
# LicenseChain Perl SDK - Basic Usage Example

use strict;
use warnings;
use LicenseChain::SDK;

print "?? LicenseChain Perl SDK - Basic Usage Example\n";
print "=" x 50 . "\n";

# Initialize the client
my  = LicenseChain::SDK->new({
    api_key  => 'your-api-key-here',
    app_name => 'MyPerlApp',
    version  => '1.0.0',
    debug    => 1
});

# Connect to LicenseChain
print "\n Connecting to LicenseChain...\n";
my  = ->connect();
if (->{success}) {
    print " Connected to LicenseChain successfully!\n";
} else {
    print " Failed to connect: " . ->{error} . "\n";
    exit 1;
}

# Example 1: User Registration
print "\n Registering new user...\n";
 = ->register('testuser', 'password123', 'test@example.com');
if (->{success}) {
    print " User registered successfully!\n";
    print "Session ID: " . ->{session_id} . "\n";
} else {
    print " Registration failed: " . ->{error} . "\n";
}

# Example 2: License Validation
print "\n Validating license...\n";
 = ->validate_license('LICENSE-KEY-HERE');
if (->{success}) {
    print " License is valid!\n";
    print "License Key: " . ->{license}->{key} . "\n";
    print "Status: " . ->{license}->{status} . "\n";
} else {
    print " License validation failed: " . ->{error} . "\n";
}

# Cleanup
print "\n Cleaning up...\n";
->logout();
->disconnect();
print " Cleanup completed!\n";

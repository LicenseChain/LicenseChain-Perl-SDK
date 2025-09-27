#!/usr/bin/env perl

use strict;
use warnings;
use lib '../lib';

use LicenseChain::SDK;
use LicenseChain::Configuration;
use LicenseChain::WebhookHandler;
use LicenseChain::Utils qw(
    validate_email validate_license_key generate_license_key generate_uuid
    format_bytes format_duration capitalize_first to_snake_case to_pascal_case
    slugify json_serialize
);

# Configure the SDK
my $config = LicenseChain::Configuration->new(
    'your-api-key-here',
    'https://api.licensechain.app',
    30,
    3
);

# Initialize the client
my $client = LicenseChain::SDK->new($config);

print "🚀 LicenseChain Perl SDK - Basic Usage Example\n\n";

eval {
    # 1. License Management
    print "🔑 License Management:\n";
    
    # Create a license
    my $metadata = {
        platform => 'perl',
        version => '1.0.0',
        features => ['validation', 'webhooks']
    };
    
    my $license = $client->get_licenses()->create('user123', 'product456', $metadata);
    print "✅ License created: $license->{id}\n";
    print "   License Key: $license->{license_key}\n";
    print "   Status: $license->{status}\n";
    
    # Validate a license
    my $license_key = generate_license_key();
    print "\n🔍 Validating license key: $license_key\n";
    
    my $is_valid = $client->get_licenses()->validate($license_key);
    if ($is_valid) {
        print "✅ License is valid\n";
    } else {
        print "❌ License is invalid\n";
    }
    
    # Get license stats
    my $stats = $client->get_licenses()->stats();
    print "\n📊 License Statistics:\n";
    print "   Total: $stats->{total}\n";
    print "   Active: $stats->{active}\n";
    print "   Expired: $stats->{expired}\n";
    print "   Revenue: \$$stats->{revenue}\n";
    
    # 2. User Management
    print "\n👤 User Management:\n";
    
    # Create a user
    my $user_metadata = {
        source => 'perl-sdk',
        plan => 'premium'
    };
    
    my $user = $client->get_users()->create('user@example.com', 'John Doe', $user_metadata);
    print "✅ User created: $user->{id}\n";
    print "   Email: $user->{email}\n";
    print "   Name: $user->{name}\n";
    
    # Get user stats
    my $user_stats = $client->get_users()->stats();
    print "\n📊 User Statistics:\n";
    print "   Total: $user_stats->{total}\n";
    print "   Active: $user_stats->{active}\n";
    print "   Inactive: $user_stats->{inactive}\n";
    
    # 3. Product Management
    print "\n📦 Product Management:\n";
    
    # Create a product
    my $product_metadata = {
        category => 'software',
        tags => ['premium', 'enterprise']
    };
    
    my $product = $client->get_products()->create(
        'My Software Product',
        'A great software product',
        99.99,
        'USD',
        $product_metadata
    );
    print "✅ Product created: $product->{id}\n";
    print "   Name: $product->{name}\n";
    print "   Price: \$$product->{price} $product->{currency}\n";
    
    # Get product stats
    my $product_stats = $client->get_products()->stats();
    print "\n📊 Product Statistics:\n";
    print "   Total: $product_stats->{total}\n";
    print "   Active: $product_stats->{active}\n";
    print "   Revenue: \$$product_stats->{revenue}\n";
    
    # 4. Webhook Management
    print "\n🔗 Webhook Management:\n";
    
    # Create a webhook
    my @events = (
        'license.created',
        'license.updated',
        'user.created'
    );
    
    my $webhook = $client->get_webhooks()->create('https://example.com/webhook', \@events, 'webhook-secret');
    print "✅ Webhook created: $webhook->{id}\n";
    print "   URL: $webhook->{url}\n";
    print "   Events: " . join(', ', @{$webhook->{events}}) . "\n";
    
    # 5. Webhook Processing
    print "\n🔄 Webhook Processing:\n";
    
    my $webhook_handler = LicenseChain::WebhookHandler->new('webhook-secret');
    
    # Simulate a webhook event
    my $webhook_event = {
        id => 'evt_123',
        type => 'license.created',
        data => {
            id => 'lic_123',
            user_id => 'user_123',
            product_id => 'prod_123',
            license_key => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ012345',
            status => 'active',
            created_at => '2023-01-01T00:00:00Z'
        },
        timestamp => '2023-01-01T00:00:00Z',
        signature => 'signature_here'
    };
    
    $webhook_handler->process_event($webhook_event);
    print "✅ Webhook event processed successfully\n";
    
    # 6. Utility Functions
    print "\n🛠️ Utility Functions:\n";
    
    # Email validation
    my $email = 'test@example.com';
    print "Email '$email' is valid: " . (validate_email($email) ? 'true' : 'false') . "\n";
    
    # License key validation
    my $license_key = generate_license_key();
    print "License key '$license_key' is valid: " . (validate_license_key($license_key) ? 'true' : 'false') . "\n";
    
    # Generate UUID
    my $uuid = generate_uuid();
    print "Generated UUID: $uuid\n";
    
    # Format bytes
    my $bytes = 1024 * 1024;
    print "$bytes bytes = " . format_bytes($bytes) . "\n";
    
    # Format duration
    my $seconds = 3661;
    print "Duration: " . format_duration($seconds) . "\n";
    
    # String utilities
    my $text = 'Hello World';
    print "Capitalize first: " . capitalize_first($text) . "\n";
    print "To snake_case: " . to_snake_case('HelloWorld') . "\n";
    print "To PascalCase: " . to_pascal_case('hello_world') . "\n";
    print "Slugify: " . slugify('Hello World!') . "\n";
    
    # 7. Error Handling
    print "\n🛡️ Error Handling:\n";
    
    eval {
        $client->get_licenses()->get('invalid-id');
    };
    if ($@) {
        print "✅ Caught expected error: $@\n";
    }
    
    eval {
        $client->get_users()->create('invalid-email', 'John Doe');
    };
    if ($@) {
        print "✅ Caught expected error: $@\n";
    }
    
    # 8. API Health Check
    print "\n🏥 API Health Check:\n";
    
    my $ping = $client->ping();
    print "Ping response: " . json_serialize($ping) . "\n";
    
    my $health = $client->health();
    print "Health response: " . json_serialize($health) . "\n";
    
    print "\n✅ Basic usage example completed successfully!\n";
    
};

if ($@) {
    print "❌ Error: $@\n";
    if ($ENV{DEBUG}) {
        print "Stack trace:\n";
        print $@;
    }
}
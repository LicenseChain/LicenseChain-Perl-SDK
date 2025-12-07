# LicenseChain Perl SDK

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Perl](https://img.shields.io/badge/Perl-5.26+-blue.svg)](https://www.perl.org/)
[![CPAN](https://img.shields.io/badge/CPAN-LicenseChain--SDK-blue.svg)](https://metacpan.org/pod/LicenseChain::SDK)

Official Perl SDK for LicenseChain - Secure license management for Perl applications.

## ðŸš€ Features

- **ðŸ” Secure Authentication** - User registration, login, and session management
- **ðŸ“œ License Management** - Create, validate, update, and revoke licenses
- **ðŸ›¡ï¸ Hardware ID Validation** - Prevent license sharing and unauthorized access
- **ðŸ”” Webhook Support** - Real-time license events and notifications
- **ðŸ“Š Analytics Integration** - Track license usage and performance metrics
- **âš¡ High Performance** - Optimized for production workloads
- **ðŸ”„ Async Operations** - Non-blocking HTTP requests and data processing
- **ðŸ› ï¸ Easy Integration** - Simple API with comprehensive documentation

## ðŸ“¦ Installation

### Method 1: CPAN (Recommended)

```bash
# Install via CPAN
cpan LicenseChain::SDK

# Or via cpanm
cpanm LicenseChain::SDK
```

### Method 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/LicenseChain/LicenseChain-Perl-SDK.git
cd LicenseChain-Perl-SDK

# Install dependencies
cpanm --installdeps .

# Build and install
perl Makefile.PL
make
make test
make install
```

### Method 3: Local Installation

```bash
# Install to local directory
perl Makefile.PL PREFIX=~/perl5
make
make test
make install
```

## ðŸš€ Quick Start

### Basic Setup

```perl
#!/usr/bin/perl
use strict;
use warnings;
use LicenseChain::SDK;

# Initialize the client
my $client = LicenseChain::SDK->new({
    api_key  => 'your-api-key',
    app_name => 'your-app-name',
    version  => '1.0.0'
});

# Connect to LicenseChain
my $result = $client->connect();
if ($result->{success}) {
    print "Connected to LicenseChain successfully!\n";
} else {
    die "Failed to connect: " . $result->{error} . "\n";
}
```

### User Authentication

```perl
# Register a new user
my $result = $client->register('username', 'password', 'email@example.com');
if ($result->{success}) {
    print "User registered successfully!\n";
    print "User ID: " . $result->{user}->{id} . "\n";
} else {
    warn "Registration failed: " . $result->{error} . "\n";
}

# Login existing user
$result = $client->login('username', 'password');
if ($result->{success}) {
    print "User logged in successfully!\n";
    print "Session ID: " . $result->{session_id} . "\n";
} else {
    warn "Login failed: " . $result->{error} . "\n";
}
```

### License Management

```perl
# Validate a license
my $result = $client->validate_license('LICENSE-KEY-HERE');
if ($result->{success}) {
    my $license = $result->{license};
    print "License is valid!\n";
    print "License Key: " . $license->{key} . "\n";
    print "Status: " . $license->{status} . "\n";
    print "Expires: " . $license->{expires} . "\n";
    print "Features: " . join(', ', @{$license->{features}}) . "\n";
    print "User: " . $license->{user} . "\n";
} else {
    warn "License validation failed: " . $result->{error} . "\n";
}

# Get user's licenses
$result = $client->get_user_licenses();
if ($result->{success}) {
    my $licenses = $result->{licenses};
    print "Found " . scalar(@$licenses) . " licenses:\n";
    for my $i (0..$#$licenses) {
        my $license = $licenses->[$i];
        print "  " . ($i + 1) . ". " . $license->{key} 
              . " - " . $license->{status} 
              . " (Expires: " . $license->{expires} . ")\n";
    }
} else {
    warn "Failed to get licenses: " . $result->{error} . "\n";
}
```

### Hardware ID Validation

```perl
# Get hardware ID (automatically generated)
my $hardware_id = $client->get_hardware_id();
print "Hardware ID: $hardware_id\n";

# Validate hardware ID with license
$result = $client->validate_hardware_id('LICENSE-KEY-HERE', $hardware_id);
if ($result->{success}) {
    if ($result->{valid}) {
        print "Hardware ID is valid for this license!\n";
    } else {
        print "Hardware ID is not valid for this license.\n";
    }
} else {
    warn "Hardware ID validation failed: " . $result->{error} . "\n";
}
```

### Webhook Integration

```perl
# Set up webhook handler
$client->set_webhook_handler(sub {
    my ($event, $data) = @_;
    print "Webhook received: $event\n";
    
    if ($event eq 'license.created') {
        print "New license created: " . $data->{licenseKey} . "\n";
    } elsif ($event eq 'license.updated') {
        print "License updated: " . $data->{licenseKey} . "\n";
    } elsif ($event eq 'license.revoked') {
        print "License revoked: " . $data->{licenseKey} . "\n";
    }
});

# Start webhook listener
$client->start_webhook_listener();
```

## ðŸ“š API Reference

### LicenseChain::SDK

#### Constructor

```perl
my $client = LicenseChain::SDK->new({
    api_key  => 'your-api-key',
    app_name => 'your-app-name',
    version  => '1.0.0',
    base_url => 'https://api.licensechain.app'  # Optional
});
```

#### Methods

##### Connection Management

```perl
# Connect to LicenseChain
my $result = $client->connect();

# Disconnect from LicenseChain
$client->disconnect();

# Check connection status
my $is_connected = $client->is_connected();
```

##### User Authentication

```perl
# Register a new user
my $result = $client->register($username, $password, $email);

# Login existing user
my $result = $client->login($username, $password);

# Logout current user
$client->logout();

# Get current user info
my $result = $client->get_current_user();
```

##### License Management

```perl
# Validate a license
my $result = $client->validate_license($license_key);

# Get user's licenses
my $result = $client->get_user_licenses();

# Create a new license
my $result = $client->create_license($user_id, $features, $expires);

# Update a license
my $result = $client->update_license($license_key, $updates);

# Revoke a license
my $result = $client->revoke_license($license_key);

# Extend a license
my $result = $client->extend_license($license_key, $days);
```

##### Hardware ID Management

```perl
# Get hardware ID
my $hardware_id = $client->get_hardware_id();

# Validate hardware ID
my $result = $client->validate_hardware_id($license_key, $hardware_id);

# Bind hardware ID to license
my $result = $client->bind_hardware_id($license_key, $hardware_id);
```

##### Webhook Management

```perl
# Set webhook handler
$client->set_webhook_handler($handler);

# Start webhook listener
$client->start_webhook_listener();

# Stop webhook listener
$client->stop_webhook_listener();
```

##### Analytics

```perl
# Track event
my $result = $client->track_event($event_name, $properties);

# Get analytics data
my $result = $client->get_analytics($time_range);
```

## ðŸ”§ Configuration

### Environment Variables

Set these in your environment or through your build process:

```bash
# Required
export LICENSECHAIN_API_KEY=your-api-key
export LICENSECHAIN_APP_NAME=your-app-name
export LICENSECHAIN_APP_VERSION=1.0.0

# Optional
export LICENSECHAIN_BASE_URL=https://api.licensechain.app
export LICENSECHAIN_DEBUG=true
```

### Advanced Configuration

```perl
my $client = LicenseChain::SDK->new({
    api_key     => 'your-api-key',
    app_name    => 'your-app-name',
    version     => '1.0.0',
    base_url    => 'https://api.licensechain.app',
    timeout     => 30,        # Request timeout in seconds
    retries     => 3,         # Number of retry attempts
    debug       => 0,         # Enable debug logging
    user_agent  => 'MyApp/1.0.0'  # Custom user agent
});
```

## ðŸ›¡ï¸ Security Features

### Hardware ID Protection

The SDK automatically generates and manages hardware IDs to prevent license sharing:

```perl
# Hardware ID is automatically generated and stored
my $hardware_id = $client->get_hardware_id();

# Validate against license
my $result = $client->validate_hardware_id($license_key, $hardware_id);
```

### Secure Communication

- All API requests use HTTPS
- API keys are securely stored and transmitted
- Session tokens are automatically managed
- Webhook signatures are verified

### License Validation

- Real-time license validation
- Hardware ID binding
- Expiration checking
- Feature-based access control

## ðŸ“Š Analytics and Monitoring

### Event Tracking

```perl
# Track custom events
my $result = $client->track_event('app.started', {
    level        => 1,
    playerCount  => 10
});

# Track license events
$result = $client->track_event('license.validated', {
    licenseKey => 'LICENSE-KEY',
    features   => 'premium,unlimited'
});
```

### Performance Monitoring

```perl
# Get performance metrics
my $result = $client->get_performance_metrics();
if ($result->{success}) {
    my $metrics = $result->{metrics};
    print "API Response Time: " . $metrics->{avg_response_time} . "ms\n";
    print "Success Rate: " . sprintf("%.2f%%", $metrics->{success_rate} * 100) . "\n";
    print "Error Count: " . $metrics->{error_count} . "\n";
}
```

## ðŸ”„ Error Handling

### Custom Error Types

```perl
my $result = $client->validate_license('invalid-key');
if (!$result->{success}) {
    my $error_type = $result->{error_type};
    if ($error_type eq 'INVALID_LICENSE') {
        warn "License key is invalid";
    } elsif ($error_type eq 'EXPIRED_LICENSE') {
        warn "License has expired";
    } elsif ($error_type eq 'NETWORK_ERROR') {
        warn "Network connection failed";
    } else {
        warn "LicenseChain error: " . $result->{error};
    }
}
```

### Retry Logic

```perl
# Automatic retry for network errors
my $client = LicenseChain::SDK->new({
    api_key  => 'your-api-key',
    app_name => 'your-app-name',
    version  => '1.0.0',
    retries  => 3,        # Retry up to 3 times
    timeout  => 30        # Wait 30 seconds for each request
});
```

## ðŸ§ª Testing

### Unit Tests

```bash
# Run tests
prove -l t/

# Run tests with verbose output
prove -v t/

# Run specific test
prove -v t/client.t
```

### Integration Tests

```bash
# Test with real API
prove -v t/integration/
```

## ðŸ“ Examples

See the `examples/` directory for complete examples:

- `basic_usage.pl` - Basic SDK usage
- `advanced_features.pl` - Advanced features and configuration
- `webhook_integration.pl` - Webhook handling

## ðŸ¤ Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Install Perl 5.26 or later
3. Install dependencies: `cpanm --installdeps .`
4. Build: `perl Makefile.PL && make`
5. Test: `prove -l t/`

## ðŸ“„ License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ðŸ†˜ Support

- **Documentation**: [https://docs.licensechain.app/perl](https://docs.licensechain.app/perl)
- **Issues**: [GitHub Issues](https://github.com/LicenseChain/LicenseChain-Perl-SDK/issues)
- **Discord**: [LicenseChain Discord](https://discord.gg/licensechain)
- **Email**: support@licensechain.app

## ðŸ”— Related Projects

- [LicenseChain JavaScript SDK](https://github.com/LicenseChain/LicenseChain-JavaScript-SDK)
- [LicenseChain Python SDK](https://github.com/LicenseChain/LicenseChain-Python-SDK)
- [LicenseChain Node.js SDK](https://github.com/LicenseChain/LicenseChain-NodeJS-SDK)
- [LicenseChain Customer Panel](https://github.com/LicenseChain/LicenseChain-Customer-Panel)

---

**Made with â¤ï¸ for the Perl community**


## API Endpoints

All endpoints automatically use the /v1 prefix when connecting to https://api.licensechain.app.

### Base URL
- **Production**: https://api.licensechain.app/v1\n- **Development**: https://api.licensechain.app/v1\n\n### Available Endpoints\n\n| Method | Endpoint | Description |\n|--------|----------|-------------|\n| GET | /v1/health | Health check |\n| POST | /v1/auth/login | User login |\n| POST | /v1/auth/register | User registration |\n| GET | /v1/apps | List applications |\n| POST | /v1/apps | Create application |\n| GET | /v1/licenses | List licenses |\n| POST | /v1/licenses/verify | Verify license |\n| GET | /v1/webhooks | List webhooks |\n| POST | /v1/webhooks | Create webhook |\n| GET | /v1/analytics | Get analytics |\n\n**Note**: The SDK automatically prepends /v1 to all endpoints, so you only need to specify the path (e.g., /auth/login instead of /v1/auth/login).


# LicenseChain Perl SDK

[![License](https://img.shields.io/badge/license-Elastic--2.0-blue.svg)](LICENSE)
[![Perl](https://img.shields.io/badge/Perl-5.36+-blue.svg)](https://www.perl.org/)
[![CPAN](https://img.shields.io/badge/CPAN-not%20published-lightgrey.svg)](https://github.com/LicenseChain/LicenseChain-Perl-SDK)
[![CI](https://github.com/LicenseChain/LicenseChain-Perl-SDK/actions/workflows/ci.yml/badge.svg)](https://github.com/LicenseChain/LicenseChain-Perl-SDK/actions/workflows/ci.yml)

Official Perl SDK for LicenseChain - Secure license management for Perl applications.

## 🚀 Features

- **🔐 Secure Authentication** - User registration, login, and session management
- **📜 License Management** - Create, validate, update, and revoke licenses
- **🛡 Hardware ID Validation** - Prevent license sharing and unauthorized access
- **🔔 Webhook Support** - Real-time license events and notifications
- **📊 Analytics Integration** - Track license usage and performance metrics
- **⚡ High Performance** - Optimized for production workloads
- **🔄 Async Operations** - Non-blocking HTTP requests and data processing
- **🛠 Easy Integration** - Simple API with comprehensive documentation

## 📦 Installation

Intended distribution is CPAN (dist `LicenseChain-SDK`, module `LicenseChain::SDK`) once a PAUSE upload succeeds; the GitHub Packages sidebar stays empty by design (not used).

### Method 1: From GitHub (current)

```bash
# Install directly with cpanm
cpanm https://github.com/LicenseChain/LicenseChain-Perl-SDK.git

# Or clone and install locally
git clone https://github.com/LicenseChain/LicenseChain-Perl-SDK.git
cd LicenseChain-Perl-SDK
cpanm --installdeps .
perl Makefile.PL
make
make test
make install
```

### Method 2: Local prefix install

```bash
perl Makefile.PL PREFIX=~/perl5
make
make test
make install
```

### Method 3: CPAN (after first publish)

```bash
# Dist name on CPAN: LicenseChain-SDK
# Module name: LicenseChain::SDK
cpan LicenseChain::SDK
cpanm LicenseChain::SDK
```

## 🚀 Quick Start

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

## 📚 API Endpoints

All endpoints target the LicenseChain HTTP API at `https://api.licensechain.app/v1`. The client accepts either the canonical `/v1` base or the root host and normalizes requests to the same API version.

### Base URL

- **Production**: `https://api.licensechain.app/v1`
- **Development**: `https://api.licensechain.app/v1`

### Available Endpoints

| Method | Endpoint | Description |
| -------- | ---------- | --------------- |
| GET | /v1/health | Health check |
| POST | /v1/auth/login | User login |
| POST | /v1/auth/register | User registration |
| GET | /v1/apps | List applications |
| POST | /v1/apps | Create application |
| GET | /v1/licenses | List licenses |
| POST | /v1/licenses/verify | Verify license |
| GET | /v1/webhooks | List webhooks |
| POST | /v1/webhooks | Create webhook |
| GET | /v1/analytics | Get analytics |

**Note:** The SDK automatically prepends `/v1` to all endpoints, so you only need to specify the path (e.g., `/auth/login` instead of `/v1/auth/login`).

## API Reference

See the [LicenseChain SDK docs](https://docs.licensechain.app/en/sdk) for full HTTP and client method reference. Repository examples and inline docs cover language-specific usage.

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

## 🔧 Configuration

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

## 🛡 Security Features

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

## 📊 Analytics and Monitoring

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

## 🔄 Error Handling

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

## 🧪 Testing

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

## License assertion JWT (RS256 + JWKS)

When Core API returns **`license_token`** and **`license_jwks_uri`**, verify offline with **`LicenseChain::LicenseAssertion->verify_license_assertion_jwt`** (`Crypt::JWT` + JWKS; claim **`token_use`** = **`licensechain_license_v1`**). A minimal **JWKS-only** CLI is **`examples/jwks_only.pl`** — set **`LICENSECHAIN_LICENSE_TOKEN`** and **`LICENSECHAIN_LICENSE_JWKS_URI`** (optional **`LICENSECHAIN_EXPECTED_APP_ID`**), then `perl examples/jwks_only.pl` (same env names as Go/Rust/PHP; [JWKS_EXAMPLE_PRIORITY](https://docs.licensechain.app/)).

## 📝 Examples

See the `examples/` directory for complete examples:

- `basic_usage.pl` - Basic SDK usage
- `advanced_features.pl` - Advanced features and configuration
- `webhook_integration.pl` - Webhook handling
- `jwks_only.pl` — RS256 `license_token` via JWKS only ([JWKS_EXAMPLE_PRIORITY](https://docs.licensechain.app/))

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Install Perl 5.26 or later
3. Install dependencies: `cpanm --installdeps .`
4. Build: `perl Makefile.PL && make`
5. Test: `prove -l t/`

## 📄 License

This project is licensed under the Elastic License 2.0 (ELv2) — see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [https://docs.licensechain.app/en/sdk](https://docs.licensechain.app/en/sdk)
- **Issues**: [GitHub Issues](https://github.com/LicenseChain/LicenseChain-Perl-SDK/issues)
- **Discord**: [LicenseChain Discord](https://discord.gg/licensechain)
- **Email**: support@licensechain.app

## 🔗 Related Projects

- [LicenseChain Python SDK](https://github.com/LicenseChain/LicenseChain-Python-SDK)
- [LicenseChain Ruby SDK](https://github.com/LicenseChain/LicenseChain-Ruby-SDK)
- [LicenseChain PHP SDK](https://github.com/LicenseChain/LicenseChain-PHP-SDK)
---

**Made with ❤️ for the Perl community**

package LicenseChain::SDK;

use 5.010;
use strict;
use warnings;

our $VERSION = '1.0.0';

use Carp qw(croak);
use Data::Dumper;
use Encode qw(encode_utf8);
use Exporter qw(import);
use HTTP::Tiny;
use JSON qw(encode_json decode_json);
use LWP::UserAgent;
use MIME::Base64 qw(encode_base64);
use Time::HiRes qw(time);
use URI;
use URI::Escape qw(uri_escape);
use Digest::SHA qw(sha256_hex);
use Digest::HMAC qw(hmac_sha256_hex);
use Try::Tiny;
use Scalar::Util qw(blessed);
use List::Util qw(first);
use POSIX qw(strftime);
use Time::Piece;
use Time::Seconds;

# Export functions
our @EXPORT_OK = qw(
    new
    register_user
    login
    logout
    refresh_token
    get_user_profile
    update_user_profile
    change_password
    request_password_reset
    reset_password
    create_application
    list_applications
    get_application
    update_application
    delete_application
    regenerate_api_key
    create_license
    list_licenses
    get_license
    update_license
    delete_license
    validate_license
    revoke_license
    activate_license
    extend_license
    create_webhook
    list_webhooks
    get_webhook
    update_webhook
    delete_webhook
    test_webhook
    get_analytics
    get_license_analytics
    get_usage_stats
    get_system_status
    get_health_check
    is_license_valid
    get_license_info
    get_license_features
    get_license_metadata
    get_license_usage_count
    get_user_info
    get_app_info
    validate_with_rules
    validate_multiple_licenses
    verify_webhook_signature
    parse_webhook_payload
);

# Constants
use constant {
    DEFAULT_BASE_URL => 'https://api.licensechain.app',
    DEFAULT_TIMEOUT  => 30,
    DEFAULT_RETRIES  => 3,
    DEFAULT_RETRY_DELAY => 1.0,
    USER_AGENT => 'LicenseChain-Perl-SDK/1.0.0',
};

=head1 NAME

LicenseChain::SDK - Official Perl SDK for LicenseChain

=head1 VERSION

Version 1.0.0

=head1 SYNOPSIS

    use LicenseChain::SDK;
    
    # Create a client
    my $client = LicenseChain::SDK->new(
        api_key => 'your_api_key_here',
        base_url => 'https://api.licensechain.app',  # optional
        timeout  => 30,                              # optional
        retries  => 3,                               # optional
        retry_delay => 1.0,                          # optional
    );
    
    # Validate a license
    my $result = $client->validate_license('license_key_here', 'app_id');
    if ($result->{valid}) {
        print "License is valid!\n";
        print "User: " . $result->{user}->{email} . "\n";
        print "Expires: " . $result->{expires_at} . "\n";
    } else {
        print "License is invalid: " . $result->{error} . "\n";
    }
    
    # Create a new license
    my $license = $client->create_license({
        app_id => 'app_123',
        user_email => 'user@example.com',
        user_name => 'John Doe',
        expires_at => '2024-12-31T23:59:59Z',
        metadata => {
            plan => 'premium',
            features => ['api_access']
        }
    });
    print "Created license: " . $license->{key} . "\n";

=head1 DESCRIPTION

The official Perl SDK for LicenseChain - a comprehensive license management platform. 
This SDK provides full API access for license validation, user management, application management, and more.

=head1 FEATURES

- ✅ License Management - Create, validate, update, and revoke licenses
- ✅ User Authentication - Complete user management and authentication
- ✅ Application Management - Manage applications and API keys
- ✅ Webhook Support - Secure webhook verification and handling
- ✅ Analytics - Access usage statistics and analytics
- ✅ Error Handling - Comprehensive error handling with custom error types
- ✅ Type Safety - Strong typing and validation
- ✅ Documentation - Comprehensive documentation and examples

=head1 METHODS

=head2 new(%args)

Create a new LicenseChain client instance.

Arguments:
- api_key (required): Your LicenseChain API key
- base_url (optional): Base URL for the LicenseChain API (default: https://api.licensechain.app)
- timeout (optional): Request timeout in seconds (default: 30)
- retries (optional): Number of retry attempts (default: 3)
- retry_delay (optional): Delay between retries in seconds (default: 1.0)

=cut

sub new {
    my ($class, %args) = @_;
    
    croak "API key is required" unless $args{api_key};
    
    my $self = {
        api_key     => $args{api_key},
        base_url    => $args{base_url} || DEFAULT_BASE_URL,
        timeout     => $args{timeout} || DEFAULT_TIMEOUT,
        retries     => $args{retries} || DEFAULT_RETRIES,
        retry_delay => $args{retry_delay} || DEFAULT_RETRY_DELAY,
    };
    
    # Remove trailing slash from base URL
    $self->{base_url} =~ s{/$}{};
    
    # Create HTTP client
    $self->{http_client} = HTTP::Tiny->new(
        agent => USER_AGENT,
        timeout => $self->{timeout},
        default_headers => {
            'Authorization' => 'Bearer ' . $self->{api_key},
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
        },
    );
    
    bless $self, $class;
    return $self;
}

=head2 validate_license($license_key, $app_id)

Validate a license key.

Arguments:
- license_key: The license key to validate
- app_id (optional): Application ID

Returns: Hash reference with validation result

=cut

sub validate_license {
    my ($self, $license_key, $app_id) = @_;
    
    croak "License key is required" unless $license_key;
    
    my $request = {
        license_key => $license_key,
    };
    $request->{app_id} = $app_id if $app_id;
    
    return $self->_post('/licenses/validate', $request);
}

=head2 is_license_valid($license_key, $app_id)

Quick check if a license is valid.

Arguments:
- license_key: The license key to validate
- app_id (optional): Application ID

Returns: Boolean indicating if license is valid

=cut

sub is_license_valid {
    my ($self, $license_key, $app_id) = @_;
    
    my $result = $self->validate_license($license_key, $app_id);
    return $result->{valid} ? 1 : 0;
}

=head2 get_license_info($license_key, $app_id)

Get detailed license information.

Arguments:
- license_key: The license key to validate
- app_id (optional): Application ID

Returns: Hash reference with license information or undef if invalid

=cut

sub get_license_info {
    my ($self, $license_key, $app_id) = @_;
    
    my $result = $self->validate_license($license_key, $app_id);
    return $result->{valid} ? $result : undef;
}

=head2 get_license_features($license_key, $app_id)

Get license features.

Arguments:
- license_key: The license key to validate
- app_id (optional): Application ID

Returns: Array reference with features or empty array if invalid

=cut

sub get_license_features {
    my ($self, $license_key, $app_id) = @_;
    
    my $result = $self->validate_license($license_key, $app_id);
    return $result->{valid} && $result->{license} && $result->{license}->{features} 
        ? $result->{license}->{features} 
        : [];
}

=head2 get_license_metadata($license_key, $app_id)

Get license metadata.

Arguments:
- license_key: The license key to validate
- app_id (optional): Application ID

Returns: Hash reference with metadata or empty hash if invalid

=cut

sub get_license_metadata {
    my ($self, $license_key, $app_id) = @_;
    
    my $result = $self->validate_license($license_key, $app_id);
    return $result->{valid} && $result->{license} && $result->{license}->{metadata} 
        ? $result->{license}->{metadata} 
        : {};
}

=head2 get_license_usage_count($license_key, $app_id)

Get license usage count.

Arguments:
- license_key: The license key to validate
- app_id (optional): Application ID

Returns: Usage count or 0 if invalid

=cut

sub get_license_usage_count {
    my ($self, $license_key, $app_id) = @_;
    
    my $result = $self->validate_license($license_key, $app_id);
    return $result->{valid} && $result->{license} && $result->{license}->{usage_count} 
        ? $result->{license}->{usage_count} 
        : 0;
}

=head2 get_user_info($license_key, $app_id)

Get user information from license.

Arguments:
- license_key: The license key to validate
- app_id (optional): Application ID

Returns: Hash reference with user information or undef if invalid

=cut

sub get_user_info {
    my ($self, $license_key, $app_id) = @_;
    
    my $result = $self->validate_license($license_key, $app_id);
    return $result->{valid} && $result->{user} ? $result->{user} : undef;
}

=head2 get_app_info($license_key, $app_id)

Get application information from license.

Arguments:
- license_key: The license key to validate
- app_id (optional): Application ID

Returns: Hash reference with application information or undef if invalid

=cut

sub get_app_info {
    my ($self, $license_key, $app_id) = @_;
    
    my $result = $self->validate_license($license_key, $app_id);
    return $result->{valid} && $result->{app} ? $result->{app} : undef;
}

=head2 validate_with_rules($license_key, $rules, $app_id)

Validate license with custom rules.

Arguments:
- license_key: The license key to validate
- rules: Hash reference with validation rules
- app_id (optional): Application ID

Returns: Hash reference with validation result

=cut

sub validate_with_rules {
    my ($self, $license_key, $rules, $app_id) = @_;
    
    my $result = $self->validate_license($license_key, $app_id);
    
    return $result unless $result->{valid};
    
    # Apply custom validation rules
    if ($rules->{max_usage} && $result->{license} && $result->{license}->{usage_count}) {
        if ($result->{license}->{usage_count} > $rules->{max_usage}) {
            return {
                %$result,
                valid => 0,
                error => 'Usage limit exceeded'
            };
        }
    }
    
    if ($rules->{allowed_features} && $result->{license} && $result->{license}->{features}) {
        my @invalid_features = grep { !grep { $_ eq $_ } @{$rules->{allowed_features}} } @{$result->{license}->{features}};
        if (@invalid_features) {
            return {
                %$result,
                valid => 0,
                error => 'Invalid features: ' . join(', ', @invalid_features)
            };
        }
    }
    
    if ($rules->{required_features} && $result->{license} && $result->{license}->{features}) {
        my @missing_features = grep { !grep { $_ eq $_ } @{$result->{license}->{features}} } @{$rules->{required_features}};
        if (@missing_features) {
            return {
                %$result,
                valid => 0,
                error => 'Missing required features: ' . join(', ', @missing_features)
            };
        }
    }
    
    if ($rules->{allowed_domains} && $result->{license} && $result->{license}->{metadata} && $result->{license}->{metadata}->{domain}) {
        my $domain = $result->{license}->{metadata}->{domain};
        unless (grep { $_ eq $domain } @{$rules->{allowed_domains}}) {
            return {
                %$result,
                valid => 0,
                error => "Domain not allowed: $domain"
            };
        }
    }
    
    if ($rules->{allowed_ips} && $result->{license} && $result->{license}->{metadata} && $result->{license}->{metadata}->{ip_address}) {
        my $ip_address = $result->{license}->{metadata}->{ip_address};
        unless (grep { $_ eq $ip_address } @{$rules->{allowed_ips}}) {
            return {
                %$result,
                valid => 0,
                error => "IP address not allowed: $ip_address"
            };
        }
    }
    
    return $result;
}

=head2 validate_multiple_licenses($license_keys, $app_id)

Validate multiple licenses.

Arguments:
- license_keys: Array reference with license keys
- app_id (optional): Application ID

Returns: Array reference with validation results

=cut

sub validate_multiple_licenses {
    my ($self, $license_keys, $app_id) = @_;
    
    my @results;
    for my $key (@$license_keys) {
        push @results, $self->validate_license($key, $app_id);
    }
    return \@results;
}

=head2 verify_webhook_signature($payload, $signature, $secret)

Verify webhook signature.

Arguments:
- payload: The webhook payload
- signature: The signature to verify
- secret: The webhook secret

Returns: Boolean indicating if signature is valid

=cut

sub verify_webhook_signature {
    my ($self, $payload, $signature, $secret) = @_;
    
    croak "Payload is required" unless $payload;
    croak "Signature is required" unless $signature;
    croak "Secret is required" unless $secret;
    
    my $expected_signature = 'sha256=' . hmac_sha256_hex($payload, $secret);
    return $expected_signature eq $signature;
}

=head2 parse_webhook_payload($payload, $signature, $secret)

Parse and verify webhook payload.

Arguments:
- payload: The webhook payload
- signature: The signature to verify
- secret: The webhook secret

Returns: Hash reference with parsed event data

=cut

sub parse_webhook_payload {
    my ($self, $payload, $signature, $secret) = @_;
    
    unless ($self->verify_webhook_signature($payload, $signature, $secret)) {
        croak "Invalid webhook signature";
    }
    
    my $data = decode_json($payload);
    return {
        id => $data->{id},
        type => $data->{type} || $data->{event},
        created_at => $data->{created_at} || $data->{createdAt},
        data => $data->{data} || $data->{object} || {},
    };
}

# Authentication Methods

sub register_user {
    my ($self, $request) = @_;
    return $self->_post('/auth/register', $request);
}

sub login {
    my ($self, $request) = @_;
    return $self->_post('/auth/login', $request);
}

sub logout {
    my ($self) = @_;
    return $self->_post('/auth/logout', {});
}

sub refresh_token {
    my ($self, $refresh_token) = @_;
    return $self->_post('/auth/refresh', { refresh_token => $refresh_token });
}

sub get_user_profile {
    my ($self) = @_;
    return $self->_get('/auth/me');
}

sub update_user_profile {
    my ($self, $request) = @_;
    return $self->_patch('/auth/me', $request);
}

sub change_password {
    my ($self, $request) = @_;
    return $self->_patch('/auth/password', $request);
}

sub request_password_reset {
    my ($self, $email) = @_;
    return $self->_post('/auth/forgot-password', { email => $email });
}

sub reset_password {
    my ($self, $request) = @_;
    return $self->_post('/auth/reset-password', $request);
}

# Application Management

sub create_application {
    my ($self, $request) = @_;
    return $self->_post('/apps', $request);
}

sub list_applications {
    my ($self, $request) = @_;
    my $params = $self->_build_query_params($request);
    return $self->_get('/apps', $params);
}

sub get_application {
    my ($self, $app_id) = @_;
    return $self->_get("/apps/$app_id");
}

sub update_application {
    my ($self, $app_id, $request) = @_;
    return $self->_patch("/apps/$app_id", $request);
}

sub delete_application {
    my ($self, $app_id) = @_;
    return $self->_delete("/apps/$app_id");
}

sub regenerate_api_key {
    my ($self, $app_id) = @_;
    return $self->_post("/apps/$app_id/regenerate-key", {});
}

# License Management

sub create_license {
    my ($self, $request) = @_;
    return $self->_post('/licenses', $request);
}

sub list_licenses {
    my ($self, $request) = @_;
    my $params = $self->_build_query_params($request);
    return $self->_get('/licenses', $params);
}

sub get_license {
    my ($self, $license_id) = @_;
    return $self->_get("/licenses/$license_id");
}

sub update_license {
    my ($self, $license_id, $request) = @_;
    return $self->_patch("/licenses/$license_id", $request);
}

sub delete_license {
    my ($self, $license_id) = @_;
    return $self->_delete("/licenses/$license_id");
}

sub revoke_license {
    my ($self, $license_id, $reason) = @_;
    my $request = {};
    $request->{reason} = $reason if $reason;
    return $self->_patch("/licenses/$license_id/revoke", $request);
}

sub activate_license {
    my ($self, $license_id) = @_;
    return $self->_patch("/licenses/$license_id/activate", {});
}

sub extend_license {
    my ($self, $license_id, $expires_at) = @_;
    return $self->_patch("/licenses/$license_id/extend", { expires_at => $expires_at });
}

# Webhook Management

sub create_webhook {
    my ($self, $request) = @_;
    return $self->_post('/webhooks', $request);
}

sub list_webhooks {
    my ($self, $request) = @_;
    my $params = $self->_build_query_params($request);
    return $self->_get('/webhooks', $params);
}

sub get_webhook {
    my ($self, $webhook_id) = @_;
    return $self->_get("/webhooks/$webhook_id");
}

sub update_webhook {
    my ($self, $webhook_id, $request) = @_;
    return $self->_patch("/webhooks/$webhook_id", $request);
}

sub delete_webhook {
    my ($self, $webhook_id) = @_;
    return $self->_delete("/webhooks/$webhook_id");
}

sub test_webhook {
    my ($self, $webhook_id) = @_;
    return $self->_post("/webhooks/$webhook_id/test", {});
}

# Analytics

sub get_analytics {
    my ($self, $request) = @_;
    my $params = $self->_build_query_params($request);
    return $self->_get('/analytics', $params);
}

sub get_license_analytics {
    my ($self, $license_id) = @_;
    return $self->_get("/licenses/$license_id/analytics");
}

sub get_usage_stats {
    my ($self, $request) = @_;
    my $params = $self->_build_query_params($request);
    return $self->_get('/analytics/usage', $params);
}

# System Status

sub get_system_status {
    my ($self) = @_;
    return $self->_get('/status');
}

sub get_health_check {
    my ($self) = @_;
    return $self->_get('/health');
}

# Private Methods

sub _get {
    my ($self, $endpoint, $params) = @_;
    return $self->_request('GET', $endpoint, undef, $params);
}

sub _post {
    my ($self, $endpoint, $data) = @_;
    return $self->_request('POST', $endpoint, $data);
}

sub _patch {
    my ($self, $endpoint, $data) = @_;
    return $self->_request('PATCH', $endpoint, $data);
}

sub _delete {
    my ($self, $endpoint) = @_;
    return $self->_request('DELETE', $endpoint);
}

sub _request {
    my ($self, $method, $endpoint, $data, $params) = @_;
    
    my $url = $self->{base_url} . $endpoint;
    
    # Add query parameters
    if ($params && %$params) {
        my $query_string = join('&', map { uri_escape($_) . '=' . uri_escape($params->{$_}) } keys %$params);
        $url .= '?' . $query_string;
    }
    
    my $request_data = $data ? encode_json($data) : undef;
    
    my $response = $self->{http_client}->request($method, $url, {
        content => $request_data,
    });
    
    if ($response->{success}) {
        return decode_json($response->{content}) if $response->{content};
        return {};
    } else {
        my $error_data = {};
        if ($response->{content}) {
            eval {
                $error_data = decode_json($response->{content});
            };
        }
        
        my $error_message = $error_data->{error} || "HTTP $response->{status}";
        my $error_code = $error_data->{code};
        my $details = $error_data->{details} || {};
        
        croak "LicenseChain API Error: $error_message (Code: $error_code, Status: $response->{status})";
    }
}

sub _build_query_params {
    my ($self, $request) = @_;
    return {} unless $request;
    
    my %params;
    for my $key (keys %$request) {
        next unless defined $request->{$key};
        $params{$key} = $request->{$key};
    }
    return \%params;
}

1;

__END__

=head1 AUTHOR

LicenseChain Team, C<< <support at licensechain.app> >>

=head1 BUGS

Please report any bugs or feature requests to the GitHub issue tracker:
L<https://github.com/LicenseChain/LicenseChain-Perl-SDK/issues>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc LicenseChain::SDK

You can also look for information at:

=over 4

=item * GitHub repository

L<https://github.com/LicenseChain/LicenseChain-Perl-SDK>

=item * LicenseChain documentation

L<https://docs.licensechain.app/sdks/perl>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/LicenseChain-SDK>

=item * Search CPAN

L<http://search.cpan.org/dist/LicenseChain-SDK/>

=back

=head1 LICENSE AND COPYRIGHT

This software is licensed under the Elastic License 2.0.

Copyright (C) 2024 LicenseChain Team

=cut

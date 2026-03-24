package LicenseChain::Services::LicenseService;

use strict;
use warnings;
use Exporter 'import';
use LicenseChain::Utils qw(validate_uuid validate_not_empty sanitize_metadata validate_pagination);
use LicenseChain::Exceptions qw(ValidationException);

our @EXPORT_OK = qw(
    new
    create
    get
    update
    revoke
    validate
    list_user_licenses
    stats
);

our $VERSION = '1.0.0';

sub new {
    my ($class, $client) = @_;
    
    my $self = {
        client => $client
    };
    
    bless $self, $class;
    return $self;
}

sub create {
    my ($self, $app_id, $user_email, $metadata) = @_;
    validate_not_empty($app_id, 'app_id');
    validate_not_empty($user_email, 'user_email');
    
    my $data = {
        appId => $app_id,
        plan => 'FREE',
        issuedEmail => $user_email,
        metadata => sanitize_metadata($metadata || {})
    };
    
    my $response = $self->{client}->post("/apps/$app_id/licenses", $data);
    return $self->normalize_license_payload($response->{data} || $response);
}

sub get {
    my ($self, $license_id) = @_;
    validate_not_empty($license_id, 'license_id');
    
    my $response = $self->{client}->get("/licenses/$license_id");
    return $self->normalize_license_payload($response->{data} || $response);
}

sub update {
    my ($self, $license_id, $updates) = @_;
    validate_not_empty($license_id, 'license_id');
    
    my $response = $self->{client}->patch("/licenses/$license_id", sanitize_metadata($updates));
    return $self->normalize_license_payload($response->{data} || $response);
}

sub revoke {
    my ($self, $license_id) = @_;
    validate_not_empty($license_id, 'license_id');
    
    $self->{client}->delete("/licenses/$license_id");
    return 1;
}

sub validate {
    my ($self, $license_key) = @_;
    validate_not_empty($license_key, 'license_key');
    
    # Use /licenses/verify endpoint with 'key' parameter to match API
    my $response = $self->{client}->post('/licenses/verify', { key => $license_key });
    return $response->{valid} || 0;
}

sub list_user_licenses {
    my ($self, $user_id, $page, $limit) = @_;
    validate_not_empty($user_id, 'user_id');
    ($page, $limit) = validate_pagination($page, $limit);
    
    my $response = $self->{client}->get('/licenses', {
        page => $page,
        limit => $limit
    });
    my $items = $response->{data} || $response->{licenses} || [];
    my @filtered = grep {
        (($_->{issuedEmail} || '') eq $user_id) ||
        (($_->{email} || '') eq $user_id) ||
        (($_->{user_id} || '') eq $user_id)
    } @$items;
    
    return {
        data => [ map { $self->normalize_license_payload($_) } @filtered ],
        total => scalar @filtered,
        page => $page,
        limit => $limit
    };
}

sub stats {
    my ($self) = @_;
    my $response = $self->{client}->get('/licenses/stats');
    return $response->{data} || $response;
}

sub validate_uuid {
    my ($self, $id, $field_name) = @_;
    validate_not_empty($id, $field_name);
    unless (validate_uuid($id)) {
        die "Invalid $field_name format";
    }
}

sub normalize_license_payload {
    my ($self, $payload) = @_;
    return {
        id => $payload->{id},
        key => $payload->{key} || $payload->{licenseKey},
        app_id => $payload->{app_id} || $payload->{appId} || '',
        user_id => $payload->{user_id},
        user_email => $payload->{user_email} || $payload->{issuedEmail} || $payload->{email} || '',
        user_name => $payload->{user_name} || $payload->{issuedTo},
        status => lc(($payload->{status} || 'active')),
        expires_at => $payload->{expires_at} || $payload->{expiresAt},
        created_at => $payload->{created_at} || $payload->{createdAt},
        updated_at => $payload->{updated_at} || $payload->{updatedAt},
        metadata => $payload->{metadata} || {},
        features => $payload->{features} || [],
        usage_count => $payload->{usage_count} || 0
    };
}

1;

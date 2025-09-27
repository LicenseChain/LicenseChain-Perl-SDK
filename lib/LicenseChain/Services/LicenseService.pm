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
    my ($self, $user_id, $product_id, $metadata) = @_;
    $self->validate_required_params($user_id, $product_id);
    
    my $data = {
        user_id => $user_id,
        product_id => $product_id,
        metadata => sanitize_metadata($metadata || {})
    };
    
    my $response = $self->{client}->post('/licenses', $data);
    return $response->{data};
}

sub get {
    my ($self, $license_id) = @_;
    $self->validate_uuid($license_id, 'license_id');
    
    my $response = $self->{client}->get("/licenses/$license_id");
    return $response->{data};
}

sub update {
    my ($self, $license_id, $updates) = @_;
    $self->validate_uuid($license_id, 'license_id');
    
    my $response = $self->{client}->put("/licenses/$license_id", sanitize_metadata($updates));
    return $response->{data};
}

sub revoke {
    my ($self, $license_id) = @_;
    $self->validate_uuid($license_id, 'license_id');
    
    $self->{client}->delete("/licenses/$license_id");
    return 1;
}

sub validate {
    my ($self, $license_key) = @_;
    validate_not_empty($license_key, 'license_key');
    
    my $response = $self->{client}->post('/licenses/validate', { license_key => $license_key });
    return $response->{valid} || 0;
}

sub list_user_licenses {
    my ($self, $user_id, $page, $limit) = @_;
    $self->validate_uuid($user_id, 'user_id');
    ($page, $limit) = validate_pagination($page, $limit);
    
    my $response = $self->{client}->get('/licenses', {
        user_id => $user_id,
        page => $page,
        limit => $limit
    });
    
    return {
        data => $response->{data},
        total => $response->{total},
        page => $response->{page},
        limit => $response->{limit}
    };
}

sub stats {
    my ($self) = @_;
    my $response = $self->{client}->get('/licenses/stats');
    return $response->{data};
}

sub validate_required_params {
    my ($self, $user_id, $product_id) = @_;
    validate_not_empty($user_id, 'user_id');
    validate_not_empty($product_id, 'product_id');
}

sub validate_uuid {
    my ($self, $id, $field_name) = @_;
    validate_not_empty($id, $field_name);
    unless (validate_uuid($id)) {
        die "Invalid $field_name format";
    }
}

1;

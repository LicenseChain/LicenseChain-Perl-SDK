package LicenseChain::Services::UserService;

use strict;
use warnings;
use Exporter 'import';
use LicenseChain::Utils qw(validate_uuid validate_not_empty validate_email sanitize_metadata validate_pagination);
use LicenseChain::Exceptions qw(ValidationException);

our @EXPORT_OK = qw(
    new
    create
    get
    update
    delete
    list
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
    my ($self, $email, $name, $metadata) = @_;
    $self->validate_email($email);
    
    my $data = {
        email => $email,
        name => $name,
        password => 'ChangeMe123!',
        metadata => sanitize_metadata($metadata || {})
    };
    
    my $response = $self->{client}->post('/auth/register', $data);
    return $response->{user} || $response->{data} || $response;
}

sub get {
    my ($self, $user_id) = @_;
    validate_not_empty($user_id, 'user_id');
    
    my $response = $self->{client}->get('/auth/me');
    return $response->{data} || $response;
}

sub update {
    my ($self, $user_id, $updates) = @_;
    die 'User update endpoint is not available in API v1';
}

sub delete {
    my ($self, $user_id) = @_;
    die 'User delete endpoint is not available in API v1';
}

sub list {
    my ($self, $page, $limit) = @_;
    ($page, $limit) = validate_pagination($page, $limit);
    
    return {
        data => [],
        total => 0,
        page => $page,
        limit => $limit
    };
}

sub stats {
    my ($self) = @_;
    return {
        total => 0,
        active => 0,
        inactive => 0
    };
}

sub validate_email {
    my ($self, $email) = @_;
    validate_not_empty($email, 'email');
    unless (validate_email($email)) {
        die 'Invalid email format';
    }
}

sub validate_uuid {
    my ($self, $id, $field_name) = @_;
    validate_not_empty($id, $field_name);
    unless (validate_uuid($id)) {
        die "Invalid $field_name format";
    }
}

1;

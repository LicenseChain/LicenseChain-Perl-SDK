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
        metadata => sanitize_metadata($metadata || {})
    };
    
    my $response = $self->{client}->post('/users', $data);
    return $response->{data};
}

sub get {
    my ($self, $user_id) = @_;
    $self->validate_uuid($user_id, 'user_id');
    
    my $response = $self->{client}->get("/users/$user_id");
    return $response->{data};
}

sub update {
    my ($self, $user_id, $updates) = @_;
    $self->validate_uuid($user_id, 'user_id');
    
    my $response = $self->{client}->put("/users/$user_id", sanitize_metadata($updates));
    return $response->{data};
}

sub delete {
    my ($self, $user_id) = @_;
    $self->validate_uuid($user_id, 'user_id');
    
    $self->{client}->delete("/users/$user_id");
    return 1;
}

sub list {
    my ($self, $page, $limit) = @_;
    ($page, $limit) = validate_pagination($page, $limit);
    
    my $response = $self->{client}->get('/users', {
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
    my $response = $self->{client}->get('/users/stats');
    return $response->{data};
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

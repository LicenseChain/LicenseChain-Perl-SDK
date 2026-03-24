package LicenseChain::Services::WebhookService;

use strict;
use warnings;
use Exporter 'import';
use LicenseChain::Utils qw(validate_uuid validate_not_empty sanitize_metadata);
use LicenseChain::Exceptions qw(ValidationException);

our @EXPORT_OK = qw(
    new
    create
    get
    update
    delete
    list
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
    my ($self, $url, $events, $secret) = @_;
    $self->validate_webhook_params($url, $events);
    
    my $data = {
        url => $url,
        events => $events,
        secret => $secret
    };
    
    my $response = $self->{client}->post('/webhooks', $data);
    return $self->normalize_webhook_payload($response->{data} || $response);
}

sub get {
    my ($self, $webhook_id) = @_;
    $self->validate_uuid($webhook_id, 'webhook_id');
    
    my $response = $self->{client}->get("/webhooks/$webhook_id");
    return $self->normalize_webhook_payload($response->{data} || $response);
}

sub update {
    my ($self, $webhook_id, $updates) = @_;
    $self->validate_uuid($webhook_id, 'webhook_id');
    
    my $response = $self->{client}->put("/webhooks/$webhook_id", sanitize_metadata($updates));
    return $self->normalize_webhook_payload($response->{data} || $response);
}

sub delete {
    my ($self, $webhook_id) = @_;
    $self->validate_uuid($webhook_id, 'webhook_id');
    
    $self->{client}->delete("/webhooks/$webhook_id");
    return 1;
}

sub list {
    my ($self) = @_;
    my $response = $self->{client}->get('/webhooks');
    my $items = $response->{data} || [];
    return [ map { $self->normalize_webhook_payload($_) } @$items ];
}

sub validate_webhook_params {
    my ($self, $url, $events) = @_;
    validate_not_empty($url, 'url');
    unless (@$events) {
        die 'Events cannot be empty';
    }
}

sub validate_uuid {
    my ($self, $id, $field_name) = @_;
    validate_not_empty($id, $field_name);
    unless (validate_uuid($id)) {
        die "Invalid $field_name format";
    }
}

sub normalize_webhook_payload {
    my ($self, $payload) = @_;
    return {
        id => $payload->{id},
        app_id => $payload->{app_id} || '',
        url => $payload->{url} || '',
        events => $payload->{events} || [],
        secret => $payload->{secret},
        status => (($payload->{active} // 1) ? 'active' : 'inactive'),
        created_at => $payload->{created_at} || $payload->{createdAt},
        updated_at => $payload->{updated_at} || $payload->{updatedAt}
    };
}

1;

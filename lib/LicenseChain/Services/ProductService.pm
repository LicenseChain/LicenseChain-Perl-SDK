package LicenseChain::Services::ProductService;

use strict;
use warnings;
use Exporter 'import';
use LicenseChain::Utils qw(validate_uuid validate_not_empty validate_positive validate_currency sanitize_metadata validate_pagination);
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
    my ($self, $name, $description, $price, $currency, $metadata) = @_;
    $self->validate_required_params($name, $price, $currency);
    
    my $data = {
        name => $name,
        description => $description,
        price => $price,
        currency => $currency,
        metadata => sanitize_metadata($metadata || {})
    };
    
    my $response = $self->{client}->post('/products', $data);
    return $response->{data};
}

sub get {
    my ($self, $product_id) = @_;
    $self->validate_uuid($product_id, 'product_id');
    
    my $response = $self->{client}->get("/products/$product_id");
    return $response->{data};
}

sub update {
    my ($self, $product_id, $updates) = @_;
    $self->validate_uuid($product_id, 'product_id');
    
    my $response = $self->{client}->put("/products/$product_id", sanitize_metadata($updates));
    return $response->{data};
}

sub delete {
    my ($self, $product_id) = @_;
    $self->validate_uuid($product_id, 'product_id');
    
    $self->{client}->delete("/products/$product_id");
    return 1;
}

sub list {
    my ($self, $page, $limit) = @_;
    ($page, $limit) = validate_pagination($page, $limit);
    
    my $response = $self->{client}->get('/products', {
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
    my $response = $self->{client}->get('/products/stats');
    return $response->{data};
}

sub validate_required_params {
    my ($self, $name, $price, $currency) = @_;
    validate_not_empty($name, 'name');
    if (defined $price) {
        validate_positive($price, 'price');
    }
    unless (validate_currency($currency)) {
        die 'Invalid currency';
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

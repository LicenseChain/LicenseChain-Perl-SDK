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
    die 'Product endpoints are not available in API v1';
}

sub get {
    my ($self, $product_id) = @_;
    die 'Product endpoints are not available in API v1';
}

sub update {
    my ($self, $product_id, $updates) = @_;
    die 'Product endpoints are not available in API v1';
}

sub delete {
    my ($self, $product_id) = @_;
    die 'Product endpoints are not available in API v1';
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
        revenue => 0
    };
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

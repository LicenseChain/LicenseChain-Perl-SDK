package LicenseChain::SDK;

use strict;
use warnings;
use Exporter 'import';
use LicenseChain::Configuration;
use LicenseChain::ApiClient;
use LicenseChain::Services::LicenseService;
use LicenseChain::Services::UserService;
use LicenseChain::Services::ProductService;
use LicenseChain::Services::WebhookService;
use LicenseChain::Exceptions qw(ConfigurationException);

our @EXPORT_OK = qw(
    new
    get_configuration
    get_licenses
    get_users
    get_products
    get_webhooks
    ping
    health
    create
    from_environment
);

our $VERSION = '1.0.0';

sub new {
    my ($class, $config) = @_;
    
    unless ($config->is_valid()) {
        die "API key is required";
    }
    
    my $self = {
        config => $config,
        api_client => LicenseChain::ApiClient->new($config),
        licenses => LicenseChain::Services::LicenseService->new(undef),
        users => LicenseChain::Services::UserService->new(undef),
        products => LicenseChain::Services::ProductService->new(undef),
        webhooks => LicenseChain::Services::WebhookService->new(undef)
    };
    
    # Initialize services with API client
    $self->{licenses} = LicenseChain::Services::LicenseService->new($self->{api_client});
    $self->{users} = LicenseChain::Services::UserService->new($self->{api_client});
    $self->{products} = LicenseChain::Services::ProductService->new($self->{api_client});
    $self->{webhooks} = LicenseChain::Services::WebhookService->new($self->{api_client});
    
    bless $self, $class;
    return $self;
}

sub get_configuration {
    my ($self) = @_;
    return $self->{config};
}

sub get_licenses {
    my ($self) = @_;
    return $self->{licenses};
}

sub get_users {
    my ($self) = @_;
    return $self->{users};
}

sub get_products {
    my ($self) = @_;
    return $self->{products};
}

sub get_webhooks {
    my ($self) = @_;
    return $self->{webhooks};
}

sub ping {
    my ($self) = @_;
    return $self->{api_client}->ping();
}

sub health {
    my ($self) = @_;
    return $self->{api_client}->health();
}

sub create {
    my ($class, $api_key, $base_url) = @_;
    $base_url ||= 'https://api.licensechain.app';
    my $config = LicenseChain::Configuration->new($api_key, $base_url);
    return $class->new($config);
}

sub from_environment {
    my ($class) = @_;
    my $config = LicenseChain::Configuration->from_environment();
    return $class->new($config);
}

1;
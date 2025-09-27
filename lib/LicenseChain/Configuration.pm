package LicenseChain::Configuration;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(
    new
    get_api_key
    get_base_url
    get_timeout
    get_retries
    is_valid
    set_api_key
    set_base_url
    setTimeout
    set_retries
    to_hash
    from_hash
    from_environment
);

our $VERSION = '1.0.0';

sub new {
    my ($class, $api_key, $base_url, $timeout, $retries) = @_;
    $base_url ||= 'https://api.licensechain.app';
    $timeout ||= 30;
    $retries ||= 3;
    
    my $self = {
        api_key => $api_key,
        base_url => $base_url,
        timeout => $timeout,
        retries => $retries
    };
    
    bless $self, $class;
    return $self;
}

sub get_api_key {
    my ($self) = @_;
    return $self->{api_key};
}

sub get_base_url {
    my ($self) = @_;
    return $self->{base_url};
}

sub get_timeout {
    my ($self) = @_;
    return $self->{timeout};
}

sub get_retries {
    my ($self) = @_;
    return $self->{retries};
}

sub is_valid {
    my ($self) = @_;
    return defined $self->{api_key} && length($self->{api_key}) > 0;
}

sub set_api_key {
    my ($self, $api_key) = @_;
    $self->{api_key} = $api_key;
    return $self;
}

sub set_base_url {
    my ($self, $base_url) = @_;
    $self->{base_url} = $base_url;
    return $self;
}

sub setTimeout {
    my ($self, $timeout) = @_;
    $self->{timeout} = $timeout;
    return $self;
}

sub set_retries {
    my ($self, $retries) = @_;
    $self->{retries} = $retries;
    return $self;
}

sub to_hash {
    my ($self) = @_;
    return {
        api_key => $self->{api_key},
        base_url => $self->{base_url},
        timeout => $self->{timeout},
        retries => $self->{retries}
    };
}

sub from_hash {
    my ($class, $config) = @_;
    return $class->new(
        $config->{api_key} || '',
        $config->{base_url} || 'https://api.licensechain.app',
        $config->{timeout} || 30,
        $config->{retries} || 3
    );
}

sub from_environment {
    my ($class) = @_;
    return $class->new(
        $ENV{LICENSECHAIN_API_KEY} || '',
        $ENV{LICENSECHAIN_BASE_URL} || 'https://api.licensechain.app',
        $ENV{LICENSECHAIN_TIMEOUT} || 30,
        $ENV{LICENSECHAIN_RETRIES} || 3
    );
}

1;

package LicenseChain::ApiClient;

use strict;
use warnings;
use Exporter 'import';
use LWP::UserAgent;
use HTTP::Request;
use LicenseChain::Utils qw(json_serialize json_deserialize retry_with_backoff);
use LicenseChain::Exceptions qw(
    NetworkException
    ServerException
    ValidationException
    AuthenticationException
    NotFoundException
    RateLimitException
    LicenseChainException
);

our @EXPORT_OK = qw(
    new
    get
    post
    put
    delete
    ping
    health
);

our $VERSION = '1.0.0';

sub new {
    my ($class, $config) = @_;
    
    my $self = {
        config => $config,
        ua => LWP::UserAgent->new(
            timeout => $config->get_timeout(),
            agent => 'LicenseChain-Perl-SDK/1.0.0'
        )
    };
    
    bless $self, $class;
    return $self;
}

sub get {
    my ($self, $endpoint, $params) = @_;
    return $self->make_request('GET', $endpoint, undef, $params);
}

sub post {
    my ($self, $endpoint, $data) = @_;
    return $self->make_request('POST', $endpoint, $data);
}

sub put {
    my ($self, $endpoint, $data) = @_;
    return $self->make_request('PUT', $endpoint, $data);
}

sub delete {
    my ($self, $endpoint, $data) = @_;
    return $self->make_request('DELETE', $endpoint, $data);
}

sub make_request {
    my ($self, $method, $endpoint, $data, $params) = @_;
    my $url = $self->build_url($endpoint, $params);
    my $request = $self->build_request($method, $url, $data);
    
    return retry_with_backoff(sub {
        return $self->send_request($request);
    }, $self->{config}->get_retries());
}

sub build_url {
    my ($self, $endpoint, $params) = @_;
    my $url = $self->{config}->get_base_url() . '/' . $endpoint;
    $url =~ s/\/+/\//g;
    
    if ($params && %$params) {
        my @query_params;
        while (my ($key, $value) = each %$params) {
            push @query_params, "$key=" . URI::Escape::uri_escape($value);
        }
        $url .= '?' . join('&', @query_params);
    }
    
    return $url;
}

sub build_request {
    my ($self, $method, $url, $data) = @_;
    my $request = HTTP::Request->new($method, $url);
    
    $request->header('Authorization' => 'Bearer ' . $self->{config}->get_api_key());
    $request->header('Content-Type' => 'application/json');
    $request->header('X-API-Version' => '1.0');
    $request->header('X-Platform' => 'perl-sdk');
    
    if ($data) {
        $request->content(json_serialize($data));
    }
    
    return $request;
}

sub send_request {
    my ($self, $request) = @_;
    my $response = $self->{ua}->request($request);
    
    if ($response->is_success) {
        my $content = $response->content;
        return $content ? json_deserialize($content) : {};
    }
    
    my $status_code = $response->code;
    my $content = $response->content;
    my $error_message = 'Unknown error';
    
    if ($content) {
        eval {
            my $data = json_deserialize($content);
            $error_message = $data->{error} || $data->{message} || $error_message;
        };
    }
    
    if ($status_code == 400) {
        die "Bad Request: $error_message";
    } elsif ($status_code == 401) {
        die "Unauthorized: $error_message";
    } elsif ($status_code == 403) {
        die "Forbidden: $error_message";
    } elsif ($status_code == 404) {
        die "Not Found: $error_message";
    } elsif ($status_code == 429) {
        die "Rate Limited: $error_message";
    } elsif ($status_code >= 500) {
        die "Server Error: $error_message";
    } else {
        die "Unexpected response: $status_code $error_message";
    }
}

sub ping {
    my ($self) = @_;
    return $self->get('/ping');
}

sub health {
    my ($self) = @_;
    return $self->get('/health');
}

1;

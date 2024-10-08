package LicenseChain;

use strict;
use warnings;
use LWP::UserAgent;
use JSON;

sub new {
    my ($class, $api_key) = @_;
    my $self = {
        api_key => $api_key,
        base_url => 'https://licensechain.app/api'
    };
    bless $self, $class;
    return $self;
}

sub validate_license {
    my ($self, $license_key) = @_;
    my $ua = LWP::UserAgent->new;
    my $url = $self->{base_url} . "/validate_license";

    my $response = $ua->post($url, {
        api_key => $self->{api_key},
        license_key => $license_key
    });

    if ($response->is_success) {
        my $content = $response->decoded_content;
        return decode_json($content);
    } else {
        return { error => $response->status_line };
    }
}

1;

package LicenseChain::LicenseAssertion;

use strict;
use warnings;

use Crypt::JWT qw(decode_jwt);
use HTTP::Tiny;
use JSON ();

our $VERSION = '1.0.0';

# Must match Core API LICENSE_TOKEN_USE_CLAIM.
our $LICENSE_TOKEN_USE_CLAIM = 'licensechain_license_v1';

# $opts: { expected_app_id => $str, issuer => $str }
sub verify_license_assertion_jwt {
    my ( $class, $token, $jwks_url, $opts ) = @_;
    $opts ||= {};
    $token =~ s/^\s+|\s+$//g;
    die 'empty token' if $token eq '';
    $jwks_url =~ s/^\s+|\s+$//g;
    die 'empty jwks_url' if $jwks_url eq '';

    my $http = HTTP::Tiny->new( timeout => 20 );
    my $res  = $http->get($jwks_url);
    die "JWKS fetch failed: $res->{status}" unless $res->{success};

    my $jwks = JSON::decode_json( $res->{content} );

    my %args = (
        token      => $token,
        kid_keys   => $jwks,
        accepted_alg => 'RS256',
    );
    if ( my $iss = $opts->{issuer} ) {
        $iss =~ s/^\s+|\s+$//g;
        if ( $iss ne '' ) {
            $args{verify_iss} = $iss;
        }
    }

    my $payload = decode_jwt(%args);

    my $tu = $payload->{token_use} // '';
    die qq{Invalid license token: expected token_use "$LICENSE_TOKEN_USE_CLAIM"}
      unless $tu eq $LICENSE_TOKEN_USE_CLAIM;

    if ( my $want = $opts->{expected_app_id} ) {
        $want =~ s/^\s+|\s+$//g;
        if ( $want ne '' ) {
            my $aud = $payload->{aud};
            my $ok  = 0;
            if ( defined $aud ) {
                if ( !ref $aud && $aud eq $want ) { $ok = 1; }
                elsif ( ref $aud eq 'ARRAY' && grep { $_ eq $want } @$aud ) { $ok = 1; }
            }
            die 'Invalid license token: aud does not match expected app id' unless $ok;
        }
    }

    return $payload;
}

1;

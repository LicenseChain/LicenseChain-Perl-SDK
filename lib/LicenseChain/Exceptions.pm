package LicenseChain::Exceptions;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(
    ConfigurationException
    ValidationException
    AuthenticationException
    NetworkException
);

sub ConfigurationException { return 'LicenseChain::ConfigurationException'; }
sub ValidationException { return 'LicenseChain::ValidationException'; }
sub AuthenticationException { return 'LicenseChain::AuthenticationException'; }
sub NetworkException { return 'LicenseChain::NetworkException'; }

package LicenseChain::BaseException;

use strict;
use warnings;
use overload q{""} => 'message', fallback => 1;

sub new {
    my ($class, $message) = @_;
    my $self = {
        message => defined($message) ? $message : 'LicenseChain exception'
    };
    bless $self, $class;
    return $self;
}

sub message {
    my ($self) = @_;
    return $self->{message};
}

sub throw {
    my ($class, $message) = @_;
    die $class->new($message);
}

package LicenseChain::ConfigurationException;
use parent -norequire, 'LicenseChain::BaseException';

package LicenseChain::ValidationException;
use parent -norequire, 'LicenseChain::BaseException';

package LicenseChain::AuthenticationException;
use parent -norequire, 'LicenseChain::BaseException';

package LicenseChain::NetworkException;
use parent -norequire, 'LicenseChain::BaseException';

1;

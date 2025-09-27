package LicenseChain::WebhookHandler;

use strict;
use warnings;
use Exporter 'import';
use LicenseChain::Utils qw(verify_webhook_signature json_serialize);
use LicenseChain::Exceptions qw(ValidationException AuthenticationException);

our @EXPORT_OK = qw(
    WebhookEvents
);

our $VERSION = '1.0.0';

sub new {
    my ($class, $secret, $tolerance) = @_;
    $tolerance ||= 300; # seconds
    
    my $self = {
        secret => $secret,
        tolerance => $tolerance
    };
    
    bless $self, $class;
    return $self;
}

sub verify_signature {
    my ($self, $payload, $signature) = @_;
    return verify_webhook_signature($payload, $signature, $self->{secret});
}

sub verify_timestamp {
    my ($self, $timestamp) = @_;
    eval {
        my $webhook_time = Time::Piece->strptime($timestamp, '%Y-%m-%dT%H:%M:%SZ');
        my $current_time = Time::Piece->new();
        my $time_diff = abs($current_time->epoch - $webhook_time->epoch);
        
        if ($time_diff > $self->{tolerance}) {
            die "Webhook timestamp too old: $time_diff seconds";
        }
    };
    if ($@) {
        die "Invalid timestamp format: $@";
    }
}

sub verify_webhook {
    my ($self, $payload, $signature, $timestamp) = @_;
    $self->verify_timestamp($timestamp);
    
    unless ($self->verify_signature($payload, $signature)) {
        die "Invalid webhook signature";
    }
}

sub process_event {
    my ($self, $event_data) = @_;
    my $payload = json_serialize($event_data->{data} || {});
    $self->verify_webhook($payload, $event_data->{signature}, $event_data->{timestamp});
    
    my $event_type = $event_data->{type} || '';
    
    if ($event_type eq 'license.created') {
        $self->handle_license_created($event_data);
    } elsif ($event_type eq 'license.updated') {
        $self->handle_license_updated($event_data);
    } elsif ($event_type eq 'license.revoked') {
        $self->handle_license_revoked($event_data);
    } elsif ($event_type eq 'license.expired') {
        $self->handle_license_expired($event_data);
    } elsif ($event_type eq 'user.created') {
        $self->handle_user_created($event_data);
    } elsif ($event_type eq 'user.updated') {
        $self->handle_user_updated($event_data);
    } elsif ($event_type eq 'user.deleted') {
        $self->handle_user_deleted($event_data);
    } elsif ($event_type eq 'product.created') {
        $self->handle_product_created($event_data);
    } elsif ($event_type eq 'product.updated') {
        $self->handle_product_updated($event_data);
    } elsif ($event_type eq 'product.deleted') {
        $self->handle_product_deleted($event_data);
    } elsif ($event_type eq 'payment.completed') {
        $self->handle_payment_completed($event_data);
    } elsif ($event_type eq 'payment.failed') {
        $self->handle_payment_failed($event_data);
    } elsif ($event_type eq 'payment.refunded') {
        $self->handle_payment_refunded($event_data);
    } else {
        print "Unknown webhook event type: $event_type\n";
    }
}

sub handle_license_created {
    my ($self, $event_data) = @_;
    print "License created: $event_data->{id}\n";
    # Add custom logic for license created event
}

sub handle_license_updated {
    my ($self, $event_data) = @_;
    print "License updated: $event_data->{id}\n";
    # Add custom logic for license updated event
}

sub handle_license_revoked {
    my ($self, $event_data) = @_;
    print "License revoked: $event_data->{id}\n";
    # Add custom logic for license revoked event
}

sub handle_license_expired {
    my ($self, $event_data) = @_;
    print "License expired: $event_data->{id}\n";
    # Add custom logic for license expired event
}

sub handle_user_created {
    my ($self, $event_data) = @_;
    print "User created: $event_data->{id}\n";
    # Add custom logic for user created event
}

sub handle_user_updated {
    my ($self, $event_data) = @_;
    print "User updated: $event_data->{id}\n";
    # Add custom logic for user updated event
}

sub handle_user_deleted {
    my ($self, $event_data) = @_;
    print "User deleted: $event_data->{id}\n";
    # Add custom logic for user deleted event
}

sub handle_product_created {
    my ($self, $event_data) = @_;
    print "Product created: $event_data->{id}\n";
    # Add custom logic for product created event
}

sub handle_product_updated {
    my ($self, $event_data) = @_;
    print "Product updated: $event_data->{id}\n";
    # Add custom logic for product updated event
}

sub handle_product_deleted {
    my ($self, $event_data) = @_;
    print "Product deleted: $event_data->{id}\n";
    # Add custom logic for product deleted event
}

sub handle_payment_completed {
    my ($self, $event_data) = @_;
    print "Payment completed: $event_data->{id}\n";
    # Add custom logic for payment completed event
}

sub handle_payment_failed {
    my ($self, $event_data) = @_;
    print "Payment failed: $event_data->{id}\n";
    # Add custom logic for payment failed event
}

sub handle_payment_refunded {
    my ($self, $event_data) = @_;
    print "Payment refunded: $event_data->{id}\n";
    # Add custom logic for payment refunded event
}

package WebhookEvents;

use constant {
    LICENSE_CREATED => 'license.created',
    LICENSE_UPDATED => 'license.updated',
    LICENSE_REVOKED => 'license.revoked',
    LICENSE_EXPIRED => 'license.expired',
    USER_CREATED => 'user.created',
    USER_UPDATED => 'user.updated',
    USER_DELETED => 'user.deleted',
    PRODUCT_CREATED => 'product.created',
    PRODUCT_UPDATED => 'product.updated',
    PRODUCT_DELETED => 'product.deleted',
    PAYMENT_COMPLETED => 'payment.completed',
    PAYMENT_FAILED => 'payment.failed',
    PAYMENT_REFUNDED => 'payment.refunded'
};

1;

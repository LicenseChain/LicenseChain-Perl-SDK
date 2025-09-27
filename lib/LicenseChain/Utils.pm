package LicenseChain::Utils;

use strict;
use warnings;
use Exporter 'import';
use Digest::SHA qw(sha256_hex);
use Digest::MD5 qw(md5_hex);
use MIME::Base64 qw(encode_base64 decode_base64);
use Data::UUID;
use JSON;
use Time::Piece;
use Time::Seconds;

our @EXPORT_OK = qw(
    validate_email
    validate_license_key
    validate_uuid
    validate_amount
    validate_currency
    validate_status
    sanitize_input
    sanitize_metadata
    generate_license_key
    generate_uuid
    format_timestamp
    parse_timestamp
    validate_pagination
    validate_date_range
    create_webhook_signature
    verify_webhook_signature
    retry_with_backoff
    format_bytes
    format_duration
    capitalize_first
    to_snake_case
    to_pascal_case
    truncate_string
    remove_special_chars
    slugify
    validate_not_empty
    validate_positive
    validate_range
    json_serialize
    json_deserialize
    deep_merge
    chunk_array
    flatten_hash
    unflatten_hash
    generate_random_string
    generate_random_bytes
    sha256
    sha1
    md5
    base64_encode
    base64_decode
    url_encode
    url_decode
    is_valid_json
    is_valid_url
    is_valid_ip
    is_valid_email
    get_current_timestamp
    get_current_date
    get_current_date_formatted
);

our $VERSION = '1.0.0';

sub validate_email {
    my ($email) = @_;
    return $email =~ /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
}

sub validate_license_key {
    my ($license_key) = @_;
    return length($license_key) == 32 && $license_key =~ /^[A-Z0-9]+$/;
}

sub validate_uuid {
    my ($uuid) = @_;
    return $uuid =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
}

sub validate_amount {
    my ($amount) = @_;
    return defined $amount && $amount =~ /^\d+(\.\d+)?$/ && $amount > 0;
}

sub validate_currency {
    my ($currency) = @_;
    my @valid_currencies = qw(USD EUR GBP CAD AUD JPY CHF CNY);
    return grep { uc($currency) eq $_ } @valid_currencies;
}

sub validate_status {
    my ($status, $allowed_statuses) = @_;
    return grep { $status eq $_ } @$allowed_statuses;
}

sub sanitize_input {
    my ($input) = @_;
    return '' unless defined $input;
    $input =~ s/&/&amp;/g;
    $input =~ s/</&lt;/g;
    $input =~ s/>/&gt;/g;
    $input =~ s/"/&quot;/g;
    $input =~ s/'/&#x27;/g;
    return $input;
}

sub sanitize_metadata {
    my ($metadata) = @_;
    return {} unless ref $metadata eq 'HASH';
    
    my $sanitized = {};
    while (my ($key, $value) = each %$metadata) {
        if (ref $value eq 'HASH') {
            $sanitized->{$key} = sanitize_metadata($value);
        } elsif (ref $value eq 'ARRAY') {
            $sanitized->{$key} = [map { ref $_ eq 'HASH' ? sanitize_metadata($_) : sanitize_input($_) } @$value];
        } else {
            $sanitized->{$key} = sanitize_input($value);
        }
    }
    return $sanitized;
}

sub generate_license_key {
    my @chars = ('A'..'Z', '0'..'9');
    my $result = '';
    for (1..32) {
        $result .= $chars[rand @chars];
    }
    return $result;
}

sub generate_uuid {
    my $ug = Data::UUID->new;
    return lc($ug->create_str());
}

sub format_timestamp {
    my ($timestamp) = @_;
    my $time = Time::Piece->new($timestamp);
    return $time->strftime('%Y-%m-%dT%H:%M:%SZ');
}

sub parse_timestamp {
    my ($timestamp) = @_;
    my $time = Time::Piece->strptime($timestamp, '%Y-%m-%dT%H:%M:%SZ');
    return $time->epoch;
}

sub validate_pagination {
    my ($page, $limit) = @_;
    $page = $page || 1;
    $limit = $limit || 10;
    $page = 1 if $page < 1;
    $limit = 1 if $limit < 1;
    $limit = 100 if $limit > 100;
    return ($page, $limit);
}

sub validate_date_range {
    my ($start_date, $end_date) = @_;
    my $start_time = parse_timestamp($start_date);
    my $end_time = parse_timestamp($end_date);
    
    if ($start_time > $end_time) {
        die "Start date must be before or equal to end date";
    }
}

sub create_webhook_signature {
    my ($payload, $secret) = @_;
    return sha256_hex($payload . $secret);
}

sub verify_webhook_signature {
    my ($payload, $signature, $secret) = @_;
    my $expected_signature = create_webhook_signature($payload, $secret);
    return $signature eq $expected_signature;
}

sub retry_with_backoff {
    my ($callback, $max_retries, $initial_delay) = @_;
    $max_retries ||= 3;
    $initial_delay ||= 1.0;
    
    my $delay = $initial_delay;
    
    for my $attempt (0..$max_retries) {
        eval {
            return $callback->();
        };
        if ($@) {
            if ($attempt == $max_retries) {
                die $@;
            }
            sleep($delay);
            $delay *= 2;
        }
    }
}

sub format_bytes {
    my ($bytes) = @_;
    my @units = qw(B KB MB GB TB PB);
    my $threshold = 1024;
    
    return "$bytes B" if $bytes < $threshold;
    
    my $size = $bytes;
    my $unit_index = 0;
    
    while ($size >= $threshold && $unit_index < $#units) {
        $size /= $threshold;
        $unit_index++;
    }
    
    return sprintf("%.1f %s", $size, $units[$unit_index]);
}

sub format_duration {
    my ($seconds) = @_;
    if ($seconds < 60) {
        return "${seconds}s";
    } elsif ($seconds < 3600) {
        my $minutes = int($seconds / 60);
        my $remaining_seconds = $seconds % 60;
        return "${minutes}m ${remaining_seconds}s";
    } elsif ($seconds < 86400) {
        my $hours = int($seconds / 3600);
        my $minutes = int(($seconds % 3600) / 60);
        return "${hours}h ${minutes}m";
    } else {
        my $days = int($seconds / 86400);
        my $hours = int(($seconds % 86400) / 3600);
        return "${days}d ${hours}h";
    }
}

sub capitalize_first {
    my ($text) = @_;
    return '' unless $text;
    return ucfirst(lc($text));
}

sub to_snake_case {
    my ($text) = @_;
    $text =~ s/([a-z])([A-Z])/$1_$2/g;
    return lc($text);
}

sub to_pascal_case {
    my ($text) = @_;
    $text =~ s/_(\w)/\U$1/g;
    return ucfirst($text);
}

sub truncate_string {
    my ($text, $max_length) = @_;
    return $text if length($text) <= $max_length;
    return substr($text, 0, $max_length - 3) . '...';
}

sub remove_special_chars {
    my ($text) = @_;
    $text =~ s/[^a-zA-Z0-9\s]//g;
    return $text;
}

sub slugify {
    my ($text) = @_;
    $text = lc($text);
    $text =~ s/[^a-z0-9\s-]//g;
    $text =~ s/\s+/-/g;
    $text =~ s/-+/-/g;
    $text =~ s/^-|-$//g;
    return $text;
}

sub validate_not_empty {
    my ($value, $field_name) = @_;
    die "$field_name cannot be empty" unless defined $value && length($value) > 0;
}

sub validate_positive {
    my ($number, $field_name) = @_;
    die "$field_name must be positive" unless defined $number && $number > 0;
}

sub validate_range {
    my ($number, $min, $max, $field_name) = @_;
    die "$field_name must be between $min and $max" unless $number >= $min && $number <= $max;
}

sub json_serialize {
    my ($obj) = @_;
    my $json = JSON->new->utf8->pretty;
    return $json->encode($obj);
}

sub json_deserialize {
    my ($json_string) = @_;
    my $json = JSON->new->utf8;
    return $json->decode($json_string);
}

sub deep_merge {
    my ($hash1, $hash2) = @_;
    my $result = {%$hash1};
    
    while (my ($key, $value) = each %$hash2) {
        if (ref $value eq 'HASH' && ref $result->{$key} eq 'HASH') {
            $result->{$key} = deep_merge($result->{$key}, $value);
        } else {
            $result->{$key} = $value;
        }
    }
    
    return $result;
}

sub chunk_array {
    my ($array, $chunk_size) = @_;
    my @chunks;
    for (my $i = 0; $i < @$array; $i += $chunk_size) {
        push @chunks, [@$array[$i..$i+$chunk_size-1]];
    }
    return @chunks;
}

sub flatten_hash {
    my ($hash, $separator) = @_;
    $separator ||= '.';
    my $result = {};
    
    while (my ($key, $value) = each %$hash) {
        if (ref $value eq 'HASH') {
            my $flattened = flatten_hash($value, $separator);
            while (my ($sub_key, $sub_value) = each %$flattened) {
                $result->{"$key$separator$sub_key"} = $sub_value;
            }
        } else {
            $result->{$key} = $value;
        }
    }
    
    return $result;
}

sub unflatten_hash {
    my ($hash, $separator) = @_;
    $separator ||= '.';
    my $result = {};
    
    while (my ($key, $value) = each %$hash) {
        my @keys = split /\Q$separator\E/, $key;
        my $current = \$result;
        
        for my $k (@keys[0..$#keys-1]) {
            $current = \$$current->{$k};
        }
        
        $$current->{$keys[-1]} = $value;
    }
    
    return $result;
}

sub generate_random_string {
    my ($length, $characters) = @_;
    $characters ||= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    my $result = '';
    my $char_length = length($characters);
    
    for (1..$length) {
        $result .= substr($characters, int(rand($char_length)), 1);
    }
    
    return $result;
}

sub generate_random_bytes {
    my ($length) = @_;
    my $result = '';
    for (1..$length) {
        $result .= chr(int(rand(256)));
    }
    return $result;
}

sub sha256 {
    my ($data) = @_;
    return sha256_hex($data);
}

sub sha1 {
    my ($data) = @_;
    return Digest::SHA::sha1_hex($data);
}

sub md5 {
    my ($data) = @_;
    return md5_hex($data);
}

sub base64_encode {
    my ($data) = @_;
    return encode_base64($data);
}

sub base64_decode {
    my ($data) = @_;
    return decode_base64($data);
}

sub url_encode {
    my ($data) = @_;
    return URI::Escape::uri_escape($data);
}

sub url_decode {
    my ($data) = @_;
    return URI::Escape::uri_unescape($data);
}

sub is_valid_json {
    my ($json) = @_;
    eval { json_deserialize($json) };
    return !$@;
}

sub is_valid_url {
    my ($url) = @_;
    return $url =~ /^https?:\/\/.+/;
}

sub is_valid_ip {
    my ($ip) = @_;
    return $ip =~ /^(\d{1,3}\.){3}\d{1,3}$/;
}

sub is_valid_email {
    my ($email) = @_;
    return validate_email($email);
}

sub get_current_timestamp {
    return time();
}

sub get_current_date {
    my $time = Time::Piece->new();
    return $time->strftime('%Y-%m-%dT%H:%M:%SZ');
}

sub get_current_date_formatted {
    my ($format) = @_;
    my $time = Time::Piece->new();
    return $time->strftime($format);
}

1;

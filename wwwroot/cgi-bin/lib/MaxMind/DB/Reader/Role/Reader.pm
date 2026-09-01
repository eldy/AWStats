package MaxMind::DB::Reader::Role::Reader;

use strict;
use warnings;
use namespace::autoclean;
use autodie;

our $VERSION = '1.000014';

use Data::Validate::IP 0.25 qw( is_ip );
use MaxMind::DB::Types qw( Str );

use Moo::Role;

requires qw(
    _build_metadata
    _data_for_address
);

use constant DEBUG => $ENV{MAXMIND_DB_READER_DEBUG};

has file => (
    is       => 'ro',
    isa      => Str,
    coerce   => sub {"$_[0]"},
    required => 1,
);

sub record_for_address {
    my $self = shift;
    my $addr = shift;

    die 'You must provide an IP address to look up'
        unless defined $addr && length $addr;

    # We validate the IP address here as libmaxminddb allows more liberal
    # numbers and dots notation for IPv4 (e.g., `1.1.1` or `01.1.1.1`) rather
    # than requiring the standard dotted quad due to using getaddrinfo.
    die
        "The IP address you provided ($addr) is not a valid IPv4 or IPv6 address"
        unless is_ip($addr);

    return $self->_data_for_address($addr);
}

around _build_metadata => sub {
    my $orig = shift;
    my $self = shift;

    return $self->$orig(@_) unless DEBUG;

    my $metadata = $self->$orig(@_);

    $metadata->debug_dump;

    return $metadata;
};

1;

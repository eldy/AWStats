package MaxMind::DB::Reader::PP;

use strict;
use warnings;
use namespace::autoclean;
use autodie;

our $VERSION = '1.000014';

use Carp qw( confess );
use Math::BigInt ();
use MaxMind::DB::Types qw( Int );
use Socket 1.87 qw( inet_pton AF_INET AF_INET6 );

use Moo;
use MooX::StrictConstructor;

with 'MaxMind::DB::Reader::Role::Reader',
    'MaxMind::DB::Reader::Role::NodeReader',
    'MaxMind::DB::Reader::Role::HasDecoder',
    'MaxMind::DB::Role::Debugs';

has _ipv4_start_node => (
    is       => 'ro',
    isa      => Int,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_ipv4_start_node',
);

use constant DEBUG => $ENV{MAXMIND_DB_READER_DEBUG};

sub BUILD {
    my $self = shift;

    my $file = $self->file;

    die qq{Error opening database file "$file": The file does not exist.}
        unless -e $file;

    die qq{Error opening database file "$file": The file cannot be read.}
        unless -r _;

    # Build the metadata right away to ensure file's validity
    $self->metadata;

    return;
}

sub _build_data_source {
    my $self = shift;

    my $file = $self->file;
    open my $fh, '<:raw', $file;

    return $fh;
}

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _data_for_address {
    my $self = shift;
    my $addr = shift;

    my $pointer = $self->_find_address_in_tree($addr);

    ## no critic (Subroutines::ProhibitExplicitReturnUndef)
    return undef unless $pointer;

    return $self->_get_entry_data($pointer);
}
## use critic

sub _find_address_in_tree {
    my $self = shift;
    my $addr = shift;

    my $is_ipv6_addr = $addr =~ /:/;

    my $packed_addr = inet_pton( $is_ipv6_addr ? AF_INET6 : AF_INET, $addr );

    die
        "The IP address you provided ($addr) is not a valid IPv4 or IPv6 address"
        unless defined $packed_addr;

    my @address_bytes = unpack( 'C*', $packed_addr );

    # The first node of the tree is always node 0, at the beginning of the
    # value
    my $node = $self->ip_version == 6
        && !$is_ipv6_addr ? $self->_ipv4_start_node : 0;

    my $bit_length = @address_bytes * 8;
    for my $bit_num ( 0 .. $bit_length ) {
        last if $node >= $self->node_count;

        my $temp_bit = 0xFF & $address_bytes[ $bit_num >> 3 ];
        my $bit      = 1 & ( $temp_bit >> 7 - ( $bit_num % 8 ) );

        my ( $left_record, $right_record ) = $self->_read_node($node);

        $node = $bit ? $right_record : $left_record;

        if (DEBUG) {
            $self->_debug_string( 'Bit #',        $bit_length - $bit_num );
            $self->_debug_string( 'Bit value',    $bit );
            $self->_debug_string( 'Record',       $bit ? 'right' : 'left' );
            $self->_debug_string( 'Record value', $node );
        }
    }

    if ( $node == $self->node_count ) {
        $self->_debug_message('Record is empty')
            if DEBUG;
        return;
    }

    if ( $node >= $self->node_count ) {
        $self->_debug_message('Record is a data pointer')
            if DEBUG;
        return $node;
    }
}

sub iterate_search_tree {
    my $self          = shift;
    my $data_callback = shift;
    my $node_callback = shift;

    my $node_num  = 0;
    my $ipnum     = $self->ip_version() == 4 ? 0 : Math::BigInt->bzero();
    my $depth     = 1;
    my $max_depth = $self->ip_version() == 4 ? 32 : 128;

    $self->_iterate_search_tree(
        $data_callback,
        $node_callback,
        $node_num,
        $ipnum,
        $depth,
        $max_depth,
    );
}

## no critic (Subroutines::ProhibitManyArgs)
sub _iterate_search_tree {
    my $self          = shift;
    my $data_callback = shift;
    my $node_callback = shift;
    my $node_num      = shift;
    my $ipnum         = shift;
    my $depth         = shift;
    my $max_depth     = shift;

    ## no critic (TestingAndDebugging::ProhibitNoWarnings)
    no warnings 'recursion';
    ## use critic

    my @records = $self->_read_node($node_num);
    $node_callback->( $node_num, @records ) if $node_callback;

    for my $idx ( 0 .. 1 ) {
        my $value = $records[$idx];

        # We ignore empty branches of the search tree
        next if $value == $self->node_count();

        my $one = $self->ip_version() == 4 ? 1 : Math::BigInt->bone();
        $ipnum = $ipnum | ( $one << ( $max_depth - $depth ) ) if $idx;

        if ( $value <= $self->node_count() ) {
            $self->_iterate_search_tree(
                $data_callback,
                $node_callback,
                $value,
                $ipnum,
                $depth + 1,
                $max_depth,
            );
        }
        elsif ($data_callback) {
            $data_callback->(
                $ipnum, $depth,
                $self->_get_entry_data($value)
            );
        }
    }
}
## use critic

sub _get_entry_data {
    my $self   = shift;
    my $offset = shift;

    my $resolved = ( $offset - $self->node_count ) + $self->_search_tree_size;

    confess q{The MaxMind DB file's search tree is corrupt}
        if $resolved > $self->_data_source_size;

    if (DEBUG) {
        my $node_count = $self->node_count;
        my $tree_size  = $self->_search_tree_size;

        $self->_debug_string(
            'Resolved data pointer',
            "( $offset - $node_count ) + $tree_size = $resolved"
        );
    }

    # We only want the data from the decoder, not the offset where it was
    # found.
    return scalar $self->_decoder->decode($resolved);
}

sub _build_ipv4_start_node {
    my $self = shift;

    return 0 unless $self->ip_version == 6;

    my $node_num = 0;

    for ( 1 ... 96 ) {
        ($node_num) = $self->_read_node($node_num);
        last if $node_num >= $self->node_count;
    }

    return $node_num;
}

1;

package MaxMind::DB::Reader::Role::HasMetadata;

use strict;
use warnings;
use namespace::autoclean;
use autodie;

require bytes;

our $VERSION = '1.000014';
use Carp qw( confess );
use List::AllUtils qw( min );
use MaxMind::DB::Reader::Decoder;
use MaxMind::DB::Metadata;
use MaxMind::DB::Types qw( Int Metadata );

use Moo::Role;

with 'MaxMind::DB::Reader::Role::Sysreader';

has metadata => (
    is       => 'ro',
    isa      => Metadata,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_metadata',
    handles  => [
        'binary_format_major_version',
        'binary_format_minor_version',
        'build_epoch',
        'database_type',
        'description',
        'ip_version',
        'languages',
        'node_count',
        'record_size',
    ],
);

has _data_section_end => (
    is       => 'ro',
    writer   => '_set_data_section_end',
    isa      => Int,
    init_arg => undef,
);

my $MetadataStartMarker = "\xab\xcd\xefMaxMind.com";

sub _build_metadata {
    my $self = shift;

    # We need to make sure that whatever chunk we read will have the metadata
    # in it. The description metadata key is a hash of descriptions, one per
    # language. The description could be something verbose like "GeoIP 2.0
    # City Database, Multilingual - English, Chinese (Taiwan), Chinese
    # (China), French, German, Portuguese" (but with c. 20 languages). That
    # comes out to about 250 bytes _per key_. Multiply that by 20 languages,
    # and the description alon ecould use up about 5k. The other keys in the
    # metadata are very, very tiny.
    #
    # Given all this, reading 20k seems fairly future-proof. We'd have to have
    # extremely long descriptions or descriptions in 80 languages before this
    # became too long.

    my $size = $self->_data_source_size;

    my $last_bytes = min( $size, 20 * 1024 );
    my $last_block = q{};
    $self->_read( \$last_block, -$last_bytes, $last_bytes, 'seek from end' );

    my $start = ( $size - $last_bytes )
        + rindex( $last_block, $MetadataStartMarker );

    confess 'Error opening database file "'
        . $self->file
        . q{": The MaxMind DB file contains invalid metadata.}
        if $start < 0;

    # XXX - this is really gross but I couldn't come up with a better way to
    # factor this out that doesn't involve either looking for the metadata
    # marker multiple times _or_ storing the whole metadata raw chunk in
    # memory so we can calculate this later
    $self->_set_data_section_end( $size - ( $last_bytes - $start ) );

    ## no critic (Subroutines::ProhibitCallsToUnexportedSubs)
    $start += bytes::length($MetadataStartMarker);
    ## use critic

    my $raw = MaxMind::DB::Reader::Decoder->new(
        data_source  => $self->data_source,
        pointer_base => $start,
    )->decode($start);

    my $metadata = MaxMind::DB::Metadata->new($raw);

    return $metadata;
}

1;

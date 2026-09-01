package MaxMind::DB::Reader::Role::HasDecoder;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '1.000014';

use MaxMind::DB::Common qw( DATA_SECTION_SEPARATOR_SIZE );
use MaxMind::DB::Reader::Decoder;
use MaxMind::DB::Types qw( Decoder );

use Moo::Role;

with 'MaxMind::DB::Role::Debugs';

# Can't require accessors :(
# requires 'data_source', '_search_tree_size';

has _decoder => (
    is       => 'ro',
    isa      => Decoder,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_decoder',
);

sub _build_decoder {
    my $self = shift;

    return MaxMind::DB::Reader::Decoder->new(
        data_source  => $self->data_source,
        pointer_base => $self->_search_tree_size
            + DATA_SECTION_SEPARATOR_SIZE,
    );
}

1;

#!/usr/bin/perl -w
#
use Test::More tests => 4;
use Test::Deep;

my @arr = ( qr/ABc/, qr/abc/, qr/ccc/, qr/abc/, qr/ABc/ );

sub OptimizeArray {
    my ( $array, $notcasesensitive ) = @_;
    my %seen;

    if ($notcasesensitive) {

        # Case insensitive
        my $uncompiled_regex;
        return map {
            $uncompiled_regex = UnCompileRegex($_);
            !$seen{ lc $uncompiled_regex }++ ? qr/$uncompiled_regex/i : ()
        } @$array;
    }

    # Case sensitive
    return map { !$seen{$_}++ ? $_ : () } @$array;
}

sub UnCompileRegex {
    shift =~ /\(\?[-^\w]*:(.*)\)/;    # Works with all perl
                                      # shift =~ /\(\?[-\w]*:(.*)\)/;        < perl 5.14
    return $1;
}

sub OptimizeArray_old {
    my $array            = shift;
    my @arrayunreg       = map { UnCompileRegex($_) } @$array;
    my $notcasesensitive = shift;
    my $searchlist       = 0;
    if ($Debug) {
        debug( "OptimizeArray (notcasesensitive=$notcasesensitive)", 4 );
    }
    while ( $searchlist > -1 && @arrayunreg ) {
        my $elemtoremove = -1;
      OPTIMIZELOOP:
        foreach my $i ( $searchlist .. ( scalar @arrayunreg ) - 1 ) {

            # Search if $i elem is already treated by another elem
            foreach my $j ( 0 .. ( scalar @arrayunreg ) - 1 ) {
                if ( $i == $j ) { next; }
                my $parami =
                  $notcasesensitive ? lc( $arrayunreg[$i] ) : $arrayunreg[$i];
                my $paramj =
                  $notcasesensitive ? lc( $arrayunreg[$j] ) : $arrayunreg[$j];
                if ($Debug) {
                    debug( " Compare $i ($parami) to $j ($paramj)", 4 );
                }
                if ( index( $parami, $paramj ) > -1 ) {
                    if ($Debug) {
                        debug(
                            " Elem $i ($arrayunreg[$i]) already treated with elem $j ($arrayunreg[$j])",
                            4
                        );
                    }
                    $elemtoremove = $i;
                    last OPTIMIZELOOP;
                }
            }
        }
        if ( $elemtoremove > -1 ) {
            if ($Debug) {
                debug(
                    " Remove elem $elemtoremove - $arrayunreg[$elemtoremove]",
                    4
                );
            }
            splice @arrayunreg, $elemtoremove, 1;
            $searchlist = $elemtoremove;
        }
        else {
            $searchlist = -1;
        }
    }
    if ($notcasesensitive) {
        return map { qr/$_/i } @arrayunreg;
    }
    return map { qr/$_/ } @arrayunreg;
}

is_deeply(
    [ OptimizeArray( \@arr, 0 ) ],
    [
        qr/ABc/,
        qr/abc/,
        qr/ccc/,
    ],
    "case senitive OptimizeArray returns the expected results"
);
cmp_bag( [ OptimizeArray( \@arr, 0 ) ], [ OptimizeArray_old( \@arr, 0 ) ], "..and it matches the old method" );
is_deeply(
    [ OptimizeArray( \@arr, 1 ) ],
    [
        qr/ABc/i,
        qr/ccc/i,
    ],
    "case insenitive OptimizeArray returns the expected results"
);
cmp_bag( [ OptimizeArray( \@arr, 1 ) ], [ OptimizeArray_old( \@arr, 1 ) ], "..and it matches the old method" ) or diag explain [ OptimizeArray( \@arr, 1 ) ], [ OptimizeArray_old( \@arr, 1 ) ];


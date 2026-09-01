#!/usr/bin/perl -w
use Test::Simple tests => 2;


# Functions to tests (copy paste from awstats.pl)
sub UnCompileRegex {
	shift =~ /\(\?[-\w]*:(.*)\)/;
	return $1;
}
sub UnCompileRegex2 {
	shift =~ /\(\?[-\w]*:(.*)\)/;
	return $1;
}



push @INC, "../../wwwroot/cgi-bin/lib";
my $loadret = require "worms.pm";
@WormsSearchIDOrder         = map { qr/$_/i } @WormsSearchIDOrder;

foreach (@WormsSearchIDOrder) 
{
	my $worm = &UnCompileRegex($_);
	print "> ".$_." -> ".$worm."\n";
		
}


ok(&UnCompileRegex('(?i-xsm:\/default\.ida)') eq '\/default\.ida');                # check that we got something
ok(&UnCompileRegex2('(?i-xsm:\/default\.ida)') eq '\/default\.ida');                # check that we got something
    
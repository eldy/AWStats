#!/usr/bin/perl
# geoip_info.cgi
# Report geoip informations

require './awstats-lib.pl';
&ReadParse();

if (! $access{'update'}) { &error($text{'geoip_cannot'}); }

my $conf=""; my $dir="";
if ($in{'file'} =~ /awstats\.(.*)\.conf$/) { $conf=$1; }
if ($in{'file'} =~ /^(.*)[\\\/][^\\\/]+$/) { $dir=$1; }


# Display file contents
&header($title || $text{'geoip_title'}, "");

print "<hr>\n";

my $type=$in{'type'};
my $size=-1;
my $version='unknown';

local @st=stat($in{'file'});
my $size = $st[7];
my ($sec,$min,$hour,$day,$month,$year,$wday,$yday) = localtime($st[9]);
$year+=1900; $month++;

print "GeoIP information for file <b>".$in{'file'}."</b><br><br>\n";


# Try to get the GeoIP data file version at end of file
my $seekpos=($size-100);
if ($seekpos < 0) { $seekpos=0; }
open(GEOIPFILE,"<$in{'file'}") || print "Failed to open file $in{'file'}<br>\n";
binmode GEOIPFILE;
seek(GEOIPFILE,$seekpos,0);
my $nbread=0;
while (($nbread < 100) && ($line=<GEOIPFILE>)) {
    $nbread++;
    if ($line =~ /(Geo-.*)Copyright/i) { 
        $version=$1;
        last;
    }
}
close (GEOIPFILE);



print "Geoip data file type: <b>$type</b><br>\n";
print "Geoip data file size: <b>$size</b> bytes<br>\n";
printf("Geoip data file date: <b>%04s-%02s-%02s %02s:%02s:%02s</b><br>\n",$year,$month,$day,$hour,$min,$sec);
print "Geoip data file version: <b>$version</b><br>\n";

print "<br><br>\n";

# Back to config list
print "<hr>\n";
&footer("", $text{'index_return'});

0;


#!/usr/bin/perl
# With some other Unix Os, first line may be
#!/usr/local/bin/perl
# With Apache for Windows and ActiverPerl, first line may be
#!C:/Program Files/ActiveState/bin/perl
#-Description-------------------------------------------
# Launch awstats with -staticlinks option to build all static pages.
# See COPYING.TXT file about AWStats GNU General Public License.
#-------------------------------------------------------
use strict; no strict "refs";
#use diagnostics;
#use Thread;


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
# Last change $Revision$ - $Author$ - $Date$
my $REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
my $VERSION="1.1 (build $REVISION)";

# ---------- Init variables --------
my $Debug=0;
my $DIR;
my $PROG;
my $Extension;
my $Config;
my $Update=0;
my $AWSTATS="awstats.pl";



#-------------------------------------------------------
# Functions
#-------------------------------------------------------

sub error {
	print "Error: $_[0].\n";
    exit 1;
}

sub debug {
	my $level = $_[1] || 1;
	if ($Debug >= $level) { 
		my $debugstring = $_[0];
		if ($ENV{"GATEWAY_INTERFACE"}) { $debugstring =~ s/^ /&nbsp&nbsp /; $debugstring .= "<br>"; }
		print "DEBUG $level - ".time." : $debugstring\n";
		}
	0;
}

sub warning {
	my $messagestring=shift;
	debug("$messagestring",1);
#	if ($WarningMessages) {
#    	if ($HTMLOutput) {
#    		$messagestring =~ s/\n/\<br\>/g;
#    		print "$messagestring<br>\n";
#    	}
#    	else {
	    	print "$messagestring\n";
#    	}
#	}
}



#-------------------------------------------------------
# MAIN
#-------------------------------------------------------
my $QueryString=""; for (0..@ARGV-1) { $QueryString .= "$ARGV[$_] "; }
if ($QueryString =~ /debug=/i) { $Debug=$QueryString; $Debug =~ s/.*debug=//; $Debug =~ s/&.*//; $Debug =~ s/ .*//; }
if ($QueryString =~ /config=/i) { $Config=$QueryString; $Config =~ s/.*config=//; $Config =~ s/&.*//; $Config =~ s/ .*//; }
if ($QueryString =~ /awstatsprog=/i) { $AWSTATS=$QueryString; $AWSTATS =~ s/.*awstatsprog=//; $AWSTATS =~ s/&.*//; $AWSTATS =~ s/ .*//; }
if ($QueryString =~ /update/i) { $Update=1; }
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

if (! $Config) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG allows you to launch AWStats with -staticlinks option to\n";
	print "build all possible pages allowed by option -output.\n";
	print "\n";
	print "Usage:\n";
	print "  $PROG.$Extension [-update] -awstatsprog=pathtoawstatspl -config=...\n";
	print "\n";
	print "New versions and FAQ at http://awstats.sourceforge.net\n";
	exit 0;
}


my $retour;
my $OutputFile;

# Check if AWSTATS is ok
if (! -s "$AWSTATS") {
	error("Can't find AWStats program ('$AWSTATS').\nUse -awstatsprog option to solve this");
	exit 1;
}

# Launch awstats update
if ($Update) {
	`"$AWSTATS" -config=$Config -update`;
}


# Launch all awstats output
$retour=`"$AWSTATS" -config=$Config -staticlinks -output 2>&1`;
$OutputFile="awstats.$Config.html";
#$OutputFile="awstats.html";
open("OUTPUT",">$OutputFile") || error("Couldn't open log file \"$OutputFile\" for writing : $!");
print OUTPUT $retour;
close("OUTPUT");
my @OutputList=("allhosts","lasthosts","unknownip","urldetail","unknownos","unknownbrowser","browserdetail","allkeyphrases","errors404");
for my $output (@OutputList) {
	$retour=`"$AWSTATS" -config=$Config -staticlinks -output=$output 2>&1`;
	$OutputFile="awstats.$Config.$output.html";
#	$OutputFile="awstats.$output.html";
	open("OUTPUT",">$OutputFile") || error("Couldn't open log file \"$OutputFile\" for writing : $!");
	print OUTPUT $retour;
	close("OUTPUT");
}


0;	# Do not remove this line

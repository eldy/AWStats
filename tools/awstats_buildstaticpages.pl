#!/usr/bin/perl
# With some other Unix Os, first line may be
#!/usr/local/bin/perl
# With Apache for Windows and ActiverPerl, first line may be
#!C:/Program Files/ActiveState/bin/perl
#-Description-------------------------------------------
# Launch awstats with -staticlinks option to build all static pages.
# See COPYING.TXT file about AWStats GNU General Public License.
#-------------------------------------------------------
# $Revision$ - $Author$ - $Date$

# use strict is commented to make AWStats working with old perl.
use strict;no strict "refs";
#use warnings;		# Must be used in test mode only. This reduce a little process speed
#use diagnostics;	# Must be used in test mode only. This reduce a lot of process speed
#use Thread;


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
my $REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
my $VERSION="1.1 (build $REVISION)";

# ---------- Init variables --------
my $Debug=0;
my $DIR;
my $PROG;
my $Extension;
my $Config;
my $Update=0;
my $Date=0;
my $Lang;
my $YearRequired;
my $MonthRequired;
my $Awstats="awstats.pl";
my $OutputDir="";
my $OutputSuffix;
my $OutputFile;
my @OutputList=(
"allhosts","lasthosts","unknownip","urldetail",
"unknownos","unknownbrowser","browserdetail",
"refererse","refererpages",
#"referersites",
"allkeyphrases","allkeywords","errors404"
);


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
if ($QueryString =~ /-debug=/i)  { $Debug=$QueryString; $Debug =~ s/.*debug=//; $Debug =~ s/&.*//; $Debug =~ s/ .*//; }
if ($QueryString =~ /-config=/i) { $Config=$QueryString; $Config =~ s/.*config=//; $Config =~ s/&.*//; $Config =~ s/ .*//; }
if ($QueryString =~ /-awstatsprog=/i) { $Awstats=$QueryString; $Awstats =~ s/.*awstatsprog=//; $Awstats =~ s/&.*//; $Awstats =~ s/ .*//; }
if ($QueryString =~ /-dir=/i)    { $OutputDir=$QueryString; $OutputDir =~ s/.*dir=//; $OutputDir =~ s/&.*//; $OutputDir =~ s/ .*//; }
if ($QueryString =~ /-update/i)  { $Update=1; }
if ($QueryString =~ /-date/i)    { $Date=1; }
if ($QueryString =~ /-year=(\d\d\d\d)/i) { $YearRequired="$1"; }
if ($QueryString =~ /-month=(\d\d)/i || $QueryString =~ /month=(year)/i) { $MonthRequired="$1"; }
if ($QueryString =~ /-lang=([^\s&]+)/i)	{ $Lang=$1; }
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
if ($OutputDir) { if ($OutputDir !~ /[\\\/]$/) { $OutputDir.="/"; } }

if (! $Config) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG allows you to launch AWStats with -staticlinks option to\n";
	print "build all possible pages allowed by AWStats -output option.\n";
	print "\n";
	print "Usage:\n";
	print "  $PROG.$Extension (awstats_options) [awstatsbuildstaticpages_options]\n";
	print "\n";
	print "  where awstats_options are any option known by AWStats\n";
	print "   -config=configvalue is value for -config parameter (REQUIRED)\n";
	print "   -update             option used to update statistics before to generate pages\n";
	print "   -lang=LL            to output a HTML report in language LL (en,de,es,fr,...)\n";
	print "   -month=MM           to output a HTML report for an old month=MM\n";
	print "   -year=YYYY          to output a HTML report for an old year=YYYY\n";
	print "\n";
	print "  and awstatsbuildstaticpages_options can be\n";
	print "   -awstatsprog=pathtoawstatspl gives AWStats software (awstats.pl) path\n";
	print "   -dir=outputdir               to set output directory for generated pages\n";
	print "   -date                        used to add build date in built pages file name\n";
	print "\n";
	print "New versions and FAQ at http://awstats.sourceforge.net\n";
	exit 0;
}


my $retour;

# Check if AWSTATS is ok
if (! -s "$Awstats") {
	error("Can't find AWStats program ('$Awstats').\nUse -awstatsprog option to solve this");
	exit 1;
}

# Launch awstats update
if ($Update) {
	my $command="\"$Awstats\" -config=$Config -update";
	print "Launch update process : $command\n";
	$retour=`$command  2>&1`;
}



# Built the OutputSuffix value (used later to build page name)
$OutputSuffix=$Config;
if ($Date) {
	my ($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday) = localtime(time);
	if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
	++$nowmonth;
	$OutputSuffix.=".".sprintf("%04s%02s%02s",$nowyear,$nowmonth,$nowday);
}


my $cpt=0;
my $smallcommand="\"$Awstats\" -config=$Config -staticlinks".($OutputSuffix ne $Config?"=$OutputSuffix":"");
if ($Lang)          { $smallcommand.=" -lang=$Lang"; }
if ($MonthRequired) { $smallcommand.=" -month=$MonthRequired"; }
if ($YearRequired)  { $smallcommand.=" -year=$YearRequired"; }

# Launch main awstats output
my $command="$smallcommand -output";
print "Build main page: $command\n";
$retour=`$command  2>&1`;
$OutputFile=($OutputDir?$OutputDir:"")."awstats.$OutputSuffix.html";
open("OUTPUT",">$OutputFile") || error("Couldn't open log file \"$OutputFile\" for writing : $!");
print OUTPUT $retour;
close("OUTPUT");
$cpt++;

# Launch all other awstats output
for my $output (@OutputList) {
	my $command="$smallcommand -output=$output";
	print "Build $output page: $command\n";
	$retour=`$command  2>&1`;
	$OutputFile=($OutputDir?$OutputDir:"")."awstats.$OutputSuffix.$output.html";
	open("OUTPUT",">$OutputFile") || error("Couldn't open log file \"$OutputFile\" for writing : $!");
	print OUTPUT $retour;
	close("OUTPUT");
	$cpt++;
}

print "$cpt files built. Main page is 'awstats.$OutputSuffix.html'\n";

0;	# Do not remove this line

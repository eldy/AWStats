#!/usr/bin/perl
#-------------------------------------------------------
# This script creates one config file for each virtual web servers
# so AWStats is immedialty working.
# See COPYING.TXT file about AWStats GNU General Public License.
#-------------------------------------------------------
# $Revision$ - $Author$ - $Date$


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
use vars qw/ $REVISION $VERSION /;
$REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
$VERSION="1.0 (build $REVISION)";

use vars qw/
$DIR $PROG $Extension
/;

# Possible dirs for Apache conf files
@WEBCONF=('/usr/local/apache/conf/httpd.conf','/usr/local/apache2/conf/httpd.conf','/etc/httpd/httpd.conf');




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



#-------------------------------------------------------
# MAIN
#-------------------------------------------------------
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

my $QueryString=""; for (0..@ARGV-1) { $QueryString .= "$ARGV[$_] "; }
if ($QueryString =~ /debug=/i) { $Debug=$QueryString; $Debug =~ s/.*debug=//; $Debug =~ s/&.*//; $Debug =~ s/ .*//; }

my $helpfound=0;
for (0..@ARGV-1) {
	if ($ARGV[$_] =~ /^-*h/i)   { $helpfound=1; last; }
}

# Show usage help
if ($helpfound) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG is a tool to setup AWStats. It works with Apache only.\n";
	print "- It detects web server install path\n";
	print "- It detects global cgi-bin and icons directory\n";
	print "- It copy cgi and icons files in thoose directories\n";
	print "- It extract list of virtual servers and create one config file for each of\n";
	print "  them.\n";
	print "- It return commands and URL(s) for using Awstats for each config file.\n";
	print "\n";
	print "Usage:  $PROG.$Extension\n";
	print "\n";
	exit 0;
}

# Get current time
my $nowtime=time;
my ($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear) = localtime($nowtime);
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
my $nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
if (++$nowmonth < 10) { $nowmonth = "0$nowmonth"; }
if ($nowday < 10) { $nowday = "0$nowday"; }
if ($nowhour < 10) { $nowhour = "0$nowhour"; }
if ($nowmin < 10) { $nowmin = "0$nowmin"; }
if ($nowsec < 10) { $nowsec = "0$nowsec"; }



print "THIS SCRIPT IS NOT READY YET.\n";
print "See AWStats setup documentation instead (file docs/index.html).\n";
print "\n";
print "If you want to help and write this script, run ot with -h option\n";
print "to known what it should do.\n\n";


# Detect web server path
# ---------------------
my $ApachePath="";








if (! $ApachePath) {
	error("Your web server path could not be found.\nIf uou are not using Apache web server, you must setup AWStats manually.\nSee AWStats setup documentation (file docs/index.html)");
	exit 1;
}



# Open Apache config file
# -----------------------

# TODO



# Copy cgi-bin and icons into global cgi-bin and icons directory
# --------------------------------------------------------------

# TODO


# Search virtual servers
# --------------------------------------------------------------

# TODO


# Loop on each virtual servers and create one config file
# --------------------------------------------------------------

# TODO



# Loop on each virtual servers and show on screen the URL to use
# --------------------------------------------------------------

# TODO


0;	# Do not remove this line

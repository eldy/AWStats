#!/usr/bin/perl
#-Description-------------------------------------------
# This script creates one config file for each virtual web servers
# so AWStats is immedialty working.
# See COPYING.TXT file about AWStats GNU General Public License.
#-------------------------------------------------------
# $Revision$ - $Author$ - $Date$


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
my $REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
my $VERSION="1.0 (build $REVISION)";

# Default value of DIRCONFIG and AWSTATSSCRIPT
my $DIRCONFIG = "/etc/opt/awstats";
my $AWSTATSSCRIPT = "/opt/awstats/wwwroot/cgi-bin/awstats.pl";




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
my $QueryString=""; for (0..@ARGV-1) { $QueryString .= "$ARGV[$_] "; }
if ($QueryString =~ /debug=/i) { $Debug=$QueryString; $Debug =~ s/.*debug=//; $Debug =~ s/&.*//; $Debug =~ s/ .*//; }
if ($QueryString =~ /dnslookup/i) { $DNSLookup=1; }
if ($QueryString =~ /showsteps/i) { $ShowSteps=1; }

my $helpfound=0;
for (0..@ARGV-1) {
	if ($ARGV[$_] =~ /^-*h/i)     		  	 { $helpfound=1; last; }
}

# Show usage help
my $DIR; my $PROG; my $Extension;
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
if ($helpfound) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG creates all AWStats config files for each virtual servers\n";
	print "found in an Apache web server configuration.\n";
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



print "This script is not ready yet.\n";



# Search web server





# Search Apache config file





# Search virtual servers





# Loop on each virtual servers to create one config file







0;	# Do not remove this line

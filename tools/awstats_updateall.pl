#!/usr/bin/perl
#-Description-------------------------------------------
# Launch update process for all config files found in a particular directory.
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
# MAIN
#-------------------------------------------------------

# Change default value if options are used
my $helpfound=0;my $nowfound=0;
for (0..@ARGV-1) {
	if ($ARGV[$_] =~ /^-*h/i)     		  	 { $helpfound=1; last; }
	if ($ARGV[$_] =~ /^-*awstatsprog=(.*)/i) { $AWSTATSSCRIPT="$1"; next; }
	if ($ARGV[$_] =~ /^-*confdir=(.*)/i)     { $DIRCONFIG="$1"; next; }
	if ($ARGV[$_] =~ /^now/i)     		  	 { $nowfound=1; next; }
}

# Show usage help
my $DIR; my $PROG; my $Extension;
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
if (!$nowfound || $helpfound || ! @ARGV) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG launch update process for each config file found\n";
	print "in $DIRCONFIG directory (for fast cron/scheduler setup).\n";
	print "\n";
	print "Usage:  $PROG.$Extension now [options]\n";
	print "\n";
	print "Where options are:\n";
	print "  -awstatsprog=pathtoawstatspl\n";
	print "  -confdir=confdirtoscan\n";
	print "\n";
	exit 0;
}

# Scan directory $DIRCONFIG 
opendir(DIR, $DIRCONFIG) || die "Can't scan directory $DIRCONFIG";
my @files = grep { /^awstats\.(.*)conf$/ } sort readdir(DIR);
closedir(DIR);

# Run update process for each config file found
if (@files) {
	foreach (@files) {
		if ($_ =~ /^awstats\.(.*)conf$/) {
			my $domain = $1||"default"; $domain =~ s/\.$//;
			print "Running $AWSTATSSCRIPT to update config $domain\n";
			my $output = `"$AWSTATSSCRIPT" -config=$domain -update 2>&1`;
			print "$output\n";
		}
	}
} else {
	print "No AWStats config file found in $DIRCONFIG\n";	
}

0;	# Do not remove this line

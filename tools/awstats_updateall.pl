#!/usr/bin/perl
#------------------------------------------------------------------------------
# Launch update process for all config files found in a particular directory.
# See COPYING.TXT file about AWStats GNU General Public License.
#------------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


#------------------------------------------------------------------------------
# Defines
#------------------------------------------------------------------------------
my $REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
my $VERSION="1.0 (build $REVISION)";

# Default value of DIRCONFIG
my $DIRCONFIG = "/etc/awstats";

my $Awstats='awstats.pl';
my $AwstatsDir='';



#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function:		Write error message and exit
# Parameters:	$message
# Input:		None
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub error {
	print "Error: $_[0].\n";
    exit 1;
}


#------------------------------------------------------------------------------
# Function:     Write debug message and exit
# Parameters:   $string $level
# Input:        %HTMLOutput  $Debug=required level  $DEBUGFORCED=required level forced
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub debug {
	my $level = $_[1] || 1;
	if ($Debug >= $level) {
		my $debugstring = $_[0];
		if ($ENV{"GATEWAY_INTERFACE"}) { $debugstring =~ s/^ /&nbsp&nbsp /; $debugstring .= "<br>"; }
		print localtime(time)." - DEBUG $level - $debugstring\n";
	}
}


#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------

# Change default value if options are used
my $helpfound=0;my $nowfound=0;
for (0..@ARGV-1) {
	if ($ARGV[$_] =~ /^-*h/i)     		  	 { $helpfound=1; last; }
	if ($ARGV[$_] =~ /^-*awstatsprog=(.*)/i) { $Awstats="$1"; next; }
	if ($ARGV[$_] =~ /^-*configdir=(.*)/i)   { $DIRCONFIG="$1"; next; }
	if ($ARGV[$_] =~ /^now/i)     		  	 { $nowfound=1; next; }
}

# Show usage help
my $DIR; my $PROG; my $Extension;
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
if (!$nowfound || $helpfound || ! @ARGV) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "awstats_updateall launches update process for all AWStats config files (except\n";
	print "awstats.model.conf) found in a particular directory, so you can easily setup a\n";
	print "cron/scheduler job. The scanned directory is by default $DIRCONFIG.\n";
	print "\n";
	print "Usage:  $PROG.$Extension now [options]\n";
	print "\n";
	print "Where options are:\n";
	print "  -awstatsprog=pathtoawstatspl\n";
	print "  -configdir=directorytoscan\n";
	print "\n";
	exit 0;
}

# Scan directory $DIRCONFIG 
opendir(DIR, $DIRCONFIG) || error("Can't scan directory $DIRCONFIG");
my @files = grep { /^awstats\.(.*)conf$/ } sort readdir(DIR);
closedir(DIR);

# Run update process for each config file found
if (@files) {
	# Check if AWSTATS prog is found
	my $AwstatsFound=0;
	if (-s "$Awstats") { $AwstatsFound=1; }
	elsif (-s "/usr/local/awstats/wwwroot/cgi-bin/awstats.pl") {
		$Awstats="/usr/local/awstats/wwwroot/cgi-bin/awstats.pl";
		$AwstatsFound=1;
	}
	if (! $AwstatsFound) {
		error("Can't find AWStats program ('$Awstats').\nUse -awstatsprog option to solve this");
		exit 1;
	}
	$AwstatsDir=$Awstats; $AwstatsDir =~ s/[\\\/][^\\\/]*$//;
	debug("AwstatsDir=$AwstatsDir");

	foreach (@files) {
		if ($_ =~ /^awstats\.(.*)conf$/) {
			my $domain = $1||"default"; $domain =~ s/\.$//;
			if ($domain eq 'model') { next; }
			# Define command line
			my $command="\"$Awstats\" -update -config=$domain";
			$command.=" -configdir=\"$DIRCONFIG\"";
			# Run command line
			print "Running '$command' to update config $domain\n";
			my $output = `$command 2>&1`;
			print "$output\n";
		}
	}
} else {
	print "No AWStats config file found in $DIRCONFIG\n";	
}

0;	# Do not remove this line

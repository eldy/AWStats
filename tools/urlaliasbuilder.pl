#!/usr/bin/perl
#-------------------------------------------------------
# Small script to auto-generate URL Alias files for 5.2+ AWStats
# Requires two Perl modules below.
# From original title-grabber.pl file
# 		(Feedback/suggestions to: simonjw@users.sourceforge.net)
# Modified by eldy@users.sourceforge.net
# 
# Note: If you want to retrieve document titles over SSL you must have OpenSSL and
#       the Net::SSL(eay) Perl Module available.  This code will check that SSL is
#		supported before attempting to retrieve via it.
#-------------------------------------------------------
use LWP::UserAgent;

use strict;no strict "refs";


# variables, etc
my $REVISION = '20140126';
my $VERSION="1.0 (build $REVISION)";

############### EDIT HERE ###############

# you can set this manually if you will only grep one site
my $SITECONFIG = "";

# Where the default input is located.
my $awStatsDataDir = "/var/lib/awstats";

# Throttle HTTP requests - help avoid DoS-like results if on a quick network.
# Number is the number of seconds to pause between requests. Set to zero for
# no throttling.
my $throttleRequestsTime = 0;

# LWP settings
# UA string passed to server.  You should add this to SkipUserAgents in the
# awstats.conf file if you want to ignore hits from this code.
my $userAgent = "urlaliasbuilder/$VERSION";
# Put a sensible e-mail address here
my $spiderOwner = "spider\@mydomain.com";

# Timeout (in seconds) for each HTTP request (increase on slow connections)
my $getTimeOut = 2;
# Proxy server to use when doing http/s - leave blank if you don't have one
#my $proxyServer = "http://my.proxy.server:port/";
my $proxyServer = "";
# Hosts not to use a proxy for
my @hostsNoProxy = ("host1","host1.my.domain.name");
# Make sure we don't download multi-megabyte files! We need only head section
my $maxDocSizeBytes = 4096; # number is bytes

############### DON'T EDIT BELOW HERE ###############

# Don't edit these
my $FILEMARKER1 = "BEGIN_SIDER";
my $FILEMARKER2 = "END_SIDER";

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

my $fullMonth = sprintf("%02d",$mon+1);
my $fullYear = sprintf("%04d",$year+1900);


# ====== main ======

# Change default value if options are used
my $helpfound=0;
my $nohosts=0;
my $overwritedata=0;
my $hostname="";
my $useHTTPS=0;

# Data file to open
my $fileToOpen = $awStatsDataDir . "/awstats" . $fullMonth . $fullYear . ($SITECONFIG?".$SITECONFIG":"") . ".txt";
# URL Alias file to open
my $urlAliasFile = "urlalias" . ($SITECONFIG?".$SITECONFIG":"") . ".txt";

for (0..@ARGV-1) {
	if ($ARGV[$_] =~ /^-*urllistfile=([^\s&]+)/i) 	{ $fileToOpen="$1"; next; }
	if ($ARGV[$_] =~ /^-*urlaliasfile=([^\s&]+)/i) 	{ $urlAliasFile="$1"; next; }
	if ($ARGV[$_] =~ /^-*site=(.*)/i)      			{ $hostname="$1"; next; }
	if ($ARGV[$_] =~ /^-*h/i)     		  			{ $helpfound=1; next; }
	if ($ARGV[$_] =~ /^-*overwrite/i)     	 		{ $overwritedata=1; next; }
	if ($ARGV[$_] =~ /^-*secure/i)     	 			{ $useHTTPS=1; next; }	
}

# if no host information provided, we bomb out to usage
if(! $hostname && ! $SITECONFIG) { $nohosts=1; }

# if no hostname set (i.e. -site=) then we use the config value
if(! $hostname && $SITECONFIG) { $hostname=$SITECONFIG; }

# Show usage help
my $DIR; my $PROG; my $Extension;
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
if ($nohosts || $helpfound || ! @ARGV) {
	print "\n----- $PROG $VERSION -----\n";
	print ucfirst($PROG)." generates an 'urlalias' file from an input file.\n";
	print "The input file must contain a list of URLs (It can be an AWStats history file).\n";
	print "For each of thoose URLs, the script get the corresponding HTML page and catch the\n";
	print "header information (title), then it writes an output file that contains one line\n";
	print "for each URLs and several fields:\n";
	print "- The first field is the URL,\n";
	print "- The second is title caught from web page.\n";
	print "This resulting file can be used by AWStats urlalias plugin.\n";
	print "\n";
	print "Usage:  $PROG.$Extension  -site=www.myserver.com  [options]\n";
	print "\n";
	print "The site parameter contains the web server to get the page from.\n";
	print "Where options are:\n";
	print "  -urllistfile=Input urllist file\n";
	print "    If this file is an AWStats history file then urlaliasbuilder will use the\n";
	print "    SIDER section of this file as its input URL's list.\n";
	print "  -urlaliasfile=Output urlalias file to build\n";
	print "  -overwrite    Overwrite output file if exists\n";
	print "  -secure       Use https protocol\n";
	print "\n";
	print "Example: $PROG.$Extension -site=www.someotherhost.com\n";
	print "\n";
	print "This is default configuration used when no option are provided on command line:\n";
	print "Input urllist file: $fileToOpen (overwritten by -urllistfile option)\n";
	print "Output urlalias file: $urlAliasFile (overwritten by -urlaliasfile option)\n";
	print "\n";	
	print "This script was written from Simon Waight original works title-grabber.pl.\n";
	print "\n";
	exit 0;
}

my @archivedKeys=();
my $counter = 0;
my $pageTitle = "";

# only read the alias file if we want to do a comparison
# and append new items only (i.e. not overwrite)
if($overwritedata == 0) {
	open(FILE,$urlAliasFile);
	my @bits = ();
	while(<FILE>) {
		chomp $_; s/\r//;
		@bits=split(/\t/,$_);
		@archivedKeys[$counter]=@bits[0];
		$counter++;
		#print "key: " . @bits[0] . "\n";
	}
	close(FILE);
	@bits = ();
}

# open input file (might be an AWStats history data file)
print "Reading input file: $fileToOpen\n";
open(FILE,$fileToOpen) || die "Error: Can't open input urllist file $fileToOpen";
binmode FILE;

my @field=();
my @addToAliasFile=();
my $addToAliasFileCount=0;
my $isawstatshistoryfile=0;
while (<FILE>) {
	chomp $_; s/\r//;

	if ($_ =~ /^AWSTATS DATA FILE/) {
		print "This file looks like an AWStats history file. Searching URLs list...\n";
		$isawstatshistoryfile=1;
	}

	# Split line out into fields
	@field=split(/\s+/,$_);
	if (! $field[0]) { next; }

	# If we're at the start of the URL section of file
	if (! $isawstatshistoryfile || $field[0] eq $FILEMARKER1)  {

		$_=<FILE>;
		chomp $_; s/\r//;

		my @field=split(/\s+/,$_);
		my $count=0;
		my $matched = 0;
		while ($field[0] ne $FILEMARKER2) {
			if ($field[0]) {
				# compare awstats data entry against urlalias entry
				# only if we don't just want to write current items
				# to the file (i.e. overwrite)
				if($overwritedata == 0) {
					foreach my $key (@archivedKeys) {
						if($field[0] eq $key) {
							$matched = 1;
							last;
						}
					}
					# it's a new URL, so add to list of items to retrieve
					if($matched == 0) {
						@addToAliasFile[$addToAliasFileCount] = $field[0];
						$addToAliasFileCount++;
						#print "new: " . $field[0] . "\n"
					}
					$matched = 0;
				} else {
					# no comparison, so everything is 'new'
					@addToAliasFile[$addToAliasFileCount] = $field[0];
					$addToAliasFileCount++;
				}
			}
			$_=<FILE>;
			chomp $_; s/\r//;
			@field=split(/\s+/,$_);
		}
	}
}

close(FILE);

if($addToAliasFileCount == 0) {
	print "Found no new documents.\n\n" ;
	exit();
}

print "Found " . $addToAliasFileCount . " new documents with no alias.\n";

my $fileOutput = "";

print "Looking thoose pages on web site '$hostname' to get alias...\n";

# Create a user agent (browser) object
my $ua = new LWP::UserAgent;
# set user agent name
$ua->agent($userAgent);
# set user agents owners e-mail address
$ua->from($spiderOwner);
# set timeout for requests
$ua->timeout($getTimeOut);
if ($proxyServer) {
	# set proxy for access to external sites
	$ua->proxy(["http","https"],$proxyServer);
	# avoid proxy for these hosts
	$ua->no_proxy(@hostsNoProxy);
}
# set maximum size of document to retrieve (in bytes)
$ua->max_size($maxDocSizeBytes);
if(!($ua->is_protocol_supported('https')) && $useHTTPS) {
	print "SSL is not supported on this machine.\n\n";
	exit();
}

$fileOutput = "";

# Now lets build the contents to write (or append) to urlalias file
foreach my $newAlias (@addToAliasFile) {
	sleep $throttleRequestsTime;
	my $newAliasEntry = &Generate_Alias_List_Entry($newAlias);
	$fileOutput .= $newAliasEntry . "\n";
}

# write the data back to urlalias file
if (! $overwritedata) {
	# Append to file
	open(FILE,">>$urlAliasFile") || die "Error: Failed to open file for writing: $_\n\n";
	print FILE $fileOutput;
	close(FILE);
} else {
	# Overwrite the file
	open(FILE,">$urlAliasFile") || die "Error: Failed to open file for writing: $_\n\n";
	foreach my $newAlias (@addToAliasFile) {
		my $newAliasEntry = &Generate_Alias_List_Entry($newAlias);
		print FILE "$newAliasEntry\n";
	}
	close(FILE);
}
print "File $urlAliasFile created/updated.\n";

exit();

#--------------------------- End of Main -----------------------------


#
# Generate new lines for urlalias file by doing a http get using data
# supplied.
#
sub Generate_Alias_List_Entry {

	# take in the path & document
	my $urltoget = shift;

	my $urlPrefix = "http://";
	
	if($useHTTPS) {
		$urlPrefix = "https://";
	}

	my $AliasLine = "";
	$pageTitle = "";
	$AliasLine = $urltoget;
	$AliasLine .= "\t";

	# build a full HTTP request to pass to user agent
	my $fullurltoget = $urlPrefix . $hostname . $urltoget;

	# Create a HTTP request
	print "Getting page $fullurltoget\n";
		
	my $req = new HTTP::Request GET => $fullurltoget;

	# Pass request to the user agent and get a response back
	my $res = $ua->request($req);

	# Parse returned document for page title
	if ($res->is_success()) {
		$pageTitle = $res->title;
	} else {
		print "Failed to get page: ".$res->status_line."\n";
		$pageTitle = "Unknown Title";
	}
	if ($pageTitle eq "") {
		$pageTitle = "Unknown Title";
	}
	return $AliasLine . $pageTitle;
}

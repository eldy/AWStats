#!/usr/bin/perl
#-Description-------------------------------------------
# Small script to auto-generate URL Alias files for 5.2+ AWStats
# Requires two Perl modules below.
# Note: Doesn't currently support https.
# From original title-grabber.pl file (Feedback to: simonjw@users.sourceforge.net)
# Changed by eldy@users.sourceforge.net
#-------------------------------------------------------
use LWP::UserAgent;
use HTML::TokeParser;

use strict;no strict "refs";


# variables, etc
my $REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
my $VERSION="1.0 (build $REVISION)";

my $SITECONFIG = "";
my $FILEMARKER1 = "BEGIN_SIDER";
my $FILEMARKER2 = "END_SIDER";

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $fullMonth = sprintf("%02d",$mon+1);
my $fullYear = sprintf("%04d",$year+1900);

# Where everything we need to know is installed
my $awStatsDataDir = "/var/cache/awstats";

# Timeout (in seconds) for each HTTP request (increase on slow connections)
my $getTimeOut = 2;
# Proxy server to use when doing http/s - leave blank if you don't have one
#my $proxyServer = "http://my.proxy.server:port/";
my $proxyServer = "";
# Hosts not to use a proxy for
my @hostsNoProxy = ("host1","host1.my.domain.name");



# ====== main
my $DIR; my $PROG; my $Extension;
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

# LWP settings
# UA string passed to server.  You should add this to SkipUserAgents in the
# awstats.conf file if you want to ignore hits from this code.
my $userAgent = ucfirst($PROG)."/$VERSION";

# Change default value if options are used
my $helpfound=0;
my $nohosts=0;
my $overwritedata=0;
my $hostname="";

# Data file to open
my $fileToOpen = $awStatsDataDir . "/awstats" . $fullMonth . $fullYear . ($SITECONFIG?".$SITECONFIG":"") . ".txt";
# URL Alias file to open
my $urlAliasFile = "urlalias" . ($SITECONFIG?".$SITECONFIG":"") . ".txt";

for (0..@ARGV-1) {
	if ($ARGV[$_] =~ /^-*urllistfile=([^\s&]+)/i) 	{ $fileToOpen="$1"; next; }
	if ($ARGV[$_] =~ /^-*urlaliasfile=([^\s&]+)/i) 	{ $urlAliasFile="$1"; next; }
	if ($ARGV[$_] =~ /^-*server=(.*)/i)      		{ $hostname="$1"; next; }
	if ($ARGV[$_] =~ /^-*h/i)     		  			{ $helpfound=1; next; }
	if ($ARGV[$_] =~ /^-*overwrite/i)     	 		{ $overwritedata=1; next; }
}

# if no host information provided, we bomb out to usage
if(! $hostname && ! $SITECONFIG) { $nohosts=1; }

# if no hostname set (i.e. -server=) then we use the config value
if(! $hostname && $SITECONFIG) { $hostname=$SITECONFIG; }

# Show usage help
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
	print "Usage:  $PROG.$Extension -server=www.myserver.com [options]\n";
	print "\n";
	print "The server parameter contains the web server to get the page from.\n";
	print "Where options are:\n";
	print "  -urllistfile=Input urllist file\n";
	print "    If this file is an AWStats history file then urlaliasbuilder will use the\n";
	print "    SIDER section of this file as its input URL's list.\n";
	print "  -urlaliasfile=Output urlalias file to build\n";
	print "  -overwrite\n";
	print "\n";
	print "Example: $PROG.$Extension -server=www.someotherhost.com\n";
	print "\n";
	print "This is default configuration used if no option is used on command line:\n";
	print "Input urllist file: $fileToOpen (overwritten by -urllistfile option)\n";
	print "Output urlalias file: $urlAliasFile (overwritten by -urlaliasfile option)\n";
	print "\n";	
	print "This script was written from simonjw original works title-grabber.pl.\n";
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

# open current months AWStats data file
print "Open input file $fileToOpen\n";
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

print "Found " . $addToAliasFileCount . " new URLs with no alias.\n";

close(FILE);

my $fileOutput = "";

print "Looking thoose pages on server '$hostname' to get alias...\n";

# Create a user agent (browser) object
my $ua = new LWP::UserAgent;
# set user agent name
$ua->agent($userAgent);
# set timeout for requests
$ua->timeout($getTimeOut);
if ($proxyServer) {
	# set proxy for access to external sites
	$ua->proxy(["http","https"],$proxyServer);
	# avoid proxy for these hosts
	$ua->no_proxy(@hostsNoProxy);
}

# Write the data back to urlalias file
if (! $overwritedata) {
	# Append to file
	open(FILE,">>$urlAliasFile") || die "Error: Failed to open file for writing: $_";;
	foreach my $newAlias (@addToAliasFile) {
		my $newAliasEntry = &Generate_Alias_List_Entry($newAlias);
		print FILE "$newAliasEntry\n";
	}
	close(FILE);
} else {
	# Overwrite the file
	open(FILE,">$urlAliasFile") || die "Error: Failed to open file for writing: $_";;
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

	my $AliasLine = "";
	$pageTitle = "";
	$AliasLine = $urltoget;
	$AliasLine .= "\t";

	# build a full HTTP request to pass to user agent
	my $fullurltoget =	"http://" . $hostname . $urltoget;

	#print $fullurltoget . "\n";

	# Create a HTTP request
	print "Download page $fullurltoget\n";
	my $req = new HTTP::Request GET => $fullurltoget;

	# Pass request to the user agent and get a response back
	my $res = $ua->request($req);

	# Parse returned document for page title
	if ($res->is_success()) {
		my $htmldoc = $res->content;
		my $p = HTML::Parser->new(api_version => 3);
		$p->handler( start => \&title_handler, "tagname,self");
		$p->parse($htmldoc);
	} else {
		print "Failed to get page: ".$res->status_line."\n";
		$pageTitle = "Unknown Title";
	}
	if ($pageTitle eq "") {
		$pageTitle = "Unknown Title";
	}
	return $AliasLine . $pageTitle;
}

# Handler routine for HTML::Parser
sub title_handler {
	return if shift ne "title";
	my $self = shift;
	$self->handler(text => sub { $pageTitle = shift }, "dtext");
	$self->handler(end  => sub { shift->eof if shift eq "title"; },"tagname,self");
}

#!/usr/bin/perl
#-------------------------------------------------------
# This script configures AWStats so that it works immediately.
# - Get Apache config file from registry (ask if not found)
# - Change common log to combined (ask to confirm)
# - Add AWStats directives
# - Restart web server
# - Create AWStats config file
# See COPYING.TXT file about AWStats GNU General Public License.
#-------------------------------------------------------
# $Revision$ - $Author$ - $Date$
use strict;

#-------------------------------------------------------
# IF YOU ARE A PACKAGE BUILDER, CHANGE THIS TO MATCH YOUR PATH
# SO THAT THE CONFIGURE WILL WORK ON YOUR DISTRIB !!!
# Following path are the one 
#-------------------------------------------------------
use vars qw/
$AWSTATS_ICON_PATH
$AWSTATS_CSS_PATH
$AWSTATS_CLASSES_PATH
$AWSTATS_CGI_PATH
$AWSTATS_TOOLS_PATH
$AWSTATS_MODEL_CONFIG
$AWSTATS_DIRDATA_PATH
/;
$AWSTATS_ICON_PATH='/usr/local/awstats/wwwroot/icon';
$AWSTATS_CSS_PATH='/usr/local/awstats/wwwroot/css';
$AWSTATS_CLASSES_PATH='/usr/local/awstats/wwwroot/classes';
$AWSTATS_CGI_PATH='/usr/local/awstats/wwwroot/cgi-bin';
$AWSTATS_TOOLS_PATH='/usr/local/awstats/wwwroot/tools';			# Used for linux only
$AWSTATS_MODEL_CONFIG='/etc/awstats/awstats.model.conf';		# Used for linux only
$AWSTATS_DIRDATA_PATH='/var/lib/awstats';						# Used for linux only



#-------------------------------------------------------
# Defines
#-------------------------------------------------------
# For windows registry management
my $reg;
eval('use Win32::TieRegistry ( Delimiter=>"/", TiedRef=>\$reg )');

use vars qw/ $REVISION $VERSION /;
$REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
$VERSION="1.0 (build $REVISION)";

use vars qw/
$DIR $PROG $Extension $Debug
/;

use vars qw/
@WEBCONF
/;
# Possible dirs for Apache conf files
@WEBCONF=(
'C:/Program Files/Apache Group/Apache2/conf/httpd.conf',
'C:/Program Files/Apache Group/Apache/conf/httpd.conf',
'/etc/httpd/httpd.conf',
'/usr/local/apache/conf/httpd.conf',
'/usr/local/apache2/conf/httpd.conf'
);

use vars qw/
$WebServerChanged $UseAlias $Step
%LogFormat %ConfToChange
/;
$WebServerChanged=0;
$UseAlias=0;
%LogFormat=();
%ConfToChange=();
$Step=0;



#-------------------------------------------------------
# Functions
#-------------------------------------------------------

#-------------------------------------------------------
# error
#-------------------------------------------------------
sub error {
	print "Error: $_[0].\n";
    exit 1;
}

#-------------------------------------------------------
# debug
#-------------------------------------------------------
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
# update_httpd_config
# Replace common to combined in Apache config file
#-------------------------------------------------------
sub update_httpd_config
{
	my $file=shift;
	if (! $file) { error("Call to update_httpd_config with wrong parameter"); }
	
	open(FILE, $file) || error("Failed to open $file for update");
	open(FILETMP, ">$file.tmp") || error("Failed to open $file.tmp for writing");
	
	# $%conf contains param and values
	my %confchanged=();
	my $conflinenb = 0;
	
	# First, change values that are already present in old config file
	while(<FILE>) {
		my $savline=$_;
	
		chomp $_; s/\r//;
		$conflinenb++;
	
		# Remove comments not at beginning of line
		$_ =~ s/\s#.*$//;
	
		# Change line
		if ($_ =~ /^CustomLog\s(.*)\scommon$/i)	{ $savline="CustomLog $1 combined"; }
		
		# Write line
		print FILETMP "$savline";	
	}
	
	close(FILE);
	close(FILETMP);
	
	# Move file to file.sav
	if (rename("$file","$file.old")==0) {
		error("Failed to make backup of current config file to $file.old");
	}
	
	# Move tmp file into config file
	if (rename("$file.tmp","$file")==0) {
		error("Failed to move tmp config file $file.tmp to $file");
	}
	
	return 0;
}

#-------------------------------------------------------
# update_awstats_config
# Update an awstats model [to another one]
#-------------------------------------------------------
sub update_awstats_config
{
my $file=shift;
my $fileto=shift||"$file.tmp";

if (! $file) { error("Call to update_awstats_config with wrong parameter"); }
if ($file =~ /Developpements[\\\/]awstats/i) {
	print "  This is my dev area. Don't touch.\n";
	return;
}	# To avoid script working in my dev area

open(FILE, $file) || error("Failed to open $file for update");
open(FILETMP, ">$fileto") || error("Failed to open $fileto for writing");

# $%conf contains param and values
my %confchanged=();
my $conflinenb = 0;

# First, change values that are already present in old config file
while(<FILE>) {
	my $savline=$_;

	chomp $_; s/\r//;
	$conflinenb++;

	# Remove comments not at beginning of line
	$_ =~ s/\s#.*$//;

	# Extract param and value
	my ($param,$value)=split(/=/,$_,2);
	$param =~ s/^\s+//; $param =~ s/\s+$//;
	$value =~ s/#.*$//; 
	$value =~ s/^[\s\'\"]+//; $value =~ s/[\s\'\"]+$//;

	if ($param) {
		# cleanparam is param without begining #
		my $cleanparam=$param; my $wascleaned=0;
		if ($cleanparam =~ s/^#//) { $wascleaned=1; }
		if (defined($ConfToChange{"$cleanparam"}) && $ConfToChange{"$cleanparam"}) { $savline = ($wascleaned?"#":"")."$cleanparam=\"".$ConfToChange{"$cleanparam"}."\"\n"; }
	}
	# Write line
	print FILETMP "$savline";	
}

close(FILE);
close(FILETMP);

if ($fileto eq "$file.tmp") {
	# Move file to file.sav
	if (rename("$file","$file.old")==0) {
		error("Failed to make backup of current config file to $file.old");
	}
	
	# Move tmp file into config file
	if (rename("$fileto","$file")==0) {
		error("Failed to move tmp config file $fileto to $file");
	}
	# Remove .old file
	unlink "$file.old";
}
else {
	print " Config file $fileto created.\n";
}
return 0;
}



#-------------------------------------------------------
# MAIN
#-------------------------------------------------------
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

my $QueryString=""; for (0..@ARGV-1) { $QueryString .= "$ARGV[$_] "; }
if ($QueryString =~ /debug=/i) { $Debug=$QueryString; $Debug =~ s/.*debug=//; $Debug =~ s/&.*//; $Debug =~ s/ .*//; }

my $helpfound=0;
my $OS='';
my $CR='';
my $AWSTATS_PATH='';	# Used for windows only
for (0..@ARGV-1) {
	if ($ARGV[$_] =~ /^-*h/i)   					{ $helpfound=1; last; }
	if ($ARGV[$_] =~ /^-*awstatspath=([^\s\"]+)/i)  { $AWSTATS_PATH==$1; last; }
}
if (! $AWSTATS_PATH) {
	$AWSTATS_PATH="$DIR";
	$AWSTATS_PATH=~s/tools[\\\/]?$//;
	$AWSTATS_PATH=~s/[\\\/]$//;
}

# Show usage help
if ($helpfound) {
	print "----- AWStats $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG is a tool to setup AWStats. It works with Apache only.\n";
	print " - Get Apache config file from registry (ask if not found)\n";
	print " - Change common log to combined (ask to confirm)\n";
	print " - Add AWStats directives\n";
	print " - Restart web server\n";
	print " - Create AWStats config file\n";
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

print "\n";
print "----- AWStats $PROG $VERSION (c) Laurent Destailleur -----\n";
print "This tool will help you to configure AWStats to analyze statistics for\n";
print "one web server. If you need to analyze load balanced servers, downloaded\n";
print "log files without web server, to analyze mail or ftp log files, or need\n";
print "to manage rotated logs, you will have to complete the config file manually\n";
print "according to your needs.\n";
print "Read the AWStats documentation (docs/index.html).\n";
print "\n";

# Detect web server path
# ----------------------
if (-d "/etc" && -d "/home") { $OS='linux'; $CR=''; }
else { $OS='windows'; $CR="\r"; }
#print "Running OS detected: $OS (Perl $^[)\n";
print "\n-----> Running OS detected: $OS\n";

# Detect web server path
# ----------------------
print "\n-----> Check for web server install\n";
my %ApachePath=();		# All Apache path found
my %ApacheConfPath=();	# All Apache config found
my $tips;
if ($OS eq 'linux') {
	my $found=0;
	foreach my $conf (@WEBCONF) {
		if (-s "$conf") {
			print "  Found Web server Apache config file '$conf'\n";
			$ApacheConfPath{"$conf"}=++$found;
		}
	}
}
if ($OS eq 'windows') {
	$reg->Delimiter("/");
	if ($tips=$reg->{"LMachine/Software/Apache Group/Apache/"}) {
		# If Apache registry call successfull
		my $found=0;
		foreach( sort keys %$tips  ) {
			my $path=$reg->{"LMachine/Software/Apache Group/Apache/$_/ServerRoot"};
			$path=~s/[\\\/]$//;
			if (-d "$path" && -s "$path/conf/httpd.conf") {
				print "  Found a Web server Apache install in '$path'\n";
				$ApachePath{"$path"}=++$found;
				$ApacheConfPath{"$path/conf/httpd.conf"}=++$found;
			}
		}
	}
}
if (! scalar keys %ApacheConfPath) {
	# Ask web server path
	print "$PROG did not find your web server path.\n";
	
	print "\nPlease, enter full path directory of you web server.\n";
	print "Example: /usr/local/apache\n";
	print "Example: d:\\Program files\\apache group\\apache\n";
	my $bidon='';
	while (! -d "$bidon") {
		print "Web server path (CTRL+C to cancel): ";
		$bidon=<STDIN>; chomp $bidon;
		if (! -d "$bidon") { print " The directory '$bidon' does not exists.\n"; }
	}
	$ApachePath{"$bidon"}=1;

	print "\nNow, enter full config file path of you web server.\n";
	print "Example: /etc/httpd/apache.conf\n";
	print "Example: d:\\Program files\\apache group\\apache\\conf\\httpd.conf\n";
	$bidon='';
	while (! -f "$bidon") {
		print "Config file path (CTRL+C to cancel): ";
		$bidon=<STDIN>; chomp $bidon;
		if (! -f "$bidon") { print " This file does not exists.\n"; }
	}
	$ApacheConfPath{"$bidon"}=1;
}

if (! scalar keys %ApacheConfPath) {
	error("Your web server config file(s) could not be found.\nIf you are not using Apache web server, you must setup AWStats manually.\nSee AWStats setup documentation (file docs/index.html)");
	exit 1;
}

# Open Apache config file
# -----------------------
foreach my $key (keys %ApacheConfPath) {
	print "\n-----> Check and complete web server config file '$key'\n";
	# Read config file to search for awstats directives
	my $commonchangedtocombined=0;
	READ:
	$LogFormat{$key}=4;
	open(CONF,"<$key") || error("Failed to open config file '$key' for reading");
	binmode CONF;
	my $awstatsjsfound=0;
	my $awstatsclassesfound=0;
	my $awstatscssfound=0;
	my $awstatsiconsfound=0;
	my $awstatscgifound=0;
	while(<CONF>) {
		if ($_ =~ /^CustomLog\s(.*)\scommon$/i)	{
			print "Warning: You Apache config file contains directives to write 'common' log files\n";
			print "This means that some features can't work (os, browsers and keywords detection).\n";
			print "Do you want me to setup Apache to write 'combined' log files [y/N] ?\n";
			my $bidon='';
			while ($bidon !~ /^[yN]/i) { $bidon=<STDIN>; }
			if ($bidon =~ /^y/i) {
				close CONF;				
				update_httpd_config("$key");
				$WebServerChanged=1;
				$commonchangedtocombined=1;
				goto READ;
			}
		}
		if ($_ =~ /^CustomLog\s(.*)\scombined$/i)	{ $LogFormat{$key}=1; }
		if ($_ =~ /Alias \/awstatsclasses/) 	{ $awstatsclassesfound=1; }
		if ($_ =~ /Alias \/awstatscss/) 		{ $awstatscssfound=1; }
		if ($_ =~ /Alias \/awstatsicons/) 		{ $awstatsiconsfound=1; }
		if ($_ =~ /ScriptAlias \/awstats\//)	{ $awstatscgifound=1; }
	}	
	close CONF;

	if ($awstatsclassesfound && $awstatscssfound && $awstatsiconsfound && $awstatscgifound) {
		$UseAlias=1;
		if ($commonchangedtocombined) { print "  Common log files changed to combined.\n"; }
		print "  AWStats directives already present.\n";
		next;
	}

	# Add awstats directives
	open(CONF,">>$key") || error("Failed to open config file '$key' for adding AWStats directives");
		binmode CONF;
		print CONF "$CR\n";
		print CONF "#$CR\n";
		print CONF "# Directives to allow use of AWStats as a CGI$CR\n";
		print CONF "#$CR\n";
		if (! $awstatsclassesfound) {
			print "  Add 'Alias \/awstatsclasses \"$AWSTATS_CLASSES_PATH\/\"' to config file\n";
			print CONF "Alias \/awstatsclasses \"$AWSTATS_CLASSES_PATH\/\"$CR\n";
		}
		if (! $awstatscssfound) {
			print "  Add 'Alias \/awstatscss \"$AWSTATS_CSS_PATH\/\"' to config file\n";
			print CONF "Alias \/awstatscss \"$AWSTATS_CSS_PATH\/\"$CR\n";
		}
		if (! $awstatsiconsfound) {
			print "  Add 'Alias \/awstatsicons \"$AWSTATS_ICON_PATH\/\"' to config file\n";
			print CONF "Alias \/awstatsicons \"$AWSTATS_ICON_PATH\/\"$CR\n";
		}
		if (! $awstatscgifound) {
			print "  Add 'ScriptAlias \/awstats\/ \"$AWSTATS_CGI_PATH\/\"' to config file\n";
			print CONF "ScriptAlias \/awstats\/ \"$AWSTATS_CGI_PATH\/\"$CR\n";
		}
	close CONF;
	$UseAlias=1;
	$WebServerChanged=1;
	print "  AWStats directives added to Apache config file.\n";
}

# Define model config file path
# -----------------------------
my $modelfile='';
if ($OS eq 'linux') 	{ $modelfile="$AWSTATS_MODEL_CONFIG"; }
if ($OS eq 'windows') 	{ $modelfile="$AWSTATS_PATH\\wwwroot\\cgi-bin\\awstats.model.conf"; }

# Update model config file
# ------------------------
print "\n-----> Update model config file\n";
%ConfToChange=();
if ($OS eq 'linux') { $ConfToChange{'DirData'}="$AWSTATS_DIRDATA_PATH"; }
if ($OS eq 'windows') { $ConfToChange{'DirData'}='.'; }
if ($UseAlias) {
	$ConfToChange{'DirCgi'}='/awstats';
	$ConfToChange{'DirIcons'}='/awstatsicons';
}
update_awstats_config("$modelfile");

# Ask if we need to create a config file
#---------------------------------------
my $site='';
print "\n-----> Need to create a new config file ?\n";
print "Do you want me to build a new AWStats config/profile\n";
print "file (required if first install) [y/N] ? ";
my $bidon='';
while ($bidon !~ /^[yN]/i) { $bidon=<STDIN>; }
if ($bidon =~ /^y/i) {
		
	# Ask value for web site name
	#----------------------------
	
	print "\n-----> Define config file name to create\n";
	print "What is the name of your web site or profile analysis ?\n";
	print "Example: www.mysite.com\n";
	print "Example: demo\n";
	my $bidon='';
	while (! $bidon) {
		print "Your web site, virtual server or profile name: ";
		$bidon=<STDIN>; chomp $bidon;
	
	}
	$site=$bidon;

	# Define config file path
	# -----------------------
	my $configfile='';
	if ($OS eq 'linux') 	{ $configfile="/etc/awstats/awstats.$site.conf"; }
	if ($OS eq 'windows') 	{ $configfile="$AWSTATS_PATH\\wwwroot\\cgi-bin\\awstats.$site.conf"; }
	
	# Create awstats.conf file
	# ------------------------
	print "\n-----> Create config file '$configfile'\n";
	if (-s $configfile) { print "  Config file already exists. No overwrite possible on existing config files.\n"; }
	else {
		%ConfToChange=();
		if ($OS eq 'linux') { $ConfToChange{'DirData'}="$AWSTATS_DIRDATA_PATH"; }
		if ($OS eq 'windows') { $ConfToChange{'DirData'}='.'; }
		if ($UseAlias) {
			$ConfToChange{'DirCgi'}='/awstats';
			$ConfToChange{'DirIcons'}='/awstatsicons';
		}
		$ConfToChange{'SiteDomain'}="$site";
		my $sitewithoutwww=lc($site); $sitewithoutwww =~ s/^www\.//i;
		$ConfToChange{'HostAliases'}="$sitewithoutwww www.$sitewithoutwww 127.0.0.1 localhost";
		update_awstats_config("$modelfile","$configfile");
	}

}


# Restart Apache if change were made
# ----------------------------------
if ($WebServerChanged) {
	if ($OS eq 'linux') 	{
		print "\n-----> Restart Apache with '/usr/bin/service httpd restart'\n";
	 	my $ret=`/usr/bin/service httpd restart`;
	}
	if ($OS eq 'windows')	{
		foreach my $key (keys %ApachePath) {
			if (-f "$key/bin/Apache.exe") {
				print "\n-----> Restart Apache with '\"$key/bin/Apache.exe\" -k restart'\n";
			 	my $ret=`"$key/bin/Apache.exe" -k restart`;
			}
		}
	}
}


# TODO
# Scan logorate for a log file
# If apache log has a logrotate log found, we create a config and add line in prerotate
# prerotate
#   ...
# endscript
# If not found


# Schedule awstats update process
# -------------------------------
print "\n-----> Add update process inside a scheduler\n";
if ($OS eq 'windows') {
	print "Sorry, for windows users, if you want to have statisitics to be\n";
	print "updated on a regular basis, you have to add the update process\n";
	print "in a scheduler task manually (See AWStats docs/index.html).\n";
	print "Press ENTER to continue... ";
	$bidon=<STDIN>;
}
if ($OS eq 'linux') {
	print "Sorry, programming update is not supported yet.\n";
	print "You can do it manually by adding the following line to your crontab\n";
	print "$AWSTATS_CGI_PATH/awstats -update -config=".($site?$site:"myvirtualserver")."\n";
	print "Or if you have several config files and prefer having only one command:\n";
	print "$AWSTATS_TOOLS_PATH/awstats_updateall.pl now\n";
	print "Press ENTER to continue... ";
	$bidon=<STDIN>;
}

print "\n\n";

if ($site) {
	print "A SIMPLE config file for '$site' has been created. You should have a look\n";
	print "inside to check and change manually main parameters.\n";
	print "You can then update your statistics for '$site' with command:\n";
	print "> awstats.pl -update -config=$site\n";
	print "You can also read your statistics for '$site' with URL:\n";
	print "> http://localhost/awstats/awstats.pl?config=$site\n";
	print "\n";
}
print "Press ENTER to finish...\n";
$bidon=<STDIN>;


0;	# Do not remove this line

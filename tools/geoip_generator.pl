#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Generates override files for the GEOIP databases for a given IP range
# This tool is part of AWStats log analyzer but can be use
# alone for any other log analyzer.
# See COPYING.TXT file about AWStats GNU General Public License.
#-----------------------------------------------------------------------------

use strict; no strict "refs";
use Switch;

#------------------------------------------------------------------------------
# Defines
#------------------------------------------------------------------------------
my $REVISION = '20140126';
my $VERSION="0.5 (build $REVISION)";

use vars qw/
$DirData
/;

# Variables
my %temp = {};
my $SiteConfig = "";
my $Output = "";
my $IPStart = "";
my $IPEnd = "";
my $DBType = "";
my $OutputDir = "";
my $Debug = 0;
my $Overwrite = 0;
my $Fields = "";
my $DIR="";
my $PROG;
my $FileConfig;
my $DirData;

my @Values = ();

# each array entry consists of the commandline name and the pluginname
my %Types = (
	lc("GeoIP") => "geoip",
	lc("GeoIPCity") => "geoip_city_maxmind",
	lc("GeoIPCityLite") => "geoip_city_maxmind",
	lc("GeoIPRegion") => "geoip_region_maxmind",
	lc("GeoIPOrg") => "geoip_org_maxmind",
	lc("GeoIPASN") =>"geoip_asn_maxmind"
	);

#-----------------------------------------------------------------------------
# Functions
#-----------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function:		Write an error message and exit
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
# Function:		Write a debug message
# Parameters:	$message
# Input:		$Debug
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub debug {
	my $level = $_[1] || 1;
	if ($Debug >= $level) { 
		my $debugstring = $_[0];
		print "DEBUG $level - ".localtime(time())." : $debugstring\n";
	}
}

#------------------------------------------------------------------------------
# Function:		Write a warning message
# Parameters:	$message
# Input:		$Debug
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub warning {
	my $messagestring=shift;
	if ($Debug) { debug("$messagestring",1); }
   	print "$messagestring\n";
}

#------------------------------------------------------------------------------
# Function:     CL - returns just the root name of the config file. I.e. if the 
# 				site config name is "awstats.conf" this will return "awstats"
# Parameters:	-
# Input:        $SiteConfig
# Output:		String with the root config name
# Return:		-
#------------------------------------------------------------------------------
sub Get_Config_Name{
	my $temp = shift;
	my $idx = -1;
	# check for slash
	$idx = rindex($temp, "/");
	if ($idx > -1){ $temp = substr($temp, $idx+1);}
	else{ 
		$idx = rindex($temp, "\\");
		if ($idx > -1){ $temp = substr($temp, $idx+1);}
	}
	# get the dot
	$idx = rindex($temp, ".");
	if ($idx > -1){ $temp = substr($temp, 0, $idx);}
	return $temp;
}

#------------------------------------------------------------------------------
# Function:     Read config file
# Parameters:	None or configdir to scan
# Input:        $DIR $PROG $SiteConfig
# Output:		Global variables
# Return:		-
#------------------------------------------------------------------------------
sub Read_Config {
	# Check config file in common possible directories :
	# Windows :                   				"$DIR" (same dir than awstats.pl)
	# Standard, Mandrake and Debian package :	"/etc/awstats"
	# Other possible directories :				"/usr/local/etc/awstats", "/etc"
	# FHS standard, Suse package : 				"/etc/opt/awstats"
	my $configdir=shift;
	my @PossibleConfigDir=();
	my $FileSuffix;

	# if an output was specified, then skip this
	if (!($Output eq '')){return;}
	if ($configdir) { @PossibleConfigDir=("$configdir"); }
	else { @PossibleConfigDir=("$DIR","/etc/awstats","/usr/local/etc/awstats","/etc","/etc/opt/awstats"); }

	# Open config file
	$FileConfig=$FileSuffix='';
	foreach my $dir (@PossibleConfigDir) {
		my $searchdir=$dir;
		if ($searchdir && $searchdir !~ /[\\\/]$/) { $searchdir .= "/"; }
		if (open(CONFIG,"${searchdir}awstats.$SiteConfig.conf")) { 
			$FileConfig="${searchdir}awstats.$SiteConfig.conf"; 
			$FileSuffix=".$SiteConfig"; 
			last; 
		}
		if (open(CONFIG,"${searchdir}awstats.conf")) { 
			$FileConfig="${searchdir}awstats.conf"; 
			$FileSuffix='';
			last; 
		}
		if (open(CONFIG,"$SiteConfig")) { 
			$FileConfig="$SiteConfig"; 
			$FileSuffix='';
			last; 
		}
	}
	if (! $FileConfig) { error("Couldn't open config file \"awstats.$SiteConfig.conf\" nor \"awstats.conf\" nor \"$SiteConfig.conf\" after searching in path \"".join(',',@PossibleConfigDir)."\": $!"); }

	# Analyze config file content and close it
	&Parse_Config( *CONFIG , 1 , $FileConfig);
	close CONFIG;
}

#------------------------------------------------------------------------------
# Function:     Parse content of a config file
# Parameters:	opened file handle, depth level, file name
# Input:        -
# Output:		Global variables
# Return:		-
#------------------------------------------------------------------------------
sub Parse_Config {
    my ( $confighandle ) = $_[0];
	my $level = $_[1];
	my $configFile = $_[2];
	my $versionnum=0;
	my $conflinenb=0;
	
	if ($level > 10) { error("$PROG can't read down more than 10 level of includes. Check that no 'included' config files include their parent config file (this cause infinite loop)."); }

   	while (<$confighandle>) {
		chomp $_; s/\r//;
		$conflinenb++;

		# Extract version from first line
		if (! $versionnum && $_ =~ /^# AWSTATS CONFIGURE FILE (\d+).(\d+)/i) {
			$versionnum=($1*1000)+$2;
			#if ($Debug) { debug(" Configure file version is $versionnum",1); }
			next;
		}

		if ($_ =~ /^\s*$/) { next; }

		# Check includes
		if ($_ =~ /^Include "([^\"]+)"/ || $_ =~ /^#include "([^\"]+)"/) {	# #include kept for backward compatibility
		    my $includeFile = $1;
			if ($Debug) { debug("Found an include : $includeFile",2); }
		    if ( $includeFile !~ /^[\\\/]/ ) {
			    # Correct relative include files
				if ($FileConfig =~ /^(.*[\\\/])[^\\\/]*$/) { $includeFile = "$1$includeFile"; }
			}
			if ($level > 1) {
				warning("Warning: Perl versions before 5.6 cannot handle nested includes");
				next;
			}
		    if ( open( CONFIG_INCLUDE, $includeFile ) ) {
				&Parse_Config( *CONFIG_INCLUDE , $level+1, $includeFile);
				close( CONFIG_INCLUDE );
		    }
		    else {
				error("Could not open include file: $includeFile" );
		    }
			next;
		}

		# Remove comments
		if ($_ =~ /^\s*#/) { next; }
		$_ =~ s/\s#.*$//;

		# Extract param and value
		my ($param,$value)=split(/=/,$_,2);
		$param =~ s/^\s+//; $param =~ s/\s+$//;
	
		if ($param =~ /^DirData/){
			$DirData = $value;
			#$DirData =~ s/"//g;
		}

		# If not a param=value, try with next line
		if (! $param) { warning("Warning: Syntax error line $conflinenb in file '$configFile'. Config line is ignored."); next; }
		if (! defined $value) { warning("Warning: Syntax error line $conflinenb in file '$configFile'. Config line is ignored."); next; }

		if ($value) {
			$value =~ s/^\s+//; $value =~ s/\s+$//;
			$value =~ s/^\"//; $value =~ s/\";?$//;
			# Replace __MONENV__ with value of environnement variable MONENV
			# Must be able to replace __VAR_1____VAR_2__
			while ($value =~ /__([^\s_]+(?:_[^\s_]+)*)__/) { my $var=$1; $value =~ s/__${var}__/$ENV{$var}/g; }
		}

		# Extra parameters
# 		if ($param =~ /^ExtraSectionName(\d+)/)			{ $ExtraName[$1]=$value; next; }
#
#		# Plugins
#		if ( $param =~ /^LoadPlugin/ ) { push @PluginsToLoad, $value; next; }

		# If parameters was not found previously, defined variable with name of param to value
		$$param=$value;
	}

	if ($Debug) { debug("Config file read was \"$configFile\" (level $level)"); }
}

#------------------------------------------------------------------------------
# Function:     Attempts to load an existing override file
# Parameters:   $SiteConfig $DirData
# Input:        None
# Output:       None
# Return:       None
#------------------------------------------------------------------------------
sub Load_File{
	my $conf = Get_Config_Name($SiteConfig);
	my $file = $DirData;
	$file =~ s/"//g;
	if (!(rindex($file, "/") >= length($file)-1)){$file .= "/";}
	$file .= $Types{lc($DBType)}.".$conf.txt";
	if (!($Output eq "")){$file = $Output;}
	# see if file exists
	if (!(-s $file)){debug("$file does not exist"); return;}
	
	# try loading
	debug("Attempting to load data from $file");
	if (!open(DATA, $file)){error("Unable to open the data file: $file");}
	while (<DATA>) {
		chomp $_; s/\r//;
		# skip comments 
		if ($_ =~ m/^#/){next;}
		my $idx = index($_, ",");
		if ($idx < 0) { debug("Invalid line: $_"); next; }
		my $ip = substr($_, 0, $idx);
		my $vals = substr($_, $idx);
		$temp{$ip} = $vals;
	}
	close(DATA);
	debug("Loaded ".scalar(%temp)." entries from the file");
}

#------------------------------------------------------------------------------
# Function:     Dumps the temp hash to the file
# Parameters:   $SiteConfig $DirData
# Input:        None
# Output:       None
# Return:       None
#------------------------------------------------------------------------------
sub Write_File{
	my $conf = Get_Config_Name($SiteConfig);
	my $file = $DirData;
	$file =~ s/"//g;
	if (!(rindex($file, "/") >= length($file)-1)){$file .= "/";}
	$file .= $Types{lc($DBType)}.".$conf.txt";
	if (!($Output eq '')){$file = $Output;}
	
	# try loading
	debug("Attempting to write data to $file");
	if (!open(DATA, ">$file")){error("Unable to open the data file: $file");}
	my $counter = 0;
	
	# sort to make it easier to find ips
	foreach my $key (sort keys %temp){
		if ($temp{$key}){
			print DATA "$key$temp{$key}\n";
			$counter++;
		}
	}
	close(DATA);
	debug("Wrote $counter entries to the data file");
}

#------------------------------------------------------------------------------
# Function:     Converts an IPv4 address to a decimal value
# Parameters:   IP address in dotted notation
# Input:        None
# Output:       None
# Return:       Integer
#------------------------------------------------------------------------------
sub addr_to_num { unpack( N => pack( C4 => split( /\./, $_[0] ) ) ) }

#------------------------------------------------------------------------------
# Function:     Converts an IPv4 address from decimal to it's dotted form
# Parameters:   IP address as an integer
# Input:        None
# Output:       None
# Return:       Dotted IP address
#------------------------------------------------------------------------------
sub num_to_addr { join q{.}, unpack( C4 => pack( N => $_[0] ) ) }

#-----------------------------------------------------------------------------
# MAIN
#-----------------------------------------------------------------------------
($DIR=$0) =~ s/([^\/\\]*)$//; 
($PROG=$1) =~ s/\.([^\.]*)$//;

my $QueryString=''; for (0..@ARGV-1) { $QueryString .= "$ARGV[$_]&"; }

if ($QueryString =~ /(^|-|&)debug=(\d+)/i)			{ $Debug=$2; }
if ($QueryString =~ /(^|-|&)config=([^&]+)/i)		{ $SiteConfig="$2"; }
if ($QueryString =~ /(^|-|&)output=([^&]+)/i)		{ $Output="$2"; }
if ($QueryString =~ /(^|-|&)type=([^&]+)/i)			{ $DBType="$2"; }
if ($QueryString =~ /(^|-|&)start=([^&]+)/i)		{ $IPStart="$2"; }
if ($QueryString =~ /(^|-|&)end=([^&]+)/i)			{ $IPEnd="$2"; }
if ($QueryString =~ /(^|-|&)overwrite/i) 			{ $Overwrite=1; }

# Values
if ($QueryString =~ /(^|-|&)cc=([^&]+)/i)		{ $Values[1]="$2"; }
if ($QueryString =~ /(^|-|&)rc=([^&]+)/i)		{ $Values[2]="$2"; }
if ($QueryString =~ /(^|-|&)cn=([^&]+)/i)		{ $Values[3]="$2"; }
if ($QueryString =~ /(^|-|&)pc=([^&]+)/i)		{ $Values[4]="$2"; }
if ($QueryString =~ /(^|-|&)la=([^&]+)/i)		{ $Values[5]="$2"; }
if ($QueryString =~ /(^|-|&)lo=([^&]+)/i)		{ $Values[6]="$2"; }
if ($QueryString =~ /(^|-|&)mc=([^&]+)/i)		{ $Values[7]="$2"; }
if ($QueryString =~ /(^|-|&)ac=([^&]+)/i)		{ $Values[8]="$2"; }
if ($QueryString =~ /(^|-|&)is=([^&]+)/i)		{ $Values[9]="$2"; }
if ($QueryString =~ /(^|-|&)as=([^&]+)/i)		{ $Values[10]="$2"; }

if ($OutputDir) { if ($OutputDir !~ /[\\\/]$/) { $OutputDir.="/"; } }

if ((!$SiteConfig && !$Output) || !$DBType || !$IPStart) {
	print "----- $PROG $VERSION (c) Chris Larsen -----\n";
	print "$PROG generates GeoIP Override files using data you provide.\n";
	print "Very useful for Intranet reporting or correcting an old database.\n";
	print "\n";
	print "Usage:\n";
	print "$PROG -type={type} <-config={site config} | -output={file_path}>\n";
	print "  -start{IP} [data options] [script options]\n";
	print "\n";
	print "  Required:\n";
	print "   -type=val           Type of database you want to override.\n";
	print "   -config=val         The full path to your AWStats config file\n";
	print "   -output=val         The full path to an output file\n";
	print "   -start=dotted IP    Starting IP address in 127.0.0.1 format\n";
	print "\n";
	print "  Data Options:  (surround in quotes if spaces)\n";
	print "   -cc=xx        Two character country code \n";
	print "   -rc=xx        Region code or name\n";
	print "   -cn=xx        City name\n";
	print "   -pc=xx        Postal code\n";
	print "   -la=xx        Latitude\n";
	print "   -lo=xx        Longitude\n";
	print "   -mc=xx        Metro code (US only)\n";
	print "   -ac=xx        Area code (US only)\n";
	print "   -is=xx        ISP\n";
	print "   -as=xx        AS Number\n";
	print "\n";
	print "  Script Options:\n";
	print "   -end=dotted IP      Ending IP address for a range \n";
	print "   -debug=level        Debug level to print\n";
	print "   -overwrite          Deletes any entries in the file. Otherwise appends.\n";
	print "\n";
	print "Allowable Type Values:  GeoIP | GeoIPFree | GeoCity | GeoCityLite\n";
	print "                        GeoIPRegion | GeoIPOrg | GeoIPASN \n";
	exit 0;
}

# check the db type
my $matched=0;
if (!$Types{lc($DBType)}){error("Invalid database type: $DBType");}
else {debug("Using Database type: $DBType");}

# Read config file (SiteConfig must be defined)
&Read_Config($SiteConfig);

# see if we have valid IPs
if ($IPStart =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {	# IPv4 address
    debug("Starting IPv4 Address: $IPStart");
}
elsif ($IPStart =~ /^[0-9A-F]*:/i) {							# IPv6 address
    error("Starting IPv6 Address: $IPStart");
}else{error("Invalid starting IP address: $IPStart");}

# for the end IP, if it's empty, we copy the start
if ($IPEnd eq ""){
	$IPEnd = $IPStart;
	debug ("Using IPStart for IPEnd: $IPEnd");
}
elsif($IPEnd =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {	# IPv4 address
    debug("Ending IPv4 Address: $IPEnd");
}
elsif ($IPEnd =~ /^[0-9A-F]*:/i) {							# IPv6 address
    error("Ending IPv6 Address: $IPEnd");
}else{error("Invalid ending IP address: $IPEnd");}

# load the file before anything happens
if (!$Overwrite){ Load_File(); }

# get the start and end IPs as integers
my $start = addr_to_num($IPStart);
my $end = addr_to_num($IPEnd);

# loop and dump
while ($start <= $end){
	# add the IP and values to the hash
	my $f = ",";
	# clean start and end quotes
	if ($f =~ m/^"/) {$f = substr($f, 1);}
	
	# build the fields by switching on the dbtype
	switch (lc($DBType)){
		case "geoip" 		{$f .= $Values[1]; }
		case "geoipfree" 	{$f .= $Values[1]; }
		case "geoipcity"	{
			$f .= $Values[1].",".$Values[2].",\"".$Values[3]."\",\"";
			$f .= $Values[4]."\",".$Values[5].",".$Values[6].",\"";
			$f .= $Values[7]."\",\"".$Values[8]."\""; 
		} 
		case "geoipcitylite"	{
			$f .= $Values[1].",".$Values[2].",\"".$Values[3]."\",\"";
			$f .= $Values[4]."\",".$Values[5].",".$Values[6].",\"";
			$f .= $Values[7]."\",\"".$Values[8]."\""; 
		} 
		case "geoipregion"	{$f .= "\"".$Values[2]."\""; }
		case "geoiporg"		{$f .= "\"".$Values[9]."\""; }
		case "geoipasn"		{$f .= "\"".$Values[10]." ".$Values[9]."\""}		
	}
	
	$temp{num_to_addr($start)} = $f;
	debug("Generating: ".num_to_addr($start)."$f",2);
	$start++;
}

# write
Write_File();

1;	# Do not remove this line





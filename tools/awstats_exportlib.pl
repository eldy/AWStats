#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Export lib data values to a text files to allow to use AWStats robots,
# os, browsers, search_engines database with other log analyzers
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$

#use warnings;		# Must be used in test mode only. This reduce a little process speed
#use diagnostics;	# Must be used in test mode only. This reduce a lot of process speed
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# Defines
#-----------------------------------------------------------------------------
use vars qw/ $REVISION $VERSION /;
my $REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
my $VERSION="5.1 (build $REVISION)";

# ---------- Init variables -------
# Constants
use vars qw/
$DEBUGFORCED
/;
$DEBUGFORCED=0;						# Force debug level to log lesser level into debug.log file (Keep this value to 0)
# Running variables
use vars qw/
$DIR $PROG $Extension
$Debug
$DebugResetDone
/;
$DIR=$PROG=$Extension='';
$Debug=0;
$DebugResetDone=0;
use vars qw/
$LevelForRobotsDetection $LevelForBrowsersDetection $LevelForOSDetection $LevelForRefererAnalyze
$LevelForSearchEnginesDetection $LevelForKeywordsDetection
/;
($LevelForRobotsDetection, $LevelForBrowsersDetection, $LevelForOSDetection, $LevelForRefererAnalyze,
$LevelForSearchEnginesDetection, $LevelForKeywordsDetection)=
(2,1,1,1,1,1);
use vars qw/
$DirLock $DirCgi $DirData $DirIcons $DirLang $AWScript $ArchiveFileName
$AllowAccessFromWebToFollowingIPAddresses $HTMLHeadSection $HTMLEndSection $LinksToWhoIs $LinksToIPWhoIs
$LogFile $LogFormat $LogSeparator $Logo $LogoLink $StyleSheet $WrapperScript $SiteDomain
/;
($DirLock, $DirCgi, $DirData, $DirIcons, $DirLang, $AWScript, $ArchiveFileName,
$AllowAccessFromWebToFollowingIPAddresses, $HTMLHeadSection, $HTMLEndSection, $LinksToWhoIs, $LinksToIPWhoIs,
$LogFile, $LogFormat, $LogSeparator, $Logo, $LogoLink, $StyleSheet, $WrapperScript, $SiteDomain)=
("","","","","","","","","","","","","","","","","","","","");
use vars qw/
$QueryString $LibToExport $ExportFormat
/;
($QueryString, $LibToExport, $ExportFormat)=
('','','');
# ---------- Init arrays --------
use vars qw/
@RobotsSearchIDOrder_list1 @RobotsSearchIDOrder_list2 @RobotsSearchIDOrder_list3
@BrowsersSearchIDOrder @OSSearchIDOrder @SearchEnginesSearchIDOrder @WordsToExtractSearchUrl @WordsToCleanSearchUrl
@RobotsSearchIDOrder
/;
@RobotsSearchIDOrder = ();
# ---------- Init hash arrays --------
use vars qw/
%DomainsHashIDLib %BrowsersHereAreGrabbers %BrowsersHashIcon %BrowsersHashIDLib
%OSHashID %OSHashLib
%RobotsHashIDLib
%SearchEnginesHashIDLib %SearchEnginesKnownUrl
%MimeHashFamily %MimeHashLib
/;



#-----------------------------------------------------------------------------
# Functions
#-----------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function:		Write error message and exit
# Parameters:	$message $secondmessage $thirdmessage $donotshowsetupinfo
# Input:		$LogSeparator $LogFormat
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub error {
	my $message=shift||"";
	my $secondmessage=shift||"";
	my $thirdmessage=shift||"";
	my $donotshowsetupinfo=shift||0;
	if ($Debug) { debug("$message $secondmessage $thirdmessage",1); }
	print "$message";
	print "\n";
	exit 1;
}

#------------------------------------------------------------------------------
# Function:     Write debug message and exit
# Parameters:   $string $level
# Input:        $Debug = required level   $DEBUGFORCED = required level forced
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub debug {
	my $level = $_[1] || 1;
	if ($level <= $DEBUGFORCED) {
		my $debugstring = $_[0];
		if (! $DebugResetDone) { open(DEBUGFORCEDFILE,"debug.log"); close DEBUGFORCEDFILE; chmod 0666,"debug.log"; $DebugResetDone=1; }
		open(DEBUGFORCEDFILE,">>debug.log");
		print DEBUGFORCEDFILE localtime(time)." - $$ - DEBUG $level - $debugstring\n";
		close DEBUGFORCEDFILE;
	}
	if ($level <= $Debug) {
		my $debugstring = $_[0];
		print localtime(time)." - DEBUG $level - $debugstring\n";
	}
}


#------------------------------------------------------------------------------
# Function:     Load the reference databases
# Parameters:	None
# Input:		$DIR
# Output:		Arrays and Hash tables are defined
# Return:       None
#------------------------------------------------------------------------------
sub Read_Ref_Data {
	# Check lib files in common possible directories :
	# Windows :                           		"${DIR}lib" (lib in same dir than awstats.pl)
	# Debian package :                    		"/usr/share/awstats/lib"
	# Other possible directories :        		"./lib"
	my $lib=shift;
	my $dir=$lib;
	$lib=~ s/^.*[\\\/]//;
	$dir =~ s/[^\\\/]+$//; $dir =~ s/[\\\/]+$//;
	debug("Lib: $lib, Dir: $dir");
	my @PossibleLibDir=("$dir","{DIR}lib","/usr/share/awstats/lib","./lib");

	my %FilePath=();
	my @FileListToLoad=();
	push @FileListToLoad, "$lib";
	foreach my $file (@FileListToLoad) {
		foreach my $dir (@PossibleLibDir) {
			my $searchdir=$dir;
			if ($searchdir && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
			if (! $FilePath{$file}) {
				if (-s "${searchdir}${file}") {
					$FilePath{$file}="${searchdir}${file}";
					if ($Debug) { debug("Call to Read_Ref_Data [FilePath{$file}=\"$FilePath{$file}\"]"); }
					# push @INC, "${searchdir}"; require "${file}";
					require "$FilePath{$file}";
				}
			}
		}
		if (! $FilePath{$file}) {
			my $filetext=$file; $filetext =~ s/\.pm$//; $filetext =~ s/_/ /g;
			&error("Error: Can't read file \"$file\".\nCheck if file is in ".($PossibleLibDir[0])." directory and is readable.");
		}
	}
	# Sanity check.
	if (@OSSearchIDOrder != scalar keys %OSHashID) { error("Error: Not same number of records of OSSearchIDOrder (".(@OSSearchIDOrder)." entries) and OSHashID (".(scalar keys %OSHashID)." entries) in OS database. Check your file ".$FilePath{"operating_systems.pm"}); }
	if (@BrowsersSearchIDOrder != scalar keys %BrowsersHashIDLib) { error("Error: Not same number of records of BrowsersSearchIDOrder (".(@BrowsersSearchIDOrder)." entries) and BrowsersHashIDLib (".(scalar keys %BrowsersHashIDLib)." entries) in Browsers database. Check your file ".$FilePath{"browsers.pm"}); }
	if (@SearchEnginesSearchIDOrder != scalar keys %SearchEnginesHashIDLib) { error("Error: Not same number of records of SearchEnginesSearchIDOrder (".(@SearchEnginesSearchIDOrder)." entries) and SearchEnginesHashIDLib (".(scalar keys %SearchEnginesHashIDLib)." entries) in Search Engines database. Check your file ".$FilePath{"search_engines.pm"}); }
	if ((@RobotsSearchIDOrder_list1+@RobotsSearchIDOrder_list2+@RobotsSearchIDOrder_list3) != scalar keys %RobotsHashIDLib) { error("Error: Not same number of records of RobotsSearchIDOrder_listx (total is ".(@RobotsSearchIDOrder_list1+@RobotsSearchIDOrder_list2+@RobotsSearchIDOrder_list3)." entries) and RobotsHashIDLib (".(scalar keys %RobotsHashIDLib)." entries) in Robots database. Check your file ".$FilePath{"robots.pm"}); }
}



#--------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

my @AllowedArgs=('-lib','-exportformat','-debug');

$QueryString="";
for (0..@ARGV-1) {
	# TODO Check if ARGV is an AllowedArg
	if ($_ > 0) { $QueryString .= "&"; }
	my $NewLinkParams=$ARGV[$_]; $NewLinkParams =~ s/^-+//; $NewLinkParams =~ s/\s/%20/g;
	$QueryString .= "$NewLinkParams";
}
$ExportFormat="text";
if ($QueryString =~ /lib=([^\s&]+)/i)			{ $LibToExport="$1"; }
if ($QueryString =~ /exportformat=([^\s&]+)/i)	{ $ExportFormat="$1"; }
if ($QueryString =~ /debug=(\d+)/i)				{ $Debug=$1; }

if ($Debug) {
	debug("$PROG - $VERSION - Perl $^X $]",1);
	debug("QUERY_STRING=$QueryString",2);
}

if (! $LibToExport || ! $ExportFormat) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG is a tool to export AWStats lib (Robots, Os, Browsers, search\n";
	print "engines database) to text files. This allow you to use AWStats lib with some\n";
	print "other log analyzers (to enhance their capabilities or to make comparison).\n";
	print "$PROG comes with ABSOLUTELY NO WARRANTY. It's a free software distributed\n";
	print "with a GNU General Public License (See LICENSE file for details).\n";
	print "\n";
	print "Syntax: $PROG.$Extension -lib=/awstatslibpath/libfile.pm [-exportformat=format]\n";
	print "\n";
	print "Where format can be:\n";
	print "  text       (default)\n";
	print "  webalizer\n";
	print "  analog\n";
	print "\n";
	exit 2;
}

&Read_Ref_Data($LibToExport);


my $libisexportable=0;

# Export data
#------------

if ($LibToExport =~ /browsers/) {
	foreach my $key (sort keys %BrowsersHashIcon) {	
		if ($ExportFormat eq 'text') {
			print "$key\n";
		}
		if ($ExportFormat eq 'webalizer') {
			print "GroupAgent\t$key\n";
		}
		if ($ExportFormat eq 'analog') {
			print "Analog does not support self-defined browsers.\nUse 'text' export format if you want an export list of AWStats Browsers.\n";
			last;
		}	
	}
	$libisexportable=1;
}

if ($LibToExport =~ /mime/) {
	foreach my $key (sort keys %MimeHashFamily) {
		if ($ExportFormat eq 'text') {
			print "$key\t$MimeHashLib{$MimeHashFamily{$key}}\n";
		}
		if ($ExportFormat eq 'webalizer') {
			print "Webalizer does not support self-defined mime types.\nUse 'text' export format if you want an export list of AWStats Mime types.\n";
			last;
		}
		if ($ExportFormat eq 'analog') {
			print "TYPEALIAS .$key   \"$key [$MimeHashLib{$MimeHashFamily{$key}}]\"\n";
		}	
	}
	$libisexportable=1;
}

if ($LibToExport =~ /operating_systems/) {
	foreach my $key (sort keys %OSHashLib) {	
		if ($ExportFormat eq 'text') {
			print "Feature not ready yet\n";
			last;
		}
		if ($ExportFormat eq 'webalizer') {
			print "Webalizer does not support self-defined added OS.\nUse 'text' export format if you want an export list of AWStats OS.\n";
			last;
		}
		if ($ExportFormat eq 'analog') {
			print "Analog does not support self-defined added OS.\nUse 'text' export format if you want an export list of AWStats OS.\n";
			last;
		}
	}
	$libisexportable=1;
}

if ($LibToExport =~ /robots/) {
	my %robotlist=();
	foreach my $robot (@RobotsSearchIDOrder_list1,@RobotsSearchIDOrder_list2) {
		$robotlist{"$robot"}=1;
	}
	foreach my $robot (@RobotsSearchIDOrder_list3) {
		$robotlist{"$robot"}=2;
	}
	foreach my $key (sort keys %robotlist) {	
		if ($ExportFormat eq 'text') {
			if ($robotlist{"$key"}==1) { print "$key\n"; }
		}
		if ($ExportFormat eq 'webalizer') {
			if ($robotlist{"$key"}==1) { print "GroupAgent\t$key\n"; }
		}
		if ($ExportFormat eq 'analog') {
			print 'ROBOTINCLUDE '.($robotlist{$key}==1?'':'REGEXPI:')."$key".($robotlist{$key}==1?'*':'')."\n";
		}	
	}
	$libisexportable=1;
}

if ($LibToExport =~ /search_engines/) {
	foreach my $key (sort keys %SearchEnginesKnownUrl) {	
		if ($ExportFormat eq 'text') {
			print "$key\t$SearchEnginesKnownUrl{$key}\t$SearchEnginesHashIDLib{$key}\n";
		}
		if ($ExportFormat eq 'webalizer') {
			print "SearchEngine\t$key\t$SearchEnginesKnownUrl{$key}\n";
			print "GroupReferrer\t$key\t$SearchEnginesHashIDLib{$key}\n";
		}
		if ($ExportFormat eq 'analog') {
			my $urlkeywordsyntax=$SearchEnginesKnownUrl{$key};
			$urlkeywordsyntax=~s/=$//;
			print "SEARCHENGINE http://*$key*/* $urlkeywordsyntax\n";
		}
	}
	$libisexportable=1;
}

if (! $libisexportable) {
	print "Export for AWStats lib '$LibToExport' is not supported in this tool version.\n";
}


0;	# Do not remove this line


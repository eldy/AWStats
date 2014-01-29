#!/usr/bin/perl
#------------------------------------------------------------------------------
# Launch awstats with -staticlinks option to build all static pages.
# See COPYING.TXT file about AWStats GNU General Public License.
#------------------------------------------------------------------------------

#$|=1;
#use warnings;		# Must be used in test mode only. This reduce a little process speed
#use diagnostics;	# Must be used in test mode only. This reduce a lot of process speed
use strict;no strict "refs";
use Time::Local;	# use Time::Local 'timelocal_nocheck' is faster but not supported by all Time::Local modules


#------------------------------------------------------------------------------
# Defines
#------------------------------------------------------------------------------
my $REVISION='20140126';
my $VERSION="1.2 (build $REVISION)";

# ---------- Init variables --------
my $Debug=0;
my $DIR;
my $PROG;
my $Extension;
my $SiteConfig;
my $Update=0;
my $BuildPDF=0;
my $BuildDate=0;
my $Lang;
my $YearRequired;
my $MonthRequired;
my $DayRequired;
my $Awstats='awstats.pl';
my $AwstatsDir='';
my $HtmlDoc='htmldoc';		# ghtmldoc.exe
my $StaticExt='html';
my $DirIcons='';
my $DirConfig='';
my $OutputDir='';
my $OutputSuffix;
my $OutputFile;
my @pages=();
my @OutputList=();
my $FileConfig;
my $FileSuffix;
my $DatabaseBreak;
use vars qw/
$ShowAuthenticatedUsers $ShowFileSizesStats $ShowScreenSizeStats $ShowSMTPErrorsStats
$ShowEMailSenders $ShowEMailReceivers $ShowWormsStats $ShowClusterStats
$ShowMenu $ShowMonthStats $ShowDaysOfMonthStats $ShowDaysOfWeekStats
$ShowHoursStats $ShowDomainsStats $ShowHostsStats
$ShowRobotsStats $ShowSessionsStats $ShowPagesStats $ShowFileTypesStats
$ShowOSStats $ShowBrowsersStats $ShowDownloadsStats $ShowOriginStats
$ShowKeyphrasesStats $ShowKeywordsStats $ShowMiscStats $ShowHTTPErrorsStats
$BuildReportFormat
@ExtraName
@PluginsToLoad
/;
@ExtraName = ();
@PluginsToLoad = ();
# ----- Time vars -----
use vars qw/
$starttime
$nowtime $tomorrowtime
$nowweekofmonth $nowweekofyear $nowdaymod $nowsmallyear
$nowsec $nowmin $nowhour $nowday $nowmonth $nowyear $nowwday $nowyday $nowns
/;


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
# Function:		Write a warning message
# Parameters:	$message
# Input:		$WarningMessage %HTMLOutput
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub warning {
	my $messagestring=shift;
	debug("$messagestring",1);
#	if ($WarningMessages) {
#    	if ($HTMLOutput) {
#    		$messagestring =~ s/\n/\<br \/\>/g;
#    		print "$messagestring<br />\n";
#    	}
#    	else {
	    	print "$messagestring\n";
#    	}
#	}
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
		if ($ENV{"GATEWAY_INTERFACE"}) { $debugstring =~ s/^ /&nbsp&nbsp /; $debugstring .= "<br />"; }
		print localtime(time)." - DEBUG $level - $debugstring\n";
	}
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

	if ($configdir) { @PossibleConfigDir=("$configdir"); }
	else { @PossibleConfigDir=("$AwstatsDir","$DIR","/etc/awstats","/usr/local/etc/awstats","/etc","/etc/opt/awstats"); }

	# Open config file
	$FileConfig=$FileSuffix='';
	foreach my $dir (@PossibleConfigDir) {
		my $searchdir=$dir;
		if ($searchdir && $searchdir !~ /[\\\/]$/) { $searchdir .= "/"; }
		if (open(CONFIG,"${searchdir}awstats.$SiteConfig.conf")) 	{ $FileConfig="${searchdir}awstats.$SiteConfig.conf"; $FileSuffix=".$SiteConfig"; last; }
		if (open(CONFIG,"${searchdir}awstats.conf"))  				{ $FileConfig="${searchdir}awstats.conf"; $FileSuffix=''; last; }
	}
	if (! $FileConfig) { error("Couldn't open config file \"awstats.$SiteConfig.conf\" nor \"awstats.conf\" after searching in path \"".join(',',@PossibleConfigDir)."\": $!"); }

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
            local( *CONFIG_INCLUDE );   # To avoid having parent file closed when include file is closed
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
 		if ($param =~ /^ExtraSectionName(\d+)/)			{ $ExtraName[$1]=$value; next; }

		# Plugins
		if ( $param =~ /^LoadPlugin/ ) { push @PluginsToLoad, $value; next; }

		# If parameters was not found previously, defined variable with name of param to value
		print $param."-".$value."\n";
		$$param=$value;
	}

	if ($Debug) { debug("Config file read was \"$configFile\" (level $level)"); }
}




#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

my $QueryString=''; for (0..@ARGV-1) { $QueryString .= "$ARGV[$_]&"; }

if ($QueryString =~ /(^|-|&)month=(year)/i) { error("month=year is a deprecated option. Use month=all instead."); }

if ($QueryString =~ /(^|-|&)debug=(\d+)/i)			{ $Debug=$2; }
if ($QueryString =~ /(^|-|&)configdir=([^&]+)/i)	{ $DirConfig="$2"; }
if ($QueryString =~ /(^|-|&)config=([^&]+)/i)		{ $SiteConfig="$2"; }
if ($QueryString =~ /(^|-|&)databasebreak=([^&]+)/i)	{ $DatabaseBreak="$2"; }
if ($QueryString =~ /(^|-|&)awstatsprog=([^&]+)/i)	{ $Awstats="$2"; }
if ($QueryString =~ /(^|-|&)buildpdf/i) 			{ $BuildPDF=1; }
if ($QueryString =~ /(^|-|&)buildpdf=([^&]+)/i)		{ $HtmlDoc="$2"; }
if ($QueryString =~ /(^|-|&)staticlinksext=([^&]+)/i)	{ $StaticExt="$2"; }
if ($QueryString =~ /(^|-|&)dir=([^&]+)/i)			{ $OutputDir="$2"; }
if ($QueryString =~ /(^|-|&)diricons=([^&]+)/i)		{ $DirIcons="$2"; }
if ($QueryString =~ /(^|-|&)update/i)				{ $Update=1; }
if ($QueryString =~ /(^|-|&)builddate=?([^&]*)/i)	{ $BuildDate=$2||'%YY%MM%DD'; }
if ($QueryString =~ /(^|-|&)year=(\d\d\d\d)/i) 		{ $YearRequired="$2"; }
if ($QueryString =~ /(^|-|&)month=(\d{1,2})/i || $QueryString =~ /(^|-|&)month=(all)/i) { $MonthRequired="$2"; }
if ($QueryString =~ /(^|-|&)day=(\d{1,2})/i)        { $DayRequired="$2"; }

if ($QueryString =~ /(^|-|&)lang=([^&]+)/i)			{ $Lang="$2"; }

if ($OutputDir) { if ($OutputDir !~ /[\\\/]$/) { $OutputDir.="/"; } }

if (! $SiteConfig) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG allows you to launch AWStats with -staticlinks option\n";
	print "to build all possible pages allowed by AWStats -output option.\n";
	print "\n";
	print "Usage:\n";
	print "$PROG.$Extension (awstats_options) [awstatsbuildstaticpages_options]\n";
	print "\n";
	print "  where awstats_options are any option known by AWStats\n";
	print "   -config=configvalue is value for -config parameter (REQUIRED)\n";
	print "   -update             option used to update statistics before to generate pages\n";
	print "   -lang=LL            to output a HTML report in language LL (en,de,es,fr,...)\n";
	print "   -month=MM           to output a HTML report for an old month=MM\n";
	print "   -year=YYYY          to output a HTML report for an old year=YYYY\n";
	print "\n";
	print "  and awstatsbuildstaticpages_options can be\n";
	print "   -awstatsprog=pathtoawstatspl AWStats software (awstats.pl) path\n";
	print "   -dir=outputdir               Output directory for generated pages\n";
	print "   -diricons=icondir            Relative path to use as icon dir in <img> links\n";
	print "   -builddate=%YY%MM%DD         Used to add build date in built pages filenames\n";
	print "   -staticlinksext=xxx          Build pages with .xxx extension (default .html)\n";
	print "   -buildpdf[=pathtohtmldoc]    Build a PDF file after building HTML pages.\n";
	print "                                 Output directory must contains icon directory\n";
	print "                                 when this option is used (need 'htmldoc')\n";
	print "\n";
	print "New versions and FAQ at http://www.awstats.org\n";
	exit 0;
}


my $retour;

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

# Check if HTMLDOC prog is found
if ($BuildPDF) {
	my $HtmlDocFound=0;
	if (-x "$HtmlDoc") { $HtmlDocFound=1; }
	elsif (-x "/usr/bin/htmldoc") {
		$HtmlDoc='/usr/bin/htmldoc';
		$HtmlDocFound=1;
	}
	if (! $HtmlDocFound) {
		error("Can't find htmldoc program ('$HtmlDoc').\nUse -buildpdf=htmldocprog option to solve this");
		exit 1;
	}
}

# Read config file (SiteConfig must be defined)
&Read_Config($DirConfig);

if ($BuildReportFormat eq 'xhtml') {
    $StaticExt="xml";    
    if ($BuildPDF) {
        error("Building PDF file is not compatible with building xml output files. Change your parameter BuildReportFormat to html in your config file");
    }
}

# Define list of output files
if ($ShowDomainsStats) { push @OutputList,'alldomains'; }
if ($ShowHostsStats) { push @OutputList,'allhosts'; push @OutputList,'lasthosts'; push @OutputList,'unknownip'; }
if ($ShowAuthenticatedUsers) { push @OutputList,'alllogins'; push @OutputList,'lastlogins'; }
if ($ShowRobotsStats) { push @OutputList,'allrobots'; push @OutputList,'lastrobots'; }
if ($ShowEMailSenders) { push @OutputList,'allemails'; push @OutputList,'lastemails'; }
if ($ShowEMailReceivers) { push @OutputList,'allemailr'; push @OutputList,'lastemailr'; }
if ($ShowSessionsStats) { push @OutputList,'session'; }
if ($ShowPagesStats) { push @OutputList,'urldetail'; push @OutputList,'urlentry'; push @OutputList,'urlexit'; }
#if ($ShowFileTypesStats) { push @OutputList,'filetypes'; }	# There is dedicated page for filetypes
if ($ShowOSStats) { push @OutputList,'osdetail'; push @OutputList,'unknownos'; }
if ($ShowBrowsersStats) { push @OutputList,'browserdetail'; push @OutputList,'unknownbrowser'; }
if ($ShowDownloadsStats) { push @OutputList,'downloads'; }
if ($ShowScreenSizeStats) { push @OutputList,'screensize'; }
if ($ShowOriginStats) { push @OutputList,'refererse'; push @OutputList,'refererpages'; }
if ($ShowKeyphrasesStats) { push @OutputList,'keyphrases'; }
if ($ShowKeywordsStats) { push @OutputList,'keywords'; }
#if ($ShowMiscStats) { push @OutputList,'misc'; }			# There is no dedicated page for misc
if ($ShowHTTPErrorsStats) {
	#push @OutputList,'errors'; 							# There is no dedicated page for errors					
	push @OutputList,'errors404';		
}
#if ($ShowSMTPErrorsStats) { push @OutputList,'errors'; }
foreach my $extranum (1..@ExtraName-1) {
	push @OutputList,'allextra'.$extranum;
}
#Add plugins
foreach ( @PluginsToLoad ) {
	if ($_ =~ /^(geoip_[_a-z]+)\s/) { push @OutputList,'plugin_'.$1; }	# Add geoip maxmind subpages
}


# Launch awstats update
if ($Update) {
	my $command="\"$Awstats\" -config=$SiteConfig -update";
	$command .= " -configdir=$DirConfig" if defined $DirConfig;
	$command .= " -databasebreak=$DatabaseBreak" if defined $DatabaseBreak;
	print "Launch update process : $command\n";
	$retour=`$command  2>&1`;
}

# Built the OutputSuffix value (used later to build page name)
$OutputSuffix=$SiteConfig;
if ($BuildDate) {
	($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday,$nowyday) = localtime(time);
	$nowweekofmonth=int($nowday/7);
	$nowweekofyear=int(($nowyday-1+6-($nowwday==0?6:$nowwday-1))/7)+1; if ($nowweekofyear > 52) { $nowweekofyear = 1; }
	$nowdaymod=$nowday%7;
	$nowwday++;
	$nowns=Time::Local::timegm(0,0,0,$nowday,$nowmonth,$nowyear);
	if ($nowdaymod <= $nowwday) { if (($nowwday != 7) || ($nowdaymod != 0)) { $nowweekofmonth=$nowweekofmonth+1; } }
	if ($nowdaymod >  $nowwday) { $nowweekofmonth=$nowweekofmonth+2; }
	# Change format of time variables
	$nowweekofmonth="0$nowweekofmonth";
	if ($nowweekofyear < 10) { $nowweekofyear = "0$nowweekofyear"; }
	if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
	$nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
	if (++$nowmonth < 10) { $nowmonth = "0$nowmonth"; }
	if ($nowday < 10) { $nowday = "0$nowday"; }
	if ($nowhour < 10) { $nowhour = "0$nowhour"; }
	if ($nowmin < 10) { $nowmin = "0$nowmin"; }
	if ($nowsec < 10) { $nowsec = "0$nowsec"; }
	# Replace tag with new value
	$BuildDate =~ s/%YYYY/$nowyear/ig;
	$BuildDate =~ s/%YY/$nowsmallyear/ig;
	$BuildDate =~ s/%MM/$nowmonth/ig;
	#$BuildDate =~ s/%MO/$MonthNumLibEn{$nowmonth}/ig;
	$BuildDate =~ s/%DD/$nowday/ig;
	$BuildDate =~ s/%HH/$nowhour/ig;
	$BuildDate =~ s/%NS/$nowns/ig;
	$BuildDate =~ s/%WM/$nowweekofmonth/g;
	my $nowweekofmonth0=$nowweekofmonth-1; $BuildDate =~ s/%Wm/$nowweekofmonth0/g;
	$BuildDate =~ s/%WY/$nowweekofyear/g;
	my $nowweekofyear0=sprintf("%02d",$nowweekofyear-1); $BuildDate =~ s/%Wy/$nowweekofyear0/g;
	$BuildDate =~ s/%DW/$nowwday/g;
	my $nowwday0=$nowwday-1; $BuildDate =~ s/%Dw/$nowwday0/g;
	$OutputSuffix.=".$BuildDate";
}

my $cpt=0;
my $NoLoadPlugin="";
if ($BuildPDF) { $NoLoadPlugin.="tooltips,rawlog,hostinfo"; }
my $smallcommand="\"$Awstats\" -config=$SiteConfig".($BuildPDF?" -buildpdf":"").($NoLoadPlugin?" -noloadplugin=$NoLoadPlugin":"").($DatabaseBreak?" -databasebreak=$DatabaseBreak":"")." -staticlinks".($OutputSuffix ne $SiteConfig?"=awstats.$OutputSuffix":"");
if ($StaticExt && $StaticExt ne 'html')     { $smallcommand.=" -staticlinksext=$StaticExt"; }
if ($DirIcons)      { $smallcommand.=" -diricons=$DirIcons"; }
if ($DirConfig)     { $smallcommand.=" -configdir=$DirConfig"; }
if ($Lang)          { $smallcommand.=" -lang=$Lang"; }
if ($DayRequired)   { $smallcommand.=" -day=$DayRequired"; }
if ($MonthRequired) { $smallcommand.=" -month=$MonthRequired"; }
if ($YearRequired)  { $smallcommand.=" -year=$YearRequired"; }

# Launch main awstats output
my $command="$smallcommand -output";
print "Build main page: $command\n";
$retour=`$command  2>&1`;
$OutputFile=($OutputDir?$OutputDir:"")."awstats.$OutputSuffix.$StaticExt";
open("OUTPUT",">$OutputFile") || error("Couldn't open log file \"$OutputFile\" for writing : $!");
print OUTPUT $retour;
close("OUTPUT");
$cpt++;
push @pages, $OutputFile;	# Add page to @page for PDF build

# Launch all other awstats output
for my $output (@OutputList) {
	my $command="$smallcommand -output=$output";
	print "Build $output page: $command\n";
	$retour=`$command  2>&1`;
	$OutputFile=($OutputDir?$OutputDir:"")."awstats.$OutputSuffix.$output.$StaticExt";
	open("OUTPUT",">$OutputFile") || error("Couldn't open log file \"$OutputFile\" for writing : $!");
	print OUTPUT $retour;
	close("OUTPUT");
	$cpt++;
	push @pages, $OutputFile;	# Add page to @page for PDF build
}

# Build pdf file
if ($QueryString =~ /(^|-|&)buildpdf/i) {
#	my $pdffile=$pages[0]; $pdffile=~s/\.\w+$/\.pdf/;
	$OutputFile=($OutputDir?$OutputDir:"")."awstats.$OutputSuffix.pdf";
	my $command="\"$HtmlDoc\" -t pdf --webpage --quiet --no-title --textfont helvetica --left 16 --bottom 8 --top 8 --browserwidth 800 --headfootsize 8.0 --fontsize 7.0 --header xtx --footer xd/ --outfile $OutputFile @pages\n";
	print "Build PDF file : $command\n";
	$retour=`$command  2>&1`;
    my $signal_num=$? & 127;
	my $dumped_core=$? & 128;
	my $exit_value=$? >> 8;
	if ($? || $retour =~ /error/) {
		if ($retour) { error("Failed to build PDF file with following error: $retour"); }
		else { error("Failed to run successfuly htmldoc process: Return code=$exit_value, Killer signal num=$signal_num, Core dump=$dumped_core"); }
	}
	$cpt++;
}


print "$cpt files built.\n";
print "Main HTML page is 'awstats.$OutputSuffix.$StaticExt'.\n";
if ($QueryString =~ /(^|-|&)buildpdf/i) { print "PDF file is 'awstats.$OutputSuffix.pdf'.\n"; }

0;	# Do not remove this line

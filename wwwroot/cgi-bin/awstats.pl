#!/usr/bin/perl
# With some other Unix Os, first line may be
#!/usr/local/bin/perl
# With Apache for Windows and ActiverPerl, first line may be
#!C:/Program Files/ActiveState/bin/perl
#-Description-------------------------------------------
# Free realtime web server logfile analyzer to show advanced web statistics.
# Works from command line or as a CGI. You must use this script as often as
# necessary from your scheduler to update your statistics.
# See AWStats documenation (in docs/ directory) for all setup instructions.
#-------------------------------------------------------
# ALGORITHM SUMMARY
# Read config file
# Init variables
# If 'update'
#   Get last history file name
#   Read this last history file (LastLine, data arrays, ...)
#   Loop on each new line in log file
#     If line older than LastLine, skip
#     If new line
#        If other month/year, save data arrays, reset them
#        Analyse record and complete data arrays
#     End of new line
#   End of loop
# End of 'update'
# Save data arrays
# Reset data arrays if not required month/year
# Loop for each month of current year
#   If required month, read 1st and 2nd part of history file for this month
#   If not required month, read 1st part of history file for this month
# End of loop
# If 'output'
#   Show data arrays in HTML page
# End of 'output'
#-------------------------------------------------------
#use diagnostics;
#use strict;
# Uncomment following line and a line into GetDelaySinceStart function to get
# miliseconds time in showsteps option
#use Time::HiRes qw( gettimeofday );		


#-------------------------------------------------------
# Defines
#-------------------------------------------------------

# ---------- Init variables (Variable $TmpHashxxx are not initialized) -------
($AddOn,$BarHeight,$BarWidth,$Debug,$DebugResetDone,$DNSLookup,$Expires, 
$CreateDirDataIfNotExists, $KeepBackupOfHistoricFiles,$MaxLengthOfURL,
$MaxNbOfHostsShown, $MaxNbOfKeywordsShown, $MaxNbOfLoginShown,
$MaxNbOfPageShown, $MaxNbOfRefererShown, $MaxNbOfRobotShown,
$MinHitFile, $MinHitHost, $MinHitKeyword,
$MinHitLogin, $MinHitRefer, $MinHitRobot,
$NbOfLinesForCorruptedLog, $PurgeLogFile,
$ShowAuthenticatedUsers, $ShowCompressionStats, $ShowFileSizesStats,
$ShowCorrupted, $ShowSteps, $StartSeconds, $StartMicroseconds,
$StaticLinks, $URLWithQuery)=
(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
($ArchiveLogRecords, $DetailedReportsOnNewWindows, $FirstDayOfWeek,
$ShowHeader, $ShowMenu, $ShowMonthDayStats, $ShowDaysOfWeekStats,
$ShowHoursStats, $ShowDomainsStats, $ShowHostsStats, 
$ShowRobotsStats, $ShowPagesStats, $ShowFileTypesStats, 
$ShowBrowsersStats, $ShowOSStats, $ShowOriginStats, $ShowKeyphrasesStats,
$ShowKeywordsStats,  $ShowHTTPErrorsStats,
$ShowFlagLinks, $ShowLinksOnURL,
$WarningMessages)=
(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);
($ArchiveFileName, $DIR, $DayRequired, $DefaultFile,
$Extension, $FileConfig, $FileSuffix, 
$HTMLHeadSection, $HTMLEndSection, $Host,
$LastUpdate, $LogFile, $LogFormat, $LogFormatString, $Logo, $LogoLink,
$MonthRequired,
$HTMLOutput, $PROG, $PageCode, $QueryString,
$SiteConfig, $SiteDomain, $SiteToAnalyze, $SiteToAnalyzeWithoutwww, 
$TotalEntries, $TotalBytesPages, $TotalKeyphrases, $TotalDifferentPages, $TotalDifferentKeyphrases,
$URLFilter, $UserAgent, $YearRequired)=
();
($color_Background, $color_TableBG, $color_TableBGRowTitle,
$color_TableBGTitle, $color_TableBorder, $color_TableRowTitle, $color_TableTitle,
$color_text, $color_titletext, $color_weekend, $color_link, $color_hover,
$color_h, $color_k, $color_p, $color_s, $color_u, $color_v)=
("","","","","","","","","","","","","","","","","","");
($DirCgi, $DirData, $DirIcons, $DirLang)=
("","","","");
# ---------- Init arrays --------
@HostAliases = @Message = @OnlyFiles = @SkipDNSLookupFor = @SkipFiles = @SkipHosts = @DOWIndex = ();
@RobotArrayID=();
@WordsToCleanSearchUrl = ();
# ---------- Init hash arrays --------
%DayBytes = %DayHits = %DayPages = %DayUnique = %DayVisits =
%FirstTime = %LastTime = %LastUpdate =
%MonthBytes = %MonthHits = %MonthHostsKnown = %MonthHostsUnknown = %MonthPages = %MonthUnique = %MonthVisits =
%monthlib = %monthnum = ();
# ---------- Init Tie::hash arrays --------
#use Tie::Hash;
#tie %_hostmachine_p, 'Tie::StdHash';
#tie %_hostmachine_h, 'Tie::StdHash';
#tie %_hostmachine_k, 'Tie::StdHash';
#tie %_hostmachine_l, 'Tie::StdHash';
#tie %_url_p, 'Tie::StdHash';
#tie %_url_k, 'Tie::StdHash';
#tie %_url_e, 'Tie::StdHash';
#
#tie %_browser_h, 'Tie::StdHash';
#tie %_domener_p, 'Tie::StdHash';
#tie %_domener_h, 'Tie::StdHash';
#tie %_domener_k, 'Tie::StdHash';
#tie %_errors_h, 'Tie::StdHash';
#tie %_filetypes_h, 'Tie::StdHash';
#tie %_filetypes_k, 'Tie::StdHash';
#tie %_filetypes_gz_in, 'Tie::StdHash';
#tie %_filetypes_gz_out, 'Tie::StdHash';
#tie %_keyphrases, 'Tie::StdHash';
#tie %_os_h, 'Tie::StdHash';
#tie %_pagesrefs_h, 'Tie::StdHash';
#tie %_robot_h, 'Tie::StdHash';
#tie %_robot_l, 'Tie::StdHash';
#tie %_login_p, 'Tie::StdHash';
#tie %_login_h, 'Tie::StdHash';
#tie %_login_k, 'Tie::StdHash';
#tie %_login_l, 'Tie::StdHash';
#tie %_se_referrals_h, 'Tie::StdHash';
#tie %_sider404_h, 'Tie::StdHash';
#tie %_unknownreferer_l, 'Tie::StdHash';
#tie %_unknownrefererbrowser_l, 'Tie::StdHash';



$VERSION="4.0 (build 23)";
$Lang="en";

# Default value
$DEBUGFORCED   = 0;				# Force debug level to log lesser level into debug.log file (Keep this value to 0)
$MaxRowsInHTMLOutput = 1000;	# Max number of rows for not limited HTML arrays
$VisitTimeOut  = 10000;			# Laps of time to consider a page load as a new visit. 10000 = one hour (Default = 10000)
$FullHostName  = 1;				# 1 = Use name.domain.zone to refer host clients, 0 = all hosts in same domain.zone are one host (Default = 1, 0 never tested)
$NbOfLinesForBenchmark=5000;
$ShowBackLink  = 1;
$CENTER        = "";
$WIDTH         = "600";
# Images for graphics
$BarImageVertical_v   = "barrevv.png";
#$BarImageHorizontal_v = "barrehv.png";
$BarImageVertical_u   = "barrevu.png";
#$BarImageHorizontal_u = "barrehu.png";
$BarImageVertical_p   = "barrevp.png";
$BarImageHorizontal_p = "barrehp.png";
#$BarImageVertical_e = "barreve.png";
$BarImageHorizontal_e = "barrehe.png";
$BarImageVertical_h   = "barrevh.png";
$BarImageHorizontal_h = "barrehh.png";
$BarImageVertical_k   = "barrevk.png";
$BarImageHorizontal_k = "barrehk.png";

$AddOn=0;
#require "${DIR}addon.pl"; $AddOn=1; 		# Keep this line commented in standard version

# Those addresses are shown with those lib (First column is full exact relative URL, second column is text to show instead of URL)
%Aliases    = (
			"/",                                    "<b>HOME PAGE</b>",
			"/cgi-bin/awstats.pl",					"<b>AWStats stats page</b>",
			"/cgi-bin/awstats/awstats.pl",			"<b>AWStats stats page</b>",
			# Following the same example, you can put here HTML text you want to see in links instead of URL text.
			"/YourRelativeUrl",						"<b>Your HTML text</b>"
			);

# These table is used to make fast reverse DNS lookup for particular IP adresses. You can add your own IP addresses resolutions.
%MyDNSTable = (
"256.256.256.1", "myworkstation1",
"256.256.256.2", "myworkstation2"
);

# HTTP codes with tooltip
%httpcode = (
"201", "Partial Content", "202", "Request recorded, will be executed later", "204", "Request executed", "206", "Partial Content",
"301", "Moved Permanently", "302", "Found",
"400", "Bad Request", "401", "Unauthorized", "403", "Forbidden", "404", "Not Found", "408", "Request Timeout",
"500", "Internal Error", "501", "Not implemented", "502", "Received bad response from real server", "503", "Server busy", "504", "Gateway Time-Out", "505", "HTTP version not supported",
"200", "OK", "304", "Not Modified"	# 200 and 304 are not errors
);



#-------------------------------------------------------
# Functions
#-------------------------------------------------------

sub html_head {
	if ($HTMLOutput) {
		# Write head section
		my $sitetoanalyze=$SiteToAnalyze; $sitetoanalyze =~ s/\\\./\./g;
	  	print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n\n";
	    print "<html>\n";
		print "<head>\n";
		if ($PageCode) { print "<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=$PageCode\"\n"; }		# If not defined, iso-8859-1 is used in major countries
		if ($Expires)  { print "<META HTTP-EQUIV=\"expires\" CONTENT=\"".(localtime(time()+$Expires))."\">\n"; } 
		print "<meta http-equiv=\"description\" content=\"$PROG - Advanced Web Statistics for $sitetoanalyze\">\n";
		print "<meta http-equiv=\"keywords\" content=\"$sitetoanalyze, free, advanced, realtime, web, server, logfile, log, analyzer, analysis, statistics, stats, perl, analyse, performance, hits, visits\">\n";
		print "<meta name=\"robots\" content=\"index,follow\">\n";
		print "<title>$Message[7] $sitetoanalyze</title>\n";
		# Do not use " for number in a style section
		print <<EOF;
<STYLE TYPE="text/css">
<!--
BODY { font: 12px arial, verdana, helvetica, sans-serif; background-color: #$color_Background; }
TH { font: 12px arial, verdana, helvetica, sans-serif; text-align:center; color: #$color_titletext; }
TH.AWL { font-size: 14px; font-weight: bold; }
TD { font: 12px arial, verdana, helvetica, sans-serif; text-align:center; color: #$color_text; }
.AWL { font: 12px arial, verdana, helvetica, sans-serif; text-align:left; color: #$color_text; }
A { font: 12px arial, verdana, helvetica, sans-serif; }
A:link    { color: #$color_link; text-decoration: none; }
A:visited { color: #$color_link; text-decoration: none; }
A:hover   { color: #$color_hover; text-decoration: underline; }
DIV { font: 12px arial,verdana,helvetica; text-align:justify; }
.TABLEBORDER { background-color: #$color_TableBorder; }
.TABLEFRAME { background-color: #$color_TableBG; padding: 2px 2px 2px 2px; margin-top: 0 }
.TABLEDATA { background-color: #$color_Background; }
.TABLETITLEFULL  { font: 14px verdana, arial, helvetica, sans-serif; font-weight: bold; background-color: #$color_TableBGTitle; text-align: center; width: 66%; margin-bottom: 0; padding: 2px; }
.TABLETITLEBLANK { font: 14px verdana, arial, helvetica, sans-serif; background-color: #$color_Background; }
.CTooltip { position:absolute; top:0px; left:0px; z-index:2; width:280; visibility:hidden; font: 8pt MS Comic Sans,arial,sans-serif; background-color: #FFFFE6; padding: 8px; border: 1px solid black; }

.tablecontainer  { width: 100% }
\@media projection {
.tablecontainer { page-break-before: always; }
}

//-->
</STYLE>
EOF
		print "</head>\n\n";
		print "<body>\n";
		# Write logo, flags and product name
		if ($ShowHeader) {
			print "$HTMLHeadSection\n";
			print "<table WIDTH=$WIDTH>\n";
			print "<tr valign=middle><td class=AWL width=150 style=\"font: 18px arial,verdana,helvetica; font-weight: bold\">AWStats\n";
			Show_Flag_Links($Lang);
			print "</td>\n";
			if ($LogoLink =~ "http://awstats.sourceforge.net") {
				print "<td class=AWL width=450><a href=\"$LogoLink\" target=\"_newawstats\"><img src=\"$DirIcons/other/$Logo\" border=0 alt=\"$PROG Official Web Site\" title=\"$PROG Official Web Site\"></a></td></tr>\n";
			}
			else {
				print "<td class=AWL width=450><a href=\"$LogoLink\" target=\"_newawstats\"><img src=\"$DirIcons/other/$Logo\" border=0></a></td></tr>\n";
			}
			#print "<b><font face=\"verdana\" size=1><a href=\"$HomeURL\">HomePage</a> &#149\; <a href=\"javascript:history.back()\">Back</a></font></b><br>\n";
			print "<tr><td class=AWL colspan=2>$Message[54]</td></tr>\n";
			print "</table>\n";
			#print "<hr>\n";
		}
	}
}


sub html_end {
	if ($HTMLOutput) {
		print "$CENTER<br><br><br>\n";
		print "<FONT COLOR=\"#$color_text\"><b>Advanced Web Statistics $VERSION</b> - <a href=\"http://awstats.sourceforge.net\" target=\"_newawstats\">Created by $PROG</a></font><br>\n";
		print "<br>\n";
		print "$HTMLEndSection\n";
		print "</body>\n";
		print "</html>\n";
	}
}

sub tab_head {
	my $title=shift;
	my $tooltip=shift;
	print "<div class=\"tablecontainer\">\n";
	print "<TABLE CLASS=\"TABLEFRAME\" BORDER=0 CELLPADDING=2 CELLSPACING=0 WIDTH=\"100%\">\n";
	if ($tooltip) {
		print "<TR><TD class=\"TABLETITLEFULL\" onmouseover=\"ShowTooltip($tooltip);\" onmouseout=\"HideTooltip($tooltip);\">$title </TD>";
	}
	else {
		print "<TR><TD class=\"TABLETITLEFULL\">$title </TD>";
	}
	print "<TD class=\"TABLETITLEBLANK\"> &nbsp; </TD></TR>\n";
	print "<TR><TD colspan=2><TABLE CLASS=\"TABLEDATA\" BORDER=1 BORDERCOLOR=\"#$color_TableBorder\" CELLPADDING=2 CELLSPACING=0 WIDTH=\"100%\">";
}

sub tab_end {
	print "</TABLE></TD></TR></TABLE>";
	print "</div>\n\n";
}

sub error {
	my $message=shift||"";
	my $secondmessage=shift||"";
	my $thirdmessage=shift||"";
	debug("$message $secondmessage $thirdmessage",1);
	if ($message =~ /^Format error$/) {
		# Files seems to have bad format
		if ($HTMLOutput) { print "<br><br>\n"; }
		print "AWStats did not found any valid log lines that match your <b>LogFormat</b> parameter, in the ${NbOfLinesForCorruptedLog}th first non commented lines read of your log.<br>\n";
		print "<font color=#880000>Your log file <b>$thirdmessage</b> must have a bad format or <b>LogFormat</b> parameter setup does not match this format.</font><br><br>\n";
		print "Your <b>LogFormat</b> parameter is <b>$LogFormat</b>, this means each line in your log file need to have ";
		if ($LogFormat == 1) {
			print "<b>\"combined log format\"</b> like this:<br>\n";
			print ($HTMLOutput?"<font color=#888888><i>":"");
			print "111.22.33.44 - - [10/Jan/2001:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234 \"http://www.fromserver.com/from.htm\" \"Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)\"\n";
			print ($HTMLOutput?"</i></font><br><br>":"");
		}
		if ($LogFormat == 2) {
			print "<b>\"MSIE Extended W3C log format\"</b> like this:<br>\n";
			print ($HTMLOutput?"<font color=#888888><i>":"");
			print "date time c-ip c-username cs-method cs-uri-sterm sc-status sc-bytes cs-version cs(User-Agent) cs(Referer)\n";
			print ($HTMLOutput?"</i></font><br><br>":"");
		}
		if ($LogFormat == 3) {
			print "<b>\"WebStar native log format\"</b><br>\n";
		}
		if ($LogFormat == 4) {
			print "<b>\"common log format\"</b> like this:<br>\n";
			print ($HTMLOutput?"<font color=#888888><i>":"");
			print "111.22.33.44 - - [10/Jan/2001:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234\n";
			print ($HTMLOutput?"</i></font><br><br>":"");
		}
		if ($LogFormat != 1 && $LogFormat != 2 && $LogFormat != 3 && $LogFormat != 4) {
			print "the following personalised log format:<br>\n";
			print ($HTMLOutput?"<font color=#888888><i>":"");
			print "$LogFormat\n";
			print ($HTMLOutput?"</i></font><br><br>":"");
		}
		print "And this is a sample of what AWStats found in your log (the record number $NbOfLinesForCorruptedLog in your log):\n";
		print ($HTMLOutput?"<br><font color=#888888><i>":"");
		print "$secondmessage";
		print ($HTMLOutput?"</i></font><br><br>":"");
		print "\n";
		#print "Note: If your $NbOfLinesForCorruptedLog first lines in your log files are wrong because they are ";
		#print "result of a worm virus attack, you can increase the NbOfLinesForCorruptedLog parameter in config file.\n";
		#print "\n";
	}			
	else {
   		print ($HTMLOutput?"<br><font color=#880000>":"");
   		print "$message";
   		print ($HTMLOutput?"</font><br>":"");
   		print "\n";
   	}
   	if ($message ne "" && $message !~ /History file.*is corrupted/) { 
		if ($HTMLOutput) { print "<br><b>\n"; }
		print "Setup (".($FileConfig?$FileConfig:"Config")." file, web server or permissions) may be wrong.\n";
		if ($HTMLOutput) { print "</b><br>\n"; }
		print "See README.TXT for informations on how to setup $PROG.\n";
	}
	if ($HTMLOutput) { print "</BODY>\n</HTML>\n"; }
    exit 1;
}

sub warning {
	my $messagestring=shift;
	debug("$messagestring",1);
	if ($WarningMessages == 1) {
    	if ($HTMLOutput) {
    		$messagestring =~ s/\n/\<br\>/g;
    		print "$messagestring<br>\n";
    	}
    	else {
	    	print "$messagestring\n";
    	}
	}
}

# Parameters : $string $level   
# Input      : $Debug = required level   $DEBUGFORCED = required level forced
sub debug {
	my $level = $_[1] || 1;
	if ($DEBUGFORCED >= $level) { 
		my $debugstring = $_[0];
		if ($DEBUGFORCED >= $level) {
			if (! $DebugResetDone) { open(DEBUGFORCEDFILE,"debug.log"); close DEBUGFORCEDFILE; chmod 0666,"debug.log"; $DebugResetDone=1; }
			open(DEBUGFORCEDFILE,">>debug.log");
			print DEBUGFORCEDFILE localtime(time)." - $$ - DEBUG $level - $debugstring\n";
			close DEBUGFORCEDFILE;
		}
	}
	if ($Debug >= $level) { 
		my $debugstring = $_[0];
		if ($HTMLOutput) { $debugstring =~ s/^ /&nbsp&nbsp /; $debugstring .= "<br>"; }
		print localtime(time)." - DEBUG $level - $debugstring\n";
	}
}

sub SkipHost {
	foreach my $match (@SkipHosts) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipHosts
}

sub SkipFile {
	foreach my $match (@SkipFiles) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipFiles
}

sub OnlyFile {
	if (! $OnlyFiles[0]) { return 1; }
	foreach my $match (@OnlyFiles) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @OnlyFiles
}

sub SkipDNSLookup {
	foreach my $match (@SkipDNSLookupFor) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipDNSLookupFor
}

sub DayOfWeek {
	my ($day, $month, $year) = @_;
	&debug("DayOfWeek for $day $month $year",4);
	if ($month < 3) {  $month += 10;  $year--; } 
	else { $month -= 2; }
	my $cent = sprintf("%1i",($year/100));
	my $y = ($year % 100);
	my $dw = (sprintf("%1i",(2.6*$month)-0.2) + $day + $y + sprintf("%1i",($y/4)) + sprintf("%1i",($cent/4)) - (2*$cent)) % 7;
	$dw += 7 if ($dw<0);
	&debug(" is $dw",4);
	return $dw;
}

sub DateIsValid {
	my ($day, $month, $year) = @_;
	&debug("DateIsValid for $day $month $year",4);
	if ($day < 1) { return 0; }
	if ($month==1 || $month==3 || $month==5 || $month==7 || $month==8 || $month==10 || $month==12) {
		if ($day > 31) { return 0; }		
	}
	if ($month==4 || $month==6 || $month==9 || $month==11) {
		if ($day > 30) { return 0; }
	}
	if ($month==2) {
		if ($day > 28) { return 0; }		
	}
	return 1;
}



#------------------------------------------------------------------------------
# Function:     read config file
# Input:		$DIR $PROG $SiteConfig
# Output:		Global variables
#------------------------------------------------------------------------------
sub Read_Config_File {
	$FileConfig=""; $FileSuffix="";
	if (! $SiteConfig) { $SiteConfig=$ENV{"SERVER_NAME"}; }		# For backward compatibility
	foreach my $dir ("$DIR","/etc/opt/awstats","/etc/awstats","/etc","/usr/local/etc/awstats") {
		my $searchdir=$dir;
		if (($searchdir ne "") && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
		if ($FileConfig eq "") { if (open(CONFIG,"$searchdir$PROG.$SiteConfig.conf")) { $FileConfig="$searchdir$PROG.$SiteConfig.conf"; $FileSuffix=".$SiteConfig"; } }
		if ($FileConfig eq "") { if (open(CONFIG,"$searchdir$PROG.conf"))  { $FileConfig="$searchdir$PROG.conf"; $FileSuffix=""; } }
	}
	if ($FileConfig eq "") { error("Error: Couldn't open config file \"$PROG.$SiteConfig.conf\" nor \"$PROG.conf\" : $!"); }
	&debug("Call to Read_Config_File [FileConfig=\"$FileConfig\"]");
	my $foundNotPageList=0;
	while (<CONFIG>) {
		chomp $_; s/\r//;
		if ($_ =~ /^$/) { next; }
		# Remove comments
		if ($_ =~ /^#/) { next; }					
		$_ =~ s/^([^\"]*)#.*/$1/;
		$_ =~ s/^([^\"]*\"[^\"]*\"[^\"]*)#.*/$1/;
		# Extract param and value
		#debug("$_",2);
		my @felter=split(/=/,$_,2);						
		my $param=$felter[0]||next;					# If not a param=value, try with next line
		my $value=$felter[1];
		$param =~ s/^\s+//; $param =~ s/\s+$//;
		$value =~ s/^\s+//; $value =~ s/\s+$//;
		$value =~ s/^\"//; $value =~ s/\"$//;
		# Replace __MONENV__ with value of environnement variable MONENV
		$value =~ s/__(\w+)__/$ENV{$1}/g;
		# Read main section
		if ($param =~ /^LogFile/) {
			$LogFile=$value;
			if ($LogFile =~ /%([ymdhwYMDHW]+)-(\d*)/) {
				my $timephase=$2;
				debug(" Found a time phase of $timephase hour in log file name",1);
				# Get older time
				($oldersec,$oldermin,$olderhour,$olderday,$oldermonth,$olderyear,$olderwday) = localtime($nowtime-($timephase*3600));
				$olderweekofmonth=int($olderday/7);
				$olderdaymod=$olderday%7;
				$olderwday++;
				if ($olderdaymod <= $olderwday) { if (($olderwday != 7) || ($olderdaymod != 0)) { $olderweekofmonth=$olderweekofmonth+1; } }
				if ($olderdaymod >  $olderwday) { $olderweekofmonth=$olderweekofmonth+2; }
				$olderweekofmonth = "0$olderweekofmonth";
				if ($olderyear < 100) { $olderyear+=2000; } else { $olderyear+=1900; }
				$oldersmallyear=$olderyear;$oldersmallyear =~ s/^..//;
				if (++$oldermonth < 10) { $oldermonth = "0$oldermonth"; }
				if ($olderday < 10) { $olderday = "0$olderday"; }
				if ($olderhour < 10) { $olderhour = "0$olderhour"; }
				if ($oldermin < 10) { $oldermin = "0$oldermin"; }
				if ($oldersec < 10) { $oldersec = "0$oldersec"; }
				$LogFile =~ s/%YYYY-$timephase/$olderyear/ig;
				$LogFile =~ s/%YY-$timephase/$oldersmallyear/ig;
				$LogFile =~ s/%MM-$timephase/$oldermonth/ig;
				$LogFile =~ s/%DD-$timephase/$olderday/ig;
				$LogFile =~ s/%HH-$timephase/$olderhour/ig;
				$LogFile =~ s/%WM-$timephase/$olderweekofmonth/ig;
			}
			# Replace %YYYY %YY %MM %DD %HH with current value. Kept for backward compatibility.
			$LogFile =~ s/%YYYY/$nowyear/ig;
			$LogFile =~ s/%YY/$nowsmallyear/ig;
			$LogFile =~ s/%MM/$nowmonth/ig;
			$LogFile =~ s/%DD/$nowday/ig;
			$LogFile =~ s/%HH/$nowhour/ig;
			$LogFile =~ s/%WM/$nowweekofmonth/ig;
			debug(" LogFile=$LogFile",1);
			next;
			}
		if ($param =~ /^LogFormat/)            	{ $LogFormat=$value; next; }
		if ($param =~ /^DirData/) 				{ $DirData=$value; next; }
		if ($param =~ /^DirCgi/)                { $DirCgi=$value; next; }
		if ($param =~ /^DirIcons/)              { $DirIcons=$value; next; }
		if ($param =~ /^DNSLookup/)             { $DNSLookup=$value; next; }
		if ($param =~ /^AllowToUpdateStatsFromBrowser/)	{ $AllowToUpdateStatsFromBrowser=$value; next; }
		if ($param =~ /^SiteDomain/)			{
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			$SiteDomain=$value; next;
			}
		if ($param =~ /^HostAliases/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			my @felter=split(/\s+/,$value);
			foreach my $elem (@felter)	  { push @HostAliases,$elem; }
			next;
			}
		# Read optional section
		if ($param =~ /^CreateDirDataIfNotExists/)   { $CreateDirDataIfNotExists=$value; next; }
		if ($param =~ /^PurgeLogFile/)          { $PurgeLogFile=$value; next; }
		if ($param =~ /^ArchiveLogRecords/)     { $ArchiveLogRecords=$value; next; }
		if ($param =~ /^KeepBackupOfHistoricFiles/)     { $KeepBackupOfHistoricFiles=$value; next; }
		if ($param =~ /^Lang/)                  { $Lang=$value; next; }
		if ($param =~ /^DirLang/)               { $DirLang=$value; next; }
		if ($param =~ /^DefaultFile/)           { $DefaultFile=$value; next; }
		if ($param =~ /^SkipHosts/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			my @felter=split(/\s+/,$value);
			foreach my $elem (@felter)    { push @SkipHosts,$elem; }
			next;
			}
		if ($param =~ /^SkipDNSLookupFor/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			my @felter=split(/\s+/,$value);
			foreach my $elem (@felter)    { push @SkipDNSLookupFor,$elem; }
			next;
			}
		if ($param =~ /^SkipFiles/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			my @felter=split(/\s+/,$value);
			foreach my $elem (@felter)    { push @SkipFiles,$elem; }
			next;
			}
		if ($param =~ /^OnlyFiles/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			my @felter=split(/\s+/,$value);
			foreach my $elem (@felter)    { push @OnlyFiles,$elem; }
			next;
			}
		if ($param =~ /^NotPageList/) {
			my @felter=split(/\s+/,$value);
			foreach my $elem (@felter)    { push @NotPageList,$elem; }
			$foundNotPageList=1;
			next;
			}
		if ($param =~ /^URLWithQuery/)          { $URLWithQuery=$value; next; }
		if ($param =~ /^WarningMessages/)       { $WarningMessages=$value; next; }
		if ($param =~ /^NbOfLinesForCorruptedLog/) { $NbOfLinesForCorruptedLog=$value; next; }
		if ($param =~ /^FirstDayOfWeek/)       	{ $FirstDayOfWeek=$value; next; }
		if ($param =~ /^MaxNbOfDomain/)         { $MaxNbOfDomain=$value; next; }
		if ($param =~ /^MaxNbOfHostsShown/)     { $MaxNbOfHostsShown=$value; next; }
		if ($param =~ /^MinHitHost/)            { $MinHitHost=$value; next; }
		if ($param =~ /^MaxNbOfRobotShown/)     { $MaxNbOfRobotShown=$value; next; }
		if ($param =~ /^MinHitRobot/)           { $MinHitRobot=$value; next; }
		if ($param =~ /^MaxNbOfLoginShown/)     { $MaxNbOfLoginShown=$value; next; }
		if ($param =~ /^MinHitLogin/)           { $MinHitLogin=$value; next; }
		if ($param =~ /^MaxNbOfPageShown/)      { $MaxNbOfPageShown=$value; next; }
		if ($param =~ /^MinHitFile/)            { $MinHitFile=$value; next; }
		if ($param =~ /^MaxNbOfRefererShown/)   { $MaxNbOfRefererShown=$value; next; }
		if ($param =~ /^MinHitRefer/)           { $MinHitRefer=$value; next; }
		if ($param =~ /^MaxNbOfKeywordsShown/)  { $MaxNbOfKeywordsShown=$value; next; }
		if ($param =~ /^MinHitKeyword/)         { $MinHitKeyword=$value; next; }
		if ($param =~ /^SplitSearchString/)     { $SplitSearchString=$value; next; }
		if ($param =~ /^Expires/)               { $Expires=$value; next; }
		if ($param =~ /^ShowHeader/)             { $ShowHeader=$value; next; }
		if ($param =~ /^ShowMenu/)               { $ShowMenu=$value; next; }
		if ($param =~ /^ShowMonthDayStats/)      { $ShowMonthDayStats=$value; next; }
		if ($param =~ /^ShowDaysOfWeekStats/)    { $ShowDaysOfWeekStats=$value; next; }
		if ($param =~ /^ShowHoursStats/)         { $ShowHoursStats=$value; next; }
		if ($param =~ /^ShowDomainsStats/)       { $ShowDomainsStats=$value; next; }
		if ($param =~ /^ShowHostsStats/)         { $ShowHostsStats=$value; next; }
		if ($param =~ /^ShowAuthenticatedUsers/) { $ShowAuthenticatedUsers=$value; next; }
		if ($param =~ /^ShowRobotsStats/)        { $ShowRobotsStats=$value; next; }
		if ($param =~ /^ShowPagesStats/)         { $ShowPagesStats=$value; next; }
		if ($param =~ /^ShowFileTypesStats/)     { $ShowFileTypesStats=$value; next; }
		if ($param =~ /^ShowFileSizesStats/)     { $ShowFileSizesStats=$value; next; }
		if ($param =~ /^ShowBrowsersStats/)      { $ShowBrowsersStats=$value; next; }
		if ($param =~ /^ShowOSStats/)            { $ShowOSStats=$value; next; }
		if ($param =~ /^ShowOriginStats/)        { $ShowOriginStats=$value; next; }
		if ($param =~ /^ShowKeyphrasesStats/)    { $ShowKeyphrasesStats=$value; next; }
		if ($param =~ /^ShowKeywordsStats/)      { $ShowKeywordsStats=$value; next; }
		if ($param =~ /^ShowCompressionStats/)   { $ShowCompressionStats=$value; next; }
		if ($param =~ /^ShowHTTPErrorsStats/)    { $ShowHTTPErrorsStats=$value; next; }
		if ($param =~ /^ShowFlagLinks/)         { $ShowFlagLinks=$value; next; }
		if ($param =~ /^ShowLinksOnUrl/)        { $ShowLinksOnUrl=$value; next; }
		if ($param =~ /^MaxLengthOfURL/)        { $MaxLengthOfURL=$value; next; }
		if ($param =~ /^MaxRowsInHTMLOutput/)   { $MaxRowsInHTMLOutput=$value; next; }
		if ($param =~ /^DetailedReportsOnNewWindows/) { $DetailedReportsOnNewWindows=$value; next; }
		if ($param =~ /^HTMLHeadSection/)       { $HTMLHeadSection=$value; next; }
		if ($param =~ /^HTMLEndSection/)        { $HTMLEndSection=$value; next; }
		if ($param =~ /^BarWidth/)              { $BarWidth=$value; next; }
		if ($param =~ /^BarHeight/)             { $BarHeight=$value; next; }
		if ($param =~ /^Logo$/)                 { $Logo=$value; next; }
		if ($param =~ /^LogoLink/)              { $LogoLink=$value; next; }
		if ($param =~ /^color_Background/)      { $color_Background=$value; next; }
		if ($param =~ /^color_TableTitle/)      { $color_TableTitle=$value; next; }
		if ($param =~ /^color_TableBGTitle/)    { $color_TableBGTitle=$value; next; }
		if ($param =~ /^color_TableRowTitle/)   { $color_TableRowTitle=$value; next; }
		if ($param =~ /^color_TableBGRowTitle/) { $color_TableBGRowTitle=$value; next; }
		if ($param =~ /^color_TableBG/)         { $color_TableBG=$value; next; }
		if ($param =~ /^color_TableBorder/)     { $color_TableBorder=$value; next; }
		if ($param =~ /^color_text/)            { $color_text=$value; next; }
		if ($param =~ /^color_titletext/)       { $color_titletext=$value; next; }
		if ($param =~ /^color_weekend/)         { $color_weekend=$value; next; }
		if ($param =~ /^color_link/)            { $color_link=$value; next; }
		if ($param =~ /^color_hover/)           { $color_hover=$value; next; }
		if ($param =~ /^color_u/)               { $color_u=$value; next; }
		if ($param =~ /^color_v/)               { $color_v=$value; next; }
		if ($param =~ /^color_p/)               { $color_p=$value; next; }
		if ($param =~ /^color_h/)               { $color_h=$value; next; }
		if ($param =~ /^color_k/)               { $color_k=$value; next; }
		if ($param =~ /^color_s/)               { $color_s=$value; next; }
	}
	close CONFIG;
	# If parameter NotPageList not found. Init for backward compatibility
	if (! $foundNotPageList) {
		$NotPageList[0]="gif";
		$NotPageList[1]="jpg";
		$NotPageList[2]="jpeg";
		$NotPageList[3]="png";
		$NotPageList[4]="bmp";
	}
}


#------------------------------------------------------------------------------
# Function:     Get the reference databases
# Parameter:	None
# Return value: None
# Input:		$DIR
# Output:		Arrays and Hash tables are defined 
#------------------------------------------------------------------------------
sub Read_Ref_Data {
	foreach my $file ("browsers.pl","domains.pl","operating_systems.pl","robots.pl","search_engines.pl") {
		my $FileRef="";
		foreach my $dir ("${DIR}db","./db") {
			my $searchdir=$dir;
			if (($searchdir ne "") && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
			if ($FileRef eq "") {
				if (-s "${searchdir}${file}") {
					$FileRef="${searchdir}${file}";
					&debug("Call to Read_Ref_Data [FileRef=\"$FileRef\"]");
					require "$FileRef";
				}
			}
		}
		if ($FileRef eq "") {
			my $filetext=$file; $filetext =~ s/\.pl$//; $filetext =~ s/_/ /g;
			&warning("Warning: Can't read file \"$file\" ($filetext detection will not work correctly).\nCheck if file is in ${DIR}db directory and is readable.");
		}
	}
	# Sanity check.
	if (@OSArrayID != scalar keys %OSHashID) { error("Error: Not same number of records of OSArray (".(@OSArrayID).") and/or OSHashID (".(scalar keys %OSHashID).") in source file."); }
	if (@BrowsersArrayID != scalar keys %BrowsersHashIDLib) { error("Error: Not same number of records of BrowsersArrayID (".(@BrowsersArrayID).") and/or BrowsersHashIDLib (".(scalar keys %BrowsersHashIDLib).") in source file."); }
}



#------------------------------------------------------------------------------
# Function:     Get the messages for a specified language
# Parameter:	Language id
# Input:		$DIR
# Output:		$Message table is defined in memory
#------------------------------------------------------------------------------
sub Read_Language_Data {
	my $FileLang="";
	foreach my $dir ("$DirLang","${DIR}lang","./lang") {
		my $searchdir=$dir;
		if (($searchdir ne "") && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
		if ($FileLang eq "") { if (open(LANG,"${searchdir}awstats-$_[0].txt")) { $FileLang="${searchdir}awstats-$_[0].txt"; } }
	}
	# If file not found, we try english
	foreach my $dir ("$DirLang","${DIR}lang","./lang") {
		my $searchdir=$dir;
		if (($searchdir ne "") && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
		if ($FileLang eq "") { if (open(LANG,"${searchdir}awstats-en.txt")) { $FileLang="${searchdir}awstats-en.txt"; } }
	}
	&debug("Call to Read_Language_Data [FileLang=\"$FileLang\"]");
	if ($FileLang ne "") {
		$i = 0;
		while (<LANG>) {
			chomp $_; s/\r//;
			if ($_ =~ /^PageCode/i) {
				$_ =~ s/^PageCode=//i;
				$_ =~ s/#.*//;								# Remove comments
				$_ =~ tr/\t /  /s;							# Change all blanks into " "
				$_ =~ s/^\s+//; $_ =~ s/\s+$//;
				$_ =~ s/^\"//; $_ =~ s/\"$//;
				$PageCode = $_;
			}
			if ($_ =~ /^Message/i) {
				$_ =~ s/^Message\d+=//i;
				$_ =~ s/#.*//;								# Remove comments
				$_ =~ tr/\t /  /s;							# Change all blanks into " "
				$_ =~ s/^\s+//; $_ =~ s/\s+$//;
				$_ =~ s/^\"//; $_ =~ s/\"$//;
				$Message[$i] = $_;
				$i++;
			}
		}
	}
	else {
		&warning("Warning: Can't find language files for \"$_[0]\". English will be used.");
	}
	close(LANG);
}


#------------------------------------------------------------------------------
# Function:     Get the tooltip texts for a specified language
# Parameter:	Language id
# Input:		None
# Output:		Full tooltips text
#------------------------------------------------------------------------------
sub Read_Language_Tooltip {
	my $FileLang="";
	foreach my $dir ("$DirLang","${DIR}lang","./lang") {
		my $searchdir=$dir;
		if (($searchdir ne "") && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
		if ($FileLang eq "") { if (open(LANG,"${searchdir}awstats-tt-$_[0].txt")) { $FileLang="${searchdir}awstats-tt-$_[0].txt"; } }
	}
	# If file not found, we try english
	foreach my $dir ("$DirLang","${DIR}lang","./lang") {
		my $searchdir=$dir;
		if (($searchdir ne "") && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
		if ($FileLang eq "") { if (open(LANG,"${searchdir}awstats-tt-en.txt")) { $FileLang="${searchdir}awstats-tt-en.txt"; } }
	}
	&debug("Call to Read_Language_Tooltip [FileLang=\"$FileLang\"]");
	if ($FileLang ne "") {
		my $aws_VisitTimeout = $VisitTimeOut/10000*60;
		my $aws_NbOfRobots = scalar keys %RobotHashIDLib;
		my $aws_NbOfSearchEngines = scalar keys %SearchEnginesHashIDLib;
		while (<LANG>) {
			# Search for replaceable parameters
			s/#PROG#/$PROG/;
			s/#MaxNbOfRefererShown#/$MaxNbOfRefererShown/;
			s/#VisitTimeOut#/$aws_VisitTimeout/;
			s/#RobotArray#/$aws_NbOfRobots/;
			s/#SearchEnginesArray#/$aws_NbOfSearchEngines/;
			print "$_";
		}
	}
	close(LANG);
}


#--------------------------------------------------------------------
# Input: All lobal variables
# Ouput: Change on some global variables
#--------------------------------------------------------------------
sub Check_Config {
	&debug("Call to Check_Config");
	# Main section
	if ($LogFormat =~ /^[\d]$/ && $LogFormat !~ /[1-5]/)  { error("Error: LogFormat parameter is wrong. Value is '$LogFormat' (should be 1,2,3,4,5 or a 'personalised AWtats log format string')"); }
	if ($DNSLookup !~ /[0-1]/)                            { error("Error: DNSLookup parameter is wrong. Value is '$DNSLookup' (should be 0 or 1)"); }
	if ($AllowToUpdateStatsFromBrowser !~ /[0-1]/) 	{ $AllowToUpdateStatsFromBrowser=1; }	# For compatibility, is 1 if not defined
	# Optional section
	if ($CreateDirDataIfNotExists !~ /[0-1]/)      	{ $CreateDirDataIfNotExists=0; }
	if ($PurgeLogFile !~ /[0-1]/)                 	{ $PurgeLogFile=0; }
	if ($ArchiveLogRecords !~ /[0-1]/)            	{ $ArchiveLogRecords=1; }
	if ($KeepBackupOfHistoricFiles !~ /[0-1]/)     	{ $KeepBackupOfHistoricFiles=0; }
	if (! $DefaultFile)                       		{ $DefaultFile="index.html"; }
	if ($URLWithQuery !~ /[0-1]/)                 	{ $URLWithQuery=0; }
	if ($WarningMessages !~ /[0-1]/)              	{ $WarningMessages=1; }
	if ($NbOfLinesForCorruptedLog !~ /[\d]+/ || $NbOfLinesForCorruptedLog<1)	{ $NbOfLinesForCorruptedLog=50; }
	if ($FirstDayOfWeek !~ /[0-1]/)               	{ $FirstDayOfWeek=1; }
	if ($MaxNbOfDomain !~ /^[\d]+/ || $MaxNbOfDomain<1)           		{ $MaxNbOfDomain=25; }
	if ($MaxNbOfHostsShown !~ /^[\d]+/ || $MaxNbOfHostsShown<1)       	{ $MaxNbOfHostsShown=25; }
	if ($MinHitHost !~ /^[\d]+/ || $MinHitHost<1)              			{ $MinHitHost=1; }
	if ($MaxNbOfLoginShown !~ /^[\d]+/ || $MaxNbOfLoginShown<1)       	{ $MaxNbOfLoginShown=10; }
	if ($MinHitLogin !~ /^[\d]+/ || $MinHitLogin<1)             		{ $MinHitLogin=1; }
	if ($MaxNbOfRobotShown !~ /^[\d]+/ || $MaxNbOfRobotShown<1)       	{ $MaxNbOfRobotShown=25; }
	if ($MinHitRobot !~ /^[\d]+/ || $MinHitRobot<1)             		{ $MinHitRobot=1; }
	if ($MaxNbOfPageShown !~ /^[\d]+/ || $MaxNbOfPageShown<1)        	{ $MaxNbOfPageShown=25; }
	if ($MinHitFile !~ /^[\d]+/ || $MinHitFile<1)              			{ $MinHitFile=1; }
	if ($MaxNbOfRefererShown !~ /^[\d]+/ || $MaxNbOfRefererShown<1)     { $MaxNbOfRefererShown=25; }
	if ($MinHitRefer !~ /^[\d]+/ || $MinHitRefer<1)             		{ $MinHitRefer=1; }
	if ($MaxNbOfKeywordsShown !~ /^[\d]+/ || $MaxNbOfKeywordsShown<1)	{ $MaxNbOfKeywordsShown=25; }
	if ($MinHitKeyword !~ /^[\d]+/ || $MinHitKeyword<1)           		{ $MinHitKeyword=1; }
	if ($MaxRowsInHTMLOutput !~ /^[\d]+/ || $MaxRowsInHTMLOutput<1)     { $MaxRowsInHTMLOutput=1000; }
	if ($SplitSearchString !~ /[0-1]/)          	{ $SplitSearchString=0; }
	if ($Expires !~ /^[\d]+/)                 		{ $Expires=0; }
	if ($ShowHeader !~ /[0-1]/)                   	{ $ShowHeader=1; }
	if ($ShowMenu !~ /[0-1]/)                     	{ $ShowMenu=1; }
	if ($ShowMonthDayStats !~ /[0-1]/)            	{ $ShowMonthDayStats=1; }
	if ($ShowDaysOfWeekStats !~ /[0-1]/)          	{ $ShowDaysOfWeekStats=1; }
	if ($ShowHoursStats !~ /[0-1]/)               	{ $ShowHoursStats=1; }
	if ($ShowDomainsStats !~ /[0-1]/)             	{ $ShowDomainsStats=1; }
	if ($ShowHostsStats !~ /[0-1]/)               	{ $ShowHostsStats=1; }
	if ($ShowAuthenticatedUsers !~ /[0-1]/)       	{ $ShowAuthenticatedUsers=1; }
	if ($ShowRobotsStats !~ /[0-1]/)              	{ $ShowRobotsStats=1; }
	if ($ShowPagesStats !~ /[0-1]/)               	{ $ShowPagesStats=1; }
	if ($ShowFileTypesStats !~ /[0-1]/)           	{ $ShowFileTypesStats=1; }
	if ($ShowFileSizesStats !~ /[0-1]/)           	{ $ShowFileSizesStats=1; }
	if ($ShowBrowsersStats !~ /[0-1]/)            	{ $ShowBrowsersStats=1; }
	if ($ShowOSStats !~ /[0-1]/)                  	{ $ShowOSStats=1; }
	if ($ShowOriginStats !~ /[0-1]/)              	{ $ShowOriginStats=1; }
	if ($ShowKeyphrasesStats !~ /[0-1]/)          	{ $ShowKeyphrasesStats=1; }
	if ($ShowKeywordsStats !~ /[0-1]/)            	{ $ShowKeywordsStats=1; }
	if ($ShowCompressionStats !~ /[0-1]/)         	{ $ShowCompressionStats=1; }
	if ($ShowHTTPErrorsStats !~ /[0-1]/)          	{ $ShowHTTPErrorsStats=1; }
	if ($ShowLinksOnURL !~ /[0-1]/)               	{ $ShowLinksOnURL=1; }
	if ($MaxLengthOfURL !~ /^[\d+]/ || $MaxLengthOfURL<1) { $MaxLengthOfURL=72; }
	if ($DetailedReportsOnNewWindows !~ /[0-1]/)  	{ $DetailedReportsOnNewWindows=1; }
	if ($BarWidth !~ /^[\d]+/ || $BarWidth<1) 		{ $BarWidth=260; }
	if ($BarHeight !~ /^[\d]+/ || $BarHeight<1)		{ $BarHeight=180; }
	if (! $Logo)    	                          	{ $Logo="awstats_logo1.png"; }
	if (! $LogoLink)  	                        	{ $LogoLink="http://awstats.sourceforge.net"; }
	$color_Background =~ s/#//g; if ($color_Background !~ /^[0-9|A-Z]+$/i)           { $color_Background="FFFFFF";	}
	$color_TableBGTitle =~ s/#//g; if ($color_TableBGTitle !~ /^[0-9|A-Z]+$/i)       { $color_TableBGTitle="CCCCDD"; }
	$color_TableTitle =~ s/#//g; if ($color_TableTitle !~ /^[0-9|A-Z]+$/i)           { $color_TableTitle="000000"; }
	$color_TableBG =~ s/#//g; if ($color_TableBG !~ /^[0-9|A-Z]+$/i)                 { $color_TableBG="CCCCDD"; }
	$color_TableRowTitle =~ s/#//g; if ($color_TableRowTitle !~ /^[0-9|A-Z]+$/i)     { $color_TableRowTitle="FFFFFF"; }
	$color_TableBGRowTitle =~ s/#//g; if ($color_TableBGRowTitle !~ /^[0-9|A-Z]+$/i) { $color_TableBGRowTitle="ECECEC"; }
	$color_TableBorder =~ s/#//g; if ($color_TableBorder !~ /^[0-9|A-Z]+$/i)         { $color_TableBorder="ECECEC"; }
	$color_text =~ s/#//g; if ($color_text !~ /^[0-9|A-Z]+$/i)           			 { $color_text="000000"; }
	$color_titletext =~ s/#//g; if ($color_titletext !~ /^[0-9|A-Z]+$/i) 			 { $color_titletext="000000"; }
	$color_weekend =~ s/#//g; if ($color_weekend !~ /^[0-9|A-Z]+$/i)     			 { $color_weekend="EAEAEA"; }
	$color_link =~ s/#//g; if ($color_link !~ /^[0-9|A-Z]+$/i)           			 { $color_link="0011BB"; }
	$color_hover =~ s/#//g; if ($color_hover !~ /^[0-9|A-Z]+$/i)         			 { $color_hover="605040"; }
	$color_u =~ s/#//g; if ($color_u !~ /^[0-9|A-Z]+$/i)                 			 { $color_u="FF9933"; }
	$color_v =~ s/#//g; if ($color_v !~ /^[0-9|A-Z]+$/i)                 			 { $color_v="F3F300"; }
	$color_p =~ s/#//g; if ($color_p !~ /^[0-9|A-Z]+$/i)                 			 { $color_p="4477DD"; }
	$color_h =~ s/#//g; if ($color_h !~ /^[0-9|A-Z]+$/i)                 			 { $color_h="66F0FF"; }
	$color_k =~ s/#//g; if ($color_k !~ /^[0-9|A-Z]+$/i)                 			 { $color_k="339944"; }
	$color_s =~ s/#//g; if ($color_s !~ /^[0-9|A-Z]+$/i)                 			 { $color_s="8888DD"; }
	# Default value	for Messages
	if (! $Message[0]) { $Message[0]="Unknown"; }
	if (! $Message[1]) { $Message[1]="Unknown (unresolved ip)"; }
	if (! $Message[2]) { $Message[2]="Others"; }
	if (! $Message[3]) { $Message[3]="View details"; }
	if (! $Message[4]) { $Message[4]="Day"; }
	if (! $Message[5]) { $Message[5]="Month"; }
	if (! $Message[6]) { $Message[6]="Year"; }
	if (! $Message[7]) { $Message[7]="Statistics of"; }
	if (! $Message[8]) { $Message[8]="First visit"; }
	if (! $Message[9]) { $Message[9]="Last visit"; }
	if (! $Message[10]) { $Message[10]="Number of visits"; }
	if (! $Message[11]) { $Message[11]="Unique visitors"; }
	if (! $Message[12]) { $Message[12]="Visit"; }
	if (! $Message[13]) { $Message[13]="different keywords"; }
	if (! $Message[14]) { $Message[14]="Search"; }
	if (! $Message[15]) { $Message[15]="Percent"; }
	if (! $Message[16]) { $Message[16]="Traffic"; }
	if (! $Message[17]) { $Message[17]="Domains/Countries"; }
	if (! $Message[18]) { $Message[18]="Visitors"; }
	if (! $Message[19]) { $Message[19]="Pages-URL"; }
	if (! $Message[20]) { $Message[20]="Hours"; }
	if (! $Message[21]) { $Message[21]="Browsers"; }
	if (! $Message[22]) { $Message[22]="HTTP Errors"; }
	if (! $Message[23]) { $Message[23]="Referers"; }
	if (! $Message[24]) { $Message[24]="Search&nbsp;Keywords"; }
	if (! $Message[25]) { $Message[25]="Visitors domains/countries"; }
	if (! $Message[26]) { $Message[26]="hosts"; }
	if (! $Message[27]) { $Message[27]="pages"; }
	if (! $Message[28]) { $Message[28]="different pages"; }
	if (! $Message[29]) { $Message[29]="Viewed pages"; }
	if (! $Message[30]) { $Message[30]="Other words"; }
	if (! $Message[31]) { $Message[31]="Pages not found"; }
	if (! $Message[32]) { $Message[32]="HTTP Error codes"; }
	if (! $Message[33]) { $Message[33]="Netscape versions"; }
	if (! $Message[34]) { $Message[34]="IE versions"; }
	if (! $Message[35]) { $Message[35]="Last Update"; }
	if (! $Message[36]) { $Message[36]="Connect to site from"; }
	if (! $Message[37]) { $Message[37]="Origin"; }
	if (! $Message[38]) { $Message[38]="Direct address / Bookmarks"; }
	if (! $Message[39]) { $Message[39]="Origin unknown"; }
	if (! $Message[40]) { $Message[40]="Links from an Internet Search Engine"; }
	if (! $Message[41]) { $Message[41]="Links from an external page (other web sites except search engines)"; }
	if (! $Message[42]) { $Message[42]="Links from an internal page (other page on same site)"; }
	if (! $Message[43]) { $Message[43]="Keywords used on search engines"; }
	if (! $Message[44]) { $Message[44]="Kb"; }
	if (! $Message[45]) { $Message[45]="Unresolved IP Address"; }
	if (! $Message[46]) { $Message[46]="Unknown OS (Referer field)"; }
	if (! $Message[47]) { $Message[47]="Required but not found URLs (HTTP code 404)"; }
	if (! $Message[48]) { $Message[48]="IP Address"; }
	if (! $Message[49]) { $Message[49]="Error&nbsp;Hits"; }
	if (! $Message[50]) { $Message[50]="Unknown browsers (Referer field)"; }
	if (! $Message[51]) { $Message[51]="Visiting robots"; }
	if (! $Message[52]) { $Message[52]="visits/visitor"; }
	if (! $Message[53]) { $Message[53]="Robots/Spiders visitors"; }
	if (! $Message[54]) { $Message[54]="Free realtime logfile analyzer for advanced web statistics"; }
	if (! $Message[55]) { $Message[55]="of"; }
	if (! $Message[56]) { $Message[56]="Pages"; }
	if (! $Message[57]) { $Message[57]="Hits"; }
	if (! $Message[58]) { $Message[58]="Versions"; }
	if (! $Message[59]) { $Message[59]="Operating Systems"; }
	if (! $Message[60]) { $Message[60]="Jan"; }
	if (! $Message[61]) { $Message[61]="Feb"; }
	if (! $Message[62]) { $Message[62]="Mar"; }
	if (! $Message[63]) { $Message[63]="Apr"; }
	if (! $Message[64]) { $Message[64]="May"; }
	if (! $Message[65]) { $Message[65]="Jun"; }
	if (! $Message[66]) { $Message[66]="Jul"; }
	if (! $Message[67]) { $Message[67]="Aug"; }
	if (! $Message[68]) { $Message[68]="Sep"; }
	if (! $Message[69]) { $Message[69]="Oct"; }
	if (! $Message[70]) { $Message[70]="Nov"; }
	if (! $Message[71]) { $Message[71]="Dec"; }
	if (! $Message[72]) { $Message[72]="Navigation"; }
	if (! $Message[73]) { $Message[73]="Files type"; }
	if (! $Message[74]) { $Message[74]="Update now"; }
	if (! $Message[75]) { $Message[75]="Bytes"; }
	if (! $Message[76]) { $Message[76]="Back to main page"; }
	if (! $Message[77]) { $Message[77]="Top"; }
	if (! $Message[78]) { $Message[78]="dd mmm yyyy - HH:MM"; }
	if (! $Message[79]) { $Message[79]="Filter"; }
	if (! $Message[80]) { $Message[80]="Full list"; }
	if (! $Message[81]) { $Message[81]="Hosts"; }
	if (! $Message[82]) { $Message[82]="Known"; }
	if (! $Message[83]) { $Message[83]="Robots"; }
	if (! $Message[84]) { $Message[84]="Sun"; }
	if (! $Message[85]) { $Message[85]="Mon"; }
	if (! $Message[86]) { $Message[86]="Tue"; }
	if (! $Message[87]) { $Message[87]="Wed"; }
	if (! $Message[88]) { $Message[88]="Thu"; }
	if (! $Message[89]) { $Message[89]="Fri"; }
	if (! $Message[90]) { $Message[90]="Sat"; }
	if (! $Message[91]) { $Message[91]="Days of week"; }
	if (! $Message[92]) { $Message[92]="Who"; }
	if (! $Message[93]) { $Message[93]="When"; }
	if (! $Message[94]) { $Message[94]="Authenticated users"; }
	if (! $Message[95]) { $Message[95]="Min"; }
	if (! $Message[96]) { $Message[96]="Average"; }
	if (! $Message[97]) { $Message[97]="Max"; }
	if (! $Message[98]) { $Message[98]="Web compression"; }
	if (! $Message[99]) { $Message[99]="Bandwith saved"; }
	if (! $Message[100]) { $Message[100]="Before compression"; }
	if (! $Message[101]) { $Message[101]="After compression"; }
	if (! $Message[102]) { $Message[102]="Total"; }
	if (! $Message[103]) { $Message[103]="different keyphrases"; }
	if (! $Message[104]) { $Message[104]="Entry pages"; }
	if (! $Message[105]) { $Message[105]="Code"; }
	if (! $Message[106]) { $Message[106]="Average size"; }
	if (! $Message[107]) { $Message[107]="Links from a NewsGroup"; }
	# Check if DirData is OK
	if (! -d $DirData) {
		if ($CreateDirDataIfNotExists) {
			debug(" Make directory $DirData",2);
			my $mkdirok=mkdir "$DirData", 0666;
			if (! $mkdirok) { error("Error: $PROG failed to create directory DirData (DirData=\"$DirData\", CreateDirDataIfNotExists=$CreateDirDataIfNotExists)."); }
		}
		else {
			error("Error: AWStats database directory defined in config file by 'DirData' parameter ($DirData) does not exist or is not writable.");
		}
	}
}

#--------------------------------------------------------------------
# Input: year,month,0|1		(0=read only 1st part, 1=read all file)
#--------------------------------------------------------------------
sub Read_History_File {
	my $year=sprintf("%04i",shift);
	my $month=sprintf("%02i",shift);
	my $part=shift;	# If part=0 wee need only TotalVisits, LastUpdate, BEGIN_TIME section and BEGIN_VISITOR
	# In standard use of AWStats, the DayRequired variable is always empty
	if ($DayRequired) { &debug("Call to Read_History_File [$year,$month,$part] ($DayRequired)"); }
	else { &debug("Call to Read_History_File [$year,$month,$part]"); }
	if ($HistoryFileAlreadyRead{"$year$month$DayRequired"}) {				# Protect code to invoke function only once for each month/year
		&debug(" Already loaded");
		return 0;
		}
	$HistoryFileAlreadyRead{"$year$month$DayRequired"}=1;					# Protect code to invoke function only once for each month/year
	if (! -s "$DirData/$PROG$DayRequired$month$year$FileSuffix.txt") {
		# If file not exists, return
		&debug(" No history file");
		return 0;
	}

	# If session for read (no update), file can be open with share. So POSSIBLE CHANGE HERE	
	open(HISTORY,"$DirData/$PROG$DayRequired$month$year$FileSuffix.txt") || error("Error: Couldn't open for read file \"$DirData/$PROG$DayRequired$month$year$FileSuffix.txt\" : $!");	# Month before Year kept for backward compatibility
	$MonthUnique{$year.$month}=0; $MonthPages{$year.$month}=0; $MonthHits{$year.$month}=0; $MonthBytes{$year.$month}=0; $MonthHostsKnown{$year.$month}=0; $MonthHostsUnknown{$year.$month}=0;
	
	my $versionmaj=$versionmin=0;
	my $countlines=0;
	while (<HISTORY>) {
		chomp $_; s/\r//; $countlines++;
		# Analyze config line
		if ($_ =~ /^AWSTATS DATA FILE (\d+).(\d+)/) {
			$versionmaj=$1; $versionmin=$2;
			debug(" data file version is $versionmaj.$versionmin",2);
		}
		my @field=split(/\s+/,$_);
		if ($field[0] eq "FirstTime")       { $FirstTime{$year.$month}=int($field[1]); next; }
	    if ($field[0] eq "LastLine")        { if ($LastLine{$year.$month} < int($field[1])) { $LastLine{$year.$month}=int($field[1]); }; next; }
		if ($field[0] eq "FirstTime")       { $FirstTime{$year.$month}=int($field[1]); next; }
	    if ($field[0] eq "LastTime")        { if ($LastTime{$year.$month} < int($field[1])) { $LastTime{$year.$month}=int($field[1]); }; next; }
		if ($field[0] eq "TotalVisits")     { $MonthVisits{$year.$month}=int($field[1]); next; }
	    if ($field[0] eq "LastUpdate")      {
	    	if ($LastUpdate{$year.$month} < $field[1]) {
		    	$LastUpdate{$year.$month}=int($field[1]);
		    	#$LastUpdateLinesRead{$year.$month}=int($field[2]);
		    	#$LastUpdateNewLinesRead{$year.$month}=int($field[3]);
		    	#$LastUpdateLinesCorrupted{$year.$month}=int($field[4]); 
		    };
	    	next;
	    }

		# Following data are loaded or not depending on $part parameter
		if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=xxx/i)) {
	        if ($field[0] eq "From0") { $_from_p[0]+=$field[1]; $_from_h[0]+=$field[2]; next; }
	        if ($field[0] eq "From1") { $_from_p[1]+=$field[1]; $_from_h[1]+=$field[2]; next; }
	        if ($field[0] eq "From2") { $_from_p[2]+=$field[1]; $_from_h[2]+=$field[2]; next; }
	        if ($field[0] eq "From3") { $_from_p[3]+=$field[1]; $_from_h[3]+=$field[2]; next; }
	        if ($field[0] eq "From4") { $_from_p[4]+=$field[1]; $_from_h[4]+=$field[2]; next; }
	        if ($field[0] eq "From5") { $_from_p[5]+=$field[1]; $_from_h[5]+=$field[2]; next; }
			# Next lines are to read old awstats history files ("Fromx" section was "HitFromx" in such files)
	        if ($field[0] eq "HitFrom0") { $_from_p[0]+=0; $_from_h[0]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom1") { $_from_p[1]+=0; $_from_h[1]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom2") { $_from_p[2]+=0; $_from_h[2]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom3") { $_from_p[3]+=0; $_from_h[3]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom4") { $_from_p[4]+=0; $_from_h[4]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom5") { $_from_p[5]+=0; $_from_h[5]+=$field[1]; next; }
		}
	    if ($field[0] eq "BEGIN_TIME")      {
			&debug(" Begin of TIME section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section TIME). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_TIME") {
				$count++;
				# We always read this to build the month graph (MonthPages, MonthHits, MonthBytes)
		    	$MonthPages{$year.$month}+=int($field[1]); $MonthHits{$year.$month}+=int($field[2]); $MonthBytes{$year.$month}+=int($field[3]);
				if ($part) {	# TODO ? used to build total
					$countloaded++;
		        	if ($field[1]) { $_time_p[$field[0]]+=int($field[1]); }
		        	if ($field[2]) { $_time_h[$field[0]]+=int($field[2]); }
		        	if ($field[3]) { $_time_k[$field[0]]+=int($field[3]); }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section TIME). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of TIME section ($count entries, $countloaded loaded)");
			next;
	    }
	    if ($field[0] eq "BEGIN_DAY")      {
			&debug(" Begin of DAY section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section DAY). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_DAY" ) {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=xxx/i)) {
					$countloaded++;
					if ($field[1]) { $DayPages{$field[0]}=int($field[1]); }
					if ($field[2]) { $DayHits{$field[0]}=int($field[2]); }
					if ($field[3]) { $DayBytes{$field[0]}=int($field[3]); }
					if ($field[4]) { $DayVisits{$field[0]}=int($field[4]); }
					if ($field[5]) { $DayUnique{$field[0]}=int($field[5]); }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section DAY). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of DAY section ($count entries, $countloaded loaded)");
			next;
	    }
	    if ($field[0] eq "BEGIN_VISITOR")   {
			&debug(" Begin of VISITOR section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section VISITOR). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_VISITOR") {
				$count++;
				# We always read this to build the month graph (MonthUnique, MonthHostsKnown, MonthHostsUnknown)
		    	if ($field[0] ne "Unknown") {	# If and else is kept for backward compatibility
		    		if (($field[1]||0) > 0) { $MonthUnique{$year.$month}++; }
					if ($field[0] !~ /^[\d]+\.[\d]+\.[\d]+\.[\d]+$/) { $MonthHostsKnown{$year.$month}++; }
					else { $MonthHostsUnknown{$year.$month}++; }
				}
		    	else {
		    		$MonthUnique{$year.$month}++;
		    		$MonthHostsUnknown{$year.$month}++;
		    	}
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=allhosts/i || $QueryString =~ /output=lasthosts/i || $QueryString =~ /output=unknownip/i)) {
					# Data required:
					# update 				 need to load all
					# noupdate+
					#  main page for year	 need to load all
					#  main page for month	 need to load MaxNbOfHostsShown pages and >= MinHitHost
					#  lastconnect for year  need to load all
					#  lastconnect for month need to load all
					#  unknownip for year	 need to load all ip
					#  unknownip for month	 need to load ip with >= MinHitHost
					my $loadrecord=0;
					if ($UpdateStats) {
						$loadrecord=1;
					}
					else {
						if ($QueryString =~ /output=allhosts/i || $QueryString =~ /output=lasthosts/i) { $loadrecord=1;	}
						if ($MonthRequired eq "year" || $field[2] >= $MinHitHost) {
							if ($QueryString =~ /output=unknownip/i && ($field[0] =~ /^[\d]+\.[\d]+\.[\d]+\.[\d]+$/)) { $loadrecord=1; }
							if ($QueryString !~ /output=/i && ($MonthRequired eq "year" || $countloaded < $MaxNbOfHostsShown)) { $loadrecord=1; }
						}
					}
					if ($loadrecord) {
						if ($field[1]) { $_hostmachine_p{$field[0]}+=$field[1]; }
		        		if ($field[2]) { $_hostmachine_h{$field[0]}+=$field[2]; }
		        		if ($field[3]) { $_hostmachine_k{$field[0]}+=$field[3]; }
		        		if (! $_hostmachine_l{$field[0]} && $field[4]) { $_hostmachine_l{$field[0]}=int($field[4]); }
						$countloaded++;
					}
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section VISITOR). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of VISITOR section ($count entries, $countloaded loaded)");
			next;
    	}
	    if ($field[0] eq "BEGIN_LOGIN")   {
			&debug(" Begin of LOGIN section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section LOGIN). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_LOGIN") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=xxx/i)) {
					$countloaded++;
					if ($field[1]) { $_login_p{$field[0]}+=$field[1]; }
			    	if ($field[2]) { $_login_h{$field[0]}+=$field[2]; }
			    	if ($field[3]) { $_login_k{$field[0]}+=$field[3]; }
		        	if (! $_login_l{$field[0]} && $field[4]) { $_login_l{$field[0]}=int($field[4]); }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section LOGIN). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of LOGIN section ($count entries, $countloaded loaded)");
			next;
    	}
	    if ($field[0] eq "BEGIN_DOMAIN")   {
			&debug(" Begin of DOMAIN section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section DOMAIN). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_DOMAIN") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=xxx/i)) {
					$countloaded++;
					if ($field[1]) { $_domener_p{$field[0]}+=$field[1]; }
					if ($field[2]) { $_domener_h{$field[0]}+=$field[2]; }
					if ($field[3]) { $_domener_k{$field[0]}+=$field[3]; }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section DOMAIN). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of DOMAIN section ($count entries, $countloaded loaded)");
			next;
		}
	    if ($field[0] eq "BEGIN_BROWSER")   {
			&debug(" Begin of BROWSER section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section BROWSER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_BROWSER") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=browserdetail/i)) {
					$countloaded++;
		        	if ($field[1]) { $_browser_h{$field[0]}+=$field[1]; }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section BROWSER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of BROWSER section ($count entries, $countloaded loaded)");
			next;
		}
	    if ($field[0] eq "BEGIN_MSIEVER")   {
			&debug(" Begin of MSIEVER section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section MSIEVER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_MSIEVER") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=browserdetail/i)) {
					$countloaded++;
		        	if ($field[1]) { $_msiever_h[$field[0]]+=$field[1]; }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section MSIEVER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of MSIEVER section ($count entries, $countloaded loaded)");
			next;
		}
	    if ($field[0] eq "BEGIN_NSVER")   {
			&debug(" Begin of NSVER section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section NSVER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_NSVER") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=browserdetail/i)) {
					$countloaded++;
		        	if ($field[1]) { $_nsver_h[$field[0]]+=$field[1]; }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section NSVER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of NSVER section ($count entries, $countloaded loaded)");
			next;
		}
	    if ($field[0] eq "BEGIN_OS")   {
			&debug(" Begin of OS section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section OS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_OS") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=xxx/i)) {
					$countloaded++;
		        	if ($field[1]) { $_os_h{$field[0]}+=$field[1]; }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section OS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of OS section ($count entries, $countloaded loaded)");
			next;
		}
	    if ($field[0] eq "BEGIN_UNKNOWNREFERER")   {
			&debug(" Begin of UNKNOWNREFERER section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section UNKNOWNREFERER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_UNKNOWNREFERER") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=unknownreferer/i)) {
					$countloaded++;
					if (! $_unknownreferer_l{$field[0]}) { $_unknownreferer_l{$field[0]}=int($field[1]); }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section UNKNOWNREFERER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of UNKNOWNREFERER section ($count entries, $countloaded loaded)");
			next;
		}
	    if ($field[0] eq "BEGIN_UNKNOWNREFERERBROWSER")   {
			&debug(" Begin of UNKNOWNREFERERBROWSER section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section UNKNOWNREFERERBROWSER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_UNKNOWNREFERERBROWSER") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=unknownrefererbrowser/i)) {
					$countloaded++;
		        	if (! $_unknownrefererbrowser_l{$field[0]}) { $_unknownrefererbrowser_l{$field[0]}=int($field[1]); }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section UNKNOWNREFERERBROWSER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of UNKNOWNREFERERBROWSER section ($count entries, $countloaded loaded)");
			next;
		}
	    if ($field[0] eq "BEGIN_ROBOT")   {
			&debug(" Begin of ROBOT section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section ROBOT). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_ROBOT") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=xxx/i)) {
					$countloaded++;
					if ($field[1]) { $_robot_h{$field[0]}+=$field[1]; }
		        	if (! $_robot_l{$field[0]}) { $_robot_l{$field[0]}=int($field[2]); }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section ROBOT). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of ROBOT section ($count entries, $countloaded loaded)");
			next;
		}
		if ($field[0] eq "BEGIN_SIDER")  {
			&debug(" Begin of SIDER section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section SIDER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_SIDER") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=urldetail/i)) {
					# Data required:
					# update 				need to load all pages - TotalDiffetentPages could be counted but is not
					# noupdate+
					#  main page for year	need to load all pages - TotalDiffetentPages could be counted but is not
					#  main page for month	need to load MaxNbOfPageShown pages and >= MinHitFile - TotalDiffetentPages can be counted and is
					#  urldetail for year	need to load all pages with filter ok - TotalDiffetentPages could be counted if no filter but is not
					#  urldetail for month	need to load all pages with filter ok and >= MinHitFile - TotalDiffetentPages can be counted and is
					my $loadrecord=0;
					if ($UpdateStats) {
						$loadrecord=1;
					}
					else {
						if ($QueryString !~ /output=/i) {
							if ($MonthRequired eq "year") { $loadrecord=1; }
							else { 
								if ($countloaded < $MaxNbOfPageShown && $field[1] >= $MinHitFile) { $loadrecord=1; }
								$TotalDifferentPages++;
							}	
						}
						if ($QueryString =~ /output=urldetail/i) {
							if ($MonthRequired eq "year" ) { 
								if (!$URLFilter || $field[0] =~ /$URLFilter/) { $loadrecord=1; }
							}
							else { 
								if ((!$URLFilter || $field[0] =~ /$URLFilter/) && $field[1] >= $MinHitFile) { $loadrecord=1; }
								$TotalDifferentPages++;
							}
						}
						# Posssibilite de mettre if ($URLFilter && $field[0] =~ /$URLFilter/) mais il faut gerer TotalPages de la meme maniere
						if ($versionmaj < 4) {
							$TotalEntries+=($field[2]||0);
						}
						else {
							$TotalBytesPages+=($field[2]||0);
							$TotalEntries+=($field[3]||0);
						}
					}
					if ($loadrecord) {					
						if ($field[1]) { $_url_p{$field[0]}+=$field[1]; }
						if ($versionmaj < 4) {
							if ($field[2]) { $_url_e{$field[0]}+=$field[2]; }
							$_url_k{$field[0]}=0;
						}
						else {
							if ($field[2]) { $_url_k{$field[0]}+=$field[2]; } 
							if ($field[3]) { $_url_e{$field[0]}+=$field[3]; } 
						}
						$countloaded++;
					}
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section SIDER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of SIDER section ($count entries, $countloaded loaded)");
			next;
		}
	    if ($field[0] eq "BEGIN_FILETYPES")   {
			&debug(" Begin of FILETYPES section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section FILETYPES). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_FILETYPES") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=xxx/i)) {
					$countloaded++;
					if ($field[1]) { $_filetypes_h{$field[0]}+=$field[1]; }
					if ($field[2]) { $_filetypes_k{$field[0]}+=$field[2]; }
					if ($field[3]) { $_filetypes_gz_in{$field[0]}+=$field[3]; }
					if ($field[4]) { $_filetypes_gz_out{$field[0]}+=$field[4]; }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section FILETYPES). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of FILETYPES section ($count entries, $countloaded loaded)");
			next;
    	}
	    if ($field[0] eq "BEGIN_PAGEREFS")   {
			&debug(" Begin of PAGEREFS section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section PAGEREFS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_PAGEREFS") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=externalreferers/i)) {
					$countloaded++;
					if ($field[1]) { $_pagesrefs_h{$field[0]}+=int($field[1]); }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section PAGEREFS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of PAGEREFS section ($count entries, $countloaded loaded)");
			next;
    	}
		if ($field[0] eq "BEGIN_SEREFERRALS")   {
			&debug(" Begin of SEREFERRALS section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section SEREFERRALS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_SEREFERRALS") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=xxx/i)) {
					$countloaded++;
		        	if ($field[1]) { $_se_referrals_h{$field[0]}+=$field[1]; }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section SEREFERRALS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of SEREFERRALS section ($count entries, $countloaded loaded)");
			next;
    	}
	    if ($field[0] eq "BEGIN_SEARCHWORDS")   {
			&debug(" Begin of SEARCHWORDS section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section SEARCHWORDS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_SEARCHWORDS") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=allkeyphrases/i)) {
					my $loadrecord=0;
					if ($UpdateStats) {
						$loadrecord=1;
					}
					else {
						if ($QueryString !~ /output=/i) {
							if ($MonthRequired eq "year") { $loadrecord=1; }
							else { 
								if ($countloaded < $MaxNbOfKeywordsShown && $field[1] >= $MinHitKeyword) { $loadrecord=1; }
								$TotalDifferentKeyphrases++;
								$TotalKeyphrases+=($field[1]||0);
							}	
						}
						if ($QueryString =~ /output=allkeyphrases/i) {
							if ($MonthRequired eq "year" ) { 
								$loadrecord=1;
							}
							else { 
								if ($field[1] >= $MinHitKeyword) { $loadrecord=1; }
								$TotalDifferentKeyphrases++;
								$TotalKeyphrases+=($field[1]||0);
							}
						}
					}
					if ($loadrecord) {					
						if ($field[1]) { $_keyphrases{$field[0]}+=$field[1]; }
						$countloaded++;
					}
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section SEARCHWORDS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of SEARCHWORDS section ($count entries, $countloaded loaded)");
			next;
    	}
	    if ($field[0] eq "BEGIN_ERRORS")   {
			&debug(" Begin of ERRORS section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section ERRORS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_ERRORS") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=xxx/i)) {
					$countloaded++;
		        	if ($field[1]) { $_errors_h{$field[0]}+=$field[1]; }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section ERRORS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of ERRORS section ($count entries, $countloaded loaded)");
			next;
		}
	    if ($field[0] eq "BEGIN_SIDER_404")   {
			&debug(" Begin of SIDER_404 section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section SIDER_404). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
			my @field=split(/\s+/,$_); $countlines++;
			my $count=0;my $countloaded=0;
			while ($field[0] ne "END_SIDER_404") {
				$count++;
				if ($part && ($UpdateStats || $QueryString !~ /output=/i || $QueryString =~ /output=errors404/i)) {
					$countloaded++;
					if ($field[1]) { $_sider404_h{$field[0]}+=$field[1]; }
					if ($UpdateStats || $QueryString =~ /output=errors404/i) {
						if ($field[2]) { $_referer404_h{$field[0]}=$field[2]; }
					}
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section SIDER_404). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_); $countlines++;
			}
			&debug(" End of SIDER_404 section ($count entries, $countloaded loaded)");
			next;
		}
	}
	close HISTORY;
	if (! $LastLine{$year.$month}) { $LastLine{$year.$month}=$LastTime{$year.$month}; }		# For backward compatibility, if LastLine does not exist
}

#--------------------------------------------------------------------
# Function:    Show flags for 5 major languages
# Input:       Year, Month
#--------------------------------------------------------------------
sub Save_History_File {
	my $year=sprintf("%04i",shift);
	my $month=sprintf("%02i",shift);
	&debug("Call to Save_History_File [$year,$month]");
	open(HISTORYTMP,">$DirData/$PROG$month$year$FileSuffix.tmp.$$") || error("Error: Couldn't open file \"$DirData/$PROG$month$year$FileSuffix.tmp.$$\" : $!");	# Month before Year kept for backward compatibility

	print HISTORYTMP "AWSTATS DATA FILE $VERSION\n";
	print HISTORYTMP "# If you remove this file, all statistics for date $year-$month will be lost/reset.\n";
	print HISTORYTMP "\n";
	print HISTORYTMP "LastLine $LastLine{$year.$month}\n";
	print HISTORYTMP "FirstTime $FirstTime{$year.$month}\n";
	print HISTORYTMP "LastTime $LastTime{$year.$month}\n";
	if ($LastUpdate{$year.$month} < int("$nowyear$nowmonth$nowday$nowhour$nowmin$nowsec")) { $LastUpdate{$year.$month}=int("$nowyear$nowmonth$nowday$nowhour$nowmin$nowsec"); }
	print HISTORYTMP "LastUpdate $LastUpdate{$year.$month} $NbOfLinesRead $NbOfNewLinesProcessed $NbOfLinesCorrupted\n";
	print HISTORYTMP "TotalVisits $MonthVisits{$year.$month}\n";

	# When
	print HISTORYTMP "BEGIN_DAY\n";
    foreach my $key (keys %DayHits) {
    	if ($key =~ /^$year$month/) {	# Found a day entry of the good month
			my $page=$DayPages{$key}||0;
			my $hits=$DayHits{$key}||0;
			my $bytes=$DayBytes{$key}||0;
			my $visits=$DayVisits{$key}||0;
			my $unique=$DayUnique{$key}||"";
    		print HISTORYTMP "$key $page $hits $bytes $visits $unique\n";
    		next;
    	}
   	}
    print HISTORYTMP "END_DAY\n";
	print HISTORYTMP "BEGIN_TIME\n";
	for (my $ix=0; $ix<=23; $ix++) { print HISTORYTMP "$ix ".int($_time_p[$ix])." ".int($_time_h[$ix])." ".int($_time_k[$ix])."\n"; next; }
	print HISTORYTMP "END_TIME\n";

	# Who
	print HISTORYTMP "BEGIN_DOMAIN\n";
	foreach my $key (keys %_domener_h) {
		my $page=$_domener_p{$key}||0;
		my $bytes=$_domener_k{$key}||0;		# ||0 could be commented to reduce history file size
		print HISTORYTMP "$key $page $_domener_h{$key} $bytes\n"; next;
	}
	print HISTORYTMP "END_DOMAIN\n";
	print HISTORYTMP "BEGIN_VISITOR\n";
	&BuildKeyList($MaxNbOfHostsShown,$MinHitHost,\%_hostmachine_h,\%_hostmachine_p);
	my %keysinkeylist=();
	foreach my $key (@keylist) {
		$keysinkeylist{$key}=1;
		my $page=$_hostmachine_p{$key}||0;
		my $bytes=$_hostmachine_k{$key}||0;
		my $lastaccess=$_hostmachine_l{$key}||"";
		print HISTORYTMP "$key $page $_hostmachine_h{$key} $bytes $lastaccess\n"; next;
	}
	foreach my $key (keys %_hostmachine_h) {
		if ($keysinkeylist{$key}) { next; }
		my $page=$_hostmachine_p{$key}||0;
		my $bytes=$_hostmachine_k{$key}||0;
		my $lastaccess=$_hostmachine_l{$key}||"";
		print HISTORYTMP "$key $page $_hostmachine_h{$key} $bytes $lastaccess\n"; next;
	}
	print HISTORYTMP "END_VISITOR\n";
	print HISTORYTMP "BEGIN_LOGIN\n";
	foreach my $key (keys %_login_h) { print HISTORYTMP "$key ".int($_login_p{$key})." ".int($_login_h{$key})." ".int($_login_k{$key})." $_login_l{$key}\n"; next; }
	print HISTORYTMP "END_LOGIN\n";
	print HISTORYTMP "BEGIN_ROBOT\n";
	foreach my $key (keys %_robot_h) { print HISTORYTMP "$key ".int($_robot_h{$key})." $_robot_l{$key}\n"; next; }
	print HISTORYTMP "END_ROBOT\n";

	# Navigation
	# We save page list in score sorted order to get a -output faster and with less use of memory.
	print HISTORYTMP "BEGIN_SIDER\n";
	&BuildKeyList($MaxNbOfPageShown,$MinHitFile,\%_url_p,\%_url_p);
	%keysinkeylist=();
	foreach my $key (@keylist) {
		$keysinkeylist{$key}=1;
		$newkey=$key;
		$newkey =~ s/([^:])\/\//$1\//g;		# Because some targeted url were taped with 2 / (Ex: //rep//file.htm). We must keep http://rep/file.htm
		my $entry=$_url_e{$key}||"";
		print HISTORYTMP "$newkey ".int($_url_p{$key}||0)." ".int($_url_k{$key}||0)." $entry\n"; next;
	}
	foreach my $key (keys %_url_p) {
		if ($keysinkeylist{$key}) { next; }
		$newkey=$key;
		$newkey =~ s/([^:])\/\//$1\//g;		# Because some targeted url were taped with 2 / (Ex: //rep//file.htm). We must keep http://rep/file.htm
		my $entry=$_url_e{$key}||"";
		print HISTORYTMP "$newkey ".int($_url_p{$key}||0)." ".int($_url_k{$key}||0)." $entry\n"; next;
	}
	print HISTORYTMP "END_SIDER\n";
	print HISTORYTMP "BEGIN_FILETYPES\n";
	foreach my $key (keys %_filetypes_h) {
		my $hits=$_filetypes_h{$key}||0;
		my $bytes=$_filetypes_k{$key}||0;
		my $bytesbefore=$_filetypes_gz_in{$key}||0;
		my $bytesafter=$_filetypes_gz_out{$key}||0;
		print HISTORYTMP "$key $hits $bytes $bytesbefore $bytesafter\n";
		next;
	}
	print HISTORYTMP "END_FILETYPES\n";
	print HISTORYTMP "BEGIN_BROWSER\n";
	foreach my $key (keys %_browser_h) { print HISTORYTMP "$key $_browser_h{$key}\n"; next; }
	print HISTORYTMP "END_BROWSER\n";
	print HISTORYTMP "BEGIN_NSVER\n";
	for (my $i=1; $i<=$#_nsver_h; $i++) {
		my $nb_h=$_nsver_h[$i]||"";
		print HISTORYTMP "$i $nb_h\n";
		next;
	}
	print HISTORYTMP "END_NSVER\n";
	print HISTORYTMP "BEGIN_MSIEVER\n";
	for (my $i=1; $i<=$#_msiever_h; $i++) {
		my $nb_h=$_msiever_h[$i]||"";
		print HISTORYTMP "$i $nb_h\n";
		next;
	}
	print HISTORYTMP "END_MSIEVER\n";
	print HISTORYTMP "BEGIN_OS\n";
	foreach my $key (keys %_os_h) { print HISTORYTMP "$key $_os_h{$key}\n"; next; }
	print HISTORYTMP "END_OS\n";

	# Referer
	print HISTORYTMP "BEGIN_UNKNOWNREFERER\n";
	foreach my $key (keys %_unknownreferer_l) { print HISTORYTMP "$key $_unknownreferer_l{$key}\n"; next; }
	print HISTORYTMP "END_UNKNOWNREFERER\n";
	print HISTORYTMP "BEGIN_UNKNOWNREFERERBROWSER\n";
	foreach my $key (keys %_unknownrefererbrowser_l) { print HISTORYTMP "$key $_unknownrefererbrowser_l{$key}\n"; next; }
	print HISTORYTMP "END_UNKNOWNREFERERBROWSER\n";
	print HISTORYTMP "From0 ".int($_from_p[0])." ".int($_from_h[0])."\n";
	print HISTORYTMP "From1 ".int($_from_p[1])." ".int($_from_h[1])."\n";
	print HISTORYTMP "From2 ".int($_from_p[2])." ".int($_from_h[2])."\n";
	print HISTORYTMP "From3 ".int($_from_p[3])." ".int($_from_h[3])."\n";
	print HISTORYTMP "From4 ".int($_from_p[4])." ".int($_from_h[4])."\n";		# Same site
	print HISTORYTMP "From5 ".int($_from_p[5])." ".int($_from_h[5])."\n";		# News
	print HISTORYTMP "BEGIN_SEREFERRALS\n";
	foreach my $key (keys %_se_referrals_h) { print HISTORYTMP "$key $_se_referrals_h{$key}\n"; next; }
	print HISTORYTMP "END_SEREFERRALS\n";
	print HISTORYTMP "BEGIN_PAGEREFS\n";
	foreach my $key (keys %_pagesrefs_h) {
		$newkey=$key;
		$newkey =~ s/^http(s|):\/\/([^\/]+)\/$/http$1:\/\/$2/;	# Remove / at end of http://.../ but not at end of http://.../dir/
		$newkey =~ s/\s/%20/g;
		print HISTORYTMP "$newkey $_pagesrefs_h{$key}\n"; next;
	}
	print HISTORYTMP "END_PAGEREFS\n";
	print HISTORYTMP "BEGIN_SEARCHWORDS\n";
	&BuildKeyList($MaxNbOfKeywordsShown,$MinHitKeyword,\%_keyphrases,\%_keyphrases);
	my %keysinkeylist=();
	foreach my $key (@keylist) {
		$keysinkeylist{$key}=1;
		my $keyphrase=$key;
		print HISTORYTMP "$keyphrase $_keyphrases{$key}\n"; next;
	}
	foreach my $key (keys %_keyphrases) {
		if ($keysinkeylist{$key}) { next; }
		my $keyphrase=$key;
		print HISTORYTMP "$keyphrase $_keyphrases{$key}\n"; next;
	}
	print HISTORYTMP "END_SEARCHWORDS\n";

	# Other
	print HISTORYTMP "BEGIN_ERRORS\n";
	foreach my $key (keys %_errors_h) { print HISTORYTMP "$key $_errors_h{$key}\n"; next; }
	print HISTORYTMP "END_ERRORS\n";
	print HISTORYTMP "BEGIN_SIDER_404\n";
	foreach my $key (keys %_sider404_h) { 
		my $newkey=$key;
		my $newreferer=$_referer404_h{$key}||"";
		$newreferer =~ s/\s/%20/g;
		print HISTORYTMP "$newkey ".int($_sider404_h{$key})." $newreferer\n";
		next;
	}
	print HISTORYTMP "END_SIDER_404\n";

	close(HISTORYTMP);
}

#--------------------------------------------------------------------
# Function:     Return time elapsed since last call in miliseconds
# Input:        None
# Return:       Number of miliseconds elapsed since last call
#--------------------------------------------------------------------
sub GetDelaySinceStart {
	my $option=shift;
	if ($option) { $StartSeconds=0;	}	# Reset counter
	my ($newseconds, $newmicroseconds)=(0,0);
	my $usedTimeHires=0;
#	($newseconds, $newmicroseconds) = gettimeofday; $usedTimeHires=1;	# Uncomment to use Time::HiRes function (provide milliseconds)
	if ((! $usedTimeHires) || ($newseconds eq "gettimeofday")) { $newseconds=time(); }
	if (! $StartSeconds) { $StartSeconds=$newseconds; $StartMicroseconds=$newmicroseconds; }
	my $nbms=$newseconds*1000+int($newmicroseconds/1000)-$StartSeconds*1000-int($StartMicroseconds/1000);
	return ($nbms);
}

#--------------------------------------------------------------------
# Input: Global variables
#--------------------------------------------------------------------
sub Init_HashArray {
	my $year=sprintf("%04i",shift||0);
	my $month=sprintf("%02i",shift||0);
	&debug("Call to Init_HashArray [$year,$month]");
	# We purge data read for $year and $month so it's like we never read it
	$HistoryFileAlreadyRead{"$year$month"}=0;
	# Delete/Reinit all arrays with name beginning by _
	@_msiever_h = @_nsver_h = ();
	for (my $ix=0; $ix<6; $ix++)  { $_from_p[$ix]=0; $_from_h[$ix]=0; }
	for (my $ix=0; $ix<24; $ix++) { $_time_h[$ix]=0; $_time_k[$ix]=0; $_time_p[$ix]=0; }
	# Delete/Reinit all hash arrays with name beginning by _
	%_browser_h = %_domener_h = %_domener_k = %_domener_p = %_errors_h =
	%_filetypes_h = %_filetypes_k = %_filetypes_gz_in = %_filetypes_gz_out =
	%_hostmachine_h = %_hostmachine_k = %_hostmachine_l = %_hostmachine_p =
	%_keyphrases = %_os_h = %_pagesrefs_h = %_robot_h = %_robot_l = 
	%_login_h = %_login_p = %_login_k = %_login_l =
	%_se_referrals_h = %_sider404_h = %_url_p = %_url_k = %_url_e =
	%_unknownreferer_l = %_unknownrefererbrowser_l = ();
}



#--------------------------------------------------------------------
# Function:     Change word separators into space and remove bad coded chars
# Input:        stringtodecode
# Return:		decodedstring
#--------------------------------------------------------------------
sub ChangeWordSeparatorsIntoSpace {
	$_[0] =~ s/%1[03]/ /g;
	$_[0] =~ s/%2[02789abc]/ /g;
	$_[0] =~ s/%3a/ /g;
	$_[0] =~ tr/\+\'\(\)\"\*,:/        /s;								# "&" and "=" must not be in this list
}


#--------------------------------------------------------------------
# Function:     Decode an URL encoded string
# Input:        stringtodecode
# Return:		decodedstring
#--------------------------------------------------------------------
sub DecodeEncodedString {
	my $stringtodecode=shift;
 	$stringtodecode =~ tr/\+/ /s;
 	$stringtodecode =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;		# Decode encoded URL
	return $stringtodecode;
}


#--------------------------------------------------------------------
# Function:     Copy one file into another
# Input:        sourcefilename targetfilename
# Return:		0 if copy is ok, 1 else
#--------------------------------------------------------------------
sub FileCopy {
	my $filesource = shift;
	my $filetarget = shift;
	debug("FileCopy($filesource,$filetarget)",1);
	open(FILESOURCE,"$filesource") || return 1;
	open(FILETARGET,">$filetarget") || return 1;
	# ...
	close(FILETARGET);
	close(FILESOURCE);
	debug(" File copied",1);
	return 0;
}

#--------------------------------------------------------------------
# Function:      Show flags for other language translations
# Input:         Current languade id (en, fr, ...)
#--------------------------------------------------------------------
sub Show_Flag_Links {
	my $CurrentLang = shift;
	if ($ShowFlagLinks eq "0") { $ShowFlagLinks = ""; }						# For backward compatibility
	if ($ShowFlagLinks eq "1") { $ShowFlagLinks = "en fr de it nl es"; }	# For backward compatibility
	my @flaglist=split(/\s+/,$ShowFlagLinks);

	# Build flags link
	my $NewLinkParams=$QueryString;
	if ($ENV{"GATEWAY_INTERFACE"}) {
		$NewLinkParams =~ s/update[=]*[^ &]*//;
		$NewLinkParams =~ s/staticlinks[=]*[^ &]*//;
		$NewLinkParams =~ s/lang=[^ &]*//;
		$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
		if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }
	}
	else {
		$NewLinkParams=($SiteConfig?"config=$SiteConfig&":"")."year=$YearRequired&month=$MonthRequired&";
	}

	print "<br>\n";
	foreach my $flag (@flaglist) {
		if ($flag ne $CurrentLang) {
			my $lng=$flag;
			if ($flag eq "en") { $lng="English"; }
			if ($flag eq "fr") { $lng="French"; }
			if ($flag eq "de") { $lng="German"; }
			if ($flag eq "it") { $lng="Italian"; }
			if ($flag eq "nl") { $lng="Dutch"; }
			if ($flag eq "es") { $lng="Spanish"; }
			print "<a href=\"$DirCgi$PROG.$Extension?${NewLinkParams}lang=$flag\"><img src=\"$DirIcons\/flags\/$flag.png\" height=14 border=0 alt=\"$lng\" title=\"$lng\"></a>&nbsp;\n";
		}
	}
}

#--------------------------------------------------------------------
# Function:      Format value in bytes in a string (Bytes, Kb, Mb, Gb)
# Input:         bytes
#--------------------------------------------------------------------
sub Format_Bytes {
	my $bytes = shift||0;
	my $fudge = 1;
	if ($bytes >= $fudge * exp(3*log(1024))) { return sprintf("%.2f", $bytes/exp(3*log(1024)))." Gb"; }
	if ($bytes >= $fudge * exp(2*log(1024))) { return sprintf("%.2f", $bytes/exp(2*log(1024)))." Mb"; }
	if ($bytes >= $fudge * exp(1*log(1024))) { return sprintf("%.2f", $bytes/exp(1*log(1024)))." $Message[44]"; }
	if ($bytes < 0) { $bytes="?"; }
	return int($bytes)." $Message[75]";
}

#------------------------------------------------------------------------------
# Function:      Format a date according to Message[78] (country date format)
# Input:         String YYYYMMDDHHMMSS
#------------------------------------------------------------------------------
sub Format_Date {
	my $date=shift;
	my $option=shift;
	my $year=substr("$date",0,4);
	my $month=substr("$date",4,2);
	my $day=substr("$date",6,2);
	my $hour=substr("$date",8,2);
	my $min=substr("$date",10,2);
	my $sec=substr("$date",12,2);
	my $dateformat=$Message[78];
	$dateformat =~ s/yyyy/$year/g;
	$dateformat =~ s/yy/$year/g;
	$dateformat =~ s/mmm/$monthlib{$month}/g;
	$dateformat =~ s/mm/$month/g;
	$dateformat =~ s/dd/$day/g;
	$dateformat =~ s/HH/$hour/g;
	$dateformat =~ s/MM/$min/g;
	$dateformat =~ s/SS/$sec/g;
	return "$dateformat";
}

#--------------------------------------------------------------------
# Function:     Return 1 if string contains only ascii chars
# Input:        String
# Return:       0 or 1
#--------------------------------------------------------------------
sub IsAscii {
	my $string=shift;
	debug("IsAscii($string)",4);
	if ($string =~ /^[\w\+\-\/\\\.%,;:=\"\'&?!\s]+$/) {
		debug(" Yes",4);
		return 1;		# Only alphanum chars (and _) or + - / \ . % , ; : = " ' & ? space \t
	}
	debug(" No",4);
	return 0;
}


sub AddInTree {
	my $keytoadd=shift;
	my $keyval=shift;
	my $firstadd=shift||0;	
#	$countaddintree++;
#	if ($countaddintree % 100 == 1) { debug(" AddInTree Start of 100 (lowerval=$lowerval)",3); }
	if ($firstadd==1) {			# Val is the first one
		debug(" firstadd",4);
		$val{$keyval}=$keytoadd;
		$lowerval=$keyval;
		debug(" lowerval=$lowerval, nb elem val=".(scalar keys %val).", nb elem egal=".(scalar keys %egal).".",4);
		return;
	}
	if ($val{$keyval}) { 		# Val is already in tree
		debug(" val is already in tree",4);
		$egal{$keytoadd}=$val{$keyval};
		$val{$keyval}=$keytoadd;
		debug(" lowerval=$lowerval, nb elem val=".(scalar keys %val).", nb elem egal=".(scalar keys %egal).".",4);
		return;
	}
	if ($keyval <= $lowerval) {	# Val is a new one lower (should happens only when tree is not full)
		debug(" keytoadd val=$keyval is lower or equal to lowerval=$lowerval",4);
		$val{$keyval}=$keytoadd;
		$nextval{$keyval}=$lowerval;
		$lowerval=$keyval;
		debug(" lowerval=$lowerval, nb elem val=".(scalar keys %val).", nb elem egal=".(scalar keys %egal).".",4);
		return;
	}
	# Val is a new one higher
	debug(" keytoadd val=$keyval is higher than lowerval=$lowerval",4);
	$val{$keyval}=$keytoadd;
	my $valcursor=$lowerval;	# valcursor is value just before keyval
	while ($nextval{$valcursor} && ($nextval{$valcursor} < $keyval)) { $valcursor=$nextval{$valcursor}; }
	if ($nextval{$valcursor}) {	# keyval is beetween valcursor and nextval{valcursor}
		$nextval{$keyval}=$nextval{$valcursor};
	}
	$nextval{$valcursor}=$keyval; 
	debug(" lowerval=$lowerval, nb elem val=".(scalar keys %val).", nb elem egal=".(scalar keys %egal).".",4);
#	if ($countaddintree % 100 == 0) { debug(" AddInTree End of 100",3); }
}

sub Removelowerval {
	my $keytoremove=$val{$lowerval};	# This is lower key
	debug("  remove for lowerval=$lowerval: key=$keytoremove",5);
	if ($egal{$keytoremove}) {
		$val{$lowerval}=$egal{$keytoremove};
		delete $egal{$keytoremove};
	}
	else {
		delete $val{$lowerval};
		#my $templowerval=$nextval{$lowerval};
		$lowerval=$nextval{$lowerval};	# Set new lowerval
		#delete $nextval{$templowerval};
	}
	debug("  new lower value=$lowerval, val size=".(scalar keys %val).", egal size=".(scalar keys %egal),5);
}
#sub AddInTree {
#	my $keytoadd=shift;
#	my $keycursor=shift;
#	$countaddintree++;
#	if ($countaddintree % 100 == 0) { debug("AddInTree Start of 100 ($count already processed: 1 root + ".(scalar keys %left)." left + ".(scalar keys %right)." right",2); }
#	my $value=$hashfororder->{$keytoadd};
#	if ($keytoadd eq $keyroot || $left{$keytoadd} || $right{$keytoadd}) {	# Key $keytoadd already exists. Should not be possible
#		warning("Error during sort process (Key $keytoadd is already in tree with root key $keycursor).");
#		return;
#	}
#	while (1) {
#		if ($value < $hashfororder->{$keycursor}) {
#			if ($left{$keycursor}) { $keycursor=$left{$keycursor}; next; }
#			$left{$keycursor}=$keytoadd; last;
#		}
#		if ($value >= $hashfororder->{$keycursor}) {
#			if ($right{$keycursor}) { $keycursor=$right{$keycursor}; next; }
#			$right{$keycursor}=$keytoadd; last;
#		}
#	}
#	if ($countaddintree % 100 == 99) { debug("AddInTree End of 100",2); }
#}
#
#sub Removelowerval {
#	my $keycursor=$keysaved=shift;
#	while ($left{$keycursor}) { $keysaved=$keycursor; $keycursor=$left{$keycursor}; }
#	# We found lower key
#	debug("  remove $keycursor, value=$hashfororder->{$keycursor}",2);
#	if (! $right{$keycursor}) {			# Nothing higher
#		delete $left{$keysaved};
#		$lowerval=$hashfororder->{$keysaved}||0;
#	}
#	else {
#		if ($keycursor ne $keysaved) {	# lower key was not root key
#			$left{$keysaved}=$right{$keycursor};
#			delete $right{$keycursor};
#			$keycursor=$keysaved;
#		}
#		else {	# lower key was root key
#			$keyroot=$right{$keycursor};
#			delete $right{$keycursor};
#			$keycursor=$keyroot;
#		}
#		while ($left{$keycursor}) { $keycursor=$left{$keycursor}; }
#		$lowerval=$hashfororder->{$keycursor}||0;
#	}
#	debug("  new lower value is $lowerval",2);
#}
#
sub Minimum {
	my ($val1,$val2)=@_;
	return ($val1<$val2?$val1:$val2);
}

#--------------------------------------------------------------------
# Function:     Build keylist array
# Input:        Size of keylist array, min value in hash for select, hash for select, hash for order
# Return:       keylist array
#--------------------------------------------------------------------
sub BuildKeyList {
	my $ArraySize=shift;
	my $MinValue=shift;
	my $hashforselect=shift;
	my $hashfororder=shift;
	debug("BuildKeyList($ArraySize,$MinValue,$hashforselect with size=".(scalar keys %$hashforselect).",$hashfororder with size=".(scalar keys %$hashfororder).")",2);
	my $count=0;
	$lowerval=0;	# Global because used in AddInTree and Removelowerval
	%val=(); %nextval=(); %egal=();
	foreach my $key (keys %$hashforselect) {
		if ($count < $ArraySize) {
			if ($hashforselect->{$key} >= $MinValue) {
				$count++;
				debug(" Add in tree entry $count : $key (value=".($hashfororder->{$key}||0).", tree not full)",4);
				AddInTree($key,$hashfororder->{$key}||0,$count);
			}
			next;
		}
		if (($hashfororder->{$key}||0)<=$lowerval) {
			$count++;
			next;
		}
		$count++;
		debug(" Add in tree entry $count : $key (value=".($hashfororder->{$key}||0)." > lowerval=$lowerval)",4);
		AddInTree($key,$hashfororder->{$key}||0);
		debug(" Removelower in tree",4);
		Removelowerval();
	}

	# Build key list and sort it
	debug(" Build key list and sort it. lowerval=$lowerval, nb elem val=".(scalar keys %val).", nb elem egal=".(scalar keys %egal).".",2);
	my %notsortedkeylist=();
	foreach my $key (values %val) {	$notsortedkeylist{$key}=1; }
	foreach my $key (values %egal) { $notsortedkeylist{$key}=1; }
	@keylist=();
	@keylist=(sort {$hashfororder->{$b} <=> $hashfororder->{$a} } keys %notsortedkeylist);
	debug("BuildKeyList End (keylist size=".(@keylist).")",2);
	return;
}


#--------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------
if ($ENV{"GATEWAY_INTERFACE"}) {	# Run from a browser
	#print "Expires: ".(localtime(time()+3600))."\n";
	print("Content-type: text/html\n\n\n");
	if ($ENV{"CONTENT_LENGTH"}) {
		binmode STDIN;
		read(STDIN, $QueryString, $ENV{'CONTENT_LENGTH'});
	}
	if ($ENV{"QUERY_STRING"}) {
		$QueryString = $ENV{"QUERY_STRING"};
	}
	$QueryString =~ s/<script.*$//i;						# This is to avoid 'Cross Site Scripting attacks'
	if ($QueryString =~ /site=/i)   { $SiteConfig=$QueryString; $SiteConfig =~ s/.*site=//i;   $SiteConfig =~ s/&.*//; $SiteConfig =~ s/ .*//; }	# For backward compatibility
	if ($QueryString =~ /config=/i) { $SiteConfig=$QueryString; $SiteConfig =~ s/.*config=//i; $SiteConfig =~ s/&.*//; $SiteConfig =~ s/ .*//; }
	$UpdateStats=0; $HTMLOutput=1;							# No update but report by default when run from a browser
	if ($QueryString =~ /update=1/i)  { $UpdateStats=1; }	# Update is required
}
else {								# Run from command line
	if ($ARGV[0] && $ARGV[0] eq "-h") { $SiteConfig = $ARGV[1]; }          # Kept for backward compatibility but useless
	$QueryString=""; for (0..@ARGV-1) {
		if ($_ > 0) { $QueryString .= "&"; }
		my $NewLinkParams=$ARGV[$_]; $NewLinkParams =~ s/^-+//;
		$QueryString .= "$NewLinkParams";
	}
	$QueryString =~ s/<script.*$//i;                             # This is to avoid 'Cross Site Scripting attacks'
	if ($QueryString =~ /site=/i)     { $SiteConfig=$QueryString; $SiteConfig =~ s/.*site=//i;   $SiteConfig =~ s/&.*//; $SiteConfig =~ s/ .*//; }  # For backward compatibility
	if ($QueryString =~ /config=/i)   { $SiteConfig=$QueryString; $SiteConfig =~ s/.*config=//i; $SiteConfig =~ s/&.*//; $SiteConfig =~ s/ .*//; }
	$UpdateStats=1; $HTMLOutput=0;                               # Update with no report by default when run from command line
	if ($QueryString =~ /output/i)    { $UpdateStats=0; $HTMLOutput=1; }   # Report and no update if an output is required
	if ($QueryString =~ /update/i)    { $UpdateStats=1; }                  # Except if -update specified
	$QueryString=~s/output&//; $QueryString=~s/output$//;
	if ($QueryString =~ /showsteps/i) { $ShowSteps=1; } else { $ShowSteps=0; }
	$QueryString=~s/showsteps[^&]*//;
	if ($QueryString =~ /showcorrupted/i) { $ShowCorrupted=1; } else { $ShowCorrupted=0; }
	$QueryString=~s/showcorrupted[^&]*//;
}
if ($QueryString =~ /staticlinks/i) 		{ $StaticLinks=1; }
if ($QueryString =~ /debug=(\d+)/i)			{ $Debug=$1; }
if ($QueryString =~ /output=urldetail:/i) 	{	
	# A filter can be defined with output=urldetail to reduce number of lines read and showed
	$URLFilter=$QueryString; $URLFilter =~ s/.*output=urldetail://; $URLFilter =~ s/&.*//; $URLFilter =~ s/ .*//;
}
&debug("QUERY_STRING=$QueryString",2);

($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

# Read reference databases
&Read_Ref_Data();

if ((! $ENV{"GATEWAY_INTERFACE"}) && (! $SiteConfig)) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG is a free web server logfile analyzer to show you advanced web\n";
	print "statistics.\n";
	print "$PROG comes with ABSOLUTELY NO WARRANTY. It's a free software distributed\n";
	print "with a GNU General Public License (See LICENSE file for details).\n";
	print "\n";
	print "Syntax: $PROG.$Extension -config=virtualhostname [options]\n";
	print "  This runs $PROG in command line to update statistics of a web site, from\n";
	print "  the log file defined in config file, and/or returns a HTML report.\n";
	print "  First, $PROG tries to read $PROG.virtualhostname.conf as the config file.\n";
	print "  If not found, $PROG tries to read $PROG.conf\n";
	print "  Config files must be in /etc/opt/awstats, /etc/awstats, /etc or same\n";
	print "  directory than awstats.pl file.\n";
	print "  See AWStats documentation for all setup instrutions.\n";
	print "\n";
	print "Options to update statistics:\n";
	print "  -update        to update statistics (default)\n";
	print "  -showsteps     to add benchmark information every $NbOfLinesForBenchmark lines processed\n";
	print "  -showcorrupted to add output for each corrupted lines found, with reason\n";
	print "  Be care to process log files in chronological order when updating statistics.\n";
	print "\n";
	print "Options to show statistics:\n";
	print "  -output      to output main HTML report (no update made except with -update)\n";
	print "  -output=x    to output other report pages where x is:\n";
	print "               allhosts         to build page of all hosts\n";
	print "               lasthosts        to build page of last connections\n";
	print "               unknownip        to build page of all unresolved IP\n";
	print "               urldetail        to list most often viewed pages \n";
	print "               urldetail:filter to list most often viewed pages matching filter\n";
	print "               unknownreferer        to list 'User Agents' with unknown OS\n";
	print "               unknownrefererbrowser to list 'User Agents' with unknown browser\n";
	print "               browserdetail    to build page with browsers detailed versions\n";
	print "               allkeyphrases    to list all keyphrases used on search engines\n";
	print "               errors404        to list 'Referers' for 404 errors\n";
	print "  -staticlinks to have static links in HTML report page\n";
	print "  -lang=LL     to output a HTML report in language LL (en,de,es,fr,it,nl,...)\n";
	print "  -month=MM    to output a HTML report for an old month=MM\n";
	print "  -year=YYYY   to output a HTML report for an old year=YYYY\n";
	print "  Warning: Those 'date' options doesn't allow you to process old log file.\n";
	print "  It only allows you to see a report for a chosen month/year period instead\n";
	print "  of current month/year.\n";
	print "\n";
	print "Other options:\n";
	print "  -debug=X       to add debug informations lesser than level X\n";
	print "\n";
	print "Now supports/detects:\n";
	print "  Reverse DNS lookup\n";
	print "  Number of visits, unique visitors, list of last visits\n";
	print "  Hosts list and unresolved IP addresses list\n";
	print "  Days of week and rush hours\n";
	print "  Authenticated users\n";
	print "  Viewed and entry pages\n";
	print "  Type of files and Web compression\n";
	print "  ".(scalar keys %DomainsHashIDLib)." domains/countries\n";
	print "  ".(scalar keys %BrowsersHashIDLib)." browsers\n";
	print "  ".(scalar keys %OSHashLib)." operating systems\n";
	print "  ".(scalar keys %RobotHashIDLib)." robots\n";
	print "  ".(scalar keys %SearchEnginesHashIDLib)." search engines (and keyphrases/keywords used from them)\n";
	print "  All HTTP errors\n";
	print "  Report by day/month/year\n";
	print "  And a lot of other advanced options...\n";
	print "New versions and FAQ at http://awstats.sourceforge.net\n";
	exit 2;
}

# Get current time
$nowtime=time;
($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday) = localtime($nowtime);
$nowweekofmonth=int($nowday/7);
$nowdaymod=$nowday%7;
$nowwday++;
if ($nowdaymod <= $nowwday) { if (($nowwday != 7) || ($nowdaymod != 0)) { $nowweekofmonth=$nowweekofmonth+1; } }
if ($nowdaymod >  $nowwday) { $nowweekofmonth=$nowweekofmonth+2; }
$nowweekofmonth = "0$nowweekofmonth";
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
$nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
if (++$nowmonth < 10) { $nowmonth = "0$nowmonth"; }
if ($nowday < 10) { $nowday = "0$nowday"; }
if ($nowhour < 10) { $nowhour = "0$nowhour"; }
if ($nowmin < 10) { $nowmin = "0$nowmin"; }
if ($nowsec < 10) { $nowsec = "0$nowsec"; }
# Get tomorrow time (will be used to discard some record with corrupted date (future date))
($tomorrowsec,$tomorrowmin,$tomorrowhour,$tomorrowday,$tomorrowmonth,$tomorrowyear) = localtime($nowtime+86400);
if ($tomorrowyear < 100) { $tomorrowyear+=2000; } else { $tomorrowyear+=1900; }
$tomorrowsmallyear=$tomorrowyear;$tomorrowsmallyear =~ s/^..//;
if (++$tomorrowmonth < 10) { $tomorrowmonth = "0$tomorrowmonth"; }
if ($tomorrowday < 10) { $tomorrowday = "0$tomorrowday"; }
if ($tomorrowhour < 10) { $tomorrowhour = "0$tomorrowhour"; }
if ($tomorrowmin < 10) { $tomorrowmin = "0$tomorrowmin"; }
if ($tomorrowsec < 10) { $tomorrowsec = "0$tomorrowsec"; }
$timetomorrow=int($tomorrowyear.$tomorrowmonth.$tomorrowday.$tomorrowhour.$tomorrowmin.$tomorrowsec);

# Read config file
&Read_Config_File;
if ($QueryString =~ /lang=/i) { $Lang=$QueryString; $Lang =~ s/.*lang=//i; $Lang =~ s/&.*//; $Lang =~ s/ .*//; }
if (! $Lang) { $Lang="en"; }

# Change old values of Lang into new for compatibility
if ($Lang eq "0") { $Lang="en"; }
if ($Lang eq "1") { $Lang="fr"; }
if ($Lang eq "2") { $Lang="nl"; }
if ($Lang eq "3") { $Lang="es"; }
if ($Lang eq "4") { $Lang="it"; }
if ($Lang eq "5") { $Lang="de"; }
if ($Lang eq "6") { $Lang="pl"; }
if ($Lang eq "7") { $Lang="gr"; }
if ($Lang eq "8") { $Lang="cz"; }
if ($Lang eq "9") { $Lang="pt"; }
if ($Lang eq "10") { $Lang="kr"; }

# Get the output strings
&Read_Language_Data($Lang);

# Check and correct bad parameters
&Check_Config;

# Init other parameters
if ($ENV{"GATEWAY_INTERFACE"}) { $DirCgi=""; }
if (($DirCgi ne "") && !($DirCgi =~ /\/$/) && !($DirCgi =~ /\\$/)) { $DirCgi .= "/"; }
if ($DirData eq "" || $DirData eq ".") { $DirData=$DIR; }	# If not defined or chosen to "." value then DirData is current dir
if ($DirData eq "")  { $DirData="."; }						# If current dir not defined then we put it to "."
$DirData =~ s/\/$//; $DirData =~ s/\\$//;
$SiteToAnalyze=$SiteDomain;
if (! $SiteToAnalyze) { $SiteToAnalyze=$SiteConfig; }
$SiteToAnalyze =~ tr/A-Z/a-z/;
$SiteToAnalyzeWithoutwww = $SiteToAnalyze; $SiteToAnalyzeWithoutwww =~ s/www\.//;
if ($FirstDayOfWeek == 1) { @DOWIndex = (1,2,3,4,5,6,0); }
else { @DOWIndex = (0,1,2,3,4,5,6); }

# Check year and month parameters
if ($QueryString =~ /year=/i) 	{ $YearRequired=$QueryString; $YearRequired =~ s/.*year=//; $YearRequired =~ s/&.*//;  $YearRequired =~ s/ .*//; }
if ((! $YearRequired) || ($YearRequired !~ /^\d\d\d\d$/)) { $YearRequired=$nowyear; }
if ($QueryString =~ /month=/i)	{ $MonthRequired=$QueryString; $MonthRequired =~ s/.*month=//; $MonthRequired =~ s/&.*//; $MonthRequired =~ s/ .*//; }
if ((! $MonthRequired) || ($MonthRequired ne "year" && $MonthRequired !~ /^[\d][\d]$/)) { $MonthRequired=$nowmonth; }
# day is a hidden option. Must not be used (Make results not understandable). Available for users that rename historic files with day.
if ($QueryString =~ /day=/i)	{ $DayRequired=$QueryString; $DayRequired =~ s/.*day=//; $DayRequired =~ s/&.*//; $DayRequired =~ s/ .*//; }
if ((! $DayRequired) || ($DayRequired !~ /^[\d][\d]$/)) { $DayRequired=""; }
debug("YearRequired=$YearRequired MonthRequired=$MonthRequired",2);

# Print html header
&html_head;

# Security check
if ($UpdateStats && ($AllowToUpdateStatsFromBrowser==0) && ($ENV{"GATEWAY_INTERFACE"})) {
	error("Error: Update of statistics is not allowed from a browser.");
}

# Init global variables required for output and update process
%monthlib = ("01","$Message[60]","02","$Message[61]","03","$Message[62]","04","$Message[63]","05","$Message[64]","06","$Message[65]","07","$Message[66]","08","$Message[67]","09","$Message[68]","10","$Message[69]","11","$Message[70]","12","$Message[71]");
%monthnum = ("Jan","01","jan","01","Feb","02","feb","02","Mar","03","mar","03","Apr","04","apr","04","May","05","may","05","Jun","06","jun","06","Jul","07","jul","07","Aug","08","aug","08","Sep","09","sep","09","Oct","10","oct","10","Nov","11","nov","11","Dec","12","dec","12");	# monthnum must be in english because used to translate log date in apache log files
$LastLine=0;$LastUpdate=0;
$TotalEntries=0; $TotalBytesPages=0; $TotalKeyphrases=0; $TotalDifferentPages=0; $TotalDifferentKeyphrases=0;
for (my $ix=1; $ix<=12; $ix++) {
	my $monthix=$ix;if ($monthix < 10) { $monthix  = "0$monthix"; }
	$LastLine{$YearRequired.$monthix}=0;$FirstTime{$YearRequired.$monthix}=0;$LastTime{$YearRequired.$monthix}=0;$LastUpdate{$YearRequired.$monthix}=0;
	$MonthVisits{$YearRequired.$monthix}=0;$MonthUnique{$YearRequired.$monthix}=0;$MonthPages{$YearRequired.$monthix}=0;$MonthHits{$YearRequired.$monthix}=0;$MonthBytes{$YearRequired.$monthix}=0;$MonthHostsKnown{$YearRequired.$monthix}=0;$MonthHostsUnknown{$YearRequired.$monthix}=0;
}
&Init_HashArray;	# Should be useless in perl (except with mod_perl that keep variables in memory).


#------------------------------------------
# UPDATE PROCESS
#------------------------------------------
debug("UpdateStats is $UpdateStats",2);
if ($UpdateStats) {

	if ($DNSLookup) {
	#	eval { use Sockets; }; 
	#	if ($@){
	#		error("Error: The perl 'Socket' module is not installed. Install it from CPAN or use a more 'standard' perl interpreter.\n");
	#	}
		use Socket;
	}
	$NewDNSLookup=$DNSLookup;

	# Init RobotArrayID required for update process
	push @RobotArrayList,"major";
	push @RobotArrayList,"other";
	push @RobotArrayList,"generic";
	foreach my $key (@RobotArrayList) {
		if ($key ne "other") {
			push @RobotArrayID,@{"RobotArrayID_$key"};
			debug("Add ".@{"RobotArrayID_$key"}." elements from RobotArrayID_$key into RobotArrayID",2);
		}
		else {
			my $added=0;
			foreach my $robotid (keys %RobotHashIDLib) {
				my $alreadyin=0;
				# Check if robotid in RobotArrayID
				foreach my $robotin (@RobotArrayID) {
					if ($robotid eq $robotin) { $alreadyin=1; last; }
				}
				# Check if robotid in generic
				foreach my $robotin (@{"RobotArrayID_generic"}) {
					if ($robotid eq $robotin) { $alreadyin=1; last; }
				}
				if (! $alreadyin) {
					push @RobotArrayID,$robotid;
					$added++;
				}
			}	
			debug("Add $added elements from RobotHashIDLib into RobotArrayID",2);
		}
	}
	debug("RobotArrayID has now ".@RobotArrayID." elements",2);
	# Init HostAliases array
	if (! @HostAliases) {
		warning("Warning: HostAliases parameter is not defined, $PROG choose \"$SiteToAnalyze localhost 127.0.0.1\".");
		push @HostAliases,"$SiteToAnalyze"; push @HostAliases,"localhost"; push @HostAliases,"127.0.0.1";
	}
	my $SiteToAnalyzeIsInHostAliases=0;
	foreach my $elem (@HostAliases) { if ($elem eq $SiteToAnalyze) { $SiteToAnalyzeIsInHostAliases=1; last; } }
	if (! $SiteToAnalyzeIsInHostAliases) { 
		unshift @HostAliases,"$SiteToAnalyze";	# Add SiteToAnalyze at beginning of HostAliases Array
	}
	debug("HostAliases is now @HostAliases",2);
	# Init SkipFiles array
	if (! @SkipFiles) { $SkipFiles[0]="\.css\$";$SkipFiles[1]="\.js\$";$SkipFiles[2]="\.class\$";$SkipFiles[3]="robots\.txt\$"; }
	debug("SkipFiles is now @SkipFiles",2);

	debug("Start Update process");

	# GENERATING PerlParsingFormat
	#------------------------------------------
	# Log example records
	# 62.161.78.73 user - [dd/mmm/yyyy:hh:mm:ss +0000] "GET / HTTP/1.1" 200 1234 "http://www.from.com/from.htm" "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"
	# my.domain.com - user [09/Jan/2001:11:38:51 -0600] "OPTIONS /mime-tmp/xxx file.doc HTTP/1.1" 408 - "-" "-"
    # 2000-07-19 14:14:14 62.161.78.73 - GET / 200 1234 HTTP/1.1 Mozilla/4.0+(compatible;+MSIE+5.01;+Windows+NT+5.0) http://www.from.com/from.htm
	# 05/21/00	00:17:31	OK  	200	212.242.30.6	Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)	http://www.cover.dk/	"www.cover.dk"	:Documentation:graphics:starninelogo.white.gif	1133
	# Other example for error 408 with Apache
	# 62.161.78.73 user - [dd/mmm/yyyy:hh:mm:ss +0000] "-" 408 - "-" "-"
	$LogFormatString=$LogFormat;
	if ($LogFormat eq "1") { $LogFormatString="%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""; }
	if ($LogFormat eq "2") { $LogFormatString="date time c-ip cs-username cs-method cs-uri-stem sc-status sc-bytes cs-version cs(User-Agent) cs(Referer)"; }
	if ($LogFormat eq "4") { $LogFormatString="%h %l %u %t \"%r\" %>s %b"; }
	if ($LogFormat eq "5") { $LogFormatString="c-ip cs-username c-agent sc-authenticated date time s-svcname s-computername cs-referred r-host r-ip r-port time-taken cs-bytes sc-bytes cs-protocol cs-transport s-operation cs-uri cs-mime-type s-object-source sc-status s-cache-info"; }
	# Replacement for Apache format string
	$LogFormatString =~ s/%h([\s])/%host$1/g; $LogFormatString =~ s/%h$/%host/g;
	$LogFormatString =~ s/%l([\s])/%other$1/g; $LogFormatString =~ s/%l$/%other/g;
	$LogFormatString =~ s/%u([\s])/%logname$1/g; $LogFormatString =~ s/%u$/%logname/g;
	$LogFormatString =~ s/%t([\s])/%time1$1/g; $LogFormatString =~ s/%t$/%time1/g;
	$LogFormatString =~ s/\"%r\"/%methodurl/g;
	$LogFormatString =~ s/%>s/%code/g; 			
 	$LogFormatString =~ s/%b([\s])/%bytesd$1/g;	$LogFormatString =~ s/%b$/%bytesd/g;
	$LogFormatString =~ s/\"%\(Referer\)i\"/%refererquot/g;
	$LogFormatString =~ s/\"%\(User-Agent\)i\"/%uaquot/g;
	# Replacement for a IIS and ISA format string
	$LogFormatString =~ s/date\stime/%time2/g;
	$LogFormatString =~ s/c-ip/%host/g;
	$LogFormatString =~ s/cs-username/%logname/g;
	$LogFormatString =~ s/cs-method/%method/g;
	$LogFormatString =~ s/cs-uri-stem/%url/g; $LogFormatString =~ s/cs-uri/%url/g;
	$LogFormatString =~ s/sc-status/%code/g;
	$LogFormatString =~ s/sc-bytes/%bytesd/g;
	$LogFormatString =~ s/cs-version/%other/g;	# Protocol
	$LogFormatString =~ s/cs\(User-Agent\)/%ua/g; $LogFormatString =~ s/c-agent/%ua/g;
	$LogFormatString =~ s/cs\(Referer\)/%referer/g; $LogFormatString =~ s/cs-referred/%referer/g;
	$LogFormatString =~ s/cs-uri-query/%host/g;
	$LogFormatString =~ s/sc-authenticated/%other/g;
	$LogFormatString =~ s/s-svcname/%other/g;
	$LogFormatString =~ s/s-computername/%other/g;
	$LogFormatString =~ s/r-host/%other/g;
	$LogFormatString =~ s/r-ip/%other/g;
	$LogFormatString =~ s/r-port/%other/g;
	$LogFormatString =~ s/time-taken/%other/g;
	$LogFormatString =~ s/cs-bytes/%other/g;
	$LogFormatString =~ s/cs-protocol/%other/g;
	$LogFormatString =~ s/cs-transport/%other/g;
	$LogFormatString =~ s/s-operation/%other/g;
	$LogFormatString =~ s/cs-mime-type/%other/g;
	$LogFormatString =~ s/s-object-source/%other/g;
	$LogFormatString =~ s/s-cache-info/%other/g;
	# Generate PerlParsingFormat
	&debug("Generate PerlParsingFormat from LogFormatString=$LogFormatString");
	$PerlParsingFormat="";
	if ($LogFormat eq "1") {
		$PerlParsingFormat="([^\\s]+) [^\\s]+ ([^\\s]+) \\[([^\\s]+) [^\\s]+\\] \\\"([^\\s]+) ([^\\s]+) [^\\\"]+\\\" ([\\d|-]+) ([\\d|-]+) \\\"(.*)\\\" \\\"([^\\\"]+)\\\"";
		$pos_rc=1;$pos_logname=2;$pos_date=3;$pos_method=4;$pos_url=5;$pos_code=6;$pos_size=7;$pos_referer=8;$pos_agent=9;
		$lastrequiredfield=9;
	}
	if ($LogFormat eq "2") {
		$PerlParsingFormat="([^\\s]+ [^\\s]+) ([^\\s]+) ([^\\s]+) ([^\\s]+) ([^\\s]+) ([\\d|-]+) ([\\d|-]+) [^\\s]+ ([^\\s]+) ([^\\s]+)";
		$pos_date=1;$pos_rc=2;$pos_logname=3;$pos_method=4;$pos_url=5;$pos_code=6;$pos_size=7;$pos_agent=8;$pos_referer=9;
		$lastrequiredfield=9;
	}
	if ($LogFormat eq "3") {
		$PerlParsingFormat="([^\\t]*\\t[^\\t]*)\\t([^\\t]*)\\t([\\d]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t[^\\t]*\\t.*:([^\\t]*)\\t([\\d]*)";
		$pos_date=1;$pos_method=2;$pos_code=3;$pos_rc=4;$pos_agent=5;$pos_referer=6;$pos_url=7;$pos_size=8;
		$lastrequiredfield=8;
	}
	if ($LogFormat eq "4") {
		$PerlParsingFormat="([^\\s]*) [^\\s]* ([^\\s]*) \\[([^\\s]*) [^\\s]*\\] \\\"([^\\s]*) ([^\\s]*) [^\\\"]*\\\" ([\\d|-]*) ([\\d|-]*)";
		$pos_rc=1;$pos_logname=2;$pos_date=3;$pos_method=4;$pos_url=5;$pos_code=6;$pos_size=7;
		$lastrequiredfield=7;
	}
	if ($LogFormat eq "5") {
		$PerlParsingFormat="([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t[^\\t]*\\t([^\\t]*\\t[^\\t]*)\\t[^\\t]*\\t[^\\t]*\\t([^\\t]*)\\t[^\\t]*\\t[^\\t]*\\t[^\\t]*\\t[^\\t]*\\t[^\\t]*\\t([^\\t]*)\\t[^\\t]*\\t[^\\t]*\\t([^\\t]*)\\t([^\\t]*)\\t[^\\t]*\\t[^\\t]*\\t([^\\t]*)\\t[^\\t]*";
		$pos_rc=1;$pos_logname=2;$pos_agent=3;$pos_date=4;$pos_referer=5;$pos_size=6;$pos_method=7;$pos_url=8;$pos_code=9;
		$lastrequiredfield=9;
	}
	if ($LogFormat lt "1" || $LogFormat gt "5") {
		# Scan $LogFormat to found all required fields and generate PerlParsing
		my @fields = split(/ +/, $LogFormatString); # make array of entries
		my $i = 1;
		foreach my $f (@fields) {
			my $found=0;
			if ($f =~ /%host$/) {
				$found=1; 
				$pos_rc = $i; $i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%logname$/) {
				$found=1; 
				$pos_logname = $i; $i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%time1$/) {
				$found=1; 
				$pos_date = $i;
				$i++;
				#$pos_zone = $i;
				$i++;
				$PerlParsingFormat .= "\\[([^\\s]*) ([^\\s]*)\\] ";
			}
			if ($f =~ /%time2$/) {
				$found=1; 
				$pos_date = $i;
				$i++;
				$PerlParsingFormat .= "([^\\s]* [^\\s]*) ";
			}
			if ($f =~ /%methodurl$/) {
				$found=1; 
				$pos_method = $i;
				$i++;
				$pos_url = $i;
				$i++;
				$PerlParsingFormat .= "\\\"([^\\s]*) ([^\\s]*) [^\\\"]*\\\" ";
			}
			if ($f =~ /%methodurlnoprot$/) {
				$found=1; 
				$pos_method = $i;
				$i++;
				$pos_url = $i;
				$i++;
				$PerlParsingFormat .= "\\\"([^\\s]*) ([^\\s]*)\\\" ";
			}
			if ($f =~ /%method$/) {
				$found=1; 
				$pos_method = $i;
				$i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%url$/) {
				$found=1; 
				$pos_url = $i;
				$i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%query$/) {
				$found=1; 
				$pos_query = $i;
				$i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%code$/) {
				$found=1; 
				$pos_code = $i;
				$i++;
				$PerlParsingFormat .= "([\\d|-]*) ";
			}
			if ($f =~ /%bytesd$/) {
				$found=1; 
				$pos_size = $i; $i++;
				$PerlParsingFormat .= "([\\d|-]*) ";
			}
			if ($f =~ /%refererquot$/) {
				$found=1;
				$pos_referer = $i; $i++;
				$PerlParsingFormat .= "\\\"(.*)\\\" ";
			}
			if ($f =~ /%referer$/) {
				$found=1;
				$pos_referer = $i; $i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%uaquot$/) {
				$found=1; 
				$pos_agent = $i; $i++;
				$PerlParsingFormat .= "\\\"([^\\\"]*)\\\" ";
			}
			if ($f =~ /%ua$/) {
				$found=1; 
				$pos_agent = $i; $i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%gzipin$/ ) {
				$found=1;
				$pos_gzipin=$i;$i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%gzipout$/ ) {
				$found=1;
				$pos_gzipout=$i;$i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%gzipres$/ ) {
				$found=1;
				$pos_gzipres=$i;$i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if (! $found) { $found=1; $PerlParsingFormat .= "[^\\s]* "; }
		}
		# Remove last space char
		($PerlParsingFormat) ? chop($PerlParsingFormat) : error("Error: No recognised format tag in personalised LogFormat string"); 
		$lastrequiredfield=$i--;
	}
	if (! $pos_rc) { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%host in your LogFormat string)."); }
	if (! $pos_date) { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%time1 or \%time2 in your LogFormat string)."); }
	if (! $pos_method) { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%methodurl or \%method in your LogFormat string)."); }
	if (! $pos_url) { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%methodurl or \%url in your LogFormat string)."); }
	if (! $pos_code) { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%code in your LogFormat string)."); }
	if (! $pos_size) { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%bytesd in your LogFormat string)."); }
	&debug("PerlParsingFormat is $PerlParsingFormat");


	# READING THE LAST PROCESSED HISTORY FILE
	#------------------------------------------
	my $monthtoprocess=0; my $yeartoprocess=0;

	# Search last history file $PROG(MM)(YYYY)$FileSuffix.txt
	my $yearmonthmax=0;
	opendir(DIR,"$DirData");
	@filearray = sort readdir DIR;
	close DIR;
	foreach my $i (0..$#filearray) {
		if ("$filearray[$i]" =~ /^$PROG([\d][\d])([\d][\d][\d][\d])$FileSuffix\.txt$/) {
			if (int("$2$1") > $yearmonthmax) { $yearmonthmax=int("$2$1"); }
		}
	}
	# We read last history file if found
	if ($yearmonthmax =~ /^([\d][\d][\d][\d])([\d][\d])$/) {
		$monthtoprocess=int($2);$yeartoprocess=int($1);
		# We read LastTime in this last history file.
		&Read_History_File($yeartoprocess,$monthtoprocess,1);
	}
	else {
		$LastLine{"000000"}=0;
	}

	# PROCESSING CURRENT LOG
	#------------------------------------------
	&debug("Start of processing log file (monthtoprocess=$monthtoprocess, yeartoprocess=$yeartoprocess)");
	my $yearmonth=sprintf("%04i%02i",$yeartoprocess,$monthtoprocess);
	$NbOfLinesRead=0; $NbOfNewLinesProcessed=0; $NbOfLinesCorrupted=0;
	$NowNewLinePhase=0;

	# Open log file
	&debug("Open log file \"$LogFile\"");
	open(LOG,"$LogFile") || error("Error: Couldn't open server log file \"$LogFile\" : $!");

	# Reset counter for benchmark (first call to GetDelaySinceStart)
	GetDelaySinceStart(1);

	while (<LOG>)
	{
		if (/^#/) { next; }									# Ignore comment lines (ISS writes such comments)
		if (/^!/) { next; }									# Ignore comment lines (Webstar writes such comments)
		#if (/^$/) { next; }								# Ignore blank lines (With ISS: happens sometimes, with Apache: possible when editing log file)
		chomp $_; s/\r//;

		$NbOfLinesRead++;

		# Parse line record to get all required fields
		/^$PerlParsingFormat/;
		my @field=();
		foreach $i (1..$lastrequiredfield) { $field[$i]=$$i; }
 		&debug(" Record $NbOfLinesRead is ($lastrequiredfield fields read) : host=\"$field[$pos_rc]\", logname=\"$field[$pos_logname]\", date=\"$field[$pos_date]\", method=\"$field[$pos_method]\", url=\"$field[$pos_url]\", code=\"$field[$pos_code]\", size=\"$field[$pos_size]\", referer=\"$field[$pos_referer]\", agent=\"$field[$pos_agent]\"",3);

		# Check parsed parameters
		#----------------------------------------------------------------------
		if (! $field[$pos_code]) {
			$NbOfLinesCorrupted++;
			if ($ShowCorrupted && $_ =~ /^\s*$/) { print "Corrupted record (blank line)\n"; }
			if ($ShowCorrupted && $_ !~ /^\s*$/) { print "Corrupted record (corrupted HTTP code): $_\n"; }
			if ($NbOfLinesRead >= $NbOfLinesForCorruptedLog && $NbOfLinesCorrupted == $NbOfLinesRead) { error("Format error",$_,$LogFile); }	# Exit with format error
			next;
		}

		# Check filters
		#----------------------------------------------------------------------
		my $protocol=0;	
		if ($field[$pos_method] eq 'GET' || $field[$pos_method] eq 'POST' || $field[$pos_method] =~ /OK/) {
			# HTTP request.	Keep only GET, POST, *OK* with Webstar but not HEAD, OPTIONS
			$protocol=1;
			}
		elsif ($field[$pos_method] =~ /sent/ || $field[$pos_method] =~ /get/) {
			# FTP request.
			$protocol=2;
		}	
		if (! $protocol) { next; }
		
		# Split DD/Month/YYYY:HH:MM:SS or YYYY-MM-DD HH:MM:SS or MM/DD/YY\tHH:MM:SS
		$field[$pos_date] =~ tr/-\/ \t/::::/;
		my @dateparts=split(/:/,$field[$pos_date]);
		if ($field[$pos_date] =~ /^....:..:..:/) { $tmp=$dateparts[0]; $dateparts[0]=$dateparts[2]; $dateparts[2]=$tmp; }
		if ($field[$pos_date] =~ /^..:..:..:/) { $dateparts[2]+=2000; $tmp=$dateparts[0]; $dateparts[0]=$dateparts[1]; $dateparts[1]=$tmp; }
		if ($monthnum{$dateparts[1]}) { $dateparts[1]=$monthnum{$dateparts[1]}; }	# Change lib month in num month if necessary
		# Create $timeconnexion like YYYYMMDDHHMMSS
		my $timeconnexion=int($dateparts[2].$dateparts[1].$dateparts[0].$dateparts[3].$dateparts[4].$dateparts[5]);
		my $dayconnexion=$dateparts[2].$dateparts[1].$dateparts[0];
		if ($timeconnexion < 10000000000000) { $NbOfLinesCorrupted++; if ($ShowCorrupted) { print "Corrupted record (invalid date): $_\n"; } next; }		# Should not happen, kept in case of parasite/corrupted line
		if ($timeconnexion > $timetomorrow) { $NbOfLinesCorrupted++; if ($ShowCorrupted) { print "Corrupted record (invalid date): $_\n"; } next; }		# Should not happen, kept in case of parasite/corrupted line

		# Skip if not a new line
		#-----------------------
		if ($NowNewLinePhase) {
			if ($timeconnexion < $LastLine{$yearmonth}) { $NbOfLinesCorrupted++; if ($ShowCorrupted) { print "Corrupted record (not sorted record): $_\n"; } next; }	# Should not happen, kept in case of parasite/corrupted old line
		}
		else {
			if ($timeconnexion <= $LastLine{$yearmonth}) {
				if ($ShowSteps && ($NbOfLinesRead % $NbOfLinesForBenchmark == 0)) {
					my $delay=GetDelaySinceStart(0); if ($delay < 1) { $delay=1000; }
					print "$NbOfLinesRead lines read already processed ($delay ms, ".int(1000*$NbOfLinesRead/$delay)." lines/seconds)\n";
				}
				next;
			}	# Already processed
			# We found a new line. This will stop comparison "<=" between timeconnexion and LastLine (we should have only new lines now)
			$NowNewLinePhase=1;	
			#GetDelaySinceStart(1);
		}

		# Here, field array, datepart array, timeconnexion and dayconnexion are init for log record
		&debug(" This is a not already processed record",3);

		# Record is approved. We found a new line
		#----------------------------------------
		$NbOfNewLinesProcessed++;
		if ($ShowSteps && ($NbOfNewLinesProcessed % $NbOfLinesForBenchmark == 0)) {
			my $delay=GetDelaySinceStart(0);
			print "$NbOfNewLinesProcessed lines processed ($delay ms, ".int(1000*$NbOfNewLinesProcessed/($delay>0?$delay:1))." lines/seconds)\n";
		}

		$LastLine{$yearmonth} = $timeconnexion;

		# TODO. Add as a robot if URL is robots.txt
		
		if (&SkipHost($field[$pos_rc])) { next; }		# Skip with some client host IP addresses
		if (&SkipFile($field[$pos_url])) { next; }		# Skip with some URLs
		if (! &OnlyFile($field[$pos_url])) { next; }	# Skip with other URLs

		# Is it in a new month section ?
		#-------------------------------
		if (((int($dateparts[1]) > $monthtoprocess) && (int($dateparts[2]) >= $yeartoprocess)) || (int($dateparts[2]) > $yeartoprocess)) {
			# Yes, a new month to process
			if ($monthtoprocess > 0) {
				&Save_History_File($yeartoprocess,$monthtoprocess);		# We save data of current processed month
 				&Init_HashArray($yeartoprocess,$monthtoprocess);		# Start init for next one
			}
			$monthtoprocess=int($dateparts[1]);$yeartoprocess=int($dateparts[2]);
			$yearmonth=sprintf("%04i%02i",$yeartoprocess,$monthtoprocess);
			&Read_History_File($yeartoprocess,$monthtoprocess,1);		# This should be useless (file must not exist)
		}

		# Check return code
		#------------------
		if ($protocol == 1) {
			if ($field[$pos_code]==304) {
				$field[$pos_size]=0;
			}
			else {
				if ($field[$pos_code] != 200) {	# Stop if HTTP server return code != 200 and 304
					if ($field[$pos_code] =~ /^[\d][\d][\d]$/) { 				# Keep error code and next
						$_errors_h{$field[$pos_code]}++;
						if ($field[$pos_code] == 404) { $_sider404_h{$field[$pos_url]}++; $_referer404_h{$field[$pos_url]}=$field[$pos_referer]; }
						next;
					}
					else {														# Bad format record (should not happen but when using MSIndex server), next
						$NbOfLinesCorrupted++;
						if ($ShowCorrupted) { print "Corrupted record (HTTP code not on 3 digits): $_\n"; }
						next;
					}
				}
			}
		}
	
		$field[$pos_agent] =~ tr/\+ /__/;		# Same Agent with different writing syntax have now same name
		$field[$pos_agent] =~ s/%20/_/g;		# This is to support Roxen webserver that writes user agent with %20 in it
		$UserAgent = $field[$pos_agent];
		$UserAgent =~ tr/A-Z/a-z/;

		# Robot ?
		#-------------------------------------------------------------------------
		if (!$TmpHashRobot{$UserAgent}) {	# TmpHashRobot is a temporary hash table to increase speed
			# If made on each record -> -1300 rows/seconds
			my $foundrobot=0;
			# study $UserAgent
			foreach my $bot (@RobotArrayID) {
				if ($UserAgent =~ /$bot/) {
					$foundrobot=1;
					$TmpHashRobot{$UserAgent}="$bot";	# Last time, we won't search if robot or not. We know it's is.
					last;
				}
			}
			if (! $foundrobot) {						# Last time, we won't search if robot or not. We know it's not.	
				$TmpHashRobot{$UserAgent}="-";
			}
		}
		# If robot, we stop here 
		if ($TmpHashRobot{$UserAgent} ne "-") {
			debug("UserAgent $UserAgent contains robot ID '$TmpHashRobot{$UserAgent}'",2);
			$_robot_h{$TmpHashRobot{$UserAgent}}++; $_robot_l{$TmpHashRobot{$UserAgent}}=$timeconnexion; 
			next;
		}
		
		# Canonize and clean target URL and referrer URL. Possible URL syntax for $field[$pos_url]:
		# /mypage.ext?param=x#aaa
		# /mypage.ext#aaa
		# /
		my $urlwithnoquery;
		if ($URLWithQuery) { 				
			$urlwithnoquery=$field[$pos_url];
			$urlwithnoquery =~ s/\?.*//;
			# We combine the URL and query strings.
			if ($field[$pos_query] && ($field[$pos_query] ne "-")) { $field[$pos_url] .= "?" . $field[$pos_query]; }
		}
		else {
			# Trunc CGI parameters in URL
			$field[$pos_url] =~ s/\?.*//;
			$urlwithnoquery=$field[$pos_url];
		}
		# urlwithnoquery=/mypage.ext
		$field[$pos_url] =~ s/\/$DefaultFile$/\//;	# Replace default page name with / only

		# Analyze file type and compression
		#----------------------------------
		my $PageBool=1;
		my $extension;

		# Extension
		if ($urlwithnoquery =~ /\.(\w{1,5})$/) {
			$extension=$1; $extension =~ tr/A-Z/a-z/;
			# Check if not a page
			foreach my $cursor (@NotPageList) { if ($extension eq $cursor) { $PageBool=0; last; } }
		} else {
			$extension="Unknown";
		}
		$_filetypes_h{$extension}++;
		$_filetypes_k{$extension}+=$field[$pos_size];
		# Compression
		if ($pos_gzipin && $field[$pos_gzipin]) {
			my ($a,$b)=split(":",$field[$pos_gzipres]);
			my ($notused,$in)=split(":",$field[$pos_gzipin]);
			my ($notused1,$out,$notused2)=split(":",$field[$pos_gzipout]);
			if ($out) {
				$_filetypes_gz_in{$extension}+=$in;
				$_filetypes_gz_out{$extension}+=$out;
			}
		}

		# Analyze: Date - Hour - Pages - Hits - Kilo
		#-------------------------------------------
		if ($PageBool) {
			# FirstTime and LastTime are First and Last human visits (so changed if access to a page)
			if (! $FirstTime{$yearmonth}) { $FirstTime{$yearmonth}=$timeconnexion; }
			$LastTime{$yearmonth} = $timeconnexion;
			$DayPages{$dayconnexion}++;
			$MonthPages{$yearmonth}++;
			$_time_p[int($dateparts[3])]++;												#Count accesses for hour (page)
			$_url_p{$field[$pos_url]}++; 												#Count accesses for page (page)
			$_url_k{$field[$pos_url]}+=$field[$pos_size];
			}
		$_time_h[int($dateparts[3])]++; $MonthHits{$yearmonth}++; $DayHits{$dayconnexion}++;	#Count accesses for hour (hit)
		$_time_k[int($dateparts[3])]+=$field[$pos_size]; $MonthBytes{$yearmonth}+=$field[$pos_size]; $DayBytes{$dayconnexion}+=$field[$pos_size];	#Count accesses for hour (kb)

		# Analize login
		#--------------
		if ($field[$pos_logname] && $field[$pos_logname] ne "-") {
			# We found an authenticated user
			if ($PageBool) {
				$_login_p{$field[$pos_logname]}++;										#Count accesses for page (page)
			}
			$_login_h{$field[$pos_logname]}++;											#Count accesses for page (hit)
			$_login_k{$field[$pos_logname]}+=$field[$pos_size];							#Count accesses for page (kb)
			$_login_l{$field[$pos_logname]}=$timeconnexion;
		}

		# Analyze: IP-address
		#--------------------
		my $found=0;
		$Host=$field[$pos_rc];
		if ($Host =~ /^[\d]+\.[\d]+\.[\d]+\.[\d]+$/) {
			my $newip;
			# Doing DNS lookup
		    if ($NewDNSLookup) {
				$newip=$TmpHashDNSLookup{$Host};	# TmpHashDNSLookup is a temporary hash table to increase speed
				if (!$newip) {						# if $newip undefined, $Host not yet resolved
					&debug("Start of reverse DNS lookup for $Host",4);
					if ($MyDNSTable{$Host}) {
					$newip = $MyDNSTable{$Host};
						&debug("End of reverse DNS lookup for $Host. Found '$newip' in local MyDNSTable",4);
					}
					else {
						if (&SkipDNSLookup($Host)) {
							&debug("Skip this DNS lookup at user request",4);
						}
						else {
							$newip=gethostbyaddr(pack("C4",split(/\./,$Host)),AF_INET);	# This is very slow, may took 20 seconds
							if (! IsAscii($newip)) { $newip="ip"; }	# If DNSLookup corrupted answer, we treat it as Unknown
						}
						&debug("End of reverse DNS lookup for $Host. Found '$newip'",4);
					}
					if ($newip eq "") { $newip="ip"; }
					$TmpHashDNSLookup{$Host}=$newip;
				}
				# Here $Host is still xxx.xxx.xxx.xxx and $newip is name or "ip" if reverse failed)
				if ($newip ne "ip") { $Host=$newip; }
			}
		    # If we don't do lookup or if it failed, we still have an IP address in $Host
		    if (!$NewDNSLookup || $newip eq "ip") {
				if ($PageBool) {
				  		if ($timeconnexion > (($_hostmachine_l{$Host}||0)+$VisitTimeOut)) {
				  			$MonthVisits{$yearmonth}++;
				  			$DayVisits{$dayconnexion}++;
							if (! $_hostmachine_l{$Host}) { $MonthUnique{$yearmonth}++; }
							$_url_e{$field[$pos_url]}++; 	# Increase 'entry' page
				  		}
						$_hostmachine_p{$Host}++;
						$_hostmachine_l{$Host}=$timeconnexion;
						$_domener_p{"ip"}++;
				}
				if (! $_hostmachine_h{$Host}) {	$MonthHostsUnknown{$yearmonth}++; }
				$_hostmachine_h{$Host}++;
				$_hostmachine_k{$Host}+=$field[$pos_size];
				$_domener_h{"ip"}++;
				$_domener_k{"ip"}+=$field[$pos_size];
				$found=1;
			}
		}
		else {
			if ($Host =~ /[a-z]/) { 
				&debug("The following hostname '$Host' seems to be already resolved.",3);
				$NewDNSLookup=0;
			}
		}	# Hosts seems to be already resolved, make DNS lookup inactive

		# Here, $Host = hostname or xxx.xxx.xxx.xxx
		if (!$found) {	# If not processed yet
			# Here $Host = hostname
			$_ = $Host;
			tr/A-Z/a-z/;

			# Count hostmachine
			if (!$FullHostName) { s/^[\w\-]+\.//; };
			if ($PageBool) {
				if ($timeconnexion > (($_hostmachine_l{$_}||0)+$VisitTimeOut)) {
					# This is a new visit
					$MonthVisits{$yearmonth}++;
					$DayVisits{$dayconnexion}++;
					if (! $_hostmachine_l{$_}) { $MonthUnique{$yearmonth}++; }
					$_url_e{$field[$pos_url]}++; 	# Increase 'entry' page
				}
				$_hostmachine_p{$_}++;
				$_hostmachine_l{$_}=$timeconnexion;
				}
			if (! $_hostmachine_h{$_}) { $MonthHostsKnown{$yearmonth}++; }
			$_hostmachine_h{$_}++;
			$_hostmachine_k{$_}+=$field[$pos_size];

			# Count top-level domain
			if (/\.([\w]+)$/) { $_=$1; }
			if ($DomainsHashIDLib{$_}) {
				 if ($PageBool) { $_domener_p{$_}++; }
				 $_domener_h{$_}++;
				 $_domener_k{$_}+=$field[$pos_size];
				 }
			else {
				 if ($PageBool) { $_domener_p{"ip"}++; }
				 $_domener_h{"ip"}++;
				 $_domener_k{"ip"}+=$field[$pos_size];
			}
		}

		if ($UserAgent) {	 # Made on each record -> -100 rows/seconds

			# Analyze: Browser
			#-----------------
			my $found=0;
			if (!$TmpHashBrowser{$UserAgent}) {
				# IE ? (For higher speed, we start whith IE, the most often used. This avoid other tests if found)
				if (($UserAgent =~ /msie/) && ($UserAgent !~ /webtv/) && ($UserAgent !~ /omniweb/) && ($UserAgent !~ /opera/)) {
					$_browser_h{"msie"}++;
					if ($UserAgent =~ /msie_(\d)\./) {  # $1 now contains major version no
						$_msiever_h[$1]++;
						$found=1;
						$TmpHashBrowser{$UserAgent}="msie_$1";
					}
				}
		
				# Netscape ?
				if (!$found) {
					if (($UserAgent =~ /mozilla/) && ($UserAgent !~ /compatible/) && ($UserAgent !~ /opera/)) {
				    	$_browser_h{"netscape"}++;
				    	if ($UserAgent =~ /\/(\d)\./) {		# $1 now contains major version no
				    		$_nsver_h[$1]++;
				    		$found=1;
							$TmpHashBrowser{$UserAgent}="netscape_$1";
						}
					}
				}
		
				# Other ?
				if (!$found) {
					foreach my $key (@BrowsersArrayID) {
				    	if ($UserAgent =~ /$key/) {
				    		$_browser_h{$key}++;
				    		$found=1;
				    		$TmpHashBrowser{$UserAgent}=$key;
				    		last;
				    	}
					}
				}
	
				# Unknown browser ?
				if (!$found) {
					$_browser_h{"Unknown"}++;
					$_unknownrefererbrowser_l{$field[$pos_agent]}=$timeconnexion;
#					$TmpHashBrowser{$UserAgent}="Unknown";
				}
			}
			else {
				if ($TmpHashBrowser{$UserAgent} =~ /^msie_(\d)/) { $_browser_h{"msie"}++; $_msiever_h[$1]++; $found=1; }
				if (!$found && $TmpHashBrowser{$UserAgent} =~ /^netscape_(\d)/) { $_browser_h{"netscape"}++; $_nsver_h[$1]++; $found=1; }
				if (!$found) { $_browser_h{$TmpHashBrowser{$UserAgent}}++; }
			}

			# Analyze: OS
			#------------
			if (!$TmpHashOS{$UserAgent}) {
				my $found=0;
				# in OSHashID list ?
				foreach my $key (@OSArrayID) {	# Searchin ID in order of OSArrayID
					if ($UserAgent =~ /$key/) {
						$_os_h{$OSHashID{$key}}++;
						$found=1;
						$TmpHashOS{$UserAgent}=$OSHashID{$key};
						last;
					}
				}
				# Unknown OS ?
				if (!$found) {
					$_os_h{"Unknown"}++;
					$_unknownreferer_l{$field[$pos_agent]}=$timeconnexion;
#					$TmpHashOS{$UserAgent}="Unknown";
				}
			}
			else {
				$_os_h{$TmpHashOS{$UserAgent}}++;
			}
		}
		else {
			$_browser_h{"Unknown"}++;
			$_os_h{"Unknown"}++;
		}		




		# Analyze: Referer
		#-----------------
		$found=0;
		if ($field[$pos_referer]) {

			# Direct ?
			if ($field[$pos_referer] eq "-") { 
				if ($PageBool) { $_from_p[0]++; }
				$_from_h[0]++;
				$found=1;
			}
			else {	
				$field[$pos_referer] =~ /^(\w+):\/\/([^\/]*)\//;
				my $refererprot=$1;
				my $refererserver=$2;

				# HTML link ?
				if ($refererprot =~ /^http/i) {

					# Kind of origin
					if (!$TmpHashRefererServer{$refererserver}) {
						if ($refererserver =~ /^(www\.|)$SiteToAnalyzeWithoutwww/i) {
						    # Intern (This hit came from another page of the site)
							debug("Server $refererserver is added to TmpHashRefererServer with value '='",2);
							$TmpHashRefererServer{$refererserver}="=";
							$found=1;
						}
						if (! $found) {
							foreach my $key (@HostAliases) {
								if ($refererserver =~ /^$key/i) {
								    # Intern (This hit came from another page of the site)
									debug("Server $refererserver is added to TmpHashRefererServer with value '='",2);
									$TmpHashRefererServer{$refererserver}="=";
									$found=1;
									last;
								}
							}
						}
						if (! $found) {
						    # Extern (This hit came from an external web site). 
							# If made on each record -> -1700 rows/seconds (should be made on 10% of records only)
						    foreach my $key (keys %SearchEnginesHashIDLib) {
								# This hit came from the search engine $key
								if ($refererserver =~ /$key/i) {
									debug("Server $refererserver is added to TmpHashRefererServer with value '$key'",2);
									$TmpHashRefererServer{$refererserver}="$key";
									$found=1;
								}
							}
						}
					}
					
					if ($TmpHashRefererServer{$refererserver}) {
						if ($TmpHashRefererServer{$refererserver} eq "=") {
						    # Intern (This hit came from another page of the site)
							if ($PageBool) { $_from_p[4]++; }
					    	$_from_h[4]++;
					    }
					    else {
							# This hit came from the search engine
							if ($PageBool) { $_from_p[2]++; }
							$_from_h[2]++;
							$_se_referrals_h{$TmpHashRefererServer{$refererserver}}++;
							$found=1;
							my @refurl=split(/\?/,$field[$pos_referer],2);
							if ($refurl[1]) {								
								# Extract keywords
								$refurl[1] =~ tr/A-Z/a-z/;				# Full param string in lowcase
								my @paramlist=split(/&/,$refurl[1]);
								if ($SearchEnginesKnownUrl{$TmpHashRefererServer{$refererserver}}) {	# Search engine with known URL syntax
									foreach my $param (@paramlist) {
										#if ($param =~ /^$SearchEnginesKnownUrl{$key}/) { 	# We found good parameter
										#	$param =~ s/^$SearchEnginesKnownUrl{$key}//;	# Cut "xxx="
										if ($param =~ s/^$SearchEnginesKnownUrl{$TmpHashRefererServer{$refererserver}}//) { 	# We found good parameter
											# Ok, "cache:mmm:www/zzz+aaa+bbb/ccc+ddd%20eee'fff,ggg" is a search parameter line
											$param =~ s/^cache:[^\+]*//;
											$param =~ s/^related:[^\+]*//;
											&ChangeWordSeparatorsIntoSpace($param);			# Change [ aaa+bbb/ccc+ddd%20eee'fff,ggg ] into [ aaa bbb/ccc ddd eee fff ggg]
											if ($SplitSearchString) {
												my @wordlist=split(/ /,$param);	# Split aaa bbb ccc ddd eee fff into a wordlist array
												foreach $word (@wordlist) {
													if ((length $word) > 0) { $_keyphrases{$word}++; }
												}
											}
											else {
												$param =~ s/^ +//; $param =~ s/ +$//; $param =~ tr/ /\+/s;
												if ((length $param) > 0) { $_keyphrases{$param}++; }
											}
											last;
										}
									}
								}
								else {									# Search engine with unknown URL syntax
									foreach my $param (@paramlist) {
										&ChangeWordSeparatorsIntoSpace($param);				# Change [ xxx=cache:www/zzz+aaa+bbb/ccc+ddd%20eee'fff,ggg ] into [ xxx=cache:www/zzz aaa bbb/ccc ddd eee fff ggg ]
										my $foundparam=1;
										foreach $paramtoexclude (@WordsToCleanSearchUrl) {
											if ($param =~ /.*$paramtoexclude.*/) { $foundparam=0; last; } # Not the param with search criteria
										}
										if ($foundparam == 0) { next; }			# Do not keep this URL parameter because is in exclude list
										# Ok, "xxx=cache:www/zzz aaa bbb/ccc ddd eee fff ggg" is a search parameter line
										$param =~ s/.*=//;						# Cut "xxx="
										$param =~ s/^cache:[^ ]*//;
										$param =~ s/^related:[^ ]*//;
										if ($SplitSearchString) {
											my @wordlist=split(/ /,$param);		# Split aaa bbb ccc ddd eee fff into a wordlist array
											foreach $word (@wordlist) {
												if ((length $word) > 2) { $_keyphrases{$word}++; }	# Keep word only if word length is 3 or more
											}
										}
										else {
											$param =~ s/^ +//; $param =~ s/ +$//; $param =~ tr/ /\+/s;
											if ((length $param) > 2) { $_keyphrases{$param}++; }
										}
									}
								}
							}	# End of if refurl[1]
						}
					}	# End of if ($TmpHashRefererServer) 
					else {
						# This hit came from a site other than a search engine
						if ($PageBool) { $_from_p[3]++; }
						$_from_h[3]++;
						# http://www.mysite.com/ must be same referer than http://www.mysite.com but .../mypage/ differs of .../mypage
						#if ($refurl[0] =~ /^[^\/]+\/$/) { $field[$pos_referer] =~ s/\/$//; }	# Code moved in save
						$_pagesrefs_h{$field[$pos_referer]}++;
						$found=1;
					}
				}

				# News Link ?
				if (! $found && $refererprot =~ /^news/i) {
					$found=1;
					if ($PageBool) { $_from_p[5]++; }
			    	$_from_h[5]++;
				}
			}
		}	

		# Origin not found
		if (!$found) {
			if ($PageBool) { $_from_p[1]++; }
			$_from_h[1]++;
		}

		# End of processing all new records.

	}
	&debug("End of processing log file(s)");

	&debug("Close log file");
	close LOG;

	# DNSLookup warning
	if ($DNSLookup && !$NewDNSLookup) { warning("Warning: <b>$PROG</b> has detected that hosts names are already resolved in your logfile <b>$LogFile</b>.<br>\nIf this is always true, you should change your setup DNSLookup=1 into DNSLookup=0 to increase $PROG speed."); }

	# Save current processed month $monthtoprocess
	if ($UpdateStats && $monthtoprocess) {	# If monthtoprocess is still 0, it means there was no history files and we found no valid lines in log file
		&Save_History_File($yeartoprocess,$monthtoprocess);		# We save data for this month,year
		if (($MonthRequired ne "year") && ($monthtoprocess != $MonthRequired)) { &Init_HashArray($yeartoprocess,$monthtoprocess); }	# Not a desired month (wrong month), so we clean data arrays
		if (($MonthRequired eq "year") && ($yeartoprocess != $YearRequired)) { &Init_HashArray($yeartoprocess,$monthtoprocess); }	# Not a desired month (wrong year), so we clean data arrays
	}

	# Archive LOG file into ARCHIVELOG
	if (($PurgeLogFile == 1) && ($ArchiveLogRecords == 1)) {
		&debug("Start of archiving log file");
		$ArchiveFileName="$DirData/${PROG}_archive$FileSuffix.log";
		open(LOG,"+<$LogFile") || error("Error: Enable to archive log records of \"$LogFile\" into \"$ArchiveFileName\" because source can't be opened for read and write: $!<br>\n");
		open(ARCHIVELOG,">>$ArchiveFileName") || error("Error: Couldn't open file \"$ArchiveFileName\" to archive current log: $!");
		while (<LOG>) {	print ARCHIVELOG $_; }
		close(ARCHIVELOG);
		chmod 0666,"$ArchiveFileName";
		&debug("End of archiving log file");
	}
	else {
		open(LOG,"+<$LogFile");
	}

	# Rename all HISTORYTMP files into HISTORYTXT
	my $allok=1;
	opendir(DIR,"$DirData");
	@filearray = sort readdir DIR;
	close DIR;
	foreach my $i (0..$#filearray) {
		my $pid=$$;
		if ("$filearray[$i]" =~ /^$PROG(\d\d\d\d\d\d)$FileSuffix\.tmp\.$pid$/) {
			debug("Rename new tmp historic $PROG$1$FileSuffix.tmp.$$ into $PROG$1$FileSuffix.txt",1);
			if (-s "$DirData/$PROG$1$FileSuffix.tmp.$$") {		# Rename files of this session with size > 0
				if ($KeepBackupOfHistoricFiles) {
					if (-s "$DirData/$PROG$1$FileSuffix.txt") {	# Historic file already exists. We backup it
						debug(" Make a backup of old historic file into $PROG$1$FileSuffix.bak before",1);
						#if (FileCopy("$DirData/$PROG$1$FileSuffix.txt","$DirData/$PROG$1$FileSuffix.bak")) {
						if (rename("$DirData/$PROG$1$FileSuffix.txt", "$DirData/$PROG$1$FileSuffix.bak")==0) {
							warning("Warning: Failed to make a backup of \"$DirData/$PROG$1$FileSuffix.txt\" into \"$DirData/$PROG$1$FileSuffix.bak\".\n");
						}
						chmod 0666,"$DirData/$PROG$1$FileSuffix.bak";
					}
					else {
						debug(" No need to backup old historic file",1);
					}
				}
				if (rename("$DirData/$PROG$1$FileSuffix.tmp.$$", "$DirData/$PROG$1$FileSuffix.txt")==0) {
					$allok=0;	# At least one error in renaming working files
					# Remove file
					unlink "$DirData/$PROG$1$FileSuffix.tmp.$$";
					warning("Warning: Failed to rename \"$DirData/$PROG$1$FileSuffix.tmp.$$\" into \"$DirData/$PROG$1$FileSuffix.txt\".\nWrite permissions on \"$PROG$1$FileSuffix.txt\" might be wrong".($ENV{"GATEWAY_INTERFACE"}?" for an 'update from web'":"")." or file might be opened.");
					last;
				}
				chmod 0666,"$DirData/$PROG$1$FileSuffix.txt";
			}
		}
	}

	# Purge Log file if all renaming are ok and option is on
	if (($allok > 0) && ($PurgeLogFile == 1)) {
		truncate(LOG,0) || warning("Warning: <b>$PROG</b> couldn't purge logfile \"<b>$LogFile</b>\".<br>\nChange your logfile permissions to allow write for your web server<br>\nor change PurgeLofFile=1 into PurgeLogFile=0 in configure file<br>\n(and think to purge sometines your logile. Launch $PROG just before this to save in $PROG history text files all informations logfile contains).");
	}
	close(LOG);

}
# End of log processing



#---------------------------------------------------------------------
# SHOW REPORT
#---------------------------------------------------------------------

if ($HTMLOutput) {
	
	my @filearray;
	my %listofyears;
	my $max_p; my $max_h; my $max_k; my $max_v;
	my $rest_p; my $rest_h; my $rest_k; my $rest_e; my $rest_s;
	my $total_p; my $total_h; my $total_k; my $total_e; my $total_s;

	$SiteToAnalyze =~ s/\\\./\./g;

	# Get list of all possible years
	opendir(DIR,"$DirData");
	@filearray = sort readdir DIR;
	close DIR;
	#my $yearmin=0;
	foreach my $i (0..$#filearray) {
		if ("$filearray[$i]" =~ /^$PROG([\d][\d])([\d][\d][\d][\d])$FileSuffix\.txt$/) {
			$listofyears{$2}=1; 
			#if (int("$2") < $yearmin || $yearmin == 0) { $yearmin=int("$2"); }
		}
	}
	#foreach my $i ($yearmin..$nowyear) { $listofyears{$i}=1; }

	# Here, first part of data for processed month (old and current) are still in memory
	# If a month was already processed, then $HistoryFileAlreadyRead{"MMYYYY"} value is 1
	
	# READING NOW ALL NOT ALREADY READ HISTORY FILES FOR ALL MONTHS OF REQUIRED YEAR
	#-------------------------------------------------------------------------------
	# Loop on each month of year but only existing and not already read will be read by Read_History_File function
	for (my $ix=12; $ix>=1; $ix--) {
		my $monthix=$ix+0; if ($monthix < 10) { $monthix  = "0$monthix"; }	# Good trick to change $monthix into "MM" format
		if ($MonthRequired eq "year" || $monthix == $MonthRequired) {
			&Read_History_File($YearRequired,$monthix,1);	# Read full history file
		}
		else {
			&Read_History_File($YearRequired,$monthix,0);	# Read first part of history file is enough (for the month graph)
		}
	}
	
	
	# Get the tooltips texts
	&Read_Language_Tooltip($Lang);
	
	# Position .style.pixelLeft/.pixelHeight/.pixelWidth/.pixelTop	IE OK	Opera OK
	#          .style.left/.height/.width/.top											Netscape OK
	# document.getElementById										IE OK	Opera OK	Netscape OK
	# document.body.offsetWidth|document.body.style.pixelWidth		IE OK	Opera OK	Netscape OK		Visible width of container
	# document.body.scrollTop                                       IE OK	Opera OK	Netscape OK		Visible width of container
	# tooltip.offsetWidth|tooltipOBJ.style.pixelWidth				IE OK	Opera OK	Netscape OK		Width of an object
	# event.clientXY												IE OK	Opera OK	Netscape KO		Return position of mouse
	print <<EOF;
	
	<script language="javascript">
		function ShowTooltip(fArg)
		{
			var tooltipOBJ = (document.getElementById) ? document.getElementById('tt' + fArg) : eval("document.all['tt" + fArg + "']");
			if (tooltipOBJ != null) {
			    var tooltipLft = (document.body.offsetWidth?document.body.offsetWidth:document.body.style.pixelWidth) - (tooltipOBJ.offsetWidth?tooltipOBJ.offsetWidth:(tooltipOBJ.style.pixelWidth?tooltipOBJ.style.pixelWidth:300)) - 30;
			    if (navigator.appName != 'Netscape') {
					var tooltipTop = (document.body.scrollTop>=0?document.body.scrollTop+10:event.clientY+10);
					if ((event.clientX > tooltipLft) && (event.clientY < (tooltipOBJ.scrollHeight?tooltipOBJ.scrollHeight:tooltipOBJ.style.pixelHeight) + 10)) {
						tooltipTop = (document.body.scrollTop?document.body.scrollTop:document.body.offsetTop) + event.clientY + 20;
					}
					tooltipOBJ.style.pixelLeft = tooltipLft; tooltipOBJ.style.pixelTop = tooltipTop; 
				}
				else {
					var tooltipTop = 10;
					tooltipOBJ.style.left = tooltipLft; tooltipOBJ.style.top = tooltipTop; 
				}
			    tooltipOBJ.style.visibility = "visible";
			}
		}
		function HideTooltip(fArg)
		{
			var tooltipOBJ = (document.getElementById) ? document.getElementById('tt' + fArg) : eval("document.all['tt" + fArg + "']");
			if (tooltipOBJ != null) {
			    tooltipOBJ.style.visibility = "hidden";
			}
		}
	</script>
	
EOF

	# Define the NewLinkParams for main chart
	my $NewLinkParams=${QueryString};
	$NewLinkParams =~ s/update[=]*[^ &]*//;
	$NewLinkParams =~ s/output[=]*[^ &]*//;
	$NewLinkParams =~ s/staticlinks[=]*[^ &]*//;
	$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
	if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }

	# FirstTime LastTime TotalVisits TotalUnique TotalHostsKnown TotalHostsUnknown
	my $FirstTime=$LastTime=$TotalUnique=$TotalVisits=$TotalHostsKnown=$TotalHostsUnKnown=0;
	my $beginmonth=$MonthRequired;my $endmonth=$MonthRequired;
	if ($MonthRequired eq "year") { $beginmonth=1;$endmonth=12; }
	for (my $monthix=$beginmonth; $monthix<=$endmonth; $monthix++) {
		$monthix=$monthix+0; if ($monthix < 10) { $monthix  = "0$monthix"; }	# Good trick to change $month into "MM" format
		if ($FirstTime{$YearRequired.$monthix} && ($FirstTime == 0 || $FirstTime > $FirstTime{$YearRequired.$monthix})) { $FirstTime = $FirstTime{$YearRequired.$monthix}; }
		if ($LastTime < $LastTime{$YearRequired.$monthix}) { $LastTime = $LastTime{$YearRequired.$monthix}; }
		$TotalUnique+=$MonthUnique{$YearRequired.$monthix};					# Wrong in year view
		$TotalVisits+=$MonthVisits{$YearRequired.$monthix};
		$TotalHostsKnown+=$MonthHostsKnown{$YearRequired.$monthix}||0;		# Wrong in year view
		$TotalHostsUnknown+=$MonthHostsUnknown{$YearRequired.$monthix}||0;	# Wrong in year view
	}
	# TotalPages TotalHits TotalBytes
	my $TotalPages=$TotalHits=$TotalBytes=0;
	for (my $ix=0; $ix<=23; $ix++) {
		$TotalPages+=$_time_p[$ix];
		$TotalHits+=$_time_h[$ix];
		$TotalBytes+=$_time_k[$ix];
	}
	# TotalErrors
	my $TotalErrors=0;
	foreach my $key (keys %_errors_h) { $TotalErrors+=$_errors_h{$key}; }
	# TotalEntries (if not already specifically counted, we init it from _url_e hash table)
	if (!$TotalEntries) { foreach my $key (keys %_url_e) { $TotalEntries+=$_url_e{$key}; } }
	# TotalBytesPages (if not already specifically counted, we init it from _url_k hash table)
	if (!$TotalBytesPages) { foreach my $key (keys %_url_k) { $TotalBytesPages+=$_url_k{$key}; } }
	# TotalKeyphrases (if not already specifically counted, we init it from _keyphrases hash table)
	if (!$TotalKeyphrases) { foreach my $key (keys %_keyphrases) { $TotalKeyphrases+=$_keyphrases{$key}; } }
	# TotalDifferentPages (if not already specifically counted, we init it from _url_p hash table)
	if (!$TotalDifferentPages) { $TotalDifferentPages=scalar keys %_url_p; }
	# TotalDifferentKeyphrases (if not already specifically counted, we init it from _keyphrases hash table)
	if (!$TotalDifferentKeyphrases) { $TotalDifferentKeyphrases=scalar keys %_keyphrases; }
	# Define firstdaytocountaverage, lastdaytocountaverage, firstdaytoshowtime, lastdaytoshowtime
	my $firstdaytocountaverage=$nowyear.$nowmonth."01";				# Set day cursor to 1st day of month
	my $firstdaytoshowtime=$nowyear.$nowmonth."01";					# Set day cursor to 1st day of month
	my $lastdaytocountaverage=$nowyear.$nowmonth.$nowday;			# Set day cursor to today
	my $lastdaytoshowtime=$nowyear.$nowmonth."31";					# Set day cursor to last day of month
	if ($MonthRequired eq "year") {
		$firstdaytocountaverage=$YearRequired."0101";				# Set day cursor to 1st day of the required year
	}
	if (($MonthRequired ne $nowmonth && $MonthRequired ne "year") || $YearRequired ne $nowyear) { 
		if ($MonthRequired eq "year") {
			$firstdaytocountaverage=$YearRequired."0101";			# Set day cursor to 1st day of the required year
			$firstdaytoshowtime=$YearRequired."1201";				# Set day cursor to 1st day of last month of required year
			$lastdaytocountaverage=$YearRequired."1231";			# Set day cursor to last day of the required year
			$lastdaytoshowtime=$YearRequired."1231";				# Set day cursor to last day of last month of required year
		}
		else {
			$firstdaytocountaverage=$YearRequired.$MonthRequired."01";	# Set day cursor to 1st day of the required month
			$firstdaytoshowtime=$YearRequired.$MonthRequired."01";		# Set day cursor to 1st day of the required month
			$lastdaytocountaverage=$YearRequired.$MonthRequired."31";	# Set day cursor to last day of the required month
			$lastdaytoshowtime=$YearRequired.$MonthRequired."31";		# Set day cursor to last day of the required month
		}
	}
	debug("firstdaytocountaverage=$firstdaytocountaverage, lastdaytocountaverage=$lastdaytocountaverage",1);
	debug("firstdaytoshowtime=$firstdaytoshowtime, lastdaytoshowtime=$lastdaytoshowtime",1);


	# MENU
	#---------------------------------------------------------------------
	if ($ShowMenu) {
		debug("ShowMenu",2);
		print "$CENTER<a name=\"MENU\">&nbsp;</a><BR>";
		print "<table>";
		print "<tr><th class=AWL>$Message[7] : </th><td class=AWL><font style=\"font-size: 14px;\">$SiteToAnalyze</font></th></tr>";
		print "<tr><th class=AWL valign=top>$Message[35] : </th>";
		print "<td class=AWL><font style=\"font-size: 14px;\">";
		foreach my $key (sort keys %LastUpdate) { if ($LastUpdate < $LastUpdate{$key}) { $LastUpdate = $LastUpdate{$key}; } }
		if ($LastUpdate) { print Format_Date($LastUpdate,0); }
		else { print "<font color=#880000>Never updated</font>"; }
		print "</font>&nbsp; &nbsp; &nbsp; &nbsp;";
		if ($AllowToUpdateStatsFromBrowser) {
			my $NewLinkParams=${QueryString};
			$NewLinkParams =~ s/update[=]*[^ &]*//;
			$NewLinkParams =~ s/staticlinks[=]*[^ &]*//;
			$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
			if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }
			print "<a href=\"$DirCgi$PROG.$Extension?${NewLinkParams}update=1\">$Message[74]</a>";
		}
		print "</td></tr>\n";
		if ($QueryString !~ /output=/i) {	# If main page asked
			print "<tr><td>&nbsp;</td></tr>\n";
			# When
			print "<tr><th class=AWL>$Message[93] : </th>";
			print "<td class=AWL>";
#			if ($ShowMonthDayStats)		 { print "<a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension${LinkParamA}":"")."#SUMMARY\">$Message[5]/$Message[4]</a> &nbsp; "; }
			if ($ShowMonthDayStats)		 { print "<a href=\"#SUMMARY\">$Message[5]/$Message[4]</a> &nbsp; "; }
			if ($ShowDaysOfWeekStats)	 { print "<a href=\"#DAYOFWEEK\">$Message[91]</a> &nbsp; "; }
			if ($ShowHoursStats)		 { print "<a href=\"#HOUR\">$Message[20]</a> &nbsp; "; }
			# Who
			print "<tr><th class=AWL>$Message[92] : </th>";
			print "<td class=AWL>";
			if ($ShowDomainsStats)		 { print "<a href=\"#DOMAINS\">$Message[17]</a> &nbsp; "; }
			if ($ShowHostsStats)		 { print "<a href=\"#VISITOR\">".ucfirst($Message[81])."</a> &nbsp; "; }
			if ($ShowHostsStats)		 { print "<a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=lasthosts":"$PROG$FileSuffix.lasthosts.html")."\">$Message[9]</a> &nbsp;\n"; }
			if ($ShowHostsStats)		 { print "<a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=unknownip":"$PROG$FileSuffix.unknownip.html")."\">$Message[45]</a> &nbsp;\n"; }
			if ($ShowAuthenticatedUsers) { print "<a href=\"#LOGIN\">$Message[94]</a> &nbsp; "; }
			if ($ShowRobotsStats)		 { print "<a href=\"#ROBOTS\">$Message[53]</a> &nbsp; "; }
			print "<br></td></tr>";
			# Navigation
			print "<tr><th class=AWL>$Message[72] : </th>";
			print "<td class=AWL>";
			if ($ShowPagesStats)		 { print "<a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=urldetail":"$PROG$FileSuffix.urldetail.html")."\">$Message[29]</a> &nbsp; "; }
			if ($ShowPagesStats)		 { print "<a href=\"#ENTRY\">$Message[104]</a> &nbsp; "; }
			if ($ShowFileTypesStats)	 { print "<a href=\"#FILETYPES\">$Message[73]</a> &nbsp; "; }
			if ($ShowFileSizesStats)	 {  }
			if ($ShowOSStats)			 { print "<a href=\"#OS\">$Message[59]</a> &nbsp; "; }
			if ($ShowBrowsersStats)		 { print "<a href=\"#BROWSER\">$Message[21]</a> &nbsp; "; }
			if ($ShowBrowsersStats)		 { print "<a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=browserdetail":"$PROG$FileSuffix.browserdetail.html")."\">$Message[33]</a> &nbsp; "; }
			if ($ShowBrowsersStats)		 { print "<a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=browserdetail":"$PROG$FileSuffix.browserdetail.html")."\">$Message[34]</a><br></td></tr>\n"; }
			# Referers
			print "<tr><th class=AWL>$Message[23] : </th>";
			print "<td class=AWL>";
			if ($ShowOriginStats)		 { print "<a href=\"#REFERER\">$Message[37]</a> &nbsp; "; }
			if ($ShowKeyphrasesStats)	 { print "<a href=\"#SEARCHKEYS\">$Message[24]</a><br></td></tr>\n"; }
			# Others
			print "<tr><th class=AWL>$Message[2] : </th>";
			print "<td class=AWL>";
			if ($ShowCompressionStats)	 { print "<a href=\"#FILETYPES\">$Message[98]</a> &nbsp; "; }
			if ($ShowHTTPErrorsStats)	 { print "<a href=\"#ERRORS\">$Message[22]</a> &nbsp; "; }
			if ($ShowHTTPErrorsStats)	 { print "<a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=errors404":"$PROG$FileSuffix.errors404.html")."\">$Message[31]</a><br></td></tr>\n"; }
		}
		else {
			${NewLinkParams} =~ s/&+$//;
			if ($ShowBackLink) { print "<tr><td class=AWL><a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension".(${NewLinkParams}ne""?"?${NewLinkParams}":""):"$PROG$FileSuffix.html")."\">$Message[76]</a></td></tr>\n"; }
		}
		print "</table>\n";
		print "<br>\n";
		print "<hr>\n\n";
	}
	if ($QueryString =~ /output=allhosts/i) {
		print "$CENTER<a name=\"HOSTSLIST\">&nbsp;</a><BR>";
		&tab_head($Message[81],19);
		if ($MonthRequired ne "year") { print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[81] : $TotalHostsKnown $Message[82], $TotalHostsUnknown $Message[1] - $TotalUnique $Message[11]</TH><TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH><TH width=120>$Message[9]</TH></TR>\n"; }
		else { print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[81] : ".(scalar keys %_hostmachine_h)."</TH><TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH><TH width=120>$Message[9]</TH></TR>\n"; }
		$total_p=$total_h=$total_k=0;
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,$MinHitHost,\%_hostmachine_h,\%_hostmachine_p);
		foreach my $key (@keylist) {
			$key =~ s/<script.*$//gi;				# This is to avoid 'Cross Site Scripting attacks'
			if ($_robot_l{$key}) {
				print "<tr><td CLASS=AWL><b>$key</b></td>";
			} else {
				print "<tr><td CLASS=AWL>$key</td>";
			}
			print "<TD>".($_hostmachine_p{$key}?$_hostmachine_p{$key}:"&nbsp;")."</TD><TD>$_hostmachine_h{$key}</TD><TD>".Format_Bytes($_hostmachine_k{$key})."</TD>";
			if ($_hostmachine_l{$key}) { print "<td>".Format_Date($_hostmachine_l{$key},1)."</td>"; }
			else { print "<td>-</td>"; }
			print "</tr>\n";
			$total_p += $_hostmachine_p{$key};
			$total_h += $_hostmachine_h{$key};
			$total_k += $_hostmachine_k{$key}||0;
			$count++;
		}
		debug("Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h",2);
		$rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other visitors (known or not)
			print "<TR><TD CLASS=AWL><font color=blue>$Message[2]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>".Format_Bytes($rest_k)."</TD><TD>&nbsp;</TD></TR>\n";
		}
		&tab_end;
		&html_end;
		exit(0);
	}
	if ($QueryString =~ /output=lasthosts/i) {
		print "$CENTER<a name=\"HOSTSLIST\">&nbsp;</a><BR>";
		&tab_head($Message[9],19);
		if ($MonthRequired ne "year") { print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[81] : $TotalHostsKnown $Message[82], $TotalHostsUnknown $Message[1] - $TotalUnique $Message[11]</TH><TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH><TH width=120>$Message[9]</TH></TR>\n"; }
		else { print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[81] : ".(scalar keys %_hostmachine_h)."</TH><TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH><TH width=120>$Message[9]</TH></TR>\n"; }
		$total_p=$total_h=$total_k=0;
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,$MinHitHost,\%_hostmachine_h,\%_hostmachine_l);
		foreach my $key (@keylist) {
			$key =~ s/<script.*$//gi;				# This is to avoid 'Cross Site Scripting attacks'
			if ($_robot_l{$key}) {
				print "<tr><td CLASS=AWL><b>$key</b></td>";
			} else {
				print "<tr><td CLASS=AWL>$key</td>";
			}
			print "<TD>".($_hostmachine_p{$key}?$_hostmachine_p{$key}:"&nbsp;")."</TD><TD>$_hostmachine_h{$key}</TD><TD>".Format_Bytes($_hostmachine_k{$key})."</TD>";
			if ($_hostmachine_l{$key}) { print "<td>".Format_Date($_hostmachine_l{$key},1)."</td>"; }
			else { print "<td>-</td>"; }
			print "</tr>\n";
			$total_p += $_hostmachine_p{$key};
			$total_h += $_hostmachine_h{$key};
			$total_k += $_hostmachine_k{$key}||0;
			$count++;
		}
		debug("Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h",2);
		$rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other visitors (known or not)
			print "<TR><TD CLASS=AWL><font color=blue>$Message[2]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>".Format_Bytes($rest_k)."</TD><TD>&nbsp;</TD></TR>\n";
		}
		&tab_end;
		&html_end;
		exit(0);
	}
	if ($QueryString =~ /output=unknownip/i) {
		print "$CENTER<a name=\"UNKOWNIP\">&nbsp;</a><BR>";
		&tab_head($Message[45],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>".(scalar keys %_hostmachine_h)." $Message[1]</TH><TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH><TH width=120>$Message[9]</TH>\n";
		$total_p=$total_h=$total_k=0;
		$count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,$MinHitHost,\%_hostmachine_h,\%_hostmachine_p);
		foreach my $key (@keylist) {
			$key =~ s/<script.*$//gi;				# This is to avoid 'Cross Site Scripting attacks'
			print "<tr><td CLASS=AWL>$key</td><TD>".($_hostmachine_p{$key}||"&nbsp")."</TD><TD>$_hostmachine_h{$key}</TD><TD>".Format_Bytes($_hostmachine_k{$key})."</TD>";
			if ($_hostmachine_l{$key}) { print "<td>".Format_Date($_hostmachine_l{$key},1)."</td>"; }
			else { print "<td>-</td>"; }
			print "</tr>\n";
			$total_p += $_hostmachine_p{$key};
			$total_h += $_hostmachine_h{$key};
			$total_k += $_hostmachine_k{$key}||0;
			$count++;
		}
		debug("Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h",2);
		$rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other visitors (known or not)
			print "<TR><TD CLASS=AWL><font color=blue>$Message[82]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>".Format_Bytes($rest_k)."</TD><TD>&nbsp;</TD></TR>\n";
		}
		&tab_end;
		&html_end;
		exit(0);
	}
	if ($QueryString =~ /output=urldetail/i) {
		if ($AddOn) { AddOn_Filter(); }
		print "$CENTER<a name=\"URLDETAIL\">&nbsp;</a><BR>";
		&tab_head($Message[19],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>";
		if ($URLFilter) {
			print "$Message[79]: <b>$URLFilter</b> - ".(scalar keys %_url_p)." $Message[28]";
			if ($MonthRequired ne "year") { print " ($Message[102]: $TotalDifferentPages $Message[28])"; }
		}
		else { print "$Message[102]: ".(scalar keys %_url_p)." $Message[28]"; }
		print "</TH>";
		print "<TH bgcolor=\"#$color_p\">&nbsp;$Message[29]&nbsp;</TH>";
		print "<TH bgcolor=\"#$color_s\">&nbsp;$Message[104]&nbsp;</TH>";
		print "<TH bgcolor=\"#$color_k\">&nbsp;$Message[106]&nbsp;</TH>";
		if ($AddOn) { AddOn_ShowFields(""); }
		print "<TH>&nbsp;</TH></TR>\n";
		$total_p=$total_k=$total_e=0;
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,$MinHitFile,\%_url_p,\%_url_p);
		$max_p=1; $max_k=1;
		foreach my $key (@keylist) {
			if ($_url_p{$key} > $max_p) { $max_p = $_url_p{$key}; }
			if ($_url_k{$key}/($_url_p{$key}||1) > $max_k) { $max_k = $_url_k{$key}/($_url_p{$key}||1); }
		}
		foreach my $key (@keylist) {
	    	print "<TR><TD CLASS=AWL>";
			my $nompage=$Aliases{$key};
			if ($nompage eq "") { $nompage=$key; }
			if (length($nompage)>$MaxLengthOfURL) { $nompage=substr($nompage,0,$MaxLengthOfURL)."..."; }
		    if ($ShowLinksOnUrl) { print "<A HREF=\"http://$SiteToAnalyze$key\">$nompage</A>"; }
		    else              	 { print "$nompage"; }

			my $bredde_p=0; my $bredde_e=0; my $bredde_k=0;
			if ($max_p > 0) { $bredde_p=int($BarWidth*($_url_p{$key}||0)/$max_p)+1; }
			if (($bredde_p==1) && $_url_p{$key}) { $bredde_p=2; }
			if ($max_p > 0) { $bredde_e=int($BarWidth*($_url_e{$key}||0)/$max_p)+1; }
			if (($bredde_e==1) && $_url_e{$key}) { $bredde_e=2; }
			if ($max_k > 0) { $bredde_k=int($BarWidth*(($_url_k{$key}||0)/($_url_p{$key}||1))/$max_k)+1; }
			if (($bredde_k==1) && $_url_k{$key}) { $bredde_k=2; }
			print "</TD><TD>$_url_p{$key}</TD><TD>".($_url_e{$key}?$_url_e{$key}:"&nbsp;")."</TD><TD>".($_url_k{$key}?Format_Bytes($_url_k{$key}/($_url_p{$key}||1)):"&nbsp;")."</TD>";
			if ($AddOn) { AddOn_ShowFields($key); }
			print "<TD CLASS=AWL>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6><br>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_e\" WIDTH=$bredde_e HEIGHT=6><br>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6>";
			print "</TD></TR>\n";
			$total_p += $_url_p{$key};
			$total_e += $_url_e{$key};
			$total_k += $_url_k{$key};
			$count++;
		}
		debug("Total real / shown : $TotalPages / $total_p - $TotalEntries / $total_e - $TotalBytesPages / $total_k",2);
		$rest_p=$TotalPages-$total_p;
		$rest_e=$TotalEntries-$total_e;
		$rest_k=$TotalBytesPages-$total_k;
		if ($rest_p > 0 || $rest_e > 0 || $rest_k) {
			print "<TR><TD CLASS=AWL><font color=blue>$Message[2]</font></TD><TD>$rest_p</TD><TD>$rest_e</TD><TD>".($rest_k?Format_Bytes($rest_k/$rest_p||1):"&nbsp;")."<TD>&nbsp;</TD></TR>\n";
		}
		&tab_end;
		&html_end;
		exit(0);
	}
	if ($QueryString =~ /output=browserdetail/i) {
		print "$CENTER<a name=\"NETSCAPE\">&nbsp;</a><BR>";
		&tab_head("$Message[33]<br><img src=\"$DirIcons/browser/netscape.png\">",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[58]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH></TR>\n";
		for (my $i=1; $i<=$#_nsver_h; $i++) {
			my $h="&nbsp;"; my $p="&nbsp;";
			if ($_nsver_h[$i] > 0 && $_browser_h{"netscape"} > 0) {
				$h=$_nsver_h[$i]; $p=int($_nsver_h[$i]/$_browser_h{"netscape"}*1000)/10; $p="$p&nbsp;%";
			}
			print "<TR><TD CLASS=AWL>Mozilla/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
		}
		&tab_end;
		print "<a name=\"MSIE\">&nbsp;</a><BR>";
		&tab_head("$Message[34]<br><img src=\"$DirIcons/browser/msie.png\">",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[58]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH></TR>\n";
		for ($i=1; $i<=$#_msiever_h; $i++) {
			my $h="&nbsp;"; my $p="&nbsp;";
			if ($_msiever_h[$i] > 0 && $_browser_h{"msie"} > 0) {
				$h=$_msiever_h[$i]; $p=int($_msiever_h[$i]/$_browser_h{"msie"}*1000)/10; $p="$p&nbsp;%";
			}
			print "<TR><TD CLASS=AWL>MSIE/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
		}
		&tab_end;
		&html_end;
		exit(0);
	}
	if ($QueryString =~ /output=browserdetail/i) {
		print "$CENTER<a name=\"NETSCAPE\">&nbsp;</a><BR>";
		&tab_head("$Message[33]<br><img src=\"$DirIcons/browser/netscape.png\">",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[58]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH></TR>\n";
		for (my $i=1; $i<=$#_nsver_h; $i++) {
			my $h="&nbsp;"; my $p="&nbsp;";
			if ($_nsver_h[$i] > 0 && $_browser_h{"netscape"} > 0) {
				$h=$_nsver_h[$i]; $p=int($_nsver_h[$i]/$_browser_h{"netscape"}*1000)/10; $p="$p&nbsp;%";
			}
			print "<TR><TD CLASS=AWL>Mozilla/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
		}
		&tab_end;
		print "<a name=\"MSIE\">&nbsp;</a><BR>";
		&tab_head("$Message[34]<br><img src=\"$DirIcons/browser/msie.png\">",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[58]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH></TR>\n";
		for ($i=1; $i<=$#_msiever_h; $i++) {
			my $h="&nbsp;"; my $p="&nbsp;";
			if ($_msiever_h[$i] > 0 && $_browser_h{"msie"} > 0) {
				$h=$_msiever_h[$i]; $p=int($_msiever_h[$i]/$_browser_h{"msie"}*1000)/10; $p="$p&nbsp;%";
			}
			print "<TR><TD CLASS=AWL>MSIE/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
		}
		&tab_end;
		&html_end;
		exit(0);
	}
	if ($QueryString =~ /output=allkeyphrases/i) {
		print "$CENTER<a name=\"KEYPHRASES\">&nbsp;</a><BR>";
		&tab_head($Message[43],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\" onmouseover=\"ShowTooltip(15);\" onmouseout=\"HideTooltip(15);\"><TH>$TotalDifferentKeyphrases $Message[103]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[14]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[15]</TH></TR>\n";
		$total_s=0;
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,$MinHitKeyword,\%_keyphrases,\%_keyphrases);
		foreach my $key (@keylist) {
			$key =~ s/<script.*$//gi;				# This is to avoid 'Cross Site Scripting attacks'
			my $p;
			if ($TotalKeyphrases) { $p=int($_keyphrases{$key}/$TotalKeyphrases*1000)/10; }
			my $mot = $key;
			print "<TR><TD CLASS=AWL>".DecodeEncodedString($mot)."</TD><TD>$_keyphrases{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
			$total_s += $_keyphrases{$key};
			$count++;
		}
		debug("Total real / shown : $TotalKeyphrases / $total_s",2);
		$rest_s=$TotalKeyphrases-$total_s;
		if ($rest_s > 0) {
			my $p;
			if ($TotalKeyphrases) { $p=int($rest_s/$TotalKeyphrases*1000)/10; }
			print "<TR><TD CLASS=AWL><font color=blue>$Message[30]</TD><TD>$rest_s</TD>";
			print "<TD>$p&nbsp;%</TD></TR>\n";
		}
		&tab_end;
		&html_end;
		exit(0);
	}
	if ($QueryString =~ /output=unknownreferer/i) {
		print "$CENTER<a name=\"UNKOWNREFERER\">&nbsp;</a><BR>";
		&tab_head($Message[46],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>Referer (".(scalar keys %_unknownreferer_l).")</TH><TH>$Message[9]</TH></TR>\n";
		my $count=0;
		foreach my $key (sort { $_unknownreferer_l{$b} <=> $_unknownreferer_l{$a} } keys (%_unknownreferer_l)) {
			if ($count>=$MaxRowsInHTMLOutput) { next; }
			$key =~ s/<script.*$//gi;				# This is to avoid 'Cross Site Scripting attacks'
			print "<tr><td CLASS=AWL>$key</td><td>".Format_Date($_unknownreferer_l{$key},1)."</td></tr>\n";
			$count++;
		}
		&tab_end;
		&html_end;
		exit(0);
	}
	if ($QueryString =~ /output=errors404/i) {
		print "$CENTER<a name=\"NOTFOUNDERROR\">&nbsp;</a><BR>";
		&tab_head($Message[47],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>URL (".(scalar keys %_sider404_h).")</TH><TH bgcolor=\"#$color_h\">$Message[49]</TH><TH>$Message[23]</TH></TR>\n";
		my $count=0;
		foreach my $key (sort { $_sider404_h{$b} <=> $_sider404_h{$a} } keys (%_sider404_h)) {
			if ($count>=$MaxRowsInHTMLOutput) { next; }
			$key =~ s/<script.*$//gi; 				# This is to avoid 'Cross Site Scripting attacks'
			my $nompage=$key;
			#if (length($nompage)>$MaxLengthOfURL) { $nompage=substr($nompage,0,$MaxLengthOfURL)."..."; }
			my $referer=$_referer404_h{$key}; $referer =~ s/<script.*$//gi;	# This is to avoid 'Cross Site Scripting attacks'
			print "<tr><td CLASS=AWL>$nompage</td><td>$_sider404_h{$key}</td><td>$referer&nbsp;</td></tr>\n";
			$count++;
		}
		&tab_end;
		&html_end;
		exit(0);
	}
	if ($QueryString =~ /output=info/i) {
		# Not yet available
		print "$CENTER<a name=\"INFO\">&nbsp;</a><BR>";
		&html_end;
		exit(0);
	}

	
	# SUMMARY
	#---------------------------------------------------------------------
	if ($ShowMonthDayStats) {
		debug("ShowMonthDayStats",2);
		print "$CENTER<a name=\"SUMMARY\">&nbsp;</a><BR>";
		&tab_head("$Message[7] $SiteToAnalyze",0);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TD><b>$Message[8]</b></TD>";
		if ($MonthRequired eq "year") { print "<TD colspan=3 rowspan=2><font style=\"font: 18px arial,verdana,helvetica; font-weight: normal\">$Message[6] $YearRequired</font><br>"; }
		else { print "<TD colspan=3 rowspan=2><font style=\"font: 18px arial,verdana,helvetica; font-weight: normal\">$Message[5] $monthlib{$MonthRequired} $YearRequired</font><br>"; }
		# Show links for possible years
		my $NewLinkParams=${QueryString};
		$NewLinkParams =~ s/update[=]*[^ &]*//;
		$NewLinkParams =~ s/year=[^ &]*//;
		$NewLinkParams =~ s/month=[^ &]*//;
		$NewLinkParams =~ s/staticlinks[=]*[^ &]*//;
		$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
		if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }
		foreach my $key (sort keys %listofyears) {
			if ($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks) {
				print "<a href=\"$DirCgi$PROG.$Extension?${NewLinkParams}year=$key&month=year\">$Message[6] $key</a> &nbsp; ";
			}
		}
		print "</TD>";
		print "<TD><b>$Message[9]</b></TD></TR>\n";
		
		# Ratio
		my $RatioVisits=0; my $RatioPages=0; my $RatioHits=0; my $RatioBytes=0;
		if ($TotalUnique > 0) { $RatioVisits=int($TotalVisits/$TotalUnique*100)/100; }
		if ($TotalVisits > 0) { $RatioPages=int($TotalPages/$TotalVisits*100)/100; }
		if ($TotalVisits > 0) { $RatioHits=int($TotalHits/$TotalVisits*100)/100; }
		if ($TotalVisits > 0) { $RatioBytes=int(($TotalBytes/1024)*100/$TotalVisits)/100; }
		
		if ($FirstTime) { print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TD>".Format_Date($FirstTime,0)."</TD>"; }
		else { print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TD>NA</TD>"; }
		if ($LastTime) { print "<TD>".Format_Date($LastTime,0)."</TD></TR>\n"; }
		else { print "<TD>NA</TD></TR>\n"; }
		print "<TR>";
		print "<TD width=\"20%\" bgcolor=\"#$color_u\" onmouseover=\"ShowTooltip(2);\" onmouseout=\"HideTooltip(2);\">$Message[11]</TD>";
		print "<TD width=\"20%\" bgcolor=\"#$color_v\" onmouseover=\"ShowTooltip(1);\" onmouseout=\"HideTooltip(1);\">$Message[10]</TD>";
		print "<TD width=\"20%\" bgcolor=\"#$color_p\" onmouseover=\"ShowTooltip(3);\" onmouseout=\"HideTooltip(3);\">$Message[56]</TD>";
		print "<TD width=\"20%\" bgcolor=\"#$color_h\" onmouseover=\"ShowTooltip(4);\" onmouseout=\"HideTooltip(4);\">$Message[57]</TD>";
		print "<TD width=\"20%\" bgcolor=\"#$color_k\" onmouseover=\"ShowTooltip(5);\" onmouseout=\"HideTooltip(5);\">$Message[75]</TD>";
		print "</TR>\n";
		print "<TR>";
		print "<TD>".($MonthRequired eq "year"?"<b><= $TotalUnique</b><br>Exact value not available in 'Year' view":"<b>$TotalUnique</b><br>&nbsp;")."</TD>";
		print "<TD><b>$TotalVisits</b><br>($RatioVisits&nbsp;$Message[52])</TD>";
		print "<TD><b>$TotalPages</b><br>($RatioPages&nbsp;".lc($Message[56]."/".$Message[12]).")</TD>";
		print "<TD><b>$TotalHits</b><br>($RatioHits&nbsp;".lc($Message[57]."/".$Message[12]).")</TD>";
		print "<TD><b>".Format_Bytes(int($TotalBytes))."</b><br>($RatioBytes&nbsp;$Message[44]/".lc($Message[12]).")</TD>";
		print "</TR>\n";
		print "<TR valign=bottom><TD colspan=5 align=center><center>";
		# Show monthly stats
		print "<TABLE>";
		print "<TR valign=bottom>";
		$max_v=$max_p=$max_h=$max_k=1;
		for (my $ix=1; $ix<=12; $ix++) {
			my $monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
			#if ($MonthUnique{$YearRequired.$monthix} > $max_v) { $max_v=$MonthUnique{$YearRequired.$monthix}; }
			if ($MonthVisits{$YearRequired.$monthix} > $max_v) { $max_v=$MonthVisits{$YearRequired.$monthix}; }
			#if ($MonthPages{$YearRequired.$monthix} > $max_p)  { $max_p=$MonthPages{$YearRequired.$monthix}; }
			if ($MonthHits{$YearRequired.$monthix} > $max_h)   { $max_h=$MonthHits{$YearRequired.$monthix}; }
			if ($MonthBytes{$YearRequired.$monthix} > $max_k)  { $max_k=$MonthBytes{$YearRequired.$monthix}; }
		}
		for (my $ix=1; $ix<=12; $ix++) {
			my $monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
			my $bredde_u=0; my $bredde_v=0;my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
			if ($max_v > 0) { $bredde_u=int($MonthUnique{$YearRequired.$monthix}/$max_v*$BarHeight/2)+1; }
			if ($max_v > 0) { $bredde_v=int($MonthVisits{$YearRequired.$monthix}/$max_v*$BarHeight/2)+1; }
			if ($max_h > 0) { $bredde_p=int($MonthPages{$YearRequired.$monthix}/$max_h*$BarHeight/2)+1; }
			if ($max_h > 0) { $bredde_h=int($MonthHits{$YearRequired.$monthix}/$max_h*$BarHeight/2)+1; }
			if ($max_k > 0) { $bredde_k=int($MonthBytes{$YearRequired.$monthix}/$max_k*$BarHeight/2)+1; }
			print "<TD>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_u\" HEIGHT=$bredde_u WIDTH=8 ALT=\"$Message[11]: $MonthUnique{$YearRequired.$monthix}\" title=\"$Message[11]: $MonthUnique{$YearRequired.$monthix}\">";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=8 ALT=\"$Message[10]: $MonthVisits{$YearRequired.$monthix}\" title=\"$Message[10]: $MonthVisits{$YearRequired.$monthix}\">";
			print "&nbsp;";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=8 ALT=\"$Message[56]: $MonthPages{$YearRequired.$monthix}\" title=\"$Message[56]: $MonthPages{$YearRequired.$monthix}\">";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=8 ALT=\"$Message[57]: $MonthHits{$YearRequired.$monthix}\" title=\"$Message[57]: $MonthHits{$YearRequired.$monthix}\">";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=8 ALT=\"$Message[75]: ".Format_Bytes($MonthBytes{$YearRequired.$monthix})."\" title=\"$Message[75]: ".Format_Bytes($MonthBytes{$YearRequired.$monthix})."\">";
			print "</TD>\n";
		}
		print "</TR>\n";
		print "<TR>";
		for (my $ix=1; $ix<=12; $ix++) {
			my $monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
			print "<TD valign=middle>";
			if ($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks) { print "<a href=\"$DirCgi$PROG.$Extension?${NewLinkParams}year=$YearRequired&month=$monthix\">"; }
			print "$monthlib{$monthix}";
			if ($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks) { print "</a>"; }
			print "</TD>\n";
		}
		print "</TR>\n";
		print "</TABLE>\n<br>\n";
		# Show daily stats
		print "<TABLE>";
		print "<TR valign=bottom>";
		# Get max_v, max_h and max_k values
		$max_v=$max_h=$max_k=1;
		foreach my $daycursor ($firstdaytoshowtime..$lastdaytoshowtime) {
			$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
			my $year=$1; my $month=$2; my $day=$3;
			if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
			if (($DayVisits{$year.$month.$day}||0) > $max_v)  { $max_v=$DayVisits{$year.$month.$day}; }
			#if (($DayPages{$year.$month.$day}||0) > $max_p)  { $max_p=$DayPages{$year.$month.$day}; }
			if (($DayHits{$year.$month.$day}||0) > $max_h)   { $max_h=$DayHits{$year.$month.$day}; }
			if (($DayBytes{$year.$month.$day}||0) > $max_k)  { $max_k=$DayBytes{$year.$month.$day}; }
		}
		# Calculate average values
		my $avg_day_nb=0; my $avg_day_v=0; my $avg_day_p=0; my $avg_day_h=0; my $avg_day_k=0;
		foreach my $daycursor ($firstdaytocountaverage..$lastdaytocountaverage) {
			$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
			my $year=$1; my $month=$2; my $day=$3;
			if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
			$avg_day_nb++;											# Increase number of day used to count
			$avg_day_v+=($DayVisits{$daycursor}||0);
			$avg_day_p+=($DayPages{$daycursor}||0);
			$avg_day_h+=($DayHits{$daycursor}||0);
			$avg_day_k+=($DayBytes{$daycursor}||0);
		}
		if ($avg_day_nb) {
			$avg_day_v=sprintf("%.2f",$avg_day_v/$avg_day_nb);
			$avg_day_p=sprintf("%.2f",$avg_day_p/$avg_day_nb);
			$avg_day_h=sprintf("%.2f",$avg_day_h/$avg_day_nb);
			$avg_day_k=sprintf("%.2f",$avg_day_k/$avg_day_nb);
			if ($avg_day_v > $max_v) { $max_v=$avg_day_v; }
			if ($avg_day_h > $max_h) { $max_h=$avg_day_h; }
			if ($avg_day_k > $max_k) { $max_k=$avg_day_k; }
		}
		else {
			$avg_day_v="?";
			$avg_day_p="?";
			$avg_day_h="?";
			$avg_day_k="?";
		}
		foreach my $daycursor ($firstdaytoshowtime..$lastdaytoshowtime) {
			$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
			my $year=$1; my $month=$2; my $day=$3;
			if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
			my $bredde_v=0; my $bredde_p=0; my $bredde_h=0; my $bredde_k=0;
			if ($max_v > 0) { $bredde_v=int(($DayVisits{$year.$month.$day}||0)/$max_v*$BarHeight/2)+1; }
			if ($max_h > 0) { $bredde_p=int(($DayPages{$year.$month.$day}||0)/$max_h*$BarHeight/2)+1; }
			if ($max_h > 0) { $bredde_h=int(($DayHits{$year.$month.$day}||0)/$max_h*$BarHeight/2)+1; }
			if ($max_k > 0) { $bredde_k=int(($DayBytes{$year.$month.$day}||0)/$max_k*$BarHeight/2)+1; }
			print "<TD>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=4 ALT=\"$Message[10]: ".int($DayVisits{$year.$month.$day}||0)."\" title=\"$Message[10]: ".int($DayVisits{$year.$month.$day}||0)."\">";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=4 ALT=\"$Message[56]: ".int($DayPages{$year.$month.$day}||0)."\" title=\"$Message[56]: ".int($DayPages{$year.$month.$day}||0)."\">";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=4 ALT=\"$Message[57]: ".int($DayHits{$year.$month.$day}||0)."\" title=\"$Message[57]: ".int($DayHits{$year.$month.$day}||0)."\">";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=4 ALT=\"$Message[75]: ".Format_Bytes($DayBytes{$year.$month.$day})."\" title=\"$Message[75]: ".Format_Bytes($DayBytes{$year.$month.$day})."\">";
			print "</TD>\n";
		}
		print "<TD> &nbsp; </TD>";
		# Show average values
		print "<TD>";
		my $bredde_v=0; my $bredde_p=0; my $bredde_h=0; my $bredde_k=0;
		if ($max_v > 0) { $bredde_v=int($avg_day_v/$max_v*$BarHeight/2)+1; }
		if ($max_h > 0) { $bredde_p=int($avg_day_p/$max_h*$BarHeight/2)+1; }
		if ($max_h > 0) { $bredde_h=int($avg_day_h/$max_h*$BarHeight/2)+1; }
		if ($max_k > 0) { $bredde_k=int($avg_day_k/$max_k*$BarHeight/2)+1; }
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=4 ALT=\"$Message[10]: $avg_day_v\" title=\"$Message[10]: $avg_day_v\">";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=4 ALT=\"$Message[56]: $avg_day_p\" title=\"$Message[56]: $avg_day_p\">";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=4 ALT=\"$Message[57]: $avg_day_h\" title=\"$Message[57]: $avg_day_h\">";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=4 ALT=\"$Message[75]: ".Format_Bytes($avg_day_k)."\" title=\"$Message[75]: ".Format_Bytes($avg_day_k)."\">";
		print "</TD>\n";
		print "</TR>\n";
		print "<TR>";
		foreach my $daycursor ($firstdaytoshowtime..$lastdaytoshowtime) {
			$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
			my $year=$1; my $month=$2; my $day=$3;
			if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
			my $dayofweekcursor=DayOfWeek($day,$month,$year);
			print "<TD valign=middle".($dayofweekcursor==0||$dayofweekcursor==6?" bgcolor=\"#$color_weekend\"":"").">";
			print ($day==$nowday && $month==$nowmonth && $year==$nowyear?"<b>":"");
			print "$day<br><font style=\"font: 10px;\">".$monthlib{$month}."</font>";
			print ($day==$nowday && $month==$nowmonth && $year==$nowyear?"</b></TD>":"</TD>\n");
		}
		print "<TD> &nbsp; </TD>";
		print "<TD valign=middle onmouseover=\"ShowTooltip(18);\" onmouseout=\"HideTooltip(18);\">$Message[96]</TD>\n";
		print "</TR>\n";
		print "</TABLE>\n<br>\n";
		
		print "</center></TD></TR>\n";
		&tab_end;
	}	

	# BY DAY OF WEEK
	#-------------------------
	if ($ShowDaysOfWeekStats) {
		debug("ShowDaysOfWeekStats",2);
		print "$CENTER<a name=\"DAYOFWEEK\">&nbsp;</a><BR>";
		&tab_head($Message[91],18);
		print "<TR>";
		print "<TD align=center><center><TABLE>";
		print "<TR valign=bottom>\n";
		$max_h=$max_k=$max_v=1;
		# Get average value for day of week
		foreach my $daycursor ($firstdaytocountaverage..$lastdaytocountaverage) {
			$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
			my $year=$1; my $month=$2; my $day=$3;
			if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
			my $dayofweekcursor=DayOfWeek($day,$month,$year);
			$avg_dayofweek_nb[$dayofweekcursor]++;					# Increase number of day used to count for this day of week
			$avg_dayofweek_p[$dayofweekcursor]+=($DayPages{$daycursor}||0);
			$avg_dayofweek_h[$dayofweekcursor]+=($DayHits{$daycursor}||0);
			$avg_dayofweek_k[$dayofweekcursor]+=($DayBytes{$daycursor}||0);
		}
		for (0..6) {
			if ($avg_dayofweek_nb[$_]) { 
				$avg_dayofweek_p[$_]=sprintf("%.2f",$avg_dayofweek_p[$_]/$avg_dayofweek_nb[$_]);
				$avg_dayofweek_h[$_]=sprintf("%.2f",$avg_dayofweek_h[$_]/$avg_dayofweek_nb[$_]);
				$avg_dayofweek_k[$_]=sprintf("%.2f",$avg_dayofweek_k[$_]/$avg_dayofweek_nb[$_]);
				#if ($avg_dayofweek_p[$_] > $max_p) { $max_p = $avg_dayofweek_p[$_]; }
				if ($avg_dayofweek_h[$_] > $max_h) { $max_h = $avg_dayofweek_h[$_]; }
				if ($avg_dayofweek_k[$_] > $max_k) { $max_k = $avg_dayofweek_k[$_]; }
			}
			else {
				$avg_dayofweek_p[$_]="?";
				$avg_dayofweek_h[$_]="?";
				$avg_dayofweek_k[$_]="?";
			}
        }
        for (@DOWIndex) {
			if ($max_h > 0) { $bredde_p=int($avg_dayofweek_p[$_]/$max_h*$BarHeight/2)+1; }
			if ($max_h > 0) { $bredde_h=int($avg_dayofweek_h[$_]/$max_h*$BarHeight/2)+1; }
			if ($max_k > 0) { $bredde_k=int($avg_dayofweek_k[$_]/$max_k*$BarHeight/2)+1; }
			print "<TD valign=bottom>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=6 ALT=\"$Message[56]: $avg_dayofweek_p[$_]\" title=\"$Message[56]: $avg_dayofweek_p[$_]\">";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=6 ALT=\"$Message[57]: $avg_dayofweek_h[$_]\" title=\"$Message[57]: $avg_dayofweek_h[$_]\">";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=6 ALT=\"$Message[75]: ".Format_Bytes($avg_dayofweek_k[$_])."\" title=\"$Message[75]: ".Format_Bytes($avg_dayofweek_k[$_])."\">";
			print "</TD>\n";
        }
        print "</TR>\n<TR onmouseover=\"ShowTooltip(17);\" onmouseout=\"HideTooltip(17);\">\n";
        for (@DOWIndex) {
			print "<TD";
			if ($_ =~ /[06]/) { print " bgcolor=\"#$color_weekend\""; }
			print ">".$Message[$_+84]."</TD>";
        }
		print "</TR></TABLE></center></TD>";
		print "</TR>\n";
		&tab_end;
	}
	
	# BY HOUR
	#----------------------------
	if ($ShowHoursStats) {
		debug("ShowHoursStats",2);
		print "$CENTER<a name=\"HOUR\">&nbsp;</a><BR>";
		&tab_head($Message[20],19);
		print "<TR><TD align=center><center><TABLE><TR>\n";
		$max_h=$max_k=1;
		for (my $ix=0; $ix<=23; $ix++) {
		  print "<TH width=16 onmouseover=\"ShowTooltip(17);\" onmouseout=\"HideTooltip(17);\">$ix</TH>\n";
		  #if ($_time_p[$ix]>$max_p) { $max_p=$_time_p[$ix]; }
		  if ($_time_h[$ix]>$max_h) { $max_h=$_time_h[$ix]; }
		  if ($_time_k[$ix]>$max_k) { $max_k=$_time_k[$ix]; }
		}
		print "</TR>\n";
		print "<TR>\n";
		for (my $ix=1; $ix<=24; $ix++) {
			my $hr=$ix; if ($hr>12) { $hr=$hr-12; }
			print "<TH onmouseover=\"ShowTooltip(17);\" onmouseout=\"HideTooltip(17);\"><IMG SRC=\"$DirIcons\/clock\/hr$hr.png\" width=10></TH>\n";
		}
		print "</TR>\n";
		print "<TR valign=bottom>\n";
		for (my $ix=0; $ix<=23; $ix++) {
			my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
			if ($max_h > 0) { $bredde_p=int($BarHeight*$_time_p[$ix]/$max_h)+1; }
			if ($max_h > 0) { $bredde_h=int($BarHeight*$_time_h[$ix]/$max_h)+1; }
			if ($max_k > 0) { $bredde_k=int($BarHeight*$_time_k[$ix]/$max_k)+1; }
			print "<TD>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=6 ALT=\"$Message[56]: ".int($_time_p[$ix])."\" title=\"$Message[56]: ".int($_time_p[$ix])."\">";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=6 ALT=\"$Message[57]: ".int($_time_h[$ix])."\" title=\"$Message[57]: ".int($_time_h[$ix])."\">";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=6 ALT=\"$Message[75]: ".Format_Bytes($_time_k[$ix])."\" title=\"$Message[75]: ".Format_Bytes($_time_k[$ix])."\">";
			print "</TD>\n";
		}
		print "</TR></TABLE></center></TD></TR>\n";
		&tab_end;
	}

	# BY COUNTRY/DOMAIN
	#---------------------------
	if ($ShowDomainsStats) {
		debug("ShowDomainsStats",2);
		print "$CENTER<a name=\"DOMAINS\">&nbsp;</a><BR>";
		&tab_head($Message[25],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH colspan=2>$Message[17]</TH><TH>$Message[105]</TH><TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH><TH>&nbsp;</TH></TR>\n";
		$total_p=$total_h=$total_k=0;
		$max_h=1; foreach my $key (values %_domener_h) { if ($key > $max_h) { $max_h = $key; } }
		$max_k=1; foreach my $key (values %_domener_k) { if ($key > $max_k) { $max_k = $key; } }
		$count=0;
		foreach my $key (sort { $_domener_p{$b} <=> $_domener_p{$a} } keys %_domener_p) {
			if ($count >= $MaxNbOfDomain) { last; }
			my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
			if ($max_h > 0) { $bredde_p=int($BarWidth*$_domener_p{$key}/$max_h)+1; }	# use max_h to enable to compare pages with hits
			if ($_domener_p{$key} && $bredde_p==1) { $bredde_p=2; }
			if ($max_h > 0) { $bredde_h=int($BarWidth*$_domener_h{$key}/$max_h)+1; }
			if ($_domener_h{$key} && $bredde_h==1) { $bredde_h=2; }
			if ($max_k > 0) { $bredde_k=int($BarWidth*($_domener_k{$key}||0)/$max_k)+1; }
			if ($_domener_k{$key} && $bredde_k==1) { $bredde_k=2; }
			if ($key eq "ip") {
				print "<TR><TD><IMG SRC=\"$DirIcons\/flags\/$key.png\" height=14></TD><TD CLASS=AWL>$Message[0]</TD><TD>$key</TD>";
			}
			else {
				print "<TR><TD><IMG SRC=\"$DirIcons\/flags\/$key.png\" height=14></TD><TD CLASS=AWL>$DomainsHashIDLib{$key}</TD><TD>$key</TD>";
			}
			print "<TD>$_domener_p{$key}</TD><TD>$_domener_h{$key}</TD><TD>".Format_Bytes($_domener_k{$key})."</TD>";
			print "<TD CLASS=AWL>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$Message[56]: ".int($_domener_p{$key})."\" title=\"$Message[56]: ".int($_domener_p{$key})."\"><br>\n";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 ALT=\"$Message[57]: ".int($_domener_h{$key})."\" title=\"$Message[57]: ".int($_domener_h{$key})."\"><br>\n";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$Message[75]: ".Format_Bytes($_domener_k{$key})."\" title=\"$Message[75]: ".Format_Bytes($_domener_k{$key})."\">";
			print "</TD></TR>\n";
			$total_p += $_domener_p{$key};
			$total_h += $_domener_h{$key};
			$total_k += $_domener_k{$key}||0;
			$count++;
		}
		$rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) { 	# All other domains (known or not)
			my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
			if ($max_h > 0) { $bredde_p=int($BarWidth*$rest_p/$max_h)+1; }	# use max_h to enable to compare pages with hits
			if ($rest_p && $bredde_p==1) { $bredde_p=2; }
			if ($max_h > 0) { $bredde_h=int($BarWidth*$rest_h/$max_h)+1; }
			if ($rest_h && $bredde_h==1) { $bredde_h=2; }
			if ($max_k > 0) { $bredde_k=int($BarWidth*$rest_k/$max_k)+1; }
			if ($rest_k && $bredde_k==1) { $bredde_k=2; }
			print "<TR><TD colspan=3 CLASS=AWL><font color=blue>$Message[2]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>".Format_Bytes($rest_k)."</TD>\n";
			print "<TD CLASS=AWL>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$Message[56]: ".int($rest_p)."\" title=\"$Message[56]: ".int($rest_p)."\"><br>\n";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 ALT=\"$Message[57]: ".int($rest_h)."\" title=\"$Message[57]: ".int($rest_h)."\"><br>\n";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$Message[75]: ".Format_Bytes($rest_k)."\" title=\"$Message[75]: ".Format_Bytes($rest_k)."\">";
			print "</TD></TR>\n";
		}
		&tab_end;
	}
	
	# BY HOST/VISITOR
	#--------------------------
	if ($ShowHostsStats) {
		debug("ShowHostsStats",2);
		print "$CENTER<a name=\"VISITOR\">&nbsp;</a><BR>";
		$MaxNbOfHostsShown = (scalar keys %_hostmachine_h) if $MaxNbOfHostsShown > (scalar keys %_hostmachine_h);
		&tab_head("$Message[81] ($Message[77] $MaxNbOfHostsShown) &nbsp; - &nbsp; <a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=allhosts":"$PROG$FileSuffix.allhosts.html")."\">$Message[80]</a> &nbsp; - &nbsp; <a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=lasthosts":"$PROG$FileSuffix.lasthosts.html")."\">$Message[9]</a> &nbsp; - &nbsp; <a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=unknownip":"$PROG$FileSuffix.unknownip.html")."\">$Message[45]</a>",19);
		if ($MonthRequired ne "year") { print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[81] : $TotalHostsKnown $Message[82], $TotalHostsUnknown $Message[1] - $TotalUnique $Message[11]</TH><TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH><TH width=120>$Message[9]</TH></TR>\n"; }
		else { print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[81] : ".(scalar keys %_hostmachine_h)."</TH><TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH><TH width=120>$Message[9]</TH></TR>\n"; }
		$total_p=$total_h=$total_k=0;
		$count=0;
		&BuildKeyList($MaxNbOfHostsShown,$MinHitHost,\%_hostmachine_h,\%_hostmachine_p);
		foreach my $key (@keylist) {
			print "<tr><td CLASS=AWL>$key</td><TD>".($_hostmachine_p{$key}||"&nbsp")."</TD><TD>$_hostmachine_h{$key}</TD><TD>".Format_Bytes($_hostmachine_k{$key})."</TD>";
			if ($_hostmachine_l{$key}) { print "<td>".Format_Date($_hostmachine_l{$key},1)."</td>"; }
			else { print "<td>-</td>"; }
			print "</tr>\n";
			$total_p += $_hostmachine_p{$key};
			$total_h += $_hostmachine_h{$key};
			$total_k += $_hostmachine_k{$key}||0;
			$count++;
		}
		$rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other visitors (known or not)
			print "<TR><TD CLASS=AWL><font color=blue>$Message[2]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>".Format_Bytes($rest_k)."</TD><TD>&nbsp;</TD></TR>\n";
		}
		&tab_end;
	}	
	
	# BY LOGIN
	#----------------------------
	if ($ShowAuthenticatedUsers) {
		debug("ShowAuthenticatedUsers",2);
		print "$CENTER<a name=\"LOGIN\">&nbsp;</a><BR>";
		&tab_head($Message[94],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[94]</TH><TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH><TH width=120>$Message[9]</TH></TR>\n";
		$total_p=$total_h=$total_k=0;
		$max_h=1; foreach my $key (values %_login_h) { if ($key > $max_h) { $max_h = $key; } }
		$max_k=1; foreach my $key (values %_login_k) { if ($key > $max_k) { $max_k = $key; } }
		$count=0;
		foreach my $key (sort { $_login_h{$b} <=> $_login_h{$a} } keys %_login_h) {
			if ($count >= $MaxNbOfLoginShown) { last; }
			my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
			if ($max_h > 0) { $bredde_p=int($BarWidth*$_login_p{$key}/$max_h)+1; }	# use max_h to enable to compare pages with hits
			if ($max_h > 0) { $bredde_h=int($BarWidth*$_login_h{$key}/$max_h)+1; }
			if ($max_k > 0) { $bredde_k=int($BarWidth*$_login_k{$key}/$max_k)+1; }
			print "<TR><TD CLASS=AWL>$key</TD>";
			print "<TD>$_login_p{$key}</TD><TD>$_login_h{$key}</TD><TD>".Format_Bytes($_login_k{$key})."</TD>";
			if ($_login_l{$key}) { print "<td>".Format_Date($_login_l{$key},1)."</td>"; }
			else { print "<td>-</td>"; }
#			print "<TD CLASS=AWL>";
#			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$Message[56]: $_login_p{$key}\" title=\"$Message[56]: $_login_p{$key}\"><br>\n";
#			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 ALT=\"$Message[57]: $_login_h{$key}\" title=\"$Message[57]: $_login_h{$key}\"><br>\n";
#			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$Message[75]: ".Format_Bytes($_login_k{$key})."\" title=\"$Message[75]: ".Format_Bytes($_login_k{$key})."\">";
#			print "</TD>";
			print "</TR>\n";
			$total_p += $_login_p{$key};
			$total_h += $_login_h{$key};
			$total_k += $_login_k{$key};
			$count++;
		}
		$rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other login
			print "<TR><TD CLASS=AWL><font color=blue>$Message[2]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>".Format_Bytes($rest_k)."</TD><TD>&nbsp;</TD></TR>\n";
		}
		&tab_end;
	}	
	
	# BY ROBOTS
	#----------------------------
	if ($ShowRobotsStats) {
		debug("ShowRobotStats",2);
		print "$CENTER<a name=\"ROBOTS\">&nbsp;</a><BR>";
		&tab_head($Message[53],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\" onmouseover=\"ShowTooltip(16);\" onmouseout=\"HideTooltip(16);\"><TH>$Message[83]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH width=120>$Message[9]</TH></TR>\n";
		my $count=0;
		foreach my $key (sort { $_robot_h{$b} <=> $_robot_h{$a} } keys (%_robot_h)) {
			print "<tr><td CLASS=AWL>".($RobotHashIDLib{$key}?$RobotHashIDLib{$key}:"Unknown robot")."</td><td>$_robot_h{$key}</td><td>".Format_Date($_robot_l{$key},1)."</td></tr>\n";
			$count++;
			}
		&tab_end;
	}	
		
	# BY URL
	#-------------------------
	if ($ShowPagesStats) {
		debug("ShowPagesStats (MaxNbOfPageShown=$MaxNbOfPageShown TotalDifferentPages=$TotalDifferentPages)",2);
		print "$CENTER<a name=\"PAGE\">&nbsp;</a><a name=\"ENTRY\">&nbsp;</a><BR>";
		$MaxNbOfPageShown = $TotalDifferentPages if $MaxNbOfPageShown > $TotalDifferentPages;
		&tab_head("$Message[19] ($Message[77] $MaxNbOfPageShown) &nbsp; - &nbsp; <a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=urldetail":"$PROG$FileSuffix.urldetail.html")."\">$Message[80]</a>",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$TotalDifferentPages $Message[28]</TH>";
		print "<TH bgcolor=\"#$color_p\" width=80>$Message[29]</TH>";
		print "<TH bgcolor=\"#$color_s\" width=80>$Message[104]</TH>";
		print "<TH bgcolor=\"#$color_k\" width=80>$Message[106]</TH>";
		print "<TH>&nbsp;</TH></TR>\n";
		$total_p=$total_e=$total_k=0;
		$max_p=1; $max_k=1;
		$count=0;
		&BuildKeyList($MaxNbOfPageShown,$MinHitFile,\%_url_p,\%_url_p);
		foreach my $key (@keylist) {
			if ($_url_p{$key} > $max_p) { $max_p = $_url_p{$key}; }
			if ($_url_k{$key}/($_url_p{$key}||1) > $max_k) { $max_k = $_url_k{$key}/($_url_p{$key}||1); }
		}
		foreach my $key (@keylist) {
		    print "<TR><TD CLASS=AWL>";
			my $nompage=$Aliases{$key}||$key;
			if (length($nompage)>$MaxLengthOfURL) { $nompage=substr($nompage,0,$MaxLengthOfURL)."..."; }
			if ($ShowLinksOnUrl) { 
				if ($key =~ /^http(s|):/i) {
					# URL is url extracted from a proxy log file
					print "<A HREF=\"$key\">$nompage</A>";
				}
				else {
					# URL is url extracted from a web/wap server log file
					print "<A HREF=\"http://$SiteToAnalyze$key\">$nompage</A>";
				}
			}
			else {
				print "$nompage";
			}
			my $bredde_p=0; my $bredde_e=0; my $bredde_k=0;
			if ($max_p > 0) { $bredde_p=int($BarWidth*($_url_p{$key}||0)/$max_p)+1; }
			if (($bredde_p==1) && $_url_p{$key}) { $bredde_p=2; }
			if ($max_p > 0) { $bredde_e=int($BarWidth*($_url_e{$key}||0)/$max_p)+1; }
			if (($bredde_e==1) && $_url_e{$key}) { $bredde_e=2; }
			if ($max_k > 0) { $bredde_k=int($BarWidth*(($_url_k{$key}||0)/($_url_p{$key}||1))/$max_k)+1; }
			if (($bredde_k==1) && $_url_k{$key}) { $bredde_k=2; }
			print "</TD><TD>$_url_p{$key}</TD><TD>".($_url_e{$key}?$_url_e{$key}:"&nbsp;")."</TD><TD>".($_url_k{$key}?Format_Bytes($_url_k{$key}/($_url_p{$key}||1)):"&nbsp;")."</TD>";
			print "<TD CLASS=AWL>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$Message[56]: ".int($_url_p{$key}||0)."\" title=\"$Message[56]: ".int($_url_p{$key}||0)."\"><br>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_e\" WIDTH=$bredde_e HEIGHT=6 ALT=\"$Message[104]: ".int($_url_e{$key}||0)."\" title=\"$Message[104]: ".int($_url_e{$key}||0)."\"><br>";
			print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$Message[106]: ".($_url_k{$key}?Format_Bytes($_url_k{$key}/($_url_p{$key}||1)):"&nbsp;")."\" title=\"$Message[106]: ".($_url_k{$key}?Format_Bytes($_url_k{$key}/($_url_p{$key}||1)):"&nbsp;")."\">";
			print "</TD></TR>\n";
			$total_p += $_url_p{$key};
			$total_e += $_url_e{$key};
			$total_k += $_url_k{$key};
			$count++;
		}
		$rest_p=$TotalPages-$total_p;
		$rest_e=$TotalEntries-$total_e;
		$rest_k=$TotalBytesPages-$total_k;
		if ($rest_p > 0 || $rest_e > 0 || $rest_k > 0) {	# All other urls
			print "<TR><TD CLASS=AWL><font color=blue>$Message[2]</font></TD><TD>$rest_p</TD><TD>".($rest_e?$rest_e:"&nbsp;")."</TD><TD>".($rest_k?Format_Bytes($rest_k/($rest_p||1)):"&nbsp;")."</TD><TD>&nbsp;</TD></TR>\n";
		}
		&tab_end;
	}

	# BY FILE TYPE
	#-------------------------
	if ($ShowFileTypesStats || $ShowCompressionStats) {
		debug("ShowFileTypesStatsCompressionStats",2);
		print "$CENTER<a name=\"FILETYPES\">&nbsp;</a><BR>";
		my $Totalh=0; foreach my $key (keys %_filetypes_h) { $Totalh+=$_filetypes_h{$key}; }
		my $Totalk=0; foreach my $key (keys %_filetypes_k) { $Totalk+=$_filetypes_k{$key}; }
		if ($ShowCompressionStats) { &tab_head("$Message[73] - $Message[98]</a>",19); }
		else { &tab_head("$Message[73]</a>",19); }
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[73]</TH>";
		print "<TH bgcolor=\"#$color_h\" width=80>&nbsp;$Message[57]&nbsp;</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH>";
		if ($ShowCompressionStats) {
			print "<TH bgcolor=\"#$color_k\" width=120>$Message[100]</TH><TH bgcolor=\"#$color_k\" width=120>$Message[101]</TH><TH bgcolor=\"#$color_k\" width=120>$Message[99]</TH>";
		}
		else {
			print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>";
		}
		print "</TR>\n";
		$count=0; 
		foreach my $key (sort { $_filetypes_h{$b} <=> $_filetypes_h{$a} } keys (%_filetypes_h)) {
			my $p=int($_filetypes_h{$key}/$Totalh*1000)/10;
			if ($key eq "Unknown") {
				print "<TR><TD CLASS=AWL>$Message[0]</TD>";
			}
			else {
				print "<TR><TD CLASS=AWL>$key</TD>";
			}
			print "<TD>$_filetypes_h{$key}</TD><TD>$p&nbsp;%</TD>";
			if ($ShowCompressionStats) {
				if ($_filetypes_gz_in{$key}) {
					my $percent=int(100*(1-$_filetypes_gz_out{$key}/$_filetypes_gz_in{$key})); 
					printf("<TD>%s</TD><TD>%s</TD><TD>%s (%s%)</TD>",Format_Bytes($_filetypes_gz_in{$key}),Format_Bytes($_filetypes_k{$key}),Format_Bytes($_filetypes_gz_in{$key}-$_filetypes_gz_out{$key}),$percent);
				}
				else {
					printf("<TD>%s</TD><TD>&nbsp;</TD><TD>&nbsp;</TD>",Format_Bytes($_filetypes_k{$key}));
				}
			}
			else {
				printf("<TD>%s</TD>",Format_Bytes($_filetypes_k{$key}));
			}
			print "</TR>\n";
			$count++;
		}
		&tab_end;
	}
		
	# BY FILE SIZE
	#-------------------------
	if ($ShowFileSizesStats) {
		
	}
	
	# BY BROWSER
	#----------------------------
	if ($ShowBrowsersStats) {
		debug("ShowBrowsersStats",2);
		print "$CENTER<a name=\"BROWSER\">&nbsp;</a><BR>";
		$BrowsersHashIDLib{"netscape"}="<font color=blue>Netscape</font> <a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=browserdetail":"$PROG$FileSuffix.browserdetail.html")."\">($Message[58])</a>";
		$BrowsersHashIDLib{"msie"}="<font color=blue>MS Internet Explorer</font> <a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=browserdetail":"$PROG$FileSuffix.browserdetail.html")."\">($Message[58])</a>";
		my $Total=0; foreach my $key (keys %_browser_h) { $Total+=$_browser_h{$key}; }
		&tab_head($Message[21],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>Browser</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH></TR>\n";
		$count=0; 
		foreach my $key (sort { $_browser_h{$b} <=> $_browser_h{$a} } keys (%_browser_h)) {
			my $p=int($_browser_h{$key}/$Total*1000)/10;
			if ($key eq "Unknown") {
				print "<TR><TD CLASS=AWL><a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=unknownrefererbrowser":"$PROG$FileSuffix.unknownrefererbrowser.html")."\">$Message[0]</a></TD><TD>$_browser_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
			}
			else {
				my $newbrowser=$BrowsersHashIDLib{$key}||$key;
				print "<TR><TD CLASS=AWL>$newbrowser</TD><TD>$_browser_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
			}
			$count++;
		}
		&tab_end;
	}	

	# BY OS
	#----------------------------
	if ($ShowOSStats) {
		debug("ShowOSStats",2);
		print "$CENTER<a name=\"OS\">&nbsp;</a><BR>";
		my $Total=0; foreach my $key (keys %_os_h) { $Total+=$_os_h{$key}; }
		&tab_head($Message[59],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH colspan=2>OS</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH></TR>\n";
		$count=0; 
		foreach my $key (sort { $_os_h{$b} <=> $_os_h{$a} } keys (%_os_h)) {
			my $p=int($_os_h{$key}/$Total*1000)/10;
			if ($key eq "Unknown") {
				print "<TR><TD><IMG SRC=\"$DirIcons\/os\/unknown.png\"></TD><TD CLASS=AWL><a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=unknownreferer":"$PROG$FileSuffix.unknownreferer.html")."\">$Message[0]</a></TD><TD>$_os_h{$key}</TD>";
				print "<TD>$p&nbsp;%</TD></TR>\n";
				}
			else {
				my $newos=$OSHashLib{$key}||$key;
				my $nameicon=$newos; $nameicon =~ s/\s.*//; $nameicon =~ tr/A-Z/a-z/;
				print "<TR><TD><IMG SRC=\"$DirIcons\/os\/$nameicon.png\"></TD><TD CLASS=AWL>$newos</TD><TD>$_os_h{$key}</TD>";
				print "<TD>$p&nbsp;%</TD></TR>\n";
			}
			$count++;
		}
		&tab_end;
	}	
	
	# BY REFERENCE
	#---------------------------
	if ($ShowOriginStats) {
		debug("ShowOriginStats",2);
		print "$CENTER<a name=\"REFERER\">&nbsp;</a><BR>";
		my $Totalp=0; foreach my $i (0..5) { $Totalp+=$_from_p[$i]; }
		my $Totalh=0; foreach my $i (0..5) { $Totalh+=$_from_h[$i]; }
		&tab_head($Message[36],19);
		my @p_p=(0,0,0,0,0,0);
		if ($Totalp > 0) {
			$p_p[0]=int($_from_p[0]/$Totalp*1000)/10;
			$p_p[1]=int($_from_p[1]/$Totalp*1000)/10;
			$p_p[2]=int($_from_p[2]/$Totalp*1000)/10;
			$p_p[3]=int($_from_p[3]/$Totalp*1000)/10;
			$p_p[4]=int($_from_p[4]/$Totalp*1000)/10;
			$p_p[5]=int($_from_p[5]/$Totalp*1000)/10;
		}
		my @p_h=(0,0,0,0,0,0);
		if ($Totalh > 0) {
			$p_h[0]=int($_from_h[0]/$Totalh*1000)/10;
			$p_h[1]=int($_from_h[1]/$Totalh*1000)/10;
			$p_h[2]=int($_from_h[2]/$Totalh*1000)/10;
			$p_h[3]=int($_from_h[3]/$Totalh*1000)/10;
			$p_h[4]=int($_from_h[4]/$Totalh*1000)/10;
			$p_h[5]=int($_from_h[5]/$Totalh*1000)/10;
		}
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[37]</TH><TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_p\" width=80>$Message[15]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH></TR>\n";
		#------- Referrals by direct address/bookmarks
		print "<TR><TD CLASS=AWL><b>$Message[38]</b></TD><TD>$_from_p[0]&nbsp;</TD><TD>$p_p[0]&nbsp;%</TD><TD>$_from_h[0]&nbsp;</TD><TD>$p_h[0]&nbsp;%</TD></TR>\n";
		#------- Referrals by news group
		print "<TR><TD CLASS=AWL><b>$Message[107]</b></TD><TD>$_from_p[5]&nbsp;</TD><TD>$p_p[5]&nbsp;%</TD><TD>$_from_h[5]&nbsp;</TD><TD>$p_h[5]&nbsp;%</TD></TR>\n";
		#------- Referrals by search engine
		print "<TR onmouseover=\"ShowTooltip(13);\" onmouseout=\"HideTooltip(13);\"><TD CLASS=AWL><b>$Message[40]</b><br>\n";
		print "<TABLE>\n";
		$count=0; 
		foreach my $key (sort { $_se_referrals_h{$b} <=> $_se_referrals_h{$a} } keys (%_se_referrals_h)) {
			my $newreferer=$SearchEnginesHashIDLib{$key}||$key;
			print "<TR><TD CLASS=AWL>- $newreferer</TD><TD align=right> $_se_referrals_h{$key} </TD></TR>\n";
			$count++;
		}
		print "</TABLE></TD>\n";
		print "<TD valign=top>$_from_p[2]&nbsp;</TD><TD valign=top>$p_p[2]&nbsp;%</TD><TD valign=top>$_from_h[2]&nbsp;</TD><TD valign=top>$p_h[2]&nbsp;%</TD></TR>\n";
		#------- Referrals by external HTML link
		print "<TR onmouseover=\"ShowTooltip(14);\" onmouseout=\"HideTooltip(14);\"><TD CLASS=AWL><b>$Message[41]</b><br>\n";
		print "<TABLE>\n";
		$count=0;
		$rest_h=0;
		foreach my $key (sort { $_pagesrefs_h{$b} <=> $_pagesrefs_h{$a} } keys (%_pagesrefs_h)) {
			if ($count>=$MaxNbOfRefererShown) { $rest_h+=$_pagesrefs_h{$key}; next; }
			if ($_pagesrefs_h{$key}<$MinHitRefer) { $rest_h+=$_pagesrefs_h{$key}; next; }
			my $nompage=$key;
			if (length($nompage)>$MaxLengthOfURL) { $nompage=substr($nompage,0,$MaxLengthOfURL)."..."; }
			if ($ShowLinksOnUrl && ($key =~ /^http(s|):\/\//i)) {
				print "<TR><TD CLASS=AWL>- <A HREF=\"$key\">$nompage</A></TD><TD>$_pagesrefs_h{$key}</TD></TR>\n";
			} else {
				print "<TR><TD CLASS=AWL>- $nompage</TD><TD>$_pagesrefs_h{$key}</TD></TR>\n";
			}
			$count++;
		}
		if ($rest_h > 0) {
			print "<TR><TD CLASS=AWL><font color=blue>- $Message[2]</TD><TD>$rest_h</TD>";
		}
		print "</TABLE></TD>\n";
		print "<TD valign=top>$_from_p[3]&nbsp;</TD><TD valign=top>$p_p[3]&nbsp;%</TD><TD valign=top>$_from_h[3]&nbsp;</TD><TD valign=top>$p_h[3]&nbsp;%</TD></TR>\n";
		#------- Referrals by internal HTML link
		print "<TR><TD CLASS=AWL><b>$Message[42]</b></TD><TD>$_from_p[4]&nbsp;</TD><TD>$p_p[4]&nbsp;%</TD><TD>$_from_h[4]&nbsp;</TD><TD>$p_h[4]&nbsp;%</TD></TR>\n";
		print "<TR><TD CLASS=AWL><b>$Message[39]</b></TD><TD>$_from_p[1]&nbsp;</TD><TD>$p_p[1]&nbsp;%</TD><TD>$_from_h[1]&nbsp;</TD><TD>$p_h[1]&nbsp;%</TD></TR>\n";
		&tab_end;
	}	

	# BY SEARCH PHRASES
	#----------------------------
	if ($ShowKeyphrasesStats) {
		debug("ShowKeyphrasesStats",2);
		print "$CENTER<a name=\"SEARCHKEYS\">&nbsp;</a><BR>";
		$MaxNbOfKeywordsShown = $TotalDifferentKeyphrases if $MaxNbOfKeywordsShown > $TotalDifferentKeyphrases;
		&tab_head("$Message[43] ($Message[77] $MaxNbOfKeywordsShown) &nbsp; - &nbsp; <a href=\"".($ENV{"GATEWAY_INTERFACE"} || !$StaticLinks?"$DirCgi$PROG.$Extension?${NewLinkParams}output=allkeyphrases":"$PROG$FileSuffix.allkeyphrases.html")."\">$Message[80]</a>",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\" onmouseover=\"ShowTooltip(15);\" onmouseout=\"HideTooltip(15);\"><TH>$TotalDifferentKeyphrases $Message[103]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[14]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[15]</TH></TR>\n";
		$total_s=0;
		my $count=0;
		&BuildKeyList($MaxNbOfKeywordsShown,$MinHitKeyword,\%_keyphrases,\%_keyphrases);
		foreach my $key (@keylist) {
			$key =~ s/<script.*$//gi;				# This is to avoid 'Cross Site Scripting attacks'
			my $p;
			if ($TotalKeyphrases) { $p=int($_keyphrases{$key}/$TotalKeyphrases*1000)/10; }
			my $mot = $key;
			print "<TR><TD CLASS=AWL>".DecodeEncodedString($mot)."</TD><TD>$_keyphrases{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
			$total_s += $_keyphrases{$key};
			$count++;
		}
		$rest_s=$TotalKeyphrases-$total_s;
		if ($rest_s > 0) {
			my $p;
			if ($TotalKeyphrases) { $p=int($rest_s/$TotalKeyphrases*1000)/10; }
			print "<TR><TD CLASS=AWL><font color=blue>$Message[30]</TD><TD>$rest_s</TD>";
			print "<TD>$p&nbsp;%</TD></TR>\n";
		}
		&tab_end;
	}	

	# BY ERRORS
	#----------------------------
	if ($ShowHTTPErrorsStats) {
		debug("ShowHTTPErrorsStats",2);
		print "$CENTER<a name=\"ERRORS\">&nbsp;</a><BR>";
		&tab_head($Message[32],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH colspan=2>$Message[32]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH></TR>\n";
		$count=0;
		foreach my $key (sort { $_errors_h{$b} <=> $_errors_h{$a} } keys (%_errors_h)) {
			my $p=int($_errors_h{$key}/$TotalErrors*1000)/10;
			if ($httpcode{$key}) { print "<TR onmouseover=\"ShowTooltip($key);\" onmouseout=\"HideTooltip($key);\">"; }
			else { print "<TR>"; }
			if ($key == 404) { print "<TD><a href=\"$DirCgi$PROG.$Extension?${NewLinkParams}output=errors404\">$key</a></TD>"; }
			else { print "<TD>$key</TD>"; }
			if ($httpcode{$key}) { print "<TD CLASS=AWL>$httpcode{$key}</TD><TD>$_errors_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n"; }
			else { print "<TD CLASS=AWL>Unknown error</TD><TD>$_errors_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n"; }
			$count++;
		}
		&tab_end;
	}
	
	&html_end;

}
else {
	print "Lines in file: $NbOfLinesRead\n";
	print "Found $NbOfNewLinesProcessed new records,\n";
	print "Found $NbOfLinesCorrupted corrupted records.\n";
}

0;	# Do not remove this line

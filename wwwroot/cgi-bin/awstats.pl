#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Free realtime web server logfile analyzer to show advanced web statistics.
# Works from command line or as a CGI. You must use this script as often as
# necessary from your scheduler to update your statistics and from command
# line or a browser to read report results.
# See AWStats documentation (in docs/ directory) for all setup instructions.
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$

#use warnings;		# Must be used in test mode only. This reduce a little process speed
#use diagnostics;	# Must be used in test mode only. This reduce a lot of process speed
use strict;no strict "refs";
use Time::Local;	# use Time::Local 'timelocal_nocheck' is faster but not supported by all Time::Local modules
use Socket;



#-----------------------------------------------------------------------------
# Defines
#-----------------------------------------------------------------------------
use vars qw/ $REVISION $VERSION /;
$REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
$VERSION="5.5 (build $REVISION)";

# ---------- Init variables -------
# Constants
use vars qw/
$DEBUGFORCED $NBOFLINESFORBENCHMARK $FRAMEWIDTH $NBOFLASTUPDATELOOKUPTOSAVE
$LIMITFLUSH $NEWDAYVISITTIMEOUT $VISITTIMEOUT $NOTSORTEDRECORDTOLERANCE $MAXDIFFEXTRA
$WIDTHCOLICON $WIDTHINFO $HEIGHTINFO $TOOLTIPON
/;
$DEBUGFORCED=0;						# Force debug level to log lesser level into debug.log file (Keep this value to 0)
$NBOFLINESFORBENCHMARK=8192;		# Benchmark info are printing every NBOFLINESFORBENCHMARK lines (Must be a power of 2)
$FRAMEWIDTH=260;					# Width of left frame when UseFramesWhenCGI is on
$NBOFLASTUPDATELOOKUPTOSAVE=200;	# Nb of records to save in DNS last update cache file
$LIMITFLUSH=4000;					# Nb of records in data arrays after how we need to flush data on disk
$NEWDAYVISITTIMEOUT=764041;			# Delay between 01-23:59:59 and 02-00:00:00
$VISITTIMEOUT=10000;				# Laps of time to consider a page load as a new visit. 10000 = 1 hour (Default = 10000)
$NOTSORTEDRECORDTOLERANCE=10000;	# Laps of time to accept a record if not in correct order. 10000 = 1 hour (Default = 10000)
$MAXDIFFEXTRA=500;
$WIDTHCOLICON=32;
$WIDTHINFO=640;
$HEIGHTINFO=480;
$TOOLTIPON=0;						# Tooltips plugin loaded
# Plugins variable
use vars qw/ %PluginsLoaded $PluginDir /;
%PluginsLoaded=();
$PluginDir='';
# Running variables
use vars qw/
$DIR $PROG $Extension
$Debug $ShowSteps
$DebugResetDone $DNSLookupAlreadyDone
/;
$DIR=$PROG=$Extension='';
$Debug=$ShowSteps=0;
$DebugResetDone=$DNSLookupAlreadyDone=0;
# Time vars
use vars qw/
$starttime
$nowtime $tomorrowtime
$nowweekofmonth $nowweekofyear $nowdaymod $nowsmallyear
$nowsec $nowmin $nowhour $nowday $nowmonth $nowyear $nowwday $nowyday $nowns
$StartSeconds $StartMicroseconds
/;
$StartSeconds=$StartMicroseconds=0;
# Vars for config file reading
use vars qw/
$FoundNotPageList $FoundValidHTTPCodes $FoundValidSMTPCodes
/;
$FoundNotPageList=$FoundValidHTTPCodes=$FoundValidSMTPCodes=0;
# Config vars
use vars qw/
$DNSStaticCacheFile
$DNSLastUpdateCacheFile
$LogScreenSizeUrl
$Lang
$MaxRowsInHTMLOutput
$BarImageVertical_v
$BarImageVertical_u
$BarImageVertical_p
$BarImageHorizontal_p
$BarImageHorizontal_e
$BarImageHorizontal_x
$BarImageVertical_h
$BarImageHorizontal_h
$BarImageVertical_k
$BarImageHorizontal_k
/;
$DNSStaticCacheFile='dnscache.txt';
$DNSLastUpdateCacheFile='dnscachelastupdate.txt';
$LogScreenSizeUrl='logscreensizeurl';
$Lang='auto';
$MaxRowsInHTMLOutput = 1000;
$BarImageVertical_v   = 'vv.png';
#$BarImageHorizontal_v = 'hv.png';
$BarImageVertical_u   = 'vu.png';
#$BarImageHorizontal_u = 'hu.png';
$BarImageVertical_p   = 'vp.png';
$BarImageHorizontal_p = 'hp.png';
#$BarImageVertical_e = 've.png';
$BarImageHorizontal_e = 'he.png';
$BarImageHorizontal_x = 'hx.png';
$BarImageVertical_h   = 'vh.png';
$BarImageHorizontal_h = 'hh.png';
$BarImageVertical_k   = 'vk.png';
$BarImageHorizontal_k = 'hk.png';
use vars qw/
$EnableLockForUpdate $DNSLookup $AllowAccessFromWebToAuthenticatedUsersOnly
$BarHeight $BarWidth $CreateDirDataIfNotExists $KeepBackupOfHistoricFiles $MaxLengthOfURL
$NbOfLinesParsed $NbOfLinesDropped $NbOfLinesCorrupted $NbOfOldLines $NbOfNewLines
$NbOfLinesShowsteps $NewLinePhase $NbOfLinesForCorruptedLog $PurgeLogFile
$ShowAuthenticatedUsers $ShowFileSizesStats $ShowScreenSizeStats 
$ShowDropped $ShowCorrupted $ShowUnknownOrigin $ShowLinksToWhoIs
$ShowEMailSenders $ShowEMailReceivers
$AuthenticatedUsersNotCaseSensitive
$Expires $UpdateStats $MigrateStats $URLNotCaseSensitive $URLWithQuery $URLReferrerWithQuery
$UseFramesWhenCGI $DecodeUA
/;
($EnableLockForUpdate, $DNSLookup, $AllowAccessFromWebToAuthenticatedUsersOnly,
$BarHeight, $BarWidth, $CreateDirDataIfNotExists, $KeepBackupOfHistoricFiles, $MaxLengthOfURL,
$NbOfLinesParsed, $NbOfLinesDropped, $NbOfLinesCorrupted, $NbOfOldLines, $NbOfNewLines,
$NbOfLinesShowsteps, $NewLinePhase, $NbOfLinesForCorruptedLog, $PurgeLogFile,
$ShowAuthenticatedUsers, $ShowFileSizesStats, $ShowScreenSizeStats,
$ShowDropped, $ShowCorrupted, $ShowUnknownOrigin, $ShowLinksToWhoIs,
$ShowEMailSenders, $ShowEMailReceivers,
$AuthenticatedUsersNotCaseSensitive,
$Expires, $UpdateStats, $MigrateStats, $URLNotCaseSensitive, $URLWithQuery, $URLReferrerWithQuery,
$UseFramesWhenCGI, $DecodeUA)=
(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
use vars qw/
$AllowToUpdateStatsFromBrowser $ArchiveLogRecords $DetailedReportsOnNewWindows
$FirstDayOfWeek $KeyWordsNotSensitive $SaveDatabaseFilesWithPermissionsForEveryone
$WarningMessages $DebugMessages
$ShowMenu $ShowMonthStats $ShowDaysOfMonthStats $ShowDaysOfWeekStats
$ShowHoursStats $ShowDomainsStats $ShowHostsStats
$ShowRobotsStats $ShowWormsStats $ShowSessionsStats $ShowPagesStats $ShowFileTypesStats
$ShowOSStats $ShowBrowsersStats $ShowOriginStats
$ShowKeyphrasesStats $ShowKeywordsStats $ShowHTTPErrorsStats
$ShowFlagLinks $ShowLinksOnUrl
$AddDataArrayMonthStats $AddDataArrayShowDaysOfMonthStats $AddDataArrayShowDaysOfWeekStats $AddDataArrayShowHoursStats
/;
($AllowToUpdateStatsFromBrowser, $ArchiveLogRecords, $DetailedReportsOnNewWindows,
$FirstDayOfWeek, $KeyWordsNotSensitive, $SaveDatabaseFilesWithPermissionsForEveryone,
$WarningMessages, $DebugMessages,
$ShowMenu, $ShowMonthStats, $ShowDaysOfMonthStats, $ShowDaysOfWeekStats,
$ShowHoursStats, $ShowDomainsStats, $ShowHostsStats,
$ShowRobotsStats, $ShowWormsStats, $ShowSessionsStats, $ShowPagesStats, $ShowFileTypesStats,
$ShowOSStats, $ShowBrowsersStats, $ShowOriginStats,
$ShowKeyphrasesStats, $ShowKeywordsStats, $ShowHTTPErrorsStats,
$ShowFlagLinks, $ShowLinksOnUrl,
$AddDataArrayMonthStats, $AddDataArrayShowDaysOfMonthStats, $AddDataArrayShowDaysOfWeekStats, $AddDataArrayShowHoursStats
)=
(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);
use vars qw/
$LevelForRobotsDetection $LevelForBrowsersDetection $LevelForOSDetection $LevelForRefererAnalyze
$LevelForSearchEnginesDetection $LevelForKeywordsDetection
/;
($LevelForRobotsDetection, $LevelForBrowsersDetection, $LevelForOSDetection, $LevelForRefererAnalyze,
$LevelForSearchEnginesDetection, $LevelForKeywordsDetection)=
(2,2,2,2,2,2);
use vars qw/
$DirLock $DirCgi $DirData $DirIcons $DirLang $AWScript $ArchiveFileName
$AllowAccessFromWebToFollowingIPAddresses $HTMLHeadSection $HTMLEndSection $LinksToWhoIs $LinksToIPWhoIs
$LogFile $LogFormat $LogSeparator $Logo $LogoLink $StyleSheet $WrapperScript $SiteDomain
$UseHTTPSLinkForUrl $URLQuerySeparators $URLWithAnchor $ErrorMessages
/;
($DirLock, $DirCgi, $DirData, $DirIcons, $DirLang, $AWScript, $ArchiveFileName,
$AllowAccessFromWebToFollowingIPAddresses, $HTMLHeadSection, $HTMLEndSection, $LinksToWhoIs, $LinksToIPWhoIs,
$LogFile, $LogFormat, $LogSeparator, $Logo, $LogoLink, $StyleSheet, $WrapperScript, $SiteDomain,
$UseHTTPSLinkForUrl, $URLQuerySeparators, $URLWithAnchor, $ErrorMessages)=
('','','','','','','','','','','','','','','','','','','','','','','','');
use vars qw/
$color_Background $color_TableBG $color_TableBGRowTitle
$color_TableBGTitle $color_TableBorder $color_TableRowTitle $color_TableTitle
$color_text $color_textpercent $color_titletext $color_weekend $color_link $color_hover $color_other
$color_h $color_k $color_p $color_e $color_x $color_s $color_u $color_v
/;
($color_Background, $color_TableBG, $color_TableBGRowTitle,
$color_TableBGTitle, $color_TableBorder, $color_TableRowTitle, $color_TableTitle,
$color_text, $color_textpercent, $color_titletext, $color_weekend, $color_link, $color_hover, $color_other,
$color_h, $color_k, $color_p, $color_e, $color_x, $color_s, $color_u, $color_v)=
('','','','','','','','','','','','','','','','','','','','','','');
use vars qw/
$FrameName $Center $FileConfig $FileSuffix $Host $DayRequired $MonthRequired $YearRequired
$QueryString $SiteConfig $StaticLinks $PageCode $PerlParsingFormat
$HostFilter $URLFilter $RefererPagesFilter
$SiteToAnalyze $SiteToAnalyzeWithoutwww $UserAgent
/;
($FrameName, $Center, $FileConfig, $FileSuffix, $Host, $DayRequired, $MonthRequired,
$YearRequired, $QueryString, $SiteConfig, $StaticLinks, $PageCode,
$HostFilter, $URLFilter, $RefererPagesFilter,
$PerlParsingFormat, $SiteToAnalyze, $SiteToAnalyzeWithoutwww, $UserAgent)=
('','','','','','','','','','','','','','','','','','','');
use vars qw/
$pos_vh $pos_host $pos_logname $pos_date $pos_method $pos_url $pos_code $pos_size
$pos_referer $pos_agent $pos_query $pos_gzipin $pos_gzipout $pos_gzipratio
$pos_emails $pos_emailr $pos_hostr
/;
$pos_vh = $pos_host = $pos_logname = $pos_date = $pos_method = $pos_url = $pos_code = $pos_size = -1;
$pos_referer = $pos_agent = $pos_query = $pos_gzipin = $pos_gzipout = $pos_gzipratio = -1;
$pos_emails = $pos_emailr = $pos_hostr = -1;
use vars qw/
$lowerval
$LastLine $LastLineNumber $LastLineOffset $LastLineChecksum
$LastUpdate
$TotalUnique $TotalVisits $TotalHostsKnown $TotalHostsUnknown
$TotalPages $TotalHits $TotalBytes $TotalEntries $TotalExits $TotalBytesPages $TotalDifferentPages
$TotalKeyphrases $TotalKeywords $TotalDifferentKeyphrases $TotalDifferentKeywords
$TotalSearchEnginesPages $TotalSearchEnginesHits $TotalRefererPages $TotalRefererHits $TotalDifferentSearchEngines $TotalDifferentReferer
/;
$lowerval = 0;
$LastLine = $LastLineNumber = $LastLineOffset = $LastLineChecksum = 0;
$LastUpdate = 0;
$TotalUnique = $TotalVisits = $TotalHostsKnown = $TotalHostsUnknown = 0;
$TotalPages = $TotalHits = $TotalBytes = $TotalEntries = $TotalExits = $TotalBytesPages = $TotalDifferentPages = 0;
$TotalKeyphrases = $TotalKeywords = $TotalDifferentKeyphrases = $TotalDifferentKeywords = 0;
$TotalSearchEnginesPages = $TotalSearchEnginesHits = $TotalRefererPages = $TotalRefererHits = $TotalDifferentSearchEngines = $TotalDifferentReferer = 0;
# ---------- Init arrays --------
use vars qw/
@RobotsSearchIDOrder_list1 @RobotsSearchIDOrder_list2 @RobotsSearchIDOrder_list3
@BrowsersSearchIDOrder @OSSearchIDOrder @SearchEnginesSearchIDOrder @WordsToExtractSearchUrl @WordsToCleanSearchUrl
@WormsSearchIDOrder
@DOWIndex @RobotsSearchIDOrder
@_from_p @_from_h
@_time_p @_time_h @_time_k
@fieldlib @keylist
/;
@DOWIndex = @RobotsSearchIDOrder = ();
@_from_p = @_from_h = ();
@_time_p = @_time_h = @_time_k = ();
@fieldlib = @keylist = ();
use vars qw/
@OSFamily @BrowsersFamily @SessionsRange %SessionsAverage %LangBrowserToAwstats
@HostAliases @AllowAccessFromWebToFollowingAuthenticatedUsers
@DefaultFile @SkipDNSLookupFor
@SkipHosts @SkipUserAgents @SkipFiles
@OnlyHosts @OnlyFiles 
@URLWithQueryWithoutFollowingParameters
@ExtraName @ExtraCondition @ExtraStatTypes @MaxNbOfExtra @MinHitExtra
@ExtraFirstColumnTitle @ExtraFirstColumnValues
@ExtraConditionType @ExtraConditionTypeVal
@ExtraFirstColumnValuesType @ExtraFirstColumnValuesTypeVal
@PluginsToLoad 
/;
@OSFamily=('win','mac');
@BrowsersFamily=('msie','netscape');
@SessionsRange=('0s-30s','30s-2mn','2mn-5mn','5mn-15mn','15mn-30mn','30mn-1h','1h+');
%SessionsAverage=('0s-30s',15,'30s-2mn',75,'2mn-5mn',210,'5mn-15mn',600,'15mn-30mn',1350,'30mn-1h',2700,'1h+',3600);
%LangBrowserToAwstats=('sq','al','ba','ba','cz','cz','de','de','en','en','nl','nl','bg','bg',
'ca','es_cat','zh','cn','zh-tw','tw','ko','kr','da','dk','es','es','fi','fi','fr','fr',
'el','gr','hu','hu','in','id','it','it','ja','jp','lv','lv','lt','lt','no','nn','pl','pl',
'pt','pt','pt-br','br','ro','ro','ru','ru','sk','sk','sv','se','tr','tr','uk','ua','wlk','wlk');
@HostAliases=();
@AllowAccessFromWebToFollowingAuthenticatedUsers=();
@DefaultFile = @SkipDNSLookupFor = ();
@SkipHosts = @SkipUserAgents = @SkipFiles = ();
@OnlyHosts = @OnlyFiles = ();
@URLWithQueryWithoutFollowingParameters = ();
@ExtraName = @ExtraCondition = @ExtraStatTypes = @MaxNbOfExtra = @MinHitExtra = ();
@ExtraFirstColumnTitle = @ExtraFirstColumnValues = ();
@PluginsToLoad = ();
# ---------- Init hash arrays --------
use vars qw/
%BrowsersHashIDLib %BrowsersHashIcon %BrowsersHereAreGrabbers 
%DomainsHashIDLib
%MimeHashLib %MimeHashIcon %MimeHashFamily
%OSHashID %OSHashLib
%RobotsHashIDLib
%SearchEnginesHashIDLib %SearchEnginesKnownUrl
%WormsHashID %WormsHashLib
/;
use vars qw/
%HTMLOutput
%BadFormatWarning
%MonthLib %MonthNum
%ValidHTTPCodes %ValidSMTPCodes
%TrapInfosForHTTPErrorCodes %NotPageList %DayBytes %DayHits %DayPages %DayVisits
%MaxNbOf %MinHit
%FirstTime %LastTime
%MonthUnique %MonthVisits %MonthPages %MonthHits %MonthBytes %MonthHostsKnown %MonthHostsUnknown
%ListOfYears %HistoryAlreadyFlushed %PosInFile %ValueInFile
%_session %_browser_h %_domener_h %_domener_k %_domener_p %_errors_h %_errors_k
%_filetypes_h %_filetypes_k %_filetypes_gz_in %_filetypes_gz_out
%_host_p %_host_h %_host_k %_host_l %_host_s %_host_u
%_waithost_e %_waithost_l %_waithost_s %_waithost_u
%_keyphrases %_keywords %_os_h %_pagesrefs_p %_pagesrefs_h %_robot_h %_robot_k %_robot_l
%_worm_h %_worm_l %_login_h %_login_p %_login_k %_login_l %_screensize_h
%_se_referrals_p %_se_referrals_h %_sider404_h %_referer404_h %_url_p %_url_k %_url_e %_url_x
%_unknownreferer_l %_unknownrefererbrowser_l
%_emails_h %_emails_k %_emails_l %_emailr_h %_emailr_k %_emailr_l
%val %nextval %egal
%TmpDNSLookup %TmpOS %TmpRefererServer %TmpRobot %TmpBrowser
%MyDNSTable
/;
%HTMLOutput = ();
%BadFormatWarning = ();
%MonthLib = %MonthNum = ();
%ValidHTTPCodes = %ValidSMTPCodes = ();
%TrapInfosForHTTPErrorCodes=(); $TrapInfosForHTTPErrorCodes{404}=1;	# TODO Add this in config file
%NotPageList=();
%DayBytes = %DayHits = %DayPages = %DayVisits = ();
%MaxNbOf = %MinHit = ();
%FirstTime = %LastTime = ();
%MonthUnique = %MonthVisits = %MonthPages = %MonthHits = %MonthBytes = %MonthHostsKnown = %MonthHostsUnknown = ();
%ListOfYears = %HistoryAlreadyFlushed = %PosInFile = %ValueInFile = ();
%_session = %_browser_h = %_domener_h = %_domener_k = %_domener_p = %_errors_h = %_errors_k = ();
%_filetypes_h = %_filetypes_k = %_filetypes_gz_in = %_filetypes_gz_out = ();
%_host_p = %_host_h = %_host_k = %_host_l = %_host_s = %_host_u = ();
%_waithost_e = %_waithost_l = %_waithost_s = %_waithost_u = ();
%_keyphrases = %_keywords = %_os_h = %_pagesrefs_p = %_pagesrefs_h = %_robot_h = %_robot_k = %_robot_l = ();
%_worm_h = %_worm_l = %_login_h = %_login_p = %_login_k = %_login_l = %_screensize_h = ();
%_se_referrals_p = %_se_referrals_h = %_sider404_h = %_referer404_h = %_url_p = %_url_k = %_url_e = %_url_x = ();
%_unknownreferer_l = %_unknownrefererbrowser_l = ();
%_emails_h = %_emails_k = %_emails_l = %_emailr_h = %_emailr_k = %_emailr_l = ();
%val = %nextval = %egal = ();
%TmpDNSLookup = %TmpOS = %TmpRefererServer = %TmpRobot = %TmpBrowser = ();
# ---------- Init Tie::hash arrays --------
# Didn't find a tie that increase speed
#use Tie::StdHash;
#use Tie::Cache::LRU;
#tie %_host_p, 'Tie::StdHash';
#tie %TmpOS, 'Tie::Cache::LRU';

# PROTOCOL CODES

# HTTP codes
use vars qw/ %httpcodelib /;
%httpcodelib = (
#[Miscellaneous successes]
'2xx', '[Miscellaneous successes]',
'200', 'OK',								# HTTP request OK
'201', 'Created',
'202', 'Request recorded, will be executed later',
'203', 'Non-authoritative information',
'204', 'Request executed',
'205', 'Reset document',
'206', 'Partial Content',
#[Miscellaneous redirections]
'3xx', '[Miscellaneous redirections]',
'300', 'Multiple documents available',
'301', 'Moved Permanently',
'302', 'Found',
'303', 'See other document',
'304', 'Not Modified since last retrieval',	# HTTP request OK
'305', 'Use proxy',
'306', 'Switch proxy',
'307', 'Document moved temporarily',
#[Miscellaneous client/user errors]
'4xx', '[Miscellaneous client/user errors]',
'400', 'Bad Request',
'401', 'Unauthorized',
'402', 'Payment required',
'403', 'Forbidden',
'404', 'Document Not Found',
'405', 'Method not allowed',
'406', 'Document not acceptable to client',
'407', 'Proxy authentication required',
'408', 'Request Timeout',
'409', 'Request conflicts with state of resource',
'410', 'Document gone permanently',
'411', 'Length required',
'412', 'Precondition failed',
'413', 'Request too long',
'414', 'Requested filename too long',
'415', 'Unsupported media type',
'416', 'Requested range not valid',
'417', 'Failed',
#[Miscellaneous server errors]
'5xx', '[Miscellaneous server errors]',
'500', 'Internal server Error',
'501', 'Not implemented',
'502', 'Received bad response from real server',
'503', 'Server busy',
'504', 'Gateway timeout',
'505', 'HTTP version not supported',
'506', 'Redirection failed',
#[Unknown]
'xxx' ,'[Unknown]'
);

# FTP codes
use vars qw/ %ftpcodelib /;
%ftpcodelib = (
);

# SMTP codes
use vars qw/ %smtpcodelib /;
%smtpcodelib = (
);

# DEFAULT MESSAGE
use vars qw/ @Message /;
@Message=(
'Unknown',
'Unknown (unresolved ip)',
'Others',
'View details',
'Day',
'Month',
'Year',
'Statistics of',
'First visit',
'Last visit',
'Number of visits',
'Unique visitors',
'Visit',
'different keywords',
'Search',
'Percent',
'Traffic',
'Domains/Countries',
'Visitors',
'Pages-URL',
'Hours',
'Browsers',
'HTTP Errors',
'Referers',
'Never updated',
'Visitors domains/countries',
'hosts',
'pages',
'different pages-url',
'Viewed',
'Other words',
'Pages not found',
'HTTP Error codes',
'Netscape versions',
'IE versions',
'Last Update',
'Connect to site from',
'Origin',
'Direct address / Bookmarks',
'Origin unknown',
'Links from an Internet Search Engine',
'Links from an external page (other web sites except search engines)',
'Links from an internal page (other page on same site)',
'Keyphrases used on search engines',
'Keywords used on search engines',
'Unresolved IP Address',
'Unknown OS (Referer field)',
'Required but not found URLs (HTTP code 404)',
'IP Address',
'Error&nbsp;Hits',
'Unknown browsers (Referer field)',
'different robots',
'visits/visitor',
'Robots/Spiders visitors',
'Free realtime logfile analyzer for advanced web statistics',
'of',
'Pages',
'Hits',
'Versions',
'Operating Systems',
'Jan',
'Feb',
'Mar',
'Apr',
'May',
'Jun',
'Jul',
'Aug',
'Sep',
'Oct',
'Nov',
'Dec',
'Navigation',
'Files type',
'Update now',
'Bandwidth',
'Back to main page',
'Top',
'dd mmm yyyy - HH:MM',
'Filter',
'Full list',
'Hosts',
'Known',
'Robots',
'Sun',
'Mon',
'Tue',
'Wed',
'Thu',
'Fri',
'Sat',
'Days of week',
'Who',
'When',
'Authenticated users',
'Min',
'Average',
'Max',
'Web compression',
'Bandwidth saved',
'Compression on',
'Compression result',
'Total',
'different keyphrases',
'Entry',
'Code',
'Average size',
'Links from a NewsGroup',
'KB',
'MB',
'GB',
'Grabber',
'Yes',
'No',
'WhoIs info',
'OK',
'Exit',
'Visits duration',
'Close window',
'Bytes',
'Search&nbsp;Keyphrases',
'Search&nbsp;Keywords',
'different refering search engines',
'different refering sites',
'Other phrases',
'Other logins (and/or anonymous users)',
'Refering search engines',
'Refering sites',
'Summary',
'Exact value not available in "Year" view',
'Data value arrays',
'Sender EMail',
'Receiver EMail',
'Reported period',
'Extra/Marketing',
'Screen sizes',
'Worm/Virus attacks',
'Add to favourites',
'Days of month'
);



#-----------------------------------------------------------------------------
# Functions
#-----------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function:		Write on ouput header of HTML page
# Parameters:	None
# Input:		%HTMLOutput $Expires $Lang $StyleSheet $HTMLHeadSection $PageCode
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub html_head {
	if (scalar keys %HTMLOutput) {
		# Write head section
		if ($FrameName ne 'index') { print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n\n";  }
		else { print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\">\n\n"; }
		print "<html lang='$Lang'>\n";
		print "<head>\n";
		if ($PageCode) { print "<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=$PageCode\">\n"; }		# If not defined, iso-8859-1 is used in major countries
		#else { print "<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=iso-8859-1\">\n"; }
		#else { print "<meta HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=UTF-8\">\n"; }
		if ($Expires)  { print "<META HTTP-EQUIV=\"expires\" CONTENT=\"".(gmtime(time()+$Expires))."\">\n"; }
		print "<meta http-equiv=\"description\" content=\"".ucfirst($PROG)." - Advanced Web Statistics for $SiteDomain\">\n";
		if ($FrameName ne 'mainleft') { print "<meta http-equiv=\"keywords\" content=\"$SiteDomain, free, advanced, realtime, web, server, logfile, log, analyzer, analysis, statistics, stats, perl, analyse, performance, hits, visits\">\n"; }
		print "<meta name=\"robots\" content=\"".($FrameName eq 'mainleft'?'no':'')."index,follow\">\n";
		print "<title>$Message[7] $SiteDomain</title>\n";
		if ($FrameName ne 'index') {
			# A STYLE section must be in head section. Do not use " for number in a style section
			print <<EOF;
<STYLE TYPE="text/css">
<!--
BODY { font: 12px arial, verdana, helvetica, sans-serif; background-color: #$color_Background; margin-top: 0 }
TH { font: 12px arial, verdana, helvetica, sans-serif; text-align:center; color: #$color_titletext; }
TH.AWL { font-size: 14px; font-weight: bold; }
TD { font: 12px arial, verdana, helvetica, sans-serif; text-align:center; color: #$color_text; }
.AWL { font: 12px arial, verdana, helvetica, sans-serif; text-align:left; color: #$color_text; }
B { font-weight: bold; }
A { font: 12px arial, verdana, helvetica, sans-serif; }
A:link    { color: #$color_link; text-decoration: none; }
A:visited { color: #$color_link; text-decoration: none; }
A:hover   { color: #$color_hover; text-decoration: underline; }
.TABLEBORDER { background-color: #$color_TableBorder; }
.TABLEFRAME { background-color: #$color_TableBG; padding: 2px 2px 2px 2px; margin-top: 0 }
.TABLEDATA { background-color: #$color_Background; }
.TABLETITLEFULL  { font: 14px verdana, arial, helvetica, sans-serif; font-weight: bold; background-color: #$color_TableBGTitle; text-align: center; margin-bottom: 0; padding: 2px; }
.TABLETITLEBLANK { font: 14px verdana, arial, helvetica, sans-serif; background-color: #$color_Background; }
.CFormFields { font: 14px verdana, arial, helvetica; }
EOF
		# Call to plugins' function AddHTMLStyles
		foreach my $pluginname (keys %{$PluginsLoaded{'AddHTMLStyles'}})  {
			my $function="AddHTMLStyles_$pluginname()";
			eval("$function");
		}
print <<EOF;
//-->
</STYLE>
EOF
			if ($StyleSheet) {
				print "<link rel=\"stylesheet\" href=\"$StyleSheet\">\n";
			}
		}
		print "</head>\n\n";
		if ($FrameName ne 'index') { print "<body>\n"; }
		if ($FrameName ne 'index' && $FrameName ne 'mainleft' && $ShowLinksToWhoIs) {
print <<EOF;
<SCRIPT language="JavaScript">
function neww(a,b) {
	var wfeatures="directories=0,menubar=1,status=0,resizable=1,scrollbars=1,toolbar=0,width=$WIDTHINFO,height=$HEIGHTINFO,left=" + eval("(screen.width - $WIDTHINFO)/2") + ",top=" + eval("(screen.height - $HEIGHTINFO)/2");
	if (b==1) { fen=window.open('$LinksToWhoIs'+a,'whois',wfeatures); }
	if (b==2) { fen=window.open('$LinksToIPWhoIs'+a,'whois',wfeatures); }
}
</SCRIPT>

EOF
		}
	}
}

#------------------------------------------------------------------------------
# Function:		Write on ouput end of HTML page
# Parameters:	None
# Input:		%HTMLOutput $HTMLEndSection
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub html_end {
	if (scalar keys %HTMLOutput) {
		if ($FrameName ne 'index' && $FrameName ne 'mainleft') {
			print "$Center<br><br>\n";
			print "<FONT COLOR=\"#$color_text\">";
			print "<b>Advanced Web Statistics $VERSION</b> - <a href=\"http://awstats.sourceforge.net\" target=\"awstatshome\">Created by $PROG";
			my $atleastoneplugin=0;
			foreach my $pluginname (keys %{$PluginsLoaded{'init'}}) {
				if (! $atleastoneplugin) { $atleastoneplugin=1; print " (with plugin "; }
				else { print ","; }
				print "$pluginname";
			}
			if ($atleastoneplugin) { print ")"; }
			print "</a></font><br>\n";
			if ($HTMLEndSection) { print "<br>\n$HTMLEndSection\n"; }
		}
		print "\n";
		if ($FrameName ne 'index') { print "</body>\n"; }
		print "</html>\n";
	}
}

#------------------------------------------------------------------------------
# Function:		Print on stdout tab header of a chart
# Parameters:	$title $tooltip_number [$width percentage of chart title]
# Input:		None
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub tab_head {
	my $title=shift;
	my $tooltip=shift;
	my $width=shift||70;
	print "<TABLE CLASS=\"TABLEFRAME\" BORDER=0 CELLPADDING=2 CELLSPACING=0 WIDTH=\"100%\">\n";
	if ($tooltip) {
		print "<TR><TD class=\"TABLETITLEFULL\" width=\"$width%\"".($TOOLTIPON?" onmouseover=\"ShowTip($tooltip);\" onmouseout=\"HideTip($tooltip);\"":"").">$title </TD>";
	}
	else {
		print "<TR><TD class=\"TABLETITLEFULL\" width=\"$width%\">$title </TD>";
	}
	print "<TD class=\"TABLETITLEBLANK\">&nbsp;</TD></TR>\n";
	print "<TR><TD colspan=2>\n";
	print "<TABLE CLASS=\"TABLEDATA\" BORDER=1 BORDERCOLOR=\"#$color_TableBorder\" CELLPADDING=2 CELLSPACING=0 WIDTH=\"100%\">\n";
}

#------------------------------------------------------------------------------
# Function:		Print on stdout tab ender of a chart
# Parameters:	None
# Input:		None
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub tab_end {
	print "</TABLE></TD></TR></TABLE>";
	print "<br>\n\n";
}

#------------------------------------------------------------------------------
# Function:		Write error message and exit
# Parameters:	$message $secondmessage $thirdmessage $donotshowsetupinfo
# Input:		%HTMLOutput $LogSeparator $LogFormat
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub error {
	my $message=shift||''; if (scalar keys %HTMLOutput) { $message =~ s/\</&lt;/g; $message =~ s/\>/&gt;/g; }
	my $secondmessage=shift||'';
	my $thirdmessage=shift||'';
	my $donotshowsetupinfo=shift||0;
	if ($Debug) { debug("$message $secondmessage $thirdmessage",1); }
	if (! $ErrorMessages && $message =~ /^Format error$/i) {
		my $tagbold=''; my $tagunbold=''; my $tagbr=''; my $tagfontred=''; my $tagunfont='';
		# Files seems to have bad format
		if (scalar keys %HTMLOutput) {
			$tagbold='<b>'; $tagunbold='</b>'; $tagbr='<br>'; $tagfontred='<font color=#880000>'; $tagunfont='</font>';
			print "<br><br>\n";
		}
		if ($message !~ $LogSeparator) {
			# Bad LogSeparator parameter
			print "${tagfontred}AWStats did not found the ${tagbold}LogSeparator${tagunbold} in your log records.${tagbr}${tagunfont}\n";
		}
		else {
			# Bad LogFormat parameter
			print "AWStats did not found any valid log lines that match your ${tagbold}LogFormat${tagunbold} parameter, in the ${NbOfLinesForCorruptedLog}th first non commented lines read of your log.${tagbr}\n";
			print "${tagfontred}Your log file ${tagbold}$thirdmessage${tagunbold} must have a bad format or ${tagbold}LogFormat${tagunbold} parameter setup does not match this format.${tagbr}${tagbr}${tagunfont}\n";
			print "Your AWStats ${tagbold}LogFormat${tagunbold} parameter is:\n";
			print "${tagbold}$LogFormat${tagunbold}${tagbr}\n";
			print "This means each line in your web server log file need to have ";
			if ($LogFormat == 1) {
				print "${tagbold}\"combined log format\"${tagunbold} like this:${tagbr}\n";
				print (scalar keys %HTMLOutput?"<font color=#888888><i>":"");
				print "111.22.33.44 - - [10/Jan/2001:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234 \"http://www.fromserver.com/from.htm\" \"Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)\"\n";
				print (scalar keys %HTMLOutput?"</i></font>${tagbr}${tagbr}\n":"");
			}
			if ($LogFormat == 2) {
				print "${tagbold}\"MSIE Extended W3C log format\"${tagunbold} like this:${tagbr}\n";
				print (scalar keys %HTMLOutput?"<font color=#888888><i>":"");
				print "date time c-ip c-username cs-method cs-uri-sterm sc-status sc-bytes cs-version cs(User-Agent) cs(Referer)\n";
				print (scalar keys %HTMLOutput?"</i></font>${tagbr}${tagbr}\n":"");
			}
			if ($LogFormat == 3) {
				print "${tagbold}\"WebStar native log format\"${tagunbold}${tagbr}\n";
			}
			if ($LogFormat == 4) {
				print "${tagbold}\"common log format\"${tagunbold} like this:${tagbr}\n";
				print (scalar keys %HTMLOutput?"<font color=#888888><i>":"");
				print "111.22.33.44 - - [10/Jan/2001:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234\n";
				print (scalar keys %HTMLOutput?"</i></font>${tagbr}${tagbr}\n":"");
			}
			if ($LogFormat == 5) {
				print "${tagbold}\"ISA native log format\"${tagunbold}${tagbr}\n";
			}
			if ($LogFormat == 6) {
				print "${tagbold}\"Lotus Notes/Lotus Domino\"${tagunbold}${tagbr}\n";
				print (scalar keys %HTMLOutput?"<font color=#888888><i>":"");
				print "111.22.33.44 - Firstname Middlename Lastname [10/Jan/2001:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234 \"http://www.fromserver.com/from.htm\" \"Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)\"\n";
				print (scalar keys %HTMLOutput?"</i></font>${tagbr}${tagbr}\n":"");
			}
			if ($LogFormat !~ /^[1-6]$/) {
				print "the following personalized log format:${tagbr}\n";
				print (scalar keys %HTMLOutput?"<font color=#888888><i>":"");
				print "$LogFormat\n";
				print (scalar keys %HTMLOutput?"</i></font>${tagbr}${tagbr}\n":"");
			}
			print "And this is a sample of records AWStats found in your log file (the record number $NbOfLinesForCorruptedLog in your log):\n";
			print (scalar keys %HTMLOutput?"<br><font color=#888888><i>":"");
			print "$secondmessage";
			print (scalar keys %HTMLOutput?"</i></font>${tagbr}${tagbr}":"");
			print "\n";
		}
		#print "Note: If your $NbOfLinesForCorruptedLog first lines in your log files are wrong because of ";
		#print "a worm virus attack, you can increase the NbOfLinesForCorruptedLog parameter in config file.\n";
		#print "\n";
	}
	else {
		print (scalar keys %HTMLOutput?"<br><font color=#880000>\n":"");
		print ($ErrorMessages?"$ErrorMessages":"Error: $message");
		print (scalar keys %HTMLOutput?"\n</font><br>":"");
		print "\n";
	}
	if (! $ErrorMessages && ! $donotshowsetupinfo) {
		if (scalar keys %HTMLOutput) { print "<br><b>\n"; }
		print "Setup (".($FileConfig?"'".$FileConfig."'":"Config")." file, web server or permissions) may be wrong.\n";
		if (scalar keys %HTMLOutput) { print "</b><br>\n"; }
		print "See AWStats documentation in 'docs' directory for informations on how to setup $PROG.\n";
	}
	# Remove lock if not a lock message 
	if ($EnableLockForUpdate && $message !~ /lock file/) {
		&Lock_Update(0);
	}
	if (scalar keys %HTMLOutput) { print "</BODY>\n</HTML>\n"; }
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
	if ($Debug) { debug("$messagestring",1); }
	if ($WarningMessages) {
		if (scalar keys %HTMLOutput) {
			$messagestring =~ s/\n/\<br\>/g;
			print "$messagestring<br>\n";
		}
		else {
			print "$messagestring\n";
		}
	}
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
	if ($level <= $DEBUGFORCED) {
		my $debugstring = $_[0];
		if (! $DebugResetDone) { open(DEBUGFORCEDFILE,"debug.log"); close DEBUGFORCEDFILE; chmod 0666,"debug.log"; $DebugResetDone=1; }
		open(DEBUGFORCEDFILE,">>debug.log");
		print DEBUGFORCEDFILE localtime(time)." - $$ - DEBUG $level - $debugstring\n";
		close DEBUGFORCEDFILE;
	}
	if ($DebugMessages && $level <= $Debug) {
		my $debugstring = $_[0];
		if (scalar keys %HTMLOutput) { $debugstring =~ s/^ /&nbsp&nbsp /; $debugstring .= "<br>"; }
		print localtime(time)." - DEBUG $level - $debugstring\n";
	}
}

#------------------------------------------------------------------------------
# Function:     Optimize an array removing duplicate entries
# Parameters:	@Array notcasesensitive mustbeequal
# Input:        None
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub OptimizeArray {
	my $array=shift;
	my $notcasesensitive=shift;
	my $mustbeequal=shift;
	my $searchlist=0;
	if ($Debug) { debug("OptimizeArray (notcasesensitive=$notcasesensitive,mustbeequal=$mustbeequal)",4); }
	while ($searchlist>-1 && @$array) {
		my $elemtoremove=-1;
		OPTIMIZELOOP:
		foreach my $i ($searchlist..(scalar @$array)-1) {
			# Search if $i elem is already treated by another elem
			foreach my $j (0..(scalar @$array)-1) {
				if ($i == $j) { next; }
				my $parami=$notcasesensitive?lc(@$array[$i]):@$array[$i];
				my $paramj=$notcasesensitive?lc(@$array[$j]):@$array[$j];
				if ($Debug) { debug(" Compare $i ($parami) to $j ($paramj)",4); }
				if (($mustbeequal && $parami eq $paramj) || (! $mustbeequal && index($parami,$paramj)>-1)) {
					if ($Debug) { debug(" Elem $i (@$array[$i]) already treated with elem $j (@$array[$j])",4); }
					$elemtoremove=$i;
					last OPTIMIZELOOP;
				}
			}
		}
		if ($elemtoremove > -1) {
			if ($Debug) { debug(" Remove elem $elemtoremove - @$array[$elemtoremove]",4); }
			splice @$array, $elemtoremove, 1;
			$searchlist=$elemtoremove;
		}
		else {
			$searchlist=-1;
		}
	}
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in SkipDNSLookupFor array
# Parameters:	ip @SkipDNSLookupFor
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub SkipDNSLookup {
	foreach my $match (@SkipDNSLookupFor) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipDNSLookupFor
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in SkiHosts array
# Parameters:	host @SkipHosts
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub SkipHost {
	foreach my $match (@SkipHosts) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipHosts
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in SkipUserAgents array
# Parameters:	useragent @SkipUserAgents
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub SkipUserAgent {
	foreach my $match (@SkipUserAgents) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipUserAgent
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in SkiFiles array
# Parameters:	url @SkipFiles
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub SkipFile {
	foreach my $match (@SkipFiles) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipFiles
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in OnlyHosts array
# Parameters:	host @OnlyHosts
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub OnlyHost {
	foreach my $match (@OnlyHosts) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @OnlyHosts
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in OnlyFiles array
# Parameters:	url @OnlyFiles
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub OnlyFile {
	foreach my $match (@OnlyFiles) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @OnlyFiles
}

#------------------------------------------------------------------------------
# Function:     Return day of week of a day
# Parameters:	$day $month $year
# Return:		0-6
#------------------------------------------------------------------------------
sub DayOfWeek {
	my ($day, $month, $year) = @_;
	if ($Debug) { debug("DayOfWeek for $day $month $year",4); }
	if ($month < 3) {  $month += 10;  $year--; }
	else { $month -= 2; }
	my $cent = sprintf("%1i",($year/100));
	my $y = ($year % 100);
	my $dw = (sprintf("%1i",(2.6*$month)-0.2) + $day + $y + sprintf("%1i",($y/4)) + sprintf("%1i",($cent/4)) - (2*$cent)) % 7;
	$dw += 7 if ($dw<0);
	if ($Debug) { debug(" is $dw",4); }
	return $dw;
}

#------------------------------------------------------------------------------
# Function:     Return 1 if a date exists
# Parameters:	$day $month $year
# Return:		1 if date exists else 0
#------------------------------------------------------------------------------
sub DateIsValid {
	my ($day, $month, $year) = @_;
	if ($Debug) { debug("DateIsValid for $day $month $year",4); }
	if ($day < 1)  { return 0; }
	if ($day > 31) { return 0; }
	if ($month==4 || $month==6 || $month==9 || $month==11) {
		if ($day > 30) { return 0; }
	}
	elsif ($month==2) {
		my $leapyear=($year%4==0?1:0);						# A leap year every 4 years
		if ($year%100==0 && $year%400!=0) { $leapyear=0; }	# Except if year is 100x and not 400x
		if ($day > (28+$leapyear)) { return 0; }
	}
	return 1;
}

#------------------------------------------------------------------------------
# Function:     Return string of visit duration
# Parameters:	$starttime $endtime
# Input:        None
# Output:		None
# Return:		A string that identify the visit duration range
#------------------------------------------------------------------------------
sub GetSessionRange {
	my $starttime = my $endtime;
	if (shift =~ /(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/) { $starttime = Time::Local::timelocal($6,$5,$4,$3,$2-1,$1); }
	if (shift =~ /(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/) { $endtime = Time::Local::timelocal($6,$5,$4,$3,$2-1,$1); }
	my $delay=$endtime-$starttime;
	if ($Debug) { debug("GetSessionRange $endtime - $starttime = $delay",4); }
	if ($delay <= 30) { return $SessionsRange[0]; }
	if ($delay > 30 && $delay <= 120) { return $SessionsRange[1]; }
	if ($delay > 120 && $delay <= 300) { return $SessionsRange[2]; }
	if ($delay > 300 && $delay <= 900) { return $SessionsRange[3]; }
	if ($delay > 900 && $delay <= 1800) { return $SessionsRange[4]; }
	if ($delay > 1800 && $delay <= 3600) { return $SessionsRange[5]; }
	if ($delay > 3600) { return $SessionsRange[6]; }
	return "error";
}

#------------------------------------------------------------------------------
# Function:     Read config file
# Parameters:	-
# Input:        $DIR $PROG $SiteConfig
# Output:		Global variables
# Return:		-
#------------------------------------------------------------------------------
sub Read_Config {
	# Check config file in common possible directories :
	# Windows :                                 "$DIR" (same dir than awstats.pl)
	# FHS standard, Suse and Mandrake package : "/etc/opt/awstats"
	# Debian package :                          "/etc/awstats"
	# Other possible directories :              "/etc", "/usr/local/etc/awstats"
	my @PossibleConfigDir=("$DIR","/etc/opt/awstats","/etc/awstats","/etc","/usr/local/etc/awstats");

	# Open config file
	$FileConfig=$FileSuffix='';
	foreach my $dir (@PossibleConfigDir) {
		my $searchdir=$dir;
		if ($searchdir && $searchdir !~ /[\\\/]$/) { $searchdir .= "/"; }
		if (open(CONFIG,"$searchdir$PROG.$SiteConfig.conf")) 	{ $FileConfig="$searchdir$PROG.$SiteConfig.conf"; $FileSuffix=".$SiteConfig"; last; }
		if (open(CONFIG,"$searchdir$PROG.conf"))  				{ $FileConfig="$searchdir$PROG.conf"; $FileSuffix=''; last; }
	}
	if (! $FileConfig) { error("Couldn't open config file \"$PROG.$SiteConfig.conf\" nor \"$PROG.conf\" : $!"); }

	# Analyze config file content
	&Parse_Config( *CONFIG , 1 , $FileConfig);

	# Close config file
	close CONFIG;
	
	# If parameter NotPageList not found, init for backward compatibility
	if (! $FoundNotPageList) {
		$NotPageList{'gif'}=$NotPageList{'jpg'}=$NotPageList{'jpeg'}=$NotPageList{'png'}=$NotPageList{'bmp'}=1;
	}
	# If parameter ValidHTTPCodes not found, init for backward compatibility
	if (! $FoundValidHTTPCodes) {
		$ValidHTTPCodes{"200"}=$ValidHTTPCodes{"304"}=1;
	}
	# If parameter ValidSMTPCodes not found, init for backward compatibility
	if (! $FoundValidSMTPCodes) {
		$ValidSMTPCodes{"1"}=1;
	}
}

#------------------------------------------------------------------------------
# Function:     Parse content of a config file
# Parameters:	file handle, depth level, file name
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

		if ($_ =~ /^$/) { next; }

		# Check includes
		if ($_ =~ /^Include "([^\"]+)"/ || $_ =~ /^#include "([^\"]+)"/) {	# #include kept for backward compatibility
		    my $includeFile = $1;
			if ($Debug) { debug("Found an include : $includeFile",2); }
		    if ( $includeFile !~ /^[\\\/]/ ) {
			    # Correct relative include files
				if ($FileConfig =~ /^(.*[\\\/])[^\\\/]*$/) { $includeFile = "$1$includeFile"; }
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
		if ($_ =~ /^#/) { next; }
		$_ =~ s/\s#.*$//;

		# Extract param and value
		#if ($Debug) { debug("$_",2); }
		my @felter=split(/=/,$_,2);
		my $param=$felter[0]||next;			# If not a param=value, try with next line
		my $value=$felter[1];
		$param =~ s/^\s+//; $param =~ s/\s+$//;
		if ($value) {
			$value =~ s/^\s+//; $value =~ s/\s+$//;
			$value =~ s/^\"//; $value =~ s/\";?$//;
			# Replace __MONENV__ with value of environnement variable MONENV
			while ($value =~ /__(\w+)__/) {	my $var=$1;	$value =~ s/__${var}__/$ENV{$var}/g; }
		}

		# Initialize parameter for (param,value)
		if ($param =~ /^LogFile/) {
			if ($QueryString !~ /logfile=([^\s&]+)/i) { $LogFile=$value; }
			next;
			}
		if ($param =~ /^SiteDomain/)			{
			#$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# SiteDomain is not used in regex. Must not replace . into \.
			$SiteDomain=$value;
			next;
			}
		if ($param =~ /^HostAliases/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			foreach my $elem (split(/\s+/,$value))	{ push @HostAliases,$elem; }
			next;
			}
		# Special optional setup params
		if ($param =~ /^SkipDNSLookupFor/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			foreach my $elem (split(/\s+/,$value))	{ push @SkipDNSLookupFor,$elem; }
			next;
			}
		if ($param =~ /^AllowAccessFromWebToFollowingAuthenticatedUsers/) {
			foreach my $elem (split(/\s+/,$value))	{ push @AllowAccessFromWebToFollowingAuthenticatedUsers,$elem; }
			next;
			}
		if ($param =~ /^DefaultFile/)           {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;   # Replace . into \.
			foreach my $elem (split(/\s+/,$value))	{ push @DefaultFile,$elem; }
			next;
			}
		if ($param =~ /^SkipHosts/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			foreach my $elem (split(/\s+/,$value))	{ push @SkipHosts,$elem; }
			next;
			}
		if ($param =~ /^SkipUserAgents/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			foreach my $elem (split(/\s+/,$value))	{ push @SkipUserAgents,$elem; }
			next;
			}
		if ($param =~ /^SkipFiles/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			foreach my $elem (split(/\s+/,$value))	{ push @SkipFiles,$elem; }
			next;
			}
		if ($param =~ /^OnlyHosts/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			foreach my $elem (split(/\s+/,$value))	{ push @OnlyHosts,$elem; }
			next;
			}
		if ($param =~ /^OnlyFiles/) {
			$value =~ s/\\\./\./g; $value =~ s/([^\\])\./$1\\\./g; $value =~ s/^\./\\\./;	# Replace . into \.
			foreach my $elem (split(/\s+/,$value))	{ push @OnlyFiles,$elem; }
			next;
			}
		if ($param =~ /^NotPageList/) {
			foreach my $elem (split(/\s+/,$value))	{ $NotPageList{$elem}=1; }
			$FoundNotPageList=1;
			next;
			}
		if ($param =~ /^ValidHTTPCodes/) {
			foreach my $elem (split(/\s+/,$value))	{ $ValidHTTPCodes{$elem}=1; }
			$FoundValidHTTPCodes=1;
			next;
			}
		if ($param =~ /^ValidSMTPCodes/) {
			foreach my $elem (split(/\s+/,$value))	{ $ValidSMTPCodes{$elem}=1; }
			$FoundValidSMTPCodes=1;
			next;
			}
		if ($param =~ /^URLWithQueryWithoutFollowingParameters$/)	{
			foreach my $elem (split(/\s+/,$value))	{ push @URLWithQueryWithoutFollowingParameters,$elem; }
			next;
			}
 		# Extra parameters
 		if ($param =~ /^ExtraSectionName(\d+)/)			{ $ExtraName[$1]=$value; next; }
 		if ($param =~ /^ExtraSectionCondition(\d+)/)  	{ $ExtraCondition[$1]=$value; next; }
 		if ($param =~ /^ExtraSectionStatTypes(\d+)/)    { $ExtraStatTypes[$1]=$value; next; }
 		if ($param =~ /^ExtraSectionFirstColumnTitle(\d+)/) 	{ $ExtraFirstColumnTitle[$1]=$value; next; }
 		if ($param =~ /^ExtraSectionFirstColumnValues(\d+)/) 	{ $ExtraFirstColumnValues[$1]=$value; next; }
 		if ($param =~ /^MaxNbOfExtra(\d+)/) 			{ $MaxNbOfExtra[$1]=$value; next; }
 		if ($param =~ /^MinHitExtra(\d+)/) 				{ $MinHitExtra[$1]=$value; next; }
		# Special appearance parameters
		if ($param =~ /^LoadPlugin/)           			{ push @PluginsToLoad, $value; next; }
		# Other that we need to put after MaxNbOfExtra and MinHitExtra
 		if ($param =~ /^MaxNbOf(\w+)/) 	{ $MaxNbOf{$1}=$value; next; }
 		if ($param =~ /^MinHit(\w+)/) 	{ $MinHit{$1}=$value; next; }
		# Check if this is a known parameter
#		if (! $ConfOk{$param}) { error("Unknown config parameter '$param' found line $conflinenb in file \"configFile\""); }
		# If parameters was not found previously, defined variable with name of param to value
		$$param=$value;
	}
	close $confighandle;

	# For backward compatibility
	if ($versionnum < 5001) { $BarHeight=$BarHeight>>1; }

	if ($Debug) { debug("Config file read was \"$configFile\" (level $level)"); }
}


#------------------------------------------------------------------------------
# Function:     Load the reference databases
# Parameters:	List of files to load
# Input:		$DIR
# Output:		Arrays and Hash tables are defined
# Return:       -
#------------------------------------------------------------------------------
sub Read_Ref_Data {
	# Check lib files in common possible directories :
	# Windows :                           		"${DIR}lib" (lib in same dir than awstats.pl)
	# Debian package :                    		"/usr/share/awstats/lib"
	# Other possible directories :        		"./lib"
	my @PossibleLibDir=("${DIR}lib","/usr/share/awstats/lib","./lib");
	my %FilePath=();
	my @FileListToLoad=();
	while (my $file=shift) { push @FileListToLoad, "$file.pm"; }
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
			warning("Warning: Can't read file \"$file\" ($filetext detection will not work correctly).\nCheck if file is in \"".($PossibleLibDir[0])."\" directory and is readable.");
		}
	}
	# Sanity check.
	if (@OSSearchIDOrder != scalar keys %OSHashID) { error("Not same number of records of OSSearchIDOrder (".(@OSSearchIDOrder)." entries) and OSHashID (".(scalar keys %OSHashID)." entries) in OS database. Check your file ".$FilePath{"operating_systems.pm"}); }
	if (@BrowsersSearchIDOrder != scalar keys %BrowsersHashIDLib) { error("Not same number of records of BrowsersSearchIDOrder (".(@BrowsersSearchIDOrder)." entries) and BrowsersHashIDLib (".(scalar keys %BrowsersHashIDLib)." entries) in Browsers database. Check your file ".$FilePath{"browsers.pm"}); }
	if (@SearchEnginesSearchIDOrder != scalar keys %SearchEnginesHashIDLib) { error("Not same number of records of SearchEnginesSearchIDOrder (".(@SearchEnginesSearchIDOrder)." entries) and SearchEnginesHashIDLib (".(scalar keys %SearchEnginesHashIDLib)." entries) in Search Engines database. Check your file ".$FilePath{"search_engines.pm"}); }
	if ((@RobotsSearchIDOrder_list1+@RobotsSearchIDOrder_list2+@RobotsSearchIDOrder_list3) != scalar keys %RobotsHashIDLib) { error("Not same number of records of RobotsSearchIDOrder_listx (total is ".(@RobotsSearchIDOrder_list1+@RobotsSearchIDOrder_list2+@RobotsSearchIDOrder_list3)." entries) and RobotsHashIDLib (".(scalar keys %RobotsHashIDLib)." entries) in Robots database. Check your file ".$FilePath{"robots.pm"}); }
}


#------------------------------------------------------------------------------
# Function:     Get the messages for a specified language
# Parameters:	LanguageId
# Input:		$DirLang $DIR
# Output:		$Message table is defined in memory
# Return:		None
#------------------------------------------------------------------------------
sub Read_Language_Data {
	# Check lang files in common possible directories :
	# Windows :                           		"${DIR}lang" (lang in same dir than awstats.pl)
	# Debian package :                    		"/usr/share/awstats/lang"
	# Other possible directories :        		"./lang"
	my @PossibleLangDir=("$DirLang","${DIR}lang","/usr/share/awstats/lang","./lang");

	my $FileLang='';
	foreach my $dir (@PossibleLangDir) {
		my $searchdir=$dir;
		if ($searchdir && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
		if (open(LANG,"${searchdir}awstats-$_[0].txt")) { $FileLang="${searchdir}awstats-$_[0].txt"; last; }
	}
	# If file not found, we try english
	if (! $FileLang) {
		foreach my $dir (@PossibleLangDir) {
			my $searchdir=$dir;
			if ($searchdir && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
			if (open(LANG,"${searchdir}awstats-en.txt")) { $FileLang="${searchdir}awstats-en.txt"; last; }
		}
	}
	if ($Debug) { debug("Call to Read_Language_Data [FileLang=\"$FileLang\"]"); }
	if ($FileLang) {
		my $i = 0;
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
		warning("Warning: Can't find language files for \"$_[0]\". English will be used.");
	}
	close(LANG);
}


#------------------------------------------------------------------------------
# Function:     Check if all parameters are correctly defined. If not set them to default.
# Parameters:	None
# Input:		All global variables
# Output:		Change on some global variables
# Return:		None
#------------------------------------------------------------------------------
sub Check_Config {
	if ($Debug) { debug("Call to Check_Config"); }

	# Show initial values of main parameters before check
	if ($Debug) {
		debug(" LogFile='$LogFile'",2);
		debug(" LogFormat='$LogFormat'",2);
		debug(" LogSeparator='$LogSeparator'",2);
		debug(" DNSLookup='$DNSLookup'",2);
		debug(" DirData='$DirData'",2);
		debug(" DirCgi='$DirCgi'",2);
		debug(" DirIcons='$DirIcons'",2);
		debug(" NotPageList ".(scalar keys %NotPageList),2);
		debug(" ValidHTTPCodes ".(scalar keys %ValidHTTPCodes),2);
		debug(" ValidSMTPCodes ".(scalar keys %ValidSMTPCodes),2);
		debug(" UseFramesWhenCGI=$UseFramesWhenCGI",2);
	}

	# Main section
	while ($LogFile =~ /%([ymdhwYMDHWNS]+)-(\d+)/) {
		my $timetag=$1;
		my $timephase=$2;
		if ($Debug) { debug(" Found a time phase of $timephase hour in log file name",1); }
		# Get older time
		my ($oldersec,$oldermin,$olderhour,$olderday,$oldermonth,$olderyear,$olderwday,$olderyday) = localtime($starttime-($timephase*3600));
		my $olderweekofmonth=int($olderday/7);
		my $olderweekofyear=int(($olderyday-1+6-($olderwday==0?6:$olderwday-1))/7)+1; if ($olderweekofyear > 52) { $olderweekofyear = 1; }
		my $olderdaymod=$olderday%7;
		$olderwday++;
		my $olderns=Time::Local::timelocal(0,0,0,$olderday,$oldermonth,$olderyear);
		if ($olderdaymod <= $olderwday) { if (($olderwday != 7) || ($olderdaymod != 0)) { $olderweekofmonth=$olderweekofmonth+1; } }
		if ($olderdaymod >  $olderwday) { $olderweekofmonth=$olderweekofmonth+2; }
		# Change format of time variables
		$olderweekofmonth = "0$olderweekofmonth";
		if ($olderweekofyear < 10) { $olderweekofyear = "0$olderweekofyear"; }
		if ($olderyear < 100) { $olderyear+=2000; } else { $olderyear+=1900; }
		my $oldersmallyear=$olderyear;$oldersmallyear =~ s/^..//;
		if (++$oldermonth < 10) { $oldermonth = "0$oldermonth"; }
		if ($olderday < 10) { $olderday = "0$olderday"; }
		if ($olderhour < 10) { $olderhour = "0$olderhour"; }
		if ($oldermin < 10) { $oldermin = "0$oldermin"; }
		if ($oldersec < 10) { $oldersec = "0$oldersec"; }
		# Replace tag with new value
		if ($timetag =~ /YYYY/i) { $LogFile =~ s/%YYYY-$timephase/$olderyear/ig; next; }
		if ($timetag =~ /YY/i)   { $LogFile =~ s/%YY-$timephase/$oldersmallyear/ig; next; }
		if ($timetag =~ /MM/i)   { $LogFile =~ s/%MM-$timephase/$oldermonth/ig; next; }
		if ($timetag =~ /DD/i)   { $LogFile =~ s/%DD-$timephase/$olderday/ig; next; }
		if ($timetag =~ /HH/i)   { $LogFile =~ s/%HH-$timephase/$olderhour/ig; next; }
		if ($timetag =~ /NS/i)   { $LogFile =~ s/%NS-$timephase/$olderns/ig; next; }
		if ($timetag =~ /WM/)    { $LogFile =~ s/%WM-$timephase/$olderweekofmonth/g; next; }
		if ($timetag =~ /Wm/)    { my $olderweekofmonth0=$olderweekofmonth-1; $LogFile =~ s/%Wm-$timephase/$olderweekofmonth0/g; next; }
		if ($timetag =~ /WY/)    { $LogFile =~ s/%WY-$timephase/$olderweekofyear/g; next; }
		if ($timetag =~ /Wy/)    { my $olderweekofyear0=sprintf("%02d",$olderweekofyear-1); $LogFile =~ s/%Wy-$timephase/$olderweekofyear0/g; next; }
		if ($timetag =~ /DW/)    { $LogFile =~ s/%DW-$timephase/$olderwday/g; next; }
		if ($timetag =~ /Dw/)    { my $olderwday0=$olderwday-1; $LogFile =~ s/%Dw-$timephase/$olderwday0/g; next; }
		# If unknown tag
		error("Unknown tag '\%$timetag' in LogFile parameter.");
	}
	# Replace %YYYY %YY %MM %DD %HH with current value. Kept for backward compatibility.
	$LogFile =~ s/%YYYY/$nowyear/ig;
	$LogFile =~ s/%YY/$nowsmallyear/ig;
	$LogFile =~ s/%MM/$nowmonth/ig;
	$LogFile =~ s/%DD/$nowday/ig;
	$LogFile =~ s/%HH/$nowhour/ig;
	$LogFile =~ s/%NS/$nowns/ig;
	$LogFile =~ s/%WM/$nowweekofmonth/g;
	my $nowweekofmonth0=$nowweekofmonth-1; $LogFile =~ s/%Wm/$nowweekofmonth0/g;
	$LogFile =~ s/%WY/$nowweekofyear/g;
	my $nowweekofyear0=$nowweekofyear-1; $LogFile =~ s/%Wy/$nowweekofyear0/g;
	$LogFile =~ s/%DW/$nowwday/g;
	my $nowwday0=$nowwday-1; $LogFile =~ s/%Dw/$nowwday0/g;
	$LogFormat =~ s/\\//g;
	if (! $LogFile)   { error("LogFile parameter is not defined in config/domain file"); }
	if (! $LogFormat) { error("LogFormat parameter is not defined in config/domain file"); }
	if ($LogFormat =~ /^\d$/ && $LogFormat !~ /[1-6]/)  { error("LogFormat parameter is wrong in config/domain file. Value is '$LogFormat' (should be 1,2,3,4,5 or a 'personalized AWStats log format string')"); }
	$LogSeparator||="\\s";
	$DirData||=$DirData='.';
	$DirCgi||='/cgi-bin';
	$DirIcons||='/icon';
	if ($DNSLookup !~ /[0-2]/)                      { error("DNSLookup parameter is wrong in config/domain file. Value is '$DNSLookup' (should be 0 or 1)"); }
	if (! $SiteDomain)                              { error("SiteDomain parameter not found in your config/domain file. You must add it for using this version."); }
	if ($AllowToUpdateStatsFromBrowser !~ /[0-1]/) 	{ $AllowToUpdateStatsFromBrowser=0; }
	# Optional setup section
	if ($EnableLockForUpdate !~ /[0-1]/)           	{ $EnableLockForUpdate=0; }
	$DNSStaticCacheFile||='dnscache.txt';
	$DNSLastUpdateCacheFile||='dnscachelastupdate.txt';
	if ($DNSStaticCacheFile eq $DNSLastUpdateCacheFile)	{ error("DNSStaticCacheFile and DNSLastUpdateCacheFile must have different values."); }
	if ($AllowAccessFromWebToAuthenticatedUsersOnly !~ /[0-1]/)     { $AllowAccessFromWebToAuthenticatedUsersOnly=0; }
	if ($CreateDirDataIfNotExists !~ /[0-1]/)      	{ $CreateDirDataIfNotExists=0; }
	if ($SaveDatabaseFilesWithPermissionsForEveryone !~ /[0-1]/)	{ $SaveDatabaseFilesWithPermissionsForEveryone=1; }
	if ($PurgeLogFile !~ /[0-1]/)                 	{ $PurgeLogFile=0; }
	if ($ArchiveLogRecords !~ /[0-1]/)            	{ $ArchiveLogRecords=1; }
	if ($KeepBackupOfHistoricFiles !~ /[0-1]/)     	{ $KeepBackupOfHistoricFiles=0; }
	$DefaultFile[0]||='index.html';
	if ($AuthenticatedUsersNotCaseSensitive !~ /[0-1]/)       { $AuthenticatedUsersNotCaseSensitive=0; }
	if ($URLNotCaseSensitive !~ /[0-1]/)           	{ $URLNotCaseSensitive=0; }
	if ($URLWithAnchor !~ /[0-1]/)                 	{ $URLWithAnchor=0; }
	$URLQuerySeparators =~ s/\s//g; 
	if (! $URLQuerySeparators)                 		{ $URLQuerySeparators='?;'; }
	if ($URLWithQuery !~ /[0-1]/)                 	{ $URLWithQuery=0; }
	if ($URLReferrerWithQuery !~ /[0-1]/)          	{ $URLReferrerWithQuery=0; }
	if ($WarningMessages !~ /[0-1]/)              	{ $WarningMessages=1; }
	if ($DebugMessages !~ /[0-1]/)              	{ $DebugMessages=1; }
	if ($NbOfLinesForCorruptedLog !~ /^\d+/ || $NbOfLinesForCorruptedLog<1)	{ $NbOfLinesForCorruptedLog=50; }
	if ($Expires !~ /^\d+/)                 		{ $Expires=0; }
	if ($DecodeUA !~ /[0-1]/)						{ $DecodeUA=0; }
	$LogScreenSizeUrl||='logscreensizeurl';
	# Optional accuracy setup section
	if ($LevelForRobotsDetection !~ /^\d+/)       	{ $LevelForRobotsDetection=2; }
	if ($LevelForBrowsersDetection !~ /^\d+/)     	{ $LevelForBrowsersDetection=2; }
	if ($LevelForOSDetection !~ /^\d+/)    			{ $LevelForOSDetection=2; }
	if ($LevelForRefererAnalyze !~ /^\d+/)			{ $LevelForRefererAnalyze=2; }
	if ($LevelForSearchEnginesDetection !~ /^\d+/)	{ $LevelForSearchEnginesDetection=2; }
	if ($LevelForKeywordsDetection !~ /^\d+/)  		{ $LevelForKeywordsDetection=2; }
	# Optional extra setup section
	foreach my $extracpt (1..@ExtraName-1) {
		if ($ExtraStatTypes[$extracpt] !~ /[PHBL]/)  { $ExtraStatTypes[$extracpt]='PHBL'; }
		if ($MaxNbOfExtra[$extracpt] !~ /^\d+$/ || $MaxNbOfExtra[$extracpt]<1) { $MaxNbOfExtra[$extracpt]=20; }
		if ($MinHitExtra[$extracpt] !~ /^\d+$/ || $MinHitExtra[$extracpt]<1) { $MinHitExtra[$extracpt]=1; }
		if (! $ExtraFirstColumnValues[$extracpt]) { error("Extra section number $extracpt is defined without ExtraSectionFirstColumnValues$extracpt parameter"); }
	}
	# Optional appearance setup section
	if ($MaxRowsInHTMLOutput !~ /^\d+/ || $MaxRowsInHTMLOutput<1)     { $MaxRowsInHTMLOutput=1000; }
	if ($ShowMenu !~ /[0-1]/)                     	{ $ShowMenu=1; }
	if ($ShowMonthStats !~ /[01UVPHB]/)         	{ $ShowMonthStats='UVPHB'; }
	if ($ShowDaysOfMonthStats !~ /[01VPHB]/)    	{ $ShowDaysOfMonthStats='VPHB'; }
	if ($ShowDaysOfWeekStats !~ /[01PHBL]/)        	{ $ShowDaysOfWeekStats='PHBL'; }
	if ($ShowHoursStats !~ /[01PHBL]/)             	{ $ShowHoursStats='PHBL'; }
	if ($ShowDomainsStats !~ /[01PHB]/)            	{ $ShowDomainsStats='PHB'; }
	if ($ShowHostsStats !~ /[01PHBL]/)             	{ $ShowHostsStats='PHBL'; }
	if ($ShowAuthenticatedUsers !~ /[01PHBL]/)     	{ $ShowAuthenticatedUsers=0; }
	if ($ShowRobotsStats !~ /[01HBL]/)            	{ $ShowRobotsStats='HBL'; }
	if ($ShowWormsStats !~ /[01HL]/)            	{ $ShowWormsStats='HL'; }
	if ($ShowEMailSenders !~ /[01HBML]/)       		{ $ShowEMailSenders=0; }
	if ($ShowEMailReceivers !~ /[01HBML]/)         	{ $ShowEMailReceivers=0; }
	if ($ShowSessionsStats !~ /[0-1]/)             	{ $ShowSessionsStats=1; }
	if ($ShowPagesStats !~ /[01PBEX]/i)           	{ $ShowPagesStats='PBEX'; }
	if ($ShowFileTypesStats !~ /[01HBC]/)         	{ $ShowFileTypesStats='HB'; }
	if ($ShowFileSizesStats !~ /[0-1]/)           	{ $ShowFileSizesStats=1; }
	if ($ShowOSStats !~ /[0-1]/)                  	{ $ShowOSStats=1; }
	if ($ShowBrowsersStats !~ /[0-1]/)            	{ $ShowBrowsersStats=1; }
	if ($ShowScreenSizeStats !~ /[0-1]/)           	{ $ShowScreenSizeStats=0; }
	if ($ShowOriginStats !~ /[01PH]/)              	{ $ShowOriginStats='PH'; }
	if ($ShowKeyphrasesStats !~ /[0-1]/)          	{ $ShowKeyphrasesStats=1; }
	if ($ShowKeywordsStats !~ /[0-1]/)            	{ $ShowKeywordsStats=1; }
	if ($ShowHTTPErrorsStats !~ /[0-1]/)          	{ $ShowHTTPErrorsStats=1; }
	if ($AddDataArrayMonthStats !~ /[0-1]/)        	{ $AddDataArrayMonthStats=1; }
	if ($AddDataArrayShowDaysOfMonthStats !~ /[0-1]/)       { $AddDataArrayShowDaysOfMonthStats=1; }
	if ($AddDataArrayShowDaysOfWeekStats !~ /[0-1]/)       	{ $AddDataArrayShowDaysOfWeekStats=1; }
	if ($AddDataArrayShowHoursStats !~ /[0-1]/)          	{ $AddDataArrayShowHoursStats=1; }
	my @maxnboflist=('Domain','HostsShown','LoginShown','RobotShown','WormsShown','PageShown','ScreenSizesShown','RefererShown','KeyphrasesShown','KeywordsShown','EMailsShown');
	my @maxnboflistdefaultval=(10,10,10,10,10,10,5,10,10,10,20);
	foreach my $i (0..(@maxnboflist-1)) {
		if (! $MaxNbOf{$maxnboflist[$i]} || $MaxNbOf{$maxnboflist[$i]} !~ /^\d+$/ || $MaxNbOf{$maxnboflist[$i]}<1) 	{ $MaxNbOf{$maxnboflist[$i]}=$maxnboflistdefaultval[$i]; }
	}
	my @minhitlist=('Domain','Host','Login','Robot','Worm','File','ScreenSize','Refer','Keyphrase','Keyword','EMail');
	my @minhitlistdefaultval=(1,1,1,1,1,1,1,1,1,1,1);
	foreach my $i (0..(@minhitlist-1)) {
		if (! $MinHit{$minhitlist[$i]} || $MinHit{$minhitlist[$i]} !~ /^\d+$/ || $MinHit{$minhitlist[$i]}<1) 	{ $MinHit{$minhitlist[$i]}=$minhitlistdefaultval[$i]; }
	}
	if ($FirstDayOfWeek !~ /[0-1]/)               	{ $FirstDayOfWeek=1; }
	if ($UseFramesWhenCGI !~ /[0-1]/)  				{ $UseFramesWhenCGI=0; }
	if ($DetailedReportsOnNewWindows !~ /[0-2]/)  	{ $DetailedReportsOnNewWindows=1; }
	if ($ShowLinksOnUrl !~ /[0-1]/)               	{ $ShowLinksOnUrl=1; }
	if ($MaxLengthOfURL !~ /^\d+/ || $MaxLengthOfURL<1) { $MaxLengthOfURL=72; }
	if ($ShowLinksToWhoIs !~ /[0-1]/)              	{ $ShowLinksToWhoIs=0; }
	$Logo||='awstats_logo1.png';
	$LogoLink||='http://awstats.sourceforge.net';
	if ($BarWidth !~ /^\d+/ || $BarWidth<1) 		{ $BarWidth=260; }
	if ($BarHeight !~ /^\d+/ || $BarHeight<1)		{ $BarHeight=90; }
	$color_Background =~ s/#//g; if ($color_Background !~ /^[0-9|A-Z]+$/i)           { $color_Background='FFFFFF';	}
	$color_TableBGTitle =~ s/#//g; if ($color_TableBGTitle !~ /^[0-9|A-Z]+$/i)       { $color_TableBGTitle='CCCCDD'; }
	$color_TableTitle =~ s/#//g; if ($color_TableTitle !~ /^[0-9|A-Z]+$/i)           { $color_TableTitle='000000'; }
	$color_TableBG =~ s/#//g; if ($color_TableBG !~ /^[0-9|A-Z]+$/i)                 { $color_TableBG='CCCCDD'; }
	$color_TableRowTitle =~ s/#//g; if ($color_TableRowTitle !~ /^[0-9|A-Z]+$/i)     { $color_TableRowTitle='FFFFFF'; }
	$color_TableBGRowTitle =~ s/#//g; if ($color_TableBGRowTitle !~ /^[0-9|A-Z]+$/i) { $color_TableBGRowTitle='ECECEC'; }
	$color_TableBorder =~ s/#//g; if ($color_TableBorder !~ /^[0-9|A-Z]+$/i)         { $color_TableBorder='ECECEC'; }
	$color_text =~ s/#//g; if ($color_text !~ /^[0-9|A-Z]+$/i)           			 { $color_text='000000'; }
	$color_textpercent =~ s/#//g; if ($color_textpercent !~ /^[0-9|A-Z]+$/i)  		 { $color_textpercent='606060'; }
	$color_titletext =~ s/#//g; if ($color_titletext !~ /^[0-9|A-Z]+$/i) 			 { $color_titletext='000000'; }
	$color_weekend =~ s/#//g; if ($color_weekend !~ /^[0-9|A-Z]+$/i)     			 { $color_weekend='EAEAEA'; }
	$color_link =~ s/#//g; if ($color_link !~ /^[0-9|A-Z]+$/i)           			 { $color_link='0011BB'; }
	$color_hover =~ s/#//g; if ($color_hover !~ /^[0-9|A-Z]+$/i)         			 { $color_hover='605040'; }
	$color_other =~ s/#//g; if ($color_other !~ /^[0-9|A-Z]+$/i)         			 { $color_other='666688'; }
	$color_u =~ s/#//g; if ($color_u !~ /^[0-9|A-Z]+$/i)                 			 { $color_u='FFB055'; }
	$color_v =~ s/#//g; if ($color_v !~ /^[0-9|A-Z]+$/i)                 			 { $color_v='F8E880'; }
	$color_p =~ s/#//g; if ($color_p !~ /^[0-9|A-Z]+$/i)                 			 { $color_p='4477DD'; }
	$color_h =~ s/#//g; if ($color_h !~ /^[0-9|A-Z]+$/i)                 			 { $color_h='66F0FF'; }
	$color_k =~ s/#//g; if ($color_k !~ /^[0-9|A-Z]+$/i)                 			 { $color_k='2EA495'; }
	$color_s =~ s/#//g; if ($color_s !~ /^[0-9|A-Z]+$/i)                 			 { $color_s='8888DD'; }
	$color_e =~ s/#//g; if ($color_e !~ /^[0-9|A-Z]+$/i)                 			 { $color_e='CEC2E8'; }
	$color_x =~ s/#//g; if ($color_x !~ /^[0-9|A-Z]+$/i)                 			 { $color_x='C1B2E2'; }

	# Correct param if default value is asked
	if ($ShowMonthStats eq '1')      	{ $ShowMonthStats = 'UVPHB'; }
	if ($ShowDaysOfMonthStats eq '1') 	{ $ShowDaysOfMonthStats = 'VPHB'; }
	if ($ShowDaysOfWeekStats eq '1')    { $ShowDaysOfWeekStats = 'PHBL'; }
	if ($ShowHoursStats eq '1')         { $ShowHoursStats = 'PHBL'; }
	if ($ShowDomainsStats eq '1')       { $ShowDomainsStats = 'PHB'; }
	if ($ShowHostsStats eq '1')         { $ShowHostsStats = 'PHBL'; }
	if ($ShowEMailSenders eq '1')       { $ShowEMailSenders = 'HBML'; }
	if ($ShowEMailReceivers eq '1')     { $ShowEMailReceivers = 'HBML'; }
	if ($ShowAuthenticatedUsers eq '1') { $ShowAuthenticatedUsers = 'PHBL'; }
	if ($ShowRobotsStats eq '1') 		{ $ShowRobotsStats = 'HBL'; }
	if ($ShowWormsStats eq '1') 		{ $ShowWormsStats = 'HL'; }
	if ($ShowPagesStats eq '1') 		{ $ShowPagesStats = 'PBEX'; }
	if ($ShowFileTypesStats eq '1') 	{ $ShowFileTypesStats = 'HB'; }
	if ($ShowOriginStats eq '1') 		{ $ShowOriginStats = 'PH'; }

	# Convert extra sections data into @ExtraConditionType, @ExtraConditionTypeVal...
	foreach my $extranum (1..@ExtraName-1) {
		my $part=0;
		foreach my $conditioncouple (split(/\s\|\s/, $ExtraCondition[$extranum])) {
	 		my ($conditiontype, $conditiontypeval)=split(/,/,$conditioncouple,2);
	 		$ExtraConditionType[$extranum][$part]=$conditiontype;
	 		$ExtraConditionTypeVal[$extranum][$part]=($URLNotCaseSensitive?lc($conditiontypeval):$conditiontypeval);
			$part++;
	 	}
		$part=0;
		foreach my $rowkeycouple (split(/\s\|\s/, $ExtraFirstColumnValues[$extranum])) {
	 		my ($rowkeytype, $rowkeytypeval)=split(/,/,$rowkeycouple,2);
	 		$ExtraFirstColumnValuesType[$extranum][$part]=$rowkeytype;
	 		$ExtraFirstColumnValuesTypeVal[$extranum][$part]=($URLNotCaseSensitive?lc($rowkeytypeval):$rowkeytypeval);
			$part++;
	 	}
	}

	# Show definitive values for major parameters
	if ($Debug) {
		debug(" LogFile='$LogFile'",2);
		debug(" LogFormat='$LogFormat'",2);
		debug(" LogSeparator='$LogSeparator'",2);
		debug(" DNSLookup='$DNSLookup'",2);
		debug(" DirData='$DirData'",2);
		debug(" DirCgi='$DirCgi'",2);
		debug(" DirIcons='$DirIcons'",2);
		debug(" SiteDomain=$SiteDomain",2);
		foreach my $key (keys %MaxNbOf) {
			debug(" MaxNbOf{$key}=$MaxNbOf{$key}",2);
		}
		foreach my $key (keys %MinHit) {
			debug(" MinHit{$key}=$MinHit{$key}",2);
		}
	}
	foreach my $extranum (1..@ExtraName-1) {
		debug(" ExtraConditionType[$extranum] is array ".join(',',@{$ExtraConditionType[$extranum]}),2);
		debug(" ExtraConditionTypeVal[$extranum] is array ".join(',',@{$ExtraConditionTypeVal[$extranum]}),2);
		debug(" ExtraFirstColumnValuesType[$extranum] is array ".join(',',@{$ExtraFirstColumnValuesType[$extranum]}),2);
		debug(" ExtraFirstColumnValuesTypeVal[$extranum] is array ".join(',',@{$ExtraFirstColumnValuesTypeVal[$extranum]}),2);
	}

	# Refuse LogFile if contains a pipe and PurgeLogFile || ArchiveLogRecords set on
	if (($PurgeLogFile || $ArchiveLogRecords) && $LogFile =~ /\|\s*$/) {
		error("A pipe in log file name is not allowed if PurgeLogFile and ArchiveLogRecords are not set to 0");
	}
	# If not a migrate, check if DirData is OK
	if (! $MigrateStats && ! -d $DirData) {
		if ($CreateDirDataIfNotExists) {
			if ($Debug) { debug(" Make directory $DirData",2); }
			my $mkdirok=mkdir "$DirData", 0766;
			if (! $mkdirok) { error("$PROG failed to create directory DirData (DirData=\"$DirData\", CreateDirDataIfNotExists=$CreateDirDataIfNotExists)."); }
		}
		else {
			error("AWStats database directory defined in config file by 'DirData' parameter ($DirData) does not exist or is not writable.");
		}
	}
}


#------------------------------------------------------------------------------
# Function:     Common function used by init function of plugins
# Parameters:	AWStats version required by plugin
# Input:		$VERSION
# Output:		None
# Return: 		'' if ok, "Error: xxx" if error
#------------------------------------------------------------------------------
sub Check_Plugin_Version {
	my $PluginNeedAWStatsVersion=shift;
	if (! $PluginNeedAWStatsVersion) { return 0; }
	$VERSION =~ /^(\d+)\.(\d+)/;
	my $numAWStatsVersion=($1*1000)+$2;
	$PluginNeedAWStatsVersion =~ /^(\d+)\.(\d+)/;
	my $numPluginNeedAWStatsVersion=($1*1000)+$2;
	if 	($numPluginNeedAWStatsVersion > $numAWStatsVersion) {
		return "Error: AWStats version $PluginNeedAWStatsVersion or higher is required. Detected $VERSION.";
	}
	return '';
}


#------------------------------------------------------------------------------
# Function:     Return a checksum for an array of string
# Parameters:	Array of string
# Input:		None
# Output:		None
# Return: 		Checksum number
#------------------------------------------------------------------------------
sub CheckSum {
	my $string=shift;
	my $checksum=0;
#	use MD5;
# 	$checksum = MD5->hexhash($string);
	my $i=0; my $j=0; 
	while ($i < length($string)) { 
		my $c=substr($string,$i,1);
		$checksum+=(ord($c)<<(8*$j));
		if ($j++ > 3) { $j=0; }
		$i++;
	}
 	return $checksum;
}


#------------------------------------------------------------------------------
# Function:     Load plugins files
# Parameters:	None
# Input:		$DIR @PluginsToLoad
# Output:		None
# Return: 		None
#------------------------------------------------------------------------------
sub Read_Plugins {
	# Check plugin files in common possible directories :
	# Windows :                           		"${DIR}plugins" (plugins in same dir than awstats.pl)
	# Debian package :                    		"/usr/share/awstats/plugins"
	# Other possible directories :        		"./lang"
	my @PossiblePluginsDir=("${DIR}plugins","/usr/share/awstats/plugins","./plugins");

	if ($Debug) { debug("Call to Read_Plugins with list: @PluginsToLoad"); }
	foreach my $plugininfo (@PluginsToLoad) {
		my @loadplugin=split(/\s+/,$plugininfo,2);
		my $pluginfile=$loadplugin[0]; $pluginfile =~ s/\.pm$//i;
		my $pluginparam=$loadplugin[1]||'';
		$pluginfile =~ /([^\/\\]*)$/;
		my $pluginname=$1;
		if ($pluginname) {
			if (! $PluginsLoaded{'init'}{"$pluginname"}) {		# Plugin already loaded
				foreach my $dir (@PossiblePluginsDir) {
					my $searchdir=$dir;
					if ($searchdir && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
					my $pluginpath="${searchdir}${pluginfile}.pm";
					if (-s "$pluginpath") {
						$PluginDir="${searchdir}";	# Set plugin dir
						if ($Debug) { debug(" Try to init plugin '$pluginname' ($pluginpath) with param '$pluginparam'",1); }
						my $loadret=require "$pluginpath";
						if (! $loadret || $loadret =~ /^error/i) {
							# Load failed, we stop here
							error("Plugin load for plugin '$pluginname' failed with return code: $loadret");
						}
						my $ret;	# To get init return
						my $initfunction="\$ret=Init_$pluginname('$pluginparam')";
						my $initret=eval("$initfunction");
						if (! $initret || $initret =~ /^error/i) {
							# Init function failed, we stop here
							error("Plugin init for plugin '$pluginname' failed with return code: ".($initret?"$initret":"$@ (A module required by plugin might be missing)."));
						}
						# Plugin load and init successfull
						foreach my $elem (split(/\s+/,$initret)) {
							# Some functions can only be plugged once
							my @UniquePluginsFunctions=("ChangeTime","GetTimeZoneTitle","GetTime","SearchFile","LoadCache","SaveCash");
							foreach my $function (@UniquePluginsFunctions) {
								if ("$elem" eq "$function") {
									# We try to load a 'unique' function, so we check and stop if already loaded
									foreach my $otherpluginname (keys %{$PluginsLoaded{"$elem"}})  {
										error("Conflict between plugin '$pluginname' and '$otherpluginname'. They implements both the 'must be unique' function '$elem'.\nYou can use only one of these plugins but not both of them.");
									}
									last;
								}
							}
							$PluginsLoaded{"$elem"}{"$pluginname"}=1;
						}
						$PluginsLoaded{'init'}{"$pluginname"}=1;
						if ($Debug) { debug(" Plugin '$pluginname' now hooks functions '$initret'",1); }
						last;
					}
				}
				if (! $PluginsLoaded{'init'}{"$pluginname"}) {
					error("Can't open plugin file \"$pluginfile.pm\" for read.\nCheck if file is in \"".($PossiblePluginsDir[0])."\" directory and is readable.");
				}
			}
			else {
				warning("Warning: Tried to load plugin \"$pluginname\" twice. Fix config file.");
			}
		}
		else {
			error("Plugin \"$pluginfile\" is not a valid plugin name.");
		}
	}
}

#--------------------------------------------------------------------
# Function:		Read history file and create/update tmp history file
# Parameters:	year,month,withupdate,withpurge,part_to_load[,lastlinenumber,lastlineoffset,lastlinechecksum]
# Input:		$DirData $PROG $FileSuffix $LastLine
# Output:		None
# Return:		Tmp history file name or '' if withupdate is 0
#--------------------------------------------------------------------
sub Read_History_With_TmpUpdate {

	my $year=sprintf("%04i",shift||0);
	my $month=sprintf("%02i",shift||0);
	my $withupdate=shift||0;
	my $withpurge=shift||0;
	my $part=shift||'';

	my $lastlinenumber=shift||0;
	my $lastlineoffset=shift||0;
	my $lastlinechecksum=shift||0;

	my %allsections=('general'=>1,'time'=>2,'visitor'=>3,'day'=>4,
					 'domain'=>5,'login'=>6,'robot'=>7,'worms'=>8,'emailsender'=>9,'emailreceiver'=>10,
					 'session'=>11,'sider'=>12,'filetypes'=>13,
					 'os'=>14,'browser'=>15,'screensize'=>16,'unknownreferer'=>17,'unknownrefererbrowser'=>18,
					 'origin'=>19,'sereferrals'=>20,'pagerefs'=>21,
					 'searchwords'=>22,'keywords'=>23,
					 'errors'=>24);
	my $order=25;
	foreach my $code (keys %TrapInfosForHTTPErrorCodes) { $allsections{"sider_$code"}=$order++; }
	foreach my $extranum (1..@ExtraName-1) { $allsections{"extra_$extranum"}=$order++; }

	my $withread=0;

	# Two variables used to read old format history files
	my $readvisitorforbackward=0;

	# In standard use of AWStats, the DayRequired variable is always empty
	if ($DayRequired) { if ($Debug) { debug("Call to Read_History_With_TmpUpdate [$year,$month,withupdate=$withupdate,withpurge=$withpurge,part=$part,lastlinenumber=$lastlinenumber,lastlineoffset=$lastlineoffset,lastlinechecksum=$lastlinechecksum] ($DayRequired)"); } }
	else { if ($Debug) { debug("Call to Read_History_With_TmpUpdate [$year,$month,withupdate=$withupdate,withpurge=$withpurge,part=$part,lastlinenumber=$lastlinenumber,lastlineoffset=$lastlineoffset,lastlinechecksum=$lastlinechecksum]"); } }

	# Define SectionsToLoad (which sections to load)
	my %SectionsToLoad = ();
	if ($part eq 'all') {	# Load all needed sections
		my $order=1;
		$SectionsToLoad{'general'}=$order++;
		# When
		$SectionsToLoad{'time'}=$order++;	# Always loaded because needed to count TotalPages, TotalHits, TotalBandwidth
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowHostsStats) || $HTMLOutput{'allhosts'} || $HTMLOutput{'lasthosts'} || $HTMLOutput{'unknownip'}) { $SectionsToLoad{'visitor'}=$order++; }	# Must be before day, sider and session section
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && ($ShowDaysOfWeekStats || $ShowDaysOfMonthStats)) || $HTMLOutput{'alldays'}) { $SectionsToLoad{'day'}=$order++; }
		# Who
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowDomainsStats) || $HTMLOutput{'alldomains'}) { $SectionsToLoad{'domain'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowAuthenticatedUsers) || $HTMLOutput{'alllogins'} || $HTMLOutput{'lastlogins'}) { $SectionsToLoad{'login'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowRobotsStats) || $HTMLOutput{'allrobots'} || $HTMLOutput{'lastrobots'}) { $SectionsToLoad{'robot'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowWormsStats) || $HTMLOutput{'allworms'} || $HTMLOutput{'lastworms'}) { $SectionsToLoad{'worms'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowEMailSenders) || $HTMLOutput{'allemails'} || $HTMLOutput{'lastemails'}) { $SectionsToLoad{'emailsender'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowEMailReceivers) || $HTMLOutput{'allemailr'} || $HTMLOutput{'lastemailr'}) { $SectionsToLoad{'emailreceiver'}=$order++; }
		# Navigation
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowSessionsStats) || $HTMLOutput{'sessions'}) { $SectionsToLoad{'session'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowPagesStats) || $HTMLOutput{'urldetail'} || $HTMLOutput{'urlentry'} || $HTMLOutput{'urlexit'}) { $SectionsToLoad{'sider'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowFileTypesStats) || $HTMLOutput{'filetypes'}) { $SectionsToLoad{'filetypes'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowOSStats) || $HTMLOutput{'osdetail'}) { $SectionsToLoad{'os'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowBrowsersStats) || $HTMLOutput{'browserdetail'}) { $SectionsToLoad{'browser'}=$order++; }
		if ($UpdateStats || $MigrateStats || $HTMLOutput{'unknownos'})      { $SectionsToLoad{'unknownreferer'}=$order++; }
		if ($UpdateStats || $MigrateStats || $HTMLOutput{'unknownbrowser'}) { $SectionsToLoad{'unknownrefererbrowser'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowScreenSizeStats)) { $SectionsToLoad{'screensize'}=$order++; }
		# Referers
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowOriginStats) || $HTMLOutput{'origin'}) { $SectionsToLoad{'origin'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowOriginStats) || $HTMLOutput{'refererse'}) { $SectionsToLoad{'sereferrals'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowOriginStats) || $HTMLOutput{'refererpages'}) { $SectionsToLoad{'pagerefs'}=$order++; }
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowKeyphrasesStats) || $HTMLOutput{'keyphrases'} || $HTMLOutput{'keywords'}) { $SectionsToLoad{'searchwords'}=$order++; }
		if (! $withupdate && $HTMLOutput{'main'} && $ShowKeywordsStats) { $SectionsToLoad{'keywords'}=$order++; }	# If we update, dont need to load
		# Others
		if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowHTTPErrorsStats) || $HTMLOutput{'errors'}) { $SectionsToLoad{'errors'}=$order++; }
		foreach my $code (keys %TrapInfosForHTTPErrorCodes) {
			if ($UpdateStats || $MigrateStats || $HTMLOutput{"errors$code"}) { $SectionsToLoad{"sider_$code"}=$order++; }
		}
		foreach my $extranum (1..@ExtraName-1) {
			if ($UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ExtraStatTypes[$extranum]) || $HTMLOutput{"extra$extranum"}) { $SectionsToLoad{"extra_$extranum"}=$order++; }
		}
	}
	else {					# Load only required sections
		my $order=1;
		foreach my $key (split(/\s+/,$part)) { $SectionsToLoad{$key}=$order++; }
	}

	# Define SectionsToSave (which sections to save)
	my %SectionsToSave = ();
	if ($withupdate) { %SectionsToSave=%allsections; }

	if ($Debug) {
		foreach my $section (sort { $SectionsToLoad{$a} <=> $SectionsToLoad{$b} } keys %SectionsToLoad) { debug(" Section '$section' is marked for load",2); }
		foreach my $section (sort { $SectionsToSave{$a} <=> $SectionsToSave{$b} } keys %SectionsToSave) { debug(" Section '$section' is marked for save",2); }
	}

	# Define value for filetowrite and filetoread (Month before Year kept for backward compatibility)
	my $filetowrite='';
	my $filetoread='';
	if ($HistoryAlreadyFlushed{"$year$month"} && -s "$DirData/$PROG$month$year$FileSuffix.tmp.$$") {
		# tmp history file was already flushed
		$filetoread="$DirData/$PROG$month$year$FileSuffix.tmp.$$";
		$filetowrite="$DirData/$PROG$month$year$FileSuffix.tmp.$$.bis";
	}
	else {
		$filetoread="$DirData/$PROG$DayRequired$month$year$FileSuffix.txt";
		$filetowrite="$DirData/$PROG$month$year$FileSuffix.tmp.$$";
	}
	if ($Debug) { debug(" History file to read is '$filetoread'",2); }

	# Is there an old data file to read or if migrate, we need to open for read the file
	if (-s $filetoread || $MigrateStats) { $withread=1; }

	# Open files
	if ($withread) {
		open(HISTORY,$filetoread) || error("Couldn't open file \"$filetoread\" for read: $!","","",$MigrateStats);
		binmode HISTORY;	# Avoid premature EOF due to history files corrupted with \cZ or bin chars
	}
	if ($withupdate) {
		open(HISTORYTMP,">$filetowrite") || error("Couldn't open file \"$filetowrite\" for write: $!");
		Save_History("header",$year,$month);
	}

	# Loop on read file
	if ($withread) {
		my $countlines=0;
		my $versionnum=0;
		my @field=();
		while (<HISTORY>) {
			chomp $_; s/\r//;
			$countlines++;

			# Extract version from first line
			if (! $versionnum && $_ =~ /^AWSTATS DATA FILE (\d+).(\d+)/i) {
				$versionnum=($1*1000)+$2;
				if ($Debug) { debug(" Data file version is $versionnum",1); }
				next;
			}

			# Analyze fields
			@field=split(/\s+/,$_);
			if (! $field[0]) { next; }

			# BEGIN_GENERAL
			if ($field[0] eq 'BEGIN_GENERAL')      {
				if ($Debug) { debug(" Begin of GENERAL section"); }
				next;
			}
			if ($field[0] eq 'LastLine')        {
				if (! $LastLine || $LastLine < int($field[1])) { $LastLine=int($field[1]); };
				if ($field[2]) { $LastLineNumber=int($field[2]); }
				if ($field[3]) { $LastLineOffset=int($field[3]); }
				if ($field[4]) { $LastLineChecksum=int($field[4]); }
				next;
			}
			if ($field[0] eq 'FirstTime')       { if (! $FirstTime{$year.$month} || $FirstTime{$year.$month} > int($field[1])) { $FirstTime{$year.$month}=int($field[1]); }; next; }
			if ($field[0] eq 'LastTime')        { if (! $LastTime{$year.$month} || $LastTime{$year.$month} < int($field[1])) { $LastTime{$year.$month}=int($field[1]); }; next; }
			if ($field[0] eq 'LastUpdate')      {
				if ($LastUpdate < $field[1]) {
					$LastUpdate=int($field[1]);
					#$LastUpdateLinesRead=int($field[2]);
					#$LastUpdateNewLinesRead=int($field[3]);
					#$LastUpdateLinesCorrupted=int($field[4]);
				};
				next;
			}
			if ($field[0] eq 'TotalVisits')       {
				if (! $withupdate) { $MonthVisits{$year.$month}+=int($field[1]); }
				# Save in MonthVisits also if migrate from a file < 4.x for backward compatibility
				if ($MigrateStats && $versionnum < 4000 && ! $MonthVisits{$year.$month}) {
					debug("File is version < 4000. We save ".int($field[1])." visits in DayXxx arrays",1);
					$DayHits{$year.$month."00"}+=0;
					$DayVisits{$year.$month."00"}+=int($field[1]);
				}
				next;
			}
			if ($field[0] eq 'TotalUnique')       { if (! $withupdate) { $MonthUnique{$year.$month}+=int($field[1]); } next; }
			if ($field[0] eq 'MonthHostsKnown')   { if (! $withupdate) { $MonthHostsKnown{$year.$month}+=int($field[1]); } next; }
			if ($field[0] eq 'MonthHostsUnknown') { if (! $withupdate) { $MonthHostsUnknown{$year.$month}+=int($field[1]); } next; }

			if ($field[0] eq 'END_GENERAL'	# END_GENERAL didn't exist for history files < 5.0
			 || ($versionnum < 5000 && $SectionsToLoad{"general"} && $FirstTime{$year.$month} && $LastTime{$year.$month}) )		{
				if ($Debug) { debug(" End of GENERAL section"); }

				# Show migrate warning for backward compatibility
				if ($versionnum < 5000 && ! $MigrateStats && ! $BadFormatWarning{$year.$month}) {
					if ($FrameName ne 'mainleft') {
						$BadFormatWarning{$year.$month}=1;
						my $message="Warning: Data file '$filetoread' has an old history file format (version $versionnum). You should upgrade it...\nFrom command line: $PROG.$Extension -migrate=\"$filetoread\"";
						if ($ENV{'GATEWAY_INTERFACE'} && $AllowToUpdateStatsFromBrowser) { $message.="\nFrom your browser with URL: <a href=\"http://".$ENV{"SERVER_NAME"}.$ENV{"SCRIPT_NAME"}."?migrate=$filetoread\">http://".$ENV{"SERVER_NAME"}.$ENV{"SCRIPT_NAME"}."?migrate=$filetoread</a>"; }
						warning("$message");
					}
				}
				if (! ($versionnum < 5000) && $MigrateStats && ! $BadFormatWarning{$year.$month}) {
					$BadFormatWarning{$year.$month}=1;
					warning("Warning: You are migrating a file that is already a recent version (migrate not required for files version $versionnum).","","",1);
				}
				# If migrate and version < 4.x we need to include BEGIN_UNKNOWNIP into BEGIN_VISITOR for backward compatibility
				if ($MigrateStats && $versionnum < 4000) {
					debug("File is version < 4000. We add UNKOWNIP in sections to load",1);
					$SectionsToLoad{'unknownip'}=99;
				}

				delete $SectionsToLoad{'general'};
				if ($SectionsToSave{'general'}) { Save_History('general',$year,$month,$lastlinenumber,$lastlineoffset,$lastlinechecksum); delete $SectionsToSave{'general'}; }

				# Test for backward compatibility
				if ($versionnum < 5000 && ! $withupdate) {
					# We must find another way to init MonthUnique MonthHostsKnown and MonthHostsUnknown
					debug(" We ask to count MonthUnique, MonthHostsKnown and MonthHostsUnknown in visitor section because they are not stored in general section for this data file (version $versionnum).");
					$readvisitorforbackward=($SectionsToLoad{"visitor"}?1:2);
					$SectionsToLoad{"visitor"}=3;
				}
				else {
					if (! scalar %SectionsToLoad) {
						debug(" Stop reading history file. Got all we need."); last;
					}
				}
				if ($versionnum >= 5000) { next; }	# We can forget 'END_GENERAL' line and read next one
			}
			# BEGIN_TIME
			if ($field[0] eq 'BEGIN_TIME')      {
				if ($Debug) { debug(" Begin of TIME section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section TIME). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				my $monthpages=0;my $monthhits=0;my $monthbytes=0;
				while ($field[0] ne 'END_TIME') {
					#if ($field[0]) {	# This test must not be here for TIME section (because field[0] is "0" for hour 0)
						$count++;
						if ($SectionsToLoad{'time'}) {
							if ($withupdate || $MonthRequired eq 'all' || $MonthRequired eq "$month") {	# Still required
								$countloaded++;
								if ($field[1]) { $_time_p[$field[0]]+=int($field[1]); }
								if ($field[2]) { $_time_h[$field[0]]+=int($field[2]); }
								if ($field[3]) { $_time_k[$field[0]]+=int($field[3]); }
							}
							$monthpages+=int($field[1]);
							$monthhits+=int($field[2]);
							$monthbytes+=int($field[3]);
						}
					#}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section TIME). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				$MonthPages{$year.$month}+=$monthpages;
				$MonthHits{$year.$month}+=$monthhits;
				$MonthBytes{$year.$month}+=$monthbytes;
				if ($Debug) { debug(" End of TIME section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'time'};
				if ($SectionsToSave{'time'}) {
					Save_History('time',$year,$month); delete $SectionsToSave{'time'};
					if ($withpurge) { @_time_p=(); @_time_h=(); @_time_k=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}

			# BEGIN_ORIGIN
			if ($field[0] eq 'BEGIN_ORIGIN')	{
				if ($Debug) { debug(" Begin of ORIGIN section"); }
				next;
			}
			if ($SectionsToLoad{'origin'}) {
				if ($field[0] eq 'From0') { $_from_p[0]+=$field[1]; $_from_h[0]+=$field[2]; next; }
				if ($field[0] eq 'From1') { $_from_p[1]+=$field[1]; $_from_h[1]+=$field[2]; next; }
				if ($field[0] eq 'From2') { $_from_p[2]+=$field[1]; $_from_h[2]+=$field[2]; next; }
				if ($field[0] eq 'From3') { $_from_p[3]+=$field[1]; $_from_h[3]+=$field[2]; next; }
				if ($field[0] eq 'From4') { $_from_p[4]+=$field[1]; $_from_h[4]+=$field[2]; next; }
				if ($field[0] eq 'From5') { $_from_p[5]+=$field[1]; $_from_h[5]+=$field[2]; next; }
				# Next lines are to read old awstats history files ("Fromx" section was "HitFromx" in such files)
				if ($field[0] eq 'HitFrom0') { $_from_p[0]+=0; $_from_h[0]+=$field[1]; next; }
				if ($field[0] eq 'HitFrom1') { $_from_p[1]+=0; $_from_h[1]+=$field[1]; next; }
				if ($field[0] eq 'HitFrom2') { $_from_p[2]+=0; $_from_h[2]+=$field[1]; next; }
				if ($field[0] eq 'HitFrom3') { $_from_p[3]+=0; $_from_h[3]+=$field[1]; next; }
				if ($field[0] eq 'HitFrom4') { $_from_p[4]+=0; $_from_h[4]+=$field[1]; next; }
				if ($field[0] eq 'HitFrom5') { $_from_p[5]+=0; $_from_h[5]+=$field[1]; next; }
			}
			if ($field[0] eq 'END_ORIGIN')      {
				if ($Debug) { debug(" End of ORIGIN section"); }
				delete $SectionsToLoad{'origin'};
				if ($SectionsToSave{'origin'}) {
					Save_History('origin',$year,$month); delete $SectionsToSave{'origin'};
					if ($withpurge) { @_from_p=(); @_from_h=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_DAY
			if ($field[0] eq 'BEGIN_DAY')      {
				if ($Debug) { debug(" Begin of DAY section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section DAY). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_DAY' ) {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'day'}) {
							$countloaded++;
							if ($field[1]) { $DayPages{$field[0]}+=int($field[1]); }
							$DayHits{$field[0]}+=int($field[2]);						# DayHits always load (should be >0 and if not it's a day YYYYMM00 resulting of an old file migration)
							if ($field[3]) { $DayBytes{$field[0]}+=int($field[3]); }
							if ($field[4]) { $DayVisits{$field[0]}+=int($field[4]); }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section DAY). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of DAY section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'day'};
				# WE DO NOT SAVE SECTION NOW BECAUSE VALUES CAN BE CHANGED AFTER READING VISITOR
				#if ($SectionsToSave{'day'}) {	# Must be made after read of visitor
				#	Save_History('day',$year,$month); delete $SectionsToSave{'day'};
				#	if ($withpurge) { %DayPages=(); %DayHits=(); %DayBytes=(); %DayVisits=(); }
				#}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_VISITOR
			if ($field[0] eq 'BEGIN_VISITOR')   {
				if ($Debug) { debug(" Begin of VISITOR section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section VISITOR). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_VISITOR') {
					if ($field[0]) {
						$count++;

						# For backward compatibility
						if ($readvisitorforbackward) {
							if ($field[1]) { $MonthUnique{$year.$month}++; }
							if ($MonthRequired ne 'all') {
								if ($field[0] !~ /^\d+\.\d+\.\d+\.\d+$/ && $field[0] !~ /^[0-9A-F]*:/i) { $MonthHostsKnown{$year.$month}++; }
								else { $MonthHostsUnknown{$year.$month}++; }
							}
						}

						# Process data saved in 'wait' arrays
						if ($withupdate && $_waithost_e{$field[0]}){
							my $timehostl=int($field[4]||0);
							my $timehosts=int($field[5]||0);
							my $newtimehosts=($_waithost_s{$field[0]}?$_waithost_s{$field[0]}:$_host_s{$field[0]});
							my $newtimehostl=($_waithost_l{$field[0]}?$_waithost_l{$field[0]}:$_host_l{$field[0]});
							if ($newtimehosts > $timehostl + $VISITTIMEOUT ) {
								if ($Debug) { debug(" Visit for $field[0] in 'wait' arrays is a new visit different than last in history",4); }
								if ($field[6]) { $_url_x{$field[6]}++; }
								$_url_e{$_waithost_e{$field[0]}}++;
								$newtimehosts =~ /^(\d\d\d\d\d\d\d\d)/; $DayVisits{$1}++;
								if ($timehosts && $timehostl) { $_session{GetSessionRange($timehosts,$timehostl)}++; }
								if ($_waithost_s{$field[0]}) {
									# First session found in log was followed by another one so it's finished
									$_session{GetSessionRange($newtimehosts,$newtimehostl)}++;
								}
								# Here $_host_l $_host_s and $_host_u are correctly defined
							}
							else {
								if ($Debug) { debug(" Visit for $field[0] in 'wait' arrays is following of last visit in history",4); }
								if ($_waithost_s{$field[0]}) {
									# First session found in log was followed by another one so it's finished
									$_session{GetSessionRange(MinimumButNoZero($timehosts,$newtimehosts),$timehostl>$newtimehostl?$timehostl:$newtimehostl)}++;
									# Here $_host_l $_host_s and $_host_u are correctly defined
								}
								else {
									# We correct $_host_l $_host_s and $_host_u
									if ($timehostl > $newtimehostl) {
										$_host_l{$field[0]}=$timehostl;
										$_host_u{$field[0]}=$field[6];
									}
									if ($timehosts < $newtimehosts) {
										$_host_s{$field[0]}=$timehosts;
									}
								}
							}
							delete $_waithost_e{$field[0]};
							delete $_waithost_l{$field[0]};
							delete $_waithost_s{$field[0]};
							delete $_waithost_u{$field[0]};
						}

						# Load records
						if ($readvisitorforbackward!=2 && $SectionsToLoad{'visitor'}) { # if readvisitorforbackward==2 we do not load
							my $loadrecord=0;
							if ($withupdate) {
								$loadrecord=1;
							}
							else {
								if ($HTMLOutput{'allhosts'} || $HTMLOutput{'lasthosts'}) {
									if (!$HostFilter || $field[0] =~ /$HostFilter/) { $loadrecord=1; }
								}
								elsif ($MonthRequired eq 'all' || $field[2] >= $MinHit{'Host'}) {
									if ($HTMLOutput{'unknownip'} && ($field[0] =~ /^\d+\.\d+\.\d+\.\d+$/ || $field[0] =~ /^[0-9A-F]*:/i)) { $loadrecord=1; }
									elsif ($HTMLOutput{'main'} && ($MonthRequired eq 'all' || $countloaded < $MaxNbOf{'HostsShown'})) { $loadrecord=1; }
								}
							}
							if ($loadrecord) {
								if ($field[1]) { $_host_p{$field[0]}+=$field[1]; }
								if ($field[2]) { $_host_h{$field[0]}+=$field[2]; }
								if ($field[3]) { $_host_k{$field[0]}+=$field[3]; }
								if ($field[4] && ! $_host_l{$field[0]}) {	# We save last connexion params if not previously defined
									$_host_l{$field[0]}=int($field[4]);
									if ($withupdate) {		# field[5] field[6] are used only for update
										if ($field[5] && ! $_host_s{$field[0]}) { $_host_s{$field[0]}=int($field[5]); }
										if ($field[6] && ! $_host_u{$field[0]}) { $_host_u{$field[0]}=$field[6]; }
									}
								}
								$countloaded++;
							}
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section VISITOR). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of VISITOR section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'visitor'};
				# WE DO NOT SAVE SECTION NOW TO BE SURE TO HAVE THIS LARGE SECTION NOT AT THE BEGINNING OF FILE
				#if ($SectionsToSave{'visitor'}) {
				#	Save_History('visitor',$year,$month); delete $SectionsToSave{'visitor'};
				#	if ($withpurge) { %_host_p=(); %_host_h=(); %_host_k=(); %_host_l=(); %_host_s=(); %_host_u=(); }
				#}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_UNKOWNIP for backward compatibility
			if ($field[0] eq 'BEGIN_UNKNOWNIP')   {
				if ($Debug) { debug(" Begin of UNKNOWNIP section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section UNKNOWNIP). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				my %iptomigrate=();
				while ($field[0] ne 'END_UNKNOWNIP') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'unknownip'}) {
							$iptomigrate{$field[0]}=$field[1]||0;
							$countloaded++;
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section UNKNOWNIP). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of UNKNOWNIP section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'visitor'};
				# THIS SECTION IS NEVER SAVED. ONLY READ FOR MIGRATE AND CONVERTED INTO VISITOR SECTION
				foreach my $key (keys %iptomigrate) {
					$_host_p{$key}+=int($_host_p{'Unknown'}/$countloaded);
					$_host_h{$key}+=int($_host_h{'Unknown'}/$countloaded);
					$_host_k{$key}+=int($_host_k{'Unknown'}/$countloaded);
					if ($iptomigrate{$key} > 0) { $_host_l{$key}=$iptomigrate{$key} };
				}
				delete $_host_p{'Unknown'};
				delete $_host_h{'Unknown'};
				delete $_host_k{'Unknown'};
				delete $_host_l{'Unknown'};
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_LOGIN
			if ($field[0] eq 'BEGIN_LOGIN')   {
				if ($Debug) { debug(" Begin of LOGIN section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section LOGIN). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_LOGIN') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'login'}) {
							$countloaded++;
							if ($field[1]) { $_login_p{$field[0]}+=$field[1]; }
							if ($field[2]) { $_login_h{$field[0]}+=$field[2]; }
							if ($field[3]) { $_login_k{$field[0]}+=$field[3]; }
							if (! $_login_l{$field[0]} && $field[4]) { $_login_l{$field[0]}=int($field[4]); }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section LOGIN). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of LOGIN section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'login'};
				if ($SectionsToSave{'login'}) {
					Save_History('login',$year,$month); delete $SectionsToSave{'login'};
					if ($withpurge) { %_login_p=(); %_login_h=(); %_login_k=(); %_login_l=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_DOMAIN
			if ($field[0] eq 'BEGIN_DOMAIN')   {
				if ($Debug) { debug(" Begin of DOMAIN section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section DOMAIN). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_DOMAIN') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'domain'}) {
							$countloaded++;
							if ($field[1]) { $_domener_p{$field[0]}+=$field[1]; }
							if ($field[2]) { $_domener_h{$field[0]}+=$field[2]; }
							if ($field[3]) { $_domener_k{$field[0]}+=$field[3]; }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section DOMAIN). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of DOMAIN section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'domain'};
				if ($SectionsToSave{'domain'}) {
					Save_History('domain',$year,$month); delete $SectionsToSave{'domain'};
					if ($withpurge) { %_domener_p=(); %_domener_h=(); %_domener_k=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_SESSION
			if ($field[0] eq 'BEGIN_SESSION')   {
				if ($Debug) { debug(" Begin of SESSION section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section SESSION). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_SESSION') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'session'}) {
							$countloaded++;
							if ($field[1]) { $_session{$field[0]}+=$field[1]; }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section SESSION). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of SESSION section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'session'};
				# WE DO NOT SAVE SECTION NOW BECAUSE VALUES CAN BE CHANGED AFTER READING VISITOR
				#if ($SectionsToSave{'session'}) {
				#	Save_History('session',$year,$month); delete $SectionsToSave{'session'}; }
				#	if ($withpurge) { %_session=(); }
				#}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_OS
			if ($field[0] eq 'BEGIN_OS')   {
				if ($Debug) { debug(" Begin of OS section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section OS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_OS') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'os'}) {
							$countloaded++;
							if ($field[1]) { $_os_h{$field[0]}+=$field[1]; }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section OS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of OS section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'os'};
				if ($SectionsToSave{'os'}) {
					Save_History('os',$year,$month); delete $SectionsToSave{'os'};
					if ($withpurge) { %_os_h=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_BROWSER
			if ($field[0] eq 'BEGIN_BROWSER')   {
				if ($Debug) { debug(" Begin of BROWSER section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section BROWSER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_BROWSER') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'browser'}) {
							$countloaded++;
							if ($field[1]) { $_browser_h{$field[0]}+=$field[1]; }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section BROWSER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of BROWSER section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'browser'};
				if ($SectionsToSave{'browser'}) {
					Save_History('browser',$year,$month); delete $SectionsToSave{'browser'};
					if ($withpurge) { %_browser_h=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_UNKNOWNREFERER
			if ($field[0] eq 'BEGIN_UNKNOWNREFERER')   {
				if ($Debug) { debug(" Begin of UNKNOWNREFERER section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section UNKNOWNREFERER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_UNKNOWNREFERER') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'unknownreferer'}) {
							$countloaded++;
							if (! $_unknownreferer_l{$field[0]}) { $_unknownreferer_l{$field[0]}=int($field[1]); }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section UNKNOWNREFERER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of UNKNOWNREFERER section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'unknownreferer'};
				if ($SectionsToSave{'unknownreferer'}) {
					Save_History('unknownreferer',$year,$month); delete $SectionsToSave{'unknownreferer'};
					if ($withpurge) { %_unknownreferer_l=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_UNKNOWNREFERERBROWSER
			if ($field[0] eq 'BEGIN_UNKNOWNREFERERBROWSER')   {
				if ($Debug) { debug(" Begin of UNKNOWNREFERERBROWSER section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section UNKNOWNREFERERBROWSER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_UNKNOWNREFERERBROWSER') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'unknownrefererbrowser'}) {
							$countloaded++;
							if (! $_unknownrefererbrowser_l{$field[0]}) { $_unknownrefererbrowser_l{$field[0]}=int($field[1]); }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section UNKNOWNREFERERBROWSER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of UNKNOWNREFERERBROWSER section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'unknownrefererbrowser'};
				if ($SectionsToSave{'unknownrefererbrowser'}) {
					Save_History('unknownrefererbrowser',$year,$month); delete $SectionsToSave{'unknownrefererbrowser'};
					if ($withpurge) { %_unknownrefererbrowser_l=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_SCREENSIZE
			if ($field[0] eq 'BEGIN_SCREENSIZE')   {
				if ($Debug) { debug(" Begin of SCREENSIZE section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section SCREENSIZE). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_SCREENSIZE') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'screensize'}) {
							$countloaded++;
							if ($field[1]) { $_screensize_h{$field[0]}+=$field[1]; }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section SCREENSIZE). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of SCREENSIZE section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'screensize'};
				if ($SectionsToSave{'screensize'}) {
					Save_History('screensize',$year,$month); delete $SectionsToSave{'screensize'};
					if ($withpurge) { %_screensize_h=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_ROBOT
			if ($field[0] eq 'BEGIN_ROBOT')   {
				if ($Debug) { debug(" Begin of ROBOT section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section ROBOT). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_ROBOT') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'robot'}) {
							$countloaded++;
							if ($field[1]) { $_robot_h{$field[0]}+=$field[1]; }
							if ($versionnum < 5000 || ! $field[3]) {		# For backward compatibility
								if (! $_robot_l{$field[0]}) { $_robot_l{$field[0]}=int($field[2]); }
							}
							else {
								$_robot_k{$field[0]}+=$field[2];
								if (! $_robot_l{$field[0]}) { $_robot_l{$field[0]}=int($field[3]); }
							}
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section ROBOT). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of ROBOT section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'robot'};
				if ($SectionsToSave{'robot'}) {
					Save_History('robot',$year,$month); delete $SectionsToSave{'robot'};
					if ($withpurge) { %_robot_h=(); %_robot_k=(); %_robot_l=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_EMAILS
			if ($field[0] eq 'BEGIN_EMAILSENDER')   {
				if ($Debug) { debug(" Begin of EMAILSENDER section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section EMAILSENDER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_EMAILSENDER') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'emailsender'}) {
							$countloaded++;
							if ($field[1]) { $_emails_h{$field[0]}+=$field[1]; }
							if ($field[2]) { $_emails_k{$field[0]}+=$field[2]; }
							if (! $_emails_l{$field[0]}) { $_emails_l{$field[0]}=int($field[3]); }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section EMAILSENDER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of EMAILSENDER section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'emailsender'};
				if ($SectionsToSave{'emailsender'}) {
					Save_History('emailsender',$year,$month); delete $SectionsToSave{'emailsender'};
					if ($withpurge) { %_emails_h=(); %_emails_k=(); %_emails_l=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_EMAILR
			if ($field[0] eq 'BEGIN_EMAILRECEIVER')   {
				if ($Debug) { debug(" Begin of EMAILRECEIVER section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section EMAILRECEIVER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_EMAILRECEIVER') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'emailreceiver'}) {
							$countloaded++;
							if ($field[1]) { $_emailr_h{$field[0]}+=$field[1]; }
							if ($field[2]) { $_emailr_k{$field[0]}+=$field[2]; }
							if (! $_emailr_l{$field[0]}) { $_emailr_l{$field[0]}=int($field[3]); }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section EMAILRECEIVER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of EMAILRECEIVER section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'emailreceiver'};
				if ($SectionsToSave{'emailreceiver'}) {
					Save_History('emailreceiver',$year,$month); delete $SectionsToSave{'emailreceiver'};
					if ($withpurge) { %_emailr_h=(); %_emailr_k=(); %_emailr_l=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_SIDER
			if ($field[0] eq 'BEGIN_SIDER')  {
				if ($Debug) { debug(" Begin of SIDER section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section SIDER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_SIDER') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'sider'}) {
							my $loadrecord=0;
							if ($withupdate) {
								$loadrecord=1;
							}
							else {
								if ($HTMLOutput{'main'}) {
									if ($MonthRequired eq 'all') { $loadrecord=1; }
									else {
										if ($countloaded < $MaxNbOf{'PageShown'} && $field[1] >= $MinHit{'File'}) { $loadrecord=1; }
										$TotalDifferentPages++;
									}
								}
								else {	# This is for $HTMLOutput = urldetail, urlentry or urlexit
									if ($MonthRequired eq 'all' ) {
										if (!$URLFilter || $field[0] =~ /$URLFilter/) { $loadrecord=1; }
									}
									else {
										if ((!$URLFilter || $field[0] =~ /$URLFilter/) && $field[1] >= $MinHit{'File'}) { $loadrecord=1; }
										$TotalDifferentPages++;
									}
								}
								# Posssibilite de mettre if ($URLFilter && $field[0] =~ /$URLFilter/) mais il faut gerer TotalPages de la meme maniere
								if ($versionnum < 4000) {	# For history files < 4.0
									$TotalEntries+=($field[2]||0);
								}
								else {
									$TotalBytesPages+=($field[2]||0);
									$TotalEntries+=($field[3]||0);
									$TotalExits+=($field[4]||0);
								}
							}
							if ($loadrecord) {
								if ($field[1]) { $_url_p{$field[0]}+=$field[1]; }
								if ($versionnum < 4000) {	# For history files < 4.0
									if ($field[2]) { $_url_e{$field[0]}+=$field[2]; }
									$_url_k{$field[0]}=0;
								}
								else {
									if ($field[2]) { $_url_k{$field[0]}+=$field[2]; }
									if ($field[3]) { $_url_e{$field[0]}+=$field[3]; }
									if ($field[4]) { $_url_x{$field[0]}+=$field[4]; }
								}
								$countloaded++;
							}
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section SIDER). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of SIDER section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'sider'};
				# WE DO NOT SAVE SECTION NOW BECAUSE VALUES CAN BE CHANGED AFTER READING VISITOR
				#if ($SectionsToSave{'sider'}) {
				#	Save_History('sider',$year,$month); delete $SectionsToSave{'sider'};
				#	if ($withpurge) { %_url_p=(); %_url_k=(); %_url_e=(); %_url_x=(); }
				#}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_FILETYPES
			if ($field[0] eq 'BEGIN_FILETYPES')   {
				if ($Debug) { debug(" Begin of FILETYPES section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section FILETYPES). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_FILETYPES') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'filetypes'}) {
							$countloaded++;
							if ($field[1]) { $_filetypes_h{$field[0]}+=$field[1]; }
							if ($field[2]) { $_filetypes_k{$field[0]}+=$field[2]; }
							if ($field[3]) { $_filetypes_gz_in{$field[0]}+=$field[3]; }
							if ($field[4]) { $_filetypes_gz_out{$field[0]}+=$field[4]; }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section FILETYPES). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of FILETYPES section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'filetypes'};
				if ($SectionsToSave{'filetypes'}) {
					Save_History('filetypes',$year,$month); delete $SectionsToSave{'filetypes'};
					if ($withpurge) { %_filetypes_h=(); %_filetypes_k=(); %_filetypes_gz_in=(); %_filetypes_gz_out=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_SEREFERRALS
			if ($field[0] eq 'BEGIN_SEREFERRALS')   {
				if ($Debug) { debug(" Begin of SEREFERRALS section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section SEREFERRALS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_SEREFERRALS') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'sereferrals'}) {
							$countloaded++;
							if ($versionnum < 5004) {	# For history files < 5.4
								if ($field[1]) { $_se_referrals_h{$field[0]}+=$field[1]; }
							} else {
								if ($field[1]) { $_se_referrals_p{$field[0]}+=$field[1]; }
								if ($field[2]) { $_se_referrals_h{$field[0]}+=$field[2]; }
							}
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section SEREFERRALS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of SEREFERRALS section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'sereferrals'};
				if ($SectionsToSave{'sereferrals'}) {
					Save_History('sereferrals',$year,$month); delete $SectionsToSave{'sereferrals'};
					if ($withpurge) { %_se_referrals_p=(); %_se_referrals_h=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_PAGEREFS
			if ($field[0] eq 'BEGIN_PAGEREFS')   {
				if ($Debug) { debug(" Begin of PAGEREFS section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section PAGEREFS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_PAGEREFS') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'pagerefs'}) {
							my $loadrecord=0;
							if ($withupdate) {
								$loadrecord=1;
							}
							else {
								if (!$RefererPagesFilter || $field[0] =~ /$RefererPagesFilter/) { $loadrecord=1; }
							}
							if ($loadrecord) {
								if ($versionnum < 5004) {	# For history files < 5.4
									if ($field[1]) { $_pagesrefs_h{$field[0]}+=int($field[1]); }
								} else {
									if ($field[1]) { $_pagesrefs_p{$field[0]}+=int($field[1]); }
									if ($field[2]) { $_pagesrefs_h{$field[0]}+=int($field[2]); }
								}
								$countloaded++;
							}
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section PAGEREFS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of PAGEREFS section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'pagerefs'};
				if ($SectionsToSave{'pagerefs'}) {
					Save_History('pagerefs',$year,$month); delete $SectionsToSave{'pagerefs'};
					if ($withpurge) { %_pagesrefs_p=(); %_pagesrefs_h=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_SEARCHWORDS
			if ($field[0] eq 'BEGIN_SEARCHWORDS')   {
				if ($Debug) { debug(" Begin of SEARCHWORDS section ($MaxNbOf{'KeyphrasesShown'},$MinHit{'Keyphrase'})"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section SEARCHWORDS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_SEARCHWORDS') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'searchwords'}) {
							my $loadrecord=0;
							if ($withupdate) {
								$loadrecord=1;
							}
							else {
								if ($HTMLOutput{'main'}) {
									if ($MonthRequired eq 'all') { $loadrecord=1; }
									else {
										if ($countloaded < $MaxNbOf{'KeyphrasesShown'} && $field[1] >= $MinHit{'Keyphrase'}) { $loadrecord=1; }
										$TotalDifferentKeyphrases++;
										$TotalKeyphrases+=($field[1]||0);
									}
								}
								elsif ($HTMLOutput{'keyphrases'}) {	# Load keyphrases for keyphrases chart
									if ($MonthRequired eq 'all' ) { $loadrecord=1; }
									else {
										if ($field[1] >= $MinHit{'Keyphrase'}) { $loadrecord=1; }
										$TotalDifferentKeyphrases++;
										$TotalKeyphrases+=($field[1]||0);
									}
								}
								if ($HTMLOutput{'keywords'}) {	# Load keyphrases for keywords chart
									$loadrecord=2;
								}
							}
							if ($loadrecord) {
								if ($field[1]) {
									if ($loadrecord==2) {
										foreach my $word (split(/\+/,$field[0])) {	# val1+val2
											$_keywords{$word}+=$field[1];
										}
									}
									else {
										$_keyphrases{$field[0]}+=$field[1];
									}
								}
								$countloaded++;
							}
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section SEARCHWORDS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of SEARCHWORDS section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'searchwords'};
				if ($SectionsToSave{'searchwords'}) {
					Save_History('searchwords',$year,$month); delete $SectionsToSave{'searchwords'};	# This save searwords and keywords sections
					if ($withpurge) { %_keyphrases=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_KEYWORDS
			if ($field[0] eq 'BEGIN_KEYWORDS')   {
				if ($Debug) { debug(" Begin of KEYWORDS section ($MaxNbOf{'KeywordsShown'},$MinHit{'Keyword'})"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section KEYWORDS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_KEYWORDS') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'keywords'}) {
							my $loadrecord=0;
							if ($MonthRequired eq 'all') { $loadrecord=1; }
							else {
								if ($countloaded < $MaxNbOf{'KeywordsShown'} && $field[1] >= $MinHit{'Keyword'}) { $loadrecord=1; }
								$TotalDifferentKeywords++;
								$TotalKeywords+=($field[1]||0);
							}
							if ($loadrecord) {
								if ($field[1]) { $_keywords{$field[0]}+=$field[1]; }
								$countloaded++;
							}
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section KEYWORDS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of KEYWORDS section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'keywords'};
				if ($SectionsToSave{'keywords'}) {
					Save_History('keywords',$year,$month); delete $SectionsToSave{'keywords'};
					if ($withpurge) { %_keywords=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_ERRORS
			if ($field[0] eq 'BEGIN_ERRORS')   {
				if ($Debug) { debug(" Begin of ERRORS section"); }
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if (! $_) { error("History file \"$filetoread\" is corrupted (in section ERRORS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
				my @field=split(/\s+/,$_); $countlines++;
				my $count=0;my $countloaded=0;
				while ($field[0] ne 'END_ERRORS') {
					if ($field[0]) {
						$count++;
						if ($SectionsToLoad{'errors'}) {
							$countloaded++;
							if ($field[1]) { $_errors_h{$field[0]}+=$field[1]; }
							if ($field[2]) { $_errors_k{$field[0]}+=$field[2]; }
						}
					}
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section ERRORS). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					@field=split(/\s+/,$_); $countlines++;
				}
				if ($Debug) { debug(" End of ERRORS section ($count entries, $countloaded loaded)"); }
				delete $SectionsToLoad{'errors'};
				if ($SectionsToSave{'errors'}) {
					Save_History('errors',$year,$month); delete $SectionsToSave{'errors'};
					if ($withpurge) { %_errors_h=(); %_errors_k=(); }
				}
				if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
				next;
			}
			# BEGIN_SIDER_xxx
			foreach my $code (keys %TrapInfosForHTTPErrorCodes) {
				if ($field[0] eq "BEGIN_SIDER_$code")   {
					if ($Debug) { debug(" Begin of SIDER_$code section"); }
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$filetoread\" is corrupted (in section SIDER_$code). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
					my @field=split(/\s+/,$_); $countlines++;
					my $count=0;my $countloaded=0;
					while ($field[0] ne "END_SIDER_$code") {
						if ($field[0]) {
							$count++;
							if ($SectionsToLoad{"sider_$code"}) {
								$countloaded++;
								if ($field[1]) { $_sider404_h{$field[0]}+=$field[1]; }
								if ($withupdate || $HTMLOutput{"errors$code"}) {
									if ($field[2]) { $_referer404_h{$field[0]}=$field[2]; }
								}
							}
						}
						$_=<HISTORY>;
						chomp $_; s/\r//;
						if (! $_) { error("History file \"$filetoread\" is corrupted (in section SIDER_$code). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost).","","",1); }
						@field=split(/\s+/,$_); $countlines++;
					}
					if ($Debug) { debug(" End of SIDER_$code section ($count entries, $countloaded loaded)"); }
					delete $SectionsToLoad{"sider_$code"};
					if ($SectionsToSave{"sider_$code"}) {
						Save_History("sider_$code",$year,$month); delete $SectionsToSave{"sider_$code"};
						if ($withpurge) { %_sider404_h=(); %_referer404_h=(); }
					}
					if (! scalar %SectionsToLoad) { debug(" Stop reading history file. Got all we need."); last; }
					next;
				}
			}
			# BEGIN_EXTRA_xxx
			foreach my $extranum (1..@ExtraName-1) {
				if ($field[0] eq "BEGIN_EXTRA_$extranum")   {
					if ($Debug) { debug(" Begin of EXTRA_$extranum"); }
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if (! $_) { error("History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section EXTRA_$extranum). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
					my @field=split(/\s+/,$_); $countlines++;
					my $count=0;my $countloaded=0;
					while ($field[0] ne "END_EXTRA_$extranum") {
						# if ($field[0]) {
							$count++;
							if ($SectionsToLoad{"extra_$extranum"}) {
								if ($ExtraStatTypes[$extranum] =~ m/P/i && $field[1]) { ${'_section_' . $extranum . '_p'}{$field[0]}+=$field[1]; }
								${'_section_' . $extranum . '_h'}{$field[0]}+=$field[2];
								if ($ExtraStatTypes[$extranum] =~ m/B/i && $field[3]) { ${'_section_' . $extranum . '_k'}{$field[0]}+=$field[3]; }
								if ($ExtraStatTypes[$extranum] =~ m/L/i && ! ${'_section_' . $extranum . '_l'}{$field[0]} && $field[4]) { ${'_section_' . $extranum . '_l'}{$field[0]}=int($field[4]); }
								$countloaded++;
							}
						# }
						$_=<HISTORY>;
						chomp $_; s/\r//;
						if (! $_) { error("History file \"$DirData/$PROG$month$year$FileSuffix.txt\" is corrupted (in section EXTRA_$extranum). Last line read is number $countlines.\nCorrect the line, restore a recent backup of this file, or remove it (data for this month will be lost)."); }
						@field=split(/\s+/,$_); $countlines++;
					}
					if ($Debug) { debug(" End of EXTRA_$extranum ($count entries, $countloaded loaded)"); }
					next;
				}
			}
		}
	}

	if ($withupdate) {
		# Process rest of data saved in 'wait' arrays (data for hosts that are not in history file or no history file found)
		# This can change some values for day, sider and session sections
		if ($Debug) { debug(" Processing data in 'wait' arrays",3); }
		foreach my $key (keys %_waithost_e) {
			if ($Debug) { debug("  Visit in 'wait' arrays is a new visit",4); }
			my $newtimehosts=($_waithost_s{$key}?$_waithost_s{$key}:$_host_s{$key});
			my $newtimehostl=($_waithost_l{$key}?$_waithost_l{$key}:$_host_l{$key});
			$_url_e{$_waithost_e{$key}}++;
			$newtimehosts =~ /^(\d\d\d\d\d\d\d\d)/; $DayVisits{$1}++;
			if ($_waithost_s{$key}) {
				# There was also a second session in processed log
				$_session{GetSessionRange($newtimehosts,$newtimehostl)}++;
			}
		}
	}

	# Write all unwrote sections in section order ('general','time', 'day','sider','session' and other...)
	foreach my $key (sort { $SectionsToSave{$a} <=> $SectionsToSave{$b} } keys %SectionsToSave) {
		Save_History("$key",$year,$month,$lastlinenumber,$lastlineoffset,$lastlinechecksum);
	}
	%SectionsToSave=();

	# Update offset in map section and last data in general section then close files
	if ($withupdate) {
		# Update offset of sections in the MAP section
		foreach my $key (sort { $PosInFile{$a} <=> $PosInFile{$b} } keys %ValueInFile) {
			debug(" Update offset of section $key=$ValueInFile{$key} in file at offset $PosInFile{$key}");
			if ($PosInFile{"$key"}) {
				seek(HISTORYTMP,$PosInFile{"$key"},0); print HISTORYTMP $ValueInFile{"$key"};
			}
		}
		# Save last data in general sections
		debug(" Update MonthVisits=$MonthVisits{$year.$month} in file at offset $PosInFile{TotalVisits}");
		seek(HISTORYTMP,$PosInFile{"TotalVisits"},0); print HISTORYTMP $MonthVisits{$year.$month};
		debug(" Update MonthUnique=$MonthUnique{$year.$month} in file at offset $PosInFile{TotalUnique}");
		seek(HISTORYTMP,$PosInFile{"TotalUnique"},0); print HISTORYTMP $MonthUnique{$year.$month};
		debug(" Update MonthHostsKnown=$MonthHostsKnown{$year.$month} in file at offset $PosInFile{MonthHostsKnown}");
		seek(HISTORYTMP,$PosInFile{"MonthHostsKnown"},0); print HISTORYTMP $MonthHostsKnown{$year.$month};
		debug(" Update MonthHostsUnknown=$MonthHostsUnknown{$year.$month} in file at offset $PosInFile{MonthHostsUnknown}");
		seek(HISTORYTMP,$PosInFile{"MonthHostsUnknown"},0); print HISTORYTMP $MonthHostsUnknown{$year.$month};
		close(HISTORYTMP) || error("Failed to write temporary history file");
	}
	if ($withread) {
		close(HISTORY) || error("Command for pipe '$filetoread' failed");
	}

	# Purge data
	if ($withpurge) { &Init_HashArray(); }

	# If update, rename tmp file bis into tmp file or set HistoryAlreadyFlushed
	if ($withupdate) {
		if ($HistoryAlreadyFlushed{"$year$month"}) {
			if (rename($filetowrite,$filetoread)==0) {
				error("Failed to update tmp history file $filetoread");
			}
		}
		else {
			$HistoryAlreadyFlushed{"$year$month"}=1;
		}
		if (! $ListOfYears{"$year"} || $ListOfYears{"$year"} lt "$month") { $ListOfYears{"$year"}="$month"; }
	}

	# For backward compatibility, if LastLine does not exist, set to LastTime
	$LastLine||=$LastTime{$year.$month};

	return ($withupdate?"$filetowrite":"");
}

#--------------------------------------------------------------------
# Function:		Save a part of history file
# Parameters:	part_to_save,year,month[,lastlinenumber,lastlineoffset,lastlinechecksum]
# Input:		$VERSION HISTORYTMP $nowyear $nowmonth $nowday $nowhour $nowmin $nowsec $LastLineNumber $LastLineOffset $LastLineChecksum
# Output:		None
# Return:		None
#--------------------------------------------------------------------
sub Save_History {
	my $sectiontosave=shift||'';
	my $year=shift||'';
	my $month=shift||'';

	my $lastlinenumber=shift||0;
	my $lastlineoffset=shift||0;
	my $lastlinechecksum=shift||0;
	if (! $lastlinenumber) {	# Should be needed for migrate only
		$lastlinenumber=$LastLineNumber;
		$lastlineoffset=$LastLineOffset;
		$lastlinechecksum=$LastLineChecksum;
	}
	
	if ($Debug) { debug(" Save_History [sectiontosave=$sectiontosave,year=$year,month=$month,lastlinenumber=$lastlinenumber,lastlineoffset=$lastlineoffset,lastlinechecksum=$lastlinechecksum]",3); }
	my $spacebar="                    ";
	my %keysinkeylist=();

	# Header
	if ($sectiontosave eq 'header') {
		print HISTORYTMP "AWSTATS DATA FILE $VERSION\n";
		print HISTORYTMP "# If you remove this file, all statistics for date $year-$month will be lost/reset.\n";
		print HISTORYTMP "\n";
		print HISTORYTMP "# Position (offset in bytes) in this file of beginning of each section\n";
		print HISTORYTMP "# for direct I/O access. If you made changes somewhere in this file, you\n";
		print HISTORYTMP "# should also remove completely the MAP section (AWStats will rewrite it\n";
		print HISTORYTMP "# at next update).\n";
		print HISTORYTMP "BEGIN_MAP ".(24+(scalar keys %TrapInfosForHTTPErrorCodes)+(scalar @ExtraName?scalar @ExtraName-1:0))."\n";
		print HISTORYTMP "POS_GENERAL ";$PosInFile{"general"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		# When
		print HISTORYTMP "POS_TIME ";$PosInFile{"time"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_VISITOR ";$PosInFile{"visitor"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_DAY ";$PosInFile{"day"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		# Who
		print HISTORYTMP "POS_DOMAIN ";$PosInFile{"domain"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_LOGIN ";$PosInFile{"login"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_ROBOT ";$PosInFile{"robot"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_WORMS ";$PosInFile{"worms"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_EMAILSENDER ";$PosInFile{"emailsender"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_EMAILRECEIVER ";$PosInFile{"emailreceiver"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		# Navigation
		print HISTORYTMP "POS_SESSION ";$PosInFile{"session"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_SIDER ";$PosInFile{"sider"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_FILETYPES ";$PosInFile{"filetypes"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_OS ";$PosInFile{"os"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_BROWSER ";$PosInFile{"browser"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_SCREENSIZE ";$PosInFile{"screensize"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_UNKNOWNREFERER ";$PosInFile{'unknownreferer'}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_UNKNOWNREFERERBROWSER ";$PosInFile{'unknownrefererbrowser'}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		# Referers
		print HISTORYTMP "POS_ORIGIN ";$PosInFile{"origin"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_SEREFERRALS ";$PosInFile{"sereferrals"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_PAGEREFS ";$PosInFile{"pagerefs"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_SEARCHWORDS ";$PosInFile{"searchwords"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "POS_KEYWORDS ";$PosInFile{"keywords"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		# Others
		print HISTORYTMP "POS_ERRORS ";$PosInFile{"errors"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		foreach my $code (keys %TrapInfosForHTTPErrorCodes) {
			print HISTORYTMP "POS_SIDER_$code ";$PosInFile{"sider_$code"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		}
		foreach my $extranum (1..@ExtraName-1) {
			print HISTORYTMP "POS_EXTRA_$extranum ";$PosInFile{"extra_$extranum"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		}
		print HISTORYTMP "END_MAP\n";
	}

	# General
	if ($sectiontosave eq 'general') {
		if ($LastUpdate < int("$nowyear$nowmonth$nowday$nowhour$nowmin$nowsec")) { $LastUpdate=int("$nowyear$nowmonth$nowday$nowhour$nowmin$nowsec"); }
		print HISTORYTMP "\n";
		print HISTORYTMP "# LastLine    = Date of last record processed - Last record line number in last log - Last record offset in last log - Last record signature value\n";
		print HISTORYTMP "# FirstTime   = Date of first visit for history file\n";
		print HISTORYTMP "# LastTime    = Date of last visit for history file\n";
		print HISTORYTMP "# LastUpdate  = Date of last update - Nb of parsed records - Nb of old records - Nb of new records - Nb of corrupted - Nb of dropped\n";
		print HISTORYTMP "# TotalVisits = Number of visits\n";
		print HISTORYTMP "# TotalUnique = Number of unique visitors\n";
		print HISTORYTMP "# MonthHostsKnown   = Number of hosts known\n";
		print HISTORYTMP "# MonthHostsUnKnown = Number of hosts unknown\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_GENERAL 8\n";
		print HISTORYTMP "LastLine ".($LastLine>0?$LastLine:$LastTime{$year.$month})." $lastlinenumber $lastlineoffset $lastlinechecksum\n";
		print HISTORYTMP "FirstTime $FirstTime{$year.$month}\n";
		print HISTORYTMP "LastTime $LastTime{$year.$month}\n";
		print HISTORYTMP "LastUpdate $LastUpdate $NbOfLinesParsed $NbOfOldLines $NbOfNewLines $NbOfLinesCorrupted $NbOfLinesDropped\n";
		print HISTORYTMP "TotalVisits ";$PosInFile{"TotalVisits"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "TotalUnique ";$PosInFile{"TotalUnique"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "MonthHostsKnown ";$PosInFile{"MonthHostsKnown"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "MonthHostsUnknown ";$PosInFile{"MonthHostsUnknown"}=tell HISTORYTMP;print HISTORYTMP "$spacebar\n";
		print HISTORYTMP "END_GENERAL\n";
	}

	# When
	if ($sectiontosave eq 'time') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Hour - Pages - Hits - Bandwidth\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_TIME 24\n";
		for (my $ix=0; $ix<=23; $ix++) { print HISTORYTMP "$ix ".int($_time_p[$ix])." ".int($_time_h[$ix])." ".int($_time_k[$ix])."\n"; }
		print HISTORYTMP "END_TIME\n";
	}
	if ($sectiontosave eq 'day') {	# This section must be saved after VISITOR section is read
		print HISTORYTMP "\n";
		print HISTORYTMP "# Date - Pages - Hits - Bandwidth - Visits\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_DAY ".(scalar keys %DayHits)."\n";
		my $monthvisits=0;
		foreach my $key (sort keys %DayHits) {
			if ($key =~ /^$year$month/i) {	# Found a day entry of the good month
				my $page=$DayPages{$key}||0;
				my $hits=$DayHits{$key}||0;
				my $bytes=$DayBytes{$key}||0;
				my $visits=$DayVisits{$key}||0;
				print HISTORYTMP "$key $page $hits $bytes $visits\n";
				$monthvisits+=$visits;
			}
		}
		$MonthVisits{$year.$month}=$monthvisits;
		print HISTORYTMP "END_DAY\n";
	}

	# Who
	if ($sectiontosave eq 'domain') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Domain - Pages - Hits - Bandwidth\n";
		print HISTORYTMP "# The $MaxNbOf{'Domain'} first Pages must be first (order not required for others)\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_DOMAIN ".(scalar keys %_domener_h)."\n";
		# We save page list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList($MaxNbOf{'Domain'},$MinHit{'Domain'},\%_domener_h,\%_domener_p);
		my %keysinkeylist=();
		foreach my $key (@keylist) {
			$keysinkeylist{$key}=1;
			my $page=$_domener_p{$key}||0;
			my $bytes=$_domener_k{$key}||0;		# ||0 could be commented to reduce history file size
			print HISTORYTMP "$key $page $_domener_h{$key} $bytes\n";
		}
		foreach my $key (keys %_domener_h) {
			if ($keysinkeylist{$key}) { next; }
			my $page=$_domener_p{$key}||0;
			my $bytes=$_domener_k{$key}||0;		# ||0 could be commented to reduce history file size
			print HISTORYTMP "$key $page $_domener_h{$key} $bytes\n";
		}
		print HISTORYTMP "END_DOMAIN\n";
	}
	if ($sectiontosave eq 'visitor') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Host - Pages - Hits - Bandwidth - Last visit date - [Start of last visit date] - [Last page of last visit]\n";
		print HISTORYTMP "# [Start of last visit date] and [Last page of last visit] are saved only if session is not finished\n";
		print HISTORYTMP "# The $MaxNbOf{'HostsShown'} first Hits must be first (order not required for others)\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_VISITOR ".(scalar keys %_host_h)."\n";
		my $monthhostsknown=0;
		# We save page list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList($MaxNbOf{'HostsShown'},$MinHit{'Host'},\%_host_h,\%_host_p);
		my %keysinkeylist=();
		foreach my $key (@keylist) {
			if ($key !~ /^\d+\.\d+\.\d+\.\d+$/ &&  $key !~ /^[0-9A-F]*:/i) { $monthhostsknown++; }
			$keysinkeylist{$key}=1;
			my $page=$_host_p{$key}||0;
			my $bytes=$_host_k{$key}||0;
			my $timehostl=$_host_l{$key}||0;
			my $timehosts=$_host_s{$key}||0;
			my $lastpage=$_host_u{$key}||'';
			if ($timehostl && $timehosts && $lastpage) {
				if (($timehostl+$VISITTIMEOUT) < $LastLine) {
					# Session for this user is expired
					if ($timehosts) { $_session{GetSessionRange($timehosts,$timehostl)}++; }
					if ($lastpage) { $_url_x{$lastpage}++; }
					delete $_host_s{$key};
					delete $_host_u{$key};
					print HISTORYTMP "$key $page $_host_h{$key} $bytes $timehostl\n";
				}
				else {
					# If this user has started a new session that is not expired
					print HISTORYTMP "$key $page $_host_h{$key} $bytes $timehostl $timehosts $lastpage\n";
				}
			}
			else {
				my $hostl=$timehostl||'';
				print HISTORYTMP "$key $page $_host_h{$key} $bytes $hostl\n";
			}
		}
		foreach my $key (keys %_host_h) {
			if ($keysinkeylist{$key}) { next; }
			if ($key !~ /^\d+\.\d+\.\d+\.\d+$/ && $key !~ /^[0-9A-F]*:/i) { $monthhostsknown++; }
			my $page=$_host_p{$key}||0;
			my $bytes=$_host_k{$key}||0;
			my $timehostl=$_host_l{$key}||0;
			my $timehosts=$_host_s{$key}||0;
			my $lastpage=$_host_u{$key}||'';
			if ($timehostl && $timehosts && $lastpage) {
				if (($timehostl+$VISITTIMEOUT) < $LastLine) {
					# Session for this user is expired
					if ($timehosts) { $_session{GetSessionRange($timehosts,$timehostl)}++; }
					if ($lastpage) { $_url_x{$lastpage}++; }
					delete $_host_s{$key};
					delete $_host_u{$key};
					print HISTORYTMP "$key $page $_host_h{$key} $bytes $timehostl\n";
				}
				else {
					# If this user has started a new session that is not expired
					print HISTORYTMP "$key $page $_host_h{$key} $bytes $timehostl $timehosts $lastpage\n";
				}
			}
			else {
				my $hostl=$timehostl||'';
				print HISTORYTMP "$key $page $_host_h{$key} $bytes $hostl\n";
			}
		}
		$MonthUnique{$year.$month}=(scalar keys %_host_p);
		$MonthHostsKnown{$year.$month}=$monthhostsknown;
		$MonthHostsUnknown{$year.$month}=(scalar keys %_host_h) - $monthhostsknown;
		print HISTORYTMP "END_VISITOR\n";
	}
	if ($sectiontosave eq 'login') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Login - Pages - Hits - Bandwidth - Last visit\n";
		print HISTORYTMP "# The $MaxNbOf{'LoginShown'} first Pages must be first (order not required for others)\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_LOGIN ".(scalar keys %_login_h)."\n";
		# We save login list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList($MaxNbOf{'LoginShown'},$MinHit{'Login'},\%_login_h,\%_login_p);
		my %keysinkeylist=();
		foreach my $key (@keylist) {
			$keysinkeylist{$key}=1;
			print HISTORYTMP "$key ".int($_login_p{$key}||0)." ".int($_login_h{$key}||0)." ".int($_login_k{$key}||0)." ".($_login_l{$key}||'')."\n";
		}
		foreach my $key (keys %_login_h) {
			if ($keysinkeylist{$key}) { next; }
			print HISTORYTMP "$key ".int($_login_p{$key}||0)." ".int($_login_h{$key}||0)." ".int($_login_k{$key}||0)." ".($_login_l{$key}||'')."\n";
		}
		print HISTORYTMP "END_LOGIN\n";
	}
	if ($sectiontosave eq 'robot') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Robot ID - Hits - Bandwidth - Last visit\n";
		print HISTORYTMP "# The $MaxNbOf{'RobotShown'} first Hits must be first (order not required for others)\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_ROBOT ".(scalar keys %_robot_h)."\n";
		# We save robot list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList($MaxNbOf{'RobotShown'},$MinHit{'Robot'},\%_robot_h,\%_robot_h);
		my %keysinkeylist=();
		foreach my $key (@keylist) {
			$keysinkeylist{$key}=1;
			print HISTORYTMP "$key ".int($_robot_h{$key})." ".int($_robot_k{$key})." $_robot_l{$key}\n";
		}
		foreach my $key (keys %_robot_h) {
			if ($keysinkeylist{$key}) { next; }
			print HISTORYTMP "$key ".int($_robot_h{$key})." ".int($_robot_k{$key})." $_robot_l{$key}\n";
		}
		print HISTORYTMP "END_ROBOT\n";
	}
	if ($sectiontosave eq 'worms') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Worm ID - Hits - Last visit\n";
		print HISTORYTMP "# The $MaxNbOf{'WormsShown'} first Hits must be first (order not required for others)\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_WORMS ".(scalar keys %_worm_h)."\n";
		# We save robot list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList($MaxNbOf{'WormsShown'},$MinHit{'Worm'},\%_worm_h,\%_worm_h);
		my %keysinkeylist=();
		foreach my $key (@keylist) {
			$keysinkeylist{$key}=1;
			print HISTORYTMP "$key ".int($_worm_h{$key})." $_worm_l{$key}\n";
		}
		foreach my $key (keys %_worm_h) {
			if ($keysinkeylist{$key}) { next; }
			print HISTORYTMP "$key ".int($_worm_h{$key})." $_worm_l{$key}\n";
		}
		print HISTORYTMP "END_WORMS\n";
	}
	if ($sectiontosave eq 'emailsender') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# EMail - Hits - Bandwidth - Last visit\n";
		print HISTORYTMP "# The $MaxNbOf{'EMailsShown'} first Hits must be first (order not required for others)\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_EMAILSENDER ".(scalar keys %_emails_h)."\n";
		# We save sender email list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList($MaxNbOf{'EMailsShown'},$MinHit{'EMail'},\%_emails_h,\%_emails_h);
		my %keysinkeylist=();
		foreach my $key (@keylist) {
			$keysinkeylist{$key}=1;
			print HISTORYTMP "$key ".int($_emails_h{$key})." ".int($_emails_k{$key})." $_emails_l{$key}\n";
		}
		foreach my $key (keys %_emails_h) {
			if ($keysinkeylist{$key}) { next; }
			print HISTORYTMP "$key ".int($_emails_h{$key})." ".int($_emails_k{$key})." $_emails_l{$key}\n";
		}
		print HISTORYTMP "END_EMAILSENDER\n";
	}
	if ($sectiontosave eq 'emailreceiver') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# EMail - Hits - Bandwidth - Last visit\n";
		print HISTORYTMP "# The $MaxNbOf{'EMailsShown'} first hits must be first (order not required for others)\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_EMAILRECEIVER ".(scalar keys %_emailr_h)."\n";
		# We save receiver email list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList($MaxNbOf{'EMailsShown'},$MinHit{'EMail'},\%_emailr_h,\%_emailr_h);
		my %keysinkeylist=();
		foreach my $key (@keylist) {
			$keysinkeylist{$key}=1;
			print HISTORYTMP "$key ".int($_emailr_h{$key})." ".int($_emailr_k{$key})." $_emailr_l{$key}\n";
		}
		foreach my $key (keys %_emailr_h) {
			if ($keysinkeylist{$key}) { next; }
			print HISTORYTMP "$key ".int($_emailr_h{$key})." ".int($_emailr_k{$key})." $_emailr_l{$key}\n";
		}
		print HISTORYTMP "END_EMAILRECEIVER\n";
	}

	# Navigation
	if ($sectiontosave eq 'session') {	# This section must be saved after VISITOR section is read
		print HISTORYTMP "\n";
		print HISTORYTMP "# Session range - Number of visits\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_SESSION ".(scalar keys %_session)."\n";
		foreach my $key (keys %_session) { print HISTORYTMP "$key ".int($_session{$key})."\n"; }
		print HISTORYTMP "END_SESSION\n";
	}
	if ($sectiontosave eq 'sider') {	# This section must be saved after VISITOR section is read
		print HISTORYTMP "\n";
		print HISTORYTMP "# URL - Pages - Bandwidth - Entry - Exit\n";
		print HISTORYTMP "# The $MaxNbOf{'PageShown'} first Pages must be first (order not required for others)\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_SIDER ".(scalar keys %_url_p)."\n";
		# We save page list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList($MaxNbOf{'PageShown'},$MinHit{'File'},\%_url_p,\%_url_p);
		%keysinkeylist=();
		foreach my $key (@keylist) {
			$keysinkeylist{$key}=1;
			my $newkey=$key;
			$newkey =~ s/([^:])\/\//$1\//g;		# Because some targeted url were taped with 2 / (Ex: //rep//file.htm). We must keep http://rep/file.htm
			print HISTORYTMP "$newkey ".int($_url_p{$key}||0)." ".int($_url_k{$key}||0)." ".int($_url_e{$key}||0)." ".int($_url_x{$key}||0)."\n";
		}
		foreach my $key (keys %_url_p) {
			if ($keysinkeylist{$key}) { next; }
			my $newkey=$key;
			$newkey =~ s/([^:])\/\//$1\//g;		# Because some targeted url were taped with 2 / (Ex: //rep//file.htm). We must keep http://rep/file.htm
			print HISTORYTMP "$newkey ".int($_url_p{$key}||0)." ".int($_url_k{$key}||0)." ".int($_url_e{$key}||0)." ".int($_url_x{$key}||0)."\n";
		}
		print HISTORYTMP "END_SIDER\n";
	}
	if ($sectiontosave eq 'filetypes') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Files type - Hits - Bandwidth - Bandwidth without compression - Bandwidth after compression\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_FILETYPES ".(scalar keys %_filetypes_h)."\n";
		foreach my $key (keys %_filetypes_h) {
			my $hits=$_filetypes_h{$key}||0;
			my $bytes=$_filetypes_k{$key}||0;
			my $bytesbefore=$_filetypes_gz_in{$key}||0;
			my $bytesafter=$_filetypes_gz_out{$key}||0;
			print HISTORYTMP "$key $hits $bytes $bytesbefore $bytesafter\n";
		}
		print HISTORYTMP "END_FILETYPES\n";
	}
	if ($sectiontosave eq 'os') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# OS ID - Hits\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_OS ".(scalar keys %_os_h)."\n";
		foreach my $key (keys %_os_h) { print HISTORYTMP "$key $_os_h{$key}\n"; }
		print HISTORYTMP "END_OS\n";
	}
	if ($sectiontosave eq 'browser') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Browser ID - Hits\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_BROWSER ".(scalar keys %_browser_h)."\n";
		foreach my $key (keys %_browser_h) { print HISTORYTMP "$key $_browser_h{$key}\n"; }
		print HISTORYTMP "END_BROWSER\n";
	}
	if ($sectiontosave eq 'screensize') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Screen size - Hits\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_SCREENSIZE ".(scalar keys %_screensize_h)."\n";
		foreach my $key (keys %_screensize_h) { print HISTORYTMP "$key $_screensize_h{$key}\n"; }
		print HISTORYTMP "END_SCREENSIZE\n";
	}

	# Referer
	if ($sectiontosave eq 'unknownreferer') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Unknown referer OS - Last visit date\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_UNKNOWNREFERER ".(scalar keys %_unknownreferer_l)."\n";
		foreach my $key (keys %_unknownreferer_l) { print HISTORYTMP "$key $_unknownreferer_l{$key}\n"; }
		print HISTORYTMP "END_UNKNOWNREFERER\n";
	}
	if ($sectiontosave eq 'unknownrefererbrowser') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Unknown referer Browser - Last visit date\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_UNKNOWNREFERERBROWSER ".(scalar keys %_unknownrefererbrowser_l)."\n";
		foreach my $key (keys %_unknownrefererbrowser_l) { print HISTORYTMP "$key $_unknownrefererbrowser_l{$key}\n"; }
		print HISTORYTMP "END_UNKNOWNREFERERBROWSER\n";
	}
	if ($sectiontosave eq 'origin') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Origin - Pages - Hits \n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_ORIGIN 6\n";
		print HISTORYTMP "From0 ".int($_from_p[0])." ".int($_from_h[0])."\n";
		print HISTORYTMP "From1 ".int($_from_p[1])." ".int($_from_h[1])."\n";
		print HISTORYTMP "From2 ".int($_from_p[2])." ".int($_from_h[2])."\n";
		print HISTORYTMP "From3 ".int($_from_p[3])." ".int($_from_h[3])."\n";
		print HISTORYTMP "From4 ".int($_from_p[4])." ".int($_from_h[4])."\n";		# Same site
		print HISTORYTMP "From5 ".int($_from_p[5])." ".int($_from_h[5])."\n";		# News
		print HISTORYTMP "END_ORIGIN\n";
	}
	if ($sectiontosave eq 'sereferrals') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Search engine referers ID - Pages - Hits\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_SEREFERRALS ".(scalar keys %_se_referrals_h)."\n";
		foreach my $key (keys %_se_referrals_h) { print HISTORYTMP "$key ".int($_se_referrals_p{$key}||0)." $_se_referrals_h{$key}\n"; }
		print HISTORYTMP "END_SEREFERRALS\n";
	}
	if ($sectiontosave eq 'pagerefs') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# External page referers - Pages - Hits\n";
		print HISTORYTMP "# The $MaxNbOf{'RefererShown'} first Pages must be first (order not required for others)\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_PAGEREFS ".(scalar keys %_pagesrefs_h)."\n";
		# We save page list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList($MaxNbOf{'RefererShown'},$MinHit{'Refer'},\%_pagesrefs_h,\%_pagesrefs_p);
		%keysinkeylist=();
		foreach my $key (@keylist) {
			$keysinkeylist{$key}=1;
			my $newkey=$key;
			$newkey =~ s/^http(s|):\/\/([^\/]+)\/$/http$1:\/\/$2/i;	# Remove / at end of http://.../ but not at end of http://.../dir/
			$newkey =~ s/\s/%20/g;
			print HISTORYTMP "$newkey ".int($_pagesrefs_p{$key}||0)." $_pagesrefs_h{$key}\n";
		}
		foreach my $key (keys %_pagesrefs_h) {
			if ($keysinkeylist{$key}) { next; }
			my $newkey=$key;
			$newkey =~ s/^http(s|):\/\/([^\/]+)\/$/http$1:\/\/$2/i;	# Remove / at end of http://.../ but not at end of http://.../dir/
			$newkey =~ s/\s/%20/g;
			print HISTORYTMP "$newkey ".int($_pagesrefs_p{$key}||0)." $_pagesrefs_h{$key}\n";
		}
		print HISTORYTMP "END_PAGEREFS\n";
	}
	if ($sectiontosave eq 'searchwords') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Search keyphrases - Number of search\n";
		print HISTORYTMP "# The $MaxNbOf{'KeyphrasesShown'} first number of search must be first (order not required for others)\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_SEARCHWORDS ".(scalar keys %_keyphrases)."\n";
		# We will also build _keywords
		%_keywords=();
		# We save key list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList($MaxNbOf{'KeywordsShown'},$MinHit{'Keyword'},\%_keyphrases,\%_keyphrases);
		%keysinkeylist=();
		foreach my $key (@keylist) {
			$keysinkeylist{$key}=1;
			my $keyphrase=$key;
			print HISTORYTMP "$keyphrase $_keyphrases{$key}\n";
			foreach my $word (split(/\+/,$key)) { $_keywords{$word}+=$_keyphrases{$key}; }	# To init %_keywords
		}
		foreach my $key (keys %_keyphrases) {
			if ($keysinkeylist{$key}) { next; }
			my $keyphrase=$key;
			print HISTORYTMP "$keyphrase $_keyphrases{$key}\n";
			foreach my $word (split(/\+/,$key)) { $_keywords{$word}+=$_keyphrases{$key}; }	# To init %_keywords
		}
		print HISTORYTMP "END_SEARCHWORDS\n";
		# Now save keywords section
		print HISTORYTMP "\n";
		print HISTORYTMP "# Search keywords - Number of search\n";
		print HISTORYTMP "# The $MaxNbOf{'KeywordsShown'} first number of search must be first (order not required for others)\n";
		$ValueInFile{"keywords"}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_KEYWORDS ".(scalar keys %_keywords)."\n";
		# We save key list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList($MaxNbOf{'KeywordsShown'},$MinHit{'Keyword'},\%_keywords,\%_keywords);
		%keysinkeylist=();
		foreach my $key (@keylist) {
			$keysinkeylist{$key}=1;
			my $keyword=$key;
			print HISTORYTMP "$keyword $_keywords{$key}\n";
		}
		foreach my $key (keys %_keywords) {
			if ($keysinkeylist{$key}) { next; }
			my $keyword=$key;
			print HISTORYTMP "$keyword $_keywords{$key}\n";
		}
		print HISTORYTMP "END_KEYWORDS\n";
	}

	# Other - Errors
	if ($sectiontosave eq 'errors') {
		print HISTORYTMP "\n";
		print HISTORYTMP "# Errors - Hits - Bandwidth\n";
		$ValueInFile{$sectiontosave}=tell HISTORYTMP;
		print HISTORYTMP "BEGIN_ERRORS ".(scalar keys %_errors_h)."\n";
		foreach my $key (keys %_errors_h) { print HISTORYTMP "$key $_errors_h{$key} ".int($_errors_k{$key}||0)."\n"; }
		print HISTORYTMP "END_ERRORS\n";
	}
 	# Other - Trapped errors
	foreach my $code (keys %TrapInfosForHTTPErrorCodes) {
		if ($sectiontosave eq "sider_$code") {
			print HISTORYTMP "\n";
			print HISTORYTMP "# URL with $code errors - Hits - Last URL referer\n";
			$ValueInFile{$sectiontosave}=tell HISTORYTMP;
			print HISTORYTMP "BEGIN_SIDER_$code ".(scalar keys %_sider404_h)."\n";
			foreach my $key (keys %_sider404_h) {
				my $newkey=$key;
				my $newreferer=$_referer404_h{$key}||''; $newreferer =~ s/\s/%20/g;
				print HISTORYTMP "$newkey $_sider404_h{$key} $newreferer\n";
			}
			print HISTORYTMP "END_SIDER_$code\n";
		}
	}
 	# Other - Extra stats sections
 	foreach my $extranum (1..@ExtraName-1) {
		if ($sectiontosave eq "extra_$extranum") {
			print HISTORYTMP "\n";
			print HISTORYTMP "# Extra sections...\n";
			$ValueInFile{$sectiontosave}=tell HISTORYTMP;
	 		print HISTORYTMP "BEGIN_EXTRA_$extranum\n";
	 		&BuildKeyList($MaxNbOfExtra[$extranum],$MinHitExtra[$extranum],\%{'_section_' . $extranum . '_h'},\%{'_section_' . $extranum . '_p'});
	 		%keysinkeylist=();
	 		foreach my $key (@keylist) {
	 			$keysinkeylist{$key}=1;
	 			my $page=${'_section_' . $extranum . '_p'}{$key}||0;
	 			my $bytes=${'_section_' . $extranum . '_k'}{$key}||0;
	 			my $lastaccess=${'_section_' . $extranum . '_l'}{$key}||'';
	 			print HISTORYTMP "$key $page ", ${'_section_' . $extranum . '_h'}{$key}, " $bytes $lastaccess\n"; next;
	 		}
	 		foreach my $key (keys %{'_section_' . $extranum . '_h'}) {
	 			if ($keysinkeylist{$key}) { next; }
	 			my $page=${'_section_' . $extranum . '_p'}{$key}||0;
	 			my $bytes=${'_section_' . $extranum . '_k'}{$key}||0;
	 			my $lastaccess=${'_section_' . $extranum . '_l'}{$key}||'';
	 			print HISTORYTMP "$key $page ", ${'_section_' . $extranum . '_h'}{$key}, " $bytes $lastaccess\n"; next;
	 		}
	 		print HISTORYTMP "END_EXTRA_$extranum\n";
		}
 	}
	
	%keysinkeylist=();
}

#--------------------------------------------------------------------
# Function:     Rename all tmp history file into history
# Parameters:   None
# Input:        $DirData $PROG $FileSuffix
#               $KeepBackupOfHistoricFile $SaveDatabaseFilesWithPermissionsForEveryone
# Output:       None
# Return:       1 Ok, 0 at least one error (tmp files are removed)
#--------------------------------------------------------------------
sub Rename_All_Tmp_History()
{
	my $pid=$$;
	my $renameok=1;

	if ($Debug) { debug("Call to Rename_All_Tmp_History"); }

	opendir(DIR,"$DirData");
	foreach (grep /^$PROG(\d\d\d\d\d\d)$FileSuffix\.tmp\.$pid$/, sort readdir DIR) {
		/^$PROG(\d\d\d\d\d\d)$FileSuffix\.tmp\.$pid$/;
		if ($renameok) {	# No rename error yet
			if ($Debug) { debug(" Rename new tmp history file $PROG$1$FileSuffix.tmp.$$ into $PROG$1$FileSuffix.txt",1); }
			if (-s "$DirData/$PROG$1$FileSuffix.tmp.$$") {		# Rename tmp files if size > 0
				if ($KeepBackupOfHistoricFiles) {
					if (-s "$DirData/$PROG$1$FileSuffix.txt") {	# History file already exists. We backup it
						if ($Debug) { debug("  Make a backup of old history file into $PROG$1$FileSuffix.bak before",1); }
						#if (FileCopy("$DirData/$PROG$1$FileSuffix.txt","$DirData/$PROG$1$FileSuffix.bak")) {
						if (rename("$DirData/$PROG$1$FileSuffix.txt", "$DirData/$PROG$1$FileSuffix.bak")==0) {
							warning("Warning: Failed to make a backup of \"$DirData/$PROG$1$FileSuffix.txt\" into \"$DirData/$PROG$1$FileSuffix.bak\".");
						}
						if ($SaveDatabaseFilesWithPermissionsForEveryone) {
							chmod 0666,"$DirData/$PROG$1$FileSuffix.bak";
						}
					}
					else {
						if ($Debug) { debug("  No need to backup old history file",1); }
					}
				}
				if (rename("$DirData/$PROG$1$FileSuffix.tmp.$$", "$DirData/$PROG$1$FileSuffix.txt")==0) {
					$renameok=0;	# At least one error in renaming working files
					# Remove tmp file
					unlink "$DirData/$PROG$1$FileSuffix.tmp.$$";
					warning("Warning: Failed to rename \"$DirData/$PROG$1$FileSuffix.tmp.$$\" into \"$DirData/$PROG$1$FileSuffix.txt\".\nWrite permissions on \"$PROG$1$FileSuffix.txt\" might be wrong".($ENV{'GATEWAY_INTERFACE'}?" for an 'update from web'":"")." or file might be opened.");
					next;
				}
				if ($SaveDatabaseFilesWithPermissionsForEveryone) {
					chmod 0666,"$DirData/$PROG$1$FileSuffix.txt";
				}
			}
		}
		else {				# Because of rename error, we remove all remaining tmp files
			unlink "$DirData/$PROG$1$FileSuffix.tmp.$$";
		}
	}
	close DIR;
	return $renameok;
}

#------------------------------------------------------------------------------
# Function:     Load DNS cache file entries into a memory hash array
# Parameters:	Hash array ref to load into,
#               File name to load,
#				File suffix to use
#               Save to a second plugin file if not up to date
# Input:		None
# Output:		Hash array is loaded
# Return:		1 No DNS Cache file found, 0 OK
#------------------------------------------------------------------------------
sub Read_DNS_Cache {
	my $hashtoload=shift;
	my $dnscachefile=shift;
	my $filesuffix=shift;
	my $savetohash=shift;

	my $dnscacheext='';
	my $filetoload='';
	my $timetoload = time();

	if ($Debug) { debug("Call to Read_DNS_Cache [file=\"$dnscachefile\"]"); }
	if ($dnscachefile =~ s/(\.\w+)$//) { $dnscacheext=$1; }
	foreach my $dir ("$DirData",".","") {
		my $searchdir=$dir;
		if ($searchdir && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
		if (-f "${searchdir}$dnscachefile$filesuffix$dnscacheext") { $filetoload="${searchdir}$dnscachefile$filesuffix$dnscacheext"; }
		# Plugin call : Change filetoload
		if ($PluginsLoaded{'SearchFile'}{'hashfiles'}) { SearchFile_hashfiles($searchdir,$dnscachefile,$filesuffix,$dnscacheext,$filetoload); }
		if ($filetoload) { last; }	# We found a file to load
	}

	if (! $filetoload) {
		if ($Debug) { debug(" No DNS Cache file found"); }
		return 1;
	}

	# Plugin call : Load hashtoload
	if ($PluginsLoaded{'LoadCache'}{'hashfiles'}) { LoadCache_hashfiles($filetoload,$hashtoload); }
	if (! scalar keys %$hashtoload) {
		open(DNSFILE,"$filetoload") or error("Couldn't open DNS Cache file \"$filetoload\": $!");
		# This is the fastest way to load with regexp that I know
		%$hashtoload = map(/^\d{0,10}\s*([0-9A-F:\.]+)\s+([^\s]+)$/oi,<DNSFILE>);
		close DNSFILE;
		if ($savetohash) {
			# Plugin call : Save hash file (all records) with test if up to date to save
			if ($PluginsLoaded{'SaveHash'}{'hashfiles'}) { SaveHash_hashfiles($filetoload,$hashtoload,1,0); }
		}
	}
	if ($Debug) { debug(" Loaded ".(scalar keys %$hashtoload)." items from $filetoload in ".(time()-$timetoload)." seconds.",1); }
	return 0;
}

#------------------------------------------------------------------------------
# Function:     Save a memory hash array into a DNS cache file
# Parameters:	Hash array ref to save,
#               File name to save,
#				File suffix to use
# Input:		None
# Output:		None
# Return:		0 OK, 1 Error
#------------------------------------------------------------------------------
sub Save_DNS_Cache_File {
	my $hashtosave=shift;
	my $dnscachefile=shift;
	my $filesuffix=shift;

	my $dnscacheext='';
	my $filetosave='';
	my $timetosave = time();
	my $nbofelemtosave=$NBOFLASTUPDATELOOKUPTOSAVE;
	my $nbofelemsaved=0;

	if ($Debug) { debug("Call to Save_DNS_Cache_File [file=\"$dnscachefile\"]"); }
	if (! scalar keys %$hashtosave) {
		if ($Debug) { debug(" No data to save"); }
		return 0;
	}
	if ($dnscachefile =~ s/(\.\w+)$//) { $dnscacheext=$1; }
	$filetosave="$dnscachefile$filesuffix$dnscacheext";
	# Plugin call : Save hash file (only $NBOFLASTUPDATELOOKUPTOSAVE records) with no test if up to date
	if ($PluginsLoaded{'SaveHash'}{'hashfiles'}) { SaveHash_hashfiles($filetosave,$hashtosave,0,$nbofelemtosave,$nbofelemsaved); }
	if (! $nbofelemsaved) {
		$filetosave="$dnscachefile$filesuffix$dnscacheext";
		debug(" Save data ".($nbofelemtosave?"($nbofelemtosave records max)":"(all records)")." into file $filetosave");
		if (! open(DNSFILE,">$filetosave")) {
			warning("Warning: Failed to open for writing last update DNS Cache file \"$filetosave\": $!");
			return 1;
		}
		my $starttimemin=int($starttime/60);
		foreach my $key (keys %$hashtosave) {
			#if ($hashtosave->{$key} ne '*') {
				my $ipsolved=$hashtosave->{$key};
				print DNSFILE "$starttimemin\t$key\t".($ipsolved eq 'ip'?'*':$ipsolved)."\n";	# Change 'ip' to '*' for backward compatibility
				if (++$nbofelemsaved >= $NBOFLASTUPDATELOOKUPTOSAVE) { last; }
			#}
		}
		close DNSFILE;
		
		if ($SaveDatabaseFilesWithPermissionsForEveryone) {
			chmod 0666,"$filetosave";
		}

	}
	if ($Debug) { debug(" Saved $nbofelemsaved items into $filetosave in ".(time()-$timetosave)." seconds.",1); }
	return 0;
}

#------------------------------------------------------------------------------
# Function:     Return time elapsed since last call in miliseconds
# Parameters:	0|1 (0 reset counter, 1 no reset)
# Input:		None
# Output:		None
# Return:		Number of miliseconds elapsed since last call
#------------------------------------------------------------------------------
sub GetDelaySinceStart {
	if (shift) { $StartSeconds=0; }	# Reset chrono
	my ($newseconds, $newmicroseconds)=(time(),0);
	# Plugin call : Return seconds and milliseconds
	if ($PluginsLoaded{'GetTime'}{'timehires'}) { GetTime_timehires($newseconds, $newmicroseconds); }
	if (! $StartSeconds) { $StartSeconds=$newseconds; $StartMicroseconds=$newmicroseconds; }
	return (($newseconds-$StartSeconds)*1000+int(($newmicroseconds-$StartMicroseconds)/1000));
}

#------------------------------------------------------------------------------
# Function:     Reset all variables whose name start with _ because a new month start
# Parameters:	None
# Input:        $YearRequired All variables whose name start with _
# Output:       All variables whose name start with _
# Return:		None
#------------------------------------------------------------------------------
sub Init_HashArray {
	if ($Debug) { debug("Call to Init_HashArray"); }
	# Reset global hash arrays
	%FirstTime = %LastTime = ();
	%MonthVisits = %MonthUnique = ();
	%MonthPages = %MonthHits = %MonthBytes = ();
	%MonthHostsKnown = %MonthHostsUnknown = ();
	%DayPages = %DayHits = %DayBytes = %DayVisits = ();
	# Reset all arrays with name beginning by _
	for (my $ix=0; $ix<6; $ix++)  { $_from_p[$ix]=0; $_from_h[$ix]=0; }
	for (my $ix=0; $ix<24; $ix++) { $_time_h[$ix]=0; $_time_k[$ix]=0; $_time_p[$ix]=0; }
	# Reset all hash arrays with name beginning by _
	%_session = %_browser_h = %_domener_h = %_domener_k = %_domener_p = %_errors_h = %_errors_k = ();
	%_filetypes_h = %_filetypes_k = %_filetypes_gz_in = %_filetypes_gz_out = ();
	%_host_p = %_host_h = %_host_k = %_host_l = %_host_s = %_host_u = ();
	%_waithost_e = %_waithost_l = %_waithost_s = %_waithost_u = ();
	%_keyphrases = %_keywords = %_os_h = %_pagesrefs_p = %_pagesrefs_h = %_robot_h = %_robot_k = %_robot_l = ();
	%_worm_h = %_worm_l = %_login_p = %_login_h = %_login_k = %_login_l = %_screensize_h = ();
	%_se_referrals_p = %_se_referrals_h = %_sider404_h = %_referer404_h = %_url_p = %_url_k = %_url_e = %_url_x = ();
	%_unknownreferer_l = %_unknownrefererbrowser_l = ();
	%_emails_h = %_emails_k = %_emails_l = %_emailr_h = %_emailr_k = %_emailr_l = ();
 	for (my $ix=1; $ix < @ExtraName; $ix++) {
 		%{'_section_' . $ix . '_h'} = %{'_section_' . $ix . '_o'} = %{'_section_' . $ix . '_k'}	=
 		%{'_section_' . $ix . '_l'} = %{'_section_' . $ix . '_p'} = ();
 	}
}

#------------------------------------------------------------------------------
# Function:     Change word separators of a keyphrase string into space and
#               remove bad coded chars
# Parameters:	stringtodecode
# Input:        None
# Output:       None
# Return:		decodedstring
#------------------------------------------------------------------------------
sub ChangeWordSeparatorsIntoSpace {
	$_[0] =~ s/%1[03]/ /g;
	$_[0] =~ s/%2[02789abc]/ /ig;
	$_[0] =~ s/%3a/ /ig;
	$_[0] =~ tr/\+\'\(\)\"\*,:/        /s;								# "&" and "=" must not be in this list
}

#------------------------------------------------------------------------------
# Function:     Converts an UTF8 binary string
#------------------------------------------------------------------------------
sub Utf8_To_Ascii
{
	my $string = shift;
	my $format = $ENV{"UCFORMAT"}||('%lx');
	$string =~ s/([\xC0-\xDF])([\x80-\xBF])/sprintf ("%c", hex(sprintf($format,unpack("c",$1)<<6&0x07C0|unpack("c",$2)&0x003F)))/ge;
	$string =~ s/([\xE0-\xEF])([\x80-\xBF])([\x80-\xBF])/sprintf ("%c", hex(sprintf($format,unpack("c",$1)<<12&0xF000|unpack("c",$2)<<6&0x0FC0|unpack("c",$3)&0x003F)))/ge;
	$string =~ s/([\xF0-\xF7])([\x80-\xBF])([\x80-\xBF])([\x80-\xBF])/sprintf ("%c", hex(sprintf($format,unpack("c",$1)<<18&0x1C0000|unpack("c",$2)<<12&0x3F000|unpack("c",$3)<<6&0x0FC0|unpack("c",$4)&0x003F)))/ge;
	return $string;
}

#--------------------------------------------------------------------
# Function:     Encode a binary string into a non binary string
#--------------------------------------------------------------------
sub EncodeString
{
	my $string = shift;
#	use bytes;
	$string =~ s/([\x2B\x80-\xFF])/sprintf ("%%%2x", ord($1))/eg;
#	no bytes;
	$string =~ tr/ /+/s;
	return $string;
}

#--------------------------------------------------------------------
# Function:     Decode an only text string into a binary string
# Parameters:   stringtodecode
# Input:        None
# Output:       None
# Return:		decodedstring
#--------------------------------------------------------------------
sub DecodeEncodedString {
	my $stringtodecode=shift;
	$stringtodecode =~ tr/\+/ /s;
	$stringtodecode =~ s/%([A-F0-9][A-F0-9])/pack("C", hex($1))/ieg;
	return $stringtodecode;
}

#--------------------------------------------------------------------
# Function:     Clean a string of all HTML code to avoid 'Cross Site Scripting attacks'
# Parameters:   stringtodecode
# Input:        None
# Output:       None
# Return:		decodedstring
#--------------------------------------------------------------------
sub CleanFromCSSA {
	my $stringtoclean=shift;
	$stringtoclean =~ s/[<>].*$//;
	return $stringtoclean;
}

#--------------------------------------------------------------------
# Function:     Copy one file into another
# Parameters:   sourcefilename targetfilename
# Input:        None
# Output:       None
# Return:		0 if copy is ok, 1 else
#--------------------------------------------------------------------
sub FileCopy {
	my $filesource = shift;
	my $filetarget = shift;
	if ($Debug) { debug("FileCopy($filesource,$filetarget)",1); }
	open(FILESOURCE,"$filesource") || return 1;
	open(FILETARGET,">$filetarget") || return 1;
	# ...
	close(FILETARGET);
	close(FILESOURCE);
	if ($Debug) { debug(" File copied",1); }
	return 0;
}

#--------------------------------------------------------------------
# Function:     Show flags for other language translations
# Parameters:   Current languade id (en, fr, ...)
# Input:        None
# Output:       None
# Return:       None
#--------------------------------------------------------------------
sub Show_Flag_Links {
	my $CurrentLang = shift;

	# Build flags link
	my $NewLinkParams=$QueryString;
	my $NewLinkTarget='';
	if ($ENV{'GATEWAY_INTERFACE'}) {
		$NewLinkParams =~ s/(^|&)update(=\w*|$)//i;
		$NewLinkParams =~ s/(^|&)staticlinks(=\w*|$)//i;
		$NewLinkParams =~ s/(^|&)framename=[^&]*//i;
		$NewLinkParams =~ s/(^|&)lang=[^&]*//i;
		if ($FrameName eq 'mainright') { $NewLinkTarget=" target=\"_parent\""; }
		$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
		if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }
	}
	else {
		$NewLinkParams=($SiteConfig?"config=$SiteConfig&":"")."year=$YearRequired&month=$MonthRequired&";
	}
	if ($FrameName eq 'mainright') { $NewLinkParams.='framename=index&'; }

	foreach my $flag (split(/\s+/,$ShowFlagLinks)) {
		if ($flag ne $CurrentLang) {
			my %lngtitle=('en','English','fr','French','de','German','it','Italian','nl','Dutch','es','Spanish');
			my $lng=($lngtitle{$flag}?$lngtitle{$flag}:$flag);
			print "<a href=\"$AWScript?${NewLinkParams}lang=$flag\"$NewLinkTarget><img src=\"$DirIcons\/flags\/$flag.png\" height=14 border=0 alt=\"$lng\" title=\"$lng\"></a>&nbsp;\n";
		}
	}
}

#--------------------------------------------------------------------
# Function:		Format value in bytes in a string (Bytes, Kb, Mb, Gb)
# Parameters:   bytes (integer value or "0.00")
# Input:        None
# Output:       None
# Return:       "x.yz MB" or "x.yy KB" or "x Bytes" or "0"
#--------------------------------------------------------------------
sub Format_Bytes {
	my $bytes = shift||0;
	my $fudge = 1;
	# Do not use exp/log function to calculate 1024power, function make segfault on some unix/perl versions
	if ($bytes >= ($fudge << 30)) { return sprintf("%.2f", $bytes/1073741824)." $Message[110]"; }
	if ($bytes >= ($fudge << 20)) { return sprintf("%.2f", $bytes/1048576)." $Message[109]"; }
	if ($bytes >= ($fudge << 10)) { return sprintf("%.2f", $bytes/1024)." $Message[108]"; }
	if ($bytes < 0) { $bytes="?"; }
	return int($bytes).(int($bytes)?" $Message[119]":"");
}

#--------------------------------------------------------------------
# Function:		Format a date according to Message[78] (country date format)
# Parameters:   String date YYYYMMDDHHMMSS
#               Option 0=LastUpdate and LastTime date
#                      1=Arrays date except daymonthvalues
#                      2=daymonthvalues date (only year month and day)
# Input:        $Message[78]
# Output:       None
# Return:       Date with format defined by Message[78] and option
#--------------------------------------------------------------------
sub Format_Date {
	my $date=shift;
	my $option=shift||0;
	my $year=substr("$date",0,4);
	my $month=substr("$date",4,2);
	my $day=substr("$date",6,2);
	my $hour=substr("$date",8,2);
	my $min=substr("$date",10,2);
	my $sec=substr("$date",12,2);
	my $dateformat=$Message[78];
	if ($option == 2) {
		$dateformat =~ s/^[^ymd]+//g;
		$dateformat =~ s/[^ymd]+$//g;
	}
	$dateformat =~ s/yyyy/$year/g;
	$dateformat =~ s/yy/$year/g;
	$dateformat =~ s/mmm/$MonthLib{$month}/g;
	$dateformat =~ s/mm/$month/g;
	$dateformat =~ s/dd/$day/g;
	$dateformat =~ s/HH/$hour/g;
	$dateformat =~ s/MM/$min/g;
	$dateformat =~ s/SS/$sec/g;
	return "$dateformat";
}

#--------------------------------------------------------------------
# Function:     Write a HTML cell with a WhoIs link to parameter
# Parameters:   Key to used as WhoIs target
# Input:        $LinksToWhoIs $LinksToIPWhoIs
# Output:       None
# Return:       None
#--------------------------------------------------------------------
sub ShowWhoIsCell {
	my $keyurl=shift;
	my $keyforwhois;
	my $linkforwhois;
	if ($keyurl =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {	# IPv4 address
		$keyforwhois=$keyurl;
		$linkforwhois=2;
	}
	elsif ($keyurl =~ /^[0-9A-F]*:/i) {							# IPv6 address
		$keyforwhois=$keyurl;
		$linkforwhois=2;
	}
	else {	# Hostname
		$keyurl =~ /([-\w]+\.[-\w]+\.(au|uk|jp|nz))$/ or $keyurl =~ /([-\w]+\.[-\w]+)$/;
		$keyforwhois=$1;
		$linkforwhois=1;
	}
	print "<td>";
	if ($keyforwhois && $linkforwhois) { print "<a href=\"javascript:neww('$keyforwhois',$linkforwhois)\">?</a>"; }
	else { print "&nbsp;" }
	print "</td>";
}

#--------------------------------------------------------------------
# Function:     Return 1 if string contains only ascii chars
# Parameters:   string
# Input:        None
# Output:       None
# Return:       0 or 1
#--------------------------------------------------------------------
sub IsAscii {
	my $string=shift;
	if ($Debug) { debug("IsAscii($string)",5); }
	if ($string =~ /^[\w\+\-\/\\\.%,;:=\"\'&?!\s]+$/) {
		if ($Debug) { debug(" Yes",5); }
		return 1;		# Only alphanum chars (and _) or + - / \ . % , ; : = " ' & ? space \t
	}
	if ($Debug) { debug(" No",5); }
	return 0;
}

#--------------------------------------------------------------------
# Function:     Add a val from sorting tree
# Parameters:   keytoadd keyval [firstadd]
# Input:        None
# Output:       None
# Return:       None
#--------------------------------------------------------------------
sub AddInTree {
	my $keytoadd=shift;
	my $keyval=shift;
	my $firstadd=shift||0;
	if ($firstadd==1) {			# Val is the first one
		if ($Debug) { debug("  firstadd",4); }
		$val{$keyval}=$keytoadd;
		$lowerval=$keyval;
		if ($Debug) { debug("  lowerval=$lowerval, nb elem val=".(scalar keys %val).", nb elem egal=".(scalar keys %egal).".",4); }
		return;
	}
	if ($val{$keyval}) { 		# Val is already in tree
		if ($Debug) { debug("  val is already in tree",4); }
		$egal{$keytoadd}=$val{$keyval};
		$val{$keyval}=$keytoadd;
		if ($Debug) { debug("  lowerval=$lowerval, nb elem val=".(scalar keys %val).", nb elem egal=".(scalar keys %egal).".",4); }
		return;
	}
	if ($keyval <= $lowerval) {	# Val is a new one lower (should happens only when tree is not full)
		if ($Debug) { debug("  keytoadd val=$keyval is lower or equal to lowerval=$lowerval",4); }
		$val{$keyval}=$keytoadd;
		$nextval{$keyval}=$lowerval;
		$lowerval=$keyval;
		if ($Debug) { debug("  lowerval=$lowerval, nb elem val=".(scalar keys %val).", nb elem egal=".(scalar keys %egal).".",4); }
		return;
	}
	# Val is a new one higher
	if ($Debug) { debug("  keytoadd val=$keyval is higher than lowerval=$lowerval",4); }
	$val{$keyval}=$keytoadd;
	my $valcursor=$lowerval;	# valcursor is value just before keyval
	while ($nextval{$valcursor} && ($nextval{$valcursor} < $keyval)) { $valcursor=$nextval{$valcursor}; }
	if ($nextval{$valcursor}) {	# keyval is beetween valcursor and nextval{valcursor}
		$nextval{$keyval}=$nextval{$valcursor};
	}
	$nextval{$valcursor}=$keyval;
	if ($Debug) { debug("  lowerval=$lowerval, nb elem val=".(scalar keys %val).", nb elem egal=".(scalar keys %egal).".",4); }
}

#--------------------------------------------------------------------
# Function:     Remove a val from sorting tree
# Parameters:   None
# Input:        $lowerval %val %egal
# Output:       None
# Return:       None
#--------------------------------------------------------------------
sub Removelowerval {
	my $keytoremove=$val{$lowerval};	# This is lower key
	if ($Debug) { debug("   remove for lowerval=$lowerval: key=$keytoremove",4); }
	if ($egal{$keytoremove}) {
		$val{$lowerval}=$egal{$keytoremove};
		delete $egal{$keytoremove};
	}
	else {
		delete $val{$lowerval};
		$lowerval=$nextval{$lowerval};	# Set new lowerval
	}
	if ($Debug) { debug("   new lower value=$lowerval, val size=".(scalar keys %val).", egal size=".(scalar keys %egal),4); }
}

#--------------------------------------------------------------------
# Function:     Return the lower value between 2 but exclude value if 0
# Parameters:   Val1 and Val2
# Input:        None
# Output:       None
# Return:       min(Val1,Val2)
#--------------------------------------------------------------------
sub MinimumButNoZero {
	my ($val1,$val2)=@_;
	return ($val1&&($val1<$val2||!$val2)?$val1:$val2);
}

#--------------------------------------------------------------------
# Function:     Build @keylist array
# Parameters:   Size max for @keylist array,
#               Min value in hash for select,
#               Hash used for select,
#               Hash used for order
# Input:        None
# Output:       None
# Return:       @keylist response array
#--------------------------------------------------------------------
sub BuildKeyList {
	my $ArraySize=shift||error("System error. Call to BuildKeyList function with incorrect value for first param","","",1);
	my $MinValue=shift||error("System error. Call to BuildKeyList function with incorrect value for second param","","",1);
	my $hashforselect=shift;
	my $hashfororder=shift;
	if ($Debug) { debug(" BuildKeyList($ArraySize,$MinValue,$hashforselect with size=".(scalar keys %$hashforselect).",$hashfororder with size=".(scalar keys %$hashfororder).")",2); }
	delete $hashforselect->{0};delete $hashforselect->{''};		# Those is to protect from infinite loop when hash array has an incorrect null key
	my $count=0;
	$lowerval=0;	# Global because used in AddInTree and Removelowerval
	%val=(); %nextval=(); %egal=();
	foreach my $key (keys %$hashforselect) {
		if ($count < $ArraySize) {
			if ($hashforselect->{$key} >= $MinValue) {
				$count++;
				if ($Debug) { debug("  Add in tree entry $count : $key (value=".($hashfororder->{$key}||0).", tree not full)",4); }
				AddInTree($key,$hashfororder->{$key}||0,$count);
			}
			next;
		}
		if (($hashfororder->{$key}||0)<=$lowerval) {
			$count++;
			next;
		}
		$count++;
		if ($Debug) { debug("  Add in tree entry $count : $key (value=".($hashfororder->{$key}||0)." > lowerval=$lowerval)",4); }
		AddInTree($key,$hashfororder->{$key}||0);
		if ($Debug) { debug("  Removelower in tree",4); }
		Removelowerval();
	}

	# Build key list and sort it
	if ($Debug) { debug("  Build key list and sort it. lowerval=$lowerval, nb elem val=".(scalar keys %val).", nb elem egal=".(scalar keys %egal).".",2); }
	my %notsortedkeylist=();
	foreach my $key (values %val) {	$notsortedkeylist{$key}=1; }
	foreach my $key (values %egal) { $notsortedkeylist{$key}=1; }
	@keylist=();
	@keylist=(sort {($hashfororder->{$b}||0) <=> ($hashfororder->{$a}||0) } keys %notsortedkeylist);
	if ($Debug) { debug(" BuildKeyList End (keylist size=".(@keylist).")",2); }
	return;
}

#--------------------------------------------------------------------
# Function:     Lock or unlock update
# Parameters:   status (1 to lock, 0 to unlock)
# Input:        $DirLock (if status=0) $PROG $FileSuffix
# Output:       $DirLock (if status=1)
# Return:       None
#--------------------------------------------------------------------
sub Lock_Update {
	my $status=shift;
	my $lock="$PROG$FileSuffix.lock";
	if ($status) {
		# We stop if there is at least one lock file wherever it is
		foreach my $key ($ENV{"TEMP"},$ENV{"TMP"},"/tmp","/",".") {
			my $newkey =$key;
			$newkey =~ s/[\\\/]$//;
			if (-f "$newkey/$lock") { error("An AWStats update process seems to be already running for this config file. Try later.\nIf this is not true, remove manually lock file '$newkey/$lock'.","","",1); }
		}
		# Set lock where we can
		foreach my $key ($ENV{"TEMP"},$ENV{"TMP"},"/tmp","/",".") {
			if (! -d "$key") { next; }
			$DirLock=$key;
			$DirLock =~ s/[\\\/]$//;
			if ($Debug) { debug("Update lock file $DirLock/$lock is set"); }
			open(LOCK,">$DirLock/$lock") || error("Failed to create lock file $DirLock/$lock","","",1);
			print LOCK "AWStats update started by process $$ at $nowyear-$nowmonth-$nowday $nowhour:$nowmin:$nowsec\n";
			close(LOCK);
			last;
		}
	}
	else {
		# Remove lock
		if ($Debug) { debug("Update lock file $DirLock/$lock is removed"); }
		unlink("$DirLock/$lock");
	}
	return;
}

#--------------------------------------------------------------------
# Function:     Signal handler to call Lock_Update to remove lock file
# Parameters:   Signal name
# Input:        None
# Output:       None
# Return:       None
#--------------------------------------------------------------------
sub SigHandler {
	my $signame = shift;
	print ucfirst($PROG)." process (ID $$) interrupted by signal $signame.\n";
	&Lock_Update(0);
	exit 1;
}

#--------------------------------------------------------------------
# Function:     Convert an IPAddress into an integer
# Parameters:   IPAddress
# Input:        None
# Output:       None
# Return:       Int
#--------------------------------------------------------------------
sub Convert_IP_To_Decimal() {
	my ($IPAddress) = @_;
	my @ip_seg_arr = split(/\./,$IPAddress);
	my $decimal_ip_address = 256 * 256 *256 * $ip_seg_arr[0] + 256 * 256 * $ip_seg_arr[1] + 256 * $ip_seg_arr[2] + $ip_seg_arr[3];
	return($decimal_ip_address);
}

#--------------------------------------------------------------------
# Function:     Test there is at least on value in list not null
# Parameters:   List of values
# Input:        None
# Output:       None
# Return:       1 There is at least one not null value, 0 else
#--------------------------------------------------------------------
sub AtLeastOneNotNull() {
	debug(" Call to AtLeastOneNotNull (".join('-',@_).")",3);
	foreach my $val (@_) { if ($val) { return 1; } }
	return 0;
}

#--------------------------------------------------------------------
# Function:     Insert a form filter
# Parameters:   name of filter field, default value for filter field
# Input:        $StaticLinks, $QueryString
# Output:       HTML Form
# Return:       None
#--------------------------------------------------------------------
sub ShowFormFilter() {
	my $fieldfiltername=shift;
	my $fieldfiltervalue=shift;
	if (! $StaticLinks) {
		my $NewLinkParams=${QueryString};
		$NewLinkParams =~ s/(^|&)update(=\w*|$)//i;
		$NewLinkParams =~ s/(^|&)output(=\w*|$)//i;
		$NewLinkParams =~ s/(^|&)staticlinks(=\w*|$)//i;
		$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
		if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }
		print "\n<FORM name=\"FormFilter\" action=\"$AWScript?${NewLinkParams}\" class=\"TABLEFRAME\">\n";
		print "<TABLE valign=middle><TR>\n";
		print "<TD>&nbsp; &nbsp; $Message[79] : &nbsp; &nbsp;\n";
		print "<input type=hidden name=\"output\" value=\"".join(',',keys %HTMLOutput)."\">\n";
		if ($SiteConfig) { print "<input type=hidden name=\"config\" value=\"$SiteConfig\">\n"; }
		if ($QueryString =~ /(^|&)year=(\d\d\d\d)/i) { print "<input type=hidden name=\"year\" value=\"$2\">\n"; }
		if ($QueryString =~ /(^|&)month=(\d\d)/i || $QueryString =~ /(^|&)month=(all)/i) { print "<input type=hidden name=\"month\" value=\"$2\">\n"; }
		if ($QueryString =~ /(^|&)lang=(\w+)/i) { print "<input type=hidden name=\"lang\" value=\"$2\">\n"; }
		if ($QueryString =~ /(^|&)debug=(\d+)/i) { print "<input type=hidden name=\"debug\" value=\"$2\">\n"; }
		if ($QueryString =~ /(^|&)framename=(\w+)/i) { print "<input type=hidden name=\"framename\" value=\"$2\">\n"; }
		print "</TD>\n";
		print "<TD><input type=text name=\"$fieldfiltername\" value=\"$fieldfiltervalue\" class=\"CFormFields\"></TD>\n";
		print "<TD><input type=submit value=\"$Message[115]\" class=\"CFormFields\">\n";
		print "</TR></TABLE>\n";
		print "</FORM>\n\n";
	}
}

#--------------------------------------------------------------------
# Function:     Write URL with HTML link or not
# Parameters:   $url
# Input:        %Aliases $MaxLengthOfURL $ShowLinksOnUrl $SiteDomain $UseHTTPSLinkForUrl
# Output:       URL link
# Return:       None
#--------------------------------------------------------------------
sub ShowURL() {
	my $url=shift;
	my $nompage=CleanFromCSSA($url);

	# Call to plugins' function ReplaceURL
	foreach my $pluginname (keys %{$PluginsLoaded{'ReplaceURL'}})  {
		my $function="ReplaceURL_$pluginname('$url')";
		eval("$function");
	}

	if (length($nompage)>$MaxLengthOfURL) { $nompage=substr($nompage,0,$MaxLengthOfURL)."..."; }
	if ($ShowLinksOnUrl) {
		my $newkey=CleanFromCSSA($url);
		if ($newkey =~ /^http(s|):/i) {	# URL seems to be extracted from a ftp or proxy log file
			print "<A HREF=\"$newkey\" target=\"url\">$nompage</A>";
		}
		elsif ($newkey =~ /^\//) {		# URL seems to be an url extracted from a web or wap server log file
			$newkey =~ s/^\/$SiteDomain//;
			# Define http or https
			my $httplink='http';
			if ($UseHTTPSLinkForUrl && $newkey =~ /^$UseHTTPSLinkForUrl/) { $httplink='https'; }
			print "<A HREF=\"$httplink://$SiteDomain$newkey\" target=\"url\">$nompage</A>";
		}
		else {
			print "$nompage";
		}
	}
	else {
		print "$nompage";
	}
}

#--------------------------------------------------------------------
# Function:     Define value for PerlParsingFormat (used for regex log record parsing)
# Parameters:   -
# Input:        $LogFormat
# Output:       @fieldlib
# Return:       -
#--------------------------------------------------------------------
sub DefinePerlParsingFormat() {
	# Log records examples:
	# Apache combined: 62.161.78.73 user - [dd/mmm/yyyy:hh:mm:ss +0000] "GET / HTTP/1.1" 200 1234 "http://www.from.com/from.htm" "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"
	# Apache combined (408 error): my.domain.com - user [09/Jan/2001:11:38:51 -0600] "OPTIONS /mime-tmp/xxx file.doc HTTP/1.1" 408 - "-" "-"
	# Apache combined (408 error): 62.161.78.73 user - [dd/mmm/yyyy:hh:mm:ss +0000] "-" 408 - "-" "-"
	# Apache common_with_mod_gzip_info1: %h %l %u %t \"%r\" %>s %b mod_gzip: %{mod_gzip_compression_ratio}npct.
	# Apache common_with_mod_gzip_info2: %h %l %u %t \"%r\" %>s %b mod_gzip: %{mod_gzip_result}n In:%{mod_gzip_input_size}n Out:%{mod_gzip_output_size}n:%{mod_gzip_compression_ratio}npct.
	# IIS: 2000-07-19 14:14:14 62.161.78.73 - GET / 200 1234 HTTP/1.1 Mozilla/4.0+(compatible;+MSIE+5.01;+Windows+NT+5.0) http://www.from.com/from.htm
	# WebStar: 05/21/00	00:17:31	OK  	200	212.242.30.6	Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)	http://www.cover.dk/	"www.cover.dk"	:Documentation:graphics:starninelogo.white.gif	1133
	# Squid extended: 12.229.91.170 - - [27/Jun/2002:03:30:50 -0700] "GET http://www.callistocms.com/images/printable.gif HTTP/1.1" 304 354 "-" "Mozilla/5.0 Galeon/1.0.3 (X11; Linux i686; U;) Gecko/0" TCP_REFRESH_HIT:DIRECT
	if ($Debug) { debug("Call To DefinePerlParsingFormat"); }
	if ($Debug) { debug(" LogFormat=$LogFormat"); }
	@fieldlib=();
	if ($LogFormat =~ /^[1-6]$/) {	# Pre-defined log format
		if ($LogFormat eq '1' || $LogFormat eq '6') {	# Same than "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"".
			# %u (user) is "(.+)" instead of "[^ ]+" because can contain space (Lotus Notes). referer and ua might be "".
			$PerlParsingFormat="([^ ]+) [^ ]+ ([^\\[]+) \\[([^ ]+) [^ ]+\\] \\\"([^ ]+) ([^ ]+) [^\\\"]+\\\" ([\\d|-]+) ([\\d|-]+) \\\"(.*)\\\" \\\"([^\\\"]*)\\\"";
			$pos_host=0;$pos_logname=1;$pos_date=2;$pos_method=3;$pos_url=4;$pos_code=5;$pos_size=6;$pos_referer=7;$pos_agent=8;
			@fieldlib=('host','logname','date','method','url','code','size','referer','ua');
		}
		elsif ($LogFormat eq '2') {	# Same than "date time c-ip cs-username cs-method cs-uri-stem sc-status sc-bytes cs-version cs(User-Agent) cs(Referer)"
			$PerlParsingFormat="(\\S+ \\S+) (\\S+) (\\S+) (\\S+) (\\S+) ([\\d|-]+) ([\\d|-]+) \\S+ (\\S+) (\\S+)";
			$pos_date=0;$pos_host=1;$pos_logname=2;$pos_method=3;$pos_url=4;$pos_code=5;$pos_size=6;$pos_agent=7;$pos_referer=8;
			@fieldlib=('date','host','logname','method','url','code','size','ua','referer');
		}
		elsif ($LogFormat eq '3') {
			$PerlParsingFormat="([^\\t]*\\t[^\\t]*)\\t([^\\t]*)\\t([\\d]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t[^\\t]*\\t.*:([^\\t]*)\\t([\\d]*)";
			$pos_date=0;$pos_method=1;$pos_code=2;$pos_host=3;$pos_agent=4;$pos_referer=5;$pos_url=6;$pos_size=7;
			@fieldlib=('date','method','code','host','ua','referer','url','size');
		}
		elsif ($LogFormat eq '4') {	# Same than "%h %l %u %t \"%r\" %>s %b"
			# %u (user) is "(.+)" instead of "[^ ]+" because can contain space (Lotus Notes).
			$PerlParsingFormat="([^ ]+) [^ ]+ (.+) \\[([^ ]+) [^ ]+\\] \\\"([^ ]+) ([^ ]+) [^\\\"]+\\\" ([\\d|-]+) ([\\d|-]+)";
			$pos_host=0;$pos_logname=1;$pos_date=2;$pos_method=3;$pos_url=4;$pos_code=5;$pos_size=6;
			@fieldlib=('host','logname','date','method','url','code','size');
		}
		# This is a deprecated option, will be removed in a next version.
		elsif ($LogFormat eq '5') {	# Same than "c-ip cs-username c-agent sc-authenticated date time s-svcname s-computername cs-referred r-host r-ip r-port time-taken cs-bytes sc-bytes cs-protocol cs-transport s-operation cs-uri cs-mime-type s-object-source sc-status s-cache-info"
			$PerlParsingFormat="([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t[^\\t]*\\t([^\\t]*\\t[^\\t]*)\\t[^\\t]*\\t[^\\t]*\\t([^\\t]*)\\t[^\\t]*\\t[^\\t]*\\t[^\\t]*\\t[^\\t]*\\t[^\\t]*\\t([^\\t]*)\\t[^\\t]*\\t[^\\t]*\\t([^\\t]*)\\t([^\\t]*)\\t[^\\t]*\\t[^\\t]*\\t([^\\t]*)\\t[^\\t]*";
			$pos_host=0;$pos_logname=1;$pos_agent=2;$pos_date=3;$pos_referer=4;$pos_size=5;$pos_method=6;$pos_url=7;$pos_code=8;
			@fieldlib=('host','logname','ua','date','referer','size','method','url','code');
		}
	}
	else {							# Personalized log format
		my $LogFormatString=$LogFormat;
		# Replacement for Apache format string
		$LogFormatString =~ s/%v(\s)/%virtualname$1/g; $LogFormatString =~ s/%v$/%virtualname/g;
		$LogFormatString =~ s/%h(\s)/%host$1/g; $LogFormatString =~ s/%h$/%host/g;
		$LogFormatString =~ s/%l(\s)/%other$1/g; $LogFormatString =~ s/%l$/%other/g;
		$LogFormatString =~ s/%u(\s)/%logname$1/g; $LogFormatString =~ s/%u$/%logname/g;
		$LogFormatString =~ s/%t(\s)/%time1$1/g; $LogFormatString =~ s/%t$/%time1/g;
		$LogFormatString =~ s/\"%r\"/%methodurl/g;
		$LogFormatString =~ s/%>s/%code/g;
		$LogFormatString =~ s/%b(\s)/%bytesd$1/g;	$LogFormatString =~ s/%b$/%bytesd/g;
		$LogFormatString =~ s/\"%{Referer}i\"/%refererquot/g;
		$LogFormatString =~ s/\"%{User-Agent}i\"/%uaquot/g;
		$LogFormatString =~ s/%{mod_gzip_input_size}n/%gzipin/g;
		$LogFormatString =~ s/%{mod_gzip_output_size}n/%gzipout/g;
		$LogFormatString =~ s/%{mod_gzip_compression_ratio}n/%gzipratio/g;
		# Replacement for a IIS and ISA format string
		$LogFormatString =~ s/cs-uri-query/%query/g;	# Must be before cs-uri
		$LogFormatString =~ s/date\stime/%time2/g;
		$LogFormatString =~ s/c-ip/%host/g;
		$LogFormatString =~ s/cs-username/%logname/g;
		$LogFormatString =~ s/cs-method/%method/g;		# GET, POST, SMTP, RETR STOR
		$LogFormatString =~ s/cs-uri-stem/%url/g; $LogFormatString =~ s/cs-uri/%url/g;
		$LogFormatString =~ s/sc-status/%code/g;
		$LogFormatString =~ s/sc-bytes/%bytesd/g;
		$LogFormatString =~ s/cs-version/%other/g;		# Protocol
		$LogFormatString =~ s/cs\(User-Agent\)/%ua/g; $LogFormatString =~ s/c-agent/%ua/g;
		$LogFormatString =~ s/cs\(Referer\)/%referer/g; $LogFormatString =~ s/cs-referred/%referer/g;
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
		# Added for MMS
		$LogFormatString =~ s/protocol/%protocolmms/g;	# cs-method might not be available
		$LogFormatString =~ s/c-status/%codemms/g;		# sc-status not available
		if ($Debug) { debug(" LogFormatString=$LogFormatString"); }
		# Scan $LogFormatString to found all required fields and generate PerlParsingFormat
		my $i = 0;
		my $LogSeparatorWithoutStar=$LogSeparator; $LogSeparatorWithoutStar =~ s/[\*\+]//g;
		foreach my $f (split(/\s+/,$LogFormatString)) {
			# Add separator for next field
			if ($PerlParsingFormat) { $PerlParsingFormat.="$LogSeparator"; }
			if ($f =~ /%virtualname$/) {
				$pos_vh = $i; $i++; push @fieldlib, 'vhost';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%host_r$/) {
				$pos_hostr = $i; $i++; push @fieldlib, 'hostr';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%host$/) {
				$pos_host = $i; $i++; push @fieldlib, 'host';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%logname$/) {
				$pos_logname = $i; $i++; push @fieldlib, 'logname';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%time1b$/) {
				$pos_date = $i; $i++; push @fieldlib, 'date';
				$PerlParsingFormat .= "\\[([^$LogSeparatorWithoutStar]+)\\]";
			}
			elsif ($f =~ /%time1$/) {
				$pos_date = $i;	$i++; push @fieldlib, 'date';
				$PerlParsingFormat .= "\\[([^$LogSeparatorWithoutStar]+) [^$LogSeparatorWithoutStar]+\\]";
			}
			elsif ($f =~ /%time2$/) {
				$pos_date = $i;	$i++; push @fieldlib, 'date';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+\\s[^$LogSeparatorWithoutStar]+)";	# Need \s for Exchange log files
			}
			elsif ($f =~ /%methodurl$/) {
				$pos_method = $i; $i++; push @fieldlib, 'method';
				$pos_url = $i; $i++; push @fieldlib, 'url';
				$PerlParsingFormat .= "\\\"([^$LogSeparatorWithoutStar]+) ([^$LogSeparatorWithoutStar]+) [^\\\"]+\\\"";
			}
			elsif ($f =~ /%methodurlnoprot$/) {
				$pos_method = $i; $i++; push @fieldlib, 'method';
				$pos_url = $i; $i++; push @fieldlib, 'url';
				$PerlParsingFormat .= "\\\"([^$LogSeparatorWithoutStar]+) ([^$LogSeparatorWithoutStar]+)\\\"";
			}
			elsif ($f =~ /%method$/) {
				$pos_method = $i; $i++; push @fieldlib, 'method';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%protocolmms$/) {	# protocolmms is used for method if method not already found (for MMS)
				if ($pos_method < 0) {
					$pos_method = $i; $i++; push @fieldlib, 'method';
					$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
				}
			}
			elsif ($f =~ /%url$/) {
				$pos_url = $i; $i++; push @fieldlib, 'url';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%query$/) {
				$pos_query = $i; $i++; push @fieldlib, 'query';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%code$/) {
				$pos_code = $i; $i++; push @fieldlib, 'code';
				$PerlParsingFormat .= "([\\d|-]+)";
			}
			elsif ($f =~ /%codemms$/) {		# codemms is used for code if code not already found (for MMS)
				if ($pos_code < 0) {
					$pos_code = $i; $i++; push @fieldlib, 'code';
					$PerlParsingFormat .= "([\\d|-]+)";
				}
			}
			elsif ($f =~ /%bytesd$/) {
				$pos_size = $i; $i++; push @fieldlib, 'size';
				$PerlParsingFormat .= "([\\d|-]+)";
			}
			elsif ($f =~ /%refererquot$/) {
				$pos_referer = $i; $i++; push @fieldlib, 'referer';
				$PerlParsingFormat .= "\\\"(.*)\\\""; 		# referer might be ""
			}
			elsif ($f =~ /%referer$/) {
				$pos_referer = $i; $i++; push @fieldlib, 'referer';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%uaquot$/) {
				$pos_agent = $i; $i++; push @fieldlib, 'ua';
				$PerlParsingFormat .= "\\\"([^\\\"]*)\\\"";	# ua might be ""
			}
			elsif ($f =~ /%uabracket$/) {
				$pos_agent = $i; $i++; push @fieldlib, 'ua';
				$PerlParsingFormat .= "\\\[(.*)\\\]"; 		# ua might be []
			}
			elsif ($f =~ /%ua$/) {
				$pos_agent = $i; $i++; push @fieldlib, 'ua';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%gzipin$/ ) {
				$pos_gzipin=$i;$i++; push @fieldlib, 'gzipin';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%gzipout/ ) {		# Compare $f to /%gzipout/ and not to /%gzipout$/ like other fields
				$pos_gzipout=$i;$i++; push @fieldlib, 'gzipout';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%gzipratio/ ) {	# Compare $f to /%gzipratio/ and not to /%gzipratio$/ like other fields
				$pos_gzipratio=$i;$i++; push @fieldlib, 'gzipratio';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%syslog$/) {		# Added for syslog time and host stamp, fields are skipped and not analyzed
				$PerlParsingFormat .= "\\w\\w\\w \\d+ \\d\\d:\\d\\d:\\d\\d \\w+";
			}
			elsif ($f =~ /%email_r$/) {
				$pos_emailr = $i; $i++; push @fieldlib, 'email_r';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ($f =~ /%email$/) {
				$pos_emails = $i; $i++; push @fieldlib, 'email';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			else {
				$PerlParsingFormat .= "[^$LogSeparatorWithoutStar]+";
			}
		}
		if (! $PerlParsingFormat) { error("No recognized format tag in personalized LogFormat string"); }
	}
	if ($pos_host < 0) { error("Your personalized LogFormat does not include all fields required by AWStats (Add \%host in your LogFormat string)."); }
	if ($pos_date < 0) { error("Your personalized LogFormat does not include all fields required by AWStats (Add \%time1 or \%time2 in your LogFormat string)."); }
	if ($pos_method < 0) { error("Your personalized LogFormat does not include all fields required by AWStats (Add \%methodurl or \%method in your LogFormat string)."); }
	if ($pos_url < 0) { error("Your personalized LogFormat does not include all fields required by AWStats (Add \%methodurl or \%url in your LogFormat string)."); }
	if ($pos_code < 0) { error("Your personalized LogFormat does not include all fields required by AWStats (Add \%code in your LogFormat string)."); }
	if ($pos_size < 0) { error("Your personalized LogFormat does not include all fields required by AWStats (Add \%bytesd in your LogFormat string)."); }
	if ($Debug) { debug(" PerlParsingFormat is $PerlParsingFormat"); }
}



#--------------------------------------------------------------------
# MAIN
#--------------------------------------------------------------------
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

$starttime=time;

# Get current time (time when AWStats was started)
($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday,$nowyday) = localtime($starttime);
$nowweekofmonth=int($nowday/7);
$nowweekofyear=int(($nowyday-1+6-($nowwday==0?6:$nowwday-1))/7)+1; if ($nowweekofyear > 52) { $nowweekofyear = 1; }
$nowdaymod=$nowday%7;
$nowwday++;
$nowns=Time::Local::timelocal(0,0,0,$nowday,$nowmonth,$nowyear);
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
$nowtime=int($nowyear.$nowmonth.$nowday.$nowhour.$nowmin.$nowsec);
# Get tomorrow time (will be used to discard some record with corrupted date (future date))
my ($tomorrowsec,$tomorrowmin,$tomorrowhour,$tomorrowday,$tomorrowmonth,$tomorrowyear) = localtime($starttime+86400);
if ($tomorrowyear < 100) { $tomorrowyear+=2000; } else { $tomorrowyear+=1900; }
if (++$tomorrowmonth < 10) { $tomorrowmonth = "0$tomorrowmonth"; }
if ($tomorrowday < 10) { $tomorrowday = "0$tomorrowday"; }
if ($tomorrowhour < 10) { $tomorrowhour = "0$tomorrowhour"; }
if ($tomorrowmin < 10) { $tomorrowmin = "0$tomorrowmin"; }
if ($tomorrowsec < 10) { $tomorrowsec = "0$tomorrowsec"; }
$tomorrowtime=int($tomorrowyear.$tomorrowmonth.$tomorrowday.$tomorrowhour.$tomorrowmin.$tomorrowsec);

my @AllowedArgs=('-site','-config','-showsteps','-showdropped','-showcorrupted',
'-showunknownorigin','-logfile','-output','-staticlinks','-lang',
'-hostfilter','-urlfilter','-refererpagesfilter',
'-month','-year','-framename','-debug','-limitflush');

$QueryString='';
if ($ENV{'GATEWAY_INTERFACE'}) {	# Run from a browser
	print "Content-type: text/html\n";
	# Expires must be GMT ANSI asctime and must be after Content-type to avoid pb with some servers (SAMBAR)
	#my $ExpireDelayInHTTPHeader=0;
	#print "Expires: ".(gmtime($starttime()+$ExpireDelayInHTTPHeader))."\n";
	print "\n";

	# Prepare QueryString
	if ($ENV{'CONTENT_LENGTH'}) {
		binmode STDIN;
		read(STDIN, $QueryString, $ENV{'CONTENT_LENGTH'});
	}
	if ($ENV{'QUERY_STRING'}) { $QueryString = $ENV{'QUERY_STRING'}; }

	$QueryString = CleanFromCSSA($QueryString);
	# No update but report by default when run from a browser
	$UpdateStats=($QueryString=~/update=1/i?1:0);

	if ($QueryString =~ /config=([^&]+)/i)				{ $SiteConfig=&DecodeEncodedString("$1"); }
	if ($QueryString =~ /logfile=([^&]+)/i)				{ $LogFile=&DecodeEncodedString("$1"); }
	# All filters
	if ($QueryString =~ /hostfilter=([^&]+)/i)			{ $HostFilter=&DecodeEncodedString("$1"); }			# Filter on host list can also be defined with hostfilter=filter
	if ($QueryString =~ /urlfilter=([^&]+)/i)			{ $URLFilter=&DecodeEncodedString("$1"); }			# Filter on URL list can also be defined with urlfilter=filter
	if ($QueryString =~ /refererpagesfilter=([^&]+)/i)	{ $RefererPagesFilter=&DecodeEncodedString("$1"); }	# Filter on referer list can also be defined with refererpagesfilter=filter
	# All output
	if ($QueryString =~ /output=allhosts:([^&]+)/i)		{ $HostFilter=&DecodeEncodedString("$1"); }			# Filter on host list can be defined with output=allhosts:filter to reduce number of lines read and showed
	if ($QueryString =~ /output=lasthosts:([^&]+)/i)	{ $HostFilter=&DecodeEncodedString("$1"); }			# Filter on host list can be defined with output=lasthosts:filter to reduce number of lines read and showed
	if ($QueryString =~ /output=urldetail:([^&]+)/i)	{ $URLFilter=&DecodeEncodedString("$1"); }			# Filter on URL list can be defined with output=urldetail:filter to reduce number of lines read and showed
	if ($QueryString =~ /output=refererpages:([^&]+)/i)	{ $RefererPagesFilter=&DecodeEncodedString("$1"); }	# Filter on referer list can be defined with output=refererpages:filter to reduce number of lines read and showed

	# If migrate
	if ($QueryString =~ /(^|-|&)migrate=([^&]+)/i)	{
		$MigrateStats=&DecodeEncodedString("$2"); 
		$MigrateStats =~ /^(.*)$PROG(\d{0,2})(\d\d)(\d\d\d\d)(.*)\.txt$/;
		$SiteConfig=$5?$5:'xxx'; $SiteConfig =~ s/^\.//;		# SiteConfig is used to find config file
	}
}
else {								# Run from command line
	# Prepare QueryString
	for (0..@ARGV-1) {
		if ($ARGV[$_] =~ /(^|-|&)migrate=([^&]+)/i) {
			$MigrateStats="$2";
			$MigrateStats =~ /^(.*)$PROG(\d{0,2})(\d\d)(\d\d\d\d)(.*)\.txt$/;
			$SiteConfig=$5?$5:'xxx'; $SiteConfig =~ s/^\.//;	# SiteConfig is used to find config file
			next;
		}
		# TODO Check if ARGV is in @AllowedArg
		if ($QueryString) { $QueryString .= '&'; }
		my $NewLinkParams=$ARGV[$_]; $NewLinkParams =~ s/^-+//;
		$QueryString .= "$NewLinkParams";
	}

	$QueryString = CleanFromCSSA($QueryString);
	# Update with no report by default when run from command line
	$UpdateStats=1;

	if ($QueryString =~ /config=([^&]+)/i)				{ $SiteConfig="$1"; }
	if ($QueryString =~ /logfile=([^&]+)/i)				{ $LogFile="$1"; }
	# All filters
	if ($QueryString =~ /hostfilter=([^&]+)/i)			{ $HostFilter="$1"; }			# Filter on host list can also be defined with hostfilter=filter
	if ($QueryString =~ /urlfilter=([^&]+)/i)			{ $URLFilter="$1"; }			# Filter on URL list can also be defined with urlfilter=filter
	if ($QueryString =~ /refererpagesfilter=([^&]+)/i)	{ $RefererPagesFilter="$1"; }	# Filter on referer list can also be defined with refererpagesfilter=filter
	# All output
	if ($QueryString =~ /output=allhosts:([^&]+)/i)		{ $HostFilter="$1"; }			# Filter on host list can be defined with output=allhosts:filter to reduce number of lines read and showed
	if ($QueryString =~ /output=lasthosts:([^&]+)/i)	{ $HostFilter="$1"; }			# Filter on host list can be defined with output=lasthosts:filter to reduce number of lines read and showed
	if ($QueryString =~ /output=urldetail:([^&]+)/i)	{ $URLFilter="$1"; }			# Filter on URL list can be defined with output=urldetail:filter to reduce number of lines read and showed
	if ($QueryString =~ /output=refererpages:([^&]+)/i)	{ $RefererPagesFilter="$1"; }	# Filter on referer list can be defined with output=refererpages:filter to reduce number of lines read and showed

	# If show options
	if ($QueryString =~ /showsteps/i) 					{ $ShowSteps=1; $QueryString=~s/showsteps[^&]*//i; }
	if ($QueryString =~ /showcorrupted/i) 				{ $ShowCorrupted=1; $QueryString=~s/showcorrupted[^&]*//i; }
	if ($QueryString =~ /showdropped/i)					{ $ShowDropped=1; $QueryString=~s/showdropped[^&]*//i; }
	if ($QueryString =~ /showunknownorigin/i)			{ $ShowUnknownOrigin=1; $QueryString=~s/showunknownorigin[^&]*//i; }
}
if ($QueryString =~ /(^|&)staticlinks/i) 			{ $StaticLinks=".$SiteConfig"; }
if ($QueryString =~ /(^|&)staticlinks=([^&]+)/i) 	{ $StaticLinks=".$2"; }		# When ran from awstatsbuildstaticpages.pl
if ($QueryString =~ /(^|&)framename=([^&]+)/i)		{ $FrameName="$2"; }
if ($QueryString =~ /(^|&)debug=(\d+)/i)			{ $Debug=$2; }
if ($QueryString =~ /(^|&)limitflush=(\d+)/i)		{ $LIMITFLUSH=$2; }
# Get/Define output
if ($QueryString =~ /(^|&)output(=[^&]*|)(.*)&output(=[^&]*|)(&|$)/i) { error("Only 1 output option is allowed","","",1); }
if ($QueryString =~ /(^|&)output(=[^&]*|)(&|$)/i) {
	# At least one output expected. We define %HTMLOutput
	my $outputlist="$2";
	if ($outputlist) {
		$outputlist =~ s/^=//;
		foreach my $outputparam (split(/,/,$outputlist)) {
			$outputparam=~s/:(.*)$//;
			if ($outputparam) { $HTMLOutput{lc($outputparam)}="$1"||1; }
		}
	}
	# If output with no update, on command line
	if (! $ENV{'GATEWAY_INTERFACE'} && $QueryString !~ /update/i) { $UpdateStats=0; }
	# If no output defined, used default value
	if (! scalar keys %HTMLOutput) { $HTMLOutput{'main'}=1; }
}
if ($ENV{'GATEWAY_INTERFACE'} && ! scalar keys %HTMLOutput) { $HTMLOutput{'main'}=1; }
	
# Remove -output option with no = from QueryString
$QueryString=~s/(^|&)output(&|$)//i; $QueryString=~s/&+$//;

# Check year and month parameters
if ($QueryString =~ /(^|&)month=(year)/i) { error("month=year is a deprecated option. Use month=all instead."); }
if ($QueryString =~ /(^|&)year=(\d\d\d\d)/i) { $YearRequired=sprintf("%04d",$2); }
else { $YearRequired="$nowyear"; }
if ($QueryString =~ /(^|&)month=(\d{1,2})/i) { $MonthRequired=sprintf("%02d",$2); }
elsif ($QueryString =~ /(^|&)month=(all)/i) { $MonthRequired='all'; }
else { $MonthRequired="$nowmonth"; }
if ($QueryString =~ /(^|&)day=(\d{1,2})/i) { $DayRequired=sprintf("%02d",$2); }	# day is a hidden option. Must not be used (Make results not understandable). Available for users that rename history files with day.
else { $DayRequired=''; }

# Print AWStats and Perl version 
if ($Debug) {
	debug(ucfirst($PROG)." - $VERSION - Perl $^X $]",1);
	debug("QUERY_STRING=$QueryString",2);
	debug("HTMLOutput=".join(',',keys %HTMLOutput),1);
	debug("YearRequired=$YearRequired, MonthRequired=$MonthRequired",2);
}

# Force SiteConfig if AWSTATS_FORCE_CONFIG is defined
if ($ENV{'AWSTATS_CONFIG'}) { $ENV{'AWSTATS_FORCE_CONFIG'}=$ENV{'AWSTATS_CONFIG'}; } # For backward compatibility
if ($ENV{'AWSTATS_FORCE_CONFIG'}) {
	if ($Debug) { debug("AWSTATS_FORCE_CONFIG parameter is defined to '".$ENV{'AWSTATS_FORCE_CONFIG'}."'. $PROG will use this as config value."); }
	$SiteConfig=$ENV{'AWSTATS_FORCE_CONFIG'};
}

if ((! $ENV{'GATEWAY_INTERFACE'}) && (! $SiteConfig)) {
	&Read_Ref_Data('browsers','domains','operating_systems','robots','search_engines','worms');
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
	print "  Note 1: Config files ($PROG.virtualhostname.conf or $PROG.conf) must be\n";
	print "  in /etc/opt/awstats, /etc/awstats, /etc or same directory than awstats.pl\n";
	print "  file.\n";
	print "  Note 2: If AWSTATS_FORCE_CONFIG environment variable is defined, AWStats will\n";
	print "  use it as the \"config\" value, whatever is the value on command line or URL.\n";
	print "  See AWStats documentation for all setup instrutions.\n";
	print "\n";
	print "Options to update statistics:\n";
	print "  -update        to update statistics (default)\n";
	print "  -showsteps     to add benchmark information every $NBOFLINESFORBENCHMARK lines processed\n";
	print "  -showcorrupted to add output for each corrupted lines found, with reason\n";
	print "  -showdropped   to add output for each dropped lines found, with reason\n";
	print "  -logfile=x     to force log to analyze whatever is 'LogFile' in config file\n";
	print "  Be care to process log files in chronological order when updating statistics.\n";
	print "\n";
	print "Options to show statistics:\n";
	print "  -output      to output main HTML report (no update made except with -update)\n";
	print "  -output=x    to output other report pages where x is:\n";
	print "               alldomains       to build page of all domains/countries\n";
	print "               allhosts         to build page of all hosts\n";
	print "               lasthosts        to build page of last hits for hosts\n";
	print "               unknownip        to build page of all unresolved IP\n";
	print "               allemails        to build page of all email senders (maillog)\n";
	print "               lastemails       to build page of last email senders (maillog)\n";
	print "               allemailr        to build page of all email receivers (maillog)\n";
	print "               lastemailr       to build page of last email receivers (maillog)\n";
	print "               alllogins        to build page of all logins used\n";
	print "               lastlogins       to build page of last hits for logins\n";
	print "               allrobots        to build page of all robots/spider visits\n";
	print "               lastrobots       to build page of last hits for robots\n";
	print "               urldetail        to list most often viewed pages \n";
	print "               urldetail:filter to list most often viewed pages matching filter\n";
	print "               urlentry         to list entry pages\n";
	print "               urlentry:filter  to list entry pages matching filter\n";
	print "               urlexit          to list exit pages\n";
	print "               urlexit:filter   to list exit pages matching filter\n";
	print "               osdetail         to build page with os detailed versions\n";
	print "               browserdetail    to build page with browsers detailed versions\n";
	print "               unknownbrowser   to list 'User Agents' with unknown browser\n";
	print "               unknownos        to list 'User Agents' with unknown OS\n";
	print "               refererse        to build page of all refering search engines\n";
	print "               refererpages     to build page of all refering pages\n";
	#print "               referersites     to build page of all refering sites\n";
	print "               keyphrases       to list all keyphrases used on search engines\n";
	print "               keywords         to list all keywords used on search engines\n";
	print "               errors404        to list 'Referers' for 404 errors\n";
	print "  -staticlinks to have static links in HTML report page\n";
	print "  -lang=LL     to output a HTML report in language LL (en,de,es,fr,it,nl,...)\n";
	print "  -month=MM    to output a HTML report for an old month=MM\n";
	print "  -year=YYYY   to output a HTML report for an old year=YYYY\n";
	print "  Those 'date' options doesn't allow you to process old log file. They only\n";
	print "  allow you to see a past report for a chosen month/year period instead of\n";
	print "  current month/year.\n";
	print "\n";
	print "Other options:\n";
	print "  -debug=X     to add debug informations lesser than level X (speed reduced)\n";
	print "\n";
	print "Now supports/detects:\n";
	print "  Web/Ftp/Mail log analyze\n";
	print "  Reverse DNS lookup and/or GeoIP lookup\n";
	print "  Number of visits, number of unique visitors\n";
	print "  Visits duration and list of last visits\n";
	print "  Authenticated users\n";
	print "  Days of week and rush hours\n";
	print "  Hosts list and unresolved IP addresses list\n";
	print "  Most viewed, entry and exit pages\n";
	print "  Files type and Web compression\n";
	print "  Personalized reports\n";
	print "  ".(scalar keys %DomainsHashIDLib)." domains/countries\n";
	print "  ".(scalar keys %RobotsHashIDLib)." robots\n";
	print "  ".(scalar keys %OSHashLib)." operating systems\n";
	print "  ".(scalar keys %BrowsersHashIDLib)." browsers\n";
	print "  ".(scalar keys %SearchEnginesHashIDLib)." search engines (and keyphrases/keywords used from them)\n";
	print "  All HTTP errors with last referrer\n";
	print "  Report by day/month/year\n";
	print "  And a lot of other advanced options...\n";
	print "New versions and FAQ at http://awstats.sourceforge.net\n";
	exit 2;
}
$SiteConfig||=$ENV{'SERVER_NAME'};
#$ENV{'SERVER_NAME'}||=$SiteConfig;	# For thoose who use __SERVER_NAME__ in conf file and use CLI.
$ENV{'AWSTATS_CURRENT_CONFIG'}=$SiteConfig;

# Read config file (here SiteConfig is defined)
&Read_Config;
if ($QueryString =~ /(^|&)lang=([^&]+)/i)	{ $Lang="$2"; }
if (! $Lang || $Lang eq 'auto') {	# If lang not defined or forced to auto
	my $langlist=$ENV{'HTTP_ACCEPT_LANGUAGE'}||''; $langlist =~ s/;[^,]*//g;
	debug("Search an available language among HTTP_ACCEPT_LANGUAGE=$langlist",1);
	foreach my $code (split(/,/,$langlist)) {	# Search for a valid lang in priority
		if ($LangBrowserToAwstats{$code}) { $Lang=$LangBrowserToAwstats{$code}; debug("Will try to use Lang=$Lang",1); last; }
		$code =~ s/-.*$//;
		if ($LangBrowserToAwstats{$code}) { $Lang=$LangBrowserToAwstats{$code}; debug("Will try to use Lang=$Lang",1); last; }
	}
}
if (! $Lang || $Lang eq 'auto') { debug("No language defined or available. Will use Lang=en",1); $Lang='en'; }

# Check and correct bad parameters
&Check_Config;
# Now SiteDomain is defined

# Define frame name and correct variable for frames
if (! $FrameName) {
	if ($ENV{'GATEWAY_INTERFACE'} && $UseFramesWhenCGI && $HTMLOutput{'main'}) { $FrameName='index'; }
	else { $FrameName='main'; }
}

# Load Message and Plugins
if ($FrameName ne 'index') {
	&Read_Language_Data($Lang);
	if ($FrameName ne 'mainleft') {
		if (! scalar keys %HTMLOutput) { &Read_Ref_Data('browsers','domains','operating_systems','robots','search_engines','worms'); }
		else { &Read_Ref_Data('browsers','domains','operating_systems','robots','search_engines','worms','mime'); }
		&Read_Plugins();
	}
}

# Init other parameters
$NBOFLINESFORBENCHMARK--;
if ($ENV{'GATEWAY_INTERFACE'}) { $DirCgi=''; }
if ($DirCgi && !($DirCgi =~ /\/$/) && !($DirCgi =~ /\\$/)) { $DirCgi .= '/'; }
if (! $DirData || $DirData eq '.') { $DirData="$DIR"; }	# If not defined or chosen to '.' value then DirData is current dir
$DirData||='.';		# If current dir not defined then we put it to '.'
$DirData =~ s/\/$//; $DirData =~ s/\\$//;
# Define SiteToAnalyze and SiteToAnalyzeWithoutwww for regex operations
$SiteToAnalyze=lc($SiteDomain); $SiteToAnalyze =~ s/\./\\\./g;
$SiteToAnalyzeWithoutwww = $SiteToAnalyze; $SiteToAnalyzeWithoutwww =~ s/www\.//;
if ($FirstDayOfWeek == 1) { @DOWIndex = (1,2,3,4,5,6,0); }
else { @DOWIndex = (0,1,2,3,4,5,6); }

# Should we link to ourselves or to a wrapper script
$AWScript=($WrapperScript?"$WrapperScript":"$DirCgi$PROG.$Extension");

# Print html header (Need HTMLOutput,Expires,Lang,StyleSheet,HTMLHeadSectionExpires defined by Read_Config, PageCodes defined by Read_Language_Data)
&html_head;

# Security check
if ($AllowAccessFromWebToAuthenticatedUsersOnly && $ENV{'GATEWAY_INTERFACE'}) {
	if ($Debug) { debug("REMOTE_USER=".$ENV{"REMOTE_USER"}); }
	if (! $ENV{"REMOTE_USER"}) {
		error("Access to statistics is only allowed from an authenticated session to authenticated users.");
	}
	if (@AllowAccessFromWebToFollowingAuthenticatedUsers) {
		my $userisinlist=0;
		my $currentuser=$ENV{"REMOTE_USER"};
		$currentuser =~ s/\s/%20/g;	# Allow authenticated user with space in name to be compared to allowed user list
		foreach my $key (@AllowAccessFromWebToFollowingAuthenticatedUsers) {
			if ($currentuser eq $key) { $userisinlist=1; last; }
		}
		if (! $userisinlist) {
			error("User '$currentuser' is not allowed to access statistics of this domain/config.");
		}
	}
}
if ($AllowAccessFromWebToFollowingIPAddresses && $ENV{'GATEWAY_INTERFACE'}) {
	if ($AllowAccessFromWebToFollowingIPAddresses	!~ /^(\d+\.\d+\.\d+\.\d+)-(\d+\.\d+\.\d+\.\d+)$/) {
		error("AllowAccessFromWebToFollowingIPAddresses is defined to '$AllowAccessFromWebToFollowingIPAddresses' but does not match the correct syntax: IPAddressMin-IPAddressMax");
	}
	my $ipmin=&Convert_IP_To_Decimal($1);
	my $ipmax=&Convert_IP_To_Decimal($2);
	my $useripaddress=&Convert_IP_To_Decimal($ENV{"REMOTE_ADDR"});
	if ($useripaddress < $ipmin || $useripaddress > $ipmax) {
		error("Access to statistics is not allowed from your IP Address ".$ENV{"REMOTE_ADDR"});
	}
}
if (($UpdateStats || $MigrateStats) && (! $AllowToUpdateStatsFromBrowser) && $ENV{'GATEWAY_INTERFACE'}) {
	error("".($UpdateStats?"Update":"Migrate")." of statistics is not allowed from a browser.");
}

#------------------------------------------
# MIGRATE PROCESS (Must be after reading config cause we need MaxNbOf... and Min...)
#------------------------------------------
if ($MigrateStats) {
	if ($Debug) { debug("MigrateStats is $MigrateStats",2); }
	if ($MigrateStats !~ /^(.*)$PROG(\d{0,2})(\d\d)(\d\d\d\d)(.*)\.txt$/) {
		error("AWStats history file name must match following syntax: ${PROG}MMYYYY[.config].txt","","",1);
	}
	$DirData="$1";
	$DayRequired="$2";
	$MonthRequired="$3";
	$YearRequired="$4";
	$FileSuffix="$5";
	# Correct DirData
	if (! $DirData || $DirData eq '.') { $DirData="$DIR"; }	# If not defined or chosen to '.' value then DirData is current dir
	$DirData||=$DirData='.';	# If current dir not defined then we put it to '.'
	$DirData =~ s/\/$//; $DirData =~ s/\\$//;
	print "Start migration for file '$MigrateStats'."; print $ENV{'GATEWAY_INTERFACE'}?"<br>\n":"\n";
	if ($EnableLockForUpdate) {	&Lock_Update(1); }
	my $newhistory=&Read_History_With_TmpUpdate($YearRequired,$MonthRequired,1,0,'all');
	if (rename("$newhistory","$MigrateStats")==0) {
		unlink "$newhistory";
		error("Failed to rename \"$newhistory\" into \"$MigrateStats\".\nWrite permissions on \"$MigrateStats\" might be wrong".($ENV{'GATEWAY_INTERFACE'}?" for a 'migration from web'":"")." or file might be opened.");
	}
	if ($EnableLockForUpdate) {	&Lock_Update(0); }
	print "Migration for file '$MigrateStats' successful."; print $ENV{'GATEWAY_INTERFACE'}?"<br>\n":"\n";
	&html_end;
	exit 0;
}

# Output main frame page and exit. This must be after the security check.
if ($FrameName eq 'index') {
	# Define the NewLinkParams for main chart
	my $NewLinkParams=${QueryString};
	$NewLinkParams =~ s/(^|&)framename=[^&]*//i;
	$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
	if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }
	# Exit if main frame
	print "<frameset cols=\"$FRAMEWIDTH,*\" border=0 framespacing=2 frameborder=0>\n";
	print "<frame name=\"mainleft\" src=\"$AWScript?${NewLinkParams}framename=mainleft\" noresize noborder>\n";
	print "<frame name=\"mainright\" src=\"$AWScript?${NewLinkParams}framename=mainright\" noresize scrolling=\"YES\" noborder>\n";
	print "<noframes><body>";
	print "Your browser does not support frames.<br>\n";
	print "You must set AWStats UseFramesWhenCGI parameter to 0\n";
	print "to see your reports.<br>\n";
	print "</body></noframes>\n";
	print "</frameset>\n";
	&html_end;
	exit 0;
}

# Init global variables required for output and update process
%MonthLib = ("01","$Message[60]","02","$Message[61]","03","$Message[62]","04","$Message[63]","05","$Message[64]","06","$Message[65]","07","$Message[66]","08","$Message[67]","09","$Message[68]","10","$Message[69]","11","$Message[70]","12","$Message[71]");
%MonthNum = ("Jan","01","jan","01","Feb","02","feb","02","Mar","03","mar","03","Apr","04","apr","04","May","05","may","05","Jun","06","jun","06","Jul","07","jul","07","Aug","08","aug","08","Sep","09","sep","09","Oct","10","oct","10","Nov","11","nov","11","Dec","12","dec","12");	# MonthNum must be in english because used to translate log date in apache log files

# Build ListOfYears list with all existing years
my $lastyearbeforeupdate=0;
opendir(DIR,"$DirData");
foreach (grep /^$PROG(\d\d)(\d\d\d\d)$FileSuffix\.txt(|\.gz)$/, sort readdir DIR) {
	/^$PROG(\d\d)(\d\d\d\d)$FileSuffix\.txt(|\.gz)$/;
	if (! $ListOfYears{"$2"} || "$1" gt $ListOfYears{"$2"}) {
		$ListOfYears{"$2"}="$1";	# ListOfYears contains max month found
		if ("$2" gt $lastyearbeforeupdate) { $lastyearbeforeupdate="$2"; }
	}
}
close DIR;

# Get value for LastLine
if ($lastyearbeforeupdate) {
	# Read 'general' section of last history file for LastLine
	&Read_History_With_TmpUpdate($lastyearbeforeupdate,$ListOfYears{$lastyearbeforeupdate},0,0,"general");
}
if ($Debug) {
	debug("Last year=$lastyearbeforeupdate - Last month=$ListOfYears{$lastyearbeforeupdate}");
	debug("LastLine=$LastLine");
	debug("LastLineNumber=$LastLineNumber");
	debug("LastLineOffset=$LastLineOffset");
	debug("LastLineChecksum=$LastLineChecksum");
}

# Init vars
&Init_HashArray();


#------------------------------------------
# UPDATE PROCESS
#------------------------------------------
if ($Debug) { debug("UpdateStats is $UpdateStats",2); }
if ($UpdateStats && $FrameName ne 'index' && $FrameName ne 'mainleft') {	# Update only on index page or when not framed to avoid update twice

	if (! scalar keys %HTMLOutput) {
		print "Update for config \"$FileConfig\"\n";
		print "With data in log file \"$LogFile\"...\n";
	}

	my $lastprocessedyear=$lastyearbeforeupdate;
	my $lastprocessedmonth=$ListOfYears{$lastyearbeforeupdate}||0;
	my $lastprocessedyearmonth=sprintf("%04i%02i",$lastprocessedyear,$lastprocessedmonth);

	# Init RobotsSearchIDOrder required for update process
	my @robotlist;
	if ($LevelForRobotsDetection >= 1) { push @robotlist,"list1"; }
	if ($LevelForRobotsDetection >= 2) { push @robotlist,"list2"; }
	if ($LevelForRobotsDetection >= 1) { push @robotlist,"list3"; }	# Always added
	foreach my $key (@robotlist) {
		push @RobotsSearchIDOrder,@{"RobotsSearchIDOrder_$key"};
		if ($Debug) { debug("Add ".@{"RobotsSearchIDOrder_$key"}." elements from RobotsSearchIDOrder_$key into RobotsSearchIDOrder",2); }
	}
	if ($Debug) { debug("RobotsSearchIDOrder has now ".@RobotsSearchIDOrder." elements",1); }

	# Complete HostAliases array
	if (! @HostAliases) {
		warning("Warning: HostAliases parameter is not defined, $PROG choose \"$SiteDomain localhost 127.0.0.1\".");
		push @HostAliases,"$SiteToAnalyze"; push @HostAliases,"localhost"; push @HostAliases,"127\.0\.0\.1";
	}
	unshift @HostAliases,"$SiteToAnalyze";	# Add SiteToAnalyze as first value

	# Optimize HostAliases, SkipDNSLookupFor, SkipHosts, SkipUserAgents, SkipFiles, OnlyHosts, OnlyFiles array
	&OptimizeArray(\@HostAliases,1,1); if ($Debug) { debug("HostAliases is now @HostAliases",1); }
	&OptimizeArray(\@SkipDNSLookupFor,1,0); if ($Debug) { debug("SkipDNSLookupFor is now @SkipDNSLookupFor",1); }
	&OptimizeArray(\@SkipHosts,1,0); if ($Debug) { debug("SkipHosts is now @SkipHosts",1); }
	&OptimizeArray(\@SkipUserAgents,1,0); if ($Debug) { debug("SkipUserAgents is now @SkipUserAgents",1); }
	&OptimizeArray(\@SkipFiles,0,0); if ($Debug) { debug("SkipFiles is now @SkipFiles",1); }
	&OptimizeArray(\@OnlyHosts,1,0); if ($Debug) { debug("OnlyHosts is now @OnlyHosts",1); }
	&OptimizeArray(\@OnlyFiles,0,0); if ($Debug) { debug("OnlyFiles is now @OnlyFiles",1); }

	# Define value of $PerlParsingFormat and @fieldlib
	DefinePerlParsingFormat();

	# Load DNS Cache Files
	#------------------------------------------
	if ($DNSLookup) {
		&Read_DNS_Cache(\%MyDNSTable,"$DNSStaticCacheFile","",1);						# Load with save into a second plugin file if plugin enabled and second file not up to date. No use of FileSuffix
		if ($DNSLookup == 1) {		# System DNS lookup required
			#if (! eval("use Socket;")) { error("Failed to load perl module Socket."); }
			#use Socket;
			&Read_DNS_Cache(\%TmpDNSLookup,"$DNSLastUpdateCacheFile","$FileSuffix",0);	# Load with no save into a second plugin file. Use FileSuffix
		}
	}

	# Processing log
	#------------------------------------------

	if ($EnableLockForUpdate) {
		# Trap signals to remove lock
		$SIG{INT} = \&SigHandler;	# 2
		#$SIG{KILL} = \&SigHandler;	# 9
		#$SIG{TERM} = \&SigHandler;	# 15
		# Set AWStats update lock
		&Lock_Update(1);
	}

	if ($Debug) { debug("Start Update process (lastprocessedmonth=$lastprocessedmonth, lastprocessedyear=$lastprocessedyear)"); }

	# Open log file
	if ($Debug) { debug("Open log file \"$LogFile\""); }
	open(LOG,"$LogFile") || error("Couldn't open server log file \"$LogFile\" : $!");
	binmode LOG;	# Avoid premature EOF due to log files corrupted with \cZ or bin chars

	my @field=();
	my $lastlinenumber=0; my $lastlineoffset=0; my $lastlineoffsetnext=0;
	my $counterforflushtest=0;
	# Reset chrono for benchmark (first call to GetDelaySinceStart)
	&GetDelaySinceStart(1);
	if (! scalar keys %HTMLOutput) { print "Phase 1 : First bypass old records, searching new record...\n"; }

	# Can we try a direct seek access in log ?
	if ($LastLine && $LastLineNumber && $LastLineOffset && $LastLineChecksum) {
		# Try a direct seek access to save time
#		if ($Debug) { debug("Try a direct access to LastLine=$LastLine, LastLineNumber=$LastLineNumber, LastLineOffset=$LastLineOffset, LastLineChecksum=$LastLineChecksum"); }
#		seek(LOG,$LastLineOffset,0);
#		if ($_=<LOG>) {
#			chomp $_; s/\r$//;
#			@field=map(/^$PerlParsingFormat/,$_);
#			if ($Debug) {
#				my $string='';
#				foreach my $key (0..@field-1) {	$string.="$fieldlib[$key]=$field[$key] "; }
#				debug(" Read line after direct access: $string",1);
#			}
#			my $checksum=&CheckSum(join("\t",@field));
#			debug(" LastLineChecksum=$LastLineChecksum, Read line checksum=$checksum",1);
#			if ($checksum == $LastLineChecksum ) {
#				if (! scalar keys %HTMLOutput) { print "Direct access to new records was successfull (We should be line $LastLineRead)\n"; }
#				$lastlinenumber=$LastLineNumber;
#				$lastlineoffset=$LastLineOffset;
#				$lastlineoffsetnext=$LastLineOffset;
#				seek(LOG,$LastLineOffset,0);	# Direct access succesful, we keep it.
#			}
#			else {
#				if (! scalar keys %HTMLOutput) { print "Direct access to last remembered record falled on another record.\nSo searching it from beginning of log file...\n"; }
#				$lastlinenumber=0;
#				$lastlineoffset=0;
#				$lastlineoffsetnext=0;
#				seek(LOG,0,0);
#			}
#		}
#		else {
#			if (! scalar keys %HTMLOutput) { print "Direct access to last remembered record is out of file.\nSo searching if from beginning of log file...\n"; }
#			$lastlinenumber=0;
#			$lastlineoffset=0;
#			$lastlineoffsetnext=0;
#			seek(LOG,0,0);
#		}
	}
	else {
		# No try of direct seek access
		$lastlinenumber=0;
		$lastlineoffset=0;
		$lastlineoffsetnext=0;
	}
	
	while (<LOG>) {
		chomp $_; s/\r$//;
		$NbOfLinesParsed++;
 		$lastlineoffset=$lastlineoffsetnext; $lastlineoffsetnext=tell LOG;

		if ($ShowSteps) {
			if ((++$NbOfLinesShowsteps & $NBOFLINESFORBENCHMARK) == 0) {
				my $delay=&GetDelaySinceStart(0);
				print "$NbOfLinesParsed lines processed (".($delay>0?$delay:1000)." ms, ".int(1000*$NbOfLinesShowsteps/($delay>0?$delay:1000))." lines/second)\n";
			}
		}

		# Parse line record to get all required fields
		if (! (@field=map(/^$PerlParsingFormat/,$_))) {
			$NbOfLinesCorrupted++;
			if ($ShowCorrupted) {
				if ($_ =~ /^#/ || $_ =~ /^!/) { print "Corrupted record line ".($lastlinenumber+$NbOfLinesParsed)." (comment line): $_\n"; }
				elsif ($_ =~ /^\s*$/) { print "Corrupted record line ".($lastlinenumber+$NbOfLinesParsed)." (blank line)\n"; }
				else { print "Corrupted record line ".($lastlinenumber+$NbOfLinesParsed)." (record format does not match LogFormat parameter): $_\n"; }
			}
			if ($NbOfLinesParsed >= $NbOfLinesForCorruptedLog && $NbOfLinesParsed == $NbOfLinesCorrupted) { error("Format error",$_,$LogFile); }	# Exit with format error
			if ($_ =~ /^__end_of_file__/) { last; }	# For test purpose only
			next;
		}

		if ($Debug) {
			my $string='';
			foreach my $key (0..@field-1) {	$string.="$fieldlib[$key]=$field[$key] "; }
			debug(" Correct format line ".($lastlinenumber+$NbOfLinesParsed).": $string",4);
		}

		# Check virtual host name
		#----------------------------------------------------------------------
		if ($pos_vh>=0 && $field[$pos_vh] ne $SiteDomain) {
			$NbOfLinesDropped++;
			if ($ShowDropped) { print "Dropped record (virtual hostname '$field[$pos_vh]' does not match SiteDomain='$SiteDomain' parameter): $_\n"; }
			next;
		}

		# Check protocol (Note: Use of TmpProtocol does not increase speed)
		#----------------------------------------------------------------------
		my $protocol=0;
		if ($field[$pos_method] eq 'GET' || $field[$pos_method] eq 'POST' || $field[$pos_method] eq 'HEAD' || $field[$pos_method] =~ /OK/i) {
			# HTTP request.	Keep only GET, POST, HEAD, *OK* with Webstar but not OPTIONS
			$protocol=1;
		}
		elsif ($field[$pos_method] eq 'SMTP') {
			# Mail request ('SMTP' for sendmail with sma)
			$protocol=3;
		}
		elsif ($field[$pos_method] eq 'RETR' || $field[$pos_method] =~ /get/i) {
			# FTP GET request
			$protocol=2;
		}
		elsif ($field[$pos_method] eq 'STOR' || $field[$pos_method] =~ /sent/i) {
			# FTP SENT request
			$protocol=2;
		}
		elsif ($field[$pos_method] eq 'mms') {
			# Streaming request
			$protocol=4;
		}
		elsif ($field[$pos_method] =~ /\d\d\d\d/) {
			# Mail request (\d\d\d\d for Exchange log)
			$protocol=5;
		}
		else {
			$NbOfLinesDropped++;
			if ($ShowDropped) { print "Dropped record (method/protocol '$field[$pos_method]' not qualified): $_\n"; }
			next;
		}

		# Split DD/Month/YYYY:HH:MM:SS or YYYY-MM-DD HH:MM:SS or MM/DD/YY\tHH:MM:SS
		$field[$pos_date] =~ tr/,-\/ \t/:::::/;			# " \t" is used instead of "\s" not known with tr
		my @dateparts=split(/:/,$field[$pos_date]);		# tr and split faster than @dateparts=split(/[\/\-:\s]/,$field[$pos_date])
		if ($dateparts[0] =~ /^....$/) { my $tmp=$dateparts[0]; $dateparts[0]=$dateparts[2]; $dateparts[2]=$tmp; }
		elsif ($field[$pos_date] =~ /^..:..:..:/) { $dateparts[2]+=2000; my $tmp=$dateparts[0]; $dateparts[0]=$dateparts[1]; $dateparts[1]=$tmp; }
		if ($MonthNum{$dateparts[1]}) { $dateparts[1]=$MonthNum{$dateparts[1]}; }	# Change lib month in num month if necessary

		# Now @dateparts is (DD,MM,YYYY,HH,MM,SS) and we're going to create $timerecord=YYYYMMDDHHMMSS
		# Plugin call : Convert a @datepart into another @datepart
		if ($PluginsLoaded{'ChangeTime'}{'timezone'})  { @dateparts=ChangeTime_timezone(\@dateparts); }
		my $yearmonthdayrecord=sprintf("$dateparts[2]%02i%02i",$dateparts[1],$dateparts[0]);
		my $timerecord=((int("$yearmonthdayrecord")*100+$dateparts[3])*100+$dateparts[4])*100+$dateparts[5];
		my $yearrecord=int($dateparts[2]);
		my $monthrecord=int($dateparts[1]);

		# Check date
		#-----------------------
		if ($timerecord < 10000000000000 || $timerecord > $tomorrowtime) {
			$NbOfLinesCorrupted++;
			if ($ShowCorrupted) { print "Corrupted record (invalid date, timerecord=$timerecord): $_\n"; }
			next;		# Should not happen, kept in case of parasite/corrupted line
		}
		if ($NewLinePhase) {
			if ($timerecord < ($LastLine - $NOTSORTEDRECORDTOLERANCE)) {
				# Should not happen, kept in case of parasite/corrupted old line
				$NbOfLinesCorrupted++;
				if ($ShowCorrupted) { print "Corrupted record (date $timerecord lower than $LastLine-$NOTSORTEDRECORDTOLERANCE): $_\n"; } next;
			}
		}
		else {
			if ($timerecord <= $LastLine) {	# Already processed
				$NbOfOldLines++;
				next;
			}
			# We found a new line. This will replace comparison "<=" with "<" between timerecord and LastLine (we should have only new lines now)
			$NewLinePhase=1;
			if ($ShowSteps) {
				if ($NbOfLinesShowsteps > 1 && (($NbOfLinesShowsteps & $NBOFLINESFORBENCHMARK) != 0)) {
					my $delay=&GetDelaySinceStart(0);
					print "".($NbOfLinesParsed-1)." lines processed (".($delay>0?$delay:1000)." ms, ".int(1000*($NbOfLinesShowsteps-1)/($delay>0?$delay:1000))." lines/second)\n";
				}
				&GetDelaySinceStart(1);	$NbOfLinesShowsteps=1;
			}
			if (! scalar keys %HTMLOutput) {
				print "Phase 2 : Now process new records (Flush history on disk after ".($LIMITFLUSH<<2)." hosts)...\n";
				#print "Phase 2 : Now process new records (Flush history on disk after ".($LIMITFLUSH<<2)." hosts or ".($LIMITFLUSH)." URLs)...\n";
			}
		}

		# Here, field array, timerecord and yearmonthdayrecord are initialized for log record
		if ($Debug) { debug("  This is a not already processed record ($timerecord)",4); }

		# We found a new line
		#----------------------------------------
		if ($timerecord > $LastLine) {
			$LastLine = $timerecord;
		}	# Test should always be true except with not sorted log files.

		# TODO. Add robot in a list if URL is robots.txt (Note: robot referer value can be same than a normal browser)

		# Skip for some client host IP addresses, some URLs, other URLs
		my $qualifdrop='';
		if    (@SkipHosts && &SkipHost($field[$pos_host]))   { $qualifdrop="Dropped record (host $field[$pos_host] not qualified by SkipHosts)"; }
		elsif (@SkipFiles && &SkipFile($field[$pos_url]))    { $qualifdrop="Dropped record (URL $field[$pos_url] not qualified by SkipFiles)"; }
		elsif (@OnlyHosts && ! &OnlyHost($field[$pos_host])) { $qualifdrop="Dropped record (host $field[$pos_host] not qualified by OnlyHosts)"; }
		elsif (@OnlyFiles && ! &OnlyFile($field[$pos_url]))  { $qualifdrop="Dropped record (URL $field[$pos_url] not qualified by OnlyFiles)"; }
		elsif (@SkipUserAgents && $pos_agent >= 0 && &SkipUserAgent($field[$pos_agent]))	{ $qualifdrop="Dropped record (user agent $field[$pos_agent] not qualified by SkipUserAgents)"; }
		if ($qualifdrop) {
			$NbOfLinesDropped++;
			if ($Debug) { debug("$qualifdrop: $_",4); }
			if ($ShowDropped) { print "$qualifdrop: $_\n"; }
			next;
		}

		# Record is approved
		#-------------------
		$NbOfNewLines++;

		# Is it in a new month section ?
		#-------------------------------
		if ((($monthrecord > $lastprocessedmonth) && ($yearrecord >= $lastprocessedyear)) || ($yearrecord > $lastprocessedyear)) {
			# A new month to process
			if ($lastprocessedmonth) {
				# We save data of processed month
				&Read_History_With_TmpUpdate($lastprocessedyear,$lastprocessedmonth,1,1,"all",($lastlinenumber+$NbOfLinesParsed),$lastlineoffset,&CheckSum($_));
				$counterforflushtest=0;	# We reset counterforflushtest
			}
			$lastprocessedmonth=$monthrecord;$lastprocessedyear=$yearrecord;
			$lastprocessedyearmonth=sprintf("%04i%02i",$lastprocessedyear,$lastprocessedmonth);
		}

		# Convert $field[$pos_size]
		# if ($field[$pos_size] eq '-') { $field[$pos_size]=0; }

		# Check screen size
		#------------------
		if ($field[$pos_url] =~ /$LogScreenSizeUrl/) {
			if ($pos_query >=0 && $field[$pos_query]) { # For this fucking IIS in pos_query mode
				if ($field[$pos_query] =~ /w=(\d+)&h=(\d+)/) { $_screensize_h{"$1x$2"}++; next; }
			}
			elsif ($field[$pos_url] =~ /w=(\d+)&h=(\d+)/) { $_screensize_h{"$1x$2"}++; next; }
		}
		
		# Check return status code
		#-------------------------
		if ($protocol == 1 || $protocol == 4) {			# HTTP record or Stream record
			if ($ValidHTTPCodes{$field[$pos_code]}) {	# Code is valid
				if ($field[$pos_code] == 304) { $field[$pos_size]=0; }
			}
			else {										# Code is not valid
				if ($field[$pos_code] =~ /^\d\d\d$/) {  # Keep error code and next
					$_errors_h{$field[$pos_code]}++;
					$_errors_k{$field[$pos_code]}+=int($field[$pos_size]);
					foreach my $code (keys %TrapInfosForHTTPErrorCodes) {
						if ($field[$pos_code] == $code) {
							my $newurl=$field[$pos_url];
							$newurl =~ s/[$URLQuerySeparators].*$//;
							$_sider404_h{$newurl}++;
							my $newreferer=$field[$pos_referer];
							if (! $URLReferrerWithQuery) { $newreferer =~ s/[$URLQuerySeparators].*$//; }
							$_referer404_h{$newurl}=$newreferer;
							last;
						}
					}
					next;
				}
				else {									# Bad format record (should not happen but when using MSIndex server), next
					# Second test avoid error when using MS IndexServer that returns non standard HTTP code on 1 char
					if ($field[$pos_code] !~ /^\d$/) { 
						$NbOfLinesCorrupted++; $NbOfNewLines--;
						if ($ShowCorrupted) { print "Corrupted record (HTTP code not on 3 digits): $_\n"; }
						next;
					}
				}
			}
		}
		elsif ($protocol == 3 || $protocol == 5) {		# Mail record
			if (! $ValidSMTPCodes{$field[$pos_code]}) {	# Code is not valid
				$_errors_h{$field[$pos_code]}++;
				#$_errors_k{$field[$pos_code]}+=int($field[$pos_size]);	# Useless as pos_size should be 0
				next;	# Next log record
			}
		}

		# Analyze: Robot
		#---------------
		if ($pos_agent >= 0) {
			if ($DecodeUA) { $field[$pos_agent] =~ s/%20/_/g; }	# This is to support servers (like Roxen) that writes user agent with %20 in it
			$UserAgent=$field[$pos_agent];

			if ($LevelForRobotsDetection) {

				my $uarobot=$TmpRobot{$UserAgent};
				if (! $uarobot) {
					my $foundrobot=0;
					#study $UserAgent;		Does not increase speed
					foreach my $bot (@RobotsSearchIDOrder) {
						if ($UserAgent =~ /$bot/i) {
							$foundrobot=1;
							$TmpRobot{$UserAgent}=$uarobot="$bot";	# Last time, we won't search if robot or not. We know it is.
							if ($Debug) { debug(" UserAgent '$UserAgent' is added to TmpRobot with value '$bot'",2); }
							last;
						}
					}
					if (! $foundrobot) {							# Last time, we won't search if robot or not. We know it's not.
						$TmpRobot{$UserAgent}=$uarobot='-';
					}
				}
				# If robot, we stop here
				if ($uarobot ne '-') {
					if ($Debug) { debug(" UserAgent '$UserAgent' contains robot ID '$uarobot'",2); }
					$_robot_h{$uarobot}++;
					$_robot_k{$uarobot}+=int($field[$pos_size]);
					$_robot_l{$uarobot}=$timerecord;
					next;
				}

			}
		}

		# Canonize and clean target URL and referrer URL
		#-----------------------------------------------
		if ($URLNotCaseSensitive) { $field[$pos_url] =~ tr/A-Z/a-z/; }
		if ($protocol == 2) { $field[$pos_url] =~ s/\s/%20/g; }
		# Possible URL syntax for $field[$pos_url]: /mydir/mypage.ext?param1=x&param2=y#aaa, /mydir/mypage.ext#aaa, /
		my $urlwithnoquery; my $tokenquery; my $standalonequery; my $anchor='';
		if ($field[$pos_url] =~ s/#(\w*)$//) { $anchor=$1; }	# Remove and save anchor
		if ($URLWithQuery) {
			$urlwithnoquery=$field[$pos_url];
			my $foundparam=($urlwithnoquery =~ s/([$URLQuerySeparators])(.*)$//);
			$tokenquery=$1||'';
			$standalonequery=$2||'';
			# For IIS setup, if pos_query is enabled we need to combine the URL to query strings
			if (! $foundparam && $pos_query >=0 && $field[$pos_query] && $field[$pos_query] ne '-') {
				$foundparam=1;
				$field[$pos_url] .= '?'.$field[$pos_query];
				$tokenquery='?';
				$standalonequery=$field[$pos_query];
			}
 			# Remove params that are marked to be ignored in URLWithQueryWithoutFollowingParameters
			if ($foundparam && @URLWithQueryWithoutFollowingParameters) {
				if ($URLNotCaseSensitive) { map {$field[$pos_url] =~ s/$_=[^&]*//i;} @URLWithQueryWithoutFollowingParameters; }
				else { map {$field[$pos_url] =~ s/$_=[^&]*//;} @URLWithQueryWithoutFollowingParameters; }
 				# Cut starting or trailing ? or &
 				$field[$pos_url] =~ tr/&/&/s;
 				$field[$pos_url] =~ s/[$tokenquery]&/$tokenquery/;
 				$field[$pos_url] =~ s/[$tokenquery&]$//;
 			}
		}
		else {
			# Trunc parameters of URL
			$field[$pos_url] =~ s/([$URLQuerySeparators])(.*)$//;
			$urlwithnoquery=$field[$pos_url];
			$tokenquery=$1||'';
			$standalonequery=$2||'';
		}
		if ($URLWithAnchor && $anchor) { $field[$pos_url].="#$anchor"; }	# Restore anchor

		# Here now urlwithnoquery is /mydir/mypage.ext, /mydir, /, /page#XXX
		# Here now tokenquery is '' or '?' or ';'
		# Here now standalonequery is '' or 'param1=x'

		# Analyze: File type and compression
		#-----------------------------------
		my $PageBool=1;
		my $extension;
		# Extension
		if ($urlwithnoquery =~ /\.(\w{1,6})$/ || ($urlwithnoquery =~ /[\\\/]$/ && $DefaultFile[0] =~ /\.(\w{1,6})$/)) {
			$extension=lc($1);
			if ($NotPageList{$extension}) { $PageBool=0; }
		}
		else {
			$extension='Unknown';
		}
		$_filetypes_h{$extension}++;
		$_filetypes_k{$extension}+=int($field[$pos_size]);	# TODO can cause a warning
		# Compression
		if ($pos_gzipin>=0 && $field[$pos_gzipin]) {	# If in and out in log
			my ($notused,$in)=split(/:/,$field[$pos_gzipin]);
			my ($notused1,$out,$notused2)=split(/:/,$field[$pos_gzipout]);
			if ($out) {
				$_filetypes_gz_in{$extension}+=$in;
				$_filetypes_gz_out{$extension}+=$out;
			}
		}
		elsif ($pos_gzipratio>=0 && ($field[$pos_gzipratio] =~ /(\d+)pct./)) {
			$_filetypes_gz_in{$extension}+=int($field[$pos_size]*100/((100-$1)||1));
			$_filetypes_gz_out{$extension}+=int($field[$pos_size]);	# out size calculated from pct.
		}

		# Analyze: Date - Hour - Pages - Hits - Kilo
		#-------------------------------------------
		my $hourrecord=int($dateparts[3]);
		if ($PageBool) {
			# Replace default page name with / only ('if' is to increase speed when only 1 value in @DefaultFile)
			if (@DefaultFile > 1) { foreach my $elem (@DefaultFile) { if ($field[$pos_url] =~ s/\/$elem$/\//) { last; } } }
			else { $field[$pos_url] =~ s/\/$DefaultFile[0]$/\//; }

			# FirstTime and LastTime are First and Last human visits (so changed if access to a page)
			$FirstTime{$lastprocessedyearmonth}||=$timerecord;
			$LastTime{$lastprocessedyearmonth}=$timerecord;
			$DayPages{$yearmonthdayrecord}++;
			$MonthPages{$lastprocessedyearmonth}++;
			$_time_p[$hourrecord]++;											#Count accesses for hour (page)
			$_url_p{$field[$pos_url]}++; 										#Count accesses for page (page)
			$_url_k{$field[$pos_url]}+=int($field[$pos_size]);
		}
		$_time_h[$hourrecord]++; $MonthHits{$lastprocessedyearmonth}++; $DayHits{$yearmonthdayrecord}++;	#Count accesses for hour (hit)
		$_time_k[$hourrecord]+=int($field[$pos_size]); $MonthBytes{$lastprocessedyearmonth}+=int($field[$pos_size]); $DayBytes{$yearmonthdayrecord}+=int($field[$pos_size]);	#Count accesses for hour (kb)

		# Analyze: Login
		#---------------
		if ($pos_logname>=0 && $field[$pos_logname] && $field[$pos_logname] ne '-') {
			$field[$pos_logname] =~ s/ /_/g; # This is to allow space in logname
			if ($LogFormat eq '6') { $field[$pos_logname] =~ s/^\"//; $field[$pos_logname] =~ s/\"$//;}	# logname field has " with Domino 6+
			if ($AuthenticatedUsersNotCaseSensitive) { $field[$pos_logname] =~ tr/A-Z/a-z/; }

			# We found an authenticated user
			if ($PageBool) {
				$_login_p{$field[$pos_logname]}++;								#Count accesses for page (page)
			}
			$_login_h{$field[$pos_logname]}++;									#Count accesses for page (hit)
			$_login_k{$field[$pos_logname]}+=int($field[$pos_size]);			#Count accesses for page (kb)
			$_login_l{$field[$pos_logname]}=$timerecord;
		}

		# Do DNS lookup
		#--------------
		my $Host=$field[$pos_host];
		my $HostResolved='';
		my $ip=0;
		if ($DNSLookup) {			# DNS lookup is 1 or 2
			if ($Host =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) { $ip=4; }	# IPv4
			elsif ($Host =~ /^[0-9A-F]*:/i) { $ip=6; }						# IPv6
			if ($ip) {
				# Check in static DNS cache file
				$HostResolved=$MyDNSTable{$Host};
				if ($HostResolved) {
					if ($Debug) { debug("  DNS lookup asked for $Host and found in DNS cache file: $HostResolved",4); }
				}
				elsif ($DNSLookup==1) {
					# Check in session cache (dynamic DNS cache file + session DNS cache)
					$HostResolved=$TmpDNSLookup{$Host};
					if (! $HostResolved) {
						if (@SkipDNSLookupFor && &SkipDNSLookup($Host)) {
							$HostResolved=$TmpDNSLookup{$Host}='*';
							if ($Debug) { debug("  No need of reverse DNS lookup for $Host, skipped at user request.",4); }
						}
						else {
							if ($ip == 4) {
								my $lookupresult=gethostbyaddr(pack("C4",split(/\./,$Host)),AF_INET);	# This is very slow, may took 20 seconds
								if (! $lookupresult || $lookupresult =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ || ! IsAscii($lookupresult)) {
									$TmpDNSLookup{$Host}=$HostResolved='*';
								}
								else {
									$TmpDNSLookup{$Host}=$HostResolved=$lookupresult;
								}
								if ($Debug) { debug("  Reverse DNS lookup for $Host done: $HostResolved",4); }
							}
							elsif ($ip == 6) {
								$TmpDNSLookup{$Host}=$HostResolved='*';
								if ($Debug) { debug("  Reverse DNS lookup for $Host not available for IPv6",4); }
							}
							else { error("Bad value vor ip"); }
						}
					}
				}
				else {
					$HostResolved='*';
					if ($Debug) { debug("  DNS lookup by file asked for $Host but not found in DNS cache file.",4); }
				}
			}
			else {
				if ($Debug) { debug("  DNS lookup asked for $Host but this is not an IP address.",4); }
				$DNSLookupAlreadyDone=$LogFile;
			}
		}
		else {
			if ($Host =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) { $HostResolved='*'; $ip=4; }	# IPv4
			elsif ($Host =~ /^[0-9A-F]*:/i) { $HostResolved='*'; $ip=6; }						# IPv6
			if ($Debug) { debug("  No DNS lookup asked.",4); }
		}

		# Analyze: Country (Top-level domain)
		#------------------------------------
		my $Domain='ip';
		# Set $HostResolved to host and resolve Domain from it
		if ($HostResolved eq '*') {
			# $Host is an IP address and is not resolved (failed or not asked) or resolution gives an IP address
			$HostResolved = $Host;
			# Resolve Domain
			if ($PluginsLoaded{'GetCountryCodeByAddr'}{'geoipfree'}) { $Domain=GetCountryCodeByAddr_geoipfree($HostResolved); }
			elsif ($PluginsLoaded{'GetCountryCodeByAddr'}{'geoip'}) { $Domain=GetCountryCodeByAddr_geoip($HostResolved); }
		}
		else {
			# $Host has been resolved or was already a host name
			$HostResolved = lc($HostResolved?$HostResolved:$Host);
			# Resolve Domain
			if ($PluginsLoaded{'GetCountryCodeByName'}{'geoipfree'}) { $Domain=GetCountryCodeByName_geoipfree($HostResolved); }
			elsif ($PluginsLoaded{'GetCountryCodeByName'}{'geoip'}) { $Domain=GetCountryCodeByName_geoip($HostResolved); }
			elsif ($HostResolved =~ /\.(\w+)$/) { $Domain=$1; }
		}
		# Store country
		if ($PageBool) { $_domener_p{$Domain}++; }
		$_domener_h{$Domain}++;
		$_domener_k{$Domain}+=int($field[$pos_size]);

		# Analyze: Host, URL and Session
		#-------------------------------
		if ($PageBool) {
			my $timehostl=$_host_l{$HostResolved};
			if ($timehostl) {
				# A visit for this host was already detected
# TODO everywhere there is $VISITTIMEOUT
#				$timehostl =~ /^\d\d\d\d\d\d(\d\d)/; my $daytimehostl=$1;
#				if ($timerecord > ($timehostl+$VISITTIMEOUT+($dateparts[3]>$daytimehostl?$NEWDAYVISITTIMEOUT:0))) {
				if ($timerecord > ($timehostl+$VISITTIMEOUT)) {
					# This is a second visit or more
					if (! $_waithost_s{$HostResolved}) {
						# This is a second visit or more
						# We count 'visit','exit','entry','DayVisits'
						if ($Debug) { debug("  This is a second visit for $HostResolved.",4); }
						my $timehosts=$_host_s{$HostResolved};
						my $page=$_host_u{$HostResolved};
						if ($page) { $_url_x{$page}++; }
						$_url_e{$field[$pos_url]}++;
						$DayVisits{$yearmonthdayrecord}++;
						# We can't count session yet because we don't have the start so
						# we save save params of first 'wait' session
						$_waithost_l{$HostResolved}=$timehostl;
						$_waithost_s{$HostResolved}=$timehosts;
						$_waithost_u{$HostResolved}=$page;
					}
					else {
						# This is third visit or more
						# We count 'session','visit','exit','entry','DayVisits'
						if ($Debug) { debug("  This is a third visit or more for $HostResolved.",4); }
						my $timehosts=$_host_s{$HostResolved};
						my $page=$_host_u{$HostResolved};
						if ($page) { $_url_x{$page}++; }
						$_url_e{$field[$pos_url]}++;
						$DayVisits{$yearmonthdayrecord}++;
						if ($timehosts) { $_session{GetSessionRange($timehosts,$timehostl)}++; }
					}
					# Save new session properties
					$_host_s{$HostResolved}=$timerecord;
					$_host_l{$HostResolved}=$timerecord;
					$_host_u{$HostResolved}=$field[$pos_url];
				}
				elsif ($timerecord > $timehostl) {
					# This is a same visit we can count
					if ($Debug) { debug("  This is same visit still running for $HostResolved. host_l/host_u changed to $timerecord/$field[$pos_url]",4); }
					$_host_l{$HostResolved}=$timerecord;
					$_host_u{$HostResolved}=$field[$pos_url];
				}
				elsif ($timerecord == $timehostl) {
					# This is a same visit we can count
					if ($Debug) { debug("  This is same visit still running for $HostResolved. host_l/host_u changed to $timerecord/$field[$pos_url]",4); }
					$_host_u{$HostResolved}=$field[$pos_url];
				}
				elsif ($timerecord < $_host_s{$HostResolved}) {
					# Should happens only with not correctly sorted log files
					if ($Debug) { debug("  This is same visit still running for $HostResolved with start not in order. host_s changed to $timerecord",4); }
					if (! $_waithost_s{$HostResolved}) {
						# We can change entry page not yet counted as the save entry page was waithost_e if $_waithost_s{$HostResolved} is not defined
						$_waithost_e{$HostResolved}=$field[$pos_url];
					}
					else {
						# We can't change entry counted as we dont't know what was the url counted as entry
					}
					$_host_s{$HostResolved}=$timerecord;
				}
				else {
					if ($Debug) { debug("  This is same visit still running for $HostResolved with hit between start and last hits. No change",4); }
				}
			}
			else {
				# This is a new visit (may be). First new visit found for this host. We save in wait array the entry page to count later
				if ($Debug) { debug("  New session (may be) for $HostResolved. Save in wait array to see later",4); }
				$_waithost_e{$HostResolved}=$field[$pos_url];
				# Save new session properties
				$_host_u{$HostResolved}=$field[$pos_url];
				$_host_s{$HostResolved}=$timerecord;
				$_host_l{$HostResolved}=$timerecord;
			}
			$_host_p{$HostResolved}++;
		}
		$_host_h{$HostResolved}++;
		$_host_k{$HostResolved}+=int($field[$pos_size]);

		# Analyze: Browser and OS
		#------------------------
		if ($pos_agent >= 0 && $UserAgent) {

			if ($LevelForBrowsersDetection) {

				# Analyze: Browser
				#-----------------
				my $uabrowser=$TmpBrowser{$UserAgent};
				if (! $uabrowser) {
					my $found=1;
					# IE ?
					if (($UserAgent =~ /msie([+_ ]|)([\d\.]*)/i) && ($UserAgent !~ /webtv/i) && ($UserAgent !~ /omniweb/i) && ($UserAgent !~ /opera/i)) {
						$_browser_h{"msie$2"}++;
						$TmpBrowser{$UserAgent}="msie$2";
					}
					# Netscape ?
					elsif ($UserAgent =~ /netscape.?\/([\d\.]*)/i) {
						$_browser_h{"netscape$1"}++;
						$TmpBrowser{$UserAgent}="netscape$1";
					}
					elsif (($UserAgent =~ /mozilla(\/|)([\d\.]*)/i) && ($UserAgent !~ /compatible/i) && ($UserAgent !~ /opera/i) && ($UserAgent !~ /galeon/i) && ($UserAgent !~ /safari/i)) {
						$_browser_h{"netscape$2"}++;
						$TmpBrowser{$UserAgent}="netscape$2";
					}
					# Other ?
					else {
						$found=0;
						foreach my $key (@BrowsersSearchIDOrder) {	# Search ID in order of BrowsersSearchIDOrder
							if ($UserAgent =~ /$key/i) {
								$_browser_h{"$key"}++;
								$TmpBrowser{$UserAgent}="$key";
								$found=1;
								last;
							}
						}
					}
					# Unknown browser ?
					if (!$found) {
						$_browser_h{'Unknown'}++;
						$TmpBrowser{$UserAgent}='Unknown';
						my $newua=$UserAgent; $newua =~ tr/\+ /__/;
						$_unknownrefererbrowser_l{$newua}=$timerecord;
					}
				}
				else {
					$_browser_h{$uabrowser}++;
					if ($uabrowser eq 'Unknown') {
						my $newua=$UserAgent; $newua =~ tr/\+ /__/;
						$_unknownrefererbrowser_l{$newua}=$timerecord;
					}
				}

			}

			if ($LevelForOSDetection) {

				# Analyze: OS
				#------------
				my $uaos=$TmpOS{$UserAgent};
				if (! $uaos) {
					my $found=0;
					# in OSHashID list ?
					foreach my $key (@OSSearchIDOrder) {	# Search ID in order of OSSearchIDOrder
						if ($UserAgent =~ /$key/i) {
							my $osid=$OSHashID{$key};
							$_os_h{"$osid"}++;
							$TmpOS{$UserAgent}="$osid";
							$found=1;
							last;
						}
					}
					# Unknown OS ?
					if (!$found) {
						$_os_h{'Unknown'}++;
						$TmpOS{$UserAgent}='Unknown';
						my $newua=$UserAgent; $newua =~ tr/\+ /__/;
						$_unknownreferer_l{$newua}=$timerecord;
					}
				}
				else {
					$_os_h{$uaos}++;
					if ($uaos eq 'Unknown') {
						my $newua=$UserAgent; $newua =~ tr/\+ /__/;
						$_unknownreferer_l{$newua}=$timerecord;
					}
				}

			}

		}
		else {
			$_browser_h{'Unknown'}++;
			$_os_h{'Unknown'}++;
		}

		# Analyze: Referer
		#-----------------
		my $found=0;
		if ($pos_referer >= 0 && $LevelForRefererAnalyze && $field[$pos_referer]) {

			# Direct ?
			if ($field[$pos_referer] eq '-' || $field[$pos_referer] eq 'bookmarks') {	# "bookmarks" is sent by Netscape, '-' by all others browsers
				if ($PageBool) { $_from_p[0]++; }
				$_from_h[0]++;
				$found=1;
			}
			else {
				$field[$pos_referer] =~ /^(\w+):\/\/([^\/]+)/;
				my $refererprot=$1;
				my $refererserver=$2;

				# HTML link ?
				if ($refererprot =~ /^http/i) {

					# Kind of origin
					if (!$TmpRefererServer{$refererserver}) {
						if ($refererserver =~ /^(www\.|)$SiteToAnalyzeWithoutwww/i) {
							# Intern (This hit came from another page of the site)
							if ($Debug) { debug(" Server '$refererserver' is added to TmpRefererServer with value '='",2); }
							$TmpRefererServer{$refererserver}='=';
							$found=1;
						}
						else {
							foreach my $key (@HostAliases) {
								if ($refererserver =~ /^$key/i) {
									# Intern (This hit came from another page of the site)
									if ($Debug) { debug(" Server '$refererserver' is added to TmpRefererServer with value '='",2); }
									$TmpRefererServer{$refererserver}='=';
									$found=1;
									last;
								}
							}
							if (! $found) {
								# Extern (This hit came from an external web site).
	
								if ($LevelForSearchEnginesDetection) {
	
									foreach my $key (@SearchEnginesSearchIDOrder) {		# Search ID in order of SearchEnginesSearchIDOrder
										if ($refererserver =~ /$key/i) {
											# This hit came from the search engine $key
											if ($Debug) { debug(" Server '$refererserver' is added to TmpRefererServer with value '$key'",2); }
											$TmpRefererServer{$refererserver}="$key";
											$found=1;
											last;
										}
									}

								}
							}
						}
					}

					if ($TmpRefererServer{$refererserver}) {
						if ($TmpRefererServer{$refererserver} eq '=') {
							# Intern (This hit came from another page of the site)
							if ($PageBool) { $_from_p[4]++; }
							$_from_h[4]++;
							$found=1;
						}
						else {
							# This hit came from a search engine
							if ($PageBool) { $_from_p[2]++; $_se_referrals_p{$TmpRefererServer{$refererserver}}++; }
							$_from_h[2]++;
							$_se_referrals_h{$TmpRefererServer{$refererserver}}++;
							$found=1;
							my @refurl=split(/\?/,$field[$pos_referer],2);	# TODO Use \? or [$URLQuerySeparators] ?
							if ($refurl[1]) {
								# Extract keywords
								my @paramlist=split(/&/,$KeyWordsNotSensitive?lc($refurl[1]):$refurl[1]);
								if ($SearchEnginesKnownUrl{$TmpRefererServer{$refererserver}}) {	# Search engine with known URL syntax
									foreach my $param (@paramlist) {
										if ($param =~ s/^$SearchEnginesKnownUrl{$TmpRefererServer{$refererserver}}//) { 	# We found good parameter
											# Ok, "cache:mmm:www/zzz+aaa+bbb/ccc+ddd%20eee'fff,ggg" is a search parameter line
											$param =~ s/^cache:[^\+]*//;
											$param =~ s/^related:[^\+]*//;
											&ChangeWordSeparatorsIntoSpace($param);			# Change [ aaa+bbb/ccc+ddd%20eee'fff,ggg ] into [ aaa bbb/ccc ddd eee fff ggg]
											$param =~ s/^ +//; $param =~ s/ +$//; $param =~ tr/ /\+/s;
											if ((length $param) > 0) { $_keyphrases{$param}++; }
											last;
										}
									}
								}
								else {									# Search engine with unknown URL syntax
									foreach my $param (@paramlist) {
										my $foundexcludeparam=0;
										foreach my $paramtoexclude (@WordsToCleanSearchUrl) {
											if ($param =~ /$paramtoexclude/i) { $foundexcludeparam=1; last; } # Not the param with search criteria
										}
										if ($foundexcludeparam) { next; }		# Do not keep this URL parameter because is in exclude list
										$param =~ s/.*=//;						# Cut "xxx="
										# Ok, "cache:www/zzz aaa bbb/ccc ddd eee fff ggg" is a search parameter line
										$param =~ s/^cache:[^ ]*//;
										$param =~ s/^related:[^ ]*//;
										&ChangeWordSeparatorsIntoSpace($param);				# Change [ aaa+bbb/ccc+ddd%20eee'fff,ggg ] into [ aaa bbb/ccc ddd eee fff ggg ]
										$param =~ s/^ +//; $param =~ s/ +$//; $param =~ tr/ /\+/s;
										if ((length $param) > 2) { $_keyphrases{$param}++; last; }
									}
								}
							}	# End of if refurl[1]
						}
					}	# End of if ($TmpRefererServer)
					else {
						# This hit came from a site other than a search engine
						if ($PageBool) { $_from_p[3]++; }
						$_from_h[3]++;
						# http://www.mysite.com/ must be same referer than http://www.mysite.com but .../mypage/ differs of .../mypage
						#if ($refurl[0] =~ /^[^\/]+\/$/) { $field[$pos_referer] =~ s/\/$//; }	# Code moved in Save_History
						if ($URLReferrerWithQuery) {
							if ($PageBool) { $_pagesrefs_p{$field[$pos_referer]}++; }
							$_pagesrefs_h{$field[$pos_referer]}++;
						}
						else {
							if ($field[$pos_referer]=~/^([^$URLQuerySeparators]+)/) {
								if ($PageBool) { $_pagesrefs_p{"$1"}++; }
								$_pagesrefs_h{"$1"}++;
							}
							else {
								if ($PageBool) { $_pagesrefs_p{$field[$pos_referer]}++; }
								$_pagesrefs_h{$field[$pos_referer]}++;
							}
						}
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
			if ($ShowUnknownOrigin) { print "Unknown origin: $field[$pos_referer]\n"; }
			if ($PageBool) { $_from_p[1]++; }
			$_from_h[1]++;
		}

		# Analyze: EMail
		#---------------
		if ($pos_emails>=0 && $field[$pos_emails]) {
			if ($field[$pos_emails] eq '<>') { $field[$pos_emails]='Unknown'; }
			elsif ($field[$pos_emails] !~ /\@/) { $field[$pos_emails].="\@$SiteDomain"; }
			$_emails_h{lc($field[$pos_emails])}++;									#Count accesses for sender email (hit)
			$_emails_k{lc($field[$pos_emails])}+=int($field[$pos_size]);			#Count accesses for sender email (kb)
			$_emails_l{lc($field[$pos_emails])}=$timerecord;
		}
		if ($pos_emailr>=0 && $field[$pos_emailr]) {
			if ($field[$pos_emailr] !~ /\@/) { $field[$pos_emailr].="\@$SiteDomain"; }
			$_emailr_h{lc($field[$pos_emailr])}++;									#Count accesses for receiver email (hit)
			$_emailr_k{lc($field[$pos_emailr])}+=int($field[$pos_size]);			#Count accesses for receiver email (kb)
			$_emailr_l{lc($field[$pos_emailr])}=$timerecord;
		}

		# Analyze: Extra
		#---------------
 		foreach my $extranum (1..@ExtraName-1) {
			if ($Debug) { debug(" Process extra analyze $extranum",4); }

 			# Check conditions
 			my $conditionok=0;
 			foreach my $condnum (0..@{$ExtraConditionType[$extranum]}-1) {
 				my $conditiontype=$ExtraConditionType[$extranum][$condnum];
 				my $conditiontypeval=$ExtraConditionTypeVal[$extranum][$condnum];
 				if ($conditiontype eq 'URL') {
					if ($Debug) { debug(" Check condition '$conditiontype' must contain '$conditiontypeval' in $urlwithnoquery.",5); }
 					if ($urlwithnoquery =~ m/$conditiontypeval/) { $conditionok=1; last; }
 				}
 				elsif ($conditiontype eq 'QUERY_STRING') {
					if ($Debug) { debug(" Check condition '$conditiontype' must contain '$conditiontypeval' in $standalonequery.",5); }
 					if ($standalonequery =~ m/$conditiontypeval/) {	$conditionok=1; last; }
 				}
 				elsif ($conditiontype eq 'REFERER') {
					if ($Debug) { debug(" Check condition '$conditiontype' must contain '$conditiontypeval' in $field[$pos_referer]",5); }
 					if ($field[$pos_referer] =~ m/$conditiontypeval/) { $conditionok=1; last; }
 				}
 				else { error("Wrong value of parameter ExtraSectionCondition$extranum"); }
 			}
			if (! $conditionok && @{$ExtraConditionType[$extranum]}) { next; }	# End for this section
			
			if ($Debug) { debug(" No condition or Condition is OK. Now we extract value for first column of extra chart.",5); }
			
 			# Determine actual column value to use.
 			my $rowkeyval;
			my $rowkeyok=0;
 			foreach my $rowkeynum (0..@{$ExtraFirstColumnValuesType[$extranum]}-1) {
 				my $rowkeytype=$ExtraFirstColumnValuesType[$extranum][$rowkeynum];
 				my $rowkeytypeval=$ExtraFirstColumnValuesTypeVal[$extranum][$rowkeynum];
				if ($rowkeytype eq 'URL') { 
					if ($urlwithnoquery =~ m/$rowkeytypeval/) { $rowkeyval = "$1"; $rowkeyok = 1; last; }
				} 
 				elsif ($rowkeytype eq 'QUERY_STRING') {
 					if ($standalonequery =~ m/$rowkeytypeval/) { $rowkeyval = "$1"; $rowkeyok = 1; last; }
 				}
 				elsif ($rowkeytype eq 'REFERER') {
 					if ($field[$pos_referer] =~ m/$rowkeytypeval/) { $rowkeyval = "$1"; $rowkeyok = 1; last; }
 				}
 				else { error("Wrong value of parameter ExtraSectionFirstColumnValues$extranum"); }
 			}
			if (! $rowkeyok) { next; }	# End for this section
			if ($Debug) { debug(" Key val was found: $rowkeyval",5); }

 			# Here we got all values to increase counters
 			if ($PageBool && $ExtraStatTypes[$extranum] =~ /P/i) { ${'_section_' . $extranum . '_p'}{$rowkeyval}++; }
 			${'_section_' . $extranum . '_h'}{$rowkeyval}++;	# Must be set
 			if ($ExtraStatTypes[$extranum] =~ /B/i) { ${'_section_' . $extranum . '_k'}{$rowkeyval}+=int($field[$pos_size]); }
 			if ($ExtraStatTypes[$extranum] =~ /L/i) {
 				if (${'_section_' . $extranum . '_l'}{$rowkeyval}||0 < $timerecord) { ${'_section_' . $extranum . '_l'}{$rowkeyval}=$timerecord; }
 			}
			# Check to avoid too large extra sections
			if (scalar keys %{'_section_' . $extranum . '_h'} > $MAXDIFFEXTRA) {
				error("Too many (more than $MAXDIFFEXTRA) different values for row keys of extra section $extranum. Your setup is probably wrong.");
			}
 		}

		# Every 20,000 approved lines after a flush, we test to clean too large hash arrays to flush data in tmp file
		if (++$counterforflushtest >= 20000) {
		#if (++$counterforflushtest >= 1) {
			if ((scalar keys %_host_u) > ($LIMITFLUSH<<2) || (scalar keys %_url_p) > $LIMITFLUSH) {
				# warning("Warning: Try to run AWStats update process more frequently to analyze smaler log files.");
				if ($^X =~ /activestate/i || $^X =~ /activeperl/i) {
					# We don't flush if perl is activestate to avoid slowing process because of memory hole
				}
				else {
					# Clean tmp hash arrays
					#%TmpDNSLookup = ();
					%TmpOS = %TmpRefererServer = %TmpRobot = %TmpBrowser = ();
					# We flush if perl is not activestate
					print "Flush history file on disk";
					if ((scalar keys %_host_u) > ($LIMITFLUSH<<2)) { print " (unique hosts reach flush limit of ".($LIMITFLUSH<<2).")"; }
					if ((scalar keys %_url_p) > $LIMITFLUSH) { print " (unique url reach flush limit of ".($LIMITFLUSH).")"; }
					print "\n";
					if ($Debug) {
						debug("End of set of $counterforflushtest records: Some hash arrays are too large. We flush and clean some.",2);
						print " _host_p:".(scalar keys %_host_p)." _host_h:".(scalar keys %_host_h)." _host_k:".(scalar keys %_host_k)." _host_l:".(scalar keys %_host_l)." _host_s:".(scalar keys %_host_s)." _host_u:".(scalar keys %_host_u)."\n";
						print " _url_p:".(scalar keys %_url_p)." _url_k:".(scalar keys %_url_k)." _url_e:".(scalar keys %_url_e)." _url_x:".(scalar keys %_url_x)."\n";
						print " _waithost_e:".(scalar keys %_waithost_e)." _waithost_l:".(scalar keys %_waithost_l)." _waithost_s:".(scalar keys %_waithost_s)." _waithost_u:".(scalar keys %_waithost_u)."\n";
					}
					&Read_History_With_TmpUpdate($lastprocessedyear,$lastprocessedmonth,1,1,"all",($lastlinenumber+$NbOfLinesParsed),$lastlineoffset,&CheckSum($_));
					&GetDelaySinceStart(1);	$NbOfLinesShowsteps=1;
				}
			}
			$counterforflushtest=0;
		}

	}	# End of loop for processing new record.

	if ($Debug) {
		debug(" _host_p:".(scalar keys %_host_p)." _host_h:".(scalar keys %_host_h)." _host_k:".(scalar keys %_host_k)." _host_l:".(scalar keys %_host_l)." _host_s:".(scalar keys %_host_s)." _host_u:".(scalar keys %_host_u)."\n",1);
		debug(" _url_p:".(scalar keys %_url_p)." _url_k:".(scalar keys %_url_k)." _url_e:".(scalar keys %_url_e)." _url_x:".(scalar keys %_url_x)."\n",1);
		debug(" _waithost_e:".(scalar keys %_waithost_e)." _waithost_l:".(scalar keys %_waithost_l)." _waithost_s:".(scalar keys %_waithost_s)." _waithost_u:".(scalar keys %_waithost_u)."\n",1);
		debug("End of processing log file (AWStats memory cache is TmpDNSLookup=".(scalar keys %TmpDNSLookup)." TmpBrowser=".(scalar keys %TmpBrowser)." TmpOS=".(scalar keys %TmpOS)." TmpRefererServer=".(scalar keys %TmpRefererServer)." TmpRobot=".(scalar keys %TmpRobot).")",1);
	}

	# Save current processed month $lastprocessedmonth
	# If lastprocessedmonth > 0 means there is at least one approved new record in log or at least one existing history file
	if ($lastprocessedmonth) {	# TODO: Do not save if we are sure a flush was just already done
		# Get last line
		seek(LOG,$lastlineoffset,0);
		$_=<LOG>;
 		chomp $_; s/\r$//;
		&Read_History_With_TmpUpdate($lastprocessedyear,$lastprocessedmonth,1,1,"all",($lastlinenumber+$NbOfLinesParsed),$lastlineoffset,&CheckSum($_));
	}

	if ($Debug) { debug("Close log file \"$LogFile\""); }
	close LOG || error("Command for pipe '$LogFile' failed");

	# Process the Rename - Archive - Purge phase
	my $renameok=1; my $archiveok=1;

	# Open Log file for writing if PurgeLogFile is on
	if ($PurgeLogFile == 1) {
		if ($ArchiveLogRecords == 1) {
			$ArchiveFileName="$DirData/${PROG}_archive$FileSuffix.log";
			open(LOG,"+<$LogFile") || error("Enable to archive log records of \"$LogFile\" into \"$ArchiveFileName\" because source can't be opened for read and write: $!<br>\n");
		}
		else {
			open(LOG,"+<$LogFile");
		}
	}

	# Rename all HISTORYTMP files into HISTORYTXT
	&Rename_All_Tmp_History;

	# Purge Log file if option is on and all renaming are ok
	if ($PurgeLogFile == 1) {
		# Archive LOG file into ARCHIVELOG
		if ($ArchiveLogRecords == 1) {
			if ($Debug) { debug("Start of archiving log file"); }
			open(ARCHIVELOG,">>$ArchiveFileName") || error("Couldn't open file \"$ArchiveFileName\" to archive log: $!");
			while (<LOG>) {
				if (! print ARCHIVELOG $_) { $archiveok=0; last; }
			}
			close(ARCHIVELOG) || error("Archiving failed during closing archive: $!");
			if ($SaveDatabaseFilesWithPermissionsForEveryone) {	chmod 0666,"$ArchiveFileName"; }
			if ($Debug) { debug("End of archiving log file"); }
		}
		# If rename and archive ok
		if ($renameok && $archiveok) {
			if ($Debug) { debug("Purge log file"); }
			truncate(LOG,0) || warning("Warning: <b>$PROG</b> couldn't purge logfile \"<b>$LogFile</b>\".\nChange your logfile permissions to allow write for your web server CGI process or change PurgeLogFile=1 into PurgeLogFile=0 in configure file and think to purge sometines manually your logfile (just after running an update process to not loose any not already processed records your log file contains).");
		}
		close(LOG);
	}


	if ($DNSLookup && $DNSLookupAlreadyDone) {
		# DNSLookup warning
		my $bold=($ENV{'GATEWAY_INTERFACE'}?'<b>':'');
		my $unbold=($ENV{'GATEWAY_INTERFACE'}?'</b>':'');
		my $br=($ENV{'GATEWAY_INTERFACE'}?'<br>':'');
		warning("Warning: $bold$PROG$unbold has detected that some hosts names were already resolved in your logfile $bold$DNSLookupAlreadyDone$unbold.$br\nIf DNS lookup was already made by the logger (web server), you should change your setup DNSLookup=$DNSLookup into DNSLookup=0 to increase $PROG speed.");
	}
	if ($DNSLookup && $NbOfNewLines) {
		# Save new DNS last update cache file
		Save_DNS_Cache_File(\%TmpDNSLookup,"$DirData/$DNSLastUpdateCacheFile","$FileSuffix");	# Save into file using FileSuffix
	}

	if ($EnableLockForUpdate) {
		# Remove lock
		&Lock_Update(0);
		# Restore signals handler
		$SIG{INT} = 'DEFAULT';	# 2
		#$SIG{KILL} = 'DEFAULT';	# 9
		#$SIG{TERM} = 'DEFAULT';	# 15
	}

}
# End of log processing if ($UPdateStats)


#---------------------------------------------------------------------
# SHOW REPORT
#---------------------------------------------------------------------

if (scalar keys %HTMLOutput) {

	my $max_p; my $max_h; my $max_k; my $max_v;
	my $total_u; my $total_v; my $total_p; my $total_h; my $total_k; my $total_e; my $total_x; my $total_s;
	my $average_u; my $average_v; my $average_p; my $average_h; my $average_k; my $average_s;
	my $rest_p; my $rest_h; my $rest_k; my $rest_e; my $rest_x; my $rest_s;
	my $average_nb;

	# Define the NewLinkParams for main chart
	my $NewLinkParams=${QueryString};
	$NewLinkParams =~ s/(^|&)update(=\w*|$)//i;
	$NewLinkParams =~ s/(^|&)output(=\w*|$)//i;
	$NewLinkParams =~ s/(^|&)staticlinks(=\w*|$)//i;
	$NewLinkParams =~ s/(^|&)framename=[^&]*//i;
	my $NewLinkTarget='';
	if ($DetailedReportsOnNewWindows) { $NewLinkTarget=" target=\"awstatsbis\""; }
	if (($FrameName eq 'mainleft' || $FrameName eq 'mainright') && $DetailedReportsOnNewWindows < 2) {
		$NewLinkParams.="&framename=mainright";
		$NewLinkTarget=" target=\"mainright\"";
	}
	$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
	if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }

	# Call to plugins' function AddHTMLBodyHeader
	foreach my $pluginname (keys %{$PluginsLoaded{'AddHTMLBodyHeader'}})  {
		my $function="AddHTMLBodyHeader_$pluginname()";
		eval("$function");
	}

	if ($FrameName ne 'mainleft') {

		# READING DATA
		#-------------
		&Init_HashArray();

		# Loop on each month of year
		for (my $ix=12; $ix>=1; $ix--) {
			my $monthix=sprintf("%02s",$ix);
			if ($MonthRequired eq 'all' || $monthix eq $MonthRequired) {
				&Read_History_With_TmpUpdate($YearRequired,$monthix,0,0,"all");				# Read full history file
			}
			elsif (($HTMLOutput{'main'} && $ShowMonthStats) || $HTMLOutput{'alldays'}) {
				&Read_History_With_TmpUpdate($YearRequired,$monthix,0,0,"general time");	# Read general and time sections.
			}
		}
	}

	# HTMLHeadSection
	if ($FrameName ne 'index' && $FrameName ne 'mainleft') {
		print "<a name=\"TOP\">&nbsp;</a>\n\n";
		print "$HTMLHeadSection\n";
		print "\n";
	}

	# MENU
	#---------------------------------------------------------------------
	if ($ShowMenu || $FrameName eq 'mainleft') {
		if ($Debug) { debug("ShowMenu",2); }
		my $frame=($FrameName eq 'mainleft');
		print "$Center<a name=\"MENU\">&nbsp;</a>\n";

		my $WIDTHMENU1=150;
		
		if ($FrameName ne 'mainleft') {
			my $NewLinkParams=${QueryString};
			$NewLinkParams =~ s/(^|&)update(=\w*|$)//i;
			$NewLinkParams =~ s/(^|&)staticlinks(=\w*|$)//i;
			$NewLinkParams =~ s/(^|&)year=[^&]*//i;
			$NewLinkParams =~ s/(^|&)month=[^&]*//i;
			$NewLinkParams =~ s/(^|&)framename=[^&]*//i;
			$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
			my $NewLinkTarget='';
			if ($FrameName eq 'mainright') { $NewLinkTarget=" target=_parent"; }
			print "<FORM name=\"FormDateFilter\" action=\"$AWScript?${NewLinkParams}\" style=\"padding: 0px 0px 0px 0px; margin-top: 0\"$NewLinkTarget>\n";
		}

		print "<TABLE CLASS=\"TABLEFRAME\" BORDER=0 CELLPADDING=2 CELLSPACING=0 WIDTH=\"100%\">\n";
		print "<TR><TD>";
		print "<TABLE CLASS=\"TABLEDATA\" BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=\"100%\">\n";

#		if ($FrameName ne 'mainright' && $FrameName ne 'mainleft') { print "<table width=\"100%\"".($frame?" cellspacing=0 cellpadding=0 border=0":"").">\n"; }
#		else { print "<table width=\"100%\" bgcolor=#$color_TableBGTitle".($frame?" cellspacing=0 cellpadding=0 border=0":"").">\n"; }

		if ($FrameName ne 'mainright') {
			# Print Statistics Of
			if ($FrameName eq 'mainleft') { print "<tr><th class=AWL>$Message[7]:</th></tr><tr><td class=AWL><font style=\"font-size: 14px;\">$SiteDomain</font></td>"; }
			else { print "<tr><th class=AWL>$Message[7]:&nbsp;</th><td class=AWL><font style=\"font-size: 14px;\">$SiteDomain</font></td>"; }

			# Logo and flags
			if ($FrameName ne 'mainleft') {
				if ($LogoLink =~ "http://awstats.sourceforge.net") {
					print "<td align=right rowspan=3><a href=\"$LogoLink\" target=\"awstatshome\"><img src=\"$DirIcons/other/$Logo\" border=0 alt=\"".ucfirst($PROG)." Web Site\" title=\"".ucfirst($PROG)." Web Site\"></a>\n";
				}
				else {
					print "<td align=right rowspan=3><a href=\"$LogoLink\" target=\"awstatshome\"><img src=\"$DirIcons/other/$Logo\" border=0></a>\n";
				}
				if (! $StaticLinks) { print "<br>"; Show_Flag_Links($Lang); }
				print "</td>";
			}
			print  "</tr>\n";
		}
		if ($FrameName ne 'mainleft') {

			# Print Last Update
			print "<tr><th class=AWL valign=middle width=$WIDTHMENU1>$Message[35]:&nbsp;</th>";
			print "<td class=AWL valign=middle><font style=\"font-size: 14px;\">";
			if ($LastUpdate) { print Format_Date($LastUpdate,0); }
			else {
				# Here NbOfOldLines = 0 (because LastUpdate is defined)
				if (! $UpdateStats) { print "<font color=#880000>$Message[24]</font>"; }
				else { print "<font color=#880000>No qualified records found in log ($NbOfLinesCorrupted corrupted, $NbOfLinesDropped dropped)</font>"; }
				
			}
			print "</font>";
			# Print Update Now link
			if ($AllowToUpdateStatsFromBrowser && ! $StaticLinks) {
				my $NewLinkParams=${QueryString};
				$NewLinkParams =~ s/(^|&)update(=\w*|$)//i;
				$NewLinkParams =~ s/(^|&)staticlinks(=\w*|$)//i;
				$NewLinkParams =~ s/(^|&)framename=[^&]*//i;
				if ($FrameName eq 'mainright') { $NewLinkParams.="&framename=mainright"; }
				$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
				if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }
				print "&nbsp; &nbsp; &nbsp; &nbsp;";
				print "<a href=\"$AWScript?${NewLinkParams}update=1\">$Message[74]</a>";
			}
			print "</td>";

			# Logo and flags
			if ($FrameName eq 'mainright') {
				if ($LogoLink =~ "http://awstats.sourceforge.net") {
					print "<td align=right rowspan=2><a href=\"$LogoLink\" target=\"awstatshome\"><img src=\"$DirIcons/other/$Logo\" border=0 alt=\"".ucfirst($PROG)." Web Site\" title=\"".ucfirst($PROG)." Web Site\"></a>\n";
				}
				else {
					print "<td align=right rowspan=2><a href=\"$LogoLink\" target=\"awstatshome\"><img src=\"$DirIcons/other/$Logo\" border=0></a>\n";
				}
				if (! $StaticLinks) { print "<br>"; Show_Flag_Links($Lang); }
				print "</td>";
			}

			print "</tr>\n";
			# Print selected period of analysis (month and year required)
			print "<tr><th class=AWL valign=middle>$Message[133]:</th>";
			print "<td class=AWL valign=middle>";
			if ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) {
				print "<select class=CFormFields name=\"month\">\n";
				foreach my $ix (1..12) { my $monthix=sprintf("%02s",$ix); print "<option".($MonthRequired eq "$monthix"?" selected":"")." value=\"$monthix\">$MonthLib{$monthix}\n"; }
				print "<option".($MonthRequired eq 'all'?" selected":"")." value='all'>-\n";
				print "</select>\n";
				print "<select class=CFormFields name=\"year\">\n";
				# Add YearRequired in list if not in ListOfYears
				$ListOfYears{$YearRequired}||=$MonthRequired;
				foreach my $key (sort keys %ListOfYears) { print "<option".($YearRequired eq "$key"?" selected":"")." value=\"$key\">$key\n"; }
				print "</select>\n";
				print "<input type=hidden name=\"output\" value=\"".join(',',keys %HTMLOutput)."\">\n";
				if ($SiteConfig) { print "<input type=hidden name=\"config\" value=\"$SiteConfig\">\n"; }
				if ($QueryString =~ /lang=(\w+)/i) { print "<input type=hidden name=\"lang\" value=\"$1\">\n"; }
				if ($QueryString =~ /debug=(\d+)/i) { print "<input type=hidden name=\"debug\" value=\"$1\">\n"; }
				if ($FrameName eq 'mainright') { print "<input type=hidden name=\"framename\" value=\"index\">\n"; }
				print "<input type=submit value=\"OK\" class=\"CFormFields\">";
			}
			else {
				print "<font style=\"font-size: 14px;\">";
				if ($MonthRequired eq 'all') { print "$Message[6] $YearRequired"; }
				else { print "$Message[5] $MonthLib{$MonthRequired} $YearRequired"; }
				print "</font>";
			}
			print "</td></tr>\n";
		}
		print "</TABLE>\n";

		print "</TD></TR></TABLE>\n";

		if ($FrameName ne 'mainleft') {	print "</FORM>\n"; }
		else { print "<br>\n"; }
		print "\n";

		# Print menu links
		if (($HTMLOutput{'main'} && $FrameName ne 'mainright') || $FrameName eq 'mainleft') {	# If main page asked
			my $linkanchor=($FrameName eq 'mainleft'?"$AWScript?${NewLinkParams}":"");
			if ($linkanchor && ($linkanchor !~ /framename=mainright/)) { $linkanchor.="framename=mainright"; }
			$linkanchor =~ s/&$//;
			my $targetpage=($FrameName eq 'mainleft'?" target=mainright":"");
			my $linetitle=1;
			print "<table".($frame?" cellspacing=0 cellpadding=0 border=0":"").">\n";
			# When
			$linetitle=&AtLeastOneNotNull($ShowMonthStats,$ShowDaysOfMonthStats,$ShowDaysOfWeekStats,$ShowHoursStats);
			if ($linetitle) { print "<tr><th class=AWL width=$WIDTHMENU1>$Message[93]: </th>\n"; }
			if ($linetitle) { print ($frame?"</tr>\n":"<td class=AWL>"); }
			if ($ShowMonthStats)		 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#TOP\"$targetpage>$Message[128]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			#if ($ShowMonthDayStats)	 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=alldays":"$PROG$StaticLinks.alldays.html")."\"$NewLinkTarget>$Message[130]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowDaysOfMonthStats)	 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#DAYOFMONTH\"$targetpage>$Message[138]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowDaysOfWeekStats)	 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#DAYOFWEEK\"$targetpage>$Message[91]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowHoursStats)		 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#HOUR\"$targetpage>$Message[20]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($linetitle) { print ($frame?"":"</td></tr>\n"); }
			# Who
			$linetitle=&AtLeastOneNotNull($ShowDomainsStats,$ShowHostsStats,$ShowAuthenticatedUsers,$ShowEMailSenders,$ShowEMailReceivers,$ShowRobotsStats,$ShowWormsStats);
			if ($linetitle) { print "<tr><th class=AWL>$Message[92]: </th>\n"; }
			if ($linetitle) { print ($frame?"</tr>\n":"<td class=AWL>"); }
			if ($ShowDomainsStats)		 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#DOMAINS\"$targetpage>$Message[17]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowDomainsStats)		 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=alldomains":"$PROG$StaticLinks.alldomains.html")."\"$NewLinkTarget>$Message[80]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowHostsStats)		 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#VISITOR\"$targetpage>".ucfirst($Message[81])."</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowHostsStats)		 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=allhosts":"$PROG$StaticLinks.allhosts.html")."\"$NewLinkTarget>$Message[80]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowHostsStats =~ /L/i) { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=lasthosts":"$PROG$StaticLinks.lasthosts.html")."\"$NewLinkTarget>$Message[9]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowHostsStats)		 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=unknownip":"$PROG$StaticLinks.unknownip.html")."\"$NewLinkTarget>$Message[45]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowAuthenticatedUsers) { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#LOGIN\"$targetpage>$Message[94]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowAuthenticatedUsers) { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=alllogins":"$PROG$StaticLinks.alllogins.html")."\"$NewLinkTarget>$Message[80]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowAuthenticatedUsers =~ /L/i)	{ print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=lastlogins":"$PROG$StaticLinks.lastlogins.html")."\"$NewLinkTarget>$Message[9]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowEMailSenders)		 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#EMAILSENDERS\"$targetpage>$Message[131]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowEMailSenders)		 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=allemails":"$PROG$StaticLinks.allemails.html")."\"$NewLinkTarget>$Message[80]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowEMailSenders =~ /L/i)	{ print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=lastemails":"$PROG$StaticLinks.lastemails.html")."\"$NewLinkTarget>$Message[9]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowEMailReceivers)	 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#EMAILRECEIVERS\"$targetpage>$Message[132]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowEMailReceivers)	 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=allemailr":"$PROG$StaticLinks.allemailr.html")."\"$NewLinkTarget>$Message[80]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowEMailReceivers =~ /L/i)	{ print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=lastemailr":"$PROG$StaticLinks.lastemailr.html")."\"$NewLinkTarget>$Message[9]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowRobotsStats)		 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#ROBOTS\"$targetpage>$Message[53]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowRobotsStats) 		 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=allrobots":"$PROG$StaticLinks.allrobots.html")."\"$NewLinkTarget>$Message[80]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowRobotsStats =~ /L/i)	{ print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=lastrobots":"$PROG$StaticLinks.lastrobots.html")."\"$NewLinkTarget>$Message[9]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
#			if ($ShowWormsStats)		 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#WORMS\"$targetpage>$Message[136]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
#			if ($ShowWormsStats) 		 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=allworms":"$PROG$StaticLinks.allworms.html")."\"$NewLinkTarget>$Message[80]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
#			if ($ShowWormsStats =~ /L/i)	{ print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=lastworms":"$PROG$StaticLinks.lastworms.html")."\"$NewLinkTarget>$Message[9]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($linetitle) { print ($frame?"":"</td></tr>\n"); }
			# Navigation
			$linetitle=&AtLeastOneNotNull($ShowSessionsStats,$ShowPagesStats,$ShowFileTypesStats,$ShowFileSizesStats,$ShowOSStats,$ShowBrowsersStats,$ShowScreenSizeStats);
			if ($linetitle) { print "<tr><th class=AWL>$Message[72]: </th>\n"; }
			if ($linetitle) { print ($frame?"</tr>\n":"<td class=AWL>"); }
			if ($ShowSessionsStats)		 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#SESSIONS\"$targetpage>$Message[117]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowFileTypesStats)	 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#FILETYPES\"$targetpage>$Message[73]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowPagesStats)		 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#PAGE\"$targetpage>$Message[29]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowPagesStats)		 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=urldetail":"$PROG$StaticLinks.urldetail.html")."\"$NewLinkTarget>$Message[80]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowPagesStats =~ /E/i)	{ print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=urlentry":"$PROG$StaticLinks.urlentry.html")."\"$NewLinkTarget>$Message[104]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowPagesStats =~ /X/i)	{ print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=urlexit":"$PROG$StaticLinks.urlexit.html")."\"$NewLinkTarget>$Message[116]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowOSStats)			 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#OS\"$targetpage>$Message[59]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowOSStats)		 	 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=osdetail":"$PROG$StaticLinks.osdetail.html")."\"$NewLinkTarget>$Message[58]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowOSStats)			 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=unknownos":"$PROG$StaticLinks.unknownos.html")."\"$NewLinkTarget>$Message[0]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowBrowsersStats)		 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#BROWSER\"$targetpage>$Message[21]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowBrowsersStats)		 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=browserdetail":"$PROG$StaticLinks.browserdetail.html")."\"$NewLinkTarget>$Message[58]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowBrowsersStats)		 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=unknownbrowser":"$PROG$StaticLinks.unknownbrowser.html")."\"$NewLinkTarget>$Message[0]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowScreenSizeStats)	 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#SCREENSIZE\"$targetpage>$Message[135]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($linetitle) { print ($frame?"":"</td></tr>\n"); }
			# Referers
			$linetitle=&AtLeastOneNotNull($ShowOriginStats,$ShowKeyphrasesStats,$ShowKeywordsStats);
			if ($linetitle) { print "<tr><th class=AWL>$Message[23]: </th>\n"; }
			if ($linetitle) { print ($frame?"</tr>\n":"<td class=AWL>"); }
			if ($ShowOriginStats)		 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#REFERER\"$targetpage>$Message[37]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowOriginStats)		 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=refererse":"$PROG$StaticLinks.refererse.html")."\"$NewLinkTarget>$Message[126]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowOriginStats)		 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=refererpages":"$PROG$StaticLinks.refererpages.html")."\"$NewLinkTarget>$Message[127]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowKeyphrasesStats || $ShowKeywordsStats)	 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#KEYS\"$targetpage>$Message[14]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowKeyphrasesStats)	 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=keyphrases":"$PROG$StaticLinks.keyphrases.html")."\"$NewLinkTarget>$Message[120]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowKeywordsStats)	 	 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=keywords":"$PROG$StaticLinks.keywords.html")."\"$NewLinkTarget>$Message[121]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($linetitle) { print ($frame?"":"</td></tr>\n"); }
			# Others
			$linetitle=&AtLeastOneNotNull($ShowFileTypesStats=~/C/i,$ShowHTTPErrorsStats);
			if ($linetitle) { print "<tr><th class=AWL>$Message[2]: </th>\n"; }
			if ($linetitle) { print ($frame?"</tr>\n":"<td class=AWL>"); }
			if ($ShowFileTypesStats =~ /C/i)	 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#FILETYPES\"$targetpage>$Message[98]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			if ($ShowHTTPErrorsStats)	 { print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#ERRORS\"$targetpage>$Message[22]</a>"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			foreach my $code (keys %TrapInfosForHTTPErrorCodes) {
				if ($ShowHTTPErrorsStats)	 { print ($frame?"<tr><td class=AWL> &nbsp; <img height=8 width=9 src=\"$DirIcons/other/page.png\" alt=\"...\"> ":""); print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=errors$code":"$PROG$StaticLinks.errors$code.html")."\"$NewLinkTarget>$Message[31]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; "); }
			}
			if ($linetitle) { print ($frame?"":"</td></tr>\n"); }
			# Extra/Marketing
		 	$linetitle=&AtLeastOneNotNull(@ExtraStatTypes);
			if ($linetitle) { print "<tr><th class=AWL>$Message[134]: </th>\n"; }
			if ($linetitle) { print ($frame?"</tr>\n":"<td class=AWL>"); }
			foreach my $extranum (1..@ExtraName-1) {
				print ($frame?"<tr><td class=AWL>":""); print "<a href=\"$linkanchor#EXTRA$extranum\"$targetpage>$ExtraName[$extranum]</a>\n"; print ($frame?"</td></tr>\n":" &nbsp; ");
			}
			if ($linetitle) { print ($frame?"":"</td></tr>\n"); }
			print "</table>\n";
			print ($frame?"":"<br>\n");

		}
		# Print Back link
		elsif (! $HTMLOutput{'main'}) {
			print "<table>\n";
			$NewLinkParams =~ s/(^|&)hostfilter=[^&]*//i;
			$NewLinkParams =~ s/(^|&)urlfilter=[^&]*//i;
			$NewLinkParams =~ s/(^|&)refererpagesfilter=[^&]*//i;
			$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/&$//;
			if (! $DetailedReportsOnNewWindows || $FrameName eq 'mainright') {
				print "<tr><td class=AWL><a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript".(${NewLinkParams}?"?${NewLinkParams}":""):"$PROG$StaticLinks.html")."\">$Message[76]</a></td></tr>\n";
			}
			else {
				print "<tr><td class=AWL><a href=\"javascript:parent.window.close();\">$Message[118]</a></td></tr>\n";
			}
			print "</table>\n";
			print "\n";
		}
	}

	# Exit if left frame
	if ($FrameName eq 'mainleft') {
		&html_end;
		exit 0;
	}

	# FirstTime LastTime TotalVisits TotalUnique TotalPages TotalHits TotalBytes TotalHostsKnown TotalHostsUnknown
	my $FirstTime=0;
	my $LastTime=0;
	$TotalUnique=$TotalVisits=$TotalPages=$TotalHits=$TotalBytes=$TotalHostsKnown=$TotalHostsUnknown=0;
	my $beginmonth=$MonthRequired;my $endmonth=$MonthRequired;
	if ($MonthRequired eq 'all') { $beginmonth=1;$endmonth=12; }
	for (my $month=$beginmonth; $month<=$endmonth; $month++) {
		my $monthix=sprintf("%02s",$month);
		if ($FirstTime{$YearRequired.$monthix} && ($FirstTime == 0 || $FirstTime > $FirstTime{$YearRequired.$monthix})) { $FirstTime = $FirstTime{$YearRequired.$monthix}; }
		if ($LastTime < $LastTime{$YearRequired.$monthix}) { $LastTime = $LastTime{$YearRequired.$monthix}; }
		$TotalVisits+=$MonthVisits{$YearRequired.$monthix}||0;
		$TotalPages+=$MonthPages{$YearRequired.$monthix}||0;
		$TotalHits+=$MonthHits{$YearRequired.$monthix}||0;
		$TotalBytes+=$MonthBytes{$YearRequired.$monthix}||0;
		$TotalUnique+=$MonthUnique{$YearRequired.$monthix}||0;				# Wrong in year view
		$TotalHostsKnown+=$MonthHostsKnown{$YearRequired.$monthix}||0;		# Wrong in year view
		$TotalHostsUnknown+=$MonthHostsUnknown{$YearRequired.$monthix}||0;	# Wrong in year view
	}
	# TotalHitsErrors TotalBytesErrors
	my $TotalHitsErrors=0; my $TotalBytesErrors=0;
	foreach my $key (keys %_errors_h) { $TotalHitsErrors+=$_errors_h{$key}; $TotalBytesErrors+=$_errors_k{$key}; }
	# TotalEntries (if not already specifically counted, we init it from _url_e hash table)
	if (!$TotalEntries) { foreach my $key (keys %_url_e) { $TotalEntries+=$_url_e{$key}; } }
	# TotalExits (if not already specifically counted, we init it from _url_x hash table)
	if (!$TotalExits) { foreach my $key (keys %_url_x) { $TotalExits+=$_url_x{$key}; } }
	# TotalBytesPages (if not already specifically counted, we init it from _url_k hash table)
	if (!$TotalBytesPages) { foreach my $key (keys %_url_k) { $TotalBytesPages+=$_url_k{$key}; } }
	# TotalKeyphrases (if not already specifically counted, we init it from _keyphrases hash table)
	if (!$TotalKeyphrases) { foreach my $key (keys %_keyphrases) { $TotalKeyphrases+=$_keyphrases{$key}; } }
	# TotalKeywords (if not already specifically counted, we init it from _keywords hash table)
	if (!$TotalKeywords) { foreach my $key (keys %_keywords) { $TotalKeywords+=$_keywords{$key}; } }
	# TotalSearchEnginesPages (if not already specifically counted, we init it from _se_referrals_p hash table)
	if (!$TotalSearchEnginesPages) { foreach my $key (keys %_se_referrals_p) { $TotalSearchEnginesPages+=$_se_referrals_p{$key}; } }
	# TotalSearchEnginesHits (if not already specifically counted, we init it from _se_referrals_h hash table)
	if (!$TotalSearchEnginesHits) { foreach my $key (keys %_se_referrals_h) { $TotalSearchEnginesHits+=$_se_referrals_h{$key}; } }
	# TotalRefererPages (if not already specifically counted, we init it from _pagesrefs_p hash table)
	if (!$TotalRefererPages) { foreach my $key (keys %_pagesrefs_p) { $TotalRefererPages+=$_pagesrefs_p{$key}; } }
	# TotalRefererHits (if not already specifically counted, we init it from _pagesrefs_h hash table)
	if (!$TotalRefererHits) { foreach my $key (keys %_pagesrefs_h) { $TotalRefererHits+=$_pagesrefs_h{$key}; } }
	# TotalDifferentPages (if not already specifically counted, we init it from _url_p hash table)
	$TotalDifferentPages||=scalar keys %_url_p;
	# TotalDifferentKeyphrases (if not already specifically counted, we init it from _keyphrases hash table)
	$TotalDifferentKeyphrases||=scalar keys %_keyphrases;
	# TotalDifferentKeywords (if not already specifically counted, we init it from _keywords hash table)
	$TotalDifferentKeywords||=scalar keys %_keywords;
	# TotalDifferentSearchEngines (if not already specifically counted, we init it from _se_referrals_h hash table)
	$TotalDifferentSearchEngines||=scalar keys %_se_referrals_h;
	# TotalDifferentReferer (if not already specifically counted, we init it from _pagesrefs_h hash table)
	$TotalDifferentReferer||=scalar keys %_pagesrefs_h;

	# Define firstdaytocountaverage, lastdaytocountaverage, firstdaytoshowtime, lastdaytoshowtime
	my $firstdaytocountaverage=$nowyear.$nowmonth."01";				# Set day cursor to 1st day of month
	my $firstdaytoshowtime=$nowyear.$nowmonth."01";					# Set day cursor to 1st day of month
	my $lastdaytocountaverage=$nowyear.$nowmonth.$nowday;			# Set day cursor to today
	my $lastdaytoshowtime=$nowyear.$nowmonth."31";					# Set day cursor to last day of month
	if ($MonthRequired eq 'all') {
		$firstdaytocountaverage=$YearRequired."0101";				# Set day cursor to 1st day of the required year
	}
	if (($MonthRequired ne $nowmonth && $MonthRequired ne 'all') || $YearRequired ne $nowyear) {
		if ($MonthRequired eq 'all') {
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
	if ($Debug) {
		debug("firstdaytocountaverage=$firstdaytocountaverage, lastdaytocountaverage=$lastdaytocountaverage",1);
		debug("firstdaytoshowtime=$firstdaytoshowtime, lastdaytoshowtime=$lastdaytoshowtime",1);
	}

	# Output particular part

#	if ($HTMLOutput{'alldays'}) {
#		if ($Debug) { debug("ShowMonthDayStats",2); }
#		print "$Center<a name=\"MONTHDAY\">&nbsp;</a><BR>\n";
#		&tab_head("$Message[5]",0);
#
#		my $NewLinkParams=${QueryString};
#		$NewLinkParams =~ s/(^|&)update(=\w*|$)//i;
#		$NewLinkParams =~ s/(^|&)staticlinks(=\w*|$)//i;
#		$NewLinkParams =~ s/(^|&)year=[^&]*//i;
#		$NewLinkParams =~ s/(^|&)month=[^&]*//i;
#		$NewLinkParams =~ s/(^|&)framename=[^&]*//i;
#		$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
#		if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }
#		my $NewLinkTarget="";
#		if ($FrameName eq 'mainright') { $NewLinkTarget=" target=_parent"; }
#
#		# Show monthly stats
#		print "<TR valign=bottom><TD align=center>";
#		print "<CENTER>";
#
#		print "<TABLE>";
#		print "<TR valign=bottom><td></td>";
#		$max_v=$max_p=$max_h=$max_k=1;
#		for (my $ix=1; $ix<=12; $ix++) {
#			my $monthix=sprintf("%02s",$ix);
#			#if ($MonthUnique{$YearRequired.$monthix} > $max_v) { $max_v=$MonthUnique{$YearRequired.$monthix}; }
#			if ($MonthVisits{$YearRequired.$monthix} > $max_v) { $max_v=$MonthVisits{$YearRequired.$monthix}; }
#			#if ($MonthPages{$YearRequired.$monthix} > $max_p)  { $max_p=$MonthPages{$YearRequired.$monthix}; }
#			if ($MonthHits{$YearRequired.$monthix} > $max_h)   { $max_h=$MonthHits{$YearRequired.$monthix}; }
#			if ($MonthBytes{$YearRequired.$monthix} > $max_k)  { $max_k=$MonthBytes{$YearRequired.$monthix}; }
#		}
#		for (my $ix=1; $ix<=12; $ix++) {
#			my $monthix=sprintf("%02s",$ix);
#			my $bredde_u=0; my $bredde_v=0;my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
#			if ($max_v > 0) { $bredde_u=int($MonthUnique{$YearRequired.$monthix}/$max_v*$BarHeight)+1; }
#			if ($max_v > 0) { $bredde_v=int($MonthVisits{$YearRequired.$monthix}/$max_v*$BarHeight)+1; }
#			if ($max_h > 0) { $bredde_p=int($MonthPages{$YearRequired.$monthix}/$max_h*$BarHeight)+1; }
#			if ($max_h > 0) { $bredde_h=int($MonthHits{$YearRequired.$monthix}/$max_h*$BarHeight)+1; }
#			if ($max_k > 0) { $bredde_k=int($MonthBytes{$YearRequired.$monthix}/$max_k*$BarHeight)+1; }
#			print "<TD>";
#			if ($ShowMonthDayStats =~ /U/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_u\" HEIGHT=$bredde_u WIDTH=8 ALT=\"$Message[11]: $MonthUnique{$YearRequired.$monthix}\" title=\"$Message[11]: $MonthUnique{$YearRequired.$monthix}\">"; }
#			if ($ShowMonthDayStats =~ /V/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=8 ALT=\"$Message[10]: $MonthVisits{$YearRequired.$monthix}\" title=\"$Message[10]: $MonthVisits{$YearRequired.$monthix}\">"; }
#			print "&nbsp;";
#			if ($ShowMonthDayStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=8 ALT=\"$Message[56]: $MonthPages{$YearRequired.$monthix}\" title=\"$Message[56]: $MonthPages{$YearRequired.$monthix}\">"; }
#			if ($ShowMonthDayStats =~ /H/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=8 ALT=\"$Message[57]: $MonthHits{$YearRequired.$monthix}\" title=\"$Message[57]: $MonthHits{$YearRequired.$monthix}\">"; }
#			if ($ShowMonthDayStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=8 ALT=\"$Message[75]: ".Format_Bytes($MonthBytes{$YearRequired.$monthix})."\" title=\"$Message[75]: ".Format_Bytes($MonthBytes{$YearRequired.$monthix})."\">"; }
#			print "</TD>\n";
#		}
#		print "</TR>\n";
#		# Show lib for month
#		print "<TR valign=middle cellspacing=0 cellpadding=0><td></td>";
#		for (my $ix=1; $ix<=12; $ix++) {
#			my $monthix=($ix<10?"0$ix":"$ix");
#			print "<TD>";
#			if (($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) && ! $HTMLOutput{'alldays'}) { print "<a href=\"$AWScript?${NewLinkParams}year=$YearRequired&month=$monthix\"$NewLinkTarget>"; }
#			print "$MonthLib{$monthix}";
#			if (($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) && ! $HTMLOutput{'alldays'}) { print "</a>"; }
#			print "</TD>\n";
#		}
#		print "</TR>\n";
#		print "</TABLE>\n<br>\n";
#
#		# Show data array for month
#		print "<TABLE>\n";
#		print "<TR><TD width=\"15%\" bgcolor=\"#$color_TableBGRowTitle\">$Message[5]</TD>";
#		if ($ShowMonthDayStats =~ /U/i) { print "<TD width=\"17%\" bgcolor=\"#$color_u\" onmouseover=\"ShowTip(2);\" onmouseout=\"HideTip(2);\">$Message[11]</TD>"; }
#		if ($ShowMonthDayStats =~ /V/i) { print "<TD width=\"17%\" bgcolor=\"#$color_v\" onmouseover=\"ShowTip(1);\" onmouseout=\"HideTip(1);\">$Message[10]</TD>"; }
#		if ($ShowMonthDayStats =~ /P/i) { print "<TD width=\"17%\" bgcolor=\"#$color_p\" onmouseover=\"ShowTip(3);\" onmouseout=\"HideTip(3);\">$Message[56]</TD>"; }
#		if ($ShowMonthDayStats =~ /H/i) { print "<TD width=\"17%\" bgcolor=\"#$color_h\" onmouseover=\"ShowTip(4);\" onmouseout=\"HideTip(4);\">$Message[57]</TD>"; }
#		if ($ShowMonthDayStats =~ /B/i) { print "<TD width=\"17%\" bgcolor=\"#$color_k\" onmouseover=\"ShowTip(5);\" onmouseout=\"HideTip(5);\">$Message[75]</TD>"; }
#		print "</TR>\n";
#		for (my $ix=1; $ix<=12; $ix++) {
#			my $monthix=($ix<10?"0$ix":"$ix");
#			print "<TR>";
#			print "<TD>",$MonthLib{$monthix},"</TD>";
#			if ($ShowMonthDayStats =~ /U/i) { print "<TD>",$MonthUnique{$YearRequired.$monthix}?$MonthUnique{$YearRequired.$monthix}:"0","</TD>"; }
#			if ($ShowMonthDayStats =~ /V/i) { print "<TD>",$MonthVisits{$YearRequired.$monthix}?$MonthVisits{$YearRequired.$monthix}:"0","</TD>"; }
#			if ($ShowMonthDayStats =~ /P/i) { print "<TD>",$MonthPages{$YearRequired.$monthix}?$MonthPages{$YearRequired.$monthix}:"0","</TD>"; }
#			if ($ShowMonthDayStats =~ /H/i) { print "<TD>",$MonthHits{$YearRequired.$monthix}?$MonthHits{$YearRequired.$monthix}:"0","</TD>"; }
#			if ($ShowMonthDayStats =~ /B/i) { print "<TD>",Format_Bytes(int($MonthBytes{$YearRequired.$monthix})),"</TD>"; }
#			print "</TR>\n";
#		}
#		print "</TABLE>\n<br>";
#
#		print "</CENTER>\n";
#		print "</TD></TR>\n";
#		&tab_end;
#
#		print "<br>\n";
#
#		&tab_head("$Message[4]",0);
#		print "<TR valign=bottom><TD align=center>";
#		print "<CENTER>";
#
#		print "<TABLE>";
#		print "<TR valign=bottom><td></td>";
#		# Get max_v, max_h and max_k values
#		$max_v=$max_h=$max_k=0;		# Start from 0 because can be lower than 1
#		foreach my $daycursor ($firstdaytoshowtime..$lastdaytoshowtime) {
#			$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
#			my $year=$1; my $month=$2; my $day=$3;
#			if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
#			if (($DayVisits{$year.$month.$day}||0) > $max_v)  { $max_v=$DayVisits{$year.$month.$day}; }
#			#if (($DayPages{$year.$month.$day}||0) > $max_p)  { $max_p=$DayPages{$year.$month.$day}; }
#			if (($DayHits{$year.$month.$day}||0) > $max_h)   { $max_h=$DayHits{$year.$month.$day}; }
#			if (($DayBytes{$year.$month.$day}||0) > $max_k)  { $max_k=$DayBytes{$year.$month.$day}; }
#		}
#		# Calculate average values
#		my $average_nb=0; my $average_v=0; my $average_p=0; my $average_h=0; my $average_k=0;
#		foreach my $daycursor ($firstdaytocountaverage..$lastdaytocountaverage) {
#			$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
#			my $year=$1; my $month=$2; my $day=$3;
#			if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
#			$average_nb++;											# Increase number of day used to count
#			$average_v+=($DayVisits{$daycursor}||0);
#			$average_p+=($DayPages{$daycursor}||0);
#			$average_h+=($DayHits{$daycursor}||0);
#			$average_k+=($DayBytes{$daycursor}||0);
#		}
#		if ($average_nb) {
#			$average_v=$average_v/$average_nb;
#			$average_p=$average_p/$average_nb;
#			$average_h=$average_h/$average_nb;
#			$average_k=$average_k/$average_nb;
#			if ($average_v > $max_v) { $max_v=$average_v; }
#			#if ($average_p > $max_p) { $max_p=$average_p; }
#			if ($average_h > $max_h) { $max_h=$average_h; }
#			if ($average_k > $max_k) { $max_k=$average_k; }
#		}
#		else {
#			$average_v="?";
#			$average_p="?";
#			$average_h="?";
#			$average_k="?";
#		}
#		foreach my $daycursor ($firstdaytoshowtime..$lastdaytoshowtime) {
#			$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
#			my $year=$1; my $month=$2; my $day=$3;
#			if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
#			my $bredde_v=0; my $bredde_p=0; my $bredde_h=0; my $bredde_k=0;
#			if ($max_v > 0) { $bredde_v=int(($DayVisits{$year.$month.$day}||0)/$max_v*$BarHeight)+1; }
#			if ($max_h > 0) { $bredde_p=int(($DayPages{$year.$month.$day}||0)/$max_h*$BarHeight)+1; }
#			if ($max_h > 0) { $bredde_h=int(($DayHits{$year.$month.$day}||0)/$max_h*$BarHeight)+1; }
#			if ($max_k > 0) { $bredde_k=int(($DayBytes{$year.$month.$day}||0)/$max_k*$BarHeight)+1; }
#			print "<TD>";
#			if ($ShowMonthDayStats =~ /V/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=4 ALT=\"$Message[10]: ".int($DayVisits{$year.$month.$day}||0)."\" title=\"$Message[10]: ".int($DayVisits{$year.$month.$day}||0)."\">"; }
#			if ($ShowMonthDayStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=4 ALT=\"$Message[56]: ".int($DayPages{$year.$month.$day}||0)."\" title=\"$Message[56]: ".int($DayPages{$year.$month.$day}||0)."\">"; }
#			if ($ShowMonthDayStats =~ /H/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=4 ALT=\"$Message[57]: ".int($DayHits{$year.$month.$day}||0)."\" title=\"$Message[57]: ".int($DayHits{$year.$month.$day}||0)."\">"; }
#			if ($ShowMonthDayStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=4 ALT=\"$Message[75]: ".Format_Bytes($DayBytes{$year.$month.$day})."\" title=\"$Message[75]: ".Format_Bytes($DayBytes{$year.$month.$day})."\">"; }
#			print "</TD>\n";
#		}
#		print "<TD>&nbsp;</TD>";
#		print "<TD>";	# Show average value cell
#		my $bredde_v=0; my $bredde_p=0; my $bredde_h=0; my $bredde_k=0;
#		if ($max_v > 0) { $bredde_v=int($average_v/$max_v*$BarHeight)+1; }
#		if ($max_h > 0) { $bredde_p=int($average_p/$max_h*$BarHeight)+1; }
#		if ($max_h > 0) { $bredde_h=int($average_h/$max_h*$BarHeight)+1; }
#		if ($max_k > 0) { $bredde_k=int($average_k/$max_k*$BarHeight)+1; }
#		$average_v=sprintf("%.2f",$average_v);
#		$average_p=sprintf("%.2f",$average_p);
#		$average_h=sprintf("%.2f",$average_h);
#		$average_k=sprintf("%.2f",$average_k);
#		if ($ShowMonthDayStats =~ /V/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=4 ALT=\"$Message[10]: $average_v\" title=\"$Message[10]: $average_v\">"; }
#		if ($ShowMonthDayStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=4 ALT=\"$Message[56]: $average_p\" title=\"$Message[56]: $average_p\">"; }
#		if ($ShowMonthDayStats =~ /H/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=4 ALT=\"$Message[57]: $average_h\" title=\"$Message[57]: $average_h\">"; }
#		if ($ShowMonthDayStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=4 ALT=\"$Message[75]: ".Format_Bytes($average_k)."\" title=\"$Message[75]: ".Format_Bytes($average_k)."\">"; }
#		print "</TD>";
#		print "<TD></TD>\n";
#		print "</TR>\n";
#		# Show lib for days
#		print "<TR><td></td>";
#		foreach my $daycursor ($firstdaytoshowtime..$lastdaytoshowtime) {
#			$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
#			my $year=$1; my $month=$2; my $day=$3;
#			if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
#			my $dayofweekcursor=DayOfWeek($day,$month,$year);
#			print "<TD valign=middle".($dayofweekcursor=~/[06]/?" bgcolor=\"#$color_weekend\"":"").">";
#			print ($day==$nowday && $month==$nowmonth && $year==$nowyear?'<b>':'');
#			print "$day<br><font style=\"font-size: ".($FrameName ne 'mainright'?"10":"9")."px;\">".$MonthLib{$month}."</font>";
#			print ($day==$nowday && $month==$nowmonth && $year==$nowyear?'</b>':'');
#			print "</TD>\n";
#		}
#		print "<TD>&nbsp;</TD>";
#		print "<TD valign=middle".($TOOLTIPON?" onmouseover=\"ShowTip(18);\" onmouseout=\"HideTip(18);\"":"").">$Message[96]</TD>\n";
#		print "<TD></TD>\n";
#		print "</TR>\n";
#		print "</TABLE>\n<br>\n";
#
#		# Show data array for days
#		print "<TABLE>\n";
#		print "<TR><TD width=\"20%\" bgcolor=\"#$color_TableBGRowTitle\">$Message[4]</TD>";
#		if ($ShowMonthDayStats =~ /V/i) { print "<TD width=\"20%\" bgcolor=\"#$color_v\"".($TOOLTIPON?" onmouseover=\"ShowTip(1);\" onmouseout=\"HideTip(1);\"":"").">$Message[10]</TD>"; }
#		if ($ShowMonthDayStats =~ /P/i) { print "<TD width=\"20%\" bgcolor=\"#$color_p\"".($TOOLTIPON?" onmouseover=\"ShowTip(3);\" onmouseout=\"HideTip(3);\"":"").">$Message[56]</TD>"; }
#		if ($ShowMonthDayStats =~ /H/i) { print "<TD width=\"20%\" bgcolor=\"#$color_h\"".($TOOLTIPON?" onmouseover=\"ShowTip(4);\" onmouseout=\"HideTip(4);\"":"").">$Message[57]</TD>"; }
#		if ($ShowMonthDayStats =~ /B/i) { print "<TD width=\"20%\" bgcolor=\"#$color_k\"".($TOOLTIPON?" onmouseover=\"ShowTip(5);\" onmouseout=\"HideTip(5);\"":"").">$Message[75]</TD>"; }
#		print "</TR>\n";
#		foreach my $daycursor ($firstdaytoshowtime..$lastdaytoshowtime) {
#			$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
#			my $year=$1; my $month=$2; my $day=$3;
#			if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
#			my $dayofweekcursor=DayOfWeek($day,$month,$year);
#			print "<TR>";
#			print "<TD".($dayofweekcursor=~/[06]/?" bgcolor=\"#$color_weekend\"":"").">",Format_Date("$year$month$day"."000000",2),"</TD>";
#			if ($ShowMonthDayStats =~ /V/i) { print "<TD".($dayofweekcursor=~/[06]/?" bgcolor=\"#$color_weekend\"":"").">",$DayVisits{$year.$month.$day}?$DayVisits{$year.$month.$day}:"0","</TD>"; }
#			if ($ShowMonthDayStats =~ /P/i) { print "<TD".($dayofweekcursor=~/[06]/?" bgcolor=\"#$color_weekend\"":"").">",$DayPages{$year.$month.$day}?$DayPages{$year.$month.$day}:"0","</TD>"; }
#			if ($ShowMonthDayStats =~ /H/i) { print "<TD".($dayofweekcursor=~/[06]/?" bgcolor=\"#$color_weekend\"":"").">",$DayHits{$year.$month.$day}?$DayHits{$year.$month.$day}:"0","</TD>"; }
#			if ($ShowMonthDayStats =~ /B/i) { print "<TD".($dayofweekcursor=~/[06]/?" bgcolor=\"#$color_weekend\"":"").">",Format_Bytes(int($DayBytes{$year.$month.$day})),"</TD>"; }
#			print "</TR>\n";
#		}
#		print "</TABLE>\n<br>";
#
#		print "</CENTER>\n";
#		print "</TD></TR>\n";
#		&tab_end;
#		&html_end;
#		exit(0);
#	}
	if ($HTMLOutput{'alldomains'}) {
		print "$Center<a name=\"DOMAINSLIST\">&nbsp;</a><BR>\n";
		# Show domains list
		my $title=''; my $cpt=0;
		if ($HTMLOutput{'alldomains'})  { $title.="$Message[25]"; $cpt=(scalar keys %_domener_h); }
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH width=$WIDTHCOLICON>&nbsp;</TH><TH colspan=2>$Message[17]</TH>";
		if ($ShowDomainsStats =~ /P/i) { print "<TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH>"; }
		if ($ShowDomainsStats =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
		if ($ShowDomainsStats =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
		print "<TH>&nbsp;</TH>";
		print "</TR>\n";
		$total_p=$total_h=$total_k=0;
		$max_h=1; foreach my $key (values %_domener_h) { if ($key > $max_h) { $max_h = $key; } }
		$max_k=1; foreach my $key (values %_domener_k) { if ($key > $max_k) { $max_k = $key; } }
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,1,\%_domener_p,\%_domener_p);
		foreach my $key (@keylist) {
			my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
			if ($max_h > 0) { $bredde_p=int($BarWidth*$_domener_p{$key}/$max_h)+1; }	# use max_h to enable to compare pages with hits
			if ($_domener_p{$key} && $bredde_p==1) { $bredde_p=2; }
			if ($max_h > 0) { $bredde_h=int($BarWidth*$_domener_h{$key}/$max_h)+1; }
			if ($_domener_h{$key} && $bredde_h==1) { $bredde_h=2; }
			if ($max_k > 0) { $bredde_k=int($BarWidth*($_domener_k{$key}||0)/$max_k)+1; }
			if ($_domener_k{$key} && $bredde_k==1) { $bredde_k=2; }
			my $newkey=lc($key);
			if ($newkey eq 'ip' || ! $DomainsHashIDLib{$newkey}) {
				print "<TR><TD width=$WIDTHCOLICON><IMG SRC=\"$DirIcons\/flags\/ip.png\" height=14 alt=\"$Message[0]\"></TD><TD CLASS=AWL>$Message[0]</TD><TD>$newkey</TD>";
			}
			else {
				print "<TR><TD width=$WIDTHCOLICON><IMG SRC=\"$DirIcons\/flags\/$newkey.png\" height=14 alt=\"$newkey\"></TD><TD CLASS=AWL>$DomainsHashIDLib{$newkey}</TD><TD>$newkey</TD>";
			}
			if ($ShowDomainsStats =~ /P/i) { print "<TD>$_domener_p{$key}</TD>"; }
			if ($ShowDomainsStats =~ /H/i) { print "<TD>$_domener_h{$key}</TD>"; }
			if ($ShowDomainsStats =~ /B/i) { print "<TD>".Format_Bytes($_domener_k{$key})."</TD>"; }
			print "<TD CLASS=AWL>";
			if ($ShowDomainsStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$Message[56]: ".int($_domener_p{$key})."\" title=\"$Message[56]: ".int($_domener_p{$key})."\"><br>\n"; }
			if ($ShowDomainsStats =~ /H/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 ALT=\"$Message[57]: ".int($_domener_h{$key})."\" title=\"$Message[57]: ".int($_domener_h{$key})."\"><br>\n"; }
			if ($ShowDomainsStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$Message[75]: ".Format_Bytes($_domener_k{$key})."\" title=\"$Message[75]: ".Format_Bytes($_domener_k{$key})."\">"; }
			print "</TD>";
			print "</TR>\n";
			$total_p += $_domener_p{$key};
			$total_h += $_domener_h{$key};
			$total_k += $_domener_k{$key}||0;
			$count++;
		}
		$rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) { 	# All other domains (known or not)
			print "<TR><TD width=$WIDTHCOLICON>&nbsp;</TD><TD colspan=2 CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
			if ($ShowDomainsStats =~ /P/i) { print "<TD>$rest_p</TD>"; }
			if ($ShowDomainsStats =~ /H/i) { print "<TD>$rest_h</TD>"; }
			if ($ShowDomainsStats =~ /B/i) { print "<TD>".Format_Bytes($rest_k)."</TD>"; }
			print "<TD CLASS=AWL>&nbsp;</TD>";
			print "</TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'allhosts'} || $HTMLOutput{'lasthosts'}) {
		print "$Center<a name=\"HOSTSLIST\">&nbsp;</a><BR>\n";
		# Show filter form
		&ShowFormFilter("hostfilter",$HostFilter);
		# Show hosts list
		my $title=''; my $cpt=0;
		if ($HTMLOutput{'allhosts'})  { $title.="$Message[81]"; $cpt=(scalar keys %_host_h); }
		if ($HTMLOutput{'lasthosts'}) { $title.="$Message[9]"; $cpt=(scalar keys %_host_h); }
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>";
		if ($HostFilter) {
			print "$Message[79] <b>$HostFilter</b>: $cpt $Message[81]";
			if ($MonthRequired ne 'all') {
				if ($HTMLOutput{'allhosts'} || $HTMLOutput{'lasthosts'}) { print "<br>$Message[102]: $TotalHostsKnown $Message[82], $TotalHostsUnknown $Message[1] - $TotalUnique $Message[11]"; }
			}
		}
		else {
			if ($MonthRequired ne 'all') { print "$Message[102] : $TotalHostsKnown $Message[82], $TotalHostsUnknown $Message[1] - $TotalUnique $Message[11]"; }
			else { print "$Message[102] : ".(scalar keys %_host_h); }
		}
		print "</TH>";
		if ($ShowLinksToWhoIs && $LinksToWhoIs) { print "<TH width=80>$Message[114]</TH>"; }
		if ($ShowHostsStats =~ /P/i) { print "<TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH>"; }
		if ($ShowHostsStats =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
		if ($ShowHostsStats =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
		if ($ShowHostsStats =~ /L/i) { print "<TH width=120>$Message[9]</TH>"; }
		print "</TR>\n";
		$total_p=$total_h=$total_k=0;
		my $count=0;
		if ($HTMLOutput{'allhosts'})  { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Host'},\%_host_h,\%_host_p); }
		if ($HTMLOutput{'lasthosts'}) { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Host'},\%_host_h,\%_host_l); }
		foreach my $key (@keylist) {
			my $host=CleanFromCSSA($key);
			print "<tr><td CLASS=AWL>".($_robot_l{$key}?'<b>':'')."$host".($_robot_l{$key}?'</b>':'')."</td>";
			if ($ShowLinksToWhoIs && $LinksToWhoIs) { ShowWhoIsCell($key); }
			if ($ShowHostsStats =~ /P/i) { print "<TD>".($_host_p{$key}?$_host_p{$key}:"&nbsp;")."</TD>"; }
			if ($ShowHostsStats =~ /H/i) { print "<TD>$_host_h{$key}</TD>"; }
			if ($ShowHostsStats =~ /B/i) { print "<TD>".Format_Bytes($_host_k{$key})."</TD>"; }
			if ($ShowHostsStats =~ /L/i) { print "<TD>".($_host_l{$key}?Format_Date($_host_l{$key},1):'-')."</TD>"; }
			$total_p += $_host_p{$key};
			$total_h += $_host_h{$key};
			$total_k += $_host_k{$key}||0;
			$count++;
		}
		if ($Debug) { debug("Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h",2); }
		$rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other visitors (known or not)
			print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
			if ($ShowLinksToWhoIs && $LinksToWhoIs) { ShowWhoIsCell(''); }
			if ($ShowHostsStats =~ /P/i) { print "<TD>".($rest_p?$rest_p:"&nbsp;")."</TD>"; }
			if ($ShowHostsStats =~ /H/i) { print "<TD>$rest_h</TD>"; }
			if ($ShowHostsStats =~ /B/i) { print "<TD>".Format_Bytes($rest_k)."</TD>"; }
			if ($ShowHostsStats =~ /L/i) { print "<TD>&nbsp;</TD>"; }
			print "</TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'unknownip'}) {
		print "$Center<a name=\"UNKOWNIP\">&nbsp;</a><BR>\n";
		&tab_head("$Message[45]",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>".(scalar keys %_host_h)." $Message[1]</TH>";
		if ($ShowLinksToWhoIs && $LinksToWhoIs) { print "<TH width=80>$Message[114]</TH>"; }
		if ($ShowHostsStats =~ /P/i) { print "<TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH>"; }
		if ($ShowHostsStats =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
		if ($ShowHostsStats =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
		if ($ShowHostsStats =~ /L/i) { print "<TH width=120>$Message[9]</TH>"; }
		print "</TR>\n";
		$total_p=$total_h=$total_k=0;
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Host'},\%_host_h,\%_host_p);
		foreach my $key (@keylist) {
			my $host=CleanFromCSSA($key);
			print "<tr><td CLASS=AWL>$host</td>";
			if ($ShowLinksToWhoIs && $LinksToWhoIs) { ShowWhoIsCell($key); }
			if ($ShowHostsStats =~ /P/i) { print "<TD>".($_host_p{$key}?$_host_p{$key}:"&nbsp;")."</TD>"; }
			if ($ShowHostsStats =~ /H/i) { print "<TD>$_host_h{$key}</TD>"; }
			if ($ShowHostsStats =~ /B/i) { print "<TD>".Format_Bytes($_host_k{$key})."</TD>"; }
			if ($ShowHostsStats =~ /L/i) { print "<TD>".($_host_l{$key}?Format_Date($_host_l{$key},1):'-')."</TD>"; }
			print "</tr>\n";
			$total_p += $_host_p{$key};
			$total_h += $_host_h{$key};
			$total_k += $_host_k{$key}||0;
			$count++;
		}
		if ($Debug) { debug("Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h",2); }
		$rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other visitors (known or not)
			print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[82]</font></TD>";
			if ($ShowLinksToWhoIs && $LinksToWhoIs) { ShowWhoIsCell(''); }
			if ($ShowHostsStats =~ /P/i) { print "<TD>".($rest_p?$rest_p:"&nbsp;")."</TD>"; }
			if ($ShowHostsStats =~ /H/i) { print "<TD>$rest_h</TD>"; }
			if ($ShowHostsStats =~ /B/i) { print "<TD>".Format_Bytes($rest_k)."</TD>"; }
			if ($ShowHostsStats =~ /L/i) { print "<TD>&nbsp;</TD>"; }
			print "</TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'allemails'} || $HTMLOutput{'lastemails'}) {
		print "$Center<a name=\"EMAILSLIST\">&nbsp;</a><BR>\n";
		# Show filter form
		#&ShowFormFilter("emailsfilter",$EmailsFilter);
		# Show emails list
		my $title="$Message[131]";
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[131] : ".(scalar keys %_emails_h)."</TH>";
		if ($ShowEMailSenders =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
		if ($ShowEMailSenders =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
		if ($ShowEMailSenders =~ /M/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[106]</TH>"; }
		if ($ShowEMailSenders =~ /L/i) { print "<TH width=120>$Message[9]</TH>"; }
		print "</TR>\n";
		$total_p=$total_h=$total_k=0;
		$max_h=1; foreach my $key (values %_emails_h) { if ($key > $max_h) { $max_h = $key; } }
		$max_k=1; foreach my $key (values %_emails_k) { if ($key > $max_k) { $max_k = $key; } }
		my $count=0;
		if ($HTMLOutput{'allemails'})  { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'EMail'},\%_emails_h,\%_emails_h); }
		if ($HTMLOutput{'lastemails'}) { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'EMail'},\%_emails_h,\%_emails_l); }
		foreach my $key (@keylist) {
			my $bredde_h=0;my $bredde_k=0;
			if ($max_h > 0) { $bredde_h=int($BarWidth*$_emails_h{$key}/$max_h)+1; }
			if ($max_k > 0) { $bredde_k=int($BarWidth*$_emails_k{$key}/$max_k)+1; }
			print "<TR><TD CLASS=AWL>$key</TD>";
			if ($ShowEMailSenders =~ /H/i) { print "<TD>$_emails_h{$key}</TD>"; }
			if ($ShowEMailSenders =~ /B/i) { print "<TD>".Format_Bytes($_emails_k{$key})."</TD>"; }
			if ($ShowEMailSenders =~ /M/i) { print "<TD>".Format_Bytes($_emails_k{$key}/($_emails_h{$key}||1))."</TD>"; }
			if ($ShowEMailSenders =~ /L/i) { print "<TD>".($_emails_l{$key}?Format_Date($_emails_l{$key},1):'-')."</TD>"; }
			print "</TR>\n";
			#$total_p += $_emails_p{$key};
			$total_h += $_emails_h{$key};
			$total_k += $_emails_k{$key};
			$count++;
		}
		$rest_p=0;	# $rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other sender emails
			print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
			if ($ShowEMailSenders =~ /H/i) { print "<TD>$rest_h</TD>"; }
			if ($ShowEMailSenders =~ /B/i) { print "<TD>".Format_Bytes($rest_k)."</TD>"; }
			if ($ShowEMailSenders =~ /M/i) { print "<TD>".Format_Bytes($rest_k/($rest_h||1))."</TD>"; }
			if ($ShowEMailSenders =~ /L/i) { print "<TD>&nbsp;</TD>"; }
			print "</TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'allemailr'} || $HTMLOutput{'lastemailr'}) {
		print "$Center<a name=\"EMAILRLIST\">&nbsp;</a><BR>\n";
		# Show filter form
		#&ShowFormFilter("emailrfilter",$EmailrFilter);
		# Show emails list
		my $title="$Message[132]";
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[132] : ".(scalar keys %_emailr_h)."</TH>";
		if ($ShowEMailReceivers =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
		if ($ShowEMailReceivers =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
		if ($ShowEMailReceivers =~ /M/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[106]</TH>"; }
		if ($ShowEMailReceivers =~ /L/i) { print "<TH width=120>$Message[9]</TH>"; }
		print "</TR>\n";
		$total_p=$total_h=$total_k=0;
		$max_h=1; foreach my $key (values %_emailr_h) { if ($key > $max_h) { $max_h = $key; } }
		$max_k=1; foreach my $key (values %_emailr_k) { if ($key > $max_k) { $max_k = $key; } }
		my $count=0;
		if ($HTMLOutput{'allemailr'})  { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'EMail'},\%_emailr_h,\%_emailr_h); }
		if ($HTMLOutput{'lastemailr'}) { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'EMail'},\%_emailr_h,\%_emailr_l); }
		foreach my $key (@keylist) {
			my $bredde_h=0;my $bredde_k=0;
			if ($max_h > 0) { $bredde_h=int($BarWidth*$_emailr_h{$key}/$max_h)+1; }
			if ($max_k > 0) { $bredde_k=int($BarWidth*$_emailr_k{$key}/$max_k)+1; }
			print "<TR><TD CLASS=AWL>$key</TD>";
			if ($ShowEMailReceivers =~ /H/i) { print "<TD>$_emailr_h{$key}</TD>"; }
			if ($ShowEMailReceivers =~ /B/i) { print "<TD>".Format_Bytes($_emailr_k{$key})."</TD>"; }
			if ($ShowEMailReceivers =~ /M/i) { print "<TD>".Format_Bytes($_emailr_k{$key}/($_emailr_h{$key}||1))."</TD>"; }
			if ($ShowEMailReceivers =~ /L/i) { print "<TD>".($_emailr_l{$key}?Format_Date($_emailr_l{$key},1):'-')."</TD>"; }
			print "</TR>\n";
			#$total_p += $_emailr_p{$key};
			$total_h += $_emailr_h{$key};
			$total_k += $_emailr_k{$key};
			$count++;
		}
		$rest_p=0;	# $rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other receiver emails
			print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
			if ($ShowEMailReceivers =~ /H/i) { print "<TD>$rest_h</TD>"; }
			if ($ShowEMailReceivers =~ /B/i) { print "<TD>".Format_Bytes($rest_k)."</TD>"; }
			if ($ShowEMailReceivers =~ /M/i) { print "<TD>".Format_Bytes($rest_k/($rest_h||1))."</TD>"; }
			if ($ShowEMailReceivers =~ /L/i) { print "<TD>&nbsp;</TD>"; }
			print "</TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'alllogins'} || $HTMLOutput{'lastlogins'}) {
		print "$Center<a name=\"LOGINSLIST\">&nbsp;</a><BR>\n";
		my $title='';
		if ($HTMLOutput{'alllogins'}) { $title.="$Message[94]"; }
		if ($HTMLOutput{'lastlogins'}) { $title.="$Message[9]"; }
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[94] : ".(scalar keys %_login_h)."</TH>";
		if ($ShowAuthenticatedUsers =~ /P/i) { print "<TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH>"; }
		if ($ShowAuthenticatedUsers =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
		if ($ShowAuthenticatedUsers =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
		if ($ShowAuthenticatedUsers =~ /L/i) { print "<TH width=120>$Message[9]</TH>"; }
		print "</TR>\n";
		$total_p=$total_h=$total_k=0;
		my $count=0;
		if ($HTMLOutput{'alllogins'}) { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Host'},\%_login_h,\%_login_p); }
		if ($HTMLOutput{'lastlogins'}) { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Host'},\%_login_h,\%_login_l); }
		foreach my $key (@keylist) {
			print "<TR><TD CLASS=AWL>$key</TD>";
			if ($ShowAuthenticatedUsers =~ /P/i) { print "<TD>".($_login_p{$key}?$_login_p{$key}:"&nbsp;")."</TD>"; }
			if ($ShowAuthenticatedUsers =~ /H/i) { print "<TD>$_login_h{$key}</TD>"; }
			if ($ShowAuthenticatedUsers =~ /B/i) { print "<TD>".Format_Bytes($_login_k{$key})."</TD>"; }
			if ($ShowAuthenticatedUsers =~ /L/i) { print "<TD>".($_login_l{$key}?Format_Date($_login_l{$key},1):'-')."</TD>"; }
			print "</TR>\n";
			$total_p += $_login_p{$key}||0;
			$total_h += $_login_h{$key};
			$total_k += $_login_k{$key}||0;
			$count++;
		}
		if ($Debug) { debug("Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h",2); }
		$rest_p=$TotalPages-$total_p;
		$rest_h=$TotalHits-$total_h;
		$rest_k=$TotalBytes-$total_k;
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other logins and/or anonymous
			print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[125]</font></TD>";
			if ($ShowAuthenticatedUsers =~ /P/i) { print "<TD>".($rest_p?$rest_p:"&nbsp;")."</TD>"; }
			if ($ShowAuthenticatedUsers =~ /H/i) { print "<TD>$rest_h</TD>"; }
			if ($ShowAuthenticatedUsers =~ /B/i) { print "<TD>".Format_Bytes($rest_k)."</TD>"; }
			if ($ShowAuthenticatedUsers =~ /L/i) { print "<TD>&nbsp;</TD>"; }
			print "</TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'allrobots'} || $HTMLOutput{'lastrobots'}) {
		print "$Center<a name=\"ROBOTSLIST\">&nbsp;</a><BR>\n";
		my $title='';
		if ($HTMLOutput{'allrobots'})  { $title.="$Message[53]"; }
		if ($HTMLOutput{'lastrobots'}) { $title.="$Message[9]"; }
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>".(scalar keys %_robot_h)." $Message[51]</TH>";
		if ($ShowRobotsStats =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
		if ($ShowRobotsStats =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
		if ($ShowRobotsStats =~ /L/i) { print "<TH width=120>$Message[9]</TH>"; }
		print "</TR>\n";
		$total_p=$total_h=$total_k=0;
		my $count=0;
		if ($HTMLOutput{'allrobots'})  { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Robot'},\%_robot_h,\%_robot_h); }
		if ($HTMLOutput{'lastrobots'}) { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Robot'},\%_robot_h,\%_robot_l); }
		foreach my $key (@keylist) {
			print "<TR><TD CLASS=AWL>".($RobotsHashIDLib{$key}?$RobotsHashIDLib{$key}:$key)."</TD>";
			if ($ShowRobotsStats =~ /H/i) { print "<TD>$_robot_h{$key}</TD>"; }
			if ($ShowRobotsStats =~ /B/i) { print "<TD>".Format_Bytes($_robot_k{$key})."</TD>"; }
			if ($ShowRobotsStats =~ /L/i) { print "<TD>".($_robot_l{$key}?Format_Date($_robot_l{$key},1):'-')."</TD>"; }
			print "</TR>\n";
			#$total_p += $_robot_p{$key}||0;
			$total_h += $_robot_h{$key};
			$total_k += $_robot_k{$key}||0;
			$count++;
		}
		# For bots we need to count Totals
		my $TotalPagesRobots = 0; #foreach my $val (values %_robot_p) { $TotalPagesRobots+=$val; }
		my $TotalHitsRobots = 0; foreach my $val (values %_robot_h) { $TotalHitsRobots+=$val; }
		my $TotalBytesRobots = 0; foreach my $val (values %_robot_k) { $TotalBytesRobots+=$val; }
		$rest_p=0;	#$rest_p=$TotalPagesRobots-$total_p;
		$rest_h=$TotalHitsRobots-$total_h;
		$rest_k=$TotalBytesRobots-$total_k;
		if ($Debug) { debug("Total real / shown : $TotalPagesRobots / $total_p - $TotalHitsRobots / $total_h - $TotalBytesRobots / $total_k",2); }
		if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other login
			print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
			if ($ShowRobotsStats =~ /H/i) { print "<TD>$rest_h</TD>"; }
			if ($ShowRobotsStats =~ /B/i) { print "<TD>".(Format_Bytes($rest_k))."</TD>"; }
			if ($ShowRobotsStats =~ /L/i) { print "<TD>&nbsp;</TD>"; }
			print "</TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'urldetail'} || $HTMLOutput{'urlentry'} || $HTMLOutput{'urlexit'}) {
		# Call to plugins' function ShowPagesFilter
		foreach my $pluginname (keys %{$PluginsLoaded{'ShowPagesFilter'}})  {
			my $function="ShowPagesFilter_$pluginname()";
			eval("$function");
		}
		print "$Center<a name=\"URLDETAIL\">&nbsp;</a><BR>\n";
		# Show filter form
		&ShowFormFilter("urlfilter",$URLFilter);
		# Show URL list
		my $title=''; my $cpt=0;
		if ($HTMLOutput{'urldetail'}) { $title=$Message[19]; $cpt=(scalar keys %_url_p); }
		if ($HTMLOutput{'urlentry'})  { $title=$Message[104]; $cpt=(scalar keys %_url_e); }
		if ($HTMLOutput{'urlexit'})   { $title=$Message[116]; $cpt=(scalar keys %_url_x); }
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>";
		if ($URLFilter) {
			print "$Message[79] <b>$URLFilter</b>: $cpt $Message[28]";
			if ($MonthRequired ne 'all') {
				if ($HTMLOutput{'urldetail'}) { print "<br>$Message[102]: $TotalDifferentPages $Message[28]"; }
			}
		}
		else { print "$Message[102]: $cpt $Message[28]"; }
		print "</TH>";
		if ($ShowPagesStats =~ /P/i) { print "<TH bgcolor=\"#$color_p\" width=80>$Message[29]</TH>"; }
		if ($ShowPagesStats =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[106]</TH>"; }
		if ($ShowPagesStats =~ /E/i) { print "<TH bgcolor=\"#$color_e\" width=80>$Message[104]</TH>"; }
		if ($ShowPagesStats =~ /X/i) { print "<TH bgcolor=\"#$color_x\" width=80>$Message[116]</TH>"; }
		# Call to plugins' function ShowPagesAddField
		foreach my $pluginname (keys %{$PluginsLoaded{'ShowPagesAddField'}})  {
			my $function="ShowPagesAddField_$pluginname('title')";
			eval("$function");
		}
		print "<TH>&nbsp;</TH></TR>\n";
		$total_p=$total_k=$total_e=$total_x=0;
		my $count=0;
		if ($HTMLOutput{'urlentry'}) { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'File'},\%_url_e,\%_url_e); }
		elsif ($HTMLOutput{'urlexit'}) { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'File'},\%_url_x,\%_url_x); }
		else { &BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'File'},\%_url_p,\%_url_p); }
		$max_p=1; $max_k=1;
		foreach my $key (@keylist) {
			if ($_url_p{$key} > $max_p) { $max_p = $_url_p{$key}; }
			if ($_url_k{$key}/($_url_p{$key}||1) > $max_k) { $max_k = $_url_k{$key}/($_url_p{$key}||1); }
		}
		foreach my $key (@keylist) {
			print "<TR><TD CLASS=AWL>";
			&ShowURL($key);
			print "</TD>";
			my $bredde_p=0; my $bredde_e=0; my $bredde_x=0; my $bredde_k=0;
			if ($max_p > 0) { $bredde_p=int($BarWidth*($_url_p{$key}||0)/$max_p)+1; }
			if (($bredde_p==1) && $_url_p{$key}) { $bredde_p=2; }
			if ($max_p > 0) { $bredde_e=int($BarWidth*($_url_e{$key}||0)/$max_p)+1; }
			if (($bredde_e==1) && $_url_e{$key}) { $bredde_e=2; }
			if ($max_p > 0) { $bredde_x=int($BarWidth*($_url_x{$key}||0)/$max_p)+1; }
			if (($bredde_x==1) && $_url_x{$key}) { $bredde_x=2; }
			if ($max_k > 0) { $bredde_k=int($BarWidth*(($_url_k{$key}||0)/($_url_p{$key}||1))/$max_k)+1; }
			if (($bredde_k==1) && $_url_k{$key}) { $bredde_k=2; }
			if ($ShowPagesStats =~ /P/i) { print "<TD>$_url_p{$key}</TD>"; }
			if ($ShowPagesStats =~ /B/i) { print "<TD>".($_url_k{$key}?Format_Bytes($_url_k{$key}/($_url_p{$key}||1)):"&nbsp;")."</TD>"; }
			if ($ShowPagesStats =~ /E/i) { print "<TD>".($_url_e{$key}?$_url_e{$key}:"&nbsp;")."</TD>"; }
			if ($ShowPagesStats =~ /X/i) { print "<TD>".($_url_x{$key}?$_url_x{$key}:"&nbsp;")."</TD>"; }
			# Call to plugins' function ShowPagesAddField
			foreach my $pluginname (keys %{$PluginsLoaded{'ShowPagesAddField'}})  {
				my $function="ShowPagesAddField_$pluginname('$key')"; 
				eval("$function");
			}
			print "<TD CLASS=AWL>";
			# alt and title are not provided to reduce page size
			if ($ShowPagesStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6><br>"; }
			if ($ShowPagesStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6><br>"; }
			if ($ShowPagesStats =~ /E/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_e\" WIDTH=$bredde_e HEIGHT=6><br>"; }
			if ($ShowPagesStats =~ /X/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_x\" WIDTH=$bredde_x HEIGHT=6>"; }
			#if ($ShowPagesStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$Message[29]: $_url_p{$key}\" TITLE=\"$Message[29]: $_url_p{$key}\" ><br>"; }
			#if ($ShowPagesStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$Message[106]: ".Format_Bytes($_url_k{$key}/($_url_p{$key}||1))."\" TITLE=\"$Message[106]: ".Format_Bytes($_url_k{$key}/($_url_p{$key}||1))."\"><br>"; }
			#if ($ShowPagesStats =~ /E/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_e\" WIDTH=$bredde_e HEIGHT=6 ALT=\"$Message[104]: $_url_e{$key}\" TITLE=\"$Message[104]: $_url_e{$key}\"><br>"; }
			#if ($ShowPagesStats =~ /X/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_x\" WIDTH=$bredde_x HEIGHT=6 ALT=\"$Message[116]: $_url_x{$key}\" TITLE=\"$Message[116]: $_url_x{$key}\">"; }
			print "</TD></TR>\n";
			$total_p += $_url_p{$key};
			$total_e += $_url_e{$key};
			$total_x += $_url_x{$key};
			$total_k += $_url_k{$key};
			$count++;
		}
		if ($Debug) { debug("Total real / shown : $TotalPages / $total_p - $TotalEntries / $total_e - $TotalExits / $total_x - $TotalBytesPages / $total_k",2); }
		$rest_p=$TotalPages-$total_p;
		$rest_k=$TotalBytesPages-$total_k;
		$rest_e=$TotalEntries-$total_e;
		$rest_x=$TotalExits-$total_x;
		if ($rest_p > 0 || $rest_e > 0 || $rest_k > 0) {
			print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
			if ($ShowPagesStats =~ /P/i) { print "<TD>".($rest_p?$rest_p:"&nbsp;")."</TD>"; }
			if ($ShowPagesStats =~ /B/i) { print "<TD>".($rest_k?Format_Bytes($rest_k/($rest_p||1)):"&nbsp;")."</TD>"; }
			if ($ShowPagesStats =~ /E/i) { print "<TD>".($rest_e?$rest_e:"&nbsp;")."</TD>"; }
			if ($ShowPagesStats =~ /X/i) { print "<TD>".($rest_x?$rest_x:"&nbsp;")."</TD>"; }
			# Call to plugins' function ShowPagesAddField
			foreach my $pluginname (keys %{$PluginsLoaded{'ShowPagesAddField'}})  {
				my $function="ShowPagesAddField_$pluginname('')";
				eval("$function");
			}
			print "<TD>&nbsp;</TD></TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'unknownos'}) {
		print "$Center<a name=\"UNKOWNOS\">&nbsp;</a><BR>\n";
		my $title="$Message[46]";
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>User agent (".(scalar keys %_unknownreferer_l).")</TH><TH>$Message[9]</TH></TR>\n";
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,1,\%_unknownreferer_l,\%_unknownreferer_l);
		foreach my $key (@keylist) {
			my $useragent=CleanFromCSSA($key);
			print "<tr><td CLASS=AWL>$useragent</td><td>".Format_Date($_unknownreferer_l{$key},1)."</td></tr>\n";
			$count++;
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'unknownbrowser'}) {
		print "$Center<a name=\"UNKOWNBROWSER\">&nbsp;</a><BR>\n";
		my $title="$Message[50]";
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>User agent (".(scalar keys %_unknownrefererbrowser_l).")</TH><TH>$Message[9]</TH></TR>\n";
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,1,\%_unknownrefererbrowser_l,\%_unknownrefererbrowser_l);
		foreach my $key (@keylist) {
			my $useragent=CleanFromCSSA($key);
			print "<tr><td CLASS=AWL>$useragent</td><td>".Format_Date($_unknownrefererbrowser_l{$key},1)."</td></tr>\n";
			$count++;
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'osdetail'}) {
		# Show os versions
		print "$Center<a name=\"OSVERSIONS\">&nbsp;</a><BR>";
		my $title="$Message[59]";
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH colspan=2>$Message[58]</TH>";
		print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH>";
		print "<TH>&nbsp;</TH>";
		print "</TR>\n";
		# Count Total by family
		my %totalfamily_h=();
		my $Total=0;
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,1,\%_os_h,\%_os_h);
		my %keysinkeylist=();
		$max_h=1;
		OSLOOP: foreach my $key (@keylist) {
			$Total+=$_os_h{$key};
			if ($_os_h{$key} > $max_h) { $max_h = $_os_h{$key}; }
			foreach my $family (@OSFamily) { if ($key =~ /^$family/i) { $totalfamily_h{$family}+=$_os_h{$key}; next OSLOOP; } }
		}
		# Write records grouped in a brwoser family
		foreach my $family (@OSFamily) {
			my $p='&nbsp;';
			if ($Total) { $p=int($totalfamily_h{$family}/$Total*1000)/10; $p="$p %"; }
			print "<TR bgcolor=\"#F8F8F8\"><TD class=AWL colspan=2><b>".uc($family)."</b></TD>";
			print "<TD><b>".int($totalfamily_h{$family})."</b></TD><TD><b>$p</b></TD><TD>&nbsp;</TD>";
			print "</TR>\n";
			foreach my $key (reverse sort keys %_os_h) {
				if ($key =~ /^$family(.*)/i) {
					$keysinkeylist{$key}=1;
					my $ver=$1;
					my $p='&nbsp;';
					if ($Total) { $p=int($_os_h{$key}/$Total*1000)/10; $p="$p %"; }
					print "<TR>";
					print "<TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/os\/$key.png\" alt=\"\"></TD>";
					print "<TD CLASS=AWL>$OSHashLib{$key}</TD>";
					my $bredde_h=0;
					if ($max_h > 0) { $bredde_h=int($BarWidth*($_os_h{$key}||0)/$max_h)+1; }
					if (($bredde_h==1) && $_os_h{$key}) { $bredde_h=2; }
					print "<TD>$_os_h{$key}</TD><TD>$p</TD>";
					print "<TD CLASS=AWL>";
					# alt and title are not provided to reduce page size
					if ($ShowOSStats) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6><br>"; }
					print "</TD>";
					print "</TR>\n";
					$count++;
				}
			}
		}
		# Write other records
		print "<TR bgcolor=\"#F8F8F8\"><TD class=AWL colspan=2><b>".uc($Message[2])."</b></TD>";
		print "<TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD>";
		print "</TR>\n";
		foreach my $key (@keylist) {
			if ($keysinkeylist{$key}) { next; }
			my $p='&nbsp;';
			if ($Total) { $p=int($_os_h{$key}/$Total*1000)/10; $p="$p %"; }
			print "<TR>";
			if ($key eq 'Unknown') {
				print "<TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/browser\/unknown.png\" alt=\"\"></TD><TD CLASS=AWL><font color=\"#$color_other\">$Message[0]</font></TD>";
			}
			else {
				my $keywithoutcumul=$key; $keywithoutcumul =~ s/cumul$//i;
				my $libos=$OSHashLib{$keywithoutcumul}||$keywithoutcumul;
				my $nameicon=$keywithoutcumul; $nameicon =~ s/[^\w]//g;
				print "<TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/os\/$nameicon.png\" alt=\"\"></TD><TD CLASS=AWL>$libos</TD>";
			}
			my $bredde_h=0;
			if ($max_h > 0) { $bredde_h=int($BarWidth*($_os_h{$key}||0)/$max_h)+1; }
			if (($bredde_h==1) && $_os_h{$key}) { $bredde_h=2; }
			print "<TD>$_os_h{$key}</TD><TD>$p</TD>";
			print "<TD CLASS=AWL>";
			# alt and title are not provided to reduce page size
			if ($ShowOSStats) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6><br>"; }
			print "</TD>";
			print "</TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'browserdetail'}) {
		# Show browsers versions
		print "$Center<a name=\"BROWSERSVERSIONS\">&nbsp;</a><BR>";
		my $title="$Message[21]";
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH colspan=2>$Message[58]</TH>";
		print "<TH width=80>$Message[111]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH>";
		print "<TH>&nbsp;</TH>";
		print "</TR>\n";
		# Count Total by family
		my %totalfamily_h=();
		my $Total=0;
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,1,\%_browser_h,\%_browser_h);
		my %keysinkeylist=();
		$max_h=1;
		BROWSERLOOP: foreach my $key (@keylist) {
			$Total+=$_browser_h{$key};
			if ($_browser_h{$key} > $max_h) { $max_h = $_browser_h{$key}; }
			foreach my $family (@BrowsersFamily) { if ($key =~ /^$family/i) { $totalfamily_h{$family}+=$_browser_h{$key}; next BROWSERLOOP; } }
		}
		# Write records grouped in a brwoser family
		foreach my $family (@BrowsersFamily) {
			my $p='&nbsp;';
			if ($Total) { $p=int($totalfamily_h{$family}/$Total*1000)/10; $p="$p %"; }
			print "<TR bgcolor=\"#F8F8F8\"><TD class=AWL colspan=2><b>".uc($family)."</b></TD>";
			print "<TD>&nbsp;</TD><TD><b>".int($totalfamily_h{$family})."</b></TD><TD><b>$p</b></TD><TD>&nbsp;</TD>";
			print "</TR>\n";
			foreach my $key (reverse sort keys %_browser_h) {
				if ($key =~ /^$family(.*)/i) {
					$keysinkeylist{$key}=1;
					my $ver=$1;
					my $p='&nbsp;';
					if ($Total) { $p=int($_browser_h{$key}/$Total*1000)/10; $p="$p %"; }
					print "<TR>";
					print "<TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/browser\/$family.png\" alt=\"\"></TD>";
					print "<TD CLASS=AWL>".ucfirst($family)." ".($ver?"$ver":"?")."</TD>";
					print "<TD>".($BrowsersHereAreGrabbers{$family}?"<b>$Message[112]</b>":"$Message[113]")."</TD>";
					my $bredde_h=0;
					if ($max_h > 0) { $bredde_h=int($BarWidth*($_browser_h{$key}||0)/$max_h)+1; }
					if (($bredde_h==1) && $_browser_h{$key}) { $bredde_h=2; }
					print "<TD>$_browser_h{$key}</TD><TD>$p</TD>";
					print "<TD CLASS=AWL>";
					# alt and title are not provided to reduce page size
					if ($ShowBrowsersStats) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6><br>"; }
					print "</TD>";
					print "</TR>\n";
					$count++;
				}
			}
		}
		# Write other records
		print "<TR bgcolor=\"#F8F8F8\"><TD class=AWL colspan=2><b>".uc($Message[2])."</b></TD>";
		print "<TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD>";
		print "</TR>\n";
		foreach my $key (@keylist) {
			if ($keysinkeylist{$key}) { next; }
			my $p='&nbsp;';
			if ($Total) { $p=int($_browser_h{$key}/$Total*1000)/10; $p="$p %"; }
			print "<TR>";
			if ($key eq 'Unknown') {
				print "<TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/browser\/unknown.png\" alt=\"\"></TD><TD CLASS=AWL><font color=\"#$color_other\">$Message[0]</font></TD><TD width=80>?</TD>";
			}
			else {
				my $keywithoutcumul=$key; $keywithoutcumul =~ s/cumul$//i;
				my $libbrowser=$BrowsersHashIDLib{$keywithoutcumul}||$keywithoutcumul;
				my $nameicon=$BrowsersHashIcon{$keywithoutcumul}||"notavailable";
				print "<TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/browser\/$nameicon.png\" alt=\"\"></TD><TD CLASS=AWL>$libbrowser</TD><TD>".($BrowsersHereAreGrabbers{$key}?"<b>$Message[112]</b>":"$Message[113]")."</TD>";
			}
			my $bredde_h=0;
			if ($max_h > 0) { $bredde_h=int($BarWidth*($_browser_h{$key}||0)/$max_h)+1; }
			if (($bredde_h==1) && $_browser_h{$key}) { $bredde_h=2; }
			print "<TD>$_browser_h{$key}</TD><TD>$p</TD>";
			print "<TD CLASS=AWL>";
			# alt and title are not provided to reduce page size
			if ($ShowBrowsersStats) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6><br>"; }
			print "</TD>";
			print "</TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'refererse'}) {
		print "$Center<a name=\"REFERERSE\">&nbsp;</a><BR>\n";
		my $title="$Message[40]";
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$TotalDifferentSearchEngines $Message[122]</TH>";
		print "<TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_p\" width=80>$Message[15]</TH>";
		print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH>";
		print "</TR>\n";
		$total_s=0;
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Refer'},\%_se_referrals_h,\%_se_referrals_p);
		foreach my $key (@keylist) {
			my $newreferer=CleanFromCSSA($SearchEnginesHashIDLib{$key}||$key);
			my $p_p; my $p_h;
			if ($TotalSearchEnginesPages) { $p_p=int($_se_referrals_p{$key}/$TotalSearchEnginesPages*1000)/10; }
			if ($TotalSearchEnginesHits) { $p_h=int($_se_referrals_h{$key}/$TotalSearchEnginesHits*1000)/10; }
			print "<TR><TD CLASS=AWL>$newreferer</TD>";
			print "<TD>".($_se_referrals_p{$key}?$_se_referrals_p{$key}:'&nbsp;')."</TD>";
			print "<TD>".($_se_referrals_p{$key}?"$p_p %":'&nbsp;')."</TD>";
			print "<TD>$_se_referrals_h{$key}</TD>";
			print "<TD>$p_h %</TD>";
			print "</TR>\n";
			$total_p += $_se_referrals_p{$key};
			$total_h += $_se_referrals_h{$key};
			$count++;
		}
		if ($Debug) { debug("Total real / shown : $TotalSearchEnginesPages / $total_p - $TotalSearchEnginesHits / $total_h",2); }
		$rest_p=$TotalSearchEnginesPages-$total_p;
		$rest_h=$TotalSearchEnginesHits-$total_h;
		if ($rest_p > 0 || $rest_h > 0) {
			my $p_p;my $p_h;
			if ($TotalSearchEnginesPages) { $p_p=int($rest_p/$TotalSearchEnginesPages*1000)/10; }
			if ($TotalSearchEnginesHits) { $p_h=int($rest_h/$TotalSearchEnginesHits*1000)/10; }
			print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
			print "<TD>".($rest_p?$rest_p:'&nbsp;')."</TD>";
			print "<TD>".($rest_p?"%p_p %":'&nbsp;')."</TD>";
			print "<TD>$rest_h</TD>";
			print "<TD>$p_h %</TD>";
			print "</TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'refererpages'}) {
		print "$Center<a name=\"REFERERPAGES\">&nbsp;</a><BR>\n";
		# Show filter form
		&ShowFormFilter("refererpagesfilter",$RefererPagesFilter);
		my $title="$Message[41]"; my $cpt=0;
		$cpt=(scalar keys %_pagesrefs_h);
		&tab_head("$title",19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>";
		if ($RefererPagesFilter) {
			print "$Message[79] <b>$RefererPagesFilter</b>: $cpt $Message[28]";
			#if ($MonthRequired ne 'all') {
			#	if ($HTMLOutput{'refererpages'}) { print "<br>$Message[102]: $TotalDifferentPages $Message[28]"; }
			#}
		}
		else { print "$Message[102]: $cpt $Message[28]"; }
		print "</TH>";
		print "<TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_p\" width=80>$Message[15]</TH>";
		print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH>";
		print "</TR>\n";
		$total_s=0;
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Refer'},\%_pagesrefs_h,\%_pagesrefs_p);
		foreach my $key (@keylist) {
			my $nompage=CleanFromCSSA($key);
			if (length($nompage)>$MaxLengthOfURL) { $nompage=substr($nompage,0,$MaxLengthOfURL)."..."; }
			my $p_p; my $p_h;
			if ($TotalRefererPages) { $p_p=int($_pagesrefs_p{$key}/$TotalRefererPages*1000)/10; }
			if ($TotalRefererHits) { $p_h=int($_pagesrefs_h{$key}/$TotalRefererHits*1000)/10; }
			print "<TR><TD CLASS=AWL>";
			&ShowURL($key);
			print "</TD>";
			print "<TD>".($_pagesrefs_p{$key}?$_pagesrefs_p{$key}:'&nbsp;')."</TD><TD>".($_pagesrefs_p{$key}?"$p_p %":'&nbsp;')."</TD>";
			print "<TD>".($_pagesrefs_h{$key}?$_pagesrefs_h{$key}:'&nbsp;')."</TD><TD>".($_pagesrefs_h{$key}?"$p_h %":'&nbsp;')."</TD>";
			print "</TR>\n";
			$total_p += $_pagesrefs_p{$key};
			$total_h += $_pagesrefs_h{$key};
			$count++;
		}
		if ($Debug) { debug("Total real / shown : $TotalRefererPages / $total_p - $TotalRefererHits / $total_h",2); }
		$rest_p=$TotalRefererPages-$total_p;
		$rest_h=$TotalRefererHits-$total_h;
		if ($rest_p > 0 || $rest_h > 0) {
			my $p_p; my $p_h;
			if ($TotalRefererPages) { $p_p=int($rest_p/$TotalRefererPages*1000)/10; }
			if ($TotalRefererHits) { $p_h=int($rest_h/$TotalRefererHits*1000)/10; }
			print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
			print "<TD>$rest_p</TD>";
			print "<TD>$p_p %</TD>";
			print "<TD>$rest_h</TD>";
			print "<TD>$p_h %</TD>";
			print "</TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'keyphrases'}) {
		print "$Center<a name=\"KEYPHRASES\">&nbsp;</a><BR>\n";
		&tab_head($Message[43],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"".($TOOLTIPON?" onmouseover=\"ShowTip(15);\" onmouseout=\"HideTip(15);\"":"")."><TH>$TotalDifferentKeyphrases $Message[103]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[14]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[15]</TH></TR>\n";
		$total_s=0;
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Keyphrase'},\%_keyphrases,\%_keyphrases);
		foreach my $key (@keylist) {
			my $mot = DecodeEncodedString(CleanFromCSSA($key));
			my $p;
			if ($TotalKeyphrases) { $p=int($_keyphrases{$key}/$TotalKeyphrases*1000)/10; }
			print "<TR><TD CLASS=AWL>$mot</TD><TD>$_keyphrases{$key}</TD><TD>$p %</TD></TR>\n";
			$total_s += $_keyphrases{$key};
			$count++;
		}
		if ($Debug) { debug("Total real / shown : $TotalKeyphrases / $total_s",2); }
		$rest_s=$TotalKeyphrases-$total_s;
		if ($rest_s > 0) {
			my $p;
			if ($TotalKeyphrases) { $p=int($rest_s/$TotalKeyphrases*1000)/10; }
			print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[124]</font></TD><TD>$rest_s</TD>";
			print "<TD>$p %</TD></TR>\n";
		}
		&tab_end;
		&html_end;
	}
	if ($HTMLOutput{'keywords'}) {
		print "$Center<a name=\"KEYWORDS\">&nbsp;</a><BR>\n";
		&tab_head($Message[44],19);
		print "<TR bgcolor=\"#$color_TableBGRowTitle\"".($TOOLTIPON?" onmouseover=\"ShowTip(15);\" onmouseout=\"HideTip(15);\"":"")."><TH>$TotalDifferentKeywords $Message[13]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[14]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[15]</TH></TR>\n";
		$total_s=0;
		my $count=0;
		&BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Keyword'},\%_keywords,\%_keywords);
		foreach my $key (@keylist) {
			my $mot = DecodeEncodedString(CleanFromCSSA($key));
			my $p;
			if ($TotalKeywords) { $p=int($_keywords{$key}/$TotalKeywords*1000)/10; }
			print "<TR><TD CLASS=AWL>$mot</TD><TD>$_keywords{$key}</TD><TD>$p %</TD></TR>\n";
			$total_s += $_keywords{$key};
			$count++;
		}
		if ($Debug) { debug("Total real / shown : $TotalKeywords / $total_s",2); }
		$rest_s=$TotalKeywords-$total_s;
		if ($rest_s > 0) {
			my $p;
			if ($TotalKeywords) { $p=int($rest_s/$TotalKeywords*1000)/10; }
			print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[30]</font></TD><TD>$rest_s</TD>";
			print "<TD>$p %</TD></TR>\n";
		}
		&tab_end;
		&html_end;
	}
	foreach my $code (keys %TrapInfosForHTTPErrorCodes) {
		if ($HTMLOutput{"errors$code"}) {
			print "$Center<a name=\"NOTFOUNDERROR\">&nbsp;</a><BR>\n";
			&tab_head($Message[47],19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>URL (".(scalar keys %_sider404_h).")</TH><TH bgcolor=\"#$color_h\">$Message[49]</TH><TH>$Message[23]</TH></TR>\n";
			my $count=0;
			&BuildKeyList($MaxRowsInHTMLOutput,1,\%_sider404_h,\%_sider404_h);
			foreach my $key (@keylist) {
				my $nompage=CleanFromCSSA($key);
				#if (length($nompage)>$MaxLengthOfURL) { $nompage=substr($nompage,0,$MaxLengthOfURL)."..."; }
				my $referer=CleanFromCSSA($_referer404_h{$key});
				print "<tr><td CLASS=AWL>$nompage</td><td>$_sider404_h{$key}</td><td CLASS=AWL>".($referer?"$referer":"&nbsp;")."</td></tr>\n";
				$count++;
			}
			&tab_end;
			&html_end;
		}
	}
	if ($HTMLOutput{'info'}) {
		# Not yet available
		print "$Center<a name=\"INFO\">&nbsp;</a><BR>";
		&html_end;
	}
	if ($HTMLOutput{'main'}) {

		# SUMMARY
		#---------------------------------------------------------------------
		if ($ShowMonthStats) {
			if ($Debug) { debug("ShowMonthStats",2); }
			print "$Center<a name=\"MONTH\">&nbsp;</a><BR>\n";
			my $title="$Message[128]";
			&tab_head("$title",0);
	
			my $NewLinkParams=${QueryString};
			$NewLinkParams =~ s/(^|&)update(=\w*|$)//i;
			$NewLinkParams =~ s/(^|&)staticlinks(=\w*|$)//i;
			$NewLinkParams =~ s/(^|&)year=[^&]*//i;
			$NewLinkParams =~ s/(^|&)month=[^&]*//i;
			$NewLinkParams =~ s/(^|&)framename=[^&]*//i;
			$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
			if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }
			my $NewLinkTarget='';
			if ($FrameName eq 'mainright') { $NewLinkTarget=" target=_parent"; }
	
			# Ratio
			my $RatioVisits=0; my $RatioPages=0; my $RatioHits=0; my $RatioBytes=0;
			if ($TotalUnique > 0) { $RatioVisits=int($TotalVisits/$TotalUnique*100)/100; }
			if ($TotalVisits > 0) { $RatioPages=int($TotalPages/$TotalVisits*100)/100; }
			if ($TotalVisits > 0) { $RatioHits=int($TotalHits/$TotalVisits*100)/100; }
			if ($TotalVisits > 0) { $RatioBytes=int(($TotalBytes/1024)*100/$TotalVisits)/100; }
	
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TD><b>$Message[8]</b></TD>\n";
			print "<TD colspan=3>$Message[128]</TD>";
			print "<TD><b>$Message[9]</b></TD></TR>\n";
			if ($FirstTime) { print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TD>".Format_Date($FirstTime,0)."</TD>"; }
			else { print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TD>NA</TD>"; }
			print "<TD colspan=3><b>";
			print ($MonthRequired eq 'all'?"$Message[6] $YearRequired":"$Message[5] ".$MonthLib{$MonthRequired}." $YearRequired");
			print "</b></TD>";
			if ($LastTime) { print "<TD>".Format_Date($LastTime,0)."</TD></TR>\n"; }
			else { print "<TD>NA</TD></TR>\n"; }
			# Show main indicators
			print "<TR>";
			if ($ShowMonthStats =~ /U/i) { print "<TD width=\"20%\" bgcolor=\"#$color_u\"".($TOOLTIPON?" onmouseover=\"ShowTip(2);\" onmouseout=\"HideTip(2);\"":"").">$Message[11]</TD>"; } else { print "<TD width=\"20%\">&nbsp;</TD>"; }
			if ($ShowMonthStats =~ /V/i) { print "<TD width=\"20%\" bgcolor=\"#$color_v\"".($TOOLTIPON?" onmouseover=\"ShowTip(1);\" onmouseout=\"HideTip(1);\"":"").">$Message[10]</TD>"; } else { print "<TD width=\"20%\">&nbsp;</TD>"; }
			if ($ShowMonthStats =~ /P/i) { print "<TD width=\"20%\" bgcolor=\"#$color_p\"".($TOOLTIPON?" onmouseover=\"ShowTip(3);\" onmouseout=\"HideTip(3);\"":"").">$Message[56]</TD>"; } else { print "<TD width=\"20%\">&nbsp;</TD>"; }
			if ($ShowMonthStats =~ /H/i) { print "<TD width=\"20%\" bgcolor=\"#$color_h\"".($TOOLTIPON?" onmouseover=\"ShowTip(4);\" onmouseout=\"HideTip(4);\"":"").">$Message[57]</TD>"; } else { print "<TD width=\"20%\">&nbsp;</TD>"; }
			if ($ShowMonthStats =~ /B/i) { print "<TD width=\"20%\" bgcolor=\"#$color_k\"".($TOOLTIPON?" onmouseover=\"ShowTip(5);\" onmouseout=\"HideTip(5);\"":"").">$Message[75]</TD>"; } else { print "<TD width=\"20%\">&nbsp;</TD>"; }
			print "</TR>\n";
			print "<TR>";
			if ($ShowMonthStats =~ /U/i) { print "<TD>".($MonthRequired eq 'all'?"<b><= $TotalUnique</b><br>$Message[129]":"<b>$TotalUnique</b><br>&nbsp;")."</TD>"; } else { print "<TD>&nbsp;</TD>"; }
			if ($ShowMonthStats =~ /V/i) { print "<TD><b>$TotalVisits</b><br>($RatioVisits&nbsp;$Message[52])</TD>"; } else { print "<TD>&nbsp;</TD>"; }
			if ($ShowMonthStats =~ /P/i) { print "<TD><b>$TotalPages</b><br>($RatioPages&nbsp;".lc($Message[56]."/".$Message[12]).")</TD>"; } else { print "<TD>&nbsp;</TD>"; }
			if ($ShowMonthStats =~ /H/i) { print "<TD><b>$TotalHits</b><br>($RatioHits&nbsp;".lc($Message[57]."/".$Message[12]).")</TD>"; } else { print "<TD>&nbsp;</TD>"; }
			if ($ShowMonthStats =~ /B/i) { print "<TD><b>".Format_Bytes(int($TotalBytes))."</b><br>($RatioBytes&nbsp;$Message[108]/".lc($Message[12]).")</TD>"; } else { print "<TD>&nbsp;</TD>"; }
			print "</TR>\n";
	
			my $colspan=5;
			print "<TR valign=bottom><TD align=center colspan=$colspan>";
	
			$average_nb=$average_u=$average_v=$average_p=$average_h=$average_k=0;
			$total_u=$total_v=$total_p=$total_h=$total_k=0;
			print "<CENTER>";
			print "<TABLE>";
			$max_v=$max_p=$max_h=$max_k=1;
			# Define total and max
			for (my $ix=1; $ix<=12; $ix++) {
				my $monthix=sprintf("%02s",$ix);
				$total_u+=$MonthUnique{$YearRequired.$monthix}||0;
				$total_v+=$MonthVisits{$YearRequired.$monthix}||0;
				$total_p+=$MonthPages{$YearRequired.$monthix}||0;
				$total_h+=$MonthHits{$YearRequired.$monthix}||0;
				$total_k+=$MonthBytes{$YearRequired.$monthix}||0;
				#if ($MonthUnique{$YearRequired.$monthix} > $max_v) { $max_v=$MonthUnique{$YearRequired.$monthix}; }
				if ($MonthVisits{$YearRequired.$monthix} > $max_v) { $max_v=$MonthVisits{$YearRequired.$monthix}; }
				#if ($MonthPages{$YearRequired.$monthix} > $max_p)  { $max_p=$MonthPages{$YearRequired.$monthix}; }
				if ($MonthHits{$YearRequired.$monthix} > $max_h)   { $max_h=$MonthHits{$YearRequired.$monthix}; }
				if ($MonthBytes{$YearRequired.$monthix} > $max_k)  { $max_k=$MonthBytes{$YearRequired.$monthix}; }
			}
			# Define average
			# TODO
			# Show bars for month
			print "<TR valign=bottom>";
			print "<TD>&nbsp;</TD>\n";
			for (my $ix=1; $ix<=12; $ix++) {
				my $monthix=sprintf("%02s",$ix);
				my $bredde_u=0; my $bredde_v=0;my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
				if ($max_v > 0) { $bredde_u=int($MonthUnique{$YearRequired.$monthix}/$max_v*$BarHeight)+1; }
				if ($max_v > 0) { $bredde_v=int($MonthVisits{$YearRequired.$monthix}/$max_v*$BarHeight)+1; }
				if ($max_h > 0) { $bredde_p=int($MonthPages{$YearRequired.$monthix}/$max_h*$BarHeight)+1; }
				if ($max_h > 0) { $bredde_h=int($MonthHits{$YearRequired.$monthix}/$max_h*$BarHeight)+1; }
				if ($max_k > 0) { $bredde_k=int($MonthBytes{$YearRequired.$monthix}/$max_k*$BarHeight)+1; }
				print "<TD>";
				if ($ShowMonthStats =~ /U/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_u\" HEIGHT=$bredde_u WIDTH=6 ALT=\"$Message[11]: $MonthUnique{$YearRequired.$monthix}\" title=\"$Message[11]: $MonthUnique{$YearRequired.$monthix}\">"; }
				if ($ShowMonthStats =~ /V/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=6 ALT=\"$Message[10]: $MonthVisits{$YearRequired.$monthix}\" title=\"$Message[10]: $MonthVisits{$YearRequired.$monthix}\">"; }
				print "&nbsp;";
				if ($ShowMonthStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=6 ALT=\"$Message[56]: $MonthPages{$YearRequired.$monthix}\" title=\"$Message[56]: $MonthPages{$YearRequired.$monthix}\">"; }
				if ($ShowMonthStats =~ /H/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=6 ALT=\"$Message[57]: $MonthHits{$YearRequired.$monthix}\" title=\"$Message[57]: $MonthHits{$YearRequired.$monthix}\">"; }
				if ($ShowMonthStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=6 ALT=\"$Message[75]: ".Format_Bytes($MonthBytes{$YearRequired.$monthix})."\" title=\"$Message[75]: ".Format_Bytes($MonthBytes{$YearRequired.$monthix})."\">"; }
				print "</TD>\n";
			}
			print "<TD>&nbsp;</TD>";
			print "</TR>\n";
			# Show lib for month
			print "<TR valign=middle>";
#			if ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) {
#				print "<TD><a href=\"$AWScript?${NewLinkParams}month=12&year=".($YearRequired-1)."\">&lt;&lt;</a></TD>";
#			}
#			else {
				print "<TD>&nbsp;</TD>";
#			}
			for (my $ix=1; $ix<=12; $ix++) {
				my $monthix=sprintf("%02s",$ix);
#				if ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) {
#					print "<TD><a href=\"$AWScript?${NewLinkParams}month=$monthix&year=$YearRequired\">$MonthLib{$monthix}<br>$YearRequired</a></TD>";
#				}
#				else {
					print "<TD>$MonthLib{$monthix}<br>$YearRequired</TD>";
#				}
			}
#			if ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) {
#				print "<TD><a href=\"$AWScript?${NewLinkParams}month=1&year=".($YearRequired+1)."\">&gt;&gt;</a></TD>";
#			}
#			else {
				print "<TD>&nbsp;</TD>";
#			}
			print "</TR>\n";
			print "</TABLE>\n<br>\n";
	
			# Show data array for month
			if ($AddDataArrayMonthStats) {
				print "<TABLE>\n";
				print "<TR><TD width=\"80\" bgcolor=\"#$color_TableBGRowTitle\">$Message[5]</TD>";
				if ($ShowMonthStats =~ /U/i) { print "<TD width=\"80\" bgcolor=\"#$color_u\"".($TOOLTIPON?" onmouseover=\"ShowTip(2);\" onmouseout=\"HideTip(2);\"":"").">$Message[11]</TD>"; }
				if ($ShowMonthStats =~ /V/i) { print "<TD width=\"80\" bgcolor=\"#$color_v\"".($TOOLTIPON?" onmouseover=\"ShowTip(1);\" onmouseout=\"HideTip(1);\"":"").">$Message[10]</TD>"; }
				if ($ShowMonthStats =~ /P/i) { print "<TD width=\"80\" bgcolor=\"#$color_p\"".($TOOLTIPON?" onmouseover=\"ShowTip(3);\" onmouseout=\"HideTip(3);\"":"").">$Message[56]</TD>"; }
				if ($ShowMonthStats =~ /H/i) { print "<TD width=\"80\" bgcolor=\"#$color_h\"".($TOOLTIPON?" onmouseover=\"ShowTip(4);\" onmouseout=\"HideTip(4);\"":"").">$Message[57]</TD>"; }
				if ($ShowMonthStats =~ /B/i) { print "<TD width=\"80\" bgcolor=\"#$color_k\"".($TOOLTIPON?" onmouseover=\"ShowTip(5);\" onmouseout=\"HideTip(5);\"":"").">$Message[75]</TD>"; }
				print "</TR>\n";
				for (my $ix=1; $ix<=12; $ix++) {
					my $monthix=sprintf("%02s",$ix);
					print "<TR>";
					print "<TD>$MonthLib{$monthix} $YearRequired</TD>";
					if ($ShowMonthStats =~ /U/i) { print "<TD>",$MonthUnique{$YearRequired.$monthix}?$MonthUnique{$YearRequired.$monthix}:"0","</TD>"; }
					if ($ShowMonthStats =~ /V/i) { print "<TD>",$MonthVisits{$YearRequired.$monthix}?$MonthVisits{$YearRequired.$monthix}:"0","</TD>"; }
					if ($ShowMonthStats =~ /P/i) { print "<TD>",$MonthPages{$YearRequired.$monthix}?$MonthPages{$YearRequired.$monthix}:"0","</TD>"; }
					if ($ShowMonthStats =~ /H/i) { print "<TD>",$MonthHits{$YearRequired.$monthix}?$MonthHits{$YearRequired.$monthix}:"0","</TD>"; }
					if ($ShowMonthStats =~ /B/i) { print "<TD>",Format_Bytes(int($MonthBytes{$YearRequired.$monthix})),"</TD>"; }
					print "</TR>\n";
				}
				# Average row
				# TODO
				# Total row
				print "<TR><TD bgcolor=\"#$color_TableBGRowTitle\">$Message[102]</TD>";
				if ($ShowMonthStats =~ /U/i) { print "<TD bgcolor=\"#$color_TableBGRowTitle\">$total_u</TD>"; }
				if ($ShowMonthStats =~ /V/i) { print "<TD bgcolor=\"#$color_TableBGRowTitle\">$total_v</TD>"; }
				if ($ShowMonthStats =~ /P/i) { print "<TD bgcolor=\"#$color_TableBGRowTitle\">$total_p</TD>"; }
				if ($ShowMonthStats =~ /H/i) { print "<TD bgcolor=\"#$color_TableBGRowTitle\">$total_h</TD>"; }
				if ($ShowMonthStats =~ /B/i) { print "<TD bgcolor=\"#$color_TableBGRowTitle\">".Format_Bytes($total_k)."</TD>"; }
				print "</TR>\n";		
				print "</TABLE>\n<br>\n";
			}
				
			print "</CENTER>\n";
			print "</TD></TR>\n";
			&tab_end;
		}
	
		print "\n<a name=\"WHEN\">&nbsp;</a>\n\n";

		# BY DAY OF MONTH
		#---------------------------------------------------------------------
		if ($ShowDaysOfMonthStats) {
			if ($Debug) { debug("ShowDaysOfMonthStats",2); }
			print "$Center<a name=\"DAYOFMONTH\">&nbsp;</a><BR>\n";
			my $title="$Message[138]";
			&tab_head("$title",0);
			print "<TR>";
			print "<TD align=center><center><TABLE>";
			print "<TR valign=bottom>\n";
	
			my $NewLinkParams=${QueryString};
			$NewLinkParams =~ s/(^|&)update(=\w*|$)//i;
			$NewLinkParams =~ s/(^|&)staticlinks(=\w*|$)//i;
			$NewLinkParams =~ s/(^|&)year=[^&]*//i;
			$NewLinkParams =~ s/(^|&)month=[^&]*//i;
			$NewLinkParams =~ s/(^|&)framename=[^&]*//i;
			$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
			if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }
			my $NewLinkTarget='';
			if ($FrameName eq 'mainright') { $NewLinkTarget=" target=_parent"; }
				
			$average_nb=$average_u=$average_v=$average_p=$average_h=$average_k=0;
			$total_u=$total_v=$total_p=$total_h=$total_k=0;
			# Define total and max
			$max_v=$max_h=$max_k=0;		# Start from 0 because can be lower than 1
			foreach my $daycursor ($firstdaytoshowtime..$lastdaytoshowtime) {
				$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
				my $year=$1; my $month=$2; my $day=$3;
				if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
				$total_v+=$DayVisits{$year.$month.$day}||0;
				$total_p+=$DayPages{$year.$month.$day}||0;
				$total_h+=$DayHits{$year.$month.$day}||0;
				$total_k+=$DayBytes{$year.$month.$day}||0;
				if (($DayVisits{$year.$month.$day}||0) > $max_v)  { $max_v=$DayVisits{$year.$month.$day}; }
				#if (($DayPages{$year.$month.$day}||0) > $max_p)  { $max_p=$DayPages{$year.$month.$day}; }
				if (($DayHits{$year.$month.$day}||0) > $max_h)   { $max_h=$DayHits{$year.$month.$day}; }
				if (($DayBytes{$year.$month.$day}||0) > $max_k)  { $max_k=$DayBytes{$year.$month.$day}; }
			}
			# Define average
			foreach my $daycursor ($firstdaytocountaverage..$lastdaytocountaverage) {
				$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
				my $year=$1; my $month=$2; my $day=$3;
				if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
				$average_nb++;											# Increase number of day used to count
				$average_v+=($DayVisits{$daycursor}||0);
				$average_p+=($DayPages{$daycursor}||0);
				$average_h+=($DayHits{$daycursor}||0);
				$average_k+=($DayBytes{$daycursor}||0);
			}
			if ($average_nb) {
				$average_v=$average_v/$average_nb;
				$average_p=$average_p/$average_nb;
				$average_h=$average_h/$average_nb;
				$average_k=$average_k/$average_nb;
				if ($average_v > $max_v) { $max_v=$average_v; }
				#if ($average_p > $max_p) { $max_p=$average_p; }
				if ($average_h > $max_h) { $max_h=$average_h; }
				if ($average_k > $max_k) { $max_k=$average_k; }
			}
			else {
				$average_v="?";
				$average_p="?";
				$average_h="?";
				$average_k="?";
			}
			# Show bars for day
			foreach my $daycursor ($firstdaytoshowtime..$lastdaytoshowtime) {
				$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
				my $year=$1; my $month=$2; my $day=$3;
				if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
				my $bredde_v=0; my $bredde_p=0; my $bredde_h=0; my $bredde_k=0;
				if ($max_v > 0) { $bredde_v=int(($DayVisits{$year.$month.$day}||0)/$max_v*$BarHeight)+1; }
				if ($max_h > 0) { $bredde_p=int(($DayPages{$year.$month.$day}||0)/$max_h*$BarHeight)+1; }
				if ($max_h > 0) { $bredde_h=int(($DayHits{$year.$month.$day}||0)/$max_h*$BarHeight)+1; }
				if ($max_k > 0) { $bredde_k=int(($DayBytes{$year.$month.$day}||0)/$max_k*$BarHeight)+1; }
				print "<TD>";
				if ($ShowDaysOfMonthStats =~ /V/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=4 ALT=\"$Message[10]: ".int($DayVisits{$year.$month.$day}||0)."\" title=\"$Message[10]: ".int($DayVisits{$year.$month.$day}||0)."\">"; }
				if ($ShowDaysOfMonthStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=4 ALT=\"$Message[56]: ".int($DayPages{$year.$month.$day}||0)."\" title=\"$Message[56]: ".int($DayPages{$year.$month.$day}||0)."\">"; }
				if ($ShowDaysOfMonthStats =~ /H/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=4 ALT=\"$Message[57]: ".int($DayHits{$year.$month.$day}||0)."\" title=\"$Message[57]: ".int($DayHits{$year.$month.$day}||0)."\">"; }
				if ($ShowDaysOfMonthStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=4 ALT=\"$Message[75]: ".Format_Bytes($DayBytes{$year.$month.$day})."\" title=\"$Message[75]: ".Format_Bytes($DayBytes{$year.$month.$day})."\">"; }
				print "</TD>\n";
			}
			print "<TD>&nbsp;</TD>";
			# Show average value cell
			print "<TD>";
			my $bredde_v=0; my $bredde_p=0; my $bredde_h=0; my $bredde_k=0;
			if ($max_v > 0) { $bredde_v=int($average_v/$max_v*$BarHeight)+1; }
			if ($max_h > 0) { $bredde_p=int($average_p/$max_h*$BarHeight)+1; }
			if ($max_h > 0) { $bredde_h=int($average_h/$max_h*$BarHeight)+1; }
			if ($max_k > 0) { $bredde_k=int($average_k/$max_k*$BarHeight)+1; }
			$average_v=sprintf("%.2f",$average_v);
			$average_p=sprintf("%.2f",$average_p);
			$average_h=sprintf("%.2f",$average_h);
			$average_k=(int($average_k)?Format_Bytes(sprintf("%.2f",$average_k)):"0.00");
			if ($ShowDaysOfMonthStats =~ /V/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=4 ALT=\"$Message[10]: $average_v\" title=\"$Message[10]: $average_v\">"; }
			if ($ShowDaysOfMonthStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=4 ALT=\"$Message[56]: $average_p\" title=\"$Message[56]: $average_p\">"; }
			if ($ShowDaysOfMonthStats =~ /H/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=4 ALT=\"$Message[57]: $average_h\" title=\"$Message[57]: $average_h\">"; }
			if ($ShowDaysOfMonthStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=4 ALT=\"$Message[75]: $average_k\" title=\"$Message[75]: $average_k\">"; }
			print "</TD>\n";
			print "</TR>\n";
			# Show lib for day
			print "<TR valign=middle>";
			foreach my $daycursor ($firstdaytoshowtime..$lastdaytoshowtime) {
				$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
				my $year=$1; my $month=$2; my $day=$3;
				if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
				my $dayofweekcursor=DayOfWeek($day,$month,$year);
				print "<TD".($dayofweekcursor=~/[06]/?" bgcolor=\"#$color_weekend\"":"").">";
				print ($day==$nowday && $month==$nowmonth && $year==$nowyear?'<b>':'');
				print "$day<br><font style=\"font-size: ".($FrameName ne 'mainright'?"10":"9")."px;\">".$MonthLib{$month}."</font>";
				print ($day==$nowday && $month==$nowmonth && $year==$nowyear?'</b>':'');
				print "</TD>\n";
			}
			print "<TD>&nbsp;</TD>";
			print "<TD valign=middle".($TOOLTIPON?" onmouseover=\"ShowTip(18);\" onmouseout=\"HideTip(18);\"":"").">$Message[96]</TD>\n";
	
			print "</TR>\n";
			print "</TABLE>\n<br>\n";
	
			# Show data array for days
			if ($AddDataArrayShowDaysOfMonthStats) {
				print "<TABLE>\n";
				print "<TR><TD width=\"80\" bgcolor=\"#$color_TableBGRowTitle\">$Message[4]</TD>";
				if ($ShowDaysOfMonthStats =~ /V/i) { print "<TD width=\"80\" bgcolor=\"#$color_v\"".($TOOLTIPON?" onmouseover=\"ShowTip(1);\" onmouseout=\"HideTip(1);\"":"").">$Message[10]</TD>"; }
				if ($ShowDaysOfMonthStats =~ /P/i) { print "<TD width=\"80\" bgcolor=\"#$color_p\"".($TOOLTIPON?" onmouseover=\"ShowTip(3);\" onmouseout=\"HideTip(3);\"":"").">$Message[56]</TD>"; }
				if ($ShowDaysOfMonthStats =~ /H/i) { print "<TD width=\"80\" bgcolor=\"#$color_h\"".($TOOLTIPON?" onmouseover=\"ShowTip(4);\" onmouseout=\"HideTip(4);\"":"").">$Message[57]</TD>"; }
				if ($ShowDaysOfMonthStats =~ /B/i) { print "<TD width=\"80\" bgcolor=\"#$color_k\"".($TOOLTIPON?" onmouseover=\"ShowTip(5);\" onmouseout=\"HideTip(5);\"":"").">$Message[75]</TD></TR>"; }
				foreach my $daycursor ($firstdaytoshowtime..$lastdaytoshowtime) {
					$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
					my $year=$1; my $month=$2; my $day=$3;
					if (! DateIsValid($day,$month,$year)) { next; }			# If not an existing day, go to next
					my $dayofweekcursor=DayOfWeek($day,$month,$year);
					print "<TR".($dayofweekcursor=~/[06]/?" bgcolor=\"#$color_weekend\"":"").">";
					print "<TD>",Format_Date("$year$month$day"."000000",2),"</TD>";
					if ($ShowDaysOfMonthStats =~ /V/i) { print "<TD>",$DayVisits{$year.$month.$day}?$DayVisits{$year.$month.$day}:"0","</TD>"; }
					if ($ShowDaysOfMonthStats =~ /P/i) { print "<TD>",$DayPages{$year.$month.$day}?$DayPages{$year.$month.$day}:"0","</TD>"; }
					if ($ShowDaysOfMonthStats =~ /H/i) { print "<TD>",$DayHits{$year.$month.$day}?$DayHits{$year.$month.$day}:"0","</TD>"; }
					if ($ShowDaysOfMonthStats =~ /B/i) { print "<TD>",Format_Bytes(int($DayBytes{$year.$month.$day})),"</TD>"; }
					print "</TR>\n";
				}
				# Average row
				print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TD>$Message[96]</TD>";
				if ($ShowDaysOfMonthStats =~ /V/i) { print "<TD>$average_v</TD>"; }
				if ($ShowDaysOfMonthStats =~ /P/i) { print "<TD>$average_p</TD>"; }
				if ($ShowDaysOfMonthStats =~ /H/i) { print "<TD>$average_h</TD>"; }
				if ($ShowDaysOfMonthStats =~ /B/i) { print "<TD>$average_k</TD>"; }
				print "</TR>\n";		
				# Total row
				print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TD>$Message[102]</TD>";
				if ($ShowDaysOfMonthStats =~ /V/i) { print "<TD>$total_v</TD>"; }
				if ($ShowDaysOfMonthStats =~ /P/i) { print "<TD>$total_p</TD>"; }
				if ($ShowDaysOfMonthStats =~ /H/i) { print "<TD>$total_h</TD>"; }
				if ($ShowDaysOfMonthStats =~ /B/i) { print "<TD>".Format_Bytes($total_k)."</TD>"; }
				print "</TR>\n";		
				print "</TABLE>\n<br>";
			}
				
			print "</CENTER>\n";
			print "</TD></TR>\n";
			&tab_end;
		}

		# BY DAY OF WEEK
		#-------------------------
		if ($ShowDaysOfWeekStats) {
			if ($Debug) { debug("ShowDaysOfWeekStats",2); }
			print "$Center<a name=\"DAYOFWEEK\">&nbsp;</a><BR>\n";
			&tab_head("$Message[91]",18);
			print "<TR>";
			print "<TD align=center><center><TABLE>";
			print "<TR valign=bottom>\n";
			$max_h=$max_k=0;	# Start from 0 because can be lower than 1
			# Get average value for day of week
			my @avg_dayofweek_nb = my @avg_dayofweek_p = my @avg_dayofweek_h = my @avg_dayofweek_k = ();
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
			for (@DOWIndex) {
				if ($avg_dayofweek_nb[$_]) {
					$avg_dayofweek_p[$_]=$avg_dayofweek_p[$_]/$avg_dayofweek_nb[$_];
					$avg_dayofweek_h[$_]=$avg_dayofweek_h[$_]/$avg_dayofweek_nb[$_];
					$avg_dayofweek_k[$_]=$avg_dayofweek_k[$_]/$avg_dayofweek_nb[$_];
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
				my $bredde_p=0; my $bredde_h=0; my $bredde_k=0;
				if ($max_h > 0) { $bredde_p=int($avg_dayofweek_p[$_]/$max_h*$BarHeight)+1; }
				if ($max_h > 0) { $bredde_h=int($avg_dayofweek_h[$_]/$max_h*$BarHeight)+1; }
				if ($max_k > 0) { $bredde_k=int($avg_dayofweek_k[$_]/$max_k*$BarHeight)+1; }
				$avg_dayofweek_p[$_]=sprintf("%.2f",$avg_dayofweek_p[$_]);
				$avg_dayofweek_h[$_]=sprintf("%.2f",$avg_dayofweek_h[$_]);
				$avg_dayofweek_k[$_]=sprintf("%.2f",$avg_dayofweek_k[$_]);
				# Remove decimal part if 0
				if ($avg_dayofweek_p[$_] == int($avg_dayofweek_p[$_])) { $avg_dayofweek_p[$_]=int($avg_dayofweek_p[$_]); }
				if ($avg_dayofweek_h[$_] == int($avg_dayofweek_h[$_])) { $avg_dayofweek_h[$_]=int($avg_dayofweek_h[$_]); }
				print "<TD valign=bottom>";
				if ($ShowDaysOfWeekStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=6 ALT=\"$Message[56]: $avg_dayofweek_p[$_]\" title=\"$Message[56]: $avg_dayofweek_p[$_]\">"; }
				if ($ShowDaysOfWeekStats =~ /H/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=6 ALT=\"$Message[57]: $avg_dayofweek_h[$_]\" title=\"$Message[57]: $avg_dayofweek_h[$_]\">"; }
				if ($ShowDaysOfWeekStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=6 ALT=\"$Message[75]: ".Format_Bytes($avg_dayofweek_k[$_])."\" title=\"$Message[75]: ".Format_Bytes($avg_dayofweek_k[$_])."\">"; }
				print "</TD>\n";
			}
			print "</TR>\n";
			print "<TR".($TOOLTIPON?" onmouseover=\"ShowTip(17);\" onmouseout=\"HideTip(17);\"":"").">\n";
			for (@DOWIndex) {
				print "<TD".($_=~/[06]/?" bgcolor=\"#$color_weekend\"":"").">".$Message[$_+84]."</TD>";
			}
			print "</TR>\n</TABLE>\n";
			print "<br>\n";
			
			# Show data array for days of week
			if ($AddDataArrayShowDaysOfWeekStats) {
				print "<TABLE>\n";
				print "<TR><TD width=\"80\" bgcolor=\"#$color_TableBGRowTitle\">$Message[4]</TD>";
				if ($ShowDaysOfWeekStats =~ /P/i) { print "<TD width=\"80\" bgcolor=\"#$color_p\"".($TOOLTIPON?" onmouseover=\"ShowTip(3);\" onmouseout=\"HideTip(3);\"":"").">$Message[56]</TD>"; }
				if ($ShowDaysOfWeekStats =~ /H/i) { print "<TD width=\"80\" bgcolor=\"#$color_h\"".($TOOLTIPON?" onmouseover=\"ShowTip(4);\" onmouseout=\"HideTip(4);\"":"").">$Message[57]</TD>"; }
				if ($ShowDaysOfWeekStats =~ /B/i) { print "<TD width=\"80\" bgcolor=\"#$color_k\"".($TOOLTIPON?" onmouseover=\"ShowTip(5);\" onmouseout=\"HideTip(5);\"":"").">$Message[75]</TD></TR>"; }
				for (@DOWIndex) {
					print "<TR".($_=~/[06]/?" bgcolor=\"#$color_weekend\"":"").">";
					print "<TD>".$Message[$_+84]."</TD>";
					if ($ShowDaysOfWeekStats =~ /P/i) { print "<TD>",$avg_dayofweek_p[$_],"</TD>"; }
					if ($ShowDaysOfWeekStats =~ /H/i) { print "<TD>",$avg_dayofweek_h[$_],"</TD>"; }
					if ($ShowDaysOfWeekStats =~ /B/i) { print "<TD>",Format_Bytes($avg_dayofweek_k[$_]),"</TD>"; }
					print "</TR>\n";
				}
				print "</TABLE>\n<br>\n";
			}
						
			print "</center></TD>";
			print "</TR>\n";
			&tab_end;
		}
	
		# BY HOUR
		#----------------------------
		if ($ShowHoursStats) {
			if ($Debug) { debug("ShowHoursStats",2); }
			print "$Center<a name=\"HOUR\">&nbsp;</a><BR>\n";
			my $title="$Message[20]";
			if ($PluginsLoaded{'GetTimeZoneTitle'}{'timezone'}) { $title.=" (GMT ".(GetTimeZoneTitle_timezone()>=0?"+":"").int(GetTimeZoneTitle_timezone()).")"; }
			&tab_head("$title",19);
			print "<TR><TD align=center><center><TABLE>\n";
			$max_h=$max_k=1;
			for (my $ix=0; $ix<=23; $ix++) {
			  #if ($_time_p[$ix]>$max_p) { $max_p=$_time_p[$ix]; }
			  if ($_time_h[$ix]>$max_h) { $max_h=$_time_h[$ix]; }
			  if ($_time_k[$ix]>$max_k) { $max_k=$_time_k[$ix]; }
			}
			print "<TR valign=bottom>\n";
			for (my $ix=0; $ix<=23; $ix++) {
				my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
				if ($max_h > 0) { $bredde_p=int($BarHeight*$_time_p[$ix]/$max_h)+1; }
				if ($max_h > 0) { $bredde_h=int($BarHeight*$_time_h[$ix]/$max_h)+1; }
				if ($max_k > 0) { $bredde_k=int($BarHeight*$_time_k[$ix]/$max_k)+1; }
				print "<TD>";
				if ($ShowHoursStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=6 ALT=\"$Message[56]: ".int($_time_p[$ix])."\" title=\"$Message[56]: ".int($_time_p[$ix])."\">"; }
				if ($ShowHoursStats =~ /H/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=6 ALT=\"$Message[57]: ".int($_time_h[$ix])."\" title=\"$Message[57]: ".int($_time_h[$ix])."\">"; }
				if ($ShowHoursStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=6 ALT=\"$Message[75]: ".Format_Bytes($_time_k[$ix])."\" title=\"$Message[75]: ".Format_Bytes($_time_k[$ix])."\">"; }
				print "</TD>\n";
			}
			print "</TR>\n";
			# Show hour lib
			print "<TR".($TOOLTIPON?" onmouseover=\"ShowTip(17);\" onmouseout=\"HideTip(17);\"":"").">";
			for (my $ix=0; $ix<=23; $ix++) {
			  print "<TH width=19>$ix</TH>\n";	# width=19 instead of 18 to avoid a MacOS browser bug.
			}
			print "</TR>\n";
			# Show clock icon
			print "<TR".($TOOLTIPON?" onmouseover=\"ShowTip(17);\" onmouseout=\"HideTip(17);\"":"").">\n";
			for (my $ix=0; $ix<=23; $ix++) {
				my $hr=($ix+1); if ($hr>12) { $hr=$hr-12; }
				print "<TD><IMG SRC=\"$DirIcons\/clock\/hr$hr.png\" width=10 alt=\"$hr:00\"></TD>\n";
			}
			print "</TR>\n";
	
			print "</TABLE>\n";
			print "<br>\n";
			
			# Show data array for hours
			if ($AddDataArrayShowHoursStats) {
				print "<TABLE><TR><TD>\n";
				print "<TABLE>\n";
				print "<TR><TD width=\"80\" bgcolor=\"#$color_TableBGRowTitle\">$Message[20]</TD>";
				if ($ShowHoursStats =~ /P/i) { print "<TD width=\"80\" bgcolor=\"#$color_p\"".($TOOLTIPON?" onmouseover=\"ShowTip(3);\" onmouseout=\"HideTip(3);\"":"").">$Message[56]</TD>"; }
				if ($ShowHoursStats =~ /H/i) { print "<TD width=\"80\" bgcolor=\"#$color_h\"".($TOOLTIPON?" onmouseover=\"ShowTip(4);\" onmouseout=\"HideTip(4);\"":"").">$Message[57]</TD>"; }
				if ($ShowHoursStats =~ /B/i) { print "<TD width=\"80\" bgcolor=\"#$color_k\"".($TOOLTIPON?" onmouseover=\"ShowTip(5);\" onmouseout=\"HideTip(5);\"":"").">$Message[75]</TD>"; }
				print "</TR>";
				for (my $ix=0; $ix<=11; $ix++) {
					my $monthix=($ix<10?"0$ix":"$ix");
					print "<TR>";
					print "<TD>$monthix</TD>";
					if ($ShowHoursStats =~ /P/i) { print "<TD>",$_time_p[$monthix]?$_time_p[$monthix]:"0","</TD>"; }
					if ($ShowHoursStats =~ /H/i) { print "<TD>",$_time_h[$monthix]?$_time_h[$monthix]:"0","</TD>"; }
					if ($ShowHoursStats =~ /B/i) { print "<TD>",Format_Bytes(int($_time_k[$monthix])),"</TD>"; }
					print "</TR>\n";
				}
				print "</TABLE>\n";
				print "</TD><TD>\n";
				print "<TABLE>\n";
				print "<TR><TD width=\"80\" bgcolor=\"#$color_TableBGRowTitle\">$Message[20]</TD>";
				if ($ShowHoursStats =~ /P/i) { print "<TD width=\"80\" bgcolor=\"#$color_p\"".($TOOLTIPON?" onmouseover=\"ShowTip(3);\" onmouseout=\"HideTip(3);\"":"").">$Message[56]</TD>"; }
				if ($ShowHoursStats =~ /H/i) { print "<TD width=\"80\" bgcolor=\"#$color_h\"".($TOOLTIPON?" onmouseover=\"ShowTip(4);\" onmouseout=\"HideTip(4);\"":"").">$Message[57]</TD>"; }
				if ($ShowHoursStats =~ /B/i) { print "<TD width=\"80\" bgcolor=\"#$color_k\"".($TOOLTIPON?" onmouseover=\"ShowTip(5);\" onmouseout=\"HideTip(5);\"":"").">$Message[75]</TD>"; }
				print "</TR>\n";
				for (my $ix=12; $ix<=23; $ix++) {
					my $monthix=($ix<10?"0$ix":"$ix");
					print "<TR>";
					print "<TD>$monthix</TD>";
					if ($ShowHoursStats =~ /P/i) { print "<TD>",$_time_p[$monthix]?$_time_p[$monthix]:"0","</TD>"; }
					if ($ShowHoursStats =~ /H/i) { print "<TD>",$_time_h[$monthix]?$_time_h[$monthix]:"0","</TD>"; }
					if ($ShowHoursStats =~ /B/i) { print "<TD>",Format_Bytes(int($_time_k[$monthix])),"</TD>"; }
					print "</TR>\n";
				}
				print "</TABLE>\n";
				print "</TD></TR>\n";
				print "</TABLE>\n<br>\n";
			}
					
			print "</center></TD></TR>\n";
			&tab_end;
		}
	
		print "\n<a name=\"WHO\">&nbsp;</a>\n\n";
	
		# BY COUNTRY/DOMAIN
		#---------------------------
		if ($ShowDomainsStats) {
			if ($Debug) { debug("ShowDomainsStats",2); }
			print "$Center<a name=\"DOMAINS\">&nbsp;</a><BR>\n";
			my $title="$Message[25] ($Message[77] $MaxNbOf{'Domain'}) &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=alldomains":"$PROG$StaticLinks.alldomains.html")."\"$NewLinkTarget>$Message[80]</a>";
			&tab_head("$title",19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH width=$WIDTHCOLICON>&nbsp;</TH><TH colspan=2>$Message[17]</TH>";
			if ($ShowDomainsStats =~ /P/i) { print "<TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH>"; }
			if ($ShowDomainsStats =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
			if ($ShowDomainsStats =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
			print "<TH>&nbsp;</TH>";
			print "</TR>\n";
			$total_p=$total_h=$total_k=0;
			$max_h=1; foreach my $key (values %_domener_h) { if ($key > $max_h) { $max_h = $key; } }
			$max_k=1; foreach my $key (values %_domener_k) { if ($key > $max_k) { $max_k = $key; } }
			my $count=0;
			&BuildKeyList($MaxNbOf{'Domain'},$MinHit{'Domain'},\%_domener_p,\%_domener_p);
			foreach my $key (@keylist) {
				my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
				if ($max_h > 0) { $bredde_p=int($BarWidth*$_domener_p{$key}/$max_h)+1; }	# use max_h to enable to compare pages with hits
				if ($_domener_p{$key} && $bredde_p==1) { $bredde_p=2; }
				if ($max_h > 0) { $bredde_h=int($BarWidth*$_domener_h{$key}/$max_h)+1; }
				if ($_domener_h{$key} && $bredde_h==1) { $bredde_h=2; }
				if ($max_k > 0) { $bredde_k=int($BarWidth*($_domener_k{$key}||0)/$max_k)+1; }
				if ($_domener_k{$key} && $bredde_k==1) { $bredde_k=2; }
				my $newkey=lc($key);
				if ($newkey eq 'ip' || ! $DomainsHashIDLib{$newkey}) {
					print "<TR><TD width=$WIDTHCOLICON><IMG SRC=\"$DirIcons\/flags\/ip.png\" height=14 alt=\"$Message[0]\"></TD><TD CLASS=AWL>$Message[0]</TD><TD>$newkey</TD>";
				}
				else {
					print "<TR><TD width=$WIDTHCOLICON><IMG SRC=\"$DirIcons\/flags\/$newkey.png\" height=14 alt=\"$newkey\"></TD><TD CLASS=AWL>$DomainsHashIDLib{$newkey}</TD><TD>$newkey</TD>";
				}
				if ($ShowDomainsStats =~ /P/i) { print "<TD>$_domener_p{$key}</TD>"; }
				if ($ShowDomainsStats =~ /H/i) { print "<TD>$_domener_h{$key}</TD>"; }
				if ($ShowDomainsStats =~ /B/i) { print "<TD>".Format_Bytes($_domener_k{$key})."</TD>"; }
				print "<TD CLASS=AWL>";
				if ($ShowDomainsStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 alt=\"\" title=\"\"><br>\n"; }
				if ($ShowDomainsStats =~ /H/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 alt=\"\" title=\"\"><br>\n"; }
				if ($ShowDomainsStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 alt=\"\" title=\"\">"; }
				print "</TD>";
				print "</TR>\n";
				$total_p += $_domener_p{$key};
				$total_h += $_domener_h{$key};
				$total_k += $_domener_k{$key}||0;
				$count++;
			}
			$rest_p=$TotalPages-$total_p;
			$rest_h=$TotalHits-$total_h;
			$rest_k=$TotalBytes-$total_k;
			if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) { 	# All other domains (known or not)
				print "<TR><TD width=$WIDTHCOLICON>&nbsp;</TD><TD colspan=2 CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
				if ($ShowDomainsStats =~ /P/i) { print "<TD>$rest_p</TD>"; }
				if ($ShowDomainsStats =~ /H/i) { print "<TD>$rest_h</TD>"; }
				if ($ShowDomainsStats =~ /B/i) { print "<TD>".Format_Bytes($rest_k)."</TD>"; }
				print "<TD CLASS=AWL>&nbsp;</TD>";
				print "</TR>\n";
			}
			&tab_end;
		}
	
		# BY HOST/VISITOR
		#--------------------------
		if ($ShowHostsStats) {
			if ($Debug) { debug("ShowHostsStats",2); }
			print "$Center<a name=\"VISITOR\">&nbsp;</a><BR>\n";
			my $title="$Message[81] ($Message[77] $MaxNbOf{'HostsShown'}) &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=allhosts":"$PROG$StaticLinks.allhosts.html")."\"$NewLinkTarget>$Message[80]</a> &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=lasthosts":"$PROG$StaticLinks.lasthosts.html")."\"$NewLinkTarget>$Message[9]</a> &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=unknownip":"$PROG$StaticLinks.unknownip.html")."\"$NewLinkTarget>$Message[45]</a>";
			&tab_head("$title",19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\">";
	#		print "<TH".($PluginsLoaded{'GetCountryCodeByAddr'}{'geoip'}?" colspan=2":"").">";
			print "<TH>";
			if ($MonthRequired ne 'all') { print "$Message[81] : $TotalHostsKnown $Message[82], $TotalHostsUnknown $Message[1] - $TotalUnique $Message[11]</TH>"; }
			else { print "$Message[81] : ".(scalar keys %_host_h)."</TH>"; }
			if ($ShowLinksToWhoIs && $LinksToWhoIs) { print "<TH width=80>$Message[114]</TH>"; }
			if ($ShowHostsStats =~ /P/i) { print "<TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH>"; }
			if ($ShowHostsStats =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
			if ($ShowHostsStats =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
			if ($ShowHostsStats =~ /L/i) { print "<TH width=120>$Message[9]</TH>"; }
			print "</TR>\n";
			$total_p=$total_h=$total_k=0;
			my $count=0;
			&BuildKeyList($MaxNbOf{'HostsShown'},$MinHit{'Host'},\%_host_h,\%_host_p);
			foreach my $key (@keylist) {
				print "<TR>";
				print "<TD CLASS=AWL>$key</TD>";
				if ($ShowLinksToWhoIs && $LinksToWhoIs) { ShowWhoIsCell($key); }
				if ($ShowHostsStats =~ /P/i) { print "<TD>".($_host_p{$key}||"&nbsp")."</TD>"; }
				if ($ShowHostsStats =~ /H/i) { print "<TD>$_host_h{$key}</TD>"; }
				if ($ShowHostsStats =~ /B/i) { print "<TD>".Format_Bytes($_host_k{$key})."</TD>"; }
				if ($ShowHostsStats =~ /L/i) { print "<TD>".($_host_l{$key}?Format_Date($_host_l{$key},1):'-')."</TD>"; }
				print "</TR>\n";
				$total_p += $_host_p{$key};
				$total_h += $_host_h{$key};
				$total_k += $_host_k{$key}||0;
				$count++;
			}
			$rest_p=$TotalPages-$total_p;
			$rest_h=$TotalHits-$total_h;
			$rest_k=$TotalBytes-$total_k;
			if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other visitors (known or not)
				print "<TR>";
				print "<TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
				if ($ShowLinksToWhoIs && $LinksToWhoIs) { print "<TD>&nbsp;</TD>"; }
				if ($ShowHostsStats =~ /P/i) { print "<TD>$rest_p</TD>"; }
				if ($ShowHostsStats =~ /H/i) { print "<TD>$rest_h</TD>"; }
				if ($ShowHostsStats =~ /B/i) { print "<TD>".Format_Bytes($rest_k)."</TD>"; }
				if ($ShowHostsStats =~ /L/i) { print "<TD>&nbsp;</TD>"; }
				print "</TR>\n";
			}
			&tab_end;
		}
	
		# BY SENDER EMAIL
		#----------------------------
		if ($ShowEMailSenders) {
			if ($Debug) { debug("ShowEMailSenders",2); }
			print "$Center<a name=\"EMAILSENDERS\">&nbsp;</a><BR>\n";
			my $title="$Message[131] ($Message[77] $MaxNbOf{'EMailsShown'}) &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=allemails":"$PROG$StaticLinks.allemails.html")."\"$NewLinkTarget>$Message[80]</a>";
			if ($ShowEMailSenders =~ /L/i) { $title.=" &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=lastemails":"$PROG$StaticLinks.lastemails.html")."\"$NewLinkTarget>$Message[9]</a>"; }
			&tab_head("$title",19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[131] : ".(scalar keys %_emails_h)."</TH>";
			if ($ShowEMailSenders =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
			if ($ShowEMailSenders =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
			if ($ShowEMailSenders =~ /M/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[106]</TH>"; }
			if ($ShowEMailSenders =~ /L/i) { print "<TH width=120>$Message[9]</TH>"; }
			print "</TR>\n";
			$total_p=$total_h=$total_k=0;
			$max_h=1; foreach my $key (values %_emails_h) { if ($key > $max_h) { $max_h = $key; } }
			$max_k=1; foreach my $key (values %_emails_k) { if ($key > $max_k) { $max_k = $key; } }
			my $count=0;
			&BuildKeyList($MaxNbOf{'EMailsShown'},$MinHit{'EMail'},\%_emails_h,\%_emails_h);
			foreach my $key (@keylist) {
				my $bredde_h=0;my $bredde_k=0;
				if ($max_h > 0) { $bredde_h=int($BarWidth*$_emails_h{$key}/$max_h)+1; }
				if ($max_k > 0) { $bredde_k=int($BarWidth*$_emails_k{$key}/$max_k)+1; }
				print "<TR><TD CLASS=AWL>$key</TD>";
				if ($ShowEMailSenders =~ /H/i) { print "<TD>$_emails_h{$key}</TD>"; }
				if ($ShowEMailSenders =~ /B/i) { print "<TD>".Format_Bytes($_emails_k{$key})."</TD>"; }
				if ($ShowEMailSenders =~ /M/i) { print "<TD>".Format_Bytes($_emails_k{$key}/($_emails_h{$key}||1))."</TD>"; }
				if ($ShowEMailSenders =~ /L/i) { print "<TD>".($_emails_l{$key}?Format_Date($_emails_l{$key},1):'-')."</TD>"; }
				print "</TR>\n";
				#$total_p += $_emails_p{$key};
				$total_h += $_emails_h{$key};
				$total_k += $_emails_k{$key};
				$count++;
			}
			$rest_p=0;	# $rest_p=$TotalPages-$total_p;
			$rest_h=$TotalHits-$total_h;
			$rest_k=$TotalBytes-$total_k;
			if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other sender emails
				print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
				if ($ShowEMailSenders =~ /H/i) { print "<TD>$rest_h</TD>"; }
				if ($ShowEMailSenders =~ /B/i) { print "<TD>".Format_Bytes($rest_k)."</TD>"; }
				if ($ShowEMailSenders =~ /M/i) { print "<TD>".Format_Bytes($rest_k/($rest_h||1))."</TD>"; }
				if ($ShowEMailSenders =~ /L/i) { print "<TD>&nbsp;</TD>"; }
				print "</TR>\n";
			}
			&tab_end;
		}
	
		# BY RECEIVER EMAIL
		#----------------------------
		if ($ShowEMailReceivers) {
			if ($Debug) { debug("ShowEMailReceivers",2); }
			print "$Center<a name=\"EMAILRECEIVERS\">&nbsp;</a><BR>\n";
			my $title="$Message[132] ($Message[77] $MaxNbOf{'EMailsShown'}) &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=allemailr":"$PROG$StaticLinks.allemailr.html")."\"$NewLinkTarget>$Message[80]</a>";
			if ($ShowEMailReceivers =~ /L/i) { $title.=" &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=lastemailr":"$PROG$StaticLinks.lastemailr.html")."\"$NewLinkTarget>$Message[9]</a>"; }
			&tab_head("$title",19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[132] : ".(scalar keys %_emailr_h)."</TH>";
			if ($ShowEMailReceivers =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
			if ($ShowEMailReceivers =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
			if ($ShowEMailReceivers =~ /M/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[106]</TH>"; }
			if ($ShowEMailReceivers =~ /L/i) { print "<TH width=120>$Message[9]</TH>"; }
			print "</TR>\n";
			$total_p=$total_h=$total_k=0;
			$max_h=1; foreach my $key (values %_emailr_h) { if ($key > $max_h) { $max_h = $key; } }
			$max_k=1; foreach my $key (values %_emailr_k) { if ($key > $max_k) { $max_k = $key; } }
			my $count=0;
			&BuildKeyList($MaxNbOf{'EMailsShown'},$MinHit{'EMail'},\%_emailr_h,\%_emailr_h);
			foreach my $key (@keylist) {
				my $bredde_h=0;my $bredde_k=0;
				if ($max_h > 0) { $bredde_h=int($BarWidth*$_emailr_h{$key}/$max_h)+1; }
				if ($max_k > 0) { $bredde_k=int($BarWidth*$_emailr_k{$key}/$max_k)+1; }
				print "<TR><TD CLASS=AWL>$key</TD>";
				if ($ShowEMailReceivers =~ /H/i) { print "<TD>$_emailr_h{$key}</TD>"; }
				if ($ShowEMailReceivers =~ /B/i) { print "<TD>".Format_Bytes($_emailr_k{$key})."</TD>"; }
				if ($ShowEMailReceivers =~ /M/i) { print "<TD>".Format_Bytes($_emailr_k{$key}/($_emailr_h{$key}||1))."</TD>"; }
				if ($ShowEMailReceivers =~ /L/i) { print "<TD>".($_emailr_l{$key}?Format_Date($_emailr_l{$key},1):'-')."</TD>"; }
				print "</TR>\n";
				#$total_p += $_emailr_p{$key};
				$total_h += $_emailr_h{$key};
				$total_k += $_emailr_k{$key};
				$count++;
			}
			$rest_p=0;	# $rest_p=$TotalPages-$total_p;
			$rest_h=$TotalHits-$total_h;
			$rest_k=$TotalBytes-$total_k;
			if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other receiver emails
				print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
				if ($ShowEMailReceivers =~ /H/i) { print "<TD>$rest_h</TD>"; }
				if ($ShowEMailReceivers =~ /B/i) { print "<TD>".Format_Bytes($rest_k)."</TD>"; }
				if ($ShowEMailReceivers =~ /M/i) { print "<TD>".Format_Bytes($rest_k/($rest_h||1))."</TD>"; }
				if ($ShowEMailReceivers =~ /L/i) { print "<TD>&nbsp;</TD>"; }
				print "</TR>\n";
			}
			&tab_end;
		}
	
		# BY LOGIN
		#----------------------------
		if ($ShowAuthenticatedUsers) {
			if ($Debug) { debug("ShowAuthenticatedUsers",2); }
			print "$Center<a name=\"LOGIN\">&nbsp;</a><BR>\n";
			my $title="$Message[94] ($Message[77] $MaxNbOf{'LoginShown'}) &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=alllogins":"$PROG$StaticLinks.alllogins.html")."\"$NewLinkTarget>$Message[80]</a>";
			if ($ShowAuthenticatedUsers =~ /L/i) { $title.=" &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=lastlogins":"$PROG$StaticLinks.lastlogins.html")."\"$NewLinkTarget>$Message[9]</a>"; }
			&tab_head("$title",19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[94] : ".(scalar keys %_login_h)."</TH>";
			if ($ShowAuthenticatedUsers =~ /P/i) { print "<TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH>"; }
			if ($ShowAuthenticatedUsers =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
			if ($ShowAuthenticatedUsers =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
			if ($ShowAuthenticatedUsers =~ /L/i) { print "<TH width=120>$Message[9]</TH>"; }
			print "</TR>\n";
			$total_p=$total_h=$total_k=0;
			$max_h=1; foreach my $key (values %_login_h) { if ($key > $max_h) { $max_h = $key; } }
			$max_k=1; foreach my $key (values %_login_k) { if ($key > $max_k) { $max_k = $key; } }
			my $count=0;
			&BuildKeyList($MaxNbOf{'LoginShown'},$MinHit{'Login'},\%_login_h,\%_login_p);
			foreach my $key (@keylist) {
				my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
				if ($max_h > 0) { $bredde_p=int($BarWidth*$_login_p{$key}/$max_h)+1; }	# use max_h to enable to compare pages with hits
				if ($max_h > 0) { $bredde_h=int($BarWidth*$_login_h{$key}/$max_h)+1; }
				if ($max_k > 0) { $bredde_k=int($BarWidth*$_login_k{$key}/$max_k)+1; }
				print "<TR><TD CLASS=AWL>$key</TD>";
				if ($ShowAuthenticatedUsers =~ /P/i) { print "<TD>".($_login_p{$key}?$_login_p{$key}:"&nbsp;")."</TD>"; }
				if ($ShowAuthenticatedUsers =~ /H/i) { print "<TD>$_login_h{$key}</TD>"; }
				if ($ShowAuthenticatedUsers =~ /B/i) { print "<TD>".Format_Bytes($_login_k{$key})."</TD>"; }
				if ($ShowAuthenticatedUsers =~ /L/i) { print "<TD>".($_login_l{$key}?Format_Date($_login_l{$key},1):'-')."</TD>"; }
				#print "<TD CLASS=AWL>";
				#print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$Message[56]: $_login_p{$key}\" title=\"$Message[56]: $_login_p{$key}\"><br>\n";
				#print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 ALT=\"$Message[57]: $_login_h{$key}\" title=\"$Message[57]: $_login_h{$key}\"><br>\n";
				#print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$Message[75]: ".Format_Bytes($_login_k{$key})."\" title=\"$Message[75]: ".Format_Bytes($_login_k{$key})."\">";
				#print "</TD>";
				print "</TR>\n";
				$total_p += $_login_p{$key};
				$total_h += $_login_h{$key};
				$total_k += $_login_k{$key};
				$count++;
			}
			$rest_p=$TotalPages-$total_p;
			$rest_h=$TotalHits-$total_h;
			$rest_k=$TotalBytes-$total_k;
			if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other logins
				print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[125]</font></TD>";
				if ($ShowAuthenticatedUsers =~ /P/i) { print "<TD>".($rest_p?$rest_p:"&nbsp;")."</TD>"; }
				if ($ShowAuthenticatedUsers =~ /H/i) { print "<TD>$rest_h</TD>"; }
				if ($ShowAuthenticatedUsers =~ /B/i) { print "<TD>".Format_Bytes($rest_k)."</TD>"; }
				if ($ShowAuthenticatedUsers =~ /L/i) { print "<TD>&nbsp;</TD>"; }
				print "</TR>\n";
			}
			&tab_end;
		}
	
		# BY ROBOTS
		#----------------------------
		if ($ShowRobotsStats) {
			if ($Debug) { debug("ShowRobotStats",2); }
			print "$Center<a name=\"ROBOTS\">&nbsp;</a><BR>\n";
			&tab_head("$Message[53] ($Message[77] $MaxNbOf{'RobotShown'}) &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=allrobots":"$PROG$StaticLinks.allrobots.html")."\"$NewLinkTarget>$Message[80]</a> &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=lastrobots":"$PROG$StaticLinks.lastrobots.html")."\"$NewLinkTarget>$Message[9]</a>",19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"".($TOOLTIPON?" onmouseover=\"ShowTip(16);\" onmouseout=\"HideTip(16);\"":"")."><TH>".(scalar keys %_robot_h)." $Message[51]</TH>";
			if ($ShowRobotsStats =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
			if ($ShowRobotsStats =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
			if ($ShowRobotsStats =~ /L/i) { print "<TH width=120>$Message[9]</TH>"; }
			print "</TR>\n";
			$total_p=$total_h=$total_k=0;
			my $count=0;
			&BuildKeyList($MaxNbOf{'RobotShown'},$MinHit{'Robot'},\%_robot_h,\%_robot_h);
			foreach my $key (@keylist) {
				print "<TR><TD CLASS=AWL>".($RobotsHashIDLib{$key}?$RobotsHashIDLib{$key}:$key)."</TD>";
				if ($ShowRobotsStats =~ /H/i) { print "<TD>$_robot_h{$key}</TD>"; }
				if ($ShowRobotsStats =~ /B/i) { print "<TD>".Format_Bytes($_robot_k{$key})."</TD>"; }
				if ($ShowRobotsStats =~ /L/i) { print "<td>".($_robot_l{$key}?Format_Date($_robot_l{$key},1):'-')."</td>"; }
				print "</TR>\n";
				#$total_p += $_robot_p{$key};
				$total_h += $_robot_h{$key};
				$total_k += $_robot_k{$key};
				$count++;
				}
			# For bots we need to count Totals
			my $TotalPagesRobots = 0; #foreach my $val (values %_robot_p) { $TotalPagesRobots+=$val; }
			my $TotalHitsRobots = 0; foreach my $val (values %_robot_h) { $TotalHitsRobots+=$val; }
			my $TotalBytesRobots = 0; foreach my $val (values %_robot_k) { $TotalBytesRobots+=$val; }
			$rest_p=0;	#$rest_p=$TotalPagesRobots-$total_p;
			$rest_h=$TotalHitsRobots-$total_h;
			$rest_k=$TotalBytesRobots-$total_k;
			if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other robots
				print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
				if ($ShowRobotsStats =~ /H/i) { print "<TD>$rest_h</TD>"; }
				if ($ShowRobotsStats =~ /B/i) { print "<TD>".(Format_Bytes($rest_k))."</TD>"; }
				if ($ShowRobotsStats =~ /L/i) { print "<TD>&nbsp;</TD>"; }
				print "</TR>\n";
			}
			&tab_end;
		}
	
		print "\n<a name=\"HOW\">&nbsp;</a>\n\n";
	
		# BY SESSION
		#----------------------------
		if ($ShowSessionsStats) {
			if ($Debug) { debug("ShowSessionsStats",2); }
			print "$Center<a name=\"SESSIONS\">&nbsp;</a><BR>\n";
			my $title="$Message[117]";
			&tab_head($title,19);
			my $Totals=0; foreach my $key (@SessionsRange) { $average_s+=$_session{$key}*$SessionsAverage{$key}; $Totals+=$_session{$key}; }
			if ($Totals) { $average_s=int($average_s/$Totals); }
			else { $average_s='?'; }
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"".($TOOLTIPON?" onmouseover=\"ShowTip(1);\" onmouseout=\"HideTip(1);\"":"")."><TH>$Message[10]: $TotalVisits - $Message[96]: $average_s s</TH><TH bgcolor=\"#$color_s\" width=80>$Message[10]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[15]</TH></TR>\n";
			$average_s=0;
			$total_s=0;
			my $count=0;
			foreach my $key (@SessionsRange) {
				my $p=0;
				if ($TotalVisits) { $p=int($_session{$key}/$TotalVisits*1000)/10; }
				$total_s+=$_session{$key}||0;
				print "<tr><td CLASS=AWL>$key</td>";
				print "<td>".($_session{$key}?$_session{$key}:"&nbsp;")."</td>";
				print "<td>".($_session{$key}?"$p %":"&nbsp;")."</td>";
				print "</tr>\n";
				$count++;
			}
			$rest_s=$TotalVisits-$total_s;
			if ($rest_s > 0) {	# All others sessions
				my $p=0;
				if ($TotalVisits) { $p=int($rest_s/$TotalVisits*1000)/10; }
				print "<tr".($TOOLTIPON?" onmouseover=\"ShowTip(20);\" onmouseout=\"HideTip(20);\"":"")."><td CLASS=AWL><font color=\"#$color_other\">$Message[0]</font></td>";
				print "<td>$rest_s</td>";
				print "<td>".($rest_s?"$p %":"&nbsp;")."</td>";
				print "</tr>\n";
			}
			&tab_end;
		}
	
		# BY FILE TYPE
		#-------------------------
		if ($ShowFileTypesStats) {
			if ($Debug) { debug("ShowFileTypesStatsCompressionStats",2); }
			print "$Center<a name=\"FILETYPES\">&nbsp;</a><BR>\n";
			my $Totalh=0; foreach my $key (keys %_filetypes_h) { $Totalh+=$_filetypes_h{$key}; }
			my $Totalk=0; foreach my $key (keys %_filetypes_k) { $Totalk+=$_filetypes_k{$key}; }
			my $title="$Message[73]";
			if ($ShowFileTypesStats =~ /C/i) { $title.=" - $Message[98]"; }
			&tab_head("$title",19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH colspan=3>$Message[73]</TH>";
			if ($ShowFileTypesStats =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>&nbsp;$Message[57]&nbsp;</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH>"; }
			if ($ShowFileTypesStats =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
			if ($ShowFileTypesStats =~ /C/i) { print "<TH bgcolor=\"#$color_k\" width=120>$Message[100]</TH><TH bgcolor=\"#$color_k\" width=120>$Message[101]</TH><TH bgcolor=\"#$color_k\" width=120>$Message[99]</TH>"; }
			print "</TR>\n";
			my $count=0;
			&BuildKeyList($MaxRowsInHTMLOutput,1,\%_filetypes_h,\%_filetypes_h);
			foreach my $key (@keylist) {
				my $p=int($_filetypes_h{$key}/$Totalh*1000)/10;
				if ($key eq 'Unknown') {
					print "<TR><TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/mime\/unknown.png\" alt=\"\"></TD><TD CLASS=AWL><font color=\"#$color_other\">$Message[0]</font></TD>";
					print "<TD>&nbsp;</TD>";
				}
				else {
					my $nameicon=$MimeHashIcon{$key}||"notavailable";
					my $nametype=$MimeHashLib{$MimeHashFamily{$key}||""}||"&nbsp;";
					print "<TR><TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/mime\/$nameicon.png\" alt=\"\"></TD><TD CLASS=AWL>$key</TD>";
					print "<TD class=AWL>$nametype</TD>";
				}
				if ($ShowFileTypesStats =~ /H/i) { print "<TD>$_filetypes_h{$key}</TD><TD>$p %</TD>"; }
				if ($ShowFileTypesStats =~ /B/i) { print "<TD>".Format_Bytes($_filetypes_k{$key})."</TD>"; }
				if ($ShowFileTypesStats =~ /C/i) {
					if ($_filetypes_gz_in{$key}) {
						my $percent=int(100*(1-$_filetypes_gz_out{$key}/$_filetypes_gz_in{$key}));
						printf("<TD>%s</TD><TD>%s</TD><TD>%s (%s%)</TD>",Format_Bytes($_filetypes_gz_in{$key}),Format_Bytes($_filetypes_gz_out{$key}),Format_Bytes($_filetypes_gz_in{$key}-$_filetypes_gz_out{$key}),$percent);
					}
					else {
						print "<TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD>";
					}
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
	
		# BY FILE/URL
		#-------------------------
		if ($ShowPagesStats) {
			if ($Debug) { debug("ShowPagesStats (MaxNbOf{'PageShown'}=$MaxNbOf{'PageShown'} TotalDifferentPages=$TotalDifferentPages)",2); }
			print "$Center<a name=\"PAGE\">&nbsp;</a><a name=\"ENTRY\">&nbsp;</a><a name=\"EXIT\">&nbsp;</a><BR>\n";
			my $title="$Message[19] ($Message[77] $MaxNbOf{'PageShown'}) &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=urldetail":"$PROG$StaticLinks.urldetail.html")."\"$NewLinkTarget>$Message[80]</a>";
			if ($ShowPagesStats =~ /E/i) { $title.=" &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=urlentry":"$PROG$StaticLinks.urlentry.html")."\"$NewLinkTarget>$Message[104]</a>"; }
			if ($ShowPagesStats =~ /X/i) { $title.=" &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=urlexit":"$PROG$StaticLinks.urlexit.html")."\"$NewLinkTarget>$Message[116]</a>"; }
			&tab_head("$title",19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$TotalDifferentPages $Message[28]</TH>";
			if ($ShowPagesStats =~ /P/i) { print "<TH bgcolor=\"#$color_p\" width=80>$Message[29]</TH>"; }
			if ($ShowPagesStats =~ /B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[106]</TH>"; }
			if ($ShowPagesStats =~ /E/i) { print "<TH bgcolor=\"#$color_e\" width=80>$Message[104]</TH>"; }
			if ($ShowPagesStats =~ /X/i) { print "<TH bgcolor=\"#$color_x\" width=80>$Message[116]</TH>"; }
			# Call to plugins' function ShowPagesAddField
			foreach my $pluginname (keys %{$PluginsLoaded{'ShowPagesAddField'}})  {
				my $function="ShowPagesAddField_$pluginname('title')";
				eval("$function");
			}
			print "<TH>&nbsp;</TH></TR>\n";
			$total_p=$total_e=$total_x=$total_k=0;
			$max_p=1; $max_k=1;
			my $count=0;
			&BuildKeyList($MaxNbOf{'PageShown'},$MinHit{'File'},\%_url_p,\%_url_p);
			foreach my $key (@keylist) {
				if ($_url_p{$key} > $max_p) { $max_p = $_url_p{$key}; }
				if ($_url_k{$key}/($_url_p{$key}||1) > $max_k) { $max_k = $_url_k{$key}/($_url_p{$key}||1); }
			}
			foreach my $key (@keylist) {
				print "<TR><TD CLASS=AWL>";
				&ShowURL($key);
				print "</TD>";
				my $bredde_p=0; my $bredde_e=0; my $bredde_x=0; my $bredde_k=0;
				if ($max_p > 0) { $bredde_p=int($BarWidth*($_url_p{$key}||0)/$max_p)+1; }
				if (($bredde_p==1) && $_url_p{$key}) { $bredde_p=2; }
				if ($max_p > 0) { $bredde_e=int($BarWidth*($_url_e{$key}||0)/$max_p)+1; }
				if (($bredde_e==1) && $_url_e{$key}) { $bredde_e=2; }
				if ($max_p > 0) { $bredde_x=int($BarWidth*($_url_x{$key}||0)/$max_p)+1; }
				if (($bredde_x==1) && $_url_x{$key}) { $bredde_x=2; }
				if ($max_k > 0) { $bredde_k=int($BarWidth*(($_url_k{$key}||0)/($_url_p{$key}||1))/$max_k)+1; }
				if (($bredde_k==1) && $_url_k{$key}) { $bredde_k=2; }
				if ($ShowPagesStats =~ /P/i) { print "<TD>$_url_p{$key}</TD>"; }
				if ($ShowPagesStats =~ /B/i) { print "<TD>".($_url_k{$key}?Format_Bytes($_url_k{$key}/($_url_p{$key}||1)):"&nbsp;")."</TD>"; }
				if ($ShowPagesStats =~ /E/i) { print "<TD>".($_url_e{$key}?$_url_e{$key}:"&nbsp;")."</TD>"; }
				if ($ShowPagesStats =~ /X/i) { print "<TD>".($_url_x{$key}?$_url_x{$key}:"&nbsp;")."</TD>"; }
				# Call to plugins' function ShowPagesAddField
				foreach my $pluginname (keys %{$PluginsLoaded{'ShowPagesAddField'}})  {
					my $function="ShowPagesAddField_$pluginname('$key')";
					eval("$function");
				}
				print "<TD CLASS=AWL>";
				if ($ShowPagesStats =~ /P/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 alt=\"\" title=\"\"><br>"; }
				if ($ShowPagesStats =~ /B/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 alt=\"\" title=\"\"><br>"; }
				if ($ShowPagesStats =~ /E/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_e\" WIDTH=$bredde_e HEIGHT=6 alt=\"\" title=\"\"><br>"; }
				if ($ShowPagesStats =~ /X/i) { print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_x\" WIDTH=$bredde_x HEIGHT=6 alt=\"\" title=\"\">"; }
				print "</TD></TR>\n";
				$total_p += $_url_p{$key};
				$total_e += $_url_e{$key};
				$total_x += $_url_x{$key};
				$total_k += $_url_k{$key};
				$count++;
			}
			$rest_p=$TotalPages-$total_p;
			$rest_e=$TotalEntries-$total_e;
			$rest_x=$TotalExits-$total_x;
			$rest_k=$TotalBytesPages-$total_k;
			if ($rest_p > 0 || $rest_k > 0 || $rest_e > 0 || $rest_x > 0) {	# All other urls
				print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></TD>";
				if ($ShowPagesStats =~ /P/i) { print "<TD>$rest_p</TD>"; }
				if ($ShowPagesStats =~ /B/i) { print "<TD>".($rest_k?Format_Bytes($rest_k/($rest_p||1)):"&nbsp;")."</TD>"; }
				if ($ShowPagesStats =~ /E/i) { print "<TD>".($rest_e?$rest_e:"&nbsp;")."</TD>"; }
				if ($ShowPagesStats =~ /X/i) { print "<TD>".($rest_x?$rest_x:"&nbsp;")."</TD>"; }
				# Call to plugins' function ShowPagesAddField
				foreach my $pluginname (keys %{$PluginsLoaded{'ShowPagesAddField'}})  {
					my $function="ShowPagesAddField_$pluginname('')";
					eval("$function");
				}
				print "<TD>&nbsp;</TD></TR>\n";
			}
			&tab_end;
		}
	
		# BY OS
		#----------------------------
		if ($ShowOSStats) {
			if ($Debug) { debug("ShowOSStats",2); }
			print "$Center<a name=\"OS\">&nbsp;</a><BR>\n";
			my $Totalh=0; my %new_os_h=();
			OSLOOP: foreach my $key (keys %_os_h) {
				$Totalh+=$_os_h{$key};
				foreach my $family (@OSFamily) { if ($key =~ /^$family/i) { $new_os_h{"${family}cumul"}+=$_os_h{$key}; next OSLOOP; } }
				$new_os_h{$key}+=$_os_h{$key};
			}
			my $title="$Message[59] &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=osdetail":"$PROG$StaticLinks.osdetail.html")."\"$NewLinkTarget>$Message[58]</a> &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=unknownos":"$PROG$StaticLinks.unknownos.html")."\"$NewLinkTarget>$Message[0]</a>";
			&tab_head("$title",19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH width=$WIDTHCOLICON>&nbsp;</TH><TH>$Message[59]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH></TR>\n";
			my $count=0;
			&BuildKeyList($MaxRowsInHTMLOutput,1,\%new_os_h,\%new_os_h);
			foreach my $key (@keylist) {
				my $p='&nbsp;';
				if ($Totalh) { $p=int($new_os_h{$key}/$Totalh*1000)/10; $p="$p %"; }
				if ($key eq 'Unknown') {
					print "<TR><TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/os\/unknown.png\" alt=\"\"></TD><TD CLASS=AWL><font color=\"#$color_other\">$Message[0]</font></TD><TD>$_os_h{$key}</TD><TD>$p</TD></TR>\n";
				}
				else {
					my $keywithoutcumul=$key; $keywithoutcumul =~ s/cumul$//i;
					my $libos=$OSHashLib{$keywithoutcumul}||$keywithoutcumul;
					my $nameicon=$keywithoutcumul; $nameicon =~ s/[^\w]//g;
					# TODO Use OSFamilyLib
					if ($libos eq 'win') { $libos="<b>Windows</b>"; }
					if ($libos eq 'mac') { $libos="<b>Macintosh</b>"; }
					print "<TR><TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/os\/$nameicon.png\" alt=\"\"></TD><TD CLASS=AWL>$libos</TD><TD>$new_os_h{$key}</TD><TD>$p</TD></TR>\n";
				}
				$count++;
			}
			&tab_end;
		}
		
		# BY BROWSER
		#----------------------------
		if ($ShowBrowsersStats) {
			if ($Debug) { debug("ShowBrowsersStats",2); }
			print "$Center<a name=\"BROWSER\">&nbsp;</a><BR>\n";
			my $Totalh=0; my %new_browser_h=();
			BROWSERLOOP: foreach my $key (keys %_browser_h) {
				$Totalh+=$_browser_h{$key};
				foreach my $family (@BrowsersFamily) { if ($key =~ /^$family/i) { $new_browser_h{"${family}cumul"}+=$_browser_h{$key}; next BROWSERLOOP; } }
				$new_browser_h{$key}+=$_browser_h{$key};
			}
			my $title="$Message[21] &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=browserdetail":"$PROG$StaticLinks.browserdetail.html")."\"$NewLinkTarget>$Message[58]</a> &nbsp; - &nbsp; <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=unknownbrowser":"$PROG$StaticLinks.unknownbrowser.html")."\"$NewLinkTarget>$Message[0]</a>";
			&tab_head("$title",19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH width=$WIDTHCOLICON>&nbsp;</TH><TH>$Message[21]</TH><TH width=80>$Message[111]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH></TR>\n";
			my $count=0;
			&BuildKeyList($MaxRowsInHTMLOutput,1,\%new_browser_h,\%new_browser_h);
			foreach my $key (@keylist) {
				my $p='&nbsp;';
				if ($Totalh) { $p=int($new_browser_h{$key}/$Totalh*1000)/10; $p="$p %"; }
				if ($key eq 'Unknown') {
					print "<TR><TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/browser\/unknown.png\" alt=\"\"></TD><TD CLASS=AWL><font color=\"#$color_other\">$Message[0]</font></TD><TD width=80>?</TD><TD>$_browser_h{$key}</TD><TD>$p</TD></TR>\n";
				}
				else {
					my $keywithoutcumul=$key; $keywithoutcumul =~ s/cumul$//i;
					my $libbrowser=$BrowsersHashIDLib{$keywithoutcumul}||$keywithoutcumul;
					my $nameicon=$BrowsersHashIcon{$keywithoutcumul}||"notavailable";
					# TODO Use BrowsersFamilyLib
					if ($libbrowser eq 'netscape') { $libbrowser="<b>Netscape</b>"; }
					if ($libbrowser eq 'msie')     { $libbrowser="<b>MS Internet Explorer</b>"; }
					print "<TR><TD".($count?"":" width=$WIDTHCOLICON")."><IMG SRC=\"$DirIcons\/browser\/$nameicon.png\" alt=\"\"></TD><TD CLASS=AWL>$libbrowser</TD><TD>".($BrowsersHereAreGrabbers{$key}?"<b>$Message[112]</b>":"$Message[113]")."</TD><TD>$new_browser_h{$key}</TD><TD>$p</TD></TR>\n";
				}
				$count++;
			}
			&tab_end;
		}
	
		# BY SCREEN SIZE
		#----------------------------
		if ($ShowScreenSizeStats) {
			if ($Debug) { debug("ShowScreenSizeStats",2); }
			print "$Center<a name=\"SCREENSIZE\">&nbsp;</a><BR>\n";
			my $Totalh=0; foreach my $key (keys %_screensize_h) { $Totalh+=$_screensize_h{$key}; }
			my $title="$Message[135] ($Message[77] $MaxNbOf{'ScreenSizesShown'})";
			&tab_head("$title",0);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[135]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH></TR>\n";
			my $total_h=0;
			my $count=0;
			&BuildKeyList($MaxNbOf{'ScreenSizesShown'},$MinHit{'ScreenSize'},\%_screensize_h,\%_screensize_h);
			foreach my $key (@keylist) {
				my $p='&nbsp;';
				if ($Totalh) { $p=int($_screensize_h{$key}/$Totalh*1000)/10; $p="$p %"; }
				$total_h+=$_screensize_h{$key}||0;
				print "<TR>";
				if ($key eq 'Unknown') {
					print "<TD CLASS=AWL><font color=\"#$color_other\">$Message[0]</font></TD>";
					print "<TD>$p</TD>";
					}
				else {
					my $screensize=$key;
					print "<TD CLASS=AWL>$screensize</TD>";
					print "<TD>$p</TD>";
				}
				print "</TR>\n";
				$count++;
			}
			$rest_h=$Totalh-$total_h;
			if ($rest_h > 0) {	# All others sessions
				my $p=0;
				if ($Totalh) { $p=int($rest_h/$Totalh*1000)/10; }
				print "<tr><td CLASS=AWL><font color=\"#$color_other\">$Message[2]</font></td>";
				print "<td>".($rest_h?"$p %":"&nbsp;")."</td>";
				print "</tr>\n";
			}
			&tab_end;
		}

		print "\n<a name=\"REFERING\">&nbsp;</a>\n\n";
	
		# BY REFERENCE
		#---------------------------
		if ($ShowOriginStats) {
			if ($Debug) { debug("ShowOriginStats",2); }
			print "$Center<a name=\"REFERER\">&nbsp;</a><BR>\n";
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
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>$Message[37]</TH>";
			if ($ShowOriginStats =~ /P/i) { print "<TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH><TH bgcolor=\"#$color_p\" width=80>$Message[15]</TH>"; }
			if ($ShowOriginStats =~ /H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH>"; }
			print "</TR>\n";
			#------- Referrals by direct address/bookmarks
			print "<TR><TD CLASS=AWL><b>$Message[38]</b></TD>";
			if ($ShowOriginStats =~ /P/i) { print "<TD>".($_from_p[0]?$_from_p[0]:"&nbsp;")."</TD><TD>".($_from_p[0]?"$p_p[0] %":"&nbsp;")."</TD>"; }
			if ($ShowOriginStats =~ /H/i) { print "<TD>".($_from_h[0]?$_from_h[0]:"&nbsp;")."</TD><TD>".($_from_h[0]?"$p_h[0] %":"&nbsp;")."</TD>"; }
			print "</TR>\n";
			#------- Referrals by news group
			print "<TR><TD CLASS=AWL><b>$Message[107]</b></TD>";
			if ($ShowOriginStats =~ /P/i) { print "<TD>".($_from_p[5]?$_from_p[5]:"&nbsp;")."</TD><TD>".($_from_p[5]?"$p_p[5] %":"&nbsp;")."</TD>"; }
			if ($ShowOriginStats =~ /H/i) { print "<TD>".($_from_h[5]?$_from_h[5]:"&nbsp;")."</TD><TD>".($_from_h[5]?"$p_h[5] %":"&nbsp;")."</TD>"; }
			print "</TR>\n";
			#------- Referrals by search engine
			print "<TR".($TOOLTIPON?" onmouseover=\"ShowTip(13);\" onmouseout=\"HideTip(13);\"":"")."><TD CLASS=AWL><b>$Message[40]</b> - <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=refererse":"$PROG$StaticLinks.refererse.html")."\"$NewLinkTarget>$Message[80]</a><br>\n";
			if (scalar keys %_se_referrals_h) {
				print "<TABLE>\n";
				$total_p=0; $total_h=0;
				my $count=0;
				&BuildKeyList($MaxNbOf{'RefererShown'},$MinHit{'Refer'},\%_se_referrals_h,\%_se_referrals_p);
				foreach my $key (@keylist) {
					my $newreferer=CleanFromCSSA($SearchEnginesHashIDLib{$key}||$key);
					print "<TR><TD CLASS=AWL>- $newreferer</TD>";
					print "<TD>".($_se_referrals_p{$key}?$_se_referrals_p{$key}:'0')."</TD>";
					print "<TD>$_se_referrals_h{$key}</TD>";
					print "</TR>\n";
					$total_p += $_se_referrals_p{$key};
					$total_h += $_se_referrals_h{$key};
					$count++;
				}
				if ($Debug) { debug("Total real / shown : $TotalSearchEnginesPages / $total_p -  $TotalSearchEnginesHits / $total_h",2); }
				$rest_p=$TotalSearchEnginesPages-$total_p;
				$rest_h=$TotalSearchEnginesHits-$total_h;
				if ($rest_p > 0 || $rest_h > 0) {
					print "<TR><TD CLASS=AWL><font color=\"#$color_other\">- $Message[2]</font></TD>";
					print "<TD>$rest_p</TD>";
					print "<TD>$rest_h</TD>";
					print "</TR>\n";
				}
				print "</TABLE>";
			}
			print "</TD>\n";
			if ($ShowOriginStats =~ /P/i) { print "<TD valign=top>".($_from_p[2]?$_from_p[2]:"&nbsp;")."</TD><TD valign=top>".($_from_p[2]?"$p_p[2] %":"&nbsp;")."</TD>"; }
			if ($ShowOriginStats =~ /H/i) { print "<TD valign=top>".($_from_h[2]?$_from_h[2]:"&nbsp;")."</TD><TD valign=top>".($_from_h[2]?"$p_h[2] %":"&nbsp;")."</TD>"; }
			print "</TR>\n";
			#------- Referrals by external HTML link
			print "<TR".($TOOLTIPON?" onmouseover=\"ShowTip(14);\" onmouseout=\"HideTip(14);\"":"")."><TD CLASS=AWL><b>$Message[41]</b> - <a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=refererpages":"$PROG$StaticLinks.refererpages.html")."\"$NewLinkTarget>$Message[80]</a><br>\n";
			if (scalar keys %_pagesrefs_h) {
				print "<TABLE>\n";
				$total_p=0; $total_h=0;
				my $count=0;
				&BuildKeyList($MaxNbOf{'RefererShown'},$MinHit{'Refer'},\%_pagesrefs_h,\%_pagesrefs_p);
				foreach my $key (@keylist) {
					print "<TR><TD CLASS=AWL>- ";
					&ShowURL($key);
					print "</TD>";
					print "<TD>".($_pagesrefs_p{$key}?$_pagesrefs_p{$key}:'0')."</TD>";
					print "<TD>$_pagesrefs_h{$key}</TD>";
					print "</TR>\n";
					$total_p += $_pagesrefs_p{$key};
					$total_h += $_pagesrefs_h{$key};
					$count++;
				}
				if ($Debug) { debug("Total real / shown : $TotalRefererPages / $total_p - $TotalRefererHits / $total_h",2); }
				$rest_p=$TotalRefererPages-$total_p;
				$rest_h=$TotalRefererHits-$total_h;
				if ($rest_p > 0 || $rest_h > 0) {
					print "<TR><TD CLASS=AWL><font color=\"#$color_other\">- $Message[2]</font></TD>";
					print "<TD>$rest_p</TD>";
					print "<TD>$rest_h</TD>";
					print "</TR>\n";
				}
				print "</TABLE>";
			}
			print "</TD>\n";
			if ($ShowOriginStats =~ /P/i) { print "<TD valign=top>".($_from_p[3]?$_from_p[3]:"&nbsp;")."</TD><TD valign=top>".($_from_p[3]?"$p_p[3] %":"&nbsp;")."</TD>"; }
			if ($ShowOriginStats =~ /H/i) { print "<TD valign=top>".($_from_h[3]?$_from_h[3]:"&nbsp;")."</TD><TD valign=top>".($_from_h[3]?"$p_h[3] %":"&nbsp;")."</TD>"; }
			print "</TR>\n";
			#------- Referrals by internal HTML link
			print "<TR><TD CLASS=AWL><b>$Message[42]</b></TD>";
			if ($ShowOriginStats =~ /P/i) { print "<TD>".($_from_p[4]?$_from_p[4]:"&nbsp;")."</TD><TD>".($_from_p[4]?"$p_p[4] %":"&nbsp;")."</TD>"; }
			if ($ShowOriginStats =~ /H/i) { print "<TD>".($_from_h[4]?$_from_h[4]:"&nbsp;")."</TD><TD>".($_from_h[4]?"$p_h[4] %":"&nbsp;")."</TD>"; }
			print "</TR>\n";
			#------- Unkown origin
			print "<TR><TD CLASS=AWL><b>$Message[39]</b></TD>";
			if ($ShowOriginStats =~ /P/i) { print "<TD>".($_from_p[1]?$_from_p[1]:"&nbsp;")."</TD><TD>".($_from_p[1]?"$p_p[1] %":"&nbsp;")."</TD>"; }
			if ($ShowOriginStats =~ /H/i) { print "<TD>".($_from_h[1]?$_from_h[1]:"&nbsp;")."</TD><TD>".($_from_h[1]?"$p_h[1] %":"&nbsp;")."</TD>"; }
			print "</TR>\n";
			&tab_end;
		}
	
		print "\n<a name=\"KEYS\">&nbsp;</a>\n\n";
	
		# BY SEARCH KEYWORDS AND/OR KEYPHRASES
		#-------------------------------------
		if ($ShowKeyphrasesStats) { print "$Center<a name=\"KEYPHRASES\">&nbsp;</a>"; }
		if ($ShowKeywordsStats)   {	print "$Center<a name=\"KEYWORDS\">&nbsp;</a>"; }
		if ($ShowKeyphrasesStats || $ShowKeywordsStats) { print "<BR>\n"; }
		if ($ShowKeyphrasesStats && $ShowKeywordsStats) { print "<table width=\"100%\"><tr>"; }
		if ($ShowKeyphrasesStats) {
			# By Keyphrases
			if ($ShowKeyphrasesStats && $ShowKeywordsStats) { print "<td width=\"50%\" valign=top>\n";	}
			if ($Debug) { debug("ShowKeyphrasesStats",2); }
			&tab_head("$Message[120] ($Message[77] $MaxNbOf{'KeyphrasesShown'})<br><a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=keyphrases":"$PROG$StaticLinks.keyphrases.html")."\"$NewLinkTarget>$Message[80]</a>",19,($ShowKeyphrasesStats && $ShowKeywordsStats)?95:70);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"".($TOOLTIPON?" onmouseover=\"ShowTip(15);\" onmouseout=\"HideTip(15);\"":"")."><TH>$TotalDifferentKeyphrases $Message[103]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[14]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[15]</TH></TR>\n";
			$total_s=0;
			my $count=0;
			&BuildKeyList($MaxNbOf{'KeyphrasesShown'},$MinHit{'Keyphrase'},\%_keyphrases,\%_keyphrases);
			foreach my $key (@keylist) {
				my $mot = DecodeEncodedString(CleanFromCSSA($key));
				my $p;
				if ($TotalKeyphrases) { $p=int($_keyphrases{$key}/$TotalKeyphrases*1000)/10; }
				print "<TR><TD CLASS=AWL>$mot</TD><TD>$_keyphrases{$key}</TD><TD>$p %</TD></TR>\n";
				$total_s += $_keyphrases{$key};
				$count++;
			}
			if ($Debug) { debug("Total real / shown : $TotalKeyphrases / $total_s",2); }
			$rest_s=$TotalKeyphrases-$total_s;
			if ($rest_s > 0) {
				my $p;
				if ($TotalKeyphrases) { $p=int($rest_s/$TotalKeyphrases*1000)/10; }
				print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[124]</font></TD><TD>$rest_s</TD>";
				print "<TD>$p&nbsp;%</TD></TR>\n";
			}
			&tab_end;
			if ($ShowKeyphrasesStats && $ShowKeywordsStats) { print "</td>\n";	}
		}
		if ($ShowKeywordsStats) {
			# By Keywords
			if ($ShowKeyphrasesStats && $ShowKeywordsStats) { print "<td width=\"50%\" valign=top>\n";	}
			if ($Debug) { debug("ShowKeywordsStats",2); }
			&tab_head("$Message[121] ($Message[77] $MaxNbOf{'KeywordsShown'})<br><a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=keywords":"$PROG$StaticLinks.keywords.html")."\"$NewLinkTarget>$Message[80]</a>",19,($ShowKeyphrasesStats && $ShowKeywordsStats)?95:70);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"".($TOOLTIPON?" onmouseover=\"ShowTip(15);\" onmouseout=\"HideTip(15);\"":"")."><TH>$TotalDifferentKeywords $Message[13]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[14]</TH><TH bgcolor=\"#$color_s\" width=80>$Message[15]</TH></TR>\n";
			$total_s=0;
			my $count=0;
			&BuildKeyList($MaxNbOf{'KeywordsShown'},$MinHit{'Keyword'},\%_keywords,\%_keywords);
			foreach my $key (@keylist) {
				my $mot = DecodeEncodedString(CleanFromCSSA($key));
				my $p;
				if ($TotalKeywords) { $p=int($_keywords{$key}/$TotalKeywords*1000)/10; }
				print "<TR><TD CLASS=AWL>$mot</TD><TD>$_keywords{$key}</TD><TD>$p %</TD></TR>\n";
				$total_s += $_keywords{$key};
				$count++;
			}
			if ($Debug) { debug("Total real / shown : $TotalKeywords / $total_s",2); }
			$rest_s=$TotalKeywords-$total_s;
			if ($rest_s > 0) {
				my $p;
				if ($TotalKeywords) { $p=int($rest_s/$TotalKeywords*1000)/10; }
				print "<TR><TD CLASS=AWL><font color=\"#$color_other\">$Message[30]</font></TD><TD>$rest_s</TD>";
				print "<TD>$p %</TD></TR>\n";
			}
			&tab_end;
			if ($ShowKeyphrasesStats && $ShowKeywordsStats) { print "</td>\n";	}
		}
		if ($ShowKeyphrasesStats && $ShowKeywordsStats) { print "</tr></table>\n"; }
	
		print "\n<a name=\"OTHER\">&nbsp;</a>\n\n";
	
		# BY ERRORS
		#----------------------------
		if ($ShowHTTPErrorsStats) {
			if ($Debug) { debug("ShowHTTPErrorsStats",2); }
			print "$Center<a name=\"ERRORS\">&nbsp;</a><BR>\n";
			my $title="$Message[32]";
			&tab_head("$title",19);
			print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH colspan=2>$Message[32]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH><TH bgcolor=\"#$color_h\" width=80>$Message[15]</TH><TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH></TR>\n";
			$total_h=0;
			my $count=0;
			&BuildKeyList($MaxRowsInHTMLOutput,1,\%_errors_h,\%_errors_h);
			foreach my $key (@keylist) {
				my $p=int($_errors_h{$key}/$TotalHitsErrors*1000)/10;
				print "<TR".($TOOLTIPON?" onmouseover=\"ShowTip($key);\" onmouseout=\"HideTip($key);\"":"").">";
				if ($TrapInfosForHTTPErrorCodes{$key}) { print "<TD><a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?"$AWScript?${NewLinkParams}output=errors$key":"$PROG$StaticLinks.errors$key.html")."\"$NewLinkTarget>$key</a></TD>"; }
				else { print "<TD>$key</TD>"; }
				print "<TD CLASS=AWL>".($httpcodelib{$key}?$httpcodelib{$key}:'Unknown error')."</TD><TD>$_errors_h{$key}</TD><TD>$p %</TD><TD>".Format_Bytes($_errors_k{$key})."</TD>";
				print "</TR>\n";
				$total_h+=$_errors_h{$key};
				$count++;
			}
			&tab_end;
		}
	
	 	# BY EXTRA SECTIONS
	 	#----------------------------
	 	foreach my $extranum (1..@ExtraName-1) {
	 		if ($Debug) { debug("ExtraName$extranum",2); }
	 		print "$Center<a name=\"EXTRA$extranum\">&nbsp;</a><BR>";
			my $title=$ExtraName[$extranum];
	 		&tab_head("$title",19);
	 		print "<TR bgcolor=\"#$color_TableBGRowTitle\"><TH>".$ExtraFirstColumnTitle[$extranum]."</TH>";
	 		if ($ExtraStatTypes[$extranum] =~ m/P/i) { print "<TH bgcolor=\"#$color_p\" width=80>$Message[56]</TH>"; }
	 		if ($ExtraStatTypes[$extranum] =~ m/H/i) { print "<TH bgcolor=\"#$color_h\" width=80>$Message[57]</TH>"; }
	 		if ($ExtraStatTypes[$extranum] =~ m/B/i) { print "<TH bgcolor=\"#$color_k\" width=80>$Message[75]</TH>"; }
	 		if ($ExtraStatTypes[$extranum] =~ m/L/i) { print "<TH width=120>$Message[9]</TH>"; }
	 		print "</TR>\n";
	 		$total_p=$total_h=$total_k=0;
	 		#$max_h=1; foreach my $key (values %_login_h) { if ($key > $max_h) { $max_h = $key; } }
	 		#$max_k=1; foreach my $key (values %_login_k) { if ($key > $max_k) { $max_k = $key; } }
	 		my $count=0;
	 		if ($ExtraStatTypes[$extranum] =~ m/P/i) { 
	 			&BuildKeyList($MaxNbOfExtra[$extranum],$MinHitExtra[$extranum],\%{'_section_' . $extranum . '_h'},\%{'_section_' . $extranum . '_p'});
	 		}
	 		else {
	 			&BuildKeyList($MaxNbOfExtra[$extranum],$MinHitExtra[$extranum],\%{'_section_' . $extranum . '_h'},\%{'_section_' . $extranum . '_h'});
	 		}
			foreach my $key (@keylist) {
	 			my $firstcol = DecodeEncodedString(CleanFromCSSA($key));
	 			print "<TR><TD CLASS=AWL>$firstcol</TD>";
	 			if ($ExtraStatTypes[$extranum] =~ m/P/i) { print "<TD>" . ${'_section_' . $extranum . '_p'}{$key} . "</TD>"; }
	 			if ($ExtraStatTypes[$extranum] =~ m/H/i) { print "<TD>" . ${'_section_' . $extranum . '_h'}{$key} . "</TD>"; }
	 			if ($ExtraStatTypes[$extranum] =~ m/B/i) { print "<TD>" . Format_Bytes(${'_section_' . $extranum . '_k'}{$key}) . "</TD>"; }
	 			if ($ExtraStatTypes[$extranum] =~ m/L/i) { print "<TD>" . (${'_section_' . $extranum . '_l'}{$key}?Format_Date(${'_section_' . $extranum . '_l'}{$key},1):'-') . "</TD>"; }
	 			print "</TR>\n";
	 			$count++;
			}
	 		&tab_end;
	 	}
	
		&html_end;
	}
}
else {
	# if ($LastLineRead < $NbOfLinesRead) { Print "Jumped lines in file: $LastLineRead\n"; }
	print "Parsed lines in file: $NbOfLinesParsed\n";
	print "Found $NbOfLinesDropped dropped records,\n";
	print "Found $NbOfLinesCorrupted corrupted records,\n";
	print "Found $NbOfOldLines old records,\n";
	print "Found $NbOfNewLines new qualifed records.\n";
}

0;	# Do not remove this line


#-------------------------------------------------------
# ALGORITHM SUMMARY
#
# Read config file
# Check config and Init variables
# html_head
#
# If 'migrate'
#   We create/update tmp file with
#     &Read_History_With_TmpUpdate(year,month,UPDATE,NOPURGE,"all");
#   Rename the tmp file
#   html_end
#   Exit
# End of 'migrate'
#
# Get last history file name
# Get value for $LastLine $LastLineNumber $LastLineOffset $LastLineChecksum with
#	&Read_History_With_TmpUpdate(lastyear,lastmonth,NOUPDATE,NOPURGE,"general");
#
# &Init_HashArray()
#
# If 'update'
#   Loop on each new line in log file
#     lastlineoffset=lastlineoffsetnext; lastlineoffsetnext=file pointer position
#     If line corrupted, skip --> next on loop
#	  Drop wrong virtual host --> next on loop
#     Drop wrong protocol --> next on loop
#     Drop wrong date --> next on loop
#     If line older than $LastLine, skip --> next on loop
#     So it's new line
#     $LastLine = time or record
#     Skip line for @SkipHosts --> next on loop
#     Skip line for @SkipFiles --> next on loop
#     Skip line for not @OnlyHosts --> next on loop
#     Skip line for not @OnlyFiles --> next on loop
#     Skip line for @SkipUserAgent --> next on loop
#     So it's new line approved
#     If other month/year, create/update tmp file and purge data arrays with
#       &Read_History_With_TmpUpdate(lastprocessedyear,lastprocessedmonth,UPDATE,PURGE,"all",lastlinenumber,lastlineoffset,checksum($_));
#     Check protocol and complete %_error_, %_sider404 and %_referrer404
#     Check robot and complete %_robot
#     ...
#     If too many records, we flush data arrays with
#       &Read_History_With_TmpUpdate($lastprocessedyear,$lastprocessedmonth,UPDATE,PURGE,"all",lastlinenumber,lastlineoffset,checksum($_));
#   End of loop
#   Create/update tmp file
#	  Seek to lastlineoffset to read and get last line into $_ 
#	  &Read_History_With_TmpUpdate($lastprocessedyear,$lastprocessedmonth,UPDATE,PURGE,"all",lastlinenumber,lastlineoffset,checksum($_))
#   Rename all tmp files
# End of 'update'
#
# &Init_HashArray()
#
# If 'output'
#   Loop for each month of required year
#     &Read_History_With_TmpUpdate($YearRequired,monthloop,NOUPDATE,NOPURGE,"all" or "general time" if not required month)
#   End of loop
#   Show data arrays in HTML page
#   html_end
# End of 'output'
#-------------------------------------------------------

#-------------------------------------------------------
# DNS CACHE FILE FORMATS
# /etc/hosts    x.y.z.w hostname
# Analog		UT/60 x.y.z.w hostname
#-------------------------------------------------------

#-------------------------------------------------------
# IP Format (d=decimal on 16 bits, x=hexadecimal on 16 bits)
#
# 13.1.68.3						IPv4 (d.d.d.d)
# 0:0:0:0:0:0:13.1.68.3 		IPv6 (x:x:x:x:x:x:d.d.d.d)
# ::13.1.68.3
# 0:0:0:0:0:FFFF:13.1.68.3 		IPv6 (x:x:x:x:x:x:d.d.d.d)
# ::FFFF:13.1.68.3 				IPv6
#
# 1070:0:0:0:0:800:200C:417B 	IPv6
# 1070:0:0:0:0:800:200C:417B 	IPv6
# 1070::800:200C:417B 			IPv6
#-------------------------------------------------------

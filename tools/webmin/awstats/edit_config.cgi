#!/usr/bin/perl
# edit_config.cgi
# Display a form for adding a new config or editing an existing one.

require './awstats-lib.pl';
&ReadParse();

if (! $access{'global'}) { &error($text{'edit_ecannot'}); }

my $filecontent="";
my $filetoopen="";
if ($in{'new'}) {
        $filetoopen=$config{'alt_conf'};
}
else {
        $filetoopen=$in{'file'};
}

if ($in{'new'}) {
	$access{'add'} || &error($text{'edit_ecannot'});
	&header($text{'edit_title1'}, "");
	}
else {
	&can_edit_config($in{'file'}) || &error($text{'edit_ecannot'});
	&header($text{'edit_title2'}, "");
	}
# Get parameters
$lconf = &get_config($filetoopen);
foreach my $key (keys %$lconf) {
	$lconf->{$key}=~s/^\s*//g;
	$lconf->{$key}=~s/^*[\"\']//;
	$lconf->{$key}=~s/#.*$//;
	$lconf->{$key}=~s/\s*$//g;
	$lconf->{$key}=~s/[\"\']\s*$//;
}

print "<hr>\n";

print <<EOF;
<SCRIPT LANGUAGE="JavaScript">
function Submit_onClick() {
	if (document.editconfig.LogFormat.value=='') {
		alert('$text{save_errLogFormat}');
		document.editconfig.LogFormat.focus();
		return false;
	}
	if (document.editconfig.LogFile.value.match(/maillogconvert.pl/)!=null && document.editconfig.LogType.value != 'M') {
		alert('Your log file is preprocessed by maillogconvert.pl but is not defined as a "Mail" log type.\\nChange LogFile or LogType parameter.');
		document.editconfig.LogType.focus();
		return false;
	}
	if (document.editconfig.SiteDomain.value=='') {
		alert('$text{save_errSiteDomain}');
		document.editconfig.SiteDomain.focus();
		return false;
	}
	if (document.editconfig.DirData.value=='') {
		alert('$text{save_errDirData}');
		document.editconfig.DirData.focus();
		return false;
	}
	return true;
}

function neww(id) {
	var argv = neww.arguments;
	var argc = neww.arguments.length;
	tmp=id;
	var l = (argc > 1) ? argv[1] : 640;
	var h = (argc > 2) ? argv[2] : 450;
	var wfeatures="directories=0,menubar=1,status=0,resizable=1,scrollbars=1,toolbar=0,width="+l+",height="+h+",left=" + eval("(screen.width - l)/2") + ",top=" + eval("(screen.height - h)/2");
	fen=window.open(tmp,'window',wfeatures);
}
</SCRIPT>
EOF

if (-d "/private/etc" && ! &can_edit_config("/private/etc")) { # For MacOS users
	print "Warning: It seems that you are a MacOS user. With MacOS, the '/etc/awstats' directory is not a hard directory but a link to '/private/etc/awstats' which is not by default an allowed directory to store config files, so if you want to store config files in '/etc/awstats', you must first change the Webmin ACL for AWStats module to add '/private/etc' in the allowed directories list:<br>\n";
	print &text('index_changeallowed',"<a href=\"/acl/\">Webmin - Webmin Users</a>", $text{'index_title'})."<br>\n";
}


print "<form name='editconfig' action='save_config.cgi'>\n";

print "<table border width=100%>\n";
print "<tr $tb> <td><b>";
if ($in{'new'}) {
	print &text('edit_headernew');
}
else {
	print &text('edit_header',$in{'file'});
}
print "</b></td> </tr>\n";
print "<tr $cb> <td><table width=100%>\n";



my $filenametosave="";
if ($in{'new'}) {
	print "<tr> <td><b>$text{'edit_add'}</b></td> <td>\n";

	my $newfile="/etc/awstats/awstats.newconfig.conf";
	print "<input type=text name=new size=50 value='$newfile'>";

	print "</td> <td> </td> </tr>\n";
	print "<tr> <td colspan=3><hr></td> </tr>\n";
} else {
	print "<input type=hidden name=file value='$in{'file'}'>\n";
}
print "<input type=hidden name=oldfile value='$in{'file'}'>\n";

print "<tr> <td colspan=3>MAIN SETUP SECTION (Required to make AWStats work)<br><hr></td> </tr>\n";

print "<tr> <td><b>LogFile</b></td> <td> <input type=text name=LogFile size=50 value='$lconf->{'LogFile'}'> ".&file_chooser_button("LogFile",0,0)." </td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=LogFile")." </td> </tr>\n";
print "<tr> <td><b>LogType</b></td> <td> ";
print "<select name=LogType>";
print "<option value='W'".($lconf->{'LogType'} eq 'W'?" selected":"").">W (Web server log file)</option>\n";
print "<option value='S'".($lconf->{'LogType'} eq 'S'?" selected":"").">S (Streaming server log file)</option>\n";
print "<option value='M'".($lconf->{'LogType'} eq 'M'?" selected":"").">M (Mail server log file)</option>\n";
print "<option value='F'".($lconf->{'LogType'} eq 'F'?" selected":"").">F (Ftp server log file)</option>\n";
print "</select>\n";
print "</td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=LogType")." </td> </tr>\n";
print "<tr> <td><b>LogFormat</b></td> <td> <input name=LogFormat type=text size=40 value='$lconf->{'LogFormat'}'> </td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=LogFormat")," </td> </tr>\n";
print "<tr> <td><b>LogSeparator</b></td> <td> <input size=10 name=LogSeparator type=text value='$lconf->{'LogSeparator'}'> </td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=LogSeparator")." </td> </tr>\n";
print "<tr> <td><b>SiteDomain</b></td> <td> <input name=SiteDomain type=text value='$lconf->{'SiteDomain'}'> </td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=SiteDomain")." </td> </tr>\n";
print "<tr> <td><b>HostAliases</b></td> <td> <input size=50 name=HostAliases type=text value='$lconf->{'HostAliases'}'> </td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=HostAliases")." </td> </tr>\n";
print "<tr> <td><b>DNSLookup</b></td> <td> <input size=10 name=DNSLookup type=text value='$lconf->{'DNSLookup'}'> </td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=DNSLookup")." </td> </tr>\n";
print "<tr> <td><b>DirData</b></td> <td> <input size=40 name=DirData type=text value='$lconf->{'DirData'}'> </td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=DirData")." </td> </tr>\n";
print "<tr> <td><b>DirCgi</b></td> <td> <input size=30 name=DirCgi type=text value='$lconf->{'DirCgi'}'> </td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=DirCgi")." </td> </tr>\n";
print "<tr> <td><b>DirIcons</b></td> <td> <input size=30 name=DirIcons type=text value='$lconf->{'DirIcons'}'> </td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=DirIcons")." </td> </tr>\n";
print "<tr> <td><b>AllowToUpdateStatsFromBrowser</b></td> <td> <input size=10 name=AllowToUpdateStatsFromBrowser type=text value='$lconf->{'AllowToUpdateStatsFromBrowser'}'> </td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=AllowToUpdateStatsFromBrowser")." </td> </tr>\n";
print "<tr> <td><b>AllowFullYearView</b></td> <td> <input size=10 name=AllowFullYearView type=text value='$lconf->{'AllowFullYearView'}'> </td> <td> ";
print &hblink($text{'help_help'}, "help.cgi?param=AllowFullYearView")." </td> </tr>\n";


print "<tr> <td colspan=3><br>OPTIONAL SETUP SECTION (Not required but increase AWStats features)<br><hr></td> </tr>\n";
if ($in{'advanced'} == 1) {
	print "<tr> <td><b>EnableLockForUpdate</b></td> <td> <input size=10 name=EnableLockForUpdate type=text value='$lconf->{'EnableLockForUpdate'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=EnableLockForUpdate")." </td> </tr>\n";
	print "<tr> <td><b>DNSStaticCacheFile</b></td> <td> <input size=30 name=DNSStaticCacheFile type=text value='$lconf->{'DNSStaticCacheFile'}'> ".&file_chooser_button("DNSStaticCacheFile",0,0)."</td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=DNSStaticCacheFile")." </td> </tr>\n";
	print "<tr> <td><b>DNSLastUpdateCacheFile</b></td> <td> <input size=30 name=DNSLastUpdateCacheFile type=text value='$lconf->{'DNSLastUpdateCacheFile'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=DNSLastUpdateCacheFile")." </td> </tr>\n";
	print "<tr> <td><b>SkipDNSLookupFor</b></td> <td> <input size=30 name=SkipDNSLookupFor type=text value='$lconf->{'SkipDNSLookupFor'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=SkipDNSLookupFor")." </td> </tr>\n";
	print "<tr> <td><b>AllowAccessFromWebToAuthenticatedUsersOnly</b></td> <td> <input size=10 name=AllowAccessFromWebToAuthenticatedUsersOnly type=text value='$lconf->{'AllowAccessFromWebToAuthenticatedUsersOnly'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=AllowAccessFromWebToAuthenticatedUsersOnly")." </td> </tr>\n";
	print "<tr> <td><b>AllowAccessFromWebToFollowingAuthenticatedUsers</b></td> <td> <input size=30 name=AllowAccessFromWebToFollowingAuthenticatedUsers type=text value='$lconf->{'AllowAccessFromWebToFollowingAuthenticatedUsers'}'> ".&user_chooser_button('AllowAccessFromWebToFollowingAuthenticatedUsers', multiple, 0)."</td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=AllowAccessFromWebToFollowingAuthenticatedUsers")." </td> </tr>\n";
	print "<tr> <td><b>AllowAccessFromWebToFollowingIPAddresses</b></td> <td> <input size=30 name=AllowAccessFromWebToFollowingIPAddresses type=text value='$lconf->{'AllowAccessFromWebToFollowingIPAddresses'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=AllowAccessFromWebToFollowingIPAddresses")." </td> </tr>\n";
	print "<tr> <td><b>CreateDirDataIfNotExists</b></td> <td> <input size=10 name=CreateDirDataIfNotExists type=text value='$lconf->{'CreateDirDataIfNotExists'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=CreateDirDataIfNotExists")." </td> </tr>\n";
	print "<tr> <td><b>BuildHistoryFormat</b></td> <td> <input size=10 name=BuildHistoryFormat type=text value='$lconf->{'BuildHistoryFormat'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=BuildHistoryFormat")." </td> </tr>\n";
	print "<tr> <td><b>BuildReportFormat</b></td> <td> <input size=10 name=BuildReportFormat type=text value='$lconf->{'BuildReportFormat'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=BuildReportFormat")." </td> </tr>\n";
	print "<tr> <td><b>SaveDatabaseFilesWithPermissionsForEveryone</b></td> <td> <input size=10 name=SaveDatabaseFilesWithPermissionsForEveryone type=text value='$lconf->{'SaveDatabaseFilesWithPermissionsForEveryone'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=SaveDatabaseFilesWithPermissionsForEveryone")." </td> </tr>\n";
	print "<tr> <td><b>PurgeLogFile</b></td> <td> <input size=10 name=PurgeLogFile type=text value='$lconf->{'PurgeLogFile'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=PurgeLogFile")." </td> </tr>\n";
	print "<tr> <td><b>ArchiveLogRecords</b></td> <td> <input size=10 name=ArchiveLogRecords type=text value='$lconf->{'ArchiveLogRecords'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ArchiveLogRecords")." </td> </tr>\n";
	print "<tr> <td><b>KeepBackupOfHistoricFiles</b></td> <td> <input size=10 name=KeepBackupOfHistoricFiles type=text value='$lconf->{'KeepBackupOfHistoricFiles'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=KeepBackupOfHistoricFiles")." </td> </tr>\n";
	print "<tr> <td><b>DefaultFile</b></td> <td> <input size=20 name=DefaultFile type=text value='$lconf->{'DefaultFile'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=DefaultFile")." </td> </tr>\n";
	print "<tr> <td><b>SkipHosts</b></td> <td> <input size=30 name=SkipHosts type=text value='$lconf->{'SkipHosts'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=SkipHosts")." </td> </tr>\n";
	print "<tr> <td><b>SkipUserAgents</b></td> <td> <input size=30 name=SkipUserAgents type=text value='$lconf->{'SkipUserAgents'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=SkipUserAgents")." </td> </tr>\n";
	print "<tr> <td><b>SkipFiles</b></td> <td> <input size=30 name=SkipFiles type=text value='$lconf->{'SkipFiles'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=SkipFiles")." </td> </tr>\n";
	print "<tr> <td><b>OnlyHosts</b></td> <td> <input size=30 name=OnlyHosts type=text value='$lconf->{'OnlyHosts'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=OnlyHosts")." </td> </tr>\n";
	print "<tr> <td><b>OnlyUserAgents</b></td> <td> <input size=30 name=OnlyUserAgents type=text value='$lconf->{'OnlyUserAgents'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=OnlyUserAgents")." </td> </tr>\n";
	print "<tr> <td><b>OnlyFiles</b></td> <td> <input size=30 name=OnlyFiles type=text value='$lconf->{'OnlyFiles'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=OnlyFiles")." </td> </tr>\n";
	print "<tr> <td><b>NotPageList</b></td> <td> <input size=30 name=NotPageList type=text value='$lconf->{'NotPageList'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=NotPageList")." </td> </tr>\n";
	print "<tr> <td><b>ValidHTTPCodes</b></td> <td> <input size=20 name=ValidHTTPCodes type=text value='$lconf->{'ValidHTTPCodes'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ValidHTTPCodes")." </td> </tr>\n";
	print "<tr> <td><b>ValidSMTPCodes</b></td> <td> <input size=20 name=ValidSMTPCodes type=text value='$lconf->{'ValidSMTPCodes'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ValidSMTPCodes")." </td> </tr>\n";
	print "<tr> <td><b>AuthenticatedUsersNotCaseSensitive</b></td> <td> <input size=10 name=AuthenticatedUsersNotCaseSensitive type=text value='$lconf->{'AuthenticatedUsersNotCaseSensitive'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=AuthenticatedUsersNotCaseSensitive")." </td> </tr>\n";
	print "<tr> <td><b>URLNotCaseSensitive</b></td> <td> <input size=10 name=URLNotCaseSensitive type=text value='$lconf->{'URLNotCaseSensitive'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=URLNotCaseSensitive")." </td> </tr>\n";
	print "<tr> <td><b>URLWithAnchor</b></td> <td> <input size=10 name=URLWithAnchor type=text value='$lconf->{'URLWithAnchor'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=URLWithAnchor")." </td> </tr>\n";
	print "<tr> <td><b>URLQuerySeparators</b></td> <td> <input size=10 name=URLQuerySeparators type=text value='$lconf->{'URLQuerySeparators'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=URLQuerySeparators")." </td> </tr>\n";
	print "<tr> <td><b>URLWithQuery</b></td> <td> <input size=10 name=URLWithQuery type=text value='$lconf->{'URLWithQuery'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=URLWithQuery")." </td> </tr>\n";
	print "<tr> <td><b>URLWithQueryWithOnlyFollowingParameters</b></td> <td> <input size=30 name=URLWithQueryWithOnlyFollowingParameters type=text value='$lconf->{'URLWithQueryWithOnlyFollowingParameters'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=URLWithQueryWithOnlyFollowingParameters")." </td> </tr>\n";
	print "<tr> <td><b>URLWithQueryWithoutFollowingParameters</b></td> <td> <input size=30 name=URLWithQueryWithoutFollowingParameters type=text value='$lconf->{'URLWithQueryWithoutFollowingParameters'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=URLWithQueryWithoutFollowingParameters")." </td> </tr>\n";
	print "<tr> <td><b>URLReferrerWithQuery</b></td> <td> <input size=10 name=URLReferrerWithQuery type=text value='$lconf->{'URLReferrerWithQuery'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=URLReferrerWithQuery")." </td> </tr>\n";
	print "<tr> <td><b>WarningMessages</b></td> <td> <input size=10 name=WarningMessages type=text value='$lconf->{'WarningMessages'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=WarningMessages")." </td> </tr>\n";
	print "<tr> <td><b>ErrorMessages</b></td> <td> <input size=40 name=ErrorMessages type=text value='$lconf->{'ErrorMessages'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ErrorMessages")." </td> </tr>\n";
	print "<tr> <td><b>DebugMessages</b></td> <td> <input size=10 name=DebugMessages type=text value='$lconf->{'DebugMessages'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=DebugMessages")." </td> </tr>\n";
	print "<tr> <td><b>NbOfLinesForCorruptedLog</b></td> <td> <input size=10 name=NbOfLinesForCorruptedLog type=text value='$lconf->{'NbOfLinesForCorruptedLog'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=NbOfLinesForCorruptedLog")." </td> </tr>\n";
	print "<tr> <td><b>WrapperScript</b></td> <td> <input size=20 name=WrapperScript type=text value='$lconf->{'WrapperScript'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=WrapperScript")." </td> </tr>\n";
	print "<tr> <td><b>DecodeUA</b></td> <td> <input size=10 name=DecodeUA type=text value='$lconf->{'DecodeUA'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=DecodeUA")." </td> </tr>\n";
	print "<tr> <td><b>MiscTrackerUrl</b></td> <td> <input size=30 name=MiscTrackerUrl type=text value='$lconf->{'MiscTrackerUrl'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MiscTrackerUrl")." </td> </tr>\n";
	print "<tr> <td colspan=3 align=center><a href='edit_config.cgi?".($in{'new'}?"new=1&":"")."&file=$in{'file'}'>$text{'index_hideadvanced'}</a></td></tr>\n";
}
else {
	print "<tr> <td colspan=3 align=center><a href='edit_config.cgi?".($in{'new'}?"new=1&":"")."advanced=1&file=$in{'file'}'>$text{'index_advanced1'}</a></td></tr>\n";
}
print "<tr> <td colspan=3><br></td> </tr>\n";

print "<tr> <td colspan=3><br>OPTIONAL ACCURACY SETUP SECTION (Not required but increase AWStats features)<br><hr></td> </tr>\n";
if ($in{'advanced'} == 2) {
	print "<tr> <td><b>LevelForBrowsersDetection</b></td> <td> <input size=10 type=text name=LevelForBrowsersDetection value='$lconf->{'LevelForBrowsersDetection'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=LevelForBrowsersDetection")." </td> </tr>\n";
	print "<tr> <td><b>LevelForOSDetection</b></td> <td> <input size=10 type=text name=LevelForOSDetection value='$lconf->{'LevelForOSDetection'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=LevelForOSDetection")." </td> </tr>\n";
	print "<tr> <td><b>LevelForRefererAnalyze</b></td> <td> <input size=10 type=text name=LevelForRefererAnalyze value='$lconf->{'LevelForRefererAnalyze'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=LevelForRefererAnalyze")." </td> </tr>\n";
	print "<tr> <td><b>LevelForRobotsDetection</b></td> <td> <input size=10 type=text name=LevelForRobotsDetection value='$lconf->{'LevelForRobotsDetection'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=LevelForRobotsDetection")." </td> </tr>\n";
	print "<tr> <td><b>LevelForSearchEnginesDetection</b></td> <td> <input size=10 type=text name=LevelForSearchEnginesDetection value='$lconf->{'LevelForSearchEnginesDetection'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=LevelForSearchEnginesDetection")." </td> </tr>\n";
	print "<tr> <td><b>LevelForKeywordsDetection</b></td> <td> <input size=10 type=text name=LevelForKeywordsDetection value='$lconf->{'LevelForKeywordsDetection'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=LevelForKeywordsDetection")." </td> </tr>\n";
	print "<tr> <td><b>LevelForFileTypesDetection</b></td> <td> <input size=10 type=text name=LevelForFileTypesDetection value='$lconf->{'LevelForFileTypesDetection'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=LevelForFileTypesDetection")." </td> </tr>\n";
	print "<tr> <td><b>LevelForWormsDetection</b></td> <td> <input size=10 type=text name=LevelForWormsDetection value='$lconf->{'LevelForWormsDetection'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=LevelForWormsDetection")." </td> </tr>\n";
	print "<tr> <td colspan=3 align=center><a href='edit_config.cgi?".($in{'new'}?"new=1&":"")."&file=$in{'file'}'>$text{'index_hideadvanced'}</a></td></tr>\n";
} else {
	print "<tr> <td colspan=3 align=center><a href='edit_config.cgi?".($in{'new'}?"new=1&":"")."advanced=2&file=$in{'file'}'>$text{'index_advanced2'}</a></td></tr>\n";
}	
print "<tr> <td colspan=3><br></td> </tr>\n";

print "<tr> <td colspan=3><br>OPTIONAL APPEARANCE SETUP SECTION (Not required but increase AWStats features)<br><hr></td> </tr>\n";
if ($in{'advanced'} == 3) {
	print "<tr> <td><b>UseFramesWhenCGI</b></td> <td> <input size=10 name=UseFramesWhenCGI type=text value='$lconf->{'UseFramesWhenCGI'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=UseFramesWhenCGI")." </td> </tr>\n";
	print "<tr> <td><b>DetailedReportsOnNewWindows</b></td> <td> <input size=10 name=DetailedReportsOnNewWindows type=text value='$lconf->{'DetailedReportsOnNewWindows'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=DetailedReportsOnNewWindows")." </td> </tr>\n";
	print "<tr> <td><b>Expires</b></td> <td> <input size=10 name=Expires type=text value='$lconf->{'Expires'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=Expires")." </td> </tr>\n";
	print "<tr> <td><b>MaxRowsInHTMLOutput</b></td> <td> <input size=10 name=MaxRowsInHTMLOutput type=text value='$lconf->{'MaxRowsInHTMLOutput'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxRowsInHTMLOutput")." </td> </tr>\n";
	print "<tr> <td><b>Lang</b></td> <td> <input size=10 name=Lang type=text value='$lconf->{'Lang'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=Lang")." </td> </tr>\n";
	print "<tr> <td><b>DirLang</b></td> <td> <input size=30 name=DirLang type=text value='$lconf->{'DirLang'}'> ".&file_chooser_button("DirLang",1,0)."</td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=DirLang")." </td> </tr>\n";
	print "<tr> <td><b>ShowMenu</b></td> <td> <input size=10 name=ShowMenu type=text value='$lconf->{'ShowMenu'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowMenu")." </td> </tr>\n";
	print "<tr> <td><b>ShowMonthStats</b></td> <td> <input size=10 name=ShowMonthStats type=text value='$lconf->{'ShowMonthStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowMonthStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowDaysOfMonthStats</b></td> <td> <input size=10 name=ShowDaysOfMonthStats type=text value='$lconf->{'ShowDaysOfMonthStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowDaysOfMonthStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowDaysOfWeekStats</b></td> <td> <input size=10 name=ShowDaysOfWeekStats type=text value='$lconf->{'ShowDaysOfWeekStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowDaysOfWeekStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowHoursStats</b></td> <td> <input size=10 name=ShowHoursStats type=text value='$lconf->{'ShowHoursStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowHoursStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowDomainsStats</b></td> <td> <input size=10 name=ShowDomainsStats type=text value='$lconf->{'ShowDomainsStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowDomainsStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowHostsStats</b></td> <td> <input size=10 name=ShowHostsStats type=text value='$lconf->{'ShowHostsStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowHostsStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowAuthenticatedUsers</b></td> <td> <input size=10 name=ShowAuthenticatedUsers type=text value='$lconf->{'ShowAuthenticatedUsers'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowAuthenticatedUsers")." </td> </tr>\n";
	print "<tr> <td><b>ShowRobotsStats</b></td> <td> <input size=10 name=ShowRobotsStats type=text value='$lconf->{'ShowRobotsStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowRobotsStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowWormsStats</b></td> <td> <input size=10 name=ShowWormsStats type=text value='$lconf->{'ShowWormsStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowWormsStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowEMailSenders</b></td> <td> <input size=10 name=ShowEMailSenders type=text value='$lconf->{'ShowEMailSenders'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowEMailSenders")." </td> </tr>\n";
	print "<tr> <td><b>ShowEMailReceivers</b></td> <td> <input size=10 name=ShowEMailReceivers type=text value='$lconf->{'ShowEMailReceivers'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowEMailReceivers")." </td> </tr>\n";
	print "<tr> <td><b>ShowSessionsStats</b></td> <td> <input size=10 name=ShowSessionsStats type=text value='$lconf->{'ShowSessionsStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowSessionsStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowPagesStats</b></td> <td> <input size=10 name=ShowPagesStats type=text value='$lconf->{'ShowPagesStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowPagesStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowFileTypesStats</b></td> <td> <input size=10 name=ShowFileTypesStats type=text value='$lconf->{'ShowFileTypesStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowFileTypesStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowFileSizesStats</b></td> <td> <input size=10 name=ShowFileSizesStats type=text value='$lconf->{'ShowFileSizesStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowFileSizesStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowOSStats</b></td> <td> <input size=10 name=ShowOSStats type=text value='$lconf->{'ShowOSStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowOSStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowBrowsersStats</b></td> <td> <input size=10 name=ShowBrowsersStats type=text value='$lconf->{'ShowBrowsersStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowBrowsersStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowScreenSizeStats</b></td> <td> <input size=10 name=ShowScreenSizeStats type=text value='$lconf->{'ShowScreenSizeStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowScreenSizeStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowOriginStats</b></td> <td> <input size=10 name=ShowOriginStats type=text value='$lconf->{'ShowOriginStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowOriginStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowKeyphrasesStats</b></td> <td> <input size=10 name=ShowKeyphrasesStats type=text value='$lconf->{'ShowKeyphrasesStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowKeyphrasesStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowKeywordsStats</b></td> <td> <input size=10 name=ShowKeywordsStats type=text value='$lconf->{'ShowKeywordsStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowKeywordsStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowMiscStats</b></td> <td> <input size=10 name=ShowMiscStats type=text value='$lconf->{'ShowMiscStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowMiscStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowHTTPErrorsStats</b></td> <td> <input size=10 name=ShowHTTPErrorsStats type=text value='$lconf->{'ShowHTTPErrorsStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowHTTPErrorsStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowSMTPErrorsStats</b></td> <td> <input size=10 name=ShowSMTPErrorsStats type=text value='$lconf->{'ShowSMTPErrorsStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowSMTPErrorsStats")." </td> </tr>\n";
	print "<tr> <td><b>ShowClusterStats</b></td> <td> <input size=10 name=ShowClusterStats type=text value='$lconf->{'ShowClusterStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowClusterStats")." </td> </tr>\n";
	print "<tr> <td><b>AddDataArrayMonthStats</b></td> <td> <input size=10 name=AddDataArrayMonthStats type=text value='$lconf->{'AddDataArrayMonthStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=AddDataArrayMonthStats")." </td> </tr>\n";
	print "<tr> <td><b>AddDataArraySHowDaysOfMonthStats</b></td> <td> <input size=10 name=AddDataArraySHowDaysOfMonthStats type=text value='$lconf->{'AddDataArrayShowDaysOfMonthStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=AddDataArraySHowDaysOfMonthStats")." </td> </tr>\n";
	print "<tr> <td><b>AddDataArrayShowDaysOfWeekStats</b></td> <td> <input size=10 name=AddDataArrayShowDaysOfWeekStats type=text value='$lconf->{'AddDataArrayShowDaysOfWeekStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=AddDataArrayShowDaysOfWeekStats")." </td> </tr>\n";
	print "<tr> <td><b>AddDataArrayShowHoursStats</b></td> <td> <input size=10 name=AddDataArrayShowHoursStats type=text value='$lconf->{'AddDataArrayShowHoursStats'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=AddDataArrayShowHoursStats")." </td> </tr>\n";
	print "<tr> <td><b>IncludeInternalLinksInOriginSection</b></td> <td> <input size=10 name=IncludeInternalLinksInOriginSection type=text value='$lconf->{'IncludeInternalLinksInOriginSection'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=IncludeInternalLinksInOriginSection")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfDomain </b></td> <td> <input size=10 name=MaxNbOfDomain type=text value='$lconf->{'MaxNbOfDomain '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfDomain ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitDomain  </b></td> <td> <input size=10 name=MinHitDomain type=text value='$lconf->{'MinHitDomain  '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitDomain  ")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfHostsShown </b></td> <td> <input size=10 name=MaxNbOfHostsShown  type=text value='$lconf->{'MaxNbOfHostsShown '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfHostsShown ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitHost    </b></td> <td> <input size=10 name=MinHitHost     type=text value='$lconf->{'MinHitHost    '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitHost    ")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfLoginShown </b></td> <td> <input size=10 name=MaxNbOfLoginShown  type=text value='$lconf->{'MaxNbOfLoginShown '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfLoginShown ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitLogin   </b></td> <td> <input size=10 name=MinHitLogin    type=text value='$lconf->{'MinHitLogin   '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitLogin   ")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfRobotShown </b></td> <td> <input size=10 name=MaxNbOfRobotShown  type=text value='$lconf->{'MaxNbOfRobotShown '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfRobotShown ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitRobot   </b></td> <td> <input size=10 name=MinHitRobot    type=text value='$lconf->{'MinHitRobot   '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitRobot   ")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfPageShown </b></td> <td> <input size=10 name=MaxNbOfPageShown  type=text value='$lconf->{'MaxNbOfPageShown '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfPageShown ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitFile    </b></td> <td> <input size=10 name=MinHitFile     type=text value='$lconf->{'MinHitFile    '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitFile    ")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfOsShown </b></td> <td> <input size=10 name=MaxNbOfOsShown  type=text value='$lconf->{'MaxNbOfOsShown '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfOsShown ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitOs      </b></td> <td> <input size=10 name=MinHitOs       type=text value='$lconf->{'MinHitOs      '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitOs      ")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfBrowsersShown </b></td> <td> <input size=10 name=MaxNbOfBrowsersShown  type=text value='$lconf->{'MaxNbOfBrowsersShown '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfBrowsersShown ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitBrowser </b></td> <td> <input size=10 name=MinHitBrowser  type=text value='$lconf->{'MinHitBrowser '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitBrowser ")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfScreenSizesShown </b></td> <td> <input size=10 name=MaxNbOfScreenSizesShown  type=text value='$lconf->{'MaxNbOfScreenSizesShown '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfScreenSizesShown ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitScreenSize </b></td> <td> <input size=10 name=MinHitScreenSize  type=text value='$lconf->{'MinHitScreenSize '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitScreenSize ")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfRefererShown </b></td> <td> <input size=10 name=MaxNbOfRefererShown  type=text value='$lconf->{'MaxNbOfRefererShown '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfRefererShown ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitRefer   </b></td> <td> <input size=10 name=MinHitRefer    type=text value='$lconf->{'MinHitRefer   '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitRefer   ")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfKeyphrasesShown </b></td> <td> <input size=10 name=MaxNbOfKeyphrasesShown  type=text value='$lconf->{'MaxNbOfKeyphrasesShown '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfKeyphrasesShown ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitKeyphrase </b></td> <td> <input size=10 name=MinHitKeyphrase  type=text value='$lconf->{'MinHitKeyphrase '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitKeyphrase ")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfKeywordsShown </b></td> <td> <input size=10 name=MaxNbOfKeywordsShown  type=text value='$lconf->{'MaxNbOfKeywordsShown '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfKeywordsShown ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitKeyword </b></td> <td> <input size=10 name=MinHitKeyword  type=text value='$lconf->{'MinHitKeyword '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitKeyword ")." </td> </tr>\n";
	print "<tr> <td><b>MaxNbOfEMailsShown </b></td> <td> <input size=10 name=MaxNbOfEMailsShown  type=text value='$lconf->{'MaxNbOfEMailsShown '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxNbOfEMailsShown ")." </td> </tr>\n";
	print "<tr> <td><b>MinHitEMail   </b></td> <td> <input size=10 name=MinHitEMail    type=text value='$lconf->{'MinHitEMail   '}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MinHitEMail   ")." </td> </tr>\n";
	print "<tr> <td><b>FirstDayOfWeek</b></td> <td> <input size=10 name=FirstDayOfWeek type=text value='$lconf->{'FirstDayOfWeek'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=FirstDayOfWeek")." </td> </tr>\n";
	print "<tr> <td><b>ShowFlagLinks</b></td> <td> <input size=30 name=ShowFlagLinks type=text value='$lconf->{'ShowFlagLinks'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowFlagLinks")." </td> </tr>\n";
	print "<tr> <td><b>ShowLinksOnUrl</b></td> <td> <input size=10 name=ShowLinksOnUrl type=text value='$lconf->{'ShowLinksOnUrl'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=ShowLinksOnUrl")." </td> </tr>\n";
	print "<tr> <td><b>UseHTTPSLinkForUrl</b></td> <td> <input size=10 name=UseHTTPSLinkForUrl type=text value='$lconf->{'UseHTTPSLinkForUrl'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=UseHTTPSLinkForUrl")." </td> </tr>\n";
	print "<tr> <td><b>MaxLengthOfShownURL</b></td> <td> <input size=10 name=MaxLengthOfShownURL type=text value='$lconf->{'MaxLengthOfShownURL'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=MaxLengthOfShownURL")." </td> </tr>\n";
#	print "<tr> <td><b>LinksToWhoIs</b></td> <td> <input size=40 name=LinksToWhoIs type=text value='$lconf->{'LinksToWhoIs'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=LinksToWhoIs")." </td> </tr>\n";
#	print "<tr> <td><b>LinksToIPWhoIs</b></td> <td> <input size=40 name=LinksToIPWhoIs type=text value='$lconf->{'LinksToIPWhoIs'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=LinksToIPWhoIs")." </td> </tr>\n";
	print "<tr> <td><b>HTMLHeadSection</b></td> <td> <input size=30 name=HTMLHeadSection type=text value='$lconf->{'HTMLHeadSection'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=HTMLHeadSection")." </td> </tr>\n";
	print "<tr> <td><b>HTMLEndSection</b></td> <td> <input size=40 name=HTMLEndSection type=text value='$lconf->{'HTMLEndSection'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=HTMLEndSection")." </td> </tr>\n";
	print "<tr> <td><b>Logo</b></td> <td> <input size=30 name=Logo type=text value='$lconf->{'Logo'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=Logo")." </td> </tr>\n";
	print "<tr> <td><b>LogoLink</b></td> <td> <input size=30 name=LogoLink type=text value='$lconf->{'LogoLink'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=LogoLink")." </td> </tr>\n";
	print "<tr> <td><b>BarWidth / BarHeight</b></td> <td> <input size=10 name=BarWidth    type=text value='$lconf->{'BarWidth   '}'> / <input size=10 name=BarHeight   type=text value='$lconf->{'BarHeight  '}'></td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=BarWidth   ")." </td> </tr>\n";
	print "<tr> <td><b>StyleSheet</b></td> <td> <input size=20 name=StyleSheet type=text value='$lconf->{'StyleSheet'}'> </td> <td> ";
	print &hblink($text{'help_help'}, "help.cgi?param=StyleSheet")." </td> </tr>\n";
#	print "<tr> <td><b>color_Background</b></td> <td> <input size=10 name=color_Background type=text value='$lconf->{'color_Background'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_Background")." </td> </tr>\n";
#	print "<tr> <td><b>color_TableBGTitle</b></td> <td> <input size=10 name=color_TableBGTitle type=text value='$lconf->{'color_TableBGTitle'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_TableBGTitle")." </td> </tr>\n";
#	print "<tr> <td><b>color_TableTitle</b></td> <td> <input size=10 name=color_TableTitle type=text value='$lconf->{'color_TableTitle'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_TableTitle")." </td> </tr>\n";
#	print "<tr> <td><b>color_TableBG</b></td> <td> <input size=10 name=color_TableBG type=text value='$lconf->{'color_TableBG'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_TableBG")." </td> </tr>\n";
#	print "<tr> <td><b>color_TableRowTitle</b></td> <td> <input size=10 name=color_TableRowTitle type=text value='$lconf->{'color_TableRowTitle'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_TableRowTitle")." </td> </tr>\n";
#	print "<tr> <td><b>color_TableBGRowTitle</b></td> <td> <input size=10 name=color_TableBGRowTitle type=text value='$lconf->{'color_TableBGRowTitle'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_TableBGRowTitle")." </td> </tr>\n";
#	print "<tr> <td><b>color_TableBorder</b></td> <td> <input size=10 name=color_TableBorder type=text value='$lconf->{'color_TableBorder'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_TableBorder")." </td> </tr>\n";
#	print "<tr> <td><b>color_text</b></td> <td> <input size=10 name=color_text type=text value='$lconf->{'color_text'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_text")." </td> </tr>\n";
#	print "<tr> <td><b>color_textpercent</b></td> <td> <input size=10 name=color_textpercent type=text value='$lconf->{'color_textpercent'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_textpercent")." </td> </tr>\n";
#	print "<tr> <td><b>color_titletext</b></td> <td> <input size=10 name=color_titletext type=text value='$lconf->{'color_titletext'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_titletext")." </td> </tr>\n";
#	print "<tr> <td><b>color_weekend</b></td> <td> <input size=10 name=color_weekend type=text value='$lconf->{'color_weekend'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_weekend")." </td> </tr>\n";
#	print "<tr> <td><b>color_link</b></td> <td> <input size=10 name=color_link type=text value='$lconf->{'color_link'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_link")." </td> </tr>\n";
#	print "<tr> <td><b>color_hover</b></td> <td> <input size=10 name=color_hover type=text value='$lconf->{'color_hover'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_hover")." </td> </tr>\n";
#	print "<tr> <td><b>color_u</b></td> <td> <input size=10 name=color_u type=text value='$lconf->{'color_u'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_u")." </td> </tr>\n";
#	print "<tr> <td><b>color_v</b></td> <td> <input size=10 name=color_v type=text value='$lconf->{'color_v'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_v")." </td> </tr>\n";
#	print "<tr> <td><b>color_p</b></td> <td> <input size=10 name=color_p type=text value='$lconf->{'color_p'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_p")." </td> </tr>\n";
#	print "<tr> <td><b>color_h</b></td> <td> <input size=10 name=color_h type=text value='$lconf->{'color_h'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_h")." </td> </tr>\n";
#	print "<tr> <td><b>color_k</b></td> <td> <input size=10 name=color_k type=text value='$lconf->{'color_k'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_k")." </td> </tr>\n";
#	print "<tr> <td><b>color_s</b></td> <td> <input size=10 name=color_s type=text value='$lconf->{'color_s'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_s")." </td> </tr>\n";
#	print "<tr> <td><b>color_e</b></td> <td> <input size=10 name=color_e type=text value='$lconf->{'color_e'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_e")." </td> </tr>\n";
#	print "<tr> <td><b>color_x</b></td> <td> <input size=10 name=color_x type=text value='$lconf->{'color_x'}'> </td> <td> ";
#	print &hblink($text{'help_help'}, "help.cgi?param=color_x")." </td> </tr>\n";
	print "<tr> <td colspan=3 align=center><a href='edit_config.cgi?".($in{'new'}?"new=1&":"")."&file=$in{'file'}'>$text{'index_hideadvanced'}</a></td></tr>\n";
}
else {
	print "<tr> <td colspan=3 align=center><a href='edit_config.cgi?".($in{'new'}?"new=1&":"")."advanced=3&file=$in{'file'}'>$text{'index_advanced3'}</a></td></tr>\n";
}
print "<tr> <td colspan=3><br></td> </tr>\n";

print "<tr> <td colspan=3><br>PLUGINS SETUP SECTION (Not required but increase AWStats features)<br><hr></td> </tr>\n";
if ($in{'advanced'} == 4) {
	my $conflinenb = 0;
	my @pconfparam=();
	my @pconfvalue=();
	my @pconfvaluep=();
	my %pluginlinefound=();
	# Search the loadable plugins in edited config file
	open(FILE, $filetoopen) || error("Failed to open $filetoopen for reading plugins' config");
	while(<FILE>) {
		my $savline=$_;
		chomp $_; s/\r//;
		$conflinenb++;
		if ($_ =~ /^#?LoadPlugin/i) {
			# Extract param and value
			my ($load,$value)=split(/=/,$_,2);
			# Remove comments not at beginning of line
			$param =~ s/^\s+//; $param =~ s/\s+$//;
			$value =~ s/#.*$//; 
			$value =~ s/^[\s\'\"]+//g; $value =~ s/[\s\'\"]+$//g;
			($value1,$value2)=split(/\s/,$value,2);
			if ($value1 =~ /^graph3d$/i) { next; }
			if (! $pluginlinefound{$value1}) {	# To avoid plugin to be shown twice
				$pluginlinefound{$value1}=1;
				push @pconfparam, $value1;
				push @pconfvaluep, $value2;
    			my $active=0;
    			if ($load !~ /#.*LoadPlugin/i) { $active=1; }
				push @pconfactive, $active;
			}
		}	
	}
	close FILE;
	# Search the loadable plugins in sample config file (if not new)
	if (! $in{'new'}) {
		open(FILE, $config{'alt_conf'}) || error("Failed to open $config{'alt_conf'} for reading available plugins");
		while(<FILE>) {
			my $savline=$_;
			chomp $_; s/\r//;
			$conflinenb++;
			if ($_ =~ /^#?LoadPlugin/i) {
				# Extract param and value
				my ($load,$value)=split(/=/,$_,2);
				# Remove comments not at beginning of line
				$param =~ s/^\s+//; $param =~ s/\s+$//;
				$value =~ s/#.*$//; 
				$value =~ s/^[\s\'\"]+//g; $value =~ s/[\s\'\"]+$//g;
				($value1,$value2)=split(/\s/,$value,2);
				if ($value1 =~ /^graph3d$/i) { next; }
				if (! $pluginlinefound{$value1}) {	# To avoid plugin to be shown twice
					push @pconfparam, $value1;
					push @pconfvaluep, $value2;
                    # Plugin in sample but not in config file is by default not enabled.
        			my $active=0;
					push @pconfactive, $active;
				}
			}	
		}
		close FILE;
	}

	print "<tr> <td>Loaded plugins</td> <td>Plugin's parameters</td> <td> &nbsp; </td> </tr>\n";
	foreach my $key (0..(@pconfparam-1)) {
		print "<tr> <td> <input size=10 name=plugin_$pconfparam[$key] type=checkbox ".($pconfactive[$key]?" checked":"")."><b>$pconfparam[$key]</b></td> <td> <input size=30 name=plugin_param_$pconfparam[$key] type=text value='$pconfvaluep[$key]'> </td> <td> ";
		print &hblink($text{'help_help'}, "help.cgi?param=plugin_$pconfparam[$key]")." </td> </tr>\n";
	}	
	print "<tr> <td colspan=3 align=center><a href='edit_config.cgi?".($in{'new'}?"new=1&":"")."&file=$in{'file'}'>$text{'index_hideadvanced'}</a> <input type=\"hidden\" name=\"advanced\" value=\"4\"></td></tr>\n";
} else {
	print "<tr> <td colspan=3 align=center><a href='edit_config.cgi?".($in{'new'}?"new=1&":"")."advanced=4&file=$in{'file'}'>$text{'index_advanced4'}</a></td></tr>\n";
}	
print "<tr> <td colspan=3><br></td> </tr>\n";


if ($advanced) {
	print "<tr> <td colspan=3><br><hr></td> </tr>\n";
	print "<tr> <td colspan=3 align=center><a href='edit_config.cgi?".($in{'new'}?"new=1&":"")."file=$in{'file'}'>$text{'index_hideadvanced'}</a></td></tr>\n";
	print "<tr> <td colspan=3><hr></td> </tr>\n";
	print "</table>\n";
}
else{
	print "</table>\n";
}

@b=();
if ($in{'new'}) {
	push(@b, "<input type=submit value='$text{'create'}' onClick=\"return Submit_onClick();\">");
	}
else {
	if ($access{'global'}) {
		push(@b, "<input type=submit value='$text{'save'}' onClick=\"return Submit_onClick();\">");
	}
	if ($access{'add'}) {
		push(@b, "<input type=submit name='delete' value='$text{'delete'}'>");
	}
}

&spaced_buttons(@b);


print "</form>\n";

print "<hr>\n";
&footer("", $text{'index_return'});


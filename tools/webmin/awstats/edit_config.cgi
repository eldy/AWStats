#!/usr/bin/perl
# edit_log.cgi
# Display a form for adding a new logfile or editing an existing one.
# Allows you to set the schedule on which the log is analysed

require './awstats-lib.pl';
&foreign_require("cron", "cron-lib.pl");
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

print "<form action='save_config.cgi'>\n";

print "<table border width=100%>\n";
print "<tr $tb> <td><b>";
print &text('edit_header',$in{'file'});
print "</b></td> </tr>\n";
print "<tr $cb> <td><table width=100%>\n";



my $filenametosave="";
if ($in{'new'}) {
	print "<tr> <td><b>$text{'edit_add'}</b></td> <td>\n";
	print "<input type=text name=new size=40 value='$config{'awstats_conf'}/awstats.newconfig.conf'>";
	print "</td> <td> </td> </tr>\n";
	print "<tr> <td colspan=3><hr></td> </tr>\n";
} else {
	print "<input type=hidden name=file value='$in{'file'}'>\n";
}
print "<input type=hidden name=oldfile value='$in{'file'}'>\n";

print "<tr> <td colspan=3>MAIN SETUP SECTION (Required to make AWStats work)<br><hr></td> </tr>\n";

print "<tr> <td><b>LogFile</b></td> <td> <input type=text name=LogFile size=40 value='$lconf->{'LogFile'}'> ".&file_chooser_button("LogFile")." </td> <td> ";
print &hblink("Help", "help.cgi?param=LogFile")." </td> </tr>\n";
print "<tr> <td><b>LogType</b></td> <td> ";
print "<select name=LogType><option value='W'".($lconf->{'LogType'} eq 'W'?" selected":"").">W (Web server log file)</option>\n";
print "<option value='M'".($lconf->{'LogType'} eq 'M'?" selected":"").">M (Mail server log file)</option>\n";
print "<option value='F'".($lconf->{'LogType'} eq 'F'?" selected":"").">F (Ftp server log file)</option>\n";
print "</select>\n";
print "</td> <td> ";
print &hblink("Help", "help.cgi?param=LogType")." </td> </tr>\n";
print "<tr> <td><b>LogFormat</b></td> <td> <input name=LogFormat type=text size=40 value='$lconf->{'LogFormat'}'> </td> <td> ";
print &hblink("Help", "help.cgi?param=LogFormat")," </td> </tr>\n";
print "<tr> <td><b>LogSeparator</b></td> <td> <input name=LogSeparator type=text value='$lconf->{'LogSeparator'}'> </td> <td> ";
print &hblink("Help", "help.cgi?param=LogSeparator")." </td> </tr>\n";
print "<tr> <td><b>SiteDomain</b></td> <td> <input name=SiteDomain type=text value='$lconf->{'SiteDomain'}'> </td> <td> ";
print &hblink("Help", "help.cgi?param=SiteDomain")." </td> </tr>\n";
print "<tr> <td><b>HostAliases</b></td> <td> <input name=HostAliases type=text size=40 value='$lconf->{'HostAliases'}'> </td> <td> ";
print &hblink("Help", "help.cgi?param=HostAliases")." </td> </tr>\n";
print "<tr> <td><b>DNSLookup</b></td> <td> <input name=DNSLookup type=text value='$lconf->{'DNSLookup'}'> </td> <td> ";
print &hblink("Help", "help.cgi?param=DNSLookup")." </td> </tr>\n";
print "<tr> <td><b>DirData</b></td> <td> <input name=DirData type=text value='$lconf->{'DirData'}'> </td> <td> ";
print &hblink("Help", "help.cgi?param=DirData")." </td> </tr>\n";
print "<tr> <td><b>DirCgi</b></td> <td> <input name=DirCgi type=text value='$lconf->{'DirCgi'}'> </td> <td> ";
print &hblink("Help", "help.cgi?param=DirCgi")." </td> </tr>\n";
print "<tr> <td><b>DirIcons</b></td> <td> <input name=DirIcons type=text value='$lconf->{'DirIcons'}'> </td> <td> ";
print &hblink("Help", "help.cgi?param=DirIcons")." </td> </tr>\n";
print "<tr> <td><b>AllowToUpdateStatsFromBrowser</b></td> <td> <input name=AllowToUpdateStatsFromBrowser type=text value='$lconf->{'AllowToUpdateStatsFromBrowser'}'> </td> <td> ";
print &hblink("Help", "help.cgi?param=AllowToUpdateStatsFromBrowser")." </td> </tr>\n";

if (! $in{'advanced'}) {

	print "<tr> <td colspan=3><br><hr></td> </tr>\n";
	print "<tr> <td colspan=3 align=center><a href='edit_config.cgi?".($in{'new'}?"new=1&":"")."advanced=1&file=$in{'file'}'>$text{'index_advanced'}</a></td></tr>\n";
	print "<tr> <td colspan=3><hr></td> </tr>\n";
	print "</table>\n";
}
else {

	print "<tr> <td colspan=3><br>OPTIONAL SETUP SECTION (Not required but increase AWStats features)<br><hr></td> </tr>\n";
	print "<tr> <td colspan=3>Not available in this version of AWStats Webmin module</td> </tr>\n";
	
	print "<tr> <td colspan=3><br>OPTIONAL ACCURACY SETUP SECTION (Not required but increase AWStats features)<br><hr></td> </tr>\n";
	print "<tr> <td><b>LevelForRobotsDetection</b></td> <td> <input type=text name=LevelForRobotsDetection value='$lconf->{'LevelForRobotsDetection'}'> </td> <td> ";
	print &hblink("Help", "help.cgi?param=LevelForRobotsDetection")." </td> </tr>\n";
	print "<tr> <td><b>LevelForBrowsersDetection</b></td> <td> <input type=text name=LevelForBrowsersDetection value='$lconf->{'LevelForBrowsersDetection'}'> </td> <td> ";
	print &hblink("Help", "help.cgi?param=LevelForBrowsersDetection")." </td> </tr>\n";
	print "<tr> <td><b>LevelForOSDetection</b></td> <td> <input type=text name=LevelForOSDetection value='$lconf->{'LevelForOSDetection'}'> </td> <td> ";
	print &hblink("Help", "help.cgi?param=LevelForOSDetection")." </td> </tr>\n";
	print "<tr> <td><b>LevelForRefererAnalyze</b></td> <td> <input type=text name=LevelForRefererAnalyze value='$lconf->{'LevelForRefererAnalyze'}'> </td> <td> ";
	print &hblink("Help", "help.cgi?param=LevelForRefererAnalyze")." </td> </tr>\n";
	
	print "<tr> <td colspan=3><br>OPTIONAL APPEARANCE SETUP SECTION (Not required but increase AWStats features)<br><hr></td> </tr>\n";
	print "<tr> <td colspan=3>Not available in this version of AWStats Webmin module</td> </tr>\n";

	print "<tr> <td colspan=3><br><hr></td> </tr>\n";
	print "<tr> <td colspan=3 align=center><a href='edit_config.cgi?".($in{'new'}?"new=1&":"")."file=$in{'file'}'>$text{'index_hideadvanced'}</a></td></tr>\n";
	print "<tr> <td colspan=3><hr></td> </tr>\n";
	print "</table>\n";

}

@b=();

if ($in{'new'}) {
	push(@b, "<input type=submit value='$text{'create'}'>");
	}
else {
	if ($access{'global'}) {
		push(@b, "<input type=submit value='$text{'save'}'>");
	}
	if ($access{'add'}) {
		push(@b, "<input type=submit name=delete value='$text{'delete'}'>");
	}
}

&spaced_buttons(@b);


print "</form>\n";

print "<hr>\n";
&footer("", $text{'index_return'});


#!/usr/bin/perl
# schedule_stats.cgi
# schedule AWStats update process from cron or logrotate

require './awstats-lib.pl';
&ReadParse();

if (! $access{'update'}) { &error($text{'schedule_cannot'}); }

my $conf=""; my $dir="";
if ($in{'file'} =~ /awstats\.(.*)\.conf$/) { $conf=$1; }
if ($in{'file'} =~ /^(.*)[\\\/][^\\\/]+$/) { $dir=$1; }


# Display file contents
&header($title || $text{'schedule_title'}, "");

print "<hr>\n";


print "Feature not yet available\n";
print "You must manually check if AWStats update process is";
print " in crontab";
print " or added into a logrotate preprocessor task<br>";
print "<br>\n";

# Read cron
&foreign_require("cron", "cron-lib.pl");
#@procs = &foreign_call("proc", "list_processes");
#&foreign_call("proc", "renice_proc", $pid, -10);

# Read logrotate
&foreign_require("logrotate", "logrotate-lib.pl");
#@procs = &foreign_call("proc", "list_processes");
#&foreign_call("proc", "renice_proc", $pid, -10);


# For global update
print "<table border width=100%>\n";
print "<tr $tb> <td colspan=2 align=left><b>";
print "Scheduled AWStats global update process (For all files in /etc/awstats)";
print "</b></td> </tr>\n";

print "<tr> <td valign=top><input name=GlobalUpdate type=radio value='none'> <b>None</b></td> <td> &nbsp; </td> </tr>\n";
print "<tr> <td valign=top><input name=GlobalUpdate type=radio value='yes'> <b>Yes</b></td> <td> ";

print "<table border=0 width=100%>\n";
# Show cron found
print "<tr> <td><input name=GlobalUpdate type=checkbox value='bycron'> <b>By cron</b></td> <td> Date: NA </td> <td> Remove this order </td> </tr>\n";
# Loop on each logrotate found
print "<tr> <td><input name=GlobalUpdate type=checkbox value='bylogrotate'> <b>By logrotate preprocess</b></td> <td> File: NA </td> <td> Remove this order </td> </tr>\n";
print "<tr> <td> Add a new global update order by cron </td> </tr>\n";
print "<tr> <td> Add a new global update order by a logrotate file </td> </tr>\n";
print "</table>";

print "</td> </tr>\n";
print "</table>";


print "<br>\n";


# For particular config file update
print "<table border width=100%>\n";
print "<tr $tb> <td colspan=2 align=left><b>";
print "Scheduled AWStats update process for this config file only (".$in{'file'}.")";
print "</b></td> </tr>\n";

print "<tr> <td valign=top><input name=GlobalUpdate type=radio value='none'> <b>None</b></td> <td> &nbsp; </td> </tr>\n";
print "<tr> <td valign=top><input name=GlobalUpdate type=radio value='yes'> <b>Yes</b></td> <td> ";

print "<table border=0 width=100%>\n";
# Show cron found
print "<tr> <td><input name=GlobalUpdate type=checkbox value='bycron'> <b>By cron</b></td> <td> Date: NA </td> <td> Remove this order </td> </tr>\n";
# Loop on each logrotate found
print "<tr> <td><input name=GlobalUpdate type=checkbox value='bylogrotate'> <b>By logrotate preprocess</b></td> <td> File: NA </td> <td> Remove this order </td> </tr>\n";
print "<tr> <td> Add a new global update order by cron </td> </tr>\n";
print "<tr> <td> Add a new global update order by a logrotate file </td> </tr>\n";
print "</table>";

print "</td> </tr>\n";
print "</table>";


print "<br>\n";


0;


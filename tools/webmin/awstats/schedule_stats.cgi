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

print "AWStats scheduled update processes detected for config file <b>".$in{'file'}."</b><br>\n";
print "<br>\n";
print "<br>\n";

# Load other modules lib
&foreign_require("cron", "cron-lib.pl");
&foreign_require("logrotate", "logrotate-lib.pl");

# For global update
print "Update processes scheduled by a <b>cron</b> task :<br>";
print "<table border width=100%>\n";
print "<tr $tb><td align=left>User</td>";
print "<td>Task</td><td align=center>Active</td><td>Note on task</td><td>Action</td></tr>\n";

my $globalupdate=0;
my $confupdate=0;
if ( foreign_installed('cron', 0) ) {
    # Show cron found
    my $regupdateall="awstats_updateall\.pl";
    my $regupdate="awstats\.pl";
    foreach my $j (grep { $_->{'command'} =~ /$regupdate/ || $_->{'command'} =~ /$regupdateall/ } &foreign_call("cron","list_cron_jobs")) {
        my $global=0;
        if ($j->{'command'} =~ /$regupdateall/) { $globalupdate++; $global=1; }
        my $confparam="";
        if ($j->{'command'} =~ /$regupdate/) {
            $j->{'command'} =~ /config=(\S+)/;
            $confparam=$1;
            if ($confparam ne $conf) { next; }
        }
        print "<tr>";
        print "<td><b>".$j->{'user'}."</b></td>";
        print "<td>".$j->{'command'}."</td>";
        print "<td align=center>".($j->{'active'}?'yes':'no')."</td>";
        if ($global) { print "<td>Update all config files</td>"; }
        else { print  "<td>Update this config file only</td>"; }
        print "<td><a href=\"/cron/edit_cron.cgi?idx=".$j->{'index'}."\">Jump to cron task</a></td>";
        print "</tr>";
    }
}
else {
    print "<tr><td colspan=4>Webmin cron module is not installed. It is required to setup cron scheduled tasks</td></tr>";
}
print "</table>";
print "<br>\n";
print "<a href=\"/cron/edit_cron.cgi?new=1\">Add an AWStats cron task to update all AWStats config files</a><br>";
print "(You must add the command \"/usr/local/awstats/tools/awstats_updateall.pl now >/dev/null\")<br>\n";
print "<br>\n";
print "<a href=\"/cron/edit_cron.cgi?new=1\">Add an AWStats cron task to update this config files</a><br>\n";
print "(You must add the command \"$config{'awstats'} -update -config=$conf >/dev/null\")<br>\n";
print "<br>\n";


print "<br>\n";
print "<br>\n";


# For logrotate scheduling
print "Update processes scheduled by a <b>logrotate</b> task :<br>";
print "<table border width=100%>\n";
print "<tr $tb><td>Logrotate file</td>";
print "<td>Task</td><td>Note on task</td><td>Action</td></tr>\n";

if ( foreign_installed('logrotate', 0) ) {


}
else {
    print "<tr><td colspan=4>Webmin logrotate module is not installed. It is required to setup logrotate scheduled tasks</td></tr>";
}
print "</table>";
print "Add a logrotate for this file";

print "<br>\n";


0;


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
print "<tr $tb> <td align=left><b>";
print "Scheduled AWStats global update process (For all files in /etc/awstats)";
print "</b></td> </tr>\n";

print "<tr> <td> ";

if ( foreign_installed('cron', 0) || foreign_installed('logrotate', 0) ) {
    print "<table border=0 width=100%>\n";
    # Show cron found
    if ( foreign_installed('cron', 0) ) {
        $idcron=0;
        @jobs = &foreign_call("cron","list_cron_jobs");

        #TODO detect idcron for /.*/awstats_updateall.pl in @jobs
        
        print "<tr> <td> <b>By cron</b></td> <td> ";
        if (! $idcron) {        
            print "Off\n";
        }
        else {
            print "On\n";
        }
        print " </td> <td> ";
        if (! $idcron) {        
            print "<a href=\"/cron/edit_cron.cgi?new=1\">Add AWStats global update process in cron</a>\n";
        } else {
            print "<a href=\"/cron/edit_cron.cgi?idx=$idcron\">Edit cron task to update all AWStats config files</a> ";
        }
        print "</td> </tr>\n";
    }
    # Loop on each logrotate found
    if ( foreign_installed('logrotate', 0) ) {
        print "<tr> <td> <b>By logrotate preprocess</b></td> ";

        print " <td> File: NA </td> ";
        print " <td> Edit logrotate file<br>";
        
        print "Add a logrotate for this file";
        
        print "</td></tr>";
    }
    print "</table>";
}
else {
    print "Nor cron, nor logrotate module are installed. They are required to setup AWStats scheduled tasks";
}

print "</td> </tr>\n";
print "</table>";


print "<br>\n";


# For particular config file update
print "<table border width=100%>\n";
print "<tr $tb> <td align=left><b>";
print "Scheduled AWStats update process for this config file only (".$in{'file'}.")";
print "</b></td> </tr>\n";

print "<tr> <td> ";

if ( foreign_installed('cron', 0) || foreign_installed('logrotate', 0) ) {
    print "<table border=0 width=100%>\n";
    # Show cron found
    if ( foreign_installed('cron', 0) ) {
        @jobs = &foreign_call("cron","list_cron_jobs");

        #TODO detect idcron for /.*/awstats_updateall.pl in @jobs
        
        print "<tr> <td> <b>By cron</b></td> <td> ";
        if (! $idcron) {        
            print "Off\n";
        }
        else {
            print "On\n";
        }
        print " </td> <td> ";
        if (! $idcron) {        
            print "<a href=\"/cron/edit_cron.cgi?new=1\">Add AWStats update process in cron for config file</a>\n";
        } else {
            print "<a href=\"/cron/edit_cron.cgi?idx=$idcron\">Edit cron task to update only this AWStats config files</a> ";
        }
        print "</td> </tr>\n";
    }
    # Loop on each logrotate found
    if ( foreign_installed('logrotate', 0) ) {
        print "<tr> <td> <b>By logrotate preprocess</b></td> ";
        print " <td> File: NA </td> ";
        print " <td> Edit logrotate file<br>";
        
        print "Add a logrotate for this file";
        
        print "</td></tr>";
   
    }
    print "</table>";
}
else {
    print "Nor cron, nor logrotate module are installed. They are required to setup AWStats scheduled tasks";
}

print "</td> </tr>\n";
print "</table>";


print "<br>\n";


0;


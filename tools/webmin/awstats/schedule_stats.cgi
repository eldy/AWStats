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
print " or added into a logrotate preprocessor task";

0;


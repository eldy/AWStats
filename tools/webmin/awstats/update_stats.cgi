#!/usr/bin/perl
# update_stats.cgi
# Run AWStats update process
# $Revision$ - $Author$ - $Date$

require './awstats-lib.pl';
&ReadParse();

if (! $access{'update'}) { &error($text{'update_ecannot'}); }

my $conf=""; my $dir="";
if ($in{'file'} =~ /awstats\.(.*)\.conf$/) { $conf=$1; }
if ($in{'file'} =~ /^(.*)[\\\/][^\\\/]+$/) { $dir=$1; }


# Display file contents
&header($title || $text{'update_title'}, "");
print "<hr>\n";

my $command=$config{'awstats'}." -update -config=$conf -configdir=$dir";
print $text{'update_run'}.":\n<br>\n";
print "$command<br>\n";
print $text{'update_wait'}."...<br>\n";
print "<br>\n";

&foreign_require("proc", "proc-lib.pl");
proc::safe_process_exec_logged($command,$config{'user'},undef, STDOUT,undef, 1, 1, 0);


#$retour=`$command 2>&1`;
#print "$retour\n";

print "<hr>\n";
print $text{'update_finished'}.".<br>\n";
print "<br>\n";


# Back to config list
&footer("", $text{'index_return'});

0;

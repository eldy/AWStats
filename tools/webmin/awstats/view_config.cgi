#!/usr/bin/perl
# view_log.cgi
# Display the report for some log file

require './awstats-lib.pl';
&ReadParse();

$escaped = $1;
$file = $2;
$config = &un_urlize($escaped);
$file =~ /\.\./ || $file =~ /\<|\>|\||\0/ && &error($text{'view_efile'});

if (! $access{'view'}) { &error($text{'view_ecannot'}); }


# Display file contents
&header($title || $text{'view_title'}, "");
print "<hr>\n";
my $command="$conf{'awstats'} -output -config=$file";
print "<hr>\n";


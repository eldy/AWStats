#!/usr/bin/perl
# help.cgi
# Show help for a config parameter

require './awstats-lib.pl';
&ReadParse();

# Display file contents
&header($title || $text{'help_title'}, "", undef, 0, 1, 1);
print "<hr>\n";

my $helpparam=$in{'param'};
my $isplugin=0;
if ($helpparam =~ s/^plugin_//) { $isplugin=1; }

if ($isplugin) { print &text('help_subtitleplugin',$helpparam)."<br><br>\n"; }
else { print &text('help_subtitle',$helpparam)."<br><br>\n"; }

open(CONF, $config{'alt_conf'}) || &error("Failed to open sample config file");
my $output="";
my $savoutput="";
my $found=0;
while(<CONF>) {
	chomp $_; s/\r//;

	my $line="$_";

	if ($line !~ /#LoadPlugin/i && $line =~ s/^#//) {
		if ($line =~ /-----------------/) { 
			if ($output) { $savoutput=$output; }
			$output="";
			next;
		}
		$line =~ s/</&lt;/g;
		$line =~ s/>/&gt;/g;
		$output.="$line<br>";
	}
	else {
		# Remove comments
		$_ =~ s/\s#.*$//;
		# Extract param and value
		my ($param,$value)=split(/=/,$_,2);
		$param =~ s/^\s+//; $param =~ s/\s+$//;
		
		if (defined($param) && defined($value)) {
			if ((! $isplugin && $param =~ /$helpparam/i) ||
			     ($isplugin && $value =~ /$helpparam/i)) {
				$found=1; last;
			}
			else {
				if ($output) { $savoutput=$output; }
				$output="";
			}
		}
	}
}
close(CONF);

if ($found) {
	if ($output) { print "$output\n"; }
	else { print "$savoutput"; }
}
else {
	print &text('help_notfound',$config{'alt_conf'});
#	print "Parameter not found in your sample file $config{'alt_conf'}.\nMay be your AWStats version does not support it, so no help is available.";
}
	
0;

#!/usr/bin/perl
# help.cgi
# Show help for a config parameter

require './awstats-lib.pl';
&ReadParse();

# Display file contents
&header($title || $text{'help_title'}, "");
print "<hr>\n";

my $helpparam=$in{'param'};

print "<b>Help for config file parameter $helpparam :</b><br><br>\n";

open(CONF, $config{'alt_conf'}) || &error("eee");
my $output="";
my $savoutput="";
while(<CONF>) {
        chomp $_; s/\r//;

	my $line="$_";	

	if ($line =~ s/^#//) {
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
 			if ($param =~ /$helpparam/i) { last; }
			else {
				if ($output) { $savoutput=$output; }
				$output="";
			}
	        }

	}
}
close(CONF);

if ($output) { print "$output\n"; }
else { print "$savoutput"; }



#!/usr/bin/perl
#-------------------------------------------------------
# Convert a mail log file to a common log file for analyzing with any log
# analyzer.
#-------------------------------------------------------
# Tool built from original work of Odd-Jarle Kristoffersen
# Note 1: QMail must log in syslog format for timestamps to work.
# Note 2: Qmail logging is not 100% accurate. Some messages might
# not be logged correctly or completely.
#-------------------------------------------------------
use strict;no strict "refs";


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
my $REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
my $VERSION="1.0 (build $REVISION)";

use vars qw/
$DIR $PROG $Extension
%entry $help
$mode $year $Debug
/;



#-------------------------------------------------------
# Functions
#-------------------------------------------------------

sub error {
	print "Error: $_[0].\n";
    exit 1;
}

sub debug {
	my $level = $_[1] || 1;
	if ($Debug >= $level) { 
		my $debugstring = $_[0];
		if ($ENV{"GATEWAY_INTERFACE"}) { $debugstring =~ s/^ /&nbsp&nbsp /; $debugstring .= "<br>"; }
		print "DEBUG $level - ".time." : $debugstring\n";
		}
	0;
}

sub CleanVadminUser { $_=shift;
	s/[#<|>\[\]]//g;	# Remove unwanted characters first
	s/^(.*?)-//gi;		# Strip off unixuser- at beginning
	return $_;
}

sub CleanEmail { $_=shift;
	s/[#<|>\[\]]//g;	# Remove unwanted characters first
	return $_;
}

# Clean host addresses
# Input:  servername[123.123.123.123]
# Return: servername or 123.123.123.123 if servername is 'unknown'
sub CleanHost { $_=shift;
	if (/^unknown\[/) { $_ =~ /\[(.*)\]/; $_=$1; }
	else { $_ =~ s/\[.*$//; }
	return $_;
}

# Return domain
# Input:	host.domain.com, <user@domain.com>, <>
#
sub CleanDomain { $_=shift;
	s/>.*$//; s/[<>]//g;
	s/^.*@//; 
	if (! $_) { $_ = 'localhost'; }
	return $_;
}

sub OutputRecord {
	my $id=shift;

	# Clean day and month
	$entry{$id}{'day'}=sprintf("%02d",$entry{$id}{'day'});
	if ($entry{$id}{mon} eq 'Jan') { $entry{$id}{mon} = "01"; }
	if ($entry{$id}{mon} eq 'Feb') { $entry{$id}{mon} = "02"; }
	if ($entry{$id}{mon} eq 'Mar') { $entry{$id}{mon} = "03"; }
	if ($entry{$id}{mon} eq 'Apr') { $entry{$id}{mon} = "04"; }
	if ($entry{$id}{mon} eq 'May') { $entry{$id}{mon} = "05"; }
	if ($entry{$id}{mon} eq 'Jun') { $entry{$id}{mon} = "06"; }
	if ($entry{$id}{mon} eq 'Jul') { $entry{$id}{mon} = "07"; }
	if ($entry{$id}{mon} eq 'Aug') { $entry{$id}{mon} = "08"; }
	if ($entry{$id}{mon} eq 'Sep') { $entry{$id}{mon} = "09"; }
	if ($entry{$id}{mon} eq 'Oct') { $entry{$id}{mon} = "10"; }
	if ($entry{$id}{mon} eq 'Nov') { $entry{$id}{mon} = "11"; }
	if ($entry{$id}{mon} eq 'Dec') { $entry{$id}{mon} = "12"; }

	# Clean relay_s
	$entry{$id}{'relay_s'}=&CleanHost($entry{$id}{'relay_s'});
	$entry{$id}{'relay_s'}||=&CleanDomain($entry{$id}{'from'});
	$entry{$id}{'relay_s'}=~s/\.$//;
	if ($entry{$id}{'relay_s'} eq 'local' || $entry{$id}{'relay_s'} eq 'localhost.localdomain') { $entry{$id}{'relay_s'}='localhost'; }

	# Clean relay_r
	$entry{$id}{'relay_r'}=&CleanHost($entry{$id}{'relay_r'});
	$entry{$id}{'relay_r'}||="-";
	$entry{$id}{'relay_r'}=~s/\.$//;
	if ($entry{$id}{'relay_r'} eq 'local' || $entry{$id}{'relay_r'} eq 'localhost.localdomain') { $entry{$id}{'relay_r'}='localhost'; }

	# Clean from
	$entry{$id}{'from'}=&CleanEmail($entry{$id}{'from'});
	$entry{$id}{'from'}||='<>';
	
	# Clean to
	if ($mode eq 'vadmin') { $entry{$id}{'to'}=&CleanVadminUser($entry{$id}{'to'}); }
	else { $entry{$id}{'to'}=&CleanEmail($entry{$id}{'to'}); }

	# Write line
	print "$year-$entry{$id}{mon}-$entry{$id}{day} $entry{$id}{time} $entry{$id}{from} $entry{$id}{to} $entry{$id}{relay_s} $entry{$id}{relay_r} SMTP - $entry{$id}{code} ".($entry{$id}{size}||0)."\n";
	undef $entry{$id};
}



#-------------------------------------------------------
# MAIN
#-------------------------------------------------------
$mode=lc(shift);
$year=shift;
if ($mode ne 'standard' and $mode ne 'vadmin') { $help = 1; }

($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

my $starttime=time();
my ($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday,$nowyday) = localtime($starttime);
$year||=($nowyear+1900);

# Show usage help
if ($help) {
	print "----- $PROG $VERSION -----\n";
	print <<HELPTEXT;
Usage:

perl maillogconvert.pl [standard|vadmin] [year] < logfile > output

The first parameter specifies what format the mail logfile is :
  standard - logfile is standard sendmail,postfix or qmail log format
  vadmin - logfile is qmail with vadmin multi-host support

The second parameter specifies what year to timestamp logfile with,
 if current year is not the correct one. (ie. 2002). Always use 4 digits.
 If not specified, current year is used.

If no output is specified, it goes to the console (stdout).

HELPTEXT
	sleep 1;
	exit;
}

#
# Start Processing Input Logfile
#
while (<>) {
	my $rowid=0;

	#
	# Get sender host for postfix
	#
	if (/: client=/ ne undef) {
		my ($id,$relay_s)=m/\w+\s+\d+\s+\d+:\d+:\d+\s+\w+\s+(?:sendmail|postfix\/smtpd|postfix\/smtp)\[\d+\]:\s+(.*?):\s+client=(.*)/;
		$rowid=$id;
		$entry{$id}{'relay_s'}=$relay_s;
#		print "Found host sender on a 'client' line: $entry{$id}{'relay_s'}\n";
	}

	#
	# See if we received sendmail or postfix email reject error
	#
	elsif (/: reject/ ne undef) {
		# TODO Trap SMTP erros
		my ($mon,$day,$time,$id,$code,$from,$to)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+\w+\s+(?:sendmail|postfix\/smtpd|postfix\/smtp)\[\d+\]:\s+(.*?):\s+(.*)\s+from=([^\s,]*)\s+to=([^\s,]*)\s/;
		$rowid=$id;
		# $code='reject: RCPT from c66.191.66.89.dul.mn.charter.com[66.191.66.89]: 450 <partenaires@chiensderace.com>: User unknown in local recipient table;'
		if ($code =~ /\s+(\d\d\d)\s+/) { $entry{$id}{'code'}=$1; }
		else { $entry{$id}{'code'}=999; }	# Unkown error
		$entry{$id}{'from'}=$from;
		$entry{$id}{'to'}=$to;
		$entry{$id}{'mon'}=$mon;
		$entry{$id}{'day'}=$day;
		$entry{$id}{'time'}=$time;
#		print "Found an error incoming message: id=$id code=$entry{$id}{'code'} from=$entry{$id}{'from'} to=$entry{$id}{'to'}\n";
	}

	#
	# See if we received sendmail, postfix or qmail email
	#
	elsif ((/info msg .* from/ ne undef) || (/: from=/ ne undef)) {
		if (/info msg .* from/ ne undef) {
			#
			# Matched incoming qmail message
			#
			my ($id,$size,$from)=m/info msg (\d+): bytes (\d+) from <(.*)>/;
			$rowid=$id;
			$entry{$id}{'code'}=1;
			$entry{$id}{'from'}=$from;
			$entry{$id}{'size'}=$size;
			if (m/\s+relay=([^\s,]*)[\s,]/) { $entry{$id}{'relay_s'}=$1; }
#			print "Found an incoming message: id=$id from=$entry{$id}{'from'} size=$entry{$id}{'size'} relay_s=$entry{$id}{'relay_s'}\n";
		}
		elsif (/: from=/ ne undef) {
			#
			# Matched incoming sendmail or postfix message
			#
			my ($id,$from,$size)=m/\w+\s+\d+\s+\d+:\d+:\d+\s+\w+\s+(?:sendmail|postfix\/qmgr|postfix\/nqmgr)\[\d+\]:\s+(.*?):\s+from=(.*?),\s+size=(.*?),/;
			$rowid=$id;
			$entry{$id}{'code'}=1;
			$entry{$id}{'from'}=$from;
			$entry{$id}{'size'}=$size;
			if (m/\s+relay=([^\s,]*)[\s,]/) { $entry{$id}{'relay_s'}=$1; }
#			print "Found an incoming message: id=$id from=$entry{$id}{'from'} size=$entry{$id}{'size'} relay_s=$entry{$id}{'relay_s'}\n";
		}
	}

	#
	# Analyzed the to
	#
	elsif ((/: to=.*stat(us)?=sent/i ne undef) || (/starting delivery/ ne undef)) {
		if (/: to=.*stat(us)?=sent/i ne undef) {
			#
			# Matched outgoing sendmail message
			#
			my ($mon,$day,$time,$id,$to)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+\w+\s+(?:sendmail|postfix\/(?:local|smtpd|smtp))\[.*?\]:\s+(.*?):\s+to=(.*?),/;
			$rowid=$id;
			if (m/\s+relay=([^\s,]*)[\s,]/) { $entry{$id}{'relay_r'}=$1; }
			elsif (m/\s+mailer=local/) { $entry{$id}{'relay_r'}='localhost'; }
			$entry{$id}{'mon'}=$mon;
			$entry{$id}{'day'}=$day;
			$entry{$id}{'time'}=$time;
			$entry{$id}{'to'}=$to;
#			print "Found a record: id=$id mon=$entry{$id}{'mon'} day=$entry{$id}{'day'} time=$entry{$id}{'time'} to=$entry{$id}{'to'} relay_r=$entry{$id}{'relay_r'}\n";
		}
		elsif (/starting delivery/ ne undef) {
			#
			# Matched outgoing qmail message
			#
			my ($mon,$day,$time,$id,$to)=m/^(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+.*\s+msg\s+(\d+)\s+to\s+.*?\s+(.*)$/;
			$rowid=$id;
			if (m/\s+relay=([^\s,]*)[\s,]/) { $entry{$id}{'relay_r'}=$1; }
			elsif (m/\s+mailer=local/) { $entry{$id}{'relay_r'}='localhost'; }
			$entry{$id}{'mon'}=$mon;
			$entry{$id}{'day'}=$day;
			$entry{$id}{'time'}=$time;
			$entry{$id}{'to'}=$to;
		}
	}

	#
	# Write record if full
	#
	if ($rowid && $entry{$rowid}{'from'} && $entry{$rowid}{'to'}) { &OutputRecord($rowid) }

}

0;


# SMTP Postfix errors:
# 450 User unknown
# 554 Relay denied
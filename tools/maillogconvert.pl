#!/usr/bin/perl
#-------------------------------------------------------
# Convert a mail log file to a common log file for analyzing with any log
# analyzer.
#-------------------------------------------------------
# Tool built from original work of Odd-Jarle Kristoffersen
# Note 1: QMail must log in syslog format for timestamps to work.
# Note 2: QMail logging is not 100% accurate. Some messages might
# not be logged correctly or completely.
#
# A mail received to 2 different receivers, report 2 records instead of one.
# A mail received to a forwarded account is reported as to the original receiver, not the "forwarded to".
# A mail locally sent to a local alias is reported as n mails to all addresses of alias.
#-------------------------------------------------------
use strict;no strict "refs";


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
use vars qw/ $REVISION $VERSION /;
$REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
$VERSION="1.1 (build $REVISION)";

use vars qw/
$DIR $PROG $Extension
$Debug
%entry $help
$mode $year $Debug
$NBOFLINESFORFLUSH
/;

$NBOFLINESFORFLUSH=8192;		# Nb or records for flush of %entry (Must be a power of 2)


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
		print "DEBUG $level - $. - ".time." : $debugstring\n";
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
# Input:  "servername[123.123.123.123]", "servername [123.123.123.123]"
#         "root@servername", "[123.123.123.123]"
# Return: servername or 123.123.123.123 if servername is 'unknown'
sub CleanHost {
	$_=shift;
	if (/^\[(.*)\]$/) { $_=$1; }						# If [ip] we keep ip
	if (/^unknown\s*\[/) { $_ =~ /\[(.*)\]/; $_=$1; }	# If unknown [ip], we keep ip
	else { $_ =~ s/\s*\[.*$//; }
	$_ =~ s/^.*\@//;									# If x@y, we keep y
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

# Return string without starting and ending space
#
sub trim { $_=shift;
	s/^\s+//; s/\s+$//;
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

	# Clean from
	$entry{$id}{'from'}=&CleanEmail($entry{$id}{'from'});
	$entry{$id}{'from'}||='<>';
	
	# Clean to
	if ($mode eq 'vadmin') { $entry{$id}{'to'}=&CleanVadminUser($entry{$id}{'to'}); }
	else { $entry{$id}{'to'}=&CleanEmail($entry{$id}{'to'}); }
	$entry{$id}{'to'}||='<>';

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
	#if we don't have info for relay_s, we keep it unknown, awstats might then guess it
	
	# Write line
	print "$year-$entry{$id}{mon}-$entry{$id}{day} $entry{$id}{time} $entry{$id}{from} $entry{$id}{to} $entry{$id}{relay_s} $entry{$id}{relay_r} SMTP - $entry{$id}{code} ".($entry{$id}{size}||0)."\n";
	
	# If there was a redirect
	if ($entry{$id}{'frowardto'}) {
		# Redirect to local address
		# TODO
		# Redirect to external address
		# TODO
	}
}



#-------------------------------------------------------
# MAIN
#-------------------------------------------------------

# Prepare QueryString
my %param=();
for (0..@ARGV-1) { $param{$_}=$ARGV[$_]; }
foreach my $key (sort keys %param) {
	if ($param{$key} =~ /(^|-|&)debug=([^&]+)/i) { $Debug=$2; shift; next; }
	if ($param{$key} =~ /^(\d+)$/) { $year=$1; shift; next; }
	if ($param{$key} =~ /^(standard|vadmin)$/i) { $mode=$1; shift; next; }
}
if ($mode ne 'standard' and $mode ne 'vadmin') { $help = 1; }

($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

my $starttime=time();
my ($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday,$nowyday) = localtime($starttime);
$year||=($nowyear+1900);

# Show usage help
if ($help) {
	print "----- $PROG $VERSION -----\n";
	print <<HELPTEXT;
$PROG is mail log preprocessor that convert a mail log file (from
postfix, sendmail or qmail servers) into a human readable format.
The output format is also ready to be used by a log analyzer, like AWStats.

Usage:
  perl maillogconvert.pl [standard|vadmin] [year] < logfile > output

The first parameter specifies what format the mail logfile is :
  standard - logfile is standard postfix,sendmail or qmail log format
  vadmin   - logfile is qmail log format with vadmin multi-host support

The second parameter specifies what year to timestamp logfile with, if current
year is not the correct one (ie. 2002). Always use 4 digits. If not specified,
current year is used.

If no output is specified, it goes to the console (stdout).

HELPTEXT
	sleep 1;
	exit;
}

#
# Start Processing Input Logfile
#
$NBOFLINESFORFLUSH--;
my $numrecord=0;
while (<>) {
	chomp $_; s/\r//;
	$numrecord++;
	
	my $rowid=0;

	#
	# Get sender host for postfix
	#
	if (/: client=/ ne undef) {
		my ($id,$relay_s)=m/\w+\s+\d+\s+\d+:\d+:\d+\s+[\w\-]+\s+(?:sendmail|postfix\/smtpd|postfix\/smtp)\[\d+\]:\s+(.*?):\s+client=(.*)/;
		$rowid=$id;
		$entry{$id}{'relay_s'}=$relay_s;
		debug("For id=$id, found host sender on a 'client' line: $entry{$id}{'relay_s'}");
	}

	#
	# See if we received postfix email reject error
	#
	elsif (/: reject/ ne undef) {
		# Example: 
		# postfix:  Jan 01 04:19:04 apollon postfix/smtpd[26553]: 1954F3B8A4: reject: RCPT from unknown[80.245.33.2]: 450 <partenaires@chiensderace.com>: User unknown in local recipient table; from=<httpd@fozzy2.dpi-europe.fr> to=<partenaires@chiensderace.com> proto=ESMTP helo=<fozzy2.dpi-europe.fr>
		# postfix:  Jan 01 04:26:39 halley postfix/smtpd[9245]: reject: RCPT from unknown[203.156.32.33]: 554 <charitha99@yahoo.com>: Recipient address rejected: Relay access denied; from=<1126448365@aol.com> to=<charitha99@yahoo.com>
		my ($mon,$day,$time,$id,$code,$from,$to)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-]+\s+(?:postfix\/smtpd|postfix\/smtp)\[\d+\]:\s+(.*?):\s+(.*)\s+from=([^\s,]*)\s+to=([^\s,]*)/;
		$rowid=($id eq 'reject'?999:$id);	# id not provided in log, we take 999
		# $code='reject: RCPT from c66.191.66.89.dul.mn.charter.com[66.191.66.89]: 450 <partenaires@chiensderace.com>: User unknown in local recipient table;'
		#    or 'reject: RCPT from unknown[203.156.32.33]: 554 <charitha99@yahoo.com>: Recipient address rejected: Relay access denied;'
		if ($rowid) {
			if ($code =~ /\s+(\d\d\d)\s+/) { $entry{$rowid}{'code'}=$1; }
			else { $entry{$rowid}{'code'}=999; }	# Unkown error
			if (! $entry{$rowid}{'relay_s'} &&  $code =~ /from\s+([^\s]+)\s+/) {
				$entry{$rowid}{'relay_s'}=&trim($1);
			}
			$entry{$rowid}{'from'}=&trim($from);
			$entry{$rowid}{'to'}=&trim($to);
			$entry{$rowid}{'mon'}=$mon;
			$entry{$rowid}{'day'}=$day;
			$entry{$rowid}{'time'}=$time;
			debug("For id=$rowid, found a postfix error incoming message: code=$entry{$rowid}{'code'} from=$entry{$rowid}{'from'} to=$entry{$rowid}{'to'}");
		}
	}
	#
	# See if we received sendmail reject error
	#
	elsif (/, reject/ ne undef) {
		# Example: 
		# sm-mta:   Jul 27 04:06:05 androneda sm-mta[6641]: h6RB44tg006641: ruleset=check_mail, arg1=<7ms93d4ms@topprodsource.com>, relay=crelay1.easydns.com [216.220.57.222], reject=451 4.1.8 Domain of sender address 7ms93d4ms@topprodsource.com does not resolve
		# sm-mta:	Jul 27 06:21:24 androneda sm-mta[11461]: h6RDLNtg011461: ruleset=check_rcpt, arg1=<nobody@nova.dice.net>, relay=freedom.myhostdns.com [66.246.77.42], reject=550 5.7.1 <nobody@nova.dice.net>... Relaying denied
		# sendmail: Sep 30 04:21:32 halley sendmail[3161]: g8U2LVi03161: ruleset=check_rcpt, arg1=<amber3624@netzero.net>, relay=moon.partenor.fr [10.0.0.254], reject=550 5.7.1 <amber3624@netzero.net>... Relaying denied
		my ($mon,$day,$time,$id,$ruleset,$arg,$relay_s,$code)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-]+\s+(?:sendmail|sm-mta)\[\d+\]:\s+(.*?):\sruleset=(\w+),\s+arg1=(.*),\s+relay=(.*),\s+(reject=.*)/;
		$rowid=$id;
		if ($rowid) {
			if ($ruleset eq 'check_mail') { $entry{$id}{'from'}=$arg; }
			if ($ruleset eq 'check_rcpt') { $entry{$id}{'to'}=$arg; }
			$entry{$id}{'relay_s'}=$relay_s;
			# $code='reject=550 5.7.1 <amber3624@netzero.net>... Relaying denied'
			if ($code =~ /=(\d\d\d)\s+/) { $entry{$id}{'code'}=$1; }
			else { $entry{$id}{'code'}=999; }	# Unkown error
			$entry{$id}{'mon'}=$mon;
			$entry{$id}{'day'}=$day;
			$entry{$id}{'time'}=$time;
			debug("For id=$id, found a sendmail error incoming message: code=$entry{$id}{'code'} from=$entry{$id}{'from'} to=$entry{$id}{'to'} relay_s=$entry{$id}{'relay_s'}");
		}
	}
	#
	# See if we received postfix email bounced error
	#
	elsif (/stat(us)?=bounced/ ne undef) {
		# Example: 
		# postfix:  Sep  9 18:24:23 halley postfix/local[22003]: 12C6413EC9: to=<etavidian@partenor.com>, relay=local, delay=0, status=bounced (unknown user: "etavidian")
		my ($mon,$day,$time,$id,$to,$relay_r)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-]+\s+(?:postfix\/(?:local|smtpd|smtp))\[\d+\]:\s+(.*?):\s+to=([^\s,]*)[\s,]+relay=([^\s,]*)/;
		$rowid=($id eq 'reject'?999:$id);	# id not provided in log, we take 999
		if ($rowid) {
			$entry{$rowid}{'code'}="999";	# Unkown error (bounced)
			$entry{$rowid}{'to'}=&trim($to);
			$entry{$rowid}{'relay_r'}=&trim($relay_r);
			$entry{$rowid}{'mon'}=$mon;
			$entry{$rowid}{'day'}=$day;
			$entry{$rowid}{'time'}=$time;
			debug("For id=$rowid, found a postfix bounced incoming message: code=$entry{$rowid}{'code'} to=$entry{$rowid}{'to'} relay_r=$entry{$rowid}{'relay_r'}");
		}
	}

	#
 	# See if we send a sendmail (with ctladdr tag) email
 	#
 	elsif(/, ctladdr=/ ne undef) {
 			#
 			# Matched outgoing sendmail/postfix message
 			#
 			my ($mon,$day,$time,$id,$to,$from)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-]+\s+(?:sm-mta|sendmail(?:-out|)|postfix\/(?:local|smtpd|smtp))\[.*?\]:\s+([^:]*):\s+to=(.*?)[,\s]+ctladdr=([^\,\s]*)/;
 			$rowid=$id;
 			if (m/\s+relay=([^\s,]*)[\s,]/) { $entry{$id}{'relay_r'}=$1; }
 			elsif (m/\s+mailer=local/) { $entry{$id}{'relay_r'}='localhost'; }
 			if (/, stat\=Sent/) { $entry{$id}{'code'}=1; }
 			elsif (/, stat\=User\s+unknown/) { $entry{$id}{'code'}=550; }
 			elsif (/, stat\=Local\s+configuration/) { $entry{$id}{'code'}=451; }
 			elsif (/, stat\=Deferred:\s+(\d*)/) { $entry{$id}{'code'}=$1; }
 			else { $entry{$id}{'code'}=999; }
 			$entry{$id}{'mon'}=$mon;
 			$entry{$id}{'day'}=$day;
 			$entry{$id}{'time'}=$time;
 			$entry{$id}{'to'}=&trim($to);
 			$entry{$id}{'from'}=&trim($from);
 			$entry{$id}{'size'}='?';
 			debug("For id=$id, found a sendmail outgoing message: to=$entry{$id}{'to'} from=$entry{$id}{'from'} size=$entry{$id}{'size'} relay_s=$entry{$id}{'relay_s'}");
 	}

	#
	# Matched incoming qmail message
	#
	elsif (/info msg .* from/ ne undef) {
		my ($id,$size,$from)=m/(\d+)(?:\.\d+)? info msg \d+: bytes (\d+) from <(.*)>/;
		$rowid=$id;
		if (! $entry{$id}{'code'}) { $entry{$id}{'code'}=1; }	# If not already defined, we define it
		if ($entry{$id}{'from'} ne '<>') { $entry{$id}{'from'}=$from; }
		$entry{$id}{'size'}=$size;
		if (m/\s+relay=([^\,]+)[\s\,]/ || m/\s+relay=([^\s\,]+)$/) { $entry{$id}{'relay_s'}=$1; }
		debug("For id=$id, found a qmail incoming message: from=$entry{$id}{'from'} size=$entry{$id}{'size'} relay_s=$entry{$id}{'relay_s'}");
	}

	#
	# Matched incoming sendmail or postfix message
	#
	elsif (/: from=/ ne undef) {
		# sm-mta:  Jul 28 06:55:13 androneda sm-mta[28877]: h6SDtCtg028877: from=<4cmkh79eob@webtv.net>, size=2556, class=0, nrcpts=1, msgid=<w1$kqj-9-o2m45@0h2i38.4.m0.5u>, proto=ESMTP, daemon=MTA, relay=smtp.easydns.com [205.210.42.50]
		# postfix: Jul  3 15:32:26 apollon postfix/qmgr[13860]: 08FB63B8A4: from=<nobody@ns3744.ovh.net>, size=3302, nrcpt=1 (queue active)
		my ($id,$from,$size)=m/\w+\s+\d+\s+\d+:\d+:\d+\s+[\w\-]+\s+(?:sm-mta|sendmail(?:-in|)|postfix\/qmgr|postfix\/nqmgr)\[\d+\]:\s+(.*?):\s+from=(.*?),\s+size=(.*?),/;
		$rowid=$id;
		if (! $entry{$id}{'code'}) { $entry{$id}{'code'}=1; }	# If not already defined, we define it
		if ($entry{$id}{'from'} ne '<>') { $entry{$id}{'from'}=$from; }
		$entry{$id}{'size'}=$size;
		if (m/\s+relay=([^\,]+)[\s\,]/ || m/\s+relay=([^\s\,]+)$/) { $entry{$id}{'relay_s'}=$1; }
		debug("For id=$id, found a sendmail/postfix incoming message: from=$entry{$id}{'from'} size=$entry{$id}{'size'} relay_s=$entry{$id}{'relay_s'}");
	}

	#
	# Matched sendmail/postfix "to" message
	#
	elsif (/: to=.*stat(us)?=sent/i ne undef) {
		my ($mon,$day,$time,$id,$to)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-]+\s+(?:sm-mta|sendmail(?:-out|)|postfix\/(?:local|smtpd|smtp))\[.*?\]:\s+(.*?):\s+to=(.*?),/;
		$rowid=$id;
		if (m/\s+relay=([^\s,]*)[\s,]/) { $entry{$id}{'relay_r'}=$1; }
		elsif (m/\s+mailer=local/) { $entry{$id}{'relay_r'}='localhost'; }
		if (m/forwarded as/) {
			# If 'forwarded as idnewmail' is found, we discard this mail to avoid counting it twice
			debug("For id=$id, mail was forwarded to other id, we discard it");
			undef $entry{$id};
		}
		else {
			if (m/\s+orig_to=([^\s,]*)[\s,]/) {
				# If we have a orig_to, we used it as receiver
				$entry{$id}{'to'}=&trim($1);
				$entry{$id}{'forwardedto'}=&trim($to);
			}
			else {
				$entry{$id}{'to'}=&trim($to);
			}
			$entry{$id}{'mon'}=$mon;
			$entry{$id}{'day'}=$day;
			$entry{$id}{'time'}=$time;
			debug("For id=$id, found a sendmail/postfix record: mon=$entry{$id}{'mon'} day=$entry{$id}{'day'} time=$entry{$id}{'time'} to=$entry{$id}{'to'} relay_r=$entry{$id}{'relay_r'}");
		}
	}

	#
	# Matched qmail "to" message
	#
	elsif (/starting delivery/ ne undef) {
		my ($mon,$day,$time,$id,$to)=m/^(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+.*\s+(\d+)(?:\.\d+)?\s+starting delivery \d+:\s+msg\s+\d+\s+to\s+.*?\s+(.*)$/;
		$rowid=$id;
		if (m/\s+relay=([^\s,]*)[\s,]/) { $entry{$id}{'relay_r'}=$1; }
		elsif (m/\s+mailer=local/) { $entry{$id}{'relay_r'}='localhost'; }
		$entry{$id}{'mon'}=$mon;
		$entry{$id}{'day'}=$day;
		$entry{$id}{'time'}=$time;
		$entry{$id}{'to'}=&trim($to);
		debug("For id=$id, found a qmail record: mon=$entry{$id}{'mon'} day=$entry{$id}{'day'} time=$entry{$id}{'time'} to=$entry{$id}{'to'} relay_r=$entry{$id}{'relay_r'}");
	}

	#
	# Write record if full
	#
	if ($rowid) {
		debug("ID:$rowid RELAY_S:$entry{$rowid}{'relay_s'} RELAY_R:$entry{$rowid}{'relay_r'} FROM:$entry{$rowid}{'from'} TO:$entry{$rowid}{'to'} CODE:$entry{$rowid}{'code'}");
		if (
		   ($entry{$rowid}{'from'} && $entry{$rowid}{'to'})
		|| ($entry{$rowid}{'from'} && $entry{$rowid}{'code'} > 1)
		) {
			&OutputRecord($rowid);
			# Delete generic unknown record
			if ($rowid == 999) {
				undef $entry{999};
			}
		}
	}
	else {
		debug("Not interesting row");
	}


	if ((++$numrecord & $NBOFLINESFORFLUSH) == 0) {
		# We clean $entry
		debug("We reach $numrecord records, so we flush entry hash array");
		foreach my $id (keys %entry) {
			debug(" Delete entry for id=$id",3);
			undef $entry{$id};
		}
	}

}

0;


# SMTP Postfix errors:
# 450 Sender or domain address not qualified (or Unkown recipient user with incomplete postfix setup)
# 451 Domain of sender address
# 550 Relaying denied or Unkown recipient user
# 554 Relay denied

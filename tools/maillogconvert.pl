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
# A mail received to 2 different receivers, report 2 records.
# A mail received to a forwarded account is reported as to the original receiver, not the "forwarded to".
# A mail locally sent to a local alias is reported as n mails to all addresses of alias.
#-------------------------------------------------------
use strict;no strict "refs";


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
use vars qw/ $REVISION $VERSION /;
$REVISION = '20140126';
$VERSION="1.2 (build $REVISION)";

use vars qw/
$DIR $PROG $Extension
$Debug
%mail %qmaildelivery
$help
$mode $year $lastmon $Debug
$NBOFENTRYFOFLUSH
$MailType
%MonthNum
/;
$Debug=0;
$NBOFENTRYFOFLUSH=16384;	# Nb or records for flush of %entry (Must be a power of 2)
$MailType='';				# Mail server family (postfix, sendmail, qmail)
%MonthNum = (
'Jan'=>1,
'Feb'=>2,
'Mar'=>3,
'Apr'=>4,
'May'=>5,
'Jun'=>6,
'Jul'=>7,
'Aug'=>8,
'Sep'=>9,
'Oct'=>10,
'Nov'=>11,
'Dec'=>12
);


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
		if ($ENV{"GATEWAY_INTERFACE"}) { $debugstring =~ s/^ /&nbsp&nbsp /; $debugstring .= "<br />"; }
		print localtime(time)." - DEBUG $level - $. - : $debugstring\n";
		}
	0;
}

sub CleanVadminUser { $_=shift||'';
	s/[#<|>\[\]]//g;	# Remove unwanted characters first
	s/^(.*?)-//gi;		# Strip off unixuser- at beginning
	return $_;
}

sub CleanEmail { $_=shift||'';
	s/[#<|>\[\]]//g;	# Remove unwanted characters first
	return $_;
}

# Clean host addresses
# Input:  "servername[123.123.123.123]", "servername [123.123.123.123]"
#         "root@servername", "[123.123.123.123]"
# Return: servername or 123.123.123.123 if servername is 'unknown'
sub CleanHost {
	$_=shift||'';
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

# Write a record
#
sub OutputRecord {
	my $year=shift;
	my $month=shift;    # Jan,Feb,... or 1,2,3...
	my $day=shift;
	my $time=shift;
	my $from=shift;
	my $to=shift;
	my $relay_s=shift;
	my $relay_r=shift;
	my $code=shift;
	my $size=shift||0;
	my $forwardto=shift;
	my $extinfo=shift||'-';

	# Clean day and month
	$day=sprintf("%02d",$day);
    $month=sprintf("%02d",$MonthNum{$month}||$month);

	# Clean from
	$from=&CleanEmail($from);
	$from||='<>';
	
	# Clean to
	if ($mode eq 'vadmin') { $to=&CleanVadminUser($to); }
	else { $to=&CleanEmail($to); }
	$to||='<>';

	# Clean relay_s
	$relay_s=&CleanHost($relay_s);
	$relay_s||=&CleanDomain($from);
	$relay_s=~s/\.$//;
	if ($relay_s eq 'local' || $relay_s eq 'localhost.localdomain') { $relay_s='localhost'; }

	# Clean relay_r
	$relay_r=&CleanHost($relay_r);
	$relay_r||="-";
	$relay_r=~s/\.$//;
	if ($relay_r eq 'local' || $relay_r eq 'localhost.localdomain') { $relay_r='localhost'; }
	#if we don't have info for relay_s, we keep it unknown, awstats might then guess it
	
	# Write line
	print "$year-$month-$day $time $from $to $relay_s $relay_r SMTP $extinfo $code $size\n";
	
	# If there was a redirect
	if ($forwardto) {
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
  standard - logfile is standard postfix,sendmail,qmail or mdaemon log format
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
$lastmon=0;
my $numrecord=0;
my $numrecordforflush=0;
while (<>) {
	chomp $_; s/\r//;
	$numrecord++;
	$numrecordforflush++;

	my $mailid=0;

	if (/^__BREAKPOINT__/) { last; }	# For debug only

	### <CJK> ###
	my ($mon)=m/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s/;
	if ($mon) {
	    $mon = $MonthNum{$mon};
		if ($mon==12 && $lastmon==1 ){$year--;}
		if ($mon==1 && $lastmon==12){$year++;}
		$lastmon=$mon;
	}
	### </CJK> ###

	if (/^#/) {
		debug("Comment record");
		next;
	}
	
	#
	# Get sender host for postfix
	#
	elsif (/: client=/) {
		$MailType||='postfix';
		# Example:
		# postfix:  Jan 01 07:27:32 apollon.com postfix/smtpd[1684]: 2BC793B8A4: client=remt30.cluster1.abcde.net[209.225.8.40]
		my ($id,$relay_s)=m/\w+\s+\d+\s+\d+:\d+:\d+\s+[\w\-\.\@]+\s+(?:sendmail|postfix\/(?:local|lmtp|smtpd|smtp|virtual|pipe))\[\d+\]:\s+(.*?):\s+client=(.*)/;
		$mailid=$id;
		$mail{$id}{'relay_s'}=$relay_s;
		debug("For id=$id, found host sender on a 'client' line: $mail{$id}{'relay_s'}");
	}

	#
	# See if we received postfix email reject error
	#
	elsif (/: reject/) {
		$MailType||='postfix';
		# Example: 
		# postfix ?.? :  Jan 01 12:00:00 halley postfix/smtpd[9245]: reject: RCPT from unknown[203.156.32.33]: 554 <userx@yahoo.com>: Recipient address rejected: Relay access denied; from=<sender@aol.com> to=<userx@yahoo.com>
        # postfix 2.1+:  Jan 01 12:00:00 localhost postfix/smtpd[11120]: NOQUEUE: reject: RCPT from unknown[62.205.124.145]: 450 Client host rejected: cannot find your hostname, [62.205.124.145]; from=<sender@msn.com> to=<usery@yahoo.com> proto=ESMTP helo=<xxx.com>
		# postfix ?.? :  Jan 01 12:00:00 apollon postfix/smtpd[26553]: 1954F3B8A4: reject: RCPT from unknown[80.245.33.2]: 450 <usery@yahoo.com>: User unknown in local recipient table; from=<sender@msn.com> to=<usery@yahoo.com> proto=ESMTP helo=<xxx.com>
		my ($mon,$day,$time,$id,$code,$from,$to)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-\.\@]+\s+(?:postfix\/(?:local|lmtp|smtpd|smtp|virtual|pipe))\[\d+\]:\s+(.*?):\s+(.*)\s+from=([^\s,]*)\s+to=([^\s,]*)/;
		# postfix:	Jan 01 14:10:16 juni postfix/smtpd[2568]: C34ED1432B: reject: RCPT from relay2.tp2rc.edu.tw[163.28.32.177]: 450 <linda@trieger.org>: User unknown in local recipient table; from=<> proto=ESMTP helo=<rmail.nccu.edu.tw>
		if (! $mon) { ($mon,$day,$time,$id,$code,$from)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-\.\@]+\s+(?:postfix\/(?:local|lmtp|smtpd|smtp|virtual|pipe))\[\d+\]:\s+(.*?):\s+(.*)\s+from=([^\s,]*)/; }
		$mailid=($id eq 'reject' || $id eq 'NOQUEUE'?'999':$id);	# id not provided in log, we take '999'
		if ($mailid) {
			# $code='reject: RCPT from unknown[203.156.32.33]: 554 <userx@yahoo.com>: Recipient address rejected: Relay access denied;'
		    #    or 'reject: RCPT from unknown[62.205.124.145]: 450 Client host rejected: cannot find your hostname, [62.205.124.145]; from=<sender@msn.com> to=<usery@yahoo.com> proto=ESMTP helo=<xxx.com>'
			#    or 'reject: RCPT from unknown[80.245.33.2]: 450 <usery@yahoo.com>: User unknown in local recipient table;'
			if ($code =~ /\s+(\d\d\d)\s+/) { $mail{$mailid}{'code'}=$1; }
			else { $mail{$mailid}{'code'}=999; }	# Unkown error
			if (! $mail{$mailid}{'relay_s'} && $code =~ /from\s+([^\s]+)\s+/) {
				$mail{$mailid}{'relay_s'}=&trim($1);
			}
			$mail{$mailid}{'from'}=&trim($from);
			if ($to) { 
				$mail{$mailid}{'to'}=&trim($to);
			}
			elsif ($code =~ /<(.*)>/) {
				$mail{$mailid}{'to'}=&trim($1);
			}
			$mail{$mailid}{'year'}=$year; ### <CJK>###
			$mail{$mailid}{'mon'}=$mon;
			$mail{$mailid}{'day'}=$day;
			$mail{$mailid}{'time'}=$time;
			if (! defined($mail{$mailid}{'size'})) { $mail{$mailid}{'size'}='?'; }
			debug("For id=$mailid, found a postfix error incoming message: code=$mail{$mailid}{'code'} from=$mail{$mailid}{'from'} to=$mail{$mailid}{'to'} time=$mail{$mailid}{'time'}");
		}
	}
	#
	# See if we received postfix email bounced error
	#
	elsif (/stat(us)?=bounced/) {
		$MailType||='postfix';
		# Example: 
		# postfix:  Sep  9 18:24:23 halley postfix/local[22003]: 12C6413EC9: to=<etavidian@partenor.com>, relay=local, delay=0, status=bounced (unknown user: "etavidian")
		my ($mon,$day,$time,$id,$to,$relay_r)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-\.\@]+\s+(?:postfix\/(?:local|lmtp|smtpd|smtp|virtual|pipe))\[\d+\]:\s+(.*?):\s+to=([^\s,]*)[\s,]+relay=([^\s,]*)/;
		$mailid=($id eq 'reject'?'999':$id);	# id not provided in log, we take '999'
		if ($mailid) {
			$mail{$mailid}{'code'}=999;	# Unkown error (bounced)
			$mail{$mailid}{'to'}=&trim($to);
			$mail{$mailid}{'relay_r'}=&trim($relay_r);
			$mail{$mailid}{'year'}=$year; ### <CJK>###
			$mail{$mailid}{'mon'}=$mon;
			$mail{$mailid}{'day'}=$day;
			$mail{$mailid}{'time'}=$time;
			if (! defined($mail{$mailid}{'size'})) { $mail{$mailid}{'size'}='?'; }
			debug("For id=$mailid, found a postfix bounced incoming message: code=$mail{$mailid}{'code'} to=$mail{$mailid}{'to'} relay_r=$mail{$mailid}{'relay_r'}");
		}
	}
	#
	# See if we received sendmail reject error
	#
	elsif (/, reject/) {
		$MailType||='sendmail';
		# Example: 
		# sm-mta:   Jul 27 04:06:05 androneda sm-mta[6641]: h6RB44tg006641: ruleset=check_mail, arg1=<7ms93d4ms@topprodsource.com>, relay=crelay1.easydns.com [216.220.57.222], reject=451 4.1.8 Domain of sender address 7ms93d4ms@topprodsource.com does not resolve
		# sm-mta:	Jul 27 06:21:24 androneda sm-mta[11461]: h6RDLNtg011461: ruleset=check_rcpt, arg1=<nobody@nova.dice.net>, relay=freedom.myhostdns.com [66.246.77.42], reject=550 5.7.1 <nobody@nova.dice.net>... Relaying denied
		# sendmail: Sep 30 04:21:32 halley sendmail[3161]: g8U2LVi03161: ruleset=check_rcpt, arg1=<amber3624@netzero.net>, relay=moon.partenor.fr [10.0.0.254], reject=550 5.7.1 <amber3624@netzero.net>... Relaying denied

		# sendmail:	Jan 10 07:37:48 smtp sendmail[32440]: ruleset=check_relay, arg1=[211.228.26.114], arg2=211.228.26.114, relay=[211.228.26.114], reject=554 5.7.1 Rejected 211.228.26.114 found in dnsbl.sorbs.net
		# sendmail: Jan 10 07:37:08 smtp sendmail[32439]: ruleset=check_relay, arg1=235.Red-213-97-175.pooles.rima-tde.net, arg2=213.97.175.235, relay=235.Red-213-97-175.pooles.rima-tde.net [213.97.175.235], reject=550 5.7.1 Mail from 213.97.175.235 refused. Rejected for bad WHOIS info on IP of your SMTP server - see http://www.rfc-ignorant.org/
		# sendmail: Jan 10 17:15:42 smtp sendmail[12770]: ruleset=check_relay, arg1=[63.218.84.21], arg2=63.218.84.21, relay=[63.218.84.21], reject=553 5.3.0 Rejected - see http://spamhaus.org/
		my ($mon,$day,$time,$id,$ruleset,$arg,$relay_s,$code)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-\.\@]+\s+(?:sendmail|sm-mta)\[\d+\][:\s]*(.*?):\sruleset=(\w+),\s+arg1=(.*),\s+relay=(.*),\s+(reject=.*)/;
		# sendmail: Jan 10 18:00:34 smtp sendmail[5759]: i04Axx2c005759: Milter: data, reject=511 Virus found in email!
		if (! $mon) { ($mon,$day,$time,$id,$ruleset,$code)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-\.\@]+\s+(?:sendmail|sm-mta)\[\d+\]:\s+(.*?):\s\w+:\s(\w+),\s+(reject=.*)/; }
		$mailid=(! $id && $mon?'999':$id);	# id not provided in log, we take '999'
		if ($mailid) {
			if ($ruleset eq 'check_mail') { $mail{$mailid}{'from'}=$arg; }
			if ($ruleset eq 'check_rcpt') { $mail{$mailid}{'to'}=$arg; }
			if ($ruleset eq 'check_relay') { }
			if ($ruleset eq 'data') { }
			$mail{$mailid}{'relay_s'}=$relay_s;
			# $code='reject=550 5.7.1 <amber3624@netzero.net>... Relaying denied'
			if ($code =~ /=(\d\d\d)\s+/) { $mail{$mailid}{'code'}=$1; }
			else { $mail{$mailid}{'code'}=999; }	# Unkown error
			$mail{$mailid}{'year'}=$year; ### <CJK>###
			$mail{$mailid}{'mon'}=$mon;
			$mail{$mailid}{'day'}=$day;
			$mail{$mailid}{'time'}=$time;
			if (! defined($mail{$mailid}{'size'})) { $mail{$mailid}{'size'}='?'; }
			debug("For id=$mailid, found a sendmail error incoming message: code=$mail{$mailid}{'code'} from=$mail{$mailid}{'from'} to=$mail{$mailid}{'to'} relay_s=$mail{$mailid}{'relay_s'}");
		}
	}

	#
 	# See if we send a sendmail (with ctladdr tag) email
 	#
 	elsif (/, ctladdr=/) {
		$MailType||='sendmail';
		#
		# Matched outgoing sendmail/postfix message
		#
		my ($mon,$day,$time,$id,$to,$fromorto)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-\.\@]+\s+(?:sm-mta|sendmail(?:-out|)|postfix\/(?:local|lmtp|smtpd|smtp|virtual|pipe))\[.*?\]:\s+([^:]*):\s+to=(.*?)[,\s]+ctladdr=([^\,\s]*)/;
		$mailid=$id;
		if (m/\s+relay=([^\s,]*)[\s,]/) { $mail{$id}{'relay_r'}=$1; }
		elsif (m/\s+mailer=local/) { $mail{$id}{'relay_r'}='localhost'; }
		if (/, stat\=Sent/) { $mail{$id}{'code'}=1; }
		elsif (/, stat\=User\s+unknown/) { $mail{$id}{'code'}=550; }
		elsif (/, stat\=Local\s+configuration/) { $mail{$id}{'code'}=451; }
		elsif (/, stat\=Deferred:\s+(\d*)/) { $mail{$id}{'code'}=$1; }
		else { $mail{$id}{'code'}=999; }
			$mail{$mailid}{'year'}=$year; ### <CJK>###
		$mail{$id}{'mon'}=$mon;
		$mail{$id}{'day'}=$day;
		$mail{$id}{'time'}=$time;
		if (&trim($to)=~/^\|/) {
			# In particular case of mails are sent to a pipe, the ctladdr contains the to
			$mail{$id}{'to'}=&trim($fromorto);
		} else {
			# In most cases
			$mail{$id}{'to'}=&trim($to);
			$mail{$id}{'from'}=&trim($fromorto);
		}
		if (! defined($mail{$id}{'size'})) { $mail{$id}{'size'}='?'; }
		debug("For id=$id, found a sendmail outgoing message: to=$mail{$id}{'to'} from=$mail{$id}{'from'} size=$mail{$id}{'size'} relay_r=".($mail{$id}{'relay_r'}||''));
 	}

	#
	# Matched incoming qmail message
	#
	elsif (/info msg .* from/) {
		# Example: Sep 14 09:58:09 gandalf qmail: 1063526289.292776 info msg 270182: bytes 10712 from <john@john.do> qp 54945 uid 82
		$MailType||='qmail';
		#my ($id,$size,$from)=m/info msg \d+: bytes (\d+) from <(.*)>/;
		my ($id,$size,$from)=m/info msg (\d+): bytes (\d+) from <(.*)>/;
		$mailid=$id;
		delete $mail{$mailid};	# If 'info msg' found, we start a new mail. This is to protect from wrong file
		if (! $mail{$id}{'from'} || $mail{$id}{'from'} ne '<>') { $mail{$id}{'from'}=$from; }	# TODO ???
		$mail{$id}{'size'}=$size;
		if (m/\s+relay=([^\,]+)[\s\,]/ || m/\s+relay=([^\s\,]+)$/) { $mail{$id}{'relay_s'}=$1; }
		debug("For id=$id, found a qmail 'info msg' message: from=$mail{$id}{'from'} size=$mail{$id}{'size'}");
	}

	#
	# Matched incoming sendmail or postfix message
	#
	elsif (/: from=/) {
		# sm-mta:  Jul 28 06:55:13 androneda sm-mta[28877]: h6SDtCtg028877: from=<xxx@mysite.net>, size=2556, class=0, nrcpts=1, msgid=<w1$kqj-9-o2m45@0h2i38.4.m0.5u>, proto=ESMTP, daemon=MTA, relay=smtp.easydns.com [205.210.42.50]
		# postfix: Jul  3 15:32:26 apollon postfix/qmgr[13860]: 08FB63B8A4: from=<nobody@ns3744.ovh.net>, size=3302, nrcpt=1 (queue active)
		# postfix: Sep 24 14:45:15 wideboy postfix/qmgr[22331]: 7E0E6196: from=<xxx@hotmail.com>, size=1141 (queue active)
		my ($id,$from,$size)=m/\w+\s+\d+\s+\d+:\d+:\d+\s+[\w\-\.\@]+\s+(?:sm-mta|sendmail(?:-in|)|postfix\/qmgr|postfix\/nqmgr)\[\d+\]:\s+(.*?):\s+from=(.*?),\s+size=(\d+)/;
		$mailid=$id;
		if (! $mail{$id}{'code'}) { $mail{$id}{'code'}=1; }	# If not already defined, we define it
		if (! $mail{$id}{'from'} || $mail{$id}{'from'} ne '<>') { $mail{$id}{'from'}=$from; }
		$mail{$id}{'size'}=$size;
		if (m/\s+relay=([^\,]+)[\s\,]/ || m/\s+relay=([^\s\,]+)$/) { $mail{$id}{'relay_s'}=$1; }
		debug("For id=$id, found a sendmail/postfix incoming message: from=$mail{$id}{'from'} size=$mail{$id}{'size'} relay_s=".($mail{$id}{'relay_s'}||''));
	}

	#
	# Matched exchange message
	#
	elsif (/^([^\t]+)\t([^\t]+)\t[^\t]+\t([^\t]+)\t([^\t]+)\t([^\t]+)\t[^\t]+\t([^\t]+)\t([^\t]+)\t([^\t]+)\t[^\t]+\t[^\t]+\t([^\t]+)\t[^\t]+\t[^\t]+\t[^\t]+\t[^\t]+\t[^\t]+\t([^\t]+)\t([^\t]+)/) {
		#    date      hour GMT  ip_s    relay_s   partner   relay_r   ip_r    to        code      id                        size                                              subject   from
		# Example: 2003-8-12	0:58:14 GMT	66.218.66.69	n14.grp.scd.yahoo.com	-	PACKRAT	192.168.1.2	christina@pirnie.org	1019	bh9e3f+5qvo@eGroups.com	0	0	4281	1	2003-8-12 0:58:14 GMT	0	Version: 6.0.3790.0	-	 [SRESafeHaven] Re: More Baby Stuff	jtluvs2cq@wmconnect.com	-
		$MailType||='exchange';
		my $date=$1;
		my $time=$2;
		my $relay_s=$3;
		my $partner=$4;
		my $relay_r=$5;
		my $to=$6; $to =~ s/\s/%20/g;
		my $code=$7;
		my $id=$8;
		my $size=$9;
		my $subject=&trim($10);
		my $from=$11; $from =~ s/\s/%20/g;
		$id=sprintf("%s_%s_%s",$id,$from,$to);
		# Check if record is significant record
		my $ok=0;

		# Code 1031=SMTP End Outbound Transfer
		if ($code == 1031) {	# This is for external bound mails
			$ok=1;
			my $savrelay_s=$relay_s;
			$relay_s=$relay_r; $relay_r=$savrelay_s;
			#$relay_s=$relay_r;
			#$relay_r=$partner;
			$code=1;
		}
		# Code 1028=SMTP Store Driver: Message Delivered Locally to Store
		if ($code == 1028) {	# This is for local bound mails
			$code=1;
			$ok=1;
		}
		# Code 1030=SMTP: Non-Delivered Report (NDR) Generated
		if ($code == 1030) {	# This is for errors. 
			$code=999;
			$ok=1;
		}

		if ($ok && !$mail{$id}{'code'} ) {		
			$mailid=$id;
			if ($date =~ /(\d+)-(\d+)-(\d+)/) {
				$mail{$id}{'year'}=sprintf("%02s",$1);
				$mail{$id}{'mon'}=sprintf("%02s",$2);
				$mail{$id}{'day'}=sprintf("%02s",$3);
			}
			if ($time =~ /^(\d+):(\d+):(\d+)/) {
				$mail{$id}{'time'}=sprintf("%02s:%02s:%02s",$1,$2,$3);
			}
			if ( $from eq '<>' && $subject =~ /^Delivery\s+Status/) {
				$from='postmaster@localhost';
			}
			$mail{$id}{'from'}=$from;
			$mail{$id}{'to'}=$to;
			$mail{$id}{'code'}=$code;
			$mail{$id}{'size'}=$size;
			$mail{$id}{'relay_s'}=$relay_s;
			$mail{$id}{'relay_r'}=$relay_r;
			debug("For id=$id, found an exchange message: year=$mail{$id}{'year'} mon=$mail{$id}{'mon'} day=$mail{$id}{'day'} time=$mail{$id}{'time'} from=$mail{$id}{'from'} to=$mail{$id}{'to'} size=$mail{$id}{'size'} code=$mail{$id}{'code'} relay_s=$mail{$id}{'relay_s'} relay_r=$mail{$id}{'relay_r'}");
		}
	}

	#
	# Matched sendmail or postfix "to" message
	#
	elsif (/: to=.*stat(us)?=sent/i) {
		# Example:
		# postfix:  Jan 01 07:27:38 apollon postfix/local[1689]: 2BC793B8A4: to=<jo@jo.com>, orig_to=<webmaster@toto.com>, relay=local, delay=6, status=sent ("|/usr/bin/procmail")
		my ($mon,$day,$time,$id,$to)=m/(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+[\w\-\.\@]+\s+(?:sm-mta|sendmail(?:-out|)|postfix\/(?:local|lmtp|smtpd|smtp|virtual|pipe))\[.*?\]:\s+(.*?):\s+to=(.*?),/;
		$mailid=$id;
		$mail{$id}{'code'}='1';
		if (m/\s+relay=([^\s,]*)[\s,]/) { $mail{$id}{'relay_r'}=$1; }
		elsif (m/\s+mailer=local/) { $mail{$id}{'relay_r'}='localhost'; }
		if (m/forwarded as/) {
			# If 'forwarded as idnewmail' is found, we discard this mail to avoid counting it twice
			debug("For id=$id, mail was forwarded to other id, we discard it");
			delete $mail{$id};
		} 
		###########################################
		elsif (m/\s*dsn=2.6.0\s*/) {
            # if the DSN is not 2.0.0, we discard this mail to avoid counting it twice
            # postfix: Aug 29 19:22:38 example postfix/smtp[1347]: D989FD6C302: to=<webmaster@example.com>, relay=127.0.0.1[127.0.0.1]:10024, delay=2.9, delays=0.31/0.01/0/2.6, dsn=2.6.0, status=sent (250 2.6.0 Ok, id=01182-01, from MTA([127.0.0.1]:10025): 250 2.0.0 Ok: queued as 995DCD6C315)
            debug("For id=$id, mail DSN is not 2.0.0, we discard it");
            delete $mail{$id};
        }
        ###########################################
		else {
			if (m/\s+orig_to=([^\s,]*)[\s,]/) {
				# If we have a orig_to, we used it as receiver
				$mail{$id}{'to'}=&trim($1);
				$mail{$id}{'forwardedto'}=&trim($to);
			}
			else {
				$mail{$id}{'to'}=&trim($to);
			}
			$mail{$mailid}{'year'}=$year; ### <CJK>###
			$mail{$id}{'mon'}=$mon;
			$mail{$id}{'day'}=$day;
			$mail{$id}{'time'}=$time;
			debug("For id=$id, found a sendmail/postfix record: mon=$mail{$id}{'mon'} day=$mail{$id}{'day'} time=$mail{$id}{'time'} to=$mail{$id}{'to'} relay_r=$mail{$id}{'relay_r'}");
		}
	}

	#
	# Matched qmail "to" record
	#
	elsif (/starting delivery/) {
		# Example: Sep 14 09:58:09 gandalf qmail: 1063526289.574100 starting delivery 251: msg 270182 to local spamreport@john.do
		# Example: 2003-09-27 11:22:07.039237500 starting delivery 3714: msg 163844 to local name_also_removed@maildomain.com
		$MailType||='qmail';
		my ($yea,$mon,$day,$time,$delivery,$id,$relay_r,$to)=();
		($mon,$day,$time,$delivery,$id,$relay_r,$to)=m/^(\w+)\s+(\d+)\s+(\d+:\d+:\d+)\s+.*\s+\d+(?:\.\d+)?\s+starting delivery (\d+):\s+msg\s+(\d+)\s+to\s+(.*)?\s+(.*)$/;
		if (! $id) { ($yea,$mon,$day,$time,$delivery,$id,$relay_r,$to)=m/^(\d+)-(\d+)-(\d+)\s+(\d+:\d+:\d+).*\s+starting delivery (\d+):\s+msg\s+(\d+)\s+to\s+(.*)?\s+(.*)$/; }
		$mailid=$id;
		if ($relay_r eq 'local') { $mail{$id}{'relay_r'}='localhost'; }
		elsif (m/\s+relay=([^\s,]*)[\s,]/) { $mail{$id}{'relay_r'}=$1; }
		elsif (m/\s+mailer=local/) { $mail{$id}{'relay_r'}='localhost'; }
		$qmaildelivery{$delivery}=$id;		# Save mail id for this delivery to be able to get error code
		if ($yea) { $mail{$id}{'year'}=$yea; }
		$mail{$id}{'mon'}=$mon;
		$mail{$id}{'day'}=$day;
		$mail{$id}{'time'}=$time;
		$mail{$id}{'to'}{$delivery}=&trim($to);
		debug("For id=$id, found a qmail 'start delivery' record: year=".($mail{$id}{'year'}||'')." mon=$mail{$id}{'mon'} day=$mail{$id}{'day'} time=$mail{$id}{'time'} to=$mail{$id}{'to'}{$delivery} relay_r=".($mail{$id}{'relay_r'}||'')." delivery=$delivery");
	}

	#
	# Matched qmail status code record
	#
	elsif (/delivery (\d+): (\w+):/) {
		# Example: Sep 14 09:58:09 gandalf qmail: 1063526289.744259 delivery 251: success: did_0+0+1/
		# Example: 2003-09-27 11:22:07.070367500 delivery 3714: success: did_1+0+0/
		$MailType||='qmail';
		my ($delivery,$code)=($1,$2);
		my $id=$qmaildelivery{$delivery};
		$mailid=$id;
		if ($code =~ /success/i) { $mail{$id}{'code'}{$delivery}=1; }
		elsif ($code =~ /deferral/i) { $mail{$id}{'code'}{$delivery}=999; }
		else { $mail{$id}{'code'}{$delivery}=999; }
		debug("For id=$qmaildelivery{$delivery}, found a qmail 'delivery' record: delivery=$delivery code=$mail{$id}{'code'}{$delivery}");
	}
	#
	# Matched qmail end of mail record
	#
	elsif (/end msg (\d+)/ && scalar %{$mail{$1}{'to'}}) {	# If records for mail id are finished and still mails with no delivery status
		# Example: Sep 14 09:58:12 gandalf qmail: 1063526292.782444 end msg 270182
		$MailType||='qmail';
		my ($id)=($1);
		$mailid=$id;
		foreach my $delivery (keys %{$mail{$mailid}{'to'}}) { $mail{$id}{'code'}{$delivery}||=1; }
		debug("For id=$id, found a qmail 'end msg' record. This replace 'delivery' record for delivery=".join(',',keys %{$mail{$id}{'code'}}));
	}
	#
	# Matched MDaemon log file record
	#
    elsif (/^\"(\d\d\d\d)-(\d\d)-(\d\d) (\d\d:\d\d:\d\d)\",\"[^\"]*\",(\w+),\d+,\"([^\"]*)\",\"([^\"]*)\",\"([^\"]*)\",\"[^\"]*\",\"([^\"]*)\",\"([^\"]*)\",\"([^\"]*)\",(-?[\.\d]+),(\d+),(\d+)/) {
		# Example: "2003-11-06 00:00:42","2003-11-06 00:00:45",SMTPI,9443,"dillon_fm@aaaaa.net","cpeltier@domain.com","","","10.0.0.16","","",0,4563,1
		$MailType||='mdaemon';
		my ($id)=($numrecord);
		if ($5 eq 'SMTPI' || $5 eq 'SMTPO') {
			$mail{$id}{'year'}=$1;
			$mail{$id}{'mon'}=$2;
			$mail{$id}{'day'}=$3;
			$mail{$id}{'time'}=$4;
			$mail{$id}{'direction'}=($5 eq 'SMTPI'?'in':'out');
			$mail{$id}{'from'}=$6;
			$mail{$id}{'to'}=$7||$8;
			if ($5 eq 'SMTPI') {
				$mail{$id}{'relay_s'}=$9;
				$mail{$id}{'relay_r'}='-';
			}
			if ($5 eq 'SMTPO') {
				$mail{$id}{'relay_s'}=$9;
				$mail{$id}{'relay_r'}='-';
			}
			$mail{$id}{'code'}=1;
			$mail{$id}{'size'}=$13;
			$mail{$id}{'extinfo'}="?virus=$10&rbl=$11&heuristicspam=$12&ssl=$14";
			$mail{$id}{'extinfo'}=~s/\s/_/g;
			$mailid=$id;
		}
	}
	
	
	#
	# Write record if all required data were found
	#
	if ($mailid) {
		my $code; my $to;
		my $delivery=0;
		my $canoutput=0;
		
		debug("ID:$mailid RELAY_S:".($mail{$mailid}{'relay_s'}||'')." RELAY_R:".($mail{$mailid}{'relay_r'}||'')." FROM:".($mail{$mailid}{'from'}||'')." TO:".($mail{$mailid}{'to'}||'')." CODE:".($mail{$mailid}{'code'}||''));

		# Check if we can output a mail line
		if ($MailType eq 'qmail') {
			if ($mail{$mailid}{'code'} && scalar %{$mail{$mailid}{'code'}}) {
				# This is a hash variable
				foreach my $key (keys %{$mail{$mailid}{'code'}}) {
					$delivery=$key;
					$code=$mail{$mailid}{'code'}{$key};
					$to=$mail{$mailid}{'to'}{$key};
				}
				$canoutput=1;
			}
		}
		elsif ($MailType eq 'mdaemon') {
			$code=$mail{$mailid}{'code'};
			$to=$mail{$mailid}{'to'};
			$canoutput=1;
		}
		else {
			$code=$mail{$mailid}{'code'};
			$to=$mail{$mailid}{'to'};
			if ($mail{$mailid}{'from'} && $mail{$mailid}{'to'}) { $canoutput=1; }
			if ($mail{$mailid}{'from'} && $mail{$mailid}{'code'} > 1) { $canoutput=1; }
			if ($mailid && $mail{$mailid}{'code'} > 1) { $canoutput=1; }
		}

		# If we can
		if ($canoutput) {
			&OutputRecord($mail{$mailid}{'year'}?$mail{$mailid}{'year'}:$year,$mail{$mailid}{'mon'},$mail{$mailid}{'day'},$mail{$mailid}{'time'},$mail{$mailid}{'from'},$to,$mail{$mailid}{'relay_s'},$mail{$mailid}{'relay_r'},$code,$mail{$mailid}{'size'},$mail{$mailid}{'forwardto'},$mail{$mailid}{'extinfo'});
			# Delete mail with generic unknown id (This id can by used by another mail)
			if ($mailid eq '999') {
				debug(" Delete mail for id=$mailid",3);
				delete $mail{$mailid};
			}
			# Delete delivery instance for id if qmail (qmail can use same id for several mails with multiple delivery)
			elsif ($MailType eq 'qmail') {
				debug(" Delete delivery instances for mail id=$mailid and delivery id=$delivery",3);
				if ($delivery) {
					delete $mail{$mailid}{'to'}{$delivery};
					delete $mail{$mailid}{'code'}{$delivery};
				}
			}

			# We flush %mail if too large
			if (scalar keys %mail > $NBOFENTRYFOFLUSH) {
				debug("We reach $NBOFENTRYFOFLUSH records in %mail, so we flush mail hash array");
				#foreach my $id (keys %mail) {
				#	debug(" Delete mail for id=$id",3);
				#	delete $mail{$id};
				#}
				%mail=();
				%qmaildelivery=();
			}

		}
	}
	else {
		debug("Not interesting row");
	}

}

#foreach my $key (keys %mail) {
#	print ".$key.$mail{$key}{'to'}.\n";
#}

0;

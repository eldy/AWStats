#!/usr/bin/perl
#-------------------------------------------------------
# Save the click done on managed hits into a trace file
# and return to browser a redirector to tell browser to visit this URL.
# Ex: <a href="http://athena/cgi-bin/awredir/awredir.pl?url=http://212.43.217.240/%7Eforumgp/forum/list.php3?f=11">XXX</a>
#-------------------------------------------------------

#use DBD::mysql;


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
use vars qw/ $REVISION $VERSION /;
$REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
$VERSION="1.1 (build $REVISION)";

use vars qw / $DIR $PROG $Extension $DEBUG $DEBUGFILE $REPLOG $DEBUGRESET $SITE $REPCONF /;
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
$DEBUG=0;					# Debug level
$DEBUGFILE="$PROG.log";		# Debug output (A log file name or "screen" to have debug on screen)

$TRACEBASE=0;
$TRACEFILE=0;
$TXTDIR="$DIR/../../../logs"; $TXTFILE="awredir.trc";
#$TRACEFILE=1; $TXTDIR="$DIR"; $TXTFILE="chiensderace_awredir.txt";
$REPLOG="$DIR";

$EXCLUDEIP="127.0.0.1";


#-------------------------------------------------------
# Functions
#-------------------------------------------------------

sub error {
	print "Content-type: text/html; charset=iso-8859-1\n";
	print "\n";
	print "<html>\n";
	print "<head>\n";
	print "</head>\n";
	print "\n";
	print "<body>\n";
	print "<center><br>\n";
	print "<font size=2><b>AWRedir</b></font><br>\n\n";
   	print "<font color=#880000>$_[0].</font><br><br>\n";
	print "Setup (setup or logfile permissions) may be wrong.\n";
	$date=localtime();
	print "<CENTER><br><font size=1>$date - <b>Advanced Web Redirector $VERSION</b><br>\n";
	print "<br>\n";
	print "</body>";
	print "</html>";
    die;
}

#-------------------------------------------------------
# MAIN
#-------------------------------------------------------

if ($DEBUG) {
	open(LOGFILE,">$REPLOG/$PROG.log");
	print LOGFILE "----- $PROG $VERSION -----\n";	
}

if (! $ENV{'GATEWAY_INTERFACE'}) {	# Run from command line
	print "----- $PROG $VERSION -----\n";
	print "This script is only usefull when used as a CGI script.\n";
	print "When called as a CGI, this script return to browser a redirector to tell it\n";
	print "to show the page provided in parameters.\n";
	print "So, to use this script, you must replace HTML code for links in your HTML pages\n";
	print "from\n";
	print "<a href=\"http://sitelinked/pagelinked\">Link</a>\n";
	print "to\n";
	print "<a href=\"http://mysite/cgi-bin/awredir.pl?url=http://sitelinked/pagelinked\">Link</a>\n";
	print "\n";
	print "For your web visitor, there is no difference. However this allow you to track\n";
	print "clicks done on your site on external links.\n";
	exit 0;
}

$Url=$ENV{QUERY_STRING};

# Extract url to redirect to
if ($Url =~ /url=\"([^\"]+)\"/) { $Url=$1; }
elsif ($Url =~ /url=(.+)$/) { $Url=$1; }

if ($Url !~ /^http/i) { $Url = "http://".$Url; }
if (! $Url) {
	error("Error: Bad use of $PROG. To redirect an URL with $PROG, use the following syntax:<br><i>/cgi-bin/$PROG.pl?url=http://urltogo</i>");
}
if ($DEBUG) { print LOGFILE "Url=$Url\n"; }

# Get date
($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday,$nowyday,$nowisdst) = localtime(time);
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
$nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
if (++$nowmonth < 10) { $nowmonth = "0$nowmonth"; }
if ($nowday < 10) { $nowday = "0$nowday"; }
if ($nowhour < 10) { $nowhour = "0$nowhour"; }
if ($nowmin < 10) { $nowmin = "0$nowmin"; }
if ($nowsec < 10) { $nowsec = "0$nowsec"; }

if ($TRACEBASE == 1) {
	if ($ENV{REMOTE_ADDR} !~ /$EXCLUDEIP/) {
		if ($DEBUG == 1) { print LOGFILE "Execution requete Update sur BASE=$BASE, USER=$USER, PASS=$PASS\n"; }
		my $dbh = DBI->connect("DBI:mysql:$BASE", $USER, $PASS) || die "Can't connect to DBI:mysql:$BASE: $dbh->errstr\n";
		my $sth = $dbh->prepare("UPDATE T_LINKS set HITS_LINKS = HIT_LINKS+1 where URL_LINKS = '$Url'");
		$sth->execute || error("Error: Unable execute query:$dbh->err, $dbh->errstr");
		$sth->finish;
		$dbh->disconnect;
		if ($DEBUG == 1) { print LOGFILE "Execution requete Update - OK\n"; }
	}
}

if ($TRACEFILE == 1) {
	if ($ENV{REMOTE_ADDR} !~ /$EXCLUDEIP/) {
		open(FICHIER,">>$TXTDIR/$TXTFILE") || error("Error: Enable to open trace file $TXTDIR/$TXTFILE: $!");
		print FICHIER "$nowyear-$nowmonth-$nowday $nowhour:$nowmin:$nowsec\t$ENV{REMOTE_ADDR}\t$Url\n";
		close(FICHIER);
	}
}

# Redir html instructions
print "Location: $Url\n\n";

if ($DEBUG) {
	print LOGFILE "Redirect to $Url\n";
	close(LOGFILE);
}

0;

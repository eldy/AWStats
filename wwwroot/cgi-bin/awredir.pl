#!/usr/bin/perl
#-------------------------------------------------------
# Save the click done on managed hits into a trace file
# and return to browser a redirector to tell browser to visit this URL.
# Ex: <a href="http://athena/cgi-bin/awredir/awredir.pl?tag=TAGFORLOG&key=ABCDEFGH&url=http://212.43.217.240/%7Eforumgp/forum/list.php3?f=11">XXX</a>
# Where ABCDEFGH is md5(YOURKEYFORMD5.url)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------

#use DBD::mysql;
use Digest::MD5 qw(md5 md5_hex md5_base64);


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
use vars qw/ $REVISION $VERSION /;
$REVISION='20140126';
$VERSION="1.2 (build $REVISION)";

use vars qw / $DIR $PROG $Extension $DEBUG $DEBUGFILE $REPLOG $DEBUGRESET $SITE $REPCONF /;
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
$DEBUG=0;					# Debug level
$DEBUGFILE="$PROG.log";		# Debug output (A log file name or "screen" to have debug on screen)
$REPLOG="$DIR";				# Debug directory

$TRACEBASE=0;	# Set to 1 to track click on links that point to extern site into a database
$TRACEFILE=0;	# Set to 1 to track click on links that point to extern site into a file
$TXTDIR="$DIR/../../../logs";	# Directory where to write tracking file (if TRACEFILE=1)
$TXTFILE="awredir.trc";			# Tracking file (if TRACEFILE=1)
$EXCLUDEIP="127.0.0.1";

# Put here a personalised value.
# If you do not want to use the security key in link to avoid use of awredir by an external web
# site, you can set this to the empty string, but be warned that this is a security hole as everybody
# can use awredir on your site to redirect to any web site (including illegal web sites).
$KEYFORMD5='YOURKEYFORMD5';
# Put here url pattern you want to allow event if parameter key is not provided.
$AUTHORIZEDWITHOUTKEY='';


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

#------------------------------------------------------------------------------
# Function:     Decode an URL encoded string
# Parameters:	stringtodecode
# Input:        None
# Output:		None
# Return:		decodedstring
#--------------------------------------------------------------------
sub DecodeEncodedString {
	my $stringtodecode=shift;
	$stringtodecode =~ s/\+/ /g;
	$stringtodecode =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;		# Decode encoded URL
	return $stringtodecode;
}

#------------------------------------------------------------------------------
# Function:     Clean a string of HTML tags to avoid 'Cross Site Scripting attacks'
#               and clean | char.
# Parameters:   stringtoclean
# Input:        None
# Output:       None
# Return:		cleanedstring
#------------------------------------------------------------------------------
sub CleanXSS {
	my $stringtoclean = shift;

	# To avoid html tags and javascript
	$stringtoclean =~ s/</&lt;/g;
	$stringtoclean =~ s/>/&gt;/g;
	$stringtoclean =~ s/|//g;

	# To avoid onload="
	$stringtoclean =~ s/onload//g;
	return $stringtoclean;
}


#-------------------------------------------------------
# MAIN
#-------------------------------------------------------

if ($DEBUG) {
	open(LOGFILE,">$REPLOG/$PROG.log");
	print LOGFILE "----- $PROG $VERSION -----\n";	
}

if (! $ENV{'GATEWAY_INTERFACE'}) {	# Run from command line
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "This script is absolutely not required to use AWStats.\n";
	print "It's a third tool that can help webmaster in their tracking tasks but is\n";
	print "not used by AWStats engine.\n";
	print "\n";
	print "This tools must be used as a CGI script. When called as a CGI, it returns to\n";
	print "browser a redirector to tell it to show the page provided in 'url' parameter.\n";
	print "So, to use this script, you must replace HTML code for external links onto your\n";
	print "HTML pages from\n";
	print "<a href=\"http://externalsite/pagelinked\">Link</a>\n";
	print "to\n";
	print "<a href=\"http://mysite/cgi-bin/awredir.pl?key=ABCDEFGH&url=http://externalsite/pagelinked\">Link</a>\n";
	print "\n";
	print "For your web visitor, there is no difference. However this allow you to track\n";
	print "clicks done on links onto your web pages that point to external web sites,\n";
	print "because an entry will be seen in your own server log, to awredir.pl script\n";
	print "with url parameter, even if link was pointing to another external web server.\n";
	print "\n";
	sleep 2;
	exit 0;
}

if ((! $AUTHORIZEDWITHOUTKEY) && ($KEYFORMD5 eq 'YOURKEYFORMD5')) {
        error("Error: You must change value of constant KEYFORMD5 in awredir.pl script.");
}

# Extract tag
$Tag='NOTAG';
if ($ENV{QUERY_STRING} =~ /tag=\"?([^\"&]+)\"?/) { $Tag=$1; }

$Key='NOKEY';
if ($ENV{QUERY_STRING} =~ /key=\"?([^\"&]+)\"?/) { $Key=$1; }

# Extract url to redirect to
$Url=$ENV{QUERY_STRING};
if ($Url =~ /url=\"([^\"]+)\"/) { $Url=$1; }
elsif ($Url =~ /url=(.+)$/) { $Url=$1; }
$Url = DecodeEncodedString($Url);
$UrlParam=$Url;

# Sanitize parameters
$Tag=CleanXSS($Tag);
$Key=CleanXSS($Key);
$UrlParam=CleanXSS($UrlParam);


if (! $UrlParam) {
        error("Error: Bad use of $PROG. To redirect an URL with $PROG, use the following syntax:<br><i>/cgi-bin/$PROG.pl?url=http://urltogo</i>");
}

if ($Url !~ /^http/i) { $Url = "http://".$Url; }
if ($DEBUG) { print LOGFILE "Url=$Url\n"; }

if ((! $AUTHORIZEDWITHOUTKEY || $UrlParam !~ /$AUTHORIZEDWITHOUTKEY/) && $KEYFORMD5 && ($Key ne md5_hex($KEYFORMD5.$UrlParam))) {
#       error("Error: Bad value for parameter key=".$Key." to allow a redirect to ".$UrlParam." - ".$KEYFORMD5." - ".md5_hex($KEYFORMD5.$UrlParam) );
        error("Error: Bad value for parameter key=".$Key." to allow a redirect to ".$UrlParam.". Key must be hexadecimal md5(KEYFORMD5.".$UrlParam.") where KEYFORMD5 is value hardcoded into awredir.pl. Note: You can remove use of key by setting KEYFORMD5 to empty string in script awredir.pl");
}

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
		print FICHIER "$nowyear-$nowmonth-$nowday $nowhour:$nowmin:$nowsec\t$ENV{REMOTE_ADDR}\t$Tag\t$Url\n";
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

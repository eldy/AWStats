#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Merge several log files into one and replace all IP addresses
# with resolved DNS host name.
# This tool is part of AWStats log analyzer but can be use
# alone for any other log analyzer.
# See COPYING.TXT file about AWStats GNU General Public License.
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$

use strict; no strict "refs";
#use diagnostics;
#use Thread;


#-----------------------------------------------------------------------------
# Defines
#-----------------------------------------------------------------------------
use vars qw/ $REVISION $VERSION /;
$REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
$VERSION="1.2 (build $REVISION)";

# ---------- External Program variables ----------
# For gzip compression
my $zcat = 'zcat';
my $zcat_file = '\.gz$';
# For bz2 compression
my $bzcat = 'bzcat';
my $bzcat_file = '\.bz2$';

# ---------- Init variables --------
use vars qw/ $QUEUEPOOLSIZE $NBOFLINESFORBENCHMARK $USETHREADS /;
$QUEUEPOOLSIZE=10;
$NBOFLINESFORBENCHMARK=8192;
$USETHREADS=0;

my $Debug=0;
my $ShowSteps=0;
my $AddFileNum=0;
my $DIR;
my $PROG;
my $Extension;
my $DNSLookup=0;
my $DNSCache='';
my $DirCgi='';
my $DirData='';
my $DNSLookupAlreadyDone=0;
my $NbOfLinesShowsteps=0;

# ---------- Init arrays --------
my @SkipDNSLookupFor=();
my @ParamFile=();
# ---------- Init hash arrays --------
my %linerecord=();
my %timerecord=();
my %corrupted=();
my %TmpDNSLookup =();
my %QueueHostsToResolve=();
my %QueueRecords=();
my %MyDNSTable=();



#-----------------------------------------------------------------------------
# Functions
#-----------------------------------------------------------------------------

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

#------------------------------------------------------------------------------
# Function:		Write a warning message
# Parameters:	$message
# Input:		$Debug
# Output:		None
# Return:		None
#------------------------------------------------------------------------------
sub warning {
	my $messagestring=shift;
	if ($Debug) { debug("$messagestring",1); }
   	print "$messagestring\n";
}

#-----------------------------------------------------------------------------
# Function:     Return 1 if string contains only ascii chars
# Input:        String
# Return:       0 or 1
#-----------------------------------------------------------------------------
sub IsAscii {
	my $string=shift;
	if ($Debug) { debug("IsAscii($string)",5); }
	if ($string =~ /^[\w\+\-\/\\\.%,;:=\"\'&?!\s]+$/) {
		if ($Debug) { debug(" Yes",5); }
		return 1;		# Only alphanum chars (and _) or + - / \ . % , ; : = " ' & ? space \t
	}
	if ($Debug) { debug(" No",5); }
	return 0;
}

sub SkipDNSLookup {
	foreach my $match (@SkipDNSLookupFor) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipDNSLookupFor
}

sub MakeDNSLookup {
	my $ipaddress=shift;
	debug("MakeDNSlookup (ipaddress=$ipaddress)",4);
	return "azerty";
}



#-----------------------------------------------------------------------------
# MAIN
#-----------------------------------------------------------------------------
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

my $cpt=1;
for (0..@ARGV-1) {
	if ($ARGV[$_] =~ /^-/) {
		if ($ARGV[$_] =~ /debug=(\d)/i) { $Debug=$1; }
		elsif ($ARGV[$_] =~ /dnscache=/i) { $DNSLookup||=2; $DNSCache=$ARGV[$_]; $DNSCache =~ s/-dnscache=//; }
		elsif ($ARGV[$_] =~ /dnslookup/i) { $DNSLookup=1; }
		elsif ($ARGV[$_] =~ /showsteps/i) { $ShowSteps=1; }
		elsif ($ARGV[$_] =~ /addfilenum/i) { $AddFileNum=1; }
		else { print "Unknown argument $ARGV[$_] ignored\n"; }
	}
	else {
		push @ParamFile, $ARGV[$_];
		$cpt++;
	}
}
if (scalar @ParamFile == 0) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG allows you to merge several log files into one output,\n";
	print "sorted on date. It also makes a fast reverse DNS lookup to replace\n";
	print "all IP addresses into host names in resulting log file.\n";
	print "$PROG comes with ABSOLUTELY NO WARRANTY. It's a free software\n";
	print "distributed with a GNU General Public License (See COPYING.txt file).\n";
	print "$PROG is part of AWStats but can be used alone as a log merger\n";
	print "or resolver before using any other log analyzer.\n";
	print "\n";
	print "Usage:\n";
	print "  $PROG.$Extension [options] file\n";
	print "  $PROG.$Extension [options] file1 ... filen\n";
	print "  $PROG.$Extension [options] *.*\n";
	print "  perl $PROG.$Extension [options] *.* > newfile\n";
	print "Options:\n";
	print "  -dnslookup     make a reverse DNS lookup on IP adresses\n";
#	print "  -dnslookup:n   same with a n parallel threads instead of $QueuePoolSize by default\n";
	print "  -dnscache=file make DNS lookup from cache file first before network lookup\n";
	print "  -showsteps     print on stderr benchmark information every $NBOFLINESFORBENCHMARK lines\n";
	print "  -addfilenum    if used with several files, file number can be added in first\n";
	print "                 field of output file. This can be used to add a cluster id\n";
	print "                 when log files comes from several load balanced computers.\n";
	print "\n";
	print "This runs $PROG in command line to open one or several web\n";
	print "server log files to merge them (sorted on date) and/or to make a reverse\n";
	print "DNS lookup. The result log file is sent on standard output.\n";
	print "Note: $PROG is not a 'sort' tool to sort one file. It's a\n";
	print "software able to output sorted log records (with a reverse DNS lookup\n";
	print "made if wanted) even if log records are shaked in several files.\n";
	print "However each of thoose files must be already independently sorted itself\n";
	print "(but that is the case in all web server log files).\n";
	print "$PROG is particularly usefull when you want to merge large log\n";
	print "files in a fast process and with a low use of memory getting records in a\n";
	print "chronological order through a pipe (for use by third tool, like log analyzer).\n";
	print "\n";
	print "WARNING: If log files are old MAC text files (lines ended with CR char), you\n";
	print "can't run this tool on Win or Unix platforms.\n";
	print "\n";
	print "Now supports/detects:\n";
	print "  Automatic detection of log format\n";
	print "  Files can be .gz/.bz2 files if zcat/bzcat tools are available in PATH.\n";
#	print "  Multithreaded reverse DNS lookup (several parallel requests)\n";
#	print "  No need of extra Perl library\n";
	print "New versions and FAQ at http://awstats.sourceforge.net\n";
	exit 0;
}

# Get current time
my $nowtime=time;
my ($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear) = localtime($nowtime);
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
my $nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
if (++$nowmonth < 10) { $nowmonth = "0$nowmonth"; }
if ($nowday < 10) { $nowday = "0$nowday"; }
if ($nowhour < 10) { $nowhour = "0$nowhour"; }
if ($nowmin < 10) { $nowmin = "0$nowmin"; }
if ($nowsec < 10) { $nowsec = "0$nowsec"; }
# Get tomorrow time (will be used to discard some record with corrupted date (future date))
my ($tomorrowsec,$tomorrowmin,$tomorrowhour,$tomorrowday,$tomorrowmonth,$tomorrowyear) = localtime($nowtime+86400);
if ($tomorrowyear < 100) { $tomorrowyear+=2000; } else { $tomorrowyear+=1900; }
my $tomorrowsmallyear=$tomorrowyear;$tomorrowsmallyear =~ s/^..//;
if (++$tomorrowmonth < 10) { $tomorrowmonth = "0$tomorrowmonth"; }
if ($tomorrowday < 10) { $tomorrowday = "0$tomorrowday"; }
if ($tomorrowhour < 10) { $tomorrowhour = "0$tomorrowhour"; }
if ($tomorrowmin < 10) { $tomorrowmin = "0$tomorrowmin"; }
if ($tomorrowsec < 10) { $tomorrowsec = "0$tomorrowsec"; }
my $timetomorrow=$tomorrowyear.$tomorrowmonth.$tomorrowday.$tomorrowhour.$tomorrowmin.$tomorrowsec;	

# Init other parameters
$NBOFLINESFORBENCHMARK--;
if ($ENV{"GATEWAY_INTERFACE"}) { $DirCgi=''; }
if ($DirCgi && !($DirCgi =~ /\/$/) && !($DirCgi =~ /\\$/)) { $DirCgi .= '/'; }
if (! $DirData || $DirData eq '.') { $DirData=$DIR; }	# If not defined or choosed to "." value then DirData is current dir
if (! $DirData)  { $DirData='.'; }						# If current dir not defined then we put it to "."
$DirData =~ s/\/$//;
if ($DNSLookup) { use Socket; }
#my %monthlib =  ( "01","$Message[60]","02","$Message[61]","03","$Message[62]","04","$Message[63]","05","$Message[64]","06","$Message[65]","07","$Message[66]","08","$Message[67]","09","$Message[68]","10","$Message[69]","11","$Message[70]","12","$Message[71]" );
# monthnum must be in english because it's used to translate log date in apache log files which are always in english
my %monthnum =  ( "Jan","01","jan","01","Feb","02","feb","02","Mar","03","mar","03","Apr","04","apr","04","May","05","may","05","Jun","06","jun","06","Jul","07","jul","07","Aug","08","aug","08","Sep","09","sep","09","Oct","10","oct","10","Nov","11","nov","11","Dec","12","dec","12" );

&debug("DNSLookup=$DNSLookup");
&debug("DNSCache=$DNSCache");

if ($DNSCache) {
	&debug("Load DNS Cache file $DNSCache",2);
	open(CACHE, "<$DNSCache") or error("Can't open cache file $DNSCache");
	while (<CACHE>) {
		my ($time, $ip, $name) = split;
		$name='ip' if $name eq '*';
		$MyDNSTable{$ip}=$name;
	}
	close CACHE;
}

#-----------------------------------------------------------------------------
# PROCESSING CURRENT LOG(s)
#-----------------------------------------------------------------------------
my %LogFileToDo=();
my $NbOfLinesRead=0;
my $NbOfLinesParsed=0;
my $logfilechosen=0;
my $starttime=time();

# Define the LogFileToDo list
$cpt=1;
foreach my $key (0..(@ParamFile-1)) {
	if ($ParamFile[$key] !~ /\*/ && $ParamFile[$key] !~ /\?/) {
		&debug("Log file $ParamFile[$key] is added to LogFileToDo with number $cpt.");

		# Check for supported compression 
		if ($ParamFile[$key] =~ /$zcat_file/) {
			&debug("GZIP compression detected for Log file $ParamFile[$key].");
			# Modify the name to include the zcat command
			$ParamFile[$key] = $zcat . ' ' . $ParamFile[$key] . ' |';
		}
		elsif ($ParamFile[$key] =~ /$bzcat_file/) {
			&debug("BZ2 compression detected for Log file $ParamFile[$key].");
			# Modify the name to include the bzcat command
			$ParamFile[$key] = $bzcat . ' ' . $ParamFile[$key] . ' |';
		}

		$LogFileToDo{$cpt}=@ParamFile[$key];
		$cpt++;
	}
	else {
		my $DirFile=$ParamFile[$key]; $DirFile =~ s/([^\/\\]*)$//;
		$ParamFile[$key] = $1;
		if ($DirFile eq '') { $DirFile = '.'; }
		$ParamFile[$key] =~ s/\./\\\./g;
		$ParamFile[$key] =~ s/\*/\.\*/g;
		$ParamFile[$key] =~ s/\?/\./g;
		&debug("Search for file \"$ParamFile[$key]\" into \"$DirFile\"");
		opendir(DIR,"$DirFile");
		my @filearray = sort readdir DIR;
		close DIR;
		foreach my $i (0..$#filearray) {
			if ("$filearray[$i]" =~ /^$ParamFile[$key]$/ && "$filearray[$i]" ne "." && "$filearray[$i]" ne "..") {
				&debug("Log file $filearray[$i] is added to LogFileToDo with number $cpt.");
				$LogFileToDo{$cpt}="$DirFile/$filearray[$i]";
				$cpt++;
			}
		}
	}
}

# If no files to process
if (scalar keys %LogFileToDo == 0) {
	error("No input log file found");
}

# Open all log files
&debug("Start of processing ".(scalar keys %LogFileToDo)." log file(s)");
foreach my $logfilenb (keys %LogFileToDo) {
	&debug("Open log file number $logfilenb: \"$LogFileToDo{$logfilenb}\"");
	open("LOG$logfilenb","$LogFileToDo{$logfilenb}") || error("Couldn't open log file \"$LogFileToDo{$logfilenb}\" : $!");
	binmode "LOG$logfilenb";	# To avoid pb of corrupted text log files with binary chars.
}

my $QueueCursor=1;
while (1 == 1)
{
	# BEGIN Read new record (for each log file or only for log file with record just processed)
	#------------------------------------------------------------------------------------------
	foreach my $logfilenb (keys %LogFileToDo) {
		if (($logfilechosen == 0) || ($logfilechosen == $logfilenb)) {
			&debug("Search next record in file number $logfilenb",3);
			# Read chosen log file until we found a record with good date or reaching end of file
			while (1 == 1) {
				my $LOG="LOG$logfilenb";
				$_=<$LOG>;	# Read new line
				if (! $_) {							# No more records in log file number $logfilenb
					&debug(" No more records in file number $logfilenb",2);
					delete $LogFileToDo{$logfilenb};
					last;
				}

				$NbOfLinesRead++;
				chomp $_; s/\r$//;

				if (/^#/) { next; }									# Ignore comment lines (ISS writes such comments)
				if (/^!!/) { next; }								# Ignore comment lines (Webstar writes such comments)
				if (/^$/) { next; }									# Ignore blank lines (With ISS: happens sometimes, with Apache: possible when editing log file)

				$linerecord{$logfilenb}=$_; 

				# Check filters
				#----------------------------------------------------------------------

				# Split DD/Month/YYYY:HH:MM:SS or YYYY-MM-DD HH:MM:SS or MM/DD/YY\tHH:MM:SS
				my $year=0; my $month=0; my $day=0; my $hour=0; my $minute=0; my $second=0;
				if ($_ =~ /(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/) { $year=$1; $month=$2; $day=$3; $hour=$4; $minute=$5; $second=$6; }
				if ($_ =~ /\[(\d\d)[\/:\s](\w+)[\/:\s](\d\d\d\d)[\/:\s](\d\d)[\/:\s](\d\d)[\/:\s](\d\d) /) { $year=$3; $month=$2; $day=$1; $hour=$4; $minute=$5; $second=$6; }
				if ($_ =~ /\[\w+ (\w+) (\d\d) (\d\d)[\/:\s](\d\d)[\/:\s](\d\d) (\d\d\d\d)\]/) { $year=$6; $month=$1; $day=$2; $hour=$3; $minute=$4; $second=$5; }

				if ($monthnum{$month}) { $month=$monthnum{$month}; }	# Change lib month in num month if necessary

				# Create $timerecord like YYYYMMDDHHMMSS
		 		$timerecord{$logfilenb}=int("$year$month$day$hour$minute$second");
				if ($timerecord{$logfilenb}<10000000000000) {
					&debug(" This record is corrupted (no date found)",3);
					$corrupted{$logfilenb}++;
					next;
				}
				&debug(" This is next record for file $logfilenb : timerecord=$timerecord{$logfilenb}",3);
				last;
			}
		}
	}
	# END Read new lines for each log file. After this, following var are filled
	# $timerecord{$logfilenb}

	# We choose wich record of wich log file to process
	&debug("Choose of wich record of which log file to process",3);
	$logfilechosen=-1;
	my $timeref="99999999999999";
	foreach my $logfilenb (keys %LogFileToDo) {
		&debug(" timerecord for file $logfilenb is $timerecord{$logfilenb}",4);
		if ($timerecord{$logfilenb} < $timeref) { $logfilechosen=$logfilenb; $timeref=$timerecord{$logfilenb} }
	}
	if ($logfilechosen <= 0) { last; }								# No more record to process
	# Record is chosen
	&debug(" We choosed to qualify record of file number $logfilechosen",3);
	&debug("  Record is $linerecord{$logfilechosen}",3);
			
	# Record is approved. We found a new line to parse in file number $logfilechosen
	#-------------------------------------------------------------------------------
	$NbOfLinesParsed++;
	if ($ShowSteps) {
		if ((++$NbOfLinesShowsteps & $NBOFLINESFORBENCHMARK) == 0) {
			my $delay=(time()-$starttime)||1;
			print STDERR "$NbOfLinesParsed lines processed (".(1000*$delay)." ms, ".int($NbOfLinesShowsteps/$delay)." lines/seconds)\n";
		}
	}

	# Do DNS lookup
	#--------------------
	my $Host='';
	my $HostResolved='';
	my $ip=0;
	if ($DNSLookup) {			# DNS lookup is 1 or 2
		if ($linerecord{$logfilechosen} =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/) { $ip=4; $Host=$1; }	# IPv4
		elsif ($linerecord{$logfilechosen} =~ /([0-9A-F]*:)/i) { $ip=6; $Host=$1; }						# IPv6
		if ($ip) {
			# Check in static DNS cache file
			$HostResolved=$MyDNSTable{$Host};
			if ($HostResolved) {
				if ($Debug) { debug("  DNS lookup asked for $Host and found in static DNS cache file: $HostResolved",4); }
			}
			elsif ($DNSLookup==1) {
				# Check in session cache (dynamic DNS cache file + session DNS cache)
				$HostResolved=$TmpDNSLookup{$Host};
				if (! $HostResolved) {
					if (@SkipDNSLookupFor && &SkipDNSLookup($Host)) {
						$HostResolved=$TmpDNSLookup{$Host}='*';
						if ($Debug) { debug("  No need of reverse DNS lookup for $Host, skipped at user request.",4); }
					}
					else {
						if ($ip == 4) {
							# Create or not a new thread						
							if (! $USETHREADS) {
								my $lookupresult=gethostbyaddr(pack("C4",split(/\./,$Host)),AF_INET);	# This is very slow, may took 20 seconds
								if (! $lookupresult || $lookupresult =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ || ! IsAscii($lookupresult)) {
									$TmpDNSLookup{$Host}=$HostResolved='*';
								}
								else {
									$TmpDNSLookup{$Host}=$HostResolved=$lookupresult;
								}
								if ($Debug) { debug("  Reverse DNS lookup for $Host done: $HostResolved",4); }
							} else {
#								my $t = new Thread \&MakeDNSLookup, $Host;
								if ($Debug) { &debug(" Reverse DNS lookup for $Host queued",4); }
								# Here, this is the only way, $HostResolved and $TmpDNSLookup{$Host} is not defined
							}				
						}
						elsif ($ip == 6) {
							$TmpDNSLookup{$Host}=$HostResolved='*';
							if ($Debug) { debug("  Reverse DNS lookup for $Host not available for IPv6",4); }
						}
						else { error("Bad value vor ip"); }
					}
				}
			}
			else {
				$HostResolved='*';
				if ($Debug) { debug("  DNS lookup by static DNS cache file asked for $Host but not found.",4); }
			}
		}
		else {
			if ($Debug) { debug("  DNS lookup asked for $Host but this is not an IP address.",4); }
			$DNSLookupAlreadyDone=$LogFileToDo{$logfilechosen};
		}
	}
	else {
		if ($linerecord{$logfilechosen} =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/) { $HostResolved='*'; $ip=4; $Host=$1; }	# IPv4
		elsif ($linerecord{$logfilechosen} =~ /([0-9A-F]*:)/i) { $HostResolved='*'; $ip=6; $Host=$1; }						# IPv6
		if ($Debug) { debug("  No DNS lookup asked.",4); }
	}

	# Put record in queue
	debug("Add record $NbOfLinesParsed in queue (with host value ".($Host?$Host:'*').")",4);
	$QueueRecords{$NbOfLinesParsed}=$linerecord{$logfilechosen};
	# If there is a host to resolve, we add line to queue with value of HostResolved
	# $Host is '' (no ip found) or is ip
	if ($DNSLookup==0) {
		$QueueHostsToResolve{$NbOfLinesParsed}='*';
	}
	if ($DNSLookup==1) { 
		$QueueHostsToResolve{$NbOfLinesParsed}=$Host?$Host:'*';
	}
	if ($DNSLookup==2) { 
		# If ($HostResolved ne '*' and $Host) then MyDNSTable is defined for $Host
		$QueueHostsToResolve{$NbOfLinesParsed}=($Host && $HostResolved ne '*')?$Host:'*';
	}

	# Print all records in head of queue that are ready
	debug("Check head of queue to write records ready to flush (QueueCursor=$QueueCursor, QueueSize=".(scalar keys %QueueRecords).")",4);
	while ( $QueueHostsToResolve{$QueueCursor} && ( ($QueueHostsToResolve{$QueueCursor} eq '*') || ($MyDNSTable{$QueueHostsToResolve{$QueueCursor}}) || ($TmpDNSLookup{$QueueHostsToResolve{$QueueCursor}}) ) ) {
		# $QueueCursor point to a ready record
		if ($QueueHostsToResolve{$QueueCursor} eq '*') {
			debug(" First elem in queue is ready. No change on it. We pull it.",4);
		}
		else {
			if ($MyDNSTable{$QueueHostsToResolve{$QueueCursor}}) {
				if ($MyDNSTable{$QueueHostsToResolve{$QueueCursor}} ne '*') {
					$QueueRecords{$QueueCursor}=~s/$QueueHostsToResolve{$QueueCursor}/$MyDNSTable{$QueueHostsToResolve{$QueueCursor}}/;
					debug(" First elem in queue has been resolved ($MyDNSTable{$QueueHostsToResolve{$QueueCursor}}). We pull it.",4);
				}
			}
			elsif ($TmpDNSLookup{$QueueHostsToResolve{$QueueCursor}}) {
				if ($TmpDNSLookup{$QueueHostsToResolve{$QueueCursor}} ne '*') {
					$QueueRecords{$QueueCursor}=~s/$QueueHostsToResolve{$QueueCursor}/$TmpDNSLookup{$QueueHostsToResolve{$QueueCursor}}/;
					debug(" First elem in queue has been resolved ($TmpDNSLookup{$QueueHostsToResolve{$QueueCursor}}). We pull it.",4);
				}
			}
		}
		# Record is ready, we output it.
		if ($AddFileNum) { print "$logfilechosen $QueueRecords{$QueueCursor}\n"; }
		else { print "$QueueRecords{$QueueCursor}\n"; }
		delete $QueueRecords{$QueueCursor};
		delete $QueueHostsToResolve{$QueueCursor};
		$QueueCursor++;
	}

	# End of processing new record. Loop on next one.
}
&debug("End of processing log file(s)");

# Close all log files
foreach my $logfilenb (keys %LogFileToDo) {
	&debug("Close log file number $logfilenb");
	close("LOG$logfilenb") || error("Command for pipe '$LogFileToDo{$logfilenb}' failed");
}

# Waiting queue is empty




# DNSLookup warning
if ($DNSLookup==1 && $DNSLookupAlreadyDone) {
	warning("Warning: $PROG has detected that some host names were already resolved in your logfile $DNSLookupAlreadyDone.\nIf DNS lookup was already made by the logger (web server) in ALL your log files, you should not use -dnslookup option to increase $PROG speed.");
}

#if ($DNSCache) {
#	open(CACHE, ">$DNSCache") or die;
#	foreach (keys %TmpDNSLookup) {
#		$TmpDNSLookup{$_}="*" if $TmpDNSLookup{$_} eq "ip";
#		print CACHE "0\t$_\t$TmpDNSLookup{$_}\n";
#	}
#	close CACHE;
#}

0;	# Do not remove this line

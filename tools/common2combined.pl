#!/usr/bin/perl
# With some other Unix Os, first line may be
#!/usr/local/bin/perl
# With Apache for Windows and ActiverPerl, first line may be
#!C:/Program Files/ActiveState/bin/perl
#-Description-------------------------------------------
# Convert a common log file into a combined.
# This tool is part of AWStats log analyzer but can be use
# alone for any other log analyzer.
# See COPYING.TXT file about AWStats GNU General Public License.
#-------------------------------------------------------
use strict; no strict "refs";
#use diagnostics;


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
# Last change made by $Author$ on $Date$
my $REVISION='$Revision$';
$REVISION =~ /\s(.*)\s/; $REVISION=$1;
my $VERSION="1.1 (build $REVISION)";

# ---------- Init variables --------
my $Debug=0;
my $ShowSteps=0;
my $DIR;
my $PROG;
my $Extension;
my $DNSLookup=0;
my $DirCgi="";
my $DirData="";
my $NbOfLinesForBenchmark=5000;
my $NewReferer="-";		#$NewReferer="http://www.referersite.com/refererpage.html";
my $NewUserAgent="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)";
my $nowtime = my $nowweekofmonth = my $nowdaymod = my $nowsmallyear = 0; 
my $nowsec = my $nowmin = my $nowhour = my $nowday = my $nowmonth = my $nowyear = my $nowwday = 0;
# ---------- Init hash arrays --------
my %ParamFile=();
my %linerecord=();
my %timeconnexion=();
my %corrupted=();



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



#-------------------------------------------------------
# MAIN
#-------------------------------------------------------
my $QueryString=""; for (0..@ARGV-1) { $QueryString .= "$ARGV[$_] "; }
if ($QueryString =~ /debug=/i) { $Debug=$QueryString; $Debug =~ s/.*debug=//; $Debug =~ s/&.*//; $Debug =~ s/ .*//; }
if ($QueryString =~ /dnslookup/i) { $DNSLookup=1; }
if ($QueryString =~ /showsteps/i) { $ShowSteps=1; }
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;

my $cpt=1;
for (0..@ARGV-1) {
	if ($ARGV[$_] =~ /^-/) { last; }
	$ParamFile{$cpt}=$ARGV[$_];
	$cpt++;
}
if (scalar keys %ParamFile == 0) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG converts any Apache 'common' log file into a 'combined' file.\n";
	print "$PROG comes with ABSOLUTELY NO WARRANTY. It's a free software\n";
	print "distributed with a GNU General Public License (See COPYING.txt file).\n";
	print "$PROG is part of AWStats but can be used alone for any need.\n";
	print "\n";
	print "Value used for the 2 new fields added in conversion are :\n";
	print "New referer    : \"$NewReferer\"\n";
	print "New user Agent : \"$NewUserAgent\"\n";
	print "\n";
	print "Usage:\n";
	print "  $PROG.$Extension oldfile.log > newfile.log\n";
	print "\n";
	print "Options:\n";
	print "  -showsteps  to add benchmark informations every $NbOfLinesForBenchmark lines processed\n";
	print "\n";
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
if ($ENV{"GATEWAY_INTERFACE"}) { $DirCgi=""; }
if ($DirCgi && !($DirCgi =~ /\/$/) && !($DirCgi =~ /\\$/)) { $DirCgi .= "/"; }
if (! $DirData || $DirData eq ".") { $DirData=$DIR; }	# If not defined or choosed to "." value then DirData is current dir
if (! $DirData)  { $DirData="."; }						# If current dir not defined then we put it to "."
$DirData =~ s/\/$//;
if ($DNSLookup) { use Socket; }
#my %monthlib =  ( "01","$message[60]","02","$message[61]","03","$message[62]","04","$message[63]","05","$message[64]","06","$message[65]","07","$message[66]","08","$message[67]","09","$message[68]","10","$message[69]","11","$message[70]","12","$message[71]" );
# monthnum must be in english because it's used to translate log date in apache log files which are always in english
my %monthnum =  ( "Jan","01","jan","01","Feb","02","feb","02","Mar","03","mar","03","Apr","04","apr","04","May","05","may","05","Jun","06","jun","06","Jul","07","jul","07","Aug","08","aug","08","Sep","09","sep","09","Oct","10","oct","10","Nov","11","nov","11","Dec","12","dec","12" );

#------------------------------------------
# PROCESSING CURRENT LOG(s)
#------------------------------------------
my %LogFileToDo=(); my %NowNewLinePhase=(); my %NbOfLinesRead=(); my %NbOfLinesCorrupted=();
my $NbOfNewLinesProcessed=0;
my $NbOfNewLinesCorrupted=0;
my $logfilechosen=0;
my $starttime=time();

# Define the LogFileToDo list
$cpt=1;
foreach my $key (keys %ParamFile) {
	if ($ParamFile{$key} !~ /\*/ && $ParamFile{$key} !~ /\?/) {
		&debug("Log file $ParamFile{$key} is added to LogFileToDo.");
		$LogFileToDo{$cpt}=$ParamFile{$key};
		$cpt++;
	}
	else {
		my $DirFile=$ParamFile{$key}; $DirFile =~ s/([^\/\\]*)$//;
		$ParamFile{$key} = $1;
		if ($DirFile eq "") { $DirFile = "."; }
		$ParamFile{$key} =~ s/\./\\\./g;
		$ParamFile{$key} =~ s/\*/\.\*/g;
		$ParamFile{$key} =~ s/\?/\./g;
		&debug("Search for file \"$ParamFile{$key}\" into \"$DirFile\"");
		opendir(DIR,"$DirFile");
		my @filearray = sort readdir DIR;
		close DIR;
		foreach my $i (0..$#filearray) {
			if ("$filearray[$i]" =~ /^$ParamFile{$key}$/ && "$filearray[$i]" ne "." && "$filearray[$i]" ne "..") {
				&debug("Log file $filearray[$i] is added to LogFileToDo.");
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
}

while (1 == 1)
{
	# BEGIN Read new record (for each log file or only for log file with record just processed)
	#------------------------------------------------------------------------------------------
	foreach my $logfilenb (keys %LogFileToDo) {
		if (($logfilechosen == 0) || ($logfilechosen == $logfilenb)) {
			&debug("Search next record in file number $logfilenb",3);
			# Read chosen log file until we found a record with good date or reaching end of file
			while (1 == 1) {
				my $LOG="LOG$logfilenb"; $_=<$LOG>;	# Read new line
				if (! $_) {							# No more records in log file number $logfilenb
					&debug(" No more records in file number $logfilenb",2);
					delete $LogFileToDo{$logfilenb};
					last; }											# We have all the new records for each other files, we stop here

				chomp $_; s/\r//;

				if (/^#/) { next; }									# Ignore comment lines (ISS writes such comments)
				if (/^!!/) { next; }								# Ignore comment lines (Webstar writes such comments)
				if (/^$/) { next; }									# Ignore blank lines (With ISS: happens sometimes, with Apache: possible when editing log file)

				$NbOfLinesRead{$logfilenb}++;

				# Check filters
				#----------------------------------------------------------------------
				# Split DD/Month/YYYY:HH:MM:SS or YYYY-MM-DD HH:MM:SS or MM/DD/YY\tHH:MM:SS
				$linerecord{$logfilenb}=$_; 
				my $year=0; my $month=0; my $day=0; my $hour=0; my $minute=0; my $second=0;
				if ($_ =~ /(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/) { $year=$1; $month=$2; $day=$3; $hour=$4; $minute=$5; $second=$6; }
				if ($_ =~ /\[(\d\d)\/(.*)\/(\d\d\d\d):(\d\d):(\d\d):(\d\d) /) { $year=$3; $month=$2; $day=$1; $hour=$4; $minute=$5; $second=$6; }
				if ($monthnum{$month}) { $month=$monthnum{$month}; }	# Change lib month in num month if necessary

				# Create $timeconnexion like YYYYMMDDHHMMSS
		 		$timeconnexion{$logfilenb}=int("$year$month$day$hour$minute$second");
				if ($timeconnexion{$logfilenb}<10000000000000) {
					&debug(" This record is corrupted (no date found)",3);
					$corrupted{$logfilenb}++;
					next;
				}
				&debug(" This is next record for file $logfilenb : timeconnexion=$timeconnexion{$logfilenb}",3);
				last;
			}
		}
	}
	# END Read new lines for each log file. After this, following var are filled
	# $timeconnexion{$logfilenb}
	
	# We choose wich record of wich log file to process
	&debug("Choose of wich record of which log file to process",3);
	$logfilechosen=-1;
	my $timeref="99999999999999";
	foreach my $logfilenb (keys %LogFileToDo) {
		&debug(" timeconnexion for file $logfilenb is $timeconnexion{$logfilenb}",4);
		if ($timeconnexion{$logfilenb} < $timeref) { $logfilechosen=$logfilenb; $timeref=$timeconnexion{$logfilenb} }
	}
	if ($logfilechosen <= 0) { last; }								# No more record to process
	# Record is chosen
	&debug(" We choosed to analyze record of file number $logfilechosen",3);
	&debug(" Record is $linerecord{$logfilechosen}",3);
			
	# Record is approved. We found a new line to process in file number $logfilechosen
	#----------------------------------------------------------------------------------
	$NbOfNewLinesProcessed++;
	if (($ShowSteps) && ($NbOfNewLinesProcessed % $NbOfLinesForBenchmark == 0)) { print STDERR "$NbOfNewLinesProcessed lines processed (".(time()-$starttime)." seconds, ".($NbOfNewLinesProcessed/(time()-$starttime))." lines/seconds)\n"; }

	# Print record if ready
	print "$linerecord{$logfilechosen} \"$NewReferer\" \"$NewUserAgent\"\n";

	# End of processing all new records.
}
&debug("End of processing log file(s)");


# Close all log files
foreach my $logfilenb (keys %LogFileToDo) {
	&debug("Close log file number $logfilenb");
	close("LOG$logfilenb");
}


0;	# Do not remove this line

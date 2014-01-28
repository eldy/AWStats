#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Free addition to AWStats Web Log Analyzer. Used to export the contents of
# sections of the Apache server log database to CSV for use in other tools.
# Works from command line or as a CGI. 
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
#------------------------------------------------------------------------------
use CGI qw(:standard);

my $ALLOWDOWNLOAD=0;

# Disabled by default for security reason
if (! $ALLOWDOWNLOAD) 
{
	print("Error: You must first edit script to change ALLOWDOWNLOAD to 1 to allow usage of this script.\n");
	print("Reason is that enabling this script may be a security hole as it allows someone to download/view details of your awstats data files.\n");
	exit;
}

my $q               = new CGI;
my $outputFile      = "";   # used to write the output to a file
my $inputFile       = "";   # the fully qualified path to the input log database file
my $sectionToReport = "";   # contains the tag to search for in the database file
my $startSearchStr  = "BEGIN_";
my $endSearchStr    = "END_";
my $startPrinting   = 0;    # flag to indicate that the start tag has been found
my $attachFileName  = "";

# These parameters are used to build the input file name of the awstats log database
my $baseName        = "";
my $month           = "";
my $year            = "";
my $day             = "";
my $siteConfig      = "";

if ($q->param("outputFile")) {
  if ($outputFile eq '') { $outputFile = $q->param("outputFile"); }
}

if ($q->param("inputFile")) {
  if ($inputFile eq '') { $inputFile = $q->param("inputFile"); }
}

if ($q->param("section")) {
  if ($sectionToReport eq '' ) { $sectionToReport = $q->param("section"); }
}

if ($q->param("baseName")) {
  if ($baseName eq '' ) { $baseName = $q->param("baseName"); }
}

if ($q->param("month")) {
  if ($month eq '' ) { $month = $q->param("month"); }
}

if ($q->param("year")) {
  if ($year eq '' ) { $year = $q->param("year"); }
}

if ($q->param("day")) { $day = $q->param("day"); }

if ($q->param("siteConfig")) {
  if ($siteConfig eq '' ) { $siteConfig = $q->param("siteConfig"); }
}

# set the attachment file name to the report section
if ($sectionToReport ne '' ) {
  $attachFileName = $sectionToReport . ".csv";
} else {
  $attachFileName = "exportCSV.csv";
}
print $q->header(-type=> "application/force-download", -attachment=>$attachFileName);

# Build the start/end search tags
$startSearchStr = $startSearchStr . $sectionToReport;
$endSearchStr   = $endSearchStr . $sectionToReport;

if ( !$inputFile ) { $inputFile ="$baseName$month$year$day.$siteConfig.txt" };

open (IN, $inputFile) || die "cannot open $inputFile\n";

# If there's a parameter for the output, open it here
if ($outputFile ne '') {
  open (OUT,">$outputFile") || die "cannot create $outputFile\n";
  flock (OUT, 2);
}
# Loop through the input file searching for the start string. When
# found, start displaying the input lines (with spaces changed
# to commas) until the end tag is found.

# Array to store comments for printing once we hit the desired section
my $commentCount = -1;
my %commentArray;

while (<IN>) {
  chomp;

  if (/^#\s(.*-)\s/){    # search for comment lines
    s/ - /,/g;   # replace dashes with commas
    s/#//;       # get rid of the comment sign
    $commentArray[++$commentCount] = $_;
  }

  # put the test to end printing here to eliminate printing
  # the line with the END tag
  if (/^$endSearchStr\b/) {
    $startPrinting = 0;
  }

  if ($startPrinting) {
    s/ /,/g;
    print "$_\n";
    if ($outputFile ne '') {
      print OUT "$_\n";
    }
  }
  # if we find an END tag and we haven't started printing, reset the
  # comment array to start re-capturing comments for next section
  if ((/^END_/) && ($startPrinting == 0)) {
    $commentCount = -1;
  }

  # put the start printing test after the first input line
  # to eliminate printing the line with the BEGIN tag...find it
  # here, then start printing on the next input line
  if (/^$startSearchStr\b/) {
    $startPrinting = 1;
    # print the comment array - it provides labels for the columns
    for ($i = 0; $i <= $commentCount; $i++ ) {
    print "$commentArray[$i]\n";
    }
  }
}

close(IN);

# Close the output file if there was one used
if ($outputFile ne '') {
  close(OUT);
}

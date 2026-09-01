#!/usr/bin/perl
#
###        anonlog 1.0.1             http://anonlog.sourceforge.net/
### This program is copyright (c) Stephen R. E. Turner 2000-2002.
### It is free software; you can redistribute it and/or modify
### it under the terms of version 2 of the GNU General Public License as
### published by the Free Software Foundation.
###
### This program is distributed in the hope that it will be useful,
### but without any warranty; without even the implied warranty of
### merchantability or fitness for a particular purpose.  See the
### GNU General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program; if not, see http://www.gnu.org/copyleft/gpl.html
### or write to the Free Software Foundation, Inc., 59 Temple Place,
### Suite 330, Boston, MA 02111-1307, USA

require 5.004;  # for rand()
use strict;
my ($conffile, $logfile, $logformat, $newlog, $dictionary, $translations,
    $servernames, $unchfiles, $matchlength,
    $case_sensitive, $usercase_sensitive);

# ======== User-settable parameters start here ======== #
#
# NB All parameters can also be set in the configuration file, $conffile,
# normally anonlog.cfg. This is usually more convenient. The variables here
# have the same names as those in anonlog.cfg (with the addition of a $ at
# the front). So see Readme.html for documentation on the various options.
#
# On Unix, you can edit the top line of this program to give the location of
# Perl on your system. (Try 'which perl' to find out).
#
# The configuration file to override all these options.
# $conffile = ''; for none.
$conffile = 'anonlog.cfg';

$logfile = 'logfile.log';
$newlog = '';
$servernames = '';
$logformat = '';
$dictionary = 'dictionary';
$translations = '';
$unchfiles = 'index.html';
$matchlength = 0;
$case_sensitive = 1;
$usercase_sensitive = 0;

# ======== User-settable parameters end here ======== #

my $progname = $0 || 'anonlog';
my $version = '1.0.1';  # version of this program
my $progurl = 'http://anonlog.sourceforge.net/';

# All legal domain names
my @domains = ("ad", "ae", "af", "ag", "ai", "al", "am", "an", "ao", "aq",
	       "ar", "as", "at", "au", "aw", "az", "ba", "bb", "bd", "be",
	       "bf", "bg", "bh", "bi", "bj", "bm", "bn", "bo", "br", "bs",
	       "bt", "bv", "bw", "by", "bz", "ca", "cc", "cd", "cf", "cg",
	       "ch", "ci", "ck", "cl", "cm", "cn", "co", "com", "cr", "cs",
	       "cu", "cv", "cx", "cy", "cz", "de", "dj", "dk", "dm", "do",
	       "dz", "ec", "edu", "ee", "eg", "eh", "er", "es", "et", "fi",
	       "fj", "fk", "fm", "fo", "fr", "fx", "ga", "gb", "gd", "ge",
	       "gf", "gg", "gh", "gi", "gl", "gm", "gn", "gov", "gp", "gq",
	       "gr", "gs", "gt", "gu", "gw", "gy", "hk", "hm", "hn", "hr",
	       "ht", "hu", "id", "ie", "il", "im", "in", "int", "io", "iq",
	       "ir", "is", "it", "je", "jm", "jo", "jp", "ke", "kg", "kh",
	       "ki", "km", "kn", "kp", "kr", "kw", "ky", "kz", "la", "lb",
	       "lc", "li", "lk", "lr", "ls", "lt", "lu", "lv", "ly", "ma",
	       "mc", "md", "mg", "mh", "mil", "mk", "ml", "mm", "mn", "mo",
	       "mp", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my",
	       "mz", "na", "nc", "ne", "net", "nf", "ng", "ni", "nl", "no",
	       "np", "nr", "nu", "nz", "om", "org", "pa", "pe", "pf", "pg",
	       "ph", "pk", "pl", "pm", "pn", "pr", "pt", "pw", "py", "qa",
	       "re", "ro", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg",
	       "sh", "si", "sj", "sk", "sl", "sm", "sn", "so", "sr", "st",
	       "su", "sv", "sy", "sz", "tc", "td", "tf", "tg", "th", "tj",
	       "tk", "tm", "tn", "to", "tp", "tr", "tt", "tv", "tw", "tz",
	       "ua", "ug", "uk", "um", "us", "uy", "uz", "va", "vc", "ve",
	       "vg", "vi", "vn", "vu", "wf", "ws", "ye", "yt", "yu", "za",
	       "zm", "zr", "zw");
my $no_tries = 100;    # See random_entry() and random_string()
my $no_tries2 = 2000;
my $width = 35;        # See writeout
my $firstline;

my @data;
# @data has the folloing components:
# 0 = host; 1 = user; 2 = date/time; 3 = HTTP method; 4 = filename;
# 5 = HTTP version / W3SVC string; 6 = HTTP status code; 7 = bytes sent;
# 8 = referrer; 9 = browser; 10 = virtual hostname; 11 = processing time;
# 12 = bytes received, 13 = IIS status; 14 = search args;
# 15 = time separate from date.
my (%hosttree, %filetree, %reftree, %usertree, %vhosttree);
my (@servernames, @unchfiles, @dict);

# Now all log formats

my ($format, @tokens, $outstr);

my $commonfmt = <<'HERE';
    (\S*)\            # host
    \S+\              # (unused)
    (\S+)\            # user
    \[([^\]]+)\]\     # date and time
    \"\s*([A-Za-z]+)\s+(.+?)(?:\s+(HTTP\/\d.\d))?\s*\"\   # request line
    (\d{3})\          # status code
    (\d+|-)           # bytes
HERE
my @commontokens = (0..7);
my $commonout = "%s - %s [%s] \"%s %s %s\" %s %s";

my $combfmt = <<'HERE';
    (\S*)\            # host
    \S+\              # (unused)
    (\S+)\            # user
    \[([^\]]+)\]\     # date and time
    \"\s*([A-Za-z]+)\s+(.+?)(?:\s+(HTTP\/\d.\d))?\s*\"\   # request line
    (\d{3})\          # status code
    (\d+|-)\          # bytes
    \"(.*)\"\         # referrer
    \"([^\"]*)\"      # browser
HERE
my @combtokens = (0..9);
my $combout = "%s - %s [%s] \"%s %s %s\" %s %s \"%s\" \"%s\"";

my $proftpd = <<'HERE';
    \[([^\]]+)\]\     # date and time
    (\S+)\            # host
    (\S+)\            # user
    (\S+)\s(.*)\       # request line
    (\d{3})\          # status code
    (\d+|-)           # bytes
HERE
my @proftpdtokens = (2, 0, 1, 3, 4, 6, 7);
my $proftpdout = "[%s] %s %s %s %s %s %s";

my $iisfmt = <<'HERE';
    ([^,]*),\             # host
    ([^,]*),\             # user
    ([^,]*,\ [^,]*),\     # date and time
    (W3SVC[^,]*),\        # W3SVC line
    ([^,]*),\             # server name
    [^,]*,\               # server address
    (\d+|-),\             # processing time
    (\d+|-),\             # bytes received
    (\d+|-),\             # bytes sent
    (\d{3}|-),\           # HTTP status code
    ([^,]*),\             # IIS status
    ([^,]*),\             # Operation
    ([^,]*),\             # Filename
    ([^,]*),\ ?           # Search args
HERE
my @iistokens = (0..2, 5, 10..12, 7, 6, 13, 3, 4, 14);
my $iisout = "%s, %s, %s, %s, %s, -, %s, %s, %s, %s, %s, %s, %s, %s,";

my $msext = 0;   # Whether extended format is genuine or Microsoft version

# ======== End of global declarations, start of main program ======== #

if ($conffile) {
    open(CONFFILE, $conffile) ||
	die "$progname: Cannot open configuration file $conffile: $!\n";
    parse_config();
}

open(LOGFILE, $logfile) || die "$progname: Cannot open logfile $logfile: $!\n";
if ($newlog eq '') { $newlog = '-'; }
open(NEWLOG, ">$newlog") ||
    die "$progname: Cannot write to new logfile $newlog: $!\n";

@servernames = split(/,\s*/, $servernames);
@unchfiles = split(/,\s*/, $unchfiles);

if ($dictionary) {
    unless (open(DICT, $dictionary)) {
	warn "$progname: Cannot open dictionary $dictionary: $!\n";
    } else { construct_dict(); }
}

# == End of initialisation, now process logfile == #

$firstline = 1;
while (<LOGFILE>) {
    if ($firstline) {
	detect_format();
	$firstline = 0;
    }
    if ($logformat eq 'extended' && /^\#/) {
	# special case: extended format, line beginning with #
	if (/^\#Fields:\s/) { parse_extfmt(); }
	print NEWLOG;
    }
    else {
	@data[@tokens] = /^$format$/x;
	unless (defined($data[$tokens[0]])) {
	    print STDERR "$progname: Unparseable line: ";
	    print STDERR;
	}
	else {
	    $data[0] = anon_host($data[0]);
	    $data[4] = anon_file($data[4]);
	    $data[8] = anon_referrer($data[8]);
	    $data[1] = anon_user($data[1]);
	    $data[10] = anon_vhost($data[10]);
	    if ($data[14] ne '' && $data[14] ne '-') { $data[14] = 'args'; }
	    printf NEWLOG "$outstr\n", @data[@tokens];
	}
    }
}

# == Finished processing logfile, finally output translations == #

if ($translations) {
    unless (open(TRANS, ">$translations")) {
	warn "$progname: Cannot write to translation file $translations: $!\n";
    } else {
	if (%filetree) {
	    print TRANS "** FILES **\n\n";
	    writeout(\%filetree, 1, '/', 1, 1);
	}
	if (%hosttree) {
	    print TRANS "\n** HOSTS **\n\n";
	    writeout(\%hosttree, 2, '.', 0, 0);
	}
	if (%reftree) {
	    print TRANS "\n** REFERRERS **\n\n";
	    writeout(\%reftree, 1, '/', 0, 0);
	}
	if (%usertree) {
	    print TRANS "\n** USERS **\n\n";
	    writeout(\%usertree, 1, '', 0, 0);
	}
	if (%vhosttree) {
	    print TRANS "\n** VIRTUAL HOSTS **\n\n";
	    writeout(\%vhosttree, 1, '', 0, 0);
	}
    }
}

# ======== End of main program. Rest is subroutines. ======== #

# Parse the configuration file.
sub parse_config {
    my ($name, $value);

    while (<CONFFILE>) {
	chomp;
	s/\#.*$//;    # Remove comments
	if (/\S/) {   # If any non-space character left on line
	    ($name, $value) = /^\s*(.*?)\s*=\s*(.*?)\s*$/;
	    $name =~ tr/A-Z/a-z/;
	    if (!defined($name)) {
		warn "$progname: Can't parse configuration line: $_\n";
	    }
	    elsif ($name eq 'logfile' && $value ne '') { $logfile = $value }
	    elsif ($name eq 'logformat') { $logformat = $value }
	    elsif ($name eq 'newlog') { $newlog = $value }
	    elsif ($name eq 'dictionary') { $dictionary = $value }
	    elsif ($name eq 'translations') { $translations = $value }
	    elsif ($name eq 'servernames') { $servernames = $value }
	    elsif ($name eq 'unchfiles') { $unchfiles = $value }
	    elsif ($name eq 'matchlength' &&
		   ($value eq '0' || $value == '1')) {
		$matchlength = $value;
	    }
	    elsif ($name eq 'case_sensitive' &&
		   ($value eq '0' || $value == '1')) {
		$case_sensitive = $value;
	    }
	    elsif ($name eq 'usercase_sensitive' &&
		   ($value eq '0' || $value == '1')) {
		$usercase_sensitive = $value;
	    }
	    else {
		warn "$progname: Can't understand configuration line: $_\n";
	    }
	}
    }
}

# Construct the dictionary.
sub construct_dict {
    local $_;
    my ($w, $d, $i, $tmp, @words, @ignore, %h);

    while (<DICT>) { $w .= $_ }
    @words = split(/\s+/, $w);
    @ignore = map(/^([^.]*)/, @unchfiles);
    # @ignore contains the 'index' in index.html (or index.html.gz or index)
    # We delete them from the dictionary below (could instead be careful in
    # lookup_or_create_filename, but this is easier and faster).
    foreach (@ignore) { tr/A-Z/a-z/; }
    # Put words of length l into the array at $dict[l].
    foreach (@words) {
	tr/A-Z/a-z/;
	$tmp = $_;
	$i = $matchlength?length():0;
	push(@{$dict[$i]}, $_)  # Take only words, and not in @ignore
	    unless (/[^a-z]/ || grep($tmp eq $_, @ignore));
    }
    foreach $d (@dict) { if ($d == undef) { @$d = (); }}
}

# Detect logfile format from first line. (NB Line is already in (global) $_ ).
sub detect_format {
    my $i;

    unless ($logformat) {
	if ((split /,\s*/) == 15) { $logformat = 'iis'; }
	elsif (($i = index($_, '[')) >= 6 && substr($_, $i + 27, 1) eq ']' &&
	       index($_, '"') == $i + 29) {
	    if (($i = split(/\"/)) == 3) { $logformat = 'common'; }
	    elsif ($i == 7) { $logformat = 'combined'; }
	}
	elsif (/^\#/) { $logformat = 'extended'; }
	unless ($logformat) { die "$progname: Can't detect format of logfile $logfile from first line: specify it in $conffile\n"; }
    }

    $logformat =~ tr/A-Z/a-z/;
    if ($logformat eq 'common') {
	print STDERR "$progname: Reading $logfile in common format\n";
	$format = $commonfmt;
	@tokens = @commontokens;
	$outstr = $commonout;
    }
    elsif ($logformat eq 'combined') {
	print STDERR "$progname: Reading $logfile in combined format\n";
	$format = $combfmt;
	@tokens = @combtokens;
	$outstr = $combout;
    }
    elsif ($logformat eq 'proftpd') {
	print STDERR "$progname: Reading $logfile in proftpd format\n";
	$format = $proftpd;
	@tokens = @proftpdtokens;
	$outstr = $proftpdout;
    }
    elsif ($logformat eq 'iis') {
	print STDERR "$progname: Reading $logfile in IIS format\n";
	$format = $iisfmt;
	@tokens = @iistokens;
	$outstr = $iisout;
    }
    elsif ($logformat eq 'extended' || $logformat eq 'ms-extended') {
	# In this case, have to construct the log format from the #Fields line
	if ($logformat eq 'ms-extended') { $msext = 1; }
	$logformat = 'extended';
	while (/^\#/) {   # process all # lines before handing back
	    if (/^\#Software: Microsoft Internet Information Serv/) {
		$msext = 1;
	    }
	    elsif (/^\#Fields:\s/) { parse_extfmt(); }
	    print NEWLOG;
	    $_ = <LOGFILE>;
	}
	print NEWLOG "#Remark: Logfile anonymized by anonlog $version, $progurl\n";
	if ($msext) { print STDERR "$progname: Reading $logfile in Microsoft extended format\n"; }
	else { print STDERR "$progname: Reading $logfile in W3C extended format\n"; }
    }
    else { die "$progname: Don't know what you mean by 'logformat = $logformat' in $conffile\n"; }
}

# Parse the #Fields: line from an extended format logfile. The #Fields: line
# is already in (global) $_ .
sub parse_extfmt { 
    my ($i, $first);

    $format = '';
    @tokens = ();
    $outstr = '';
    $first = 1;

    foreach $i (split(' ', substr($_, 9))) {  # substr skips "#Fields: " itself
	if ($first) { $first = 0; }
	else { $format .= '\s+'; $outstr .= "\t"; }
	$i =~ tr/A-Z/a-z/;
	if ($i eq 'date') {
	    $format .= '(\d{4}-\d{2}-\d{2})';
	    push(@tokens, 2);
	    $outstr .= '%s';
	}
	elsif ($i eq 'time') {
	    $format .= '(\d{2}:\d{2}(?::\d{2}(?:\.\d*)?)?)';
	    push(@tokens, 15);
	    $outstr .= '%s';
	}
	elsif ($i eq 'bytes' || $i eq 'sc-bytes') {
	    $format .= '(\d+|-)';
	    push(@tokens, 7);
	    $outstr .= '%d';
	}
	elsif ($i eq 'cs-bytes') {
	    $format .= '(\d+|-)';
	    push(@tokens, 12);
	    $outstr .= '%d';
	}
	elsif ($i eq 'sc-status') {
	    $format .= '(\d{3})';
	    push(@tokens, 6);
	    $outstr .= '%d';
	}
	elsif ($i eq 'c-dns' || $i eq 'cs-dns' ||
	       $i eq 'c-ip' || $i eq 'cs-ip') {
	    $format .= '(\S+)';
	    push(@tokens, 0);
	    $outstr .= '%s';
	}
	elsif ($i eq 'cs-uri' || $i eq 'cs-uri-stem') {
	    $format .= '(\S+)';
	    push(@tokens, 4);
	    $outstr .= '%s';
	}
	elsif ($i eq 'cs(referer)') {
	    if ($msext) { $format .= '(\S+)'; $outstr .= '%s'; }
	    else { $format .= '\"(.*?)\"'; $outstr .= '"%s"'; }
	    push(@tokens, 8);
	}
	elsif ($i eq 'cs(user-agent)') {
	    if ($msext) { $format .= '(\S+)'; $outstr .= '%s'; }
	    else { $format .= '\"(.*?)\"'; $outstr .= '"%s"'; }
	    push(@tokens, 9);
	}
	elsif ($i eq 'cs-host' || $i eq 's-ip' || $i eq 's-dns' ||
	       $i eq 'cs-sip' || $i eq 's-sitename' ||
	       $i eq 's-computername') {
	    $format .= '(\S+)';
	    push(@tokens, 10);
	    $outstr .= '%s';
	}
	elsif ($i eq 'cs(host)') {
	    $format .= '\"(.*?)\"';
	    push(@tokens, 10);
	    $outstr .= '"%s"';
	}
	elsif ($i eq 'cs-uri-query') {
	    $format .= '(\S+)';
	    push(@tokens, 14);
	    $outstr .= '%s';
	}
	elsif ($i eq 'cs-username') {
	    $format .= '(\S+)';
	    push(@tokens, 1);
	    $outstr .= '%s';
	}
	elsif ($i eq 'cs(from)') {
	    $format .= '\"(.*?)\"';
	    push(@tokens, 1);
	    $outstr .= '"%s"';
	}
	elsif ($i eq 'time-taken') {
	    $format .= '([\d\.]+|-)';
	    push(@tokens, 11);
	    $outstr .= '%s';
	}
	elsif ($i eq 'cs-method') {
	    $format .= '([A-Za-z]+)';
	    push(@tokens, 3);
	    $outstr .= '%s';
	}
	else {  # unknown token
	    $format .= '\S+';
	    $outstr .= '-';
	}
    }
}

# The anonymizing functions
#
# The translations are looked up in a tree. Each node of the tree is a hash
# as follows:
# Keys: The part of the name being translated
# Values: A 2-element \array (translation, \hash of the same type recursively)
#
# All these functions work the same way.
# They are called with one argument from the main part of the
# program, a second argument (\sub-hash) when called recursively.
# The name is split into two components, $b to be translated immediately
# and $a, the rest. $b's (translation, \subhash) is assigned to @b.
sub anon_host {
    local $_ = $_[0];
    my @b;
    my $numhost = 0;
    if (!defined($_[1])) { tr/A-Z/a-z/; }
    if (/\.$/) { $_ = substr($_, 0, length($_) - 1); } # strip trailing dot
    my ($a, $b) = /^(.*)\.(.*)$/;
    if (!defined($b)) { $a = ''; $b = $_; }  # if no dot in (sub-)name

    if (defined($_[1])) { @b = lookup_or_create($b, \%{$_[1]}); }
    else {
	if ($_ eq '' || $_ eq '-') { return '-'; }
	my($n1, $n2, $n3, $n4) =
	    /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
 	if (defined($n1) && $n1 <= 255 && $n2 <= 255 && $n3 <= 255 &&
	    $n4 <= 255) { return(anon_numhost($_, \%hosttree)); }
	if (!/\./ && !grep($b eq $_, @domains)) {  # no dot in whole name
	    @b = lookup_or_create($b, \%hosttree);
	} else { @b = lookup_or_create($b, \%hosttree, \@domains); }
    }

    if ($a eq '') { return($b[0]); }
    else { return(anon_host($a, $b[1]) . '.' . $b[0]); }
}

sub anon_numhost {     # Numerical hostnames
    local $_ = $_[0];
    my @b;
    my ($b, $a) = /^(.*?)\.(.*)$/;
    if (!defined($b)) { $a = ''; $b = $_; }
    my @newnumber = (rand255($_[1]));
    @b = lookup_or_create($b, $_[1], \@newnumber);
    if ($a eq '') { return($b[0]); }
    else { return($b[0] . '.' . anon_numhost($a, $b[1])); }
}

# anon_file also takes an optional argument number 2, overriding global
# $case_sensitive. If it is present, initial stripping of anchors and search
# arguments is also performed (because it is also used only on the first call
# for that data, in this case a referrer).
sub anon_file {
    local $_ = $_[0];
    my $args = '';
    my $case = $case_sensitive;
    my (@b, @tmp, $ans);
    if (!defined($_[1]) || defined($_[2])) {
	s/\#.*//;  # remove anchors
	if (s/\?.*//) { $args = '?args'; }
	s/%([\da-fA-F]{2})/pack("C", hex($1))/ge;  # change %7E to ~ etc.
	if (defined($_[2])) { $case = $_[2]; }
	if (!$case) { tr/A-Z/a-z/; }
    }

    my ($b, $a) = m[^/(.*?)(/.*)$];
    if (!defined($b)) {  # not two slashes in name
	if (!m[^/]) { return '-'; }
	# top level should always begin with slash, and lower levels forced to
	$b = substr($_, 1);
	if ($b eq '') { return "/$args"; }
	if (grep($b eq $_, @unchfiles)) { return "/$b$args"; }
	if (defined($_[1])) { @b = lookup_or_create_filename($b, \%{$_[1]}); }
	else { @b = lookup_or_create_filename($b, \%filetree); }
	return("/$b[0]$args");
    }
    # rest only reached if there were two slashes in name
    if ($b eq '.' || $b eq '..') {  # special case: leave these alone
	@tmp = ($b);
	if (defined($_[1])) { @b = lookup_or_create($b, \%{$_[1]}, \@tmp); }
	else { @b = lookup_or_create($b, \%filetree, \@tmp); }
    }
    elsif (defined($_[1])) { @b = lookup_or_create($b, \%{$_[1]}); }
    else { @b = lookup_or_create($b, \%filetree); }
    return("/$b[0]" . anon_file($a, $b[1]) . $args);
}

# Referrers are a bit different because they're split into 3 parts:
# a scheme, a hostname and a filename. We only allow through http: and
# ftp: URLs. If the hostname is in the list of known $servernames, we preserve
# the hostname and use the existing local translations for the filename part.
# Otherwise we translate the hostname according to the existing hosttree, and
# use this as the root for the referrer tree.
sub anon_referrer {
    local $_ = $_[0];
    my @b;
    my ($scheme, $hostname, $port, $path) = m[^(.*?)://(.*?)(:.*?)?(/.*)$];

    if (!defined($scheme) || $scheme !~ /^(ht|f)tp/i) { return "-"; }
    $scheme =~ tr/A-Z/a-z/;
    if ($hostname =~ /\.$/) {  # strip trailing dot
	$hostname = substr($hostname, 0, length($hostname) - 1);
    }
    if (grep($_ eq $hostname, @servernames)) {
	return($scheme . '://' . $hostname . anon_file($path));
    }
    else {
	my @newhost = (anon_host($hostname));
	@b = lookup_or_create($hostname, \%reftree, \@newhost);
	return("$scheme://$b[0]$port" . anon_file($path, $b[1], 1));
    }
}

sub anon_user {   # users and virtual hosts aren't hierarchical
    local $_ = $_[0];
    my @b;

    if ($_ eq '' || $_ eq '-') { return '-'; }
    if (!$usercase_sensitive) { tr/A-Z/a-z/; }
    @b = lookup_or_create($_, \%usertree);
    return($b[0]);
}

sub anon_vhost {
    local $_ = $_[0];
    my @b;

    if ($_ eq '' || $_ eq '-') { return '-'; }
    tr/A-Z/a-z/;
    @b = lookup_or_create($_, \%vhosttree);
    return($b[0]);
}

# Look up an item (arg 0) in a tree node (arg 1), or create a new entry if
# necessary. The entry is selected from array arg 2 if present, else from
# dictionary entry of correct length, else a random string of correct length.
# See also lookup_or_create_filename below.
sub lookup_or_create {
    my $n = $_[0];
    my (@ans, %h);

    unless (defined(${$_[1]}{$n})) {
	if (defined($_[2])) { $ans[0] = random_entry($_[2], $_[1]); }
	else {
	    $ans[0] = random_entry($dict[$matchlength?length($n):0], $_[1]);
	}
	unless (defined($ans[0])) {
	    $ans[0] = random_string(length($n), $_[1]);
	}
	# Start hash table so it isn't undef later
	$h{''} = undef;
	$ans[1] = \%h;
	${$_[1]}{$n} = \@ans;
    }
    return(@{${$_[1]}{$n}});
}

# The same as lookup_or_create above, but preserves the extension of filenames.
# (Actually, this is never called with 3 args, but we leave it in for possible
# future use, and to keep it parallel with the previous function).
sub lookup_or_create_filename {
    local $_ = $_[0];
    my (@ans, %h);

    unless (defined(${$_[1]}{$_})) {
        my ($name, $ext) = m[^(.*)(\..*)$];
	if (!defined($name)) { $ext = ''; $name = $_; }  # no extension
	if (defined($_[2])) { $ans[0] = random_entry($_[2], $_[1], $ext); }
	else {
	    $ans[0] = random_entry($dict[$matchlength?length($name):0], $_[1],
				   $ext);
	}
	unless (defined($ans[0])) {
	    $ans[0] = random_string(length($name), $_[1], $ext);
	}
	$h{''} = undef;
	$ans[1] = \%h;
	${$_[1]}{$_} = \@ans;
    }
    return(@{${$_[1]}{$_}});
}

# Select a random entry from array arg 0, but must not occur as value in hash
# arg 1. If failed after $no_tries, give up and return undef.
# If arg 2 exists, then the random entry is "arg0_element . arg2" instead.
sub random_entry {
    if ($_[0] == undef) { return undef; }
    my @l = @{$_[0]};
    my @v = values(%{$_[1]});
    my ($ans, $k);

    if (@l == ()) { return undef; }
    for ($k = 0;
	 (!defined($ans) || grep {$ans eq ${$_}[0]} @v) && $k < $no_tries;
	 $k++) { $ans = $l[rand($#l + 0.9999999)] . $_[2]; }
    if ($k < $no_tries) { return($ans); }
    else { return undef; }
}

# Create random string, length given by arg 0 (unless global $matchlength is
# false), again must not occur as value in hash arg 1. Same arg2 as in
# random_entry. This time if failed after $no_tries2, return any answer.
sub random_string {
    my $l = $_[0];
    my @v = values(%{$_[1]});
    my ($ans, $i, $j, $k);

    if ($l == 0) { return(''); }
    unless ($matchlength) { $l = int(5 + rand(6)); }  # i.e. 5 to 10
    for ($k = 0;
	 (!defined($ans) || grep {$ans eq ${$_}[0]} @v) && $k < $no_tries2;
	 $k++) {
	$ans = '';
	for ($i = 0; $i < $l; $i++) {
	    $j = 65 + rand(52);
	    if ($j >= 91) { $j += 6; }
	    $ans .= chr($j);
	}
	$ans .= $_[2];
    }
    return($ans);
}

# Select a random number from 0 to 255, but again not already occurring as
# value in hash (arg 0). This should never fail in the context of this
# program, but we use $no_tries2 again just in case.
sub rand255 {
    my @v = values(%{$_[0]});
    my ($ans, $k);

    for ($k = 0;
	 (!defined($ans) || grep {$ans == ${$_}[0]} @v) && $k < $no_tries2;
	 $k++) { $ans = int(rand(255.9999999)); }
    return($ans);
}

# Write out the translations to file TRANS.
# The 0th argument is the \hash to be interpreted;
# The 1st argument is 0 if the name-parts are collated backwards, 1 if
# forwards, 2 if they are hostnames (backwards unless numerical);
# The 2nd argument is the delimiter between name-parts, or empty string if they
# are not hierarchical.
# The 3rd argument says whether the delimiter should also occur at the start of
# the string.
# The 4th argument says whether the entry should still be printed if it is
# not (known to be) a leaf.
# The 5th and 6th arguments, if present, are the up-tree name-parts for the
# original and translated names respectively.
sub writeout {
    my %hash = %{$_[0]};
    my ($colorder, $delim, $initial, $printall) = ($_[1], $_[2], $_[3], $_[4]);
    my ($partname_old, $partname_new) = ($_[5], $_[6]);
    my ($name, @value, $name_new, $name_old, $newcolord, $fieldwidth);

    foreach $name (sort {  # Declare sort order inline so we can use %hash
	# The first case is binned immediately below, but must catch here too
	(!defined($hash{$a}) || !defined($hash{$b}))?(lc($a) cmp lc($b)):
        (((${$hash{$a}}[0] + 0) <=> (${$hash{$b}}[0] + 0)) ||
	# If they start with (or are) numbers, sort them that way
         (lc(${$hash{$a}}[0]) cmp lc(${$hash{$b}}[0])) || # Usual ordering
         (($a + 0) <=> ($b + 0)) ||    # Fallback to untranslated names: but by
         (lc($a) cmp lc($b)))  # construction this should (all but) never occur
    } keys(%hash)) {       # End of sort order. Phew.
	if (defined($hash{$name})) {
	    @value = @{$hash{$name}};
	    if ($colorder == 2) { $newcolord = (($name =~ /^\d{1,3}$/)?1:0); }
	    else { $newcolord = $colorder; }
	    # NB Incomplete test for numerical hostname (unlike in anon_host)
	    if ($newcolord == 1) {
		if (!$partname_old && !$initial) {
		    $name_new = "$value[0]";
		    $name_old = "$name";
		} else {
		    $name_new = "$partname_new$delim$value[0]";
		    $name_old = "$partname_old$delim$name";
		}
		$fieldwidth = -$width;
	    }
	    else {
		if (!$partname_old && !$initial) {
		    $name_new = "$value[0]";
		    $name_old = "$name";
		} else {
		    $name_new = "$value[0]$delim$partname_new";
		    $name_old = "$name$delim$partname_old";
		}
		$fieldwidth = $width;
	    }
            printf TRANS ("%*s  =  %*s\n",
                          $fieldwidth, $name_new, $fieldwidth, $name_old)
                if ($printall || keys(%{$value[1]}) <= 1);
	    writeout($value[1], $newcolord, $delim, $initial, $printall,
		     $name_old, $name_new);
	}
    }
}

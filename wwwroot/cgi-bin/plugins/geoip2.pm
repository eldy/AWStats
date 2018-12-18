#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GeoIp2 Maxmind AWStats plugin
# This plugin allow you to get country report with countries detected
# from a Geographical database (GeoIP2 internal database) instead of domain
# hostname suffix.
# Need the country database from Maxmind (free).
#-----------------------------------------------------------------------------
# Perl Required Module: GeoIP2::Database::Reader
#-----------------------------------------------------------------------------


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
use vars qw/ $type /;
$type='geoip2';
if (!eval ('require "GeoIP2/Database/Reader.pm";')) {
	$error=$@;
    $ret=($error)?"Error:\n$error":"";
    $ret.="Error: Need Perl module GeoIP2::Database::Reader";
    return $ret;
}
# GeoIP2 Perl API doesn't have a ByName lookup so we need to do the resolution ourselves
if (!eval ('require "Socket.pm";')) {
	$error=$@;
    $ret=($error)?"Error:\n$error":"";
    $ret.="Error: Need Perl module Socket";
    return $ret;
}
# ----->
#use strict;
no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.4";
my $PluginHooksFunctions="GetCountryCodeByAddr GetCountryCodeByName ShowInfoHost";
my $PluginName = "geoip2";
my $LoadedOverride=0;
my $OverrideFile="";
my %TmpDomainLookup;
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$reader
/;
use Data::Validate::IP 0.25 qw( is_private_ip );
# ----->


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_geoip2 {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin $PluginName: InitParams=$InitParams",1);
    my ($datafile,$override)=split(/\+/,$InitParams,2);
   	if (! $datafile) { $datafile="GeoLite2-Country.mmdb"; }
    else { $datafile =~ s/%20/ /g; }
	if ($override){$OverrideFile=$override;}
	%TmpDomainLookup=();
	debug(" Plugin $PluginName: GeoIP2 try to initialize override=$override datafile=$datafile",1);
	$reader = GeoIP2::Database::Reader->new(
        file    => $datafile,
        locales => [ 'en', 'de', ]
    );

	# Fails on some GeoIP version
	# debug(" Plugin $PluginName: GeoIP initialized database_info=".$reader->database_info());
	if ($reader) { debug(" Plugin $PluginName: GeoIP2 plugin and reader object initialized",1); }
	else { return "Error: Failed to create reader object for datafile=".$datafile; }
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByAddr_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByAddr is called to translate an ip into a country code in lower case.
#-----------------------------------------------------------------------------
sub GetCountryCodeByAddr_geoip2 {
    my $param="$_[0]";
	# <-----
	if (! $param) { return ''; }
	my $res= TmpLookup_geoip2($param);
	if (! $res) {
		if ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByAddr_geoip2 for $param",5); }
		$res=lc($reader->country( ip => $param )->country()->iso_code()) || 'unknown';
		$TmpDomainLookup{$param}=$res;
		if ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByAddr_geoip2 for $param: [$res]",5); }
	}
	elsif ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByAddr_geoip2 for $param: Already resolved to [$res]",5); }
	# ----->
	return $res;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByName_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByName is called to translate a host name into a country code in lower case.
#-----------------------------------------------------------------------------
sub GetCountryCodeByName_geoip2 {
    my $param="$_[0]";
	# <-----
	if (! $param) { return ''; }
	my $res = TmpLookup_geoip($param);
	if (! $res) {
        # First resolve the name to an IP
        $address = inet_ntoa(inet_aton($param));
		if ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByName_geoip2 $param resolved to $address",5); }
        # Now do the same lookup from the IP
		$res=lc($reader->country( ip => $address )->country()->iso_code()) || 'unknown';
		$TmpDomainLookup{$param}=$res;
		if ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByName_geoip2 for $param: [$res]",5); }
	}
	elsif ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByName_geoip2 for $param: Already resolved to [$res]",5); }
	# ----->
	return $res;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoHost_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal columns to the Hosts report.
# This function is called when building rows of the report (One call for each
# row). So it allows you to add a column in report, for example with code :
#   print "<TD>This is a new cell for $param</TD>";
# Parameters: Host name or ip
#-----------------------------------------------------------------------------
sub ShowInfoHost_geoip2 {
    my $param="$_[0]";
	# <-----
	if ($param eq '__title__') {
    	my $NewLinkParams=${QueryString};
    	$NewLinkParams =~ s/(^|&)update(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&)output(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&)staticlinks(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&)framename=[^&]*//i;
    	my $NewLinkTarget='';
    	if ($DetailedReportsOnNewWindows) { $NewLinkTarget=" target=\"awstatsbis\""; }
    	if (($FrameName eq 'mainleft' || $FrameName eq 'mainright') && $DetailedReportsOnNewWindows < 2) {
    		$NewLinkParams.="&framename=mainright";
    		$NewLinkTarget=" target=\"mainright\"";
    	}
    	$NewLinkParams =~ tr/&/&/s; $NewLinkParams =~ s/^&//; $NewLinkParams =~ s/&$//;
    	if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }

		print "<th width=\"80\">";
        print "<a href=\"#countries\">GeoIP2<br />Country</a>";
        print "</th>";
	}
	elsif ($param) {
        my $ip=0;
		my $key;
		if ($param =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {	# IPv4 address
		    $ip=4;
			$key=$param;
		}
		elsif ($param =~ /^[0-9A-F]*:/i) {						# IPv6 address
		    $ip=6;
			$key=$param;
		}
		print "<td>";
		if ($key && $ip==4) {
        	if ($Debug) { debug("  Plugin $PluginName: ShowInfoHost_geoip2 for $param key=$key ip=$ip",5); }
			my $res = TmpLookup_geoip2($param);
        	if (!$res){$res=lc($reader->country( ip => $param )->country()->iso_code()) if $reader;}
        	if ($Debug) { debug("  Plugin $PluginName: ShowInfoHost_geoip2 for $param: [$res]",5); }
		    if ($res) { print $DomainsHashIDLib{$res}?$DomainsHashIDLib{$res}:"<span style=\"color: #$color_other\">$Message[0]</span>"; }
		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
		}
		if ($key && $ip==6) {                              # GeoIP2 supports both IPv4 and IPv6
        	if ($Debug) { debug("  Plugin $PluginName: ShowInfoHost_geoip2 for $param key=$key ip=$ip",5); }
			my $res = TmpLookup_geoip2($param);
        	if (!$res){$res=lc($reader->country( ip => $param )->country()->iso_code()) if $reader;}
        	if ($Debug) { debug("  Plugin $PluginName: ShowInfoHost_geoip2 for $param: [$res]",5); }
		    if ($res) { print $DomainsHashIDLib{$res}?$DomainsHashIDLib{$res}:"<span style=\"color: #$color_other\">$Message[0]</span>"; }
		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
		}
		if (! $key) {
        	if ($Debug) { debug("  Plugin $PluginName: ShowInfoHost_geoip2 for $param key=$key ip=$ip",5); }
			my $res = TmpLookup_geoip2($param);
            # First resolve the name to an IP
            $address = inet_ntoa(inet_aton($param));
            if ($Debug) { debug("  Plugin $PluginName: ShowInfoHost_geoip2 $param resolved to $address",5); }
            # Now do the same lookup from the IP
            # GeoIP2::Reader doesn't support private IP addresses
            if (!is_private_ip($address)){
        	if (!$res){$res=lc($reader->country( ip => $address )->country()->iso_code()) if $reader;}
        	if ($Debug) { debug("  Plugin $PluginName: ShowInfoHost_geoip2 for $param: [$res]",5); }
		    if ($res) { print $DomainsHashIDLib{$res}?$DomainsHashIDLib{$res}:"<span style=\"color: #$color_other\">$Message[0]</span>"; }
		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
		}}
		print "</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	return 1;
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: LoadOverrideFile
# Attempts to load a comma delimited file that will override the GeoIP database
# Useful for Intranet records
# CSV format: IP,2-char Country code
#-----------------------------------------------------------------------------
sub LoadOverrideFile_geoip2{
	my $filetoload="";
	if ($OverrideFile){
		if (!open(GEOIPFILE, $OverrideFile)){
			debug("Plugin $PluginName: Unable to open override file: $OverrideFile");
			$LoadedOverride = 1;
			return;
		}
	}else{
		my $conf = (exists(&Get_Config_Name) ? Get_Config_Name() : $SiteConfig);
		if ($conf && open(GEOIPFILE,"$DirData/$PluginName.$conf.txt"))	{ $filetoload="$DirData/$PluginName.$conf.txt"; }
		elsif (open(GEOIPFILE,"$DirData/$PluginName.txt"))	{ $filetoload="$DirData/$PluginName.txt"; }
		else { debug("No override file \"$DirData/$PluginName.txt\": $!"); }
	}
	if ($filetoload)
	{
		# This is the fastest way to load with regexp that I know
		while (<GEOIPFILE>){
			chomp $_;
			s/\r//;
			my @record = split(",", $_);
			# replace quotes if they were used in the file
			foreach (@record){ $_ =~ s/"//g; }
			# store in hash
			$TmpDomainLookup{$record[0]} = $record[1];
		}
		close GEOIPFILE;
        debug(" Plugin $PluginName: Overload file loaded: ".(scalar keys %TmpDomainLookup)." entries found.");
	}
	$LoadedOverride = 1;
	return;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: TmpLookup
# Searches the temporary hash for the parameter value and returns the corresponding
# GEOIP entry
#-----------------------------------------------------------------------------
sub TmpLookup_geoip2(){
	$param = shift;
	if (!$LoadedOverride){&LoadOverrideFile_geoip2();}
	#my $val;
	#if ($reader &&
	#(($type eq 'geoip' && $reader->VERSION >= 1.30) || 
	#  $type eq 'geoippureperl' && $reader->VERSION >= 1.17)){
	#	$val = $TmpDomainLookup{$reader->get_ip_address($param)};
	#}
    #else {$val = $TmpDomainLookup{$param};}
    #return $val || '';
    return $TmpDomainLookup{$param}||'';
}

1;	# Do not remove this line

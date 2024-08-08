#!/usr/bin/perl
# extended geoip.pm by Sven Strickroth <email@cs-ware.de>
#-----------------------------------------------------------------------------
# GeoIP Maxmind AWStats plugin with IPv6 support
# This plugin allow you to get country report with countries detected
# from a Geographical database (GeoIP internal database) instead of domain
# hostname suffix.
# This works with IPv4 and also IPv6
# Needs the IPv6 country database from Maxmind (free).
#-----------------------------------------------------------------------------
# Perl Required Modules: Geo::IP (Geo::IP::PurePerl does not support IPv6 yet)
#-----------------------------------------------------------------------------

# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
use vars qw/ $type /;
$type='geoip';
if (!eval ('require "Geo/IP.pm";')) {
	$error1=$@;
#	$type='geoippureperl';
#	if (!eval ('require "Geo/IP/PurePerl.pm";')) {
#		$error2=$@;
#		$ret=($error1||$error2)?"Error:\n$error1$error2":"";
		$ret.="Error: Need Perl module Geo::IP";
		return $ret;
#	}
} else {
        Geo::IP->VERSION >= 1.40 || die("Requires Geo/IP.pm >= 1.40");
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
my $PluginName = "geoip6";
my $LoadedOverride=0;
my $OverrideFile="";
my %TmpDomainLookup;
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$gi
/;
# ----->


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_geoip6 {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin $PluginName: InitParams=$InitParams",1);
   	my ($mode,$tmpdatafile)=split(/\s+/,$InitParams,2);
   	my ($datafile,$override)=split(/\+/,$tmpdatafile,2);
   	if (! $datafile) { $datafile="$PluginName.dat"; }
    else { $datafile =~ s/%20/ /g; }
	if ($type eq 'geoippureperl') {
		if ($mode eq '' || $mode eq 'GEOIP_MEMORY_CACHE')  { $mode=Geo::IP::PurePerl::GEOIP_MEMORY_CACHE(); }
		else { $mode=Geo::IP::PurePerl::GEOIP_STANDARD(); }
	} else {
		if ($mode eq '' || $mode eq 'GEOIP_MEMORY_CACHE')  { $mode=Geo::IP::GEOIP_MEMORY_CACHE(); }
		else { $mode=Geo::IP::GEOIP_STANDARD(); }
	}
	if ($override){$OverrideFile=$override;}
	%TmpDomainLookup=();
	debug(" Plugin $PluginName: GeoIP initialized type=$type mode=$mode override=$override",1);
	if ($type eq 'geoippureperl') {
		$gi = Geo::IP::PurePerl->open($datafile, $mode);
	} else {
		$gi = Geo::IP->open($datafile, $mode);
	}

# Fails on some GeoIP version
# 	debug(" Plugin geoip6: GeoIP initialized database_info=".$gi->database_info());
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByAddr_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByAddr is called to translate an ip into a country code in lower case.
#-----------------------------------------------------------------------------
sub GetCountryCodeByAddr_geoip6 {
    my $param="$_[0]";
	# <-----
	if (! $param) { return ''; }
	my $searchkey;
	if ($param =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) { # IPv4 address
	        $searchkey = '::ffff:'.$param;
        } else {
                $searchkey = $param;
        }
	my $res= TmpLookup_geoip6($param);
	if (! $res) {
		$res=lc($gi->country_code_by_addr_v6($searchkey)) || 'unknown';
		$TmpDomainLookup{$param}=$res;
 		if ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByAddr for $searchkey: [$res]",5); }
	}
	elsif ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByAddr for $param: Already resolved to [$res]",5); }
	# ----->
	return $res;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByName_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByName is called to translate a host name into a country code in lower case.
#-----------------------------------------------------------------------------
sub GetCountryCodeByName_geoip6 {
    my $param="$_[0]";
	# <-----
	if (! $param) { return ''; }
	my $res = TmpLookup_geoip6($param);
	if (! $res) {
		$res=lc($gi->country_code_by_name_v6($param)) || 'unknown';
		$TmpDomainLookup{$param}=$res;
		if ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByName for $param: [$res]",5); }
	}
	elsif ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByName for $param: Already resolved to [$res]",5); }
	# ----->
	return $res;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoHost_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal columns to the Hosts report.
# This function is called when building rows of the report (One call for each
# row). So it allows you to add a column in report.
# The returned string is the content of the cell, the cell is build by AWStats.pl
# return code example: ### return "This is a new content for $param";
# 
# Parameters: Host name or ip
#-----------------------------------------------------------------------------
sub ShowInfoHost_geoip6 {
    my $param="$_[0]";
    my $noRes = $Message[56];

	# <-----
	if(!$param){ return $noRes; }

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

        return "GeoIP Country";
	}

	my $key;
	if ($param =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {	# IPv4 address
		$key='::ffff:'.$param;
	}
	elsif ($param =~ /^[0-9A-F]*:/i) {						# IPv6 address
		$key=$param;
	}

	my $res = TmpLookup_geoip6($param);

	if ($key)
	{
       	if (!$res && $gi) {
            $res=lc($gi->country_code_by_addr_v6($key));
        }
       	if ($Debug) { debug("  Plugin $PluginName: GetCountryByIp for $key: [$res]",5); }
	}
	else {
       	if (!$res){
       		$res=lc($gi->country_code_by_name_v6($param)) if $gi;
       	}
       	if ($Debug) { debug("  Plugin $PluginName: GetCountryByHostname for $param: [$res]",5); }
	}

	if ($res) {
    	return $DomainsHashIDLib{$res} ? $DomainsHashIDLib{$res} : $noRes;
    }

	return $noRes;
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: LoadOverrideFile
# Attempts to load a comma delimited file that will override the GeoIP database
# Useful for Intranet records
# CSV format: IP,2-char Country code
#-----------------------------------------------------------------------------
sub LoadOverrideFile_geoip6{
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
sub TmpLookup_geoip6(){
	$param = shift;
	if (!$LoadedOverride){&LoadOverrideFile_geoip6();}
	#my $val;
	#if ($gi &&
	#(($type eq 'geoip' && $gi->VERSION >= 1.30) || 
	#  $type eq 'geoippureperl' && $gi->VERSION >= 1.17)){
	#	$val = $TmpDomainLookup{$gi->get_ip_address($param)};
	#}
    #else {$val = $TmpDomainLookup{$param};}
    #return $val || '';
    return $TmpDomainLookup{$param}||'';
}

1;	# Do not remove this line

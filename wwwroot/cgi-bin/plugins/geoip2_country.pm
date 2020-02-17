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
$type='geoip2_country';
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
my $PluginName = "geoip2_country";
my $LoadedOverride=0;
my $OverrideFile="";
my %TmpDomainLookup;
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$reader
/;
use Data::Validate::IP 0.25 qw( is_public_ip );
# ----->


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_geoip2_country {
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
sub GetCountryCodeByAddr_geoip2_country {
	my $param = shift;
	if (! $param) { return ''; }
	my $res = Lookup_geoip2_country($param);
	return ($res) ? lc($res) : 'unknown';
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByName_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByName is called to translate a host name into a country code in lower case.
#-----------------------------------------------------------------------------
sub GetCountryCodeByName_geoip2_country {
	return GetCountryCodeByAddr_geoip2_country(@_);
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
sub ShowInfoHost_geoip2_country {
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
		my $res = Lookup_geoip2_country($param);
		if ($res) {
				$res = lc($res);
				print $DomainsHashIDLib{$res}?$DomainsHashIDLib{$res}:"<span style=\"color: #$color_other\">$Message[0]</span>";
		}
		else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
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
sub LoadOverrideFile_geoip2_country{
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
# PLUGIN FUNCTION: Lookup
# Looks up the input parameter (either ip address or dns name) and returns its
# associated country code; or undefined if not available.
# GEOIP entry
#-----------------------------------------------------------------------------
sub Lookup_geoip2_country {
	$param = shift;
	if (!$LoadedOverride) { &LoadOverrideFile_geoip2_country(); }
	if ($Debug) { debug("  Plugin $PluginName: Lookup_geoip2_country for $param",5); }
	if ($reader && !exists($TmpDomainLookup{$param})) {
		$TmpDomainLookup{$param} = undef; # negative entry to avoid repeated lookups
		# Resolve the parameter (either a name or an ip address) to a list of network addresses
		my ($err, @result) = Socket::getaddrinfo($param, undef, { protocol => Socket::IPPROTO_TCP, socktype => Socket::SOCK_STREAM });
		for (@result) {
			# Convert the network address to human-readable form
			my ($err, $address, $servicename) = Socket::getnameinfo($_->{addr}, Socket::NI_NUMERICHOST, Socket::NIx_NOSERV);
			next if ($err || !is_public_ip($address));

			if ($Debug && $param ne $address) { debug("  Plugin $PluginName: Lookup_geoip2_country $param resolved to $address",5); }
			eval {
				my $record = $reader->country(ip => $address);
				$TmpDomainLookup{$param} = $record->country()->iso_code();
				last;
			}
		}
	}
	my $res = $TmpDomainLookup{$param};
	if ($Debug) { debug("  Plugin $PluginName: Lookup_geoip2_country for $param: [$res]",5); }
	return $res;
}

1;	# Do not remove this line

#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GeoIp Maxmind AWStats plugin
# This plugin allow you to get country report with countries detected
# from a Geographical database (GeoIP internal database) instead of domain
# hostname suffix.
# Need the country database from Maxmind (free).
#-----------------------------------------------------------------------------
# Perl Required Modules: Geo::IP or Geo::IP::PurePerl
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
use vars qw/ $type /;
$type='geoip';
if (!eval ('require "Geo/IP.pm";')) 	{
	$type='geoippureperl';
	if (!eval ('require "Geo/IP/PurePerl.pm";')) { return $@?"Error: $@":"Error: Need Perl module Geo::IP or Geo::IP::PurePerl"; }
}
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.4";
my $PluginHooksFunctions="GetCountryCodeByAddr GetCountryCodeByName";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
%TmpDomainLookup
$gi
/;
# ----->


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_geoip {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin geoip: InitParams=$InitParams",1);
	my $mode=$InitParams;
	if ($type eq 'geoippureperl') {
		if ($mode eq '' || $mode eq 'GEOIP_MEMORY_CACHE')  { $mode=Geo::IP::PurePerl::GEOIP_MEMORY_CACHE(); }
		else { $mode=Geo::IP::PurePerl::GEOIP_STANDARD(); }
	} else {
		if ($mode eq '' || $mode eq 'GEOIP_MEMORY_CACHE')  { $mode=Geo::IP::GEOIP_MEMORY_CACHE(); }
		else { $mode=Geo::IP::GEOIP_STANDARD(); }
	}
	%TmpDomainLookup=();
	debug(" Plugin geoip: GeoIP initialized in mode $type $mode",1);
	if ($type eq 'geoippureperl') {
		$gi = Geo::IP::PurePerl->new($mode);
	} else {
		$gi = Geo::IP->new($mode);
	}
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByName_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByName is called to translate a host name into a country name.
#-----------------------------------------------------------------------------
sub GetCountryCodeByName_geoip {
    my $param="$_[0]";
	# <-----
	my $res=$TmpDomainLookup{$param}||'';
	if (! $res) {
		$res=lc($gi->country_code_by_name($param));
		$TmpDomainLookup{$param}=$res;
		if ($Debug) { debug("  Plugin geoip: GetCountryCodeByName for $param: [$res]",5); }
	}
	elsif ($Debug) { debug("  Plugin geoip: GetCountryCodeByName for $param: Already resolved to $res",5); }
	# ----->
	return $res;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByAddr_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByAddr is called to translate an ip into a country name.
#-----------------------------------------------------------------------------
sub GetCountryCodeByAddr_geoip {
    my $param="$_[0]";
	# <-----
	my $res=$TmpDomainLookup{$param}||'';
	if (! $res) {
		$res=lc($gi->country_code_by_addr($param));
		$TmpDomainLookup{$param}=$res;
		if ($Debug) { debug("  Plugin geoip: GetCountryCodeByAddr for $param: $res",5); }
	}
	elsif ($Debug) { debug("  Plugin geoip: GetCountryCodeByAddr for $param: Already resolved to $res",5); }
	# ----->
	return $res;
}


1;	# Do not remove this line

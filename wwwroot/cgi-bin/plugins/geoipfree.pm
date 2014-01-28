#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GeoIpFree AWStats plugin
# This plugin allow you to get AWStats country report with countries detected
# from a Geographical database (GeoIP internal database) instead of domain
# hostname suffix.
#-----------------------------------------------------------------------------
# Perl Required Modules: Geo::IPfree (version 0.2+)
#-----------------------------------------------------------------------------


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
push @INC, "${DIR}/plugins";
if (!eval ('require "Geo/IPfree.pm";')) { return $@?"Error: $@":"Error: Need Perl module Geo::IPfree"; }
# ----->
#use strict;
no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.5";
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
sub Init_geoipfree {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin geoipfree: InitParams=$InitParams",1);
	%TmpDomainLookup=();
	$gi = Geo::IPfree->new();
#	$gi->Faster; 	# Do not enable Faster as the Memoize module is rarely available
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByName_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByName is called to translate a host name into a country name.
#-----------------------------------------------------------------------------
sub GetCountryCodeByName_geoipfree {
    my $param="$_[0]";
	# <-----
	my $res=$TmpDomainLookup{$param}||'';
	if (! $res) {
		($res,undef)=$gi->LookUp($param);
		if ($res !~ /\w\w/) { $res='ip'; }
		else { $res=lc($res); }
		$TmpDomainLookup{$param}=$res;
		if ($Debug) { debug("  Plugin geoipfree: GetCountryCodeByName for $param: $res",5); }
	}
	elsif ($Debug) { debug("  Plugin geoipfree: GetCountryCodeByName for $param: Already resolved to $res",5); }
	# ----->
	return $res;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByAddr_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByAddr is called to translate an ip into a country name.
#-----------------------------------------------------------------------------
sub GetCountryCodeByAddr_geoipfree {
    my $param="$_[0]";
	# <-----
	my $res=$TmpDomainLookup{$param}||'';
	if (! $res) {
		($res,undef)=$gi->LookUp($param);
		if ($res !~ /\w\w/) { $res='ip'; }
		else { $res=lc($res); }
		$TmpDomainLookup{$param}=$res;
		if ($Debug) { debug("  Plugin geoipfree: GetCountryCodeByAddr for $param: $res",5); }
	}
	elsif ($Debug) { debug("  Plugin geoipfree: GetCountryCodeByAddr for $param: Already resolved to $res",5); }
	# ----->
	return $res;
}

1;	# Do not remove this line


# Internal IP address:
# 10.x.x.x
# 192.168.x.x


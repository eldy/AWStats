#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GeoIp AWStats plugin
# This plugin allow you to get AWStats country report with countries detected
# from a Geographical database (GeoIP internal database) instead of domain
# hostname suffix.
#-----------------------------------------------------------------------------
# Perl Required Modules: Geo::IP
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
use Geo::IP;
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.2";
my $PluginHooksFunctions="GetCountryCodeByAddr GetCountryCodeByName";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$gi
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNTION Init_pluginname
#-----------------------------------------------------------------------------
sub Init_geoip {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# YOU CAN ENTER HERE CODE TO INIT PLUGIN GLOBAL VARIABLES
	debug(" InitParams=$InitParams",1);
#	$gi = Geo::IP->new(GEOIP_STANDARD);
	$gi = Geo::IP->new(GEOIP_MEMORY_CACHE);
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNTION GetCountryCodeByName_pluginname
# UNIQUE: YES (Only one function GetCountryName can exists for all loaded plugins)
# GetCountryName is called to translate a host name or ip to a country name.
#-----------------------------------------------------------------------------
sub GetCountryCodeByName_geoip {
	# <-----
	$_[0]=lc($gi->country_code_by_name($_[0]));
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNTION GetCountryCodeByAddr_pluginname
# UNIQUE: YES (Only one function GetCountryName can exists for all loaded plugins)
# GetCountryName is called to translate a host name or ip to a country name.
#-----------------------------------------------------------------------------
sub GetCountryCodeByAddr_geoip {
	# <-----
	$_[0]=lc($gi->country_code_by_addr($_[0]));
	# ----->
}


1;	# Do not remove this line

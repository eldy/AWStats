#!/usr/bin/perl
#-----------------------------------------------------------------------------
# TimeZone AWStats plugin
# Allow AWStats to correct a bad timezone for user of IIS that use strange
# log format.
#-----------------------------------------------------------------------------
# Perl Required Modules: None
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!! This plugin reduces AWStats speed by 40% !!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#use Time::Local 'timelocal_nocheck';
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
my $PluginNeedAWStatsVersion="5.1";
my $PluginHooksFunctions="ChangeTime GetTimeZoneTitle";

use vars qw/
$PluginTimeZoneSeconds
/;


#-----------------------------------------------------------------------------
# PLUGIN FUNTION Init_pluginname
#-----------------------------------------------------------------------------
sub Init_timezone {
	my $AWStatsVersion=shift;
	my $TZ=shift;
	if (! $TZ) { return "Error: Disable plugin if TimeZone is 0 (Plugin useless)"; }	# We do not need this plugin if TZ=0
	$PluginTimeZoneSeconds=($TZ*3600);
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNTION ChangeTime_pluginname
#-----------------------------------------------------------------------------
sub ChangeTime_timezone {
	my $dateparts=shift;
	my ($nsec,$nmin,$nhour,$nmday,$nmon,$nyear,$nwday) = localtime(Time::Local::timelocal(@$dateparts[5], @$dateparts[4], @$dateparts[3], @$dateparts[0], @$dateparts[1]-1, @$dateparts[2]-1900) + $PluginTimeZoneSeconds);
	return ($nmday, $nmon+1, $nyear+1900, $nhour, $nmin, $nsec);
}


#-----------------------------------------------------------------------------
# PLUGIN FUNTION GetTimeZoneTitle_pluginname
#-----------------------------------------------------------------------------
sub GetTimeZoneTitle_timezone {
	return ($PluginTimeZoneSeconds/3600);
}


1;	# Do not remove this line

#!/usr/bin/perl
#-----------------------------------------------------------------------------
# TimeHires AWStats plugin
# Change time accuracy in showsteps option from seconds to milliseconds
#-----------------------------------------------------------------------------
# Perl Required Modules: Time::HiRes
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


use Time::HiRes qw( gettimeofday );
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
my $PluginNeedAWStatsVersion="5.1";
my $PluginHooksFunctions="GetTime";



#-----------------------------------------------------------------------------
# PLUGIN FUNTION Init_pluginname
#-----------------------------------------------------------------------------
sub Init_timehires {
	my $AWStatsVersion=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNTION GetTime_pluginname
#-----------------------------------------------------------------------------
sub GetTime_timehires {
	my ($sec,$msec)=&gettimeofday();
	$_[0]=$sec;
	$_[1]=$msec;
}


1;	# Do not remove this line

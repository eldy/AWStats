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
my $Plugin_need_awstats_version=5001;
#...



#-----------------------------------------------------------------------------
# PLUGIN Init_check_Version FUNCTION
#-----------------------------------------------------------------------------
sub Init_timehires_Check_Version {
	my $AWStats_Version=shift;
	if (! $Plugin_need_awstats_version) { return 0; }
	$AWStats_Version =~ /^(\d+)\.(\d+)/;
	my $versionnum=($1*1000)+$2;
	if 	($Plugin_need_awstats_version > $versionnum) {
		my $maj=int($Plugin_need_awstats_version/1000);
		my $min=$Plugin_need_awstats_version % 1000;
		return "Error: AWStats version $maj.$min or higher is required.";
	}
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN Init_pluginname FUNCTION
#-----------------------------------------------------------------------------
sub Init_timehires {
	my $AWStats_Version=shift;
	my $checkversion=Init_timehires_Check_Version($AWStats_Version);
	return ($checkversion?$checkversion:1);
}


#-----------------------------------------------------------------------------
# PLUGIN GetTime_pluginname FUNCTION
#-----------------------------------------------------------------------------
sub GetTime_timehires {
	my ($sec,$msec)=&gettimeofday();
	$_[0]=$sec;
	$_[1]=$msec;
}


#-----------------------------------------------------------------------------
# PLUGIN ShowField_pluginname FUNCTION
#-----------------------------------------------------------------------------
#...


#-----------------------------------------------------------------------------
# PLUGIN Filter_pluginname FUNCTION
#-----------------------------------------------------------------------------
#...



1;	# Do not remove this line

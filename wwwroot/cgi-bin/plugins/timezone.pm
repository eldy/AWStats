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
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
my $Plugin_need_awstats_version=5001;
#...



#-----------------------------------------------------------------------------
# PLUGIN Init_check_Version FUNCTION
#-----------------------------------------------------------------------------
sub Init_timezone_Check_Version {
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
sub Init_timezone {
	my $AWStats_Version=shift;
	my $TZ=shift;
	if (! $TZ) { return "Error: Disable plugin if TimeZone is 0 (Plugin useless)"; }	# We do not need this plugin if TZ=0
	my $checkversion=Init_timezone_Check_Version($AWStats_Version);
	return ($checkversion?$checkversion:($TZ*3600));
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

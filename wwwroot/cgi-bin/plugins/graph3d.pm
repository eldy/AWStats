#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Graph3d AWStats plugin
# Allow AWStats to use 3D graphs in its report
#-----------------------------------------------------------------------------
# Perl Required Modules: Graph3D
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


use GD::Graph3d;



#-----------------------------------------------------------------------------
# PLUGIN GLOBAL VARIABLES
#-----------------------------------------------------------------------------
my $Plugin_need_awstats_version=5001;
#...


#-----------------------------------------------------------------------------
# PLUGIN Init_check_Version FUNCTION
#-----------------------------------------------------------------------------
sub Init_graph3d_Check_Version {
	if (! $Plugin_need_awstats_version) { return 0; }
	$VERSION =~ /^(\d+)\.(\d+)/;
	my $versionnum=($1*1000)+$2;
	if 	($Plugin_need_awstats_version < $versionnum) {
		return "Error: AWStats version $Plugin_need_awstats_version or higher is required.";
	}
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN Init_pluginname FUNCTION
#-----------------------------------------------------------------------------
sub Init_graph3d {
	my $checkversion=Init_timehires_Check_Version();
	return ($checkversion?$checkversion:1);
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

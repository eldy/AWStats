#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Graph3d AWStats plugin
# Allow AWStats to use 3D graphs in its report
#-----------------------------------------------------------------------------
# Perl Required Modules: Graph3D
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
use GD::Graph3d;
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
my $PluginNeedAWStatsVersion="5.1";
my $PluginHooksFunctions="";



#-----------------------------------------------------------------------------
# PLUGIN FUNTION Init_pluginname
#-----------------------------------------------------------------------------
sub Init_graph3d {
	my $InitParams=shift;

	# <-----
	# YOU CAN ENTER HERE CODE TO INIT PLUGIN GLOBAL VARIABLES
	$PluginHashfilesUpToDate=1;
	# ----->

	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


1;	# Do not remove this line

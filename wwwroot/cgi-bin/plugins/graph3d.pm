#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Graph3d AWStats plugin
# Allow AWStats to replace bar graphs with an Applet (graph3Dapplet) that draw
# 3D graphs instead.
#-----------------------------------------------------------------------------
# Perl Required Modules: None
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.4";
my $PluginHooksFunctions="ShowMonthGraph";
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_graph3d {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-------------------------------------------------------
# PLUGIN FUNCTION: ShowMonthGraph_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# Add the code for graph3Dapplet
# Parameters:	$max_value, @data
# Input:        None
# Output:       HTML code for graph3Dapplet insertion
# Return:		0 OK, 1 Error
#-------------------------------------------------------
sub ShowMonthGraph_graph3d() {
	my $max_value=shift;
	my $graphwidth=780;
	my $graphheight=400;
	my @data=shift;
	if (! @data) { 
		# Si tableau de données vide
		return 1;
	}

	print "<applet>\n";
	
	print "</applet>\n";	

	return 0;
}



1;	# Do not remove this line

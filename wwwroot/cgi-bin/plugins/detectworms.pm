#!/usr/bin/perl
#-----------------------------------------------------------------------------
# detectworms AWStats plugin
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
my $PluginNeedAWStatsVersion="5.6";
my $PluginHooksFunctions="ScanForWorms";

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE
use vars qw/
/;
# ----->


#-----------------------------------------------------------------------------
# PLUGIN Init_pluginname FUNCTION
#-----------------------------------------------------------------------------
sub Init_detectworms {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# YOU CAN ENTER HERE CODE TO INIT PLUGIN GLOBAL VARIABLES
	my @param=split(/\s+/,$InitParams);
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#--------------------------------------------------------------------
# Function:      Return true if record is a worm hit
# Input:         
# Output:        
# UNIQUE: YES (Only one plugin using this function can be loaded)
#--------------------------------------------------------------------
sub ScanForWorms_detectworms
{
	debug("Call to ScanForWorms",5);

}



1;	# Ne pas effacer cette ligne

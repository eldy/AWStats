#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Example AWStats plugin
# <-----
# THIS IS A SAMPLE OF AN EMPTY PLUGIN FILE WITH INSTRUCTIONS TO HELP YOU TO
# WRITE YOUR OWN WORKING PLUGIN. REPLACE THIS SENTENCE WITH THE PLUGIN GOAL.
# NOTE THAT A PLUGIN FILE example.pm MUST BE IN LOWER CASE.
# ----->
#-----------------------------------------------------------------------------
# Perl Required Modules: Put here list of all required plugins
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
#use Time::Local
#use Time::Local
#use Time::Local
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
# EACH POSSIBLE FUNCTION AND GOAL ARE DESCRIBE LATER.
my $PluginNeedAWStatsVersion="5.1";
my $PluginHooksFunctions="xxx";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$PluginVariable1
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNTION Init_pluginname
#-----------------------------------------------------------------------------
sub Init_timezone {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# YOU CAN ENTER HERE CODE TO INIT PLUGIN GLOBAL VARIABLES
	debug("InitParams=$InitParams",1);
	$PluginVariable1="";
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



# HERE ARE ALL POSSIBLE HOOK FUNCTIONS. YOU MUST CHANGE THE NAME OF THE
# FUNCTION xxx_example INTO xxx_pluginname (pluginname is in lower case).
# NOTE THAT IN PLUGIN FUNCTIONS YOU CAN USE ANY AWSTATS GLOBAL VARIALES.


#-----------------------------------------------------------------------------
# PLUGIN FUNTION ShowPagesAddField_pluginname
# ShowPagesAddField is called when building the row of the output report
# of TOP Pages-URL (One call for each row). So it allows you to add a column
# in these report. For example with the code :
#   print "<TD>This is a new cell</TD>";
#-----------------------------------------------------------------------------
sub ShowPagesAddField_example {

	# <-----
	# ENTER PERL CODE HERE
	# ----->

}


1;	# Do not remove this line

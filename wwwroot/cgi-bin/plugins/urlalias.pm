#!/usr/bin/perl
#-----------------------------------------------------------------------------
# UrlAlias AWStats plugin
# This plugin allow you to report all URL links with a text title instead of
# URL value.
# You must create a file called urlalias.cnfigvalue.txt and store it in
# plugin directory that contains 2 columns separated by a tab char.
# First column is URL value and second column is text title to use instead of.
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
# SHOULD BE AT LEAST 5.1
my $PluginNeedAWStatsVersion="5.2";
# ----->

# <-----
# THIS VARIABLE MUST CONTAINS THE NAME OF ALL FUNCTIONS THAT MANAGE THE PLUGIN
my $PluginHooksFunctions="ReplaceURL";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE
use vars qw/
$urlaliasloaded
%UrlAliases
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNTION Init_pluginname
#-----------------------------------------------------------------------------
sub Init_urlalias {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# YOU CAN ENTER HERE CODE TO INIT PLUGIN GLOBAL VARIABLES
	debug("InitParams=$InitParams",1);
	$urlaliasloaded=0;
	%UrlAliases=();
	# ----->
	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNTION GetCountryCodeByName_pluginname
# UNIQUE: YES (Only one function GetCountryName can exists for all loaded plugins)
# GetCountryName is called to translate a host name or ip to a country name.
#-----------------------------------------------------------------------------
sub ReplaceURL_urlalias {
	# <-----
	if (! $urlaliasloaded) {
		my $filetoload="$PluginDir/urlalias.txt";
		# Load urlalias file
		open(URLALIASFILE,"$filetoload") or error("Error: Couldn't open UrlAlias file \"$filetoload\": $!");
		# This is the fastest way to load with regexp that I know
		%UrlAliases = map(/^([^\s]+)\s+([^\s]+)$/o,<URLALIASFILE>);
		close URLALIASFILE;
		debug("UrlAlias file loaded: ".(scalar keys %UrlAliases)." aliases found.");
		$urlaliasloaded=1;	
	}
	my $urltoreplace="$_[0]";
	if ($UrlAliases{$urltoreplace}) { print "<font style=\"color: #$color_link; font-weight: bold\">$UrlAliases{$urltoreplace}</font><br>"; }
	else { print ""; }
	return 1;
	# ----->
}


1;	# Do not remove this line

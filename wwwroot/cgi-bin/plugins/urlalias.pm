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
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES.
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.5";
my $PluginHooksFunctions="ShowInfoURL";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$urlinfoloaded
%UrlInfo
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_urlalias {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" InitParams=$InitParams",1);
	$urlinfoloaded=0;
	%UrlInfo=();
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoURL_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal information for URLs in URLs' report.
# This function is called after writing the URL value in the URL cell of the
# Top Pages-URL report.
# Parameters: URL
#-----------------------------------------------------------------------------
sub ShowInfoURL_urlalias {
	# <-----
	my $urltoshow="$_[0]";
	if ($urltoshow && ! $urlinfoloaded) {
		# Load urlalias file
		my $filetoload='';
		if ($SiteConfig && open(URLINFOFILE,"$PluginDir/urlalias.$SiteConfig.txt"))	{ $filetoload="$PluginDir/urlalias.$SiteConfig.txt"; }
		elsif (open(URLINFOFILE,"$PluginDir/urlalias.txt"))  						{ $filetoload="$PluginDir/urlalias.txt"; }
		else { error("Couldn't open UrlAlias file \"$PluginDir/urlalias.txt\": $!"); }
		# This is the fastest way to load with regexp that I know
		%UrlInfo = map(/^([^\t]+)\t+([^\t]+)/o,<URLINFOFILE>);
		close URLINFOFILE;
		debug("UrlAlias file loaded: ".(scalar keys %UrlInfo)." entries found.");
		$urlinfoloaded=1;
	}
	if ($urltoshow) {
		if ($UrlInfo{$urltoshow}) { print "<font style=\"color: #$color_link; font-weight: bold\">$UrlInfo{$urltoshow}</font><br>"; }
		else { print ""; }	# Undefined url info
	}
	else { print ""; }	# Url info title
	return 1;
	# ----->
}


1;	# Do not remove this line

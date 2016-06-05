#!/usr/bin/perl
#-----------------------------------------------------------------------------
# ClusterInfo AWStats plugin
# This plugin allow you to add information on cluster chart from
# a text file. Like full cluster hostname.
# You must create a file called clusterinfo.configvalue.txt which contains 2
# columns separated by a tab char, and store it in the DirData directory.
# The first column is the cluster number and the second column is the text
# you want to add.
#-----------------------------------------------------------------------------
# Perl Required Modules: None
#-----------------------------------------------------------------------------


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
#if (!eval ('require "TheModule.pm";')) { return $@?"Error: $@":"Error: Need Perl module TheModule"; }
# ----->
#use strict;
no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="6.2";
my $PluginHooksFunctions="ShowInfoCluster";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$clusterinfoloaded
%ClusterInfo
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_clusterinfo {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin clusterinfo: InitParams=$InitParams",1);
	$clusterinfoloaded=0;
	%ClusterInfo=();
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoCluster_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal columns to Cluster report.
# This function is called when building rows of the report (One call for each
# row). So it allows you to add a column in report, for example with code :
#   print "<TD>This is a new cell</TD>";
# Parameters: Cluster number
#-----------------------------------------------------------------------------
sub ShowInfoCluster_clusterinfo {
	my $param="$_[0]";
	# <-----
	my $filetoload='';
	if ($param && $param ne '__title__' && ! $clusterinfoloaded) {
		# Load clusterinfo file
		if ($SiteConfig && open(CLUSTERINFOFILE,"$DirData/clusterinfo.$SiteConfig.txt"))	{ $filetoload="$DirData/clusterinfo.$SiteConfig.txt"; }
		elsif (open(CLUSTERINFOFILE,"$DirData/clusterinfo.txt")) 	    				    { $filetoload="$DirData/clusterinfo.txt"; }
		else { error("Couldn't open ClusterInfo file \"$DirData/clusterinfo.txt\": $!"); }
		# This is the fastest way to load with regexp that I know
		%ClusterInfo = map(/^([^\s]+)\s+(.+)/o,<CLUSTERINFOFILE>);
		close CLUSTERINFOFILE;
		debug(" Plugin clusterinfo: ClusterInfo file loaded: ".(scalar keys %ClusterInfo)." entries found.");
		$clusterinfoloaded=1;
	}
	if ($param eq '__title__') {
		print "<th>$Message[114]</th>";
	}
	elsif ($param) {
		print "<td class=\"aws\">";
		if ($ClusterInfo{$param}) { print "$ClusterInfo{$param}"; }
		else { print "&nbsp;"; }	# Undefined cluster info
		print "</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	return 1;
	# ----->
}


1;	# Do not remove this line

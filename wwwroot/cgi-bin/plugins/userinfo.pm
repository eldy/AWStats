#!/usr/bin/perl
#-----------------------------------------------------------------------------
# UserInfo AWStats plugin
# This plugin allow you to add information on authenticated users chart from
# a text file. Like full user name and lastname.
# You must create a file called userinfo.configvalue.txt wich contains 2
# columns separated by a tab char, and store it in DirData directory.
# First column is authenticated user login and second column is text you want
# to add.
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
my $PluginNeedAWStatsVersion="5.5";
my $PluginHooksFunctions="ShowInfoUser";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$userinfoloaded
%UserInfo
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_userinfo {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin userinfo: InitParams=$InitParams",1);
	$userinfoloaded=0;
	%UserInfo=();
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoUser_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal columns to Authenticated users report.
# This function is called when building rows of the report (One call for each
# row). So it allows you to add a column in report, for example with code :
#   print "<TD>This is a new cell</TD>";
# Parameters: User
#-----------------------------------------------------------------------------
sub ShowInfoUser_userinfo {
	my $param="$_[0]";
	# <-----
	my $filetoload='';
	if ($param && $param ne '__title__' && ! $userinfoloaded) {
		# Load userinfo file
		if ($SiteConfig && open(USERINFOFILE,"$DirData/userinfo.$SiteConfig.txt"))	{ $filetoload="$DirData/userinfo.$SiteConfig.txt"; }
		elsif (open(USERINFOFILE,"$DirData/userinfo.txt"))  						{ $filetoload="$DirData/userinfo.txt"; }
		else { error("Couldn't open UserInfo file \"$DirData/userinfo.txt\": $!"); }
		# This is the fastest way to load with regexp that I know
		%UserInfo = map(/^([^\t]+)\t+([^\t]+)/o,<USERINFOFILE>);
		close USERINFOFILE;
		debug(" Plugin userinfo: UserInfo file loaded: ".(scalar keys %UserInfo)." entries found.");
		$userinfoloaded=1;
	}
	if ($param eq '__title__') {
		print "<th width=\"80\">$Message[114]</th>";	
	}
	elsif ($param) {
		print "<td>";
		if ($UserInfo{$param}) { print "$UserInfo{$param}"; }
		else { print "&nbsp;"; }	# Undefined user info
		print "</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	return 1;
	# ----->
}


1;	# Do not remove this line

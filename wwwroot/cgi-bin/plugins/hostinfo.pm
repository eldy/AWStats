#!/usr/bin/perl
#-----------------------------------------------------------------------------
# HostInfo AWStats plugin
# This plugin allow you to add information on hosts, like a whois link.
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
my $PluginNeedAWStatsVersion="5.7";
my $PluginHooksFunctions="ShowInfoHost AddHTMLBodyHeader";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_hostinfo {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" InitParams=$InitParams",1);
	if (! $LinksToWhoIs || ! $LinksToIPWhoIs) { return "Error: Parameters LinksToWhoIs and LinksToIPWhoIs must be defined in config file to use hostinfo plugin."; } 
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLBodyHeader_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add HTML code at beginning of BODY section.
#-----------------------------------------------------------------------------
sub AddHTMLBodyHeader_hostinfo {
	# <-----
	my $WIDTHINFO=640;
	my $HEIGHTINFO=480;

	print <<EOF;
			
<SCRIPT language="JavaScript">
function neww(a,b) {
	var wfeatures="directories=0,menubar=1,status=0,resizable=1,scrollbars=1,toolbar=0,width=$WIDTHINFO,height=$HEIGHTINFO,left=" + eval("(screen.width - $WIDTHINFO)/2") + ",top=" + eval("(screen.height - $HEIGHTINFO)/2");
	if (b==1) { fen=window.open('$LinksToWhoIs'+a,'whois',wfeatures); }
	if (b==2) { fen=window.open('$LinksToIPWhoIs'+a,'whois',wfeatures); }
}
</SCRIPT>

EOF

	return 1;
	# ----->
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoHost_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal columns to the Hosts report.
# This function is called when building rows of the report (One call for each
# row). So it allows you to add a column in report, for example with code :
#   print "<TD>This is a new cell</TD>";
# Parameters: Host name or ip
#-----------------------------------------------------------------------------
sub ShowInfoHost_hostinfo {
	# <-----
	my $hostinfotoshow="$_[0]";
	if ($hostinfotoshow eq '__title__') {
		print "<td width=80>$Message[114]</td>";	
	}
	elsif ($hostinfotoshow) {
		my $keyforwhois;
		my $linkforwhois;
		if ($hostinfotoshow =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {	# IPv4 address
			$keyforwhois=$hostinfotoshow;
			$linkforwhois=2;
		}
		elsif ($hostinfotoshow =~ /^[0-9A-F]*:/i) {							# IPv6 address
			$keyforwhois=$hostinfotoshow;
			$linkforwhois=2;
		}
		else {	# Hostname
			$hostinfotoshow =~ /([-\w]+\.[-\w]+\.(au|uk|jp|nz))$/ or $hostinfotoshow =~ /([-\w]+\.[-\w]+)$/;
			$keyforwhois=$1;
			$linkforwhois=1;
		}
		print "<td>";
		if ($keyforwhois && $linkforwhois) { print "<a href=\"javascript:neww('$keyforwhois',$linkforwhois)\">?</a>"; }
		else { print "&nbsp;" }
		print "</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	return 1;
	# ----->
}


1;	# Do not remove this line

#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GraphGoogleChartApi AWStats plugin
# Allow AWStats to replace bar graphs with a Google Graph image
#-----------------------------------------------------------------------------
# Perl Required Modules: None
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$
# 
# Changelog
#
# 1.0 - Initial release
# 1.1 - Changed scaling: making it independent of chart series


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
# ----->
#use strict;
no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion = "6.0";
my $PluginHooksFunctions = "ShowGraph";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$DirClasses
/;
# ----->


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_graphgooglechartapi {
	my $InitParams = shift;
	my $checkversion = &Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	$DirClasses = $InitParams;
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-------------------------------------------------------
# PLUGIN FUNCTION: ShowGraph_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# Add the code for call to applet awgraphapplet
# Parameters:	$title $type $showmonthstats \@blocklabel,\@vallabel,\@valcolor,\@valmax,\@valtotal
# Input:        None
# Output:       HTML code for awgraphapplet insertion
# Return:		0 OK, 1 Error
#-------------------------------------------------------
sub ShowGraph_graphgooglechartapi() {
	my $title = shift;
	my $type = shift;
	my $showmonthstats = shift;
	my $blocklabel = shift;
	my $vallabel = shift;
	my $valcolor = shift;
	my $valmax = shift;
	my $valtotal = shift;
	my $valaverage = shift;
	my $valdata = shift;

	my $graphwidth = 780;
	my $graphheight = 400;

	my $color1 = "4477dd";
	my $color2 = "66f0ff";
	my $maxlabellen = 3;

	if ($type eq 'month') {
		$graphwidth = 540;
		$graphheight = 160;
		$color1 = "ffb055";
		$color2 = "f8e880";
	}
	elsif ($type eq 'daysofmonth') {
		$graphwidth = 640;
		$graphheight = 160;
		$color1 = "f8e880";
		$color2 = "4477DD";
		$maxlabellen = 2; 
	}
	elsif ($type eq 'daysofweek') {
		$graphwidth = 300;
		$graphheight = 160;
	}
	elsif ($type eq 'hours') {
		$graphwidth = 600;
		$graphheight = 160;
	}
	else {
		error("Unknown type parameter in ShowGraph_graphgooglechartapi function");
	}

	print "<img src = \"http://chart.apis.google.com/chart?cht=bvg&chd=t:";
	$s = "";

	# initialise array for 2 data series
    @max = (0,0);

	# display only x series
	$x=1;
	for ($serie = 0; $serie <= $x; $serie++) {
		foreach my $j (1..(scalar @$blocklabel)) {
    			if ($j > 1) { $s .= ","; }
			$val = @$valdata[($j-1)*(scalar @$vallabel)+$serie];
			$s .= "$val";
			if ($val > $max[$serie]) {
				$max[$serie] = $val;
			}
		}
		if ($serie < $x) {
			$s .= "|";
		}
        }
	print $s."&chds=0,$max[0],0,$max[1]&chbh=a&chl=";

	# display labels
	foreach my $i (1..(scalar @$blocklabel)) {
		$b = "".@$blocklabel[$i-1];
		$b = substr($b,0,$maxlabellen);
		print $b ."|";
	}
        print "&chs=$graphwidth"; print "x$graphheight&chco=$color1,$color2\" alt=\"\" /><br />\n";

	return 0;
}



1;	# Do not remove this line

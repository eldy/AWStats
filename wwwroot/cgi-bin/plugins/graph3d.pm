#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Graph3d AWStats plugin
# Allow AWStats to use 3D graphs in its report
#-----------------------------------------------------------------------------
# Perl Required Modules: GD::Graph
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
if (!eval ('require "GD/Graph/bars3d.pm";')) { return "Error: Need Perl module GD::Graph"; }
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
my $PluginNeedAWStatsVersion="5.1";
my $PluginHooksFunctions="ShowMonthGraph";



#-----------------------------------------------------------------------------
# PLUGIN FUNTION Init_pluginname
#-----------------------------------------------------------------------------
sub Init_graph3d {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-------------------------------------------------------
# Genere un fichier image .png du graphique du tableau de bord
# Parameters:	$max_value, @data
# Input:        None
# Output:       Png file
# Return:		0 OK, 1 Error
#-------------------------------------------------------
sub ShowMonthGraph() {
	my $max_value=shift;
	my $graphwidth=780;
	my $graphheight=400;
	my @data=shift;
	if (! @data) { 
		# Si tableau de données vide
		return 1;
	}
	
	$max_value = (int($max_value/100)+1)*100;
		
	# Make a new graph object that is 900 pixels wide by 500 pixels high
	my $graph = new GD::Graph::bars3d($graphwidth, $graphheight);
	
	# Set some labels
	$graph->set( 
		x_label           => 'xxx',
		y_label           => 'yyy',
		title             => '',
		overwrite		  => 1,
		long_ticks		  => 0,
		legend_placement  => 'RC',
		legend_spacing    => 10,
		x_ticks			  => 1,
		dclrs			  => ['#0000FF', '#9900FF', '#CC00FF', '#FF0099'],
		bar_spacing		  => 1,
		title			  => 'aaaaaaaa',
		y_max_value		  => $max_value
	);
	
	$graph->set_legend('xxx', 'yyy', 'zzz', 'www');
	$graph->set_legend_font(GD::Font->MediumBold);
	$graph->set_x_label_font(GD::Font->MediumBold);
	$graph->set_y_label_font(GD::Font->MediumBold);
	$graph->set_title_font(GD::Font->Giant);
	
	# Plot the graph to a GD object
	my $gd = $graph->plot( \@data );

	# Figure out what the default output format is
	my $format = $graph->export_format;


	# Now write image to output
	print IMG $gd->png();

	return 0;
}





1;	# Do not remove this line

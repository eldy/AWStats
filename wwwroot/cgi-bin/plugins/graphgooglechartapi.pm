#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GraphGoogleChartApi AWStats plugin
# Allow AWStats to replace bar graphs with a Google Graph image
#-----------------------------------------------------------------------------
# Perl Required Modules: None
#-----------------------------------------------------------------------------
# 
# Changelog
#
# 1.0 - Initial release by george@dynapres.nl
# 1.1 - Changed scaling: making it independent of chart series
# 1.2 - Added pie charts, visualization hook, map and axis labels by Chris Larsen

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
my $PluginNeedAWStatsVersion = "7.0";
my $PluginHooksFunctions = "Init ShowGraph AddHTMLHeader";
my $PluginName = "graphgooglechartapi";
my $ChartProtocol = "https://";
my $ChartURI = "chart.googleapis.com/chart?";	# Don't put the HTTP part here!
my $ChartIndex = 0;
my $title;
my $type;
my $imagewidth = 640;			# maximum image width. 
my $imageratio = .25;			# Height is defaulted to 25% of width
my $pieratio = .20;				# Height for pie charts should be different
my $mapratio = .62;				# Height for maps is different
my $labellength;
my @blocklabel = ();
my @vallabel = ();
my @valcolor = ();
my @valmax = ();
my @valtotal = ();
my @valaverage = ();
my @valdata = ();
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$DirClasses
$URLIndex
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

	$title = "";
	$type = "";
	$labellength=2;
	$ChartIndex = -1;
	
	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}

#-------------------------------------------------------
# PLUGIN FUNCTION: ShowGraph_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# Prints the proper chart depending on the $type provided
# Parameters:	$title $type $imagewidth \@blocklabel,\@vallabel,\@valcolor,\@valmax,\@valtotal
# Input:        None
# Output:       HTML code for awgraphapplet insertion
# Return:		0 OK, 1 Error
#-------------------------------------------------------
sub ShowGraph_graphgooglechartapi() {
	$title = shift;
	$type = shift;
	$imagewidth = shift || 640;
	$blocklabel = shift;
	$vallabel = shift;
	$valcolor = shift;
	$valmax = shift;
	$valtotal = shift;
	$valaverage = shift;
	$valdata = shift;
	
	# check width
	if ($imagewidth < 1){$imagewidth=640;}

	if ($type eq 'month') {
		$labellength=4;
		print Get_Img_Tag(Graph_Monthly(), $title);
	}
	elsif ($type eq 'daysofmonth') {
		$labellength=2;
		print Get_Img_Tag(Graph_Daily(), $title);		
	}
	elsif ($type eq 'daysofweek') {
		$labellength=3;
		print Get_Img_Tag(Graph_Weekly(), $title);		
	}
	elsif ($type eq 'hours') {
		$labellength=2;
		print Get_Img_Tag(Graph_Hourly(), $title);		
	}
	elsif ($type eq 'cluster'){
		$labellength=32;
		print Get_Img_Tag(Graph_Pie(), $title);		
	}
	elsif ($type eq 'filetypes'){
		$labellength=4;
		print Get_Img_Tag(Graph_Pie(), $title);
	}
	elsif ($type eq 'httpstatus'){
		$labellength=4;
		print Get_Img_Tag(Graph_Pie(), $title);
	}
	elsif ($type eq 'browsers'){
		$labellength=32;
		print Get_Img_Tag(Graph_Pie(), $title);
	}
	elsif ($type eq 'downloads'){
		$labellength=32;
		print Get_Img_Tag(Graph_Pie(), $title);
	}
	elsif ($type eq 'pages'){
		$labellength=32;
		print Get_Img_Tag(Graph_Pie(), $title);
	}
	elsif ($type eq 'oss'){
		$labellength=32;
		print Get_Img_Tag(Graph_Pie(), $title);
	}
	elsif ($type eq 'hosts'){
		$labellength=32;
		print Get_Img_Tag(Graph_Pie(), $title);
	}
	elsif ($type eq 'countries_map'){
		print Chart_Map();
	}
	else {
		debug("Unknown type parameter in ShowGraph_graphgooglechartapi function: $title",1);
		#error("Unknown type parameter in ShowGraph_graphgooglechartapi function");
	}

	return 0;
}

#-------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLHeader_pluginname
# UNIQUE: NO
# Prints javascript includes for Google Visualizations
# Parameters:	None
# Input:        None
# Output:       HTML code for Google Visualizations
# Return:		0 OK, 1 Error
#-------------------------------------------------------
sub AddHTMLHeader_graphgooglechartapi(){
	print "<script type='text/javascript' src='https://www.google.com/jsapi'></script>\n";
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Graph_Monthly
# Prints the image code to display a column chart of monthly usage
# Parameters:	None
# Input:        None
# Output:       HTML code to print a chart
# Return:		0 OK, 1 Error
#-------------------------------------------------------
sub Graph_Monthly(){
	my $chxt = "chxt=";
	my $chxl = "chxl=";
	my $chxs = "chxs=";
	my $chco = "chco=";
	my $chg = "chg=";
	my $chs = "chs=";
	my $cht = "cht=bvg";
	my $chd = "chd=t:";
	my $cba = "chbh=a";				# shows the whole month
	my $graphwidth = $imagewidth;
	my $graphheight = int ($imagewidth * $imageratio);
	
	# round max values
	foreach my $i(0..(scalar @$valmax)){
		@$valmax[$i] = Round_Up(@$valmax[$i]);
	}
	
	# setup axis
	$chxt .= "x,y,y,r"; # add an x for years
	
	# get the month labels
	$chxl .= "0:|";
	$chxl .= Get_Labels();
	# get the hits/pages max
	$chxl .= "1:|0|".Get_Suffixed((@$valmax[0]/2),0)."|".Get_Suffixed(@$valmax[0],0)."|";
	# get the visitors/pages max
	$chxl .= "2:|0|".Get_Suffixed((@$valmax[2]/2),0)."|".Get_Suffixed(@$valmax[2],0)."|";
	# get bytes
	$chxl .= "3:|0|".Get_Suffixed((@$valmax[4]/2),1)."|".Get_Suffixed(@$valmax[4],1);
	# TODO add the year at the start and end
	
	# set the axis colors
	$chxs .= "1,".@$valcolor[0]."|2,".@$valcolor[2]."|3,".@$valcolor[4];
	
	# dump colors
	foreach my $i(0..(scalar @$valcolor)){
		$chco .= @$valcolor[$i];
		if ($i < (scalar @$valcolor)-1){ $chco .= ",";}
	}
	
	# grid lines
	$chg .= "0,50";
	
	# size
	$chs .= $graphwidth."x".$graphheight;
	
	# finally get the data
	$chd .= Get_Column_Data();
	
	# string and dump
	return "$cht&$chxl&$chxt&$chxs&$chco&$chg&$chs&$chd&$cba";
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Graph_Daily
# Prints the image code to display a column chart of daily usage
# Parameters:	None
# Input:        None
# Output:       HTML code to print a chart
# Return:		0 OK, 1 Error
#-------------------------------------------------------
sub Graph_Daily(){
	my $chxt = "chxt=";
	my $chxl = "chxl=";
	my $chxs = "chxs=";
	my $chco = "chco=";
	my $chg = "chg=";
	my $chs = "chs=";
	my $cht = "cht=bvg";
	my $chd = "chd=t:";
	my $cba = "chbh=a";				# shows the whole month
	my $graphwidth = $imagewidth;
	my $graphheight = int ($imagewidth * $imageratio);
	
	# round max values
	foreach my $i(0..(scalar @$valmax)){
		@$valmax[$i] = Round_Up(@$valmax[$i]);
	}
	
	# setup axis
	$chxt .= "x,y,y,r"; # add an x for years
	
	# setup axis labels
	# get day labels
	$chxl .= "0:|";
	$chxl .= Get_Labels();
	# get the hits/pages max
	$chxl .= "1:|0|".Get_Suffixed((@$valmax[0]/2),0)."|".Get_Suffixed(@$valmax[0],0)."|";
	# get the visitors/pages max
	$chxl .= "2:|0|".Get_Suffixed((@$valmax[1]/2),0)."|".Get_Suffixed(@$valmax[1],0)."|";
	# get bytes
	$chxl .= "3:|0|".Get_Suffixed((@$valmax[3]/2),1)."|".Get_Suffixed(@$valmax[3],1);
	# TODO month name
	
	# set the axis colors
	$chxs .= "1,".@$valcolor[0]."|2,".@$valcolor[1]."|3,".@$valcolor[3];
	
	# dump colors
	foreach my $i(0..(scalar @$valcolor)){
		$chco .= @$valcolor[$i];
		if ($i < (scalar @$valcolor)-1){ $chco .= ",";}
	}
	
	# grid lines
	$chg .= "0,50";
	
	# size
	$chs .= $graphwidth."x".$graphheight;
	
	# finally get the data
	$chd .= Get_Column_Data();
	
	# string and dump
	return "$cht&$chxl&$chxt&$chxs&$chco&$chg&$chs&$chd&$cba";
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Graph_Weekly
# Prints the image code to display a column chart of weekly usage
# Parameters:	None
# Input:        None
# Output:       HTML code to print a chart
# Return:		0 OK, 1 Error
#-------------------------------------------------------
sub Graph_Weekly(){
	my $chxt = "chxt=";
	my $chxl = "chxl=";
	my $chxs = "chxs=";
	my $chco = "chco=";
	my $chg = "chg=";
	my $chs = "chs=";
	my $cht = "cht=bvg";
	my $chd = "chd=t:";
	my $cba = "chbh=a";				# shows the whole month
	my $graphwidth = int ($imagewidth * .75);   # to maintain old look/ratio, reduce width of the weekly
	my $graphheight = int ($imagewidth * $imageratio);
	
	# round max values
	foreach my $i(0..(scalar @$valmax)){
		@$valmax[$i] = Round_Up(@$valmax[$i]);
	}
	
	# setup axis
	$chxt .= "x,y,y,r"; # add an x for years
	
	# setup axis labels
	# get the day labels
	$chxl .= "0:|";
	$chxl .= Get_Labels();
	# get the hits/pages max
	$chxl .= "1:|0|".Get_Suffixed((@$valmax[0]/2),0)."|".Get_Suffixed(@$valmax[0],0)."|";
	# get the visitors/pages max
	$chxl .= "2:|0|".Get_Suffixed((@$valmax[1]/2),0)."|".Get_Suffixed(@$valmax[1],0)."|";
	# get bytes
	$chxl .= "3:|0|".Get_Suffixed((@$valmax[2]/2),1)."|".Get_Suffixed(@$valmax[2],1);
	
	# set the axis colors
	$chxs .= "1,".@$valcolor[0]."|2,".@$valcolor[1]."|3,".@$valcolor[2];
	
	# dump colors
	foreach my $i(0..(scalar @$valcolor)){
		$chco .= @$valcolor[$i];
		if ($i < (scalar @$valcolor)-1){ $chco .= ",";}
	}
	
	# grid lines
	$chg .= "0,50";
	
	# size
	$chs .= $graphwidth."x".$graphheight;
	
	# finally get the data
	$chd .= Get_Column_Data();
	
	# string and dump
	return "$cht&$chxl&$chxt&$chxs&$chco&$chg&$chs&$chd&$cba";
}
	
#-------------------------------------------------------
# PLUGIN FUNCTION: Graph_Hourly
# Prints the image code to display a column chart of hourly usage
# Parameters:	None
# Input:        None
# Output:       HTML code to print a chart
# Return:		0 OK, 1 Error
#-------------------------------------------------------
sub Graph_Hourly(){
	my $chxt = "chxt=";
	my $chxl = "chxl=";
	my $chxs = "chxs=";
	my $chco = "chco=";
	my $chg = "chg=";
	my $chs = "chs=";
	my $cht = "cht=bvg";
	my $chd = "chd=t:";
	my $cba = "chbh=a";				# shows the whole month
	my $graphwidth = $imagewidth;
	my $graphheight = int ($imagewidth * $imageratio);
	
	# round max values
	foreach my $i(0..(scalar @$valmax - 1)){
		@$valmax[$i] = Round_Up(@$valmax[$i]);
	}
	
	# setup axis
	$chxt .= "x,y,y,r"; # add an x for years
	
	# setup axis labels
	$chxl .= "0:|";
	$chxl .= Get_Labels();
	# get the hits/pages max
	$chxl .= "1:|0|".Get_Suffixed((@$valmax[0]/2),0)."|".Get_Suffixed(@$valmax[0],0)."|";
	# get the visitors/pages max
	$chxl .= "2:|0|".Get_Suffixed((@$valmax[1]/2),0)."|".Get_Suffixed(@$valmax[1],0)."|";
	# get bytes
	$chxl .= "3:|0|".Get_Suffixed((@$valmax[2]/2),1)."|".Get_Suffixed(@$valmax[2],1);
	# TODO years
	
	# set the axis colors
	$chxs .= "1,".@$valcolor[0]."|2,".@$valcolor[1]."|3,".@$valcolor[2];
	
	# dump colors
	foreach my $i(0..(scalar @$valcolor)){
		$chco .= @$valcolor[$i];
		if ($i < (scalar @$valcolor)-1){ $chco .= ",";}
	}
	
	# grid lines
	$chg .= "0,50";
	
	# size
	$chs .= $graphwidth."x".$graphheight;
	
	# finally get the data
	$chd .= Get_Column_Data();
	
	# string and dump
	return "$cht&$chxl&$chxt&$chxs&$chco&$chg&$chs&$chd&$cba";
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Graph_Pie
# Prints the image code to display a pie chart of the provided data
# Parameters:	None
# Input:        None
# Output:       HTML code to print a chart
# Return:		0 OK, 1 Error
#-------------------------------------------------------
sub Graph_Pie(){
	my $chl = "chl=";
	my $chs = "chs=";
	my $chco = "chco=";
	my $cht = "cht=p3";
	my $chd = "chd=t:";
	my $graphwidth = $imagewidth;
	my $graphheight = int ($imagewidth * $pieratio);
	
	# get labels
	$chl .= Get_Labels();
	
	# get data, just read off the array for however many labels we have
	foreach my $i (0..((scalar @$blocklabel)-1)) {
		$chd .= int(@$valdata[$i]);
		$chd .= ($i < ((scalar @$blocklabel)-1) ? "," : "");
	}
	
	# get color, just the first color passed
	$chco .= @$valcolor[0];
	
	# set size
	$chs .= $graphwidth."x".$graphheight;
	
	return "$cht&$chs&$chco&$chl&$chd";
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Chart_Map
# Prints a Javascript and DIV tag to display a Google Visualization GeoMap
# that uses the Flash plugin to display a map of the world shaded to reflect
# the provided data
# Parameters:	None
# Input:        None
# Output:       Javascript and DIV tag
# Return:		0 OK, 1 Error
#-------------------------------------------------------
sub Chart_Map(){
	my $graphwidth = $imagewidth;
	my $graphheight = int ($imagewidth * $mapratio);
	
	# Assume we've already included the proper headers so just call our script inline
	print "\n<script type='text/javascript'>\n";
   	print "google.load('visualization', '1', {'packages': ['geomap']});\n";
   	print "google.setOnLoadCallback(drawMap);\n";
	print "function drawMap() {\n\tvar data = new google.visualization.DataTable();\n";
	      
	# get the total number of rows
	print "\tdata.addRows(".scalar @$blocklabel.");\n";
	print "\tdata.addColumn('string', 'Country');\n";
	print "\tdata.addColumn('number', 'Hits');\n";
	      
	# loop and dump
    my $i = 0;
    for ($i .. (scalar @$blocklabel - 1)) {
		# fix case of uk
        if (@$blocklabel[$i] eq 'Great Britain') { @$blocklabel[$i] = 'United Kingdom'; }
        if (@$blocklabel[$i] eq 'Russian Federation') { @$blocklabel[$i] = 'Russia'; }
    	print "\tdata.setValue($i, 0, \"".@$blocklabel[$i]."\");\n";
    	print "\tdata.setValue($i, 1, ".@$valdata[$i].");\n";
    	$i++;
    	# Google's Geomap only supports up to 400 entries
    	if ($i >= 400){ last; }
    }
	
	print "\tvar options = {};\n";
	print "\toptions['dataMode'] = 'regions';\n";
	print "\toptions['width'] = $graphwidth;\n";
	print "\toptions['height'] = $graphheight;\n";
	print "\tvar container = document.getElementById('$title');\n";
	print "\tvar geomap = new google.visualization.GeoMap(container);\n";
	print "\tgeomap.draw(data, options);\n";
	print "};\n";			
	print "</script>\n";
	
	# print the div tag that will contain the map
	print "<div id='$title'></div>\n";
	return;
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Get_Column_Data
# Loops through the data array and prints a CHD string to send to a Google
# chart via the API
# Parameters:	None
# Input:        @valcolor, @blocklabel, @valdata, @valmax
# Output:       None
# Return:		A pipe delimited string of data. REQUIRES the "chd=t:" prepended
#-------------------------------------------------------
# Returns a string with the CHD data
sub Get_Column_Data(){
	my $chd = "";
	
	# use the # of colors to determine how many values we have
	$x= scalar @$valcolor;
	for ($serie = 0; $serie <= $x; $serie++) {
		foreach my $j (1.. (scalar @$blocklabel)) {
    			if ($j > 1) { $chd .= ","; }
			$val = @$valdata[($j-1)*$x+$serie];
			# convert our values to a percent of max
			$chd .= (@$valmax[$serie] > 0 ? int(($val / Round_Up(@$valmax[$serie])) * 100) : 0);
		}
		if ($serie < $x) {
			$chd .= "|";
		}
    }
	
	# return
	return $chd;
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Get_Labels
# Returns a CHXL string with labels to send to the Google chart API. Long labels
# are shortened to $labellength
# TODO - better shortening method instead of just lopping off the end of strings
# Parameters:	None
# Input:        @blocklabel, $labellength
# Output:       None
# Return:		A pipe delimited string of labels. REQUIRES the "chxl=" prepended
#-------------------------------------------------------
sub Get_Labels(){
	my $chxl = "";
	foreach my $i (1..(scalar @$blocklabel)) {
		$temp = @$blocklabel[$i-1];
		if (length($temp) > $labellength){
			$temp = (substr($temp,0,$labellength));
		}
		$chxl .= "$temp|";
	}
	$chxl =~ s/&//;
	return $chxl;
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Round_Up
# Rounds a number up to the next most significant digit, i.e. 1234 becomes 2000
# Useful for getting the max values of our graph
# Parameters:	$num
# Input:        None
# Output:       None
# Return:		The rounded number
#-------------------------------------------------------
sub Round_Up(){
	my $num = shift;
	$num = int($num);
	if ($num < 1){ return $num; }
	
	# under 100, just increment and dump
	if ($num < 100){return $num++; }
	
	$i = int(substr($num,0,2))+1;
	
	# pad with 0s
	$l = length($i);
	while ($l<(length($num))){
		$i .= "0";
		$l++;
	}
	return $i;
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Get_Suffixed
# Converts a number for axis labels and appends the scientific notation suffix
# or proper size in bytes
# Parameters:	$num
# Input:        @Message array from AWStats
# Output:       None
# Return:		A number with suffix, i.e. 400 MB or 200 K
#-------------------------------------------------------
sub Get_Suffixed(){
	my $num = shift || 0;
	my $isbytes = shift || 0;
	my $float = 0;
	if ( $num >= ( 1 << 30 ) ) {
		$float = (split(/\./, $num / 1000000000))[1];
		if ($float){
			return sprintf( "%.1f", $num / 1000000000 ) . ($isbytes ? " $Message[110]" : " B");
		}else{
			return sprintf( "%.0f", $num / 1000000000 ) . ($isbytes ? " $Message[110]" : " B");
		}
	}
	if ( $num >= ( 1 << 20 ) ) {
		$float = (split(/\./, $num / 1000000))[1];
		if ($float){
			return sprintf( "%.1f", $num / 1000000 ) . ($isbytes ? " $Message[109]" : " M");
		}else{
			return sprintf( "%.0f", $num / 1000000 ) . ($isbytes ? " $Message[109]" : " M");
		}		
	}
	if ( $num >= ( 1 << 10 ) ) {
		$float = (split(/\./, $num / 1000))[1];
		if ($float){
			return sprintf( "%.1f", $num / 1000 ) . ($isbytes ? " $Message[108]" : " K");
		}else{
			return sprintf( "%.0f", $num / 1000 ) . ($isbytes ? " $Message[108]" : " K");
		}
	}
	return int($num);
}

#-------------------------------------------------------
# PLUGIN FUNCTION: Get_Img_Tag
# Builds the full IMG tag to place in HTML that will call the Google Charts API
# Parameters:	$params, $title
# Input:        $ChartProtocol, $ChartURI, $ChartIndex
# Output:       None
# Return:		An HTML IMG tag
#-------------------------------------------------------
sub Get_Img_Tag(){
	my $params = shift || "";
	my $title = shift || "";
	my $tag = "<img src=\"$ChartProtocol";
	# for optimization, we can prepend a number to the host address and google will
	# use different servers to generate our images. This is important if we have multiple
	# images on the same page
	# TODO - debug why chart index isn't working as Google says it should
#	if ($URLIndex < 0){
		$tag .= "$ChartURI";
#	}else{
#		$tag .= "$ChartIndex.$ChartURI";
#	}
	$ChartIndex = ($ChartIndex >= 9 ? 0 : $ChartIndex + 1);
	$tag .= $params;
	$tag .= "\" alt=\"$title\"/>";
}

1;	# Do not remove this line

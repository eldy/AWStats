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
# EACH POSSIBLE FUNCTION AND GOAL ARE DESCRIBED LATER.
my $PluginNeedAWStatsVersion="6.7";
my $PluginHooksFunctions="xxx";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$PluginVariable1
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_example {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" InitParams=$InitParams",1);
	$PluginVariable1="";
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



# HERE ARE ALL POSSIBLE HOOK FUNCTIONS. YOU MUST CHANGE THE NAME OF THE
# FUNCTION xxx_example INTO xxx_pluginname (pluginname in lower case).
# NOTE THAT IN PLUGINS' FUNCTIONS, YOU CAN USE ANY AWSTATS GLOBAL VARIALES.


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLStyles_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add HTML styles at beginning of BODY section.
# Parameters: None
#-----------------------------------------------------------------------------
sub AddHTMLStyles_example {
	# <-----
	# PERL CODE HERE
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLBodyHeader_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add HTML code at beginning of BODY section (top of page).
# Parameters: None
#-----------------------------------------------------------------------------
sub AddHTMLBodyHeader_example {
	# <-----
	# PERL CODE HERE
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLBodyFooter_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add HTML code at end of BODY section (bottom of page).
# Parameters: None
#-----------------------------------------------------------------------------
sub AddHTMLBodyFooter_example {
	# <-----
	# PERL CODE HERE
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLMenuHeader_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add HTML code just before the menu section
# Parameters: None
#-----------------------------------------------------------------------------
sub AddHTMLMenuHeader_example {
	# <-----
	# PERL CODE HERE
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLMenuFooter_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add HTML code just after the menu section
# Parameters: None
#-----------------------------------------------------------------------------
sub AddHTMLMenuFooter_example {
	# <-----
	# PERL CODE HERE
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLContentHeader_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add HTML code just before the first report
# Parameters: None
#-----------------------------------------------------------------------------
sub AddHTMLContentHeader_example {
	# <-----
	# PERL CODE HERE
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNTION: BuildFullHTMLOutput_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to output an HTML page completely built by plugin instead
# of AWStats output
#-----------------------------------------------------------------------------
sub BuildFullHTMLOutput_example {
	# <-----
	print "This is an output for plugin example<br />\n";
	return 1;
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoHost_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal columns to the Hosts report.
# This function is called when building rows of the report (One call for each
# row). So it allows you to add a column in report, for example with code :
#   print "<TD>This is a new cell for $param</TD>";
# Parameters: Host name or ip
#-----------------------------------------------------------------------------
sub ShowInfoHost_example {
    my $param="$_[0]";
	# <-----
	# PERL CODE HERE
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowPagesAddField_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function used to add additionnal columns to the Top Pages-URL report.
# This function is called when building rows of the report (One call for each
# row). So it allows you to add a column in report, for example with code :
#   print "<TD>This is a new cell for $param</TD>";
# Parameters: URL
#-----------------------------------------------------------------------------
sub ShowPagesAddField_example {
    my $param="$_[0]";
	# <-----
	# PERL CODE HERE
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoURL_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal information for URLs in URLs' report.
# This function is called after writing the URL value in the URL cell of the
# Top Pages-URL report.
# Parameters: URL
#-----------------------------------------------------------------------------
sub ShowInfoURL_example {
    my $param="$_[0]";
	# <-----
	# PERL CODE HERE
	# ----->
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoUser_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal columns to Authenticated users report.
# This function is called when building rows of the report (One call for each
# row). So it allows you to add a column in report, for example with code :
#   print "<TD>This is a new cell for $param</TD>";
# Parameters: User
#-----------------------------------------------------------------------------
sub ShowInfoUser_example {
    my $param="$_[0]";
	# <-----
	# PERL CODE HERE
	# ----->
}



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionInitHashArray_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionInitHashArray_example {
	# <-----
	if ($Debug) { debug(" Plugin example: Init_HashArray"); }
	%_myarray_p = %_myarray_h = %_myarray_k = %_myarray_l = ();
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessIP_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessIp_example {
    my $param="$_[0]";      # Param is IP of record
	# <-----
	# PERL CODE HERE
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessHostname_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessHostname_example {
    my $param="$_[0]";      # Param is hostname of record
	# <-----
	# PERL CODE HERE
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionReadHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionReadHistory_example {
    my $issectiontoload=shift;
    my $xmlold=shift;
    my $xmleb=shift;
	my $countlines=shift;
	# <-----
#	if ($Debug) { debug(" Plugin example: Begin of PLUGIN_example section"); }
#	my @field=();
#	my $count=0;my $countloaded=0;
#	do {
#		if ($field[0]) {
#			$count++;
#			if ($issectiontoload) {
#				$countloaded++;
#				if ($field[1]) { $_myarray_p{$field[0]}+=$field[1]; }
#				if ($field[2]) { $_myarray_h{$field[0]}+=$field[2]; }
#				if ($field[3]) { $_myarray_k{$field[0]}+=$field[3]; }
#				if ($field[4]) { $_myarray_l{$field[0]}+=$field[4]; }
#			}
#		}
#		$_=<HISTORY>;
#		chomp $_; s/\r//;
#		@field=split(/\s+/,($xmlold?XMLDecodeFromHisto($_):$_));
#		$countlines++;
#	}
#	until ($field[0] eq 'END_PLUGIN_example' || $field[0] eq "${xmleb}END_PLUGIN_example" || ! $_);
#	if ($field[0] ne 'END_PLUGIN_example' && $field[0] ne "${xmleb}END_PLUGIN_example") { error("History file is corrupted (End of section PLUGIN not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).","","",1); }
#	if ($Debug) { debug(" Plugin example: End of PLUGIN_example section ($count entries, $countloaded loaded)"); }
	# ----->
	return 0;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionWriteHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionWriteHistory_example {
    my ($xml,$xmlbb,$xmlbs,$xmlbe,$xmlrb,$xmlrs,$xmlre,$xmleb,$xmlee)=(shift,shift,shift,shift,shift,shift,shift,shift,shift);
    if ($Debug) { debug(" Plugin example: SectionWriteHistory_example start - ".(scalar keys %_myarray_h)); }
	# <-----
#	print HISTORYTMP "\n";
#	if ($xml) { print HISTORYTMP "<section id='plugin_example'><sortfor>$MAXNBOFSECTIONGIR</sortfor><comment>\n"; }
#	print HISTORYTMP "# Plugin key - Pages - Hits - Bandwidth - Last access\n";
#	$ValueInFile{'plugin_example'}=tell HISTORYTMP;
#	print HISTORYTMP "${xmlbb}BEGIN_PLUGIN_example${xmlbs}".(scalar keys %_myarray_h)."${xmlbe}\n";
#	&BuildKeyList($MAXNBOFSECTIONGIR,1,\%_myarray_h,\%_myarray_h);
#	my %keysinkeylist=();
#	foreach (@keylist) {
#		$keysinkeylist{$_}=1;
#		my $page=$_myarray_p{$_}||0;
#		my $bytes=$_myarray_k{$_}||0;
#		my $lastaccess=$_myarray_l{$_}||'';
#		print HISTORYTMP "${xmlrb}$_${xmlrs}", $_myarray_p{$_}, "${xmlrs}", $_myarray_h{$_}, "${xmlrs}", $_myarray_k{$_}, "${xmlrs}", $_myarray_l{$_}, "${xmlre}\n"; next;
#	}
#	foreach (keys %_myarray_h) {
#		if ($keysinkeylist{$_}) { next; }
#		my $page=$_myarray_p{$_}||0;
#		my $bytes=$_myarray_k{$_}||0;
#		my $lastaccess=$_myarray_l{$_}||'';
#		print HISTORYTMP "${xmlrb}$_${xmlrs}", $_myarray_p{$_}, "${xmlrs}", $_myarray_h{$_}, "${xmlrs}", $_myarray_k{$_}, "${xmlrs}", $_myarray_l{$_}, "${xmlre}\n"; next;
#	}
#	print HISTORYTMP "${xmleb}END_PLUGIN_example${xmlee}\n";
	# ----->
	return 0;
}


1;	# Do not remove this line

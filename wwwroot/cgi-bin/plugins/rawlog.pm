#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Rawlog AWStats plugin
# This plugin adds a form in AWStats main page to allow users to see raw
# content of current log files. A filter is also available.
#-----------------------------------------------------------------------------
# Perl Required Modules: None
#-----------------------------------------------------------------------------


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES.
# ----->
#use strict;
no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.7";
my $PluginHooksFunctions="AddHTMLBodyHeader BuildFullHTMLOutput";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$MAXLINE
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_rawlog {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin rawlog: InitParams=$InitParams",1);

	if ($QueryString =~ /rawlog_maxlines=(\d+)/i) { $MAXLINE=&DecodeEncodedString("$1"); }
	else { $MAXLINE=5000; }

	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLBodyHeader_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add HTML code at beginning of BODY section.
#-----------------------------------------------------------------------------
sub AddHTMLBodyHeader_rawlog {
	# <-----
	# Show form only if option -staticlinks not used
	if (! $StaticLinks) { &_ShowForm(''); }
	return 1;
	# ----->
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: BuildFullHTMLOutput_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to output an HTML page completely built by plugin instead
# of AWStats output
#-----------------------------------------------------------------------------
sub BuildFullHTMLOutput_rawlog {
	# <-----
	my $Filter='';
	if ($QueryString =~ /filterrawlog=([^&]+)/i) { $Filter=&DecodeEncodedString("$1"); }

    # A security check
	if ($QueryString =~ /logfile=/i) { 
	    print "<br />Option logfile is not allowed while building rawlog output.<br />";
        return 0;
	}

	# Show form
	&_ShowForm($Filter);

	# Precompiled regex Filter to speed up scan
	if ($Filter) { $Filter=qr/$Filter/i; }

	print "<hr />\n";
	
	# Show raws
	my $xml=($BuildReportFormat eq 'xhtml');
	open(LOG,"$LogFile") || error("Couldn't open server log file \"$LogFile\" : $!");
	binmode LOG;	# Avoid premature EOF due to log files corrupted with \cZ or bin chars
	my $i=0;
	print "<pre>";
	while (<LOG>) {
		chomp $_; $_ =~ s/\r//;
		if ($Filter && $_ !~ /$Filter/o) { next; }
		print ($xml?XMLEncode("$_"):"$_");
		print "\n";
		if (++$i >= $MAXLINE) { last; }
	}
	print "</pre><br />\n<b>$i lines.</b><br />";
	return 1;
	# ----->
}

sub _ShowForm {
	my $Filter=shift||'';
	print "<br />\n";
	print "<form action=\"$AWScript\" style=\"padding: 0px 0px 0px 0px; margin-top: 0\">\n";
	print "<table class=\"aws_border\" border=\"0\" cellpadding=\"2\" cellspacing=\"0\" width=\"100%\">\n";
	print "<tr><td>";
	print "<table class=\"aws_data\" border=\"0\" cellpadding=\"1\" cellspacing=\"0\" width=\"100%\">\n";
	print "<tr><td><span dir=\"ltr\"><b>Show content of file '$LogFile' ($MAXLINE first lines):</b></span></td></tr>\n";
	print "<tr><td>$Message[79]: <input type=\"text\" name=\"filterrawlog\" value=\"$Filter\" /> &nbsp; &nbsp; &nbsp; Max Number of Lines: <input type=\"text\" name=\"rawlog_maxlines\" size=\"5\" value=\"$MAXLINE\" /> &nbsp; &nbsp; &nbsp; <input type=\"submit\" value=\"List\" class=\"aws_button\" />\n";
	print "<input type=\"hidden\" name=\"config\" value=\"$SiteConfig\" /><input type=\"hidden\" name=\"framename\" value=\"$FrameName\" /><input type=\"hidden\" name=\"pluginmode\" value=\"rawlog\" />";
	print "</td></tr>\n";
	print "</table>\n";
	print "</td></tr></table>\n";
	print "</form>\n";
}

1;	# Do not remove this line

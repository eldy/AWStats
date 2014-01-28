#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Tooltips AWStats plugin
# This plugin allow you to add some toolpus in AWStats HTML report pages.
# The tooltip are in same language than the report (they are stored in the
# awstats-tt-codelanguage.txt files in lang directory).
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
my $PluginNeedAWStatsVersion="6.1";
my $PluginHooksFunctions="AddHTMLStyles AddHTMLBodyHeader";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$TOOLTIPWIDTH
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_tooltips {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin tooltips: InitParams=$InitParams",1);
	$TOOLTIPON=1;
	$TOOLTIPWIDTH=380;					# Width of tooltips
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLStyles_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add HTML styles at beginning of BODY section.
#-----------------------------------------------------------------------------
sub AddHTMLStyles_tooltips {
	# <-----
	print "div { font: 12px 'Arial','Verdana','Helvetica', sans-serif; text-align: justify; }\n";
	print ".CTooltip { position:absolute; top: 0px; left: 0px; z-index: 2; width: ${TOOLTIPWIDTH}px; visibility:hidden; font: 8pt 'MS Comic Sans','Arial',sans-serif; background-color: #FFFFE6; padding: 8px; border: 1px solid black; }\n";
	return 1;
	# ----->
}


#-----------------------------------------------------------------------------
# PLUGIN FUNTION: AddHTMLBodyHeader_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add HTML code at beginning of BODY section.
#-----------------------------------------------------------------------------
sub AddHTMLBodyHeader_tooltips {
	# <-----
	if ($FrameName ne 'mainleft') {

		# GET AND WRITE THE TOOLTIP STRINGS
		#---------------------------------------------------------------------
		&_ReadAndOutputTooltipFile($Lang);

		# WRITE TOOLTIPS JAVASCRIPT CODE
		#---------------------------------------------------------------------
		# Position .style.pixelLeft/.pixelHeight/.pixelWidth/.pixelTop	IE OK		Opera OK
		#          .style.left/.height/.width/.top						IE456 OK				Netscape67 OK	XHTML OK
		# document.getElementById										IE456 OK	Opera OK	Netscape67 OK	XHTML OK
		# document.body.offsetWidth|document.body.style.pixelWidth		IE OK		Opera OK	Netscape OK		XHTML KO	Visible width of container
		# document.documentElement.offsetWidth																	XHTML OK	Visible width of container
		# tooltipOBJ.offsetWidth|tooltipOBJ.style.pixelWidth			IE OK		Opera OK	Netscape OK					Width of an object
		# event.clientXY												IE OK		Opera OK	Netscape KO		XHTML KO	Position of mouse
		# window.innerHeight											IE OK					Netscape OK					Height of container

		# window.pageYOffset																								?
		# document.body.scrollTop                                       IE OK		Opera OK	Netscape OK		XHTML KO	Vertical position of scrollbar

		my $docwidth="document.body.offsetWidth";
		my $doctop="document.body.scrollTop";
		if ($BuildReportFormat eq 'xhtml' || $BuildReportFormat eq 'xml') {
			$docwidth="document.documentElement.offsetWidth";
			$doctop="document.documentElement.scrollTop";
		}

		print <<EOF;

<script type="text/javascript">
function ShowTip(fArg)
{
	var tooltipOBJ = (document.getElementById) ? document.getElementById('tt' + fArg) : eval("document.all['tt" + fArg + "']");
	if (tooltipOBJ != null) {
		var tooltipLft = ($docwidth?$docwidth:document.body.style.pixelWidth) - (tooltipOBJ.offsetWidth?tooltipOBJ.offsetWidth:(tooltipOBJ.style.pixelWidth?tooltipOBJ.style.pixelWidth:$TOOLTIPWIDTH)) - 30;
		var tooltipTop = 10;
		if (navigator.appName == 'Netscape') {
			tooltipTop = ($doctop>=0?$doctop+10:event.clientY+10);
 			tooltipOBJ.style.top = tooltipTop+"px";
			tooltipOBJ.style.left = tooltipLft+"px";
		}
		else {
			tooltipTop = ($doctop>=0?$doctop+10:event.clientY+10);
			tooltipTop = (document.body.scrollTop>=0?document.body.scrollTop+10:event.clientY+10);
EOF
		# Seul IE en HTML a besoin de code suppl�mentaire. IE en xhtml est OK
		if ($BuildReportFormat ne 'xhtml' && $BuildReportFormat ne 'xml') {
print <<EOF;
			if ((event.clientX > tooltipLft) && (event.clientY < (tooltipOBJ.scrollHeight?tooltipOBJ.scrollHeight:tooltipOBJ.style.pixelHeight) + 10)) {
				tooltipTop = ($doctop?$doctop:document.body.offsetTop) + event.clientY + 20;
			}
EOF
		}
print <<EOF;
			tooltipOBJ.style.left = tooltipLft;
			tooltipOBJ.style.top = tooltipTop;
		}
		tooltipOBJ.style.visibility = "visible";
	}
}
function HideTip(fArg)
{
	var tooltipOBJ = (document.getElementById) ? document.getElementById('tt' + fArg) : eval("document.all['tt" + fArg + "']");
	if (tooltipOBJ != null) {
		tooltipOBJ.style.visibility = "hidden";
	}
}
</script>

EOF

	}
	return 1;
	# ----->
}


#------------------------------------------------------------------------------
# Function:     Get the tooltip texts for a specified language and write it
# Parameters:	LanguageId
# Input:		$DirLang $DIR
# Output:		Full tooltips text
# Return:		None
#------------------------------------------------------------------------------
sub _ReadAndOutputTooltipFile {
	# Check lang files in common possible directories :
	# Windows and standard package:         	"$DIR/lang" (lang in same dir than awstats.pl)
	# Debian package :                    		"/usr/share/awstats/lang"
	# Other possible directories :        		"./lang"
	my @PossibleLangDir=("$DirLang","${DIR}/lang","/usr/share/awstats/lang","./lang");

	my $FileLang='';
	my $logtype=lc($LogType ne 'S'?$LogType:'W');
	foreach my $dir (@PossibleLangDir) {
		my $searchdir=$dir;
		if ($searchdir && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
		if (open(LANG,"${searchdir}tooltips_${logtype}/awstats-tt-$_[0].txt")) { $FileLang="${searchdir}tooltips_${logtype}/awstats-tt-$_[0].txt"; last; }
	}
	# If file not found, we try english
	if (! $FileLang) {
		foreach my $dir (@PossibleLangDir) {
			my $searchdir=$dir;
			if ($searchdir && (!($searchdir =~ /\/$/)) && (!($searchdir =~ /\\$/)) ) { $searchdir .= "/"; }
			if (open(LANG,"${searchdir}tooltips_${logtype}/awstats-tt-en.txt")) { $FileLang="${searchdir}tooltips_${logtype}/awstats-tt-en.txt"; last; }
		}
	}
	if ($Debug) { debug(" Plugin tooltips: Call to Read_Language_Tooltip [FileLang=\"$FileLang\"]"); }
	if ($FileLang) {
		my $aws_PROG=ucfirst($PROG);
		my $aws_VisitTimeout = $VISITTIMEOUT/10000*60;
		my $aws_NbOfRobots = scalar keys %RobotsHashIDLib;
		my $aws_NbOfWorms = scalar @WormsSearchIDOrder;
		my $aws_NbOfSearchEngines = scalar keys %SearchEnginesHashLib;
		while (<LANG>) {
			if ($_ =~ /\<!--/) { next; }	# Remove comment
			# Search for replaceable parameters
			s/#PROG#/$aws_PROG/;
			s/#MaxNbOfRefererShown#/$MaxNbOf{'RefererShown'}/;
			s/#VisitTimeOut#/$aws_VisitTimeout/;
			s/#RobotArray#/$aws_NbOfRobots/;
			s/#WormsArray#/$aws_NbOfWorms/;
			s/#SearchEnginesArray#/$aws_NbOfSearchEngines/;
			print "$_";
		}
	}
	close(LANG);
}


1;	# Do not remove this line

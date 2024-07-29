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
my $PluginNeedAWStatsVersion="8.0";
my $PluginHooksFunctions="AddHTMLStyles getTooltip";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$TOOLTIPLIST
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
	$TOOLTIPLIST = &_ReadAndOutputTooltipFile($Lang);
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
	return '.CTooltip { position:absolute; top: 0px; left: 0px; z-index: 2; width: ${TOOLTIPWIDTH}px; visibility:hidden; background-color: #FFFFE6; padding: 8px; border: 1px solid black; }';
	# ----->
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLJavascript_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add Javascript at beginning of BODY section.
#-----------------------------------------------------------------------------
sub getTooltip_tooltips {
	# <-----
	my $tooltipnb = shift;
	return $TOOLTIPLIST{'tt' . $tooltipnb};
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
			if ($_ !~ /\S/) { next; }	# Remove empty lines
			# Search for replaceable parameters
			s/#PROG#/$aws_PROG/;
			s/#MaxNbOfRefererShown#/$MaxNbOf{'RefererShown'}/;
			s/#VisitTimeOut#/$aws_VisitTimeout/;
			s/#RobotArray#/$aws_NbOfRobots/;
			s/#WormsArray#/$aws_NbOfWorms/;
			s/#SearchEnginesArray#/$aws_NbOfSearchEngines/;
			my ($nb, $value) = split('=', $_); 
			$TOOLTIPLIST{$nb} = $value;
		}
	}
	close(LANG);
}


1;	# Do not remove this line

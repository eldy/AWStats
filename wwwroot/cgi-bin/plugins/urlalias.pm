#!/usr/bin/perl
#-----------------------------------------------------------------------------
# UrlAlias AWStats plugin
# This plugin allow you to report all URL links with a text title instead of
# URL value.
# You must create a file called urlalias.cnfigvalue.txt and store it in
# plugin directory that contains 2 columns separated by a tab char.
# First column is URL value and second column is text title to use instead of.
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
my $PluginNeedAWStatsVersion="5.5";
my $PluginHooksFunctions="ShowInfoURL";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$urlinfoloaded
%UrlAlias
@UrlMatch
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_urlalias {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" InitParams=$InitParams",1);
	$urlinfoloaded=0;
	%UrlAlias=();
	@UrlMatch=();
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoURL_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal information for URLs in URLs' report.
# This function is called after writing the URL value in the URL cell of the
# Top Pages-URL report.
# Parameters: URL
#-----------------------------------------------------------------------------
sub ShowInfoURL_urlalias {
	# <-----
	my $urltoshow="$_[0]";
	my $found = 0;			# flag for testing for whether a match occurs.  unused at present 
	my $filetoload='';		# unused at present
	my $filetoload2='';		# unused at present
	if ($urltoshow && ! $urlinfoloaded) {
		# Load urlalias and match files
		if ($SiteConfig && open(URLALIASFILE,"$DirData/urlalias.$SiteConfig.txt"))	{ $filetoload2="$PluginDir/urlalias.$SiteConfig.txt"; }
		elsif (open(URLALIASFILE,"$DirData/urlalias.txt"))  						{ $filetoload2="$PluginDir/urlalias.txt"; }
		else { error("Couldn't open UrlAlias file \"$DirData/urlalias.txt\": $!"); }
		if ($SiteConfig && open(URLMATCHFILE,"$DirData/urlmatch.$SiteConfig.txt"))	{ $filetoload="$PluginDir/urlmatch.$SiteConfig.txt"; }
		elsif (open(URLMATCHFILE,"$DirData/urlmatch.txt"))  						{ $filetoload="$PluginDir/urlmatch.txt"; }
		# Load UrlAlias
		%UrlAlias = map(/^([^\t]+)\t+([^\t]+)/o,<URLALIASFILE>);
		# Load UrlMatch
		my $iter = 0;
		foreach my $key (<URLMATCHFILE>) {
			$key =~ /^([^\t]+)\t+([^\t]+)/o;
			$UrlMatch[$iter][0] = $1;
			$UrlMatch[$iter][1] = $2;
			$iter++;
		}
		close URLALIASFILE;
		close URLMATCHFILE;
		debug("UrlAlias file loaded: ".(scalar keys %UrlAlias)." entries found.");
		debug("UrlMatch file loaded: ".(scalar @UrlMatch)." entries found.");
		$urlinfoloaded=1;
	}
	if ($urltoshow) {
		if ($UrlAlias{$urltoshow}) {
 			print "<font style=\"color: $color_link; font-weight: bold\">$UrlAlias{$urltoshow}</font><br>"; 
			$found=1;
		}
		else {
			foreach my $iter (0..@UrlMatch-1) {
				my $key = $UrlMatch[$iter][0];
				if ( $urltoshow =~ /$key/ ) {
 					print "<font style=\"color: #$color_link; font-weight: bold\">$UrlMatch[$iter][1]</font><br>"; 
					$UrlAlias{$urltoshow} = $UrlMatch[$iter][1];
					if ($SiteConfig && open(URLALIASFILE,">> $PluginDir/urlalias.$SiteConfig.txt")) { 
						$filetoload="$PluginDir/urlalias.$SiteConfig.txt"; 
					}
					elsif (open(URLALIASFILE,">> $PluginDir/urlalias.txt")) { 
						$filetoload="$PluginDir/urlalias.txt"; 
					}
					else { 
						error("Couldn't open UrlAlias file \"$PluginDir/urlalias.txt\": $!"); 
					}
					print URLALIASFILE "$urltoshow\t$UrlAlias{$urltoshow}";
					close URLALIASFILE;
					$found = 1;
					last;
				}
			}
		}
		if (!$found) {
		# does nothing right now
			print "";
		}
	}
	else { print ""; }	# Url info title
	return 1;
	# ----->
}


1;	# Do not remove this line

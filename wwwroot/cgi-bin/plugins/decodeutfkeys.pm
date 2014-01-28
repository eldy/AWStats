#!/usr/bin/perl
#-----------------------------------------------------------------------------
# decodeUTFKeys AWStats plugin
# Allow AWStats to convert keywords strings coded by some search engines in
# UTF8 coding to a common string in a local charset.
#-----------------------------------------------------------------------------
# Perl Required Modules: Encode and URI::Escape
#-----------------------------------------------------------------------------


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
if (!eval ('require "Encode.pm"')) { return $@?"Error: $@":"Error: Need Perl module Encode"; }
if (!eval ('require "URI/Escape.pm"')) { return $@?"Error: $@":"Error: Need Perl module URI::Escape"; }
#if (!eval ('require "HTML/Entities.pm"')) { return $@?"Error: $@":"Error: Need Perl module HTML::Entities"; }
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="6.0";
my $PluginHooksFunctions="DecodeKey";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_decodeutfkeys {
	my $InitParams=shift;

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	# ----->

	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#------------------------------------------------------------------------------
# Function:     Converts an UTF8 string to specified Charset
# Parameters:	utfstringtodecode charsettoencode
# Return:		newencodedstring
#------------------------------------------------------------------------------
sub DecodeKey_decodeutfkeys {
	my $string = shift;
	my $encoding = shift;
	if (! $encoding) { error("Function DecodeKey from plugin decodeutfkeys was called but AWStats don't know language code required to output new value."); }
	$string =~ s/\\x(\w\w)/%$1/gi;	# Change "\xc4\xbe\xd7\xd3\xc3\xc0" into "%c4%be%d7%d3%c3%c0"
	$string=URI::Escape::uri_unescape($string);
	if ( $string =~ m/^(?:[\x00-\x7f]|[\xc2-\xdf][\x80-\xbf]|\xe0[\xa0-\xbf][\x80-\xbf]|[\xe1-\xef][\x80-\xbf][\x80-\xbf]|\xf0[\x90-\xbf][\x80-\xbf][\x80-\xbf]|[\xf1-\xf7][\x80-\xbf][\x80-\xbf][\x80-\xbf])*$/ )
	{
		$string=Encode::encode($encoding, Encode::decode("utf-8", $string));
	}
	#$string=HTML::Entities::encode_entities($string);
	$string =~ s/[;+]/ /g;
	return $string;
}


1;	# Do not remove this line

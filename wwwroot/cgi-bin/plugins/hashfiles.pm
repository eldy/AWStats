#!/usr/bin/perl
#-----------------------------------------------------------------------------
# HashFiles AWStats plugin
# Allows AWStats to read/save its data file as native hash files.
# This increase read andwrite files operations.
#-----------------------------------------------------------------------------
# Perl Required Modules: Storable
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
if (!eval ('require "Storable.pm";')) 	{ return "Error: Need Perl module Storable"; }
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.1";
my $PluginHooksFunctions="SearchFile LoadCache SaveHash";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$PluginHashfilesUpToDate
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_hashfiles {
	my $InitParams=shift;

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	$PluginHashfilesUpToDate=1;
	# ----->

	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNTION: SearchFile_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
#-----------------------------------------------------------------------------
sub SearchFile_hashfiles {
	my ($searchdir,$dnscachefile,$filesuffix,$dnscacheext,$filetoload)=@_;	# Get params sent by ref
	if (-f "${searchdir}$dnscachefile$filesuffix.hash") {
		my ($tmp1a,$tmp2a,$tmp3a,$tmp4a,$tmp5a,$tmp6a,$tmp7a,$tmp8a,$tmp9a,$datesource,$tmp10a,$tmp11a,$tmp12a) = stat("${searchdir}$dnscachefile$filesuffix$dnscacheext");
		my ($tmp1b,$tmp2b,$tmp3b,$tmp4b,$tmp5b,$tmp6b,$tmp7b,$tmp8b,$tmp9b,$datehash,$tmp10b,$tmp11b,$tmp12b) = stat("${searchdir}$dnscachefile$filesuffix.hash");
		if ($datesource && $datehash < $datesource) {
			$PluginHashfilesUpToDate=0;
			debug(" Hash file not up to date. Will use source file $filetoload instead.");
		}
		else {
			# There is no source file or there is and hash file is up to date. We can just load hash file
			$filetoload="${searchdir}$dnscachefile$filesuffix.hash";
		}
	}
	elsif ($filetoload) {
		$PluginHashfilesUpToDate=0;
		debug(" Hash file not found. Will use source file $filetoload instead.");
	}
	# Change calling params
	$_[4]=$filetoload;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: LoadCache_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
#-----------------------------------------------------------------------------
sub LoadCache_hashfiles {
	my ($filetoload,$hashtoload)=@_;
	if ($filetoload =~ /\.hash$/) {
		# There is no source file or there is and hash file is up to date. We can just load hash file
		eval('%$hashtoload = %{ retrieve("$filetoload") };');
	}
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SaveHash_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
#-----------------------------------------------------------------------------
sub SaveHash_hashfiles {
	my ($filetosave,$hashtosave,$testifuptodate,$nbmaxofelemtosave,$nbofelemsaved)=@_;
	if (! $testifuptodate || ! $PluginHashfilesUpToDate) {
		$filetosave =~ s/(\.\w+)$//; $filetosave.=".hash";
		debug(" Save data ".($nbmaxofelemtosave?"($nbmaxofelemtosave records max)":"(all records)")." into hash file $filetosave");
		if (! $nbmaxofelemtosave || (scalar keys %$hashtosave <= $nbmaxofelemtosave)) {
			# Save all hash array
			eval('store(\%$hashtosave, "$filetosave");');
			$_[4]=scalar keys %$hashtosave;
		}
		else {
			debug(" We need to resize hash to save from ".(scalar keys %$hashtosave)." to $nbmaxofelemtosave");
			# Save part of hash array
			my $counter=0;
			my %newhashtosave=();
			foreach my $key (keys %$hashtosave) {
				$newhashtosave{$key}=$hashtosave->{$key};
				if (++$counter >= $nbmaxofelemtosave) { last; }
			}
			eval('store(\%newhashtosave, "$filetosave");');
			$_[4]=scalar keys %newhashtosave;
		}
		$_[0]=$filetosave;
	}
	else {
		$_[4]=0;
	}
}


1;	# Do not remove this line

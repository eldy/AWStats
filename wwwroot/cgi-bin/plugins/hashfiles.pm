#!/usr/bin/perl
#-----------------------------------------------------------------------------
# HashFiles AWStats plugin
# Allows AWStats to read/save its data file as native hash files.
# This increase read andwrite files operations.
#-----------------------------------------------------------------------------
# Perl Required Modules: Storable
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


use Storable;
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
my $PluginNeedAWStatsVersion="5.1";
my $PluginHooksFunctions="SearchFile LoadCache SaveHash";

use vars qw/
$PluginHashfilesUpToDate
/;



#-----------------------------------------------------------------------------
# PLUGIN FUNTION Init_pluginname
#-----------------------------------------------------------------------------
sub Init_hashfiles {
	my $AWStatsVersion=shift;
	$PluginHashfilesUpToDate=1;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNTION SearchFile_pluginname
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
# PLUGIN FUNTION LoadCache_pluginname
#-----------------------------------------------------------------------------
sub LoadCache_hashfiles {
	my ($filetoload,$hashtoload)=@_;
	if ($filetoload =~ /\.hash$/) {
		# There is no source file or there is and hash file is up to date. We can just load hash file
		eval('%$hashtoload = %{ retrieve("$filetoload") };');
	}
}


#-----------------------------------------------------------------------------
# PLUGIN FUNTION SaveHash_pluginname
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

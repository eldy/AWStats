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
my $Plugin_need_awstats_version=5001;
use vars qw/
$hashfileuptodate
/;
#...


#-----------------------------------------------------------------------------
# PLUGIN Init_check_Version FUNCTION
#-----------------------------------------------------------------------------
sub Init_hashfiles_Check_Version {
	my $AWStats_Version=shift;
	if (! $Plugin_need_awstats_version) { return 0; }
	$AWStats_Version =~ /^(\d+)\.(\d+)/;
	my $versionnum=($1*1000)+$2;
	if 	($Plugin_need_awstats_version > $versionnum) {
		my $maj=int($Plugin_need_awstats_version/1000);
		my $min=$Plugin_need_awstats_version % 1000;
		return "Error: AWStats version $maj.$min or higher is required.";
	}
	return 0;
}

#-----------------------------------------------------------------------------
# PLUGIN Init_pluginname FUNCTION
#-----------------------------------------------------------------------------
sub Init_hashfiles {
	my $AWStats_Version=shift;
	$hashfileuptodate=1;
	my $checkversion=Init_hashfiles_Check_Version($AWStats_Version);
	return ($checkversion?$checkversion:1);
}


#-----------------------------------------------------------------------------
# PLUGIN SearchFile_pluginname FUNCTION
#-----------------------------------------------------------------------------
sub SearchFile_hashfiles {
	my ($searchdir,$dnscachefile,$filesuffix,$dnscacheext,$filetoload)=@_;	# Get params sent by ref
	if (-f "${searchdir}$dnscachefile$filesuffix.hash") {
		my ($tmp1a,$tmp2a,$tmp3a,$tmp4a,$tmp5a,$tmp6a,$tmp7a,$tmp8a,$tmp9a,$datesource,$tmp10a,$tmp11a,$tmp12a) = stat("${searchdir}$dnscachefile$filesuffix$dnscacheext");
		my ($tmp1b,$tmp2b,$tmp3b,$tmp4b,$tmp5b,$tmp6b,$tmp7b,$tmp8b,$tmp9b,$datehash,$tmp10b,$tmp11b,$tmp12b) = stat("${searchdir}$dnscachefile$filesuffix.hash");
		if ($datesource && $datehash < $datesource) {
			$hashfileuptodate=0;
			debug(" Hash file not up to date. Will use source file $filetoload instead.");
		}
		else {
			# There is no source file or there is and hash file is up to date. We can just load hash file
			$filetoload="${searchdir}$dnscachefile$filesuffix.hash";
		}
	}
	elsif ($filetoload) {
		$hashfileuptodate=0;
		debug(" Hash file not found. Will use source file $filetoload instead.");
	}
	# Change calling params
	$_[4]=$filetoload;
}


#-----------------------------------------------------------------------------
# PLUGIN LoadCache_pluginname FUNCTION
#-----------------------------------------------------------------------------
sub LoadCache_hashfiles {
	my ($filetoload,$hashtoload)=@_;
	if ($filetoload =~ /\.hash$/) {
		# There is no source file or there is and hash file is up to date. We can just load hash file
		eval('%$hashtoload = %{ retrieve("$filetoload") };');
	}
}


#-----------------------------------------------------------------------------
# PLUGIN SaveHash_pluginname FUNCTION
#-----------------------------------------------------------------------------
sub SaveHash_hashfiles {
	my ($filetosave,$hashtosave,$testifuptodate,$nbmaxofelemtosave,$nbofelemsaved)=@_;
	if (! $testifuptodate || ! $hashfileuptodate) {
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



#-----------------------------------------------------------------------------
# PLUGIN ShowField_pluginname FUNCTION
#-----------------------------------------------------------------------------
#...



#-----------------------------------------------------------------------------
# PLUGIN Filter_pluginname FUNCTION
#-----------------------------------------------------------------------------
#...



1;	# Do not remove this line

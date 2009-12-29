#!/usr/bin/perl
#-----------------------------------------------------------------------------
# TimeZone AWStats reloaded plugin
#
# Allow AWStats to convert GMT time stamps to local time zone
# taking into account daylight saving time.
# If the POSIX module is available, a target time zone name
# can be provided, otherwise the default system local time is used.
# For compatibility with the original version of this plugin, "-/+hours"
# is interpreted as a fixed difference to GMT.
#
# 2009 jacob@internet24.de
#-----------------------------------------------------------------------------
# Perl Required Modules: POSIX
#-----------------------------------------------------------------------------


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!! This plugin reduces AWStats speed by about 10% !!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.1";
my $PluginHooksFunctions="ChangeTime GetTimeZoneTitle";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$PluginTimeZoneZone
$PluginTimeZoneCache
/;
# ----->


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_timezone {
	my $InitParams=shift;

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	if ($InitParams) 
	{
		if (!eval ('require "POSIX.pm"')) 
		{ 
			return $@?"Error: $@":"Error: Need Perl module POSIX"; 
		}
	}

	$PluginTimeZoneZone = "$InitParams";
	$PluginTimeZoneCache = {};
	# ----->

	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ChangeTime_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
#-----------------------------------------------------------------------------
sub ChangeTime_timezone {
	my @d = @{$_[0]};
	my $e = $PluginTimeZoneCache->{$d[2]};
	my ($i);


	unless ($e) {
		$e = $PluginTimeZoneCache->{$d[2]} = [
			tz_find_zone_diff($PluginTimeZoneZone, $d[2]),
			tz_find_month_length($PluginTimeZoneZone, $d[2])
		]
	}

	INTERVAL: foreach $i (@{@$e[0]}) {
		foreach (1,0,3,4,5) {
			next INTERVAL if $d[$_]>@$i[$_];
			last if $d[$_]<@$i[$_];
		}

		$d[5] += @$i[8];
		if ( $d[5]<0 ) {
			$d[5] += 60, $d[4]--;
		} elsif ( $d[5]>59 ) {
			$d[5] -= 60, $d[4]++;
		}

		$d[4] += @$i[7];
		if ( $d[4]<0 ) {
			$d[4] += 60, $d[3]--;
		} elsif ( $d[4]>59 ) {
			$d[4] -= 60, $d[3]++;
		}

		$d[3] += @$i[6];
		if ( $d[3]<0 ) {
			$d[3] += 24, $d[0]--;
		} elsif ( $d[3]>23 ) {
			$d[3] -= 24, $d[0]++;
		} else {
			return @d;
		}

		if ($d[0]<1) {
			$d[1]--;
			if ( $d[1]<1 ) {
				$d[2]--, $d[1] = 12, $d[0] = 31;
			} else {
				$d[0] = $e->[1][$d[1]];
			}
		} elsif ($d[0]>$e->[1][$d[1]]) {
			$d[1]++, $d[0]=1;
			if ( $d[1]>12 ) {
				$d[2]++, $d[1] = 1;
			}
		}

		return @d;
	}

	# This should never be reached
	return @d;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetTimeZoneTitle_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
#-----------------------------------------------------------------------------
sub GetTimeZoneTitle_timezone {
	return $PluginTimeZoneZone;
}


#-----------------------------------------------------------------------------
# Tools
#-----------------------------------------------------------------------------

# convenience wrappers
sub tz_mktime
{
	return timegm($_[0], $_[1], $_[2], 
		$_[3], $_[4]-1, $_[5]-1900, 0, 0, -1);
}
sub tz_interval
{
	my ($time, $shift) = @_;
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
		gmtime($time);

	return [
		$mday,
		$mon+1,
		2147483647, # max(int32)
		$hour,
		$min,
		$sec,
		int($shift/3600),
		int(($shift%3600)/60),
		int(($shift%60)),
	]
}


# return largest $value between $left and $right
# whose tz_shift is equal to that of $left
sub tz_find_break
{
	my ($left, $right) = @_;

	return undef if $left>$right;

	return $left if ($right-$left)<=1;

	my $middle = int(($right+$left)/2);
	my ($leftshift, $rightshift, $middleshift) = 
		(tz_shift($left), tz_shift($right), tz_shift($middle));

	if ($leftshift == $middleshift) {
		return undef if $rightshift == $middleshift;
		return tz_find_break($middle, $right);
	}
	elsif ($rightshift == $middleshift) {
		return tz_find_break($left, $middle);
	}
}


# compute difference beetween localtime and gmtime in seconds
# for unix time stamp $time
sub tz_shift
{
	my ($time) = @_;

	my ($lsec,$lmin,$lhour,$lmday,$lmon,$lyear,$lwday,$lyday,$lisdst) =
		localtime($time);
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
		gmtime($time);

	my $day_change = $lyear-$year;
	$day_change = $lmon-$mon unless $day_change;
	$day_change = $lmday-$mday unless $day_change;

	my $hour_diff = $lhour-$hour;
	my $min_diff = $lmin-$min;
	my $sec_diff = $lsec-$sec;

	if ($day_change>0) {
		$hour_diff +=24;
	}
	elsif($day_change<0) {
		$hour_diff -=24;
	}

	return (($hour_diff*60)+$min_diff)*60+$sec_diff;
}


# Compute time zone shift intervals for $year
# and time zone $zone
sub tz_find_zone_diff
{
	my ($zone, $year) = @_;

	my $othertz = $PluginTimeZoneZone &&
		$PluginTimeZoneZone !~ m/^[+-]?\d+$/;
	
	my ($left, $middle, $right);
	my ($leftshift, $middleshift, $rightshift);

	{
		local $ENV{TZ} = $zone
			if $othertz;

		$left = tz_mktime(0,0,0,1,1,$year);
		$middle = tz_mktime(0,0,0,1,7,$year);
		$right = tz_mktime(59,59,23,31,12,$year);

		if (!$PluginTimeZoneZone || $PluginTimeZoneZone !~ m/^[+-]?\d+$/)
		{	
			$leftshift = tz_shift($left);
			$middleshift = tz_shift($middle);
			$rightshift = tz_shift($right)
		}
		else
		{
			$leftshift = $middleshift = $rightshift =
				int($PluginTimeZoneZone)*3600;
		}
	
		if ($leftshift != $rightshift || $rightshift != $middleshift) {
			return
				[
					tz_interval(tz_find_break($left, $middle), $leftshift),
					tz_interval(tz_find_break($middle, $right), $middleshift),
					tz_interval($right, $rightshift)
				]
		}

		POSIX::tzset() if $othertz;
	}
	
	POSIX::tzset() if $othertz;

	return [ tz_interval($right, $rightshift) ]
}


# Compute number of days in all months for $year
sub tz_find_month_length
{
	my ($zone, $year) = @_;
	
	my $othertz = $PluginTimeZoneZone && 
		$PluginTimeZoneZone !~ m/^[+-]?\d+$/;

	my $months = [ undef, 31, 28, 31, 30, 31, 30,
		31, 31, 30, 31, 30, 31 ];

	{
		local $ENV{TZ} = $zone
			if $othertz;

		# leap year?
		$months->[2] = 29 if
			(localtime(tz_mktime(0, 0, 12, 28, 2, $year)+86400))[4]
			== 1;

		POSIX::tzset() if $othertz;
	}

	POSIX::tzset() if $othertz;

	return $months;
}


1;	# Do not remove this line

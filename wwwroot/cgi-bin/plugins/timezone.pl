#!/usr/bin/perl
#-----------------------------------------------------------------------------
# TimeZone AWStats plugin
# Allow AWStats to correct a bad timezone for user of IIS that use strange
# log format.
#-----------------------------------------------------------------------------
# Perl Required Modules: None
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


# Warning: 
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!! This module reduce VERY dramatically AWStats speed !!!!!!!
# !!!!!!! Do not use on large web sites                      !!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


$PluginTimeZone=1;

my $TZ=+2;
$PluginTimeZoneSeconds=($TZ*3600);


1;	# Do not remove this line

#!/usr/bin/perl
#-----------------------------------------------------------------------------
# TimeHires AWStats plugin
# Change time accuracy in showsteps option from seconds to milliseconds
#-----------------------------------------------------------------------------
# Perl Required Modules: Time::HiRes
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$

use Time::HiRes qw( gettimeofday );


$PluginTimeHiRes=1;

1;	# Do not remove this line

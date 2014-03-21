#!/usr/bin/perl
#-----------------------------------------------------------------------------
# IPv6 AWStats plugin
# This plugin allow AWStats to make reverse DNS Lookup on IPv6 addresses.
#-----------------------------------------------------------------------------
# Perl Required Modules: Net::IP and Net::DNS
#-----------------------------------------------------------------------------


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
if (!eval ('require "Net/IP.pm";'))		{ return $@?"Error: $@":"Error: Need Perl module Net::IP"; }
if (!eval ('require "Net/DNS.pm";')) 	{ return $@?"Error: $@":"Error: Need Perl module Net::DNS"; }
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="5.5";
my $PluginHooksFunctions="GetResolvedIP";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$resolver
/;
# ----->


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_ipv6 {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin ipv6: InitParams=$InitParams",1);
	$resolver = Net::DNS::Resolver->new;
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetResolvedIP_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetResolvedIP is called to resolve an IPv6 address into a host name
#-----------------------------------------------------------------------------
sub GetResolvedIP_ipv6 {
	# <-----
	my $ip = new Net::IP($_[0]);
	my $reverseip= $ip->reverse_ip();
	my $query = $resolver->query($reverseip, "PTR");
	if (! defined($query)) { return; }
	my @result=split(/\s/, ($query->answer)[0]->string);
	chop($result[4]); # Remove the trailing dot of the answer.
	return $result[4];
	# ----->
}


1;	# Do not remove this line

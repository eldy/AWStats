#!/usr/bin/perl
#-----------------------------------------------------------------------------
# HostInfo AWStats plugin
# This plugin allow you to add information on hosts, like whois fields.
#-----------------------------------------------------------------------------
# Perl Required Modules: XWhois
#-----------------------------------------------------------------------------


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
push @INC, "${DIR}/plugins";
if (!eval ('require "Net/XWhois.pm";')) { return $@?"Error: $@":"Error: Need Perl module Net::XWhois"; }
if (!eval ('require "Digest/MD5.pm";')) { return $@?"Error: $@":"Error: Need Perl module Digest::MD5"; }
# ----->
#use strict;
no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="6.0";
my $PluginHooksFunctions="ShowInfoHost AddHTMLBodyHeader BuildFullHTMLOutput";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_hostinfo {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);

	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin hostinfo: InitParams=$InitParams",1);
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLBodyHeader_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to Add HTML code at beginning of BODY section.
# Parameters: None
#-----------------------------------------------------------------------------
sub AddHTMLBodyHeader_hostinfo {
	# <-----
	my $WIDTHINFO=640;
	my $HEIGHTINFO=480;

	my $urlparam="pluginmode=hostinfo&config=$SiteConfig";
	$urlparam.=($DirConfig?"&configdir=$DirConfig":"");
	
	print <<EOF;

<script type="text/javascript">
function neww(a,b) {
var wfeatures="directories=0,menubar=1,status=0,resizable=1,scrollbars=1,toolbar=0,width=$WIDTHINFO,height=$HEIGHTINFO,left=" + eval("(screen.width - $WIDTHINFO)/2") + ",top=" + eval("(screen.height - $HEIGHTINFO)/2");
EOF
	print "fen=window.open('".XMLEncode("$AWScript?$urlparam&host")."='+a+'".XMLEncode("&key")."='+b,'whois',wfeatures);\n";
print <<EOF;
}
</script>

EOF

	return 1;
	# ----->
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: ShowInfoHost_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to add additionnal columns to the Hosts report.
# This function is called when building rows of the report (One call for each
# row). So it allows you to add a column in report, for example with code :
#   print "<TD>This is a new cell for $param</TD>";
# Parameters: Host name or ip
#-----------------------------------------------------------------------------
sub ShowInfoHost_hostinfo {
    my $param="$_[0]";
	# <-----
	if ($param eq '__title__') {
		print "<th width=\"40\">$Message[114]</th>";	
	}
	elsif ($param) {
		my $keyforwhois;
		if ($param =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {	# IPv4 address
			$keyforwhois=$param;
		}
		elsif ($param =~ /^[0-9A-F]*:/i) {						# IPv6 address
			$keyforwhois=$param;
		}
		else {	# Hostname
			$param =~ /([-\w]+\.[-\w]+\.(?:au|uk|jp|nz))$/ or $param =~ /([-\w]+\.[-\w]+)$/;
			$keyforwhois=$1;
		}
		print "<td>";
#		if ($keyforwhois) { print "<a href=\"javascript:neww('$keyforwhois','".md5_hex("${keyforwhois}XXX")."')\">?</a>"; }
		if ($keyforwhois) { print "<a href=\"javascript:neww('$keyforwhois','${keyforwhois}XXX')\">?</a>"; }
		else { print "&nbsp;" }
		print "</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	return 1;
	# ----->
}


#-----------------------------------------------------------------------------
# PLUGIN FUNTION: BuildFullHTMLOutput_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
# Function called to output an HTML page completely built by plugin instead
# of AWStats output
#-----------------------------------------------------------------------------
sub BuildFullHTMLOutput_hostinfo {
	# <-----
	my $Host='';
	if ($QueryString =~ /host=([^&]+)/i) {
		$Host=lc(&DecodeEncodedString("$1"));
	}

	my $ip='';
	my $HostResolved='';
#	my $regipv4=qr/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
#	my $regipv6=qr/^[0-9A-F]*:/i;
#	if ($Host =~ /$regipv4/o) { $ip=4; }
#	elsif ($Host =~ /$regipv6/o) { $ip=6; }
#	if ($ip == 4) {
#		my $lookupresult=lc(gethostbyaddr(pack("C4",split(/\./,$Host)),AF_INET));	# This is very slow, may spend 20 seconds
#		if (! $lookupresult || $lookupresult =~ /$regipv4/o || ! IsAscii($lookupresult)) {
#			$HostResolved='*';
#		}
#		else {
#			$HostResolved=$lookupresult;
#		}
#		if ($Debug) { debug("  Reverse DNS lookup for $Host done: $HostResolved",4); }
#	}
	if (! $ip) { $HostResolved=$Host; }

	if ($Debug) { debug("  Plugin hostinfo: DirData=$DirData Host=$Host HostResolved=$HostResolved ",4); }
	my $w = new Net::XWhois Verbose=>$Debug, Cache=>$DirData, NoCache=>0, Timeout=>10, Domain=>$HostResolved;

	print "<br />\n";
	
	if ($w && $w->response()) {
		&tab_head("Common Whois Fields",0,0,'whois');
		print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>Common field info</th><th>Value</th></tr>\n";
		print "<tr><td>Name</td><td>".($w->name())."&nbsp;</td></tr>";
		print "<tr><td>Status</td><td>".($w->status())."&nbsp;</td></tr>";
		print "<tr><td>NameServers</td><td>".($w->nameservers())."&nbsp;</td></tr>";
		print "<tr><td>Registrant</td><td>".($w->registrant())."&nbsp;</td></tr>";
		print "<tr><td>Contact Admin</td><td>".($w->contact_admin())."&nbsp;</td></tr>";
		print "<tr><td>Contact Tech</td><td>".($w->contact_tech())."&nbsp;</td></tr>";
		print "<tr><td>Contact Billing</td><td>".($w->contact_billing())."&nbsp;</td></tr>";
		print "<tr><td>Contact Zone</td><td>".($w->contact_zone())."&nbsp;</td></tr>";
		print "<tr><td>Contact Emails</td><td>".($w->contact_emails())."&nbsp;</td></tr>";
		print "<tr><td>Contact Handles</td><td>".($w->contact_handles())."&nbsp;</td></tr>";
		print "<tr><td>Domain Handles</td><td>".($w->domain_handles())."&nbsp;</td></tr>";
		&tab_end;
	}

	&tab_head("Full Whois Field",0,0,'whois');
	if ($w && $w->response()) {
		print "<tr><td class=\"aws\"><pre>".($w->response())."</pre></td></tr>\n";
	}
	else {
		print "<tr><td><br />The Whois command failed.<br />Did the server running AWStats is allowed to send WhoIs queries (If a firewall is running, port 43 should be opened from inside to outside) ?<br /><br /></td></tr>\n";
	}
	&tab_end;

	return 1;
	# ----->
}

1;	# Do not remove this line

#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GeoIp_Org_Maxmind AWStats plugin
# This plugin allow you to add a city report.
# Need the licensed ISP database from Maxmind.
#-----------------------------------------------------------------------------
# Perl Required Modules: Geo::IP or Geo::IP::PurePerl
#-----------------------------------------------------------------------------


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
use vars qw/ $type /;
$type='geoip';
if (!eval ('require "Geo/IP.pm";')) {
	$error1=$@;
	$type='geoippureperl';
	if (!eval ('require "Geo/IP/PurePerl.pm";')) {
		$error2=$@;
		$ret=($error1||$error2)?"Error:\n$error1$error2":"";
		$ret.="Error: Need Perl module Geo::IP or Geo::IP::PurePerl";
		return $ret;
	}
}
# ----->
#use strict;
no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="6.2";
my $PluginHooksFunctions="AddHTMLMenuLink AddHTMLGraph ShowInfoHost SectionInitHashArray SectionProcessIp SectionProcessHostname SectionReadHistory SectionWriteHistory";
my $PluginName="geoip_org_maxmind";
my $LoadedOverride=0;
my $OverrideFile="";
my %TmpDomainLookup; 
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$geoip_org_maxmind
%_org_p
%_org_h
%_org_k
%_org_l
$MAXNBOFSECTIONGIR
$MAXLENGTH
/;
# ----->


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_geoip_org_maxmind {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
    $MAXNBOFSECTIONGIR=10;
    $MAXLENGTH=50;
    
	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin $PluginName: InitParams=$InitParams",1);
    my ($mode,$tmpdatafile)=split(/\s+/,$InitParams,2);
    my ($datafile,$override)=split(/\+/,$tmpdatafile,2);
   	if (! $datafile) { $datafile="GeoIPOrg.dat"; }
   	else { $datafile =~ s/%20/ /g; }
	if ($type eq 'geoippureperl') {
		# With pureperl with always use GEOIP_STANDARD.
		# GEOIP_MEMORY_CACHE seems to fail with ActiveState
		if ($mode eq '' || $mode eq 'GEOIP_MEMORY_CACHE')  { $mode=Geo::IP::PurePerl::GEOIP_STANDARD(); }
		else { $mode=Geo::IP::PurePerl::GEOIP_STANDARD(); }
	} else {
		if ($mode eq '' || $mode eq 'GEOIP_MEMORY_CACHE')  { $mode=Geo::IP::GEOIP_MEMORY_CACHE(); }
		else { $mode=Geo::IP::GEOIP_STANDARD(); }
	}
	if ($override){ $override =~ s/%20/ /g; $OverrideFile=$override; }
	%TmpDomainLookup=();
	debug(" Plugin $PluginName: GeoIP initialized type=$type mode=$mode",1);
	if ($type eq 'geoippureperl') {
		$geoip_org_maxmind = Geo::IP::PurePerl->open($datafile, $mode);
	} else {
		$geoip_org_maxmind = Geo::IP->open($datafile, $mode);
	}
	$LoadedOverride=0;
	# Fails on some GeoIP version
	# debug(" Plugin $PluginName: GeoIP initialized database_info=".$geoip_org_maxmind->database_info());
	if ($geoip_org_maxmind) { debug(" Plugin $PluginName: GeoIP plugin and gi object initialized",1); }
	else { return "Error: Failed to create gi object for datafile=".$datafile; }
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLMenuLink_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLMenuLink_geoip_org_maxmind {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: AddHTMLMenuLink"); }
    if ($categ eq 'who') {
        $menu->{"plugin_$PluginName"}=0.5;               	# Pos
        $menulink->{"plugin_$PluginName"}=2;           		# Type of link
        $menutext->{"plugin_$PluginName"}="Organizations";   # Text
    }
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLGraph_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLGraph_geoip_org_maxmind {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
    my $ShowISP='H';
	$MinHit{'Org'}=1;
	my $total_p; my $total_h; my $total_k;
	my $rest_p; my $rest_h; my $rest_k;

	if ($Debug) { debug(" Plugin $PluginName: AddHTMLGraph $categ $menu $menulink $menutext"); }
	my $title='Organizations';
	&tab_head("$title",19,0,'org');
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>Organizations : ".((scalar keys %_org_h)-($_org_h{'unknown'}?1:0))."</th>";
	if ($ShowISP =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[56]</th>"; }
	if ($ShowISP =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[15]</th>"; }
	if ($ShowISP =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[57]</th>"; }
	if ($ShowISP =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[15]</th>"; }
	if ($ShowISP =~ /B/i) { print "<th bgcolor=\"#$color_k\" width=\"80\">$Message[75]</th>"; }
	if ($ShowISP =~ /L/i) { print "<th width=\"120\">$Message[9]</th>"; }
	print "</tr>\n";
	$total_p=$total_h=$total_k=0;
	my $count=0;
	&BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Org'},\%_org_h,\%_org_h);
    	foreach my $key (@keylist) {
            if ($key eq 'unknown') { next; }
   			my $p_p; my $p_h;
   			if ($TotalPages) { $p_p=int($_org_p{$key}/$TotalPages*1000)/10; }
   			if ($TotalHits)  { $p_h=int($_org_h{$key}/$TotalHits*1000)/10; }
   		    print "<tr>";
   		    my $org=$key; $org =~ s/_/ /g;
   		    print "<td class=\"aws\">".ucfirst($org)."</td>";
    		if ($ShowISP =~ /P/i) { print "<td>".($_org_p{$key}?Format_Number($_org_p{$key}):"&nbsp;")."</td>"; }
    		if ($ShowISP =~ /P/i) { print "<td>".($_org_p{$key}?"$p_p %":'&nbsp;')."</td>"; }
    		if ($ShowISP =~ /H/i) { print "<td>".($_org_h{$key}?Format_Number($_org_h{$key}):"&nbsp;")."</td>"; }
    		if ($ShowISP =~ /H/i) { print "<td>".($_org_h{$key}?"$p_h %":'&nbsp;')."</td>"; }
    		if ($ShowISP =~ /B/i) { print "<td>".Format_Bytes($_org_k{$key})."</td>"; }
    		if ($ShowISP =~ /L/i) { print "<td>".($_org_p{$key}?Format_Date($_org_l{$key},1):'-')."</td>"; }
    		print "</tr>\n";
    		$total_p += $_org_p{$key}||0;
    		$total_h += $_org_h{$key};
    		$total_k += $_org_k{$key}||0;
    		$count++;
    	}
	if ($Debug) { debug("Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h",2); }
	$rest_p=0;
	$rest_h=$TotalHits-$total_h;
	$rest_k=0;
	if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other cities
#	    print "<tr>";
#	    print "<td class=\"aws\">&nbsp;</td>";
#   		if ($ShowISP =~ /P/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowISP =~ /P/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowISP =~ /H/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowISP =~ /H/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowISP =~ /B/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowISP =~ /L/i) { print "<td>&nbsp;</td>"; }
#        print "</tr>\n";

		my $p_p; my $p_h;
		if ($TotalPages) { $p_p=int($rest_p/$TotalPages*1000)/10; }
		if ($TotalHits)  { $p_h=int($rest_h/$TotalHits*1000)/10; }
		print "<tr>";
		print "<td class=\"aws\"><span style=\"color: #$color_other\">$Message[2]/$Message[0]</span></td>";
		if ($ShowISP =~ /P/i) { print "<td>".($rest_p?Format_Number($rest_p):"&nbsp;")."</td>"; }
   		if ($ShowISP =~ /P/i) { print "<td>".($rest_p?"$p_p %":'&nbsp;')."</td>"; }
		if ($ShowISP =~ /H/i) { print "<td>".($rest_h?Format_Number($rest_h):"&nbsp;")."</td>"; }
   		if ($ShowISP =~ /H/i) { print "<td>".($rest_h?"$p_h %":'&nbsp;')."</td>"; }
		if ($ShowISP =~ /B/i) { print "<td>".Format_Bytes($rest_k)."</td>"; }
		if ($ShowISP =~ /L/i) { print "<td>&nbsp;</td>"; }
		print "</tr>\n";
	}
	&tab_end();

	# ----->
	return 0;
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
sub ShowInfoHost_geoip_org_maxmind {
    my $param="$_[0]";
	# <-----
	if ($param eq '__title__') {
    	my $NewLinkParams=${QueryString};
    	$NewLinkParams =~ s/(^|&|&amp;)update(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&|&amp;)output(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&|&amp;)staticlinks(=\w*|$)//i;
    	$NewLinkParams =~ s/(^|&|&amp;)framename=[^&]*//i;
    	my $NewLinkTarget='';
    	if ($DetailedReportsOnNewWindows) { $NewLinkTarget=" target=\"awstatsbis\""; }
    	if (($FrameName eq 'mainleft' || $FrameName eq 'mainright') && $DetailedReportsOnNewWindows < 2) {
    		$NewLinkParams.="&framename=mainright";
    		$NewLinkTarget=" target=\"mainright\"";
    	}
    	$NewLinkParams =~ s/(&amp;|&)+/&amp;/i;
    	$NewLinkParams =~ s/^&amp;//; $NewLinkParams =~ s/&amp;$//;
    	if ($NewLinkParams) { $NewLinkParams="${NewLinkParams}&"; }

		print "<th width=\"80\">";
        print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?XMLEncode("$AWScript?${NewLinkParams}output=plugin_$PluginName"):"$StaticLinks.plugin_$PluginName.$StaticExt")."\"$NewLinkTarget>GeoIP<br />Org</a>";
        print "</th>";
	}
	elsif ($param) {
        my $ip=0;
		my $key;
		if ($param =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {	# IPv4 address
		    $ip=4;
			$key=$param;
		}
		elsif ($param =~ /^[0-9A-F]*:/i) {						# IPv6 address
		    $ip=6;
			$key=$param;
		}
		print "<td>";
		if ($key && $ip==4) {
			my $org = TmpLookup_geoip_org_maxmind($param);
        	if (!$org && $type eq 'geoippureperl')
			{
        		# Function org_by_addr does not exists in PurePerl but org_by_name do same
        		$org=$geoip_org_maxmind->org_by_name($param) if $geoip_org_maxmind;
        	}
        	elsif(!$org)
        	{
        		$org=$geoip_org_maxmind->org_by_addr($param) if $geoip_org_maxmind;
        	}
        	if ($Debug) { debug("  Plugin $PluginName: GetOrgByIp for $param: [$org]",5); }
		    if ($org) {
		        if (length($org) <= $MAXLENGTH) {
		            print "$org";
		        }
		        else {
		            print substr($org,0,$MAXLENGTH).'...';
		        }
		    }
		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
		}
		if ($key && $ip==6) {
		    print "<span style=\"color: #$color_other\">$Message[0]</span>";
		}
		if (! $key) {
        	my $org = TmpLookup_geoip_org_maxmind($param);
        	if (!$org && $type eq 'geoippureperl')
			{
        		$org=$geoip_org_maxmind->org_by_name($param) if $geoip_org_maxmind;
        	}
        	elsif(!$org)
        	{
        		$org=$geoip_org_maxmind->org_by_name($param) if $geoip_org_maxmind;
        	}
        	if ($Debug) { debug("  Plugin $PluginName: GetOrgByHostname for $param: [$org]",5); }
		    if ($org) {
		        if (length($org) <= $MAXLENGTH) {
		            print "$org";
		        }
		        else {
		            print substr($org,0,$MAXLENGTH).'...';
		        }
		    }
		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
		}
		print "</td>";
	}
	else {
		print "<td>&nbsp;</td>";
	}
	return 1;
	# ----->
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionInitHashArray_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionInitHashArray_geoip_org_maxmind {
#    my $param="$_[0]";
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: Init_HashArray"); }
	%_org_p = %_org_h = %_org_k = %_org_l =();
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessIP_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessIp_geoip_org_maxmind {
    my $param="$_[0]";      # Param must be an IP
	# <-----
	my $org = TmpLookup_geoip_org_maxmind($param);
	if (!$org && $type eq 'geoippureperl')
	{
		# Function org_by_addr does not exists in PurePerl but org_by_name do same
		$org=$geoip_org_maxmind->org_by_name($param) if $geoip_org_maxmind;
	}
	elsif(!$org)
	{
		$org=$geoip_org_maxmind->org_by_addr($param) if $geoip_org_maxmind;
	}
	if ($Debug) { debug("  Plugin $PluginName: GetOrgByIp for $param: [$org]",5); }
    if ($org) {
        $org =~ s/\s/_/g;
        $_org_h{$org}++;
    } else {
        $_org_h{'unknown'}++;
    }
#	if ($timerecord > $_org_l{$city}) { $_org_l{$city}=$timerecord; }
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessHostname_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessHostname_geoip_org_maxmind {
    my $param="$_[0]";      # Param must be an IP
	# <-----
	my $org = TmpLookup_geoip_org_maxmind($param);
	if (!$org && $type eq 'geoippureperl')
	{
		$org=$geoip_org_maxmind->org_by_name($param) if $geoip_org_maxmind;
	}
	elsif(!$org)
	{
		$org=$geoip_org_maxmind->org_by_name($param) if $geoip_org_maxmind;
	}
	if ($Debug) { debug("  Plugin $PluginName: GetOrgByHostname for $param: [$org]",5); }
    if ($org) {
        $org =~ s/\s/_/g;
        $_org_h{$org}++;
    } else {
        $_org_h{'unknown'}++;
    }
#	if ($timerecord > $_org_l{$city}) { $_org_l{$city}=$timerecord; }
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionReadHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionReadHistory_geoip_org_maxmind {
    my $issectiontoload=shift;
    my $xmlold=shift;
    my $xmleb=shift;
	my $countlines=shift;
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: Begin of PLUGIN_$PluginName section"); }
	my @field=();
	my $count=0;my $countloaded=0;
	do {
		if ($field[0]) {
			$count++;
			if ($issectiontoload) {
				$countloaded++;
				if ($field[2]) { $_org_h{$field[0]}+=$field[2]; }
			}
		}
		$_=<HISTORY>;
		chomp $_; s/\r//;
		@field=split(/\s+/,($xmlold?XMLDecodeFromHisto($_):$_));
		$countlines++;
	}
	until ($field[0] eq "END_PLUGIN_$PluginName" || $field[0] eq "${xmleb}END_PLUGIN_$PluginName" || ! $_);
	if ($field[0] ne "END_PLUGIN_$PluginName" && $field[0] ne "${xmleb}END_PLUGIN_$PluginName") { error("History file is corrupted (End of section PLUGIN not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).","","",1); }
	if ($Debug) { debug(" Plugin $PluginName: End of PLUGIN_$PluginName section ($count entries, $countloaded loaded)"); }
	# ----->
	return 0;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionWriteHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionWriteHistory_geoip_org_maxmind {
    my ($xml,$xmlbb,$xmlbs,$xmlbe,$xmlrb,$xmlrs,$xmlre,$xmleb,$xmlee)=(shift,shift,shift,shift,shift,shift,shift,shift,shift);
    if ($Debug) { debug(" Plugin $PluginName: SectionWriteHistory_$PluginName start - ".(scalar keys %_org_h)); }
	# <-----
	print HISTORYTMP "\n";
	if ($xml) { print HISTORYTMP "<section id='plugin_$PluginName'><sortfor>$MAXNBOFSECTIONGIR</sortfor><comment>\n"; }
	print HISTORYTMP "# Plugin key - Pages - Hits - Bandwidth - Last access\n";
	#print HISTORYTMP "# The $MaxNbOfExtra[$extranum] first number of hits are first\n";
	$ValueInFile{'plugin_geoip_org_maxmind'}=tell HISTORYTMP;
	print HISTORYTMP "${xmlbb}BEGIN_PLUGIN_$PluginName${xmlbs}".(scalar keys %_org_h)."${xmlbe}\n";
	&BuildKeyList($MAXNBOFSECTIONGIR,1,\%_org_h,\%_org_h);
	my %keysinkeylist=();
	foreach (@keylist) {
		$keysinkeylist{$_}=1;
		#my $page=$_org_p{$_}||0;
		#my $bytes=$_org_k{$_}||0;
		#my $lastaccess=$_org_l{$_}||'';
		print HISTORYTMP "${xmlrb}$_${xmlrs}0${xmlrs}", $_org_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	foreach (keys %_org_h) {
		if ($keysinkeylist{$_}) { next; }
		#my $page=$_org_p{$_}||0;
		#my $bytes=$_org_k{$_}||0;
		#my $lastaccess=$_org_l{$_}||'';
		print HISTORYTMP "${xmlrb}$_${xmlrs}0${xmlrs}", $_org_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	print HISTORYTMP "${xmleb}END_PLUGIN_$PluginName${xmlee}\n";
	# ----->
	return 0;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: LoadOverrideFile
# Attempts to load a comma delimited file that will override the GeoIP database
# Useful for Intranet records
# CSV format: IP,"organization"
#-----------------------------------------------------------------------------
sub LoadOverrideFile_geoip_org_maxmind{
	my $filetoload="";
	if ($OverrideFile){
		if (!open(GEOIPFILE, $OverrideFile)){
			debug("Plugin $PluginName: Unable to open override file: $OverrideFile");
			$LoadedOverride = 1;
			return;
		}
	}else{
		my $conf = (exists(&Get_Config_Name) ? Get_Config_Name() : $SiteConfig);
		if ($conf && open(GEOIPFILE,"$DirData/$PluginName.$conf.txt"))	{ $filetoload="$DirData/$PluginName.$conf.txt"; }
		elsif (open(GEOIPFILE,"$DirData/$PluginName.txt"))	{ $filetoload="$DirData/$PluginName.txt"; }
		else { debug("No override file \"$DirData/$PluginName.txt\": $!"); }
	}
	if ($filetoload)
	{
		# This is the fastest way to load with regexp that I know
		while (<GEOIPFILE>){
			chomp $_;
			s/\r//;
			my @record = split(",", $_);
			# replace quotes if they were used in the file
			foreach (@record){ $_ =~ s/"//g; }
			# store in hash
			$TmpDomainLookup{$record[0]} = $record[1];
		}
		close GEOIPFILE;
        debug(" Plugin $PluginName: Overload file loaded: ".(scalar keys %TmpDomainLookup)." entries found.");
	}
	$LoadedOverride = 1;
	return;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: TmpLookup
# Searches the temporary hash for the parameter value and returns the corresponding
# GEOIP entry
#-----------------------------------------------------------------------------
sub TmpLookup_geoip_org_maxmind(){
	$param = shift;
	if (!$LoadedOverride){&LoadOverrideFile_geoip_org_maxmind();}
	#my $val;
	#if ($geoip_org_maxmind && 
	#(($type eq 'geoip' && $geoip_org_maxmind->VERSION >= 1.30) || 
	#  $type eq 'geoippureperl' && $geoip_org_maxmind->VERSION >= 1.17)){
	#	$val = $TmpDomainLookup{$geoip_org_maxmind->get_ip_address($param)};
	#}
    #else {$val = $TmpDomainLookup{$param};}
    #return $val || '';
    return $TmpDomainLookup{$param}||'';
}

1;	# Do not remove this line

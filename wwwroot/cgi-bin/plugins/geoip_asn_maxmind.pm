#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GeoIp_ASN_Maxmind AWStats plugin
# This plugin allow you to add ASN information to a report
# Requires the free ASN database from MaxMind
#-----------------------------------------------------------------------------
# Perl Required Modules: Geo::IP or Geo::IP::PurePerl
#-----------------------------------------------------------------------------


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
use vars qw/ $type /;
$type='GeoIPASNum';
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
my $PluginHooksFunctions="AddHTMLMenuLink AddHTMLGraph ShowInfoHost 
						  SectionInitHashArray SectionProcessIp SectionProcessHostname 
						  SectionReadHistory SectionWriteHistory";
my $PluginName="geoip_asn_maxmind";
my $LoadedOverride=0;
my %TmpLookup;
my $LookupLink="";
my $OverrideFile="";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$geoip_asn_maxmind
%_asn_p
%_asn_h
%_asn_k
%_asn_l
$MAXNBOFSECTIONGIR
$MAXLENGTH
/;
# ----->


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
# Parameters: $mode - Whether to load into memory or search file for lookups 
#					  Values: GEOIPSTANDARD () or GEOIP_MEMORY_CACHE
#			  $datafile - Path to the GEOIP Data file. Defaults to local directory
#			  $override - Path to an override file
#			  $link - ASN lookup link to a page with more information. Appends 
#				      the AS number at the end. For example:
#					  $link=http://www.lookup.net/lookup.php?asn={ASNUMBER}
#-----------------------------------------------------------------------------
sub Init_geoip_asn_maxmind {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
    $MAXNBOFSECTIONGIR=10;
    $MAXLENGTH=20;
    
	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin $PluginName: InitParams=$InitParams",1);
    my ($mode,$tmpdatafile)=split(/\s+/,$InitParams,2);
    my ($datafile,$override,$link)=split(/\+/,$tmpdatafile,3);
   	if (! $datafile) { $datafile="GeoIPASNum.dat"; }
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
	# if there is a url in the override field, move it to link
	if (lc($override) =~ m/^http/) { $link = $override; $override = ''; }
	elsif ($override) { $override =~ s/%20/ /g; $OverrideFile=$override; }
	if ($link){$LookupLink=$link;}
	debug(" Plugin $PluginName: GeoIP initialized type=$type mode=$mode, override=$override, link=$link",1);
	if ($type eq 'geoippureperl') {
		$geoip_asn_maxmind = Geo::IP::PurePerl->open($datafile, $mode);
	} else {
		$geoip_asn_maxmind = Geo::IP->open($datafile, $mode);
	}
	# Fails on some GeoIP version
	# debug(" Plugin geoip_org_maxmind: GeoIP initialized database_info=".$geoip_asn_maxmind->database_info());
	if ($geoip_asn_maxmind) { debug(" Plugin $PluginName: GeoIP plugin and gi object initialized",1); }
	else { return "Error: Failed to create gi object for datafile=".$datafile; }
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLMenuLink_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLMenuLink_geoip_asn_maxmind {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: AddHTMLMenuLink"); }
    if ($categ eq 'who') {
        $menu->{"plugin_$PluginName"}=0.7;               # Pos
        $menulink->{"plugin_$PluginName"}=2;           # Type of link
        $menutext->{"plugin_$PluginName"}="ASNs";    # Text
    }
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLGraph_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLGraph_geoip_asn_maxmind {
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
	my $title='AS Numbers';
	&tab_head("$title",19,0,'org');
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>AS Numbers: ".((scalar keys %_asn_h)-($_asn_h{'unknown'}?1:0))."</th>";
	print "<th>ISP</th>\n";
	if ($ShowISP =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[56]</th>"; }
	if ($ShowISP =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[15]</th>"; }
	if ($ShowISP =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[57]</th>"; }
	if ($ShowISP =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[15]</th>"; }
	if ($ShowISP =~ /B/i) { print "<th bgcolor=\"#$color_k\" width=\"80\">$Message[75]</th>"; }
	if ($ShowISP =~ /L/i) { print "<th width=\"120\">$Message[9]</th>"; }
	print "</tr>\n";
	$total_p=$total_h=$total_k=0;
	my $count=0;
	&BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Org'},\%_asn_h,\%_asn_h);
    	foreach my $key (@keylist) {
            if ($key eq 'unknown') { next; }
   			my $p_p; my $p_h;
   			if ($TotalPages) { $p_p=int($_asn_p{$key}/$TotalPages*1000)/10; }
   			if ($TotalHits)  { $p_h=int($_asn_h{$key}/$TotalHits*1000)/10; }
   		    print "<tr>";
   		    my $asn=$key; $asn =~ s/_/ /g;
   		    my $idx = index($asn, ' ');
   		    # get lookup link
   		    my $link = '';
   		    if ($LookupLink){
	   		    if ($idx < 0 && $asn =~ m/^A/){ $link .= $LookupLink.$asn; }
	   		    elsif (substr($asn, 0, $idx) =~ m/^A/){$link .= $LookupLink.substr($asn, 0, $idx); }
	   		    if ($link){ $link = "<a target=\"_blank\" href=\"".$link."\">";}
   		    }
   		    print "<td class=\"aws\">".$link.ucfirst(($idx > -1 ? substr($asn, 0, $idx) : $asn));
   		    print ($link ? "</a>" : "")."</td>";
   		    print "<td class=\"aws\">".($idx > -1 ? substr($asn, $idx+1) : "&nbsp;")."</td>\n";
    		if ($ShowISP =~ /P/i) { print "<td>".($_asn_p{$key}?Format_Number($_asn_p{$key}):"&nbsp;")."</td>"; }
    		if ($ShowISP =~ /P/i) { print "<td>".($_asn_p{$key}?"$p_p %":'&nbsp;')."</td>"; }
    		if ($ShowISP =~ /H/i) { print "<td>".($_asn_h{$key}?Format_Number($_asn_h{$key}):"&nbsp;")."</td>"; }
    		if ($ShowISP =~ /H/i) { print "<td>".($_asn_h{$key}?"$p_h %":'&nbsp;')."</td>"; }
    		if ($ShowISP =~ /B/i) { print "<td>".Format_Bytes($_asn_k{$key})."</td>"; }
    		if ($ShowISP =~ /L/i) { print "<td>".($_asn_p{$key}?Format_Date($_asn_l{$key},1):'-')."</td>"; }
    		print "</tr>\n";
    		$total_p += $_asn_p{$key}||0;
    		$total_h += $_asn_h{$key};
    		$total_k += $_asn_k{$key}||0;
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
		print "<td class=\"aws\">&nbsp;</td>\n";
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
sub ShowInfoHost_geoip_asn_maxmind {
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
        print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?XMLEncode("$AWScript?${NewLinkParams}output=plugin_$PluginName"):"$StaticLinks.plugin_$PluginName.$StaticExt")."\"$NewLinkTarget>GeoIP<br />ASN</a>";
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
		my $asn = 0;
		if ($key && $ip==4) {
        	$asn = TmpLookup_geoip_asn_maxmind($param);
        	if (!$asn && $type eq 'geoippureperl')
			{
        		# Function org_by_addr does not exists in PurePerl but org_by_name do same
        		$asn=$geoip_asn_maxmind->org_by_name($param) if $geoip_asn_maxmind;
        	}
        	elsif (!$asn)
        	{
        		$asn=$geoip_asn_maxmind->org_by_addr($param) if $geoip_asn_maxmind;
        	}
        	if ($Debug) { debug("  Plugin $PluginName: GetASNByIp for $param: [$asn]",5); }
		}
		if ($key && $ip==6) {
		    debug("  Plugin $PluginName: IPv6 not supported by MaxMind Free DBs: $key",3);
		}
		if (! $key) {
        	$asn = TmpLookup_geoip_asn_maxmind($param);
        	if (!$asn && $type eq 'geoippureperl')
			{
        		$asn=$geoip_asn_maxmind->org_by_name($param) if $geoip_asn_maxmind;
        	}
        	elsif (!$asn)
        	{
        		$asn=$geoip_asn_maxmind->org_by_name($param) if $geoip_asn_maxmind;
        	}
        	if ($Debug) { debug("  Plugin $PluginName: GetOrgByHostname for $param: [$asn]",5); }
		}
		if (length($asn)>0) {
	    	my $link = '';
	    	my $idx = index(trim($asn), ' ');
	    	if ($LookupLink){
	   		    if ($idx < 0 && $asn =~ m/^A/){ $link .= $LookupLink.$asn; }
	   		    elsif (substr($asn, 0, $idx) =~ m/^A/){$link .= $LookupLink.substr($asn, 0, $idx); }
	    	}
   		    if ($link){ $link = "<a target=\"_blank\" href=\"".$link."\">";}
	    	if ($idx > -1 ) {$asn = substr(trim($asn), $idx+1);}	    
	        if (length($asn) <= $MAXLENGTH) {
	            print "$link$asn".($link ? "</a>" : "");
	        }
	        else {
	            print $link.substr($asn,0,$MAXLENGTH).'...'.($link ? "</a>" : "");
	        }
	    }
	    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
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
sub SectionInitHashArray_geoip_asn_maxmind {
#    my $param="$_[0]";
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: Init_HashArray"); }
	%_asn_p = %_asn_h = %_asn_k = %_asn_l =();
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessIP_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessIp_geoip_asn_maxmind {
    my $param="$_[0]";      # Param must be an IP
	# <-----
	my $asn = TmpLookup_geoip_asn_maxmind($param);
	if (!$asn && $type eq 'geoippureperl')
	{
		# Function org_by_addr does not exists in PurePerl but org_by_name do same
		$asn=$geoip_asn_maxmind->org_by_name($param) if $geoip_asn_maxmind;
	}
	elsif (!$asn)
	{
		$asn=$geoip_asn_maxmind->org_by_addr($param) if $geoip_asn_maxmind;
	}
	if ($Debug) { debug("  Plugin $PluginName: GetASNByIp for $param: [$asn]",5); }
    if ($asn) {
        $asn =~ s/\s/_/g;
        $_asn_h{$asn}++;
    } else {
        $_asn_h{'unknown'}++;
    }
#	if ($timerecord > $_asn_l{$city}) { $_asn_l{$city}=$timerecord; }
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessHostname_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessHostname_geoip_asn_maxmind {
    my $param="$_[0]";      # Param must be an IP
	# <-----
	my $asn = TmpLookup_geoip_asn_maxmind($param);
	if (!$asn && $type eq 'geoippureperl')
	{
		$asn=$geoip_asn_maxmind->org_by_name($param) if $geoip_asn_maxmind;
	}
	elsif (!$asn)
	{
		$asn=$geoip_asn_maxmind->org_by_name($param) if $geoip_asn_maxmind;
	}
	if ($Debug) { debug("  Plugin $PluginName: GetOrgByHostname for $param: [$asn]",5); }
    if ($asn) {
        $asn =~ s/\s/_/g;
        $_asn_h{$asn}++;
    } else {
        $_asn_h{'unknown'}++;
    }
#	if ($timerecord > $_asn_l{$city}) { $_asn_l{$city}=$timerecord; }
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionReadHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionReadHistory_geoip_asn_maxmind {
    my $issectiontoload=shift;
    my $xmlold=shift;
    my $xmleb=shift;
	my $countlines=shift;
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: Begin of PLUGIN_geoip_org_maxmind section"); }
	my @field=();
	my $count=0;my $countloaded=0;
	do {
		if ($field[0]) {
			$count++;
			if ($issectiontoload) {
				$countloaded++;
				if ($field[2]) { $_asn_h{$field[0]}+=$field[2]; }
			}
		}
		$_=<HISTORY>;
		chomp $_; s/\r//;
		@field=split(/\s+/,($xmlold?XMLDecodeFromHisto($_):$_));
		$countlines++;
	}
	until ($field[0] eq "END_PLUGIN_$PluginName" || $field[0] eq "${xmleb}END_PLUGIN_$PluginName" || ! $_);
	if ($field[0] ne "END_PLUGIN_$PluginName" && $field[0] ne "${xmleb}END_PLUGIN_$PluginName") { error("History file is corrupted (End of section PLUGIN not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).","","",1); }
	if ($Debug) { debug(" Plugin $PluginName: End of PLUGIN_geoip_org_maxmind section ($count entries, $countloaded loaded)"); }
	# ----->
	return 0;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionWriteHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionWriteHistory_geoip_asn_maxmind {
    my ($xml,$xmlbb,$xmlbs,$xmlbe,$xmlrb,$xmlrs,$xmlre,$xmleb,$xmlee)=(shift,shift,shift,shift,shift,shift,shift,shift,shift);
    if ($Debug) { debug(" Plugin $PluginName: SectionWriteHistory_$PluginName start - ".(scalar keys %_asn_h)); }
	# <-----
	print HISTORYTMP "\n";
	if ($xml) { print HISTORYTMP "<section id='plugin_$PluginName'><sortfor>$MAXNBOFSECTIONGIR</sortfor><comment>\n"; }
	print HISTORYTMP "# Plugin key - Pages - Hits - Bandwidth - Last access\n";
	#print HISTORYTMP "# The $MaxNbOfExtra[$extranum] first number of hits are first\n";
	$ValueInFile{'plugin_$PluginName'}=tell HISTORYTMP;
	print HISTORYTMP "${xmlbb}BEGIN_PLUGIN_$PluginName${xmlbs}".(scalar keys %_asn_h)."${xmlbe}\n";
	&BuildKeyList($MAXNBOFSECTIONGIR,1,\%_asn_h,\%_asn_h);
	my %keysinkeylist=();
	foreach (@keylist) {
		$keysinkeylist{$_}=1;
		#my $page=$_asn_p{$_}||0;
		#my $bytes=$_asn_k{$_}||0;
		#my $lastaccess=$_asn_l{$_}||'';
		print HISTORYTMP "${xmlrb}$_${xmlrs}0${xmlrs}", $_asn_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	foreach (keys %_asn_h) {
		if ($keysinkeylist{$_}) { next; }
		#my $page=$_asn_p{$_}||0;
		#my $bytes=$_asn_k{$_}||0;
		#my $lastaccess=$_asn_l{$_}||'';
		print HISTORYTMP "${xmlrb}$_${xmlrs}0${xmlrs}", $_asn_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	print HISTORYTMP "${xmleb}END_PLUGIN_$PluginName${xmlee}\n";
	# ----->
	return 0;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: LoadOverrideFile
# Attempts to load a comma delimited file that will override the GeoIP database
# Useful for Intranet records
# CSV format: IP,2-char Country code
#-----------------------------------------------------------------------------
sub LoadOverrideFile_geoip_asn_maxmind{
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
			$TmpLookup{$record[0]} = $record[1];
		}
		close GEOIPFILE;
        debug(" Plugin $PluginName: Overload file loaded: ".(scalar keys %TmpLookup)." entries found.");
	}
	$LoadedOverride = 1;
	return;
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: TmpLookup
# Searches the temporary hash for the parameter value and returns the corresponding
# GEOIP entry
#-----------------------------------------------------------------------------
sub TmpLookup_geoip_asn_maxmind(){
	$param = shift;
	if (!$LoadedOverride){&LoadOverrideFile_geoip_asn_maxmind();}
#	my $val;
#	if ($geoip_asn_maxmind && 
#	(($type eq 'geoip' && $geoip_asn_maxmind->VERSION >= 1.30) || 
#	  $type eq 'geoippureperl' && $geoip_asn_maxmind->VERSION >= 1.17)){
#		$val = $TmpLookup{$geoip_asn_maxmind->get_ip_address($param)};
#	}
#    else {$val = $TmpLookup{$param};}
#    return $val || '';
    return $TmpLookup{$param}||'';
    
}


1;	# Do not remove this line

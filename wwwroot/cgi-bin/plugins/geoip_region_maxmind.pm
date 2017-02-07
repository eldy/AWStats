#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GeoIp_Region_Maxmind AWStats plugin
# This plugin allow you to add a region report with regions detected
# from a Geographical database (US and Canada).
# Need the licensed region database from Maxmind.
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
my $PluginNeedAWStatsVersion="6.5";
my $PluginHooksFunctions="AddHTMLMenuLink AddHTMLGraph ShowInfoHost SectionInitHashArray SectionProcessIp SectionProcessHostname SectionReadHistory SectionWriteHistory";
my $PluginName="geoip_region_maxmind";
my $LoadedOverride=0;
my $OverrideFile=""; 
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
%TmpDomainLookup
$geoip_region_maxmind
%_region_p
%_region_h
%_region_k
%_region_l
$MAXNBOFSECTIONGIR
%region
/;
my %countrylib=('ca'=>'Canada','us'=>'USA');
my %countryregionlib=('ca'=>'Canadian Regions','us'=>'US regions');
my %regca=(
'AB',"Alberta",
'BC',"British Columbia",
'MB',"Manitoba",
'NB',"New Brunswick",
'NF',"Newfoundland",
'NS',"Nova Scotia",
'NU',"Nunavut",
'ON',"Ontario",
'PE',"Prince Edward Island",
'QC',"Quebec",
'SK',"Saskatchewan",
'NT',"Northwest Territories",
'YT',"Yukon Territory"
);
my %regus=(
'AA',"Armed Forces Americas",
'AE',"Armed Forces Europe, Middle East, & Canada",
'AK',"Alaska",
'AL',"Alabama",
'AP',"Armed Forces Pacific",
'AR',"Arkansas",
'AS',"American Samoa",
'AZ',"Arizona",
'CA',"California",
'CO',"Colorado",
'CT',"Connecticut",
'DC',"District of Columbia",
'DE',"Delaware",
'FL',"Florida",
'FM',"Federated States of Micronesia",
'GA',"Georgia",
'GU',"Guam",
'HI',"Hawaii",
'IA',"Iowa",
'ID',"Idaho",
'IL',"Illinois",
'IN',"Indiana",
'KS',"Kansas",
'KY',"Kentucky",
'LA',"Louisiana",
'MA',"Massachusetts",
'MD',"Maryland",
'ME',"Maine",
'MH',"Marshall Islands",
'MI',"Michigan",
'MN',"Minnesota",
'MO',"Missouri",
'MP',"Northern Mariana Islands",
'MS',"Mississippi",
'MT',"Montana",
'NC',"North Carolina",
'ND',"North Dakota",
'NE',"Nebraska",
'NH',"New Hampshire",
'NJ',"New Jersey",
'NM',"New Mexico",
'NV',"Nevada",
'NY',"New York",
'OH',"Ohio",
'OK',"Oklahoma",
'OR',"Oregon",
'PA',"Pennsylvania",
'PR',"Puerto Rico",
'PW',"Palau",
'RI',"Rhode Island",
'SC',"South Carolina",
'SD',"South Dakota",
'TN',"Tennessee",
'TX',"Texas",
'UT',"Utah",
'VA',"Virginia",
'VI',"Virgin Islands",
'VT',"Vermont",
'WA',"Washington",
'WV',"West Virginia",
'WI',"Wisconsin",
'WY',"Wyoming"
);
my %region=(
'ca'=>\%regca,
'us'=>\%regus
);
# ----->


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_geoip_region_maxmind {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
    $MAXNBOFSECTIONGIR=10;
    
	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin $PluginName: InitParams=$InitParams",1);
    my ($mode,$tmpdatafile)=split(/\s+/,$InitParams,2);
    my ($datafile,$override)=split(/\+/,$tmpdatafile,2);
   	if (! $datafile) { $datafile="GeoIPRegion.dat"; }
   	else { $datafile =~ s/%20/ /g; }
	if ($type eq 'geoippureperl') {
		# With pureperl we always use GEOIP_STANDARD.
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
		$geoip_region_maxmind = Geo::IP::PurePerl->open($datafile, $mode);
	} else {
		$geoip_region_maxmind = Geo::IP->open($datafile, $mode);
	}
	$LoadedOverride=0;
	# Fails with some geoip versions
	# debug(" Plugin geoip_region_maxmind: GeoIP initialized database_info=".$geoip_region_maxmind->database_info());
	if ($geoip_region_maxmind) { debug(" Plugin $PluginName: GeoIP plugin and gi object initialized",1); }
	else { return "Error: Failed to create gi object for datafile=".$datafile; }
 	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLMenuLink_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLMenuLink_geoip_region_maxmind {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: AddHTMLMenuLink"); }
    if ($categ eq 'who') {
        $menu->{"plugin_$PluginName"}=2.1;             # Pos
        $menulink->{"plugin_$PluginName"}=2;           # Type of link
        $menutext->{"plugin_$PluginName"}="Regions";   # Text
    }
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLGraph_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLGraph_geoip_region_maxmind {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
    my $ShowRegions='H';
	$MinHit{'Regions'}=1;
	my $total_p; my $total_h; my $total_k;
	my $rest_p; my $rest_h; my $rest_k;

	if ($Debug) { debug(" Plugin $PluginName: AddHTMLGraph"); }
	my $title='Regions';
	&tab_head("$title",19,0,'regions');
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th>US and CA Regions : ".((scalar keys %_region_h)-($_region_h{'unknown'}?1:0))."</th>";
	if ($ShowRegions =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[56]</th>"; }
	if ($ShowRegions =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[15]</th>"; }
	if ($ShowRegions =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[57]</th>"; }
	if ($ShowRegions =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[15]</th>"; }
	if ($ShowRegions =~ /B/i) { print "<th bgcolor=\"#$color_k\" width=\"80\">$Message[75]</th>"; }
	if ($ShowRegions =~ /L/i) { print "<th width=\"120\">$Message[9]</th>"; }
	print "</tr>\n";
	$total_p=$total_h=$total_k=0;
	my $count=0;
	&BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Regions'},\%_region_h,\%_region_h);
    # Group by country
    my @countrylist=('ca','us');
    foreach my $country (@countrylist) {
	    print "<tr><td class=\"aws\"><b>".$countryregionlib{$country}."</b></td>";
   		if ($ShowRegions =~ /P/i) { print "<td>&nbsp;</td>"; }
   		if ($ShowRegions =~ /P/i) { print "<td>&nbsp;</td>"; }
   		if ($ShowRegions =~ /H/i) { print "<td>&nbsp;</td>"; }
   		if ($ShowRegions =~ /H/i) { print "<td>&nbsp;</td>"; }
   		if ($ShowRegions =~ /B/i) { print "<td>&nbsp;</td>"; }
   		if ($ShowRegions =~ /L/i) { print "<td>&nbsp;</td>"; }
        print "</tr>\n";
    	foreach my $key (@keylist) {
            if ($key eq 'unknown') { next; }
   		    my ($countrycode,$regioncode)=split('_',$key);
            if ($countrycode ne $country) { next; }
   			my $p_p; my $p_h;
   			if ($TotalPages) { $p_p=int($_region_p{$key}/$TotalPages*1000)/10; }
   			if ($TotalHits)  { $p_h=int($_region_h{$key}/$TotalHits*1000)/10; }
   		    print "<tr><td class=\"aws\">".$region{$countrycode}{uc($regioncode)}." ($regioncode)</td>";
    		if ($ShowRegions =~ /P/i) { print "<td>".($_region_p{$key}?Format_Number($_region_p{$key}):"&nbsp;")."</td>"; }
    		if ($ShowRegions =~ /P/i) { print "<td>".($_region_p{$key}?"$p_p %":'&nbsp;')."</td>"; }
    		if ($ShowRegions =~ /H/i) { print "<td>".($_region_h{$key}?Format_Number($_region_h{$key}):"&nbsp;")."</td>"; }
    		if ($ShowRegions =~ /H/i) { print "<td>".($_region_h{$key}?"$p_h %":'&nbsp;')."</td>"; }
    		if ($ShowRegions =~ /B/i) { print "<td>".Format_Bytes($_region_k{$key})."</td>"; }
    		if ($ShowRegions =~ /L/i) { print "<td>".($_region_p{$key}?Format_Date($_region_l{$key},1):'-')."</td>"; }
    		print "</tr>\n";
    		$total_p += $_region_p{$key}||0;
    		$total_h += $_region_h{$key};
    		$total_k += $_region_k{$key}||0;
    		$count++;
    	}
    }
	if ($Debug) { debug("Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h",2); }
	$rest_p=0;
	$rest_h=$TotalHits-$total_h;
	$rest_k=0;
	if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other regions
	    print "<tr><td class=\"aws\">&nbsp;</td>";
   		if ($ShowRegions =~ /P/i) { print "<td>&nbsp;</td>"; }
   		if ($ShowRegions =~ /P/i) { print "<td>&nbsp;</td>"; }
   		if ($ShowRegions =~ /H/i) { print "<td>&nbsp;</td>"; }
   		if ($ShowRegions =~ /H/i) { print "<td>&nbsp;</td>"; }
   		if ($ShowRegions =~ /B/i) { print "<td>&nbsp;</td>"; }
   		if ($ShowRegions =~ /L/i) { print "<td>&nbsp;</td>"; }
        print "</tr>\n";

		my $p_p; my $p_h;
		if ($TotalPages) { $p_p=int($rest_p/$TotalPages*1000)/10; }
		if ($TotalHits)  { $p_h=int($rest_h/$TotalHits*1000)/10; }
		print "<tr><td class=\"aws\"><span style=\"color: #$color_other\">$Message[2]/$Message[0]</span></td>";
		if ($ShowRegions =~ /P/i) { print "<td>".($rest_p?Format_Number($rest_p):"&nbsp;")."</td>"; }
   		if ($ShowRegions =~ /P/i) { print "<td>".($rest_p?"$p_p %":'&nbsp;')."</td>"; }
		if ($ShowRegions =~ /H/i) { print "<td>".($rest_h?Format_Number($rest_h):"&nbsp;")."</td>"; }
   		if ($ShowRegions =~ /H/i) { print "<td>".($rest_h?"$p_h %":'&nbsp;')."</td>"; }
		if ($ShowRegions =~ /B/i) { print "<td>".Format_Bytes($rest_k)."</td>"; }
		if ($ShowRegions =~ /L/i) { print "<td>&nbsp;</td>"; }
		print "</tr>\n";
	}
	&tab_end();

	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByAddr_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByAddr is called to translate an ip into a country code in lower case.
#-----------------------------------------------------------------------------
# Rem: Not used
sub GetCountryCodeByAddr_geoip_region_maxmind {
    my $param="$_[0]";
	# <-----
	if (!$LoadedOverride){&LoadOverrideFile_geoip_region_maxmind();}
	my $res=$TmpDomainLookup{$param}||'';
	if (! $res) {
    	my ($res1,$res2,$countryregion)=();
    	($res1,$res2)=$geoip_region_maxmind->region_by_name($param) if $geoip_region_maxmind;
    	$res=lc($res1) || 'unknown';
		$TmpDomainLookup{$param}=$res;
    	if ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByAddr for $param: [$res]",5); }
	}
	elsif ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByAddr for $param: Already resolved to [$res]",5); }
	# ----->
	return $res;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: GetCountryCodeByName_pluginname
# UNIQUE: YES (Only one plugin using this function can be loaded)
# GetCountryCodeByName is called to translate a host name into a country code in lower case.
#-----------------------------------------------------------------------------
# Rem: Not used
sub GetCountryCodeByName_geoip_region_maxmind {
    my $param="$_[0]";
	# <-----
	if (!$LoadedOverride){&LoadOverrideFile_geoip_region_maxmind();}
	my $res=$TmpDomainLookup{$param}||'';
	if (! $res) {
    	my ($res1,$res2,$countryregion)=();
    	($res1,$res2)=$geoip_region_maxmind->region_by_name($param) if $geoip_region_maxmind;
    	$res=lc($res1) || 'unknown';
		$TmpDomainLookup{$param}=$res;
    	if ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByName for $param: [$res]",5); }
	}
	elsif ($Debug) { debug("  Plugin $PluginName: GetCountryCodeByName for $param: Already resolved to [$res]",5); }
	# ----->
	return $res;
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
sub ShowInfoHost_geoip_region_maxmind {
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
        print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?XMLEncode("$AWScript?${NewLinkParams}output=plugin_$PluginName"):"$StaticLinks.plugin_$PluginName.$StaticExt")."\"$NewLinkTarget>GeoIP<br />Region</a>";
        print "</th>";
	}
	elsif ($param) {
		# try loading our override file if we haven't yet
		if (!$LoadedOverride){&LoadOverrideFile_geoip_region_maxmind();}
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
        	my ($res1,$res2,$countryregion)=();
        	my @res = TmpLookup_geoip_region_maxmind($param);
	        if (@res){
	        	$res1 = $res[0];
	        	$res2 = $res[1];
	        }else{
        		($res1,$res2)=$geoip_region_maxmind->region_by_name($param) if $geoip_region_maxmind;
	        }
        	if ($Debug) { debug("  Plugin $PluginName: GetRegionByIp for $param: [${res1}_${res2}]",5); }
            if (! $PluginsLoaded{'init'}{'geoip'}) {
                # Show country
                if ($res1 =~ /\w\w/) { print $DomainsHashIDLib{lc($res1)}||uc($res1); }
                else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
                # Show region
                if ($res1 =~ /\w\w/ && $res2 =~ /\w\w/) {
                    print "&nbsp;(";
                    print $region{lc($res1)}{uc($res2)};
                    print ")";
                }
            }
            else {
            	# Show region
                if ($res1 =~ /\w\w/ && $res2 =~ /\w\w/) {
                    print $region{lc($res1)}{uc($res2)};
                }
                else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
            }
		}
		if ($key && $ip==6) {
            print "<span style=\"color: #$color_other\">$Message[0]</span>";
        }
		if (! $key) {
        	my ($res1,$res2,$countryregion)=();
        	my @res = TmpLookup_geoip_region_maxmind($param);
	        if (@res){
	        	$res1 = $res[0];
	        	$res2 = $res[1];
	        }else{
        		($res1,$res2)=$geoip_region_maxmind->region_by_name($param) if $geoip_region_maxmind;
	        }
        	if ($Debug) { debug("  Plugin $PluginName: GetRegionByName for $param: [${res1}_${res2}]",5); }
            if (! $PluginsLoaded{'init'}{'geoip'}) {
                # Show country
                if ($res1 =~ /\w\w/) { print $DomainsHashIDLib{lc($res1)}||uc($res1); }
                else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
                # Show region
                if ($res1 =~ /\w\w/ && $res2 =~ /\w\w/) {
                    print "&nbsp;(";
                    print $region{lc($res1)}{uc($res2)};
                    print ")";
                }
            }
            else {
                # Show region
                if ($res1 =~ /\w\w/ && $res2 =~ /\w\w/) {
                    print $region{lc($res1)}{uc($res2)};
                }
                else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
            }
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
sub SectionInitHashArray_geoip_region_maxmind {
#    my $param="$_[0]";
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: Init_HashArray"); }
	%_region_p = %_region_h = %_region_k = %_region_l =();
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessHostname_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessIp_geoip_region_maxmind {
    my $param="$_[0]";      # Param must be an IP
	# <-----
	my ($res1,$res2,$countryregion)=();
	my @res = TmpLookup_geoip_region_maxmind($param);
    if (@res){
      	$res1 = $res[0];
       	$res2 = $res[1];
    }else{
		($res1,$res2)=$geoip_region_maxmind->region_by_name($param) if $geoip_region_maxmind;
    }
	if ($Debug) { debug("  Plugin $PluginName: GetRegionByIp for $param: [${res1}_${res2}]",5); }
    if ($res2 =~ /\w\w/) { $countryregion=lc("${res1}_${res2}"); }
    else { $countryregion='unknown'; }
#	if ($PageBool) { $_region_p{$countryregion}++; }
    $_region_h{$countryregion}++; 
#	if ($timerecord > $_region_l{$countryregion}) { $_region_l{$countryregion}=$timerecord; }
	# ----->
	return;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessHostname_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessHostname_geoip_region_maxmind {
    my $param="$_[0]";      # Param must be a hostname
	# <-----
	my ($res1,$res2,$countryregion)=();
	my @res = TmpLookup_geoip_region_maxmind($param);
    if (@res){
      	$res1 = $res[0];
       	$res2 = $res[1];
    }else{
		($res1,$res2)=$geoip_region_maxmind->region_by_name($param) if $geoip_region_maxmind;
    }
	if ($Debug) { debug("  Plugin $PluginName: GetRegionByName for $param: [${res1}_${res2}]",5); }
    if ($res2 =~ /\w\w/) { $countryregion=lc("${res1}_${res2}"); }
    else { $countryregion='unknown'; }
#	if ($PageBool) { $_region_p{$countryregion}++; }
    $_region_h{$countryregion}++; 
#	if ($timerecord > $_region_l{$countryregion}) { $_region_l{$countryregion}=$timerecord; }
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionReadHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionReadHistory_geoip_region_maxmind {
    my $issectiontoload=shift;
    my $xmlold=shift;
    my $xmleb=shift;
	my $countlines=shift;
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: Begin of PLUGIN_$PluginName"); }
	my @field=();
	my $count=0;my $countloaded=0;
	do {
		if ($field[0]) {
			$count++;
			if ($issectiontoload) {
				$countloaded++;
				if ($field[2]) { $_region_h{$field[0]}+=$field[2]; }
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
sub SectionWriteHistory_geoip_region_maxmind {
    my ($xml,$xmlbb,$xmlbs,$xmlbe,$xmlrb,$xmlrs,$xmlre,$xmleb,$xmlee)=(shift,shift,shift,shift,shift,shift,shift,shift,shift);
    if ($Debug) { debug(" Plugin $PluginName: SectionWriteHistory_$PluginName start - ".(scalar keys %_region_h)); }
	# <-----
	print HISTORYTMP "\n";
	if ($xml) { print HISTORYTMP "<section id='plugin_$PluginName'><sortfor>$MAXNBOFSECTIONGIR</sortfor><comment>\n"; }
	print HISTORYTMP "# Plugin key - Pages - Hits - Bandwidth - Last access\n";
	#print HISTORYTMP "# The $MaxNbOfExtra[$extranum] first number of hits are first\n";
	$ValueInFile{"plugin_$PluginName"}=tell HISTORYTMP;
	print HISTORYTMP "${xmlbb}BEGIN_PLUGIN_$PluginName${xmlbs}".(scalar keys %_region_h)."${xmlbe}\n";
	&BuildKeyList($MAXNBOFSECTIONGIR,1,\%_region_h,\%_region_h);
	my %keysinkeylist=();
	foreach (@keylist) {
		$keysinkeylist{$_}=1;
		#my $page=$_region_p{$_}||0;
		#my $bytes=$_region_k{$_}||0;
		#my $lastaccess=$_region_l{$_}||'';
		print HISTORYTMP "${xmlrb}$_${xmlrs}0${xmlrs}", $_region_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	foreach (keys %_region_h) {
		if ($keysinkeylist{$_}) { next; }
		#my $page=$_region_p{$_}||0;
		#my $bytes=$_region_k{$_}||0;
		#my $lastaccess=$_region_l{$_}||'';
		print HISTORYTMP "${xmlrb}$_${xmlrs}0${xmlrs}", $_region_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	print HISTORYTMP "${xmleb}END_PLUGIN_$PluginName${xmlee}\n";
	# ----->
	return 0;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: LoadOverrideFile
# Attempts to load a comma delimited file that will override the GeoIP database
# Useful for Intranet records
# CSV format: IP,2-char Country code, region
#-----------------------------------------------------------------------------
sub LoadOverrideFile_geoip_region_maxmind{
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
			# now we need to copy our file values in the order to mimic the lookup values
			my @res = ();
			$res[0] = $record[1];	# country code
			$res[1] = $record[2];	# region code
			# store in hash
			$TmpDomainLookup{$record[0]} = [@res];
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
sub TmpLookup_geoip_region_maxmind(){
	$param = shift;
	if (!$LoadedOverride){&LoadOverrideFile_geoip_region_maxmind();}
	#my @val = ();
	#if ($geoip_region_maxmind &&
	#(($type eq 'geoip' && $geoip_region_maxmind->VERSION >= 1.30) || 
	#  $type eq 'geoippureperl' && $geoip_region_maxmind->VERSION >= 1.17)){
	#	@val = @{$TmpDomainLookup{$geoip_region_maxmind->get_ip_address($param)}};
	#}
    #else {@val = @{$TmpDomainLookup{$param};}}
    #return @val;
    if ($TmpDomainLookup{$param}) { return @{$TmpDomainLookup{$param};} }  
    else { return; }
}

1;	# Do not remove this line

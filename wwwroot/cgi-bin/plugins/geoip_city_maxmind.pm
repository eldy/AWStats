#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GeoIp_City_Maxmind AWStats plugin
# This plugin allow you to add a city report.
# Need the licensed city database from Maxmind.
#-----------------------------------------------------------------------------
# Perl Required Modules: Geo::IP (Geo::IP::PurePerl is not yet supported)
#-----------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
if (!eval ('require "Geo/IP.pm";')) 	{
    return $@?"Error: $@":"Error: Need Perl module Geo::IP (Geo::IP::PurePerl is not yet supported)";
}
# ----->
use strict;no strict "refs";



#-----------------------------------------------------------------------------
# PLUGIN VARIABLES
#-----------------------------------------------------------------------------
# <-----
# ENTER HERE THE MINIMUM AWSTATS VERSION REQUIRED BY YOUR PLUGIN
# AND THE NAME OF ALL FUNCTIONS THE PLUGIN MANAGE.
my $PluginNeedAWStatsVersion="6.2";
my $PluginHooksFunctions="AddHTMLMenuLink AddHTMLGraph ShowInfoHost SectionInitHashArray SectionProcessIp SectionProcessHostname SectionReadHistory SectionWriteHistory";
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$geoip_city_maxmind
%_city_p
%_city_h
%_city_k
%_city_l
%_region_p
%_region_h
%_region_k
%_region_l
$MAXNBOFSECTIONGIR
%region
/;
my %countrylib=('ca'=>'Canadian Regions','us'=>'US regions');
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
sub Init_geoip_city_maxmind {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
    $MAXNBOFSECTIONGIR=10;
    
	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin geoip_city_maxmind: InitParams=$InitParams",1);
#    if ($UpdateStats) {
    	my ($mode,$datafile)=split(/\s+/,$InitParams,2);
    	if (! $datafile) { $datafile="GeoIPCity.dat"; }
    	if ($mode eq '' || $mode eq 'GEOIP_MEMORY_CACHE')  { $mode=Geo::IP::GEOIP_MEMORY_CACHE(); }
    	else { $mode=Geo::IP::GEOIP_STANDARD(); }
    	debug(" Plugin geoip_city_maxmind: GeoIP initialized in mode $mode",1);
        $geoip_city_maxmind = Geo::IP->open($datafile, $mode);
#    }
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLMenuLink_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLMenuLink_geoip_city_maxmind {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
	if ($Debug) { debug(" Plugin geoip_city_maxmind: AddHTMLMenuLink"); }
    if ($categ eq 'who') {
        $menu->{'plugin_geoip_city_maxmind'}=1;               # Pos
        $menulink->{'plugin_geoip_city_maxmind'}=2;           # Type of link
        $menutext->{'plugin_geoip_city_maxmind'}="Cities";    # Text
    }
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLGraph_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLGraph_geoip_city_maxmind {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
    my $ShowCities='H';
	$MinHit{'Cities'}=1;
	my $total_p; my $total_h; my $total_k;
	my $rest_p; my $rest_h; my $rest_k;

	if ($Debug) { debug(" Plugin geoip_city_maxmind: AddHTMLGraph $categ $menu $menulink $menutext"); }
	my $title='Cities';
	&tab_head("$title",19,0,'cities');
	print "<tr bgcolor=\"#$color_TableBGRowTitle\"><th colspan=\"2\">Cities : ".((scalar keys %_city_h)-($_city_h{'unknown'}?1:0))."</th>";
	if ($ShowCities =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[56]</th>"; }
	if ($ShowCities =~ /P/i) { print "<th bgcolor=\"#$color_p\" width=\"80\">$Message[15]</th>"; }
	if ($ShowCities =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[57]</th>"; }
	if ($ShowCities =~ /H/i) { print "<th bgcolor=\"#$color_h\" width=\"80\">$Message[15]</th>"; }
	if ($ShowCities =~ /B/i) { print "<th bgcolor=\"#$color_k\" width=\"80\">$Message[75]</th>"; }
	if ($ShowCities =~ /L/i) { print "<th width=\"120\">$Message[9]</th>"; }
	print "</tr>\n";
	$total_p=$total_h=$total_k=0;
	my $count=0;
	&BuildKeyList($MaxRowsInHTMLOutput,$MinHit{'Cities'},\%_city_h,\%_city_h);
    # Group by country
#    my @countrylist=('ca','us');
#    foreach my $country (@countrylist) {
#	    print "<tr>";
#	    print "<td class=\"aws\"><b>".$countrylib{$country}."</b></td>";
#   		if ($ShowCities =~ /P/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowCities =~ /P/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowCities =~ /H/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowCities =~ /H/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowCities =~ /B/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowCities =~ /L/i) { print "<td>&nbsp;</td>"; }
#        print "</tr>\n";
    	foreach my $key (@keylist) {
            if ($key eq 'unknown') { next; }
   		    my ($countrycode,$city)=split('_',$key);
#            if ($countrycode ne $country) { next; }
   			my $p_p; my $p_h;
   			if ($TotalPages) { $p_p=int($_city_p{$key}/$TotalPages*1000)/10; }
   			if ($TotalHits)  { $p_h=int($_city_h{$key}/$TotalHits*1000)/10; }
   		    print "<tr>";
   		    print "<td class=\"aws\">".$DomainsHashIDLib{$countrycode}."</td>";
   		    print "<td class=\"aws\">".ucfirst($city)."</td>";
    		if ($ShowCities =~ /P/i) { print "<td>".($_city_p{$key}?$_city_p{$key}:"&nbsp;")."</td>"; }
    		if ($ShowCities =~ /P/i) { print "<td>".($_city_p{$key}?"$p_p %":'&nbsp;')."</td>"; }
    		if ($ShowCities =~ /H/i) { print "<td>".($_city_h{$key}?$_city_h{$key}:"&nbsp;")."</td>"; }
    		if ($ShowCities =~ /H/i) { print "<td>".($_city_h{$key}?"$p_h %":'&nbsp;')."</td>"; }
    		if ($ShowCities =~ /B/i) { print "<td>".Format_Bytes($_city_k{$key})."</td>"; }
    		if ($ShowCities =~ /L/i) { print "<td>".($_city_p{$key}?Format_Date($_city_l{$key},1):'-')."</td>"; }
    		print "</tr>\n";
    		$total_p += $_city_p{$key}||0;
    		$total_h += $_city_h{$key};
    		$total_k += $_city_k{$key}||0;
    		$count++;
    	}
#    }
	if ($Debug) { debug("Total real / shown : $TotalPages / $total_p - $TotalHits / $total_h - $TotalBytes / $total_h",2); }
	$rest_p=0;
	$rest_h=$TotalHits-$total_h;
	$rest_k=0;
	if ($rest_p > 0 || $rest_h > 0 || $rest_k > 0) {	# All other cities
#	    print "<tr>";
#	    print "<td class=\"aws\">&nbsp;</td>";
#   		if ($ShowCities =~ /P/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowCities =~ /P/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowCities =~ /H/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowCities =~ /H/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowCities =~ /B/i) { print "<td>&nbsp;</td>"; }
#   		if ($ShowCities =~ /L/i) { print "<td>&nbsp;</td>"; }
#        print "</tr>\n";

		my $p_p; my $p_h;
		if ($TotalPages) { $p_p=int($rest_p/$TotalPages*1000)/10; }
		if ($TotalHits)  { $p_h=int($rest_h/$TotalHits*1000)/10; }
		print "<tr>";
		print "<td class=\"aws\" colspan=\"2\"><span style=\"color: #$color_other\">$Message[2]/$Message[0]</span></td>";
		if ($ShowCities =~ /P/i) { print "<td>".($rest_p?$rest_p:"&nbsp;")."</td>"; }
   		if ($ShowCities =~ /P/i) { print "<td>".($rest_p?"$p_p %":'&nbsp;')."</td>"; }
		if ($ShowCities =~ /H/i) { print "<td>".($rest_h?$rest_h:"&nbsp;")."</td>"; }
   		if ($ShowCities =~ /H/i) { print "<td>".($rest_h?"$p_h %":'&nbsp;')."</td>"; }
		if ($ShowCities =~ /B/i) { print "<td>".Format_Bytes($rest_k)."</td>"; }
		if ($ShowCities =~ /L/i) { print "<td>&nbsp;</td>"; }
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
sub ShowInfoHost_geoip_city_maxmind {
    my $param="$_[0]";
	# <-----
	if ($param eq '__title__') {
		print "<th width=\"80\">GeoIP<br>City</th>";
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
        	my $record=();
        	$record=$geoip_city_maxmind->record_by_addr($param) if $geoip_city_maxmind;
        	if ($Debug) { debug("  Plugin geoip_city_maxmind: GetCityByIp for $param: [$record]",5); }
            my $city;
            $city=$record->city if $record;
		    if ($city) { print "$city"; }
		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
		}
		if ($key && $ip==6) {
		    print "<span style=\"color: #$color_other\">$Message[0]</span>";
		}
		if (! $key) {
        	my $record=();
        	$record=$geoip_city_maxmind->record_by_name($param) if $geoip_city_maxmind;
        	if ($Debug) { debug("  Plugin geoip_city_maxmind: GetCityByHostname for $param: [$record]",5); }
            my $city;
            $city=$record->city if $record;
		    if ($city) { print "$city"; }
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
sub SectionInitHashArray_geoip_city_maxmind {
    my $param="$_[0]";
	# <-----
	if ($Debug) { debug(" Plugin geoip_city_maxmind: Init_HashArray"); }
	%_city_p = %_city_h = %_city_k = %_city_l =();
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessIP_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessIp_geoip_city_maxmind {
    my $param="$_[0]";      # Param must be an IP
	# <-----
	my $record=();
	$record=$geoip_city_maxmind->record_by_addr($param) if $geoip_city_maxmind;
	if ($Debug) { debug("  Plugin geoip_city_maxmind: GetCityByIp for $param: [$record]",5); }
    my $city=$record->city;
#	if ($PageBool) { $_city_p{$city}++; }
    if ($city) {
        my $countrycity=lc(($record->country_code)."_".$city);
        $countrycity=~tr/ /_/;
        $_city_h{$countrycity}++;
    } else {
        $_city_h{'unknown'}++;
    }
#	if ($timerecord > $_city_l{$city}) { $_city_l{$city}=$timerecord; }
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessHostname_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessHostname_geoip_city_maxmind {
    my $param="$_[0]";      # Param must be an IP
	# <-----
	my $record=();
	$record=$geoip_city_maxmind->record_by_name($param) if $geoip_city_maxmind;
	if ($Debug) { debug("  Plugin geoip_city_maxmind: GetCityByName for $param: [$record]",5); }
    my $city=$record->city;
#	if ($PageBool) { $_city_p{$city}++; }
    if ($city) {
        my $countrycity=lc(($record->country_code)."_".$city);
        $countrycity=~tr/ /_/;
        $_city_h{$countrycity}++;
    } else {
        $_city_h{'unknown'}++;
    }
#	if ($timerecord > $_city_l{$city}) { $_city_l{$city}=$timerecord; }
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionReadHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionReadHistory_geoip_city_maxmind {
    my $issectiontoload=shift;
    my $xmlold=shift;
    my $xmleb=shift;
	my $countlines=shift;
	# <-----
	if ($Debug) { debug(" Plugin geoip_city_maxmind: Begin of PLUGIN_geoip_city_maxmind section"); }
	my @field=();
	my $count=0;my $countloaded=0;
	do {
		if ($field[0]) {
			$count++;
			if ($issectiontoload) {
				$countloaded++;
				if ($field[2]) { $_city_h{$field[0]}+=$field[2]; }
			}
		}
		$_=<HISTORY>;
		chomp $_; s/\r//;
		@field=split(/\s+/,($xmlold?CleanFromTags($_):$_));
		$countlines++;
	}
	until ($field[0] eq 'END_PLUGIN_geoip_city_maxmind' || $field[0] eq "${xmleb}END_PLUGIN_geoip_city_maxmind" || ! $_);
	if ($field[0] ne 'END_PLUGIN_geoip_city_maxmind' && $field[0] ne "${xmleb}END_PLUGIN_geoip_city_maxmind") { error("History file is corrupted (End of section PLUGIN not found).\nRestore a recent backup of this file (data for this month will be restored to backup date), remove it (data for month will be lost), or remove the corrupted section in file (data for at least this section will be lost).","","",1); }
	if ($Debug) { debug(" Plugin geoip_city_maxmind: End of PLUGIN_geoip_city_maxmind section ($count entries, $countloaded loaded)"); }
	# ----->
	return 0;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionWriteHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionWriteHistory_geoip_city_maxmind {
    my ($xml,$xmlbb,$xmlbs,$xmlbe,$xmlrb,$xmlrs,$xmlre,$xmleb,$xmlee)=(shift,shift,shift,shift,shift,shift,shift,shift,shift);
    if ($Debug) { debug(" Plugin geoip_city_maxmind: SectionWriteHistory_geoip_city_maxmind start - ".(scalar keys %_city_h)); }
	# <-----
	print HISTORYTMP "\n";
	if ($xml) { print HISTORYTMP "<section id='plugin_geoip_city_maxmind'><sortfor>$MAXNBOFSECTIONGIR</sortfor><comment>\n"; }
	print HISTORYTMP "# Plugin key - Pages - Hits - Bandwidth - Last access\n";
	#print HISTORYTMP "# The $MaxNbOfExtra[$extranum] first number of hits are first\n";
	$ValueInFile{'plugin_geoip_city_maxmind'}=tell HISTORYTMP;
	print HISTORYTMP "${xmlbb}BEGIN_PLUGIN_geoip_city_maxmind${xmlbs}".(scalar keys %_city_h)."${xmlbe}\n";
	&BuildKeyList($MAXNBOFSECTIONGIR,1,\%_city_h,\%_city_h);
	my %keysinkeylist=();
	foreach (@keylist) {
		$keysinkeylist{$_}=1;
		#my $page=$_city_p{$_}||0;
		#my $bytes=$_city_k{$_}||0;
		#my $lastaccess=$_city_l{$_}||'';
		print HISTORYTMP "${xmlrb}$_${xmlrs}0${xmlrs}", $_city_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	foreach (keys %_city_h) {
		if ($keysinkeylist{$_}) { next; }
		#my $page=$_city_p{$_}||0;
		#my $bytes=$_city_k{$_}||0;
		#my $lastaccess=$_city_l{$_}||'';
		print HISTORYTMP "${xmlrb}$_${xmlrs}0${xmlrs}", $_city_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	print HISTORYTMP "${xmleb}END_PLUGIN_geoip_city_maxmind${xmlee}\n";
	# ----->
	return 0;
}



1;	# Do not remove this line

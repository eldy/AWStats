#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GeoIp2_City AWStats plugin
# This plugin allow you to add a city report.
# Need the licensed city database from Maxmind.
#-----------------------------------------------------------------------------
# Perl Required Modules: Geo::IP or Geo::IP::PurePerl
#-----------------------------------------------------------------------------
# 1.4 - Chris Larsen - added file override capabilities

# <-----
# ENTER HERE THE USE COMMAND FOR ALL REQUIRED PERL MODULES
use vars qw/ $type /;
$type='geoip2';
if (!eval ('require "GeoIP2/Database/Reader.pm";')) {
	$error=$@;
    $ret=($error)?"Error:\n$error":"";
    $ret.="Error: Need Perl module GeoIP2::Database::Reader";
    return $ret;
}
# GeoIP2 Perl API doesn't have a ByName lookup so we need to do the resolution ourselves
if (!eval ('require "Socket.pm";')) {
	$error=$@;
    $ret=($error)?"Error:\n$error":"";
    $ret.="Error: Need Perl module Socket";
    return $ret;
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
my $PluginName="geoip2_city";
my $LoadedOverride=0;
my $OverrideFile="";
my %TmpDomainLookup = {}; 
# ----->

# <-----
# IF YOUR PLUGIN NEED GLOBAL VARIABLES, THEY MUST BE DECLARED HERE.
use vars qw/
$geoip2_city
%_city_p
%_city_h
%_city_k
%_city_l
$MAXNBOFSECTIONGIR
/;
# ----->



#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: Init_pluginname
#-----------------------------------------------------------------------------
sub Init_geoip2_city {
	my $InitParams=shift;
	my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
    $MAXNBOFSECTIONGIR=10;
    
	# <-----
	# ENTER HERE CODE TO DO INIT PLUGIN ACTIONS
	debug(" Plugin $PluginName: InitParams=$InitParams",1);
    my ($datafile,$override)=split(/\+/,$InitParams,2);
   	if (! $datafile) { $datafile="GeoLite2-City.mmdb"; }
   	else { $datafile =~ s/%20/ /g; }
	if ($override){ $override =~ s/%20/ /g; $OverrideFile=$override; }
	%TmpDomainLookup=();
	debug(" Plugin $PluginName: GeoIP initialized type=$type override=$override",1);
	$geoip2_city = GeoIP2::Database::Reader->new(
        file    => $datafile,
        locales => [ 'en', 'de', ]);
	$LoadedOverride=0;
	# Fails on some GeoIP version
	# debug(" Plugin geoip2_city: GeoIP initialized database_info=".$geoip2_city->database_info());
	if ($geoip2_city) { debug(" Plugin $PluginName: GeoIP plugin and gi object initialized",1); }
	else { return "Error: Failed to create gi object for datafile=".$datafile; }
	# ----->

	return ($checkversion?$checkversion:"$PluginHooksFunctions");
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLMenuLink_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLMenuLink_geoip2_city {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: AddHTMLMenuLink"); }
    if ($categ eq 'who') {
        $menu->{"plugin_$PluginName"}=2.2;               # Pos
        $menulink->{"plugin_$PluginName"}=2;             # Type of link
        $menutext->{"plugin_$PluginName"}=$Message[172]; # Text
    }
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: AddHTMLGraph_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub AddHTMLGraph_geoip2_city {
    my $categ=$_[0];
    my $menu=$_[1];
    my $menulink=$_[2];
    my $menutext=$_[3];
	# <-----
    my $ShowCities='H';
	$MinHit{'Cities'}=1;
	my $total_p; my $total_h; my $total_k;
	my $rest_p; my $rest_h; my $rest_k;

	if ($Debug) { debug(" Plugin $PluginName: AddHTMLGraph $categ $menu $menulink $menutext"); }
	my $title="GeoIP Cities";
	&tab_head($title,19,0,'cities');
	print "<tr bgcolor=\"#$color_TableBGRowTitle\">";
	print "<th>".$Message[148]."</th>";
	print "<th>".$Message[171]."</th>";
	print "<th>".$Message[172].": ".((scalar keys %_city_h)-($_city_h{'unknown'}?1:0))."</th>";
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
   		    my ($countrycode,$city,$regionname)=split('_',$key,3);
            $city=~s/%20/ /g;
            $regionname=~s/%20/ /g;
#            if ($countrycode ne $country) { next; }
   			my $p_p; my $p_h;
			if ($TotalPages) { $p_p=int(($_city_p{$key}||0)/$TotalPages*1000)/10; }
   			if ($TotalHits)  { $p_h=int($_city_h{$key}/$TotalHits*1000)/10; }
   		    print "<tr>";
   		    print "<td class=\"aws\">".$DomainsHashIDLib{$countrycode}."</td>";
   		    print "<td class=\"aws\">".ucfirst(EncodeToPageCode($regionname))."</td>";
   		    print "<td class=\"aws\">".ucfirst(EncodeToPageCode($city))."</td>";
    		if ($ShowCities =~ /P/i) { print "<td>".($_city_p{$key}?Format_Number($_city_p{$key}):"&nbsp;")."</td>"; }
    		if ($ShowCities =~ /P/i) { print "<td>".($_city_p{$key}?"$p_p %":'&nbsp;')."</td>"; }
    		if ($ShowCities =~ /H/i) { print "<td>".($_city_h{$key}?Format_Number($_city_h{$key}):"&nbsp;")."</td>"; }
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
		print "<td class=\"aws\" colspan=\"3\"><span style=\"color: #$color_other\">$Message[2]/$Message[0]</span></td>";
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
sub ShowInfoHost_geoip2_city {
    my $param="$_[0]";
	# <-----
	if ($param eq '__title__')
	{
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

#		print "<th width=\"80\">";
#        print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?XMLEncode("$AWScript?${NewLinkParams}output=plugin_geoip2_city&amp;suboutput=country"):"$PROG$StaticLinks.plugin_geoip2_city.country.$StaticExt")."\"$NewLinkTarget>GeoIP2<br/>Country</a>";
#        print "</th>";
		print "<th width=\"80\">";
        print "<a href=\"".($ENV{'GATEWAY_INTERFACE'} || !$StaticLinks?XMLEncode("$AWScript?${NewLinkParams}output=plugin_$PluginName"):"$StaticLinks.plugin_$PluginName.$StaticExt")."\"$NewLinkTarget>GeoIP2<br/>City</a>";
        print "</th>";
	}
	elsif ($param)
	{
		# try loading our override file if we haven't yet
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
		if ($key) {
	        my $country;
	        my $city;
	        my @res = TmpLookup_geoip2_city($param);
	        if (@res){
	        	$country = $res[0];
	        	$city = $res[4];
	        }
			else
			{
	        	my $record=();
	        	if ($Debug) { debug("  Plugin $PluginName: ShowInfoHost_geoip2_city for $param",5); }
	        	$record=$geoip2_city->city(ip=>$param) if $geoip2_city;
	        	if ($Debug) { debug("  Plugin $PluginName: ShowInfoHost_geoip2_city for $param: [".$record->city()->name()."]",5); }
	            $country=$record->country()->iso_code() if $record;
	            $city=$record->city()->name() if $record;
			}
#			print "<td>";
#		    if ($country) { print $DomainsHashIDLib{$country}?$DomainsHashIDLib{$country}:"<span style=\"color: #$color_other\">$Message[0]</span>"; }
#		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
#		    print "</td>";
			print "<td>";
		    if ($city) { print EncodeToPageCode($city); }
		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
		    print "</td>";
		}
		if (! $key) {
	        my $country;
	        my $city;
	        my @res = TmpLookup_geoip2_city($param);
	        if (@res){
	        	$country = $res[0];
	        	$city = $res[4];
	        }
			else
			{
	        	my $record=();
                # First resolve the name to an IP
                $address = inet_ntoa(inet_aton($param));
                if ($Debug) { debug("  Plugin $PluginName: ShowInfoHost_geoip2_city $param resolved to $address",5); }
                # Now do the same lookup from the IP
	        	$record=$geoip2_city->city(ip=>$address) if $geoip2_city;
	        	if ($Debug) { debug("  Plugin $PluginName: ShowInfoHost_geoip2_city for $param: [$record]",5); }
	            $country=$record->country()->iso_code() if $record;
	            $city=$record->city()->name() if $record;
			}
#			print "<td>";
#		    if ($country) { print $DomainsHashIDLib{$country}?$DomainsHashIDLib{$country}:"<span style=\"color: #$color_other\">$Message[0]</span>"; }
#		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
#		    print "</td>";
			print "<td>";
		    if ($city) { print EncodeToPageCode($city); }
		    else { print "<span style=\"color: #$color_other\">$Message[0]</span>"; }
			print "</td>";
		}
	}
	else
	{ print "<td>&nbsp;</td>"; }
	return 1;
	# ----->
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionInitHashArray_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionInitHashArray_geoip2_city {
#    my $param="$_[0]";
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: Init_HashArray"); }
	%_city_p = %_city_h = %_city_k = %_city_l =();
	# ----->
	return 0;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessIP_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessIp_geoip2_city {
    my $param="$_[0]";      # Param must be an IP
	# <-----
    my $record=();
    my @rec = TmpLookup_geoip2_city($param);
    if (@rec){
        $record->city = $rec[4];
        $record->region = $rec[0];
        $record->country_code = $rec[3];
    }else{
        if ($Debug) { debug("  Plugin $PluginName: SectionProcessIp_geoip2_city for $param",5); }
        $record=$geoip2_city->city(ip=>$param) if $geoip2_city;
    }
    if ($Debug) { debug("  Plugin $PluginName: GetCityByIp for $param: [".$record->city()->name()."]",5); }
    if ($record) {
        my $city=$record->city()->name();
#   	if ($PageBool) { $_city_p{$city}++; }
        if ($city) {
            my $countrycity=$record->country()->iso_code().'_'.$record->city()->name();
            $countrycity=~s/ /%20/g;
            if ($record->most_specific_subdivision()->name()) { $countrycity.='_'.$record->most_specific_subdivision()->name(); }
            $_city_h{lc($countrycity)}++;
        } else {
            $_city_h{'unknown'}++;
        }
#   	if ($timerecord > $_city_l{$city}) { $_city_l{$city}=$timerecord; }
    } else {
        $_city_h{'unknown'}++;
    }
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionProcessHostname_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionProcessHostname_geoip2_city {
    my $param="$_[0]";      # Param must be an IP
    my $record=();
    my @rec = TmpLookup_geoip2_city($param);
    if (@rec){
        $record->city = $rec[4];
        $record->region = $rec[3];
        $record->country_code = $rec[0];
    }else{
        # First resolve the name to an IP
        $address = inet_ntoa(inet_aton($param));
		if ($Debug) { debug("  Plugin $PluginName: SectionProcessHostname_geoip2_city $param resolved to $address",5); }
        # Now do the same lookup from the IP
        $record=$geoip2_city->city(ip=>$address) if $geoip2_city;
    }
    if ($Debug) { debug("  Plugin $PluginName: GetCityByName for $param: [$record]",5); }
    if ($record) {
        my $city=$record->city()->name();
#	    if ($PageBool) { $_city_p{$city}++; }
        if ($city) {
            my $countrycity=($record->country()->iso_code()).'_'.$city;
            $countrycity=~s/ /%20/g;
            if ($record->most_specific_subdivision()->name()) { $countrycity.='_'.$record->most_specific_subdivision()->name(); }
            $_city_h{lc($countrycity)}++;
        } else {
            $_city_h{'unknown'}++;
        }
#	    if ($timerecord > $_city_l{$city}) { $_city_l{$city}=$timerecord; }
    } else {
        $_city_h{'unknown'}++;
    }
	# ----->
	return;
}


#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: SectionReadHistory_pluginname
# UNIQUE: NO (Several plugins using this function can be loaded)
#-----------------------------------------------------------------------------
sub SectionReadHistory_geoip2_city {
    my $issectiontoload=shift;
    my $xmlold=shift;
    my $xmleb=shift;
	my $countlines=shift;
	# <-----
	if ($Debug) { debug(" Plugin $PluginName: Begin of PLUGIN_geoip2_city section"); }
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
sub SectionWriteHistory_geoip2_city {
    my ($xml,$xmlbb,$xmlbs,$xmlbe,$xmlrb,$xmlrs,$xmlre,$xmleb,$xmlee)=(shift,shift,shift,shift,shift,shift,shift,shift,shift);
    if ($Debug) { debug(" Plugin $PluginName: SectionWriteHistory_$PluginName start - ".(scalar keys %_city_h)); }
	# <-----
	print HISTORYTMP "\n";
	if ($xml) { print HISTORYTMP "<section id='plugin_$PluginName'><sortfor>$MAXNBOFSECTIONGIR</sortfor><comment>\n"; }
	print HISTORYTMP "# Plugin key - Pages - Hits - Bandwidth - Last access\n";
	#print HISTORYTMP "# The $MaxNbOfExtra[$extranum] first number of hits are first\n";
	$ValueInFile{"plugin_$PluginName"}=tell HISTORYTMP;
	print HISTORYTMP "${xmlbb}BEGIN_PLUGIN_$PluginName${xmlbs}".(scalar keys %_city_h)."${xmlbe}\n";
	&BuildKeyList($MAXNBOFSECTIONGIR,1,\%_city_h,\%_city_h);
	my %keysinkeylist=();
	foreach (@keylist) {
		$keysinkeylist{$_}=1;
		#my $page=$_city_p{$_}||0;
		#my $bytes=$_city_k{$_}||0;
		#my $lastaccess=$_city_l{$_}||'';
		print HISTORYTMP "${xmlrb}".XMLEncodeForHisto($_)."${xmlrs}0${xmlrs}", $_city_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	foreach (keys %_city_h) {
		if ($keysinkeylist{$_}) { next; }
		#my $page=$_city_p{$_}||0;
		#my $bytes=$_city_k{$_}||0;
		#my $lastaccess=$_city_l{$_}||'';
		print HISTORYTMP "${xmlrb}".XMLEncodeForHisto($_)."${xmlrs}0${xmlrs}", $_city_h{$_}, "${xmlrs}0${xmlrs}0${xmlre}\n"; next;
	}
	print HISTORYTMP "${xmleb}END_PLUGIN_$PluginName${xmlee}\n";
	# ----->
	return 0;
}

#-----------------------------------------------------------------------------
# PLUGIN FUNCTION: LoadOverrideFile
# Attempts to load a comma delimited file that will override the GeoIP database
# Useful for Intranet records
# CSV format: IP,2-char Country code, region, city, postal code, latitude, 
#				longitude, US metro code, US area code
#-----------------------------------------------------------------------------
sub LoadOverrideFile_geoip2_city{
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
			$res[0] = $record[1];
			$res[3] = $record[2];
			$res[4] = $record[3];
			$res[5] = $record[4];
			$res[6] = $record[5];
			$res[7] = $record[6];
			$res[8] = $record[7];
			$res[9] = $record[8];
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
sub TmpLookup_geoip2_city(){
	$param = shift;
	if (!$LoadedOverride){&LoadOverrideFile_geoip2_city();}
#	my @val = ();
#	if ($geoip2_city &&
#	(($type eq 'geoip' && $geoip2_city->VERSION >= 1.30) || 
#	  $type eq 'geoippureperl' && $geoip2_city->VERSION >= 1.17)){
#		@val = @{$TmpDomainLookup{$geoip2_city->get_ip_address($param)}};
#	}
#    else {@val = @{$TmpDomainLookup{$param};}}
#    return @val;
    if ($TmpDomainLookup{$param}) { return @{$TmpDomainLookup{$param};} }  
    else { return; }
}


1;	# Do not remove this line

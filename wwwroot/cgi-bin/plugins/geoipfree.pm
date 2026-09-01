#!/usr/bin/perl
#-----------------------------------------------------------------------------
# GeoIpFree AWStats plugin - Fixed
#-----------------------------------------------------------------------------

push @INC, "${DIR}/plugins";
if (!eval ('require Geo::IPfree;')) { 
    return $@?"Error: $@":"Error: Need Perl module Geo::IPfree"; 
}
no strict "refs";

my $PluginNeedAWStatsVersion="5.5";
my $PluginHooksFunctions="GetCountryCodeByAddr GetCountryCodeByName";

use vars qw/
%TmpDomainLookup
%TmpDomainFullLocation
$gi
/;
use Encode qw(encode_utf8 decode_utf8);
use open ':std', ':encoding(UTF-8)';
sub _t {
    my $str = shift;
    return $str;
}

sub Init_geoipfree {
    my $InitParams=shift;
    my $checkversion=&Check_Plugin_Version($PluginNeedAWStatsVersion);
    debug(" Plugin geoipfree: InitParams=$InitParams",1);
    %TmpDomainLookup=();
    %TmpDomainFullLocation=();
    $gi = Geo::IPfree->new();
    return ($checkversion?$checkversion:"$PluginHooksFunctions");
}

sub GetCountryCodeByName_geoipfree {
    my $param="$_[0]";
    my $res=$TmpDomainLookup{$param}||'';
    if (! $res) {
        my ($country_code, $full_location, $state, $city) = $gi->LookUp($param);
        
        my $display_location = '';
        if ($full_location && $full_location ne '' && $full_location ne _t("Unknown")) {
            $display_location = $full_location;
        } elsif ($city && $city ne '') {
            $display_location = "$country_code, $city";
        } elsif ($state && $state ne '') {
            $display_location = "$country_code, $state";
        } else {
            $display_location = $country_code;
        }
        
        $display_location =~ s/,\s*$//;
        $display_location =~ s/^\s*//;
        
        if ($display_location && $display_location ne '' && $display_location ne '--' && $display_location ne 'ip') {
            $res = $display_location;
        } else {
            $res = $country_code;
            if ($res !~ /\w\w/) { $res='ip'; }
            else { $res=lc($res); }
        }
        
        $TmpDomainLookup{$param}=$res;
    }
    return $res;
}

sub GetCountryCodeByAddr_geoipfree {
    my $param="$_[0]";
    my $res=$TmpDomainLookup{$param}||'';
    if (! $res) {
        my ($country_code, $full_location, $state, $city) = $gi->LookUp($param);
        
        my $display_location = '';
        if ($full_location && $full_location ne '' && $full_location ne _t("Unknown")) {
            $display_location = $full_location;
        } elsif ($city && $city ne '') {
            $display_location = "$country_code, $city";
        } elsif ($state && $state ne '') {
            $display_location = "$country_code, $state";
        } else {
            $display_location = $country_code;
        }
        
        $display_location =~ s/,\s*/, /g;
        $display_location =~ s/^\s*//;
        $display_location =~ s/\s*$//;

        my $storage_location = $display_location;
        $storage_location =~ s/ /_/g;
        $storage_location = encode_utf8($storage_location);
        
        my $code = lc($country_code);
        $TmpDomainFullLocation{$code} = {
            display => $display_location,
            code => $code,
            country_name => $country_code,
            state => $state,
            city => $city
        };
        
        $res = $storage_location;
        $TmpDomainLookup{$param} = $res;
        
        if ($Debug) {
            debug(" Plugin geoipfree: IP=$param -> Code=$code, Location=$display_location",2);
        }
    }
    return $res;
}

1;
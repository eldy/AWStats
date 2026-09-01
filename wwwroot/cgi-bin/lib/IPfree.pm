package Geo::IPfree;
# use 5.020;
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use Carp qw();

require Exporter;
our @ISA = qw(Exporter);

our $VERSION = '2.0.0';

our @EXPORT    = qw(LookUp LoadDB);
our @EXPORT_OK = @EXPORT;

my $DEFAULT_MMDB = 'dbip-city.mmdb';
my $cache_expire = 5000;

# 初始化国家代码映射
my %countrys = ();

{
    my $data_content = '';
    if (defined *DATA && defined fileno(DATA)) {
        local $/;
        $data_content = <DATA>;
    }
    
    if ($data_content) {
        my @lines = split /\n/, $data_content;
        foreach my $line (@lines) {
            last if $line =~ /^__END__/;
            chomp $line;
            next if $line =~ /^\s*$/;
            my ($code, $name) = split /\s+/, $line, 2;
            if ($code && $name) {
                $countrys{$code} = $name;
            }
        }
    }
    
    if (!%countrys) {
        %countrys = (
            '--' => 'N/A',
            'L0' => 'localhost',
            'I0' => 'IntraNet',
            'A1' => 'Anonymous Proxy',
            'A2' => 'Satellite Provider',
            'US' => 'United States',
            'CN' => 'China',
            'JP' => 'Japan',
            'GB' => 'United Kingdom',
            'DE' => 'Germany',
            'FR' => 'France',
            'CA' => 'Canada',
            'AU' => 'Australia',
            'RU' => 'Russian Federation',
            'BR' => 'Brazil',
            'IN' => 'India',
        );
    }
}

sub new {
    my ($class, $mmdb_file) = @_;
    
    my $this = bless {}, $class;
    
    $mmdb_file = _find_mmdb_file() unless $mmdb_file;
    
    # 检查 GeoIP2 模块是否可用
    my $has_geoip2 = eval "require GeoIP2::Database::Reader; 1";
    
    # 先尝试作为 MaxMind DB Reader 打开（用于 DB-IP）
    my $db_opened = 0;
    eval {
        require MaxMind::DB::Reader;
        $this->{mmdb_raw} = MaxMind::DB::Reader->new(file => $mmdb_file);
        $this->{db_type} = 'dbip';
        $db_opened = 1;
    };
    
    # 如果失败且 GeoIP2 可用，尝试作为 GeoIP2 Reader 打开
    if (!$db_opened && $has_geoip2) {
        eval {
            # 修正 locales 参数格式
            $this->{mmdb_geoip} = GeoIP2::Database::Reader->new(
                file    => $mmdb_file,
                locales => ['en'],
            );
            $this->{db_type} = 'geoip2';
            $db_opened = 1;
        };
        if ($@) {
            # 如果还失败，尝试不带 locales 参数
            eval {
                $this->{mmdb_geoip} = GeoIP2::Database::Reader->new(
                    file => $mmdb_file,
                );
                $this->{db_type} = 'geoip2';
                $db_opened = 1;
            };
        }
    }
    
    if (!$db_opened) {
        Carp::croak("Cannot open database file $mmdb_file: $@");
    }
    
    $this->{dbfile} = $mmdb_file;
    $this->{cache} = 1;
    $this->{cache_data} = {};
    $this->{cache_count} = 0;
    
    # 为了兼容旧代码
    $this->{CACHE} = {};
    $this->{CACHE_COUNT} = 0;
    
    return $this;
}

sub _find_mmdb_file {
    my @locations = (
        '/usr/local/share',
        '/usr/local/share/GeoIPfree',
        '/usr/share/perl5/Geo',
        '/usr/share/GeoIP',
        '/var/lib/GeoIP',
        map { $_, "$_/Geo" } @INC
    );
    
    if (exists $INC{'Geo/IPfree.pm'} && defined $INC{'Geo/IPfree.pm'}) {
        my ($lib) = ($INC{'Geo/IPfree.pm'} =~ /^(.*?)[\\\/]+[^\\\/]+$/gs);
        push @locations, $lib if $lib;
    }
    
    my @patterns = (
        $DEFAULT_MMDB,
        'dbip-city.mmdb',
    );
    
    foreach my $dir (@locations) {
        next unless -d $dir;
        foreach my $pattern (@patterns) {
            my $file = "$dir/$pattern";
            return $file if -f $file;
        }
    }
    
    foreach my $dir (@locations) {
        next unless -d $dir;
        opendir(my $dh, $dir) || next;
        my @files = grep { /\.mmdb$/i && -f "$dir/$_" } readdir($dh);
        closedir($dh);
        return "$dir/$files[0]" if @files;
    }
    
    Carp::croak("Cannot find any MMDB database file in: " . join(', ', @locations));
}

sub _cache_result {
    my ($this, $key, $result) = @_;
    
    if (ref $result ne 'ARRAY') {
        warn "Attempt to cache non-array reference";
        return;
    }
    
    if ($this->{cache_count} > $cache_expire) {
        keys %{ $this->{cache_data} };
        my ($old_key) = each %{ $this->{cache_data} };
        delete $this->{cache_data}{$old_key} if $old_key;
        $this->{cache_count}--;
    }
    
    $this->{cache_data}{$key} = $result;
    $this->{cache_count}++;
    
    # 同时更新旧的缓存格式
    $this->{CACHE}{$key} = $result;
    $this->{CACHE_COUNT} = $this->{cache_count};
}

sub _query_mmdb {
    my ($this, $ip) = @_;
    
    my ($country_code, $country_name, $state_name, $city_name) = ('--', 'Unknown', '', '');
    
    eval {
        if ($this->{db_type} eq 'dbip') {
            my $data = $this->{mmdb_raw}->record_for_address($ip);
            
            if ($data && ref $data eq 'HASH') {
                # 国家信息
                if ($data->{country}) {
                    $country_code = $data->{country}->{iso_code} // '--';
                    if ($data->{country}->{names}) {
                        $country_name = $data->{country}->{names}->{'en'} // 'Unknown';
                    }
                }
                
                # 省份/州信息
                if ($data->{subdivisions} && ref $data->{subdivisions} eq 'ARRAY' && $data->{subdivisions}[0]) {
                    my $subdiv = $data->{subdivisions}[0];
                    if ($subdiv->{names}) {
                        $state_name = $subdiv->{names}->{'en'} // '';
                    }
                }
                
                # 城市信息
                if ($data->{city} && $data->{city}->{names}) {
                    $city_name = $data->{city}->{names}->{'en'} // '';
                }
            }
        } elsif ($this->{db_type} eq 'geoip2') {
            my $city = $this->{mmdb_geoip}->city(ip => $ip);
            if ($city) {
                $country_code = $city->country->iso_code // '--';
                $country_name = $city->country->name // 'Unknown';
                
                if ($city->most_specific_subdivision) {
                    $state_name = $city->most_specific_subdivision->name // '';
                }
                
                if ($city->city) {
                    $city_name = $city->city->name // '';
                }
            }
        }
    };
    
    if ($@) {
        warn "MMDB query failed for $ip: $@\n";
    }
    
    return ($country_code, $country_name, $state_name, $city_name);
}

sub LookUp {
    my $this;
    
    # 兼容旧的调用方式
    if ($#_ == 0) {
        my $class = 'Geo::IPfree';
        $this = $class->new();
    }
    else { 
        $this = shift; 
    }
    
    my ($ip) = @_;
    
    return unless defined $ip && $ip ne '';
    
    $ip = _clean_ip($ip);
    return unless $ip;
    
    my $cache_key = $ip;
    $cache_key =~ s/\.\d+$/\.0/;
    
    # 检查缓存
    if ($this->{cache} && exists $this->{cache_data}{$cache_key}) {
        my $cached = $this->{cache_data}{$cache_key};
        if (ref $cached eq 'ARRAY') {
            return wantarray ? @$cached : $cached->[0];
        }
    }
    
    my ($code, $country, $state, $city) = $this->_query_mmdb($ip);
    
    # 构建位置字符串
    my $location = $country;
    $location .= ", $state" if $state && $state ne '';
    $location .= ", $city" if $city && $city ne '';
    
    my @result = ($code, $location, $state, $city);
    
    # 缓存结果
    if ($this->{cache}) {
        $this->_cache_result($cache_key, \@result);
    }
    
    # 根据上下文返回
    if (wantarray) {
        return @result;
    } else {
        return $code;
    }
}

sub _clean_ip {
    my $ip = shift;
    
    return unless defined $ip;
    
    $ip =~ s/\.+/\./gs if index($ip, '..') > -1;
    substr($ip, 0, 1, '') if substr($ip, 0, 1) eq '.';
    chop $ip if substr($ip, -1) eq '.';
    my $is_ipv4 = ($ip =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/);
    my $is_ipv6 = ($ip =~ /:/);
    
    if (!$is_ipv4 && !$is_ipv6) {
        $ip = nslookup($ip);
    }
    
    return $ip;
}

# 保留旧的 nslookup 函数
sub nslookup {
    my ($host, $last_lookup) = @_;
    require Socket;
    my $iaddr = Socket::inet_aton($host) || '';
    my @ip = unpack('C4', $iaddr);
    
    return nslookup("www.$host", 1) if !@ip && !$last_lookup;
    return join('.', @ip);
}

sub Clean_Cache {
    my $this = shift;
    $this->{cache_count} = 0;
    $this->{cache_data} = {};
    $this->{CACHE_COUNT} = 0;
    $this->{CACHE} = {};
    return 1;
}

sub Faster {
    warn "Faster() is deprecated with MMDB backend";
    return 1;
}

sub LoadDB {
    warn "LoadDB() is deprecated - MMDB loads automatically in constructor";
    return 1;
}

sub get_all_countries {
    return {%countrys};
}

# 保留这些函数以保持向后兼容
sub ip2nb {
    warn "ip2nb() is deprecated with MMDB backend";
    return 0;
}

sub nb2ip {
    warn "nb2ip() is deprecated with MMDB backend";
    return '';
}

sub dec2baseX {
    warn "dec2baseX() is deprecated with MMDB backend";
    return '';
}

sub baseX2dec {
    warn "baseX2dec() is deprecated with MMDB backend";
    return 0;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Geo::IPfree - IP geolocation using MMDB database

=head1 VERSION

version 2.0.0

=head1 SYNOPSIS

    use Geo::IPfree;
    
    my $geo = Geo::IPfree->new();
    my ($code, $location, $state, $city) = $geo->LookUp('8.8.8.8');
    print "Country code: $code\n";
    print "Location: $location\n";
    print "State: $state\n";
    print "City: $city\n";

=cut
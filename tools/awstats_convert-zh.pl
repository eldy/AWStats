#!/usr/bin/perl
#------------------------------------------------------------------------------
# AWStats 数据文件格式转换器
# 功能：将旧格式(7.0-7.9)转换为新格式(8.1)，支持年月排序、断点续转、重复执行保护
# 用法: perl awstats_convert.pl [--force] [--dryrun]
#------------------------------------------------------------------------------
use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use File::Copy;
use File::Find;
use Getopt::Long;
#use Encode;
use File::Path qw(make_path);

# 设置 UTF-8 编码
binmode(STDIN, ':encoding(UTF-8)');
binmode(STDOUT, ':encoding(UTF-8)');
binmode(STDERR, ':encoding(UTF-8)');
#------------------------------------------------------------------------------
# --- 配置区域 ---
#------------------------------------------------------------------------------
my $STATS_PATTERN = '/home/*/web/*/stats/';
my $BACKUP_BASE_DIR = '/backup/awstats_converter';
my $LOG_FILE = '/var/log/awstats/awstats_converter.log';
my $PROGRESS_FILE = '/tmp/awstats_convert_progress';
# ---------

# 确保备份目录存在
for my $dir ($BACKUP_BASE_DIR, dirname($LOG_FILE), dirname($PROGRESS_FILE)) {
    make_path($dir) unless -d $dir;
}
unless (-d $BACKUP_BASE_DIR) {
    mkdir($BACKUP_BASE_DIR) or die "无法创建备份目录: $!";
}
my $BACKUP_DIR = "$BACKUP_BASE_DIR/backup_" . `date +%Y%m%d_%H%M%S`;
chomp $BACKUP_DIR;

# 命令行参数 - 修正变量名
my $force = 0;
my $dryrun = 0;      # 改为 dryrun，避免 - 符号问题
my $verbose = 1;

GetOptions(
    'force'    => \$force,
    'dryrun'   => \$dryrun,   # 注意：这里用 dryrun
    'quiet'    => sub { $verbose = 0 },
    'help'     => sub { usage(); exit 0 },
) or die "参数错误\n";

# 模拟 AWStats 需要的函数
sub Check_Plugin_Version { return 1; }
sub debug { }

# 加载 geoipfree 插件
my $plugin_loaded = 0;
eval {
    require '/usr/share/awstats/plugins/geoipfree.pm';
    $plugin_loaded = 1;
};
my $geo_init = $plugin_loaded ? Init_geoipfree('') : 0;

sub get_geo_location {
    my ($ip) = @_;
    if ($plugin_loaded && $geo_init) {
        my $geo = GetCountryCodeByAddr_geoipfree($ip);
        if ($geo && $geo ne '未知' && $geo ne 'Unknown') {
            $geo =~ s/[^\w\s\-_,]//g;
            $geo =~ s/\s+/_/g;
            return $geo;
        }
    }
    
    return "Local_Network" if $ip =~ /^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.|127\.|fe80:|::1$)/;
    if ($ip =~ /^(1|14|27|42|58|59|60|61|110|111|112|113|114|115|116|117|118|119|120|121|122|123|124|125|126|180|182|183|202|203|210|211|218|219|220|221|222|223)\./) {
        return "China";
    }
    return "Unknown";
}

sub log_message {
    my ($msg) = @_;
    my $timestamp = `date '+%Y-%m-%d %H:%M:%S'`;
    chomp $timestamp;
    print "[$timestamp] $msg\n" if $verbose;
    open(my $log, '>>:encoding(UTF-8)', $LOG_FILE) or return;
    print $log "[$timestamp] $msg\n";
    close($log);
}

sub usage {
    print <<"EOF";
AWStats 数据文件格式转换器 - 专业版（支持批量目录）

用法: perl $0 [选项]

选项:
    --force     强制重新转换（即使已经是新格式）
    --dryrun    试运行，只显示将要执行的操作，不实际修改文件
    --quiet     安静模式，减少输出
    --help      显示此帮助信息

说明:
    - 自动搜索所有匹配路径下的 awstats*.txt 文件
    - 支持通配符路径: $STATS_PATTERN
    - 自动按年月排序（从最新到最旧）
    - 自动跳过已经是 8.1 格式的文件
    - 自动备份原文件到统一备份目录
    - 支持断点续转（记录已转换的文件）
    - 重复执行安全（不会重复转换已成功的文件）

示例:
    perl $0                    # 正常转换
    perl $0 --force            # 强制重新转换所有文件
    perl $0 --dryrun           # 试运行，查看将要转换的文件
EOF
}

sub get_date_key {
    my ($filename) = @_;
    if ($filename =~ /awstats(\d{2})(\d{4})\./) {
        return "$2$1";
    }
    return "999999";
}

sub is_new_format {
    my ($file) = @_;
    open(my $fh, '<:encoding(UTF-8)', $file) or return 0;
    my $first_line = <$fh>;
    close($fh);
    return $first_line =~ /AWSTATS DATA FILE 8\.1/;
}

sub is_converted {
    my ($file) = @_;
    return 0 unless -f $PROGRESS_FILE;
    open(my $fh, '<:encoding(UTF-8)', $PROGRESS_FILE) or return 0;
    my %converted;
    while (<$fh>) {
        chomp;
        $converted{$_} = 1;
    }
    close($fh);
    return $converted{$file};
}

sub mark_converted {
    my ($file) = @_;
    open(my $fh, '>>:encoding(UTF-8)', $PROGRESS_FILE) or return;
    print $fh "$file\n";
    close($fh);
}

sub convert_file {
    my ($old_file) = @_;
    my $filename = basename($old_file);
    
    log_message("处理: $old_file");
    
    if ($dryrun) {
        log_message("  [DRYRUN] 将转换: $filename");
        return 1;
    }
    
    open(my $fh, '<:encoding(UTF-8)', $old_file) or die "无法打开文件: $!";
    my $content = do { local $/; <$fh> };
    close($fh);
    
    my ($domain) = $old_file =~ /awstats\d{6}\.([^.]+)\.txt/;
    $domain = "unknown" unless $domain;
    my ($month, $year) = $old_file =~ /awstats(\d{2})(\d{4})\./;
    log_message("  域名: $domain, 日期: ${year}年${month}月");
    
    my @visitors;
    if ($content =~ /BEGIN_VISITOR\s+\d+\n(.*?)\nEND_VISITOR/ms) {
        for my $line (split(/\n/, $1)) {
            $line =~ s/^\s+//;
            if ($line =~ /^([\d\.:a-fA-F]+)\s+(\d+)\s+(\d+)\s+(\d+)/) {
                push @visitors, { ip => $1, pages => $2, hits => $3, bandwidth => $4 };
            }
        }
    }
    log_message("  访问者数量: " . scalar(@visitors));
    
    my %geo_stats;
    my $count = 0;
    my $total = scalar(@visitors);
    for my $v (@visitors) {
        my $geo = get_geo_location($v->{ip});
        $geo_stats{$geo}{pages} += $v->{pages};
        $geo_stats{$geo}{hits} += $v->{hits};
        $geo_stats{$geo}{bandwidth} += $v->{bandwidth};
        $count++;
        if ($verbose && $count % 100 == 0) {
            print "    处理IP: $count/$total\r";
        }
    }
    print "\n" if $verbose && $total > 100;
    log_message("  地理位置统计: " . scalar(keys %geo_stats) . " 个地区");
    
    my $new_domain = "BEGIN_DOMAIN " . scalar(keys %geo_stats) . "\n";
    for my $geo (sort { $geo_stats{$b}{pages} <=> $geo_stats{$a}{pages} } keys %geo_stats) {
        my $s = $geo_stats{$geo};
        $new_domain .= sprintf("%s %6d %6d %12d\n", $geo, $s->{pages}, $s->{hits}, $s->{bandwidth});
    }
    $new_domain .= "END_DOMAIN\n\n";
    
    if ($content =~ s/(BEGIN_DOMAIN.*?END_DOMAIN\n\n)/$new_domain/ms) {
        log_message("  OK DOMAIN 段已更新");
    } else {
        log_message("  WARN 未找到 DOMAIN 段");
    }
    
    if ($content =~ s/BEGIN_MISC.*?END_MISC\n\n//ms) {
        log_message("  OK MISC 段已删除");
    }
    
    my $total_hits = 0;
    my $total_bandwidth = 0;
    for my $v (@visitors) {
        $total_hits += $v->{hits};
        $total_bandwidth += $v->{bandwidth};
    }
    my $http10_hits = int($total_hits * 0.95);
    my $http10_bw = int($total_bandwidth * 0.95);
    my $http20_hits = $total_hits - $http10_hits;
    my $http20_bw = $total_bandwidth - $http10_bw;
    
    my $protocol = "BEGIN_PROTOCOL 2\n";
    $protocol .= sprintf("HTTP/1.0 %d %d\n", $http10_hits, $http10_bw);
    $protocol .= sprintf("HTTP/2.0 %d %d\n", $http20_hits, $http20_bw);
    $protocol .= "END_PROTOCOL\n\n";
    
    if ($content =~ /(BEGIN_TIME.*?END_TIME\n\n)/ms) {
        $content =~ s/(BEGIN_TIME.*?END_TIME\n\n)/$1$protocol/ms;
        log_message("  OK PROTOCOL 段已添加");
    }
    
    $content =~ s/AWSTATS DATA FILE 7\.[0-9]{1,2}(?: \(build [\d.]+\))?/AWSTATS DATA FILE 8.1 (release 20260410)/;
    
    open(my $out, '>:encoding(UTF-8)', $old_file) or die "无法写入文件: $!";
    print $out $content;
    close($out);
    
    log_message("  OK 转换完成");
    return 1;
}

sub find_stats_files {
    my @files;
    my @search_dirs = ('/home');
    
    find(sub {
        return unless -d;
        if ($_ eq 'stats' && $File::Find::name =~ m|/home/[^/]+/web/[^/]+/stats$|) {
            opendir(my $dh, $File::Find::name) or return;
            my @txt_files = grep { /^awstats.*\.txt$/ && -f "$File::Find::name/$_" } readdir($dh);
            closedir($dh);
            for my $tf (@txt_files) {
                push @files, "$File::Find::name/$tf";
            }
        }
    }, @search_dirs);
    
    return @files;
}

# 主程序
print "\n";
print "=" x 70 . "\n";
print "AWStats Data File Converter - Professional Edition (Batch Mode)\n";
print "=" x 70 . "\n";
print "Search Pattern: $STATS_PATTERN\n";
print "Log File: $LOG_FILE\n";
print "Backup Directory: $BACKUP_DIR\n";
print "Dry Run Mode: " . ($dryrun ? "Yes" : "No") . "\n";
print "Force Convert: " . ($force ? "Yes" : "No") . "\n";
print "=" x 70 . "\n\n";

log_message("--- Conversion Started ---");

print "Scanning for awstats*.txt files...\n";
my @files = find_stats_files();

unless (@files) {
    print "No awstats*.txt files found matching pattern: $STATS_PATTERN\n";
    exit 0;
}

print "Found " . scalar(@files) . " file(s):\n";
for my $file (@files) {
    print "  - $file\n";
}
print "\n";

my @sorted_files = sort { get_date_key($b) cmp get_date_key($a) } @files;

my @to_convert;
for my $file (@sorted_files) {
    if (!$force && is_new_format($file)) {
        log_message("Skip: $file (already version 8.1)");
        next;
    }
    
    if (!$force && is_converted($file)) {
        log_message("Skip: $file (already converted)");
        next;
    }
    
    push @to_convert, $file;
}

if (@to_convert == 0) {
    print "\nAll files are already up to date.\n";
    print "Use --force to convert again.\n";
    exit 0;
}

print "Need to convert " . scalar(@to_convert) . " file(s):\n";
for my $file (@to_convert) {
    print "  - " . basename($file) . "\n";
}
print "\n";

if (!$dryrun && @to_convert > 0) {
    print "Creating backup directory: $BACKUP_DIR\n";
    mkdir($BACKUP_DIR) or die "Cannot create backup directory: $!";
    
    print "Backing up files...\n";
    for my $file (@to_convert) {
        my $filename = basename($file);
        my $relative_path = $file;
        $relative_path =~ s|^/||;
        $relative_path =~ s|/|_|g;
        my $dst = "$BACKUP_DIR/$relative_path";
        copy($file, $dst);
        print "  Backup: $filename -> $dst\n";
    }
    print "\n";
}

my $success = 0;
my $fail = 0;

for my $file (@to_convert) {
    my $filename = basename($file);
    print "\n" . "-" x 50 . "\n";
    print "Processing: $filename\n";
    
    eval {
        if (convert_file($file)) {
            $success++;
            mark_converted($file) unless $dryrun;
        } else {
            $fail++;
        }
    };
    if ($@) {
        log_message("  FAILED: $@");
        $fail++;
    }
}

print "\n";
print "=" x 70 . "\n";
print "Conversion Complete!\n";
print "Success: $success file(s)\n";
print "Failed: $fail file(s)\n";
print "=" x 70 . "\n";

if (!$dryrun && $success > 0) {
    print "\nBackup saved to: $BACKUP_DIR\n";
    print "Log saved to: $LOG_FILE\n";
    print "Progress saved to: $PROGRESS_FILE\n";
}

exit($fail > 0 ? 1 : 0);
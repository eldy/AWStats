#!/usr/bin/perl
#----------------------------------------------------------------------------
# \file         make/makepack-awstats_webmin.pl
# \brief        Dedicated package builder for Webmin module (.wbm, .tgz, .zip)
#----------------------------------------------------------------------------

use strict;
use warnings;
use v5.20;
use Cwd qw(abs_path);
use File::Temp;
use File::Path qw(remove_tree make_path);
use File::Copy;
use File::Basename;
use File::Find;
use Getopt::Long;

# 初始化配置
my $PROJECT = "awstats";
my ($MAJOR, $MINOR) = ("2", "0");
my $SOURCE_DIR;
my $DEST_DIR;
my @TARGETS = ();

# Webmin 模块和标准归档所必须的系统工具依赖
my %REQUIREMENTS = (
    "WBM" => "tar",
    "TGZ" => "tar",
    "ZIP" => "zip"
);

# 获取版本信息
sub get_version {
    my $source_dir = shift;
    my $info_file = "$source_dir/$PROJECT/module.info";
    
    if (open my $fh, '<', $info_file) {
        while (<$fh>) {
            if (/version=(.+)/) {
                close $fh;
                my $v = $1; $v =~ s/\s+//g;
                return split(/\./, $v, 2);
            }
        }
        close $fh;
    }
    return ("2", "0");
}

# 检查依赖工具
sub check_requirements {
    my ($target) = @_;
    my $req = $REQUIREMENTS{$target};
    
    print "Checking requirement for $target: $req... ";
    
    my $check_cmd = ($^O =~ /win32|cygwin|msys/i) 
        ? "where $req.exe >nul 2>&1" 
        : "command -v $req > /dev/null 2>&1";
        
    if (system($check_cmd) == 0) {
        print "OK\n"; return 1;
    } else {
        print "FAILED (Tool missing)\n"; return 0;
    }
}

# 准备构建环境
sub prepare_buildroot {
    my ($source, $build) = @_;
    
    print "Creating build directory: $build\n";
    make_path($build);
    
    print "Copying source from $source to $build/$PROJECT\n";
    system("cp -R '$source/$PROJECT' '$build/'") == 0 or die "Failed to copy source modules";
    
    print "Cleaning temporary files and metadata via File::Find...\n";
    find(sub {
        my $name = $_;
        if (-d $File::Find::name && ($name eq 'CVS' || $name eq '.svn' || $name eq '.git' || $name eq '.hg')) {
            remove_tree($File::Find::name);
            $File::Find::prune = 1; 
        }
        elsif (-f $File::Find::name) {
            if ($name eq 'Thumbs.db' || $name =~ /\.(wbm|tar|bak|old)$/ || $name =~ /~$/) {
                unlink($File::Find::name);
            }
        }
    }, $build);
}

# 构建 WBM 包
sub build_wbm {
    my ($build_dir, $version, $dest) = @_;
    my $pkg_name = "$PROJECT-webmin-$version.wbm";
    my $pkg_path = "$dest/$pkg_name";
    
    print "\nBuilding WBM package: $pkg_name\n";
    system("tar -C '$build_dir' -cf '$pkg_path' $PROJECT") == 0 or die "Failed to create WBM package";
    print "WBM package successfully created: $pkg_path\n";
}

# 主构建函数
sub build_packages {
    my ($source, $dest, @targets) = @_;
    
    my $build_root = File::Temp->newdir("awstats-webmin-XXXXXX", TMPDIR => 1, CLEANUP => 1) 
        or die "Failed to create temp block: $!";
    my $staging_path = $build_root->dirname;
    
    prepare_buildroot($source, $staging_path);
    
    foreach my $target (@targets) {
        $target = uc($target);
        next unless check_requirements($target);
        
        if ($target eq 'WBM') {
            build_wbm($staging_path, "$MAJOR.$MINOR", $dest);
        }
        elsif ($target eq 'TGZ') {
            my $pkg_path = "$dest/$PROJECT-webmin-" . "$MAJOR.$MINOR.wbm.gz";
            print "\nBuilding compressed WBM.GZ package...\n";
            system("tar -C '$staging_path' -czf '$pkg_path' $PROJECT") == 0 or die "Failed to create TGZ module";
            print "Compressed package successfully created: $pkg_path\n";
        }
        elsif ($target eq 'ZIP') {
            my $pkg_path = "$dest/$PROJECT-webmin-" . "$MAJOR.$MINOR.zip";
            print "\nBuilding ZIP module package...\n";
            use Cwd qw(getcwd);
            my $orig_cwd = getcwd();
            chdir($staging_path);
            system("zip -r '$pkg_path' $PROJECT > /dev/null") == 0 or die "Failed to create ZIP module";
            chdir($orig_cwd);
            print "ZIP package successfully created: $pkg_path\n";
        }
    }
    print "\nBuild completed successfully!\n";
}

sub main {
    my ($help, $targets, $source, $dest) = (0, '', '', '');
    GetOptions(
        'help|?'     => \$help,
        'target=s'   => \$targets,
        'source=s'   => \$source,
        'dest=s'     => \$dest,
    ) or die "Invalid options";
    
    if ($help) {
        print "Usage: $0 [--target=WBM,TGZ,ZIP] [--source=DIR] [--dest=DIR]\n";
        exit 0;
    }
    
    my $script_dir = dirname(abs_path($0));
    $SOURCE_DIR = $source || "$script_dir/../../awstats/tools/webmin";
    $DEST_DIR   = $dest   || "$script_dir";
    
    # 自动多级探测相对路径
    $SOURCE_DIR = "$script_dir/../tools/webmin" unless -d $SOURCE_DIR;
    $SOURCE_DIR = "$script_dir/tools/webmin" unless -d $SOURCE_DIR;
    
    unless (-d "$SOURCE_DIR/$PROJECT") {
        die "Fatal: Webmin module source folder not found at: $SOURCE_DIR/$PROJECT";
    }
    
    ($MAJOR, $MINOR) = get_version($SOURCE_DIR);
    print "Initializing Dedicated Webmin Packager (Version: $MAJOR.$MINOR)\n";
    
    @TARGETS = $targets ? split(/[,\s]+/, uc($targets)) : ('WBM');
    make_path($DEST_DIR) unless -d $DEST_DIR;
    build_packages($SOURCE_DIR, $DEST_DIR, @TARGETS);
}

main();
exit 0;
#!/usr/bin/perl
#----------------------------------------------------------------------------
# \file         make/makepack-awstats.pl
# \brief        Package builder (tgz, zip, pkg, rpm, deb, exe) with Git automation
# \author       (c)2004-2026 Laurent Destailleur  <eldy@users.sourceforge.net>
#----------------------------------------------------------------------------

use strict;
use warnings;
use v5.20;
$| = 1;
use Cwd;
use experimental qw(declared_refs);
use File::Path qw(remove_tree make_path);
use File::Copy;
use File::Basename;
use Getopt::Long;
use POSIX qw(strftime);
use Digest::SHA qw(sha256_hex);
use Cwd qw(abs_path);
use File::Spec;
use File::Find;

# 检测运行环境
my $IS_GITHUB_ACTIONS = $ENV{GITHUB_ACTIONS} ? 1 : 0;
my $IS_WINDOWS = ($^O =~ /win32/i) ? 1 : 0;

print "运行环境: " . ($IS_GITHUB_ACTIONS ? "GitHub Actions" : "本地") . "\n";
print "操作系统: " . ($IS_WINDOWS ? "Windows" : "Unix-like") . "\n";

# 项目配置
my $PROJECT = "awstats";
my $RPMSUBVERSION = "1";
my $PKGSUBVERSION = "1";
my $WBMVERSION = "2.0";
my @TARGETS = ("TGZ", "ZIP", "PKG", "RPM", "DEB");
my $GITHUB_REPO = "hestiacn/vstats";

# 工具依赖
my %REQUIREMENTS = (
    "TGZ" => "tar",
    "ZIP" => "7z",
    "PKG" => "pkg",
    "RPM" => "rpmbuild",
    "DEB" => "dpkg-buildpackage",
    "EXE" => "makensis"
);

# 版本信息
my ($MAJOR, $MINOR, $BUILD);
my ($REVISION, $VERSION) = ('', '');

# 路径配置
my ($DIR, $PROG, $SOURCE, $DESTI, $TEMP, $BUILDROOT, $RPMDIR);
my $OS = '';
my $PROGPATH = '';

# 检测操作系统
sub detect_os {
    if ($^O eq "freebsd") { return 'freebsd'; }
    elsif ($^O =~ /linux/i || (-d "/etc" && -d "/var" && $^O !~ /cygwin/i)) { 
        return 'linux'; 
    }
    elsif (-d "/etc" && -d "/Users") { 
        return 'macosx'; 
    }
    elsif ($^O =~ /cygwin/i || $^O =~ /win32/i) { 
        return 'windows'; 
    }
    else {
        die "Unsupported OS: $^O";
    }
}

# 获取 Git 版本信息
sub get_git_version {
    my $source_dir = shift;
    my $olddir = getcwd();
    chdir($source_dir);
    
    my $tag = `git describe --tags --abbrev=0 2>/dev/null`;
    chomp($tag);
    my $commit = `git rev-parse --short HEAD 2>/dev/null`;
    chomp($commit);
    my $date = `git log -1 --format=%cd --date=short 2>/dev/null`;
    chomp($date);
    
    chdir($olddir);
    return ($tag, $commit, $date);
}

# 生成发布说明
sub generate_release_notes {
    my ($source_dir, $old_tag, $new_tag) = @_;
    
    my $olddir = getcwd();
    chdir($source_dir);
    
    my $log = `git log $old_tag..$new_tag --pretty=format:"* %s (%h)"`;
    chdir($olddir);
    
    my $date = strftime("%Y-%m-%d", localtime);
    
    return <<"NOTES";
## AWStats $MAJOR.$MINOR ($date)

### What's Changed
$log

### Downloads
- [Source Code (tar.gz)](https://github.com/$GITHUB_REPO/releases/download/v$MAJOR.$MINOR/$PROJECT-$MAJOR.$MINOR.tar.gz)
- [Source Code (zip)](https://github.com/$GITHUB_REPO/releases/download/v$MAJOR.$MINOR/$PROJECT-$MAJOR.$MINOR.zip)
- [RPM Package](https://github.com/$GITHUB_REPO/releases/download/v$MAJOR.$MINOR/$PROJECT-$MAJOR.$MINOR-$RPMSUBVERSION.noarch.rpm)
- [DEB Package](https://github.com/$GITHUB_REPO/releases/download/v$MAJOR.$MINOR/${PROJECT}_$MAJOR.$MINOR-${RPMSUBVERSION}_all.deb)
- [FreeBSD Package](https://github.com/$GITHUB_REPO/releases/download/v$MAJOR.$MINOR/$PROJECT-$MAJOR.$MINOR-$PKGSUBVERSION.pkg)

### Installation
See [INSTALL.md](https://github.com/$GITHUB_REPO/blob/main/docs/INSTALL.md) for details.

### Full Changelog
https://github.com/$GITHUB_REPO/compare/$old_tag...$new_tag
NOTES
}

# 使用 gh CLI 发布
sub publish_with_gh_cli {
    my ($version, $notes, @files) = @_;
    
    if (system("gh --version > /dev/null 2>&1") != 0) {
        print "⚠ GitHub CLI (gh) not installed\n";
        print "Install from: https://cli.github.com/\n";
        return 0;
    }
    
    if (system("gh auth status > /dev/null 2>&1") != 0) {
        print "⚠ Not logged into GitHub\n";
        print "Run: gh auth login\n";
        return 0;
    }
    
    my $user = `gh api user -q .login`;
    chomp $user;
    print "✓ Logged in as: $user\n";
    
    my $tag = "v$version";
    if (system("git rev-parse $tag > /dev/null 2>&1") != 0) {
        print "Creating tag $tag...\n";
        system("git tag -a $tag -m 'Release $version'");
        system("git push origin $tag");
    }
    
    my $notes_file = "$TEMP/release_notes_$$.md";
    open my $fh, '>', $notes_file or die "Cannot create $notes_file: $!";
    print $fh $notes;
    close $fh;
    
    print "Creating GitHub release $tag...\n";
    my $cmd = "gh release create $tag --title 'AWStats $version' --notes-file '$notes_file'";
    foreach my $file (@files) {
        if (-f $file) {
            $cmd .= " '$file'";
        }
    }
    system($cmd);
    
    unlink $notes_file;
    print "✓ Published to GitHub: https://github.com/$GITHUB_REPO/releases/tag/$tag\n";
    return 1;
}

# 生成 SHA256 校验和
sub generate_checksums {
    my @files = @_;
    
    my $checksum_file = "$DESTI/SHA256SUMS.txt";
    open my $fh, '>', $checksum_file or die "Cannot create $checksum_file: $!";
    
    foreach my $file (@files) {
        if (-f $file) {
            open my $in, '<', $file or next;
            binmode $in;
            my $ctx = Digest::SHA->new(256);
            $ctx->addfile($in);
            close $in;
            
            my $hash = $ctx->hexdigest;
            my $basename = basename($file);
            print $fh "$hash  $basename\n";
        }
    }
    
    close $fh;
    print "✓ Checksums generated: $checksum_file\n";
    return $checksum_file;
}

# 初始化
sub init {
    ($DIR = $0) =~ s/([^\/\\]+)$//;
    ($PROG = $1) =~ s/\.([^\.]*)$//;
    $DIR ||= '.';
    $DIR =~ s/([^\/\\])[\\\/]+$/$1/;
    
    # 获取脚本的绝对路径
    my $script_dir = abs_path($DIR);
    print "脚本目录: $script_dir\n";
    
    # 项目根目录（脚本在 make 目录下）
    my $project_root;
    if ($IS_WINDOWS) {
        # Windows 路径处理
        $project_root = File::Spec->catdir($script_dir, '..');
        $project_root = abs_path($project_root);
    } else {
        $project_root = "$script_dir/..";
    }
    
    print "项目根目录: $project_root\n";
    
    # 查找 awstats.pl 的可能位置
    my @possible_paths = (
        File::Spec->catfile($project_root, 'wwwroot', 'cgi-bin', 'awstats.pl'),
        File::Spec->catfile($project_root, 'awstats', 'wwwroot', 'cgi-bin', 'awstats.pl'),
        File::Spec->catfile($script_dir, '..', 'wwwroot', 'cgi-bin', 'awstats.pl'),
        File::Spec->catfile($script_dir, '..', '..', 'awstats', 'wwwroot', 'cgi-bin', 'awstats.pl'),
    );
    
    $SOURCE = '';
    foreach my $test_path (@possible_paths) {
        print "检查: $test_path\n";
        if (-f $test_path) {
            print "找到 awstats.pl: $test_path\n";
            # 获取源码目录（向上三级到项目根）
            $SOURCE = File::Spec->catdir($test_path, '..', '..', '..');
            $SOURCE = abs_path($SOURCE);
            last;
        }
    }
    
    unless ($SOURCE) {
        # 默认使用项目根目录
        $SOURCE = $project_root;
        print "使用默认源码目录: $SOURCE\n";
        
        # 检查文件是否存在
        my $test_file = File::Spec->catfile($SOURCE, 'wwwroot', 'cgi-bin', 'awstats.pl');
        unless (-f $test_file) {
            die "Cannot find awstats.pl. Please ensure file exists at: $test_file";
        }
    }
    
    $DESTI = File::Spec->catdir($SOURCE, 'make');
    
    # 检测操作系统
    $OS = detect_os();
    
    # 设置临时目录（Windows 特殊处理）
    if ($OS eq 'windows') {
        $TEMP = $ENV{TEMP} || $ENV{TMP} || 'C:\temp';
        $PROGPATH = $ENV{ProgramFiles} || 'C:\Program Files';
        
        # 处理 HOME 环境变量（Windows 可能没有）
        unless ($ENV{HOME}) {
            $ENV{HOME} = $ENV{USERPROFILE} || 'C:\Users\runneradmin';
        }
    } elsif ($OS eq 'linux' || $OS eq 'macosx' || $OS eq 'freebsd') {
        $TEMP = $ENV{TEMP} || $ENV{TMP} || '/tmp';
    }
    
    die "No temporary directory found" unless ($TEMP && -d $TEMP);
    
    $BUILDROOT = File::Spec->catdir($TEMP, "${PROJECT}-buildroot");
    
    # 设置 RPM 目录（Windows 忽略）
    unless ($OS eq 'windows') {
        if (-d "/usr/src/redhat") { $RPMDIR = "/usr/src/redhat"; }
        elsif (-d "/usr/src/RPM") { $RPMDIR = "/usr/src/RPM"; }
        elsif (-d "/home/ldestailleur/rpmbuild") { $RPMDIR = "/home/ldestailleur/rpmbuild"; }
        elsif ($ENV{HOME}) { $RPMDIR = "$ENV{HOME}/rpmbuild"; }
    }
    
    # 从 awstats.pl 读取版本
    my $version_file = File::Spec->catfile($SOURCE, 'wwwroot', 'cgi-bin', 'awstats.pl');
    print "读取版本文件: $version_file\n";
    
    if (open my $fh, '<', $version_file) {
        while (<$fh>) {
            if (/VERSION\s*=\s*"([\d\.a-z\-]+)/) {
                my $fullver = $1;
                ($MAJOR, $MINOR, $BUILD) = split(/\./, $fullver, 3);
                last;
            }
        }
        close $fh;
    } else {
        die "Cannot open version file: $version_file";
    }
    
    die "Cannot detect version from $version_file" unless $MAJOR;
    
    print "=" x 60, "\n";
    print "AWStats Packager\n";
    print "=" x 60, "\n";
    print "Version: $MAJOR.$MINOR\n";
    print "Source: $SOURCE\n";
    print "Output: $DESTI\n";
    print "OS: $OS\n";
    print "=" x 60, "\n\n";
}

# 准备构建目录
sub prepare_buildroot {
    my $skip_copy = shift || 0;
    
    if ($skip_copy) {
        print "Skipping buildroot preparation (using source directly for TGZ/ZIP)\n";
        $BUILDROOT = $SOURCE;
        return;
    }
    
    print "Preparing build directory for PKG/RPM/DEB/EXE...\n";
    
    remove_tree($BUILDROOT) if -d $BUILDROOT;
    make_path($BUILDROOT);
    
    my $target_dir = "$BUILDROOT/$PROJECT-$MAJOR.$MINOR";
    make_path($target_dir);
    
    # 复制所有需要的顶层目录（保持原有结构）
    my @top_dirs = qw(docs tools wwwroot);
    foreach my $item (@top_dirs) {
        my $src = File::Spec->catfile($SOURCE, $item);
        if (-e $src) {
            print "Copying $item/ ...\n";
            system("cp -pr '$src' '$target_dir/'");
        } else {
            print "Warning: $src not found\n";
        }
    }
    
    # 复制 README 文件
    foreach my $readme (qw(README.md README-zh_CN.md README-zh_TW.md)) {
        my $src = File::Spec->catfile($SOURCE, $readme);
        if (-f $src) {
            print "Copying $readme...\n";
            copy($src, "$target_dir/$readme") or warn "Failed to copy $readme: $!";
        }
    }
    
    # 复制配置文件（它们应该在 wwwroot/cgi-bin/ 下）
    my @config_files = qw(awstats.conf awstats.model.conf);
    foreach my $conf (@config_files) {
        my $src = File::Spec->catfile($SOURCE, 'wwwroot', 'cgi-bin', $conf);
        my $dst = "$target_dir/wwwroot/cgi-bin/$conf";
        if (-f $src) {
            print "Copying $conf...\n";
            copy($src, $dst) or warn "Failed to copy $conf: $!";
        } else {
            print "Warning: $conf not found at $src\n";
        }
    }
    
    # 清理不需要的文件
    cleanup_buildroot($BUILDROOT, "$MAJOR.$MINOR");
    
    print "Build directory ready: $target_dir\n\n";
}

# 完整清理函数
sub cleanup_buildroot {
    my ($build_dir, $version) = @_;
    
    my $target_dir = "$build_dir/$PROJECT-$version";
    print "Cleaning files in $target_dir...\n";
    
    # 删除版本控制文件和备份
    my @patterns = (
        '.git', '.svn', 'CVS',
        '.github', '.settings',
        '*.bak', '*~', '*.old',
        '.cvsignore', '.gitignore',
        '.project', '.gitattributes',
        'Thumbs.db', '.DS_Store'
    );
    
    foreach my $pattern (@patterns) {
        system("find '$target_dir' -name '$pattern' -exec rm -rf {} \\; 2>/dev/null");
    }
    
    # 删除特定文件
    my @specific_files = (
        "$target_dir/git2cvs.sh",
        "$target_dir/wwwroot/cgi-bin/.cvsignore",
        "$target_dir/wwwroot/classes/src/.cvsignore",
        "$target_dir/docs/images/.cvsignore",
        "$target_dir/tools/webmin/.cvsignore",
        "$target_dir/tools/webmin/awstats/images/.cvsignore",
    );
    
    foreach my $file (@specific_files) {
        unlink $file if -f $file;
    }
    
    # 删除不需要的目录
    my @remove_dirs = (
        "$target_dir/make",
        "$target_dir/test",
    );
    
    foreach my $dir (@remove_dirs) {
        system("rm -rf '$dir' 2>/dev/null");
    }
    
    print "Cleanup completed\n";
}

# 检查依赖工具
sub check_requirements {
    my $target = shift;
    my $req = $REQUIREMENTS{$target};
    
    print "Checking requirement for $target: $req... ";
    
    if ($OS eq 'windows') {
        $req .= ".exe" if $req !~ /\.exe$/;
        my $found = 0;
        foreach my $path (split(/;/, $ENV{PATH})) {
            if (-f "$path\\$req") {
                $found = 1;
                last;
            }
        }
        if ($found) {
            print "OK (found in PATH)\n";
            return 1;
        } else {
            print "FAILED (not found in PATH)\n";
            return 0;
        }
    } else {
        my $ret = system("$req --version > /dev/null 2>&1");
        if ($ret == 0) {
            print "OK\n";
            return 1;
        } else {
            print "FAILED\n";
            return 0;
        }
    }
}

# 构建 TGZ 包
sub build_tgz {
    my $version = "$MAJOR.$MINOR";
    my $filename = "$PROJECT-$version";
    my $output_file = "$DESTI/$filename.tar.gz";
    
    print "\nBuilding TGZ package: $filename\n";
    
    my $nested_dir = "$SOURCE/$filename";
    if (-d $nested_dir) {
        print "Removing nested directory: $nested_dir\n";
        system("rm -rf '$nested_dir'");
    }
    
    chdir($SOURCE);
    
    my $cmd = "tar --exclude='.git' --exclude='.github' --exclude='.settings' "
            . "--exclude='make' --exclude='test' --exclude='*.bak' --exclude='*~' "
            . "--exclude='*.old' --exclude='.gitignore' --exclude='.gitattributes' "
            . "--exclude='.project' --exclude='.cvsignore' --exclude='git2cvs.sh' "
            . "-czf '$output_file' --transform='s/^/$filename\\//' . 2>&1";
    
    print "Running: $cmd\n";
    system($cmd);
    
    if (-f $output_file && -s $output_file > 0) {
        print "✅ TGZ package created\n";
        return $output_file;
    }
    return undef;
}

# 构建 ZIP 包
sub build_zip {
    my $version = "$MAJOR.$MINOR";
    my $filename = "$PROJECT-$version";
    my $output_file = "$DESTI/$filename.zip";
    
    print "\nBuilding ZIP package: $filename\n";
    
    my $which_7z = `which 7z 2>&1`;
    if ($which_7z =~ /not found/i) {
        print "⚠️ 7z command not found, skipping ZIP build\n";
        return undef;
    }
    
    my $nested_dir = "$SOURCE/$filename";
    if (-d $nested_dir) {
        print "Removing nested directory: $nested_dir\n";
        system("rm -rf '$nested_dir'");
    }
    
    chdir($SOURCE);
    
    my $cmd = "7z a -r -tzip -mx9 '$output_file' "
            . "-xr!.git -xr!.github -xr!.settings "
            . "-xr!make -xr!test "
            . "-xr!*.bak -xr!*~ -xr!*.old "
            . "-xr!.gitignore -xr!.gitattributes "
            . "-xr!.project -xr!.cvsignore -xr!git2cvs.sh "
            . ". 2>&1";
    
    print "Running: $cmd\n";
    system($cmd);
    
    if (-f $output_file) {
        print "✅ ZIP package created\n";
        return $output_file;
    }
    return undef;
}

# 构建 RPM 包
sub build_rpm {
    my $version = "$MAJOR.$MINOR";
    my $filename = "$PROJECT-$version";
    my $output = "$DESTI/$PROJECT-$version-$RPMSUBVERSION.noarch.rpm";
    
    print "\nBuilding RPM package: $filename\n";
    
    # 调试信息
    print "  Current directory: " . Cwd::getcwd() . "\n";
    print "  BUILDROOT: $BUILDROOT\n";
    print "  RPMDIR: $RPMDIR\n";
    
    # 确保 SOURCES 目录存在
    make_path("$RPMDIR/SOURCES");
    
    # 创建源码包（直接到 SOURCES 目录）
    my $tgz_file = "$RPMDIR/SOURCES/$PROJECT-$version.tgz";
    unlink $tgz_file;
    
    my $exclude_file = "$SOURCE/make/tgz/tar.exclude";
    my $exclude_opt = -f $exclude_file ? "--exclude-from='$exclude_file'" : "";
    my $cmd = "tar $exclude_opt --directory='$BUILDROOT' -czvf '$tgz_file' $filename";
    
    print "  Creating source tarball: $cmd\n";
    system($cmd) == 0 or die "Failed to create source tarball";
    
    # 检查源码包
    if (-f $tgz_file) {
        my $size = -s $tgz_file;
        print "  ✅ Source tarball created: $tgz_file (" . int($size/1024) . " KB)\n";
    } else {
        die "❌ Source tarball not created";
    }
    
    # 查找 spec 文件
    my $spec_template = "rpm/$PROJECT.spec";
    print "  Looking for spec file at: $spec_template\n";
    
    if (-f $spec_template) {
        print "  ✅ Found spec file\n";

        # 读取并修改 spec 文件
        open my $spec_in, '<', $spec_template or die "Cannot open spec template: $spec_template";
        open my $spec_out, '>', "$TEMP/$PROJECT.spec" or die "Cannot create spec file";

        my $source_added = 0;
        while (<$spec_in>) {
            s/__VERSION__/$MAJOR.$MINOR/g;
            s/__RELEASE__/$RPMSUBVERSION/g;
            
            # 在 Name 后面添加 Source0，但只加一次
            if (/^Name:/ && !$source_added) {
                print $spec_out $_;
                print $spec_out "Source0: %{name}-%{version}.tgz\n";
                $source_added = 1;
                next;
            }
            
            # 跳过原有的 Source0 行（如果有）
            if (/^Source0:/) {
                # 如果已经添加过了，就跳过
                if ($source_added) {
                    next;
                } else {
                    # 否则保留原来的
                    print $spec_out $_;
                    $source_added = 1;
                }
                next;
            }
            
            # 确保 %prep 部分有正确的 %setup
            if (/^%prep/) {
                print $spec_out $_;
                print $spec_out "%setup -q -n %{name}-%{version}\n";
                # 跳过原有的 %setup 行
                while (<$spec_in>) {
                    last if !/^%setup/;
                }
                next;
            }
            print $spec_out $_;
        }
        close $spec_in;
        close $spec_out;
        
        # 显示生成的 spec 文件内容
        print "  Generated spec file preview:\n";
        system("head -20 '$TEMP/$PROJECT.spec'");
        
        # 运行 rpmbuild
        $cmd = "rpmbuild --clean -ba '$TEMP/$PROJECT.spec' 2>&1";
        print "  Running: $cmd\n";
        my $result = system($cmd);
        
        if ($result != 0) {
            warn "RPM build failed with code $result";
            print "  RPM build output:\n";
            system("tail -50 /tmp/rpmbuild.log 2>/dev/null || true");
            return undef;
        }
    } else {
        die "❌ RPM spec file not found at: $spec_template";
    }
    
    # 查找生成的 RPM 文件
    my $rpm_file = "$RPMDIR/RPMS/noarch/$PROJECT-$version-$RPMSUBVERSION.noarch.rpm";
    if (-f $rpm_file) {
        my $size = -s $rpm_file;
        print "  ✅ RPM package created: $rpm_file (" . int($size/1024) . " KB)\n";
        move($rpm_file, $output) or warn "Failed to move RPM file";
        return $output;
    } else {
        print "  ❌ RPM package not found at: $rpm_file\n";
        print "  Contents of $RPMDIR/RPMS/noarch/:\n";
        system("ls -la $RPMDIR/RPMS/noarch/ 2>/dev/null || echo 'directory not found'");
        return undef;
    }
}

# 构建 DEB 包
sub build_deb {
    my $version = "$MAJOR.$MINOR";
    my $filename = "$PROJECT-$version";
    my $output = "$DESTI/${PROJECT}_$version-${RPMSUBVERSION}_all.deb";
    
    print "\n🔨 Building DEB package: $filename\n";
    print "=" x 60, "\n";
    
    # 步骤1: 检查依赖工具
    print "📋 Step 1: Checking build dependencies...\n";
    my $dpkg_check = system("dpkg-buildpackage --version > /dev/null 2>&1");
    if ($dpkg_check != 0) {
        print "  ❌ dpkg-buildpackage not found. Please install dpkg-dev\n";
        print "  💡 Run: sudo apt-get install dpkg-dev debhelper\n";
        return undef;
    }
    print "  ✅ dpkg-buildpackage found\n";
    
    my $dh_check = system("which dh > /dev/null 2>&1");
    if ($dh_check != 0) {
        print "  ❌ debhelper not found. Please install debhelper\n";
        print "  💡 Run: sudo apt-get install debhelper\n";
        return undef;
    }
    print "  ✅ debhelper found\n";
    
    # 步骤2: 创建构建目录
    print "\n📋 Step 2: Creating build directories...\n";
    my $deb_buildroot = "$BUILDROOT/deb-build";
    my $deb_packageroot = "$deb_buildroot/$filename";
    
    remove_tree($deb_buildroot);
    make_path($deb_packageroot);
    print "  ✅ Build root: $deb_buildroot\n";
    print "  ✅ Package root: $deb_packageroot\n";
    
    # 步骤3: 复制源码
    print "\n📋 Step 3: Copying source files...\n";
    my $src_dir = "$BUILDROOT/$filename";
    if (! -d $src_dir) {
        print "  ❌ Source directory not found: $src_dir\n";
        return undef;
    }
    
    my $copy_cmd = "cp -pr '$src_dir'/* '$deb_packageroot/' 2>&1";
    my $copy_result = `$copy_cmd`;
    if ($? != 0) {
        print "  ❌ Failed to copy source: $copy_result\n";
        return undef;
    }
    print "  ✅ Source files copied\n";
    
    # 步骤4: 解析模板生成 debian 目录
    print "\n📋 Step 4: Generating debian packaging files from template...\n";
    my $spec_template = "$SOURCE/make/deb/awstats.spec";
    if (! -f $spec_template) {
        print "  ❌ DEB spec template not found: $spec_template\n";
        print "  Looking in: " . Cwd::getcwd() . "/make/deb/awstats.spec\n";
        return undef;
    }
    print "  ✅ Using template: $spec_template\n";
    
    # 解析模板并生成文件
    my $gen_result = parse_deb_template($spec_template, $deb_packageroot, $version, $RPMSUBVERSION);
    unless ($gen_result) {
        print "  ❌ Failed to generate debian files\n";
        return undef;
    }
    print "  ✅ Debian files generated\n";
    
    # 步骤5: 验证所有必需文件
    print "\n📋 Step 5: Verifying required files...\n";
    my @required = qw(control changelog compat copyright rules);
    my @optional = qw(postinst prerm preinst install watch);
    my $all_ok = 1;
    
    foreach my $file (@required) {
        if (-f "$deb_packageroot/debian/$file") {
            print "  ✅ $file\n";
        } else {
            print "  ❌ $file MISSING\n";
            $all_ok = 0;
        }
    }
    
    foreach my $file (@optional) {
        if (-f "$deb_packageroot/debian/$file") {
            print "  ✅ $file (optional)\n";
        }
    }
    
    unless ($all_ok) {
        print "  ❌ Required files missing, aborting\n";
        return undef;
    }
    
    # 步骤6: 构建 DEB 包
    print "\n📋 Step 6: Building DEB package...\n";
    print "  Running: dpkg-buildpackage -us -uc -b\n";
    
    chdir($deb_packageroot) or die "Cannot chdir to $deb_packageroot: $!";
    
    my $build_output = `dpkg-buildpackage -us -uc -b 2>&1`;
    my $build_status = $?;
    
    if ($build_status != 0) {
        print "  ❌ Build failed with status: $build_status\n";
        print "  Build output:\n";
        print "-" x 40, "\n";
        print $build_output;
        print "-" x 40, "\n";
        return undef;
    }
    print "  ✅ Build completed successfully\n";
    
    # 步骤7: 查找并移动 .deb 文件
    print "\n📋 Step 7: Locating generated .deb file...\n";
    opendir my $dh, $deb_buildroot or do {
        print "  ❌ Cannot open directory: $deb_buildroot\n";
        return undef;
    };
    
    my $found = 0;
    while (my $file = readdir $dh) {
        if ($file =~ /\.deb$/) {
            my $src = "$deb_buildroot/$file";
            my $size = -s $src;
            print "  ✅ Found: $src (" . int($size/1024) . " KB)\n";
            print "  Moving to: $output\n";
            move($src, $output) or warn "  ❌ Failed to move: $!";
            $found = 1;
            last;
        }
    }
    closedir $dh;
    
    unless ($found) {
        print "  ❌ No .deb file found in $deb_buildroot\n";
        print "  Directory contents:\n";
        system("ls -la $deb_buildroot");
        return undef;
    }
    
    # 步骤8: 验证输出文件
    if (-f $output) {
        my $size = -s $output;
        print "\n✅ DEB package created successfully\n";
        print "📦 $output (" . int($size/1024) . " KB)\n";
        return $output;
    } else {
        print "  ❌ Output file not found: $output\n";
        return undef;
    }
}

# 解析 DEB 模板文件
sub parse_deb_template {
    my ($template_file, $target_root, $version, $release) = @_;
    
    print "  Parsing template: $template_file\n";
    
    open my $fh, '<', $template_file or die "Cannot open template: $template_file";
    my $content = do { local $/; <$fh> };
    close $fh;
    
    # 替换变量
    my $maintainer = "Laurent Destailleur <eldy\@users.sourceforge.net>";
    my $date = strftime("%a, %d %b %Y %H:%M:%S %z", localtime);
    my $project = $PROJECT || "awstats";
    
    $content =~ s/__VERSION__/$version/g;
    $content =~ s/__RELEASE__/$release/g;
    $content =~ s/__MAINTAINER__/$maintainer/g;
    $content =~ s/__DATE__/$date/g;
    $content =~ s/__PROJECT__/$project/g;
    
    # 解析 [FILE:filename] 块
    my $debian_dir = "$target_root/debian";
    make_path($debian_dir);
    
    my $file_count = 0;
    while ($content =~ /\[FILE:([^\]]+)\]\n(.*?)\n\[FILE:\1\]/gs) {
        my ($filename, $file_content) = ($1, $2);
        my $filepath = "$debian_dir/$filename";
        
        # 确保父目录存在
        my $dir = dirname($filepath);
        make_path($dir) unless -d $dir;
        
        open my $out, '>', $filepath or die "Cannot create $filepath: $!";
        print $out $file_content;
        close $out;
        
        # 设置可执行权限
        if ($filename =~ /^(postinst|prerm|preinst|rules)$/) {
            chmod 0755, $filepath;
            print "    Generated: $filename (executable)\n";
        } else {
            print "    Generated: $filename\n";
        }
        $file_count++;
    }
    
    print "  Generated $file_count files in $debian_dir\n";
    return $file_count > 0;
}

# 构建 FreeBSD PKG 包
sub build_pkg {
    my $version = "$MAJOR.$MINOR";
    my $filename = "$PROJECT-$version";
    my $output = "$DESTI/$PROJECT-$version-$PKGSUBVERSION.pkg";
    
    print "\n🔨 Building FreeBSD package: $filename\n";
    print "=" x 60, "\n";
    
    # ==========================================================================
    # 步骤1: 检查是否在 FreeBSD 系统
    # ==========================================================================
    if ($OS ne 'freebsd') {
        print "  ⚠️ Not running on FreeBSD, skipping pkg build\n";
        print "  💡 FreeBSD packages must be built on FreeBSD system\n";
        return undef;
    }
    print "  ✅ Running on FreeBSD\n";
    
    # ==========================================================================
    # 步骤2: 创建 staging 目录
    # ==========================================================================
    print "\n📋 Step 2: Creating staging directory...\n";
    my $pkg_root = "$BUILDROOT/pkg-stage";
    remove_tree($pkg_root) if -d $pkg_root;
    make_path($pkg_root);
    
    my $src_dir = "$BUILDROOT/$filename";
    if (!-d $src_dir) {
        print "  ❌ Source directory not found: $src_dir\n";
        return undef;
    }
    
    # ==========================================================================
    # 步骤3: 安装文件到 staging 目录 (Step 3: Installing files to staging directory)
    # ==========================================================================
    print "\n📋 Step 3: Installing files to staging directory...\n";

    # 创建干净的 FreeBSD FHS 标准物理目录树
    make_path("$pkg_root/usr/local/www/cgi-bin");
    make_path("$pkg_root/usr/local/share/awstats/classes");
    make_path("$pkg_root/usr/local/share/awstats/css");
    make_path("$pkg_root/usr/local/share/awstats/icon");
    make_path("$pkg_root/usr/local/share/awstats/js");
    make_path("$pkg_root/usr/local/share/awstats/lang");
    make_path("$pkg_root/usr/local/share/awstats/lib");
    make_path("$pkg_root/usr/local/share/awstats/plugins");
    make_path("$pkg_root/usr/local/share/awstats/tools");
    make_path("$pkg_root/usr/local/share/doc/awstats");
    make_path("$pkg_root/usr/local/etc/awstats");
    make_path("$pkg_root/usr/local/bin");
    make_path("$pkg_root/usr/local/etc/periodic/daily");
    make_path("$pkg_root/usr/local/etc/cron.d");
    make_path("$pkg_root/usr/local/lib/perl5/site_perl/Geo");

    # 复制 CGI 脚本到 www/cgi-bin（只复制 .pl 和可执行文件）
    print "  Copying CGI scripts...\n";
    system("cp -pr $src_dir/wwwroot/cgi-bin/awstats.pl $pkg_root/usr/local/www/cgi-bin/");
    system("cp -pr $src_dir/wwwroot/cgi-bin/awredir.pl $pkg_root/usr/local/www/cgi-bin/");
    system("cp -pr $src_dir/wwwroot/cgi-bin/awdownloadcsv.pl $pkg_root/usr/local/www/cgi-bin/");
    system("cp -pr $src_dir/wwwroot/cgi-bin/awstats-update $pkg_root/usr/local/www/cgi-bin/");
    die "Failed to copy CGI scripts" if $? != 0;

    # 复制静态资源到 share/awstats
    print "  Copying classes...\n";
    system("cp -pr $src_dir/wwwroot/classes/. $pkg_root/usr/local/share/awstats/classes/");
    die "Failed to copy classes" if $? != 0;

    print "  Copying css...\n";
    system("cp -pr $src_dir/wwwroot/css/. $pkg_root/usr/local/share/awstats/css/");
    die "Failed to copy css" if $? != 0;

    print "  Copying icon...\n";
    system("cp -pr $src_dir/wwwroot/icon/. $pkg_root/usr/local/share/awstats/icon/");
    die "Failed to copy icon" if $? != 0;

    print "  Copying js...\n";
    system("cp -pr $src_dir/wwwroot/js/. $pkg_root/usr/local/share/awstats/js/");
    die "Failed to copy js" if $? != 0;

    # 复制库文件到 share/awstats
    print "  Copying lang...\n";
    system("cp -pr $src_dir/wwwroot/cgi-bin/lang/. $pkg_root/usr/local/share/awstats/lang/");
    die "Failed to copy lang" if $? != 0;

    print "  Copying lib...\n";
    system("cp -pr $src_dir/wwwroot/cgi-bin/lib/. $pkg_root/usr/local/share/awstats/lib/");
    die "Failed to copy lib" if $? != 0;

    system("cp -pr $src_dir/wwwroot/cgi-bin/lib/IPfree.pm $pkg_root/usr/local/lib/perl5/site_perl/Geo/");
    system("cp -pr $src_dir/wwwroot/cgi-bin/lib/IPfree.pod $pkg_root/usr/local/lib/perl5/site_perl/Geo/");
    print "  Copying IPfree to Geo directory...\n";

    print "  Copying plugins...\n";
    system("cp -pr $src_dir/wwwroot/cgi-bin/plugins/. $pkg_root/usr/local/share/awstats/plugins/");
    die "Failed to copy plugins" if $? != 0;

    # 复制工具脚本
    print "  Copying tools...\n";
    system("cp -pr $src_dir/tools/. $pkg_root/usr/local/share/awstats/tools/");
    die "Failed to copy tools" if $? != 0;

    print "  Copying docs...\n";
    system("cp -pr $src_dir/docs/. $pkg_root/usr/local/share/doc/awstats/");
    die "Failed to copy docs" if $? != 0;

    # 复制说明文档
    foreach my $readme (qw(README.md README-*.md)) {
        if (-f "$src_dir/$readme") {
            copy("$src_dir/$readme", "$pkg_root/usr/local/share/doc/awstats/");
        }
    }

    # 初始默认配置文件对齐
    copy("$src_dir/wwwroot/cgi-bin/awstats.model.conf", "$pkg_root/usr/local/etc/awstats/awstats.model.conf");
    copy("$src_dir/wwwroot/cgi-bin/awstats.conf", "$pkg_root/usr/local/etc/awstats/awstats.conf");
    
    open my $fh, '>', "$pkg_root/usr/local/etc/awstats/awstats.local.conf";
    print $fh "# Local AWStats configuration\n";
    close $fh;

    # CLI 命令层面的可执行包装脚本
    open my $wf, '>', "$pkg_root/usr/local/bin/awstats";
    print $wf "#!/bin/sh\n";
    print $wf "exec /usr/local/bin/perl /usr/local/www/cgi-bin/awstats.pl \"\$@\"\n";
    close $wf;
    chmod 0755, "$pkg_root/usr/local/bin/awstats";

    # periodic 每日自动定时执行计划
    open my $pf, '>', "$pkg_root/usr/local/etc/periodic/daily/awstats";
    print $pf "#!/bin/sh\n";
    print $pf "# AWStats daily update\n";
    print $pf "/usr/local/bin/perl /usr/local/share/awstats/tools/awstats_updateall.pl now 2>/dev/null\n";
    close $pf;
    chmod 0755, "$pkg_root/usr/local/etc/periodic/daily/awstats";

    print "  ✅ Files installed\n";

    # --------------------------------------------------------------------------
    # 创建每月自动执行的 DB-IP 城市级地理数据库更新脚本
    # --------------------------------------------------------------------------
    print "\n📋 Creating DB-IP update script...\n";
    open my $dbip_fh, '>', "$pkg_root/usr/local/etc/cron.d/awstats-dbip-update";
    print $dbip_fh <<'EOF';
#!/bin/sh
# ------------------------------------------------------------------------------
# Generated by AWStats, do not edit manually
# 由 AWStats 自动生成，请勿手动编辑
# To disable automatic updates, rename this file so you can re-enable it later if needed.
# 若需禁用自动更新，请将此文件重命名！以便后续启用此功能！
# ------------------------------------------------------------------------------
YEAR_MONTH=$(date +%Y-%m)
DBIP_DIR="/usr/local/lib/perl5/site_perl/Geo"
DBIP_DEST="$DBIP_DIR/dbip-city.mmdb"
DBIP_TEMP="$DBIP_DIR/dbip-city.mmdb.tmp"
LOG_FILE="/var/log/dbip-update.log"

if [ -f "$LOG_FILE" ] && [ $(cat "$LOG_FILE" | wc -l) -gt 30 ]; then
    tail -n 30 "$LOG_FILE" > "$LOG_FILE.tmp"
    mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

mkdir -p "$DBIP_DIR"
cd "$DBIP_DIR"

if ! command -v fetch > /dev/null 2>&1; then
    echo "$(date): fetch not installed, skipping update" >> "$LOG_FILE"
    exit 1
fi

fetch -o "$DBIP_TEMP.gz" "https://download.db-ip.com/free/dbip-city-lite-${YEAR_MONTH}.mmdb.gz" 2>/dev/null
if [ ! -s "$DBIP_TEMP.gz" ]; then
    LAST_MONTH=$(date -v-1m +%Y-%m 2>/dev/null || date -d "1 month ago" +%Y-%m 2>/dev/null)
    if [ -n "$LAST_MONTH" ]; then
        echo "$(date): Current month ${YEAR_MONTH} not available, trying ${LAST_MONTH}" >> "$LOG_FILE"
        fetch -o "$DBIP_TEMP.gz" "https://download.db-ip.com/free/dbip-city-lite-${LAST_MONTH}.mmdb.gz" 2>/dev/null
        if [ -s "$DBIP_TEMP.gz" ]; then
            echo "$(date): Downloaded ${LAST_MONTH} instead" >> "$LOG_FILE"
        fi
    fi
fi
if [ -s "$DBIP_TEMP.gz" ]; then
    gunzip -f "$DBIP_TEMP.gz"
fi

if [ -s "$DBIP_TEMP" ]; then
    mv "$DBIP_TEMP" "$DBIP_DEST"
    chmod 644 "$DBIP_DEST"
    echo "$(date): Updated to ${YEAR_MONTH}" >> "$LOG_FILE"
else
    rm -f "$DBIP_TEMP" "$DBIP_TEMP.gz"
    echo "$(date): Update failed for ${YEAR_MONTH}" >> "$LOG_FILE"
fi
EOF
    close $dbip_fh;
    chmod 0755, "$pkg_root/usr/local/etc/cron.d/awstats-dbip-update";
    print "  ✅ Created DB-IP update script at /usr/local/etc/cron.d/awstats-dbip-update\n";
    print "  Verifying files...\n";
    my $file_count = 0;
    use File::Find;
    find(sub { 
        return if $_ eq '.' || $_ eq '..';
        $file_count++ if -f $File::Find::name && $File::Find::name !~ /\/\+/;
    }, $pkg_root);
    print "  Total files in staging (excluding metadata): $file_count\n";
        
    # ==========================================================================
    # 步骤4: 初始化并生成核心清单 +MANIFEST (物理隔离写入专属元数据目录)
    # ==========================================================================
    print "\n📋 Step 4: Generating package manifest...\n";
    
    my $meta_stage = "/tmp/awstats-buildroot/meta-stage";
    system("rm -rf '$meta_stage' && mkdir -p '$meta_stage'") == 0 or die "Cannot initialize meta-stage dir: $!";
    
    my $manifest_file = "$meta_stage/+MANIFEST";
    open my $mf, '>', $manifest_file or die "Cannot create $manifest_file: $!";

    use POSIX qw(strftime);
    my $build_timestamp = strftime("%Y-%m-%dT%H:%M:%SZ", gmtime);
    my $build_date      = strftime("%Y-%m-%d %H:%M:%S", localtime);

    my $pkg_version = $version;
    if ($PKGSUBVERSION && $PKGSUBVERSION > 0) {
        $pkg_version .= "_$PKGSUBVERSION";
    }

    my $arch = `uname -m`; chomp $arch;
    my $os_version = `freebsd-version | cut -d. -f1`; chomp $os_version;
    my $freebsd_version = "$os_version:$arch";

    print $mf "name: $PROJECT\n";
    print $mf "version: $pkg_version\n";
    print $mf "origin: www/$PROJECT\n";
    print $mf "comment: Advanced Web Statistics Community Edition\n";
    print $mf "maintainer: hestiacn\@tuta.io\n";
    print $mf "www: https://awstats.org\n";
    print $mf "prefix: /usr/local\n";
    print $mf "licenses: [GPLv3]\n";
    print $mf "categories: [www]\n";
    print $mf "arch: $freebsd_version\n" if $freebsd_version;
    
    print $mf "options: {\n";
    print $mf "    JSON: on,\n";
    print $mf "    GEOIPFREE: on,\n";
    print $mf "    IPV6: on,\n";
    print $mf "    UTF8: on\n";
    print $mf "}\n";
    
    print $mf "annotations: {\n";
    print $mf "    build_timestamp: \"$build_timestamp\",\n";
    print $mf "    build_date: \"$build_date\",\n";
    print $mf "    built_by: \"hestia-automation-builder-v1\",\n";
    print $mf "    cpe: \"cpe:2.3:a:hestiacn:awstats:$pkg_version:::::freebsd15:x64:1\"\n";
    print $mf "}\n";
    
    print $mf "deps: {\n";
    print $mf "    perl5: { origin: \"lang/perl5\" },\n";
    print $mf "    p5-JSON-XS: { origin: \"converters/p5-JSON-XS\" },\n";
    print $mf "    p5-Try-Tiny: { origin: \"lang/p5-Try-Tiny\" },\n";
    print $mf "    p5-MaxMind-DB-Common: { origin: \"net/p5-MaxMind-DB-Common\" },\n";
    print $mf "    p5-MaxMind-DB-Reader: { origin: \"net/p5-MaxMind-DB-Reader\" },\n";
    print $mf "    p5-MaxMind-DB-Reader-XS: { origin: \"net/p5-MaxMind-DB-Reader-XS\" },\n";
    print $mf "    wget: { origin: \"ftp/wget\" }\n";
    print $mf "}\n";
    print $mf "\n";
    print $mf "desc: <<EOD\n";
    print $mf "AWStats is short for Advanced Web Statistics. It's a free tool that
    generates advanced web (but also ftp or mail) server statistics,
    graphically.\n";
    print $mf "\n";
    print $mf "This log analyzer works as a CGI or from command line and shows you
    all possible information that your logs contain, in a few graphical
    web pages. It uses a partial information file to be able to process
    large log files, often and quickly.\n";
    print $mf "\n";
    print $mf "It can analyze log files from IIS (W3C log format), Apache log files
    (NCSA combined/XLF/ELF log format or common/CLF log format), WebStar
    and most of all web, proxy, WAP, and streaming servers (and FTP
    servers or mail logs).\n";
    print $mf "EOD\n";
    close $mf;

    print "  Manifest version: $pkg_version\n";
    print "  Architecture: $freebsd_version\n" if $freebsd_version;
    print "  ✅ Created +MANIFEST inside metadata directory\n";

    # ==========================================================================
    # 步骤5: 生成安装包依赖文件列表清单 +PLIST
    # ==========================================================================
    print "\n📋 Step 5: Generating PLIST...\n";
    my $plist_file = "$meta_stage/+PLIST";
    open my $pfh, '>', $plist_file or die "Cannot create $plist_file: $!";

    my @files = ();
    find(sub {
        return if $_ eq '.' || $_ eq '..';
        my $fullpath = $File::Find::name;
        my $relpath = $fullpath;
        $relpath =~ s/^\Q$pkg_root\E//;
        $relpath =~ s|^/||;
        $relpath =~ s|^usr/local/||;
        
        if (-f $fullpath && $fullpath !~ /\/\+/ && $fullpath !~ /\.meta/) {
            push @files, $relpath;
        }
    }, $pkg_root);

    foreach my $file (sort @files) {
        print $pfh "$file\n";
    }
    close $pfh;
    print "  ✅ Created +PLIST (" . scalar(@files) . " files)\n";
    
    # --------------------------------------------------------------------------
    # 创建符合 FreeBSD 包管理器标准的安装后脚本 +POST_INSTALL
    # --------------------------------------------------------------------------
    print "\n📋 Creating POST_INSTALL script...\n";
    my $postinstall_file = "$meta_stage/+POST_INSTALL";
    open my $pi, '>', $postinstall_file or die "Cannot create $postinstall_file: $!";
    print $pi <<'EOF';
#!/bin/sh

# 检查并下载 GeoIP 数据库
mkdir -p /usr/local/lib/perl5/site_perl/Geo

DBIP_DIR="/usr/local/lib/perl5/site_perl/Geo"
DBIP_DEST="$DBIP_DIR/dbip-city.mmdb"

if [ ! -f "$DBIP_DEST" ]; then
    echo "Downloading GeoIP database..."
    
    YEAR=$(date +%Y)
    MONTH=$(date +%m)
    DBIP_URL="https://download.db-ip.com/free/dbip-city-lite-${YEAR}-${MONTH}.mmdb.gz"
    DBIP_TEMP_GZ="$DBIP_DIR/dbip-city-temp.mmdb.gz"
    DBIP_TEMP="$DBIP_DIR/dbip-city-temp.mmdb"
    
    if command -v fetch > /dev/null 2>&1; then
        fetch -o "$DBIP_TEMP_GZ" "$DBIP_URL" 2>/dev/null
        if [ ! -s "$DBIP_TEMP_GZ" ]; then
            LAST_YEAR=$(date -v-1m +%Y 2>/dev/null || date -d "1 month ago" +%Y 2>/dev/null)
            LAST_MONTH=$(date -v-1m +%m 2>/dev/null || date -d "1 month ago" +%m 2>/dev/null)
            DBIP_URL="https://download.db-ip.com/free/dbip-city-lite-${LAST_YEAR}-${LAST_MONTH}.mmdb.gz"
            echo "Current month not available, trying ${LAST_YEAR}-${LAST_MONTH}..."
            fetch -o "$DBIP_TEMP_GZ" "$DBIP_URL" 2>/dev/null
        fi
        
        if [ -s "$DBIP_TEMP_GZ" ]; then
            gunzip -f "$DBIP_TEMP_GZ" && \
            mv "$DBIP_TEMP" "$DBIP_DEST" && \
            chmod 644 "$DBIP_DEST" && \
            echo "✓ GeoIP database downloaded successfully"
        else
            rm -f "$DBIP_TEMP_GZ"
            echo "⚠️ Failed to download GeoIP database"
        fi
    else
        echo "⚠️ fetch not installed, skipping GeoIP database download"
    fi
fi

# 生成 awredir.pl 的随机密钥
if [ -f /usr/local/www/cgi-bin/awredir.pl ]; then
    echo "Generating random key for awredir.pl..."
    if command -v openssl > /dev/null 2>&1; then
        KEY=$(openssl rand -hex 16 2>/dev/null)
    else
        KEY=$(perl -e 'print int(rand(2**32))' 2>/dev/null)
    fi
    
    if [ -n "$KEY" ]; then
        sed -i '' "s/YOURKEYFORMD5/$KEY/" /usr/local/www/cgi-bin/awredir.pl
        echo "✓ Random key generated for awredir.pl"
    fi
fi

# 添加 DB-IP 月度更新定时任务
(echo "# AWStats DB-IP monthly update on 3rd at 5:00 AM"; echo "0 5 3 * * /usr/local/etc/cron.d/awstats-dbip-update") | crontab -
echo "✓ DB-IP monthly update added to crontab (3rd at 5:00 AM)"

echo ""
echo "=========================================="
echo " AWStats 8.1-1 UTF-8 installation complete"
echo "=========================================="
echo " Main directory:     /usr/local/share/awstats"
echo " CGI scripts:        /usr/local/www/cgi-bin/"
echo " Configuration:      /usr/local/etc/awstats/"
echo " Tools:              /usr/local/share/awstats/tools/"
echo " Documentation:      /usr/local/share/doc/awstats/"
echo "=========================================="
echo " Configuration steps:"
echo " 1. cp /usr/local/etc/awstats/awstats.model.conf \\"
echo "    /usr/local/etc/awstats/awstats.yourdomain.conf"
echo " 2. Edit the configuration file, set LogFile, SiteDomain, etc."
echo " 3. Update statistics: /usr/local/bin/awstats -config=yourdomain -update"
echo " 4. Access: http://yourdomain/cgi-bin/awstats.pl?config=yourdomain"
echo "=========================================="
echo " Scheduled tasks:"
echo "   Daily update:   /usr/local/etc/periodic/daily/awstats"
echo "   Monthly DB update: /usr/local/etc/cron.d/awstats-dbip-update"
echo "   (Added to /var/cron/tabs/: 0 5 3 * * root ...)"
echo "=========================================="
EOF
    close $pi;
    chmod 0755, $postinstall_file;
    print "  ✅ Created +POST_INSTALL inside metadata directory\n";

    # ==========================================================================
    # 步骤6: 调用 FreeBSD 包编译器创建成品安装包
    # ==========================================================================
    print "\n📋 Step 6: Creating package...\n";
    chdir($BUILDROOT);
    
    my $cmd = "pkg create -m '$meta_stage' -r '$pkg_root' -p '$meta_stage/+PLIST' -o '$DESTI' 2>&1";
    print "  Running: $cmd\n";
    my $result = system($cmd);

    if ($result != 0) {
        print "  ❌ Package creation failed\n";
        return undef;
    }

    my $dh;
    my @pkgs;

    opendir($dh, $DESTI);
    @pkgs = grep { /\.pkg$/ && -f "$DESTI/$_" } readdir($dh);
    closedir($dh);

    my @sorted = sort { -s "$DESTI/$b" <=> -s "$DESTI/$a" } @pkgs;
    my $found = $sorted[0];

    use File::Basename qw(basename);
    use File::Copy qw(move);

    if ($found) {
        my $pkg_file = "$DESTI/$found";
        print "  Found package: $found (" . (-s $pkg_file) . " bytes)\n";
        
        my $target_base = basename($output);
        if ($found ne $target_base) {
            unlink($output) if -f $output;
            move($pkg_file, $output);
            print "  ✅ Renamed to: $target_base\n";
        }
    }

    # ==========================================================================
    # 步骤7: 查找并严密验证最终生成的二进制包 (确保通过 GitHub Actions 流程断检)
    # ==========================================================================
    print "\n📋 Step 7: Locating and verifying generated package...\n";
    print "  DESTI = $DESTI\n";
    print "  Checking directory contents:\n";
    system("ls -la $DESTI");
    print "\n";

    opendir($dh, $DESTI);
    @pkgs = grep { /\.pkg$/ && -f "$DESTI/$_" } readdir($dh);
    closedir($dh);

    print "  Found packages: " . join(", ", @pkgs) . "\n";

    if (@pkgs) {
        my $final_pkg = $pkgs[0];
        my $size = -s "$DESTI/$final_pkg";
        print "  ✅ Package created: $final_pkg (" . int($size/1024) . " KB)\n";
        
        my $target_base = basename($output);
        if ($final_pkg ne $target_base) {
            move("$DESTI/$final_pkg", $output);
            print "  ✅ Renamed to: $target_base\n";
        }
        
        # 终极物理落盘安全阻断检查
        if (-f $output) {
            print "  ✅ Verified: $output successfully generated and verified!\n";
            return $output;
        } else {
            print "  ❌ Warning: $output does not exist after final move\n";
        }
    }
    
    return undef;
}

# 构建 EXE 包
sub build_exe {
    my $version = "$MAJOR.$MINOR";
    my $filename = "$PROJECT-$version";
    my $output_file = "$DESTI/$filename.exe";
    
    print "\n🔨 Building EXE package: $filename\n";
    print "=" x 60, "\n";
    
    # 步骤0：强制检查 NSIS
    print "📋 Step 0: Force checking NSIS...\n";
    my $nsis = $REQUIREMENTS{EXE};
    my $makensis_path = '';
    
    foreach my $path (split(/;/, $ENV{PATH})) {
        my $test = "$path\\makensis.exe";
        if (-f $test) {
            $makensis_path = $test;
            last;
        }
    }
    
    if ($makensis_path) {
        print "  ✅ NSIS found at: $makensis_path\n";
        $nsis = $makensis_path;
    } else {
        print "  ❌ NSIS not found, skipping\n";
        return undef;
    }
    
    # 步骤1：检查环境
    print "\n📋 Step 1: Checking environment...\n";
    print "  OS: $OS\n";
    print "  Source dir: $SOURCE\n";
    print "  Output dir: $DESTI\n";
    
    # 检查 Windows 环境
    if ($OS ne 'windows') {
        print "  ❌ EXE package can only be built on Windows\n";
        return undef;
    }
    print "  ✅ Windows environment OK\n";
    
    # 步骤2：检查 NSI 文件
    print "\n📋 Step 2: Checking NSI file...\n";
    my $nsi_file = File::Spec->catfile($SOURCE, 'make', 'exe', "$PROJECT.nsi");
    print "  Looking for: $nsi_file\n";
    
    unless (-f $nsi_file) {
        print "  ❌ NSI file not found\n";
        my $exe_dir = File::Spec->catfile($SOURCE, 'make', 'exe');
        if (-d $exe_dir) {
            if (opendir(my $dh, $exe_dir)) {
                while (my $f = readdir $dh) {
                    print "    - $f\n" if $f !~ /^\./;
                }
                closedir $dh;
            }
        }
        return undef;
    }
    print "  ✅ NSI file found\n";
    
    # 步骤3：检查构建目录
    print "\n📋 Step 3: Checking build directory...\n";
    my $build_dir = "$BUILDROOT/$PROJECT-$version";
    unless (-d $build_dir) {
        print "  ❌ Build directory not found: $build_dir\n";
        return undef;
    }
    print "  ✅ Build directory exists\n";
    
    # 清理旧的 exe
    unlink "$filename.exe";
    if (-f "$SOURCE/make/exe/$filename.exe") {
        unlink "$SOURCE/make/exe/$filename.exe";
    }
    
    # 步骤4：运行 NSIS
    print "\n📋 Step 4: Running NSIS...\n";
    my $command = "\"$nsis\" /DMUI_VERSION_DOT=$version \"$nsi_file\"";
    print "  Command: $command\n";
    
    my $nsis_result = `$command 2>&1`;
    my $nsis_status = $?;  
    
    print "  NSIS output:\n";
    print "-" x 40, "\n";
    print $nsis_result;
    print "-" x 40, "\n";
    print "  Exit code: $nsis_status\n";
    
    if ($nsis_status != 0) {
        print "  ❌ NSIS failed with code: $nsis_status\n";
        return undef;
    }
    
    # 步骤5：查找生成的 exe
    print "\n📋 Step 5: Locating generated EXE...\n";
    my $exe_file = File::Spec->catfile($SOURCE, 'make', 'exe', "$filename.exe");
    print "  Looking for: $exe_file\n";
    
    if (-f $exe_file) {
        my $size = -s $exe_file;
        print "  ✅ EXE found, size: " . int($size/1024) . " KB\n";
        move($exe_file, $output_file) or warn "  ❌ Failed to move: $!";
        print "  ✅ Moved to: $output_file\n";
        return $output_file;
    } else {
        print "  ❌ EXE not found\n";
        return undef;
    }
}

# 主函数
sub main {
    my $help = 0;
    my $targets = '';
    my $publish = 0;
    
    GetOptions(
        'help|?'     => \$help,
        'target=s'   => \$targets,
        'publish'    => \$publish
    ) or die "Invalid options";
    
    if ($help) {
        print <<"USAGE";
Usage: $0 [options]
Options:
  --target=LIST   Comma-separated list of targets (TGZ,ZIP,RPM,DEB,PKG,EXE)
  --publish       Publish to GitHub releases
  --help          Show this help

Examples:
  $0 --target=TGZ,ZIP
  $0 --target=RPM,DEB,PKG
  $0 --target=all --publish
USAGE
        exit 0;
    }
    
    init();
    
    my ($tag, $commit, $date) = get_git_version($SOURCE);
    print "Git tag: $tag\n";
    print "Commit: $commit\n";
    print "Date: $date\n\n";
    
    prepare_buildroot();
    
    my @build_targets;
    if ($targets) {
        if (lc($targets) eq 'all') {
            @build_targets = @TARGETS;
        } else {
            @build_targets = split(/[,\s]+/, uc($targets));
        }
    } else {
        @build_targets = @TARGETS;
    }
    
    my @built_files;
    foreach my $target (@build_targets) {
        next unless check_requirements($target);
        
        my $file;
        if ($target eq 'TGZ') {
            $file = build_tgz();
        }
        elsif ($target eq 'ZIP') {
            $file = build_zip();
        }
        elsif ($target eq 'RPM') {
            $file = build_rpm();
        }
        elsif ($target eq 'DEB') {
            $file = build_deb();
        }
        elsif ($target eq 'PKG') {
            $file = build_pkg();
        }
        elsif ($target eq 'EXE') {
            $file = build_exe();
        }
        else {
            print "Unknown target: $target\n";
            next;
        }
        
        if ($file && -f $file) {
            push @built_files, $file;
            print "✓ Built $target: $file\n";
        }
    }
    
    if (@built_files) {
        my $checksum_file = generate_checksums(@built_files);
        push @built_files, $checksum_file;
    }
    
    if ($publish && @built_files) {
        print "\n" . "=" x 60 . "\n";
        print "GitHub Release\n";
        print "=" x 60 . "\n";
        
        my $new_version = "$MAJOR.$MINOR";
        my $new_tag = "v$new_version";
        
        my $release_notes = generate_release_notes($SOURCE, $tag, $new_tag);
        publish_with_gh_cli($new_version, $release_notes, @built_files);
    }
    
    print "\n" . "=" x 60 . "\n";
    print "Summary\n";
    print "=" x 60 . "\n";
    
    foreach my $file (@built_files) {
        my $size = -s $file;
        printf "✓ %s (%d bytes)\n", $file, $size;
    }
    
    print "\nBuild completed\n";
}

main();
exit 0;
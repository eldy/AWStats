#!/usr/bin/perl
#----------------------------------------------------------------------------
# \file         make/makepack-awstats.pl
# \brief        Package builder (tgz, zip, rpm, deb, exe)
# \version      $Revision$
# \author       (c)2004-2005 Laurent Destailleur  <eldy@users.sourceforge.net>
#----------------------------------------------------------------------------

use Cwd;

$PROJECT="awstats";
$MAJOR="6";
$MINOR="8";
$RPMSUBVERSION="1";

@LISTETARGET=("TGZ","ZIP","RPM","DEB","EXE");   # Possible packages
%REQUIREMENTTARGET=(                            # Tool requirement for each package
"TGZ"=>"tar",
"ZIP"=>"7z",
"RPM"=>"rpmbuild",
"DEB"=>"dpkg-buildpackage",
"EXE"=>"makensis.exe"
);
%ALTERNATEPATH=(
"7z"=>"7-ZIP",
"makensis.exe"=>"NSIS"
);

$FILENAME="$PROJECT";
$FILENAMETGZ="$PROJECT-$MAJOR.$MINOR";
$FILENAMEZIP="$PROJECT-$MAJOR.$MINOR";
$FILENAMERPM="$PROJECT-$MAJOR.$MINOR-$RPMSUBVERSION";
$FILENAMEDEB="$PROJECT-$MAJOR.$MINOR";
$FILENAMEEXE="$PROJECT-$MAJOR.$MINOR";
if (-d "/usr/src/redhat") {
    # redhat
    $RPMDIR="/usr/src/redhat";
}
if (-d "/usr/src/RPM") {
    # mandrake
    $RPMDIR="/usr/src/RPM";
}
if (-d "/usr/src/rpm") {
    # ubuntu
    $RPMDIR="/usr/src/rpm";
}
use vars qw/ $REVISION $VERSION /;
$REVISION='$Revision$'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
$VERSION="1.0 (build $REVISION)";



#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------
($DIR=$0) =~ s/([^\/\\]+)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
$DIR||='.'; $DIR =~ s/([^\/\\])[\\\/]+$/$1/;

$SOURCE="$DIR/../../awstats";
$DESTI="$SOURCE/make";

# Detect OS type
# --------------
if ("$^O" =~ /linux/i || (-d "/etc" && -d "/var" && "$^O" !~ /cygwin/i)) { $OS='linux'; $CR=''; }
elsif (-d "/etc" && -d "/Users") { $OS='macosx'; $CR=''; }
elsif ("$^O" =~ /cygwin/i || "$^O" =~ /win32/i) { $OS='windows'; $CR="\r"; }
if (! $OS) {
    print "$PROG was not able to detect your OS.\n";
	print "Can't continue.\n";
	print "$PROG aborted.\n";
    sleep 2;
	exit 1;
}

# Define buildroot
# ----------------
if ($OS =~ /linux/) {
    $TEMP=$ENV{"TEMP"}||$ENV{"TMP"}||"/tmp";
}
if ($OS =~ /macos/) {
    $TEMP=$ENV{"TEMP"}||$ENV{"TMP"}||"/tmp";
}
if ($OS =~ /windows/) {
    #$TEMP=$ENV{"TEMP"}||$ENV{"TMP"}||"c:/temp";
    $TEMP="c:/temp";
    $PROGPATH=$ENV{"ProgramFiles"};
}
if (! $TEMP || ! -d $TEMP) {
    print "Error: A temporary directory can not be find.\n";
    print "Check that TEMP or TMP environment variable is set correctly.\n";
	print "makepack-dolibarr.pl aborted.\n";
    sleep 2;
    exit 2;
} 
$BUILDROOT="$TEMP/${PROJECT}-buildroot";


my $copyalreadydone=0;
my $batch=0;

print "Makepack version $VERSION\n";
print "Building package name: $PROJECT\n";
print "Building package version: $MAJOR.$MINOR\n";

for (0..@ARGV-1) {
	if ($ARGV[$_] =~ /^-*target=(\w+)/i)    { $target=$1; $batch=1; }
}

# Choose package targets
#-----------------------
if ($target) {
    $CHOOSEDTARGET{uc($target)}=1;
}
else {
my $found=0;
my $NUM_SCRIPT;
while (! $found) {
	my $cpt=0;
	printf(" %d - %3s    (%s)\n",$cpt,"All","Need ".join(",",values %REQUIREMENTTARGET));
	foreach my $target (@LISTETARGET) {
		$cpt++;
		printf(" %d - %3s    (%s)\n",$cpt,$target,"Need ".$REQUIREMENTTARGET{$target});
	}

	# On demande de choisir le fichier à passer
	print "Choose one package number or several separated with space: ";
	$NUM_SCRIPT=<STDIN>; 
	chomp($NUM_SCRIPT);
	if ($NUM_SCRIPT =~ s/-//g) {
		# Do not do copy	
		$copyalreadydone=1;
	}
	if ($NUM_SCRIPT !~ /^[0-$cpt\s]+$/)
	{
		print "This is not a valid package number list.\n";
		$found = 0;
	}
	else
	{
		$found = 1;
	}
}
print "\n";
if ($NUM_SCRIPT) {
	foreach my $num (split(/\s+/,$NUM_SCRIPT)) {
		$CHOOSEDTARGET{$LISTETARGET[$num-1]}=1;
	}
}
else {
	foreach my $key (@LISTETARGET) {
	    $CHOOSEDTARGET{$key}=1;
    }
}
}

# Test if requirement is ok
#--------------------------
foreach my $target (keys %CHOOSEDTARGET) {
    foreach my $req (split(/[,\s]/,$REQUIREMENTTARGET{$target})) {
        # Test    
        print "Test requirement for target $target: Search '$req'... ";
        $ret=`"$req" 2>&1`;
        $coderetour=$?; $coderetour2=$coderetour>>8;
        if ($coderetour != 0 && (($coderetour2 == 1 && $OS =~ /windows/ && $ret !~ /Usage/i) || ($coderetour2 == 127 && $OS !~ /windows/)) && $PROGPATH) { 
            # Not found error, we try in PROGPATH
            $ret=`"$PROGPATH/$ALTERNATEPATH{$req}/$req\" 2>&1`;
            $coderetour=$?; $coderetour2=$coderetour>>8;
            $REQUIREMENTTARGET{$target}="$PROGPATH/$ALTERNATEPATH{$req}/$req";
        }    

        if ($coderetour != 0 && (($coderetour2 == 1 && $OS =~ /windows/ && $ret !~ /Usage/i) || ($coderetour2 == 127 && $OS !~ /windows/))) {
            # Not found error
            print "Not found\nCan't build target $target. Requirement '$req' not found in PATH\n";
            $CHOOSEDTARGET{$target}=-1;
            last;
        } else {
            # Pas erreur ou erreur autre que programme absent
            print " Found ".$REQUIREMENTTARGET{$target}."\n";
        }
    }
}

print "\n";

# Check if there is at least on target to build
#----------------------------------------------
$nboftargetok=0;
foreach my $target (keys %CHOOSEDTARGET) {
    if ($CHOOSEDTARGET{$target} < 0) { next; }
    $nboftargetok++;
}

if ($nboftargetok) {

# Update buildroot
#-----------------
if (! $copyalreadydone) {
	print "Delete directory $BUILDROOT\n";
	$ret=`rm -fr "$BUILDROOT"`;

	print "Create directory $BUILDROOT\n";
	mkdir "$BUILDROOT";

	print "Create directory $BUILDROOT/$PROJECT\n";
	mkdir "$BUILDROOT/$PROJECT";

	print "Recopie de $SOURCE/README.TXT dans $BUILDROOT/$PROJECT\n";
	$ret=`cp -p "$SOURCE/README.TXT" "$BUILDROOT/$PROJECT"`;

	print "Recopie de $SOURCE/docs dans $BUILDROOT/$PROJECT/docs\n";
	mkdir "$BUILDROOT/$PROJECT/docs";
	$ret=`cp -pr "$SOURCE/docs" "$BUILDROOT/$PROJECT"`;

	print "Recopie de $SOURCE/tools dans $BUILDROOT/$PROJECT/tools\n";
	mkdir "$BUILDROOT/$PROJECT/tools";
	$ret=`cp -pr "$SOURCE/tools" "$BUILDROOT/$PROJECT"`;

	print "Recopie de $SOURCE/wwwroot dans $BUILDROOT/$PROJECT/wwwroot\n";
	mkdir "$BUILDROOT/$PROJECT/wwwroot";
	$ret=`cp -pr "$SOURCE/wwwroot" "$BUILDROOT/$PROJECT"`;
}

print "Nettoyage de $BUILDROOT\n";
$ret=`rm -f $BUILDROOT/$PROJECT/ChangeLog`;
$ret=`rm -f $BUILDROOT/$PROJECT/docs/awstats_loganalysispaper.html`;
$ret=`rm -f $BUILDROOT/$PROJECT/tools/urlalias.txt`;
$ret=`rm -f $BUILDROOT/$PROJECT/tools/xferlogconvert.pl`;
$ret=`rm -f $BUILDROOT/$PROJECT/tools/xslt/awstats*.sps`;
$ret=`rm -f $BUILDROOT/$PROJECT/tools/xslt/gen*.*`;
$ret=`rm -fr $BUILDROOT/$PROJECT/tools/webmin/awstats`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/*.inc`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT.conf`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT.demo.conf`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT.mail.conf`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT.ftp.conf`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT.www*.conf`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT.map24.conf`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT.common.conf`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT.test*.conf`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT.*com.conf`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT.*net.conf`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT??????.txt`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT??.*`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/$PROJECT*.athena.*`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/smallprof.*`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/.smallprof*`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/plugins/etf1*`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/plugins/readgz*`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/plugins/urlalias.txt`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/plugins/detectrefererspam.pm`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/cgi-bin/plugins/testxxx.pm`;
$ret=`rm -f $BUILDROOT/$PROJECT/wwwroot/classes/src/AWGraphApplet.class`;
$ret=`rm -fr $BUILDROOT/$PROJECT/wwwroot/cgi-bin/plugins/testgeo*`;
$ret=`rm -fr $BUILDROOT/$PROJECT/wwwroot/cgi-bin/plugins/Geo`;
$ret=`rm -fr $BUILDROOT/$PROJECT/wwwroot/php`;
$ret=`rm -fr $BUILDROOT/$PROJECT/make`;
$ret=`rm -fr $BUILDROOT/$PROJECT/test`;
$ret=`rm -fr $BUILDROOT/$PROJECT/Thumbs.db $BUILDROOT/$PROJECT/*/Thumbs.db $BUILDROOT/$PROJECT/*/*/Thumbs.db $BUILDROOT/$PROJECT/*/*/*/Thumbs.db`;
$ret=`rm -fr $BUILDROOT/$PROJECT/CVS* $BUILDROOT/$PROJECT/*/CVS* $BUILDROOT/$PROJECT/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/*/*/CVS*`;

rename("$BUILDROOT/$PROJECT","$BUILDROOT/$FILENAMETGZ");

# Build package for each target
#------------------------------
    foreach my $target (keys %CHOOSEDTARGET) {
    if ($CHOOSEDTARGET{$target} < 0) { next; }

        print "\nBuild package for target $target\n";

    	if ($target eq 'TGZ') {
    		unlink $FILENAMETGZ.tgz;
    		print "Compress $FILENAMETGZ into $FILENAMETGZ.tar.gz\n";
    		$ret=`tar --directory="$BUILDROOT" --mode=go-w -czvf $FILENAMETGZ.tar.gz $FILENAMETGZ`;
    		print "Move $FILENAMETGZ.tar.gz to $DESTI\n";
    		rename("$FILENAMETGZ.tar.gz","$DESTI/$FILENAMETGZ.tar.gz");
    		next;
    	}	
    
    	if ($target eq 'ZIP') {
        		unlink $FILENAMEZIP.zip;
        		print "Compress $FILENAMETGZ into $FILENAMEZIP.zip...\n";
     		chdir("$BUILDROOT");
    		#print "cd $BUILDROOTNT & 7z a -r -tzip -mx $BUILDROOT/$FILENAMEZIP.zip $FILENAMETGZ\\*.*\n";
    		#$ret=`cd $BUILDROOTNT & 7z a -r -tzip -mx $BUILDROOT/$FILENAMEZIP.zip $FILENAMETGZ\\*.*`;
    		$ret=`7z a -r -tzip -mx $BUILDROOT/$FILENAMEZIP.zip $FILENAMETGZ\\*.*`;
    		print "Move $FILENAMEZIP.zip to $DESTI\n";
    		rename("$BUILDROOT/$FILENAMEZIP.zip","$DESTI/$FILENAMEZIP.zip");
    		next;
    	}

    	if ($target eq 'RPM') {                 # Linux only
    		$BUILDFIC="$FILENAME.spec";
    		unlink $FILENAMETGZ.tgz;
    		print "Compress $FILENAMETGZ into $FILENAMETGZ.tgz...\n";
    		$ret=`tar --exclude-from "$SOURCE/make/tgz/tar.exclude" --directory "$BUILDROOT" -czvf "$BUILDROOT/$FILENAMETGZ.tgz" $FILENAMETGZ`;

    		print "Move $FILENAMETGZ.tgz to $RPMDIR/SOURCES/$FILENAMETGZ.tgz\n";
    		$cmd="mv \"$BUILDROOT/$FILENAMETGZ.tgz\" \"$RPMDIR/SOURCES/$FILENAMETGZ.tgz\"";
            $ret=`$cmd`;

    		print "Copy $SOURCE/make/rpm/${BUILDFIC} to $BUILDROOT\n";
#    		$ret=`cp -p "$SOURCE/make/rpm/${BUILDFIC}" "$BUILDROOT"`;
            open (SPECFROM,"<$SOURCE/make/rpm/${BUILDFIC}") || die "Error, can't open input file $SOURCE/make/rpm/${BUILDFIC}";
            open (SPECTO,">$TEMP/$BUILDFIC") || die "Error, can't open output file $TEMP/$BUILDFIC";
            while (<SPECFROM>) {
                $_ =~ s/__VERSION__/$MAJOR.$MINOR/;
                print SPECTO $_;
            }
            close SPECFROM;
            close SPECTO;

    		print "Launch RPM build (rpmbuild --clean -ba $TEMP/${BUILDFIC})\n";
    		$ret=`rpmbuild --clean -ba $TEMP/${BUILDFIC}`;

   		    print "Move $RPMDIR/RPMS/noarch/${FILENAMERPM}.noarch.rpm into $DESTI/${FILENAMERPM}.noarch.rpm\n";
   		    $cmd="mv \"$RPMDIR/RPMS/noarch/${FILENAMERPM}.noarch.rpm\" \"$DESTI/${FILENAMERPM}.noarch.rpm\"";
    		$ret=`$cmd`;
		next;
	}
	
	if ($target eq 'DEB') {
        print "Automatic build for DEB is not yet supported.\n";
    }
    
	if ($target eq 'EXE') {
    		unlink "$FILENAMEEXE.exe";
    		print "Compress into $FILENAMEEXE.exe by $FILENAME.nsi...\n";
    		$command="\"$REQUIREMENTTARGET{$target}\" /DMUI_VERSION_DOT=$MAJOR.$MINOR /X\"SetCompressor bzip2\" \"$SOURCE\\make\\exe\\$FILENAME.nsi\"";
        print "$command\n";
		$ret=`$command`;
		print "Move $FILENAMEEXE.exe to $DESTI\n";
		rename("$SOURCE\\make\\exe\\$FILENAMEEXE.exe","$DESTI/$FILENAMEEXE.exe");
		next;
	}

}

}

print "\n----- Summary -----\n";
foreach my $target (keys %CHOOSEDTARGET) {
    if ($CHOOSEDTARGET{$target} < 0) {
        print "Package $target not built (bad requirement).\n";
    } else {
        print "Package $target built succeessfully in $DESTI\n";
    }
}

if (! $btach) {
	print "\nPress key to finish...";
	my $WAITKEY=<STDIN>;
}

0;

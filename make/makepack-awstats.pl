#!/usr/bin/perl
use Cwd;

$PROJECT="awstats";
$MAJOR="6";
$MINOR="4";
$RPMSUBVERSION="1";

@LISTETARGET=("TGZ","ZIP","RPM","DEB","EXE");   # Possible packages
%REQUIREMENTTARGET=(                            # Tool requirement for each package
"TGZ"=>"tar",
"ZIP"=>"7z",
"RPM"=>"rpm",
"DEB"=>"dpkg-buildpackage",
"EXE"=>"makensis.exe");
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
    print "makepack-dolbarr.pl was not able to detect your OS.\n";
	print "Can't continue.\n";
	print "makepack-dolibarr.pl aborted.\n";
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
    $TEMP=$ENV{"TEMP"}||$ENV{"TMP"}||"c:/temp";
    $PROGPATH=$ENV{"ProgramFiles"};
}
if (! $TEMP || ! -d $TEMP) {
    print "Error: A temporary directory can not be find.\n";
    print "Check that TEMP or TMP environment variable is set correctly.\n";
	print "makepack-dolibarr.pl aborted.\n";
    sleep 2;
    exit 2;
} 
$BUILDROOT="$TEMP/buildroot";



# Choose package targets
#-----------------------
print "Makepack version $VERSION\n";
print "Building package for $PROJECT $MAJOR.$MINOR\n";
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

# Test if requirement is ok
#--------------------------
foreach my $target (keys %CHOOSEDTARGET) {
    foreach my $req (split(/[,\s]/,$REQUIREMENTTARGET{$target})) {
        # Test    
        print "Test requirement for target $target: Search '$req'... ";
        $ret1=`"$req" 2>&1`;
        $coderetour=$?; $coderetour2=$coderetour>>8;
        if ($coderetour != 0 && $coderetour2 == 1 && $PROGPATH) { 
            # If error not found, we try in PROGPATH
            $ret2=`"$PROGPATH/$ALTERNATEPATH{$req}/$req\" 2>&1`;
            $coderetour=$?; $coderetour2=$coderetour>>8;
            $REQUIREMENTTARGET{$target}="$PROGPATH/$ALTERNATEPATH{$req}/$req";
        }    

        if ($coderetour == 0 || $coderetour2 > 1 || $ret1 =~ /Usage/im || $ret2 =~ /Usage/im) {
            # Pas erreur ou erreur autre que programme absent
            print " Found ".$REQUIREMENTTARGET{$target}."\n";
        } else {
            print "Not found\nCan't build target $target. Requirement '$req' not found in PATH\n";
            $CHOOSEDTARGET{$target}=-1;
            last;
        }
    }
}

print "\n";

# Update buildroot
#-----------------
my $copyalreadydone=0;
if (! $copyalreadydone) {
	print "Delete directory $BUILDROOT\n";
	$ret=`rm -fr "$BUILDROOT"`;

	mkdir "$BUILDROOT";
	print "Recopie de $SOURCE dans $BUILDROOT/$PROJECT\n";
	mkdir "$BUILDROOT/$PROJECT";
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

# Generation des packages
#------------------------

# Build package for each target
#------------------------------
foreach $target (keys %CHOOSEDTARGET) {
    if ($CHOOSEDTARGET{$target} < 0) { next; }

    print "\nBuild pack for target $target\n";

	if ($target eq 'TGZ') {
		unlink $FILENAMETGZ.tgz;
		print "Compression en $FILENAMETGZ.tgz de $FILENAMETGZ\n";
		$ret=`tar --directory="$BUILDROOT" -czvf $FILENAMETGZ.tgz $FILENAMETGZ`;
		print "Déplacement de $FILENAMETGZ.tgz dans $DESTI\n";
		rename("$FILENAMETGZ.tgz","$DESTI/$FILENAMETGZ.tgz");
		next;
	}	

	if ($target eq 'ZIP') {
		unlink "$BUILDROOT/$FILENAMEZIP.zip de $FILENAMETGZ";
		print "Compression en $FILENAMEZIP.zip\n";
 		chdir("$BUILDROOT");
		#print "cd $BUILDROOTNT & 7z a -r -tzip -mx $BUILDROOT/$FILENAMEZIP.zip $FILENAMETGZ\\*.*\n";
		#$ret=`cd $BUILDROOTNT & 7z a -r -tzip -mx $BUILDROOT/$FILENAMEZIP.zip $FILENAMETGZ\\*.*`;
		$ret=`7z a -r -tzip -mx $BUILDROOT/$FILENAMEZIP.zip $FILENAMETGZ\\*.*`;
		print "Déplacement de $FILENAMEZIP.zip dans $DESTI\n";
		rename("$BUILDROOT/$FILENAMEZIP.zip","$DESTI/$FILENAMEZIP.zip");
		next;
	}

	if ($target eq 'RPM') {
		# Copie fichier spec
		$BUILDFIC="$FILENAMETGZ.spec";
		print "Recopie fichiers build $SOURCE/make/rpm/${BUILDFIC} en z:/tmp\n";
        open (SPECFROM,"<$SOURCE/make/rpm/${BUILDFIC}") || die "Error, can't open input file";
        open (SPECTO,">z:/tmp") || die "Error, can't open output file";
        while (<SPECFROM>) {
            $_ =~ s/__VERSION__/$MAJOR.$MINOR.$BUILD/;
            print SPECTO $_;
        }
        close SPECFROM;
        close SPECTO;

		unlink $FILENAMETGZ.tgz;
		print "Compression en $FILENAMETGZ.tgz de $FILENAMETGZ\n";
		$ret=`tar --directory="$BUILDROOT" -czvf $FILENAMETGZ.tgz $FILENAMETGZ`;
		print "Déplacement de $FILENAMETGZ.tgz dans z:/usr/src/RPM/SOURCES/\n";
		$ret=`cp "$FILENAMETGZ.tgz" "z:/usr/src/RPM/SOURCES/"`;

		print "Lancer la generation du RPM (rpm --clean -ba /tmp/${BUILDFIC})\n";
		my $WAITKEY=<STDIN>;
	
		print "Recopie de z:/usr/src/RPM/RPMS/noarch/${FILENAMERPM}.noarch.rpm en $DESTI\n";
		rename("z:/usr/src/RPM/RPMS/noarch/${FILENAMERPM}.noarch.rpm","$DESTI/${FILENAMERPM}.noarch.rpm");
		next;
	}
	
	if ($target eq 'DEB') {
        print "Automatic build for DEB is not yet supported.\n";
    }
    
	if ($target eq 'EXE') {
		unlink "$BUILDROOT/$FILENAMEEXE.exe";
		print "Compression en $FILENAMEEXE.exe par $FILENAME.nsi\n";
		$command="\"c:\\Program Files\\NSIS\\makensis.exe\" /DMUI_VERSION_DOT=$MAJOR.$MINOR /X\"SetCompressor bzip2\" \"$SOURCE\\make\\exe\\$FILENAME.nsi\"";
        print "$command\n";
		$ret=`$command`;
		print "Move $FILENAMEEXE.exe to $DESTI\n";
		rename("$SOURCE\\make\\exe\\$FILENAMEEXE.exe","$DESTI/$FILENAMEEXE.exe");
		next;
	}

}

print "\n----- Summary -----\n";
foreach $target (keys %CHOOSEDTARGET) {
    if ($CHOOSEDTARGET{$target} < 0) {
        print "Package $target not built (bad requirement).\n";
    } else {
        print "Package $target built succeessfully in $DESTI\n";
    }
}

print "\nPress key to finish...";
my $WAITKEY=<STDIN>;

0;

#!/usr/bin/perl
use Cwd;

$PROJECT="awstats";
$MAJOR="1";
$MINOR="5";

$FILENAMEWBM="$PROJECT-$MAJOR.$MINOR";
$SOURCE="C:/Mes developpements/$PROJECT/tools/webmin";
$DESTI="C:/Mes sites/Web/$PROJECT/wwwroot/files";
$BUILDROOT="c:/temp/buildroot";

@LISTETARGET=("WBM");
@CHOOSEDTARGET=();


# Choose package
#---------------
print "Building package for $PROJECT $MAJOR.$MINOR\n";
my $copyalreadydone=0;
my $found=0;
my $NUM_SCRIPT;
while (! $found) {
	my $cpt=0;
	print "$cpt - All\n";
	foreach my $target (@LISTETARGET) {
		$cpt++;
		print "$cpt - $target\n";
	}

	# On demande de choisir le fichier à passer
	print "Choose package number (or several separated by space): ";
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
		push @CHOOSEDTARGET, $LISTETARGET[$num-1];
	}
}
else {
	@CHOOSEDTARGET=@LISTETARGET;	
}


# Mise à jour du buildroot
#-------------------------

if (! $copyalreadydone) {
	print "Suppression du repertoire $BUILDROOT\n";
	$ret=`rm -fr "$BUILDROOT"`;

	mkdir "$BUILDROOT";
	print "Recopie de $SOURCE dans $BUILDROOT/$PROJECT\n";
	mkdir "$BUILDROOT/$PROJECT";
	$ret=`cp -pr "$SOURCE/$PROJECT" "$BUILDROOT"`;

}

print "Nettoyage de $BUILDROOT\n";
$ret=`rm -f $BUILDROOT/$PROJECT/webmin/*.wbm`;
$ret=`rm -f $BUILDROOT/$PROJECT/webmin/*.tar`;
$ret=`rm -fr $BUILDROOT/$PROJECT/Thumbs.db $BUILDROOT/$PROJECT/*/Thumbs.db $BUILDROOT/$PROJECT/*/*/Thumbs.db $BUILDROOT/$PROJECT/*/*/*/Thumbs.db`;
$ret=`rm -fr $BUILDROOT/$PROJECT/CVS* $BUILDROOT/$PROJECT/*/CVS* $BUILDROOT/$PROJECT/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/*/*/CVS*`;


# Generation des packages
#------------------------

foreach $target (@CHOOSEDTARGET) {

	if ($target eq 'WBM') {
		unlink $FILENAMEWBM.wbm;
		print "Creation archive $FILENAMEWBM.wbm de $PROJECT\n";
		$ret=`tar --directory="$BUILDROOT" -cvf $FILENAMEWBM.wbm $PROJECT`;
		print "Déplacement de $FILENAMEWBM.wbm dans $SOURCE/$FILENAMEWBM.wbm\n";
		rename("$FILENAMEWBM.wbm","$SOURCE/$FILENAMEWBM.wbm");
		$ret=`cp -pr "$SOURCE/$FILENAMEWBM.wbm" "$DESTI/$FILENAMEWBM.wbm"`;
	}	

}

print "\n";
foreach $target (@CHOOSEDTARGET) {
	print "Fichiers de type $target genere en $DESTI avec succes.\n";
}

my $WAITKEY=<STDIN>;

0;

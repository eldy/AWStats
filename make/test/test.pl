#!/usr/bin/perl
#-----------------------------------------------------------------------------
# Run update and output for a list of test config files
#-----------------------------------------------------------------------------


$DIRAWSTATS="/home/ldestailleur/git/awstats/wwwroot/cgi-bin";
$DIRCONF="/home/ldestailleur/git/awstats/test/awstats/conf";
$DIRRESULT="/home/ldestailleur/git/awstats/test/awstats/result";
$TEMP="/temp";
#$PERL="\"c:\\Program files\\cygwin\\bin\\perl.exe\"";
$PERL="perl";

@TESTLIST=(
"testglobal",
"testsmall",
"testnginx",
"testtime5",
#"testlogins",
#"testworms",
#"testipv6",
#"testdnsdone",
#"testextra",
#"testgeoip",
#"testgeoip_region_maxmind",
#"testgeoip_city_maxmind",
"testgeoip_isp_maxmind",
#"testgeoip_org_maxmind",
#"testrobot",
#"benchmark",
#"testmoddeflate","testmodgzip","testmodgzip2","testmodgzip3",
#"testurlwithquery",
#"testwindowsmediaserver","testwindowsmediaserver9","testrealmediaserver","testdarwinserver",
#"testsquidextended",
#"testisa1",
#"testisa2",
#"testlotus",
#"testlotus65",
#"testwebstar",
#"testzope",
#"testcluster",
#"testoracle9ias",
#"testproftp","testproftp2","testvsftpd",
#"testskipfiles",
#"testvirtualhosts",
#"testsendmail",
#"testpostfix",
#"testpostfix1",
#"testpostfix4",
#"testexchange"
);

#@TESTLIST=("testglobal","testsmall","testtime5");
#@TESTLIST=("testlogins");
#@TESTLIST=("testworms");
#@TESTLIST=("testipv6");
#@TESTLIST=("testrobot");
#@TESTLIST=("testdnsdone");
#@TESTLIST=("testextra");
#@TESTLIST=("testgeoip");
#@TESTLIST=("benchmark");
#@TESTLIST=("testmoddeflate","testmodgzip","testmodgzip2","testmodgzip3");
#@TESTLIST=("testproftp");
#@TESTLIST=("testwindowsmediaserver");
#@TESTLIST=("testwindowsmediaserver9");
#@TESTLIST=("testrealmediaserver");
#@TESTLIST=("testdarwinserver");
#@TESTLIST=("testurlwithquery");
#@TESTLIST=("testlotus");
#@TESTLIST=("testlotus65");
#@TESTLIST=("testzope");
#@TESTLIST=("testcluster");
#@TESTLIST=("testoracle9ias");
#@TESTLIST=("testproftp","testproftp2","testvsftpd");
#@TESTLIST=("testskipfiles");
#@TESTLIST=("testvirtualhosts");
#@TESTLIST=("testsendmail");
#@TESTLIST=("testpostfix");
#@TESTLIST=("testpostfix1");
#@TESTLIST=("testpostfix4");
#@TESTLIST=("testexchange");
#@TESTLIST=("testwebstar");
$OPTIONNODEBUG="-staticlinks -showdropped -showcorrupted -debug=0";
$OPTIONDEBUG="-staticlinks -showdropped -showcorrupted -debug=4";
$YEARMONTH="-month=01 -year=2001";
#$YEARMONTH="-month=12 -year=2003";

print "AWStats unitary tester\n";


while(1==1)
{
	
	print "Choose test to execute...\n";
	sprintf("$2i %s", 0, "All");
	my $i=1;
	foreach my $key (@TESTLIST) {
	    print sprintf("%02i) %s\n",$i,$key);
	    $i++;
	}
	my $bidon='';
	while (! $bidon) {
	    print "Your choice : ";
	    $bidon=<STDIN>;
	    chomp $bidon;
	    $bidon =~ s/\r//g;
	}
	my @chosen=();
	if ($bidon eq '0') { @chosen=@TESTLIST; }
	else { push @chosen, $TESTLIST[$bidon-1]; }
	
	# Option output
	print "Choose output option ('', 'browserdetail', 'osdetail', ...)\n";
	$bidon='';
	print "Your choice : ";
	$bidon=<STDIN>;
	chomp $bidon;
	$bidon =~ s/\r//g;
	if ($bidon) { $OPTIONOUTPUT=$bidon; }
	
	my $command=my $ret='';
	foreach my $test (@chosen) {
		print "\n----- Lancement du test $test -----\n";
	
		unlink("$DIRRESULT/dnscachelastupdate.$test.txt");
	
		$command="cp \"$DIRCONF/awstats.$test.conf\" \"$DIRAWSTATS/awstats.$test.conf\"";
		print "$command 2>&1\n";
		$ret=`$command`;
		print "$ret\n";
	
		opendir(DIR,"$DIRRESULT");
		foreach (grep /^awstats\d\d\d\d\d\d\.$test\.txt$/, sort readdir DIR) { unlink "$DIRRESULT/$_"; }
		closedir(DIR);
	
		$command="$PERL \"$DIRAWSTATS/awstats.pl\" $OPTIONDEBUG -config=$test > \"$DIRRESULT/result_${test}_update_debug.html\"";
		print "$command 2>&1\n";
		$ret=`$command  2>&1`;
	#	print "$ret\n";
        $command="$PERL \"$DIRAWSTATS/awstats.pl\" $OPTIONNODEBUG -config=$test > \"$DIRRESULT/result_${test}_update.html\"";
        print "$command 2>&1\n";
        $ret=`$command  2>&1`;
    #   print "$ret\n";
		$command="$PERL \"$DIRAWSTATS/awstats.pl\" $OPTIONDEBUG -config=$test $YEARMONTH -output".($OPTIONOUTPUT?"=$OPTIONOUTPUT":"")." > \"$DIRRESULT/result_${test}_debug.html\"";
		print "$command 2>&1\n";
		$ret=`$command`;
	#	print "$ret\n";
        $command="$PERL \"$DIRAWSTATS/awstats.pl\" $OPTIONNODEBUG -config=$test $YEARMONTH -output".($OPTIONOUTPUT?"=$OPTIONOUTPUT":"")." > \"$DIRRESULT/result_${test}.html\"";
        print "$command 2>&1\n";
        $ret=`$command`;
    #   print "$ret\n";
	
		`rm "$DIRAWSTATS/awstats.$test.conf"`;
	
		# Compare txt file
	
		# Compare html file
		
	
		print "Test $test finished success.\n";
	}
	
	sleep 5;

}

#!/usr/bin/perl
# view_all.cgi
# Display summary of all available config files
# $Revision$ - $Author$ - $Date$

require './awstats-lib.pl';
&ReadParse();


my $BarWidth=120;
my $BarHeight=3;

# Check if awstats is actually installed
if (!&has_command($config{'awstats'})) {
	&header($text{'index_title'}, "", undef, 1, 1, 0, undef);
	print "<hr>\n";
	print "<p>",&text('index_eawstats', "<tt>$config{'awstats'}</tt>","$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
	print "<hr>\n";
	&footer("/", $text{'index'});
	exit;
}


&header($text{'viewall_title'}, "", undef, 1, 1, 0, undef, undef, undef, undef);

my $widthtooltip=560;
print <<EOF;
<style type="text/css">
<!--
div { font: 12px 'Arial','Verdana','Helvetica', sans-serif; text-align: justify; }
.CTooltip { position:absolute; top: 0px; left: 0px; z-index: 2; width: ${widthtooltip}px; visibility:hidden; font: 8pt 'MS Comic Sans','Arial',sans-serif; background-color: #FFFFE6; padding: 8px; border: 1px solid black; }
//-->
</style>

<script language="javascript" type="text/javascript">
function ShowTip(fArg)
{
	var tooltipOBJ = (document.getElementById) ? document.getElementById('tt' + fArg) : eval("document.all['tt" + fArg + "']");
	if (tooltipOBJ != null) {
		var tooltipLft = (document.body.offsetWidth?document.body.offsetWidth:document.body.style.pixelWidth) - (tooltipOBJ.offsetWidth?tooltipOBJ.offsetWidth:(tooltipOBJ.style.pixelWidth?tooltipOBJ.style.pixelWidth:${widthtooltip})) - 30;
		var tooltipTop = 10;
		if (navigator.appName == 'Netscape') {
			tooltipTop = (document.body.scrollTop>=0?document.body.scrollTop+10:event.clientY+10);
 			tooltipOBJ.style.top = tooltipTop+"px";
			tooltipOBJ.style.left = tooltipLft+"px";
		}
		else {
			tooltipTop = (document.body.scrollTop>=0?document.body.scrollTop+10:event.clientY+10);
			tooltipTop = (document.body.scrollTop>=0?document.body.scrollTop+10:event.clientY+10);
			if ((event.clientX > tooltipLft) && (event.clientY < (tooltipOBJ.scrollHeight?tooltipOBJ.scrollHeight:tooltipOBJ.style.pixelHeight) + 10)) {
				tooltipTop = (document.body.scrollTop?document.body.scrollTop:document.body.offsetTop) + event.clientY + 20;
			}
			tooltipOBJ.style.left = tooltipLft;
			tooltipOBJ.style.top = tooltipTop;
		}
		tooltipOBJ.style.visibility = "visible";
	}
}
function HideTip(fArg)
{
	var tooltipOBJ = (document.getElementById) ? document.getElementById('tt' + fArg) : eval("document.all['tt" + fArg + "']");
	if (tooltipOBJ != null) {
		tooltipOBJ.style.visibility = "hidden";
	}
}
</script>
EOF


print "<hr>\n";

if (! $access{'view'}) {
	print &text('viewall_notallowed')."<br>\n";
}

my @configdirtoscan=split(/\s+/, $access{'dir'});

if (! @configdirtoscan) {
	print &text('index_nodirallowed',"<b>$remote_user</b>")."<br>\n";
	print &text('index_changeallowed',"<a href=\"/acl/\">Webmin - Utilisateurs Webmin</a>", $text{'index_title'})."<br>\n";
	print "<br>\n";
#	print "<p>",&text('index_econfdir', "<tt>$config{'awstats_conf'}</tt>",
#		  "$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
	print "<hr>\n";
	&footer("/", $text{'index'});
	exit;
}

# Build list of config files from allowed directories
foreach my $dir (split(/\s+/, $access{'dir'})) {
	my @conflist=();
	push(@conflist, map { $_->{'custom'} = 1; $_ } &scan_config_dir($dir));
	foreach my $file (@conflist) {
		next if (!&can_edit_config($file));
		push @config, $file;
	}
}

# Write message for allowed directories
print &text('viewall_allowed',"<b>$remote_user</b>");
print ":<br>\n";
foreach my $dir (split(/\s/,$access{'dir'})) {
	print "$dir<br>";
}
print "<br>\n";
print &text('index_changeallowed',"<a href=\"/acl/\">Webmin - Webmin Users</a>", $text{'index_title'})."<br>\n";
print "<br>";


$starttime=time();
($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday,$nowyday) = localtime($starttime);
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
$nowmonth=sprintf("%02d",$nowmonth+1);

my $YearRequired=$in{'year'}||$nowyear;
my $MonthRequired=$in{'month'}||$nowmonth;
my %dirdata=();
my %view_u=();
my %view_v=();
my %view_p=();
my %view_h=();
my %view_k=();
my %notview_p=();
my %notview_h=();
my %notview_k=();
my %version=();
my %lastupdate=();
my $max_u=0;
my $max_v=0;
my $max_p=0;
my $max_h=0;
my $max_k=0;
my $nomax_p=0;
my $nomax_h=0;
my $nomax_k=0;
my %ListOfYears=($nowyear=>1);
# If required year not in list, we add it
$ListOfYears{$YearRequired}||=$MonthRequired;

# Set dirdata for config file
my $nbofallowedconffound=0;
if (scalar @config) {

	# Loop on each config file
	foreach my $l (@config) {
		next if (!&can_edit_config($l));
		$nbofallowedconffound++;

        # Read data files
        $dirdata{$l}=get_dirdata($l);
    }
}


# Show summary informations
$nbofallowedconffound=0;
if (scalar @config) {

    my %foundendmap=();
    my %error=();

	# Loop on each config file to get info
	#--------------------------------------
	foreach my $l (@config) {
		next if (!&can_edit_config($l));
        
		# Config file line
		#local @files = &all_config_files($l);
		#next if (!@files);
		local $lconf = &get_config($l);
		my $conf=""; my $dir="";
		if ($l =~ /awstats([^\\\/]*)\.conf$/) { $conf=$1; }
		if ($l =~ /^(.*)[\\\/][^\\\/]+$/) { $dir=$1; }
        my $confwithoutdot=$conf; $confwithoutdot =~ s/^\.+//;

        # Read data file for config $l
        my $dirdata=$dirdata{$l};
        if (! $dirdata) { $dirdata="."; }
        my $filedata=$dirdata."/awstats${MonthRequired}${YearRequired}${conf}.txt";

        my $linenb=0;
        my $posgeneral=0;
        if (! -f "$filedata") {
            $error{$l}="No data for this month";
        }
        elsif (open(FILE, "<$filedata")) {
            $linenb=0;
            while(<FILE>) {
                if ($linenb++ > 100) { last; }
                my $savline=$_;
                chomp $_; s/\r//;

                # Remove comments not at beginning of line
                $_ =~ s/\s#.*$//;

                # Extract param and value
                my ($param,$value)=split(/=/,CleanFromTags($_),2);
                $param =~ s/^\s+//; $param =~ s/\s+$//;
                $value =~ s/#.*$//;
                $value =~ s/^[\s\'\"]+//; $value =~ s/[\s\'\"]+$//;

                if ($param) {
                    # cleanparam is param without begining #
                    my $cleanparam=$param; my $wascleaned=0;
                    if ($cleanparam =~ s/^#//) { $wascleaned=1; }

                    if ($cleanparam =~ /^AWSTATS DATA FILE (.*)$/) {
                        $version{$l}=$1;
                        next;
                    }
                    if ($cleanparam =~ /^POS_GENERAL\s+(\d+)/) {
                        $posgeneral=$1;
                        next;
                    }
                    if ($cleanparam =~ /^POS_TIME\s+(\d+)/) {
                        $postime=$1;
                        next;
                    }
                    if ($cleanparam =~ /^END_MAP/) {
                        $foundendmap{$l}=1;
                        last;
                    }
                }

            }
            if ($foundendmap{$l}) {

                # Map section was completely read, we can jump to data GENERAL
                if ($posgeneral) {
            		$linenb=0;
                    my ($foundu,$foundv,$foundl)=(0,0,0);
                    seek(FILE,$posgeneral,0);
                    while (<FILE>) {
                        if ($linenb++ > 50) { last; }  # To protect against full file scan
                        $line=$_;
                 		chomp $line; $line =~ s/\r$//;
                        $line=CleanFromTags($line);
                        
                        if ($line =~ /TotalUnique\s+(\d+)/) { $view_u{$l}=$1; if ($1 > $max_u) { $max_u=$1; } $foundu++; }
                        elsif ($line =~ /TotalVisits\s+(\d+)/) { $view_v{$l}=$1; if ($1 > $max_v) { $max_v=$1; }  $foundv++; }
                        elsif ($line =~ /LastUpdate\s+(\d+)/) { $lastupdate{$l}=$1; $foundl++; }
                        
                        if ($foundu && $foundv && $foundl) { last; }
                    }
                } else {
                    $error{$l}.="Mapping for section GENERAL was wrong.";
                }

                # Map section was completely read, we can jump to data TIME
                if ($postime) {
                    seek(FILE,$postime,0);
            		$linenb=0;
                    while (<FILE>) {
                        if ($linenb++ > 50) { last; }  # To protect against full file scan
                        $line=$_;
                 		chomp $line; $line =~ s/\r$//;
                        $line=CleanFromTags($line);
                        
                        if ($line =~ /^(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/) {
                            $view_p{$l}+=$2;
                            $view_h{$l}+=$3;
                            $view_k{$l}+=$4;
                            $noview_p{$l}+=$5;
                            $noview_h{$l}+=$6;
                            $noview_k{$l}+=$7;
                        }
                        
                        if ($line =~ /^END_TIME/) { last; }
                    }
                    if ($view_p{$l} > $max_p) { $max_p=$view_p{$l}; } 
                    if ($view_h{$l} > $max_h) { $max_h=$view_h{$l}; }
                    if ($view_k{$l} > $max_k) { $max_k=$view_k{$l}; } 
                    if ($noview_p{$l} > $nomax_p) { $nomax_p=$noview_p{$l}; }
                    if ($noview_h{$l} > $nomax_h) { $nomax_h=$noview_h{$l}; }
                    if ($noview_k{$l} > $nomax_k) { $nomax_k=$noview_k{$l}; }
                   } else {
                    $error{$l}.="Mapping for section TIME was wrong.";
                }
                
            }
            close(FILE);
        } else {
            $error{$l}="Failed to open $filedata for read";
        }
    }

	($total_u,$total_v,$total_p,$total_h,$total_k)=();
	
	# Loop on each config file to show info
	#--------------------------------------
	foreach my $l (@config) {
		next if (!&can_edit_config($l));
		$nbofallowedconffound++;
        
		# Config file line
		#local @files = &all_config_files($l);
		#next if (!@files);
		local $lconf = &get_config($l);
		my $conf=""; my $dir="";
		if ($l =~ /awstats([^\\\/]*)\.conf$/) { $conf=$1; }
		if ($l =~ /^(.*)[\\\/][^\\\/]+$/) { $dir=$1; }
        my $confwithoutdot=$conf; $confwithoutdot =~ s/^\.+//;

        # Read data file for config $l
        my $dirdata=$dirdata{$l};
        if (! $dirdata) { $dirdata="."; }
        my $filedata=$dirdata."/awstats${MonthRequired}${YearRequired}${conf}.txt";

		# Head of config file's table list
		if ($nbofallowedconffound == 1) {
			print "<table border width=100%>\n";
			print "<form method=\"post\" action=\"view_all.cgi\">\n";
			print "<tr><td valign=\"middle\"><b>".&text('viewall_period').":</b></td>";
			print "<td valign=\"middle\">";
			print "<select name=\"month\">\n";
			foreach (1..12) { my $monthix=sprintf("%02s",$_); print "<option".($MonthRequired eq "$monthix"?" selected=\"true\"":"")." value=\"$monthix\">".&text("month$monthix")."</option>\n"; }
			print "</select>\n";
			print "<select name=\"year\">\n";
			# Add YearRequired in list if not in ListOfYears
			$ListOfYears{$YearRequired}||=$MonthRequired;
			foreach (sort keys %ListOfYears) { print "<option".($YearRequired eq "$_"?" selected=\"true\"":"")." value=\"$_\">$_</option>\n"; }
			print "</select>\n";
			print "<input type=\"submit\" value=\" Go \" class=\"aws_button\" />";
			print "</td></tr>\n";
            print "</form>\n";
            print "</table>\n";

			print "<table border width=\"100%\">\n";
			print "<tr $tb>";
			print "<td colspan=\"3\"><b>$text{'index_path'}</b></td>";
			print "<td width=80 bgcolor=#FFB055 align=center><b>$text{'viewall_u'}</b></td>";
			print "<td width=80 bgcolor=#F8E880 align=center><b>$text{'viewall_v'}</b></td>";
			print "<td width=80 bgcolor=#4477DD align=center><b>$text{'viewall_p'}</b></td>";
			print "<td width=80 bgcolor=#66F0FF align=center><b>$text{'viewall_h'}</b></td>";
			print "<td width=80 bgcolor=#2EA495 align=center><b>$text{'viewall_k'}</b></td>";
			print "<td width=\"".($BarWidth+5)."\">&nbsp;</td>";
			print "<td align=center><b>$text{'index_view'}</b></td>";
			print "</tr>\n";
		}

		my @st=stat($l);
		my $size = $st[7];
		my ($sec,$min,$hour,$day,$month,$year,$wday,$yday) = localtime($st[9]);
		$year+=1900; $month++;

        print '<div class="CTooltip" id="tt'.$nbofallowedconffound.'">';
        printf("Configuration file: <b>%s</b><br>\n",$l);
		printf("Created/Changed: <b>%04s-%02s-%02s %02s:%02s:%02s</b><br>\n",$year,$month,$day,$hour,$min,$sec);
        print "<br>\n";

		my @st2=stat($filedata);
        printf("Data file for period: <b>%s</b><br>\n",$filedata);
        printf("Data file size for period: <b>%s</b>".($st2[7]?" bytes":"")."<br>\n",($st2[7]?$st2[7]:"unknown"));
        printf("Data file version: <b>%s</b>",($version{$l}?" $version{$l}":"unknown")."<br>");
        printf("Last update: <b>%s</b>",($lastupdate{$l}?" $lastupdate{$l}":"unknown"));
        print '</div>';

		print "<tr $cb>\n";

		print "<td>$nbofallowedconffound</td>";
        print "<td align=\"center\" width=\"20\" onmouseover=\"ShowTip($nbofallowedconffound);\" onmouseout=\"HideTip($nbofallowedconffound);\"><img src=\"images/info.png\"></td>";
		print "<td>";
        print "$confwithoutdot";
		if ($access{'global'}) {	# Edit config
	    	print "<br><a href=\"edit_config.cgi?file=$l\">$text{'index_edit'}</a>";
		}
		print "</td>";

		if ($error{$l}) {
		    print "<td colspan=\"6\" align=\"center\">";
		    print "$error{$l}";
		    print "</td>";
		}
		elsif (! $foundendmap{$l}) {
		    print "<td colspan=\"6\">";
		    print "Unable to read summary info in data file. File may have been built by a too old AWStats version. File was built by version: $version{$l}.";
		    print "</td>";
		}
        else {
        	$total_u+=$view_u{$l};
        	$total_v+=$view_v{$l};
        	$total_p+=$view_p{$l};
        	$total_h+=$view_h{$l};
        	$total_k+=$view_k{$l};
    		print "<td align=\"right\" nowrap=\"1\">";
    		print Format_Number($view_u{$l});
    		print "</td>";
    		print "<td align=\"right\" nowrap=\"1\">";
    		print Format_Number($view_v{$l});
    		print "</td>";
    		print "<td align=\"right\" nowrap=\"1\">";
    		print Format_Number($view_p{$l});
    		print "</td>";
    		print "<td align=\"right\" nowrap=\"1\">";
    		print Format_Number($view_h{$l});
    		print "</td>";
    		print "<td align=\"right\" nowrap=\"1\">";
    		print Format_Bytes($view_k{$l});
    		print "</td>";
            # Print bargraph
            print '<td>';
			my $bredde_u=0; my $bredde_v=0; my $bredde_p=0; my $bredde_h=0; my $bredde_k=0; my $nobredde_p=0; my $nobredde_h=0; my $nobredde_k=0;
			if ($max_u > 0) { $bredde_u=int($BarWidth*($view_u{$l}||0)/$max_u)+1; }
			if ($max_v > 0) { $bredde_v=int($BarWidth*($view_v{$l}||0)/$max_v)+1; }
			if ($max_p > 0) { $bredde_p=int($BarWidth*($view_p{$l}||0)/$max_p)+1; }
			if ($max_h > 0) { $bredde_h=int($BarWidth*($view_h{$l}||0)/$max_h)+1; }
			if ($max_k > 0) { $bredde_k=int($BarWidth*($view_k{$l}||0)/$max_k)+1; }
			if ($nomax_p > 0) { $nobredde_p=int($BarWidth*($noview_p{$l}||0)/$nomax_p)+1; }
			if ($nomax_h > 0) { $nobredde_h=int($BarWidth*($noview_h{$l}||0)/$nomax_h)+1; }
			if ($nomax_k > 0) { $nobredde_k=int($BarWidth*($noview_k{$l}||0)/$nomax_k)+1; }
   			if (1) { print "<img src=\"images/hu.png\" width=\"$bredde_u\" height=\"$BarHeight\" /><br />"; }
   			if (1) { print "<img src=\"images/hv.png\" width=\"$bredde_v\" height=\"$BarHeight\" /><br />"; }
   			if (1) { print "<img src=\"images/hp.png\" width=\"$bredde_p\" height=\"$BarHeight\" /><br />"; }
   			if (1) { print "<img src=\"images/hh.png\" width=\"$bredde_h\" height=\"$BarHeight\" /><br />"; }
   			if (1) { print "<img src=\"images/hk.png\" width=\"$bredde_k\" height=\"$BarHeight\" /><br />"; }
            print '</td>';
        }

		if ($access{'view'}) {
			if ($config{'awstats_cgi'}) {
				print "<td align=center><a href='$config{'awstats_cgi'}?".($confwithoutdot?"config=$confwithoutdot":"").($dir?"&configdir=$dir":"")."' target=awstats>$text{'index_view2'}</a></td>\n";
			}
			else {
				print "<td align=center>".&text('index_cgi', "$gconfig{'webprefix'}/config.cgi?$module_name")."</td>";	
			}
		}
		else {
	        print "<td align=center>NA</td>";
		}

		print "</tr>\n";
	}

	if ($nbofallowedconffound > 0 && 1==2)
	{
		print "<tr $cb>\n";

		print "<td colspan=\"2\">&nbsp;</td>";
		print "<td>Total</td>";

		print "<td align=\"right\" nowrap=\"1\">";
		print Format_Number($total_u);
		print "</td>";
		print "<td align=\"right\" nowrap=\"1\">";
		print Format_Number($total_v);
		print "</td>";
		print "<td align=\"right\" nowrap=\"1\">";
		print Format_Number($total_p);
		print "</td>";
		print "<td align=\"right\" nowrap=\"1\">";
		print Format_Number($total_h);
		print "</td>";
		print "<td align=\"right\" nowrap=\"1\">";
		print Format_Bytes($total_k);
		print "</td>";
        # Print bargraph
        print '<td colspan="2">&nbsp;</td>';
		print "</tr>\n";		
	}

	print "</table><br>\n";
}

if (! $nbofallowedconffound) {
	print "<br><p><b>$text{'index_noconfig'}</b></p><br>\n";
}

# Back to config list
print "<hr>\n";
&footer("", $text{'index_return'});

#!/usr/bin/perl
# index.cgi
# Display available config files

require './awstats-lib.pl';


# Check if awstats is actually installed
if (!&has_command($config{'awstats'})) {
	&header($text{'index_title'}, "", undef, 1, 1, 0, undef);
	print "<hr>\n";
	print "<p>",&text('index_eawstats', "<tt>$config{'awstats'}</tt>","$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
	print "<hr>\n";
	&footer("/", $text{'index'});
	exit;
}

# Check AWStats URL
# TODO


# Get the version number
$out = `$config{'awstats'} 2>&1`;
if ($out !~ /^----- awstats (\S+)\.(\S+)\s(\S+\s\S+)/) {
	&header($text{'index_title'}, "", undef, 1, 1, 0, undef);

	if ($out =~ /^content-type/i) {
		# To old version. Does not support CLI launch from CGI_GATEWAY interface
		print "<p>",&text('index_eversion', "<tt>$config{'awstats'}</tt>", "5.7 or older", "5.8"),"<p>\n";
		print "<hr>\n";
		&footer("/", $text{'index'});
		exit;
	}

	print "<hr>\n";
	print "<p>",&text('index_egetversion', "<tt>$config{'awstats'}</tt>", "<pre>$out</pre>", "$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
	print "<hr>\n";
	&footer("/", $text{'index'});
	exit;
}

&header($text{'index_title'}, "", undef, 1, 1, 0, undef, undef, undef, &text('index_version', "$1.$2 $3"));

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
		var tooltipLft = (document.body.offsetWidth?document.body.offsetWidth:document.body.style.pixelWidth) - (tooltipOBJ.offsetWidth?tooltipOBJ.offsetWidth:(tooltipOBJ.style.pixelWidth?tooltipOBJ.style.pixelWidth:$widthtooltip)) - 30;
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
if ($1 < 5 || ($1 == 5 && $2 < 8)) {
	print "<p>",&text('index_eversion', "<tt>$config{'awstats'}</tt>", "$1.$2", "5.8"),"<p>\n";
	print "<hr>\n";
	&footer("/", $text{'index'});
	exit;
	}

# Check if sample file exists
if (!-r $config{'alt_conf'}) {
        print "<p>",&text('index_econf', "<tt>$config{'alt_conf'}</tt>",
                  "$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
        print "<hr>\n";
        &footer("/", $text{'index'});
        exit;
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

# Query apache and squid for their logfiles
%auto = map { $_, 1 } split(/,/, $config{'auto'});
if (&foreign_check("apache") && $auto{'apache'}) {
	&foreign_require("apache", "apache-lib.pl");
	$confapache = &apache::get_config();
	@dirs = ( &apache::find_all_directives($confapache, "CustomLog"),
		  &apache::find_all_directives($confapache, "TransferLog") );
	$root = &apache::find_directive_struct("ServerRoot", $confapache);
	foreach $d (@dirs) {
		local $lf = $d->{'words'}->[0];
		next if ($lf =~ /^\|/);
		if ($lf !~ /^\//) {
			$lf = "$root->{'words'}->[0]/$lf";
			}
		open(FILE, $lf);
		local $line = <FILE>;
		close(FILE);
		if (!$line || $line =~ /^([a-zA-Z0-9\.\-]+)\s+\S+\s+\S+\s+\[\d+\/[a-zA-z]+\/\d+:\d+:\d+:\d+\s+[0-9\+\-]+\]/) {
			push(@config, { 'file' => $lf,
				      'type' => 1 });
			}
		}
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
print &text('index_allowed',"<b>$remote_user</b>");
print ":<br>\n";
foreach my $dir (split(/\s/,$access{'dir'})) {
	print "$dir<br>"; 
}
print "<br>\n";
print &text('index_changeallowed',"<a href=\"/acl/\">Webmin - Webmin Users</a>", $text{'index_title'})."<br>\n";
print "<br>";

my $nbofallowedconffound=0;
if (scalar @config) {

	# Loop on each config file
	foreach my $l (@config) {
		next if (!&can_edit_config($l));
		$nbofallowedconffound++;


		# Head of config file's table list
		if ($nbofallowedconffound == 1) {

        	print "<a href='edit_config.cgi?new=1'>$text{'index_add'}</a><br><br>\n" if ($access{'add'});

            if (scalar @config >= 2 && $access{'view'}) {
        	    print "<a href='view_all.cgi?new=1'>$text{'index_viewall'}</a><br><br>\n";
            }
            
			print "<table border width=\"100%\">\n";
			print "<tr $tb>";
			print "<td rowspan=2 colspan=3><b>$text{'index_path'}</b></td>";
			print "<td rowspan=2 align=center><b>$text{'index_create'}</b></td>";
		 	print "<td colspan=2 align=center><b>$text{'index_update'}</b></td>";
			print "<td rowspan=2 align=center><b>$text{'index_view'}</b></td>";
			print "</tr>\n";
			print "<tr $tb><td align=center>$text{'index_scheduled'}</td><td align=center>$text{'index_now'}</td></tr>\n";
		}

		# Config file line
		#local @files = &all_config_files($l);
		#next if (!@files);
		local $lconf = &get_config($l);
		my $conf=""; my $dir="";
		if ($l =~ /awstats([^\\\/]*)\.conf$/) { $conf=$1; }
		if ($l =~ /^(.*)[\\\/][^\\\/]+$/) { $dir=$1; }
        my $confwithoutdot=$conf; $confwithoutdot =~ s/^\.+//;

		local ($size, $latest);
		local @st=stat($l);
		my ($sec,$min,$hour,$day,$month,$year,$wday,$yday) = localtime($st[9]);
		$year+=1900; $month++;

        print '<div class="CTooltip" id="tt'.$nbofallowedconffound.'">';
        printf("Configuration file: <b>%s</b><br>\n",$l);
		printf("Created/Changed: <b>%04s-%02s-%02s %02s:%02s:%02s</b><br>\n",$year,$month,$day,$hour,$min,$sec);
        print '</div>';

		print "<tr $cb>\n";

    	print "<td width=\"40\" align=\"center\">$nbofallowedconffound</td>";
        print "<td align=\"center\" width=\"20\" onmouseover=\"ShowTip($nbofallowedconffound);\" onmouseout=\"HideTip($nbofallowedconffound);\"><img src=\"images/info.png\"></td>";
		print "<td>";
		print "$confwithoutdot";
		if ($access{'global'}) {	# Edit config
	        print "<br><a href='edit_config.cgi?file=$l'>$text{'index_edit'}</a>\n";
		}
		print "</td>";

		printf("<td align=center>%04s-%02s-%02s %02s:%02s:%02s</td>",$year,$month,$day,$hour,$min,$sec);
	
		# Database size
		#print "<td>NA</td>";
		
		if ($access{'update'}) {	# Update
	        print "<td align=center><a href='schedule_stats.cgi?file=$l'>$text{'index_sched2'}</a></td>";
	        print "<td align=center><a href='update_stats.cgi?file=$l'>$text{'index_update2'}</a></td>\n";
		}
		else {
	        print "<td align=center>NA</td>";
	        print "<td align=center>NA</td>";
		}

#		print "<td>",$size > 10*1024*1024 ? int($size/1024/1024)." MB" :
#			     $size > 10*1024 ? int($size/1024)." KB" :
#			     $size ? "$size B" : $text{'index_empty'},"</td>\n";
#		print "<td>$latest</td>\n";
#		print "<td>",$lconf->{'sched'} ? $text{'yes'}
#					       : $text{'no'},"</td>\n";
#		if ($lconf->{'dir'} && -r "$lconf->{'dir'}/index.html") {

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
	
	if ($nbofallowedconffound > 0) { print "</table><br>\n"; }
}

if (! $nbofallowedconffound) {
	print "<br><p><b>$text{'index_noconfig'}</b></p><br>\n";
}


print "<hr>\n";
&footer("/", $text{'index'});


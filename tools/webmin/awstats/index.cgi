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
if ($out !~ /----- awstats (\S+)\.(\S+)\s(\S+\s\S+)/) {
	&header($text{'index_title'}, "", undef, 1, 1, 0, undef);

	print "<hr>\n";
	print "<p>",&text('index_egetversion',
			  "<tt>$config{'awstats'}</tt>",
			  "<pre>$out</pre>",
			  "$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
	print "<hr>\n";
	&footer("/", $text{'index'});
	exit;
}

&header($text{'index_title'}, "", undef, 1, 1, 0, undef, undef, undef, &text('index_version', "$1.$2 $3"));
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
if (!-r $config{'awstats_conf'}) {
	print "<p>",&text('index_econfdir', "<tt>$config{'awstats_conf'}</tt>",
		  "$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
	print "<hr>\n";
	&footer("/", $text{'index'});
	exit;
	}

# Query apache and squid for their logfiles
%auto = map { $_, 1 } split(/,/, $config{'auto'});
if (&foreign_check("apache") && $auto{'apache'}) {
	&foreign_require("apache", "apache-lib.pl");
	$conf = &apache::get_config();
	@dirs = ( &apache::find_all_directives($conf, "CustomLog"),
		  &apache::find_all_directives($conf, "TransferLog") );
	$root = &apache::find_directive_struct("ServerRoot", $conf);
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

# Add custom configfiles
push(@config, map { $_->{'custom'} = 1; $_ } &scan_config_dir());

print "Your user is allowed to view/edit config files into (or that are links to) ".$access{'dir'}.".<br><br>";  
if (@config) {
	print "<a href='edit_config.cgi?new=1'>$text{'index_add'}</a>\n"
		if ($access{'add'});
	print "<table border width=100%>\n";
	print "<tr $tb> <td><b>$text{'index_path'}</b></td> ",
	      "<td><b>$text{'index_create'}</b></td> ",
	      "<td><b>$text{'index_edit'}</b></td> ",
 	      "<td><b>$text{'index_update'}</b></td> ",
	      "<td><b>$text{'index_view'}</b></td> </tr>\n";
	foreach my $l (@config) {
		next if (!&can_edit_config($l));
		local @files = &all_config_files($l);
		next if (!@files);
		local $lconf = &get_config($l);
		print "<tr $cb>\n";

		local ($size, $latest);
#		foreach $f (@files) {
#			local @st = stat($f);
#			$size += $st[7];
#			$latest = $st[9] if ($st[9] > $latest);
#			}
#		$latest = $latest ? localtime($latest) : "<br>";

		print "<td>$l</td>";
		local @st=stat($l);
		print "<td>".make_date($st[10])."</td>";

                my $conf=""; my $dir="";
                if ($l =~ /awstats\.(.*)\.conf$/) { $conf=$1; }
                if ($l =~ /^(.*)[\\\/][^\\\/]+$/) { $dir=$1; }

                if ($access{'global'}) {
                        print "<td><a href='edit_config.cgi?file=$l'>$text{'index_edit'}</a></td>\n";
                }
		else {
                        print "<td>&nbsp;</td>\n";
                }

               	if ($access{'update'}) {
                        print "<td><a href='update_stats.cgi?file=$l'>$text{'index_update'}</a></td>\n";
                }
		else {
                        print "<td>&nbsp;</td>\n";
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
				print "<td><a href='$config{'awstats_cgi'}?".($conf?"config=$conf":"").($dir?"&configdir=$dir":"")."' target=awstats>$text{'index_view'}</a></td>\n";
			}
			else {
				print "<td>".&text('index_cgi', "$gconfig{'webprefix'}/config.cgi?$module_name")."</td>";	
			}
		}
		else {
			print "<td>&nbsp;</td>\n";
		}
		print "</tr>\n";
		}
	print "</table>\n";
}
else {
	print "<p><b>$text{'index_noconfig'}</b><p>\n";
}

print "<a href='edit_config.cgi?new=1'>$text{'index_add'}</a><br>\n" if ($access{'add'});


print "<hr>\n";
&footer("/", $text{'index'});


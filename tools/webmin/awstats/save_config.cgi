#!/usr/bin/perl
# save_config.cgi
# Save, create or delete options for a config file

require './awstats-lib.pl';
&foreign_require("cron", "cron-lib.pl");
&ReadParse();

&error_setup($text{'save_err'});

if (! $in{'file'}) { $in{'file'}=$in{'new'}; }
if ($in{'new'} && ! $access{'add'}) { &error($text{'edit_ecannot'}); }
if (! $in{'new'} && $access{'edit'}) { &error($text{'edit_ecannot'}); }


if ($in{'view'}) {
	my $dir=$in{'file'}; $dir =~ s/[\\\/][^\\\/]+$//;
	if (! $dir) { $dir="/etc/awstats"; }
	&can_edit_config($in{'file'}) || &error($text{'edit_efilecannot'}." ".$in{'file'});

	# Re-direct to the view page
	&redirect("view_config.cgi/".&urlize(&urlize($in{'file'}))."/index.html");
	}
elsif ($in{'delete'}) {
	my $dir=$in{'file'}; $dir =~ s/[\\\/][^\\\/]+$//;
	if (! $dir) { $dir="/etc/awstats"; }
	&can_edit_config($in{'file'}) || &error($text{'edit_efilecannot'}." ".$in{'file'});

	# Delete this config file from the configuration
	local $cfile = $in{'file'};
	&lock_file($cfile);
	unlink($cfile);
	&unlock_file($cfile);
	&webmin_log("delete", "log", $in{'file'});

	# Create or delete the cron job
#		&lock_file($job->{'file'});
#		&foreign_call("cron", "delete_cron_job", $job);
#		&unlock_file($job->{'file'});

	}
else {
	# Validate and store inputs
	if (!$in{'new'} && !$in{'file'}) { &error($text{'save_efile'}); }

	my $dir=$in{'file'}; $dir =~ s/[\\\/][^\\\/]+$//;
	if (! $dir) { $dir="/etc/awstats"; }
	if (! &can_edit_config($dir)) {
		&error(&text('save_edir',"$dir")."<br>\n".&text('index_changeallowed',"Menu <a href=\"/acl/\">Webmin - Utilisateurs Webmin</a> puis clic sur $text{'index_title'}")."<br>\n");
	}

	if ($in{'new'} && -r $in{'$file'}) { &error($text{'save_fileexists'}); }
	if (! -d $dir) { &error($text{'save_dirnotexists'}); }

	%conf=();
	foreach my $key (keys %in) {
		if ($key eq 'file') { next; }
                if ($key eq 'new') { next; }
                if ($key eq 'submit') { next; }
		if ($key eq 'oldfile') { next; }
		$conf{$key} = $in{$key};
		if ($conf{key} ne ' ') {
			$conf{$key} =~ s/^\s+//;
			$conf{$key} =~ s/\s+$//;
		}
	}
	if ($conf{'LogSeparator'} eq '') { $conf{'LogSeparator'}=' '; }

	# Check data
	my $logfile='';
	if ($conf{'LogFile'} !~ /|\s*$/) {	# LogFile is not a piped valued
		$logfile=$conf{'LogFile'};
	}
	else {								# LogFile is piped
		# It can be
		# '/xxx/maillogconvert.pl standard /aaa/mail.log |'
		# '/xxx/logresolvermerge.pl *'

		# TODO test something here ?
	}
	if ($logfile && ! -r $logfile)	{ &error(&text(save_errLogFile,$logfile)); }
	if (! $conf{'SiteDomain'}) 		{ &error(&text(save_errSiteDomain,$conf{'SiteDomain'})); }
	if (! -d $conf{'DirData'}) 		{ &error(&text(save_errDirData,$conf{'DirData'})); }

	if ($in{'new'}) {
		# Add a new config file to the configuration
		&system_logged("cp '$config{'alt_conf'}' '$in{'new'}'");
	}
	
	# Update the config file's options
	local $cfile = $in{'file'};
	&lock_file($cfile);
	&update_config($cfile, \%conf);
	&unlock_file($cfile);
	&webmin_log($in{'new'} ? "create" : "modify", "log", $in{'file'});
	}

&redirect("");


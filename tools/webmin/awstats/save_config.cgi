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

&can_edit_config($in{'file'}) || &error($text{'edit_efilecannot'}." ".$in{'file'});


if ($in{'view'}) {
	# Re-direct to the view page
	&redirect("view_config.cgi/".&urlize(&urlize($in{'file'}))."/index.html");
	}
elsif ($in{'delete'}) {
	# Delete this config file from the configuration
	local $cfile = $in{'file'};
	&lock_file($cfile);
	unlink($cfile);
	&unlock_file($cfile);
	&webmin_log("delete", "log", $in{'file'});
	}
else {
	# Validate and store inputs
	if (!$in{'new'} && !$in{'file'}) { &error($text{'save_efile'}); }
	if ($in{'new'} && -r $in{'$file'}) { &error($text{'save_fileexists'}); }
	my $dir=$in{'file'}; $dir =~ s/[\\\/][^\\\/]+$//;
	if (! $dir) { $dir=$config{'awstats_conf'}; }

	if (! -d $dir) { &error($text{'save_edir'}); }
	$in{'cmode'} != 2 || -r $in{'cfile'} || &error($text{'save_ecfile'});

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
	if (! -r $conf{'LogFile'}) { &error(&text(save_errLogFile,$conf{'LogFile'})); }
	if (! $conf{'SiteDomain'}) { &error(&text(save_errSiteDomain,$conf{'SiteDomain'})); }
	if (! -d $conf{'DirData'}) { &error(&text(save_errDirData,$conf{'DirData'})); }

#	if ($access{'user'} eq '*') {
#		# Set the user to whatever was entered
#		defined(getpwnam($in{'user'})) || &error($text{'save_euser'});
#		$lconf->{'user'} = $in{'user'};
#		}
#	elsif (!$in{'new'} && $lconf->{'dir'}) {
#		# This is not a new config, so the user cannot be changed
#		}
#	elsif ($access{'user'} eq '') {
#		# This is a new log, or one that has not been saved for
#		# the first time yet. Use the webmin user as the user
#		defined(getpwnam($remote_user)) ||
#			&error(&text('save_ewuser', $remote_user));
#		$lconf->{'user'} = $remote_user;
#		}
#	else {
#		# This is a new log, or one that has not been saved for
#		# the first time yet. Use the user set in the ACL
#		$lconf->{'user'} = $access{'user'};
#		}
#	$lconf->{'type'} = $in{'type'};
#	$lconf->{'over'} = $in{'over'};
#	&cron::parse_times_input($lconf, \%in);

	# Create or delete the cron job
#	local $oldjob = $job;
#	if ($lconf->{'sched'}) {
#		# Create cron job and script
#		$job->{'user'} = 'root';
#		$job->{'active'} = 1;
#		$job->{'mins'} = $lconf->{'mins'};
#		$job->{'hours'} = $lconf->{'hours'};
#		$job->{'days'} = $lconf->{'days'};
#		$job->{'months'} = $lconf->{'months'};
#		$job->{'weekdays'} = $lconf->{'weekdays'};
#		$job->{'command'} = "$cron_cmd $in{'file'}";
#		open(PERL, "$config_directory/perl-path");
#		chop($perl_path = <PERL>);
#		close(PERL);
#		&lock_file($cron_cmd);
#		open(CMD, ">$cron_cmd");
#		print CMD <<EOF;
#!$perl_path
#open(CONF, "$config_directory/miniserv.conf");
#while(<CONF>) {
#	\$root = \$1 if (/^root=(.*)/);
#	}
#close(CONF);
#\$ENV{'WEBMIN_CONFIG'} = "$ENV{'WEBMIN_CONFIG'}";
#\$ENV{'WEBMIN_VAR'} = "$ENV{'WEBMIN_VAR'}";
#chdir("\$root/$module_name");
#exec("\$root/$module_name/awstats.pl", \$ARGV[0]);
#EOF
#		close(CMD);
#		chmod(0755, $cron_cmd);
#		&unlock_file($cron_cmd);
#		}
#	if ($lconf->{'sched'} && !$oldjob) {
#		# Create the cron job
#		local %cconfig = &foreign_config("cron");
#		local $ctab = "$cconfig{'cron_dir'}/root";
#		&lock_file($ctab);
#		&foreign_call("cron", "create_cron_job", $job); 
#		&unlock_file($ctab);
#		}
#	elsif ($lconf->{'sched'} && $oldjob) {
#		# Update the cron job
#		&lock_file($job->{'file'});
#		&foreign_call("cron", "change_cron_job", $job); 
#		&unlock_file($job->{'file'});
#		}
#	elsif (!$lconf->{'sched'} && $oldjob) {
#		# Delete the cron job
#		&lock_file($job->{'file'});
#		&foreign_call("cron", "delete_cron_job", $job);
#		&unlock_file($job->{'file'});
#		}

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


# awstats-lib.pl
# Common functions for editing the awstats config file

do '../web-lib.pl';
require '../javascript-lib.pl'; 
&init_config();

#$config{'awstats'}||='/usr/local/awstats/wwwroot/cgi-bin/awstats.pl';
$config{'awstats_conf'}||='/etc/awstats';
$config{'alt_conf'}||='/etc/awstats/awstats.model.conf';

$ENV{'AWSTATS_DEL_GATEWAY_INTERFACE'}=1;

$cron_cmd = "$module_config_directory/awstats.pl";
%access = &get_module_acl();


# Show help tooltip
sub hblink
{
	my $t=shift;
	my $url=shift;
	print "<a href=\"javascript:neww('$url');\">$t</a>";
}


# update_config($configfile,%conf)
# Update the awstats config file
sub update_config
{
my ($file,$conf)=@_;
if (! $file) { error("Call to update_config with wrong parameter"); }

open(FILE, $file) || error("Failed to open $file for update");
open(FILETMP, ">$file.tmp") || error("Failed to open $file.tmp for writing");

# $%conf contains param and values
my %confchanged=();
my $conflinenb = 0;

# First, change values that are already present in old config file
while(<FILE>) {
	my $savline=$_;

	chomp $_; s/\r//;
	$conflinenb++;

	# Remove comments not at beginning of line
	$_ =~ s/\s#.*$//;

	# Extract param and value
	my ($param,$value)=split(/=/,$_,2);
	$param =~ s/^\s+//; $param =~ s/\s+$//;
	$value =~ s/#.*$//; 
	$value =~ s/^[\s\'\"]+//; $value =~ s/[\s\'\"]+$//;

	if ($param) {
		# cleanparam is param without begining #
		my $cleanparam=$param; my $wascleaned=0;
		if ($cleanparam =~ s/^#//) { $wascleaned=1; }
		if ($cleanparam !~ /LoadPlugin/i && defined($conf->{$cleanparam})) {
			# Value was provided from submit form in %conf hash array so we change line with this new value
			$savline = "$cleanparam=\"".($conf->{$cleanparam})."\"\n";
			$confchanged{$cleanparam}=1;
		}
		if ($cleanparam =~ /^LoadPlugin/i && $conf->{"advanced"} == 4) {
			# It's a plugin load directive
			my ($pluginname,$pluginparam)=split(/\s/,$value,2);
			if ($conf->{"plugin_$pluginname"}) {	# Plugin loaded is asked
				$savline = "$cleanparam=\"$pluginname".($conf->{"plugin_param_$pluginname"}?" ".$conf->{"plugin_param_$pluginname"}:"")."\"\n";
			} else {								# Plugin loaded is not asked
				$savline = "#$cleanparam=\"$pluginname".($conf->{"plugin_param_$pluginname"}?" ".$conf->{"plugin_param_$pluginname"}:"")."\"\n";
			}
			$confchanged{"plugin_$pluginname"}=1;
		}
	}
	# Write line
	print FILETMP "$savline";	
}

# Now add values for directives that were not present in old config file
foreach my $key (keys %$conf) {
	if ($key eq 'advanced') { next; }	# param to know if plugin setup section was opened
	if ($key =~ /^plugin_/) { next; }	# field from plugin section, not an awstats directive
	if ($confchanged{$key}) { next; }	# awstats directive already changed
	print FILETMP "\n";
	print FILETMP "# Param $key added by AWStats Webmin module\n";
	print FILETMP "$key=\"$conf->{$key}\"\n";
}

# Now add plugin load that were not already present in old config file
foreach my $key (keys %$conf) {
	my $pluginname = $key; 
	if ($pluginname !~ s/^plugin_//) { next; }			# not a plugin load row
	if ($pluginname =~ /^param_/) { next; }				# not a plugin load row
	if ($confchanged{"plugin_$pluginname"}) { next; }	# awstats directive or load plugin already changed
	print FILETMP "\n";
	print FILETMP "# Plugin load for plugin $pluginname added by AWStats Webmin module\n";
	print FILETMP "LoadPlugin=\"$pluginname".($conf->{"plugin_param_$pluginname"}?" ".$conf->{"plugin_param_$pluginname"}:"")."\"\n";
}

close(FILE);
close(FILETMP);

# Move file to file.sav
if (rename("$file","$file.old")==0) {
	error("Failed to make backup of current config file to $file.old");
}

# Move tmp file into config file
if (rename("$file.tmp","$file")==0) {
	error("Failed to move tmp config file $file.tmp to $file");
}


return 0;
}

# save_directive(&config, name, [value]*)
sub save_directive
{
local ($conf, $name, @values) = @_;
local @old = &find($name, $conf);
local $lref = &read_file_lines($conf->[0]->{'file'});
local $i;
for($i=0; $i<@old || $i<@values; $i++) {
	if ($i < @old && $i < @values) {
		# Just replacing a line
		$lref->[$old[$i]->{'line'}] = "$name $values[$i]";
		}
	elsif ($i < @old) {
		# Deleting a line
		splice(@$lref, $old[$i]->{'line'}, 1);
		&renumber($conf, $old[$i]->{'line'}, -1);
		}
	elsif ($i < @values) {
		# Adding a line
		if (@old) {
			# after the last one of the same type
			splice(@$lref, $old[$#old]->{'line'}+1, 0,
			       "$name $values[$i]");
			&renumber($conf, $old[$#old]->{'line'}+1, 1);
			}
		else {
			# at end of file
			push(@$lref, "$name $values[$i]");
			}
		}
	}
}

# renumber(&config, line, offset)
sub renumber
{
foreach $c (@{$_[0]}) {
	$c->{'line'} += $_[2] if ($c->{'line'} >= $_[1]);
	}
}

# temp_file_name(file)
sub temp_file_name
{
local $p = $_[0];
$p =~ s/^\///;
$p =~ s/\//_/g;
return "$module_config_directory/$p.tmp";
}

# find(name, &config)
sub find
{
local @rv;
foreach $c (@{$_[1]}) {
	push(@rv, $c) if (lc($c->{'name'}) eq lc($_[0]));
	}
return wantarray ? @rv : $rv[0];
}

# find_value(name, &config)
sub find_value
{
local @rv = map { $_->{'value'} } &find(@_);
return wantarray ? @rv : $rv[0];
}

# all_config_files(file)
sub all_config_files
{
$_[0] =~ /^(.*)\/([^\/]+)$/;
local $dir = $1;
local $base = $2;
local ($f, @rv);
opendir(DIR, $dir);
foreach $f (readdir(DIR)) {
	if ($f =~ /^\Q$base\E/ && -f "$dir/$f") {
		push(@rv, "$dir/$f");
		}
	}
closedir(DIR);
return @rv;
}

# get_config(path)
# Get the configuration for some log file
sub get_config
{
local %rv;
&read_file($_[0], \%rv) || return undef;
return \%rv;
}

# generate_report_as_pdf(file, handle, escape)
sub generate_report_as_pdf
{
local $h = $_[1];
local $lconf = &get_config($_[0]);
local @all = &all_config_files($_[0]);
if (!@all) {
	print $h "Log file $_[0] does not exist\n";
	return;
	}
local ($a, %mtime);
foreach $a (@all) {
	local @st = stat($a);
	$mtime{$a} = $st[9];
	}
local $type = $lconf->{'type'} == 1 ? "" :
	      $lconf->{'type'} == 2 ? "-F squid" :
	      $lconf->{'type'} == 3 ? "-F ftp" : "";
local $cfile = &temp_file_name($_[0]);
local $conf = -r $cfile ? "-c $cfile" : "";
if ($lconf->{'over'}) {
	unlink("$lconf->{'dir'}/awstats.current");
	unlink("$lconf->{'dir'}/awstats.hist");
	}
local $user = $lconf->{'user'} || "root";
if ($user ne "root" && -r $cfile) {
	chmod(0644, $cfile);
	}
foreach $a (sort { $mtime{$a} <=> $mtime{$b} } @all) {
	local $cmd = "$config{'awstats'} $conf -o '$lconf->{'dir'}' $type -p '$a'";
	if ($user ne "root") {
		$cmd = "su \"$user\" -c \"$cmd\"";
		}
	open(OUT, "$cmd 2>&1 |");
	while(<OUT>) {
		print $h $_[2] ? &html_escape($_) : $_;
		}
	close(OUT);
	return 0 if ($?);
	&additional_config("exec", undef, $cmd);
	}
return 1;
}

# spaced_buttons(button, ...)
sub spaced_buttons
{
local $pc = int(100 / scalar(@_));
print "<table width=100%><tr>\n";
foreach $b (@_) {
	local $al = $b eq $_[0] && scalar(@_) != 1 ? "align=left" : $b eq $_[@_-1] && scalar(@_) != 1 ? "align=right" : "align=center";
	print "<td width=$pc% $al>$b</td>\n";
	}
print "</tr>\n";
print "</table>\n";
}

# scan_config_dir()
sub scan_config_dir
{
# Scan directory $DIRCONFIG
opendir(DIR, $config{'awstats_conf'}) || die "Can't scan directory $DIRCONFIG";
local @rv = grep { /^awstats\.(.*)conf$/ } sort readdir(DIR);
closedir(DIR);
foreach my $file (0..@rv-1) {
	if ($rv[$file] eq 'awstats.model.conf') { next; }
	$rv[$file]="$config{'awstats_conf'}/".$rv[$file];
	#print "$rv[0]\n<br>";
}
return @rv;
}

# can_edit_config(file)
sub can_edit_config
{
foreach $d (split(/\s+/, $access{'dir'})) {
	local $ok = &is_under_directory($d, $_[0]);
	return 1 if ($ok);
	}
return 0;
}



1;


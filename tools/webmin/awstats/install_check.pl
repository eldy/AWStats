# install_check.pl

do 'awstats-lib.pl';

# is_installed(mode)
# For mode 1, returns 2 if AWStats is installed and configured for use by
# Webmin, 1 if installed but not configured, or 0 otherwise.
# For mode 0, returns 1 if installed, 0 if not
sub is_installed
{
if (! -r $config{'awstats'}) { return 0; }

if ($_[0]) { 
	if (-r $config{'alt_conf'}) { return 2; }
}

return 1;
}


 
------------- AWStats --------------
     Advanced Web Statistics
------------------------------------

Advanced Web Statistics (AWStats) is a powerfull web server logfile analyzer
that shows you all your Web statistics including visitors, pages, hits, hours,
search engines, keywords used to find your site, broken links, robots and
more. It works with IIS 5.0+, Apache and other web/wap/proxy server log files.

License: GNU GPL (GNU General Public License. See COPYING.TXT)
Version : 3.2
Release date: 20 October 2001
Platforms: All (Linux, NT, SCO, BSD, Solaris and other *NIX's, BeOS, OS/2...)
Author: Laurent Destailleur <eldy@users.sourceforge.net>
AWStats web site: http://awstats.sourceforge.net
 
I   - Features and requirements of AWStats
      I - 1) Features, what AWStats can show you
      I - 2) Requirements for using AWStats
      I - 3) Files
II  - How to install and use AWStats
      II - 1) With Apache server
      II - 2) With IIS 5.0+
III - Benchmark
IV  - Troubleshooting / FAQ
V   - About the author, license and support



I - FEATURES AND REQUIREMENTS
------------------------------------

I - 1) Features

    A full log analysis enables AWStats to show you the following information:
    * Number of VISITS and UNIQUE VISITORS, list of last visitors,
    * Days of week and rush hours (pages, hits, kb for each day and hour),
    * Domains/countries of hosts visitors (pages, hits, kb),
    * Authenticated users,
    * Most often pages viewed,
	* File types,
	* Web compression statistics (for mod_gzip),
    * Browsers used (pages, hits, kb for each browser),
    * OS used (pages, hits, kb for each OS),
    * VISITS OF ROBOTS,
    * SEARCH ENGINES, KEYPHRASES or KEYWORDS used to find your site,
    * HTTP errors (Page not found, ...).

    It supports the following features as well:
	* Can analyze all log formats.
    * Works from command line or as a CGI,
    * Update of statistics can be made on demand from the web interface and
      not only from your scheduler,
	* Unlimited log file size, support splited log files,
	* Reverse DNS lookup during analysis,
    * A lot of options/filters can be defined,
    * Multi-named web sites supported (virtual servers),
	* Cross Site Scripting Attacks protection,
    * Several languages. English, French, Dutch, Spanish, Italian, German,
      Polish, Greek, Czech, Portuguese, Chinese, Korean...
    * No need of extra perl libraries,
	* Look and colors can match your site design,
    * Help on how AWStats work, tooltips on HTML reporting page,
    * Easy to install, easy to use (No compilation, no extern databases),
    * Free (GNU GPL) and distributed with sources (perl script).


I - 2) Requirements

    To use AWStats CGI script, you need the following requirements:
    * Your Web server must be able to log web access in "NCSA combined logfile
      format" like Apache or in "Extended W3C logfile format" like IIS 5.0+
    * You need to have read (better if read/write) access to your logfile
      server. If you can have only a read access, for example with IIS that
      doesn't allow write access on its lofgile, AWStats will automatically
      work differently, but slower than with read/write access).
    * To run awstats, from command line, your operating system must be able to
      run perl scripts (.pl files). To run awstats as a CGI (for real-time
      statistics), your web server must also be able to run such scripts.
      If not, you can solve this by downloading last Perl version at:
      http://www.activestate.com/ActivePerl/ (Win32)
      http://www.perl.com/pub/language/info/software.html (Unix/Linux/Other)


I - 3) Files

    The distribution of AWStats package includes the following files:
    README.TXT                           This file
    INSTALL.TXT                          Same as README.txt
    COPYING.TXT                          GNU General Public Licence
    wwwroot/cgi-bin/awstats.pl           The main command line/CGI perl script
    wwwroot/cgi-bin/awstats.model.conf   An example of AWStats configure file
 	wwwroot/cgi-bin/db                   Directory with awstats reference info
 	wwwroot/cgi-bin/lang                 Directory with languages files
    wwwroot/icon/browser                 Directory with browsers icons
    wwwroot/icon/clock                   Directory with clocks icons
    wwwroot/icon/cpu                     Directory with cpu icons
    wwwroot/icon/flags                   Directory with country flags icons
    wwwroot/icon/os                      Directory with os icons
    wwwroot/icon/other                   Directory with all others icons


II - HOW TO INSTALL AND USE AWSTATS
-----------------------------------

II - 1) With Apache Server (on Unix/Linux or Windows)

    * Configure your apache web server to have "combined" log format.
      You can do this by changing, in httpd.conf, following directives:
      CustomLog /yourlogpath/yourlogfile common
        into
      CustomLog /yourlogpath/yourlogfile combined
      See your apache manual for more information.
      Stop Apache, remove old log files and restart Apache.
      This is an example of records you should get in new log file:
      62.161.78.73 - - [dd/mmm/yyyy:hh:mm:ss +0000] "GET / HTTP/1.1" 200 1234 "http://www.from.com/from.htm" "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"

	* Copy all the content of provided AWStats cgi-bin directory into your web
	  server cgi-bin directory (this includes awstats.pl, awstats.model.conf,
	  logresolvemerge.pl and the lang and db sub-directories).
	
    * If necessary, in awstats.pl file, edit the first line
      #!/usr/bin/perl
      to reflect the path were your perl interpreter is installed.
      Default value works for most of Unix OS, but it also might be
      #!/usr/local/bin/perl
      With Apache for Windows and Activeperl interpreter, it might be
      #!c:/program files/activeperl/bin/perl

    * Move all awstats icon sub-directories into a directory readable by your
      web server, for example /yourwwwroot/icon or /yourwwwroot/icons.

    * Copy awstats.model.conf into awstats.virtualhostname.conf or awstats.conf
      (when you will run AWStats, it will first look for a config file named
      awstats.virtualhostname.conf, and, if not found, will look for
      awstats.conf).
      Whatever the name you choose, this new file must be stored in
      - /etc/opt/awstats or /etc/awstats or /etc for unix/linux users.
      - same directory than awstats.pl (so cgi-bin) for Windows and other OS.
      Edit this new config file with your own setup :
      - Change "LogFile" value with full path of your web server log file (You
        can also use a relative path from your awstats.pl directory).
      - Check if "LogFormat" has the value "1" (it means "NCSA apache
        combined/ELF/XLF log format").
      - Change "DirIcons" parameter to reflect relative URL of icon directory.
      - Edit "SiteDomain" parameter with the main domain name or the intranet
        web server name used to reach the web site to analyze.
      - You can change other parameters if you want.

	SETUP IS FINISHED
	
    * To update statistics, launch awstats.pl from the command line interface
      like this (the first time, process may be long) :
        awstats.pl -config=virtualhostname -update
      AWStats will read the config file (awstats.virtualhostname.conf, or, if
      not found, awstats.conf) and create/update database where AWStats store
      all summary information issued from analyzed log files.
      A log analysis process is slow (one second for each 1300 lines of your
      logfile with Athlon 1Ghz, plus DNS resolution time for each different IP
      address in your logfile if DNSLookup=1).

    * Add instructions in your crontab (Unix/Linux) or your scheduler (for
      Windows), to launch frequently this Awstats update process.
      For sites with:
      - 10,000 visitors a month     Launch AWStats every day
      - 50,000 visitors a month     Launch AWStats every 4 hours
      - 250,000 visitors a month    Launch AWStats every hour
      - 1,000,000 visitors a month  Launch AWStats every hour
      This is ABSOLUTELY necessary to keep good performances. See AWStats FAQ
      page (benchmark question) for more accurate information.

    * To see results of analyze, you can build a HTML report from the command
      line, like this :
        awstats.pl -config=virtualhostname -output > result.html
      Or, you can view dynamically your statistics from a browser. For this,
      if you named your config file awstats.conf, just use URL:
        http://www.myserver.mydomain/cgi-bin/awstats.pl
      If you named your config file awstats.virtualhostname.conf, use URL:
        http://www.myserver.mydomain/cgi-bin/awstats.pl?config=virtualhost
      where virtualhostname is used to know which config file to use (AWStats
      will use awstats.virtualhostname.conf file).


II - 2) With IIS Server

    * Configure IIS to log in "Extended W3C log format" (You can still use
      your own log format but setup is easier if made like suggested). So, for
      this, start the IIS Snap-in, select the web site and look at its
      Properties. Choose W3C Extended Log Format, then Properties, then the
      Tab Extended Properties and uncheck everything under Extended Properties.
      Once they are all unchecked, check all following fields:
      date
      time
      c-ip
      cs-username
      cs-method
      cs-uri-stem
      sc-status
      sc-bytes
      cs-version
      cs(User-Agent)
      cs(Referer)
      Stop IIS, remove old log files and restart IIS.
      This is an example of records you should get in new log file:
      2000-07-19 14:14:14 62.161.78.73 - GET / 200 1234 HTTP/1.1 Mozilla/4.0+(compatible;+MSIE+5.01;+Windows+NT+5.0) http://www.from.com/from.htm

	* Copy all the content of provided AWStats cgi-bin directory into your web
	  server cgi-bin directory (this includes awstats.pl, awstats.model.conf,
	  logresolvemerge.pl and the lang and db sub-directories).
	
    * Move all awstats icon sub-directories into a directory readable by your
      web server, for example C:\yourwwwroot\icon.

    * Copy awstats.model.conf into awstats.virtualhostname.conf or awstats.conf
      (when you will run AWStats, it will first look for a config file named
      awstats.virtualhostname.conf, and, if not found, will look for
      awstats.conf).
      Whatever the name you choose, this new file must be stored in
      - same directory than awstats.pl (so cgi-bin)
      Edit this new config file with your own setup :
      - Change "LogFile" value with full path of your web server log file (You
        can also use a relative path from your awstats.pl directory).
      - Change "LogFormat" to value "2" (it means "IIS W3C log format").
      - Change "DirIcons" parameter to reflect relative URL of icon directory.
      - Edit "SiteDomain" parameter with the main domain name or the intranet
        web server name used to reach the web site to analyze.
      - You can change other parameters if you want.

	SETUP IS FINISHED
	
    * To update statistics, launch awstats.pl from the command line interface
      like this (the first time, process may be long) :
        awstats.pl -config=virtualhostname -update
      AWStats will read the config file (awstats.virtualhostname.conf, or, if
      not found, awstats.conf) and create/update database where AWStats store
      all summary information issued from analyzed log files.
      A log analysis process is slow (one second for each 1300 lines of your
      logfile with Athlon 1Ghz, plus DNS resolution time for each different IP
      address in your logfile if DNSLookup=1).

    * Add instructions in a task scheduler to launch frequently this Awstats
      update process.
      For sites with:
      - 10,000 visitors a month     Launch AWStats every day
      - 50,000 visitors a month     Launch AWStats every 4 hours
      - 250,000 visitors a month    Launch AWStats every hour
      - 1,000,000 visitors a month  Launch AWStats every hour
      This is ABSOLUTELY necessary to keep good performances. See AWStats FAQ
      page (benchmark question) for more accurate information.

      !!! Warning, with IIS, Windows doesn't let AWStats to purge log file
      after processing it, so it's very important you purge/rotate your log
      file yourself (or setup IIS to do it).
      The more often you clean your log file, the more faster AWStats will be.
      See AWStats FAQ (benchmark question) for more accurate information.

    * To see results of analyze, you can build a HTML report from the command
      line, like this :
        awstats.pl -config=virtualhostname -output > result.html
      Or, you can view dynamically your statistics from a browser. For this,
      if you named your config file awstats.conf, just use URL:
        http://www.myserver.mydomain/cgi-bin/awstats.pl
      If you named your config file awstats.virtualhostname.conf, use URL:
        http://www.myserver.mydomain/cgi-bin/awstats.pl?config=virtualhostname
      where virtualhostname is used to know which config file to use (AWStats
      will use awstats.virtualhostname.conf file).



III - BENCHMARK
-----------------------------------

This is benchmark results with AWStats version 3.2:
CONFIG: Athlon 1 GHz / Windows 2000 / ActivePerl 5.6 / LogFormat=1
SPEED: 20000 lines in 10s with reverse DNS lookup disabled
AVERAGE: 2000 lines by seconds

However, benchmarks of log analyzer are made without reverse DNS lookup
because this depends on your system, networks and Internet and not on the
log analyzer you use. But, the reverse DNS lookup can take 95% of the time
of a log analysis.
So, have a look on AWStats FAQs ("Benchmark" question) to:
- Get more real ideas on benchmarks results
- Get more information and advice on a good setup for your site.

This is a summary of main ways to speed up AWStats:
* You can disable DNSLookup in AWStats (set DNSLookup=0) but this requires
that hosts addresses in your log file are already resolved (need to setup your
web server to do so). Speed can be increased up by 2 to 50 times !
* If you use Apache, set PurgeLogFile to 1 (By default, to avoid bad surprise,
PurgeLogFile is 0 in configure file, but you can set it to 1 to ask AWStats
to purge log file after processing it, this increase speed for next run).
* Launch AWStats more often (from crontab or a scheduler). The more often you
launch AWStats, the less AWStats has new lines in log to process.
* Use last AWStats version


IV - TROUBLESHOOTING / FAQ
-----------------------------------
All AWStats FAQ are available on AWStats Official web site:
http://awstats.sourceforge.net


V - ABOUT THE AUTHOR, LICENSE AND SUPPORT
-----------------------------------------
Copyright (C) 2000-2001 - Laurent Destailleur - eldy@users.sourceforge.net

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
version 2 as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details, in COPYING.TXT file.

If you have not received a copy of this file along with this program, write to
the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


You can download latest version at the following URL:
http://awstats.sourceforge.net


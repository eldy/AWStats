
------------- AWStats --------------
     Advanced Web Statistics
------------------------------------

Advanced Web Statistics (AWStats) is a powerfull web server logfile analyzer
(Perl script) that shows you all your Web statistics including visitors,
pages, hits, hours, search engines, keywords used to find your site, broken
links, robots and more. It works with IIS 5.0+ or Apache webserver log files.

License: GNU GPL (GNU General Public License. See COPYING.TXT)
Version : 2.5
Release date: 05 July 2001
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
IV  - Troubleshouting / FAQ
V   - About the author, license and support



I - FEATURES AND REQUIREMENTS
------------------------------------

I - 1) Features

    A full log analysis enables AWStats to show you the following information:
    * Number of VISITS and UNIQUE VISITORS,
    * Most often pages viewed,
    * Domains/countries of hosts visitors (pages,hits,kb),
    * Rush hours (pages,hits,kb for each hour),
    * Browsers used (pages,hits,kb for each browser),
    * OS used (pages,hits,kb for each OS),
    * VISITS OF ROBOTS,
    * SEARCH ENGINES and KEYWORDS used to find your site,
    * HTTP errors (Page not found, ...).

    It supports the following features as well:
    * Works from command line or as a CGI,
    * Update of statistics can be made on demand from the web interface and
      not only from your scheduler,
    * A lot of options/filters can be defined,
    * Easy to install, easy to use (No compilation, no extern databases),
    * Look and colors can match your site design,
    * Multi-named web sites supported (virtual servers),
    * Informations are since the start of your web site and month by month,
    * Several languages: English, French, Dutch, Spanish, Italian, German,
      Polish, Greek, Czech, Portuguese, Korean...
    * Help on how AWStats work, tooltips on HTML reporting page,
    * Colored graphics with no needs of any special libraries,
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
    wwwroot/cgi-bin/awstats.pl           The main CGI/command line perl script
    wwwroot/cgi-bin/awstats.model.conf   An example of AWStats configure file
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
      See your apache manual for more informations. Don't forget to restart
      apache to activate changes.
      This is an example of what you should get then in your log file:
      62.161.78.73 - - [dd/mmm/yyyy:hh:mm:ss +0000] "GET / HTTP/1.1" 200 1234 "http://www.from.com/from.htm" "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"

    * Put awstats.pl file in your cgi-bin directory (or other cgi directory).
      Check that this file has right permissions to be runned.

    * If necessary, in awstats.pl file, edit the first line
      #!/usr/bin/perl
      to reflect the path were your perl interpreter is installed.
      Default value works for most of Unix OS, but it also might be
      #!/usr/local/bin/perl
      With Apache for Windows and Activeperl interpreter, it might be
      #!c:/program files/activeperl/bin/perl

    * Move all awstats icons sub-directories into a directory readable by your
      web server, for example /yourwwwroot/icon.

    * Copy awstats.model.conf into awstats.www.myserver.mydomain.conf or
      awstats.conf (when you will run AWStats, it will first look for a config
      file called awstats.www.myserver.mydomain.conf, and, if not found, will
      look for awstats.conf). Whatever the name you choose, this new file must
      be stored in same directory than awstats.pl (so cgi-bin directory) and
      edit it with your own setup :
      - Change "LogFile" value with full path of your web server log file (You
        can also use a relative path from your awstats.pl directory).
      - Check if "LogFormat" has the value "1" (it means "apache combined log
        format").
      - Change the "DirIcons" parameter to reflect URL of icons directory.
      - You can change other parameters if you want.

    * To update statistics and generate the HTML report page, launch 
      awstats.pl from the command line interface (the first time, process may
      be long), like this:
       awstats.pl site=www.myserver.mydomain > result.html
      AWStats will use awstats.www.myserver.mydomain.conf config file, and, if
      not found, will use awstats.conf.
      This command create/update database where AWStats store all summary
      informations issued from analyzed log files and create an HTML result
      page that shows all those informations.
      A log analysis process is slow (one second for each 570 lines of your
      logfile with Pentium 300, plus DNS resolution time for each different IP
      address in your logfile if DNSLookup=1).

    * Add instructions in your crontab (Unix/Linux) or your scheduler (for
      Windows), to launch frequently this Awstats update process.
      For sites with:
      - 1,000 visits a month     Launch AWStats once a day (23h55 for example)
      - 10,000 visits a month    Launch AWStats every 4 hours or more often
      - 50,000 visits a month    Launch AWStats every hour
      - 200,000 visits a month   Launch AWStats every 15mn
      This is ABSOLUTELY necessary to keep good performances.

      !!! Warning: if your logfile rotates or is different each month or day,
      think to launch Awstats just before the switch (end of month or day).
      If you forget it, you will also forget statistics for this month or day.
      You can launch AWStats as much as necessary.

    * You can then view your statistics from a browser :
      - Just open the result.html file (created earlier).
      - But this result.html file is not required because AWStats is able to
      generate the report page dynamically when runned from a browser.
      For this, if you called your config file awstats.conf, just use URL:
       htpp://www.myserver.mydomain/cgi-bin/awstats.pl
      If you called your config file awstats.virtualhost.conf, use URL:
       htpp://www.myserver.mydomain/cgi-bin/awstats.pl?site=virtualhost
      where virtualhost is used to know which config file to use (AWStats will
      use awstats.virtualhost.conf file).


II - 2) With IIS Server

    * Configure IIS to have "Extended W3C log format" with following fields:
      date time c-ip cs-username cs-method cs-uri-stem sc-status sc-bytes cs-version cs(User-Agent) cs(Referer)
      This is an example of what you should get:
      2000-07-19 14:14:14 62.161.78.73 - GET / 200 1234 HTTP/1.1 Mozilla/4.0+(compatible;+MSIE+5.01;+Windows+NT+5.0) http://www.from.com/from.htm

    * Put awstats.pl file in your cgi-bin directory (or other cgi directory).

    * Move all awstats icons sub-directories into a directory readable by your
      web server, for example C:\yourwwwroot\icon and change the "DirIcons"
      parameter in configure file to reflect this directory (Ie: /icon).

    * Copy awstats.model.conf into awstats.www.myserver.mydomain.conf or
      awstats.conf (when you will run AWStats, it will first look for a config
      file called awstats.www.myserver.mydomain.conf, and, if not found, will
      look for awstats.conf). Whatever the name you choose, this new file must
      be stored in same directory than awstats.pl (so cgi-bin directory) and
      edit it with your own setup :
      - Change "LogFile" value with full path of your web server log file (You
        can also use a relative path from your awstats.pl directory).
      - Change "LogFormat" to value "2" (it means "IIS log format").
      - Change "DirIcons" parameter to reflect URL of icons directory.
      - You can change other parameters if you want.

    * To update statistics and generate the HTML report page, launch 
      awstats.pl from the command line interface (the first time, process may
      be long), like this:
       awstats.pl site=www.myserver.mydomain > result.html
      AWStats will use awstats.www.myserver.mydomain.conf config file, and, if
      not found, will use awstats.conf.
      This command create/update database where AWStats store all summary
      informations issued from analyzed log files and create an HTML result
      page that shows all those informations.
      A log analysis process is slow (one second for each 570 lines of your
      logfile with Pentium 300, plus DNS resolution time for each different IP
      address in your logfile if DNSLookup=1).

    * Add instructions in a task scheduler to launch frequently this Awstats
      update process.
      For sites with:
      - 1,000 visits a month     Launch AWStats once a day (23h55 for example)
      - 10,000 visits a month    Launch AWStats every 4 hours or more often
      - 50,000 visits a month    Launch AWStats every hour
      - 200,000 visits a month   Launch AWStats every 15mn
      This is ABSOLUTELY necessary to keep good performances.

      !!! Warning, with IIS, Windows doesn't let AWStats to purge log file
      after processing it, so performance won't be as good as with Apache
      server.
      It's very important you purge/rotate your log file yourself (or let IIS
      doing it), if you don't want to have very bad performances.
      The more often you clean your log file, the more faster AWStats will be
      (See benchmark chapter to known what you can hope).

      !!! Warning: if your logfile rotates or is different each month or day,
      think to launch Awstats just before the switch (end of month or day).
      If you forget it, you will also forget statistics for this month or day.
      You can launch AWStats as much as necessary.

    * You can then view your statistics from a browser :
      - Just open the result.html file (created earlier).
      - But this result.html file is not required because AWStats is able to
      generate the report page dynamically when runned from a browser.
      For this, if you called your config file awstats.conf, just use URL:
       htpp://www.myserver.mydomain/cgi-bin/awstats.pl
      If you called your config file awstats.virtualhost.conf, use URL:
       htpp://www.myserver.mydomain/cgi-bin/awstats.pl?site=virtualhost
      where virtualhost is used to know which config file to use (AWStats will
      use awstats.virtualhost.conf file).


III - BENCHMARK
-----------------------------------

This is benchmark results with AWStats version 2.5:
CONFIG: Athlon 1 GHz / Windows 2000 / ActivePerl 5.6
SPEED: 20000 lines in 15s with reverse dns lookup disabled
AVERAGE: 1333 lines by seconds 

However, benchmarks of log analyzer are made without reverse dns lookup
because this depends on your system, networks and Internet and not on the
log analyzer you use. But, the reverse dns lookup is 99% of the time
to make a log analysis. So this is results in reality (with reverse dns
lookup enabled, made on true log samples):
AVERAGE: 100 lines by seconds
If we consider 5 hits by page and 5 pages for one visit, it means that
AWStats is able to analyze 4 visits in one second.
If your site has 70 visits each hour (50,000 visits a month), you should
launch AWStats each hour to be sure to get a processing time less than
70/4 = 18 seconds (with Athlon 1 Ghz).

To increase speed:
- You can disable DNSLookup in AWStats (set DNSLookup=0) but this requires
that hosts adresses in your log file are already resolved (need to setup your
web server to do so). Speed can be increased up by 2 to 50 times !
- If you use Apache, set PurgeLogFile to 1 (By default, to avoid bad surpise,
PurgeLogFile is 0 in configure file, but you can set it to 1 to ask AWStats
to purge log file after processing it, this increase speed for next run).
- Launch AWStats more often (from crontab or a scheduler). The more often you
launch AWStats, the less AWStats has new lines in log to process.
- Use last AWStats version


IV - TROUBLESHOUTING / FAQ
-----------------------------------
All AWStats FAQ are availabe on AWStats Official web site:
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


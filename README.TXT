
------------- AWStats --------------
     Advanced Web Statistics
------------------------------------

Advanced Web Statistics (AWStats) is a powerfull web server logfile analyzer
(Perl script) that shows you all your Web statistics including visitors,
pages, hits, hours, search engines, keywords used to find your site, broken
links, robots and more. It works with IIS 5.0+ or Apache webserver log files.

License: GNU GPL (GNU General Public License. See COPYING.TXT)
Version : 2.23
Release date: 25 November 2000
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
	* number of VISITS and UNIQUE VISITORS,
	* most often pages viewed
	* domains/countries of hosts visitors (pages,hits,kb),
	* rush hours (pages,hits,kb for each hour),
	* browsers used (pages,hits,kb for each browsed),
	* OS used (pages,hits,kb for each OS),
	* VISITS OF ROBOTS,
	* SEARCH ENGINES and KEYWORDS used to find your site,
	* HTTP errors.

	It supports the following features as well:
	* Command line scheduled analysis or real-time analysis
	* Easy to install, easy to use (No compilation, no extern databases, only
	  one .pl file),
	* Tooltips and explanations for each informations pointed by mouse,
	* Multi-named web sites supported,
	* Informations are since the start of your web site and month by month,
	* 7 languages: English, French, Dutch (Christtian Langeveld), Spanish
	  (Rodrigo Villarreal), Italian (Vittore Zen), German (Ulf Moench), Polish
	  (Tomasz Ciemnoczulowski).
	* Colored graphics,
	* Free and distributed with sources (perl script).
	
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
	  statistics), your web server must be able to run such scripts.
	  If not, you can solve this by downloading last Perl version at:
	  http://www.activestate.com/ActivePerl/ (Win32)
	  http://www.perl.com/pub/language/info/software.html (Unix/Linux/Other)
	  
	
I - 3) Files
	
	The distribution of AWStats include the following files:
	awstats.pl         The main CGI/command line perl script
	awstats.model.conf A model of AWStats configure file
	COPYING.TXT        Information file on GNU General Public Licence
	README.TXT         This file
	INSTALL.TXT        To say setup manual is in README.TXT file
	robotslist.txt     Information file on robots (useless for AWStats)
	browser            Directory with browsers icons
	clock              Directory with clocks icons
	cpu                Directory with cpu icons
	flags              Directory with country flags icons
	os                 Directory with os icons
	other              Directory with all others icons


II - HOW TO INSTALL AND USE AWSTATS
-----------------------------------

II - 1) With Apache Server

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

	* If necessary (on some Unix OS), in awstats.pl file, edit the first line
	  #!/usr/bin/perl
	  to reflect the path were your perl interpreter is installed. It might be
	  #!/usr/local/bin/perl
	  	
	* Move all awstats icons sub-directories into a directory readable by your
	  web server, for example /yourwwwroot/icon.

	* Copy awstats.model.conf into awstats.www.myserver.mydomain.conf or
	  awstats.conf (when you will run AWStats, it will first look for a config
	  file called awstats.www.myserver.mydomain.conf, and, if not found, will
	  look for awstats.conf). Whatever the name you choose, edit this new file
	  with your own setup :
	  - Change "LogFile" value with full path of your web server log file. You
	    can use a relative path from your awstats.pl directory.
	  - Check if "LogFormat" has the value "1" (it means "apache combined log
	    format").
	  - Change the "DirIcons" parameter to reflect URL of icons directory.
	  - You can change other parameters if you want.
	
	* Before using AWStats from your browser, launch awstats.pl from the
	  command line (the first time, process may be long), like this:
	> awstats.pl -h www.myserver.mydomain
	  where www.myserver.mydomain is the URL you use to access your web site.
	  AWStats will use awstats.www.myserver.mydomain.conf config file, and, if
	  not found, will use awstats.conf.
	  
	  This command help you see if AWStats setup is good and because, the
	  first time, the AWStats process is slow (one second for each 570 lines
	  of your logfile with Pentium 300, plus DNS resolution time for each
	  different IP address in your logfile).
	  The result, an HTML code page on your screen, means you can now run
	  AWStats from your browser. For example with this URL :
	   htpp://www.myserver.mydomain/cgi-bin/awstats.pl
	  You can also use this URL to choose parameters of a particular site :
	   htpp://www.myserver.mydomain/cgi-bin/awstats.pl?site=virtualhost
	  where virtualhost is a name of another web server (AWStats will use
	  awstats.virtualhost.conf file).

	* Add something in your crontab (Unix/Linux), or something else, to launch
	  the following command :
	> awstats.pl -h www.myserver.mydomain
	  where www.myserver.mydomain is the URL used to access your web site.
	  For sites with:
	  - 1,000 visits a month     Launch AWStats once a day (23h55 for example)
	  - 10,000 visits a month    Launch AWStats every 4 hours or more often
	  - 50,000 visits a month    Launch AWStats every hour
	  - 200,000 visits a month   Launch AWStats every 15mn
	  This is necessary to keep good performances.
	
	
II - 2) With IIS Server

	* Configure IIS to have "Extended W3C log format" with following fields:
	  date time c-ip c-username cs-method cs-uri-sterm sc-status cs-bytes cs-version cs-host cs(User-Agent) cs(Referer)
	    or (this second format will require more time for AWStats processing)
	  date time c-ip c-username cs-method cs-uri-sterm sc-status cs-bytes cs-version cs(User-Agent) cs(Referer)
	  This is an example of what you should get:
	  2000-07-19 14:14:14 62.161.78.73 - GET / 200 1234 HTTP/1.1 Mozilla/4.0+(compatible;+MSIE+5.01;+Windows+NT+5.0) host http://www.from.com/from.htm
	    or
	  2000-07-19 14:14:14 62.161.78.73 - GET / 200 1234 HTTP/1.1 Mozilla/4.0+(compatible;+MSIE+5.01;+Windows+NT+5.0) http://www.from.com/from.htm
	
	* Put awstats.pl file in your cgi-bin directory (or other cgi directory).
	
	* Move all awstats icons sub-directories into a directory readable by your
	  web server, for example C:\yourwwwroot\icon and change the "DirIcons"
	  parameter in configure file to reflect this directory (Ie: /icon).
		
	* Copy awstats.model.conf into awstats.www.myserver.mydomain.conf or
	  awstats.conf (when you will run AWStats, it will first look for a config
	  file called awstats.www.myserver.mydomain.conf, and, if not found, will
	  look for awstats.conf). Whatever the name you choose, edit this new file
	  with your own setup :
	  - Change "LogFile" value with full path of your web server log file. You
	    can use a relative path from your awstats.pl directory.
	  - Change "LogFormat" to value "2" (it means "IIS log format").
	  - Change "DirIcons" parameter to reflect URL of icons directory.
	  - You can change other parameters if you want.

	* Before using AWStats from you're browser, launch awstats.pl from the
	  command line:
	> awstats.pl -h www.myserver.mydomain
	  where www.myserver.mydomain is the URL you use to access your web site.
	  AWStats will use awstats.www.myserver.mydomain.conf config file, and, if
	  not found, will use awstats.conf.
	  
	  This command help you see if AWStats setup is good and because, the
	  first time, the AWStats process is slow (one second for each 570 lines
	  of your logfile with Pentium 300, plus DNS resolution time for each
	  different IP address in your logfile).
	  The result, an HTML code page on your screen, means you can now run
	  AWStats from your browser. For example with this URL :
	   htpp://www.myserver.mydomain/cgi-bin/awstats.pl
	  You can also use this URL to choose parameters of a particular site :
	   htpp://www.myserver.mydomain/cgi-bin/awstats.pl?site=virtualhost
	  where virtualhost is a name of another web server (AWStats will use
	  awstats.virtualhost.conf file).

	* Add something in a task scheduler, or something else, to launch at the
	  following command :
	> awstats.pl -h www.myserver.mydomain
	  where www.myserver.mydomain is the URL used to access your web site.
	  For sites with:
	  - 1,000 visits a month     Launch AWStats once a day (23h55 for example)
	  - 10,000 visits a month    Launch AWStats every 4 hours or more often
	  - 50,000 visits a month    Launch AWStats every hour
	  - 200,000 visits a month   Launch AWStats every 15mn
	  This is necessary to keep good performances.
	
	  !!! Warning, with IIS, Windows doesn't let AWStats to purge log file
	  after processing it, so performance won't be as good as with Apache
	  server.
	  It's very important you purge your log file yourself (or let IIS doing
	  it), if you don't want to have very bad performances.
	  The more often you clean your log file, the more faster AWStats will be
	  (See benchmark chapter to known what you can hope).

	  !!! Warning: if your log filename is different each month or day (with
	  IIS, think to launch awstats just before the end of month or day. If you
	  forget it, you will also forget statistics for this month or day.



III - BENCHMARK
-----------------------------------

In version 2.23, AWStats processes 570 lines by seconds (Pentium 300Mhz).
If we consider 10 hits by page and 5 pages for one visits, it means that
AWStats is able to analyze 11 visits in one second.
If your site has 70 visits each hour (50,000 visits a month), you should
launch AWStats each hour to be sure to get a processing time less than
70/11 = 6.4 seconds (with Pentium 300Mhz). In fact, process time might be
higher because of DNS reverse lookup that is time consuming.
DNS lookup speed depends on your system, network and Internet but not on the
log analyzer you use. For this reason, DNS lookup is disabled in all log
analyzer benchmarks, but you must keep in mind that it's the most time
consuming part of the process.
To increase speed:
- Use last AWStats version
- Launch AWStats more often (from crontab or a scheduler)
- You can disable DNSLookup in AWStats (set DNSLookup=0) but this requires
that hosts adresses in your log file are already resolved (need to setup your
web server to do so). Speed can be increased up by 2 to 10 times !


IV - TROUBLESHOUTING / FAQ
-----------------------------------
All AWStats FAQ are availabe on AWStats Official web site:
http://awstats.sourceforge.net


V - ABOUT THE AUTHOR, LICENSE AND SUPPORT
-----------------------------------------
Copyright (C) 2000  Laurent Destailleur

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

You can send or ask help to:
eldy@users.sourceforge.net


------------- AWStats --------------
     Advanced Web Statistics
------------------------------------

Advanced Web Statistics (AWStats) is a powerfull web server logfile analyzer
(CGI Perl script) that shows you all your Web statistics including visitors, 
pages, hits, hours, search engines, keywords used to find your site, broken
links, robots and more. It works with IIS 5.0+ or Apache webserver log files.

License: GNU GPL (GNU General Public License. See COPYING.TXT)
Version : 2.22k
Release date: 10 October 2000
Platforms: All (Linux, NT, SCO, BSD, Solaris and other *NIX's, OS/2...)
Author: Laurent Destailleur <laurent.destailleur@wanadoo.fr>
AWStats web site: http://perso.wanadoo.fr/l.destailleur/awstats.html

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
	* ENTRY PAGES
	* domains/countries of hosts visitors (pages,hits,kb),
	* rush hours (pages,hits,kb for each hour),
	* browsers used (pages,hits,kb for each browsed),
	* OS used (pages,hits,kb for each OS),
	* VISITS OF ROBOTS,
	* SEARCH ENGINES and KEYWORDS used to find your site,
	* HTTP errors,

	It supports the following features as well:
	* Real-time analysis
	* Easy to install, easy to use (No compilation, no extern databases, only one .pl file),
	* Tooltips and explanations for each informations pointed by mouse,
	* Multi-named web sites supported,
	* Informations are since the start of your web site and/or month by month,
	* 4 languages: English, French, Dutch (Thanks to Christtian Langeveld) and Spanish (Thanks to Rodrigo Villarreal) 
	* Colored graphics,
	* Distributed with sources (perl script)
	
I - 2) Requirements
	
	To use AWStats CGI script, you need the following requirements:
	* Your Web server must be able to log web access in "Combined logfile
	  format" like Apache or in "Extended W3C logfile format" like IIS 5.0+
	* Your server must be able to run perl script (.pl files).
	  If not, you can solve this by downloading last Perl version at:
	  http://www.activestate.com/ActivePerl/ (Win32)
	  http://www.perl.com/pub/language/info/software.html (Unix/Linux/Other)
	* You need to have read (better if read/write) access to your logfile
	  server. If you can only have a read access, for example with IIS that
	  doesn't allow write access on its lofgile, AWStats will automatically
	  work differently, but slower than with read/write access).
	
I - 3) Files
	
	The distribution of AWStats include the following files:
	awstats.pl		The main CGI/command line perl script
	README.TXT		This file
	browser			Directory with browsers icons
	clock			Directory with clocks icons
	cpu				Directory with cpu icons
	flags			Directory with country flags icons
	os				Directory with os icons
	other			Directory with all others icons


II - HOW TO INSTALL AND USE AWSTATS
-----------------------------------

II - 1) With Apache Server

	* Configure your apache web server to have "combined" log format.
	  You can do so with the following directive:
	  CustomLog /yourlogpath/yourlogfile combined
	  (See your apache manual for more informations).
	  This is an example of what you should get then in your log file:
	  62.161.78.73 - - [dd/mmm/yyyy:hh:mm:ss +0000] "GET / HTTP/1.1" 200 1234 "http://www.from.com/from.htm" "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"
	
	* Put awstats.pl file in your cgi-bin directory (or other cgi directory).
	  This directory must be writable by default server user (nobody for Apache
	  with Unix/Linux).
	
	* In awstats.pl file, edit the first line "#!/usr/local/bin/perl" to
	  reflect the path were your perl interpreter is installed (Ie: It might
	  be "#!/usr/bin/perl" instead).
	
	* In awstats.pl file, modify line "$LogFile=" with full path of your web
	  server log file.
	
	* In awstats.pl file, the line "$LogFormat=" must have the value "1" (it
	  means "apache combined log format").
	
	* Move all icons directories into a directory readable by your web server
	  (and change "$DirIcons=" value in awstats.pl to reflect this directory).
	
	* Before using AWStats from your browser, launch awstats.pl from the
	  command line (the first time, process may be long):
	> awstats.pl www.myserver.com
	  where www.myserver.com is the URL you use to access your web site.
	
	  This is to see if AWStats setup is good and because, the first time,
	  the AWStats process is slow (one second for each 570 lines of your
	  logfile with Pentium 300, plus DNS resolution time for each IP address
	  in your logfile).
	  The result, an HTML code page on your screen, means you can now run
	  AWStats from your browser. For example with this URL :
	  htpp://www.myserver.com/cgi-bin/awstats.pl

	* Add something in your crontab (Unix/Linux), or something else, to launch
	  at least once a day, the following command (more often if you have a lot
	  of visitors):
	> awstats.pl www.myserver.com
	  where www.myserver.com is the URL name you use to access your web site.
	
	  This is usefull to keep good performances.
	
	
II - 2) With IIS Server

	* Configure IIS to have "Extended W3C log format" with following fields:
	  date time c-ip c-username cs-method cs-uri-sterm cs-status cs-bytes cs-version cs(User-Agent) cs(Referer)
	  This is an example of what you should get:
	  2000-07-19 14:14:14 62.161.78.73 - GET / 200 1234 HTTP/1.1 Mozilla/4.0+(compatible;+MSIE+5.01;+Windows+NT+5.0) http://www.from.com/from.htm
	
	* Put awstats.pl file in your cgi-bin directory (or other cgi directory).
	  This directory must be writable by default server user (nobody for Apache
	  with Unix/Linux).
	
	* In awstats.pl file, modify line "$LogFile=" with full path of your web
	  server log file.
	
	* In awstats.pl file, the line "$LogFormat=" must have the value "2" (it
	  means IIS log format).
	
	* Move all icons directories into a readable directory for your web server
	  (And change "$DirIcons=" value in awstats.pl file to reflect this)
	
	* Before using AWStats from you're browser, launch awstats.pl from the
	  command line:
	> awstats.pl www.myserver.com
	  where www.myserver.com is the URL name you use to access your web site.
	
	  This is to see if AWStats setup is good and because, the first time,
	  the AWStats process is slow (one second for each 570 lines of your
	  logfile with Pentium 300, plus DNS resolution time for each IP address
	  in your logfile).
	  The result, an HTML code page on your screen, means you can now run
	  AWStats from your browser. For example with this URL :
	  htpp://www.myserver.com/cgi-bin/awstats.pl

	* Add something in a task scheduler, or something else, to launch at least
	  once a day, the following command (more often if you have a lot of
	  visitors):
	> awstats.pl www.myserver.com
	  where www.myserver.com is the URL name you use to access your web site.
	
	  This is necessary to keep good performances.
	
	  !!! Warning, with IIS, Windows doesn't let AWStats to purge log file
	  after processing it (AWStats do this to analyze only new logs and
	  increase its speed), so performance won't be as good as with Apache
	  server.
	  It's very important you do this yourself (or let MSII doing it), if you
	  don't want to have very bad performances.
	  The more often you clean your log file, the more faster AWStats will be
	  (See benchmark to known what you can hope).


III - BENCHMARK
-----------------------------------

In version 2.21, AWStats processes 570 lines by seconds (Pentium 300Mhz).
If we consider 9 hits by page and 4 pages for one visits, it means that
AWStats is able to analyze 7 visits in one second.
If your site has 40 visits each hour (30000 visits a month), you should launch
AWStats each hour to be sure to have a processing time less than 20/7 = 2.8
seconds (with Pentium 300Mhz). In fact, process time is higher because of DNS
lookup that is time consuming. DNS lookup speed depends on your system,
network and Internet but not on the log analyzer you use. For this reason,
DNS lookup is disabled in all log analyzer benchmarks, but you must keep in
mind that it's the most time consuming part of the process.


IV - TROUBLESHOUTING / FAQ
-----------------------------------

I'M USING WEBANALYZER AND DOESN'T HAVE THE SAME RESULT AS WITH AWSTATS. WHY ?
> There is some difference between way to analyze logfile, so results are
> different. For example, some dynamic pages generated by CGI are not
> understood by WebAnalyzer as pages if CGI prog has not a .cgi extension, so
> they are not included in WebAnalyzer statistics. Another difference is that
> WebAnalyzer is not able to detect robots and think its a human visitor.
> AWStats doesn't count this hits as a visitor but make a separated report for
> all those robots. There is a lot of other differences I can't list because I
> don't know all Webanalyzer specifications. I try to keep AWStats way of
> working understandable and free, so if you have any questions about AWStats
> process, just ask me.


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
http://perso.wanadoo.fr/l.destailleur/awstats.html

You can send or ask help to:
laurent.destailleur@wanadoo.fr

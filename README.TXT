
------------- AWStats --------------
     Advanced Web Statistics
------------------------------------

Advanced Web Statistics (AWStats) is a powerfull and featurefull web server
logfile analyzer that shows you all your Web statistics including visitors,
pages, hits, hours, search engines, keywords used to find your site, broken
links, robots and more...
It works with IIS 5.0+, Apache and all major web/wap/proxy server log files
on all Operating Systems.

License: GNU GPL (GNU General Public License. See LICENSE file)
Version : 4.0
Release date: 19 January 2001
Platforms: All (Linux, NT, SCO, BSD, Solaris and other *NIX's, BeOS, OS/2...)
Author: Laurent Destailleur <eldy@users.sourceforge.net>
AWStats official web site and latest version: http://awstats.sourceforge.net
 
I   - Features and requirements of AWStats
      I - 1) Features, what AWStats can show you
      I - 2) Requirements for using AWStats
      I - 3) Files
II  - How to install and use AWStats
III - Benchmark
IV  - About the author, license and support



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
      Polish, Greek, Czech, Portuguese, Chinese, Japanese, Korean...
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
    README.TXT                          This file
	docs/LICENSE                        GNU General Public Licence
	docs/*                              AWStats documentation (setup/usage...)
	tools/*                             Ohter provided tools
    wwwroot/cgi-bin/awstats.pl          The main command line/CGI program
    wwwroot/cgi-bin/awstats.model.conf  An example of AWStats configure file
 	wwwroot/cgi-bin/db                  Directory with awstats reference info
 	wwwroot/cgi-bin/lang                Directory with languages files
    wwwroot/icon/browser                Directory with browsers icons
    wwwroot/icon/clock                  Directory with clocks icons
    wwwroot/icon/cpu                    Directory with cpu icons
    wwwroot/icon/flags                  Directory with country flags icons
    wwwroot/icon/os                     Directory with os icons
    wwwroot/icon/other                  Directory with all others icons



II - HOW TO INSTALL AND USE AWSTATS
-----------------------------------

The documentation available as of the date of this release is included, in
HTML format, in the docs/ directory.
You can find a most up-to-date documentation on:
http://awstats.sourceforge.net


III - BENCHMARK
-----------------------------------

Tests and results are available in AWStats documentation, in docs/ directory.


IV - ABOUT THE AUTHOR, LICENSE AND SUPPORT
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


------------- AWStats --------------
	 Advanced Web Statistics
------------------------------------

AWStats (Advanced Web Statistics) is a powerful, full-featured web server
logfile analyzer which shows you all your Web statistics including: visitors,
pages, hits, hours, search engines, keywords used to find your site, broken
links, robots and many more...

It works with IIS 5.0+, Apache and all major web, wap, proxy, streaming
server log files (and even ftp servers or mail logs) on all Operating Systems.

License: GNU GPL v3+ (GNU General Public License. See LICENSE file),
         OSI Certified Open Source Software license.
Version: 7.2
Release date: June 2013
Platforms: All (Linux, NT, BSD, Solaris and other *NIX's, BeOS, OS/2...)
Author: Laurent Destailleur <eldy@users.sourceforge.net>
AWStats official web site and latest version: http://www.awstats.org

I   - Features and requirements of AWStats
	  I - 1) Features, what AWStats can show you
	  I - 2) Requirements for using AWStats
	  I - 3) Files
II  - Install, Setup and Use AWStats
III - Benchmark
IV  - About the author, license and support



I - FEATURES AND REQUIREMENTS
------------------------------------

I - 1) Features

	A full log analysis enables AWStats to show you the following information:
	* Number of VISITS and UNIQUE VISITORS
	* Visits duration and last visits
	* Authenticated users, and last authenticated visits
	* Days of week and rush hours (pages, hits, KB for each day and hour)
	* Domains/countries of hosts visitors (pages, hits, KB)
	* Hosts list, last visits and unresolved IP addresses list
	* Most viewed, entry and exit pages
	* File types
	* Web compression statistics (for mod_gzip or mod_deflate)
	* Browsers used (pages, hits, kb for each browser)
	* OS used (pages, hits, KB for each OS)
	* Robot visits
	* Worm attacks
	* Download and continuation detection
	* Search engines, keyphrases and keywords used to find your site
	* HTTP errors (Page not found with last referer, etc,)
	* Screen size report
	* Number of times your site is "added to favourites bookmarks"
	* Ratio of Browsers that support: Java, Flash, RealG2 reader,
	  Quicktime reader, WMA reader, PDF reader
	* Cluster report for load balanced servers ratio
	* Other personalized reports...

	It supports the following features as well:
	* Can analyze all log formats
	* Works from command line and from a browser as a CGI (with dynamic
	  filters capabilities for some charts)
	* Update of statistics can be made on demand from the web interface and
	  not only from your scheduler
	* Unlimited log file size, support split log files (load balancing system)
	* Support 'nearly sorted' log files even for entry and exit pages
	* Reverse DNS lookup before or during analysis, supports DNS cache files
	* Country detection from IP location or domain name
	* WhoIS links
	* A lot of options/filters and plugins can be used
	* Multi-named web sites supported (virtual servers)
	* Cross Site Scripting Attacks protection
	* Several languages
	* No need of rare perl libraries
	* Dynamic reports as CGI output
	* Static reports in one or framed HTML or XHTML pages
	* Experimental PDF export
	* Look and colors can match your site design (CSS)
	* Help and tooltips on HTML reported pages
	* Easy to use (Just one configuration file to edit)
	* Analysis database can be stored in XML format (for XSLT processing, ...)
	* A Webmin module
	* Free (GNU GPL) with sources (perl scripts)
	* Available on all platforms


I - 2) Requirements

	To use AWStats CGI script, you need the following requirements:
	* Your server must log web access in a log file you can read.
	* To run awstats, from command line, your operating system must be able
	  to run perl scripts (.pl files).
	* Perl module "Encode" must be available.
	  
	To run awstats as a CGI (for real-time
	  statistics), your web server must also be able to run such scripts.
	  If not, you can solve this by downloading last Perl version at:
	  http://www.activestate.com/ActivePerl/ (Windows)
	  http://www.perl.com/pub/language/info/software.html (All OS)


I - 3) Files

	The distribution of AWStats package includes the following files:
	README.TXT                          This file
	docs/LICENSE                        GNU General Public Licence
	docs/*                              AWStats documentation (setup/usage...)
	wwwroot/cgi-bin/awstats.pl          THE MAIN AWSTATS PROGRAM (CLI/CGI)
	wwwroot/cgi-bin/awredir.pl          A tool to track exit clicks
	wwwroot/cgi-bin/awstats.model.conf  An model configuration file
	wwwroot/cgi-bin/lang                Directory with languages files
	wwwroot/cgi-bin/lib                 Directory with awstats reference info
	wwwroot/cgi-bin/plugins             Directory with optional plugins
	wwwroot/icon/browser                Directory with browsers icons
	wwwroot/icon/clock                  Directory with clock icons
	wwwroot/icon/cpu                    Directory with cpu icons
	wwwroot/icon/flags                  Directory with country flag icons
	wwwroot/icon/os                     Directory with OS icons
	wwwroot/icon/other                  Directory with all others icons
	wwwroot/classes                     Java applet for graphapplet plugin
	wwwroot/css                         Samples of CSS files
	wwwroot/js                          Javascript sources for "Misc" feature
	tools/*                             Other provided tools
	tools/webmin/awstats-x.x.wbm        A Webmin module for AWStats
	tools/xslt/awstats61.xsd            AWStats XML database schema descriptor
	tools/xslt/*                        Demo to manipulate AWStats XML database



II - INSTALL, SETUP AND USE AWSTATS
-----------------------------------

The documentation available for this release in HTML format is
in the docs/ directory.

You can find a most up-to-date documentation at:
http://www.awstats.org



III - BENCHMARK
-----------------------------------

Tests and results are available in AWStats documentation, in docs/ directory.



IV - ABOUT THE AUTHOR, LICENSE AND SUPPORT
-----------------------------------------
Copyright (C) 2000-2013 - Laurent Destailleur - eldy@users.sourceforge.net

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

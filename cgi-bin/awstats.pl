#!/usr/bin/perl
# With some other Unix Os, first line may be
#!/usr/local/bin/perl
# With Apache for Windows and ActiverPerl, first line may be
#!c:/program files/activeperl/bin/perl
# use diagnostics;
# use strict;
#-Description-------------------------------------------
# Free realtime web server logfile analyzer (Perl script) to show advanced web
# statistics. Works from command line or as a CGI.
# You must use this script as often as necessary from your scheduler to update
# your statistics.
# See README.TXT file for setup and benchmark informations.
# See COPYING.TXT file about AWStats GNU General Public License.
#-------------------------------------------------------
# Algorithm SUMMARY
# Read config file
# If 'update'
#   Get last history file name
#   Read this last history file (LastTime, data arrays, ...)
#   Loop on each new line in log file
#     If line older than Lastime, skip
#     If new line
#        If other month/year, save data arrays, reset them
#        Analyse record and complete data arrays
#     End of new line
#   End of loop
# End of 'update'
# Save data arrays
# Reset data arrays if not required month/year
# Loop for each month of current year
#   If required month, read 1st and 2nd part of history file for this month
#   If not required month, read 1st part of history file for this month
# End of loop
# Show data arrays in HTML page
#-------------------------------------------------------


#-------------------------------------------------------
# Defines
#-------------------------------------------------------

# ---------- Init variables --------
($ArchiveFileName, $ArchiveLogRecords, $BarHeight, $BarWidth,
$DIR, $DNSLookup, $DefaultFile, $DirCgi, $DirConfig, $DirData,
$DirIcons, $Extension, $FileConfig, $FileSuffix, $FirstTime,
$HTMLEndSection, $Host, $HostAlias, $LastTime, $LastUpdate, $SiteToAnalyze,
$SiteToAnalyzeIsInHostAliases, $SiteToAnalyzeWithoutwww, $LogFile,
$LogFormat, $LogFormatString, $Logo, $MaxNbOfHostsShown, $MaxNbOfKeywordsShown,
$MaxNbOfPageShown, $MaxNbOfRefererShown, $MaxNbOfRobotShown, $MinHitFile,
$MinHitHost, $MinHitKeyword, $MinHitRefer, $MinHitRobot, $MonthRequired,
$NewDNSLookup, $NowNewLinePhase, $OpenFileError, $PROG, $PageBool, $PurgeLogFile,
$QueryString, $RatioBytes, $RatioHits, $RatioHosts, $RatioPages,
$ShowFlagLinks, $ShowLinksOnURL, $ShowLinksOnUrl, $TotalBytes,
$TotalDifferentKeywords, $TotalDifferentPages, $TotalErrors, $TotalHits,
$TotalHosts, $TotalKeywords, $TotalPages, $TotalUnique, $TotalVisits, $UserAgent,
$WarningMessages, $YearRequired,
$allok, $beginmonth, $bredde, $bredde_h, $bredde_k, $bredde_p, $bredde_u,
$bredde_v, $color_Background, $color_TableBG, $color_TableBGRowTitle,
$color_TableBGTitle, $color_TableBorder, $color_TableRowTitle,
$color_TableTitle, $color_h, $color_k, $color_link, $color_p, $color_s, $color_v,
$color_w, $count, $date, $daycon, $endmonth, $found, $foundrobot,
$h, $hourcon, $hr, $internal_link, $ix, $keep, $key, $kilo, $lien, $line,
$max, $max_h, $max_k, $max_p, $max_v, $mincon, $monthcon, $monthfile, $monthix,
$monthtoprocess, $nameicon, $new, $nompage, $nowday, $nowisdst, $nowmin, $nowmonth,
$nowsec, $nowsmallyear, $nowwday, $nowyday, $nowyear, $p, $page, $param,
$paramtoexclude, $rest, $rest_h, $rest_k, $rest_p,
$savetime, $savetmp, $tab_titre, $timeconnexion, $total_h, $total_k, $total_p,
$word, $yearcon, $yearfile, $yearmonthfile, $yeartoprocess) = ();
# ---------- Init arrays --------
%DayBytes = %DayHits = %DayPage = %DayUnique = %DayVisits =
%FirstTime = %HistoryFileAlreadyRead = %LastTime =
%MonthBytes = %MonthHits = %MonthPage = %MonthUnique = %MonthVisits =
%_browser_h = %_domener_h = %_domener_k = %_domener_p =
%_errors_h = %_hostmachine_h = %_hostmachine_k = %_hostmachine_l = %_hostmachine_p =
%_keywords = %_os_h = %_pagesrefs_h = %_robot_h = %_robot_l = %_se_referrals_h =
%_sider404_h = %_sider_h = %_sider_k = %_sider_p = %_unknownip_l = %_unknownreferer_l =
%_unknownrefererbrowser_l = %listofyears = %monthlib = %monthnum = ();
# ---------- Init hash arrays --------
@BrowserArray = @DomainsArray = @FirstTime = @HostAliases = @LastTime = @LastUpdate =
@OnlyFiles = @OSArray = @PageCode = @RobotArray =
@SearchEnginesArray = @SkipFiles = @SkipHosts =
@_from_h = @_msiever_h = @_nsver_h = @_time_h = @_time_k = @_time_p =
@datep = @dateparts = @felter = @field = @filearray = @message =
@paramlist = @refurl = @sortbrowsers = @sortdomains_h = @sortdomains_k =
@sortdomains_p = @sorterrors = @sorthosts_p = @sortos = @sortpagerefs = @sortrobot =
@sortsearchwords = @sortsereferrals = @sortsider404 = @sortsiders = @sortunknownip =
@sortunknownreferer = @sortunknownrefererbrowser = @wordlist = ();

$VERSION="2.5 (build 21)";
$Lang=0;

# Default value
$SortDir       = -1;		# -1 = Sort order from most to less, 1 = reverse order (Default = -1)
$VisitTimeOut  = 10000;		# Laps of time to consider a page load as a new visit. 10000 = one hour (Default = 10000)
$FullHostName  = 1;			# 1 = Use name.domain.zone to refer host clients, 0 = all hosts in same domain.zone are one host (Default = 1, 0 never tested)
$MaxLengthOfURL= 70;		# Maximum length of URL shown on stats page. This affects only URL visible text, link still work (Default = 70)
$CENTER        = "";
$WIDTH         = "600";
# Images for graphics
$BarImageVertical_v   = "barrevv.png";
$BarImageHorizontal_v = "barrehv.png";
$BarImageVertical_u   = "barrevu.png";
$BarImageHorizontal_u = "barrehu.png";
$BarImageVertical_p   = "barrevp.png";
$BarImageHorizontal_p = "barrehp.png";
$BarImageVertical_h   = "barrevh.png";
$BarImageHorizontal_h = "barrehh.png";
$BarImageVertical_k   = "barrevk.png";
$BarImageHorizontal_k = "barrehk.png";

# URL with such end signature are kind of URL we only need to count as hits
@NotPageList= (
			"\\.gif","\\.jpg","\\.png","\\.bmp",
#			"\\.zip","\\.arj","\\.gz","\\.z",
#			"\\.pdf","\\.doc","\\.ppt","\\.rtf","\\.txt",
#			"\\.mp3","\\.wma"
			);

# Those addresses are shown with those lib (First column is full relative URL, Second column is text to show instead of URL)
%Aliases    = (
			"/",                                    "<b>HOME PAGE</b>",
			"/cgi-bin/awstats.pl",					"<b>AWStats stats page</b>",
			"/cgi-bin/awstats/awstats.pl",			"<b>AWStats stats page</b>",
			# Following the same example, you can put here HTML text you want to see in links instead of URL text.
			"/YourRelativeUrl",						"<b>Your HTML text</b>",
			"/YourRelativeUrl",						"<b>Your HTML text</b>"
			);

# These table is used to make fast reverse DNS lookup for particular IP adresses. You can add your own IP adresses resolutions.
%MyDNSTable = (
"256.256.256.1", "myworkstation1",
"256.256.256.2", "myworkstation2"
);

# Search engines names database (update the 10th january 2001)
%SearchEnginesHash=(
# Most common search engines
"yahoo\.","Yahoo",
"altavista\.","AltaVista",
"msn\.","MSN",
"voila\.", "Voila",
"lycos\.","Lycos",
"search\.terra\.","Terra",
"google\.","Google",
"alltheweb\.com","AllTheWeb",
"netscape\.","Netscape",
"northernlight\.","NorthernLight",
"dmoz\.org","DMOZ",
"search\.aol\.co","AOL",
# Others
"hotbot\.","Hotbot",
"webcrawler\.","WebCrawler",
"metacrawler\.","MetaCrawler (Metamoteur)",
"go2net\.com","Go2Net (Metamoteur)",
"go\.com","Go.com",
"euroseek\.","Euroseek",
"excite\.","Excite",
"lokace\.", "Lokace",
"spray\.","Spray",
"netfind\.aol\.com","AOL",
"recherche\.aol\.fr","AOL",
"nbci\.com/search","NBCI",
"askjeeves\.","Ask Jeeves",
"mamma\.","Mamma",
"dejanews\.","DejaNews",
"search\.dogpile\.com","Dogpile",
"ilse\.","Ilse","vindex\.","Vindex\.nl",	# Minor dutch search engines
"nomade\.fr/","Nomade", "ctrouve\.","C'est trouvé", "francite\.","Francité", "\.lbb\.org", "LBB", "rechercher\.libertysurf\.fr", "Libertysurf",	# Minor french search engines
"fireball\.de","Fireball", "infoseek\.de","Infoseek", "suche\.web\.de","Web.de", "meta\.ger","MetaGer",	# Minor german search engines
"engine\.exe","Cade", "miner\.bol\.com\.br","Meta Miner",	# Minor brazilian search engine
"search\..*com","Other search engines"
);



# Search engines known URLs database (update the 10th january 2001)
# To add a search engine, add a new line:
# "match_string_in_url_that_identify_engine", "search_engine_name",
%SearchEngineKnownUrl=(
# Most common search engines
"yahoo\.","p=",
"altavista\.","q=",
"msn\.","q=",
"voila\.","kw=",
"lycos\.","query=",
"google\.","q=",
"alltheweb\.","query=",
"netscape\.","search=",
"northernlight\.","qr=",
"dmoz\.org","search=",
"search\.aol\.co","query=",
# Others
"hotbot\.","mt=",
"webcrawler","searchText=",
"metacrawler\.","general=",
"go2net\.com","general=",
"go\.com","qt=",
"euroseek\.","query=",
"excite\.","search=",
"spray\.","string=",
"nbci\.com/search","keyword=",
"askjeeves\.","ask=",
"mamma\.","query=",
"search\.dogpile\.com", "q=",
"ilse\.","search_for=", "vindex\.","in=",
"nomade\.fr/","s=", "francite\.","name=",
"fireball\.de","q=", "infoseek\.de","qt=", "suche\.web\.de","su=",
"engine\.exe","p1=", "miner\.bol\.com\.br","q="
);
@WordsToCleanSearchUrl= ("act=","annuaire=","btng=","categoria=","cfg=","cou=","dd=","domain=","dt=","dw=","exec=","geo=","hc=","height=","hl=","hs=","kl=","lang=","loc=","lr=","matchmode=","medor=","message=","meta=","mode=","order=","page=","par=","pays=","pg=","pos=","prg=","qc=","refer=","sa=","safe=","sc=","sort=","src=","start=","stype=","tag=","temp=","theme=","url=","user=","width=","what=","\\.x=","\\.y=");
# Never put the following exclusion ("ask=","claus=","general=","kw=","keyword=","MT","p=","q=","qr=","qt=","query=","s=","search=","searchText=","string=","su=") because they are strings that contain keywords we're looking for.

# HTTP codes with tooltip
%httpcode = (
"201", "Partial Content", "202", "Request recorded, will be executed later", "204", "Request executed", "206", "Partial Content",
"301", "Moved Permanently", "302", "Found",
"400", "Bad Request", "401", "Unauthorized", "403", "Forbidden", "404", "Not Found", "408", "Request Timeout",
"500", "Internal Error", "501", "Not implemented", "502", "Received bad response from real server", "503", "Server busy", "504", "Gateway Time-Out", "505", "HTTP version not supported",

"200", "OK", "304", "Not Modified"	# 200 and 304 are not errors
);

# Browser lists ("browser id in lower case", "browser text")
%BrowsersHash = (
"msie","defined_later",
"netscape","defined_later",
# Most frequent browsers should be first in this list
"lynx","Lynx",						
"opera","Opera",
"wget","Wget",
"22acidownload","22AciDownload",
"aol\\-iweng","AOL-Iweng",
"amaya","Amaya",
"amigavoyager","AmigaVoyager",
"antfresco","ANT Fresco",
"bpftp","BPFTP",
"cyberdog","Cyberdog",
"dreamcast","Dreamcast",
"downloadagent","DownloadAgent",
"ecatch", "eCatch",
"emailsiphon","EmailSiphon",
"friendlyspider","FriendlySpider",
"getright","GetRight",
"headdump","HeadDump",
"hotjava","Sun HotJava",
"ibrowse","IBrowse",
"icab","iCab",
"intergo","InterGO",
"konqueror","Konqueror",
"linemodebrowser","W3C Line Mode Browser",
"lotus-notes","Lotus Notes web client",
"macweb","MacWeb",
"ncsa_mosaic","NCSA Mosaic",
"netpositive","NetPositive",
"nutscrape", "Nutscrape",
"mspie","MS Pocket Internet Explorer",
"msfrontpageexpress","MS FrontPage Express",
"omniweb","OmniWeb",
"teleport","TelePort Pro (Site grabber)",
"tzgeturl","TZGETURL",
"viking","Viking",
"webcapture","Acrobat (Site grabber)",
"webfetcher","WebFetcher",
"webtv","WebTV browser",
"webexplorer","IBM-WebExplorer",
"webmirror","WebMirror",
"webvcr","WebVCR",
"libwww","LibWWW",				# Must be at end because some browser have both "browser id" and "libwww"
# Music only browsers
"real","RealAudio or compatible player",
"winamp","WinAmp",				# Works for winampmpeg and winamp3httprdr
"xmms","XMMS",
"audion","Audion",
"freeamp","FreeAmp",
"windows-media-player","Windows Media Player",
"jetaudio","JetAudio",
"uplayer","Ultra Player",
"itunes","Apple iTunes",
"xaudio","Some XAudio Engine based MPEG player",
"nsplayer","NetShow Player",
"mint_audio","Mint Audio",
"mpg123","mpg123",
# Other kind of browsers
"webzip","WebZIP"
);

# OS lists ("os detector in lower case","os text")
%OSHash      = (
"winme","Windows Me",
"win2000","Windows 2000",
"winnt","Windows NT",
"win98","Windows 98",
"win95","Windows 95",
"win16","Windows 3.xx",
"wince","Windows CE",
"beos","BeOS",
"macintosh","Mac OS",
"unix","Unknown Unix system",
"linux","Linux",
"os/2","Warp OS/2",
"amigaos","AmigaOS",
"sunos","Sun Solaris",
"irix","Irix",
"osf","OSF Unix",
"hp-ux","HP Unix",
"aix","Aix",
"netbsd","NetBSD",
"bsdi","BSDi",
"freebsd","FreeBSD",
"openbsd","OpenBSD",
"webtv","WebTV",
"cp/m","CPM",
"crayos","CrayOS",
"riscos","Acorn RISC OS"
);

# OS AliasHash ("text that match in log after changing ' ' or '+' into '_' ","osid")
%OSAliasHash	= (
"windows_me","winme",
"windows_2000","win2000",
"windows_nt_5","win2000",
"windows_nt","winnt",
"windows-nt","winnt",
"win32","winnt",
"windows_98","win98",
"windows_95","win95",
"windows_3","win16",			# This works for windows_31 and windows_3.1
"windows;i;16","win16",
"windows_ce","wince",
"mac_p","macintosh",			# This works for mac_ppc and mac_powerpc
"mac_68","macintosh",			# This works for mac_6800 and mac_68k
"macppc","macintosh",
"macweb","macintosh"
);

# Robots list
# List can be found at http://info.webcrawler.com/mak/projects/robots/active.html and the next command show how to generate tab list from this file:
# cat robotslist.txt | sed 's/:/ /' | awk ' /robot-id/ { name=tolower($2); } /robot-name/ { print "\""name"\", \""$0"\"," } ' | sed 's/robot-name *//g' > file
# Rem: To avoid bad detection, some robots id were removed from this list:
#      - Robots with ID of 2 letters only
#      - Robot called "webs"
# Rem: directhit is changed in direct_hit (its real id)
%RobotHash   = (
"acme.spider", "Acme.Spider",
"ahoythehomepagefinder", "Ahoy! The Homepage Finder",
"alkaline", "Alkaline",
"appie", "Walhello appie",
"arachnophilia", "Arachnophilia",
"architext", "ArchitextSpider",
"aretha", "Aretha",
"ariadne", "ARIADNE",
"aspider", "ASpider (Associative Spider)",
"atn.txt", "ATN Worldwide",
"atomz", "Atomz.com Search Robot",
"auresys", "AURESYS",
"backrub", "BackRub",
"bigbrother", "Big Brother",
"bjaaland", "Bjaaland",
"blackwidow", "BlackWidow",
"blindekuh", "Die Blinde Kuh",
"bloodhound", "Bloodhound",
"brightnet", "bright.net caching robot",
"bspider", "BSpider",
"cactvschemistryspider", "CACTVS Chemistry Spider",
"calif", "Calif",
"cassandra", "Cassandra",
"cgireader", "Digimarc Marcspider/CGI",
"checkbot", "Checkbot",
"churl", "churl",
"cmc", "CMC/0.01",
"collective", "Collective",
"combine", "Combine System",
"conceptbot", "Conceptbot",
"core", "Web Core / Roots",
"cshkust", "CS-HKUST WISE: WWW Index and Search Engine",
"cusco", "Cusco",
"cyberspyder", "CyberSpyder Link Test",
"deweb", "DeWeb(c) Katalog/Index",
"dienstspider", "DienstSpider",
"diibot", "Digital Integrity Robot",
"direct_hit", "Direct Hit Grabber",
"dnabot", "DNAbot",
"download_express", "DownLoad Express",
"dragonbot", "DragonBot",
"dwcp", "DWCP (Dridus' Web Cataloging Project)",
"ebiness", "EbiNess",
"eit", "EIT Link Verifier Robot",
"emacs", "Emacs-w3 Search Engine",
"emcspider", "ananzi",
"esther", "Esther",
"evliyacelebi", "Evliya Celebi",
"fdse", "Fluid Dynamics Search Engine robot",
"felix", "	Felix IDE",
"ferret", "Wild Ferret Web Hopper #1, #2, #3",
"fetchrover", "FetchRover",
"fido", "fido",
"finnish", "Hämähäkki",
"fireball", "KIT-Fireball",
"fish", "Fish search",
"fouineur", "Fouineur",
"francoroute", "Robot Francoroute",
"freecrawl", "Freecrawl",
"funnelweb", "FunnelWeb",
"gazz", "gazz",
"gcreep", "GCreep",
"getbot", "GetBot",
"geturl", "GetURL",
"golem", "Golem",
"googlebot", "Googlebot",
"grapnel", "Grapnel/0.01 Experiment",
"griffon", "Griffon",
"gromit", "Gromit",
"gulliver", "Northern Light Gulliver",
"hambot", "HamBot",
"harvest", "Harvest",
"havindex", "havIndex",
"hometown", "Hometown Spider Pro",
"wired-digital", "Wired Digital",
"htdig", "ht://Dig",
"htmlgobble", "HTMLgobble",
"hyperdecontextualizer", "Hyper-Decontextualizer",
"ibm", "IBM_Planetwide",
"iconoclast", "Popular Iconoclast",
"ilse", "Ingrid",
"imagelock", "Imagelock ",
"incywincy", "IncyWincy",
"informant", "Informant",
"infoseek", "InfoSeek Robot 1.0",
"infoseeksidewinder", "Infoseek Sidewinder",
"infospider", "InfoSpiders",
"inspectorwww", "Inspector Web",
"intelliagent", "IntelliAgent",
"iron33", "Iron33",
"israelisearch", "Israeli-search",
"javabee", "JavaBee",
"jcrawler", "JCrawler",
"jeeves", "Jeeves",
"jobot", "Jobot",
"joebot", "JoeBot",
"jubii", "The Jubii Indexing Robot",
"jumpstation", "JumpStation",
"katipo", "Katipo",
"kdd", "KDD-Explorer",
"kilroy", "Kilroy",
"ko_yappo_robot", "KO_Yappo_Robot",
"labelgrabber.txt", "LabelGrabber",
"larbin", "larbin",
"legs", "legs",
"linkscan", "LinkScan",
"linkwalker", "LinkWalker",
"lockon", "Lockon",
"logo_gif", "logo.gif Crawler",
"lycos", "Lycos",
"macworm", "Mac WWWWorm",
"magpie", "Magpie",
"mediafox", "MediaFox",
"merzscope", "MerzScope",
"meshexplorer", "NEC-MeshExplorer",
"mindcrawler", "MindCrawler",
"moget", "moget",
"momspider", "MOMspider",
"monster", "Monster",
"motor", "Motor",
"muscatferret", "Muscat Ferret",
"mwdsearch", "Mwd.Search",
"myweb", "Internet Shinchakubin",
"netcarta", "NetCarta WebMap Engine",
"netmechanic", "NetMechanic",
"netscoop", "NetScoop",
"newscan-online", "newscan-online",
"nhse", "NHSE Web Forager",
"nomad", "Nomad",
"northstar", "The NorthStar Robot",
"nzexplorer", "nzexplorer",
"occam", "Occam",
"octopus", "HKU WWW Octopus",
"orb_search", "Orb Search",
"packrat", "Pack Rat",
"pageboy", "PageBoy",
"parasite", "ParaSite",
"patric", "Patric",
"perignator", "The Peregrinator",
"perlcrawler", "PerlCrawler 1.0",
"phantom", "Phantom",
"piltdownman", "PiltdownMan",
"pioneer", "Pioneer",
"pitkow", "html_analyzer",
"pjspider", "Portal Juice Spider",
"pka", "PGP Key Agent",
"plumtreewebaccessor", "PlumtreeWebAccessor",
"poppi", "Poppi",
"portalb", "PortalB Spider",
"puu", "GetterroboPlus Puu",
"python", "The Python Robot",
"raven", "Raven Search",
"rbse", "RBSE Spider",
"resumerobot", "Resume Robot",
"rhcs", "RoadHouse Crawling System",
"roadrunner", "Road Runner: The ImageScape Robot",
"robbie", "Robbie the Robot",
"robi", "ComputingSite Robi/1.0",
"roverbot", "Roverbot",
"safetynetrobot", "SafetyNet Robot",
"scooter", "Scooter",
"search_au", "Search.Aus-AU.COM",
"searchprocess", "SearchProcess",
"senrigan", "Senrigan",
"sgscout", "SG-Scout",
"shaggy", "ShagSeeker",
"shaihulud", "Shai'Hulud",
"sift", "Sift",
"simbot", "Simmany Robot Ver1.0",
"site-valet", "Site Valet",
"sitegrabber", "Open Text Index Robot",
"sitetech", "SiteTech-Rover",
"slurp", "Inktomi Slurp",
"smartspider", "Smart Spider",
"snooper", "Snooper",
"solbot", "Solbot",
"spanner", "Spanner",
"speedy", "Speedy Spider",
"spider_monkey", "spider_monkey",
"spiderbot", "SpiderBot",
"spiderman", "SpiderMan",
"spry", "Spry Wizard Robot",
"ssearcher", "Site Searcher",
"suke", "Suke",
"sven", "Sven",
"tach_bw", "TACH Black Widow",
"tarantula", "Tarantula",
"tarspider", "tarspider",
"tcl", "Tcl W3 Robot",
"techbot", "TechBOT",
"templeton", "Templeton",
"titin", "TitIn",
"titan", "TITAN",
"tkwww", "The TkWWW Robot",
"tlspider", "TLSpider",
"ucsd", "UCSD Crawl",
"udmsearch", "UdmSearch",
"urlck", "URL Check",
"valkyrie", "Valkyrie",
"victoria", "Victoria",
"visionsearch", "vision-search",
"voyager", "Voyager",
"vwbot", "VWbot",
"w3index", "The NWI Robot",
"w3m2", "W3M2",
"wanderer", "the World Wide Web Wanderer",
"webbandit", "WebBandit Web Spider",
"webcatcher", "WebCatcher",
"webcopy", "WebCopy",
"webfetcher", "webfetcher",
"webfoot", "The Webfoot Robot",
"weblayers", "Weblayers",
"weblinker", "WebLinker",
"webmirror", "WebMirror",
"webmoose", "The Web Moose",
"webquest", "WebQuest",
"webreader", "Digimarc MarcSpider",
"webreaper", "WebReaper",
"websnarf", "Websnarf",
"webspider", "WebSpider",
"webvac", "WebVac",
"webwalk", "webwalk",
"webwalker", "WebWalker",
"webwatch", "WebWatch",
"wget", "Wget",
"whowhere", "WhoWhere Robot",
"wmir", "w3mir",
"wolp", "WebStolperer",
"wombat", "The Web Wombat ",
"worm", "The World Wide Web Worm",
"wwwc", "WWWC Ver 0.2.5",
"wz101", "WebZinger",
"xget", "XGET",
"nederland.zoek", "Nederland.zoek",

# Not declared robots
"antibot", "Antibot (Not referenced robot)",
"daviesbot", "DaviesBot (Not referenced robot)",
"ezresult",	"Ezresult (Not referenced robot)",
"fast-webcrawler", "Fast-Webcrawler (Not referenced robot)",
"gnodspider","GNOD Spider (Not referenced robot)",
"jennybot", "JennyBot (Not referenced robot)",
"justview", "JustView (Not referenced robot)",
"mercator", "Mercator (Not referenced robot)",
#"msiecrawler", "MSIECrawler (Not referenced robot)",	MSIECrawler seems to be a grabber not a robot
"perman surfer", "Perman surfer (Not referenced robot)",
"shoutcast","Shoutcast Directory Service (Not referenced robot)",
"unlost_web_crawler", "Unlost_Web_Crawler (Not referenced robot)",
"webbase", "WebBase (Not referenced robot)",
"yandex", "Yandex bot (Not referenced robot)",
# Supposed to be robots
"webcompass", "webcompass (Not referenced robot)",
"digout4u", "digout4u (Not referenced robot)",
"echo", "EchO! (Not referenced robot)",
"voila", "Voila (Not referenced robot)",
"boris", "Boris (Not referenced robot)",
"ultraseek", "Ultraseek (Not referenced robot)",
"ia_archiver", "ia_archiver (Not referenced robot)",
# Generic ID
"robot", "Unknown robot (Not referenced robot)"
);

# Domains list
%DomainsHash = (
"localhost","localhost",

"ad","Andorra","ae","United Arab Emirates","aero","Aero/Travel domains","af","Afghanistan","ag",
"Antigua and Barbuda","ai","Anguilla","al","Albania","am",
"Armenia","an","Netherlands Antilles","ao","Angola","aq",
"Antarctica","ar","Argentina","arpa","Old style Arpanet","as",
"American Samoa","at","Austria","au","Australia","aw","Aruba","az",
"Azerbaidjan","ba","Bosnia-Herzegovina","bb","Barbados","bd",
"Bangladesh","be","Belgium","bf","Burkina Faso","bg","Bulgaria",
"bh","Bahrain","bi","Burundi","biz","Biz domains","bj","Benin","bm","Bermuda","bn",
"Brunei Darussalam","bo","Bolivia","br","Brazil","bs","Bahamas",
"bt","Bhutan","bv","Bouvet Island","bw","Botswana","by","Belarus",
"bz","Belize","ca","Canada","cc","Cocos (Keeling) Islands","cf",
"Central African Republic","cg","Congo","ch","Switzerland","ci",
"Ivory Coast (Cote D'Ivoire)","ck","Cook Islands","cl","Chile","cm","Cameroon",
"cn","China","co","Colombia","com","Commercial","coop","Coop domains","cr","Costa Rica",
"cs","Former Czechoslovakia","cu","Cuba","cv","Cape Verde","cx",
"Christmas Island","cy","Cyprus","cz","Czech Republic","de","Germany",
"dj","Djibouti","dk","Denmark","dm","Dominica","do","Dominican Republic",
"dz","Algeria","ec","Ecuador","edu","USA Educational","ee","Estonia",
"eg","Egypt","eh","Western Sahara","es","Spain","et","Ethiopia","fi","Finland","fj","Fiji","fk",
"Falkland Islands","fm","Micronesia","fo","Faroe Islands",
"fr","France","fx","France (European Territory)","ga","Gabon","gb",
"Great Britain","gd","Grenada","ge","Georgia","gf","French Guyana","gh","Ghana","gi","Gibraltar",
"gl","Greenland","gm","Gambia","gn","Guinea","gov","USA Government","gp","Guadeloupe (French)","gq",
"Equatorial Guinea","gr","Greece","gs","S. Georgia &amp; S. Sandwich Isls.",
"gt","Guatemala","gu","Guam (USA)","gw","Guinea Bissau","gy","Guyana",
"hk","Hong Kong","hm","Heard and McDonald Islands","hn","Honduras","hr",
"Croatia","ht","Haiti","hu","Hungary","id","Indonesia","ie","Ireland","il","Israel",
"in","India","info","Info domains","int","International","io","British Indian Ocean Territory",
"iq","Iraq","ir","Iran","is","Iceland","it","Italy","jm",
"Jamaica","jo","Jordan","jp","Japan","ke","Kenya","kg","Kyrgyzstan",
"kh","Cambodia","ki","Kiribati","km","Comoros","kn","Saint Kitts &amp; Nevis Anguilla",
"kp","North Korea","kr","South Korea","kw","Kuwait","ky",
"Cayman Islands","kz","Kazakhstan","la","Laos","lb","Lebanon","lc","Saint Lucia",
"li","Liechtenstein","lk","Sri Lanka","lr","Liberia","ls","Lesotho","lt","Lithuania",
"lu","Luxembourg","lv","Latvia","ly","Libya","ma","Morocco","mc","Monaco",
"md","Moldavia","mg","Madagascar","mh","Marshall Islands","mil","USA Military","mk",
"Macedonia","ml","Mali","mm","Myanmar","mn","Mongolia","mo","Macau",
"mp","Northern Mariana Islands","mq","Martinique (French)","mr","Mauritania",
"ms","Montserrat","mt","Malta","mu","Mauritius","musuem","Museum domains","mv","Maldives","mw",
"Malawi","mx","Mexico","my","Malaysia","mz","Mozambique","na","Namibia","name","Name domains","nato","NATO",
"nc","New Caledonia (French)","ne","Niger","net","Network","nf","Norfolk Island",
"ng","Nigeria","ni","Nicaragua","nl","Netherlands","no","Norway",
"np","Nepal","nr","Nauru","nt","Neutral Zone","nu","Niue","nz","New Zealand","om","Oman","org",
"Non-Profit Organizations","pa","Panama","pe","Peru","pf","Polynesia (French)",
"pg","Papua New Guinea","ph","Philippines","pk","Pakistan","pl","Poland",
"pm","Saint Pierre and Miquelon","pn","Pitcairn Island","pr","Puerto Rico","pro","Professional domains",
"pt","Portugal","pw","Palau","py","Paraguay","qa","Qatar",
"re","Reunion (French)","ro","Romania","ru","Russian Federation","rw","Rwanda",
"sa","Saudi Arabia","sb","Solomon Islands","sc","Seychelles","sd",
"Sudan","se","Sweden","sg","Singapore","sh","Saint Helena","si","Slovenia",
"sj","Svalbard and Jan Mayen Islands","sk","Slovak Republic","sl","Sierra Leone",
"sm","San Marino","sn","Senegal","so","Somalia","sr","Suriname","st",
"Saint Tome and Principe","su","Former USSR","sv","El Salvador","sy","Syria","sz","Swaziland","tc",
"Turks and Caicos Islands","td","Chad","tf","French Southern Territories","tg","Togo",
"th","Thailand","tj","Tadjikistan","tk","Tokelau","tm","Turkmenistan","tn","Tunisia",
"to","Tonga","tp","East Timor","tr","Turkey","tt","Trinidad and Tobago","tv","Tuvalu",
"tw","Taiwan","tz","Tanzania","ua","Ukraine","ug","Uganda","uk",
"United Kingdom","um","USA Minor Outlying Islands","us","United States",
"uy","Uruguay","uz","Uzbekistan","va","Vatican City State","vc",
"Saint Vincent &amp; Grenadines","ve","Venezuela","vg","Virgin Islands (British)",
"vi","Virgin Islands (USA)","vn","Vietnam","vu","Vanuatu","wf","Wallis and Futuna Islands",
"ws","Samoa","ye","Yemen","yt","Mayotte","yu","Yugoslavia","za","South Africa",
"zm","Zambia","zr","Zaire","zw","Zimbabwe"
);

# ---------- Translation tables --------
# English
$message[0][0]="Unknown";
$message[1][0]="Unknown (unresolved ip)";
$message[2][0]="Others";
$message[3][0]="View details";
$message[4][0]="Day";
$message[5][0]="Month";
$message[6][0]="Year";
$message[7][0]="Statistics of";
$message[8][0]="First visit";
$message[9][0]="Last visit";
$message[10][0]="Number of visits";
$message[11][0]="Unique visitors";
$message[12][0]="Visit";
$message[13][0]="Keyword";
$message[14][0]="Search";
$message[15][0]="Percent";
$message[16][0]="Traffic Summary";
$message[17][0]="Domains/Countries";
$message[18][0]="Visitors";
$message[19][0]="Pages/URL";
$message[20][0]="Hours (Server time)";
$message[21][0]="Browsers";
$message[22][0]="HTTP Errors";
$message[23][0]="Referers";
$message[24][0]="Search&nbsp;Keywords";
$message[25][0]="Visitors domains/countries";
$message[26][0]="hosts";
$message[27][0]="pages";
$message[28][0]="different pages";
$message[29][0]="Access";
$message[30][0]="Other words";
$message[31][0]="Pages not found";
$message[32][0]="HTTP Error codes";
$message[33][0]="Netscape versions";
$message[34][0]="IE versions";
$message[35][0]="Last Update";
$message[36][0]="Connect to site from";
$message[37][0]="Origin";
$message[38][0]="Direct address / Bookmarks";
$message[39][0]="Links from a Newsgroup";
$message[40][0]="Links from an Internet Search Engine";
$message[41][0]="Links from an external page (other web sites except search engines)";
$message[42][0]="Links from an internal page (other page on same site)";
$message[43][0]="keywords used on search engines";
$message[44][0]="Kb";
$message[45][0]="Unresolved IP Address";
$message[46][0]="Unknown OS (Referer field)";
$message[47][0]="Required but not found URLs (HTTP code 404)";
$message[48][0]="IP Address";
$message[49][0]="Error&nbsp;Hits";
$message[50][0]="Unknown browsers (Referer field)";
$message[51][0]="Visiting robots";
$message[52][0]="visits/visitor";
$message[53][0]="Robots/Spiders visitors";
$message[54][0]="Free realtime logfile analyzer for advanced web statistics";
$message[55][0]="of";
$message[56][0]="Pages";
$message[57][0]="Hits";
$message[58][0]="Versions";
$message[59][0]="Operating Systems";
$message[60][0]="Jan";
$message[61][0]="Feb";
$message[62][0]="Mar";
$message[63][0]="Apr";
$message[64][0]="May";
$message[65][0]="Jun";
$message[66][0]="Jul";
$message[67][0]="Aug";
$message[68][0]="Sep";
$message[69][0]="Oct";
$message[70][0]="Nov";
$message[71][0]="Dec";
$message[72][0]="English us.png";
$message[73][0]="Day statistics";
$message[74][0]="Update";

# French
$message[0][1]="Inconnus";
$message[1][1]="Inconnu (IP non résolue)";
$message[2][1]="Autres";
$message[3][1]="Voir détails";
$message[4][1]="Jour";
$message[5][1]="Mois";
$message[6][1]="Année";
$message[7][1]="Statistiques du site";
$message[8][1]="Première visite";
$message[9][1]="Dernière visite";
$message[10][1]="Visites";
$message[11][1]="Visiteurs différents";
$message[12][1]="Visite";
$message[13][1]="Mot clé";
$message[14][1]="Recherche";
$message[15][1]="Pourcentage";
$message[16][1]="Résumé";
$message[17][1]="Domaines/Pays";
$message[18][1]="Visiteurs";
$message[19][1]="Pages/URL";
$message[20][1]="Heures (Heures du serveur)";
$message[21][1]="Navigateurs";
$message[22][1]="Erreurs HTTP";
$message[23][1]="Origine/Referrer";
$message[24][1]="Mots&nbsp;clés&nbsp;de&nbsp;recherche";
$message[25][1]="Domaines/pays visiteurs";
$message[26][1]="des hôtes";
$message[27][1]="des pages";
$message[28][1]="pages différentes";
$message[29][1]="Accès";
$message[30][1]="Autres mots";
$message[31][1]="Pages non trouvées";
$message[32][1]="Codes Erreurs HTTP";
$message[33][1]="Versions de Netscape";
$message[34][1]="Versions de MS Internet Explorer";
$message[35][1]="Dernière mise à jour";
$message[36][1]="Connexions au site par";
$message[37][1]="Origine de la connexion";
$message[38][1]="Adresse directe / Bookmarks";
$message[39][1]="Lien depuis un Newsgroup";
$message[40][1]="Lien depuis un moteur de recherche Internet";
$message[41][1]="Lien depuis une page externe (autres sites, hors moteurs de recherche)";
$message[42][1]="Lien depuis une page interne (autre page du site)";
$message[43][1]="des critères de recherches utilisés";
$message[44][1]="Ko";
$message[45][1]="Adresses IP des visiteurs non identifiables (IP non résolue)";
$message[46][1]="OS non reconnus (champ referer brut)";
$message[47][1]="URLs du site demandées non trouvées (Code HTTP 404)";
$message[48][1]="Adresse IP";
$message[49][1]="Hits&nbsp;en&nbsp;échec";
$message[50][1]="Navigateurs non reconnus (champ referer brut)";
$message[51][1]="Robots visiteurs";
$message[52][1]="visite/visiteur";
$message[53][1]="Visiteurs Robots/Spiders";
$message[54][1]="Analyseur de log gratuit pour statistiques Web avancées";
$message[55][1]="sur";
$message[56][1]="Pages";
$message[57][1]="Hits";
$message[58][1]="Versions";
$message[59][1]="Systèmes exploitation";
$message[60][1]="Jan";
$message[61][1]="Fév";
$message[62][1]="Mar";
$message[63][1]="Avr";
$message[64][1]="Mai";
$message[65][1]="Juin";
$message[66][1]="Juil";
$message[67][1]="Août";
$message[68][1]="Sep";
$message[69][1]="Oct";
$message[70][1]="Nov";
$message[71][1]="Déc";
$message[72][1]="French fr.png";
$message[73][1]="Statistiques par jour";
$message[74][1]="Mise à jour";

# Dutch
$message[0][2]="Onbekend";
$message[1][2]="Onbekend (Onbekend ip)";
$message[2][2]="Andere";
$message[3][2]="Bekijk details";
$message[4][2]="Dag";
$message[5][2]="Maand";
$message[6][2]="Jaar";
$message[7][2]="Statistieken van";
$message[8][2]="Eerste bezoek";
$message[9][2]="Laatste bezoek";
$message[10][2]="Aantal bezoeken";
$message[11][2]="Unieke bezoekers";
$message[12][2]="Bezoek";
$message[13][2]="Trefwoord";
$message[14][2]="Zoek";
$message[15][2]="Procent";
$message[16][2]="Opsomming";
$message[17][2]="Domeinen/Landen";
$message[18][2]="Bezoekers";
$message[19][2]="Pagina's/URL";
$message[20][2]="Uren";
$message[21][2]="Browsers";
$message[22][2]="HTTP Foutmeldingen";
$message[23][2]="Verwijzing";
$message[24][2]="Zoek&nbsp;trefwoorden";
$message[25][2]="Bezoekers domeinen/landen";
$message[26][2]="hosts";
$message[27][2]="pagina's";
$message[28][2]="verschillende pagina's";
$message[29][2]="Toegang";
$message[30][2]="Andere woorden";
$message[31][2]="Pages not found";
$message[32][2]="HTTP foutmelding codes";
$message[33][2]="Netscape versies";
$message[34][2]="MS Internet Explorer versies";
$message[35][2]="Last Update";
$message[36][2]="Verbinding naar site vanaf";
$message[37][2]="Herkomst";
$message[38][2]="Direkt adres / Bookmarks";
$message[39][2]="Link vanuit een nieuwsgroep";
$message[40][2]="Link vanuit een Internet Zoek Machine";
$message[41][2]="Link vanuit een externe pagina (andere web sites behalve zoek machines)";
$message[42][2]="Link vanuit een interne pagina (andere pagina van dezelfde site)";
$message[43][2]="gebruikte trefwoorden bij zoek machines";
$message[44][2]="Kb";
$message[45][2]="niet vertaald  IP Adres";
$message[46][2]="Onbekend OS (Referer veld)";
$message[47][2]="Verplicht maar niet gvonden URLs (HTTP code 404)";
$message[48][2]="IP Adres";
$message[49][2]="Fout&nbsp;Hits";
$message[50][2]="Onbekende browsers (Referer veld)";
$message[51][2]="Bezoekende robots";
$message[52][2]="bezoeken/bezoeker";
$message[53][2]="Robots/Spiders bezoekers";
$message[54][2]="Gratis realtime logbestand analyzer voor geavanceerde web statistieken";
$message[55][2]="van";
$message[56][2]="Pagina's";
$message[57][2]="Hits";
$message[58][2]="Versies";
$message[59][2]="OS";
$message[60][2]="Jan";
$message[61][2]="Feb";
$message[62][2]="Mar";
$message[63][2]="Apr";
$message[64][2]="May";
$message[65][2]="Jun";
$message[66][2]="Jul";
$message[67][2]="Aug";
$message[68][2]="Sep";
$message[69][2]="Oct";
$message[70][2]="Nov";
$message[71][2]="Dec";
$message[72][2]="Dutch nl.png";
$message[73][2]="Dag statistieken";
$message[74][2]="Update";

# Spanish
$message[0][3]="Desconocido";
$message[1][3]="Dirección IP desconocida";
$message[2][3]="Otros";
$message[3][3]="Vea detalles";
$message[4][3]="Día";
$message[5][3]="Mes";
$message[6][3]="Año";
$message[7][3]="Estadísticas del sitio";
$message[8][3]="Primera visita";
$message[9][3]="Última visita";
$message[10][3]="Número de visitas";
$message[11][3]="Visitantes distintos";
$message[12][3]="Visita";
$message[13][3]="Palabra clave (keyword)";
$message[14][3]="Búsquedas";
$message[15][3]="Porciento";
$message[16][3]="Resumen de tráfico";
$message[17][3]="Dominios/Países";
$message[18][3]="Visitantes";
$message[19][3]="Páginas/URLs";
$message[20][3]="Horas";
$message[21][3]="Navegadores";
$message[22][3]="Errores";
$message[23][3]="Enlaces (Links)";
$message[24][3]="Palabra&nbsp;clave&nbsp;de&nbsp;búsqueda";
$message[25][3]="Dominios/Países de visitantes";
$message[26][3]="servidores";
$message[27][3]="páginas";
$message[28][3]="páginas diferentes";
$message[29][3]="Acceso";
$message[30][3]="Otras palabras";
$message[31][3]="Pages not found";
$message[32][3]="Códigos de Errores de Protocolo HTTP";
$message[33][3]="Versiones de Netscape";
$message[34][3]="Versiones de MS Internet Explorer";
$message[35][3]="Last Update";
$message[36][3]="Enlaces (links) al sitio";
$message[37][3]="Origen de enlace";
$message[38][3]="Dirección directa / Favoritos";
$message[39][3]="Enlaces desde Newsgroups";
$message[40][3]="Enlaces desde algún motor de búsqueda";
$message[41][3]="Enlaces desde páginas externas (exeptuando motores de búsqueda)";
$message[42][3]="Enlaces desde páginas internas (otras páginas del sitio)";
$message[43][3]="Palabras clave utilizada por el motor de búsqueda";
$message[44][3]="Kb";
$message[45][3]="Dirección IP no identificada";
$message[46][3]="Sistema Operativo desconocido (campo de referencia)";
$message[47][3]="URLs necesarios pero no encontados (código 404 de protocolo HTTP)";
$message[48][3]="Dirección IP";
$message[49][3]="Hits&nbsp;erróneos";
$message[50][3]="Navegadores desconocidos (campo de referencia)";
$message[51][3]="Visitas de Robots";
$message[52][3]="Visitas/Visitante";
$message[53][3]="Visitas de Robots/Spiders (indexadores)";
$message[54][3]="Analizador gratuito de 'log' para estadísticas Web avanzadas";
$message[55][3]="de";
$message[56][3]="Páginas";
$message[57][3]="Hits";
$message[58][3]="Versiones";
$message[59][3]="Sistema Operativo";
$message[60][3]="Ene";
$message[61][3]="Feb";
$message[62][3]="Mar";
$message[63][3]="Abr";
$message[64][3]="May";
$message[65][3]="Jun";
$message[66][3]="Jul";
$message[67][3]="Ago";
$message[68][3]="Sep";
$message[69][3]="Oct";
$message[70][3]="Nov";
$message[71][3]="Dic";
$message[72][3]="Spanish es.png";
$message[73][3]="Dia estadísticas";
$message[74][3]="Update";

# Italian
$message[0][4]="Sconosciuto";
$message[1][4]="Sconosciuto (ip non risolto)";
$message[2][4]="Altri";
$message[3][4]="Vedi dettagli";
$message[4][4]="Giorno";
$message[5][4]="Mese";
$message[6][4]="Anno";
$message[7][4]="Statistiche di";
$message[8][4]="Prima visita";
$message[9][4]="Ultima visita";
$message[10][4]="Visite";
$message[11][4]="Visitatori diverse";
$message[12][4]="Visite";
$message[13][4]="Parole chiave";
$message[14][4]="Ricerche";
$message[15][4]="Percentuali";
$message[16][4]="Riassunto del traffico";
$message[17][4]="Domini/Nazioni";
$message[18][4]="Visitatori";
$message[19][4]="Pagine/URL";
$message[20][4]="Ore";
$message[21][4]="Browsers";
$message[22][4]="Errori HTTP";
$message[23][4]="Origine/Riferimenti";
$message[24][4]="Ricerche&nbsp;Parole chiave";
$message[25][4]="Visitatori per domini/nazioni";
$message[26][4]="hosts";
$message[27][4]="pagine";
$message[28][4]="pagine diverse";
$message[29][4]="Accessi";
$message[30][4]="Altre parole";
$message[31][4]="Pages not found";
$message[32][4]="Codici di errori HTTP";
$message[33][4]="Netscape versione";
$message[34][4]="MS Internet Explorer versione";
$message[35][4]="Last Update";
$message[36][4]="Connesso al sito da";
$message[37][4]="Origine";
$message[38][4]="Indirizzo diretto / segnalibro";
$message[39][4]="Link da un  Newsgroup";
$message[40][4]="Link da un motore di ricerca";
$message[41][4]="Link da una pagina esterna (altri siti eccetto i motori di ricerca)";
$message[42][4]="Link da una pagina interna (altre pagine dello stesso sito)";
$message[43][4]="Parole chiave usate dai motori di ricerca";
$message[44][4]="Kb";
$message[45][4]="Indirizzi IP non risolti";
$message[46][4]="Sistemi operativi non conosciuti (Campo di riferimento)";
$message[47][4]="Richiesto un URL ma non trovato (HTTP codice 404)";
$message[48][4]="Indirizzo IP";
$message[49][4]="Errori&nbsp;Punteggio";
$message[50][4]="Browser sconosciuti (Campo di riferimento)";
$message[51][4]="Visite di robots";
$message[52][4]="visite/visitatori";
$message[53][4]="Visite di Robots/Spiders";
$message[54][4]="Analizzatore gratuito in tempo reale dei file di log per statistiche avanzate";
$message[55][4]="it";
$message[56][4]="Pagine";
$message[57][4]="Hits";
$message[58][4]="Versioni";
$message[59][4]="Sistema Operativo";
$message[60][4]="Genn";
$message[61][4]="Febb";
$message[62][4]="Mar";
$message[63][4]="Apr";
$message[64][4]="Magg";
$message[65][4]="Giu";
$message[66][4]="Lug";
$message[67][4]="Ago";
$message[68][4]="Sep";
$message[69][4]="Oct";
$message[70][4]="Nov";
$message[71][4]="Dic";
$message[72][4]="Italian it.png";
$message[73][4]="Giorno statistiche";
$message[74][4]="Update";

# German
$message[0][5]="Unbekannt";
$message[1][5]="IP konnte nicht aufgeloest werden";
$message[2][5]="Sonstige";
$message[3][5]="Details";
$message[4][5]="Tag";
$message[5][5]="Monat";
$message[6][5]="Jahr";
$message[7][5]="Statistik ueber";
$message[8][5]="Erster Besuch";
$message[9][5]="Letzter Besuch";
$message[10][5]="Anzahl der Besucher";
$message[11][5]="Verschiedene Besucher";
$message[12][5]="Besuch";
$message[13][5]="Suchbegriffe";
$message[14][5]="Haeufigkeit";
$message[15][5]="Prozent";
$message[16][5]="Verkehr Gesamt";
$message[17][5]="Laender";
$message[18][5]="Besucher";
$message[19][5]="Besuchte Seiten";
$message[20][5]="Durchschn. Tagesverlauf";
$message[21][5]="Browser";
$message[22][5]="HTTP Status";
$message[23][5]="Referrer";
$message[24][5]="Suchbegriffe";
$message[25][5]="Laender aus denen die Besucher kamen";
$message[26][5]="Hosts";
$message[27][5]="Seiten";
$message[28][5]="Unterschiedliche Seiten";
$message[29][5]="Zugriffe";
$message[30][5]="Weitere Suchbegriffe";
$message[31][5]="Pages not found";
$message[32][5]="HTTP Status Meldungen";
$message[33][5]="Netscape Versionen";
$message[34][5]="MS Internet Explorer Versionen";
$message[35][5]="Last Update";
$message[36][5]="Woher die Besucher kamen";
$message[37][5]="Ursprung";
$message[38][5]="Direkter Zugriff / Bookmarks";
$message[39][5]="Link von einer Newsgroup";
$message[40][5]="Link von einer Suchmaschine";
$message[41][5]="Link von einer ext. Seite (nicht Suchmaschine!)";
$message[42][5]="Link von einer Seite innerhalb der Web Site";
$message[43][5]="Suchbegriffen (Suchmaschinen)";
$message[44][5]="Kb";
$message[45][5]="Unaufgeloeste IP Adresse";
$message[46][5]="Unbekanntes Betriebssystem [Referer]";
$message[47][5]="Nicht auffindbare Seiten [Error 404]";
$message[48][5]="IP Addresse";
$message[49][5]="Fehler / Hits";
$message[50][5]="Unbekannter Browser [Referer]";
$message[51][5]="Besuche von Robots / Spider";
$message[52][5]="Besuche / Besucher";
$message[53][5]="Besuche von Robots / Spider";
$message[54][5]="Programm zur erweiterten Echtzeitanalyse von Log-Dateien";
$message[55][5]="von";
$message[56][5]="Seiten";
$message[57][5]="Hits";
$message[58][5]="Ausführungen";
$message[59][5]="Unbekanntes Betriebssystem";
$message[60][5]="Jan";
$message[61][5]="Feb";
$message[62][5]="Mar";
$message[63][5]="Abr";
$message[64][5]="Mai";
$message[65][5]="Jun";
$message[66][5]="Juli";
$message[67][5]="Aug";
$message[68][5]="Sep";
$message[69][5]="Oct";
$message[70][5]="Nov";
$message[71][5]="Dez";
$message[72][5]="German de.png";
$message[73][5]="Tag statistik";
$message[74][5]="Update";

# Polish
$PageCode[6]="<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=iso-8859-2\">";
$message[0][6]="Nieznany";
$message[1][6]="Nieznany (brak odwzorowania IP w DNS)";
$message[2][6]="Inni";
$message[3][6]="Szczegó³y...";
$message[4][6]="Dzieñ";
$message[5][6]="Miesi±c";
$message[6][6]="Rok";
$message[7][6]="Statystyki";
$message[8][6]="Pierwsza wizyta";
$message[9][6]="Ostatnia wizyta";
$message[10][6]="Ilo¶æ wizyt";
$message[11][6]="Unikalnych go¶ci";
$message[12][6]="wizyt";
$message[13][6]="S³owo kluczowe";
$message[14][6]="Szukanych";
$message[15][6]="Procent";
$message[16][6]="Podsumowanie";
$message[17][6]="Domeny/Kraje";
$message[18][6]="Go¶cie";
$message[19][6]="Stron/URL-i";
$message[20][6]="Rozk³ad godzinny";
$message[21][6]="Przegl±darki";
$message[22][6]="B³êdy HTTP";
$message[23][6]="Referenci";
$message[24][6]="Wyszukiwarki&nbsp;-&nbsp;s³owa&nbsp;kluczowe";
$message[25][6]="Domeny/narodowo¶æ Internautów";
$message[26][6]="hosty";
$message[27][6]="strony";
$message[28][6]="ró¿nych stron";
$message[29][6]="Dostêp";
$message[30][6]="Inne s³owa";
$message[31][6]="Pages not found";
$message[32][6]="Kody b³êdów HTTP";
$message[33][6]="Wersje Netscape'a";
$message[34][6]="Wersje MS IE";
$message[35][6]="Last Update";
$message[36][6]="¬ród³a po³±czeñ";
$message[37][6]="Pochodzenie";
$message[38][6]="Dostêp bezpo¶redni lub z Ulubionych/Bookmarków";
$message[39][6]="Link z grupy dyskusyjnej";
$message[40][6]="Link z zagranicznej wyszukiwarki internetowej";
$message[41][6]="Link zewnêtrzny";
$message[42][6]="Link wewnêtrzny (z serwera na którym jest strona)";
$message[43][6]="S³owa kluczowe u¿yte w wyszukiwarkach internetowcyh";
$message[44][6]="Kb";
$message[45][6]="Nieznany (brak odwzorowania IP w DNS)";
$message[46][6]="Nieznany system operacyjny";
$message[47][6]="Nie znaleziony (B³±d HTTP 404)";
$message[48][6]="Adres IP";
$message[49][6]="Ilo¶æ&nbsp;b³êdów";
$message[50][6]="Nieznane przegl±darki";
$message[51][6]="Roboty sieciowe";
$message[52][6]="wizyt/go¶ci";
$message[53][6]="Roboty sieciowe";
$message[54][6]="Darmowy analizator logów on-line";
$message[55][6]="z";
$message[56][6]="Strony";
$message[57][6]="¯±dania";
$message[58][6]="Wersje";
$message[59][6]="Systemy operacyjne";
$message[60][6]="Styczeñ";
$message[61][6]="Luty";
$message[62][6]="Marzec";
$message[63][6]="Kwiecieñ";
$message[64][6]="Maj";
$message[65][6]="Czerwiec";
$message[66][6]="Lipiec";
$message[67][6]="Sierpieñ";
$message[68][6]="Wrzesieñ";
$message[69][6]="Pa¼dziernik";
$message[70][6]="Listopad";
$message[71][6]="Grudzieñ";
$message[72][6]="Polish pl.png";
$message[73][6]="Dzieñ Statystyki";
$message[74][6]="Update";

# Greek (simos@hellug.gr)
$PageCode[7]="<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=iso-8859-7\">";
$message[0][7]="¶ãíùóôï";
$message[1][7]="¶ãíùóôï (ìç áíáãíùñéóìÝíç ip)";
$message[2][7]="¶ëëïé";
$message[3][7]="ÅìöÜíéóç ëåðôïìåñéþí";
$message[4][7]="ÇìÝñá";
$message[5][7]="ÌÞíáò";
$message[6][7]="¸ôïò";
$message[7][7]="ÓôáôéóôéêÜ ôïõ";
$message[8][7]="Ðñþôç åðßóêåøç";
$message[9][7]="Ôåëåõôáßá åðßóêåøç";
$message[10][7]="Áñéèìüò åðéóêÝøåùí";
$message[11][7]="Ìïíáäéêïß åðéóêÝðôåò";
$message[12][7]="Åðßóêåøç";
$message[13][7]="ËÝîç-êëåéäß";
$message[14][7]="ÁíáæÞôçóç";
$message[15][7]="Ðïóïóôü";
$message[16][7]="Ðåñßëçøç Êõêëïöïñßáò";
$message[17][7]="ÅðéèÝìáôá/×þñåò";
$message[18][7]="ÅðéóêÝðôåò";
$message[19][7]="Óåëßäåò/URL";
$message[20][7]="¿ñåò";
$message[21][7]="ÖõëëïìåôñçôÝò";
$message[22][7]="ÓöÜëìáôá HTTP";
$message[23][7]="ÐáñáðÝìðôåò";
$message[24][7]="ËåêôéêÜ&nbsp;ÁíáæÞôçóçò";
$message[25][7]="ÅðéèÝìáôá/÷þñåò åðéóêåðôþí";
$message[26][7]="óõóôÞìáôá";
$message[27][7]="óåëßäåò";
$message[28][7]="äéáöïñåôéêÝò óåëßäåò";
$message[29][7]="Ðñüóâáóç";
$message[30][7]="¶ëëá ëåêôéêÜ";
$message[31][7]="Pages not found";
$message[32][7]="Êùäéêïß óöáëìÜôùí HTTP";
$message[33][7]="Åêäüóåéò Netscape";
$message[34][7]="Åêäüóåéò MS Internet Explorer";
$message[35][7]="Last Update";
$message[36][7]="Óýíäåóç óôï ôüðï áðü";
$message[37][7]="ÐñïÝëåõóç";
$message[38][7]="Åõèýò óýíäåóìïò / ÁãáðçìÝíá";
$message[39][7]="Óýíäåóìïò áðü ÏìÜäá ÓõæçôÞóåùí";
$message[40][7]="Óýíäåóìïò áðü Ìç÷áíÞ ÁíáæÞôçóçò ôïõ Internet";
$message[41][7]="Óýíäåóìïò áðü åîùôåñéêÞ óåëßäá (Üëëïé äéêôõáêïß ôüðïé åêôüò ìç÷áíþí áíáæÞôçóçò)";
$message[42][7]="Óýíäåóìïò áðü åóùôåñéêÞ óåëßäá (Üëëç óåëßäá óôïí ßäéï äéêôõáêü ôüðï)";
$message[43][7]="ëåêôéêÜ ðïõ ÷ñçóéìïðïéÞèçêáí óå ìç÷áíÝò áíáæÞôçóçò";
$message[44][7]="Kb";
$message[45][7]="Äéåõèýíóåéò IP ðïõ äåí áíáãíùñßóôçêáí";
$message[46][7]="¶ãíùóôï ëåéôïõñãéêü óýóôçìá (Ðåäßï ðáñÜðåìøçò)";
$message[47][7]="Áðáéôïýìåíá áëëÜ ÷ùñßò íá âñåèïýí URL (Êþäéêáò HTTP 404)";
$message[48][7]="Äéåýèõíóç IP";
$message[49][7]="ÓõìâÜíôá&nbsp;ÓöáëìÜôùí";
$message[50][7]="¶ãíùóôïé öõëëïìåôñçôÝò (Ðåäßï ðáñÜðåìøçò)";
$message[51][7]="Ñïìðüô åðéóêÝðôåò";
$message[52][7]="åðéóêÝøåéò/åðéóêÝðôç";
$message[53][7]="ÅðéóêÝðôåò Ñïìðüô/ÁñÜ÷íåò";
$message[54][7]="Åëåýèåñïò áíáëõôÞò êáôáãñáöþí ðñáãìáôéêïý ÷ñüíïõ ãéá ðñïçãìÝíá óôáôéóôéêÜ êßíçóçò WWW";
$message[55][7]="áðü";
$message[56][7]="Óåëßäåò";
$message[57][7]="Åðéôõ÷ßåò";
$message[58][7]="Åêäüóåéò";
$message[59][7]="Ë/Ó";
$message[60][7]="Éáí";
$message[61][7]="Öåâ";
$message[62][7]="ÌÜñ";
$message[63][7]="Áðñ";
$message[64][7]="ÌÜú";
$message[65][7]="Éïýí";
$message[66][7]="Éïýë";
$message[67][7]="Áýã";
$message[68][7]="Óåð";
$message[69][7]="Ïêô";
$message[70][7]="ÍïÝ";
$message[71][7]="Äåê";
$message[72][7]="Greek gr.png";
$message[73][7]="Daily statistics";
$message[74][7]="Update";

# Czech (js@fsid.cvut.cz)
$PageCode[8]="<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=iso-8859-2\">";
$message[0][8]="Neznámý";
$message[1][8]="Neznámý (nepøelo¾ená IP)";
$message[2][8]="Ostatní";
$message[3][8]="Prohlédnout detaily";
$message[4][8]="Den";
$message[5][8]="Mìsíc";
$message[6][8]="Rok";
$message[7][8]="Statistika pro";
$message[8][8]="První náv¹tìva";
$message[9][8]="Poslední náv¹tìva";
$message[10][8]="Poèet náv¹tìv";
$message[11][8]="Unikátní náv¹tìvy";
$message[12][8]="Náv¹tìva";
$message[13][8]="Výrazy";
$message[14][8]="Hledání";
$message[15][8]="Procenta";
$message[16][8]="Provoz celkem";
$message[17][8]="Domény / zemì";
$message[18][8]="Náv¹tìvy";
$message[19][8]="Stránky/URL";
$message[20][8]="Hodiny";
$message[21][8]="Browsery (prohlí¾eèe)";
$message[22][8]="HTTP Chyby";
$message[23][8]="Reference";
$message[24][8]="Hledané výrazy";
$message[25][8]="Náv¹tìvy domény/zemì";
$message[26][8]="hosts";
$message[27][8]="stránek";
$message[28][8]="rùzné stránky";
$message[29][8]="Pøistup";
$message[30][8]="Jiná slova";
$message[31][8]="Pages not found";
$message[32][8]="Chybové kódy HTTP ";
$message[33][8]="Verze Netscape";
$message[34][8]="Verze MS Internet Explorer";
$message[35][8]="Last Update";
$message[36][8]="Konekce z";
$message[37][8]="Pùvod";
$message[38][8]="Pøímá adresa / Oblíbené (Bookmark)";
$message[39][8]="Odkaz z Newsgroup";
$message[40][8]="Odkaz z Internetového vyhledávaèe";
$message[41][8]="Odkaz z jiné stránky (jiné stránky ne¾ vyhledávaèe)";
$message[42][8]="Odkaz z vlastní stránky (jiná stránka na serveru)";
$message[43][8]="výrazy pou¾ité ve vyhledávaèi";
$message[44][8]="Kb";
$message[45][8]="Nepøelo¾ená IP adresa";
$message[46][8]="Neznámy OS (polo¾ka Referer)";
$message[47][8]="Po¾adované, ale nenalezené URL (HTTP 404)";
$message[48][8]="IP Addresa";
$message[49][8]="Chyba&nbsp;Dotazù";
$message[50][8]="neznámý browser (prohlí¾eè) (polo¾ka Referer)";
$message[51][8]="Náv¹tìvnost robotù";
$message[52][8]="náv¹tìv/náv¹tìvníka";
$message[53][8]="Roboti";
$message[54][8]="Volnì ¹iøitelný nástroj pro analýzu web statistik";
$message[55][8]="z";
$message[56][8]="Stránek";
$message[57][8]="Hity";
$message[58][8]="Verze";
$message[59][8]="OS";
$message[60][8]="Led";
$message[61][8]="Úno";
$message[62][8]="Bøe";
$message[63][8]="Dub";
$message[64][8]="Kvì";
$message[65][8]="Èer";
$message[66][8]="Èvc";
$message[67][8]="Srp";
$message[68][8]="Záø";
$message[69][8]="Øíj";
$message[70][8]="Lis";
$message[71][8]="Pro";
$message[72][8]="Czech cz.png";
$message[73][8]="Daily statistics";
$message[74][8]="Update";

# Portuguese
$message[0][9]="Desconhecido";
$message[1][9]="Desconhecido (ip não resolvido)";
$message[2][9]="Outros visitantes";
$message[3][9]="Ver detalhes";
$message[4][9]="Dia";
$message[5][9]="Mês";
$message[6][9]="Ano";
$message[7][9]="Estatísticas de";
$message[8][9]="Primeira visita";
$message[9][9]="Última visita";
$message[10][9]="Numero de visitas";
$message[11][9]="Visitantes únicos";
$message[12][9]="Visita";
$message[13][9]="Palavra chave";
$message[14][9]="Pesquisa";
$message[15][9]="Por cento";
$message[16][9]="Resumo de Tráfego";
$message[17][9]="Domínios/Países";
$message[18][9]="Visitantes";
$message[19][9]="Páginas/URL";
$message[20][9]="Horas";
$message[21][9]="Browsers";
$message[22][9]="Erros HTTP";
$message[23][9]="Referencias";
$message[24][9]="Busca&nbsp;Palavras";
$message[25][9]="Visitas domínios/países";
$message[26][9]="hosts";
$message[27][9]="páginas";
$message[28][9]="paginas diferentes";
$message[29][9]="Acesso";
$message[30][9]="Outras palavras";
$message[31][9]="Pages not found";
$message[32][9]="Erros HTTP";
$message[33][9]="Versões Netscape";
$message[34][9]="Versões MS Internet Explorer";
$message[35][9]="Last Update";
$message[36][9]="Connectado a partir de";
$message[37][9]="Origem";
$message[38][9]="Endereço directo / Favoritos";
$message[39][9]="Link de um  Newsgroup";
$message[40][9]="Link de um Motor de Busca";
$message[41][9]="Link de uma página externa (outros sites que não motores de busca)";
$message[42][9]="Link de uma página interna (outras páginas no mesmo site)";
$message[43][9]="palavras usadas em motores de busca";
$message[44][9]="Kb";
$message[45][9]="Endereço IP não resolvido";
$message[46][9]="SO Desconhecido (Campo Referer)";
$message[47][9]="URLs solicitadas e não encontradas (HTTP code 404)";
$message[48][9]="Endereço IP";
$message[49][9]="Erro&nbsp;Hits";
$message[50][9]="Browsers Desconhecidos(Campo Referer)";
$message[51][9]="Motores Visitantes";
$message[52][9]="visitas/visitante";
$message[53][9]="Motores/Spiders visitantes";
$message[54][9]="Ferramenta de Análise de ficheiros de log em realtime para estatísticas avançadas";
$message[55][9]="de";
$message[56][9]="Páginas";
$message[57][9]="Hits";
$message[58][9]="Versões";
$message[59][9]="SO";
$message[60][9]="Jan";
$message[61][9]="Fev";
$message[62][9]="Mar";
$message[63][9]="Abr";
$message[64][9]="Mai";
$message[65][9]="Jun";
$message[66][9]="Jul";
$message[67][9]="Ago";
$message[68][9]="Set";
$message[69][9]="Out";
$message[70][9]="Nov";
$message[71][9]="Dez";
$message[72][9]="Portuguese pt.png";
$message[73][9]="Daily statistics";
$message[74][9]="Update";

# Korean
$PageCode[10]="<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=euc-kr\">";
$message[0][10]="¾Ë¼ö¾øÀ½";
$message[1][10]="¾Ë¼ö¾øÀ½(¾Ë¼ö¾ø´Â ip)";
$message[2][10]="±âÅ¸";
$message[3][10]="ÀÚ¼¼È÷ º¸±â";
$message[4][10]="ÀÏ";
$message[5][10]="&nbsp;";
$message[6][10]="³â";
$message[7][10]="Åë°è";
$message[8][10]="Ã³À½ Á¢¼Ó";
$message[9][10]="¸¶Áö¸· Á¢¼Ó";
$message[10][10]="Á¢¼Ó È¸¼ö";
$message[11][10]="Á¢¼ÓÀÚº°";
$message[12][10]="Á¢¼Ó";
$message[13][10]="Å°¿öµå";
$message[14][10]="Ã£±â";
$message[15][10]="ÆÛ¼¾Æ®";
$message[16][10]="À¥ Åë°è ¿ä¾à";
$message[17][10]="µµ¸ÞÀÎ/±¹°¡";
$message[18][10]="¹æ¹®ÀÚ";
$message[19][10]="ÆäÀÌÁö/URL";
$message[20][10]="½Ã°£";
$message[21][10]="ºê¶ó¿ìÀú";
$message[22][10]="HTTP ¿¡·¯";
$message[23][10]="·¹ÆÛ·¯";
$message[24][10]="Ã£±â&nbsp;Å°¿öµå";
$message[25][10]="¹æ¹®ÀÚ µµ¸ÞÀÎ/±¹°¡";
$message[26][10]="È£½ºÆ®";
$message[27][10]="ÆäÀÌÁö";
$message[28][10]="´Ù¸¥ ÆäÀÌÁö";
$message[29][10]="ÀÐ±â È¸¼ö";
$message[30][10]="´Ù¸¥ ´Ü¾î";
$message[31][10]="»ç¿ëÇÑ ºê¶ó¿ìÀú";
$message[32][10]="HTTP ¿¡·¯ ÄÚµå";
$message[33][10]="³Ý½ºÄÉÀÌÇÁ ¹öÀü";
$message[34][10]="MS ÀÎÅÍ³Ý ÀÍ½ºÇÃ·Î·¯ ¹öÀü";
$message[35][10]="Last Update";
$message[36][10]="Á¢¼Ó »çÀÌÆ®º° Åë°è";
$message[37][10]="ÁÖ¼Ò";
$message[38][10]="Á÷Á¢ ÁÖ¼Ò / ºÏ¸¶Å©";
$message[39][10]="´º½ºÅ©·ì¿¡¼­ ¿¬°á";
$message[40][10]="³»ºÎ °Ë»ö ¿£Áø¿¡¼­ ¿¬°á";
$message[41][10]="¿ÜºÎÆäÀÌÁö¿¡¼­ ¿¬°á (°Ë»ö¿£ÁøÀ» Á¦¿ÜÇÑ ´Ù¸¥ À¥»çÀÌÆ®)";
$message[42][10]="³»ºÎÆäÀÌÁö¿¡¼­ ¸µÅ©(°°Àº »çÀÌÆ®ÀÇ ´Ù¸¥ ÆäÀÌÁö)";
$message[43][10]="°Ë»ö¿£Áø¿¡¼­ »ç¿ëµÈ Å°¿öµå";
$message[44][10]="»ç¿ë·®(Kb)";
$message[45][10]="¾Ë¼ö¾ø´Â IP ÁÖ¼Ò";
$message[46][10]="¾Ë¼ö¾ø´Â OS (Æä·¯ÆÛ ÇÊµå)";
$message[47][10]="Á¸ÀçÇÏÁö ¾Ê´Â URL Á¢¼Ó½Ãµµ (HTTP ÄÚµå 404)";
$message[48][10]="IP ÁÖ¼Ò";
$message[49][10]="Á¢¼Ó¿À·ù È¸¼ö";
$message[50][10]="¾Ë¼ö¾ø´Â ºê¶ó¿ìÀú (·¹ÆÛ·¯ ÇÊµå)";
$message[51][10]="¹æ¹®ÁßÀÎ ·Î¹öÆ®";
$message[52][10]="Á¢¼Ó/¹æ¹®ÀÚ";
$message[53][10]="·Î¹öÆ®/½ºÆÄÀÌ´õ ¹æ¹®ÀÚ";
$message[54][10]="Áøº¸ÀûÀÎ À¥ Åë°è¸¦ À§ÇÑ ÀÚÀ¯·Î¿î ½Ç½Ã°£ ·Î±×ÆÄÀÏ";
$message[55][10]="-";
$message[56][10]="ÀÐÀº ÆäÀÌÁö";
$message[57][10]="Á¶È¸¼ö";
$message[58][10]="¹öÀü";
$message[59][10]="OS";
$message[60][10]="1¿ù";
$message[61][10]="2¿ù";
$message[62][10]="3¿ù";
$message[63][10]="4¿ù";
$message[64][10]="5¿ù";
$message[65][10]="6¿ù";
$message[66][10]="7¿ù";
$message[67][10]="8¿ù";
$message[68][10]="9¿ù";
$message[69][10]="10¿ù";
$message[70][10]="11¿ù";
$message[71][10]="12¿ù";
$message[72][10]="Korean kr.png";
$message[73][10]="ÀÏÀÏ Åë°è";
$message[74][10]="Update";


#-------------------------------------------------------
# Functions
#-------------------------------------------------------

sub html_head {
  	print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n\n";
    print "<html>\n";
	print "<head>\n";
	if ($PageCode[$Lang] ne "") { print "$PageCode[$Lang]\n"; }		# If not defined, iso-8859-1 is used in major countries
	print "<meta http-equiv=\"description\" content=\"$PROG - Advanced Web Statistics for $SiteToAnalyze\">\n";
	print "<meta http-equiv=\"keywords\" content=\"$SiteToAnalyze, free, advanced, realtime, web, server, logfile, log, analyzer, analysis, statistics, stats, perl, analyse, performance, hits, visits\">\n";
	print "<meta name=\"robots\" content=\"index,follow\">\n";
	print "<title>$message[7][$Lang] $SiteToAnalyze</title>\n";
	print "<STYLE TYPE=text/css>
<!--
BODY { font: 12px arial, verdana, helvetica, sans-serif; background-color: #$color_Background; }
TH { font: 12px arial, verdana, helvetica, sans-serif; text-align:center; color: #$color_titletext }
TD { font: 12px arial, verdana, helvetica, sans-serif; text-align:center; color: #$color_text }
TD.LEFT { font: 12px arial, verdana, helvetica, sans-serif; text-align:left; color: #$color_text }
A { font: normal 12px arial, verdana, helvetica, sans-serif; text-decoration: underline; }
A:link  { color: #$color_link; }
A:hover { color: #$color_hover; }
DIV { font: 12px arial,verdana,helvetica; text-align:justify; }
.TABLEBORDER { background-color: #$color_TableBorder; }
.TABLEFRAME { background-color: #$color_TableBG; }
.TABLEDATA { background-color: #$color_Background; }
.TABLETITLE { font: bold 16px verdana, arial, helvetica, sans-serif; color: #$color_TableTitle; background-color: #$color_TableBGTitle; }
.CTooltip { position:absolute; top:0px; left:0px; z-index:2; width:280; visibility:hidden; font: 8pt MS Comic Sans,arial,sans-serif; background-color:#FFFFE6; padding: 8px; border: 1px solid black; }
//-->
</STYLE>\n
";
	print "</head>\n\n";
	print "<body>\n";
}


sub html_end {
	print "$CENTER<br><font size=1><b>Advanced Web Statistics $VERSION</b> - <a href=\"http://awstats.sourceforge.net\" target=_newawstats>Created by $PROG</a></font><br>\n";
	print "<br>\n";
	print "$HTMLEndSection\n";
	print "</body>\n";
	print "</html>\n";
}

sub tab_head {
	print "
		<TABLE CLASS=TABLEBORDER BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=$WIDTH>
		<TR><TD>
		<TABLE CLASS=TABLEFRAME BORDER=0 CELLPADDING=3 CELLSPACING=0 WIDTH=100%>
		<TR><TH COLSPAN=2 CLASS=TABLETITLE>$tab_titre</TH></TR>
		<TR><TD COLSPAN=2>
		<TABLE CLASS=TABLEDATA BORDER=1 CELLPADDING=2 CELLSPACING=0 WIDTH=100%>
		";
}

sub tab_end {
	print "</TABLE></TD></TR></TABLE>";
	print "</TD></TR></TABLE>\n\n";
}

sub UnescapeURLParam {
	$_[0] =~ tr/\+/ /s;
	$_[0] =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;		# Decode encoded URL
	$_[0] =~ tr/\'\/=\(\)\"/      /s;
}

sub error {
   	if ($_[0] ne "") { print "<font color=#880000>$_[0].</font><br>\n"; }
   	if ($ENV{"GATEWAY_INTERFACE"} ne "") { print "<br><b>\n"; }
	if ($_[0] ne "") { print "Setup ($FileConfig file, web server or logfile permissions) may be wrong.\n"; }
	if ($ENV{"GATEWAY_INTERFACE"} ne "") { print "</b><br>\n"; }
	print "See README.TXT for informations on how to setup $PROG.\n";
   	if ($ENV{"GATEWAY_INTERFACE"} ne "") { print "</BODY>\n</HTML>\n"; }
    die;
}

sub warning {
	if ($WarningMessages == 1) {
    	print "$_[0]<br>\n";
#		print "You can now remove this warning by changing <b>\$WarningMessages=1</b> parameter into <b>\$WarningMessages=0</b> in $PROG config file (<b>$FileConfig</b>).<br><br>\n"; }
	}
}

sub debug {
	my $level = $_[1] || 1;
	if ($Debug >= $level) { print "DEBUG $level - ".time." : $_[0]<br>\n"; }
	0;
}

sub SkipHost {
	foreach $match (@SkipHosts) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipHosts
}

sub SkipFile {
	foreach $match (@SkipFiles) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not inside @SkipFiles
}

sub OnlyFile {
	if ($OnlyFiles[0] eq "") { return 1; }
	foreach $match (@OnlyFiles) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not inside @OnlyFiles
}

sub Read_Config_File {
	$FileConfig="";$DirConfig=$DIR;if (($DirConfig ne "") && (!($DirConfig =~ /\/$/)) && (!($DirConfig =~ /\\$/)) ) { $DirConfig .= "/"; }
	if (open(CONFIG,"$DirConfig$PROG.$SiteToAnalyze.conf")) { $FileConfig="$DirConfig$PROG.$SiteToAnalyze.conf"; $FileSuffix=".$SiteToAnalyze"; }
	if ($FileConfig eq "") { if (open(CONFIG,"$DirConfig$PROG.conf"))  { $FileConfig="$DirConfig$PROG.conf"; $FileSuffix=""; } }
	if ($FileConfig eq "") { error("Error: Couldn't open config file \"$PROG.$SiteToAnalyze.conf\" nor \"$PROG.conf\" : $!"); }
	&debug("Call to Read_Config_File [FileConfig=\"$FileConfig\"]");
	while (<CONFIG>) {
		chomp $_; s/\r//;
		$_ =~ s/#.*//;								# Remove comments
		$_ =~ tr/\t /  /s;							# Change all blanks into " "
		$_ =~ s/=/§/; @felter=split(/§/,$_);		# Change first "=" into "§" to split
		$param=$felter[0]; $value=$felter[1];
		$value =~ s/^ *//; $value =~ s/ *$//;
		$value =~ s/^\"//; $value =~ s/\"$//;
		# Read main section
		if ($param =~ /^LogFile/) {
			$LogFile=$value;
			# Replace %YYYY %YY %MM %DD %HH with current value
			$LogFile =~ s/%YYYY/$nowyear/g;
			$LogFile =~ s/%YY/$nowsmallyear/g;
			$LogFile =~ s/%MM/$nowmonth/g;
			$LogFile =~ s/%DD/$nowday/g;
			$LogFile =~ s/%HH/$nowhour/g;
			next;
			}
		if ($param =~ /^LogFormat/)            { $LogFormat=$value; next; }
		if ($param =~ /^AllowToUpdateStatsFromBrowser/)	{ $AllowToUpdateStatsFromBrowser=$value; next; }
		if ($param =~ /^HostAliases/) {
			@felter=split(/ /,$value);
			$i=0; foreach $elem (@felter)      { $HostAliases[$i]=$elem; $i++; }
			next;
			}
		if ($param =~ /^SkipHosts/) {
			@felter=split(/ /,$value);
			$i=0; foreach $elem (@felter)      { $SkipHosts[$i]=$elem; $i++; }
			next;
			}
		if ($param =~ /^SkipFiles/) {
			@felter=split(/ /,$value);
			$i=0; foreach $elem (@felter)      { $SkipFiles[$i]=$elem; $i++; }
			next;
			}
		if ($param =~ /^OnlyFiles/) {
			@felter=split(/ /,$value);
			$i=0; foreach $elem (@felter)      { $OnlyFiles[$i]=$elem; $i++; }
			next;
			}
		if ($param =~ /^DirData/)               { $DirData=$value; next; }
		if ($param =~ /^DirCgi/)                { $DirCgi=$value; next; }
		if ($param =~ /^DirIcons/)              { $DirIcons=$value; next; }
		if ($param =~ /^DNSLookup/)             { $DNSLookup=$value; next; }
		if ($param =~ /^PurgeLogFile/)          { $PurgeLogFile=$value; next; }
		if ($param =~ /^ArchiveLogRecords/)     { $ArchiveLogRecords=$value; next; }
		# Read optional section
		if ($param =~ /^Lang/)                  { $Lang=$value; next; }
		if ($param =~ /^DefaultFile/)           { $DefaultFile=$value; next; }
		if ($param =~ /^WarningMessages/)       { $WarningMessages=$value; next; }
		if ($param =~ /^ShowLinksOnUrl/)        { $ShowLinksOnUrl=$value; next; }
		if ($param =~ /^ShowFlagLinks/)         { $ShowFlagLinks=$value; next; }
		if ($param =~ /^HTMLEndSection/)        { $HTMLEndSection=$value; next; }
		if ($param =~ /^BarWidth/)              { $BarWidth=$value; next; }
		if ($param =~ /^BarHeight/)             { $BarHeight=$value; next; }
		if ($param =~ /^MaxNbOfDomain/)         { $MaxNbOfDomain=$value; next; }
		if ($param =~ /^MaxNbOfHostsShown/)     { $MaxNbOfHostsShown=$value; next; }
		if ($param =~ /^MinHitHost/)            { $MinHitHost=$value; next; }
		if ($param =~ /^MaxNbOfRobotShown/)     { $MaxNbOfRobotShown=$value; next; }
		if ($param =~ /^MinHitRobot/)           { $MinHitRobot=$value; next; }
		if ($param =~ /^MaxNbOfPageShown/)      { $MaxNbOfPageShown=$value; next; }
		if ($param =~ /^MinHitFile/)            { $MinHitFile=$value; next; }
		if ($param =~ /^MaxNbOfRefererShown/)   { $MaxNbOfRefererShown=$value; next; }
		if ($param =~ /^MinHitRefer/)           { $MinHitRefer=$value; next; }
		if ($param =~ /^MaxNbOfKeywordsShown/)  { $MaxNbOfKeywordsShown=$value; next; }
		if ($param =~ /^MinHitKeyword/)         { $MinHitKeyword=$value; next; }
		if ($param =~ /^SplitSearchString/)     { $SplitSearchString=$value; next; }
		if ($param =~ /^Logo/)                  { $Logo=$value; next; }
		if ($param =~ /^color_Background/)      { $color_Background=$value; next; }
		if ($param =~ /^color_TableTitle/)      { $color_TableTitle=$value; next; }
		if ($param =~ /^color_TableBGTitle/)    { $color_TableBGTitle=$value; next; }
		if ($param =~ /^color_TableRowTitle/)   { $color_TableRowTitle=$value; next; }
		if ($param =~ /^color_TableBGRowTitle/) { $color_TableBGRowTitle=$value; next; }
		if ($param =~ /^color_TableBorder/)     { $color_TableBorder=$value; next; }
		if ($param =~ /^color_TableBG/)         { $color_TableBG=$value; next; }
		if ($param =~ /^color_link/)            { $color_link=$value; next; }
		if ($param =~ /^color_hover/)           { $color_hover=$value; next; }
		if ($param =~ /^color_text/)            { $color_text=$value; next; }
		if ($param =~ /^color_titletext/)       { $color_titletext=$value; next; }
		if ($param =~ /^color_v/)               { $color_v=$value; next; }
		if ($param =~ /^color_w/)               { $color_w=$value; next; }
		if ($param =~ /^color_p/)               { $color_p=$value; next; }
		if ($param =~ /^color_h/)               { $color_h=$value; next; }
		if ($param =~ /^color_k/)               { $color_k=$value; next; }
		if ($param =~ /^color_s/)               { $color_s=$value; next; }
	}
	close CONFIG;
}

sub Check_Config {
	&debug("Call to Check_Config");
	# Main section
	if ($LogFormat =~ /^[\d]$/ && $LogFormat !~ /[1-3]/)  { error("Error: LogFormat parameter is wrong. Value is '$LogFormat' (should be 1 or 2 or a 'personalised AWtats log format string')"); }
	if ($DNSLookup !~ /[0-1]/)             { error("Error: DNSLookup parameter is wrong. Value is '$DNSLookup' (should be 0 or 1)"); }
	# Optional section
	if ($AllowToUpdateStatsFromBrowser !~ /[0-1]/) { $AllowToUpdateStatsFromBrowser=1; }	# For compatibility, is 1 if not defined
	if ($PurgeLogFile !~ /[0-1]/)          { $PurgeLogFile=0; }
	if ($ArchiveLogRecords !~ /[0-1]/)     { $ArchiveLogRecords=1; }
	if ($Lang !~ /[0-9]/)                  { $Lang=0; }
	if ($DefaultFile eq "")                { $DefaultFile="index.html"; }
	if ($WarningMessages !~ /[0-1]/)       { $WarningMessages=1; }
	if ($ShowLinksOnURL !~ /[0-1]/)        { $ShowLinksOnURL=1; }
	if ($ShowFlagLinks !~ /[0-1]/)         { $ShowFlagLinks=1; }
	if ($BarWidth !~ /[\d]/)               { $BarWidth=260; }
	if ($BarHeight !~ /[\d]/)              { $BarHeight=220; }
	if ($MaxNbOfDomain !~ /[\d]/)          { $MaxNbOfDomain=25; }
	if ($MaxNbOfHostsShown !~ /[\d]/)      { $MaxNbOfHostsShown=25; }
	if ($MinHitHost !~ /[\d]/)             { $MinHitHost=1; }
	if ($MaxNbOfRobotShown !~ /[\d]/)      { $MaxNbOfRobotShown=25; }
	if ($MinHitRobot !~ /[\d]/)            { $MinHitRobot=1; }
	if ($MaxNbOfPageShown !~ /[\d]/)       { $MaxNbOfPageShown=25; }
	if ($MinHitFile !~ /[\d]/)             { $MinHitFile=1; }
	if ($MaxNbOfRefererShown !~ /[\d]/)    { $MaxNbOfRefererShown=25; }
	if ($MinHitRefer !~ /[\d]/)            { $MinHitRefer=1; }
	if ($MaxNbOfKeywordsShown !~ /[\d]/)   { $MaxNbOfKeywordsShown=25; }
	if ($MinHitKeyword !~ /[\d]/)          { $MinHitKeyword=1; }
	if ($SplitSearchString !~ /[0-1]/)     { $SplitSearchString=0; }
	if ($Logo eq "")                       { $Logo="awstats_logo1.png"; }
	$color_Background =~ s/#//g; if ($color_Background !~ /[\d]/)           { $color_Background="FFFFFF";	}
	$color_TableBorder =~ s/#//g; if ($color_TableBorder !~ /[\d]/)         { $color_TableBorder="000000"; }
	$color_TableBG =~ s/#//g; if ($color_TableBG !~ /[\d]/)                 { $color_TableBG="DDDDBB"; }
	$color_TableTitle =~ s/#//g; if ($color_TableTitle !~ /[\d]/)           { $color_TableTitle="FFFFFF"; }
	$color_TableBGTitle =~ s/#//g; if ($color_TableBGTitle !~ /[\d]/)       { $color_TableBGTitle="666666"; }
	$color_TableRowTitle =~ s/#//g; if ($color_TableRowTitle !~ /[\d]/)     { $color_TableRowTitle="FFFFFF"; }
	$color_TableBGRowTitle =~ s/#//g; if ($color_TableBGRowTitle !~ /[\d]/) { $color_TableBGRowTitle="BBBBBB"; }
	$color_link =~ s/#//g; if ($color_link !~ /[\d]/)         { $color_link="4000FF"; }
	$color_hover =~ s/#//g; if ($color_hover !~ /[\d]/)       { $color_hover="4000FF"; }
	$color_text =~ s/#//g; if ($color_text !~ /[\d]/)         { $color_text="000000"; }
	$color_titletext =~ s/#//g; if ($color_titletext !~ /[\d]/) { $color_titletext="000000"; }
	$color_v =~ s/#//g; if ($color_v !~ /[\d]/)               { $color_v="F3F300"; }
	$color_w =~ s/#//g; if ($color_w !~ /[\d]/)               { $color_w="FF9933"; }
	$color_w =~ s/#//g; if ($color_p !~ /[\d]/)               { $color_p="4477DD"; }
	$color_h =~ s/#//g; if ($color_h !~ /[\d]/)               { $color_h="66F0FF"; }
	$color_k =~ s/#//g; if ($color_k !~ /[\d]/)               { $color_k="339944"; }
	$color_s =~ s/#//g; if ($color_s !~ /[\d]/)               { $color_s="8888DD"; }
}

sub Read_History_File {
#--------------------------------------------------------------------
# Input: year,month,0|1|2	(0=read only 1st part, 1=read all file, 2=read only LastUpdate)
#--------------------------------------------------------------------
	&debug("Call to Read_History_File [$_[0],$_[1],$_[2]]");
	if ($HistoryFileAlreadyRead{"$_[0]$_[1]"}) { return 0; }			# Protect code to invoke function only once for each month/year
	$HistoryFileAlreadyRead{"$_[0]$_[1]"}=1;							# Protect code to invoke function only once for each month/year
	if (! -s "$DirData/$PROG$_[1]$_[0]$FileSuffix.txt") { return 0; }	# If file not exists, return
	open(HISTORY,"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt") || error("Error: Couldn't open for read file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" : $!");	# Month before Year kept for backward compatibility
	$readdomain=0;$readvisitor=0;$readunknownip=0;$readsider=0;$readtime=0;$readbrowser=0;$readnsver=0;$readmsiever=0;
	$reados=0;$readrobot=0;$readunknownreferer=0;$readunknownrefererbrowser=0;$readpagerefs=0;$readse=0;
	$readsearchwords=0;$readerrors=0;$readerrors404=0; $readday=0;
	$MonthUnique{$_[0].$_[1]}=0; $MonthPage{$_[0].$_[1]}=0; $MonthHits{$_[0].$_[1]}=0; $MonthBytes{$_[0].$_[1]}=0;
	while (<HISTORY>) {
		chomp $_; s/\r//;
		@field=split(/ /,$_);

		# FIRST PART: Always read
		if ($field[0] eq "FirstTime")       { $FirstTime{$_[0].$_[1]}=$field[1]; next; }
	    if ($field[0] eq "LastTime")        { if ($LastTime{$_[0].$_[1]} < $field[1]) { $LastTime{$_[0].$_[1]}=$field[1]; }; next; }
		if ($field[0] eq "TotalVisits")     { $MonthVisits{$_[0].$_[1]}=$field[1]; next; }
	    if ($field[0] eq "LastUpdate")      { if ($LastUpdate{$_[0].$_[1]} < $field[1]) { $LastUpdate{$_[0].$_[1]}=$field[1]; }; next; }
	    if ($field[0] eq "BEGIN_VISITOR")   { $readvisitor=1; next; }
	    if ($field[0] eq "END_VISITOR")     { $readvisitor=0; next; }
	    if ($field[0] eq "BEGIN_UNKNOWNIP") { $readunknownip=1; next; }
	    if ($field[0] eq "END_UNKNOWNIP")   { $readunknownip=0; next; }
	    if ($field[0] eq "BEGIN_TIME")      { $readtime=1; next; }
	    if ($field[0] eq "END_TIME")        { $readtime=0; next; }
	    if ($field[0] eq "BEGIN_DAY")       { $readday=1; next; }
	    if ($field[0] eq "END_DAY")         { $readday=0; next; }

	    if ($readvisitor) {
	    	if (($field[0] ne "Unknown") && ($field[1] > 0)) { $MonthUnique{$_[0].$_[1]}++; }
	    	}
	    if ($readunknownip) {
	    	$MonthUnique{$_[0].$_[1]}++;
			}
	    if ($readtime) {
	    	$MonthPage{$_[0].$_[1]}+=$field[1]; $MonthHits{$_[0].$_[1]}+=$field[2]; $MonthBytes{$_[0].$_[1]}+=$field[3];
			}
		if ($readday)
		{
			$DayPage{$field[0]}=$field[1]; $DayHits{$field[0]}=$field[2]; $DayBytes{$field[0]}=$field[3]; $DayVisits{$field[0]}=$field[4]; $DayUnique{$field[0]}=$field[5];
		}

		# SECOND PART: If $_[2] == 0, it means we don't need second part of history file.
		if ($_[2]) {
	        if ($field[0] eq "BEGIN_DOMAIN") { $readdomain=1; next; }
			if ($field[0] eq "END_DOMAIN")   { $readdomain=0; next; }
			if ($field[0] eq "BEGIN_SIDER")  { $readsider=1; next; }
			if ($field[0] eq "END_SIDER")    { $readsider=0; next; }
	        if ($field[0] eq "BEGIN_BROWSER") { $readbrowser=1; next; }
	        if ($field[0] eq "END_BROWSER") { $readbrowser=0; next; }
	        if ($field[0] eq "BEGIN_NSVER") { $readnsver=1; next; }
	        if ($field[0] eq "END_NSVER") { $readnsver=0; next; }
	        if ($field[0] eq "BEGIN_MSIEVER") { $readmsiever=1; next; }
	        if ($field[0] eq "END_MSIEVER") { $readmsiever=0; next; }
	        if ($field[0] eq "BEGIN_OS") { $reados=1; next; }
	        if ($field[0] eq "END_OS") { $reados=0; next; }
	        if ($field[0] eq "BEGIN_ROBOT") { $readrobot=1; next; }
	        if ($field[0] eq "END_ROBOT") { $readrobot=0; next; }
	        if ($field[0] eq "BEGIN_UNKNOWNREFERER") { $readunknownreferer=1; next; }
	        if ($field[0] eq "END_UNKNOWNREFERER")   { $readunknownreferer=0; next; }
	        if ($field[0] eq "BEGIN_UNKNOWNREFERERBROWSER") { $readunknownrefererbrowser=1; next; }
	        if ($field[0] eq "END_UNKNOWNREFERERBROWSER")   { $readunknownrefererbrowser=0; next; }
	        if ($field[0] eq "BEGIN_PAGEREFS") { $readpagerefs=1; next; }
	        if ($field[0] eq "END_PAGEREFS") { $readpagerefs=0; next; }
	        if ($field[0] eq "BEGIN_SEREFERRALS") { $readse=1; next; }
	        if ($field[0] eq "END_SEREFERRALS") { $readse=0; next; }
	        if ($field[0] eq "BEGIN_SEARCHWORDS") { $readsearchwords=1; next; }
	        if ($field[0] eq "END_SEARCHWORDS") { $readsearchwords=0; next; }
	        if ($field[0] eq "BEGIN_ERRORS") { $readerrors=1; next; }
	        if ($field[0] eq "END_ERRORS") { $readerrors=0; next; }
	        if ($field[0] eq "BEGIN_SIDER_404") { $readerrors404=1; next; }
	        if ($field[0] eq "END_SIDER_404") { $readerrors404=0; next; }
	  		if ($field[0] eq "BEGIN_DAY")       { $readday=1; next; }
	    	if ($field[0] eq "END_DAY")         { $readday=0; next; }

	        if ($readvisitor) {
	        	$_hostmachine_p{$field[0]}+=$field[1];
	        	$_hostmachine_h{$field[0]}+=$field[2];
	        	$_hostmachine_k{$field[0]}+=$field[3];
	        	if ($_hostmachine_l{$field[0]} eq "") { $_hostmachine_l{$field[0]}=$field[4]; }
	        	next; }
	        if ($readunknownreferer) {
	        	if ($_unknownreferer_l{$field[0]} eq "") { $_unknownreferer_l{$field[0]}=$field[1]; }
	        	next; }
			if ($readdomain) {
				$_domener_p{$field[0]}+=$field[1];
				$_domener_h{$field[0]}+=$field[2];
				$_domener_k{$field[0]}+=$field[3];
				next; }
	        if ($readunknownip) {
	        	if ($_unknownip_l{$field[0]} eq "") { $_unknownip_l{$field[0]}=$field[1]; }
	        	next; }
			if ($readsider) { $_sider_p{$field[0]}+=$field[1]; next; }
	        if ($readtime) {
	        	$_time_p[$field[0]]+=$field[1]; $_time_h[$field[0]]+=$field[2]; $_time_k[$field[0]]+=$field[3];
	        	next; }
	        if ($readbrowser) { $_browser_h{$field[0]}+=$field[1]; next; }
	        if ($readnsver) { $_nsver_h[$field[0]]+=$field[1]; next; }
	        if ($readmsiever) { $_msiever_h[$field[0]]+=$field[1]; next; }
	        if ($reados) { $_os_h{$field[0]}+=$field[1]; next; }
	        if ($readrobot) {
				$_robot_h{$field[0]}+=$field[1];
	        	if ($_robot_l{$field[0]} eq "") { $_robot_l{$field[0]}=$field[2]; }
				next; }
	        if ($readunknownrefererbrowser) {
	        	if ($_unknownrefererbrowser_l{$field[0]} eq "") { $_unknownrefererbrowser_l{$field[0]}=$field[1]; }
	        	next; }
	        if ($field[0] eq "HitFrom0") { $_from_h[0]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom1") { $_from_h[1]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom2") { $_from_h[2]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom3") { $_from_h[3]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom4") { $_from_h[4]+=$field[1]; next; }
	        if ($readpagerefs) { $_pagesrefs_h{$field[0]}+=$field[1]; next; }
	        if ($readse) { $_se_referrals_h{$field[0]}+=$field[1]; next; }
	        if ($readsearchwords) { $_keywords{$field[0]}+=$field[1]; next; }
	        if ($readerrors) { $_errors_h{$field[0]}+=$field[1]; next; }
	        if ($readerrors404) { $_sider404_h{$field[0]}+=$field[1]; $_referer404_h{$field[0]}=$field[2]; next; }
		}
	}
	close HISTORY;
	if ($readdomain || $readvisitor || $readunknownip || $readsider || $readtime || $readbrowser || $readnsver || $readmsiever || $reados || $readrobot || $readunknownreferer || $readunknownrefererbrowser || $readpagerefs || $readse || $readsearchwords || $readerrors || $readerrors404 || $readday) {
		# History file is corrupted
		error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost).");
	}
}

sub Save_History_File {
	&debug("Call to Save_History_File [$_[0],$_[1]]");
	open(HISTORYTMP,">$DirData/$PROG$_[1]$_[0]$FileSuffix.tmp.$$") || error("Error: Couldn't open file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.tmp.$$\" : $!");	# Month before Year kept for backward compatibility

	print HISTORYTMP "FirstTime $FirstTime{$_[0].$_[1]}\n";
	print HISTORYTMP "LastTime $LastTime{$_[0].$_[1]}\n";
	if ($LastUpdate{$_[0].$_[1]} lt "$nowyear$nowmonth$nowday$nowhour$nowmin") { $LastUpdate{$_[0].$_[1]}="$nowyear$nowmonth$nowday$nowhour$nowmin"; }
	print HISTORYTMP "LastUpdate $LastUpdate{$_[0].$_[1]}\n";
	print HISTORYTMP "TotalVisits $MonthVisits{$_[0].$_[1]}\n";

	print HISTORYTMP "BEGIN_DOMAIN\n";
	foreach $key (keys %_domener_h) {
		$page=$_domener_p{$key};$kilo=$_domener_k{$key};
		if ($page == "") {$page=0;}
		if ($kilo == "") {$kilo=0;}
		print HISTORYTMP "$key $page $_domener_h{$key} $kilo\n"; next;
		}
	print HISTORYTMP "END_DOMAIN\n";

	print HISTORYTMP "BEGIN_VISITOR\n";
	foreach $key (keys %_hostmachine_h) {
		$page=$_hostmachine_p{$key};$kilo=$_hostmachine_k{$key};
		if ($page == "") {$page=0;}
		if ($kilo == "") {$kilo=0;}
		print HISTORYTMP "$key $page $_hostmachine_h{$key} $kilo $_hostmachine_l{$key}\n"; next;
		}
	print HISTORYTMP "END_VISITOR\n";

	print HISTORYTMP "BEGIN_UNKNOWNIP\n";
	foreach $key (keys %_unknownip_l) { print HISTORYTMP "$key $_unknownip_l{$key}\n"; next; }
	print HISTORYTMP "END_UNKNOWNIP\n";

	print HISTORYTMP "BEGIN_SIDER\n";
	foreach $key (keys %_sider_p) { print HISTORYTMP "$key $_sider_p{$key}\n"; next; }
	print HISTORYTMP "END_SIDER\n";

	print HISTORYTMP "BEGIN_TIME\n";
	for ($ix=0; $ix<=23; $ix++) { print HISTORYTMP "$ix $_time_p[$ix] $_time_h[$ix] $_time_k[$ix]\n"; next; }
	print HISTORYTMP "END_TIME\n";

	print HISTORYTMP "BEGIN_DAY\n";
    foreach $key (keys %DayPages) {
    	 if ($key =~ /^$_[0]$_[1]/) {	# Found a day entry of the good month
    	 	print HISTORYTMP "$key $DayPages{$key} $DayHits{$key} $DayBytes{$key} $DayVisits{$key} $DayUnique{$key}\n"; next;
    	 	}
    	 }
    print HISTORYTMP "END_DAY\n";

	print HISTORYTMP "BEGIN_BROWSER\n";
	foreach $key (keys %_browser_h) { print HISTORYTMP "$key $_browser_h{$key}\n"; next; }
	print HISTORYTMP "END_BROWSER\n";
	print HISTORYTMP "BEGIN_NSVER\n";
	for ($i=1; $i<=$#_nsver_h; $i++) { print HISTORYTMP "$i $_nsver_h[$i]\n"; next; }
	print HISTORYTMP "END_NSVER\n";
	print HISTORYTMP "BEGIN_MSIEVER\n";
	for ($i=1; $i<=$#_msiever_h; $i++) { print HISTORYTMP "$i $_msiever_h[$i]\n"; next; }
	print HISTORYTMP "END_MSIEVER\n";
	print HISTORYTMP "BEGIN_OS\n";
	foreach $key (keys %_os_h) { print HISTORYTMP "$key $_os_h{$key}\n"; next; }
	print HISTORYTMP "END_OS\n";

	print HISTORYTMP "BEGIN_ROBOT\n";
	foreach $key (keys %_robot_h) { print HISTORYTMP "$key $_robot_h{$key} $_robot_l{$key}\n"; next; }
	print HISTORYTMP "END_ROBOT\n";

	print HISTORYTMP "BEGIN_UNKNOWNREFERER\n";
	foreach $key (keys %_unknownreferer_l) { print HISTORYTMP "$key $_unknownreferer_l{$key}\n"; next; }
	print HISTORYTMP "END_UNKNOWNREFERER\n";
	print HISTORYTMP "BEGIN_UNKNOWNREFERERBROWSER\n";
	foreach $key (keys %_unknownrefererbrowser_l) { print HISTORYTMP "$key $_unknownrefererbrowser_l{$key}\n"; next; }
	print HISTORYTMP "END_UNKNOWNREFERERBROWSER\n";

	print HISTORYTMP "HitFrom0 $_from_h[0]\n";
	print HISTORYTMP "HitFrom1 $_from_h[1]\n";
	print HISTORYTMP "HitFrom2 $_from_h[2]\n";
	print HISTORYTMP "HitFrom3 $_from_h[3]\n";
	print HISTORYTMP "HitFrom4 $_from_h[4]\n";

	print HISTORYTMP "BEGIN_SEREFERRALS\n";
	foreach $key (keys %_se_referrals_h) { print HISTORYTMP "$key $_se_referrals_h{$key}\n"; next; }
	print HISTORYTMP "END_SEREFERRALS\n";

	print HISTORYTMP "BEGIN_PAGEREFS\n";
	foreach $key (keys %_pagesrefs_h) { print HISTORYTMP "$key $_pagesrefs_h{$key}\n"; next; }
	print HISTORYTMP "END_PAGEREFS\n";

	print HISTORYTMP "BEGIN_SEARCHWORDS\n";
	foreach $key (keys %_keywords) { if ($_keywords{$key}) { print HISTORYTMP "$key $_keywords{$key}\n"; } next; }
	print HISTORYTMP "END_SEARCHWORDS\n";

	print HISTORYTMP "BEGIN_ERRORS\n";
	foreach $key (keys %_errors_h) { print HISTORYTMP "$key $_errors_h{$key}\n"; next; }
	print HISTORYTMP "END_ERRORS\n";

	print HISTORYTMP "BEGIN_SIDER_404\n";
	foreach $key (keys %_sider404_h) { print HISTORYTMP "$key $_sider404_h{$key} $_referer404_h{$key}\n"; next; }
	print HISTORYTMP "END_SIDER_404\n";

	close(HISTORYTMP);
}

sub Init_HashArray {
	# We purge data read for year $_[0] and month $_[1] so it's like we never read it
	$HistoryFileAlreadyRead{"$_[0]$_[1]"}=0;
	# Delete all hash arrays with name beginning by _
	%_browser_h = %_domener_h = %_domener_k = %_domener_p =
	%_errors_h = %_hostmachine_h = %_hostmachine_k = %_hostmachine_l = %_hostmachine_p =
	%_keywords = %_os_h = %_pagesrefs_h = %_robot_h = %_robot_l = %_se_referrals_h =
	%_sider404_h = %_sider_h = %_sider_k = %_sider_p = %_unknownip_l = %_unknownreferer_l =
	%_unknownrefererbrowser_l = ();
	reset _;
}



#-------------------------------------------------------
# MAIN
#-------------------------------------------------------
if ($ENV{"GATEWAY_INTERFACE"} ne "") {	# Run from a browser
	print("Content-type: text/html\n\n\n");
	$QueryString = $ENV{"QUERY_STRING"};
	$QueryString =~ s/<script.*$//i;						# This is to avoid 'Cross Site Scripting attacks'
	if ($QueryString =~ /site=/) { $SiteToAnalyze=$QueryString; $SiteToAnalyze =~ s/.*site=//; $SiteToAnalyze =~ s/&.*//; $SiteToAnalyze =~ s/ .*//; }
	$UpdateStats=0;	if ($QueryString =~ /update=1/i) { $UpdateStats=1; }	# No update by default when run from a browser
}
else {	# Run from command line
	if ($ARGV[0] eq "-h") { $SiteToAnalyze = $ARGV[1]; }	# Kept for backward compatibility but useless
	$QueryString=""; for (0..@ARGV-1) { $QueryString .= "$ARGV[$_] "; }
	$QueryString =~ s/<script.*$//i;						# This is to avoid 'Cross Site Scripting attacks'
	if ($QueryString =~ /site=/) { $SiteToAnalyze=$QueryString; $SiteToAnalyze =~ s/.*site=//; $SiteToAnalyze =~ s/&.*//; $SiteToAnalyze =~ s/ .*//; }
	$UpdateStats=1;	if ($QueryString =~ /update=0/i) { $UpdateStats=0; }	# Update by default when run from command line
}
if ($QueryString =~ /debug=/i) { $Debug=$QueryString; $Debug =~ s/.*debug=//; $Debug =~ s/&.*//; $Debug =~ s/ .*//; }
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
if ($SiteToAnalyze eq "") { $SiteToAnalyze = $ENV{"SERVER_NAME"}; }
$SiteToAnalyze =~ tr/A-Z/a-z/;
$SiteToAnalyzeWithoutwww = $SiteToAnalyze; $SiteToAnalyzeWithoutwww =~ s/www\.//;
if (($ENV{"GATEWAY_INTERFACE"} eq "") && ($SiteToAnalyze eq "")) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG is a free web server logfile analyzer (in Perl) to show you advanced\n";
	print "web statistics.\n";
	print "$PROG comes with ABSOLUTELY NO WARRANTY. It's a free software distributed\n";
	print "with a GNU General Public License (See COPYING.txt file for details).\n";
	print "\n";
	print "Syntax: $PROG.$Extension site=www.host.com\n";
	print "  This runs $PROG in command line to update statistics of a web site, from\n";
	print "  the log file defined in config file, and returns an HTML report.\n";
	print "  First, $PROG tries to read $PROG.www.host.com.conf as the config file,\n";
	print "  if not found, it will read $PROG.conf\n";
	print "  See README.TXT file to know how to create the config file.\n";
	print "\n";
	print "Advanced options:\n";
	print "  update=0            to only show a report, no update of statistics\n";
	print "  lang=X              to show a report page in language number X\n";
	print "  month=MM year=YYYY  to show a report for an old month=MM, year=YYYY\n";
	print "  Warning : Those 'date' options doesn't allow you to process old log file.\n";
	print "  It only allows you to see a report for a choosed month/year period instead\n";
	print "  of current month/year. To update stats from a log file, use standard syntax.\n";
	print "  Be care to process log files in chronological order.\n";
	print "\n";
	print "Now supports/detects:\n";
	print "  Number of visits and unique visitors\n";
	print "  Rush hours\n";
	print "  Most often viewed pages\n";
	@DomainsArray=keys %DomainsHash;
	print "  ".(@DomainsArray)." domains/countries\n";
	@BrowserArray=keys %BrowsersHash;
	print "  ".(@BrowserArray)." browsers\n";
	@OSArray=keys %OSHash;
	print "  ".(@OSArray)." Operating Systems\n";
	@RobotArray=keys %RobotHash;
	print "  ".(@RobotArray)." robots\n";
	@SearchEnginesArray=keys %SearchEnginesHash;
	print "  ".(@SearchEnginesArray)." search engines (and keywords or keyphrases used from them)\n";
	print "  All HTTP errors\n";
	print "  Statistics by day/month/year\n";
	print "New versions and FAQ at http://awstats.sourceforge.net\n";
	exit 0;
	}

# Get current time
($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday,$nowyday,$nowisdst) = localtime(time);
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
$nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
if (++$nowmonth < 10) { $nowmonth = "0$nowmonth"; }
if ($nowday < 10) { $nowday = "0$nowday"; }
if ($nowhour < 10) { $nowhour = "0$nowhour"; }
if ($nowmin < 10) { $nowmin = "0$nowmin"; }

# Read config file
&Read_Config_File;
if ($QueryString =~ /lang=/i) { $Lang=$QueryString; $Lang =~ s/.*lang=//; $Lang =~ s/&.*//;  $Lang =~ s/ .*//; }

# Check and correct bad parameters
&Check_Config;
	
# Print html header
&html_head;

# Init other parameters
if ($ENV{"GATEWAY_INTERFACE"} ne "") { $DirCgi=""; }
if (($DirCgi ne "") && !($DirCgi =~ /\/$/) && !($DirCgi =~ /\\$/)) { $DirCgi .= "/"; }
if ($DirData eq "" || $DirData eq ".") { $DirData=$DIR; }	# If not defined or choosed to "." value then DirData is current dir
if ($DirData eq "")  { $DirData="."; }						# If current dir not defined then we put it to "."
$DirData =~ s/\/$//;
if ($DNSLookup) { use Socket; }
$NewDNSLookup=$DNSLookup;
%monthlib =  ( "01","$message[60][$Lang]","02","$message[61][$Lang]","03","$message[62][$Lang]","04","$message[63][$Lang]","05","$message[64][$Lang]","06","$message[65][$Lang]","07","$message[66][$Lang]","08","$message[67][$Lang]","09","$message[68][$Lang]","10","$message[69][$Lang]","11","$message[70][$Lang]","12","$message[71][$Lang]" );
# monthnum must be in english because it's used to translate log date in log files which are always in english
%monthnum =  ( "Jan","01","Feb","02","Mar","03","Apr","04","May","05","Jun","06","Jul","07","Aug","08","Sep","09","Oct","10","Nov","11","Dec","12" );

# Check year and month parameters
if ($QueryString =~ /year=/i) 	{ $YearRequired=$QueryString; $YearRequired =~ s/.*year=//; $YearRequired =~ s/&.*//;  $YearRequired =~ s/ .*//; }
if ($YearRequired !~ /^[\d][\d][\d][\d]$/) { $YearRequired=$nowyear; }
if ($QueryString =~ /month=/i)	{ $MonthRequired=$QueryString; $MonthRequired =~ s/.*month=//; $MonthRequired =~ s/&.*//; $MonthRequired =~ s/ .*//; }
if ($MonthRequired ne "year" && $MonthRequired !~ /^[\d][\d]$/) { $MonthRequired=$nowmonth; }

$BrowsersHash{"netscape"}="<font color=blue>Netscape</font> <a href=\"$DirCgi$PROG.$Extension?action=browserdetail&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">($message[58][$Lang])</a>";
$BrowsersHash{"msie"}="<font color=blue>MS Internet Explorer</font> <a href=\"$DirCgi$PROG.$Extension?action=browserdetail&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">($message[58][$Lang])</a>";

if (@HostAliases == 0) {
	warning("Warning: HostAliases parameter is not defined, $PROG will choose \"$SiteToAnalyze localhost 127.0.0.1\".");
	$HostAliases[0]=$SiteToAnalyze; $HostAliases[1]="localhost"; $HostAliases[2]="127.0.0.1";
	}

$SiteToAnalyzeIsInHostAliases=0;
foreach $elem (@HostAliases) { if ($elem eq $SiteToAnalyze) { $SiteToAnalyzeIsInHostAliases=1; last; } }
if ($SiteToAnalyzeIsInHostAliases == 0) { $HostAliases[@HostAliases]=$SiteToAnalyze; }
if (@SkipFiles == 0) { $SkipFiles[0]="\.css\$";$SkipFiles[1]="\.js\$";$SkipFiles[2]="\.class\$";$SkipFiles[3]="robots\.txt\$"; }
$FirstTime=0;$LastTime=0;$LastUpdate=0;$TotalVisits=0;$TotalHosts=0;$TotalUnique=0;$TotalDifferentPages=0;$TotalDifferentKeywords=0;$TotalKeywords=0;
for ($ix=1; $ix<=12; $ix++) {
	$monthix=$ix;if ($monthix < 10) { $monthix  = "0$monthix"; }
	$FirstTime{$YearRequired.$monthix}=0;$LastTime{$YearRequired.$monthix}=0;$LastUpdate{$YearRequired.$monthix}=0;
	$MonthVisits{$YearRequired.$monthix}=0;$MonthUnique{$YearRequired.$monthix}=0;$MonthPage{$YearRequired.$monthix}=0;$MonthHits{$YearRequired.$monthix}=0;$MonthBytes{$YearRequired.$monthix}=0;
	}
for ($ix=0; $ix<5; $ix++) {	$_from_h[$ix]=0; }

# Show logo
print "<table WIDTH=$WIDTH>\n";
print "<tr valign=center><td class=LEFT width=150 style=\"font: 18px arial,verdana,helvetica; font-weight: bold\">AWStats\n";
# Show flags
if ($ShowFlagLinks == 1) {
	print "<br>\n";
	my $sp = '';
	for (0..5) {		# Only flags for 5 major languages
		if ($Lang != $_) {
			my ($lng, $flg) = split(/\s+/, $message[72][$_]);
			print "$sp<a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$_\"><img src=\"$DirIcons\/flags\/$flg\" height=14 border=0 alt=\"$lng\" title=\"$lng\"></a>\n";
			$sp = '&nbsp;';
		}
	}
}
print "</td>\n";
print "<td class=LEFT width=450><a href=\"http://awstats.sourceforge.net\" target=_newawstats><img src=$DirIcons/other/$Logo border=0 alt=\"$PROG Official Web Site\" title=\"$PROG Official Web Site\"></a></td></tr>\n";
#print "<b><font face=\"verdana\" size=1><a href=\"$HomeURL\">HomePage</a> &#149\; <a href=\"javascript:history.back()\">Back</a></font></b><br>\n";
print "<tr><td class=LEFT colspan=2>$message[54][$Lang]</td></tr>\n";
print "</table>\n";

print "<hr>\n";


# No update (no log processing) if not current month or full current year asked
#if (($YearRequired == $nowyear) && ($MonthRequired eq "year" || $MonthRequired == $nowmonth)) {
# No update (no log processing) if UpdateStats != 1
if ($UpdateStats) {

	#------------------------------------------
	# READING THE LAST PROCESSED HISTORY FILE
	#------------------------------------------

	# Search last file
	opendir(DIR,"$DirData");
	@filearray = sort readdir DIR;
	close DIR;
	$yearmonthmax=0;
	foreach $i (0..$#filearray) {
		if ("$filearray[$i]" =~ /^$PROG[\d][\d][\d][\d][\d][\d]$FileSuffix\.txt$/) {
			$yearmonthfile=$filearray[$i]; $yearmonthfile =~ s/^$PROG//; $yearmonthfile =~ s/\..*//;
			$yearfile=$yearmonthfile; $yearfile =~ s/^..//;
			$monthfile=$yearmonthfile; $monthfile =~ s/....$//;
			$yearmonthfile="$yearfile$monthfile";	# year and month have been inversed
			if ($yearmonthfile > $yearmonthmax) { $yearmonthmax=$yearmonthfile; }
		}
	};

	$monthtoprocess=0;$yeartoprocess=0;
	if ($yearmonthmax) {	# We found last history file
		$yeartoprocess=$yearmonthmax; $monthtoprocess=$yearmonthmax;
		$yeartoprocess =~ s/..$//; $monthtoprocess =~ s/^....//;
		# We read LastTime in this last history file.
		&Read_History_File($yeartoprocess,$monthtoprocess,1);
	}

	#------------------------------------------
	# GENERATING PerlParsingFormat
	#------------------------------------------
	# Log example records
	# 62.161.78.73 user - [dd/mmm/yyyy:hh:mm:ss +0000] "GET / HTTP/1.1" 200 1234 "http://www.from.com/from.htm" "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"
	# my.domain.com - user [09/Jan/2001:11:38:51 -0600] "OPTIONS /mime-tmp/xxx file.doc HTTP/1.1" 408 - "-" "-"
    # 2000-07-19 14:14:14 62.161.78.73 - GET / 200 1234 HTTP/1.1 Mozilla/4.0+(compatible;+MSIE+5.01;+Windows+NT+5.0) http://www.from.com/from.htm
	# 05/21/00	00:17:31	OK  	200	212.242.30.6	Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)	http://www.cover.dk/	"www.cover.dk"	:Documentation:graphics:starninelogo.white.gif	1133
	$LogFormatString=$LogFormat;
	if ($LogFormat == 1) { $LogFormatString="%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""; }
	if ($LogFormat == 2) { $LogFormatString="date time c-ip cs-username cs-method cs-uri-stem sc-status sc-bytes cs-version cs(User-Agent) cs(Referer)"; }
	&debug("Generate PerlParsingFormat from LogFormatString=$LogFormatString");
	$PerlParsingFormat="";
	if ($LogFormat == 1) {
		$PerlParsingFormat="([^\\s]*) ([^\\s]*) ([^\\s]*) \\[([^\\s]*) ([^\\s]*)\\] \\\"([^\\s]*) ([^\\s]*) [^\\\"]*\\\" ([\\d|-]*) ([\\d|-]*) \\\"([^\\\"]*)\\\" \\\"([^\\\"]*)\\\"";
		$pos_rc=1;$pos_logname=2;$pos_user=3;$pos_date=4;$pos_zone=5;$pos_method=6;$pos_url=7;$pos_code=8;$pos_size=9;$pos_referer=10;$pos_agent=11;
		$lastrequiredfield=11;
	}
	if ($LogFormat == 2) {
		$PerlParsingFormat="([^\\s]* [^\\s]*) ([^\\s]*) ([^\\s]*) ([^\\s]*) ([^\\s]*) ([\\d|-]*) ([\\d|-]*) [^\\s]* ([^\\s]*) ([^\\s]*)";
		$pos_date=1;$pos_rc=2;$pos_logname=3;$pos_method=4;$pos_url=5;$pos_code=6;$pos_size=7;$pos_agent=8;$pos_referer=9;
		$lastrequiredfield=9;
	}
	if ($LogFormat == 3) {
#		$PerlParsingFormat="([^\\t]*\\t[^\\t]*)\\t([^\\t]*)\\t([\\d]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t[^\\t]*\\t.*:([^\\t]*)\\t([\\d]*)";
		$PerlParsingFormat="([^\\t]*\\t[^\\t]*)\\t([^\\t]*)\\t([\\d]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t[^\\t]*\\t.*:([^\\t]*)\\t([\\d]*)";
		$pos_date=1;$pos_method=2;$pos_code=3;$pos_rc=4;$pos_agent=5;$pos_referer=6;$pos_url=7;$pos_size=8;
		$lastrequiredfield=8;
	}
	if ($LogFormat != 1 && $LogFormat != 2 && $LogFormat != 3) {
		# Scan $LogFormat to found all required fields and generate PerlParsing
		@fields = split(/ +/, $LogFormatString); # make array of entries
		$i = 1;
		foreach $f (@fields) {
			$found=0;
			if ($f =~ /%host$/ || $f =~ /%h$/ || $f =~ /c-ip$/) {
				$found=1; 
				$pos_rc = $i; $i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%time1$/ || $f =~ /%t$/) {
				$found=1; 
				$pos_date = $i;
				$i++;
				$pos_zone = $i;
				$i++;
				$PerlParsingFormat .= "\\[([^\\s]*) ([^\\s]*)\\] ";
			}
			if ($f =~ /%time2$/) {
				$found=1; 
				$pos_date = $i;
				$i++;
				$PerlParsingFormat .= "([^\\s]* [^\\s]*) ";
			}
			if ($f =~ /%methodurl$/ || $f =~ /\\"%r\\"/) {
				$found=1; 
				$pos_method = $i;
				$i++;
				$pos_url = $i;
				$i++;
				$PerlParsingFormat .= "\\\"([^\\s]*) ([^\\s]*) [^\\\"]*\\\" ";
			}
			if ($f =~ /%method$/ || $f =~ /cs-method$/) {
				$found=1; 
				$pos_method = $i;
				$i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%url$/ || $f =~ /cs-uri-stem$/) {
				$found=1; 
				$pos_url = $i;
				$i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%code$/ || $f =~ /%.*>s$/ || $f =~ /cs-status$/) {
				$found=1; 
				$pos_code = $i;
				$i++;
				$PerlParsingFormat .= "([\\d|-]*) ";
			}
			if ($f =~ /%bytesd$/ || $f =~ /%b$/ || $f =~ /sc-bytes$/) {
				$found=1; 
				$pos_size = $i; $i++;
				$PerlParsingFormat .= "([\\d|-]*) ";
			}
			if ($f =~ /%refererquot$/ || $f =~ /\\"%{Referer}i\\"/) {
				$found=1;
				$pos_referer = $i; $i++;
				$PerlParsingFormat .= "\\\"([^\\\"]*)\\\" ";
			}
			if ($f =~ /%referer$/ || $f =~ /cs\(Referer\)/) {
				$found=1;
				$pos_referer = $i; $i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if ($f =~ /%uaquot$/ || $f =~ /\\"%{User-Agent}i\\"/) {
				$found=1; 
				$pos_agent = $i; $i++;
				$PerlParsingFormat .= "\\\"([^\\\"]*)\\\" ";
			}
			if ($f =~ /%ua$/ || $f =~ /cs\(User-Agent\)/) {
				$found=1; 
				$pos_agent = $i; $i++;
				$PerlParsingFormat .= "([^\\s]*) ";
			}
			if (! $found) { $found=1; $PerlParsingFormat .= "[^\\s]* "; }
		}
		($PerlParsingFormat) ? chop($PerlParsingFormat) : error("Error: no recognised format commands in Personalised log format"); 
		$lastrequiredfield=$i--;
	}
	if ($pos_rc eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%host in your LogFormat string)."); }
	if ($pos_date eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%time1 or \%time2 in your LogFormat string)."); }
	if ($pos_method eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%methodurl or \%method in your LogFormat string)."); }
	if ($pos_url eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%methodurl or \%url in your LogFormat string)."); }
	if ($pos_code eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%code in your LogFormat string)."); }
	if ($pos_size eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%bytesd in your LogFormat string)."); }
	if ($pos_referer eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%referer or \%refererquot in your LogFormat string)."); }
	if ($pos_agent eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%ua or \%uaquot in your LogFormat string)."); }
	&debug("PerlParsingFormat is $PerlParsingFormat");


	#------------------------------------------
	# PROCESSING CURRENT LOG
	#------------------------------------------
	&debug("Start of processing log file $LogFile (monthtoprocess=$monthtoprocess, yeartoprocess=$yeartoprocess)");
	$OpenFileError=1; if (open(LOG,"$LogFile")) { $OpenFileError=0; }
	if ($OpenFileError) { error("Error: Couldn't open server log file \"$LogFile\" : $!"); }
	$NbOfLinesProcessed=0; $NowNewLinePhase=0;
	while (<LOG>)
	{
		$savedline=$_;
		chomp $_; s/\r//;
		if (/^$/) { next; }									# Ignore blank lines (With ISS: happens sometimes, with Apache: possible when editing log file)
		if (/^#/) { next; }									# Ignore comment lines (ISS writes such comments)
		if (/^!!/) { next; }								# Ignore comment lines (Webstar writes such comments)
		$NbOfLinesProcessed++;

		# Parse line record to get all required fields
		$_ =~ /^$PerlParsingFormat/;
		foreach $i (1..$lastrequiredfield) { $field[$i]=$$i; }
		&debug("Fields for record $NbOfLinesProcessed: $field[$pos_rc] ; - ; - ; $field[$pos_date] ; TZ; $field[$pos_method] ; $field[$pos_url] ; $field[$pos_code] ; $field[$pos_size] ; $field[$pos_referer] ; $field[$pos_agent]",3);

		# Check parsed parameters
		#----------------------------------------------------------------------
		if ($field[$pos_code] eq "") {
			$corrupted++;
			if ($NbOfLinesProcessed >= 10 && $corrupted == $NbOfLinesProcessed) {
				# Files seems to have bad format
				print "AWStats did not found any valid log lines that match your <b>LogFormat</b> parameter, in the 10th first non commented lines of your log.<br>\n";
				print "<font color=#880000>Your log file <b>$LogFile</b> must have a bad format or <b>LogFormat</b> parameter setup is wrong.</font><br><br>\n";
				print "Your <b>LogFormat</b> parameter is <b>$LogFormat</b>, this means each line in your log file need to have ";
				if ($LogFormat == 1) {
					print "<b>\"combined log format\"</b> like this:<br>\n";
					print "<font color=#888888><i>111.22.33.44 - - [10/Jan/2001:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234 \"http://www.fromserver.com/from.htm\" \"Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)\"</i></font><br>\n";
				}
				if ($LogFormat == 2) {
					print "<b>\"MSIE Extended W3C log format\"</b> like this:<br>\n";
					print "<font color=#888888><i>date time c-ip c-username cs-method cs-uri-sterm sc-status sc-bytes cs-version cs(User-Agent) cs(Referer)</i></font><br>\n";
				}
				if ($LogFormat != 1 && $LogFormat != 2) {
					print "the following personalised log format:<br>\n";
					print "<font color=#888888><i>$LogFormat</i></font><br>\n";
				}
				print "<br>";
				print "This is a sample of what AWStats found (10th non commented line):<br>\n";
				print "<font color=#888888><i>$_</i></font><br>\n";

				error("");	# Exit with format error
			}
		}

		# Check filters
		#----------------------------------------------------------------------
		if ($field[$pos_method] ne 'GET' && $field[$pos_method] ne 'POST' && $field[$pos_method] !~ /OK/) { next; }	# Keep only GET, POST but not HEAD, OPTIONS
		if ($field[$pos_url] =~ /^RC=/) { $_corrupted++; next; }						# A strange log record with IIS we need to forget
		# Split DD/Month/YYYY:HH:MM:SS or YYYY-MM-DD HH:MM:SS or MM/DD/YY\tHH:MM:SS
		$field[$pos_date] =~ tr/-\/ \t/::::/;
		@dateparts=split(/:/,$field[$pos_date]);
		if ($field[$pos_date] =~ /^....:..:..:/) { $tmp=$dateparts[0]; $dateparts[0]=$dateparts[2]; $dateparts[2]=$tmp; }
		if ($field[$pos_date] =~ /^..:..:..:/) { $dateparts[2]+=2000; $tmp=$dateparts[0]; $dateparts[0]=$dateparts[1]; $dateparts[1]=$tmp; }
		if ($monthnum{$dateparts[1]}) { $dateparts[1]=$monthnum{$dateparts[1]}; }	# Change lib month in num month if necessary
		# Create $timeconnexion like YYYYMMDDHHMMSS
		$timeconnexion=$dateparts[2].$dateparts[1].$dateparts[0].$dateparts[3].$dateparts[4].$dateparts[5];
		if ($timeconnexion < 10000000000000) { $corrupted++; next; }

		# Skip if not a new line
		#-----------------------
		if ($NowNewLinePhase) {
			if ($timeconnexion < $LastTime{$yeartoprocess.$monthtoprocess}) { next; }	# Should not happen, kept in case of parasite old lines
			}
		else {
			if ($timeconnexion <= $LastTime{$yeartoprocess.$monthtoprocess}) { next; }	# Already processed
			$NowNewLinePhase=1;	# This will stop comparison "<=" between timeconnexion and LastTime (we should have only new lines now)
			}

		if (&SkipHost($field[$pos_rc])) { next; }		# Skip with some client host IP addresses
		if (&SkipFile($field[$pos_url])) { next; }		# Skip with some URLs
		if (! &OnlyFile($field[$pos_url])) { next; }	# Skip with other URLs

		# Record is approved. We found a new line. Is it in a new month section ?
		#------------------------------------------------------------------------
		if ((($dateparts[1] > $monthtoprocess) && ($dateparts[2] >= $yeartoprocess)) || ($dateparts[2] > $yeartoprocess)) {
			# Yes, a new month to process
			if ($monthtoprocess > 0) {
				&Save_History_File($yeartoprocess,$monthtoprocess);		# We save data of current processed month
 				&Init_HashArray($yeartoprocess,$monthtoprocess);		# Start init for next one
				}
			$monthtoprocess=$dateparts[1];$yeartoprocess=$dateparts[2];
			&Read_History_File($yeartoprocess,$monthtoprocess,1);		# This should be useless (file must not exist)
			}

		# Check return code
		#------------------
		if (($field[$pos_code] != 200) && ($field[$pos_code] != 304)) {	# Stop if HTTP server return code != 200 and 304
			if ($field[$pos_code] =~ /^[\d][\d][\d]$/) { 				# Keep error code and next
				$_errors_h{$field[$pos_code]}++;
				if ($field[$pos_code] == 404) { $_sider404_h{$field[$pos_url]}++; $_referer404_h{$field[$pos_url]}=$field[$pos_referer]; }
				next;
				}
			else {														# Bad format record (should not happen but when using MSIndex server), next
				$_corrupted++; next;
				}
		}

		$field[$pos_agent] =~ tr/\+ /__/;		# Same Agent with different writing syntax have now same name
		$UserAgent = $field[$pos_agent];
		$UserAgent =~ tr/A-Z/a-z/;

		# Robot ? If yes, we stop here
		#-----------------------------
		$foundrobot=0;
		if (!$TmpHashNotRobot{$UserAgent}) {	# TmpHashNotRobot is a temporary hash table to increase speed
			foreach $bot (keys %RobotHash) { if ($UserAgent =~ /$bot/) { $_robot_h{$bot}++; $_robot_l{$bot}=$timeconnexion ; $foundrobot=1; last; }	}
			if ($foundrobot == 1) { next; }
			$TmpHashNotRobot{$UserAgent}=1;		# Last time, we won't search if robot or not. We know it's not.
		}

		# Canonize and clean target URL and referrer URL
		$field[$pos_url] =~ s/\/$DefaultFile$/\//;	# Replace default page name with / only
		$field[$pos_url] =~ s/\?.*//;					# Trunc CGI parameters in URL get
		$field[$pos_url] =~ s/\/\//\//g;				# Because some targeted url were taped with 2 / (Ex: //rep//file.htm)

		# Check if page or not
		$PageBool=1;
		foreach $cursor (@NotPageList) { if ($field[$pos_url] =~ /$cursor$/i) { $PageBool=0; last; } }

		# Analyze: Date - Hour - Pages - Hits - Kilo
		#-------------------------------------------
		if ($FirstTime{$yeartoprocess.$monthtoprocess} == 0) { $FirstTime{$yeartoprocess.$monthtoprocess}=$timeconnexion; }
		$LastTime{$yeartoprocess.$monthtoprocess} = $timeconnexion;
		if ($PageBool) {
			$_time_p[$dateparts[3]]++; $MonthPage{$yeartoprocess.$monthtoprocess}++;	#Count accesses per hour (page)
			$_sider_p{$field[$pos_url]}++; 									#Count accesses per page (page)
			}
		$_time_h[$dateparts[3]]++; $MonthHits{$yeartoprocess.$monthtoprocess}++;		#Count accesses per hour (hit)
		$_time_k[$dateparts[3]]+=$field[$pos_size]; $MonthBytes{$yeartoprocess.$monthtoprocess}+=$field[$pos_size];	#Count accesses per hour (kb)
		$_sider_h{$field[$pos_url]}++;										#Count accesses per page (hit)
		$_sider_k{$field[$pos_url]}+=$field[$pos_size];								#Count accesses per page (kb)

		# Analyze: IP-address
		#--------------------
		$found=0;
		$Host=$field[$pos_rc];
		if ($Host =~ /^[\d]+\.[\d]+\.[\d]+\.[\d]+$/) {
			# Doing DNS lookup
		    if ($NewDNSLookup) {
				$new=$TmpHashDNSLookup{$Host};	# TmpHashDNSLookup is a temporary hash table to increase speed
				if (!$new) {					# if $new undefined, $Host not yet resolved
					&debug("Start of reverse DNS lookup for $Host",4);
					if ($MyTableDNS{$Host}) {
						&debug("End of reverse DNS lookup, found resolution of $Host in local MyTableDNS",4);
	  					$new = $MyTableDns{$Host};
					}
					else {
						$new=gethostbyaddr(pack("C4",split(/\./,$Host)),AF_INET);	# This is very slow may took 20 seconds
						&debug("End of reverse DNS lookup for $Host",4);
					}
					if ($new eq "") { $new="ip"; }
					$TmpHashDNSLookup{$Host}=$new;
				}
				# Here $Host is still xxx.xxx.xxx.xxx and $new is name or "ip" if reverse failed)
				if ($new ne "ip") { $Host=$new; }
			}
		    # If we don't do lookup or if it failed, we still have an IP address in $Host
		    if (!$NewDNSLookup || $new eq "ip") {
				  if ($PageBool) {
				  		if (int($timeconnexion) > int($_unknownip_l{$Host}+$VisitTimeOut)) { $MonthVisits{$yeartoprocess.$monthtoprocess}++; }
						if ($_unknownip_l{$Host} eq "") { $MonthUnique{$yeartoprocess.$monthtoprocess}++; }
						$_unknownip_l{$Host}=$timeconnexion;		# Table of (all IP if !NewDNSLookup) or (all unknown IP) else
						$_hostmachine_p{"Unknown"}++;
						$_domener_p{"ip"}++;
				  }
				  $_hostmachine_h{"Unknown"}++;
				  $_domener_h{"ip"}++;
				  $_hostmachine_k{"Unknown"}+=$field[$pos_size];
				  $_domener_k{"ip"}+=$field[$pos_size];
				  $found=1;
		      }
	    }
		else {
			if ($Host =~ /[a-z]/) { 
				&debug("The following hostname '$Host' seems to be already resolved.",3);
				$NewDNSLookup=0;
			}
		}	# Hosts seems to be already resolved, make DNS lookup inactive

		# Here, $Host = hostname or xxx.xxx.xxx.xxx
		if (!$found) {				# If not processed yet ($Host = hostname)
			$Host =~ tr/A-Z/a-z/;
			$_ = $Host;

			# Count hostmachine
			if (!$FullHostName) { s/^[\w\-]+\.//; };
			if ($PageBool) {
				if (int($timeconnexion) > int($_hostmachine_l{$_}+$VisitTimeOut)) { $MonthVisits{$yeartoprocess.$monthtoprocess}++; }
				if ($_hostmachine_l{$_} eq "") { $MonthUnique{$yeartoprocess.$monthtoprocess}++; }
				$_hostmachine_p{$_}++;
				$_hostmachine_l{$_}=$timeconnexion;
				}
			$_hostmachine_h{$_}++;
			$_hostmachine_k{$_}+=$field[$pos_size];

			# Count top-level domain
			if (/\./) { /\.([\w]+)$/; $_=$1; };
			if ($DomainsHash{$_}) {
				 if ($PageBool) { $_domener_p{$_}++; }
				 $_domener_h{$_}++;
				 $_domener_k{$_}+=$field[$pos_size];
				 }
			else {
				 if ($PageBool) { $_domener_p{"ip"}++; }
				 $_domener_h{"ip"}++;
				 $_domener_k{"ip"}+=$field[$pos_size];
			}
		}

		# Analyze: Browser
		#-----------------
		$found=0;

		# IE ? (For higher speed, we start whith IE, the most often used. This avoid other tests if found)
		if ($UserAgent =~ /msie/) {
			if (($UserAgent !~ /webtv/) && ($UserAgent !~ /omniweb/) && ($UserAgent !~ /opera/)) {
				$_browser_h{"msie"}++;
				$UserAgent =~ /msie_(\d)\./;  # $1 now contains major version no
				$_msiever_h[$1]++;
				$found=1;
			}
		}

		# Netscape ?
		if (!$found) {
			if ($UserAgent =~ /mozilla/ && $UserAgent !~ /compatible/) {
		    	$_browser_h{"netscape"}++;
		    	$UserAgent =~ /\/(\d)\./;  # $1 now contains major version no
		    	$_nsver_h[$1]++;
		    	$found=1;
			}
		}

		# Other ?
		if (!$found) {
			foreach $key (keys %BrowsersHash) {
		    	if ($UserAgent =~ /$key/) { $_browser_h{$key}++; $found=1; last; }
			}
		}

		# Unknown browser ?
		if (!$found) { $_browser_h{"Unknown"}++; $_unknownrefererbrowser_l{$field[$pos_agent]}=$timeconnexion; }

		# Analyze: OS
		#------------
		$found=0;
		if (!$TmpHashOS{$UserAgent}) {
			# OSHash list ?
			foreach $key (keys %OSHash) {
				if ($UserAgent =~ /$key/) { $_os_h{$key}++; $found=1; $TmpHashOS{$UserAgent}=$key; last; }
			}
			# OSAliasHash list ?
			if (!$found) {
				foreach $key (keys %OSAliasHash) {
					if ($UserAgent =~ /$key/) { $_os_h{$OSAliasHash{$key}}++; $found=1; $TmpHashOS{$UserAgent}=$OSAliasHash{$key}; last; }
				}
			}
			# Unknown OS ?
			if (!$found) { $_os_h{"Unknown"}++; $_unknownreferer_l{$field[$pos_agent]}=$timeconnexion; }
		}
		else {
			$_os_h{$TmpHashOS{$UserAgent}}++;
		}

		# Analyze: Referer
		#-----------------
		$found=0;

		# Direct ?
		if ($field[$pos_referer] eq "-") { $_from_h[0]++; $found=1; }

		# HTML link ?
		if (!$found) {
			if ($field[$pos_referer] =~ /^http/i) {
				$internal_link=0;
				if ($field[$pos_referer] =~ /^http(s|):\/\/(www.|)$SiteToAnalyzeWithoutwww/i) { $internal_link=1; }
				else {
					foreach $HostAlias (@HostAliases) {
						if ($field[$pos_referer] =~ /^http(s|):\/\/$HostAlias/i) { $internal_link=1; last; }
						}
				}

				if ($internal_link) {
				    # Intern (This hit came from another page of the site)
				    $_from_h[4]++;
					$found=1;
				}
				else {
				    # Extern (This hit came from an external web site)
					@refurl=split(/\?/,$field[$pos_referer]);
					$refurl[0] =~ tr/A-Z/a-z/;
				    foreach $key (keys %SearchEnginesHash) {
						if ($refurl[0] =~ /$key/) {
							# This hit came from the search engine $key
							$_from_h[2]++;
							$_se_referrals_h{$key}++;
							$found=1;
							# Extract keywords
							$refurl[1] =~ tr/A-Z/a-z/;				# Full param string in lowcase
							@paramlist=split(/&/,$refurl[1]);
							if ($SearchEngineKnownUrl{$key}) {		# Search engine with known URL syntax
								foreach $param (@paramlist) {
									if ($param =~ /^$SearchEngineKnownUrl{$key}/) { # We found good parameter
										&UnescapeURLParam($param);			# Change [ xxx=cache:www+aaa+bbb/ccc+ddd%20eee'fff ] into [ xxx=cache:www aaa bbb ccc ddd eee fff ]
										# Ok, "xxx=cache:www aaa bbb ccc ddd eee fff" is a search parameter line
										$param =~ s/.*=//;					# Cut "xxx="
										$param =~ s/^cache:[^ ]* //;
										$param =~ s/^related:[^ ]* //;
										if ($SplitSearchString) {
											@wordlist=split(/ /,$param);	# Split aaa bbb ccc ddd eee fff into a wordlist array
											foreach $word (@wordlist) {
												if ((length $word) > 0) { $_keywords{$word}++; }
											}
										}
										else {
											$param =~ s/^ *//; $param =~ s/ *$//; $param =~ tr/ / /s;
											if ((length $param) > 0) { $param =~ tr/ /+/; $_keywords{$param}++; }
										}
										last;
									}
								}
							}
							else {									# Search engine with unknown URL syntax
								foreach $param (@paramlist) {
									&UnescapeURLParam($param);		# Change [ xxx=cache:www+aaa+bbb/ccc+ddd%20eee'fff ] into [ xxx=cache:www aaa bbb ccc ddd eee fff ]
									$keep=1;
									foreach $paramtoexclude (@WordsToCleanSearchUrl) {
										if ($param =~ /.*$paramtoexclude.*/) { $keep=0; last; } # Not the param with search criteria
									}
									if ($keep == 0) { next; }			# Do not keep this URL parameter because is in exclude list
									# Ok, "xxx=cache:www aaa bbb ccc ddd eee fff" is a search parameter line
									$param =~ s/.*=//;					# Cut "xxx="
									$param =~ s/^cache:[^ ]* //;
									$param =~ s/^related:[^ ]* //;
									if ($SplitSearchString) {
										@wordlist=split(/ /,$param);	# Split aaa bbb ccc ddd eee fff into a wordlist array
										foreach $word (@wordlist) {
											if ((length $word) > 2) { $_keywords{$word}++; }	# Keep word only if word length is 3 or more
										}
									}
									else {
										$param =~ s/^ *//; $param =~ s/ *$//; $param =~ tr/ / /s;
										if ((length $param) > 2) { $param =~ tr/ /+/; $_keywords{$param}++; }
									}
								}
							}
							last;
						}
					}
					if (!$found) {
						# This hit came from a site other than a search engine
						$_from_h[3]++;
						if ($field[$pos_referer] =~ /http:\/\/[^\/]*\/$/i) { $field[$pos_referer] =~ s/\/$//; }	# To make htpp://www.mysite.com and http://www.mysite.com/ as same referer
						$_pagesrefs_h{$field[$pos_referer]}++;
						$found=1;
					}
				}
			}
		}

		# News link ?
		if (!$found) {
			if ($field[$pos_referer] =~ /^news/i) {
				$_from_h[1]++;
				$found=1;
			}
		}

	}
	close LOG;
	&debug("End of processing log file");

	# DNSLookup warning
	if ($DNSLookup && !$NewDNSLookup) { warning("Warning: <b>$PROG</b> has detected that hosts names are already resolved in your logfile <b>$LogFile</b>.<br>\nIf this is always true, you should change your setup DNSLookup=1 into DNSLookup=0 to increase $PROG speed."); }

	# Save current processed month $monthtoprocess
	if ($UpdateStats && $monthtoprocess) {	# If monthtoprocess is still 0, it means there was no history files and we found no valid lines in log file
		&Save_History_File($yeartoprocess,$monthtoprocess);		# We save data for this month,year
		if (($MonthRequired ne "year") && ($monthtoprocess != $MonthRequired)) { &Init_HashArray($yeartoprocess,$monthtoprocess); }	# Not a desired month, so we clean data
	}

	# Archive LOG file into ARCHIVELOG
	if (($PurgeLogFile == 1) && ($ArchiveLogRecords == 1)) {
		&debug("Start of archiving log file");
		$ArchiveFileName="$DirData/${PROG}_archive$FileSuffix.log";
		open(LOG,"+<$LogFile") || error("Error: Enable to archive log records of \"$LogFile\" into \"$ArchiveFileName\" because source can't be opened for read and write: $!<br>\n");
		open(ARCHIVELOG,">>$ArchiveFileName") || error("Error: Couldn't open file \"$ArchiveFileName\" to archive current log: $!");
		while (<LOG>) {	print ARCHIVELOG $_; }
		close(ARCHIVELOG);
		chmod 438,"$ArchiveFileName";
		&debug("End of archiving log file");
	}
	else {
		open(LOG,"+<$LogFile");
	}

	# Rename all HISTORYTMP files into HISTORYTXT
	$allok=1;
	opendir(DIR,"$DirData");
	@filearray = sort readdir DIR;
	close DIR;
	foreach $i (0..$#filearray) {
		if ("$filearray[$i]" =~ /^$PROG[\d][\d][\d][\d][\d][\d]$FileSuffix\.tmp\..*$/) {
			$yearmonthfile=$filearray[$i]; $yearmonthfile =~ s/^$PROG//; $yearmonthfile =~ s/\..*//;
			if (-s "$DirData/$PROG$yearmonthfile$FileSuffix.tmp.$$") {	# Rename only files for this session and with size > 0
				if (rename("$DirData/$PROG$yearmonthfile$FileSuffix.tmp.$$", "$DirData/$PROG$yearmonthfile$FileSuffix.txt")==0) {
					$allok=0;	# At least one error in renaming working files
					last;
				}
				chmod 438,"$DirData/$PROG$yearmonthfile$FileSuffix.txt";
			}
		}
	}

	# Purge Log file if all renaming are ok and option is on
	if (($allok > 0) && ($PurgeLogFile == 1)) {
		truncate(LOG,0) || warning("Warning: <b>$PROG</b> couldn't purge logfile \"<b>$LogFile</b>\".<br>\nChange your logfile permissions to allow write for your web server<br>\nor change PurgeLofFile=1 into PurgeLogFile=0 in configure file<br>\n(and think to purge sometines your logile. Launch $PROG just before this to save in $PROG history text files all informations logfile contains).");
	}
	close(LOG);

}	# End of log processing


# Get list of all possible years
opendir(DIR,"$DirData");
@filearray = sort readdir DIR;
close DIR;
foreach $i (0..$#filearray) {
	if ("$filearray[$i]" =~ /^$PROG[\d][\d][\d][\d][\d][\d]$FileSuffix\.txt$/) {
		$yearmonthfile=$filearray[$i]; $yearmonthfile =~ s/^$PROG//; $yearmonthfile =~ s/\..*//;
		$yearfile=$yearmonthfile; $yearfile =~ s/^..//;
		$listofyears{$yearfile}=1;
	}
}


# Here, first part of data for all processed month (old and current) are still in memory
# If a month was already processed, then $HistoryFileAlreadyRead{"MMYYYY"} value is 1


#-------------------------------------------------------------------------------
# READING NOW ALL NOT ALREADY READ HISTORY FILES FOR ALL MONTHS OF REQUIRED YEAR
#-------------------------------------------------------------------------------

# Loop on each month of year but only existing and not already read will be read by Read_History_File function
for ($ix=12; $ix>=1; $ix--) {
	$monthix=$ix+0; if ($monthix < 10) { $monthix  = "0$monthix"; }	# Good trick to change $monthix into "MM" format
	if ($MonthRequired eq "year" || $monthix == $MonthRequired) {
		&Read_History_File($YearRequired,$monthix,1);	# Read full history file
	}
	else {
		&Read_History_File($YearRequired,$monthix,0);	# Read first part of history file is enough
	}
}



#---------------------------------------------------------------------
# SHOW STATISTICS
#---------------------------------------------------------------------
if ($QueryString =~ /action=unknownip/i) {
	print "$CENTER<a name=\"UNKOWNIP\"></a><BR>";
	$tab_titre=$message[45][$Lang];
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH>$message[48][$Lang]</TH><TH>$message[9][$Lang]</TH>\n";
	@sortunknownip=sort { $SortDir*$_unknownip_l{$a} <=> $SortDir*$_unknownip_l{$b} } keys (%_unknownip_l);
	foreach $key (@sortunknownip) {
		$yearcon=substr($_unknownip_l{$key},0,4);
		$monthcon=substr($_unknownip_l{$key},4,2);
		$daycon=substr($_unknownip_l{$key},6,2);
		$hourcon=substr($_unknownip_l{$key},8,2);
		$mincon=substr($_unknownip_l{$key},10,2);
		if ($Lang == 1) { print "<tr><td>$key</td><td>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
		else { print "<tr><td>$key</td><td>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /action=unknownrefererbrowser/i) {
	print "$CENTER<a name=\"UNKOWNREFERERBROWSER\"></a><BR>";
	$tab_titre=$message[50][$Lang];
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH>Referer</TH><TH>$message[9][$Lang]</TH></TR>\n";
	@sortunknownrefererbrowser=sort { $SortDir*$_unknownrefererbrowser_l{$a} <=> $SortDir*$_unknownrefererbrowser_l{$b} } keys (%_unknownrefererbrowser_l);
	foreach $key (@sortunknownrefererbrowser) {
		$yearcon=substr($_unknownrefererbrowser_l{$key},0,4);
		$monthcon=substr($_unknownrefererbrowser_l{$key},4,2);
		$daycon=substr($_unknownrefererbrowser_l{$key},6,2);
		$hourcon=substr($_unknownrefererbrowser_l{$key},8,2);
		$mincon=substr($_unknownrefererbrowser_l{$key},10,2);
		$key =~ s/<script.*$//gi;				# This is to avoid 'Cross Site Scripting attacks'
		if ($Lang == 1) { print "<tr><td CLASS=LEFT>$key</td><td>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
		else { print "<tr><td CLASS=LEFT>$key</td><td>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /action=unknownreferer/i) {
	print "$CENTER<a name=\"UNKOWNREFERER\"></a><BR>";
	$tab_titre=$message[46][$Lang];
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH>Referer</TH><TH>$message[9][$Lang]</TH></TR>\n";
	@sortunknownreferer=sort { $SortDir*$_unknownreferer_l{$a} <=> $SortDir*$_unknownreferer_l{$b} } keys (%_unknownreferer_l);
	foreach $key (@sortunknownreferer) {
		$yearcon=substr($_unknownreferer_l{$key},0,4);
		$monthcon=substr($_unknownreferer_l{$key},4,2);
		$daycon=substr($_unknownreferer_l{$key},6,2);
		$hourcon=substr($_unknownreferer_l{$key},8,2);
		$mincon=substr($_unknownreferer_l{$key},10,2);
		$key =~ s/<script.*$//gi;				# This is to avoid 'Cross Site Scripting attacks'
		if ($Lang == 1) { print "<tr><td CLASS=LEFT>$key</td><td>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
		else { print "<tr><td CLASS=LEFT>$key</td><td>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /action=notfounderror/i) {
	print "$CENTER<a name=\"NOTFOUNDERROR\"></a><BR>";
	$tab_titre=$message[47][$Lang];
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH>URL</TH><TH bgcolor=#$color_h>$message[49][$Lang]</TH><TH>$message[23][$Lang]</TH></TR>\n";
	@sortsider404=sort { $SortDir*$_sider404_h{$a} <=> $SortDir*$_sider404_h{$b} } keys (%_sider404_h);
	foreach $key (@sortsider404) {
		$url=$key; $url =~ s/<script.*$//gi; 							# This is to avoid 'Cross Site Scripting attacks'
		$referer=$_referer404_h{$key}; $referer =~ s/<script.*$//gi;	# This is to avoid 'Cross Site Scripting attacks'
		print "<tr><td CLASS=LEFT>$url</td><td>$_sider404_h{$key}</td><td>$referer&nbsp;</td></tr>";
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /action=browserdetail/i) {
	print "$CENTER<a name=\"NETSCAPE\"></a><BR>";
	$tab_titre=$message[33][$Lang]."<br><img src=\"$DirIcons/browser/netscape.png\">";
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH>$message[58][$Lang]</TH><TH bgcolor=#$color_h width=40>$message[57][$Lang]</TH><TH bgcolor=#$color_h width=40>$message[15][$Lang]</TH></TR>\n";
	for ($i=1; $i<=$#_nsver_h; $i++) {
		if ($_nsver_h[$i] gt 0) {
			$h=$_nsver_h[$i]; $p=int($_nsver_h[$i]/$_browser_h{"netscape"}*1000)/10; $p="$p&nbsp;%";
		}
		else {
			$h="&nbsp;"; $p="&nbsp;";
		}
		print "<TR><TD CLASS=LEFT>Mozilla/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
	}
	&tab_end;
	print "<a name=\"MSIE\"></a><BR>";
	$tab_titre=$message[34][$Lang]."<br><img src=\"$DirIcons/browser/msie.png\">";
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH>$message[58][$Lang]</TH><TH bgcolor=#$color_h width=40>$message[57][$Lang]</TH><TH bgcolor=#$color_h width=40>$message[15][$Lang]</TH></TR>\n";
	for ($i=1; $i<=$#_msiever_h; $i++) {
		if ($_msiever_h[$i] gt 0) {
			$h=$_msiever_h[$i]; $p=int($_msiever_h[$i]/$_browser_h{"msie"}*1000)/10; $p="$p&nbsp;%";
		}
		else {
			$h="&nbsp;"; $p="&nbsp;";
		}
		print "<TR><TD CLASS=LEFT>MSIE/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
	}
	&tab_end;

	&html_end;
	exit(0);
	}
if ($QueryString =~ /action=info/i) {
	# Not yet available
	print "$CENTER<a name=\"INFO\"></a><BR>";
	&html_end;
	exit(0);
	}

&debug("Start of sorting hash arrays");
@RobotArray=keys %RobotHash;
@SearchEnginesArray=keys %SearchEnginesHash;
@sortdomains_p=sort { $SortDir*$_domener_p{$a} <=> $SortDir*$_domener_p{$b} } keys (%_domener_p);
@sortdomains_h=sort { $SortDir*$_domener_h{$a} <=> $SortDir*$_domener_h{$b} } keys (%_domener_h);
@sortdomains_k=sort { $SortDir*$_domener_k{$a} <=> $SortDir*$_domener_k{$b} } keys (%_domener_k);
@sorthosts_p=sort { $SortDir*$_hostmachine_p{$a} <=> $SortDir*$_hostmachine_p{$b} } keys (%_hostmachine_p);
@sortsiders=sort { $SortDir*$_sider_p{$a} <=> $SortDir*$_sider_p{$b} } keys (%_sider_p);
@sortbrowsers=sort { $SortDir*$_browser_h{$a} <=> $SortDir*$_browser_h{$b} } keys (%_browser_h);
@sortos=sort { $SortDir*$_os_h{$a} <=> $SortDir*$_os_h{$b} } keys (%_os_h);
@sortsereferrals=sort { $SortDir*$_se_referrals_h{$a} <=> $SortDir*$_se_referrals_h{$b} } keys (%_se_referrals_h);
@sortpagerefs=sort { $SortDir*$_pagesrefs_h{$a} <=> $SortDir*$_pagesrefs_h{$b} } keys (%_pagesrefs_h);
@sortsearchwords=sort { $SortDir*$_keywords{$a} <=> $SortDir*$_keywords{$b} } keys (%_keywords);
@sorterrors=sort { $SortDir*$_errors_h{$a} <=> $SortDir*$_errors_h{$b} } keys (%_errors_h);
&debug("End of sorting hash arrays");

# English tooltips
if (($Lang != 1) && ($Lang != 2) && ($Lang != 3) && ($Lang != 4) && ($Lang != 6) && ($Lang != 10)) {
	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt1\">
	A new visits is defined as each new <b>incoming visitor</b> (viewing or browsing a page) who was not connected to your site during last <b>".($VisitTimeOut/10000*60)." mn</b>.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt2\">
	Number of client hosts (<b>IP address</b>) who came to visit the site (and who viewed at least one <b>page</b>).<br>
	This data refers to the number of <b>different physical persons</b> who had reached the site in any one day.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt3\">
	Number of times a <b>page</b> of the site is <b>viewed</b> (Sum for all visitors for all visits).<br>
	This piece of data differs from \"hits\" in that it counts only HTML pages as oppose to images and other files.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt4\">
	Number of times a <b>page, image, file</b> of the site is <b>viewed</b> or <b>downloaded</b> by someone.<br>
	This piece of data is provided as a reference only, since the number of \"pages\" viewed is often prefered for marketing purposes.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt5\">
	This piece of information refers to the amount of data downloaded by all <b>pages</b>, <b>images</b> and <b>files</b> within your site measured in KBs.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt13\">
	$PROG recognizes each access to your site after a <b>search</b> from the <b>".(@SearchEnginesArray)." most popular Internet Search Engines and Directories</b> (such as Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt14\">
	List of all <b>external pages</b> which were used to link (or enter) to your site (Only the <b>$MaxNbOfRefererShown</b> most often used external pages are shown.\n
	Links used by the results of the search engines are excluded here because they have already been included on the previous line within this table.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt15\">
	This table shows the list of the most frequently <b>keywords</b> utilized to find your site from Internet Search Engines and Directories.
	(Keywords from the <b>".(@SearchEnginesArray)."</b> most popular Search Engines and Directories are recognized by $PROG, such as Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt16\">
	Robots (sometimes refer to Spiders) are <b>automatic computer visitors</b> used by many search engines that scan your web site to (1) index it and rank it, (2) collect statistics on Internet Web sites and/or (3) see if your site is still online.<br>
	$PROG is able to recognize up to <b>".(@RobotArray)."</b> robots.
	</DIV>";

	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt201\"> No description for this error. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt202\"> Request was understood by server but will be processed later. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt204\"> Server has processed the request but there is no document to send. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt206\"> Partial content. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt301\"> Requested document was moved and is now at another address given in awnswer. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt302\"> No description for this error. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt400\"> Syntax error, server didn\'t understand request. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt401\"> Tried to reach an <b>URL where a login/password pair was required</b>.<br>A high number within this item could mean that someone (such as a hacker) is attempting to crack, or enter into your site (hoping to enter a secured area by trying different login/password pairs, for instance). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt403\"> Tried to reach an <b>URL not configured to be reachable, even with an login/password pair</b> (for example, an URL within a directory not defined as \"browsable\".). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt404\"> Tried to reach a <b>non existing URL</b>. This error often means that there is an invalid link somewhere in your site or that a visitor mistyped a certain URL. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt408\"> Server has taken <b>too much time</b> to respond to a request. This error frequently involves either a slow CGI script which the server was required to kill or an extremely congested web server. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt500\"> Internal error. This error is often caused by a CGI program that had finished abnormally (coredump for example). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt501\"> Unknown requested action. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt502\"> Code returned by a HTTP server that works as a proxy or gateway when a real, targeted server doesn\'t answer successfully to the client\'s request. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt503\"> Internal server error. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt504\"> Gateway Time-out. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt505\"> HTTP Version Not Supported. </DIV>
	";
}

# French tooltips
if ($Lang == 1) {
	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt1\">
	On considère une nouvelle visite pour <b>chaque arrivée</b> d un visiteur consultant une page et ne s étant pas connecté dans les dernières <b>".($VisitTimeOut/10000*60)." mn</b>.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt2\">
	Nombre de hotes (<b>adresse IP</b>) utilisés pour accéder au site (et voir au moins une <b>page</b>).<br>
	Ce chiffre reflète le nombre de <b>personnes physiques</b> différentes ayant un jour accédées au site.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt3\">
	Nombre de fois qu une <b>page</b> du site est <b>vue</b> (Cumul de tout visiteur, toute visite).<br>
	Ce compteur différe des \"hits\" car il ne comptabilise que les pages HTML et non les images ou autres fichiers.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt4\">
	Nombre de fois qu une <b>page, image, fichier</b> du site est <b>vu</b> ou <b>téléchargé</b> par un visiteur.<br>
	Ce compteur est donné à titre indicatif, le compteur \"pages\" etant préféré.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt5\">
	Nombre de <b>kilo octets</b> téléchargé lors des visites du site.<br>
	Il s agit aussi bien du volume de données du au chargement des <b>pages</b> et <b>images</b> que des <b>fichiers</b> téléchargés.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt13\">
	$PROG est capable de reconnaitre l acces au site issu d une <b>recherche</b> depuis les <b>".(@SearchEnginesArray)." moteurs de recherche Internet</b> les plus connus (Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt14\">
	Liste des <b>pages de sites externes</b> contenant un lien suivi pour accéder à ce site (Seules les <b>$MaxNbOfRefererShown</b> pages externes les plus utilisées sont affichées).\n
	Les liens issus du résultat d un moteur de recherche connu n apparaissent pas ici, car comptabilisés à part sur la ligne juste au-dessus.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt15\">
	Ce tableau offre la liste des <b>mots</b> les plus souvent utilisés pour retrouver et accéder au site depuis
	un moteur de recherche Internet (Les recherches depuis <b>".(@SearchEnginesArray)."</b> moteurs de recherche parmi les pluspopulaires sont reconnues, comme Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt16\">
	Les robots sont des <b>automates visiteurs</b> scannant le site dans le but de l indexer, d obtenir des statistiques sur les sites Web Internet ou de vérifier sa disponibilié.<br>
	$PROG reconnait <b>".(@RobotArray)."</b> robots.
	</DIV>";

	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt201\"> Contenu partiel renvoyé. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt202\"> La requête a été enregistrée par le serveur mais sera exécutée plus tard. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt204\"> Le serveur a traité la demande mais il n existe aucun document à renvoyer. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt206\"> Contenu partiel renvoyé. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt301\"> Le document réclamé a été déplacé et se trouve maintenant à une autre adresse mentionnée dans la réponse. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt302\"> Aucun descriptif pour cette erreur. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt400\"> Erreur de syntaxe, le serveur n a pas compris la requête. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt401\"> Tentatives d accès à une <b>URL nécessitant identification avec un login/mot de passe invalide</b>.<br>Un nombre trop élévé peut mettre en évidence une tentative de crackage brute du site (par accès répété de différents logins/mots de passe). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt403\"> Tentatives d accès à une <b>URL non configurée pour etre accessible, même avec une identification</b> (par exemple, une URL d un répertoire non défini comme étant \"listable\"). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt404\"> Tentatives d accès à une <b>URL inexistante</b>. Il s agit donc d un lien invalide sur le site ou d une faute de frappe d un visiteur qui a saisie une mauvaise URL directement. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt408\"> Le serveur mis un <b>temps trop important</b> pour répondre à la requête. Il peut s agir d un script CGI trop lent sur le serveur forcé d abandonner le traitement ou d une saturation du site. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt500\"> Erreur interne au serveur. Cette erreur est le plus souvant renvoyé lors de l arrêt anormal d un script CGI (par exemple suite à un coredump du CGI). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt501\"> Le serveur ne prend pas en charge l action demandée. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt502\"> Code renvoyé par un serveur HTTP qui fonctionne comme proxy ou gateway lorsque le serveur réel consulté ne réagit pas avec succès à la demande du client. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt503\"> Erreur interne au serveur. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt504\"> Gateway Time-out. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt505\"> Version HTTP non supporté. </DIV>
	";
}

# Dutch tooltips
if ($Lang == 2) {
	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt1\">
	Een nieuw bezoek is elke <b>binnenkomende bezoeker</b> (die een pagina bekijkt) die de laatste <b>".($VisitTimeOut/10000*60)." mn</b> niet met uw site verbonden was.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt2\">
	Number of client hosts (<b>IP address</b>) who came to visit the site (and who viewed at least one <b>page</b>).<br>
	This data refers to the number of <b>different physical persons</b> who had reached the site in any one day.
	Aantal client hosts (<b>IP adres</b>) die de site bezochten (en minimaal een <b>pagina</b> bekeken).<br>
	Dit geeft aan hoeveel <b>verschillende fysieke personen</b> de site op een bepaalde dag bezocht hebben.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt3\">
	Aantal malen dat een <b>pagina</b> van de site <b>bekeken</b> is (Som voor alle bezoekers voor alle bezoeken).<br>
	Dit onderdeel verschilt van \"hits\" in het feit dat het alleen HTML pagina\'s telt, in tegenstelling tot plaatjes en andere bestanden.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt4\">
	Aantal malen dat een <b>pagina</b>, <b>plaatje</b> of <b>bestand</b> op de site door iemand is <b>bekeken</b> of <b>gedownload</b>.<br>
	Dit onderdeel is alleen als referentie gegeven, omdat het aantal bekeken \"pagina\'s\" voor marketingdoeleinden de voorkeur heeft.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt5\">
	Aantal door uw bezoekers gedownloade <b>kilobytes</b>.<br>
	Dit onderdeel geeft de hoeveelheid gedownloade gegevens in alle <b>pagina\'s</b>, <b>plaatjes</b> en <b>bestanden</b> van uw site, gemeten in KBs.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt13\">
	Dit programma, $PROG, herkent elke benadering van uw site na een <b>zoekopdracht</b> van de <b>".(@SearchEnginesArray)." meest populaire Internet zoekmachines</b> (zoals Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt14\">
	Lijst van alle <b>externe pagina\'s</b> die zijn gebruikt om naar uw site te linken (of deze te benaderen) (Alleen de <b>$MaxNbOfRefererShown</b> meest gebruikte externe pagina\'s zijn getoond.\n
	Links gebruikt door de resultaten van zoekmachines worden hiet niet getoond omdat deze al zijn opgenomen in de vorige regel van deze tabel.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt15\">
	Deze tabel toont de lijst van <b>keywords</b> die het meest zijn gebruikt om uw site te vindein in Internet zoekmachines.
	(Keywords van de <b>".(@SearchEnginesArray)."</b> meest populaire zoekmachines worden door $PROG herkend, zoals Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt16\">
	Robots (soms Spiders genoemd) zijn <b>automatische bezoekcomputers</b> die door veel zoekmachines worden gebruikt om uw site te scannen om (1) deze te indexeren, (2) statistieken over Internet sites te verzamelen en/of (3) te kijken of site nog steeds on-line is.<br>
	Dit programma, $PROG, is in staat maximaal <b>".(@RobotArray)."</b> robots te herkennen</b>.
	</DIV>";

	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt201\"> Geen beschrijving voor deze foutmelding. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt202\"> De server heeft het verzoek begrepen, maar zal deze later behandelen. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt204\"> De server heeft het verzoek verwerkt, maar er is geen document om te verzenden. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt206\"> Gedeeltelijke inhoud. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt301\"> Het aangevraagde document is verplaatst en is nu op een andere locatie die in het antwoord gegeven is. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt302\"> Geen beschrijving voor deze foutmelding. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt400\"> \"Taalfout\", de server begreep het verzoek niet. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt401\"> Er is gepoogd een <b>URL waarvoor een usernaam/wachtwoord noodzakelijk is</b> te benaderen.<br>Een hoog aantal van deze meldingen kan betekenen dat iemand (zoals een hacker) probeert uw site te kraken, of uw site binnen te komen (pogend een beveiligd onderdeel van uw site te benaderen door verschillende usernamen/wachtwoorden te proberen, bijvoorbeeld). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt403\"> Er is gepoogd een <b>URL die is ingesteld om niet benaderbaar te zijn, zelfs met usernaam/wachtwoord</b> te benaderen (bijvoorbeeld, een URL in een directory die niet \"doorbladerbaar\" is). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt404\"> Er is gepoogd een <b>niet bestaande URL</b> te benaderen. Deze fout betekent vaak dat er een ongeldige link in uw site zit of dat een bezoeker een URL foutief heeft ingevoerd. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt408\"> De server heeft er <b>te lang</b> over gedaan om een antwoord op een aanvraag te geven. Het kan een CGI script zijn dat zo traag is dat de server hem heeft moeten afbreken of een overbelaste web server. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt500\"> Interne fout. Deze error wordt vaak veroorzaakt door een CGI programma dat abnormaal is beeindigd (een core dump, bijvoorbeeld). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt501\"> Onbekende actie aangevraagd. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt502\"> Melding die door een proxy of gateway HTTP server wordt gegeven als een echte doelserver niet succesvol op de aanvraag van een client antwoordt. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt503\"> Interne server fout. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt504\"> Gateway time-out. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt505\"> HTTP versie niet ondersteund. </DIV>
	";
}

# Spanish tooltips
if ($Lang == 3) {
	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt1\">
	Se considera un nueva vista por <b>cada nuevo visitante</b> que consulte una página y que no haya accesado el sitio en los últimos <b>".($VisitTimeOut/10000*60)." mins.</b>.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt2\">
	Número de Servidores (<b>direcciones IP</b>) que entran a un sitio (y que por lo menos visitan una <b>página</b>).<br>
	Esta cifra refleja el número de <b>personas físicas diferentes</b> que hayan accesado al sitio en un día.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt3\">
	Número de ocasiones que una <b>página</b> del sitio ha sido <b>vista</b> (La suma de todos los visitantes incluyendo múltiples visitas).<br>
	Este contador se distingue de \"hits\" porque cuenta sólo las páginas HTML y no los gráficos u otros archivos o ficheros.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt4\">
	El número de ocasiones que una <b>página, imagen, archivo o fichero</b> de un sitio es <b>visto</b> o <b>descargado</b> por un visitante.<br>
	Este contador sirve de referencia, pero el contador de \"páginas\" representa un dato mercadotécnico generalmente más útil y por lo tanto se recomienda.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt5\">
	El número de <b>kilo bytes</b> descargados por los visitantes del sitio.<br>
	Se refiere al volumen de datos descargados por todas las <b>páginas</b>, <b>imágenes</b> y <b>archivos o ficheros</b> medidos en kilo bytes.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt13\">
	El programa $PROG es capaz de reconocer una visita a su sitio luego de cada <b>búsqueda</b> desde cualquiera de los <b>".(@SearchEnginesArray)." motores de búsqueda y directorios Internet</b> más populares (Yahoo, Altavista, Lycos, Google, Terra, etc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt14\">
	Lista de <b>páginas de sitios externos</b> utilizadas para acceder o enlazarse con su sitio (Sólo las <b>$MaxNbOfRefererShown</b> páginas más utilizadas se encuentras enumeradas).\n
	Los enlaces utilizados por los motores de búsqueda o directorios son excluidos porque ya han sido contabilizados en el rubro anterior.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt15\">
	Esta tabla muestra la lista de las <b>palabras clave</b> más utilizadas en los motores de búsqueda y directorios Internet para encontrar su sitio.
	(El programa $PROG reconoce palabras clave usadas en los <b>".(@SearchEnginesArray)."</b> motores de búsqueda más populares, tales como Yahoo, Altavista, Lycos, Google, Voila, Terra etc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt16\">
	Los Robots son <b>visitantes automáticos</b> que escanean o viajan por su sitio para indexarlo, o jerarquizarlo, para recopilar estadísticas de sitios Web, o para verificar si su sitio se encuentra conectado a la Red.<br>
	El programa $PROG reconoce hasta <b>".(@RobotArray)."</b> robots.
	</DIV>";

	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt201\"> Error sin descripción. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt202\"> La solicitud ha sido computada pero el servidor la procesará más tarde. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt204\"> El servidor ha procesado la solicitud pero no existen documentos para enviar. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt206\"> Contenido parcial. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt301\"> El documento solicitado ha sido reubicado y se encuentra en un URL proporcionado en la misma respuesta. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt302\"> Error sin descripción. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt400\"> Error de sintaxis, el servidor no ha comprendido su solicitud. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt401\"> Número de intentos por acceder un <b>URL que exige una combinación usuario/contraseña que ha sido invalida.</b>.<br>Un número de intentos muy elevado pudiera sugerir la posibilidad de que un hacker (o pirata) ha intentado entrar a una zona restringida del sitio (p.e., intentando múltiples combinaciones de usuario/contraseña). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt403\"> Número de intentos por acceder un <b>URL configurado para no ser accesible, aún con una combinación usuario/contraseña</b> (p.e., un URL previamente definido como \"no navegable\"). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt404\"> Número de intentos por acceder un <b>URL inexistente</b>. Frecuentemente, éstos se refieren ya sea a un enlace (link) inválido o a un error mecanográfico cuando el visitante tecleó el URL equivocado. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt408\"> El servidor ha tomado <b>demasiado tiempo</b> para responder a una solicitud. Frecuentemente se debe ya sea a un programa CGI muy lento, el cual tuvo que ser abandonado por el servidor, o bien por un servidor sobre-saturado. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt500\"> Error interno. Este error generalmente es causado por una terminación anormal o prematura de un programa CGI (p.e., un CGI corrompido o dañado). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt501\"> Solicitud desconocida por el servidor. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt502\"> Código retornado por un servidor de protocolo HTTP el cual funge como proxy o puente (gateway) cuando el servidor objetivo no funciona o no interpreta adecuadamente la solicitud del cliente (o visitante). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt503\"> Error interno del servidor. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt504\"> Gateway time-out. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt505\"> Versión de protocolo HTTP no soportada. </DIV>
	";
}

# Italian tooltips
if ($Lang == 4) {
	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt1\">
	Si considera una nuova visita per <b>ogni arrivo</b> di un visitatore che visualizza o consulta una pagina e non si è connesso negli ultimi <b>".($VisitTimeOut/10000*60)." minuti</b>.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt2\">
	Numero di client hosts (<b>indirizzi IP</b>) utilizzati per accedere al sito (e visualizzare almeno una <b>pagina</b>).<br>
	Questa cifra riflette il numero di <b>persone fisiche</b> differenti che un giorno hanno visitato il sito.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt3\">
	Numero di volte che una <b>pagina</b> del sito è stata <b>vista</b> (somma di tutti i visitatori, per tutte le visite).<br>
	Questo valore è diverso dagli \"hits\" perchè considera solamente le pagine HTML e non le immagini o gli altri elementi.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt4\">
	Numero di volte che una <b>pagina, immagine o elemento</b> del sito è <b>visto</b> o <b>scaricato</b> da un visitatore.<br>
	Questo valore è indicativo, in quanto il contatore \"pagine\" a volte é più significativo ai fini commerciali.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt5\">
	Numero totale di <b>kilobytes</b> scaricati dal sito durante le visite.<br>
	Indica il volume di traffico dovute alle richieste di caricamento delle <b>pagine</b>, delle <b>immagini</b> e degli altri <b>elementi</b> scaricati.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt13\">
	$PROG è capace di riconoscere gli accessi al sito provenienti dalle <b>ricerche</b> dei <b>".(@SearchEnginesArray)." motori di ricerca Internet</b> più conosciuti (Yahoo, Altavista, Lycos, Google, Voila, ecc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt14\">
	Elenco delle <b>pagine di siti esterni</b> contenenti un link che è stato seguito per accedere a questo sito (solo le <b>$MaxNbOfRefererShown</b> pagine esterne più utilizzate sono visualizzate).\n
	I link risultanti da una ricerca di un motore conosciuto non appaiono qui, dato che sono conteggiati a parte sulla linea subito sopra.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt15\">
	Questa tabella offre la lista delle <b>parole</b> più frequentemente utilizzate per rintracciare e accedere al sito a partire da
	un motore di ricerca Internet (sono riconosciute le ricerche dei <b>".(@SearchEnginesArray)."</b> motori di ricerca più popolari, come Yahoo, Altavista, Lycos, Google, Voila, ecc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt16\">
	I robots sono dei <b>visitatori automatici</b> che perlustrano il sito al fine di indicizzarlo, di ottenere delle statistiche sui siti Web Internet o di verificarne l'accessibilità.<br>
	$PROG riconosce <b>".(@RobotArray)."</b> robots.
	</DIV>";

	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt201\"> Contenuto parziale ritornato. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt202\"> La richiesta è stata registrata del server ma sarà eseguita più tardi. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt204\"> Il server ha processato la richiesta ma non esiste alcun documento da ritornare. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt206\"> Contenuto parziale ritornato. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt301\"> Il documento richiesto è stato spostato e si trova al momento a un altro indirizzo, indicato nella risposta. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt302\"> Nessuna descrizione per questo errore. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt400\"> Errore di sintassi, il server non ha compreso la richiesta. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt401\"> Tentativo di accesso non autorizzato a un <b>URL che richiede un'autenticazione con un login o una parola di accesso</b>.<br>Un numero troppo elevato può evidenziare un tentativo di accesso mediante forza bruta al sito (a seguito di accesso ripetuto con differenti nomi di login o parole di accesso).</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt403\"> Tentativo di accesso a un <b>URL non configurato per essere accessibile, anche se corretto</b> (ad esempio, un URL di una directory indicata come non \"listabile\"). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt404\"> Tentativo di accesso a una risorsa o <b>URL inesistente</b>. SI tratta dunque di un link non valido sul sito o di un errore di battitura del visitatore che ha indicato un URL non corretto. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt408\"> Il server ha impiegato un <b>tempo troppo lungo</b> per rispondere alla richiesta. Può trattarsi di uno script CGI troppo lento obbligato ad abbandonare la richiesta, o di un timeout dato dalla saturazione del sito. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt500\"> Errore interno del server. Questo errore è quello ritornato più di frequente durante la terminazione anormale di uno script CGI (per esempio in seguito a un coredump del CGI). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt501\"> Il server non prende in carico l'azione richiesta. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt502\"> Codice ritornato da un server HTTP che funziona da proxy o gateway quando il server reale chiamato non risponde alla richiesta del client. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt503\"> Errore interno del server. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt504\"> Time-out del gateway. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt505\"> Versione HTTP non supportata. </DIV>
	";
}

# Polish tooltips
if ($Lang == 6) {
	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt1\">
	Wizyty ka¿dego <b>nowego go¶cia</b>, który ogl±da³ stronê i nie ³±czy³ siê z ni± przez ostatnie <b>".($VisitTimeOut/10000*60)." mn</b>.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt2\">
	Adres numeryczny hosta klienta (<b>tzw. adres IP</b>) odwiedzaj±cego tê stronê.<br>
	Ten numer mo¿e byæ identyczny dla <B>kilku ró¿nych Internautów</B> którzy odwiedzili stronê tego samego dnia.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt3\">
	¦rednia liczba obejrzanych <B>stron</B> przypadaj±ca na jednego Internautê. (Suma go¶ci, wszystkich wizyt).<br>
	Ten licznik ró¿ni siê od kolumny z prawej, gdy¿ zlicza on tylko strony html (bez obrazków i innych plików).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt4\">
	Liczba wszystkich <b>stron, obrazków, d¼wiêków, plików</b>, które zosta³y <b>obejrzane</b> lub <b>¶ci±gniête</b> przez kogo¶.<br>
	Warto¶æ jest jedynie orientacyjna, zaleca siê spogl±daæ na licznik \"strony\".
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt5\">
	Liczba <b>kilobajtów</b> ¶ci±gniêtych przez Internautów.<br>
	Jest to suma wszystkich ¶ci±gniêtych danych <B>(strony html, obrazki, d¼wiêki)</B>.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt13\">
	$PROG rozró¿nia dostêp do stron <b>z zagranicznych wyszukiwarek</b> dziêki <b>".(@SearchEnginesArray)." najpopularniejszym przegl±darkom internetowym</b> (Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt14\">
	Lista wszystkich <b>stron spoza serwera</b> z których trafiono na ten serwer (wy¶wietlanych jest <b>$MaxNbOfRefererShown</b> stron z których najczê¶ciej siê odwo³ywano.\n
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt15\">
	Ta kolumna pokazuje listê najczê¶ciej u¿ywanych <b>s³ów kluczowych</b>, dziêki którym znaleziono t± stronê w wyszukiwarkach.
	($PROG rozró¿nia zapytania s³ów kluczowych z <b>".(@SearchEnginesArray)."</b> najpopularniejszych wyszukiwarek, takich jak Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt16\">
	Roboty s± <b>programami sieciowymi</b> skanuj±cymi strony w celu zebrania/aktualizacji danych (np. s³owa kluczowe do wyszukiwarek), lub sprawdzaj±cymi czy strona nadal istnieje w sieci.<br>
	$PROG rozró¿nia obecnie <b>".(@RobotArray)."</b> robów.
	</DIV>";

	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt201\"> Zlecenie POST zosta³o zrealizowane pomy¶lnie. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt202\"> ¯±danie zosta³o odebrane poprawnie, lecz jeszcze siê nie zakoñczy³o. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt204\"> Serwer przetworzy³ ¿±danie, lecz nie posiada ¿adnych danych do wys³ania. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt206\"> Czê¶ciowa zawarto¶æ.</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt301\"> Dokument zosta³ przeniesiony pod inny adres.</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt302\"> Dokument zosta³ czasowo przeniesiony pod iiny adres.</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt400\"> Zlecenie by³o b³êdne, lub niemo¿liwe do zrealizowania przez serwer.<BR>B³±d powstaje wtedy, kiedy serwer WWW otrzymuje do wykonania instrukcjê, której nie rozumie.</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt401\"> B³±d autoryzacji. Strona wymaga podania has³a i loginu - b³±d pokazuje siê wtedy, gdy które¶ z tych danych siê nie zgadza lub zosta³y podane niew³a¶ciwiwe.<BR>Je¶li liczba ta jest du¿a, jest to sygna³ dla webmastera, i¿ kto¶ próbuje z³amaæ has³o do strony nim zabezpieczonej.</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt403\"> B³±d wystêpuje wtedy, gdy katalog/strona do którego siê odwo³ywano nie ma ustawionych w³a¶ciwych praw dostêpu, lub prawa te nie pozwalaj± na obejrzenie zawarto¶ci katalogu/strony.</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt404\"> Spróbuj wpisaæ <b>nie istniej±cy adres URL</b> (np. adres tej strony ze skasowan± jedn± literk±). Znaczy to, ¿e posiadasz gdzie¶ na swoich stronach b³êdny link, lub link odnosz±cy siê do nieistniej±cej strony.</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt408\"> Przegl±darka nie wys³a³a ¿±dañ do serwera w czasie jego oczekiwania. Mo¿esz powtórzyæ ¿±danie bez jego modyfikacji w czasie pó¼niejszym. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt500\"> B³±d wewnêtrzny. Ten b³±d czêsto pojawia siê, gdy aplikacja CGI nie zakoñczy³a siê normalnie (podobno ka¿dy program zawiera przynajmniej jeden b³±d...:-). </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt501\"> Serwer nie umo¿liwia obs³ugi mechanizmu. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt502\"> Serwer jest chwilowo przeci±¿ony i nie mo¿e obs³u¿yæ zlecenia.</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt503\"> Serwer zdecydowa³ siê przerwaæ oczekiwanie na inny zasób lub us³ugê, i z tego powodu nie móg³ obs³u¿yæ zlecenia.</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt504\"> Serwer docelowy nie otrzyma³ odpowiedzi od serwera proxy, lub bramki.</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt505\"> Nie obs³ugiwana wesja protoko³u HTTP. </DIV>
	";
}

# Korean tooltips
if ($Lang == 10) {
	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt1\">
	»õ·Î¿î ¹æ¹®Àº ÀÌÀü¿¡(<b>\".($VisitTimeOut/10000*60).\" ºÐÀÌ³»</b>)
	´ç½ÅÀÇ »çÀÌÆ®¿¡ Á¢¼ÓÇÏÁö ¾ÊÀº(º¸°Å³ª ºê¶ó¿ìÂ¡ ÇÏÁö ¾ÊÀº) »õ·Î¿î
	<b>¹æ¹®ÀÚ</b>¸¦ ³ªÅ¸³À´Ï´Ù.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt2\">
	Å¬¶óÀÌ¾ðÆ® È£½ºÆ® ¼ö(<b>IP ÁÖ¼Ò</b>)´Â ¹æ¹®ÇÑ »çÀÌÆ® ¼ö¸¦ ³ªÅ¸³À´Ï´Ù.(ÃÖ¼ÒÇÑ <b>ÇÑ ÆäÀÌÁö</b>¶óµµ º» »çÀÌÆ®)<br>
	ÀÌ ÀÚ·á´Â ÀÏº° <b>¹°¸®ÀûÀ¸·Î ´Ù¸¥ »ç¿ëÀÚ</b>¼ö¸¦ ³ªÅ¸³À´Ï´Ù.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt3\">
	»çÀÌÆ®¿¡¼­ <b>º»(view) ÆäÀÌÁö</b> È¸¼ö¸¦ ³ªÅ¸³À´Ï´Ù.
	(¸ðµç ¹æ¹®ÀÚÀÇ ÇÔ)<br>
        ÀÌ ÀÚ·á´Â ÀÌ¹ÌÁö, ÆÄÀÏ°ú ´Þ¸® HTML ÆäÀÌÁö¿¡¼­ÀÇ \"Á¶È¸¼ö(hit)\"¿Í´Â ´Ù¸¨´Ï´Ù.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt4\">
	<b>ÆäÀÌÁö, ÀÌ¹ÌÁö, ÆÄÀÏ</b>À» <b>º¸°Å³ª ´Ù¿î·Îµå</b>ÇÑ È¸¼ö¸¦ ³ªÅ¸³À´Ï´Ù.<br>
	ÀÌ ÀÚ·á´Â ÂüÁ¶¿ëÀ¸·Î¸¸ Á¦°øµË´Ï´Ù. ¿Ö³ÄÇÏ¸é º» \"ÆäÀÌÁö\"´Â Á¾Á¾ ½ÃÀåÁ¶»ç ¸ñÀûÀ¸·Î »ç¿ëµÉ ¼ö ÀÖ±â ¶§¹®ÀÔ´Ï´Ù.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt5\">
	ÀÌ Á¤º¸µéÀº ´Ù¿î·ÎµåÇÑ ¸ðµç <b>ÆäÀÌÁö</b>, <b>ÀÌ¹ÌÁö</b>, <b>ÆÄÀÏ</b> µéÀ» Kb´ÜÀ§·Î ³ªÅ¸³À´Ï´Ù.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt13\">
	$PROG ´Â <b>".(@SearchEnginesArray)."</b>ÀÇ <b>°Ë»ö</b>À¸·Î ´ç½ÅÀÇ »çÀÌÆ®¿¡ ´ëÇÑ Á¢±ÙÀ» ½Äº°ÇÒ ¼ö ÀÖ½À´Ï´Ù.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt14\">
	´ç½ÅÀÇ »çÀÌÆ®¿¡ ¸µÅ©µÈ ¸ðµç <b>¿ÜºÎ ÆäÀÌÁö</b><br>
	(<b>$MaxNbOfRefereShown</b>´Â °¡Àå ÀÚÁÖ »ç¿ëµÇ´Â ¿ÜºÎ ÆäÀÌÁö¸¦ ³ªÅ¸³À´Ï´Ù.)
        °Ë»ö ¿£Áø¿¡ ÀÇÇÑ °á°úÆäÀÌÁö¿¡ »ç¿ëµÈ ¸µÅ©´Â ¿©±â¿¡¼­ Á¦¿ÜµË´Ï´Ù.
        (ÀÌ Å×ÀÌºíÀÇ ÀÌÀü¿¡ ÀÌ¹Ì ³ª¿Í ÀÖ½À´Ï´Ù.)
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt15\">
	ÀÌ Å×ÀÌºíÀº ´ç½ÅÀÇ »çÀÌÆ®¿¡¼­ °¡Àå ¸¹ÀÌ »ç¿ëµÇ´Â <b>Å°¿öµå</b> ¸ñ·ÏÀ» º¸¿©ÁÝ´Ï´Ù.
        (°¡Àå ¾ÖÈ£ÇÏ´Â °Ë»ö¿£Áø Yahoo, Altavista, Lycos, Google, Voilaµî°ú °°Àº
	<b>".(@SearchEnginesArray)."</b>ÀÇ Å°¿öµå¸¦ $PROG´Â ½Äº°ÇÒ ¼ö ÀÖ½À´Ï´Ù.
	</DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt16\">
	·Îº¸Æ® (¶§·Î´Â ½ºÆÄÀÌ´õ¸¦ ¶æÇÔ)´Â ¸¹Àº °Ë»ö ¿£Áø¿¡¼­ »ç¿ëµÇ´Â
	<b>ÀÚµ¿È­µÈ À¥Á¢¼Ó µµ±¸</b>ÀÔ´Ï´Ù. ÀÌ ¿£ÁøÀº (1) À¥»çÀÌÆ®¸¦ ¸ñ·ÏÈ­ÇÏ°í
	¼ø¼­¸¦ ºÎ¿©ÇÏ°í (2) ÀÎÅÍ³Ý À¥ »çÀÌÆ®ÀÇ Åë°è¸¦ ¼öÁýÇÏ°í (3) ´ç½ÅÀÇ
	»çÀÌÆ®°¡ ¿©ÀüÈ÷ »ç¿ë°¡´ÉÇÑÁö Á¶»çÇÕ´Ï´Ù.<br>
	$PROG´Â <b>".(@RobotArra)."</b> ·Îº¸Æ®¸¦ ½Äº°ÇÒ ¼ö ÀÖ½À´Ï´Ù.
	</DIV>";

	print "
	<DIV CLASS=\"CTooltip\" ID=\"tt201\"> ÀÌ ¿À·ù¿¡ ´ëÇÑ ¼³¸íÀÌ ¾ø½À´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt202\"> ¿äÃ»ÀÌ ¼­¹ö¿¡ ÀÇÇØ ´õÀÌ»ó ÁøÇàµÉ ¼ö ¾ø½À´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt204\"> ¼­¹ö°¡ ¿äÃ»À» Ã³¸®ÇßÁö¸¸ Àü¼ÛÇÒ ¹®¼­°¡ ¾ø½À´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt206\"> ÀÏºÎ ³»¿ë. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt301\"> ¿äÃ»µÈ ¹®¼­´Â ¿Å°ÜÁ®¼­ ´Ù¸¥ ÁÖ¼Ò¸¦ »ç¿ëÇÕ´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt302\"> ÀÌ ¿À·ù¿¡ ´ëÇÑ ¼³¸íÀÌ ¾ø½À´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt400\"> ±¸¹® ¿À·ù, ¼­¹ö°¡ ÀÌ ¿äÃ»À» ¾Ë ¼ö ¾ø½À´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt401\"> <b>URL¿¡ Á¢¼ÓÀ» À§ÇØ¼­´Â ·Î±×ÀÎ/ÆÐ½º¿öµå °¡ ÇÊ¿äÇÕ´Ï´Ù.</b><br>ÀÌ Ç×¸ñÀÇ ÃÖ°í°ªÀº ´©±º°¡ Å©·¢À» ½ÃµµÇÏ°Å³ª ´ç½ÅÀÇ »çÀÌÆ®¿¡ Á¢¼ÓÀ» ½ÃµµÇÏ°í ÀÖ´Â °Í(´Ù¸¥ ·Î±×ÀÎ/ÆÐ½º¿öµå¸¦ »ç¿ëÇÏ¿© ½ÃµµÇÏ´Â°Í) À» ÀÇ¹ÌÇÕ´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt403\"> <b>»ç¿ë°¡´ÉÇÏ°Ô ¼³Á¤µÇ¾î ÀÖÁö ¾Ê´Â URL</b>¿¡ ´ëÇÑ Á¢¼Ó½Ãµµ ¿À·ù ÀÔ´Ï´Ù. (¿¹¸¦ µé¾î, µð·ºÅä¸®¿¡¤Ô´ëÇÑ \"ºê¶ó¿ìÂ¡\"ÀÌ Á¤ÀÇµÇÁö ¾ÊÀº °æ¿ìÀÔ´Ï´Ù.) </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt404\"> <b>Á¸ÀçÇÏÁö ¾Ê´Â URL</b>¿¡ ´ëÇÑ Á¢¼Ó ½Ãµµ ¿À·ùÀÔ´Ï´Ù. ÀÌ ¿À·ù´Â Á¾Á¾ ´ç½ÅÀÇ »çÀÌÆ® ¾îµò°¡¿¡¼­ Àß¸øµÈ ¸µÅ©°¡ ÀÖ¾î ¹æ¹®ÀÚµéÀÌ Àß¸øµÈ URL·Î Á¢¼ÓÇÏ´Â °æ¿ì¿¡ ¹ß»ýÇÕ´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt408\"> ¼­¹ö¿¡°Ô ¿äÃ»µÈ °ÍÀÌ <b>³Ê¹« ¸¹Àº ÀÀ´ä ½Ã°£</b>À» ¿ä±¸ÇÕ´Ï´Ù.	ÀÌ ¿À·ù´Â Á¾Á¾ ´À¸° CGI ½ºÅ©¸³Æ® ¹®Á¦ÀÌ°Å³ª À¥¼­¹ö »ç¿ë·®ÀÌ ¸¹Àº °æ¿ì¿¡ ¹ß»ýÇÕ´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt500\"> ³»ºÎ ¿À·ù. ÀÌ ¿À·ù´Â Á¾Á¾ CGIÇÁ·Î±×·¥ÀÌ ºñÁ¤»óÀûÀ¸·Î Á¾·áµÇ¾úÀ» ¶§ ¹ß»ýÇÕ´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt501\"> ¿äÃ»µÈ µ¿ÀÛÀ» ¾Ë¼ö ¾ø½À´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt502\"> HTTP ¼­¹ö¿¡ ÀÇÇØ ¹Ý¼ÛµÈ ÄÚµå°¡ ÇÁ¶ô½Ã³ª °ÔÀÌÆ®¿þÀÌ·Î µ¿ÀÛÇÕ´Ï´Ù.  ´ë»ó ¼­¹ö°¡ Å¬¶óÀÌ¾ðÆ®ÀÇ ¿äÃ»¿¡ Á¤È®ÇÏ°Ô ÀÀ´äÀ» ÇÏÁö ¸øÇÕ´Ï´Ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt503\"> ³»ºÎ ¼­¹ö ¿À·ù. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt504\"> °ÔÀÌÆ®¿þÀÌ ½Ã°£ÃÊ°ú. </DIV>
	<DIV CLASS=\"CTooltip\" ID=\"tt505\"> HTTP ¹öÀüÀÌ Áö¿øÇÏÁö ¾Ê½À´Ï´Ù. </DIV>
	";
}


# Position .style.pixelLeft/.pixelHeight/.pixelWidth/.pixelTop	IE OK	Opera OK
#          .style.left/.height/.width/.top											Netscape OK
# document.getElementById										IE OK	Opera OK	Netscape OK
# document.body.offsetWidth|document.body.style.pixelWidth		IE OK	Opera OK	Netscape OK		Visible width of container
# document.body.scrollTop                                       IE OK	Opera OK	Netscape OK		Visible width of container
# tooltip.offsetWidth|tooltipOBJ.style.pixelWidth				IE OK	Opera OK	Netscape OK		Width of an object
# event.clientXY												IE OK	Opera OK	Netscape KO		Return position of mouse
print <<EOF;
<script type="text/javascript" language="javascript">
  function ShowTooltip(fArg)
  {
    var tooltipOBJ = (document.getElementById) ? document.getElementById('tt' + fArg) : eval("document.all['tt" + fArg + "']");
    var tooltipLft = (document.body.offsetWidth?document.body.offsetWidth:document.body.style.pixelWidth) - (tooltipOBJ.offsetWidth?tooltipOBJ.offsetWidth:(tooltipOBJ.style.pixelWidth?tooltipOBJ.style.pixelWidth:300)) - 30;
    if (navigator.appName != 'Netscape') {
		var tooltipTop = (document.body.scrollTop>=0?document.body.scrollTop+10:event.clientY+10);
		if ((event.clientX > tooltipLft) && (event.clientY < (tooltipOBJ.scrollHeight?tooltipOBJ.scrollHeight:tooltipOBJ.style.pixelHeight) + 10)) {
			tooltipTop = (document.body.scrollTop?document.body.scrollTop:document.body.offsetTop) + event.clientY + 20;
		}
		tooltipOBJ.style.pixelLeft = tooltipLft; tooltipOBJ.style.pixelTop = tooltipTop; 
	}
	else {
		var tooltipTop = 10;
		tooltipOBJ.style.left = tooltipLft; tooltipOBJ.style.top = tooltipTop; 
	}
    tooltipOBJ.style.visibility = "visible";
  }
  function HideTooltip(fArg)
  {
    var tooltipOBJ = (document.getElementById) ? document.getElementById('tt' + fArg) : eval("document.all['tt" + fArg + "']");
    tooltipOBJ.style.visibility = "hidden";
  }
</script>

EOF


# MENU
#---------------------------------------------------------------------
print "$CENTER<a name=\"MENU\"></a><BR>";

print "<table>";
print "<tr><td class=LEFT colspan=2><font style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">$message[7][$Lang] : <font style=\"font: 14px arial,verdana,helvetica; font-weight: normal\">$SiteToAnalyze</td></tr>";
print "<tr><td class=LEFT style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">Last update : <font style=\"font: 14px arial,verdana,helvetica; font-weight: normal\">";
foreach $key (keys %LastUpdate) { if ($LastUpdate < $LastUpdate{$key}) { $LastUpdate = $LastUpdate{$key}; } }
$yearcon=substr($LastUpdate,0,4);$monthcon=substr($LastUpdate,4,2);$daycon=substr($LastUpdate,6,2);$hourcon=substr($LastUpdate,8,2);$mincon=substr($LastUpdate,10,2);
if ($LastUpdate != 0) { print "$daycon&nbsp;$monthlib{$monthcon}&nbsp;$yearcon&nbsp;-&nbsp;$hourcon:$mincon"; }
else { print "<font color=#880000>Never updated</font>"; }
print "</font></td><td valign=center><font size=1>&nbsp;";
if ($AllowToUpdateStatsFromBrowser) { print "<a href=\"$DirCgi$PROG.$Extension?update=1&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$message[74][$Lang]</a>"; }
print "</td></tr></table>";
print "<br>\n";
print "<table>\n";
print "<tr><td class=LEFT><font style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">Traffic:</td>";
print "<td class=LEFT><a href=\"#DOMAINS\">$message[17][$Lang]</a> &nbsp; <a href=\"#VISITOR\">".ucfirst($message[26][$Lang])."</a> &nbsp; <a href=\"#ROBOTS\">$message[53][$Lang]</a> &nbsp; <a href=\"#HOUR\">$message[20][$Lang]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?action=unknownip&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$message[45][$Lang]</a><br></td></tr>\n";
print "<tr><td class=LEFT><font style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">Navigation:</td>";
print "<td class=LEFT><a href=\"#PAGE\">$message[19][$Lang]</a> &nbsp; <a href=\"#BROWSER\">$message[21][$Lang]</a> &nbsp; <a href=\"#OS\">$message[59][$Lang]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?action=browserdetail&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$message[33][$Lang]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?action=browserdetail&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$message[34][$Lang]</a><br></td></tr>\n";
print "<tr><td class=LEFT><font style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">$message[23][$Lang]</td>";
print "<td class=LEFT><a href=\"#REFERER\">$message[37][$Lang]</a> &nbsp; <a href=\"#SEARCHWORDS\">$message[24][$Lang]</a><br></td></tr>\n";
print "<tr><td class=LEFT><font style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">$message[2][$Lang]:</td>";
print "<td class=LEFT> <a href=\"#ERRORS\">$message[22][$Lang]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?action=notfounderror&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$message[31][$Lang]</a><br></td></tr>\n";
print "</table>\n";
print "<br>\n\n";


# SUMMARY
#---------------------------------------------------------------------
print "$CENTER<a name=\"SUMMARY\"></a><BR>";
$tab_titre="$message[7][$Lang] $SiteToAnalyze";
&tab_head;

# FirstTime LastTime TotalVisits
$beginmonth=$MonthRequired;$endmonth=$MonthRequired;
if ($MonthRequired eq "year") { $beginmonth=1;$endmonth=12; }
for ($monthix=$beginmonth; $monthix<=$endmonth; $monthix++) {
	$monthix=$monthix+0; if ($monthix < 10) { $monthix  = "0$monthix"; }	# Good trick to change $month into "MM" format
	if ($FirstTime{$YearRequired.$monthix} > 0 && ($FirstTime == 0 || $FirstTime > $FirstTime{$YearRequired.$monthix})) { $FirstTime = $FirstTime{$YearRequired.$monthix}; }
	if ($LastTime  < $LastTime{$YearRequired.$monthix}) { $LastTime = $LastTime{$YearRequired.$monthix}; }
	$TotalVisits+=$MonthVisits{$YearRequired.$monthix};
}
# TotalUnique TotalHosts
foreach $key (keys %_hostmachine_p) { if ($key ne "Unknown") { if ($_hostmachine_p{$key} > 0) { $TotalUnique++; }; $TotalHosts++; } }
foreach $key (keys %_unknownip_l) { $TotalUnique++; $TotalHosts++; }		# TODO: Put + @xxx instead of foreach
# TotalDifferentPages
$TotalDifferentPages=@sortsiders;
# TotalPages TotalHits TotalBytes
for ($ix=0; $ix<=23; $ix++) { $TotalPages+=$_time_p[$ix]; $TotalHits+=$_time_h[$ix]; $TotalBytes+=$_time_k[$ix]; }
# TotalDifferentKeywords
$TotalDifferentKeywords=@sortsearchwords;
# TotalKeywords
foreach $key (keys %_keywords) { $TotalKeywords+=$_keywords{$key}; }
# TotalErrors
foreach $key (keys %_errors_h) { $TotalErrors+=$_errors_h{$key}; }
# Ratio
if ($TotalUnique > 0) { $RatioHosts=int($TotalVisits/$TotalUnique*100)/100; }
if ($TotalVisits > 0) { $RatioPages=int($TotalPages/$TotalVisits*100)/100; }
if ($TotalVisits > 0) { $RatioHits=int($TotalHits/$TotalVisits*100)/100; }
if ($TotalVisits > 0) { $RatioBytes=int(($TotalBytes/1024)*100/$TotalVisits)/100; }

print "<TR><TD><b>$message[8][$Lang]</b></TD>";
if ($MonthRequired eq "year") { print "<TD colspan=3 rowspan=2><font style=\"font: 18px arial,verdana,helvetica; font-weight: bold\">$message[6][$Lang] $YearRequired</font><br>"; }
else { print "<TD colspan=3 rowspan=2><font style=\"font: 18px arial,verdana,helvetica; font-weight: bold\">$message[5][$Lang] $monthlib{$MonthRequired} $YearRequired</font><br>"; }
# Show links for possible years
foreach $key (keys %listofyears) {
	print "<a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$key&month=year&lang=$Lang\">$message[6][$Lang] $key</a> ";
}
print "</TD>";
print "<TD><b>$message[9][$Lang]</b></TD></TR>";

$yearcon=substr($FirstTime,0,4);$monthcon=substr($FirstTime,4,2);$daycon=substr($FirstTime,6,2);$hourcon=substr($FirstTime,8,2);$mincon=substr($FirstTime,10,2);
if ($FirstTime != 0) { print "<TR><TD>$daycon&nbsp;$monthlib{$monthcon}&nbsp;$yearcon&nbsp;-&nbsp;$hourcon:$mincon</TD>"; }
else { print "<TR><TD>NA</TD>"; }
$yearcon=substr($LastTime,0,4);$monthcon=substr($LastTime,4,2);$daycon=substr($LastTime,6,2);$hourcon=substr($LastTime,8,2);$mincon=substr($LastTime,10,2);
if ($LastTime != 0) { print "<TD>$daycon&nbsp;$monthlib{$monthcon}&nbsp;$yearcon&nbsp;-&nbsp;$hourcon:$mincon</TD></TR>"; }
else { print "<TD>NA</TD></TR>\n"; }
print "<TR>";
print "<TD width=20% bgcolor=#$color_v onmouseover=\"ShowTooltip(1);\" onmouseout=\"HideTooltip(1);\">$message[10][$Lang]</TD>";
print "<TD width=20% bgcolor=#$color_w onmouseover=\"ShowTooltip(2);\" onmouseout=\"HideTooltip(2);\">$message[11][$Lang]</TD>";
print "<TD width=20% bgcolor=#$color_p onmouseover=\"ShowTooltip(3);\" onmouseout=\"HideTooltip(3);\">$message[56][$Lang]</TD>";
print "<TD width=20% bgcolor=#$color_h onmouseover=\"ShowTooltip(4);\" onmouseout=\"HideTooltip(4);\">$message[57][$Lang]</TD>";
print "<TD width=20% bgcolor=#$color_k onmouseover=\"ShowTooltip(5);\" onmouseout=\"HideTooltip(5);\">$message[44][$Lang]</TD></TR>";
$kilo=int($TotalBytes/1024*100)/100;
print "<TR><TD><b>$TotalVisits</b><br>&nbsp;</TD><TD><b>$TotalUnique</b><br>($RatioHosts&nbsp;$message[52][$Lang])</TD><TD><b>$TotalPages</b><br>($RatioPages&nbsp;".lc $message[56][$Lang]."/".lc $message[12][$Lang].")</TD>";
print "<TD><b>$TotalHits</b><br>($RatioHits&nbsp;".lc $message[57][$Lang]."/".lc $message[12][$Lang].")</TD><TD><b>$kilo $message[44][$Lang]</b><br>($RatioBytes&nbsp;$message[44][$Lang]/".lc $message[12][$Lang].")</TD></TR>\n";
print "<TR valign=bottom><TD colspan=5>";
print "<TABLE>";
print "<TR valign=bottom>";
$max_v=1;$max_p=1;$max_h=1;$max_k=1;
for ($ix=1; $ix<=12; $ix++) {
	$monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
	if ($MonthVisits{$YearRequired.$monthix} > $max_v) { $max_v=$MonthVisits{$YearRequired.$monthix}; }
	if ($MonthUnique{$YearRequired.$monthix} > $max_v) { $max_v=$MonthUnique{$YearRequired.$monthix}; }
	if ($MonthPage{$YearRequired.$monthix} > $max_p)   { $max_p=$MonthPage{$YearRequired.$monthix}; }
	if ($MonthHits{$YearRequired.$monthix} > $max_h)   { $max_h=$MonthHits{$YearRequired.$monthix}; }
	if ($MonthBytes{$YearRequired.$monthix} > $max_k)  { $max_k=$MonthBytes{$YearRequired.$monthix}; }
}

for ($ix=1; $ix<=12; $ix++) {
	$monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
	$bredde_v=$MonthVisits{$YearRequired.$monthix}/$max_v*$BarHeight/2;
	$bredde_u=$MonthUnique{$YearRequired.$monthix}/$max_v*$BarHeight/2;
	$bredde_p=$MonthPage{$YearRequired.$monthix}/$max_h*$BarHeight/2;
	$bredde_h=$MonthHits{$YearRequired.$monthix}/$max_h*$BarHeight/2;
	$bredde_k=$MonthBytes{$YearRequired.$monthix}/$max_k*$BarHeight/2;
	$kilo=int(($MonthBytes{$YearRequired.$monthix}/1024)*100)/100;
	print "<TD>";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=8 ALT=\"$message[10][$Lang]: $MonthVisits{$YearRequired.$monthix}\" title=\"$message[10][$Lang]: $MonthVisits{$YearRequired.$monthix}\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_u\" HEIGHT=$bredde_u WIDTH=8 ALT=\"$message[11][$Lang]: $MonthUnique{$YearRequired.$monthix}\" title=\"$message[11][$Lang]: $MonthUnique{$YearRequired.$monthix}\">";
	print "&nbsp;";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=8 ALT=\"$message[56][$Lang]: $MonthPage{$YearRequired.$monthix}\" title=\"$message[56][$Lang]: $MonthPage{$YearRequired.$monthix}\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=8 ALT=\"$message[57][$Lang]: $MonthHits{$YearRequired.$monthix}\" title=\"$message[57][$Lang]: $MonthHits{$YearRequired.$monthix}\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=8 ALT=\"$message[44][$Lang]: $kilo\" title=\"$message[44][$Lang]: $kilo\">";
	print "</TD>\n";
}

print "</TR><TR>";
for ($ix=1; $ix<=12; $ix++) {
	$monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
	print "<TD valign=center><a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$monthix&lang=$Lang\">$monthlib{$monthix}</a></TD>";
}

print "</TR></TABLE>";
print "</TD></TR>";
&tab_end;

print "<br><hr>\n";

# BY COUNTRY/DOMAIN
#---------------------------
print "$CENTER<a name=\"DOMAINS\"></a><BR>";
$tab_titre="$message[25][$Lang]";
&tab_head;
print "<TR bgcolor=#$color_TableBGRowTitle><TH colspan=2>$message[17][$Lang]</TH><TH>Code</TH><TH bgcolor=#$color_p>$message[56][$Lang]</TH><TH bgcolor=#$color_h>$message[57][$Lang]</TH><TH bgcolor=#$color_k>$message[44][$Lang]</TH><TH>&nbsp;</TH></TR>\n";
if ($SortDir<0) { $max_h=$_domener_h{$sortdomains_h[0]}; }
else            { $max_h=$_domener_h{$sortdomains_h[$#sortdomains_h]}; }
if ($SortDir<0) { $max_k=$_domener_k{$sortdomains_k[0]}; }
else            { $max_k=$_domener_k{$sortdomains_k[$#sortdomains_k]}; }
$count=0;$total_p=0;$total_h=0;$total_k=0;
foreach $key (@sortdomains_p) {
	if ($max_h > 0) { $bredde_p=$BarWidth*$_domener_p{$key}/$max_h+1; }	# use max_h to enable to compare pages with hits
	if ($max_h > 0) { $bredde_h=$BarWidth*$_domener_h{$key}/$max_h+1; }
	if ($max_k > 0) { $bredde_k=$BarWidth*$_domener_k{$key}/$max_k+1; }
	$kilo=int(($_domener_k{$key}/1024)*100)/100;
	if ($key eq "ip") {
		print "<TR><TD><IMG SRC=\"$DirIcons\/flags\/$key.png\" height=14></TD><TD CLASS=LEFT>$message[0][$Lang]</TD><TD>$key</TD>";
	}
	else {
		print "<TR><TD><IMG SRC=\"$DirIcons\/flags\/$key.png\" height=14></TD><TD CLASS=LEFT>$DomainsHash{$key}</TD><TD>$key</TD>";
	}
	print "<TD>$_domener_p{$key}</TD><TD>$_domener_h{$key}</TD><TD>$kilo</TD>";
	print "<TD CLASS=LEFT>";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$message[56][$Lang]: $_domener_p{$key}\" title=\"$message[56][$Lang]: $_domener_p{$key}\"><br>\n";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 ALT=\"$message[57][$Lang]: $_domener_h{$key}\" title=\"$message[57][$Lang]: $_domener_h{$key}\"><br>\n";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$message[44][$Lang]: $kilo\" title=\"$message[44][$Lang]: $kilo\">";
	print "</TD></TR>\n";
	$total_p += $_domener_p{$key};
	$total_h += $_domener_h{$key};
	$total_k += $_domener_k{$key};
	$count++;
	if ($count >= $MaxNbOfDomain) { last; }
}
$rest_p=$TotalPages-$total_p;
$rest_h=$TotalHits-$total_h;
$rest_k=int((($TotalBytes-$total_k)/1024)*100)/100;
if ($rest_p > 0) { 	# All other domains (known or not)
	print "<TR><TD colspan=3 CLASS=LEFT><font color=blue>$message[2][$Lang]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>$rest_k</TD>\n";
	print "<TD CLASS=LEFT>";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$message[56][$Lang]: $_rest_p\" title=\"$message[56][$Lang]: $_rest_p\"><br>\n";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 ALT=\"$message[57][$Lang]: $_rest_h\" title=\"$message[57][$Lang]: $_rest_h\"><br>\n";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$message[44][$Lang]: $_rest_k\" title=\"$message[44][$Lang]: $_rest_k\">";
	print "</TD></TR>\n";
	}
&tab_end;


# BY HOST/VISITOR
#--------------------------
print "$CENTER<a name=\"VISITOR\"></a><BR>";
$tab_titre="TOP $MaxNbOfHostsShown $message[55][$Lang] $TotalHosts $message[26][$Lang] ($TotalUnique $message[11][$Lang])";
&tab_head;
print "<TR bgcolor=#$color_TableBGRowTitle><TH>$message[18][$Lang]</TH><TH bgcolor=#$color_p>$message[56][$Lang]</TH><TH bgcolor=#$color_h>$message[57][$Lang]</TH><TH bgcolor=#$color_k>$message[44][$Lang]</TH><TH>$message[9][$Lang]</TH></TR>\n";
$count=0;$total_p=0;$total_h=0;$total_k=0;
foreach $key (@sorthosts_p)
{
	if ($_hostmachine_h{$key}>=$MinHitHost) {
		$kilo=int(($_hostmachine_k{$key}/1024)*100)/100;
		if ($key eq "Unknown") {
			print "<TR><TD CLASS=LEFT><a href=\"$DirCgi$PROG.$Extension?action=unknownip&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$message[1][$Lang]</a></TD><TD>$_hostmachine_p{$key}</TD><TD>$_hostmachine_h{$key}</TD><TD>$kilo</TD><TD><a href=\"$DirCgi$PROG.$Extension?action=unknownip&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$message[3][$Lang]</a></TD></TR>\n";
			}
		else {
			$yearcon=substr($_hostmachine_l{$key},0,4);
			$monthcon=substr($_hostmachine_l{$key},4,2);
			$daycon=substr($_hostmachine_l{$key},6,2);
			$hourcon=substr($_hostmachine_l{$key},8,2);
			$mincon=substr($_hostmachine_l{$key},10,2);
			print "<tr><td CLASS=LEFT>$key</td><TD>$_hostmachine_p{$key}</TD><TD>$_hostmachine_h{$key}</TD><TD>$kilo</TD>";
			if ($daycon ne "") {
				if ($Lang != 0) { print "<td>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
				else { print "<td>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
			}
			else {
				print "<td>-</td>";
			}
		}
		$total_p += $_hostmachine_p{$key};
		$total_h += $_hostmachine_h{$key};
		$total_k += $_hostmachine_k{$key};
	}
	$count++;
	if (!(($SortDir<0 && $count<$MaxNbOfHostsShown) || ($SortDir>0 && $#sorthosts_p-$MaxNbOfHostsShown < $count))) { last; }
}
$rest_p=$TotalPages-$total_p;
$rest_h=$TotalHits-$total_h;
$rest_k=int((($TotalBytes-$total_k)/1024)*100)/100;
if ($rest_p > 0) { print "<TR><TD CLASS=LEFT><font color=blue>$message[2][$Lang]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>$rest_k</TD><TD>&nbsp;</TD></TR>\n"; }	# All other visitors (known or not)
&tab_end;


# BY ROBOTS
#----------------------------
print "$CENTER<a name=\"ROBOTS\"></a><BR>";
$tab_titre=$message[53][$Lang];
&tab_head;
print "<TR bgcolor=#$color_TableBGRowTitle onmouseover=\"ShowTooltip(16);\" onmouseout=\"HideTooltip(16);\"><TH>Robot</TH><TH bgcolor=#$color_h width=80>$message[57][$Lang]</TH><TH>$message[9][$Lang]</TH></TR>\n";
@sortrobot=sort { $SortDir*$_robot_h{$a} <=> $SortDir*$_robot_h{$b} } keys (%_robot_h);
foreach $key (@sortrobot) {
	$yearcon=substr($_robot_l{$key},0,4);
	$monthcon=substr($_robot_l{$key},4,2);
	$daycon=substr($_robot_l{$key},6,2);
	$hourcon=substr($_robot_l{$key},8,2);
	$mincon=substr($_robot_l{$key},10,2);
	if ($Lang != 0) { print "<tr><td CLASS=LEFT>$RobotHash{$key}</td><td>$_robot_h{$key}</td><td>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
	else { print "<tr><td CLASS=LEFT>$RobotHash{$key}</td><td>$_robot_h{$key}</td><td>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
}
&tab_end;


# BY HOUR
#----------------------------
print "$CENTER<a name=\"HOUR\"></a><BR>";
$tab_titre="$message[20][$Lang]";
&tab_head;
print "<TR><TD><TABLE><TR>\n";
$max_p=0;$max_h=0;$max_k=0;
for ($ix=0; $ix<=23; $ix++) {
  print "<TH width=16>$ix</TH>";
  if ($_time_p[$ix]>$max_p) { $max_p=$_time_p[$ix]; }
  if ($_time_h[$ix]>$max_h) { $max_h=$_time_h[$ix]; }
  if ($_time_k[$ix]>$max_k) { $max_k=$_time_k[$ix]; }
}
print "</TR>\n";
print "<TR>\n";
for ($ix=1; $ix<=24; $ix++) {
	$hr=$ix; if ($hr>12) { $hr=$hr-12; }
	print "<TH><IMG SRC=\"$DirIcons\/clock\/hr$hr.png\" width=10></TH>";
}
print "</TR>\n";
print "\n<TR VALIGN=BOTTOM>\n";
for ($ix=0; $ix<=23; $ix++) {
	$bredde_p=0;$bredde_h=0;$bredde_k=0;
	if ($max_h > 0) { $bredde_p=($BarHeight*$_time_p[$ix]/$max_h)+1; }
	if ($max_h > 0) { $bredde_h=($BarHeight*$_time_h[$ix]/$max_h)+1; }
	if ($max_k > 0) { $bredde_k=($BarHeight*$_time_k[$ix]/$max_k)+1; }
	$kilo=int(($_time_k[$ix]/1024)*100)/100;
	print "<TD>";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=6 ALT=\"$message[56][$Lang]: $_time_p[$ix]\" title=\"$message[56][$Lang]: $_time_p[$ix]\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=6 ALT=\"$message[57][$Lang]: $_time_h[$ix]\" title=\"$message[57][$Lang]: $_time_h[$ix]\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=6 ALT=\"$message[44][$Lang]: $kilo\" title=\"$message[44][$Lang]: $kilo\">";
	print "</TD>\n";
}
print "</TR></TABLE></TD></TR>\n";
&tab_end;


# BY PAGE
#-------------------------
print "$CENTER<a name=\"PAGE\"></a><BR>";
$tab_titre="TOP $MaxNbOfPageShown $message[55][$Lang] $TotalDifferentPages $message[27][$Lang]";
&tab_head;
print "<TR bgcolor=#$color_TableBGRowTitle><TH>Page-URL</TH><TH bgcolor=#$color_p>&nbsp;$message[29][$Lang]&nbsp;</TH><TH>&nbsp;</TH></TR>\n";
if ($SortDir<0) { $max=$_sider_p{$sortsiders[0]}; }
else            { $max=$_sider_p{$sortsiders[$#sortsiders]}; }
$count=0;
foreach $key (@sortsiders) {
	if ((($SortDir<0 && $count<$MaxNbOfPageShown) || ($SortDir>0 && $#sortsiders-$MaxNbOfPageShown<$count)) && $_sider_p{$key}>=$MinHitFile) {
    	print "<TR><TD CLASS=LEFT>";
		$nompage=$Aliases{$key};
		if ($nompage eq "") { $nompage=$key; }
		$nompage=substr($nompage,0,$MaxLengthOfURL);
	    if ($ShowLinksOnUrl) { print "<A HREF=\"http://$SiteToAnalyze$key\">$nompage</A>"; }
	    else              	 { print "$nompage"; }
	    $bredde=$BarWidth*$_sider_p{$key}/$max+1;
		print "</TD><TD>$_sider_p{$key}</TD><TD CLASS=LEFT><IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde HEIGHT=8 ALT=\"$message[56][$Lang]: $_sider_p{$key}\" title=\"$message[56][$Lang]: $_sider_p{$key}\"></TD></TR>\n";
  	}
  	$count++;
}
&tab_end;


# BY BROWSER
#----------------------------
print "$CENTER<a name=\"BROWSER\"></a><BR>";
$tab_titre="$message[21][$Lang]";
&tab_head;
print "<TR bgcolor=#$color_TableBGRowTitle><TH>Browser</TH><TH bgcolor=#$color_h width=40>$message[57][$Lang]</TH><TH bgcolor=#$color_h width=40>$message[15][$Lang]</TH></TR>\n";
foreach $key (@sortbrowsers) {
	$p=int($_browser_h{$key}/$TotalHits*1000)/10;
	if ($key eq "Unknown") {
		print "<TR><TD CLASS=LEFT><a href=\"$DirCgi$PROG.$Extension?action=unknownrefererbrowser&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$message[0][$Lang]</a></TD><TD>$_browser_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
	}
	else {
		print "<TR><TD CLASS=LEFT>$BrowsersHash{$key}</TD><TD>$_browser_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
	}
}
&tab_end;


# BY OS
#----------------------------
print "$CENTER<a name=\"OS\"></a><BR>";
$tab_titre=$message[59][$Lang];
&tab_head;
print "<TR bgcolor=#$color_TableBGRowTitle><TH colspan=2>OS</TH><TH bgcolor=#$color_h width=40>$message[57][$Lang]</TH><TH bgcolor=#$color_h width=40>$message[15][$Lang]</TH></TR>\n";
foreach $key (@sortos) {
	$p=int($_os_h{$key}/$TotalHits*1000)/10;
	if ($key eq "Unknown") {
		print "<TR><TD><IMG SRC=\"$DirIcons\/os\/unknown.png\"></TD><TD CLASS=LEFT><a href=\"$DirCgi$PROG.$Extension?action=unknownreferer&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$message[0][$Lang]</a></TD><TD>$_os_h{$key}&nbsp;</TD>";
		print "<TD>$p&nbsp;%</TD></TR>\n";
		}
	else {
		$nameicon = $OSHash{$key}; $nameicon =~ s/\ .*//; $nameicon =~ tr/A-Z/a-z/;
		print "<TR><TD><IMG SRC=\"$DirIcons\/os\/$nameicon.png\"></TD><TD CLASS=LEFT>$OSHash{$key}</TD><TD>$_os_h{$key}</TD>";
		print "<TD>$p&nbsp;%</TD></TR>\n";
	}
}
&tab_end;


# BY REFERENCE
#---------------------------
print "$CENTER<a name=\"REFERER\"></a><BR>";
$tab_titre="$message[36][$Lang]";
&tab_head;
print "<TR bgcolor=#$color_TableBGRowTitle><TH>$message[37][$Lang]</TH><TH bgcolor=#$color_h width=40>$message[57][$Lang]</TH><TH bgcolor=#$color_h width=40>$message[15][$Lang]</TH></TR>\n";
if ($TotalHits > 0) { $_=int($_from_h[0]/$TotalHits*1000)/10; }
print "<TR><TD CLASS=LEFT><b>$message[38][$Lang]:</b></TD><TD>$_from_h[0]&nbsp;</TD><TD>$_&nbsp;%</TD></TR>\n";
if ($TotalHits > 0) { $_=int($_from_h[1]/$TotalHits*1000)/10; }
print "<TR><TD CLASS=LEFT><b>$message[39][$Lang]:</b></TD><TD>$_from_h[1]&nbsp;</TD><TD>$_&nbsp;%</TD></TR>\n";
#------- Referrals by search engine
if ($TotalHits > 0) { $_=int($_from_h[2]/$TotalHits*1000)/10; }
print "<TR onmouseover=\"ShowTooltip(13);\" onmouseout=\"HideTooltip(13);\"><TD CLASS=LEFT><b>$message[40][$Lang] :</b><br>\n";
print "<TABLE>\n";
foreach $se (@sortsereferrals) {
	print "<TR><TD CLASS=LEFT>- $SearchEnginesHash{$se} </TD><TD align=right>$_se_referrals_h{\"$se\"}</TD></TR>\n";
}
print "</TABLE></TD>\n";
print "<TD valign=top>$_from_h[2]&nbsp;</TD><TD valign=top>$_&nbsp;%</TD>\n</TR>\n";
#------- Referrals by external HTML link
if ($TotalHits > 0) { $_=(int($_from_h[3]/$TotalHits*1000)/10); }
print "<TR onmouseover=\"ShowTooltip(14);\" onmouseout=\"HideTooltip(14);\"><TD CLASS=LEFT><b>$message[41][$Lang] :</b><br>\n";
print "<TABLE>\n";
$count=0;
foreach $from (@sortpagerefs) {
	if (!(($SortDir<0 && $count<$MaxNbOfRefererShown) || ($SortDir>0 && $#sortpagerefs-$MaxNbOfRefererShown < $count))) { last; }
	if ($_pagesrefs_h{$from}>=$MinHitRefer) {

		# Show source
		$lien=$from; $lien=substr($lien,0,$MaxLengthOfURL);
		if ($ShowLinksOnUrl && ($from =~ /^http(s|):\/\//)) {
			print "<TR><TD CLASS=LEFT>- <A HREF=\"$from\">$lien</A></TD><TD>$_pagesrefs_h{$from}</TD></TR>\n";
		} else {
			print "<TR><TD CLASS=LEFT>- $lien</TD><TD>$_pagesrefs_h{$from}</TD></TR>\n";
		}

		$count++;
	}
}
print "</TABLE></TD>\n";
print "<TD valign=top>$_from_h[3]&nbsp;</TD><TD valign=top>$_&nbsp;%</TD>\n</TR>\n";

if ($TotalHits > 0) { $_=(int($_from_h[4]/$TotalHits*1000)/10); }
print "<TR><TD CLASS=LEFT><b>$message[42][$Lang] :</b></TD><TD>$_from_h[4]&nbsp;</TD><TD>$_&nbsp;%</TD></TR>\n";
&tab_end;


# BY SEARCHWORDS
#----------------------------
print "$CENTER<a name=\"SEARCHWORDS\"></a><BR>";
$tab_titre="TOP $MaxNbOfKeywordsShown $message[55][$Lang] $TotalDifferentKeywords $message[43][$Lang]";
&tab_head;
print "<TR bgcolor=#$color_TableBGRowTitle onmouseover=\"ShowTooltip(15);\" onmouseout=\"HideTooltip(15);\"><TH>$message[13][$Lang]</TH><TH bgcolor=#$color_s width=40>$message[14][$Lang]</TH><TH bgcolor=#$color_s width=40>$message[15][$Lang]</TH></TR>\n";
$count=0;
foreach $key (@sortsearchwords) {
	if ( $count>=$MaxNbOfKeywordsShown ) { last; }
	$p=int($_keywords{$key}/$TotalKeywords*1000)/10;
	$mot = $key; $mot =~ s/\+/ /g;	# Showing $key without +
	print "<TR><TD CLASS=LEFT>$mot</TD><TD>$_keywords{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
	$count++;
}
$count=0;$rest=0;
foreach $key (@sortsearchwords) {
	if ( $count<$MaxNbOfKeywordsShown ) { $count++; next; }
	$rest=$rest+$_keywords{$key};
}
if ($rest >0) {
	if ($TotalKeywords > 0) { $p=int($rest/$TotalKeywords*1000)/10; }
	print "<TR><TD CLASS=LEFT><font color=blue>$message[30][$Lang]</TD><TD>$rest</TD>";
	print "<TD>$p&nbsp;%</TD></TR>\n";
	}
&tab_end;


# BY ERRORS
#----------------------------
print "$CENTER<a name=\"ERRORS\"></a><BR>";
$tab_titre=$message[32][$Lang];
&tab_head;
print "<TR bgcolor=#$color_TableBGRowTitle><TH colspan=2>$message[32][$Lang]</TH><TH bgcolor=#$color_h width=40>$message[57][$Lang]</TH><TH bgcolor=#$color_h width=40>$message[15][$Lang]</TH></TR>\n";
foreach $key (@sorterrors) {
	$p=int($_errors_h{$key}/$TotalErrors*1000)/10;
	if ($httpcode{$key}) { print "<TR onmouseover=\"ShowTooltip($key);\" onmouseout=\"HideTooltip($key);\">"; }
	else { print "<TR>"; }
	if ($key == 404) { print "<TD><a href=\"$DirCgi$PROG.$Extension?action=notfounderror&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$key</a></TD>"; }
	else { print "<TD>$key</TD>"; }
	if ($httpcode{$key}) { print "<TD CLASS=LEFT>$httpcode{$key}</TD><TD>$_errors_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n"; }
	else { print "<TD CLASS=LEFT>Unknown error</TD><TD>$_errors_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n"; }
}
&tab_end;

&html_end;

0;	# Do not remove this line

#!/usr/bin/perl
# With some other Unix Os, first line may be
#!/usr/local/bin/perl
# With Apache for Windows and ActiverPerl, first line may be
#!c:/program files/activeperl/bin/perl
#-Description-------------------------------------------
# Free realtime web server logfile analyzer (Perl script) to show advanced web
# statistics. Works from command line or as a CGI.
# You must use this script as often as necessary from your scheduler to update
# your statistics.
# See README.TXT file for setup and benchmark informations.
# See COPYING.TXT file about AWStats GNU General Public License.
#-------------------------------------------------------
# ALGORITHM SUMMARY
# Read config file
# Init variables
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
#use diagnostics;
#use strict;


#-------------------------------------------------------
# Defines
#-------------------------------------------------------

# ---------- Init variables (Variable $TmpHashxxx are not initialized) --------
($ArchiveFileName, $ArchiveLogRecords, $BarHeight, $BarWidth,
$DIR, $DNSLookup, $Debug, $DefaultFile, $DirCgi, $DirData,
$DirIcons, $Extension, $FileConfig, $FileSuffix, $FirstTime,
$HTMLEndSection, $Host, $HostAlias, $LastTime, $LastUpdate,
$LogFile, $LogFormat, $LogFormatString, $Logo, $MaxNbOfDays, $MaxNbOfHostsShown, $MaxNbOfKeywordsShown,
$MaxNbOfPageShown, $MaxNbOfRefererShown, $MaxNbOfRobotShown, $MinHitFile,
$MinHitHost, $MinHitKeyword, $MinHitRefer, $MinHitRobot, $MonthRequired,
$NoHTMLOutput, $PROG, $PageBool, $PageCode,
$PurgeLogFile, $QueryString, $RatioBytes, $RatioHits, $RatioHosts, $RatioPages,
$ShowFlagLinks, $ShowLinksOnURL, $ShowLinksOnUrl, $ShowSteps,
$SiteToAnalyze, $SiteToAnalyzeWithoutwww,
$TotalBytes, $TotalDifferentPages, $TotalErrors, $TotalHits,
$TotalHostsKnown, $TotalHostsUnKnown, $TotalKeywords, $TotalPages, $TotalUnique, $TotalVisits,
$URLFilter, $UserAgent, $WarningMessages, $YearRequired, 
$color_Background, $color_TableBG, $color_TableBGRowTitle,
$color_TableBGTitle, $color_TableBorder, $color_TableRowTitle, $color_TableTitle,
$color_h, $color_k, $color_link, $color_p, $color_s, $color_v, $color_w, $color_weekend,
$found, $internal_link, $monthtoprocess, $new,
$tab_titre, $total_h, $total_k, $total_p, $yearmonth, $yeartoprocess) = ();
# ---------- Init arrays --------
@HostAliases = @OnlyFiles = @SkipDNSLookupFor = @SkipFiles = @SkipHosts =
@dateparts = @felter = @field = @filearray = @Message =
@paramlist = @refurl = @wordlist = ();
# ---------- Init hash arrays --------
%DayBytes = %DayHits = %DayPages = %DayUnique = %DayVisits =
%FirstTime = %HistoryFileAlreadyRead = %LastTime = %LastUpdate =
%MonthBytes = %MonthHits = %MonthHostsKnown = %MonthHostsUnknown = %MonthPages = %MonthUnique = %MonthVisits =
%listofyears = %monthlib = %monthnum = ();

$VERSION="3.1 (build 10)";
$Lang="en";
$Sort="";

# Default value
$SortDir       = -1;		# -1 = Sort order from most to less, 1 = reverse order (Default = -1)
$VisitTimeOut  = 10000;		# Laps of time to consider a page load as a new visit. 10000 = one hour (Default = 10000)
$FullHostName  = 1;			# 1 = Use name.domain.zone to refer host clients, 0 = all hosts in same domain.zone are one host (Default = 1, 0 never tested)
$MaxLengthOfURL= 70;		# Maximum length of URL shown on stats page. This affects only URL visible text, link still work (Default = 70)
$MaxNbOfDays   = 31;
$NbOfLinesForBenchmark=5000;
#$NbOfLinesForCorruptedLog=10;
$NbOfLinesForCorruptedLog=10000;	# ETF1
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
			"\\.gif","\\.jpg","\\.jpeg","\\.png","\\.bmp",
#			"\\.zip","\\.arj","\\.gz","\\.z",
#			"\\.pdf","\\.doc","\\.ppt","\\.rtf","\\.txt",
#			"\\.mp3","\\.wma"
			);

# Those addresses are shown with those lib (First column is full exact relative URL, second column is text to show instead of URL)
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
# To add a search engine, add a new line:
# "match_string_in_url_that_identify_engine", "search_engine_name",
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
"www\.search\.com","Search.com",
"kvasir\.","Kvasir",
# Others
"hotbot\.","Hotbot",
"webcrawler\.","WebCrawler",
"metacrawler\.","MetaCrawler (Metamoteur)",
"go2net\.com","Go2Net (Metamoteur)",
"go\.com","Go.com",
"goto\.com","Goto.com",
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
"wisenut\.com","WISENut",
"engine\.exe","Cade", "miner\.bol\.com\.br","Meta Miner",		# Minor brazilian search engines
"opasia\.dk","Opasia", "danielsen\.com","Thor (danielsen.com)",	# Minor danish search-engines 
"ilse\.","Ilse","vindex\.","Vindex\.nl",						# Minor dutch search engines
"splut\.","Splut", "ukplus\.", "UKPlus", "mirago\.", "Mirago", "ukindex\.co\.uk", "UKIndex", "ukdirectory\.","UK Directory", # Minor english search engines
"nomade\.fr/","Nomade", "ctrouve\.","C'est trouvé", "francite\.","Francité", "\.lbb\.org", "LBB", "rechercher\.libertysurf\.fr", "Libertysurf",	# Minor french search engines
"fireball\.de","Fireball", "infoseek\.de","Infoseek", "suche\.web\.de","Web.de", "meta\.ger","MetaGer",	# Minor german search engines
"virgilio\.it","Virgilio",										# Minor italian search engines
"sok\.start\.no","start.no",									# Minor norvegian search engines
"evreka\.passagen\.se","Evreka",								# Minor swedish search engines
"search\..*com","Other search engines"
);

# Search engines known URLs rules to find keywords (update the 10th january 2001)
%SearchEnginesKnownUrl=(
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
"www\.search\.com","q=",
"kvasir\.", "q=",
# Others
"askjeeves\.","ask=",
"hotbot\.","mt=",
"metacrawler\.","general=",
"go2net\.com","general=",
"go\.com","qt=",
"euroseek\.","query=",
"excite\.","search=",
"spray\.","string=",
"nbci\.com/search","keyword=",
"mamma\.","query=",
"search\.dogpile\.com", "q=",
"wisenut\.com","query=",
"virgilio\.it","qs=",
"webcrawler","searchText=",
"engine\.exe","p1=", "miner\.bol\.com\.br","q=",				# Minor brazilian search engines
"opasia\.dk","q=", "danielsen\.com","q=", 						# Minor danish search engines
"ilse\.","search_for=", "vindex\.","in=",						# Minor dutch search engines
"splut\.","pattern=", "ukplus\.", "search=", "mirago\.", "txtSearch=",		# Minor english search engines
"ukindex\.co\.uk", "stext=", "ukdirectory\.","k=", 							# Minor english search engines
"nomade\.fr/","s=", "francite\.","name=",									# Minor french search engines
"fireball\.de","q=", "infoseek\.de","qt=", "suche\.web\.de","su=",			# Minor german search engines
"sok\.start\.no", "q=",											# Minor norvegian search engines
"evreka\.passagen\.se","q="										# Minor swedish search engines
);
# If no rules are known, this will be used to clean URL of not keyword parameters.
@WordsToCleanSearchUrl= ("act=","annuaire=","btng=","categoria=","cfg=","cou=","cp=","dd=","domain=","dt=","dw=","exec=","geo=","hc=","height=","hl=","hq=","hs=","id=","kl=","lang=","loc=","lr=","matchmode=","medor=","message=","meta=","mode=","order=","page=","par=","pays=","pg=","pos=","prg=","qc=","refer=","sa=","safe=","sc=","sort=","src=","start=","stype=","sum=","tag=","temp=","theme=","url=","user=","width=","what=","\\.x=","\\.y=","y=","look=");
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
"go!zilla","Go!Zilla",
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
"msfrontpageexpress","MS FrontPage Express",
"omniweb","OmniWeb",
"teleport","TelePort Pro (Site grabber)",
"tzgeturl","TZGETURL",
"viking","Viking",
"webcapture","Acrobat (Site grabber)",
"webfetcher","WebFetcher",
"webexplorer","IBM-WebExplorer",
"webmirror","WebMirror",
"webvcr","WebVCR",
"libwww","LibWWW",				# Must be at end because some browser have both "browser id" and "libwww"
# Music only browsers
"real","RealAudio or compatible player",
"winamp","WinAmp",				# Works for winampmpeg and winamp3httprdr
"windows-media-player","Windows Media Player",
"audion","Audion",
"freeamp","FreeAmp",
"itunes","Apple iTunes",
"jetaudio","JetAudio",
"mint_audio","Mint Audio",
"mpg123","mpg123",
"nsplayer","NetShow Player",
"sonique","Sonique",
"uplayer","Ultra Player",
"xmms","XMMS",
"xaudio","Some XAudio Engine based MPEG player",
# Other kind of browsers
"webzip","WebZIP",
# PDA/Phonecell browsers
"mmef","Microsoft Mobile Explorer (PDA/Phone browser)",
"mspie","MS Pocket Internet Explorer (PDA/Phone browser)",
"up\.","UP.Browser (PDA/Phone browser)",					# Works for UP.Browser and UP.Link
"wapalizer","WAPalizer (PDA/Phone browser)",
"wapsilon","WAPsilon (PDA/Phone browser)",
"webcollage","WebCollage (PDA/Phone browser)",
"alcatel","Alcatel Browser (PDA/Phone browser)",
"nokia","Nokia Browser (PDA/Phone browser)",
# Others (TV)
"webtv","WebTV browser"
);

# OS lists ("os detector in lower case","os text")
%OSHash      = (
# Windows family OS
"winme","Windows Me",
"win2000","Windows 2000",
"winnt","Windows NT",
"win98","Windows 98",
"win95","Windows 95",
"win16","Windows 3.xx",
"wince","Windows CE",
# Other famous OS
"beos","BeOS",
"macintosh","Mac OS",
"os/2","Warp OS/2",
"amigaos","AmigaOS",
# Unix like OS
"unix","Unknown Unix system",
"linux","Linux",
"aix","Aix",
"sunos","Sun Solaris",
"irix","Irix",
"osf","OSF Unix",
"hp-ux","HP Unix",
"netbsd","NetBSD",
"bsdi","BSDi",
"freebsd","FreeBSD",
"openbsd","OpenBSD",
# Miscellanous OS
"webtv","WebTV",
"cp/m","CPM",
"crayos","CrayOS",
"dreamcast","Dreamcast",
"riscos","Acorn RISC OS"
);

# OS AliasHash ("text that match in log after changing ' ' or '+' into '_' ","osid")
%OSAliasHash	= (
"windows_me","winme",
"windows2000","win2000",
"windows_2000","win2000",
"windows_nt_5","win2000",
"windows_nt","winnt",
"windows-nt","winnt",
"win32","winnt",
"windows_98","win98",
"windows98","win98",
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
%RobotHash   = (
# Main list of robots (found at http://info.webcrawler.com/mak/projects/robots/active.html)
# This command show how to generate tab list from this file: cat robotslist.txt | sed 's/:/ /' | awk ' /robot-id/ { name=tolower($2); } /robot-name/ { print "\""name"\", \""$0"\"," } ' | sed 's/robot-name *//g' > file
# Rem: To avoid bad detection, some robots id were removed from this list:
#      - Robots with ID of 2 letters only
#      - Robot called "webs"
# Rem: directhit is changed into direct_hit (its real id)
# Rem: calif is changed into calif[^r] to avoid confusion between tiscalifreenet browser
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
"calif[^r]", "Calif",
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
"cscrawler","CsCrawler (Not referenced robot)",
"daviesbot", "DaviesBot (Not referenced robot)",
"ezresult",	"Ezresult (Not referenced robot)",
"fast-webcrawler", "Fast-Webcrawler (Not referenced robot)",
"gnodspider","GNOD Spider (Not referenced robot)",
"jennybot", "JennyBot (Not referenced robot)",
"justview", "JustView (Not referenced robot)",
"mercator", "Mercator (Not referenced robot)",
"perman surfer", "Perman surfer (Not referenced robot)",
"redalert", "Red Alert (Not referenced robot)",
"shoutcast","Shoutcast Directory Service (Not referenced robot)",
"unlost_web_crawler", "Unlost_Web_Crawler (Not referenced robot)",
"webbase", "WebBase (Not referenced robot)",
"wisenutbot","WISENutbot (Not referenced robot)",
"yandex", "Yandex bot (Not referenced robot)",
# Supposed to be robots
"boris", "Boris (Not referenced robot)",
"digout4u", "digout4u (Not referenced robot)",
"echo", "EchO! (Not referenced robot)",
"ia_archiver", "ia_archiver (Not referenced robot)",
"ultraseek", "Ultraseek (Not referenced robot)",
"voila", "Voila (Not referenced robot)",
"webcompass", "webcompass (Not referenced robot)",
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


#-------------------------------------------------------
# Functions
#-------------------------------------------------------

sub html_head {
	if ($NoHTMLOutput != 1) {
		# Write head section
	  	print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n\n";
	    print "<html>\n";
		print "<head>\n";
		if ($PageCode ne "") { print "<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=$PageCode\"\n"; }		# If not defined, iso-8859-1 is used in major countries
		print "<meta http-equiv=\"description\" content=\"$PROG - Advanced Web Statistics for $SiteToAnalyze\">\n";
		print "<meta http-equiv=\"keywords\" content=\"$SiteToAnalyze, free, advanced, realtime, web, server, logfile, log, analyzer, analysis, statistics, stats, perl, analyse, performance, hits, visits\">\n";
		print "<meta name=\"robots\" content=\"index,follow\">\n";
		print "<title>$Message[7] $SiteToAnalyze</title>\n";
		print <<EOF;
<STYLE TYPE=text/css>
<!--
BODY { font: 12px arial, verdana, helvetica, sans-serif; background-color: #$color_Background; }
TH { font: 12px arial, verdana, helvetica, sans-serif; text-align:center; color: #$color_titletext }
TD { font: 12px arial, verdana, helvetica, sans-serif; text-align:center; color: #$color_text }
TD.AWL { font: 12px arial, verdana, helvetica, sans-serif; text-align:left; color: #$color_text }
A { font: normal 12px arial, verdana, helvetica, sans-serif; }
A:link    { color: #$color_link; text-decoration: none; }
A:visited { color: #$color_link; text-decoration: none; }
A:hover   { color: #$color_hover; text-decoration: underline; }
DIV { font: 12px arial,verdana,helvetica; text-align:justify; }
.TABLEBORDER { background-color: #$color_TableBorder; }
.TABLEFRAME { background-color: #$color_TableBG; }
.TABLEDATA { background-color: #$color_Background; }
.TABLETITLEFULL  { font: bold 14px verdana, arial, helvetica, sans-serif; background-color: #$color_TableBGTitle; }
.TABLETITLEBLANK { font: bold 14px verdana, arial, helvetica, sans-serif; background-color: #$color_Background; }
.CTooltip { position:absolute; top:0px; left:0px; z-index:2; width:280; visibility:hidden; font: 8pt MS Comic Sans,arial,sans-serif; background-color:#FFFFE6; padding: 8px; border: 1px solid black; }
//-->
</STYLE>
EOF
		print "</head>\n\n";
		print "<body>\n";
		# Write logo, flags and product name
		print "<table WIDTH=$WIDTH>\n";
		print "<tr valign=center><td class=AWL width=150 style=\"font: 18px arial,verdana,helvetica; font-weight: bold\">AWStats\n";
		Show_Flag_Links($Lang);
		print "</td>\n";
		print "<td class=AWL width=450><a href=\"http://awstats.sourceforge.net\" target=_newawstats><img src=$DirIcons/other/$Logo border=0 alt=\"$PROG Official Web Site\" title=\"$PROG Official Web Site\"></a></td></tr>\n";
		#print "<b><font face=\"verdana\" size=1><a href=\"$HomeURL\">HomePage</a> &#149\; <a href=\"javascript:history.back()\">Back</a></font></b><br>\n";
		print "<tr><td class=AWL colspan=2>$Message[54]</td></tr>\n";
		print "</table>\n";
		
		print "<hr>\n";
	}
}


sub html_end {
	if ($NoHTMLOutput != 1) {
		print "$CENTER<br><br><br>\n";
		print "<b>Advanced Web Statistics $VERSION</b> - <a href=\"http://awstats.sourceforge.net\" target=_newawstats>Created by $PROG</a><br>\n";
		print "<br>\n";
		print "$HTMLEndSection\n";
		print "</body>\n";
		print "</html>\n";
	}
}

sub tab_head {
	print "
		<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=100%>
		<TR><TD>
		<TABLE CLASS=TABLEFRAME BORDER=0 CELLPADDING=3 CELLSPACING=0 WIDTH=100%>
		<TR><TD class=TABLETITLEFULL align=center width=60%>$tab_titre </TD><TD class=TABLETITLEBLANK>&nbsp;</TD></TR>
		<TR><TD colspan=2>
		<TABLE CLASS=TABLEDATA BORDER=1 BORDERCOLOR=#$color_TableBorder CELLPADDING=2 CELLSPACING=0 WIDTH=100%>
		";
}

sub tab_end {
	print "\n</TABLE></TD></TR></TABLE>";
	print "</TD></TR></TABLE>\n\n";
}

sub UnescapeURLParam {
	$_[0] =~ tr/\+/ /s;
	$_[0] =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;		# Decode encoded URL
	$_[0] =~ tr/\'\(\)\"/    /s;									# "&" and "=" must not be in this list
}

sub error {
	if ($_[0] eq "Format error") {
		# Files seems to have bad format
		print "AWStats did not found any valid log lines that match your <b>LogFormat</b> parameter, in the 10th first non commented lines read of your log.<br>\n";
		print "<font color=#880000>Your log file <b>$_[2]</b> must have a bad format or <b>LogFormat</b> parameter setup is wrong.</font><br><br>\n";
		print "Your <b>LogFormat</b> parameter is <b>$LogFormat</b>, this means each line in your log file need to have ";
		if ($LogFormat == 1) {
			print "<b>\"combined log format\"</b> like this:<br>\n";
			print "<font color=#888888><i>111.22.33.44 - - [10/Jan/2001:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234 \"http://www.fromserver.com/from.htm\" \"Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)\"</i></font><br>\n";
		}
		if ($LogFormat == 2) {
			print "<b>\"MSIE Extended W3C log format\"</b> like this:<br>\n";
			print "<font color=#888888><i>date time c-ip c-username cs-method cs-uri-sterm sc-status sc-bytes cs-version cs(User-Agent) cs(Referer)</i></font><br>\n";
		}
		if ($LogFormat == 3) {
			print "<b>\"WebStar native log format\"</b><br>\n";
		}
		if ($LogFormat == 4) {
			print "<b>\"common log format\"</b> like this:<br>\n";
			print "<font color=#888888><i>111.22.33.44 - - [10/Jan/2001:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234</i></font><br>\n";
		}
		if ($LogFormat != 1 && $LogFormat != 2 && $LogFormat != 3 && $LogFormat != 4) {
			print "the following personalised log format:<br>\n";
			print "<font color=#888888><i>$LogFormat</i></font><br>\n";
		}
		print "<br>";
		print "And this is a sample of what AWStats found in your log (the 10th non commented line read):<br>\n";
		print ($ENV{"GATEWAY_INTERFACE"} ne ""?"<font color=#888888><i>":"");
		print "$_[1]";
		print ($ENV{"GATEWAY_INTERFACE"} ne ""?"</i></font><br>":"");
		print "\n";
	}			
   	if ($_[0] ne "Format error" && $_[0] ne "") {
   		print ($ENV{"GATEWAY_INTERFACE"} ne ""?"<font color=#880000>":"");
   		print "$_[0]";
   		print ($ENV{"GATEWAY_INTERFACE"} ne ""?"</font><br>":"");
   		print "\n";
   	}
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
	if ($Debug >= $level) { 
		my $debugstring = $_[0];
		if ($ENV{"GATEWAY_INTERFACE"} ne "") { $debugstring =~ s/^ /&nbsp&nbsp /; $debugstring .= "<br>"; }
		print "DEBUG $level - ".time." : $debugstring\n";
		}
}

sub SkipHost {
	foreach $match (@SkipHosts) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipHosts
}

sub SkipFile {
	foreach $match (@SkipFiles) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipFiles
}

sub OnlyFile {
	if ($OnlyFiles[0] eq "") { return 1; }
	foreach $match (@OnlyFiles) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @OnlyFiles
}

sub SkipDNSLookup {
	foreach $match (@SkipDNSLookupFor) { if ($_[0] =~ /$match/i) { return 1; } }
	0; # Not in @SkipDNSLookupFor
}


#------------------------------------------------------------------------------
# Function:     read config file
# Input:		$DIR $PROG $SiteToAnalyze
# Output:		Global variables
#------------------------------------------------------------------------------
sub Read_Config_File {
	$FileConfig="";
	my $Dir=$DIR; if (($Dir ne "") && (!($Dir =~ /\/$/)) && (!($Dir =~ /\\$/)) ) { $Dir .= "/"; }
	if ($FileConfig eq "") { if (open(CONFIG,"$Dir$PROG.$SiteToAnalyze.conf")) { $FileConfig="$Dir$PROG.$SiteToAnalyze.conf"; $FileSuffix=".$SiteToAnalyze"; } }
	if ($FileConfig eq "") { if (open(CONFIG,"$Dir$PROG.conf"))  { $FileConfig="$Dir$PROG.conf"; $FileSuffix=""; } }
	if ($FileConfig eq "") { if (open(CONFIG,"/etc/$PROG.$SiteToAnalyze.conf"))  { $FileConfig="/etc/$PROG.$SiteToAnalyze.conf"; $FileSuffix=".$SiteToAnalyze"; } }
	if ($FileConfig eq "") { if (open(CONFIG,"/etc/$PROG.conf"))  { $FileConfig="/etc/$PROG.conf"; $FileSuffix=""; } }
	if ($FileConfig eq "") { error("Error: Couldn't open config file \"$PROG.$SiteToAnalyze.conf\" nor \"$PROG.conf\" : $!"); }
	&debug("Call to Read_Config_File [FileConfig=\"$FileConfig\"]");
	while (<CONFIG>) {
		chomp $_; s/\r//;
		$_ =~ s/#.*//;								# Remove comments
		$_ =~ tr/\t /  /s;							# Change all blanks into " "
		$_ =~ s/=/§/; @felter=split(/§/,$_);		# Change first "=" into "§" to split
		my $param=$felter[0];
		my $value=$felter[1];
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
			@felter=split(/\s+/,$value);
			$i=0; foreach $elem (@felter)      { $HostAliases[$i]=$elem; $i++; }
			next;
			}
		if ($param =~ /^SkipHosts/) {
			@felter=split(/\s+/,$value);
			$i=0; foreach $elem (@felter)      { $SkipHosts[$i]=$elem; $i++; }
			next;
			}
		if ($param =~ /^SkipFiles/) {
			@felter=split(/\s+/,$value);
			$i=0; foreach $elem (@felter)      { $SkipFiles[$i]=$elem; $i++; }
			next;
			}
		if ($param =~ /^OnlyFiles/) {
			@felter=split(/\s+/,$value);
			$i=0; foreach $elem (@felter)      { $OnlyFiles[$i]=$elem; $i++; }
			next;
			}
		if ($param =~ /^SkipDNSLookupFor/) {
			@felter=split(/\s+/,$value);
			$i=0; foreach $elem (@felter)      { $SkipDNSLookupFor[$i]=$elem; $i++; }
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
		if ($param =~ /^color_TableBG/)         { $color_TableBG=$value; next; }
		if ($param =~ /^color_TableBorder/)     { $color_TableBorder=$value; next; }
		if ($param =~ /^color_link/)            { $color_link=$value; next; }
		if ($param =~ /^color_hover/)           { $color_hover=$value; next; }
		if ($param =~ /^color_text/)            { $color_text=$value; next; }
		if ($param =~ /^color_titletext/)       { $color_titletext=$value; next; }
		if ($param =~ /^color_weekend/)         { $color_weekend=$value; next; }
		if ($param =~ /^color_v/)               { $color_v=$value; next; }
		if ($param =~ /^color_w/)               { $color_w=$value; next; }
		if ($param =~ /^color_p/)               { $color_p=$value; next; }
		if ($param =~ /^color_h/)               { $color_h=$value; next; }
		if ($param =~ /^color_k/)               { $color_k=$value; next; }
		if ($param =~ /^color_s/)               { $color_s=$value; next; }
	}
	close CONFIG;
}


#------------------------------------------------------------------------------
# Function:     Get the messages for a specified language
# Parameter:	Language id
# Input:		None
# Output:		$Message table
#------------------------------------------------------------------------------
sub Read_Language_Data {
	my $FileLang="";
	my $Dir=$DIR; if (($Dir ne "") && (!($Dir =~ /\/$/)) && (!($Dir =~ /\\$/)) ) { $Dir .= "/"; }
	if (open(LANG,"${Dir}lang/awstats-$_[0].txt")) { $FileLang="${Dir}lang/awstats-$_[0].txt"; }
	else { if (open(LANG,"${Dir}lang/awstats-en.txt")) { $FileLang="${Dir}lang/awstats-en.txt"; } }		# If file not found, we try english
	&debug("Call to Read_Language_Data [FileLang=\"$FileLang\"]");
	if ($FileLang ne "") {
		$i = 0;
		while (<LANG>) {
			chomp $_; s/\r//;
			if ($_ =~ /^PageCode/i) {
				$_ =~ s/^PageCode=//i;
				$_ =~ s/#.*//;								# Remove comments
				$_ =~ tr/\t /  /s;							# Change all blanks into " "
				$_ =~ s/^ *//; $_ =~ s/ *$//;
				$_ =~ s/^\"//; $_ =~ s/\"$//;
				$PageCode = $_;
			}
			if ($_ =~ /^Message/i) {
				$_ =~ s/^Message\d+=//i;
				$_ =~ s/#.*//;								# Remove comments
				$_ =~ tr/\t /  /s;							# Change all blanks into " "
				$_ =~ s/^ *//; $_ =~ s/ *$//;
				$_ =~ s/^\"//; $_ =~ s/\"$//;
				$Message[$i] = $_;
				$i++;
			}
		}
	}
	close(LANG);
}


#------------------------------------------------------------------------------
# Function:     Get the tooltip texts for a specified language
# Parameter:	Language id
# Input:		None
# Output:		Full tooltips text
#------------------------------------------------------------------------------
sub Read_Language_Tooltip {
	my $FileLang="";
	my $Dir=$DIR; if (($Dir ne "") && (!($Dir =~ /\/$/)) && (!($Dir =~ /\\$/)) ) { $Dir .= "/"; }
	if (open(LANG,"${Dir}lang/awstats-tt-$_[0].txt")) { $FileLang="${Dir}lang/awstats-tt-$_[0].txt"; }
	else { if (open(LANG,"${Dir}lang/awstats-tt-en.txt")) { $FileLang="${Dir}lang/awstats-tt-en.txt"; } }		# If file not found, we try english
	&debug("Call to Read_Language_Tooltip [FileLang=\"$FileLang\"]");
	if ($FileLang ne "") {
		my @RobotArray=keys %RobotHash;
		my @SearchEnginesArray=keys %SearchEnginesHash;
		my $aws_Timeout = $VisitTimeOut/10000*60;
		my $aws_MaxNbOfRefererShown = $MaxNbOfRefererShown;
		my $aws_RobotArray = @RobotArray;
		my $aws_SearchEnginesArray = @SearchEnginesArray;
		while (<LANG>) {
			# Search for replaceable parameters
			s/#PROG#/$PROG/;
			s/#VisitTimeOut#/$aws_Timeout/;
			s/#MaxNbOfRefererShown#/$aws_MaxNbOfRefererShown/;
			s/#RobotArray#/$aws_RobotArray/;
			s/#SearchEnginesArray#/$aws_SearchEnginesArray/;
			print "$_";
		}
	}
	close(LANG);
}


#--------------------------------------------------------------------
# Input: All lobal variables
# Ouput: Change on some global variables
#--------------------------------------------------------------------
sub Check_Config {
	&debug("Call to Check_Config");
	# Main section
	if ($LogFormat =~ /^[\d]$/ && $LogFormat !~ /[1-4]/)  { error("Error: LogFormat parameter is wrong. Value is '$LogFormat' (should be 1 or 2 or a 'personalised AWtats log format string')"); }
	if ($DNSLookup !~ /[0-1]/)                            { error("Error: DNSLookup parameter is wrong. Value is '$DNSLookup' (should be 0 or 1)"); }
	# Optional section
	if ($AllowToUpdateStatsFromBrowser !~ /[0-1]/) { $AllowToUpdateStatsFromBrowser=1; }	# For compatibility, is 1 if not defined
	if ($PurgeLogFile !~ /[0-1]/)                { $PurgeLogFile=0; }
	if ($ArchiveLogRecords !~ /[0-1]/)           { $ArchiveLogRecords=1; }
	if ($DefaultFile eq "")                      { $DefaultFile="index.html"; }
	if ($WarningMessages !~ /[0-1]/)             { $WarningMessages=1; }
	if ($ShowLinksOnURL !~ /[0-1]/)              { $ShowLinksOnURL=1; }
	if ($ShowFlagLinks !~ /[0-1]/)               { $ShowFlagLinks=1; }
	if ($BarWidth !~ /^[\d][\d]*/)               { $BarWidth=260; }
	if ($BarHeight !~ /^[\d][\d]*/)              { $BarHeight=180; }
	if ($MaxNbOfDomain !~ /^[\d][\d]*/)          { $MaxNbOfDomain=25; }
	if ($MaxNbOfHostsShown !~ /^[\d][\d]*/)      { $MaxNbOfHostsShown=25; }
	if ($MinHitHost !~ /^[\d][\d]*/)             { $MinHitHost=1; }
	if ($MaxNbOfRobotShown !~ /^[\d][\d]*/)      { $MaxNbOfRobotShown=25; }
	if ($MinHitRobot !~ /^[\d][\d]*/)            { $MinHitRobot=1; }
	if ($MaxNbOfPageShown !~ /^[\d][\d]*/)       { $MaxNbOfPageShown=25; }
	if ($MinHitFile !~ /^[\d][\d]*/)             { $MinHitFile=1; }
	if ($MaxNbOfRefererShown !~ /^[\d][\d]*/)    { $MaxNbOfRefererShown=25; }
	if ($MinHitRefer !~ /^[\d][\d]*/)            { $MinHitRefer=1; }
	if ($MaxNbOfKeywordsShown !~ /^[\d][\d]*/)   { $MaxNbOfKeywordsShown=25; }
	if ($MinHitKeyword !~ /^[\d][\d]*/)          { $MinHitKeyword=1; }
	if ($SplitSearchString !~ /[0-1]/)           { $SplitSearchString=0; }
	if ($Logo eq "")                             { $Logo="awstats_logo1.png"; }
	$color_Background =~ s/#//g; if ($color_Background !~ /^[0-9|A-Z][0-9|A-Z]*$/i)           { $color_Background="FFFFFF";	}
	$color_TableBGTitle =~ s/#//g; if ($color_TableBGTitle !~ /^[0-9|A-Z][0-9|A-Z]*$/i)       { $color_TableBGTitle="CCCCDD"; }
	$color_TableTitle =~ s/#//g; if ($color_TableTitle !~ /^[0-9|A-Z][0-9|A-Z]*$/i)           { $color_TableTitle="000000"; }
	$color_TableBG =~ s/#//g; if ($color_TableBG !~ /^[0-9|A-Z][0-9|A-Z]*$/i)                 { $color_TableBG="CCCCDD"; }
	$color_TableRowTitle =~ s/#//g; if ($color_TableRowTitle !~ /^[0-9|A-Z][0-9|A-Z]*$/i)     { $color_TableRowTitle="FFFFFF"; }
	$color_TableBGRowTitle =~ s/#//g; if ($color_TableBGRowTitle !~ /^[0-9|A-Z][0-9|A-Z]*$/i) { $color_TableBGRowTitle="ECECEC"; }
	$color_TableBorder =~ s/#//g; if ($color_TableBorder !~ /^[0-9|A-Z][0-9|A-Z]*$/i)         { $color_TableBorder="ECECEC"; }
	$color_text =~ s/#//g; if ($color_text !~ /^[0-9|A-Z][0-9|A-Z]*$/i)           { $color_text="000000"; }
	$color_titletext =~ s/#//g; if ($color_titletext !~ /^[0-9|A-Z][0-9|A-Z]*$/i) { $color_titletext="000000"; }
	$color_link =~ s/#//g; if ($color_link !~ /^[0-9|A-Z][0-9|A-Z]*$/i)           { $color_link="0011BB"; }
	$color_hover =~ s/#//g; if ($color_hover !~ /^[0-9|A-Z][0-9|A-Z]*$/i)         { $color_hover="605040"; }
	$color_weekend =~ s/#//g; if ($color_weekend !~ /^[0-9|A-Z][0-9|A-Z]*$/i)     { $color_weekend="EAEAEA"; }
	$color_v =~ s/#//g; if ($color_v !~ /^[0-9|A-Z][0-9|A-Z]*$/i)                 { $color_v="F3F300"; }
	$color_w =~ s/#//g; if ($color_w !~ /^[0-9|A-Z][0-9|A-Z]*$/i)                 { $color_w="FF9933"; }
	$color_w =~ s/#//g; if ($color_p !~ /^[0-9|A-Z][0-9|A-Z]*$/i)                 { $color_p="4477DD"; }
	$color_h =~ s/#//g; if ($color_h !~ /^[0-9|A-Z][0-9|A-Z]*$/i)                 { $color_h="66F0FF"; }
	$color_k =~ s/#//g; if ($color_k !~ /^[0-9|A-Z][0-9|A-Z]*$/i)                 { $color_k="339944"; }
	$color_s =~ s/#//g; if ($color_s !~ /^[0-9|A-Z][0-9|A-Z]*$/i)                 { $color_s="8888DD"; }
	# Default value	for Messages
	if ($Message[0] eq "") { $Message[0]="Unknown"; }
	if ($Message[1] eq "") { $Message[1]="Unknown (unresolved ip)"; }
	if ($Message[2] eq "") { $Message[2]="Others"; }
	if ($Message[3] eq "") { $Message[3]="View details"; }
	if ($Message[4] eq "") { $Message[4]="Day"; }
	if ($Message[5] eq "") { $Message[5]="Month"; }
	if ($Message[6] eq "") { $Message[6]="Year"; }
	if ($Message[7] eq "") { $Message[7]="Statistics of"; }
	if ($Message[8] eq "") { $Message[8]="First visit"; }
	if ($Message[9] eq "") { $Message[9]="Last visit"; }
	if ($Message[10] eq "") { $Message[10]="Number of visits"; }
	if ($Message[11] eq "") { $Message[11]="Unique visitors"; }
	if ($Message[12] eq "") { $Message[12]="Visit"; }
	if ($Message[13] eq "") { $Message[13]="Keyword"; }
	if ($Message[14] eq "") { $Message[14]="Search"; }
	if ($Message[15] eq "") { $Message[15]="Percent"; }
	if ($Message[16] eq "") { $Message[16]="Traffic"; }
	if ($Message[17] eq "") { $Message[17]="Domains/Countries"; }
	if ($Message[18] eq "") { $Message[18]="Visitors"; }
	if ($Message[19] eq "") { $Message[19]="Pages-URL"; }
	if ($Message[20] eq "") { $Message[20]="Hours (Server time)"; }
	if ($Message[21] eq "") { $Message[21]="Browsers"; }
	if ($Message[22] eq "") { $Message[22]="HTTP Errors"; }
	if ($Message[23] eq "") { $Message[23]="Referers"; }
	if ($Message[24] eq "") { $Message[24]="Search&nbsp;Keywords"; }
	if ($Message[25] eq "") { $Message[25]="Visitors domains/countries"; }
	if ($Message[26] eq "") { $Message[26]="hosts"; }
	if ($Message[27] eq "") { $Message[27]="pages"; }
	if ($Message[28] eq "") { $Message[28]="different pages"; }
	if ($Message[29] eq "") { $Message[29]="Access"; }
	if ($Message[30] eq "") { $Message[30]="Other words"; }
	if ($Message[31] eq "") { $Message[31]="Pages not found"; }
	if ($Message[32] eq "") { $Message[32]="HTTP Error codes"; }
	if ($Message[33] eq "") { $Message[33]="Netscape versions"; }
	if ($Message[34] eq "") { $Message[34]="IE versions"; }
	if ($Message[35] eq "") { $Message[35]="Last Update"; }
	if ($Message[36] eq "") { $Message[36]="Connect to site from"; }
	if ($Message[37] eq "") { $Message[37]="Origin"; }
	if ($Message[38] eq "") { $Message[38]="Direct address / Bookmarks"; }
	if ($Message[39] eq "") { $Message[39]="Origin unknown"; }
	if ($Message[40] eq "") { $Message[40]="Links from an Internet Search Engine"; }
	if ($Message[41] eq "") { $Message[41]="Links from an external page (other web sites except search engines)"; }
	if ($Message[42] eq "") { $Message[42]="Links from an internal page (other page on same site)"; }
	if ($Message[43] eq "") { $Message[43]="keywords used on search engines"; }
	if ($Message[44] eq "") { $Message[44]="Kb"; }
	if ($Message[45] eq "") { $Message[45]="Unresolved IP Address"; }
	if ($Message[46] eq "") { $Message[46]="Unknown OS (Referer field)"; }
	if ($Message[47] eq "") { $Message[47]="Required but not found URLs (HTTP code 404)"; }
	if ($Message[48] eq "") { $Message[48]="IP Address"; }
	if ($Message[49] eq "") { $Message[49]="Error&nbsp;Hits"; }
	if ($Message[50] eq "") { $Message[50]="Unknown browsers (Referer field)"; }
	if ($Message[51] eq "") { $Message[51]="Visiting robots"; }
	if ($Message[52] eq "") { $Message[52]="visits/visitor"; }
	if ($Message[53] eq "") { $Message[53]="Robots/Spiders visitors"; }
	if ($Message[54] eq "") { $Message[54]="Free realtime logfile analyzer for advanced web statistics"; }
	if ($Message[55] eq "") { $Message[55]="of"; }
	if ($Message[56] eq "") { $Message[56]="Pages"; }
	if ($Message[57] eq "") { $Message[57]="Hits"; }
	if ($Message[58] eq "") { $Message[58]="Versions"; }
	if ($Message[59] eq "") { $Message[59]="Operating Systems"; }
	if ($Message[60] eq "") { $Message[60]="Jan"; }
	if ($Message[61] eq "") { $Message[61]="Feb"; }
	if ($Message[62] eq "") { $Message[62]="Mar"; }
	if ($Message[63] eq "") { $Message[63]="Apr"; }
	if ($Message[64] eq "") { $Message[64]="May"; }
	if ($Message[65] eq "") { $Message[65]="Jun"; }
	if ($Message[66] eq "") { $Message[66]="Jul"; }
	if ($Message[67] eq "") { $Message[67]="Aug"; }
	if ($Message[68] eq "") { $Message[68]="Sep"; }
	if ($Message[69] eq "") { $Message[69]="Oct"; }
	if ($Message[70] eq "") { $Message[70]="Nov"; }
	if ($Message[71] eq "") { $Message[71]="Dec"; }
	if ($Message[72] eq "") { $Message[72]="Navigation"; }
	if ($Message[73] eq "") { $Message[73]="Day statistics"; }
	if ($Message[74] eq "") { $Message[74]="Update now"; }
	if ($Message[75] eq "") { $Message[75]="Bytes"; }
	if ($Message[76] eq "") { $Message[76]="Back to main page"; }
	if ($Message[77] eq "") { $Message[77]="Top"; }
	if ($Message[78] eq "") { $Message[78]="dd mmm yyyy - HH:MM"; }
}

#--------------------------------------------------------------------
# Input: year,month,0|1|2	(0=read only 1st part, 1=read all file, 2=read only LastUpdate)
#--------------------------------------------------------------------
sub Read_History_File {
	&debug("Call to Read_History_File [$_[0],$_[1],$_[2]]");
	if ($HistoryFileAlreadyRead{"$_[0]$_[1]"}) { return 0; }			# Protect code to invoke function only once for each month/year
	$HistoryFileAlreadyRead{"$_[0]$_[1]"}=1;							# Protect code to invoke function only once for each month/year
	if (! -s "$DirData/$PROG$_[1]$_[0]$FileSuffix.txt") { return 0; }	# If file not exists, return

	# If session for read (no update), file can be open with share
	# POSSIBLE CHANGE HERE	
	open(HISTORY,"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt") || error("Error: Couldn't open for read file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" : $!");	# Month before Year kept for backward compatibility
	$MonthUnique{$_[0].$_[1]}=0; $MonthPages{$_[0].$_[1]}=0; $MonthHits{$_[0].$_[1]}=0; $MonthBytes{$_[0].$_[1]}=0; $MonthHostsKnown{$_[0].$_[1]}=0; $MonthHostsUnKnown{$_[0].$_[1]}=0;
	my $readdomain=0;my $readsider=0;my $readbrowser=0;my $readnsver=0;my $readmsiever=0;
	my $reados=0;my $readrobot=0;my $readunknownreferer=0;my $readunknownrefererbrowser=0;my $readse=0;
	my $readsearchwords=0;my $readerrors=0;

	while (<HISTORY>) {
		chomp $_; s/\r//;
		@field=split(/\s+/,$_);

		# FIRST PART: Always read
		if ($field[0] eq "FirstTime")       { $FirstTime{$_[0].$_[1]}=int($field[1]); next; }
	    if ($field[0] eq "LastTime")        { if ($LastTime{$_[0].$_[1]} < int($field[1])) { $LastTime{$_[0].$_[1]}=int($field[1]); }; next; }
		if ($field[0] eq "TotalVisits")     { $MonthVisits{$_[0].$_[1]}=$field[1]; next; }
	    if ($field[0] eq "LastUpdate")      {
	    	if ($LastUpdate{$_[0].$_[1]} < $field[1]) {
		    	$LastUpdate{$_[0].$_[1]}=$field[1];
		    	$LastUpdateLinesRead{$_[0].$_[1]}=$field[2];
		    	$LastUpdateNewLinesRead{$_[0].$_[1]}=$field[3];
		    	$LastUpdateLinesCorrupted{$_[0].$_[1]}=$field[4]; 
		    	$LastUpdateNewLinesCorrupted{$_[0].$_[1]}=$field[5];
		    };
	    	next;
	    }
	    if ($field[0] eq "BEGIN_VISITOR")   {
			&debug(" Begin of VISITOR section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
			@field=split(/\s+/,$_);
			while ($field[0] ne "END_VISITOR") {
		    	if ($field[0] ne "Unknown") { if ($field[1] > 0) { $MonthUnique{$_[0].$_[1]}++; } $MonthHostsKnown{$_[0].$_[1]}++; }
				if ($_[2] && ($QueryString !~ /action=/i)) {
		        	$_hostmachine_p{$field[0]}+=$field[1];
		        	$_hostmachine_h{$field[0]}+=$field[2];
		        	$_hostmachine_k{$field[0]}+=$field[3];
		        	if (! $_hostmachine_l{$field[0]}) { $_hostmachine_l{$field[0]}=int($field[4]); }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_);
			}
			&debug(" End of VISITOR section");
			next;
    	}
	    if ($field[0] eq "BEGIN_UNKNOWNIP")   {
			&debug(" Begin of UNKNOWNIP section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
			@field=split(/\s+/,$_);
			my $count=0;
			while ($field[0] ne "END_UNKNOWNIP") {
				$count++;
		    	$MonthUnique{$_[0].$_[1]}++; $MonthHostsUnknown{$_[0].$_[1]}++;
				if ($_[2] && ($UpdateStats || $QueryString =~ /action=unknownip/i)) {	# Init of $_unknownip_l not needed in this case
		        	if (! $_unknownip_l{$field[0]}) { $_unknownip_l{$field[0]}=int($field[1]); }
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_);
			}
			&debug(" End of UNKNOWN_IP section ($count entries)");
			next;
    	}
	    if ($field[0] eq "BEGIN_TIME")      {
			&debug(" Begin of TIME section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
			@field=split(/\s+/,$_);
			while ($field[0] ne "END_TIME") {
		    	$MonthPages{$_[0].$_[1]}+=$field[1]; $MonthHits{$_[0].$_[1]}+=$field[2]; $MonthBytes{$_[0].$_[1]}+=$field[3];
				if ($_[2]) {
		        	$_time_p[$field[0]]+=$field[1]; $_time_h[$field[0]]+=$field[2]; $_time_k[$field[0]]+=$field[3];
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_);
			}
			&debug(" End of TIME section");
			next;
	    }
	    if ($field[0] eq "BEGIN_DAY")      {
			&debug(" Begin of DAY section");
			$_=<HISTORY>;
			chomp $_; s/\r//;
			if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
			@field=split(/\s+/,$_);
			while ($field[0] ne "END_DAY" ) {
				if ($QueryString !~ /action=/i) {
					$DayPages{$field[0]}=int($field[1]); $DayHits{$field[0]}=int($field[2]); $DayBytes{$field[0]}=int($field[3]); $DayVisits{$field[0]}=$field[4]; $DayUnique{$field[0]}=int($field[5]);
				}
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_);
			}
			&debug(" End of DAY section");
			next;
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
		    if ($field[0] eq "BEGIN_PAGEREFS")   {
				&debug(" Begin of PAGEREFS section");
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_);
				my $count=0;
				while ($field[0] ne "END_PAGEREFS") {
					$count++;
					$_pagesrefs_h{$field[0]}+=$field[1];
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
					@field=split(/\s+/,$_);
				}
				&debug(" End of PAGEREFS section ($count entries)");
				next;
	    	}
	        if ($field[0] eq "BEGIN_SEREFERRALS") { $readse=1; next; }
	        if ($field[0] eq "END_SEREFERRALS") { $readse=0; next; }
	        if ($field[0] eq "BEGIN_SEARCHWORDS") { $readsearchwords=1; next; }
	        if ($field[0] eq "END_SEARCHWORDS") { $readsearchwords=0; next; }
	        if ($field[0] eq "BEGIN_ERRORS") { $readerrors=1; next; }
	        if ($field[0] eq "END_ERRORS") { $readerrors=0; next; }
		    if ($field[0] eq "BEGIN_SIDER_404")   {
				&debug(" Begin of SIDER_404 section");
				$_=<HISTORY>;
				chomp $_; s/\r//;
				if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
				@field=split(/\s+/,$_);
				my $count=0;
				while ($field[0] ne "END_SIDER_404") {
					$count++;
					$_sider404_h{$field[0]}+=$field[1]; $_referer404_h{$field[0]}=$field[2]; 
					$_=<HISTORY>;
					chomp $_; s/\r//;
					if ($_ eq "") { error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost)."); }
					@field=split(/\s+/,$_);
				}
				&debug(" End of SIDER_404 section ($count entries)");
				next;
			}
	        if ($readunknownreferer) {
	        	if (! $_unknownreferer_l{$field[0]}) { $_unknownreferer_l{$field[0]}=int($field[1]); }
	        	next;
	        }
			if ($readdomain) {
				$_domener_p{$field[0]}+=$field[1];
				$_domener_h{$field[0]}+=$field[2];
				$_domener_k{$field[0]}+=$field[3];
				next;
			}
			if ($readsider) { $_sider_p{$field[0]}+=$field[1]; next; }
	        if ($readbrowser) { $_browser_h{$field[0]}+=$field[1]; next; }
	        if ($readnsver) { $_nsver_h[$field[0]]+=$field[1]; next; }
	        if ($readmsiever) { $_msiever_h[$field[0]]+=$field[1]; next; }
	        if ($reados) { $_os_h{$field[0]}+=$field[1]; next; }
	        if ($readrobot) {
				$_robot_h{$field[0]}+=$field[1];
	        	if (! $_robot_l{$field[0]}) { $_robot_l{$field[0]}=int($field[2]); }
				next;
			}
	        if ($readunknownrefererbrowser) {
	        	if (! $_unknownrefererbrowser_l{$field[0]}) { $_unknownrefererbrowser_l{$field[0]}=int($field[1]); }
	        	next;
	        }
	        if ($field[0] eq "From0") { $_from_p[0]+=$field[1]; $_from_h[0]+=$field[2]; next; }
	        if ($field[0] eq "From1") { $_from_p[1]+=$field[1]; $_from_h[1]+=$field[2]; next; }
	        if ($field[0] eq "From2") { $_from_p[2]+=$field[1]; $_from_h[2]+=$field[2]; next; }
	        if ($field[0] eq "From3") { $_from_p[3]+=$field[1]; $_from_h[3]+=$field[2]; next; }
	        if ($field[0] eq "From4") { $_from_p[4]+=$field[1]; $_from_h[4]+=$field[2]; next; }
			# Next 5 lines are to read old awstats history files ("Fromx" section was "HitFromx" in such files)
	        if ($field[0] eq "HitFrom0") { $_from_p[0]=0; $_from_h[0]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom1") { $_from_p[1]=0; $_from_h[1]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom2") { $_from_p[2]=0; $_from_h[2]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom3") { $_from_p[3]=0; $_from_h[3]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom4") { $_from_p[4]=0; $_from_h[4]+=$field[1]; next; }
	        if ($readse) { $_se_referrals_h{$field[0]}+=$field[1]; next; }
	        if ($readsearchwords) { $_keywords{$field[0]}+=$field[1]; next; }
	        if ($readerrors) { $_errors_h{$field[0]}+=$field[1]; next; }
		}
	}
	close HISTORY;
	if ($readdomain || $readunknownip || $readsider || $readbrowser || $readnsver || $readmsiever || $reados || $readrobot || $readunknownreferer || $readunknownrefererbrowser || $readpagerefs || $readse || $readsearchwords || $readerrors) {
		# History file is corrupted
		error("Error: History file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.txt\" is corrupted. Restore a backup of this file, or remove it (data for this month will be lost).");
	}
}

#--------------------------------------------------------------------
# Function:    Show flags for 5 major languages
# Input:       Year, Month
#--------------------------------------------------------------------
sub Save_History_File {
	&debug("Call to Save_History_File [$_[0],$_[1]]");
	open(HISTORYTMP,">$DirData/$PROG$_[1]$_[0]$FileSuffix.tmp.$$") || error("Error: Couldn't open file \"$DirData/$PROG$_[1]$_[0]$FileSuffix.tmp.$$\" : $!");	# Month before Year kept for backward compatibility

	print HISTORYTMP "FirstTime $FirstTime{$_[0].$_[1]}\n";
	print HISTORYTMP "LastTime $LastTime{$_[0].$_[1]}\n";
	if ($LastUpdate{$_[0].$_[1]} lt "$nowyear$nowmonth$nowday$nowhour$nowmin$nowsec") { $LastUpdate{$_[0].$_[1]}="$nowyear$nowmonth$nowday$nowhour$nowmin$nowsec"; }
	print HISTORYTMP "LastUpdate $LastUpdate{$_[0].$_[1]} $NbOfLinesRead $NbOfNewLinesProcessed $NbOfLinesCorrupted $NbOfNewLinesCorrupted\n";
	print HISTORYTMP "TotalVisits $MonthVisits{$_[0].$_[1]}\n";

	print HISTORYTMP "BEGIN_DOMAIN\n";
#	foreach $key (keys %_domener_h) {
	foreach $key (sort keys %_domener_h) {
		my $page=$_domener_p{$key}; if ($page == "") {$page=0;}
		my $bytes=$_domener_k{$key}; if ($bytes == "") {$bytes=0;}
		print HISTORYTMP "$key $page $_domener_h{$key} $bytes\n"; next;
	}
	print HISTORYTMP "END_DOMAIN\n";

	print HISTORYTMP "BEGIN_VISITOR\n";
#	foreach $key (keys %_hostmachine_h) {
	foreach $key (sort keys %_hostmachine_h) {
		my $page=$_hostmachine_p{$key}; if ($page == "") {$page=0;}
		my $bytes=$_hostmachine_k{$key}; if ($bytes == "") {$bytes=0;}
		print HISTORYTMP "$key $page $_hostmachine_h{$key} $bytes $_hostmachine_l{$key}\n"; next;
	}
	print HISTORYTMP "END_VISITOR\n";

	print HISTORYTMP "BEGIN_UNKNOWNIP\n";
#	foreach $key (keys %_unknownip_l) { print HISTORYTMP "$key $_unknownip_l{$key}\n"; next; }
	foreach $key (sort keys %_unknownip_l) { print HISTORYTMP "$key $_unknownip_l{$key}\n"; next; }
	print HISTORYTMP "END_UNKNOWNIP\n";

	print HISTORYTMP "BEGIN_SIDER\n";
	foreach $key (sort keys %_sider_p) { print HISTORYTMP "$key $_sider_p{$key}\n"; next; }
#	foreach $key (keys %_sider_p) { print HISTORYTMP "$key $_sider_p{$key}\n"; next; }
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
#	foreach $key (keys %_browser_h) { print HISTORYTMP "$key $_browser_h{$key}\n"; next; }
	foreach $key (sort keys %_browser_h) { print HISTORYTMP "$key $_browser_h{$key}\n"; next; }
	print HISTORYTMP "END_BROWSER\n";
	print HISTORYTMP "BEGIN_NSVER\n";
	for ($i=1; $i<=$#_nsver_h; $i++) { print HISTORYTMP "$i $_nsver_h[$i]\n"; next; }
	print HISTORYTMP "END_NSVER\n";
	print HISTORYTMP "BEGIN_MSIEVER\n";
	for ($i=1; $i<=$#_msiever_h; $i++) { print HISTORYTMP "$i $_msiever_h[$i]\n"; next; }
	print HISTORYTMP "END_MSIEVER\n";
	print HISTORYTMP "BEGIN_OS\n";
#	foreach $key (keys %_os_h) { print HISTORYTMP "$key $_os_h{$key}\n"; next; }
	foreach $key (sort keys %_os_h) { print HISTORYTMP "$key $_os_h{$key}\n"; next; }
	print HISTORYTMP "END_OS\n";

	print HISTORYTMP "BEGIN_ROBOT\n";
#	foreach $key (keys %_robot_h) { print HISTORYTMP "$key $_robot_h{$key} $_robot_l{$key}\n"; next; }
	foreach $key (sort keys %_robot_h) { print HISTORYTMP "$key $_robot_h{$key} $_robot_l{$key}\n"; next; }
	print HISTORYTMP "END_ROBOT\n";

	print HISTORYTMP "BEGIN_UNKNOWNREFERER\n";
#	foreach $key (keys %_unknownreferer_l) { print HISTORYTMP "$key $_unknownreferer_l{$key}\n"; next; }
	foreach $key (sort keys %_unknownreferer_l) { print HISTORYTMP "$key $_unknownreferer_l{$key}\n"; next; }
	print HISTORYTMP "END_UNKNOWNREFERER\n";
	print HISTORYTMP "BEGIN_UNKNOWNREFERERBROWSER\n";
#	foreach $key (keys %_unknownrefererbrowser_l) { print HISTORYTMP "$key $_unknownrefererbrowser_l{$key}\n"; next; }
	foreach $key (sort keys %_unknownrefererbrowser_l) { print HISTORYTMP "$key $_unknownrefererbrowser_l{$key}\n"; next; }
	print HISTORYTMP "END_UNKNOWNREFERERBROWSER\n";

	print HISTORYTMP "From0 $_from_p[0] $_from_h[0]\n";
	print HISTORYTMP "From1 $_from_p[1] $_from_h[1]\n";
	print HISTORYTMP "From2 $_from_p[2] $_from_h[2]\n";
	print HISTORYTMP "From3 $_from_p[3] $_from_h[3]\n";
	print HISTORYTMP "From4 $_from_p[4] $_from_h[4]\n";

	print HISTORYTMP "BEGIN_SEREFERRALS\n";
#	foreach $key (keys %_se_referrals_h) { print HISTORYTMP "$key $_se_referrals_h{$key}\n"; next; }
	foreach $key (sort keys %_se_referrals_h) { print HISTORYTMP "$key $_se_referrals_h{$key}\n"; next; }
	print HISTORYTMP "END_SEREFERRALS\n";

	print HISTORYTMP "BEGIN_PAGEREFS\n";
#	foreach $key (keys %_pagesrefs_h) { print HISTORYTMP "$key $_pagesrefs_h{$key}\n"; next; }
	foreach $key (sort keys %_pagesrefs_h) { print HISTORYTMP "$key $_pagesrefs_h{$key}\n"; next; }
	print HISTORYTMP "END_PAGEREFS\n";

	print HISTORYTMP "BEGIN_SEARCHWORDS\n";
#	foreach $key (keys %_keywords) { if ($_keywords{$key}) { print HISTORYTMP "$key $_keywords{$key}\n"; } next; }
	foreach $key (sort keys %_keywords) { if ($_keywords{$key}) { print HISTORYTMP "$key $_keywords{$key}\n"; } next; }
	print HISTORYTMP "END_SEARCHWORDS\n";

	print HISTORYTMP "BEGIN_ERRORS\n";
#	foreach $key (keys %_errors_h) { print HISTORYTMP "$key $_errors_h{$key}\n"; next; }
	foreach $key (keys %_errors_h) { print HISTORYTMP "$key $_errors_h{$key}\n"; next; }
	print HISTORYTMP "END_ERRORS\n";

	print HISTORYTMP "BEGIN_SIDER_404\n";
#	foreach $key (keys %_sider404_h) { print HISTORYTMP "$key $_sider404_h{$key} $_referer404_h{$key}\n"; next; }
	foreach $key (sort keys %_sider404_h) { print HISTORYTMP "$key $_sider404_h{$key} $_referer404_h{$key}\n"; next; }
	print HISTORYTMP "END_SIDER_404\n";

	close(HISTORYTMP);
}

#--------------------------------------------------------------------
# Input: Global variables
#--------------------------------------------------------------------
sub Init_HashArray {
	&debug("Call to Init_HashArray [$_[0],$_[1]]");
	# We purge data read for year $_[0] and month $_[1] so it's like we never read it
	$HistoryFileAlreadyRead{"$_[0]$_[1]"}=0;
	# Delete/Reinit all arrays with name beginning by _
	@_msiever_h = @_nsver_h = ();
	for ($ix=0; $ix<5; $ix++) {	$_from_p[$ix]=0; $_from_h[$ix]=0; }
	for ($ix=0; $ix<=23; $ix++) { $_time_h[$ix]=0; $_time_k[$ix]=0; $_time_p[$ix]=0; }
	# Delete/Reinit all hash arrays with name beginning by _
	%_browser_h = %_domener_h = %_domener_k = %_domener_p = %_errors_h = 
	%_hostmachine_h = %_hostmachine_k = %_hostmachine_l = %_hostmachine_p =
	%_keywords = %_os_h = %_pagesrefs_h = %_robot_h = %_robot_l = %_se_referrals_h =
	%_sider404_h = %_sider_h = %_sider_k = %_sider_p = %_unknownip_l = %_unknownreferer_l =	%_unknownrefererbrowser_l = ();
}

#------------------------------------------------------------------------------
# Function:      Show flags for 5 major languages
# Input:         Languade id (en, fr, ...)
#------------------------------------------------------------------------------
sub Show_Flag_Links {
	my $Lang = $_[0];
	my @lngcode = ();
	if ($ShowFlagLinks == 1) { 
		$lngcode[0]="English en";
		$lngcode[1]="French fr";
		$lngcode[2]="Dutch nl";
		$lngcode[3]="Spanish es";
		$lngcode[4]="Italian it";
		$lngcode[5]="German de";
		print "<br>\n";
		for (0..5) {		# Only flags for 5 major languages
			my ($lng, $code) = split(/\s+/, $lngcode[$_]);
			if ($Lang ne $code) { print "<a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$code\"><img src=\"$DirIcons\/flags\/$code.png\" height=14 border=0 alt=\"$lng\" title=\"$lng\"></a>&nbsp;\n"; }
		}
	}
}

#------------------------------------------------------------------------------
# Function:      Format value in bytes in a string (Bytes, Kb, Mb, Gb)
# Input:         bytes
#------------------------------------------------------------------------------
sub Format_Bytes {
	my $bytes = $_[0];
	my $fudge = 1;
	if ($bytes >= $fudge * exp(3*log(1024))) { return sprintf("%.2f", $bytes/exp(3*log(1024)))." Gb"; }
	if ($bytes >= $fudge * exp(2*log(1024))) { return sprintf("%.2f", $bytes/exp(2*log(1024)))." Mb"; }
	if ($bytes >= $fudge * exp(1*log(1024))) { return sprintf("%.2f", $bytes/exp(1*log(1024)))." $Message[44]"; }
	return "$bytes $Message[75]";
}

#------------------------------------------------------------------------------
# Function:      Format a date according to Message[78] (country date format)
# Input:         day month year hour min
#------------------------------------------------------------------------------
sub Format_Date {
	my $date=shift;
	my $year=substr("$date",0,4);
	my $month=substr("$date",4,2);
	my $day=substr("$date",6,2);
	my $hour=substr("$date",8,2);
	my $min=substr("$date",10,2);
	my $dateformat=$Message[78];
	$dateformat =~ s/yyyy/$year/g;
	$dateformat =~ s/yy/$year/g;
	$dateformat =~ s/mmm/$monthlib{$month}/g;
	$dateformat =~ s/mm/$month/g;
	$dateformat =~ s/dd/$day/g;
	$dateformat =~ s/HH/$hour/g;
	$dateformat =~ s/MM/$min/g;
	return "$dateformat";
}


#-------------------------------------------------------
# MAIN
#-------------------------------------------------------
if ($ENV{"GATEWAY_INTERFACE"} ne "") {	# Run from a browser
	print("Content-type: text/html\n\n\n");
	if ($ENV{"CONTENT_LENGTH"} ne "") {
		binmode STDIN;
		$NbBytesRead=read(STDIN, $QueryString, $ENV{'CONTENT_LENGTH'});
	}
	if ($ENV{"QUERY_STRING"} ne "") {
		$QueryString = $ENV{"QUERY_STRING"};
	}
	$QueryString =~ s/<script.*$//i;						# This is to avoid 'Cross Site Scripting attacks'
	if ($QueryString =~ /site=/) { $SiteToAnalyze=$QueryString; $SiteToAnalyze =~ s/.*site=//; $SiteToAnalyze =~ s/&.*//; $SiteToAnalyze =~ s/ .*//; }
	$UpdateStats=0;
	if ($QueryString =~ /update=1/i) { $UpdateStats=1; }	# No update by default when run from a browser
}
else {									# Run from command line
	if ($ARGV[0] eq "-h") { $SiteToAnalyze = $ARGV[1]; }	# Kept for backward compatibility but useless
	$QueryString=""; for (0..@ARGV-1) { $QueryString .= "$ARGV[$_] "; }
	$QueryString =~ s/<script.*$//i;						# This is to avoid 'Cross Site Scripting attacks'
	if ($QueryString =~ /site=/) { $SiteToAnalyze=$QueryString; $SiteToAnalyze =~ s/.*site=//; $SiteToAnalyze =~ s/&.*//; $SiteToAnalyze =~ s/ .*//; }
	$UpdateStats=1;
	if ($QueryString =~ /noupdate/i) { $UpdateStats=0; }	# Update by default when run from command line
	if ($QueryString =~ /update=0/i) { $UpdateStats=0; }	# Other option for no update kept for backward compatibility
}
if ($QueryString =~ /-nooutput/i)  	{ $NoHTMLOutput=1; }
if ($QueryString =~ /-showsteps/i) 	{ $ShowSteps=1; }
if ($QueryString =~ /sort=/i)  		{ $Sort=$QueryString; $Sort =~ s/.*sort=//i; $Sort =~ s/&.*//; $Sort =~ s/\s+//; }
if ($QueryString =~ /debug=/i) 		{ $Debug=$QueryString; $Debug =~ s/.*debug=//; $Debug =~ s/&.*//; $Debug =~ s/ .*//; }
if ($QueryString =~ /action=urldetail:/i) 	{	
	# A filter can be defined with action=urldetail to reduce number of lines read and showed
	$URLFilter=$QueryString; $URLFilter =~ s/.*action=urldetail://; $URLFilter =~ s/&.*//; $URLFilter =~ s/ .*//;
}

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
	print "Syntax: $PROG.$Extension -site=www.host.com [options]\n";
	print "  This runs $PROG in command line to update statistics of a web site, from\n";
	print "  the log file defined in config file, and returns an HTML report.\n";
	print "  First, $PROG tries to read $PROG.www.host.com.conf as the config file,\n";
	print "  if not found, it will read $PROG.conf\n";
	print "  See README.TXT file to know how to create the config file.\n";
	print "\n";
	print "Options:\n";
	print "  -nooutput            to update statistics only with no HTML output report\n";
	print "  -noupdate            to output a report with no update of statistics\n";
	print "  -showsteps           to add benchmark informations every $NbOfLinesForBenchmark lines processed\n";
#	print "  -debug=X             to add debug informations lesser than level X\n";
	print "  -lang=LL             to output a report page in language LL (en,fr,es,...)\n";
	print "  -month=MM -year=YYYY to output a report for an old month=MM, year=YYYY\n";
	print "  Warning : Those 'date' options doesn't allow you to process old log file.\n";
	print "  It only allows you to see a report for a choosed month/year period instead\n";
	print "  of current month/year. To update stats from a log file, use standard syntax.\n";
	print "  Be care to process log files in chronological order.\n";
	print "\n";
	print "Now supports/detects:\n";
	print "  Number of visits and unique visitors\n";
	print "  Rush hours\n";
	print "  Most often viewed pages\n";
	my @DomainsArray=keys %DomainsHash;
	print "  ".(@DomainsArray)." domains/countries\n";
	my @BrowserArray=keys %BrowsersHash;
	print "  ".(@BrowserArray)." browsers\n";
	my @OSArray=keys %OSHash;
	print "  ".(@OSArray)." Operating Systems\n";
	my @RobotArray=keys %RobotHash;
	print "  ".(@RobotArray)." robots\n";
	my @SearchEnginesArray=keys %SearchEnginesHash;
	print "  ".(@SearchEnginesArray)." search engines (and keywords or keyphrases used from them)\n";
	print "  All HTTP errors\n";
	print "  Statistics by day/month/year\n";
	print "New versions and FAQ at http://awstats.sourceforge.net\n";
	exit 0;
}

# Get current time
$nowtime=time;
($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear) = localtime($nowtime);
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
$nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
if (++$nowmonth < 10) { $nowmonth = "0$nowmonth"; }
if ($nowday < 10) { $nowday = "0$nowday"; }
if ($nowhour < 10) { $nowhour = "0$nowhour"; }
if ($nowmin < 10) { $nowmin = "0$nowmin"; }
if ($nowsec < 10) { $nowsec = "0$nowsec"; }
# Get tomorrow time (will be used to discard some record with corrupted date (future date))
($tomorrowsec,$tomorrowmin,$tomorrowhour,$tomorrowday,$tomorrowmonth,$tomorrowyear) = localtime($nowtime+86400);
if ($tomorrowyear < 100) { $tomorrowyear+=2000; } else { $tomorrowyear+=1900; }
$tomorrowsmallyear=$tomorrowyear;$tomorrowsmallyear =~ s/^..//;
if (++$tomorrowmonth < 10) { $tomorrowmonth = "0$tomorrowmonth"; }
if ($tomorrowday < 10) { $tomorrowday = "0$tomorrowday"; }
if ($tomorrowhour < 10) { $tomorrowhour = "0$tomorrowhour"; }
if ($tomorrowmin < 10) { $tomorrowmin = "0$tomorrowmin"; }
if ($tomorrowsec < 10) { $tomorrowsec = "0$tomorrowsec"; }
$timetomorrow=int($tomorrowyear.$tomorrowmonth.$tomorrowday.$tomorrowhour.$tomorrowmin.$tomorrowsec);

# Read config file
&Read_Config_File;
if ($QueryString =~ /lang=/i) { $Lang=$QueryString; $Lang =~ s/.*lang=//i; $Lang =~ s/&.*//; $Lang =~ s/\s+//; }
if ($Lang eq "") { $Lang="en"; }

# Change old values of Lang into new for compatibility
if ($Lang eq "0") { $Lang="en"; }
if ($Lang eq "1") { $Lang="fr"; }
if ($Lang eq "2") { $Lang="nl"; }
if ($Lang eq "3") { $Lang="es"; }
if ($Lang eq "4") { $Lang="it"; }
if ($Lang eq "5") { $Lang="de"; }
if ($Lang eq "6") { $Lang="pl"; }
if ($Lang eq "7") { $Lang="gr"; }
if ($Lang eq "8") { $Lang="cz"; }
if ($Lang eq "9") { $Lang="pt"; }
if ($Lang eq "10") { $Lang="kr"; }

# Get the output strings
&Read_Language_Data($Lang);

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
%monthlib =  ( "01","$Message[60]","02","$Message[61]","03","$Message[62]","04","$Message[63]","05","$Message[64]","06","$Message[65]","07","$Message[66]","08","$Message[67]","09","$Message[68]","10","$Message[69]","11","$Message[70]","12","$Message[71]" );
# monthnum must be in english because it's used to translate log date in apache log files which are always in english
%monthnum =  ( "Jan","01","jan","01","Feb","02","feb","02","Mar","03","mar","03","Apr","04","apr","04","May","05","may","05","Jun","06","jun","06","Jul","07","jul","07","Aug","08","aug","08","Sep","09","sep","09","Oct","10","oct","10","Nov","11","nov","11","Dec","12","dec","12" );

# Check year and month parameters
if ($QueryString =~ /year=/i) 	{ $YearRequired=$QueryString; $YearRequired =~ s/.*year=//; $YearRequired =~ s/&.*//;  $YearRequired =~ s/ .*//; }
if ($YearRequired !~ /^[\d][\d][\d][\d]$/) { $YearRequired=$nowyear; }
if ($QueryString =~ /month=/i)	{ $MonthRequired=$QueryString; $MonthRequired =~ s/.*month=//; $MonthRequired =~ s/&.*//; $MonthRequired =~ s/ .*//; }
if ($MonthRequired ne "year" && $MonthRequired !~ /^[\d][\d]$/) { $MonthRequired=$nowmonth; }

$BrowsersHash{"netscape"}="<font color=blue>Netscape</font> <a href=\"$DirCgi$PROG.$Extension?action=browserdetail&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">($Message[58])</a>";
$BrowsersHash{"msie"}="<font color=blue>MS Internet Explorer</font> <a href=\"$DirCgi$PROG.$Extension?action=browserdetail&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">($Message[58])</a>";

# Init all global variables
if (@HostAliases == 0) {
	warning("Warning: HostAliases parameter is not defined, $PROG will choose \"$SiteToAnalyze localhost 127.0.0.1\".");
	$HostAliases[0]=$SiteToAnalyze; $HostAliases[1]="localhost"; $HostAliases[2]="127.0.0.1";
	}
my $SiteToAnalyzeIsInHostAliases=0;
foreach $elem (@HostAliases) { if ($elem eq $SiteToAnalyze) { $SiteToAnalyzeIsInHostAliases=1; last; } }
if ($SiteToAnalyzeIsInHostAliases == 0) { $HostAliases[@HostAliases]=$SiteToAnalyze; }
if (@SkipFiles == 0) { $SkipFiles[0]="\.css\$";$SkipFiles[1]="\.js\$";$SkipFiles[2]="\.class\$";$SkipFiles[3]="robots\.txt\$"; }
$FirstTime=0;$LastTime=0;$LastUpdate=0;$TotalVisits=0;$TotalHostsKnown=0;$TotalHostsUnKnown=0;$TotalUnique=0;$TotalDifferentPages=0;$TotalKeywords=0;
for ($ix=1; $ix<=12; $ix++) {
	my $monthix=$ix;if ($monthix < 10) { $monthix  = "0$monthix"; }
	$FirstTime{$YearRequired.$monthix}=0;$LastTime{$YearRequired.$monthix}=0;$LastUpdate{$YearRequired.$monthix}=0;
	$MonthVisits{$YearRequired.$monthix}=0;$MonthUnique{$YearRequired.$monthix}=0;$MonthPages{$YearRequired.$monthix}=0;$MonthHits{$YearRequired.$monthix}=0;$MonthBytes{$YearRequired.$monthix}=0;$MonthHostsKnown{$YearRequired.$monthix}=0;$MonthHostsUnKnown{$YearRequired.$monthix}=0;
	}
&Init_HashArray;	# Should be useless in perl (except with mod_perl that keep variables in memory).


#------------------------------------------
# UPDATE PROCESS
#------------------------------------------

# No update (no log processing) if not current month or full current year asked
#if (($YearRequired == $nowyear) && ($MonthRequired eq "year" || $MonthRequired == $nowmonth)) {
# No update (no log processing) if UpdateStats != 1
if ($UpdateStats) {
	&debug("Start Update process");

	# READING THE LAST PROCESSED HISTORY FILE
	#------------------------------------------

	# Search last file
	opendir(DIR,"$DirData");
	@filearray = sort readdir DIR;
	close DIR;
	my $yearmonthmax=0;
	foreach $i (0..$#filearray) {
		if ("$filearray[$i]" =~ /^$PROG[\d][\d][\d][\d][\d][\d]$FileSuffix\.txt$/) {
			my $yearmonth=$filearray[$i]; $yearmonth =~ s/^$PROG//; $yearmonth =~ s/\..*//;
			my $yearfile=$yearmonth; $yearfile =~ s/^..//;
			my $monthfile=$yearmonth; $monthfile =~ s/....$//;
			$yearmonth="$yearfile$monthfile";	# year and month have been inversed
			if ($yearmonth > $yearmonthmax) { $yearmonthmax=$yearmonth; }
		}
	};

	$monthtoprocess=0;$yeartoprocess=0;
	if ($yearmonthmax) {	# We found last history file
		$yeartoprocess=$yearmonthmax; $monthtoprocess=$yearmonthmax;
		$yeartoprocess =~ s/..$//; $monthtoprocess =~ s/^....//;
		# We read LastTime in this last history file.
		&Read_History_File($yeartoprocess,$monthtoprocess,1);
	}

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
	if ($LogFormat == 4) { $LogFormatString="%h %l %u %t \"%r\" %>s %b"; }
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
		$PerlParsingFormat="([^\\t]*\\t[^\\t]*)\\t([^\\t]*)\\t([\\d]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t[^\\t]*\\t.*:([^\\t]*)\\t([\\d]*)";
		$pos_date=1;$pos_method=2;$pos_code=3;$pos_rc=4;$pos_agent=5;$pos_referer=6;$pos_url=7;$pos_size=8;
		$lastrequiredfield=8;
	}
	if ($LogFormat == 4) {
		$PerlParsingFormat="([^\\s]*) [^\\s]* [^\\s]* \\[([^\\s]*) [^\\s]*\\] \\\"([^\\s]*) ([^\\s]*) [^\\\"]*\\\" ([\\d|-]*) ([\\d|-]*)";
#		$pos_rc=1;$pos_logname=2;$pos_user=3;$pos_date=4;$pos_zone=5;$pos_method=6;$pos_url=7;$pos_code=8;$pos_size=9;
		$pos_rc=1;$pos_date=2;$pos_method=3;$pos_url=4;$pos_code=5;$pos_size=6;	# ETF1
		$lastrequiredfield=9;
	}
	if ($LogFormat != 1 && $LogFormat != 2 && $LogFormat != 3 && $LogFormat != 4) {
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
			if ($f =~ /%code$/ || $f =~ /%.*>s$/ || $f =~ /sc-status$/) {
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
		($PerlParsingFormat) ? chop($PerlParsingFormat) : error("Error: no recognised format commands in personalised LogFormat string"); 
		$lastrequiredfield=$i--;
	}
	if ($pos_rc eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%host in your LogFormat string)."); }
	if ($pos_date eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%time1 or \%time2 in your LogFormat string)."); }
	if ($pos_method eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%methodurl or \%method in your LogFormat string)."); }
	if ($pos_url eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%methodurl or \%url in your LogFormat string)."); }
	if ($pos_code eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%code in your LogFormat string)."); }
	if ($pos_size eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%bytesd in your LogFormat string)."); }
	if ($LogFormat != 4) {	# If not common format, referer and agent are required
		if ($pos_referer eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%referer or \%refererquot in your LogFormat string)."); }
		if ($pos_agent eq "") { error("Error: Your personalised LogFormat does not include all fields required by AWStats (Add \%ua or \%uaquot in your LogFormat string)."); }
	}
	&debug("PerlParsingFormat is $PerlParsingFormat");


	# PROCESSING CURRENT LOG
	#------------------------------------------
	&debug("Start of processing log file (monthtoprocess=$monthtoprocess, yeartoprocess=$yeartoprocess)");
	my $yearmonth="$yeartoprocess$monthtoprocess";
	$NbOfLinesRead=0; $NbOfLinesCorrupted=0; 
	$NbOfNewLinesProcessed=0; $NbOfNewLinesCorrupted=0;
	$NowNewLinePhase=0;
	$starttime=time();

	# Open log file
	&debug("Open log file \"$LogFile\"");
	open(LOG,"$LogFile") || error("Error: Couldn't open server log file \"$LogFile\" : $!");

	while (<LOG>)
	{
		chomp $_; s/\r//;
		if (/^#/) { next; }									# Ignore comment lines (ISS writes such comments)
		if (/^!!/) { next; }								# Ignore comment lines (Webstar writes such comments)
		if (/^$/) { next; }									# Ignore blank lines (With ISS: happens sometimes, with Apache: possible when editing log file)

		$NbOfLinesRead++;

		# Parse line record to get all required fields
		$_ =~ /^$PerlParsingFormat/;
		foreach $i (1..$lastrequiredfield) { $field[$i]=$$i; }
		&debug(" Record $NbOfLinesRead is: $field[$pos_rc] ; - ; - ; $field[$pos_date] ; TZ; $field[$pos_method] ; $field[$pos_url] ; $field[$pos_code] ; $field[$pos_size] ; $field[$pos_referer] ; $field[$pos_agent]",3);

		# Check parsed parameters
		#----------------------------------------------------------------------
		if ($field[$pos_code] eq "") {
			$NbOfLinesCorrupted++;
			if ($NbOfLinesRead >= $NbOfLinesForCorruptedLog && $NbOfLinesCorrupted == $NbOfLinesRead) { error("Format error",$_,$LogFile); }	# Exit with format error
			next;
		}

		# Check filters
		#----------------------------------------------------------------------
		if ($field[$pos_method] ne 'GET' && $field[$pos_method] ne 'POST' && $field[$pos_method] !~ /OK/) { next; }	# Keep only GET, POST but not HEAD, OPTIONS
		if ($field[$pos_url] =~ /^RC=/) { $NbOfLinesCorrupted++; next; }			# A strange log record with IIS we need to forget
		# Split DD/Month/YYYY:HH:MM:SS or YYYY-MM-DD HH:MM:SS or MM/DD/YY\tHH:MM:SS
		$field[$pos_date] =~ tr/-\/ \t/::::/;
		@dateparts=split(/:/,$field[$pos_date]);
		if ($field[$pos_date] =~ /^....:..:..:/) { $tmp=$dateparts[0]; $dateparts[0]=$dateparts[2]; $dateparts[2]=$tmp; }
		if ($field[$pos_date] =~ /^..:..:..:/) { $dateparts[2]+=2000; $tmp=$dateparts[0]; $dateparts[0]=$dateparts[1]; $dateparts[1]=$tmp; }
		if ($monthnum{$dateparts[1]}) { $dateparts[1]=$monthnum{$dateparts[1]}; }	# Change lib month in num month if necessary
		# Create $timeconnexion like YYYYMMDDHHMMSS
		my $timeconnexion=int($dateparts[2].$dateparts[1].$dateparts[0].$dateparts[3].$dateparts[4].$dateparts[5]);
		my $dayconnexion=$dateparts[2].$dateparts[1].$dateparts[0];
		if ($timeconnexion < 10000000000000) { $NbOfLinesCorrupted++; next; }		# Should not happen, kept in case of parasite/corrupted line
		if ($timeconnexion > $timetomorrow) { $NbOfLinesCorrupted++; next; }		# Should not happen, kept in case of parasite/corrupted line
		
		# Skip if not a new line
		#-----------------------
		if ($NowNewLinePhase) {
			if ($timeconnexion < $LastTime{$yeartoprocess.$monthtoprocess}) { next; }	# Should not happen, kept in case of parasite/corrupted old line
		}
		else {
			if ($timeconnexion <= $LastTime{$yeartoprocess.$monthtoprocess}) {
				# NEXT LINE IS FOR TEST
				if ($ShowSteps && ($NbOfLinesRead % $NbOfLinesForBenchmark == 0)) { print "$NbOfLinesRead lines read already processed (".(time()-$starttime)." seconds, ".($NbOfLinesRead/(time()-$starttime+1))." lines/seconds)\n"; }
				next;
			}	# Already processed
			$NowNewLinePhase=1;	# This will stop comparison "<=" between timeconnexion and LastTime (we should have only new lines now)
		}

		# Here, field array, datepart array, timeconnexion and dayconnexion are init for log record
		&debug(" This is a not already processed record",3);

		# Record is approved. We found a new line
		#----------------------------------------
		$NbOfNewLinesProcessed++;
		# NEXT LINE IS FOR TEST
		if ($ShowSteps && ($NbOfNewLinesProcessed % $NbOfLinesForBenchmark == 0)) { print "$NbOfNewLinesProcessed lines processed (".(time()-$starttime)." seconds, ".($NbOfNewLinesProcessed/(time()-$starttime+1))." lines/seconds)\n"; }

		if (&SkipHost($field[$pos_rc])) { next; }		# Skip with some client host IP addresses
		if (&SkipFile($field[$pos_url])) { next; }		# Skip with some URLs
		if (! &OnlyFile($field[$pos_url])) { next; }	# Skip with other URLs

		# Is it in a new month section ?
		#-------------------------------
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
				$NbOfNewLinesCorrupted++; next;
			}
		}

		$field[$pos_agent] =~ tr/\+ /__/;		# Same Agent with different writing syntax have now same name
		$UserAgent = $field[$pos_agent];
		$UserAgent =~ tr/A-Z/a-z/;

		# Robot ? If yes, we stop here
		#-----------------------------
		my $foundrobot=0;
		if (!$TmpHashNotRobot{$UserAgent}) {	# TmpHashNotRobot is a temporary hash table to increase speed
			foreach $bot (keys %RobotHash) { if ($UserAgent =~ /$bot/) { $_robot_h{$bot}++; $_robot_l{$bot}=$timeconnexion; $foundrobot=1; last; }	}
			if ($foundrobot == 1) { next; }
			$TmpHashNotRobot{$UserAgent}=1;		# Last time, we won't search if robot or not. We know it's not.
		}

		# Canonize and clean target URL and referrer URL
		$field[$pos_url] =~ s/\/$DefaultFile$/\//;	# Replace default page name with / only
		$field[$pos_url] =~ s/\?.*//;				# Trunc CGI parameters in URL get
		$field[$pos_url] =~ s/\/\//\//g;			# Because some targeted url were taped with 2 / (Ex: //rep//file.htm)

		# Check if page or not
		$PageBool=1;
		foreach $cursor (@NotPageList) { if ($field[$pos_url] =~ /$cursor$/i) { $PageBool=0; last; } }

		# Analyze: Date - Hour - Pages - Hits - Kilo
		#-------------------------------------------
		if (! $FirstTime{$yeartoprocess.$monthtoprocess}) { $FirstTime{$yeartoprocess.$monthtoprocess}=$timeconnexion; }
		$LastTime{$yeartoprocess.$monthtoprocess} = $timeconnexion;
		if ($PageBool) {
			$_time_p[$dateparts[3]]++;													#Count accesses per hour (page)
			$DayPages{$dayconnexion}++;
			$MonthPages{$yeartoprocess.$monthtoprocess}++;
			$_sider_p{$field[$pos_url]}++; 												#Count accesses per page (page)
			}
		$_time_h[$dateparts[3]]++; $MonthHits{$yeartoprocess.$monthtoprocess}++; $DayHits{$dayconnexion}++;	#Count accesses per hour (hit)
		$_time_k[$dateparts[3]]+=$field[$pos_size]; $MonthBytes{$yeartoprocess.$monthtoprocess}+=$field[$pos_size]; $DayBytes{$dayconnexion}+=$field[$pos_size];	#Count accesses per hour (kb)
		$_sider_h{$field[$pos_url]}++;													#Count accesses per page (hit)
		$_sider_k{$field[$pos_url]}+=$field[$pos_size];									#Count accesses per page (kb)

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
					if ($MyDNSTable{$Host}) {
						&debug("End of reverse DNS lookup, found resolution of $Host in local MyDNSTable",4);
	  					$new = $MyDNSTable{$Host};
					}
					else {
						if (&SkipDNSLookup($Host)) {
							&debug("(Skipping this DNS lookup at user request.)",4);
						}
						else {
							$new=gethostbyaddr(pack("C4",split(/\./,$Host)),AF_INET);	# This is very slow, may took 20 seconds
						}
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
				  		if ($timeconnexion > ($_unknownip_l{$Host}+$VisitTimeOut)) { $MonthVisits{$yeartoprocess.$monthtoprocess}++; }
						if (! $_unknownip_l{$Host}) { $MonthUnique{$yeartoprocess.$monthtoprocess}++; $MonthHostsUnknown{$yeartoprocess.$monthtoprocess}++; }
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
				if ($timeconnexion > ($_hostmachine_l{$_}+$VisitTimeOut)) { $MonthVisits{$yeartoprocess.$monthtoprocess}++; }
				if (! $_hostmachine_l{$_}) { $MonthUnique{$yeartoprocess.$monthtoprocess}++;  }
				$_hostmachine_p{$_}++;
				$_hostmachine_l{$_}=$timeconnexion;
				}
			if (! $_hostmachine_l{$_}) { $MonthHostsKnown{$yeartoprocess.$monthtoprocess}++;  }
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
			if (($UserAgent =~ /mozilla/) && ($UserAgent !~ /compatible/) && ($UserAgent !~ /opera/)) {
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
		if ($field[$pos_referer] eq "-") { 
			if ($PageBool) { $_from_p[0]++; }
			$_from_h[0]++;
			$found=1;
		}

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
					if ($PageBool) { $_from_p[4]++; }
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
							if ($PageBool) { $_from_p[2]++; }
							$_from_h[2]++;
							$_se_referrals_h{$key}++;
							$found=1;
							# Extract keywords
							$refurl[1] =~ tr/A-Z/a-z/;				# Full param string in lowcase
							@paramlist=split(/&/,$refurl[1]);
							if ($SearchEnginesKnownUrl{$key}) {		# Search engine with known URL syntax
								foreach $param (@paramlist) {
									if ($param =~ /^$SearchEnginesKnownUrl{$key}/) { # We found good parameter
										&UnescapeURLParam($param);			# Change [ xxx=cache:www/zzz+aaa+bbb/ccc+ddd%20eee'fff ] into [ xxx=cache:www/zzz aaa bbb/ccc ddd eee fff ]
										# Ok, "xxx=cache:www/zzz aaa bbb/ccc ddd eee fff" is a search parameter line
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
									&UnescapeURLParam($param);				# Change [ xxx=cache:www/zzz+aaa+bbb/ccc+ddd%20eee'fff ] into [ xxx=cache:www/zzz aaa bbb/ccc ddd eee fff ]
									my $foundparam=1;
									foreach $paramtoexclude (@WordsToCleanSearchUrl) {
										if ($param =~ /.*$paramtoexclude.*/) { $foundparam=0; last; } # Not the param with search criteria
									}
									if ($foundparam == 0) { next; }			# Do not keep this URL parameter because is in exclude list
									# Ok, "xxx=cache:www/zzz aaa bbb/ccc ddd eee fff" is a search parameter line
									$param =~ s/.*=//;						# Cut "xxx="
									$param =~ s/^cache:[^ ]* //;
									$param =~ s/^related:[^ ]* //;
									if ($SplitSearchString) {
										@wordlist=split(/ /,$param);		# Split aaa bbb ccc ddd eee fff into a wordlist array
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
						if ($PageBool) { $_from_p[3]++; }
						$_from_h[3]++;
						if ($field[$pos_referer] =~ /http:\/\/[^\/]*\/$/i) { $field[$pos_referer] =~ s/\/$//; }	# To make htpp://www.mysite.com and http://www.mysite.com/ as same referer
						$_pagesrefs_h{$field[$pos_referer]}++;
						$found=1;
					}
				}
			}
		}

		# Origin not found
		if (!$found) {
			if ($PageBool) { $_from_p[1]++; }
			$_from_h[1]++;
		}

		# End of processing all new records.
	}
	&debug("End of processing log file(s)");

	&debug("Close log file");
	close LOG;

	# DNSLookup warning
	if ($DNSLookup && !$NewDNSLookup) { warning("Warning: <b>$PROG</b> has detected that hosts names are already resolved in your logfile <b>$LogFile</b>.<br>\nIf this is always true, you should change your setup DNSLookup=1 into DNSLookup=0 to increase $PROG speed."); }

	# Save current processed month $monthtoprocess
	if ($UpdateStats && $monthtoprocess) {	# If monthtoprocess is still 0, it means there was no history files and we found no valid lines in log file
		&Save_History_File($yeartoprocess,$monthtoprocess);		# We save data for this month,year
		if (($MonthRequired ne "year") && ($monthtoprocess != $MonthRequired)) { &Init_HashArray($yeartoprocess,$monthtoprocess); }	# Not a desired month (wrong month), so we clean data arrays
		if (($MonthRequired eq "year") && ($yeartoprocess != $YearRequired)) { &Init_HashArray($yeartoprocess,$monthtoprocess); }	# Not a desired month (wrong year), so we clean data arrays
	}

	# Archive LOG file into ARCHIVELOG
	if (($PurgeLogFile == 1) && ($ArchiveLogRecords == 1)) {
		&debug("Start of archiving log file");
		$ArchiveFileName="$DirData/${PROG}_archive$FileSuffix.log";
		open(LOG,"+<$LogFile") || error("Error: Enable to archive log records of \"$LogFile\" into \"$ArchiveFileName\" because source can't be opened for read and write: $!<br>\n");
		open(ARCHIVELOG,">>$ArchiveFileName") || error("Error: Couldn't open file \"$ArchiveFileName\" to archive current log: $!");
		while (<LOG>) {	print ARCHIVELOG $_; }
		close(ARCHIVELOG);
		chmod 0666,"$ArchiveFileName";
		&debug("End of archiving log file");
	}
	else {
		open(LOG,"+<$LogFile");
	}

	# Rename all HISTORYTMP files into HISTORYTXT
	my $allok=1;
	opendir(DIR,"$DirData");
	@filearray = sort readdir DIR;
	close DIR;
	foreach $i (0..$#filearray) {
		if ("$filearray[$i]" =~ /^$PROG[\d][\d][\d][\d][\d][\d]$FileSuffix\.tmp\..*$/) {
			my $yearmonth=$filearray[$i]; $yearmonth =~ s/^$PROG//; $yearmonth =~ s/\..*//;
			if (-s "$DirData/$PROG$yearmonth$FileSuffix.tmp.$$") {	# Rename only files for this session and with size > 0
				if (rename("$DirData/$PROG$yearmonth$FileSuffix.tmp.$$", "$DirData/$PROG$yearmonth$FileSuffix.txt")==0) {
					$allok=0;	# At least one error in renaming working files
					last;
				}
				chmod 0666,"$DirData/$PROG$yearmonth$FileSuffix.txt";
			}
		}
	}

	# Purge Log file if all renaming are ok and option is on
	if (($allok > 0) && ($PurgeLogFile == 1)) {
		truncate(LOG,0) || warning("Warning: <b>$PROG</b> couldn't purge logfile \"<b>$LogFile</b>\".<br>\nChange your logfile permissions to allow write for your web server<br>\nor change PurgeLofFile=1 into PurgeLogFile=0 in configure file<br>\n(and think to purge sometines your logile. Launch $PROG just before this to save in $PROG history text files all informations logfile contains).");
	}
	close(LOG);

}	# End of log processing



#---------------------------------------------------------------------
# SHOW REPORT
#---------------------------------------------------------------------

if ($NoHTMLOutput != 1) {
	
	# Get list of all possible years
	opendir(DIR,"$DirData");
	@filearray = sort readdir DIR;
	close DIR;
	foreach $i (0..$#filearray) {
		if ("$filearray[$i]" =~ /^$PROG[\d][\d][\d][\d][\d][\d]$FileSuffix\.txt$/) {
			my $yearmonth=$filearray[$i]; $yearmonth =~ s/^$PROG//; $yearmonth =~ s/\..*//;
			my $yearfile=$yearmonth; $yearfile =~ s/^..//;
			$listofyears{$yearfile}=1;
		}
	}
	
	# Here, first part of data for processed month (old and current) are still in memory
	# If a month was already processed, then $HistoryFileAlreadyRead{"MMYYYY"} value is 1
	
	# READING NOW ALL NOT ALREADY READ HISTORY FILES FOR ALL MONTHS OF REQUIRED YEAR
	#-------------------------------------------------------------------------------
	# Loop on each month of year but only existing and not already read will be read by Read_History_File function
	for ($ix=12; $ix>=1; $ix--) {
		my $monthix=$ix+0; if ($monthix < 10) { $monthix  = "0$monthix"; }	# Good trick to change $monthix into "MM" format
		if ($MonthRequired eq "year" || $monthix == $MonthRequired) {
			&Read_History_File($YearRequired,$monthix,1);	# Read full history file
		}
		else {
			&Read_History_File($YearRequired,$monthix,0);	# Read first part of history file is enough
		}
	}
	
	
	# Get the tooltips texts
	&Read_Language_Tooltip($Lang);
	
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
			if (tooltipOBJ != null) {
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
		}
		function HideTooltip(fArg)
		{
			var tooltipOBJ = (document.getElementById) ? document.getElementById('tt' + fArg) : eval("document.all['tt" + fArg + "']");
			if (tooltipOBJ != null) {
			    tooltipOBJ.style.visibility = "hidden";
			}
		}
	</script>
EOF
	
	
	# INFO
	#---------------------------------------------------------------------
	print "$CENTER<a name=\"MENU\"></a><BR>";
	print "<table>";
	print "<tr><td class=AWL><font style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">$Message[7] : </td><td class=AWL><font style=\"font: 14px arial,verdana,helvetica; font-weight: normal\">$SiteToAnalyze</td></tr>";
	print "<tr><td class=AWL valign=top><font style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">$Message[35] : ";
	print "</td><td class=AWL><font style=\"font: 14px arial,verdana,helvetica; font-weight: normal\">";
	my $choosedkey;
	foreach $key (sort keys %LastUpdate) { if ($LastUpdate < $LastUpdate{$key}) { $choosedkey=$key; $LastUpdate = $LastUpdate{$key}; } }
	if ($LastUpdate) { print Format_Date($LastUpdate); }
	else { print "<font color=#880000>Never updated</font>"; }
	print "</font>&nbsp; &nbsp; &nbsp; &nbsp;";
	if ($AllowToUpdateStatsFromBrowser) { print "<a href=\"$DirCgi$PROG.$Extension?update=1&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$Message[74]</a>"; }
	print "</td></tr>\n";
	if ($QueryString !~ /action=/i) {
		print "<tr><td>&nbsp;</td></tr>\n";
		# Traffic
		print "<tr><td class=AWL><font style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">$Message[16] : </td>";
		print "<td class=AWL><a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang#DOMAINS\">$Message[17]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang#VISITOR\">".ucfirst($Message[26])."</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang#ROBOTS\">$Message[53]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang#HOUR\">$Message[20]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?action=unknownip&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$Message[45]</a><br></td></tr>\n";
		# Navigation
		print "<tr><td class=AWL><font style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">$Message[72] : </td>";
		print "<td class=AWL><a href=\"$DirCgi$PROG.$Extension?action=urldetail&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$Message[19]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang#BROWSER\">$Message[21]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang#OS\">$Message[59]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?action=browserdetail&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$Message[33]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?action=browserdetail&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$Message[34]</a><br></td></tr>\n";
		# Referers
		print "<tr><td class=AWL><font style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">$Message[23] : </td>";
		print "<td class=AWL><a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang#REFERER\">$Message[37]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang#SEARCHWORDS\">$Message[24]</a><br></td></tr>\n";
		# Others
		print "<tr><td class=AWL><font style=\"font: 14px arial,verdana,helvetica; font-weight: bold\">$Message[2] : </td>";
		print "<td class=AWL> <a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang#ERRORS\">$Message[22]</a> &nbsp; <a href=\"$DirCgi$PROG.$Extension?action=notfounderror&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$Message[31]</a><br></td></tr>\n";
	}
	else {
		print "<tr><td class=AWL><a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$Message[76]</a></td></tr>\n";
	}
	print "</table>\n";
	print "<br>\n\n";
	
	
	if ($QueryString =~ /action=unknownip/i) {
		print "$CENTER<a name=\"UNKOWNIP\"></a><BR>";
		$tab_titre=$Message[45];
		&tab_head;
		print "<TR bgcolor=#$color_TableBGRowTitle><TH>$Message[48]</TH><TH>$Message[9]</TH>\n";
		my @sortunknownip=sort { $SortDir*$_unknownip_l{$a} <=> $SortDir*$_unknownip_l{$b} } keys (%_unknownip_l);
		foreach $key (@sortunknownip) { print "<tr><td>$key</td><td>".Format_Date($_unknownip_l{$key})."</td></tr>"; }
		&tab_end;
		&html_end;
		exit(0);
		}
	if ($QueryString =~ /action=unknownrefererbrowser/i) {
		print "$CENTER<a name=\"UNKOWNREFERERBROWSER\"></a><BR>";
		$tab_titre=$Message[50];
		&tab_head;
		print "<TR bgcolor=#$color_TableBGRowTitle><TH>Referer</TH><TH>$Message[9]</TH></TR>\n";
		my @sortunknownrefererbrowser=sort { $SortDir*$_unknownrefererbrowser_l{$a} <=> $SortDir*$_unknownrefererbrowser_l{$b} } keys (%_unknownrefererbrowser_l);
		foreach $key (@sortunknownrefererbrowser) {
			$key =~ s/<script.*$//gi;				# This is to avoid 'Cross Site Scripting attacks'
			print "<tr><td CLASS=AWL>$key</td><td>".Format_Date($_unknownrefererbrowser_l{$key})."</td></tr>";
		}
		&tab_end;
		&html_end;
		exit(0);
		}
	if ($QueryString =~ /action=unknownreferer/i) {
		print "$CENTER<a name=\"UNKOWNREFERER\"></a><BR>";
		$tab_titre=$Message[46];
		&tab_head;
		print "<TR bgcolor=#$color_TableBGRowTitle><TH>Referer</TH><TH>$Message[9]</TH></TR>\n";
		my @sortunknownreferer=sort { $SortDir*$_unknownreferer_l{$a} <=> $SortDir*$_unknownreferer_l{$b} } keys (%_unknownreferer_l);
		foreach $key (@sortunknownreferer) {
			$key =~ s/<script.*$//gi;				# This is to avoid 'Cross Site Scripting attacks'
			print "<tr><td CLASS=AWL>$key</td><td>".Format_Date($_unknownreferer_l{$key})."</td></tr>";
		}
		&tab_end;
		&html_end;
		exit(0);
		}
	if ($QueryString =~ /action=notfounderror/i) {
		print "$CENTER<a name=\"NOTFOUNDERROR\"></a><BR>";
		$tab_titre=$Message[47];
		&tab_head;
		print "<TR bgcolor=#$color_TableBGRowTitle><TH>URL</TH><TH bgcolor=#$color_h>$Message[49]</TH><TH>$Message[23]</TH></TR>\n";
		my @sortsider404=sort { $SortDir*$_sider404_h{$a} <=> $SortDir*$_sider404_h{$b} } keys (%_sider404_h);
		foreach $key (@sortsider404) {
			$url=$key; $url =~ s/<script.*$//gi; 							# This is to avoid 'Cross Site Scripting attacks'
			$referer=$_referer404_h{$key}; $referer =~ s/<script.*$//gi;	# This is to avoid 'Cross Site Scripting attacks'
			print "<tr><td CLASS=AWL>$url</td><td>$_sider404_h{$key}</td><td>$referer&nbsp;</td></tr>";
		}
		&tab_end;
		&html_end;
		exit(0);
		}
	if ($QueryString =~ /action=browserdetail/i) {
		print "$CENTER<a name=\"NETSCAPE\"></a><BR>";
		$tab_titre=$Message[33]."<br><img src=\"$DirIcons/browser/netscape.png\">";
		&tab_head;
		print "<TR bgcolor=#$color_TableBGRowTitle><TH>$Message[58]</TH><TH bgcolor=#$color_h width=80>$Message[57]</TH><TH bgcolor=#$color_h width=40>$Message[15]</TH></TR>\n";
		for ($i=1; $i<=$#_nsver_h; $i++) {
			my $h="&nbsp;"; my $p="&nbsp;";
			if ($_nsver_h[$i] > 0 && $_browser_h{"netscape"} > 0) {
				$h=$_nsver_h[$i]; $p=int($_nsver_h[$i]/$_browser_h{"netscape"}*1000)/10; $p="$p&nbsp;%";
			}
			print "<TR><TD CLASS=AWL>Mozilla/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
		}
		&tab_end;
		print "<a name=\"MSIE\"></a><BR>";
		$tab_titre=$Message[34]."<br><img src=\"$DirIcons/browser/msie.png\">";
		&tab_head;
		print "<TR bgcolor=#$color_TableBGRowTitle><TH>$Message[58]</TH><TH bgcolor=#$color_h width=80>$Message[57]</TH><TH bgcolor=#$color_h width=40>$Message[15]</TH></TR>\n";
		for ($i=1; $i<=$#_msiever_h; $i++) {
			my $h="&nbsp;"; my $p="&nbsp;";
			if ($_msiever_h[$i] > 0 && $_browser_h{"msie"} > 0) {
				$h=$_msiever_h[$i]; $p=int($_msiever_h[$i]/$_browser_h{"msie"}*1000)/10; $p="$p&nbsp;%";
			}
			print "<TR><TD CLASS=AWL>MSIE/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
		}
		&tab_end;
		&html_end;
		exit(0);
		}
	if ($QueryString =~ /action=urldetail/i) {
		my @sortsiders=sort { $SortDir*$_sider_p{$a} <=> $SortDir*$_sider_p{$b} } keys (%_sider_p);
		print "$CENTER<a name=\"URLDETAIL\"></a><BR>";
		$tab_titre="$Message[19]";
		if ($URLFilter) { $tab_titre.=" (Filter $URLFilter)"; }
		&tab_head;
		print "<TR bgcolor=#$color_TableBGRowTitle><TH>".(@sortsiders)." &nbsp; $Message[19]</TH><TH bgcolor=#$color_p>&nbsp;$Message[29]&nbsp;</TH><TH>&nbsp;</TH></TR>\n";
		my $max_p=1;
		if ($SortDir<0) { $max_p=$_sider_p{$sortsiders[0]}; }
		else            { $max_p=$_sider_p{$sortsiders[$#sortsiders]}; }
		foreach $key (@sortsiders) {
			if ($_sider_p{$key} < $MinHitFile) { next; }
	    	print "<TR><TD CLASS=AWL>";
			my $nompage=$Aliases{$key};
			if ($nompage eq "") { $nompage=$key; }
			$nompage=substr($nompage,0,$MaxLengthOfURL);
		    if ($ShowLinksOnUrl) { print "<A HREF=\"http://$SiteToAnalyze$key\">$nompage</A>"; }
		    else              	 { print "$nompage"; }
		    my $bredde=int($BarWidth*$_sider_p{$key}/$max_p)+1;
			print "</TD><TD>$_sider_p{$key}</TD><TD CLASS=AWL><IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde HEIGHT=8 ALT=\"$Message[56]: $_sider_p{$key}\" title=\"$Message[56]: $_sider_p{$key}\"></TD></TR>\n";
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
	
	
	# SUMMARY
	#---------------------------------------------------------------------
	my @sortsiders=sort { $SortDir*$_sider_p{$a} <=> $SortDir*$_sider_p{$b} } keys (%_sider_p);
	print "$CENTER<a name=\"SUMMARY\"></a><BR>";
	$tab_titre="$Message[7] $SiteToAnalyze";
	&tab_head;
	
	# FirstTime LastTime TotalVisits TotalUnique TotalHostsKnown TotalHostsUnknown
	my $beginmonth=$MonthRequired;my $endmonth=$MonthRequired;
	if ($MonthRequired eq "year") { $beginmonth=1;$endmonth=12; }
	for (my $monthix=$beginmonth; $monthix<=$endmonth; $monthix++) {
		$monthix=$monthix+0; if ($monthix < 10) { $monthix  = "0$monthix"; }	# Good trick to change $month into "MM" format
		if ($FirstTime{$YearRequired.$monthix} && ($FirstTime == 0 || $FirstTime > $FirstTime{$YearRequired.$monthix})) { $FirstTime = $FirstTime{$YearRequired.$monthix}; }
		if ($LastTime < $LastTime{$YearRequired.$monthix}) { $LastTime = $LastTime{$YearRequired.$monthix}; }
		$TotalVisits+=$MonthVisits{$YearRequired.$monthix};
		$TotalUnique+=$MonthUnique{$YearRequired.$monthix};
		$TotalHostsKnown+=$MonthHostsKnown{$YearRequired.$monthix};
		$TotalHostsUnknown+=$MonthHostsUnknown{$YearRequired.$monthix};
	}
	# TotalDifferentPages
	$TotalDifferentPages=@sortsiders;
	# TotalPages TotalHits TotalBytes
	for ($ix=0; $ix<=23; $ix++) { $TotalPages+=$_time_p[$ix]; $TotalHits+=$_time_h[$ix]; $TotalBytes+=$_time_k[$ix]; }
	# TotalKeywords
	foreach $key (keys %_keywords) { $TotalKeywords+=$_keywords{$key}; }
	# TotalErrors
	foreach $key (keys %_errors_h) { $TotalErrors+=$_errors_h{$key}; }
	# Ratio
	if ($TotalUnique > 0) { $RatioHosts=int($TotalVisits/$TotalUnique*100)/100; }
	if ($TotalVisits > 0) { $RatioPages=int($TotalPages/$TotalVisits*100)/100; }
	if ($TotalVisits > 0) { $RatioHits=int($TotalHits/$TotalVisits*100)/100; }
	if ($TotalVisits > 0) { $RatioBytes=int(($TotalBytes/1024)*100/$TotalVisits)/100; }
	
	print "<TR bgcolor=#$color_TableBGRowTitle><TD><b>$Message[8]</b></TD>";
	if ($MonthRequired eq "year") { print "<TD colspan=3 rowspan=2><font style=\"font: 18px arial,verdana,helvetica; font-weight: normal\">$Message[6] $YearRequired</font><br>"; }
	else { print "<TD colspan=3 rowspan=2><font style=\"font: 18px arial,verdana,helvetica; font-weight: normal\">$Message[5] $monthlib{$MonthRequired} $YearRequired</font><br>"; }
	# Show links for possible years
	foreach $key (keys %listofyears) {
		print "<a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$key&month=year&lang=$Lang\">$Message[6] $key</a> &nbsp; ";
	}
	print "</TD>";
	print "<TD><b>$Message[9]</b></TD></TR>";
	
	if ($FirstTime) { print "<TR bgcolor=#$color_TableBGRowTitle><TD>".Format_Date($FirstTime)."</TD>"; }
	else { print "<TR bgcolor=#$color_TableBGRowTitle><TD>NA</TD>"; }
	if ($LastTime) { print "<TD>".Format_Date($LastTime)."</TD></TR>"; }
	else { print "<TD>NA</TD></TR>\n"; }
	print "<TR>";
	print "<TD width=20% bgcolor=#$color_v onmouseover=\"ShowTooltip(1);\" onmouseout=\"HideTooltip(1);\">$Message[10]</TD>";
	print "<TD width=20% bgcolor=#$color_w onmouseover=\"ShowTooltip(2);\" onmouseout=\"HideTooltip(2);\">$Message[11]</TD>";
	print "<TD width=20% bgcolor=#$color_p onmouseover=\"ShowTooltip(3);\" onmouseout=\"HideTooltip(3);\">$Message[56]</TD>";
	print "<TD width=20% bgcolor=#$color_h onmouseover=\"ShowTooltip(4);\" onmouseout=\"HideTooltip(4);\">$Message[57]</TD>";
	print "<TD width=20% bgcolor=#$color_k onmouseover=\"ShowTooltip(5);\" onmouseout=\"HideTooltip(5);\">$Message[75]</TD></TR>";
	print "<TR><TD><b>$TotalVisits</b><br>&nbsp;</TD><TD><b>$TotalUnique</b><br>($RatioHosts&nbsp;$Message[52])</TD><TD><b>$TotalPages</b><br>($RatioPages&nbsp;".lc($Message[56]."/".$Message[12]).")</TD>";
	print "<TD><b>$TotalHits</b><br>($RatioHits&nbsp;".lc($Message[57]."/".$Message[12]).")</TD><TD><b>".Format_Bytes($TotalBytes)."</b><br>($RatioBytes&nbsp;$Message[44]/".lc($Message[12]).")</TD></TR>\n";
	print "<TR valign=bottom><TD colspan=5 align=center><center>";
	# Show monthly stats
	print "<TABLE>";
	print "<TR valign=bottom>";
	my $max_v=1;my $max_p=1;my $max_h=1;my $max_k=1;
	for ($ix=1; $ix<=12; $ix++) {
		my $monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
		if ($MonthVisits{$YearRequired.$monthix} > $max_v) { $max_v=$MonthVisits{$YearRequired.$monthix}; }
		if ($MonthUnique{$YearRequired.$monthix} > $max_v) { $max_v=$MonthUnique{$YearRequired.$monthix}; }
		if ($MonthPages{$YearRequired.$monthix} > $max_p)  { $max_p=$MonthPages{$YearRequired.$monthix}; }
		if ($MonthHits{$YearRequired.$monthix} > $max_h)   { $max_h=$MonthHits{$YearRequired.$monthix}; }
		if ($MonthBytes{$YearRequired.$monthix} > $max_k)  { $max_k=$MonthBytes{$YearRequired.$monthix}; }
	}
	for ($ix=1; $ix<=12; $ix++) {
		my $monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
		my $bredde_u=0; my $bredde_v=0;my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
		if ($max_v > 0) { $bredde_v=int($MonthVisits{$YearRequired.$monthix}/$max_v*$BarHeight/2)+1; }
		if ($max_v > 0) { $bredde_u=int($MonthUnique{$YearRequired.$monthix}/$max_v*$BarHeight/2)+1; }
		if ($max_h > 0) { $bredde_p=int($MonthPages{$YearRequired.$monthix}/$max_h*$BarHeight/2)+1; }
		if ($max_h > 0) { $bredde_h=int($MonthHits{$YearRequired.$monthix}/$max_h*$BarHeight/2)+1; }
		if ($max_k > 0) { $bredde_k=int($MonthBytes{$YearRequired.$monthix}/$max_k*$BarHeight/2)+1; }
		print "<TD>";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=8 ALT=\"$Message[10]: $MonthVisits{$YearRequired.$monthix}\" title=\"$Message[10]: $MonthVisits{$YearRequired.$monthix}\">";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_u\" HEIGHT=$bredde_u WIDTH=8 ALT=\"$Message[11]: $MonthUnique{$YearRequired.$monthix}\" title=\"$Message[11]: $MonthUnique{$YearRequired.$monthix}\">";
		print "&nbsp;";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=8 ALT=\"$Message[56]: $MonthPages{$YearRequired.$monthix}\" title=\"$Message[56]: $MonthPages{$YearRequired.$monthix}\">";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=8 ALT=\"$Message[57]: $MonthHits{$YearRequired.$monthix}\" title=\"$Message[57]: $MonthHits{$YearRequired.$monthix}\">";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=8 ALT=\"$Message[75]: ".Format_Bytes($MonthBytes{$YearRequired.$monthix})."\" title=\"$Message[75]: ".Format_Bytes($MonthBytes{$YearRequired.$monthix})."\">";
		print "</TD>\n";
	}
	print "</TR><TR>";
	for ($ix=1; $ix<=12; $ix++) {
		my $monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
		print "<TD valign=center><a href=\"$DirCgi$PROG.$Extension?site=$SiteToAnalyze&year=$YearRequired&month=$monthix&lang=$Lang\">$monthlib{$monthix}</a></TD>";
	}
	print "</TR></TABLE><br>";
	# Show daily stats
	print "<TABLE>";
	print "<TR valign=bottom>";
	my $max_v=1;my $max_p=1;my $max_h=1;my $max_k=1;
	my $lastdaytoshowtime=$nowtime;		# Set day cursor to today
	if (! (($MonthRequired eq $nowmonth || $MonthRequired eq "year") && $YearRequired eq $nowyear)) { 
		if ($MonthRequired eq "year") {
			# About 365.24 days a year = 31556736 seconds a year
			$lastdaytoshowtime=($YearRequired-1970+1)*31556736-43200;	# Set day cursor to last day of the year
		}
		else {
			# About 30.43 days a month = 2626728 seconds a month
			$lastdaytoshowtime=($YearRequired-1970)*31556736+$MonthRequired*2629728;
		}
	}
	for ($ix=$MaxNbOfDays-1; $ix>=0; $ix--) {
		my ($oldsec,$oldmin,$oldhour,$oldday,$oldmonth,$oldyear) = localtime($lastdaytoshowtime-($ix*86400));
		if ($oldyear < 100) { $oldyear+=2000; } else { $oldyear+=1900; }
		if (++$oldmonth < 10) { $oldmonth="0$oldmonth"; }
		if ($oldday < 10) { $oldday="0$oldday"; }
		if ($DayPages{$oldyear.$oldmonth.$oldday} > $max_p)  { $max_p=$DayPages{$oldyear.$oldmonth.$oldday}; }
		if ($DayHits{$oldyear.$oldmonth.$oldday} > $max_h)   { $max_h=$DayHits{$oldyear.$oldmonth.$oldday}; }
		if ($DayBytes{$oldyear.$oldmonth.$oldday} > $max_k)  { $max_k=$DayBytes{$oldyear.$oldmonth.$oldday}; }
	}
	for ($ix=$MaxNbOfDays-1; $ix>=0; $ix--) {
		my ($oldsec,$oldmin,$oldhour,$oldday,$oldmonth,$oldyear) = localtime($lastdaytoshowtime-($ix*86400));
		if ($oldyear < 100) { $oldyear+=2000; } else { $oldyear+=1900; }
		if (++$oldmonth < 10) { $oldmonth="0$oldmonth"; }
		if ($oldday < 10) { $oldday="0$oldday"; }
		my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
		if ($max_h > 0) { $bredde_p=int($DayPages{$oldyear.$oldmonth.$oldday}/$max_h*$BarHeight/2)+1; }
		if ($max_h > 0) { $bredde_h=int($DayHits{$oldyear.$oldmonth.$oldday}/$max_h*$BarHeight/2)+1; }
		if ($max_k > 0) { $bredde_k=int($DayBytes{$oldyear.$oldmonth.$oldday}/$max_k*$BarHeight/2)+1; }
		print "<TD>";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=4 ALT=\"$Message[56]: $DayPages{$oldyear.$oldmonth.$oldday}\" title=\"$Message[56]: $DayPages{$oldyear.$oldmonth.$oldday}\">";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=4 ALT=\"$Message[57]: $DayHits{$oldyear.$oldmonth.$oldday}\" title=\"$Message[57]: $DayHits{$oldyear.$oldmonth.$oldday}\">";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=4 ALT=\"$Message[75]: ".Format_Bytes($DayBytes{$oldyear.$oldmonth.$oldday})."\" title=\"$Message[75]: ".Format_Bytes($DayBytes{$oldyear.$oldmonth.$oldday})."\">";
		print "</TD>\n";
	}
	print "</TR><TR>";
	for ($ix=$MaxNbOfDays-1; $ix>=0; $ix--) {
		my ($oldsec,$oldmin,$oldhour,$oldday,$oldmonth,$oldyear,$oldwday) = localtime($lastdaytoshowtime-($ix*86400));
		if ($oldyear < 100) { $oldyear+=2000; } else { $oldyear+=1900; }
		if (++$oldmonth < 10) { $oldmonth="0$oldmonth"; }
		if ($oldday < 10) { $oldday="0$oldday"; }
		print "<TD valign=center".($oldwday==0||$oldwday==6?" bgcolor=#$color_weekend":"").">";
		print ($oldday==$nowday && $oldmonth==$nowmonth?"<b>":"");
		print "$oldday<br>".$monthlib{$oldmonth};
		print ($oldday==$nowday && $oldmonth==$nowmonth?"</b></TD>":"</TD>");
	}
	print "</TR></TABLE><br>";
	
	print "</center></TD></TR>";
	&tab_end;
	
	print "<br><hr>\n";
	
	
	# BY COUNTRY/DOMAIN
	#---------------------------
	my @sortdomains_p=sort { $SortDir*$_domener_p{$a} <=> $SortDir*$_domener_p{$b} } keys (%_domener_p);
	my @sortdomains_h=sort { $SortDir*$_domener_h{$a} <=> $SortDir*$_domener_h{$b} } keys (%_domener_h);
	my @sortdomains_k=sort { $SortDir*$_domener_k{$a} <=> $SortDir*$_domener_k{$b} } keys (%_domener_k);
	print "$CENTER<a name=\"DOMAINS\"></a><BR>";
	$tab_titre="$Message[25]";
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH colspan=2>$Message[17]</TH><TH>Code</TH><TH bgcolor=#$color_p width=80>$Message[56]</TH><TH bgcolor=#$color_h width=80>$Message[57]</TH><TH bgcolor=#$color_k>$Message[75]</TH><TH>&nbsp;</TH></TR>\n";
	if ($SortDir<0) { $max_h=$_domener_h{$sortdomains_h[0]}; }
	else            { $max_h=$_domener_h{$sortdomains_h[$#sortdomains_h]}; }
	if ($SortDir<0) { $max_k=$_domener_k{$sortdomains_k[0]}; }
	else            { $max_k=$_domener_k{$sortdomains_k[$#sortdomains_k]}; }
	my $count=0;my $total_p=0;my $total_h=0;my $total_k=0;
	foreach $key (@sortdomains_p) {
		my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
		if ($max_h > 0) { $bredde_p=int($BarWidth*$_domener_p{$key}/$max_h)+1; }	# use max_h to enable to compare pages with hits
		if ($max_h > 0) { $bredde_h=int($BarWidth*$_domener_h{$key}/$max_h)+1; }
		if ($max_k > 0) { $bredde_k=int($BarWidth*$_domener_k{$key}/$max_k)+1; }
		if ($key eq "ip") {
			print "<TR><TD><IMG SRC=\"$DirIcons\/flags\/$key.png\" height=14></TD><TD CLASS=AWL>$Message[0]</TD><TD>$key</TD>";
		}
		else {
			print "<TR><TD><IMG SRC=\"$DirIcons\/flags\/$key.png\" height=14></TD><TD CLASS=AWL>$DomainsHash{$key}</TD><TD>$key</TD>";
		}
		print "<TD>$_domener_p{$key}</TD><TD>$_domener_h{$key}</TD><TD>".Format_Bytes($_domener_k{$key})."</TD>";
		print "<TD CLASS=AWL>";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$Message[56]: $_domener_p{$key}\" title=\"$Message[56]: $_domener_p{$key}\"><br>\n";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 ALT=\"$Message[57]: $_domener_h{$key}\" title=\"$Message[57]: $_domener_h{$key}\"><br>\n";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$Message[75]: ".Format_Bytes($_domener_k{$key})."\" title=\"$Message[75]: ".Format_Bytes($_domener_k{$key})."\">";
		print "</TD></TR>\n";
		$total_p += $_domener_p{$key};
		$total_h += $_domener_h{$key};
		$total_k += $_domener_k{$key};
		$count++;
		if ($count >= $MaxNbOfDomain) { last; }
	}
	my $rest_p=$TotalPages-$total_p;
	my $rest_h=$TotalHits-$total_h;
	my $rest_k=$TotalBytes-$total_k;
	if ($rest_p > 0) { 	# All other domains (known or not)
		my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
		if ($max_h > 0) { $bredde_p=int($BarWidth*$rest_p/$max_h)+1; }	# use max_h to enable to compare pages with hits
		if ($max_h > 0) { $bredde_h=int($BarWidth*$rest_h/$max_h)+1; }
		if ($max_k > 0) { $bredde_k=int($BarWidth*$rest_k/$max_k)+1; }
		print "<TR><TD colspan=3 CLASS=AWL><font color=blue>$Message[2]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>".Format_Bytes($rest_k)."</TD>\n";
		print "<TD CLASS=AWL>";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$Message[56]: $rest_p\" title=\"$Message[56]: $rest_p\"><br>\n";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 ALT=\"$Message[57]: $rest_h\" title=\"$Message[57]: $rest_h\"><br>\n";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$Message[75]: ".Format_Bytes($rest_k)."\" title=\"$Message[75]: ".Format_Bytes($rest_k)."\">";
		print "</TD></TR>\n";
	}
	&tab_end;
	
	
	# BY HOST/VISITOR
	#--------------------------
	my @sorthosts_p=sort { $SortDir*$_hostmachine_p{$a} <=> $SortDir*$_hostmachine_p{$b} } keys (%_hostmachine_p);
	print "$CENTER<a name=\"VISITOR\"></a><BR>";
	$MaxNbOfHostsShown = $TotalHostsKnown+($_hostmachine_h{"Unknown"}?1:0) if $MaxNbOfHostsShown > $TotalHostsKnown;
	$tab_titre="$Message[77] $MaxNbOfHostsShown $Message[55] ".($TotalHostsKnown+$TotalHostsUnknown)." $Message[26] ($TotalUnique $Message[11])";
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH>$Message[18]</TH><TH bgcolor=#$color_p width=80>$Message[56]</TH><TH bgcolor=#$color_h width=80>$Message[57]</TH><TH bgcolor=#$color_k>$Message[75]</TH><TH>$Message[9]</TH></TR>\n";
	my $count=0;my $total_p=0;my $total_h=0;my $total_k=0;
	foreach $key (@sorthosts_p) {
		if ($_hostmachine_h{$key}>=$MinHitHost) {
			if ($key eq "Unknown") {
				print "<TR><TD CLASS=AWL><a href=\"$DirCgi$PROG.$Extension?action=unknownip&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$Message[1]</a> &nbsp; ($TotalHostsUnknown)</TD><TD>$_hostmachine_p{$key}</TD><TD>$_hostmachine_h{$key}</TD><TD>".Format_Bytes($_hostmachine_k{$key})."</TD><TD><a href=\"$DirCgi$PROG.$Extension?action=unknownip&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$Message[3]</a></TD></TR>\n";
				}
			else {
				print "<tr><td CLASS=AWL>$key</td><TD>$_hostmachine_p{$key}</TD><TD>$_hostmachine_h{$key}</TD><TD>".Format_Bytes($_hostmachine_k{$key})."</TD>";
				if ($_hostmachine_l{$key}) { print "<td>".Format_Date($_hostmachine_l{$key})."</td>"; }
				else { print "<td>-</td>"; }
				print "</tr>";
			}
			$total_p += $_hostmachine_p{$key};
			$total_h += $_hostmachine_h{$key};
			$total_k += $_hostmachine_k{$key};
		}
		$count++;
		if (!(($SortDir<0 && $count<$MaxNbOfHostsShown) || ($SortDir>0 && $#sorthosts_p-$MaxNbOfHostsShown < $count))) { last; }
	}
	my $rest_p=$TotalPages-$total_p;
	my $rest_h=$TotalHits-$total_h;
	my $rest_k=$TotalBytes-$total_k;
	if ($rest_p > 0) {	# All other visitors (known or not)
		print "<TR><TD CLASS=AWL><font color=blue>$Message[2]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>".Format_Bytes($rest_k)."</TD><TD>&nbsp;</TD></TR>\n";
	}
	&tab_end;
	
	
	# BY ROBOTS
	#----------------------------
	my @sortrobot=sort { $SortDir*$_robot_h{$a} <=> $SortDir*$_robot_h{$b} } keys (%_robot_h);
	print "$CENTER<a name=\"ROBOTS\"></a><BR>";
	$tab_titre=$Message[53];
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle onmouseover=\"ShowTooltip(16);\" onmouseout=\"HideTooltip(16);\"><TH>Robot</TH><TH bgcolor=#$color_h width=80>$Message[57]</TH><TH>$Message[9]</TH></TR>\n";
	foreach $key (@sortrobot) { print "<tr><td CLASS=AWL>$RobotHash{$key}</td><td>$_robot_h{$key}</td><td>".Format_Date($_robot_l{$key})."</td></tr>"; }
	&tab_end;
	
	
	# BY HOUR
	#----------------------------
	print "$CENTER<a name=\"HOUR\"></a><BR>";
	$tab_titre="$Message[20]";
	&tab_head;
	print "<TR><TD align=center><center><TABLE><TR>\n";
	my $max_p=0;my $max_h=0;my $max_k=0;
	for ($ix=0; $ix<=23; $ix++) {
	  print "<TH width=16>$ix</TH>";
	  if ($_time_p[$ix]>$max_p) { $max_p=$_time_p[$ix]; }
	  if ($_time_h[$ix]>$max_h) { $max_h=$_time_h[$ix]; }
	  if ($_time_k[$ix]>$max_k) { $max_k=$_time_k[$ix]; }
	}
	print "</TR>\n";
	print "<TR>\n";
	for ($ix=1; $ix<=24; $ix++) {
		my $hr=$ix; if ($hr>12) { $hr=$hr-12; }
		print "<TH><IMG SRC=\"$DirIcons\/clock\/hr$hr.png\" width=10></TH>";
	}
	print "</TR>\n";
	print "\n<TR VALIGN=BOTTOM>\n";
	for ($ix=0; $ix<=23; $ix++) {
		my $bredde_p=0;my $bredde_h=0;my $bredde_k=0;
		if ($max_h > 0) { $bredde_p=int($BarHeight*$_time_p[$ix]/$max_h)+1; }
		if ($max_h > 0) { $bredde_h=int($BarHeight*$_time_h[$ix]/$max_h)+1; }
		if ($max_k > 0) { $bredde_k=int($BarHeight*$_time_k[$ix]/$max_k)+1; }
		print "<TD>";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=6 ALT=\"$Message[56]: $_time_p[$ix]\" title=\"$Message[56]: $_time_p[$ix]\">";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=6 ALT=\"$Message[57]: $_time_h[$ix]\" title=\"$Message[57]: $_time_h[$ix]\">";
		print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=6 ALT=\"$Message[75]: ".Format_Bytes($_time_k[$ix])."\" title=\"$Message[75]: ".Format_Bytes($_time_k[$ix])."\">";
		print "</TD>\n";
	}
	print "</TR></TABLE></center></TD></TR>\n";
	&tab_end;
	
	
	# BY PAGE
	#-------------------------
	print "$CENTER<a name=\"PAGE\"></a><BR>";
	$MaxNbOfPageShown = $TotalDifferentPages if $MaxNbOfPageShown > $TotalDifferentPages;
	$tab_titre="$Message[77] $MaxNbOfPageShown $Message[55] $TotalDifferentPages $Message[27] &nbsp; - &nbsp; <a href=\"$DirCgi$PROG.$Extension?action=urldetail&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">Full list</a>";
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH>$Message[19]</TH><TH bgcolor=#$color_p>&nbsp;$Message[29]&nbsp;</TH><TH>&nbsp;</TH></TR>\n";
	my $max_p=1;
	if ($SortDir<0) { $max_p=$_sider_p{$sortsiders[0]}; }
	else            { $max_p=$_sider_p{$sortsiders[$#sortsiders]}; }
	my $count=0;
	foreach $key (@sortsiders) {
		if ((($SortDir<0 && $count<$MaxNbOfPageShown) || ($SortDir>0 && $#sortsiders-$MaxNbOfPageShown<$count)) && $_sider_p{$key}>=$MinHitFile) {
	    	print "<TR><TD CLASS=AWL>";
			my $nompage=$Aliases{$key};
			if ($nompage eq "") { $nompage=$key; }
			$nompage=substr($nompage,0,$MaxLengthOfURL);
		    if ($ShowLinksOnUrl) { print "<A HREF=\"http://$SiteToAnalyze$key\">$nompage</A>"; }
		    else              	 { print "$nompage"; }
		    my $bredde=int($BarWidth*$_sider_p{$key}/$max_p)+1;
			print "</TD><TD>$_sider_p{$key}</TD><TD CLASS=AWL><IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde HEIGHT=8 ALT=\"$Message[56]: $_sider_p{$key}\" title=\"$Message[56]: $_sider_p{$key}\"></TD></TR>\n";
	  	}
	  	$count++;
	}
	&tab_end;
	
	
	# BY BROWSER
	#----------------------------
	my @sortbrowsers=sort { $SortDir*$_browser_h{$a} <=> $SortDir*$_browser_h{$b} } keys (%_browser_h);
	print "$CENTER<a name=\"BROWSER\"></a><BR>";
	$tab_titre="$Message[21]";
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH>Browser</TH><TH bgcolor=#$color_h width=80>$Message[57]</TH><TH bgcolor=#$color_h width=40>$Message[15]</TH></TR>\n";
	foreach $key (@sortbrowsers) {
		my $p=int($_browser_h{$key}/$TotalHits*1000)/10;
		if ($key eq "Unknown") {
			print "<TR><TD CLASS=AWL><a href=\"$DirCgi$PROG.$Extension?action=unknownrefererbrowser&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$Message[0]</a></TD><TD>$_browser_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
		}
		else {
			print "<TR><TD CLASS=AWL>$BrowsersHash{$key}</TD><TD>$_browser_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
		}
	}
	&tab_end;
	
	
	# BY OS
	#----------------------------
	my @sortos=sort { $SortDir*$_os_h{$a} <=> $SortDir*$_os_h{$b} } keys (%_os_h);
	print "$CENTER<a name=\"OS\"></a><BR>";
	$tab_titre=$Message[59];
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH colspan=2>OS</TH><TH bgcolor=#$color_h width=80>$Message[57]</TH><TH bgcolor=#$color_h width=40>$Message[15]</TH></TR>\n";
	foreach $key (@sortos) {
		my $p=int($_os_h{$key}/$TotalHits*1000)/10;
		if ($key eq "Unknown") {
			print "<TR><TD><IMG SRC=\"$DirIcons\/os\/unknown.png\"></TD><TD CLASS=AWL><a href=\"$DirCgi$PROG.$Extension?action=unknownreferer&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$Message[0]</a></TD><TD>$_os_h{$key}&nbsp;</TD>";
			print "<TD>$p&nbsp;%</TD></TR>\n";
			}
		else {
			my $nameicon = $OSHash{$key}; $nameicon =~ s/\s.*//; $nameicon =~ tr/A-Z/a-z/;
			print "<TR><TD><IMG SRC=\"$DirIcons\/os\/$nameicon.png\"></TD><TD CLASS=AWL>$OSHash{$key}</TD><TD>$_os_h{$key}</TD>";
			print "<TD>$p&nbsp;%</TD></TR>\n";
		}
	}
	&tab_end;
	
	
	# BY REFERENCE
	#---------------------------
	print "$CENTER<a name=\"REFERER\"></a><BR>";
	$tab_titre="$Message[36]";
	&tab_head;
	my @p_p=();
	if ($TotalPages > 0) {
		$p_p[0]=int($_from_p[0]/$TotalPages*1000)/10;
		$p_p[1]=int($_from_p[1]/$TotalPages*1000)/10;
		$p_p[2]=int($_from_p[2]/$TotalPages*1000)/10;
		$p_p[3]=int($_from_p[3]/$TotalPages*1000)/10;
		$p_p[4]=int($_from_p[4]/$TotalPages*1000)/10;
	}
	my @p_h=();
	if ($TotalHits > 0) {
		$p_h[0]=int($_from_h[0]/$TotalHits*1000)/10;
		$p_h[1]=int($_from_h[1]/$TotalHits*1000)/10;
		$p_h[2]=int($_from_h[2]/$TotalHits*1000)/10;
		$p_h[3]=int($_from_h[3]/$TotalHits*1000)/10;
		$p_h[4]=int($_from_h[4]/$TotalHits*1000)/10;
	}
	print "<TR bgcolor=#$color_TableBGRowTitle><TH>$Message[37]</TH><TH bgcolor=#$color_p width=80>$Message[56]</TH><TH bgcolor=#$color_p width=40>$Message[15]</TH><TH bgcolor=#$color_h width=80>$Message[57]</TH><TH bgcolor=#$color_h width=40>$Message[15]</TH></TR>\n";
	print "<TR><TD CLASS=AWL><b>$Message[38]:</b></TD><TD>$_from_p[0]&nbsp;</TD><TD>$p_p[0]&nbsp;%</TD><TD>$_from_h[0]&nbsp;</TD><TD>$p_h[0]&nbsp;%</TD></TR>\n";
	#------- Referrals by search engine
	my @sortsereferrals=sort { $SortDir*$_se_referrals_h{$a} <=> $SortDir*$_se_referrals_h{$b} } keys (%_se_referrals_h);
	print "<TR onmouseover=\"ShowTooltip(13);\" onmouseout=\"HideTooltip(13);\"><TD CLASS=AWL><b>$Message[40] :</b><br>\n";
	print "<TABLE>\n";
	foreach $se (@sortsereferrals) {
		print "<TR><TD CLASS=AWL>- $SearchEnginesHash{$se} </TD><TD align=right>$_se_referrals_h{\"$se\"}</TD></TR>\n";
	}
	print "</TABLE></TD>\n";
	print "<TD valign=top>$_from_p[2]&nbsp;</TD><TD valign=top>$p_p[2]&nbsp;%</TD><TD valign=top>$_from_h[2]&nbsp;</TD><TD valign=top>$p_h[2]&nbsp;%</TD></TR>\n";
	#------- Referrals by external HTML link
	my @sortpagerefs=sort { $SortDir*$_pagesrefs_h{$a} <=> $SortDir*$_pagesrefs_h{$b} } keys (%_pagesrefs_h);
	print "<TR onmouseover=\"ShowTooltip(14);\" onmouseout=\"HideTooltip(14);\"><TD CLASS=AWL><b>$Message[41]:</b><br>\n";
	print "<TABLE>\n";
	my $count=0;
	foreach $from (@sortpagerefs) {
		if (!(($SortDir<0 && $count<$MaxNbOfRefererShown) || ($SortDir>0 && $#sortpagerefs-$MaxNbOfRefererShown < $count))) { last; }
		if ($_pagesrefs_h{$from}>=$MinHitRefer) {
	
			# Show source
			my $lien=$from; $lien=substr($lien,0,$MaxLengthOfURL);
			if ($ShowLinksOnUrl && ($from =~ /^http(s|):\/\//i)) {
				print "<TR><TD CLASS=AWL>- <A HREF=\"$from\">$lien</A></TD><TD>$_pagesrefs_h{$from}</TD></TR>\n";
			} else {
				print "<TR><TD CLASS=AWL>- $lien</TD><TD>$_pagesrefs_h{$from}</TD></TR>\n";
			}
			$count++;
		}
	}
	print "</TABLE></TD>\n";
	print "<TD valign=top>$_from_p[3]&nbsp;</TD><TD valign=top>$p_p[3]&nbsp;%</TD><TD valign=top>$_from_h[3]&nbsp;</TD><TD valign=top>$p_h[3]&nbsp;%</TD></TR>\n";
	#------- Referrals by internal HTML link
	print "<TR><TD CLASS=AWL><b>$Message[42]:</b></TD><TD>$_from_p[4]&nbsp;</TD><TD>$p_p[4]&nbsp;%</TD><TD>$_from_h[4]&nbsp;</TD><TD>$p_h[4]&nbsp;%</TD></TR>\n";
	print "<TR><TD CLASS=AWL><b>$Message[39]:</b></TD><TD>$_from_p[1]&nbsp;</TD><TD>$p_p[1]&nbsp;%</TD><TD>$_from_h[1]&nbsp;</TD><TD>$p_h[1]&nbsp;%</TD></TR>\n";
	&tab_end;
	
	
	# BY SEARCHWORDS
	#----------------------------
	my @sortsearchwords=sort { $SortDir*$_keywords{$a} <=> $SortDir*$_keywords{$b} } keys (%_keywords);
	my $TotalDifferentKeywords=@sortsearchwords;
	print "$CENTER<a name=\"SEARCHWORDS\"></a><BR>";
	$MaxNbOfKeywordsShown = $TotalDifferentKeywords if $MaxNbOfKeywordsShown > $TotalDifferentKeywords;
	$tab_titre="$Message[77] $MaxNbOfKeywordsShown $Message[55] $TotalDifferentKeywords $Message[43]";
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle onmouseover=\"ShowTooltip(15);\" onmouseout=\"HideTooltip(15);\"><TH>$Message[13]</TH><TH bgcolor=#$color_s width=80>$Message[14]</TH><TH bgcolor=#$color_s width=40>$Message[15]</TH></TR>\n";
	my $count=0;
	foreach $key (@sortsearchwords) {
		if ($count>=$MaxNbOfKeywordsShown) { last; }
		my $p=int($_keywords{$key}/$TotalKeywords*1000)/10;
		my $mot = $key; $mot =~ s/\+/ /g;	# Showing $key without +
		print "<TR><TD CLASS=AWL>$mot</TD><TD>$_keywords{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
		$count++;
	}
	my $count=0;my $rest=0;
	foreach $key (@sortsearchwords) {
		if ($count<$MaxNbOfKeywordsShown) { $count++; next; }
		$rest=$rest+$_keywords{$key};
	}
	if ($rest >0) {
		if ($TotalKeywords > 0) { $p=int($rest/$TotalKeywords*1000)/10; }
		print "<TR><TD CLASS=AWL><font color=blue>$Message[30]</TD><TD>$rest</TD>";
		print "<TD>$p&nbsp;%</TD></TR>\n";
	}
	&tab_end;
	
	
	# BY ERRORS
	#----------------------------
	my @sorterrors=sort { $SortDir*$_errors_h{$a} <=> $SortDir*$_errors_h{$b} } keys (%_errors_h);
	print "$CENTER<a name=\"ERRORS\"></a><BR>";
	$tab_titre=$Message[32];
	&tab_head;
	print "<TR bgcolor=#$color_TableBGRowTitle><TH colspan=2>$Message[32]</TH><TH bgcolor=#$color_h width=80>$Message[57]</TH><TH bgcolor=#$color_h width=40>$Message[15]</TH></TR>\n";
	foreach $key (@sorterrors) {
		my $p=int($_errors_h{$key}/$TotalErrors*1000)/10;
		if ($httpcode{$key}) { print "<TR onmouseover=\"ShowTooltip($key);\" onmouseout=\"HideTooltip($key);\">"; }
		else { print "<TR>"; }
		if ($key == 404) { print "<TD><a href=\"$DirCgi$PROG.$Extension?action=notfounderror&site=$SiteToAnalyze&year=$YearRequired&month=$MonthRequired&lang=$Lang\">$key</a></TD>"; }
		else { print "<TD>$key</TD>"; }
		if ($httpcode{$key}) { print "<TD CLASS=AWL>$httpcode{$key}</TD><TD>$_errors_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n"; }
		else { print "<TD CLASS=AWL>Unknown error</TD><TD>$_errors_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n"; }
	}
	&tab_end;
	
	#print "XXXXX Record $NbOfLinesRead{1}, file 1 is: $field[$pos_rc]{1} ; - ; - ; $field[$pos_date]{1} ; TZ; $field[$pos_method]{1} ; $field[$pos_url]{1} ; $field[$pos_code]{1} ; $field[$pos_size]{1} ; $field[$pos_referer]{1} ; $field[$pos_agent]{1}";
	
	&html_end;

}
else {
	if ($UpdateStats) { print "Lines in file: $NbOfLinesRead, found $NbOfNewLinesProcessed new records, $NbOfNewLinesCorrupted corrupted records\n"; }
	else { print "Lines in file: $LastUpdateLinesRead{$choosedkey}, found $LastUpdateNewLinesRead{$choosedkey} new records, $LastUpdateNewLinesCorrupted{$choosedkey} corrupted records\n"; }
}

0;	# Do not remove this line

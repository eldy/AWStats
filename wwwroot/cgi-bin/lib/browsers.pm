# AWSTATS BROWSERS DATABASE
#-------------------------------------------------------
# If you want to add a Browser to extend AWStats database detection capabilities,
# you must add an entry in BrowsersSearchIDOrder and in BrowsersHashIDLib.
#-------------------------------------------------------
# $Revision$ - $Author$ - $Date$

# 2006-05-15 Sean Carlos http://www.antezeta.com/awstats.html 
# 				akregator (rss)
#				AppleSyndication  (rss)
#				BlogBridge http://www.blogbridge.com/ (rss)
#				BonEcho (Firefox 2.0 alpha)
#				FeedTools http://sporkmonger.com/projects/feedtools/ (rss)
#				gnome\-vfs.*neon http://www.webdav.org/neon/
#				GreatNews  http://www.curiostudio.com/ (rss)
#				Gregarius devlog.gregarius.net/docs/ua (rss)
#				hatena rss http://r.hatena.ne.jp/ (rss)
#				Liferea http://liferea.sourceforge.net/ (rss)
#				PubSub-RSS-Reader http://www.pubsub.com/ (rss)
# 2006-05-20 Sean Carlos http://www.antezeta.com/awstats.html
#				Potu Rss-Reader http://www.potu.com/
#				OSSProxy http://www.marketscore.com/FAQ.Aspx

#				
#package AWSUA;


# BrowsersSearchIDOrder
# This list is used to know in which order to search Browsers IDs (Most
# frequent one are first in this list to increase detect speed).
# It contains all matching criteria to search for in log fields.
# Note: Regex IDs are in lower case and ' ' and '+' are changed into '_'
#-------------------------------------------------------
@BrowsersSearchIDOrder = (
# Most frequent standard web browsers are first in this list (except msie, netscape and firefox)
'chrome',
'firebird',
'go!zilla',
'icab',
'konqueror',
'links',
'lynx',
'omniweb',
'opera',
# Other standard web browsers
'22acidownload',
'aol\-iweng',
'amaya',
'amigavoyager',
'aweb',
'bonecho',
'bpftp',
'camino',
'chimera',
'cyberdog',
'dillo',
'doris',
'dreamcast',
'xbox',
'downloadagent',
'ecatch',
'emailsiphon',
'encompass',
'epiphany',
'friendlyspider',
'fresco',
'galeon',
'flashget',
'freshdownload',
'getright',
'leechget',
'netants',
'headdump',
'hotjava',
'ibrowse',
'intergo',
'k\-meleon',
'linemodebrowser',
'lotus\-notes',
'macweb',
'multizilla',
'ncsa_mosaic',
'netcaptor',
'netpositive',
'nutscrape',
'msfrontpageexpress',
'phoenix',
'shiira',               # Must be before safari
'safari',				# Must be after a lot of others (shiira, chrome)
'tzgeturl',
'viking',
'webfetcher',
'webexplorer',
'webmirror',
'webvcr',
# Site grabbers
'teleport',
'webcapture',
'webcopier',
# Media only browsers
'real',
'winamp',				# Works for winampmpeg and winamp3httprdr
'windows\-media\-player',
'audion',
'freeamp',
'itunes',
'jetaudio',
'mint_audio',
'mpg123',
'mplayer',
'nsplayer',
'qts',
'sonique',
'uplayer',
'xaudio',
'xine',
'xmms',
# RSS Readers
'abilon',
'aggrevator',
'akregator',
'applesyndication',
'betanews_reader',
'blogbridge',
'cyndicate',
'feeddemon', 
'feedreader', 
'feedtools',
'greatnews',
'gregarius',
'hatena_rss', 
'jetbrains_omea', 
'liferea',
'netnewswire', 
'newsfire', 
'newsgator', 
'newzcrawler',
'plagger',
'pluck', 
'potu',
'pubsub\-rss\-reader',
'pulpfiction', 
'rssbandit', 
'rssreader',
'rssowl', 
'rss\sxpress',
'rssxpress',
'sage', 
'sharpreader', 
'shrook', 
'straw', 
'syndirella', 
'vienna',
'wizz\srss\snews\sreader',
# PDA/Phonecell browsers
'alcatel',				# Alcatel
'lg\-',					# LG
'mot\-',				# Motorola
'nokia',				# Nokia
'panasonic',			# Panasonic
'philips',				# Philips
'sagem',				# Sagem
'samsung',				# Samsung
'sie\-',				# SIE
'sec\-',				# SonyEricsson
'sonyericsson',			# SonyEricsson
'ericsson',				# Ericsson (must be after sonyericsson)
'mmef',
'mspie',
'wapalizer',
'wapsilon',
'webcollage',
'up\.',					# Works for UP.Browser and UP.Link
# PDA/Phonecell I-Mode browsers
'docomo',
'portalmmm',
# Others (TV)
'webtv',
# Anonymous Proxy Browsers (can be used as grabbers as well...)
'cjb\.net',
'ossproxy',
# Other kind of browsers
'apt',
'analogx_proxy',
'gnome\-vfs',
'neon',
'curl',
'csscheck',
'httrack',
'fdm',
'javaws',
'wget',
'chilkat',
'webdownloader\sfor\sx',
'w3m',
'wdg_validator',
'webreaper',
'webzip',
'staroffice',
'gnus', 
'nikto', 
'microsoft\-webdav\-miniredir', 
'microsoft\sdata\saccess\sinternet\spublishing\sprovider\scache\smanager',
'microsoft\sdata\saccess\sinternet\spublishing\sprovider\sdav',
'microsoft\sdata\saccess\sinternet\spublishing\sprovider\sprotocol\sdiscovery',
'POE\-Component\-Client\-HTTP',
'mozilla',				# Must be at end because a lot of browsers contains mozilla in string
'libwww',				# Must be at end because some browser have both 'browser id' and 'libwww'
'lwp'
);

# BrowsersHashIDLib
# List of browser's name ('browser id in lower case', 'browser text')
#---------------------------------------------------------------
%BrowsersHashIDLib = (
# Common web browsers text
'msie','MS Internet Explorer',
'netscape','Netscape',
'firefox','Firefox',
'svn', 'Subversion client', 

'chrome','Google Chrome',
'firebird','Firebird (Old Firefox)',
'go!zilla','Go!Zilla',
'icab','iCab',
'konqueror','Konqueror',
'links','Links',
'lynx','Lynx',
'omniweb','OmniWeb',
'opera','Opera',
# Other standard web browsers
'22acidownload','22AciDownload',
'aol\-iweng','AOL-Iweng',
'amaya','Amaya',
'amigavoyager','AmigaVoyager',
'aweb','AWeb',
'bonecho','<a href="http://www.mozilla.org/projects/bonecho/" title="Browser home page [new window]" target="_blank">BonEcho (Firefox 2.0 development)</a>',
'bpftp','BPFTP',
'camino','Camino',
'chimera','Chimera (Old Camino)',
'cyberdog','Cyberdog',
'dillo','Dillo',
'doris','Doris (for Symbian)',
'dreamcast','Dreamcast',
'xbox', 'XBoX',
'downloadagent','DownloadAgent',
'ecatch', 'eCatch',
'emailsiphon','EmailSiphon',
'encompass','Encompass',
'epiphany','Epiphany',
'friendlyspider','FriendlySpider',
'fresco','ANT Fresco',
'galeon','Galeon',
'flashget','FlashGet',
'freshdownload','FreshDownload',
'getright','GetRight',
'leechget','LeechGet',
'netants','NetAnts',
'headdump','HeadDump',
'hotjava','Sun HotJava',
'ibrowse','iBrowse',
'intergo','InterGO',
'k\-meleon','K-Meleon',
'linemodebrowser','W3C Line Mode Browser',
'lotus\-notes','Lotus Notes web client',
'macweb','MacWeb',
'multizilla','MultiZilla',
'ncsa_mosaic','NCSA Mosaic',
'netcaptor','NetCaptor',
'netpositive','NetPositive',
'nutscrape', 'Nutscrape',
'msfrontpageexpress','MS FrontPage Express',
'phoenix','Phoenix',
'shiira','Shiira',
'safari','Safari',
'tzgeturl','TzGetURL',
'viking','Viking',
'webfetcher','WebFetcher',
'webexplorer','IBM-WebExplorer',
'webmirror','WebMirror',
'webvcr','WebVCR',
# Site grabbers
'teleport','TelePort Pro',
'webcapture','Acrobat Webcapture',
'webcopier', 'WebCopier',
# Media only browsers
'real','Real player or compatible (media player)',
'winamp','WinAmp (media player)',				# Works for winampmpeg and winamp3httprdr
'windows\-media\-player','Windows Media Player (media player)',
'audion','Audion (media player)',
'freeamp','FreeAmp (media player)',
'itunes','Apple iTunes (media player)',
'jetaudio','JetAudio (media player)',
'mint_audio','Mint Audio (media player)',
'mpg123','mpg123 (media player)',
'mplayer','The Movie Player (media player)',
'nsplayer','NetShow Player (media player)',
'qts','Quicktime',
'sonique','Sonique (media player)',
'uplayer','Ultra Player (media player)',
'xaudio','Some XAudio Engine based MPEG player (media player)',
'xine','Xine, a free multimedia player (media player)',
'xmms','XMMS (media player)',
# RSS Readers
'abilon','Abilon (RSS Reader)',
'aggrevator', 'Aggrevator (RSS Reader)',
'akregator','<a href="http://akregator.sourceforge.net/" title="Browser home page [new window]" target="_blank">Akregator (RSS Reader)</a>',  
'applesyndication','<a href="http://www.apple.com/macosx/features/safari/" title="Browser home page [new window]" target="_blank">AppleSyndication (RSS Reader)</a>',
'betanews_reader','Betanews Reader (RSS Reader)',
'blogbridge','<a href="http://www.blogbridge.com/" title="Browser home page [new window]" target="_blank">BlogBridge (RSS Reader)</a>',
'cyndicate','Cyndicate (RSS Reader)',
'feeddemon', 'FeedDemon (RSS Reader)',
'feedreader', 'FeedReader (RSS Reader)',
'feedtools','<a href="http://sporkmonger.com/projects/feedtools/" title="Browser home page [new window]" target="_blank">FeedTools (RSS Reader)</a>',
'greatnews','<a href="http://www.curiostudio.com/" title="Browser home page [new window]" target="_blank">GreatNews (RSS Reader)</a>',
'gregarius','<a href="http://devlog.gregarius.net/docs/ua" title="Browser home page [new window]" target="_blank">Gregarius (RSS Reader)</a>',
'hatena_rss','<a href="http://r.hatena.ne.jp/" title="Browser home page [new window]" target="_blank">Hatena (RSS Reader)</a>',
'jetbrains_omea', 'Omea (RSS Reader)',
'liferea','<a href="http://liferea.sourceforge.net/" title="Browser home page [new window]" target="_blank">Liferea (RSS Reader)</a>',
'netnewswire', 'NetNewsWire (RSS Reader)',
'newsfire', 'NewsFire (RSS Reader)',
'newsgator', 'NewsGator (RSS Reader)',
'newzcrawler', 'NewzCrawler (RSS Reader)',
'plagger', 'Plagger (RSS Reader)',
'pluck', 'Pluck (RSS Reader)',
'potu','<a href="http://www.potu.com/" title="Potu Rss-Reader home page [new window]" target="_blank">Potu (RSS Reader)</a>',
'pubsub\-rss\-reader','<a href="http://www.pubsub.com/" title="Browser home page [new window]" target="_blank">PubSub (RSS Reader)</a>',
'pulpfiction', 'PulpFiction (RSS Reader)',
'rssbandit', 'RSS Bandit (RSS Reader)',
'rssreader', 'RssReader (RSS Reader)',
'rssowl', 'RSSOwl (RSS Reader)',
'rss\sxpress','RSS Xpress (RSS Reader)',
'rssxpress','RSSXpress (RSS Reader)',
'sage', 'Sage (RSS Reader)',
'sharpreader', 'SharpReader (RSS Reader)',
'shrook', 'Shrook (RSS Reader)',
'straw', 'Straw (RSS Reader)',
'syndirella', 'Syndirella (RSS Reader)',
'vienna', '<a href="http://www.opencommunity.co.uk/vienna2.php" title="Vienna RSS-Reader [new window]" target="_blank">Vienna (RSS Reader)</a>',
'wizz\srss\snews\sreader','Wizz RSS News Reader (RSS Reader)',
# PDA/Phonecell browsers
'alcatel','Alcatel Browser (PDA/Phone browser)',
'lg\-','LG (PDA/Phone browser)',
'mot\-','Motorola Browser (PDA/Phone browser)',
'nokia','Nokia Browser (PDA/Phone browser)',
'panasonic','Panasonic Browser (PDA/Phone browser)',
'philips','Philips Browser (PDA/Phone browser)',
'sagem','Sagem (PDA/Phone browser)',
'samsung','Samsung (PDA/Phone browser)',
'sie\-','SIE (PDA/Phone browser)',
'sec\-','Sony/Ericsson (PDA/Phone browser)',
'sonyericsson','Sony/Ericsson Browser (PDA/Phone browser)',
'ericsson','Ericsson Browser (PDA/Phone browser)',			# Must be after SonyEricsson
'mmef','Microsoft Mobile Explorer (PDA/Phone browser)',
'mspie','MS Pocket Internet Explorer (PDA/Phone browser)',
'wapalizer','WAPalizer (PDA/Phone browser)',
'wapsilon','WAPsilon (PDA/Phone browser)',
'webcollage','WebCollage (PDA/Phone browser)',
'up\.','UP.Browser (PDA/Phone browser)',					# Works for UP.Browser and UP.Link
# PDA/Phonecell I-Mode browsers
'docomo','I-Mode phone (PDA/Phone browser)',
'portalmmm','I-Mode phone (PDA/Phone browser)',
# Others (TV)
'webtv','WebTV browser',
# Anonymous Proxy Browsers (can be used as grabbers as well...)
'cjb\.net','<a href="http://proxy.cjb.net/" title="Browser home page [new window]" target="_blank">CJB.NET Proxy</a>',
'ossproxy','<a href="http://www.marketscore.com/FAQ.Aspx" title="OSSProxy home page [new window]" target="_blank">OSSProxy</a>',
# Other kind of browsers
'apt','Debian APT',
'analogx_proxy','AnalogX Proxy',
'gnome\-vfs', 'Gnome FileSystem Abstraction library', 
'neon', 'Neon HTTP and WebDAV client library', 
'curl','Curl',
'csscheck','WDG CSS Validator',
'httrack','HTTrack',
'fdm','<a href="http://www.freedownloadmanager.org/" title="Browser home page [new window]" target="_blank">FDM Free Download Manager</a>',
'javaws','Java Web Start',
'wget','Wget',
'chilkat', 'Chilkat',
'webdownloader\sfor\sx','Downloader for X',
'w3m','w3m',
'wdg_validator','WDG HTML Validator',
'webreaper','WebReaper',
'webzip','WebZIP',
'staroffice','StarOffice',
'gnus', 'Gnus Network User Services',
'nikto', 'Nikto Web Scanner', 
'microsoft\-webdav\-miniredir', 'Microsoft Data Access Component Internet Publishing Provider',
'microsoft\sdata\saccess\sinternet\spublishing\sprovider\scache\smanager', 'Microsoft Data Access Component Internet Publishing Provider Cache Manager',
'microsoft\sdata\saccess\sinternet\spublishing\sprovider\sdav', 'Microsoft Data Access Component Internet Publishing Provider DAV',
'microsoft\sdata\saccess\sinternet\spublishing\sprovider\sprotocol\sdiscovery', 'Microsoft Data Access Component Internet Publishing Provider Protocol Discovery',
'POE\-Component\-Client\-HTTP','HTTP user-agent for POE (portable networking framework for Perl)',
'mozilla','Mozilla',
'libwww','LibWWW',
'lwp','LibWWW-perl'
);


# BrowsersHashAreGrabber
# Put here an entry for each browser in BrowsersSearchIDOrder that are grabber
# browsers.
#---------------------------------------------------------------------------
%BrowsersHereAreGrabbers = (
'teleport','1',
'webcapture','1',
'webcopier','1',
'curl','1',
'fdm','1',
'httrack','1',
'webreaper','1',
'wget','1',
'webdownloader\sfor\sx','1',
'webzip','1'
);


# BrowsersHashIcon
# Each Browsers Search ID is associated to a string that is the name of icon
# file for this browser.
#---------------------------------------------------------------------------
%BrowsersHashIcon = (
# Standard web browsers
'msie','msie',
'netscape','netscape',
'firefox','firefox',
'svn','subversion',
'chrome','chrome', 
'firebird','phoenix',
'go!zilla','gozilla',
'icab','icab',
'konqueror','konqueror',
'lynx','lynx',
'omniweb','omniweb',
'opera','opera',
# Other standard web browsers
'amaya','amaya',
'amigavoyager','amigavoyager',
'avantbrowser','avant',
'aweb','aweb',
'bonecho','firefox',
'bpftp','bpftp',
'camino','chimera',
'chimera','chimera',
'cyberdog','cyberdog',
'dillo','dillo',
'doris','doris',
'dreamcast','dreamcast',
'xbox', 'winxbox',
'ecatch','ecatch',
'encompass','encompass',
'epiphany','epiphany',
'fresco','fresco',
'galeon','galeon',
'flashget','flashget',
'freshdownload','freshdownload',
'getright','getright',
'leechget','leechget',
'hotjava','hotjava',
'ibrowse','ibrowse',
'k\-meleon','kmeleon',
'lotus\-notes','lotusnotes',
'macweb','macweb',
'multizilla','multizilla',
'msfrontpageexpress','fpexpress',
'ncsa_mosaic','ncsa_mosaic',
'netpositive','netpositive',
'phoenix','phoenix',
'safari','safari',
# Site grabbers
'teleport','teleport',
'webcapture','adobe',
'webcopier','webcopier',
# Media only browsers
'real','real',
'winamp','mediaplayer',				# Works for winampmpeg and winamp3httprdr
'windows\-media\-player','mplayer',
'audion','mediaplayer',
'freeamp','mediaplayer',
'itunes','mediaplayer',
'jetaudio','mediaplayer',
'mint_audio','mediaplayer',
'mpg123','mediaplayer',
'mplayer','mediaplayer',
'nsplayer','netshow',
'qts','mediaplayer',
'sonique','mediaplayer',
'uplayer','mediaplayer',
'xaudio','mediaplayer',
'xine','mediaplayer',
'xmms','mediaplayer',
# PDA/Phonecell browsers
'alcatel','pdaphone',				# Alcatel
'lg\-','pdaphone',                  # LG
'ericsson','pdaphone',				# Ericsson
'mot\-','pdaphone',					# Motorola
'nokia','pdaphone',					# Nokia
'panasonic','pdaphone',				# Panasonic
'philips','pdaphone',				# Philips
'sagem','pdaphone',                 # Sagem
'samsung','pdaphone',               # Samsung
'sie\-','pdaphone',                 # SIE
'sec\-','pdaphone',                 # Sony/Ericsson
'sonyericsson','pdaphone',			# Sony/Ericsson
'mmef','pdaphone',
'mspie','pdaphone',
'wapalizer','pdaphone',
'wapsilon','pdaphone',
'webcollage','pdaphone',
'up\.','pdaphone',					# Works for UP.Browser and UP.Link
# PDA/Phonecell I-Mode browsers
'docomo','pdaphone',
'portalmmm','pdaphone',
# Others (TV)
'webtv','webtv',
# Anonymous Proxy Browsers (can be used as grabbers as well...)
'cjb\.net','cjbnet',
# RSS Readers
'abilon', 'abilon',
'aggrevator', 'rss',
'akregator', 'rss',
'applesyndication', 'rss',
'betanews_reader','rss',
'blogbridge','rss',
'feeddemon', 'rss',
'feedreader', 'rss',
'feedtools', 'rss',
'greatnews', 'rss',
'gregarius', 'rss',
'hatena_rss', 'rss',
'jetbrains_omea', 'rss',
'liferea', 'rss',
'netnewswire', 'rss',
'newsfire', 'rss',
'newsgator', 'rss',
'newzcrawler', 'rss',
'plagger', 'rss',
'pluck', 'rss',
'potu', 'rss',
'pubsub\-rss\-reader', 'rss',
'pulpfiction', 'rss',
'rssbandit', 'rss',
'rssreader', 'rss',
'rssowl', 'rss',
'rss\sxpress','rss',
'rssxpress','rss',
'sage', 'rss',
'sharpreader', 'rss',
'shrook', 'rss',
'straw', 'rss',
'syndirella', 'rss',
'vienna', 'rss',
'wizz\srss\snews\sreader','wizz',
# Other kind of browsers
'apt','apt',
'analogx_proxy','analogx',
'microsoft\-webdav\-miniredir','frontpage',
'microsoft\sdata\saccess\sinternet\spublishing\sprovider\scache\smanager','frontpage',
'microsoft\sdata\saccess\sinternet\spublishing\sprovider\sdav','frontpage',
'microsoft\sdata\saccess\sinternet\spublishing\sprovider\sprotocol\sdiscovery','frontpage',
'gnome\-vfs', 'gnome', 
'neon','neon', 
'javaws','java',
'webzip','webzip',
'webreaper','webreaper',
'httrack','httrack',
'staroffice','staroffice',
'gnus', 'gnus',
'mozilla','mozilla'
);

# Source for this is http://developer.apple.com/internet/safari/uamatrix.html
%BrowsersSafariBuildToVersionHash = 
(
    '48' => '0.8',
    '51' => '0.8.1',
    '60' => '0.8.2',
    '73' => '0.9',
    '74' => '1.0b2',
    '85' => '1.0',
    '85.5' => '1.0',
    '85.7' => '1.0.2',
    '85.8' => '1.0.3',
    '85.8.1' => '1.0.3',
    '100' => '1.1',
    '100.1' => '1.1.1',
    '125.7' => '1.2.2',
    '125.8' => '1.2.2',
    '125.9' => '1.2.3',
    '125.11' => '1.2.4',
    '125.12' => '1.2.4',
    '312' => '1.3',
    '312.3' => '1.3.1',
    '312.3.1' => '1.3.1',
    '412' => '2.0',
    '412.2' => '2.0',
    '412.2.2' => '2.0',
    '412.5' => '2.0.1',
    '416.12' => '2.0.2'
);


1;


# Browsers examples by engines
#
# -- Mosaic --
# MSIE		4.0  	Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt; KITV4 Wanadoo; KITV5 Wanadoo)
#
# -- Gecko Netscape --
# Netscape	4.05	Mozilla/4.05 [fr]C-SYMPA (Win95; I)
# Netscape	4.7     Mozilla/4.7 [fr] (Win95; I)
# Netscape	6.0		Mozilla/5.0 (Macintosh; N; PPC; fr-FR; m18) Gecko/20001108 Netscape6/6.0
# Netscape	7.02	Mozilla/5.0 (Platform; Security; OS-or-CPU; Localization; rv:1.0.2) Gecko/20030208 Netscape/7.02 
#
# -- Gecko others --
# Mozilla	1.3		Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.3) Gecko/20030312
# Firefox	0.9		Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.5a) Gecko/20030728 Mozilla Firefox/0.9.1
# Firebird,Phoenix,Galeon,AmiZilla,Dino
# Autre             Mozilla/3.01 (compatible;)
#
# -- Opera --
# Opera		6.03	Mozilla/3.0 (Windows 98; U) Opera 6.03  [en]
# Opera		5.12    Mozilla/3.0 (Windows 98; U) Opera 5.12  [en]
# Opera		3.21    Opera 3.21, Windows:
#
# -- KHTML --
# Safari
# Konqueror
#

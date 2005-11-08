# AWSTATS BROWSERS DATABASE
#-------------------------------------------------------
# If you want to add a Browser to extend AWStats database detection capabilities,
# you must add an entry in BrowsersSearchIDOrder and in BrowsersHashIDLib.
#-------------------------------------------------------
# $Revision$ - $Author$ - $Date$


#package AWSUA;


# BrowsersSearchIDOrder
# This list is used to know in which order to search Browsers IDs (Most
# frequent one are first in this list to increase detect speed).
# It contains all matching criteria to search for in log fields.
# Note: Regex IDs are in lower case and ' ' and '+' are changed into '_'
#-------------------------------------------------------
@BrowsersSearchIDOrder = (
# Most frequent standard web browsers are first in this list (except msie, netscape and firefox)
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
'bpftp',
'camino',
'chimera',
'cyberdog',
'dillo',
'dreamcast',
'downloadagent',
'ecatch',
'emailsiphon',
'encompass',
'epiphany',
'friendlyspider',
'fresco',
'galeon',
'getright',
'headdump',
'hotjava',
'ibrowse',
'intergo',
'javaws',
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
'safari',
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
'nsplayer',
'sonique',
'uplayer',
'xmms',
'xaudio',
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
'ericsson',				# Ericsson (must be after sonyericsson
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
# RSS Readers
'aggrevator', 
'feeddemon', 
'feedreader', 
'jetbrains_omea_reader', 
'netnewswire', 
'newsfire', 
'newsgator', 
'newzcrawler',
'pluck', 
'pulpfiction', 
'rssbandit', 
'rssreader',
'rssowl', 
'sage', 
'sharpreader', 
'shrook', 
'straw', 
'syndirella', 
# Other kind of browsers
'apt',
'curl',
'csscheck',
'wget',
'w3m',
'w3c_css_validator',
'w3c_validator',
'wdg_validator',
'webzip',
'staroffice',
'mozilla',				# Must be at end because a lot of browsers contains mozilla in string
'libwww'				# Must be at end because some browser have both 'browser id' and 'libwww'
);

# BrowsersHashIDLib
# List of browser's name ('browser id in lower case', 'browser text')
#---------------------------------------------------------------
%BrowsersHashIDLib = (
# Common web browsers text
'msie','MS Internet Explorer',
'netscape','Netscape',
'firefox','Firefox',

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
'bpftp','BPFTP',
'camino','Camino',
'chimera','Chimera (Old Camino)',
'cyberdog','Cyberdog',
'dillo','Dillo',
'dreamcast','Dreamcast',
'downloadagent','DownloadAgent',
'ecatch', 'eCatch',
'emailsiphon','EmailSiphon',
'encompass','Encompass',
'epiphany','Epiphany',
'friendlyspider','FriendlySpider',
'fresco','ANT Fresco',
'galeon','Galeon',
'getright','GetRight',
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
'webcapture','Acrobat',
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
'nsplayer','NetShow Player (media player)',
'sonique','Sonique (media player)',
'uplayer','Ultra Player (media player)',
'xmms','XMMS (media player)',
'xaudio','Some XAudio Engine based MPEG player (media player)',
# PDA/Phonecell browsers
'alcatel','Alcatel Browser (PDA/Phone browser)',
'lg\-','LG (PDA/Phone browser)',
'ericsson','Ericsson Browser (PDA/Phone browser)',
'mot\-','Motorola Browser (PDA/Phone browser)',
'nokia','Nokia Browser (PDA/Phone browser)',
'panasonic','Panasonic Browser (PDA/Phone browser)',
'philips','Philips Browser (PDA/Phone browser)',
'sagem','Sagem (PDA/Phone browser)',
'samsung','Samsung (PDA/Phone browser)',
'sie\-','SIE (PDA/Phone browser)',
'sec\-','Sony/Ericsson (PDA/Phone browser)',
'sonyericsson','Sony/Ericsson Browser (PDA/Phone browser)',
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
# RSS Readers
'aggrevator', 'Aggrevator (RSS Reader)',
'feeddemon', 'FeedDemon (RSS Reader)',
'feedreader', 'FeedReader (RSS Reader)',
'jetbrains_omea_reader', 'Omea Reader (RSS Reader)',
'netnewswire', 'NetNewsWire (RSS Reader)',
'newsfire', 'NewsFire (RSS Reader)',
'newsgator', 'NewsGator (RSS Reader)',
'newzcrawler', 'NewzCrawler (RSS Reader)',
'pluck', 'Pluck (RSS Reader)',
'pulpfiction', 'PulpFiction (RSS Reader)',
'rssbandit', 'RSS Bandit (RSS Reader)',
'rssreader', 'RssReader (RSS Reader)',
'rssowl', 'RSSOwl (RSS Reader)',
'sage', 'Sage (RSS Reader)',
'sharpreader', 'SharpReader (RSS Reader)',
'shrook', 'Shrook (RSS Reader)',
'straw', 'Straw (RSS Reader)',
'syndirella', 'Syndirella (RSS Reader)',
# Other kind of browsers
'apt','Debian APT',
'curl','Curl',
'csscheck','WDG CSS Validator',
'javaws','Java Web Start',
'wget','Wget',
'w3m','w3m',
'w3c_css_validator','W3C CSS Validator',
'w3c_validator','W3C HTML Validator',
'wdg_validator','WDG HTML Validator',
'webzip','WebZIP',
'staroffice','StarOffice',
'mozilla','Mozilla',
'libwww','LibWWW',
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
'wget','1'
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
'bpftp','bpftp',
'camino','chimera',
'chimera','chimera',
'cyberdog','cyberdog',
'dillo','dillo',
'dreamcast','dreamcast',
'ecatch','ecatch',
'encompass','encompass',
'epiphany','epiphany',
'fresco','fresco',
'galeon','galeon',
'getright','getright',
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
'real','mediaplayer',
'winamp','mediaplayer',				# Works for winampmpeg and winamp3httprdr
'windows\-media\-player','mediaplayer',
'audion','mediaplayer',
'freeamp','mediaplayer',
'itunes','mediaplayer',
'jetaudio','mediaplayer',
'mint_audio','mediaplayer',
'mpg123','mediaplayer',
'nsplayer','mediaplayer',
'sonique','mediaplayer',
'uplayer','mediaplayer',
'xmms','mediaplayer',
'xaudio','mediaplayer',
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
# RSS Readers
'aggrevator', 'rss',
'feeddemon', 'rss',
'feedreader', 'rss',
'jetbrains_omea_reader', 'rss',
'netnewswire', 'rss',
'newsfire', 'rss',
'newsgator', 'rss',
'newzcrawler', 'rss',
'pluck', 'rss',
'pulpfiction', 'rss',
'rssbandit', 'rss',
'rssreader', 'rss',
'rssowl', 'rss',
'sage', 'rss',
'sharpreader', 'rss',
'shrook', 'rss',
'straw', 'rss',
'syndirella', 'rss',
# Other kind of browsers
'apt','apt',
'webzip','webzip',
'staroffice','staroffice',
'mozilla','mozilla'
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

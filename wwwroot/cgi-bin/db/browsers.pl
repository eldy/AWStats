# AWSTATS BROWSERS DATABASE
#--------------------------
# Last update: 2002-02-25

# If you want to add a Browser to extend AWStats database detection capabilities,
# you must add an entry in BrowsersSearchIDOrder and in BrowsersHashIDLib.


# BrowsersSearchIDOrder
# This list is used to know in which order to search Browsers IDs (Most
# frequent one are first in this list to increase detect speed).
# It contains all matching criteria to search for in log fields.
# Note: Browsers IDs are in lower case and ' ' and '+' are changed into '_'
#-------------------------------------------------------
@BrowsersSearchIDOrder = (
# Most frequent standard web browsers are first in this list
"icab",
"go!zilla",
"konqueror",
"links",
"lynx",
"omniweb",
"opera",
"wget",
# Other standard web browsers
"22acidownload",
"aol\\-iweng",
"amaya",
"amigavoyager",
"antfresco",
"bpftp",
"cyberdog",
"dreamcast",
"downloadagent",
"ecatch",
"emailsiphon",
"friendlyspider",
"getright",
"headdump",
"hotjava",
"ibrowse",
"intergo",
"linemodebrowser",
"lotus-notes",
"macweb",
"ncsa_mosaic",
"netpositive",
"nutscrape",
"msfrontpageexpress",
"tzgeturl",
"viking",
"webfetcher",
"webexplorer",
"webmirror",
"webvcr",
# Site grabbers
"teleport",
"webcapture",
"webcopier",
# Music only browsers
"real",
"winamp",				# Works for winampmpeg and winamp3httprdr
"windows-media-player",
"audion",
"freeamp",
"itunes",
"jetaudio",
"mint_audio",
"mpg123",
"nsplayer",
"sonique",
"uplayer",
"xmms",
"xaudio",
# PDA/Phonecell browsers
"mmef",
"mspie",
"up\.",					# Works for UP.Browser and UP.Link
"wapalizer",
"wapsilon",
"webcollage",
"alcatel",
"nokia",
# Others (TV)
"webtv",
# Other kind of browsers
"csscheck",
"w3m",
"w3c_css_validator",
"w3c_validator",
"wdg_validator",
"webzip",
"libwww",				# Must be at end because some browser have both "browser id" and "libwww"
"staroffice"
);

# BrowsersHashAreGrabber
# Put here an entry for each browser in BrowsersSearchIDOrder that are grabber
# browsers.
#---------------------------------------------------------------------------
%BrowsersHereAreGrabbers = (
"teleport","1",
"webcapture","1",
"webcopier","1",,
);

# BrowsersHashIcon
# Each Browsers Search ID is associated to a string that is the name of icon
# file for this OS.
#---------------------------------------------------------------------------
%BrowsersHashIcon = (
# Standard web browsers
"msie","msie",
"netscape","netscape",
"icab","notavailable",
"go!zilla","notavailable",
"konqueror","konqueror",
"links","notavailable",
"lynx","lynx",
"omniweb","omniweb",
"opera","opera",
"wget","notavailable",
"22acidownload","notavailable",
"aol\\-iweng","notavailable",
"amaya","notavailable",
"amigavoyager","notavailable",
"antfresco","notavailable",
"bpftp","notavailable",
"cyberdog","notavailable",
"dreamcast","dreamcast",
"downloadagent","notavailable",
"ecatch","notavailable",
"emailsiphon","notavailable",
"friendlyspider","notavailable",
"getright","notavailable",
"headdump","notavailable",
"hotjava","notavailable",
"ibrowse","notavailable",
"intergo","notavailable",
"linemodebrowser","notavailable",
"lotus-notes","notavailable",
"macweb","notavailable",
"ncsa_mosaic","notavailable",
"netpositive","notavailable",
"nutscrape","notavailable",
"msfrontpageexpress","notavailable",
"tzgeturl","notavailable",
"viking","notavailable",
"webfetcher","notavailable",
"webexplorer","notavailable",
"webmirror","notavailable",
"webvcr","notavailable",
# Site grabbers
"teleport","notavailable",
"webcapture","notavailable",
"webcopier","notavailable",
# Music only browsers
"real","mediaplayer",
"winamp","mediaplayer",				# Works for winampmpeg and winamp3httprdr
"windows-media-player","mediaplayer",
"audion","mediaplayer",
"freeamp","mediaplayer",
"itunes","mediaplayer",
"jetaudio","mediaplayer",
"mint_audio","mediaplayer",
"mpg123","mediaplayer",
"nsplayer","mediaplayer",
"sonique","mediaplayer",
"uplayer","mediaplayer",
"xmms","mediaplayer",
"xaudio","mediaplayer",
# PDA/Phonecell browsers
"mmef","pdaphone",
"mspie","pdaphone",
"up\.","pdaphone",					# Works for UP.Browser and UP.Link
"wapalizer","pdaphone",
"wapsilon","pdaphone",
"webcollage","pdaphone",
"alcatel","pdaphone",
"nokia","pdaphone",
# Others (TV)
"webtv","webtv",
# Other kind of browsers
"csscheck","notavailable",
"w3m","notavailable",
"w3c_css_validator","notavailable",
"w3c_validator","notavailable",
"wdg_validator","notavailable",
"webzip","notavailable",
"libwww","notavailable",			# Must be at end because some browser have both "browser id" and "libwww"
"staroffice","notavailable"
);


# Browser name list ("browser id in lower case", "browser text")
#---------------------------------------------------------------
%BrowsersHashIDLib = (
# Common web browsers (IE and Netscape must not be in this list)
"icab","iCab",
"go!zilla","Go!Zilla",
"konqueror","Konqueror",
"links","Links",
"lynx","Lynx",
"omniweb","OmniWeb",
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
"intergo","InterGO",
"linemodebrowser","W3C Line Mode Browser",
"lotus-notes","Lotus Notes web client",
"macweb","MacWeb",
"ncsa_mosaic","NCSA Mosaic",
"netpositive","NetPositive",
"nutscrape", "Nutscrape",
"msfrontpageexpress","MS FrontPage Express",
"tzgeturl","TZGETURL",
"viking","Viking",
"webfetcher","WebFetcher",
"webexplorer","IBM-WebExplorer",
"webmirror","WebMirror",
"webvcr","WebVCR",
# Site grabbers
"teleport","TelePort Pro (site grabber)",
"webcapture","Acrobat (site grabber)",
# Music only browsers
"real","RealAudio or compatible (media player)",
"winamp","WinAmp (media player)",				# Works for winampmpeg and winamp3httprdr
"windows-media-player","Windows Media Player (media player)",
"audion","Audion (media player)",
"freeamp","FreeAmp (media player)",
"itunes","Apple iTunes (media player)",
"jetaudio","JetAudio (media player)",
"mint_audio","Mint Audio (media player)",
"mpg123","mpg123 (media player)",
"nsplayer","NetShow Player (media player)",
"sonique","Sonique (media player)",
"uplayer","Ultra Player (media player)",
"xmms","XMMS (media player)",
"xaudio","Some XAudio Engine based MPEG player (media player)",
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
"webtv","WebTV browser",
# Other kind of browsers
"csscheck","WDG CSS Validator",
"w3m","w3m",
"w3c_css_validator","W3C CSS Validator",
"w3c_validator","W3C HTML Validator",
"wdg_validator","WDG HTML Validator",
"webcopier", "WebCopier",
"webzip","WebZIP",
"libwww","LibWWW",
"staroffice","StarOffice"
);

1;

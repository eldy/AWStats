# AWSTATS BROWSERS DATABASE
#--------------------------
# Last update: 2002-02-09

# If you want to add a Browser to extend AWStats database detection capabilities,
# you must add an entry in BrowsersArrayID and in BrowsersOSHashIDLib.



# BrowsersArrayID
# Matching criteria to search in log after changing ' ' or '+' into '_' "
# This searching ID are searched in declare order.
#-------------------------------------------------------
@BrowsersArrayID = (
# Most frequent browsers should be first in this list
"icab",
"go!zilla",
"konqueror",
"links",
"lynx",
"omniweb",
"opera",
"wget",

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
"webcopier",
"wdg_validator",
"webzip",
"libwww",				# Must be at end because some browser have both "browser id" and "libwww"
"staroffice"
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

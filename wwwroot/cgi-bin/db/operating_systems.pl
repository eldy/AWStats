# AWSTATS OPERATING SYSTEMS DATABASE
#------------------------------------
# Last update: 2001-11-10

# If you want to add an OS to extend AWStats database detection capabilities,
# you must add an entry in OSArrayID, in OSHashID and in OS Hash Lib.


# OSArrayID
# This list is used to know in which order to search Operating System IDs.
# It contains all matching criteria to search for in log fields.
# Note: OS IDs are in lower case and ' ' and '+' are changed into '_'
#-------------------------------------------------------------------------
@OSArrayID	= (
# Windows OS family
"windows_xp","windows_nt_5\.1",		# Must be before windows_nt_5
"windows_me","win_9x_4\.9",			# Must be before windows_98
"windows2000","windows_2000","windows_nt_5",
"winnt","windows_nt","windows-nt","win32",
"win98","windows_98","windows98",
"win95","windows_95",
"win16","windows_3","windows;i;16",	# This works for windows_31 and windows_3.1
"wince","windows_ce",
# Macintosh OS family
"mac_p",							# This works for mac_ppc and mac_powerpc
"mac_68",							# This works for mac_6800 and mac_68k
"macppc",
"macweb",
"macintosh",
# Other famous OS
"beos",
"os/2",
"amiga",
# Unix like OS
"linux",
"aix",
"sunos",
"irix",
"osf",
"hp-ux",
"netbsd",
"bsdi",
"freebsd",
"openbsd",
"unix",
# Miscellanous OS
"cp/m",
"crayos",
"dreamcast",
"riscos",
"webtv"
);

# OSHashID
# Each OS detect string is associated to an unique ID string
# that is also the name of icon file for this OS
#-----------------------------------------------------------
%OSHashID	= (
# Windows OS family
"windows_xp","winxp","windows_nt_5\.1","winxp",
"windows_me","winme","win_9x_4\.9","winme",
"windows2000","win2000","windows_2000","win2000","windows_nt_5","win2000",
"winnt","winnt","windows_nt","winnt","windows-nt","winnt","win32","winnt",
"win98","win98","windows_98","win98","windows98","win98",
"win95","win95","windows_95","win95",
"win16","win16","windows_3","win16","windows;i;16","win16",
"wince","wince","windows_ce","wince",
# Macintosh OS family
"mac_p","macintosh","mac_68","macintosh","macppc","macintosh","macweb","macintosh","macintosh","macintosh",
# Other famous OS
"beos","beos",
"os/2","os/2",
"amiga","amigaos",
# Unix like OS
"linux","linux",
"aix","aix",
"sunos","sunos",
"irix","irix",
"osf","osf",
"hp-ux","hp-ux",
"netbsd","netbsd",
"bsdi","bsdi",
"freebsd","freebsd",
"openbsd","openbsd",
"unix","unix",
# Miscellanous OS
"cp/m","cp/m",
"crayos","crayos",
"dreamcast","dreamcast",
"riscos","riscos",
"webtv","webtv"
);

# OS name list ("os unique id in lower case","os clear text")
# Each unique ID string is associated to a label
#-----------------------------------------------------------
%OSHashLib      = (
# Windows family OS
"winxp","Windows XP",
"winme","Windows Me",
"win2000","Windows 2000",
"winnt","Windows NT",
"win98","Windows 98",
"win95","Windows 95",
"win16","Windows 3.xx",
"wince","Windows CE",
# Macintosh OS
"macintosh","Mac OS",
# Other famous OS
"beos","BeOS",
"os/2","Warp OS/2",
"amigaos","AmigaOS",
# Unix like OS
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
"unix","Unknown Unix system",
# Miscellanous OS
"cp/m","CPM",
"crayos","CrayOS",
"dreamcast","Dreamcast",
"riscos","Acorn RISC OS",
"webtv","WebTV"
);


1;


# Informations from microsoft for detecting windows version
#  Windows 95 retail, OEM     4.00.950                     7/11/95
#  Windows 95 retail SP1      4.00.950A                    7/11/95-12/31/95
#  OEM Service Release 2      4.00.1111* (4.00.950B)       8/24/96
#  OEM Service Release 2.1    4.03.1212-1214* (4.00.950B)  8/24/96-8/27/97  
#  OEM Service Release 2.5    4.03.1214* (4.00.950C)       8/24/96-11/18/97
#  Windows 98 retail, OEM     4.10.1998                    5/11/98
#  Windows 98 Second Edition  4.10.2222A                   4/23/99
#  Windows Me                 4.90.3000 

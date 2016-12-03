# AWSTATS OPERATING SYSTEMS DATABASE
#-------------------------------------------------------
# If you want to add an OS to extend AWStats database detection capabilities,
# you must add an entry in OSSearchIDOrder, in OSHashID and in OSHashLib.
#-------------------------------------------------------

# 2005-08-19 Sean Carlos http://www.antezeta.com/awstats.html
#              - added specific Linux distributions in addition to 
#              the generic Linux.  
#              Included documentation link to Distribution home pages.
#              - added links for each operating systems.

# 2013-01-08 Joe CC Ho - added iOS, Windows 8 and Windows Phone.

#package AWSOS;

# Relocated from main file for easier editing
%OSFamily = (
	'win'   => 'Windows',
	'mac'   => 'Macintosh',
	'ios'   => 'iOS',
	'linux' => 'Linux',
	'bsd'   => 'BSD'
);

# OSSearchIDOrder
# This list is used to know in which order to search Operating System IDs
# (Most frequent one are first in this list to increase detect speed).
# It contains all matching criteria to search for in log fields.
# Note: OS IDs are in lower case and '_', ' ' and '+' are changed into '[_+ ]'
#-------------------------------------------------------------------------
@OSSearchIDOrder	= (
# Windows OS family
'windows[_+ ]?2005', 'windows[_+ ]nt[_+ ]6\.0',
'windows[_+ ]?2008', 'windows[_+ ]nt[_+ ]6\.1', # Must be before windows_nt_6
'windows[_+ ]?2012', 'windows[_+ ]nt[_+ ]6\.2', # Must be before windows_nt_6 = windows 8
'windows[_+ ]nt[_+ ]6\.3', # Must be before windows_nt_6 = windows 8.1 
'windows[_+ ]nt[_+ ]10', # Windows 10
'windows[_+ ]?vista', 'windows[_+ ]nt[_+ ]6',
'windows[_+ ]?2003','windows[_+ ]nt[_+ ]5\.2',	# Must be before windows_nt_5
'windows[_+ ]xp','windows[_+ ]nt[_+ ]5\.1',		# Must be before windows_nt_5
'windows[_+ ]me','win[_+ ]9x',					# Must be before windows_98
'windows[_+ ]?2000','windows[_+ ]nt[_+ ]5',
'windows[_+ ]phone',
'winnt','windows[_+ \-]?nt','win32',
'win(.*)98',
'win(.*)95',
'win(.*)16','windows[_+ ]3',					# This works for windows_31 and windows_3.1
'win(.*)ce',
# iOS family
#'iphone[_+ ]os',  #Must be Before Mac OS Family
#'ipad[_+ ]os',  #Must be Before Mac OS Family
#'ipod[_+ ]os',  #Must be Before Mac OS Family
'iphone',
'ipad',
'ipod',
# Macintosh OS family
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]12',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]11',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]10',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]9',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]8',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]7',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]6',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]5',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]4',
'mac[_+ ]os[_+ ]x',
'mac[_+ ]?p',									# This works for macppc and mac_ppc and mac_powerpc
'mac[_+ ]68',									# This works for mac_6800 and mac_68k
'macweb',
'macintosh',
# Linux family
'linux(.*)android',
'linux(.*)asplinux',
'linux(.*)centos',
'linux(.*)debian',
'linux(.*)fedora',
'linux(.*)gentoo',
'linux(.*)mandr',
'linux(.*)momonga',
'linux(.*)pclinuxos',
'linux(.*)red[_+ ]hat',
'linux(.*)suse',
'linux(.*)ubuntu',
'linux(.*)vector',
'linux(.*)vine',
'linux(.*)white\sbox',
'linux(.*)zenwalk',
'linux',
'android',
'debian',
# Hurd family
'gnu.hurd',
# BSDs family
'bsdi',
'gnu.kfreebsd',								    # Must be before freebsd
'freebsd',
'openbsd',
'netbsd',
'dragonfly',
# Other Unix, Unix-like
'aix',
'sunos',
'irix',
'osf',
'hp\-ux',
'unix',
'x11',
'gnome\-vfs',
# Other famous OS
'beos',
'os/2',
'amiga',
'atari',
'vms',
'commodore',
'qnx',
'inferno',
'palmos',
'syllable',
# Miscellaneous OS
'blackberry',
'cp/m',
'crayos',
'dreamcast',
'risc[_+ ]?os',
'symbian',
'webtv',
'playstation',
'xbox',
'wii',
'vienna',
'newsfire',
'applesyndication',
'akregator',
'plagger',
'syndirella',
'j2me',
'java',
'microsoft',									# Pushed down to prevent mis-identification
'msie[_+ ]',									# by other OS spoofers.
'ms[_+ ]frontpage',
'windows'
);


# OSHashID
# Each OS Search ID is associated to a string that is the AWStats id and
# also the name of icon file for this OS.
#--------------------------------------------------------------------------
%OSHashID	= (
# Windows OS family
'windows[_+ ]?2005','winlong','windows[_+ ]nt[_+ ]6\.0','winlong',
'windows[_+ ]?2008','win2008','windows[_+ ]nt[_+ ]6\.1','win7',
'windows[_+ ]?2012','win2012','windows[_+ ]nt[_+ ]6\.2','win8',
'windows[_+ ]nt[_+ ]6\.3','win8.1',
'windows[_+ ]nt[_+ ]10','win10',
'windows[_+ ]?vista','winvista','windows[_+ ]nt[_+ ]6','winvista',
'windows[_+ ]?2003','win2003','windows[_+ ]nt[_+ ]5\.2','win2003',
'windows[_+ ]xp','winxp','windows[_+ ]nt[_+ ]5\.1','winxp', 'syndirella', 'winxp',
'windows[_+ ]me','winme','win[_+ ]9x','winme',
'windows[_+ ]?2000','win2000','windows[_+ ]nt[_+ ]5','win2000',
'winnt','winnt','windows[_+ \-]?nt','winnt','win32','winnt',
'windows[_+ ]phone','winphone',
'win(.*)98','win98',
'win(.*)95','win95',
'win(.*)16','win16','windows[_+ ]3','win16',
'win(.*)ce','wince',
'microsoft','winunknown',
'msie[_+ ]','winunknown',
'ms[_+ ]frontpage','winunknown',
# iOS family
#'iphone[_+ ]os','ios_iphone',       #Must be Before Mac OS Family
#'ipad[_+ ]os','ios_ipad',       #Must be Before Mac OS Family
#'ipod[_+ ]os','ios_ipod',       #Must be Before Mac OS Family
'iphone','ios_iphone', #Must be Before Mac OS Family
'ipad','ios_ipad', #Must be Before Mac OS Family
'ipod','ios_ipod',  #Must be Before Mac OS Family
# Macintosh OS family
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]12','macosx12',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]11','macosx11',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]10','macosx10',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]9','macosx9',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]8','macosx8',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]7','macosx7',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]6','macosx6',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]5','macosx5',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]4','macosx4',
'mac[_+ ]os[_+ ]x','macosx', 'vienna', 'macosx', 'newsfire', 'macosx', 'applesyndication', 'macosx',
'mac[_+ ]?p','macintosh','mac[_+ ]68','macintosh','macweb','macintosh','macintosh','macintosh',
# Linux family (linuxyyy)
'linux(.*)android','linuxandroid',
'linux(.*)asplinux','linuxasplinux',
'linux(.*)centos','linuxcentos',
'linux(.*)debian','linuxdebian',
'linux(.*)fedora','linuxfedora',
'linux(.*)gentoo','linuxgentoo',
'linux(.*)mandr','linuxmandr',
'linux(.*)momonga','linuxmomonga',
'linux(.*)pclinuxos','linuxpclinuxos',
'linux(.*)red[_+ ]hat','linuxredhat',
'linux(.*)suse','linuxsuse',
'linux(.*)ubuntu','linuxubuntu',
'linux(.*)vector','linuxvector',
'linux(.*)vine','linuxvine',
'linux(.*)white\sbox','linuxwhitebox',
'linux(.*)zenwalk','linuxzenwalk',
'linux','linux',
'android','linuxandroid',
'debian','linuxdebian',
# Hurd family
'gnu.hurd','gnu',
# BSDs family (bsdyyy)
'bsdi','bsdi',
'gnu.kfreebsd','bsdkfreebsd',						    # Must be before freebsd
'freebsd','bsdfreebsd',
'openbsd','bsdopenbsd',
'netbsd','bsdnetbsd',
'dragonflybsd','bsddflybsd',
# Other Unix, Unix-like
'aix','aix',
'sunos','sunos',
'irix','irix',
'osf','osf',
'hp\-ux','hp\-ux',
'unix','unix',
'x11','unix',
'gnome\-vfs','unix',
'plagger', 'unix',
# Other famous OS
'beos','beos',
'os/2','os/2',
'amiga','amigaos',
'atari','atari',
'vms','vms',
'commodore','commodore',
'j2me', 'j2me',
'java', 'java',
'qnx','qnx',
'inferno','inferno',
'palmos','palmos',
'syllable','syllable',
# Miscellaneous OS
'akregator', 'linux',
'blackberry','blackberry',
'cp/m','cp/m',
'crayos','crayos',
'dreamcast','dreamcast',
'risc[_+ ]?os','riscos',
'symbian','symbian',
'webtv','webtv',
'playstation', 'psp',
'xbox', 'winxbox',
'wii', 'wii',
'windows','winunknown'
);

# OS name list ('os unique id in lower case','os clear text')
# Each unique ID string is associated to a label
#-----------------------------------------------------------
%OSHashLib      = (
# Windows family OS
'win10','<a href="http://www.microsoft.com/windows10/" title="Windows 10 home page [new window]" target="_blank">Windows 10</a>',
'win8.1','<a href="http://www.microsoft.com/windows8/" title="Windows 8.1 home page [new window]" target="_blank">Windows 8.1</a>',
'win8','<a href="http://www.microsoft.com/windows8/" title="Windows 8 home page [new window]" target="_blank">Windows 8</a>',
'win7','<a href="http://windows.microsoft.com/en-US/windows7/products/home/" title="Windows 7 home page [new window]" target="_blank">Windows 7</a>',
'winlong','<a href="http://www.microsoft.com/windows/" title="Windows Vista home page [new window]" target="_blank">Windows Vista (LongHorn)</a>',
'win2008','<a href="http://www.microsoft.com/windowsserver2008/" title="Windows 2008 home page [new window]" target="_blank">Windows 2008</a>',
'win2012','<a href="http://www.microsoft.com/en-us/server-cloud/windows-server/2012-default.aspx/" title="Windows Server 2012 home page [new window]" target="_blank">Windows Server 2012</a>',
'winvista','<a href="http://www.microsoft.com/windowsvista/" title="Windows Vista home page [new window]" target="_blank">Windows Vista</a>',
'win2003','<a href="http://www.microsoft.com/windowsserver2003/" title="Windows 2003 home page [new window]" target="_blank">Windows 2003</a>',
'winxp','<a href="http://www.microsoft.com/windowsxp/" title="Windows XP home page [new window]" target="_blank">Windows XP</a>',
'winme','<a href="http://support.microsoft.com/ph/6519/" title="Windows ME support page [new window]" target="_blank">Windows ME</a>',
'win2000','<a href="http://support.microsoft.com/ph/1131" title="Windows 2000 support page [new window]" target="_blank">Windows 2000</a>',
'winnt','<a href="http://support.microsoft.com/default.aspx?pr=ntw40" title="Windows NT support page [new window]" target="_blank">Windows NT</a>',
'win98','<a href="http://support.microsoft.com/w98" title="Windows 98 support page [new window]" target="_blank">Windows 98</a>',
'win95','<a href="http://support.microsoft.com/ph/7864" title="Windows 95 support page [new window]" target="_blank">Windows 95</a>',
'win16','<a href="http://www.microsoft.com/windows/WinHistoryDesktop.mspx#E1B" title="Windows 3.xx history page [new window]" target="_blank">Windows 3.xx</a>',
'wince','<a href="http://www.microsoft.com/windowsmobile/" title="Windows Mobile home page [new window]" target="_blank">Windows Mobile</a>',
'winphone','<a href="http://www.microsoft.com/windowsphone/" title="Windows Phone home page [new window]" target="_blank">Windows Phone</a>',
'winunknown','Windows (unknown version)',
'winxbox','<a href="http://www.xbox.com/" title="Microsoft XBOX home page [new window]" target="_blank">Microsoft XBOX</a>',
# Macintosh OS
'macosx12','<a href="http://www.apple.com/macosx/" title="Mac OS X home page [new window]" target="_blank">Mac OS X 10.12 Sierra</a>',
'macosx11','<a href="http://www.apple.com/macosx/" title="Mac OS X home page [new window]" target="_blank">Mac OS X 10.11 El Capitan</a>',
'macosx10','<a href="http://www.apple.com/macosx/" title="Mac OS X home page [new window]" target="_blank">Mac OS X 10.10 Yosemite</a>',
'macosx9','<a href="http://www.apple.com/macosx/" title="Mac OS X home page [new window]" target="_blank">Mac OS X 10.9 Mavericks</a>',
'macosx8','<a href="http://www.apple.com/macosx/" title="Mac OS X home page [new window]" target="_blank">Mac OS X 10.8 Mountain Lion</a>',
'macosx7','<a href="http://www.apple.com/macosx/" title="Mac OS X home page [new window]" target="_blank">Mac OS X 10.7 Lion</a>',
'macosx6','<a href="http://www.apple.com/macosx/" title="Mac OS X home page [new window]" target="_blank">Mac OS X 10.6 Snow Leopard</a>',
'macosx5','<a href="http://www.apple.com/macosx/" title="Mac OS X home page [new window]" target="_blank">Mac OS X 10.5 Leopard</a>',
'macosx4','<a href="http://www.apple.com/macosx/" title="Mac OS X home page [new window]" target="_blank">Mac OS X 10.4 Tiger</a>',
'macosx','<a href="http://www.apple.com/macosx/" title="Mac OS X home page [new window]" target="_blank">Mac OS X others</a>',
'macintosh','<a href="http://www.apple.com/" title="Mac OS home page [new window]" target="_blank">Mac OS</a>',
# Linux
'linuxandroid','<a href="http://code.google.com/android/" title="Google Android home page [new window]" target="_blank">Google Android</a>',
'linuxasplinux','<a href="http://www.asplinux.ru/" title="ASPLinux home page [new window]" target="_blank">ASPLinux</a>',
'linuxcentos','<a href="http://www.centos.org/" title="Centos home page [new window]" target="_blank">Centos</a>',
'linuxdebian','<a href="http://www.debian.org/" title="Debian home page [new window]" target="_blank">Debian</a>',
'linuxfedora','<a href="http://fedora.redhat.com/" title="Fedora home page [new window]" target="_blank">Fedora</a>',
'linuxgentoo','<a href="http://www.gentoo.org/" title="Gentoo home page [new window]" target="_blank">Gentoo</a>',
'linuxmandr','<a href="http://www.mandriva.com/" title="Mandriva (former Mandrake) home page [new window]" target="_blank">Mandriva (or Mandrake)</a>',
'linuxmomonga','<a href="http://www.momonga-linux.org/" title="Momonga Linux home page [new window]" target="_blank">Momonga Linux</a>',
'linuxpclinuxos','<a href="http://www.pclinuxos.com/" title="PCLinuxOS home page [new window]" target="_blank">PCLinuxOS</a>',
'linuxredhat','<a href="http://www.redhat.com/" title="Red Hat home page [new window]" target="_blank">Red Hat</a>',
'linuxsuse','<a href="http://www.novell.com/linux/suse/" title="Suse home page [new window]" target="_blank">Suse</a>',
'linuxubuntu','<a href="http://www.ubuntulinux.org/" title="Ubuntu home page [new window]" target="_blank">Ubuntu</a>',
'linuxvector','<a href="http://vectorlinux.com/" title="VectorLinux home page [new window]" target="_blank">VectorLinux</a>',
'linuxvine','<a href="http://www.vinelinux.org/index-en.html" title="Vine Linux home page [new window]" target="_blank">Vine Linux</a>',
'linuxwhitebox','<a href="http://whiteboxlinux.org/" title="White Box Linux home page [new window]" target="_blank">White Box Linux</a>',
'linuxzenwalk','<a href="http://www.zenwalk.org/" title="Zenwalk GNU Linux home page [new window]" target="_blank">Zenwalk GNU Linux</a>',
'linux','<a href="http://www.distrowatch.com/" title="Linux DistroWatch home page. Useful if you find the associated user agent string in your logs. [new window]" target="_blank">Linux (Unknown/unspecified)</a>',
'linux','GNU Linux (Unknown or unspecified distribution)',
# Hurd
'gnu','<a href="http://www.gnu.org/software/hurd/hurd.html" title="GNU Hurd home page [new window]" target="_blank">GNU Hurd</a>',
# BSDs
'bsdi','<a href="http://en.wikipedia.org/wiki/BSDi" title="BSDi home page [new window]" target="_blank">BSDi</a>',
'bsdkfreebsd','<a href="http://www.debian.org/ports/kfreebsd-gnu/" title="Debian GNU/kFreeBSD" target="_blank">GNU/kFreeBSD</a>',
'freebsd','<a href="http://www.freebsd.org/" title="FreeBSD home page [new window]" target="_blank">FreeBSD</a>',    # For backard compatibility
'bsdfreebsd','<a href="http://www.freebsd.org/" title="FreeBSD home page [new window]" target="_blank">FreeBSD</a>',
'openbsd','<a href="http://www.openbsd.org/" title="OpenBSD home page [new window]" target="_blank">OpenBSD</a>',    # For backard compatibility
'bsdopenbsd','<a href="http://www.openbsd.org/" title="OpenBSD home page [new window]" target="_blank">OpenBSD</a>',
'netbsd','<a href="http://www.netbsd.org/" title="NetBSD home page [new window]" target="_blank">NetBSD</a>', # For backard compatibility
'bsdnetbsd','<a href="http://www.netbsd.org/" title="NetBSD home page [new window]" target="_blank">NetBSD</a>',
'bsddflybsd','<a href="http://www.dragonflybsd.org/" title="DragonFlyBSD home page [new window]" target="_blank">DragonFlyBSD</a>',
# Other Unix, Unix-like
'aix','<a href="http://www-1.ibm.com/servers/aix/" title="Aix home page [new window]" target="_blank">Aix</a>',
'sunos','<a href="http://www.sun.com/software/solaris/" title="Sun Solaris home page [new window]" target="_blank">Sun Solaris</a>',
'irix','<a href="http://www.sgi.com/products/software/irix/" title="Irix home page [new window]" target="_blank">Irix</a>',
'osf','<a href="http://www.tru64.org/" title="OSF Unix home page [new window]" target="_blank">OSF Unix</a>',
'hp\-ux','<a href="http://www.hp.com/products1/unix/operating/" title="HP UX home page [new window]" target="_blank">HP UX</a>',
'unix','Unknown Unix system',
# iOS
'ios_iphone','<a href="http://www.apple.com/iphone/ios" title="Apple iPhone home page [new window]" target="_blank">iOS (iPhone)</a>',
'ios_ipad','<a href="http://www.apple.com/ipad/ios" title="Apple iPad home page [new window]" target="_blank">iOS (iPad)</a>',
'ios_ipod','<a href="http://www.apple.com/ipod/ios" title="Apple iPod home page [new window]" target="_blank">iOS (iPod)</a>',
# Other famous OS
'beos','<a href="http://www.beincorporated.com/" title="BeOS home page [new window]" target="_blank">BeOS</a>',
'os/2','<a href="http://www.ibm.com/software/os/warp/" title="OS/2 home page [new window]" target="_blank">OS/2</a>',
'amigaos','<a href="http://www.amiga.com/amigaos/" title="AmigaOS home page [new window]" target="_blank">AmigaOS</a>',
'atari','<a href="http://www.atarimuseum.com/computers/computers.html" title="Atari home page [new window]" target="_blank">Atari</a>',
'vms','<a href="http://h71000.www7.hp.com/" title="VMS home page [new window]" target="_blank">VMS</a>',
'commodore','<a href="http://en.wikipedia.org/wiki/Commodore_64" title="Commodore 64 wikipedia page [new window]" target="_blank">Commodore 64</a>',
'j2me','<a href="http://mobile.java.com/" title="Java Mobile home page [new window]" target="_blank">Java Mobile</a>',
'java','<a href="http://www.java.com/" title="Java home page [new window]" target="_blank">Java</a>',
'qnx','<a href="http://www.qnx.com/products/neutrino_rtos/" title="QNX home page [new window]" target="_blank">QNX</a>',
'inferno','<a href="http://www.vitanuova.com/inferno/" title="Inferno home page [new window]" target="_blank">Inferno</a>',
'palmos','<a href="http://www.palm.com/" title="Palm OS home page [new window]" target="_blank">Palm OS</a>',
'syllable','<a href="http://www.syllable.org/" title="Syllable home page [new window]" target="_blank">Syllable</a>',
# Miscellaneous OS
'blackberry','BlackBerry',
'cp/m','<a href="http://www.digitalresearch.biz/CPM.HTM" title="CP/M home page [new window]" target="_blank">CP/M</a>',
'crayos','<a href="http://www.cray.com/" title="CrayOS home page [new window]" target="_blank">CrayOS</a>',
'dreamcast','<a href="http://www.sega.com/" title="Dreamcast home page [new window]" target="_blank">Dreamcast</a>',
'riscos','<a href="http://www.riscos.com/" title="RISC OS home page [new window]" target="_blank">RISC OS</a>',
'symbian','<a href="http://www.symbian.com/" title="Symbian OS home page [new window]" target="_blank">Symbian OS</a>',
'webtv','<a href="http://www.webtv.com/" title="WebTV home page [new window]" target="_blank">WebTV</a>',
'psp', '<a href="http://www.playstation.com/" title="Sony PlayStation home page [new window]" target="_blank">Sony PlayStation</a>',
'wii', '<a href="http://wii.opera.com/" title="Opera for Nintendo Wii home page [new window]" target="_blank">Nintendo Wii</a>'
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

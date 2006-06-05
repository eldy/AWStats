# AWSTATS OPERATING SYSTEMS DATABASE
#-------------------------------------------------------
# If you want to add an OS to extend AWStats database detection capabilities,
# you must add an entry in OSSearchIDOrder, in OSHashID and in OSHashLib.
#-------------------------------------------------------
# $Revision$ - $Author$ - $Date$

# 2005-08-19 Sean Carlos http://www.antezeta.com/awstats.html
#              - added specific Linux distributions in addition to 
#              the generic Linux.  
#              Included documentation link to Distribution home pages.
#              - added links for each operating systems.

#package AWSOS;


# OSSearchIDOrder
# This list is used to know in which order to search Operating System IDs
# (Most frequent one are first in this list to increase detect speed).
# It contains all matching criteria to search for in log fields.
# Note: OS IDs are in lower case and ' ' and '+' are changed into '_'
#-------------------------------------------------------------------------
@OSSearchIDOrder	= (
# Windows OS family
'windows[_+ ]?2005', 'windows[_+ ]nt[_+ ]6\.0',
'windows[_+ ]?2003','windows[_+ ]nt[_+ ]5\.2',	# Must be before windows_nt_5
'windows[_+ ]xp','windows[_+ ]nt[_+ ]5\.1',		# Must be before windows_nt_5
'windows[_+ ]me','win[_+ ]9x',					# Must be before windows_98
'windows[_+ ]?2000','windows[_+ ]nt[_+ ]5',
'winnt','windows[_+ \-]?nt','win32',
'win(.*)98',
'win(.*)95',
'win(.*)16','windows[_+ ]3',					# This works for windows_31 and windows_3.1
'win(.*)ce',
# Macintosh OS family
'mac[_+ ]os[_+ ]x',
'mac[_+ ]?p',									# This works for macppc and mac_ppc and mac_powerpc
'mac[_+ ]68',									# This works for mac_6800 and mac_68k
'macweb',
'macintosh',
# Linux family
'linux(.*)centos',
'linux(.*)debian',
'linux(.*)fedora',
'linux(.*)mandr',
'linux(.*)red[_+ ]hat',
'linux(.*)suse',
'linux(.*)ubuntu',
'linux',
# Hurd family
'gnu.hurd',
# BSDs family
'bsdi',
'gnu.kfreebsd',								    # Must be before freebsd
'freebsd',
'openbsd',
'netbsd',
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
# Miscellanous OS
'cp/m',
'crayos',
'dreamcast',
'risc[_+ ]?os',
'symbian',
'webtv',
'playstation[_+ ]portable',
'xbox'
);


# OSHashID
# Each OS Search ID is associated to a string that is the AWStats id and
# also the name of icon file for this OS.
#--------------------------------------------------------------------------
%OSHashID	= (
# Windows OS family
'windows[_+ ]?2005','winlong','windows[_+ ]nt[_+ ]6\.0','winlong',
'windows[_+ ]?2003','win2003','windows[_+ ]nt[_+ ]5\.2','win2003',
'windows[_+ ]xp','winxp','windows[_+ ]nt[_+ ]5\.1','winxp',
'windows[_+ ]me','winme','win[_+ ]9x','winme',
'windows[_+ ]?2000','win2000','windows[_+ ]nt[_+ ]5','win2000',
'winnt','winnt','windows[_+ \-]?nt','winnt','win32','winnt',
'win(.*)98','win98',
'win(.*)95','win95',
'win(.*)16','win16','windows[_+ ]3','win16',
'win(.*)ce','wince',
# Macintosh OS family
'mac[_+ ]os[_+ ]x','macosx',
'mac[_+ ]?p','macintosh','mac[_+ ]68','macintosh','macweb','macintosh','macintosh','macintosh',
# Linux family (linuxyyy)
'linux(.*)centos','linuxcentos',
'linux(.*)debian','linuxdebian',
'linux(.*)fedora','linuxfedora',
'linux(.*)mandr','linuxmandr',
'linux(.*)red[_+ ]hat','linuxredhat',
'linux(.*)suse','linuxsuse',
'linux(.*)ubuntu','linuxubuntu',
'linux','linux',
# Hurd family
'gnu.hurd','gnu',
# BSDs family (bsdyyy)
'bsdi','bsdi',
'gnu.kfreebsd','bsdkfreebsd',						    # Must be before freebsd
'freebsd','bsdfreebsd',
'openbsd','bsdopenbsd',
'netbsd','bsdnetbsd',
# Other Unix, Unix-like
'aix','aix',
'sunos','sunos',
'irix','irix',
'osf','osf',
'hp\-ux','hp\-ux',
'unix','unix',
'x11','unix',
'gnome\-vfs','unix',
# Other famous OS
'beos','beos',
'os/2','os/2',
'amiga','amigaos',
'atari','atari',
'vms','vms',
'commodore','commodore',
# Miscellanous OS
'cp/m','cp/m',
'crayos','crayos',
'dreamcast','dreamcast',
'risc[_+ ]?os','riscos',
'symbian','symbian',
'webtv','webtv',
'playstation[_+ ]portable', 'psp',
'xbox', 'winxbox',
);

# OS name list ('os unique id in lower case','os clear text')
# Each unique ID string is associated to a label
#-----------------------------------------------------------
%OSHashLib      = (
# Windows family OS
'winlong','<a href="http://www.microsoft.com/windows/" title="Windows Vista home page [new window]" target="_blank">Windows Vista (Longhorn)</a>',
'win2003','<a href="http://www.microsoft.com/windowsserver2003/" title="Windows 2003 home page [new window]" target="_blank">Windows 2003</a>',
'winxp','<a href="http://www.microsoft.com/windowsxp/" title="Windows XP home page [new window]" target="_blank">Windows XP</a>',
'winme','<a href="http://www.microsoft.com/windowsme/" title="Windows Me home page [new window]" target="_blank">Windows Me</a>',
'win2000','<a href="http://www.microsoft.com/windows2000/" title="Windows 2000 home page [new window]" target="_blank">Windows 2000</a>',
'winnt','<a href="http://www.microsoft.com/ntworkstation/" title="Windows NT home page [new window]" target="_blank">Windows NT</a>',
'win98','<a href="http://www.microsoft.com/windows98/" title="Windows 98 home page [new window]" target="_blank">Windows 98</a>',
'win95','<a href="http://www.microsoft.com/windows95/" title="Windows 95 home page [new window]" target="_blank">Windows 95</a>',
'win16','<a href="http://www.microsoft.com/" title="Windows 3.xx home page [new window]" target="_blank">Windows 3.xx</a>',
'wince','<a href="http://www.microsoft.com/windowsmobile/" title="Windows CE home page [new window]" target="_blank">Windows CE</a>',
'winxbox','<a href="http://www.xbox.com/en-US/hardware/xbox/" title="Microsoft XBOX home page [new window]" target="_blank">Microsoft XBOX</a>',
 # Macintosh OS
'macosx','<a href="http://www.apple.com/macosx/" title="Mac OS X home page [new window]" target="_blank">Mac OS X</a>',
'macintosh','<a href="http://www.apple.com/" title="Mac OS home page [new window]" target="_blank">Mac OS</a>',
# Linux
'linuxcentos','<a href="http://www.centos.org/" title="Centos home page [new window]" target="_blank">Centos</a>',
'linuxdebian','<a href="http://www.debian.org/" title="Debian home page [new window]" target="_blank">Debian</a>',
'linuxfedora','<a href="http://fedora.redhat.com/" title="Fedora home page [new window]" target="_blank">Fedora</a>',
'linuxmandr','<a href="http://www.mandriva.com/" title="Mandriva (former Mandrake) home page [new window]" target="_blank">Mandriva (or Mandrake)</a>',
'linuxredhat','<a href="http://www.redhat.com/" title="Red Hat home page [new window]" target="_blank">Red Hat</a>',
'linuxsuse','<a href="http://www.novell.com/linux/suse/" title="Suse home page [new window]" target="_blank">Suse</a>',
'linuxubuntu','<a href="http://www.ubuntulinux.org/" title="Ubuntu home page [new window]" target="_blank">Ubuntu</a>',
'linux','<a href="http://www.distrowatch.com/" title="Linux DistroWatch home page. Useful if you find the associated user agent string in your logs. [new window]" target="_blank">Linux (Unknown/unspecified)</a>',
'linux','GNU Linux (Unknown or unspecified distribution)',
# Hurd
'gnu','<a href="www.gnu.org/software/hurd/hurd.html" title="GNU Hurd home page [new window]" target="_blank">GNU Hurd</a>',
# BSDs
'bsdi','<a href="http://en.wikipedia.org/wiki/BSDi" title="BSDi home page [new window]" target="_blank">BSDi</a>',
'bsdkfreebsd','GNU/kFreeBSD',
'freebsd','<a href="http://www.freebsd.org/" title="FreeBSD home page [new window]" target="_blank">FreeBSD</a>',    # For backard compatibility
'bsdfreebsd','<a href="http://www.freebsd.org/" title="FreeBSD home page [new window]" target="_blank">FreeBSD</a>',
'openbsd','<a href="http://www.openbsd.org/" title="OpenBSD home page [new window]" target="_blank">OpenBSD</a>',    # For backard compatibility
'bsdopenbsd','<a href="http://www.openbsd.org/" title="OpenBSD home page [new window]" target="_blank">OpenBSD</a>',
'netbsd','<a href="http://www.netbsd.org/" title="NetBSD home page [new window]" target="_blank">NetBSD</a>', # For backard compatibility
'bsdnetbsd','<a href="http://www.netbsd.org/" title="NetBSD home page [new window]" target="_blank">NetBSD</a>',
# Other Unix, Unix-like
'aix','<a href="http://www-1.ibm.com/servers/aix/" title="Aix home page [new window]" target="_blank">Aix</a>',
'sunos','<a href="http://www.sun.com/software/solaris/" title="Sun Solaris home page [new window]" target="_blank">Sun Solaris</a>',
'irix','<a href="http://www.sgi.com/products/software/irix/" title="Irix home page [new window]" target="_blank">Irix</a>',
'osf','<a href="http://www.tru64.org/" title="OSF Unix home page [new window]" target="_blank">OSF Unix</a>',
'hp\-ux','<a href="http://www.hp.com/products1/unix/operating/" title="HP UX home page [new window]" target="_blank">HP UX</a>',
'unix','Unknown Unix system',
# Other famous OS
'beos','<a href="http://www.beincorporated.com/" title="BeOS home page [new window]" target="_blank">BeOS</a>',
'os/2','<a href="http://www.ibm.com/software/os/warp/" title="OS/2 home page [new window]" target="_blank">OS/2</a>',
'amigaos','<a href="http://www.amiga.com/amigaos/" title="AmigaOS home page [new window]" target="_blank">AmigaOS</a>',
'atari','<a href="http://www.atarimuseum.com/computers/computers.html" title="Atari home page [new window]" target="_blank">Atari</a>',
'vms','<a href="http://h71000.www7.hp.com/" title="VMS home page [new window]" target="_blank">VMS</a>',
'commodore','<a href="http://en.wikipedia.org/wiki/Commodore_64" title="Commodore 64 wikipedia page [new window]" target="_blank">Commodore 64</a>',
# Miscellanous OS
'cp/m','<a href="http://www.digitalresearch.biz/CPM.HTM" title="CPM home page [new window]" target="_blank">CPM</a>',
'crayos','<a href="http://www.cray.com/" title="CrayOS home page [new window]" target="_blank">CrayOS</a>',
'dreamcast','<a href="http://www.sega.com/" title="Dreamcast home page [new window]" target="_blank">Dreamcast</a>',
'riscos','<a href="http://www.riscos.com/" title="RISC OS home page [new window]" target="_blank">RISC OS</a>',
'symbian','<a href="http://www.symbian.com/" title="Symbian OS home page [new window]" target="_blank">Symbian OS</a>',
'webtv','<a href="http://www.webtv.com/" title="WebTV home page [new window]" target="_blank">WebTV</a>',
'psp', '<a href="http://www.playstation.jp/psp/" title="Sony PlayStation Portable home page [new window]" target="_blank">Sony PlayStation Portable</a>',
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

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
  'win'     => 'Windows',
  'mac'     => 'Macintosh',
  'ios'     => 'iOS',
  'android' => 'Android',
  'linux'   => 'Linux',
  'bsd'     => 'BSD'
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
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]15',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]14',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]13',
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
# Android family
'android[_+ ]10',       # Android 10
'android[_+ ]9',        # Pie
'android[_+ ]8',        # Oreo
'android[_+ ]7',        # Nougat
'android[_+ ]6',        # Marshmallow
'android[_+ ]5',        # Lollipop
'android[_+ ]4[_\.]4',  # KitKat
'android[_+ ]4[_\.]0',  # Ice Cream Sandwich
'android[_+ ]4',        # Jelly Bean, Must be after K & I
'android[_+ ]3',        # Honeycomb
'android[_+ ]2[_\.]3',  # Gingerbread
'android[_+ ]2[_\.]2',  # Froyo
'android[_+ ]2',        # Eclair, Must be after F & G
'android[_+ ]1[_\.]6',  # Donut
'android[_+ ]1[_\.]5',  # Cupcake
'linux(.*)android',
'android',
# Linux family
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
'centos',
'debian',
'gentoo',
'ubuntu',
'linux',
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
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]15','macosx15',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]14','macosx14',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]13','macosx13',
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
# Android family (androidyyy)
'android[_+ ]10','android10',              # Android 10
'android[_+ ]9','androidpie',              # Pie
'android[_+ ]8','androidoreo',              # Oreo
'android[_+ ]7','androidnougat',            # Nougat
'android[_+ ]6','androidmarshmallow',       # Marshmallow
'android[_+ ]5','androidlollipop',          # Lollipop
'android[_+ ]4[_\.]4','androidkitkat',      # KitKat
'android[_+ ]4[_\.]0','androidics',         # Ice Cream Sandwich
'android[_+ ]4','androidjellybean',         # Jelly Bean, Must be after K & I
'android[_+ ]3','androidhoneycomb',         # Honeycomb
'android[_+ ]2[_\.]3','androidgingerbread', # Gingerbread
'android[_+ ]2[_\.]2','androidfroyo',       # Froyo
'android[_+ ]2','androideclair',            # Eclair, Must be after F & G
'android[_+ ]1[_\.]6','androiddonut',       # Donut
'android[_+ ]1[_\.]5','androidcupcake',     # Cupcake
'linux(.*)android','android',
'android','android',
# Linux family (linuxyyy)
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
'centos','linuxcentos',
'debian','linuxdebian',
'gentoo','linuxgentoo',
'ubuntu','linuxubuntu',
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
'win10','<a href="http://www.microsoft.com/windows10/" title="Windows 10 home page [new window]" target="_blank" rel="noopener noreferrer">Windows 10</a>',
'win8.1','<a href="https://technet.microsoft.com/en-us/library/hh832030(v=ws.11).aspx" title="Windows 8.1 home page [new window]" target="_blank" rel="noopener noreferrer">Windows 8.1</a>',
'win8','<a href="https://technet.microsoft.com/en-us/library/hh832030(v=ws.11).aspx" title="Windows 8 home page [new window]" target="_blank" rel="noopener noreferrer">Windows 8</a>',
'win7','<a href="https://technet.microsoft.com/en-us/library/dd349779.aspx" title="Windows 7 home page [new window]" target="_blank" rel="noopener noreferrer">Windows 7</a>',
'winlong','<a href="https://technet.microsoft.com/en-us/library/cc707009.aspx" title="Windows Vista home page [new window]" target="_blank" rel="noopener noreferrer">Windows Vista (LongHorn)</a>',
'win2008','<a href="https://technet.microsoft.com/en-us/library/dd349801(v=ws.10).aspx" title="Windows 2008 home page [new window]" target="_blank" rel="noopener noreferrer">Windows 2008</a>',
'win2012','<a href="https://technet.microsoft.com/en-us/library/hh801901(v=ws.11).aspx" title="Windows Server 2012 home page [new window]" target="_blank" rel="noopener noreferrer">Windows Server 2012</a>',
'winvista','<a href="https://technet.microsoft.com/en-us/library/cc707009.aspx" title="Windows Vista home page [new window]" target="_blank" rel="noopener noreferrer">Windows Vista</a>',
'win2003','<a href="https://www.microsoft.com/en-US/download/details.aspx?id=53314" title="Windows 2003 home page [new window]" target="_blank" rel="noopener noreferrer">Windows 2003</a>',
'winxp','<a href="https://technet.microsoft.com/en-us/library/bb491054.aspx" title="Windows XP home page [new window]" target="_blank" rel="noopener noreferrer">Windows XP</a>',
'winme','<a href="https://support.microsoft.com/en-us/help/253695/" title="Windows ME support page [new window]" target="_blank" rel="noopener noreferrer">Windows ME</a>',
'win2000','<a href="https://technet.microsoft.com/en-us/library/hh534433.aspx" title="Windows 2000 support page [new window]" target="_blank" rel="noopener noreferrer">Windows 2000</a>',
'winnt','<a href="https://technet.microsoft.com/en-us/library/cc767870.aspx" title="Windows NT support page [new window]" target="_blank" rel="noopener noreferrer">Windows NT</a>',
'win98','<a href="https://support.microsoft.com/en-us/help/234762/" title="Windows 98 support page [new window]" target="_blank" rel="noopener noreferrer">Windows 98</a>',
'win95','<a href="https://en.wikipedia.org/wiki/Windows_95" title="Windows 95 Wiki Pedia page [new window]" target="_blank" rel="noopener noreferrer">Windows 95</a>',
'win16','<a href="https://support.microsoft.com/en-us/help/83245" title="Windows 3.xx history page [new window]" target="_blank" rel="noopener noreferrer">Windows 3.xx</a>',
'wince','<a href="http://www.microsoft.com/windowsmobile/" title="Windows Mobile home page [new window]" target="_blank" rel="noopener noreferrer">Windows Mobile</a>',
'winphone','<a href="http://www.microsoft.com/windowsphone/" title="Windows Phone home page [new window]" target="_blank" rel="noopener noreferrer">Windows Phone</a>',
'winunknown','Windows (unknown version)',
'winxbox','<a href="http://www.xbox.com/" title="Microsoft XBOX home page [new window]" target="_blank" rel="noopener noreferrer">Microsoft XBOX</a>',
# Macintosh OS
'macosx15','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">macOS 10.15 Catalina</a>',
'macosx14','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">macOS 10.14 Mojave</a>',
'macosx13','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">macOS 10.13 High Sierra</a>',
'macosx12','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">macOS 10.12 Sierra</a>',
'macosx11','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">OS X 10.11 El Capitan</a>',
'macosx10','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">OS X 10.10 Yosemite</a>',
'macosx9','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">OS X 10.9 Mavericks</a>',
'macosx8','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">OS X 10.8 Mountain Lion</a>',
'macosx7','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">Mac OS X 10.7 Lion</a>',
'macosx6','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">Mac OS X 10.6 Snow Leopard</a>',
'macosx5','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">Mac OS X 10.5 Leopard</a>',
'macosx4','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">Mac OS X 10.4 Tiger</a>',
'macosx','<a href="https://www.apple.com/macos/" title="macOS home page [new window]" target="_blank" rel="noopener noreferrer">Mac OS X others</a>',
'macintosh','<a href="https://www.apple.com/" title="Mac OS home page [new window]" target="_blank" rel="noopener noreferrer">Mac OS</a>',
# Android
'android10','<a href="https://developer.android.com/about/versions/10" title="Google Android 10.x home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 10.x</a>',
'androidpie','<a href="https://developer.android.com/about/versions/pie/" title="Google Android 9.x Pie home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 9.x Pie</a>',
'androidoreo','<a href="https://developer.android.com/about/versions/oreo/" title="Google Android 8.x Oreo home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 8.x Oreo</a>',
'androidnougat','<a href="https://developer.android.com/about/versions/nougat/" title="Google Android 7.x Nougat home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 7.x Nougat</a>',
'androidmarshmallow','<a href="https://developer.android.com/about/versions/marshmallow/" title="Google Android 6.x Marshmallow home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 6.x Marshmallow</a>',
'androidlollipop','<a href="https://developer.android.com/about/versions/lollipop.html" title="Google Android 5.x Lollipop home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 5.x Lollipop</a>',
'androidkitkat','<a href="https://developer.android.com/about/versions/kitkat.html" title="Google Android 4.4 KitKat home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 4.4 KitKat</a>',
'androidjellybean','<a href="https://developer.android.com/about/versions/jelly-bean.html" title="Google Android 4.1-4.3 Jelly Bean home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 4.1-4.3 Jelly Bean</a>',
'androidics','<a href="https://developer.android.com/index.html" title="Google Android home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 4.0 Ice Cream Sandwich</a>',
'androidhoneycomb','<a href="https://developer.android.com/index.html" title="Google Android home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 3.x Honeycomb</a>',
'androidgingerbread','<a href="https://developer.android.com/index.html" title="Google Android home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 2.3 Gingerbread</a>',
'androidfroyo','<a href="https://developer.android.com/index.html" title="Google Android home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 2.2 Froyo</a>',
'androideclair','<a href="https://developer.android.com/index.html" title="Google Android home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 2.0-2.1 Eclair</a>',
'androiddonut','<a href="https://developer.android.com/index.html" title="Google Android home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 1.6 Donut</a>',
'androidcupcake','<a href="https://developer.android.com/index.html" title="Google Android home page [new window]" target="_blank" rel="noopener noreferrer">Google Android 1.5 Cupcake</a>',
'android','<a href="https://developer.android.com/index.html" title="Google Android home page [new window]" target="_blank" rel="noopener noreferrer">Google Android Unknown</a>',
'linuxandroid','<a href="https://developer.android.com/index.html" title="Google Android home page [new window]" target="_blank" rel="noopener noreferrer">Google Android Unknown</a>',
# Linux
'linuxasplinux','<a href="http://www.asplinux.ru/" title="ASPLinux home page [new window]" target="_blank" rel="noopener noreferrer">ASPLinux</a>',
'linuxcentos','<a href="https://www.centos.org/" title="Centos home page [new window]" target="_blank" rel="noopener noreferrer">Centos</a>',
'linuxdebian','<a href="https://www.debian.org/" title="Debian home page [new window]" target="_blank" rel="noopener noreferrer">Debian</a>',
'linuxfedora','<a href="https://getfedora.org/" title="Fedora home page [new window]" target="_blank" rel="noopener noreferrer">Fedora</a>',
'linuxgentoo','<a href="https://www.gentoo.org/" title="Gentoo home page [new window]" target="_blank" rel="noopener noreferrer">Gentoo</a>',
'linuxmandr','<a href="http://www.mandriva.com/" title="Mandriva (former Mandrake) home page [new window]" target="_blank" rel="noopener noreferrer">Mandriva (or Mandrake)</a>',
'linuxmomonga','<a href="http://www.momonga-linux.org/" title="Momonga Linux home page [new window]" target="_blank" rel="noopener noreferrer">Momonga Linux</a>',
'linuxpclinuxos','<a href="http://www.pclinuxos.com/" title="PCLinuxOS home page [new window]" target="_blank" rel="noopener noreferrer">PCLinuxOS</a>',
'linuxredhat','<a href="http://www.redhat.com/" title="Red Hat home page [new window]" target="_blank" rel="noopener noreferrer">Red Hat</a>',
'linuxsuse','<a href="https://www.suse.com/" title="Suse home page [new window]" target="_blank" rel="noopener noreferrer">Suse</a>',
'linuxubuntu','<a href="https://www.ubuntu.com/" title="Ubuntu home page [new window]" target="_blank" rel="noopener noreferrer">Ubuntu</a>',
'linuxvector','<a href="http://vectorlinux.com/" title="VectorLinux home page [new window]" target="_blank" rel="noopener noreferrer">VectorLinux</a>',
'linuxvine','<a href="http://www.vinelinux.org/index-en.html" title="Vine Linux home page [new window]" target="_blank" rel="noopener noreferrer">Vine Linux</a>',
'linuxwhitebox','<a href="http://whiteboxlinux.org/" title="White Box Linux home page [new window]" target="_blank" rel="noopener noreferrer">White Box Linux</a>',
'linuxzenwalk','<a href="http://www.zenwalk.org/" title="Zenwalk GNU Linux home page [new window]" target="_blank" rel="noopener noreferrer">Zenwalk GNU Linux</a>',
'linux','<a href="http://www.distrowatch.com/" title="Linux DistroWatch home page. Useful if you find the associated user agent string in your logs. [new window]" target="_blank" rel="noopener noreferrer">Linux (Unknown/unspecified)</a>',
'linux','GNU Linux (Unknown or unspecified distribution)',
# Hurd
'gnu','<a href="http://www.gnu.org/software/hurd/hurd.html" title="GNU Hurd home page [new window]" target="_blank" rel="noopener noreferrer">GNU Hurd</a>',
# BSDs
'bsdi','<a href="http://en.wikipedia.org/wiki/BSDi" title="BSDi home page [new window]" target="_blank" rel="noopener noreferrer">BSDi</a>',
'bsdkfreebsd','<a href="http://www.debian.org/ports/kfreebsd-gnu/" title="Debian GNU/kFreeBSD" target="_blank" rel="noopener noreferrer">GNU/kFreeBSD</a>',
'freebsd','<a href="http://www.freebsd.org/" title="FreeBSD home page [new window]" target="_blank" rel="noopener noreferrer">FreeBSD</a>',    # For backard compatibility
'bsdfreebsd','<a href="http://www.freebsd.org/" title="FreeBSD home page [new window]" target="_blank" rel="noopener noreferrer">FreeBSD</a>',
'openbsd','<a href="http://www.openbsd.org/" title="OpenBSD home page [new window]" target="_blank" rel="noopener noreferrer">OpenBSD</a>',    # For backard compatibility
'bsdopenbsd','<a href="http://www.openbsd.org/" title="OpenBSD home page [new window]" target="_blank" rel="noopener noreferrer">OpenBSD</a>',
'netbsd','<a href="http://www.netbsd.org/" title="NetBSD home page [new window]" target="_blank" rel="noopener noreferrer">NetBSD</a>', # For backard compatibility
'bsdnetbsd','<a href="http://www.netbsd.org/" title="NetBSD home page [new window]" target="_blank" rel="noopener noreferrer">NetBSD</a>',
'bsddflybsd','<a href="http://www.dragonflybsd.org/" title="DragonFlyBSD home page [new window]" target="_blank" rel="noopener noreferrer">DragonFlyBSD</a>',
# Other Unix, Unix-like
'aix','<a href="http://www-1.ibm.com/servers/aix/" title="Aix home page [new window]" target="_blank" rel="noopener noreferrer">Aix</a>',
'sunos','<a href="http://www.sun.com/software/solaris/" title="Sun Solaris home page [new window]" target="_blank" rel="noopener noreferrer">Sun Solaris</a>',
'irix','<a href="http://www.sgi.com/products/software/irix/" title="Irix home page [new window]" target="_blank" rel="noopener noreferrer">Irix</a>',
'osf','<a href="http://www.tru64.org/" title="OSF Unix home page [new window]" target="_blank" rel="noopener noreferrer">OSF Unix</a>',
'hp\-ux','<a href="http://www.hp.com/products1/unix/operating/" title="HP UX home page [new window]" target="_blank" rel="noopener noreferrer">HP UX</a>',
'unix','Unknown Unix system',
# iOS
'ios_iphone','<a href="http://www.apple.com/iphone/ios" title="Apple iPhone home page [new window]" target="_blank" rel="noopener noreferrer">iOS (iPhone)</a>',
'ios_ipad','<a href="http://www.apple.com/ipad/ios" title="Apple iPad home page [new window]" target="_blank" rel="noopener noreferrer">iOS (iPad)</a>',
'ios_ipod','<a href="http://www.apple.com/ipod/ios" title="Apple iPod home page [new window]" target="_blank" rel="noopener noreferrer">iOS (iPod)</a>',
# Other famous OS
'beos','<a href="http://www.beincorporated.com/" title="BeOS home page [new window]" target="_blank" rel="noopener noreferrer">BeOS</a>',
'os/2','<a href="http://www.ibm.com/software/os/warp/" title="OS/2 home page [new window]" target="_blank" rel="noopener noreferrer">OS/2</a>',
'amigaos','<a href="http://www.amiga.com/amigaos/" title="AmigaOS home page [new window]" target="_blank" rel="noopener noreferrer">AmigaOS</a>',
'atari','<a href="http://www.atarimuseum.com/computers/computers.html" title="Atari home page [new window]" target="_blank" rel="noopener noreferrer">Atari</a>',
'vms','<a href="http://h71000.www7.hp.com/" title="VMS home page [new window]" target="_blank" rel="noopener noreferrer">VMS</a>',
'commodore','<a href="http://en.wikipedia.org/wiki/Commodore_64" title="Commodore 64 wikipedia page [new window]" target="_blank" rel="noopener noreferrer">Commodore 64</a>',
'j2me','<a href="http://mobile.java.com/" title="Java Mobile home page [new window]" target="_blank" rel="noopener noreferrer">Java Mobile</a>',
'java','<a href="http://www.java.com/" title="Java home page [new window]" target="_blank" rel="noopener noreferrer">Java</a>',
'qnx','<a href="http://www.qnx.com/products/neutrino_rtos/" title="QNX home page [new window]" target="_blank" rel="noopener noreferrer">QNX</a>',
'inferno','<a href="http://www.vitanuova.com/inferno/" title="Inferno home page [new window]" target="_blank" rel="noopener noreferrer">Inferno</a>',
'palmos','<a href="http://www.palm.com/" title="Palm OS home page [new window]" target="_blank" rel="noopener noreferrer">Palm OS</a>',
'syllable','<a href="http://www.syllable.org/" title="Syllable home page [new window]" target="_blank" rel="noopener noreferrer">Syllable</a>',
# Miscellaneous OS
'blackberry','BlackBerry',
'cp/m','<a href="http://www.digitalresearch.biz/CPM.HTM" title="CP/M home page [new window]" target="_blank" rel="noopener noreferrer">CP/M</a>',
'crayos','<a href="http://www.cray.com/" title="CrayOS home page [new window]" target="_blank" rel="noopener noreferrer">CrayOS</a>',
'dreamcast','<a href="http://www.sega.com/" title="Dreamcast home page [new window]" target="_blank" rel="noopener noreferrer">Dreamcast</a>',
'riscos','<a href="http://www.riscos.com/" title="RISC OS home page [new window]" target="_blank" rel="noopener noreferrer">RISC OS</a>',
'symbian','<a href="http://www.symbian.com/" title="Symbian OS home page [new window]" target="_blank" rel="noopener noreferrer">Symbian OS</a>',
'webtv','<a href="http://www.webtv.com/" title="WebTV home page [new window]" target="_blank" rel="noopener noreferrer">WebTV</a>',
'psp', '<a href="http://www.playstation.com/" title="Sony PlayStation home page [new window]" target="_blank" rel="noopener noreferrer">Sony PlayStation</a>',
'wii', '<a href="http://wii.opera.com/" title="Opera for Nintendo Wii home page [new window]" target="_blank" rel="noopener noreferrer">Nintendo Wii</a>'
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


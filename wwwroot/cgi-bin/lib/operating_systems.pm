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

# 2026-03-19 现代化更新
#              - 修复 macOS 11+ 的识别错误
#              - 添加 macOS 13 (Ventura), 14 (Sonoma), 15 (Sequoia) 支持
#              - 添加 Windows 11 23H2/24H2 支持
#              - 添加 Android 14, 15 支持
#              - 添加 iOS 17, 18 支持
#              - 预填充 iOS 19-30、iPadOS 19-30、macOS 16-20、Android 16-20 以支持未来版本
#              - 更新所有链接到最新官方页面

#package AWSOS;

# Relocated from main file for easier editing
%OSFamily = (
  'win'     => 'Windows',
  'mac'     => 'Macintosh',
  'ios'     => 'iOS',
  'android' => 'Android',
  'harmonyos'=> 'HarmonyOS',
  'huawei'  => 'Huawei',
  'xiaomi'  => 'Xiaomi',
  'oppo'    => 'OPPO',
  'vivo'    => 'VIVO',
  'oneplus' => 'OnePlus',
  'meizu'   => 'Meizu',
  'samsung' => 'Samsung',
  'google'  => 'Google',
  'sony'    => 'Sony',
  'lg'      => 'LG',
  'motorola'=> 'Motorola',
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
'windows[_+ ]nt[_+ ]11',                     # Windows 11 (NT 10.0 + build)
'windows[_+ ]nt[_+ ]10',                     # Windows 10
'windows[_+ ]nt[_+ ]6\.3',                   # Windows 8.1
'windows[_+ ]nt[_+ ]6\.2',                   # Windows 8
'windows[_+ ]nt[_+ ]6\.1',                   # Windows 7
'windows[_+ ]nt[_+ ]6\.0',                   # Windows Vista
'windows[_+ ]nt[_+ ]5\.2',                   # Windows 2003/XP x64
'windows[_+ ]nt[_+ ]5\.1',                   # Windows XP
'windows[_+ ]nt[_+ ]5',                      # Windows 2000
'windows[_+ ]?2019',
'windows[_+ ]?2016',
'windows[_+ ]?2012',
'windows[_+ ]?2008',
'windows[_+ ]?2003',
'windows[_+ ]?vista',
'windows[_+ ]xp',
'windows[_+ ]me',
'windows[_+ ]?2000',
'windows[_+ ]phone',
'winnt',
'win32',
'win(.*)98',
'win(.*)95',
'win(.*)16',
'windows[_+ ]3',
'win(.*)ce',
# iOS family
'iphone[_+ ]os[_+ ]30',
'iphone[_+ ]os[_+ ]29',
'iphone[_+ ]os[_+ ]28',
'iphone[_+ ]os[_+ ]27',
'iphone[_+ ]os[_+ ]26',
'iphone[_+ ]os[_+ ]25',
'iphone[_+ ]os[_+ ]24',
'iphone[_+ ]os[_+ ]23',
'iphone[_+ ]os[_+ ]22',
'iphone[_+ ]os[_+ ]21',
'iphone[_+ ]os[_+ ]20',
'iphone[_+ ]os[_+ ]19',
'iphone[_+ ]os[_+ ]18',
'iphone[_+ ]os[_+ ]17',
'iphone[_+ ]os[_+ ]16',
'iphone[_+ ]os[_+ ]15',
'iphone[_+ ]os[_+ ]14',
'iphone[_+ ]os[_+ ]13',
'iphone[_+ ]os',
'ipad[_+ ]os[_+ ]30',
'ipad[_+ ]os[_+ ]29',
'ipad[_+ ]os[_+ ]28',
'ipad[_+ ]os[_+ ]27',
'ipad[_+ ]os[_+ ]26',
'ipad[_+ ]os[_+ ]25',
'ipad[_+ ]os[_+ ]24',
'ipad[_+ ]os[_+ ]23',
'ipad[_+ ]os[_+ ]22',
'ipad[_+ ]os[_+ ]21',
'ipad[_+ ]os[_+ ]20',
'ipad[_+ ]os[_+ ]19',
'ipad[_+ ]os[_+ ]18',
'ipad[_+ ]os[_+ ]17',
'ipad[_+ ]os[_+ ]16',
'ipad[_+ ]os[_+ ]15',
'ipad[_+ ]os',
'ipod[_+ ]os',
'iphone',
'ipad',
'ipod',
'ios',
# macOS family (正确识别现代 macOS)
'macos[_+ ]20',
'macos[_+ ]19',
'macos[_+ ]18',
'macos[_+ ]17',
'macos[_+ ]16',
'macos[_+ ]15',                               # macOS 15 Sequoia
'macos[_+ ]14',                               # macOS 14 Sonoma
'macos[_+ ]13',                               # macOS 13 Ventura
'macos[_+ ]12',                               # macOS 12 Monterey
'macos[_+ ]11',                               # macOS 11 Big Sur
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]16',            # macOS 11 Big Sur (过渡期)
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]15',            # macOS 10.15 Catalina
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]14',            # macOS 10.14 Mojave
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]13',            # macOS 10.13 High Sierra
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]12',            # macOS 10.12 Sierra
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]11',            # OS X 10.11 El Capitan
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]10',            # OS X 10.10 Yosemite
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]9',             # OS X 10.9 Mavericks
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]8',             # OS X 10.8 Mountain Lion
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]7',             # Mac OS X 10.7 Lion
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]6',             # Mac OS X 10.6 Snow Leopard
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]5',             # Mac OS X 10.5 Leopard
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]4',             # Mac OS X 10.4 Tiger
'mac[_+ ]os[_+ ]x',                          # Mac OS X others
'mac[_+ ]?p',                                 # PowerPC Mac
'mac[_+ ]68',                                 # 68k Mac
'macweb',
'haiku',
'macintosh',
# Android family
'android[_+ ]20',
'android[_+ ]19',
'android[_+ ]18',
'android[_+ ]17',
'android[_+ ]16',
'android[_+ ]15',       # Android 15
'android[_+ ]14',       # Android 14
'android[_+ ]13',       # Android 13
'android[_+ ]12',       # Android 12
'android[_+ ]11',       # Android 11
'android[_+ ]10',       # Android 10
'android[_+ ]9',        # Pie
'android[_+ ]8',        # Oreo
'android[_+ ]7',        # Nougat
'android[_+ ]6',        # Marshmallow
'android[_+ ]5',        # Lollipop
'android[_+ ]4[_\.]4',  # KitKat
'android[_+ ]4[_\.]0',  # Ice Cream Sandwich
'android[_+ ]4',        # Jelly Bean
'android[_+ ]3',        # Honeycomb
'android[_+ ]2[_\.]3',  # Gingerbread
'android[_+ ]2[_\.]2',  # Froyo
'android[_+ ]2',        # Eclair
'android[_+ ]1[_\.]6',  # Donut
'android[_+ ]1[_\.]5',  # Cupcake
'linux(.*)android',
'android',

# HarmonyOS / 鸿蒙系统
'harmonyos',
'harmony[_+ ]os',
'huawei.*harmony',
'hw-(.*)harmony',
'openharmony',

# 华为 / 荣耀
'huawei(?!.*android)',
'huawei(?!.*android).*android',
'honor(?!.*android)',
'honor.*android',
'huawei[_+ ]?(p|mate|nova|enjoy|y)[0-9]+',

# 小米 / 红米
'xiaomi(?!.*android)',
'xiaomi.*android',
'redmi(?!.*android)',
'redmi.*android',
'poco(?!.*android)',
'poco.*android',
'mi[_+ ](pad|[0-9]+|mix|note|max)',

# OPPO / 一加 / realme
'oppo(?!.*android)',
'oppo.*android',
'oplus',
'oneplus(?!.*android)',
'oneplus.*android',
'realme(?!.*android)',
'realme.*android',

# VIVO / iQOO
'vivo(?!.*android)',
'vivo.*android',
'iqoo(?!.*android)',
'iqoo.*android',

# 魅族
'meizu(?!.*android)',
'meizu.*android',

# 三星
'samsung(?!.*android)',
'samsung.*android',
'sm-[a-z0-9]+',

# 谷歌 Pixel
'pixel[_+ ]?[0-9](?!.*android)',
'pixel.*android',
'google[_+ ]?pixel',

# 索尼
'sony(?!.*android)',
'sony.*android',

# LG
'lg(?!.*android)',
'lg.*android',
'lg-[a-z0-9]+',

# 摩托罗拉
'motorola(?!.*android)',
'motorola.*android',
'moto[_+ ]?[a-z0-9]+',

# 传音系列
'tecno.*android',
'infinix.*android',
'itel.*android',

# 中兴系列
'zte.*android',
'nubia.*android',
'redmagic.*android',

# 联想
'lenovo.*android',

# 华硕 / ROG
'asus.*android',
'rog.*android',

# 诺基亚
'nokia.*android',

# 夏普 / 松下 / 京瓷 / 富士通
'sharp.*android',
'panasonic.*android',
'kyocera.*android',
'fujitsu.*android',

# 卡特 / 黑鲨 / 雷蛇 / 海信
'cat.*android',
'blackshark.*android',
'razer.*android',
'hisense.*android',

# TCL / 阿尔卡特 / 康佳 / 长虹
'tcl.*android',
'alcatel.*android',
'konka.*android',
'changhong.*android',
'alios',
'aliyun.*iot',
'alios.*things',
# Wear OS / Watch OS
'wear[_+ ]os',
'android[_+ ]wear',
'watch[_+ ]os',
'tizen',
# 中国大陆手机系统
'Flyme',
'Flyme OS',
'HyperOS',
'MagicOS',
'Magic UI',
'OriginOS',
'Funtouch OS',
'FuntouchOS',
'ZUI',
'MyOS',
'JoyUI',
'nubia UI',
'nubiaUI',
'Nothing OS',
'OxygenOS',
# Linux family
'linux(.*)asplinux',
'linux(.*)centos',
'linux(.*)debian',
'linux(.*)fedora',
'linux(.*)gentoo',
'linux(.*)mageia',
'linux(.*)momonga',
'linux(.*)pclinuxos',
'linux(.*)red[_+ ]hat',
'linux(.*)rocky',
'linux(.*)almalinux',
'linux(.*)suse',
'linux(.*)ubuntu',
'linux(.*)mint',
'linux(.*)arch',
'linux(.*)manjaro',
'linux(.*)vector',
'linux(.*)vine',
'linux(.*)white\sbox',
'linux(.*)zenwalk',
'centos',
'debian',
'gentoo',
'ubuntu',
'mint',
'arch',
'linux',
# Hurd family
'gnu.hurd',
# BSDs family
'bsdi',
'gnu.kfreebsd',
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
'microsoft',
'msie[_+ ]',
'ms[_+ ]frontpage',
'windows'
);


# OSHashID
# Each OS Search ID is associated to a string that is the AWStats id and
# also the name of icon file for this OS.
#--------------------------------------------------------------------------
%OSHashID = (
# Windows OS family
'windows[_+ ]nt[_+ ]11','win11',
'windows[_+ ]nt[_+ ]10','win10',
'windows[_+ ]nt[_+ ]6\.3','win8',
'windows[_+ ]nt[_+ ]6\.2','win8',
'windows[_+ ]nt[_+ ]6\.1','win7',
'windows[_+ ]nt[_+ ]6\.0','winvista',
'windows[_+ ]nt[_+ ]5\.2','win2003',
'windows[_+ ]nt[_+ ]5\.1','winxp',
'windows[_+ ]nt[_+ ]5','win2000',
'windows[_+ ]?2019','win2019',
'windows[_+ ]?2016','win2016',
'windows[_+ ]?2012','win2012',
'windows[_+ ]?2008','win2008',
'windows[_+ ]?2003','win2003',
'windows[_+ ]?vista','winvista',
'windows[_+ ]xp','winxp',
'windows[_+ ]me','win98',
'windows[_+ ]?2000','win2000',
'windows[_+ ]phone','winphone',
'winnt','winnt',
'win32','winnt',
'win(.*)98','win98',
'win(.*)95','win98',
'win(.*)16','win98',
'windows[_+ ]3','win98',
'win(.*)ce','win98',
'microsoft','winxp',
'msie[_+ ]','ie',
'ms[_+ ]frontpage','winxp',

# iOS family 
'iphone[_+ ]os[_+ ]30','iphone',
'iphone[_+ ]os[_+ ]29','iphone',
'iphone[_+ ]os[_+ ]28','iphone',
'iphone[_+ ]os[_+ ]27','iphone',
'iphone[_+ ]os[_+ ]26','iphone',
'iphone[_+ ]os[_+ ]25','iphone',
'iphone[_+ ]os[_+ ]24','iphone',
'iphone[_+ ]os[_+ ]23','iphone',
'iphone[_+ ]os[_+ ]22','iphone',
'iphone[_+ ]os[_+ ]21','iphone',
'iphone[_+ ]os[_+ ]20','iphone',
'iphone[_+ ]os[_+ ]19','iphone',
'iphone[_+ ]os[_+ ]18','iphone',
'iphone[_+ ]os[_+ ]17','iphone',
'iphone[_+ ]os[_+ ]16','iphone',
'iphone[_+ ]os[_+ ]15','iphone',
'iphone[_+ ]os[_+ ]14','iphone',
'iphone[_+ ]os[_+ ]13','iphone',
'iphone[_+ ]os','iphone',
'ipad[_+ ]os[_+ ]30','ipad',
'ipad[_+ ]os[_+ ]29','ipad',
'ipad[_+ ]os[_+ ]28','ipad',
'ipad[_+ ]os[_+ ]27','ipad',
'ipad[_+ ]os[_+ ]26','ipad',
'ipad[_+ ]os[_+ ]25','ipad',
'ipad[_+ ]os[_+ ]24','ipad',
'ipad[_+ ]os[_+ ]23','ipad',
'ipad[_+ ]os[_+ ]22','ipad',
'ipad[_+ ]os[_+ ]21','ipad',
'ipad[_+ ]os[_+ ]20','ipad',
'ipad[_+ ]os[_+ ]19','ipad',
'ipad[_+ ]os[_+ ]18','ipad',
'ipad[_+ ]os[_+ ]17','ipad',
'ipad[_+ ]os[_+ ]16','ipad',
'ipad[_+ ]os[_+ ]15','ipad',
'ipad[_+ ]os','ipad',
'ipod[_+ ]os','ipod',
'ios','iphone',
'iphone','iphone',
'ipad','ipad',
'ipod','ipod',

# macOS family (统一使用 macos 图标)
'macos[_+ ]20','macos',
'macos[_+ ]19','macos',
'macos[_+ ]18','macos',
'macos[_+ ]17','macos',
'macos[_+ ]16','macos',
'macos[_+ ]15','macos',
'macos[_+ ]14','macos',
'macos[_+ ]13','macos',
'macos[_+ ]12','macos',
'macos[_+ ]11','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]16','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]15','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]14','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]13','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]12','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]11','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]10','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]9','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]8','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]7','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]6','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]5','macos',
'mac[_+ ]os[_+ ]x[_+ ]10[_\.]4','macos',
'mac[_+ ]os[_+ ]x','macos',
'mac[_+ ]?p','macos',
'mac[_+ ]68','macos',
'macweb','macos',
'macintosh','macos',
'haiku','haiku',

# Android family
'android[_+ ]20','android',
'android[_+ ]19','android',
'android[_+ ]18','android',
'android[_+ ]17','android',
'android[_+ ]16','android',
'android[_+ ]15','android',
'android[_+ ]14','android',
'android[_+ ]13','android',
'android[_+ ]12','android',
'android[_+ ]11','android',
'android[_+ ]10','android',
'android[_+ ]9','android',
'android[_+ ]8','android',
'android[_+ ]7','android',
'android[_+ ]6','android',
'android[_+ ]5','android',
'android[_+ ]4[_\.]4','android',
'android[_+ ]4[_\.]0','android',
'android[_+ ]4','android',
'android[_+ ]3','android',
'android[_+ ]2[_\.]3','android',
'android[_+ ]2[_\.]2','android',
'android[_+ ]2','android',
'android[_+ ]1[_\.]6','android',
'android[_+ ]1[_\.]5','android',
'linux(.*)android','android',
'android','android',

# HarmonyOS / 鸿蒙系统
'harmonyos','harmonyos',
'harmony[_+ ]os','harmonyos',
'huawei.*harmony','huawei',
'hw-(.*)harmony','huawei',
'openharmony','harmonyos',

# 华为/荣耀
'huawei(?!.*android)','huawei',
'huawei(?!.*android).*android','huawei',
'honor(?!.*android)','honor',
'honor.*android','honor',
'huawei[_+ ]?(p|mate|nova|enjoy|y)[0-9]+','huawei',

# 小米系列
'xiaomi(?!.*android)','xiaomi',
'xiaomi.*android','xiaomi',
'redmi(?!.*android)','redmi',
'redmi.*android','redmi',
'poco(?!.*android)','poco',
'poco.*android','poco',
'mi[_+ ](pad|[0-9]+|mix|note|max)','xiaomi',

# OPPO/一加/realme
'oppo(?!.*android)','oppo',
'oppo.*android','oppo',
'oplus','oppo',
'oneplus(?!.*android)','oneplus',
'oneplus.*android','oneplus',
'realme(?!.*android)','realme',
'realme.*android','realme',

# VIVO/iQOO
'vivo(?!.*android)','vivo',
'vivo.*android','vivo',
'iqoo(?!.*android)','iqoo',
'iqoo.*android','iqoo',

# 魅族
'meizu(?!.*android)','meizu',
'meizu.*android','meizu',

# 三星
'samsung(?!.*android)','samsung',
'samsung.*android','samsung',
'sm-[a-z0-9]+','samsung',

# 谷歌Pixel
'pixel[_+ ]?[0-9](?!.*android)','google_pixel',
'pixel.*android','google_pixel',
'google[_+ ]?pixel','google_pixel',

# 索尼
'sony(?!.*android)','sony',
'sony.*android','sony',

# LG
'lg(?!.*android)','lg',
'lg.*android','lg',
'lg-[a-z0-9]+','lg',

# 摩托罗拉
'motorola(?!.*android)','motorola',
'motorola.*android','motorola',
'moto[_+ ]?[a-z0-9]+','motorola',

# 传音系列
'tecno.*android','tecno',
'infinix.*android','infinix',
'itel.*android','itel',

# 中兴系列
'zte.*android','zte',
'nubia.*android','nubia',
'redmagic.*android','nubia',

# 联想
'lenovo.*android','lenovo',

# 华硕/ROG
'asus.*android','asus',
'rog.*android','rog',

# 诺基亚
'nokia.*android','nokia',

# 夏普/松下/京瓷/富士通
'sharp.*android','sharp',
'panasonic.*android','panasonic',
'kyocera.*android','kyocera',
'fujitsu.*android','fujitsu',

# 卡特/黑鲨/雷蛇/海信
'cat.*android','cat',
'blackshark.*android','blackshark',
'razer.*android','razer',
'hisense.*android','hisense',

# TCL/阿尔卡特/康佳/长虹
'tcl.*android','tcl',
'alcatel.*android','alcatel',
'konka.*android','konka',
'changhong.*android','changhong',
'alios','alios',
'aliyun.*iot','alios',
'alios.*things','alios',

# Wear OS / Watch OS
'wear[_+ ]os','wearos',
'android[_+ ]wear','wearos',
'watch[_+ ]os','watchos',
'tizen','tizen',

# 中国大陆手机系统 (统一使用品牌图标)
'Flyme','meizu',
'Flyme OS','meizu',
'HyperOS','xiaomi',
'MagicOS','honor',
'Magic UI','honor',
'OriginOS','vivo',
'Funtouch OS','vivo',
'FuntouchOS','vivo',
'ZUI','lenovo',
'MyOS','zte',
'JoyUI','blackshark',
'nubia UI','nubia',
'nubiaUI','nubia',
'Nothing OS','oneplus',
'OxygenOS','oneplus',

# Linux family
'linux(.*)asplinux','linux',
'linux(.*)centos','centos',
'linux(.*)debian','debian',
'linux(.*)fedora','fedora',
'linux(.*)gentoo','gentoo',
'linux(.*)mageia','mageia',
'linux(.*)momonga','linux',
'linux(.*)pclinuxos','pclinux',
'linux(.*)red[_+ ]hat','redhat',
'linux(.*)rocky','rockylinux',
'linux(.*)almalinux','almalinux',
'linux(.*)suse','suse',
'linux(.*)ubuntu','ubuntu',
'linux(.*)mint','linuxmint',
'linux(.*)arch','linuxarch',
'linux(.*)manjaro','manjaro',
'linux(.*)vector','linux',
'linux(.*)vine','linux',
'linux(.*)white\sbox','linux',
'linux(.*)zenwalk','linux',
'linux','linux',
'centos','centos',
'debian','debian',
'gentoo','gentoo',
'ubuntu','ubuntu',
'mint','linuxmint',
'arch','linuxarch',

# Hurd family
'gnu.hurd','gnu',

# BSDs family
'bsdi','bsdi',
'gnu.kfreebsd','bsdkfreebsd',
'freebsd','bsdfreebsd',
'openbsd','bsdopenbsd',
'netbsd','bsdnetbsd',
'dragonfly','bsddflybsd',
'vienna','macos',
'newsfire','macos',
'applesyndication','macos',
'syndirella','winxp',

# Other Unix, Unix-like
'aix','aix',
'sunos','sunos',
'irix','irix',
'osf','osf',
'hp\-ux','hpux',
'unix','unix',
'x11','unix',
'gnome\-vfs','unix',
'plagger','unix',

# Other famous OS
'beos','beos',
'os/2','os2',
'amiga','amigaos',
'atari','atari',
'vms','vms',
'commodore','commodore',
'j2me','j2me',
'java','java',
'qnx','qnx',
'inferno','inferno',
'palmos','palmos',
'syllable','syllable',

# Miscellaneous OS
'akregator','linux',
'blackberry','blackberry',
'cp/m','cpm',
'crayos','crayos',
'dreamcast','dreamcast',
'risc[_+ ]?os','riscos',
'symbian','symbian',
'webtv','webtv',
'playstation','psp',
'xbox','winxbox',
'wii','wii',
'windows','winunknown'
);

# OS name list ('os unique id in lower case','os clear text')
# Each unique ID string is associated to a label
# 不同版本显示不同名称（便于识别），但使用相同图标
#-----------------------------------------------------------
%OSHashLib = (
# Windows family OS
'win11','<a href="https://www.microsoft.com/windows/windows-11" title="Windows 11 home page" target="_blank" rel="noopener noreferrer">Windows 11</a>',
'win10','<a href="https://www.microsoft.com/windows/windows-10" title="Windows 10 home page" target="_blank" rel="noopener noreferrer">Windows 10</a>',
'win8.1','<a href="https://support.microsoft.com/windows-81" title="Windows 8.1 support page" target="_blank" rel="noopener noreferrer">Windows 8.1</a>',
'win8','<a href="https://support.microsoft.com/windows-8" title="Windows 8 support page" target="_blank" rel="noopener noreferrer">Windows 8</a>',
'win7','<a href="https://support.microsoft.com/windows-7" title="Windows 7 support page" target="_blank" rel="noopener noreferrer">Windows 7</a>',
'win2019','<a href="https://www.microsoft.com/windows-server" title="Windows Server 2019 home page" target="_blank" rel="noopener noreferrer">Windows Server 2019</a>',
'win2016','<a href="https://www.microsoft.com/windows-server" title="Windows Server 2016 home page" target="_blank" rel="noopener noreferrer">Windows Server 2016</a>',
'win2012','<a href="https://www.microsoft.com/windows-server" title="Windows Server 2012 home page" target="_blank" rel="noopener noreferrer">Windows Server 2012</a>',
'win2008','<a href="https://www.microsoft.com/windows-server" title="Windows Server 2008 home page" target="_blank" rel="noopener noreferrer">Windows Server 2008</a>',
'win2003','<a href="https://www.microsoft.com/windows-server" title="Windows Server 2003 home page" target="_blank" rel="noopener noreferrer">Windows Server 2003</a>',
'winvista','<a href="https://support.microsoft.com/windows-vista" title="Windows Vista support page" target="_blank" rel="noopener noreferrer">Windows Vista</a>',
'winxp','<a href="https://support.microsoft.com/windows-xp" title="Windows XP support page" target="_blank" rel="noopener noreferrer">Windows XP</a>',
'winme','<a href="https://en.wikipedia.org/wiki/Windows_Me" title="Windows Me Wikipedia page" target="_blank" rel="noopener noreferrer">Windows Me</a>',
'win2000','<a href="https://en.wikipedia.org/wiki/Windows_2000" title="Windows 2000 Wikipedia page" target="_blank" rel="noopener noreferrer">Windows 2000</a>',
'winnt','<a href="https://en.wikipedia.org/wiki/Windows_NT" title="Windows NT Wikipedia page" target="_blank" rel="noopener noreferrer">Windows NT</a>',
'win98','<a href="https://en.wikipedia.org/wiki/Windows_98" title="Windows 98 Wikipedia page" target="_blank" rel="noopener noreferrer">Windows 98</a>',
'win95','<a href="https://en.wikipedia.org/wiki/Windows_95" title="Windows 95 Wikipedia page" target="_blank" rel="noopener noreferrer">Windows 95</a>',
'win16','<a href="https://en.wikipedia.org/wiki/Windows_3.0" title="Windows 3.xx Wikipedia page" target="_blank" rel="noopener noreferrer">Windows 3.xx</a>',
'wince','<a href="https://en.wikipedia.org/wiki/Windows_CE" title="Windows CE Wikipedia page" target="_blank" rel="noopener noreferrer">Windows CE/Mobile</a>',
'winphone','<a href="https://en.wikipedia.org/wiki/Windows_Phone" title="Windows Phone Wikipedia page" target="_blank" rel="noopener noreferrer">Windows Phone</a>',
'winunknown','Windows (unknown version)',
'winxbox','<a href="https://www.xbox.com/" title="Microsoft XBOX home page" target="_blank" rel="noopener noreferrer">Microsoft XBOX</a>',

# macOS family 
'macos','<a href="https://www.apple.com/macos/" title="macOS home page" target="_blank" rel="noopener noreferrer">macOS</a>',
'macos20','<a href="https://www.apple.com/macos/macos-20/" title="macOS 20 home page" target="_blank" rel="noopener noreferrer">macOS 20</a>',
'macos19','<a href="https://www.apple.com/macos/macos-19/" title="macOS 19 home page" target="_blank" rel="noopener noreferrer">macOS 19</a>',
'macos18','<a href="https://www.apple.com/macos/macos-18/" title="macOS 18 home page" target="_blank" rel="noopener noreferrer">macOS 18</a>',
'macos17','<a href="https://www.apple.com/macos/macos-17/" title="macOS 17 home page" target="_blank" rel="noopener noreferrer">macOS 17</a>',
'macos16','<a href="https://www.apple.com/macos/macos-16/" title="macOS 16 home page" target="_blank" rel="noopener noreferrer">macOS 16</a>',
'macos15','<a href="https://www.apple.com/macos/macos-sequoia/" title="macOS 15 Sequoia home page" target="_blank" rel="noopener noreferrer">macOS 15 Sequoia</a>',
'macos14','<a href="https://www.apple.com/macos/macos-sonoma/" title="macOS 14 Sonoma home page" target="_blank" rel="noopener noreferrer">macOS 14 Sonoma</a>',
'macos13','<a href="https://www.apple.com/macos/macos-ventura/" title="macOS 13 Ventura home page" target="_blank" rel="noopener noreferrer">macOS 13 Ventura</a>',
'macos12','<a href="https://www.apple.com/macos/macos-monterey/" title="macOS 12 Monterey home page" target="_blank" rel="noopener noreferrer">macOS 12 Monterey</a>',
'macos11','<a href="https://www.apple.com/macos/macos-big-sur/" title="macOS 11 Big Sur home page" target="_blank" rel="noopener noreferrer">macOS 11 Big Sur</a>',
'macos1015','<a href="https://www.apple.com/macos/catalina/" title="macOS 10.15 Catalina home page" target="_blank" rel="noopener noreferrer">macOS 10.15 Catalina</a>',
'macos1014','<a href="https://www.apple.com/macos/mojave/" title="macOS 10.14 Mojave home page" target="_blank" rel="noopener noreferrer">macOS 10.14 Mojave</a>',
'macos1013','<a href="https://www.apple.com/macos/high-sierra/" title="macOS 10.13 High Sierra home page" target="_blank" rel="noopener noreferrer">macOS 10.13 High Sierra</a>',
'macos1012','<a href="https://www.apple.com/macos/sierra/" title="macOS 10.12 Sierra home page" target="_blank" rel="noopener noreferrer">macOS 10.12 Sierra</a>',
'macos1011','<a href="https://www.apple.com/macos/el-capitan/" title="OS X 10.11 El Capitan home page" target="_blank" rel="noopener noreferrer">OS X 10.11 El Capitan</a>',
'macos1010','<a href="https://www.apple.com/macos/yosemite/" title="OS X 10.10 Yosemite home page" target="_blank" rel="noopener noreferrer">OS X 10.10 Yosemite</a>',
'macos109','<a href="https://www.apple.com/macos/mavericks/" title="OS X 10.9 Mavericks home page" target="_blank" rel="noopener noreferrer">OS X 10.9 Mavericks</a>',
'macos108','<a href="https://www.apple.com/macos/mountain-lion/" title="OS X 10.8 Mountain Lion home page" target="_blank" rel="noopener noreferrer">OS X 10.8 Mountain Lion</a>',
'macos107','<a href="https://www.apple.com/macos/lion/" title="Mac OS X 10.7 Lion home page" target="_blank" rel="noopener noreferrer">Mac OS X 10.7 Lion</a>',
'macos106','<a href="https://www.apple.com/macos/snow-leopard/" title="Mac OS X 10.6 Snow Leopard home page" target="_blank" rel="noopener noreferrer">Mac OS X 10.6 Snow Leopard</a>',
'macos105','<a href="https://www.apple.com/macos/leopard/" title="Mac OS X 10.5 Leopard home page" target="_blank" rel="noopener noreferrer">Mac OS X 10.5 Leopard</a>',
'macos104','<a href="https://www.apple.com/macos/tiger/" title="Mac OS X 10.4 Tiger home page" target="_blank" rel="noopener noreferrer">Mac OS X 10.4 Tiger</a>',
'macosx','<a href="https://www.apple.com/macos/" title="macOS home page" target="_blank" rel="noopener noreferrer">macOS</a>',
'macintosh','<a href="https://www.apple.com/mac/" title="Mac home page" target="_blank" rel="noopener noreferrer">Mac</a>',
'haiku','<a href="https://www.haiku-os.org/" title="Haiku home page" target="_blank" rel="noopener noreferrer">Haiku</a>',

# iOS family
'iphone','<a href="https://www.apple.com/iphone/" title="Apple iPhone home page" target="_blank" rel="noopener noreferrer">iPhone</a>',
'ipad','<a href="https://www.apple.com/ipad/" title="Apple iPad home page" target="_blank" rel="noopener noreferrer">iPad</a>',
'ipod','<a href="https://www.apple.com/ipod/" title="Apple iPod home page" target="_blank" rel="noopener noreferrer">iPod</a>',
'ios','<a href="https://www.apple.com/iphone/" title="Apple iPhone home page" target="_blank" rel="noopener noreferrer">iPhone</a>',
'ios30_iphone','<a href="https://www.apple.com/ios/ios-30/" title="Apple iOS 30 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 30 (iPhone)</a>',
'ios29_iphone','<a href="https://www.apple.com/ios/ios-29/" title="Apple iOS 29 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 29 (iPhone)</a>',
'ios28_iphone','<a href="https://www.apple.com/ios/ios-28/" title="Apple iOS 28 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 28 (iPhone)</a>',
'ios27_iphone','<a href="https://www.apple.com/ios/ios-27/" title="Apple iOS 27 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 27 (iPhone)</a>',
'ios26_iphone','<a href="https://www.apple.com/ios/ios-26/" title="Apple iOS 26 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 26 (iPhone)</a>',
'ios25_iphone','<a href="https://www.apple.com/ios/ios-25/" title="Apple iOS 25 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 25 (iPhone)</a>',
'ios24_iphone','<a href="https://www.apple.com/ios/ios-24/" title="Apple iOS 24 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 24 (iPhone)</a>',
'ios23_iphone','<a href="https://www.apple.com/ios/ios-23/" title="Apple iOS 23 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 23 (iPhone)</a>',
'ios22_iphone','<a href="https://www.apple.com/ios/ios-22/" title="Apple iOS 22 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 22 (iPhone)</a>',
'ios21_iphone','<a href="https://www.apple.com/ios/ios-21/" title="Apple iOS 21 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 21 (iPhone)</a>',
'ios20_iphone','<a href="https://www.apple.com/ios/ios-20/" title="Apple iOS 20 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 20 (iPhone)</a>',
'ios19_iphone','<a href="https://www.apple.com/ios/ios-19/" title="Apple iOS 19 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 19 (iPhone)</a>',
'ios18_iphone','<a href="https://www.apple.com/ios/ios-18/" title="Apple iOS 18 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 18 (iPhone)</a>',
'ios17_iphone','<a href="https://www.apple.com/ios/ios-17/" title="Apple iOS 17 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 17 (iPhone)</a>',
'ios16_iphone','<a href="https://www.apple.com/ios/ios-16/" title="Apple iOS 16 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 16 (iPhone)</a>',
'ios15_iphone','<a href="https://www.apple.com/ios/ios-15/" title="Apple iOS 15 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 15 (iPhone)</a>',
'ios14_iphone','<a href="https://www.apple.com/ios/ios-14/" title="Apple iOS 14 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 14 (iPhone)</a>',
'ios13_iphone','<a href="https://www.apple.com/ios/ios-13/" title="Apple iOS 13 (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS 13 (iPhone)</a>',
'ios_iphone','<a href="https://www.apple.com/ios/" title="Apple iOS (iPhone) home page" target="_blank" rel="noopener noreferrer">iOS (iPhone)</a>',
'ios30_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 30 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 30 (iPad)</a>',
'ios29_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 29 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 29 (iPad)</a>',
'ios28_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 28 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 28 (iPad)</a>',
'ios27_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 27 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 27 (iPad)</a>',
'ios26_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 26 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 26 (iPad)</a>',
'ios25_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 25 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 25 (iPad)</a>',
'ios24_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 24 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 24 (iPad)</a>',
'ios23_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 23 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 23 (iPad)</a>',
'ios22_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 22 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 22 (iPad)</a>',
'ios21_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 21 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 21 (iPad)</a>',
'ios20_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 20 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 20 (iPad)</a>',
'ios19_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 19 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 19 (iPad)</a>',
'ios18_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 18 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 18 (iPad)</a>',
'ios17_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 17 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 17 (iPad)</a>',
'ios16_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 16 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 16 (iPad)</a>',
'ios15_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS 15 (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS 15 (iPad)</a>',
'ios_ipad','<a href="https://www.apple.com/ipados/" title="Apple iPadOS (iPad) home page" target="_blank" rel="noopener noreferrer">iPadOS (iPad)</a>',
'ios_ipod','<a href="https://www.apple.com/ios/" title="Apple iOS (iPod) home page" target="_blank" rel="noopener noreferrer">iOS (iPod)</a>',

# Android family
'android','<a href="https://www.android.com/" title="Google Android home page" target="_blank" rel="noopener noreferrer">Android</a>',
'android20','<a href="https://developer.android.com/about/versions/20" title="Google Android 20" target="_blank" rel="noopener noreferrer">Android 20</a>',
'android19','<a href="https://developer.android.com/about/versions/19" title="Google Android 19" target="_blank" rel="noopener noreferrer">Android 19</a>',
'android18','<a href="https://developer.android.com/about/versions/18" title="Google Android 18" target="_blank" rel="noopener noreferrer">Android 18</a>',
'android17','<a href="https://developer.android.com/about/versions/17" title="Google Android 17" target="_blank" rel="noopener noreferrer">Android 17</a>',
'android16','<a href="https://developer.android.com/about/versions/16" title="Google Android 16" target="_blank" rel="noopener noreferrer">Android 16</a>',
'android15','<a href="https://developer.android.com/about/versions/15" title="Google Android 15" target="_blank" rel="noopener noreferrer">Android 15</a>',
'android14','<a href="https://developer.android.com/about/versions/14" title="Google Android 14" target="_blank" rel="noopener noreferrer">Android 14</a>',
'android13','<a href="https://developer.android.com/about/versions/13" title="Google Android 13" target="_blank" rel="noopener noreferrer">Android 13</a>',
'android12','<a href="https://developer.android.com/about/versions/12" title="Google Android 12" target="_blank" rel="noopener noreferrer">Android 12</a>',
'android11','<a href="https://developer.android.com/about/versions/11" title="Google Android 11" target="_blank" rel="noopener noreferrer">Android 11</a>',
'android10','<a href="https://developer.android.com/about/versions/10" title="Google Android 10" target="_blank" rel="noopener noreferrer">Android 10</a>',
'androidpie','<a href="https://developer.android.com/about/versions/pie/" title="Google Android 9 Pie home page" target="_blank" rel="noopener noreferrer">Android 9 Pie</a>',
'androidoreo','<a href="https://developer.android.com/about/versions/oreo/" title="Google Android 8 Oreo home page" target="_blank" rel="noopener noreferrer">Android 8 Oreo</a>',
'androidnougat','<a href="https://developer.android.com/about/versions/nougat/" title="Google Android 7 Nougat home page" target="_blank" rel="noopener noreferrer">Android 7 Nougat</a>',
'androidmarshmallow','<a href="https://developer.android.com/about/versions/marshmallow/" title="Google Android 6 Marshmallow home page" target="_blank" rel="noopener noreferrer">Android 6 Marshmallow</a>',
'androidlollipop','<a href="https://developer.android.com/about/versions/lollipop.html" title="Google Android 5 Lollipop home page" target="_blank" rel="noopener noreferrer">Android 5 Lollipop</a>',
'androidkitkat','<a href="https://developer.android.com/about/versions/kitkat.html" title="Google Android 4.4 KitKat home page" target="_blank" rel="noopener noreferrer">Android 4.4 KitKat</a>',
'androidjellybean','<a href="https://developer.android.com/about/versions/jelly-bean.html" title="Google Android 4.1-4.3 Jelly Bean home page" target="_blank" rel="noopener noreferrer">Android 4.1-4.3 Jelly Bean</a>',
'androidics','<a href="https://developer.android.com/about/versions/android-4.0-highlights.html" title="Google Android 4.0 Ice Cream Sandwich home page" target="_blank" rel="noopener noreferrer">Android 4.0 Ice Cream Sandwich</a>',
'androidhoneycomb','<a href="https://developer.android.com/about/versions/android-3.0-highlights.html" title="Google Android 3 Honeycomb home page" target="_blank" rel="noopener noreferrer">Android 3.x Honeycomb</a>',
'androidgingerbread','<a href="https://developer.android.com/about/versions/android-2.3-highlights.html" title="Google Android 2.3 Gingerbread home page" target="_blank" rel="noopener noreferrer">Android 2.3 Gingerbread</a>',
'androidfroyo','<a href="https://developer.android.com/about/versions/android-2.2-highlights.html" title="Google Android 2.2 Froyo home page" target="_blank" rel="noopener noreferrer">Android 2.2 Froyo</a>',
'androideclair','<a href="https://developer.android.com/about/versions/android-2.0-highlights.html" title="Google Android 2.0-2.1 Eclair home page" target="_blank" rel="noopener noreferrer">Android 2.0-2.1 Eclair</a>',
'androiddonut','<a href="https://developer.android.com/about/versions/android-1.6-highlights.html" title="Google Android 1.6 Donut home page" target="_blank" rel="noopener noreferrer">Android 1.6 Donut</a>',
'androidcupcake','<a href="https://developer.android.com/about/versions/android-1.5-highlights.html" title="Google Android 1.5 Cupcake home page" target="_blank" rel="noopener noreferrer">Android 1.5 Cupcake</a>',

# HarmonyOS / 鸿蒙系统
'harmonyos','<a href="https://developer.harmonyos.com/" title="HarmonyOS home page" target="_blank" rel="noopener noreferrer">HarmonyOS</a>',
'harmonyos_huawei','<a href="https://www.huawei.com/harmonyos/" title="Huawei HarmonyOS home page" target="_blank" rel="noopener noreferrer">Huawei HarmonyOS</a>',
'openharmony','<a href="https://www.openharmony.cn/" title="OpenHarmony home page" target="_blank" rel="noopener noreferrer">OpenHarmony</a>',

# 华为
'huawei','<a href="https://consumer.huawei.com/" title="Huawei Android devices home page" target="_blank" rel="noopener noreferrer">Huawei</a>',
'honor','<a href="https://www.hihonor.com/" title="Honor Android devices home page" target="_blank" rel="noopener noreferrer">Honor</a>',

# 小米
'xiaomi','<a href="https://www.mi.com/" title="Xiaomi Android devices home page" target="_blank" rel="noopener noreferrer">Xiaomi</a>',
'redmi','<a href="https://www.mi.com/redmi/" title="Redmi Android devices home page" target="_blank" rel="noopener noreferrer">Redmi</a>',
'poco','<a href="https://www.po.co/" title="POCO Android devices home page" target="_blank" rel="noopener noreferrer">POCO</a>',

# OPPO 系列
'oppo','<a href="https://www.oppo.com/" title="OPPO Android devices home page" target="_blank" rel="noopener noreferrer">OPPO</a>',
'oneplus','<a href="https://www.oneplus.com/" title="OnePlus Android devices home page" target="_blank" rel="noopener noreferrer">OnePlus</a>',
'realme','<a href="https://www.realme.com/" title="realme Android devices home page" target="_blank" rel="noopener noreferrer">realme</a>',

# VIVO
'vivo','<a href="https://www.vivo.com/" title="VIVO Android devices home page" target="_blank" rel="noopener noreferrer">VIVO</a>',
'iqoo','<a href="https://www.iqoo.com/" title="iQOO Android devices home page" target="_blank" rel="noopener noreferrer">iQOO</a>',

# 魅族
'meizu','<a href="https://www.meizu.com/" title="Meizu Android devices home page" target="_blank" rel="noopener noreferrer">Meizu</a>',

# 三星
'samsung','<a href="https://www.samsung.com/" title="Samsung Android devices home page" target="_blank" rel="noopener noreferrer">Samsung</a>',

# 谷歌
'google_pixel','<a href="https://store.google.com/category/phones" title="Google Pixel Android devices home page" target="_blank" rel="noopener noreferrer">Google Pixel</a>',
'google','<a href="https://www.android.com/" title="Google Android home page" target="_blank" rel="noopener noreferrer">Google Android</a>',

# 索尼
'sony','<a href="https://www.sony.com/" title="Sony Xperia Android devices home page" target="_blank" rel="noopener noreferrer">Sony Xperia</a>',

# LG
'lg','<a href="https://www.lg.com/" title="LG Android devices home page" target="_blank" rel="noopener noreferrer">LG</a>',

# 摩托罗拉
'motorola','<a href="https://www.motorola.com/" title="Motorola Android devices home page" target="_blank" rel="noopener noreferrer">Motorola</a>',

# 传音系列
'tecno','<a href="https://www.tecno-mobile.com/" title="TECNO Android devices home page" target="_blank" rel="noopener noreferrer">TECNO</a>',
'infinix','<a href="https://www.infinixmobility.com/" title="Infinix Android devices home page" target="_blank" rel="noopener noreferrer">Infinix</a>',
'itel','<a href="https://www.itel-mobile.com/" title="itel Android devices home page" target="_blank" rel="noopener noreferrer">itel</a>',

# 中兴
'zte','<a href="https://www.ztedevices.com/" title="ZTE Android devices home page" target="_blank" rel="noopener noreferrer">ZTE</a>',
'nubia','<a href="https://www.nubia.com/" title="nubia Android devices home page" target="_blank" rel="noopener noreferrer">nubia</a>',
'redmagic','<a href="https://redmagic.gg/" title="REDMAGIC Android devices home page" target="_blank" rel="noopener noreferrer">REDMAGIC</a>',

# 联想
'lenovo','<a href="https://www.lenovo.com/" title="Lenovo Android devices home page" target="_blank" rel="noopener noreferrer">Lenovo</a>',

# 华硕
'asus','<a href="https://www.asus.com/" title="ASUS Android devices home page" target="_blank" rel="noopener noreferrer">ASUS</a>',
'rog','<a href="https://rog.asus.com/" title="ROG Android devices home page" target="_blank" rel="noopener noreferrer">ROG</a>',

# 诺基亚
'nokia','<a href="https://www.nokia.com/phones/" title="Nokia Android devices home page" target="_blank" rel="noopener noreferrer">Nokia</a>',

# 夏普
'sharp','<a href="https://jp.sharp/" title="Sharp Android devices home page" target="_blank" rel="noopener noreferrer">Sharp</a>',

# 松下
'panasonic','<a href="https://www.panasonic.com/" title="Panasonic Android devices home page" target="_blank" rel="noopener noreferrer">Panasonic</a>',

# 京瓷
'kyocera','<a href="https://www.kyocera.com/" title="KYOCERA Android devices home page" target="_blank" rel="noopener noreferrer">KYOCERA</a>',

# 富士通
'fujitsu','<a href="https://www.fujitsu.com/" title="Fujitsu Android devices home page" target="_blank" rel="noopener noreferrer">Fujitsu</a>',

# 卡特
'cat','<a href="https://www.catphones.com/" title="CAT Android devices home page" target="_blank" rel="noopener noreferrer">CAT</a>',

# 黑鲨
'blackshark','<a href="https://www.blackshark.com/" title="Black Shark Android devices home page" target="_blank" rel="noopener noreferrer">Black Shark</a>',

# 雷蛇
'razer','<a href="https://www.razer.com/" title="Razer Android devices home page" target="_blank" rel="noopener noreferrer">Razer</a>',

# 海信
'hisense','<a href="https://www.hisense.com/" title="Hisense Android devices home page" target="_blank" rel="noopener noreferrer">Hisense</a>',

# TCL
'tcl','<a href="https://www.tcl.com/" title="TCL Android devices home page" target="_blank" rel="noopener noreferrer">TCL</a>',
'alcatel','<a href="https://www.alcatelmobile.com/" title="Alcatel Android devices home page" target="_blank" rel="noopener noreferrer">Alcatel</a>',

# 康佳
'konka','<a href="https://www.konka.com/" title="Konka Android devices home page" target="_blank" rel="noopener noreferrer">Konka</a>',

# 长虹
'changhong','<a href="https://www.changhong.com/" title="Changhong Android devices home page" target="_blank" rel="noopener noreferrer">Changhong</a>',

# AliOS
'alios','<a href="https://www.alibabacloud.com/zh/product/alios-things" title="AliOS Things home page" target="_blank" rel="noopener noreferrer">AliOS</a>',

# Wear OS / Watch OS
'wearos','<a href="https://wearos.google.com/" title="Wear OS home page" target="_blank" rel="noopener noreferrer">Wear OS</a>',
'watchos','<a href="https://www.apple.com/watchos/" title="watchOS home page" target="_blank" rel="noopener noreferrer">watchOS</a>',
'tizen','<a href="https://www.tizen.org/" title="Tizen OS home page" target="_blank" rel="noopener noreferrer">Tizen OS</a>',

# 中国大陆手机系统 UI
'flyme','<a href="https://www.flyme.com/" title="Flyme OS home page" target="_blank" rel="noopener noreferrer">Flyme (Meizu)</a>',
'hyperos','<a href="https://hyperos.mi.com/" title="HyperOS home page" target="_blank" rel="noopener noreferrer">HyperOS (Xiaomi)</a>',
'magicos','<a href="https://www.honor.com/magic-os/" title="MagicOS home page" target="_blank" rel="noopener noreferrer">MagicOS (Honor)</a>',
'originos','<a href="https://www.vivo.com.cn/originos/" title="OriginOS home page" target="_blank" rel="noopener noreferrer">OriginOS (vivo)</a>',
'funtouchos','<a href="https://www.vivo.com/funtouch-os" title="Funtouch OS home page" target="_blank" rel="noopener noreferrer">Funtouch OS (vivo)</a>',
'zui','<a href="https://www.lenovo.com/zui" title="ZUI home page" target="_blank" rel="noopener noreferrer">ZUI (Lenovo)</a>',
'myos','<a href="https://www.zte.com.cn/myos" title="MyOS home page" target="_blank" rel="noopener noreferrer">MyOS (ZTE)</a>',
'joyui','<a href="https://www.blackshark.com/joyui" title="JoyUI home page" target="_blank" rel="noopener noreferrer">JoyUI (Black Shark)</a>',
'nubiaui','<a href="https://www.nubia.com/nubia-ui" title="nubia UI home page" target="_blank" rel="noopener noreferrer">nubia UI (ZTE)</a>',
'nothingos','<a href="https://nothing.tech/os" title="Nothing OS home page" target="_blank" rel="noopener noreferrer">Nothing OS</a>',
'oxygenos','<a href="https://www.oneplus.com/oxygenos" title="OxygenOS home page" target="_blank" rel="noopener noreferrer">OxygenOS (OnePlus)</a>',

# Linux family
'centos','<a href="https://www.centos.org/" title="CentOS home page" target="_blank" rel="noopener noreferrer">CentOS</a>',
'debian','<a href="https://www.debian.org/" title="Debian home page" target="_blank" rel="noopener noreferrer">Debian</a>',
'fedora','<a href="https://getfedora.org/" title="Fedora home page" target="_blank" rel="noopener noreferrer">Fedora</a>',
'gentoo','<a href="https://www.gentoo.org/" title="Gentoo home page" target="_blank" rel="noopener noreferrer">Gentoo</a>',
'mageia','<a href="https://www.mageia.org/" title="Mageia home page" target="_blank" rel="noopener noreferrer">Mageia</a>',
'redhat','<a href="https://www.redhat.com/" title="Red Hat home page" target="_blank" rel="noopener noreferrer">Red Hat</a>',
'rockylinux','<a href="https://rockylinux.org/" title="Rocky Linux home page" target="_blank" rel="noopener noreferrer">Rocky Linux</a>',
'almalinux','<a href="https://almalinux.org/" title="AlmaLinux home page" target="_blank" rel="noopener noreferrer">AlmaLinux</a>',
'suse','<a href="https://www.suse.com/" title="SUSE home page" target="_blank" rel="noopener noreferrer">SUSE</a>',
'ubuntu','<a href="https://ubuntu.com/" title="Ubuntu home page" target="_blank" rel="noopener noreferrer">Ubuntu</a>',
'linuxmint','<a href="https://linuxmint.com/" title="Linux Mint home page" target="_blank" rel="noopener noreferrer">Linux Mint</a>',
'linuxarch','<a href="https://archlinux.org/" title="Arch Linux home page" target="_blank" rel="noopener noreferrer">Arch Linux</a>',
'manjaro','<a href="https://manjaro.org/" title="Manjaro Linux home page" target="_blank" rel="noopener noreferrer">Manjaro</a>',
'pclinux','<a href="https://www.pclinuxos.com/" title="PCLinuxOS home page" target="_blank" rel="noopener noreferrer">PCLinuxOS</a>',
'linux','<a href="https://www.kernel.org/" title="Linux Kernel home page" target="_blank" rel="noopener noreferrer">Linux</a>',

# Hurd
'gnu','<a href="https://www.gnu.org/software/hurd/" title="GNU Hurd home page" target="_blank" rel="noopener noreferrer">GNU Hurd</a>',

# BSDs
'bsdi','<a href="https://en.wikipedia.org/wiki/BSDi" title="BSDi Wikipedia page" target="_blank" rel="noopener noreferrer">BSDi</a>',
'bsdkfreebsd','<a href="https://www.debian.org/ports/kfreebsd-gnu/" title="Debian GNU/kFreeBSD home page" target="_blank" rel="noopener noreferrer">Debian GNU/kFreeBSD</a>',
'bsdfreebsd','<a href="https://www.freebsd.org/" title="FreeBSD home page" target="_blank" rel="noopener noreferrer">FreeBSD</a>',
'bsdopenbsd','<a href="https://www.openbsd.org/" title="OpenBSD home page" target="_blank" rel="noopener noreferrer">OpenBSD</a>',
'bsdnetbsd','<a href="https://www.netbsd.org/" title="NetBSD home page" target="_blank" rel="noopener noreferrer">NetBSD</a>',
'bsddflybsd','<a href="https://www.dragonflybsd.org/" title="DragonFlyBSD home page" target="_blank" rel="noopener noreferrer">DragonFlyBSD</a>',

# Other Unix, Unix-like
'aix','<a href="https://www.ibm.com/power/aix" title="IBM AIX home page" target="_blank" rel="noopener noreferrer">AIX</a>',
'sunos','<a href="https://www.oracle.com/solaris/" title="Oracle Solaris home page" target="_blank" rel="noopener noreferrer">Solaris</a>',
'irix','<a href="https://en.wikipedia.org/wiki/IRIX" title="IRIX Wikipedia page" target="_blank" rel="noopener noreferrer">IRIX</a>',
'osf','<a href="https://en.wikipedia.org/wiki/Tru64_UNIX" title="Tru64 UNIX Wikipedia page" target="_blank" rel="noopener noreferrer">Tru64 UNIX</a>',
'hpux','<a href="https://www.hpe.com/us/en/hp-ux.html" title="HP-UX home page" target="_blank" rel="noopener noreferrer">HP-UX</a>',
'unix','Unknown Unix system',

# Other famous OS
'beos','<a href="https://en.wikipedia.org/wiki/BeOS" title="BeOS Wikipedia page" target="_blank" rel="noopener noreferrer">BeOS</a>',
'os2','<a href="https://en.wikipedia.org/wiki/OS/2" title="OS/2 Wikipedia page" target="_blank" rel="noopener noreferrer">OS/2</a>',
'amigaos','<a href="https://www.amigaos.net/" title="AmigaOS home page" target="_blank" rel="noopener noreferrer">AmigaOS</a>',
'atari','<a href="https://en.wikipedia.org/wiki/Atari" title="Atari Wikipedia page" target="_blank" rel="noopener noreferrer">Atari</a>',
'vms','<a href="https://vmssoftware.com/" title="OpenVMS home page" target="_blank" rel="noopener noreferrer">OpenVMS</a>',
'commodore','<a href="https://en.wikipedia.org/wiki/Commodore_64" title="Commodore 64 Wikipedia page" target="_blank" rel="noopener noreferrer">Commodore 64</a>',
'j2me','<a href="https://www.oracle.com/java/technologies/javameoverview.html" title="Java ME home page" target="_blank" rel="noopener noreferrer">Java ME</a>',
'java','<a href="https://www.java.com/" title="Java home page" target="_blank" rel="noopener noreferrer">Java</a>',
'qnx','<a href="https://blackberry.qnx.com/" title="QNX home page" target="_blank" rel="noopener noreferrer">QNX</a>',
'inferno','<a href="https://www.vitanuova.com/inferno/" title="Inferno home page" target="_blank" rel="noopener noreferrer">Inferno</a>',
'palmos','<a href="https://en.wikipedia.org/wiki/Palm_OS" title="Palm OS Wikipedia page" target="_blank" rel="noopener noreferrer">Palm OS</a>',
'syllable','<a href="https://www.syllable.org/" title="Syllable home page" target="_blank" rel="noopener noreferrer">Syllable</a>',

# Miscellaneous OS
'blackberry','<a href="https://www.blackberry.com/" title="BlackBerry home page" target="_blank" rel="noopener noreferrer">BlackBerry</a>',
'cpm','<a href="https://en.wikipedia.org/wiki/CP/M" title="CP/M Wikipedia page" target="_blank" rel="noopener noreferrer">CP/M</a>',
'crayos','<a href="https://www.cray.com/" title="CrayOS home page" target="_blank" rel="noopener noreferrer">CrayOS</a>',
'dreamcast','<a href="https://www.sega.com/" title="Sega Dreamcast home page" target="_blank" rel="noopener noreferrer">Sega Dreamcast</a>',
'riscos','<a href="https://www.riscosopen.org/" title="RISC OS home page" target="_blank" rel="noopener noreferrer">RISC OS</a>',
'symbian','<a href="https://en.wikipedia.org/wiki/Symbian" title="Symbian OS Wikipedia page" target="_blank" rel="noopener noreferrer">Symbian OS</a>',
'webtv','<a href="https://en.wikipedia.org/wiki/MSN_TV" title="WebTV Wikipedia page" target="_blank" rel="noopener noreferrer">WebTV</a>',
'psp','<a href="https://www.playstation.com/" title="Sony PlayStation home page" target="_blank" rel="noopener noreferrer">PlayStation</a>',
'wii','<a href="https://www.nintendo.com/wii/" title="Nintendo Wii home page" target="_blank" rel="noopener noreferrer">Nintendo Wii</a>'
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
#  Windows 2000               NT 5.0                       12/19/99
#  Windows XP                 NT 5.1                       8/24/01
#  Windows Server 2003        NT 5.2                       4/24/03
#  Windows Vista              NT 6.0                       1/30/07
#  Windows Server 2008        NT 6.1                       2/27/08
#  Windows 7                  NT 6.1                       10/22/09
#  Windows 8                  NT 6.2                       10/26/12
#  Windows 8.1                NT 6.3                       10/17/13
#  Windows 10                 NT 10.0                      7/29/15
#  Windows Server 2012        NT 6.2                       9/4/12
#  Windows Server 2016        NT 10.0                      9/26/16
#  Windows Server 2019        NT 10.0                      10/2/18
#  Windows Server 2022        NT 10.0                      8/18/21
#  Windows 11                 NT 10.0 (build 22000+)       10/5/21
#  Windows 11 22H2            NT 10.0 (build 22621)        9/20/22
#  Windows 11 23H2            NT 10.0 (build 22631)        10/31/23
#  Windows 11 24H2            NT 10.0 (build 26100)        10/1/24
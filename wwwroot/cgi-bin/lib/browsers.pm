# AWSTATS UNIFIED BROWSERS DATABASE (2026)
#-------------------------------------------------------
# 统一的浏览器识别数据库 - 合并桌面和移动设备识别
# 支持:
#   - 桌面浏览器: Chrome, Firefox, Safari, Edge, Brave, Vivaldi, Opera, etc.
#   - 移动设备: iOS, Android, HarmonyOS
#   - 移动品牌: Samsung, Huawei, Xiaomi, OPPO, VIVO, etc.
#   - 平板设备: iPad, Android Tablet, Kindle
#   - 可穿戴设备: WatchOS, Wear OS
#   - 电视设备: Apple TV, Android TV, WebOS, Tizen
#   - 抓取器/机器人: Googlebot, Bingbot, etc.
#-------------------------------------------------------

#------------------------------------------------------------------------------
# 浏览器家族分组
#------------------------------------------------------------------------------
%BrowsersFamily = (
    # 桌面浏览器
    'msie'      => 1,
    'edge'      => 2,
    'firefox'   => 3,
    'netscape'  => 4,
    'svn'       => 5,
    'opera'     => 6,
    'safari'    => 7,
    'chrome'    => 8,
    'konqueror' => 9,
    'brave'     => 10,
    'vivaldi'   => 11,
    'yandex'    => 12,
    
    # 移动浏览器/设备
    'ios_safari'        => 20,
    'ios_chrome'        => 21,
    'ios_firefox'       => 22,
    'ios_edge'          => 23,
    'ios_opera'         => 24,
    'android_chrome'    => 30,
    'android_firefox'   => 31,
    'android_edge'      => 32,
    'android_opera'     => 33,
    'harmonyos'         => 40,
    'samsung'           => 50,
    'huawei'            => 51,
    'xiaomi'            => 52,
    'oppo'              => 53,
    'vivo'              => 54,
    'oneplus'           => 55,
    'realme'            => 56,
    'google_pixel'      => 57,
    'other_android'     => 58,
    'tablet'            => 60,
    'wearable'          => 70,
    'tv'                => 80,
    'bot'               => 90,
);

#------------------------------------------------------------------------------
# 浏览器搜索顺序（移动优先，因为移动 UA 更具体）
#------------------------------------------------------------------------------
@BrowsersSearchIDOrder = (

    # --- iOS 设备 ---
    'iphone', 'ipad', 'ipod',
    
    # --- iOS 浏览器 ---
    'crios', 'fxios', 'edgios', 'opios',
    
    # --- 平板设备 ---
    'tablet', 'android.*tablet', 'ipad', 'kindle', 'kfapwi',
    'playbook', 'nexus 7', 'nexus 10', 'galaxy tab',
    
    # --- HarmonyOS 设备 ---
    'harmonyos', 'harmony', 'huawei.*harmony',
    'mis-al00', 'vog-[al]', 'ely-[al]', 'mar-[al]', 'lya-[al]',
    'nova', 'mate', 'p[0-9]+',
    
    # --- 三星系列 ---
    'sm-[a-z][0-9]+', 'samsung', 'galaxy', 'samsungbrowser',
    
    # --- 华为/荣耀系列 ---
    'huawei', 'honor', 'hw-', 'huaweibrowser',
    
    # --- 小米系列 ---
    'xiaomi', 'redmi', 'poco', 'mi[0-9]+', 'm[0-9]{4}',
    'miuibrowser', 'miui',
    
    # --- OPPO/一加/realme ---
    'oppo', 'oneplus', 'realme', 'cph[0-9]+', 'rmx[0-9]+',
    'oppobrowser', 'coloros',
    
    # --- VIVO/iQOO ---
    'vivo', 'iqoo', 'v[0-9]{4}', 'vivobrowser', 'funtouch', 'originos',
    
    # --- 谷歌系列 ---
    'pixel', 'google', 'nexus',
    
    # --- 其他中国品牌 ---
    'meizu', 'flyme', 'lenovo', 'zuk', 'zte', 'nubia', 'blackshark',
    'tecno', 'infinix', 'itel', 'coolpad', 'gionee', 'leeco',
    'smartisan', 'qihoo',
    
    # --- 其他国际品牌 ---
    'asus', 'rog', 'zenfone', 'nokia', 'sony', 'xperia', 'lg',
    'motorola', 'moto', 'htc', 'blackberry', 'acatel', 'alcatel',
    
    # --- Android 浏览器 ---
    'ucbrowser', 'ucweb', 'quark', 'baiduboxapp', 'baidubrowser',
    'sogou', 'qqbrowser', 'qzone', 'mqqbrowser', 'micromessenger',
    'wechat', 'dingtalk', 'ali', 'taobao', 'juc',
    
    # --- Android WebView ---
    'android webview', 'webview', 'android',
    
    # --- 移动版桌面浏览器 ---
    'mobile.*chrome', 'mobile.*firefox', 'mobile.*edge', 'mobile.*opera',
    
    # --- 可穿戴设备 ---
    'wear os', 'android wear', 'watch os', 'apple watch', 'galaxy watch',
    
    # --- 电视设备 ---
    'apple tv', 'android tv', 'googletv', 'smart-tv', 'webos',
    'tizen', 'roku', 'firetv', 'chromecast', 'kodi',
    
    # --- 现代桌面浏览器 ---
    'edg', 'edge', 'chrome', 'firefox', 'safari', 'brave',
    'vivaldi', 'yabrowser', 'whale', 'opr', 'opera',
    
    # --- 传统桌面浏览器 ---
    'konqueror', 'netscape', 'msie', 'ie', 'trident',
    
    # --- 包管理工具 ---
    'composer', 'npm', 'pip', 'cargo', 'gem', 'uv', 'conda',
    'rustc', 'bundler', 'poetry', 'yarn', 'pnpm',
    
    # --- 抓取器/机器人 ---
    'googlebot-mobile', 'googlebot', 'bingbot', 'yandexbot',
    'baiduspider', 'facebookexternalhit', 'twitterbot', 'linkedinbot',
    'applebot', 'slurp', 'duckduckbot', 'semrushbot', 'ahrefsbot',
    'mj12bot', 'uptimerobot', 'pingdom', 'newrelic', 'datadog',
    
    # --- 其他移动浏览器 ---
    'opera mini', 'silk', 'puffin', 'dolphin', 'cm browser',
    
    # --- 社交媒体应用内浏览器 ---
    'instagram', 'facebook', 'twitter', 'snapchat', 'tiktok',
    'weibo', 'line', 'kakao', 'telegram', 'whatsapp',
    
    # --- 站点抓取器 ---
    'cloudflare', 'grabber', 'teleport', 'webcapture', 'webcopier',
    
    # --- 媒体播放器 ---
    'real', 'winamp', 'windows-media-player', 'audion', 'freeamp',
    'itunes', 'jetaudio', 'mint_audio', 'mpg123', 'mplayer',
    'nsplayer', 'qts', 'quicktime', 'sonique', 'uplayer',
    'xaudio', 'xine', 'xmms', 'gstreamer',
    
    # --- RSS 阅读器 ---
    'abilon', 'aggrevator', 'aiderss', 'akregator', 'applesyndication',
    'betanews_reader', 'blogbridge', 'cyndicate', 'feeddemon',
    'feedreader', 'feedtools', 'greatnews', 'gregarius', 'hatena_rss',
    'jetbrains_omea', 'liferea', 'netnewswire', 'newsfire', 'newsgator',
    'newzcrawler', 'plagger', 'pluck', 'potu', 'pubsub-rss-reader',
    'pulpfiction', 'rssbandit', 'rssreader', 'rssowl', 'rssxpress',
    'sage', 'sharpreader', 'shrook', 'straw', 'syndirella', 'vienna',
    'wizz rss news reader', 'feedly', 'inoreader', 'newsblur',
    'flipboard', 'pocket',
    
    # --- 开发工具 ---
    'curl', 'wget', 'python-requests', 'go-http-client', 'java',
    'ruby', 'node-fetch', 'axios', 'postman', 'insomnia',
    'adobeair', 'apt', 'analogx_proxy', 'gnome-vfs', 'neon',
    'csscheck', 'httrack', 'fdm', 'javaws', 'fget', 'chilkat',
    'webdownloader for x', 'w3m', 'wdg_validator', 'w3c_validator',
    'jigsaw', 'webreaper', 'webzip', 'staroffice', 'gnus', 'nikto',
    'download master', 'microsoft-webdav-miniredir',
    'microsoft data access internet publishing provider',
    'POE-Component-Client-HTTP',
    
    # --- 其他浏览器 ---
    'elinks', 'firebird', 'go!zilla', 'icab', 'links', 'lynx',
    'omniweb', '22acidownload', 'abrowse', 'aol-iweng', 'amaya',
    'amigavoyager', 'arora', 'aweb', 'charon', 'donzilla', 'seamonkey',
    'flock', 'minefield', 'bonecho', 'granparadiso', 'songbird',
    'strata', 'sylera', 'kazehakase', 'prism', 'icecat', 'iceape',
    'iceweasel', 'palemoon', 'waterfox', 'basilisk', 'w3clinemode',
    'bpftp', 'camino', 'chimera', 'cyberdog', 'dillo', 'xchaos_arachne',
    'doris', 'dreamcast', 'xbox', 'downloadagent', 'ecatch',
    'emailsiphon', 'encompass', 'epiphany', 'friendlyspider', 'fresco',
    'galeon', 'flashget', 'freshdownload', 'getright', 'leechget',
    'netants', 'headdump', 'hotjava', 'ibrowse', 'intergo', 'k-meleon',
    'k-ninja', 'linemodebrowser', 'lotus-notes', 'macweb', 'multizilla',
    'ncsa_mosaic', 'netcaptor', 'netpositive', 'nutscrape',
    'msfrontpageexpress', 'contiki', 'emacs-w3', 'phoenix', 'shiira',
    'tzgeturl', 'viking', 'webfetcher', 'webexplorer', 'webmirror',
    'webvcr', 'qnx svoyager', 'webpositive', 'electron', 'phantomjs',
    'slimerjs',
    
    # --- 兜底规则 ---
    'mozilla', 'libwww', 'lwp', 'mobile'
);

#------------------------------------------------------------------------------
# 浏览器显示名称
#------------------------------------------------------------------------------
%BrowsersHashIDLib = (

    # --- iOS 设备 ---
    'iphone' => '<a href="https://www.apple.com/iphone/" title="Apple iPhone" target="_blank" rel="noopener noreferrer">iPhone</a>',
    'ipad' => '<a href="https://www.apple.com/ipad/" title="Apple iPad" target="_blank" rel="noopener noreferrer">iPad</a>',
    'ipod' => '<a href="https://www.apple.com/ipod/" title="Apple iPod" target="_blank" rel="noopener noreferrer">iPod Touch</a>',
    
    # --- iOS 浏览器 ---
    'crios' => '<a href="https://www.google.com/chrome" title="Chrome for iOS" target="_blank" rel="noopener noreferrer">Chrome for iOS</a>',
    'fxios' => '<a href="https://www.mozilla.org/firefox/ios/" title="Firefox for iOS" target="_blank" rel="noopener noreferrer">Firefox for iOS</a>',
    'edgios' => '<a href="https://www.microsoft.com/edge" title="Edge for iOS" target="_blank" rel="noopener noreferrer">Edge for iOS</a>',
    'opios' => '<a href="https://www.opera.com" title="Opera for iOS" target="_blank" rel="noopener noreferrer">Opera for iOS</a>',
    
    # --- 平板设备 ---
    'tablet' => '<a href="#" title="Tablet Device" target="_blank" rel="noopener noreferrer">Tablet</a>',
    'kindle' => '<a href="https://www.amazon.com/kindle" title="Amazon Kindle" target="_blank" rel="noopener noreferrer">Amazon Kindle</a>',
    'galaxy tab' => '<a href="https://www.samsung.com/tablets/" title="Samsung Galaxy Tab" target="_blank" rel="noopener noreferrer">Samsung Galaxy Tab</a>',
    
    # --- HarmonyOS ---
    'harmonyos' => '<a href="https://www.harmonyos.com" title="HarmonyOS" target="_blank" rel="noopener noreferrer">HarmonyOS</a>',
    
    # --- 移动品牌 ---
    'huawei' => '<a href="https://consumer.huawei.com" title="Huawei" target="_blank" rel="noopener noreferrer">Huawei</a>',
    'honor' => '<a href="https://www.hihonor.com" title="Honor" target="_blank" rel="noopener noreferrer">Honor</a>',
    'huaweibrowser' => '<a href="https://consumer.huawei.com" title="Huawei Browser" target="_blank" rel="noopener noreferrer">Huawei Browser</a>',
    'xiaomi' => '<a href="https://www.mi.com" title="Xiaomi" target="_blank" rel="noopener noreferrer">Xiaomi</a>',
    'redmi' => '<a href="https://www.mi.com/redmi" title="Redmi" target="_blank" rel="noopener noreferrer">Redmi</a>',
    'poco' => '<a href="https://www.po.co" title="POCO" target="_blank" rel="noopener noreferrer">POCO</a>',
    'miuibrowser' => '<a href="https://www.mi.com" title="MIUI Browser" target="_blank" rel="noopener noreferrer">MIUI Browser</a>',
    'samsung' => '<a href="https://www.samsung.com" title="Samsung Galaxy" target="_blank" rel="noopener noreferrer">Samsung Galaxy</a>',
    'samsungbrowser' => '<a href="https://www.samsung.com/in/apps/samsung-internet/" title="Samsung Internet" target="_blank" rel="noopener noreferrer">Samsung Internet</a>',
    'oppo' => '<a href="https://www.oppo.com" title="OPPO" target="_blank" rel="noopener noreferrer">OPPO</a>',
    'oneplus' => '<a href="https://www.oneplus.com" title="OnePlus" target="_blank" rel="noopener noreferrer">OnePlus</a>',
    'realme' => '<a href="https://www.realme.com" title="realme" target="_blank" rel="noopener noreferrer">realme</a>',
    'oppobrowser' => '<a href="https://www.oppo.com" title="OPPO Browser" target="_blank" rel="noopener noreferrer">OPPO Browser</a>',
    'vivo' => '<a href="https://www.vivo.com" title="VIVO" target="_blank" rel="noopener noreferrer">VIVO</a>',
    'iqoo' => '<a href="https://www.iqoo.com" title="iQOO" target="_blank" rel="noopener noreferrer">iQOO</a>',
    'vivobrowser' => '<a href="https://www.vivo.com" title="VIVO Browser" target="_blank" rel="noopener noreferrer">VIVO Browser</a>',
    'meizu' => '<a href="https://www.meizu.com" title="Meizu" target="_blank" rel="noopener noreferrer">Meizu</a>',
    'lenovo' => '<a href="https://www.lenovo.com" title="Lenovo" target="_blank" rel="noopener noreferrer">Lenovo</a>',
    'zte' => '<a href="https://www.zte.com.cn" title="ZTE" target="_blank" rel="noopener noreferrer">ZTE</a>',
    'nubia' => '<a href="https://www.nubia.com" title="nubia" target="_blank" rel="noopener noreferrer">nubia</a>',
    'blackshark' => '<a href="https://www.blackshark.com" title="Black Shark" target="_blank" rel="noopener noreferrer">Black Shark</a>',
    'tecno' => '<a href="https://www.tecno-mobile.com" title="TECNO" target="_blank" rel="noopener noreferrer">TECNO</a>',
    'infinix' => '<a href="https://www.infinixmobility.com" title="Infinix" target="_blank" rel="noopener noreferrer">Infinix</a>',
    'itel' => '<a href="https://www.itel-mobile.com" title="itel" target="_blank" rel="noopener noreferrer">itel</a>',
    'asus' => '<a href="https://www.asus.com" title="ASUS" target="_blank" rel="noopener noreferrer">ASUS</a>',
    'rog' => '<a href="https://rog.asus.com" title="ROG Phone" target="_blank" rel="noopener noreferrer">ROG Phone</a>',
    'nokia' => '<a href="https://www.nokia.com" title="Nokia" target="_blank" rel="noopener noreferrer">Nokia</a>',
    'sony' => '<a href="https://www.sony.com" title="Sony Xperia" target="_blank" rel="noopener noreferrer">Sony Xperia</a>',
    'lg' => '<a href="https://www.lg.com" title="LG" target="_blank" rel="noopener noreferrer">LG</a>',
    'motorola' => '<a href="https://www.motorola.com" title="Motorola" target="_blank" rel="noopener noreferrer">Motorola</a>',
    'pixel' => '<a href="https://store.google.com/category/phones" title="Google Pixel" target="_blank" rel="noopener noreferrer">Google Pixel</a>',
    'google' => '<a href="https://www.google.com" title="Google" target="_blank" rel="noopener noreferrer">Google</a>',
    'blackberry' => '<a href="https://www.blackberry.com" title="BlackBerry" target="_blank" rel="noopener noreferrer">BlackBerry</a>',
    'htc' => '<a href="https://www.htc.com" title="HTC" target="_blank" rel="noopener noreferrer">HTC</a>',
    'alcatel' => '<a href="https://www.alcatelmobile.com" title="Alcatel" target="_blank" rel="noopener noreferrer">Alcatel</a>',
    
    # --- Android 浏览器 ---
    'android' => '<a href="https://www.android.com" title="Android Browser" target="_blank" rel="noopener noreferrer">Android WebView</a>',
    'ucbrowser' => '<a href="https://www.ucweb.com" title="UC Browser" target="_blank" rel="noopener noreferrer">UC Browser</a>',
    'quark' => '<a href="https://quark.ucweb.com" title="Quark Browser" target="_blank" rel="noopener noreferrer">Quark Browser</a>',
    'baiduboxapp' => '<a href="https://mbrowser.baidu.com" title="Baidu Browser" target="_blank" rel="noopener noreferrer">Baidu Browser</a>',
    'qqbrowser' => '<a href="https://browser.qq.com" title="QQ Browser" target="_blank" rel="noopener noreferrer">QQ Browser</a>',
    'sogou' => '<a href="https://browser.sogou.com" title="Sogou Browser" target="_blank" rel="noopener noreferrer">Sogou Browser</a>',
    'micromessenger' => '<a href="https://weixin.qq.com" title="WeChat" target="_blank" rel="noopener noreferrer">WeChat</a>',
    'dingtalk' => '<a href="https://www.dingtalk.com" title="DingTalk" target="_blank" rel="noopener noreferrer">DingTalk</a>',
    
    # --- 移动版桌面浏览器 ---
    'chrome' => '<a href="https://www.google.com/chrome" title="Chrome" target="_blank" rel="noopener noreferrer">Chrome</a>',
    'firefox' => '<a href="https://www.mozilla.org/firefox/" title="Firefox" target="_blank" rel="noopener noreferrer">Firefox</a>',
    'safari' => '<a href="https://www.apple.com/safari/" title="Safari" target="_blank" rel="noopener noreferrer">Safari</a>',
    'edge' => '<a href="https://www.microsoft.com/edge" title="Microsoft Edge" target="_blank" rel="noopener noreferrer">Microsoft Edge</a>',
    'edg' => '<a href="https://www.microsoft.com/edge" title="Microsoft Edge (Chromium)" target="_blank" rel="noopener noreferrer">Microsoft Edge (Chromium)</a>',
    'opera' => '<a href="https://www.opera.com" title="Opera" target="_blank" rel="noopener noreferrer">Opera</a>',
    'opr' => '<a href="https://www.opera.com" title="Opera" target="_blank" rel="noopener noreferrer">Opera</a>',
    'brave' => '<a href="https://brave.com" title="Brave Browser" target="_blank" rel="noopener noreferrer">Brave</a>',
    'vivaldi' => '<a href="https://vivaldi.com" title="Vivaldi Browser" target="_blank" rel="noopener noreferrer">Vivaldi</a>',
    'yabrowser' => '<a href="https://browser.yandex.com" title="Yandex Browser" target="_blank" rel="noopener noreferrer">Yandex Browser</a>',
    'whale' => '<a href="https://whale.naver.com" title="Naver Whale" target="_blank" rel="noopener noreferrer">Naver Whale</a>',
    'opera mini' => '<a href="https://www.opera.com/mobile/mini" title="Opera Mini" target="_blank" rel="noopener noreferrer">Opera Mini</a>',
    'silk' => '<a href="https://www.amazon.com/silk" title="Amazon Silk" target="_blank" rel="noopener noreferrer">Amazon Silk</a>',
    
    # --- 传统桌面浏览器 ---
    'ie' => '<a href="https://www.microsoft.com/ie" title="Internet Explorer home page" target="_blank" rel="noopener noreferrer">Internet Explorer</a>',
    'msie' => '<a href="https://www.microsoft.com/ie" title="Internet Explorer" target="_blank" rel="noopener noreferrer">Internet Explorer</a>',
    'netscape' => '<a href="https://en.wikipedia.org/wiki/Netscape" title="Netscape Navigator" target="_blank" rel="noopener noreferrer">Netscape Navigator</a>',
    'konqueror' => '<a href="https://konqueror.org" title="Konqueror" target="_blank" rel="noopener noreferrer">Konqueror</a>',
    'mozilla' => '<a href="https://www.mozilla.org" title="Mozilla" target="_blank" rel="noopener noreferrer">Mozilla Compatible</a>',
    
    # --- 可穿戴设备 ---
    'wear os' => '<a href="https://wearos.google.com" title="Wear OS" target="_blank" rel="noopener noreferrer">Wear OS</a>',
    'watch os' => '<a href="https://www.apple.com/watchos/" title="watchOS" target="_blank" rel="noopener noreferrer">watchOS</a>',
    'apple watch' => '<a href="https://www.apple.com/watch/" title="Apple Watch" target="_blank" rel="noopener noreferrer">Apple Watch</a>',
    'galaxy watch' => '<a href="https://www.samsung.com/watches/" title="Samsung Galaxy Watch" target="_blank" rel="noopener noreferrer">Samsung Galaxy Watch</a>',
    
    # --- 电视设备 ---
    'apple tv' => '<a href="https://www.apple.com/apple-tv/" title="Apple TV" target="_blank" rel="noopener noreferrer">Apple TV</a>',
    'android tv' => '<a href="https://www.android.com/tv/" title="Android TV" target="_blank" rel="noopener noreferrer">Android TV</a>',
    'webos' => '<a href="https://www.lg.com/webos" title="LG WebOS" target="_blank" rel="noopener noreferrer">LG WebOS</a>',
    'tizen' => '<a href="https://www.tizen.org" title="Samsung Tizen" target="_blank" rel="noopener noreferrer">Samsung Tizen</a>',
    'roku' => '<a href="https://www.roku.com" title="Roku" target="_blank" rel="noopener noreferrer">Roku</a>',
    'chromecast' => '<a href="https://www.google.com/chromecast/" title="Google Chromecast" target="_blank" rel="noopener noreferrer">Chromecast</a>',
    
    # --- 抓取器/机器人 ---
    'googlebot' => '<a href="https://developers.google.com/search/docs/crawling-indexing/googlebot" title="Googlebot" target="_blank" rel="noopener noreferrer">Googlebot</a>',
    'googlebot-mobile' => '<a href="https://developers.google.com/search/docs/crawling-indexing/googlebot" title="Googlebot Mobile" target="_blank" rel="noopener noreferrer">Googlebot Mobile</a>',
    'bingbot' => '<a href="https://www.bing.com/webmaster/help/which-crawlers-does-bing-use" title="Bingbot" target="_blank" rel="noopener noreferrer">Bingbot</a>',
    'yandexbot' => '<a href="https://yandex.com/bot" title="Yandex Bot" target="_blank" rel="noopener noreferrer">Yandex Bot</a>',
    'baiduspider' => '<a href="https://www.baidu.com/search/spider.html" title="Baidu Spider" target="_blank" rel="noopener noreferrer">Baidu Spider</a>',
    'facebookexternalhit' => '<a href="https://developers.facebook.com/docs/sharing/webmasters/crawler" title="Facebook Crawler" target="_blank" rel="noopener noreferrer">Facebook Crawler</a>',
    'twitterbot' => '<a href="https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards" title="Twitterbot" target="_blank" rel="noopener noreferrer">Twitterbot</a>',
    'linkedinbot' => '<a href="https://www.linkedin.com/help/linkedin/answer/1113" title="LinkedIn Bot" target="_blank" rel="noopener noreferrer">LinkedIn Bot</a>',
    'applebot' => '<a href="https://support.apple.com/en-us/HT204683" title="Applebot" target="_blank" rel="noopener noreferrer">Applebot</a>',
    'slurp' => '<a href="https://help.yahoo.com/kb/SLN22198.html" title="Yahoo Slurp" target="_blank" rel="noopener noreferrer">Yahoo Slurp</a>',
    'duckduckbot' => '<a href="https://duckduckgo.com/duckduckbot" title="DuckDuckGo Bot" target="_blank" rel="noopener noreferrer">DuckDuckGo Bot</a>',
    'semrushbot' => '<a href="https://www.semrush.com/bot/" title="SEMrush Bot" target="_blank" rel="noopener noreferrer">SEMrush Bot</a>',
    'ahrefsbot' => '<a href="https://ahrefs.com/robot" title="Ahrefs Bot" target="_blank" rel="noopener noreferrer">Ahrefs Bot</a>',
    'mj12bot' => '<a href="https://www.majestic.com/crawler" title="Majestic MJ12bot" target="_blank" rel="noopener noreferrer">MJ12bot</a>',
    'uptimerobot' => '<a href="https://uptimerobot.com" title="UptimeRobot" target="_blank" rel="noopener noreferrer">UptimeRobot</a>',
    'pingdom' => '<a href="https://www.pingdom.com" title="Pingdom" target="_blank" rel="noopener noreferrer">Pingdom</a>',
    'cloudflare' => '<a href="https://www.cloudflare.com" title="Cloudflare" target="_blank" rel="noopener noreferrer">Cloudflare</a>',
    
    # --- 社交媒体应用内浏览器 ---
    'instagram' => '<a href="https://www.instagram.com" title="Instagram" target="_blank" rel="noopener noreferrer">Instagram</a>',
    'facebook' => '<a href="https://www.facebook.com" title="Facebook" target="_blank" rel="noopener noreferrer">Facebook</a>',
    'twitter' => '<a href="https://twitter.com" title="Twitter" target="_blank" rel="noopener noreferrer">Twitter</a>',
    'tiktok' => '<a href="https://www.tiktok.com" title="TikTok" target="_blank" rel="noopener noreferrer">TikTok</a>',
    'weibo' => '<a href="https://weibo.com" title="Weibo" target="_blank" rel="noopener noreferrer">Weibo</a>',
    'telegram' => '<a href="https://telegram.org" title="Telegram" target="_blank" rel="noopener noreferrer">Telegram</a>',
    'whatsapp' => '<a href="https://www.whatsapp.com" title="WhatsApp" target="_blank" rel="noopener noreferrer">WhatsApp</a>',
    'line' => '<a href="https://line.me" title="LINE" target="_blank" rel="noopener noreferrer">LINE</a>',
    
    # --- RSS 阅读器 ---
    'feedly' => '<a href="https://feedly.com" title="Feedly" target="_blank" rel="noopener noreferrer">Feedly</a>',
    'inoreader' => '<a href="https://www.inoreader.com" title="Inoreader" target="_blank" rel="noopener noreferrer">Inoreader</a>',
    'newsblur' => '<a href="https://newsblur.com" title="NewsBlur" target="_blank" rel="noopener noreferrer">NewsBlur</a>',
    'flipboard' => '<a href="https://flipboard.com" title="Flipboard" target="_blank" rel="noopener noreferrer">Flipboard</a>',
    'pocket' => '<a href="https://getpocket.com" title="Pocket" target="_blank" rel="noopener noreferrer">Pocket</a>',
    'netnewswire' => '<a href="https://netnewswire.com" title="NetNewsWire" target="_blank" rel="noopener noreferrer">NetNewsWire</a>',
    
    # --- 包管理工具 ---
    'composer' => '<a href="https://getcomposer.org" title="Composer" target="_blank" rel="noopener noreferrer">Composer</a>',
    'npm' => '<a href="https://www.npmjs.com" title="npm" target="_blank" rel="noopener noreferrer">npm</a>',
    'pip' => '<a href="https://pip.pypa.io" title="pip" target="_blank" rel="noopener noreferrer">pip</a>',
    'cargo' => '<a href="https://doc.rust-lang.org/cargo/" title="Cargo" target="_blank" rel="noopener noreferrer">Cargo</a>',
    'yarn' => '<a href="https://yarnpkg.com" title="Yarn" target="_blank" rel="noopener noreferrer">Yarn</a>',
    
    # --- 开发工具 ---
    'curl' => '<a href="https://curl.se" title="cURL" target="_blank" rel="noopener noreferrer">cURL</a>',
    'wget' => '<a href="https://www.gnu.org/software/wget/" title="Wget" target="_blank" rel="noopener noreferrer">Wget</a>',
    'python-requests' => '<a href="https://requests.readthedocs.io" title="Python Requests" target="_blank" rel="noopener noreferrer">Python Requests</a>',
    'go-http-client' => '<a href="https://golang.org" title="Go HTTP Client" target="_blank" rel="noopener noreferrer">Go HTTP Client</a>',
    'postman' => '<a href="https://www.postman.com" title="Postman" target="_blank" rel="noopener noreferrer">Postman</a>',
    
    # --- 其他 ---
    'puffin' => '<a href="https://www.puffin.com" title="Puffin Browser" target="_blank" rel="noopener noreferrer">Puffin Browser</a>',
    'dolphin' => '<a href="https://dolphin.com" title="Dolphin Browser" target="_blank" rel="noopener noreferrer">Dolphin Browser</a>',
    'electron' => '<a href="https://www.electronjs.org" title="Electron" target="_blank" rel="noopener noreferrer">Electron App</a>',
    'phantomjs' => '<a href="https://phantomjs.org" title="PhantomJS" target="_blank" rel="noopener noreferrer">PhantomJS</a>',
    'mobile' => '<a href="#" title="Mobile Device" target="_blank" rel="noopener noreferrer">Mobile Device</a>',
);

#------------------------------------------------------------------------------
# 抓取器标记
#------------------------------------------------------------------------------
%BrowsersHereAreGrabbers = (
    'googlebot' => 1, 'googlebot-mobile' => 1, 'bingbot' => 1,
    'yandexbot' => 1, 'baiduspider' => 1, 'facebookexternalhit' => 1,
    'twitterbot' => 1, 'linkedinbot' => 1, 'applebot' => 1,
    'slurp' => 1, 'duckduckbot' => 1, 'semrushbot' => 1,
    'ahrefsbot' => 1, 'mj12bot' => 1, 'uptimerobot' => 1,
    'pingdom' => 1, 'cloudflare' => 1, 'curl' => 1, 'wget' => 1,
    'python-requests' => 1, 'go-http-client' => 1, 'httrack' => 1,
    'teleport' => 1, 'webcapture' => 1, 'webcopier' => 1,
    'webreaper' => 1, 'webzip' => 1, 'phantomjs' => 1, 'slimerjs' => 1,
);

#------------------------------------------------------------------------------
# 图标映射
#------------------------------------------------------------------------------
%BrowsersHashIcon = (
    # --- iOS 设备 ---
    'iphone' => 'iphone',
    'ipad' => 'ipad',
    'ipod' => 'iphone',
    
    # --- iOS 浏览器 ---
    'crios' => 'chrome',
    'fxios' => 'firefox',
    'edgios' => 'edge',
    'opios' => 'opera',
    'safari' => 'safari',
    'mobile safari' => 'safari',
    
    # --- 三星 ---
    'samsung' => 'samsung',
    'samsungbrowser' => 'samsung',
    'galaxy tab' => 'samsung',
    
    # --- 华为/荣耀 ---
    'huawei' => 'huawei',
    'honor' => 'honor',
    'harmonyos' => 'harmonyos',
    'huaweibrowser' => 'huawei-browser',
    
    # --- 小米 ---
    'xiaomi' => 'xiaomi',
    'redmi' => 'redmi',
    'poco' => 'poco',
    'miuibrowser' => 'miui_browser',
    
    # --- OPPO/一加/realme ---
    'oppo' => 'oppo',
    'oneplus' => 'oneplus',
    'realme' => 'realme',
    'oppobrowser' => 'oppo',
    
    # --- VIVO ---
    'vivo' => 'vivo',
    'iqoo' => 'iqoo',
    'vivobrowser' => 'vivo',
    
    # --- 其他中国品牌 ---
    'meizu' => 'meizu',
    'lenovo' => 'lenovo',
    'zte' => 'zte',
    'nubia' => 'nubia',
    'blackshark' => 'blackshark',
    'tecno' => 'tecno',
    'infinix' => 'infinix',
    'itel' => 'itel',
    'hisense' => 'hisense',
    'tcl' => 'tcl',
    'konka' => 'konka',
    'changhong' => 'changhong',
    
    # --- 其他国际品牌 ---
    'asus' => 'asus',
    'rog' => 'rog',
    'nokia' => 'nokia',
    'sony' => 'sony',
    'lg' => 'lg',
    'motorola' => 'motorola',
    'pixel' => 'pixel',
    'google' => 'google',
    'blackberry' => 'blackberry',
    'htc' => 'default',
    
    # --- 日本品牌 ---
    'kyocera' => 'kyocera',
    'panasonic' => 'panasonic',
    'sharp' => 'sharp',
    'fujitsu' => 'fujitsu',
    
    # --- 浏览器 ---
    'android' => 'android',
    'ucbrowser' => 'uc_browser',
    'quark' => 'quark',
    'baiduboxapp' => 'baidu',
    'qqbrowser' => 'qqbrowser',
    'sogou' => 'sogou',
    'opera mini' => 'opera',
    'chrome' => 'chrome',
    'firefox' => 'firefox',
    'edge' => 'edge',
    'edg' => 'edge',
    'opera' => 'opera',
    'brave' => 'brave',
    'vivaldi' => 'vivaldi',
    'yabrowser' => 'yandex-browser',
    'whale' => 'whale',
    'silk' => 'silk',
    'puffin' => 'puffin',
    'dolphin' => 'dolphin',
    'electron' => 'electron',
    'phantomjs' => 'phantomjs',
    
    # --- 传统浏览器 ---
    'msie' => 'ie',
    'ie' => 'Internet-Explorer',
    'netscape' => 'netscape',
    'konqueror' => 'konqueror',
    'mozilla' => 'firefox',
    
    # --- 可穿戴设备 ---
    'wear os' => 'wearos',
    'watch os' => 'watchos',
    'apple watch' => 'apple',
    'galaxy watch' => 'samsung',
    'wearable' => 'wearable',
    
    # --- 电视设备 ---
    'apple tv' => 'apple',
    'android tv' => 'android',
    'webos' => 'webos',
    'tizen' => 'tizen',
    'roku' => 'roku',
    'chromecast' => 'chromecast',
    'smart tv' => 'smart',
    'tv' => 'tv',
    
    # --- 抓取器/机器人 ---
    'googlebot' => 'google',
    'googlebot-mobile' => 'google',
    'bingbot' => 'bingbot',
    'yandexbot' => 'yandex-browser',
    'baiduspider' => 'baidu',
    'facebookexternalhit' => 'facebook',
    'twitterbot' => 'twitter',
    'linkedinbot' => 'bot',
    'applebot' => 'apple',
    'slurp' => 'bot',
    'duckduckbot' => 'bot',
    'semrushbot' => 'bot',
    'ahrefsbot' => 'bot',
    'mj12bot' => 'bot',
    'uptimerobot' => 'bot',
    'pingdom' => 'bot',
    'cloudflare' => 'bot',
    'bot' => 'bot',
    
    # --- 社交媒体应用 ---
    'instagram' => 'instagram',
    'facebook' => 'facebook',
    'twitter' => 'twitter',
    'tiktok' => 'tiktok',
    'weibo' => 'weibo',
    'telegram' => 'telegram',
    'whatsapp' => 'whatsapp',
    'line' => 'line',
    'micromessenger' => 'wechat',
    'wechat' => 'wechat',
    
    # --- RSS 阅读器 ---
    'feedly' => 'feedly',
    'inoreader' => 'inoreader',
    'newsblur' => 'newsblur',
    'flipboard' => 'flipboard',
    'pocket' => 'pocket',
    'netnewswire' => 'netnewswire',
    'akregator' => 'akregator',
    'rss' => 'rss',
    'rssbandit' => 'rssbandit',
    'rssowl' => 'rssowl',
    
    # --- 包管理工具 ---
    'composer' => 'composer',
    'npm' => 'npm',
    'pip' => 'pip',
    'cargo' => 'cargo',
    'yarn' => 'yarn',
    'bundler' => 'bundler',
    'poetry' => 'poetry',
    'gem' => 'gem',
    'conda' => 'conda',
    'uv' => 'uv',
    'rustc' => 'Rust',
    'pnpm' => 'pnpm',
    
    # --- 开发工具 ---
    'curl' => 'curl',
    'wget' => 'wget',
    'python-requests' => 'python-requests',
    'go-http-client' => 'go-http-client',
    'postman' => 'postman',
    'insomnia' => 'insomnia',
    'axios' => 'axios',
    'node-fetch' => 'node-fetch',
    'java' => 'java',
    
    # --- 媒体播放器 ---
    'real' => 'realplayer',
    'winamp' => 'winamp',
    'windows-media-player' => 'windows-media-player',
    'itunes' => 'itunes-note',
    'vlc' => 'vlc',
    'quicktime' => 'quicktime',
    'mplayer' => 'mplayer',
    'xmms' => 'xmms',
    'xine' => 'xine',
    'gstreamer' => 'gstreamer',
    
    # --- 其他 ---
    'mobile' => 'mobile',
    'tablet' => 'tablet',
    'wearable' => 'wearable',
    'tv' => 'tv',
    'default' => 'default',
    'unknown' => 'unknown',
    
    # --- 操作系统图标（用于设备类型） ---
    'windows' => 'win10',
    'macos' => 'macos',
    'linux' => 'linuxarch',
    'android' => 'android',
    'ios' => 'iphone',
    'harmonyos' => 'harmonyos',
);

#------------------------------------------------------------------------------
# Safari 版本检测函数
#------------------------------------------------------------------------------
sub get_safari_version {
    my $build = shift;
    return undef unless $build =~ /^\d+(?:\.\d+)*$/;
    
    # 新版 Safari (10+ 以后)
    if ($build >= 12600) {
        my $major = int(($build - 2600) / 1000);
        my $minor = int(($build % 1000) / 100);
        return "$major.$minor";
    }
    
    # 旧版 Safari (1.x-4.x) 映射
    my %old_map = (
        48 => '0.8', 51 => '0.8.1', 60 => '0.8.2', 73 => '0.9',
        85 => '1.0', 100 => '1.1', 125 => '1.2', 312 => '1.3',
        412 => '2.0', 416 => '2.0', 417 => '2.0', 419 => '2.0',
        522 => '3.0', 523 => '3.0', 525 => '3.1', 526 => '3.2',
        528 => '4.0', 530 => '4.0', 531 => '4.0', 533 => '4.1',
        534 => '5.0', 535 => '5.1', 536 => '6.0', 537 => '6.1',
    );
    
    my $base = int($build);
    return $old_map{$base} if exists $old_map{$base};
    
    return $build;
}

#------------------------------------------------------------------------------
# 设备类型识别函数
#------------------------------------------------------------------------------
sub get_device_type {
    my $user_agent = shift;
    
    return 'tv' if $user_agent =~ /tv|smart[- ]tv|webos|tizen|roku|firetv|chromecast|kodi|apple.*tv|android.*tv/i;
    return 'wearable' if $user_agent =~ /wear|watch|fitbit|galaxy.*watch|apple.*watch/i;
    return 'tablet' if $user_agent =~ /tablet|ipad|kindle|playbook|nexus 7|nexus 10|galaxy tab/i;
    return 'bot' if $user_agent =~ /bot|crawler|spider|scraper|uptimerobot|pingdom|newrelic|datadog/i;
    return 'mobile' if $user_agent =~ /mobile|android|iphone|ipod|harmonyos|blackberry|windows phone/i;
    return 'desktop';
}

#------------------------------------------------------------------------------
# 移动操作系统检测函数
#------------------------------------------------------------------------------
sub get_mobile_os {
    my $user_agent = shift;
    
    return 'harmonyos' if $user_agent =~ /harmonyos|harmony/i;
    return 'ios' if $user_agent =~ /iphone|ipad|ipod|crios|fxios|edgios|opios/i;
    return 'android' if $user_agent =~ /android/i;
    return 'watchos' if $user_agent =~ /watch.*os|apple.*watch/i;
    return 'tizen' if $user_agent =~ /tizen/i;
    return 'webos' if $user_agent =~ /webos/i;
    return 'unknown';
}

print "AWStats Unified Browser DB: Loaded successfully\n" if $Debug;
print "AWStats Unified Browser DB: Desktop + Mobile detection enabled\n" if $Debug;
print "AWStats Unified Browser DB: Supports iOS, Android, HarmonyOS, Tablets, Wearables, TV\n" if $Debug;

1;
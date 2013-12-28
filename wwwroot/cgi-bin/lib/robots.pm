# AWSTATS ROBOTS DATABASE
#-------------------------------------------------------
# If you want to add robots to extend AWStats database detection capabilities,
# you must add an entry in RobotsSearchIDOrder_listx and RobotsHashIDLib.

# The entry in RobotsSearchIDOrder_listx is a Perl regular expression
# (see http://perldoc.perl.org/perlreref.html). AWSTats applies these
# expressions to the user agent string in the order given by the lists. The
# first match specifies the robot.
#
# The corresponding entry in RobotsHashIDLib contains the regular expression
# as key, followed by a string containing HTML-text. AWStats inserts this
# text into reports to describe the bot. If possible the text should contain
# a link to the bot home page. This make it easier for systadmins to find
# the information necessary e.g. to adapt the robots.txt file.
#
# An entry in the RobotsAffiliateLib is not necessary. An entry in this list
# contains as first part the regular expression specifying the bot. The
# second part is a string that gives the Company or product managing the bot.
# This information is not used yet.

#-------------------------------------------------------

# 2005-08-19 Sean Carlos http://www.antezeta.com/awstats.html
#              added dipsie (not tested with real data).
#              added DomainsDB.net http://domainsdb.net/
#              added ia_archiver-web.archive.org (was inadvertently grouped with Alexa traffic)
#              added Nutch (used by looksmart (furl?))
#              added rssImagesBot
#              added Sqworm
#              added t\-h\-u\-n\-d\-e\-r\-s\-t\-o\-n\-e
#              added w3c css-validator
#              added documentation link to bot home pages for above and selected major bots.
#                    In the case of international bots, choose .com page.
#                    Included tool tip (html "title").
#                    To do: parameterize to match both AWStats language and tooltips settings.
#                    To do: add html links for all bots based on current documentation in source
#                           files referenced below.
#              changed '\wbot[\/\-]', to '\wbot[\/\-]' (removed comma)
#              made minor grammar corrections to notes below
# 2005-08-24	added YahooSeeker-Testing
#              	added w3c-checklink
#              	updated url for ask.com
# 2005-08-24   	added Girafabot http://www.girafa.com/
# 2005-08-30   	added PluckFeedCrawler http://www.pluck.com/
#		added Gaisbot/3.0 (robot05@gais.cs.ccu.edu.tw; )
#		dded geniebot (wgao@genieknows.com)
#		added BecomeBot link http://www.become.com/site_owners.html
#		added topicblogs http://www.topicblogs.com/
#		added Powermarks; seen used by referrer spam
#		added YahooSeeker
#		added NG/2. http://www.exabot.com/
# 2005-09-15	added link for Walhello appie
#		added bender focused_crawler
#		updated YahooSeeker description (blog crawler)
# 2005-09-16	added link for http://linkchecker.sourceforge.net
# 		added ConveraCrawler/0.9d ( http://www.authoritativeweb.com/crawl)
#		added Blogslive  info@blogslive.com intelliseek.com
#		added BlogPulse (ISSpider-3.0) intelliseek.com
# 2005-09-26	added Feedfetcher-Google (http://www.google.com/feedfetcher.html)
#		added EverbeeCrawler
#		added Yahoo-Blogs http://help.yahoo.com/help/us/ysearch/crawling/crawling-02.html
#		added link for Bloglines http://www.bloglines.com
# 2005-10-19	fixed Feedfetcher-Google (http://www.google.com/feedfetcher.html)
# 		added Blogshares Spiders (Synchronized V1.5.1)
#		added yacy
# 2005-11-21	added Argus www.simpy.com
#		added BlogsSay :: RSS Search Crawler (http://www.blogssay.com/)
#		added MJ12bot http://majestic12.co.uk/bot.php
#		added OpenTaggerBot (http://www.opentagger.com/opentaggerbot.htm)
#		added OutfoxBot/0.3 (For internet experiments; outfox.agent@gmail.com)
#		added RufusBot Rufus Web Miner http://64.124.122.252.webaroo.com/feedback.html
#		added Seekbot (http://www.seekbot.net/bot.html)
#		added Yahoo-MMCrawler/3.x (mms-mmcrawler-support@yahoo-inc.com)
#               added link for BaiDuSpider
#		added link for Blogshares Spider
#		added link for StackRambler http://www.rambler.ru/doc/faq.shtml
#		added link for WISENutbot
#		added link for ZyBorg/1.0 (wn-14.zyborg@looksmart.net; http://www.WISEnutbot.com.  Moved location to above wisenut to avoid classification as wisenut
# 2005-12-15
#		added FAST Enteprise Crawler/6 (www dot fastsearch dot com). Note spelling Enteprise not Enterprise.
#		added findlinks http://wortschatz.uni-leipzig.de/findlinks/
#		added IBM Almaden Research Center WebFountain™ http://www.almaden.ibm.com/cs/crawler [hc3]
#		added INFOMINE/8.0 VLCrawler (http://infomine.ucr.edu/useragents)
#		added lmspider (lmspider@scansoft.com) http://www.nuance.com/
#		added noxtrumbot http://www.noxtrum.com/
#		added SandCrawler (Microsoft)
#		added SBIder http://www.sitesell.com/sbider.html
#		added SeznamBot http://fulltext.seznam.cz/
#		added sohu-search http://corp.sohu.com/ (looked for //robots.txt not /robots.txt)
#		added the ruffle SemanticWeb crawler v0.5 - http://www.unreach.net
#		added WebVulnCrawl/1.0 libwww-perl/5.803 (looked for //robots.txt not /robots.txt)
#		added Yahoo! Japan keyoshid http://www.yahoo.co.jp/
#		added Y!J http://help.yahoo.co.jp/help/jp/search/indexing/indexing-15.html
#		added link for GigaBot
#		added link for MagpieRSS
#		added link for MSIECrawler
# 2005-12-21
#		added aipbot http://www.aipbot.com aipbot@aipbot.com [matthys70 users.sourceforge.net]
#		added Everest-Vulcan Inc./0.1 (R&D project; http://everest.vulcan.com/crawlerhelp)
#		added Fast-Search-Engine http://www.fast-search-engine.com/ [matthys70  users.sourceforge.net]
#		added g2Crawler (nobody@airmail.net) http://crawler.instantnetworks.net/
#		added Jakarta commons-httpclient http://jakarta.apache.org/commons/httpclient/ (hit robots.txt).  May be used as robot or browser - a site may want to remove this entry.
#		added OmniExplorer_Bot http://www.omni-explorer.com/ [matthys70 users.sourceforge.net]
#		added USTC-Semantic-Group ai.ustc.edu.cn/mas/en/research/index.php ?
# 2005-12-22
#		added EARTHCOM.info www.earthcom.info
#		added HTTrack off-line browser 'httrack','HTTrack', http://www.httrack.com/ [Moizes Gabor]
#		added KummHttp http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&template=detail.html&match=\bid_g_l_301105_2\b [Moizes Gabor]
# 2006-01-01
#		added Dulance http://www.dulance.com/bot.jsp
#		added MojeekBot http://www.mojeek.com/bot.html
#		added nicebot http://www.egghelp.org/setup.htm ?
#		added Snappy http://www.urltrends.com/faq.php
#		added sohu agent
#		added VORTEX http://marty.anstey.ca/robots/vortex/ [matthys70 users.sourceforge.net]
#		added zspider http://feedback.redkolibri.com/
# 2006-01-13
#		added boitho.com-dc http://www.boitho.com/dcbot.html
#		added IRLbot http://irl.cs.tamu.edu/crawler
#		added virus_detector virus_harvester@securecomputing.com
#		added Wavefire http://www.wavefire.com; info@wavefire.com
#		added WebFilter Robot
# 2006-01-24
#		added Shim-Crawler http://www.logos.ic.i.u-tokyo.ac.jp/crawler/; crawl@logos.ic.i.u-tokyo.ac.jp
#		added Exabot exabot.com
#		added LetsCrawl.com http://letscrawl.com
#		added ichiro http://help.goo.ne.jp/door/crawlerE.html
# 2006-01-27    additional 22 robots from a list provided by Moizes Gabor
#		added ALeadSoftbot	http://www.aleadsoft.com/bot.htm
#		added CipinetBot	http://www.cipinet.com/bot.html
#		added Cuasarbot	http://www.cuasar.com/
#		added Dumbot	http://www.dumbfind.com/
#		added Extreme_Picture_Finder	http://www.exisoftware.com/
#		added Fooky.com/ScorpionBot/ScoutOut	http://www.fooky.com/scorpionbots
#		added IlTrovatore-Setaccio	http://www.iltrovatore.it/aiuto/motore_di_ricerca.html	bot@iltrovatore.it
#		added InsurancoBot	http://www.fastspywareremoval.com/
#		added InternetArchive	http://lucene.apache.org/nutch/bot.html 	nutch-agent@lucene.apache.org
#		added KazoomBot	http://www.kazoom.ca/bot.html	kazoombot@kazoom.ca
#		added Kurzor	http://www.easymail.hu/	cursor@easymail.hu
#		added NutchCVS	http://lucene.apache.org/nutch/bot.html	nutch-agent@lucene.apache.org
#		added NutchOSU-VLIB	http://lucene.apache.org/nutch/bot.html	nutch-agent@lucene.apache.org
#		added Orbiter	http://www.dailyorbit.com/bot.htm
#		added PHP_version_tracker	http://www.nexen.net/phpversion/bot.php
#		added SuperBot	http://www.sparkleware.com/superbot/
#		added SynooBot	http://www.synoo.de/bot.html	webmaster@synoo.com
#		added TestBot	http://www.agbrain.com/
#		added TutorGigBot	http://www.tutorgig.info/
#		added WebIndexer	mailto://webindexerv1@yahoo.com
#		added WebMiner	http://64.124.122.252/feedback.html
# 2006-02-01
#		added heritrix https://sourceforge.net/forum/message.php?msg_id=3550202
#		added Zeus Webster Pro https://sourceforge.net/forum/message.php?msg_id=3141164
#               additional robots from a list provided by Moizes Gabor [ mojzi -a-t- free mail hu ]
#		added Candlelight_Favorites_Inspector
#		added DomainChecker
#		added EasyDL
#		added FavOrg
#		added Favorites_Sweeper
#		added Html_Link_Validator
#		added Internet_Ninja
#		added JRTwine_Software_Check_Favorites_Utility
#		fixed Microsoft_URL_Control
#		added miniRank
#		added Missigua_Locator
#		added NPBot
#		added Ocelli
#		added Onet.pl_SA
#		added proodleBot
#		added SearchGuild_DMOZ_Experiment
#		added Susie
#		added Website_Monitoring_Bot
#		added Xenu_Link_Sleuth
# 2006-05-15
#		added ASPseek http://www.aspseek.org/
#		added AdamM Bot http://home.blic.net/adamm/
#		added archive.org_bot http://crawls.archive.org/collections/bncf/crawl.html
#		added arianna.libero.it (Italian Portal/search engine)
#		added Biz360 spider http://www.biz360.com
#		added BlogBridge Service http://www.blogbridge.com/
#		added BlogSearch http://www.icerocket.com/
#		added libcrawl
#		added edgeio-relanshanbottriever http://www.edgeio.com
#		added FeedFlow http://feedflow.com/about
#		added Biblioteca Nazionale Centrale di Firenze (Italian National Archive) http://www.bncf.firenze.sbn.it/raccolta.txt
#		added Java catchall - used by many spam bots
#		added lanshanbot http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&amp;template=detail.html&amp;match=%5Cbid_g_l_140406_1%5Cb
#		added msnbot-media http://search.msn.com/msnbot.htm
#		added MT::Telegraph::Agent
#		added Netluchs http://www.netluchs.de/ (German SE bot)
#		added oBot http://www.webmasterworld.com/forum11/1616.htm
#		added Onfolio http://www.onfolio.com/  (IE Toolbar plugin) - hit rss feeds.
#		added ping.blo.gs http://blo.gs/ping.php blog bot
#		added Sphere Scout http://www.sphere.com/
#		added sproose crawler http://www.sproose.com/bot.html
#		added SyndicAPI http://syndicapi.com/bot.html
#		added Yahoo! Mindset http://mindset.research.yahoo.com/
#		added msrabot
#		added Vagabondo & Vagabondo-WAP http://www.wise-guys.nl/Contact/index.php?botselected=webagents&amp;lang=uk
#		fixed Missigua Locator detection (Missigua_Locator -> Missigua Locator)
#		changed echo to echo! to avoid conflict with the bonecho (Firefox 2.0) browser.
#			This requires you to reprocess historic logs if you want EchO! to be recognized for older reports.
# 2006-05-17
#		added Alpha Search Agent # 62.152.125.60 Eurologon Srl
#		added Krugle http://www.krugle.com/crawler/info.html the search engine for developers
#		added Octora Beta Bot http://www.octora.com/ # Blog and Rss Search Engine
#		added UbiCrawler http://law.dsi.unimi.it/ubicrawler/
#		added Yahoo! Slurp China http://misc.yahoo.com.cn/help.html
#			You must reprocess old logs for the Yahoo! Slurp China bot to be detected in old reports
# 2006-05-20
#		added 1-More Scanner http://www.myzips.com/software/1-More-Scanner.phtml
#		added Accoona-AI-Agent http://www.accoona.com/
#		added ActiveBookmark http://www.libmaster.com/active_bookmark.php
#		added BIGLOTRON http://www.biglotron.com/robot.html
#		added Bookmark-Manager http://bkm.sourceforge.net/
#		added cbn00glebot
#		added Cerberian Drtrs http://www.pgts.com.au/cgi-bin/psql?robot_info=25240
#		added CFNetwork http://www.cocoadev.com/index.pl?CFNetwork
#		added CheckWeb link validator http://p.duby.free.fr/chkweb.htm
#		added Computer and Automation Research Institute Crawler http://www.ilab.sztaki.hu/~stamas/publications/p184-benczur.html
#		added ConveraCrawler http://www.authoritativeweb.com/crawl/
#		added ConveraMultiMediaCrawler http://www.authoritativeweb.com/crawl/
#		added CSE HTML Validator Lite Online http://online.htmlvalidator.com/php/onlinevallite.php
#		added Cursor http://adcenter.hu/docs/en/bot.html
#		added Custo http://www.netwu.com/custo/
#		added DataFountains/DMOZ Downloader http://infomine.ucr.edu/
#		added Deepindex http://www.deepindex.net/faq.php
#		added DNSGroup http://www.dnsgroup.com/
#		added DoCoMo http://www.nttdocomo.co.jp/
#		added dumm.de-Bot http://www.dumm.de/
#		added ETS v http://www.freetranslation.com/help/
#		added eventax http://www.eventax.de/
#		added FAST Enterprise Crawler * crawleradmin.t-info@telekom.de http://www.telekom.de/
#		added FAST Enterprise Crawler http://www.fast.no/
#		added FAST Enterprise Crawler * T-Info_BI_cluster crawleradmin.t-info@telekom.de http://www.telekom.de/
#		added FeedValidator http://feedvalidator.org/
#		added FilmkameraBot http://www.filmkamera.at/bot.html
#		added Findexa Crawler http://www.findexa.no/gulesider/article26548.ece
#		added Global Fetch http://www.wesonet.com/
#		added GOFORITBOT http://www.goforit.com/about/
#		added GoForIt.com http://www.goforit.com/about/
#		added GPU p2p crawler http://gpu.sourceforge.net/search_engine.php
#		added HooWWWer http://cosco.hiit.fi/search/hoowwwer/
#		added HPPrint
#		added HTMLParser http://htmlparser.sourceforge.net/
#		added Hundesuche.com-Bot http://www.hundesuche.com/
#		added InfoBot http://www.infobot.org/
#		added InfociousBot http://corp.infocious.com/tech_crawler.php
#		added InternetSupervision http://internetsupervision.com/
#		added isearch2006 http://www.yahoo.com.cn/
#		added IUPUI_Research_Bot http://spamhuntress.com/2005/04/25/a-mail-harvester-visits/
#		added KalamBot http://64.124.122.251/feedback.html
#		added kamano.de NewsFeedVerzeichnis http://www.kamano.de/
#		added Kevin http://dznet.com/kevin/
#		added KnowItAll http://www.cs.washington.edu/research/knowitall/
#		added Knowledge.com http://www.knowledge.com/
#		added Kouaa Krawler http://www.kouaa.com/
#		added ksibot http://ego.ms.mff.cuni.cz/
#		added Link Valet Online http://www.htmlhelp.com/tools/valet/
#		added lwp-request http://search.cpan.org/~gaas/libwww-perl-5.69/bin/lwp-request
#		added lwp-trivial http://search.cpan.org/src/GAAS/libwww-perl-5.805/lib/LWP/Simple.pm
#		added MapoftheInternet.com http://MapoftheInternet.com/
#		added Matrix S.p.A. - FAST Enterprise Crawler http://tin.virgilio.it/
#		added Megite http://www.megite.com/
#		added Metaspinner http://index.meta-spinner.de/
#		added Mini-reptile
#		added Misterbot http://www.misterbot.fr/
#		added Miva http://www.miva.com/
#		added Mizzu Labs http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&amp;template=detail.html&amp;match=\bid_m_141105_2\b
#		added MSRBOT http://research.microsoft.com/research/sv/msrbot/
#		added MS SharePoint Portal Server - MS Search 4.0 Robot http://support.microsoft.com/default.aspx?scid=kb;en-us;284022
#		added Mydoyouhike http://www.doyouhike.net/my
#		added NASA Search http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&template=detail.html&match=\bid_n_s_140506_2\b
#		added NetSprint http://www.netsprint.pl/serwis/
#		added NimbleCrawler http://www.healthline.com/
#		added OpenWebSpider http://www.openwebspider.org/
#		added Oracle Ultra Search http://www.oracle.com/technology/products/ultrasearch/index.html
#		added OSSProxy http://www.marketscore.com/FAQ.Aspx
#		added passwordmaker.org http://passwordmaker.org/
#		added PEAR HTTP Request class http://pear.php.net/
#		added PEERbot http://www.peerbot.com/
#		added PHP version tracker http://www.nexen.net/phpversion/bot.php
#		added PictureOfInternet http://malfunction.org/poi/
#		added plinki http://www.plinki.com/
#		added Port Huron Labs http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&amp;template=detail.html&amp;match=\bid_n_s_1133\b
#		added PostFavorites http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&amp;template=detail.html&amp;match=\bid_n_s_1135\b
#		added ProjectWF-java-test-crawler
#		added PyQuery http://sourceforge.net/projects/pyquery/
#		added Schizozilla http://spamhuntress.com/2005/03/18/gizmo/
#		added Scumbot
#		added Sensis Web Crawler http://www.sensis.com.au/
#		added snap.com beta crawler http://www.snap.com/
#		added Steeler http://www.tkl.iis.u-tokyo.ac.jp/~crawler/
#		added STEROID  Download http://faqs.org.ru/progr/pascal/delphi_internet2.htm
#		added Suchfin-Bot http://www.suchfin.de/
#		added Sunrise http://www.sunrisexp.com/
#		added Tagyu Agent http://www.tagyu.com/
#		added Tcl http client package http://www.tcl.tk/man/tcl8.4/TclCmd/http.htm
#		added TeragramCrawlerSURF http://www.teragram.com/
#		added Test Crawler http://netp.ath.cx/
#		added UnChaos Bot Hybrid Web Search Engine http://www.unchaos.com/
#		added unido-bot http://www.unchina.org/unido/unido/our_projects/3_3.html
#		added UniversalFeedParser http://feedparser.org/ (seen from md301000.inktomisearch.com)
#		added updated http://www.updated.com/
#		added Vermut http://vermut.aol.com
#		added versus crawler from eda.baykan@epfl.ch http://www.epfl.ch/Eindex.html
#		added Vespa Crawler (Yahoo Norway?) http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&template=detail.html&match=%5Cbid_t_z_030406_1%5Cb
#		added VSE http://www.vivisimo.com/
#		added webcrawl.net http://www.webcrawl.net/
#		added Web Downloader http://www.krasu.ru/soft/chuchelo/
#		added Webdup http://www.webdup.com/en/index.html
#		added Wells Search http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&amp;template=detail.html&amp;match=\bid_t_z_1484\b
#		added WordPress http://wordpress.org/
#		added wume crawler http://wume.cse.lehigh.edu/~xiq204/crawler/
#		added Xenu's Link Sleuth (with ')
#		added xirq http://www.xirq.com/
#		added yoogliFetchAgent http://www.yoogli.com/
#		added Z-Add Link Checker http://w3.z-add.co.uk/linkcheck/
#		-- fix - some robots were reported with _ where _ should have been a space.
#		changed Xenu Link Sleuth
#		changed microsoft[_+ ]url[_+ ]control -> microsoft_url_control
#		changed favorites_sweeper -> favorites_sweeper
#		-- updates
#		updated AskJeeves to Ask
# 2012-06-05 Albrecht Mueller
#              added Grabber from SDSC (San Diego Supercomputer Center).
# 2013-09-30 Albrecht Mueller
# AWStats probably cannot detect this bot as it identifies itself in
# the referrer field and not in the user agent string.
#92.113.100.35 - - [29/Sep/2013:17:22:46 +0200] "GET /robots.txt HTTP/1.1" 200 516 "-" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:5.0) Gecko/20100101 Firefox/5.0" "-"
#92.113.100.35 - - [29/Sep/2013:17:22:49 +0200] "GET /tghome.htm HTTP/1.1" 200 4445 "http://extrabot.com/help/frytygativyheku.htm" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:5.0) Gecko/20100101 Firefox/5.0" "-"
#92.113.100.35 - - [29/Sep/2013:17:22:51 +0200] "GET / HTTP/1.1" 200 5467 "http://extrabot.com/help/frytygativyheku.htm" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:5.0) Gecko/20100101 Firefox/5.0" "-"

# to do  MS Search 4.0 Robot

#package AWSROB;


# Robots list was found at http://www.robotstxt.org/wc/active/all.txt
# Other robots can be found at http://www.jafsoft.com/searchengines/webbots.html
# Rem: To avoid bad detection, some robot's ids were removed from this list:
#      - Robots with ID of 3 letters only
#      - Robots called 'webs' and 'tcl'
# Rem: directhit changed into direct_hit (its real id)
# Rem: calif changed into calif[^r] to avoid confusion between Tiscalifreenet browser
# Rem: fish changed into [^a]fish to avoid confusion between Madsafish browser
# Rem: roadrunner changed into road_runner
# Rem: lycos changed to lycos_ to avoid confusion with lycos-online browser
# Rem: voyager changed into ^voyager\/ to avoid to exclude voyager and amigavoyager browser

# RobotsSearchIDOrder
# It contains all matching criteria to search for in log fields. This list is
# used to know in which order to search Robot IDs.
# Most frequent ones are in list1, used when LevelForRobotsDetection is 1 or more
# Minor robots are in list2, used when LevelForRobotsDetection is 2 or more
# Note: Robots IDs are in lower case, '_', ' ' and '+' are changed into '[_+ ]' and are quoted.
#-------------------------------------------------------
@RobotsSearchIDOrder_list1 = (
# Common robots (In robot file)
'appie',
'architext',
'bingpreview',
'bjaaland',
'contentmatch',
'ferret',
'googlebot\-image',
'googlebot',
'google\-sitemaps',
'google[_+ ]web[_+ ]preview',
'grabber',
'gulliver',
'virus[_+ ]detector',		# Must be before harvest
'harvest',
'htdig',
'jeeves',
'linkwalker',
'lilina',
'lycos[_+ ]',
'moget',
'muscatferret',
'myweb',
'nomad',
'scooter',
'slurp',
'^voyager\/',
'weblayers',
# Common robots (Not in robot file)
'antibot',
'bruinbot',
'digout4u',
'echo!',
'fast\-webcrawler',
'ia_archiver\-web\.archive\.org', # Must be before ia_archiver to avoid confusion with alexa
'ia_archiver',
'jennybot',
'mercator',
'netcraft',
'msnbot\-media',
'msnbot',
'petersnews',
'relevantnoise\.com',
'unlost_web_crawler',
'voila',
'webbase',
'webcollage',
'cfetch',
'zyborg',	# Must be before wisenut
'wisenutbot'
);
@RobotsSearchIDOrder_list2 = (
# Less common robots (In robot file)
'[^a]fish',
'abcdatos',
'abonti\.com',
'acme\.spider',
'ahoythehomepagefinder',
'ahrefsbot',
'alkaline',
'anthill',
'arachnophilia',
'arale',
'araneo',
'aretha',
'ariadne',
'powermarks',
'arks',
'aspider',
'atn\.txt',
'atomz',
'auresys',
'backrub',
'bbot',
'bigbrother',
'blackwidow',
'blindekuh',
'bloodhound',
'borg\-bot',
'brightnet',
'bspider',
'cactvschemistryspider',
'calif[^r]',
'cassandra',
'cgireader',
'checkbot',
'christcrawler',
'churl',
'cienciaficcion',
'collective',
'combine',
'conceptbot',
'coolbot',
'core',
'cosmos',
'cruiser',
'cusco',
'cyberspyder',
'desertrealm',
'deweb',
'dienstspider',
'digger',
'diibot',
'direct_hit',
'dnabot',
'download_express',
'dragonbot',
'dwcp',
'e\-collector',
'ebiness',
'elfinbot',
'emacs',
'emcspider',
'esther',
'evliyacelebi',
'fastcrawler',
'feedcrawl',
'fdse',
'felix',
'fetchrover',
'fido',
'finnish',
'fireball',
'fouineur',
'francoroute',
'freecrawl',
'funnelweb',
'gama',
'gazz',
'gcreep',
'getbot',
'geturl',
'golem',
'gougou',
'grapnel',
'griffon',
'gromit',
'gulperbot',
'hambot',
'havindex',
'hometown',
'htmlgobble',
'hyperdecontextualizer',
'iajabot',
'iaskspider',
'hl_ftien_spider',
'sogou',
'icjobs\.de',
'iconoclast',
'ilse',
'imagelock',
'incywincy',
'informant',
'infoseek',
'infoseeksidewinder',
'infospider',
'inspectorwww',
'intelliagent',
'irobot',
'iron33',
'israelisearch',
'javabee',
'jbot',
'jcrawler',
'jobo',
'jobot',
'joebot',
'jubii',
'jumpstation',
'kapsi',
'katipo',
'kilroy',
'ko[_+ ]yappo[_+ ]robot',
'kummhttp',
'labelgrabber\.txt',
'larbin',
'legs',
'linkidator',
'linkscan',
'lockon',
'logo_gif',
'macworm',
'magpie',
'marvin',
'mattie',
'mediafox',
'merzscope',
'meshexplorer',
'mindcrawler',
'mnogosearch',
'momspider',
'monster',
'motor',
'muncher',
'mwdsearch',
'ndspider',
'nederland\.zoek',
'netcarta',
'netmechanic',
'netscoop',
'newscan\-online',
'nhse',
'northstar',
'nzexplorer',
'objectssearch',
'occam',
'octopus',
'openfind',
'orb_search',
'packrat',
'pageboy',
'parasite',
'patric',
'pegasus',
'perignator',
'perlcrawler',
'phantom',
'phpdig',
'piltdownman',
'pimptrain',
'pioneer',
'pitkow',
'pjspider',
'plumtreewebaccessor',
'poppi',
'portalb',
'psbot',
'python',
'raven',
'rbse',
'resumerobot',
'rhcs',
'road_runner',
'robbie',
'robi',
'robocrawl',
'robofox',
'robozilla',
'roverbot',
'rules',
'safetynetrobot',
'search\-info',
'search_au',
'searchprocess',
'senrigan',
'sgscout',
'shaggy',
'shaihulud',
'sift',
'simbot',
'site\-valet',
'sitetech',
'skymob',
'slcrawler',
'smartspider',
'snooper',
'solbot',
'speedy',
'spider[_+ ]monkey',
'spiderbot',
'spiderline',
'spiderman',
'spiderview',
'spry',
'sqworm',
'ssearcher',
'suke',
'sunrise',
'suntek',
'sven',
'tach_bw',
'tagyu_agent',
'tailrank',
'tarantula',
'tarspider',
'techbot',
'templeton',
'titan',
'titin',
'tkwww',
'tlspider',
'ucsd',
'udmsearch',
'universalfeedparser',
'urlck',
'valkyrie',
'verticrawl',
'victoria',
'visionsearch',
'voidbot',
'vwbot',
'w3index',
'w3m2',
'wallpaper',
'wanderer',
'wapspIRLider',
'webbandit',
'webcatcher',
'webcopy',
'webfetcher',
'webfoot',
'webinator',
'weblinker',
'webmirror',
'webmoose',
'webquest',
'webreader',
'webreaper',
'websnarf',
'webspider',
'webvac',
'webwalk',
'webwalker',
'webwatch',
'whatuseek',
'whowhere',
'wired\-digital',
'wmir',
'wolp',
'wombat',
'wordpress',
'worm',
'woozweb',
'wwwc',
'wz101',
'xget',
# Other robots reported by users
'1\-more_scanner',
'360spider',
'a6-indexer',
'accoona\-ai\-agent',
'activebookmark',
'adamm_bot',
'adsbot-google',
'almaden',
'aipbot',
'aleadsoftbot',
'alpha_search_agent',
'allrati',
'aport',
'archive\.org_bot',
'argus', 		# Must be before nutch
'arianna\.libero\.it',
'aspseek',
'asterias',
'awbot',
'backlinktest\.com',
'baiduspider',
'becomebot',
'bender',
'betabot',
'biglotron',
'bittorrent_bot',
'biz360[_+ ]spider',
'blogbridge[_+ ]service',
'bloglines',
'blogpulse',
'blogsearch',
'blogshares',
'blogslive',
'blogssay',
'bncf\.firenze\.sbn\.it\/raccolta\.txt',
'bobby',
'boitho\.com\-dc',
'bookmark\-manager',
'boris',
'bubing',
'bumblebee',
'candlelight[_+ ]favorites[_+ ]inspector',
'careerbot',
'cbn00glebot',
'cerberian_drtrs',
'cfnetwork',
'cipinetbot',
'checkweb_link_validator',
'commons\-httpclient',
'computer_and_automation_research_institute_crawler',
'converamultimediacrawler',
'converacrawler',
'copubbot',
'cscrawler',
'cse_html_validator_lite_online',
'cuasarbot',
'cursor',
'custo',
'datafountains\/dmoz_downloader',
'dataprovider\.com',
'daumoa',
'daviesbot',
'daypopbot',
'deepindex',
'dipsie\.bot',
'dnsgroup',
'domainchecker',
'domainsdb\.net',
'dulance',
'dumbot',
'dumm\.de\-bot',
'earthcom\.info',
'easydl',
'eccp',
'edgeio\-retriever',
'ets_v',
'exactseek',
'extreme[_+ ]picture[_+ ]finder',
'eventax',
'everbeecrawler',
'everest\-vulcan',
'ezresult',
'enteprise',
'facebook',
'fast_enterprise_crawler.*crawleradmin\.t\-info@telekom\.de',
'fast_enterprise_crawler.*t\-info_bi_cluster_crawleradmin\.t\-info@telekom\.de',
'matrix_s\.p\.a\._\-_fast_enterprise_crawler', # must come before fast enterprise crawler
'fast_enterprise_crawler',
'fast\-search\-engine',
'favicon',
'favorg',
'favorites_sweeper',
'feedburner',
'feedfetcher\-google',
'feedflow',
'feedster',
'feedsky',
'feedvalidator',
'filmkamerabot',
'filterdb\.iss\.net',
'findlinks',
'findexa_crawler',
'firmilybot',
'foaf-search\.net',
'fooky\.com\/ScorpionBot',
'g2crawler',
'gaisbot',
'geniebot',
'gigabot',
'girafabot',
'global_fetch',
'gnodspider',
'goforit\.com',
'goforitbot',
'gonzo',
'grapeshot',
'grub',
'gpu_p2p_crawler',
'henrythemiragorobot',
'heritrix',
'holmes',
'hoowwwer',
'hpprint',
'htmlparser',
'html[_+ ]link[_+ ]validator',
'httrack',
'hundesuche\.com\-bot',
'i-bot',
'ichiro',
'iltrovatore\-setaccio',
'infobot',
'infociousbot',
'infohelfer',
'infomine',
'insurancobot',
'integromedb\.org',
'internet[_+ ]ninja',
'internetarchive',
'internetseer',
'internetsupervision',
'ips\-agent',
'irlbot',
'isearch2006',
'istellabot',
'iupui_research_bot',
'jrtwine[_+ ]software[_+ ]check[_+ ]favorites[_+ ]utility',
'justview',
'kalambot',
'kamano\.de_newsfeedverzeichnis',
'kazoombot',
'kevin',
'keyoshid', # Must come before Y!J
'kinjabot',
'kinja\-imagebot',
'knowitall',
'knowledge\.com',
'kouaa_krawler',
'krugle',
'ksibot',
'kurzor',
'lanshanbot',
'letscrawl\.com',
'libcrawl',
'linkbot',
'linkdex\.com',
'link_valet_online',
'metager\-linkchecker',	# Must be before linkchecker
'linkchecker',
'livejournal\.com',
'lmspider',
'ltbot',
'lwp\-request',
'lwp\-trivial',
'magpierss',
'mail\.ru',
'mapoftheinternet\.com',
'mediapartners\-google',
'megite',
'metaspinner',
'miadev',
'microsoft bits',
'microsoft.*discovery', # = 'microsoft (?:office (?:protocol|existence)|data access internet publishing provider protocol) discovery',
'microsoft[_+ ]url[_+ ]control',
'mini\-reptile',
'minirank',
'missigua_locator',
'misterbot',
'miva',
'mizzu_labs',
'mj12bot',
'mojeekbot',
'msiecrawler',
'ms_search_4\.0_robot',
'msrabot',
'msrbot',
'mt::telegraph::agent',
'mydoyouhike',
'nagios',
'nasa_search',
'netestate ne crawler',
'netluchs',
'netsprint',
'newsgatoronline',
'nicebot',
'nimblecrawler',
'noxtrumbot',
'npbot',
'nutchcvs',
'nutchosu\-vlib',
'nutch',  # Must come after other nutch versions
'ocelli',
'octora_beta_bot',
'omniexplorer[_+ ]bot',
'onet\.pl[_+ ]sa',
'onfolio',
'opentaggerbot',
'openwebspider',
'oracle_ultra_search',
'orbiter',
'yodaobot',
'qihoobot',
'passwordmaker\.org',
'pear_http_request_class',
'peerbot',
'perman',
'php[_+ ]version[_+ ]tracker',
'pictureofinternet',
'ping\.blo\.gs',
'plinki',
'pluckfeedcrawler',
'pogodak',
'pompos',
'popdexter',
'port_huron_labs',
'postfavorites',
'projectwf\-java\-test\-crawler',
'proodlebot',
'pyquery',
'rambler',
'redalert',
'rojo',
'rssimagesbot',
'ruffle',
'rufusbot',
'sandcrawler',
'sbider',
'schizozilla',
'scumbot',
'searchguild[_+ ]dmoz[_+ ]experiment',
'searchmetricsbot',
'seekbot',
'semrushbot',
'sensis_web_crawler',
'seokicks\.de',
'seznambot',
'shim\-crawler',
'shoutcast',
'siteexplorer\.info',
'slysearch',
'snap\.com_beta_crawler',
'sohu\-search',
'sohu', # "sohu agent"
'snappy',
'spbot',
'sphere_scout',
'spiderlytics',
'spip',
'sproose_crawler',
'ssearch_bot',
'steeler',
'steroid__download',
'suchfin\-bot',
'superbot',
'surveybot',
'susie',
'syndic8',
'syndicapi',
'synoobot',
'tcl_http_client_package',
'technoratibot',
'teragramcrawlersurf',
'test_crawler',
'testbot',
't\-h\-u\-n\-d\-e\-r\-s\-t\-o\-n\-e',
'topicblogs',
'turnitinbot',
'turtlescanner',		# Must be before turtle
'turtle',
'tutorgigbot',
'twiceler',
'ubicrawler',
'ultraseek',
'unchaos_bot_hybrid_web_search_engine',
'unido\-bot',
'unisterbot',
'updated',
'ustc\-semantic\-group',
'vagabondo\-wap',
'vagabondo',
'vermut',
'versus_crawler_from_eda\.baykan@epfl\.ch',
'vespa_crawler',
'vortex',
'vse\/',
'w3c\-checklink',
'w3c[_+ ]css[_+ ]validator[_+ ]jfouffa',
'w3c_validator',
'watchmouse',
'wavefire',
'waybackarchive\.org',
'webclipping\.com',
'webcompass',
'webcrawl\.net',
'web_downloader',
'webdup',
'webfilter',
'webindexer',
'webminer',
'website[_+ ]monitoring[_+ ]bot',
'webvulncrawl',
'wells_search',
'wesee:search',
'wonderer',
'wume_crawler',
'wwweasel',
'xenu\'s_link_sleuth',
'xenu_link_sleuth',
'xirq',
'y!j', # Must come after keyoshid Y!J
'yacy',
'yahoo\-blogs',
'yahoo\-verticalcrawler',
'yahoofeedseeker',
'yahooseeker\-testing',
'yahooseeker',
'yahoo\-mmcrawler',
'yahoo!_mindset',
'yandex',
'flexum',
'yanga',
'yet-another-spider',
'yooglifetchagent',
'z\-add_link_checker',
'zealbot',
'zhuaxia',
'zspider',
'zeus',
'ng\/1\.', # put at end to avoid false positive
'ng\/2\.', # put at end to avoid false positive
'exabot',  # put at end to avoid false positive
# Additional bots found by Sussex.
'^[1-3]$', # Hiding bots. Doesn't appear to be a valid user agent.
'alltop',
'applesyndication',
'asynchttpclient',
'bingbot',
'blogged_crawl',
'bloglovin',
'butterfly',
'buzztracker',
'carpathia',
'catbot',
'chattertrap',
'check_http', #(nagios) a monitoring tool
'coldfusion',
'covario',
'daylifefeedfetcher',
'discobot',
'dlvr\.it',
'dreamwidth',
'drupal',
'ezoom',
'feedmyinbox',
'feedroll\.com',
'feedzira',
'fever\/',
'freenews',
'geohasher',
'hanrss',
'inagist',
'jacobin club',
'jakarta',
'js\-kit',
'largesmall crawler',
'linkedinbot',
'longurl',
'metauri',
'microsoft\-webdav\-miniredir',
'^motorola$',
'movabletype',
# These appear to be bots trying to hide. All of the usual architecture data is missing.
'^mozilla\/3\.0 \(compatible$',
'^mozilla\/4\.0$',
'^mozilla\/4\.0 \(compatible;\)$',
'^mozilla\/5\.0$',
'^mozilla\/5\.0 \(compatible;$',
'^mozilla\/5\.0 \(en\-us\)$',
'^mozilla\/5\.0 firefox\/3\.0\.5$',
'^msie',
# End of hiding bots.
'netnewswire',
' netseer ',
'netvibes',
'newrelicpinger',
'newsfox',
'nextgensearchbot',
'ning',
'pingdom',
'pita',
'postpost',
'postrank',
'printfulbot',
'protopage',
'proximic',
'quipply',
'r6\_',
'ratingburner',
'regator',
'rome client',
'rpt\-httpclient',
'rssgraffiti',
'sage\+\+',
'scoutjet',
'simplepie',
'sitebot',
'summify\.com',
'superfeedr',
'synthesio',
'teoma',
'topblogsinfo',
'topix\.net',
'trapit',
'trileet',
'tweetedtimes',
'twisted pagegetter',
'twitterbot',
'twitterfeed',
'unwindfetchor',
'wazzup',
'windows\-rss\-platform',
'wiumi',
'xydo',
'yahoo! slurp',
'yahoo pipes',
'yahoo\-newscrawler',
'yahoocachesystem',
'yahooexternalcache',
'yahoo! searchmonkey',
'yahooysmcm',
'yammer',
# 'yandexbot', #already covered by 'yandex'
'yeti',
'yie8',
'youdao',
'yourls',
'zemanta',
'zend_http_client',
'zumbot',
# Other id that are 99% of robots
'wget',
'libwww',
'^java\/[0-9]'   # put at end to avoid false positive
);
@RobotsSearchIDOrder_listgen = (
# Generic robot
'robot',
'checker',
'crawl',
'discovery',
'hunter',
'scanner',
'spider',
'sucker',
'bot[\s_+:,\.\;\/\\\-]',
'[\s_+:,\.\;\/\\\-]bot',
'curl',
'php',
'ruby\/',
'no_user_agent'
);



# RobotsHashIDLib
# List of robots names ('robot id','robot clear text')
#-------------------------------------------------------
%RobotsHashIDLib   = (
# Common robots (In robot file)
'appie','<a href="http://www.walhello.com/" title="Bot home page [new window]" target="_blank">Walhello appie</a>',
'architext','ArchitextSpider',
'bingpreview','Bing Preview bot',
'bjaaland','Bjaaland',
'ferret','Wild Ferret Web Hopper #1, #2, #3',
'contentmatch','<a href="http://p4p.cn.yahoo.com">Yahoo!China ContentMatch Crawler</a>',
'googlebot\-image','<a href="http://www.google.com/bot.html" title="Bot home page [new window]" target="_blank">Googlebot-Image</a>',
'googlebot','<a href="http://www.google.com/bot.html" title="Bot home page [new window]" target="_blank">Googlebot</a>',
'google\-sitemaps', 'Google Sitemaps',
'grabber', '<a href="http://www.sdsc.edu/" title="Seltsame Aktivitaeten vom San Diego Supercomputer Center [new window]" target="_blank">Grabber (SDSC)</a>',
'google[_+ ]web[_+ ]preview', 'Google Web Preview',
'gulliver','Northern Light Gulliver',
'virus[_+ ]detector','<a href="http://www.securecomputing.com/" title="virus_harvester@securecomputing.com; Bot home page [new window]" target="_blank">virus_detector</a>',
'harvest','Harvest',
'htdig','ht://Dig',
'jeeves','<a href="http://sp.ask.com/docs/about/tech_crawling.html" title="Bot home page [new window]" target="_blank">Ask</a>',
'linkwalker','LinkWalker',
'lilina','Lilina',
'lycos[_+ ]','Lycos',
'moget','moget',
'muscatferret','Muscat Ferret',
'myweb','Internet Shinchakubin',
'nomad','Nomad',
'scooter','Scooter',
'slurp','<a href="http://help.yahoo.com/help/us/ysearch/slurp/" title="Bot home page [new window]" target="_blank">Yahoo Slurp</a>',
'^voyager\/','Voyager',
'weblayers','Weblayers',
# Common robots (Not in robot file)
'antibot','Antibot',
'bruinbot','<a href="http://web.archive.org/" title="BruinBot home page [new window]" target="_blank">The web archive</a>',
'digout4u','Digout4u',
'echo!','EchO!',
'fast\-webcrawler','Fast-Webcrawler',
'ia_archiver\-web\.archive\.org','<a href="http://web.archive.org/" title="Bot home page [new window]" target="_blank">The web archive (IA Archiver)</a>',
'ia_archiver','<a href="http://www.alexa.com/" title="Bot home page [new window]" target="_blank">Alexa (IA Archiver)</a>',
'jennybot','JennyBot',
'mercator','Mercator',
'msnbot\-media','<a href="http://search.msn.com/msnbot.htm" title="Bot home page [new window]" target="_blank">MSNBot-media</a>',
'msnbot','<a href="http://search.msn.com/msnbot.htm" title="Bot home page [new window]" target="_blank">MSNBot</a>',
'netcraft','<a href="http://www.netcraft.com/survey/" title="Bot home page [new window]" target="_blank">Netcraft</a>',
'petersnews','Petersnews',
'unlost_web_crawler','Unlost Web Crawler',
'voila','Voila',
'webbase', 'WebBase',
'zyborg','<a href="http://www.WISEnutbot.com/" title="wn-14.zyborg@looksmart.net Bot home page [new window]" target="_blank">ZyBorg</a>',
'wisenutbot','<a href="http://www.WISEnutbot.com/" title="Bot home page [new window]" target="_blank">WISENutbot</a>',
'webcollage','<a href="http://www.jwz.org/webcollage/" title="WebCollage home page [new window]" target="_blank">WebCollage</a>',
'cfetch','<a href="http://www.kosmix.com/crawler.html" title="kosmix home page [new window]" target="_blank">Cfetch</a>',
# Less common robots (In robot file)
'[^a]fish','Fish search',
'abcdatos','ABCdatos BotLink',
'abonti\.com','<a href="http://www.abonti.com/" title="Abonti WebSearch [new window]" target="_blank">Abonti WebSearch</a>',
'acme\.spider','Acme.Spider',
'ahoythehomepagefinder','Ahoy! The Homepage Finder',
'ahrefsbot', '<a href="http://ahrefs.com/robot/" title="Bot home page [new window]" target="_blank">AhrefsBot</a>',
'alkaline','Alkaline',
'anthill','Anthill',
'arachnophilia','Arachnophilia',
'arale','Arale',
'araneo','Araneo',
'aretha','Aretha',
'ariadne','ARIADNE',
'powermarks','<a href="http://www.kaylon.com/power.html" title="Bot home page [new window]" target="_blank">Powermarks</a>', # must come before Arks; seen used by referrer spam
'arks','arks',
'aspider','ASpider (Associative Spider)',
'atn\.txt','ATN Worldwide',
'atomz','Atomz.com Search Robot',
'auresys','AURESYS',
'backrub','BackRub',
'bbot','BBot',
'bigbrother','Big Brother',
'blackwidow','BlackWidow',
'blindekuh','Die Blinde Kuh',
'bloodhound','Bloodhound',
'borg\-bot','Borg-Bot',
'brightnet','bright.net caching robot',
'bspider','BSpider',
'cactvschemistryspider','CACTVS Chemistry Spider',
'calif[^r]','Calif',
'cassandra','Cassandra',
'cgireader','Digimarc Marcspider/CGI',
'checkbot','Checkbot',
'christcrawler','ChristCrawler.com',
'churl','churl',
'cienciaficcion','cIeNcIaFiCcIoN.nEt',
'collective','Collective',
'combine','Combine System',
'conceptbot','Conceptbot',
'coolbot','CoolBot',
'core','Web Core / Roots',
'cosmos','XYLEME Robot',
'cruiser','Internet Cruiser Robot',
'cusco','Cusco',
'cyberspyder','CyberSpyder Link Test',
'desertrealm','Desert Realm Spider',
'deweb','DeWeb(c) Katalog/Index',
'dienstspider','DienstSpider',
'digger','Digger',
'diibot','Digital Integrity Robot',
'direct_hit','Direct Hit Grabber',
'dnabot','DNAbot',
'download_express','DownLoad Express',
'dragonbot','DragonBot',
'dwcp','DWCP (Dridus\' Web Cataloging Project)',
'e\-collector','e-collector',
'ebiness','EbiNess',
'elfinbot','ELFINBOT',
'emacs','Emacs-w3 Search Engine',
'emcspider','ananzi',
'esther','Esther',
'evliyacelebi','Evliya Celebi',
'fastcrawler','FastCrawler',
'feedcrawl','FeedCrawl by feed@aobo.com',
'fdse','Fluid Dynamics Search Engine robot',
'felix','Felix IDE',
'fetchrover','FetchRover',
'fido','fido',
'finnish','Finnish',
'fireball','KIT-Fireball',
'fouineur','Fouineur',
'francoroute','Robot Francoroute',
'freecrawl','Freecrawl',
'funnelweb','FunnelWeb',
'gama','gammaSpider, FocusedCrawler',
'gazz','gazz',
'gcreep','GCreep',
'getbot','GetBot',
'geturl','GetURL',
'golem','Golem',
'gougou','GouGou',
'grapnel','Grapnel/0.01 Experiment',
'griffon','Griffon',
'gromit','Gromit',
'gulperbot','Gulper Bot',
'hambot','HamBot',
'havindex','havIndex',
'hometown','Hometown Spider Pro',
'htmlgobble','HTMLgobble',
'hyperdecontextualizer','Hyper-Decontextualizer',
'iajabot','iajaBot',
'iaskspider','<a href="http://www.iask.com/" target="_blank">Sina Iask Spider</a>',
'hl_ftien_spider','<a href="http://www.hylanda.com/" target="_blank">Hylanda</a>',
'sogou','<a href="http://www.sogou.com/" target="_blank">Sogou Spider</a>',
'icjobs\.de', '<a href="http://www.icjobs.de/" target="_blank">iCjobs Spider</a>',
#20130805 The user agent string of the icjobs-spider contained the
#identifying string only when it accessed the robots.txt file.
#When it accessed the actual content it did not identify itself as
#a spider. Thus traffic of this spider was counted as user traffic.
#The behavious seems to have changed now - the spider identifies itself
#when it accesses content pages.
'iconoclast','Popular Iconoclast',
'ilse','Ingrid',
'imagelock','Imagelock',
'incywincy','IncyWincy',
'informant','Informant',
'infoseek','InfoSeek Robot 1.0',
'infoseeksidewinder','Infoseek Sidewinder',
'infospider','InfoSpiders',
'inspectorwww','Inspector Web',
'intelliagent','IntelliAgent',
'ips\-agent', 'ips-agent Verisign(?) - no reliable information found.',
'irobot','I, Robot',
'iron33','Iron33',
'israelisearch','Israeli-search',
'javabee','JavaBee',
'jbot','JBot Java Web Robot',
'jcrawler','JCrawler',
'jobo','JoBo Java Web Robot',
'jobot','Jobot',
'joebot','JoeBot',
'jubii','The Jubii Indexing Robot',
'jumpstation','JumpStation',
'kapsi','image.kapsi.net',
'katipo','Katipo',
'kilroy','Kilroy',
'ko[_+ ]yappo[_+ ]robot','KO_Yappo_Robot',
'kummhttp','<a href="http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&template=detail.html&match=\bid_g_l_301105_2\b" title="Bot documentation page [new window]" target="_blank">KummHttp</a>',
'labelgrabber\.txt','LabelGrabber',
'larbin','<a href="http://para.inria.fr/~ailleret/larbin/index-eng.html" title="Bot home page [new window]" target="_blank">larbin</a>',
'legs','legs',
'linkidator','Link Validator',
'linkscan','LinkScan',
'lockon','Lockon',
'logo_gif','logo.gif Crawler',
'macworm','Mac WWWWorm',
'lmspider','<a href="http://www.nuance.com/" title="Bot home page lmspider@scansoft.com [new window]" target="_blank">lmspider</a>',
'lwp\-request','<a href="http://search.cpan.org/~gaas/libwww-perl-5.69/bin/lwp-request" title="lwp-request home page [new window]" target="_blank">lwp-request</a>',
'lwp\-trivial','<a href="http://search.cpan.org/src/GAAS/libwww-perl-5.805/lib/LWP/Simple.pm" title="lwp-trivial home page [new window]" target="_blank">lwp-trivial</a>',
'magpie','<a href="http://magpierss.sf.net/" title="Bot home page [new window]" target="_blank">MagpieRSS</a>',
'marvin','marvin/infoseek',
'mattie','Mattie',
'mediafox','MediaFox',
'merzscope','MerzScope',
'meshexplorer','NEC-MeshExplorer',
'mindcrawler','MindCrawler',
'mnogosearch','mnoGoSearch search engine software',
'momspider','MOMspider',
'monster','Monster',
'motor','Motor',
'muncher','Muncher',
'mwdsearch','Mwd.Search',
'ndspider','NDSpider',
'nederland\.zoek','Nederland.zoek',
'netcarta','NetCarta WebMap Engine',
'netmechanic','<a href="http://www.netmechanic.com/" title="Bot home page [new window]" target="_blank">NetMechanic</a>',
'netscoop','NetScoop',
'newscan\-online','newscan-online',
'nhse','NHSE Web Forager',
'northstar','The NorthStar Robot',
'nzexplorer','nzexplorer',
'objectssearch','ObjectsSearch',
'occam','Occam',
'octopus','HKU WWW Octopus',
'openfind','Openfind data gatherer',
'orb_search','Orb Search',
'packrat','Pack Rat',
'pageboy','PageBoy',
'parasite','ParaSite',
'patric','Patric',
'pegasus','pegasus',
'perignator','The Peregrinator',
'perlcrawler','PerlCrawler 1.0',
'phantom','Phantom',
'phpdig','PhpDig',
'piltdownman','PiltdownMan',
'pimptrain','Pimptrain.com\'s robot',
'pioneer','Pioneer',
'pitkow','html_analyzer',
'pjspider','Portal Juice Spider',
'plumtreewebaccessor','PlumtreeWebAccessor',
'poppi','Poppi',
'portalb','PortalB Spider',
'psbot','<a href="http://www.picsearch.com/bot.html" title="Bot home page" target="_blank">psbot</a>',
'python','<a href="http://docs.python.org/library/urllib.html" title="Tools developed using a Python library" target="_blank">Python-urllib</a>',
'raven','Raven Search',
'rbse','RBSE Spider',
'resumerobot','Resume Robot',
'rhcs','RoadHouse Crawling System',
'road_runner','Road Runner: The ImageScape Robot',
'robbie','Robbie the Robot',
'robi','ComputingSite Robi/1.0',
'robocrawl','RoboCrawl Spider',
'robofox','RoboFox',
'robozilla','Robozilla',
'roverbot','Roverbot',
'rules','RuLeS',
'safetynetrobot','SafetyNet Robot',
'search\-info','Sleek',
'search_au','Search.Aus-AU.COM',
'searchprocess','SearchProcess',
'senrigan','Senrigan',
'sgscout','SG-Scout',
'shaggy','ShagSeeker',
'shaihulud','Shai\'Hulud',
'sift','Sift',
'simbot','Simmany Robot Ver1.0',
'site\-valet','Site Valet',
'sitetech','SiteTech-Rover',
'skymob','Skymob.com',
'slcrawler','SLCrawler',
'smartspider','Smart Spider',
'snooper','Snooper',
'solbot','Solbot',
'speedy','<a href="http://www.entireweb.com/about/search_tech/speedyspider/" title="Speedy Spider home page [new window]" target="_blank">Speedy Spider</a>',
'spider[_+ ]monkey','Spider monkey',
'spiderbot','SpiderBot',
'spiderline','Spiderline Crawler',
'spiderlytics', 'Spiderlytics: No homepage, e-mail only: spider (at) spiderlytics.com',
'spiderman','<a href="http://www.iscrawling.com" title="Spiderman home page [new window]" target="_blank">Spiderman</a>',
'spiderview','SpiderView(tm)',
'spry','Spry Wizard Robot',
'ssearcher','Site Searcher',
'sqworm','<a href="http://www.websense.com/" title="Bot home page (source: http://www.pgts.com.au/) [new window]" target="_blank">Sqworm</a>',
'suke','Suke',
'sunrise','<a href="http://www.sunrisexp.com/" title="Sunrise home page [new window]" target="_blank">Sunrise</a>',
'suntek','suntek search engine',
'sven','Sven',
'tach_bw','TACH Black Widow',
'tagyu_agent','<a href="http://www.tagyu.com/" title="Bot home page [new window]" target="_blank">Tagyu Agent</a>',
'tarantula','Tarantula',
'tarspider','tarspider',
'tailrank','<a href="http://tailrank.com/robot">TailRank</a>',
'techbot','TechBOT',
'templeton','Templeton',
'titan','TITAN',
'titin','TitIn',
'tkwww','The TkWWW Robot',
'tlspider','TLSpider',
'ucsd','UCSD Crawl',
'udmsearch','UdmSearch',
'universalfeedparser','<a href="http://feedparser.org/" title="Bot home page [new window]" target="_blank">UniversalFeedParser</a>',
'urlck','URL Check',
'valkyrie','Valkyrie',
'verticrawl','Verticrawl',
'victoria','Victoria',
'visionsearch','vision-search',
'voidbot','void-bot',
'vwbot','VWbot',
'w3index','The NWI Robot',
'w3m2','W3M2',
'wallpaper','WallPaper (alias crawlpaper)',
'wanderer','the World Wide Web Wanderer',
'wapspider','w@pSpider by wap4.com',
'webbandit','WebBandit Web Spider',
'webcatcher','WebCatcher',
'webcopy','WebCopy',
'webfetcher','webfetcher',
'webfoot','The Webfoot Robot',
'webinator','Webinator',
'weblinker','WebLinker',
'webmirror','WebMirror',
'webmoose','The Web Moose',
'webquest','WebQuest',
'webreader','Digimarc MarcSpider',
'webreaper','WebReaper',
'websnarf','Websnarf',
'webspider','WebSpider',
'webvac','WebVac',
'webwalk','webwalk',
'webwalker','WebWalker',
'webwatch','WebWatch',
'whatuseek','whatUseek Winona',
'whowhere','WhoWhere Robot',
'wired\-digital','Wired Digital',
'wmir','w3mir',
'wolp','WebStolperer',
'wombat','The Web Wombat',
'wordpress','<a href="http://wordpress.org/" title="WordPress home page [new window]" target="_blank">WordPress</a>',
'worm','The World Wide Web Worm',
'woozweb','Woozweb Monitoring',
'wwwc','WWWC Ver 0.2.5',
'wz101','WebZinger',
'xget','XGET',
# Other robots reported by users
'1\-more_scanner','<a href="http://www.myzips.com/software/1-More-Scanner.phtml" title="1-More Scanner home page [new window]" target="_blank">1-More Scanner</a>',
'360spider','<a href="https://www.google.com/search?q=360spider+-Ferrari" title="No home page, using Google search instead [new window]" target="_blank">360spider</a>',
'a6-indexer',  '<a href="http://www.a6corp.com/a6-web-scraping-policy/" rel="nofollow" title="A6-Indexer [new window]" target="_blank">A6-Indexer</a>',
'accoona\-ai\-agent','<a href="http://www.accoona.com/" title="Accoona-AI-Agent home page [new window]" target="_blank">Accoona-AI-Agent</a>',
'activebookmark','<a href="http://www.libmaster.com/active_bookmark.php" title="ActiveBookmark home page [new window]" target="_blank">ActiveBookmark</a>',
'adamm_bot','<a href="http://home.blic.net/adamm/" title="Bot home page [new window]" target="_blank">AdamM Bot</a>',
'adsbot-google', '<a href="http://www.google.com/adsbot.html" rel="nofollow" title="AdsBot-Google home page [new window]" target="_blank">AdsBot-Google</a>',
'almaden','<a href="http://www.almaden.ibm.com/cs/crawler" title="IBM Almaden Research Center WebFountain&trade; Bot home page [new window]" target="_blank">IBM Almaden</a> Research Center WebFountain&trade;',
'aipbot','<a href="http://www.aipbot.com/" title="aipbot@aipbot.com Bot home page [new window]" target="_blank">aipbot</a>',
'aleadsoftbot','<a href="http://www.aleadsoft.com/bot.htm" title="ALeadSoftbot home page [new window]" target="_blank">ALeadSoftbot</a>',
'alpha_search_agent','Alpha Search Agent',
'allrati','Allrati',
'aport', 'Aport',
'archive\.org_bot','<a href="http://crawls.archive.org/collections/bncf/crawl.html" title="Bot home page [new window]" target="_blank">archive.org bot</a>',
'argus','<a href="http://www.simpy.com/bot.html" title="feedback@simpy.com Bot home page [new window]" target="_blank">Argus</a>',
'arianna\.libero\.it','<a href="http://arianna.libero.it/" title="Bot home page [new window]" target="_blank">arianna.libero.it</a>',
'aspseek','<a href="http://www.aspseek.org/" title="Bot home page [new window]" target="_blank">ASPseek</a>',
'asterias', 'Asterias',
'awbot', 'AWBot',
'backlinktest\.com', '<a href="http://www.backlinktest.com/crawler.html" title="BacklinkCrawler [new window]" target="_blank">BacklinkCrawler</a>',
'baiduspider','<a href="http://www.baidu.com/search/spider.html" title="Bot home page [new window]" target="_blank">BaiDuSpider</a>',
'becomebot', '<a href="http://www.become.com/site_owners.html" title="Bot home page [new window]" target="_blank">BecomeBot</a>',
'bender','<a href="http://bender.ucr.edu/" title="Bot home page [new window]" target="_blank">bender</a> <a href="http://ivia.ucr.edu/manuals/NiFC/current/index.shtml" title="Bot home page [new window]" target="_blank">focused_crawler</a>',
'betabot','BetaBot',
'biglotron','<a href="http://www.biglotron.com/robot.html" title="Bot home page [new window]" target="_blank">Biglotron</a>',
'bittorrent_bot','<a href="http://www.bittorrent.com/" title="Bot home page [new window]" target="_blank">BitTorrent Bot</a>',
'biz360[_+ ]spider','<a href="http://www.biz360.com/" title="blogsmanager@biz360.com Bot home page [new window]" target="_blank">Biz360 spider</a>',
'blogbridge[_+ ]service','<a href="http://www.blogbridge.com/" title="Bot home page [new window]" target="_blank">BlogBridge Service</a>',
'bloglines','<a href="http://www.bloglines.com/" title="Bot home page [new window]" target="_blank">Bloglines</a>',
'blogpulse','<a href="http://www.intelliseek.com/" title="Bot home page [new window]" target="_blank">BlogPulse ISSpider intelliseek.com</a>',
'blogsearch','<a href="http://www.icerocket.com/" title="Bot home page [new window]" target="_blank">BlogSearch</a>',
'blogshares','<a href="http://blogshares.com/help.php?node=7" title="Bot home page [new window]" target="_blank">Blogshares Spiders</a>',
'blogslive','<a href="http://www.blogslive.com/" title="info@blogslive.com Bot home page [new window]" target="_blank">Blogslive</a>',
'blogssay','<a href="http://www.blogssay.com/" title="Bot home page [new window]" target="_blank">BlogsSay :: RSS Search Crawler</a>',
'bncf\.firenze\.sbn\.it\/raccolta\.txt','<a href="http://www.bncf.firenze.sbn.it/raccolta.txt" title="Bot home page [new window]" target="_blank">Biblioteca Nazionale Centrale di Firenze</a>',
'bobby', 'Bobby',
'boitho\.com\-dc','<a href="http://www.boitho.com/dcbot.html" title="Bot home page [new window]" target="_blank">boitho.com-dc</a>',
'bookmark\-manager','<a href="http://bkm.sourceforge.net/" title="Bookmark-Manager home page [new window]" target="_blank">Bookmark-Manager</a>',
'boris', 'Boris',
'bubing', '<a href="http://law.di.unimi.it/BUbiNG.html" title="BUbiNG [new window]" target="_blank">BUbiNG</a>',
'bumblebee', 'Bumblebee (relevare.com)',
'candlelight[_+ ]favorites[_+ ]inspector','<a href="http://www.candlelight.com/home.html" title="Candlelight_Favorites_Inspector  home page [new window]" target="_blank">Candlelight_Favorites_Inspector</a>',
'careerbot',  '<a href="http://www.career-x.de/bot.html" rel="nofollow" title="CareerBot home page [new window]" target="_blank">CareerBot</a>',
'cbn00glebot','cbn00glebot',
'cerberian_drtrs','<a href="http://www.pgts.com.au/cgi-bin/psql?robot_info=25240" title="Bot home page [new window]" target="_blank">Cerberian Drtrs</a>',
'cfnetwork','<a href="http://www.cocoadev.com/index.pl?CFNetwork" title="CFNetwork home page [new window]" target="_blank">CFNetwork</a>',
'cipinetbot','<a href="http://www.cipinet.com/bot.html" title="CipinetBot home page [new window]" target="_blank">CipinetBot</a>',
'checkweb_link_validator','<a href="http://p.duby.free.fr/chkweb.htm" title="CheckWeb link validator home page [new window]" target="_blank">CheckWeb link validator</a>',
'commons\-httpclient','<a href="http://jakarta.apache.org/commons/httpclient/" title="Bot home page [new window]" target="_blank">Jakarta commons-httpclient</a>',
'computer_and_automation_research_institute_crawler','<a href="http://www.ilab.sztaki.hu/~stamas/publications/p184-benczur.html" title="Computer and Automation Research Institute Crawler home page [new window]" target="_blank">Computer and Automation Research Institute Crawler</a>',
'converamultimediacrawler','<a href="http://www.authoritativeweb.com/crawl/" title="ConveraMultiMediaCrawler home page [new window]" target="_blank">ConveraMultiMediaCrawler</a>',
'converacrawler','<a href="http://www.authoritativeweb.com/crawl/" title="ConveraCrawler home page [new window]" target="_blank">ConveraCrawler</a>',
'copubbot', '<a href="http://www.copub.com/bot.php" rel="nofollow" title="CoPubbot Home Page [new window] Note: Access to bot home page gave a 404 error on Dec 21, 2013" target="_blank">CoPubbot</a>',
'cscrawler','CsCrawler',
'cse_html_validator_lite_online','<a href="http://online.htmlvalidator.com/php/onlinevallite.php" title="CSE HTML Validator Lite Online home page [new window]" target="_blank">CSE HTML Validator Lite Online</a>','cuasarbot','<a href="http://www.cuasar.com/" title="Cuasarbot home page [new window]" target="_blank">Cuasarbot</a>',
'cursor','<a href="http://adcenter.hu/docs/en/bot.html " title="Cursor home page [new window]" target="_blank">Cursor</a>',
'custo','<a href="http://www.netwu.com/custo/" title="Custo home page [new window]" target="_blank">Custo</a>',
'datafountains\/dmoz_downloader','<a href="http://infomine.ucr.edu/ " title="DataFountains/DMOZ Downloader home page [new window]" target="_blank">DataFountains/DMOZ Downloader</a>',
'dataprovider\.com', '<a href="http://www.dataprovider.com/" title="Dataprovider Site Explorer [new window]" target="_blank">Dataprovider Site Explorer</a>',
'daumoa', '<a href="http://tab.search.daum.net/aboutWebSearch.html" title="Daum [new window]" target="_blank">Daum</a>',
'daviesbot', 'DaviesBot',
'daypopbot', 'DayPop',
'deepindex','<a href="http://www.deepindex.net/faq.php" title="Deepindex home page [new window]" target="_blank">Deepindex</a>',
'dipsie\.bot','<a href="http://www.dipsie.com/bot/" title="Bot home page [new window]" target="_blank">Dipsie</a>',
'dnsgroup','<a href="http://www.dnsgroup.com/" title="DNSGroup home page [new window]" target="_blank">DNSGroup</a>',
'domainchecker','<a href="http://net-promoter.com/" title="DomainChecker home page (not confirmed) [new window]" target="_blank">DomainChecker</a>',
'domainsdb\.net','<a href="http://domainsdb.net/" title="Bot home page [new window]" target="_blank">DomainsDB.net</a>',
'dulance','<a href="http://www.dulance.com/bot.jsp" title="Bot home page [new window]" target="_blank">Dulance</a>',
'dumbot','<a href="http://www.dumbfind.com/" title="Dumbot home page [new window]" target="_blank">Dumbot</a>',
'dumm\.de\-bot','<a href="http://www.dumm.de/" title="dumm.de-Bot home page [new window]" target="_blank">dumm.de-Bot</a>',
'earthcom\.info','<a href="http://www.earthcom.info/" title="Bot home page [new window]" target="_blank">EARTHCOM.info</a>',
'easydl','<a href="http://keywen.com/Encyclopedia/Bot/" title="EasyDL  home page [new window]" target="_blank">EasyDL</a>',
'eccp', '<a href="http://www.eniro.com/" rel="nofollow" title="Eniro Sverige home page [new window]" target="_blank">Eniro Sverige, email: search (at) eniro.com</a>',
'edgeio\-retriever','<a href="http://www.edgeio.com/" title="Bot home page [new window]" target="_blank">edgeio-retriever</a>',
'ets_v','<a href="http://www.freetranslation.com/help/" title="ETS home page [new window]" target="_blank">ETS</a> Enterprise Translation Server',
'exactseek','ExactSeek Crawler',
'extreme[_+ ]picture[_+ ]finder','<a href="http://www.exisoftware.com/" title="Extreme_Picture_Finder home page [new window]" target="_blank">Extreme_Picture_Finder</a>',
'eventax','<a href="http://www.eventax.de/" title="eventax home page [new window]" target="_blank">eventax</a>',
'everbeecrawler','EverbeeCrawler',
'everest\-vulcan','<a href="http://everest.vulcan.com/crawlerhelp" title="Bot home page [new window]" target="_blank">Everest-Vulcan</a>',
'ezresult', 'Ezresult',
'enteprise','<a href="http://www.fastsearch.com/" title="Bot home page [new window]" target="_blank">Fast Enteprise Crawler</a>',
'facebook','FaceBook bot',
'fast\-search\-engine','<a href="http://www.fast-search-engine.com/" title="Bot home page [new window]" target="_blank">Fast-Search-Engine</a> (not fastsearch.com)',
'fast_enterprise_crawler','<a href="http://www.fast.no/" title="FAST Enterprise Crawler home page [new window]" target="_blank">FAST Enterprise Crawler</a>',
'fast_enterprise_crawler.*scrawleradmin\.t\-info@telekom\.de','<a href="http://www.telekom.de/" title="FAST Enterprise Crawler * crawleradmin.t-info@telekom.de home page [new window]" target="_blank">FAST Enterprise Crawler * crawleradmin.t-info@telekom.de</a>',
'matrix_s\.p\.a\._\-_fast_enterprise_crawler','<a href="http://tin.virgilio.it/" title="Matrix S.p.A. - FAST Enterprise Crawler home page [new window]" target="_blank">Matrix S.p.A. - FAST Enterprise Crawler</a>',
'fast_enterprise_crawler.*t\-info_bi_cluster_crawleradmin\.t\-info@telekom\.de','<a href="http://www.telekom.de/" title="FAST Enterprise Crawler * T-Info_BI_cluster crawleradmin.t-info@telekom.de home page [new window]" target="_blank">FAST Enterprise Crawler * T-Info_BI_cluster crawleradmin.t-info@telekom.de</a>',
'favicon','FavIconizer',
'favorg','<a href="http://www.pcmag.com/article2/0,4149,108438,00.asp" title="FavOrg home page [new window]" target="_blank">FavOrg</a>',
'favorites_sweeper','<a href="http://www.manitools.com/favsweep/" title="Favorites_Sweeper home page [new window]" target="_blank">Favorites Sweeper</a>',
'feedburner', 'Feedburner',
'feedfetcher\-google','<a href="http://www.google.com/feedfetcher.html" title="Bot home page [new window]" target="_blank">Feedfetcher-Google</a>',
'feedflow','<a href="http://feedflow.com/about" title="Bot home page [new window]" target="_blank">FeedFlow</a>',
'feedster','<a href="http://www.feedster.com/" title="Bot home page [new window]" target="_blank">Feedster</a>',
'feedsky','<a href="http://www.feedsky.com/" title="Bot home page [new window]" target="_blank">FeedSky</a>',
'feedvalidator','<a href="http://feedvalidator.org/" title="FeedValidator home page [new window]" target="_blank">FeedValidator</a>',
'filmkamerabot','<a href="http://www.filmkamera.at/bot.html" title="FilmkameraBot home page [new window]" target="_blank">FilmkameraBot</a>',
'filterdb\.iss\.net',  '<a href="http://filterdb.iss.net/crawler/" title="oBot Home Page [new window]" target="_blank">oBot</a>',
'findexa_crawler','<a href="http://www.findexa.no/gulesider/article26548.ece " title="Findexa Crawler home page [new window]" target="_blank">Findexa Crawler</a>',
'firmilybot', '<a href="http://www.firmily.com/bot.php" title="Firmily Bot [new window]" target="_blank">Firmily Bot Home page (Website was hacked on Oct. 19, 2013)</a>',
'findlinks','<a href="http://wortschatz.uni-leipzig.de/findlinks/" title="Bot home page [new window]" target="_blank">Findlinks</a>',
'foaf-search\.net', '<a href="http://www.foaf-search.net/" title="Friend of a friend (FOAF) search engine [new window]" target="_blank">Friend of a friend (FOAF) search engine</a>',
'fooky\.com\/ScorpionBot','<a href="http://www.fooky.com/scorpionbots" title="Fooky.com/ScorpionBot/ScoutOut home page [new window]" target="_blank">Fooky.com/ScorpionBot/ScoutOut</a>',
'g2crawler','<a href="http://crawler.instantnetworks.net/" title="Bot home page (nobody@airmail.net) [new window]" target="_blank">G2Crawler</a>',
'gaisbot','<a href="http://gais.cs.ccu.edu.tw/robot.php" title="Bot home page [new window]" target="_blank">Gaisbot</a>',
'geniebot','<a href="http://www.genieknows.com/" title="Bot home page [new window]" target="_blank">Geniebot</a>',
'gigabot','<a href="http://www.gigablast.com/spider.html" title="Bot home page [new window]" target="_blank">GigaBot</a>',
'girafabot','<a href="http://www.girafa.com/" title="Bot home page [new window]" target="_blank">Girafabot</a>',
'global_fetch','<a href="http://www.wesonet.com/" title="Global Fetch home page [new window]" target="_blank">Global Fetch</a>',
'gnodspider','GNOD Spider',
'goforit\.com','<a href="http://www.goforit.com/about/" title="GoForIt.com home page [new window]" target="_blank">GoForIt.com</a>',
'goforitbot','<a href="http://www.goforit.com/about/" title="GOFORITBOT home page [new window]" target="_blank">GOFORITBOT</a>',
'gonzo','<a href="http://www.suchen.de/faq.html" title="Bot home page [new windows]" target="_blank">suchen.de</a>',
'gpu_p2p_crawler','<a href="http://gpu.sourceforge.net/search_engine.php" title="Bot home page [new window]" target="_blank">GPU p2p crawler</a>',
'grapeshot', '<a href="http://www.grapeshot.co.uk/crawler.php" title="Grapeshot Crawler [new window]" target="_blank">Grapeshot Crawler</a>',
'grub','Grub.org',
'henrythemiragorobot', '<a href="http://www.miragorobot.com/scripts/mrinfo.asp" title="Bot home page [new window]" target="_blank">Mirago</a>',
'heritrix','<a href="http://crawler.archive.org/" title="(used by a few different companies) Bot home page [new window]" target="_blank">Heritrix</a>',
'holmes', 'Holmes',
'hoowwwer','<a href="http://cosco.hiit.fi/search/hoowwwer/" title="HooWWWer home page [new window]" target="_blank">HooWWWer</a>',
'hpprint','HPPrint',
'htmlparser','<a href="http://htmlparser.sourceforge.net/" title="HTMLParser home page [new window]" target="_blank">HTMLParser</a>',
'html[_+ ]link[_+ ]validator','<a href="http://www.lithopssoft.com/ " title="Html_Link_Validator home page [new window]" target="_blank">Html_Link_Validator</a>',
'httrack','<a href="http://www.httrack.com/" title="Bot home page [new window]" target="_blank">HTTrack off-line browser</a>',
'hundesuche\.com\-bot','<a href="http://www.hundesuche.com/" title="Hundesuche.com-Bot home page [new window]" target="_blank">Hundesuche.com-Bot</a>',
'i-bot','i-bot',
'ichiro','<a href="http://help.goo.ne.jp/door/crawlerE.html" title="Bot home page [new window]" target="_blank">ichiro</a>',
'iltrovatore\-setaccio','<a href="http://www.iltrovatore.it/aiuto/motore_di_ricerca.html" title="bot@iltrovatore.it IlTrovatore-Setaccio home page [new window]" target="_blank">IlTrovatore-Setaccio</a>',
'infobot','<a href="http://www.infobot.org/" title="InfoBot home page [new window]" target="_blank">InfoBot</a>',
'infociousbot','<a href="http://corp.infocious.com/tech_crawler.php" title="InfociousBot home page [new window]" target="_blank">InfociousBot</a>',
'infohelfer','<a href="http://www.infohelfer.de/crawler.php" title="Infohelfer home page [new window]" target="_blank">Infohelfer</a>',
'infomine','<a href="http://infomine.ucr.edu/useragents" title="Bot home page [new window]" target="_blank">INFOMINE VLCrawler</a>',
'insurancobot','<a href="http://www.fastspywareremoval.com/" title="InsurancoBot home page [new window]" target="_blank">InsurancoBot</a>',
'integromedb\.org','<a href="http://www.integromedb.org/Crawler" title="IntegromeDB home page [new window]" target="_blank">IntegromeDB</a>',
'internet[_+ ]ninja','<a href="http://www.dti.ne.jp/  " title="Internet_Ninja home page [new window]" target="_blank">Internet_Ninja </a>',
'internetarchive','<a href="http://lucene.apache.org/nutch/bot.html " title="InternetArchive home page [new window]" target="_blank">InternetArchive</a>',
'internetseer', 'InternetSeer',
'internetsupervision','<a href="http://internetsupervision.com/" title="InternetSupervision home page [new window]" target="_blank">InternetSupervision</a>',
'irlbot','<a href="http://irl.cs.tamu.edu/crawler" title="Bot home page [new window]" target="_blank">IRLbot</a>',
'isearch2006','<a href="http://www.yahoo.com.cn/" title="isearch2006 home page [new window]" target="_blank">isearch2006</a>',
'istellabot', '<a href="http://www.tiscali.it/" title="IstellaBot [new window]" target="_blank">IstellaBot</a>',
'iupui_research_bot','<a href="http://spamhuntress.com/2005/04/25/a-mail-harvester-visits/" title="IUPUI_Research_Bot home page [new window]" target="_blank">IUPUI_Research_Bot</a>',
'jrtwine[_+ ]software[_+ ]check[_+ ]favorites[_+ ]utility','<a href="http://www.jrtwine.com/Products/CheckFavs/" title="JRTwine_Software_Check_Favorites_Utility  home page [new window]" target="_blank">JRTwine_Software_Check_Favorites_Utility</a>',
'justview', 'JustView',
'kalambot','<a href="http://64.124.122.251/feedback.html" title="KalamBot home page [new window]" target="_blank">KalamBot</a>',
'kamano\.de_newsfeedverzeichnis','<a href="http://www.kamano.de/" title="kamano.de NewsFeedVerzeichnis home page [new window]" target="_blank">kamano.de NewsFeedVerzeichnis</a>',
'kazoombot','<a href="http://www.kazoom.ca/bot.html" title="kazoombot@kazoom.ca KazoomBot home page [new window]" target="_blank">KazoomBot</a>',
'kevin','<a href="http://dznet.com/kevin/" title="Kevin home page [new window]" target="_blank">Kevin</a>',
'keyoshid','<a href="http://www.yahoo.co.jp/" title="Bot home page [new window]" target="_blank">Yahoo! Japan keyoshid robot study</a>',
'kinjabot', 'Kinjabot',
'kinja\-imagebot', 'Kinja Imagebot',
'knowitall','<a href="http://www.cs.washington.edu/research/knowitall/" title="KnowItAll home page [new window]" target="_blank">KnowItAll</a>',
'knowledge\.com','<a href="http://www.knowledge.com/" title="Knowledge.com home page [new window]" target="_blank">Knowledge.com</a>',
'kouaa_krawler','<a href="http://www.kouaa.com/" title="Kouaa Krawler home page [new window]" target="_blank">Kouaa Krawler</a>',
'krugle','<a href="http://www.krugle.com/crawler/info.html" title="Bot home page [new window]" target="_blank">Krugle</a>',
'ksibot','<a href="http://ego.ms.mff.cuni.cz/" title="Bot home page [new window]" target="_blank">ksibot</a>',
'kurzor','<a href="http://www.easymail.hu/" title="cursor@easymail.hu Kurzor home page [new window]" target="_blank">Kurzor</a>',
'lanshanbot','<a href="http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&amp;template=detail.html&amp;match=%5Cbid_g_l_140406_1%5Cb" title="Bot Information [new window]" target="_blank">lanshanbot</a>',
'letscrawl\.com','<a href="http://letscrawl.com/" title="Bot home page [new window]" target="_blank">LetsCrawl.com</a>',
'libcrawl','Crawl libcrawl',
'link_valet_online','<a href="http://www.htmlhelp.com/tools/valet/" title="Link Valet Online home page [new window]" target="_blank">Link Valet Online</a>',
'linkbot','LinkBot',
'linkdex\.com', '<a href="http://www.linkdex.com/about/bots/" title="Bot home page [new window]" target="_blank">Linkdex</a>',
'linkchecker','<a href="http://linkchecker.sourceforge.net" title="Bot home page [new window]" target="_blank">LinkChecker</a>',
'livejournal\.com', 'LiveJournal.com',
'ltbot', '<a href="http://www.language-tools.com/" title="Language Tools Home Page [new window]" target="_blank">Language Tools Bot (ltbot)</a>',
'magpierss', 'MagpieRSS',
'mail\.ru', '<a href="http://go.mail.ru/help/robots" title="Mail.ru bot home page [new window]" target="_blank">Mail.ru bot</a>',
'mapoftheinternet\.com','<a href="http://MapoftheInternet.com/" title="MapoftheInternet.com home page [new window]" target="_blank">MapoftheInternet.com</a>',
'mediapartners\-google','<a href="https://adwords.google.com/" title="Bot home page [new window]" target="_blank">Google AdSense</a>',
'megite','<a href="http://www.megite.com/" title="Megite home page [new window]" target="_blank">Megite</a>',
'metager\-linkchecker','MetaGer LinkChecker',
'metaspinner','<a href="http://index.meta-spinner.de/" title="Metaspinner home page [new window]" target="_blank">Metaspinner</a>',
'miadev',  '<a href="http://www.mia-marktplatz.de/spider" rel="nofollow" title="MiaDev spider [new window]" target="_blank">MiaDev spider</a>',
'microsoft bits', '<a href="http://msdn.microsoft.com/en-us/library/bb968799%28v=vs.85%29.aspx" rel="nofollow" title="Microsoft Background Intelligent Transfer Service (BITS)? [new window]" target="_blank">Microsoft Background Intelligent Transfer Service (BITS)?</a>',
'microsoft.*discovery', '<a href="http://support.microsoft.com/kb/838028/en-us" title="Microsoft KB838028 [new window]" target="_blank">Microsoft Office Protocol Discovery</a>/<a href="http://blogs.msdn.com/b/vsofficedeveloper/archive/2008/03/11/office-existence-discovery-protocol.aspx" title="Description of the Microsoft Office Existence Discovery [new window]" target="_blank">Microsoft Office Existence Discovery</a>',
'microsoft[_+ ]url[_+ ]control','<a href="http://www.webmasterworld.com/forum11/1005.htm" title="Microsoft URL Control  home page [new window]" target="_blank">Microsoft URL Control</a>',
'minirank','<a href="http://minirank.com/" title="miniRank home page [new window]" target="_blank">miniRank</a>',
'mini\-reptile','Mini-reptile',
'missigua_locator','<a href="http://www.webmasterworld.com/forum11/2690.htm" title="Missigua_Locator  home page [new window]" target="_blank">Missigua_Locator</a>',
'misterbot','<a href="http://www.misterbot.fr/" title="Misterbot home page [new window]" target="_blank">Misterbot</a>',
'miva','<a href="http://www.miva.com/" title="Miva home page [new window]" target="_blank">Miva</a>',
'mizzu_labs','<a href="http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&amp;template=detail.html&amp;match=\bid_m_141105_2\b " title="Mizzu Labs home page [new window]" target="_blank">Mizzu Labs</a>',
'mj12bot','<a href="http://majestic12.co.uk/bot.php" title="Bot home page. [new window]" target="_blank">MJ12bot</a>',
'mojeekbot','<a href="http://www.mojeek.com/bot.html" title="Bot home page. [new window]" target="_blank">MojeekBot</a>',
'msiecrawler','<a href="http://msdn.microsoft.com/workshop/delivery/offline/linkrel.asp" title="Bot home page. [new window]" target="_blank">MSIECrawler</a>',
'ms_search_4\.0_robot','<a href="http://support.microsoft.com/default.aspx?scid=kb;en-us;284022" title="Bot home page. [new window]" target="_blank">MS SharePoint Portal Server - MS Search 4.0 Robot</a>',
'msrabot','msrabot',
'msrbot','<a href="http://research.microsoft.com/research/sv/msrbot/" title="MSRBOT home page [new window]" target="_blank">MSRBOT</a>',
'mt::telegraph::agent','MT::Telegraph::Agent',
'mydoyouhike','<a href="http://www.doyouhike.net/my" title="Mydoyouhike home page [new window]" target="_blank">Mydoyouhike</a>',
'nagios','Nagios',
'nasa_search','<a href="http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&amp;template=detail.html&amp;match=\bid_n_s_140506_2\b" title="NASA Search home page [new window]" target="_blank">NASA Search</a>',
'netestate ne crawler','<a href="http://www.website-datenbank.de/" title="Website-Datenbank home page [new window]" target="_blank">Website-Datenbank</a>',
'netluchs','<a href="http://www.netluchs.de/" title="Bot home page. [new window]" target="_blank">Netluchs</a>',
'netsprint','<a href="http://www.netsprint.pl/serwis/" title="NetSprint home page [new window]" target="_blank">NetSprint</a>',
'newsgatoronline', 'NewsGator Online',
'nicebot','<a href="http://www.egghelp.org/setup.htm" title="Bot home page (there may be others) [new window]" target="_blank">nicebot</a>',
'nimblecrawler','<a href="http://www.healthline.com/" title="NimbleCrawler home page [new window]" target="_blank">NimbleCrawler</a>',
'noxtrumbot','<a href="http://www.noxtrum.com/" title="Bot home page [new window]" target="_blank">noxtrumbot</a>',
'npbot','<a href="http://www.nameprotect.com/botinfo.html" title="NPBot home page [new window]" target="_blank">NPBot</a>',
'nutchcvs','<a href="http://lucene.apache.org/nutch/bot.html" title="NutchCVS home page [new window]" target="_blank">NutchCVS</a>',
'nutchosu\-vlib','<a href="http://lucene.apache.org/nutch/bot.html" title="NutchOSU-VLIB home page [new window]" target="_blank">NutchOSU-VLIB</a>',
'nutch','<a href="http://lucene.apache.org/nutch/" title="Bot home page. Used by many, including Looksmart. [new window]" target="_blank">Nutch</a>',
'ocelli','<a href="http://www.globalspec.com/Ocelli/" title="Ocelli home page [new window]" target="_blank">Ocelli</a>',
'octora_beta_bot','<a href="http://www.octora.com/" title="Bot home page [new window]" target="_blank">Octora Beta Bot</a>',
'omniexplorer[_+ ]bot','<a href="http://www.omni-explorer.com/" title="Bot home page. [new window]" target="_blank">OmniExplorer Bot</a>',
'onet\.pl[_+ ]sa','<a href="http://szukaj.onet.pl/" title="Onet.pl_SA home page [new window]" target="_blank">Onet.pl_SA</a>',
'onfolio','<a href="http://www.onfolio.com/" title="Bot home page [new window]">Onfolio</a>',
'opentaggerbot','<a href="http://www.opentagger.com/opentaggerbot.htm" title="Bot home page [new window]">OpenTaggerBot</a>',
'openwebspider','<a href="http://www.openwebspider.org/" title="OpenWebSpider home page [new window]" target="_blank">OpenWebSpider</a>',
'oracle_ultra_search','<a href="http://www.oracle.com/technology/products/ultrasearch/index.html" title="Oracle Ultra Search home page [new window]" target="_blank">Oracle Ultra Search</a>',
'orbiter','<a href="http://www.dailyorbit.com/bot.htm" title="Orbiter home page [new window]" target="_blank">Orbiter</a>',
'yodaobot','<a href="http://www.yodao.com/help/webmaster/spider/" title="YodaoBot">OutfoxBot/YodaoBot</a>',
'qihoobot','<a href="http://www.qihoo.com/" title="QihooBot">QihooBot</a>',
'passwordmaker\.org','<a href="http://passwordmaker.org/" title="passwordmaker.org home page [new window]" target="_blank">passwordmaker.org</a>',
'pear_http_request_class','<a href="http://pear.php.net/" title="PEAR HTTP Request class home page [new window]" target="_blank">PEAR HTTP Request class</a>',
'peerbot','<a href="http://www.peerbot.com/" title="PEERbot home page [new window]" target="_blank">PEERbot</a>',
'perman', 'Perman surfer',
'php[_+ ]version[_+ ]tracker','<a href="http://www.nexen.net/phpversion/bot.php" title="PHP Version Tracker home page [new window]" target="_blank">PHP version tracker</a>',
'pictureofinternet','<a href="http://malfunction.org/poi/" title="PictureOfInternet home page [new window]" target="_blank">PictureOfInternet</a>',
'ping\.blo\.gs','<a href="http://blo.gs/ping.php" title="Bot home page. [new window]" target="_blank">ping.blo.gs</a>',
'plinki','<a href="http://www.plinki.com/" title="plinki home page [new window]" target="_blank">plinki</a>',
'pluckfeedcrawler','<a href="http://www.pluck.com/" title="Bot home page. [new window]" target="_blank">PluckFeedCrawler</a>',
'pogodak','<a href="http://www.pogodak.com" title="Pogodak home page [new window]" target="_blank">Pogodak.com</a>',
'pompos','<a href="http://dir.com/pompos.html" title="Bot home page. [new window]" target="_blank">Pompos</a>',
'popdexter','Popdexter',
'port_huron_labs','<a href="http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&amp;template=detail.html&amp;match=\bid_n_s_1133\b" title="Port Huron Labs home page [new window]" target="_blank">Port Huron Labs</a>',
'postfavorites','<a href="http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&amp;template=detail.html&amp;match=\bid_n_s_1135\b " title="PostFavorites home page [new window]" target="_blank">PostFavorites</a>',
'projectwf\-java\-test\-crawler','ProjectWF-java-test-crawler',
'proodlebot','<a href="http://www.proodle.com/" title="proodleBot home page [new window]" target="_blank">proodleBot</a>',
'pyquery','<a href="http://sourceforge.net/projects/pyquery/" title="PyQuery home page [new window]" target="_blank">PyQuery</a>',
'rambler','<a href="http://www.rambler.ru/doc/faq.shtml" title="Bot home page [new window]">StackRambler</a>',
'redalert','Red Alert',
'relevantnoise\.com', '<a href="http://www.relevantnoise.com/" title="Relevant Noise [new window]" target="_blank">Relevant Noise</a>',
'rojo','<a href="http://rojo.com/" title="Bot home page [new window]" target="_blank">RoJo</a> aggregator',
'rssimagesbot','<a href="http://herbert.groot.jebbink.nl/?app=rssImages" title="Bot home page [new window]" target="_blank">rssImagesBot</a>',
'ruffle','<a href="http://www.unreach.net/" title="Bot home page [new window]" target="_blank">ruffle SemanticWeb crawler</a>',
'rufusbot','<a href="http://64.124.122.252.webaroo.com/feedback.html" title="Bot home page [new window]" target="_blank">RufusBot Rufus Web Miner</a>',
'sandcrawler','<a href="http://www.microsoft.com/" title="Bot home page [new window]" target="_blank">SandCrawler (Microsoft)</a>',
'sbider','<a href="http://www.sitesell.com/sbider.html" title="Bot home page [new window]" target="_blank">SBIder</a>',
'schizozilla','<a href="http://spamhuntress.com/2005/03/18/gizmo/ " title="Schizozilla home page [new window]" target="_blank">Schizozilla</a>',
'scumbot','Scumbot',
'searchguild[_+ ]dmoz[_+ ]experiment','<a href="http://www.searchguild.com/" title="SearchGuild_DMOZ_Experiment  home page [new window]" target="_blank">SearchGuild_DMOZ_Experiment</a>',
'searchmetricsbot','<a href="http://www.searchmetrics.com/en/searchmetrics-bot/" rel="nofollow" title="SearchmetricsBot [new window]" target="_blank">SearchmetricsBot</a>',
'seekbot','<a href="http://www.seekbot.net/bot.html" title="Bot home page [new window]">Seekbot</a>',
'semrushbot', '<a href="http://www.semrush.com/bot.html" rel="nofollow" title="SemrushBot [new window]" target="_blank">SemrushBot</a>',
'sensis_web_crawler','<a href="http://www.sensis.com.au/" title="Sensis Web Crawler home page [new window]" target="_blank">Sensis Web Crawler</a>',
'seokicks\.de', '<a href="http://www.seokicks.de/robot.html" rel="nofollow" title="SEOkicks Webcrawler home page [new window]" target="_blank">SEOkicks Webcrawler</a>',
'seznambot','<a href="http://fulltext.seznam.cz/" title="Bot home page [new window]" target="_blank">SeznamBot</a>',
'shim\-crawler','<a href="http://www.logos.ic.i.u-tokyo.ac.jp/crawler/" title="crawl@logos.ic.i.u-tokyo.ac.jp Bot home page [new window]" target="_blank">Shim-Crawler</a>',
'shoutcast','Shoutcast Directory Service',
'siteexplorer\.info', '<a href="http://siteexplorer.info/" title="Site Explorer home page [new window]" target="_blank">Site Explorer</a>',
'slysearch','SlySearch',
'snap\.com_beta_crawler','<a href="http://www.snap.com/" title="snap.com beta crawler home page [new window]" target="_blank">snap.com beta crawler</a>',
'sohu\-search','<a href="http://corp.sohu.com/" title="Bot home page [new window]" target="_blank">sohu-search</a>',
'sohu','<a href="http://corp.sohu.com/" title="Bot home page [new window]" target="_blank">sohu agent</a>',
'snappy','<a href="http://www.urltrends.com/faq.php" title="Bot home page [new window]" target="_blank">Snappy</a>',
'spbot', '<a href="http://www.seoprofiler.com/bot" rel="nofollow" title="SEOprofiler Bot [new window]" target="_blank">SEOprofiler Bot</a>',
'sphere_scout','<a href="http://www.sphere.com/" title="Bot home page [new window]" target="_blank">Sphere Scout</a>',
'spip','<a href="http://www.spip.net" title="SPIP home page [new window]" target="_blank">SPIP</a>',
'sproose_crawler','<a href="http://www.sproose.com/bot.html" title="Bot home page [new window]" target="_blank">sproose crawler</a>',
'ssearch_bot', '<a href="http://www.semantissimo.de/" title="sSearch Crawler [new window]" target="_blank">sSearch Crawler</a>',
'steroid__download','<a href="http://faqs.org.ru/progr/pascal/delphi_internet2.htm" title="STEROID  Download home page [new window]" target="_blank">STEROID  Download</a>',
'steeler','<a href="http://www.tkl.iis.u-tokyo.ac.jp/~crawler/ " title="Steeler home page [new window]" target="_blank">Steeler</a>',
'suchfin\-bot','<a href="http://www.suchfin.de/" title="Suchfin-Bot home page [new window]" target="_blank">Suchfin-Bot</a>',
'superbot','<a href="http://www.sparkleware.com/superbot/" title="SuperBot home page [new window]" target="_blank">SuperBot</a>',
'surveybot','SurveyBot',
'susie','<a href="http://www.sync2it.com/bms/susie.php" title="Susie home page [new window]" target="_blank">Susie</a>',
'syndic8','Syndic8',
'syndicapi','<a href="http://syndicapi.com/bot.html" title="Bot home page [new window]" target="_blank">SyndicAPI</a>',
'synoobot','<a href="http://www.synoo.de/bot.html" title="webmaster@synoo.com SynooBot home page [new window]" target="_blank">SynooBot</a>',
'tcl_http_client_package','<a href="http://www.tcl.tk/man/tcl8.4/TclCmd/http.htm" title="Tcl http client package home page [new window]" target="_blank">Tcl http client package</a>',
'technoratibot', 'Technoratibot',
'teragramcrawlersurf','<a href="http://www.teragram.com/" title="TeragramCrawlerSURF home page [new window]" target="_blank">TeragramCrawlerSURF</a>',
'test_crawler','<a href="http://netp.ath.cx/" title="Test Crawler home page [new window]" target="_blank">Test Crawler</a>',
'testbot','<a href="http://www.agbrain.com/" title="TestBot home page [new window]" target="_blank">TestBot</a>',
't\-h\-u\-n\-d\-e\-r\-s\-t\-o\-n\-e','<a href="http://www.thunderstone.com/" title="Bot home page. Used by many. [new window]" target="_blank">T-H-U-N-D-E-R-S-T-O-N-E</a>',
'topicblogs', '<a href="http://www.topicblogs.com/" title="Bot home page [new window]" target="_blank">topicblogs</a>',
'turnitinbot','Turn It In',
'turtle', 'Turtle',
'turtlescanner', 'Turtle',
'tutorgigbot','<a href="http://www.tutorgig.info/" title="TutorGigBot home page [new window]" target="_blank">TutorGigBot</a>',
'twiceler','<a href="http://www.cuill.com/twiceler/robot.html" title="Twiceler home page [new window]" target="_blank">twiceler</a>',
'ubicrawler','<a href="http://law.dsi.unimi.it/ubicrawler/" title="Bot home page [new window]" target="_blank">UbiCrawler</a>',
'ultraseek', 'Ultraseek',
'unchaos_bot_hybrid_web_search_engine','<a href="http://www.unchaos.com/" title="UnChaos Bot Hybrid Web Search Engine home page [new window]" target="_blank">UnChaos Bot Hybrid Web Search Engine</a>',
'unido\-bot','<a href="http://www.unchina.org/unido/unido/our_projects/3_3.html" title="unido-bot home page [new window]" target="_blank">unido-bot</a>',
'unisterbot', 'UnisterBot; E-Mail only: crawler (at) unister.de',
'updated','<a href="http://www.updated.com/" title="updated home page [new window]" target="_blank">updated</a>',
'ustc\-semantic\-group','<a href="http://ai.ustc.edu.cn/mas/en/research/index.php" title="Bot home page [new window]" target="_blank">USTC-Semantic-Group</a>',
'vagabondo\-wap','<a href="http://www.wise-guys.nl/Contact/index.php?botselected=webagents&amp;lang=uk" title="Bot home page [new window]" target="_blank">Vagabondo-WAP</a>',
'vagabondo','<a href="http://www.wise-guys.nl/Contact/index.php?botselected=webagents&amp;lang=uk" title="Bot home page [new window]" target="_blank">Vagabondo</a>',
'vermut','<a href="http://vermut.aol.com/" title="Bot home page [new window]" target="_blank">Vermut</a>',
'versus_crawler_from_eda\.baykan@epfl\.ch','<a href="http://www.epfl.ch/Eindex.html  " title="versus crawler from eda.baykan@epfl.ch home page [new window]" target="_blank">versus crawler from eda.baykan@epfl.ch</a>',
'vespa_crawler','<a href="http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&template=detail.html&match=%5Cbid_t_z_030406_1%5Cb" title="Bot home page [new window]" target="_blank">Vespa Crawler</a>',
'vortex','<a href="http://marty.anstey.ca/projects/robots/vortex/" title="Bot home page [new window]" target="_blank">VORTEX</a>',
'vse\/','<a href="http://www.vivisimo.com/" title="VSE home page [new window]" target="_blank">VSE</a>',
'w3c\-checklink','<a href="http://validator.w3.org/checklink/" title="Bot home page [new window]" target="_blank">W3C Link Checker</a>',
'w3c[_+ ]css[_+ ]validator[_+ ]jfouffa', '<a href="http://jigsaw.w3.org/css-validator/" title="Bot home page [new window]" target="_blank">W3C jigsaw CSS Validator</a>',
'w3c_validator','<a href="http://validator.w3.org/" title="Bot home page [new window]" target="_blank">W3C Validator</a>',
'watchmouse', '<a href="http://www.watchmouse.com/en/" title="WatcMouse">WatchMouse Website Monitor</a>',
'wavefire','<a href="http://www.wavefire.com" title="info@wavefire.com; Bot home page [new window]" target="_blank">Wavefire</a>',
'waybackarchive\.org', '<span title="Maybe related to spiderlytics.">No website, email: spider(at)waybackarchive.org</span>',
# 2.12.2013 Project Honeypot reports at least one of the IPs used by waybackarchive with a spiderlytics UA string.
# Problably not related to the wayback machine of archive.org.
'webclipping\.com', 'WebClipping.com',
'webcompass', 'webcompass',
'webcrawl\.net','<a href="http://www.webcrawl.net/" title="webcrawl.net home page [new window]" target="_blank">webcrawl.net</a>',
'web_downloader','<a href="http://www.krasu.ru/soft/chuchelo/" title="Web Downloader home page [new window]" target="_blank">Web Downloader</a>',
'webdup','<a href="http://www.webdup.com/en/index.html" title="Webdup home page [new window]" target="_blank">Webdup</a>',
'webfilter','<a href="http://www.verso.com/enterprise/netspective/webfilter.asp" title="Bot home page [new window]" target="_blank">WebFilter</a>',
'webindexer','<a href="mailto://webindexerv1@yahoo.com" title="WebIndexer home page [new window]" target="_blank">WebIndexer</a>',
'webminer','<a href="http://64.124.122.252/feedback.html" title="WebMiner home page [new window]" target="_blank">WebMiner</a>',
'website[_+ ]monitoring[_+ ]bot','<a href="http://InternetSupervision.com/UrlMonitor/3/" title="Website_Monitoring_Bot home page [new window]" target="_blank">Website_Monitoring_Bot</a>',
'webvulncrawl', 'WebVulnCrawl',
'wells_search','<a href="http://www.psychedelix.com/cgi-bin/csv2html.pl?data=allagents.csv&amp;template=detail.html&amp;match=\bid_t_z_1484\b " title="Wells Search home page [new window]" target="_blank">Wells Search</a>',
'wesee:search', '<a href="http://www.wesee.com/en/support/bot/" title="WeSEE Bot Home Page (gave a 404-Error on Nov. 2, 2013) [new window]" target="_blank">WeSEE Bot</a>',
'wonderer', 'Web Wombat Redback Spider',
'wume_crawler','<a href="http://wume.cse.lehigh.edu/~xiq204/crawler/ " title="wume crawler home page [new window]" target="_blank">wume crawler</a>',
'wwweasel',,'<a href="http://wwweasel.de/" title="Website_Monitoring_Bot home page [new window]" target="_blank">WWWeasel</a>',
'xenu\'s_link_sleuth','<a href="http://home.snafu.de/tilman/xenulink.html" title="Xenu Link Sleuth home page [new window]" target="_blank">Xenu Link Sleuth</a>',
'xenu_link_sleuth','<a href="http://home.snafu.de/tilman/xenulink.html" title="Xenu Link Sleuth home page [new window]" target="_blank">Xenu Link Sleuth</a>',
'xirq','<a href="http://www.xirq.com/" title="xirq home page [new window]" target="_blank">xirq</a>',
'y!j', '<a href="http://help.yahoo.co.jp/help/jp/search/indexing/indexing-15.html" title="Bot home page [new window]" target="_blank">Y!J Yahoo Japan</a>',
'yacy','<a href="http://www.yacy.net/yacy" title="Bot home page [new window]" target="_blank">yacy</a>',
'yahoo\-blogs','<a href="http://help.yahoo.com/help/us/ysearch/crawling/crawling-02.html" title="Bot home page [new window]" target="_blank">Yahoo-Blogs</a>',
'yahoo\-verticalcrawler', 'Yahoo Vertical Crawler',
'yahoofeedseeker', '<a href="http://publisher.yahoo.com/rssguide" title="Bot home page [new window]" target="_blank">Yahoo Feed Seeker</a>',
'yahooseeker\-testing', '<a href="http://search.yahoo.com/" title="Bot home page [new window]" target="_blank">YahooSeeker-Testing</a>',
'yahooseeker', '<a href="http://help.yahoo.com/help/us/ysearch/crawling/crawling-02.html" title="Bot home page [new window]" target="_blank">YahooSeeker Yahoo! Blog crawler</a>',
'yahoo\-mmcrawler', '<a href="mailto:mms-mmcrawler-support@yahoo-inc.com?subject=Yahoo-MMCrawler Information" title="E-mail Bot">Yahoo-MMCrawler</a>',
'yahoo!_mindset','<a href="http://mindset.research.yahoo.com/" title="Bot home page [new window]">Yahoo! Mindset</a>',
'yandex', '<a href="http://yandex.com/bots" title="Bot home page [new window]">Yandex Bot</a>',
'flexum', 'Flexum Search Engine',
'yanga', 'Yanga WorldSearch Bot',
'yet-another-spider','<a href="http://188.40.112.195/" title="Yet-Another-Spider home page [new window]" target="_blank">Yet-Another-Spider</a>',
'yooglifetchagent','<a href="http://www.yoogli.com/" title="yoogliFetchAgent home page [new window]" target="_blank">yoogliFetchAgent</a>',
'z\-add_link_checker','<a href="http://w3.z-add.co.uk/linkcheck/" title="Z-Add Link Checker home page [new window]" target="_blank">Z-Add Link Checker</a>',
'zealbot','ZealBot',
'zhuaxia','<a href="http://www.zhuaxia.com/"  target="_blank">ZhuaXia</a>',
'zspider','<a href="http://feedback.redkolibri.com/" title="Bot home page [new window]" target="_blank">zspider</a>',
'zeus','<a href="http://www.webmasterworld.com/forum11/1840.htm" title="Bot documentation [new window]" target="_blank">Zeus Webster Pro</a>',
'zumbot','<a href="http://help.zum.com/inquiry" title="ZumBot home page [new window]" target="_blank">ZumBot</a>',
'ng\/1\.','<a href="http://www.exabot.com/" title="Bot home page [new window]" target="_blank">NG 1.x (Exalead)</a>', # put at end to avoid false positive
'ng\/2\.','<a href="http://www.exabot.com/" title="Bot home page [new window]" target="_blank">NG 2.x (Exalead)</a>', # put at end to avoid false positive
'exabot','<a href="http://www.exabot.com/" title="Bot home page [new window]" target="_blank">Exabot</a>', # put at end to avoid false positive
# Other id that are 99% of robots
'wget','WGet tools',
'libwww','Perl tool',
'^java\/[0-9]','<a href="http://www.projecthoneypot.org/harvester_useragents.php" title="Bot home page [new window]" target="_blank">Java (Often spam bot)</a>', # put at end to avoid false positive
# Generic robot
'robot', 'Unknown robot (identified by \'robot\')',
'checker', 'Unknown robot (identified by \'checker\')',
'crawl', 'Unknown robot (identified by \'crawl\')',
'discovery', 'Unknown robot (identified by \'discovery\')',
'hunter', 'Unknown robot (identified by \'hunter\')',
'scanner', 'Unknown robot (identified by \'scanner\')',
'spider', 'Unknown robot (identified by \'spider\')',
'sucker', 'Unknown robot (identified by \'sucker\')',
'bot[\s_+:,\.\;\/\\\-]','Unknown robot (identified by \'bot\' followed by a space or one of the following characters _+:,.;/\-)',
'[\s_+:,\.\;\/\\\-]bot','Unknown robot (identified by \'bot\' preceded by a space or one of the following characters _+:,.;/\-)',
'curl', 'Common *nix tool for automating web document retireval. Most likely a bot.',
'php', 'A PHP script',
'ruby\/', 'Ruby script',
# Additional bots found by Sussex.
'^[1-3]$', 'Generic bot identified as "1", "2" or "3"',
'alltop', 'alltop',
'applesyndication', 'applesyndication',
'asynchttpclient', 'asynchttpclient',
'bingbot', '<a href="http://www.bing.com/bingbot.htm" title="Bing home page [new window]" target="_blank">Bingbot</a>',
'blogged_crawl', 'blogged_crawl',
'bloglovin', 'bloglovin',
'butterfly', 'butterfly',
'buzztracker', 'buzztracker',
'carpathia', 'carpathia',
'catbot', 'catbot',
'chattertrap', 'chattertrap',
'check_http', 'check_http (nagios)',
'coldfusion', 'coldfusion',
'covario', 'covario',
'daylifefeedfetcher', 'daylifefeedfetcher',
'discobot', 'discobot',
'dlvr\.it', 'dlvr.it',
'dreamwidth', 'dreamwidth',
'drupal', 'Drupal Site',
'ezoom', 'ezoom',
'feedmyinbox', 'feedmyinbox',
'feedroll\.com', 'feedroll.com',
'feedzira', 'feedzira',
'fever\/', '<a href="http://feedafever.com">Feed a Fever</a>',
'freenews', 'freenews',
'geohasher', 'geohasher',
'hanrss', 'hanrss',
'inagist', 'inagist',
'jacobin club', 'jacobin club',
'jakarta', 'jakarta',
'js\-kit', 'js-kit',
'largesmall crawler', 'largesmall crawler',
'linkedinbot', 'linkedinbot',
'longurl', 'longurl',
'metauri', 'metauri',
'microsoft\-webdav\-miniredir', 'microsoft-webdav-miniredir',
'^motorola$', 'Suspected Bot masquerading as "Motorola"',
'movabletype', 'movabletype',
'^mozilla\/3\.0 \(compatible$', 'Suspected bot masqurading as Mozilla',
'^mozilla\/4\.0$', 'Suspected bot masqurading as Mozilla',
'^mozilla\/4\.0 \(compatible;\)$', 'Suspected bot masqurading as Mozilla',
'^mozilla\/5\.0$', 'Suspected bot masqurading as Mozilla',
'^mozilla\/5\.0 \(compatible;$', 'Suspected bot masqurading as Mozilla',
'^mozilla\/5\.0 \(en\-us\)$', 'Suspected bot masqurading as Mozilla',
'^mozilla\/5\.0 firefox\/3\.0\.5$', 'Suspected bot masqurading as Mozilla',
'^msie', 'Suspected bot masquerading as M$ IE',
'netnewswire', 'netnewswire',
' netseer ', '<a href="http://www.netseer.com/crawler.html">Net Seer</a>',
'netvibes', 'netvibes',
'newrelicpinger', 'newrelicpinger',
'newsfox', 'Fox News',
'nextgensearchbot', 'nextgensearchbot',
'ning', 'ning',
'pingdom', 'pingdom',
'pita', 'pita (pain in the ass?)',
'postpost', 'postpost',
'postrank', 'postrank',
'printfulbot', 'printfulbot',
'protopage', 'protopage',
'proximic', '<a href="http://www.proximic.com/info/spider.php" title="Proximic Spider home page [new window]" target="_blank">Proximic Spider</a>',
'quipply', 'quipply',
'r6\_', '<a href="http://www.radian6.com/crawler">Radian 6 Crawler</a>',
'ratingburner', 'ratingburner',
'regator', 'regator',
'rome client', 'rome client',
'rpt\-httpclient', 'rpt-httpclient',
'rssgraffiti', 'rssgraffiti',
'sage\+\+', 'sage++',
'scoutjet', '<a href="http://wwww.scoutjet.com/" target="_blank">ScoutJet</a> crawler for <a href="http://blekko.com/" target="_blank">Blekko</a>.',
'simplepie', 'simplepie',
'sitebot', 'sitebot',
'summify\.com', '<a href="http://summify.com/">summify.com</a>',
'superfeedr', 'superfeedr',
'synthesio', 'synthesio',
'teoma', 'teoma',
'topblogsinfo', 'topblogsinfo',
'topix\.net', 'topix.net',
'trapit', 'trapit',
'trileet', 'trileet',
'tweetedtimes', '<a href="http://tweetedtimes.com">The Tweeted Times</a>',
'twisted pagegetter', 'twisted pagegetter',
'twitterbot', 'twitterbot',
'twitterfeed', 'twitterfeed',
'unwindfetchor', 'unwindfetchor',
'wazzup', 'wazzup',
'windows\-rss\-platform', 'windows-rss-platform',
'wiumi', 'wiumi',
'xydo', 'xydo',
'yahoo! slurp', 'Additional Yahoo bots.',
'yahoo pipes', 'Additional Yahoo bots.',
'yahoo\-newscrawler', 'Additional Yahoo bots.',
'yahoocachesystem', 'Additional Yahoo bots.',
'yahooexternalcache', 'Additional Yahoo bots.',
'yahoo! searchmonkey', 'Additional Yahoo bots.',
'yahooysmcm', 'Additional Yahoo bots.',
'yammer', 'yammer',
#'yandexbot', 'yandexbot', #already covered by 'yandex'
'yeti', 'yeti',
'yie8', 'yie8',
'youdao', 'youdao',
'yourls', 'yourls',
'zemanta', 'zemanta',
'zend_http_client', 'Zend Http Client',
'no_user_agent','Unknown robot (identified by empty user agent string)',
# Unknown robots identified by hit on robots.txt
'unknown', 'Unknown robot (identified by hit on \'robots.txt\')'
);


# RobotsAffiliateLib
# This list try to tell by which Search Engine a robot is used
#-------------------------------------------------------------
%RobotsAffiliateLib = (
'bingpreview'=>'Bing',
'fast\-webcrawler'=>'AllTheWeb',
'googlebot'=>'Google',
'google\-sitemap'=>'Google',
'google[_+ ]web[_+ ]preview'=>'Google',
'msnbot'=>'MSN',
'nutch'=>'Looksmart',
'scooter'=>'AltaVista',
'wisenutbot'=>'Looksmart',
'yahoo\-blogs'=>'Yahoo',
'yahoo\-verticalcrawler'=>'Yahoo',
'yahoofeedseeker'=>'Yahoo',
'yahooseeker\-testing'=>'Yahoo',
'yahooseeker'=>'Yahoo',
'yahoo\-mmcrawler'=>'Yahoo',
'yahoo!_mindset'=>'Yahoo',
'zyborg'=>'Looksmart',
'cfetch'=>'Kosmix',
'^voyager\/'=>'Kosmix',
# Additional bots found by Sussex.
'feedfetcher\-google'=>'Google',
'bingbot'=>'MSN',
'twitterbot'=>'Twitter',
'twitterfeed'=>'Twitter',
'yahoo! slurp'=>'Yahoo',
'yahoo pipes'=>'Yahoo',
'yahoo-newscrawler'=>'Yahoo',
'yahoocachesystem'=>'Yahoo',
'yahooexternalcache'=>'Yahoo',
'yahoo! searchmonkey'=>'Yahoo',
'yahooysmcm'=>'Yahoo'
);

1;
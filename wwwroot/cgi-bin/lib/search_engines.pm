# AWSTATS SEARCH ENGINES DATABASE
#-------------------------------------------------------
# If you want to add a Search Engine to extend AWStats database detection capabilities,
# you must add an entry in SearchEnginesSearchIDOrder and in SearchEnginesHashIDLib.
# An entry if known in SearchEnginesKnownUrl is also welcome.
#-------------------------------------------------------
# $Revision$ - $Author$ - $Date$


#package AWSSE;


# SearchEnginesSearchIDOrder
# This list is used to know in which order to search Search Engines IDs (Most
# frequent one are first in this list to increase detect speed).
# Note: Browsers IDs are in lower case and ' ' and '+' are changed into '_'
#-----------------------------------------------------------------
@SearchEnginesSearchIDOrder=(
# Major internationnal search engines
"images\.google\.",
"google\.",	# TODO Add 216\.239\.35\.101|216\.239\.37\.101|216\.239\.39\.100|216\.239\.39\.101|216\.239\.51\.100|216\.239\.51\.101|216\.239\.35\.100
"msn\.",
"voila\.",
"yahoo\.",
"lycos\.",
"altavista\.",
"search\.terra\.",
"alltheweb\.com",
"netscape\.",
"dmoz\.org",
"www\.search\.com",
"tiscali\.",
"search\.aol\.co",
# Minor internationnal search engines
"northernlight\.",
"hotbot\.",
"kvasir\.",
"webcrawler\.",
"metacrawler\.",
"go2net\.com",
"(^|\.)go\.com",
"euroseek\.",
"excite\.",
"looksmart\.",
"spray\.",
"nbci\.com/search",
"(^|\.)ask\.com",
"atomz\.",
"overture\.com",		# Replace "goto\.com","Goto.com",
"teoma\.",
"findarticles\.com",
"infospace\.com",
"mamma\.",
"dejanews\.",
"dogpile\.com",
"wisenut\.com", "ixquick.com",
"search\.earthlink\.net", 
"search\.sli\.sympatico\.ca", 
# Minor brazilian search engines
"engine\.exe", "miner\.bol\.com\.br",
# Minor chinese search engines
"baidu\.com","search\.sina\.com","search\.sohu\.com",
# Minor czech search engines
"atlas\.cz","seznam\.cz","quick\.cz","centrum\.cz","najdi\.to","redbox\.cz",
# Minor danish search-engines 
"opasia\.dk", "danielsen\.com", "sol\.dk", "jubii\.dk", "find\.dk", "edderkoppen\.dk", "netstjernen\.dk", "orbis\.dk", "tyfon\.dk", "1klik\.dk", "ofir\.dk",
# Minor dutch search engines
"ilse\.","vindex\.",
# Minor english search engines
"(^|\.)ask\.co\.uk","bbc\.co\.uk/cgi-bin/search","ifind\.freeserve","looksmart\.co\.uk","mirago\.","splut\.","spotjockey\.","ukdirectory\.","ukindex\.co\.uk","ukplus\.","searchy\.co\.uk",
# Minor finnish search engines
"haku\.www\.fi",
# Minor french search engines
"recherche\.aol\.fr","ctrouve\.","francite\.","\.lbb\.org","rechercher\.libertysurf\.fr", "search1-[12]\.free\.fr", "recherche\.club-internet\.fr",
# Minor german search engines
"fireball\.de","infoseek\.de","suche\.web\.de","meta\.ger",
"suchen\.abacho\.de","brisbane\.t-online\.de","allesklar\.de","meinestadt\.de",
# Minor hungarian search engines
"heureka\.hu","vizsla\.origo\.hu/katalogus?","vizsla\.origo\.hu","lapkereso\.hu","goliat\.hu","index\.hu","wahoo\.hu","freeweb\.hu","webmania\.hu","search\.internetto\.hu",
# Minor italian search engines
"virgilio\.it",
# Minor norvegian search engines
"sok\.start\.no",
# Minor polish search engines
"szukaj\.wp\.pl",
# Minor russian search engines
"yandex\.ru",
# Minor swedish search engines
"evreka\.passagen\.se",
# Minor swiss search engines
"search\.bluewin\.ch",
# Other
"search\..*com"
);

# SearchEnginesSearchIDOrder
# This list is used to know in which order to search Search Engines IDs (Most
# frequent one are first in this list to increase detect speed).
# Note: Browsers IDs are in lower case and ' ' and '+' are changed into '_'
#-----------------------------------------------------------------
@NotSearchEnginesSearchIDOrder=(
"hotmail.msn.com"
);


# SearchEnginesKnownUrl
# Known rules to extract keywords from a referrer search engine URL
#-------------------------------------------------
%SearchEnginesKnownUrl=(
# Most common search engines
"alltheweb\.com","q(|uery)=",
"altavista\.","q=",
"dmoz\.org","search=",
"google\.","(p|q)=",
"images\.google\.","(p|q)=",
"lycos\.","query=",
"msn\.","q=",
"netscape\.","search=",
"search\.aol\.co","query=",
"search\.terra\.","query=",
"voila\.","kw=",
"www\.search\.com","q=",
"yahoo\.","p=",
# Minor internationnal search engines
"(^|\.)go\.com","qt=",
"(^|\.)ask\.com","ask=",
"atomz\.","sp-q=",
"euroseek\.","query=",
"excite\.","search=",
"findarticles\.com","key=",
"go2net\.com","general=",
"hotbot\.","mt=",
"infospace\.com","qkw=",
"kvasir\.", "q=",
"looksmart\.","key=",
"mamma\.","query=",
"metacrawler\.","general=",
"nbci\.com/search","keyword=",
"northernlight\.","qr=",
"overture\.com","keywords=",
"dogpile\.com", "qkw=", "search\.dogpile\.com", "q=",
"spray\.","string=",
"teoma\.","q=",
"virgilio\.it","qs=",
"webcrawler","searchText=",
"wisenut\.com","query=", 
"ixquick\.com", "query=",
"search\.earthlink\.net", "q=",
"search\.sli\.sympatico\.ca", "query=", 
# Minor brazilian search engines
"engine\.exe","p1=", "miner\.bol\.com\.br","q=",
# Minor chinese search engines
"baidu\.com","word=", "search\.sina\.com", "word=", "search\.sohu\.com","word=",
# Minor czech search engines
"atlas\.cz","searchtext=", "seznam\.cz","w=", "ftxt\.quick\.cz","query=", "centrum\.cz","q=", "najdi\.to","dotaz=", "redbox.cz","srch=",
# Minor danish search engines
"opasia\.dk","q=", "danielsen\.com","q=", "sol\.dk","q=", "jubii\.dk","soegeord=", "find\.dk","words=", "edderkoppen\.dk","query=", "orbis\.dk","search_field=", "1klik\.dk","query=", "ofir\.dk","querytext=",
# Minor dutch search engines
"ilse\.","search_for=", "vindex\.","in=",
# Minor english search engines
"(^|\.)ask\.co\.uk","ask=", "bbc\.co\.uk/cgi-bin/search","q=", "ifind\.freeserve","q=", "looksmart\.co\.uk","key=",
"mirago\.","txtsearch=", "splut\.","pattern=", "spotjockey\.","Search_Keyword=", "ukindex\.co\.uk", "stext=", "ukdirectory\.","k=", "ukplus\.","search=", "searchy\.co\.uk", "search_term=",
"ukindex\.co\.uk", "stext=", "ukdirectory\.","k=",
# Minor finnish search engines
"haku\.www\.fi","w=",
# Minor french search engines
"nomade\.fr/","s=", "francite\.","name=", "recherche\.club-internet\.fr", "q=",
# Minor german search engines
"fireball\.de","q=", "infoseek\.de","qt=", "suche\.web\.de","su=",
"suchen\.abacho\.de","q=", "brisbane\.t-online\.de","q=", 
# Minor hungarian search engines
"heureka\.hu","heureka=", "vizsla\.origo\.hu/katalogus?","q=", "vizsla\.origo\.hu","search=", "lapkereso\.hu","keres.php", "goliat\.hu","KERESES=", "index\.hu","search.php3", "wahoo\.hu","q=", "freeweb\.hu","KERESES=", "search\.internetto\.hu","searchstr=",
# Minor norvegian search engines
"sok\.start\.no","q=",
# Minor polish search engines
"szukaj\.wp\.pl","szukaj=",
# Minor russian search engines
"yandex\.ru","text=",
# Minor swedish search engines
"evreka\.passagen\.se","q=",
# Minor swiss search engines
"search\.bluewin\.ch","qry=",
);

# SearchEnginesKnownUrlNotFound
# Known rules to extract not found keywords from a referrer search engine URL
#-------------------------------------------------
%SearchEnginesKnownUrlNotFound=(
# Most common search engines
"msn\.","origq="
);

# If no rules are known, this will be used to search keyword parameter
@WordsToExtractSearchUrl= ("ask=","claus=","general=","key=","kw=","keyword=","keywords=","MT=","p=","q=","qr=","qt=","query=","s=","search=","searchText=","string=","su=","txtsearch=","w=");

# If no rules are known and search in WordsToExtractSearchUrl failed, this will be used to clean URL of not keyword parameters.
@WordsToCleanSearchUrl= ("act=","annuaire=","btng=","cat=","categoria=","cfg=","cof=","cou=","count=","cp=","dd=","domain=","dt=","dw=","enc=","exec=","geo=","hc=","height=","hits=","hl=","hq=","hs=","id=","kl=","lang=","loc=","lr=","matchmode=","medor=","message=","meta=","mode=","order=","page=","par=","pays=","pg=","pos=","prg=","qc=","refer=","sa=","safe=","sc=","sort=","src=","start=","style=","stype=","sum=","tag=","temp=","theme=","type=","url=","user=","width=","what=","\\.x=","\\.y=","y=","look=");



# SearchEnginesHashIDLib
# List of search engines names
# "match_string_in_url_that_identify_engine", "search_engine_name",
#-----------------------------------------------------------------
%SearchEnginesHashIDLib=(
# Major internationnal search engines
"alltheweb\.com","AllTheWeb",
"altavista\.","AltaVista",
"dmoz\.org","DMOZ",
"google\.","Google",
"images\.google\.","Google (Images)",
"lycos\.","Lycos",
"msn\.","MSN",
"netscape\.","Netscape",
"search\.aol\.co","AOL",
"search\.terra\.","Terra",
"tiscali\.","Tiscali",
"voila\.", "Voila",
"www\.search\.com","Search.com",
"yahoo\.","Yahoo",
# Minor internationnal search engines
"(^|\.)go\.com","Go.com",
"(^|\.)ask\.com","Ask Jeeves",
"atomz\.","Atomz",
"dejanews\.","DejaNews",
"euroseek\.","Euroseek",
"excite\.","Excite",
"findarticles\.com","Find Articles",
"go2net\.com","Go2Net (Metamoteur)",
"hotbot\.","Hotbot",
"infospace\.com","InfoSpace",
"kvasir\.","Kvasir",
"looksmart\.","Looksmart",
"mamma\.","Mamma",
"metacrawler\.","MetaCrawler (Metamoteur)",
"nbci\.com/search","NBCI",
"northernlight\.","NorthernLight",
"overture\.com","Overture",                 # Replace "goto\.com","Goto.com",
"dogpile\.com","Dogpile",
"spray\.","Spray",
"teoma\.","Teoma",							# Replace "directhit\.com","DirectHit",
"webcrawler\.","WebCrawler",
"wisenut\.com","WISENut", 
"ixquick\.com", "ix quick", 
"search\.earthlink\.net", "Earth Link",
"search\.sli\.sympatico\.ca", "Sympatico",
# Minor brazilian search engines
"engine\.exe","Cade", "miner\.bol\.com\.br","Meta Miner",
# Minor chinese search engines
"baidu\.com","Baidu", "search\.sina\.com","Sina", "search\.sohu\.com","Sohu",
# Minor czech search engines
"atlas\.cz","Atlas.cz",	"seznam\.cz","Seznam.cz", "quick\.cz","Quick.cz", "centrum\.cz","Centrum.cz","najdi\.to","Najdi.to","redbox\.cz","RedBox.cz",
# Minor danish search-engines
"opasia\.dk","Opasia", "danielsen\.com","Thor (danielsen.com)", "sol\.dk","SOL", "jubii\.dk","Jubii", "find\.dk","Find", "edderkoppen\.dk","Edderkoppen", "netstjernen\.dk","Netstjernen", "orbis\.dk","Orbis", "tyfon\.dk","Tyfon", "1klik\.dk","1Klik", "ofir\.dk","Ofir",
# Minor dutch search engines
"ilse\.","Ilse","vindex\.","Vindex\.nl",						
# Minor english search engines
"(^|\.)ask\.co\.uk","Ask Jeeves UK", "bbc\.co\.uk/cgi-bin/search","BBC", "ifind\.freeserve","Freeserve", "looksmart\.co\.uk","Looksmart UK",
"mirago\.","Mirago", "splut\.","Splut", "spotjockey\.","Spotjockey", "ukdirectory\.","UK Directory", "ukindex\.co\.uk","UKIndex", "ukplus\.","UK Plus", "searchy\.co\.uk","searchy.co.uk",
# Minor finnish search engines
"haku\.www\.fi","Ihmemaa",										
# Minor french search engines
"recherche\.aol\.fr","AOL", "ctrouve\.","C'est trouvé", "francite\.","Francité", "\.lbb\.org", "LBB", "rechercher\.libertysurf\.fr", "Libertysurf", "search1-2\.free\.fr", "free.fr", "recherche\.club-internet\.fr", "Club-internet",
# Minor german search engines
"fireball\.de","Fireball", "infoseek\.de","Infoseek", "suche\.web\.de","Web.de", "meta\.ger","MetaGer",	
"suchen\.abacho\.de","Abacho", "brisbane\.t-online\.de","T-Online", 
"allesklar\.de","allesklar.de", "meinestadt\.de","meinestadt.de", 
# Minor hungarian search engines
"heureka\.hu","Heureka", "vizsla\.origo\.hu/katalogus?","Origo-Vizsla-Katalógus", "vizsla\.origo\.hu","Origo-Vizsla", "lapkereso\.hu","Startlapkeresõ", "goliat\.hu","Góliát", "index\.hu","Index", "wahoo\.hu","Wahoo", "freeweb\.hu","FreeWeb", "webmania\.hu","webmania.hu", "search\.internetto\.hu","Internetto Keresõ",
# Minor italian search engines
"virgilio\.it","Virgilio",										
# Minor norvegian search engines
"sok\.start\.no","start.no",								
# Minor polish search engines
"szukaj\.wp\.pl","Szukaj",
# Minor russian search engines
"yandex\.ru","Yandex",
# Minor swedish search engines
"evreka\.passagen\.se","Evreka",
# Minor Swiss search engines
"search.bluewin.ch","Bluewin",
# Other
"search\..*com","Other search engines"
);


1;

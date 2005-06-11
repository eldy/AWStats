# AWSTATS SEARCH ENGINES DATABASE
#------------------------------------------------------------------------------
# If you want to add a Search Engine to extend AWStats database detection capabilities,
# you must add an entry in SearchEnginesSearchIDOrder, SearchEnginesHashID and in
# SearchEnginesHashLib.
# An entry if known in SearchEnginesKnownUrl is also welcome.
#------------------------------------------------------------------------------
# $Revision$ - $Author$ - $Date$


#package AWSSE;


# SearchEnginesSearchIDOrder
# It contains all matching criteria to search for in log fields. This list is
# used to know in which order to search Search Engines IDs.
# Most frequent one are in list1, used when LevelForSearchEnginesDetection is 1 or more
# Minor robots are in list2, used when LevelForSearchEnginesDetection is 2 or more
# Note: Regex IDs are in lower case and ' ' and '+' are changed into '_'
#------------------------------------------------------------------------------
@SearchEnginesSearchIDOrder_list1=(
# Major internationnal search engines
'images\.google\.',
'google\.','216\.239\.(35\.101|37\.101|39\.100|39\.101|51\.100|51\.101|35\.100)',
'msn\.',
'voila\.',
'yahoo\.','(66\.218\.71\.225|216\.109\.117\.135)',
'search\.aol\.co',
'tiscali\.',
'lycos\.',
'alexa\.com',
'alltheweb\.com',
'altavista\.',
'a9\.com',
'dmoz\.org',
'netscape\.',
'search\.terra\.',
'www\.search\.com',
'search\.sli\.sympatico\.ca', 
'excite\.'
);

@SearchEnginesSearchIDOrder_list2=(
# Minor internationnal search engines
'northernlight\.',
'hotbot\.',
'kvasir\.',
'webcrawler\.',
'metacrawler\.',
'go2net\.com',
'(^|\.)go\.com',
'euroseek\.',
'looksmart\.',
'spray\.',
'nbci\.com/search',
'(^|\.)ask\.com',
'atomz\.',
'overture\.com',		# Replace 'goto\.com','Goto.com',
'teoma\.',
'findarticles\.com',
'infospace\.com',
'mamma\.',
'dejanews\.',
'dogpile\.com',
'wisenut\.com',
'ixquick\.com',
'search\.earthlink\.net', 
'i-une\.com',
# Minor brazilian search engines
'engine\.exe', 'miner\.bol\.com\.br',
# Minor chinese search engines
'baidu\.com','search\.sina\.com','search\.sohu\.com',
# Minor czech search engines
'atlas\.cz','seznam\.cz','quick\.cz','centrum\.cz','jyxo\.(cz|com)','najdi\.to','redbox\.cz',
# Minor danish search-engines 
'opasia\.dk', 'danielsen\.com', 'sol\.dk', 'jubii\.dk', 'find\.dk', 'edderkoppen\.dk', 'netstjernen\.dk', 'orbis\.dk', 'tyfon\.dk', '1klik\.dk', 'ofir\.dk',
# Minor dutch search engines
'ilse\.','vindex\.',
# Minor english search engines
'(^|\.)ask\.co\.uk','bbc\.co\.uk/cgi-bin/search','ifind\.freeserve','looksmart\.co\.uk','mirago\.','splut\.','spotjockey\.','ukdirectory\.','ukindex\.co\.uk','ukplus\.','searchy\.co\.uk',
# Minor finnish search engines
'haku\.www\.fi',
# Minor french search engines
'recherche\.aol\.fr','ctrouve\.','francite\.','\.lbb\.org','rechercher\.libertysurf\.fr', 'search[\w\-]+\.free\.fr', 'recherche\.club-internet\.fr',
# Minor german search engines
'sucheaol\.aol\.de',
'fireball\.de','infoseek\.de','suche\d?\.web\.de','[a-z]serv\.rrzn\.uni-hannover\.de',
'suchen\.abacho\.de','brisbane\.t-online\.de','allesklar\.de','meinestadt\.de',
'212\.227\.33\.241',
'(161\.58\.227\.204|161\.58\.247\.101|212\.40\.165\.90|213\.133\.108\.202|217\.160\.108\.151|217\.160\.111\.99|217\.160\.131\.108|217\.160\.142\.227|217\.160\.176\.42)',
# Minor hungarian search engines
'heureka\.hu','vizsla\.origo\.hu','lapkereso\.hu','goliat\.hu','index\.hu','wahoo\.hu','webmania\.hu','search\.internetto\.hu',
# Minor italian search engines
'virgilio\.it',
# Minor norvegian search engines
'sok\.start\.no',
# Minor polish search engines
'szukaj\.wp\.pl',
# Minor russian search engines
'ya(ndex)?\.ru', 'aport\.ru', 'rambler\.ru', 'turtle\.ru', 'metabot\.ru',
# Minor swedish search engines
'evreka\.passagen\.se',
# Minor swiss search engines
'search\.ch', 'search\.bluewin\.ch'
);
@SearchEnginesSearchIDOrder_listgen=(
# Generic search engines
'search\..*\.\w+'
);


# NotSearchEnginesKeys
# If a search engie key is found, we check its exclude list to know if it's
# really a search engine
#------------------------------------------------------------------------------
%NotSearchEnginesKeys=(
'msn\.'=>'hotmail\.msn\.',
'yahoo\.'=>'mail\.yahoo\.'
);


# SearchEnginesHashID
# Each Search Engine Search ID is associated to an AWStats id string
#------------------------------------------------------------------------------
%SearchEnginesHashID = (
# Major internationnal search engines
'images\.google\.','google_image',
'google\.','google','216\.239\.(35\.101|37\.101|39\.100|39\.101|51\.100|51\.101|35\.100)','google',
'msn\.','msn',
'voila\.','voila',
'yahoo\.','yahoo','(66\.218\.71\.225|216\.109\.117\.135)','yahoo',
'lycos\.','lycos',
'alexa\.com','alexa',
'alltheweb\.com','alltheweb',
'altavista\.','altavista',
'a9\.com','a9',
'dmoz\.org','dmoz',
'netscape\.','netscape',
'search\.terra\.','terra',
'www\.search\.com','search.com',
'tiscali\.','tiscali',
'search\.aol\.co','aol',
'search\.sli\.sympatico\.ca','sympatico',
'excite\.','excite',
# Minor internationnal search engines
'northernlight\.','northernlight',
'hotbot\.','hotbot',
'kvasir\.','kvasir',
'webcrawler\.','webcrawler',
'metacrawler\.','metacrawler',
'go2net\.com','go2net',
'(^|\.)go\.com','go',
'euroseek\.','euroseek',
'looksmart\.','looksmart',
'spray\.','spray',
'nbci\.com/search','nbci',
'(^|\.)ask\.com','ask',
'atomz\.','atomz',
'overture\.com','overture',		# Replace 'goto\.com','Goto.com',
'teoma\.','teoma',
'findarticles\.com','findarticles',
'infospace\.com','infospace',
'mamma\.','mamma',
'dejanews\.','dejanews',
'dogpile\.com','dogpile',
'wisenut\.com','wisenut',
'ixquick\.com','ixquick',
'search\.earthlink\.net','earthlink',
'i-une\.com','iune',
# Minor brazilian search engines
'engine\.exe','engine',
'miner\.bol\.com\.br','miner',
# Minor chinese search engines
'baidu\.com','baidu',
'search\.sina\.com','sina',
'search\.sohu\.com','sohu',
# Minor czech search engines
'atlas\.cz','atlas',
'seznam\.cz','seznam',
'quick\.cz','quick',
'centrum\.cz','centrum',
'jyxo\.(cz|com)','jyxo',
'najdi\.to','najdi',
'redbox\.cz','redbox',
# Minor danish search-engines 
'opasia\.dk','opasia',
'danielsen\.com','danielsen',
'sol\.dk','sol',
'jubii\.dk','jubii',
'find\.dk','finddk',
'edderkoppen\.dk','edderkoppen',
'netstjernen\.dk','netstjernen',
'orbis\.dk','orbis',
'tyfon\.dk','tyfon',
'1klik\.dk','1klik',
'ofir\.dk','ofir',
# Minor dutch search engines
'ilse\.','ilse',
'vindex\.','vindex',
# Minor english search engines
'(^|\.)ask\.co\.uk','askuk',
'bbc\.co\.uk/cgi-bin/search','bbc',
'ifind\.freeserve','freeserve',
'looksmart\.co\.uk','looksmartuk',
'mirago\.','mirago',
'splut\.','splut',
'spotjockey\.','spotjockey',
'ukdirectory\.','ukdirectory',
'ukindex\.co\.uk','ukindex',
'ukplus\.','ukplus',
'searchy\.co\.uk','searchy',
# Minor finnish search engines
'haku\.www\.fi','haku',
# Minor french search engines
'recherche\.aol\.fr','aolfr',
'ctrouve\.','ctrouve',
'francite\.','francite',
'\.lbb\.org','lbb',
'rechercher\.libertysurf\.fr','libertysurf',
'search[\w\-]+\.free\.fr','free',
'recherche\.club-internet\.fr','clubinternet',
# Minor german search engines
'sucheaol\.aol\.de','aolde',
'fireball\.de','fireball',
'infoseek\.de','infoseek',
'suche\d?\.web\.de','webde',
'[a-z]serv\.rrzn\.uni-hannover\.de','meta',
'suchen\.abacho\.de','abacho',
'brisbane\.t-online\.de','t-online',
'allesklar\.de','allesklar',
'meinestadt\.de','meinestadt',
'212\.227\.33\.241','metaspinner',
'(161\.58\.227\.204|161\.58\.247\.101|212\.40\.165\.90|213\.133\.108\.202|217\.160\.108\.151|217\.160\.111\.99|217\.160\.131\.108|217\.160\.142\.227|217\.160\.176\.42)','metacrawler_de',
# Minor hungarian search engines
'heureka\.hu','heureka',
'vizsla\.origo\.hu','origo',
'lapkereso\.hu','lapkereso',
'goliat\.hu','goliat',
'index\.hu','indexhu',
'wahoo\.hu','wahoo',
'webmania\.hu','webmania',
'search\.internetto\.hu','internetto',
# Minor italian search engines
'virgilio\.it','virgilio',
# Minor norvegian search engines
'sok\.start\.no','start',
# Minor polish search engines
'szukaj\.wp\.pl','wp',
# Minor russian search engines
'ya(ndex)?\.ru','yandex',
'aport\.ru','aport',
'rambler\.ru','rambler',
'turtle\.ru','turtle',
'metabot\.ru','metabot',
# Minor swedish search engines
'evreka\.passagen\.se','passagen',
# Minor swiss search engines
'search\.ch','searchch',
'search\.bluewin\.ch','bluewin',
# Generic search engines
'search\..*\.\w+','search'
);


# SearchEnginesWithKeysNotInQuery
# List of search engines that store keyword as page instead of query parameter
#------------------------------------------------------------------------------
%SearchEnginesWithKeysNotInQuery=(
'a9',1    # www.a9.com/searckey1%20searchkey2
);

# SearchEnginesKnownUrl
# Known rules to extract keywords from a referrer search engine URL
#------------------------------------------------------------------------------
%SearchEnginesKnownUrl=(
# Most common search engines
'alexa','q=',
'alltheweb','q(|uery)=',
'altavista','q=',
'a9','a9\.com\/', 
'dmoz','search=',
'google','(p|q|as_p|as_q)=',
'google_image','(p|q|as_p|as_q)=',
'lycos','query=',
'msn','q=',
'netscape','search=',
'aol','query=',
'terra','query=',
'voila','kw=',
'search.com','q=',
'yahoo','p=',
'sympatico', 'query=', 
'excite','search=',
# Minor internationnal search engines
'go','qt=',
'ask','ask=',
'atomz','sp-q=',
'euroseek','query=',
'findarticles','key=',
'go2net','general=',
'hotbot','mt=',
'infospace','qkw=',
'kvasir', 'q=',
'looksmart','key=',
'mamma','query=',
'metacrawler','general=',
'nbci','keyword=',
'northernlight','qr=',
'overture','keywords=',
'dogpile', 'q(|kw)=',
'spray','string=',
'teoma','q=',
'virgilio','qs=',
'webcrawler','searchText=',
'wisenut','query=', 
'ixquick', 'query=',
'earthlink', 'q=',
'iune','(keywords|q)=',
# Minor brazilian search engines
'engine','p1=', 'miner','q=',
# Minor chinese search engines
'baidu','word=', 'sina', 'word=', 'sohu','word=',
# Minor czech search engines
'atlas','searchtext=', 'seznam','w=', 'quick','query=', 'centrum','q=', 'jyxo','s=', 'najdi','dotaz=', 'redbox','srch=',
# Minor danish search engines
'opasia','q=', 'danielsen','q=', 'sol','q=', 'jubii','soegeord=', 'finddk','words=', 'edderkoppen','query=', 'orbis','search_field=', '1klik','query=', 'ofir','querytext=',
# Minor dutch search engines
'ilse','search_for=', 'vindex','in=',
# Minor english search engines
'askuk','ask=', 'bbc','q=', 'freeserve','q=', 'looksmart','key=',
'mirago','txtsearch=', 'splut','pattern=', 'spotjockey','Search_Keyword=', 'ukindex', 'stext=', 'ukdirectory','k=', 'ukplus','search=', 'searchy', 'search_term=',
# Minor finnish search engines
'haku','w=',
# Minor french search engines
'francite','name=', 'clubinternet', 'q=',
# Minor german search engines
'aolde','q=',
'fireball','q=', 'infoseek','qt=', 'webde','su=',
'abacho','q=', 't-online','q=', 
'metaspinner','qry=',
'metacrawler_de','qry=',
# Minor hungarian search engines
'heureka','heureka=', 'origo','(q|search)=', 'goliat','KERESES=', 'wahoo','q=', 'internetto','searchstr=',
# Minor norvegian search engines
'start','q=',
# Minor polish search engines
'wp','szukaj=',
# Minor russian search engines
'yandex', 'text=', 'rambler','words=', 'aport', 'r=', 'metabot', 'st=',
# Minor swedish search engines
'passagen','q=',
# Minor swiss search engines
'searchch', 'q=', 'bluewin', 'qry='
);

# SearchEnginesKnownUrlNotFound
# Known rules to extract not found keywords from a referrer search engine URL
#------------------------------------------------------------------------------
%SearchEnginesKnownUrlNotFound=(
# Most common search engines
'msn','origq='
);

# If no rules are known, WordsToExtractSearchUrl will be used to search keyword parameter
# If no rules are known and search in WordsToExtractSearchUrl failed, this will be used to clean URL of not keyword parameters.
#------------------------------------------------------------------------------
@WordsToExtractSearchUrl= ('ask=','claus=','general=','key=','kw=','keyword=','keywords=','MT=','p=','q=','qr=','qt=','query=','s=','search=','searchText=','string=','su=','txtsearch=','w=');
@WordsToCleanSearchUrl= ('act=','annuaire=','btng=','cat=','categoria=','cfg=','cof=','cou=','count=','cp=','dd=','domain=','dt=','dw=','enc=','exec=','geo=','hc=','height=','hits=','hl=','hq=','hs=','id=','kl=','lang=','loc=','lr=','matchmode=','medor=','message=','meta=','mode=','order=','page=','par=','pays=','pg=','pos=','prg=','qc=','refer=','sa=','safe=','sc=','sort=','src=','start=','style=','stype=','sum=','tag=','temp=','theme=','type=','url=','user=','width=','what=','\\.x=','\\.y=','y=','look=');

# SearchEnginesKnownUTFCoding
# Known param that proves a search engines has coded its param in UTF8
#------------------------------------------------------------------------------
%SearchEnginesKnownUTFCoding=(
# Most common search engines
'google','ie=utf-8',
'alltheweb','cs=utf-8'
);


# SearchEnginesHashLib
# List of search engines names
# 'search_engine_id', 'search_engine_name',
#------------------------------------------------------------------------------
%SearchEnginesHashLib=(
# Major internationnal search engines
'alexa','Alexa',
'alltheweb','AllTheWeb',
'altavista','AltaVista',
'a9', 'A9.com',
'dmoz','DMOZ',
'google','Google',
'google_image','Google (Images)',
'lycos','Lycos',
'msn','MSN',
'netscape','Netscape',
'aol','AOL',
'terra','Terra',
'tiscali','Tiscali',
'voila','Voila',
'search.com','Search.com',
'yahoo','Yahoo',
'sympatico', 'Sympatico',
'excite','Excite',
# Minor internationnal search engines
'go','Go.com',
'ask','Ask Jeeves',
'atomz','Atomz',
'dejanews','DejaNews',
'euroseek','Euroseek',
'findarticles','Find Articles',
'go2net','Go2Net (Metamoteur)',
'hotbot','Hotbot',
'infospace','InfoSpace',
'kvasir','Kvasir',
'looksmart','Looksmart',
'mamma','Mamma',
'metacrawler','MetaCrawler (Metamoteur)',
'nbci','NBCI',
'northernlight','NorthernLight',
'overture','Overture',                 # Replace 'goto\.com','Goto.com',
'dogpile','Dogpile',
'spray','Spray',
'teoma','Teoma',							# Replace 'directhit\.com','DirectHit',
'webcrawler','WebCrawler',
'wisenut','WISENut', 
'ixquick', 'ix quick', 
'earthlink', 'Earth Link',
'iune','i-une.com',
# Minor brazilian search engines
'engine','Cade', 'miner','Meta Miner',
# Minor chinese search engines
'baidu','Baidu', 'sina','Sina', 'sohu','Sohu',
# Minor czech search engines
'atlas','Atlas.cz',	'seznam','Seznam', 'quick','Quick.cz', 'centrum','Centrum.cz', 'jyxo','Jyxo.cz', 'najdi','Najdi.to', 'redbox','RedBox.cz',
# Minor danish search-engines
'opasia','Opasia', 'danielsen','Thor (danielsen.com)', 'sol','SOL', 'jubii','Jubii', 'finddk','Find', 'edderkoppen','Edderkoppen', 'netstjernen','Netstjernen', 'orbis','Orbis', 'tyfon','Tyfon', '1klik','1Klik', 'ofir','Ofir',
# Minor dutch search engines
'ilse','Ilse','vindex','Vindex\.nl',						
# Minor english search engines
'askuk','Ask Jeeves UK', 'bbc','BBC', 'freeserve','Freeserve', 'looksmartuk','Looksmart UK',
'mirago','Mirago', 'splut','Splut', 'spotjockey','Spotjockey', 'ukdirectory','UK Directory', 'ukindex','UKIndex', 'ukplus','UK Plus', 'searchy','searchy.co.uk',
# Minor finnish search engines
'haku','Ihmemaa',										
# Minor french search engines
'aolfr','AOL (fr)', 'ctrouve','C\'est trouvé', 'francite','Francité', 'lbb', 'LBB', 'libertysurf', 'Libertysurf', 'free', 'Free.fr', 'clubinternet', 'Club-internet',
# Minor german search engines
'aolde','AOL (de)',
'fireball','Fireball', 'infoseek','Infoseek', 'webde','Web.de',
'abacho','Abacho', 't-online','T-Online', 
'allesklar','allesklar.de', 'meinestadt','meinestadt.de', 
'metaspinner','metaspinner',
'metacrawler_de','metacrawler.de',
# Minor hungarian search engines
'heureka','Heureka', 'origo','Origo-Vizsla', 'lapkereso','Startlapkeresõ', 'goliat','Góliát', 'indexhu','Index', 'wahoo','Wahoo', 'webmania','webmania.hu', 'internetto','Internetto Keresõ',
# Minor italian search engines
'virgilio','Virgilio',										
# Minor norvegian search engines
'start','start.no',								
# Minor polish search engines
'wp','Szukaj',
# Minor russian search engines
'yandex', 'Yandex', 'aport', 'Aport', 'rambler', 'Rambler', 'turtle', 'Turtle', 'metabot', 'MetaBot',
# Minor swedish search engines
'passagen','Evreka',
# Minor Swiss search engines
'searchch', 'search.ch', 'bluewin', 'search.bluewin.ch',								
# Generic search engines
'search','Unknown search engines'
);


# Sanity check.
# Enable this code and run perl search_engines.pm to check file entries are ok
#-----------------------------------------------------------------------------
#foreach my $key (@SearchEnginesSearchIDOrder_list1) {
#	if (! $SearchEnginesHashID{$key}) { error("Entry '$key' has been found in SearchEnginesSearchIDOrder_list1 with no value in SearchEnginesHashID");
#	foreach my $key2 (@SearchEnginesSearchIDOrder_list2) { if ($key2 eq $key) { error("$key is in 1 and 2\n"); } }
#	foreach my $key2 (@SearchEnginesSearchIDOrder_listgen) { if ($key2 eq $key) { error("$key is in 1 and gen\n"); } }
#} }
#foreach my $key (@SearchEnginesSearchIDOrder_list2) {
#	if (! $SearchEnginesHashID{$key}) { error("Entry '$key' has been found in SearchEnginesSearchIDOrder_list1 with no value in SearchEnginesHashID");
#	foreach my $key2 (@SearchEnginesSearchIDOrder_list1) { if ($key2 eq $key) { error("$key is in 2 and 1\n"); } }
#	foreach my $key2 (@SearchEnginesSearchIDOrder_listgen) { if ($key2 eq $key) { error("$key is in 2 and gen\n"); } }
#} }
#foreach my $key (@SearchEnginesSearchIDOrder_listgen) { if (! $SearchEnginesHashID{$key}) { error("Entry '$key' has been found in SearchEnginesSearchIDOrder_listgen with no value in SearchEnginesHashID"); } }
#foreach my $key (keys %NotSearchEnginesKeys) { if (! $SearchEnginesHashID{$key}) { error("Entry '$key' has been found in NotSearchEnginesKeys with no value in SearchEnginesHashID"); } }
#foreach my $key (keys %SearchEnginesKnownUrl) {
#	my $found=0;
#	foreach my $key2 (values %SearchEnginesHashID) {
#		if ($key eq $key2) { $found=1; last; }
#	}
#	if (! $found) { die "Entry '$key' has been found in SearchEnginesKnownUrl with no value in SearchEnginesHashID"; }
#}
#foreach my $key (keys %SearchEnginesHashLib) {
#	my $found=0;
#	foreach my $key2 (values %SearchEnginesHashID) {
#		if ($key eq $key2) { $found=1; last; }
#	}
#	if (! $found) { die "Entry '$key' has been found in SearchEnginesHashLib with no value in SearchEnginesHashID"; }
#}
#print @SearchEnginesSearchIDOrder_list1." ".@SearchEnginesSearchIDOrder_list2." ".@SearchEnginesSearchIDOrder_listgen;

1;

# AWSTATS SEARCH ENGINES DATABASE
#--------------------------------
# Last update: 2001-12-02


# Search engines names database
# To add a search engine, add a new line:
# "match_string_in_url_that_identify_engine", "search_engine_name",
#-------------------------------------------------------
%SearchEnginesHashIDLib=(
# Most common search engines
"yahoo\.","Yahoo",
"altavista\.","AltaVista",
"msn\.","MSN",
"voila\.", "Voila",
"lycos\.","Lycos",
"search\.terra\.","Terra",
"google\.","Google",
"alltheweb\.com","AllTheWeb",
"netscape\.","Netscape",
"northernlight\.","NorthernLight",
"dmoz\.org","DMOZ",
"search\.aol\.co","AOL",
"www\.search\.com","Search.com",
"kvasir\.","Kvasir",
# Others
"hotbot\.","Hotbot",
"webcrawler\.","WebCrawler",
"metacrawler\.","MetaCrawler (Metamoteur)",
"go2net\.com","Go2Net (Metamoteur)",
"go\.com","Go.com",
"overture\.com","Overture",		# Replace "goto\.com","Goto.com",
"euroseek\.","Euroseek",
"excite\.","Excite",
"lokace\.", "Lokace",
"spray\.","Spray",
"netfind\.aol\.com","AOL",
"recherche\.aol\.fr","AOL",
"nbci\.com/search","NBCI",
"askjeeves\.","Ask Jeeves",
"mamma\.","Mamma",
"dejanews\.","DejaNews",
"search\.dogpile\.com","Dogpile",
"wisenut\.com","WISENut",
"engine\.exe","Cade", "miner\.bol\.com\.br","Meta Miner",		# Minor brazilian search engines
"opasia\.dk","Opasia", "danielsen\.com","Thor (danielsen.com)",	# Minor danish search-engines 
"ilse\.","Ilse","vindex\.","Vindex\.nl",						# Minor dutch search engines
"splut\.","Splut", "ukplus\.", "UKPlus", "mirago\.", "Mirago", "ukindex\.co\.uk", "UKIndex", "ukdirectory\.","UK Directory", # Minor english search engines
"haku\.www\.fi","Ihmemaa",										# Minor finnish search engines
"nomade\.fr/","Nomade", "ctrouve\.","C'est trouvé", "francite\.","Francité", "\.lbb\.org", "LBB", "rechercher\.libertysurf\.fr", "Libertysurf",	# Minor french search engines
"fireball\.de","Fireball", "infoseek\.de","Infoseek", "suche\.web\.de","Web.de", "meta\.ger","MetaGer",	# Minor german search engines
"virgilio\.it","Virgilio",										# Minor italian search engines
"sok\.start\.no","start.no",									# Minor norvegian search engines
"evreka\.passagen\.se","Evreka",								# Minor swedish search engines
"atlas\.cz","Atlas.cz",	"seznam\.cz","Seznam.cz", "quick\.cz","Quick.cz", "centrum\.cz","Centrum.cz",	#Minor czech search engines
"search\..*com","Other search engines"
);

# Search engines known URLs rules to find keywords (update the 10th january 2001)
#-------------------------------------------------------
%SearchEnginesKnownUrl=(
# Most common search engines
"yahoo\.","p=",
"altavista\.","q=",
"msn\.","q=",
"voila\.","kw=",
"lycos\.","query=",
"google\.","q=",
"alltheweb\.com","q(|uery)=",
"netscape\.","search=",
"northernlight\.","qr=",
"dmoz\.org","search=",
"search\.aol\.co","query=",
"www\.search\.com","q=",
"kvasir\.", "q=",
# Others
"askjeeves\.","ask=",
"hotbot\.","mt=",
"metacrawler\.","general=",
"go2net\.com","general=",
"go\.com","qt=",
"overture\.com","keywords=",
"euroseek\.","query=",
"excite\.","search=",
"spray\.","string=",
"nbci\.com/search","keyword=",
"mamma\.","query=",
"search\.dogpile\.com", "q=",
"wisenut\.com","query=",
"virgilio\.it","qs=",
"webcrawler","searchText=",
"engine\.exe","p1=", "miner\.bol\.com\.br","q=",				# Minor brazilian search engines
"opasia\.dk","q=", "danielsen\.com","q=", 						# Minor danish search engines
"ilse\.","search_for=", "vindex\.","in=",						# Minor dutch search engines
"splut\.","pattern=", "ukplus\.", "search=", "mirago\.", "txtSearch=",		# Minor english search engines
"ukindex\.co\.uk", "stext=", "ukdirectory\.","k=", 							# Minor english search engines
"haku\.www\.fi","w=",														# Minor finnish search engines
"nomade\.fr/","s=", "francite\.","name=",									# Minor french search engines
"fireball\.de","q=", "infoseek\.de","qt=", "suche\.web\.de","su=",			# Minor german search engines
"sok\.start\.no", "q=",											# Minor norvegian search engines
"evreka\.passagen\.se","q=",										# Minor swedish search engines
"atlas\.cz","searchtext=", "seznam\.cz","w=", "ftxt\.quick\.cz","query=", "centrum\.cz","q="		# Minor czech search engines
);
# If no rules are known, this will be used to clean URL of not keyword parameters.
@WordsToCleanSearchUrl= ("act=","annuaire=","btng=","categoria=","cfg=","cof=","cou=","cp=","dd=","domain=","dt=","dw=","exec=","geo=","hc=","height=","hl=","hq=","hs=","id=","kl=","lang=","loc=","lr=","matchmode=","medor=","message=","meta=","mode=","order=","page=","par=","pays=","pg=","pos=","prg=","qc=","refer=","sa=","safe=","sc=","sort=","src=","start=","style=","stype=","sum=","tag=","temp=","theme=","url=","user=","width=","what=","\\.x=","\\.y=","y=","look=");
# Never put the following exclusion ("ask=","claus=","general=","kw=","keyword=","keywords=","MT","p=","q=","qr=","qt=","query=","s=","search=","searchText=","string=","su=","w=") because they are strings that contain keywords we're looking for.


1;

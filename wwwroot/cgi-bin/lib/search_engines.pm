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
"google\.",
"msn\.",
"voila\.",
"yahoo\.",
"lycos\.",
"altavista\.",
"search\.terra\.",
"alltheweb\.com",
"netscape\.",
"dmoz\.org",
"search\.aol\.co",
"www\.search\.com",
"overture\.com",		# Replace "goto\.com","Goto.com",
# Minor internationnal search engines
"northernlight\.",
"hotbot\.",
"kvasir\.",
"webcrawler\.",
"metacrawler\.",
"go2net\.com",
"go\.com",
"euroseek\.",
"excite\.",
"lokace\.",
"spray\.",
"netfind\.aol\.com",
"recherche\.aol\.fr",
"nbci\.com/search",
"askjeeves\.",
"mamma\.",
"dejanews\.",
"search\.dogpile\.com",
"wisenut\.com",
# Minor brazilian search engines
"engine\.exe", "miner\.bol\.com\.br",
# Minor danish search-engines 
"opasia\.dk", "danielsen\.com",
# Minor dutch search engines
"ilse\.","vindex\.",
# Minor english search engines
"splut\.","ukplus\.","mirago\.","ukindex\.co\.uk","ukdirectory\.",
# Minor finnish search engines
"haku\.www\.fi",
# Minor french search engines
"nomade\.fr/","ctrouve\.","francite\.","\.lbb\.org","rechercher\.libertysurf\.fr",
# Minor german search engines
"fireball\.de","infoseek\.de","suche\.web\.de","meta\.ger",
# Minor italian search engines
"virgilio\.it",
# Minor norvegian search engines
"sok\.start\.no",
# Minor swedish search engines
"evreka\.passagen\.se",
# Minor czech search engines
"atlas\.cz","seznam\.cz","quick\.cz","centrum\.cz","najdi\.to","redbox\.cz",
# Other
"search\..*com"
);


# SearchEnginesHashIDLib
# List of search engines names
# "match_string_in_url_that_identify_engine", "search_engine_name",
#-----------------------------------------------------------------
%SearchEnginesHashIDLib=(
# Major internationnal search engines
"google\.","Google",
"msn\.","MSN",
"voila\.", "Voila",
"yahoo\.","Yahoo",
"lycos\.","Lycos",
"altavista\.","AltaVista",
"search\.terra\.","Terra",
"alltheweb\.com","AllTheWeb",
"netscape\.","Netscape",
"dmoz\.org","DMOZ",
"search\.aol\.co","AOL",
"www\.search\.com","Search.com",
"overture\.com","Overture",		# Replace "goto\.com","Goto.com",
# Minor internationnal search engines
"northernlight\.","NorthernLight",
"hotbot\.","Hotbot",
"kvasir\.","Kvasir",
"webcrawler\.","WebCrawler",
"metacrawler\.","MetaCrawler (Metamoteur)",
"go2net\.com","Go2Net (Metamoteur)",
"go\.com","Go.com",
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
# Minor brazilian search engines
"engine\.exe","Cade", "miner\.bol\.com\.br","Meta Miner",
# Minor danish search-engines 
"opasia\.dk","Opasia", "danielsen\.com","Thor (danielsen.com)",	
# Minor dutch search engines
"ilse\.","Ilse","vindex\.","Vindex\.nl",						
# Minor english search engines
"splut\.","Splut", "ukplus\.", "UKPlus", "mirago\.", "Mirago", "ukindex\.co\.uk", "UKIndex", "ukdirectory\.","UK Directory",
# Minor finnish search engines
"haku\.www\.fi","Ihmemaa",										
# Minor french search engines
"nomade\.fr/","Nomade", "ctrouve\.","C'est trouvé", "francite\.","Francité", "\.lbb\.org", "LBB", "rechercher\.libertysurf\.fr", "Libertysurf",	
# Minor german search engines
"fireball\.de","Fireball", "infoseek\.de","Infoseek", "suche\.web\.de","Web.de", "meta\.ger","MetaGer",	
# Minor italian search engines
"virgilio\.it","Virgilio",										
# Minor norvegian search engines
"sok\.start\.no","start.no",									
# Minor swedish search engines
"evreka\.passagen\.se","Evreka",								
# Minor czech search engines
"atlas\.cz","Atlas.cz",	"seznam\.cz","Seznam.cz", "quick\.cz","Quick.cz", "centrum\.cz","Centrum.cz","najdi\.to","Najdi.to","redbox\.cz","RedBox.cz",
# Other
"search\..*com","Other search engines"
);


# SearchEnginesKnownUrl
# Search engines known rules to extract keywords from a referrer URL
#-------------------------------------------------
%SearchEnginesKnownUrl=(
# Most common search engines
"yahoo\.","p=",
"altavista\.","q=",
"msn\.","q=",
"voila\.","kw=",
"lycos\.","query=",
"search\.terra\.","query=",
"google\.","(p|q)=",
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
"atlas\.cz","searchtext=", "seznam\.cz","w=", "ftxt\.quick\.cz","query=", "centrum\.cz","q=", "najdi\.to","dotaz=", "redbox.cz","srch="		# Minor czech search engines
);

# If no rules are known, this will be used to clean URL of not keyword parameters.
@WordsToCleanSearchUrl= ("act=","annuaire=","btng=","categoria=","cfg=","cof=","cou=","cp=","dd=","domain=","dt=","dw=","exec=","geo=","hc=","height=","hl=","hq=","hs=","id=","kl=","lang=","loc=","lr=","matchmode=","medor=","message=","meta=","mode=","order=","page=","par=","pays=","pg=","pos=","prg=","qc=","refer=","sa=","safe=","sc=","sort=","src=","start=","style=","stype=","sum=","tag=","temp=","theme=","url=","user=","width=","what=","\\.x=","\\.y=","y=","look=");
# Never put the following exclusion ("ask=","claus=","general=","kw=","keyword=","keywords=","MT","p=","q=","qr=","qt=","query=","s=","search=","searchText=","string=","su=","w=") because they are strings that contain keywords we're looking for.


1;

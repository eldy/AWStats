#!/usr/bin/perl
# use diagnostics;
# use strict;
#-Description-------------------------------------------
# Free realtime web server logfile analyzer (in Perl) working as a CGI to show
# advanced web statistics. For better performances, you should use this script
# at least once a day (from a scheduler for example).
# See README.TXT file for setup and benchmark informations
# See COPYING.TXT file about AWStats GNU General Public License
#-------------------------------------------------------


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
$VERSION="2.23q";
$Lang=0;

# Default value
$SortDir       = -1;		# -1 = Sort order from most to less, 1 = reverse order (Default = -1)
$VisitTimeOut  = 10000;		# Laps of time to consider a page load as a new visit. 10000 = one hour (Default = 10000)
$FullHostName  = 1;			# 1 = Use name.domain.zone to refer host clients, 0 = all hosts in same domain.zone are one host (Default = 1, 0 never tested)
$MaxLengthOfURL= 70;		# Maximum length of URL shown on stats page. This affects only URL visible text, link still work (Default = 70)
$BenchMark     = 0;			# Set this to 1 to get some benchmark informations as a second's counter since 1970 (Default = 0)
# Images for graphics
$BarImageVertical_v   = "barrevv.png";
$BarImageHorizontal_v = "barrehv.png";
$BarImageVertical_u   = "barrevu.png";
$BarImageHorizontal_u = "barrehu.png";
$BarImageVertical_p   = "barrevp.png";
$BarImageHorizontal_p = "barrehp.png";
$BarImageVertical_h   = "barrevh.png";
$BarImageHorizontal_h = "barrehh.png";
$BarImageVertical_k   = "barrevk.png";
$BarImageHorizontal_k = "barrehk.png";

# URL with such end signature are king of URL we only need hits
@NotPageList= (
			"\\.gif","\\.jpg","\\.png","\\.bmp",
#			"\\.zip","\\.arj","\\.gz","\\.z",
#			"\\.pdf","\\.doc","\\.ppt","\\.rtf","\\.txt",
#			"\\.mp3","\\.wma"
			);

# Those addresses are shown with those lib (First column is full relative URL, Second column is text to show instead of URL)
%Aliases    = (
			"/",                                    "<b>HOME PAGE</b>",
			"/cgi-bin/awstats.pl",					"<b>AWStats stats page</b>",
			"/cgi-bin/awstats/awstats.pl",			"<b>AWStats stats page</b>",
			# Following the same example, you can put here HTML text you want to see in links instead of URL text.
			"/YourRelativeUrl",						"<b>Your HTML text</b>",
			"/YourRelativeUrl",						"<b>Your HTML text</b>"
			);

# ---------- Search engines list --------------------
%SearchEnginesHash=(
# Most common search engines
"yahoo\.","Yahoo",				"altavista\.","AltaVista",
"msn\.dk/","MSN (dk)",			"msn\.fr/","MSN (fr)",		"msn\.","MSN",
"voila\.", "Voila",				"lycos\.","Lycos",			"nomade\.fr/","Nomade",
"search\.terra\.","Terra",
"google\.","Google",			"alltheweb\.com","AllTheWeb",
# Others
"hotbot\.","Hotbot",			"northernlight\.","NorthernLight",	
"webcrawler\.","WebCrawler",	"metacrawler\.","MetaCrawler (Metamoteur)",	"go2net\.com","Go2Net (Metamoteur)",
"go\.com","Go.com",		
"euroseek\.","Euroseek",		"excite\.","Excite",		"lokace\.", "Lokace",	"spray\.","Spray",
"ctrouve\.","C'est trouvé",		"francite\.","Francité",	"\.lbb\.org", "LBB",	"rechercher\.libertysurf\.fr","Libertysurf",
"netscape\.","Netscape",		"netfind\.aol\.com","AOL",	"recherche\.aol\.fr","AOL",
"snap\.","Snap",				"nbci\.com/search","NBCI",
"askjeeves\.","Ask Jeeves",		"mamma\.","Mamma",
"dejanews\.","DejaNews",
"dmoz\.org","DMOZ",
"search\.com","Other search engines"
);

# ---------- Search engines URL --------------------
@SearchEngineUrl=(
"yahoo\.","p=",
"altavista\.","q=",
"msn\.dk","MT=",
"msn\.fr","MT=",
"msn\.","MT=",
"google\.","q=",
"alltheweb\.","query=",
"lycos\.","query=",
"excite\.","search=",
"infoseek\.","qt=",
"eureka\.","q=",
"hotbot\.","MT=",
"webcrawler","searchText=",
"netscape\.","search=",
"mamma\.","query=",
"northernlight\.","qr="
);
@WordsToCleanSearchUrl= ("act=","annuaire=","btng=","categoria=","cou=","dd=","domain=","dt=","dw=","exec=","geo=","hc=","height=","hl=","hs=","kl=","lang=","loc=","lr=","matchmode=","medor=","message=","meta=","mode=","order=","page=","par=","pays=","pg=","pos=","prg=","qc=","refer=","sa=","safe=","sc=","sort=","src=","start=","stype=","tag=","temp=","theme=","url=","user=","width=","what=","\\.x=","\\.y=");
# Never put the following exclusion ("Claus=","kw=","keyword=","MT","p=","q=","qr=","qt=","query=","s=","search=","searchText=") because they are strings that contain keywords we're looking for.

# ---------- HTTP Code with tooltip --------
%httpcode = (
"201", "Partial Content", "202", "Request recorded, will be executed later", "204", "Request executed", "206", "Partial Content",
"301", "Moved Permanently", "302", "Found",
"400", "Bad Request", "401", "Unauthorized", "403", "Forbidden", "404", "Not Found", "408", "Request Timeout",
"500", "Internal Error", "501", "Not implemented", "502", "Received bad response from real server", "503", "Server busy", "504", "Gateway Time-Out", "505", "HTTP version not supported",

"200", "OK", "304", "Not Modified"	# 200 and 304 are not errors
);

# English
$message[0][0]="Unknown";
$message[1][0]="Unknown (unresolved ip)";
$message[2][0]="Other visitors";
$message[3][0]="View details";
$message[4][0]="Day";
$message[5][0]="Month";
$message[6][0]="Year";
$message[7][0]="Statistics of";
$message[8][0]="First visit";
$message[9][0]="Last visit";
$message[10][0]="Number of visits";
$message[11][0]="Unique visitors";
$message[12][0]="Visit";
$message[13][0]="Keyword";
$message[14][0]="Search";
$message[15][0]="Percent";
$message[16][0]="Traffic Summary";
$message[17][0]="Domains/Countries";
$message[18][0]="Visitors";
$message[19][0]="Pages/URL";
$message[20][0]="Hours";
$message[21][0]="Browsers";
$message[22][0]="HTTP Errors";
$message[23][0]="Referrers";
$message[24][0]="Search&nbsp;Keywords";
$message[25][0]="Visitors domains/countries";
$message[26][0]="hosts";
$message[27][0]="pages";
$message[28][0]="different pages";
$message[29][0]="Access";
$message[30][0]="Other words";
$message[31][0]="Used browsers";
$message[32][0]="HTTP Error codes";
$message[33][0]="Netscape versions";
$message[34][0]="MS Internet Explorer versions";
$message[35][0]="Used OS";
$message[36][0]="Connect to site from";
$message[37][0]="Origin";
$message[38][0]="Direct address / Bookmarks";
$message[39][0]="Link from a Newsgroup";
$message[40][0]="Link from an Internet Search Engine";
$message[41][0]="Link from an external page (other web sites except search engines)";
$message[42][0]="Link from an internal page (other page on same site)";
$message[43][0]="keywords used on search engines";
$message[44][0]="Kb";
$message[45][0]="Unresolved IP Address";
$message[46][0]="Unknown OS (Referer field)";
$message[47][0]="Required but not found URLs (HTTP code 404)";
$message[48][0]="IP Address";
$message[49][0]="Error&nbsp;Hits";
$message[50][0]="Unknown browsers (Referer field)";
$message[51][0]="Visiting robots";
$message[52][0]="visits/visitor";
$message[53][0]="Robots/Spiders visitors";
$message[54][0]="Free realtime logfile analyzer for advanced web statistics";
$message[55][0]="of";
$message[56][0]="Pages";
$message[57][0]="Hits";
$message[58][0]="Versions";
$message[59][0]="OS";
$message[60][0]="Jan";
$message[61][0]="Feb";
$message[62][0]="Mar";
$message[63][0]="Apr";
$message[64][0]="May";
$message[65][0]="Jun";
$message[66][0]="Jul";
$message[67][0]="Aug";
$message[68][0]="Sep";
$message[69][0]="Oct";
$message[70][0]="Nov";
$message[71][0]="Dec";

# French
$message[0][1]="Inconnus";
$message[1][1]="Inconnu (IP non résolue)";
$message[2][1]="Autres visiteurs";
$message[3][1]="Voir détails";
$message[4][1]="Jour";
$message[5][1]="Mois";
$message[6][1]="Année";
$message[7][1]="Statistiques du site";
$message[8][1]="Première visite";
$message[9][1]="Dernière visite";
$message[10][1]="Nbre visites";
$message[11][1]="Nbre visiteurs différents";
$message[12][1]="Visite";
$message[13][1]="Mot clé";
$message[14][1]="Recherche";
$message[15][1]="Pourcentage";
$message[16][1]="Résumé";
$message[17][1]="Domaines/Pays";
$message[18][1]="Visiteurs";
$message[19][1]="Pages/URL";
$message[20][1]="Heures";
$message[21][1]="Navigateurs";
$message[22][1]="Erreurs HTTP";
$message[23][1]="Origine/Referrer";
$message[24][1]="Mots&nbsp;clés&nbsp;de&nbsp;recherche";
$message[25][1]="Domaines/pays visiteurs";
$message[26][1]="des hôtes";
$message[27][1]="des pages";
$message[28][1]="pages différentes";
$message[29][1]="Accès";
$message[30][1]="Autres mots";
$message[31][1]="Navigateurs utilisés";
$message[32][1]="Codes Erreurs HTTP";
$message[33][1]="Versions de Netscape";
$message[34][1]="Versions de MS Internet Explorer";
$message[35][1]="Systèmes d'exploitation utilisés";
$message[36][1]="Connexions au site par";
$message[37][1]="Origine de la connexion";
$message[38][1]="Adresse directe / Bookmarks";
$message[39][1]="Lien depuis un Newsgroup";
$message[40][1]="Lien depuis un moteur de recherche Internet";
$message[41][1]="Lien depuis une page externe (autres sites, hors moteurs de recherche)";
$message[42][1]="Lien depuis une page interne (autre page du site)";
$message[43][1]="des critères de recherches utilisés";
$message[44][1]="Ko";
$message[45][1]="Adresses IP des visiteurs non identifiables (IP non résolue)";
$message[46][1]="OS non reconnus (champ referer brut)";
$message[47][1]="URLs du site demandées non trouvées (Code HTTP 404)";
$message[48][1]="Adresse IP";
$message[49][1]="Hits&nbsp;en&nbsp;échec";
$message[50][1]="Navigateurs non reconnus (champ referer brut)";
$message[51][1]="Robots visiteurs";
$message[52][1]="visite/visiteur";
$message[53][1]="Visiteurs Robots/Spiders";
$message[54][1]="Analyseur de log gratuit pour statistiques Web avancées";
$message[55][1]="sur";
$message[56][1]="Pages";
$message[57][1]="Hits";
$message[58][1]="Versions";
$message[59][1]="OS";
$message[60][1]="Jan";
$message[61][1]="Fév";
$message[62][1]="Mar";
$message[63][1]="Avr";
$message[64][1]="Mai";
$message[65][1]="Juin";
$message[66][1]="Juil";
$message[67][1]="Août";
$message[68][1]="Sep";
$message[69][1]="Oct";
$message[70][1]="Nov";
$message[71][1]="Déc";

# Dutch
$message[0][2]="Onbekend";
$message[1][2]="Onbekend (Onbekend ip)";
$message[2][2]="Andere bezoekers";
$message[3][2]="Bekijk details";
$message[4][2]="Dag";
$message[5][2]="Maand";
$message[6][2]="Jaar";
$message[7][2]="Statistieken van";
$message[8][2]="Eerste bezoek";
$message[9][2]="Laatste bezoek";
$message[10][2]="Aantal boezoeken";
$message[11][2]="Unieke bezoekers";
$message[12][2]="Bezoek";
$message[13][2]="Trefwoord";
$message[14][2]="Zoek";
$message[15][2]="Procent";
$message[16][2]="Opsomming";
$message[17][2]="Domeinen/Landen";
$message[18][2]="Bezoekers";
$message[19][2]="Pagina's/URL";
$message[20][2]="Uren";
$message[21][2]="Browsers";
$message[22][2]="HTTP Foutmeldingen";
$message[23][2]="Verwijzing";
$message[24][2]="Zoek&nbsp;trefwoorden";
$message[25][2]="Bezoekers domeinen/landen";
$message[26][2]="hosts";
$message[27][2]="pagina's";
$message[28][2]="verschillende pagina's";
$message[29][2]="Toegang";
$message[30][2]="Andere woorden";
$message[31][2]="Gebruikte browsers";
$message[32][2]="HTTP foutmelding codes";
$message[33][2]="Netscape versies";
$message[34][2]="MS Internet Explorer versies";
$message[35][2]="Gebruikt OS";
$message[36][2]="Verbinding naar site vanaf";
$message[37][2]="Herkomst";
$message[38][2]="Direkt adres / Bookmarks";
$message[39][2]="Link vanuit een nieuwsgroep";
$message[40][2]="Link vanuit een Internet Zoek Machine";
$message[41][2]="Link vanuit een externe pagina (andere web sites behalve zoek machines)";
$message[42][2]="Link vanuit een interne pagina (andere pagina van dezelfde site)";
$message[43][2]="gebruikte trefwoorden bij zoek machines";
$message[44][2]="Kb";
$message[45][2]="niet vertaald  IP Adres";
$message[46][2]="Onbekend OS (Referer veld)";
$message[47][2]="Verplicht maar niet gvonden URLs (HTTP code 404)";
$message[48][2]="IP Adres";
$message[49][2]="Fout&nbsp;Hits";
$message[50][2]="Onbekende browsers (Referer veld)";
$message[51][2]="Bezoekende robots";
$message[52][2]="bezoeken/bezoeker";
$message[53][2]="Robots/Spiders bezoekers";
$message[54][2]="Gratis realtime logbestand analyzer voor geavanceerde web statistieken";
$message[55][2]="van";
$message[56][2]="Pagina's";
$message[57][2]="Hits";
$message[58][2]="Versies";																																																										
$message[59][2]="OS";																																																										
$message[60][2]="Jan";																																																										
$message[61][2]="Feb";																																																										
$message[62][2]="Mar";
$message[63][2]="Apr";																																																										
$message[64][2]="May";																																																										
$message[65][2]="Jun";																																																										
$message[66][2]="Jul";																																																										
$message[67][2]="Aug";																																																										
$message[68][2]="Sep";																																																										
$message[69][2]="Oct";																																																										
$message[70][2]="Nov";																																																										
$message[71][2]="Dec";

# Spanish
$message[0][3]="Desconocido";
$message[1][3]="Dirección IP desconocida";
$message[2][3]="Otros visitantes";
$message[3][3]="Vea detalles";
$message[4][3]="Día";
$message[5][3]="Mes";
$message[6][3]="Año";
$message[7][3]="Estadísticas del sitio";
$message[8][3]="Primera visita";
$message[9][3]="Última visita";
$message[10][3]="Número de visitas";
$message[11][3]="No. de visitantes distintos";
$message[12][3]="Visita";
$message[13][3]="Palabra clave (keyword)";
$message[14][3]="Búsquedas";
$message[15][3]="Porciento";
$message[16][3]="Resumen de tráfico";
$message[17][3]="Dominios/Países";
$message[18][3]="Visitantes";
$message[19][3]="Páginas/URLs";
$message[20][3]="Horas";
$message[21][3]="Navegadores";
$message[22][3]="Errores";
$message[23][3]="Enlaces (Links)";
$message[24][3]="Palabra&nbsp;clave&nbsp;de&nbsp;búsqueda";
$message[25][3]="Dominios/Países de visitantes";
$message[26][3]="servidores";
$message[27][3]="páginas";
$message[28][3]="páginas diferentes";
$message[29][3]="Acceso";
$message[30][3]="Otras palabras";
$message[31][3]="Navegadores utilizados";
$message[32][3]="Códigos de Errores de Protocolo HTTP";
$message[33][3]="Versiones de Netscape";
$message[34][3]="Versiones de MS Internet Explorer";
$message[35][3]="Sistemas Operativos utilizados";
$message[36][3]="Enlaces (links) al sitio";
$message[37][3]="Origen de enlace";
$message[38][3]="Dirección directa / Favoritos";
$message[39][3]="Enlaces desde Newsgroups";
$message[40][3]="Enlaces desde algún motor de búsqueda";
$message[41][3]="Enlaces desde páginas externas (exeptuando motores de búsqueda)";
$message[42][3]="Enlaces desde páginas internas (otras páginas del sitio)";
$message[43][3]="Palabras clave utilizada por el motor de búsqueda";
$message[44][3]="Kb";
$message[45][3]="Dirección IP no identificada";
$message[46][3]="Sistema Operativo desconocido (campo de referencia)";
$message[47][3]="URLs necesarios pero no encontados (código 404 de protocolo HTTP)";
$message[48][3]="Dirección IP";
$message[49][3]="Hits&nbsp;erróneos";
$message[50][3]="Navegadores desconocidos (campo de referencia)";
$message[51][3]="Visitas de Robots";
$message[52][3]="Visitas/Visitante";
$message[53][3]="Visitas de Robots/Spiders (indexadores)";
$message[54][3]="Analizador gratuito de 'log' para estadísticas Web avanzadas";
$message[55][3]="de";
$message[56][3]="Páginas";
$message[57][3]="Hits";
$message[58][3]="Versiones";
$message[59][3]="Sistema Operativo";
$message[60][3]="Ene";
$message[61][3]="Feb";
$message[62][3]="Mar";
$message[63][3]="Abr";
$message[64][3]="May";
$message[65][3]="Jun";
$message[66][3]="Jul";
$message[67][3]="Ago";
$message[68][3]="Sep";
$message[69][3]="Oct";
$message[70][3]="Nov";
$message[71][3]="Dic";

# Italian
$message[0][4]="Sconosciuto";
$message[1][4]="Sconosciuto (ip non risolto)";
$message[2][4]="Altri visitatori";
$message[3][4]="Vedi dettagli";
$message[4][4]="Giorno";
$message[5][4]="Mese";
$message[6][4]="Anno";
$message[7][4]="Statistiche di";
$message[8][4]="Prima visita";
$message[9][4]="Ultima visita";
$message[10][4]="Numero di visite";
$message[11][4]="Numero di visitatori diverse";
$message[12][4]="Visite";
$message[13][4]="Parole chiave";
$message[14][4]="Ricerche";
$message[15][4]="Percentuali";
$message[16][4]="Riassunto del traffico";
$message[17][4]="Domini/Nazioni";
$message[18][4]="Visitatori";
$message[19][4]="Pagine/URL";
$message[20][4]="Ore";
$message[21][4]="Browsers";
$message[22][4]="Errori HTTP";
$message[23][4]="Origine/Riferimenti";
$message[24][4]="Ricerche&nbsp;Parole chiave";
$message[25][4]="Visitatori per domini/nazioni";
$message[26][4]="hosts";
$message[27][4]="pagine";
$message[28][4]="pagine diverse";
$message[29][4]="Accessi";
$message[30][4]="Altre parole";
$message[31][4]="Browser usati";
$message[32][4]="Codici di errori HTTP";
$message[33][4]="Netscape versione";
$message[34][4]="MS Internet Explorer versione";
$message[35][4]="Sistemi operativi usati";
$message[36][4]="Connesso al sito da";
$message[37][4]="Origine";
$message[38][4]="Indirizzo diretto / segnalibro";
$message[39][4]="Link da un  Newsgroup";
$message[40][4]="Link da un motore di ricerca";
$message[41][4]="Link da una pagina esterna (altri siti eccetto i motori di ricerca)";
$message[42][4]="Link da una pagina interna (altre pagine dello stesso sito)";
$message[43][4]="Parole chiave usate dai motori di ricerca";
$message[44][4]="Kb";
$message[45][4]="Indirizzi IP non risolti";
$message[46][4]="Sistemi operativi non conosciuti (Campo di riferimento)";
$message[47][4]="Richiesto un URL ma non trovato (HTTP codice 404)";
$message[48][4]="Indirizzo IP";
$message[49][4]="Errori&nbsp;Punteggio";
$message[50][4]="Browser sconosciuti (Campo di riferimento)";
$message[51][4]="Visite di robots";
$message[52][4]="visite/visitatori";
$message[53][4]="Visite di Robots/Spiders";
$message[54][4]="Analizzatore gratuito in tempo reale dei file di log per statistiche avanzate";
$message[55][4]="it";
$message[56][4]="Pagine";
$message[57][4]="Hits";
$message[58][4]="Versioni";
$message[59][4]="Sistema Operativo";
$message[60][4]="Genn";
$message[61][4]="Febb";
$message[62][4]="Mar";
$message[63][4]="Apr";
$message[64][4]="Magg";
$message[65][4]="Giu";
$message[66][4]="Lug";
$message[67][4]="Ago";
$message[68][4]="Sep";
$message[69][4]="Oct";
$message[70][4]="Nov";
$message[71][4]="Dic";

# German
$message[0][5]="Unbekannt";
$message[1][5]="IP konnte nicht aufgeloest werden";
$message[2][5]="Sonstige Besucher";
$message[3][5]="Details";
$message[4][5]="Tag";
$message[5][5]="Monat";
$message[6][5]="Jahr";
$message[7][5]="Statistik ueber";
$message[8][5]="Erster Besuch";
$message[9][5]="Letzter Besuch";
$message[10][5]="Anzahl der Besucher";
$message[11][5]="Verschiedene Besucher";
$message[12][5]="Besuch";
$message[13][5]="Suchbegriffe";
$message[14][5]="Haeufigkeit";
$message[15][5]="Prozent";
$message[16][5]="Verkehr Gesamt";
$message[17][5]="Laender";
$message[18][5]="Besucher";
$message[19][5]="Besuchte Seiten";
$message[20][5]="Durchschn. Tagesverlauf";
$message[21][5]="Browser";
$message[22][5]="HTTP Status";
$message[23][5]="Referrer";
$message[24][5]="Suchbegriffe";
$message[25][5]="Laender aus denen die Besucher kamen";
$message[26][5]="Hosts";
$message[27][5]="Seiten";
$message[28][5]="Unterschiedliche Seiten";
$message[29][5]="Zugriffe";
$message[30][5]="Weitere Suchbegriffe";
$message[31][5]="Verwendete Browser";
$message[32][5]="HTTP Status Meldungen";
$message[33][5]="Netscape Versionen<br><img src=\"$DirIcons/browser/netscape.png\">";
$message[34][5]="MS Internet Explorer Versionen<br><img src=\"$DirIcons/browser/msie.png\">";
$message[35][5]="Betriebssysteme";
$message[36][5]="Woher die Besucher kamen";
$message[37][5]="Ursprung";
$message[38][5]="Direkter Zugriff / Bookmarks";
$message[39][5]="Link von einer Newsgroup";
$message[40][5]="Link von einer Suchmaschine";
$message[41][5]="Link von einer ext. Seite (nicht Suchmaschine!)";
$message[42][5]="Link von einer Seite innerhalb der Web Site";
$message[43][5]="Suchbegriffen (Suchmaschinen)";
$message[44][5]="Kb";
$message[45][5]="Unaufgeloeste IP Adresse";
$message[46][5]="Unbekanntes Betriebssystem [Referer]";
$message[47][5]="Nicht auffindbare Seiten [Error 404]";
$message[48][5]="IP Addresse";
$message[49][5]="Fehler / Hits";
$message[50][5]="Unbekannter Browser [Referer]";
$message[51][5]="Besuche von Robots / Spider";
$message[52][5]="Besuche / Besucher";
$message[53][5]="Besuche von Robots / Spider";
$message[54][5]="Programm zur erweiterten Echtzeitanalyse von Log-Dateien";
$message[55][5]="von";
$message[56][5]="Seiten";
$message[57][5]="Hits";
$message[58][5]="Ausführungen";
$message[59][5]="Unbekanntes Betriebssystem";
$message[60][5]="Jan";
$message[61][5]="Feb";
$message[62][5]="Mar";
$message[63][5]="Abr";
$message[64][5]="Mai";
$message[65][5]="Jun";
$message[66][5]="Juli";
$message[67][5]="Aug";
$message[68][5]="Sep";
$message[69][5]="Oct";
$message[70][5]="Nov";
$message[71][5]="Dez";

# Polish
$PageCode[6]="<META HTTP-EQUIV=\"content-type\" CONTENT=\"text/html; charset=ISO-8859-2\">";
$message[0][6]="Nieznany";
$message[1][6]="Nieznany (brak odwzorowania IP w DNS)";
$message[2][6]="Inni go¶cie";
$message[3][6]="Szczegó³y...";
$message[4][6]="Dzieñ";
$message[5][6]="Miesi±c"; 
$message[6][6]="Rok";
$message[7][6]="Statystyki";
$message[8][6]="Pierwsza wizyta";
$message[9][6]="Ostatnia wizyta";
$message[10][6]="Ilo¶æ wizyt";
$message[11][6]="Unikalnych go¶ci";
$message[12][6]="wizyt";
$message[13][6]="S³owo kluczowe";
$message[14][6]="Szukanych";
$message[15][6]="Procent";
$message[16][6]="Podsumowanie";
$message[17][6]="Domeny/Kraje";
$message[18][6]="Go¶cie";
$message[19][6]="Stron/URL-i";
$message[20][6]="Rozk³ad godzinny";
$message[21][6]="Przegl±darki";
$message[22][6]="B³êdy HTTP";
$message[23][6]="Referenci";
$message[24][6]="Wyszukiwarki&nbsp;-&nbsp;s³owa&nbsp;kluczowe";
$message[25][6]="Domeny/narodowo¶æ Internautów";
$message[26][6]="hosty";
$message[27][6]="strony";
$message[28][6]="ró¿nych stron";
$message[29][6]="Dostêp";
$message[30][6]="Inne s³owa";
$message[31][6]="Przegl±darki"; 
$message[32][6]="Kody b³êdów HTTP";
$message[33][6]="Wersje Netscape'a<br><img src=\"$DirIcons/browser/netscape.png\">";
$message[34][6]="Wersje MS IE<br><img src=\"$DirIcons/browser/msie.png\">";
$message[35][6]="Systemy operacyjne";
$message[36][6]="¬ród³a po³±czeñ";
$message[37][6]="Pochodzenie";
$message[38][6]="Dostêp bezpo¶redni lub z Ulubionych/Bookmarków";
$message[39][6]="Link z grupy dyskusyjnej";
$message[40][6]="Link z wyszukiwarki internetowej";
$message[41][6]="Link zewnêtrzny (inne strony z wy³±czeniem wyszukiwarek)";
$message[42][6]="Link wewnêtrzny (z serwera na którym jest strona)";
$message[43][6]="S³owa kluczowe u¿yte w wyszukiwarkach internetowcyh";
$message[44][6]="Kb";
$message[45][6]="Nieznany (brak odwzorowania IP w DNS)";
$message[46][6]="Nieznany system operacyjny";
$message[47][6]="Nie znaleziony (B³±d HTTP 404)";
$message[48][6]="Adres IP";
$message[49][6]="Ilo¶æ&nbsp;b³êdów";
$message[50][6]="Nieznane przegl±darki";
$message[51][6]="Roboty sieciowe";
$message[52][6]="wizyt/go¶ci";
$message[53][6]="Roboty sieciowe";
$message[54][6]="Darmowy analizator logów on-line";
$message[55][6]="";
$message[56][6]="Pages";
$message[57][6]="Hits";
$message[58][6]="Versions";
$message[59][6]="Systemy operacyjne";
$message[60][6]="Jan";
$message[61][6]="Fev";
$message[62][6]="Luty";
$message[63][6]="Kwiecien";
$message[64][6]="Maj";
$message[65][6]="Jun";
$message[66][6]="Jul";
$message[67][6]="Ago";
$message[68][6]="Sep";
$message[69][6]="Oct";
$message[70][6]="Nov";
$message[71][6]="Dic";

# ---------- Browser lists ----------------
# ("browser id in lower case", "browser text")
%BrowsersHash = (
"netscape","defined_later",
"msie","defined_later",

"libwww","LibWWW",
"wget","Wget",
"lynx","Lynx",
"opera","Opera",
"22acidownload","22AciDownload",
"aol\\-iweng","AOL-Iweng",
"amigavoyager","AmigaVoyager",
"antfresco","ANT Fresco",
"bpftp","BPFTP",
"cyberdog","Cyberdog",
"downloadagent","DownloadAgent",
"ecatch", "eCatch",
"emailsiphon","EmailSiphon",
"friendlyspider","FriendlySpider",
"getright","GetRight",
"headdump","HeadDump",
"hotjava","Sun HotJava",
"ibrowse","IBrowse",
"intergo","InterGO",
"konqueror","Konqueror",
"linemodebrowser","W3C Line Mode Browser",
"lotus-notes","Lotus Notes web client",
"macweb","MacWeb",
"ncsa_mosaic","NCSA Mosaic",
"nutscrape", "Nutscrape",
"mspie","MS Pocket Internet Explorer",
"msfrontpageexpress","MS FrontPage Express",
"real","RealAudio or compatible player",
"teleport","TelePort Pro (Site grabber)",
"tzgeturl","TZGETURL",
"viking","Viking",
"webcapture","Acrobat (Site grabber)",
"webfetcher","WebFetcher",
"webtv","WebTV browser",
"webexplorer","IBM-WebExplorer",
"webmirror","WebMirror",
"webvcr","WebVCR",
"webzip","WebZIP"
);

# ---------- OS lists --------------------

# ("os id in lower case","os text")
%OSHash      = (
"win16","Windows 3.xx",
"win95","Windows 95",
"win98","Windows 98",
"winnt","Windows NT / Windows 2000",
"wince","Windows CE",
"cp/m","CPM",
"sunos","Sun Solaris",
"irix","Irix",
"macintosh","MacOS",
"unix","Unknown Unix system",
"linux","Linux",
"os/2","Warp OS/2",
"osf","OSF Unix",
"crayos","CrayOS",
"amigaos","AmigaOS",
"hp-ux","HP Unix",
"riscos","Acorn RISC OS",
"aix","Aix",
"netbsd","NetBSD",
"bsdi","BSDi",
"freebsd","FreeBSD",
"webtv","WebTV"
);

# ("text that match in log after changing space and plus into underscore","osid")
%OSAlias     = (
"windows_98","win98",
"windows_nt","winnt",
"win32","winnt",
"windows_95","win95",
"windows_31","win16",
"windows;i;16","win16",
"windowsce","wince",
"mac_powerpc","macintosh",
"mac_ppc","macintosh",
"mac_68000","macintosh",
"macweb","macintosh"
);


# ---------- Robot lists ------------
# List can be found at http://info.webcrawler.com/mak/projects/robots/active.html and the next command show how to generate tab list from this file:
# cat robotslist.txt | sed 's/:/ /' | awk ' /robot-id/ { name=tolower($2); } /robot-name/ { print "\""name"\", \""$0"\"," } ' | sed 's/robot-name *//g' > file
# Rem: To avoid bad detection, some robots id were removed from this list:
#      - Robots with ID of 2 letters only
#      - Robot called "webs"
# Rem: directhit is changed in direct_hit (it's real id)
%RobotHash   = (
"acme.spider", "Acme.Spider",
"ahoythehomepagefinder", "Ahoy! The Homepage Finder",
"alkaline", "Alkaline",
"appie", "Walhello appie",
"arachnophilia", "Arachnophilia",
"architext", "ArchitextSpider",
"aretha", "Aretha",
"ariadne", "ARIADNE",
"aspider", "ASpider (Associative Spider)",
"atn.txt", "ATN Worldwide",
"atomz", "Atomz.com Search Robot",
"auresys", "AURESYS",
"backrub", "BackRub",
"bigbrother", "Big Brother",
"bjaaland", "Bjaaland",
"blackwidow", "BlackWidow",
"blindekuh", "Die Blinde Kuh",
"bloodhound", "Bloodhound",
"brightnet", "bright.net caching robot",
"bspider", "BSpider",
"cactvschemistryspider", "CACTVS Chemistry Spider",
"calif", "Calif",
"cassandra", "Cassandra",
"cgireader", "Digimarc Marcspider/CGI",
"checkbot", "Checkbot",
"churl", "churl",
"cmc", "CMC/0.01",
"collective", "Collective",
"combine", "Combine System",
"conceptbot", "Conceptbot",
"core", "Web Core / Roots",
"cshkust", "CS-HKUST WISE: WWW Index and Search Engine",
"cusco", "Cusco",
"cyberspyder", "CyberSpyder Link Test",
"deweb", "DeWeb(c) Katalog/Index",
"dienstspider", "DienstSpider",
"diibot", "Digital Integrity Robot",
"direct_hit", "Direct Hit Grabber",
"dnabot", "DNAbot",
"download_express", "DownLoad Express",
"dragonbot", "DragonBot",
"dwcp", "DWCP (Dridus' Web Cataloging Project)",
"ebiness", "EbiNess",
"eit", "EIT Link Verifier Robot",
"emacs", "Emacs-w3 Search Engine",
"emcspider", "ananzi",
"esther", "Esther",
"evliyacelebi", "Evliya Celebi",
"nzexplorer", "nzexplorer",
"fdse", "Fluid Dynamics Search Engine robot",
"felix", "	Felix IDE",
"ferret", "Wild Ferret Web Hopper #1, #2, #3",
"fetchrover", "FetchRover",
"fido", "fido",
"finnish", "Hämähäkki",
"fireball", "KIT-Fireball",
"fish", "Fish search",
"fouineur", "Fouineur",
"francoroute", "Robot Francoroute",
"freecrawl", "Freecrawl",
"funnelweb", "FunnelWeb",
"gazz", "gazz",
"gcreep", "GCreep",
"getbot", "GetBot",
"geturl", "GetURL",
"golem", "Golem",
"googlebot", "Googlebot",
"grapnel", "Grapnel/0.01 Experiment",
"griffon", "Griffon                                                               ",
"gromit", "Gromit",
"gulliver", "Northern Light Gulliver",
"hambot", "HamBot",
"harvest", "Harvest",
"havindex", "havIndex",
"hometown", "Hometown Spider Pro",
"wired-digital", "Wired Digital",
"htdig", "ht://Dig",
"htmlgobble", "HTMLgobble",
"hyperdecontextualizer", "Hyper-Decontextualizer",
"ibm", "IBM_Planetwide",
"iconoclast", "Popular Iconoclast",
"ilse", "Ingrid",
"imagelock", "Imagelock ",
"incywincy", "IncyWincy",
"informant", "Informant",
"infoseek", "InfoSeek Robot 1.0",
"infoseeksidewinder", "Infoseek Sidewinder",
"infospider", "InfoSpiders",
"inspectorwww", "Inspector Web",
"intelliagent", "IntelliAgent",
"iron33", "Iron33",
"israelisearch", "Israeli-search",
"javabee", "JavaBee",
"jcrawler", "JCrawler",
"jeeves", "Jeeves",
"jobot", "Jobot",
"joebot", "JoeBot",
"jubii", "The Jubii Indexing Robot",
"jumpstation", "JumpStation",
"katipo", "Katipo",
"kdd", "KDD-Explorer",
"kilroy", "Kilroy",
"ko_yappo_robot", "KO_Yappo_Robot",
"labelgrabber.txt", "LabelGrabber",
"larbin", "larbin",
"legs", "legs",
"linkscan", "LinkScan",
"linkwalker", "LinkWalker",
"lockon", "Lockon",
"logo_gif", "logo.gif Crawler",
"lycos", "Lycos",
"macworm", "Mac WWWWorm",
"magpie", "Magpie",
"mediafox", "MediaFox",
"merzscope", "MerzScope",
"meshexplorer", "		NEC-MeshExplorer",
"mindcrawler", "MindCrawler",
"moget", "moget",
"momspider", "MOMspider",
"monster", "Monster",
"motor", "Motor",
"muscatferret", "Muscat Ferret",
"mwdsearch", "Mwd.Search",
"myweb", "Internet Shinchakubin",
"netcarta", "NetCarta WebMap Engine",
"netmechanic", "NetMechanic",
"netscoop", "NetScoop",
"newscan-online", "newscan-online",
"nhse", "NHSE Web Forager",
"nomad", "Nomad",
"northstar", "The NorthStar Robot",
"occam", "Occam",
"octopus", "HKU WWW Octopus",
"orb_search", "Orb Search",
"packrat", "Pack Rat",
"pageboy", "PageBoy",
"parasite", "ParaSite",
"patric", "Patric",
"perignator", "The Peregrinator",
"perlcrawler", "PerlCrawler 1.0",
"phantom", "Phantom",
"piltdownman", "PiltdownMan",
"pioneer", "Pioneer",
"pitkow", "html_analyzer",
"pjspider", "Portal Juice Spider",
"pka", "PGP Key Agent",
"plumtreewebaccessor", "PlumtreeWebAccessor ",
"poppi", "Poppi",
"portalb", "PortalB Spider",
"puu", "GetterroboPlus Puu",
"python", "The Python Robot",
"raven", "Raven Search",
"rbse", "RBSE Spider",
"resumerobot", "Resume Robot",
"rhcs", "RoadHouse Crawling System",
"roadrunner", "Road Runner: The ImageScape Robot",
"robbie", "Robbie the Robot",
"robi", "ComputingSite Robi/1.0",
"roverbot", "Roverbot",
"safetynetrobot", "SafetyNet Robot",
"scooter", "Scooter",
"search_au", "Search.Aus-AU.COM",
"searchprocess", "SearchProcess",
"senrigan", "Senrigan",
"sgscout", "SG-Scout",
"shaggy", "ShagSeeker",
"shaihulud", "Shai'Hulud",
"sift", "Sift",
"simbot", "Simmany Robot Ver1.0",
"site-valet", "Site Valet",
"sitegrabber", "Open Text Index Robot",
"sitetech", "SiteTech-Rover",
"slurp", "Inktomi Slurp",
"smartspider", "Smart Spider",
"snooper", "Snooper",
"solbot", "Solbot",
"spanner", "Spanner",
"speedy", "Speedy Spider",
"spider_monkey", "spider_monkey",
"spiderbot", "SpiderBot",
"spiderman", "SpiderMan",
"spry", "Spry Wizard Robot",
"ssearcher", "Site Searcher",
"suke", "Suke",
"sven", "Sven",
"tach_bw", "TACH Black Widow",
"tarantula", "Tarantula",
"tarspider", "tarspider",
"tcl", "Tcl W3 Robot",
"techbot", "TechBOT",
"templeton", "Templeton",
"titin", "TitIn",
"titan", "TITAN",
"tkwww", "The TkWWW Robot",
"tlspider", "TLSpider",
"ucsd", "UCSD Crawl",
"udmsearch", "UdmSearch",
"urlck", "URL Check",
"valkyrie", "Valkyrie",
"victoria", "Victoria",
"visionsearch", "vision-search",
"voyager", "Voyager",
"vwbot", "VWbot",
"w3index", "The NWI Robot",
"w3m2", "W3M2",
"wanderer", "the World Wide Web Wanderer",
"webbandit", "WebBandit Web Spider",
"webcatcher", "WebCatcher",
"webcopy", "WebCopy",
"webfetcher", "webfetcher",
"webfoot", "The Webfoot Robot",
"weblayers", "Weblayers",
"weblinker", "WebLinker",
"webmirror", "WebMirror",
"webmoose", "The Web Moose",
"webquest", "WebQuest",
"webreader", "Digimarc MarcSpider",
"webreaper", "WebReaper",
"websnarf", "Websnarf",
"webspider", "WebSpider",
"webvac", "WebVac",
"webwalk", "webwalk",
"webwalker", "WebWalker",
"webwatch", "WebWatch",
"wget", "Wget",
"whowhere", "WhoWhere Robot",
"wmir", "w3mir",
"wolp", "WebStolperer",
"wombat", "The Web Wombat ",
"worm", "The World Wide Web Worm",
"wwwc", "WWWC Ver 0.2.5",
"wz101", "WebZinger",
"xget", "XGET",
"nederland.zoek", "Nederland.zoek",

# Not declared robots
"antibot", "Antibot (Not referenced robot)",
"daviesbot", "DaviesBot (Not referenced robot)",
"ezresult",	"Ezresult (Not referenced robot)",
"fast-webcrawler", "Fast-Webcrawler (Not referenced robot)",
"jennybot", "JennyBot (Not referenced robot)",
"justview", "JustView (Not referenced robot)",
"mercator", "Mercator (Not referenced robot)",
#"msiecrawler", "MSIECrawler (Not referenced robot)",	MSIECrawler seems to be a grabber not a robot
"perman surfer", "Perman surfer (Not referenced robot)",
"unlost_web_crawler", "Unlost_Web_Crawler (Not referenced robot)",
"webbase", "WebBase (Not referenced robot)",
# Supposed to be robots
"webcompass", "webcompass (Not referenced robot)",
"digout4u", "digout4u (Not referenced robot)",
"echo", "EchO! (Not referenced robot)",
"voila", "Voila (Not referenced robot)",
"boris", "Boris (Not referenced robot)",
"ultraseek", "Ultraseek (Not referenced robot)",
"ia_archiver", "ia_archiver (Not referenced robot)",
# Generic ID
"robot", "Unknown robot (Not referenced robot)"
);

# ---------- Domains --------------------
%DomainsHash = (
"localhost","localhost",

"ad","Andorra","ae","United Arab Emirates","af","Afghanistan","ag",
"Antigua and Barbuda","ai","Anguilla","al","Albania","am",
"Armenia","an","Netherlands Antilles","ao","Angola","aq",
"Antarctica","ar","Argentina","arpa","Old style Arpanet","as",
"American Samoa","at","Austria","au","Australia","aw","Aruba","az",
"Azerbaidjan","ba","Bosnia-Herzegovina","bb","Barbados","bd",
"Bangladesh","be","Belgium","bf","Burkina Faso","bg","Bulgaria",
"bh","Bahrain","bi","Burundi","bj","Benin","bm","Bermuda","bn",
"Brunei Darussalam","bo","Bolivia","br","Brazil","bs","Bahamas",
"bt","Bhutan","bv","Bouvet Island","bw","Botswana","by","Belarus",
"bz","Belize","ca","Canada","cc","Cocos (Keeling) Islands","cf",
"Central African Republic","cg","Congo","ch","Switzerland","ci",
"Ivory Coast (Cote D'Ivoire)","ck","Cook Islands","cl","Chile","cm","Cameroon",
"cn","China","co","Colombia","com","Commercial","cr","Costa Rica",
"cs","Former Czechoslovakia","cu","Cuba","cv","Cape Verde","cx",
"Christmas Island","cy","Cyprus","cz","Czech Republic","de","Germany",
"dj","Djibouti","dk","Denmark","dm","Dominica","do","Dominican Republic",
"dz","Algeria","ec","Ecuador","edu","USA Educational","ee","Estonia",
"eg","Egypt","eh","Western Sahara","es","Spain","et","Ethiopia","fi","Finland","fj","Fiji","fk",
"Falkland Islands","fm","Micronesia","fo","Faroe Islands",
"fr","France","fx","France (European Territory)","ga","Gabon","gb",
"Great Britain","gd","Grenada","ge","Georgia","gf","French Guyana","gh","Ghana","gi","Gibraltar",
"gl","Greenland","gm","Gambia","gn","Guinea","gov","USA Government","gp","Guadeloupe (French)","gq",
"Equatorial Guinea","gr","Greece","gs","S. Georgia &amp; S. Sandwich Isls.",
"gt","Guatemala","gu","Guam (USA)","gw","Guinea Bissau","gy","Guyana",
"hk","Hong Kong","hm","Heard and McDonald Islands","hn","Honduras","hr",
"Croatia","ht","Haiti","hu","Hungary","id","Indonesia","ie","Ireland","il","Israel",
"in","India","int","International","io","British Indian Ocean Territory",
"iq","Iraq","ir","Iran","is","Iceland","it","Italy","jm",
"Jamaica","jo","Jordan","jp","Japan","ke","Kenya","kg","Kyrgyzstan",
"kh","Cambodia","ki","Kiribati","km","Comoros","kn","Saint Kitts &amp; Nevis Anguilla",
"kp","North Korea","kr","South Korea","kw","Kuwait","ky",
"Cayman Islands","kz","Kazakhstan","la","Laos","lb","Lebanon","lc","Saint Lucia",
"li","Liechtenstein","lk","Sri Lanka","lr","Liberia","ls","Lesotho","lt","Lithuania",
"lu","Luxembourg","lv","Latvia","ly","Libya","ma","Morocco","mc","Monaco",
"md","Moldavia","mg","Madagascar","mh","Marshall Islands","mil","USA Military","mk",
"Macedonia","ml","Mali","mm","Myanmar","mn","Mongolia","mo","Macau",
"mp","Northern Mariana Islands","mq","Martinique (French)","mr","Mauritania",
"ms","Montserrat","mt","Malta","mu","Mauritius","mv","Maldives","mw",
"Malawi","mx","Mexico","my","Malaysia","mz","Mozambique","na","Namibia","nato","NATO",
"nc","New Caledonia (French)","ne","Niger","net","Network","nf","Norfolk Island",
"ng","Nigeria","ni","Nicaragua","nl","Netherlands","no","Norway",
"np","Nepal","nr","Nauru","nt","Neutral Zone","nu","Niue","nz","New Zealand","om","Oman","org",
"Non-Profit Organizations","pa","Panama","pe","Peru","pf","Polynesia (French)",
"pg","Papua New Guinea","ph","Philippines","pk","Pakistan","pl","Poland",
"pm","Saint Pierre and Miquelon","pn","Pitcairn Island","pr",
"Puerto Rico","pt","Portugal","pw","Palau","py","Paraguay","qa","Qatar",
"re","Reunion (French)","ro","Romania","ru","Russian Federation","rw","Rwanda",
"sa","Saudi Arabia","sb","Solomon Islands","sc","Seychelles","sd",
"Sudan","se","Sweden","sg","Singapore","sh","Saint Helena","si","Slovenia",
"sj","Svalbard and Jan Mayen Islands","sk","Slovak Republic","sl","Sierra Leone",
"sm","San Marino","sn","Senegal","so","Somalia","sr","Suriname","st",
"Saint Tome and Principe","su","Former USSR","sv","El Salvador","sy","Syria","sz","Swaziland","tc",
"Turks and Caicos Islands","td","Chad","tf","French Southern Territories","tg","Togo",
"th","Thailand","tj","Tadjikistan","tk","Tokelau","tm","Turkmenistan","tn","Tunisia",
"to","Tonga","tp","East Timor","tr","Turkey","tt","Trinidad and Tobago","tv","Tuvalu",
"tw","Taiwan","tz","Tanzania","ua","Ukraine","ug","Uganda","uk",
"United Kingdom","um","USA Minor Outlying Islands","us","United States",
"uy","Uruguay","uz","Uzbekistan","va","Vatican City State","vc",
"Saint Vincent &amp; Grenadines","ve","Venezuela","vg","Virgin Islands (British)",
"vi","Virgin Islands (USA)","vn","Vietnam","vu","Vanuatu","wf","Wallis and Futuna Islands",
"ws","Samoa","ye","Yemen","yt","Mayotte","yu","Yugoslavia","za","South Africa",
"zm","Zambia","zr","Zaire","zw","Zimbabwe"
);


#-------------------------------------------------------
# Functions
#-------------------------------------------------------
sub html_head {
	print "<html>\n";
	print "<head>\n";
	if ($PageCode[$Lang] ne "") { print "$PageCode[$Lang]\n"; }
	print "<meta http-equiv=\"description\" content=\"$PROG - Advanced Web Statistics for $LocalSite\">\n";
	print "<meta http-equiv=\"keywords\" content=\"$LocalSite, free, advanced, realtime, web, server, logfile, log, analyzer, analysis, statistics, stats, perl, analyse, performance, hits, visits\">\n";
	print "<meta name=\"robots\" content=\"index,follow\">\n";
	print "<title>$message[7][$Lang] $LocalSite</title>\n";
	print "</head>\n";
	print "\n";
	print "<body>\n";
	print "<center><br>\n";
	print "<font size=2><b>AWStats</b></font><br>";
}

sub html_end {
	$date=localtime();
	print "<CENTER><br><font size=1>$date - <b>Advanced Web Statistics $VERSION</b> - <a href=\"http://awstats.sourceforge.net\" target=_newawstats>Created by $PROG</a></font><br>\n";
	print "<br>\n";
	print "$HTMLEndSection\n";
	print "</body>";
	print "</html>";
}

sub tab_head {
	print "
		<TABLE CLASS=TABLEBORDER BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=600>
		<TR><TD>
		<TABLE CLASS=TABLEFRAME BORDER=0 CELLPADDING=3 CELLSPACING=0 WIDTH=100%>
		<TR><TH COLSPAN=2 CLASS=TABLETITLE>$tab_titre</TH></TR>
		<TR><TD COLSPAN=2>
		<TABLE CLASS=TABLEDATA BORDER=1 CELLPADDING=2 CELLSPACING=0 WIDTH=100%>
		";
}

sub tab_end {
	print "</TABLE></TD></TR></TABLE>";
	print "</TD></TR></TABLE>\n\n";
}

sub UnescapeURL {
	$_[0] =~ s/\+/ /gi;
	$_[0] =~ s/%20/ /gi;	#
	$_[0] =~ s/%22//gi;		#"
	$_[0] =~ s/%26/ /gi;	#&
	$_[0] =~ s/%27/ /gi;	#'
	$_[0] =~ s/%28//gi;		#(
	$_[0] =~ s/%29//gi;		#)
	$_[0] =~ s/%2b/ /gi;	#+
	$_[0] =~ s/%2c/ /gi;	#,
	$_[0] =~ s/%2d//gi;		#-
	$_[0] =~ s/%2e/\./gi;	#.
	$_[0] =~ s/%2f/ /gi;	#/
	$_[0] =~ s/%3c/ /gi;	#<
	$_[0] =~ s/%3d/ /gi;	#=
	$_[0] =~ s/%3e/ /gi;	#>
	$_[0] =~ s/%c9/é/gi;	#é maj
	$_[0] =~ s/%e8/è/gi;	#è
	$_[0] =~ s/%e9/é/gi;	#é
	$_[0] =~ s/%ea/ê/gi;	#ê
	$_[0] =~ s/%eb/ë/gi;	#ë
	$_[0] =~ s/%f1/ñ/gi;	#ñ
	$_[0] =~ s/%f2/ò/gi;	#ò
	$_[0] =~ s/%f3/ó/gi;	#ó
	$_[0] =~ s/[0-9]//gi;	#		$_[0] =~ s/^[0-9]*//gi; should be better but not tested yet
	$_[0] =~ s/\"//gi;
}

sub error {
   	print "<font color=#880000>$_[0].</font><br>\n";
   	if ($ENV{"GATEWAY_INTERFACE"} ne "") { print "<br><b>\n"; }
	print "Setup ($FileConfig file, web server or logfile permissions) may be wrong.\n";
	if ($ENV{"GATEWAY_INTERFACE"} ne "") { print "</b><br>\n"; }
	print "See README.TXT for informations on how to setup $PROG.\n";
   	if ($ENV{"GATEWAY_INTERFACE"} ne "") { print "</BODY>\n</HTML>\n"; }
    die;
}

sub warning {
	if ($WarningMessages == 1) {
    	print "$_[0]<br>\n";
#		print "You can now remove this warning by changing <b>\$WarningMessages=1</b> parameter into <b>\$WarningMessages=0</b> in $PROG config file (<b>$FileConfig</b>).<br><br>\n"; }
	}
}

sub SkipHost {
	foreach $Skip (@SkipHosts) { if ($_[0] =~ /$Skip/) { return 1; } }
	0; # Not in @SkipHosts
}

sub SkipFile {
	foreach $Skip (@SkipFiles) { if ($_[0] =~ /$Skip/i) { return 1; } }
	0; # Not inside @SkipFiles
}

sub Read_Config_File {
	$FileConfig="";$DirConfig=$DIR;if (($DirConfig ne "") && (!($DirConfig =~ /\/$/)) && (!($DirConfig =~ /\\$/)) ) { $DirConfig .= "/"; }
	if (open(CONFIG,"$DirConfig$PROG.$LocalSite.conf")) { $FileConfig="$DirConfig$PROG.$LocalSite.conf"; $FileSuffix=".$LocalSite"; }
	if ($FileConfig eq "") { if (open(CONFIG,"$DirConfig$PROG.conf"))  { $FileConfig="$DirConfig$PROG.conf"; $FileSuffix=""; } }
	if ($FileConfig eq "") { $FileConfig="$PROG.conf"; error("Error: Couldn't open config file [$PROG.$LocalSite.conf] nor [$PROG.conf]: $!"); }
	while (<CONFIG>) {
		$_ =~ s/\n//;
		$line=$_; $line =~ s/#.*//; $line =~ s/	/¥/g; $line =~ s/ /¥/g;
		@felter=split(/=/,$line);
		$param=$felter[1]; $param =~ s/¥*$//g; $param =~ s/^¥*//g; $param =~ s/¥/ /g; $param =~ s/^\"//; $param =~ s/\"$//;
		# Read main section
		if ($line =~ /^LogFile/)               { $LogFile=$param; next; }
		if ($line =~ /^LogFormat/)             { $LogFormat=$param; next; }
		if ($line =~ /^HostAliases/) {
			@felter=split(/ /,$param);
			$i=0; foreach $elem (@felter)      { $HostAliases[$i]=$elem; $i++; }
			next;
			}
		if ($line =~ /^SkipFiles/) {
			@felter=split(/ /,$param);
			$i=0; foreach $elem (@felter)      { $SkipFiles[$i]=$elem; $i++; }
			next;
			}
		if ($line =~ /^SkipHosts/) {
			@felter=split(/ /,$param);
			$i=0; foreach $elem (@felter)      { $SkipHosts[$i]=$elem; $i++; }
			next;
			}
		if ($line =~ /^DirData/)               { $DirData=$param; next; }
		if ($line =~ /^DirCgi/)                { $DirCgi=$param; next; }
		if ($line =~ /^DirIcons/)              { $DirIcons=$param; next; }
		if ($line =~ /^DNSLookup/)             { $DNSLookup=$param; next; }
		if ($line =~ /^PurgeLogFile/)          { $PurgeLogFile=$param; next; }
		if ($line =~ /^ArchiveLogRecords/)     { $ArchiveLogRecords=$param; next; }
		# Read optional section
		if ($line =~ /^Lang/)                  { $Lang=$param; next; }
		if ($line =~ /^DefaultFile/)           { $DefaultFile=$param; next; }
		if ($line =~ /^WarningMessages/)       { $WarningMessages=$param; next; }
		if ($line =~ /^ShowLinksOnUrl/)        { $ShowLinksOnUrl=$param; next; }
		if ($line =~ /^ShowFlagLinks/)         { $ShowFlagLinks=$param; next; }
		if ($line =~ /^HTMLEndSection/)        { $HTMLEndSection=$param; next; }
		if ($line =~ /^BarWidth/)              { $BarWidth=$param; next; }
		if ($line =~ /^BarHeight/)             { $BarHeight=$param; next; }
		if ($line =~ /^MaxNbOfHostsShown/)     { $MaxNbOfHostsShown=$param; next; }
		if ($line =~ /^MinHitHost/)            { $MinHitHost=$param; next; }
		if ($line =~ /^MaxNbOfPageShown/)      { $MaxNbOfPageShown=$param; next; }
		if ($line =~ /^MinHitFile/)            { $MinHitFile=$param; next; }
		if ($line =~ /^MaxNbOfRefererShown/)   { $MaxNbOfRefererShown=$param; next; }
		if ($line =~ /^MinHitRefer/)           { $MinHitRefer=$param; next; }
		if ($line =~ /^MaxNbOfKeywordsShown/)  { $MaxNbOfKeywordsShown=$param; next; }
		if ($line =~ /^MinHitKeyword/)         { $MinHitKeyword=$param; next; }
		if ($line =~ /^MaxNbOfRobotShown/)     { $MaxNbOfRobotShown=$param; next; }
		if ($line =~ /^MinHitRobot/)           { $MinHitRobot=$param; next; }
		if ($line =~ /^Logo/)                  { $Logo=$param; next; }
		if ($line =~ /^color_Background/)      { $color_Background=$param; next; }
		if ($line =~ /^color_TableTitle/)      { $color_TableTitle=$param; next; }
		if ($line =~ /^color_TableBGTitle/)    { $color_TableBGTitle=$param; next; }
		if ($line =~ /^color_TableRowTitle/)   { $color_TableRowTitle=$param; next; }
		if ($line =~ /^color_TableBGRowTitle/) { $color_TableBGRowTitle=$param; next; }
		if ($line =~ /^color_TableBorder/)     { $color_TableBorder=$param; next; }
		if ($line =~ /^color_TableBG/)         { $color_TableBG=$param; next; }
		if ($line =~ /^color_link/)            { $color_link=$param; next; }
		if ($line =~ /^color_v/)               { $color_v=$param; next; }
		if ($line =~ /^color_w/)               { $color_w=$param; next; }
		if ($line =~ /^color_p/)               { $color_p=$param; next; }
		if ($line =~ /^color_h/)               { $color_h=$param; next; }
		if ($line =~ /^color_k/)               { $color_k=$param; next; }
		if ($line =~ /^color_s/)               { $color_s=$param; next; }
	}
	close CONFIG;
}

sub Check_Config {
	# Main section
	if (! ($LogFormat =~ /[1-2]/))            { error("Error: LogFormat parameter is wrong. Value is $LogFormat (should be 1 or 2)"); }
	if (! ($DNSLookup =~ /[0-1]/))            { error("Error: DNSLookup parameter is wrong. Value is $DNSLookup (should be 0 or 1)"); }
	# Optional section
	if (! ($PurgeLogFile =~ /[0-1]/))         { $PurgeLogFile=0; }
	if (! ($ArchiveLogRecords =~ /[0-1]/))    { $ArchiveLogRecords=1; }
	if (! ($Lang =~ /[0-6]/))                 { $Lang=0; }
	if ($DefaultFile eq "")                   { $DefaultFile="index.html"; }
	if (! ($WarningMessages =~ /[0-1]/))      { $WarningMesages=1; }
	if (! ($ShowLinksOnURL =~ /[0-1]/))       { $ShowLinksOnURL=1; }
	if (! ($ShowFlagLinks =~ /[0-1]/))        { $ShowFlagLinks=1; }
	if (! ($BarWidth =~ /[\d]/))              { $BarWidth=260; }
	if (! ($BarHeight =~ /[\d]/))             { $BarHeight=220; }
	if (! ($MaxNbOfHostsShown =~ /[\d]/))     { $MaxNbOfHostsShown=25; }
	if (! ($MinHitHost =~ /[\d]/))            { $MinHitHost=1; }
	if (! ($MaxNbOfPageShown =~ /[\d]/))      { $MaxNbOfPageShown=25; }
	if (! ($MinHitFile =~ /[\d]/))            { $MinHitFile=1; }
	if (! ($MaxNbOfRefererShown =~ /[\d]/))   { $MaxNbOfRefererShown=25; }
	if (! ($MinHitRefer =~ /[\d]/))           { $MinHitRefer=1; }
	if (! ($MaxNbOfKeywordsShown =~ /[\d]/))  { $MaxNbOfKeywordsShown=25; }
	if (! ($MinHitKeyword =~ /[\d]/))         { $MinHitKeyword=1; }
	if (! ($MaxNbOfRobotShown =~ /[\d]/))     { $MaxNbOfRobotShown=25; }
	if (! ($MinHitRobot =~ /[\d]/))           { $MinHitRobot=1; }
	if ($Logo eq "")                          { $Logo="awstats_logo1.png"; }
	if (! ($color_Background =~ /[\d]/))      { $color_Background="#FFFFFF";	}
	if (! ($color_TableBorder =~ /[\d]/))     { $color_TableBorder="#000000"; }
	if (! ($color_TableBG =~ /[\d]/))         { $color_TableBG="#DDDDBB"; }
	if (! ($color_TableTitle =~ /[\d]/))      { $color_TableTitle="#FFFFFF"; }
	if (! ($color_TableBGTitle =~ /[\d]/))    { $color_TableBGTitle="#666666"; }
	if (! ($color_TableRowTitle =~ /[\d]/))   { $color_TableRowTitle="#FFFFFF"; }
	if (! ($color_TableBGRowTitle =~ /[\d]/)) { $color_TableBGRowTitle="#BBBBBB"; }
	if (! ($color_link =~ /[\d]/))            { $color_link="#4000FF"; }
	if (! ($color_v =~ /[\d]/))               { $color_v="#F3F300"; }
	if (! ($color_w =~ /[\d]/))               { $color_w="#FF9933"; }
	if (! ($color_p =~ /[\d]/))               { $color_p="#4477DD"; }
	if (! ($color_h =~ /[\d]/))               { $color_h="#66F0FF"; }
	if (! ($color_k =~ /[\d]/))               { $color_k="#339944"; }
	if (! ($color_s =~ /[\d]/))               { $color_s="#8888DD"; }
}

sub Read_History_File_For_LastTime {
if (open(HISTORY,"$DirData/$PROG$_[0]$_[1]$FileSuffix.txt")) {
	while (<HISTORY>) {
		$_ =~ s/\n//;
		@field=split(/ /,$_);
		if ($field[0] eq "LastTime")        { $LastTime{$_[0].$_[1]}=$field[1]; last; }
		}
	}
close HISTORY;
}

sub Read_History_File {
if ($HistoryFileAlreadyRead{"$_[0]$_[1]"}) { return 0; }	# Protect code to invoke function only once for each month/year
$HistoryFileAlreadyRead{"$_[0]$_[1]"}=1;
if (open(HISTORY,"$DirData/$PROG$_[0]$_[1]$FileSuffix.txt")) {
	$readdomain=0;$readvisitor=0;$readunknownip=0;$readsider=0;$readtime=0;$readbrowser=0;$readnsver=0;$readmsiever=0;
	$reados=0;$readrobot=0;$readunknownreferer=0;$readunknownrefererbrowser=0;$readpagerefs=0;$readse=0;
	$readsearchwords=0;$readerrors=0;$readerrors404=0;
	while (<HISTORY>) {
		$_ =~ s/\n//;
		@field=split(/ /,$_);
		if ($field[0] eq "FirstTime")       { $FirstTime{$_[0].$_[1]}=$field[1]; next; }
        if ($field[0] eq "LastTime")        { if ($LastTime{$_[0].$_[1]} < $field[1]) { $LastTime{$_[0].$_[1]}=$field[1]; }; next; }
		if ($field[0] eq "TotalVisits")     { $MonthVisits{$_[0].$_[1]}+=$field[1]; next; }
        if ($field[0] eq "BEGIN_VISITOR")   { $readvisitor=1; next; }
        if ($field[0] eq "END_VISITOR")     { $readvisitor=0; next; }
        if ($field[0] eq "BEGIN_UNKNOWNIP") { $readunknownip=1; next; }
        if ($field[0] eq "END_UNKNOWNIP")   { $readunknownip=0; next; }
        if ($field[0] eq "BEGIN_TIME")      { $readtime=1; next; }
        if ($field[0] eq "END_TIME")        { $readtime=0; next; }

        if ($readvisitor) {
        	if (($field[0] ne "Unknown") && ($field[1] > 0)) { $MonthUnique{$_[0].$_[1]}++; }
        	}
        if ($readunknownip) {
        	$MonthUnique{$_[0].$_[1]}++;
			}
        if ($readtime) {
        	$MonthPage{$_[0].$_[1]}+=$field[1]; $MonthHits{$_[0].$_[1]}+=$field[2]; $MonthBytes{$_[0].$_[1]}+=$field[3];
			}

		# If $_[2] == 0, it means we don't need second part of history file
		if ($_[2]) {	
	        if ($field[0] eq "BEGIN_DOMAIN") { $readdomain=1; next; }
			if ($field[0] eq "END_DOMAIN")   { $readdomain=0; next; }
			if ($field[0] eq "BEGIN_SIDER")  { $readsider=1; next; }
			if ($field[0] eq "END_SIDER")    { $readsider=0; next; }
	        if ($field[0] eq "BEGIN_BROWSER") { $readbrowser=1; next; }
	        if ($field[0] eq "END_BROWSER") { $readbrowser=0; next; }
	        if ($field[0] eq "BEGIN_NSVER") { $readnsver=1; next; }
	        if ($field[0] eq "END_NSVER") { $readnsver=0; next; }
	        if ($field[0] eq "BEGIN_MSIEVER") { $readmsiever=1; next; }
	        if ($field[0] eq "END_MSIEVER") { $readmsiever=0; next; }
	        if ($field[0] eq "BEGIN_OS") { $reados=1; next; }
	        if ($field[0] eq "END_OS") { $reados=0; next; }
	        if ($field[0] eq "BEGIN_ROBOT") { $readrobot=1; next; }
	        if ($field[0] eq "END_ROBOT") { $readrobot=0; next; }
	        if ($field[0] eq "BEGIN_UNKNOWNREFERER") { $readunknownreferer=1; next; }
	        if ($field[0] eq "END_UNKNOWNREFERER")   { $readunknownreferer=0; next; }
	        if ($field[0] eq "BEGIN_UNKNOWNREFERERBROWSER") { $readunknownrefererbrowser=1; next; }
	        if ($field[0] eq "END_UNKNOWNREFERERBROWSER")   { $readunknownrefererbrowser=0; next; }
	        if ($field[0] eq "BEGIN_PAGEREFS") { $readpagerefs=1; next; }
	        if ($field[0] eq "END_PAGEREFS") { $readpagerefs=0; next; }
	        if ($field[0] eq "BEGIN_SEREFERRALS") { $readse=1; next; }
	        if ($field[0] eq "END_SEREFERRALS") { $readse=0; next; }
	        if ($field[0] eq "BEGIN_SEARCHWORDS") { $readsearchwords=1; next; }
	        if ($field[0] eq "END_SEARCHWORDS") { $readsearchwords=0; next; }
	        if ($field[0] eq "BEGIN_ERRORS") { $readerrors=1; next; }
	        if ($field[0] eq "END_ERRORS") { $readerrors=0; next; }
	        if ($field[0] eq "BEGIN_SIDER_404") { $readerrors404=1; next; }
	        if ($field[0] eq "END_SIDER_404") { $readerrors404=0; next; }

	        if ($readvisitor) {
	        	$_hostmachine_p{$field[0]}+=$field[1];
	        	$_hostmachine_h{$field[0]}+=$field[2];
	        	$_hostmachine_k{$field[0]}+=$field[3];
	        	if ($_hostmachine_l{$field[0]} eq "") { $_hostmachine_l{$field[0]}=$field[4]; }
	        	next; }
	        if ($readunknownreferer) {
	        	if ($_unknownreferer_l{$field[0]} eq "") { $_unknownreferer_l{$field[0]}=$field[1]; }
	        	next; }
			if ($readdomain) {
				$_domener_p{$field[0]}+=$field[1];
				$_domener_h{$field[0]}+=$field[2];
				$_domener_k{$field[0]}+=$field[3];
				next; }
	        if ($readunknownip) {
	        	if ($_unknownip_l{$field[0]} eq "") { $_unknownip_l{$field[0]}=$field[1]; }
	        	next; }
			if ($readsider) { $_sider_p{$field[0]}+=$field[1]; next; }
	        if ($readtime) {
	        	$_time_p[$field[0]]+=$field[1]; $_time_h[$field[0]]+=$field[2]; $_time_k[$field[0]]+=$field[3];
	        	next; }
	        if ($readbrowser) { $_browser_h{$field[0]}+=$field[1]; next; }
	        if ($readnsver) { $_nsver_h[$field[0]]+=$field[1]; next; }
	        if ($readmsiever) { $_msiever_h[$field[0]]+=$field[1]; next; }
	        if ($reados) { $_os_h{$field[0]}+=$field[1]; next; }
	        if ($readrobot) {
				$_robot_h{$field[0]}+=$field[1];
	        	if ($_robot_l{$field[0]} eq "") { $_robot_l{$field[0]}=$field[2]; }
				next; }
	        if ($readunknownrefererbrowser) {
	        	if ($_unknownrefererbrowser_l{$field[0]} eq "") { $_unknownrefererbrowser_l{$field[0]}=$field[1]; }
	        	next; }
	        if ($field[0] eq "HitFrom0") { $_from_h[0]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom1") { $_from_h[1]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom2") { $_from_h[2]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom3") { $_from_h[3]+=$field[1]; next; }
	        if ($field[0] eq "HitFrom4") { $_from_h[4]+=$field[1]; next; }
	        if ($readpagerefs) { $_pagesrefs_h{$field[0]}+=$field[1]; next; }
	        if ($readse) { $_se_referrals_h{$field[0]}+=$field[1]; next; }
	        if ($readsearchwords) { $_keywords{$field[0]}+=$field[1]; next; }
	        if ($readerrors) { $_errors_h{$field[0]}+=$field[1]; next; }
	        if ($readerrors404) { $_sider404_h{$field[0]}+=$field[1]; next; }

			}
		}
	}
close HISTORY;
}

sub Save_History_File {
	open(HISTORYTMP,">$DirData/$PROG$_[0]$_[1]$FileSuffix.tmp.$$") || error("Couldn't open file $DirData/$PROG$_[0]$_[1]$FileSuffix.tmp.$$: $!");
	
	print HISTORYTMP "FirstTime $FirstTime{$_[0].$_[1]}\n";
	print HISTORYTMP "LastTime $LastTime{$_[0].$_[1]}\n";
	print HISTORYTMP "TotalVisits $MonthVisits{$_[0].$_[1]}\n";
	
	print HISTORYTMP "BEGIN_DOMAIN\n";
	foreach $key (keys %_domener_h) {
		$page=$_domener_p{$key};$kilo=$_domener_k{$key};
		if ($page == "") {$page=0;}
		if ($kilo == "") {$kilo=0;}
		print HISTORYTMP "$key $page $_domener_h{$key} $kilo\n"; next;
		}
	print HISTORYTMP "END_DOMAIN\n";
	
	print HISTORYTMP "BEGIN_VISITOR\n";
	foreach $key (keys %_hostmachine_h) {
		$page=$_hostmachine_p{$key};$kilo=$_hostmachine_k{$key};
		if ($page == "") {$page=0;}
		if ($kilo == "") {$kilo=0;}
		print HISTORYTMP "$key $page $_hostmachine_h{$key} $kilo $_hostmachine_l{$key}\n"; next;
		}
	print HISTORYTMP "END_VISITOR\n";
	
	print HISTORYTMP "BEGIN_UNKNOWNIP\n";
	foreach $key (keys %_unknownip_l) { print HISTORYTMP "$key $_unknownip_l{$key}\n"; next; }
	print HISTORYTMP "END_UNKNOWNIP\n";
	
	print HISTORYTMP "BEGIN_SIDER\n";
	foreach $key (keys %_sider_p) { print HISTORYTMP "$key $_sider_p{$key}\n"; next; }
	print HISTORYTMP "END_SIDER\n";
	
	print HISTORYTMP "BEGIN_TIME\n";
	for ($ix=0; $ix<=23; $ix++) { print HISTORYTMP "$ix $_time_p[$ix] $_time_h[$ix] $_time_k[$ix]\n"; next; }
	print HISTORYTMP "END_TIME\n";
	
	print HISTORYTMP "BEGIN_BROWSER\n";
	foreach $key (keys %_browser_h) { print HISTORYTMP "$key $_browser_h{$key}\n"; next; }
	print HISTORYTMP "END_BROWSER\n";
	print HISTORYTMP "BEGIN_NSVER\n";
	for ($i=1; $i<=$#_nsver_h; $i++) { print HISTORYTMP "$i $_nsver_h[$i]\n"; next; }
	print HISTORYTMP "END_NSVER\n";
	print HISTORYTMP "BEGIN_MSIEVER\n";
	for ($i=1; $i<=$#_msiever_h; $i++) { print HISTORYTMP "$i $_msiever_h[$i]\n"; next; }
	print HISTORYTMP "END_MSIEVER\n";
	print HISTORYTMP "BEGIN_OS\n";
	foreach $key (keys %_os_h) { print HISTORYTMP "$key $_os_h{$key}\n"; next; }
	print HISTORYTMP "END_OS\n";
	
	print HISTORYTMP "BEGIN_ROBOT\n";
	foreach $key (keys %_robot_h) { print HISTORYTMP "$key $_robot_h{$key} $_robot_l{$key}\n"; next; }
	print HISTORYTMP "END_ROBOT\n";
	
	print HISTORYTMP "BEGIN_UNKNOWNREFERER\n";
	foreach $key (keys %_unknownreferer_l) { print HISTORYTMP "$key $_unknownreferer_l{$key}\n"; next; }
	print HISTORYTMP "END_UNKNOWNREFERER\n";
	print HISTORYTMP "BEGIN_UNKNOWNREFERERBROWSER\n";
	foreach $key (keys %_unknownrefererbrowser_l) { print HISTORYTMP "$key $_unknownrefererbrowser_l{$key}\n"; next; }
	print HISTORYTMP "END_UNKNOWNREFERERBROWSER\n";
	
	print HISTORYTMP "HitFrom0 $_from_h[0]\n";
	print HISTORYTMP "HitFrom1 $_from_h[1]\n";
	print HISTORYTMP "HitFrom2 $_from_h[2]\n";
	print HISTORYTMP "HitFrom3 $_from_h[3]\n";
	print HISTORYTMP "HitFrom4 $_from_h[4]\n";
	
	print HISTORYTMP "BEGIN_SEREFERRALS\n";
	foreach $key (keys %_se_referrals_h) { print HISTORYTMP "$key $_se_referrals_h{$key}\n"; next; }
	print HISTORYTMP "END_SEREFERRALS\n";
	
	print HISTORYTMP "BEGIN_PAGEREFS\n";
	foreach $key (keys %_pagesrefs_h) { print HISTORYTMP "$key $_pagesrefs_h{$key}\n"; next; }
	print HISTORYTMP "END_PAGEREFS\n";
	
	print HISTORYTMP "BEGIN_SEARCHWORDS\n";
	foreach $key (keys %_keywords) { print HISTORYTMP "$key $_keywords{$key}\n"; next; }
	print HISTORYTMP "END_SEARCHWORDS\n";
	
	print HISTORYTMP "BEGIN_ERRORS\n";
	foreach $key (keys %_errors_h) { print HISTORYTMP "$key $_errors_h{$key}\n"; next; }
	print HISTORYTMP "END_ERRORS\n";
	
	print HISTORYTMP "BEGIN_SIDER_404\n";
	foreach $key (keys %_sider404_h) { print HISTORYTMP "$key $_sider404_h{$key}\n"; next; }
	print HISTORYTMP "END_SIDER_404\n";
	
	close(HISTORYTMP);
}

sub Init_HashArray {
	reset _;		# Delete all hash arrays with name beginning by _
}



#-------------------------------------------------------
# MAIN
#-------------------------------------------------------
$Lang=0;
if ($ENV{"GATEWAY_INTERFACE"} ne "") {
	$QueryString = $ENV{"QUERY_STRING"};
	if ($QueryString =~ /site=/) { $LocalSite=$QueryString; $LocalSite =~ s/.*site=//; $LocalSite =~ s/&.*//; }
	else { $LocalSite = $ENV{"SERVER_NAME"}; }
	$PROG=$0; $PROG =~ s/.*\\//; $PROG =~ s/.*\///; $DIR=$0; $DIR =~ s/$PROG//;
	$Extension=$PROG; $Extension =~ s/.*\.pl?/pl/;
	$PROG =~ s/\.$Extension$//;
	print("Content-type: text/html\n\n\n");
	}
else {
	$LocalSite = $ARGV[1];
	$PROG=$0; $PROG =~ s/.*\\//; $PROG =~ s/.*\///; $DIR=$0; $DIR =~ s/$PROG//;
	$Extension=$PROG; $Extension =~ s/.*\.pl?/pl/;
	$PROG =~ s/\.$Extension$//;
	}
$LocalSite =~ tr/A-Z/a-z/;
$LocalSiteWithoutwww = $LocalSite; $LocalSiteWithoutwww =~ s/www\.//;
if (($ENV{"GATEWAY_INTERFACE"} eq "") && ($ARGV[0] eq "" || $ARGV[0] ne "-h" || $ARGV[1] eq "")) {
	print "----- $PROG $VERSION (c) Laurent Destailleur -----\n";
	print "$PROG is a free web server logfile analyzer (in Perl) to show you advanced\n";
	print "web statistics. Distributed under GNU General Public Licence.\n";
	print "Syntax: $PROG.$Extension -h www.host.com\n";
	print " Runs $PROG from command line to have statistics of www.host.com web site.\n";
	print " First, $PROG tries to use $PROG.www.host.com.conf as the config file, if\n";
	print " not found, $PROG will use $PROG.conf.\n";
	print " See README.TXT file to know how to configure this file.\n";
	print "Now supports/detects:\n";
	print " Number of visits and unique visitors\n";
	print " Rush hours\n";
	print " Most often viewed pages\n";
	@DomainsArray=keys %DomainsHash;
	print " ".(@DomainsArray)." domains/countries\n";
	@BrowserArray=keys %BrowsersHash;
	print " ".(@BrowserArray)." browsers\n";
	@OSArray=keys %OSHash;
	print " ".(@OSArray)." Operating Systems\n";
	@RobotArray=keys %RobotHash;
	print " ".(@RobotArray)." robots\n";
	@SearchEnginesArray=keys %SearchEnginesHash;
	print " ".(@SearchEnginesArray)." search engines (and keywords used from them)\n";
	print " All HTTP errors\n";
	print " and more...\n";
	print "New versions and support at http://awstats.sourceforge.net\n";
	exit 0
	}

# Print html header
if ($ENV{"GATEWAY_INTERFACE"} ne "") { 
	if ($QueryString =~ /lang=/) { $Lang=$QueryString; $Lang =~ s/.*lang=//; $Lang =~ s/&.*//; }
	&html_head;
	}

# Read config file
&Read_Config_File;

# Correct some parameters
if ($ENV{"GATEWAY_INTERFACE"} ne "") {
	$DirCgi="";
	$QueryString = $ENV{"QUERY_STRING"};
	if ($QueryString =~ /lang=/) { $Lang=$QueryString; $Lang =~ s/.*lang=//; $Lang =~ s/&.*//; }
	}
if (($DirCgi ne "") && !($DirCgi =~ /\/$/) && !($DirCgi =~ /\\$/)) { $DirCgi .= "/"; }
if ($DirData eq "" || $DirData eq ".") { $DirData=$DIR; }	# If not defined or choosed to "." value then DirData is current dir
if ($DirData eq "")  { $DirData="."; }						# If current dir not defined them we put it to "."
$DirData =~ s/\/$//;

# Check if parameters are OK
&Check_Config;

# Init other parameters
if ($DNSLookup) { use Socket; }
$NewDNSLookup=$DNSLookup;
$LogFileWithoutLog=$LogFile;$LogFileWithoutLog =~ s/\.log$//;
%monthlib =  ( "01","$message[60][$Lang]","02","$message[61][$Lang]","03","$message[62][$Lang]","04","$message[63][$Lang]","05","$message[64][$Lang]","06","$message[65][$Lang]","07","$message[66][$Lang]","08","$message[67][$Lang]","09","$message[68][$Lang]","10","$message[69][$Lang]","11","$message[70][$Lang]","12","$message[71][$Lang]" );
# monthnum must be in english because it's used to translate log date in log files which are always in english
%monthnum =  ( "Jan","01","Feb","02","Mar","03","Apr","04","May","05","Jun","06","Jul","07","Aug","08","Sep","09","Oct","10","Nov","11","Dec","12" );

($nowsec,$nowmin,$nowmin,$nowday,$nowmonth,$nowyear,$nowwday,$nowyday,$nowisdst) = localtime(time);
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
$nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
$nowmonth++;if ($nowmonth < 10) { $nowmonth  = "0$nowmonth"; }

if ($QueryString =~ /year=[\d][\d][\d][\d]/) { $YearRequired=$QueryString; $YearRequired =~ s/.*year=//; $YearRequired =~ s/&.*//; }
if ($YearRequired eq "")  { $YearRequired=$nowyear; }
if ($QueryString =~ /month=/)                { $MonthRequired=$QueryString; $MonthRequired =~ s/.*month=//; $MonthRequired =~ s/&.*//; }
if ($MonthRequired eq "") { $MonthRequired=$nowmonth; }

$BrowsersHash{"netscape"}="<font color=blue>Netscape</font> <a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&action=browserdetail&month=$MonthRequired&lang=$Lang\">($message[58][$Lang])</a>";
$BrowsersHash{"msie"}="<font color=blue>MS Internet Explorer</font> <a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&action=browserdetail&month=$MonthRequired&lang=$Lang\">($message[58][$Lang])</a>";

if (@HostAliases == 0) {
	warning("Warning: HostAliases parameter is not defined, $PROG will choose \"$LocalSite localhost 127.0.0.1\".");
	$HostAliases[0]=$LocalSite; $HostAliases[1]="localhost"; $HostAliases[2]="127.0.0.1";
	}

$LocalSiteIsInHostAliases=0;
foreach $elem (@HostAliases) { if ($elem eq $LocalSite) { $LocalSiteIsInHostAliases=1; last; } }
if ($LocalSiteIsInHostAliases == 0) { $HostAliases[@HostAliases]=$LocalSite; }
if (@SkipFiles == 0) {
	$SkipFiles[0]="\.css";$SkipFiles[1]="\.js";$SkipFiles[2]="\.class";$SkipFiles[3]="robots\.txt";
	}
$FirstTime=0;$LastTime=0;$TotalVisits=0;$TotalHosts=0;$TotalUnique=0;$TotalDifferentPages=0;$TotalDifferentKeywords=0;$TotalKeywords=0;
for ($ix=1; $ix<=12; $ix++) {
	$monthix=$ix;if ($monthix < 10) { $monthix  = "0$monthix"; }
	$FirstTime{$monthix.$YearRequired}=0;$LastTime{$monthix.$YearRequired}=0;
	$MonthVisits{$monthix.$YearRequired}=0;$MonthUnique{$monthix.$YearRequired}=0;$MonthPage{$monthix.$YearRequired}=0;$MonthHits{$monthix.$YearRequired}=0;$MonthBytes{$monthix.$YearRequired}=0;
	}
for ($ix=0; $ix<5; $ix++) {	$_from_h[$ix]=0; }

# Print html header
if ($ENV{"GATEWAY_INTERFACE"} eq "") { &html_head; }
print "<STYLE TYPE=text/css>
<!--
	BODY { font-align: font-family: arial, verdana, helvetica, sans-serif; font-size:12px; background-color:$color_Background; }
	TD,TH { font-family: arial, verdana, helvetica, sans-serif; font-size:10px; text-align: center; }
	TD.LEFT { font-family: arial, verdana, helvetica, sans-serif; font-size:10px; text-align: left; }
	A {	font-family: arial, verdana helvetica, sans-serif; font-size:10px; font-style: normal; color: $color_link; }
	DIV { text-align: justify; }
	.TABLEBORDER { background-color:$color_TableBorder; }
	.TABLEFRAME { background-color:$color_TableBG; }
	.TABLEDATA { background-color:$color_Background; }
	.TABLETITLE { font-family: verdana, arial, helvetica, sans-serif; font-size:14px; font-weight:bold; color: $color_TableTitle; background-color:$color_TableBGTitle; }
	.classTooltip { position:absolute; top:0px; left:0px; z-index:2; width:280; visibility:hidden; font:8pt MS Comic Sans,arial,sans-serif; background-color:#FFFFE6; padding:10px 10px; border:1px solid black; }
//-->
</STYLE>\n
";
print "<a href=\"http://awstats.sourceforge.net\" target=_newawstats><img src=$DirIcons/other/$Logo border=0 alt=\"$PROG Official Web Site\" title=\"$PROG Official Web Site\"></a><br>\n";
if ($ShowFlagLinks == 1) { 
	if ($Lang != 0) { print "<a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&year=$YearRequired&month=$MonthRequired&lang=0\"><img src=\"$DirIcons\/flags\/us.png\" height=14 border=0 alt=\"English\" title=\"English\"></a>\n"; }
	if ($Lang != 1) { print " &nbsp; <a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&year=$YearRequired&month=$MonthRequired&lang=1\"><img src=\"$DirIcons\/flags\/fr.png\" height=14 border=0 alt=\"French\" title=\"French\"></a>\n"; }
	if ($Lang != 2) { print " &nbsp; <a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&year=$YearRequired&month=$MonthRequired&lang=2\"><img src=\"$DirIcons\/flags\/nl.png\" height=14 border=0 alt=\"Dutch\" title=\"Dutch\"></a>\n"; }
	if ($Lang != 3) { print " &nbsp; <a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&year=$YearRequired&month=$MonthRequired&lang=3\"><img src=\"$DirIcons\/flags\/es.png\" height=14 border=0 alt=\"Spanish\" title=\"Spanish\"></a>\n"; }
	if ($Lang != 4) { print " &nbsp; <a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&year=$YearRequired&month=$MonthRequired&lang=4\"><img src=\"$DirIcons\/flags\/it.png\" height=14 border=0 alt=\"Italian\" title=\"Italian\"></a>\n"; }
	if ($Lang != 5) { print " &nbsp; <a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&year=$YearRequired&month=$MonthRequired&lang=5\"><img src=\"$DirIcons\/flags\/de.png\" height=14 border=0 alt=\"German\" title=\"German\"></a>\n"; }
	print "<br>";
	}
print "<font size=1>$message[54][$Lang]</font><br>\n";
print "<BR><BR>\n";


# No realtime (no log processing) if not current month or full current year asked 
if (($YearRequired == $nowyear) && ($MonthRequired eq "year" || $MonthRequired == $nowmonth)) {

	#------------------------------------------
	# READING LAST PROCESSED HISTORY FILE
	#------------------------------------------

	# Search last file
	opendir(DIR,"$DirData");
	@filearray = sort readdir DIR;
	close DIR;
	$yearmonthchoosed=0;
	foreach $i (0..$#filearray) {
		if ("$filearray[$i]" =~ /^$PROG[\d][\d][\d][\d][\d][\d]$FileSuffix\.txt$/) {
			$yearmonth=$filearray[$i]; $yearmonth =~ s/^.*$PROG//; $yearmonth =~ s/\..*//;
			# Reverse year and month
			$yearfile=$yearmonth; $monthfile=$yearmonth; $yearfile =~ s/^..//; $monthfile =~ s/....$//; 
			$yearmonth="$yearfile$monthfile";
			if ($yearmonth > $yearmonthchoosed) { $yearmonthchoosed=$yearmonth; }
		}
	};

	$monthtoprocess=0;$yeartoprocess=0;
	if ($yearmonthchoosed) {
		# We found last history file
		$yeartoprocess=$yearmonthchoosed; $monthtoprocess=$yearmonthchoosed;
		$yeartoprocess =~ s/..$//; $monthtoprocess =~ s/^....//;
		# We read LastTime in this last file
		&Read_History_File($monthtoprocess,$yeartoprocess,1);
	}

	#------------------------------------------
	# PROCESSING CURRENT LOG
	#------------------------------------------
	if ($BenchMark) { print "Start of processing log file: ".time."<br>\n"; }
	# Try with $LogFile
	# If not found try $LogFile$nowsmallyear$nowmonth.log
	# If still not found, try $LogFile$nowsmallyear$nowmonth$nowday.log
	$OpenFileError=1;     if (open(LOG,"$LogFile")) { $OpenFileError=0; }
	if ($OpenFileError) { if (open(LOG,"$LogFileWithoutLog$nowsmallyear$nowmonth.log"))        { $LogFile="$LogFileWithoutLog$nowsmallyear$nowmonth.log"; $OpenFileError=0; } }
	if ($OpenFileError) { if (open(LOG,"$LogFileWithoutLog$nowsmallyear$nowmonth$nowday.log")) { $LogFile="$LogFileWithoutLog$nowsmallyear$nowmonth$nowday.log"; $OpenFileError=0; } }
	if ($OpenFileError) { error("Error: Couldn't open server log file $LogFile: $!"); }
	while (<LOG>)
	{
		# Get log line
		#-------------
		$line=$_;
		$_ =~ s/\n//;	# Needed because IIS log file end with CRLF and perl read lines until LF
		$_ =~ s/\" / /g; $_ =~ s/ \"/ /g; $_ =~ s/\"$//;	# Suppress "
		if ($LogFormat == 2) {
			if (/^#/) { next; }		# ISS writes such comments, we forget line
			@felter=split(/ /,$_);
			$savetime=$felter[1];
			@datep=split(/-/,$felter[0]);				# YYYY-MM-DD
			# Change order of ISS parameters to be like Apache
			if ($#felter == 10) {						# Log with no resolved host in it (11 fields)
				$felter[0]=$felter[2];
				$felter[11]=$felter[9];
			}
			else {										# Log with host already resolved (12 fields)
				if ($felter[9] ne "-") { $felter[0]=$felter[9]; }
				else { $felter[0]=$felter[2]; }
				$savetmp=$felter[10];
				$felter[10]=$felter[11];
				$felter[11]=$savetmp;
			}
			$felter[1]="-";
			$felter[2]=$felter[3];
			$felter[3]="[$datep[2]/$datep[1]/$datep[0]:$savetime";
			$felter[9]=$felter[7];
			$felter[7]=$felter[8];
			$felter[8]=$felter[6];
			$felter[6]=$felter[5];
			$felter[5]=$felter[4];
			$felter[4]="+0000]";
			#print "$#felter: $felter[0] $felter[1] $felter[2] $felter[3] $felter[4] $felter[5] $felter[6] $felter[7] $felter[8] $felter[9] $felter[10] $felter[11]<br>";
		}
		else {
			$_ =~ s/ GET .* .* HTTP\// GET BAD_URL HTTP\//;		# Change ' GET x y z HTTP/' into ' GET x%20y%20z HTTP/'
			@felter=split(/ /,$_);
		}
#		$felter[1]=$felter[0]; shift @felter;					# This is for test when log format is "hostname ip ...	"
	
		# Check filters (here, log is in apache combined format, even with IIS)
		#----------------------------------------------------------------------
		if ($felter[5] eq 'HEAD') { next; }				# Keep only GET, POST, OPTIONS but not HEAD
		if ($felter[11] eq "")    { next; }				# Apache sometines forget some fields, ISS sometimes write blank lines
		if ($felter[6] =~ /^RC=/) { next; }				# A strange log record we need to forget

		$felter[3] =~ s/\//:/g;
		$felter[3] =~ s/\[//;
		@dateparts=split(/:/,$felter[3]);				# Split DD:Month:YYYY:HH:MM:SS
		if ( $monthnum{$dateparts[1]} ) { $dateparts[1]=$monthnum{$dateparts[1]}; }	# Change lib month in num month if necessary
		$timeconnexion=$dateparts[2].$dateparts[1].$dateparts[0].$dateparts[3].$dateparts[4].$dateparts[5];	# YYYYMMDDHHMMSS
		# Skip if not a new line
		if ($NowNewLinePhase) {
			if ($timeconnexion < $LastTime{$monthtoprocess.$yeartoprocess}) { next; }	# Should not happen, kept in case of parasite lines
			}
		else {
			if ($timeconnexion <= $LastTime{$monthtoprocess.$yeartoprocess}) { next; }	# Already processed
			$NowNewLinePhase=1;
			}

		if (&SkipFile($felter[6])) { next; }			# Skip with some URL
		if (&SkipHost($felter[0])) { next; }			# Skip with some client host IP address


		# We found a new line. Is it in a new month section
		#----------------------------------------------------------------------
		if ((($dateparts[1] > $monthtoprocess) && ($dateparts[2] >= $yeartoprocess)) || ($dateparts[2] > $yeartoprocess)){
			# Yes, a new month to process
			if ($monthtoprocess > 0) {
				&Save_History_File($monthtoprocess,$yeartoprocess);		# We save data of old processed month
 				&Init_HashArray;										# Start init for next one
				}
			$monthtoprocess=$dateparts[1];$yeartoprocess=$dateparts[2];
			&Read_History_File($monthtoprocess,$yeartoprocess,1);
			}

		if (($felter[8] != 200) && ($felter[8] != 304)) {		# Stop if HTTP server return code != 200 and 304
			if ($felter[8] =~ /^[\d][\d][\d]$/) { 				# Keep error code
				$_errors_h{$felter[8]}++;
				if ($felter[8] == 404) { $_sider404_h{$felter[6]}++; }
				next;
				}
			print "Log file <b>$LogFile</b> doesn't seem to have good format. Suspect line is<br>";
			print "<font color=#888888><i>$line</i></font><br>";
			print "<br><b>LogFormat</b> parameter is <b>$LogFormat</b>, this means each line in your log file need to have ";
			if ($LogFormat == 2) {
					print "<b>\"MSIE Extended W3C log format\"</b> like this:<br>";
					print "<font color=#888888><i>date time c-ip c-username cs-method cs-uri-sterm sc-status cs-bytes cs-version cs(User-Agent) cs(Referer)</i></font><br>"
				}
			else {
					print "<b>\"combined log format\"</b> like this:<br>";
					print "<font color=#888888><i>62.161.78.73 - - [19/Jul/2000:02:14:14 +0200] \"GET / HTTP/1.1\" 200 1234 \"http://www.fromserver.com/from.htm\" \"Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)\"</i></font><br>";
			}
			error("<br>");
		}
	

		# Record is approved. Start of line process
		if ($LogFormat == 1) {
			# To correct bad format of some old apache log (field 10 is twice in line)
			# if ($felter[10] =~ /^$felter[11],/) { for ($ix=12; $ix<=$#felter; $ix++) { $felter[$ix-1] = $felter[$ix]; } }
			# Define $UserAgent in one string (no ' ') like "Mozilla/4.0_(compatible;_MSIE_4.01;_Windows_98)"
			for ($ix=12; $ix<=$#felter; $ix++) {
				$felter[11] .= "_"; $felter[11] .= $felter[$ix];
			}
		}
	
		$felter[11] =~ s/\+/_/g;
		$UserAgent = $felter[11];
		$UserAgent =~ tr/A-Z/a-z/;
	
		# Robot ? If yes, we stop here
		#-----------------------------
		$foundrobot=0;
		if (!$TmpHashNotRobot{$UserAgent}) {	# TmpHashNotRobot is a temporary hash table to increase speed
			foreach $bot (keys %RobotHash) { if ($UserAgent =~ /$bot/) { $_robot_h{$bot}++; $_robot_l{$bot}=$timeconnexion ; $foundrobot=1; last; }	}
			if ($foundrobot == 1) { next; }
			$TmpHashNotRobot{$UserAgent}=1;		# Last time, we won't search if robot or not. We know it's not.
		}
	
		# Canonize and clean target URL and referrer URL
		$felter[6] =~ s/\/$DefaultFile$/\//;	# Replace default page name with / only
		$felter[6] =~ s/\?.*//;					# Trunc CGI parameters in URL get
		$felter[6] =~ s/\/\//\//g;				# Because some targeted url were taped with 2 / (Ex: //rep//file.htm)
	
		# Check if page or not
		$PageBool=1;
		foreach $cursor (@NotPageList) { if ($felter[6] =~ /$cursor$/) { $PageBool=0; last; } }

		# Analyze: Date - Hour - Pages - Hits - Kilo
		#-------------------------------------------
		if ($FirstTime{$monthtoprocess.$yeartoprocess} == 0) { $FirstTime{$monthtoprocess.$yeartoprocess}=$timeconnexion; }
		$LastTime{$monthtoprocess.$yeartoprocess} = $timeconnexion;
		if ($PageBool) {
			$_time_p[$dateparts[3]]++; $MonthPage{$monthtoprocess.$yeartoprocess}++;	#Count accesses per hour (page)
			$_sider_p{$felter[6]}++; 									#Count accesses per page (page)
			}
		$_time_h[$dateparts[3]]++; $MonthHits{$monthtoprocess.$yeartoprocess}++;		#Count accesses per hour (hit)
		$_time_k[$dateparts[3]]+=$felter[9]; $MonthBytes{$monthtoprocess.$yeartoprocess}+=$felter[9];	#Count accesses per hour (kb)
		$_sider_h{$felter[6]}++;										#Count accesses per page (hit)
		$_sider_k{$felter[6]}+=$felter[9];								#Count accesses per page (kb)

		# Analyze: IP-address
		#--------------------
		$found=0;
		$Host=$felter[0];
		if ($Host =~ /^[\d]+\.[\d]+\.[\d]+\.[\d]+$/) {
			# Doing DNS lookup
		    if ($NewDNSLookup) {
				$new=$TmpHashDNSLookup{$Host};	# TmpHashDNSLookup is a temporary hash table to increase speed
				if (!$new) {		# if $new undefined, $Host not yet resolved
					if ($BenchMark) { print "Start of reverse DNS lookup for $Host: ".time."<br>\n"; }
					$new=gethostbyaddr(pack("C4",split(/\./,$Host)),AF_INET);	# This is very slow may took 20 seconds
					if ($BenchMark) { print "End of reverse DNS lookup for $Host: ".time."<br>\n"; }
					if ($new eq "") {	$new="ip"; }
					$TmpHashDNSLookup{$Host}=$new;
				}
	
				# Here $Host is still xxx.xxx.xxx.xxx and $new is name or "ip" if reverse failed)
				if ($new ne "ip") { $Host=$new; }
			}
		    # If we're not doing lookup or if it failed, we still have an IP address in $Host
		    if (!$NewDNSLookup || $new eq "ip") {
				  if ($PageBool) {
				  		if (int($timeconnexion) > int($_unknownip_l{$Host}+$VisitTimeOut)) { $MonthVisits{$monthtoprocess.$yeartoprocess}++; }
						if ($_unknownip_l{$Host} eq "") { $MonthUnique{$monthtoprocess.$yeartoprocess}++; }
						$_unknownip_l{$Host}=$timeconnexion;		# Table of (all IP if !NewDNSLookup) or (all unknown IP) else
						$_hostmachine_p{"Unknown"}++;
						$_domener_p{"ip"}++;
				  }
				  $_hostmachine_h{"Unknown"}++;
				  $_domener_h{"ip"}++;
				  $_hostmachine_k{"Unknown"}+=$felter[9];
				  $_domener_k{"ip"}+=$felter[9];
				  $found=1;
		      }
	    }
		else { $NewDNSLookup=0; }	# Hosts seems to be already resolved

		# Here, $Host = hostname or xxx.xxx.xxx.xxx
		if (!$found) {				# If not processed yet ($Host = hostname)
			$Host =~ tr/A-Z/a-z/;
			$_ = $Host;
	
			# Count hostmachine
			if (!$FullHostName) { s/^[\w\-]+\.//; };
			if ($PageBool) {
				if (int($timeconnexion) > int($_hostmachine_l{$_}+$VisitTimeOut)) { $MonthVisits{$monthtoprocess.$yeartoprocess}++; }
				if ($_hostmachine_l{$_} eq "") { $MonthUnique{$monthtoprocess.$yeartoprocess}++; }
				$_hostmachine_p{$_}++;
				$_hostmachine_l{$_}=$timeconnexion;
				}
			$_hostmachine_h{$_}++;
			$_hostmachine_k{$_}+=$felter[9];
	
			# Count top-level domain
			if (/\./) { /\.([\w]+)$/; $_=$1; };
			if ($DomainsHash{$_}) {
				 if ($PageBool) { $_domener_p{$_}++; }
				 $_domener_h{$_}++;
				 $_domener_k{$_}+=$felter[9];
				 }
			else {
				 if ($PageBool) { $_domener_p{"ip"}++; }
				 $_domener_h{"ip"}++;
				 $_domener_k{"ip"}+=$felter[9];
			}
		}
	
		# Analyze: Browser
		#-----------------
		$found=0;
	
		# IE ? (For higher speed, we start whith IE, the most often used. This avoid other tests if found)
		if ($UserAgent =~ /msie/ && !($UserAgent =~ /webtv/)) {
			$_browser_h{"msie"}++;
			$UserAgent =~ /msie_(\d)\./;  # $1 now contains major version no
			$_msiever_h[$1]++;
			$found=1;
		}
	
		# Netscape ?
		if (!$found) {
			if ($UserAgent =~ /mozilla/ && !($UserAgent =~ /compatible/)) {
		    	$_browser_h{"netscape"}++;
		    	$UserAgent =~ /\/(\d)\./;  # $1 now contains major version no
		    	$_nsver_h[$1]++;
		    	$found=1;
			}
		}
	
		# Other ?
		if (!$found) {
			foreach $key (keys %BrowsersHash) {
		    	if ($UserAgent =~ /$key/) { $_browser_h{$key}++; $found=1; last; }
			}
		}
	
		# Unknown browser ?
		if (!$found) { $_browser_h{"Unknown"}++; $_unknownrefererbrowser_l{$felter[11]}=$timeconnexion; }
	
		# Analyze: OS
		#------------
		$found=0;
		if (!$TmpHashOS{$UserAgent}) {
			# OSHash list ?
			foreach $key (keys %OSHash) {
				if ($UserAgent =~ /$key/) { $_os_h{$key}++; $found=1; $TmpHashOS{$UserAgent}=$key; last; }
			}
			# OSAlias list ?
			if (!$found) {
				foreach $key (keys %OSAlias) {
					if ($UserAgent =~ /$key/) { $_os_h{$OSAlias{$key}}++; $found=1; $TmpHashOS{$UserAgent}=$OSAlias{$key}; last; }
				}
			}
			# Unknown OS ?
			if (!$found) { $_os_h{"Unknown"}++; $_unknownreferer_l{$felter[11]}=$timeconnexion; }
		}
		else {
			$_os_h{$TmpHashOS{$UserAgent}}++;
		}
	
		# Analyze: Referrer
		#------------------
		$found=0;
	
		# Direct ?
		if ($felter[10] eq "-") { $_from_h[0]++; $found=1; }
	
		# HTML link ?
		if (!$found) {
			if ($felter[10] =~ /^http/)     {
				$internal_link=0;
				if (($felter[10] =~ /^http:\/\/www.$LocalSiteWithoutwww/i) || ($felter[10] =~ /^http:\/\/$LocalSiteWithoutwww/i)) { $internal_link=1; }
				else {
					foreach $HostAlias (@HostAliases) {
						if ($felter[10] =~ /^http:\/\/$HostAlias/) { $internal_link=1; last; }
						}
				}
	
				if ($internal_link) {
				    # Intern (This hit came from another page of the site)
				    $_from_h[4]++;
					$found=1;
				}
				else {
				    # Extern (This hit came from an external web site)
					@refurl=split(/\?/,$felter[10]);
					$refurl[0] =~ tr/A-Z/a-z/;
				    foreach $key (keys %SearchEnginesHash) {
						if ($refurl[0] =~ /$key/) {
							# This hit came from a search engine
							$_from_h[2]++;
							$_se_referrals_h{$key}++;
							# Extract keywords
							$refurl[1] =~ tr/A-Z/a-z/;
							@paramlist=split(/&/,$refurl[1]);
							foreach $param (@paramlist) {
								$keep=1;
								&UnescapeURL($param);				# Change xxx=aaa+bbb/ccc+ddd%20eee'fff into xxx=aaa bbb ccc ddd eee fff
								foreach $paramtoexclude (@WordsToCleanSearchUrl) {
									if ($param =~ /.*$paramtoexclude.*/i) { $keep=0; last; } # Not the param with search criteria
								}
								if ($keep == 0) { next; }			# Do not keep this URL parameter because is in exclude list
								# Ok. xxx=aaa bbb ccc ddd eee fff is a search parameter line
								$param =~ s/.*=//g;					# Cut chars xxx=
								@wordlist=split(/ /,$param);		# Split aaa bbb ccc ddd eee fff into a wordlist array
								foreach $word (@wordlist) {
									if ((length $word) > 2) { $_keywords{$word}++; }	# Keep word only if word length is 3 or more
								}
							}
							$found=1;
							last;
						}
					}
					if (!$found) {
						# This hit came from a site other than a search engine
						$_from_h[3]++;
						$_pagesrefs_h{$felter[10]}++;
						$found=1;
					}
				}
			}
		}
	
		# News link ?
		if (!$found) {
			if ($felter[10] =~ /^news/) {
				$_from_h[1]++;
				$found=1;
			}
		}
	
	}
	close LOG;
	if ($BenchMark) { print "End of processing log file: ".time."<br>\n"; }

	# DNSLookup warning
	if ($DNSLookup && !$NewDNSLookup) { warning("Warning: <b>$PROG</b> has detected that hosts names are already resolved in your logfile <b>$LogFile</b>.<br>\nIf this is true, you should change your setup DNSLookup=1 into DNSLookup=0 to increase $PROG speed."); }

	# Save for month $monthtoprocess
	if ($monthtoprocess) {	# If monthtoprocess is 0, it means there was no history files and we found no valid lines in log file
#		&Read_History_File($monthtoprocess,$yeartoprocess,1);	# Add full history file to data
		&Save_History_File($monthtoprocess,$yeartoprocess);		# We save data for this month
		if (($MonthRequired ne "year") && ($monthtoprocess != $MonthRequired)) { &Init_HashArray; }	# Not a desired month, so we clean data
	}

	# Archive LOG file into ARCHIVELOG
	if (($PurgeLogFile == 1) && ($ArchiveLogRecords == 1)) {
		if ($BenchMark) { print "Start of archiving log file: ".time."<br>\n"; }
		$ArchiveFileName="$DirData/${PROG}_archive$FileSuffix.log";
		open(LOG,"+<$LogFile") || error("Error: Enable to archive log records of $LogFile into $ArchiveFileName because source can't be opened for read and write: $!<br>\n");
		open(ARCHIVELOG,">>$ArchiveFileName") || error("Error: Couldn't open file $ArchiveFileName to archive current log: $!");
		while (<LOG>) {	print ARCHIVELOG $_; }
		close(ARCHIVELOG);
		chmod 438,"$ArchiveFileName";
		if ($BenchMark) { print "End of archiving log file: ".time."<br>\n"; }
	}
	else {
		open(LOG,"+<$LogFile");
	}

	# Rename all HISTORYTMP files into HISTORYTXT
	$allok=1;
	opendir(DIR,"$DirData");
	@filearray = sort readdir DIR;
	close DIR;
	foreach $i (0..$#filearray) {
		if ("$filearray[$i]" =~ /^$PROG[\d][\d][\d][\d][\d][\d]$FileSuffix\.tmp\..*$/) {
			$yearmonth=$filearray[$i]; $yearmonth =~ s/^$PROG//; $yearmonth =~ s/\..*//;
			if (-R "$DirData/$PROG$yearmonth$FileSuffix.tmp.$$") {
				if (rename("$DirData/$PROG$yearmonth$FileSuffix.tmp.$$", "$DirData/$PROG$yearmonth$FileSuffix.txt")==0) {
					$allok=0;	# At least on error in renaming working files
					last;
				}
				chmod 438,"$DirData/$PROG$yearmonth$FileSuffix.txt";
			}
		}
	}

	# Purge Log file if all renaming are ok and option is on
	if (($allok > 0) && ($PurgeLogFile == 1)) {
		truncate(LOG,0) || warning("Warning: <b>$PROG</b> couldn't purge logfile <b>$LogFile</b>.<br>\nChange your logfile permissions to allow write for your web server<br>\nor change PurgeLofFile=1 into PurgeLogFile=0 in configure file<br>\n(and think to purge sometines your logile. Launch $PROG just before this to save in $PROG history text files all informations logfile contains).");
	}
	close(LOG);

}


# Get list of all possible years
opendir(DIR,"$DirData");
@filearray = sort readdir DIR;
close DIR;
foreach $i (0..$#filearray) {
	if ("$filearray[$i]" =~ /^$PROG[\d][\d][\d][\d][\d][\d]$FileSuffix\.txt$/) {
		$yearmonth=$filearray[$i]; $yearmonth =~ s/^.*$PROG//; $yearmonth =~ s/\..*//;
		$yearfile=$yearmonth; $yearfile =~ s/^..//;
		$listofyears{$yearfile}=1;
	}
}


# Here, first part of data for all processed month (old or current) are is still in memory
# If a month was already processed, then $HistoryFileAlreadyRead{"MMYYYY"} value is 1

	
#--------------------------------------------
# READING NOW HISTORY FILES FOR REQUIRED YEAR
#--------------------------------------------

# Loop on each month files
for ($ix=12; $ix>=1; $ix--) {
	$monthix=$ix+0; if ($monthix < 10) { $monthix  = "0$monthix"; }	# Good trick to change $monthix into "MM" format
	if ($MonthRequired eq "year" || $monthix == $MonthRequired) {
		&Read_History_File($monthix,$YearRequired,1);	# Read full history file
	}
	else {
		&Read_History_File($monthix,$YearRequired,0);	# Read first part of history file
	}
}


#---------------------------------------------------------------------
# SHOW STATISTICS
#---------------------------------------------------------------------

if ($QueryString =~ /unknownip/) {
	print "<CENTER><a name=\"UNKOWNIP\"></a>";
	$tab_titre=$message[45][$Lang];
	&tab_head;
	print "<TR BGCOLOR=$color_TableBGRowTitle color=#770000><TH>$message[48][$Lang]</TH><TH>$message[9][$Lang]</TH>\n";
	@sortunknownip=sort { $SortDir*$_unknownip_l{$a} <=> $SortDir*$_unknownip_l{$b} } keys (%_unknownip_l);
	foreach $key (@sortunknownip) {
		$yearcon=substr($_unknownip_l{$key},0,4);
		$monthcon=substr($_unknownip_l{$key},4,2);
		$daycon=substr($_unknownip_l{$key},6,2);
		$hourcon=substr($_unknownip_l{$key},8,2);
		$mincon=substr($_unknownip_l{$key},10,2);
		if ($Lang == 1) { print "<tr><td>$key</td><td>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
		else { print "<tr><td>$key</td><td>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /unknownrefererbrowser/) {
	print "<CENTER><a name=\"UNKOWNREFERERBROWSER\"></a>";
	$tab_titre=$message[50][$Lang];
	&tab_head;
	print "<TR BGCOLOR=$color_TableBGRowTitle><TH CLASS=LEFT>Referer</TH><TH>$message[9][$Lang]</TH></TR>\n";
	@sortunknownrefererbrowser=sort { $SortDir*$_unknownrefererbrowser_l{$a} <=> $SortDir*$_unknownrefererbrowser_l{$b} } keys (%_unknownrefererbrowser_l);
	foreach $key (@sortunknownrefererbrowser) {
		$yearcon=substr($_unknownrefererbrowser_l{$key},0,4);
		$monthcon=substr($_unknownrefererbrowser_l{$key},4,2);
		$daycon=substr($_unknownrefererbrowser_l{$key},6,2);
		$hourcon=substr($_unknownrefererbrowser_l{$key},8,2);
		$mincon=substr($_unknownrefererbrowser_l{$key},10,2);
		if ($Lang == 1) { print "<tr><td CLASS=LEFT>$key</td><td>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
		else { print "<tr><td CLASS=LEFT>$key</td><td>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /unknownreferer/) {
	print "<CENTER><a name=\"UNKOWNREFERER\"></a>";
	$tab_titre=$message[46][$Lang];
	&tab_head;
	print "<TR BGCOLOR=$color_TableBGRowTitle><TH CLASS=LEFT>Referer</TH><TH>$message[9][$Lang]</TH></TR>\n";
	@sortunknownreferer=sort { $SortDir*$_unknownreferer_l{$a} <=> $SortDir*$_unknownreferer_l{$b} } keys (%_unknownreferer_l);
	foreach $key (@sortunknownreferer) {
		$yearcon=substr($_unknownreferer_l{$key},0,4);
		$monthcon=substr($_unknownreferer_l{$key},4,2);
		$daycon=substr($_unknownreferer_l{$key},6,2);
		$hourcon=substr($_unknownreferer_l{$key},8,2);
		$mincon=substr($_unknownreferer_l{$key},10,2);
		if ($Lang == 1) { print "<tr><td CLASS=LEFT>$key</td><td>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
		else { print "<tr><td CLASS=LEFT>$key</td><td>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /notfounderror/) {
	print "<CENTER><a name=\"NOTFOUNDERROR\"></a>";
	$tab_titre=$message[47][$Lang];
	&tab_head;
	print "<TR bgcolor=$color_TableBGRowTitle><TH CLASS=LEFT>URL</TH><TH bgcolor=$color_h>$message[49][$Lang]</TH></TR>\n";
	@sortsider404=sort { $SortDir*$_sider404_h{$a} <=> $SortDir*$_sider404_h{$b} } keys (%_sider404_h);
	foreach $key (@sortsider404) {
		print "<tr><td CLASS=LEFT>$key</td><td>$_sider404_h{$key}</td></tr>";
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /browserdetail/) {
	print "<CENTER><a name=\"BROWSERDETAIL\"></a>";

	print "<a name=\"NETSCAPE\"></a><BR>";
	$tab_titre=$message[33][$Lang]."<br><img src=\"$DirIcons/browser/netscape.png\">";
	&tab_head;
	print "<TR BGCOLOR=$color_TableBGRowTitle><TH CLASS=LEFT>Version</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
	for ($i=1; $i<=$#_nsver_h; $i++) {
		if ($_nsver_h[$i] gt 0) {
			$h=$_nsver_h[$i]; $p=int($_nsver_h[$i]/$_browser_h{"netscape"}*1000)/10; $p="$p&nbsp;%";
		}
		else {
			$h="&nbsp;"; $p="&nbsp;";
		}
		print "<TR><TD CLASS=LEFT>Mozilla/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
	}
	&tab_end;

	print "<a name=\"MSIE\"></a><BR>";
	$tab_titre=$message[34][$Lang]."<br><img src=\"$DirIcons/browser/msie.png\">";
	&tab_head;
	print "<TR BGCOLOR=$color_TableBGRowTitle><TH CLASS=LEFT>Version</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
	for ($i=1; $i<=$#_msiever_h; $i++) {
		if ($_msiever_h[$i] gt 0) {
			$h=$_msiever_h[$i]; $p=int($_msiever_h[$i]/$_browser_h{"msie"}*1000)/10; $p="$p&nbsp;%";
		}
		else {
			$h="&nbsp;"; $p="&nbsp;";
		}
		print "<TR><TD CLASS=LEFT>MSIE/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
	}
	&tab_end;

	&html_end;
	exit(0);
	}
if ($QueryString =~ /info/) {
	# Not yet available
	print "<CENTER><a name=\"INFO\"></a>";
	
	&html_end;
	exit(0);
	}

if ($BenchMark) { print "Start of sorting hash arrays: ".time."<br>\n"; }
@RobotArray=keys %RobotHash;
@SearchEnginesArray=keys %SearchEnginesHash;
@sortdomains_p=sort { $SortDir*$_domener_p{$a} <=> $SortDir*$_domener_p{$b} } keys (%_domener_p);
@sortdomains_h=sort { $SortDir*$_domener_h{$a} <=> $SortDir*$_domener_h{$b} } keys (%_domener_h);
@sortdomains_k=sort { $SortDir*$_domener_k{$a} <=> $SortDir*$_domener_k{$b} } keys (%_domener_k);
@sorthosts_p=sort { $SortDir*$_hostmachine_p{$a} <=> $SortDir*$_hostmachine_p{$b} } keys (%_hostmachine_p);
@sortsiders=sort { $SortDir*$_sider_p{$a} <=> $SortDir*$_sider_p{$b} } keys (%_sider_p);
@sortbrowsers=sort { $SortDir*$_browser_h{$a} <=> $SortDir*$_browser_h{$b} } keys (%_browser_h);
@sortos=sort { $SortDir*$_os_h{$a} <=> $SortDir*$_os_h{$b} } keys (%_os_h);
@sortsereferrals=sort { $SortDir*$_se_referrals_h{$a} <=> $SortDir*$_se_referrals_h{$b} } keys (%_se_referrals_h);
@sortpagerefs=sort { $SortDir*$_pagesrefs_h{$a} <=> $SortDir*$_pagesrefs_h{$b} } keys (%_pagesrefs_h);
@sortsearchwords=sort { $SortDir*$_keywords{$a} <=> $SortDir*$_keywords{$b} } keys (%_keywords);
@sorterrors=sort { $SortDir*$_errors_h{$a} <=> $SortDir*$_errors_h{$b} } keys (%_errors_h);
if ($BenchMark) { print "End of sorting hash arrays: ".time."<br>\n"; }

# English tooltips
if (($Lang != 1) && ($Lang != 3) && ($Lang != 6)) {
	print "
	<DIV CLASS=\"classTooltip\" ID=\"tt1\">
	A new visits is defined as each new <b>incoming visitor</b> (viewing or browsing a page) who was not connected to your site during last <b>".($VisitTimeOut/10000*60)." mn</b>.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt2\">
	Number of client hosts (<b>IP address</b>) who came to visit the site (and who viewed at least one <b>page</b>).<br>
	This data refers to the number of <b>different physical persons</b> who had reached the site in any one day.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt3\">
	Number of time a <b>page</b> of the site is <b>viewed</b> (Sum for all visitors for all visits).<br>
	This piece of data differs from \"hits\" in that it counts only HTML pages as oppose to images and other files.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt4\">
	Number of time a <b>page, image, file</b> of the site is <b>viewed</b> or <b>downloaded</b> by someone.<br>
	This piece of data is provided as a reference only, since the number of \"pages\" viewed is often prefered for marketing purposes.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt5\">
	Number of <b>kilobytes</b> downloaded by your visitors.<br>
	This piece of information refers to the amount of data downloaded by all <b>pages</b>, <b>images</b> and <b>files</b> within your site measured in KBs.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt13\">
	This program, $PROG, recognizes each access to your site after a <b>search</b> from the <b>".(@SearchEnginesArray)." most popular Internet Search Engines and Directories</b> (such as Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt14\">
	List of all <b>external pages</b> which were used to link (or eneter) to your site (Only the <b>$MaxNbOfRefererShown</b> most often used external pages are shown.\n
	Links used by the results of the search engines are excluded here because they have already been included on the previous line within this table.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt15\">
	This table shows the list of the most frequently <b>keywords</b> utilized to find your site from Internet Search Engines and Directories.
	(Keywords from the <b>".(@SearchEnginesArray)."</b> most popular Search Engines and Directories are recognized by $PROG, such as Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt16\">
	Robots (sometimes refer to Spiders) are <b>automatic computer visitors</b> used by many search engines that scan your web site to (1) index it and rank it, (2) collect statistics on Internet Web sites and/or (3) see if your site is still online.<br>
	This program, $PROG, is able to recognize up to <b>".(@RobotArray)."</b> robots</b>.
	</DIV>";

	print "
	<DIV CLASS=\"classTooltip\" ID=\"tt201\">
	No description for this error.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt202\">
	Request was understood by server but will be processed later.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt204\">
	Server has processed the request but there is no document to send.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt206\">
	Partial content.
	</DIV>

	<DIV CLASS=\"classTooltip\" ID=\"tt301\">
	Requested document was moved and is now at another address given in awnswer.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt302\">
	No description for this error.
	</DIV>

	<DIV CLASS=\"classTooltip\" ID=\"tt400\">
	Syntax error, server didn\'t understand request.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt401\">
	Tried to reach an <b>URL where a login/password pair was required</b>.<br>
	A high number within this item could mean that someone (such as a hacker) is attempting to crack, or enter into your site (hoping to enter a secured area by trying different login/password pairs, for instance).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt403\">
	Tried to reach an <b>URL not configured to be reachable, even with an login/password pair</b> (for example, an URL within a directory not defined as \"browsable\".).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt404\">
	Tried to reach a <b>non existing URL</b>. This error often means that there is an invalid link somewhere in your site or that a visitor mistyped a certain URL.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt408\">
	Server has taken a <b>too long time</b> to respond to request. It might be a CGI script so slow that server need to kill this job or a overcharged web server.
	</DIV>

	<DIV CLASS=\"classTooltip\" ID=\"tt500\">
	Internal error. This error is often caused by a CGI program that had finished abnormally (coredump for example).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt501\">
	Unknown requested action.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt502\">
	Code returned by a HTTP server that works as a proxy or gateway when a real, targeted server doesn\'t answer successfully to the client\'s request.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt503\">
	Internal server error.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt504\">
	Gateway Time-out.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt505\">
	HTTP Version Not Supported.
	</DIV>
	";
}

# French tooltips
if ($Lang == 1) {
	print "
	<DIV CLASS=\"classTooltip\" ID=\"tt1\">
	On considère une nouvelle visite pour <b>chaque arrivée</b> d un visiteur consultant une page et ne s étant pas connecté dans les dernières <b>".($VisitTimeOut/10000*60)." mn</b>.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt2\">
	Nombre de hotes (<b>adresse IP</b>) utilisés pour accéder au site (et voir au moins une <b>page</b>).<br>
	Ce chiffre reflète le nombre de <b>personnes physiques</b> différentes ayant un jour accédé au site.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt3\">
	Nombre de fois qu une <b>page</b> du site est <b>vue</b> (Cumul de tout visiteur, toute visite).<br>
	Ce compteur différe des \"hits\" car il ne comptabilise que les pages HTML et non les images ou autres fichiers.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt4\">
	Nombre de fois qu une <b>page, image, fichier</b> du site est <b>vu</b> ou <b>téléchargé</b> par un visiteur.<br>
	Ce compteur est donné à titre indicatif, le compteur \"pages\" etant préféré.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt5\">
	Nombre de <b>kilo octets</b> téléchargé lors des visites du site.<br>
	Il s agit aussi bien du volume de données du au chargement des <b>pages</b> et <b>images</b> que des <b>fichiers</b> téléchargés.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt13\">
	$PROG est capable de reconnaitre l acces au site issu d une <b>recherche</b> depuis les <b>".(@SearchEnginesArray)." moteurs de recherche Internet</b> les plus connus (Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt14\">
	Liste des <b>pages de sites externes</b> contenant un lien suivi pour accéder à ce site (Seules les <b>$MaxNbOfRefererShown</b> pages externes les plus utilisées sont affichées).\n
	Les liens issus du résultat d un moteur de recherche connu n apparaissent pas ici, car comptabilisés à part sur la ligne juste au-dessus.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt15\">
	Ce tableau offre la liste des <b>mots</b> les plus souvent utilisés pour retrouver et accéder au site depuis
	un moteur de recherche Internet (Les recherches depuis <b>".(@SearchEnginesArray)."</b> moteurs de recherche parmi les pluspopulaires sont reconnues, comme Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt16\">
	Les robots sont des <b>automates visiteurs</b> scannant le site dans le but de l indexer, d obtenir des statistiques sur les sites Web Internet ou de vérifier sa disponibilié.<br>
	$PROG reconnait <b>".(@RobotArray)."</b> robots.
	</DIV>";

	print "
	<DIV CLASS=\"classTooltip\" ID=\"tt201\">
	Contenu partiel renvoyé.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt202\">
	La requête a été enregistrée par le serveur mais sera exécutée plus tard.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt204\">
	Le serveur a traité la demande mais il n existe aucun document à renvoyer.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt206\">
	Contenu partiel renvoyé.
	</DIV>

	<DIV CLASS=\"classTooltip\" ID=\"tt301\">
	Le document réclamé a été déplacé et se trouve maintenant à une autre adresse mentionnée dans la réponse.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt302\">
	Aucun descriptif pour cette erreur.
	</DIV>

	<DIV CLASS=\"classTooltip\" ID=\"tt400\">
	Erreur de syntaxe, le serveur n a pas compris la requête.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt401\">
	Tentatives d accès à une <b>URL nécessitant identification avec un login/mot de passe invalide</b>.<br>
	Un nombre trop élévé peut mettre en évidence une tentative de crackage brute du site (par accès répété de différents logins/mots de passe).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt403\">
	Tentatives d accès à une <b>URL non configurée pour etre accessible, même avec une identification</b> (par exemple, une URL d un répertoire non défini comme étant \"listable\").
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt404\">
	Tentatives d accès à une <b>URL inexistante</b>. Il s agit donc d un lien invalide sur le site ou d une faute de frappe d un visiteur qui a saisie une mauvaise URL directement.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt408\">
	Le serveur mis un <b>temps trop important</b> pour répondre à la requête. Il peut s agir d un script CGI trop lent sur le serveur forcé d abandonner le traitement ou d une saturation du site.
	</DIV>

	<DIV CLASS=\"classTooltip\" ID=\"tt500\">
	Erreur interne au serveur. Cette erreur est le plus souvant renvoyé lors de l arrêt anormal d un script CGI (par exemple suite à un coredump du CGI).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt501\">
	Le serveur ne prend pas en charge l action demandée.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt502\">
	Code renvoyé par un serveur HTTP qui fonctionne comme proxy ou gateway lorsque le serveur réel consulté ne réagit pas avec succès à la demande du client.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt503\">
	Erreur interne au serveur.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt504\">
	Gateway Time-out.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt505\">
	Version HTTP non supporté.
	</DIV>
	";
}

# Spanish tooltips
if ($Lang == 3) {
	print "
	<DIV CLASS=\"classTooltip\" ID=\"tt1\">
	Se considera un nueva vista por <b>cada nuevo visitante</b> que consulte una página y que no haya accesado el sitio en los últimos <b>".($VisitTimeOut/10000*60)." mins.</b>.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt2\">
	Número de Servidores (<b>direcciones IP</b>) que entran a un sitio (y que por lo menos visitan una <b>página</b>).<br>
	Esta cifra refleja el número de <b>personas físicas diferentes</b> que hayan accesado al sitio en un día.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt3\">
	Número de ocasiones que una <b>página</b> del sitio ha sido <b>vista</b> (La suma de todos los visitantes incluyendo múltiples visitas).<br>
	Este contador se distingue de \"hits\" porque cuenta sólo las páginas HTML y no los gráficos u otros archivos o ficheros.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt4\">
	El número de ocasiones que una <b>página, imagen, archivo o fichero</b> de un sitio es <b>visto</b> o <b>descargado</b> por un visitante.<br>
	Este contador sirve de referencia, pero el contador de \"páginas\" representa un dato mercadotécnico generalmente más útil y por lo tanto se recomienda.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt5\">
	El número de <b>kilo bytes</b> descargados por los visitantes del sitio.<br>
	Se refiere al volumen de datos descargados por todas las <b>páginas</b>, <b>imágenes</b> y <b>archivos o ficheros</b> medidos en kilo bytes.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt13\">
	El programa $PROG es capaz de reconocer una visita a su sitio luego de cada <b>búsqueda</b> desde cualquiera de los <b>".(@SearchEnginesArray)." motores de búsqueda y directorios Internet</b> más populares (Yahoo, Altavista, Lycos, Google, Terra, etc...).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt14\">
	Lista de <b>páginas de sitios externos</b> utilizadas para acceder o enlazarse con su sitio (Sólo las <b>$MaxNbOfRefererShown</b> páginas más utilizadas se encuentras enumeradas).\n
	Los enlaces utilizados por los motores de búsqueda o directorios son excluidos porque ya han sido contabilizados en el rubro anterior.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt15\">
	Esta tabla muestra la lista de las <b>palabras clave</b> más utilizadas en los motores de búsqueda y directorios Internet para encontrar su sitio.
	(El programa $PROG reconoce palabras clave usadas en los <b>".(@SearchEnginesArray)."</b> motores de búsqueda más populares, tales como Yahoo, Altavista, Lycos, Google, Voila, Terra etc...).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt16\">
	Los Robots son <b>visitantes automáticos</b> que escanean o viajan por su sitio para indexarlo, o jerarquizarlo, para recopilar estadísticas de sitios Web, o para verificar si su sitio se encuentra conectado a la Red.<br>
	El programa $PROG reconoce hasta <b>".(@RobotArray)."</b> robots.
	</DIV>";

	print "
	<DIV CLASS=\"classTooltip\" ID=\"tt201\">
	Error sin descripción.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt202\">
	La solicitud ha sido computada pero el servidor la procesará más tarde.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt204\">
	El servidor ha procesado la solicitud pero no existen documentos para enviar.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt206\">
	Contenido parcial.
	</DIV>

	<DIV CLASS=\"classTooltip\" ID=\"tt301\">
	El documento solicitado ha sido reubicado y se encuentra en un URL proporcionado en la misma respuesta.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt302\">
	Error sin descripción.
	</DIV>

	<DIV CLASS=\"classTooltip\" ID=\"tt400\">
	Error de sintaxis, el servidor no ha comprendido su solicitud.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt401\">
	Número de intentos por acceder un <b>URL que exige una combinación usuario/contraseña que ha sido invalida.</b>.<br>
	Un número de intentos muy elevado pudiera sugerir la posibilidad de que un hacker (o pirata) ha intentado entrar a una zona restringida del sitio (p.e., intentando múltiples combinaciones de usuario/contraseña).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt403\">
	Número de intentos por acceder un <b>URL configurado para no ser accesible, aún con una combinación usuario/contraseña</b> (p.e., un URL previamente definido como \"no navegable\").
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt404\">
	Número de intentos por acceder un <b>URL inexistente</b>. Frecuentemente, éstos se refieren ya sea a un enlace (link) inválido o a un error mecanográfico cuando el visitante tecleó el URL equivocado.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt408\">
	El servidor ha tomado <b>demasiado tiempo</b> para responder a una solicitud. Frecuentemente se debe ya sea a un programa CGI muy lento, el cual tuvo que ser abandonado por el servidor, o bien por un servidor sobre-saturado.
	</DIV>

	<DIV CLASS=\"classTooltip\" ID=\"tt500\">
	Error interno. Este error generalmente es causado por una terminación anormal o prematura de un programa CGI (p.e., un CGI corrompido o dañado).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt501\">
	Solicitud desconocida por el servidor.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt502\">
	Código retornado por un servidor de protocolo HTTP el cual funge como proxy o puente (gateway) cuando el servidor objetivo no funciona o no interpreta adecuadamente la solicitud del cliente (o visitante).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt503\">
	Error interno del servidor.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt504\">
	Gateway time-out.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt505\">
	Versión de protocolo HTTP no soportada.
	</DIV>
	";
}

# Polish tooltips
if ($Lang == 6) {
	print "
	<DIV CLASS=\"classTooltip\" ID=\"tt1\">
	Wizyty ka¿dego <b>nowego go¶cia</b>, który ogl±da³ stronê i nie ³±czy³ siê z ni± przez ostatnie <b>".($VisitTimeOut/10000*60)." mn</b>.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt2\">
	Adres numeryczny hosta klienta (<b>tzw. adres IP</b>) odwiedzaj±cego tê stronê.<br>
	Ten numer mo¿e byæ identyczny dla <B>kilku ró¿nych Internautów</B> którzy odwiedzili stronê tego samego dnia.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt3\">
	¦rednia liczba obejrzanych <B>stron</B> przypadaj±ca na jednego Internautê. (Suma go¶ci, wszystkich wizyt).<br>
	Ten licznik ró¿ni siê od kolumny z prawej, gdy¿ zlicza on tylko strony html (bez obrazków i innych plików).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt4\">
	Liczba wszystkich <b>stron, obrazków, d¼wiêków, plików</b>, które zosta³y <b>obejrzane</b> lub <b>¶ci±gniête</b> przez kogo¶.<br>
	Warto¶æ jest jedynie orientacyjna, zaleca siê spogl±daæ na licznik \"strony\".
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt5\">
	Liczba <b>kilobajtów</b> ¶ci±gniêtych przez Internautów.<br>
	Jest to suma wszystkich ¶ci±gniêtych danych <B>(strony html, obrazki, d¼wiêki)</B>.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt13\">
	$PROG rozró¿nia dostêp do stron <b>z wyszukiwarek</b> dziêki <b>".(@SearchEnginesArray)." najpopularniejszym przegl±darkom internetowym</b> (Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt14\">
	Lista wszystkich <b>stron spoza serwera</b> z których trafiono na ten serwer (wy¶wietlanych jest <b>$MaxNbOfRefererShown</b> stron z których najczê¶ciej siê odwo³ywano.\n
	Odwo³ania z wyszukiwarek internetowych nie bêd± wy¶wietlone, poniewa¿ istnieje dla nich oddzielne zestawenie pokazane poni¿ej).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt15\">
	Ta kolumna pokazuje listê najczê¶ciej u¿ywanych <b>s³ów kluczowych</b>, dziêki którym znaleziono t± stronê w wyszukiwarkach.
	($PROG rozró¿nia zapytania s³ów kluczowych z <b>".(@SearchEnginesArray)."</b> najpopularniejszych wyszukiwarek, takich jak Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt16\">
	Roboty s± <b>programami sieciowymi</b> skanuj±cymi strony w celu zebrania/aktualizacji danych (np. s³owa kluczowe do wyszukiwarek), lub sprawdzaj±cymi czy strona nadal istnieje w sieci.<br>
	$PROG rozró¿nia obecnie <b>".(@RobotArray)."</b> robów</b>.
	</DIV>";
	
	print "
	<DIV CLASS=\"classTooltip\" ID=\"tt201\"> Zlecenie POST zosta³o zrealizowane pomy¶lnie. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt202\"> ¯±danie zosta³o odebrane poprawnie, lecz jeszcze siê nie zakoñczy³o. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt203\"> Zwrócona informacja na temat obiektu jest nieaktualna. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt204\"> Serwer przetworzy³ ¿±danie, lecz nie posiada ¿adnych danych do wys³ania. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt206\"> Czê¶ciowa zawarto¶æ.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt301\"> Dokument zosta³ przeniesiony pod inny adres.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt302\"> Dokument zosta³ czasowo przeniesiony pod iiny adres.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt303\"> W celu pobrania dokumentu konieczne jest sprawdzenie innego URL-a. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt400\"> Zlecenie by³o b³êdne, lub niemo¿liwe do zrealizowania przez serwer.<BR>B³±d powstaje wtedy, kiedy serwer WWW otrzymuje do wykonania instrukcjê, której nie rozumie.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt401\"> B³±d autoryzacji. Strona wymaga podania has³a i loginu - b³±d pokazuje siê wtedy, gdy które¶ z tych danych siê nie zgadza lub zosta³y podane niew³a¶ciwiwe.<BR>Je¶li liczba ta jest du¿a, jest to sygna³ dla webmastera, i¿ kto¶ próbuje z³amaæ has³o do strony nim zabezpieczonej.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt403\"> Spróbuj reach an <b>URL not configured to be reachable, even with an identification</b> (dla przyk³±du, kiedy URL odnosi siê do katalogu który nie zosta³ zdefiniowany jako udostêpniony do przegl±dania - np. cgi-bin).</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt404\"> Spróbuj wpisaæ <b>nie istniej±cy adres URL</b> (np. adres tej strony ze skasowan± jedn± literk±). Znaczy to, ¿e posiadasz gdzie¶ na swoich stronach b³êdny link, lub link odnosz±cy siê do nieistniej±cej strony.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt405\"> Metoda wskazana w <B>nag³ówku ¿±dania</B> jest niedozwolona przy odnoszeniu siê do zasobu, na który wskazuje. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt406\"> Zasób identyfikowany przez ¿±danie jest generuje odpowiedzi zawieraj±ce charakterystyczn± zawarto¶æ nie akceptowaln± wed³ug nag³ówka ¿±dania. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt407\"> Kod podobny do Error 401 (brak autoryzacji), lecz nakazuje on, i¿ musisz dokonaæ wpierw <B>autoryzacji na serwerze proxy</B> (serwer proxy wysy³a wtedy do strony nag³ówek <B>Proxy-Authentificate</B>, dziêki któremu autoryzacja jest mo¿liwa). </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt408\"> Przegl±darka nie wys³a³a ¿±dañ do serwera w czasie jego oczekiwania. Mo¿esz powtórzyæ ¿±danie bez jego modyfikacji w czasie pó¼niejszym. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt409\"> ¯±danie nie mog³o zostaæ spe³nione, poniewa¿ wyst±pi³ konflikt stanu ¿±danego obiektu. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt410\"> Dosyæ ciekawy b³±d - jeszcze siê z nim nie spotka³em. B³±d jest wy¶wietlany, gdy <B>trwale uzuniêto stronê</B> i jej autorzy chc± o tym fakcie poinformowaæ (zazwyczaj praktykuje siê kasacjê konta bez uprzedzenia :). Oznacza to, i¿ inni webmasterzy powinni usun±æ na swoich stronach odwo³ania do strony z Error410. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt411\"> Serwer odrzuci³ ¿adanie poniewa¿ nie zawiera³o ono nag³ówka <B>Content-Length</B>. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt412\"> Jeden lub wiêcej <B>warunków</B> przes³anych w <b>nag³ówku ¿±dania</b> nie spe³ni³ warunków i zosta³ odrzucony (np. gdy wa¿no¶æ strony okre¶lona w nag³ówku <B>Expiration</B> wygas³a). </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt413\"> Serwer odrzuci³ ¿±danie poniewa¿ dane wejsciowe s± zbyt du¿e ni¿ mo¿na je obs³u¿yæ (np. przy próbie wys³ania przez formularz pliku o du¿ej objêto¶ci). Serwer zakoñczy po³±czenie w celu ochrony klienta.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt414\"> Serwer odrzuci³ ¿±danie, poniewa¿ <B>URI</B> zasobu jest d³u¿sze ni¿ serwer mo¿e zinterpretowaæ.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt415\"> Serwer odrzuci³ ¿±danie, poniewa¿ ¿±danie jest w formacie nie obs³ugiwanym przez serwer.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt408\"> Serwer czeka³ <b>zbyt d³ugo</b> na odpowied¼. Prawdopodobnie skrypt CGI pracuje zbyt wolno (ma za du¿o danych do przetworzenia). </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt500\"> B³±d wewnêtrzny. Ten b³±d czêsto pojawia siê, gdy aplikacja CGI nie zakoñczy³a siê normalnie (podobno ka¿dy program zawiera przynajmniej jeden b³±d...:-). </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt501\"> Serwer nie umo¿liwia obs³ugi mechanizmu. </DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt502\"> Serwer jest chwilowo przeci±¿ony i nie mo¿e obs³u¿yæ zlecenia.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt503\"> Serwer zdecydowa³ siê przerwaæ oczekiwanie na inny zasób lub us³ugê, i z tego powodu nie móg³ obs³u¿yæ zlecenia.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt504\"> Serwer docelowy nie otrzyma³ odpowiedzi od serwera proxy, lub bramki.</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt505\"> Nie obs³ugiwana wesja protoko³u HTTP. </DIV>
	";
	}


print "
<SCRIPT JavaScript>
	function ShowTooltip(fArg)
	{
		var tooltipOBJ = eval(\"document.all['tt\" + fArg + \"']\");
		var tooltipOffsetTop = tooltipOBJ.scrollHeight + 35;
		var testTop = (document.body.scrollTop + event.clientY) - tooltipOffsetTop;
		var testLeft = event.clientX - 310;
		var tooltipAbsLft = (testLeft < 0) ? 10 : testLeft;
		var tooltipAbsTop = (testTop < document.body.scrollTop) ? document.body.scrollTop + 10 : testTop;
		tooltipOBJ.style.posLeft = tooltipAbsLft; tooltipOBJ.style.posTop = tooltipAbsTop;
		tooltipOBJ.style.visibility = \"visible\";
	}
	function HideTooltip(fArg)
	{
		var tooltipOBJ = eval(\"document.all['tt\" + fArg + \"']\");
		tooltipOBJ.style.visibility = \"hidden\";
	}
</SCRIPT>

";


# SUMMARY
#---------------------------------------------------------------------
print "<CENTER><a name=\"SUMMARY\"></a><BR>";
$tab_titre="$message[7][$Lang] $LocalSite";
&tab_head;

# FirstTime LastTime TotalVisits
$beginmonth=$MonthRequired;$endmonth=$MonthRequired;
if ($MonthRequired eq "year") { $beginmonth=1;$endmonth=12; }
for ($monthix=$beginmonth; $monthix<=$endmonth; $monthix++) {
	$monthix=$monthix+0; if ($monthix < 10) { $monthix  = "0$monthix"; }	# Good trick to change $month into "MM" format
	if ($FirstTime{$monthix.$YearRequired} > 0 && ($FirstTime == 0 || $FirstTime > $FirstTime{$monthix.$YearRequired})) { $FirstTime = $FirstTime{$monthix.$YearRequired}; }
	if ($LastTime  < $LastTime{$monthix.$YearRequired}) { $LastTime = $LastTime{$monthix.$YearRequired}; }
	$TotalVisits+=$MonthVisits{$monthix.$YearRequired};
}
# TotalUnique TotalHosts
foreach $key (keys %_hostmachine_p) { if ($key ne "Unknown") { if ($_hostmachine_p{$key} > 0) { $TotalUnique++; }; $TotalHosts++; } }
foreach $key (keys %_unknownip_l) { $TotalUnique++; $TotalHosts++; }		# TODO: Put + @xxx instead of foreach
# TotalDifferentPages
$TotalDifferentPages=@sortsiders;
# TotalPages TotalHits TotalBytes
for ($ix=0; $ix<=23; $ix++) { $TotalPages+=$_time_p[$ix]; $TotalHits+=$_time_h[$ix]; $TotalBytes+=$_time_k[$ix]; }
# TotalDifferentKeywords
$TotalDifferentKeywords=@sortsearchwords;
# TotalKeywords
foreach $key (keys %_keywords) { $TotalKeywords+=$_keywords{$key}; }
# TotalErrors
foreach $key (keys %_errors_h) { $TotalErrors+=$_errors_h{$key}; }
# Ratio
if ($TotalUnique > 0) { $RatioHosts=int($TotalVisits/$TotalUnique*100)/100; }
if ($TotalVisits > 0) { $RatioPages=int($TotalPages/$TotalVisits*100)/100; }
if ($TotalVisits > 0) { $RatioHits=int($TotalHits/$TotalVisits*100)/100; }
if ($TotalVisits > 0) { $RatioBytes=int(($TotalBytes/1024)*100/$TotalVisits)/100; }

print "<TR><TD><b>$message[8][$Lang]</b></TD>";
if ($MonthRequired eq "year") { print "<TD colspan=3 rowspan=2><font style=\"font: 10pt arial,verdana,helvetica\"><b>$message[6][$Lang] $YearRequired</b></font><br>"; }
else { print "<TD colspan=3 rowspan=2><font style=\"font: 10pt arial,verdana,helvetica\"><b>$message[5][$Lang] $monthlib{$MonthRequired} $YearRequired</b></font><br>"; }
# Show links for possible years
foreach $key (keys %listofyears) {
	print "<a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&year=$key&month=year&lang=$Lang\">$message[6][$Lang] $key</a> ";
}
print "</TD>";
print "<TD><b>$message[9][$Lang]</b></TD></TR>";

$yearcon=substr($FirstTime,0,4);$monthcon=substr($FirstTime,4,2);$daycon=substr($FirstTime,6,2);$hourcon=substr($FirstTime,8,2);$mincon=substr($FirstTime,10,2);
if ($FirstTime != 0) { print "<TR><TD>$daycon&nbsp;$monthlib{$monthcon}&nbsp;$yearcon&nbsp;-&nbsp;$hourcon:$mincon</TD>"; }
else { print "<TR><TD>NA</TD>"; }
$yearcon=substr($LastTime,0,4);$monthcon=substr($LastTime,4,2);$daycon=substr($LastTime,6,2);$hourcon=substr($LastTime,8,2);$mincon=substr($LastTime,10,2);
if ($LastTime != 0) { print "<TD>$daycon&nbsp;$monthlib{$monthcon}&nbsp;$yearcon&nbsp;-&nbsp;$hourcon:$mincon</TD></TR>"; }
else { print "<TD>NA</TD></TR>\n"; }
print "<TR>";
print "<TD width=20% bgcolor=$color_v onmouseover=\"ShowTooltip(1);\" onmouseout=\"HideTooltip(1);\">$message[10][$Lang]</TD>";
print "<TD width=20% bgcolor=$color_w onmouseover=\"ShowTooltip(2);\" onmouseout=\"HideTooltip(2);\">$message[11][$Lang]</TD>";
print "<TD width=20% bgcolor=$color_p onmouseover=\"ShowTooltip(3);\" onmouseout=\"HideTooltip(3);\">$message[56][$Lang]</TD>";
print "<TD width=20% bgcolor=$color_h onmouseover=\"ShowTooltip(4);\" onmouseout=\"HideTooltip(4);\">$message[57][$Lang]</TD>";
print "<TD width=20% bgcolor=$color_k onmouseover=\"ShowTooltip(5);\" onmouseout=\"HideTooltip(5);\">$message[44][$Lang]</TD></TR>";
$kilo=int($TotalBytes/1024*100)/100;
print "<TR><TD><b>$TotalVisits</b><br>&nbsp;</TD><TD><b>$TotalUnique</b><br>($RatioHosts&nbsp;$message[52][$Lang])</TD><TD><b>$TotalPages</b><br>($RatioPages&nbsp;".lc $message[56][$Lang]."/".lc $message[12][$Lang].")</TD>";
print "<TD><b>$TotalHits</b><br>($RatioHits&nbsp;".lc $message[57][$Lang]."/".lc $message[12][$Lang].")</TD><TD><b>$kilo $message[44][$Lang]</b><br>($RatioBytes&nbsp;$message[44][$Lang]/".lc $message[12][$Lang].")</TD></TR>\n";
print "<TR valign=bottom><TD colspan=5>";
print "<TABLE>";
print "<TR valign=bottom>";
$max_v=1;$max_p=1;$max_h=1;$max_k=1;
for ($ix=1; $ix<=12; $ix++) {
	$monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
	if ($MonthVisits{$monthix.$YearRequired} > $max_v) { $max_v=$MonthVisits{$monthix.$YearRequired}; }
	if ($MonthUnique{$monthix.$YearRequired} > $max_v) { $max_v=$MonthUnique{$monthix.$YearRequired}; }
	if ($MonthPage{$monthix.$YearRequired} > $max_p)   { $max_p=$MonthPage{$monthix.$YearRequired}; }
	if ($MonthHits{$monthix.$YearRequired} > $max_h)   { $max_h=$MonthHits{$monthix.$YearRequired}; }
	if ($MonthBytes{$monthix.$YearRequired} > $max_k)  { $max_k=$MonthBytes{$monthix.$YearRequired}; }
}
for ($ix=1; $ix<=12; $ix++) {
	$monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
	$bredde_v=$MonthVisits{$monthix.$YearRequired}/$max_v*$BarHeight/2;
	$bredde_u=$MonthUnique{$monthix.$YearRequired}/$max_v*$BarHeight/2;
	$bredde_p=$MonthPage{$monthix.$YearRequired}/$max_h*$BarHeight/2;
	$bredde_h=$MonthHits{$monthix.$YearRequired}/$max_h*$BarHeight/2;
	$bredde_k=$MonthBytes{$monthix.$YearRequired}/$max_k*$BarHeight/2;
	$kilo=int(($MonthBytes{$monthix.$YearRequired}/1024)*100)/100;
	print "<TD>";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=8 ALT=\"$message[10][$Lang]: $MonthVisits{$monthix.$YearRequired}\" title=\"$message[10][$Lang]: $MonthVisits{$monthix.$YearRequired}\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_u\" HEIGHT=$bredde_u WIDTH=8 ALT=\"$message[18][$Lang]: $MonthUnique{$monthix.$YearRequired}\" title=\"$message[18][$Lang]: $MonthUnique{$monthix.$YearRequired}\">";
	print "&nbsp;";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=8 ALT=\"$message[56][$Lang]: $MonthPage{$monthix.$YearRequired}\" title=\"$message[56][$Lang]: $MonthPage{$monthix.$YearRequired}\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=8 ALT=\"$message[57][$Lang]: $MonthHits{$monthix.$YearRequired}\" title=\"$message[57][$Lang]: $MonthHits{$monthix.$YearRequired}\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=8 ALT=\"$message[44][$Lang]: $kilo\" title=\"$message[44][$Lang]: $kilo\">";
	print "</TD>\n";
}

print "</TR><TR>";
for ($ix=1; $ix<=12; $ix++) {
	$monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
	print "<TD valign=center><a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&year=$YearRequired&month=$monthix&lang=$Lang\">$monthlib{$monthix}</a></TD>";
}

print "</TR></TABLE>";
print "</TD></TR>";
&tab_end;


# MENU
#---------------------------------------------------------------------
print "<CENTER><a name=\"MENU\"></a><BR>";

print "<table><tr><td>";
print " <a href=\"#DOMAINS\"><font size=1>[$message[17][$Lang]]</font></a> &nbsp;";
print " <a href=\"#VISITOR\"><font size=1>[$message[18][$Lang]]</font></a> &nbsp;";
print " <a href=\"#ROBOTS\"><font size=1>[$message[53][$Lang]]</font></a> &nbsp;";
print " <a href=\"#PAGE\"><font size=1>[$message[19][$Lang]]</font></a> &nbsp;";
print " <a href=\"#HOUR\"><font size=1>[$message[20][$Lang]]</font></a> &nbsp;";
print " <a href=\"#BROWSER\"><font size=1>[$message[21][$Lang]]</font></a> &nbsp;";
print " <a href=\"#REFERER\"><font size=1>[$message[23][$Lang]]</font></a> &nbsp;";
print " <a href=\"#SEARCHWORDS\"><font size=1>[$message[24][$Lang]]</font></a> &nbsp;";
print " <a href=\"#ERRORS\"><font size=1>[$message[22][$Lang]]</font></a> &nbsp;";
print "</td></tr></table>\n";

print "<br><hr width=96%>\n\n";


# BY COUNTRY/DOMAIN
#---------------------------
print "<CENTER><a name=\"DOMAINS\"></a><BR>";
$tab_titre="$message[25][$Lang]";
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle><TH colspan=2>$message[17][$Lang]</TH><TH>Code</TH><TH bgcolor=$color_p>$message[56][$Lang]</TH><TH bgcolor=$color_h>$message[57][$Lang]</TH><TH bgcolor=$color_k>$message[44][$Lang]</TH><TH>&nbsp;</TH></TR>\n";
if ($SortDir<0) { $max_h=$_domener_h{$sortdomains_h[0]}; }
else            { $max_h=$_domener_h{$sortdomains_h[$#sortdomains_h]}; }
if ($SortDir<0) { $max_k=$_domener_k{$sortdomains_k[0]}; }
else            { $max_k=$_domener_k{$sortdomains_k[$#sortdomains_k]}; }
foreach $key (@sortdomains_p) {
	if ($max_h > 0) { $bredde_p=$BarWidth*$_domener_p{$key}/$max_h+1; }	# use max_h to enable to compare pages with hits
	if ($max_h > 0) { $bredde_h=$BarWidth*$_domener_h{$key}/$max_h+1; }
	if ($max_k > 0) { $bredde_k=$BarWidth*$_domener_k{$key}/$max_k+1; }
	$kilo=int(($_domener_k{$key}/1024)*100)/100;
	if ($key eq "ip") {
		print "<TR><TD><IMG SRC=\"$DirIcons\/flags\/$key.png\" height=14></TD><TD CLASS=LEFT>$message[0][$Lang]</TD><TD>$key</TD>";
	}
	else {
		print "<TR><TD><IMG SRC=\"$DirIcons\/flags\/$key.png\" height=14></TD><TD CLASS=LEFT>$DomainsHash{$key}</TD><TD>$key</TD>";
	}
	print "<TD>$_domener_p{$key}</TD><TD>$_domener_h{$key}</TD><TD>$kilo</TD>";
	print "<TD CLASS=LEFT>";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"$message[56][$Lang]: $_domener_p{$key}\" title=\"$message[56][$Lang]: $_domener_p{$key}\"><br>\n";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 ALT=\"$message[57][$Lang]: $_domener_h{$key}\" title=\"$message[57][$Lang]: $_domener_h{$key}\"><br>\n";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$message[44][$Lang]: $kilo\" title=\"$message[44][$Lang]: $kilo\">";
	print "</TD></TR>\n";
}
&tab_end;


# BY HOST/VISITOR
#--------------------------
print "<CENTER><a name=\"VISITOR\"></a><BR>";
$tab_titre="TOP $MaxNbOfHostsShown $message[55][$Lang] $TotalHosts $message[26][$Lang] ($TotalUnique $message[11][$Lang])";
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle><TH CLASS=LEFT>$message[18][$Lang]</TH><TH bgcolor=$color_p>$message[56][$Lang]</TH><TH bgcolor=$color_h>$message[57][$Lang]</TH><TH bgcolor=$color_k>$message[44][$Lang]</TH><TH>$message[9][$Lang]</TH></TR>\n";
$count=0;$total_p=0;$total_h=0;$total_k=0;
foreach $key (@sorthosts_p)
{
  if ($_hostmachine_h{$key}>=$MinHitHost) {
    $kilo=int(($_hostmachine_k{$key}/1024)*100)/100;
	if ($key eq "Unknown") {
		print "<TR><TD CLASS=LEFT><a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&action=unknownip&month=$MonthRequired&lang=$Lang\">$message[1][$Lang]</a></TD><TD>$_hostmachine_p{$key}</TD><TD>$_hostmachine_h{$key}</TD><TD>$kilo</TD><TD><a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&action=unknownip&month=$MonthRequired&lang=$Lang\">$message[3][$Lang]</a></TD></TR>\n";
		}
	else {
		$yearcon=substr($_hostmachine_l{$key},0,4);
		$monthcon=substr($_hostmachine_l{$key},4,2);
		$daycon=substr($_hostmachine_l{$key},6,2);
		$hourcon=substr($_hostmachine_l{$key},8,2);
		$mincon=substr($_hostmachine_l{$key},10,2);
		print "<tr><td CLASS=LEFT>$key</td><TD>$_hostmachine_p{$key}</TD><TD>$_hostmachine_h{$key}</TD><TD>$kilo</TD>";
		if ($daycon ne "") {
			if ($Lang != 0) { print "<td>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
			else { print "<td>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
		}
		else {
			print "<td>-</td>";
		}
	}

    $total_p += $_hostmachine_p{$key};
    $total_h += $_hostmachine_h{$key};
    $total_k += $_hostmachine_k{$key};
  }
  $count++;
  if (!(($SortDir<0 && $count<$MaxNbOfHostsShown) || ($SortDir>0 && $#sorthosts_p-$MaxNbOfHostsShown < $count))) { last; }
}
$rest_p=$TotalPages-$total_p;
$rest_h=$TotalHits-$total_h;
$rest_k=int((($TotalBytes-$total_k)/1024)*100)/100;
if ($rest_p > 0) { print "<TR><TD CLASS=LEFT><font color=blue>$message[2][$Lang]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>$rest_k</TD><TD>&nbsp;</TD></TR>\n"; }	# All other visitors (known or not)
&tab_end;


# BY ROBOTS
#----------------------------
print "<CENTER><a name=\"ROBOTS\"></a><BR>";
$tab_titre=$message[53][$Lang];
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle onmouseover=\"ShowTooltip(16);\" onmouseout=\"HideTooltip(16);\"><TH CLASS=LEFT>Robot</TH><TH bgcolor=$color_h width=80>Hits</TH><TH>$message[9][$Lang]</TH></TR>\n";
@sortrobot=sort { $SortDir*$_robot_h{$a} <=> $SortDir*$_robot_h{$b} } keys (%_robot_h);
foreach $key (@sortrobot) {
	$yearcon=substr($_robot_l{$key},0,4);
	$monthcon=substr($_robot_l{$key},4,2);
	$daycon=substr($_robot_l{$key},6,2);
	$hourcon=substr($_robot_l{$key},8,2);
	$mincon=substr($_robot_l{$key},10,2);
	if ($Lang != 0) { print "<tr><td CLASS=LEFT>$RobotHash{$key}</td><td>$_robot_h{$key}</td><td>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
	else { print "<tr><td CLASS=LEFT>$RobotHash{$key}</td><td>$_robot_h{$key}</td><td>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
}
&tab_end;


# BY PAGE
#-------------------------
print "<CENTER><a name=\"PAGE\"></a><BR>";
$tab_titre="TOP $MaxNbOfPageShown $message[55][$Lang] $TotalDifferentPages $message[27][$Lang]";
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle><TH CLASS=LEFT>Page-URL</TH><TH bgcolor=$color_p>&nbsp;$message[29][$Lang]&nbsp;</TH><TH>&nbsp;</TH></TR>\n";
if ($SortDir<0) { $max=$_sider_p{$sortsiders[0]}; }
else            { $max=$_sider_p{$sortsiders[$#sortsiders]}; }
$count=0;
foreach $key (@sortsiders) {
	if ((($SortDir<0 && $count<$MaxNbOfPageShown) || ($SortDir>0 && $#sortsiders-$MaxNbOfPageShown<$count)) && $_sider_p{$key}>=$MinHitFile) {
    	print "<TR><TD CLASS=LEFT>";
		$nompage=$Aliases{$key};
		if ($nompage eq "") { $nompage=$key; }
		$nompage=substr($nompage,0,$MaxLengthOfURL);
	    if ($ShowLinksOnUrl) { print "<A HREF=\"$key\">$nompage</A>"; }
	    else              	 { print "$nompage"; }
	    $bredde=$BarWidth*$_sider_p{$key}/$max+1;
		print "</TD><TD>$_sider_p{$key}</TD><TD CLASS=LEFT><IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde HEIGHT=8 ALT=\"$message[56][$Lang]: $_sider_p{$key}\" title=\"$message[56][$Lang]: $_sider_p{$key}\"></TD></TR>\n";
  	}
  	$count++;
}
&tab_end;


# BY HOUR
#----------------------------
print "<CENTER><a name=\"HOUR\"></a><BR>";
$tab_titre="$message[20][$Lang]";
&tab_head;

print "<TR><TD><TABLE><TR>\n";
$max_p=0;$max_h=0;$max_k=0;
for ($ix=0; $ix<=23; $ix++) {
  print "<TH width=16>$ix</TH>";
  if ($_time_p[$ix]>$max_p) { $max_p=$_time_p[$ix]; }
  if ($_time_h[$ix]>$max_h) { $max_h=$_time_h[$ix]; }
  if ($_time_k[$ix]>$max_k) { $max_k=$_time_k[$ix]; }
}
print "</TR>\n";

print "<TR>\n";
for ($ix=0; $ix<=23; $ix++) {
	$hr=$ix+1;
	if ($ix>11) { $hr=$ix-11; }
	print "<TH><IMG SRC=\"$DirIcons\/clock\/hr$hr.png\" width=10></TH>";
}
print "</TR>\n";

print "\n<TR VALIGN=BOTTOM>\n";
for ($ix=0; $ix<=23; $ix++) {
	$bredde_p=0;$bredde_h=0;$bredde_k=0;
	if ($max_h > 0) { $bredde_p=($BarHeight*$_time_p[$ix]/$max_h)+1; }
	if ($max_h > 0) { $bredde_h=($BarHeight*$_time_h[$ix]/$max_h)+1; }
	if ($max_k > 0) { $bredde_k=($BarHeight*$_time_k[$ix]/$max_k)+1; }
	$kilo=int(($_time_k[$ix]/1024)*100)/100;
	print "<TD>";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=6 ALT=\"$message[56][$Lang]: $_time_p[$ix]\" title=\"$message[56][$Lang]: $_time_p[$ix]\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=6 ALT=\"$message[57][$Lang]: $_time_h[$ix]\" title=\"$message[57][$Lang]: $_time_h[$ix]\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=6 ALT=\"$message[44][$Lang]: $kilo\" title=\"$message[44][$Lang]: $kilo\">";
	print "</TD>\n";
}
print "</TR></TABLE></TD></TR>\n";

&tab_end;


# BY BROWSER
#----------------------------
print "<CENTER><a name=\"BROWSER\"></a><BR>";
$tab_titre="$message[31][$Lang]";
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle><TH CLASS=LEFT>Browser</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
foreach $key (@sortbrowsers) {
	$p=int($_browser_h{$key}/$TotalHits*1000)/10;
	if ($key eq "Unknown") {
		print "<TR><TD CLASS=LEFT><a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&action=unknownrefererbrowser&month=$MonthRequired&lang=$Lang\">$message[0][$Lang]</a></TD><TD>$_browser_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
	}
	else {
		print "<TR><TD CLASS=LEFT>$BrowsersHash{$key}</TD><TD>$_browser_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
	}
}
&tab_end;


# BY OS
#----------------------------
print "<CENTER><a name=\"OS\"></a><BR>";
$tab_titre=$message[35][$Lang];
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle><TH CLASS=LEFT colspan=2>OS</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
foreach $key (@sortos) {
	$p=int($_os_h{$key}/$TotalHits*1000)/10;
	if ($key eq "Unknown") {
		print "<TR><TD><IMG SRC=\"$DirIcons\/os\/unknown.png\"></TD><TD CLASS=LEFT><a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&action=unknownreferer&month=$MonthRequired&lang=$Lang\">$message[0][$Lang]</a></TD><TD>$_os_h{$key}&nbsp;</TD>";
		print "<TD>$p&nbsp;%</TD></TR>\n";
		}
	else {
		$nameicon = $OSHash{$key}; $nameicon =~ s/\ .*//; $nameicon =~ tr/A-Z/a-z/;
		print "<TR><TD><IMG SRC=\"$DirIcons\/os\/$nameicon.png\"></TD><TD CLASS=LEFT>$OSHash{$key}</TD><TD>$_os_h{$key}</TD>";
		print "<TD>$p&nbsp;%</TD></TR>\n";
	}
}
&tab_end;


# BY REFERENCE
#---------------------------
print "<CENTER><a name=\"REFERER\"></a><BR>";
$tab_titre="$message[36][$Lang]";
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle><TH CLASS=LEFT>$message[37][$Lang]</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
if ($TotalHits > 0) { $_=int($_from_h[0]/$TotalHits*1000)/10; }
print "<TR><TD CLASS=LEFT><b>$message[38][$Lang]:</b></TD><TD>$_from_h[0]&nbsp;</TD><TD>$_&nbsp;%</TD></TR>\n";
if ($TotalHits > 0) { $_=int($_from_h[1]/$TotalHits*1000)/10; }
print "<TR><TD CLASS=LEFT><b>$message[39][$Lang]:</b></TD><TD>$_from_h[1]&nbsp;</TD><TD>$_&nbsp;%</TD></TR>\n";
#------- Referrals by search engine
if ($TotalHits > 0) { $_=int($_from_h[2]/$TotalHits*1000)/10; }
print "<TR onmouseover=\"ShowTooltip(13);\" onmouseout=\"HideTooltip(13);\"><TD CLASS=LEFT><b>$message[40][$Lang] :</b><br>\n";
print "<TABLE>\n";
foreach $SE (@sortsereferrals) {
    print "<TR><TD CLASS=LEFT>- $SearchEnginesHash{$SE} </TD><TD align=right>$_se_referrals_h{\"$SE\"}</TD></TR>\n";
}
print "</TABLE></TD>\n";
print "<TD valign=top>$_from_h[2]&nbsp;</TD><TD valign=top>$_&nbsp;%</TD>\n</TR>\n";
#------- Referrals by external HTML link
if ($TotalHits > 0) { $_=(int($_from_h[3]/$TotalHits*1000)/10); }
print "<TR onmouseover=\"ShowTooltip(14);\" onmouseout=\"HideTooltip(14);\"><TD CLASS=LEFT><b>$message[41][$Lang] :</b><br>\n";
print "<TABLE>\n";
$count=0;
foreach $from (@sortpagerefs) {
	if (!(($SortDir<0 && $count<$MaxNbOfRefererShown) || ($SortDir>0 && $#sortpagerefs-$MaxNbOfRefererShown < $count))) { last; }
	if ($_pagesrefs_h{$from}>=$MinHitRefer) {

		# Show source
		$lien=$from;
		$lien =~ s/\"//g;
		$lien=substr($lien,0,$MaxLengthOfURL);
		if ($ShowLinksOnUrl && ($lien =~ /(ftp|http):\/\//)) {
		    print "<TR><TD CLASS=LEFT>- <A HREF=$from>$lien</A></TD> <TD>$_pagesrefs_h{$from}</TD></TR>\n";
		} else {
			print "<TR><TD CLASS=LEFT>- $lien </TD><TD>$_pagesrefs_h{$from}</TD></TR>\n";
		}

		$count++;
	}
}
print "</TABLE></TD>\n";
print "<TD valign=top>$_from_h[3]&nbsp;</TD><TD valign=top>$_&nbsp;%</TD>\n</TR>\n";

if ($TotalHits > 0) { $_=(int($_from_h[4]/$TotalHits*1000)/10); }
print "<TR><TD CLASS=LEFT><b>$message[42][$Lang] :</b></TD><TD>$_from_h[4]&nbsp;</TD><TD>$_&nbsp;%</TD></TR>\n";
&tab_end;


# BY SEARCHWORDS
#----------------------------
print "<CENTER><a name=\"SEARCHWORDS\"></a><BR>";
$tab_titre="TOP $MaxNbOfKeywordsShown $message[55][$Lang] $TotalDifferentKeywords $message[43][$Lang]";
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle onmouseover=\"ShowTooltip(15);\" onmouseout=\"HideTooltip(15);\"><TH CLASS=LEFT>$message[13][$Lang]</TH><TH bgcolor=$color_s width=40>$message[14][$Lang]</TH><TH bgcolor=$color_s width=40>$message[15][$Lang]</TH></TR>\n";
$count=0;
foreach $key (@sortsearchwords) {
	if ( $count>=$MaxNbOfKeywordsShown ) { last; }
	$p=int($_keywords{$key}/$TotalKeywords*1000)/10;
	print "<TR><TD CLASS=LEFT>$key</TD><TD>$_keywords{$key}</TD>";
	print "<TD>$p&nbsp;%</TD></TR>\n";
	$count++;
}
$count=0;$rest=0;
foreach $key (@sortsearchwords) {
	if ( $count<$MaxNbOfKeywordsShown ) { $count++; next; }
	$rest=$rest+$_keywords{$key};
}
if ($rest >0) {
	if ($TotalKeywords > 0) { $p=int($rest/$TotalKeywords*1000)/10; }
	print "<TR><TD CLASS=LEFT><font color=blue>$message[30][$Lang]</TD><TD>$rest</TD>";
	print "<TD>$p&nbsp;%</TD></TR>\n";
	}
&tab_end;


# BY ERRORS
#----------------------------
print "<CENTER><a name=\"ERRORS\"></a><BR>";
$tab_titre=$message[32][$Lang];
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle><TH CLASS=LEFT colspan=2>$message[32][$Lang]</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
foreach $key (@sorterrors) {
	$p=int($_errors_h{$key}/$TotalErrors*1000)/10;
	if ($httpcode{$key}) { print "<TR onmouseover=\"ShowTooltip($key);\" onmouseout=\"HideTooltip($key);\">"; }
	else { print "<TR>"; }
	if ($key == 404) { print "<TD><a href=\"$DirCgi$PROG.$Extension?site=$LocalSite&action=notfounderror&month=$MonthRequired&lang=$Lang\">$key</a></TD>"; }
	else { print "<TD>$key</TD>"; }
	if ($httpcode{$key}) { print "<TD CLASS=LEFT>$httpcode{$key}</TD><TD>$_errors_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n"; }
	else { print "<TD CLASS=LEFT>Unknown error</TD><TD>$_errors_h{$key}</TD><TD>$p&nbsp;%</TD></TR>\n"; }
}
&tab_end;


&html_end;

0;	# Do not remove this line

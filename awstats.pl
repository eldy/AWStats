#!/usr/local/bin/perl
#-Description-------------------------------------------
# Free realtime web server logfile analyzer (in Perl) working as a CGI to show
# advanced web statistics. For better performances, you should use this script
# at least once a day (from a scheduler for example).
# See README.TXT file for setup and benchmark informations
# See COPYING.TXT file about AWStats GNU General Public License
#-------------------------------------------------------

#-------------------------------------------------------
# Setup/Configure section
#-------------------------------------------------------
# Warning: If you're under Linux/Unix, don't forget to change first line of this file with path of your perl binary.
# Warning: With IIS, if your log filename is different each month or day, launch awstats just before the end of month or day.
#          If you forget it, you will also forget statistics for this month or day.
$LogFile    = "/var/log/httpd/mylog.log";	# Web server logfile to analyze, with full path (ie with IIS: "C:/WINNT/system32/LogFiles/W3SVC1/exyymm.log")
$LogFormat  = 1;			# 1 = Apache combined log format, 2 = IIS extended W3C log format
$DirIcons   = "/icons";		# Depending on web server, add relative or absolute web URL of all icons subdirectories (Default = "/icons" means you must copy icons directories in "yourwwwroot/icons")
@HostAliases= ("www.myserver.com","127.0.0.1","x.y.z.w");	# Put here all possible domain names, addresses or virtual hosts someone can use to access your site
$DefaultFile= "index.html";	# Default page name for your Web server (Default = "index.html")
$ArchiveLogRecords = 0;		# If AWStats can purge log after processing it, it will do so. You can keep an archive file of processed log records by setting this to 1 (Default = 0)
$Lang		= 0;			# Default language: 0 = English, 1 = French, 2 = Dutch, 3 = Spanish (Default = 0)
$WarningMessages=1;			# 1 = Show message informations when warning occurs, 0 = Skip message information for warning (Default = 1)
$Barwidth   = 260;			# Bar width in pixel, for horizontal graphics bar (Default = 260)
$Barheight  = 220;			# Bar height in pixel, for vertical graphics bar (Default = 220)
$SortDir    = -1;			# -1 = Sort order from most to less, 1 = reverse order (Default = -1)
$ShowLinksOnUrl= 1;			# 1 = Each URL shown in stats are links you can click. Not available for pages generated from command line (Default = 1)
$VisitTimeOut  = 10000;		# Laps of time to consider a page load as a new visit. 10000 = one hour (Default = 10000)
$DNSLookup     = 1;			# 1 = Show name instead of IPAddress, 0 is faster (Default = 1)
$FullHostName  = 1;			# 1 = Use name.domaine.zone to refer host clients, 0 = all hosts in same domaine.zone are one host (Default = 1)
$MaxLengthOfURL= 70;		# Maximum length of URL shown on stats page. This affects only URL visible text, link still work (Default = 70)
$SponsorLinkVisible = 0;	# 1 = Link to AWStats sponsor, at the bottom, is visible (Default = 0)
$BenchMark=0;				# Set this to 1 to get some benchmark informations
# Stats by hosts
$MaxNbOfHostsShown = 25;	#
$MinHitHost    = 1;			#
# Stats by pages
$MaxNbOfPageShown = 25;		#
$MinHitFile    = 1;			#
# Stats by referers
$MaxNbOfRefererShown = 25;	#
$MinHitRefer   = 1;			#
# Keywords
$MaxNbOfKeywordsShown = 20;	#
$MinHitKeyword  = 1;		#
# Stats by robots
$MaxNbOfRobotShown = 25;	#
$MinHitRobot   = 1;			#
# Icons and colors
$Logo="awstats_logo1.png";			# You can put your own logo, must be in awstats "other" directory (Default = "awstats_logo1.png")
$color_Background="#FFFFFF";		# Background color for main page (Default = #FFFFFF)
$color_TableBorder="#000000";		# Table border color (Default = #000000)
$color_TableBG="#DDDDBB";			# Background color for table (Default = #DDDDBB)
$color_TableTitle="#FFFFFF";		# Table title font color (Default = #FFFFFF)
$color_TableBGTitle="#666666";		# Background color for table title (Default = #666666)
$color_TableRowTitle="#FFFFFF";		# Table row title font color (Default = #FFFFFF)
$color_TableBGRowTitle="#BBBBBB";	# Background color for row title (Default = #BBBBBB)
$color_link="#4000FF";				# Color of HTML links (Default = #4000FF)
$color_v="#F3F300";					# Background color for number of visites (Default = #F3F300)
$color_w="#FF9933";					# Background color for number of unique visitors (Default = #FF9933)
$color_p="#4477DD";					# Background color for number of pages (Default = #4477DD)
$color_h="#66F0FF";					# Background color for number of hits (Default = #66F0FF)
$color_k="#339944";					# Background color for number of bytes (Default = #339944)
$color_s="#8888DD";					# Background color for number of search (Default = #8888DD)
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
#----- End of Setup/Configure section


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
$VERSION="2.22k";
if ($ENV{"GATEWAY_INTERFACE"} ne "") { $PROG=$0; $PROG =~ s/.*\\//; $PROG =~ s/.*\///; $DIR=$0; $DIR =~ s/$PROG//; $PROG =~ s/\.pl$//; }
else {
	$PROG=$0; $PROG =~ s/.*\\//; $PROG =~ s/.*\///; $DIR=$0; $DIR =~ s/$PROG//; $PROG =~ s/\.pl$//;
	$ShowLinksOnUrl=0;
	}
$QueryString = $ENV{"QUERY_STRING"};
if ($QueryString =~ /lang=0/) { $Lang=0; }
if ($QueryString =~ /lang=1/) { $Lang=1; }
if ($QueryString =~ /lang=2/) { $Lang=2; }
if ($QueryString =~ /lang=3/) { $Lang=3; }

# Do not include access from clients that match following IP address
@SkipHosts= ("x.y.z.w");

# Do not include access to URLs that match following entries
@SkipFiles=	("\\.css","\\.js","\\.class","robots\\.txt",
			# If you don't want to include users homepage in your stats, uncomment the following line
			# "/~"
			# You can also, if you want, add list of not important frames page (like menus, etc...) to exclude them from statistics.
			);

# URL with such end signature are not HTML pages
@NotPageList= (
			"\\.gif","\\.jpg","\\.png","\\.bmp",
			"\\.zip","\\.arj","\\.gz","\\.z",
			"\\.pdf","\\.doc","\\.ppt",
			"\\.mp3","\\.wma"
			);

# Those addresses are shown with those lib (First column is full relative URL, Second column is text to show instead of URL)
%Aliases    = (
			"/",                                    "<b>HOME PAGE</b>",
			"/cgi-bin/awstats.pl",					"<b>AWStats stats page</b>",
			"/cgi-bin/awstats/awstats.pl",			"<b>AWStats stats page</b>",
			# Put here HTML text you want to see in links instead of URL text.
			"/cgi-bin/htsearchlaunch",				"<b>Recherche sur le site</b>",
			"/cgi-bin/awmess/SendMess",       		"<b>Envoi de mails-formulaire via le Web</b>",
			"/cgi-bin/awmess/GetMess",				"<b>Lecture de mails-formulaire via le Web</b>"
			);

# ---------- Search URL --------------------
@WordsToCleanSearchUrl= ("act=","annuaire=","btng=","categoria=","cou=","dd=","domain=","dt=","dw=","geo=","hc=","height=","hl=","hs=","kl=","lang=","loc=","lr=","medor=","message=","meta=","mode=","order=","page=","par=","pays=","pg=","pos=","prg=","qc=","refer=","sa=","safe=","sc=","sort=","src=","start=","stype=","tag=","temp=","theme=","url=","user=","width=","what=","\\.x=","\\.y=");
# Never put the following exclusion ("Claus=","kw=","keyword=","MT","p=","q=","qr=","qt=","query=","s=","search=","searchText=") because they are strings that contain keywords we're looking for.
# yahoo.com      p=
# altavista.com  q=
# google.com     q=
# eureka.com     q=
# lycos.com      query=
# hotbot.com     MT=
# msn.com        MT=
# infoseek.com   qt=
# webcrawler searchText=
# excite         search=
# netscape.com   search=
# mamma.com      query=
# alltheweb.com  query=
# northernlight.com qr=


# ---------- HTTP Code with tooltip --------
%httpcode = (
"201", "Partial Content", "202", "Request recorded, will be executed later", "204", "Request executed", "206", "Partial Content",
"301", "Moved Permanently", "302", "Found",
"400", "Bad Request", "401", "Unauthorized", "403", "Forbidden", "404", "Not Found", "408", "Request Timeout",
"500", "Internal Error", "501", "Not implemented", "502", "Received bad response from real server", "503", "Server busy", "504", "Gateway Time-Out", "505", "HTTP version not supported",

"200", "OK", "304", "Not Modified"	# 200 and 304 are not errors
);

%monthlib =  ( "01","Jan","02","Feb","03","Mar","04","Apr","05","May","06","Jun","07","Jul","08","Aug","09","Sep","10","Oct","11","Nov","12","Dec" );
%monthnum =  ( "Jan","01","Feb","02","Mar","03","Apr","04","May","05","Jun","06","Jul","07","Aug","08","Sep","09","Oct","10","Nov","11","Dec","12" );

# ---------- Language translation messages --------
$message[0][0]="Unknown";						$message[0][1]="Inconnus";								$message[0][2]="Onbekend";                                                                                                                                                              $message[0][3]="Desconocido";
$message[1][0]="Unknown (unresolved ip)";		$message[1][1]="Inconnu (IP non résolue)";				$message[1][2]="Onbekend (Onbekend ip)";                                                                                                                                                $message[1][3]="Dirección IP desconocida";
$message[2][0]="Other visitors";				$message[2][1]="Autres visiteurs";						$message[2][2]="Andere bezoekers";																							 															$message[2][3]="Otros visitantes";
$message[3][0]="View details";					$message[3][1]="Voir détails";							$message[3][2]="Bekijk details";																							 															$message[3][3]="Vea detalles";
$message[4][0]="Day";							$message[4][1]="Jour";									$message[4][2]="Dag";																										 															$message[4][3]="Día";
$message[5][0]="Month";							$message[5][1]="Mois";									$message[5][2]="Maand";																																									$message[5][3]="Mes";
$message[6][0]="Year";							$message[6][1]="Année";									$message[6][2]="Jaar";																																									$message[6][3]="Año";
$message[7][0]="Statistics of";					$message[7][1]="Statistiques du site";					$message[7][2]="Statistieken van";																																						$message[7][3]="Estadísticas del sitio";
$message[8][0]="First visit";					$message[8][1]="Première visite";						$message[8][2]="Eerste bezoek";																																							$message[8][3]="Primera visita";
$message[9][0]="Last visit";					$message[9][1]="Dernière visite";						$message[9][2]="Laatste bezoek";																																						$message[9][3]="Última visita";
$message[10][0]="Number of visits";				$message[10][1]="Nbre visites";							$message[10][2]="Aantal boezoeken";																																						$message[10][3]="Número de visitas";
$message[11][0]="Unique visitors";  			$message[11][1]="Nbre visiteurs différents";			$message[11][2]="Unieke bezoekers";																																						$message[11][3]="No. de visitantes distintos";
$message[12][0]="visit";						$message[12][1]="visite";								$message[12][2]="bezoek";																																								$message[12][3]="visita";
$message[13][0]="Keyword";						$message[13][1]="Mot clé";								$message[13][2]="Trefwoord";																																							$message[13][3]="Palabra clave (keyword)";
$message[14][0]="Search";						$message[14][1]="Recherche";							$message[14][2]="Zoek";																																									$message[14][3]="Búsqueda";
$message[15][0]="Percent";						$message[15][1]="Pourcentage";							$message[15][2]="Procent";																																								$message[15][3]="Porciento";
$message[16][0]="Traffic Summary";				$message[16][1]="Résumé";								$message[16][2]="Opsomming";																																							$message[16][3]="Resumen de tráfico";
$message[17][0]="Domains/Countries";			$message[17][1]="Domaines/Pays";						$message[17][2]="Domeinen/Landen";																																						$message[17][3]="Dominios/Países";
$message[18][0]="Visitors";						$message[18][1]="Visiteurs";							$message[18][2]="Bezoekers";																																							$message[18][3]="Visitantes";
$message[19][0]="Pages/URL";					$message[19][1]="Pages/URL";							$message[19][2]="Pagina's/URL";																																							$message[19][3]="Páginas/URLs";
$message[20][0]="Hours";						$message[20][1]="Heures";								$message[20][2]="Uren";																																									$message[20][3]="Horas";
$message[21][0]="Browsers";						$message[21][1]="Navigateurs";							$message[21][2]="Browsers";																																								$message[21][3]="Navegadores";
$message[22][0]="HTTP Errors";					$message[22][1]="Erreurs HTTP";							$message[22][2]="HTTP Foutmeldingen";																																					$message[22][3]="Errores de protocolo HTTP";
$message[23][0]="Referrers";					$message[23][1]="Origine/Referrer";						$message[23][2]="Verwijzing";																																							$message[23][3]="Referencia de origen";
$message[24][0]="Search&nbsp;Keywords";			$message[24][1]="Mots&nbsp;clés&nbsp;de&nbsp;recherche";	$message[24][2]="Zoek&nbsp;trefwoorden";																																		    $message[24][3]="Palabra&nbsp;clave&nbsp;de&nbsp;búsqueda";
$message[25][0]="Visitors domains/countries";	$message[25][1]="Domaines/pays visiteurs";					$message[25][2]="Bezoekers domeinen/landen";																																	    $message[25][3]="Dominios/País de visitantes";
$message[26][0]="hosts";						$message[26][1]="des hôtes";								$message[26][2]="hosts";																																							$message[26][3]="servidor";
$message[27][0]="pages";						$message[27][1]="des pages";								$message[27][2]="pagina's";																																							$message[27][3]="páginas";
$message[28][0]="different pages";				$message[28][1]="pages différentes";						$message[28][2]="verschillende pagina's";																																			$message[28][3]="páginas diferentes";
$message[29][0]="Access";						$message[29][1]="Accès";									$message[29][2]="Toegang";																																							$message[29][3]="Acceso";
$message[30][0]="Other words";					$message[30][1]="Autres mots";								$message[30][2]="Andere woorden";																																					$message[30][3]="Otras palabras";
$message[31][0]="Used browsers";				$message[31][1]="Navigateurs utilisés";						$message[31][2]="Gebruikte browsers";																																				$message[31][3]="Navegadores utilizados";	
$message[32][0]="HTTP Error codes";				$message[32][1]="Codes Erreurs HTTP";						$message[32][2]="HTTP foutmelding codes";																																			$message[32][3]="Códigos de Errores de Protocolo HTPP";
$message[33][0]="Netscape versions<br><img src=\"$DirIcons/browser/netscape.png\">";			$message[33][1]="Versions de Netscape<br><img src=\"$DirIcons/browser/netscape.png\">";			$message[33][2]="Netscape versies<br><img src=\"$DirIcons/browser/netscape.png\">";				$message[33][3]="Versiones de Netscape<br><img src=\"$DirIcons/browser/netscape.png\">";
$message[34][0]="MS Internet Explorer versions<br><img src=\"$DirIcons/browser/msie.png\">";	$message[34][1]="Versions de MS Internet Explorer<br><img src=\"$DirIcons/browser/msie.png\">"; $message[34][2]="MS Internet Explorer versies<br><img src=\"$DirIcons/browser/msie.png\">";		$message[34][3]="Versiones de MS Internet Explorer<br><img src=\"$DirIcons/browser/msie.png\">";
$message[35][0]="Used OS";																		$message[35][1]="Systèmes d'exploitation utilisés";												$message[35][2]="Gebruikt OS";																	$message[35][3]="Sistemas Operativos utilizados";
$message[36][0]="Connect to site from";															$message[36][1]="Connexions au site par";														$message[36][2]="Verbinding naar site vanaf";													$message[36][3]="Enlazado al sitio desde";
$message[37][0]="Origin";																		$message[37][1]="Origine de la connexion";														$message[37][2]="Herkomst";																		$message[37][3]="Origen de enlace";
$message[38][0]="Direct address / Bookmarks";													$message[38][1]="Adresse directe / Bookmarks";													$message[38][2]="Direkt adres / Bookmarks";														$message[38][3]="Dirección directa / Favoritos";
$message[39][0]="Link from a Newsgroup";														$message[39][1]="Lien depuis un Newsgroup";														$message[39][2]="Link vanuit een nieuwsgroep";													$message[39][3]="Enlace desde Newsgroup";
$message[40][0]="Link from an Internet Search Engine";											$message[40][1]="Lien depuis un moteur de recherche Internet";									$message[40][2]="Link vanuit een Internet Zoek Machine";										$message[40][3]="Enlace desde algún motor de búsqueda";
$message[41][0]="Link from an external page (other web sites except search engines)";			$message[41][1]="Lien depuis une page externe (autres sites, hors moteurs de recherche)";		$message[41][2]="Link vanuit een externe pagina (andere web sites behalve zoek machines)";		$message[41][3]="Enlace desde página externa (exeptuando motores de búsqueda)";
$message[42][0]="Link from an internal page (other page on same site)";							$message[42][1]="Lien depuis une page interne (autre page du site)";							$message[42][2]="Link vanuit een interne pagina (andere pagina van dezelfde site)";				$message[42][3]="Enlace desde página interna (otra página del sitio)";
$message[43][0]="keywords used on search engines";												$message[43][1]="des critères de recherches utilisés";											$message[43][2]="gebruikte trefwoorden bij zoek machines";										$message[43][3]="Palabras clave utilizada por el motor de búsqueda";
$message[44][0]="Kb";																			$message[44][1]="Ko";																			$message[44][2]="Kb";																			$message[44][3]="Kb";
$message[45][0]="Unresolved IP Address";														$message[45][1]="Adresses IP des visiteurs non identifiables (IP non résolue)";					$message[45][2]="niet vertaald  IP Adres";														$message[45][3]="Dirección IP no identificada";
$message[46][0]="Unknown OS (Referer field)";													$message[46][1]="OS non reconnus (champ referer brut)";											$message[46][2]="Onbekend OS (Referer veld)";													$message[46][3]="Sistema Operativo desconocido (campo de referencia)";
$message[47][0]="Required but not found URLs (HTTP code 404)";									$message[47][1]="URLs du site demandées non trouvées (Code HTTP 404)";							$message[47][2]="Verplicht maar niet gvonden URLs (HTTP code 404)";								$message[47][3]="URLs necesarios pero no encontados (código 404 de protocolo HTTP)";
$message[48][0]="IP Address";																	$message[48][1]="Adresse IP";																	$message[48][2]="IP Adres";																		$message[48][3]="Dirección IP";
$message[49][0]="Error&nbsp;Hits";																$message[49][1]="Hits&nbsp;en&nbsp;échec";														$message[49][2]="Fout&nbsp;Hits";																$message[49][3]="Hits&nbsp;erróneos";
$message[50][0]="Unknown browsers (Referer field)";												$message[50][1]="Navigateurs non reconnus (champ referer brut)";								$message[50][2]="Onbekende browsers (Referer veld)";											$message[50][3]="Navegadores desconocidos (campo de referencia)";
$message[51][0]="Visiting robots";																$message[51][1]="Robots visiteurs";																$message[51][2]="Bezoekende robots";															$message[51][3]="Visitas de Robots";
$message[52][0]="visits/visitor";																$message[52][1]="visite/visiteur";																$message[52][2]="bezoeken/bezoeker";															$message[52][3]="Visitas/Visitantes";
$message[53][0]="Robots/Spiders visitors";														$message[53][1]="Visiteurs Robots/Spiders";														$message[53][2]="Robots/Spiders bezoekers";														$message[53][3]="Visitas de Robots/Spiders (arañas de indexación)";
$message[54][0]="Free realtime logfile analyzer for advanced web statistics";					$message[54][1]="Analyseur de log gratuit pour statistiques Web avancées";						$message[54][2]="Gratis realtime logbestand analyzer voor geavanceerde web statistieken";		$message[54][3]="Analizador gratuito de 'log' para estadísticas Web avanzadas";
$message[55][0]="of";																			$message[55][1]="sur";																			$message[55][2]="van";																			$message[55][3]="de";


# ---------- Browser lists ----------------
# ("browser id in lower case", "browser text")
%BrowsersHash = (
"netscape","<font color=blue>Netscape</font> <a href=\"$PROG.pl?action=browserdetail&lang=$Lang\">(Versions)</a>",
"msie","<font color=blue>MS Internet Explorer</font> <a href=\"$PROG.pl?action=browserdetail&lang=$Lang\">(Versions)</a>",

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
"teleportpro","TelePortPro",
"tzgeturl","TZGETURL",
"viking","Viking",
"webcapture","Aspirateur Acrobat",
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
#      - Robot called webs
# Rem: directhit is renamed in direct_hit
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
"weblayers", "weblayers",
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
"ezresult",	"Ezresult (Not referenced robot)",
"fast-webcrawler", "Fast-Webcrawler (Not referenced robot)",
"perman surfer", "Perman surfer (Not referenced robot)",
"mercator", "Mercator (Not referenced robot)",
"antibot", "Antibot (Not referenced robot)",
"daviesbot", "DaviesBot (Not referenced robot)",
"unlost_web_crawler", "Unlost_Web_Crawler (Not referenced robot)",
"justview", "JustView (Not referenced robot)",
# Supposed to be robots
"webcompass", "webcompass (Not referenced robot)",
"digout4u", "digout4u (Not referenced robot)",
"echo", "EchO! (Not referenced robot)",
"voila", "Voila (Not referenced robot)",
"boris", "Boris (Not referenced robot)",
"ultraseek", "Ultraseek (Not referenced robot)",
"ia_archiver", "ia_archiver (Not referenced robot)",
# Generic detect ID
"robot", "Unknown robot (Not referenced robot)"
);

# ---------- Search engine lists --------------------
%SearchEnginesHash=(
"excite\.","Excite",			"yahoo\.","Yahoo",			"altavista\.","AltaVista",
"lycos\.","Lycos",				"voila\.", "Voila",			"infoseek\.","Infoseek",			"google\.","Google",
"webcrawler\.","WebCrawler",	"lokace\.", "Lokace",		"northernlight\.","NorthernLight",	"hotbot\.","Hotbot",
"metacrawler\.","MetaCrawler",	"go2net\.com","Go2Net (Metamoteur)",	"askjeeves\.","Ask Jeeves",	"ctrouve\.","C'est trouvé",
"euroseek\.","Euroseek",		"francite\.","Francité",	"\.lbb\.org", "LBB",
"netscape\.","Netscape",		"nomade\.fr/","Nomade",
"msn\.dk/","MSN (dk)",			"msn\.fr/","MSN (fr)",		"msn\.","MSN",						"nbci\.com/search","NBCI",
"mamma\.","Mamma",				"dejanews\.","DejaNews",	
"search\.terra\.","Terra",		"snap\.","Snap",
"netfind\.aol\.com","AOL",		"recherche\.aol\.fr","AOL",		"rechercher\.libertysurf\.fr","Libertysurf",
"search\.com","Other search engines"
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
sub html_end {
	$date=localtime();
	print "<br><font size=1>$date - <b>Advanced Web Statistics $VERSION</b> - <a href=\"http://perso.wanadoo.fr/l.destailleur/awstats.html\" target=_newawstats>Visit $PROG official web page</a></font>\n";
	if ($SponsorLinkVisible) {
		print " - <a href=\"http://www.commission-junction.com/track/track.dll?AID=348418&PID=531902&URL=http%3A%2F%2Fwww%2Ecj%2Ecom\">";
		print "Visit $PROG sponsor";
		print "</a><img src=\"http://www.commission-junction.com/banners/tracker.exe?AID=348418&PID=531902&banner=0.gif\" height=1 width=1 border=0>";
	}
	print "<br><br>";
	print "</body>";
	print "</html>";
	exit(0);
}

sub tab_head {
	print "
		<TABLE CLASS=TABLEBORDER BORDER=0 CELLPADDING=1 CELLSPACING=0 WIDTH=700>
		<TR><TD>
		<TABLE CLASS=TABLEFRAME BORDER=0 CELLPADDING=3 CELLSPACING=0 WIDTH=100%>
		<TR><TH COLSPAN=2 CLASS=TABLETITLE>$tab_titre</TH></TR>
		<TR><TD COLSPAN=2>
		<TABLE CLASS=TABLEDATA BORDER=1 CELLPADDING=2 CELLSPACING=0 WIDTH=100%>
		";
}

sub tab_end {
	print "</TABLE></TD></TR></TABLE>";
	print "</TD></TR></TABLE>";
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
   	print "$_[0].<br><br>\n";
	print "<font color=#880000><b>Setup ($PROG, web server or logfile permissions) may be wrong.</b></font><br>";
	print "See README.TXT for informations on how to install $PROG.\n";
    print "</BODY>\n";
    print "</HTML>\n";
    die;
}

sub warning {
	if ($WarningMessages == 1) {
    	print "$_[0]<br>\n";
	    print "You can now suppress this warning by changing <b>\$WarningMessage=1</b> parameter into <b>\$WarningMessage=0</b> in <b>$PROG.pl</b> file.<br><br>\n";
	}
}

sub SkipHost {
	foreach $Skip (@SkipHosts) { if ($_[0] =~ m/$Skip/) { return 1; } }
	0; # Not in @SkipHosts
}

sub SkipFile {
	foreach $Skip (@SkipFiles) { if ($_[0] =~ m/$Skip/i) { return 1; } }
	0; # Not inside @SkipFiles
}

sub Read_History_File {
if (open(HISTORY,$fic)) {
	$readdomain=0;$readvisitor=0;$readunknownip=0;$readsider=0;$readtime=0;$readbrowser=0;$readnsver=0;$readmsiever=0;
	$reados=0;$readrobot=0;$readunknownreferer=0;$readunknownrefererbrowser=0;$readpagerefs=0;$readse=0;
	$readsearchwords=0;$readerrors=0;$readerrors404=0;
   	$indic1{$_[0]}=0; $indic2{$_[0]}=0; $indic3{$_[0]}=0; $indic4{$_[0]}=0; $indic5{$_[0]}=0;
	while (<HISTORY>) {
		$_ =~ s/\n//; $saveline=$_;
		@felter=split(/ /,$_);
		if ($felter[0] eq "FirstTime") { $FirstTime=$felter[1]; next; }
        if (($felter[0] eq "LastTime") && ($LastTime eq 0)) { $LastTime=$felter[1]; next; }
		if ($felter[0] eq "TotalVisits") { $TotalVisits+=$felter[1]; $indic1{$_[0]}+=$felter[1]; next; }

        if ($felter[0] eq "BEGIN_DOMAIN") { $readdomain=1; next; }
		if ($felter[0] eq "END_DOMAIN")   { $readdomain=0; next; }
		if ($readdomain) {
			$domener_p{$felter[0]}+=$felter[1];
			$domener_h{$felter[0]}+=$felter[2];
			$domener_k{$felter[0]}+=$felter[3];
			next; }

        if ($felter[0] eq "BEGIN_VISITOR") { $readvisitor=1; next; }
        if ($felter[0] eq "END_VISITOR")   { $readvisitor=0; next; }
        if ($readvisitor) {
        	$hostmachine_p{$felter[0]}+=$felter[1];
        	$hostmachine_h{$felter[0]}+=$felter[2];
        	$hostmachine_k{$felter[0]}+=$felter[3];
        	$hostmachine_l{$felter[0]}=$felter[4];
        	if (($felter[0] ne "Unknown") && ($hostmachine_p{$felter[0]} > 0)) { $indic2{$_[0]}++; }
        	next; }
        if ($felter[0] eq "BEGIN_UNKNOWNIP") { $readunknownip=1; next; }
        if ($felter[0] eq "END_UNKNOWNIP")   { $readunknownip=0; next; }
        if ($readunknownip) {
        	if ($unknownip_l{$felter[0]} eq "") { $unknownip_l{$felter[0]}=$felter[1]; }
        	$indic2{$_[0]}++;
        	next; }

		if ($felter[0] eq "BEGIN_SIDER")  { $readsider=1; next; }
		if ($felter[0] eq "END_SIDER")    { $readsider=0; next; }
		if ($readsider) { $sider_p{$felter[0]}+=$felter[1]; next; }

        if ($felter[0] eq "BEGIN_TIME")     { $readtime=1; next; }
        if ($felter[0] eq "END_TIME")       { $readtime=0; next; }
        if ($readtime) {
        	$time_p[$felter[0]]+=$felter[1]; $time_h[$felter[0]]+=$felter[2]; $time_k[$felter[0]]+=$felter[3];
        	$indic3{$_[0]}+=$felter[1]; $indic4{$_[0]}+=$felter[2]; $indic5{$_[0]}+=$felter[3];
        	next; }

        if ($felter[0] eq "BEGIN_BROWSER") { $readbrowser=1; next; }
        if ($felter[0] eq "END_BROWSER") { $readbrowser=0; next; }
        if ($readbrowser) { $browser{$felter[0]}+=$felter[1]; next; }

        if ($felter[0] eq "BEGIN_NSVER") { $readnsver=1; next; }
        if ($felter[0] eq "END_NSVER") { $readnsver=0; next; }
        if ($readnsver) { $nsver[$felter[0]]+=$felter[1]; next; }

        if ($felter[0] eq "BEGIN_MSIEVER") { $readmsiever=1; next; }
        if ($felter[0] eq "END_MSIEVER") { $readmsiever=0; next; }
        if ($readmsiever) { $msiever[$felter[0]]+=$felter[1]; next; }

        if ($felter[0] eq "BEGIN_OS") { $reados=1; next; }
        if ($felter[0] eq "END_OS") { $reados=0; next; }
        if ($reados) { $OS{$felter[0]}+=$felter[1]; next; }

        if ($felter[0] eq "BEGIN_ROBOT") { $readrobot=1; next; }
        if ($felter[0] eq "END_ROBOT") { $readrobot=0; next; }
        if ($readrobot) { 
        	if ($robot_l{$felter[0]} eq "") { $robot_l{$felter[0]}=$felter[2]; }
			$robot{$felter[0]}+=$felter[1];
			next; }

        if ($felter[0] eq "BEGIN_UNKNOWNREFERER") { $readunknownreferer=1; next; }
        if ($felter[0] eq "END_UNKNOWNREFERER")   { $readunknownreferer=0; next; }
        if ($readunknownreferer) {
        	if ($unknownreferer_l{$felter[0]} eq "") { $unknownreferer_l{$felter[0]}=$felter[1]; }
        	next; }
        if ($felter[0] eq "BEGIN_UNKNOWNREFERERBROWSER") { $readunknownrefererbrowser=1; next; }
        if ($felter[0] eq "END_UNKNOWNREFERERBROWSER")   { $readunknownrefererbrowser=0; next; }
        if ($readunknownrefererbrowser) {
        	if ($unknownrefererbrowser_l{$felter[0]} eq "") { $unknownrefererbrowser_l{$felter[0]}=$felter[1]; }
        	next; }

        if ($felter[0] eq "HitFrom0") { $HitFrom[0]+=$felter[1]; next; }
        if ($felter[0] eq "HitFrom1") { $HitFrom[1]+=$felter[1]; next; }
        if ($felter[0] eq "HitFrom2") { $HitFrom[2]+=$felter[1]; next; }
        if ($felter[0] eq "HitFrom3") { $HitFrom[3]+=$felter[1]; next; }
        if ($felter[0] eq "HitFrom4") { $HitFrom[4]+=$felter[1]; next; }

        if ($felter[0] eq "BEGIN_PAGEREFS") { $readpagerefs=1; next; }
        if ($felter[0] eq "END_PAGEREFS") { $readpagerefs=0; next; }
        if ($readpagerefs) { $PageRefs{$felter[0]}+=$felter[1]; next; }

        if ($felter[0] eq "BEGIN_SEREFERRALS") { $readse=1; next; }
        if ($felter[0] eq "END_SEREFERRALS") { $readse=0; next; }
        if ($readse) { $SEReferrals{$felter[0]}+=$felter[1]; next; }

        if ($felter[0] eq "BEGIN_SEARCHWORDS") { $readsearchwords=1; next; }
        if ($felter[0] eq "END_SEARCHWORDS") { $readsearchwords=0; next; }
        if ($readsearchwords) { $searchwords{$felter[0]}+=$felter[1]; next; }

        if ($felter[0] eq "BEGIN_ERRORS") { $readerrors=1; next; }
        if ($felter[0] eq "END_ERRORS") { $readerrors=0; next; }
        if ($readerrors) { $errors{$felter[0]}+=$felter[1]; next; }

        if ($felter[0] eq "BEGIN_SIDER_404") { $readerrors404=1; next; }
        if ($felter[0] eq "END_SIDER_404") { $readerrors404=0; next; }
        if ($readerrors404) { $sider404{$felter[0]}+=$felter[1]; next; }
		}
	}
close HISTORY;
}


# For my own test
if ($ENV{"SERVER_NAME"} eq "athena" || $ARGV[0] eq "athena") {
$LogFile   = "C:\\WINNT\\system32\\LogFiles\\W3SVC1\\ex";
#$LogFile   = "C:\\TEMP\\test.log";
$LogFormat  = 2; }
if ($ENV{"SERVER_NAME"} eq "chiensderace.com" || $ARGV[0] eq "chiensderace.com") {
$ArchiveLogRecords = 1;
@SkipFiles= ("\\.css","\\.js","\\.class","robots\\.txt","/~","accueil\\.htm","sommaire\\.htm","barre\\.htm","menu\\.shtml","menu_","onglet_");
@HostAliases= ("chiensderaces.com","www.chiensderaces.com");
$LogFile   = "/export/home/wwwroot/nicoboy/logs/chiensderace_access_log";
$DirIcons="/icon"; }
if ($ENV{"SERVER_NAME"} eq "reference" || $ARGV[0] eq "reference") {
@HostAliases= ("163.84.167.24","163.84.92.240","refoptimia","referenc");
$LogFile   = "/usr/local/apache/logs/reference.access_log";	}
if ($ENV{"SERVER_NAME"} eq "www.partenor.com" || $ARGV[0] eq "www.partenor.com") {
$ArchiveLogRecords = 1;
@SkipHosts= ("10.0.0.");
@SkipFiles= ("\\.css","\\.js","\\.class","robots\\.txt","/~","sommaire\\.htm","barre\\.htm","menu_","onglet_");
@HostAliases= ("ftp.partenor.com");
$LogFile   = "/var/log/httpd/www.partenor.com-access_log"; }


#-------------------------------------------------------
# MAIN
#-------------------------------------------------------
if ($DNSLookup) { use Socket; }

$LocalSite = $ENV{"SERVER_NAME"};if ($LocalSite eq "") { $LocalSite=$ARGV[0] }; $LocalSite =~ tr/A-Z/a-z/;
$LocalSiteWithoutwww = $LocalSite; $LocalSiteWithoutwww =~ s/www\.//;
if ($ARGV[0] eq "-h" || $ARGV[0] eq "-?" || $ARGV[0] eq "--help") {
	print "----- $PROG $VERSION (c) laurent.destailleur\@wanadoo.fr -----\n";
	print "$PROG is a free Web server logfile analyzer (in Perl) working as CGI to show\n";
	print "advanced web statistics. Now supports/detects :\n";
	print " Visits and unique visitors\n";
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
	print " ".(@SearchEnginesArray)." search engines to detect referrer\n";
	print " ".(@SearchEnginesArray)." search engines to detect keywords\n";
	print "See README.TXT for setup.\n";
	print "New versions and support at http://perso.wanadoo.fr/l.destailleur/awstats.html\n";
	exit 0
	}
if ($LocalSite eq "") {
	print "----- $PROG $VERSION (c) laurent.destailleur\@wanadoo.fr -----\n";
	print "Syntax: $PROG.pl www.myservername   Run $PROG from command line, not as CGI\n";
	print "        $PROG.pl -h                 Quick features (Read README.TXT for help)\n";
	print "New versions and support at http://perso.wanadoo.fr/l.destailleur/awstats.html\n";
	exit 0
	}

# Send HTTP/HTML Header
if ($ENV{"GATEWAY_INTERFACE"} ne "") { print("Content-type: text/html\n\n\n"); }
print "<html>\n";
print "<head>\n";
print "<meta http-equiv=\"description\" content=\"$PROG - Advanced Web Statistics of $LocalSite\">\n";
print "<meta http-equiv=\"keywords\" content=\"$LocalSite, free, advanced, realtime, web, server, logfile, log, analyzer, analysis, statistics, stats, perl, analyse, performance, hits, visits\">\n";
print "<meta name=\"robots\" content=\"index,follow\">\n";
print "<title>$message[7][$Lang] $LocalSite</title>\n";
print "</head>\n";
print "<body>\n";

print "<center><br>\n";
print "<font size=2><b>AWStats</b></font><br>";
print "<a href=\"http://perso.wanadoo.fr/l.destailleur/awstats.html\" target=_newawstats><img src=$DirIcons/other/$Logo border=0 alt=\"$PROG Official Web Site\"></a><br>\n";
print "<a href=\"$PROG.pl?lang=0\"><img src=\"$DirIcons\/flags\/us.png\" height=14 border=0></a> &nbsp; <a href=\"$PROG.pl?lang=1\"><img src=\"$DirIcons\/flags\/fr.png\" height=14 border=0></a> &nbsp; <a href=\"$PROG.pl?lang=2\"><img src=\"$DirIcons\/flags\/nl.png\" height=14  border=0></a> &nbsp; <a href=\"$PROG.pl?lang=3\"><img src=\"$DirIcons\/flags\/es.png\" height=14 border=0></a><br>\n";
print "<font size=1>$message[54][$Lang]</font><br>\n";
print "<font name=Arial size=-2>\n";
print "<BR><BR>\n";
print "<STYLE TYPE=text/css>\n
<!--
	BODY { font-align: font-family: arial, verdana, helvetica, sans-serif; font-size: 10px; background-color:$color_Background; }
	TD,TH { font-family: arial, verdana, helvetica, sans-serif; font-size: 10px; }
	A {	font-family: arial, verdana helvetica, sans-serif;	font-size: 10px; font-style: normal; color: $color_link; }
	DIV { text-align: justify; }
	.TABLEBORDER { background-color:$color_TableBorder; }
	.TABLEFRAME { background-color:$color_TableBG; }
	.TABLEDATA { background-color:$color_Background; }
	.TABLETITLE { font-family: verdana, arial, helvetica, sans-serif; font-size: 14px; font-weight:bold; color: $color_TableTitle; background-color:$color_TableBGTitle; }
	.classTooltip { position:absolute; top:0px; left:0px; z-index:2; width: 280; visibility:hidden; font: 8pt MS Comic Sans,arial,sans-serif; background-color:#FFFFE6; padding:10px 10px; border: 1px solid black; }
//-->
</STYLE>\n
";

# INIT
#------------------------------------------
($sec,$min,$hour,$day,$month,$year,$wday,$yday,$isdst) = localtime(time);
if ($year < 100) { $year+=2000; } else { $year+=1900; }
$smallyear=$year;$smallyear =~ s/^..//;
$month++;if ($month < 10) { $month  = "0$month"; }
foreach $Host (@SkipHosts)  { if ($Host eq "") { die "Error: undefined SkipHosts. Put a value.\n";  } }
foreach $Host (@SkipFiles)  { if ($Host eq "") { die "Error: undefined SkipFiles. Put a value.\n";  } }
foreach $HostAlias (@HostAliases) { if ($HostAlias eq "") { die "Error: undefined HostAliases. Put a value.\n"; } }
$FirstTime=0;$LastTime=0;$TotalVisits=0;$TotalUnique=0;$TotalDifferentPages=0;$TotalDifferentKeywords=0;$TotalKeywords=0;
for ($ix=0; $ix<5; $ix++) {	$HitFrom[$ix]=0; }


#------------------------------------------
# READING CURRENT MONTH HISTORY FILE
#------------------------------------------
$fic="$DIR$PROG$month$year.txt";
&Read_History_File($month);


#------------------------------------------
# PROCESSING CURRENT LOG
#------------------------------------------
if ($BenchMark == 1) {
	($secbench,$minbench,$hourbench,$daybench,$monthbench,$yearbench,$wdaybench,$ydaybench,$isdstbench) = localtime(time);
	print "Start of processing log file: $hourbench:$minbench:$secbench<br>";
	}
# Try with $LogFile (If not found try $LogFile$smallyear$month.log and then $LogFile$smallyear$month$day.log)
$OpenFileError=1;     if (open(LOG,"$LogFile")) { $OpenFileError=0; }
if ($OpenFileError) { if (open(LOG,"$LogFile$smallyear$month.log")) { $LogFile="$LogFile$smallyear$month.log"; $OpenFileError=0; } }
if ($OpenFileError) { if (open(LOG,"$LogFile$smallyear$month$day.log")) { $LogFile="$LogFile$smallyear$month$day.log"; $OpenFileError=0; } }
if ($OpenFileError) { error("Error: Couldn't open server log file <b>$LogFile</b>: $!"); }
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
		# Change order of ISS parameters to be like Apache
		$savedate=$felter[0];$savetime=$felter[1];
		$felter[0]=$felter[2];
		$felter[1]="-";
		$felter[2]=$felter[3];
		@datep=split(/-/,$savedate);				#Day:MM:YY:Hour:Min:Sec
		$felter[3]="[$datep[2]/$datep[1]/$datep[0]:$savetime";
		$felter[11]=$felter[9];
		$felter[9]=$felter[7];
		$felter[7]=$felter[8];
		$felter[8]=$felter[6];
		$felter[6]=$felter[5];
		$felter[5]=$felter[4];
		$felter[4]="+0000]";
		#print "$felter[0] $felter[1] $felter[2] $felter[3] $felter[4] $felter[5] $felter[6] $felter[7] $felter[8] $felter[9] $felter[10] $felter[11]<br>";
	}
	else {
		$_ =~ s/ GET .* .* HTTP\// GET BAD_URL HTTP\//;		# Change ' GET x y z HTTP/' into ' GET x%20y%20z HTTP/'
		@felter=split(/ /,$_);
	}

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
	if ($timeconnexion <= $LastTime) { next; }		# Skip if not a new line

	if (&SkipHost($felter[0])) { next; }			# Skip with some client host IP address
	if (&SkipFile($felter[6])) { next; }			# Skip with some URL
	if (($felter[8] != 200) && ($felter[8] != 304)) {		# Stop if HTTP server return code != 200 and 304
		if ($felter[8] =~ /^[\d][\d][\d]$/) { 				# Keep error code
			$errors{$felter[8]}++;
			if ($felter[8] == 404) { $sider404{$felter[6]}++; }
			next;
			}
		print "Log file <b>$LogFile</b> doesn't seem to have good format. Suspect line is<br>";
		print "<font color=#888888><i>$line</i></font><br>";
		print "<br><b>LogFormat</b> parameter is <b>$LogFormat</b>, this means each line in your log file need to have ";
		if ($LogFormat == 2) {
				print "<b>\"MSIE Extended W3C log format\"</b> like this:<br>";
				print "<font color=#888888><i>date time c-ip c-username cs-method cs-uri-sterm cs-status cs-bytes cs-version cs(User-Agent) cs(Referer)</i></font><br>"
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
#		if ($felter[10] =~ /^$felter[11],/) {
#		     for ($ix=12; $ix<=$#felter; $ix++) { $felter[$ix-1] = $felter[$ix]; }
#		     }
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
		foreach $bot (keys %RobotHash) { if ($UserAgent =~ /$bot/) { $robot{$bot}++; $robot_l{$bot}=$timeconnexion ; $foundrobot=1; last; }	}
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
	if ($FirstTime eq 0) { $FirstTime=$dateparts[2].$dateparts[1].$dateparts[0].$dateparts[3].$dateparts[4].$dateparts[5]; }
	if ($PageBool) {
		$time_p[$dateparts[3]]++; $indic3{$month}++;		#Count accesses per hour (page)
		$sider_p{$felter[6]}++; 							#Count accesses per page (page)
		}
	$time_h[$dateparts[3]]++; $indic4{$month}++;			#Count accesses per hour (hit)
	$time_k[$dateparts[3]]+=$felter[9]; $indic5{$month}++;	#Count accesses per hour (kb)
	$sider_h{$felter[6]}++;									#Count accesses per page (hit)
	$sider_k{$felter[6]}+=$felter[9];						#Count accesses per page (kb)

	# Analyze: IP-address
	#--------------------
	$found=0;
	$Host=$felter[0];
	if ($Host =~ /^[\d]+\.[\d]+\.[\d]+\.[\d]+$/) {
		# Doing DNS lookup
	    if ($DNSLookup) {
			$new=$TmpHashDNSLookup{$Host};	# TmpHashDNSLookup is a temporary hash table to increase speed
			if (!$new) {	# if $new undefined, $Host not yet resolved
				$new=gethostbyaddr(pack("C4",split(/\./,$Host)),AF_INET);	# This is very slow may took 20 seconds
				if ($new eq "") {	$new="ip"; }
				$TmpHashDNSLookup{$Host}=$new;
			}

			# Here $Host is still xxx.xxx.xxx.xxx and $new is name or "ip" if reverse failed)
			if ($new ne "ip") { $Host=$new; }
		}
	    # If we're not doing lookup or if it failed, we still have an IP address in $Host
	    if (!$DNSLookup || $new eq "ip") {
			  if ($PageBool) {
			  		if (int($timeconnexion) > int($unknownip_l{$Host}+$VisitTimeOut)) { $TotalVisits++; $indic1{$month}++; }
					if ($unknownip_l{$Host} eq "") { $indic2{$month}++; }
					$unknownip_l{$Host}=$timeconnexion;		# Table of (all IP if !DNSLookup) or (all unknown IP) else
					$hostmachine_p{"Unknown"}++;
					$domener_p{"ip"}++;
			  }
			  $hostmachine_h{"Unknown"}++;
			  $domener_h{"ip"}++;
			  $hostmachine_k{"Unknown"}+=$felter[9];
			  $domener_k{"ip"}+=$felter[9];
			  $found=1;
	      }
    }

	# Here, $Host = hostname or xxx.xxx.xxx.xxx
	if (!$found) {					# If not processed yet ($Host = hostname)
		$Host =~ tr/A-Z/a-z/;
		$_ = $Host;

		# Count hostmachine
		if (!$FullHostName) { s/^[\w\-]+\.//; };
		if ($PageBool) {
			if (int($timeconnexion) > int($hostmachine_l{$_}+$VisitTimeOut)) { $TotalVisits++; $indic1{$month}++; }
			if ($hostmachine_l{$_} eq "") { $indic2{$month}++; }
			$hostmachine_p{$_}++;
			$hostmachine_l{$_}=$timeconnexion;
			}
		$hostmachine_h{$_}++;
		$hostmachine_k{$_}+=$felter[9];

		# Count top-level domain
		if (/\./) { /\.([\w]+)$/; $_=$1; };
		if ($DomainsHash{$_}) {
			 if ($PageBool) { $domener_p{$_}++; }
			 $domener_h{$_}++;
			 $domener_k{$_}+=$felter[9];
			 }
		else {
			 if ($PageBool) { $domener_p{"ip"}++; }
			 $domener_h{"ip"}++;
			 $domener_k{"ip"}+=$felter[9];
		}
	}

	# Analyze: Browser
	#-----------------
	$found=0;

	# IE ? (For higher speed, we start whith IE, the most often used. This avoid other tests if found)
	if ($UserAgent =~ /msie/ && !($UserAgent =~ /webtv/)) {
		$browser{"msie"}++;
		$UserAgent =~ /msie_(\d)\./;  # $1 now contains major version no
		$msiever[$1]++;
		$found=1;
	}

	# Netscape ?
	if (!$found) {
		if ($UserAgent =~ /mozilla/ && !($UserAgent =~ /compatible/)) {
	    	$browser{"netscape"}++;
	    	$UserAgent =~ /\/(\d)\./;  # $1 now contains major version no
	    	$nsver[$1]++;
	    	$found=1;
		}
	}

	# Other ?
	if (!$found) {
		foreach $key (keys %BrowsersHash) {
	    	if ($UserAgent =~ /$key/) { $browser{$key}++; $found=1; last; }
		}
	}

	# Unknown browser ?
	if (!$found) { $browser{"Unknown"}++; $unknownrefererbrowser_l{$felter[11]}=$timeconnexion; }

	# Analyze: OS
	#------------
	$found=0;
	if (!$TmpHashOS{$UserAgent}) {
		# OSHash list ?
		foreach $key (keys %OSHash) {
			if ($UserAgent =~ /$key/) { $OS{$key}++; $found=1; $TmpHashOS{$UserAgent}=$key; last; }
		}
		# OSAlias list ?
		if (!$found) {
			foreach $key (keys %OSAlias) {
				if ($UserAgent =~ /$key/) { $OS{$OSAlias{$key}}++; $found=1; $TmpHashOS{$UserAgent}=$OSAlias{$key}; last; }
			}
		}
		# Unknown OS ?
		if (!$found) { $OS{"Unknown"}++; $unknownreferer_l{$felter[11]}=$timeconnexion; }
	}
	else {
		$OS{$TmpHashOS{$UserAgent}}++;	
	}
	
	# Analyze: Referrer
	#------------------
	$found=0;

	# Direct ?
	if ($felter[10] eq "-") { $HitFrom[0]++; $found=1; }
    
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
			    $HitFrom[4]++;
				$found=1;
			}
			else {
			    # Extern (This hit came from an external web site)
				@refurl=split(/\?/,$felter[10]);
				$refurl[0] =~ tr/A-Z/a-z/;
			    foreach $key (keys %SearchEnginesHash) {
					if ($refurl[0] =~ /$key/) {
						# This hit came from a search engine
						$HitFrom[2]++;
						$SEReferrals{$key}++;
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
								if ((length $word) > 2) { $searchwords{$word}++; }	# Keep word only if word length is 3 or more
							}
						}
						$found=1;
						last;
					}
				}
				if (!$found) {
					# This hit came from a site other than a search engine
					$HitFrom[3]++;
					$PageRefs{$felter[10]}++;
					$found=1;
				}
			}
		}
	}
    
	# News link ?
	if (!$found) {
		if ($felter[10] =~ /^news/) {
			$HitFrom[1]++;
			$found=1;
		}
	}

}
close LOG;
if ($BenchMark == 1) {
	($secbench,$minbench,$hourbench,$daybench,$monthbench,$yearbench,$wdaybench,$ydaybench,$isdstbench) = localtime(time);
	print "End of processing log file: $hourbench:$minbench:$secbench<br>";
	}
if ($dateparts[0]) { $LastTime = $dateparts[2].$dateparts[1].$dateparts[0].$dateparts[3].$dateparts[4].$dateparts[5]; }


#---------------------------
# SAVING NEW CURRENT MONTH
#---------------------------

open(HISTORYTMP,">$DIR$PROG$month$year.tmp.$$") || error("Couldn't open file $DIR$PROG$month$year.tmp.$$: $!");

print HISTORYTMP "FirstTime $FirstTime\n";
print HISTORYTMP "LastTime $LastTime\n";

print HISTORYTMP "TotalVisits $TotalVisits\n";

print HISTORYTMP "BEGIN_DOMAIN\n";
foreach $key (keys %domener_h) {
	$page=$domener_p{$key};$kilo=$domener_k{$key};
	if ($page == "") {$page=0;}
	if ($kilo == "") {$kilo=0;}
	print HISTORYTMP "$key $page $domener_h{$key} $kilo\n"; next;
	}
print HISTORYTMP "END_DOMAIN\n";

print HISTORYTMP "BEGIN_VISITOR\n";
foreach $key (keys %hostmachine_h) {
	$page=$hostmachine_p{$key};$kilo=$hostmachine_k{$key};
	if ($page == "") {$page=0;}
	if ($kilo == "") {$kilo=0;}
	print HISTORYTMP "$key $page $hostmachine_h{$key} $kilo $hostmachine_l{$key}\n"; next;
	}
print HISTORYTMP "END_VISITOR\n";

print HISTORYTMP "BEGIN_UNKNOWNIP\n";
foreach $key (keys %unknownip_l) { print HISTORYTMP "$key $unknownip_l{$key}\n"; next; }
print HISTORYTMP "END_UNKNOWNIP\n";

print HISTORYTMP "BEGIN_SIDER\n";
foreach $key (keys %sider_p) { print HISTORYTMP "$key $sider_p{$key}\n"; next; }
print HISTORYTMP "END_SIDER\n";

print HISTORYTMP "BEGIN_TIME\n";
for ($ix=0; $ix<=23; $ix++) { print HISTORYTMP "$ix $time_p[$ix] $time_h[$ix] $time_k[$ix]\n"; next; }
print HISTORYTMP "END_TIME\n";

print HISTORYTMP "BEGIN_BROWSER\n";
foreach $key (keys %browser) { print HISTORYTMP "$key $browser{$key}\n"; next; }
print HISTORYTMP "END_BROWSER\n";
print HISTORYTMP "BEGIN_NSVER\n";
for ($i=1; $i<=$#nsver; $i++) { print HISTORYTMP "$i $nsver[$i]\n"; next; }
print HISTORYTMP "END_NSVER\n";
print HISTORYTMP "BEGIN_MSIEVER\n";
for ($i=1; $i<=$#msiever; $i++) { print HISTORYTMP "$i $msiever[$i]\n"; next; }
print HISTORYTMP "END_MSIEVER\n";
print HISTORYTMP "BEGIN_OS\n";
foreach $key (keys %OS) { print HISTORYTMP "$key $OS{$key}\n"; next; }
print HISTORYTMP "END_OS\n";

print HISTORYTMP "BEGIN_ROBOT\n";
foreach $key (keys %robot) { print HISTORYTMP "$key $robot{$key} $robot_l{$key}\n"; next; }
print HISTORYTMP "END_ROBOT\n";

print HISTORYTMP "BEGIN_UNKNOWNREFERER\n";
foreach $key (keys %unknownreferer_l) { print HISTORYTMP "$key $unknownreferer_l{$key}\n"; next; }
print HISTORYTMP "END_UNKNOWNREFERER\n";
print HISTORYTMP "BEGIN_UNKNOWNREFERERBROWSER\n";
foreach $key (keys %unknownrefererbrowser_l) { print HISTORYTMP "$key $unknownrefererbrowser_l{$key}\n"; next; }
print HISTORYTMP "END_UNKNOWNREFERERBROWSER\n";

print HISTORYTMP "HitFrom0 $HitFrom[0]\n";
print HISTORYTMP "HitFrom1 $HitFrom[1]\n";
print HISTORYTMP "HitFrom2 $HitFrom[2]\n";
print HISTORYTMP "HitFrom3 $HitFrom[3]\n";
print HISTORYTMP "HitFrom4 $HitFrom[4]\n";

print HISTORYTMP "BEGIN_SEREFERRALS\n";
foreach $key (keys %SEReferrals) { print HISTORYTMP "$key $SEReferrals{$key}\n"; next; }
print HISTORYTMP "END_SEREFERRALS\n";

print HISTORYTMP "BEGIN_PAGEREFS\n";
foreach $key (keys %PageRefs) { print HISTORYTMP "$key $PageRefs{$key}\n"; next; }
print HISTORYTMP "END_PAGEREFS\n";

print HISTORYTMP "BEGIN_SEARCHWORDS\n";
foreach $key (keys %searchwords) { print HISTORYTMP "$key $searchwords{$key}\n"; next; }
print HISTORYTMP "END_SEARCHWORDS\n";

print HISTORYTMP "BEGIN_ERRORS\n";
foreach $key (keys %errors) { print HISTORYTMP "$key $errors{$key}\n"; next; }
print HISTORYTMP "END_ERRORS\n";

print HISTORYTMP "BEGIN_SIDER_404\n";
foreach $key (keys %sider404) { print HISTORYTMP "$key $sider404{$key}\n"; next; }
print HISTORYTMP "END_SIDER_404\n";

close(HISTORYTMP);


# Archive LOG file into ARCHIVELOG
if ($ArchiveLogRecords == 1) {
	if ($BenchMark == 1) { print "Start of archiving log records: ";print localtime(); print "<br>"; }
	open(LOG,"+<$LogFile") || error("Error: Enable to archive log records of $LogFile into $DIR$PROG$month$year.log because source can't be opened for read and write: $!<br>\n");
	open(ARCHIVELOG,">>$DIR$PROG$month$year.log") || error("Error: Couldn't open file $DIR$PROG$month$year.log to archive current log: $!");
	while (<LOG>) {	print ARCHIVELOG $_; }
	close(ARCHIVELOG);
	if ($BenchMark == 1) { print "End of archiving log records: ";print localtime(); print "<br>"; }
	}
else {
	open(LOG,"+<$LogFile");
}
# Rename HISTORYTMP file into HISTORYTXT and purge LOG if ok
if (rename "$DIR$PROG$month$year.tmp.$$", "$DIR$PROG$month$year.txt") {
	truncate(LOG,0) || warning("Warning: $PROG couldn't purge logfile <b>$LogFile</b>.<br>\nBe aware of purging this file sometimes to keep good performances. Think to launch $PROG just before this to save in AWStats history text file all informations logfile contains.");
	}
close(LOG);
chmod 438,"$DIR$PROG$month$year.txt"; chmod 438,"$DIR$PROG$month$year.log";


#----------------------------------
# READING OLD HISTORY FILES TO ADD
#----------------------------------

# Loop on each old month files
for ($ix=($month-1); $ix>=1; $ix--) {
	$monthix=$ix;if ($monthix < 10) { $monthix  = "0$monthix"; }
	$fic="$DIR$PROG$monthix$year.txt";
	&Read_History_File($monthix);
}


#---------------------------------------------------------------------
# SHOW STATISTICS
#---------------------------------------------------------------------

if ($QueryString =~ /unknownip/) {
	print "<a name=\"UNKOWNIP\"></a>";
	$tab_titre=$message[45][$Lang];
	&tab_head;
	print "<TR BGCOLOR=$color_TableBGRowTitle><TH align=left>$message[48][$Lang]</TH><TH align=center>$message[9][$Lang]</TH>\n";
	@sortunknownip=sort { $SortDir*$unknownip_l{$a} <=> $SortDir*$unknownip_l{$b} } keys (%unknownip_l);
	foreach $key (@sortunknownip) {
		$yearcon=substr($unknownip_l{$key},0,4);
		$monthcon=substr($unknownip_l{$key},4,2);
		$daycon=substr($unknownip_l{$key},6,2);
		$hourcon=substr($unknownip_l{$key},8,2);
		$mincon=substr($unknownip_l{$key},10,2);
		if ($Lang == 1) { print "<tr align=left><td>$key</td><td align=center>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
		else { print "<tr align=left><td>$key</td><td align=center>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /unknownrefererbrowser/) {
	print "<a name=\"UNKOWNREFERERBROWSER\"></a>";
	$tab_titre=$message[50][$Lang];
	&tab_head;
	print "<TR BGCOLOR=$color_TableBGRowTitle><TH align=left>Referer</TH><TH align=center>$message[9][$Lang]</TH></TR>\n";
	@sortunknownrefererbrowser=sort { $SortDir*$unknownrefererbrowser_l{$a} <=> $SortDir*$unknownrefererbrowser_l{$b} } keys (%unknownrefererbrowser_l);
	foreach $key (@sortunknownrefererbrowser) {
		$yearcon=substr($unknownrefererbrowser_l{$key},0,4);
		$monthcon=substr($unknownrefererbrowser_l{$key},4,2);
		$daycon=substr($unknownrefererbrowser_l{$key},6,2);
		$hourcon=substr($unknownrefererbrowser_l{$key},8,2);
		$mincon=substr($unknownrefererbrowser_l{$key},10,2);
		if ($Lang == 1) { print "<tr align=left><td>$key</td><td align=center>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
		else { print "<tr align=left><td>$key</td><td align=center>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /unknownreferer/) {
	print "<a name=\"UNKOWNREFERER\"></a>";
	$tab_titre=$message[46][$Lang];
	&tab_head;
	print "<TR BGCOLOR=$color_TableBGRowTitle><TH align=left>Referer</TH><TH align=center>$message[9][$Lang]</TH></TR>\n";
	@sortunknownreferer=sort { $SortDir*$unknownreferer_l{$a} <=> $SortDir*$unknownreferer_l{$b} } keys (%unknownreferer_l);
	foreach $key (@sortunknownreferer) {
		$yearcon=substr($unknownreferer_l{$key},0,4);
		$monthcon=substr($unknownreferer_l{$key},4,2);
		$daycon=substr($unknownreferer_l{$key},6,2);
		$hourcon=substr($unknownreferer_l{$key},8,2);
		$mincon=substr($unknownreferer_l{$key},10,2);
		if ($Lang == 1) { print "<tr align=left><td>$key</td><td align=center>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
		else { print "<tr align=left><td>$key</td><td align=center>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /notfounderror/) {
	print "<a name=\"NOTFOUNDERROR\"></a>";
	$tab_titre=$message[47][$Lang];
	&tab_head;
	print "<TR bgcolor=$color_TableBGRowTitle align=center><TH align=left>URL</TH><TH bgcolor=$color_h>$message[49][$Lang]</TH></TR>\n";
	@sortsider404=sort { $SortDir*$sider404{$a} <=> $SortDir*$sider404{$b} } keys (%sider404);
	foreach $key (@sortsider404) {
		print "<tr align=center><td align=left>$key</td><td>$sider404{$key}</td></tr>";
	}
	&tab_end;
	&html_end;
	exit(0);
	}
if ($QueryString =~ /browserdetail/) {
	print "<a name=\"BROWSERDETAIL\"></a>";

	print "<a name=\"NETSCAPE\"></a><BR>";
	$tab_titre=$message[33][$Lang];
	&tab_head;
	print "<TR BGCOLOR=$color_TableBGRowTitle align=center><TH align=left>Version</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
	for ($i=1; $i<=$#nsver; $i++) {
		if ($nsver[$i] gt 0) {
			$h=$nsver[$i]; $p=int($nsver[$i]/$browser{"netscape"}*1000)/10; $p="$p&nbsp;%";
		}
		else {
			$h="&nbsp;"; $p="&nbsp;";
		}
		print "<TR align=center><TD align=left>Mozilla/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
	}
	&tab_end;

	print "<a name=\"MSIE\"></a><BR>";
	$tab_titre=$message[34][$Lang];
	&tab_head;
	print "<TR BGCOLOR=$color_TableBGRowTitle align=center><TH align=left>Version</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
	for ($i=1; $i<=$#msiever; $i++) {
		if ($msiever[$i] gt 0) {
			$h=$msiever[$i]; $p=int($msiever[$i]/$browser{"msie"}*1000)/10; $p="$p&nbsp;%";
		}
		else {
			$h="&nbsp;"; $p="&nbsp;";
		}
		print "<TR align=center><TD align=left>MSIE/$i.xx</TD><TD>$h</TD><TD>$p</TD></TR>\n";
	}
	&tab_end;

	&html_end;
	exit(0);
	}


if ($BenchMark == 1) { print "Start of sorting: ";print localtime();print "<br>"; }
@RobotArray=keys %RobotHash;
@SearchEnginesArray=keys %SearchEnginesHash;
@sortdomains_h=sort { $SortDir*$domener_h{$a} <=> $SortDir*$domener_h{$b} } keys (%domener_h);
@sortdomains_k=sort { $SortDir*$domener_k{$a} <=> $SortDir*$domener_k{$b} } keys (%domener_k);
@sorthosts_h=sort { $SortDir*$hostmachine_h{$a} <=> $SortDir*$hostmachine_h{$b} } keys (%hostmachine_h);
@sortsiders=sort { $SortDir*$sider_p{$a} <=> $SortDir*$sider_p{$b} } keys (%sider_p);
@sortbrowsers=sort { $SortDir*$browser{$a} <=> $SortDir*$browser{$b} } keys (%browser);
@sortos=sort { $SortDir*$OS{$a} <=> $SortDir*$OS{$b} } keys (%OS);
@sortsereferrals=sort { $SortDir*$SEReferrals{$a} <=> $SortDir*$SEReferrals{$b} } keys (%SEReferrals);
@sortpagerefs=sort { $SortDir*$PageRefs{$a} <=> $SortDir*$PageRefs{$b} } keys (%PageRefs);
@sortsearchwords=sort { $SortDir*$searchwords{$a} <=> $SortDir*$searchwords{$b} } keys (%searchwords);
@sorterrors=sort { $SortDir*$errors{$a} <=> $SortDir*$errors{$b} } keys (%errors);
if ($BenchMark == 1) { print "End of sorting: ";print localtime(); print "<br>"; }

# English tooltips
if (($Lang == 0) || ($Lang == 2)) {
	print "
	<DIV CLASS=\"classTooltip\" ID=\"tt1\">
	We count a new visits for each new <b>incoming visitor</b> viewing a page and who was not connected during last <b>".($VisitTimeOut/10000*60)." mn</b>.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt2\">
	Number of client hosts (<b>IP address</b>) who came to visit the site (and to see at list one <b>page</b>).<br>
	This number is about the number of <b>different physical persons</b> who had reached the site one day.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt3\">
	Number of time a <b>page</b> of the site is <b>viewed</b> (Sum for all visitors, all visits).<br>
	This counter differs from \"hits\" because it counts only HTML pages and not images and other files.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt4\">
	Number of time a <b>page, image, file</b> of the site is <b>viewed</b> or <b>downloaded</b> by someone.<br>
	This counter is given for indication, \"pages\" counter is often prefered.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt5\">
	Number of <b>kilobytes</b> downloaded by visitors.<br>
	It\'s the amount of data caused by download of all <b>pages</b>, <b>images</b> and <b>files</b>.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt13\">
	$PROG is able to recognize access to the site after a <b>search</b> from the <b>".(@SearchEnginesArray)." most popular Internet Search Engines</b> (Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt14\">
	List of all <b>external pages</b> that own a link followed to access the site (Only the <b>$MaxNbOfRefererShown</b> most often used external pages are shown.\n
	Links used from the result of a search engine are not included here because they are included on line above this one.
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt15\">
	This tab shows list of most often used <b>keywords</b> to find your site from Internet Search Engines web sites
	(Search from <b>".(@SearchEnginesArray)."</b> search engines among the most popular are recognized, like Yahoo, Altavista, Lycos, Google, Voila, etc...).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt16\">
	Robots are <b>automatic computer visitors</b> scanning your web site to index it, to collect statistics on Internet Web sites or to see if your site is online.<br>
	$PROG is able to recognize <b>".(@RobotArray)."</b> robots</b>.
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
	Try to reach an <b>URL where identification with login/password was required</b>.<br>
	A too important number can show you someone making brute cracking of your site (hoping to enter a secured area by trying different logins/password).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt403\">
	Try to reach an <b>URL not configured to be reachable, even with an identification</b> (for example, an URL of a directory not defined as \"browsable\".).
	</DIV>
	<DIV CLASS=\"classTooltip\" ID=\"tt404\">
	Try to reach a <b>non existing URL</b>. So it means an invalid link somewhere or a typing error made by visitor who tape a direct URL.
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
	Code returned by a HTTP server that works as a proxy or gateway when real targeted server doesn\'t answer successfully to the client request.
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
	$PROG reconnait <b>".(@RobotArray)."</b> robots</b>.
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

# Spannish tooltips
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
	El programa $PROG reconoce hasta <b>".(@RobotArray)."</b> Robots</b>.
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
$tab_titre="$message[7][$Lang] $LocalSite";
&tab_head;

# TotalUnique
foreach $key (keys %hostmachine_p) { if (($key ne "Unknown") && ($hostmachine_p{$key} > 0)) { $TotalUnique++; } }
foreach $key (keys %unknownip_l) { $TotalUnique++; }
# TotalDifferentPages
$TotalDifferentPages=@sortsiders;
# TotalPages TotalHits TotalBytes
for ($ix=0; $ix<=23; $ix++) { $TotalPages+=$time_p[$ix]; $TotalHits+=$time_h[$ix]; $TotalBytes+=$time_k[$ix]; }
# TotalDifferentKeywords
$TotalDifferentKeywords=@sortsearchwords;
# TotalKeywords
foreach $key (keys %searchwords) { $TotalKeywords+=$searchwords{$key}; }
# TotalErrors
foreach $key (keys %errors) { $TotalErrors+=$errors{$key}; }
# Ratio
if ($TotalUnique > 0) { $RatioHosts=int($TotalVisits/$TotalUnique*100)/100; }
if ($TotalVisits > 0) { $RatioPages=int($TotalPages/$TotalVisits*100)/100; }
if ($TotalVisits > 0) { $RatioHits=int($TotalHits/$TotalVisits*100)/100; }
if ($TotalVisits > 0) { $RatioBytes=int(($TotalBytes/1024/$TotalVisits)*100)/100; }

print "<TR align=center><TD><b>$message[8][$Lang]</b></TD><TD colspan=3 rowspan=2>$message[6][$Lang] $year</TD><TD><b>$message[9][$Lang]</b></TD></TR>";
$yearcon=substr($FirstTime,0,4);$monthcon=substr($FirstTime,4,2);$daycon=substr($FirstTime,6,2);$hourcon=substr($FirstTime,8,2);$mincon=substr($FirstTime,10,2);
print "<TR align=center><TD>$daycon&nbsp;$monthlib{$monthcon}&nbsp;$yearcon&nbsp;-&nbsp;$hourcon:$mincon</TD>";
$yearcon=substr($LastTime,0,4);$monthcon=substr($LastTime,4,2);$daycon=substr($LastTime,6,2);$hourcon=substr($LastTime,8,2);$mincon=substr($LastTime,10,2);
print "<TD>$daycon&nbsp;$monthlib{$monthcon}&nbsp;$yearcon&nbsp;-&nbsp;$hourcon:$mincon</TD></TR>";
print "<TR align=center>";
print "<TD width=20% bgcolor=$color_v onmouseover=\"ShowTooltip(1);\" onmouseout=\"HideTooltip(1);\">$message[10][$Lang]</TD>";
print "<TD width=20% bgcolor=$color_w onmouseover=\"ShowTooltip(2);\" onmouseout=\"HideTooltip(2);\">$message[11][$Lang]</TD>";
print "<TD width=20% bgcolor=$color_p onmouseover=\"ShowTooltip(3);\" onmouseout=\"HideTooltip(3);\">Pages</TD>";
print "<TD width=20% bgcolor=$color_h onmouseover=\"ShowTooltip(4);\" onmouseout=\"HideTooltip(4);\">Hits</TD>";
print "<TD width=20% bgcolor=$color_k onmouseover=\"ShowTooltip(5);\" onmouseout=\"HideTooltip(5);\">$message[44][$Lang]</TD></TR>";
$kilo=int($TotalBytes/1024*100)/100;
print "<TR align=center><TD><b>$TotalVisits</b><br>&nbsp;</TD><TD><b>$TotalUnique</b><br>($RatioHosts&nbsp;$message[52][$Lang])</TD><TD><b>$TotalPages</b><br>($RatioPages&nbsp;pages/$message[12][$Lang])</TD><TD><b>$TotalHits</b><br>($RatioHits&nbsp;hits/$message[12][$Lang])</TD><TD><b>$kilo $message[44][$Lang]</b><br>($RatioBytes&nbsp;$message[44][$Lang]/$message[12][$Lang])</TD></TR>\n";
print "<TR valign=bottom><TD colspan=5 align=center>";
print "<TABLE>";
print "<TR valign=bottom>";
$max_v=1;$max_u=1;$max_p=1;$max_h=1;$max_k=1;
for ($ix=1; $ix<=12; $ix++) {
	$monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
	if ($indic1{$monthix} > $max_v) { $max_v=$indic1{$monthix}; }
	if ($indic2{$monthix} > $max_v) { $max_v=$indic2{$monthix}; }
	if ($indic3{$monthix} > $max_p) { $max_p=$indic3{$monthix}; }
	if ($indic4{$monthix} > $max_h) { $max_h=$indic4{$monthix}; }
	if ($indic5{$monthix} > $max_k) { $max_k=$indic5{$monthix}; }
}
for ($ix=1; $ix<=12; $ix++) {
	$monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
	$bredde_v=$indic1{$monthix}/$max_v*$Barheight/2;
	$bredde_u=$indic2{$monthix}/$max_v*$Barheight/2;
	$bredde_p=$indic3{$monthix}/$max_h*$Barheight/2;
	$bredde_h=$indic4{$monthix}/$max_h*$Barheight/2;
	$bredde_k=$indic5{$monthix}/$max_k*$Barheight/2;
	$kilo=int(($indic5{$monthix}/1024)*100)/100;
	print "<TD align=center>";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_v\" HEIGHT=$bredde_v WIDTH=8 ALT=\"Visits: $indic1{$monthix}\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_u\" HEIGHT=$bredde_u WIDTH=8 ALT=\"Visitors: $indic2{$monthix}\">";
	print "&nbsp;";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=8 ALT=\"Pages: $indic3{$monthix}\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=8 ALT=\"Hits: $indic4{$monthix}\">";
	print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=8 ALT=\"$message[44][$Lang]: $kilo\">";
	print "</TD>\n";
}
print "</TR><TR>";
for ($ix=1; $ix<=12; $ix++) {
	$monthix=$ix; if ($monthix < 10) { $monthix="0$monthix"; }
	print "<TD align=center>$monthlib{$monthix}</TD>";
}
print "</TR></TABLE>";
print "</TD></TR>";
&tab_end;


# MENU
#---------------------------------------------------------------------
print "<br>";

print "<table width=100%><tr align=center><td>";
print " <a href=\"#DOMAINS\"><font size=1>[$message[17][$Lang]]</font></a> &nbsp;";
print " <a href=\"#VISITOR\"><font size=1>[$message[18][$Lang]]</font></a> &nbsp;";
print " <a href=\"#ROBOTS\"><font size=1>[$message[53][$Lang]]</font></a> &nbsp;";
print " <a href=\"#PAGE\"><font size=1>[$message[19][$Lang]]</font></a> &nbsp;";
print " <a href=\"#HOUR\"><font size=1>[$message[20][$Lang]]</font></a> &nbsp;";
print " <a href=\"#BROWSER\"><font size=1>[$message[21][$Lang]]</font></a> &nbsp;";
print " <a href=\"#REFERER\"><font size=1>[$message[23][$Lang]]</font></a> &nbsp;";
print " <a href=\"#SEARCHWORDS\"><font size=1>[$message[24][$Lang]]</font></a> &nbsp;";
print " <a href=\"#ERRORS\"><font size=1>[$message[22][$Lang]]</font></a> &nbsp;";
print "</td></tr></table>";

print "<br><hr width=96%>";


# BY COUNTRY/DOMAIN
#---------------------------
print "<a name=\"DOMAINS\"></a><BR>";
$tab_titre="$message[25][$Lang]";
&tab_head;
print "<TR align=center BGCOLOR=$color_TableBGRowTitle><TH colspan=2>$message[17][$Lang]</TH><TH>Code</TH><TH bgcolor=$color_p>Pages</TH><TH bgcolor=$color_h>Hits</TH><TH bgcolor=$color_k>$message[44][$Lang]</TH><TH>&nbsp;</TH></TR>\n";
if ($SortDir<0) { $max_h=$domener_h{$sortdomains_h[0]}; }
else            { $max_h=$domener_h{$sortdomains_h[$#sortdomains_h]}; }
if ($SortDir<0) { $max_k=$domener_k{$sortdomains_k[0]}; }
else            { $max_k=$domener_k{$sortdomains_k[$#sortdomains_k]}; }
foreach $key (@sortdomains_h) {
        if ($max_h > 0) { $bredde_p=$Barwidth*$domener_p{$key}/$max_h+1; }	# use max_h to enable to compare pages with hits
        if ($max_h > 0) { $bredde_h=$Barwidth*$domener_h{$key}/$max_h+1; }
        if ($max_k > 0) { $bredde_k=$Barwidth*$domener_k{$key}/$max_k+1; }
		$page=$domener_p{$key};if ($page eq "") { $page=0; }
        $kilo=int(($domener_k{$key}/1024)*100)/100;
		if ($key eq "ip") {
			print "<TR align=center><TD><IMG SRC=\"$DirIcons\/flags\/$key.png\" height=14></TD><TD align=left>$message[0][$Lang]</TD><TD align=center>$key</TD>";
		}
		else {
			print "<TR align=center><TD><IMG SRC=\"$DirIcons\/flags\/$key.png\" height=14></TD><TD align=left>$DomainsHash{$key}</TD><TD align=center>$key</TD>";
		}
        print "<TD>$page</TD><TD>$domener_h{$key}</TD><TD>$kilo</TD>";
        print "<TD align=left>";
        print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde_p HEIGHT=6 ALT=\"Pages: $domener_p{$key}\"><br>\n";
        print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_h\" WIDTH=$bredde_h HEIGHT=6 ALT=\"Hits: $domener_h{$key}\"><br>\n";
        print "<IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_k\" WIDTH=$bredde_k HEIGHT=6 ALT=\"$message[44][$Lang]: $kilo\">";
        print "</TD></TR>\n";
}
&tab_end;


# BY HOST/VISITOR
#--------------------------
print "<a name=\"VISITOR\"></a>";
$tab_titre="TOP $MaxNbOfHostsShown $message[55][$Lang] ".(@sorthosts_h)." $message[26][$Lang] ($TotalUnique $message[11][$Lang])";
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle><TH align=left>$message[18][$Lang]</TH><TH bgcolor=$color_p>Pages</TH><TH bgcolor=$color_h>Hits</TH><TH bgcolor=$color_k>$message[44][$Lang]</TH><TH>$message[9][$Lang]</TH></TR>\n";
$count=0;$total_p=0;$total_h=0;$total_k=0;
foreach $key (@sorthosts_h)
{
  if ($hostmachine_h{$key}>=$MinHitHost) {
	$page=$hostmachine_p{$key};if ($page eq "") { $page=0; }
    $kilo=int(($hostmachine_k{$key}/1024)*100)/100;
	if ($key eq "Unknown") {
		print "<TR align=center><TD align=left><a href=\"$PROG.pl?action=unknownip&lang=$Lang\">$message[1][$Lang]</a></TD><TD>$page</TD><TD>$hostmachine_h{$key}</TD><TD>$kilo</TD><TD><a href=\"$PROG.pl?action=unknownip&lang=$Lang\">$message[3][$Lang]</a></TD></TR>\n";
		}
	else {
		$yearcon=substr($hostmachine_l{$key},0,4);
		$monthcon=substr($hostmachine_l{$key},4,2);
		$daycon=substr($hostmachine_l{$key},6,2);
		$hourcon=substr($hostmachine_l{$key},8,2);
		$mincon=substr($hostmachine_l{$key},10,2);
		print "<tr align=center><td align=left>$key</td><TD>$page</TD><TD>$hostmachine_h{$key}</TD><TD>$kilo</TD>";
		if ($Lang != 0) { print "<td align=center>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
		else { print "<td align=center>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
	}

    $total_p += $hostmachine_p{$key};
    $total_h += $hostmachine_h{$key};
    $total_k += $hostmachine_k{$key};
  }
  $count++;
  if (!(($SortDir<0 && $count<$MaxNbOfHostsShown) || ($SortDir>0 && $#sorthosts_h-$MaxNbOfHostsShown < $count))) { last; }
}
$rest_p=$TotalPages-$total_p;
$rest_h=$TotalHits-$total_h;
$rest_k=int((($TotalBytes-$total_k)/1024)*100)/100;
if ($rest_p > 0) { print "<TR align=center><TD align=left><font color=blue>$message[2][$Lang]</font></TD><TD>$rest_p</TD><TD>$rest_h</TD><TD>$rest_k</TD><TD>&nbsp;</TD></TR>\n"; }	# All other visitors (known or not)
&tab_end;


# BY ROBOTS
#----------------------------
print "<a name=\"ROBOTS\"></a><BR>";
$tab_titre=$message[53][$Lang];
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle onmouseover=\"ShowTooltip(16);\" onmouseout=\"HideTooltip(16);\"><TH align=left>Robot</TH><TH align=center bgcolor=$color_h width=80>Hits</TH><TH>$message[9][$Lang]</TH></TR>\n";
@sortrobot=sort { $SortDir*$robot{$a} <=> $SortDir*$robot{$b} } keys (%robot);
foreach $key (@sortrobot) {
	$yearcon=substr($robot_l{$key},0,4);
	$monthcon=substr($robot_l{$key},4,2);
	$daycon=substr($robot_l{$key},6,2);
	$hourcon=substr($robot_l{$key},8,2);
	$mincon=substr($robot_l{$key},10,2);
	if ($Lang != 0) { print "<tr align=left><td>$RobotHash{$key}</td><td align=center>$robot{$key}</td><td align=center>$daycon/$monthcon/$yearcon - $hourcon:$mincon</td></tr>"; }
	else { print "<tr align=left><td>$RobotHash{$key}</td><td align=center>$robot{$key}</td><td align=center>$daycon $monthlib{$monthcon} $yearcon - $hourcon:$mincon</td></tr>"; }
}
&tab_end;


# BY PAGE
#-------------------------
print "<a name=\"PAGE\"></a><BR>";
$tab_titre="TOP $MaxNbOfPageShown $message[55][$Lang] $TotalDifferentPages $message[27][$Lang]";
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle><TH>Page-URL</TH><TH bgcolor=$color_p align=center>&nbsp;$message[29][$Lang]&nbsp;</TH><TH>&nbsp;</TH></TR>\n";
if ($SortDir<0) { $max=$sider_p{$sortsiders[0]}; }
else            { $max=$sider_p{$sortsiders[$#sortsiders]}; }
$count=0;
foreach $key (@sortsiders) {
	if ((($SortDir<0 && $count<$MaxNbOfPageShown) || ($SortDir>0 && $#sortsiders-$MaxNbOfPageShown<$count)) && $sider_p{$key}>=$MinHitFile) {
    	print "<TR><TD>";
		$nompage=$Aliases{$key};
		if ($nompage eq "") { $nompage=$key; }
		$nompage=substr($nompage,0,$MaxLengthOfURL);
	    if ($ShowLinksOnUrl) { print "<A HREF=\"$key\">$nompage</A>"; }
	    else              	 { print "$nompage"; }
	    $bredde=$Barwidth*$sider_p{$key}/$max+1;
		print "</TD><TD align=center>$sider_p{$key}</TD><TD><IMG SRC=\"$DirIcons\/other\/$BarImageHorizontal_p\" WIDTH=$bredde HEIGHT=8 ALT=\"Pages: $sider_p{$key}\"></TD></TR>\n";
  	}
  	$count++;
}
&tab_end;


# BY HOUR
#----------------------------
print "<a name=\"HOUR\"></a><BR>";
$tab_titre="$message[20][$Lang]";
&tab_head;

print "<TR><TD align=center><TABLE><TR>\n";
$max_p=0;$max_h=0;$max_k=0;
for ($ix=0; $ix<=23; $ix++) {
  print "<TH width=16>$ix</TH>";
  if ($time_p[$ix]>$max_p) { $max_p=$time_p[$ix]; }
  if ($time_h[$ix]>$max_h) { $max_h=$time_h[$ix]; }
  if ($time_k[$ix]>$max_k) { $max_k=$time_k[$ix]; }
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
  if ($max_h > 0) { $bredde_p=$Barheight*$time_p[$ix]/$max_h+1; }
  if ($max_h > 0) { $bredde_h=$Barheight*$time_h[$ix]/$max_h+1; }
  if ($max_k > 0) { $bredde_k=$Barheight*$time_k[$ix]/$max_k+1; }
  $kilo=int(($time_k[$ix]/1024)*100)/100;
  print "<TD>";
  print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_p\" HEIGHT=$bredde_p WIDTH=6 ALT=\"Pages: $time_p[$ix]\">";
  print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_h\" HEIGHT=$bredde_h WIDTH=6 ALT=\"Hits: $time_h[$ix]\">";
  print "<IMG SRC=\"$DirIcons\/other\/$BarImageVertical_k\" HEIGHT=$bredde_k WIDTH=6 ALT=\"$message[44][$Lang]: $kilo\">";
  print "</TD>\n";
}
print "</TR></TABLE></TD></TR>\n";

&tab_end;


# BY BROWSER
#----------------------------
print "<a name=\"BROWSER\"></a><BR>";
$tab_titre="$message[31][$Lang]";
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle align=center><TH align=left>Browser</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
foreach $key (@sortbrowsers) {
	$p=int($browser{$key}/$TotalHits*1000)/10;
	if ($key eq "Unknown") {
		print "<TR align=center><TD align=left><a href=\"$PROG.pl?action=unknownrefererbrowser&lang=$Lang\">$message[0][$Lang]</a></TD><TD>$browser{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
	}
	else {
		print "<TR align=center><TD align=left>$BrowsersHash{$key}</TD><TD>$browser{$key}</TD><TD>$p&nbsp;%</TD></TR>\n";
	}
}
&tab_end;


# BY OS
#----------------------------
print "<a name=\"OS\"></a><BR>";
$tab_titre=$message[35][$Lang];
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle align=center><TH align=left colspan=2>OS</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
foreach $key (@sortos) {
	$p=int($OS{$key}/$TotalHits*1000)/10;
	if ($key eq "Unknown") {
		print "<TR align=center><TD><IMG SRC=\"$DirIcons\/os\/unknown.png\"></TD><TD align=left><a href=\"$PROG.pl?action=unknownreferer&lang=$Lang\">$message[0][$Lang]</a></TD><TD>$OS{$key}&nbsp;</TD>";
		print "<TD>$p&nbsp;%</TD></TR>\n";
		}
	else {
		$nameicon = $OSHash{$key}; $nameicon =~ s/\ .*//; $nameicon =~ tr/A-Z/a-z/;
		print "<TR align=center><TD><IMG SRC=\"$DirIcons\/os\/$nameicon.png\"></TD><TD align=left>$OSHash{$key}</TD><TD>$OS{$key}</TD>";
		print "<TD>$p&nbsp;%</TD></TR>\n";
	}
}
&tab_end;


# BY REFERENCE
#---------------------------
print "<a name=\"REFERER\"></a><BR>";
$tab_titre="$message[36][$Lang]";
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle align=center><TH align=left>$message[37][$Lang]</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
if ($TotalHits > 0) { $_=int($HitFrom[0]/$TotalHits*1000)/10; }
print "<TR align=center><TD align=left><b>$message[38][$Lang]:</b></TD><TD>$HitFrom[0]</TD><TD>$_&nbsp;%</TD></TR>\n";
if ($TotalHits > 0) { $_=int($HitFrom[1]/$TotalHits*1000)/10; }
print "<TR align=center><TD align=left><b>$message[39][$Lang]:</b></TD><TD>$HitFrom[1]</TD><TD>$_&nbsp;%</TD></TR>\n";
#------- Referrals by search engine
if ($TotalHits > 0) { $_=int($HitFrom[2]/$TotalHits*1000)/10; }
print "<TR align=center onmouseover=\"ShowTooltip(13);\" onmouseout=\"HideTooltip(13);\"><TD align=left><b>$message[40][$Lang] :</b><br>";
print "<TABLE>\n";
foreach $SE (@sortsereferrals) {
    print "<TR><TD align=left>- $SearchEnginesHash{$SE} </TD><TD align=right>$SEReferrals{\"$SE\"}</TD></TR>\n";
}
print "</TABLE></TD>\n";
print "<TD valign=top>$HitFrom[2]</TD><TD valign=top>$_&nbsp;%</TD></TR>\n";
#------- Referrals by external HTML link
if ($TotalHits > 0) { $_=(int($HitFrom[3]/$TotalHits*1000)/10); }
print "<TR align=center onmouseover=\"ShowTooltip(14);\" onmouseout=\"HideTooltip(14);\"><TD align=left><b>$message[41][$Lang] :</b><br>";
print "<TABLE>\n";
$count=0;
foreach $from (@sortpagerefs) {
	if (!(($SortDir<0 && $count<$MaxNbOfRefererShown) || ($SortDir>0 && $#sortpagerefs-$MaxNbOfRefererShown < $count))) { last; }
	if ($PageRefs{$from}>=$MinHitRefer) {

		# Show source
		$lien=$from;
		$lien =~ s/\"//g;
		$lien=substr($lien,0,$MaxLengthOfURL);
		if ($ShowLinksOnUrl && ($lien =~ /(ftp|http):\/\//)) {
		    print "<TR align=center><TD align=left>- <A HREF=$from>$lien</A></TD> <TD>$PageRefs{$from}</TD></TR>\n";
		} else {
			print "<TR align=center><TD align=left>- $lien </TD><TD>$PageRefs{$from}</TD></TR>\n";
		}

		$count++;
	}
}
print "</TABLE></TD>\n";
print "<TD valign=top>$HitFrom[3]</TD><TD valign=top>$_&nbsp;%</TD></TR>\n";

if ($TotalHits > 0) { $_=(int($HitFrom[4]/$TotalHits*1000)/10); }
print "<TR align=center><TD align=left><b>$message[42][$Lang] :</b></TD><TD>$HitFrom[4]</TD><TD>$_&nbsp;%</TD></TR>\n";
&tab_end;


# BY SEARCHWORDS
#----------------------------
print "<a name=\"SEARCHWORDS\"></a><BR>";
$tab_titre="TOP $MaxNbOfKeywordsShown $message[55][$Lang] $TotalDifferentKeywords $message[43][$Lang]";
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle align=center onmouseover=\"ShowTooltip(15);\" onmouseout=\"HideTooltip(15);\"><TH align=left>$message[13][$Lang]</TH><TH bgcolor=$color_s width=40>$message[14][$Lang]</TH><TH bgcolor=$color_s width=40>$message[15][$Lang]</TH></TR>\n";
$count=0;
foreach $key (@sortsearchwords) {
	if ( $count>=$MaxNbOfKeywordsShown ) { last; }
	$p=int($searchwords{$key}/$TotalKeywords*1000)/10;
	print "<TR align=center><TD align=left>$key</TD><TD>$searchwords{$key}</TD>";
	print "<TD>$p&nbsp;%</TD></TR>\n";
	$count++;
}
$count=0;$rest=0;
foreach $key (@sortsearchwords) {
	if ( $count<$MaxNbOfKeywordsShown ) { $count++; next; }
	$rest=$rest+$searchwords{$key};
}
if ($rest >0) {
	if ($TotalKeywords > 0) { $p=int($rest/$TotalKeywords*1000)/10; }
	print "<TR align=center><TD align=left><font color=blue>$message[30][$Lang]</TD><TD>$rest</TD>";
	print "<TD>$p&nbsp;%</TD></TR>\n";
	}
&tab_end;


# BY ERRORS
#----------------------------
print "<a name=\"ERRORS\"></a><BR>";
$tab_titre=$message[32][$Lang];
&tab_head;
print "<TR BGCOLOR=$color_TableBGRowTitle align=center><TH align=left colspan=2>$message[32][$Lang]</TH><TH bgcolor=$color_h width=40>Hits</TH><TH bgcolor=$color_h width=40>$message[15][$Lang]</TH></TR>\n";
foreach $key (@sorterrors) {
	$p=int($errors{$key}/$TotalErrors*1000)/10;
	if ($httpcode{$key}) { print "<TR align=center onmouseover=\"ShowTooltip($key);\" onmouseout=\"HideTooltip($key);\">"; }
	else { print "<TR align=center>"; }
	if ($key == 404) { print "<TD><a href=\"$PROG.pl?action=notfounderror&lang=$Lang\">$key</a></TD>"; }
	else { print "<TD>$key</TD>"; }
	if ($httpcode{$key}) { print "<TD align=left>$httpcode{$key}</TD><TD>$errors{$key}</TD><TD>$p&nbsp;%</TD></TR>\n"; }
	else { print "<TD align=left>Unknown error</TD><TD>$errors{$key}</TD><TD>$p&nbsp;%</TD></TR>\n"; }
}
&tab_end;


&html_end;

%define name awstats
%define version	__VERSION__
# For Mandrake
#%define release 1mdk
# For all other distrib
%define release 1

Name: %{name}
Version: %{version}
Release: %{release}
Summary: AWStats is a free powerful and featureful server logfile analyzer.

License: GPL
Packager: Laurent Destailleur (Eldy) <eldy@users.sourceforge.net>
Vendor: Laurent Destailleur

URL: http://%{name}.sourceforge.net
Source: http://dl.sf.net/awstats/%{name}-%{version}.tgz
BuildArch: noarch
BuildArchitectures: noarch
BuildRoot: /tmp/%{name}-buildroot
Icon: awstats_logo1.gif

# For Mandrake
Group: Networking/WWW
# For all other distrib
Group: Applications/Internet

#Requires=perl
AutoReqProv: yes


%description
AWStats (Advanced Web Statistics) is a free powerful and featureful
tool that generates advanced web (but also ftp or mail) server
statistics, graphically.

This log analyzer works as a CGI or from command line and shows you
all possible information your log contains, in few graphical web
pages like visits, unique vistors, authenticated users, pages,
domains/countries, OS busiest times, robot visits, type of files,
search engines,keywords and keyphrases used, visits duration,
cluster balancing, HTTP errors and also screen size, web browser
java,flash,etc support and more...
Statistics can be updated from a browser or your scheduler.
AWStats uses a partial information file to be able to process large
log files, often and quickly.

It can analyze log files from IIS (W3C log format), Apache log files
(NCSA combined/XLF/ELF log format or common/CLF log format), WebStar
and most of all web, proxy, wap, streaming servers (and ftp servers
or mail logs).
The program also supports virtual servers, plugins and a lot of
features.

%description -l pl
awstats (Advanced Web Statistics - zaawansowane statystyki WWW) to
potê¿ne i bogate w mo¿liwo¶ci narzêdzie generuj±ce zaawansowane
graficzne statystyki serwera WWW. Ten analizator logów serwera
dzia³a z linii poleceñ lub jako CGI i pokazuje wszystkie informacje
zawarte w logu w postaci graficznych stron WWW. Mo¿e analizowaæ logi
wielu serwerów WWW/WAP/proxy, takich jak Apache, IIS, Weblogic,
Webstar, Squid... ale tak¿e serwerów pocztowych lub ftp.

Ten program mo¿e mierzyæ odwiedziny, odwiedzaj±cych, uwierzytelnionych
u¿ytkowników, strony, domeny/kraje, najbardziej zajête godziny,
odwiedziny robotów, rodzaje plików, u¿ywane wyszukiwarki i s³owa
kluczowe, czasy trwania odwiedzin, b³êdy HTTP... a nawet wiêcej.
Statystyki mog± byæ uaktualniane z przegl±darki lub schedulera.
Program obs³uguje tak¿e serwery wirtualne, wtyczki i wiele innych
rzeczy.

%description -l fr
AWStats (Advanced Web Statistics) est un outils pour générer des 
statistiques avancés d'un serveur web (mais aussi ftp ou mail)
de manière graphique.

Cet analyseur de log fonctionne en CGI ou en ligne de commande
et syntétise toutes les informations que vos logs contiennent en
quelques pages comme les visites, visiteurs uniques, logins,
pages vues, domaines/pays, heures de pointes, visites des robots, 
type de fichiers, moteurs de recherche, mots et phrases clés,
durée des visites, répartition clusters, erreurs HTTP mais aussi
support java,flash,etc des navigateurs, résolution d'écran,
estimation des ajouts aux favoris, etc...

Les statistiques peuvent etre mise à jour par un navigateur ou un
séquenceur.
AWStats génère un fichier d'informations consolidés pour pouvoir
traiter de large sites souvent et rapidement.

Il peut analyser des logs IIS (W3C log format), fichier log Apache
(format NCSA combined/XLF/ELF ou format common/CLF), WebStar et la
plupart des logs de serveur web, proxy, wap, streaming serveurs
(et aussi serveurs ftp et de mails).
Ce programme supporte de plus les serveurs virtuels, des plugins
et de nombreuses fonctionalités.




#---- prep
%prep
%setup -q


#---- build
%build
# Nothing to build


#---- install
%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/tools
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/tools/webmin
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/tools/xslt
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/classes
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/classes/src
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/lib
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/plugins
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/plugins/example
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/css
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/browser
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/clock
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/cpu
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/flags
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/mime
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/os
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/other
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/js
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/lang
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/lang/tooltips_f
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/lang/tooltips_m
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/lang/tooltips_w
#mkdir -p $RPM_BUILD_ROOT/usr/share/awstats/lang
#mkdir -p $RPM_BUILD_ROOT/usr/share/awstats/man
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/docs
mkdir -p $RPM_BUILD_ROOT/usr/local/awstats/docs/images
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/awstats
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/cron.daily
mkdir -p /var/lib/awstats

install -m 444 tools/httpd_conf $RPM_BUILD_ROOT/usr/local/awstats/tools/httpd_conf
install -m 755 tools/logresolvemerge.pl $RPM_BUILD_ROOT/usr/local/awstats/tools/logresolvemerge.pl
install -m 755 tools/maillogconvert.pl $RPM_BUILD_ROOT/usr/local/awstats/tools/maillogconvert.pl
install -m 755 tools/urlaliasbuilder.pl $RPM_BUILD_ROOT/usr/local/awstats/tools/urlaliasbuilder.pl
install -m 755 tools/awstats_buildstaticpages.pl $RPM_BUILD_ROOT/usr/local/awstats/tools/awstats_buildstaticpages.pl
install -m 755 tools/awstats_configure.pl $RPM_BUILD_ROOT/usr/local/awstats/tools/awstats_configure.pl
install -m 755 tools/awstats_exportlib.pl $RPM_BUILD_ROOT/usr/local/awstats/tools/awstats_exportlib.pl
install -m 755 tools/awstats_updateall.pl $RPM_BUILD_ROOT/usr/local/awstats/tools/awstats_updateall.pl
install -m 755 tools/webmin/* $RPM_BUILD_ROOT/usr/local/awstats/tools/webmin
install -m 755 tools/xslt/* $RPM_BUILD_ROOT/usr/local/awstats/tools/xslt
install -m 755 wwwroot/classes/awgraphapplet.jar $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/classes/awgraphapplet.jar
install -m 755 wwwroot/classes/src/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/classes/src
install -m 755 wwwroot/cgi-bin/awstats.pl $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/awstats.pl
install -m 755 wwwroot/cgi-bin/awredir.pl $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/awredir.pl
install -m 755 wwwroot/cgi-bin/lib/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/lib
install -m 755 wwwroot/cgi-bin/plugins/*.pm $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/plugins
install -m 755 wwwroot/cgi-bin/plugins/example/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/plugins/example
install -m 644 wwwroot/cgi-bin/awstats.model.conf $RPM_BUILD_ROOT/%{_sysconfdir}/awstats/awstats.model.conf
install -m 444 wwwroot/css/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/css
install -m 444 wwwroot/icon/browser/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/browser
install -m 444 wwwroot/icon/clock/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/clock
install -m 444 wwwroot/icon/cpu/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/cpu
install -m 444 wwwroot/icon/flags/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/flags
install -m 444 wwwroot/icon/mime/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/mime
install -m 444 wwwroot/icon/os/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/os
install -m 444 wwwroot/icon/other/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/icon/other
install -m 444 wwwroot/js/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/js
install -m 444 wwwroot/cgi-bin/lang/tooltips_f/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/lang/tooltips_f
install -m 444 wwwroot/cgi-bin/lang/tooltips_m/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/lang/tooltips_m
install -m 444 wwwroot/cgi-bin/lang/tooltips_w/* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/lang/tooltips_w
install -m 444 wwwroot/cgi-bin/lang/awstats* $RPM_BUILD_ROOT/usr/local/awstats/wwwroot/cgi-bin/lang
install -m 444 README.TXT  $RPM_BUILD_ROOT/usr/local/awstats/README.TXT
#install -m 644 README.TXT  $RPM_BUILD_ROOT/usr/share/awstats/man
install -m 444 docs/*.* $RPM_BUILD_ROOT/usr/local/awstats/docs
install -m 444 docs/images/* $RPM_BUILD_ROOT/usr/local/awstats/docs/images

#---- clean
%clean
rm -rf $RPM_BUILD_ROOT


#---- files
%files
%defattr(-,root,root)
%doc README.TXT
%doc /usr/local/awstats/docs/*
%config /%{_sysconfdir}/awstats/*
%dir /usr/local/awstats/wwwroot
%dir /usr/local/awstats/tools

/usr/local/awstats/README.TXT
/usr/local/awstats/wwwroot/*
/usr/local/awstats/tools/*


#---- post
%post

# Create a config file
#if [ 1 -eq 1 ]; then
#  if [ ! -f /%{_sysconfdir}/awstats/awstats.`hostname`.conf ]; then
#    /bin/cat /%{_sysconfdir}/awstats/awstats.model.conf | \
#      /usr/bin/perl -p -e 's|^SiteDomain=.*$|SiteDomain="'`hostname`'"|;
#                       s|^HostAliases=.*$|HostAliases="REGEX[^.*'${HOSTNAME//./\\\\.}'\$]"|;
#                      ' > /%{_sysconfdir}/awstats/awstats.`hostname`.conf || :
#  fi
#fi

# Show result
echo
echo ----- AWStats %version - Laurent Destailleur -----
echo AWStats files have been installed in /usr/local/awstats
echo
echo If first install, follow instructions in documentation
echo \(/usr/local/awstats/docs/index.html\) to setup AWStats in 3 steps:
echo Step 1 : Install and Setup with awstats_configure.pl \(or manually\)
echo Step 2 : Build/Update Statistics with awstats.pl
echo Step 3 : Read Statistics
echo


%changelog


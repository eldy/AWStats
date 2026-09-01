%define name awstats
%define version __VERSION__
%define release 1

Name: %{name}
Version: %{version}
Release: %{release}
Source0: %{name}-%{version}.tgz
Summary: AWStats is a free powerful and featureful server logfile analyzer.

License: GPL
Packager: Laurent Destailleur (Eldy) <eldy@users.sourceforge.net>
Vendor: Laurent Destailleur

BuildArchitectures: noarch
BuildRoot: /tmp/%{name}-buildroot
Group: Applications/Internet

# 依赖
Requires: perl >= 1:5.020
Requires: perl(JSON::XS)
Requires: perl(Try::Tiny)
Requires: wget
Recommends: cron, httpd, ca-certificates
AutoReqProv: yes

%description
AWStats (Advanced Web Statistics) is a free powerful and featureful
tool that generates advanced web (but also ftp or mail) server
statistics, graphically.

This log analyzer works as a CGI or from command line and shows you
all possible information your log contains, in few graphical web
pages like visits, unique visitors, authenticated users, pages,
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
potężne i bogate w możliwości narzędzie generujące zaawansowane
graficzne statystyki serwera WWW. Ten analizator logów serwera
działa z linii poleceń lub jako CGI i pokazuje wszystkie informacje
zawarte w logu w postaci graficznych stron WWW. Może analizować logi
wielu serwerów WWW/WAP/proxy, takich jak Apache, IIS, Weblogic,
Webstar, Squid... ale także serwerów pocztowych lub ftp.

Ten program może mierzyć odwiedziny, odwiedzających, uwierzytelnionych
użytkowników, strony, domeny/kraje, najbardziej zajęte godziny,
odwiedziny robotów, rodzaje plików, używane wyszukiwarki i słowa
kluczowe, czasy trwania odwiedzin, błędy HTTP... a nawet więcej.
Statystyki mogą być uaktualniane z przeglądarki lub schedulera.
Program obsługuje także serwery wirtualne, wtyczki i wiele innych
rzeczy.

%description -l fr
AWStats (Advanced Web Statistics) est un outil pour générer des 
statistiques avancées d'un serveur web (mais aussi ftp ou mail)
de manière graphique.

Cet analyseur de log fonctionne en CGI ou en ligne de commande
et synthétise toutes les informations que vos logs contiennent en
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
et de nombreuses fonctionnalités.

#---- prep
%prep
%setup -q -n %{name}-%{version}

#---- build
%build
# Nothing to build

#---- install
%install
rm -rf $RPM_BUILD_ROOT

# 创建目录
mkdir -p $RPM_BUILD_ROOT/usr/share/awstats
mkdir -p $RPM_BUILD_ROOT/usr/share/awstats/icon
mkdir -p $RPM_BUILD_ROOT/usr/share/awstats/css
mkdir -p $RPM_BUILD_ROOT/usr/share/awstats/js
mkdir -p $RPM_BUILD_ROOT/usr/share/awstats/classes
mkdir -p $RPM_BUILD_ROOT/usr/share/awstats/tools
mkdir -p $RPM_BUILD_ROOT/usr/lib/cgi-bin
mkdir -p $RPM_BUILD_ROOT/usr/local/bin
mkdir -p $RPM_BUILD_ROOT/etc/awstats
mkdir -p $RPM_BUILD_ROOT/etc/cron.d
mkdir -p $RPM_BUILD_ROOT/etc/cron.monthly
mkdir -p $RPM_BUILD_ROOT/etc/logrotate.d
mkdir -p $RPM_BUILD_ROOT/var/lib/awstats
mkdir -p $RPM_BUILD_ROOT/var/log/awstats
mkdir -p $RPM_BUILD_ROOT/usr/share/perl5/Geo
mkdir -p $RPM_BUILD_ROOT/usr/share/doc/awstats

# 创建 Apache 配置文件
mkdir -p $RPM_BUILD_ROOT/etc/httpd/conf.d
cat > $RPM_BUILD_ROOT/etc/httpd/conf.d/awstats.conf << 'EOF'
Alias /awstatsclasses "/usr/share/awstats/classes/"
Alias /awstatscss "/usr/share/awstats/css/"
Alias /awstatsicons "/usr/share/awstats/icon/"
Alias /awstatsdocs "/usr/share/doc/awstats/"
ScriptAlias /awstats/ "/usr/lib/cgi-bin/"

<Directory "/usr/share/awstats">
    Options None
    AllowOverride None
    Require all granted
</Directory>

<IfModule mod_env.c>
    SetEnv PERL5LIB /usr/share/awstats/lib:/usr/share/awstats/plugins
</IfModule>
EOF

# 复制 webmin 模块 - 使用绝对路径
if [ -d "$RPM_BUILD_DIR/%{name}-%{version}/tools/webmin/awstats" ]; then
    mkdir -p $RPM_BUILD_ROOT/usr/share/awstats/tools/webmin
    cd $RPM_BUILD_DIR/%{name}-%{version}/tools/webmin
    tar -czf awstats-2.0.wbm awstats/
    cp awstats-2.0.wbm $RPM_BUILD_ROOT/usr/share/awstats/tools/webmin/
    cd $RPM_BUILD_DIR/%{name}-%{version}
fi

# 复制 MaxMind 模块到 Perl 库路径
MAXMIND_SRC="$RPM_BUILD_DIR/%{name}-%{version}/wwwroot/cgi-bin/lib/MaxMind"
if [ -d "$MAXMIND_SRC" ]; then
    mkdir -p $RPM_BUILD_ROOT/usr/share/perl5/vendor_perl
    cp -pr "$MAXMIND_SRC" $RPM_BUILD_ROOT/usr/share/perl5/vendor_perl/
    echo "✓ Copied MaxMind module to Perl library path"
else
    echo "⚠ ERROR: MaxMind source directory not found at $MAXMIND_SRC"
    echo "  Contents of $RPM_BUILD_DIR/%{name}-%{version}/wwwroot/cgi-bin/lib/:"
    ls -la $RPM_BUILD_DIR/%{name}-%{version}/wwwroot/cgi-bin/lib/ || true
    exit 1
fi

# 批量复制所有文件
cp -pr $RPM_BUILD_DIR/%{name}-%{version}/docs/* $RPM_BUILD_ROOT/usr/share/doc/awstats/ 2>/dev/null || true
cp -pr $RPM_BUILD_DIR/%{name}-%{version}/wwwroot/* $RPM_BUILD_ROOT/usr/share/awstats/ 2>/dev/null || true

# 移动 CGI 脚本到 /usr/lib/cgi-bin
mv $RPM_BUILD_ROOT/usr/share/awstats/cgi-bin/* $RPM_BUILD_ROOT/usr/lib/cgi-bin/ 2>/dev/null || true
rm -rf $RPM_BUILD_ROOT/usr/share/awstats/cgi-bin 2>/dev/null || true

cp -pr $RPM_BUILD_DIR/%{name}-%{version}/tools $RPM_BUILD_ROOT/usr/share/awstats/ 2>/dev/null || true
cp -pr $RPM_BUILD_DIR/%{name}-%{version}/README.md $RPM_BUILD_ROOT/usr/share/awstats/ 2>/dev/null || true

# 移动 lang/lib/plugins 到正确位置
if [ -d "$RPM_BUILD_ROOT/usr/share/awstats/lang" ]; then
    mv $RPM_BUILD_ROOT/usr/share/awstats/lang $RPM_BUILD_ROOT/usr/share/awstats/lang
fi
if [ -d "$RPM_BUILD_ROOT/usr/share/awstats/lib" ]; then
    mv $RPM_BUILD_ROOT/usr/share/awstats/lib $RPM_BUILD_ROOT/usr/share/awstats/lib
fi
if [ -d "$RPM_BUILD_ROOT/usr/share/awstats/plugins" ]; then
    mv $RPM_BUILD_ROOT/usr/share/awstats/plugins $RPM_BUILD_ROOT/usr/share/awstats/plugins
fi

# 复制配置文件
cp -pr $RPM_BUILD_DIR/%{name}-%{version}/wwwroot/cgi-bin/awstats.conf $RPM_BUILD_ROOT/etc/awstats/awstats.conf
cp -pr $RPM_BUILD_DIR/%{name}-%{version}/wwwroot/cgi-bin/awstats.model.conf $RPM_BUILD_ROOT/etc/awstats/awstats.model.conf

# 创建空配置文件
touch $RPM_BUILD_ROOT/etc/awstats/awstats.local.conf

# 复制 MaxMind 模块
MAXMIND_SRC="$RPM_BUILD_DIR/%{name}-%{version}/wwwroot/cgi-bin/lib/MaxMind"
if [ -d "$MAXMIND_SRC" ]; then
    mkdir -p $RPM_BUILD_ROOT/usr/share/perl5/vendor_perl
    cp -pr "$MAXMIND_SRC" $RPM_BUILD_ROOT/usr/share/perl5/vendor_perl/
fi

# 复制 IPfree 模块
if [ -f $RPM_BUILD_DIR/%{name}-%{version}/wwwroot/cgi-bin/lib/IPfree.pm ]; then
    cp -pr $RPM_BUILD_DIR/%{name}-%{version}/wwwroot/cgi-bin/lib/IPfree.pm $RPM_BUILD_ROOT/usr/share/perl5/Geo/IPfree.pm
    chmod 644 $RPM_BUILD_ROOT/usr/share/perl5/Geo/IPfree.pm
fi

if [ -f $RPM_BUILD_DIR/%{name}-%{version}/wwwroot/cgi-bin/lib/IPfree.pod ]; then
    cp -pr $RPM_BUILD_DIR/%{name}-%{version}/wwwroot/cgi-bin/lib/IPfree.pod $RPM_BUILD_ROOT/usr/share/perl5/Geo/IPfree.pod
    chmod 644 $RPM_BUILD_ROOT/usr/share/perl5/Geo/IPfree.pod
fi

# 创建 CLI 包装脚本
cat > $RPM_BUILD_ROOT/usr/local/bin/awstats << 'EOF'
#!/bin/bash
perl /usr/lib/cgi-bin/awstats.pl "$@"
EOF
chmod 755 $RPM_BUILD_ROOT/usr/local/bin/awstats

# 创建 cron 任务
cat > $RPM_BUILD_ROOT/etc/cron.d/awstats << 'EOF'
# AWStats cron job
# Run AWStats update daily at 1:00 AM
0 1 * * * root [ -x /usr/share/awstats/tools/awstats_updateall.pl ] && /usr/share/awstats/tools/awstats_updateall.pl now > /dev/null 2>&1
EOF

# 创建 logrotate 配置
cat > $RPM_BUILD_ROOT/etc/logrotate.d/awstats << 'EOF'
/var/log/awstats/*.log {
    weekly
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 root root
    sharedscripts
    postrotate
        /usr/share/awstats/tools/awstats_updateall.pl now > /dev/null 2>&1 || true
    endscript
}
EOF

# 创建 DB-IP 数据库更新脚本
cat > $RPM_BUILD_ROOT/etc/cron.d/awstats-dbip-update << 'EOF'
#!/bin/bash
# ------------------------------------------------------------------------------
# Monthly DB-IP database update script
# Runs on the 1st of each month via cron.monthly
# Generated by AWStats, do not edit manually
# 由 AWStats 自动生成，请勿手动编辑
# To disable automatic updates, rename this file so you can re-enable it later if needed.
# 若需禁用自动更新，请将此文件重命名！以便后续再次启用此功能！
# ------------------------------------------------------------------------------

YEAR_MONTH=$(date +%Y-%m)
DBIP_DIR="/usr/share/perl5/Geo"
DBIP_DEST="$DBIP_DIR/dbip-city.mmdb"
DBIP_TEMP_GZ="$DBIP_DIR/dbip-city.mmdb.tmp.gz"
DBIP_TEMP="$DBIP_DIR/dbip-city.mmdb.tmp"
LOG_FILE="/var/log/dbip-update.log"

if [ -f "$LOG_FILE" ] && [ $(wc -l < "$LOG_FILE") -gt 30 ]; then
    tail -n 30 "$LOG_FILE" > "$LOG_FILE.tmp"
    mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

mkdir -p "$DBIP_DIR"
cd "$DBIP_DIR"

if ! command -v wget > /dev/null 2>&1; then
    echo "$(date): wget not installed, skipping update" >> "$LOG_FILE"
    exit 1
fi

echo "$(date): Downloading DB-IP database for ${YEAR_MONTH}..." >> "$LOG_FILE"
wget -q -O "$DBIP_TEMP_GZ" "https://download.db-ip.com/free/dbip-city-lite-${YEAR_MONTH}.mmdb.gz" 2>/dev/null
if [ ! -s "$DBIP_TEMP_GZ" ]; then
    LAST_MONTH=$(date -d "1 month ago" +%Y-%m 2>/dev/null)
    if [ -n "$LAST_MONTH" ]; then
        echo "$(date): Current month ${YEAR_MONTH} not available, trying ${LAST_MONTH}" >> "$LOG_FILE"
        wget -q -O "$DBIP_TEMP_GZ" "https://download.db-ip.com/free/dbip-city-lite-${LAST_MONTH}.mmdb.gz" 2>/dev/null
        if [ -s "$DBIP_TEMP_GZ" ]; then
            echo "$(date): Downloaded ${LAST_MONTH} instead" >> "$LOG_FILE"
        fi
    fi
fi
if [ -s "$DBIP_TEMP_GZ" ]; then
    gunzip -f "$DBIP_TEMP_GZ"
    if [ -f "$DBIP_TEMP" ]; then
        mv "$DBIP_TEMP" "$DBIP_DEST"
        chmod 644 "$DBIP_DEST"
        echo "$(date): Successfully updated to ${YEAR_MONTH}" >> "$LOG_FILE"
        echo "✓ DB-IP database updated to ${YEAR_MONTH}"
    else
        echo "$(date): Gunzip failed" >> "$LOG_FILE"
        echo "⚠ DB-IP database decompression failed"
    fi
else
    rm -f "$DBIP_TEMP_GZ"
    echo "$(date): Download failed for ${YEAR_MONTH}" >> "$LOG_FILE"
    echo "⚠ DB-IP database update failed"
fi
EOF
chmod 755 $RPM_BUILD_ROOT/etc/cron.d/awstats-dbip-update

#---- clean
%clean
rm -rf $RPM_BUILD_ROOT

#---- files
%files
%defattr(-,root,root)
%doc README.md
%config(noreplace) /etc/awstats/awstats.conf
%config(noreplace) /etc/awstats/awstats.model.conf
%config(noreplace) /etc/awstats/awstats.local.conf
%config(noreplace) /etc/httpd/conf.d/awstats.conf
%config(noreplace) /etc/cron.d/awstats
%config(noreplace) /etc/logrotate.d/awstats
%config(noreplace) /etc/cron.d/awstats-dbip-update
/usr/share/doc/awstats/
/usr/share/awstats/
/usr/lib/cgi-bin/
/usr/local/bin/awstats
/var/lib/awstats
/var/log/awstats
/usr/share/perl5/Geo/
/usr/share/perl5/vendor_perl/MaxMind/

#---- post
%post
#!/bin/sh
set -e

case "$1" in
    1)  # 首次安装
        echo ""
        echo "-----------------------------------------"
        echo " AWStats %{version} - DB-IP Database Setup"
        echo "-----------------------------------------"
        echo ""
        
        # 创建目录
        mkdir -p /usr/share/perl5/Geo
        mkdir -p /var/lib/awstats
        mkdir -p /var/log/awstats
        chmod 755 /var/lib/awstats
        chmod 755 /var/log/awstats
        
        # 确保 CGI 脚本可执行
        if [ -f /usr/lib/cgi-bin/awstats.pl ]; then
            chmod 755 /usr/lib/cgi-bin/awstats.pl
        fi
        if [ -f /usr/lib/cgi-bin/awredir.pl ]; then
            chmod 755 /usr/lib/cgi-bin/awredir.pl
        fi
        
        # 首次下载 DB-IP 数据库
        DBIP_DEST="/usr/share/perl5/Geo/dbip-city.mmdb"
        if [ ! -f "$DBIP_DEST" ]; then
            echo "Downloading DB-IP City Lite database..."
            
            if command -v wget > /dev/null 2>&1; then
                YEAR=$(date +%Y)
                MONTH=$(date +%m)
                DBIP_URL="https://download.db-ip.com/free/dbip-city-lite-${YEAR}-${MONTH}.mmdb.gz"
                DBIP_TEMP_GZ="/usr/share/perl5/Geo/dbip-city-temp.mmdb.gz"
                
                echo "Trying ${YEAR}-${MONTH}..."
                if wget -q --show-progress -O "$DBIP_TEMP_GZ" "$DBIP_URL" 2>/dev/null; then
                    DOWNLOAD_SUCCESS=1
                else
                    LAST_YEAR=$(date -d "1 month ago" +%Y 2>/dev/null)
                    LAST_MONTH=$(date -d "1 month ago" +%m 2>/dev/null)
                    if [ -n "$LAST_YEAR" ] && [ -n "$LAST_MONTH" ]; then
                        DBIP_URL="https://download.db-ip.com/free/dbip-city-lite-${LAST_YEAR}-${LAST_MONTH}.mmdb.gz"
                        echo "Current month not available, trying ${LAST_YEAR}-${LAST_MONTH}..."
                        if wget -q --show-progress -O "$DBIP_TEMP_GZ" "$DBIP_URL" 2>/dev/null; then
                            DOWNLOAD_SUCCESS=1
                        fi
                    fi
                fi
                
                if [ "$DOWNLOAD_SUCCESS" = "1" ] && [ -s "$DBIP_TEMP_GZ" ]; then
                    if gunzip -f "$DBIP_TEMP_GZ"; then
                        mv /usr/share/perl5/Geo/dbip-city-temp.mmdb "$DBIP_DEST"
                        chmod 644 "$DBIP_DEST"
                        echo "✓ GeoIP database downloaded successfully"
                    else
                        echo "⚠️ Failed to decompress database"
                    fi
                    rm -f "$DBIP_TEMP_GZ"
                else
                    echo "⚠️ GeoIP database download failed"
                    echo "  Please check internet connection"
                fi
            else
                echo "⚠️ wget not installed, skipping GeoIP database download"
                echo "  Install wget: yum install wget"
            fi
        fi
        
        # 设置每月自动更新脚本
        if [ -f /etc/cron.d/awstats-dbip-update ]; then
            chmod +x /etc/cron.d/awstats-dbip-update
            echo "✓ Monthly GeoIP update script installed"
        fi

        # 生成 awredir.pl 随机密钥
        if [ -f /usr/lib/cgi-bin/awredir.pl ]; then
            if command -v openssl >/dev/null 2>&1; then
                KEY=$(openssl rand -hex 16 2>/dev/null)
                sed -i "s/YOURKEYFORMD5/$KEY/" /usr/lib/cgi-bin/awredir.pl
                echo "✓ Random key generated for awredir.pl"
            fi
        fi
        
        if [ -x /usr/sbin/a2enmod ]; then
            a2enmod cgi > /dev/null 2>&1 || true
            if command -v systemctl >/dev/null 2>&1; then
                systemctl try-reload-or-restart httpd >/dev/null 2>&1 || true
            fi
        fi
        (crontab -l 2>/dev/null; echo "0 5 3 * * /etc/cron.d/awstats-dbip-update") | crontab -
        ;;
esac

echo ""
echo "-----------------------------------------"
echo " AWStats %{version} installation complete"
echo "-----------------------------------------"
echo ""
echo " Main directory: /usr/share/awstats"
echo " Configuration: /etc/awstats"
echo " CGI scripts: /usr/lib/cgi-bin"
echo " CLI wrapper: /usr/local/bin/awstats"
echo ""
echo " Web access: http://your-domain/vstats/"
echo " Cron job: /etc/cron.d/awstats (daily at 1 AM)"
echo " DB-IP database: /usr/share/perl5/Geo/dbip-city.mmdb"
echo " Data directory: /var/lib/awstats"
echo " Log directory: /var/log/awstats"
echo ""
echo " Monthly DB-IP update: /etc/cron.d/awstats-dbip-update"
echo ""
echo " No control panel? Try HestiaCP - https://hestiadocs.brepo.ru"
echo " HestiaCP is designed for Red Hat series (RHEL/RockyLinux/AlmaLinux/CentOS)"
echo " AWStats works out of the box with HestiaCP, no manual config needed."
echo "-----------------------------------------"
echo ""

%postun
#!/bin/sh
if [ "$1" = "0" ]; then
    # 卸载时清理
    rm -f /usr/share/perl5/Geo/dbip-city.mmdb 2>/dev/null || true
    rm -f /usr/share/perl5/Geo/dbip-city.mmdb.bak 2>/dev/null || true
fi

%changelog
* __CHANGELOG_DATE__ Laurent Destailleur <eldy@users.sourceforge.net> %{version}-%{release}
- Add DB-IP database support with monthly updates
- Add city-level geolocation support
- Add mobile device detection
- Add download statistics with resume support
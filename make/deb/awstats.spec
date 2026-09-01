# ------------------------------------------------------------------------------
# AWStats DEB Package Template
# This template generates all debian/ packaging files
# Variables:
#   __VERSION__   - Package version (e.g., 7.9)
#   __RELEASE__   - Package release (e.g., 1)
#   __DATE__      - Current date for changelog
#   __MAINTAINER__ - Package maintainer
# ------------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# File: debian/control
# -----------------------------------------------------------------------------
[FILE:control]
Source: awstats
Section: web
Priority: optional
Maintainer: __MAINTAINER__
Build-Depends: debhelper (>= 13)
Standards-Version: 4.7.0
Rules-Requires-Root: no
Homepage: https://awstats.org

Package: awstats
Architecture: all
Depends: perl,
         libmaxmind-db-reader-perl,
         libsocket-perl,
         libencode-perl,
         libjson-xs-perl,
         libtry-tiny-perl,
         ${misc:Depends}
Recommends: wget,
            ca-certificates
Suggests: apache2,
          nginx,
          cron
Description: powerful and featureful web server log analyzer
 AWStats (Advanced Web Statistics) is a free powerful and featureful
 tool that generates advanced web (but also ftp or mail) server
 statistics, graphically.
 .
 This log analyzer works as a CGI or from command line and shows you
 all possible information your log contains, in few graphical web
 pages.
 .
 Features:
  - Complete statistics with graphs
  - Support for GeoIP/DB-IP geolocation
  - Support for log rotation
  - Multi-language support (50+ languages)
  - IPv6 support
  - Mobile device detection
  - Download statistics with resume support

[FILE:control]

# -----------------------------------------------------------------------------
# File: debian/changelog
# -----------------------------------------------------------------------------
[FILE:changelog]
awstats (__VERSION__-__RELEASE__) unstable; urgency=medium

  * New upstream release
  * Add DB-IP database support with monthly updates
  * Add city-level geolocation support
  * Add mobile device detection
  * Add download statistics with resume support

 -- __MAINTAINER__  __DATE__

[FILE:changelog]

# -----------------------------------------------------------------------------
# File: debian/compat
# -----------------------------------------------------------------------------
[FILE:compat]
13

[FILE:compat]

# -----------------------------------------------------------------------------
# File: debian/copyright
# -----------------------------------------------------------------------------
[FILE:copyright]
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: awstats
Source: https://github.com/eldy/awstats

Files: *
Copyright: 2000-2026 Laurent Destailleur <eldy@users.sourceforge.net>
License: GPL-2+
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 .
 On Debian systems, the full text of the GNU General Public License
 version 2 can be found in the file /usr/share/common-licenses/GPL-2.

[FILE:copyright]

# -----------------------------------------------------------------------------
# File: debian/rules
# -----------------------------------------------------------------------------
[FILE:rules]
#!/usr/bin/make -f

%:
	dh $@

override_dh_auto_install:
	# 创建所有必要的目录
	mkdir -p debian/awstats/usr/share/awstats
	mkdir -p debian/awstats/usr/share/awstats/lang
	mkdir -p debian/awstats/usr/share/awstats/lib
	mkdir -p debian/awstats/usr/share/awstats/plugins
	mkdir -p debian/awstats/usr/share/awstats/icon
	mkdir -p debian/awstats/usr/share/awstats/css
	mkdir -p debian/awstats/usr/share/awstats/js
	mkdir -p debian/awstats/usr/share/awstats/classes
	mkdir -p debian/awstats/usr/share/awstats/tools
	mkdir -p debian/awstats/usr/lib/cgi-bin
	mkdir -p debian/awstats/usr/local/bin
	mkdir -p debian/awstats/etc/awstats
	mkdir -p debian/awstats/etc/cron.d
	mkdir -p debian/awstats/etc/logrotate.d/httpd-prerotate
	mkdir -p debian/awstats/var/lib/awstats
	mkdir -p debian/awstats/var/log/awstats
	mkdir -p debian/awstats/usr/share/doc/awstats
	mkdir -p debian/awstats/usr/share/doc/awstats/images
	mkdir -p debian/awstats/usr/share/man/man1
	mkdir -p debian/awstats/usr/share/perl5/Geo

	# 创建 logrotate 配置
	echo '# AWStats logrotate configuration' > debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '/var/log/awstats/*.log {' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '    weekly' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '    missingok' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '    rotate 52' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '    compress' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '    delaycompress' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '    notifempty' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '    create 644 root root' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '    sharedscripts' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '    postrotate' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '        /usr/share/awstats/tools/awstats_updateall.pl now > /dev/null 2>&1' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '    endscript' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats
	echo '}' >> debian/awstats/etc/logrotate.d/httpd-prerotate/awstats

	# 创建 cron 任务
	echo '# AWStats cron job' > debian/awstats/etc/cron.d/awstats
	echo '# Run AWStats update daily at 1:00 AM' >> debian/awstats/etc/cron.d/awstats
	echo '0 1 * * * root [ -x /usr/share/awstats/tools/awstats_updateall.pl ] && /usr/share/awstats/tools/awstats_updateall.pl now > /dev/null 2>&1' >> debian/awstats/etc/cron.d/awstats

	# 复制主程序文件到 /usr/lib/cgi-bin/
	cp -pr wwwroot/cgi-bin/*.pl debian/awstats/usr/lib/cgi-bin/ 2>/dev/null || true
	chmod 755 debian/awstats/usr/lib/cgi-bin/*.pl

	# 复制 awstats-update 到 /usr/local/bin/
	cp -pr wwwroot/cgi-bin/awstats-update debian/awstats/usr/local/bin/ 2>/dev/null || true
	chmod 755 debian/awstats/usr/local/bin/awstats-update

	# 复制库文件（排除 IPfree 模块）
	cp -pr wwwroot/cgi-bin/lib/* debian/awstats/usr/share/awstats/lib/ 2>/dev/null || true
	rm -f debian/awstats/usr/share/awstats/lib/IPfree.pm 2>/dev/null || true
	rm -f debian/awstats/usr/share/awstats/lib/IPfree.pod 2>/dev/null || true

	# 复制 IPfree 模块到 Perl 路径
	cp -pr wwwroot/cgi-bin/lib/IPfree.pm debian/awstats/usr/share/perl5/Geo/ 2>/dev/null || true
	cp -pr wwwroot/cgi-bin/lib/IPfree.pod debian/awstats/usr/share/perl5/Geo/ 2>/dev/null || true
	chmod 644 debian/awstats/usr/share/perl5/Geo/IPfree.pm 2>/dev/null || true
	chmod 644 debian/awstats/usr/share/perl5/Geo/IPfree.pod 2>/dev/null || true

	# 创建 CLI 包装脚本
	printf '%s\n' '#!/bin/bash' 'perl /usr/lib/cgi-bin/awstats.pl "$$@"' > debian/awstats/usr/local/bin/awstats
	chmod 755 debian/awstats/usr/local/bin/awstats

	# 复制语言文件
	cp -pr wwwroot/cgi-bin/lang/* debian/awstats/usr/share/awstats/lang/ 2>/dev/null || true

	# 复制插件
	cp -pr wwwroot/cgi-bin/plugins/* debian/awstats/usr/share/awstats/plugins/ 2>/dev/null || true

	# 复制图标
	cp -pr wwwroot/icon/* debian/awstats/usr/share/awstats/icon/ 2>/dev/null || true

	# 复制 CSS
	cp -pr wwwroot/css/* debian/awstats/usr/share/awstats/css/ 2>/dev/null || true

	# 复制 JavaScript
	cp -pr wwwroot/js/* debian/awstats/usr/share/awstats/js/ 2>/dev/null || true

	# 复制 Java classes
	cp -pr wwwroot/classes/* debian/awstats/usr/share/awstats/classes/ 2>/dev/null || true

	# 复制工具脚本
	cp -pr tools/* debian/awstats/usr/share/awstats/tools/ 2>/dev/null || true

	# 复制配置文件
	cp -pr wwwroot/cgi-bin/awstats.conf debian/awstats/etc/awstats/awstats.conf
	cp -pr wwwroot/cgi-bin/awstats.model.conf debian/awstats/etc/awstats/awstats.model.conf

	# 创建 awstats.conf.local
	touch debian/awstats/etc/awstats/awstats.conf.local

	# 复制文档
	cp -pr docs/* debian/awstats/usr/share/doc/awstats/ 2>/dev/null || true

override_dh_installchangelog:
	dh_installchangelog docs/CHANGELOG.md

override_dh_installdocs:
	dh_installdocs

override_dh_usrlocal:
	# 跳过 dh_usrlocal
	true

[FILE:rules]

# -----------------------------------------------------------------------------
# File: debian/postinst
# -----------------------------------------------------------------------------
[FILE:postinst]
#!/bin/sh
set -e

case "$1" in
    configure)
        # 创建必要的目录
        mkdir -p /var/lib/awstats
        mkdir -p /var/log/awstats
        chmod 755 /var/lib/awstats
        chmod 755 /var/log/awstats
        
        # 确保 CGI 脚本可执行
        chmod 755 /usr/lib/cgi-bin/awstats.pl
        chmod 755 /usr/lib/cgi-bin/awredir.pl
        chmod 755 /usr/share/awstats/*.pl 2>/dev/null || true

        # 检测并安装 cron（如果未安装）
        if ! command -v crontab > /dev/null 2>&1; then
            echo "cron not found, installing..."
            if command -v apt-get > /dev/null 2>&1; then
                apt-get update && apt-get install -y cron
            elif command -v yum > /dev/null 2>&1; then
                yum install -y cronie
            elif command -v dnf > /dev/null 2>&1; then
                dnf install -y cronie
            elif command -v apk > /dev/null 2>&1; then
                apk add dcron
            fi
            
            # 启动服务
            if command -v systemctl > /dev/null 2>&1; then
                systemctl enable cron 2>/dev/null || systemctl enable crond 2>/dev/null
                systemctl start cron 2>/dev/null || systemctl start crond 2>/dev/null
            fi
        fi

        # 修复 Perl 模块依赖（仅 Debian/Ubuntu）
        if command -v apt-get > /dev/null 2>&1; then
            echo "Fixing dependencies..."
            timeout 10 apt --fix-broken install -y 2>/dev/null || {
                echo "⚠️ Failed to fix dependencies automatically"
                echo "   Run: apt --fix-broken install -y"
            }
        fi

        # 检查并下载 GeoIP 数据库
        mkdir -p /usr/share/perl5/Geo

        DBIP_DIR="/usr/share/perl5/Geo"
        DBIP_DEST="$DBIP_DIR/dbip-city.mmdb"

        if [ ! -f "$DBIP_DEST" ]; then
            echo "Downloading GeoIP database..."
            YEAR=$(date +%Y)
            MONTH=$(date +%m)
            DBIP_URL="https://download.db-ip.com/free/dbip-city-lite-${YEAR}-${MONTH}.mmdb.gz"
            DBIP_TEMP_GZ="$DBIP_DIR/dbip-city-temp.mmdb.gz"
            DBIP_TEMP="$DBIP_DIR/dbip-city-temp.mmdb"
            
            if command -v wget > /dev/null 2>&1; then
                wget -q -O "$DBIP_TEMP_GZ" "$DBIP_URL" 2>/dev/null
                if [ ! -s "$DBIP_TEMP_GZ" ]; then
                    LAST_YEAR=$(date -d "1 month ago" +%Y 2>/dev/null)
                    LAST_MONTH=$(date -d "1 month ago" +%m 2>/dev/null)
                    if [ -n "$LAST_YEAR" ] && [ -n "$LAST_MONTH" ]; then
                        echo "Current month not available, trying ${LAST_YEAR}-${LAST_MONTH}..."
                        DBIP_URL="https://download.db-ip.com/free/dbip-city-lite-${LAST_YEAR}-${LAST_MONTH}.mmdb.gz"
                        wget -q -O "$DBIP_TEMP_GZ" "$DBIP_URL" 2>/dev/null
                    fi
                fi
                
                if [ -s "$DBIP_TEMP_GZ" ]; then
                    gunzip -f "$DBIP_TEMP_GZ"
                    if [ -f "$DBIP_TEMP" ]; then
                        mv "$DBIP_TEMP" "$DBIP_DEST"
                        chmod 644 "$DBIP_DEST"
                        echo "✓ GeoIP database downloaded successfully"
                    else
                        echo "⚠️ Failed to decompress database"
                    fi
                else
                    echo "⚠️ GeoIP database download failed"
                fi
                rm -f "$DBIP_TEMP_GZ"
            else
                echo "⚠️ wget not installed, skipping GeoIP database download"
            fi
        fi

        # 设置每月自动更新脚本
        cat > /etc/cron.d/awstats-dbip-update << 'INNEREOF'
#!/bin/bash
# ------------------------------------------------------------------------------
# Generated by AWStats, do not edit manually
# 由 AWStats 自动生成，请勿手动编辑
# To disable automatic updates, rename this file so you can re-enable it later if needed.
# 若需禁用自动更新，请将此文件重命名！以便后续再次启用此功能！
# ------------------------------------------------------------------------------
YEAR_MONTH=$(date +%Y-%m)
DBIP_DIR="/usr/share/perl5/Geo"
DBIP_DEST="$DBIP_DIR/dbip-city.mmdb"
DBIP_TEMP_GZ="$DBIP_DIR/dbip-city-temp.mmdb.gz"
DBIP_TEMP="$DBIP_DIR/dbip-city-temp.mmdb"
LOG_FILE="/var/log/dbip-update.log"

if [ -f "$LOG_FILE" ] && [ $(cat "$LOG_FILE" | wc -l) -gt 30 ]; then
    tail -n 30 "$LOG_FILE" > "$LOG_FILE.tmp"
    mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

mkdir -p "$DBIP_DIR"
cd "$DBIP_DIR"

if ! command -v wget > /dev/null 2>&1; then
    echo "$(date): wget not installed, skipping update" >> "$LOG_FILE"
    exit 1
fi

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
        echo "$(date): Updated to ${YEAR_MONTH}" >> "$LOG_FILE"
        echo "✓ DB-IP database updated"
    else
        echo "$(date): Gunzip failed" >> "$LOG_FILE"
    fi
else
    echo "$(date): Update failed for ${YEAR_MONTH}" >> "$LOG_FILE"
fi

rm -f "$DBIP_TEMP_GZ"
INNEREOF
        chmod +x /etc/cron.d/awstats-dbip-update
        
        echo "✓ Monthly GeoIP update script installed"

        # 启用 Apache CGI 模块
        if [ -x /usr/sbin/a2enmod ]; then
            a2enmod cgi > /dev/null 2>&1 || true
            if command -v systemctl >/dev/null 2>&1; then
                systemctl try-reload-or-restart apache2 >/dev/null 2>&1 || true
            fi
        fi

        # 生成 awredir.pl 的随机密钥
        if [ -f /usr/lib/cgi-bin/awredir.pl ]; then
            echo "Generating random key for awredir.pl..."
            # 尝试多种方式生成随机密钥
            if command -v openssl >/dev/null 2>&1; then
                KEY=$(openssl rand -hex 16 2>/dev/null)
            elif command -v md5sum >/dev/null 2>&1; then
                KEY=$(echo $(date)$$RANDOM | md5sum | cut -d' ' -f1)
            else
                KEY=$(perl -e 'use Digest::MD5 qw(md5_hex); print md5_hex(rand().time().$$)' 2>/dev/null)
            fi
            
            if [ -n "$KEY" ]; then
                sed -i "s/YOURKEYFORMD5/$KEY/" /usr/lib/cgi-bin/awredir.pl
                echo "✓ Random key generated"
            fi
        fi
        (crontab -l 2>/dev/null; echo "0 5 3 * * /etc/cron.d/awstats-dbip-update") | crontab -
        echo
        echo "══════════════════════════════════════════════"
        echo " AWStats __VERSION__ installation complete"
        echo "══════════════════════════════════════════════"
        echo ""
        echo " Main program directory: /usr/share/awstats"
        echo " Configuration directory: /etc/awstats"
        echo "   - awstats.conf        # Standard configuration file"
        echo "   - awstats.model.conf  # Full version (with comments)"
        echo ""
        echo "   Want AWStats configuration to be extremely simple?"
        echo "   Use Hestia Control Panel to manage your server!"
        echo "   https://hestiacp.com"
        echo ""
        echo "  HestiaCP automatically:"
        echo "     Enables AWStats when adding domains"
        echo "     Configures log paths automatically"
        echo "     Sets up scheduled update tasks"
        echo "     Configures web access permissions"
        echo "     Handles all domains in one go!"
        echo ""
        echo " Visit https://your-domain/vstats/ to view statistics"
        echo " It's that simple, no manual configuration needed!"
        echo ""
        echo " Manual configuration guide (if you insist on doing it manually):"
        echo "   1. Edit /etc/awstats/awstats.conf"
        echo "   2. Modify LogFile and SiteDomain"
        echo "   3. Run /usr/share/awstats/tools/awstats_configure.pl"
        echo "   4. Add cron job"
        echo ""
        echo " CGI scripts: /usr/lib/cgi-bin/"
        echo " Data directory: /var/lib/awstats"
        echo " Log directory: /var/log/awstats"
        echo " Documentation: /usr/share/doc/awstats"
        echo ""
        echo " Configuration tool: /usr/share/awstats/tools/awstats_configure.pl"
        echo " Web access: http://your-domain/vstats/"
        echo " Cron job: /etc/cron.d/awstats (daily update at 1 AM)"
        echo " Log rotation: /etc/logrotate.d/httpd-prerotate/awstats"
        echo "══════════════════════════════════════════════"
        echo
        ;;
esac

exit 0

[FILE:postinst]

# -----------------------------------------------------------------------------
# File: debian/prerm
# -----------------------------------------------------------------------------
[FILE:prerm]
#!/bin/sh
set -e

case "$1" in
    remove|upgrade)
        # 卸载前清理（如果需要）
        ;;
esac

exit 0

[FILE:prerm]

# -----------------------------------------------------------------------------
# File: debian/preinst
# -----------------------------------------------------------------------------
[FILE:preinst]
#!/bin/sh
set -e

case "$1" in
    install|upgrade)
        # 安装前准备工作
        ;;
esac

exit 0

[FILE:preinst]

# -----------------------------------------------------------------------------
# File: debian/install
# -----------------------------------------------------------------------------
[FILE:install]
# Empty - files are copied via rules

[FILE:install]

# ------------------------------------------------------------------------------
# End of DEB package template
# ------------------------------------------------------------------------------
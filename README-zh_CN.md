# AWStats 8.1 - 高级网站统计工具（社区版）

<p align="center">
  <img src="docs/images/screenshot.png" alt="AWStats Dashboard Preview" width="800">
</p>

<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html#license-text"><img src="https://img.shields.io/badge/许可证-GPL%20v3-blue.svg" alt="许可证"></a>
  <a href="https://www.perl.org/"><img src="https://img.shields.io/badge/Perl-5.20%2B-brightgreen.svg" alt="Perl 版本"></a>
  <br><br>
  <a href="https://github.com/hestiacn/vstats/releases/latest"><img src="https://img.shields.io/github/v/release/hestiacn/vstats?style=for-the-badge&logo=github&label=最新版本&color=blue" alt="最新版本"></a>
  <br><br>
  <a href="docs/CHANGELOG-zh_CN.md"><img src="https://img.shields.io/badge/📝_更新日志-中文版-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="更新日志"></a>
  <br><br>
  <a href="docs/CHANGELOG.md"><img src="https://img.shields.io/badge/📝_Changelog-English_Version-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="Changelog"></a>
</p>

> **🎉 这是 vstats 的首个主要社区版本！** 是对传奇的 `AWStats` (1997-2025) 的全面重构。我们为其拂去尘埃，使其焕然一新，足以应对未来 25 年的挑战！

原始 `AWStats` 在经历了 25 年的维护后，于 2025 年 11 月归档。本项目在原始基础上进行了全面重构和功能增强，由 [hestiacn](https://github.com/hestiacn/vstats) 社区持续维护。

---

## 🚀 发布亮点

### 1. 原生 UTF-8 支持（告别繁琐编码）

告别令人头疼的编码问题！所有内部逻辑和输出现在都完全采用 UTF-8 编码。中文、日文、阿拉伯文和其他特殊字符现在都能完美呈现。

### 2. 全球“灵魂”本地化（73 种语言）

- 将整个翻译系统从数字索引切换到语义键（`_t('key')`）
- 新增/更新了 73 种语言（包括塞浦路斯语、巴西葡萄牙语、等）
- 为 24 小时统计数据配上了独特幽默的“吐槽”描述——给凌晨 4 点还在工作的系统管理员们一个小小的惊喜！☕️

### 3. 现代化的用户界面和响应式设计

- **深色/浅色模式**：一键切换明暗主题
- **纯 CSS 图表**：旧的 PNG 图像已被支持 `border-radius` 的现代 CSS 图表取代
- **表情符号集成**：使用 Emoji 进行数据可视化，打造现代化的视觉体验

### 4. 性能与代码优化

- 对 Perl 代码进行了重大清理，以提升在现代 CGI 环境下的性能
- 改进了对现代浏览器和机器人的检测（2026 年最新规则）

### 5. 多历法支持和13月 🗓️

支持日本年号、佛历、民国纪年、甲子纪年、伊斯兰历、波斯历等 **13 种历法**（含埃塞俄比亚 **13 个月**历法），自动匹配站点语言。

> 📌 **埃塞俄比亚历**：前 12 个月各 30 天，第 13 个月闰年 6 天平年 5 天。
> 📌 **希伯来历**：19 年 7 闰，闰年增加一个月（Adar I，30 天），共 13 个月。

### 6. 自定义品牌展示 🏷️

> **适用于主机商和企业用户**

现在支持在 `AWStats` 页面顶部显示自定义品牌信息，包括 **Logo** 和 **品牌名称**。

**功能特性**：
- 📍 品牌区域仅在 `/stats/logo.svg` 文件存在时自动显示
- 🔗 支持自定义品牌链接（Logo 点击跳转）
- 🏷️ 支持任意品牌名称（建议使用英文名称，兼容多语言环境），自动拼接为 **`品牌名 + " 服务器管理面板"`**

**适用场景示例**：
| 类型 | 示例 |
|:---:|:---:|
| 🐧 Linux 发行版 | `RHEL`、`Debian`、`Ubuntu`、`CentOS`、`Arch Linux`、`Fedora`、`Rocky Linux` |
| 🖥️ 操作系统 | `macOS`、`Windows`、`FreeBSD` |
| ☁️ 云主机商 | `Aliyun`、`Tencent`、`AWS`、`Azure`、`Google Cloud` |

**配置示例**：
```perl
# 在 AWStats 配置文件中添加
BrandLink="https://example.com"      # Logo 点击跳转链接
BrandPlatform="Ubuntu"               # 品牌名称（显示 "Ubuntu 服务器管理面板"）
StatsUrl="/vstats"                   # AWStats 部署目录
```

> **注意**：品牌区域仅在 `logo.svg` 文件存在时显示，未配置 `BrandLink` 时将使用默认值 `https://hestiacp.com`。

---

## 📦 下载与安装

请从下方链接获取最新版本：

| 系统/格式 | 下载链接 |
|:---:|:---:|
| **Debian/Ubuntu** | [![下载 .deb 包](https://img.shields.io/badge/下载-.deb_包-2ea44f?logo=debian&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb) |
| **RHEL/CentOS/Fedora** | [![下载 .rpm 包](https://img.shields.io/badge/下载-.rpm_包-2ea44f?logo=fedora&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm) |
| **源码包 (tar.gz)** | [![下载源码 .tar.gz](https://img.shields.io/badge/下载-.tar.gz-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.tar.gz) |
| **源码包 (zip)** | [![下载源码 .zip](https://img.shields.io/badge/下载-.zip-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.zip) |
| **Windows** | [![下载 Windows版](https://img.shields.io/badge/下载-Windows版-2ea44f?logo=windows&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-utf8.exe) |

> **Windows 环境说明**：Windows 版本仅打包了 EXE 安装包，目录结构和路径均未经过实际测试。如在使用中遇到问题，欢迎提交 Issue 或 Pull Request 协助修复！

---

## 📊 与原版对比

| 特性 | 原始 AWStats | 重构版本 |
|:---:|:---:|:---:|
| 编码 | GBK / 局部编码 | **UTF-8 全支持** |
| 翻译方式 | 数字索引 `$Message[169]` | **语义化键名 `_t('key')`** |
| 界面风格 | 固定样式 | **明暗主题切换 + 响应式** |
| 国家 | PNG图像 | **Emoji** |
| 图表 | PNG 图像 | **纯 CSS 图表** |
| 历法支持 | 公历 | **12 种历法** |
| 维护状态 | 已归档 | **持续维护** |

---

## ✨ 完整功能列表

| 类别 | 功能 |
|:---:|:---:|
| 🌐 多语言cgi访问 | `73` 种语言界面，浏览器自动识别。让全球访客用母语查看报告！[查看详细语言支持列表](docs/CHANGELOG-zh_CN.md#--语言支持) |
| 🗓️ 多历法支持 | 日本年号、佛历、民国纪年、甲子纪年、伊斯兰历、波斯历等 **13 种历法**（含埃塞俄比亚 13 月历），自动匹配站点语言 |
| 📊 访问统计 | 独立访客、访问次数、访问时长、认证用户追踪 |
| 🌍 地理位置 | `DB-IP` 免费数据库，国家/地区/城市三级定位，IPv4/IPv6 支持 |
| 💻 客户端信息 | 浏览器、操作系统、屏幕分辨率、设备类型（桌面/移动） |
| 🤖 爬虫识别 | `500+` 搜索引擎爬虫，AI/ML 爬虫（ClaudeBot、GPTBot 等） |
| 📁 文件统计 | 文件类型、下载（断点续传）、压缩（mod_gzip/mod_deflate） |
| ⚠️ 错误分析 | `HTTP` 错误（404 等）、错误来源、蠕虫攻击检测状态码本地化描述 |
| 🎨 现代化界面 | 响应式设计、深色/浅色主题、纯 CSS 图表、Emoji 国旗图标 |

---

## 📋 系统要求

### 基本要求
- ✅ 能够访问要分析的服务器日志文件（Web/FTP/邮件）
- ✅ 5.20 或更高版本（推荐 5.32+）
- ✅ 命令行和/或 CGI 环境

### 支持的操作系统
- 🐧 Linux/Unix（Ubuntu、Debian、CentOS、RHEL 等）
- 🪟 Windows（Windows 10/11、Windows Server）
- 🍎 macOS
- 🔵 FreeBSD、OpenBSD

### 支持的服务器
- 🌐 Web：Apache、Nginx、IIS、Caddy、Lighttpd
- 📁 FTP：ProFTPd、vsFTPd、Pure-FTPd
- 📧 邮件：Postfix、Sendmail、QMail、Exim
- 🎥 流媒体：RealMedia、Windows Media Server

---

## **AWStats Geo/IPfree.pm 版本兼容性修复**

如果在运行 AWStats 更新时遇到类似以下错误：
```bash
Error: Perl v5.200.0 required (did you mean v5.20.0?)--this is only v5.36.0
```

这是因为 `Geo/IPfree.pm` 文件中的版本检查与当前系统的 Perl 版本不兼容。

### **自动修复命令**
```bash
find /usr -name "IPfree.pm" 2>/dev/null | while read -r file; do
    sed -i.bak 's/^use 5\.20;/#use 5.20;/' "$file"
done
```

### **手动修复步骤**
如果自动命令无效，请按以下步骤操作：

1. **查找文件位置**
   ```bash
   find /usr -name "IPfree.pm" 2>/dev/null
   ```

2. **编辑文件，注释掉版本检查行**
   ```bash
   sed -i 's/^use 5\.20;/#use 5.20;/' /path/to/IPfree.pm
   ```

### **补充文件（如需要）**
由于平台的多样性和复杂性，不同系统可能使用不同版本。如果您系统中没有对应的文件，请手动替换以下文件：

| 文件 | 位置 |
|------|------|
| `/usr/share/perl5/Geo/IPfree.pm` | [IPfree.pm](/wwwroot/cgi-bin/lib/IPfree.pm) |
| `/usr/share/perl5/Geo/IPfree.pod` | [IPfree.pod](/wwwroot/cgi-bin/lib/IPfree.pod) |
| `/usr/share/perl5/Geo/dbip-city.mmdb` | [update-dbip](/make/test/awstats/conf/update-dbip) |

---

## 🔄 升级前转换（仅限从旧版升级）

若涉及站点升级，请先执行 `/usr/share/awstats/tools/awstats_convert-zh.pl` 对历史数据文件（*.txt）进行格式转换（7.0-7.9 → 8.1）。程序将自动检测 `/home/*/web/*/stats/` 目录下的所有 `AWStats` 数据文件（*.txt）并进行批量转换。请放心执行，它将在转换前自动备份原文件。若您的站点不在 `home` 目录下，请参考这个路径结构 `/home/站点运行用户名/web/您的域名/stats/` 微调。转换完成后，再执行数据更新操作，否则将因格式不兼容导致更新失败。

> **注意**：若您的站点版本低于 7.0，请根据实际版本号调整脚本中 `s/AWSTATS DATA FILE 7\.[0-9]{1,2}/AWSTATS DATA FILE 8.1/` 正则表达式的匹配参数。
>
> **💡 提示**：备份文件默认保存在 `/backup/awstats_converter/backup_执行时的时间戳命名/` 目录下。

```bash
# 试运行（查看将要转换哪些文件）
perl /usr/share/awstats/tools/awstats_convert-zh.pl --dryrun

# 正式运行
perl /usr/share/awstats/tools/awstats_convert-zh.pl

# 强制重新转换所有文件
perl /usr/share/awstats/tools/awstats_convert-zh.pl --force

# 安静模式
perl /usr/share/awstats/tools/awstats_convert-zh.pl --quiet

# 查看帮助
perl /usr/share/awstats/tools/awstats_convert-zh.pl --help
```
---

## 🚀 快速开始

### 1. 安装

#### HestiaCP 用户（推荐）

> **注意**：本脚本仅适配 HestiaCP 面板。如果您使用其他控制面板或没有面板管理，请参考脚本中的 `build_awstats()` 函数，根据实际环境自行调整。

HestiaCP 已自带 AWStats，更新安装打包好的 `deb` 和 `rpm` 程序即可体验全新社区版本。

**支持发行版**：
- 官方支持：[Debian/Ubuntu](https://github.com/hestiacp/hestiacp)
- 社区支持：[RHEL/CentOS/Alma/Rocky](https://github.com/bayrepo/hestiacp-rpm)

**需要手动调整的文件**：

| 文件类型 | 路径 | 参考示例 |
|:---:|:---:|:---:|
| 模板文件 | `/usr/local/hestia/data/templates/web/awstats/awstats.tpl` | [awstats.tpl](/make/test/awstats/conf/awstats.tpl) |
| 域名配置目录 | `/etc/awstats/` | - |
| 更新脚本 (Debian/Ubuntu 及其衍生版) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.debian](/make/test/awstats/conf/v-update-web-domain-stat) |
| 更新脚本 (RHEL/CentOS/Rocky/Alma/Fedora) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.rhel](/make/test/awstats/conf/v-update-web-domain-stat) |

> 📌 **说明**：Debian 和 RHEL 系列的脚本相关程序代码不同，请根据您的操作系统选择对应的参考示例进行修改。

> 💡 **提示**：修改脚本后，如遇到权限问题，请执行 `chmod +x /usr/local/hestia/bin/v-update-web-domain-stat`

## 下载并安装

### HestiaCP 集成部署

> ⚠️ **重要提示**：使用 HestiaCP 环境安装时，若系统提示配置文件是否更新，请务必选择 **`N`**（保留原配置），否则会覆盖 HestiaCP 面板的特有路由配置。

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### Debian / Ubuntu 原生直装

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### RHEL / CentOS / Rocky Linux / Fedora

```bash
# 采用现代 DNF 标准 install 指令，完美对齐全系列红帽生态
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm && dnf install -y /tmp/awstats-8.1-1.noarch.rpm
```

### FreeBSD

```bash
# 安装后一键注入锁定防御，彻底消灭第三方管理面板（如 Webmin）的旧版本降级误报
fetch -o /tmp/awstats-8.1-1.pkg https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.pkg && \
pkg install -y /tmp/awstats-8.1-1.pkg && \
pkg lock -y awstats
```

### 基本配置

编辑配置文件 `/etc/awstats/awstats.yourdomain.conf`：

```perl
LogFile="/var/log/apache2/domains/yourdomain.log"  # 日志文件路径
LogFormat=1                                         # 使用 combined 日志格式
SiteDomain="yourdomain.com"                         # 网站域名
HostAliases="localhost 127.0.0.1"                   # 主机别名
```

### 更新统计

```bash
awstats.pl -config=yourdomain -update
```

### 查看报告

- **HestiaCP 环境**：访问 `https://yourdomain.com/vstats/`如果您需要保存书签请设置这个目录。访问后自动加载为cgi模式！
- **手动生成静态报告**：`awstats.pl -config=yourdomain -output > report.html`

---

## 📖 命令行帮助

### 使用您的母语查看帮助

```bash
# 繁體中文
dnf install -y glibc-langpack-zh
localectl set-locale LANG=zh_TW.UTF-8
# RHEL 請使用以下命令
source /etc/locale.conf
# Debian 請使用以下命令
source /etc/default/locale
awstats -h

# English (US)
dnf install -y glibc-langpack-en
localectl set-locale LANG=en_US.UTF-8
# For RHEL/CentOS/Fedora:
source /etc/locale.conf
# For Debian/Ubuntu:
source /etc/default/locale
awstats -h

# 日本語
dnf install -y glibc-langpack-ja
localectl set-locale LANG=ja_JP.UTF-8
# RHEL では以下のコマンドを使用
source /etc/locale.conf
# Debian では以下のコマンドを使用
source /etc/default/locale
awstats -h

# 简体中文
dnf install -y glibc-langpack-zh wget
localectl set-locale LANG=zh_CN.UTF-8
# RHEL 使用以下命令
source /etc/locale.conf
# Debian 请使用以下命令
source /etc/default/locale
awstats -h

# English (UK)
dnf install -y glibc-langpack-en 
localectl set-locale LANG=en_GB.UTF-8
# For RHEL/CentOS/Fedora:
source /etc/locale.conf
# For Debian/Ubuntu:
source /etc/default/locale
awstats -h

# Português (Brasil)
dnf install -y glibc-langpack-pt
localectl set-locale LANG=pt_BR.UTF-8
# Para RHEL/CentOS/Fedora:
source /etc/locale.conf
# Para Debian/Ubuntu:
source /etc/default/locale
awstats -h
```

### 常用命令

| 命令 | 说明 |
|:---:|:---:|
| `awstats.pl -config=xxx -update` | 更新统计 |
| `awstats.pl -config=xxx -output > report.html` | 生成静态报告 |
| `awstats.pl -config=xxx -update -debug=2` | 调试模式需要在配置文件更改此参数默认为0（关闭） DebugMessages=1 |
| `awstats -h` | 显示帮助 |
| `awstats -v` | 显示版本信息 |

---

## 📚 文档

| 文档 | 链接 |
|:---:|:---:|
| 中文更新日志 | [docs/CHANGELOG-zh_CN.md](docs/CHANGELOG-zh_CN.md) |
| 英文更新日志 | [docs/CHANGELOG.md](docs/CHANGELOG.md) |
| 安装指南 | [docs/awstats_setup.html](docs/awstats_setup.html) |
| 配置说明 | [docs/awstats_config.html](docs/awstats_config.html) |
| 常见问题 | [docs/awstats_faq.html](docs/awstats_faq.html) |

---

## 🤝 贡献与反馈

- **项目仓库**：[GitHub - hestiacn/vstats](https://github.com/hestiacn/vstats)
- **问题反馈**：[GitHub Issues](https://github.com/hestiacn/vstats/issues)

---

## 💖 致谢

特别感谢所有帮助我们正确翻译威尔士语和阿拉伯语六种复数形式的翻译人员和测试人员。你们是真正的网络英雄！

---

## 📄 许可证

`AWStats` 是开源软件，基于 [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.html#license-text) 发布。

---

## 👨‍💻 关于作者与维护

**原始作者**：Laurent Destailleur（1997-2025）
- 项目创始人，于 2025 年 11 月宣布停止更新。
- [Dolibarr ERP CRM](https://www.dolibarr.org) 项目负责人

**社区维护**：[hestiacn](https://github.com/hestiacn/vstats)
- 8.1 版本现代化重构
- 持续维护与更新

---

## 🔗 相关链接

- 原始项目网站：[https://www.awstats.org](https://www.awstats.org)
- 原始项目 GitHub 仓库：[eldy/AWStats](https://github.com/eldy/AWStats)
- DB-IP 数据库：[https://db-ip.com](https://db-ip.com)

---
<!--
## © 1997-2025 Laurent Destailleur | 2026-{{YEAR}} 社区版持续维护中
-->
## © 1997-2026 AWStats 团队 | 社区版持续维护中

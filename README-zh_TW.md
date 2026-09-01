# AWStats 8.1 - 進階網站統計工具（社群版）

<p align="center">
  <img src="docs/images/screenshot.png" alt="AWStats Dashboard Preview" width="800">
</p>

<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html#license-text"><img src="https://img.shields.io/badge/授權條款-GPL%20v3-blue.svg" alt="授權條款"></a>
  <a href="https://www.perl.org/"><img src="https://img.shields.io/badge/Perl-5.20%2B-brightgreen.svg" alt="Perl 版本"></a>
  <br><br>
  <a href="https://github.com/hestiacn/vstats/releases/latest"><img src="https://img.shields.io/github/v/release/hestiacn/vstats?style=for-the-badge&logo=github&label=最新版本&color=blue" alt="最新版本"></a>
  <br><br>
  <a href="docs/CHANGELOG-zh_CN.md"><img src="https://img.shields.io/badge/📝_更新日誌-简体中文版-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="更新日誌"></a>
  <br><br>
  <a href="docs/CHANGELOG.md"><img src="https://img.shields.io/badge/📝_Changelog-English_Version-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="Changelog"></a>
</p>

> **🎉 這是 vstats 的首個主要社群版本！** 是對傳奇的 `AWStats` (1997-2025) 的全面重構。我們為其拂去塵埃，使其煥然一新，足以應對未來 25 年的挑戰！

原始 `AWStats` 在經歷了 25 年的維護後，於 2025 年 11 月封存。本專案在原始基礎上進行了全面重構與功能增強，由 [hestiacn](https://github.com/hestiacn/vstats) 社群持續維護。

---

## 🚀 發佈亮點

### 1. 原生 UTF-8 支援（告別繁瑣編碼）

告別令人頭痛的編碼問題！所有內部邏輯與輸出現在都完全採用 UTF-8 編碼。中文、日文、阿拉伯文和其他特殊字元現在都能完美呈現。

### 2. 全球「靈魂」本地化（73 種語言）

- 將整個翻譯系統從數字索引切換到語意鍵（`_t('key')`）
- 新增/更新了 73 種語言（包括塞浦路斯語、巴西葡萄牙語等）
- 為 24 小時統計資料配上獨特幽默的「吐槽」描述——給凌晨 4 點還在工作的系統管理員們一個小小的驚喜！☕️

### 3. 現代化的使用者介面與響應式設計

- **深色/淺色模式**：一鍵切換明暗主題
- **純 CSS 圖表**：舊的 PNG 圖像已被支援 `border-radius` 的現代 CSS 圖表取代
- **表情符號整合**：使用 Emoji 進行資料視覺化，打造現代化的視覺體驗

### 4. 效能與程式碼最佳化

- 對 Perl 程式碼進行了重大清理，以提升在現代 CGI 環境下的效能
- 改進了對現代瀏覽器和機器人的檢測（2026 年最新規則）

### 5. 多曆法支援與13月 🗓️

支援日本年號、佛曆、民國紀年、甲子紀年、伊斯蘭曆、波斯曆等 **13 種曆法**（含埃塞俄比亞、希伯來曆 **13 個月**曆法），自動匹配站點語言。

> 📌 **埃塞俄比亞曆**：前 12 個月各 30 天，第 13 個月閏年 6 天平年 5 天。
> 📌 **希伯來曆**：19年7閏，閏年增加 Adar I（30天），形成13個月。

### 6. 自訂品牌展示 🏷️

> **適用於主機商與企業使用者**

現在支援在 `AWStats` 頁面頂部顯示自訂品牌資訊，包括 **Logo** 和 **品牌名稱**。

**功能特性**：
- 📍 品牌區域僅在 `/stats/logo.svg` 檔案存在時自動顯示
- 🔗 支援自訂品牌連結（Logo 點擊跳轉）
- 🏷️ 支援任意品牌名稱（建議使用英文名稱，相容多語言環境），自動拼接為 **`品牌名 + " 伺服器管理面板"`**

**適用場景範例**：
| 類型 | 範例 |
|:---:|:---:|
| 🐧 Linux 發行版 | `RHEL`、`Debian`、`Ubuntu`、`CentOS`、`Arch Linux`、`Fedora`、`Rocky Linux` |
| 🖥️ 作業系統 | `macOS`、`Windows`、`FreeBSD` |
| ☁️ 雲端主機商 | `Aliyun`、`Tencent`、`AWS`、`Azure`、`Google Cloud` |

**設定範例**：
```perl
# 在 AWStats 設定檔中新增
BrandLink="https://example.com"      # Logo 點擊跳轉連結
BrandPlatform="Ubuntu"               # 品牌名稱（顯示 "Ubuntu 伺服器管理面板"）
StatsUrl="/vstats"                   # AWStats 部署目錄
```

> **注意**：品牌區域僅在 `logo.svg` 檔案存在時顯示，未設定 `BrandLink` 時將使用預設值 `https://hestiacp.com`。

---

## 📦 下載與安裝

請從下方連結取得最新版本：

| 系統/格式 | 下載連結 |
|:---:|:---:|
| **Debian/Ubuntu** | [![下載 .deb 包](https://img.shields.io/badge/下載-.deb_包-2ea44f?logo=debian&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb) |
| **RHEL/CentOS/Fedora** | [![下載 .rpm 包](https://img.shields.io/badge/下載-.rpm_包-2ea44f?logo=fedora&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm) |
| **原始碼包 (tar.gz)** | [![下載原始碼 .tar.gz](https://img.shields.io/badge/下載-.tar.gz-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.tar.gz) |
| **原始碼包 (zip)** | [![下載原始碼 .zip](https://img.shields.io/badge/下載-.zip-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.zip) |
| **Windows** | [![下載 Windows版](https://img.shields.io/badge/下載-Windows版-2ea44f?logo=windows&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-utf8.exe) |

> **Windows 環境說明**：Windows 版本僅打包了 EXE 安裝包，目錄結構和路徑均未經過實際測試。如在使用中遇到問題，歡迎提交 Issue 或 Pull Request 協助修復！

---

## 📊 與原版對比

| 特性 | 原始 AWStats | 重構版本 |
|:---:|:---:|:---:|
| 編碼 | GBK / 局部編碼 | **UTF-8 全支援** |
| 翻譯方式 | 數字索引 `$Message[169]` | **語意化鍵名 `_t('key')`** |
| 介面風格 | 固定樣式 | **明暗主題切換 + 響應式** |
| 國家旗幟 | PNG圖像 | **Emoji** |
| 圖表 | PNG 圖像 | **純 CSS 圖表** |
| 曆法支援 | 公曆 | **12 種曆法** |
| 維護狀態 | 已封存 | **持續維護** |

---

## ✨ 完整功能列表

| 類別 | 功能 |
|:---:|:---:|
| 🌐 多語言 CGI 存取 | `73` 種語言介面，瀏覽器自動識別。讓全球訪客用母語檢視報告！[查看详细语言支持列表](docs/CHANGELOG-zh_CN.md#--语言支持) |
| 🗓️ 多曆法支援 | 日本年號、佛曆、民國紀年、甲子紀年、伊斯蘭曆、波斯曆等 **13 種曆法**（含衣索比亞 13 月曆），自動匹配站點語言 |
| 📊 流量統計 | 獨立訪客、訪問次數、訪問時長、驗證使用者追蹤 |
| 🌍 地理位置 | `DB-IP` 免費資料庫，國家/地區/城市三級定位，IPv4/IPv6 支援 |
| 💻 客戶端資訊 | 瀏覽器、作業系統、螢幕解析度、裝置類型（桌面/行動） |
| 🤖 爬蟲識別 | `500+` 搜尋引擎爬蟲，AI/ML 爬蟲（ClaudeBot、GPTBot 等） |
| 📁 檔案統計 | 檔案類型、下載（續傳支援）、壓縮（mod_gzip/mod_deflate） |
| ⚠️ 錯誤分析 | `HTTP` 錯誤（404 等）、錯誤來源、蠕蟲攻擊檢測狀態碼本地化描述 |
| 🎨 現代化介面 | 響應式設計、深色/淺色主題、純 CSS 圖表、Emoji 國旗圖示 |

---

## 📋 系統需求

### 基本需求
- ✅ 能夠存取要分析的伺服器日誌檔案（Web/FTP/郵件）
- ✅ Perl 5.20 或更高版本（建議 5.32+）
- ✅ 命令列和/或 CGI 環境

### 支援的作業系統
- 🐧 Linux/Unix（Ubuntu、Debian、CentOS、RHEL 等）
- 🪟 Windows（Windows 10/11、Windows Server）
- 🍎 macOS
- 🔵 FreeBSD、OpenBSD

### 支援的伺服器
- 🌐 Web：Apache、Nginx、IIS、Caddy、Lighttpd
- 📁 FTP：ProFTPd、vsFTPd、Pure-FTPd
- 📧 郵件：Postfix、Sendmail、QMail、Exim
- 🎥 串流媒體：RealMedia、Windows Media Server

---

## **AWStats Geo/IPfree.pm 版本相容性修復**

如果在執行 AWStats 更新時遇到類似以下錯誤：
```
Error: Perl v5.200.0 required (did you mean v5.20.0?)--this is only v5.36.0
```

這是因為 `Geo/IPfree.pm` 檔案中的版本檢查與當前系統的 Perl 版本不相容。

### **自動修復指令**
```bash
find /usr -name "IPfree.pm" 2>/dev/null | while read -r file; do
    sed -i.bak 's/^use 5\.20;/#use 5.20;/' "$file"
done
```

### **手動修復步驟**
如果自動指令無效，請按以下步驟操作：

1. **查找檔案位置**
   ```bash
   find /usr -name "IPfree.pm" 2>/dev/null
   ```

2. **編輯檔案，註解掉版本檢查行**
   ```bash
   sed -i 's/^use 5\.20;/#use 5.20;/' /path/to/IPfree.pm
   ```

### **補充檔案（如需要）**
由於平台的多樣性和複雜性，不同系統可能使用不同版本。如果您系統中沒有對應的檔案，請手動替換以下檔案：

| 檔案 | 位置 |
|------|------|
| `/usr/share/perl5/Geo/IPfree.pm` | [IPfree.pm](/wwwroot/cgi-bin/lib/IPfree.pm) |
| `/usr/share/perl5/Geo/IPfree.pod` | [IPfree.pod](/wwwroot/cgi-bin/lib/IPfree.pod) |
| `/usr/share/perl5/Geo/dbip-city.mmdb` | [update-dbip](/make/test/awstats/conf/update-dbip) |

---

## 🔄 升級前轉換（僅限從舊版升級）

若涉及站點升級，請先執行 `/usr/share/awstats/tools/awstats_convert-zh.pl` 對歷史資料檔案（*.txt）進行格式轉換（7.0-7.9 → 8.1）。程式將自動偵測 `/home/*/web/*/stats/` 目錄下的所有 `AWStats` 資料檔案（*.txt）並進行批次轉換。請放心執行，它將在轉換前自動備份原始檔案。若您的站點不在 `home` 目錄下，請參考這個路徑結構 `/home/站點執行使用者名稱/web/您的網域/stats/` 微調。轉換完成後，再執行資料更新操作，否則將因格式不相容導致更新失敗。

> **注意**：若您的站點版本低於 7.0，請根據實際版本號調整腳本中 `s/AWSTATS DATA FILE 7\.[0-9]{1,2}/AWSTATS DATA FILE 8.1/` 正規表示式的匹配參數。
>
> **💡 提示**：備份檔案預設儲存在 `/backup/awstats_converter/backup_執行時的時間戳記命名/` 目錄下。

```bash
# 試執行（檢視將要轉換哪些檔案）
perl /usr/share/awstats/tools/awstats_convert-zh.pl --dryrun

# 正式執行
perl /usr/share/awstats/tools/awstats_convert-zh.pl

# 強制重新轉換所有檔案
perl /usr/share/awstats/tools/awstats_convert-zh.pl --force

# 安靜模式
perl /usr/share/awstats/tools/awstats_convert-zh.pl --quiet

# 檢視說明
perl /usr/share/awstats/tools/awstats_convert-zh.pl --help
```
---

## 🚀 快速開始

### 1. 安裝

#### HestiaCP 使用者（推薦）

> **注意**：本腳本僅適用於 HestiaCP 控制面板。如果您使用其他控制面板或未使用面板管理，請參考腳本中的 `build_awstats()` 函式，依據實際環境自行調整。

HestiaCP 已內建 AWStats，更新安裝打包好的 `deb` 和 `rpm` 套件即可體驗全新社群版本。

**支援發行版**：
- 官方支援：[Debian/Ubuntu](https://github.com/hestiacp/hestiacp)
- 社群支援：[RHEL/CentOS/Alma/Rocky](https://github.com/bayrepo/hestiacp-rpm)

**需要手動調整的檔案**：

| 檔案類型 | 路徑 | 參考範例 |
|:---:|:---:|:---:|
| 模板檔案 | `/usr/local/hestia/data/templates/web/awstats/awstats.tpl` | [awstats.tpl](/make/test/awstats/conf/awstats.tpl) |
| 網域名稱設定目錄 | `/etc/awstats/` | - |
| 更新腳本 (Debian/Ubuntu 及其衍生版) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.debian](/make/test/awstats/conf/v-update-web-domain-stat) |
| 更新腳本 (RHEL/CentOS/Rocky/Alma/Fedora) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.rhel](/make/test/awstats/conf/v-update-web-domain-stat) |

> 📌 **說明**：Debian 和 RHEL 系列的腳本相關程式碼不同，請根據您的作業系統選擇對應的參考範例進行修改。

> 💡 **提示**：修改腳本後，如遇到權限問題，請執行 `chmod +x /usr/local/hestia/bin/v-update-web-domain-stat`

## 下載並安裝

### HestiaCP 整合部署

> ⚠️ **重要提示**：使用 HestiaCP 環境安裝時，若系統提示設定檔是否更新，請務必選擇 **`N`**（保留原設定），否則會覆蓋 HestiaCP 面板的特有路由設定。

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### Debian / Ubuntu 原生直接安裝

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### RHEL / CentOS / Rocky Linux / Fedora

```bash
# 採用現代 DNF 標準 install 指令，完美對齊全系列紅帽生態
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm && dnf install -y /tmp/awstats-8.1-1.noarch.rpm
```

### FreeBSD

```bash
# 安裝後一鍵注入鎖定防禦，徹底消滅第三方管理面板（如 Webmin）的舊版本降級誤報
fetch -o /tmp/awstats-8.1-1.pkg https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.pkg && \
pkg install -y /tmp/awstats-8.1-1.pkg && \
pkg lock -y awstats
```

### 基本設定

編輯設定檔 `/etc/awstats/awstats.yourdomain.conf`：

```perl
LogFile="/var/log/apache2/domains/yourdomain.log"  # 日誌檔案路徑
LogFormat=1                                         # 使用 combined 日誌格式
SiteDomain="yourdomain.com"                         # 網站網域
HostAliases="localhost 127.0.0.1"                   # 主機別名
```

### 更新統計資料

```bash
awstats.pl -config=yourdomain -update
```

### 檢視報告

- **HestiaCP 環境**：瀏覽 `https://yourdomain.com/vstats/` 如果您需要儲存書籤請設定這個目錄。瀏覽後自動載入為 CGI 模式！
- **手動產生靜態報告**：`awstats.pl -config=yourdomain -output > report.html`

---

## 📖 命令列說明

### 使用您的母語檢視說明

```bash
# 正體中文
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
# For RHEL/CentOS/Fedora:
source /etc/locale.conf
# For Debian/Ubuntu:
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

| 命令 | 說明 |
|:---:|:---:|
| `awstats.pl -config=xxx -update` | 更新統計資料 |
| `awstats.pl -config=xxx -output > report.html` | 產生靜態報告 |
| `awstats.pl -config=xxx -update -debug=2` | 偵錯模式（需要在設定檔中將 DebugMessages 改為 1，預設為 0） |
| `awstats -h` | 顯示說明 |
| `awstats -v` | 顯示版本資訊 |

---

## 📚 文件

| 文件 | 連結 |
|:---:|:---:|
| 正體中文更新日誌 | [docs/CHANGELOG-zh_TW.md](docs/CHANGELOG-zh_TW.md) |
| 英文更新日誌 | [docs/CHANGELOG.md](docs/CHANGELOG.md) |
| 安裝指南 | [docs/awstats_setup.html](docs/awstats_setup.html) |
| 設定說明 | [docs/awstats_config.html](docs/awstats_config.html) |
| 常見問題 | [docs/awstats_faq.html](docs/awstats_faq.html) |

---

## 🤝 貢獻與反饋

- **專案倉庫**：[GitHub - hestiacn/vstats](https://github.com/hestiacn/vstats)
- **問題反饋**：[GitHub Issues](https://github.com/hestiacn/vstats/issues)

---

## 💖 致謝

特別感謝所有幫助我們正確翻譯威爾斯語和阿拉伯語六種複數形式的翻譯人員和測試人員。你們是真正的網路英雄！

---

## 📄 授權條款

`AWStats` 是開源軟體，基於 [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.html#license-text) 發佈。

---

## 👨‍💻 關於作者與維護

**原始作者**：Laurent Destailleur（1997-2025）
- 專案創始人，於 2025 年 11 月宣佈停止更新。
- [Dolibarr ERP CRM](https://www.dolibarr.org) 專案負責人

**社群維護**：[hestiacn](https://github.com/hestiacn/vstats)
- 8.1 版本現代化重構
- 持續維護與更新

---

## 🔗 相關連結

- 原始專案網站：[https://www.awstats.org](https://www.awstats.org)
- 原始專案 GitHub 倉庫：[eldy/AWStats](https://github.com/eldy/AWStats)
- DB-IP 資料庫：[https://db-ip.com](https://db-ip.com)

---

## © 1997-2026 `AWStats` 團隊 | 社群版持續維護中
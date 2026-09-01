# AWStats 8.1 - 高度なWebサイト統計ツール（コミュニティ版）

<p align="center">
  <img src="docs/images/screenshot.png" alt="AWStats ダッシュボードプレビュー" width="800">
</p>

<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html#license-text"><img src="https://img.shields.io/badge/ライセンス-GPL%20v3-blue.svg" alt="ライセンス"></a>
  <a href="https://www.perl.org/"><img src="https://img.shields.io/badge/Perl-5.20%2B-brightgreen.svg" alt="Perl バージョン"></a>
  <br><br>
  <a href="https://github.com/hestiacn/vstats/releases/latest"><img src="https://img.shields.io/github/v/release/hestiacn/vstats?style=for-the-badge&logo=github&label=最新バージョン&color=blue" alt="最新バージョン"></a>
  <br><br>
  <a href="docs/CHANGELOG-zh_CN.md"><img src="https://img.shields.io/badge/📝_更新履歴-日本語版-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="更新履歴"></a>
  <br><br>
  <a href="docs/CHANGELOG.md"><img src="https://img.shields.io/badge/📝_Changelog-English_Version-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="Changelog"></a>
</p>

> **🎉 これは vstats 初のメジャーコミュニティリリースです！** 伝説的な `AWStats` (1997-2025) の全面的なリファクタリングバージョンです。長年の埃を払い、次の25年に向けて生まれ変わりました！

オリジナルの `AWStats` は25年間のメンテナンスを経て、2025年11月にアーカイブされました。本プロジェクトはオリジナルをベースに全面的なリファクタリングと機能拡張を行い、[hestiacn](https://github.com/hestiacn/vstats) コミュニティによって継続的にメンテナンスされています。

---

## 🚀 リリースのハイライト

### 1. ネイティブ UTF-8 サポート（煩わしいエンコーディングの問題から解放）

厄介なエンコーディング問題にさようなら！すべての内部ロジックと出力は完全に UTF-8 エンコーディングに対応しました。日本語、中国語、アラビア語、その他の特殊文字も完璧に表示されます。

### 2. グローバルな「ソウルフル」ローカライゼーション（73言語）

- 翻訳システム全体を数字インデックスからセマンティックキー（`_t('key')`）に移行
- 73言語の追加・更新（キプロス語、ブラジルポルトガル語など）
- 24時間統計にユニークでユーモラスな「つぶやき」説明を追加——深夜4時に働くシステム管理者へのちょっとしたサプライズ！☕️

### 3. モダンなユーザーインターフェースとレスポンシブデザイン

- **ダーク/ライトモード**：ワンクリックでテーマ切り替え
- **ピュアCSSチャート**：古いPNG画像は `border-radius` をサポートするモダンなCSSチャートに置き換え
- **絵文字統合**：データ可視化に絵文字を使用し、モダンなビジュアル体験を実現

### 4. パフォーマンスとコードの最適化

- 現代のCGI環境でのパフォーマンス向上のため、Perlコードを大幅に整理
- モダンブラウザとボットの検出機能を改善（2026年最新ルール）

### 5. 複数のカレンダーシステムと13ヶ月対応 🗓️

日本の元号、仏暦、民国紀年、干支紀年、イスラム暦、ペルシャ暦など **13種類のカレンダー**（エチオピア暦・ヘブライ暦の**13ヶ月**を含む）をサポート。サイト言語に自動マッチング。

> 📌 **エチオピア暦**：最初の12ヶ月は各30日、13ヶ月目は閏年6日・平年5日。
> 📌 **ヘブライ暦**：19年7閏、閏年は Adar I（30日）を追加し、13ヶ月になる。

### 6. カスタムブランド表示 🏷️

> **ホスティングプロバイダーや企業ユーザー向け**

`AWStats` ページの上部にカスタムブランド情報（**ロゴ** と **ブランド名**）を表示できるようになりました。

**機能の特徴**：
- 📍 ブランドエリアは `/stats/logo.svg` ファイルが存在する場合のみ自動表示
- 🔗 カスタムブランドリンクをサポート（ロゴクリック時の遷移先）
- 🏷️ 任意のブランド名をサポート（多言語環境に対応するため、英語名を推奨）。自動的に **`ブランド名 + " サーバー管理パネル"`** として表示

**ユースケース例**：
| タイプ | 例 |
|:---:|:---:|
| 🐧 Linux ディストリビューション | `RHEL`、`Debian`、`Ubuntu`、`CentOS`、`Arch Linux`、`Fedora`、`Rocky Linux` |
| 🖥️ オペレーティングシステム | `macOS`、`Windows`、`FreeBSD` |
| ☁️ クラウドホスティング | `Aliyun`、`Tencent`、`AWS`、`Azure`、`Google Cloud` |

**設定例**：
```perl
# AWStats 設定ファイルに追加
BrandLink="https://example.com"      # ロゴクリック時の遷移先リンク
BrandPlatform="Ubuntu"               # ブランド名（"Ubuntu サーバー管理パネル" と表示）
StatsUrl="/vstats"                   # AWStats のデプロイディレクトリ
```

> **注意**：ブランドエリアは `logo.svg` ファイルが存在する場合のみ表示されます。`BrandLink` が設定されていない場合は、デフォルト値 `https://hestiacp.com` が使用されます。

---

## 📦 ダウンロードとインストール

最新バージョンは以下のリンクから入手できます：

| システム/形式 | ダウンロードリンク |
|:---:|:---:|
| **Debian/Ubuntu** | [![Download .deb](https://img.shields.io/badge/Download-.deb_パッケージ-2ea44f?logo=debian&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb) |
| **RHEL/CentOS/Fedora** | [![Download .rpm](https://img.shields.io/badge/Download-.rpm_パッケージ-2ea44f?logo=fedora&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm) |
| **ソース (tar.gz)** | [![Download .tar.gz](https://img.shields.io/badge/Download-.tar.gz-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.tar.gz) |
| **ソース (zip)** | [![Download .zip](https://img.shields.io/badge/Download-.zip-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.zip) |
| **Windows** | [![Download Windows版](https://img.shields.io/badge/Download-Windows版-2ea44f?logo=windows&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-utf8.exe) |

> **Windows環境に関する注意**：Windows版はEXEインストーラーのみをパッケージングしており、ディレクトリ構造やパスは実際にテストされていません。使用中に問題が発生した場合は、IssueまたはPull Requestでのご報告をお願いいたします。

---

## 📊 オリジナル版との比較

| 機能 | オリジナル AWStats | リファクタリング版 |
|:---:|:---:|:---:|
| エンコーディング | GBK / 部分的なエンコーディング | **UTF-8 完全サポート** |
| 翻訳方式 | 数字インデックス `$Message[169]` | **セマンティックキー `_t('key')`** |
| インターフェース | 固定スタイル | **明暗テーマ切り替え + レスポンシブ** |
| 国旗 | PNG画像 | **絵文字** |
| チャート | PNG 画像 | **ピュア CSS チャート** |
| カレンダーサポート | グレゴリオ暦 | **13種類のカレンダー** |
| メンテナンス状態 | アーカイブ済み | **継続的にメンテナンス** |

---

## ✨ 完全な機能リスト

| カテゴリー | 機能 |
|:---:|:---:|
| 🌐 多言語CGIアクセス | `73` 言語のインターフェース、ブラウザ自動判定。世界中の訪問者が母国語でレポートを閲覧可能！ [詳細な言語サポートリストを見る](docs/CHANGELOG.md#-language-support) |
| 🗓️ 複数カレンダーサポート | 日本の元号、仏暦、民国紀年、干支紀年、イスラム暦、ペルシャ暦など **13種類のカレンダー**（エチオピアの13ヶ月暦を含む）、サイト言語に自動マッチング |
| 📊 アクセス統計 | ユニークビジター、訪問数、滞在時間、認証ユーザートラッキング |
| 🌍 地理位置情報 | `DB-IP` 無料データベース、国/地域/都市の3段階位置情報、IPv4/IPv6 サポート |
| 💻 クライアント情報 | ブラウザ、オペレーティングシステム、画面解像度、デバイスタイプ（デスクトップ/モバイル） |
| 🤖 クローラー識別 | `500+` 検索エンジンクローラー、AI/MLクローラー（ClaudeBot、GPTBot など） |
| 📁 ファイル統計 | ファイルタイプ、ダウンロード（レジューム対応）、圧縮（mod_gzip/mod_deflate） |
| ⚠️ エラー分析 | `HTTP` エラー（404など）、エラーソース、ワーム攻撃検出のステータスコードローカライズ説明 |
| 🎨 モダンインターフェース | レスポンシブデザイン、ダーク/ライトテーマ、ピュアCSSチャート、絵文字の国旗アイコン |

---

## 📋 システム要件

### 基本要件
- ✅ 分析対象のサーバーログファイル（Web/FTP/メール）にアクセスできること
- ✅ 5.20 以上（5.32+ を推奨）
- ✅ コマンドラインおよび/または CGI 環境

### サポートされるオペレーティングシステム
- 🐧 Linux/Unix（Ubuntu、Debian、CentOS、RHEL など）
- 🪟 Windows（Windows 10/11、Windows Server）
- 🍎 macOS
- 🔵 FreeBSD、OpenBSD

### サポートされるサーバー
- 🌐 Web：Apache、Nginx、IIS、Caddy、Lighttpd
- 📁 FTP：ProFTPd、vsFTPd、Pure-FTPd
- 📧 メール：Postfix、Sendmail、QMail、Exim
- 🎥 ストリーミング：RealMedia、Windows Media Server

---

## **AWStats Geo/IPfree.pm バージョン互換性の修正**

AWStats の更新実行中に以下のようなエラーが発生した場合：
```
Error: Perl v5.200.0 required (did you mean v5.20.0?)--this is only v5.36.0
```

これは `Geo/IPfree.pm` ファイル内のバージョンチェックが、現在のシステムの Perl バージョンと互換性がないために発生します。

### **自動修正コマンド**
```bash
find /usr -name "IPfree.pm" 2>/dev/null | while read -r file; do
    sed -i.bak 's/^use 5\.20;/#use 5.20;/' "$file"
done
```

### **手動修正手順**
自動コマンドが機能しない場合は、以下の手順に従ってください：

1. **ファイルの場所を検索**
   ```bash
   find /usr -name "IPfree.pm" 2>/dev/null
   ```

2. **ファイルを編集し、バージョンチェック行をコメントアウト**
   ```bash
   sed -i 's/^use 5\.20;/#use 5.20;/' /path/to/IPfree.pm
   ```

### **補足ファイル（必要な場合）**
プラットフォームの多様性と複雑さにより、システムによって異なるバージョンが使用される場合があります。対応するファイルがシステムに存在しない場合は、以下のファイルに手動で置き換えてください：

| ファイル | 場所 |
|------|------|
| `/usr/share/perl5/Geo/IPfree.pm` | [IPfree.pm](/wwwroot/cgi-bin/lib/IPfree.pm) |
| `/usr/share/perl5/Geo/IPfree.pod` | [IPfree.pod](/wwwroot/cgi-bin/lib/IPfree.pod) |
| `/usr/share/perl5/Geo/dbip-city.mmdb` | [update-dbip](/make/test/awstats/conf/update-dbip) |

---

## 🔄 アップグレード前の変換（旧バージョンからのアップグレードのみ）

サイトのアップグレードを行う場合は、最初に `/usr/share/awstats/tools/awstats_convert-en.pl` を実行して、履歴データファイル（*.txt）のフォーマット変換（7.0-7.9 → 8.1）を行ってください。プログラムは `/home/*/web/*/stats/` ディレクトリ以下のすべての `AWStats` データファイル（*.txt）を自動検出し、一括変換します。変換前に元のファイルを自動バックアップするので、安心して実行してください。サイトが `home` ディレクトリにない場合は、このパス構造 `/home/サイト運用ユーザー名/web/お使いのドメイン/stats/` を参考に微調整してください。変換完了後、データ更新操作を実行してください。フォーマットが互換性がない場合、更新は失敗します。

> **注意**：サイトのバージョンが 7.0 より低い場合は、実際のバージョン番号に合わせて、スクリプト内の `s/AWSTATS DATA FILE 7\.[0-9]{1,2}/AWSTATS DATA FILE 8.1/` 正規表現のマッチングパラメータを調整してください。
>
> **💡 ヒント**：バックアップファイルはデフォルトで `/backup/awstats_converter/backup_実行時のタイムスタンプ名/` ディレクトリに保存されます。

```bash
# テスト実行（変換されるファイルを確認）
perl /usr/share/awstats/tools/awstats_convert-en.pl --dryrun

# 正式実行
perl /usr/share/awstats/tools/awstats_convert-en.pl

# 全ファイルを強制的に再変換
perl /usr/share/awstats/tools/awstats_convert-en.pl --force

# サイレントモード
perl /usr/share/awstats/tools/awstats_convert-en.pl --quiet

# ヘルプを表示
perl /usr/share/awstats/tools/awstats_convert-en.pl --help
```

---

## 🚀 クイックスタート

### 1. インストール

#### HestiaCP ユーザー（推奨）

> **注意**：このスクリプトは HestiaCP パネル専用に調整されています。他のコントロールパネルを使用している場合、またはパネルを使用していない場合は、スクリプト内の `build_awstats()` 関数を参照し、実際の環境に合わせて調整してください。

HestiaCP には AWStats が既に含まれています。ビルド済みの `deb` および `rpm` パッケージを更新・インストールするだけで、新しいコミュニティバージョンを体験できます。

**対応ディストリビューション**：
- 公式サポート：[Debian/Ubuntu](https://github.com/hestiacp/hestiacp)
- コミュニティサポート：[RHEL/CentOS/Alma/Rocky](https://github.com/bayrepo/hestiacp-rpm)

**手動で調整が必要なファイル**：

| ファイルタイプ | パス | 参考例 |
|:---:|:---:|:---:|
| テンプレートファイル | `/usr/local/hestia/data/templates/web/awstats/awstats.tpl` | [awstats.tpl](/make/test/awstats/conf/awstats.tpl) |
| ドメイン設定ディレクトリ | `/etc/awstats/` | - |
| 更新スクリプト (Debian/Ubuntu および派生版) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.debian](/make/test/awstats/conf/v-update-web-domain-stat) |
| 更新スクリプト (RHEL/CentOS/Rocky/Alma/Fedora) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.rhel](/make/test/awstats/conf/v-update-web-domain-stat) |

> 📌 **説明**：Debian 系と RHEL 系ではスクリプトのコードが異なります。お使いのオペレーティングシステムに応じて、適切な参考例を選択してください。

> 💡 **ヒント**：スクリプトを変更した後、権限の問題が発生した場合は `chmod +x /usr/local/hestia/bin/v-update-web-domain-stat` を実行してください。

## ダウンロードしてインストール

### HestiaCP 統合デプロイ

> ⚠️ **重要事項**: HestiaCP環境でインストールする際、システムから設定ファイルの更新を求められた場合は、必ず **`N`**（元の設定を保持）を選択してください。そうしないと、HestiaCPパネルの固有ルーティング設定が上書きされます。

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### Debian / Ubuntu ネイティブインストール

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### RHEL / CentOS / Rocky Linux / Fedora

```bash
# 最新のDNF標準インストールコマンドを使用、Red Hatエコシステム全体に完全対応
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm && dnf install -y /tmp/awstats-8.1-1.noarch.rpm
```

### FreeBSD

```bash
# インストール後にワンクリックでロック防御を注入、サードパーティ管理パネル（Webminなど）の旧バージョンダウングレード誤報を完全に排除
fetch -o /tmp/awstats-8.1-1.pkg https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.pkg && \
pkg install -y /tmp/awstats-8.1-1.pkg && \
pkg lock -y awstats
```

### 基本設定

設定ファイル `/etc/awstats/awstats.yourdomain.conf` を編集します：

```perl
LogFile="/var/log/apache2/domains/yourdomain.log"  # ログファイルのパス
LogFormat=1                                         # combined ログ形式を使用
SiteDomain="yourdomain.com"                         # ウェブサイトのドメイン
HostAliases="localhost 127.0.0.1"                   # ホストエイリアス
```

### 統計の更新

```bash
awstats.pl -config=yourdomain -update
```

### レポートを表示

- **HestiaCP 環境**：`https://yourdomain.com/vstats/` にアクセスしてください。ブックマークを保存する場合は、このディレクトリを設定してください。アクセスすると自動的にCGIモードで読み込まれます！
- **静的レポートを手動で生成**：`awstats.pl -config=yourdomain -output > report.html`

---

## 📖 コマンドラインヘルプ

### あなたの母国語でヘルプを表示

```bash
# 日本語
dnf install -y glibc-langpack-ja
localectl set-locale LANG=ja_JP.UTF-8
# RHEL/CentOS/Fedora の場合:
source /etc/locale.conf
# Debian/Ubuntu の場合:
source /etc/default/locale
awstats -h

# 繁体中国語
dnf install -y glibc-langpack-zh
localectl set-locale LANG=zh_TW.UTF-8
# RHEL の場合
source /etc/locale.conf
# Debian の場合
source /etc/default/locale
awstats -h

# 英語 (US)
dnf install -y glibc-langpack-en
localectl set-locale LANG=en_US.UTF-8
# RHEL/CentOS/Fedora の場合:
source /etc/locale.conf
# Debian/Ubuntu の場合:
source /etc/default/locale
awstats -h

# 简体中文 (簡体字中国語)
dnf install -y glibc-langpack-zh wget
localectl set-locale LANG=zh_CN.UTF-8
# RHEL の場合
source /etc/locale.conf
# Debian の場合
source /etc/default/locale
awstats -h

# 英語 (UK)
dnf install -y glibc-langpack-en 
localectl set-locale LANG=en_GB.UTF-8
# RHEL/CentOS/Fedora の場合:
source /etc/locale.conf
# Debian/Ubuntu の場合:
source /etc/default/locale
awstats -h

# ポルトガル語 (ブラジル)
dnf install -y glibc-langpack-pt
localectl set-locale LANG=pt_BR.UTF-8
# RHEL/CentOS/Fedora の場合:
source /etc/locale.conf
# Debian/Ubuntu の場合:
source /etc/default/locale
awstats -h
```

### よく使うコマンド

| コマンド | 説明 |
|:---:|:---:|
| `awstats.pl -config=xxx -update` | 統計を更新 |
| `awstats.pl -config=xxx -output > report.html` | 静的レポートを生成 |
| `awstats.pl -config=xxx -update -debug=2` | デバッグモード。設定ファイルでこのパラメータ（デフォルト0）を変更する必要があります DebugMessages=1 |
| `awstats -h` | ヘルプを表示 |
| `awstats -v` | バージョン情報を表示 |

---

## 📚 ドキュメント

| ドキュメント | リンク |
|:---:|:---:|
| 日本語更新履歴 | [docs/CHANGELOG-ja.md](docs/CHANGELOG-ja.md) |
| 英語更新履歴 | [docs/CHANGELOG.md](docs/CHANGELOG.md) |
| インストールガイド | [docs/awstats_setup.html](docs/awstats_setup.html) |
| 設定説明 | [docs/awstats_config.html](docs/awstats_config.html) |
| よくある質問 | [docs/awstats_faq.html](docs/awstats_faq.html) |

---

## 🤝 貢献とフィードバック

- **プロジェクトリポジトリ**：[GitHub - hestiacn/vstats](https://github.com/hestiacn/vstats)
- **問題報告**：[GitHub Issues](https://github.com/hestiacn/vstats/issues)

---

## 💖 謝辞

ウェールズ語とアラビア語の6つの複数形の正しい翻訳に協力してくださったすべての翻訳者とテスト担当者に特に感謝します。皆さんは真のネットワークヒーローです！

---

## 📄 ライセンス

`AWStats` はオープンソースソフトウェアであり、[GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.html#license-text) の下でリリースされています。

---

## 👨‍💻 作者とメンテナンスについて

**オリジナル作者**：Laurent Destailleur（1997-2025）
- プロジェクト創設者、2025年11月に更新停止を発表。
- [Dolibarr ERP CRM](https://www.dolibarr.org) プロジェクトリーダー

**コミュニティメンテナンス**：[hestiacn](https://github.com/hestiacn/vstats)
- 8.1 バージョンのモダナイゼーションリファクタリング
- 継続的なメンテナンスと更新

---

## 🔗 関連リンク

- オリジナルプロジェクトウェブサイト：[https://www.awstats.org](https://www.awstats.org)
- オリジナルプロジェクト GitHub リポジトリ：[eldy/AWStats](https://github.com/eldy/AWStats)
- DB-IP データベース：[https://db-ip.com](https://db-ip.com)

---

## © 1997-2026 AWStats チーム | コミュニティ版は継続的にメンテナンス中
# AWStats 8.1 - Geavanceerde website statistieken tool (Community Editie)

<p align="center">
  <img src="docs/images/screenshot.png" alt="AWStats Dashboard Voorbeeld" width="800">
</p>

<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html#license-text"><img src="https://img.shields.io/badge/Licentie-GPL%20v3-blue.svg" alt="Licentie"></a>
  <a href="https://www.perl.org/"><img src="https://img.shields.io/badge/Perl-5.20%2B-brightgreen.svg" alt="Perl Versie"></a>
  <br><br>
  <a href="https://github.com/hestiacn/vstats/releases/latest"><img src="https://img.shields.io/github/v/release/hestiacn/vstats?style=for-the-badge&logo=github&label=Laatste%20versie&color=blue" alt="Laatste versie"></a>
  <br><br>
  <a href="docs/CHANGELOG-en_CN.md"><img src="https://img.shields.io/badge/📝_Wijzigingslog-Nederlandse_versie-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="Wijzigingslog"></a>
  <br><br>
  <a href="docs/CHANGELOG.md"><img src="https://img.shields.io/badge/📝_Changelog-English_Version-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="Changelog"></a>
</p>

> **🎉 Dit is de eerste grote community release van vstats!** Een volledige herstructurering van de legendarische `AWStats` (1997-2025). We hebben het afgestoft en gemoderniseerd zodat het klaar is voor de uitdagingen van de komende 25 jaar!

De originele `AWStats` werd in november 2025 gearchiveerd na 25 jaar onderhoud. Dit project is een volledige herstructurering en functionele verbetering van het origineel, dat wordt onderhouden door de [hestiacn](https://github.com/hestiacn/vstats) gemeenschap.

---

## 🚀 Hoogtepunten van de release

### 1. Native UTF-8 ondersteuning (Vaarwel aan vervelende codering)

Zeg vaarwel tegen vervelende coderingsproblemen! Alle interne logica en uitvoer gebruiken nu volledig UTF-8-codering. Nederlands, Chinees, Japans, Arabisch en andere speciale tekens worden nu perfect weergegeven.

### 2. Wereldwijde "zielvolle" lokalisatie (73 talen)

- Het hele vertaalsysteem omgezet van numerieke indexen naar semantische sleutels (`_t('key')`)
- 73 talen toegevoegd/bijgewerkt (waaronder Cypriotisch, Braziliaans Portugees, enz.)
- Voorzien van unieke humoristische beschrijvingen voor 24-uurs statistieken - een kleine verrassing voor systeembeheerders die om 4 uur 's ochtends werken! ☕️

### 3. Moderne gebruikersinterface en responsief ontwerp

- **Donkere/Lichte modus**: schakel met één klik tussen thema's
- **Pure CSS grafieken**: oude PNG-afbeeldingen vervangen door moderne CSS-grafieken met `border-radius` ondersteuning
- **Emoji-integratie**: gebruik van emoji's voor gegevensvisualisatie voor een moderne visuele ervaring

### 4. Prestatie- en code-optimalisaties

- Aanzienlijke opschoning van Perl-code voor betere prestaties in moderne CGI-omgevingen
- Verbeterde detectie van moderne browsers en robots (meest actuele regels van 2026)

### 5. Ondersteuning voor meerdere kalenders en 13 maanden 🗓️

Ondersteuning voor **13 kalendertypes** (inclusief Ethiopische en Hebreeuwse kalenders met **13 maanden**), automatisch afgestemd op de taal van de site.

> 📌 **Ethiopische kalender**: eerste 12 maanden hebben elk 30 dagen, 13e maand heeft 6 dagen in schrikkeljaar en 5 dagen in gewoon jaar.
> 📌 **Hebreeuwse kalender**: 7 schrikkeljaren in een cyclus van 19 jaar, in schrikkeljaren wordt Adar I (30 dagen) toegevoegd, waardoor een 13e maand ontstaat.

### 6. Aanpasbare merkweergave 🏷️

> **Voor hostingproviders en zakelijke gebruikers**

Het is nu mogelijk om aangepaste merk-informatie (**Logo** en **Merknaam**) weer te geven bovenaan de `AWStats` pagina.

**Functionaliteiten**:
- 📍 Het merkgebied wordt alleen automatisch weergegeven wanneer het bestand `/stats/logo.svg` bestaat
- 🔗 Ondersteuning voor aangepaste merklink (klikbaar logo)
- 🏷️ Ondersteuning voor elke merknaam (Engelse naam aanbevolen voor meertalige compatibiliteit), automatisch opgemaakt als **`Merknaam + " Serverbeheerpaneel"`**

**Voorbeelden**:
| Type | Voorbeelden |
|:---:|:---:|
| 🐧 Linux distributies | `RHEL`, `Debian`, `Ubuntu`, `CentOS`, `Arch Linux`, `Fedora`, `Rocky Linux` |
| 🖥️ Besturingssystemen | `macOS`, `Windows`, `FreeBSD` |
| ☁️ Cloud hosting | `Aliyun`, `Tencent`, `AWS`, `Azure`, `Google Cloud` |

**Configuratievoorbeeld**:
```perl
# Toe te voegen in AWStats configuratiebestand
BrandLink="https://example.com"      # Link bij klik op logo
BrandPlatform="Ubuntu"               # Merknaam (toont "Ubuntu Serverbeheerpaneel")
StatsUrl="/vstats"                   # AWStats implementatiemap
```

> **Opmerking**: Het merkgebied wordt alleen weergegeven als het bestand `logo.svg` bestaat. Als `BrandLink` niet is geconfigureerd, wordt de standaardwaarde `https://hestiacp.com` gebruikt.

---

## 📦 Download en installatie

Download de nieuwste versie via onderstaande links:

| Systeem/Formaat | Downloadlink |
|:---:|:---:|
| **Debian/Ubuntu** | [![Download .deb](https://img.shields.io/badge/Download-.deb_pakket-2ea44f?logo=debian&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb) |
| **RHEL/CentOS/Fedora** | [![Download .rpm](https://img.shields.io/badge/Download-.rpm_pakket-2ea44f?logo=fedora&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm) |
| **Broncode (tar.gz)** | [![Download .tar.gz](https://img.shields.io/badge/Download-.tar.gz-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.tar.gz) |
| **Broncode (zip)** | [![Download .zip](https://img.shields.io/badge/Download-.zip-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.zip) |
| **Windows** | [![Download Windows](https://img.shields.io/badge/Download-Windows_versie-2ea44f?logo=windows&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-utf8.exe) |

> **Opmerking voor Windows**: De Windows-versie bevat alleen de EXE-installer. De mapstructuur en paden zijn niet getest. Als u problemen ondervindt tijdens het gebruik, dien dan een Issue of Pull Request in.

---

## 📊 Vergelijking met originele versie

| Kenmerk | Originele AWStats | Hervormde versie |
|:---:|:---:|:---:|
| Codering | GBK / gedeeltelijke codering | **Volledige UTF-8 ondersteuning** |
| Vertaalmethode | Numerieke index `$Message[169]` | **Semantische sleutels `_t('key')`** |
| Interface stijl | Vaste stijl | **Lichte/Donkere thema's + Responsief** |
| Vlaggen | PNG afbeeldingen | **Emoji's** |
| Grafieken | PNG afbeeldingen | **Pure CSS grafieken** |
| Kalenderondersteuning | Gregoriaans | **13 kalenders** |
| Onderhoudsstatus | Gearchiveerd | **Actief onderhouden** |

---

## ✨ Volledige functielijst

| Categorie | Functie |
|:---:|:---:|
| 🌐 Meertalige CGI-toegang | Interface in `73` talen, automatische browsherkenning. Laat bezoekers wereldwijd rapporten in hun moedertaal zien! [Bekijk volledige taalondersteuningslijst](docs/CHANGELOG.md#-language-support) |
| 🗓️ Meerdere kalenders | **13 kalendertypes** (inclusief Ethiopische 13-maandskalender), automatische aanpassing aan sitetaal |
| 📊 Bezoekersstatistieken | Unieke bezoekers, aantal bezoeken, verblijfsduur, tracking van geauthenticeerde gebruikers |
| 🌍 Geolocatie | Gratis `DB-IP` database, land/regio/stad drie niveaus, IPv4/IPv6 ondersteuning |
| 💻 Client informatie | Browser, besturingssysteem, schermresolutie, apparaattype (desktop/mobiel) |
| 🤖 Robotdetectie | `500+` zoekmachine robots, AI/ML bots (ClaudeBot, GPTBot, enz.) |
| 📁 Bestandsstatistieken | Bestandstypen, downloads (hervatbaar), compressie (mod_gzip/mod_deflate) |
| ⚠️ Foutanalyse | `HTTP` fouten (404, enz.), foutbronnen, gelokaliseerde beschrijvingen van wormaanvalsdetectie statuscodes |
| 🎨 Moderne interface | Responsief ontwerp, donker/licht thema, pure CSS grafieken, Emoji vlaggen |

---

## 📋 Systeemvereisten

### Basisvereisten
- ✅ Toegang tot te analyseren serverlogbestanden (Web/FTP/Mail)
- ✅ 5.20 of hoger (5.32+ aanbevolen)
- ✅ Commandoregel en/of CGI omgeving

### Ondersteunde besturingssystemen
- 🐧 Linux/Unix (Ubuntu, Debian, CentOS, RHEL, enz.)
- 🪟 Windows (Windows 10/11, Windows Server)
- 🍎 macOS
- 🔵 FreeBSD, OpenBSD

### Ondersteunde servers
- 🌐 Web: Apache, Nginx, IIS, Caddy, Lighttpd
- 📁 FTP: ProFTPd, vsFTPd, Pure-FTPd
- 📧 Mail: Postfix, Sendmail, QMail, Exim
- 🎥 Streaming: RealMedia, Windows Media Server

---

## 🔄 Conversie voor upgrade (alleen bij upgrade van oudere versies)

Voer bij een site-upgrade eerst `/usr/share/awstats/tools/awstats_convert-en.pl` uit om de geschiedenisgegevensbestanden (*.txt) te converteren (7.0-7.9 → 8.1). Het programma detecteert en converteert automatisch alle `AWStats` gegevensbestanden (*.txt) in de map `/home/*/web/*/stats/`. Het maakt automatisch back-ups van originele bestanden voor de conversie. Als uw site niet in de map `home` staat, gebruik dan deze padstructuur als referentie: `/home/site_gebruikersnaam/web/uw_domein/stats/`. Voer na de conversie de gegevensupdate uit, anders zal de update mislukken vanwege formaatincompatibiliteit.

> **Opmerking**: Als uw siteversie lager is dan 7.0, pas dan de parameter van de reguliere expressie `s/AWSTATS DATA FILE 7\.[0-9]{1,2}/AWSTATS DATA FILE 8.1/` in het script aan op basis van het werkelijke versienummer.
>
> **💡 Tip**: Back-upbestanden worden standaard opgeslagen in de map `/backup/awstats_converter/backup_tijdstempel_van_uitvoering/`.

```bash
# Proefrun (bekijk welke bestanden worden geconverteerd)
perl /usr/share/awstats/tools/awstats_convert-en.pl --dryrun

# Normale uitvoering
perl /usr/share/awstats/tools/awstats_convert-en.pl

# Geforceerde herconversie van alle bestanden
perl /usr/share/awstats/tools/awstats_convert-en.pl --force

# Stille modus
perl /usr/share/awstats/tools/awstats_convert-en.pl --quiet

# Help bekijken
perl /usr/share/awstats/tools/awstats_convert-en.pl --help
```

---

## 🚀 Snelstart

### 1. Installatie

#### Voor HestiaCP-gebruikers (Aanbevolen)

> **Opmerking**: Dit script is specifiek aangepast voor het HestiaCP-bedieningspaneel. Als je een ander bedieningspaneel gebruikt of helemaal geen paneel, raadpleeg dan de `build_awstats()`-functie in het script en pas deze aan op basis van jouw specifieke omgeving.

HestiaCP wordt al geleverd met AWStats. Update en installeer eenvoudig de vooraf gebouwde `deb`- en `rpm`-pakketten om de nieuwe community-editie te ervaren.

**Ondersteunde distributies**:
- Officiële ondersteuning: [Debian/Ubuntu](https://github.com/hestiacp/hestiacp)
- Community-ondersteuning: [RHEL/CentOS/Alma/Rocky](https://github.com/bayrepo/hestiacp-rpm)

**Bestanden die handmatige aanpassing vereisen**:

| Bestandstype | Pad | Referentievoorbeeld |
|:---:|:---:|:---:|
| Templatebestand | `/usr/local/hestia/data/templates/web/awstats/awstats.tpl` | [awstats.tpl](/make/test/awstats/conf/awstats.tpl) |
| Domeinconfiguratiemap | `/etc/awstats/` | - |
| Updatescript (Debian/Ubuntu en afgeleiden) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.debian](/make/test/awstats/conf/v-update-web-domain-stat) |
| Updatescript (RHEL/CentOS/Rocky/Alma/Fedora) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.rhel](/make/test/awstats/conf/v-update-web-domain-stat) |

> 📌 **Uitleg**: De scriptcode verschilt tussen Debian-gebaseerde en RHEL-gebaseerde systemen. Kies het juiste referentievoorbeeld op basis van jouw besturingssysteem.

> 💡 **Tip**: Als je na het wijzigen van het script een machtigingsprobleem ondervindt, voer dan `chmod +x /usr/local/hestia/bin/v-update-web-domain-stat` uit.

## Downloaden en installeren

### HestiaCP Integratie Implementatie

> ⚠️ **Belangrijke opmerking**: Wanneer u installeert in een HestiaCP-omgeving en het systeem u vraagt om het configuratiebestand bij te werken, selecteer dan **`N`** (originele configuratie behouden), anders wordt de specifieke routeringsconfiguratie van het HestiaCP-paneel overschreven.

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### Debian / Ubuntu Native Installatie

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### RHEL / CentOS / Rocky Linux / Fedora

```bash
# Gebruik van moderne DNF standaard installatie-instructie, perfect compatibel met de volledige Red Hat-ecosysteem
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm && dnf install -y /tmp/awstats-8.1-1.noarch.rpm
```

### FreeBSD

```bash
# One-click lock injectie na installatie, elimineert volledig valse downgrade-rapporten van third-party beheerpanelen (zoals Webmin)
fetch -o /tmp/awstats-8.1-1.pkg https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.pkg && \
pkg install -y /tmp/awstats-8.1-1.pkg && \
pkg lock -y awstats
```

### Basisconfiguratie

Bewerk het configuratiebestand `/etc/awstats/awstats.uw_domein.conf`:

```perl
LogFile="/var/log/apache2/domains/uw_domein.log"  # Pad naar logbestand
LogFormat=1                                         # Gebruik gecombineerd logformaat
SiteDomain="uw_domein.com"                         # Websitedomein
HostAliases="localhost 127.0.0.1"                   # Host aliassen
```

### Statistieken bijwerken

```bash
awstats.pl -config=uw_domein -update
```

### Rapport bekijken

- **HestiaCP omgeving**: Ga naar `https://uw_domein.com/vstats/`. Stel deze map in als u een bladwijzer wilt opslaan. Bij toegang wordt automatisch de CGI-modus geladen!
- **Handmatig statisch rapport genereren**: `awstats.pl -config=uw_domein -output > rapport.html`

---

## 📖 Commandoregel help

### Help bekijken in uw moedertaal

```bash
# Nederlands
dnf install -y glibc-langpack-nl
localectl set-locale LANG=nl_NL.UTF-8
# Voor RHEL/CentOS/Fedora:
source /etc/locale.conf
# Voor Debian/Ubuntu:
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

# 繁體中文
dnf install -y glibc-langpack-zh
localectl set-locale LANG=zh_TW.UTF-8
# Voor RHEL/CentOS/Fedora:
source /etc/locale.conf
# Voor Debian/Ubuntu:
source /etc/default/locale
awstats -h

# 简体中文
dnf install -y glibc-langpack-zh wget
localectl set-locale LANG=zh_CN.UTF-8
# Voor RHEL/CentOS/Fedora:
source /etc/locale.conf
# Voor Debian/Ubuntu:
source /etc/default/locale
awstats -h

# 日本語
dnf install -y glibc-langpack-ja
localectl set-locale LANG=ja_JP.UTF-8
# Voor RHEL/CentOS/Fedora:
source /etc/locale.conf
# Voor Debian/Ubuntu:
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

### Veelgebruikte commando's

| Commando | Beschrijving |
|:---:|:---:|
| `awstats.pl -config=xxx -update` | Statistieken bijwerken |
| `awstats.pl -config=xxx -output > rapport.html` | Statisch rapport genereren |
| `awstats.pl -config=xxx -update -debug=2` | Debug-modus (vereist DebugMessages=1 in configuratiebestand) |
| `awstats -h` | Help weergeven |
| `awstats -v` | Versie-informatie weergeven |

---

## 📚 Documentatie

| Document | Link |
|:---:|:---:|
| Wijzigingslog (Nederlands) | [docs/CHANGELOG-nl.md](docs/CHANGELOG-nl.md) |
| Wijzigingslog (Engels) | [docs/CHANGELOG.md](docs/CHANGELOG.md) |
| Installatiegids | [docs/awstats_setup.html](docs/awstats_setup.html) |
| Configuratie-uitleg | [docs/awstats_config.html](docs/awstats_config.html) |
| Veelgestelde vragen | [docs/awstats_faq.html](docs/awstats_faq.html) |

---

## 🤝 Bijdragen en feedback

- **Projectrepository**: [GitHub - hestiacn/vstats](https://github.com/hestiacn/vstats)
- **Problemen melden**: [GitHub Issues](https://github.com/hestiacn/vstats/issues)

---

## 💖 Dankbetuigingen

Speciale dank aan alle vertalers en testers die ons hebben geholpen bij het correct vertalen van de zes meervoudsvormen in het Welsh en Arabisch. Jullie zijn echte netwerkhelden!

---

## 📄 Licentie

`AWStats` is open source software, uitgebracht onder de [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.html#license-text).

---

## 👨‍💻 Over de auteur en onderhoud

**Originele auteur**: Laurent Destailleur (1997-2025)
- Projectoprichter, kondigde stopzetting van updates aan in november 2025.
- Projectleider van [Dolibarr ERP CRM](https://www.dolibarr.org)

**Community onderhoud**: [hestiacn](https://github.com/hestiacn/vstats)
- Moderniseringsherstructurering van versie 8.1
- Actief onderhoud en updates

---

## 🔗 Gerelateerde links

- Originele projectwebsite: [https://www.awstats.org](https://www.awstats.org)
- Originele project GitHub repository: [eldy/AWStats](https://github.com/eldy/AWStats)
- DB-IP database: [https://db-ip.com](https://db-ip.com)

---

## © 1997-2026 AWStats Team | Community Editie wordt actief onderhouden
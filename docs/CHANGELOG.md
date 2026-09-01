# 📋 AWStats Release Changelog

*Based on official documentation, SourceForge records, and historical author materials. Some dates may not match actual release dates. For original records, please visit [SourceForge](https://sourceforge.net/projects/awstats/).*

⚠️ **AWStats 8.0 will be the last version maintained by the original author(Laurent Destailleur). Subsequent versions are maintained by the community.**

## 🚀 8.x Series(2026-latest)

### 8.1 - 2026-05-10

### 🔧 Fixed original documentation to local static documentation

The original static documentation required adding code implementation in the update script. The drawback of this approach was that the language was selected by the site deployer, resulting in users only seeing the Chinese and English static documentation that I initially added.

**Background**: The original idea was to address the fact that the original author `Laurent Destailleur` left behind very comprehensive documentation, but it was entirely in English. Non-English speakers were completely lost, causing many classic examples to be buried in the history of the internet.

**Problem**: During the modification process, I never achieved the desired effect because implementing multilingual support within a single HTML file required a large number of language keys. This approach was far from elegant and completely failed to utilize the translations in the po files.

**Solution**: While refactoring `awstats.pl`, I integrated all the documentation directly into the main program. It now displays translations based on the browser's request headers. `CGI` dynamically reads based on the browser language, defaulting to English for any documentation without a complete translation.

For details, see the [Complete Localization](#full-localizationinterface--documentation) documentation. If you need to add translations for your language's documentation localization, please refer to [Partial Localization (Interface Only)](#partial-localizationinterface-only) and submit your contributions!

### 🏷️ New Feature: Custom Branding Display

> **🚀 vstats: Bringing Warmth to Statistics**
AWStats is no longer just a cold data page. Now you can easily embed your brand identity at the top of reports. Combined with powerful support for 73 languages and 13 calendar systems, users worldwide can access statistics without cultural or language barriers.

### 🚀 Branding Features

- **Universal Compatibility**: Perfectly displays whether you're using mainstream Linux distributions or various operating systems
- **Visual Consistency**: Supports vector SVG logos, ensuring sharp clarity at any resolution(including Retina displays)
- **Smart Concatenation**: The system automatically combines your brand name with the multilingual `Server Management Panel` field, achieving brand localization across all languages

### 🖼️ Usage Examples

| Type | Examples |
|:---:|:---:|
| 🐧 Linux Distributions | `RHEL`, `Debian`, `Ubuntu`, `CentOS`, `Arch Linux`, `Fedora`, `Rocky Linux` |
| 🖥️ Operating Systems | `macOS`, `Windows`, `FreeBSD` |
| ☁️ Cloud Providers | `Aliyun`, `Tencent`, `AWS`, `Azure`, `Google Cloud` |

### 📝 Configuration Example

Add the following to your AWStats configuration file(e.g., `/etc/awstats/awstats.yourdomain.conf`):

**💡 Quick Reference:** You can directly review the optimized [awstats.tpl standard configuration template](/make/make/test/awstats/conf/awstats.tpl), which includes recommended branding settings and performance optimization parameters.

```perl
# --- Brand Customization Settings ---
BrandLink="https://your-company.com"   # Logo click redirect URL
BrandPlatform="CloudStack"             # Your platform name(English characters recommended)
StatsUrl="/vstats"                     # The web deployment path of AWStats, used to generate document link mappings in the navigation bar.
```

### 🌐 Automated Localization Effects

**vstats** automatically embeds `BrandPlatform` into 73 native language contexts, achieving true global branding:

| Language | Real-time Rendering Preview |
| :---: | :--- |
| **简体中文** | `HestiaCP 服务器管理面板` |
| **English** | `HestiaCP Server Management Panel` |
| **Kannada** | `HestiaCP ಸರ್ವರ್ ನಿರ್ವಹಣಾ ಫಲಕ` |
| **Georgian** | `HestiaCP სერვერის მართვის පැනელი` |
| **Arabic** | `لوحة إدارة خوادم HestiaCP` |

> 📌 **Note**: The system will automatically handle the word order of different languages (such as right-to-left display for Arabic), ensuring that the brand is presented professionally and authentically in any cultural context.

**Effects**
- `BrandPlatform="HestiaCP"` → Displays **"HestiaCP Server Management Panel"**
- `BrandPlatform="cPanel"` → Displays **"cPanel Server Management Panel"**
- `BrandPlatform="Plesk"` → Displays **"Plesk Server Management Panel"**
- `BrandPlatform="DirectAdmin"` → Displays **"DirectAdmin Server Management Panel"**
- `BrandPlatform="CyberPanel"` → Displays **"CyberPanel Server Management Panel"**
- `BrandPlatform="aapanel"` → Displays **"aapanel Server Management Panel"**
- `BrandPlatform="Portainer"` → Displays **"Portainer Server Management Panel"**
- `BrandPlatform="CasaOS"` → Displays **"CasaOS Server Management Panel"**
- `BrandPlatform="NPM"` → Displays **"NPM Server Management Panel"**

### ⚠️ Activation Condition

To keep the interface clean, the branding area **only activates when the `logo.svg` file exists and is readable**.

- **File Location**: Place your brand icon named `logo.svg` in your site's AWStats directory
- **Default Link**: If `BrandLink` is not configured, the system defaults to `https://hestiacp.com`

### 🗓️ **New localdate calendar plugin** Automatically switches calendar display based on user language

> **Enabled by default**, if you need to disable it, please add `EnableLocaldatePlugin=0` in the configuration file
> ⚠️ **Note:** The start date for the Japanese era name needs to be manually configured. See the notes within the `plugins/localdate.pm` for details.
- 🇯🇵 Japanese era(Reiwa): Open `plugins/localdate.pm` and locate lines 80-86. Remove the `#` comment before the era you wish to enable, and fill in the correct start date(`start_year`, `start_month`, `start_day`). Also add the corresponding era translation key in `lang/awstats-ja.po`(`calendar_era_2` → `New Era Name`). Subsequent eras follow the same pattern(`calendar_era_3`, `calendar_era_4`...)
- 🇹🇭 Buddhist calendar(Thailand, Cambodia, Laos)
- 🇹🇼 Minguo calendar(ROC)
- 🇨🇳 Ganzhi calendar(Heavenly Stems + Earthly Branches + Zodiac)
- 🇻🇳 Vietnamese Ganzhi calendar(Heavenly Stems + Earthly Branches + Zodiac, Rabbit → Cat)
- 🇰🇷 Dangun calendar
- 🕌 Islamic(Hijri)calendar
- 🇮🇷 Persian calendar
- 🇲🇲 Burmese calendar
- 🇳🇵 Vikram Samvat
- 🇮🇳 Saka calendar
- 🇪🇹 Ethiopian calendar
- 🇧🇩 Bengali calendar
- ✡️ Hebrew calendar

> 📌 **Ethiopian calendar**: First 12 months have 30 days each, the 13th month has 6 days in leap years and 5 days in common years.
> 📌 **Hebrew calendar**: 7 leap years in a 19-year cycle, adds one month(Adar I, 30 days)in leap years, totaling 13 months.

If you find any issues, please report them on [issues](https://github.com/hestiacn/vstats/issues). This feature automatically adapts the calendar display of report dates to match the site's current language(e.g., Arabic shows Islamic calendar, Japanese shows Japanese era), no additional configuration required.

#### 🎨 UI & Experience
- 📱 Adopted HTML5 standard with responsive design, perfectly adapted for mobile, tablet and desktop
- 🌙 Added dark/light theme toggle with system theme follow support
- 🧭 Added navigation menu allowing site administrators to read official documentation in their native language
- 📖 Added documentation viewer(iframe)- click menu links to view docs within the page with a close button
- 😊 Replaced country/region flag icons with Emoji, more modern and lightweight
- 📊 Modernized table styling: rounded borders, hover highlight effects
- 🎨 Defined theme colors using CSS variables, support one-click dark/light mode toggle
- 📊 Rebuilt chart engine: removed PNG image dependency, using pure CSS progress bars and bar charts
- 🖼️ Upgraded icon system: all PNG icons replaced with vector SVG format
- 🎨 Significantly upgraded OS/device icon library, added 200+ recognitions
- 🔝 Added back-to-top button with smooth scroll
- 🕐 Optimized hour chart tooltip hints with 24-hour independent copy

### 🌍 Language Support

- Language files over 300 KB contain complete localized language documentation.

| Language | Country/Region | Legacy Format | Modern Format | Update Type | File Size | Language Tag(BCP 47)|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Albanian | Albania(Shqipëria)| - | `awstats-sq.po` | ✨ New | 129 KB | BCP 47: `sq` |
| Amharic | Ethiopia(ኢትዮጵያ)| - | `awstats-am.po` | ✨ New | 164 KB | BCP 47: `am` |
| Azerbaijani | Azerbaijan(Azərbaycan)| - | `awstats-az.po` | ✨ New | 132 KB | BCP 47: `az` |
| Arabic | Arab League(الجامعة العربية)| `awstats-ar.txt` | `awstats-ar.po` | 🔄 Format Upgrade | 678 KB | BCP 47: `ar` |
| Irish | Ireland(Éire)| - | `awstats-ga.po` | ✨ New | 128 KB | BCP 47: `ga` |
| Estonian | Estonia(Eesti)| `awstats-et.txt` | `awstats-et.po` | 🔄 Format Upgrade | 123 KB | BCP 47: `et` |
| Basque | Spain/France(Euskal Herria)| `awstats-eu.txt` | `awstats-eu.po` | 🔄 Format Upgrade | 126 KB | BCP 47: `eu` |
| Brazilian Portuguese | Brazil(Brasil)| - | `awstats-pt-br.po` | ✨ New | 125 KB | BCP 47: `pt-br` |
| Bulgarian | Bulgaria(България)| `awstats-bg.txt` | `awstats-bg.po` | 🔄 Format Upgrade | 175 KB | BCP 47: `bg` |
| Icelandic | Iceland(Ísland)| - | `awstats-is.po` | ✨ New | 121 KB | BCP 47: `is` |
| Polish | Poland(Polska)| `awstats-pl.txt` | `awstats-pl.po` | 🔄 Format Upgrade | 124 KB | BCP 47: `pl` |
| Bosnian | Bosnia and Herzegovina(Bosna i Hercegovina)| `awstats-ba.txt` | `awstats-bs.po` | 🔄 Re-added | 125 KB | BCP 47: `bs`(original code `ba` was country code → corrected to language code `bs`)|
| Persian | Iran(ایران)| - | `awstats-fa.po` | ✨ New | 157 KB | BCP 47: `fa` |
| Breton | Brittany, France(Breizh)| `awstats-br.txt` | `awstats-br.po` | 🔄 Format Upgrade | 124 KB | BCP 47: `br` |
| Danish | Denmark(Danmark)| `awstats-dk.txt` | `awstats-da.po` | 🔄 Format Upgrade + Renamed | 120 KB | BCP 47: `da`(original code `dk` was country code → corrected to language code `da`)|
| German | Germany(Deutschland)| `awstats-de.txt` | `awstats-de.po` | 🔄 Format Upgrade | 127 KB | BCP 47: `de` |
| Russian | Russia(Россия)| `awstats-ru.txt` | `awstats-ru.po` | 🔄 Format Upgrade | 764 KB | BCP 47: `ru` |
| French | France(France)| `awstats-fr.txt` | `awstats-fr.po` | 🔄 Format Upgrade | 591 KB | BCP 47: `fr` |
| Finnish | Finland(Suomi)| `awstats-fi.txt` | `awstats-fi.po` | 🔄 Format Upgrade | 124 KB | BCP 47: `fi` |
| Khmer | Cambodia(កម្ពុជា)| - | `awstats-km.po` | ✨ New | 219 KB | BCP 47: `km` |
| Dutch | Netherlands(Nederland)| `awstats-nl.txt` | `awstats-nl.po` | 🔄 Format Upgrade | 573 KB | BCP 47: `nl` |
| Galician | Galicia, Spain(Galicia)| `awstats-gl.txt` | `awstats-gl.po` | 🔄 Format Upgrade | 129 KB | BCP 47: `gl` |
| Catalan | Spain/France(Catalunya)| `awstats-ca.txt` | `awstats-ca.po` | 🔄 Format Upgrade | 130 KB | BCP 47: `ca` |
| Czech | Czechia(Česko)| `awstats-cz.txt` | `awstats-cs.po` | 🔄 Format Upgrade + Renamed | 127 KB | BCP 47: `cs`(original code `cz` was country code → corrected to language code `cs`)|
| Georgian | Georgia(საქართველო)| - | `awstats-ka.po` | ✨ New | 226 KB | BCP 47: `ka` |
| Korean | South Korea(한국)| `awstats-ko.txt` | `awstats-ko.po` | 🔄 Format Upgrade | 568 KB | BCP 47: `ko` |
| Kannada | Karnataka, India(ಕನ್ನಡ)| - | `awstats-kn.po` | ✨ New | 222 KB | BCP 47: `kn` |
| Kazakh | Kazakhstan(Қазақстан)| - | `awstats-kk.po` | ✨ New | 169 KB | BCP 47: `kk` |
| Croatian | Croatia(Hrvatska)| `awstats-hr.txt` | `awstats-hr.po` | 🔄 Format Upgrade | 123 KB | BCP 47: `hr` |
| Latvian | Latvia(Latvija)| `awstats-lv.txt` | `awstats-lv.po` | 🔄 Format Upgrade | 127 KB | BCP 47: `lv` |
| Lao | Laos(ປະເທດລາວ)| - | `awstats-lo.po` | ✨ New | 202 KB | BCP 47: `lo` |
| Lithuanian | Lithuania(Lietuva)| `awstats-lt.txt` | `awstats-lt.po` | 🔄 Format Upgrade | 129 KB | BCP 47: `lt` |
| Romanian | Romania(România)| `awstats-ro.txt` | `awstats-ro.po` | 🔄 Format Upgrade | 126 KB | BCP 47: `ro` |
| Marathi | Maharashtra, India(मराठी)| - | `awstats-mr.po` | ✨ New | 205 KB | BCP 47: `mr` |
| Malayalam | Kerala, India(മലയാളം)| - | `awstats-ml.po` | ✨ New | 237 KB | BCP 47: `ml` |
| Malay | Malaysia/Indonesia(Malaysia/Indonesia)| - | `awstats-ms.po` | ✨ New | 119 KB | BCP 47: `ms` |
| Macedonian | North Macedonia(Северна Македонија)| - | `awstats-mk.po` | ✨ New | 162 KB | BCP 47: `mk` |
| Bengali | Bangladesh(বাংলাদেশ)| - | `awstats-bn.po` | ✨ New | 214 KB | BCP 47: `bn` |
| Mongolian | Mongolia(Монгол улс)| - | `awstats-mn.po` | ✨ New | 169 KB | BCP 47: `mn` |
| Burmese | Myanmar(မြန်မာ)| - | `awstats-my.po` | ✨ New | 250 KB | BCP 47: `my` |
| Nepali | Nepal(नेपाल)| - | `awstats-ne.po` | ✨ New | 210 KB | BCP 47: `ne` |
| Norwegian(Bokmål)| Norway(Norge)| `awstats-no.txt` | `awstats-nb.po` | 🔄 Format Upgrade + Renamed | 115 KB | BCP 47: `nb`(original macrolanguage code `no` refined to written variant `nb` → Bokmål)|
| Norwegian(Nynorsk)| Norway(Noreg)| - | `awstats-nn.po` | ✨ New | 115 KB | BCP 47: `nn`(Nynorsk → New Norwegian variant)|
| Punjabi | India/Pakistan(ਪੰਜਾਬ)| - | `awstats-pa.po` | ✨ New | 198 KB | BCP 47: `pa` |
| Portuguese | Portugal(Portugal)| `awstats-pt.txt` | `awstats-pt.po` | 🔄 Format Upgrade | 125 KB | BCP 47: `pt`(European Portuguese)|
| Japanese | Japan(日本)| `awstats-jp.txt` | `awstats-ja.po` | 🔄 Format Upgrade + Renamed | 635 KB | BCP 47: `ja`(original code `jp` was country code → corrected to language code `ja`)|
| Swedish | Sweden(Sverige)| `awstats-sv.txt` | `awstats-sv.po` | 🔄 Format Upgrade | 119 KB | BCP 47: `sv` |
| Serbian | Serbia(Србија)| `awstats-sr.txt` | `awstats-sr.po` | 🔄 Format Upgrade | 166 KB | BCP 47: `sr`(Cyrillic script)|
| Serbian(Latin)| Serbia(Srbija)| - | `awstats-sr-latn.po` | ✨ New | 122 KB | BCP 47: `sr-latn`(Latin transliteration variant of Cyrillic)|
| Sinhala | Sri Lanka(ශ්‍රී ලංකාව)| - | `awstats-si.po` | ✨ New | 212 KB | BCP 47: `si` |
| Slovak | Slovakia(Slovensko)| `awstats-sk.txt` | `awstats-sk.po` | 🔄 Format Upgrade | 126 KB | BCP 47: `sk` |
| Slovenian | Slovenia(Slovenija)| `awstats-si.txt` | `awstats-sl.po` | 🔄 Format Upgrade + Renamed | 124 KB | BCP 47: `sl`(original incorrect code `si` was country code for Slovenia → corrected to language code `sl`)|
| Tamil | India/Sri Lanka(தமிழ்)| - | `awstats-ta.po` | ✨ New | 236 KB | BCP 47: `ta` |
| Telugu | Telangana, India(తెలుగు)| - | `awstats-te.po` | ✨ New | 222 KB | BCP 47: `te` |
| Thai | Thailand(ประเทศไทย)| `awstats-th.txt` | `awstats-th.po` | 🔄 Format Upgrade | 202 KB | BCP 47: `th` |
| Tagalog | Philippines(Pilipinas)| `awstats-tg.txt` | `awstats-tl.po` | 🔄 Format Upgrade + Renamed | 130 KB | BCP 47: `tl`(original incorrect code `tg` was Tajik → corrected to `tl`)|
| Turkish | Turkey(Türkiye)| `awstats-tr.txt` | `awstats-tr.po` | 🔄 Format Upgrade | 127 KB | BCP 47: `tr` |
| Welsh | Wales, UK(Cymru)| `awstats-cy.txt` | `awstats-cy.po` | 🔄 Format Upgrade | 124 KB | BCP 47: `cy` |
| Ukrainian | Ukraine(Україна)| - | `awstats-uk.po` | ✨ New | 172 KB | BCP 47: `uk` |
| Uyghur | Xinjiang, China(شىنجاڭ)| - | `awstats-ug.po` | ✨ New | 176 KB | BCP 47: `ug` |
| Urdu | Pakistan(پاکستان)| - | `awstats-ur.po` | ✨ New | 158 KB | BCP 47: `ur` |
| Uzbek | Uzbekistan(Oʻzbekiston)| - | `awstats-uz.po` | ✨ New | 128 KB | BCP 47: `uz` |
| Spanish | Spain(España)| `awstats-es.txt` | `awstats-es.po` | 🔄 Format Upgrade | 130 KB | BCP 47: `es` |
| Hebrew | Israel(ישראל)| - | `awstats-he.po` | ✨ New | 140 KB | BCP 47: `he` |
| Greek | Greece(Ελλάδα)| `awstats-gr.txt` | `awstats-el.po` | 🔄 Format Upgrade + Renamed | 184 KB | BCP 47: `el`(original code `gr` was country code → corrected to language code `el`)|
| Hungarian | Hungary(Magyarország)| `awstats-hu.txt` | `awstats-hu.po` | 🔄 Format Upgrade | 130 KB | BCP 47: `hu` |
| Hindi | India(भारत)| - | `awstats-hi.po` | ✨ New | 204 KB | BCP 47: `hi` |
| Indonesian | Indonesia(Indonesia)| `awstats-id.txt` | `awstats-id.po` | 🔄 Format Upgrade | 122 KB | BCP 47: `id` |
| English | UK/USA(UK/USA)| `awstats-en.txt` | `awstats-en.po` | 🔄 Format Upgrade | 527 KB | BCP 47: `en` |
| Italian | Italy(Italia)| `awstats-it.txt` | `awstats-it.po` | 🔄 Format Upgrade | 128 KB | BCP 47: `it` |
| Vietnamese | Vietnam(Việt Nam)| `awstats-vi.txt` | `awstats-vi.po` | 🔄 Format Upgrade | 136 KB | BCP 47: `vi` |
| Simplified Chinese | China, Singapore, Malaysia(中国)<br>(including international organizations and global Chinese communities)| `awstats-cn.txt` | `awstats-zh-cn.po` | 🔄 Format Upgrade + Renamed | 519 KB | BCP 47: `zh-CN`(original code `cn` was country code → corrected to `zh-cn`)|
| Traditional Chinese | Taiwan, Hong Kong, Macau(臺灣)<br>and overseas traditional Chinese communities | `awstats-tw.txt` | `awstats-zh-tw.po` | 🔄 Format Upgrade + Renamed | 523 KB | BCP 47: `zh-TW`(original code `tw` was country code → corrected to `zh-tw`)|

- ♻️ **Developer Documentation Refactoring**: The original documentation was hardcoded in English HTML and has now been refactored into localized language documentation. The author, Laurent Destailleur, left behind a wealth of insightful documentation examples and feature descriptions, recording AWStats' development journey from 1997 to the present. Although some content may no longer be fully relevant to today's internet environment(such as outdated social plugins like Google+), it remains valuable reference material for development and an important part of AWStats' history. Due to the enormous workload, only the following languages have been fully translated for the documentation:

#### Full Localization(Interface + Documentation)
| Language | Code | Interface | Documentation |
|:---:|:---:|:---:|:---:|
| Simplified Chinese | zh-cn | ✅ | ✅ |
| Traditional Chinese | zh-tw | ✅ | ✅ |
| Russian | ru | ✅ | ✅ |
| Arabic | ar | ✅ | ✅ |
| Japanese | ja | ✅ | ✅ |
| French | fr | ✅ | ✅ |
| Dutch | nl | ✅ | ✅ |
| Korean | ko | ✅ | ✅ |
| Other Languages | - | ✅ | ❌ |

#### Partial Localization(Interface Only)

**The interface text for other languages has been fully translated, while the documentation content currently remains in the default English version.**

📌 **Note**: The example tables in this section(such as lifestyle habit comparisons, word formation logic, etc.)are **for illustrative purposes only**, intended to help explain our rationale for recommending Chinese as a translation reference. All suggestions are non-mandatory. Please feel free to choose based on **your own language habits and native language**.

If you would like to contribute a complete documentation translation for your language, you are welcome to do so in the following ways:

- 📝 Submit an [Issue](https://github.com/hestiacn/vstats/issues)to let us know your request
- 🔧 Submit a complete `.po` file to this repository(it will take effect after merging)
- **Translation Note**: The `.po` files were generated with the assistance of [DeepSeek](https://www.deepseek.com). If you find any inaccuracies, please submit a [Pull Request](https://github.com/hestiacn/vstats/pulls)to correct them! 💡 Suggestions and ideas are also welcome via Issues.

For translation accuracy, it is recommended to use `awstats-zh-cn.po` as your reference.

**Why is `awstats-en.po` not recommended?**

As the foundational language of computing, English expressions are often concise, direct, but completely unrelated. If you use it as a blueprint for secondary translation, you can easily lose the details, context, and nuance that the Chinese version adds, resulting in deviations in the final content.

The Chinese version not only preserves the original documentation but also adds extensive background context, making it a more ideal translation benchmark. Just as understanding Chinese logic makes translation more thorough, I also suggest you try changing a habit in your daily life — drink warm water regularly(starting with your first cup right after waking up in the morning)and give up cold water. This is not superstition, but rather 'a foundational wellness practice' validated by thousands of years of Eastern life practices.

Once you develop this habit, you will find that many minor colds may not even require a visit to the hospital, and can be self-repaired simply by drinking more warm water and getting enough rest. This not only improves your physical condition but also allows you to feel a deeper logical connection behind the words when handling localization work. 

| Basic Habits | Short-term Sensation(Latency)| Long-term Lifecycle(Lifecycle)|
|:---:|:---:|:---:|
| Cold/Iced Water | Fast thirst relief, refreshing taste | Stomach pain, bloating, indigestion, easy to get diarrhea, fatigue |
| Warm Water | Gentle sip, smooth and soft | Good digestion, stable metabolism, warm hands and feet, high energy |

**Why choose Chinese as the reference?**

Chinese is a language with strict logic and clear word formation. The relationships between words are often immediately obvious:

| Root | Derivatives | Logical Connection |
|:---:|:---:|:---:|
| 牛(cow/ox)| 牛肉(beef), 牛奶(milk), 牛皮(leather)| Animal → Meat/Dairy/Byproduct |
| 羊(sheep/goat)| 羊肉(mutton), 羊毛(wool), 羊皮(sheepskin)| Animal → Meat/Wool/Leather |
| 猪(pig)| 猪肉(pork), 猪油(lard), 猪皮(pigskin)| Animal → Meat/Fat/Byproduct |
| 鸡(chicken)| 鸡肉(chicken meat), 鸡蛋(egg), 鸡毛(feather)| Animal → Meat/Egg/Byproduct |
| 鱼(fish)| 鱼肉(fish meat), 鱼汤(fish soup), 鱼鳞(scale)| Animal → Meat/Soup/Byproduct |
| 葡萄(grape)| 葡萄酒(wine), 葡萄干(raisin), 葡萄园(vineyard)| Fruit → Beverage/Dried fruit/Place |
| 牛奶(milk)| 奶酪(cheese), 酸奶(yogurt), 黄油(butter)| Ingredient → Fermented/Processed |
| 火车(train)| 火车站(station), 火车票(ticket), 火车道(track)| Core word → Place/Certificate/Facility |
| 电(electricity)| 电脑(computer), 电视(TV), 电话(phone), 电梯(elevator)| Energy → Devices/Facilities |
| 水(water)| 水库(reservoir), 水杯(cup), 水龙头(faucet), 水坝(dam)| Substance → Container/Facility/Building |
| 书(book)| 书店(bookstore), 书架(bookshelf), 书签(bookmark), 书皮(cover)| Core word → Place/Item/Accessory |
| 学(study)| 学校(school), 学生(student), 学习(learning), 学费(tuition)| Action/Concept → Place/Person/Behavior/Cost |
| 您(formal "you")| 您的(your)| Honorific(elders/superiors)→ Possessive |
| 你(informal "you")| 你的(your)| Familiar(peers/juniors)→ Possessive |

---

## Additional Examples for English Speakers

To help illustrate the contrast with English, here are more examples:

| Chinese Base | Chinese Derived | Logic | English Problem |
|:---:|:---:|:---:|:---:|
| 农(farming)| 农民(farmer), 农业(agriculture), 农田(farmland)| Core → Person/Industry/Place | farm → farmer(adds -er), agriculture(different root)|
| 工(work)| 工人(worker), 工厂(factory), 工具(tool)| Core → Person/Place/Tool | work → worker(adds -er), factory(different root)|
| 车(vehicle)| 汽车(car), 火车(train), 自行车(bicycle)| Core → Types of vehicles | car/train/bicycle(completely different words)|
| 食(food)| 食物(food), 食堂(canteen), 食谱(recipe)| Core → Item/Place/Guide | food/canteen/recipe(different roots)|
| 酒(alcohol)| 啤酒(beer), 葡萄酒(wine), 白酒(liquor)| Core → Types of drinks | beer/wine/liquor(completely different words)|

---

## The Core Insight

> **Chinese: "I see the base word, I understand the derived words."**
> **English: "I see the base word, and I have no clue what the derived word is."**

| English Word | Comes From? | Relationship |
|:---:|:---:|:---:|
| beef | cow? | ❌ Different word |
| pork | pig? | ❌ Different word |
| mutton | sheep? | ❌ Different word |
| wine | grape? | ❌ Different word |
| agriculture | farming? | ❌ Different root |
| factory | work? | ❌ Different root |

---

This "infer the unknown from the known" word formation logic(seeing "sheep" and knowing roughly what "mutton/wool/sheepskin" would look like)makes Chinese an ideal reference benchmark for localization work — once you understand the base vocabulary, derived terms are often self-explanatory.

If you are interested in the Chinese language, feel free to explore it and its culture through films, music, books, cuisine, or travel. It may bring new inspiration and insights to your localization work.

Thank you for choosing the AWStats Community Enhanced Edition! 🎉

#### 🌐 Internationalization & Localization
- 🚀 Upgraded language files from GBK-encoded .txt to UTF-8 .po format based on gettext standard
- 🌍 New translations: Serbian Latin(sr-latn), Serbian Cyrillic(sr)
- 📄 Fully localized configuration file comments with detailed descriptions and examples
- 🔧 Optimized NotPageList configuration logic with UseDefaultNotPageList option

#### 🗺️ Geolocation
- 🌍 **DB-IP City-Level Geolocation Support**: AWStats now integrates with the DB-IP free geolocation database([https://db-ip.com](https://db-ip.com)). This enables precise visitor statistics at the country, region, and city levels. Note: The geolocation data(Country-Region-City)is displayed in English by default.
  - **Format Upgrade**: Upgraded from old `.dat`(GeoIP Legacy text)to `.mmdb`(MaxMind DB binary format)
  - **New Version Advantages**: 10x faster query speed, supports IPv4/IPv6 dual stack, monthly updates
- 📊 **Enhanced Geolocation Display**: Supports three-level location information with intelligent fallback
- 🚀 **Intelligent Caching Mechanism**: Uses `%TmpDomainLookup` and `%TmpDomainFullLocation` for caching
- 🔧 **Auto Plugin Enablement**: Automatically enables geoipfree plugin when no GeoIP plugin is loaded

#### 🔒 Security & Performance
- 🛡️ Added security response headers by default: X-Content-Type-Options, X-Frame-Options, Referrer-Policy
- 🛡️ **Comprehensive XSS Protection Enhancement**: `CleanXSS` now filters `javascript:` protocol and cleans event handlers, improves HTML special character escaping
- 🛡️ **URL Decoding Security Hardening**: `DecodeEncodedString` automatically calls `CleanXSS` after decoding
- 🛡️ **Input Filtering Strengthening**: `Sanitize` function adopts stricter whitelist strategy
- 🛡️ **UTF-8 Encoding Security**: `EncodeToPageCode` adds error trapping for graceful degradation
- 🛡️ **Configuration File Reading Standardization**: All file open operations uniformly specify UTF-8 encoding
- ⚡ Optimized DNS cache mechanism, reduced duplicate resolution
- 🔄 Improved try/catch exception handling for JSON log parsing
- 📡 Enhanced IPv6 and CloudFlare real IP header(CF-Connecting-IP)support

#### 📈 Statistical Feature Enhancements
- 🤖 Fixed robots.pm database inconsistency issue
- 🕷️ Added AI/ML crawler recognition: ClaudeBot, GPTBot, OAI-SearchBot, PerplexityBot, Applebot-Extended, Google-Extended, Amazonbot, Anthropic-ai, cohere-ai, AI2Bot, YouBot, etc.
- 📊 Optimized crawler classification for AI crawlers, social media crawlers, SEO tools, monitoring services
- 🔧 Removed duplicate robot rules(AhrefsBot, Exabot, XoviBot)
- 🎨 Added dedicated icons and descriptions for various crawlers
- 📈 Refactored download statistics module: supports resumable download(206 status code)recognition, mobile download statistics, intelligent distinction between streaming playback and download
- 📦 Externalized extension configuration for download files and streaming media
- 📱 Enhanced mobile device detection: added HarmonyOS, OpenHarmony recognition
- 📊 Internationalized data file comments with multilingual support
- 🗂️ Modernized NotPageList static resource list with modern formats(svg, webp, avif, woff2, etc.)
- 📊 Added detailed mime type descriptions for modern formats

#### 🛠️ Technical Improvements
- ⬆️ Raised minimum Perl version requirement from 5.007 to 5.20
- 🔧 Enabled `use warnings` and `use utf8`, unified UTF-8 encoding output
- 📚 Updated help information with practical examples
- 📋 Added version update history page `awstats_changelog.html`
- 🐛 Fixed compilation errors caused by undeclared variables `$lang` and `$dir_attr`
- 🔨 Fixed Try::Tiny syntax errors
- 📐 Independently control first column width of IP and robot list tables
- 🚪 Documentation viewer appears dynamically after clicking links, supports close button
- 🌏 Fixed language loading logic to correctly fallback to English in auto mode
- 🧹 Removed obsolete PrintCLIHelp, unified use of `print_help` function. Now you can trigger help using `awstats.pl -h`

### 8.0 - 2025-08-26
- 👋 *This is the last version maintained by the original developer(Laurent Destailleur)*
- 🔄 Improved CSS stylesheets
- 📋 Updated robots.pm database
- 🌍 Fixed #248
- 📖 Migrated Traditional Chinese translation to UTF-8 encoding
- 🌳 Sorting tree: check key existence regardless of value
- 📋 Added JSON log format support
- 🔧 Fixed NotPageList default settings
- 📋 Added request time reporting
- 📋 Fixed broken links in documentation
- 🗑️ Removed native Android and native iOS/OSX browser User Agents from robots.pm
- 🔧 Fixed GPTBot recognition error in robots.pm
- 🔧 Fixed encoding issues in Ukrainian translation

---

## 📦 7.x Series(2011-2023)

### 7.9 - 2023-01-17
- 🪟 Added Windows 11 and Android 13 OS detection
- 🇭🇺 Updated Hungarian translation and migrated to UTF-8
- 🛡️ Fixed cross-site scripting vulnerability(CVE-2020-35176)
- 🔧 Replaced hardcoded text with $Message variables(month, day, hour)
- 📱 Added Android 11/12, macOS 11/12 detection
- 🇩🇪 Updated German translation
- 🔄 Improved newline replacement logic, supporting both HTML and XHTML
- 🤖 Added new robots and mobile browsers, fixed errors in robots.pm
- 📂 Look for configuration only in dedicated awstats directory
- 📧 Handle SRS email addresses
- 🔒 Fixed #195/CVE-2020-35176
- 🌍 Fixed geoip2_country plugin issues
- 🖥️ Added HaikuOS and Safari-based WebPositive browser support
- 🔨 Added missing td tags
- 🇹🇯 Added Tajik language support

### 7.8 - 2020-04-30
- 🗄️ Added DatabaseBreak mode selection: month, day, hour
- 📋 Updated HTTP status codes
- 📁 Added more file types
- 📖 Updated README.md
- 🌍 Fixed geoip2 formatting issues
- 🔍 Fixed incorrect entries in search_engines.pm
- 🪟 Fixed geoip2 plugin on Windows
- 🤖 Updated robots.pm with new bots: PiplBot, um-IC/um-LN, arcemedia, bit.ly, bidswitchbot, bnf.fr_bot, contxbot, flamingo, getintent, laserlikebot, mappy, mojeek, serendeputy, trendiction, yak, zoominfobot
- 🔨 Fixed #104
- 📝 Improved Markdown readability
- 📅 Updated copyright year
- 🔒 Switched to https links
- 🔗 Fixed Perl download links
- ⏱️ Added %time6 tag for certain IIS log formats
- 📊 Fixed geoip2 table formatting errors
- 🍏 Added macOS DMG and PKG file support
- 🖥️ Fixed browser detection for HTTP 206 status codes
- 💻 Added macOS 10.13/10.14 support, improved icon compression
- 📈 Using top 5 as chart baseline
- 🧹 Cleaned up geoip2 and geoip2 city modules: proper DNS name conversion, public IP only queries, HTML escaped output, code improvements
- 🗜️ Lossless PNG compression(~33%)
- 🤖 Added robot: The Knowledge AI
- 🔄 Fixed RobotsSearchIDOrder_listx record count inconsistency
- ⚡ Optimized OptimizeArray function
- ⏰ Added UptimeRobot
- ⚙️ Fixed syntax errors in configuration files
- 📏 Ignored search phrases exceeding 80 characters
- 🔧 Fixed 404 details page not updating
- 🔤 Decoded RFC 3986 unreserved characters
- 🔨 Fixed #80
- ⚠️ Disabled nested include warnings for Perl > 5.6
- 🌐 Updated domains.pm
- 🔍 Fixed two invalid entries in search_engines.pm
- 💾 TB unit formatting
- ➗ Fixed division by zero error
- 🔨 Fixed #79
- 🛠️ Improved error handling in awstats_buildstaticpages.pl
- 🔨 Fixed #90
- 🚫 Excluded private IP addresses(GeoIP2::Reader unsupported)
- 🧹 Clear only saved section data
- 🏙️ Improved city plugin functionality
- 📊 Fixed ShowHost section issues
- 🌍 Initial GeoIP2 City query implementation
- 🇮🇱 Updated Hebrew language file
- 🔍 Improved Yahoo detection
- 📱 Added device pixel ratio to awstats_misc_tracker.js
- 🤖 Added 37 new robots based on 7.7 robots.pm
- 🔄 Moved oBot entry to avoid misidentification
- 🏁 Missing Sint Maarten flag
- 🌍 Fixed #76 - incorrect country names
- 📝 Fixed UTF BOM files
- 🛡️ Fixed vulnerabilities reported by cPanel security team
- 🧪 Added more tests

### 7.7 - 2018-01-07
- 🛡️ Security fix: CVE-2017-1000501
- 🔒 Security fix: Missing parameter sanitization
- 🔧 Fixed LogFormat=4 for URLs containing spaces
- 🪟 Fixed window.opener vulnerability for external referrer links
- 📝 Added methodurlprot log format definition
- 🔄 Added dynamic DNS lookup
- 🌐 Fixed Edge support

### 7.6 - 2016-12-07
- 🛡️ Security fix: DirLang parameter doesn't allow |
- 🔒 Security fix: Stricter AWSTATS_ENABLE_CONFIG_DIR usage rules
- 🤖 Updated robots database
- 💻 Fixed OS database
- 📚 Updated/fixed documentation
- 🏁 Added missing el country flag
- 📁 Partial support for pure-ftpd statistics format
- 🍏 Added macOS Sierra support
- 🔤 Added web fonts to default NotPageList, support for GPX and JSON files

### 7.5 - 2016-04-29
- 🐪 Perl 5.22 compatibility
- 🌐 Edge browser version detection support
- 🤖 Updated robots database
- 🔤 Added eot/woff/woff2 to mime.pm as fonts
- 🖼️ Added .svgz to image list
- 🚫 Excluded groups.google from search engines
- ⏱️ Added %time5 tag for ISO time format with timezone
- 🔄 Added DynamicDNSLookup option for DNS lookup at output time instead of during log analysis
- 📊 Increased MaxRowsInHTMLOutput default value

### 7.4 - 2015-11-11
- 🌍 Added geoip6 plugin supporting IPv4 and IPv6
- ☁️ Amazon AWS log file support(using %time5 tag)
- 🔧 Fixed permission issues in certain .pl scripts
- 🔨 Fixed #205: GetResolvedIP_ipv6 not removing trailing dot
- ⚠️ Fixed #496: Tool scripts should output warnings and errors to STDERR
- 🔗 Fixed #919: Referrers not being tracked
- 📝 Fixed #921: geoip_generator.pl help text error
- 🐛 Fixed #909: awstats_buildstaticpages.pl excessive debug output
- 💥 Fixed #680: Invalid data passed to Time::Local causing global destruction
- 🛡️ Fixed CVE-2006-2237

### 7.3 - 2015-11-11
- 📌 Added command line option -version
- 🌍 Improved error management in geoip modules
- 🗄️ Updated domains, robots, and search engines databases
- 📱 #877: AWStats supports Windows 8 and iOS
- 🪟 Detects IE11 and Windows 8.1
- 🔗 Fixed static linking error when using builddate option
- 🌐 Restored Opera browser version detection
- 🏙️ #838: GeoIP Cities page not working
- 🖼️ Added missing icons
- 🔒 #881: Avoid http/https mixed warnings in graphgooglechartapi module
- 🔧 #918: Use $MinHit{'Host'} instead of $MinHit{'Login'} in HTMLShowLogins
- 📦 Migrated version system to SourceForge Git

### 7.2 - 2013-07-09
- ⚖️ License upgraded to GPL v3+
- 📚 Documentation updated
- ☁️ modCloudFlareIIS support
- 🖥️ Fixed layout issue for Webmin 1.53
- 🔗 Updated broken links to maxmind

### 7.1.1 - 2013-03-08
- 🪟 Added Windows 8 detection
- ⏱️ Support for ISO date time with %time5
- 🐪 Fixed Perl 5.14 issues

### 7.1 - 2012-12-20
- 🌍 Updated translations
- 🌐 Updated browser list
- 🔧 Added nginx configuration example
- 📦 Added some Debian package patches
- 📛 Documentation domain renamed to awstats.org
- 🔑 awredir.pl can be used without md5 key parameter
- 📊 awstats_buildstaticpages.pl supports databasebreak option
- 🔗 Added rel=nofollow links
- 🧩 Added AddLinkToExternalCGIWrapper option
- 🛡️ Fixed security issue in awredir.pl
- 🇬🇧 Fixed uk case issue in googlechart api
- 🐪 Fixed compatibility with latest Perl versions

### 7.0 - 2011-01-08
- 🪟 Windows 7 detection
- 🔢 Number formatting according to language
- 📁 More MIME types
- 🌍 Added geoip_asn_maxmind plugin
- 🗺️ GeoIP Maxmind city plugin supports overlay files
- 📊 Added graphgooglechartapi using online Google Chart API for graphs
- 🗺️ Country map display capability
- 🧹 Code cleanup and optimization
- 🚫 Added parameter to ignore missing log files
- 🤖 Updated robots database
- 📥 Added download tracking feature
- 🧩 WrapperScript parameter supports wrappers with arguments
- 🏢 AWStats usage in Dolibarr ERP/CRM plugin
- 🖥️ Fixed Webmin module compatibility with newer versions
- 🛡️ Security fix(LoadPlugin directory traversal)
- 🔒 Security fix(Restricted config directory access)

---

## ⚙️ 6.x Series(2004-2009)

### 6.95 - 2009-10-28
- 🛡️ Fixed awredir.pl security issue, added security key by default
- 🧹 Enhanced parameter sanitization
- 📋 Added configuration filename in data file header
- 🌐 Added version details for Chrome, Opera, Safari, Konqueror browsers
- 📱 Added AdobeAir detection
- 🤖 Major updates to browser, robot, and search engine databases(including Bing)
- 🔍 Significantly improved robot detection
- 🇫🇷 Added Breton language
- 🖥️ Improved Safari version detection
- 🗺️ Added subpages for geoip maxmind modules
- 🇵🇱 Fixed typos in Polish language file
- ⚠️ Fixed warnings in geoipfree
- 🔧 Fixed robot detection issues

### 6.9 - 2008-12-28
- 📧 maillogconvert.pl supports DSN, avoids duplicate counting
- 📊 logresolvemerge.pl supports FreeRADIUS logs
- 🛑 Added stoponfirsteof option
- 🔄 Added host_proxy tag support
- ⭐ Renamed to "Add to favourites"
- 🤖 Updated robot and search engine databases(added Chrome, improved Vista, WII detection, etc.)
- 🌍 Updated language files
- 🗺️ Fixed maxmind city, org, and isp plugins
- 🛡️ Fixed multiple security issues
- 🖼️ Added missing icons
- 🐪 *Requires Perl 5.007 or higher*

### 6.8 - 2008-07-20
- 👥 Added OnlyUsers option
- 📡 RPC request tracking support
- 📝 HTMLHeadSection supports newlines
- 🤖 Added MetaRobot option
- 🔍 Significantly improved robot detection
- 🪟 Improved Windows OS detection
- ➕ Added HOSTINLOG condition in extra sections
- 📄 Fixed XML output issues
- 🐛 Fixed bugs in awstats_configure.pl script

### 6.7 - 2007-07-07
- 📅 Full -day option support, building different reports for each day
- 🏷️ Added virtualenamequot tag
- 🚫 Added NotPageList option
- 🌐 Added .jobs and .mobi domains
- 🐛 Fixed minor bugs in awstats_configure.pl
- 🌍 Updated language files
- 🌐 Updated browser database

### 6.6 - 2006-12-24
- 🐪 All geoip plugins support PurePerl version
- ➕ vhost support in extra sections
- 🌐 AllowAccessFromWebToFollowingIPAddresses parameter supports IPv6
- 🗂️ Added svn series to browser detection
- 🌍 IE7 support
- 🔇 Removed some Perl warnings
- 🛡️ Fixed XSS attack vulnerabilities
- 🌏 Updated language files
- 🌐 Updated browser database

### 6.5 - 2005-12-24
- ⚡ 30x speed improvement when merging large log files with logresolvemerge.pl
- 🐧 Added Linux and BSD distribution detection
- 🚫 Added SkipReferrersBlackList option to exclude spam referrers
- 📰 Added RSS feed aggregators/readers to robot database
- 🗄️ Added databasebreak option
- 🗺️ geoip_cities plugin reports region when data available
- 📱 LevelForBrowsersDetection accepts allphones value
- 🔄 LogFormat=2 can dynamically detect log format changes
- 📋 Added SectionsToBeSaved option
- 🌐 Added Epiphany browser detection
- 🔗 awredir supports ftp, https, and other protocols
- 📧 Fixed Gmail click counting issues
- 🔨 Fixed multiple bugs and XSS issues
- 🛡️ Fixed XSS issues

### 6.4 - 2005-02-25
- 📊 Added ShowSummary option
- 🌍 Added column in host report when GeoIP plugin enabled
- 🔄 LogFormat=2 auto-detects log format changes
- 🔓 Fixed security vulnerability(log file content reading possible)
- 🛡️ Fixed potential DoS attack vulnerability
- 🎥 Fixed media server analysis errors
- 🪟 Fixed configdir option issues on Windows servers
- 🏁 Added missing Basque flag icon

### 6.3 - 2005-02-25
- 🌍 Added geoip_isp_maxmind and geoip_org_maxmind plugins
- 🦊 Display Firefox version details
- 🔍 Support for detecting search engines storing keywords in URLs
- 🔓 Removed two security vulnerabilities
- 🗺️ Fixed geoip_city_maxmind plugin issues
- 📁 Fixed file type table display
- 🌐 Fixed corrupted translation entries
- 📄 Fixed XML parsing errors

### 6.2 - 2004-11-06
- ⚙️ Added -excludeconf option to awstats_updateall.pl
- ➕ Allow plugins to add entries in menu
- 🔄 Allow plugins to compile data during update process
- 🗺️ Added geoip_region_maxmind and geoip_city_maxmind plugins
- 📧 maillogconvert.pl supports postfix 2.1
- ⚡ Minor speed improvement
- 🚫 Statistics for browsers with JavaScript disabled
- 🏷️ Support for %extraX tags in log format
- 📁 PUT method support when analyzing FTP logs
- 🔨 Fixed multiple bugs

### 6.1 - 2004-05-15
- 📄 BuildHistoryFormat supports XML format
- ⏱️ Added %time4 tag for Unix timestamp support
- 🦊 Added Firefox to browser database
- 🔗 Added IncludeInternalLinksInOriginSection parameter
- 📑 PDF detection supports PDF 6
- 📧 maillogconvert.pl auto-adjusts year
- 💡 Added tooltips for mail reports
- ❌ Added failed mail count in summary
- 🔤 AllowAccessFromWebToFollowingAuthenticatedUsers no longer case sensitive
- 🌐 Added Camino browser detection
- 🔨 Fixed multiple bugs

### 6.0 - 2004-01-25
- ⚡ 10-20% speed improvement
- 🐛 Added worm reports
- 📄 XML output support
- 🔤 Added decodeUTFkeys plugin
- ⚙️ Added configure.pl script
- 🔄 Code rewrite for better understanding and maintenance
- 🔍 New search engine database supporting multiple match IDs
- ➕ Support for UA and HOST fields in ExtraSection
- 🔁 Support for right-to-left languages
- 📊 Added file type percentage column
- 🔨 Fixed multiple bugs

---

## 🔧 5.x Series(2002-2003)

### 5.9 - 2003-09-22
- 🖥️ Webmin module updated to 1.1
- 📅 Added AllowFullYearView parameter
- 🌍 Year entries display localized text in combo box
- 📧 maillogconvert.pl supports some exchange formats
- ⚙️ awstats_buildstaticpages.pl -noloadplugin option accepts comma-separated list
- 📨 Error logging support for qmail logs
- 🔨 Fixed multiple bugs

### 5.8 - 2003-09-16
- 🔧 Fixed mod_deflate compressed reports
- 📊 Fixed column count error for "others" row in host chart
- 🔍 Fixed parsing issues with uabracket and refererquot
- 🖥️ Added Webmin module
- ➕ Enhanced Extra functionality with ExtraSectionFirstColumnFormatX parameters
- 🏷️ Added %lognamequot tag
- 👥 Added OnlyUserAgents parameter
- 🛠️ Added awredir.pl tool
- 📊 Added cluster reports

### 5.7 - 2003-08-23
- 📝 Added rawlog plugin
- 🔍 Added dynamic exclusion filters in full list report pages
- 📧 Added maillogconvert.pl for mail log analysis
- ➕ Added -addfilenum option to logresolvemerge.pl
- ⏱️ Added -updatefor option to limit rows per update
- 🎥 Darwin streaming server support
- 🔥 Added Firebird browser detection
- 📄 awstats_buildstaticpages.pl can build PDF files
- ⚙️ Improved plugin loading failure handling
- 🏷️ Added LogType parameter

### 5.6 - 2003-06-28
- 🗜️ mod_deflate compressed report support
- 🌐 Improved browser detection
- 🔣 Regex values support for list parameters
- 🎨 StyleSheet parameter fully effective
- 🤖 Added meta tag robots noindex,nofollow
- 📊 Added misc charts reporting browser support for Java, Flash, Real, QuickTime, WMA, PDF
- ⚡ Improved update process, faster
- 🦊 Improved display on Netscape/Mozilla browsers

### 5.5 - 2003-05-25
- 📱 Added screen size reports
- 💻 OS grouping by family with detailed version charts
- 🔍 Improved 404 error management
- 🌍 Added geoipfree plugin
- 👤 Added userinfo plugin
- 📅 Month parameter accepts -month=D format
- ⚡ Optimized code size and HTML output
- 🌐 Added ipv6 plugin
- 📊 Split month summary and month days charts into two independent charts
- 🔗 Added -staticlinksext option
- 📧 QMail support

### 5.4 - 2003-02-23
- 🌍 Lang parameter accepts auto value
- 🎥 Partial realmedia server support
- 🛠️ Added urlaliasbuilder.pl tool
- 🔗 ExtraSection first column supports URLs
- #️⃣ Added URLWithAnchor parameter
- 💡 Tooltip functionality exported as plugin
- ⏱️ Added average time and percentage in visit duration report
- 📦 logresolvemerge.pl can read .gz or .bz2 files
- 📁 Added icons and MIME labels for file type report
- ➕ Added multiple data array parameters
- 🪟 Whois info displayed in centered popup window
- 🎨 Improved browser report appearance

### 5.3 - 2003-01-02
- 📤 Added awstats_exportlib.pl tool
- 🌍 Added full list view for domain/country reports
- 📧 Added full list and last view for mail senders/receivers charts
- ⚡ Added memory cache for GeoIP plugin
- 🔤 Added AuthenticatedUsersNotCaseSensitive parameter
- 🚀 Speed improvement when using ExtraSection
- 🔄 Updated robot, OS, browser, search engine databases
- 🖥️ Added X11 as unknown Unix OS, added Atari OS

### 5.2 - 2002-12-03
- 🔗 Added urlalias plugin
- 🌍 Added geoip plugin
- 📧 postfix mail log support
- 📊 Added total and average rows at bottom of date data arrays
- 🔍 Added dynamic filters in host and referrer pages
- 🚫 Removed Bytes text when value is 0
- 📦 Reduced home page size
- 👥 Added OnlyHosts parameter
- ⚠️ Added ErrorMessages parameter
- 🐛 Added DebugMessages parameter
- 🔣 Added URLQuerySeparators parameter
- 🔒 Added UseHTTPSLinkForUrl parameter
- 🇦🇱 Added Albanian language
- 🇧🇬 Added Bulgarian language
- 🏴󠁧󠁢󠁷󠁬󠁳󠁿 Added Welsh language
- 🇸🇨 Added Seychelles flag

### 5.1 - 2002-10-26
- 📁 Improved FTP log file support
- 📧 Improved mail log file support
- 🎥 Streaming media log analysis(Windows Media Server)
- 📅 Added month and year selection boxes in CGI mode
- 📊 Month and day data values displayed directly below home page charts
- 🔧 ShowxxxStats parameters accept codes to determine displayed columns
- 🚫 Added SkipUserAgents parameter
- 🔤 Added URLNotCaseSensitive parameter
- 🔗 Added URLWithQueryWithoutFollowingParameters parameter
- 🔄 Added URLReferrerWithquery parameter
- 🏷️ Added multiple date tags
- 🛡️ Fixed analysis halt when log files contain binary characters

### 5.0 - 2002-10-06
- 🔄 Complete rewrite of update process and history file read/write code
- 🔄 Compatible with previous versions(3.x or 4.x)
- ⚡ Old history files can be migrated with -migrate command for speed improvement
- 🔧 Fixed errors when using different offset tags
- 🔐 CreateDataDirIfNotExists directory permissions changed from 0666 to 0766
- 🌐 Track detailed browser major/minor versions
- 🤖 Added bandwidth reports for robots and errors
- 📦 DNS cache file support for DNS lookups
- 🧩 Added plugin support and multiple working plugins
- 🖼️ Frame report usage(UseFramesWhenCGI parameter)
- 📉 Reduced global variable count
- 📄 DefaultFile parameter accepts multiple values
- 🤖 Added all robots and last robots full list reports
- 👤 Added all logins and last logins full list reports
- 🚪 Added URL entry and exit full list reports
- 🛡️ Added AllowAccessFromWebToFollowingIPAddresses parameter
- 🔣 Added LogSeparator parameter
- 🔒 Added EnableLockForUpdate parameter
- 🔤 Added DecodeUA parameter
- 🏷️ Added %WY tag

---

## 📊 4.x Series(2002)

### 4.1 - 2002-07-09
- ⌨️ -logfile option usable anywhere in command line, supports spaces in filenames
- 🧠 Fixed memory leak in logresolvemerge.pl
- 📉 Reduced discarded records for non-fully sorted log files
- 🏷️ Added %virtualname tag for sharing same log file across multiple virtual servers
- 🔧 Pipe support in LogFile parameter
- 🔗 Added full list of referrer search engines and referrer pages
- 🔍 Simultaneous keyword and keyphrase reporting
- 🚪 Exit page reporting
- ⏱️ Visit duration reporting
- 📁 Added -dir option to awstats_buildstaticpages.pl

### 4.0 - 2002-04-21
- ⚠️ *Warning: Incompatible with old history files*
- ⚡ Speed improvement, reduced memory usage for large sites
- 🌐 Unresolved IPs now handled like resolved ones
- 🖼️ Added icons in browser charts
- 📋 Custom log formats also support tab delimiters
- 🔒 New security/privacy management methods and parameters
- 🤖 Crawler browsers marked in browser charts
- 📊 Added average file size in page/URL report charts
- ⚙️ Dynamic environment variables usable in configuration files
- 📝 Full keyphrase list viewing
- 🧩 Added WrapperScript parameter
- 📁 Added CreateDirDataIfNotExists parameter
- ✅ Added ValidHTTPCodes parameter
- 📏 Added MaxRowsInHTMLOutput parameter
- 🔗 Added ShowLinksToWhoIs parameter
- 🔗 Added LinksToWhoIs parameter
- 🎨 Added StyleSheet parameter
- 🔗 Added -staticlinks option
- 🛠️ Added common2combined.pl tool
- 🛠️ Added awstats_buildstaticpages.pl tool

---

## 🎨 3.x Series(2001)

### 3.2 - 2001-12-29
- ⚡ 19% speed improvement
- 🔧 Fixed history file corruption issues
- 🛡️ Security fix: Cannot update via URL when AllowToUpdateStatsFromBrowser is off
- 🏷️ Added various tags for dynamic log filenames
- 🚫 Added NotPageList parameter
- 💾 Added KeepBackupOfHistoricFiles option
- 📊 Visit counts visible in day statistics
- 📅 Added day of week statistics
- 📁 Added file type statistics
- 🚪 Added entry page statistics
- 🗜️ Added web compression statistics(mod_gzip)
- 👤 Added authenticated user/login statistics
- 📋 Added parameter to select displayed reports on home page
- 🔗 Added URLWithQuery option
- 🏁 ShowFlagLinks accepts all required flags list
- 🖥️ Standard ISA server log format support
- 🛠️ Added logresolvemerge tool
- 📝 Added HTMLHeadSection parameter
- 🔢 Added NbOfLinesForCorruptedLog parameter

### 3.1 - 2001-09
- ⚡ Significantly improved update speed
- ⚡ Significantly improved statistics viewing speed
- 🧠 Reduced memory usage
- 📂 AWStats searches configuration files in multiple directories
- 📄 NCSA common log file analysis
- 🕒 Last visit lists
- 📊 Full URL score lists
- 📅 Date format selectable by country
- 🌍 Added DirLang parameter
- ⏱️ Added Expires parameter
- 🔗 Added LogoLink parameter
- 🎨 Added color_weekend option
- ⚙️ Added -update and -output options
- 🔍 Added -showsteps option
- 🔧 Fixed OS detection
- 📱 Added WAP browsers to database

### 3.0 - 2001-07-22
- 🎨 New look and feel
- 📅 Added daily page, hit, and byte reports
- 🔄 AWStats can use its own conversion array for reverse DNS lookups
- 🚫 Added SkipDNSLookupFor option
- 📁 Added OnlyFiles option
- 📋 Custom log format support
- ⚡ Default: no update while viewing stats in browser, added immediate update button
- 💡 Tooltips now work in Netscape 6, Opera, etc.
- 🌐 Updated browser database, added audio browsers
- 💻 Updated OS database
- 🤖 Updated robot database
- 🌍 Support for new domains
- 🏁 Added missing flag icons
- 🔧 Rewrote UnescapeURL function
- 📊 Auto-scaling bytes
- 🎨 Fixed style issues
- 🌐 Added new languages

---

## 🔄 2.x Series(2001)

### 2.24 - 2001-03-09
- ⏱️ Dynamic year/month/day/hour inclusion in LogFile parameter
- ⌨️ Month, year, and language selection from command line
- 🔒 https requests correctly reported
- ⚙️ Parameter initialization to avoid mod_perl caching issues
- 🛡️ Fixed parameter checking to avoid XSS attacks
- 🏁 Added multiple country flags
- 🔍 New keyword detection algorithm
- 📝 Added option to report keywords as individual words or full search strings
- 🇬🇷 Added Greek language
- 🇨🇿 Added Czech language
- 🇵🇹 Added Portuguese translation
- ⚡ Faster configuration file parsing
- 🪟 Distinguish between Windows NT and Windows 2000
- 🌐 Added OmniWeb and iCab browsers

### 2.23 - 2001-02-10
- ⚙️ Configuration file usage
- 📁 Old log file processing capability
- 📅 Monthly statistics now working correctly
- 📅 Old years viewable from AWStats report page
- 📂 Working directory selection
- 🗑️ Added PurgeLogFile option
- 📝 awstats.pl can be renamed to awstats.plx and still work
- 🔗 Command-line generated statistics pages have correct links
- 📅 Added links for full year view selection
- 📊 Domain and page reports sorted by pages
- 🔄 Auto-disable completed DNS lookups
- ➕ Custom HTML code can be added at end of awstats
- 🇮🇹 Added Italian language
- 🇩🇪 Added German language
- 🇵🇱 Added Polish language

### 2.1 - 2001-01-01
- 🔄 AWStats treats myserver and www.myserver as identical
- 🔧 Fixed excessively high unique visitor counter
- 📦 Added ArchiveLog parameter
- ❓ Distinguish between unknown browsers and unknown OS
- 🤖 Robot statistics separated from visitors
- 🔍 Improved keyword detection algorithm
- 🕒 Added last connection time per host
- 📋 Added URL list for HTTP 404 errors
- 📊 Added page, hit, and KB statistics
- 🎨 Added colors and links
- 🪟 IIS support
- ⚡ Cleaner, faster code
- 🖼️ Images in .png format
- 🌐 4 languages

---

## 🌟 1.x Series(2000)

### 1.0 - 2000-05-02
- 🎉 First public release on SourceForge(version 1.0)
- 📄 Apache log format support
- 📊 Basic statistics: visits, pages, files

---

## 📜 Early Development Stage(1995-1999)

### 1999 - Pre-open source
- 🚀 Standardized architecture, introduced lang/ dictionary system(initially established GBK/ISO encoding specifications)to adapt to different server environments, final transformation from personal tool to standardized product
- 🔍 Enhanced recognition: Significantly expanded crawler recognition library
- 🎯 Mode fixation: Improved CGI script runtime mode
- 👥 Community testing: Conducted tests among peers, completed code cleanup and documentation based on feedback

### 1998 - Feature Deepening
- ⚙️ High-frequency internal private iterations
- 🔄 Established "incremental update" architecture, introduced intermediate database files to ensure statistics don't consume server real-time resources under big data
- 💻 Added OS, browser type, and HTTP status code recognition capabilities
- 🔌 Leveraged Perl cross-platform capabilities, tested Unix/Linux and Windows environment compatibility

### 1997 - Project Inception
- 🌟 Official documentation recognized starting point, transformation from scattered scripts to analysis engine
- 📊 Established static report generation mode, first output analysis results as HTML pages with graphical interface
- 🔍 Began building search engine and robot recognition rule libraries
- 📈 Benefited from Common Log Format standardization, scripts began to have generalization foundation

### 1995-1996 - Concept Germination
- 💡 Responded to access.log analysis needs after Apache HTTP Server became popular
- 🧪 No formal project name yet, experimental code snippets by author Laurent Destailleur
- 🐪 Written based on Perl 5, using complex hash structures for basic regex matching, used for total hits and simple file type filtering
- 📊 Only used for internal traffic monitoring on author's personal website(cdr)
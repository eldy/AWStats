# AWStats 8.1 - أداة إحصاءات الويب المتقدمة (إصدار المجتمع)

<p align="center">
  <img src="docs/images/screenshot.png" alt="معاينة لوحة تحكم AWStats" width="800">
</p>

<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html#license-text"><img src="https://img.shields.io/badge/رخصة-GPL%20v3-blue.svg" alt="الرخصة"></a>
  <a href="https://www.perl.org/"><img src="https://img.shields.io/badge/Perl-5.20%2B-brightgreen.svg" alt="إصدار Perl"></a>
  <br><br>
  <a href="https://github.com/hestiacn/vstats/releases/latest"><img src="https://img.shields.io/github/v/release/hestiacn/vstats?style=for-the-badge&logo=github&label=آخر%20إصدار&color=blue" alt="آخر إصدار"></a>
  <br><br>
  <a href="docs/CHANGELOG-zh_CN.md"><img src="https://img.shields.io/badge/📝_سجل_التغييرات-النسخة_العربية-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="سجل التغييرات"></a>
  <br><br>
  <a href="docs/CHANGELOG.md"><img src="https://img.shields.io/badge/📝_Changelog-English_Version-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="سجل التغييرات"></a>
</p>

> **🎉 هذا هو أول إصدار مجتمعي رئيسي لـ vstats!** إعادة هيكلة كاملة لـ `AWStats` الأسطوري (1997-2025). قمنا بإزالة الغبار عنه وجعلناه متجددًا لمواجهة تحديات الـ 25 عامًا القادمة!

تم أرشفة `AWStats` الأصلي في نوفمبر 2025 بعد 25 عامًا من الصيانة. هذا المشروع هو إعادة هيكلة كاملة وتحسين وظيفي للأصلي، يتم صيانته بواسطة مجتمع [hestiacn](https://github.com/hestiacn/vstats).

---

## 🚀 أبرز ميزات الإصدار

### 1. دعم UTF-8 الأصلي (وداعًا لمشاكل الترميز)

قل وداعًا لمشاكل الترميز المزعجة! جميع المنطق الداخلي والمخرجات تستخدم الآن ترميز UTF-8 بالكامل. يتم الآن عرض العربية والصينية واليابانية والأحرف الخاصة الأخرى بشكل مثالي.

### 2. التوطين العالمي (73 لغة)

- تحويل نظام الترجمة بالكامل من الفهارس الرقمية إلى المفاتيح الدلالية (`_t('key')`)
- إضافة/تحديث 73 لغة (بما في ذلك القبرصية والبرتغالية البرازيلية وغيرها)
- إضافة أوصاف فكاهية فريدة لإحصائيات الـ 24 ساعة - مفاجأة صغيرة لمسؤولي الأنظمة الذين يعملون في الساعة 4 صباحًا! ☕️

### 3. واجهة مستخدم حديثة وتصميم متجاوب

- **الوضع الداكن/الفاتح**: تبديل السمة بنقرة واحدة
- **رسوم بيانية بـ CSS الخالص**: استبدال صور PNG القديمة برسوم بيانية CSS حديثة تدعم `border-radius`
- **دمج الرموز التعبيرية**: استخدام الرموز التعبيرية لتصور البيانات لتجربة بصرية حديثة

### 4. تحسينات الأداء والكود

- تنظيف كبير لكود Perl لتحسين الأداء في بيئات CGI الحديثة
- تحسين اكتشاف المتصفحات والروبوتات الحديثة (أحدث قواعد 2026)

### 5. دعم التقويمات المتعددة و 13 شهرًا 🗓️

دعم **13 نوعًا من التقويمات** (بما في ذلك التقويم الإثيوبي والتقويم العبري ذي **13 شهرًا**)، مع المطابقة التلقائية للغة الموقع.

> 📌 **التقويم الإثيوبي**: الأشهر الـ 12 الأولى كل منها 30 يومًا، الشهر الـ 13 به 6 أيام في السنة الكبيسة و 5 أيام في السنة العادية.
> 📌 **التقويم العبري**: 7 سنوات كبيسة في دورة 19 عامًا، في السنوات الكبيسة يضاف آدار الأول (30 يومًا) مكونًا 13 شهرًا.

### 6. عرض علامة تجارية مخصصة 🏷️

> **لمقدمي الاستضافة والمستخدمين من الشركات**

يمكنك الآن عرض معلومات العلامة التجارية المخصصة (**شعار** و **اسم العلامة التجارية**) في أعلى صفحة `AWStats`.

**الميزات**:
- 📍 تظهر منطقة العلامة التجارية تلقائيًا فقط عند وجود ملف `/stats/logo.svg`
- 🔗 دعم رابط مخصص للعلامة التجارية (النقر على الشعار للانتقال)
- 🏷️ دعم أي اسم علامة تجارية (يوصى باستخدام الاسم الإنجليزي للتوافق مع البيئات متعددة اللغات)، مع تنسيق تلقائي كـ **`اسم العلامة التجارية + " لوحة إدارة الخادم"`**

**أمثلة على سيناريوهات الاستخدام**:
| النوع | أمثلة |
|:---:|:---:|
| 🐧 توزيعات لينكس | `RHEL`, `Debian`, `Ubuntu`, `CentOS`, `Arch Linux`, `Fedora`, `Rocky Linux` |
| 🖥️ أنظمة التشغيل | `macOS`, `Windows`, `FreeBSD` |
| ☁️ مزودو الاستضافة السحابية | `Aliyun`, `Tencent`, `AWS`, `Azure`, `Google Cloud` |

**مثال التكوين**:
```perl
# أضف في ملف تكوين AWStats
BrandLink="https://example.com"      # رابط الانتقال عند النقر على الشعار
BrandPlatform="Ubuntu"               # اسم العلامة التجارية (يعرض "Ubuntu لوحة إدارة الخادم")
StatsUrl="/vstats"                   # دليل نشر AWStats
```

> **ملاحظة**: تظهر منطقة العلامة التجارية فقط عند وجود ملف `logo.svg`. إذا لم يتم تكوين `BrandLink`، سيتم استخدام القيمة الافتراضية `https://hestiacp.com`.

---

## 📦 التحميل والتثبيت

احصل على أحدث إصدار عبر الروابط أدناه:

| النظام/الصيغة | رابط التحميل |
|:---:|:---:|
| **Debian/Ubuntu** | [![تحميل .deb](https://img.shields.io/badge/تحميل-.deb_حزمة-2ea44f?logo=debian&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb) |
| **RHEL/CentOS/Fedora** | [![تحميل .rpm](https://img.shields.io/badge/تحميل-.rpm_حزمة-2ea44f?logo=fedora&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm) |
| **الكود المصدري (tar.gz)** | [![تحميل .tar.gz](https://img.shields.io/badge/تحميل-.tar.gz-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.tar.gz) |
| **الكود المصدري (zip)** | [![تحميل .zip](https://img.shields.io/badge/تحميل-.zip-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.zip) |
| **Windows** | [![تحميل Windows](https://img.shields.io/badge/تحميل-نسخة_Windows-2ea44f?logo=windows&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-utf8.exe) |

> **ملاحظة حول بيئة Windows**: تحتوي نسخة Windows فقط على مثبت EXE، ولم يتم اختبار بنية الدليل والمسارات. إذا واجهت مشاكل أثناء الاستخدام، يرجى تقديم Issue أو Pull Request للمساعدة في الإصلاح.

---

## 📊 مقارنة مع النسخة الأصلية

| الميزة | AWStats الأصلي | النسخة المعاد هيكلتها |
|:---:|:---:|:---:|
| الترميز | GBK / ترميز جزئي | **دعم كامل لـ UTF-8** |
| طريقة الترجمة | فهارس رقمية `$Message[169]` | **مفاتيح دلالية `_t('key')`** |
| نمط الواجهة | نمط ثابت | **تبديل السمات الفاتحة/الداكنة + تصميم متجاوب** |
| الأعلام | صور PNG | **رموز تعبيرية** |
| الرسوم البيانية | صور PNG | **رسوم بيانية بـ CSS الخالص** |
| دعم التقويم | التقويم الميلادي | **12 تقويمًا** |
| حالة الصيانة | مؤرشف | **صيانة مستمرة** |

---

## ✨ قائمة كاملة بالميزات

| الفئة | الميزة |
|:---:|:---:|
| 🌐 الوصول متعدد اللغات عبر CGI | واجهة بـ `73` لغة، كشف تلقائي بواسطة المتصفح. تتيح للزوار من جميع أنحاء العالم عرض التقارير بلغتهم الأم! [عرض قائمة اللغات المدعومة بالتفصيل](docs/CHANGELOG.md#-language-support) |
| 🗓️ دعم التقويمات المتعددة | **13 نوعًا من التقويمات** (بما في ذلك التقويم الإثيوبي ذي الـ 13 شهرًا)، تطابق تلقائي مع لغة الموقع |
| 📊 إحصاءات الزيارات | زوار فريدون، عدد الزيارات، مدة الزيارة، تتبع المستخدمين المصادقين |
| 🌍 الموقع الجغرافي | قاعدة بيانات `DB-IP` المجانية، تحديد الموقع بثلاثة مستويات (دولة/منطقة/مدينة)، دعم IPv4/IPv6 |
| 💻 معلومات العميل | المتصفح، نظام التشغيل، دقة الشاشة، نوع الجهاز (سطح المكتب/الجوال) |
| 🤖 كشف الزواحف | `500+` زاحف محركات البحث، زواحف الذكاء الاصطناعي/التعلم الآلي (ClaudeBot، GPTBot وغيرها) |
| 📁 إحصاءات الملفات | أنواع الملفات، التنزيلات (قابلة للاستئناف)، الضغط (mod_gzip/mod_deflate) |
| ⚠️ تحليل الأخطاء | أخطاء `HTTP` (404 وغيرها)، مصدر الأخطاء، وصف محلي لرموز حالة كشف هجمات الديدان |
| 🎨 واجهة حديثة | تصميم متجاوب، سمة داكنة/فاتحة، رسوم بيانية بـ CSS الخالص، أيقونات أعلام بالرموز التعبيرية |

---

## 📋 متطلبات النظام

### المتطلبات الأساسية
- ✅ القدرة على الوصول إلى ملفات سجل الخادم المراد تحليلها (ويب/FTP/بريد)
- ✅ إصدار 5.20 أو أعلى (يوصى بـ 5.32+)
- ✅ بيئة سطر الأوامر و/أو CGI

### أنظمة التشغيل المدعومة
- 🐧 Linux/Unix (Ubuntu، Debian، CentOS، RHEL، إلخ)
- 🪟 Windows (Windows 10/11، Windows Server)
- 🍎 macOS
- 🔵 FreeBSD، OpenBSD

### الخوادم المدعومة
- 🌐 الويب: Apache، Nginx، IIS، Caddy، Lighttpd
- 📁 FTP: ProFTPd، vsFTPd، Pure-FTPd
- 📧 البريد: Postfix، Sendmail، QMail، Exim
- 🎥 البث المباشر: RealMedia، Windows Media Server

---

## **أصلاح توافق إصدار AWStats Geo/IPfree.pm**

إذا واجهت الخطأ التالي عند تشغيل تحديث AWStats:
```
Error: Perl v5.200.0 required (did you mean v5.20.0?)--this is only v5.36.0
```

هذا لأن فحص الإصدار في ملف `Geo/IPfree.pm` غير متوافق مع إصدار Perl الحالي في النظام.

### **أمر الإصلاح التلقائي**
```bash
find /usr -name "IPfree.pm" 2>/dev/null | while read -r file; do
    sed -i.bak 's/^use 5\.20;/#use 5.20;/' "$file"
done
```

### **خطوات الإصلاح اليدوي**
إذا لم يعمل الأمر التلقائي، يُرجى اتباع الخطوات التالية:

1. **البحث عن موقع الملف**
   ```bash
   find /usr -name "IPfree.pm" 2>/dev/null
   ```

2. **تحرير الملف وتعليق سطر فحص الإصدار**
   ```bash
   sed -i 's/^use 5\.20;/#use 5.20;/' /path/to/IPfree.pm
   ```

### **ملفات إضافية (عند الحاجة)**
نظراً لتنوع وتعقيد المنصات، قد تستخدم أنظمة مختلفة إصدارات مختلفة. إذا لم تكن الملفات المقابلة موجودة في نظامك، يُرجى استبدالها يدوياً بالملفات التالية:

| الملف | الموقع |
|------|------|
| `/usr/share/perl5/Geo/IPfree.pm` | [IPfree.pm](/wwwroot/cgi-bin/lib/IPfree.pm) |
| `/usr/share/perl5/Geo/IPfree.pod` | [IPfree.pod](/wwwroot/cgi-bin/lib/IPfree.pod) |
| `/usr/share/perl5/Geo/dbip-city.mmdb` | [update-dbip](/make/test/awstats/conf/update-dbip) |

---

## 🔄 التحويل قبل الترقية (فقط عند الترقية من إصدار أقدم)

عند ترقية الموقع، قم أولاً بتشغيل `/usr/share/awstats/tools/awstats_convert-en.pl` لتحويل تنسيق ملفات البيانات التاريخية (*.txt) (7.0-7.9 ← 8.1). سيكتشف البرنامج جميع ملفات بيانات `AWStats` (*.txt) في دليل `/home/*/web/*/stats/` ويحولها بشكل مجمع. قم بتنفيذه بثقة، فهو سينشئ نسخة احتياطية تلقائيًا من الملفات الأصلية قبل التحويل. إذا لم يكن موقعك في دليل `home`، يرجى الرجوع إلى هيكل المسار هذا `/home/اسم_مستخدم_تشغيل_الموقع/web/اسم_النطاق/stats/` للتعديل. بعد اكتمال التحويل، قم بتنفيذ عملية تحديث البيانات، وإلا سيفشل التحديث بسبب عدم توافق التنسيق.

> **ملاحظة**: إذا كان إصدار موقعك أقل من 7.0، يرجى ضبط معامل المطابقة في التعبير النمطي `s/AWSTATS DATA FILE 7\.[0-9]{1,2}/AWSTATS DATA FILE 8.1/` في البرنامج النصي وفقًا لرقم الإصدار الفعلي.
>
> **💡 تلميح**: يتم حفظ الملفات الاحتياطية افتراضيًا في دليل `/backup/awstats_converter/backup_طابع_زمني_أثناء_التنفيذ/`.

```bash
# تشغيل تجريبي (عرض الملفات التي سيتم تحويلها)
perl /usr/share/awstats/tools/awstats_convert-en.pl --dryrun

# تشغيل عادي
perl /usr/share/awstats/tools/awstats_convert-en.pl

# إعادة تحويل جميع الملفات بالقوة
perl /usr/share/awstats/tools/awstats_convert-en.pl --force

# وضع صامت
perl /usr/share/awstats/tools/awstats_convert-en.pl --quiet

# عرض المساعدة
perl /usr/share/awstats/tools/awstats_convert-en.pl --help
```

---

## 🚀 بداية سريعة

### 1. التثبيت

#### لمستخدمي HestiaCP (موصى به)

> **ملاحظة**: هذا السكربت مخصص فقط للوحة تحكم HestiaCP. إذا كنت تستخدم لوحة تحكم أخرى أو لا تستخدم لوحة تحكم، يرجى الرجوع إلى دالة `build_awstats()` في السكربت والتعديل وفقًا لبيئتك الفعلية.

HestiaCP يأتي مدمجًا مع AWStats، ما عليك سوى تحديث وتثبيت حزم `deb` و `rpm` المعدة مسبقًا لتجربة الإصدار المجتمعي الجديد.

**التوزيعات المدعومة**:
- دعم رسمي: [Debian/Ubuntu](https://github.com/hestiacp/hestiacp)
- دعم مجتمعي: [RHEL/CentOS/Alma/Rocky](https://github.com/bayrepo/hestiacp-rpm)

**الملفات التي تحتاج إلى تعديل يدوي**:

| نوع الملف | المسار | مثال مرجعي |
|:---:|:---:|:---:|
| ملف القالب | `/usr/local/hestia/data/templates/web/awstats/awstats.tpl` | [awstats.tpl](/make/test/awstats/conf/awstats.tpl) |
| دليل إعدادات النطاق | `/etc/awstats/` | - |
| سكربت التحديث (Debian/Ubuntu ومشتقاتهما) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.debian](/make/test/awstats/conf/v-update-web-domain-stat) |
| سكربت التحديث (RHEL/CentOS/Rocky/Alma/Fedora) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.rhel](/make/test/awstats/conf/v-update-web-domain-stat) |

> 📌 **توضيح**: أكواد سكربتات Debian و RHEL مختلفة، يرجى اختيار المثال المرجعي المناسب وفقًا لنظام التشغيل الخاص بك.

> 💡 **تلميح**: بعد تعديل السكربت، إذا واجهت مشكلة في الصلاحيات، قم بتنفيذ الأمر `chmod +x /usr/local/hestia/bin/v-update-web-domain-stat`

## التحميل والتثبيت

### HestiaCP التكامل مع

> ⚠️ **تنبيه مهم**: عند التثبيت في بيئة HestiaCP، إذا طلب النظام تحديث ملف التكوين، يرجى اختيار **`N`** (الاحتفاظ بالتكوين الأصلي)، وإلا سيتم استبدال تكوين المسار الخاص بلوحة HestiaCP.

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### Debian / Ubuntu التثبيت المباشر

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### RHEL / CentOS / Rocky Linux / Fedora

```bash
# استخدام أمر DNF القياسي للتثبيت، متوافق تماماً مع نظام Red Hat البيئي
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm && dnf install -y /tmp/awstats-8.1-1.noarch.rpm
```

### FreeBSD

```bash
# قفل الحماية بحقنة واحدة بعد التثبيت، القضاء تماماً على التقارير الخاطئة لإصدارات لوحات الإدارة القديمة (مثل Webmin)
fetch -o /tmp/awstats-8.1-1.pkg https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.pkg && \
pkg install -y /tmp/awstats-8.1-1.pkg && \
pkg lock -y awstats
```

### التكوين الأساسي

قم بتحرير ملف التكوين `/etc/awstats/awstats.nطاقك.conf`:

```perl
LogFile="/var/log/apache2/domains/nطاقك.log"  # مسار ملف السجل
LogFormat=1                                         # استخدام تنسيق السجل المدمج
SiteDomain="nطاقك.com"                         # نطاق الموقع
HostAliases="localhost 127.0.0.1"                   # أسماء مستعارة للمضيف
```

### تحديث الإحصاءات

```bash
awstats.pl -config=nطاقك -update
```

### عرض التقرير

- **بيئة HestiaCP**: قم بزيارة `https://nطاقك.com/vstats/`. إذا كنت تريد حفظ إشارة مرجعية، يرجى تعيين هذا الدليل. سيتم التحميل تلقائيًا في وضع CGI!
- **إنشاء تقرير ثابت يدويًا**: `awstats.pl -config=nطاقك -output > report.html`

---

## 📖 تعليمات سطر الأوامر

### عرض التعليمات بلغتك الأم

```bash
# العربية
dnf install -y glibc-langpack-ar
localectl set-locale LANG=ar_SA.UTF-8
# لـ RHEL/CentOS/Fedora:
source /etc/locale.conf
# لـ Debian/Ubuntu:
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
# لـ RHEL/CentOS/Fedora:
source /etc/locale.conf
# لـ Debian/Ubuntu:
source /etc/default/locale
awstats -h

# 简体中文
dnf install -y glibc-langpack-zh wget
localectl set-locale LANG=zh_CN.UTF-8
# لـ RHEL/CentOS/Fedora:
source /etc/locale.conf
# لـ Debian/Ubuntu:
source /etc/default/locale
awstats -h

# 日本語
dnf install -y glibc-langpack-ja
localectl set-locale LANG=ja_JP.UTF-8
# لـ RHEL/CentOS/Fedora:
source /etc/locale.conf
# لـ Debian/Ubuntu:
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

### الأوامر شائعة الاستخدام

| الأمر | الوصف |
|:---:|:---:|
| `awstats.pl -config=xxx -update` | تحديث الإحصاءات |
| `awstats.pl -config=xxx -output > report.html` | إنشاء تقرير ثابت |
| `awstats.pl -config=xxx -update -debug=2` | وضع التصحيح (يتطلب تغيير DebugMessages=1 في ملف التكوين) |
| `awstats -h` | عرض المساعدة |
| `awstats -v` | عرض معلومات الإصدار |

---

## 📚 الوثائق

| الوثيقة | الرابط |
|:---:|:---:|
| سجل التغييرات (العربية) | [docs/CHANGELOG-ar.md](docs/CHANGELOG-ar.md) |
| سجل التغييرات (الإنجليزية) | [docs/CHANGELOG.md](docs/CHANGELOG.md) |
| دليل التثبيت | [docs/awstats_setup.html](docs/awstats_setup.html) |
| شرح التكوين | [docs/awstats_config.html](docs/awstats_config.html) |
| الأسئلة الشائعة | [docs/awstats_faq.html](docs/awstats_faq.html) |

---

## 🤝 المساهمة والملاحظات

- **مستودع المشروع**: [GitHub - hestiacn/vstats](https://github.com/hestiacn/vstats)
- **الإبلاغ عن المشكلات**: [GitHub Issues](https://github.com/hestiacn/vstats/issues)

---

## 💖 شكر وتقدير

شكر خاص لجميع المترجمين والمختبرين الذين ساعدونا في ترجمة صيغ الجمع الست في اللغتين الويلزية والعربية بشكل صحيح. أنتم أبطال الإنترنت الحقيقيون!

---

## 📄 الرخصة

`AWStats` هو برنامج مفتوح المصدر، يتم نشره بموجب [رخصة GNU العامة العمومية الإصدار 3](https://www.gnu.org/licenses/gpl-3.0.html#license-text).

---

## 👨‍💻 حول المؤلف والصيانة

**المؤلف الأصلي**: Laurent Destailleur (1997-2025)
- مؤسس المشروع، أعلن عن إيقاف التحديثات في نوفمبر 2025.
- قائد مشروع [Dolibarr ERP CRM](https://www.dolibarr.org)

**الصيانة المجتمعية**: [hestiacn](https://github.com/hestiacn/vstats)
- إعادة هيكلة وتحديث الإصدار 8.1
- صيانة وتحديث مستمرين

---

## 🔗 روابط ذات صلة

- موقع المشروع الأصلي: [https://www.awstats.org](https://www.awstats.org)
- مستودع GitHub للمشروع الأصلي: [eldy/AWStats](https://github.com/eldy/AWStats)
- قاعدة بيانات DB-IP: [https://db-ip.com](https://db-ip.com)

---

## © 1997-2026 فريق AWStats | إصدار المجتمع قيد الصيانة المستمرة
# AWStats 8.1 - Расширенный инструмент статистики веб-сайтов (Сообщество)

<p align="center">
  <img src="docs/images/screenshot.png" alt="Предварительный просмотр панели AWStats" width="800">
</p>

<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html#license-text"><img src="https://img.shields.io/badge/Лицензия-GPL%20v3-blue.svg" alt="Лицензия"></a>
  <a href="https://www.perl.org/"><img src="https://img.shields.io/badge/Perl-5.20%2B-brightgreen.svg" alt="Версия Perl"></a>
  <br><br>
  <a href="https://github.com/hestiacn/vstats/releases/latest"><img src="https://img.shields.io/github/v/release/hestiacn/vstats?style=for-the-badge&logo=github&label=Последняя%20версия&color=blue" alt="Последняя версия"></a>
  <br><br>
  <a href="docs/CHANGELOG-zh_CN.md"><img src="https://img.shields.io/badge/📝_Журнал_изменений-Русская_версия-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="Журнал изменений"></a>
  <br><br>
  <a href="docs/CHANGELOG.md"><img src="https://img.shields.io/badge/📝_Changelog-English_Version-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="Changelog"></a>
</p>

> **🎉 Это первый крупный релиз сообщества vstats!** Полная реконструкция легендарного `AWStats` (1997-2025). Мы отряхнули от пыли и обновили его, чтобы он мог справиться с вызовами следующих 25 лет!

Оригинальный `AWStats` был архивирован в ноябре 2025 года после 25 лет обслуживания. Этот проект представляет собой полную реконструкцию и улучшение функциональности оригинальной версии, поддерживаемую сообществом [hestiacn](https://github.com/hestiacn/vstats).

---

## 🚀 Основные возможности релиза

### 1. Родная поддержка UTF-8 (Прощайте проблемы с кодировкой)

Попрощайтесь с головной болью от проблем кодировки! Вся внутренняя логика и вывод теперь полностью используют кодировку UTF-8. Русский, китайский, японский, арабский и другие специальные символы теперь отображаются идеально.

### 2. Глубокая локализация (73+ языков)

- Полный переход системы перевода с цифровых индексов на семантические ключи (`_t('key')`)
- Добавлено/обновлено 73 языков (включая кипрский, бразильский португальский и другие)
- Добавлены уникальные юмористические описания для 24-часовой статистики — маленький сюрприз для системных администраторов, работающих в 4 утра! ☕️

### 3. Современный пользовательский интерфейс и адаптивный дизайн

- **Тёмный/Светлый режим**: переключение темы одним щелчком
- **Чистые CSS графики**: старые PNG изображения заменены на современные CSS графики с поддержкой `border-radius`
- **Интеграция эмодзи**: использование эмодзи для визуализации данных, создание современного визуального опыта

### 4. Оптимизация производительности и кода

- Значительная очистка кода Perl для повышения производительности в современных CGI-средах
- Улучшенное обнаружение современных браузеров и ботов (актуальные правила 2026 года)

### 5. Поддержка множества календарей и 13 месяцев 🗓️

Поддержка **13 типов календарей** (включая эфиопский и еврейский календари с **13 месяцами**), автоматическое сопоставление с языком сайта.

> 📌 **Эфиопский календарь**: первые 12 месяцев по 30 дней, 13-й месяц — 6 дней в високосный год и 5 дней в обычный.
> 📌 **Еврейский календарь**: 7 високосных лет в 19-летнем цикле, в високосный год добавляется Адар I (30 дней), образуя 13-й месяц.

### 6. Пользовательский брендинг 🏷️

> **Для хостинг-провайдеров и корпоративных пользователей**

Теперь можно отображать пользовательскую информацию о бренде (**Логотип** и **Название бренда**) в верхней части страницы `AWStats`.

**Особенности**:
- 📍 Область бренда автоматически отображается только при наличии файла `/stats/logo.svg`
- 🔗 Поддержка пользовательской ссылки бренда (переход по клику на логотип)
- 🏷️ Поддержка произвольного названия бренда (рекомендуется использовать английское название для совместимости с многоязычной средой), автоматическое форматирование как **`Название бренда + " Панель управления сервером"`**

**Примеры использования**:
| Тип | Примеры |
|:---:|:---:|
| 🐧 Дистрибутивы Linux | `RHEL`, `Debian`, `Ubuntu`, `CentOS`, `Arch Linux`, `Fedora`, `Rocky Linux` |
| 🖥️ Операционные системы | `macOS`, `Windows`, `FreeBSD` |
| ☁️ Облачные хостинги | `Aliyun`, `Tencent`, `AWS`, `Azure`, `Google Cloud` |

**Пример конфигурации**:
```perl
# Добавьте в файл конфигурации AWStats
BrandLink="https://example.com"      # Ссылка для перехода по клику на логотип
BrandPlatform="Ubuntu"               # Название бренда (показывает "Ubuntu Панель управления сервером")
StatsUrl="/vstats"                   # Каталог развертывания AWStats
```

> **Примечание**: Область бренда отображается только при наличии файла `logo.svg`. Если `BrandLink` не настроен, используется значение по умолчанию `https://hestiacp.com`.

---

## 📦 Загрузка и установка

Получите последнюю версию по ссылкам ниже:

| Система/Формат | Ссылка для загрузки |
|:---:|:---:|
| **Debian/Ubuntu** | [![Скачать .deb](https://img.shields.io/badge/Скачать-.deb_пакет-2ea44f?logo=debian&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb) |
| **RHEL/CentOS/Fedora** | [![Скачать .rpm](https://img.shields.io/badge/Скачать-.rpm_пакет-2ea44f?logo=fedora&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm) |
| **Исходный код (tar.gz)** | [![Скачать .tar.gz](https://img.shields.io/badge/Скачать-.tar.gz-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.tar.gz) |
| **Исходный код (zip)** | [![Скачать .zip](https://img.shields.io/badge/Скачать-.zip-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.zip) |
| **Windows** | [![Скачать Windows](https://img.shields.io/badge/Скачать-Windows_версию-2ea44f?logo=windows&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-utf8.exe) |

> **Примечание для Windows**: Версия для Windows включает только EXE-установщик. Структура каталогов и пути не тестировались. Если вы столкнулись с проблемами при использовании, пожалуйста, сообщите о них через Issue или Pull Request.

---

## 📊 Сравнение с оригинальной версией

| Характеристика | Оригинальный AWStats | Обновленная версия |
|:---:|:---:|:---:|
| Кодировка | GBK / частичная кодировка | **Полная поддержка UTF-8** |
| Способ перевода | Числовые индексы `$Message[169]` | **Семантические ключи `_t('key')`** |
| Стиль интерфейса | Фиксированный стиль | **Светлая/Тёмная тема + Адаптивный дизайн** |
| Флаги | Изображения PNG | **Эмодзи** |
| Графики | Изображения PNG | **Чистые CSS графики** |
| Поддержка календарей | Григорианский календарь | **12 календарей** |
| Состояние поддержки | Архивирован | **Активно поддерживается** |

---

## ✨ Полный список функций

| Категория | Функция |
|:---:|:---:|
| 🌐 Многоязычный CGI доступ | Интерфейс на `73` языках, автоматическое определение браузера. Позволяет посетителям со всего мира просматривать отчёты на родном языке! [Смотреть список поддерживаемых языков](docs/CHANGELOG.md#-language-support) |
| 🗓️ Поддержка нескольких календарей | **13 типов календарей** (включая эфиопский 13-месячный календарь), автоматическое сопоставление с языком сайта |
| 📊 Статистика посещений | Уникальные посетители, количество посещений, продолжительность посещений, отслеживание аутентифицированных пользователей |
| 🌍 Геолокация | Бесплатная база данных `DB-IP`, трехуровневая локализация страна/регион/город, поддержка IPv4/IPv6 |
| 💻 Информация о клиентах | Браузер, операционная система, разрешение экрана, тип устройства (настольный/мобильный) |
| 🤖 Обнаружение роботов | `500+` поисковых роботов, AI/ML-ботов (ClaudeBot, GPTBot и др.) |
| 📁 Статистика файлов | Типы файлов, загрузки (возобновляемые), сжатие (mod_gzip/mod_deflate) |
| ⚠️ Анализ ошибок | `HTTP` ошибки (404 и др.), источники ошибок, локализованные описания кодов состояния обнаружения атак червей |
| 🎨 Современный интерфейс | Адаптивный дизайн, тёмная/светлая тема, чистые CSS-графики, эмодзи для флагов |

---

## 📋 Системные требования

### Основные требования
- ✅ Доступ к анализируемым серверным лог-файлам (Web/FTP/Почта)
- ✅ 5.20 или выше (рекомендуется 5.32+)
- ✅ Среда командной строки и/или CGI

### Поддерживаемые операционные системы
- 🐧 Linux/Unix (Ubuntu, Debian, CentOS, RHEL и др.)
- 🪟 Windows (Windows 10/11, Windows Server)
- 🍎 macOS
- 🔵 FreeBSD, OpenBSD

### Поддерживаемые серверы
- 🌐 Web: Apache, Nginx, IIS, Caddy, Lighttpd
- 📁 FTP: ProFTPd, vsFTPd, Pure-FTPd
- 📧 Почта: Postfix, Sendmail, QMail, Exim
- 🎥 Стриминг: RealMedia, Windows Media Server

---

## 🔄 Конвертация перед обновлением (только при обновлении с более старых версий)

При обновлении сайта сначала выполните `/usr/share/awstats/tools/awstats_convert-en.pl` для конвертации формата исторических файлов данных (*.txt) (7.0-7.9 → 8.1). Программа автоматически обнаруживает и конвертирует все файлы данных `AWStats` (*.txt) в каталоге `/home/*/web/*/stats/`. Конвертация безопасна — перед началом создаются резервные копии оригинальных файлов. Если ваш сайт находится не в каталоге `home`, используйте эту структуру пути в качестве ориентира: `/home/имя_пользователя_сайта/web/ваш_домен/stats/`. После завершения конвертации выполните обновление данных, иначе обновление не удастся из-за несовместимости форматов.

> **Примечание**: Если версия вашего сайта ниже 7.0, настройте параметр сопоставления регулярного выражения `s/AWSTATS DATA FILE 7\.[0-9]{1,2}/AWSTATS DATA FILE 8.1/` в скрипте в соответствии с фактическим номером версии.
>
> **💡 Подсказка**: Резервные копии по умолчанию сохраняются в каталог `/backup/awstats_converter/backup_время_выполнения/`.

```bash
# Пробный запуск (просмотр файлов, которые будут конвертированы)
perl /usr/share/awstats/tools/awstats_convert-en.pl --dryrun

# Обычный запуск
perl /usr/share/awstats/tools/awstats_convert-en.pl

# Принудительная повторная конвертация всех файлов
perl /usr/share/awstats/tools/awstats_convert-en.pl --force

# Тихий режим
perl /usr/share/awstats/tools/awstats_convert-en.pl --quiet

# Просмотр справки
perl /usr/share/awstats/tools/awstats_convert-en.pl --help
```

---

## 🚀 Быстрый старт

### 1. Установка

#### Для пользователей HestiaCP (Рекомендуется)

> **Примечание**: Этот скрипт адаптирован специально для панели управления HestiaCP. Если вы используете другую панель управления или не используете панель вовсе, обратитесь к функции `build_awstats()` в скрипте и настройте её в соответствии с вашим окружением.

HestiaCP уже включает AWStats. Просто обновите и установите предварительно собранные пакеты `deb` и `rpm`, чтобы опробовать новую версию сообщества.

**Поддерживаемые дистрибутивы**:
- Официальная поддержка: [Debian/Ubuntu](https://github.com/hestiacp/hestiacp)
- Поддержка сообществом: [RHEL/CentOS/Alma/Rocky](https://github.com/bayrepo/hestiacp-rpm)

**Файлы, требующие ручной настройки**:

| Тип файла | Путь | Пример для справки |
|:---:|:---:|:---:|
| Файл шаблона | `/usr/local/hestia/data/templates/web/awstats/awstats.tpl` | [awstats.tpl](/make/test/awstats/conf/awstats.tpl) |
| Каталог конфигурации домена | `/etc/awstats/` | - |
| Скрипт обновления (Debian/Ubuntu и производные) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.debian](/make/test/awstats/conf/v-update-web-domain-stat) |
| Скрипт обновления (RHEL/CentOS/Rocky/Alma/Fedora) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.rhel](/make/test/awstats/conf/v-update-web-domain-stat) |

> 📌 **Пояснение**: Код скриптов для систем на базе Debian и RHEL различается. Пожалуйста, выберите соответствующий пример для справки в зависимости от вашей операционной системы.

> 💡 **Совет**: Если после изменения скрипта возникла проблема с правами доступа, выполните `chmod +x /usr/local/hestia/bin/v-update-web-domain-stat`

## Скачать и установить

### Развертывание интеграции с HestiaCP

> ⚠️ **Важное примечание**: При установке в среде HestiaCP, если система предложит обновить файл конфигурации, пожалуйста, выберите **`N`** (сохранить исходную конфигурацию), иначе будет перезаписана специальная конфигурация маршрутизации панели HestiaCP.

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### Debian / Ubuntu Нативная установка

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### RHEL / CentOS / Rocky Linux / Fedora

```bash
# Использование современной стандартной команды DNF, идеально совместимой со всей экосистемой Red Hat
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm && dnf install -y /tmp/awstats-8.1-1.noarch.rpm
```

### FreeBSD

```bash
# Одноклипковая блокировка после установки, полностью устраняющая ложные сообщения о понижении версии сторонних панелей управления (например, Webmin)
fetch -o /tmp/awstats-8.1-1.pkg https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.pkg && \
pkg install -y /tmp/awstats-8.1-1.pkg && \
pkg lock -y awstats
```

### Базовая конфигурация

Отредактируйте файл конфигурации `/etc/awstats/awstats.ваш_домен.conf`:

```perl
LogFile="/var/log/apache2/domains/ваш_домен.log"  # Путь к лог-файлу
LogFormat=1                                         # Использовать комбинированный формат лога
SiteDomain="ваш_домен.com"                         # Домен веб-сайта
HostAliases="localhost 127.0.0.1"                   # Псевдонимы хоста
```

### Обновление статистики

```bash
awstats.pl -config=ваш_домен -update
```

### Просмотр отчёта

- **Среда HestiaCP**: Откройте `https://ваш_домен.com/vstats/`. Если хотите сохранить закладку, установите этот каталог. При доступе автоматически загружается режим CGI!
- **Генерация статического отчёта вручную**: `awstats.pl -config=ваш_домен -output > report.html`

---

## 📖 Справка командной строки

### Просмотр справки на вашем родном языке

```bash
# Русский
dnf install -y glibc-langpack-ru
localectl set-locale LANG=ru_RU.UTF-8
# Для RHEL/CentOS/Fedora:
source /etc/locale.conf
# Для Debian/Ubuntu:
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

### Часто используемые команды

| Команда | Описание |
|:---:|:---:|
| `awstats.pl -config=xxx -update` | Обновить статистику |
| `awstats.pl -config=xxx -output > report.html` | Создать статический отчёт |
| `awstats.pl -config=xxx -update -debug=2` | Режим отладки (требуется изменить DebugMessages=1 в конфигурационном файле) |
| `awstats -h` | Показать справку |
| `awstats -v` | Показать информацию о версии |

---

## 📚 Документация

| Документ | Ссылка |
|:---:|:---:|
| Журнал изменений (Русский) | [docs/CHANGELOG-ru.md](docs/CHANGELOG-ru.md) |
| Журнал изменений (Английский) | [docs/CHANGELOG.md](docs/CHANGELOG.md) |
| Руководство по установке | [docs/awstats_setup.html](docs/awstats_setup.html) |
| Описание конфигурации | [docs/awstats_config.html](docs/awstats_config.html) |
| Часто задаваемые вопросы | [docs/awstats_faq.html](docs/awstats_faq.html) |

---

## 🤝 Вклад и обратная связь

- **Репозиторий проекта**: [GitHub - hestiacn/vstats](https://github.com/hestiacn/vstats)
- **Сообщить о проблеме**: [GitHub Issues](https://github.com/hestiacn/vstats/issues)

---

## 💖 Благодарности

Особая благодарность всем переводчикам и тестировщикам, которые помогли правильно перевести шесть форм множественного числа в валлийском и арабском языках. Вы настоящие герои сети!

---

## 📄 Лицензия

`AWStats` — это программное обеспечение с открытым исходным кодом, распространяемое под лицензией [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.html#license-text).

---

## 👨‍💻 Об авторе и поддержке

**Оригинальный автор**: Laurent Destailleur (1997-2025)
- Основатель проекта, объявил о прекращении обновлений в ноябре 2025 года.
- Руководитель проекта [Dolibarr ERP CRM](https://www.dolibarr.org)

**Поддержка сообществом**: [hestiacn](https://github.com/hestiacn/vstats)
- Модернизация и реконструкция версии 8.1
- Активное обслуживание и обновление

---

## 🔗 Связанные ссылки

- Веб-сайт оригинального проекта: [https://www.awstats.org](https://www.awstats.org)
- GitHub репозиторий оригинального проекта: [eldy/AWStats](https://github.com/eldy/AWStats)
- База данных DB-IP: [https://db-ip.com](https://db-ip.com)

---

## © 1997-2026 Команда AWStats | Версия сообщества активно поддерживается
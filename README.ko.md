# AWStats 8.1 - 고급 웹사이트 통계 도구 (커뮤니티 에디션)

<p align="center">
  <img src="docs/images/screenshot.png" alt="AWStats 대시보드 미리보기" width="800">
</p>

<p align="center">
<a href="https://www.gnu.org/licenses/gpl-3.0.html#license-text"><img src="https://img.shields.io/badge/라이선스-GPL%20v3-blue.svg" alt="라이선스"></a>
  <a href="https://www.perl.org/"><img src="https://img.shields.io/badge/Perl-5.20%2B-brightgreen.svg" alt="Perl 버전"></a>
  <br>
  <a href="https://github.com/hestiacn/vstats/releases/latest"><img src="https://img.shields.io/github/v/release/hestiacn/vstats?style=for-the-badge&logo=github&label=최신%20버전&color=blue" alt="최신 버전"></a>
  <br><br>
  <a href="docs/CHANGELOG-zh_CN.md"><img src="https://img.shields.io/badge/📝_업데이트 로그-중문판-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="업데이트 로그"></a>
  <br><br>
  <a href="docs/CHANGELOG.md"><img src="https://img.shields.io/badge/📝_Changelog-English_Version-0891b2?style=for-the-badge&logo=markdown&logoColor=white" alt="Changelog"></a>
</p>

> **🎉 이것은 vstats의 첫 번째 메이저 커뮤니티 릴리스입니다!** 전설적인 `AWStats`(1997-2025)의 완전한 리팩토링 버전입니다. 먼지를 털어내고 향후 25년에 걸맞게 새롭게 태어났습니다!

원본 `AWStats`는 25년간의 유지보수 끝에 2025년 11월에 아카이브되었습니다. 이 프로젝트는 원본을 기반으로 완전한 리팩토링과 기능 개선을 수행했으며, [hestiacn](https://github.com/hestiacn/vstats) 커뮤니티에 의해 지속적으로 유지보수되고 있습니다.

---

## 🚀 릴리스 하이라이트

### 1. 네이티브 UTF-8 지원 (귀찮은 인코딩 문제와 작별)

골치 아픈 인코딩 문제와 작별하세요! 모든 내부 로직과 출력이 이제 완전히 UTF-8 인코딩을 지원합니다. 한글, 중국어, 일본어, 아랍어 및 기타 특수 문자가 완벽하게 표시됩니다.

### 2. 글로벌 "소울풀" 현지화 (73개 언어)

- 전체 번역 시스템을 숫자 인덱스에서 의미론적 키(`_t('key')`)로 전환
- 73개 언어 추가/업데이트 (키프로스어, 브라질 포르투갈어 등)
- 24시간 통계에 독특하고 유머러스한 설명 추가 — 새벽 4시에 일하는 시스템 관리자를 위한 작은 깜짝 선물! ☕️

### 3. 모던한 사용자 인터페이스 및 반응형 디자인

- **다크/라이트 모드**: 원클릭 테마 전환
- **순수 CSS 차트**: 오래된 PNG 이미지는 `border-radius`를 지원하는 모던 CSS 차트로 대체
- **이모지 통합**: 데이터 시각화에 이모지를 사용하여 모던한 비주얼 경험 제공

### 4. 성능 및 코드 최적화

- 현대 CGI 환경에서의 성능 향상을 위해 Perl 코드 대폭 정리
- 최신 브라우저 및 봇 감지 기능 개선 (2026년 최신 규칙)

### 5. 다중 달력 시스템 및 13개월 지원 🗓️

일본 연호, 불교력, 민국 기년, 간지 기년, 이슬람력, 페르시아력 등 **13가지 달력** (에티오피아력/히브리력 **13개월** 포함) 지원, 사이트 언어에 자동 매칭.

> 📌 **에티오피아 달력**: 앞의 12개월은 각 30일, 13번째 달은 윤년 6일, 평년 5일.
> 📌 **히브리 달력**: 19년에 7번의 윤년, 윤년에는 Adar I(30일)을 추가하여 13개월 형성.

### 6. 사용자 정의 브랜드 표시 🏷️

> **호스팅 제공업체 및 기업 사용자용**

`AWStats` 페이지 상단에 사용자 정의 브랜드 정보(**로고** 및 **브랜드 이름**)를 표시할 수 있습니다.

**기능 특성**:
- 📍 브랜드 영역은 `/stats/logo.svg` 파일이 존재하는 경우에만 자동 표시
- 🔗 사용자 정의 브랜드 링크 지원 (로고 클릭 시 이동)
- 🏷️ 임의의 브랜드 이름 지원 (다국어 환경 호환을 위해 영어 이름 권장), 자동으로 **`브랜드명 + " 서버 관리 패널"`** 형식으로 표시

**사용 예시**:
| 유형 | 예시 |
|:---:|:---:|
| 🐧 Linux 배포판 | `RHEL`, `Debian`, `Ubuntu`, `CentOS`, `Arch Linux`, `Fedora`, `Rocky Linux` |
| 🖥️ 운영체제 | `macOS`, `Windows`, `FreeBSD` |
| ☁️ 클라우드 호스팅 | `Aliyun`, `Tencent`, `AWS`, `Azure`, `Google Cloud` |

**설정 예시**:
```perl
# AWStats 설정 파일에 추가
BrandLink="https://example.com"      # 로고 클릭 시 이동 링크
BrandPlatform="Ubuntu"               # 브랜드 이름 ("Ubuntu 서버 관리 패널"로 표시)
StatsUrl="/vstats"                   # AWStats 배포 디렉토리
```

> **참고**: 브랜드 영역은 `logo.svg` 파일이 존재하는 경우에만 표시됩니다. `BrandLink`가 설정되지 않은 경우 기본값 `https://hestiacp.com`이 사용됩니다.

---

## 📦 다운로드 및 설치

최신 버전은 아래 링크에서 다운로드하세요:

| 시스템/형식 | 다운로드 링크 |
|:---:|:---:|
| **Debian/Ubuntu** | [![Download .deb](https://img.shields.io/badge/Download-.deb_패키지-2ea44f?logo=debian&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb) |
| **RHEL/CentOS/Fedora** | [![Download .rpm](https://img.shields.io/badge/Download-.rpm_패키지-2ea44f?logo=fedora&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm) |
| **소스 코드 (tar.gz)** | [![Download .tar.gz](https://img.shields.io/badge/Download-.tar.gz-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.tar.gz) |
| **소스 코드 (zip)** | [![Download .zip](https://img.shields.io/badge/Download-.zip-2ea44f?logo=sourceforge&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1.zip) |
| **Windows** | [![Download Windows](https://img.shields.io/badge/Download-Windows_버전-2ea44f?logo=windows&logoColor=white)](https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-utf8.exe) |

> **Windows 환경 참고**: Windows 버전은 EXE 설치 프로그램만 패키징되어 있으며, 디렉토리 구조와 경로는 실제로 테스트되지 않았습니다. 사용 중 문제가 발생하면 Issue 또는 Pull Request를 제출해 주세요.

---

## 📊 원본 대비 비교

| 기능 | 원본 AWStats | 리팩토링 버전 |
|:---:|:---:|:---:|
| 인코딩 | GBK / 부분적 인코딩 | **UTF-8 완전 지원** |
| 번역 방식 | 숫자 인덱스 `$Message[169]` | **의미론적 키 `_t('key')`** |
| 인터페이스 | 고정 스타일 | **라이트/다크 테마 + 반응형** |
| 국기 | PNG 이미지 | **이모지** |
| 차트 | PNG 이미지 | **순수 CSS 차트** |
| 달력 지원 | 그레고리력 | **13가지 달력** |
| 유지보수 상태 | 아카이브됨 | **지속적 유지보수** |

---

## ✨ 전체 기능 목록

| 카테고리 | 기능 |
|:---:|:---:|
| 🌐 다국어 CGI 접근 | `73`개 언어 인터페이스, 브라우저 자동 감지. 전 세계 방문자가 모국어로 리포트를 확인 가능! [자세한 언어 지원 목록 보기](docs/CHANGELOG.md#-language-support) |
| 🗓️ 다중 달력 지원 | 일본 연호, 불교력, 민국 기년, 간지 기년, 이슬람력, 페르시아력 등 **13가지 달력** (에티오피아 13개월력 포함), 사이트 언어에 자동 매칭 |
| 📊 접근 통계 | 고유 방문자, 방문 횟수, 체류 시간, 인증 사용자 추적 |
| 🌍 지리적 위치 | `DB-IP` 무료 데이터베이스, 국가/지역/도시 3단계 위치 정보, IPv4/IPv6 지원 |
| 💻 클라이언트 정보 | 브라우저, 운영체제, 화면 해상도, 장치 유형 (데스크톱/모바일) |
| 🤖 크롤러 식별 | `500+` 검색 엔진 크롤러, AI/ML 크롤러 (ClaudeBot, GPTBot 등) |
| 📁 파일 통계 | 파일 유형, 다운로드 (이어받기), 압축 (mod_gzip/mod_deflate) |
| ⚠️ 오류 분석 | `HTTP` 오류 (404 등), 오류 출처, 웜 공격 감지 상태 코드 현지화 설명 |
| 🎨 모던 인터페이스 | 반응형 디자인, 다크/라이트 테마, 순수 CSS 차트, 이모지 국기 아이콘 |

---

## 📋 시스템 요구사항

### 기본 요구사항
- ✅ 분석할 서버 로그 파일(Web/FTP/메일)에 접근 가능
- ✅ 5.20 이상 (5.32+ 권장)
- ✅ 명령줄 및/또는 CGI 환경

### 지원 운영체제
- 🐧 Linux/Unix (Ubuntu, Debian, CentOS, RHEL 등)
- 🪟 Windows (Windows 10/11, Windows Server)
- 🍎 macOS
- 🔵 FreeBSD, OpenBSD

### 지원 서버
- 🌐 Web: Apache, Nginx, IIS, Caddy, Lighttpd
- 📁 FTP: ProFTPd, vsFTPd, Pure-FTPd
- 📧 메일: Postfix, Sendmail, QMail, Exim
- 🎥 스트리밍: RealMedia, Windows Media Server

---

## **AWStats Geo/IPfree.pm 버전 호환성 수정**

AWStats 업데이트 실행 중 다음과 같은 오류가 발생하는 경우:
```
Error: Perl v5.200.0 required (did you mean v5.20.0?)--this is only v5.36.0
```

이는 `Geo/IPfree.pm` 파일의 버전 확인이 현재 시스템의 Perl 버전과 호환되지 않기 때문입니다.

### **자동 수정 명령어**
```bash
find /usr -name "IPfree.pm" 2>/dev/null | while read -r file; do
    sed -i.bak 's/^use 5\.20;/#use 5.20;/' "$file"
done
```

### **수동 수정 단계**
자동 명령어가 작동하지 않는 경우 다음 단계를 따르세요:

1. **파일 위치 찾기**
   ```bash
   find /usr -name "IPfree.pm" 2>/dev/null
   ```

2. **파일을 편집하여 버전 확인 줄 주석 처리**
   ```bash
   sed -i 's/^use 5\.20;/#use 5.20;/' /path/to/IPfree.pm
   ```

### **추가 파일 (필요시)**
플랫폼의 다양성과 복잡성으로 인해 시스템마다 다른 버전이 사용될 수 있습니다. 해당 파일이 시스템에 없는 경우 다음 파일로 수동 교체하세요:

| 파일 | 위치 |
|------|------|
| `/usr/share/perl5/Geo/IPfree.pm` | [IPfree.pm](/wwwroot/cgi-bin/lib/IPfree.pm) |
| `/usr/share/perl5/Geo/IPfree.pod` | [IPfree.pod](/wwwroot/cgi-bin/lib/IPfree.pod) |
| `/usr/share/perl5/Geo/dbip-city.mmdb` | [update-dbip](/make/test/awstats/conf/update-dbip) |

---

## 🔄 업그레이드 전 변환 (이전 버전에서 업그레이드하는 경우만)

사이트 업그레이드 시 먼저 `/usr/share/awstats/tools/awstats_convert-en.pl`을 실행하여 기록 데이터 파일(*.txt)의 형식을 변환(7.0-7.9 → 8.1)하세요. 프로그램은 `/home/*/web/*/stats/` 디렉토리 아래의 모든 `AWStats` 데이터 파일(*.txt)을 자동 감지하여 일괄 변환합니다. 변환 전에 원본 파일을 자동 백업하므로 안심하고 실행하세요. 사이트가 `home` 디렉토리에 없는 경우 이 경로 구조 `/home/사이트운영사용자명/web/사용중인도메인/stats/`를 참고하여 조정하세요. 변환 완료 후 데이터 업데이트 작업을 실행하세요. 형식이 호환되지 않으면 업데이트가 실패합니다.

> **참고**: 사이트 버전이 7.0보다 낮은 경우 실제 버전 번호에 맞춰 스크립트 내 `s/AWSTATS DATA FILE 7\.[0-9]{1,2}/AWSTATS DATA FILE 8.1/` 정규식 일치 매개변수를 조정하세요.
>
> **💡 힌트**: 백업 파일은 기본적으로 `/backup/awstats_converter/backup_실행시_타임스탬프명/` 디렉토리에 저장됩니다.

```bash
# 테스트 실행 (변환될 파일 확인)
perl /usr/share/awstats/tools/awstats_convert-en.pl --dryrun

# 정식 실행
perl /usr/share/awstats/tools/awstats_convert-en.pl

# 모든 파일 강제 재변환
perl /usr/share/awstats/tools/awstats_convert-en.pl --force

# 무음 모드
perl /usr/share/awstats/tools/awstats_convert-en.pl --quiet

# 도움말 보기
perl /usr/share/awstats/tools/awstats_convert-en.pl --help
```

---

## 🚀 빠른 시작

### 1. 설치

#### HestiaCP 사용자 (권장)

> **참고**: 이 스크립트는 HestiaCP 패널 전용으로 조정되었습니다. 다른 제어판을 사용하거나 패널 없이 관리하는 경우 스크립트의 `build_awstats()` 함수를 참조하여 실제 환경에 맞게 조정하세요.

HestiaCP에는 AWStats가 이미 포함되어 있습니다. 빌드된 `deb` 및 `rpm` 패키지를 업데이트하고 설치하기만 하면 새로운 커뮤니티 버전을 경험할 수 있습니다.

**지원 배포판**:
- 공식 지원: [Debian/Ubuntu](https://github.com/hestiacp/hestiacp)
- 커뮤니티 지원: [RHEL/CentOS/Alma/Rocky](https://github.com/bayrepo/hestiacp-rpm)

**수동으로 조정해야 하는 파일**:

| 파일 유형 | 경로 | 참고 예제 |
|:---:|:---:|:---:|
| 템플릿 파일 | `/usr/local/hestia/data/templates/web/awstats/awstats.tpl` | [awstats.tpl](/make/test/awstats/conf/awstats.tpl) |
| 도메인 설정 디렉토리 | `/etc/awstats/` | - |
| 업데이트 스크립트 (Debian/Ubuntu 및 파생판) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.debian](/make/test/awstats/conf/v-update-web-domain-stat) |
| 업데이트 스크립트 (RHEL/CentOS/Rocky/Alma/Fedora) | `/usr/local/hestia/bin/v-update-web-domain-stat` | [v-update-web-domain-stat.rhel](/make/test/awstats/conf/v-update-web-domain-stat) |

> 📌 **설명**: Debian 계열과 RHEL 계열의 스크립트 코드가 다릅니다. 사용 중인 운영체제에 따라 적절한 참고 예제를 선택하세요.

> 💡 **힌트**: 스크립트 수정 후 권한 문제가 발생하면 `chmod +x /usr/local/hestia/bin/v-update-web-domain-stat`을 실행하세요.

## 다운로드 및 설치

### HestiaCP 통합 배포

> ⚠️ **중요 알림**: HestiaCP 환경에서 설치할 때 시스템에서 구성 파일 업데이트를 요청하면 반드시 **`N`**(원본 구성 유지)을 선택하세요. 그렇지 않으면 HestiaCP 패널의 고유 라우팅 구성이 덮어쓰기됩니다.

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### Debian / Ubuntu 기본 설치

```bash
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats_8.1-1_all.deb && apt install -y /tmp/awstats_8.1-1_all.deb
```

### RHEL / CentOS / Rocky Linux / Fedora

```bash
# 최신 DNF 표준 install 명령어 사용, Red Hat 생태계 전체에 완벽 호환
wget -P /tmp/ https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.noarch.rpm && dnf install -y /tmp/awstats-8.1-1.noarch.rpm
```

### FreeBSD

```bash
# 설치 후 원클릭 잠금 방어 주입, 타사 관리 패널(예: Webmin)의 이전 버전 다운그레이드 오보를 완전히 제거
fetch -o /tmp/awstats-8.1-1.pkg https://github.com/hestiacn/vstats/releases/latest/download/awstats-8.1-1.pkg && \
pkg install -y /tmp/awstats-8.1-1.pkg && \
pkg lock -y awstats
```

### 기본 설정

설정 파일 `/etc/awstats/awstats.yourdomain.conf`을 편집합니다:

```perl
LogFile="/var/log/apache2/domains/yourdomain.log"  # 로그 파일 경로
LogFormat=1                                         # combined 로그 형식 사용
SiteDomain="yourdomain.com"                         # 웹사이트 도메인
HostAliases="localhost 127.0.0.1"                   # 호스트 별칭
```

### 통계 업데이트

```bash
awstats.pl -config=yourdomain -update
```

### 리포트 보기

- **HestiaCP 환경**: `https://yourdomain.com/vstats/`에 접속하세요. 북마크를 저장하려면 이 디렉토리를 설정하세요. 접속 시 자동으로 CGI 모드로 로드됩니다!
- **정적 리포트 직접 생성**: `awstats.pl -config=yourdomain -output > report.html`

---

## 📖 명령줄 도움말

### 당신의 모국어로 도움말 보기

```bash
# 한국어
dnf install -y glibc-langpack-ko
localectl set-locale LANG=ko_KR.UTF-8
# RHEL/CentOS/Fedora의 경우:
source /etc/locale.conf
# Debian/Ubuntu의 경우:
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

# Português (Brasil)
dnf install -y glibc-langpack-pt
localectl set-locale LANG=pt_BR.UTF-8
# Para RHEL/CentOS/Fedora:
source /etc/locale.conf
# Para Debian/Ubuntu:
source /etc/default/locale
awstats -h
```

### 자주 사용하는 명령어

| 명령어 | 설명 |
|:---:|:---:|
| `awstats.pl -config=xxx -update` | 통계 업데이트 |
| `awstats.pl -config=xxx -output > report.html` | 정적 리포트 생성 |
| `awstats.pl -config=xxx -update -debug=2` | 디버그 모드 (설정 파일에서 DebugMessages=1로 변경 필요) |
| `awstats -h` | 도움말 표시 |
| `awstats -v` | 버전 정보 표시 |

---

### 레퍼런스 문서

| 문서 | 링크 |
|:---:|:---:|
| 변경 로그 (한국어) | [CHANGELOG-ko.md](docs/CHANGELOG-ko.md) |
| Changelog (English) | [CHANGELOG.md](docs/CHANGELOG.md) |
| 설치 가이드 | [awstats_setup.html](docs/awstats_setup.html) |
| 설정 설명 | [awstats_config.html](docs/awstats_config.html) |
| 자주 묻는 질문 | [awstats_faq.html](docs/awstats_faq.html) |

---

## 🤝 기여 및 피드백

- **프로젝트 저장소**: [GitHub - hestiacn/vstats](https://github.com/hestiacn/vstats)
- **문제 신고**: [GitHub Issues](https://github.com/hestiacn/vstats/issues)

---

## 💖 감사의 말

웨일스어와 아랍어의 여섯 가지 복수형을 올바르게 번역하는 데 도움을 주신 모든 번역가와 테스터분들께 특별히 감사드립니다. 여러분은 진정한 네트워크 영웅입니다!

---

## 📄 라이선스

`AWStats`는 오픈소스 소프트웨어이며, [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.html#license-text)에 따라 배포됩니다.

---

## 👨‍💻 저자 및 유지보수 정보

**원본 저자**: Laurent Destailleur (1997-2025)
- 프로젝트 창립자, 2025년 11월 업데이트 중단 발표
- [Dolibarr ERP CRM](https://www.dolibarr.org) 프로젝트 리더

**커뮤니티 유지보수**: [hestiacn](https://github.com/hestiacn/vstats)
- 8.1 버전 모던화 리팩토링
- 지속적인 유지보수 및 업데이트

---

## 🔗 관련 링크

- 원본 프로젝트 웹사이트: [https://www.awstats.org](https://www.awstats.org)
- 원본 프로젝트 GitHub 저장소: [eldy/AWStats](https://github.com/eldy/AWStats)
- DB-IP 데이터베이스: [https://db-ip.com](https://db-ip.com)

---

## © 1997-2026 AWStats 팀 | 커뮤니티 에디션은 지속적으로 유지보수됩니다
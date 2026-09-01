# 📋 AWStats 版本更新发布记录

*基于官方文档、SourceForge 记录和作者历史资料整理，部分日期可能与实际不符。如需查看原始更新，请访问 [SourceForge](https://sourceforge.net/projects/awstats/)。*

⚠️ **AWStats 8.0 将是原作者(Laurent Destailleur)维护的最后一个版本，后续版本由社区维护。**

## 🚀 8.x 系列(2026-latest)

### 8.1 - 2026-05-10

### 🔧 修正原文档阅读为本地固定文档

原固定文档需要在更新脚本添加代码实现。这个方案的缺点是：由站点部署者选定语言，导致看见的是我之前最开始添加的仅只有中文和英文的固定文档。

**背景**：当初的想法是看见原作者 `Laurent Destailleur` 这么完善的文档，让看不懂英语的人完全懵逼，导致很多经典案例被淹没在互联网的历史中。

**问题**：在修改的过程中始终达不到我想要的效果，因为需要在一个 HTML 文件内实现多语言需要大量的语言键，这一点也不优雅，完全没有充分利用 po 文件的翻译。

**解决方案**：我在调整 `awstats.pl` 的时候就把所有的文档都写进主程序，现在它实现了根据访问者浏览器请求头显示对应的翻译。`CGI` 动态根据浏览器语言读取，没有完整翻译的文档默认返回英文。

详见[完整本地化](#完整本地化)文档说明。如果您需要为您的语言文档本地化添加翻译，欢迎参考[部分本地化(仅界面)](#部分本地化仅界面)提交贡献！

### 🏷️ 新增功能：自定义品牌展示

> **🚀 vstats: 让统计充满温度**
AWStats 不再只是一个冷冰冰的数据页面。现在，您可以轻松将品牌标识植入报告顶部。配合强大的 73 国语言翻译与 13 种历法适配，让全球用户都能跨越文化与语言的障碍。

### 🚀 品牌化特性

- **全平台适配**：不论是主流 Linux 发行版、各类操作系统，均能完美显示
- **视觉一致性**：支持矢量 SVG Logo，确保在各种分辨率(甚至是 Retina 屏)下都能清晰锐利
- **智能拼接**：系统会自动将您的品牌名与多语言包中的 `Server Management Panel` 字段拼接，实现全语种的品牌本地化

### 🖼️ 适用场景示例

| 类型 | 示例 |
|:---:|:---:|
| 🐧 Linux 发行版 | `RHEL`、`Debian`、`Ubuntu`、`CentOS`、`Arch Linux`、`Fedora`、`Rocky Linux` |
| 🖥️ 操作系统 | `macOS`、`Windows`、`FreeBSD` |
| ☁️ 云主机商 | `Aliyun`、`Tencent`、`AWS`、`Azure`、`Google Cloud` |

### 📝 配置示例

在 AWStats 配置文件（如 `/etc/awstats/awstats.yourdomain.conf`）中添加以下参数：

**💡 快速参考**：您可以直接查看经过优化的 [awstats.tpl 标准配置模板](/make/make/test/awstats/conf/awstats.tpl)，它包含了推荐的品牌化设置与性能优化参数。

```perl
# --- 品牌自定义设置 ---
BrandLink="https://your-company.com"   # 点击 Logo 跳转的网址
BrandPlatform="HestiaCP"               # 您的平台名称（建议英文字符）
StatsUrl="/vstats"                     # AWStats 部署的 Web 路径 用于导航栏的文档链接映射生成
```

### 🌐 自动化本地化效果

**vstats** 会自动将 `BrandPlatform` 嵌入到 73 种母语语境中，实现真正的品牌全球化：

| 语言 | 实时渲染效果预览 |
| :---: | :--- |
| **简体中文** | `HestiaCP 服务器管理面板` |
| **English** | `HestiaCP Server Management Panel` |
| **Kannada** | `HestiaCP ಸರ್ವರ್ ನಿರ್ವಹಣಾ ಫಲಕ` |
| **Georgian** | `HestiaCP სერვერის მართვის පැනელი` |
| **Arabic** | `لوحة إدارة خوادم HestiaCP` |

> 📌 **注**：系统会自动处理不同语言的语序（如阿拉伯语的从右往左显示），确保品牌展示在任何文化背景下都显得专业且地道。

**效果**
- BrandPlatform="HestiaCP" → 显示 **"HestiaCP 服务器管理面板"**
- BrandPlatform="cPanel" → 显示 **"cPanel 服务器管理面板"**
- BrandPlatform="Plesk" → 显示 **"Plesk 服务器管理面板"**
- BrandPlatform="DirectAdmin" → 显示 **"DirectAdmin 服务器管理面板"**
- BrandPlatform="CyberPanel" → 显示 **"CyberPanel 服务器管理面板"**
- BrandPlatform="aapanel" → 显示 **"aapanel 服务器管理面板"**
- BrandPlatform="Portainer" → 显示 **"Portainer 服务器管理面板"**
- BrandPlatform="CasaOS" → 显示 **"CasaOS 服务器管理面板"**
- BrandPlatform="NPM" → 显示 **"NPM 服务器管理面板"**


### ⚠️ 激活条件

为保持页面简洁，品牌展示区域**仅在检测到 `logo.svg` 文件存在且可读时**才会激活。

- **文件位置**：请将您的品牌图标命名为 `logo.svg` 并放置在站点 AWStats 目录下
- **默认链接**：若未配置 `BrandLink`，系统将指向 `https://hestiacp.com`

### 🗓️ **新增 localdate 日历插件** 根据用户语言自动切换历法显示

> **默认开启**，如需关闭请在配置文件中添加 `EnableLocaldatePlugin=0`
> ⚠️ **注意**：日本年号需要手动配置起始日期，详见`plugins/localdate.pm`内注释。
- 🇯🇵 日本年号(令和)：打开 `plugins/localdate.pm` 找到第 80-86 行，删除需要启用的年号前的 `#` 注释，并填写正确的起始年月日(`start_year`、`start_month`、`start_day`)。同时在 `lang/awstats-ja.po` 中添加对应年号翻译键(`calendar_era_2` → `新年号名称`)，后续年号依次类推(`calendar_era_3`、`calendar_era_4`...)
- 🇹🇭 佛历(泰国、柬埔寨、老挝)
- 🇹🇼 民国纪年
- 🇨🇳 甲子纪年(天干地支 + 生肖)
- 🇻🇳 越南甲子纪年(天干地支 + 生肖，兔→猫)
- 🇰🇷 檀君纪年
- 🕌 伊斯兰历(希吉拉历)
- 🇮🇷 波斯历
- 🇲🇲 缅甸历
- 🇳🇵 维克拉姆历
- 🇮🇳 萨卡历
- 🇪🇹 埃塞俄比亚历
- 🇧🇩 孟加拉历
- ✡️ 希伯来历

> 📌 **埃塞俄比亚历**：前 12 个月各 30 天，第 13 个月闰年 6 天平年 5 天。
> 📌 **希伯来历**：19 年 7 闰，闰年增加一个月(Adar I，30 天)，共 13 个月。

如有错误，欢迎在[issues](https://github.com/hestiacn/vstats/issues)提交问题反馈。此功能让报告日期的历法显示自动匹配站点当前语言(如阿拉伯语显示伊斯兰历、日语显示日本年号)，无需额外配置。

#### 🎨 界面与体验
- 📱 采用 HTML5 标准，支持响应式设计，完美适配手机、平板和电脑
- 🌙 新增深色/浅色主题切换功能，支持跟随系统主题，保护眼睛
- 🧭 新增导航菜单，网站部署人员可使用本土化语言查看官方文档
- 📖 新增文档查看器(iframe)，点击菜单链接在页面内查看文档，支持关闭按钮，无需离开当前页
- 😊 国家/地区旗帜图标全面替换为 Emoji，更现代轻量，无需维护图片资源
- 📊 表格样式现代化：圆角边框、悬停高亮效果
- 🎨 使用 CSS 变量定义主题颜色，支持一键切换深色/浅色模式
- 📊 图表引擎重构：移除 PNG 图片依赖，改用纯 CSS 实现横向进度条和竖向柱状图，加载更快、支持主题色自动适配
- 🖼️ 图标系统全面升级：所有 PNG 图标替换为矢量 SVG 格式，支持任意缩放，深色模式下自动适配颜色
- 🎨 操作系统/设备图标库全面升级，新增手机品牌、Linux 发行版、游戏主机、开发工具、文本浏览器等 200+ 识别
- 🔝 新增返回顶部按钮：滚动超过 300px 自动显示，点击平滑返回顶部，支持深色模式和 RTL 布局
- 🕐 小时图表鼠标悬停提示优化：24 小时独立文案，结合 AWStats 特色与人文关怀

### 🌍 语言支持

- 超过300 KB 的语言文件包含完整的本地化语言文档。

| 语言 | 国家/地区 | 旧版格式(Legacy)| 新版格式(Modern)| 更新类型 | 文件大小 | 语言标签(BCP 47)|
|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
| 阿尔巴尼亚语 | 阿尔巴尼亚(Shqipëria)| - | `awstats-sq.po` | ✨ 新增 | 129 KB | BCP 47: `sq` |
| 阿姆哈拉语 | 埃塞俄比亚(ኢትዮጵያ)| - | `awstats-am.po` | ✨ 新增 | 164 KB | BCP 47: `am` |
| 阿塞拜疆语 | 阿塞拜疆(Azərbaycan)| - | `awstats-az.po` | ✨ 新增 | 132 KB | BCP 47: `az` |
| 阿拉伯语 | 阿拉伯国家联盟(الجامعة العربية)| `awstats-ar.txt` | `awstats-ar.po` | 🔄 格式升级 | 678 KB | BCP 47: `ar` |
| 爱尔兰语 | 爱尔兰(Éire)| - | `awstats-ga.po` | ✨ 新增 | 128 KB | BCP 47: `ga` |
| 爱沙尼亚语 | 爱沙尼亚(Eesti)| `awstats-et.txt` | `awstats-et.po` | 🔄 格式升级 | 123 KB | BCP 47: `et` |
| 巴斯克语 | 西班牙/法国(Euskal Herria)| `awstats-eu.txt` | `awstats-eu.po` | 🔄 格式升级 | 126 KB | BCP 47: `eu` |
| 巴西葡萄牙语 | 巴西(Brasil)| - | `awstats-pt-br.po` | ✨ 新增 | 125 KB | BCP 47: `pt-br` |
| 保加利亚语 | 保加利亚(България)| `awstats-bg.txt` | `awstats-bg.po` | 🔄 格式升级 | 175 KB | BCP 47: `bg` |
| 冰岛语 | 冰岛(Ísland)| - | `awstats-is.po` | ✨ 新增 | 121 KB | BCP 47: `is` |
| 波兰语 | 波兰(Polska)| `awstats-pl.txt` | `awstats-pl.po` | 🔄 格式升级 | 124 KB | BCP 47: `pl` |
| 波斯尼亚语 | 波黑(Bosna i Hercegovina)| `awstats-ba.txt` | `awstats-bs.po` | 🔄 重新添加 | 125 KB | BCP 47: `bs`(原代码 `ba` 为国家代码,→ 修正为语言代码 `bs`)|
| 波斯语 | 伊朗(ایران)| - | `awstats-fa.po` | ✨ 新增 | 157 KB | BCP 47: `fa` |
| 布列塔尼语 | 法国布列塔尼(Breizh)| `awstats-br.txt` | `awstats-br.po` | 🔄 格式升级 | 124 KB | BCP 47: `br` |
| 丹麦语 | 丹麦(Danmark)| `awstats-dk.txt` | `awstats-da.po` | 🔄 格式升级+重命名 | 120 KB | BCP 47: `da`(原代码 `dk` 为国家代码,→ 修正为语言代码 `da`)|
| 德语 | 德国(Deutschland)| `awstats-de.txt` | `awstats-de.po` | 🔄 格式升级 | 127 KB | BCP 47: `de` |
| 俄语 | 俄罗斯(Россия)| `awstats-ru.txt` | `awstats-ru.po` | 🔄 格式升级 | 764 KB | BCP 47: `ru` |
| 法语 | 法国(France)| `awstats-fr.txt` | `awstats-fr.po` | 🔄 格式升级 | 591 KB | BCP 47: `fr` |
| 芬兰语 | 芬兰(Suomi)| `awstats-fi.txt` | `awstats-fi.po` | 🔄 格式升级 | 124 KB | BCP 47: `fi` |
| 高棉语 | 柬埔寨(កម្ពុជា)| - | `awstats-km.po` | ✨ 新增 | 219 KB | BCP 47: `km` |
| 荷兰语 | 荷兰(Nederland)| `awstats-nl.txt` | `awstats-nl.po` | 🔄 格式升级 | 573 KB | BCP 47: `nl` |
| 加利西亚语 | 西班牙加利西亚(Galicia)| `awstats-gl.txt` | `awstats-gl.po` | 🔄 格式升级 | 129 KB | BCP 47: `gl` |
| 加泰罗尼亚语 | 西班牙/法国(Catalunya)| `awstats-ca.txt` | `awstats-ca.po` | 🔄 格式升级 | 130 KB | BCP 47: `ca` |
| 捷克语 | 捷克(Česko)| `awstats-cz.txt` | `awstats-cs.po` | 🔄 格式升级+重命名 | 127 KB | BCP 47: `cs`(原代码 `cz` 为国家代码,→ 修正为语言代码 `cs`)|
| 格鲁吉亚语 | 格鲁吉亚(საქართველო)| - | `awstats-ka.po` | ✨ 新增 | 226 KB | BCP 47: `ka` |
| 韩语 | 韩国(한국)| `awstats-ko.txt` | `awstats-ko.po` | 🔄 格式升级 | 568 KB | BCP 47: `ko` |
| 卡纳达语 | 印度卡纳塔克邦(ಕನ್ನಡ)| - | `awstats-kn.po` | ✨ 新增 | 222 KB | BCP 47: `kn` |
| 哈萨克语 | 哈萨克斯坦(Қазақстан)| - | `awstats-kk.po` | ✨ 新增 | 169 KB | BCP 47: `kk` |
| 克罗地亚语 | 克罗地亚(Hrvatska)| `awstats-hr.txt` | `awstats-hr.po` | 🔄 格式升级 | 123 KB | BCP 47: `hr` |
| 拉脱维亚语 | 拉脱维亚(Latvija)| `awstats-lv.txt` | `awstats-lv.po` | 🔄 格式升级 | 127 KB | BCP 47: `lv` |
| 老挝语 | 老挝(ປະເທດລາວ)| - | `awstats-lo.po` | ✨ 新增 | 202 KB | BCP 47: `lo` |
| 立陶宛语 | 立陶宛(Lietuva)| `awstats-lt.txt` | `awstats-lt.po` | 🔄 格式升级 | 129 KB | BCP 47: `lt` |
| 罗马尼亚语 | 罗马尼亚(România)| `awstats-ro.txt` | `awstats-ro.po` | 🔄 格式升级 | 126 KB | BCP 47: `ro` |
| 马拉地语 | 印度马哈拉施特拉邦(मराठी)| - | `awstats-mr.po` | ✨ 新增 | 205 KB | BCP 47: `mr` |
| 马拉雅拉姆语 | 印度喀拉拉邦(മലയാളം)| - | `awstats-ml.po` | ✨ 新增 | 237 KB | BCP 47: `ml` |
| 马来语 | 马来西亚/印尼(Malaysia/Indonesia)| - | `awstats-ms.po` | ✨ 新增 | 119 KB | BCP 47: `ms` |
| 马其顿语 | 北马其顿(Северна Македонија)| - | `awstats-mk.po` | ✨ 新增 | 162 KB | BCP 47: `mk` |
| 孟加拉语 | 孟加拉国(বাংলাদেশ)| - | `awstats-bn.po` | ✨ 新增 | 214 KB | BCP 47: `bn` |
| 蒙古语 | 蒙古(Монгол улс)| - | `awstats-mn.po` | ✨ 新增 | 169 KB | BCP 47: `mn` |
| 缅甸语 | 缅甸(မြန်မာ)| - | `awstats-my.po` | ✨ 新增 | 250 KB | BCP 47: `my` |
| 尼泊尔语 | 尼泊尔(नेपाल)| - | `awstats-ne.po` | ✨ 新增 | 210 KB | BCP 47: `ne` |
| 挪威语(书面)| 挪威(Norge)| `awstats-no.txt` | `awstats-nb.po` | 🔄 格式升级+重命名 | 115 KB | BCP 47: `nb`(原宏语言代码 `no` 细化为书面变体 `nb`,→ 博克马尔)|
| 挪威语(新)| 挪威(Noreg)| - | `awstats-nn.po` | ✨ 新增 | 115 KB | BCP 47: `nn`(尼诺斯克,→ 新挪威语变体)|
| 旁遮普语 | 印度/巴基斯坦(ਪੰਜਾਬ)| - | `awstats-pa.po` | ✨ 新增 | 198 KB | BCP 47: `pa` |
| 葡萄牙语 | 葡萄牙(Portugal)| `awstats-pt.txt` | `awstats-pt.po` | 🔄 格式升级 | 125 KB | BCP 47: `pt`(欧洲葡萄牙语)|
| 日语 | 日本(日本)| `awstats-jp.txt` | `awstats-ja.po` | 🔄 格式升级+重命名 | 635 KB | BCP 47: `ja`(原代码 `jp` 为国家代码,→ 修正为语言代码 `ja`)|
| 瑞典语 | 瑞典(Sverige)| `awstats-sv.txt` | `awstats-sv.po` | 🔄 格式升级 | 119 KB | BCP 47: `sv` |
| 塞尔维亚语 | 塞尔维亚(Србија)| `awstats-sr.txt` | `awstats-sr.po` | 🔄 格式升级 | 166 KB | BCP 47: `sr`(西里尔文)|
| 塞尔维亚语(拉丁)| 塞尔维亚(Srbija)| - | `awstats-sr-latn.po` | ✨ 新增 | 122 KB | BCP 47: `sr-latn`(西里尔文的拉丁转写变体)|
| 僧伽罗语 | 斯里兰卡(ශ්‍රී ලංකාව)| - | `awstats-si.po` | ✨ 新增 | 212 KB | BCP 47: `si` |
| 斯洛伐克语 | 斯洛伐克(Slovensko)| `awstats-sk.txt` | `awstats-sk.po` | 🔄 格式升级 | 126 KB | BCP 47: `sk` |
| 斯洛文尼亚语 | 斯洛文尼亚(Slovenija)| `awstats-si.txt` | `awstats-sl.po` | 🔄 格式升级+重命名 | 124 KB | BCP 47: `sl`(原错误代码 `si` 为国家代码斯洛文尼亚,→ 修正为语言代码 `sl`)|
| 泰米尔语 | 印度/斯里兰卡(தமிழ்)| - | `awstats-ta.po` | ✨ 新增 | 236 KB | BCP 47: `ta` |
| 泰卢固语 | 印度特伦甘纳邦(తెలుగు)| - | `awstats-te.po` | ✨ 新增 | 222 KB | BCP 47: `te` |
| 泰语 | 泰国(ประเทศไทย)| `awstats-th.txt` | `awstats-th.po` | 🔄 格式升级 | 202 KB | BCP 47: `th` |
| 他加禄语 | 菲律宾(Pilipinas)| `awstats-tg.txt` | `awstats-tl.po` | 🔄 格式升级+重命名 | 130 KB | BCP 47: `tl`(原错误代码 `tg` 为塔吉克语,→ 修正为 `tl`)|
| 土耳其语 | 土耳其(Türkiye)| `awstats-tr.txt` | `awstats-tr.po` | 🔄 格式升级 | 127 KB | BCP 47: `tr` |
| 威尔士语 | 英国威尔士(Cymru)| `awstats-cy.txt` | `awstats-cy.po` | 🔄 格式升级 | 124 KB | BCP 47: `cy` |
| 乌克兰语 | 乌克兰(Україна)| - | `awstats-uk.po` | ✨ 新增 | 172 KB | BCP 47: `uk` |
| 维吾尔语 | 中国新疆(شىنجاڭ)| - | `awstats-ug.po` | ✨ 新增 | 176 KB | BCP 47: `ug` |
| 乌尔都语 | 巴基斯坦(پاکستان)| - | `awstats-ur.po` | ✨ 新增 | 158 KB | BCP 47: `ur` |
| 乌兹别克语 | 乌兹别克斯坦(Oʻzbekiston)| - | `awstats-uz.po` | ✨ 新增 | 128 KB | BCP 47: `uz` |
| 西班牙语 | 西班牙(España)| `awstats-es.txt` | `awstats-es.po` | 🔄 格式升级 | 130 KB | BCP 47: `es` |
| 希伯来语 | 以色列(ישראל)| - | `awstats-he.po` | ✨ 新增 | 140 KB | BCP 47: `he` |
| 希腊语 | 希腊(Ελλάδα)| `awstats-gr.txt` | `awstats-el.po` | 🔄 格式升级+重命名 | 184 KB | BCP 47: `el`(原代码 `gr` 为国家代码,→ 修正为语言代码 `el`)|
| 匈牙利语 | 匈牙利(Magyarország)| `awstats-hu.txt` | `awstats-hu.po` | 🔄 格式升级 | 130 KB | BCP 47: `hu` |
| 印地语 | 印度(भारत)| - | `awstats-hi.po` | ✨ 新增 | 204 KB | BCP 47: `hi` |
| 印尼语 | 印度尼西亚(Indonesia)| `awstats-id.txt` | `awstats-id.po` | 🔄 格式升级 | 122 KB | BCP 47: `id` |
| 英语 | 英美等(UK/USA)| `awstats-en.txt` | `awstats-en.po` | 🔄 格式升级 | 527 KB | BCP 47: `en` |
| 意大利语 | 意大利(Italia)| `awstats-it.txt` | `awstats-it.po` | 🔄 格式升级 | 128 KB | BCP 47: `it` |
| 越南语 | 越南(Việt Nam)| `awstats-vi.txt` | `awstats-vi.po` | 🔄 格式升级 | 136 KB | BCP 47: `vi` |
| 简体中文 | 中国(中国)新加坡、马来西亚<br>(含国际组织与全球华人社区)| `awstats-cn.txt` | `awstats-zh-cn.po` | 🔄 格式升级+重命名 | 519 KB | BCP 47: `zh-CN`(原代码 `cn` 为国家代码,→ 修正为 `zh-cn`)|
| 繁体中文 | 台湾(臺灣)香港、澳门<br>及海外华人传统社区 | `awstats-tw.txt` | `awstats-zh-tw.po` | 🔄 格式升级+重命名 | 523 KB | BCP 47: `zh-TW`(原代码 `tw` 为国家代码,→ 修正为 `zh-tw`)|

#### 完整本地化(界面 + 文档)

- ♻️ **重构开发者文档**：原文档为英文硬编码 HTML，现已重构为本地化语言文档。作者 Laurent Destailleur 留下了大量精彩的文档案例和功能说明，记录了 AWStats 从 1997 年至今的开发历程。虽然部分内容可能已不完全适应当前互联网环境(如 Google+ 等过时社交插件)，但仍然是值得参考的开发经验，也是 AWStats 历史的重要组成部分。由于工作量巨大，目前仅完整翻译了以下语言的文档内容：

| 语言 | 代码 | 界面 | 文档 |
|:----:|:----:|:----:|:----:|
| 英文 | en | ✅ | ✅ |
| 简体中文 | zh-cn | ✅ | ✅ |
| 繁体中文 | zh-tw | ✅ | ✅ |
| 俄语 | ru | ✅ | ✅ |
| 阿拉伯语 | ar | ✅ | ✅ |
| 日语 | ja | ✅ | ✅ |
| 法语 | fr | ✅ | ✅ |
| 荷兰语 | nl | ✅ | ✅ |
| 韩语 | ko | ✅ | ✅ |
| 其他语言 | - | ✅ | ❌ |

#### 部分本地化(仅界面)

其他语言的**界面文本**已完成翻译，**文档内容**当前为默认英文版本。

📌 **注**：本节中的示例表格(如生活习惯对比、构词逻辑等)**仅供说明参考**，旨在帮助理解我们推荐以中文作为翻译基准的出发点。所有建议均为非强制，请根据**您的语言习惯和母语**自由选择。

如果您希望为您的语言提供完整的文档翻译，欢迎通过以下方式贡献：

- 📝 提交 [Issue](https://github.com/hestiacn/vstats/issues)告诉我们需求
- 🔧 提交翻译完整的 `.po` 文件到本仓库(合并后即生效)
- **翻译说明**：`.po` 文件由 [DeepSeek](https://www.deepseek.com)辅助生成，如有不准确之处欢迎提交 [Pull Request](https://github.com/hestiacn/vstats/pulls)修正！ 💡 任何建议或想法也欢迎通过 Issues 讨论。
为了文档的准确性，建议使用 `awstats-zh-cn.po` 作为翻译参考。

**为什么不建议您用 `awstats-en.po`？**

 英文作为计算机基础语言，其表达往往简洁直接，毫无关联。如果您以此为蓝本进行二次翻译，很容易丢失中文版本中补充的细节、语境与意境，导致最终内容产生偏差。

中文版本不仅还原了原始文档信息，还补充了大量的背景上下文，是更理想的翻译基准。正如理解中文逻辑能让翻译更透彻一样，我也建议您尝试在生活中改变习惯——经常喝热水(建议从清晨起床后喝第一杯热水)，放弃冰水。这并非玄学，而是经过了东方数千年生活实践验证的“底层性能优化”。

这种习惯养成以后，您会发现很多小感冒甚至不需要去医院，仅靠多喝热水、多休息就能实现自我修复。这不仅能改善您的身体状态，更能让您在处理本地化工作时，感受到文字背后更深层的联系。

| 基础习惯 | 短期体感(Latency)| 长期生命周期(Lifecycle)|
|:---:|:---:|:---:|
| 冰水 | 解渴快、口感爽 | 胃痛胃胀、消化不良、容易拉肚子、身体乏力 |
| 热水 | 慢饮温润、入口柔和 | 消化好、代谢稳、手脚不凉、精力足 |

**为什么选择它作为参考？**

中文是一门逻辑严谨、构词清晰的语言，词汇之间的关联往往一目了然：

| 根词 (Root) | 衍生词 (Derivatives) | 逻辑关联 (Logic) |
|:---:|:---:|:---:|
| 牛 | 牛肉、牛奶、牛皮 | 动物 → 肉类/乳品/衍生品 |
| 羊 | 羊肉、羊毛、羊皮 | 动物 → 肉类/毛料/皮革 |
| 猪 | 猪肉、猪油、猪皮 | 动物 → 肉类/油脂/衍生品 |
| 鸡 | 鸡肉、鸡蛋、鸡毛 | 动物 → 肉类/蛋品/衍生品 |
| 鱼 | 鱼肉、鱼汤、鱼鳞 | 动物 → 肉类/汤品/衍生品 |
| 葡萄 | 葡萄酒、葡萄干、葡萄园 | 原料 → 饮品/果干/种植地 |
| 牛奶 | 奶酪、酸奶、黄油 | 原料 → 发酵/加工制品 |
| 火车 | 火车站、火车票、火车道 | 核心词 → 场所/凭证/设施 |
| 电 | 电脑、电视、电话、电梯 | 能源 → 应用设备/设施 |
| 水 | 水库、水杯、水龙头、水坝 | 物质 → 容器/设施/建筑物 |
| 书 | 书店、书架、书签、书皮 | 核心词 → 场所/物品/配件 |
| 学 | 学校、学生、学习、学费 | 动作/概念 → 场所/人群/行为/费用 |
| 您 | 您的 | 尊称(长辈/上级)→ 所属 |
| 你 | 你的 | 平称(同辈/晚辈)→ 所属 |

这种“以已知推未知”的构词逻辑(看到“羊”就大概知道“羊肉/羊毛/羊皮”的意思)，让中文成为本地化工作中非常理想的参考基准——理解了基础词汇，派生词汇往往不言自明。

如果你对中文感兴趣，不妨通过影视、音乐、书籍、美食或旅行探索这门语言及其背后的文化，相信会为你的本地化工作带来新的灵感与收获。

感谢您选择 AWStats 社区增强版！🎉

#### 🌐 国际化与本地化
- 🚀 语言文件从 GBK 编码的 .txt 格式升级为 UTF-8 编码的 .po 格式，基于 gettext 标准，便于维护和翻译
- 🌍 新增翻译：塞尔维亚语拉丁语言(sr-latn)、塞尔维亚语西里尔语言(sr)
- 📄 配置文件注释全面中文化：所有配置参数增加详细的中英文说明和示例
- 🔧 优化 NotPageList 配置逻辑：新增 UseDefaultNotPageList 选项，设为 1 时自动使用内置完整静态资源列表，避免配置文件重复维护大量扩展名

#### 🗺️ 地理位置
- 🌍 **DB-IP 城市级定位支持**：集成 DB-IP 免费数据库([https://db-ip.com](https://db-ip.com))，提供国家、地区、城市级别的精准访客分布统计,打印的相关数据为英文。
  - **格式升级**：从旧版 `.dat`(GeoIP Legacy 文本格式)升级为 `.mmdb`(MaxMind DB 二进制格式)
  - **旧版痛点**：`.dat` 格式查询速度慢(平均 50-100 微秒)，数据不够完整(约 1MB)，数据多年未更新
  - **新版优势**：`.mmdb` 格式查询速度快 10 倍以上(平均 3-5 微秒)，文件稍大(约 120MB)，每月更新，支持城市级别定位

- 📊 **增强的地理位置显示**：支持显示国家/地区、区域/州、城市三级位置信息，智能处理未知地点(回退到国家代码或 'ip')
- 🚀 **智能缓存机制**：使用 `%TmpDomainLookup` 缓存已查询 IP，避免重复查询；使用 `%TmpDomainFullLocation` 存储完整位置信息(国家、区域、城市)
- 🔧 **插件自动启用**：未加载任何 GeoIP 插件时自动启用 geoipfree 插件，开箱即用

#### 🔒 安全与性能
- 🛡️ 默认添加安全响应头：X-Content-Type-Options、X-Frame-Options、Referrer-Policy
- 🛡️ **XSS 防护全面增强**：`CleanXSS` 函数新增 `javascript:` 协议过滤和事件处理器(onclick/onload 等)清理，完善 HTML 特殊字符转义(`&`、`<`、`>`)
- 🛡️ **URL 解码安全加固**：`DecodeEncodedString` 解码后自动调用 `CleanXSS` 过滤，防止解码绕过 XSS 防护
- 🛡️ **输入过滤强化**：`Sanitize` 函数采用更严格的白名单策略，仅保留安全字符
- 🛡️ **UTF-8 编码安全**：`EncodeToPageCode` 增加错误捕获，编码失败时优雅降级
- 🛡️ **配置文件读取标准化**：所有文件打开操作统一指定 UTF-8 编码，避免编码不一致导致的安全问题
- ⚡ 优化 DNS 缓存机制，减少重复解析，提升处理速度
- 🔄 改进 try/catch 异常处理，避免 JSON 日志解析崩溃
- 📡 增强 IPv6 和 CloudFlare 真实 IP 头部(CF-Connecting-IP)支持

#### 📈 统计功能增强
- 🤖 修复 robots.pm 数据库不一致问题，确保 RobotsSearchIDOrder_listx 与 RobotsHashIDLib 条目数匹配
- 🕷️ 新增 AI/ML 爬虫识别：ClaudeBot、GPTBot、OAI-SearchBot、PerplexityBot、Applebot-Extended、Google-Extended、Amazonbot、Anthropic-ai、cohere-ai、AI2Bot、YouBot 等
- 📊 优化爬虫分类，区分 AI 爬虫、社交媒体爬虫、SEO 工具、监控服务
- 🔧 移除重复的机器人规则(AhrefsBot、Exabot、XoviBot)，消除数据库校验错误
- 🎨 为各爬虫添加专属图标和友好描述，报表更直观
- 📈 下载统计模块重构：支持断点续传(206 状态码)识别、移动端下载统计、流媒体播放与下载智能区分
- 📦 扩展名配置外部化：下载文件和流媒体扩展名支持从配置文件读取，便于自定义
- 📱 移动端检测增强：新增 HarmonyOS(鸿蒙)、OpenHarmony 识别
- 📊 数据文件注释国际化：所有历史数据文件的字段说明支持多语言显示
- 🗂️ NotPageList 静态资源列表现代化：补充 svg、webp、avif、woff2 等现代格式
- 📊 新增 mime 类型详细说明：为 svg、webp、avif、woff2、vue、wasm、jsx、tsx 等现代格式添加历史背景说明

#### 🛠️ 技术改进
- ⬆️ 最低 Perl 版本要求从 5.007 提升至 5.20
- 🔧 启用 use warnings 和 use utf8，统一 UTF-8 编码输出
- 📚 帮助信息更新，增加生成中文报告等实用示例
- 📋 新增版本更新历史页面 awstats_changelog.html，按版本分类展示
- 🐛 修复未声明变量 $lang 和 $dir_attr 导致的编译错误
- 🔨 修正 Try::Tiny 语法错误，确保 try/catch 正确解析
- 📐 单独控制 IP 和机器人列表表格第一列宽度，避免布局变形
- 🚪 文档查看器默认不占用空白区域，点击链接后动态显示，支持关闭按钮
- 🌏 修正语言加载逻辑，auto 模式下正确回退到英文
- 🧹 移除过时的 PrintCLIHelp，统一使用 print_help 函数，现在您可以使用`awstats.pl -h`触发帮助说明。


### 8.0 - 2025-08-26
- 👋 *这是开发者(Laurent Destailleur)维护的最后一个版本*
- 🔄 改进 CSS 样式表
- 📋 更新 robots.pm 数据库
- 🌍 修复 #248
- 📖 将繁体中文翻译迁移到 UTF-8 编码
- 🌳 排序树：检查键是否存在，不关心其值
- 📋 支持处理 JSON 格式日志
- 🔧 修复 NotPageList 的默认设置
- 📋 添加请求时间报告
- 📋 修复文档中的错误链接
- 🗑️ 从 robots.pm 中移除原生 Android 和原生 iOS/OSX 浏览器的 User Agent
- 🔧 修复 robots.pm 中 GPTBot 识别错误的问题
- 🔧 修复乌克兰语翻译的编码问题

---

## 📦 7.x 系列(2011-2023)

### 7.9 - 2023-01-17
- 🪟 添加 Windows 11 和 Android 13 操作系统检测
- 🇭🇺 更新匈牙利语翻译并迁移到 UTF-8
- 🛡️ 修复跨站脚本漏洞(CVE-2020-35176)
- 🔧 将硬编码文本替换为 $Message 变量(月、日、小时)
- 📱 添加 Android 11/12、macOS 11/12 检测
- 🇩🇪 更新德语翻译
- 🔄 改进换行符替换逻辑，同时支持 HTML 和 XHTML
- 🤖 添加一些新机器人和手机浏览器，修复 robots.pm 中的错误
- 📂 仅在专用的 awstats 目录中查找配置
- 📧 处理 SRS 邮件地址
- 🔒 修复 #195/CVE-2020-35176
- 🌍 修复 geoip2_country 插件问题
- 🖥️ 添加 HaikuOS 和基于 Safari 的 WebPositive 浏览器支持
- 🔨 添加缺失的 td 标签
- 🇹🇯 添加塔吉克语支持

### 7.8 - 2020-04-30
- 🗄️ 新增 DatabaseBreak 模式选择：月、日、小时
- 📋 更新 HTTP 状态码
- 📁 添加更多文件类型
- 📖 更新 README.md
- 🌍 修复 geoip2 格式化问题
- 🔍 修复 search_engines.pm 中的错误条目
- 🪟 修复 Windows 下的 geoip2 插件
- 🤖 更新 robots.pm，添加多个新机器人：PiplBot、um-IC/um-LN、arcemedia、bit.ly、bidswitchbot、bnf.fr_bot、contxbot、flamingo、getintent、laserlikebot、mappy、mojeek、serendeputy、trendiction、yak、zoominfobot
- 🔨 修复 #104
- 📝 改进 Markdown 可读性
- 📅 更新版权年份
- 🔒 改用 https 链接
- 🔗 修复 Perl 下载链接
- ⏱️ 新增 %time6 标签，支持某些 IIS 日志格式
- 📊 修复 geoip2 表格格式错误
- 🍏 添加 macOS DMG 和 PKG 文件支持
- 🖥️ 修复 HTTP 206 状态码的浏览器检测
- 💻 支持 macOS 10.13/10.14，改进图标图片压缩
- 📈 使用前 5 名作为图表基准
- 🧹 清理 geoip2 和 geoip2 city 模块：正确转换 DNS 名称、仅查询公网 IP、HTML 转义输出、代码改进
- 🗜️ 无损压缩 PNG 图片约 33%
- 🤖 添加机器人：The Knowledge AI
- 🔄 修复 RobotsSearchIDOrder_listx 记录数不一致错误
- ⚡ 优化 OptimizeArray 函数
- ⏰ 添加 UptimeRobot
- ⚙️ 修复配置文件中的语法错误
- 📏 忽略超过 80 字符的搜索短语
- 🔧 修复 404 详情页不更新问题
- 🔤 解码 RFC 3986 未保留字符
- 🔨 修复 #80
- ⚠️ 禁用 Perl > 5.6 的嵌套包含警告
- 🌐 更新 domains.pm
- 🔍 修复 search_engines.pm 中的两个无效条目
- 💾 TB 单位格式化
- ➗ 修复除以零错误
- 🔨 修复 #79
- 🛠️ 改进 awstats_buildstaticpages.pl 的错误处理
- 🔨 修复 #90
- 🚫 排除私有 IP 地址(GeoIP2::Reader 不支持)
- 🧹 仅清除已保存部分的数据
- 🏙️ 改进城市插件功能
- 📊 修复 ShowHost 部分的问题
- 🌍 初步实现 GeoIP2 City 查询
- 🇮🇱 更新希伯来语文件
- 🔍 改进雅虎检测
- 📱 在 awstats_misc_tracker.js 中添加设备像素比
- 🤖 基于 7.7 版本的 robots.pm 添加 37 个新机器人
- 🔄 移动 oBot 条目以避免被错误识别
- 🏁 缺失 Sint Maarten 旗帜
- 🌍 修复 #76 - 国家名称错误
- 📝 修复 UTF BOM 文件
- 🛡️ 修复 cPanel 安全团队报告的漏洞
- 🧪 添加更多测试

### 7.7 - 2018-01-07
- 🛡️ 安全修复：CVE-2017-1000501
- 🔒 安全修复：参数清理缺失
- 🔧 修复包含空格的 URL 的 LogFormat=4
- 🪟 修复外部引荐网站链接的 window.opener 漏洞
- 📝 添加 methodurlprot 定义日志格式
- 🔄 添加动态 DNS 查找
- 🌐 修复 Edge 支持

### 7.6 - 2016-12-07
- 🛡️ 安全修复：DirLang 参数不允许使用 |
- 🔒 安全修复：更严格的 AWSTATS_ENABLE_CONFIG_DIR 使用规则
- 🤖 更新 robots 数据库
- 💻 修复 OS 数据库
- 📚 更新/修复文档
- 🏁 添加缺失的 el 国家旗帜
- 📁 部分支持 pure-ftpd 统计格式
- 🍏 添加对 macOS Sierra 的支持
- 🔤 将 Web 字体添加到默认 NotPageList，支持 GPX 和 JSON 文件

### 7.5 - 2016-04-29
- 🐪 兼容 Perl 5.22
- 🌐 支持 Edge 浏览器版本检测
- 🤖 更新 robots 数据库
- 🔤 将 eot/woff/woff2 添加到 mime.pm 作为字体
- 🖼️ 将 .svgz 添加到图片列表
- 🚫 从搜索引擎中排除 groups.google
- ⏱️ 添加 %time5 标签，支持带时区的 ISO 时间格式
- 🔄 添加 DynamicDNSLookup 选项，在输出时进行 DNS 查找而非日志分析时
- 📊 增加 MaxRowsInHTMLOutput 默认值

### 7.4 - 2015-11-11
- 🌍 添加 geoip6 插件，支持 IPv4 和 IPv6
- ☁️ 支持 Amazon AWS 日志文件(使用 %time5 标签)
- 🔧 修复某些 .pl 脚本的权限问题
- 🔨 修复 #205：GetResolvedIP_ipv6 不删除尾部点
- ⚠️ 修复 #496：工具脚本应将警告和错误输出到 STDERR
- 🔗 修复 #919：引荐未被跟踪的问题
- 📝 修复 #921：geoip_generator.pl 帮助文本错误
- 🐛 修复 #909：awstats_buildstaticpages.pl 调试输出过多
- 💥 修复 #680：传递给 Time::Local 的无效数据导致全局销毁
- 🛡️ 修复 CVE-2006-2237

### 7.3 - 2015-11-11
- 📌 添加命令行选项 -version
- 🌍 改进 geoip 模块的错误管理
- 🗄️ 更新 domains、robots 和 search engines 数据库
- 📱 #877：AWStats 支持 Windows 8 和 iOS
- 🪟 检测 IE11 和 Windows 8.1
- 🔗 修复使用 builddate 选项时静态链接错误
- 🌐 恢复 Opera 浏览器版本检测
- 🏙️ #838：GeoIP Cities 页面无法工作
- 🖼️ 添加缺失的图标
- 🔒 #881：避免 graphgooglechartapi 模块的 http/https 混合警告
- 🔧 #918：HTMLShowLogins 中使用 $MinHit{'Host'} 而非 $MinHit{'Login'}
- 📦 将版本系统迁移到 SourceForge Git

### 7.2 - 2013-07-09
- ⚖️ 升级许可证到 GPL v3+
- 📚 更新文档
- ☁️ 支持 modCloudFlareIIS
- 🖥️ 修复 Webmin 1.53 的布局问题
- 🔗 更新 maxmind 的失效链接

### 7.1.1 - 2013-03-08
- 🪟 添加 Windows 8 检测
- ⏱️ 支持 ISO 日期时间的 %time5
- 🐪 修复 Perl 5.14 的问题

### 7.1 - 2012-12-20
- 🌍 更新翻译
- 🌐 更新浏览器列表
- 🔧 添加 nginx 配置示例
- 📦 添加 Debian 包的一些补丁
- 📛 将文档域名重命名为 awstats.org
- 🔑 awredir.pl 可以不使用 md5 密钥参数
- 📊 awstats_buildstaticpages.pl 支持 databasebreak 选项
- 🔗 添加 rel=nofollow 链接
- 🧩 添加 AddLinkToExternalCGIWrapper 选项
- 🛡️ 修复 awredir.pl 的安全问题
- 🇬🇧 修复 googlechart api 中 uk 的大小写问题
- 🐪 修复与最新 Perl 版本的兼容性

### 7.0 - 2011-01-08
- 🪟 检测 Windows 7
- 🔢 根据语言格式化数字
- 📁 更多 MIME 类型
- 🌍 添加 geoip_asn_maxmind 插件
- 🗺️ GeoIP Maxmind 城市插件支持覆盖文件
- 📊 添加 graphgooglechartapi 使用在线 Google Chart API 生成图表
- 🗺️ 可显示国家地图
- 🧹 代码清理和优化
- 🚫 添加参数忽略缺失的日志文件
- 🤖 更新 robots 数据库
- 📥 添加下载跟踪功能
- 🧩 WrapperScript 参数支持带参数的包装器
- 🏢 支持在 Dolibarr ERP/CRM 插件中使用 AWStats
- 🖥️ 修复 Webmin 模块与新版本的兼容性
- 🛡️ 安全修复(LoadPlugin 目录遍历)
- 🔒 安全修复(限制配置目录访问)

---

## ⚙️ 6.x 系列(2004-2009)

### 6.95 - 2009-10-28
- 🛡️ 修复 awredir.pl 安全问题，默认添加安全密钥
- 🧹 增强参数清理功能
- 📋 在数据文件头中添加配置文件名
- 🌐 添加 Chrome、Opera、Safari、Konqueror 浏览器的版本详情
- 📱 添加 AdobeAir 检测
- 🤖 大幅更新浏览器、机器人和搜索引擎数据库(包括 Bing)
- 🔍 大幅提升机器人检测能力
- 🇫🇷 添加布列塔尼语
- 🖥️ 改进 Safari 版本检测
- 🗺️ 为 geoip maxmind 模块添加子页面
- 🇵🇱 修复波兰语文件中的拼写错误
- ⚠️ 修复 geoipfree 的警告
- 🔧 修复机器人检测问题

### 6.9 - 2008-12-28
- 📧 maillogconvert.pl 支持 DSN，避免重复计数
- 📊 logresolvemerge.pl 支持 FreeRADIUS 日志
- 🛑 添加 stoponfirsteof 选项
- 🔄 添加 host_proxy 标签支持
- ⭐ 重命名为 Add to favourites
- 🤖 更新机器人和搜索引擎数据库(添加 Chrome、改进 Vista、WII 检测等)
- 🌍 更新语言文件
- 🗺️ 修复 maxmind citi、org 和 isp 插件
- 🛡️ 修复多个安全问题
- 🖼️ 添加缺失的图标
- 🐪 *需要 Perl 5.007 或更高版本*

### 6.8 - 2008-07-20
- 👥 添加 OnlyUsers 选项
- 📡 支持 RPC 请求跟踪
- 📝 HTMLHeadSection 支持换行符
- 🤖 添加 MetaRobot 选项
- 🔍 大幅提升机器人检测能力
- 🪟 改进 Windows 操作系统检测
- ➕ 在额外部分中添加 HOSTINLOG 条件
- 📄 修复 XML 输出的问题
- 🐛 修复 awstats_configure.pl 脚本的 bug

### 6.7 - 2007-07-07
- 📅 完全支持 -day 选项，可为每天构建不同的报告
- 🏷️ 添加 virtualenamequot 标签
- 🚫 添加 NotPageList 选项
- 🌐 添加 .jobs 和 .mobi 域名
- 🐛 修复 awstats_configure.pl 的次要 bug
- 🌍 更新语言文件
- 🌐 更新浏览器数据库

### 6.6 - 2006-12-24
- 🐪 所有 geoip 插件支持 PurePerl 版本
- ➕ 可在 extra 部分使用 vhost
- 🌐 AllowAccessFromWebToFollowingIPAddresses 参数支持 IPv6
- 🗂️ 添加 svn 系列到浏览器检测
- 🌍 支持 IE7
- 🔇 移除一些 Perl 警告
- 🛡️ 修复 XSS 攻击漏洞
- 🌏 更新语言文件
- 🌐 更新浏览器数据库

### 6.5 - 2005-12-24
- ⚡ logresolvemerge.pl 合并大量日志文件时速度提升 30 倍
- 🐧 添加 Linux 和 BSD 发行版检测
- 🚫 添加 SkipReferrersBlackList 选项排除垃圾引荐
- 📰 在机器人数据库中添加 RSS 订阅器/阅读器
- 🗄️ 添加 databasebreak 选项
- 🗺️ geoip_cities 插件在有数据时报告地区
- 📱 LevelForBrowsersDetection 可接受 allphones 值
- 🔄 LogFormat=2 可动态检测日志格式变化
- 📋 添加 SectionsToBeSaved 选项
- 🌐 添加 Epiphany 浏览器检测
- 🔗 awredir 支持 ftp、https 等协议
- 📧 修复 Gmail 点击计数问题
- 🔨 修复多个 bug 和 XSS 问题
- 🛡️ 修复 XSS 问题

### 6.4 - 2005-02-25
- 📊 添加 ShowSummary 选项
- 🌍 启用 GeoIP 插件时在主机报告中添加列
- 🔄 LogFormat=2 自动检测日志格式变化
- 🔓 修复安全漏洞(可读取日志文件内容)
- 🛡️ 修复可能的 DoS 攻击漏洞
- 🎥 修复媒体服务器分析的错误
- 🪟 修复 Windows 服务器上的 configdir 选项问题
- 🏁 添加缺失的巴斯克语旗帜图标

### 6.3 - 2005-02-25
- 🌍 添加 geoip_isp_maxmind 和 geoip_org_maxmind 插件
- 🦊 显示 Firefox 版本详情
- 🔍 支持检测在 URL 中存储搜索关键词的搜索引擎
- 🔓 移除两个安全漏洞
- 🗺️ 修复 geoip_city_maxmind 插件问题
- 📁 修复文件类型表格的显示
- 🌐 修复翻译词条损坏问题
- 📄 修复 XML 解析错误

### 6.2 - 2004-11-06
- ⚙️ awstats_updateall.pl 添加 -excludeconf 选项
- ➕ 允许插件在菜单中添加条目
- 🔄 允许插件在更新过程中编译数据
- 🗺️ 添加 geoip_region_maxmind 和 geoip_city_maxmind 插件
- 📧 maillogconvert.pl 支持 postfix 2.1
- ⚡ 小幅速度提升
- 🚫 统计 JavaScript 禁用的浏览器
- 🏷️ 支持在日志格式中使用 %extraX 标签
- 📁 分析 FTP 日志时支持 put 方法
- 🔨 修复多个 bug

### 6.1 - 2004-05-15
- 📄 BuildHistoryFormat 支持 XML 格式
- ⏱️ 添加 %time4 标签支持 Unix 时间戳
- 🦊 在浏览器数据库中添加 Firefox
- 🔗 添加 IncludeInternalLinksInOriginSection 参数
- 📑 PDF 检测支持 PDF 6
- 📧 maillogconvert.pl 自动调整年份
- 💡 为邮件报告添加工具提示
- ❌ 在摘要中添加失败邮件数
- 🔤 AllowAccessFromWebToFollowingAuthenticatedUsers 不再区分大小写
- 🌐 添加 Camino 浏览器检测
- 🔨 修复多个 bug

### 6.0 - 2004-01-25
- ⚡ 速度提升 10-20%
- 🐛 添加蠕虫报告
- 📄 支持 XML 输出
- 🔤 添加 decodeUTFkeys 插件
- ⚙️ 添加 configure.pl 脚本
- 🔄 代码重写，更易理解和维护
- 🔍 新的搜索引擎数据库，支持多个匹配 ID
- ➕ 支持在 ExtraSection 中使用 UA 和 HOST 字段
- 🔁 支持从右到左的语言
- 📊 添加文件类型百分比列
- 🔨 修复多个 bug

---

## 🔧 5.x 系列(2002-2003)

### 5.9 - 2003-09-22
- 🖥️ Webmin 模块更新到 1.1
- 📅 添加 AllowFullYearView 参数
- 🌍 年份条目在组合框中显示本地化文本
- 📧 maillogconvert.pl 支持一些交换格式
- ⚙️ awstats_buildstaticpages.pl 的 -noloadplugin 选项可接受逗号分隔列表
- 📨 支持 qmail 日志的错误记录
- 🔨 修复多个 bug

### 5.8 - 2003-09-16
- 🔧 修复 mod_deflate 压缩报告
- 📊 修复主机图表中其他行的列数错误
- 🔍 修复 uabracket 和 refererquot 的解析问题
- 🖥️ 添加 Webmin 模块
- ➕ 增强 Extra 功能，添加 ExtraSectionFirstColumnFormatX 等参数
- 🏷️ 添加 %lognamequot 标签
- 👥 添加 OnlyUserAgents 参数
- 🛠️ 添加 awredir.pl 工具
- 📊 添加集群报告

### 5.7 - 2003-08-23
- 📝 添加 rawlog 插件
- 🔍 在完整列表报告页添加动态排除过滤器
- 📧 添加 maillogconvert.pl 用于分析邮件日志
- ➕ logresolvemerge.pl 添加 -addfilenum 选项
- ⏱️ 添加 -updatefor 选项限制每次更新的行数
- 🎥 支持 Darwin 流媒体服务器
- 🔥 添加 Firebird 浏览器检测
- 📄 awstats_buildstaticpages.pl 可构建 PDF 文件
- ⚙️ 改进插件加载失败的处理
- 🏷️ 添加 LogType 参数

### 5.6 - 2003-06-28
- 🗜️ 支持 mod_deflate 压缩报告
- 🌐 改进浏览器检测
- 🔣 可为列表参数添加正则表达式值
- 🎨 StyleSheet 参数完全生效
- 🤖 添加 meta 标签 robots noindex,nofollow
- 📊 添加杂项图表，报告浏览器对 Java、Flash、Real、QuickTime、WMA、PDF 的支持
- ⚡ 改进更新过程，速度更快
- 🦊 改进在 Netscape/Mozilla 浏览器上的显示

### 5.5 - 2003-05-25
- 📱 添加屏幕尺寸报告
- 💻 按系列分组操作系统，添加详细版本图表
- 🔍 改进 404 错误管理
- 🌍 添加 geoipfree 插件
- 👤 添加 userinfo 插件
- 📅 月份参数可接受 -month=D 格式
- ⚡ 优化代码大小和 HTML 输出
- 🌐 添加 ipv6 插件
- 📊 拆分月份摘要和月份天数图表为两个独立图表
- 🔗 添加 -staticlinksext 选项
- 📧 支持 QMail

### 5.4 - 2003-02-23
- 🌍 Lang 参数接受 auto 值
- 🎥 部分支持 realmedia 服务器
- 🛠️ 添加 urlaliasbuilder.pl 工具
- 🔗 ExtraSection 第一列支持 URL
- #️⃣ 添加 URLWithAnchor 参数
- 💡 将工具提示功能导出为插件
- ⏱️ 在访问时长报告中添加平均时长和百分比
- 📦 logresolvemerge.pl 可读取 .gz 或 .bz2 文件
- 📁 为文件类型报告添加图标和 MIME 标签
- ➕ 添加多个数据数组参数
- 🪟 Whois 信息显示在居中弹出窗口
- 🎨 改进浏览器报告的外观

### 5.3 - 2003-01-02
- 📤 添加 awstats_exportlib.pl 工具
- 🌍 为域名/国家报告添加完整列表视图
- 📧 为邮件发送者/接收者图表添加完整列表和最后访问视图
- ⚡ 为 GeoIP 插件添加内存缓存
- 🔤 添加 AuthenticatedUsersNotCaseSensitive 参数
- 🚀 使用 ExtraSection 时速度提升
- 🔄 更新机器人、操作系统、浏览器、搜索引擎数据库
- 🖥️ 添加 X11 为未知 Unix 操作系统，添加 Atari 操作系统

### 5.2 - 2002-12-03
- 🔗 添加 urlalias 插件
- 🌍 添加 geoip 插件
- 📧 支持 postfix 邮件日志
- 📊 在日期数据数组底部添加总计和平均行
- 🔍 在主机和引荐者页面添加动态过滤器
- 🚫 移除值为 0 时的 Bytes 文本
- 📦 减小主页大小
- 👥 添加 OnlyHosts 参数
- ⚠️ 添加 ErrorMessages 参数
- 🐛 添加 DebugMessages 参数
- 🔣 添加 URLQuerySeparators 参数
- 🔒 添加 UseHTTPSLinkForUrl 参数
- 🇦🇱 添加阿尔巴尼亚语
- 🇧🇬 添加保加利亚语
- 🏴󠁧󠁢󠁷󠁬󠁳󠁿 添加威尔士语
- 🇸🇨 添加塞舌尔旗帜

### 5.1 - 2002-10-26
- 📁 改进对 FTP 日志文件的支持
- 📧 改进对邮件日志文件的支持
- 🎥 可分析流媒体日志文件(Windows Media Server)
- 📅 在 CGI 模式下添加月份和年份选择框
- 📊 月份和天数的数据值直接显示在主页图表下方
- 🔧 ShowxxxStats 参数可接受代码决定显示哪些列
- 🚫 添加 SkipUserAgents 参数
- 🔤 添加 URLNotCaseSensitive 参数
- 🔗 添加 URLWithQueryWithoutFollowingParameters 参数
- 🔄 添加 URLReferrerWithquery 参数
- 🏷️ 添加多个日期标签
- 🛡️ 修复日志文件中包含二进制字符时的分析停止问题

### 5.0 - 2002-10-06
- 🔄 完全重写更新过程和历史文件读/写代码
- 🔄 与之前版本(3.x 或 4.x)兼容
- ⚡ 可通过 -migrate 命令迁移旧历史文件以获得速度提升
- 🔧 修复使用不同偏移标签时的错误
- 🔐 CreateDataDirIfNotExists 创建的目录权限从 0666 改为 0766
- 🌐 跟踪浏览器的详细主次版本
- 🤖 为机器人和错误添加带宽报告
- 📦 支持 DNS 缓存文件进行 DNS 查找
- 🧩 添加插件支持和多个工作插件
- 🖼️ 使用框架报告(UseFramesWhenCGI 参数)
- 📉 减少全局变量数量
- 📄 DefaultFile 参数可接受多个值
- 🤖 添加所有机器人和最后机器人完整列表报告
- 👤 添加所有登录和最后登录完整列表报告
- 🚪 添加 URL 入口和出口完整列表报告
- 🛡️ 添加 AllowAccessFromWebToFollowingIPAddresses 参数
- 🔣 添加 LogSeparator 参数
- 🔒 添加 EnableLockForUpdate 参数
- 🔤 添加 DecodeUA 参数
- 🏷️ 添加 %WY 标签

---

## 📊 4.x 系列(2002)

### 4.1 - 2002-07-09
- ⌨️ -logfile 选项可在命令行任意位置使用，支持文件名中的空格
- 🧠 修复 logresolvemerge.pl 的内存泄漏问题
- 📉 减少对非完全排序日志文件的丢弃记录数
- 🏷️ 添加 %virtualname 标签，可共享同一日志文件用于多个虚拟服务器
- 🔧 LogFile 参数中可使用管道
- 🔗 添加引荐搜索引擎和引荐页面的完整列表
- 🔍 同时报告关键词和关键短语
- 🚪 报告出口页面
- ⏱️ 报告访问时长
- 📁 awstats_buildstaticpages.pl 添加 -dir 选项

### 4.0 - 2002-04-21
- ⚠️ *警告：与旧历史文件不兼容*
- ⚡ 提高速度，减少大型网站的内存使用
- 🌐 未解析的 IP 现在像已解析的一样处理
- 🖼️ 在浏览器图表中添加图标
- 📋 个性化日志格式也支持制表符分隔
- 🔒 新的安全/隐私管理方式和参数
- 🤖 在浏览器图表中标记抓取器浏览器
- 📊 在页面/URL 报告图表中添加平均文件大小
- ⚙️ 可在配置文件中使用动态环境变量
- 📝 关键短语列表可完整查看
- 🧩 添加 WrapperScript 参数
- 📁 添加 CreateDirDataIfNotExists 参数
- ✅ 添加 ValidHTTPCodes 参数
- 📏 添加 MaxRowsInHTMLOutput 参数
- 🔗 添加 ShowLinksToWhoIs 参数
- 🔗 添加 LinksToWhoIs 参数
- 🎨 添加 StyleSheet 参数
- 🔗 添加 -staticlinks 选项
- 🛠️ 添加 common2combined.pl 工具
- 🛠️ 添加 awstats_buildstaticpages.pl 工具

---

## 🎨 3.x 系列(2001)

### 3.2 - 2001-12-29
- ⚡ 速度提升 19%
- 🔧 修复历史文件损坏问题
- 🛡️ 安全修复：当 AllowToUpdateStatsFromBrowser 关闭时，无法通过 URL 更新
- 🏷️ 添加各种标签用于动态日志文件名
- 🚫 添加 NotPageList 参数
- 💾 添加 KeepBackupOfHistoricFiles 选项
- 📊 访问次数在天数统计中可见
- 📅 添加星期统计
- 📁 添加文件类型统计
- 🚪 添加入口页面统计
- 🗜️ 添加 Web 压缩统计(mod_gzip)
- 👤 添加认证用户/登录统计
- 📋 添加参数选择主页中显示的报表
- 🔗 添加 URLWithQuery 选项
- 🏁 ShowFlagLinks 可接受所有需要的旗帜列表
- 🖥️ 支持标准 ISA 服务器日志格式
- 🛠️ 添加 logresolvemerge 工具
- 📝 添加 HTMLHeadSection 参数
- 🔢 添加 NbOfLinesForCorruptedLog 参数

### 3.1 - 2001-09
- ⚡ 大幅提高更新速度
- ⚡ 大幅提高浏览器查看统计的速度
- 🧠 减少内存使用
- 📂 AWStats 在多个目录中搜索配置文件
- 📄 可分析 NCSA common 日志文件
- 🕒 最后访问列表
- 📊 URL 分数的完整列表
- 📅 日期格式可根据国家选择
- 🌍 添加 DirLang 参数
- ⏱️ 添加 Expires 参数
- 🔗 添加 LogoLink 参数
- 🎨 添加 color_weekend 选项
- ⚙️ 添加 -update 和 -output 选项
- 🔍 添加 -showsteps 选项
- 🔧 修复操作系统检测
- 📱 添加 WAP 浏览器到数据库

### 3.0 - 2001-07-22
- 🎨 全新外观
- 📅 添加每日页面、点击和字节报告
- 🔄 AWStats 可使用自己的转换数组进行反向 DNS 查找
- 🚫 添加 SkipDNSLookupFor 选项
- 📁 添加 OnlyFiles 选项
- 📋 支持个性化日志格式
- ⚡ 默认不在浏览器读取统计时更新，添加立即更新按钮
- 💡 工具提示现在也适用于 Netscape 6、Opera 等浏览器
- 🌐 更新浏览器数据库，添加音频浏览器
- 💻 更新操作系统数据库
- 🤖 更新机器人数据库
- 🌍 支持新域名
- 🏁 添加缺失的旗帜图标
- 🔧 重写 UnescapeURL 函数
- 📊 字节自动缩放
- 🎨 修复样式问题
- 🌐 添加新语言

---

## 🔄 2.x 系列(2001)

### 2.24 - 2001-03-09
- ⏱️ 可在 LogFile 参数中动态包含当前年月日时
- ⌨️ 命令行也可选择月份、年份和语言
- 🔒 https 请求正确报告
- ⚙️ 初始化参数以避免 mod_perl 的缓存问题
- 🛡️ 修复参数检查以避免 XSS 攻击
- 🏁 添加多个国家旗帜
- 🔍 新的关键词检测算法
- 📝 添加报告关键词为独立词或完整搜索字符串的选项
- 🇬🇷 添加希腊语
- 🇨🇿 添加捷克语
- 🇵🇹 添加葡萄牙语翻译
- ⚡ 更快的配置文件解析
- 🪟 区分 Windows NT 和 Windows 2000
- 🌐 添加 OmniWeb 和 iCab 浏览器

### 2.23 - 2001-02-10
- ⚙️ 使用配置文件
- 📁 可处理旧日志文件
- 📅 按月统计现在正常工作
- 📅 旧年份也可从 AWStats 报告页面查看
- 📂 可选择工作目录
- 🗑️ 添加 PurgeLogFile 选项
- 📝 awstats.pl 可重命名为 awstats.plx 并仍正常工作
- 🔗 命令行生成的统计页面链接正确
- 📅 添加选择全年视图的链接
- 📊 域名和页面报告按页面排序
- 🔄 自动禁用已完成的 DNS 查找
- ➕ 可在 awstats 末尾添加自定义 HTML 代码
- 🇮🇹 添加意大利语
- 🇩🇪 添加德语
- 🇵🇱 添加波兰语

### 2.1 - 2001-01-01
- 🔄 AWStats 将 myserver 和 www.myserver 视为相同
- 🔧 修复唯一访问者计数器过高的问题
- 📦 添加 ArchiveLog 参数
- ❓ 区分未知浏览器和未知操作系统
- 🤖 机器人统计与访问者分开
- 🔍 改进的关键词检测算法
- 🕒 添加每个主机的最后连接时间
- 📋 添加 HTTP 404 错误的 URL 列表
- 📊 添加页面、点击和 KB 统计
- 🎨 添加颜色和链接
- 🪟 支持 IIS
- ⚡ 代码更清晰、更快
- 🖼️ 图像为 .png 格式
- 🌐 4 种语言

---

## 🌟 1.x 系列(2000)

### 1.0 - 2000-05-02
- 🎉 首次在 SourceForge 公开发布 1.0 版本
- 📄 支持 Apache 日志格式
- 📊 基本统计功能：访问量、页面数、文件数

---

## 📜 早期开发阶段(1995-1999)

### 1999 - 开源前夜
- 🚀 标准化架构，引入 lang/ 字典系统(初步确立 GBK/ISO 编码规范)，以适应不同服务器环境，完成从个人工具向标准化产品的最后蜕变
- 🔍 识别增强：大幅扩充爬虫识别库
- 🎯 模式固定：完善 CGI 脚本运行模式
- 👥 社区内测：在小范围同行中进行测试，根据反馈完成代码清理和文档撰写

### 1998 - 功能深耕
- ⚙️ 进入高频内部私有迭代
- 🔄 确立“增量更新”架构，引入中间数据库文件，确保大数据量下统计不占用服务器实时资源
- 💻 新增操作系统、浏览器类型及 HTTP 状态码识别能力
- 🔌 利用 Perl 跨平台特性，测试 Unix/Linux 和 Windows 环境兼容性

### 1997 - 项目元年
- 🌟 官方文档公认起点，从零散脚本向分析引擎质变
- 📊 确立静态报告生成模式，首次将分析结果输出为带图形界面的 HTML 页面
- 🔍 开始建立搜索引擎与机器人识别规则库
- 📈 受益于 Common Log Format 标准化，脚本开始具备通用化基础

### 1995-1996 - 概念萌芽
- 💡 应对 Apache HTTP Server 流行后的 access.log 分析需求
- 🧪 尚无正式项目名称，为作者 Laurent Destailleur 的实验性代码片段
- 🐪 基于 Perl 5 编写，利用复杂哈希结构实现基础正则匹配，用于统计总点击量及简单文件类型过滤
- 📊 仅用于作者个人网站(cdr)的内部流量观测
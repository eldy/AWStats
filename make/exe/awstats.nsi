;------------------------------------------------------------------------------
; AWStats Windows 安装脚本 - 遵循 Linux 目录结构
;------------------------------------------------------------------------------
Unicode true
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"

;------------------------------------------------------------------------------
; 安装程序属性
;------------------------------------------------------------------------------
Name "AWStats"
OutFile "..\awstats-${VERSION}.exe"
InstallDir "$PROGRAMFILES64\AWStats"
InstallDirRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AWStats" "InstallLocation"
RequestExecutionLevel admin
SetCompressor /SOLID lzma
XPStyle on

;------------------------------------------------------------------------------
; 版本信息
;------------------------------------------------------------------------------
!define VERSION "8.1"
!define PRODUCT_NAME "AWStats"
!define PRODUCT_PUBLISHER "Laurent Destailleur"
!define PRODUCT_WEB_SITE "https://www.awstats.org"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"

VIProductVersion "${VERSION}.0.0"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductVersion" "${VERSION}"

;------------------------------------------------------------------------------
; 界面设置
;------------------------------------------------------------------------------
!define MUI_ICON "..\..\docs\images\favicon.pub\favicon.ico"
!define MUI_UNICON "..\..\docs\images\favicon.pub\favicon.ico"
!define MUI_ABORTWARNING
!define MUI_LANGDLL_ALLLANGUAGES

;------------------------------------------------------------------------------
; 页面配置
;------------------------------------------------------------------------------
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\..\docs\LICENSE.TXT"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;------------------------------------------------------------------------------
; 多语言支持
;------------------------------------------------------------------------------
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"

;------------------------------------------------------------------------------
; 自定义字符串
;------------------------------------------------------------------------------
LangString SectionMain ${LANG_ENGLISH} "Core Files"
LangString SectionMain ${LANG_SIMPCHINESE} "核心文件"
LangString SectionGeoIP ${LANG_ENGLISH} "GeoIP Support"
LangString SectionGeoIP ${LANG_SIMPCHINESE} "GeoIP 支持"
LangString SectionScheduler ${LANG_ENGLISH} "Task Scheduler"
LangString SectionScheduler ${LANG_SIMPCHINESE} "任务计划"
LangString SectionShortcuts ${LANG_ENGLISH} "Shortcuts"
LangString SectionShortcuts ${LANG_SIMPCHINESE} "快捷方式"
LangString RemoveConfig ${LANG_ENGLISH} "Keep configuration files?"
LangString RemoveConfig ${LANG_SIMPCHINESE} "保留配置文件？"
LangString DescMain ${LANG_ENGLISH} "AWStats core files, documentation and tools, following Linux directory structure"
LangString DescMain ${LANG_SIMPCHINESE} "AWStats 核心文件、文档和工具，遵循 Linux 目录结构"
LangString DescGeoIP ${LANG_ENGLISH} "Download and install GeoIP database for geographic statistics"
LangString DescGeoIP ${LANG_SIMPCHINESE} "下载并安装 GeoIP 数据库，用于地理位置统计"
LangString DescScheduler ${LANG_ENGLISH} "Setup Windows Task Scheduler to automatically update AWStats statistics"
LangString DescScheduler ${LANG_SIMPCHINESE} "设置 Windows 任务计划，自动更新 AWStats 统计数据"
LangString DescShortcuts ${LANG_ENGLISH} "Create desktop and start menu shortcuts"
LangString DescShortcuts ${LANG_SIMPCHINESE} "创建桌面快捷方式和开始菜单快捷方式"

;------------------------------------------------------------------------------
; 页面文本
;------------------------------------------------------------------------------
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Run AWStats"
!define MUI_FINISHPAGE_RUN_FUNCTION "RunAWStats"
!define MUI_FINISHPAGE_LINK "AWStats Website"
!define MUI_FINISHPAGE_LINK_LOCATION "https://www.awstats.org"

;------------------------------------------------------------------------------
; 初始化
;------------------------------------------------------------------------------
Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

;------------------------------------------------------------------------------
; 安装部分
;------------------------------------------------------------------------------

; 核心文件
Section "$(SectionMain)" SEC_MAIN
  SectionIn RO
  
  ; --- /usr/lib/cgi-bin/ ---
  SetOutPath "$INSTDIR\cgi-bin"
  File "..\..\wwwroot\cgi-bin\awstats.pl"
  File "..\..\wwwroot\cgi-bin\awdownloadcsv.pl"
  File "..\..\wwwroot\cgi-bin\awredir.pl"
  File "..\..\wwwroot\cgi-bin\awstats.model.conf"
  
  ; --- /usr/share/awstats/lang/ ---
  SetOutPath "$INSTDIR\share\lang"
  File /r "..\..\wwwroot\cgi-bin\lang\*"
  
  ; --- /usr/share/awstats/lib/ ---
  SetOutPath "$INSTDIR\share\lib"
  File /r "..\..\wwwroot\cgi-bin\lib\*"
  
  ; --- /usr/share/awstats/plugins/ ---
  SetOutPath "$INSTDIR\share\plugins"
  File /r "..\..\wwwroot\cgi-bin\plugins\*"
  
  ; --- /usr/share/awstats/css/ ---
  SetOutPath "$INSTDIR\share\css"
  File "..\..\wwwroot\css\awstats_bw.css"
  File "..\..\wwwroot\css\awstats_default.css"
  
  ; --- /usr/share/awstats/icon/ ---
  SetOutPath "$INSTDIR\share\icon"
  File /r "..\..\wwwroot\icon\*"
  
  ; --- /usr/share/awstats/js/ ---
  SetOutPath "$INSTDIR\share\js"
  File "..\..\wwwroot\js\awstats_misc_tracker.js"
  
  ; --- /usr/share/awstats/classes/ ---
  SetOutPath "$INSTDIR\share\classes"
  File "..\..\wwwroot\classes\awgraphapplet.jar"
  
  ; --- /usr/share/awstats/tools/ ---
  SetOutPath "$INSTDIR\share\tools"
  File "..\..\tools\awstats_buildstaticpages.pl"
  File "..\..\tools\awstats_configure.pl"
  File "..\..\tools\awstats_exportlib.pl"
  File "..\..\tools\awstats_updateall.pl"
  File "..\..\tools\geoip_generator.pl"
  File "..\..\tools\logresolvemerge.pl"
  File "..\..\tools\maillogconvert.pl"
  File "..\..\tools\urlaliasbuilder.pl"
 ;File "..\..\tools\update-geoip.sh"
  File "..\..\tools\httpd_conf"
  
  ; nginx 配置
  SetOutPath "$INSTDIR\share\tools\nginx"
  File /r "..\..\tools\nginx\*"
  
  ; xslt
  SetOutPath "$INSTDIR\share\tools\xslt"
  File /r "..\..\tools\xslt\*"
  
  ; webmin
  SetOutPath "$INSTDIR\share\tools\webmin"
  File /r "..\..\tools\webmin\*"
  
  ; dolibarr
  SetOutPath "$INSTDIR\share\tools\dolibarr"
  File /r "..\..\tools\dolibarr\*"
  
  ; --- /usr/share/doc/awstats/ ---
  SetOutPath "$INSTDIR\share\doc"
  File /r "..\..\docs\*"
  
  ; --- /usr/local/bin/ ---
  SetOutPath "$INSTDIR\bin"
  
  FileOpen $0 "$INSTDIR\bin\awstats.bat" w
  FileWrite $0 '@echo off$\r$\n'
  FileWrite $0 'perl "%ProgramFiles%\AWStats\cgi-bin\awstats.pl" %*$\r$\n'
  FileClose $0
  
  FileOpen $0 "$INSTDIR\bin\awstats-update.bat" w
  FileWrite $0 '@echo off$\r$\n'
  FileWrite $0 'perl "%ProgramFiles%\AWStats\cgi-bin\awstats.pl" -config=%1 -update$\r$\n'
  FileClose $0
  
  ; --- Windows 脚本 ---
  SetOutPath "$INSTDIR\scripts"
  
  FileOpen $0 "$INSTDIR\scripts\update-geoip.ps1" w
  FileWrite $0 '# Update GeoIP database$\r$\n'
  FileWrite $0 '$year = (Get-Date).Year$\r$\n'
  FileWrite $0 '$month = (Get-Date).Month.ToString("00")$\r$\n'
  FileWrite $0 '$url = "https://download.db-ip.com/free/dbip-city-lite-$year-$month.mmdb.gz"$\r$\n'
  FileWrite $0 '$temp = "$env:TEMP\dbip-city-lite.mmdb.gz"$\r$\n'
  FileWrite $0 '$dest = "$env:ProgramFiles\AWStats\share\GeoIP\dbip-city.mmdb"$\r$\n'
  FileWrite $0 'if (-not (Test-Path $dest)) {$\r$\n'
  FileWrite $0 '    Write-Host "Downloading GeoIP database..."$\r$\n'
  FileWrite $0 '    try { Invoke-WebRequest -Uri $url -OutFile $temp -ErrorAction Stop }$\r$\n'
  FileWrite $0 '    catch { Write-Host "Download failed: $_" -ForegroundColor Red; exit 1 }$\r$\n'
  FileWrite $0 '    Write-Host "Extracting..."$\r$\n'
  FileWrite $0 '    Add-Type -AssemblyName System.IO.Compression.FileSystem$\r$\n'
  FileWrite $0 '    [System.IO.Compression.ZipFile]::ExtractToDirectory($temp, "$env:TEMP")$\r$\n'
  FileWrite $0 '    Move-Item "$env:TEMP\dbip-city-lite.mmdb" $dest -Force$\r$\n'
  FileWrite $0 '    Remove-Item $temp -Force$\r$\n'
  FileWrite $0 '    Write-Host "GeoIP database installed" -ForegroundColor Green$\r$\n'
  FileWrite $0 '}$\r$\n'
  FileClose $0
  
  FileOpen $0 "$INSTDIR\scripts\update-geoip.bat" w
  FileWrite $0 '@echo off$\r$\n'
  FileWrite $0 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-geoip.ps1"$\r$\n'
  FileWrite $0 'pause$\r$\n'
  FileClose $0
  
  FileOpen $0 "$INSTDIR\scripts\setup-scheduled-tasks.ps1" w
  FileWrite $0 '# Setup AWStats scheduled tasks$\r$\n'
  FileWrite $0 '$awstatsPath = "$env:ProgramFiles\AWStats\bin\awstats-update.bat"$\r$\n'
  FileWrite $0 '$geoipPath = "$env:ProgramFiles\AWStats\scripts\update-geoip.bat"$\r$\n'
  FileWrite $0 '$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)$\r$\n'
  FileWrite $0 'if (-not $isAdmin) { Write-Host "Run as Administrator" -ForegroundColor Red; exit 1 }$\r$\n'
  FileWrite $0 '$action1 = New-ScheduledTaskAction -Execute $awstatsPath -Argument "localhost"$\r$\n'
  FileWrite $0 '$trigger1 = New-ScheduledTaskTrigger -Daily -At 01:00AM$\r$\n'
  FileWrite $0 '$principal1 = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest$\r$\n'
  FileWrite $0 'Register-ScheduledTask -TaskName "AWStats Daily Update" -Action $action1 -Trigger $trigger1 -Principal $principal1 -Force$\r$\n'
  FileWrite $0 '$action2 = New-ScheduledTaskAction -Execute $geoipPath$\r$\n'
  FileWrite $0 '$trigger2 = New-ScheduledTaskTrigger -Monthly -DaysOfMonth 1 -At 03:00AM$\r$\n'
  FileWrite $0 'Register-ScheduledTask -TaskName "AWStats GeoIP Update" -Action $action2 -Trigger $trigger2 -Principal $principal1 -Force$\r$\n'
  FileWrite $0 'Write-Host "Scheduled tasks created" -ForegroundColor Green$\r$\n'
  FileClose $0
  
  ; --- /etc/awstats/ ---
  SetOutPath "$APPDATA\AWStats"
  IfFileExists "$APPDATA\AWStats\awstats.conf" 0 +2
    CopyFiles "$INSTDIR\cgi-bin\awstats.model.conf" "$APPDATA\AWStats\awstats.conf"
  
  ; --- /var/lib/awstats/ ---
  CreateDirectory "$PROGRAMDATA\AWStats\data"
  
  ; --- /var/log/awstats/ ---
  CreateDirectory "$PROGRAMDATA\AWStats\logs"
  
  ; --- GeoIP 数据库 ---
  CreateDirectory "$INSTDIR\share\GeoIP"
  
  ; --- 注册卸载程序 ---
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\share\doc\images\favicon.pub\favicon.ico"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegDWORD HKLM "${PRODUCT_UNINST_KEY}" "NoModify" 1
  WriteRegDWORD HKLM "${PRODUCT_UNINST_KEY}" "NoRepair" 1
  
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKLM "${PRODUCT_UNINST_KEY}" "EstimatedSize" "$0"
  
SectionEnd

; GeoIP 支持
Section "$(SectionGeoIP)" SEC_GEOIP
  DetailPrint "Downloading GeoIP database..."
  nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -File "$INSTDIR\scripts\update-geoip.ps1"'
SectionEnd

; 任务计划
Section "$(SectionScheduler)" SEC_SCHEDULER
  DetailPrint "Setting up scheduled tasks..."
  nsExec::ExecToLog 'powershell -NoProfile -ExecutionPolicy Bypass -File "$INSTDIR\scripts\setup-scheduled-tasks.ps1"'
SectionEnd

; 快捷方式
Section "$(SectionShortcuts)" SEC_SHORTCUTS
  CreateShortCut "$DESKTOP\AWStats.lnk" "$INSTDIR\bin\awstats.bat" "" "$INSTDIR\share\doc\images\favicon.pub\favicon.ico" 0
  CreateShortCut "$DESKTOP\AWStats Update.lnk" "$INSTDIR\bin\awstats-update.bat" "" "" 0
  
  CreateDirectory "$SMPROGRAMS\AWStats"
  CreateShortCut "$SMPROGRAMS\AWStats\AWStats.lnk" "$INSTDIR\bin\awstats.bat" "" "$INSTDIR\share\doc\images\favicon.pub\favicon.ico" 0
  CreateShortCut "$SMPROGRAMS\AWStats\Update AWStats.lnk" "$INSTDIR\bin\awstats-update.bat" "" "" 0
  CreateShortCut "$SMPROGRAMS\AWStats\Update GeoIP.lnk" "$INSTDIR\scripts\update-geoip.bat" "" "" 0
  CreateShortCut "$SMPROGRAMS\AWStats\Setup Scheduled Tasks.lnk" "$INSTDIR\scripts\setup-scheduled-tasks.ps1" "" "" 0
  CreateShortCut "$SMPROGRAMS\AWStats\Documentation.lnk" "$INSTDIR\share\doc\index.html" "" "" 0
  CreateShortCut "$SMPROGRAMS\AWStats\Configuration.lnk" "$APPDATA\AWStats" "" "" 0
  CreateShortCut "$SMPROGRAMS\AWStats\Data Directory.lnk" "$PROGRAMDATA\AWStats\data" "" "" 0
  CreateShortCut "$SMPROGRAMS\AWStats\Log Directory.lnk" "$PROGRAMDATA\AWStats\logs" "" "" 0
  CreateShortCut "$SMPROGRAMS\AWStats\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "" 0
SectionEnd

;------------------------------------------------------------------------------
; 组件描述
;------------------------------------------------------------------------------
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MAIN} $(DescMain)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_GEOIP} $(DescGeoIP)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_SCHEDULER} $(DescScheduler)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_SHORTCUTS} $(DescShortcuts)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;------------------------------------------------------------------------------
; 卸载部分
;------------------------------------------------------------------------------
Section "Uninstall"
  RMDir /r "$INSTDIR"
  Delete "$DESKTOP\AWStats.lnk"
  Delete "$DESKTOP\AWStats Update.lnk"
  RMDir /r "$SMPROGRAMS\AWStats"
  nsExec::ExecToLog 'schtasks /Delete /TN "AWStats Daily Update" /F'
  nsExec::ExecToLog 'schtasks /Delete /TN "AWStats GeoIP Update" /F'
  MessageBox MB_YESNO|MB_ICONQUESTION "$(RemoveConfig)" IDYES KeepConfig
    RMDir /r "$APPDATA\AWStats"
    RMDir /r "$PROGRAMDATA\AWStats"
  KeepConfig:
  DeleteRegKey HKLM "${PRODUCT_UNINST_KEY}"
SectionEnd

;------------------------------------------------------------------------------
; 辅助函数
;------------------------------------------------------------------------------
Function RunAWStats
  ExecShell "open" "$INSTDIR\bin\awstats.bat"
FunctionEnd
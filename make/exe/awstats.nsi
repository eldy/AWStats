; AWStats.nsi
;

!include "MUI.nsh"


!define MUI_PROD "AWStats" ;Define your own software name here
#!define MUI_VERSION_DOT "6.3" ;Define your own software version here
!define MUI_PUBLISHER "Laurent Destailleur"
!define MUI_URL "http://awstats.sourceforge.net"
!define MUI_COMMENTS "copyright 2000/2004 Laurent Destailleur"
!define MUI_HELPLINK "http://awstats.sourceforge.net/docs/index.html"
!define MUI_URLUPDATE "http://awstats.sourceforge.net"



;--------------------------------
;Configuration

  ;General
  Name "AWStats"
  OutFile "awstats-${MUI_VERSION_DOT}.exe"
  Icon "C:\temp\buildroot\awstats-${MUI_VERSION_DOT}\docs\images\awstats.ico"
  UninstallIcon "C:\temp\buildroot\awstats-${MUI_VERSION_DOT}\docs\images\awstats.ico"
  !define MUI_ICON "C:\temp\buildroot\awstats-${MUI_VERSION_DOT}\docs\images\awstats.ico"
  !define MUI_UNICON "C:\temp\buildroot\awstats-${MUI_VERSION_DOT}\docs\images\awstats.ico"

  BrandingText ""
;  ShowInstDetails nevershow

  ;Set install dir
  InstallDir "$PROGRAMFILES\${MUI_PROD}"
  
  ;Get install folder from registry if available
  InstallDirRegKey HKCU "Software\${MUI_PROD}" ""

  CompletedText 'AWStats ${MUI_VERSION_DOT} install completed. Documentation is available in docs directory.'



;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING


;--------------------------------
;Language Selection Dialog Settings

  ;Recupere la langue choisie pour la dernière installation
  !define MUI_LANGDLL_REGISTRY_ROOT "HKCU" 
  !define MUI_LANGDLL_REGISTRY_KEY "Software\${MUI_PROD}" 
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"


;--------------------------------
;Pages

  !define MUI_SPECIALBITMAP "C:\Mes Developpements\awstats\make\exe\awstats_bitmap1.bmp"
  !define MUI_HEADERBITMAP "C:\Mes Developpements\awstats\make\exe\awstats_bitmap2.bmp"

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "C:\temp\buildroot\awstats-${MUI_VERSION_DOT}\docs\LICENSE.TXT"
;  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES


;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"
  !insertmacro MUI_LANGUAGE "French"

  
;--------------------------------
;Reserve Files
  
  ;These files should be inserted before other files in the data block
  ;Keep these lines before any File command
  ;Only for solid compression (by default, solid compression is enabled for BZIP2 and LZMA)
  
  !insertmacro MUI_RESERVEFILE_LANGDLL


;--------------------------------
;Language Strings

  ;Header
  LangString PERLCHECK_TITLE ${LANG_ENGLISH} "Perl check"
  LangString PERLCHECK_SUBTITLE ${LANG_ENGLISH} "Check if a working Perl interpreter can be found"
  LangString SETUP_TITLE ${LANG_ENGLISH} "Setup"
  LangString SETUP_SUBTITLE ${LANG_ENGLISH} "Building AWStats config files"

  LangString PERLCHECK_TITLE ${LANG_FRENCH} "Vérification Perl"
  LangString PERLCHECK_SUBTITLE ${LANG_FRENCH} "Vérifie sur une interpréteur Perl opérationnel peut être trouvé"
  LangString SETUP_TITLE ${LANG_FRENCH} "Configuration"
  LangString SETUP_SUBTITLE ${LANG_FRENCH} "Construction des fichiers de configuration AWStats"

  ;Description
  LangString AWStats ${LANG_ENGLISH} "AWStats"
  LangString DESC_AWStats ${LANG_ENGLISH} "AWStats main files"

  LangString AWStats ${LANG_FRENCH} "AWStats"
  LangString DESC_AWStats ${LANG_FRENCH} "Fichiers AWStats"


;--------------------------------
;Reserve Files
  
  ;Things that need to be extracted on first (keep these lines before any File command!)
  ;Only useful for BZIP2 compression
;  !insertmacro MUI_RESERVEFILE_WELCOMEFINISHPAGE
;  !insertmacro MUI_RESERVEFILE_INSTALLOPTION ;InstallOptions
;  !insertmacro MUI_RESERVEFILE_LANGDLL ;LangDLL (language selection dialog)





;--------------------------------
;Installer Sections

; Check for a Perl interpreter
Section "CheckPerl"
    !insertmacro MUI_HEADER_TEXT "$(PERLCHECK_TITLE)" "$(PERLCHECK_SUBTITLE)"
CHECKPERL:
	SearchPath $1 "perl.exe"
	IfErrors NOPERL PERL
NOPERL:
	MessageBox MB_ABORTRETRYIGNORE "The installer did not find any Perl interpreter in your PATH.$\r$\nAWStats can't work without Perl. You must install one to use AWStats (For example the free Perl found at http://activestate.com).$\r$\nContinue setup anyway ?" IDABORT ABORT IDRETRY CHECKPERL
PERL:
	GOTO NOABORT
ABORT:
	Abort "AWStats ${MUI_VERSION_DOT} setup has been canceled"
NOABORT:
SectionEnd


; Copy the files into install directory
Section "AWStats" AWStats

	SetOutPath $INSTDIR
	File /r "C:\temp\buildroot\awstats-${MUI_VERSION_DOT}\*"
	
	;Store install folder
    WriteRegStr HKCU "Software\${MUI_PROD}" "" $INSTDIR

	;Write uninstall entries
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PROD}" "DisplayName" "${MUI_PROD}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PROD}" "UninstallString" "$INSTDIR/uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PROD}" "Publisher" "${MUI_PUBLISHER}"

    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PROD}" "URLInfoAbout" "${MUI_URL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PROD}" "Comments" "${MUI_COMMENTS}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PROD}" "HelpLink" "${MUI_HELPLINK}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PROD}" "URLUpdateInfo" "${MUI_URLUPDATE}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PROD}" "DisplayVersion" "${MUI_VERSION_DOT}"

	;Create uninstaller
	WriteUninstaller "uninstall.exe"

SectionEnd


; Run setup script
Section "Create config file" Setup
    !insertmacro MUI_HEADER_TEXT "$(SETUP_TITLE)" "$(SETUP_SUBTITLE)"
	SetOutPath $INSTDIR
	StrLen $2 $1
	IntCmpU $2 0 NOCONFIGURE
	ExecWait '"$1" "$INSTDIR\tools\awstats_configure.pl"' $3
NOCONFIGURE:
	ExecShell open $INSTDIR\docs\awstats_setup.html SW_SHOWNORMAL 
	BringToFront
SectionEnd



;--------------------------------
;Descriptions

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${AWStats} $(DESC_AWStats)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
 


;--------------------------------
;Uninstaller Section

Section "Uninstall"

  DeleteRegKey /ifempty HKCU "Software\${MUI_PROD}"

  Delete "$INSTDIR\Uninstall.exe"

  RMDir /r "$INSTDIR"

SectionEnd




!define MUI_FINISHPAGE

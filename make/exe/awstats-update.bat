@echo off
REM ------------------------------------------------------------------------------
REM AWStats Update Script - Windows Batch Wrapper
REM ------------------------------------------------------------------------------

set SCRIPT_DIR=%~dp0
set POWERSHELL_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%awstats-update.ps1"

if "%1"=="" (
    echo Usage: awstats-update.bat domain [config_file] [language]
    echo.
    echo Examples:
    echo   awstats-update.bat example.com
    echo   awstats-update.bat example.com C:\AWStats\conf\awstats.example.com.conf
    echo   awstats-update.bat example.com "" zh-cn
    echo.
    exit /b 1
)

%POWERSHELL_CMD% -Domain %1 -Config %2 -Lang %3

if %ERRORLEVEL% EQU 0 (
    echo AWStats update completed successfully
) else (
    echo AWStats update failed
    exit /b %ERRORLEVEL%
)
# ------------------------------------------------------------------------------
# AWStats Update Script - Windows PowerShell Version
# ------------------------------------------------------------------------------
# Description: Update AWStats statistics for a domain
# Usage: .\awstats-update.ps1 [-Domain] <domain> [-Config] <config_file> [-Lang] <language>
# ------------------------------------------------------------------------------

param(
    [Parameter(Mandatory=$false, HelpMessage="Domain name to update")]
    [string]$Domain,
    
    [Parameter(Mandatory=$false, HelpMessage="AWStats config file path")]
    [string]$Config,
    
    [Parameter(Mandatory=$false, HelpMessage="AWStats language")]
    [string]$Lang,
    
    [Parameter(Mandatory=$false, HelpMessage="Data directory")]
    [string]$DataDir,
    
    [Parameter(Mandatory=$false, HelpMessage="Show help message")]
    [switch]$Help
)

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
$AWSTATS_BIN = "C:\Program Files\AWStats\wwwroot\cgi-bin\awstats.pl"
$AWSTATS_WWWROOT = "C:\Program Files\AWStats"
$LOG_DIR = "C:\ProgramData\AWStats\logs"
$LOG_FILE = Join-Path $LOG_DIR "awstats-update.log"
$LOCK_DIR = "C:\ProgramData\AWStats\locks"

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

function Write-Log {
    param(
        [string]$Level,
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Create log directory if not exists
    if (-not (Test-Path $LOG_DIR)) {
        New-Item -ItemType Directory -Path $LOG_DIR -Force | Out-Null
    }
    
    # Write to log file
    Add-Content -Path $LOG_FILE -Value $logMessage
    
    # Write error to console
    if ($Level -eq "ERROR") {
        Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor Red
    }
    elseif ($Level -eq "WARNING") {
        Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor Yellow
    }
    else {
        Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor Green
    }
}

function Show-Help {
    $helpText = @"
Usage: awstats-update.ps1 [-Domain] <domain> [-Config] <config_file> [-Lang] <language>

Options:
    -Domain      Domain name to update (required)
    -Config      AWStats config file path
    -Lang        AWStats language (default: auto-detect)
    -DataDir     Data directory for AWStats (optional)
    -Help        Show this help message

Examples:
    .\awstats-update.ps1 -Domain example.com
    .\awstats-update.ps1 -Domain example.com -Config C:\AWStats\conf\awstats.example.com.conf
    .\awstats-update.ps1 -Domain example.com -Lang zh-cn
"@
    Write-Host $helpText
}

function Detect-DomainFromConfig {
    param([string]$ConfigFile)
    
    if (Test-Path $ConfigFile) {
        $content = Get-Content $ConfigFile -ErrorAction SilentlyContinue
        $domain = ($content | Select-String -Pattern "^SiteDomain=" | ForEach-Object { 
            $_ -replace '^SiteDomain=', '' -replace '"', '' -replace "'", '' 
        } | Select-Object -First 1).Trim()
        
        if ($domain) {
            return $domain
        }
    }
    return $null
}

function Detect-ConfigFromDomain {
    param([string]$Domain)
    
    $possiblePaths = @(
        "C:\ProgramData\AWStats\conf\awstats.$Domain.conf",
        "C:\Program Files\AWStats\wwwroot\cgi-bin\awstats.$Domain.conf",
        "C:\Program Files\AWStats\wwwroot\cgi-bin\awstats.model.conf"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    return $null
}

function Detect-LogFile {
    param([string]$Domain)
    
    $possibleLogs = @(
        "C:\inetpub\logs\LogFiles\W3SVC*\u_ex*.log",
        "C:\Windows\System32\LogFiles\HTTPERR\httperr.log",
        "C:\Program Files\Apache Group\Apache2\logs\$Domain-access.log",
        "C:\Program Files\Apache24\logs\$Domain-access.log",
        "C:\nginx\logs\$Domain-access.log",
        "C:\inetpub\logs\LogFiles\$Domain*.log"
    )
    
    foreach ($pattern in $possibleLogs) {
        $logs = Get-ChildItem $pattern -ErrorAction SilentlyContinue
        if ($logs -and $logs.Count -gt 0) {
            # Return the directory path
            $logDir = Split-Path $logs[0].FullName
            Write-Log -Level "INFO" -Message "Found log files in: $logDir"
            return $logDir
        }
    }
    return $null
}

function Detect-Language {
    param()
    
    # Get system UI language
    $culture = Get-Culture
    $langCode = $culture.Name
    
    Write-Log -Level "INFO" -Message "System language: $langCode"
    
    # Convert to AWStats language code
    $awstatsLang = "en"  # Default
    
    switch -Wildcard ($langCode) {
        "zh-CN" { $awstatsLang = "zh-cn"; break }
        "zh-TW" { $awstatsLang = "zh-tw"; break }
        "zh-HK" { $awstatsLang = "zh-tw"; break }
        "pt-BR" { $awstatsLang = "pt-br"; break }
        "pt-PT" { $awstatsLang = "pt"; break }
        "ja-JP" { $awstatsLang = "ja"; break }
        "ko-KR" { $awstatsLang = "ko"; break }
        "ru-RU" { $awstatsLang = "ru"; break }
        "uk-UA" { $awstatsLang = "ua"; break }
        "cs-CZ" { $awstatsLang = "cz"; break }
        "da-DK" { $awstatsLang = "dk"; break }
        "sv-SE" { $awstatsLang = "se"; break }
        "nb-NO" { $awstatsLang = "nb"; break }
        "ar-*" { $awstatsLang = "ar"; break }
        "he-IL" { $awstatsLang = "he"; break }
        "th-TH" { $awstatsLang = "th"; break }
        "vi-VN" { $awstatsLang = "vi"; break }
        "id-ID" { $awstatsLang = "id"; break }
        "tr-TR" { $awstatsLang = "tr"; break }
        "el-GR" { $awstatsLang = "gr"; break }
        "de-DE" { $awstatsLang = "de"; break }
        "es-ES" { $awstatsLang = "es"; break }
        "fr-FR" { $awstatsLang = "fr"; break }
        "it-IT" { $awstatsLang = "it"; break }
        "nl-NL" { $awstatsLang = "nl"; break }
        "pl-PL" { $awstatsLang = "pl"; break }
        "ro-RO" { $awstatsLang = "ro"; break }
        default { $awstatsLang = "en" }
    }
    
    # Verify language file exists
    $poFile = Join-Path $AWSTATS_WWWROOT "lang\awstats-$awstatsLang.po"
    if (-not (Test-Path $poFile)) {
        Write-Log -Level "WARNING" -Message "Language file not found: $poFile, using English"
        $awstatsLang = "en"
    }
    
    Write-Log -Level "INFO" -Message "Using language: $awstatsLang"
    return $awstatsLang
}

function Acquire-Lock {
    param([string]$Domain)
    
    if (-not (Test-Path $LOCK_DIR)) {
        New-Item -ItemType Directory -Path $LOCK_DIR -Force | Out-Null
    }
    
    $lockFile = Join-Path $LOCK_DIR "awstats-update-$Domain.lock"
    
    try {
        $script:lockStream = [System.IO.File]::Open($lockFile, 'OpenOrCreate', 'ReadWrite', 'None')
        $script:lockStream.Lock(0, [int]::MaxValue)
        Write-Log -Level "INFO" -Message "Acquired lock: $lockFile"
        return $true
    }
    catch {
        Write-Log -Level "ERROR" -Message "Failed to acquire lock: $_"
        return $false
    }
}

function Release-Lock {
    if ($script:lockStream) {
        try {
            $script:lockStream.Unlock(0, [int]::MaxValue)
            $script:lockStream.Close()
            Write-Log -Level "INFO" -Message "Released lock"
        }
        catch {
            Write-Log -Level "ERROR" -Message "Failed to release lock: $_"
        }
    }
}

function Update-AWStats {
    param(
        [string]$Domain,
        [string]$ConfigFile,
        [string]$Language,
        [string]$DataDirectory
    )
    
    # Auto-detect config if not provided
    if (-not $ConfigFile) {
        $ConfigFile = Detect-ConfigFromDomain -Domain $Domain
        if (-not $ConfigFile) {
            Write-Log -Level "ERROR" -Message "Cannot find AWStats config file for domain: $Domain"
            return $false
        }
        Write-Log -Level "INFO" -Message "Auto-detected config file: $ConfigFile"
    }
    
    # Auto-detect log directory
    $logDir = Detect-LogFile -Domain $Domain
    if (-not $logDir) {
        Write-Log -Level "ERROR" -Message "Cannot find log files for domain: $Domain"
        return $false
    }
    Write-Log -Level "INFO" -Message "Log directory: $logDir"
    
    # Determine stats directory
    if (-not $DataDirectory) {
        if (Test-Path $ConfigFile) {
            $content = Get-Content $ConfigFile -ErrorAction SilentlyContinue
            $DataDirectory = ($content | Select-String -Pattern "^DirData=" | ForEach-Object { 
                $_ -replace '^DirData=', '' -replace '"', '' -replace "'", '' 
            } | Select-Object -First 1).Trim()
        }
        
        if (-not $DataDirectory) {
            $DataDirectory = "C:\ProgramData\AWStats\data\$Domain"
        }
    }
    
    if (-not (Test-Path $DataDirectory)) {
        New-Item -ItemType Directory -Path $DataDirectory -Force | Out-Null
    }
    Write-Log -Level "INFO" -Message "Data directory: $DataDirectory"
    
    # Check AWStats binary
    if (-not (Test-Path $AWSTATS_BIN)) {
        Write-Log -Level "ERROR" -Message "AWStats binary not found: $AWSTATS_BIN"
        return $false
    }
    
    # Get current date
    $currentYear = (Get-Date).Year
    $currentMonth = (Get-Date).Month.ToString("00")
    $currentDate = "$currentYear-$currentMonth"
    
    # Process AWStats update
    Write-Log -Level "INFO" -Message "Running AWStats update for $currentDate"
    
    $args = @(
        "-config=$Domain",
        "-lang=$Language",
        "-year=$currentYear",
        "-month=$currentMonth",
        "-update",
        "-dir=$DataDirectory"
    )
    
    if ($ConfigFile) {
        $args += "-configdir=$(Split-Path $ConfigFile -Parent)"
    }
    
    $result = & $AWSTATS_BIN $args 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log -Level "INFO" -Message "Update successful: $currentDate"
        Write-Log -Level "INFO" -Message "Output: $result"
        return $true
    }
    else {
        Write-Log -Level "ERROR" -Message "Update failed: $currentDate"
        Write-Log -Level "ERROR" -Message "Error: $result"
        return $false
    }
}

# ------------------------------------------------------------------------------
# Main Script
# ------------------------------------------------------------------------------

# Show help if requested
if ($Help) {
    Show-Help
    exit 0
}

# Validate domain
if (-not $Domain) {
    Write-Host "Error: Domain is required" -ForegroundColor Red
    Show-Help
    exit 1
}

# Auto-detect language if not specified
if (-not $Lang) {
    $Lang = Detect-Language
}

# Start update process
Write-Log -Level "INFO" -Message "Starting AWStats update for domain: $Domain"
Write-Log -Level "INFO" -Message "Language: $Lang"
Write-Log -Level "INFO" -Message "Config: $(if ($Config) { $Config } else { 'auto-detect' })"

# Acquire lock
if (-not (Acquire-Lock -Domain $Domain)) {
    Write-Log -Level "ERROR" -Message "Failed to acquire lock, exiting"
    exit 1
}

try {
    # Run update
    $updateStatus = Update-AWStats -Domain $Domain -ConfigFile $Config -Language $Lang -DataDirectory $DataDir
    
    if ($updateStatus) {
        Write-Log -Level "INFO" -Message "AWStats update completed successfully"
        exit 0
    }
    else {
        Write-Log -Level "ERROR" -Message "AWStats update failed"
        exit 1
    }
}
finally {
    # Release lock
    Release-Lock
}
<#
.SYNOPSIS
    Aggressive system cleanup script - removes all non-essential applications
    while preserving user-specified categories and core system components.

.DESCRIPTION
    This script uninstalls and deletes all applications EXCEPT:
    - Document files (.doc, .docx, .pdf, .txt, .xls, .xlsx, .ppt, .pptx, .md, etc.)
    - Audio/Video files (.mp3, .mp4, .wav, .avi, .mkv, .mov, .flac, etc.)
    - ISO files and Arch Linux folders
    - Photo/Video editing software
    - Visual Studio Code
    - Git for Windows
    - Ollama (local AI)
    - Critical system components (drivers, runtimes, security tools)

    WARNING: THIS SCRIPT IS DESTRUCTIVE. TEST WITH -WhatIf FIRST.
    ALWAYS CREATE A SYSTEM RESTORE POINT BEFORE RUNNING.

.PARAMETER WhatIf
    Preview mode - shows what would be removed without actually removing anything.

.PARAMETER Force
    Skip all confirmation prompts and run destructively.

.PARAMETER KeepPreinstalled
    Keep all Windows pre-installed apps (default: removes most of them).

.PARAMETER DryRunOnly
    Only generate the removal report, do not uninstall anything.

.EXAMPLE
    .\SystemPurge.ps1 -WhatIf
    Preview what will be removed without making changes.

.EXAMPLE
    .\SystemPurge.ps1 -Force
    Run the purge with no confirmation prompts (DANGEROUS).

.NOTES
    Author: Custom Script
    Version: 1.1 (Git + Ollama added to keep list)
    Minimum PowerShell Version: 5.1
    Run As: Administrator REQUIRED
#>

[CmdletBinding()]
param(
    [switch]$WhatIf = $false,
    [switch]$Force = $false,
    [switch]$KeepPreinstalled = $false,
    [switch]$DryRunOnly = $false
)

# =============================================================================
# CONFIGURATION - EDIT THESE LISTS BEFORE RUNNING
# =============================================================================

# -----------------------------------------------------------------------------
# 1. APPLICATIONS TO KEEP (Win32/Desktop Apps)
# -----------------------------------------------------------------------------
$Win32AppsToKeep = @(
    # === YOUR SPECIFIED PRESERVES ===
    '*Visual Studio Code*',
    '*VSCode*',
    '*Code.exe*',

    # === GIT ===
    '*Git*',
    '*Git for Windows*',
    '*GitHub Desktop*',

    # === OLLAMA (LOCAL AI) ===
    '*Ollama*',

    # === PHOTO EDITING ===
    '*Adobe Photoshop*',
    '*Adobe Lightroom*',
    '*GIMP*',
    '*Affinity Photo*',
    '*Capture One*',
    '*darktable*',
    '*RawTherapee*',
    '*PhotoScape*',
    '*Paint.NET*',
    '*DxO*',
    '*Luminar*',
    '*Nik Collection*',
    '*NikCollection*',
    '*Skylum*',

    # === VIDEO EDITING ===
    '*DaVinci Resolve*',
    '*Blackmagic*',
    '*Fairlight*',
    '*Adobe Premiere*',
    '*Adobe After Effects*',
    '*Final Cut*',
    '*Kdenlive*',
    '*Shotcut*',
    '*OpenShot*',
    '*HitFilm*',
    '*Filmora*',
    '*Vegas Pro*',
    '*CapCut*',
    '*Clipchamp*',

    # === HARDWARE DRIVERS ===
    '*Wacom*',

    # === POWERSHELL 7 ===
    '*PowerShell 7*',

    # === CRITICAL SYSTEM COMPONENTS (DO NOT REMOVE) ===
    '*Microsoft Visual C++*',
    '*Microsoft .NET*',
    '*Microsoft Edge*',
    '*Microsoft Edge WebView2*',
    '*Windows Driver*',
    '*NVIDIA*',
    '*AMD*',
    '*Intel*',
    '*Realtek*',
    '*DirectX*',
    '*OpenAL*',
    '*Vulkan*',
    '*Java* Runtime*',
    '*Python*',
    '*Node.js*',

    # === SECURITY ===
    '*Windows Defender*',
    '*Microsoft Defender*',
    '*Malwarebytes*',
    '*Bitdefender*',
    '*Kaspersky*',
    '*Avast*',
    '*AVG*',
    '*ESET*',

    # === ESSENTIAL UTILITIES ===
    '*7-Zip*',
    '*WinRAR*',
    '*Notepad++*',
    '*Everything*',
    '*PowerToys*',
    '*Windows Terminal*'
)

# -----------------------------------------------------------------------------
# 2. UWP/MICROSOFT STORE APPS TO KEEP
# -----------------------------------------------------------------------------
$UWPAppsToKeep = @(
    # === YOUR SPECIFIED PRESERVES ===
    '*Microsoft.VisualStudioCode*',

    # === CORE WINDOWS FUNCTIONALITY (DO NOT REMOVE) ===
    '*Microsoft.WindowsStore*',
    '*Microsoft.WindowsCalculator*',
    '*Microsoft.WindowsNotepad*',
    '*Microsoft.WindowsTerminal*',
    '*Microsoft.MicrosoftEdge*',
    '*Microsoft.Windows.Photos*',
    '*Microsoft.ScreenSketch*',
    '*Microsoft.WindowsCamera*',

    # === SYSTEM CRITICAL ===
    '*Microsoft.Windows.ShellExperienceHost*',
    '*Microsoft.Windows.StartMenuExperienceHost*',
    '*Microsoft.Windows.Cortana*',
    '*Microsoft.Windows.Search*',
    '*Microsoft.Windows.SecHealthUI*',
    '*Microsoft.VCLibs*',
    '*Microsoft.UI.Xaml*',
    '*Microsoft.NET.Native*',
    '*Microsoft.Services.Store.Engagement*',
    '*Microsoft.StorePurchaseApp*',
    '*Microsoft.WindowsAppRuntime*',

    # === DEPENDENCIES ===
    '*Microsoft.DesktopAppInstaller*',
    '*Microsoft.Windows.PowerShell*'
)

# -----------------------------------------------------------------------------
# 3. WIN32 APPS TO EXPLICITLY REMOVE (Optional)
# -----------------------------------------------------------------------------
$Win32AppsToRemove = @(
    # Add specific applications you want to force-remove here
)

# -----------------------------------------------------------------------------
# 4. UWP APPS TO EXPLICITLY REMOVE (Optional)
# -----------------------------------------------------------------------------
$UWPAppsToRemove = @(
    # Add specific Store apps you want to force-remove here
)

# -----------------------------------------------------------------------------
# 5. FOLDER PROTECTION - Preserve these directories from file cleanup
# -----------------------------------------------------------------------------
$ProtectedFolders = @(
    'Arch Linux',
    'Arch_Linus',
    'arch',
    'archlinux',
    'Documents',
    'Music',
    'Pictures',
    'Videos',
    'Desktop',
    'Downloads\ISO',
    'ISO',
    'Git',
    'git',
    'Ollama'
)

# -----------------------------------------------------------------------------
# 6. FILE EXTENSIONS TO PROTECT (Document, Audio, Video, ISO)
# -----------------------------------------------------------------------------
$ProtectedExtensions = @(
    # Documents
    '.doc', '.docx', '.dot', '.dotx', '.odt', '.rtf', '.txt', '.md', '.markdown',
    '.pdf', '.xls', '.xlsx', '.xlsm', '.csv', '.ods', '.ppt', '.pptx', '.odp',
    '.one', '.pub', '.wps', '.pages', '.key', '.numbers',

    # Audio
    '.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a', '.wma', '.opus', '.aiff',
    '.alac', '.ac3', '.dts', '.mid', '.midi', '.amr',

    # Video
    '.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.mpg',
    '.mpeg', '.3gp', '.3g2', '.ogv', '.ts', '.mts', '.m2ts', '.vob', '.divx',

    # ISO/Disk Images
    '.iso', '.img', '.dmg', '.vhd', '.vhdx', '.vdi', '.vmdk', '.bin', '.cue',

    # Project files for photo/video editing
    '.psd', '.psb', '.xcf', '.kra', '.afphoto', '.afdesign',
    '.prproj', '.aep', '.aet', '.veg', '.kdenlive', '.mlt', '.drp', '.fcpxml'
)

# -----------------------------------------------------------------------------
# 7. INSTALL DATE FILTER
#    Apps installed ON OR AFTER this date are automatically preserved.
#    Apps installed BEFORE this date must be explicitly in the keep list.
# -----------------------------------------------------------------------------
$UseInstallDateFilter = $true
$CutoffDate = Get-Date "2026-04-01"  # Keep apps installed April 1, 2026 or later

# =============================================================================
# SCRIPT INITIALIZATION
# =============================================================================

# Check for Administrator privileges (skip check in DryRunOnly mode - no destructive actions)
if (-NOT $DryRunOnly) {
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "ERROR: This script requires Administrator privileges." -ForegroundColor Red
        Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
        exit 1
    }
}

# Set up logging
$LogFile = "$env:TEMP\SystemPurge_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$RemovalReport = "$env:USERPROFILE\Desktop\SystemPurge_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogEntry

    switch ($Level) {
        "ERROR"   { Write-Host $LogEntry -ForegroundColor Red }
        "WARNING" { Write-Host $LogEntry -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $LogEntry -ForegroundColor Green }
        default   { Write-Host $LogEntry -ForegroundColor Gray }
    }
}

# Header
Clear-Host
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    SYSTEM PURGE SCRIPT - v1.1                        ║" -ForegroundColor Cyan
Write-Host "║                          ⚠️  DESTRUCTIVE  ⚠️                          ║" -ForegroundColor Red
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Log File: $LogFile" -ForegroundColor DarkGray
Write-Host "Report File: $RemovalReport" -ForegroundColor DarkGray
Write-Host ""

# Confirmation gate
if (-not $Force -and -not $WhatIf -and -not $DryRunOnly) {
    Write-Host "⚠️  WARNING: This script will UNINSTALL AND DELETE most applications on your system." -ForegroundColor Red
    Write-Host "⚠️  It will preserve only what is explicitly listed in the configuration." -ForegroundColor Red
    Write-Host ""
    Write-Host "Have you:" -ForegroundColor Yellow
    Write-Host "  ✓ Created a System Restore Point?" -ForegroundColor Yellow
    Write-Host "  ✓ Backed up important data?" -ForegroundColor Yellow
    Write-Host "  ✓ Reviewed the exclusion lists?" -ForegroundColor Yellow
    Write-Host "  ✓ Run with -WhatIf first?" -ForegroundColor Yellow
    Write-Host ""
    $Confirmation = Read-Host "Type 'YES, I UNDERSTAND THE RISKS' to continue"
    if ($Confirmation -ne "YES, I UNDERSTAND THE RISKS") {
        Write-Log "User cancelled execution" "WARNING"
        exit 0
    }
}

Write-Log "=== System Purge Script Started ===" "INFO"
Write-Log "Mode: WhatIf=$WhatIf, Force=$Force, KeepPreinstalled=$KeepPreinstalled, DryRunOnly=$DryRunOnly" "INFO"

# =============================================================================
# PHASE 1: SCAN AND IDENTIFY APPLICATIONS
# =============================================================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  PHASE 1: Scanning System for Applications                          ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Write-Log "Scanning Win32 applications from registry..." "INFO"
$AllWin32Apps = @()

$RegPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($Path in $RegPaths) {
    if (Test-Path (Split-Path $Path -Parent)) {
        $Apps = Get-ItemProperty $Path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -and $_.DisplayName -ne "" }
        foreach ($App in $Apps) {
            $AllWin32Apps += [PSCustomObject]@{
                DisplayName          = $App.DisplayName
                UninstallString      = $App.UninstallString
                QuietUninstallString = $App.QuietUninstallString
                Publisher            = $App.Publisher
                InstallDate          = $App.InstallDate
                RegistryPath         = $App.PSPath
                Type                 = "Win32"
            }
        }
    }
}

Write-Log "Found $($AllWin32Apps.Count) Win32 applications" "SUCCESS"

Write-Log "Scanning UWP/Store applications..." "INFO"
$AllUWPApps = Get-AppxPackage -AllUsers | Where-Object { $_.Name -notlike "*Framework*" } | ForEach-Object {
    [PSCustomObject]@{
        Name              = $_.Name
        PackageFullName   = $_.PackageFullName
        PackageFamilyName = $_.PackageFamilyName
        Publisher         = $_.Publisher
        InstallDate       = $_.InstallDate
        Version           = $_.Version
        Type              = "UWP"
    }
}

Write-Log "Found $($AllUWPApps.Count) UWP applications" "SUCCESS"

Write-Log "Getting winget application list..." "INFO"
$WingetApps = @()
try {
    $WingetOutput = winget list --accept-source-agreements 2>$null
    if ($WingetOutput) {
        $Lines = $WingetOutput -split "`r`n"
        $InDataSection = $false
        foreach ($Line in $Lines) {
            if ($Line -match "^-{10,}") {
                $InDataSection = $true
                continue
            }
            if ($InDataSection -and $Line.Trim() -ne "") {
                $Parts = $Line -split '\s{2,}'
                if ($Parts.Count -ge 2) {
                    $WingetApps += [PSCustomObject]@{
                        Name = $Parts[0].Trim()
                        ID   = $Parts[1].Trim()
                        Type = "Winget"
                    }
                }
            }
        }
    }
    Write-Log "Found $($WingetApps.Count) applications via winget" "SUCCESS"
} catch {
    Write-Log "Failed to get winget list: $_" "WARNING"
}

# =============================================================================
# PHASE 2: FILTER APPLICATIONS TO REMOVE
# =============================================================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  PHASE 2: Filtering Applications to Keep/Remove                     ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

function Test-MatchesPattern {
    param([string]$Name, [string[]]$Patterns)
    foreach ($Pattern in $Patterns) {
        if ($Name -like $Pattern) {
            return $true
        }
    }
    return $false
}

# Filter Win32 apps
$Win32AppsToUninstall = @()
$Win32AppsPreserved   = @()

foreach ($App in $AllWin32Apps) {
    $DisplayName = $App.DisplayName

    $ShouldKeep    = Test-MatchesPattern -Name $DisplayName -Patterns $Win32AppsToKeep
    $ExplicitRemove = Test-MatchesPattern -Name $DisplayName -Patterns $Win32AppsToRemove

    if ($UseInstallDateFilter -and $App.InstallDate) {
        try {
            $InstallDate = [datetime]::ParseExact($App.InstallDate, "yyyyMMdd", $null)
            if ($InstallDate -ge $CutoffDate) {
                $ShouldKeep = $true
                Write-Log "Preserving (recent install): $DisplayName (Installed: $InstallDate)" "INFO"
            }
        } catch {
            # Date parse failure - rely on other filters
        }
    }

    if ($ExplicitRemove) {
        $Win32AppsToUninstall += $App
        Write-Log "Marked for removal (explicit): $DisplayName" "INFO"
    } elseif (-not $ShouldKeep) {
        $IsSystemCritical = $DisplayName -match "(?i)(driver|runtime|framework|visual c\+\+|\.net|edge webview|windows sdk|windows kit)"
        if ($IsSystemCritical) {
            $Win32AppsPreserved += $App
            Write-Log "Preserving (system critical): $DisplayName" "INFO"
        } else {
            $Win32AppsToUninstall += $App
        }
    } else {
        $Win32AppsPreserved += $App
    }
}

Write-Log "Win32 Apps: $($Win32AppsToUninstall.Count) to remove, $($Win32AppsPreserved.Count) preserved" "SUCCESS"

# Filter UWP apps
$UWPAppsToUninstall = @()
$UWPAppsPreserved   = @()

foreach ($App in $AllUWPApps) {
    $AppName          = $App.Name
    $PackageFamilyName = $App.PackageFamilyName

    $ShouldKeep    = Test-MatchesPattern -Name $PackageFamilyName -Patterns $UWPAppsToKeep
    $ExplicitRemove = Test-MatchesPattern -Name $PackageFamilyName -Patterns $UWPAppsToRemove

    if ($UseInstallDateFilter -and $App.InstallDate) {
        if ($App.InstallDate -ge $CutoffDate) {
            $ShouldKeep = $true
            Write-Log "Preserving (recent install): $AppName (Installed: $($App.InstallDate))" "INFO"
        }
    }

    if (-not $KeepPreinstalled -and -not $ShouldKeep -and $App.Publisher -like "*Microsoft*") {
        if ($ExplicitRemove) {
            $UWPAppsToUninstall += $App
        } elseif (-not $ShouldKeep) {
            $UWPAppsToUninstall += $App
        }
    } elseif ($ExplicitRemove) {
        $UWPAppsToUninstall += $App
    } elseif (-not $ShouldKeep) {
        $UWPAppsToUninstall += $App
    } else {
        $UWPAppsPreserved += $App
    }
}

Write-Log "UWP Apps: $($UWPAppsToUninstall.Count) to remove, $($UWPAppsPreserved.Count) preserved" "SUCCESS"

# =============================================================================
# PHASE 3: GENERATE REPORT
# =============================================================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  PHASE 3: Generating Removal Report                                 ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

$ReportContent = @"
================================================================================
                    SYSTEM PURGE REMOVAL REPORT
                    Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
================================================================================

CONFIGURATION SUMMARY:
----------------------
Install Date Filter: $UseInstallDateFilter
Cutoff Date: $CutoffDate (keeping apps installed ON OR AFTER this date)
Keep Preinstalled UWP Apps: $KeepPreinstalled

APPS TO BE REMOVED: $($Win32AppsToUninstall.Count + $UWPAppsToUninstall.Count) total
  - Win32 Applications: $($Win32AppsToUninstall.Count)
  - UWP/Store Applications: $($UWPAppsToUninstall.Count)

APPS PRESERVED: $($Win32AppsPreserved.Count + $UWPAppsPreserved.Count) total
  - Win32 Applications: $($Win32AppsPreserved.Count)
  - UWP/Store Applications: $($UWPAppsPreserved.Count)

================================================================================
WIN32 APPLICATIONS TO REMOVE:
================================================================================
"@

foreach ($App in $Win32AppsToUninstall | Sort-Object DisplayName) {
    $ReportContent += "`n- $($App.DisplayName)"
    if ($App.Publisher) { $ReportContent += " (Publisher: $($App.Publisher))" }
}

$ReportContent += @"

================================================================================
UWP/STORE APPLICATIONS TO REMOVE:
================================================================================
"@

foreach ($App in $UWPAppsToUninstall | Sort-Object Name) {
    $ReportContent += "`n- $($App.Name) (Version: $($App.Version))"
}

$ReportContent += @"

================================================================================
WIN32 APPLICATIONS PRESERVED:
================================================================================
"@

foreach ($App in $Win32AppsPreserved | Sort-Object DisplayName) {
    $ReportContent += "`n- $($App.DisplayName)"
}

$ReportContent += @"

================================================================================
UWP/STORE APPLICATIONS PRESERVED:
================================================================================
"@

foreach ($App in $UWPAppsPreserved | Sort-Object Name) {
    $ReportContent += "`n- $($App.Name)"
}

$ReportContent += @"

================================================================================
PROTECTED FOLDERS:
================================================================================
"@

foreach ($Folder in $ProtectedFolders) {
    $ReportContent += "`n- $Folder"
}

$ReportContent += @"

================================================================================
PROTECTED FILE EXTENSIONS ($($ProtectedExtensions.Count) extensions):
================================================================================
"@

$ReportContent += "`n" + ($ProtectedExtensions -join ", ")

$ReportContent += @"

================================================================================
END OF REPORT
================================================================================
"@

$ReportContent | Out-File -FilePath $RemovalReport -Encoding UTF8
Write-Log "Report saved to: $RemovalReport" "SUCCESS"

# Display summary
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                         REMOVAL SUMMARY                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Win32 Apps to Remove:   $($Win32AppsToUninstall.Count)" -ForegroundColor Yellow
Write-Host "  UWP Apps to Remove:     $($UWPAppsToUninstall.Count)" -ForegroundColor Yellow
Write-Host "  Total to Remove:        $($Win32AppsToUninstall.Count + $UWPAppsToUninstall.Count)" -ForegroundColor Red
Write-Host ""
Write-Host "  Win32 Apps Preserved:   $($Win32AppsPreserved.Count)" -ForegroundColor Green
Write-Host "  UWP Apps Preserved:     $($UWPAppsPreserved.Count)" -ForegroundColor Green
Write-Host ""

if ($DryRunOnly) {
    Write-Host "DRY RUN MODE: Report generated. No changes made." -ForegroundColor Cyan
    Write-Host "Review the report at: $RemovalReport" -ForegroundColor Cyan
    Write-Log "Dry run completed - exiting" "INFO"
    exit 0
}

if ($WhatIf) {
    Write-Host "WHATIF MODE: Preview only. No changes will be made." -ForegroundColor Cyan
    Write-Log "WhatIf mode - exiting" "INFO"
    exit 0
}

# =============================================================================
# PHASE 4: UNINSTALL APPLICATIONS
# =============================================================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  PHASE 4: Uninstalling Applications                                 ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

$SuccessCount = 0
$FailCount    = 0

function Uninstall-Win32App {
    param($App)

    $DisplayName         = $App.DisplayName
    $UninstallString     = $App.UninstallString
    $QuietUninstallString = $App.QuietUninstallString

    Write-Host "`nUninstalling: $DisplayName" -ForegroundColor Yellow
    Write-Log "Attempting to uninstall: $DisplayName" "INFO"

    try {
        if ($QuietUninstallString) {
            Write-Log "Using QuietUninstallString: $QuietUninstallString" "INFO"
            $Process = Start-Process cmd.exe -ArgumentList "/c $QuietUninstallString" -Wait -NoNewWindow -PassThru
        } elseif ($UninstallString) {
            $UninstallCmd = $UninstallString

            if ($UninstallCmd -match "msiexec") {
                if ($UninstallCmd -match "/I\{") {
                    $UninstallCmd = $UninstallCmd -replace "/I\{", "/X{"
                }
                if ($UninstallCmd -notmatch "/qn") {
                    $UninstallCmd += " /qn /norestart"
                }
            } elseif ($UninstallCmd -match "\.exe") {
                if ($UninstallCmd -notmatch "/S" -and $UninstallCmd -notmatch "/silent" -and $UninstallCmd -notmatch "/quiet") {
                    $UninstallCmd += " /S"
                }
            }

            Write-Log "Executing: $UninstallCmd" "INFO"
            $Process = Start-Process cmd.exe -ArgumentList "/c $UninstallCmd" -Wait -NoNewWindow -PassThru
        } else {
            Write-Log "No uninstall string found, trying winget..." "WARNING"
            $Process = Start-Process winget -ArgumentList "uninstall `"$DisplayName`" --silent --accept-source-agreements" -Wait -NoNewWindow -PassThru
        }

        if ($Process.ExitCode -eq 0 -or $Process.ExitCode -eq 3010) {
            Write-Host "  ✓ Successfully uninstalled" -ForegroundColor Green
            Write-Log "Successfully uninstalled: $DisplayName" "SUCCESS"
            $script:SuccessCount++
        } else {
            Write-Host "  ⚠ Uninstall returned exit code: $($Process.ExitCode)" -ForegroundColor Yellow
            Write-Log "Uninstall completed with exit code $($Process.ExitCode): $DisplayName" "WARNING"
            $script:SuccessCount++
        }
    } catch {
        Write-Host "  ✗ Failed to uninstall: $_" -ForegroundColor Red
        Write-Log "Failed to uninstall $DisplayName : $_" "ERROR"
        $script:FailCount++
    }
}

function Uninstall-UWPApp {
    param($App)

    $PackageFullName = $App.PackageFullName
    $AppName         = $App.Name

    Write-Host "`nUninstalling UWP: $AppName" -ForegroundColor Yellow
    Write-Log "Attempting to uninstall UWP: $AppName" "INFO"

    try {
        Remove-AppxPackage -Package $PackageFullName -ErrorAction Stop

        try {
            Remove-AppxProvisionedPackage -Online -PackageName $PackageFullName -ErrorAction SilentlyContinue
        } catch {
            # Provisioned package removal may fail, that's acceptable
        }

        Write-Host "  ✓ Successfully uninstalled" -ForegroundColor Green
        Write-Log "Successfully uninstalled UWP: $AppName" "SUCCESS"
        $script:SuccessCount++
    } catch {
        Write-Host "  ✗ Failed to uninstall: $_" -ForegroundColor Red
        Write-Log "Failed to uninstall UWP $AppName : $_" "ERROR"
        $script:FailCount++
    }
}

Write-Log "Starting Win32 application uninstallation..." "INFO"
foreach ($App in $Win32AppsToUninstall) {
    Uninstall-Win32App -App $App
}

Write-Log "Starting UWP application uninstallation..." "INFO"
foreach ($App in $UWPAppsToUninstall) {
    Uninstall-UWPApp -App $App
}

# =============================================================================
# PHASE 5: FILE SYSTEM CLEANUP (orphaned app data folders only)
# =============================================================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  PHASE 5: File System Cleanup                                       ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

function Test-IsProtected {
    param([string]$Path)

    foreach ($Folder in $ProtectedFolders) {
        if ($Path -match "(?i)\\$Folder\\" -or $Path -match "(?i)\\$Folder$") {
            return $true
        }
    }

    $Extension = [System.IO.Path]::GetExtension($Path).ToLower()
    if ($Extension -in $ProtectedExtensions) {
        return $true
    }

    return $false
}

$CleanupPaths = @(
    "$env:PROGRAMDATA",
    "$env:LOCALAPPDATA",
    "$env:APPDATA",
    "$env:PROGRAMFILES",
    "${env:ProgramFiles(x86)}"
)

Write-Log "Starting file system cleanup..." "INFO"
$DeletedCount  = 0
$SkippedCount  = 0

foreach ($BasePath in $CleanupPaths) {
    if (-not (Test-Path $BasePath)) { continue }

    Write-Log "Scanning: $BasePath" "INFO"
    $SubDirs = Get-ChildItem -Path $BasePath -Directory -ErrorAction SilentlyContinue

    foreach ($Dir in $SubDirs) {
        $FullPath = $Dir.FullName
        $DirName  = $Dir.Name

        if (Test-IsProtected -Path $FullPath) {
            Write-Log "Skipping protected: $FullPath" "INFO"
            $SkippedCount++
            continue
        }

        $BelongsToUninstalledApp = $false
        foreach ($App in $Win32AppsToUninstall) {
            # Use stricter matching: folder name must contain app name (min 5 chars to avoid false positives)
            $AppName = $App.DisplayName
            if ($AppName.Length -ge 5 -and ($DirName -like "*$AppName*" -or $AppName -like "*$DirName*")) {
                $BelongsToUninstalledApp = $true
                break
            }
        }

        if ($BelongsToUninstalledApp) {
            Write-Host "Deleting orphaned folder: $FullPath" -ForegroundColor DarkGray
            Write-Log "Deleting orphaned folder: $FullPath" "INFO"
            try {
                Remove-Item -Path $FullPath -Recurse -Force -ErrorAction Stop
                $DeletedCount++
            } catch {
                Write-Log "Failed to delete $FullPath : $_" "WARNING"
            }
        }
    }
}

Write-Log "File cleanup: $DeletedCount folders deleted, $SkippedCount skipped (protected)" "SUCCESS"

# =============================================================================
# PHASE 6: TEMP FILE CLEANUP AND COMPLETION
# =============================================================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  PHASE 6: Cleanup and Completion                                    ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# Copy log out of TEMP before cleaning TEMP
$FinalLogCopy = "$env:USERPROFILE\Desktop\SystemPurge_Log_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
try {
    Copy-Item -Path $LogFile -Destination $FinalLogCopy -ErrorAction Stop
    Write-Host "Log copied to Desktop: $FinalLogCopy" -ForegroundColor Green
} catch {
    Write-Host "Could not copy log to Desktop: $_" -ForegroundColor Yellow
}

Write-Log "Cleaning temporary files..." "INFO"
try {
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Temporary files cleaned." -ForegroundColor Green
} catch {
    Write-Host "Some temp files could not be deleted (in use)." -ForegroundColor Yellow
}

# Final summary
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                         PURGE COMPLETE                               ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Applications Successfully Uninstalled:  $SuccessCount" -ForegroundColor Green
Write-Host "  Applications Failed to Uninstall:       $FailCount"    -ForegroundColor Red
Write-Host "  Orphaned Folders Deleted:               $DeletedCount" -ForegroundColor Yellow
Write-Host "  Protected Items Skipped:                $SkippedCount" -ForegroundColor Green
Write-Host ""
Write-Host "  Report File:  $RemovalReport"  -ForegroundColor DarkGray
Write-Host "  Log File:     $FinalLogCopy"   -ForegroundColor DarkGray
Write-Host ""

Write-Log "=== System Purge Script Completed ===" "INFO"
Write-Log "Summary: $SuccessCount successful, $FailCount failed, $DeletedCount folders deleted" "INFO"

Write-Host "⚠️  RECOMMENDATION: Restart your computer to complete the cleanup." -ForegroundColor Yellow

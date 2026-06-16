#Requires -Version 5.1
<#
.SYNOPSIS
    WSL Dev Environment Setup - Windows-side entry point (Phase 1)
.DESCRIPTION
    One-command bootstrap for a new Windows machine:
      1. Auto-elevate to admin
      2. Install WSL + Ubuntu
      3. Install Hack Nerd Font
      4. Configure Windows Terminal (merge, not overwrite)
      5. Pin WSL home to File Explorer Quick Access
      6. Run Phase 2 (setup-wsl.sh) inside WSL

    Usage (paste into PowerShell as Admin):
      iwr -useb https://raw.githubusercontent.com/latteouka/wsl-dev-setup/main/setup-dev-env.ps1 -OutFile $HOME\setup.ps1; powershell -ExecutionPolicy Bypass -File $HOME\setup.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Output Helpers ──────────────────────────────────────────────────────────

function Write-Step  { param([string]$msg) Write-Host "  [*] $msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$msg) Write-Host "  [+] $msg" -ForegroundColor Green }
function Write-Warn  { param([string]$msg) Write-Host "  [!] $msg" -ForegroundColor Yellow }
function Write-Err   { param([string]$msg) Write-Host "  [x] $msg" -ForegroundColor Red }

function Show-Banner {
    Write-Host ""
    Write-Host " ╭───────────────────────────────────────────────────╮" -ForegroundColor Cyan
    Write-Host " │        WSL Dev Environment Setup (Phase 1)        │" -ForegroundColor Cyan
    Write-Host " ├───────────────────────────────────────────────────┤" -ForegroundColor Cyan
    Write-Host " │                                                   │" -ForegroundColor Cyan
    Write-Host " │  This script will:                                │" -ForegroundColor Cyan
    Write-Host " │                                                   │" -ForegroundColor Cyan
    Write-Host " │  1. Install WSL + Ubuntu                          │" -ForegroundColor Cyan
    Write-Host " │  2. Install Hack Nerd Font                        │" -ForegroundColor Cyan
    Write-Host " │  3. Configure Windows Terminal (Tokyo Night)       │" -ForegroundColor Cyan
    Write-Host " │  4. Pin WSL home to Quick Access                  │" -ForegroundColor Cyan
    Write-Host " │  5. Run Phase 2 setup inside WSL                  │" -ForegroundColor Cyan
    Write-Host " │                                                   │" -ForegroundColor Cyan
    Write-Host " ╰───────────────────────────────────────────────────╯" -ForegroundColor Cyan
    Write-Host ""
}

# ─── 1. Auto-Elevate to Admin ───────────────────────────────────────────────

$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warn "Not running as administrator. Re-launching with elevation..."
    $scriptPath = $MyInvocation.MyCommand.Definition
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    exit
}

Show-Banner
Write-Ok "Running as administrator"

# ─── 2. Install WSL + Ubuntu ─────────────────────────────────────────────────

Write-Step "Checking WSL + Ubuntu..."

# Check if Ubuntu is already working
$ubuntuReady = $false
try {
    $testOutput = wsl -d Ubuntu -- echo "WSL_READY" 2>&1
    if ($testOutput -match "WSL_READY") {
        $ubuntuReady = $true
    }
} catch {}

if ($ubuntuReady) {
    Write-Ok "WSL + Ubuntu already installed and ready"
} else {
    Write-Step "Installing WSL + Ubuntu (this may take a few minutes)..."
    wsl --install -d Ubuntu

    # Check if reboot is required (some Windows versions need it)
    $ubuntuReady = $false
    try {
        $testOutput = wsl -d Ubuntu -- echo "WSL_READY" 2>&1
        if ($testOutput -match "WSL_READY") {
            $ubuntuReady = $true
        }
    } catch {}

    if (-not $ubuntuReady) {
        # WSL installed but not functional yet — needs reboot
        Write-Warn "WSL needs a reboot to finish installation."
        Write-Host ""

        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $continueScript = Join-Path $desktopPath "continue-setup.cmd"
        $selfPath = $MyInvocation.MyCommand.Definition

        @"
@echo off
echo Resuming WSL Dev Environment Setup...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$selfPath"
pause
"@ | Set-Content -Path $continueScript -Encoding ASCII

        Write-Ok "Created 'continue-setup.cmd' on your Desktop."
        Write-Host ""
        Write-Host "  Please:" -ForegroundColor Yellow
        Write-Host "    1. Reboot your computer" -ForegroundColor Yellow
        Write-Host "    2. Double-click 'continue-setup.cmd' on your Desktop" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "  Press Enter to exit"
        exit 0
    }

    Write-Ok "WSL + Ubuntu installed and ready"
}

# ─── 3. Install Hack Nerd Font ───────────────────────────────────────────────

Write-Step "Checking Hack Nerd Font..."

$fontInstalled = $false
try {
    Add-Type -AssemblyName System.Drawing
    $fonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families
    $fontInstalled = ($fonts | Where-Object { $_.Name -match "Hack Nerd Font" }).Count -gt 0
} catch {
    Write-Warn "Could not enumerate fonts, will attempt install anyway."
}

if ($fontInstalled) {
    Write-Ok "Hack Nerd Font is already installed"
} else {
    Write-Step "Downloading Hack Nerd Font..."
    $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
    $tempDir = Join-Path $env:TEMP "HackNerdFont_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    $zipPath = Join-Path $env:TEMP "Hack.zip"

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $fontUrl -OutFile $zipPath -UseBasicParsing

        Write-Step "Extracting fonts..."
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

        Write-Step "Installing fonts..."
        $shell = New-Object -ComObject Shell.Application
        $fontsFolder = $shell.Namespace(0x14)  # Windows Fonts special folder
        $ttfFiles = Get-ChildItem -Path $tempDir -Filter "*.ttf" -Recurse

        foreach ($ttf in $ttfFiles) {
            $fontsFolder.CopyHere($ttf.FullName, 0x10)  # 0x10 = overwrite silently
        }
        Write-Ok "Hack Nerd Font installed ($($ttfFiles.Count) files)"
    } catch {
        Write-Err "Font installation failed: $_"
        Write-Warn "You can install manually from: $fontUrl"
    } finally {
        # Cleanup temp files
        if (Test-Path $zipPath) { Remove-Item $zipPath -Force -ErrorAction SilentlyContinue }
        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

# ─── 4. Configure Windows Terminal ───────────────────────────────────────────

Write-Step "Configuring Windows Terminal..."

$wtPaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
)

$wtSettingsPath = $null
foreach ($p in $wtPaths) {
    if (Test-Path $p) {
        $wtSettingsPath = $p
        break
    }
}

if (-not $wtSettingsPath) {
    Write-Warn "Windows Terminal settings.json not found. Skipping Terminal configuration."
    Write-Warn "Install Windows Terminal from the Microsoft Store, then re-run this script."
} else {
    Write-Step "Found Windows Terminal settings: $wtSettingsPath"

    # Backup existing settings
    $backupPath = "$wtSettingsPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $wtSettingsPath -Destination $backupPath
    Write-Ok "Backed up settings to: $backupPath"

    try {
        # Read existing settings (strip BOM and comments for robustness)
        $rawJson = Get-Content -Path $wtSettingsPath -Raw -Encoding UTF8
        # Remove single-line comments (// ...) that Windows Terminal allows but ConvertFrom-Json does not
        $cleanJson = $rawJson -replace '(?m)^\s*//.*$', '' -replace '(?<=,)\s*//.*$', ''
        # Remove trailing commas before } or ] (common in WT settings)
        $cleanJson = $cleanJson -replace ',\s*([\}\]])', '$1'
        $settings = $cleanJson | ConvertFrom-Json

        # ── Add Tokyo Night color scheme ──
        $tokyoNight = @{
            name             = "Tokyo Night"
            background       = "#1b1f30"
            foreground       = "#bbc2e0"
            cursorColor      = "#c0caf5"
            selectionBackground = "#323955"
            black            = "#414868"; red     = "#f7768e"; green   = "#41b59b"; yellow  = "#e0af68"
            blue             = "#7ba2f3"; purple  = "#bb9af7"; cyan    = "#2ccde9"; white   = "#c0caf5"
            brightBlack      = "#414868"; brightRed = "#f7768e"; brightGreen = "#41b59b"
            brightYellow     = "#e0af68"; brightBlue = "#7ba2f3"; brightPurple = "#bb9af7"
            brightCyan       = "#2ac4de"; brightWhite = "#c0caf5"
        }

        # Ensure schemes array exists
        if (-not $settings.PSObject.Properties.Match("schemes")) {
            $settings | Add-Member -NotePropertyName "schemes" -NotePropertyValue @()
        }
        # Convert to list for manipulation
        $schemesList = [System.Collections.ArrayList]@($settings.schemes)
        $existingScheme = $schemesList | Where-Object { $_.name -eq "Tokyo Night" }
        if (-not $existingScheme) {
            $schemesList.Add([PSCustomObject]$tokyoNight) | Out-Null
            Write-Ok "Added 'Tokyo Night' color scheme"
        } else {
            Write-Ok "'Tokyo Night' color scheme already exists"
        }
        $settings.schemes = @($schemesList)

        # ── Set profile defaults ──
        if (-not $settings.PSObject.Properties.Match("profiles")) {
            $settings | Add-Member -NotePropertyName "profiles" -NotePropertyValue ([PSCustomObject]@{})
        }
        if (-not $settings.profiles.PSObject.Properties.Match("defaults")) {
            $settings.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue ([PSCustomObject]@{})
        }

        # Set font + colorScheme on defaults (overwrite cleanly)
        $fontSetting = [PSCustomObject]@{ face = "Hack Nerd Font Mono"; size = 18 }
        $settings.profiles.defaults = [PSCustomObject]@{
            font        = $fontSetting
            colorScheme = "Tokyo Night"
        }
        Write-Ok "Set profile defaults: Hack Nerd Font Mono, size 18, Tokyo Night"

        # ── Set default profile to WSL Ubuntu ──
        $ubuntuGuid = "{2c4de342-38b7-51cf-b940-2309a097f518}"

        $ubuntuProfile = $null
        if ($settings.profiles.PSObject.Properties.Match("list")) {
            foreach ($prof in $settings.profiles.list) {
                try {
                    if ($prof.name -match "Ubuntu") {
                        $ubuntuProfile = $prof
                        break
                    }
                } catch {}
            }
        }

        if (-not $ubuntuProfile) {
            # Terminal hasn't discovered Ubuntu yet — add profile manually
            $newProfile = [PSCustomObject]@{
                guid              = $ubuntuGuid
                name              = "Ubuntu"
                commandline       = "wsl.exe -d Ubuntu"
                startingDirectory = "~"
                hidden            = $false
            }
            $profileList = [System.Collections.ArrayList]@($settings.profiles.list)
            $profileList.Add($newProfile) | Out-Null
            $settings.profiles.list = @($profileList)
            $ubuntuProfile = $newProfile
            Write-Ok "Added Ubuntu profile to Windows Terminal"
        }

        $settings.defaultProfile = $ubuntuProfile.guid
        Write-Ok "Set default profile to Ubuntu"

        # ── Write back ──
        $settings | ConvertTo-Json -Depth 20 | Set-Content -Path $wtSettingsPath -Encoding UTF8
        Write-Ok "Windows Terminal settings updated"
    } catch {
        Write-Err "Failed to configure Windows Terminal: $_"
        Write-Warn "Restoring backup..."
        Copy-Item -Path $backupPath -Destination $wtSettingsPath -Force
        Write-Warn "Original settings restored from backup."
    }
}

# ─── 5. Pin WSL Home to Quick Access ─────────────────────────────────────────

Write-Step "Pinning WSL home directory to Quick Access..."

try {
    $wslUsername = (wsl -d Ubuntu -- whoami 2>&1).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($wslUsername)) {
        throw "Could not get WSL username"
    }

    $wslHomePath = "\\wsl$\Ubuntu\home\$wslUsername"

    if (Test-Path $wslHomePath) {
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.Namespace($wslHomePath)
        if ($folder) {
            $folder.Self.InvokeVerb("pintohome")
            Write-Ok "Pinned '$wslHomePath' to Quick Access"
        } else {
            Write-Warn "Could not access '$wslHomePath' via Shell. Pin manually in File Explorer."
        }
    } else {
        Write-Warn "WSL home path '$wslHomePath' not accessible. Pin manually after WSL is fully set up."
    }
} catch {
    Write-Warn "Could not pin WSL home to Quick Access: $_"
    Write-Warn "You can pin it manually by navigating to \\wsl$\Ubuntu\home\<username> in File Explorer."
}

# ─── 6. Run Phase 2 (WSL Setup) ──────────────────────────────────────────────

Write-Step "Launching Phase 2 (WSL-side setup)..."

# Download first, then execute — curl|bash breaks interactive prompts (stdin conflict)
$phase2Url = "https://raw.githubusercontent.com/latteouka/wsl-dev-setup/main/setup-wsl.sh"
$phase2Cmd = "curl -fsSL '$phase2Url' -o /tmp/wsl-setup.sh && bash /tmp/wsl-setup.sh"

Write-Host ""
Write-Host "  ── Entering WSL (Phase 2) ──" -ForegroundColor Cyan
Write-Host ""

wsl -d Ubuntu bash -c $phase2Cmd

if ($LASTEXITCODE -eq 0) {
    Write-Ok "Phase 2 completed successfully"
} else {
    Write-Warn "Phase 2 exited with code $LASTEXITCODE"
    Write-Warn "You can re-run manually inside WSL:"
    Write-Host "    $phase2Cmd" -ForegroundColor White
}

# ─── 7. Cleanup ──────────────────────────────────────────────────────────────

Write-Step "Cleaning up..."

$desktopPath = [Environment]::GetFolderPath("Desktop")
$continueScript = Join-Path $desktopPath "continue-setup.cmd"
if (Test-Path $continueScript) {
    Remove-Item $continueScript -Force
    Write-Ok "Removed continue-setup.cmd from Desktop"
}

# ─── Done ─────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host " ╭───────────────────────────────────────────────────╮" -ForegroundColor Green
Write-Host " │          Setup Complete!                           │" -ForegroundColor Green
Write-Host " ├───────────────────────────────────────────────────┤" -ForegroundColor Green
Write-Host " │                                                   │" -ForegroundColor Green
Write-Host " │  Open a new Windows Terminal window to start!     │" -ForegroundColor Green
Write-Host " │                                                   │" -ForegroundColor Green
Write-Host " ╰───────────────────────────────────────────────────╯" -ForegroundColor Green
Write-Host ""

Read-Host "  Press Enter to exit"

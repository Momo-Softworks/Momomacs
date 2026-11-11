<#
.SYNOPSIS
  Install Momomacs on Windows: Emacs, Git, ag, spell-check tools, the icon
  font, the config itself and all of its packages.

.DESCRIPTION
  Safe to run again: it skips what is already installed and updates an
  existing Momomacs checkout instead of replacing it.

  Quick install (PowerShell):
    & ([scriptblock]::Create((irm https://raw.githubusercontent.com/Momo-Softworks/Momomacs/main/scripts/install-windows.ps1)))

  Or double-click scripts\install-windows.cmd in a checkout.

.PARAMETER Dir
  Where the config goes.  Defaults to %APPDATA%\.emacs.d, which is where
  Emacs on Windows looks when HOME is not set.

.PARAMETER Branch
  Git branch to check out.  Defaults to main.

.PARAMETER NoSpellCheck
  Skip MSYS2 (gcc + Enchant + dictionaries), which Jinx spell-checking needs.
  It is the largest download (about 500 MB).

.PARAMETER NoFont
  Skip installing the Symbols Nerd Font Mono icon font.
#>
[CmdletBinding()]
param(
    [string]$Dir = (Join-Path $env:APPDATA '.emacs.d'),
    [string]$Branch = 'main',
    [string]$Repo = 'https://github.com/Momo-Softworks/Momomacs.git',
    [switch]$NoSpellCheck,
    [switch]$NoFont
)

$ErrorActionPreference = 'Stop'
$Msys = 'C:\msys64'
$Ucrt = Join-Path $Msys 'ucrt64\bin'

function Step($text) { Write-Host "`n==> $text" -ForegroundColor Cyan }
function Info($text) { Write-Host "    $text" }

function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

function Install-WingetPackage($id, $name) {
    $null = winget list --id $id -e --accept-source-agreements
    if ($LASTEXITCODE -eq 0) { Info "$name is already installed."; return }
    Info "Installing $name..."
    winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "winget could not install $name ($id)." }
}

function Find-Emacs {
    $cmd = Get-Command emacs.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $found = Get-ChildItem "$env:ProgramFiles\Emacs" -Recurse -Filter emacs.exe -ErrorAction SilentlyContinue |
        Where-Object { $_.Directory.Name -eq 'bin' } |
        Sort-Object FullName -Descending | Select-Object -First 1
    if ($found) { return $found.FullName }
    throw 'Emacs is installed but emacs.exe could not be found.'
}

function Add-UserPath($dir) {
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $parts = @()
    if ($user) { $parts = $user -split ';' | Where-Object { $_ } }
    if ($parts -contains $dir) { Info "$dir is already on your PATH."; return }
    # Appended, so MSYS2's tools never shadow Windows or Git ones.
    [Environment]::SetEnvironmentVariable('Path', (($parts + $dir) -join ';'), 'User')
    Info "Added $dir to your PATH."
}

# --- 1. Tools ---------------------------------------------------------------
Step 'Checking winget'
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget is missing. Install "App Installer" from the Microsoft Store, then run this again.'
}

Step 'Installing Emacs, Git and ag'
Install-WingetPackage 'GNU.Emacs' 'GNU Emacs'
Install-WingetPackage 'Git.Git' 'Git'
Install-WingetPackage 'JFLarvoire.Ag' 'The Silver Searcher (ag)'
Refresh-Path
$git = (Get-Command git.exe -ErrorAction SilentlyContinue)
if ($git) { $git = $git.Source } else { $git = Join-Path $env:ProgramFiles 'Git\cmd\git.exe' }
$emacs = Find-Emacs
Info "Emacs: $emacs"

# --- 2. Spell-check toolchain ----------------------------------------------
if (-not $NoSpellCheck) {
    Step 'Installing spell-check tools (MSYS2 with gcc, Enchant and English dictionaries)'
    if (-not (Test-Path (Join-Path $Msys 'usr\bin\bash.exe'))) {
        Install-WingetPackage 'MSYS2.MSYS2' 'MSYS2'
    } else {
        Info 'MSYS2 is already installed.'
    }
    $bash = Join-Path $Msys 'usr\bin\bash.exe'
    $env:MSYSTEM = 'UCRT64'
    $pkgs = 'mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-pkgconf mingw-w64-ucrt-x86_64-enchant mingw-w64-ucrt-x86_64-hunspell mingw-w64-ucrt-x86_64-hunspell-en'
    & $bash -lc "pacman -S --needed --noconfirm $pkgs > /dev/null 2>&1"
    if ($LASTEXITCODE -ne 0) { throw 'pacman could not install the spell-check packages.' }
    Add-UserPath $Ucrt
    Refresh-Path
}

# --- 3. Icon font -------------------------------------------------------------
if (-not $NoFont) {
    Step 'Installing the icon font (Symbols Nerd Font Mono)'
    $fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    $fontFile = Join-Path $fontDir 'SymbolsNerdFontMono-Regular.ttf'
    if (Test-Path $fontFile) {
        Info 'Already installed.'
    } else {
        New-Item -ItemType Directory -Force -Path $fontDir | Out-Null
        Invoke-WebRequest -UseBasicParsing -OutFile $fontFile `
            -Uri 'https://raw.githubusercontent.com/rainstormstudio/nerd-icons.el/main/fonts/NFM.ttf'
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' `
            -Name 'Symbols Nerd Font Mono (TrueType)' -Value $fontFile -PropertyType String -Force | Out-Null
        Info 'Installed for your account.'
    }
}

# --- 4. The config ------------------------------------------------------------
Step "Getting Momomacs into $Dir"
if (Test-Path (Join-Path $Dir '.git')) {
    Info 'Existing checkout found; updating it.'
    & $git -C $Dir fetch origin $Branch
    if ($LASTEXITCODE -ne 0) {
        Info "Could not fetch $Branch from GitHub (offline, or a local-only branch); using the checkout as is."
    } else {
        & $git -C $Dir checkout $Branch
        if ($LASTEXITCODE -ne 0) { throw "Could not switch to $Branch (uncommitted changes?)." }
        & $git -C $Dir merge --ff-only "origin/$Branch"
        if ($LASTEXITCODE -ne 0) { Info "Your $Branch has local commits; left it as is." }
    }
} else {
    if ((Test-Path $Dir) -and (Get-ChildItem $Dir -Force | Select-Object -First 1)) {
        $backup = "$Dir.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
        Info "Moving your existing Emacs config to $backup"
        Move-Item $Dir $backup
    }
    & $git clone --branch $Branch $Repo $Dir
    if ($LASTEXITCODE -ne 0) { throw 'git clone failed.' }
}

# --- 5. Packages ----------------------------------------------------------------
Step 'Installing Emacs packages (first time takes a few minutes)'
$boot = Join-Path ([IO.Path]::GetTempPath()) "momomacs-install-$PID.el"
$dirLisp = ($Dir -replace '\\', '/').TrimEnd('/') + '/'
$bootCode = @"
;;; -*- lexical-binding: t; -*-
(setq user-emacs-directory "$dirLisp")
(load (expand-file-name "early-init.el" user-emacs-directory) nil t)
(load (expand-file-name "init.el" user-emacs-directory) nil t)
(elpaca-wait)
;; Build Jinx's spell-check module now instead of on first use.
(when (and (fboundp 'jinx--load-module) (executable-find "gcc"))
  (condition-case err (jinx--load-module)
    (error (message "Jinx module not built: %s" (error-message-string err)))))
(message "MOMOMACS-INSTALL-OK")
;; Exit without the usual save-on-exit hooks (recentf, savehist, ...): if
;; Emacs is open, they find its lock on those files and wait for an answer.
(setq kill-emacs-hook nil)
(kill-emacs 0)
"@
# Emacs needs plain UTF-8; Windows PowerShell's -Encoding utf8 adds a BOM.
[IO.File]::WriteAllText($boot, $bootCode, (New-Object Text.UTF8Encoding $false))
$log = Join-Path $Dir 'install.log'
# Emacs prints its progress on stderr; send it to a file so PowerShell
# doesn't treat each line as an error.
$p = Start-Process -FilePath $emacs -ArgumentList @('--batch', '--init-directory', "`"$Dir`"", '-l', "`"$boot`"") `
    -NoNewWindow -Wait -PassThru -RedirectStandardError $log -RedirectStandardOutput "$log.out"
Remove-Item $boot, "$log.out" -ErrorAction SilentlyContinue
$out = Get-Content $log
if (-not ($out -match 'MOMOMACS-INSTALL-OK')) {
    $out | Select-Object -Last 20 | ForEach-Object { Info $_ }
    throw "Package install did not finish. Full log: $log"
}
Info "Done. Log: $log"

Step 'Momomacs is installed'
Info 'Open "Emacs" from the Start menu.'
if (-not $NoSpellCheck) {
    Info 'If spell-checking is off on the first launch, sign out and back in once so'
    Info 'Windows picks up the new PATH.'
}

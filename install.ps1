# oh-my-terminal — Windows / PowerShell installer
#
# Deploys the bundled configs onto a Windows machine by COPYING them into
# place (Windows symlinks need admin / Developer Mode, so we copy instead
# of symlinking like the macOS/Linux install.sh does).
# Any pre-existing target is moved aside to <file>.<timestamp>.bak first.
#
# Usage (run in PowerShell):
#   powershell -ExecutionPolicy Bypass -File install.ps1
#   powershell -ExecutionPolicy Bypass -File install.ps1 -WithDeps
#   powershell -ExecutionPolicy Bypass -File install.ps1 -DryRun
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Help

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$WithDeps,
    [switch]$Help
)

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path
    exit 0
}

# ─── helpers ─────────────────────────────────────────────────────────
function Ok   { Write-Host "✓ $args" }
function Info { Write-Host "• $args" }
function Warn { Write-Host "! $args" }
function Err  { Write-Host "✗ $args" }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$Cfg       = Join-Path $ScriptDir 'configs'
$Fonts     = Join-Path $ScriptDir 'fonts'
$TS        = Get-Date -Format 'yyyyMMddHHmmss'

# ─── target locations ────────────────────────────────────────────────
if ($env:XDG_CONFIG_HOME) {
    $GhosttyDst = Join-Path $env:XDG_CONFIG_HOME 'ghostty\config'
} else {
    $GhosttyDst = Join-Path $env:LOCALAPPDATA 'ghostty\config'
}
$StarshipDst = Join-Path $env:USERPROFILE '.config\starship.toml'
$ProfileDst  = $PROFILE   # e.g. ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

$BackedUp = @()

function Deploy-File {
    param($Src, $Dst, $Label)
    if (-not (Test-Path $Src)) { Warn "source missing, skipped: $Src"; return }

    if (Test-Path $Dst) {
        $same = (Get-FileHash $Src).Hash -eq (Get-FileHash $Dst).Hash
        if ($same) { Ok "[skip] $Label already up to date"; return }
        $bak = "$Dst.$TS.bak"
        if ($DryRun) { Warn "[dry-run] would back up existing $Label -> $bak" }
        else { Copy-Item $Dst $bak -Force; $script:BackedUp += $bak; Warn "backed up existing $Label -> $bak" }
    }

    if ($DryRun) { Info "[dry-run] would copy $Label -> $Dst"; return }
    New-Item -ItemType Directory -Force -Path (Split-Path $Dst) | Out-Null
    Copy-Item $Src $Dst -Force
    Ok "deployed $Label"
}

Write-Host "oh-my-terminal installer — Windows / PowerShell"
Write-Host "repo: $ScriptDir"
if ($DryRun) { Warn "DRY RUN — no changes will be made" }
Write-Host ""

# ─── configs ─────────────────────────────────────────────────────────
Deploy-File (Join-Path $Cfg 'ghostty.config')                 $GhosttyDst  'Ghostty config'
Deploy-File (Join-Path $Cfg 'starship.toml')                  $StarshipDst 'Starship config'
Deploy-File (Join-Path $Cfg 'Microsoft.PowerShell_profile.ps1') $ProfileDst 'PowerShell profile'

# ─── fonts ───────────────────────────────────────────────────────────
Write-Host ""
Info "Installing fonts (MesloLGS NF) -> $env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$FontDst = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
if ($DryRun) {
    Info "[dry-run] would copy *.ttf from $Fonts into $FontDst"
} else {
    New-Item -ItemType Directory -Force -Path $FontDst | Out-Null
    Get-ChildItem $Fonts -Filter *.ttf | ForEach-Object {
        $name = $_.Name
        if (Test-Path (Join-Path $FontDst $name)) { Ok "[skip] font already present: $name" }
        else { Copy-Item $_.FullName (Join-Path $FontDst $name) -Force; Ok "installed font: $name" }
    }
    Warn "If a terminal doesn't see the font, also copy the TTFs into C:\Windows\Fonts (admin)."
}

# ─── optional dependencies ───────────────────────────────────────────
Write-Host ""
$DepWinget = @{
    starship = 'Starship.Starship'; zoxide = 'ajeetdsouza.zoxide'; eza = 'eza.eza'
    bat = 'sharkdp.bat'; ripgrep = 'BurntSushi.ripgrep'; fd = 'fd.fd'
    fzf = 'junegunn.fzf'; fnm = 'Schniz.fnm'; git = 'Git.Git'; pnpm = 'pnpm.pnpm'
}
if ($WithDeps) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Err "winget not found — install it via the App Installer, or install deps manually."
    } else {
        foreach ($name in $DepWinget.Keys) {
            if (Get-Command $name -ErrorAction SilentlyContinue) { Ok "[skip] $name already installed"; continue }
            Info "installing $name ..."
            if (-not $DryRun) {
                try { winget install --exact --id $DepWinget[$name] --accept-package-agreements --accept-source-agreements }
                catch { Warn "failed to install $name (id $($DepWinget[$name])) — install manually" }
            }
        }
    }
} else {
    Info "Tooling checklist (re-run with -WithDeps to auto-install missing ones via winget):"
    foreach ($name in $DepWinget.Keys) {
        if (Get-Command $name -ErrorAction SilentlyContinue) { Write-Host "  ✓ $name" }
        else { Write-Host "  ✗ $name" }
    }
    Warn "fzf & fnm are referenced in the profile but not required."
}

# ─── summary ─────────────────────────────────────────────────────────
Write-Host ""
if ($BackedUp.Count -gt 0) {
    Info "Backed up $($BackedUp.Count) existing file(s). To restore:"
    foreach ($b in $BackedUp) { Write-Host "    Copy-Item `"$b`" `"$($b -replace "\.$TS\.bak$","")`"" }
}
if ($DryRun) { Warn "Dry run complete — re-run without -DryRun to apply."; exit 0 }
Write-Host "Done. Reload your profile with:  . `$PROFILE"
Write-Host "Ghostty will pick up the new config on next launch."

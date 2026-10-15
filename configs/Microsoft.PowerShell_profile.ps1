# ─── oh-my-terminal: PowerShell profile ──────────────────────────────
# Windows / PowerShell counterpart of configs/zshrc.
# Edit your profile with:   notepad $PROFILE   (or: code $PROFILE)
# Then reload with:         . $PROFILE
#
# Tools referenced here are installed separately (scoop / winget / brew).
# Every block is guarded with Get-Command so a missing tool is simply skipped.

# ─── Starship prompt ────────────────────────────────────────────────
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell)
}

# ─── Homebrew (Windows) ─────────────────────────────────────────────
# Default Windows brew prefix; adjust if yours differs.
$brewPrefix = "C:\Program Files\Homebrew"
if (Test-Path $brewPrefix) {
    $env:PATH = "$brewPrefix\bin;$brewPrefix\sbin;$env:PATH"
}

# ─── Modern CLI aliases ─────────────────────────────────────────────
# ls -> eza, cat -> bat, find -> fd, grep -> rg, top -> btop, lg -> lazygit
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls  { eza --icons --group-directories-first @args }
    function ll  { eza -la --icons --group-directories-first @args }
    function lt  { eza --tree --icons --level=2 @args }
}
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat { bat @args }
}
if (Get-Command fd -ErrorAction SilentlyContinue) {
    function find { fd @args }
}
if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep { rg @args }
}
if (Get-Command btop -ErrorAction SilentlyContinue) {
    function top { btop @args }
}
if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    function lg { lazygit @args }
}

# ─── zoxide (smart cd) ──────────────────────────────────────────────
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    (& zoxide init powershell | Out-String) | Invoke-Expression
}

# ─── fnm (Node version manager) ─────────────────────────────────────
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    & fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
}

# ─── fzf (optional, via the PSFzf module) ───────────────────────────
# Install once with:  Install-Module -Name PSFzf -Scope CurrentUser
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' `
                    -PSReadlineChordReverseHistory 'Ctrl+r'
}

# ─── SSH key switcher ───────────────────────────────────────────────
# Usage:  set-ssh-key my-key-name
function set-ssh-key {
    param([string]$key)
    $full = Join-Path $env:USERPROFILE ".ssh\$key"
    if (-not (Test-Path $full)) {
        Write-Error "Key not found: $full"
        Write-Host "Available keys:"
        Get-ChildItem (Join-Path $env:USERPROFILE ".ssh\*.pub") -ErrorAction SilentlyContinue |
            ForEach-Object { "  " + $_.BaseName }
        return
    }
    ssh-add -D
    ssh-add $full
    Write-Host "Active SSH key: $key"
}

# ─── pnpm ───────────────────────────────────────────────────────────
$env:PNPM_HOME = Join-Path $env:USERPROFILE "AppData\Local\pnpm"
if ($env:PATH -notlike "*$env:PNPM_HOME*") {
    $env:PATH = "$env:PNPM_HOME;$env:PATH"
}

# ─── Rust / cargo ───────────────────────────────────────────────────
if (Test-Path (Join-Path $env:USERPROFILE ".cargo\bin")) {
    $env:PATH = "$(Join-Path $env:USERPROFILE '.cargo\bin');$env:PATH"
}

# ─── Java / Tomcat / Go / Maven ─────────────────────────────────────
# These are machine-specific. Uncomment and point them at YOUR installs.
# $env:JAVA_HOME = "C:\Program Files\Java\jdk-11"
# $env:PATH    += ";$env:JAVA_HOME\bin"
# $env:PATH    += ";C:\Program Files\apache-maven-3.9.8\bin"
# $env:PATH    += ";C:\path\to\apache-tomcat-9.0.96\bin"
# $env:PATH    += ";$(Join-Path $env:USERPROFILE 'go\bin')"

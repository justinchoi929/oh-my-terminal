#!/usr/bin/env bash
#
# oh-my-terminal — one-command installer
#
# Deploys the bundled configs to your system by symlinking them into place
# (the repo stays the single source of truth). Any pre-existing file is
# moved aside with a timestamped `.bak` suffix before it is replaced, so
# nothing is ever destroyed.
#
# Usage:
#   bash install.sh                 # deploy configs + fonts, print a tool checklist
#   bash install.sh --with-deps     # also install missing Homebrew packages
#   bash install.sh --dry-run       # show what would happen, change nothing
#   bash install.sh --help          # this help
#
set -euo pipefail

# ─── colors ──────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  c_reset=$'\033[0m'; c_ok=$'\033[32m'; c_info=$'\033[36m'
  c_warn=$'\033[33m'; c_err=$'\033[31m'; c_bold=$'\033[1m'
else
  c_reset=''; c_ok=''; c_info=''; c_warn=''; c_err=''; c_bold=''
fi
ok()   { printf '%s✓%s %s\n' "$c_ok" "$c_reset" "$1"; }
info() { printf '%s•%s %s\n' "$c_info" "$c_reset" "$1"; }
warn() { printf '%s!%s %s\n' "$c_warn" "$c_reset" "$1"; }
err()  { printf '%s✗%s %s\n' "$c_err" "$c_reset" "$1" >&2; }

# ─── parse args ──────────────────────────────────────────────────────
DRY_RUN=false
WITH_DEPS=false
for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=true ;;
    --with-deps) WITH_DEPS=true ;;
    --help|-h)   sed -n '3,16p' "$0"; exit 0 ;;
    *) err "unknown arg: $arg (try --help)"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CFG="$SCRIPT_DIR/configs"
FONTS="$SCRIPT_DIR/fonts"
TS="$(date +%Y%m%d%H%M%S)"

# ─── target locations ────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  GHOSTTY_DST="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  FONT_DST="$HOME/Library/Fonts"
  PLATFORM="macOS"
else
  GHOSTTY_DST="$HOME/.config/ghostty/config"
  FONT_DST="$HOME/.local/share/fonts"
  PLATFORM="Linux"
fi

declare -a BACKED_UP=()

# ─── core: backup + symlink ──────────────────────────────────────────
link_file() {
  local src="$1" dst="$2" label="$3"
  if [[ ! -e "$src" ]]; then warn "source missing, skipped: $src"; return 1; fi

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      ok "[skip] $label already linked"
      return 0
    fi
    local old_bak="${dst}.${TS}.bak"
    if $DRY_RUN; then
      warn "[dry-run] would back up existing symlink -> $old_bak"
    else
      mv "$dst" "$old_bak"
      BACKED_UP+=("$old_bak")
      warn "backed up existing symlink -> $old_bak"
    fi
  elif [[ -e "$dst" ]]; then
    local bak="${dst}.${TS}.bak"
    if $DRY_RUN; then
      warn "[dry-run] would back up existing $label -> $bak"
    else
      mv "$dst" "$bak"
      BACKED_UP+=("$bak")
      warn "backed up existing $label -> $bak"
    fi
  fi

  if $DRY_RUN; then
    info "[dry-run] would link $label -> $dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  ok "linked $label"
}

echo "${c_bold}oh-my-terminal installer — $PLATFORM${c_reset}"
echo "repo: $SCRIPT_DIR"
$DRY_RUN && warn "DRY RUN — no changes will be made"
echo

# ─── configs ─────────────────────────────────────────────────────────
link_file "$CFG/ghostty.config" "$GHOSTTY_DST" "Ghostty config"
link_file "$CFG/starship.toml"  "$HOME/.config/starship.toml" "Starship config"
link_file "$CFG/zshrc"          "$HOME/.zshrc" "Zsh config"
link_file "$CFG/gitconfig"      "$HOME/.gitconfig" "Git config"

# ─── fonts ───────────────────────────────────────────────────────────
echo
info "Installing fonts (MesloLGS NF) -> $FONT_DST"
if $DRY_RUN; then
  info "[dry-run] would copy *.ttf from $FONTS into $FONT_DST"
else
  mkdir -p "$FONT_DST"
  shopt -s nullglob
  for f in "$FONTS"/*.ttf; do
    name="$(basename "$f")"
    if [[ -e "$FONT_DST/$name" ]]; then
      ok "[skip] font already present: $name"
    else
      cp "$f" "$FONT_DST/$name"
      ok "installed font: $name"
    fi
  done
  shopt -u nullglob
  if [[ "$PLATFORM" == "Linux" ]]; then
    command -v fc-cache >/dev/null && fc-cache -f "$FONT_DST" >/dev/null 2>&1 && ok "refreshed font cache"
  fi
fi

# ─── optional dependencies ───────────────────────────────────────────
echo
DEPS=(starship zsh-autosuggestions zsh-syntax-highlighting zoxide eza bat fzf fnm ripgrep fd)
if $WITH_DEPS; then
  if ! command -v brew >/dev/null; then
    err "Homebrew not found — cannot install deps. Install it from https://brew.sh first."
  else
    for d in "${DEPS[@]}"; do
      if brew list "$d" >/dev/null 2>&1; then
        ok "[skip] $d already installed"
      else
        info "installing $d ..."
        $DRY_RUN || brew install "$d"
      fi
    done
  fi
else
  info "Tooling checklist (run with --with-deps to auto-install missing ones):"
  for d in "${DEPS[@]}"; do
    if command -v "$d" >/dev/null 2>&1 || brew list "$d" >/dev/null 2>&1; then
      printf '  %s✓%s %s\n' "$c_ok" "$c_reset" "$d"
    else
      printf '  %s✗%s %s\n' "$c_warn" "$c_reset" "$d"
    fi
  done
  warn "Note: fzf & fnm are referenced in .zshrc but not currently installed."
fi

# ─── summary ─────────────────────────────────────────────────────────
echo
if [[ ${#BACKED_UP[@]} -gt 0 ]]; then
  info "Backed up ${#BACKED_UP[@]} existing file(s). To restore:"
  for b in "${BACKED_UP[@]}"; do echo "    mv \"$b\" \"${b%.${TS}.bak}\""; done
fi
$DRY_RUN && warn "Dry run complete — re-run without --dry-run to apply." && exit 0
echo "${c_bold}Done.${c_reset} Restart your terminal (or run ${c_ok}exec zsh${c_reset}) to apply."
echo "Ghostty will pick up the new config on next launch."

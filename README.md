# oh-my-terminal

My personal modern terminal setup.
All configs for Ghostty, Zsh, and Starship live in one repo and are deployed as **symlinks** (the repo is the single source of truth) — re-install on a new machine with one command.

## Stack

| Area | Tool | Notes |
|------|------|-------|
| Terminal | **Ghostty** | Catppuccin Mocha, MesloLGS NF |
| Shell | **Zsh** | autosuggestions, syntax-highlighting, better completion |
| Prompt | **Starship** | Catppuccin Mocha, multi-language version segments |
| Smart cd | **zoxide** | replaces `cd` |
| Fuzzy find | **fzf** (optional) | file/dir search via `fd` |
| Modern CLI | `eza` / `bat` / `fd` / `rg` | replace `ls` / `cat` / `find` / `grep` |
| Font | **MesloLGS NF** | bundled in `fonts/` for offline install |

The bundled `.zshrc` also carries my personal env (JDK multi-version, Tomcat, Go, Maven, pnpm, Rust/cargo), `set-ssh-key`, and common aliases. Windows users: see `configs/Microsoft.PowerShell_profile.ps1` (PowerShell equivalent) under Platform notes.

## Quick start

```bash
git clone <your-repo-url> oh-my-terminal
cd oh-my-terminal
bash install.sh                 # deploy configs + fonts, print a tool checklist
bash install.sh --with-deps     # also install missing Homebrew packages
bash install.sh --dry-run       # preview only, change nothing
```

**Windows / PowerShell:** use `install.ps1` instead — native Windows Ghostty reads `%LOCALAPPDATA%\ghostty\config`, not `~/.config`:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1            # deploy + fonts + tool checklist
powershell -ExecutionPolicy Bypass -File install.ps1 -WithDeps   # also install missing deps via winget
powershell -ExecutionPolicy Bypass -File install.ps1 -DryRun     # preview only
```

> ⚠️ On Windows we **copy** (not symlink) to avoid admin / Developer Mode requirements, so local edits don't flow back to the repo.

Restart your terminal (`exec zsh`, or relaunch Ghostty / reopen PowerShell) afterwards.

## What the installer does

1. **Backs up first** — any existing target is moved to `<file>.<timestamp>.bak`; restore commands are printed at the end.
2. **Symlinks** configs into place, so local edits flow back into the repo and are tracked by `git`.
3. **Installs fonts** into `~/Library/Fonts` (macOS) or `~/.local/share/fonts` (Linux).
4. **Checks / installs deps** — `--with-deps` uses Homebrew; otherwise prints a ✅/❌ checklist.

> 💡 Windows users: use `install.ps1` — same idea (backup + copy + fonts + optional winget deps) but targets Windows paths and **copies** instead of symlinking.

## File mapping

| Repo file | macOS | Linux | Windows |
|-----------|-------|-------|---------|
| `configs/ghostty.config` | `~/Library/Application Support/com.mitchellh.ghostty/config` | `~/.config/ghostty/config` | `%LOCALAPPDATA%\ghostty\config` |
| `configs/starship.toml` | `~/.config/starship.toml` | `~/.config/starship.toml` | `~/.config\starship.toml` |
| `configs/zshrc` | `~/.zshrc` | `~/.zshrc` | — (use the PowerShell profile below) |
| `configs/Microsoft.PowerShell_profile.ps1` | — | — | `$PROFILE` (`~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`) |

> Git config is **not** managed here on purpose: `~/.gitconfig` holds your machine-local identity (and sometimes proxies/credentials helpers), which has no business living in a public repo. Configure it yourself with `git config --global user.name … user.email …`.

## Layout

```
oh-my-terminal/
├── install.sh   # deployer for macOS / Linux (backup + symlink + fonts + deps)
├── install.ps1  # deployer for Windows / PowerShell (backup + copy + fonts + winget)
├── configs/   (ghostty.config, starship.toml, zshrc, Microsoft.PowerShell_profile.ps1)
├── fonts/     (MesloLGS NF)
├── README.md
├── README_CN.md
└── .gitignore
```

## Platform notes

- **macOS (primary):** Ghostty config lives at `~/Library/Application Support/com.mitchellh.ghostty/config`; the script handles it.
- **Linux / WSL:** Ghostty isn't in apt; the script places the config at `~/.config/ghostty/config`. Install a terminal (Ghostty / WezTerm / Kitty) yourself.
- **Windows / PowerShell:**
  - Deploy with `install.ps1` (don't use `install.sh` — it detects Windows and tells you to switch).
  - Ghostty config → `%LOCALAPPDATA%\ghostty\config`; Starship config → `~/.config\starship.toml` (= `C:\Users\you\.config\starship.toml`); PowerShell profile → `$PROFILE`.
  - Shell config is `configs/Microsoft.PowerShell_profile.ps1` (the PowerShell equivalent of `.zshrc`: Starship init, `eza/bat/fd/rg` aliases, `zoxide`, `fnm`, `set-ssh-key`, etc., rewritten in PowerShell).
  - Fonts install to the per-user fonts dir `%LOCALAPPDATA%\Microsoft\Windows\Fonts` (no admin needed); if a terminal can't see them, also copy the TTFs into `C:\Windows\Fonts`.
  - The Java / Tomcat / Go / Maven paths in that profile are **commented examples** — point them at your real Windows installs.

See `README_CN.md` for the full Chinese write-up and design rationale.

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

The bundled `.zshrc` also carries my personal env (JDK multi-version, Tomcat, Go, Maven, pnpm, Rust/cargo), `set-ssh-key`, and common aliases.

## Quick start

```bash
git clone <your-repo-url> oh-my-terminal
cd oh-my-terminal
bash install.sh                 # deploy configs + fonts, print a tool checklist
bash install.sh --with-deps     # also install missing Homebrew packages
bash install.sh --dry-run       # preview only, change nothing
```

Restart your terminal (`exec zsh`) or relaunch Ghostty afterwards.

## What the installer does

1. **Backs up first** — any existing target is moved to `<file>.<timestamp>.bak`; restore commands are printed at the end.
2. **Symlinks** configs into place, so local edits flow back into the repo and are tracked by `git`.
3. **Installs fonts** into `~/Library/Fonts` (macOS) or `~/.local/share/fonts` (Linux).
4. **Checks / installs deps** — `--with-deps` uses Homebrew; otherwise prints a ✅/❌ checklist.

## File mapping

| Repo file | macOS target | Linux target |
|-----------|--------------|--------------|
| `configs/ghostty.config` | `~/Library/Application Support/com.mitchellh.ghostty/config` | `~/.config/ghostty/config` |
| `configs/starship.toml` | `~/.config/starship.toml` | `~/.config/starship.toml` |
| `configs/zshrc` | `~/.zshrc` | `~/.zshrc` |
| `configs/gitconfig` | `~/.gitconfig` | `~/.gitconfig` |


## Layout

```
oh-my-terminal/
├── install.sh
├── configs/   (ghostty.config, starship.toml, zshrc, gitconfig)
├── fonts/     (MesloLGS NF)
├── README.md
├── README_CN.md
└── .gitignore
```

See `README_CN.md` for the full Chinese write-up and design rationale.

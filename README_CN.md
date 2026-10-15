# oh-my-terminal

一套属于我自己的现代化终端配置。
把 Ghostty、Zsh、Starship 以及各种 CLI 工具的配置集中在一个仓库里，**以仓库为唯一可信源**（dotfiles 风格），换机 / 重装时一条命令即可恢复。

---

## 包含的组件（技术栈）

| 类别 | 工具 | 说明 |
|------|------|------|
| 终端模拟器 | **Ghostty** | GPU 加速、现代简约；Catppuccin Mocha 主题，MesloLGS NF 字体 |
| Shell | **Zsh** | 自带 autosuggestions、syntax-highlighting、补全增强 |
| 提示符 | **Starship** | Catppuccin Mocha 主题，跨语言版本段（node/go/rust/java…） |
| 智能跳转 | **zoxide** | 替代 `cd` 的智能目录记忆 |
| 模糊查找 | **fzf**（可选） | 配合 `fd` 做文件/目录模糊搜索 |
| 现代替代品 | `eza` / `bat` / `fd` / `rg` | 替代 `ls` / `cat` / `find` / `grep` |
| 字体 | **MesloLGS NF** | Nerd Font，离线打包在 `fonts/` |

仓库内的 `.zshrc` 还包含了我个人的环境变量（JDK 多版本、Tomcat、Go、Maven、pnpm、Rust/cargo）以及 `set-ssh-key`、常用别名等。

---

## 快速开始

```bash
git clone <你的仓库地址> oh-my-terminal
cd oh-my-terminal
bash install.sh            # 部署配置 + 字体，并列出缺失工具清单
```

可选参数：

```bash
bash install.sh --with-deps   # 额外用 Homebrew 安装缺失的依赖（starship/zoxide/eza/bat/fzf/fnm…）
bash install.sh --dry-run     # 只预览会做什么，不改动任何文件
bash install.sh --help        # 查看帮助
```

部署完成后，**重启终端**（`exec zsh`）或重新打开 Ghostty 即可生效。

---

## 安装脚本做了什么

1. **备份优先**：部署前，任何已存在的目标文件都会被移动到 `<文件名>.<时间戳>.bak`，绝不原地覆盖。脚本结尾会打印恢复命令。
2. **软链部署**：配置以软链接形式放入系统路径，因此**以后在系统里改配置会直接写回仓库**，可用 `git` 追踪变更。
3. **字体安装**：把 `fonts/` 里的 MesloLGS NF 复制到 `~/Library/Fonts`（macOS）或 `~/.local/share/fonts`（Linux）。已存在则跳过。
4. **依赖检查 / 安装**：`--with-deps` 时用 Homebrew 补齐缺失工具；默认只打印一份 ✅/❌ 清单。

### 文件映射

| 仓库文件 | 系统目标（macOS） | 系统目标（Linux） |
|----------|-------------------|-------------------|
| `configs/ghostty.config` | `~/Library/Application Support/com.mitchellh.ghostty/config` | `~/.config/ghostty/config` |
| `configs/starship.toml` | `~/.config/starship.toml` | `~/.config/starship.toml` |
| `configs/zshrc` | `~/.zshrc` | `~/.zshrc` |
| `configs/gitconfig` | `~/.gitconfig` | `~/.gitconfig` |


---

## 目录结构

```
oh-my-terminal/
├── install.sh          # 一键部署脚本（带备份 / 软链 / 字体 / 依赖）
├── configs/            # 所有配置文件（dotfiles）
│   ├── ghostty.config
│   ├── starship.toml
│   ├── zshrc
│   └── gitconfig
├── fonts/              # MesloLGS NF（离线安装用）
├── README.md           # English
├── README_CN.md        # 中文（本文件）
└── .gitignore
```

---

## 设计取舍

- **Ghostty 而非 iTerm2**：原生、极快、配置即代码，跨平台行为一致。
- **Starship 而非 Powerlevel10k**：Rust 编写、跨 shell、配置是单一 TOML，迁移成本低。
- **Homebrew 直接装插件**（zsh-autosuggestions / syntax-highlighting）而非 Oh My Zsh / zinit，更轻、更可控。
- **软链而非拷贝**：仓库始终是源，本地改动自动回流，便于版本管理。

---

## 自定义

所有配置都在 `configs/` 里，改完直接生效（Zsh 改完 `exec zsh`，Ghostty 改完重开窗口）。常用入口：

- 改主题 / 字体 / 内边距 → `configs/ghostty.config`
- 改提示符样式 → `configs/starship.toml`
- 改别名 / 环境变量 / 插件 → `configs/zshrc`

---

## 平台说明

- **macOS（主力）**：Ghostty 配置默认在 `~/Library/Application Support/com.mitchellh.ghostty/config`，脚本已自动处理。
- **Linux / WSL**：Ghostty 不在 apt 源中，脚本会把配置放到 `~/.config/ghostty/config`；终端模拟器需自行安装（Ghostty / WezTerm / Kitty 等）。

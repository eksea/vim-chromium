# Neovim 配置 - 面向大型代码库的开发环境

> 一个偏向 Chromium / Android / C++ / Java 大仓开发的 Neovim 配置，强调搜索、Git、Diff、终端和大仓可用性。

![Neovim](https://img.shields.io/badge/Neovim-0.11%2B-green.svg)
![Lua](https://img.shields.io/badge/Lua-5.1+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

## ✨ 当前特性

- 🚀 **实时全文搜索**：`fzf.vim + ripgrep`，支持搜索历史、预览、目录内搜索
- 📁 **文件树**：`nvim-tree` 自动定位当前文件，记忆侧边栏宽度
- 🔍 **Git 集成**：`gitsigns + fugitive + lazygit`
- 🎯 **Diff / Merge**：为 Git 冲突和大型改动审阅做了快捷键优化
- 🖥️ **终端工作流**：`toggleterm` 提供右侧终端、底部终端、浮动 Lazygit
- 🌲 **语法高亮**：`treesitter` + GN / Java / Bash / Lua / C/C++
- 🧠 **LSP**：`clangd / lua_ls / bashls / jdtls`
- 🔎 **符号搜索**：`fzf-lua + aerial`
- 📝 **Markdown 预览**：浏览器实时预览 Markdown

## 📦 环境要求

### 必需依赖

```bash
# Neovim 0.11+
# Ubuntu / Debian
sudo apt install neovim

# macOS
brew install neovim

# Arch Linux
sudo pacman -S neovim
```

### 强烈推荐依赖

```bash
# ripgrep
sudo apt install ripgrep        # Ubuntu / Debian
brew install ripgrep           # macOS
sudo pacman -S ripgrep         # Arch Linux

# fzf
sudo apt install fzf           # Ubuntu / Debian
brew install fzf               # macOS
sudo pacman -S fzf             # Arch Linux

# 剪贴板支持
sudo apt install xclip xsel    # Ubuntu / Debian
sudo pacman -S xclip           # Arch Linux

# lazygit（可选，但推荐）
brew install lazygit           # macOS
sudo pacman -S lazygit         # Arch Linux
```

### LSP / 开发工具（按需）

```bash
# clangd / lua-language-server / bash-language-server / jdtls
# 可通过系统包管理器或 Mason 安装
```

## 🚀 安装

### 方式一：直接作为 `~/.config/nvim`

```bash
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true
git clone https://github.com/eksea/vim-chromium ~/.config/nvim
nvim
```

首次启动时 `lazy.nvim` 会自动安装插件。

### 方式二：以仓库目录使用（当前配置默认方式）

当前 `init.lua` 中多个脚本路径写死为：

```lua
~/github/vim-chromium/.vim/bin/
```

如果你希望开箱即用，建议仓库就放在：

```bash
~/github/vim-chromium
```

如果你想改成 `~/.config/nvim` 方式使用，请把 `init.lua` 中所有：

```lua
~/github/vim-chromium/.vim/bin/
```

替换为：

```lua
~/.config/nvim/.vim/bin/
```

## 📂 当前仓库结构

```text
.
├── init.lua
├── README.md
├── .vim/
│   └── bin/
│       ├── fzf-history.py
│       ├── preview-buffer.sh
│       ├── preview.sh
│       ├── rg-fzf-dir.sh
│       └── rg-fzf.sh
└── 其他临时/辅助文件
```

## 🎯 常用快捷键

> `Leader` 键是 `Space`

### 搜索 / 文件 / Buffer

| 快捷键 | 功能 |
|---|---|
| `<Leader>ff` | 查找文件 |
| `<Leader>fa` | 查找所有文件（包含 `.gitignore` 忽略的文件） |
| `<Leader>ss` | 全局搜索内容 |
| `<Leader>si` | 在指定目录中搜索内容 |
| `<Leader>oi` | 在指定目录中查找文件 |
| `<Leader>bb` | 切换缓冲区 |
| `<Leader>bd` | 关闭当前 buffer |
| `<Leader>fs` | 当前文件符号搜索 |
| `<Leader>fw` | 工作区符号搜索 |
| `<Leader>fS` | 实时工作区符号搜索 |

### 文件树 / 路径复制

| 快捷键 | 功能 |
|---|---|
| `<Leader>e` | 打开/关闭文件树 |
| `<Leader>r` | 在文件树中定位当前文件 |
| `<Leader>fp` | 复制完整路径 |
| `<Leader>fr` | 复制相对路径 |
| `<Leader>fn` | 复制文件名 |
| `<Leader>fd` | 复制目录路径 |

### 终端 / Lazygit

| 快捷键 | 功能 |
|---|---|
| `<Leader>tr` | 右侧终端（vertical split） |
| `<Leader>tb` | 底部终端 |
| `<Leader>g` | Lazygit |
| `F12` | ToggleTerm 默认浮动终端 |
| `Esc` | 关闭当前终端窗口 |

### Git / Diff

| 快捷键 | 功能 |
|---|---|
| `]c` | 下一个修改块 |
| `[c` | 上一个修改块 |
| `<Leader>hp` | 预览 hunk |
| `<Leader>hs` | 暂存 hunk |
| `<Leader>hr` | 撤销 hunk |
| `<Leader>hS` | 暂存整个文件 |
| `<Leader>hu` | 撤销暂存 |
| `<Leader>hR` | 重置整个文件 |
| `<Leader>hb` | 显示完整 blame |
| `<Leader>hd` | Diff 当前文件 |
| `<Leader>hD` | Diff HEAD |
| `<Leader>gs` | Git status |
| `<Leader>gd` | 垂直 Git diff |

### Diff 模式（三方合并）

| 快捷键 | 功能 |
|---|---|
| `<Leader>1` | 采用 LOCAL |
| `<Leader>2` | 采用 BASE |
| `<Leader>3` | 采用 REMOTE |
| `<Leader>u` | 刷新 diff |
| `<Leader>do` | 关闭 diff 模式 |

### 窗口 / 跳转 / 其他

| 快捷键 | 功能 |
|---|---|
| `<C-h>` | 到左窗口 |
| `<C-j>` | 到下窗口 |
| `<C-k>` | 到上窗口 |
| `<C-l>` | 到右窗口 |
| `{` | 上一个符号 |
| `}` | 下一个符号 |
| `<Leader>jf` | 跳到当前符号开头 |
| `<Leader>jh` | 跳到上一级符号 |
| `<Leader>m` | Markdown 预览 |
| `gcc` / `gc` | 注释 |

## 🔎 搜索工作流

### 全局搜索

```vim
<Leader>ss
```

打开后：

- 输入普通关键词：默认 `smart-case + hidden`
- 可以直接传 ripgrep 原生参数
- 右侧有预览窗口

### 搜索历史

在搜索输入框中：

| 按键 | 行为 |
|---|---|
| `↑` | 在历史中向上翻，且会根据当前输入过滤历史 |
| `↓` | 在历史中向下翻 |
| `Ctrl-k` | 在候选结果里上移 |
| `Ctrl-j` | 在候选结果里下移 |

> 也就是说：**上下键固定翻历史，`Ctrl-j/k` 固定翻候选列表。**

### 在指定目录中搜索

```vim
<Leader>si
```

输入一个目录后，只在该目录下做内容搜索。

### 常见 ripgrep 用法

```text
hello
-i hello
--no-ignore hello
-t cpp TODO
-t java ClassName
-F "literal string"
```

当前搜索脚本的默认行为：

- 少于 3 个字符时不触发搜索
- 默认带 `--smart-case --hidden`
- 固定排除：`.git/`、`out/`、`mtout/`、`node_modules/`

## 🧠 LSP / 符号导航

当前配置启用：

- `clangd`
- `lua_ls`
- `bashls`
- `jdtls`

常用 LSP 快捷键：

| 快捷键 | 功能 |
|---|---|
| `gd` | 跳转定义 |
| `gD` | 跳转声明 |
| `gr` | 查找引用（FzfLua） |
| `K` | hover |
| `<Leader>rn` | rename |
| `<Leader>ca` | code action |
| `[d` | 上一个诊断 |
| `]d` | 下一个诊断 |

## 🔌 当前插件列表（按现状）

| 插件 | 用途 |
|---|---|
| `lazy.nvim` | 插件管理 |
| `nvim-tree.lua` | 文件树 |
| `fzf` / `fzf.vim` | 文件/内容搜索 |
| `fzf-lua` | LSP / 符号搜索 |
| `toggleterm.nvim` | 终端 |
| `vim-fugitive` | Git 命令集成 |
| `gitsigns.nvim` | Git hunk 显示 |
| `nvim-treesitter` | 语法高亮 |
| `nvim-lspconfig` | LSP |
| `nvim-cmp` | 自动补全 |
| `aerial.nvim` | 符号大纲 / 导航 |
| `vim-commentary` | 注释 |
| `vim-gn` | GN 文件语法 |
| `auto-session` | 会话恢复 |
| `papercolor-theme` | 主题 |
| `markdown-preview.nvim` | Markdown 预览 |
| `neoscroll.nvim` | 平滑滚动 |

> 旧版 README 中的 `vim-floaterm` 已不再使用，当前终端实现是 `toggleterm.nvim`。

## 🐛 故障排除

### 1. 搜索功能无结果

```bash
which rg
which fzf
```

再确认脚本路径与 `init.lua` 中写死路径一致：

```bash
ls -la ~/github/vim-chromium/.vim/bin/
```

### 2. 剪贴板不工作

```bash
nvim --version | grep clipboard
```

Linux 下通常需要：

```bash
sudo apt install xclip xsel
```

### 3. Treesitter / 插件报错

```vim
:TSUpdate
:Lazy clean
:Lazy sync
```

### 4. Git 状态不显示

先确认当前目录本身是 Git 仓库：

```bash
git status
```

### 5. Java / LSP 不工作

请确认：

- Neovim 版本足够新（建议 0.11+）
- 对应 LSP 已安装
- Java 项目根目录能被 `pom.xml` 等标记识别

## 🔧 自定义建议

### 修改脚本路径

如果你不是在 `~/github/vim-chromium` 下运行本配置，优先统一替换 `init.lua` 中的：

```lua
~/github/vim-chromium/.vim/bin/
```

### 修改主题

直接替换 `PaperColor` 主题块即可。

### 修改缩进

```lua
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
```

### 针对大仓做进一步优化

当前已经有一些大仓优化（如 `clangd` 参数、`updatetime`、文件树行为），如果还想更激进，可以继续调：

```lua
opt.updatetime = 300
opt.timeoutlen = 500
```

## 🤝 贡献

欢迎提交 Issue / PR，也欢迎直接按你的工作流继续定制。

## 📄 许可证

MIT License

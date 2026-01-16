# Neovim 配置 - 现代化开发环境

> 一个为大型项目（如 Chromium）优化的 Neovim 配置，提供强大的文件管理、搜索、Git 集成等功能。

![Neovim](https://img.shields.io/badge/Neovim-0.8+-green.svg)
![Lua](https://img.shields.io/badge/Lua-5.1+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

## ✨ 特性

- 🚀 **快速搜索** - 基于 FZF + Ripgrep 的实时模糊搜索
- 📁 **智能文件树** - NvimTree 自动定位、宽度记忆
- 🔍 **Git 集成** - 实时显示修改状态、blame 信息
- 🎨 **语法高亮** - Treesitter 增强的语法解析
- 🖥️ **浮动终端** - 快速调用终端和 Lazygit
- ⚡ **性能优化** - 针对大型代码库优化
- 🎯 **Diff 工具** - 强大的三方合并支持

## 📦 快速开始

### 1. 前置依赖

#### 必需依赖

```bash
# Neovim >= 0.8
# Ubuntu/Debian
sudo apt install neovim

# macOS
brew install neovim

# Arch Linux
sudo pacman -S neovim
```

#### 推荐依赖

```bash
# Ripgrep (搜索引擎)
# Ubuntu/Debian
sudo apt install ripgrep

# macOS
brew install ripgrep

# Arch Linux
sudo pacman -S ripgrep

# FZF (模糊搜索)
# Ubuntu/Debian
sudo apt install fzf

# macOS
brew install fzf

# Arch Linux
sudo pacman -S fzf

# 剪贴板支持
# Ubuntu/Debian
sudo apt install xclip xsel

# macOS (默认支持)

# Arch Linux
sudo pacman -S xclip

# Lazygit (可选，用于 Git 管理)
# Ubuntu/Debian
sudo add-apt-repository ppa:lazygit-team/release
sudo apt update
sudo apt install lazygit

# macOS
brew install lazygit

# Arch Linux
sudo pacman -S lazygit
```

### 2. 安装配置

```bash
# 1. 备份现有配置（如果有）
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup

# 2. 克隆本仓库
git clone https://github.com/eksea/vim-chromium ~/.config/nvim

# 3. 赋予脚本执行权限
chmod +x ~/.config/nvim/bin/*.sh

# 4. 启动 Neovim（自动安装插件）
nvim
```

首次启动时，Lazy.nvim 会自动安装所有插件，请耐心等待。

### 3. 配置脚本路径

编辑 `~/.config/nvim/init.lua`，修改脚本路径：

```lua
-- 将以下路径
~/github/vim-chromium/.vim/bin/

-- 修改为
~/.config/nvim/bin/
```

### 4. 配置 Git（可选但推荐）

```bash
# 配置 Neovim 作为 Git 的 diff 和 merge 工具
git config --global diff.tool nvimdiff
git config --global difftool.nvimdiff.cmd 'nvim -d "$LOCAL" "$REMOTE"'
git config --global difftool.prompt false

git config --global merge.tool nvimdiff
git config --global mergetool.nvimdiff.cmd 'nvim -d "$LOCAL" "$BASE" "$REMOTE" "$MERGED" -c "wincmd J"'
git config --global mergetool.prompt false
git config --global mergetool.keepBackup false
```

## 🎯 核心快捷键

> Leader 键为 `Space`

### 文件管理

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<Space>e` | 打开/关闭文件树 | NvimTree |
| `<Space>r` | 定位当前文件 | 在文件树中定位 |
| `<Space>o` | 查找文件 | FZF 文件搜索 |
| `<Space>s` | 全局搜索内容 | Ripgrep 实时搜索 |
| `<Space>b` | 缓冲区列表 | 切换已打开文件 |

### 路径操作

| 快捷键 | 功能 |
|--------|------|
| `<Space>fp` | 复制完整路径 |
| `<Space>fr` | 复制相对路径 |
| `<Space>fn` | 复制文件名 |
| `<Space>fd` | 复制目录路径 |

### 终端

| 快捷键 | 功能 |
|--------|------|
| `<Space>t` | 切换浮动终端 |
| `F12` | 切换浮动终端（备用） |
| `<Space>g` | 打开 Lazygit |
| `Esc` | 退出终端模式 |

### Git 操作

| 快捷键 | 功能 |
|--------|------|
| `]c` | 下一个修改 |
| `[c` | 上一个修改 |
| `<Space>hp` | 预览修改 |
| `<Space>hs` | 暂存修改 |
| `<Space>hr` | 撤销修改 |
| `<Space>hb` | 显示 blame |
| `<Space>gs` | Git status |
| `<Space>gd` | Git diff |

### 窗口导航

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+h` | 切换到左窗口 |
| `Ctrl+l` | 切换到右窗口 |
| `Ctrl+j` | 切换到下窗口 |
| `Ctrl+k` | 切换到上窗口 |

### Diff 模式（三方合并）

| 快捷键 | 功能 |
|--------|------|
| `<Space>1` | 采用 LOCAL（当前分支） |
| `<Space>2` | 采用 BASE（共同祖先） |
| `<Space>3` | 采用 REMOTE（合并分支） |
| `<Space>u` | 刷新 diff |

### 注释

| 快捷键 | 功能 |
|--------|------|
| `gcc` | 注释/取消注释当前行 |
| `gc` + 动作 | 注释（如 `gc3j` 注释 3 行） |

### Markdown

| 快捷键 | 功能 |
|--------|------|
| `<Space>m` | 切换 Markdown 预览 |

## 📂 文件结构

```
~/.config/nvim/
├── init.lua              # 主配置文件
├── bin/                  # 辅助脚本
│   ├── rg-fzf.sh        # Ripgrep + FZF 集成脚本
│   ├── preview.sh       # 搜索预览脚本
│   └── preview-buffer.sh # 缓冲区预览脚本
└── README.md            # 本文件
```

## 🔧 自定义配置

### 修改主题

编辑 `init.lua`，找到主题配置：

```lua
{
  "NLKNguyen/papercolor-theme",
  priority = 1000,
  config = function()
    vim.cmd("colorscheme PaperColor")
  end,
},
```

替换为其他主题，如：

```lua
{
  "folke/tokyonight.nvim",
  priority = 1000,
  config = function()
    vim.cmd("colorscheme tokyonight")
  end,
},
```

### 修改 Leader 键

在 `init.lua` 开头修改：

```lua
vim.g.mapleader = " "  -- 改为其他键，如 ","
```

### 调整缩进

```lua
opt.tabstop = 2        -- 改为 4
opt.softtabstop = 2    -- 改为 4
opt.shiftwidth = 2     -- 改为 4
```

## 🎨 插件列表

| 插件 | 功能 |
|------|------|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | 插件管理器 |
| [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) | 文件树 |
| [fzf.vim](https://github.com/junegunn/fzf.vim) | 模糊搜索 |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git 状态显示 |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | Git 集成 |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | 语法高亮 |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | 状态栏 |
| [vim-floaterm](https://github.com/voldikss/vim-floaterm) | 浮动终端 |
| [vim-commentary](https://github.com/tpope/vim-commentary) | 快速注释 |
| [papercolor-theme](https://github.com/NLKNguyen/papercolor-theme) | 主题 |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Markdown 实时预览 |

## 🐛 故障排除

### 问题 1: 剪贴板不工作

```bash
# 检查剪贴板支持
nvim --version | grep clipboard

# 应该显示 +clipboard，如果是 -clipboard，安装：
sudo apt install xclip xsel  # Ubuntu/Debian
```

### 问题 2: 搜索功能不工作

```bash
# 确保安装了 ripgrep 和 fzf
which rg
which fzf

# 检查脚本路径是否正确
ls -la ~/.config/nvim/bin/
```

### 问题 3: Treesitter 报错

```vim
" 在 Neovim 中执行
:TSUpdate
:TSInstall c cpp lua vim bash
```

### 问题 4: 插件安装失败

```vim
" 清理并重新安装
:Lazy clean
:Lazy sync
```

### 问题 5: Git 状态不显示

```bash
# 确保在 Git 仓库中
git status

# 检查 gitsigns 是否加载
:Lazy load gitsigns.nvim
```

## 📝 使用技巧

### 1. 快速搜索工作流

```vim
" 1. 搜索文件
<Space>o
输入文件名

" 2. 搜索内容
<Space>s
输入关键词

" 3. 在搜索结果中：
Ctrl+j/k  " 上下移动
Enter     " 打开文件
Esc       " 关闭搜索
```

### 2. Git 工作流

```vim
" 1. 查看修改
]c        " 跳转到下一个修改
<Space>hp " 预览修改内容

" 2. 暂存修改
<Space>hs " 暂存当前修改

" 3. 提交
<Space>g  " 打开 Lazygit
```

### 3. 文件树操作

```
在 NvimTree 中：
a         " 新建文件
d         " 删除文件
r         " 重命名
x         " 剪切
c         " 复制
p         " 粘贴
y         " 复制文件名
Y         " 复制相对路径
gy        " 复制绝对路径
H         " 切换隐藏文件
?         " 显示帮助
```

### 4. 搜索高级用法

```vim
" 在特定文件类型中搜索
:Rg -g *.cpp keyword

" 排除特定文件
:Rg -g !test_* keyword

" 搜索多个模式
:Rg "pattern1|pattern2"
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 🙏 致谢

感谢以下项目：
- [Neovim](https://neovim.io/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)

---

**提示：** 如果你在使用 Chromium 等大型项目，建议调整以下设置以获得更好的性能：

```lua
-- 在 init.lua 中添加
opt.updatetime = 300  -- 增加更新延迟
opt.timeoutlen = 500  -- 增加按键超时
```

**Happy Coding! 🚀**

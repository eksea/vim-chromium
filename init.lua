-- ==========================================================================
-- 0. 核心预配置 (必须最先执行！)
-- ==========================================================================
-- [关键] Leader 键必须在所有插件和映射之前设置，否则快捷键会失效
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [关键] 禁用 Netrw (防止与 nvim-tree 冲突)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ==========================================================================
-- 1. 基础设置 (Options)
-- ==========================================================================
local opt = vim.opt

-- UI 设置
opt.number = true
opt.cursorline = true
opt.termguicolors = true -- 开启真彩色支持
opt.background = "dark"

-- 缩进设置 (Chromium 标准: 2空格)
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- 性能与系统集成
opt.updatetime = 100          -- 提高响应速度
opt.clipboard = "unnamedplus" -- 使用系统剪切板 (需安装 xclip 或 wl-clipboard)

-- 黑洞寄存器映射 (保留您的习惯：粘贴/删除不覆盖剪切板)
local keymap = vim.keymap.set
keymap("x", "p", '"_dP')
keymap("v", "d", '"_d')
keymap("v", "c", '"_c')
keymap("v", "x", '"_x')

-- ==========================================================================
-- 2. 插件管理器 Lazy.nvim 引导
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- 3. 插件列表与配置
-- ==========================================================================
require("lazy").setup({
  -- [主题] PaperColor
  {
    "NLKNguyen/papercolor-theme",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme PaperColor")
    end,
  },

  -- [图标支持] (NvimTree 依赖)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- [文件管理器] Nvim-Tree (高性能核心)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          group_empty = true, -- 自动折叠空目录
        },
        filters = {
          dotfiles = true,    -- 默认隐藏 .开头的文件 (按 H 键切换)
        },
        -- [关键新增] 自动定位当前打开的文件
        update_focused_file = {
          enable = true,      -- 开启自动定位
          update_root = false -- false: 保持根目录不变 (适合大项目，防止根目录乱跳)
        },
        -- [性能优化]
        git = {
          enable = true,
          timeout = 500,      -- Git 状态获取超时时间
        },
        actions = {
          open_file = {
            quit_on_open = false, -- 打开文件后不关闭侧边栏
          },
        },
      })
      
      -- 快捷键: <Space>e 打开/关闭文件树
      keymap("n", "<Leader>e", ":NvimTreeToggle<CR>", { silent = true })
      -- 快捷键: <Space>r 手动定位文件 (备用)
      keymap("n", "<Leader>r", ":NvimTreeFindFile<CR>", { silent = true })
    end,
  },

  -- [状态栏] Lualine
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = true,
  },

  -- [语法高亮] Treesitter (防崩溃版)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- 使用 pcall 保护加载
      local status, configs = pcall(require, "nvim-treesitter.configs")
      if not status then return end

      configs.setup({
        ensure_installed = { "c", "cpp", "gn", "lua", "vim", "bash" },
        sync_install = true,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },

  -- [FZF 核心]
  { "junegunn/fzf", build = "./install --bin" },
  { "junegunn/fzf.vim", dependencies = { "junegunn/fzf" } },

  -- [终端] Vim-Floaterm
  {
    "voldikss/vim-floaterm",
    config = function()
      vim.g.floaterm_width = 0.8
      vim.g.floaterm_height = 0.8
      vim.g.floaterm_position = "center"
      vim.g.floaterm_title = " Terminal $1/$2 "
      
      -- 解决退出报错
      vim.api.nvim_create_autocmd("QuitPre", {
        pattern = "*",
        command = "silent! FloatermKill!"
      })
      
      -- 快捷键映射 (F12 等)
      keymap("n", "<F12>", ":FloatermToggle<CR>", { silent = true })
      keymap("t", "<F12>", "<C-\\><C-n>:FloatermToggle<CR>", { silent = true })
      keymap("n", "<S-F12>", ":FloatermNew<CR>", { silent = true })
      keymap("t", "<S-F12>", "<C-\\><C-n>:FloatermNew<CR>", { silent = true })
      keymap("n", "<M-n>", ":FloatermNext<CR>", { silent = true })
      keymap("t", "<M-n>", "<C-\\><C-n>:FloatermNext<CR>", { silent = true })
      keymap("n", "<Leader>g", ":FloatermNew --name=lazygit --height=0.95 --width=0.95 --autoclose=2 lazygit<CR>", { silent = true })
    end,
  },
})

-- ==========================================================================
-- 4. 移植 FZF Vimscript 配置 (原样保留)
-- ==========================================================================
vim.cmd([[
  " 1. FZF 基础命令
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'

  " 2. Live Grep Handler
  function! s:live_grep_handler(args)
    " 请确保以下路径在您的系统中是正确的！
    let helper_script = expand('~/github/vim-chromium/.vim/bin/rg-fzf.sh')
    let preview_script = expand('~/github/vim-chromium/.vim/bin/preview.sh')

    let spec = {}
    let spec.options = [
      \ '--disabled',
      \ '--query', a:args,
      \ '--bind', 'change:reload:'.helper_script.' "{q}"',
      \ '--preview', preview_script . ' {1} {2} "{q}"',
      \ '--preview-window', 'right:50%:noborder:noborder:~2',
      \ '--prompt', 'Rg> '
      \ ]

    call fzf#vim#grep('true', 1, spec, 0)
  endfunction

  command! -nargs=* Rg call s:live_grep_handler(<q-args>)

  " 3. Buffers 命令 (带预览)
  command! -bang Buffers
    \ call fzf#vim#buffers(
    \   {'options': [
    \     '--preview', expand('~/github/vim-chromium/.vim/bin/preview-buffer.sh') . ' {}',
    \     '--preview-window', 'right:50%:noborder:~2:+0'
    \   ]},
    \   <bang>0)
]])

-- ==========================================================================
-- 5. 快捷键映射
-- ==========================================================================
-- FZF 快捷键
keymap("n", "<Leader>o", ":Files<CR>", { silent = true })
keymap("n", "<Leader>f", ":Rg<CR>", { silent = true })
keymap("n", "<Leader>b", ":Buffers<CR>", { silent = true })

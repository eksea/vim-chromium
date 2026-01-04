-- ==========================================================================
-- 0. 核心预配置 (必须最先执行！)
-- ==========================================================================
-- [关键] Leader 键必须在所有插件和映射之前设置
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [关键] 禁用 Netrw (防止与 nvim-tree 冲突)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ==========================================================================
-- 1. 基础设置 (Options)
-- ==========================================================================
local opt = vim.opt

opt.number = true
opt.cursorline = true
opt.termguicolors = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.updatetime = 100

-- [剪切板设置]
-- Neovim 依赖外部工具 (xclip 或 wl-copy)
-- 请确保终端运行了: sudo apt install xclip wl-clipboard
opt.clipboard = "unnamedplus"

-- 黑洞寄存器映射 (保留您的习惯)
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
-- 3. 插件列表
-- ==========================================================================
require("lazy").setup({
  -- [主题]
  {
    "NLKNguyen/papercolor-theme",
    priority = 1000,
    config = function()
      vim.o.background = "dark"
      vim.cmd("colorscheme PaperColor")
    end,
  },

  -- [图标支持]
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- [文件管理器] Nvim-Tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = { width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = true },
        git = { enable = true, timeout = 500 },
        actions = { open_file = { quit_on_open = false } },
      })
      -- 快捷键: <Space>e
      keymap("n", "<Leader>e", ":NvimTreeToggle<CR>", { silent = true })
    end,
  },

  -- [状态栏]
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = true,
  },

  -- [语法高亮] Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local status, configs = pcall(require, "nvim-treesitter.configs")
      if not status then return end
      configs.setup({
        ensure_installed = { "c", "cpp", "gn", "lua", "vim", "bash" },
        sync_install = true,
        auto_install = true,
        highlight = { enable = true, additional_vim_regex_highlighting = false },
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
      
      vim.api.nvim_create_autocmd("QuitPre", {
        pattern = "*",
        command = "silent! FloatermKill!"
      })
      
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
-- 4. 移植 FZF Vimscript 配置
-- ==========================================================================
vim.cmd([[
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'

  function! s:live_grep_handler(args)
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
-- 这里的 <Leader> 现在肯定已经是空格了
keymap("n", "<Leader>o", ":Files<CR>", { silent = true })
keymap("n", "<Leader>f", ":Rg<CR>", { silent = true })
keymap("n", "<Leader>b", ":Buffers<CR>", { silent = true })

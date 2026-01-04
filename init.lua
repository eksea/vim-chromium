-- ==========================================================================
-- 1. 基础设置 (Basic Options)
-- ==========================================================================
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus" -- 使用系统剪切板
vim.opt.termguicolors = true      -- 开启真彩色
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.updatetime = 100          -- 提高响应速度

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
  -- [主题] PaperColor
  {
    "NLKNguyen/papercolor-theme",
    priority = 1000,
    config = function()
      vim.o.background = "dark"
      vim.cmd("colorscheme PaperColor")
    end,
  },

  -- [状态栏] Lualine (轻量级)
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
      -- 使用 pcall 保护：如果加载失败，不会导致 Neovim 崩溃
      local status, configs = pcall(require, "nvim-treesitter.configs")
      if not status then
        vim.notify("Treesitter 加载失败，将使用普通正则高亮", vim.log.levels.WARN)
        return
      end

      configs.setup({
        -- 确保安装常用语言
        ensure_installed = { "c", "cpp", "gn", "lua", "vim", "bash" },
        -- 强制同步安装，避免网络问题导致的文件损坏
        sync_install = true,
        -- 自动安装缺失的解析器
        auto_install = true,

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },

  -- [FZF 核心]
  {
    "junegunn/fzf",
    build = "./install --bin",
  },
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
  },

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

      -- 快捷键映射
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

  " 2. Live Grep Handler (保留您的脚本路径)
  function! s:live_grep_handler(args)
    " 请确保这个路径在您的新系统上是正确的！
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

  " 3. Buffers 命令
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
keymap("n", "<Leader>o", ":Files<CR>", { silent = true })
keymap("n", "<Leader>f", ":Rg<CR>", { silent = true })
keymap("n", "<Leader>b", ":Buffers<CR>", { silent = true })

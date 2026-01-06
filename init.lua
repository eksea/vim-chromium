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
opt.relativenumber = true

-- 缩进设置 (Chromium 标准: 2空格)
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- 性能与系统集成
opt.updatetime = 100          -- 提高响应速度
opt.clipboard = "unnamedplus" -- 使用系统剪切板 (需安装 xclip 或 wl-clipboard)

-- ==========================================================================
-- 1.5 Vimdiff 配置
-- ==========================================================================
-- Diff 选项配置
opt.diffopt:append({
  'vertical',           -- 垂直分屏显示
  'algorithm:patience', -- 更智能的 diff 算法
  'indent-heuristic',   -- 更好的缩进对齐
  'context:5',          -- 显示 5 行上下文
  'foldcolumn:1',       -- 显示折叠列
  -- 'iwhite',          -- 忽略空白字符差异（按需启用）
})

-- Diff 颜色配置（更清晰的视觉效果）
vim.cmd([[
  highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=#b8bb26 guibg=#3c3836
  highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=#fb4934 guibg=#3c3836
  highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=#fabd2f guibg=#3c3836
  highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=#fe8019 guibg=#504945 gui=bold
]])

-- Diff 模式自动配置
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.o.diff then
      local map = vim.keymap.set
      
      -- 三方合并快捷键（Git 冲突解决）
      map('n', '<Leader>1', ':diffget LOCAL<CR>:diffupdate<CR>', { desc = '采用 LOCAL (当前分支)', silent = true })
      map('n', '<Leader>2', ':diffget BASE<CR>:diffupdate<CR>', { desc = '采用 BASE (共同祖先)', silent = true })
      map('n', '<Leader>3', ':diffget REMOTE<CR>:diffupdate<CR>', { desc = '采用 REMOTE (合并分支)', silent = true })
      
      -- 快速导航（跳转到差异并居中）
      map('n', '<C-j>', ']czz', { desc = '下一个差异', silent = true })
      map('n', '<C-k>', '[czz', { desc = '上一个差异', silent = true })
      
      -- 实用操作
      map('n', '<Leader>u', ':diffupdate<CR>', { desc = '刷新 diff', silent = true })
      map('n', '<Leader>do', ':diffoff!<CR>', { desc = '关闭 diff 模式', silent = true })
      map('n', '<Leader>q', ':qa<CR>', { desc = '退出所有窗口', silent = true })
      
      -- 窗口切换
      map('n', '<Leader>h', '<C-w>h', { desc = '切换到左窗口', silent = true })
      map('n', '<Leader>l', '<C-w>l', { desc = '切换到右窗口', silent = true })
      
      print('✓ Diff 模式已激活！使用 <Leader>1/2/3 进行三方合并')
    end
  end
})

-- ==========================================================================
-- 2. 黑洞寄存器映射 (保留您的习惯：粘贴/删除不覆盖剪切板)
-- ==========================================================================
local keymap = vim.keymap.set
keymap("x", "p", '"_dP')
keymap("v", "d", '"_d')
keymap("v", "c", '"_c')
keymap("v", "x", '"_x')

-- ==========================================================================
-- 3. 插件管理器 Lazy.nvim 引导
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
-- 4. 插件列表与配置
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
  {
    'junegunn/fzf',
    build = function() vim.fn['fzf#install']() end
  },
  {
    'junegunn/fzf.vim',
    config = function()
      vim.env.FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'

      vim.cmd([[
        function! s:live_grep_handler(args)
          let helper_script = expand('~/github/vim-chromium/.vim/bin/rg-fzf.sh')
          let preview_script = expand('~/github/vim-chromium/.vim/bin/preview.sh')
          
          let spec = {}
          let spec.options = [
            \ '--disabled',
            \ '--query', a:args,
            \ '--bind', 'change:reload:'.helper_script.' {q}',
            \ '--preview', preview_script . ' {1} {2} {q}',
            \ '--preview-window', 'right:50%:noborder:~2',
            \ '--prompt', 'Rg> ',
            \ '--delimiter', ':'
            \ ]
          
          call fzf#vim#grep('true', 1, spec, 0)
        endfunction
        
        command! -nargs=* Rg call s:live_grep_handler(<q-args>)
        
        " Buffers 命令（带预览）
        command! -bang Buffers
          \ call fzf#vim#buffers(
          \   {'options': [
          \     '--preview', expand('~/github/vim-chromium/.vim/bin/preview-buffer.sh') . ' {}',
          \     '--preview-window', 'right:50%:noborder:~2:+0'
          \   ]},
          \   <bang>0)
      ]])
    end
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

  -- [Git 集成] Vim-Fugitive（增强 Git 操作）
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'Gdiffsplit', 'Gvdiffsplit' },
    keys = {
      { '<Leader>gs', ':Git<CR>', desc = 'Git status' },
      { '<Leader>gd', ':Gvdiffsplit<CR>', desc = 'Git diff (垂直分屏)' },
      { '<Leader>gb', ':Git blame<CR>', desc = 'Git blame' },
      { '<Leader>gl', ':Gclog<CR>', desc = 'Git log' },
    },
  },

  -- [注释] Commentary
  { 'tpope/vim-commentary' },

  -- [GN 语法支持]
  { 'kalcutter/vim-gn' },
})

-- ==========================================================================
-- 5. 快捷键映射
-- ==========================================================================
-- FZF 快捷键
keymap("n", "<Leader>o", ":Files<CR>", { silent = true, desc = "查找文件" })
keymap("n", "<Leader>f", ":Rg<CR>", { silent = true, desc = "全局搜索内容" })
keymap("n", "<Leader>b", ":Buffers<CR>", { silent = true, desc = "切换缓冲区" })

-- 窗口导航快捷键（通用）
keymap("n", "<C-h>", "<C-w>h", { desc = "切换到左窗口" })
keymap("n", "<C-l>", "<C-w>l", { desc = "切换到右窗口" })
keymap("n", "<C-j>", "<C-w>j", { desc = "切换到下窗口" })
keymap("n", "<C-k>", "<C-w>k", { desc = "切换到上窗口" })

-- ==========================================================================
-- 6. Git 配置提示（首次使用需要配置）
-- ==========================================================================
-- 运行以下命令配置 Git 使用 Neovim 作为 diff 和 merge 工具：
--
-- git config --global diff.tool nvimdiff
-- git config --global difftool.nvimdiff.cmd 'nvim -d "$LOCAL" "$REMOTE"'
-- git config --global merge.tool nvimdiff
-- git config --global mergetool.nvimdiff.cmd 'nvim -d "$LOCAL" "$BASE" "$REMOTE" "$MERGED" -c "wincmd J"'
-- git config --global mergetool.prompt false
--
-- 使用方法：
--   git difftool file.cpp        # 查看文件差异
--   git mergetool                # 解决合并冲突
-- ==========================================================================

print("✓ Neovim 配置加载完成！")
print("  - 使用 :checkhealth 检查环境")
print("  - Diff 快捷键: <Leader>1/2/3 (三方合并)")
print("  - FZF 搜索: <Leader>o (文件) / <Leader>f (内容)")

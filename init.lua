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

-- ========================================
-- 搜索设置（忽略大小写）
-- ========================================
opt.ignorecase = true      -- 搜索时忽略大小写
opt.smartcase = true       -- 如果搜索词包含大写字母，则区分大小写

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
      -- 宽度持久化
      local width_file = vim.fn.stdpath('data') .. '/nvim-tree-width.txt'

      -- 读取宽度
      local function load_width()
        local file = io.open(width_file, 'r')
        if file then
          local width = tonumber(file:read('*l'))
          file:close()
          return width or 30
        end
        return 30
      end

      local function save_width(width)
        local file = io.open(width_file, 'w')
        if file then
          file:write(tostring(width))
          file:close()
        else
          print('[DEBUG] ✗ 无法打开文件写入')
        end
      end

      local initial_width = load_width()

      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = initial_width,
          side = "left",
          preserve_window_proportions = true,
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
            resize_window = false,
          },
        },
      })

      -- 自动保存宽度
      vim.api.nvim_create_autocmd('WinResized', {
        callback = function()
          print('[DEBUG] WinResized 事件触发')
          if vim.bo.filetype == 'NvimTree' then
            save_width(vim.api.nvim_win_get_width(0))
          end
        end
      })
      
      vim.api.nvim_create_autocmd('VimLeavePre', {
        callback = function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), 'filetype') == 'NvimTree' then
              save_width(vim.api.nvim_win_get_width(win))
              break
            end
          end
        end
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

      keymap("t", "<Esc>", function()
        -- 检查是否是 FZF 缓冲区
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname:match("^term://.*fzf") then
          -- FZF 缓冲区：发送 Esc 给 FZF（关闭搜索）
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'n', true)
        else
          -- Floaterm 缓冲区：退出终端模式
          vim.cmd('stopinsert')
        end
      end, { noremap = true })
      
      -- 快捷键映射 (F12 等)
      keymap("n", "<Leader>t", ":FloatermToggle<CR>", { silent = true })
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

  -- 在 require("lazy").setup({ 中添加

  -- [Git 状态显示] Gitsigns
  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('gitsigns').setup({
        signs = {
          add          = { text = '│' },  -- 新增行
          change       = { text = '│' },  -- 修改行
          delete       = { text = '_' },  -- 删除行
          topdelete    = { text = '‾' },  -- 顶部删除
          changedelete = { text = '~' },  -- 修改并删除
          untracked    = { text = '┆' },  -- 未跟踪
        },
        signcolumn = true,  -- 在行号旁显示标记
        numhl      = false, -- 高亮行号
        linehl     = false, -- 高亮整行
        word_diff  = false, -- 单词级别的 diff
        
        current_line_blame = true,  -- 显示当前行的 blame 信息
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',  -- 在行尾显示
          delay = 500,            -- 延迟 500ms 显示
          ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          
          -- 导航到上一个/下一个修改
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = '下一个修改'})
          
          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = '上一个修改'})
          
          -- 暂存/撤销修改
          map('n', '<Leader>hs', gs.stage_hunk, { desc = '暂存当前修改' })
          map('n', '<Leader>hr', gs.reset_hunk, { desc = '撤销当前修改' })
          map('v', '<Leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = '暂存选中修改' })
          map('v', '<Leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = '撤销选中修改' })
          
          map('n', '<Leader>hS', gs.stage_buffer, { desc = '暂存整个文件' })
          map('n', '<Leader>hu', gs.undo_stage_hunk, { desc = '撤销暂存' })
          map('n', '<Leader>hR', gs.reset_buffer, { desc = '重置整个文件' })
          
          -- 预览修改
          map('n', '<Leader>hp', gs.preview_hunk, { desc = '预览修改' })
          
          -- Blame
          map('n', '<Leader>hb', function() gs.blame_line{full=true} end, { desc = '显示完整 blame' })
          map('n', '<Leader>tb', gs.toggle_current_line_blame, { desc = '切换行内 blame' })
          
          -- Diff
          map('n', '<Leader>hd', gs.diffthis, { desc = 'Diff 当前文件' })
          map('n', '<Leader>hD', function() gs.diffthis('~') end, { desc = 'Diff HEAD' })
          
          -- 文本对象
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = '选择修改块' })
        end
      })
    vim.cmd([[
      " 新增行（绿色）
      highlight GitSignsAdd guifg=#1a7f37 guibg=NONE
      
      " 修改行（黄色）
      highlight GitSignsChange guifg=#fabd2f guibg=NONE
      
      " 删除行（红色）
      highlight GitSignsDelete guifg=#fb4934 guibg=NONE
      
      " 行号高亮
      highlight GitSignsAddNr guifg=#b8bb26
      highlight GitSignsChangeNr guifg=#fabd2f
      highlight GitSignsDeleteNr guifg=#fb4934
      
      " 行内 blame（灰色，不显眼）
      highlight GitSignsCurrentLineBlame guifg=#7c6f64 gui=italic
    ]])
    end,
  },

  -- [Markdown 预览]
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      { "<Leader>m", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown 预览" },
    },
    config = function()
      -- 设置浏览器（可选）
      -- vim.g.mkdp_browser = 'chrome'  -- 或 'firefox', 'safari'
      
      -- 预览服务器配置
      vim.g.mkdp_auto_start = 0          -- 打开 markdown 文件时不自动预览
      vim.g.mkdp_auto_close = 1          -- 关闭 buffer 时自动关闭预览
      vim.g.mkdp_refresh_slow = 0        -- 实时刷新（0=快速，1=保存时刷新）
      vim.g.mkdp_command_for_global = 0  -- 只在 markdown 文件中可用
      vim.g.mkdp_open_to_the_world = 0   -- 只允许本地访问
      
      -- 预览选项
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,         -- 同步滚动
        sync_scroll_type = 'middle',     -- 滚动位置
        hide_yaml_meta = 1,              -- 隐藏 YAML 元数据
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,        -- 预览内容不可编辑
        disable_filename = 0,            -- 显示文件名
        toc = {}
      }
      
      -- 主题：github（默认）或 dark
      vim.g.mkdp_theme = 'dark'
      
      -- 自定义端口（可选）
      -- vim.g.mkdp_port = '8080'
      
      -- 预览页面标题
      vim.g.mkdp_page_title = '「${name}」'
      
      -- 识别的文件类型
      vim.g.mkdp_filetypes = { "markdown" }
    end,
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
-- <Leader>f存在组合，导致搜索面板呼出太慢，改成<Leader>s
keymap("n", "<Leader>s", ":Rg<CR>", { silent = true, desc = "全局搜索内容" })
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

-- 智能路径获取函数
local function get_current_filepath()
  local filetype = vim.bo.filetype
  if filetype == "NvimTree" then
    local ok, api = pcall(require, 'nvim-tree.api')
    if ok then
      local node = api.tree.get_node_under_cursor()
      if node then return node.absolute_path end
    end
  end
  local filepath = vim.fn.expand('%:p')
  if filepath == "" or filepath:match("^term://") then return nil end
  return filepath
end

-- 路径操作快捷键
keymap("n", "<Leader>fp", function()
  local filepath = get_current_filepath()
  if not filepath then print('⚠ 当前无有效文件') return end
  vim.fn.setreg('+', filepath)
  print('✓ 完整路径已复制: ' .. filepath)
end, { desc = "复制完整路径" })

keymap("n", "<Leader>fr", function()
  local filepath = get_current_filepath()
  if not filepath then print('⚠ 当前无有效文件') return end
  local cwd = vim.fn.getcwd()
  local relative_path = filepath
  if filepath:sub(1, #cwd) == cwd then
    relative_path = filepath:sub(#cwd + 2)
  end
  vim.fn.setreg('+', relative_path)
  print('✓ 相对路径已复制: ' .. relative_path)
end, { desc = "复制相对路径" })

keymap("n", "<Leader>fn", function()
  local filepath = get_current_filepath()
  if not filepath then print('⚠ 当前无有效文件') return end
  local filename = vim.fn.fnamemodify(filepath, ':t')
  vim.fn.setreg('+', filename)
  print('✓ 文件名已复制: ' .. filename)
end, { desc = "复制文件名" })

keymap("n", "<Leader>fd", function()
  local filepath = get_current_filepath()
  if not filepath then print('⚠ 当前无有效文件') return end
  local dirpath = vim.fn.fnamemodify(filepath, ':h')
  vim.fn.setreg('+', dirpath)
  print('✓ 目录路径已复制: ' .. dirpath)
end, { desc = "复制目录路径" })

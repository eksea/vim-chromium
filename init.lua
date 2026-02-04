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
        -- 【修改】添加 "java" 以支持 Java 高亮
        ensure_installed = { "c", "cpp", "gn", "lua", "vim", "bash", "java" },
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

  -- [终端] ToggleTerm (替代 Floaterm，支持原生窗口切换)
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require("toggleterm").setup({
        -- 大小配置
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4 -- 占宽度的 40%
          end
        end,
        open_mapping = [[<F12>]], -- F12 唤起/隐藏
        hide_numbers = true,      -- 隐藏行号
        shade_terminals = true,
        start_in_insert = true,
        insert_mappings = true,   -- 允许在 insert 模式下使用映射
        persist_size = true,
        direction = 'float',      -- 默认浮动，但我们会手动调用 vertical
        close_on_exit = true,     -- 退出 shell 时关闭窗口
        shell = vim.o.shell,
        float_opts = {
          border = 'curved',
        },
      })

      -- ========================================
      -- 快捷键映射
      -- ========================================
      local keymap = vim.keymap.set
      local Terminal = require('toggleterm.terminal').Terminal

      -- 1. 右侧边栏终端 (真正的分屏，支持 <C-w>l 切入)
      local sidebar = Terminal:new({ direction = 'vertical' })
      
      keymap("n", "<Leader>tr", function()
        sidebar:toggle()
      end, { silent = true, desc = "右侧终端 (分屏)" })

      -- 2. 底部终端
      local bottom = Terminal:new({ direction = 'horizontal' })
      keymap("n", "<Leader>tb", function()
        bottom:toggle()
      end, { silent = true, desc = "底部终端" })
      
      -- 3. 浮动终端 (Lazygit)
      local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })
      keymap("n", "<Leader>g", function()
        lazygit:toggle()
      end, { silent = true, desc = "Lazygit" })

      -- ========================================
      -- 窗口导航核心配置 (让 <C-w> 在终端里也能用)
      -- ========================================
      function _G.set_terminal_keymaps()
        local opts = {buffer = 0}
        -- 让 <C-w> 系列键在终端模式下生效
        vim.keymap.set('t', '<C-w>h', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-w>j', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-w>k', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-w>l', [[<Cmd>wincmd l<CR>]], opts)
        -- 如果你想用 <C-h/j/k/l> 直接切换，也可以解开下面注释：
        -- vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        -- vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        vim.keymap.set('t', '<Esc>', [[<C-\><C-n>:close<CR>]], opts)
      end

      -- 自动应用快捷键到终端 buffer
      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    end
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
      vim.g.mkdp_auto_start = 0          -- 打开 markdown 文件时不自动预览
      vim.g.mkdp_auto_close = 0          -- 关闭 buffer 时自动关闭预览
      vim.g.mkdp_refresh_slow = 0        -- 实时刷新
      vim.g.mkdp_command_for_global = 0  -- 只在 markdown 文件中可用
      vim.g.mkdp_open_to_the_world = 0   -- 只允许本地访问
      
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = 'middle',
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {}
      }
      
      vim.g.mkdp_theme = 'dark'
      vim.g.mkdp_page_title = '「${name}」'
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },
  -- [平滑滚动]
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      require('neoscroll').setup({
        -- 基础配置
        hide_cursor = true,          -- 滚动时隐藏光标
        stop_eof = true,             -- 到达文件末尾时停止
        respect_scrolloff = false,   -- 不受 scrolloff 影响
        cursor_scrolls_alone = true, -- 光标独立滚动
        easing = "sine",             -- 缓动函数 (新版使用 easing 而不是 easing_function)
        performance_mode = false,    -- 大文件性能模式
      })

      -- 【新版 API】使用 neoscroll 提供的辅助函数配置快捷键
      local neoscroll = require('neoscroll')
      local keymap = {
        -- 半页滚动
        ["<C-y>"] = function() neoscroll.ctrl_u({ duration = 150 }) end,
        ["<C-e>"] = function() neoscroll.ctrl_d({ duration = 150 }) end,
        
        -- 整页滚动
        ["<C-b>"] = function() neoscroll.ctrl_b({ duration = 250 }) end,
        ["<C-f>"] = function() neoscroll.ctrl_f({ duration = 250 }) end,
        
        -- 单行滚动
        ["<C-u>"] = function() neoscroll.scroll(-0.1, { move_cursor=false, duration = 100 }) end,
        ["<C-d>"] = function() neoscroll.scroll(0.1, { move_cursor=false, duration = 100 }) end,
        
        -- 重新定位
        ["zt"]    = function() neoscroll.zt({ half_win_duration = 150 }) end,
        ["zz"]    = function() neoscroll.zz({ half_win_duration = 150 }) end,
        ["zb"]    = function() neoscroll.zb({ half_win_duration = 150 }) end,
      }

      local modes = { 'n', 'v', 'x' }
      for key, func in pairs(keymap) do
        vim.keymap.set(modes, key, func)
      end
    end,
  },

  -- ==========================================================================
  -- [LSP & 补全] 彻底解耦版 (手动挡，绝对稳定)
  -- ==========================================================================
  
  -- 1. Mason: 仅作为下载工具 (不参与 LSP 配置)
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  -- [FZF-Lua] 专门用于 Neovim 的 FZF 扩展 (支持 LSP)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({
        winopts = {
          preview = {
            layout = "vertical", -- 垂直预览
            vertical = "up:45%", -- 预览窗口在上方
          }
        }
      })
    end
  },

  -- 2. LSP 配置 (适配 Neovim 0.11 新 API)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- 获取补全能力
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- 定义通用的 on_attach (快捷键)
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gr', "<cmd>FzfLua lsp_references<CR>", opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      end

      -- =========================================================
      -- 使用新的 vim.lsp.config API (Neovim 0.11+)
      -- =========================================================

      -- [1] Clangd (C/C++)
      vim.lsp.config.clangd = {
        cmd = {
          "clangd",
          "--background-index=false",              -- 【关键】禁用后台索引
          "--clang-tidy=false",                    -- 【关键】禁用 clang-tidy
          "--completion-style=bundled",            -- 简化补全样式
          "--header-insertion=never",              -- 禁用自动插入头文件
          "--pch-storage=memory",                  -- PCH 存储在内存
          "--limit-results=50",                    -- 限制补全结果数量
          "--limit-references=100",                -- 限制引用查找数量
          "-j=4",                                  -- 限制并行任务数
          "--malloc-trim",                         -- 定期释放内存
          "--fallback-style=llvm",
          "--log=error",                           -- 只记录错误日志
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_markers = {
          ".clangd",
          ".clang-tidy",
          ".clang-format",
          "compile_commands.json",
          "compile_flags.txt",
          "configure.ac",
          ".git"
        },
        capabilities = capabilities,
        on_attach = on_attach,
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      }

      -- [2] Lua
      vim.lsp.config.lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false, 
            },
            telemetry = { enable = false },
          },
        },
      }

      -- [3] Bash
      vim.lsp.config.bashls = {
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh", "bash" },
        root_markers = { ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- [4] Java (JDTLS)
      -- 注意：需要先通过 :Mason 安装 jdtls
      vim.lsp.config.jdtls = {
        cmd = {
          "jdtls",
          "--jvm-arg=-Djava.home=/usr/lib/jvm/java-21-openjdk-amd64",
        }, -- Mason 会自动创建这个命令
        filetypes = { "java" },
        root_markers = { 
          "pom.xml",        -- Maven
          -- "build.gradle",   -- Gradle
          -- ".git", 
          -- "mvnw", 
          -- "gradlew" 
        },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = 'fernflower' }, -- 反编译支持
          }
        }
      }

      -- =========================================================
      -- 启用 LSP (自动检测文件类型并启动对应服务器)
      -- =========================================================
      vim.lsp.enable({ 'clangd', 'lua_ls', 'bashls', 'jdtls' })
    end,
  },

  -- 3. Nvim-CMP (保持不变)
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = 'symbol_text', 
            maxwidth = 50,
            ellipsis_char = '...',
          })
        }
      })
    end,
  },

  -- ==========================================================================
  -- [文件大纲] Aerial (基于 LSP/Treesitter)
  -- ==========================================================================
  {
    'stevearc/aerial.nvim',
    branch = "nvim-0.9",
    dependencies = {
       "nvim-treesitter/nvim-treesitter",
       "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("aerial").setup({
        -- 优先使用 LSP，如果不可用则使用 Treesitter
        backends = { "lsp", "treesitter", "markdown", "man" },
        
        -- 布局设置
        layout = {
          -- 宽度设置
          max_width = { 40, 0.2 },
          width = nil,
          min_width = 10,
          
          -- 默认显示在右侧 (toggle 时)
          default_direction = "prefer_right",
          
          -- 当文件只有一个符号时自动关闭
          close_on_cleanup = true,
        },

        -- 过滤设置：不显示过于琐碎的符号
        filter_kind = {
          "Class",
          "Constructor",
          "Enum",
          "Function",
          "Interface",
          "Module",
          "Method",
          "Struct",
          -- "Variable", -- 通常变量太多，建议注释掉，除非你想看
        },

        -- 高亮当前光标所在的符号
        highlight_on_hover = true,
        autojump = true,

        -- 图标设置 (使用 nvim-web-devicons)
        icons = vim.g.have_nerd_font and {} or {
          collapsed = "▶",
          expanded = "▼",
        },
        
        -- 快捷键 (在 Aerial 窗口内)
        keymaps = {
          ["?"] = "actions.show_help",
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.jump",
          ["<2-LeftMouse>"] = "actions.jump",
          ["<C-v>"] = "actions.jump_vsplit",
          ["<C-s>"] = "actions.jump_split",
          ["p"] = "actions.scroll",
          ["<C-j>"] = "actions.down_and_scroll",
          ["<C-k>"] = "actions.up_and_scroll",
          ["{"] = "actions.prev",
          ["}"] = "actions.next",
          ["[["] = "actions.prev_up",
          ["]]"] = "actions.next_up",
          ["q"] = "actions.close",
          ["o"] = "actions.tree_toggle",
          ["za"] = "actions.tree_toggle",
          ["O"] = "actions.tree_toggle_recursive",
          ["zA"] = "actions.tree_toggle_recursive",
          ["l"] = "actions.tree_open",
          ["h"] = "actions.tree_close",
        },
      })

      -- 全局快捷键：<Space>a 打开/关闭大纲
      vim.keymap.set("n", "<Leader>a", "<cmd>AerialToggle!<CR>", { desc = "文件大纲 (Aerial)" })
      
      -- 快捷键：{ 和 } 在代码中跳转到上一个/下一个符号 (类似 [[ ]])
      vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { desc = "上一个符号" })
      vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { desc = "下一个符号" })
    end,
  },

  -- [注释] Commentary
  { 'tpope/vim-commentary' },

  -- [GN 语法支持]
  { 'kalcutter/vim-gn' },

  -- [会话管理] 自动恢复工作区
  {
    'rmagatti/auto-session',
    config = function()
      require("auto-session").setup({
        log_level = "error",
        
        -- 自动行为配置
        auto_session_enable_last_session = false, -- 启动时不自动恢复上一次的会话（除非在同一目录）
        auto_save_enabled = true,                 -- 退出时自动保存
        auto_restore_enabled = true,              -- 启动时自动恢复（如果在有会话的目录下）
        
        -- 忽略的目录 (避免在根目录或主目录乱存会话)
        auto_session_suppress_dirs = { "~/", "/", "~/Downloads", "~/Documents", "~/Desktop" },
        
        -- [关键] 兼容性处理
        -- 保存会话前关闭 Nvim-Tree，防止恢复时布局错乱
        pre_save_cmds = { "NvimTreeClose" },
      })
    end,
  },
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


-- 【新增】文件结构大纲（支持搜索和跳转）
keymap("n", "<Leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", { silent = true, desc = "文件结构搜索" })

-- 【新增】工作区所有符号搜索（跨文件）
keymap("n", "<Leader>fw", "<cmd>FzfLua lsp_workspace_symbols<CR>", { silent = true, desc = "工作区符号搜索" })

-- 【可选】实时符号搜索（输入时动态过滤）
keymap("n", "<Leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", { silent = true, desc = "实时符号搜索" })

-- ========================================
-- 跳转到当前函数/类的开头
-- ========================================
keymap("n", "<Leader>jf", function()
  require("aerial").select({ index = 0 })  -- 跳转到当前符号的开头
end, { desc = "跳转到当前函数开头" })

-- 或者使用更智能的方式：跳转到包含当前光标的最近符号
keymap("n", "<Leader>jh", function()
  require("aerial").up(1)  -- 跳转到上一级符号（如从函数内跳到函数名）
end, { desc = "跳转到上一级符号" })

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

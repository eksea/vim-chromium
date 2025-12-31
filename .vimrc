call plug#begin('~/.vim/plugged')

" 1. 核心智能补全 (推荐 coc.nvim，对 C++ 支持极佳)
" 需要安装 nodejs
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" 2. Chromium GN 构建文件语法高亮 (官方插件)
Plug 'kalcutter/vim-gn'

" 3. 极速文件搜索 (Chromium 文件太多，必须用 fzf)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" 4. 代码格式化 (Google Style)
Plug 'google/vim-codefmt'
Plug 'google/vim-maktaba' " codefmt 的依赖

" 5. 状态栏
Plug 'vim-airline/vim-airline'

" 6. 语法高亮增强
Plug 'jackguo380/vim-lsp-cxx-highlight'

Plug 'NLKNguyen/papercolor-theme'

Plug 'tpope/vim-commentary'

call plug#end()

set shell=/bin/bash
set number
set cursorline
set clipboard=unnamedplus

set tabstop=2
set softtabstop=0 expandtab
set shiftwidth=2

set background=dark
colorscheme PaperColor

" 在 Visual 模式下粘贴时，不要复制被覆盖的文本
" 原理：粘贴操作会删除选中文本，我们让这个删除操作去黑洞寄存器
xnoremap p "_dP
vnoremap d "_d
vnoremap c "_c
vnoremap x "_x

" ----------------------------------------------------------------
" FZF 核心配置：使用 Ripgrep (rg) 作为后端
" ----------------------------------------------------------------

" 1. 让 :Files (找文件) 命令使用 rg
" --files: 只列出文件名
" --hidden: 搜索隐藏文件
" --follow: 跟随软链接
" --glob: 排除 .git 文件夹
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'

" 2. 自定义 :Rg (找内容) 命令
" 使得输入 :Rg <关键词> 时，能调用 rg 搜索内容，并用 fzf 预览
" command! -bang -nargs=* Rg
"   \ call fzf#vim#grep(
"   \   'rg --column --line-number --no-heading --color=always --smart-case --hidden --glob "!.git/*" '.shellescape(<q-args>), 1,
"   \   fzf#vim#with_preview(), <bang>0)
" 
" command! -bang -nargs=* Rg
"   \ call fzf#vim#grep(
"   \   'rg --column --line-number --no-heading --color=always --smart-case --hidden --glob "!.git/*" '.shellescape(<q-args>), 1,
"   \   fzf#vim#with_preview({'options': '--exact'}), <bang>0)

" -----------------------------------------------------------------------------
" Live Grep: 像 VS Code 一样，每输入一个字符，实时重运行 rg
" -----------------------------------------------------------------------------

function! s:live_grep_handler(args)
  let helper_script = '~/.vim/bin/rg-fzf.sh'
  let preview_script = '~/.vim/bin/preview.sh'

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

" function! s:live_grep_handler(args)
"   " 获取脚本路径
"   let helper_script = expand('~/.vim/bin/rg-fzf.sh')

"   " 关键修改点：
"   " 第一个参数从 cmd 改成了 'true'
"   " 含义：启动 FZF 时，执行系统命令 'true' (瞬间完成，无输出)
"   " 真正的搜索完全依赖后面的 'change:reload'
"   return fzf#vim#grep(
"     \ 'true', 1,
"     \ fzf#vim#with_preview({
"     \   'options': [
"     \     '--phony',
"     \     '--query', a:args,
"     \     '--bind', 'change:reload:'.helper_script.' {q}'
"     \   ]
"     \ }), 0)
" endfunction

" function! s:live_grep_handler(args)
"   " 1. 定义 rg 命令，包含性能优化参数
"   " --max-columns=200 : 忽略超长行 (关键！防止 min.js 卡死)
"   " --glob : 排除 git 和 node_modules (虽然 gitignore 包含，但显式排除更稳)
"   let cmd = 'rg --column --line-number --no-heading --color=always --smart-case --max-columns=200 '
"   let cmd .= '--glob "!.git/*" '
"   let cmd .= '--glob "!node_modules/*" '
"   let cmd .= '--glob "!out/*" '
"   let cmd .= '--glob "!mtout/*" '

"   " 2. 运行 fzf
"   " --bind 'change:reload:...': 关键！每当输入改变，重新运行 rg 命令
"   " {q} 代表当前的搜索词
"   return fzf#vim#grep(
"     \ cmd . '""', 1,
"     \ fzf#vim#with_preview({
"     \   'options': ['--phony', '--query', a:args, '--bind', 'change:reload:'.cmd.'{q}']
"     \ }), 0)
" endfunction

" 定义命令 :Rg 为 Live Grep 模式
command! -nargs=* Rg call s:live_grep_handler(<q-args>)


" ----------------------------------------------------------------
" 快捷键映射 (按需修改)
" ----------------------------------------------------------------

" Ctrl + P : 查找文件 (类似于 VSCode)
nnoremap <C-p> :Files<CR>

" Ctrl + F : 全局查找代码内容 (类似于 VSCode 的 Ctrl+Shift+F)
nnoremap <C-f> :Rg<CR>

nnoremap <C-b> :Buffers<CR>



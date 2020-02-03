call plug#begin('~/.vim/plugged')
Plug 'ctrlpvim/ctrlp.vim'
Plug 'fatih/vim-go'
Plug 'mileszs/ack.vim'
Plug 'scrooloose/nerdtree'
Plug 'mdempsky/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jlanzarotta/bufexplorer'
Plug 'tpope/vim-fugitive'
Plug 'chrisbra/Colorizer'
Plug 'trashhalo/neuromancer.vim'
Plug 'majutsushi/tagbar'
Plug 'SirVer/ultisnips'
Plug 'mtth/scratch.vim'
Plug 'tpope/vim-abolish'
call plug#end()

set background=dark
colorscheme neuromancer

noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

if has("gui_running")
	set guioptions-=m  "remove menu bar
	set guioptions-=T  "remove toolbar
	set guioptions-=r  "remove right-hand scroll bar
	set guioptions-=L  "remove locationWriterleft-hand scroll bar
	set guifont=Victor\ Mono\ 18
else
	set t_Co=256
	set termguicolors
endif

let mapleader=","

filetype off                    " Reset filetype detection first ...
filetype plugin indent on       " ... and enable filetype detection
filetype plugin on
set nocompatible                " Enables us Vim specific features
set ttyfast                     " Indicate fast terminal conn for faster redraw
set ttymouse=xterm2             " Indicate terminal type for mouse codes
set ttyscroll=3                 " Speedup scrolling
set laststatus=2                " Show status line always
set encoding=utf-8              " Set default encoding to UTF-8
set autoread                    " Automatically read changed files
set autoindent                  " Enabile Autoindent
set backspace=indent,eol,start  " Makes backspace key more powerful.
set incsearch                   " Shows the match while typing
set hlsearch                    " Highlight found searches
set noerrorbells                " No beeps
set showcmd                     " Show me what I'm typing
set noswapfile                  " Don't use swapfile
set nobackup                    " Don't create annoying backup files
set splitright                  " Vertical windows should be split to right
set splitbelow                  " Horizontal windows should split to bottom
set autowrite                   " Automatically save before :next, :make etc.
set hidden                      " Buffer should still exist if window is closed
set fileformats=unix,dos,mac    " Prefer Unix over Windows over OS 9 formats
set noshowmatch                 " Do not show matching brackets by flickering
set noshowmode                  " We show the mode with airline or lightline
set ignorecase                  " Search case insensitive...
set smartcase                   " ... but not it begins with upper case
set completeopt=menu,menuone    " Show popup menu, even if there is one entry
set pumheight=10                " Completion window max size
set nocursorcolumn              " Do not highlight column (speeds up highlighting)
set lazyredraw                  " Wait to redraw
set synmaxcol=128
syntax sync minlines=256

if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

nnoremap <leader>` :BufExplorer<CR>
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>f :Ack <C-r><C-w><CR>
nnoremap <leader>i :GoInfo<CR>
nnoremap <leader>p "+p
:command SnipList :call UltiSnips#ListSnippets()
:command SmallMonitor set guifont=Victor\ Mono\ 12
:command BigMonitor set guifont=Victor\ Mono\ 14
:command MakeHuge set guifont=Victor\ Mono\ 18

let g:go_highlight_operators    = 0
let g:go_highlight_functions    = 1
let g:go_highlight_methods      = 1
let g:go_highlight_types        = 0
let g:go_highlight_fields       = 0
let g:go_highlight_variable_declarations = 0
let g:go_highlight_build_constraints = 0
let g:go_fmt_command            = "goimports"
let g:go_metalinter_command     = "golangci-lint"
let g:go_metalinter_autosave = 0
let g:go_gorename_command = 'gopls'
let g:go_gopls_complete_unimported = 1
let g:go_gopls_use_placeholders = 1
let g:go_referrers_mode = 'gopls'
let g:go_auto_type_info = 0
let g:go_gopls_use_placeholders = 1

let g:UltiSnipsExpandTrigger="<c-space>"

inoremap <silent><expr> <tab> coc#refresh()
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

let g:tagbar_type_go = {
	\ 'ctagstype' : 'go',
	\ 'kinds'     : [
		\ 'p:package',
		\ 'i:imports:1',
		\ 'c:constants',
		\ 'v:variables',
		\ 't:types',
		\ 'n:interfaces',
		\ 'w:fields',
		\ 'e:embedded',
		\ 'm:methods',
		\ 'r:constructor',
		\ 'f:functions'
	\ ],
	\ 'sro' : '.',
	\ 'kind2scope' : {
		\ 't' : 'ctype',
		\ 'n' : 'ntype'
	\ },
	\ 'scope2kind' : {
		\ 'ctype' : 't',
		\ 'ntype' : 'n'
	\ },
	\ 'ctagsbin'  : 'gotags',
	\ 'ctagsargs' : '-sort -silent'
\ }


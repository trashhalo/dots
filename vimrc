set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')
" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'mileszs/ack.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'dmeybohm/vim-tinyfileutils'
Plugin 'freitass/todo.txt-vim'
Plugin 'tpope/vim-fugitive'
Plugin 'trashhalo/jshint.vim'
Plugin 'danro/rename.vim'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'vim-scripts/JavaScript-Indent'
Plugin 'FelikZ/ctrlp-py-matcher'
Plugin 'rking/ag.vim'
Plugin 'vim-scripts/highlight.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'chriskempson/base16-vim'
Plugin 'git://github.com/vim-scripts/matchit.zip'
Plugin 'git://github.com/kana/vim-textobj-user.git'
Plugin 'git://github.com/vim-scripts/ruby-matchit.git'
Plugin 'git://github.com/nelstrom/vim-textobj-rubyblock.git'
Plugin 'https://github.com/kana/vim-textobj-indent.git'
Plugin 'https://github.com/nunun/vim-textobj-function.git'
Plugin 'guns/vim-clojure-static'

" All of your Plugins must be added before the following line
call vundle#end()  
filetype plugin indent on    " required
set backspace=indent,eol,start
set timeoutlen=1000 ttimeoutlen=0
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
set tabstop=4
set shiftwidth=4
set expandtab
au FileType ruby setl sw=2 sts=2 et
au FileType scss setl sw=2 sts=2 et
au BufRead,BufNewFile *.es6 let b:jshintrc_file=getcwd() . "/.jshintrc.es6"
au BufRead,BufNewFile *.es6 setfiletype javascript
let mapleader = ","
syntax on
set background=dark

if has("unix")
  let s:uname = system("uname -s")
  if s:uname == "Darwin\n"
      nnoremap ∆ :wincmd j<CR>
      nnoremap ¬ :wincmd l<CR>
      nnoremap ˚ :wincmd k<CR>
      nnoremap ˙ :wincmd h<CR>
  else
      nnoremap ê :wincmd j<CR>
      nnoremap ì :wincmd l<CR>
      nnoremap ë :wincmd k<CR>
      nnoremap è :wincmd h<CR>
  endif
endif

nnoremap <leader>` :BufExplorer<CR>
noremap <C-n> :normal viw"_dP<CR>
noremap <C-y> :normal my^"*y$`y<CR>
colorscheme base16-bright
set exrc

let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
      \ --ignore .git
      \ --ignore .svn
      \ --ignore .hg
      \ --ignore node_modules
      \ --ignore .DS_Store
      \ --ignore "**/*.pyc"
      \ -g ""'

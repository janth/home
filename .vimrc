" vim:sta:si:et:ts=3:sw=3:nonu:sm:ic:rs

" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	1999 Jul 25
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"             for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc

set nocompatible	" Use Vim defaults (much better!)
set bs=2		" allow backspacing over everything in insert mode
set ai			" always set autoindenting on
set nobackup		" keep a backup file
set viminfo='20,\"50	" read/write a .viminfo file, don't store more
			" than 50 lines of registers
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set nonumber
set smarttab
set smartindent
set hidden     " keep buffers, don't abandon them
set modeline
set modelines=99999
set expandtab
set tabstop=3
set softtabstop=3
set shiftwidth=3
set showmatch
set restorescreen
set incsearch
" set hlsearch
set ignorecase
set smartcase
set scrolloff=5
set wildmode=longest,list
" set encoding=latin1
" set fileencoding=latin1
" set termencoding=utf-8
" æøåÆØÅ
set background=dark
" set background=light

" slow for large files
let g:xml_syntax_folding = 1
let perl_fold = 1

:filetype plugin on
" source $VIMRUNTIME/macros/matchit.vim

" Only do this part when compiled with support for autocommands
if has("autocmd")
  " In text files, always limit the width of text to 78 characters
  autocmd BufRead *.txt set tw=78
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost * if line("'\"") | exe "'\"" | endif
endif

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

if (&term =~ "xterm") || (&term =~ "vt220") || (&term =~ "vt100")
    if has("terminfo")
      set t_Co=8
      set t_Sf=[3%p1%dm
      set t_Sb=[4%p1%dm
    else
      set t_Co=8
      set t_Sf=[3%dm
      set t_Sb=[4%dm
    endif
endif

" http://vim.wikia.com/wiki/Automatically_set_screen_title
" let &titlestring = hostname() . ":vim " . expand("%:t") . " "
" let &titlestring = "vim " . expand("%:t") . " "
autocmd BufEnter * let &titlestring = "vim " . expand("%:p") . " "
" autocmd BufEnter * let &titlestring = hostname() . "[vim(" . expand("%:t") . ")]"
let &titleold = ''

" set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}

if &term == "screen"
   set t_ts=^[k
   set t_fs=^[\
endif
if &term == "screen" || &term == "xterm"
   set title
endif

 
" if &t_Co > 1 
"   syntax on 
"   set hlsearch
" endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
" if &t_Co > 2 || has("gui_running")
"   syntax on
"   set hlsearch
" endif

"
" Colo(u)red or not colo(u)red
" If you want color you should set this to true
"
let color = "true"
"
if has("syntax")
    if color == "true"
	" This will switch colors ON
	so ${VIMRUNTIME}/syntax/syntax.vim
	syntax on
	" set hlsearch
    else
	" this switches colors OFF
	syntax off
	set t_Co=0
    endif
endif

if has("autocmd")

   au Filetype htm,html,xml,xsl source ~/.vim/scripts/closetag.vim
 augroup cprog
  " Remove all cprog autocommands
  au!

  " When starting to edit a file:
  "   For C and C++ files set formatting of comments and set C-indenting on.
  "   For other files switch it off.
  "   Don't change the order, it's important that the line with * comes first.
  " autocmd FileType *      set formatoptions=tcql nocindent comments&
  " autocmd FileType c,cpp  set formatoptions=croql cindent comments=sr:/*,mb:*,el:*/,://
 " augroup END

 augroup gzip
  " Remove all gzip autocommands
  au!

  " Enable editing of gzipped files
  "	  read:	set binary mode before reading the file
  "		uncompress text in buffer after reading
  "	 write:	compress file after writing
  "	append:	uncompress file, append, compress file
  autocmd BufReadPre,FileReadPre	*.gz set bin
  autocmd BufReadPost,FileReadPost	*.gz let ch_save = &ch|set ch=2
  autocmd BufReadPost,FileReadPost	*.gz '[,']!gunzip
  autocmd BufReadPost,FileReadPost	*.gz set nobin
  autocmd BufReadPost,FileReadPost	*.gz let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost	*.gz execute ":doautocmd BufReadPost " . expand("%:r")

  autocmd BufWritePost,FileWritePost	*.gz !mv <afile> <afile>:r
  autocmd BufWritePost,FileWritePost	*.gz !gzip <afile>:r

  autocmd FileAppendPre			*.gz !gunzip <afile>
  autocmd FileAppendPre			*.gz !mv <afile>:r <afile>
  autocmd FileAppendPost		*.gz !mv <afile> <afile>:r
  autocmd FileAppendPost		*.gz !gzip <afile>:r
 augroup END
endif

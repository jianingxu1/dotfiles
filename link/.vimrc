set encoding=utf-8

let mapleader = " "

" BASIC SETTINGS ----------------------------------------------------------

set nocompatible " Disable vi compatibility
set clipboard=unnamed " Use system clipboard
set mouse=a " Enable mouse support

" Visual
set cursorline " Highlight current line
set number " Enable line numbers.
set relativenumber " Use relative line numbers. Current line is still in status bar.
set showtabline=2 " Always show tab bar.
set nowrap " Do not wrap lines.
set colorcolumn=81
set textwidth=80
set laststatus=2  " Always display the status line

syntax on " Enable syntax highlighting
highlight ColorColumn ctermbg=gray

" Indentation
set autoindent " Copy indent from last line when starting new line.
set shiftwidth=4 " The # of spaces for indenting.
set tabstop=4 " Tabs indent only 4 spaces
set expandtab " Expand tabs to spaces

" Search
set ignorecase
set smartcase
set incsearch " Do incremental searching
set hlsearch " Highlight searches

" MAPPINGS ---------------------------------------------------------------

" Basic shortcuts
inoremap jk <Esc>
inoremap <C-c> <Esc>

" Centering while navigating
nnoremap j jzz
nnoremap k kzz
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv

" Window navigation
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Others
nnoremap <C-n> :nohlsearch<CR> " Clear search highlighting

" Plugin mappings

" NERDTree
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" FZF
nnoremap <silent> <Leader>b :Buffers<CR>
nnoremap <silent> <Leader>f :Files<CR>

" Floatterm
nnoremap   <silent>   <F7>    :FloatermNew<CR>
tnoremap   <silent>   <F7>    <C-\><C-n>:FloatermNew<CR>
nnoremap   <silent>   <F8>    :FloatermPrev<CR>
tnoremap   <silent>   <F8>    <C-\><C-n>:FloatermPrev<CR>
nnoremap   <silent>   <F9>    :FloatermNext<CR>
tnoremap   <silent>   <F9>    <C-\><C-n>:FloatermNext<CR>
nnoremap   <silent>   <C-n>   :FloatermToggle<CR>
tnoremap   <silent>   <C-n>   <C-\><C-n>:FloatermToggle<CR>

" PLUGIN MANAGER (vim-plug) ----------------------------------------------

" Auto-install vim-plug if not present
if empty(glob('~/.vim/autoload/plug.vim'))
  silent execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs ' .
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" Auto-run PlugInstall if any plugins are missing
function! s:AutoInstallPlugins()
  if exists('g:plugs')
    let missing = filter(values(g:plugs), '!isdirectory(v:val.dir)')
    if len(missing) > 0
      silent! PlugInstall --sync
      source $MYVIMRC
    endif
  endif
endfunction

autocmd VimEnter * call s:AutoInstallPlugins()

call plug#begin()

" THEMES AND UI
Plug 'joshdick/onedark.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" FILE NAVIGATION
Plug 'preservim/nerdtree'

" GIT INTEGRATION
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" FUZZY FINDING
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" TERMINAL
Plug 'voldikss/vim-floaterm'

" w AND b NAVIGATION WITHOUT NUMBERS
Plug 'easymotion/vim-easymotion'
call plug#end()

" COLORSCHEME ------------------------------------------------------------

colorscheme onedark

" AIRLINE CONFIG ---------------------------------------------------------

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline_left_sep = '»'
let g:airline_left_alt_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_alt_sep = '◀'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.dirty = '⚡'
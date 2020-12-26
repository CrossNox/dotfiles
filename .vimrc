set spelllang=es
set spell
set number
syntax on
set bs=2

filetype plugin indent on
au FileType gitcommit set tw=72

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'morhetz/gruvbox'
Plug 'w0rp/ale'
Plug 'scrooloose/nerdtree'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'
Plug 'lervag/vimtex' 
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
Plug 'psf/black', {'tag': '19.10b0'}
" https://github.com/psf/black/issues/1293
Plug 'glench/vim-jinja2-syntax'
Plug 'vim-scripts/dbext.vim'
Plug 'tmhedberg/SimpylFold'
Plug 'tpope/vim-fugitive'
Plug 'arcticicestudio/nord-vim'
Plug 'vim-airline/vim-airline'
Plug 'co1ncidence/gunmetal.vim'
Plug 'habamax/vim-gruvbit'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'voldikss/vim-floaterm'
Plug 'airblade/vim-gitgutter'
call plug#end()

set termguicolors
colorscheme gruvbit
"colorscheme gruvbox
"colorscheme gunmetal-grey
set background=dark

let g:black_skip_string_normalization = 1

" run black on save
autocmd BufWritePre *.py execute ':Black'

" run black on f6
nnoremap <F6> :Black<CR>

let g:tex_flavor = 'latex'
let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_view_general_viewer = 'vivaldi'
let g:vimtex_compiler_latexmk = {
    \ 'options' : [
    \    '-shell-escape',
    \    '-verbose',
    \    '-file-line-error',
    \    '-synctex=1',
    \    '-interaction=nonstopmode',
    \ ],
    \}

if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif
au VimEnter * let g:ycm_semantic_triggers.tex=g:vimtex#re#youcompleteme

" zc close a fold
" zo open a fold
let g:SimpylFold_docstring_preview = 1
let g:SimpylFold_fold_import = 0

" airline
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1

" nerdtree
map <C-o> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

nnoremap <C-Down> <C-W><C-J>
nnoremap <C-Up> <C-W><C-K>
nnoremap <C-Right> <C-W><C-L>
nnoremap <C-Left> <C-W><C-H>

" Apply first suggestion
nnoremap <C-L> 1z=

" Floaterm
let g:floaterm_keymap_new    = '<F9>'
let g:floaterm_keymap_prev   = '<F10>'
let g:floaterm_keymap_next   = '<F11>'
let g:floaterm_keymap_toggle = '<F12>'


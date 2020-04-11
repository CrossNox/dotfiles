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
" Plug 'davidhalter/jedi-vim'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
Plug 'psf/black'
Plug 'lervag/vimtex' 
call plug#end()

colorscheme gruvbox
set background=dark

" run black on save
autocmd BufWritePre *.py execute ':Black'

" run black on f9
nnoremap <F9> :Black<CR>

let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_view_general_viewer = 'vivaldi'

map <C-o> :NERDTreeToggle<CR>

nnoremap <C-Down> <C-W><C-J>
nnoremap <C-Up> <C-W><C-K>
nnoremap <C-Right> <C-W><C-L>
nnoremap <C-Left> <C-W><C-H>


set spelllang=es
set spell
set number
syntax on
set bs=2

filetype plugin indent on
au FileType gitcommit set tw=72

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim  --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source ~/.config/nvim/init.vim
endif

let g:ale_disable_lsp = 1

call plug#begin()
" Themes 
Plug 'morhetz/gruvbox'
Plug 'arcticicestudio/nord-vim'
Plug 'co1ncidence/gunmetal.vim'
Plug 'habamax/vim-gruvbit'

" Utils
Plug 'scrooloose/nerdtree'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'voldikss/vim-floaterm'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" LaTex
Plug 'lervag/vimtex' 


" Linting
Plug 'dense-analysis/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Python
Plug 'psf/black', {'tag': '19.10b0'}
" https://github.com/psf/black/issues/1293
Plug 'glench/vim-jinja2-syntax'
Plug 'vim-scripts/dbext.vim'
Plug 'tmhedberg/SimpylFold'

call plug#end()

let g:coc_global_extensions = [
      \ 'coc-json',
      \ 'coc-jedi',
      \ ]

let g:ale_linters = {
      \   'python': ['pylint'],
      \}

let g:ale_fixers = {
      \    'python': ['black', 'isort'],
      \}
nmap <F6> :ALEFix<CR>
let g:ale_fix_on_save = 1

set termguicolors
colorscheme gruvbit
" colorscheme gruvbox
" colorscheme gunmetal-grey
set background=dark

let g:black_skip_string_normalization = 1

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


autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <Nul> coc#refresh()

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nmap <leader>rn <Plug>(coc-rename)

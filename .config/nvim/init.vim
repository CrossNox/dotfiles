" share clipboard
" set mouse=n
set clipboard+=unnamedplus
set spell
set spelllang=en_us,es
set number
syntax on
set bs=2

" set cursorcolumn
set cursorline

" move lines
nnoremap <A-Down> :m .+1<CR>==
nnoremap <A-Up> :m .-2<CR>==
inoremap <A-Down> <Esc>:m .+1<CR>==gi
inoremap <A-Up> <Esc>:m .-2<CR>==gi
vnoremap <A-Down> :m '>+1<CR>gv=gv
vnoremap <A-Up> :m '<-2<CR>gv=gv

filetype plugin indent on
au FileType markdown let g:indentLine_setConceal= 0
au FileType json let g:indentLine_setConceal= 0
au FileType gitcommit set tw=72

au BufNewFile,BufReadPost *.md set filetype=markdown
let g:markdown_fenced_languages = ['python']

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
Plug 'habamax/vim-gruvbit'
Plug 'artanikin/vim-synthwave84'
Plug 'liuchengxu/space-vim-dark'
Plug 'pineapplegiant/spaceduck', { 'branch': 'main' }

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
Plug 'Yggdroot/indentLine'
Plug 'APZelos/blamer.nvim'
Plug 'tpope/vim-unimpaired'
Plug 'chrisbra/Colorizer'

" LaTex
Plug 'lervag/vimtex'

" Linting
Plug 'dense-analysis/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'CrossNox/coc-sql-plus-jinja', {'do': 'yarn install --frozen-lockfile'}

" Python
Plug 'psf/black'
Plug 'glench/vim-jinja2-syntax'
Plug 'vim-scripts/dbext.vim'
Plug 'tmhedberg/SimpylFold'

call plug#end()

" let g:indentLine_setColors = 0
let g:indentLine_defaultGroup = 'SpecialKey'
let g:indentLine_char = '¦'

let g:coc_global_extensions = [
      \ 'coc-json',
      \ 'coc-jedi',
      \ 'coc-metals',
      \ 'coc-vimtex',
      \ ]

let g:ale_linters = {
      \   'python': ['pylint', 'flake8'],
      \}

let g:ale_fixers = {
      \   '*': ['remove_trailing_lines', 'trim_whitespace'],
      \    'python': ['black', 'isort'],
      \    'json': ['jq'],
      \    'html': ['html-beautify'],
      \}

nmap <F6> :ALEFix<CR>
let g:ale_fix_on_save = 1

" SQL
:autocmd BufWritePost *.sql call CocAction('format')

" colorscheme
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    let &t_ZH="\e[3m"
    let &t_ZR="\e[23m"
    let &t_ZH="\e[3m"
    let &t_ZR="\e[23m"
    set termguicolors
endif

hi Comment cterm=ITALIC

colorscheme gruvbit
let g:airline_theme='gruvbit'

" Colorizer
" let g:colorizer_auto_color = 1
" let g:colorizer_skip_comments = 1
let g:colorizer_colornames = 0
let g:colorizer_use_virtual_text = 1
let g:colorizer_auto_filetype='css,html,md,conf'
let g:colorizer_disable_bufleave = 1
:au BufNewFile,BufRead *.css,*.html,*.htm,*.md,*.conf  :ColorHighlight!

" Black
let g:black_skip_string_normalization = 1

" Vimtex
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
let g:vimtex_syntax_conceal_default = 0

" zc close a fold
" zo open a fold
let g:SimpylFold_docstring_preview = 1
let g:SimpylFold_fold_import = 0

" airline
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1

set guifont=FiraCode\ Nerd\ Font

" testing rounded separators (extra-powerline-symbols):
let g:airline_left_sep = "\uE0C6"
let g:airline_right_sep = "\uE0C7"

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

" CoC
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

" Ctrl+Enter / Ctrl+M / Ctrl+backspace
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <leader>rn <Plug>(coc-rename)
nmap <leader>eN <Plug>(coc-diagnostic-next-error)
nmap <leader>eP <Plug>(coc-diagnostic-prev-error)

" FZF
nnoremap <C-g> :Ag<Cr>
nnoremap <C-p> :GFiles<Cr>

" Json
autocmd Filetype json setlocal ts=4 sw=4 expandtab

" Blamer
let g:blamer_enabled = 1
let g:blamer_delay = 1000
let g:blamer_show_in_visual_modes = 0
let g:blamer_show_in_insert_modes = 1
let g:blamer_prefix = ' :: '
let g:blamer_template = '<committer>, <committer-time> • <summary>'
let g:blamer_date_format = '%y-%m-%d %H:%M'
let g:blamer_relative_time = 0

" Git
nmap <leader>gs :G<CR>
nmap <leader>gj :diffget //3<CR>
nmap <leader>gf :diffget //3<CR>
nmap <leader>gM :vert Gdiffsplit!<CR>

" Buffer navigation
" TAB in general mode will move to text buffer
nnoremap <TAB> :bnext<CR>
" SHIFT-TAB will go back
nnoremap <S-TAB> :bprevious<CR>

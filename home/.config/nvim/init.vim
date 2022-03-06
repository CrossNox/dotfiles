" share clipboard
" set mouse=n
set clipboard+=unnamedplus
set spell
set spelllang=en_us,es
set number
syntax on
set bs=2
set ts=4 sw=4

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
Plug 'dylanaraps/wal.vim'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

" Utils
Plug 'luukvbaal/nnn.nvim'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
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
Plug 'hashivim/vim-terraform'

Plug 'puremourning/vimspector'

" Python
Plug 'psf/black', {'tag': '21.12b0'}
Plug 'glench/vim-jinja2-syntax'
Plug 'vim-scripts/dbext.vim'
Plug 'tmhedberg/SimpylFold'
" Plug 'petobens/poet-v'

call plug#end()

"let g:poetv_executables = ['poetry']
"let g:poetv_auto_activate = 1

" let g:indentLine_setColors = 0
let g:indentLine_defaultGroup = 'SpecialKey'
let g:indentLine_char = '¦'

let g:coc_global_extensions = [
      \ 'coc-json',
      \ 'coc-jedi',
      \ 'coc-metals',
      \ 'coc-vimtex',
	  \ 'coc-java',
	  \ 'coc-java-debug',
      \ ]

let g:ale_linters = {
      \   'python': ['pylint', 'flake8'],
      \}

let g:ale_fixers = {
      \   '*': ['remove_trailing_lines', 'trim_whitespace'],
      \    'python': ['black', 'isort', 'autoimport'],
      \    'json': ['jq'],
      \    'html': ['html-beautify'],
      \    'java': ['google_java_format'],
	  \    'sh': ['shfmt'],
      \}

let g:terraform_fmt_on_save=1
let g:terraform_align=1
let g:hcl_align=1

nmap <F6> :ALEFix<CR>
nmap <F5> :ALENext<CR>
nmap <F4> :ALEPrevious<CR>
let g:ale_fix_on_save = 1

" SQL
" :autocmd BufWritePost *.sql call CocAction('format')

" Example config in VimScript
let g:tokyonight_style = "night"
let g:tokyonight_terminal_colors = 1
let g:tokyonight_italic_functions = 1
let g:tokyonight_italic_comments = 1
let g:tokyonight_italic_keywords = 1
let g:tokyonight_italic_variables = 1
let g:tokyonight_transparent = 0
let g:tokyonight_sidebars = []

" Change the "hint" color to the "orange" color, and make the "error" color bright red
let g:tokyonight_colors = {
  \ 'hint': 'orange',
  \ 'error': '#ff0000'
\ }

colorscheme tokyonight

" lualine
lua << END
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'tokyonight',
    component_separators = { left = '', right = ''},
    section_separators = { left = "", right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {
		'branch',
		'diff',
		{
			'diagnostics',

			-- Table of diagnostic sources, available sources are:
      		--   'nvim_lsp', 'nvim_diagnostic', 'coc', 'ale', 'vim_lsp'.
      		-- or a function that returns a table as such:
      		--   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
      		sources = { 'coc', 'ale' },

      		-- Displays diagnostics for the defined severity types
      		sections = { 'error', 'warn', 'info', 'hint' },

      		diagnostics_color = {
        		-- Same values as the general color option can be used here.
        		error = 'DiagnosticError', -- Changes diagnostics' error color.
        		warn  = 'DiagnosticWarn',  -- Changes diagnostics' warn color.
        		info  = 'DiagnosticInfo',  -- Changes diagnostics' info color.
        		hint  = 'DiagnosticHint',  -- Changes diagnostics' hint color.
      		},
      		symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'},
      		colored = true,           -- Displays diagnostics status in color if set to true.
      		update_in_insert = false, -- Update diagnostics in insert mode.
      		always_visible = false,   -- Show diagnostics even if there are none.
    	}
	},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
	lualine_a = {'buffers'},
	lualine_b = {},
	lualine_c = {},
	lualine_x = {},
	lualine_y = {},
	lualine_z = {'tabs'}
  },
  extensions = {}
}
END

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

set guifont=FiraCode\ Nerd\ Font

" nnn.nvim

lua << EOF
local builtin = require("nnn").builtin
local cfg = {
	explorer = {
		cmd = "nnn -G",    -- command overrride (-F1 flag is implied, -a flag is invalid!)
		width = 24,        -- width of the vertical split
		side = "topleft",  -- or "botright", location of the explorer window
		session = "local",      -- or "global" / "local" / "shared"
		tabs = true,       -- seperate nnn instance per tab
	},
	picker = {
		cmd = "tmux new-session -e SPLIT=v nnn -Pp -G",       -- command override (-p flag is implied)
		style = {
			width = 0.9,     -- percentage relative to terminal size when < 1, absolute otherwise
			height = 0.8,    -- ^
			xoffset = 0.5,   -- ^
			yoffset = 0.5,   -- ^
			border = "rounded"-- border decoration for example "rounded"(:h nvim_open_win)
		},
		session = "local",      -- or "global" / "local" / "shared"
	},
	auto_open = {
		setup = nil,       -- or "explorer" / "picker", auto open on setup function
		tabpage = nil,     -- or "explorer" / "picker", auto open when opening new tabpage
		empty = false,     -- only auto open on empty buffer
		ft_ignore = {      -- dont auto open for these filetypes
			"gitcommit",
		}
	},
	auto_close = true,  -- close tabpage/nvim when nnn is last window
	replace_netrw = nil, -- or "explorer" / "picker"
    mappings = {
		{ "<C-t>", builtin.open_in_tab },       -- open file(s) in tab
		{ "<C-s>", builtin.open_in_split },     -- open file(s) in split
		{ "<C-v>", builtin.open_in_vsplit },    -- open file(s) in vertical split
		{ "<C-y>", builtin.copy_to_clipboard }, -- copy file(s) to clipboard
	},
	windownav = {        -- window movement mappings to navigate out of nnn
		left = "<C-Left>",
		right = "<C-Right>"
	},
}
require("nnn").setup(cfg)
EOF

tnoremap <C-o> <cmd>NnnPicker<CR>
nnoremap <C-o> <cmd>NnnPicker %:p:h<CR>

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

function! JavaStartDebugCallback(err, port)
  execute "cexpr! 'Java debug started on port: " . a:port . "'"
  call vimspector#LaunchWithSettings({ "configuration": "Java Attach", "AdapterPort": a:port })
endfunction

function JavaStartDebug()
  call CocActionAsync('runCommand', 'vscode.java.startDebugSession', function('JavaStartDebugCallback'))
endfunction

nmap <F1> :call JavaStartDebug()<CR>
" nmap <F1> :CocCommand java.debug.vimspector.start<CR>
nmap <F2> <Plug>VimspectorToggleBreakpoint
nmap <F3> <Plug>VimspectorContinue
nmap <F7> <Plug>VimspectorStepOver
nmap <F7> <Plug>VimspectorStepInto

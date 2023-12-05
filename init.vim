set clipboard+=unnamedplus
" Plugins will be downloaded under the specified directory.
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" Declare the list of plugins.
Plug 'tpope/vim-sensible'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.4' }
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'
Plug 'rmagatti/auto-session'
Plug 'mattn/emmet-vim'
Plug 'vim-airline/vim-airline'
Plug 'rafamadriz/friendly-snippets'
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-commentary'
Plug 'preservim/nerdtree'
Plug 'vim-ctrlspace/vim-ctrlspace'
Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'github/copilot.vim'
" List ends here. Plugins become visible to Vim after this call.
call plug#end()

let g:CtrlSpaceDefaultMappingKey = "<C-space> "
set hidden
set encoding=utf-8
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction


" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>


:command ReloadConfig :source ~/.config/nvim/init.vim
:command Dir :e %:p:h
set number

" vim.api.nvim_echo({{'hello', 'Normal'}}, false, {})
"
" auto session config
"

luafile ~/.config/nvim/lua/purple-config.lua
luafile ~/.config/nvim/lua/windows-stuff.lua

" require('/home/pruple/.config/nvim/lua/windows-stuff.lua')
" 

autocmd InsertLeave,TextChanged,FocusLost * silent! update

let g:airline#extensions#tabline#enabled = 1

" add my custom configuration
"
execute 'source' fnamemodify(stdpath('config') . '/config/clang-format.vim', ':p')
execute 'source' fnamemodify(stdpath('config') . '/config/purple-coc-config.vim', ':p')
execute 'source' fnamemodify(stdpath('config') . '/config/purple-nerdtree-config.vim', ':p')
" /Users/vitaly/.config/nvim/config/clang-format.vim

:set tabstop=2
:set expandtab
:set listchars=tab:▷▷⋮
:set invlist
:set softtabstop=2
:set shiftwidth=2
:set splitright


let mapleader = " " 
nnoremap <leader>wo <cmd>Telescope find_files<cr>
nnoremap <leader>ff <cmd>Telescope live_grep<cr>
nnoremap <leader>fw <cmd>Telescope grep_string<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fc <cmd>Telescope colorscheme<cr>
nnoremap <leader>ee <cmd>Telescope oldfiles<cr><esc>
nnoremap <leader>hh <cmd>Telescope treesitter<cr>

" my hotkeys
"
nmap <silent> <leader>d yyp
nmap <silent> <leader>qb :bd<cr>
nmap <silent> <leader>qq :bn<cr>:bd #<cr>
nmap <silent> <leader>n :bn<cr>
nmap <silent> <leader>p :bp<cr>
nmap <silent> <leader>; msA;<esc>`s
" nmap <silent> <leader><leader>t :new | r!
nmap <silent> <C-_> gc
vmap <silent> <C-_> gc

nnoremap <silent> <leader>ll :call FormatClang()<CR>
nnoremap <silent> <leader>ll :call FormatClang()<CR>
nnoremap <silent> <leader>vt :e %:h<CR>
nnoremap <leader>c :only<CR>

autocmd FileType arduino setlocal commentstring=//\ %s

augroup source_init
  autocmd!
  autocmd BufWritePost init.vim silent! source %
augroup END

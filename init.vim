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
" Plug 'preservim/nerdtree'
" Plug 'vim-ctrlspace/vim-ctrlspace'
" let g:CtrlSpaceDefaultMappingKey = "<C-space> "
" Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'stevearc/oil.nvim'
Plug 'github/copilot.vim'
Plug 'jiangmiao/auto-pairs' 
Plug 'ThePrimeagen/harpoon', { 'branch' : 'harpoon2' }
Plug 'doums/darcula'
" List ends here. Plugins become visible to Vim after this call.
call plug#end()

set hidden
set encoding=utf-8
set nobackup
set nowritebackup
set relativenumber
set termguicolors
colorscheme darcula
" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes
set tabstop=2
set expandtab
set listchars=tab:▷▷⋮
set invlist
set softtabstop=2
set shiftwidth=2
set splitright

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

:command ReloadConfig :source ~/.config/nvim/init.vim

" vim.api.nvim_echo({{'hello', 'Normal'}}, false, {})
"
" auto session config
"

luafile ~/.config/nvim/lua/purple-config.lua
luafile ~/.config/nvim/lua/windows-stuff.lua


let mapleader = " " 
autocmd InsertLeave,TextChanged,FocusLost * silent! update

let g:airline#extensions#tabline#enabled = 1

" add my custom configuration
"
execute 'source' fnamemodify(stdpath('config') . '/config/clang-format.vim', ':p')
execute 'source' fnamemodify(stdpath('config') . '/config/purple-coc-config.vim', ':p')
" execute 'source' fnamemodify(stdpath('config') . '/config/purple-nerdtree-config.vim', ':p')
execute 'source' fnamemodify(stdpath('config') . '/config/purple-telescope-config.vim', ':p')

" lua require('/home/pruple/.config/nvim/lua/windows-stuff.lua')
" lua require("oil").setup()

:command Dir :e %:p:h
" my hotkeys
"
" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>
nmap <silent> <leader>d yyp
vmap <silent> <leader>d y`>p
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

function! OutputSplitWindow(...)
  " this function output the result of the Ex command into a split scratch buffer
  let cmd = join(a:000, ' ')
  let temp_reg = @t
  redir @t
  silent! execute cmd
  redir END
  let output = copy(@t)
  let @" = temp_reg
  if empty(output)
    echoerr "no output"
  else
    new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
    put! =output
  endif
endfunction
command! -nargs=+ -complete=command Output call OutputSplitWindow(<f-args>)

command! -nargs=? Gc execute "w" | if "<args>" == "" | execute "Git commit" | else | execute "Git commit -m '".<q-args>."'" | endif
command! -nargs=? Gf execute "Git add %" | execute "Gc ". <q-args>
command! -nargs=? Gpu  if "<args>" != "" | execute "Gf ". <q-args> | endif | execute "Git push -u origin HEAD"

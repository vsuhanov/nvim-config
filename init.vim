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
Plug 'stevearc/oil.nvim'
Plug 'github/copilot.vim'
Plug 'jiangmiao/auto-pairs' 
Plug 'ThePrimeagen/harpoon', { 'branch' : 'harpoon2' }
Plug 'doums/darcula'
Plug 'robitx/gp.nvim'
" List ends here. Plugins become visible to Vim after this call.
call plug#end()
" todo move colorscheme to set.lua
" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience


:command ReloadConfig :source ~/.config/nvim/init.vim

" vim.api.nvim_echo({{'hello', 'Normal'}}, false, {})
"
" auto session config
"
luafile ~/.config/nvim/init-tmp.lua
" luafile ~/.config/nvim/lua/windows-stuff.lua


let mapleader = " " 

" let g:airline#extensions#tabline#enabled = 1

" add my custom configuration
"
execute 'source' fnamemodify(stdpath('config') . '/config/clang-format.vim', ':p')
execute 'source' fnamemodify(stdpath('config') . '/config/purple-coc-config.vim', ':p')

:command Dir :e %:p:h
" my hotkeys

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

command! -nargs=* Gpu  if "<args>" != "" | execute "Gf ". <q-args> | endif | execute "Git push -u origin HEAD"

" map <leader>uu mt:s/~~//g<CR>:s/-<space>✓<space>//<CR>:s/-<space>✗<space>//<CR>:s/-<space>☐<space>//<CR>^i-<space>☐<space><ESC>:noh<CR>`t
map <leader>uu mt:s/\~\~//ge<CR>:s/-<space>✓<space>//e<CR>:s/-<space>✗<space>//e<CR>:s/-<space>☐<space>//e<CR>^i-<space>☐<space><ESC>:noh<CR>`t
map <leader>ud mt:s/-<space>☐<space>/-<space>✓<space>\~\~/e<CR>g_a~~<ESC>:noh<CR>`tj
map <leader>uc mt:s/-<space>☐<space>/-<space>✗<space>\~\~/e<CR>g_a~~<ESC>:noh<CR>`tj

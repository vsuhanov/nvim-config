vim.cmd[[
  let mapleader = " " 
  map <leader>uu mt:s/\~\~//ge<CR>:s/-<space>✓<space>//e<CR>:s/-<space>✗<space>//e<CR>:s/-<space>☐<space>//e<CR>^i-<space>☐<space><ESC>:noh<CR>`t
  map <leader>ud mt:s/-<space>☐<space>/-<space>✓<space>\~\~/e<CR>g_a~~<ESC>:noh<CR>`tj
  map <leader>uc mt:s/-<space>☐<space>/-<space>✗<space>\~\~/e<CR>g_a~~<ESC>:noh<CR>`tj
  let g:lightline = { 'colorscheme': 'solarized' }
]]


vim.cmd[[
  let mapleader = " " 
  map <leader>uu mt:s/\~\~//ge<CR>:s/-<space>✓<space>//e<CR>:s/-<space>✗<space>//e<CR>:s/-<space>☐<space>//e<CR>^i-<space>☐<space><ESC>`t
  map <leader>ud mt:s/-<space>☐<space>/-<space>✓<space>\~\~/e<CR>g_a~~<ESC>`tj
  map <leader>uc mt:s/-<space>☐<space>/-<space>✗<space>\~\~/e<CR>g_a~~<ESC>`tj
]]

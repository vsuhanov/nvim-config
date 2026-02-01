local function configure_terminal_buffer()
  -- Map window navigation keys to work from terminal mode
  -- vim.keymap.set('t', '<C-w>h', '<C-\\><C-n><C-w>h', { buffer = true })
  -- vim.keymap.set('t', '<C-w>j', '<C-\\><C-n><C-w>j', { buffer = true })
  -- vim.keymap.set('t', '<C-w>k', '<C-\\><C-n><C-w>k', { buffer = true })
  -- vim.keymap.set('t', '<C-w>l', '<C-\\><C-n><C-w>l', { buffer = true })
  -- vim.keymap.set('t', '<C-w>w', '<C-\\><C-n><C-w>w', { buffer = true })
  -- vim.keymap.set('t', '<C-w><C-w>', '<C-\\><C-n><C-w>w', { buffer = true })
  -- Optional: map other useful window commands
  -- vim.keymap.set('t', '<C-w>s', '<C-\\><C-n><C-w>s', { buffer = true })
  -- vim.keymap.set('t', '<C-w>v', '<C-\\><C-n><C-w>v', { buffer = true })
  -- vim.keymap.set('t', '<C-w>q', '<C-\\><C-n><C-w>q', { buffer = true })
  -- vim.keymap.set('t', '<C-w>c', '<C-\\><C-n><C-w>c', { buffer = true })
  vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>', { buffer = true })
  vim.keymap.set('t', '<C-o>', '<C-\\><C-n><C-o>', { buffer = true })
  -- FIX: this hotkey breaks interaction in terminal because TAB == C-i wtf... 
  -- vim.keymap.set('t', '<C-i>', '<C-\\><C-n><C-i>', { buffer = true })
  vim.keymap.set('t', '<C-;>', '<C-\\><C-n>:', { buffer = true })
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { buffer = true })
  vim.keymap.set('t', ':q<CR>', '<C-\\><C-n>:bd!<cr>', { buffer = true })
  -- vim.cmd([[cnoreabbrev <buffer> <expr> q getcmdtype() == ":" && getcmdline() == "q" ? "bdelete" : "q"]])
  -- vim.cmd([[cnoreabbrev <buffer> <expr> q! getcmdtype() == ":" && getcmdline() == "q!" ? "bdelete!" : "q!"]])

  vim.cmd('startinsert')
end

-- Apply to new terminals
vim.api.nvim_create_autocmd('TermOpen', {
  callback = configure_terminal_buffer
})

-- Apply to existing terminal buffers on startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == 'terminal' then
        vim.api.nvim_buf_call(buf, configure_terminal_buffer)
      end
    end
  end
})

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = 'term://*',
  command = 'startinsert'
})

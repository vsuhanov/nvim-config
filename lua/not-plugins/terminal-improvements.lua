local function configure_terminal_buffer()
  vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>', { buffer = true })
  vim.keymap.set('t', '<C-o>', '<C-\\><C-n><C-o>', { buffer = true })
  -- FIX: this hotkey breaks interaction in terminal because TAB == C-i wtf...
  -- vim.keymap.set('t', '<C-i>', '<C-\\><C-n><C-i>', { buffer = true })
  vim.keymap.set('t', '<C-;>', '<C-\\><C-n>:', { buffer = true })
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { buffer = true })
  vim.keymap.set('t', ':q<CR>', '<C-\\><C-n>:bd!<cr>', { buffer = true })
  vim.cmd('startinsert')
end

vim.api.nvim_create_autocmd('TermOpen', {
  callback = configure_terminal_buffer
})

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

-- vim.api.nvim_create_autocmd("TermClose", {
--   callback = function()
--     vim.cmd("close")
--   end
-- })

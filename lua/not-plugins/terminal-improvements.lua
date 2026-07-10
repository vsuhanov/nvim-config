local read_mode_terminals = {}

local function set_terminal_read_mode(bufnr)
  read_mode_terminals[bufnr] = true
end

local function unset_terminal_read_mode(bufnr)
  read_mode_terminals[bufnr] = nil
end

local function toggle_terminal_read_mode(bufnr)
  if read_mode_terminals[bufnr] then
    unset_terminal_read_mode(bufnr)
  else
    set_terminal_read_mode(bufnr)
  end
end

local function configure_terminal_buffer()
  vim.keymap.set('v', 'a', '<Esc>a', { buffer = true })
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

local  delta = 1
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained' }, {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= 'terminal' then return end
    -- print("resizing terminal window")
    if not read_mode_terminals[args.buf] then
      vim.cmd('startinsert')
      local win = vim.api.nvim_get_current_win()
      local w = vim.api.nvim_win_get_width(win)
      vim.api.nvim_win_set_width(win, w + delta)
      delta = delta * -1
    end
  end
})

vim.api.nvim_create_user_command('TerminalReadMode', function()
  local bufnr = vim.api.nvim_get_current_buf()
  toggle_terminal_read_mode(bufnr)
  local status = read_mode_terminals[bufnr] and 'enabled' or 'disabled'
  vim.notify('Terminal read-mode ' .. status, vim.log.levels.INFO)
end, {})

-- vim.api.nvim_create_autocmd("TermClose", {
--   callback = function()
--     vim.cmd("close")
--   end
-- })

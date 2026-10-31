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

local function has_no_scrollback(bufnr)
  return vim.api.nvim_buf_line_count(bufnr) <= vim.api.nvim_win_get_height(0)
end

local function send_wheel(direction, times)
  local bufnr = vim.api.nvim_get_current_buf()
  local chan = vim.b[bufnr].terminal_job_id
  if not chan then return end
  local button = direction == 'up' and 64 or 65
  local row = math.max(1, math.floor(vim.api.nvim_win_get_height(0) / 2))
  local col = math.max(1, math.floor(vim.api.nvim_win_get_width(0) / 2))
  local seq = string.format('\27[<%d;%d;%dM', button, col, row)
  vim.api.nvim_chan_send(chan, string.rep(seq, times))
end

local function map_tui_scroll(lhs, direction, times)
  vim.keymap.set('n', lhs, function()
    if has_no_scrollback(vim.api.nvim_get_current_buf()) then
      send_wheel(direction, times * vim.v.count1)
    else
      vim.cmd('normal! ' .. vim.v.count1 .. vim.keycode(lhs))
    end
  end, { buffer = true })
end

local function map_edge_scroll(lhs, fallback, direction)
  vim.keymap.set('n', lhs, function()
    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local edge = direction == 'up' and 1 or vim.api.nvim_buf_line_count(bufnr)
    if line == edge and has_no_scrollback(bufnr) then
      send_wheel(direction, vim.v.count1)
    else
      vim.cmd('normal! ' .. vim.v.count1 .. fallback)
    end
  end, { buffer = true })
end

local function map_jump_scroll(lhs, direction)
  vim.keymap.set('n', lhs, function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.v.count > 0 or not has_no_scrollback(bufnr) then
      vim.cmd('normal! ' .. (vim.v.count > 0 and vim.v.count or '') .. lhs)
      return
    end
    send_wheel(direction, 1000)
    local line = direction == 'up' and 1 or vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_win_set_cursor(0, { line, 0 })
  end, { buffer = true })
end

local function configure_terminal_buffer()
  map_jump_scroll('gg', 'up')
  map_jump_scroll('G', 'down')
  map_edge_scroll('k', 'gk', 'up')
  map_edge_scroll('j', 'gj', 'down')
  map_tui_scroll('<C-y>', 'up', 1)
  map_tui_scroll('<C-e>', 'down', 1)
  map_tui_scroll('<C-u>', 'up', 5)
  map_tui_scroll('<C-d>', 'down', 5)
  map_tui_scroll('<C-b>', 'up', 10)
  map_tui_scroll('<C-f>', 'down', 10)
  vim.keymap.set('v', 'a', '<Esc>a', { buffer = true })
  vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>', { buffer = true })
  -- vim.keymap.set('t', '<C-o>', '<C-\\><C-n><C-o>', { buffer = true })
  vim.keymap.set('t', 'g<Tab>', '<C-\\><C-n>g<Tab>', { buffer = true })
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

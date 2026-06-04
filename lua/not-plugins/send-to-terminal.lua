local function get_text_to_send()
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    return table.concat(lines, '\n'), end_line
  else
    local current_line = vim.fn.line('.')
    local last_line = vim.fn.line('$')
    local end_line = current_line
    for i = current_line + 1, last_line do
      local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
      if line == '' then
        break
      end
      end_line = i
    end
    local lines = vim.api.nvim_buf_get_lines(0, current_line - 1, end_line, false)
    return table.concat(lines, '\n'), end_line
  end
end

local function win_terminal_is_busy(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local chan = vim.api.nvim_get_option_value('channel', { buf = buf })
  if chan == 0 then return false end
  local pid = vim.fn.jobpid(chan)
  return vim.trim(vim.fn.system('pgrep -P ' .. pid)) ~= ''
end

local function find_terminal_wins()
  local terminal_wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == 'terminal' then
      table.insert(terminal_wins, win)
    end
  end
  return terminal_wins
end

local function send_to_win(win, text)
  local buf = vim.api.nvim_win_get_buf(win)
  local chan = vim.api.nvim_get_option_value('channel', { buf = buf })
  if chan == 0 then
    vim.notify('terminal channel not available', vim.log.levels.ERROR)
    return
  end
  vim.fn.chansend(chan, text .. '\r')
end

local function pick_idle_terminal()
  local terminal_wins = find_terminal_wins()

  if #terminal_wins == 0 then
    local source_win = vim.api.nvim_get_current_win()
    vim.cmd('vsplit | term')
    local new_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(source_win)
    return new_win
  end

  local idle_wins = vim.tbl_filter(function(win)
    return not win_terminal_is_busy(win)
  end, terminal_wins)

  if #idle_wins == 0 then
    vim.notify('all terminals are busy', vim.log.levels.WARN)
    return nil
  end

  if #idle_wins == 1 then
    return idle_wins[1]
  end

  local terminal_win_set = {}
  for _, win in ipairs(idle_wins) do
    terminal_win_set[win] = true
  end

  return require('window-picker').pick_window({
    filter_func = function(win_ids)
      local filtered = {}
      for _, win in ipairs(win_ids) do
        if terminal_win_set[win] then
          table.insert(filtered, win)
        end
      end
      return filtered
    end,
  })
end

local function open_live_file_buffer(filepath)
  vim.cmd('vsplit ' .. vim.fn.fnameescape(filepath))
  local bufnr = vim.api.nvim_get_current_buf()
  vim.bo[bufnr].autoread = true

  local timer = vim.uv.new_timer()
  timer:start(300, 300, vim.schedule_wrap(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      timer:stop()
      timer:close()
      return
    end
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd('silent! checktime')
    end)
  end))

  vim.api.nvim_create_autocmd('BufDelete', {
    buffer = bufnr,
    once = true,
    callback = function()
      timer:stop()
      timer:close()
    end,
  })
end

local function send_to_terminal(focus)
  local text = get_text_to_send()
  local target_win = pick_idle_terminal()
  if not target_win then return end

  send_to_win(target_win, text)
  if focus then
    vim.api.nvim_set_current_win(target_win)
  end
end

local function send_to_terminal_capture()
  local text, end_line = get_text_to_send()
  local source_buf = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()

  local target_win = pick_idle_terminal()
  if not target_win then return end

  local normalized = text:lower():gsub('[^a-z0-9]', ''):sub(1, 20)
  local filepath = '/tmp/' .. os.date('%Y-%b-%d-%H-%M-%S') .. '_' .. normalized

  vim.fn.system('touch ' .. vim.fn.shellescape(filepath))

  local last_buf_line = vim.api.nvim_buf_line_count(source_buf)
  local sep_line = nil
  local marker_line = nil

  for i = end_line + 1, last_buf_line do
    local line = vim.api.nvim_buf_get_lines(source_buf, i - 1, i, false)[1]
    if sep_line == nil then
      if line == '' then
        sep_line = i
      else
        break
      end
    else
      if line == '---' then
        marker_line = i
        break
      elseif line ~= '' and not line:match('^/') then
        break
      end
    end
  end

  if marker_line ~= nil then
    vim.api.nvim_buf_set_lines(source_buf, sep_line, sep_line, false, { filepath })
  elseif sep_line ~= nil then
    vim.api.nvim_buf_set_lines(source_buf, sep_line, sep_line, false, { filepath, '---', '' })
  else
    vim.api.nvim_buf_set_lines(source_buf, end_line, end_line, false, { '', filepath, '---', '' })
  end

  open_live_file_buffer(filepath)

  vim.api.nvim_set_current_win(source_win)

  send_to_win(target_win, text .. ' > ' .. filepath .. ' 2>&1')
end

vim.keymap.set({ 'n', 'v' }, '<leader>ts', function() send_to_terminal(false) end, { desc = 'Send to terminal' })
vim.keymap.set({ 'n', 'v' }, '<leader>tS', function() send_to_terminal(true) end, { desc = 'Send to terminal and focus' })
vim.keymap.set({ 'n', 'v' }, '<leader>tC', send_to_terminal_capture, { desc = 'Send to terminal with output capture' })

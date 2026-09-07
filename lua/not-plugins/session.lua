local session_dir = vim.fn.stdpath('data') .. '/simple-sessions'
local autosave_interval = 60 * 1000
local term_capture_lines = 100

local function session_path()
  local cwd = vim.fn.getcwd():gsub('%%', '%%%%'):gsub('/', '%%')
  return session_dir .. '/' .. cwd .. '.lua'
end

local function proc_cwd(pid)
  local out = vim.fn.system({ 'lsof', '-a', '-d', 'cwd', '-p', tostring(pid), '-Fn' })
  for line in out:gmatch('[^\r\n]+') do
    if line:sub(1, 1) == 'n' then return line:sub(2) end
  end
  return nil
end

local shells = { zsh = true, bash = true, sh = true, fish = true, dash = true, ksh = true }

local function is_shell(cmd)
  local exe = cmd:match('^%-?(%S+)')
  return exe ~= nil and shells[vim.fn.fnamemodify(exe, ':t')] == true
end

local function proc_cmd(pid)
  local children = vim.trim(vim.fn.system({ 'pgrep', '-P', tostring(pid) }))
  local target = children:match('%d+') or tostring(pid)
  local cmd = vim.trim(vim.fn.system({ 'ps', '-o', 'command=', '-p', target }))
  if cmd == '' or is_shell(cmd) then return nil end
  return cmd
end

local proc_cache = {}
local info_terms = {}

local function term_lines(buf)
  local count = vim.api.nvim_buf_line_count(buf)
  local start = math.max(0, count - term_capture_lines)
  local lines = vim.api.nvim_buf_get_lines(buf, start, -1, false)
  while #lines > 0 and vim.trim(lines[#lines]) == '' do
    table.remove(lines)
  end
  return lines
end

local function term_info(buf, refresh)
  local chan = vim.bo[buf].channel
  if chan == 0 then return nil end

  local cached = proc_cache[buf]
  if refresh or not cached or cached.chan ~= chan then
    local ok, pid = pcall(vim.fn.jobpid, chan)
    if ok then
      cached = { chan = chan, cwd = proc_cwd(pid) or vim.fn.getcwd(), cmd = proc_cmd(pid) }
      proc_cache[buf] = cached
    end
  end
  if not cached then return nil end

  return { cwd = cached.cwd, cmd = cached.cmd, lines = term_lines(buf) }
end

local function collect(node, curwin, refresh)
  local kind = node[1]
  if kind == 'leaf' then
    local win = node[2]
    local buf = vim.api.nvim_win_get_buf(win)
    local entry = {
      kind = 'leaf',
      current = win == curwin,
    }
    if info_terms[buf] then
      entry.term = info_terms[buf]
    elseif vim.bo[buf].buftype == 'terminal' then
      entry.term = term_info(buf, refresh)
    elseif vim.bo[buf].buftype == '' then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= '' and vim.fn.filereadable(name) == 1 then
        entry.file = name
        entry.cursor = vim.api.nvim_win_get_cursor(win)
      end
    end
    return entry
  end

  local children = {}
  for _, child in ipairs(node[2]) do
    table.insert(children, collect(child, curwin, refresh))
  end
  return { kind = kind, children = children }
end

local last_written

local function write_session(path, body)
  vim.fn.mkdir(session_dir, 'p')
  local tmp = path .. '.tmp'
  local file = io.open(tmp, 'w')
  if not file then return false end
  file:write(body)
  file:close()
  return vim.uv.fs_rename(tmp, path) ~= nil
end

local function save(refresh)
  local tabs = {}
  local curwin = vim.api.nvim_get_current_win()
  local curtab = vim.api.nvim_get_current_tabpage()
  local current_tab_index = 1

  for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if tab == curtab then current_tab_index = i end
    table.insert(tabs, collect(vim.fn.winlayout(vim.api.nvim_tabpage_get_number(tab)), curwin, refresh))
  end

  local data = { cwd = vim.fn.getcwd(), tab = current_tab_index, tabs = tabs }

  local key = vim.inspect(data)
  local path = session_path()
  if key == last_written and vim.fn.filereadable(path) == 1 then return path end

  data.saved_at = os.time()
  if not write_session(path, 'return ' .. vim.inspect(data) .. '\n') then
    vim.notify('session: cannot write ' .. path, vim.log.levels.ERROR)
    return
  end

  last_written = key
  return path
end

local function build(node, win, leaves)
  if node.kind == 'leaf' then
    node.win = win
    table.insert(leaves, node)
    return
  end

  local cmd = node.kind == 'row' and 'vsplit' or 'split'
  local wins = { win }
  vim.api.nvim_set_current_win(win)
  for _ = 2, #node.children do
    vim.cmd('belowright ' .. cmd)
    table.insert(wins, vim.api.nvim_get_current_win())
  end

  for i, child in ipairs(node.children) do
    build(child, wins[i], leaves)
  end
end

local info_count = 0

local function open_terminal(buf, term, run_cmd)
  local dir = term.cwd
  if not dir or vim.fn.isdirectory(dir) == 0 then dir = vim.fn.getcwd() end

  vim.cmd('enew')
  local chan = vim.fn.jobstart(vim.o.shell, { term = true, cwd = dir })
  pcall(vim.api.nvim_buf_delete, buf, { force = true })

  if run_cmd and chan > 0 then
    vim.defer_fn(function()
      pcall(vim.fn.chansend, chan, run_cmd .. '\r')
    end, 150)
  end

  vim.cmd('startinsert')
end

local function info_buffer(term, saved_at)
  local buf = vim.api.nvim_create_buf(false, true)
  info_count = info_count + 1
  pcall(vim.api.nvim_buf_set_name, buf, 'session://terminal/' .. info_count)

  local lines = {
    term.cmd
        and 'terminal snapshot (not running) — <CR> opens a terminal in cwd, <S-CR> also runs the command, q closes'
      or 'terminal snapshot (not running) — <CR> opens a terminal in cwd, q closes',
    '',
    'cwd: ' .. vim.fn.fnamemodify(term.cwd or vim.fn.getcwd(), ':~'),
    'cmd: ' .. (term.cmd or vim.o.shell),
  }
  if saved_at then
    table.insert(lines, 'saved: ' .. os.date('%Y-%m-%d %H:%M:%S', saved_at))
  end

  if term.lines and #term.lines > 0 then
    table.insert(lines, '')
    table.insert(lines, '--- last output ---')
    vim.list_extend(lines, term.lines)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
  vim.bo[buf].filetype = 'sessionterm'

  vim.keymap.set('n', '<CR>', function()
    open_terminal(buf, term, nil)
  end, { buffer = buf, nowait = true, desc = 'open terminal in saved cwd' })

  vim.keymap.set('n', '<S-CR>', function()
    open_terminal(buf, term, term.cmd)
  end, { buffer = buf, nowait = true, desc = 'open terminal in saved cwd and run saved command' })

  vim.keymap.set('n', 'q', function()
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end, { buffer = buf, nowait = true, desc = 'close terminal snapshot' })

  info_terms[buf] = term
  return buf
end

local function read_session()
  local path = session_path()
  if vim.fn.filereadable(path) == 0 then return nil end
  local ok, data = pcall(dofile, path)
  if not ok or type(data) ~= 'table' or type(data.tabs) ~= 'table' then return nil end
  return data
end

local function restore_windows(data)
  vim.cmd('silent! tabonly')
  vim.cmd('silent! only')
  vim.cmd('enew')

  local current_win = nil

  for i, tab in ipairs(data.tabs) do
    if i > 1 then vim.cmd('tabnew') end

    local leaves = {}
    build(tab, vim.api.nvim_get_current_win(), leaves)

    for _, leaf in ipairs(leaves) do
      if leaf.current then current_win = leaf.win end
      if leaf.file then
        vim.api.nvim_win_call(leaf.win, function()
          vim.cmd('edit ' .. vim.fn.fnameescape(leaf.file))
          pcall(vim.api.nvim_win_set_cursor, leaf.win, leaf.cursor)
        end)
      elseif leaf.term then
        vim.api.nvim_win_set_buf(leaf.win, info_buffer(leaf.term, data.saved_at))
      end
    end

    vim.cmd('wincmd =')
  end

  pcall(vim.cmd, 'tabnext ' .. (data.tab or 1))
  if current_win and vim.api.nvim_win_is_valid(current_win) then
    vim.api.nvim_set_current_win(current_win)
  end
end

local function refresh_buffers()
  local cursors = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    cursors[win] = vim.api.nvim_win_get_cursor(win)
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd('filetype detect')
      end)
      vim.api.nvim_exec_autocmds('BufReadPost', { buffer = buf, modeline = false })
      vim.api.nvim_exec_autocmds('BufWinEnter', { buffer = buf, modeline = false })
    end
  end

  for win, pos in pairs(cursors) do
    if vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_set_cursor, win, pos)
    end
  end
end

local function load()
  local data = read_session()
  if not data then
    vim.notify('session: nothing saved for ' .. vim.fn.getcwd(), vim.log.levels.WARN)
    return
  end
  restore_windows(data)
end

local function autoload()
  if vim.fn.argc() > 0 or vim.g.session_autoloaded then return end
  local data = read_session()
  if not data then return end

  vim.g.session_autoloaded = true
  restore_windows(data)
  vim.cmd('redraw')

  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = refresh_buffers,
  })
end

local group = vim.api.nvim_create_augroup('SimpleSession', { clear = true })

local autosave_timer

local function start_autosave()
  if autosave_timer then return end
  autosave_timer = vim.uv.new_timer()
  autosave_timer:start(autosave_interval, autosave_interval, vim.schedule_wrap(function()
    pcall(save, false)
  end))
end

vim.api.nvim_create_user_command('SessionSave', function()
  local path = save(true)
  if path then vim.notify('session saved: ' .. path) end
end, {})

vim.api.nvim_create_user_command('SessionLoad', load, {})

vim.api.nvim_create_user_command('NewNvim', function()
  vim.cmd('silent! tabonly')
  vim.cmd('silent! only')

  local scratch = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_win_set_buf(0, scratch)

  local kept = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= scratch and vim.api.nvim_buf_is_valid(buf) then
      local force = vim.bo[buf].buftype ~= '' or not vim.bo[buf].modified
      if not pcall(vim.api.nvim_buf_delete, buf, { force = force }) then
        kept = kept + 1
      end
    end
  end

  if kept > 0 then
    vim.notify(kept .. ' buffer(s) kept: unsaved changes', vim.log.levels.WARN)
  end
end, {})

vim.api.nvim_create_user_command('SessionDelete', function()
  vim.fn.delete(session_path())
  last_written = nil
  vim.notify('session deleted: ' .. session_path())
end, {})

vim.api.nvim_create_autocmd('BufWipeout', {
  group = group,
  callback = function(ev)
    info_terms[ev.buf] = nil
    proc_cache[ev.buf] = nil
  end,
})

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = group,
  callback = function() pcall(save, true) end,
})

start_autosave()

return { save = save, load = load, autoload = autoload, path = session_path }

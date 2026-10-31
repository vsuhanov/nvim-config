local session_dir = vim.fn.stdpath('data') .. '/simple-sessions'
local autosave_interval = 60 * 1000
local window_tracking = require('window-tracking')

local function session_path()
  local cwd = vim.fn.getcwd():gsub('%%', '%%%%'):gsub('/', '%%')
  return session_dir .. '/' .. cwd .. '.lua'
end

local function is_file_buf(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].buflisted then return false end
  if vim.bo[buf].buftype ~= '' then return false end
  local name = vim.api.nvim_buf_get_name(buf)
  return name ~= '' and vim.fn.filereadable(name) == 1
end

local function open_files()
  local files = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_file_buf(buf) then
      table.insert(files, vim.api.nvim_buf_get_name(buf))
    end
  end
  return files
end

local function last_file()
  local win = window_tracking.get_last_file_window()
  if win and is_file_buf(vim.api.nvim_win_get_buf(win)) then
    return vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
  end

  local buf = vim.api.nvim_get_current_buf()
  if is_file_buf(buf) then
    return vim.api.nvim_buf_get_name(buf)
  end

  return nil
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

local function save()
  local data = { cwd = vim.fn.getcwd(), last = last_file(), files = open_files() }

  local key = vim.inspect(data)
  local path = session_path()
  if key == last_written and vim.fn.filereadable(path) == 1 then return path end

  if not write_session(path, 'return ' .. vim.inspect(data) .. '\n') then
    vim.notify('session: cannot write ' .. path, vim.log.levels.ERROR)
    return
  end

  last_written = key
  return path
end

local function read_session()
  local path = session_path()
  if vim.fn.filereadable(path) == 0 then return nil end
  local ok, data = pcall(dofile, path)
  if not ok or type(data) ~= 'table' then return nil end
  return data
end

local function open_last(data)
  if type(data.last) ~= 'string' or vim.fn.filereadable(data.last) == 0 then return false end
  vim.cmd('edit ' .. vim.fn.fnameescape(data.last))
  return true
end

local function refresh_buffer()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_call(buf, function()
    vim.cmd('filetype detect')
  end)
  vim.api.nvim_exec_autocmds('BufReadPost', { buffer = buf, modeline = false })
  vim.api.nvim_exec_autocmds('BufWinEnter', { buffer = buf, modeline = false })
end

local function load()
  local data = read_session()
  if not data then
    vim.notify('session: nothing saved for ' .. vim.fn.getcwd(), vim.log.levels.WARN)
    return
  end
  if not open_last(data) then
    vim.notify('session: no file saved for ' .. vim.fn.getcwd(), vim.log.levels.WARN)
  end
end

local function autoload()
  if vim.fn.argc() > 0 or vim.g.session_autoloaded then return end
  local data = read_session()
  if not data then return end

  vim.g.session_autoloaded = true
  if not open_last(data) then return end
  vim.cmd('redraw')

  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = refresh_buffer,
  })
end

local group = vim.api.nvim_create_augroup('SimpleSession', { clear = true })

local autosave_timer

local function start_autosave()
  if autosave_timer then return end
  autosave_timer = vim.uv.new_timer()
  autosave_timer:start(autosave_interval, autosave_interval, vim.schedule_wrap(function()
    pcall(save)
  end))
end

vim.api.nvim_create_user_command('SessionSave', function()
  local path = save()
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

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = group,
  callback = function() pcall(save) end,
})

start_autosave()

return { save = save, load = load, autoload = autoload, path = session_path }

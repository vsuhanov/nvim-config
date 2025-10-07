local function git_add_current_file_command()
  vim.cmd('w')         -- Write the current buffer to file
  vim.cmd('Git add %') -- Add the current file to the staging area using Git
end


local function git_commit_command(opts)
  vim.cmd('w') -- write the buffer first

  if opts.args == "" then
    vim.cmd('Git commit')
  else
    local message = vim.fn.shellescape(opts.args)
    vim.cmd("Git commit -m " .. message)
  end
end


local function git_commit_current_file(opts)
  vim.cmd("w")

  git_add_current_file_command()
  if opts.args == "" then
    vim.cmd("Git commit -- %")
  else
    local message = vim.fn.shellescape(opts.args)
    vim.cmd("Git commit -m " .. message .. " -- %")
  end
end

local function git_push_or_commit_current_file_and_push(opts)
  if (vim.bo.modifiable) then
    vim.cmd("w")
  end

  if opts.args ~= "" then
    git_commit_current_file(opts)
  end
  vim.cmd("Git push -u origin HEAD")
end

vim.api.nvim_create_user_command('Ga', git_add_current_file_command, {})
vim.api.nvim_create_user_command('Gc', git_commit_command, { nargs = "*" })
vim.api.nvim_create_user_command('Gf', git_commit_current_file, { nargs = "*" })
vim.api.nvim_create_user_command('Gpu', git_push_or_commit_current_file_and_push, { nargs = "*" })
-- open directory of the current file
vim.api.nvim_create_user_command('Dir', function() vim.cmd(":e %:p:h") end, {})
-- reload the config
vim.api.nvim_create_user_command('ReloadConfig',
  function() vim.cmd(":source " .. os.getenv("HOME") .. "/.config/nvim/init.lua") end, {})
-- test push


vim.api.nvim_create_user_command(
  'CopyBufferPath',
  function(opts)
    local path = vim.fn.expand('%:p')
    if opts.args == 'withLineNumber' then
      local line_number = vim.fn.line('.')
      path = path .. ':' .. line_number
    end
    vim.fn.setreg('+', path)
    print('Copied: ' .. path)
  end,
  { nargs = '?', complete = function() return {'withLineNumber'} end }
)

vim.api.nvim_create_user_command(
  'CopyRelativePath',
  function(opts)
    local abs_path = vim.fn.expand('%:p')
    local cwd = vim.fn.getcwd()
    local path = vim.fn.fnamemodify(abs_path, ':~:.')

    if opts.args == 'withLineNumber' then
      local line_number = vim.fn.line('.')
      path = path .. ':' .. line_number
    end
    vim.fn.setreg('+', path)
    print('Copied: ' .. path)
  end,
  { nargs = '?', complete = function() return {'withLineNumber'} end }
)

vim.api.nvim_create_user_command('Messages', function()
  vim.cmd('new')
  local messages = vim.fn.execute('messages')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(messages, '\n'))
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
  vim.bo.readonly = true
end, {})

vim.api.nvim_create_user_command('OpenInIdea', function()
  local utils = require('utils')
  local current_file = vim.fn.expand('%:p')
  if current_file == '' then
    print('No file is currently open')
    return
  end
  utils.open_in_idea(current_file)
end, {})

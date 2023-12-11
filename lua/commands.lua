local function git_add_current_file_command()
  vim.cmd('w')         -- Write the current buffer to file
  vim.cmd('Git add %') -- Add the current file to the staging area using Git
end

vim.api.nvim_create_user_command('Ga', git_add_current_file_command, {})

local function git_commit_command(opts)
  vim.cmd('w') -- write the buffer first

  if opts.args == "" then
    vim.cmd('Git commit')
  else
    local message = vim.fn.shellescape(opts.args)
    vim.cmd("Git commit -m " .. message)
  end
end
vim.api.nvim_create_user_command('Gc', git_commit_command, { nargs = "*" })


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
vim.api.nvim_create_user_command('Gf', git_commit_current_file, { nargs = "*" })

local function git_push_or_commit_current_file_and_push(opts)
  vim.cmd("w")

  if opts.args ~= "" then
    git_commit_current_file(opts)
  end
  vim.cmd("Git push -u origin HEAD")
end

vim.api.nvim_create_user_command('Gpu', git_push_or_commit_current_file_and_push, { nargs = "*" })

-- open directory of the current file
vim.api.nvim_create_user_command('Dir', function() vim.cmd(":e %:p:h") end, {})

-- reload the config
vim.api.nvim_create_user_command('ReloadConfig',
  function() vim.cmd(":source " .. os.getenv("HOME") .. "/config/init.vim") end, {})

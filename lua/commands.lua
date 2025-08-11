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
  function()
    local path = vim.fn.expand('%:p')
    vim.fn.setreg('+', path)
    print('Copied: ' .. path)
  end,
  {}
)

local function configure_terminal_buffer()
    -- Map window navigation keys to work from terminal mode
    vim.keymap.set('t', '<C-w>h', '<C-\\><C-n><C-w>h', { buffer = true })
    vim.keymap.set('t', '<C-w>j', '<C-\\><C-n><C-w>j', { buffer = true })
    vim.keymap.set('t', '<C-w>k', '<C-\\><C-n><C-w>k', { buffer = true })
    vim.keymap.set('t', '<C-w>l', '<C-\\><C-n><C-w>l', { buffer = true })
    vim.keymap.set('t', '<C-w>w', '<C-\\><C-n><C-w>w', { buffer = true })
    vim.keymap.set('t', '<C-w><C-w>', '<C-\\><C-n><C-w>w', { buffer = true })
    -- Optional: map other useful window commands
    vim.keymap.set('t', '<C-w>s', '<C-\\><C-n><C-w>s', { buffer = true })
    vim.keymap.set('t', '<C-w>v', '<C-\\><C-n><C-w>v', { buffer = true })
    vim.keymap.set('t', '<C-w>q', '<C-\\><C-n><C-w>q', { buffer = true })
    vim.keymap.set('t', '<C-w>c', '<C-\\><C-n><C-w>c', { buffer = true })
    vim.keymap.set('t', '<C-;>', '<C-\\><C-n>:', { buffer = true })
    vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { buffer = true })
    vim.keymap.set('t', ':q<CR>', '<C-\\><C-n>:bd!<cr>', { buffer = true })
    vim.cmd([[cnoreabbrev <buffer> <expr> q getcmdtype() == ":" && getcmdline() == "q" ? "bdelete" : "q"]])
    vim.cmd([[cnoreabbrev <buffer> <expr> q! getcmdtype() == ":" && getcmdline() == "q!" ? "bdelete!" : "q!"]])

    vim.cmd('startinsert')
  end
vim.api.nvim_create_autocmd('TermOpen', {
  callback = configure_terminal_buffer
})

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


local function claude_command()
  -- Check if a buffer named "Claude" already exists in current tab
  local claude_buf = nil
  local claude_win = nil
  local current_tab = vim.fn.tabpagenr()

  -- Check all windows in current tab
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.fn.bufname(buf)
    if buf_name == "Claude" then
      claude_win = win
      claude_buf = buf
      break
    end
  end

  if claude_win then
    -- Buffer is visible in current tab, focus it
    vim.api.nvim_set_current_win(claude_win)
    -- Enter terminal mode
    vim.api.nvim_feedkeys("A", "n", false)
  else
    -- Check if Claude buffer exists globally
    local buffers = vim.fn.getbufinfo()
    for _, buf in ipairs(buffers) do
      if vim.fn.bufname(buf.bufnr) == "Claude" then
        claude_buf = buf.bufnr
        break
      end
    end

    if claude_buf and vim.fn.bufexists(claude_buf) == 1 then
      -- Buffer exists but not in current window, open in vertical split
      vim.cmd("vs")
      vim.cmd("buffer " .. claude_buf)
      -- Enter terminal mode
      vim.api.nvim_feedkeys("A", "n", false)
    else
      -- Create new terminal buffer
      vim.cmd("vs | terminal claude")
      -- Set the buffer name to "Claude"
      vim.cmd("file Claude")
    end
  end
end

vim.api.nvim_create_user_command('Claude', claude_command, {})
vim.keymap.set("n", "<leader>ai", function() vim.cmd("Claude") end, {silent = true});
vim.keymap.set("n", "<leader>3", function() vim.cmd("Claude") end, {silent = true});

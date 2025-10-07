local M = {}

M.current_branch = nil
M.match_ids = {}

function M.get_git_branch()
  local handle = io.popen('git branch --show-current 2>/dev/null')
  if not handle then
    return nil
  end

  local branch = handle:read("*a")
  handle:close()

  if branch and branch ~= "" then
    return vim.trim(branch)
  end
  return nil
end

function M.setup_highlight_group()
  vim.api.nvim_set_hl(0, 'GitBranchCurrent', {
    fg = '#ff9900',
    bold = true,
    italic = false
  })
end

function M.clear_previous_highlight()
  for win_id, match_id in pairs(M.match_ids) do
    if vim.api.nvim_win_is_valid(win_id) then
      pcall(vim.fn.matchdelete, match_id, win_id)
    end
  end
  M.match_ids = {}
end

function M.debug_info()
  local branch = M.get_git_branch()
  print("Debug Info:")
  print("  Current branch:", branch or "nil")
  print("  Cached branch:", M.current_branch or "nil")
  print("  Active match IDs:", vim.inspect(M.match_ids))
  print("  Current window:", vim.api.nvim_get_current_win())
  print("  Current buffer:", vim.api.nvim_get_current_buf())
  print("  Buffer type:", vim.bo.buftype)
  print("  File type:", vim.bo.filetype)
end

function M.highlight_branch_in_window(win_id)
  if not M.current_branch then
    return
  end

  local escaped_branch = vim.fn.escape(M.current_branch, '[].*^$~\\')
  local pattern = '\\<' .. escaped_branch .. '\\>'

  if vim.api.nvim_win_is_valid(win_id) then
    local match_id = vim.fn.matchadd('GitBranchCurrent', pattern, 100, -1, { window = win_id })
    if match_id > 0 then
      M.match_ids[win_id] = match_id
    end
  end
end

function M.highlight_current_branch()
  local branch = M.get_git_branch()

  if not branch then
    M.clear_previous_highlight()
    M.current_branch = nil
    return
  end

  if branch == M.current_branch then
    local current_win = vim.api.nvim_get_current_win()
    if not M.match_ids[current_win] then
      M.highlight_branch_in_window(current_win)
    end
    return
  end

  M.clear_previous_highlight()
  M.current_branch = branch

  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    M.highlight_branch_in_window(win_id)
  end
end

function M.setup_autocmds()
  local group = vim.api.nvim_create_augroup('GitBranchHighlight', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'FocusGained', 'VimResume', 'DirChanged' }, {
    group = group,
    callback = function()
      vim.schedule(M.highlight_current_branch)
    end,
  })

  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    callback = function(args)
      local win_id = tonumber(args.match)
      if win_id and M.match_ids[win_id] then
        M.match_ids[win_id] = nil
      end
    end,
  })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      M.clear_previous_highlight()
    end,
  })
end

function M.setup()
  M.setup_highlight_group()
  M.setup_autocmds()
  M.highlight_current_branch()

  vim.api.nvim_create_user_command('GitBranchHighlightDebug', function()
    M.debug_info()
  end, { desc = 'Show git branch highlighting debug info' })

  vim.api.nvim_create_user_command('GitBranchHighlightRefresh', function()
    M.highlight_current_branch()
    print('Git branch highlighting refreshed')
  end, { desc = 'Refresh git branch highlighting' })
end

return M

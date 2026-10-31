local window_matches = require('utils.window-matches')

local M = {}

M.current_branch = nil
M.previous_branch = nil

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

function M.get_previous_branch()
  local handle = io.popen('git rev-parse --abbrev-ref @{-1} 2>/dev/null')
  if not handle then
    return nil
  end

  local branch = handle:read("*a")
  handle:close()

  if branch and branch ~= "" then
    local trimmed = vim.trim(branch)
    -- Don't return the same branch as current
    if trimmed ~= M.current_branch then
      return trimmed
    end
  end
  return nil
end

function M.setup_highlight_group()
  vim.api.nvim_set_hl(0, 'GitBranchCurrent', {
    fg = '#ff9900',
    bold = true,
    italic = false
  })

  vim.api.nvim_set_hl(0, 'GitBranchPrevious', {
    fg = '#cc7700',
    bold = false,
    italic = true
  })
end

function M.debug_info()
  local branch = M.get_git_branch()
end

local function branch_pattern(branch)
  if not branch then
    return nil
  end
  return '\\<' .. vim.fn.escape(branch, '[].*^$~\\') .. '\\>'
end

function M.highlight_current_branch()
  local branch = M.get_git_branch()
  local prev_branch = branch and M.get_previous_branch() or nil

  if branch == M.current_branch and prev_branch == M.previous_branch then
    return
  end

  M.current_branch = branch
  M.previous_branch = prev_branch

  window_matches.set('git_branch_current', 'GitBranchCurrent', branch_pattern(branch), 100)
  window_matches.set('git_branch_previous', 'GitBranchPrevious', branch_pattern(prev_branch), 99)
end

function M.setup_autocmds()
  local group = vim.api.nvim_create_augroup('GitBranchHighlight', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'FocusGained', 'VimResume', 'DirChanged' }, {
    group = group,
    callback = function()
      vim.schedule(M.highlight_current_branch)
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

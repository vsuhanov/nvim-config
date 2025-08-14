local M = {}

local opts = { silent = true }

-- Variable to track what was last closed
local last_closed = nil

local function toggle_quickfix()
  local quickfix_open = false
  local loclist_open = false

  -- Check for quickfix window
  for _, win in pairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 and win.loclist == 0 then
      quickfix_open = true
      break
    end
  end

  -- Check for loclist window belonging to current window
  local current_winnr = vim.fn.winnr()
  local loclist_info = vim.fn.getloclist(current_winnr, {winid = 0})
  if loclist_info.winid ~= 0 then
    loclist_open = true
  end


  if loclist_open then
    vim.cmd('lclose')
    last_closed = 'loclist'
  elseif quickfix_open then
    vim.cmd('cclose')
    last_closed = 'quickfix'
  else
    -- Neither is open, decide what to open
    -- Get loclist and quickfix info
    local loclist = vim.fn.getloclist(0, { all = 0 })
    local qflist = vim.fn.getqflist({ all = 0 })

    local has_loclist_items = #loclist.items > 0
    local has_qflist_items = #qflist.items > 0


    -- If something was recently closed, try to reopen it (if it has items)
    if last_closed == 'loclist' and has_loclist_items then
      vim.cmd('lopen')
      last_closed = nil
    elseif last_closed == 'quickfix' and has_qflist_items then
      vim.cmd('copen')
      last_closed = nil
      -- Otherwise follow priority: loclist first, then quickfix
    elseif has_loclist_items then
      vim.cmd('lopen')
    elseif has_qflist_items then
      vim.cmd('copen')
    else
      vim.cmd('copen')
    end
  end
end

-- Helper function to determine which list to use (loclist has priority)
local function get_active_list()
  local loclist_open = false
  local quickfix_open = false

  -- Check if any list is open
  for _, win in pairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      if win.loclist == 1 then
        loclist_open = true
      else
        quickfix_open = true
      end
      break
    end
  end

  if loclist_open then
    return 'loclist'
  elseif quickfix_open then
    return 'quickfix'
  else
    -- Neither is open, check which has items (loclist priority)
    local loclist = vim.fn.getloclist(0, { all = 0 })
    local qflist = vim.fn.getqflist({ all = 0 })

    if #loclist.items > 0 then
      return 'loclist'
    elseif #qflist.items > 0 then
      return 'quickfix'
    else
      return 'quickfix' -- default fallback
    end
  end
end

local function smart_next()
  local active_list = get_active_list()
  if active_list == 'loclist' then
    pcall(vim.cmd, 'lnext')
  else
    pcall(vim.cmd, 'cnext')
  end
end

local function smart_prev()
  local active_list = get_active_list()
  if active_list == 'loclist' then
    pcall(vim.cmd, 'lprev')
  else
    pcall(vim.cmd, 'cprev')
  end
end

local function smart_first()
  local active_list = get_active_list()
  if active_list == 'loclist' then
    pcall(vim.cmd, 'lfirst')
  else
    pcall(vim.cmd, 'cfirst')
  end
end

local function smart_last()
  local active_list = get_active_list()
  if active_list == 'loclist' then
    pcall(vim.cmd, 'llast')
  else
    pcall(vim.cmd, 'clast')
  end
end

-- Setup function to initialize keymappings
function M.setup()
  vim.keymap.set('n', '<leader>qq', toggle_quickfix, { desc = 'Toggle quickfix/loclist' })
  vim.keymap.set('n', '<leader>qn', smart_next, opts)
  vim.keymap.set('n', '<leader>qp', smart_prev, opts)
  vim.keymap.set('n', '<leader>qf', smart_first, opts)
  vim.keymap.set('n', '<leader>ql', smart_last, opts)
  vim.keymap.set("n", "<leader>cn", smart_next, opts)
  vim.keymap.set("n", "<leader>cp", smart_prev, opts)
end
M.setup()
return M

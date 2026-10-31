local M = {}

local registry = {}
local base_id = 0x100000
local next_id = base_id

local function apply(win, entry)
  pcall(vim.fn.matchdelete, entry.id, win)
  if entry.pattern then
    pcall(vim.fn.matchadd, entry.group, entry.pattern, entry.priority, entry.id, { window = win })
  end
end

local function apply_all(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  for _, entry in pairs(registry) do
    apply(win, entry)
  end
end

function M.set(name, group, pattern, priority)
  local entry = registry[name]
  if not entry then
    next_id = next_id + 1
    entry = { id = next_id }
    registry[name] = entry
  end
  entry.group = group
  entry.pattern = pattern
  entry.priority = priority or 10

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    apply(win, entry)
  end
end

function M.clear(name)
  if registry[name] then
    M.set(name, nil, nil)
  end
end

vim.api.nvim_create_autocmd({ 'WinNew', 'WinEnter' }, {
  group = vim.api.nvim_create_augroup('WindowMatches', { clear = true }),
  callback = function()
    apply_all(vim.api.nvim_get_current_win())
  end,
})

return M

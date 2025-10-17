local M = {}

-- Vibrant color palette (8 colors)
-- Each color pair: { background, foreground }
M.colors = {
  { bg = '#9B59B6', fg = '#FFFFFF' }, -- Vibrant Purple
  { bg = '#3498DB', fg = '#FFFFFF' }, -- Vibrant Blue
  { bg = '#1ABC9C', fg = '#FFFFFF' }, -- Vibrant Teal
  { bg = '#2ECC71', fg = '#1A1A1A' }, -- Vibrant Green
  { bg = '#F39C12', fg = '#1A1A1A' }, -- Vibrant Orange
  { bg = '#E74C3C', fg = '#FFFFFF' }, -- Vibrant Red
  { bg = '#E91E63', fg = '#FFFFFF' }, -- Vibrant Pink
  { bg = '#FFC107', fg = '#1A1A1A' }, -- Vibrant Amber
}

-- Simple hash function for strings
local function hash_string(str)
  local hash = 0
  for i = 1, #str do
    hash = (hash * 31 + string.byte(str, i)) % 2147483647
  end
  return hash
end

-- Get color index based on CWD (deterministic)
function M.get_cwd_color_index()
  local cwd = vim.fn.getcwd()
  local hash = hash_string(cwd)
  return (hash % #M.colors) + 1
end

function M.setDarkMode()
  vim.cmd("colo nightfox");

  local color_index = M.get_cwd_color_index()
  local color = M.colors[color_index]

  vim.api.nvim_set_hl(0, 'WinBar', { bg = color.bg, fg = color.fg, bold = false })
  vim.api.nvim_set_hl(0, 'WinBarNC', { bg = '#0E141C', fg = "#9DA0A1" })

  -- vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#ff0000" }) -- Red cursor, black text
  vim.opt.winbar = "%=%f "
end

function M.setLightMode()
  vim.cmd("colo dayfox");

  local color_index = M.get_cwd_color_index()
  local color = M.colors[color_index]

  vim.api.nvim_set_hl(0, 'WinBar', { bg = color.bg, fg = color.fg, bold = true })
  vim.api.nvim_set_hl(0, 'WinBarNC', { bg = '#dedede', fg = "#ffffff" })

  -- vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#111111" }) -- Red cursor, black text
  vim.opt.winbar = "%=%f "
end

-- M.setLightMode()

return M

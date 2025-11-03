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

-- Convert hex color to RGB values
local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return {
    r = tonumber(hex:sub(1, 2), 16),
    g = tonumber(hex:sub(3, 4), 16),
    b = tonumber(hex:sub(5, 6), 16)
  }
end

-- Set iTerm2 tab color using escape sequences
function M.set_iterm_tab_color(hex_color)
  local rgb = hex_to_rgb(hex_color)
  -- iTerm2 escape sequence to set tab color
  local escape_seq = string.format(
    "\027]6;1;bg;red;brightness;%d\007\027]6;1;bg;green;brightness;%d\007\027]6;1;bg;blue;brightness;%d\007",
    rgb.r, rgb.g, rgb.b
  )
  io.write(escape_seq)
  io.flush()
end

function M.setDarkMode()
  vim.cmd("colo nightfox");

  local color_index = M.get_cwd_color_index()
  local color = M.colors[color_index]

  vim.api.nvim_set_hl(0, 'WinBar', { bg = color.bg, fg = color.fg, bold = false })
  vim.api.nvim_set_hl(0, 'WinBarNC', { bg = '#0E141C', fg = "#9DA0A1" })
  -- vim.api.nvim_set_hl(0, 'Comment', { fg = "#ff9900" })
  vim.api.nvim_set_hl(0, '@comment', { fg = "#ff9900" })
  -- Set iTerm2 tab color to match winbar
  M.set_iterm_tab_color(color.bg)

  -- vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#ff0000" }) -- Red cursor, black text
  vim.opt.winbar = "%=%f "
  require('region-highlight').setDarkMode()
end

function M.setLightMode()
  vim.cmd("colo dayfox");

  local color_index = M.get_cwd_color_index()
  local color = M.colors[color_index]


  vim.api.nvim_set_hl(0, 'WinBar', { bg = color.bg, fg = color.fg, bold = true })
  vim.api.nvim_set_hl(0, 'WinBarNC', { bg = '#dedede', fg = "#ffffff" })
  vim.api.nvim_set_hl(0, 'Comment', { fg = "#222222", bg = "#a6a6a6" })
  vim.api.nvim_set_hl(0, '@comment', { fg = "#8c3800" })

  -- Set iTerm2 tab color to match winbar
  M.set_iterm_tab_color(color.bg)

  -- vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#111111" }) -- Red cursor, black text
  vim.opt.winbar = "%=%f "
  require('region-highlight').setLightMode()
end

-- M.setDarkMode()
-- M.setLightMode()

return M

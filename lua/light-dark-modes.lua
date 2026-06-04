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

local function set_winbar()
  vim.opt.winbar = "%=%{&buftype==#'terminal'?'term: '.get(b:,'term_title',''):expand('%:f')} "
end

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

local function resolve_color()
  local override = require('not-plugins.project-config').get_color()
  if override then return { bg = override, fg = '#FFFFFF' } end
  return M.colors[M.get_cwd_color_index()]
end

function M.setDarkMode()
  vim.cmd("colo nightfox");

  local color = resolve_color()
  vim.api.nvim_set_hl(0, 'WinBar', { bg = color.bg, fg = color.fg, bold = false })
  vim.api.nvim_set_hl(0, 'WinBarNC', { bg = '#0E141C', fg = "#9DA0A1" })
  vim.api.nvim_set_hl(0, '@comment', { fg = "#ff9900" })
  require('iterm-utils').set_tab_color(color.bg)
  set_winbar()
  require('region-highlight').setDarkMode()
end

function M.setLightMode()
  vim.cmd("colo dayfox");

  local color = resolve_color()
  vim.api.nvim_set_hl(0, 'WinBar', { bg = color.bg, fg = color.fg, bold = true })
  vim.api.nvim_set_hl(0, 'WinBarNC', { bg = '#dedede', fg = "#ffffff" })
  vim.api.nvim_set_hl(0, 'Comment', { fg = "#8c3800" })
  vim.api.nvim_set_hl(0, '@comment', { fg = "#8c3800" })
  require('iterm-utils').set_tab_color(color.bg)
  set_winbar()
  require('region-highlight').setLightMode()
end

-- M.setDarkMode()
-- M.setLightMode()

return M

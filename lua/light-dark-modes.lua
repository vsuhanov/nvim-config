local M = {}
function M.setDarkMode()
  vim.cmd("colo nightfox");
  vim.api.nvim_set_hl(0, 'WinBar', { bg = '#5389D3', fg = '#0E141C', bold = false })
  vim.api.nvim_set_hl(0, 'WinBarNC', { bg = '#0E141C', fg = "#9DA0A1" })

  -- vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#ff0000" }) -- Red cursor, black text
  vim.opt.winbar = "%=%f "
end

function M.setLightMode()
  vim.cmd("colo dayfox");
  vim.api.nvim_set_hl(0, 'WinBar', { bg = '#87CEEB', bold = true })
  vim.api.nvim_set_hl(0, 'WinBarNC', { bg = '#dedede', fg = "#ffffff" })

  vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#111111" }) -- Red cursor, black text
  vim.opt.winbar = "%=%f "
end

-- M.setLightMode()

return M

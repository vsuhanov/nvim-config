local M = {}
function M.setDarkModeWinBar()
  vim.api.nvim_set_hl(0, 'WinBar', { bg = '#5389D3', fg = '#0E141C', bold = false })
  vim.api.nvim_set_hl(0, 'WinBarNC', { bg = '#0E141C', fg = "#9DA0A1" })

  vim.opt.winbar = "%=%f "
end

function M.setLightModeWinBar()
  vim.api.nvim_set_hl(0, 'WinBar', { bg = '#87CEEB', bold = true })
  vim.api.nvim_set_hl(0, 'WinBarNC', { bg = '#dedede', fg = "#ffffff" })

  vim.opt.winbar = "%=%f "
end
return M

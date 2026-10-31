local window_matches = require('utils.window-matches')

local M = {}

M.pattern = [=[\v<%(https?|ftp|file)://[^[:space:]<>"'`]*[^[:space:]<>"'`.,;:!?)\]}]]=]

function M.setup()
  vim.api.nvim_set_hl(0, 'UrlHighlight', {
    fg = '#2b6cb8',
    sp = '#2b6cb8',
    underline = true
  })

  window_matches.set('url', 'UrlHighlight', M.pattern, 110)
end

return M

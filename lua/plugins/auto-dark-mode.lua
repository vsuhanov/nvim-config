local winbar = require('winbar')
require('auto-dark-mode').setup({
    set_dark_mode = function()
      vim.cmd("colo nightfox");
      winbar.setDarkModeWinBar()
    end,
    set_light_mode = function()
      vim.cmd("colo dayfox");
      winbar.setLightModeWinBar()
    end,
    update_interval = 3000,
    fallback = "dark"
})

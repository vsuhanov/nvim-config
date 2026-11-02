local myLightDarkModes = require('light-dark-modes')
return {
  "f-person/auto-dark-mode.nvim",
  -- macOS only: on Linux, light/dark follows the terminal (see light-dark-modes)
  cond = vim.fn.has('mac') == 1,
  opts = {
    set_dark_mode = myLightDarkModes.setDarkMode,
    set_light_mode = myLightDarkModes.setLightMode,
    update_interval = 3000,
    fallback = "dark"
  }
}

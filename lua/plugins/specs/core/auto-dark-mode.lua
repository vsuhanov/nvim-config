local myLightDarkModes = require('light-dark-modes')
return {
  "f-person/auto-dark-mode.nvim",
  opts = {
    set_dark_mode = myLightDarkModes.setDarkMode,
    set_light_mode = myLightDarkModes.setLightMode,
    update_interval = 3000,
    fallback = "dark"
  }
}

local myLightDarkModes = require('light-dark-modes')
require('auto-dark-mode').setup({
  set_dark_mode = myLightDarkModes.setDarkMode,
  set_light_mode = myLightDarkModes.setLightMode,
  update_interval = 3000,
  fallback = "dark"
})

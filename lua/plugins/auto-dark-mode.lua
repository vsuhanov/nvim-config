require('auto-dark-mode').setup({
    set_dark_mode = function()
      vim.cmd("colo nightfox");
    end,
    set_light_mode = function()
      vim.cmd("colo dayfox");
    end,
    update_interval = 3000,
    fallback = "dark"
})

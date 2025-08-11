local nvimWindow = require('nvim-window')
nvimWindow.setup({
  chars = {
    'j', 'k', 'l', 'a', 's', 'd', 'f', 'b', 'c', 'd', 'e', 'g', 'h', 'i', 'm', 'n', 'o',
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
  },
})
vim.keymap.set("n", "<leader>wj", function() nvimWindow.pick() end,
  { desc = "nvim-window: Jump to window", silent = true })

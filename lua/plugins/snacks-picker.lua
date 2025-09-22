local snacks = require('snacks')
local actions = require('snacks.picker.actions')

snacks.setup({
  picker = {
    enabled = true,
    layout = {
      preset = "default",
    },
    win = {
      input = {
        keys = { ["<c-h>"] = "help", ["<c-q>"] = "loclist" },
      },
    },
    actions = {
     loclist = actions.loclist,
    },
  },
})

require('plugins.snacks-picker-keymap')

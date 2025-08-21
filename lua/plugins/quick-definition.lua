local quick_definition = require("quick-definition")
quick_definition.setup()

vim.keymap.set('v', '<2-LeftMouse>', function()
  vim.cmd('normal! <Esc>')
  quick_definition.quick_definition()
end, { silent = true })

vim.keymap.set('n', '<2-LeftMouse>', function()
  quick_definition.quick_definition()
end, { silent = true })

vim.keymap.set("n", "K", function() quick_definition.quick_definition() end, opts)

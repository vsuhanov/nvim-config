local toggle_file = require("toggle-file")
local opts = { silent = true }
vim.keymap.set("n", "<leader>1", function() toggle_file.toggle_file_window("~/Daily Notes.md") end, opts)
vim.keymap.set("n", "<leader>2", function() toggle_file.toggle_file_window(toggle_file.get_remembered_file()) end, opts)

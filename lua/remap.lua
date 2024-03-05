local keymap = vim.keymap.set
local opts = { silent = true }

vim.g.mapleader=' '

keymap("n", "<leader>d", '"tyy"tp', opts)
keymap("v", "<leader>d", '"ty`>"tp', opts)
keymap("n", "<leader>;", "msA;<esc>`s", opts)
keymap("n", "<leader>vt", ":e %:h<cr>", opts)
keymap("n", "-", ":e %:h<cr>", opts)
keymap("n", "<leader>c", ":only<cr>", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

-- navigate to visual like with j,k instead of real line
keymap("n", "j", "gj", opts)
keymap("n", "k", "gk", opts)

-- resize windows through CTRL+SHIFT+arrow keys
keymap("n", "<C-S-Right>", ":vertical resize +2<cr>", opts)
keymap("n", "<C-S-Left>", ":vertical resize -2<cr>", opts)
keymap("n", "<C-S-Up>", ":resize +2<cr>", opts)
keymap("n", "<C-S-Down>", ":resize -2<cr>", opts)
keymap("n", "<leader>cn", ":cn<cr>", opts)
keymap("n", "<leader>cp", ":cp<cr>", opts)

-- -- Visual mode mappings
keymap("n", "<C-_>", "gc", opts)
keymap("v", "<C-_>", "gc", opts)

-- Telescope mappings
keymap('n', '<leader>wo', ':Telescope find_files<CR>', opts)
keymap('n', '<leader>ff', ':Telescope live_grep<CR>', opts)
keymap('n', '<leader>fb', ':Telescope buffers<CR>', opts)
keymap('n', '<leader>hh', ':Telescope treesitter<CR>', opts)
-- harpoon mappings
local harpoon = require("harpoon")
keymap("n", "<leader>aa", function() harpoon:list():append() end)
keymap("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
keymap("n", "<leader>ee", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
keymap("n", "<leader>hu", function() harpoon:list():select(1) end)
keymap("n", "<leader>hi", function() harpoon:list():select(2) end)
keymap("n", "<leader>ho", function() harpoon:list():select(3) end)
keymap("n", "<leader>hp", function() harpoon:list():select(4) end)

keymap("t", "<C-esc>", "<C-\\><C-n>")
keymap("t", "<esc><esc>", "<C-\\><C-n>")

keymap("n", "<leader>ll", ":LspZeroFormat<CR>", opts)


keymap("n", "<leader>ll", ":LspZeroFormat<CR>", opts)
keymap("n", "<leader>gpt", ":ChatChatToggle<CR>", opts)

-- keymap("n", "<leader>;;", ":source /Users/vitaly/.config/nvim/init.lua")

local toggle_file = require("toggle-file")
vim.keymap.set("n", "<leader>1", function() toggle_file.toggle_file_window("~/Daily Notes.md") end, opts)
vim.keymap.set("n", "<leader>2", function() toggle_file.toggle_file_window("./TODO.md") end, opts)

-- quick definition hotkeys
local quick_definition = require("quick-definition")
vim.keymap.set("n", "K", function() quick_definition.quick_definition() end, opts)
vim.keymap.set("n", "<2-LeftMouse>", function() quick_definition.quick_definition() end, opts)
vim.keymap.set("n", "<MiddleMouse>", function() vim.lsp.buf.definition() end, opts)

-- copy to system clipboard. Normal mode will copy latest selection
vim.keymap.set("n", "<leader>y", 'mt`<v`>"+y`t')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>p", '"+p')
vim.keymap.set("n", "<leader>P", '"+P')
vim.keymap.set("v", "<leader>p", '"+p')
vim.keymap.set("v", "<leader>P", '"+P')
--navigate commands
vim.keymap.set("c", "<C-K>", '<Up>')
vim.keymap.set("c", "<C-J>", '<Down>')
vim.keymap.set("c", "<C-H>", '<Left>')
vim.keymap.set("c", "<C-L>", '<Right>')



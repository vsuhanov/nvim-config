local keymap = vim.keymap.set
local opts = { silent = true }

vim.g.mapleader=' '

-- Normal mode mappings
-- keymap("n", "K", vim.cmd.ShowDocumentation, opts)
keymap("n", "<leader>d", "yyp", opts)
-- keymap("n", "<leader>qb", ":bd<cr>", opts)
-- keymap("n", "<leader>qq", ":bn<cr>:bd #<cr>", opts)
-- keymap("n", "<leader>n", ":bn<cr>", opts)
-- keymap("n", "<leader>p", ":bp<cr>", opts)
keymap("n", "<leader>;", "msA;<esc>`s", opts)
-- -- keymap("n", "<leader><leader>t", ":new | r!", opts)  -- This line is commented out because it is incomplete
-- todo need to figure out a way to call my user command
-- keymap("n", "<leader>ll", vim.cmd.FormatClang, opts)
--
keymap("n", "<leader>vt", ":e %:h<cr>", opts)
keymap("n", "<leader>c", ":only<cr>", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)
-- navigate to visual like with j,k instead of real line
keymap("n", "j", "gj", opts)
keymap("n", "k", "gk", opts)

-- resize windows through CTRL+SHIFT+arrow keys
keymap("n", "<C-S-Left>", ":vertical resize +2<cr>", opts)
keymap("n", "<C-S-Right>", ":vertical resize -2<cr>", opts)
keymap("n", "<C-S-Up>", ":resize +2<cr>", opts)
keymap("n", "<C-S-Down>", ":resize -2<cr>", opts)

-- -- Visual mode mappings
-- keymap("v", "<leader>d", "y`>p", opts)
-- keymap("v", "<leader>qq", nil, opts)
-- comment on ctrl + /
keymap("n", "<C-_>", "gc", opts)
keymap("v", "<C-_>", "gc", opts)

-- CoC mappings
--
--
-- Telescope mappings
local harpoon = require("harpoon")
keymap('n', '<leader>wo', ':Telescope find_files<CR>', opts)
keymap('n', '<leader>ff', ':Telescope live_grep<CR>', opts)
keymap('n', '<leader>fb', ':Telescope buffers<CR>', opts)
keymap('n', '<leader>hh', ':Telescope treesitter<CR>', opts)
keymap("n", "<leader>aa", function() harpoon:list():append() end)
keymap("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

keymap("n", "<leader>hu", function() harpoon:list():select(1) end)
keymap("n", "<leader>hi", function() harpoon:list():select(2) end)
keymap("n", "<leader>ho", function() harpoon:list():select(3) end)
keymap("n", "<leader>hp", function() harpoon:list():select(4) end)

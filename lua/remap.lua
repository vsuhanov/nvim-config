local keymap = vim.keymap.set
local opts = { silent = true }

vim.g.mapleader=' '

keymap("n", "<leader>d", '"tyy"tp', opts)
keymap("v", "<leader>d", '"ty`>"tp', opts)
keymap("n", "<leader>;", "msA;<esc>`s", opts)
keymap("n", "<leader>vt", ":e %:h<cr>", opts)
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

-- paste yanked text, I will use idiomatic 0 register
keymap({"n", "v"}, "<leader>p", '"0p', opts)
-- CoC mappings

-- Telescope mappings
local harpoon = require("harpoon")
keymap('n', '<leader>wo', ':Telescope find_files<CR>', opts)
keymap('n', '<leader>ff', ':Telescope live_grep<CR>', opts)
keymap('n', '<leader>fb', ':Telescope buffers<CR>', opts)
keymap('n', '<leader>hh', ':Telescope treesitter<CR>', opts)
keymap("n", "<leader>aa", function() harpoon:list():append() end)
keymap("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
keymap("n", "<leader>ee", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

keymap("n", "<leader>hu", function() harpoon:list():select(1) end)
keymap("n", "<leader>hi", function() harpoon:list():select(2) end)
keymap("n", "<leader>ho", function() harpoon:list():select(3) end)
keymap("n", "<leader>hp", function() harpoon:list():select(4) end)

-- CoC mappings

keymap("n", "<leader>gd", "<Plug>(coc-definition)")
keymap("n", "<leader>b", "<Plug>(coc-type-definition)")
keymap("n", "<leader>gy", "<Plug>(coc-implementation)")
keymap("n", "<leader>gr", "<Plug>(coc-references)")
keymap("n", "<leader>ge", "<Plug>(coc-diagnostic-next)")

keymap("t", "<C-esc>", "<C-\\><C-n>")
keymap("t", "<esc><esc>", "<C-\\><C-n>")

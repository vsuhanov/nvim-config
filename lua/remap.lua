local keymap = vim.keymap.set
local opts = { silent = true }

vim.g.mapleader = ' '

keymap("n", "<leader>d", '"tyy"tp', opts)
keymap("v", "<leader>d", '"ty`>"tp', opts)
keymap("n", "<leader>;", "msA;<esc>`s", opts)
keymap("n", "<leader>vt", ":e %:h<cr>", opts)
keymap("n", "<leader>c", function()
  vim.cmd(":tab split")
end, opts)
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

-- -- Visual mode mappings
keymap("n", "<C-_>", "gc", opts)
keymap("v", "<C-_>", "gc", opts)

-- Generic function to call telescope with selected text in visual mode



keymap("t", "<C-esc>", "<C-\\><C-n>")
keymap("t", "<esc><esc>", "<C-\\><C-n>")


-- quick definition hotkeys

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

-- vim.keymap.set("n", "<leader>b", "<Plug>(coc-definition)", opts)
-- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
vim.keymap.set("n", "<leader>ge", function() vim.diagnostic.goto_next() end, opts)
vim.keymap.set("n", "<leader>gee", function() vim.diagnostic.goto_next() end, opts)
vim.keymap.set("n", "<leader>gep", function() vim.diagnostic.goto_prev() end, opts)
vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
vim.keymap.set("n", "<leader>rv", function() vim.lsp.buf.rename() end, opts)
vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
vim.keymap.set("n", "<leader>ll", function() vim.lsp.buf.format() end, opts);
vim.keymap.set('n', '<C-;>', ':', { silent = false })
vim.keymap.set('n', '<X1Mouse>', '<C-o>', { silent = false })
vim.keymap.set('n', '<X2Mouse>', '<C-i>', { silent = false })
vim.keymap.set('v', '<X1Mouse>', ':normal! <Esc><C-o>', { silent = false })
vim.keymap.set('v', '<X2Mouse>', ':normal! <Esc><C-i>', { silent = false })

-- Telescope fallback keymaps (only if telescope is not installed)
-- local telescope_ok, _ = pcall(require, 'telescope')
-- if not telescope_ok then
--   -- Add your fallback keymaps here
--   vim.keymap.set("n", "<leader>b", function() vim.lsp.buf.definition({ loclist = true }) end, opts)
--   vim.keymap.set("n", "<leader>fu", function() vim.lsp.buf.references(nil, { loclist = true }) end, opts)
-- end

-- Double-click to quick definition
vim.keymap.set('n', '<MiddleMouse>', function()
  vim.lsp.buf.definition({ loclist = true })
end, { silent = true })

vim.keymap.set('v', 'p', 'P', { noremap = true })
vim.keymap.set('v', 'c', '"cc', { noremap = true })
vim.keymap.set('v', 'C', '"cC', { noremap = true })
vim.keymap.set('n', 'c', '"cc', { noremap = true })
vim.keymap.set('n', 'C', '"cC', { noremap = true })

vim.keymap.set('n', '<leader>6', '<C-^>', {})

vim.keymap.set({"n"}, "<C-S-c>", ":CopyBufferPath<CR>", {})
vim.keymap.set({"n"}, "<C-M-c>", ":CopyRelativePath<CR>", {})

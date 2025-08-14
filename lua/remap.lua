local keymap = vim.keymap.set
local opts = { silent = true }

vim.g.mapleader = ' '

keymap("n", "<leader>d", '"tyy"tp', opts)
keymap("v", "<leader>d", '"ty`>"tp', opts)
keymap("n", "<leader>;", "msA;<esc>`s", opts)
keymap("n", "<leader>vt", ":e %:h<cr>", opts)
keymap("n", "<leader>c", function()
  vim.cmd(":tab split")
  vim.cmd(':Tabs')
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
local function telescope_with_selection(telescope_func)
  return function()
    -- Save current register
    local save_reg = vim.fn.getreg('"')
    local save_regtype = vim.fn.getregtype('"')

    -- Yank selected text to unnamed register
    vim.cmd('normal! y')

    -- Get the yanked text
    local selected_text = vim.fn.getreg('"')

    -- Restore register
    vim.fn.setreg('"', save_reg, save_regtype)

    telescope_func({ default_text = selected_text })
  end
end

-- Telescope mappings
keymap('n', '<leader>wo', ':Telescope find_files<CR>', opts)
keymap('n', '<leader>ff', ':Telescope live_grep<CR>', opts)
keymap('n', '<leader>fb', ':Telescope buffers<CR>', opts)
keymap('n', '<leader>wb', ':Telescope buffers<CR>', opts)
keymap('n', '<leader>hh', ':Telescope treesitter<CR>', opts)

-- Telescope visual mode mappings with selected text
keymap('v', '<leader>wo', telescope_with_selection(require('telescope.builtin').find_files), opts)
keymap('v', '<leader>ff', telescope_with_selection(require('telescope.builtin').live_grep), opts)
keymap('v', '<leader>fb', telescope_with_selection(require('telescope.builtin').buffers), opts)
keymap('v', '<leader>wb', telescope_with_selection(require('telescope.builtin').buffers), opts)
keymap('v', '<leader>hh', telescope_with_selection(require('telescope.builtin').treesitter), opts)

keymap("t", "<C-esc>", "<C-\\><C-n>")
keymap("t", "<esc><esc>", "<C-\\><C-n>")

local toggle_file = require("toggle-file")
vim.keymap.set("n", "<leader>1", function() toggle_file.toggle_file_window("~/Daily Notes.md") end, opts)
vim.keymap.set("n", "<leader>2", function() toggle_file.toggle_file_window("./TODO.md") end, opts)

-- quick definition hotkeys
local quick_definition = require("quick-definition")

vim.keymap.set("n", "K", function() quick_definition.quick_definition() end, opts)
-- vim.keymap.set("n", "<2-LeftMouse>", function() quick_definition.quick_definition() end, opts)
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

vim.keymap.set("n", "<leader>b", function() vim.lsp.buf.definition({ loclist = true }) end, opts)
-- vim.keymap.set("n", "<leader>b", "<Plug>(coc-definition)", opts)
-- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
vim.keymap.set("n", "<leader>ge", function() vim.diagnostic.goto_next() end, opts)
vim.keymap.set("n", "<leader>gee", function() vim.diagnostic.goto_next() end, opts)
vim.keymap.set("n", "<leader>gep", function() vim.diagnostic.goto_prev() end, opts)
vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
vim.keymap.set("n", "<leader>fu", function() vim.lsp.buf.references(nil, { loclist = true }) end, opts)
vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
vim.keymap.set("n", "<leader>ll", function() vim.lsp.buf.format() end, opts);
vim.keymap.set('n', '<C-;>', ':', { silent = false })

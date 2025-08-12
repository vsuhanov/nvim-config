local keymap = vim.keymap.set
local opts = { silent = true }

vim.g.mapleader = ' '

keymap("n", "<leader>d", '"tyy"tp', opts)
keymap("v", "<leader>d", '"ty`>"tp', opts)
keymap("n", "<leader>;", "msA;<esc>`s", opts)
keymap("n", "<leader>vt", ":e %:h<cr>", opts)
-- keymap("n", "-", ":e %:h<cr>", opts)
-- local function safe_open_oil()
--   local ok, err = pcall(vim.cmd, 'e ' .. vim.fn.expand('%:h'))
--   if not ok then
--     vim.cmd('e .')
--   end
-- end
--
-- keymap("n", "-", safe_open_oil, opts)

-- keymap("n", "-", ":silent! e %:h | if v:shell_error | echo 'Directory navigation failed' | endif<cr>", opts)
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
keymap("n", "<leader>cn", ":cn<cr>", opts)
keymap("n", "<leader>cp", ":cp<cr>", opts)

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

-- keymap("n", "<leader>ll", function() vim.lsp.buf.format({ async = true }) end, opts)
--
--
keymap("n", "<leader>gpt", ":ChatChatToggle<CR>", opts)

-- keymap("n", "<leader>;;", ":source /Users/vitaly/.config/nvim/init.lua")

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
-- manipulate windows
-- vim.keymap.set("n", "<leader>w", "<C-w>")


vim.keymap.set("n", "<leader>b", function() vim.lsp.buf.definition() end, opts)
-- vim.keymap.set("n", "<leader>b", "<Plug>(coc-definition)", opts)
-- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
vim.keymap.set("n", "<leader>ge", function() vim.diagnostic.goto_next() end, opts)
vim.keymap.set("n", "<leader>gee", function() vim.diagnostic.goto_next() end, opts)
vim.keymap.set("n", "<leader>gep", function() vim.diagnostic.goto_prev() end, opts)
vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
vim.keymap.set("n", "<leader>fu", function() vim.lsp.buf.references() end, opts)
-- vim.keymap.set("n", "<leader>rv", function() vim.lsp.buf.rename() end, opts)
vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
-- vim.keymap.set("n", "gd", function() vim.fn.CocAction('jumpDefinition') end, opts)
-- vim.keymap.set("n", "<leader>b", function() vim.fn.CocAction('jumpDefinition') end, opts)
-- vim.keymap.set("n", "<leader>vd", function() vim.fn.CocActionAsync('doHover') end, opts)
-- vim.keymap.set("n", "<leader>ge", function() vim.fn.CocAction('diagnosticNext') end, opts)
-- vim.keymap.set("n", "<leader>gee", function() vim.fn.CocAction('diagnosticNext') end, opts)
-- vim.keymap.set("n", "<leader>gep", function() vim.fn.CocAction('diagnosticPrevious') end, opts)
-- vim.keymap.set("n", "<leader>vca", function() vim.fn.CocAction('codeAction') end, opts)
-- vim.keymap.set("n", "<leader>fu", function() vim.fn.CocAction('jumpReferences') end, opts)
-- vim.keymap.set("n", "<leader>rv", function() vim.fn.CocAction('rename') end, opts)
-- vim.keymap.set("n", "<leader>ll", function() vim.cmd("CocCommand editor.action.formatDocument") end, opts)
-- vim.keymap.set("i", "<C-h>", function() vim.fn.CocActionAsync('showSignatureHelp') end, opts)

-- local conform = require("conform")
-- vim.keymap.set("n", "<leader>ll", function() conform.format() end, opts);
vim.keymap.set("n", "<leader>ll", function() vim.lsp.buf.format() end, opts);

local function toggle_quickfix()
  local quickfix_open = false

  -- Check if quickfix is open by looking at all windows
  for _, win in pairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      quickfix_open = true
      break
    end
  end

  if quickfix_open then
    vim.cmd('cclose')
  else
    vim.cmd('copen')
  end
end

vim.keymap.set('n', '<leader>qq', toggle_quickfix, { desc = 'Toggle quickfix list' })
vim.keymap.set('n', '<leader>qn', ":cn<cr>", opts)
vim.keymap.set('n', '<leader>qp', ":cp<cr>", opts)
vim.keymap.set('n', '<leader>qf', ":cf<cr>", opts)
vim.keymap.set('n', '<leader>ql', ":cl<cr>", opts)

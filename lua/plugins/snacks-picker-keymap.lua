local snacks = require('snacks')
local function picker_with_selection(picker_func, opts)
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

    local merged_opts = vim.tbl_extend('force', opts or {}, { search = selected_text })
    picker_func(merged_opts)
  end
end

local opts = { silent = true }

-- Snacks picker visual mode mappings with selected text
vim.keymap.set('v', '<leader>wo', picker_with_selection(function(o) snacks.picker.files(o) end), opts)
vim.keymap.set('v', '<leader>ff', picker_with_selection(function(o) snacks.picker.grep(o) end), opts)
vim.keymap.set('v', '<leader>fb', picker_with_selection(function(o) snacks.picker.buffers(o) end), opts)
vim.keymap.set('v', '<leader>wb', picker_with_selection(function(o) snacks.picker.buffers(o) end), opts)
vim.keymap.set('v', '<leader>hh', picker_with_selection(function(o) snacks.picker.lsp_symbols(o) end), opts)

-- Snacks picker mappings
vim.keymap.set('n', '<leader>wo', function() snacks.picker.files() end, opts)
vim.keymap.set('n', '<leader>ff', function() snacks.picker.grep() end, opts)
vim.keymap.set('n', '<leader>fb', function() snacks.picker.buffers() end, opts)
vim.keymap.set('n', '<leader>wb', function() snacks.picker.buffers() end, opts)
vim.keymap.set('n', '<leader>hh', function() snacks.picker.lsp_symbols() end, opts)

vim.keymap.set("n", "<leader>b", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client.server_capabilities.implementationProvider then
      snacks.picker.lsp_implementations()
      return
    end
  end
  snacks.picker.lsp_definitions()
end, opts)

vim.keymap.set("n", "<leader>fu", function() snacks.picker.lsp_references() end, opts)
vim.keymap.set("n", "<leader>ac", function() snacks.picker.commands() end, opts)
vim.keymap.set("n", "<leader>ah", function() snacks.picker.command_history() end, opts)
vim.keymap.set("n", "<leader>fh", function() snacks.picker.search_history() end, opts)
vim.keymap.set("n", "<leader>fb", function() snacks.picker.git_branches() end, opts)
vim.keymap.set("n", "<leader>gc", function() snacks.picker.git_log() end, opts)
vim.keymap.set("n", "<leader>gbc", function() snacks.picker.git_log_file() end, opts)
vim.keymap.set("v", "<leader>gbl", function() snacks.picker.git_log_line() end, opts)

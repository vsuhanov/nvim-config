local telescope_builtin = require('telescope.builtin')
local telescope = require('telescope')
telescope.setup {
  defaults = {
    path_dispay = { 'smart' },
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-h>"] = "which_key"
      }
    }
  },
  pickers = {
    find_files = {
      find_command = {
        "fd",
        "--type", "f",
        "--hidden",
        "--follow",
        "--exclude", "target",       -- Maven build dir
        "--exclude", "build",        -- Gradle build dir
        "--exclude", ".gradle",      -- Gradle cache
        "--exclude", "node_modules", -- If you have JS tooling
        "--exclude", ".git",
        "--exclude", "*.class",      -- Compiled Java files
      },
    },
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}
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
local opts = { silent = true }
-- Telescope visual mode mappings with selected text
vim.keymap.set('v', '<leader>wo', telescope_with_selection(telescope_builtin.find_files), opts)
vim.keymap.set('v', '<leader>ff', telescope_with_selection(require('plugins.telescope-live-multigrep').live_multigrep),
  opts)
vim.keymap.set('v', '<leader>fb', telescope_with_selection(telescope_builtin.buffers), opts)
vim.keymap.set('v', '<leader>wb', telescope_with_selection(telescope_builtin.buffers), opts)
vim.keymap.set('v', '<leader>hh', telescope_with_selection(telescope_builtin.treesitter), opts)

-- Telescope mappings
vim.keymap.set('n', '<leader>wo', ':Telescope find_files<CR>', opts)
vim.keymap.set('n', '<leader>ff', function() require('plugins.telescope-live-multigrep').live_multigrep() end, opts)
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', opts)
vim.keymap.set('n', '<leader>wb', ':Telescope buffers<CR>', opts)
vim.keymap.set('n', '<leader>hh', ':Telescope treesitter<CR>', opts)

vim.keymap.set("n", "<leader>b", function()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client.server_capabilities.implementationProvider then
      telescope_builtin.lsp_implementations()
      return
    end
  end
  telescope_builtin.lsp_definitions()
end, opts)
vim.keymap.set("n", "<leader>fu", function() telescope_builtin.lsp_references() end, opts)
vim.keymap.set("n", "<leader>ac", function() telescope_builtin.commands() end, opts)
vim.keymap.set("n", "<leader>ah", function() telescope_builtin.command_history() end, opts)
vim.keymap.set("n", "<leader>fh", function() telescope_builtin.search_history() end, opts)
vim.keymap.set("n", "<leader>fb", function() telescope_builtin.git_branches() end, opts)
vim.keymap.set("n", "<leader>gc", function() telescope_builtin.git_commits() end, opts)
vim.keymap.set("n", "<leader>gbc", function() telescope_builtin.git_bcommits() end, opts)
vim.keymap.set("v", "<leader>gbl", function() telescope_builtin.git_bcommits_range() end, opts)


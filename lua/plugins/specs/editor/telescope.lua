local picker_config = { fname_width = 60, path_display = { shorten = { len = 3, exclude = { 2, -1 } } } }

local function telescope_with_selection(telescope_func)
  return function()
    -- Save current register
    local save_reg = vim.fn.getreg('t')
    local save_regtype = vim.fn.getregtype('t')


    -- Yank selected text to unnamed register
    vim.cmd('normal! "ty')

    -- Get the yanked text
    local selected_text = vim.fn.getreg('t')

    -- Restore register
    vim.fn.setreg('"', save_reg, save_regtype)

    telescope_func({ default_text = selected_text })
  end
end

vim.api.nvim_create_user_command('TelescopeLazy', function()
  require('telescope_builtin').find_files({
    cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy")
  })
end, { desc = "search through installed plugins" }
)

return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.4",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>wo", function() require('telescope.builtin').find_files() end, desc = "Find files", mode = "n" },
    { "<leader>wo", function() telescope_with_selection(function(opts) require('telescope.builtin').find_files(opts) end)() end, desc = "Find files", mode = "v" },
    { "<leader>ff", function() require('plugins.config.telescope-live-multigrep').live_multigrep() end, desc = "Live grep", mode = { "n", "t" } },
    { "<leader>ff", function() telescope_with_selection(function(opts) require('plugins.config.telescope-live-multigrep').live_multigrep(opts) end)() end, desc = "Live grep", mode = "v" },
    { "<leader>wb", function() require('telescope.builtin').buffers() end,                              desc = "Buffers" },
    { "<leader>wr", function() require('telescope.builtin').resume() end,                               desc = "Resume" },
    { "<leader>w]", function() require('telescope.builtin').jumplist() end,                             desc = "Jumplist" },
    { "<leader>hh", function() require('telescope.builtin').treesitter() end, desc = "Treesitter", mode = "n" },
    { "<leader>hh", function() telescope_with_selection(function(opts) require('telescope.builtin').treesitter(opts) end)() end, desc = "Treesitter", mode = "v" },
    { "<leader>b",  function() require('telescope.builtin').lsp_definitions() end,                      desc = "LSP definitions" },
    {
      "<leader>B",
      function()
        vim.cmd('vs'); require('telescope.builtin').lsp_definitions()
      end,
      desc = "LSP def split"
    },
    { "<leader>fu",  function() require('telescope.builtin').lsp_references() end,     desc = "LSP references" },
    { "<leader>ac",  function() require('telescope.builtin').commands() end,           desc = "Commands" },
    { "<leader>ah",  function() require('telescope.builtin').command_history() end,    desc = "Command history" },
    { "<leader>fh",  function() require('telescope.builtin').search_history() end,     desc = "Search history" },
    { "<leader>fb",  function() require('telescope.builtin').git_branches() end,       desc = "Git branches" },
    { "<leader>gc",  function() require('telescope.builtin').git_commits() end,        desc = "Git commits" },
    { "<leader>gbc", function() require('telescope.builtin').git_bcommits() end,       desc = "Buffer commits" },
    { "<leader>gbl", function() require('telescope.builtin').git_bcommits_range() end, desc = "Commits range", mode = "n" },
    { "<leader>gbl", function() telescope_with_selection(function(opts) require('telescope.builtin').git_bcommits_range(opts) end)() end, desc = "Commits range", mode = "v" },
  },
  cmd = { "Telescope", "TelescopeLazy" },
  opts = {
    defaults = {
      path_dispay = { shorten = { len = 3, exclude = { 2, -1 } } },
      dynamic_preview_title = true,
      -- Default configuration for telescope goes here:
      -- config_key = value,
      mappings = {
        i = {
          -- map actions.which_key to <C-h> (default: <C-/>)
          -- actions.which_key shows the mappings for your picker,
          -- e.g. git_{create, delete, ...}_branch for the git_branches picker
          ["<C-h>"] = "which_key",
          ["<C-k>"] = require('telescope.actions').cycle_history_prev,
          ["<C-j>"] = require('telescope.actions').cycle_history_next,
          ["<C-q>"] = require('telescope.actions').send_to_loclist + require('telescope.actions').open_loclist,
          ["<M-q>"] = require('telescope.actions').send_selected_to_loclist + require('telescope.actions').open_loclist,
          ["<C-Q>"] = require('telescope.actions').send_to_qflist + require('telescope.actions').open_qflist,
          ["<M-Q>"] = require('telescope.actions').send_selected_to_qflist + require('telescope.actions').open_qflist,
        },
        n = {
          ["<C-q>"] = require('telescope.actions').send_to_loclist + require('telescope.actions').open_loclist,
          ["<M-q>"] = require('telescope.actions').send_selected_to_loclist + require('telescope.actions').open_loclist,
          ["<C-Q>"] = require('telescope.actions').send_to_qflist + require('telescope.actions').open_qflist,
          ["<M-Q>"] = require('telescope.actions').send_selected_to_qflist + require('telescope.actions').open_qflist,
        },
      }
    },
    pickers = {
      lsp_references      = picker_config,
      lsp_definitions     = picker_config,
      lsp_implementations = picker_config,
      jumplist            = picker_config,
      find_files          = {
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
}

return {
  -- dir = "/Users/vitaly/projects/swiftpick.nvim",
  "vsuhanov/swiftpick.nvim",
  name = "swiftpick",
  keys = {
    -- global bookmarks
    { "<leader>ag", function() require("swiftpick.actions").add({ filename = vim.api.nvim_buf_get_name(0), use_global_context = true, prompt_for_label = false }) end,  desc = "SwiftPick add to global" },
    { "<leader>aG", function() require("swiftpick.actions").add({ filename = vim.api.nvim_buf_get_name(0), use_global_context = true, prompt_for_label = true }) end,   desc = "SwiftPick add to global with label" },
    -- { "<leader>eg", function() require("swiftpick.actions").open_picker({ use_global_context = true }) end,                                                              desc = "SwiftPick open global picker" },
    { "<leader>eg", function() require("swiftpick.actions").open_telescope_picker({ use_global_context = true }) end,                                                   desc = "SwiftPick open global telescope picker" },
    -- local bookmarks
    { "<leader>al", function() require("swiftpick.actions").add({ filename = vim.api.nvim_buf_get_name(0), use_global_context = false, prompt_for_label = false }) end, desc = "SwiftPick add to local" },
    { "<leader>aa", function() require("swiftpick.actions").add({ filename = vim.api.nvim_buf_get_name(0), use_global_context = false, prompt_for_label = false }) end, desc = "SwiftPick add to local" },
    { "<leader>aL", function() require("swiftpick.actions").add({ filename = vim.api.nvim_buf_get_name(0), use_global_context = false, prompt_for_label = true }) end,  desc = "SwiftPick add to local with label" },
    -- { "<leader>el", function() require("swiftpick.actions").open_picker({ use_global_context = false }) end,                                                             desc = "SwiftPick open local picker" },
    -- { "<leader>ee", function() require("swiftpick.actions").open_picker({ use_global_context = false }) end,                                                             desc = "SwiftPick open local picker" },
    { "<leader>el", function() require("swiftpick.actions").open_telescope_picker({ use_global_context = false }) end,                                                  desc = "SwiftPick open local telescope picker" },
    { "<leader>ee", function() require("swiftpick.actions").open_telescope_picker({ use_global_context = false }) end,                                                  desc = "SwiftPick open local telescope picker" },
  },
  config = function()
    require("swiftpick").setup({
          use_global_context_by_default = true,
    })
  end
}

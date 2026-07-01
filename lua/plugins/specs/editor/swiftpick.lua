return {
  -- dir = "/Users/vitaly/projects/swiftpick.nvim",
  "vsuhanov/swiftpick.nvim",
  name = "swiftpick",
  keys = {
    { "<leader>aa", function() require("swiftpick.actions").add({ filename = vim.api.nvim_buf_get_name(0) }) end, desc = "SwiftPick add file" },
    { "<leader>ee",  function() require("swiftpick.actions").open_picker() end,                                    desc = "SwiftPick open picker" },
  },
  config = function()
    require("swiftpick").setup()
  end
}

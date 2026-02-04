return {
  "otavioschwanck/telescope-alternate",
  dependencies = { "nvim-telescope/telescope.nvim" },
  keys = {
    { "<leader>gt", function() require('telescope-alternate').alternate_file() end, desc = "Alternate file" },
  },
  config = function()
    require('plugins.config.telescope-alternate')
  end
}

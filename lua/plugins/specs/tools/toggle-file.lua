return {
  "vsuhanov/toggle-file.nvim",
  keys = {
    { "<leader>1", function() require('toggle-file').toggle_file_window("~/Daily Notes.md") end, desc = "Toggle daily notes" },
    { "<leader>2", function() require('toggle-file').toggle_file_window(require('toggle-file').get_remembered_file()) end, desc = "Toggle remembered file" },
  },
  -- this needs fixing in the plugin
  config = function()
    require('plugins.config.toggle-file')
  end
}

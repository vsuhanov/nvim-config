return {
  "vsuhanov/harpoon",
  branch = "harpoon2",
  keys = {
    { "<leader>aa", function()
        local harpoon = require('plugins.config.harpoon')
        harpoon.add_to_current_list()
      end, desc = "Harpoon add" },
    { "<leader>ee", function()
        local harpoon = require('plugins.config.harpoon')
        harpoon.toggle_quick_menu()
      end, desc = "Harpoon menu" },
    { "<leader>al", function()
        local harpoon = require('plugins.config.harpoon')
        harpoon.toggle_lists_menu()
      end, desc = "Harpoon lists add" },
    { "<leader>ea", function()
        local harpoon = require('plugins.config.harpoon')
        harpoon.toggle_lists_menu()
      end, desc = "Harpoon toggle lists" },
  },
  cmd = { "HarpoonLists", "HarpoonSwitchTo", "HarpoonCurrentList", "HarpoonCreateList", "HarpoonShowLog" },
  config = function()
    require('plugins.config.harpoon')
  end
}

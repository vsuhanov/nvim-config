return {
  "vsuhanov/quick-definition.nvim",
  keys = {
    { "K", function() require('quick-definition').quick_definition() end, desc = "Quick definition" },
    { "<2-LeftMouse>", function() require('quick-definition').quick_definition() end, desc = "Quick definition" },
  },
}

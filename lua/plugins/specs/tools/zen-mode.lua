return {
  "folke/zen-mode.nvim",
  keys = {
    {
      "<leader>z",
      function()
        require("zen-mode").toggle({
          window = {
            backdrop = 1,
            width = 180,
          }
        })
      end,
      desc = "Toggle zen mode"
    },
  },
}

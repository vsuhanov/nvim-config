return {
  "vsuhanov/region-highlight.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>hl", ":RegionHighlightClear<CR>", desc = "Clear region highlight" },
    { "<leader>hl", ":RegionHighlight<CR>", mode = "v", desc = "Region highlight" },
  },
}

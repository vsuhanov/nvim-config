return {
  "rest-nvim/rest.nvim",
  -- Its build needs luarocks (and Lua 5.1); skip on machines without it
  cond = vim.fn.executable('luarocks') == 1,
  ft = "http",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
}

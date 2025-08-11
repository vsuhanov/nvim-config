require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "eslint_d", "prettierd", "prettier", stop_after_first = true },
  }
})


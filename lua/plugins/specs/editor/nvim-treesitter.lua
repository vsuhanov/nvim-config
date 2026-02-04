return {
  "nvim-treesitter/nvim-treesitter",
  event = "BufEnter",
  config = function()
    require 'nvim-treesitter.configs'.setup {
      ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "arduino",
        "markdown",
        "markdown_inline",
        "java",
        "groovy",
        "html",
        "css",
        "javascript",
        "typescript",
        "luadoc",
      },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = "v",
          node_decremental = "V",
        },
      },
    }
  end
}

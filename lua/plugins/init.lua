local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins.specs.core" },
    { import = "plugins.specs.editor" },
    { import = "plugins.specs.lsp" },
    { import = "plugins.specs.git" },
    { import = "plugins.specs.tools" },
    { import = "plugins.specs.dap" },
    { import = "plugins.specs.database" },
    { import = "plugins.specs.misc" },
  },
  defaults = {
    lazy = false,
  },
  ui = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

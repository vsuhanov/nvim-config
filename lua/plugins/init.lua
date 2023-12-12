local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "tpope/vim-sensible",
  { "nvim-treesitter/nvim-treesitter", cmd = 'TSUpdate' },
  "nvim-lua/plenary.nvim",
  { "nvim-telescope/telescope.nvim",   tag = '0.1.4' },
  { "neoclide/coc.nvim",               branch = 'release' },
  "tpope/vim-fugitive",
  "rmagatti/auto-session",
  "mattn/emmet-vim",
  "vim-airline/vim-airline",
  "rafamadriz/friendly-snippets",
  "lewis6991/gitsigns.nvim",
  "tpope/vim-commentary",
  "stevearc/oil.nvim",
  "github/copilot.vim",
  "jiangmiao/auto-pairs",
  { "ThePrimeagen/harpoon", branch = 'harpoon2' },
  "doums/darcula",
  "robitx/gp.nvim",
  "mattn/emmet-vim",
})
require('plugins.gp')
require('plugins.auto-session')
require('plugins.harpoon')
require('plugins.oil')
require('plugins.treesitter')

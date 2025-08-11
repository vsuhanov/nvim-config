local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "tpope/vim-sensible",
  "tpope/vim-fugitive",
  "tpope/vim-commentary",
  "tpope/vim-surround",
  { "nvim-treesitter/nvim-treesitter", cmd = "TSUpdate" },
  "nvim-lua/plenary.nvim",
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
  },
  -- { "neoclide/coc.nvim",               branch = 'release' },
  "rmagatti/auto-session",
  -- "mattn/emmet-vim",
  -- "vim-airline/vim-airline",
  -- "vim-airline/vim-airline-themes",
  "itchyny/lightline.vim",
  -- "rafamadriz/friendly-snippets",
  "lewis6991/gitsigns.nvim",
  -- "stevearc/oil.nvim",
  {
    "stevearc/conform.nvim",
    opts = {},
  },
  -- "github/copilot.vim",
  -- "jiangmiao/auto-pairs",
  { "ThePrimeagen/harpoon",            branch = "harpoon2" },
  -- "doums/darcula",
  -- "robitx/gp.nvim",
  -- "mattn/emmet-vim",
  -- { 'rose-pine/neovim',  name = 'rose-pine' },
  { "EdenEast/nightfox.nvim" },
  -- "ggandor/leap.nvim",
  -- "mbbill/undotree",
  { "williamboman/mason.nvim" },
  -- "nvim-treesitter/playground",
  -- { "neoclide/coc.nvim", branch = "release" },
  -- {
  --   'VonHeikemen/lsp-zero.nvim',
  --   branch = 'v1.x',
  --   dependencies = {
  --     -- LSP Support
  --     { 'neovim/nvim-lspconfig' },
  --     { 'williamboman/mason.nvim' },
  --     { 'williamboman/mason-lspconfig.nvim' },
  --
  --     -- Autocompletion
  --     { 'hrsh7th/nvim-cmp' },
  --     { 'hrsh7th/cmp-buffer' },
  --     { 'hrsh7th/cmp-path' },
  --     { 'saadparwaiz1/cmp_luasnip' },
  --     { 'hrsh7th/cmp-nvim-lsp' },
  --     { 'hrsh7th/cmp-nvim-lua' },
  --
  --     -- Snippets
  --     { 'L3MON4D3/LuaSnip' },
  --     { 'rafamadriz/friendly-snippets' },
  --   }
  -- },
  {
    -- dir = '/Users/vitaly/projects/quick-definition.nvim'
    "vsuhanov/quick-definition.nvim",
  },
  "vsuhanov/toggle-file.nvim",
  -- 'mfussenegger/nvim-jdtls',
  -- 'mustache/vim-mustache-handlebars',
  -- 'OrangeT/vim-csharp',
  -- {
  --   'vsuhanov/omnisharp-extended-lsp.nvim',
  -- dir = '/Users/vitaly/projects/omnisharp-extended-lsp.nvim'
  -- },
  -- 'mfussenegger/nvim-dap',
  -- 'leoluz/nvim-dap-go',
  -- 'sindrets/diffview.nvim',
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  {
    "Hajime-Suzuki/vuffers.nvim",
  },
  {
    "yorickpeterse/nvim-window",
  }
  -- "neovim/nvim-lspconfig",
})
-- require('plugins.gp')
require('plugins.auto-session')
require("plugins.harpoon")
-- require('plugins.oil')
require("plugins.treesitter")
require("plugins.gitsigns")
-- require('plugins.leap')
require("plugins.mason")
-- require('plugins.lsp-zero')
require("plugins.quick-definition")
-- require('plugins.nvim-jdtls')
-- require('plugins.nvim-dap')
-- require('plugins.nvim-dap-go')
require("plugins.nvim-tree")
require("plugins.vuffers")
require("plugins.nvim-window")
-- require("plugins.conform")

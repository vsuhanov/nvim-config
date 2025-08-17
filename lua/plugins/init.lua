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
  { "nvim-telescope/telescope.nvim",   tag = "0.1.4", },
  -- "rmagatti/auto-session",
  'nvim-lualine/lualine.nvim',
  "lewis6991/gitsigns.nvim",
  { "ThePrimeagen/harpoon",   branch = "harpoon2" },
  "EdenEast/nightfox.nvim",
  { "williamboman/mason.nvim" },
  {
    -- dir = '/Users/vitaly/projects/quick-definition.nvim'
    "vsuhanov/quick-definition.nvim",
  },
  "vsuhanov/toggle-file.nvim",
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  {
    -- dir = '/Users/vitaly/projects/vuffers.nvim'
    "suhanovs/vuffers.nvim",
  },
  "yorickpeterse/nvim-window",
  "f-person/auto-dark-mode.nvim",
  {
    "LintaoAmons/scratch.nvim",
    event = "VeryLazy",
  },
  "folke/snacks.nvim",
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
  },
  {
    "smjonas/inc-rename.nvim",
    opts = {}
  },
  {
    "rest-nvim/rest.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "http")
      end,
    }
  },
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',
  'Tastyep/structlog.nvim',
  -- "neovim/nvim-lspconfig",
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
  -- { "neoclide/coc.nvim",               branch = 'release' },
  -- "mattn/emmet-vim",
  -- "vim-airline/vim-airline",
  -- "vim-airline/vim-airline-themes",
  -- "itchyny/lightline.vim",
  -- "rafamadriz/friendly-snippets",
  -- "stevearc/oil.nvim",
  -- {
  --   "stevearc/conform.nvim",
  --   opts = {},
  -- },
  -- "github/copilot.vim",
  -- "jiangmiao/auto-pairs",
  -- "doums/darcula",
  -- "robitx/gp.nvim",
  -- "mattn/emmet-vim",
  -- { 'rose-pine/neovim',  name = 'rose-pine' },
  -- "ggandor/leap.nvim",
  -- "mbbill/undotree",
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

})
-- require('plugins.gp')
-- require('plugins.oil')
-- require('plugins.leap')
-- require('plugins.lsp-zero')
-- require('plugins.nvim-jdtls')
-- require('plugins.nvim-dap')
-- require('plugins.nvim-dap-go')
-- require("plugins.conform")
-- require('plugins.auto-session')
require("plugins.harpoon")
require("plugins.treesitter")
require("plugins.gitsigns")
require("plugins.mason")
require("plugins.quick-definition")
require("plugins.nvim-tree")
require("plugins.vuffers")
require("plugins.nvim-window")
require("plugins.lualine")
require("plugins.auto-dark-mode")
require("plugins.scratch")
require("plugins.snacks")
require("plugins.inc-rename")
require("plugins.noice")
require("plugins.nvim-cmp")
require("plugins.git-fugitive")


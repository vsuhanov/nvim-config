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
  { "tpope/vim-fugitive",        config = function() require('plugins.git-fugitive') end },
  "tpope/vim-commentary",
  "tpope/vim-surround",
  {
    "nvim-treesitter/nvim-treesitter",
    cmd = "TSUpdate",
    config = function()
      require('plugins.treesitter')
    end
  },
  "nvim-lua/plenary.nvim",
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    config = function()
      require(
        'plugins.telescope')
    end
  },
  -- "rmagatti/auto-session",
  { 'nvim-lualine/lualine.nvim', config = function() require('plugins.lualine') end },
  { "lewis6991/gitsigns.nvim",   config = function() require('plugins.gitsigns') end },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
      require('plugins.harpoon')
    end
  },
  "EdenEast/nightfox.nvim",
  { "williamboman/mason.nvim",   config = function() require('plugins.mason') end },
  {
    -- dir = '/Users/vitaly/projects/quick-definition.nvim'
    "vsuhanov/quick-definition.nvim",
    config = function() require('plugins.quick-definition') end
  },
  { "vsuhanov/toggle-file.nvim", config = function() require('plugins.quick-definition') end },
  { "nvim-tree/nvim-tree.lua",   config = function() require('plugins.nvim-tree') end },
  "nvim-tree/nvim-web-devicons",
  {
    -- dir = '/Users/vitaly/projects/vuffers.nvim'
    "vsuhanov/vuffers.nvim",
    config = function() require('plugins.vuffers') end
  },
  { "yorickpeterse/nvim-window",    config = function() require('plugins.nvim-window') end },
  { "f-person/auto-dark-mode.nvim", config = function() require('plugins.auto-dark-mode') end },
  {
    "vsuhanov/scratch.nvim",
    event = "VeryLazy",
    config = function() require('plugins.scratch') end
  },
  { "folke/snacks.nvim", config = function() require('plugins.snacks') end },
  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     -- add any options here
  --   },
  --   dependencies = {,
  --     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
  --     "MunifTanjim/nui.nvim",
  --     -- OPTIONAL:
  --     --   `nvim-notify` is only needed, if you want to use the notification view.
  --     --   If not available, we use `mini` as the fallback
  --     "rcarriga/nvim-notify",
  --   },
  -- },
  {
    "smjonas/inc-rename.nvim",
    config = function() require('plugins.inc-rename') end
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
  { 'hrsh7th/nvim-cmp',  config = function() require('plugins.nvim-cmp') end },
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',
  'Tastyep/structlog.nvim',
  { 'MisanthropicBit/winmove.nvim', config = function() require('plugins.winmove') end },
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

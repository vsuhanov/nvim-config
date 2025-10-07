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
  "tpope/vim-dadbod",
  'kristijanhusak/vim-dadbod-ui',
  'kristijanhusak/vim-dadbod-completion',
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
    enabled = false,
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    config = function()
      require('plugins.telescope')
    end
  },
  -- "rmagatti/auto-session",
  { 'nvim-lualine/lualine.nvim', config = function() require('plugins.lualine') end },
  { "lewis6991/gitsigns.nvim",   config = function() require('plugins.gitsigns') end },
  {
    -- "vsuhanov/harpoon",
    dir = '/Users/vitaly/projects/harpoon',
    branch = "harpoon2",
    config = function()
      require('plugins.harpoon')
    end
  },
  "EdenEast/nightfox.nvim",
  { "williamboman/mason.nvim", config = function() require('plugins.mason') end },
  {
    -- dir = '/Users/vitaly/projects/quick-definition.nvim',
    "vsuhanov/quick-definition.nvim",
    config = function() require('plugins.quick-definition') end
  },
  {
    -- dir = '/Users/vitaly/projects/vuffers.nvim'
    "vsuhanov/vuffers.nvim",
    config = function() require('plugins.vuffers') end
  },
  {
    -- dir = '/Users/vitaly/projects/toggle-file.nvim',
    "vsuhanov/toggle-file.nvim",
    config = function() require('plugins.toggle-file') end
  },
  { "nvim-tree/nvim-tree.lua", config = function() require('plugins.nvim-tree') end },
  "nvim-tree/nvim-web-devicons",
  { "yorickpeterse/nvim-window",    config = function() require('plugins.nvim-window') end },
  { "f-person/auto-dark-mode.nvim", config = function() require('plugins.auto-dark-mode') end },
  {
    -- dir = '/Users/vitaly/projects/scratch.nvim',
    "vsuhanov/scratch.nvim",
    event = "VeryLazy",
    config = function() require('plugins.scratch') end
  },
  {
    "folke/snacks.nvim",
    config = function()
      require('plugins.snacks'); require('plugins.snacks-picker')
    end
  },
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
  -- {
  --   "smjonas/inc-rename.nvim",
  --   config = function() require('plugins.inc-rename') end
  -- },
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
  { 'hrsh7th/nvim-cmp',             config = function() require('plugins.nvim-cmp') end },
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',
  'Tastyep/structlog.nvim',
  { 'MisanthropicBit/winmove.nvim', config = function() require('plugins.winmove') end },
  {
    "linrongbin16/gitlinker.nvim",
    config = function() require('plugins.gitlinker') end,
  },
  'sindrets/diffview.nvim',
  {
    'echasnovski/mini.ai',
    version = '*',
    config = function()
      require(
        'plugins.miniai')
    end
  },
  {
    'skardyy/neo-img',
    build = ":NeoImg Install",
    config = function() require('plugins.neo-img') end
  },
  {
    'aklt/plantuml-syntax'
  },
  {
    'stevearc/oil.nvim',
    config = function() require('plugins.oil') end
  },
  {
    'tzachar/local-highlight.nvim',
    config = function()
      require('plugins.local-highlight')
    end
  },
  -- {
  --   'TobinPalmer/pastify.nvim',
  --   config = function()
  --     require('plugins.pastify')
  --   end
  -- },
})

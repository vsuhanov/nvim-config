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
  -- "tpope/vim-sensible",
  -- { "nvim-treesitter/nvim-treesitter", cmd = 'TSUpdate' },
  -- "nvim-lua/plenary.nvim",
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   tag = '0.1.4',
  -- },
  -- { "neoclide/coc.nvim",               branch = 'release' },
  -- "tpope/vim-fugitive",
  -- "rmagatti/auto-session",
  -- "mattn/emmet-vim",
  -- "vim-airline/vim-airline",
  -- "rafamadriz/friendly-snippets",
  -- "lewis6991/gitsigns.nvim",
  "tpope/vim-commentary",
  -- "stevearc/oil.nvim",
  -- "github/copilot.vim",
  -- "jiangmiao/auto-pairs",
  { "ThePrimeagen/harpoon",            branch = 'harpoon2' },
  -- "doums/darcula",
  -- "robitx/gp.nvim",
  -- "mattn/emmet-vim",
  "tpope/vim-surround",
  -- { 'rose-pine/neovim', name = 'rose-pine' },
  -- "ggandor/leap.nvim",
  -- "mbbill/undotree",
  -- "nvim-treesitter/playground",
  -- {
  --   'VonHeikemen/lsp-zero.nvim',
  --   branch = 'v1.x',
  --   dependencies = {
  --     -- LSP Support
  --     { 'neovim/nvim-lspconfig' },
  --     { 'williamboman/mason.nvim' },
  --     { 'williamboman/mason-lspconfig.nvim' },

  --     -- Autocompletion
  --     { 'hrsh7th/nvim-cmp' },
  --     { 'hrsh7th/cmp-buffer' },
  --     { 'hrsh7th/cmp-path' },
  --     { 'saadparwaiz1/cmp_luasnip' },
  --     { 'hrsh7th/cmp-nvim-lsp' },
  --     { 'hrsh7th/cmp-nvim-lua' },

  --     -- Snippets
  --     { 'L3MON4D3/LuaSnip' },
  --     { 'rafamadriz/friendly-snippets' },
  --   }
  -- },
  -- {
  --   -- dir = '/Users/vitaly/projects/quick-definition.nvim'
  --   'vsuhanov/quick-definition.nvim'
  -- },
  -- 'vsuhanov/toggle-file.nvim',
  -- 'mfussenegger/nvim-jdtls',
  -- 'mustache/vim-mustache-handlebars',
  -- 'OrangeT/vim-csharp',
  -- {
  --   'vsuhanov/omnisharp-extended-lsp.nvim',
  --   -- dir = '/Users/vitaly/projects/omnisharp-extended-lsp.nvim'
  -- },
  {
  'vscode-neovim/vscode-multi-cursor.nvim',
  cond = not not vim.g.vscode,
  opts = {},
}
})
-- require('vscode.plugins.gp')
-- require('vscode.plugins.auto-session')
-- require('vscode.plugins.harpoon')
-- require('vscode.plugins.oil')
-- require('vscode.plugins.treesitter')
-- require('vscode.plugins.gitsigns')
-- require('vscode.plugins.leap')
-- require('vscode.plugins.mason')
-- require('vscode.plugins.lsp-zero')
-- require('vscode.plugins.quick-definition')
-- require('vscode.plugins.nvim-jdtls')

  require('vscode.plugins.vscode-multi-cursor')
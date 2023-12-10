vim.g.mapleader = ' '


require('gitsigns').setup {
  on_attach = function(bufnr)
  end
}

-- require'nvim-treesitter.configs'.setup {
--   ensure_installed = "cpp", -- make sure C++ parser is installed
--   highlight = {
--     enable = true, -- enable highlighting
--   },
--   filetype_to_parser = {
--     arduino = "cpp" -- map arduino filetype to cpp parser
--   }
-- }
--




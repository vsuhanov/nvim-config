require('region-highlight').setup({})


vim.keymap.set('n', '<leader>hl', ':RegionHighlightClear<CR>', { silent = true })
vim.keymap.set('v', '<leader>hl', ':RegionHighlight<CR>', { silent = true })

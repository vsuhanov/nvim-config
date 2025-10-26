-- Configuration using vim.g (recommended approach)
vim.g.telescope_alternate = {
  mappings = {
    {
      '(.*)/(.*)', {
      { '[1]', 'Same Dir' },
    },
    },
  },
  presets = { 'rails', 'rspec', 'nestjs', 'angular' },
  picker = 'telescope',
  open_only_one_with = 'current_pane',
}

vim.keymap.set("n", "<leader>gt", function() require('telescope-alternate').alternate_file() end, { silent = true })

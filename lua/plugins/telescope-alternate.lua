-- Configuration using vim.g (recommended approach)
vim.g.telescope_alternate = {
  mappings = {
    {
      '(.*)/(.*)', {
      { '[1]', 'Same Dir' },
    },
    },
    { '(.*)/(.*?).ts', {
      -- { 'src/[1]/[2].service.ts',    'Service' },
      -- { 'src/[1]/[2].guard.ts',      'Guard' },
      -- { 'src/[1]/[2].module.ts',     'Module' },
      { '[1]/[2].spec.ts', 'Test' },
      -- { 'src/[1]/[2].controller.ts', 'Controller' },
      -- { 'src/[1]/[2].strategy.ts',   'Strategy' },
      -- { 'src/[1]/[2].logger.ts',     'Logger' },
    } }
  },
  presets = { 'rails', 'rspec', 'angular' },
  picker = 'telescope',
  open_only_one_with = 'current_pane',
}

vim.keymap.set("n", "<leader>gt", function() require('telescope-alternate').alternate_file() end, { silent = true })

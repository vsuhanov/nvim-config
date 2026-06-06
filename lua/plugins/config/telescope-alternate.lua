-- Configuration using vim.g (recommended approach)
vim.g.telescope_alternate = {
  mappings = {
    {
      '(.*)/(.*)', {
      { '[1]', 'Same Dir' },
    },
    },
    { '(.*/src/main/java/)(.*/)(.*)%.java', {
      { '[1]src/test/java/[2][3]Test.java', 'Test' },
      { '[1]src/integration-test/java/[2][3]IntegrationTest.java', 'Integration Test' },
    } },
    { '(.*/src/test/java/)(.*/)(.*)Test%.java', {
      { '[1]src/main/java/[2][3].java', 'Main' },
    } },
    { '(.*/src/integration%-test/java/)(.*/)(.*)IntegrationTest%.java', {
      { '[1]src/main/java/[2][3].java', 'Main' },
    } },
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

return {
  'nvim-java/nvim-java',
  -- Needs a JDK on PATH (and unzip to install jdtls); skip on machines without them
  cond = vim.fn.executable('java') == 1 and vim.fn.executable('unzip') == 1,
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('java').setup({
      spring_boot_tools = {
        enable = false,
        version = '1.55.1',
      },
    })
    vim.lsp.enable('jdtls')
  end,
}

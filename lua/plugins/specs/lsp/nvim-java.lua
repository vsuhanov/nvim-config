return {
  'nvim-java/nvim-java',
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

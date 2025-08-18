require("noice").setup({
  cmdline = {
    enabled = false,
    view = "cmdline_popup",
  },
  messages = {
    enabled = false,
  },
  popupmenu = {
    enabled = false,
  },
  notify = {
    enabled = false,
  },
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
      ["vim.lsp.util.stylize_markdown"] = false,
      ["cmp.entry.get_documentation"] = false,
    },
    hover = {
      enabled = false,
    },
    signature = {
      enabled = false,
    },
    message = {
      enabled = false,
    },
  },
  presets = {
    bottom_search = false,
    command_palette = true,
    long_message_to_split = false,
    inc_rename = false,
    lsp_doc_border = false,
  },
})

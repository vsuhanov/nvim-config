-- write file on any change (autosave)
vim.api.nvim_create_autocmd(
  {"InsertLeave", "TextChanged", "FocusLost"},
  {
    pattern = "*",
    command = "silent! update",
  }
)

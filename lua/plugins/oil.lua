require 'oil'.setup {
  default_file_explorer = false,
  columns = {
    "icon",
    "permissions",
    "size",
    "mtime",
  },
  keymaps = {
    ["gy"] = "actions.copy_entry_path",
    ["q"] = "actions.close",
  },
  skip_confirm_for_simple_edits = true,
  -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
  prompt_save_on_select_new_entry = true,
  view_options = {
    show_hidden = true
  },
  float = {
  -- Padding around the floating window
  padding = 2,
  -- max_width and max_height can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
  max_width = 100,
  max_height = 30,
  border = "rounded",
  win_options = {
    winblend = 0,
  },
  -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
  get_win_title = nil,
  -- preview_split: Split direction: "auto", "left", "right", "above", "below".
  preview_split = "auto",
  -- This is the config that will be passed to nvim_open_win.
  -- Change values here to customize the layout
  override = function(conf)
    return conf
  end,
},
}
-- keymap("n", "-", ":e %:h<cr>", opts)
-- local function safe_open_oil()
--   local ok, err = pcall(vim.cmd, 'e ' .. vim.fn.expand('%:h'))
--   if not ok then
--     vim.cmd('e .')
--   end
-- end
--
-- keymap("n", "-", safe_open_oil, opts)

-- keymap("n", "-", ":silent! e %:h | if v:shell_error | echo 'Directory navigation failed' | endif<cr>", opts)
vim.keymap.set("n", "<leader>rf", ":Oil --float <cr>", { silent = true })

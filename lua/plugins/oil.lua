require 'oil'.setup {
	columns = {
		"icon",
		"permissions",
		"size",
		"mtime",
	},
	keymaps = {
		["gy"] = "actions.copy_entry_path",
	},
	skip_confirm_for_simple_edits = true,
	-- Selecting a new/moved/renamed file or directory will prompt you to save changes first
	prompt_save_on_select_new_entry = true,
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


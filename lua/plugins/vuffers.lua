local vuffers = require("vuffers")

-- vim.api.nvim_create_autocmd("SessionLoadPost", {
-- 	callback = function()
-- 		vuffers.on_session_loaded()
-- 	end,
-- })

vuffers.setup({
  debug = {
    enabled = vim.fn.getcwd():find("vuffers") ~= nil,
    level = "debug",       -- "error" | "warn" | "info" | "debug" | "trace"
  },
  exclude = {
    -- do not show them on the vuffers list
    filenames = { "term://" },
    filetypes = { "lazygit", "NvimTree", "qf" },
  },
  handlers = {
    -- when deleting a buffer via vuffers list (by default triggered by "d" key)
    on_delete_buffer = function(bufnr)
      vim.api.nvim_command(":bwipeout " .. bufnr)
    end,
  },
  keymaps = {
    -- if false, no bindings will be provided at all
    -- thus you will have to bind on your own
    use_default = true,
    -- key maps on the vuffers list
    -- - may map multiple keys for the same action
    --    open = { "<CR>", "<C-l>" }
    -- - disable a specific binding using "false"
    --    open = false
    view = {
      open = "<CR>",
      delete = "d",
      pin = "p",
      unpin = "P",
      rename = "r",
      reset_custom_display_name = "R",
      reset_custom_display_names = "<leader>R",
      move_up = "U",
      move_down = "D",
      move_to = "i",
    },
  },
  sort = {
    type = "none",           -- "none" | "filename"
    direction = "asc",       -- "asc" | "desc"
  },
  view = {
    modified_icon = "😬", -- when a buffer is modified, this icon will be shown
    -- pinned_icon = "󰐾",
    pinned_icon = "📌",
    show_file_extension = true,
    window = {
      auto_resize = false,
      width = 35,
      focus_on_open = true,
    },
  },
})
local opts = { silent = true }
vim.keymap.set("n", "<leader>j", function() vuffers.go_to_buffer_by_count({ direction = 'next' }) end, opts)
vim.keymap.set("n", "<leader>k", function() vuffers.go_to_buffer_by_count({ direction = 'prev' }) end, opts)
-- vim.keymap.set("n", "<leader>", function() vuffers.toggle() end, opts)

vim.api.nvim_create_user_command('Tabs', function()
  vuffers.toggle()
end, {})

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vuffers.open()
  end
})


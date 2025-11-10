require 'gitsigns'.setup {
  signs = {
    add          = { text = '█' },
    change       = { text = '█' },
    delete       = { text = '█' },
    topdelete    = { text = '█' },
    changedelete = { text = '█' },
    untracked    = { text = '█' },
  },
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = true, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 10,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  -- yadm = {
  --   enable = false
  -- },
}

vim.api.nvim_create_user_command('GitHunkDiffInline', function()
  vim.cmd("Gitsigns preview_hunk_inline")
end, {desc = "GIT: Show inline diff for current hunk"})

vim.api.nvim_create_user_command('GitHunkDiff', function()
  vim.cmd("Gitsigns preview_hunk")
end, {desc = "GIT: Show floating diff for current hunk"})

vim.api.nvim_create_user_command('Gh', function()
  vim.cmd("Gitsigns stage_hunk")
end, {desc = "GIT: Stage/Unstage current hunk"})

vim.keymap.set({'n'}, '<leader>gh', ':Gh<cr>', {silent = true})
vim.keymap.set({'n'}, ']c', ':Gitsigns next_hunk<cr>', {silent = true})
vim.keymap.set({'n'}, '[c', ':Gitsigns prev_hunk<cr>', {silent = true})
 

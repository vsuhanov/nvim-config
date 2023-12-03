local opts = {
  log_level = 'info',
  auto_session_enable_last_session = false,
  auto_session_root_dir = vim.fn.stdpath('data').."/sessions/",
  auto_session_enabled = true,
  auto_save_enabled = true,
  auto_restore_enabled = true,
  auto_session_suppress_dirs = nil,
  auto_session_use_git_branch = nil,
  -- the configs below are lua only
  bypass_session_save_file_types = nil
}

    
require('auto-session').setup(opts)
require('gitsigns').setup{
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map('n', '<Space>hs', gs.stage_hunk)
    map('n', '<Space>hr', gs.reset_hunk)
    map('v', '<Space>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('v', '<Space>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('n', '<Space>hS', gs.stage_buffer)
    map('n', '<Space>hu', gs.undo_stage_hunk)
    map('n', '<Space>hR', gs.reset_buffer)
    map('n', '<Space>hp', gs.preview_hunk)
    map('n', '<Space>hb', function() gs.blame_line{full=true} end)
    map('n', '<Space>tb', gs.toggle_current_line_blame)
    map('n', '<Space>hd', gs.diffthis)
    map('n', '<Space>hD', function() gs.diffthis('~') end)
    map('n', '<Space>td', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

-- require'nvim-treesitter.configs'.setup {
--   ensure_installed = "cpp", -- make sure C++ parser is installed
--   highlight = {
--     enable = true, -- enable highlighting
--   },
--   filetype_to_parser = {
--     arduino = "cpp" -- map arduino filetype to cpp parser
--   }
-- }

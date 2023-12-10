local opts = {
  log_level = 'info',
  auto_session_enable_last_session = false,
  auto_session_root_dir = vim.fn.stdpath('data') .. "/sessions/",
  auto_session_enabled = true,
  auto_save_enabled = true,
  auto_restore_enabled = true,
  auto_session_suppress_dirs = nil,
  auto_session_use_git_branch = nil,
  -- the configs below are lua only
  bypass_session_save_file_types = nil
}

vim.g.mapleader = ' '
require('auto-session').setup(opts)
require('gitsigns').setup {
  on_attach = function(bufnr)
    -- local gs = package.loaded.gitsigns

    -- local function map(mode, l, r, opts)
    --   opts = opts or {}
    --   opts.buffer = bufnr
    --   vim.keymap.set(mode, l, r, opts)
    -- end

    -- Navigation
    -- map('n', ']c', function()
    --   if vim.wo.diff then return ']c' end
    --   vim.schedule(function() gs.next_hunk() end)
    --   return '<Ignore>'
    -- end, { expr = true })

    -- map('n', '[c', function()
    --   if vim.wo.diff then return '[c' end
    --   vim.schedule(function() gs.prev_hunk() end)
    --   return '<Ignore>'
    -- end, { expr = true })

    -- -- Actions
    -- map('n', '<leader>hs', gs.stage_hunk)
    -- map('n', '<leader>hr', gs.reset_hunk)
    -- map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    -- map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    -- map('n', '<leader>hS', gs.stage_buffer)
    -- map('n', '<leader>hu', gs.undo_stage_hunk)
    -- map('n', '<leader>hR', gs.reset_buffer)
    -- map('n', '<leader>hp', gs.preview_hunk)
    -- map('n', '<leader>hb', function() gs.blame_line { full = true } end)
    -- map('n', '<leader>tb', gs.toggle_current_line_blame)
    -- map('n', '<leader>hd', gs.diffthis)
    -- map('n', '<leader>hD', function() gs.diffthis('~') end)
    -- map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    -- map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
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
--
require("oil").setup({
  columns = {
    "icon",
    "permissions",
    "size",
    "mtime",
  },
})

local harpoon = require("harpoon")
-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>aa", function() harpoon:list():append() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<leader>hu", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>hi", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>ho", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>hp", function() harpoon:list():select(4) end)

require("gp").setup({
 	openai_api_key = os.getenv("OPENAI_API_KEY"),
  cmd_prefix = "Chat",
  agents = {
    {
      name = "ChatGPT4",
      chat = true,
      command = false,
      -- string with model name or table with model name and parameters
      model = { model = "gpt-4-1106-preview", temperature = 1.1, top_p = 1 },
      -- system prompt (use this to specify the persona/role of the AI)
      system_prompt = "You are a general AI assistant.\n\n"
          .. "The user provided the additional info about how they would like you to respond:\n\n"
          .. "- If you're unsure don't guess and say you don't know instead.\n"
          .. "- Ask question if you need clarification to provide better answer.\n"
          -- .. "- Think deeply and carefully from first principles step by step.\n"
          -- .. "- Zoom out first to see the big picture and then zoom in to details.\n"
          .. "- Use Socratic method to improve your thinking and coding skills.\n"
          .. "- Don't elide any code from your output if the answer requires coding.\n"
          .. "- Take a deep breath; You've got this!\n",
    },
    {
      name = "ChatGPT4Analytical",
      chat = true,
      command = false,
      -- string with model name or table with model name and parameters
      model = { model = "gpt-4-1106-preview", temperature = 1.1, top_p = 1 },
      -- system prompt (use this to specify the persona/role of the AI)
      system_prompt = "You are a general AI assistant.\n\n"
          .. "The user provided the additional info about how they would like you to respond:\n\n"
          .. "- If you're unsure don't guess and say you don't know instead.\n"
          .. "- Ask question if you need clarification to provide better answer.\n"
          .. "- Think deeply and carefully from first principles step by step.\n"
          .. "- Zoom out first to see the big picture and then zoom in to details.\n"
          .. "- Use Socratic method to improve your thinking and coding skills.\n"
          .. "- Don't elide any code from your output if the answer requires coding.\n"
          .. "- Take a deep breath; You've got this!\n",
    },
    {
      name = "ChatGPT3-5",
      chat = true,
      command = false,
      -- string with model name or table with model name and parameters
      model = { model = "gpt-3.5-turbo-1106", temperature = 1.1, top_p = 1 },
      -- system prompt (use this to specify the persona/role of the AI)
      system_prompt = "You are a general AI assistant.\n\n"
          .. "The user provided the additional info about how they would like you to respond:\n\n"
          .. "- If you're unsure don't guess and say you don't know instead.\n"
          .. "- Ask question if you need clarification to provide better answer.\n"
          .. "- Think deeply and carefully from first principles step by step.\n"
          .. "- Zoom out first to see the big picture and then zoom in to details.\n"
          .. "- Use Socratic method to improve your thinking and coding skills.\n"
          .. "- Don't elide any code from your output if the answer requires coding.\n"
          .. "- Take a deep breath; You've got this!\n",
    },
    {
      name = "CodeGPT4",
      chat = false,
      command = true,
      -- string with model name or table with model name and parameters
      model = { model = "gpt-4-1106-preview", temperature = 0.8, top_p = 1 },
      -- system prompt (use this to specify the persona/role of the AI)
      system_prompt = "You are an AI working as a code editor.\n\n"
          .. "Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n"
          .. "START AND END YOUR ANSWER WITH:\n\n```",
    },
    {
      name = "CodeGPT3-5",
      chat = false,
      command = true,
      -- string with model name or table with model name and parameters
      model = { model = "gpt-3.5-turbo-1106", temperature = 0.8, top_p = 1 },
      -- system prompt (use this to specify the persona/role of the AI)
      system_prompt = "You are an AI working as a code editor.\n\n"
          .. "Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n"
          .. "START AND END YOUR ANSWER WITH:\n\n```",
    },
  }
});

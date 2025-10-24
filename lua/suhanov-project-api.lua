local M = {}

local EMOJIS = {
  "🍎", "🍊", "🍋", "🍌", "🍇", "🍓",
  "⭐", "✨", "🌟", "💫", "⚡",
  "🟥", "🟧", "🟨", "🟩", "🟦", "🟪",
  "🎯", "🎪", "🎨",
}

M.set_terminal_title = function(title)
  local escape_seq = string.format("\027]0;%s\007", title)
  io.write(escape_seq)
  io.flush()
end

M.set_default_terminal_title = function()
  local cwd = vim.fn.getcwd()

  -- Calculate hash from cwd
  local hash = 0
  for i = 1, #cwd do
    hash = (hash + string.byte(cwd, i)) % (#EMOJIS)
  end
  hash = hash + 1 -- Convert to 1-based index

  local emoji = EMOJIS[hash]

  -- Extract parent and current directory names
  local current_dir = vim.fn.fnamemodify(cwd, ":t")
  local parent_dir = vim.fn.fnamemodify(vim.fn.fnamemodify(cwd, ":h"), ":t")

  -- Format the title
  local title = string.format("%s %s/%s", emoji, parent_dir, current_dir)
  M.set_terminal_title(title)
end

return M

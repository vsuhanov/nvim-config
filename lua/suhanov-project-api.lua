local M = {}

local current_title = nil

local EMOJIS = {
  "🍎", "🍊", "🍋", "🍌", "🍇", "🍓",
  "⭐", "✨", "🌟", "💫", "⚡",
  "🟥", "🟧", "🟨", "🟩", "🟦", "🟪",
  "🎯", "🎪", "🎨",
}

M.set_terminal_title = function(title)
  current_title = title
  local escape_seq = string.format("\027]0;%s\007", title)
  io.write(escape_seq)
  io.flush()
end

M.edit_terminal_title = function()
  local ok, Input = pcall(require, "nui.input")
  if not ok then
    vim.ui.input({ prompt = "Terminal title: ", default = current_title or "" }, function(input)
      if input ~= nil then
        M.set_terminal_title(input)
      end
    end)
    return
  end

  local input = Input({
    position = "50%",
    size = { width = 60 },
    border = {
      style = "rounded",
      text = { top = " Terminal Title ", top_align = "center" },
    },
  }, {
    default_value = current_title or "",
    on_submit = function(value)
      M.set_terminal_title(value)
    end,
  })

  input:mount()
end

local function emoji_for(path)
  local hash = 0
  for i = 1, #path do
    hash = (hash + string.byte(path, i)) % (#EMOJIS)
  end
  return EMOJIS[hash + 1]
end

local function prettify(name)
  return (name:gsub("[-_]+", " "):gsub("%f[%w]%l", string.upper))
end

local function git_title(cwd, root)
  local parent = vim.fn.fnamemodify(root, ":h")
  local name = vim.fn.fnamemodify(root, ":t")
  local title = string.format("%s%s %s", emoji_for(parent), emoji_for(root), prettify(name))
  if cwd ~= root then
    title = string.format("%s / %s", title, vim.fn.fnamemodify(cwd, ":t"))
  end
  return title
end

M.set_default_terminal_title = function()
  local cwd = vim.fs.normalize(vim.fn.getcwd())

  local root = vim.fs.root(cwd, ".git")
  if root then
    M.set_terminal_title(git_title(cwd, vim.fs.normalize(root)))
    return
  end

  -- Calculate hash from cwd
  local emoji = emoji_for(cwd)

  -- Extract parent and current directory names
  local current_dir = vim.fn.fnamemodify(cwd, ":t")
  local parent_dir = vim.fn.fnamemodify(vim.fn.fnamemodify(cwd, ":h"), ":t")

  -- Format the title
  local title = string.format("%s %s/%s", emoji, parent_dir, current_dir)
  M.set_terminal_title(title)
end

return M

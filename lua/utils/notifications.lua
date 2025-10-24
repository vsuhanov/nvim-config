-- Notification utilities for macOS
-- Sends system notifications using available tools

local M = {}

--- Send a macOS notification
--- @param message string The notification message
--- @param title string? Optional title (defaults to "Neovim")
function M.notify(message, title)
  title = title or "Neovim"

  -- Try different notification methods in order of preference
  local cmd

  if vim.fn.executable("terminal-notifier") == 1 then
    cmd = string.format(
      'terminal-notifier -message "%s" -title "%s" -sound default',
      message:gsub('"', '\\"'),
      title:gsub('"', '\\"')
    )
  elseif vim.fn.executable("alerter") == 1 then
    cmd = string.format(
      'alerter -message "%s" -title "%s" -sound default',
      message:gsub('"', '\\"'),
      title:gsub('"', '\\"')
    )
  else
    -- Fallback to osascript
    cmd = string.format(
      'osascript -e \'display notification "%s" with title "%s" sound name "default"\'',
      message:gsub('"', '\\"'),
      title:gsub('"', '\\"')
    )
  end

  -- Also play system sound
  vim.fn.system(cmd)
  vim.fn.system("afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true")
end

return M

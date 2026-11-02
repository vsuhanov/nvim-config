-- Notification utilities
-- Sends system notifications using available tools (macOS and Linux)

local M = {}

local function escape_quotes(s)
  return (s:gsub('"', '\\"'))
end

--- Send a desktop notification
--- @param message string The notification message
--- @param title string? Optional title (defaults to "Neovim")
function M.notify(message, title)
  title = title or "Neovim"

  if vim.fn.has('mac') == 1 then
    -- Try different notification methods in order of preference
    local cmd

    if vim.fn.executable("terminal-notifier") == 1 then
      cmd = string.format(
        'terminal-notifier -message "%s" -title "%s" -sound default',
        escape_quotes(message),
        escape_quotes(title)
      )
    elseif vim.fn.executable("alerter") == 1 then
      cmd = string.format(
        'alerter -message "%s" -title "%s" -sound default',
        escape_quotes(message),
        escape_quotes(title)
      )
    else
      -- Fallback to osascript
      cmd = string.format(
        'osascript -e \'display notification "%s" with title "%s" sound name "default"\'',
        escape_quotes(message),
        escape_quotes(title)
      )
    end

    vim.fn.system(cmd)
    vim.fn.system("afplay /System/Library/Sounds/Glass.aiff 2>/dev/null || true")
  elseif vim.fn.executable("notify-send") == 1 then
    -- Linux: libnotify (needs a desktop session; silently does nothing on a headless box)
    vim.fn.jobstart({ "notify-send", title, message }, { detach = true })
  end
end

return M

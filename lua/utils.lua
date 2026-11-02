local M = {}

M.is_mac = vim.fn.has('mac') == 1

-- Open a file/URL with the OS default handler (detached so nvim doesn't block)
M.open_external = function(target)
  local bin = M.is_mac and 'open' or 'xdg-open'
  if vim.fn.executable(bin) == 0 then
    vim.notify(bin .. ' not found; install xdg-utils to open links here', vim.log.levels.WARN)
    return
  end
  vim.fn.jobstart({ bin, target }, { detach = true })
end

-- Reveal a path in the file manager (Finder on macOS, folder on Linux)
M.reveal_in_file_manager = function(path)
  if M.is_mac then
    vim.fn.system({ 'open', '-R', path })
  else
    M.open_external(vim.fn.fnamemodify(path, ':h'))
  end
end

M.open_in_idea = function(file_path)
  if M.is_mac then
    vim.fn.system('open -a "IntelliJ IDEA.app" "' .. file_path .. '"')
  elseif vim.fn.executable('idea') == 1 then
    vim.fn.jobstart({ 'idea', file_path }, { detach = true })
  else
    vim.notify('IntelliJ IDEA not found on this machine (no `idea` command)', vim.log.levels.WARN)
  end
end

return M

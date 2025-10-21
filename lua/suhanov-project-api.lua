local M = {}

M.set_terminal_title = function(title)
  local escape_seq = string.format("\027]0;%s\007", title)
  io.write(escape_seq)
  io.flush()
end

return M

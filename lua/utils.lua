local M = {}

M.open_in_idea = function(file_path)
  vim.fn.system('open -a "IntelliJ IDEA.app" "' .. file_path .. '"')
end

return M

local unignored = vim.tbl_map(vim.glob.to_lpeg, {
  ".env*",
})

local function is_unignored(pattern)
  return vim.iter(unignored):any(function(glob) return glob:match(pattern) ~= nil end)
end

local function patterns(cwd)
  local file = io.open(vim.fs.joinpath(cwd, ".gitignore"), "r")
  if not file then return {} end

  local result = {}
  for line in file:lines() do
    local pattern = vim.trim(line)
    if pattern ~= "" and not pattern:match("^#") and not pattern:match("^!") then
      pattern = pattern:gsub("^/", ""):gsub("/$", "")
      if not is_unignored(pattern) then
        table.insert(result, pattern)
      end
    end
  end
  file:close()
  return result
end

return {
  patterns = patterns,
}

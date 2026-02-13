-- Define a Lua function that renders tab numbers

-- Small helper to trim whitespace (works on all recent Neovim versions)
local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- :SetTabName {name}
-- - Sets a human label for the *current* tab.
-- - Call with no arguments to clear the name.
vim.api.nvim_create_user_command("SetTabName", function(opts)
  local tab = vim.api.nvim_get_current_tabpage()
  local name = trim(opts.args or "")
  if name == "" then
    -- Clear the custom name (if it exists)
    pcall(vim.api.nvim_tabpage_del_var, tab, "tab_name")
  else
    vim.api.nvim_tabpage_set_var(tab, "tab_name", name)
  end
  -- Update the tabline immediately
  vim.cmd.redrawtabline()
end, { nargs = "*" })

-- Define a Lua function that renders tab numbers + optional names
function _G.Tabline()
  local s = ""
  local current = vim.fn.tabpagenr()
  local tabs = vim.api.nvim_list_tabpages()  -- actual tab handles

  for i, tab in ipairs(tabs) do
    -- Click target for mouse users: %iT
    s = s .. "%" .. i .. "T"
    if i == current then
      s = s .. "%#TabLineSel#"   -- highlight for selected tab
    else
      s = s .. "%#TabLine#"
    end

    -- Try to read the custom tab name from the tabpage variable
    local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, "tab_name")
    if ok and type(name) == "string" and name ~= "" then
      s = s .. " " .. i .. " " .. name .. " "
    else
      s = s .. " " .. i .. " "     -- <-- only the tab NUMBER
    end
  end

  s = s .. "%#TabLineFill#%T"     -- filler + end click target
  return s
end

-- Attach the function to 'tabline'
vim.o.tabline = "%!v:lua.Tabline()"

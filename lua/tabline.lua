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
    pcall(vim.api.nvim_tabpage_del_var, tab, "tab_name")
  else
    vim.api.nvim_tabpage_set_var(tab, "tab_name", name)
  end
  vim.cmd.redrawtabline()
end, { nargs = "*" })

function _G.Tabline()
  local s = ""
  local current = vim.fn.tabpagenr()
  local tabs = vim.api.nvim_list_tabpages()

  for i, tab in ipairs(tabs) do
    s = s .. "%" .. i .. "T"
    if i == current then
      s = s .. "%#TabLineSel#"
    else
      s = s .. "%#TabLine#"
    end


    local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, "tab_name")
    if ok and type(name) == "string" and name ~= "" then
      s = s .. " " .. i .. " " .. name .. " "
    else
      local wins = vim.api.nvim_tabpage_list_wins(tab)
      local buf_name = ""

      if #wins > 0 then
        local buf = vim.api.nvim_win_get_buf(wins[1])

        if vim.bo[buf].buftype == "terminal" then
          buf_name = "term"
        else
          local full_path = vim.api.nvim_buf_get_name(buf)
          buf_name = vim.fn.fnamemodify(full_path, ":t")
        end
      end

      if buf_name ~= "" then
        s = s .. " " .. i .. " " .. buf_name .. " "
      else
        s = s .. " " .. i .. " "
      end
    end
  end

  s = s .. "%#TabLineFill#%T"
  return s
end

vim.o.tabline = "%!v:lua.Tabline()"

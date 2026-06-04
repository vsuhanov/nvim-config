local M = {}

local store_path = vim.fn.stdpath("data") .. "/project-config.json"
local store = {}

do
  local ok, content = pcall(vim.fn.readfile, store_path)
  if ok and #content > 0 then
    local dok, data = pcall(vim.fn.json_decode, table.concat(content, "\n"))
    if dok and type(data) == "table" then store = data end
  end
end

local function get_entry()
  return store[vim.fn.getcwd()] or {}
end

function M.get_color() return get_entry().color end
function M.get_title() return get_entry().title end

function M.set_entry(key, value)
  local cwd = vim.fn.getcwd()
  if not store[cwd] then store[cwd] = {} end
  store[cwd][key] = value
end

function M.save()
  vim.fn.writefile({ vim.fn.json_encode(store) }, store_path)
end

local function apply_color(color)
  require('iterm-utils').set_tab_color(color)
  vim.api.nvim_set_hl(0, 'WinBar', { bg = color, fg = '#FFFFFF' })
end

local function nui_input(title, default, on_submit)
  local ok, Input = pcall(require, "nui.input")
  if not ok then
    vim.ui.input({ prompt = title .. ": ", default = default or "" }, function(v)
      if v ~= nil then on_submit(v) end
    end)
    return
  end
  local input = Input({
    position = "50%",
    size = { width = 60 },
    border = { style = "rounded", text = { top = " " .. title .. " ", top_align = "center" } },
  }, {
    default_value = default or "",
    on_submit = on_submit,
  })
  input:mount()
end

vim.api.nvim_create_user_command("EditTerminalTitle", function()
  nui_input("Terminal Title", M.get_title(), function(value)
    require('suhanov-project-api').set_terminal_title(value)
    M.set_entry('title', value)
    M.save()
  end)
end, {})

vim.api.nvim_create_user_command("SetTerminalTitle", function(opts)
  local value = opts.args
  require('suhanov-project-api').set_terminal_title(value)
  M.set_entry('title', value)
  M.save()
end, { nargs = 1 })

local PALETTE = {
  { hex = '#9B59B6', label = 'Purple'  },
  { hex = '#3498DB', label = 'Blue'    },
  { hex = '#1ABC9C', label = 'Teal'    },
  { hex = '#2ECC71', label = 'Green'   },
  { hex = '#F39C12', label = 'Orange'  },
  { hex = '#E74C3C', label = 'Red'     },
  { hex = '#E91E63', label = 'Pink'    },
  { hex = '#FFC107', label = 'Amber'   },
}

vim.api.nvim_create_user_command("SetProjectColor", function()
  local ok, Menu = pcall(require, "nui.menu")
  if not ok then
    nui_input("Project Color (#rrggbb)", M.get_color(), function(value)
      if not value:match("^#%x%x%x%x%x%x$") then
        vim.notify("Invalid color format. Use #rrggbb", vim.log.levels.ERROR)
        return
      end
      apply_color(value)
      M.set_entry('color', value)
      M.save()
    end)
    return
  end

  local NuiText = require("nui.text")
  local NuiLine = require("nui.line")

  for i, entry in ipairs(PALETTE) do
    vim.api.nvim_set_hl(0, "ProjectColorSwatch" .. i, { bg = entry.hex, fg = "#FFFFFF" })
  end

  local lines = {}
  for i, entry in ipairs(PALETTE) do
    lines[i] = Menu.item(
      NuiLine({ NuiText("  ", "ProjectColorSwatch" .. i), NuiText(" " .. entry.label) }),
      { color = entry.hex }
    )
  end
  lines[#lines + 1] = Menu.item(NuiLine({ NuiText("  ✏ Custom value…") }), { color = "__custom__" })

  local menu = Menu({
    position = "50%",
    size = { width = 28 },
    border = { style = "rounded", text = { top = " Project Color ", top_align = "center" } },
  }, {
    lines = lines,
    on_submit = function(item)
      if item.color == "__custom__" then
        nui_input("Project Color (#rrggbb)", M.get_color(), function(value)
          if not value:match("^#%x%x%x%x%x%x$") then
            vim.notify("Invalid color format. Use #rrggbb", vim.log.levels.ERROR)
            return
          end
          apply_color(value)
          M.set_entry('color', value)
          M.save()
        end)
      else
        apply_color(item.color)
        M.set_entry('color', item.color)
        M.save()
      end
    end,
  })
  menu:mount()
end, {})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local title = M.get_title()
    if title then
      require('suhanov-project-api').set_terminal_title(title)
    else
      require('suhanov-project-api').set_default_terminal_title()
    end

    local color = M.get_color()
    if color then apply_color(color) end
  end,
})

return M

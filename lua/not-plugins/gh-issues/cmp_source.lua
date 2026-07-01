local cache = require("not-plugins.gh-issues.cache")
local view = require("not-plugins.gh-issues.view")

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:get_debug_name()
  return "gh_issues"
end

function source:get_trigger_characters()
  return { ",", " " }
end

local function current_field()
  local buf = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(buf)
  if not bufname:match("^gh%-issue://") then return nil end
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  return view.field_at_row(buf, row), buf
end

function source:is_available()
  return current_field() ~= nil
end

function source:complete(params, callback)
  local field, buf = current_field()
  if not field then
    callback({ items = {}, isIncomplete = false })
    return
  end

  local lsp_kinds = require("cmp.types").lsp.CompletionItemKind
  local field_kinds = {
    state = lsp_kinds.EnumMember,
    labels = lsp_kinds.Enum,
    assignees = lsp_kinds.Reference,
  }

  local items = {}
  if field == "state" then
    items = { "open", "closed" }
  else
    local st = view.get_state(buf)
    if st then
      cache.ensure_fresh_meta(st.repo)
      if field == "labels" then
        items = cache.labels(st.repo)
      else
        items = cache.assignees(st.repo)
      end
    end
  end

  local before = params.context.cursor_before_line
  local start_char = 0
  for i = #before, 1, -1 do
    if before:sub(i, i) == "," then
      start_char = i
      break
    end
  end
  while start_char < #before and before:sub(start_char + 1, start_char + 1) == " " do
    start_char = start_char + 1
  end

  local row = params.context.cursor.row - 1
  local cursor_char = params.context.cursor.col - 1

  local out = {}
  for _, name in ipairs(items) do
    table.insert(out, {
      label = name,
      filterText = name,
      kind = field_kinds[field],
      textEdit = {
        newText = name,
        range = {
          start = { line = row, character = start_char },
          ["end"] = { line = row, character = cursor_char },
        },
      },
    })
  end

  callback({ items = out, isIncomplete = false })
end

return source

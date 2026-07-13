local ns = vim.api.nvim_create_namespace("block_hl")
local enabled = true

local filetypes = { "lua", "javascript", "javascriptreact", "typescript", "typescriptreact", "java" }

local ts_like_query = [[
(if_statement) @block.if
(else_clause) @block.else
(for_statement) @block.loop
(for_in_statement) @block.loop
(while_statement) @block.loop
(do_statement) @block.loop
((call_expression
  function: (member_expression property: (property_identifier) @_method)
  arguments: (arguments (_ body: (statement_block)))
  (#any-of? @_method "forEach" "map" "filter" "flatMap" "reduce" "reduceRight" "some" "every" "find" "findIndex" "findLast")) @block.loop)
(function_declaration) @block.func
(method_definition) @block.func
]]

local queries = {
  lua = [[
(if_statement) @block.if
(elseif_statement) @block.if
(else_statement) @block.else
(for_statement) @block.loop
(while_statement) @block.loop
(repeat_statement) @block.loop
(function_declaration) @block.func
]],
  javascript = ts_like_query,
  typescript = ts_like_query,
  tsx = ts_like_query,
  java = [[
(if_statement) @block.if
(if_statement alternative: (block) @block.else)
(for_statement) @block.loop
(enhanced_for_statement) @block.loop
(while_statement) @block.loop
(do_statement) @block.loop
((method_invocation
  name: (identifier) @_method
  arguments: (argument_list (lambda_expression body: (block)))
  (#any-of? @_method "forEach" "forEachOrdered" "map" "filter" "flatMap" "peek")) @block.loop)
(method_declaration) @block.func
(constructor_declaration) @block.func
]],
}

local colors = {
  dark = {
    if_bg = "#1c2f3a",
    else_bg = "#38321d",
    loop_bg = { "#22284a", "#2a3260", "#333d76", "#3d488c" },
  },
  light = {
    if_bg = "#e9f4fa",
    else_bg = "#fcf5da",
    loop_bg = { "#e9ebfd", "#dcdffb", "#ced3f9", "#c0c7f6" },
  },
}

local function shade(hex, delta)
  local function ch(i)
    return math.min(255, math.max(0, tonumber(hex:sub(i, i + 1), 16) + delta))
  end
  return string.format("#%02x%02x%02x", ch(2), ch(4), ch(6))
end

local function normal_bg()
  local hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  if hl.bg then
    return string.format("#%06x", hl.bg)
  end
  return vim.o.background == "light" and "#f5f5f5" or "#1a1a1a"
end

local function define_hl()
  local light = vim.o.background == "light"
  local c = light and colors.light or colors.dark
  local delta = light and -7 or 8
  local function set(name, bg)
    vim.api.nvim_set_hl(0, name, { bg = bg })
    vim.api.nvim_set_hl(0, name .. "Alt", { bg = shade(bg, delta) })
  end
  set("BlockHlIf", c.if_bg)
  set("BlockHlElse", c.else_bg)
  for i, bg in ipairs(c.loop_bg) do
    set("BlockHlLoop" .. i, bg)
  end
  set("BlockHlFunc", shade(normal_bg(), light and -6 or 7))
end

local parsed = {}
local function get_query(lang)
  if parsed[lang] == nil then
    if queries[lang] then
      local ok, q = pcall(vim.treesitter.query.parse, lang, queries[lang])
      parsed[lang] = ok and q or false
    else
      parsed[lang] = false
    end
  end
  return parsed[lang] or nil
end

local function contains(a, b)
  if a == b then
    return false
  end
  local starts = a.sr < b.sr or (a.sr == b.sr and a.sc <= b.sc)
  local ends = a.er > b.er or (a.er == b.er and a.ec >= b.ec)
  return starts and ends
end

local function refresh(bufnr)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  if not enabled then
    return
  end
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return
  end
  local query = get_query(parser:lang())
  if not query then
    return
  end
  local trees = parser:parse()
  if not trees or not trees[1] then
    return
  end
  local root = trees[1]:root()

  local marks = {}
  for id, node in query:iter_captures(root, bufnr) do
    local name = query.captures[id]
    if name ~= "_method" then
      local sr, sc, er, ec = node:range()
      if node:type() == "else_statement" then
        local parent = node:parent()
        if parent then
          local _, _, per, pec = parent:range()
          er, ec = per, pec
        end
      end
      if name == "block.func" then
        sc = 0
        local last_line = vim.api.nvim_buf_get_lines(bufnr, er, er + 1, false)[1]
        if last_line then
          ec = #last_line
        end
      end
      table.insert(marks, { name = name, sr = sr, sc = sc, er = er, ec = ec })
    end
  end

  for _, m in ipairs(marks) do
    m.depth = 0
    m.loop_depth = 0
    for _, other in ipairs(marks) do
      if contains(other, m) then
        m.depth = m.depth + 1
        if m.name == "block.loop" and other.name == "block.loop" then
          m.loop_depth = m.loop_depth + 1
        end
      end
    end
  end

  table.sort(marks, function(a, b)
    if a.sr ~= b.sr then
      return a.sr < b.sr
    end
    return a.sc < b.sc
  end)

  local alt_counts = {}
  for _, m in ipairs(marks) do
    local group
    if m.name == "block.if" then
      group = "BlockHlIf"
    elseif m.name == "block.else" then
      group = "BlockHlElse"
    elseif m.name == "block.func" then
      group = "BlockHlFunc"
    else
      group = "BlockHlLoop" .. math.min(m.loop_depth + 1, 4)
    end
    local n = (alt_counts[group] or 0)
    alt_counts[group] = n + 1
    if n % 2 == 1 then
      group = group .. "Alt"
    end
    pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, m.sr, m.sc, {
      end_row = m.er,
      end_col = m.ec,
      hl_group = group,
      hl_eol = true,
      priority = 10 + m.depth,
    })
  end
end

local pending = {}
local function schedule(bufnr)
  if pending[bufnr] then
    return
  end
  pending[bufnr] = true
  vim.defer_fn(function()
    pending[bufnr] = nil
    refresh(bufnr)
  end, 200)
end

define_hl()

local group = vim.api.nvim_create_augroup("BlockHl", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = filetypes,
  callback = function(ev)
    schedule(ev.buf)
  end,
})

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave", "BufEnter" }, {
  group = group,
  callback = function(ev)
    if vim.tbl_contains(filetypes, vim.bo[ev.buf].filetype) then
      schedule(ev.buf)
    end
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = define_hl,
})

vim.api.nvim_create_user_command("BlockHlToggle", function()
  enabled = not enabled
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.tbl_contains(filetypes, vim.bo[buf].filetype) then
      refresh(buf)
    end
  end
end, {})

for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(buf) and vim.tbl_contains(filetypes, vim.bo[buf].filetype) then
    schedule(buf)
  end
end

return { refresh = refresh }

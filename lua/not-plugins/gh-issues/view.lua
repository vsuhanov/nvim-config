local api = require("not-plugins.gh-issues.api")
local cache = require("not-plugins.gh-issues.cache")

local M = {}

local ns = vim.api.nvim_create_namespace("gh_issues")

local state = {}

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function split_csv(s)
  local out = {}
  for _, part in ipairs(vim.split(s or "", ",", { plain = true })) do
    local v = trim(part)
    if v ~= "" then
      table.insert(out, v)
    end
  end
  return out
end

local mark_opts = { right_gravity = false, invalidate = true, undo_restore = true }

local function place_mark(buf, row, opts)
  local o = vim.tbl_extend("force", {}, mark_opts, opts or {})
  return vim.api.nvim_buf_set_extmark(buf, ns, row, 0, o)
end

function M.render(buf, repo, issue, comments)
  local label_names = {}
  if type(issue.labels) == "table" then
    for _, l in ipairs(issue.labels) do
      table.insert(label_names, type(l) == "table" and l.name or l)
    end
  end
  local assignee_logins = {}
  if type(issue.assignees) == "table" then
    for _, a in ipairs(issue.assignees) do
      table.insert(assignee_logins, type(a) == "table" and a.login or a)
    end
  end

  local body = (type(issue.body) == "string") and issue.body or ""
  local desc_lines = vim.split(body, "\n", { plain = true })
  if #desc_lines == 0 then desc_lines = { "" } end

  local lines = {
    issue.title or "",
    issue.state or "",
    table.concat(label_names, ", "),
    table.concat(assignee_logins, ", "),
    "",
  }

  local desc_row = #lines
  vim.list_extend(lines, desc_lines)
  table.insert(lines, "")

  local comment_sections = {}
  if type(comments) == "table" then
    for _, c in ipairs(comments) do
      local cbody = (type(c.body) == "string") and c.body or ""
      local clines = vim.split(cbody, "\n", { plain = true })
      if #clines == 0 then clines = { "" } end
      table.insert(comment_sections, {
        id = c.id,
        author = (type(c.user) == "table" and c.user.login or ""),
        date = c.created_at or "",
        row = #lines,
      })
      vim.list_extend(lines, clines)
      table.insert(lines, "")
    end
  end

  local new_comment_row = #lines
  table.insert(lines, "")

  local comments_row = #comment_sections > 0 and comment_sections[1].row or new_comment_row

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local undolevels = vim.bo[buf].undolevels
  vim.bo[buf].undolevels = -1
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].undolevels = undolevels

  local meta_virt_lines = {
    { { "⭕ Meta", "Title" } },
    { { "number: " .. tostring(issue.number or ""), "Comment" } },
    { { "author: " .. (type(issue.user) == "table" and issue.user.login or ""), "Comment" } },
    { { "created_at: " .. (issue.created_at or ""), "Comment" } },
    { { "updated_at: " .. (issue.updated_at or ""), "Comment" } },
    { { "repo: " .. repo, "Comment" } },
    { { "url: " .. (issue.html_url or ""), "Comment" } },
  }

  local marks = {}
  marks.title = place_mark(buf, 0, {
    virt_text = { { "title: ", "Identifier" } },
    virt_text_pos = "inline",
    virt_lines = meta_virt_lines,
    virt_lines_above = true,
  })
  marks.state = place_mark(buf, 1, {
    virt_text = { { "state: ", "Identifier" } },
    virt_text_pos = "inline",
  })
  marks.labels = place_mark(buf, 2, {
    virt_text = { { "labels: ", "Identifier" } },
    virt_text_pos = "inline",
  })
  marks.assignees = place_mark(buf, 3, {
    virt_text = { { "assignees: ", "Identifier" } },
    virt_text_pos = "inline",
  })
  marks.desc_start = place_mark(buf, desc_row, {
    virt_lines = { { { "⭕ Description", "Title" } } },
    virt_lines_above = true,
  })
  marks.comments_start = place_mark(buf, comments_row, {
    virt_lines = { { { "⭕ Comments", "Title" } } },
    virt_lines_above = true,
  })
  marks.comment_headers = {}
  for _, c in ipairs(comment_sections) do
    table.insert(marks.comment_headers, place_mark(buf, c.row, {
      virt_lines = { { { "💬 comment [id " .. tostring(c.id) .. "]  @" .. c.author .. "  " .. c.date, "Comment" } } },
      virt_lines_above = true,
    }))
  end
  marks.new_comment = place_mark(buf, new_comment_row, {
    virt_lines = { { { "💬 new comment", "Title" } } },
    virt_lines_above = true,
  })

  state[buf] = {
    repo = repo,
    number = tostring(issue.number),
    updated_at = issue.updated_at,
    url = issue.html_url,
    marks = marks,
    original = {
      title = issue.title or "",
      state = issue.state or "",
      labels = label_names,
      assignees = assignee_logins,
      body = body,
    },
  }

  vim.bo[buf].buftype = ""
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modified = false

  vim.keymap.set("n", "<M-o>", M.open_in_browser, { buffer = buf, desc = "Open issue in browser" })
end

function M.open_in_browser()
  local st = state[vim.api.nvim_get_current_buf()]
  if not st then
    vim.notify("Not a gh-issue buffer", vim.log.levels.ERROR)
    return
  end
  local url = st.url
  if not url or url == "" then
    url = "https://github.com/" .. st.repo .. "/issues/" .. st.number
  end
  vim.ui.open(url)
end

function M.get_state(buf)
  return state[buf]
end

local function mark_row(buf, id)
  local m = vim.api.nvim_buf_get_extmark_by_id(buf, ns, id, { details = true })
  if not m or #m == 0 then return nil end
  if m[3] and m[3].invalid then return nil end
  return m[1]
end

function M.field_at_row(buf, row)
  local st = state[buf]
  if not st then return nil end
  for _, name in ipairs({ "state", "labels", "assignees" }) do
    if mark_row(buf, st.marks[name]) == row then
      return name
    end
  end
  return nil
end

function M.parse(buf)
  local st = state[buf]
  if not st then
    return nil, "no gh-issues state for this buffer; run :GHIssueReload"
  end

  local fields = {}
  local skipped = {}
  local rows_seen = {}
  for _, name in ipairs({ "title", "state", "labels", "assignees" }) do
    local row = mark_row(buf, st.marks[name])
    if not row then
      table.insert(skipped, name)
    elseif rows_seen[row] then
      return nil, "meta field lines were joined; save aborted. Run :GHIssueReload"
    else
      rows_seen[row] = true
      fields[name] = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
    end
  end

  local desc_row = mark_row(buf, st.marks.desc_start)
  local comments_row = mark_row(buf, st.marks.comments_start)
  local new_comment_row = mark_row(buf, st.marks.new_comment)
  if not desc_row or not comments_row or not new_comment_row
      or desc_row > comments_row or comments_row > new_comment_row then
    return nil, "section markers are invalid; save aborted. Run :GHIssueReload"
  end

  local desc_lines = vim.api.nvim_buf_get_lines(buf, desc_row, comments_row, false)
  local description = trim(table.concat(desc_lines, "\n"))

  local nc_lines = vim.api.nvim_buf_get_lines(buf, new_comment_row, -1, false)
  local new_comment = trim(table.concat(nc_lines, "\n"))

  return {
    fields = fields,
    skipped = skipped,
    description = description,
    new_comment = new_comment,
  }
end

local function setup_cmp()
  local ok, cmp = pcall(require, "cmp")
  if ok then
    cmp.setup.buffer({
      sources = {
        { name = "gh_issues" },
        {
          name = "buffer",
          entry_filter = function(_, ctx)
            return M.field_at_row(ctx.bufnr, ctx.cursor.row - 1) == nil
          end,
        },
      },
    })
  end
end

function M.open_issue_buffer(repo, issue, comments)
  local number = tostring(issue.number)
  local bufname = "gh-issue://" .. repo .. "/" .. number

  local existing = vim.fn.bufnr(bufname)
  local buf
  if existing ~= -1 then
    buf = existing
    vim.api.nvim_set_current_buf(buf)
  else
    vim.cmd("enew")
    buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, bufname)
  end

  M.render(buf, repo, issue, comments or {})
  setup_cmp()
  cache.ensure_fresh_meta(repo)
end

local function reload_buffer(buf, repo, number, on_done)
  api.gh_api_async("/repos/" .. repo .. "/issues/" .. number, function(fok, fresh_issue)
    if not fok or not fresh_issue then
      if on_done then on_done(false) end
      return
    end
    api.gh_api_async("/repos/" .. repo .. "/issues/" .. number .. "/comments", function(cok, fresh_comments)
      if not vim.api.nvim_buf_is_valid(buf) then return end
      local fresh_cmts = (cok and type(fresh_comments) == "table") and fresh_comments or {}
      M.render(buf, repo, fresh_issue, fresh_cmts)
      cache.upsert_issue(repo, fresh_issue)
      if on_done then on_done(true) end
    end)
  end)
end

local function show_conflict(ev, repo, number, current_issue)
  vim.bo[ev.buf].modifiable = false
  local conflict_name = "gh-issue://" .. repo .. "/" .. number .. "@conflict"
  vim.api.nvim_buf_set_name(ev.buf, conflict_name)

  api.gh_api_async("/repos/" .. repo .. "/issues/" .. number .. "/comments", function(cok, fresh_comments)
    local fresh_cmts = (cok and type(fresh_comments) == "table") and fresh_comments or {}

    vim.cmd("vsplit")
    vim.cmd("enew")
    local new_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(new_buf, "gh-issue://" .. repo .. "/" .. number)

    M.render(new_buf, repo, current_issue, fresh_cmts)
    setup_cmp()

    vim.cmd("diffthis")
    vim.cmd("wincmd h")
    vim.cmd("diffthis")

    vim.notify("Issue updated externally. Your edits (left, read-only) vs server state (right).")
  end)
end

local function save_buffer(ev)
  local st = state[ev.buf]
  if not st then
    vim.notify("No gh-issues state for this buffer. Run :GHIssueReload", vim.log.levels.ERROR)
    return
  end
  local repo, number = st.repo, st.number

  local parsed, perr = M.parse(ev.buf)
  if not parsed then
    vim.notify(perr, vim.log.levels.ERROR)
    return
  end

  api.gh_api_async("/repos/" .. repo .. "/issues/" .. number, function(ok, current_issue)
    if not ok or not current_issue then
      vim.notify("Failed to fetch current issue state", vim.log.levels.ERROR)
      return
    end

    if current_issue.updated_at ~= st.updated_at then
      show_conflict(ev, repo, number, current_issue)
      return
    end

    local payload = {}

    if parsed.fields.title then
      local title = trim(parsed.fields.title)
      if title == "" then
        vim.notify("Title cannot be empty; save aborted", vim.log.levels.ERROR)
        return
      end
      if title ~= st.original.title then
        payload.title = title
      end
    end

    if parsed.fields.state then
      local issue_state = trim(parsed.fields.state)
      if issue_state ~= st.original.state then
        if issue_state ~= "open" and issue_state ~= "closed" then
          vim.notify("Invalid state '" .. issue_state .. "' (must be open or closed); save aborted", vim.log.levels.ERROR)
          return
        end
        payload.state = issue_state
      end
    end

    if parsed.fields.labels then
      local labels = split_csv(parsed.fields.labels)
      if not vim.deep_equal(labels, st.original.labels) then
        payload.labels = labels
      end
    end

    if parsed.fields.assignees then
      local assignees = split_csv(parsed.fields.assignees)
      if not vim.deep_equal(assignees, st.original.assignees) then
        local known = {}
        for _, login in ipairs(cache.assignees(repo)) do
          known[login] = true
        end
        if next(known) then
          local unknown = {}
          for _, login in ipairs(assignees) do
            if not known[login] then
              table.insert(unknown, login)
            end
          end
          if #unknown > 0 then
            vim.notify("Assignees not found in cache: " .. table.concat(unknown, ", "), vim.log.levels.WARN)
          end
        end
        payload.assignees = assignees
      end
    end

    if parsed.description ~= st.original.body and parsed.description ~= trim(st.original.body) then
      payload.body = parsed.description
    end

    if #parsed.skipped > 0 then
      vim.notify("Skipped fields with deleted lines: " .. table.concat(parsed.skipped, ", "), vim.log.levels.WARN)
    end

    if next(payload) then
      local result = api.gh_api("PATCH", "/repos/" .. repo .. "/issues/" .. number, payload)
      if not result then
        vim.notify("Failed to update issue", vim.log.levels.ERROR)
        return
      end
    end

    if parsed.new_comment ~= "" then
      local result = api.gh_api("POST", "/repos/" .. repo .. "/issues/" .. number .. "/comments", { body = parsed.new_comment })
      if not result then
        vim.notify("Failed to post comment", vim.log.levels.ERROR)
      end
    end

    if not next(payload) and parsed.new_comment == "" then
      vim.bo[ev.buf].modified = false
      vim.notify("No changes to save")
      return
    end

    reload_buffer(ev.buf, repo, number, function(rok)
      if rok then
        vim.notify("Issue saved")
      else
        vim.notify("Saved but failed to reload", vim.log.levels.WARN)
        vim.bo[ev.buf].modified = false
      end
    end)
  end)
end

local group = vim.api.nvim_create_augroup("gh_issues_view", { clear = true })

vim.api.nvim_create_autocmd("BufWriteCmd", {
  group = group,
  pattern = "gh-issue://*",
  callback = save_buffer,
})

vim.api.nvim_create_autocmd("BufWipeout", {
  group = group,
  pattern = "gh-issue://*",
  callback = function(ev)
    state[ev.buf] = nil
  end,
})

vim.api.nvim_create_user_command("GHIssueOpen", M.open_in_browser, {})

vim.api.nvim_create_user_command("GHIssueReload", function()
  local buf = vim.api.nvim_get_current_buf()
  local st = state[buf]
  local repo, number
  if st then
    repo, number = st.repo, st.number
  else
    local bufname = vim.api.nvim_buf_get_name(buf)
    repo, number = bufname:match("^gh%-issue://(.+)/(%d+)")
  end
  if not repo or not number then
    vim.notify("Not a gh-issue buffer", vim.log.levels.ERROR)
    return
  end
  reload_buffer(buf, repo, number, function(ok)
    if ok then
      vim.notify("Issue reloaded")
    else
      vim.notify("Failed to reload issue", vim.log.levels.ERROR)
    end
  end)
end, {})

return M

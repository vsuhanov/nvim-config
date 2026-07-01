local api = require("not-plugins.gh-issues.api")

local M = {}

local db = nil

local function get_db()
  if db then return db end
  local ok, sqlite = pcall(require, "sqlite")
  if not ok then
    api.log("cache: sqlite.lua not available")
    return nil
  end
  local dok, d = pcall(sqlite.new, vim.fn.stdpath("data") .. "/gh-issues.db", { open_mode = "rwc" })
  if not dok then
    api.log("cache: failed to open db: " .. tostring(d))
    return nil
  end
  d:open()
  d:eval([[CREATE TABLE IF NOT EXISTS issues (
    repo TEXT NOT NULL,
    number INTEGER NOT NULL,
    title TEXT,
    state TEXT,
    labels TEXT,
    assignees TEXT,
    html_url TEXT,
    updated_at TEXT,
    PRIMARY KEY (repo, number)
  )]])
  d:eval([[CREATE TABLE IF NOT EXISTS labels (
    repo TEXT NOT NULL,
    name TEXT NOT NULL,
    PRIMARY KEY (repo, name)
  )]])
  d:eval([[CREATE TABLE IF NOT EXISTS assignees (
    repo TEXT NOT NULL,
    login TEXT NOT NULL,
    PRIMARY KEY (repo, login)
  )]])
  d:eval([[CREATE TABLE IF NOT EXISTS fetched (
    key TEXT PRIMARY KEY,
    at INTEGER
  )]])
  db = d
  return db
end

local function mark_fetched(d, key)
  d:eval("INSERT OR REPLACE INTO fetched (key, at) VALUES (?, ?)", { key, os.time() })
end

local function fetched_at(d, key)
  local rows = d:eval("SELECT at FROM fetched WHERE key = ?", { key })
  if type(rows) == "table" and rows[1] and rows[1].at then
    return rows[1].at
  end
  return nil
end

local function issue_row(repo, issue)
  local label_names = {}
  if type(issue.labels) == "table" then
    for _, l in ipairs(issue.labels) do
      table.insert(label_names, l.name)
    end
  end
  local assignee_logins = {}
  if type(issue.assignees) == "table" then
    for _, a in ipairs(issue.assignees) do
      table.insert(assignee_logins, a.login)
    end
  end
  return {
    repo,
    issue.number,
    issue.title or "",
    issue.state or "",
    vim.fn.json_encode(label_names),
    vim.fn.json_encode(assignee_logins),
    issue.html_url or "",
    issue.updated_at or "",
  }
end

function M.issues(repo)
  local d = get_db()
  if not d then return {} end
  local rows = d:eval("SELECT * FROM issues WHERE repo = ? ORDER BY number DESC", { repo })
  if type(rows) ~= "table" then return {} end
  local out = {}
  for _, r in ipairs(rows) do
    local lok, labels = pcall(vim.fn.json_decode, r.labels or "[]")
    local aok, assignees = pcall(vim.fn.json_decode, r.assignees or "[]")
    table.insert(out, {
      number = r.number,
      title = r.title,
      state = r.state,
      labels = lok and labels or {},
      assignees = aok and assignees or {},
      html_url = r.html_url,
      updated_at = r.updated_at,
    })
  end
  return out
end

function M.store_issues(repo, issues)
  local d = get_db()
  if not d then return end
  d:eval("DELETE FROM issues WHERE repo = ?", { repo })
  for _, issue in ipairs(issues) do
    d:eval(
      "INSERT OR REPLACE INTO issues (repo, number, title, state, labels, assignees, html_url, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
      issue_row(repo, issue)
    )
  end
  mark_fetched(d, repo .. ":issues")
end

function M.refresh_issues(repo, cb)
  api.gh_api_async("/repos/" .. repo .. "/issues?state=open&per_page=100", function(ok, issues)
    if not ok or type(issues) ~= "table" then
      if cb then cb(false, nil) end
      return
    end
    M.store_issues(repo, issues)
    if cb then cb(true, issues) end
  end)
end

function M.upsert_issue(repo, issue)
  local d = get_db()
  if not d then return end
  d:eval(
    "INSERT OR REPLACE INTO issues (repo, number, title, state, labels, assignees, html_url, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
    issue_row(repo, issue)
  )
end

function M.labels(repo)
  local d = get_db()
  if not d then return {} end
  local rows = d:eval("SELECT name FROM labels WHERE repo = ? ORDER BY name", { repo })
  if type(rows) ~= "table" then return {} end
  local out = {}
  for _, r in ipairs(rows) do
    table.insert(out, r.name)
  end
  return out
end

function M.assignees(repo)
  local d = get_db()
  if not d then return {} end
  local rows = d:eval("SELECT login FROM assignees WHERE repo = ? ORDER BY login", { repo })
  if type(rows) ~= "table" then return {} end
  local out = {}
  for _, r in ipairs(rows) do
    table.insert(out, r.login)
  end
  return out
end

function M.refresh_labels(repo, cb)
  api.gh_api_async("/repos/" .. repo .. "/labels?per_page=100", function(ok, labels)
    if not ok or type(labels) ~= "table" then
      if cb then cb(false) end
      return
    end
    local d = get_db()
    if d then
      d:eval("DELETE FROM labels WHERE repo = ?", { repo })
      for _, l in ipairs(labels) do
        if l.name then
          d:eval("INSERT OR REPLACE INTO labels (repo, name) VALUES (?, ?)", { repo, l.name })
        end
      end
      mark_fetched(d, repo .. ":labels")
    end
    if cb then cb(true) end
  end)
end

function M.refresh_assignees(repo, cb)
  api.gh_api_async("/repos/" .. repo .. "/assignees?per_page=100", function(ok, assignees)
    if not ok or type(assignees) ~= "table" then
      if cb then cb(false) end
      return
    end
    local d = get_db()
    if d then
      d:eval("DELETE FROM assignees WHERE repo = ?", { repo })
      for _, a in ipairs(assignees) do
        if a.login then
          d:eval("INSERT OR REPLACE INTO assignees (repo, login) VALUES (?, ?)", { repo, a.login })
        end
      end
      mark_fetched(d, repo .. ":assignees")
    end
    if cb then cb(true) end
  end)
end

local STALE_SECONDS = 24 * 60 * 60
local refreshing = {}

function M.ensure_fresh_meta(repo)
  local d = get_db()
  if not d then return end
  for kind, refresh in pairs({ labels = M.refresh_labels, assignees = M.refresh_assignees }) do
    local key = repo .. ":" .. kind
    local at = fetched_at(d, key)
    if (not at or os.time() - at > STALE_SECONDS) and not refreshing[key] then
      refreshing[key] = true
      refresh(repo, function()
        refreshing[key] = nil
      end)
    end
  end
end

return M

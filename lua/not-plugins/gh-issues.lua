local config_path = vim.fn.stdpath("data") .. "/gh-issues-config.json"

local function read_config()
  local ok, data = pcall(vim.fn.readfile, config_path)
  if not ok or #data == 0 then return {} end
  local pok, parsed = pcall(vim.fn.json_decode, table.concat(data, "\n"))
  return pok and parsed or {}
end

local function write_config(cfg)
  vim.fn.writefile({ vim.fn.json_encode(cfg) }, config_path)
end

local log_path = "/tmp/gh-issues-nvim.log"
local function log(msg)
  local f = io.open(log_path, "a")
  if f then
    f:write(os.date("%H:%M:%S") .. " " .. tostring(msg) .. "\n")
    f:close()
  end
end

local function get_repo_from_git()
  local url = vim.fn.system("git -C " .. vim.fn.shellescape(vim.fn.getcwd()) .. " remote get-url origin 2>/dev/null"):gsub("%s+$", "")
  if url == "" then return nil end
  local repo = url:match("github%.com[:/](.-)%.git$") or url:match("github%.com[:/](.-)$")
  if repo and repo:match("^[^/]+/[^/]+$") then return repo end
  return nil
end

local function get_token()
  local cfg = read_config()
  local account = cfg.selected_account
  if account then
    local token = vim.fn.system("gh auth token -u " .. vim.fn.shellescape(account) .. " 2>/dev/null"):gsub("%s+$", "")
    if token ~= "" then return token end
  end
  return vim.env.GH_TOKEN or ""
end

local function make_env_list()
  local token = get_token()
  local env = vim.uv.os_environ()
  if token ~= "" then
    env.GH_TOKEN = token
  end
  env.GITHUB_TOKEN = nil
  local list = {}
  for k, v in pairs(env) do
    table.insert(list, k .. "=" .. v)
  end
  return list
end

local function gh_api(method, path, body)
  local token = get_token()
  local tmp
  local cmd
  if token ~= "" then
    cmd = string.format("GH_TOKEN=%s gh api --method %s %s 2>&1", vim.fn.shellescape(token), method, vim.fn.shellescape(path))
  else
    cmd = string.format("gh api --method %s %s 2>&1", method, vim.fn.shellescape(path))
  end
  if body then
    tmp = os.tmpname()
    vim.fn.writefile({ vim.fn.json_encode(body) }, tmp)
    cmd = cmd .. " --input " .. tmp
  end
  log("gh_api: " .. cmd)
  local result = vim.fn.system(cmd)
  log("gh_api result (" .. #result .. " bytes): " .. result:sub(1, 300))
  if tmp then os.remove(tmp) end
  local ok, parsed = pcall(vim.fn.json_decode, result)
  log("gh_api parse ok=" .. tostring(ok) .. " type=" .. type(parsed))
  return ok and parsed or nil
end

local function gh_api_async(path, callback)
  log("gh_api_async: " .. path)
  local stdout = vim.uv.new_pipe()
  local chunks = {}
  vim.uv.spawn("gh", {
    args = { "api", "--method", "GET", path },
    stdio = { nil, stdout, nil },
    env = make_env_list(),
  }, function()
    stdout:close()
  end)
  vim.uv.read_start(stdout, function(err, chunk)
    if chunk then
      table.insert(chunks, chunk)
    else
      local raw = table.concat(chunks)
      vim.schedule(function()
        log("gh_api_async result (" .. #raw .. " bytes): " .. raw:sub(1, 200))
        local ok, data = pcall(vim.fn.json_decode, raw)
        log("gh_api_async parse ok=" .. tostring(ok) .. " type=" .. type(data))
        callback(ok and data ~= nil, ok and data or nil)
      end)
    end
  end)
end

local function render_issue(issue, comments)
  local lines = {}

  table.insert(lines, "⭕ Meta")
  table.insert(lines, "title: " .. (issue.title or ""))
  table.insert(lines, "number: " .. tostring(issue.number or ""))
  table.insert(lines, "state: " .. (issue.state or ""))
  table.insert(lines, "author: " .. (type(issue.user) == "table" and issue.user.login or ""))
  table.insert(lines, "created_at: " .. (issue.created_at or ""))
  table.insert(lines, "updated_at: " .. (issue.updated_at or ""))

  local label_names = {}
  if type(issue.labels) == "table" then
    for _, l in ipairs(issue.labels) do
      table.insert(label_names, l.name)
    end
  end
  table.insert(lines, "labels: " .. table.concat(label_names, ", "))

  local assignee_names = {}
  if type(issue.assignees) == "table" then
    for _, a in ipairs(issue.assignees) do
      table.insert(assignee_names, a.login)
    end
  end
  table.insert(lines, "assignees: " .. table.concat(assignee_names, ", "))

  local repo = ""
  if issue.html_url then
    repo = issue.html_url:match("github%.com/([^/]+/[^/]+)/issues") or ""
  end
  table.insert(lines, "repo: " .. repo)
  table.insert(lines, "url: " .. (issue.html_url or ""))
  table.insert(lines, "")

  table.insert(lines, "⭕ Description")
  table.insert(lines, "")
  local body = (type(issue.body) == "string") and issue.body or ""
  for _, l in ipairs(vim.split(body, "\n", { plain = true })) do
    table.insert(lines, l)
  end
  table.insert(lines, "")

  table.insert(lines, "⭕ Comments")
  table.insert(lines, "")

  if type(comments) == "table" then
    for _, c in ipairs(comments) do
      table.insert(lines, "💬 comment [id: " .. tostring(c.id) .. "]")
      table.insert(lines, "author: " .. (type(c.user) == "table" and c.user.login or ""))
      table.insert(lines, "date: " .. (c.created_at or ""))
      table.insert(lines, "")
      local cbody = (type(c.body) == "string") and c.body or ""
      for _, l in ipairs(vim.split(cbody, "\n", { plain = true })) do
        table.insert(lines, l)
      end
      table.insert(lines, "")
    end
  end

  table.insert(lines, "💬 comment")
  table.insert(lines, "")

  return lines
end

local function parse_issue_buffer(lines)
  local meta = {}
  local description_lines = {}
  local new_comments = {}

  local section = nil
  local in_new_comment = false
  local current_comment_lines = {}

  local function flush_comment()
    if in_new_comment then
      local body = table.concat(current_comment_lines, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
      if body ~= "" then
        table.insert(new_comments, { body = body })
      end
      in_new_comment = false
      current_comment_lines = {}
    end
  end

  for _, line in ipairs(lines) do
    if line:match("^⭕ Meta") then
      section = "meta"
    elseif line:match("^⭕ Description") then
      section = "description"
    elseif line:match("^⭕ Comments") then
      section = "comments"
    elseif section == "meta" then
      local key, val = line:match("^([%w_]+): (.*)$")
      if key then meta[key] = val end
    elseif section == "description" then
      table.insert(description_lines, line)
    elseif section == "comments" then
      if line:match("^💬 comment %[id: %d+%]") then
        flush_comment()
      elseif line:match("^💬 comment$") then
        flush_comment()
        in_new_comment = true
      elseif in_new_comment then
        table.insert(current_comment_lines, line)
      end
    end
  end
  flush_comment()

  local desc = table.concat(description_lines, "\n"):gsub("^%s+", ""):gsub("%s+$", "")

  return { meta = meta, description = desc, new_comments = new_comments }
end

local function open_issue_buffer(repo, issue, comments)
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

  local lines = render_issue(issue, comments)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = ""
  vim.bo[buf].modified = false
  vim.bo[buf].filetype = "markdown"
end

vim.api.nvim_create_autocmd("BufWriteCmd", {
  pattern = "gh-issue://*",
  callback = function(ev)
    local bufname = vim.api.nvim_buf_get_name(ev.buf)
    local repo, number = bufname:match("^gh%-issue://(.+)/(%d+)$")
    if not repo or not number then
      vim.notify("Cannot parse buffer name: " .. bufname, vim.log.levels.ERROR)
      return
    end

    local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
    local parsed = parse_issue_buffer(lines)
    local local_updated_at = parsed.meta.updated_at

    gh_api_async("/repos/" .. repo .. "/issues/" .. number, function(ok, current_issue)
      if not ok or not current_issue then
        vim.notify("Failed to fetch current issue state", vim.log.levels.ERROR)
        return
      end

      local server_updated_at = current_issue.updated_at

      if server_updated_at ~= local_updated_at then
        vim.bo[ev.buf].modifiable = false
        local conflict_name = "gh-issue://" .. repo .. "/" .. number .. "@conflict"
        vim.api.nvim_buf_set_name(ev.buf, conflict_name)

        gh_api_async("/repos/" .. repo .. "/issues/" .. number .. "/comments", function(cok, fresh_comments)
          local fresh_cmts = (cok and type(fresh_comments) == "table") and fresh_comments or {}

          vim.cmd("vsplit")
          vim.cmd("enew")
          local new_buf = vim.api.nvim_get_current_buf()
          vim.api.nvim_buf_set_name(new_buf, "gh-issue://" .. repo .. "/" .. number)

          local fresh_lines = render_issue(current_issue, fresh_cmts)
          vim.bo[new_buf].modifiable = true
          vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, fresh_lines)
          vim.bo[new_buf].buftype = ""
          vim.bo[new_buf].modified = false
          vim.bo[new_buf].filetype = "markdown"

          vim.cmd("diffthis")
          vim.cmd("wincmd h")
          vim.cmd("diffthis")

          vim.notify("Issue updated externally. Your edits (left, read-only) vs server state (right).")
        end)
      else
        local api_body = (type(current_issue.body) == "string") and current_issue.body or ""

        local function reload_buffer()
          gh_api_async("/repos/" .. repo .. "/issues/" .. number, function(fok, fresh_issue)
            if not fok or not fresh_issue then
              vim.notify("Saved but failed to reload", vim.log.levels.WARN)
              vim.bo[ev.buf].modified = false
              return
            end
            gh_api_async("/repos/" .. repo .. "/issues/" .. number .. "/comments", function(cok, fresh_comments)
              local fresh_cmts = (cok and type(fresh_comments) == "table") and fresh_comments or {}
              local fresh_lines = render_issue(fresh_issue, fresh_cmts)
              vim.bo[ev.buf].modifiable = true
              vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, fresh_lines)
              vim.bo[ev.buf].modified = false
              vim.notify("Issue saved")
            end)
          end)
        end

        if parsed.description ~= api_body then
          local result = gh_api("PATCH", "/repos/" .. repo .. "/issues/" .. number, { body = parsed.description })
          if not result then
            vim.notify("Failed to update issue description", vim.log.levels.ERROR)
            return
          end
        end

        for _, c in ipairs(parsed.new_comments) do
          local result = gh_api("POST", "/repos/" .. repo .. "/issues/" .. number .. "/comments", { body = c.body })
          if not result then
            vim.notify("Failed to post comment", vim.log.levels.ERROR)
          end
        end

        reload_buffer()
      end
    end)
  end
})

local function issues_picker(opts)
  opts = opts or {}
  local ok_tel, pickers = pcall(require, "telescope.pickers")
  if not ok_tel then
    vim.notify("telescope not available", vim.log.levels.ERROR)
    return
  end
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  local cfg = read_config()
  local repo = cfg.selected_repo or get_repo_from_git()
  if not repo then
    vim.notify("No repo selected. Run :GHIssues owner/repo", vim.log.levels.ERROR)
    return
  end

  local issues = gh_api("GET", "/repos/" .. repo .. "/issues?state=open&per_page=100")
  if not issues then
    vim.notify("Failed to fetch issues for " .. repo, vim.log.levels.ERROR)
    return
  end

  pickers.new(opts, {
    prompt_title = "Issues: " .. repo,
    sorting_strategy = "ascending",
    finder = finders.new_table({
      results = issues,
      entry_maker = function(issue)
        local assignees = {}
        if type(issue.assignees) == "table" and #issue.assignees > 0 then
          for _, a in ipairs(issue.assignees) do
            table.insert(assignees, "@" .. a.login)
          end
        end
        local labels = {}
        if type(issue.labels) == "table" and #issue.labels > 0 then
          for _, l in ipairs(issue.labels) do
            table.insert(labels, l.name)
          end
        end

        local display = issue.title
        if #assignees > 0 then
          display = display .. " [" .. table.concat(assignees, ", ") .. "]"
        else
          display = display .. " [unassigned]"
        end
        if #labels > 0 then
          display = display .. " (" .. table.concat(labels, ", ") .. ")"
        end

        return {
          value = issue,
          display = display,
          ordinal = display,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    previewer = previewers.new_buffer_previewer({
      title = "Issue Preview",
      define_preview = function(self, entry)
        local bufnr = self.state.bufnr
        local token = (self.state.preview_token or 0) + 1
        self.state.preview_token = token
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Loading..." })

        local stdout = vim.uv.new_pipe()
        local chunks = {}
        vim.uv.spawn("gh", {
          args = { "api", "--method", "GET", "/repos/" .. repo .. "/issues/" .. tostring(entry.value.number) },
          stdio = { nil, stdout, nil },
          env = make_env_list(),
        }, function()
          stdout:close()
        end)
        vim.uv.read_start(stdout, function(err, chunk)
          if chunk then
            table.insert(chunks, chunk)
          else
            local raw = table.concat(chunks)
            vim.schedule(function()
              if not vim.api.nvim_buf_is_valid(bufnr) then return end
              if self.state.preview_token ~= token then return end
              local pok, issue_data = pcall(vim.fn.json_decode, raw)
              if not pok or not issue_data then
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Failed to load" })
                return
              end
              local preview_body = (type(issue_data.body) == "string") and issue_data.body or ""
              local preview_lines = vim.split(preview_body, "\n", { plain = true })
              if #preview_lines == 0 then preview_lines = { "" } end
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, preview_lines)
              vim.bo[bufnr].filetype = "markdown"
            end)
          end
        end)
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        local issue_number = tostring(entry.value.number)
        local issue_data = gh_api("GET", "/repos/" .. repo .. "/issues/" .. issue_number)
        if not issue_data then
          vim.notify("Failed to fetch issue", vim.log.levels.ERROR)
          return
        end
        local comments = gh_api("GET", "/repos/" .. repo .. "/issues/" .. issue_number .. "/comments")
        open_issue_buffer(repo, issue_data, comments or {})
      end)
      local open_url = function()
        local entry = action_state.get_selected_entry()
        vim.fn.system("open " .. vim.fn.shellescape(entry.value.html_url))
      end
      local copy_url = function()
        local entry = action_state.get_selected_entry()
        vim.fn.setreg("+", entry.value.html_url)
        vim.notify("Copied: " .. entry.value.html_url)
      end
      map("i", "<C-o>", open_url)
      map("n", "<C-o>", open_url)
      map("n", "y", copy_url)
      return true
    end,
  }):find()
end

local function repos_picker(opts)
  opts = opts or {}
  local ok_tel, pickers = pcall(require, "telescope.pickers")
  if not ok_tel then
    vim.notify("telescope not available", vim.log.levels.ERROR)
    return
  end
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local repos = gh_api("GET", "/user/repos?per_page=100&type=all")
  if not repos then
    vim.notify("Failed to fetch repos", vim.log.levels.ERROR)
    return
  end

  pickers.new(opts, {
    prompt_title = "Select Repository",
    sorting_strategy = "ascending",
    finder = finders.new_table({
      results = repos,
      entry_maker = function(r)
        return {
          value = r,
          display = r.full_name,
          ordinal = r.full_name,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        local cfg = read_config()
        cfg.selected_repo = entry.value.full_name
        write_config(cfg)
        vim.notify("Selected repo: " .. entry.value.full_name)
      end)
      return true
    end,
  }):find()
end

vim.api.nvim_create_user_command("GHIssuesAccount", function()
  local output = vim.fn.system("gh auth status 2>&1")
  local accounts = {}
  for name in output:gmatch("account (%S+)") do
    table.insert(accounts, name)
  end
  if #accounts == 0 then
    vim.notify("No GitHub accounts found. Run `gh auth login`", vim.log.levels.ERROR)
    return
  end
  local ok, Menu = pcall(require, "nui.menu")
  if not ok then
    vim.notify("nui.menu not available", vim.log.levels.ERROR)
    return
  end
  local menu_lines = {}
  for _, name in ipairs(accounts) do
    table.insert(menu_lines, Menu.item(name, { account = name }))
  end
  local menu = Menu({
    position = "50%",
    size = { width = 40 },
    border = { style = "rounded", text = { top = " Select GitHub Account (Issues) ", top_align = "center" } },
  }, {
    lines = menu_lines,
    on_submit = function(item)
      vim.fn.system("gh auth switch -u " .. vim.fn.shellescape(item.account))
      local cfg = read_config()
      cfg.selected_account = item.account
      write_config(cfg)
      vim.notify("Switched to GitHub account: " .. item.account)
    end,
  })
  menu:mount()
end, {})

vim.api.nvim_create_user_command("GHIssues", function(opts)
  if opts.args and opts.args ~= "" then
    local cfg = read_config()
    cfg.selected_repo = opts.args
    write_config(cfg)
    vim.notify("Selected repo: " .. opts.args)
  else
    repos_picker()
  end
end, { nargs = "?" })

vim.api.nvim_create_user_command("GHIssuesPicker", function()
  issues_picker()
end, {})

local tok, telescope = pcall(require, "telescope")
if tok then
  log("registering telescope extension gh_issues")
  telescope.extensions.gh_issues = { issues = issues_picker, gh_issues = issues_picker }
end

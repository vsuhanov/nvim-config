local api = require("not-plugins.gh-issues.api")
local cache = require("not-plugins.gh-issues.cache")
local view = require("not-plugins.gh-issues.view")

local M = {}

local function make_entry(issue)
  local assignees = {}
  if type(issue.assignees) == "table" and #issue.assignees > 0 then
    for _, a in ipairs(issue.assignees) do
      table.insert(assignees, "@" .. (type(a) == "table" and a.login or a))
    end
  end
  local labels = {}
  if type(issue.labels) == "table" and #issue.labels > 0 then
    for _, l in ipairs(issue.labels) do
      table.insert(labels, type(l) == "table" and l.name or l)
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
end

function M.issues_picker(opts)
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

  local cfg = api.read_config()
  local repo = cfg.selected_repo or api.get_repo_from_git()
  if not repo then
    vim.notify("No repo selected. Run :GHIssues owner/repo", vim.log.levels.ERROR)
    return
  end

  cache.ensure_fresh_meta(repo)

  local issues = cache.issues(repo)
  local from_cache = #issues > 0
  if not from_cache then
    issues = api.gh_api("GET", "/repos/" .. repo .. "/issues?state=open&per_page=100")
    if not issues then
      vim.notify("Failed to fetch issues for " .. repo, vim.log.levels.ERROR)
      return
    end
    cache.store_issues(repo, issues)
  end

  local picker = pickers.new(opts, {
    prompt_title = "Issues: " .. repo,
    sorting_strategy = "ascending",
    finder = finders.new_table({
      results = issues,
      entry_maker = make_entry,
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
          env = api.make_env_list(),
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
        local issue_data = api.gh_api("GET", "/repos/" .. repo .. "/issues/" .. issue_number)
        if not issue_data then
          vim.notify("Failed to fetch issue", vim.log.levels.ERROR)
          return
        end
        local comments = api.gh_api("GET", "/repos/" .. repo .. "/issues/" .. issue_number .. "/comments")
        view.open_issue_buffer(repo, issue_data, comments or {})
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
  })
  picker:find()

  if from_cache then
    cache.refresh_issues(repo, function(rok, fresh)
      if not rok or not fresh then return end
      if not picker.prompt_bufnr or not vim.api.nvim_buf_is_valid(picker.prompt_bufnr) then return end
      picker:refresh(finders.new_table({
        results = fresh,
        entry_maker = make_entry,
      }), { reset_prompt = false })
    end)
  end
end

function M.repos_picker(opts)
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

  local repos = api.gh_api("GET", "/user/repos?per_page=100&type=all")
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
        local cfg = api.read_config()
        cfg.selected_repo = entry.value.full_name
        api.write_config(cfg)
        vim.notify("Selected repo: " .. entry.value.full_name)
      end)
      return true
    end,
  }):find()
end

return M

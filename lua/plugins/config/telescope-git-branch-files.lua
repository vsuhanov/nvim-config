-- Telescope picker: show all files changed in the current branch vs a base branch.
--
-- Base branch resolution order:
--   1. opts.base_branch   – explicit argument passed by the caller
--   2. $GIT_BASE_BRANCH   – custom environment variable
--   3. "origin/main"      – hard-coded default
--
-- Usage (from Lua):
--   require('plugins.config.telescope-git-branch-files').git_branch_files()
--   require('plugins.config.telescope-git-branch-files').git_branch_files({ base_branch = "origin/develop" })
--
-- Usage (as a command):
--   :GitBranchFiles
--   :GitBranchFiles origin/develop

local M = {}

--- Resolve which base branch to diff against.
--- @param opts table|nil  May contain opts.base_branch
--- @return string
local function resolve_base_branch(opts)
  opts = opts or {}
  if opts.base_branch and opts.base_branch ~= "" then
    return opts.base_branch
  end
  local env = vim.fn.getenv("GIT_BASE_BRANCH")
  if type(env) == "string" and env ~= "" and env ~= vim.NIL then
    return env
  end
  return "origin/main"
end

--- Run a shell command synchronously and return stdout lines.
--- Returns nil + error string on failure.
--- @param cmd string[]
--- @param cwd string|nil
--- @return string[]|nil, string|nil
local function run(cmd, cwd)
  local result = vim.fn.systemlist(
    table.concat(
      vim.tbl_map(function(s) return vim.fn.shellescape(s) end, cmd),
      " "
    ),
    nil,
    false
  )
  -- vim.fn.systemlist doesn't support cwd natively; we prepend a cd
  -- Actually, let's use jobstart approach via vim.system when available,
  -- or fall back to a subshell cd trick.
  local full_cmd
  if cwd then
    full_cmd = "cd " .. vim.fn.shellescape(cwd) .. " && " ..
      table.concat(
        vim.tbl_map(function(s) return vim.fn.shellescape(s) end, cmd),
        " "
      )
  else
    full_cmd = table.concat(
      vim.tbl_map(function(s) return vim.fn.shellescape(s) end, cmd),
      " "
    )
  end
  local lines = vim.fn.systemlist(full_cmd)
  local code = vim.v.shell_error
  if code ~= 0 then
    return nil, table.concat(lines, "\n")
  end
  return lines, nil
end

--- Build git diff command to list changed files.
--- @param base string   base branch / commit
--- @param cwd  string   repo root
--- @return string[]|nil files, string|nil err
local function get_changed_files(base, cwd)
  -- Use merge-base so we compare only branch-specific changes, not divergence in base.
  local merge_base_lines, err = run({ "git", "merge-base", base, "HEAD" }, cwd)
  if not merge_base_lines or #merge_base_lines == 0 then
    -- Fallback: just diff directly (handles shallow clones, detached HEAD, etc.)
    vim.notify(
      string.format("[GitBranchFiles] merge-base failed (%s), falling back to direct diff", err or ""),
      vim.log.levels.WARN
    )
    return run({ "git", "diff", "--name-only", base }, cwd)
  end

  local merge_base = vim.trim(merge_base_lines[1])
  return run({ "git", "diff", "--name-only", merge_base }, cwd)
end

--- Main picker entry point.
--- @param opts table|nil
function M.git_branch_files(opts)
  opts = opts or {}

  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local conf         = require("telescope.config").values
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local cwd = opts.cwd or vim.uv.cwd()
  local base_branch = resolve_base_branch(opts)

  -- Fetch changed file list up-front (fast, blocking – typically <50 ms)
  local files, err = get_changed_files(base_branch, cwd)
  if not files then
    vim.notify("[GitBranchFiles] Failed to get changed files: " .. (err or "unknown error"), vim.log.levels.ERROR)
    return
  end
  if #files == 0 then
    vim.notify("[GitBranchFiles] No changed files compared to " .. base_branch, vim.log.levels.INFO)
    return
  end

  -- Resolve absolute paths for the previewer
  local entries = {}
  for _, rel in ipairs(files) do
    if rel ~= "" then
      table.insert(entries, {
        value    = rel,                                    -- relative path (display)
        display  = rel,
        ordinal  = rel,
        path     = cwd .. "/" .. rel,                     -- absolute (for previewer / opening)
        filename = cwd .. "/" .. rel,
      })
    end
  end

  pickers.new(opts, {
    prompt_title  = "Branch files vs " .. base_branch,
    finder        = finders.new_table({
      results     = entries,
      entry_maker = function(e) return e end,
    }),
    sorter        = conf.generic_sorter(opts),
    previewer     = conf.file_previewer(opts),
    attach_mappings = function(prompt_bufnr, map)
      -- Default <CR>: open selected file
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if entry then
          vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
        end
      end)

      -- <C-d>: open git diff for the selected file vs base
      local open_diff = function()
        actions.close(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if entry then
          vim.cmd("DiffviewOpen " .. vim.fn.shellescape(base_branch) .. " -- " .. vim.fn.shellescape(entry.value))
        end
      end
      map("i", "<C-d>", open_diff)
      map("n", "<C-d>", open_diff)

      return true
    end,
  }):find()
end

return M

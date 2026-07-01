local api = require("not-plugins.gh-issues.api")
local picker = require("not-plugins.gh-issues.picker")
require("not-plugins.gh-issues.view")

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
      local cfg = api.read_config()
      cfg.selected_account = item.account
      api.write_config(cfg)
      vim.notify("Switched to GitHub account: " .. item.account)
    end,
  })
  menu:mount()
end, {})

vim.api.nvim_create_user_command("GHIssues", function(opts)
  if opts.args and opts.args ~= "" then
    local cfg = api.read_config()
    cfg.selected_repo = opts.args
    api.write_config(cfg)
    vim.notify("Selected repo: " .. opts.args)
  else
    picker.repos_picker()
  end
end, { nargs = "?" })

vim.api.nvim_create_user_command("GHIssuesPicker", function()
  picker.issues_picker()
end, {})

local tok, telescope = pcall(require, "telescope")
if tok then
  api.log("registering telescope extension gh_issues")
  telescope.extensions.gh_issues = { issues = picker.issues_picker, gh_issues = picker.issues_picker }
end

local cok, cmp = pcall(require, "cmp")
if cok then
  cmp.register_source("gh_issues", require("not-plugins.gh-issues.cmp_source").new())
end

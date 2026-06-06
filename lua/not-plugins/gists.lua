local config_path = vim.fn.stdpath("data") .. "/gists-config.json"
local config = {}

do
  local ok, content = pcall(vim.fn.readfile, config_path)
  if ok and #content > 0 then
    local dok, data = pcall(vim.fn.json_decode, table.concat(content, "\n"))
    if dok and type(data) == "table" then config = data end
  end
end

local function save_config()
  vim.fn.writefile({ vim.fn.json_encode(config) }, config_path)
end


local function gh_api(method, path, body)
  local tmp
  local cmd = string.format("env -u GITHUB_TOKEN gh api --method %s %s 2>/dev/null", method, path)
  if body then
    tmp = os.tmpname()
    vim.fn.writefile({ vim.fn.json_encode(body) }, tmp)
    cmd = cmd .. " --input " .. tmp
  end
  local result = vim.fn.system(cmd)
  if tmp then os.remove(tmp) end
  local ok, parsed = pcall(vim.fn.json_decode, result)
  return ok and parsed or nil
end

local gist_buffers = {}

local function get_filetype(filename)
  local ext = filename:match("%.([^.]+)$")
  if not ext then return "" end
  local map = {
    lua = "lua", js = "javascript", ts = "typescript", py = "python",
    rb = "ruby", go = "go", rs = "rust", sh = "sh", md = "markdown",
    json = "json", yaml = "yaml", yml = "yaml", toml = "toml",
    html = "html", css = "css", c = "c", cpp = "cpp", h = "c",
  }
  return map[ext] or ext
end

local function open_gist_buffer(gist_id, filename, content)
  vim.cmd("enew")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, "gist://" .. gist_id .. "/" .. filename)
  local lines = vim.split(content, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = ""
  vim.bo[buf].modified = false
  local ft = get_filetype(filename)
  if ft ~= "" then vim.bo[buf].filetype = ft end
  gist_buffers[buf] = { id = gist_id, filename = filename }
end

vim.api.nvim_create_autocmd("BufWriteCmd", {
  pattern = "gist://*",
  callback = function(ev)
    local info = gist_buffers[ev.buf]
    if not info then return end
    local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
    local content = table.concat(lines, "\n")
    gh_api("PATCH", "/gists/" .. info.id, {
      files = { [info.filename] = { content = content } }
    })
    vim.bo[ev.buf].modified = false
    vim.notify("Gist updated")
  end
})

vim.api.nvim_create_user_command("GistAccount", function()
  local output = vim.fn.system("gh auth status 2>&1")
  local accounts = {}
  for name in output:gmatch("as (%S+)") do
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
  local lines = {}
  for _, name in ipairs(accounts) do
    table.insert(lines, Menu.item(name, { account = name }))
  end
  local menu = Menu({
    position = "50%",
    size = { width = 40 },
    border = { style = "rounded", text = { top = " Select GitHub Account ", top_align = "center" } },
  }, {
    lines = lines,
    on_submit = function(item)
      config.selected_account = item.account
      save_config()
      vim.notify("GitHub account set to: " .. item.account)
    end,
  })
  menu:mount()
end, {})

vim.api.nvim_create_user_command("CreateGist", function(opts)
  local lines
  if opts.range > 0 then
    lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
  else
    lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end
  local content = table.concat(lines, "\n")
  local filename = vim.fn.expand("%:t")
  if filename == "" then filename = "gist.txt" end
  vim.ui.input({ prompt = "Gist description: " }, function(description)
    if description == nil then return end
    local result = gh_api("POST", "/gists", {
      description = description,
      public = false,
      files = { [filename] = { content = content } },
    })
    if not result or not result.id then
      local msg = (result and result.message) and result.message or "check token has gist scope: gh auth refresh -s gist"
      vim.notify("Failed to create gist: " .. msg, vim.log.levels.ERROR)
      return
    end
    open_gist_buffer(result.id, filename, content)
    vim.notify("Gist created: " .. result.id)
  end)
end, { nargs = "?", range = true })

local function gists_picker(opts)
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

  local gists = gh_api("GET", "/gists")
  if not gists then return end

  pickers.new(opts, {
    prompt_title = "Gists",
    sorting_strategy = "ascending",
    finder = finders.new_table({
      results = gists,
      entry_maker = function(gist)
        local filename = next(gist.files)
        local desc = (type(gist.description) == "string" and gist.description ~= "") and gist.description or filename
        local display = desc .. "  " .. gist.updated_at:sub(1, 10)
        return {
          value = gist,
          display = display,
          ordinal = display,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    previewer = previewers.new_buffer_previewer({
      title = "Gist Content",
      define_preview = function(self, entry)
        local bufnr = self.state.bufnr
        local token = (self.state.preview_token or 0) + 1
        self.state.preview_token = token
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Loading..." })
        local stdout = vim.uv.new_pipe()
        local chunks = {}
        vim.uv.spawn("env", {
          args = { "-u", "GITHUB_TOKEN", "gh", "api", "--method", "GET", "/gists/" .. entry.value.id },
          stdio = { nil, stdout, nil },
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
              local ok, gist = pcall(vim.fn.json_decode, raw)
              if not ok or not gist then
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Failed to load" })
                return
              end
              local filename = next(gist.files)
              local file = gist.files[filename]
              local lines = vim.split(type(file.content) == "string" and file.content or "", "\n", { plain = true })
              if #lines == 0 then lines = { "" } end
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
              local ft = get_filetype(filename)
              if ft ~= "" then vim.bo[bufnr].filetype = ft end
            end)
          end
        end)
      end,
    }),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        local gist = gh_api("GET", "/gists/" .. entry.value.id)
        if not gist then return end
        local filename = next(gist.files)
        local file = gist.files[filename]
        open_gist_buffer(gist.id, filename, file.content or "")
      end)
      return true
    end,
  }):find()
end

local tok, telescope = pcall(require, "telescope")
if tok then
  telescope.extensions.gists = { gists = gists_picker }
end

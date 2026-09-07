local SESSION_VAR = "ai_cli_session"
local BASE_NAME = "AI_CLI"
local ns = vim.api.nvim_create_namespace("ai_cli_prompt")

local function ai_command()
  local cmd = vim.fn.getenv("NVIM_AI_CLI_COMMAND")
  if cmd == vim.NIL or cmd == "" then
    return "claude"
  end
  return cmd
end

local function term_env()
  if not vim.o.termguicolors then
    return nil
  end
  local colorterm = vim.fn.getenv("COLORTERM")
  if colorterm == vim.NIL or colorterm == "" then
    colorterm = "truecolor"
  end
  return { COLORTERM = colorterm, FORCE_COLOR = "3" }
end

local function session_index(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end
  local ok, idx = pcall(vim.api.nvim_buf_get_var, buf, SESSION_VAR)
  if ok and type(idx) == "number" then
    return idx
  end
  return nil
end

local function find_win_in_tab()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if session_index(buf) then
      return win
    end
  end
end

local function find_session_buf(wanted)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if session_index(buf) == wanted then
      return buf
    end
  end
end

local function next_session_index()
  local max = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local idx = session_index(buf)
    if idx and idx > max then
      max = idx
    end
  end
  return max + 1
end

local function focus_terminal(win)
  vim.api.nvim_set_current_win(win)
  vim.cmd("startinsert")
end

local SPLITS = {
  left = "leftabove vsplit",
  right = "rightbelow vsplit",
  up = "leftabove split",
  down = "rightbelow split",
}

local function split_cmd(direction)
  return SPLITS[direction] or "vsplit"
end

local function open_session(idx, direction)
  vim.cmd(split_cmd(direction))
  vim.cmd("enew")
  vim.fn.jobstart(ai_command(), { term = true, env = term_env() })
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_var(buf, SESSION_VAR, idx)
  local name = idx == 1 and BASE_NAME or (BASE_NAME .. " " .. idx)
  pcall(vim.api.nvim_buf_set_name, buf, name)
  vim.cmd("startinsert")
end

local function open_default_session(direction)
  local buf = find_session_buf(1)
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.cmd(split_cmd(direction))
    vim.api.nvim_set_current_buf(buf)
    vim.cmd("startinsert")
  else
    open_session(1, direction)
  end
end

local QUESTION = "New Claude session?"

local function button_line(choice)
  local yes = choice == "yes" and "[ Yes ]" or "  Yes  "
  local no = choice == "no" and "[ No ]" or "  No  "
  return "  " .. yes .. "    " .. no .. "  "
end

local function confirm(on_choice)
  local buf = vim.api.nvim_create_buf(false, true)
  local choice = "yes"

  local width = math.max(vim.fn.strdisplaywidth(QUESTION), vim.fn.strdisplaywidth(button_line("no"))) + 2

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = 2,
    style = "minimal",
    border = "rounded",
    noautocmd = true,
  })

  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
  vim.bo[buf].bufhidden = "wipe"

  local function render()
    local line = button_line(choice)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " " .. QUESTION, line })
    vim.bo[buf].modifiable = false

    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    local target = choice == "yes" and "[ Yes ]" or "[ No ]"
    local start = line:find(target, 1, true)
    if start then
      vim.api.nvim_buf_set_extmark(buf, ns, 1, start - 1, {
        end_col = start - 1 + #target,
        hl_group = "PmenuSel",
      })
    end
  end

  local closed = false
  local function close(result)
    if closed then
      return
    end
    closed = true
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    on_choice(result)
  end

  local function map(keys, fn)
    for _, key in ipairs(keys) do
      vim.keymap.set("n", key, fn, { buffer = buf, nowait = true, silent = true })
    end
  end

  local function toggle()
    choice = choice == "yes" and "no" or "yes"
    render()
  end

  map({ "<Tab>", "<S-Tab>", "h", "l", "<Left>", "<Right>" }, toggle)
  map({ "y", "Y" }, function() close("yes") end)
  map({ "n", "N" }, function() close("no") end)
  map({ "<CR>", "<Space>" }, function() close(choice) end)
  map({ "<Esc>", "q" }, function() close("no") end)

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buf,
    once = true,
    callback = function()
      vim.schedule(function() close("no") end)
    end,
  })

  render()
end

local function ai_cli_command(direction, force_new)
  local win = find_win_in_tab()

  if force_new then
    open_session(next_session_index(), direction)
    return
  end

  if not win then
    open_default_session(direction)
    return
  end

  confirm(function(result)
    if result == "yes" then
      open_session(next_session_index(), direction)
    elseif vim.api.nvim_win_is_valid(win) then
      focus_terminal(win)
    end
  end)
end

vim.api.nvim_create_user_command('AiCli', function(opts)
  ai_cli_command(opts.args ~= "" and opts.args or nil)
end, {
  nargs = "?",
  complete = function()
    return { "left", "right", "up", "down" }
  end,
})

local function map(lhs, direction, force_new)
  vim.keymap.set("n", lhs, function() ai_cli_command(direction, force_new) end, { silent = true })
end

map("<leader>ai", nil)
map("<leader>3", nil)
map("<leader>3h", "left", true)
map("<leader>3l", "right", true)
map("<leader>3k", "up", true)
map("<leader>3j", "down", true)

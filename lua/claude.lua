local function ai_cli_command()
  local ai_command = vim.fn.getenv("NVIM_AI_CLI_COMMAND")
  if ai_command == vim.NIL or ai_command == "" then
    ai_command = "claude"
  end

  local buf_name = "AI_CLI"
  local ai_buf = nil
  local ai_win = nil
  local current_tab = vim.fn.tabpagenr()

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.fn.bufname(buf) == buf_name then
      ai_win = win
      ai_buf = buf
      break
    end
  end

  if ai_win then
    vim.api.nvim_set_current_win(ai_win)
    vim.api.nvim_feedkeys("A", "n", false)
  else
    local buffers = vim.fn.getbufinfo()
    for _, buf in ipairs(buffers) do
      if vim.fn.bufname(buf.bufnr) == buf_name and vim.fn.getbufvar(buf.bufnr, "&buflisted") == 1 then
        ai_buf = buf.bufnr
        break
      end
    end

    if ai_buf and vim.fn.bufexists(ai_buf) == 1 then
      vim.cmd("vs")
      vim.cmd("buffer " .. ai_buf)
      vim.api.nvim_feedkeys("A", "n", false)
    else
      vim.cmd("vs")
      vim.cmd("terminal " .. ai_command)
      vim.cmd("file " .. buf_name)
    end
  end
end

vim.api.nvim_create_user_command('AiCli', ai_cli_command, {})
vim.keymap.set("n", "<leader>ai", function() vim.cmd("AiCli") end, {silent = true})
vim.keymap.set("n", "<leader>3", function() vim.cmd("AiCli") end, {silent = true})

local dap = require("dap")
local dapui = require("dapui")
local dap_python = require("dap-python")

require("dapui").setup({})
require("nvim-dap-virtual-text").setup({
  commented = true, -- Show virtual text alongside comment
})

dap_python.setup(os.getenv("DAP_PYTHON_VENV_PATH") or "python3")

dap.configurations.lua = {
  {
    type = 'nlua',
    request = 'attach',
    name = "Attach to running Neovim instance",
  }
}

dap.adapters.nlua = function(callback, config)
  callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
end

dap.adapters['pwa-node'] = {
  type = 'server',
  host = 'localhost',
  port = '${port}',
  executable = {
    command = 'node',
    args = {
      vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
      '${port}'
    },
  }
}

dap.configurations.typescript = {
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Debug Current Test File',
    cwd = '${workspaceFolder}',
    runtimeExecutable = 'bun',
    runtimeArgs = {
      'test:debug',
      '${file}',
    },
    console = 'integratedTerminal',
  },
}

dap.configurations.javascript = dap.configurations.typescript

vim.fn.sign_define("DapBreakpoint", {
  text = "",
  texthl = "DiagnosticSignError",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapBreakpointRejected", {
  text = "", -- or "❌"
  texthl = "DiagnosticSignError",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapStopped", {
  text = "", -- or "→"
  texthl = "DiagnosticSignWarn",
  linehl = "Visual",
  numhl = "DiagnosticSignWarn",
})

-- Automatically open/close DAP UI
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end

-- DAP notification listeners - notify once per debug session
local notifications = require("utils.notifications")
local session_notified = {}

-- Notify when debugger stops (breakpoint or other reasons) - only once per session
dap.listeners.after.event_stopped["debugger_notify"] = function(session, body)
  local session_id = session.id
  if not session_notified[session_id] then
    local reason = body.reason or "unknown"
    notifications.notify(
      string.format("Debugger stopped: %s", reason),
      "DAP Debugger"
    )
    session_notified[session_id] = true
  end
end

-- Clear notification flag when debugger terminates
dap.listeners.after.event_terminated["debugger_notify"] = function(session, body)
  local session_id = session.id
  session_notified[session_id] = nil
  notifications.notify("Debugger terminated", "DAP Debugger")
end

local opts = { noremap = true, silent = true }

-- Toggle breakpoint
vim.keymap.set("n", "<leader>db", function()
  dap.toggle_breakpoint()
end, opts)

-- Continue / Start
vim.keymap.set("n", "<leader>dc", function()
  dap.continue()
end, opts)

-- Step Over
vim.keymap.set("n", "<leader>do", function()
  dap.step_over()
end, opts)

-- Step Into
vim.keymap.set("n", "<leader>di", function()
  dap.step_into()
end, opts)

-- Step Out
vim.keymap.set("n", "<leader>dO", function()
  dap.step_out()
end, opts)
-- Keymap to terminate debugging
vim.keymap.set("n", "<leader>dq", function()
  require("dap").terminate()
end, opts)

-- Toggle DAP UI
vim.keymap.set("n", "<leader>du", function()
  dapui.toggle()
end, opts)
-- Eval expression (visual mode uses selection)
vim.keymap.set("v", "<leader>ex", function()
  dapui.eval()
end, opts)

-- Eval expression (normal mode prompts for input)
vim.keymap.set("n", "<leader>ex", function()
  local expr = vim.fn.input("Expression: ")
  if expr ~= "" then
    dapui.eval(expr)
  end
end, opts)


vim.api.nvim_create_user_command("DebugLua", function()
  require "osv".launch({ port = 8086 })
end, { desc = "Debug lua program on port 8086" })

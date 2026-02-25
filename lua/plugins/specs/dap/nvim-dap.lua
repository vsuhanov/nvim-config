return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
    "mfussenegger/nvim-dap-python",
    "leoluz/nvim-dap-go",
    "theHamsta/nvim-dap-virtual-text",
    "jbyuki/one-small-step-for-vimkind",
    "vsuhanov/persistent-breakpoints.nvim",
  },
  keys = {
    { "<leader>db", function() require('persistent-breakpoints.api').toggle_breakpoint() end, desc = "Toggle breakpoint" },
    { "<leader>Db", function() require('persistent-breakpoints.api').set_conditional_breakpoint() end, desc = "Conditional breakpoint" },
    { "<leader>dc", function() require('dap').continue() end, desc = "Continue" },
    { "<leader>do", function() require('dap').step_over() end, desc = "Step over" },
    { "<leader>di", function() require('dap').step_into() end, desc = "Step into" },
    { "<leader>dO", function() require('dap').step_out() end, desc = "Step out" },
    { "<leader>dq", function() require('dap').terminate() end, desc = "Terminate" },
    { "<leader>du", function() require('dapui').toggle() end, desc = "Toggle DAP UI" },
    { "<leader>ex", function() require('dapui').eval() end, desc = "Eval expression", mode = "v" },
    { "<leader>ex", function()
        local expr = vim.fn.input("Expression: ")
        if expr ~= "" then
          require('dapui').eval(expr)
        end
      end, desc = "Eval expression" },
  },
  config = function()
    require('plugins.config.nvim-dap')
  end,
}

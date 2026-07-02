return {
  "linrongbin16/gitlinker.nvim",
  keys = {
    { "<leader>gl", function() require('gitlinker').link({ action = require('gitlinker.actions').system }) end,                                  mode = { "n", "v" }, desc = "Open git link in browser" },
    { "<leader>gL", function() require('gitlinker').link({ router_type = "blame", action = require('gitlinker.actions').system }) end,           mode = { "n", "v" }, desc = "Open git blame in browser" },
    { "<leader>gy", function() require('gitlinker').link() end,                                                                                  mode = { "n", "v" }, desc = "Copy git link to clipboard" },
  },
  opts = {
    router = {
      browse = {
        ["^https://.*%.visualstudio%.com"] = function(lk)
          local url = lk.remote_url:gsub("%.git$", "")
          local base_url = url .. "?path=" .. lk.file

          if lk.rev then
            base_url = base_url .. "&version=GC" .. lk.rev
          end

          if lk.lstart and lk.lend then
            if lk.lstart == lk.lend then
              base_url = base_url .. "&line=" .. lk.lstart
            else
              base_url = base_url .. "&line=" .. lk.lstart .. "&lineEnd=" .. lk.lend
            end
          end

          return base_url
        end,
        ["^https://dev%.azure%.com"] = function(lk)
          local url = lk.remote_url:gsub("%.git$", "")
          local base_url = url .. "?path=" .. lk.file

          if lk.rev then
            base_url = base_url .. "&version=GC" .. lk.rev
          end

          if lk.lstart and lk.lend then
            if lk.lstart == lk.lend then
              base_url = base_url .. "&line=" .. lk.lstart
            else
              base_url = base_url .. "&line=" .. lk.lstart .. "&lineEnd=" .. lk.lend
            end
          end

          return base_url
        end,
      },
    },
  }
}

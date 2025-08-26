local scratch = require("scratch")
scratch.setup({
  scratch_file_dir = vim.fn.stdpath("cache") .. "/scratch.nvim",     -- where your scratch files will be put
  window_cmd = "edit",                                  -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
  -- use_telescope = true,
  -- fzf-lua is recommanded, since it will order the files by modification datetime desc. (require rg)
  file_picker = "random value to enter branch that will use native select",                      -- "fzflua" | "telescope" | nil
  filetypes = { "txt", "json", "lua", "js", "sh", "ts", "http" },     -- you can simply put filetype here
  filetype_details = {                         -- or, you can have more control here
    json = {},                                 -- empty table is fine
    ["yaml"] = {},
    go = {
      requireDir = true,     -- true if each scratch file requires a new directory
      filename = "main",     -- the filename of the scratch file in the new directory
      content = { "package main", "", "func main() {", "  ", "}" },
      cursor = {
        location = { 4, 2 },
        insert_mode = true,
      },
    },
  },
  localKeys = {
    {
      filenameContains = { "sh" },
      LocalKeys = {
        {
          cmd = "<CMD>RunShellCurrentLine<CR>",
          key = "<C-r>",
          modes = { "n", "i", "v" },
        },
      },
    },
  },
  hooks = {
    {
      callback = function()
        -- vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello", "world" })
      end,
    },
  },
  filename = function(ft, directory)
      local files = vim.fn.readdir(directory)
      local max_num = 0

      for _, file in ipairs(files) do
        local num = file:match("^scratch%-(%d+)%.")
        if num then
          max_num = math.max(max_num, tonumber(num))
        end
      end

      return "scratch-" .. (max_num + 1) .. "." .. ft
    end

})

local opts = {silent = true}
vim.keymap.set("n", "<leader>nn", function() vim.cmd("Scratch") end, opts)
vim.keymap.set("n", "<leader>nf", function() vim.cmd("ScratchWithName") end, opts)
vim.keymap.set("n", "<leader>no", function() scratch.scratchOpen() end, opts)

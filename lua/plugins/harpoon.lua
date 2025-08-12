local harpoon = require("harpoon")

harpoon:setup({
  marks2 = {
    create_list_item = function(config, name)
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname == "" then
        return nil
      end

      local line_num = vim.fn.line(".")
      local col = vim.fn.col(".")

      -- Get parent directory and filename
      local parent_dir = vim.fn.fnamemodify(bufname, ":h:t")
      local filename = vim.fn.fnamemodify(bufname, ":t")

      -- Get line contents
      local line_content = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1] or ""
      line_content = line_content:gsub("^%s+", "")

      return {
        value = parent_dir .. "/" .. filename .. ":" .. line_num .. " - " .. line_content,
        context = {
          row = line_num,
          col = col,
          path = bufname,
        }
      }
    end,

    select = function(list_item, list, option)
      if list_item.value:match("^#") then
        return
      end

      if list_item.context and list_item.context.path then
        vim.cmd("edit " .. list_item.context.path)
        vim.fn.cursor(list_item.context.row, list_item.context.col)
      end
    end
  }
})

-- harpoon mappings using custom list
vim.keymap.set("n", "<leader>aa", function() harpoon:list("marks2"):add() end)
vim.keymap.set("n", "<leader>ee", function() harpoon.ui:toggle_quick_menu(harpoon:list("marks2")) end)

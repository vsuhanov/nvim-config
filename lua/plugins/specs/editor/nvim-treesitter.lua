return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    local ts = require("nvim-treesitter")

    local installed = {}
    for _, lang in ipairs(ts.get_installed("parsers")) do
      installed[lang] = true
    end

    local available = {}
    for _, lang in ipairs(ts.get_available()) do
      available[lang] = true
    end

    local function start(buf, lang)
      if installed[lang] then
        pcall(vim.treesitter.start, buf, lang)
      elseif available[lang] then
        ts.install({ lang }):await(function()
          installed[lang] = true
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) then
              pcall(vim.treesitter.start, buf, lang)
            end
          end)
        end)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("nvim_treesitter_start", { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if lang then
          start(ev.buf, lang)
        end
      end,
    })

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
        local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
        if lang then
          start(buf, lang)
        end
      end
    end

    vim.keymap.set("x", "v", function()
      vim.treesitter.select("parent")
    end, { desc = "Expand selection to parent node" })

    vim.keymap.set("x", "V", function()
      vim.treesitter.select("child")
    end, { desc = "Shrink selection to child node" })
  end,
}

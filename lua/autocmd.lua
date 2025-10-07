vim.api.nvim_create_autocmd("FileType", {
    pattern = "arduino",
    callback = function()
        vim.opt_local.commentstring = "// %s"
    end,
})

-- Define an augroup and autocmd to auto-source the init.vim file on write
local source_init_group = vim.api.nvim_create_augroup("source_init", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
    group = source_init_group,
    pattern = "init.vim",
    command = "silent! source %",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "gitrebase", "gitconfig" },
  callback = function()
    vim.bo.bufhidden = "delete"
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.j2",
  callback = function()
    vim.bo.filetype = "markdown"
  end,
})

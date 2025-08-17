-- vim.api.nvim_create_autocmd('LspAttach', {
  -- callback = function(ev)
  --   local client = vim.lsp.get_client_by_id(ev.data.client_id)
  --   -- if client:supports_method('textDocument/completion') then 
  --   --   vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
  --   --   vim.lsp.completion.enable(true, client.id, ev.buf, {autotrigger = true})
  --   --   vim.keymap.set('i', '<C-Space>', function() vim.lsp.completion.get() end)
  --   -- end
  --     -- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  --     -- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  --     -- vim.keymap.set("n", "<leader>ge", function() vim.diagnostic.goto_next() end, opts)
  --     -- vim.keymap.set("n", "<leader>gee", function() vim.diagnostic.goto_next() end, opts)
  --     -- vim.keymap.set("n", "<leader>gep", function() vim.diagnostic.goto_prev() end, opts)
  --     -- vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  --     -- vim.keymap.set("n", "<leader>fu", function() vim.lsp.buf.references() end, opts)
  --     -- vim.keymap.set("n", "<leader>rv", function() vim.lsp.buf.rename() end, opts)
  --     -- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  --     -- vim.keymap.del("n", "K")
  -- end
-- })
-- vim.lsp.set_log_level("TRACE")
vim.lsp.enable('lua_ls')
-- vim.lsp.enable('eslint')
vim.lsp.enable('ts_ls')
vim.lsp.enable('gopls')
vim.lsp.enable('jsonlsp')
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['lua_ls'].setup {
--   capabilities = capabilities
-- }


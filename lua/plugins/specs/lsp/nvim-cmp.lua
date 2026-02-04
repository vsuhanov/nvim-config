return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/vim-vsnip",
    "hrsh7th/cmp-vsnip",
  },
  opts = function()
    return {
      snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
          -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
          -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

          -- For `mini.snippets` users:
          -- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
          -- insert({ body = args.body }) -- Insert at cursor
          -- require('cmp')resubscribe({ "TextChangedI", "TextChangedP" })
          -- require("require('cmp')config").set_onetime({ sources = {} })
        end,
      },

      window = {
        -- completion = require('cmp').config.window.bordered(),
        -- documentation = require('cmp').config.window.bordered(),
      },
      mapping = require('cmp').mapping.preset.insert({
        ['<C-b>'] = require('cmp').mapping.scroll_docs(-4),
        ['<C-f>'] = require('cmp').mapping.scroll_docs(4),
        ['<C-Space>'] = require('cmp').mapping.complete(),
        ['<C-e>'] = require('cmp').mapping.abort(),
        ['<C-n>'] = require('cmp').mapping.select_next_item(),
        ['<C-p>'] = require('cmp').mapping.select_prev_item(),
        ['<CR>'] = require('cmp').mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<TAB>'] = require('cmp').mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      sorting = {
        comparators = {
          function(...) return require('cmp_buffer'):compare_locality(...) end,
          -- The rest of your comparators...
        }
      },
      sources = require('cmp').config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' }, -- For vsnip users.
        -- { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
      }, {
        {
          name = 'buffer',
          options = {
            get_bufnrs = function()
              local bufs = {}
              for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                local bufname = vim.api.nvim_buf_get_name(bufnr)
                -- Only include buffers that:
                -- 1. Are valid and loaded
                -- 2. Have a filename (not empty)
                -- 3. Have a file extension
                -- 4. Are not special buffers (no :// in name)
                if vim.api.nvim_buf_is_valid(bufnr)
                    and vim.api.nvim_buf_is_loaded(bufnr)
                    and bufname ~= ""
                    and bufname:match("%.%w+$") -- has file extension
                    and not bufname:match("://") -- not special buffer
                then
                  table.insert(bufs, bufnr)
                end
              end
              return bufs
            end
          }
        },
        { name = 'path' },
      })
    }
  end
}

-- cmp.setup.cmdline({ '/', '?' }, {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = {
--     { name = 'buffer' }
--   }
-- })

-- -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline(':', {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   }),
--   matching = { disallow_symbol_nonprefix_matching = false }
-- })

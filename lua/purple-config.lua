vim.g.mapleader = ' '

vim.cmd([[
  highlight @punctuation.bracket ctermfg=white guifg=#8c8b8b
  highlight link @punctuation.delimiter @keyword
  highlight @comment guifg=#ff9900
]])

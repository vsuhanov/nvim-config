vim.cmd[[
  " add my custom configuration
  "
  execute 'source' fnamemodify(stdpath('config') . '/config/clang-format.vim', ':p')
  execute 'source' fnamemodify(stdpath('config') . '/config/purple-coc-config.vim', ':p')

  function! OutputSplitWindow(...)
    " this function output the result of the Ex command into a split scratch buffer
    let cmd = join(a:000, ' ')
    let temp_reg = @t
    redir @t
    silent! execute cmd
    redir END
    let output = copy(@t)
    let @" = temp_reg
    if empty(output)
      echoerr "no output"
    else
      new
      setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
      put! =output
    endif
  endfunction
  command! -nargs=+ -complete=command Output call OutputSplitWindow(<f-args>)

  let mapleader = " " 
  map <leader>uu mt:s/\~\~//ge<CR>:s/-<space>✓<space>//e<CR>:s/-<space>✗<space>//e<CR>:s/-<space>☐<space>//e<CR>^i-<space>☐<space><ESC>:noh<CR>`t
  map <leader>ud mt:s/-<space>☐<space>/-<space>✓<space>\~\~/e<CR>g_a~~<ESC>:noh<CR>`tj
  map <leader>uc mt:s/-<space>☐<space>/-<space>✗<space>\~\~/e<CR>g_a~~<ESC>:noh<CR>`tj
]]

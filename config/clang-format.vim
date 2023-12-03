function! FormatClang()
  let l:lines = getline(1, '$')
  let l:formatted = system('clang-format', join(l:lines, "\n"))
  call setline(1, split(l:formatted, "\n"))
endfunction


function! SmartFormat()
  if &filetype ==# 'cpp' || &filetype ==# 'arduino' || &filetype ==# 'ino'
    call FormatClang()
  else
    exe 'normal! :Format<CR>'
  endif
endfunction

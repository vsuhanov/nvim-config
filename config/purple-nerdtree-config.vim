function! ToggleNERDTreeFind()
    " Check if NERDTree is open and visible
    if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
        " Check if NERDTree window is active
        if bufname("%") ==# t:NERDTreeBufName
            " If NERDTree is active, close it
            NERDTreeToggle
        else
            " If NERDTree is open but not active, run :NERDTreeFind
            NERDTreeFind
        endif
    else
        " If NERDTree is not visible, run :NERDTreeFind
        NERDTreeFind
    endif
endfunction

" Map the function to a key for easy access
nnoremap <silent> <F2> :call ToggleNERDTreeFind()<CR>

nnoremap <leader><leader>n :NERDTreeFocus<CR>
nnoremap <leader><leader>t :call ToggleNERDTreeFind()<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

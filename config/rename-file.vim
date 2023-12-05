function! RenameCurrentFile()
    " Save the current file name
    let s:oldfile = expand('%:p')

    " Create a new empty buffer
    enew

    " Write the current file name and full file path into the new buffer
    call setline(1, fnamemodify(s:oldfile, ':t'))
    call append(1, "# " . s:oldfile)

    " Write the buffer to /tmp/RENAME_FILE
    silent! execute 'write! /tmp/RENAME_FILE'

    " Set up an autocmd to rename the file and switch to previous buffer on BufWritePost
    augroup RenameFile
        autocmd!
        autocmd BufWritePost <buffer> call s:DoRenameFile() | execute 'bd#' | autocmd! RenameFile
    augroup END
endfunction

function! s:DoRenameFile()
    let l:newfile = readfile('/tmp/RENAME_FILE')[0]

    " Save the current directory
    let l:currentdir = getcwd()

    " Change working directory to the directory of the old file
    execute 'lcd' fnamemodify(s:oldfile, ':h')

    " Attempt to rename the file
    let l:errormsg = system('mv ' . shellescape(s:oldfile) . ' ' . shellescape(l:newfile))

    " Change working directory back to the saved directory
    execute 'lcd' l:currentdir

    " Check if the rename was successful
    if filereadable(l:newfile)
        " Close all buffers referring to the old file
        silent! execute 'bufdo if expand("%:p") == "'. s:oldfile .'" | bd | endif'
        " Open the new file for editing
        execute 'e' l:newfile

        " Display a non-obtrusive message
        echo 'File renamed successfully to' l:newfile
    else
        " Display the error message
        echo 'Error renaming file to' l:newfile
        echo 'Error message: ' . l:errormsg
    endif
endfunction

command! RenameFile :call RenameCurrentFile()

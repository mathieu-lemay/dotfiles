vim.api.nvim_exec(
    [[
" Manually set file encodings
function! SetFileEncodings(encodings) abort
    let b:fileencodingsbak=&fileencodings
    let &fileencodings=a:encodings
endfunction

" Restore previous file encodings
function! RestoreFileEncodings() abort
    let &fileencodings=b:fileencodingsbak
    unlet b:fileencodingsbak
endfunction

" Disable stuff that slow down vim when working with big files
function! DisableStuffForBigFiles() abort
    syntax off
    set nocursorline
endfunction
]],
    false
)

-- Syntaxes
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.bf",
    command = "set filetype=brainfuck",
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.asm",
    command = "set filetype=nasm",
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.tfvars",
    command = "set filetype=terraform",
})

-- Set indent / fold options for specific file types
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "python",
    command = "setlocal foldmethod=indent foldnestmax=2 foldlevelstart=99",
})
-- Make NFOs look nice
vim.api.nvim_create_autocmd({ "BufReadPre" }, {
    pattern = "*.nfo",
    command = "call SetFileEncodings('cp437')|set ambiwidth=single",
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = "*.nfo",
    command = "call RestoreFileEncodings()",
})

-- Prevent slow downs when opening files bigger than 1MiB
vim.api.nvim_create_autocmd({ "BufReadPre" }, {
    pattern = "*",
    command = 'if getfsize(expand("%")) > 1048576 | :call DisableStuffForBigFiles() | endif',
})

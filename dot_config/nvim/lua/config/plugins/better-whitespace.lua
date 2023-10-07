vim.keymap.set("n", "<leader>ws", "<cmd>StripWhitespace<CR>")

vim.g.strip_whitespace_on_save = 1
vim.g.strip_whitelines_at_eof = 1
vim.g.strip_whitespace_confirm = 0
vim.g.better_whitespace_filetypes_blacklist =
    { "diff", "git", "gitcommit", "unite", "qf", "help", "markdown", "fugitive", "toggleterm" }

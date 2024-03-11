vim.keymap.set("n", "<leader>ws", "<cmd>StripWhitespace<CR>")

vim.g.better_whitespace_filetypes_blacklist =
    { "diff", "git", "gitcommit", "unite", "qf", "help", "markdown", "fugitive", "toggleterm" }

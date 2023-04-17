vim.keymap.set("n", "<leader>fh", "<cmd>FZF ~<CR>")
vim.keymap.set("n", "<leader>f.", "<cmd>FZF<CR>")
vim.keymap.set("n", "<leader>ft", "<cmd>Tags<CR>")
vim.keymap.set("n", "<leader>fl", "<cmd>Lines<CR>")
vim.keymap.set("n", "<leader>fg", "<cmd>Rg<CR>")
vim.keymap.set("n", "<leader>fb", "<cmd>Buffers<CR>")
vim.keymap.set("n", "<leader>m", "<cmd>History<CR>")
vim.keymap.set("n", "<C-f>", "<cmd>FZF<CR>")

vim.g.fzf_layout = { window = { width = 0.85, height = 0.85 } }
--vim.g.fzf_layout = {tmux = "-p75%,75%"}

-- Match vim colorscheme
vim.g.fzf_colors = {
    ["fg"] = { "fg", "Normal" },
    ["bg"] = { "bg", "Normal" },
    ["hl"] = { "fg", "Comment" },
    ["fg+"] = { "fg", "CursorLine", "CursorColumn", "Normal" },
    ["bg+"] = { "bg", "CursorLine", "CursorColumn" },
    ["hl+"] = { "fg", "Statement" },
    ["info"] = { "fg", "PreProc" },
    ["border"] = { "fg", "Ignore" },
    ["prompt"] = { "fg", "Conditional" },
    ["pointer"] = { "fg", "Exception" },
    ["marker"] = { "fg", "Keyword" },
    ["spinner"] = { "fg", "Label" },
    ["header"] = { "fg", "Comment" },
}

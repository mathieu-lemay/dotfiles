-- Start interactive EasyAlign in visual mode (e.g. vipga)
vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
vim.keymap.set("x", "gs", "<cmd>'<,'>EasyAlign *\\ <CR>")

-- Start interactive EasyAlign for a motion/text object (e.g. gaip)
vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")

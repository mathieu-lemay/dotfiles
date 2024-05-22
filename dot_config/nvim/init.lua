require("config.plugins")
require("config.colors")
require("config.file-hooks")

-- Indent settings
local tabsize = 4
vim.opt.expandtab = true
vim.opt.tabstop = tabsize
vim.opt.softtabstop = tabsize
vim.opt.shiftwidth = tabsize
vim.opt.shiftround = true
vim.opt.autoindent = true

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
-- turn off search highlight
vim.keymap.set("n", "<leader><space>", "<cmd>nohlsearch<CR>")

-- Other settings
vim.opt.ruler = true
vim.opt.number = true
vim.opt.wrap = false
vim.opt.showcmd = true
vim.opt.cursorline = true
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full" -- Stop on ambiguity, then go through possibilities
vim.opt.modeline = true
vim.opt.scrolloff = 3
vim.opt.shortmess:append({ I = true }) -- Remove intro text
vim.opt.completeopt = "menuone,longest" -- Show menu even if one possibility and stop on ambiguity
vim.opt.mouse = "a"

-- Set to auto read when a file is changed from the outside
vim.opt.autoread = true

-- Whitespaces
vim.opt.listchars = "tab:→ ,trail:~"
vim.opt.list = true

-- Use persistent undo
vim.opt.undodir = vim.fn.expand("~/.local/state/nvim/undo")
vim.opt.undofile = true
vim.opt.undolevels = 1000 -- maximum number of changes that can be undone
vim.opt.undoreload = 10000 -- maximum number lines to save for undo on a buffer reload

-- Key remaps
vim.keymap.set({ "n", "v" }, "<tab>", "%")

-- Disable arrow keys
vim.keymap.set({ "i", "n", "v" }, "<up>", "<nop>")
vim.keymap.set({ "i", "n", "v" }, "<down>", "<nop>")
vim.keymap.set({ "i", "n", "v" }, "<left>", "<nop>")
vim.keymap.set({ "i", "n", "v" }, "<right>", "<nop>")

-- Start/End of line
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")

-- Disable going in ex mode
vim.keymap.set("", "Q", "<nop>")

-- Insert at beginning / end of selected lines
vim.keymap.set("v", "i", "<C-V>^I")
vim.keymap.set("v", "a", "<C-V>$A")

-- Cause we all do these mistakes
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("WQ", "wq", {})
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("Qa", "qa", {})
vim.api.nvim_create_user_command("QA", "qa", {})

-- Close current buffer but keep window
vim.keymap.set("n", "<leader>d", "<cmd>bp<bar>sp<bar>bn<bar>bd<CR>")

-- JSON Tidy: Reformat JSON file
vim.keymap.set("n", "<leader>jt", "<cmd>%!jq<CR>")

-- Get back to normal mode in terminal
vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>")

-- Ignore whitespaces in diff mode
vim.opt.diffopt:append("iwhite")

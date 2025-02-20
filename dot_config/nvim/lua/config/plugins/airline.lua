vim.opt.showmode = false
vim.opt.laststatus = 2

vim.g.airline_theme = "zenburn"
vim.g.airline_skip_empty_sections = 1
vim.g["airline#extensions#branch#enabled"] = 1

vim.g.airline_left_sep = ""
vim.g.airline_right_sep = ""
vim.g.airline_left_alt_sep = ">"
vim.g.airline_right_alt_sep = "<"

vim.g.airline_section_z = "%#__accent_bold#%4l/%L%#__restore__# :%3v"

-- Workaround for:
--   https://github.com/neovim/neovim/issues/31956
--   https://github.com/vim-airline/vim-airline/issues/2704
vim.g["airline#extensions#whitespace#symbol"] = '!'

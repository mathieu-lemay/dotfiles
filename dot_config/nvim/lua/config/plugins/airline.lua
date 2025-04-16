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

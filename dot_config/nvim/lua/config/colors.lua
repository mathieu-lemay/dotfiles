local nb_colors = vim.fn.system("tput colors")
nb_colors = nb_colors:gsub("%s+", "")

if nb_colors == "256" then
    require("zenburn").setup()

    comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })
    comment_hl.italic = true
    vim.api.nvim_set_hl(0, "Comment", comment_hl)
else
    vim.cmd.colorscheme("desert")
end

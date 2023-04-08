local nb_colors = vim.fn.system("tput colors")
nb_colors = nb_colors:gsub("%s+", "")

if nb_colors == "256" then
    vim.opt.termguicolors = true
    vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

    vim.g.zenburn_italic_Comment = 1
    vim.cmd.colorscheme("zenburn")
else
    vim.cmd.colorscheme("desert")
end

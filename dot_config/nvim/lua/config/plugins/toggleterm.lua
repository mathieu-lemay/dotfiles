require("toggleterm").setup({
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    direction = "float",
    env = {
        ZSH_PROMPT = "simple",
        ZSH_TMUX_AUTOSTART = "false",
    },
    float_opts = {
        border = "curved",
        width = function(term)
            return math.floor(vim.o.columns * 0.8)
        end,
        height = function(term)
            return math.floor(vim.o.lines * 0.8)
        end,
        winblend = 10,
    },
})

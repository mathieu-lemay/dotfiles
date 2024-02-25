local indent_char = "│"

require("ibl").setup({
    indent = {
        char = indent_char,
    },
    scope = {
        show_start = false,
        show_end = false,
        char = indent_char,
    },
})

hooks = require("ibl.hooks")
-- Workaround to disable the first level
-- source: https://github.com/lukas-reineke/indent-blankline.nvim/issues/824
hooks.register(hooks.type.VIRTUAL_TEXT, function(_, _, _, virt_text)
    if virt_text[1] and virt_text[1][1] == indent_char then
        virt_text[1] = { " ", { "@ibl.whitespace.char.1" } }
    end

    return virt_text
end)

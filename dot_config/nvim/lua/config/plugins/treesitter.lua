local parsers = {
    "bash",
    "dockerfile",
    "go",
    "hcl",
    "json",
    "just",
    "lua",
    "make",
    "python",
    "rust",
    "sql",
    "terraform",
    "yaml",
}

local excluded_languages = {
    "jinja",
}

-- Install parsers after startup
vim.schedule(function()
    require("nvim-treesitter").install(parsers)
end)

vim.o.foldlevelstart = 99
vim.o.foldnestmax = 2

-- on main branch, treesitter isn't started automatically
vim.api.nvim_create_autocmd({ "Filetype" }, {
    callback = function(event)
        -- make sure nvim-treesitter is loaded
        local ok, nvim_treesitter = pcall(require, "nvim-treesitter")

        -- no nvim-treesitter, maybe fresh install
        if not ok then
            return
        end

        local parsers = require("nvim-treesitter.parsers")

        if not parsers[event.match] or not nvim_treesitter.install then
            return
        end

        local ft = vim.bo[event.buf].ft
        local lang = vim.treesitter.language.get_lang(ft)

        for _, v in ipairs(excluded_languages) do
            if lang == v then
                return
            end
        end

        nvim_treesitter.install({ lang }):await(function(err)
            if err then
                vim.notify("Treesitter install error for ft: " .. ft .. " err: " .. err)
                return
            end

            pcall(vim.treesitter.start, event.buf)
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

            -- Use treesitter for folds when not in diff mode
            if not vim.opt.diff:get() then
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.wo.foldmethod = "expr"
            end
        end)
    end,
})

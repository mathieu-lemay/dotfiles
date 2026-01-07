local ts = require("nvim-treesitter")
ts.install({
    "bash",
	"dockerfile",
	"go",
	"hcl",
	"json",
	"lua",
	"python",
	"rust",
	"sql",
	"terraform",
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  desc = 'Enable treesitter highlighting and indentation',
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(event.match) or event.match
    local buf = event.buf

    -- Start highlighting immediately (works if parser exists)
    pcall(vim.treesitter.start, buf, lang)

    -- Enable treesitter indentation
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

    -- Install missing parsers (async, no-op if already installed)
    ts.install({ lang })
  end,
})

-- Use treesitter as folding method
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldlevelstart = 99
vim.o.foldnestmax = 2

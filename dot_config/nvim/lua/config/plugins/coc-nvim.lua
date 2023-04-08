vim.g.coc_global_extensions = {
    "coc-diagnostic",
    "coc-emoji",
    "coc-git",
    "coc-docker",
    "coc-json",
    "coc-pyright",
    "coc-rust-analyzer",
    "coc-sh",
    "coc-yaml",
}

-- Better display for messages
vim.opt.cmdheight = 2
-- Smaller updatetime for CursorHold & CursorHoldI
vim.opt.updatetime = 300
-- don"t give |ins-completion-menu| messages.
vim.opt.shortmess:append({ c = true })
-- always show signcolumns
vim.opt.signcolumn = "yes"

--vim.keymap.set("n", "<C-p>", "<cmd>CocCommand<CR>")
vim.keymap.set("n", "<leader>p", "<cmd>CocCommand<CR>")

-- Use `C-Up` and `C-Down` for navigate diagnostics
vim.keymap.set("n", "<C-Up>", "<Plug>(coc-diagnostic-prev)", { silent = true })
vim.keymap.set("n", "<C-Down>", "<Plug>(coc-diagnostic-next)", { silent = true })

-- Remap keys for gotos
vim.keymap.set("n", "<leader>ld", "<Plug>(coc-definition)", { silent = true })
vim.keymap.set("n", "<leader>lt", "<Plug>(coc-type-definition)", { silent = true })
vim.keymap.set("n", "<leader>li", "<Plug>(coc-implementation)", { silent = true })
vim.keymap.set("n", "<leader>lg", "<Plug>(coc-references)", { silent = true })
vim.keymap.set("n", "<leader>lf", "<Plug>(coc-format)", { silent = true })

vim.keymap.set("n", "<leader>gb", "<cmd>CocCommand git.showCommit<CR>", { silent = true })
vim.keymap.set("n", "<leader>gi", "<cmd>CocCommand git.chunkInfo<CR>", { silent = true })
vim.keymap.set("n", "<leader>gd", "<cmd>CocCommand git.diffCached<CR>", { silent = true })
vim.keymap.set("n", "<leader>ga", "<cmd>CocCommand git.chunkStage<CR>", { silent = true })
vim.keymap.set("n", "<leader>gr", "<cmd>CocCommand git.chunkUndo<CR>", { silent = true })

-- Remap for rename current word
vim.keymap.set("n", "<leader>lr", "<Plug>(coc-rename)", { silent = true })

-- Use K to show documentation in preview window
function _G.show_docs()
    local cw = vim.fn.expand("<cword>")
    if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
        vim.api.nvim_command("h " .. cw)
    elseif vim.api.nvim_eval("coc#rpc#ready()") then
        vim.fn.CocActionAsync("doHover")
    else
        vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
    end
end

vim.keymap.set("n", "K", "<CMD>lua _G.show_docs()<CR>", { silent = true })

-- Autocomplete
function _G.check_back_space()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

--" Insert <tab> when previous text is space, refresh completion if not.
local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
vim.keymap.set(
    "i",
    "<TAB>",
    'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
    opts
)
vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Use <c-space> to trigger completion
vim.keymap.set("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

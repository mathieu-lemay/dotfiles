local utils = require("config.utils")

require("neotest").setup({
    adapters = {
        require("neotest-python")({
            dap = { justMyCode = false },
        }),
        require("neotest-rust"),
    },
})

-- Run nearest test
vim.keymap.set("n", "<leader>tr", function()
    require("neotest").run.run()
end)

-- Run current file"
vim.keymap.set("n", "<leader>tf", function()
    require("neotest").run.run(vim.fn.expand("%"))
end)

-- "Run all tests"
vim.keymap.set("n", "<leader>ta", function()
    require("neotest").run.run({ suite = true })
end)

-- Run last
vim.keymap.set("n", "<leader>tt", function()
    require("neotest").run.run_last()
end)

-- Debug nearest test
vim.keymap.set("n", "<leader>td", function()
    require("neotest").run.run({ strategy = "dap" })
end)

-- Stop tests
vim.keymap.set("n", "<leader>tS", function()
    require("neotest").run.stop()
end)

-- Toggle output panel
vim.keymap.set("n", "<leader>to", function()
    require("neotest").output_panel.toggle()
    utils.focus_win("Neotest Output")
end)

-- Toggle summary
vim.keymap.set("n", "<leader>ts", function()
    require("neotest").summary.toggle()
    utils.focus_win("Neotest Summary")
end)

-- Go to Previous failed test
vim.keymap.set("n", "[t", function()
    require("neotest").jump.prev({ status = "failed" })
end)

-- Go to Next failed test
vim.keymap.set("n", "]t", function()
    require("neotest").jump.next({ status = "failed" })
end)

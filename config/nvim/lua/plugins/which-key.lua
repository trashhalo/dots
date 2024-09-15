return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    opts = {},
    dependencies = {
        "echasnovski/mini.icons"
    },
    config = function()
        local wk = require("which-key")
        wk.add({
            { "<leader>",  group = "Leader" },
            { "<leader>c", group = "Quickfix List" },
            { "<leader>j", group = "Jump" },
            { "<leader>l", group = "Location List" },
            { "<leader>n", group = "NvimTree" },
            { "<leader>s", group = "Spectre" },
            { "<leader>t", group = "Tabs" },
            { "<leader>x", group = "Trouble" },
            { "<leader>1", group = "Toggleterm" }
        })
    end,
}

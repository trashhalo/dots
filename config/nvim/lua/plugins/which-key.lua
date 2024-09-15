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
        
        -- Tab keymaps
        wk.register({
            ["<leader>t"] = {
                n = { ":tabnew<cr>", "New Tab" },
                c = { ":tabclose<cr>", "Close Tab" },
                o = { ":tabonly<cr>", "Close Other Tabs" },
            },
            ["[t"] = { ":tabprevious<cr>", "Previous Tab" },
            ["]t"] = { ":tabnext<cr>", "Next Tab" },
            ["<A-<>"] = { ":tabmove -1<cr>", "Move Tab Left" },
            ["<A->>"] = { ":tabmove +1<cr>", "Move Tab Right" },
        })
        
        -- Terminal escape keymap
        vim.api.nvim_set_keymap("t", "<esc>", "<C-\\><C-n>", {
            noremap = true,
            silent = true
        })
    end,
}

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
            { "<leader>tn", ":tabnew<cr>", desc = "New Tab" },
            { "<leader>tc", ":tabclose<cr>", desc = "Close Tab" },
            { "<leader>to", ":tabonly<cr>", desc = "Close Other Tabs" },
            { "[t", ":tabprevious<cr>", desc = "Previous Tab" },
            { "]t", ":tabnext<cr>", desc = "Next Tab" },
            { "<A-<>", ":tabmove -1<cr>", desc = "Move Tab Left" },
            { "<A->>", ":tabmove +1<cr>", desc = "Move Tab Right" },
        })
        
        -- Terminal escape keymap
        vim.api.nvim_set_keymap("t", "<esc>", "<C-\\><C-n>", {
            noremap = true,
            silent = true
        })
    end,
}

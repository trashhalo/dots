return {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
        require("toggleterm").setup {}
    end,
    keys = {
        { "<leader>11", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
    },
}

return {
    "nvim-tree/nvim-tree.lua",
    config = function()
        require("nvim-tree").setup({
            filters = {
                dotfiles = false,
            }
        })
    end,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        { "<leader>nn", "<cmd>NvimTreeToggle<cr>", desc = "Toggle Sidebar (NvimTree)" },
        { "<leader>nf", "<cmd>NvimFindFile<cr>",   desc = "Find File (NvimTree)" }
    }
}

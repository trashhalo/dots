return {
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
    },
    {
        'nvim-telescope/telescope-ui-select.nvim'
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = '0.1.4',
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
            "smartpde/telescope-recent-files",
            "folke/trouble.nvim"
        },
        config = function()
            require("telescope").setup({
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case"
                    }
                },
                defaults = {
                    mappings = {
                        i = {
                            ["<c-y>"] = require('trouble.sources.telescope').open
                        },
                        n = {
                            ["<c-y>"] = require('trouble.sources.telescope').open
                        }
                    }
                }
            })

            require('telescope').load_extension('fzf')
            require("telescope").load_extension("ui-select")
            require("telescope").load_extension("recent_files")
        end
    }
}

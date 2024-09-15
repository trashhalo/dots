return {{
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make'
}, {'nvim-telescope/telescope-ui-select.nvim'}, {
    "nvim-telescope/telescope.nvim",
    tag = '0.1.4',
    dependencies = {"nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons",
                    "smartpde/telescope-recent-files", "folke/trouble.nvim"},
    config = function()
        require("telescope").setup({
            extensions = {
                fzf = {
                    fuzzy = true, -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true, -- override the file sorter
                    case_mode = "smart_case" -- or "ignore_case" or "respect_case"
                    -- the default case_mode is "smart_case"
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

        -- To get fzf loaded and working with telescope, you need to call
        -- load_extension, somewhere after setup function:
        require('telescope').load_extension('fzf')

        -- To get ui-select loaded and working with telescope, you need to call
        -- load_extension, somewhere after setup function:
        require("telescope").load_extension("ui-select")
        require("telescope").load_extension("recent_files")
    end
}}

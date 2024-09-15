local changed_on_branch = function()
    local previewers = require("telescope.previewers")
    local pickers = require("telescope.pickers")
    local sorters = require("telescope.sorters")
    local finders = require("telescope.finders")
    pickers
        .new({}, {
            results_title = "Modified in current branch",
            finder = finders.new_oneshot_job({
                "git",
                "diff",
                "--relative",
                "--name-only",
                "--diff-filter=ACMR",
                "origin...",
            }, {}),
            sorter = sorters.get_fuzzy_file(),
            previewer = previewers.new_termopen_previewer({
                get_command = function(entry)
                    return {
                        "git",
                        "diff",
                        "--diff-filter=ACMR",
                        "origin...",
                        "--",
                        entry.value,
                    }
                end,
            }),
        })
        :find()
end

return {
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
                    case_mode = "smart_case",
                },
            },
            defaults = {
                mappings = {
                    i = { ["<c-y>"] = require('trouble.sources.telescope').open },
                    n = { ["<c-y>"] = require('trouble.sources.telescope').open },
                },
            },
        })

        require('telescope').load_extension('fzf')
        require("telescope").load_extension("ui-select")
        require("telescope").load_extension("recent_files")
    end,
    keys = {
        { "<leader>jp", function() require('telescope.builtin').find_files() end, desc = "Find Files (Telescope)" },
        { "<leader>jg", function() require('telescope.builtin').git_status() end, desc = "Git Status (Telescope)" },
        { "<leader>jk", function() require('telescope.builtin').keymaps() end, desc = "Keymaps (Telescope)" },
        { "<leader>jm", function() require('telescope.builtin').lsp_document_symbols({ symbols = { "Function", "Method", "Field", "Variable" } }) end, desc = "Document Symbols (Telescope)" },
        { "<leader>jb", changed_on_branch, desc = "Changed on Branch (Telescope)" },
        { "<leader>jc", function() require('telescope.builtin').commands() end, desc = "Commands (Telescope)" },
        { "<Leader><Leader>", "<cmd>lua require('telescope').extensions.recent_files.pick()<CR>", desc = "Recent Files (Telescope)" },
    },
}

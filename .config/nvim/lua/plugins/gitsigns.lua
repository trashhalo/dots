return {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    keys = {
        { "<leader>gj", function() require("gitsigns").next_hunk() end, desc = "Next Hunk" },
        { "<leader>gk", function() require("gitsigns").prev_hunk() end, desc = "Previous Hunk" },
        { "<leader>gs", function() require("gitsigns").stage_hunk() end, desc = "Stage Hunk" },
        { "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset Hunk" },
        { "<leader>gS", function() require("gitsigns").stage_buffer() end, desc = "Stage Buffer" },
        { "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, desc = "Undo Stage Hunk" },
        { "<leader>gR", function() require("gitsigns").reset_buffer() end, desc = "Reset Buffer" },
        { "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview Hunk" },
        { "<leader>gb", function() require("gitsigns").blame_line{full=true} end, desc = "Blame Line" },
        { "<leader>gd", function() require("gitsigns").diffthis() end, desc = "Diff This" },
        { "<leader>gD", function() require("gitsigns").toggle_deleted() end, desc = "Toggle Deleted" },
        { "<leader>gw", function() require("gitsigns").toggle_word_diff() end, desc = "Toggle Word Diff" },
        { "ih", ":<C-U>Gitsigns select_hunk<CR>", mode = {"o", "x"}, desc = "Select Hunk" },
    },
    config = function()
        require("gitsigns").setup {
            word_diff = false, -- Toggle with <leader>gw
            show_deleted = false, -- Toggle with <leader>gD
            preview_config = {
                border = 'rounded',
                style = 'minimal',
                relative = 'cursor',
                row = 0,
                col = 1
            },
        }
    end
}

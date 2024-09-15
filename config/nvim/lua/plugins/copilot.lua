return {
    "zbirenbaum/copilot.lua",
    dependencies = {"zbirenbaum/copilot-cmp"},
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
        suggestion = {
            enabled = true,
            auto_trigger = true,
            keymap = {
                accept_line = "<C-e>"
            }
        },
        panel = {
            enabled = true
        }
    },
    keys = {{
        "<leader>e",
        function()
            require("copilot.suggestion").accept()
        end,
        desc = "Accept Copilot Suggestion"
    }},
    server_opts_overrides = {
        trace = "verbose"
    },
    config = function()
    end
}

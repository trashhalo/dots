return {
  "elixir-tools/elixir-tools.nvim",
  version = "0.16.0",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")

    elixir.setup {
      nextls = { enable = false },
      credo = { enable = true },
      elixirls = {
        enable = true,
        cmd = "/Users/stephensolka/.elixir-ls/language_server.sh",
        settings = elixirls.settings {
          dialyzerEnabled = false,
          enableTestLenses = false,
        },
        on_attach = function(client, bufnr)
          vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>",
            { buffer = true, noremap = true })
          vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>",
            { buffer = true, noremap = true })
          vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>",
            { buffer = true, noremap = true })
        end,
      }
    }
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}

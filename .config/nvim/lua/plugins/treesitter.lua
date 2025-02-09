return {
	"nvim-treesitter/nvim-treesitter",
	enabled = true,
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "elixir", "eex", "heex", "lua", "markdown", "yaml", "javascript", "typescript" },
			highlight = { enable = true },
			indent = { enable = false }
		})
	end,
}

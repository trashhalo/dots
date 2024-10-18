return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = "BufRead",
	opts = {
		ensure_installed = { "elixir", "eex", "heex", "lua", "markdown", "yaml", "javascript", "typescript", "just", "css" },
		highlight = { enable = true },
		indent = { enable = true },
	}
}

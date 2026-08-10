return {
	"nvim-treesitter/nvim-treesitter-context",
	event = "BufRead",
	config = function()
		require("treesitter-context").setup({
			enable = true,
		})
	end,
	keys = {
		{ "[c", function() require("treesitter-context").go_to_context(vim.v.count1) end, silent = true, desc = "Go to previous context" },
	},
}
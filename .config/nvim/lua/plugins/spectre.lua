return {
	"nvim-pack/nvim-spectre",
	dependencies = {
		"nvim-lua/plenary.nvim"
	},
	keys = { {
		"<leader>sr",
		function()
			require("spectre").open()
		end,
		desc = "Search and Replace (Spectre)"
	}, {
		"<leader>sw",
		function()
			require("spectre").open_visual({
				select_word = true
			})
		end,
		"n",
		desc = "Search current word (Spectre)"
	}, {
		"<leader>sw",
		function()
			require("spectre").open_visual({
				select_word = true
			})
		end,
		"v",
		desc = "Search current word (Spectre)"
	} }
}

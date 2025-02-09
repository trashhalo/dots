return {
	'echasnovski/mini.ai',
	version = false,
	config = function()
		local miniai = require('mini.ai')
		local spec_treesitter = miniai.gen_spec.treesitter
		miniai.setup({
			n_lines = 500,
			custom_textobjects = {
				o = spec_treesitter({
					a = { "@block.outer", "@conditional.outer", "@loop.outer" },
					i = { "@block.inner", "@conditional.inner", "@loop.inner" },
				}, {}),
				f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
				c = spec_treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
			},
		})
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects"
	}
}

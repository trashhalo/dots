return {
	"nvim-treesitter/nvim-treesitter",
	enabled = true,
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "elixir", "eex", "heex", "lua", "markdown", "yaml", "javascript", "typescript" },
			highlight = { enable = true },
			indent = { enable = false },
			textobjects = {
				select = {
					enable = true,
					lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
					keymaps = {
						-- You can use the capture groups defined in textobjects.scm
						['aa'] = { query = '@parameter.outer', desc = "Select a parameter" },
						['ia'] = { query = '@parameter.inner', desc = "Select inner parameter" },
						['af'] = { query = '@function.outer', desc = "Select a function" },
						['if'] = { query = '@function.inner', desc = "Select inner function" },
						['ac'] = { query = '@class.outer', desc = "Select a class" },
						['ic'] = { query = '@class.inner', desc = "Select inner class" },
						["iB"] = { query = "@block.inner", desc = "Select inner block" },
						["aB"] = { query = "@block.outer", desc = "Select a block" },
					},
				},
				move = {
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
					goto_next_start = {
						[']]'] = { query = '@function.outer', desc = "Function start" },
					},
					goto_next_end = {
						[']['] = { query = '@function.outer', desc = "Function end" },
					},
					goto_previous_start = {
						['[['] = { query = '@function.outer', desc = "Function start" },
					},
					goto_previous_end = {
						['[]'] = { query = '@function.outer', desc = "Function end" },
					},
				}
			}
		})
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
		"nvim-treesitter/nvim-treesitter-refactor"
	},
}


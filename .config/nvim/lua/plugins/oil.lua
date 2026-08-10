return {
	'stevearc/oil.nvim',
	opts = {},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open Oil" },
	},
	config = function()
		require("oil").setup({
			default_file_explorer = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = false,
				natural_order = true,
				is_always_hidden = function(name, _)
					return name == ".." or name == ".git"
				end,
				is_hidden_file = function(name, bufnr)
					if vim.startswith(name, ".") then
						return true
					end
					local dir = require("oil").get_current_dir(bufnr)
					if not dir then
						return false
					end
					vim.fn.system({ "git", "-C", dir, "check-ignore", "--quiet", name })
					return vim.v.shell_error == 0
				end,
			},
			float = {
				padding = 2,
				max_width = 90,
				max_height = 0,
			},
			win_options = {
				wrap = true,
				winblend = 0,
			},
			columns = {
				"icon",
			},
		})
	end,
}

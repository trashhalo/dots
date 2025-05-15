return {
	'stevearc/oil.nvim',
	opts = {},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open Oil" },
	},
	config = function()
		local oil = require("oil")
		oil.setup({
			default_file_explorer = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
				natural_order = true,
				is_always_hidden = function(name, _)
					return name == ".." or name == ".git"
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
			keymaps = {
				["<C-c>"] = false,
				["q"] = "actions.close",
				["<CR>"] = "actions.select",

				-- File operations
				["<localleader>y"] = "actions.yank_entry",
				["<localleader>p"] = "actions.open_external",

				-- Navigation
				["<localleader>h"] = "actions.parent",
				["<localleader>t"] = { "actions.select", opts = { tab = true } },
				["<localleader>s"] = { "actions.select", opts = { vertical = true } },
				["<localleader>i"] = { "actions.select", opts = { horizontal = true } },

				-- Preview
				["<localleader>v"] = "actions.preview",
				["<localleader>j"] = "actions.preview_scroll_down",
				["<localleader>k"] = "actions.preview_scroll_up",

				-- Directory operations
				["<localleader>cd"] = "actions.cd",
				["<localleader>cw"] = { "actions.cd", opts = { scope = "win" } },
				["<localleader>ct"] = { "actions.cd", opts = { scope = "tab" } },

				-- Working with quickfix list
				["<localleader>q"] = "actions.send_to_qflist",
				["<localleader>qa"] = {
					"actions.send_to_qflist",
					opts = { action = "a" }
				},
				["<localleader>qs"] = {
					"actions.send_to_qflist",
					opts = { only_matching_search = true }
				},

				-- Working with location list
				["<localleader>l"] = {
					"actions.send_to_qflist",
					opts = { target = "loclist" }
				},

				-- Toggle features
				["<localleader>."] = "actions.toggle_hidden",
				["<localleader>\\"] = "actions.toggle_trash",

				-- Command-line integration
				["<localleader>:"] = {
					"actions.open_cmdline",
					opts = { shorten_path = true }
				},
				["<localleader>;"] = {
					"actions.open_cmdline",
					opts = { shorten_path = true, modify = ":h" }
				},

				-- Terminal in current directory
				["<localleader>T"] = "actions.open_terminal",

				-- Sorting and display
				["<localleader>gs"] = "actions.change_sort",
				["<localleader>g?"] = "actions.show_help",
			},
			-- Add columns for more information
			columns = {
				"icon",
			},
		})

		-- You could also add custom commands like:
		vim.api.nvim_create_user_command("OilFloat", function()
			require("oil").toggle_float()
		end, {})
	end,
}

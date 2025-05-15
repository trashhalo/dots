-- In your lazy.nvim plugins file (e.g., lua/plugins/octo.lua)
return {
	"pwntester/octo.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("octo").setup({
			use_local_fs = false, -- use local files on right side of reviews
			enable_builtin = false, -- enable builtin filters
			default_to_project_review = false, -- show project reviews by default
			default_remote = { "upstream", "origin" }, -- order to try remotes
			ssh_aliases = {}, -- SSH aliases. e.g. `ssh_aliases = {["github.com-work"] = "github.com"}`
			reaction_viewer_hint_icon = "", -- marker for user reactions
			user_icon = " ", -- user icon
			timeline_marker = "", -- timeline marker
			timeline_indent = "2", -- timeline indentation
			right_bubble_delimiter = "", -- bubble delimiter
			left_bubble_delimiter = "", -- bubble delimiter
			github_hostname = "", -- GitHub Enterprise host
			snippet_context_lines = 4, -- number or lines around commented lines
			file_panel = {
				size = 10, -- changed files panel rows
				use_icons = true -- use web-devicons in file panel
			},
			comment_icon = "▎", -- comment marker
			outdated_icon = "󰅒 ", -- outdated indicator
			resolved_icon = " ", -- resolved indicator
			virtual_text = true, -- show virtual text for PRs by default (toggle with <leader>gc)
			mapping = {
				pull_request = {
					-- Toggle showing PR comments as virtual text
					toggle_virtual_text = "<localleader>gc",
					-- Resolve/unresolve PR comment under the cursor
					resolve_comment = "<localleader>gr"
				},
				review_diff = {
					-- Toggle showing PR comments as virtual text in diff view
					toggle_virtual_text = "<localleader>gc",
					-- Resolve/unresolve PR comment under the cursor in diff view
					resolve_comment = "<localleader>gr"
				}
			}
		})
	end,
	-- Load only when needed - when working with GitHub PRs/issues
	cmd = { "Octo" },
	keys = {
		-- Add a mapping to open a PR
		{ "<leader>go", "<cmd>Octo pr list<CR>",     desc = "List PRs" },
		-- Open current PR
		{ "<leader>gp", "<cmd>Octo pr current<CR>",  desc = "Current PR" },
		-- Add comment on current line
		{ "<leader>ga", "<cmd>Octo comment add<CR>", desc = "Add comment" },
	}
}

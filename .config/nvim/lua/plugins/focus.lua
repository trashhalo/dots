return {
	{
		"nvim-focus/focus.nvim",
		version = "*",
		keys = {
			{ "<leader>oa", "<cmd>FocusToggle<CR>", desc = "Toggle Focus Accordion" },
		},
		opts = {
			enable = true,
			commands = true,
			autoresize = {
				enable = true,
				width = 0,
				height = 0,
				minwidth = 200,
				minheight = 200,
			},
			ui = {
				number = false,
				relativenumber = false,
				hybridnumber = false,
				cursorline = true,
			}
		},
	},
}

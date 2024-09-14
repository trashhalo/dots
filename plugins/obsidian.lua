return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	event = {
		"BufReadPre " .. vim.fn.expand("~") .. "/Documents/New beginnings Aug 23/*",
		"BufReadPre " .. vim.fn.expand("~") .. "/Documents/PARA/*",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"hrsh7th/nvim-cmp"
	},
	opts = {
		workspaces = {
			{
				name = "personal",
				path = "~/Documents/New beginnings Aug 23"
			},
			{
				name = "work",
				path = "~/Documents/PARA"
			},
		},
	},
	init = function()
		vim.opt.conceallevel = 1
	end,
}

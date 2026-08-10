return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = true,
	},
	{
		"pittcat/claude-fzf.nvim",
		dependencies = {
			"coder/claudecode.nvim",
			"ibhagwan/fzf-lua",
		},
		cmd = "ClaudeFzf",
		keys = {
			{ "<leader>cf", "<cmd>ClaudeFzf files<cr>", desc = "Claude: add files (fzf)" },
			{ "<leader>cB", "<cmd>ClaudeFzf buffers<cr>", desc = "Claude: add buffers (fzf)" },
			{ "<leader>cg", "<cmd>ClaudeFzf grep<cr>", desc = "Claude: grep → add (fzf)" },
			{ "<leader>cG", "<cmd>ClaudeFzf git<cr>", desc = "Claude: add git files (fzf)" },
		},
		opts = {},
	},
	{
		"pittcat/claude-fzf-history.nvim",
		dependencies = {
			"pittcat/claude-fzf.nvim",
			"ibhagwan/fzf-lua",
		},
		cmd = "ClaudeFzfHistory",
		keys = {
			{ "<leader>ch", "<cmd>ClaudeFzfHistory<cr>", desc = "Claude: history (fzf)" },
		},
		opts = {},
	},
}
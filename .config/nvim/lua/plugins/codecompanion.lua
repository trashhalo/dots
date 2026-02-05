return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("codecompanion").setup({
			log = {
				level = "DEBUG",
			},
			strategies = {
				chat = {
					adapter = "claude_code",
				},
				inline = {
					adapter = "anthropic",
					model = "claude-sonnet-4-0",
				},
				cmd = {
					adapter = "anthropic",
					model = "claude-sonnet-4-0",
				},
			},
			adapters = {
				acp = {
					claude_code = function()
						return require("codecompanion.adapters").extend("claude_code", {
							env = {
								CLAUDE_CODE_OAUTH_TOKEN = vim.env
								    .CLAUDE_CODE_OAUTH_TOKEN,
							},
						})
					end,
				},
				http = {
					anthropic = function()
						return require("codecompanion.adapters").extend("anthropic", {
							env = {
								api_key = vim.env.ANTHROPIC_API_KEY,
							},
						})
					end,
				},
			},
			display = {
				action_palette = {
					provider = "default", -- or "telescope", "mini_pick", "snacks"
				},
			},
		})

		-- Keymaps
		vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
		vim.keymap.set({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>",
			{ noremap = true, silent = true })
		vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

		-- Expand 'cc' into 'CodeCompanion' in the command line
		vim.cmd([[cab cc CodeCompanion]])
	end,
}

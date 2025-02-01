return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "auto",
				background = {
					light = "latte",
					dark = "mocha",
				},
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					treesitter = true,
					notify = false,
					mini = {
						enabled = true,
					},
				},
				color_overrides = {
					mocha = {
						base = "#000000",
						text = "#FFFFFF",
						surface0 = "#1E1E2E"
					},
					latte = {
						base = "#FFFFFF",
						text = "#000000",
						surface2 = "#303030",
						overlay2 = "#383838",
						subtext1 = "#1C1C1C",
						blue = "#2B4BBF",
						lavender = "#735C9F",
						sky = "#3B668F",
						sapphire = "#2D5A8A"
					},
				},
				highlight_overrides = {
					all = function(colors)
						return {
							MiniPickMatchCurrent = { bg = colors.surface1 },
						}
					end,
				},
			})
			vim.cmd.colorscheme "catppuccin"
		end
	},
	{
		"f-person/auto-dark-mode.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			update_interval = 1000,
			set_dark_mode = function()
				vim.api.nvim_set_option_value("background", "dark", {})
				vim.cmd.colorscheme 'catppuccin'
			end,
			set_light_mode = function()
				vim.api.nvim_set_option_value("background", "light", {})
				vim.cmd.colorscheme 'catppuccin'
			end,
		},
	}
}

-- Align nvim's built-in terminal ANSI palette (`:terminal` buffers, including
-- the CC terminal) with the active colorscheme. Dark = everforest hard;
-- light = sunnyday. Called from the auto-dark-mode toggle below so terminal
-- colors flip with the system appearance.
function _G.apply_terminal_palette(theme)
	local palette
	if theme == "light" then
		-- sunnyday: high-contrast black-on-white with vivid accent tones.
		palette = {
			[0]  = "#FFFFFF", -- black  (treated as bg)
			[1]  = "#8B0000", -- red
			[2]  = "#006400", -- green
			[3]  = "#FF8C00", -- yellow (orange fits sunnyday's palette better)
			[4]  = "#000080", -- blue   (navy)
			[5]  = "#4B0082", -- magenta (purple)
			[6]  = "#008B8B", -- cyan
			[7]  = "#000000", -- white  (treated as fg)
			[8]  = "#555555", -- bright black (dark_gray)
			[9]  = "#FF0000", -- bright red
			[10] = "#32CD32", -- bright green (light_green)
			[11] = "#FFD700", -- bright yellow (gold)
			[12] = "#0000CD", -- bright blue
			[13] = "#800080", -- bright magenta
			[14] = "#008080", -- bright cyan (teal)
			[15] = "#000000", -- bright white (fg)
		}
	else
		-- everforest hard dark: muted, warm foreground on cool bg.
		palette = {
			[0]  = "#272e33", -- black  (bg0)
			[1]  = "#e67e80", -- red
			[2]  = "#a7c080", -- green
			[3]  = "#dbbc7f", -- yellow
			[4]  = "#7fbbb3", -- blue
			[5]  = "#d699b6", -- magenta (purple)
			[6]  = "#83c092", -- cyan    (aqua)
			[7]  = "#d3c6aa", -- white   (fg)
			[8]  = "#7a8478", -- bright black (grey0)
			[9]  = "#e67e80", -- bright red
			[10] = "#a7c080", -- bright green
			[11] = "#e69875", -- bright yellow (orange)
			[12] = "#7fbbb3", -- bright blue
			[13] = "#d699b6", -- bright magenta
			[14] = "#83c092", -- bright cyan
			[15] = "#d3c6aa", -- bright white (fg)
		}
	end
	for i = 0, 15 do
		vim.g["terminal_color_" .. i] = palette[i]
	end
end

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"neanias/everforest-nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("everforest").setup({
				background = "hard",
				ui_contrast = "high",
				italics = false,
				disable_italic_comments = true,
			})
		end
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
		dependencies = {
			"navarasu/onedark.nvim",
		},
		opts = {
			update_interval = 1000,
			set_dark_mode = function()
				vim.api.nvim_set_option_value("background", "dark", {})
				vim.cmd.colorscheme 'everforest'
				apply_terminal_palette("dark")
			end,
			set_light_mode = function()
				vim.api.nvim_set_option_value("background", "light", {})
				vim.cmd.colorscheme 'sunnyday'
				apply_terminal_palette("light")
			end,
		},
		fallback = "dark",
	}
}

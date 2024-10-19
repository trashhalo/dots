return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	init = function()
		vim.opt.background = "dark"
		vim.cmd([[colorscheme catppuccin-mocha]])
	end

}

return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {},
	-- stylua: ignore
	keys = {
		{ "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
		{ "enter", mode = { "n" },           function() require("flash").jump() end,              desc = "Flash Alt" },
		{ "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
		{ "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
		{ "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
		{ "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
	},
	config = function()
		vim.api.nvim_set_hl(0, "FlashLabel", { bg = "#000000", fg = "#ffffff" })
	end
}

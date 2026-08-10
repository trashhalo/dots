return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {},
	-- Apply PR #419 fix for E31 error during remote yank with mini.clue.
	-- Drop this once https://github.com/folke/flash.nvim/pull/419 merges.
	build = "git apply --3way " .. vim.fn.stdpath("config") .. "/patches/flash-pr419.patch || true",
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

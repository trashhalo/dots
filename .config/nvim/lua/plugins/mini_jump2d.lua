return {
	'echasnovski/mini.jump2d',
	version = false,
	event = "VeryLazy",
	config = function()
		require("mini.jump2d").setup()
	end,
	keys = {
		{ "s",    mode = { "n", "x", "o" }, function() require("mini.jump2d").start() end, desc = "Jump" },
		{ "<CR>", mode = { "n", "x", "o" }, function() require("mini.jump2d").start() end, desc = "Jump (Enter)" }
	}
}

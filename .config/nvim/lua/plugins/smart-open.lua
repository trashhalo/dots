local show_smart_open = function()
	require("telescope").extensions.smart_open.smart_open {
		cwd_only = true
	}
end

return {
	"danielfalk/smart-open.nvim",
	branch = "0.2.x",
	config = function()
		require("telescope").load_extension("smart_open")
	end,
	dependencies = {
		"kkharji/sqlite.lua",
		-- Only required if using match_algorithm fzf
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		-- Optional.  If installed, native fzy will be used when match_algorithm is fzy
		{ "nvim-telescope/telescope-fzy-native.nvim" },
	},
	keys = {
		{ "<leader>js", show_smart_open, desc = "Smart Open (Telescope)" },
		{ "<d-p>",      show_smart_open, desc = "Smart Open (Telescope)" },
	},
}

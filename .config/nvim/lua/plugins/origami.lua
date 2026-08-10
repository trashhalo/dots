return {
	"chrisgrieser/nvim-origami",
	event = "BufReadPost", -- later or on keypress would prevent saving folds
	keys = {
		{
			"zm",
			"zM",
			desc = "Close all folds",
			remap = true,
		},
		{
			"zr",
			"zR",
			desc = "Open all folds",
			remap = true,
		},
		{
			"z0",
			":set foldlevel=0<CR>",
			desc = "Close L0 Folds",
		},
		{
			"z1",
			":set foldlevel=1<CR>",
			desc = "Close L1 Folds",
		},
		{
			"z2",
			":set foldlevel=2<CR>",
			desc = "Close L2 Folds",
		},
		{
			"z3",
			":set foldlevel=3<CR>",
			desc = "Close L3 Folds",
		},
		{
			"z4",
			":set foldlevel=4<CR>",
			desc = "Close L4 Folds",
		},
	},
	opts = {
		foldKeymaps = {
			setup = true, -- enables h, l, $ keymaps
		},
	},
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
	end,
}

return {
	'kevinhwang91/nvim-ufo',
	dependencies = 'kevinhwang91/promise-async',
	event = 'BufReadPost', -- needed for folds to load in time
	keys = {
		{
			'zr',
			function()
				require('ufo').openFoldsExceptKinds({ 'imports', 'comment' })
			end,
			desc = ' 󱃄 Open All Folds except comments',
		},
		{
			'zm',
			function()
				require('ufo').closeAllFolds()
			end,
			desc = ' 󱃄 Close All Folds',
		},
		{
			'z1',
			function()
				require('ufo').closeFoldsWith(1)
			end,
			desc = ' 󱃄 Close L1 Folds',
		},
		{
			'z2',
			function()
				require('ufo').closeFoldsWith(2)
			end,
			desc = ' 󱃄 Close L2 Folds',
		},
		{
			'z3',
			function()
				require('ufo').closeFoldsWith(3)
			end,
			desc = ' 󱃄 Close L3 Folds',
		},
		{
			'z4',
			function()
				require('ufo').closeFoldsWith(4)
			end,
			desc = ' 󱃄 Close L4 Folds',
		},
	},
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
	end,
	opts = {
		provider_selector = function(_, ft, _)
			local lspWithOutFolding = { 'markdown', 'sh', 'css', 'html', 'python' }
			if vim.tbl_contains(lspWithOutFolding, ft) then
				return { 'treesitter', 'indent' }
			end
			return { 'lsp', 'indent' }
		end,
		open_fold_hl_timeout = 800,
	},
}

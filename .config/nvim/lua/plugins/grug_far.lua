return {
	'MagicDuck/grug-far.nvim',
	---@module 'grug-far'
	---@type GrugFarOptions
	opts = {
		startInInsertMode = false,
		openTargetWindow = {
			preferredLocation = 'right',
		}
	},
	keys = function()
		local grug_far = require('grug-far')
		return {
			{
				"<leader>sa",
				function()
					grug_far.open({ engine = 'astgrep' })
				end,
				desc = "Search AST (grug-far)"
			},
			{
				"<leader>sw",
				function()
					grug_far.open({ prefills = { search = vim.fn.expand("<cword>") } })
				end,
				desc = "Search current word (grug-far)"
			},
			{
				"<leader>sf",
				function()
					grug_far.with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
				end,
				desc = "Search current word (grug-far)"
			},
			{
				"<leader>sr",
				function()
					grug_far.open()
				end,
				desc = "Search (grug-far)"
			}
		}
	end
}

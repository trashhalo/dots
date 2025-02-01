return {
	'echasnovski/mini.clue',
	version = false,
	config = function()
		local miniclue = require('mini.clue')
		miniclue.setup({
			triggers = {
				-- Leader trigger
				{ mode = 'n', keys = '<Leader>' },
				{ mode = 'x', keys = '<Leader>' },
				-- Tab navigation triggers
				{ mode = 'n', keys = '[' },
				{ mode = 'n', keys = ']' },
				-- Misc triggers
				{ mode = 'n', keys = 'g' },
				{ mode = 'n', keys = 'z' },
			},
			clues = {
				-- Leader key groups
				{ mode = 'n',          keys = '<Leader>',   desc = '+Leader' },
				{ mode = 'n',          keys = '<Leader>c',  desc = '+Quickfix List' },
				{ mode = 'n',          keys = '<Leader>g',  desc = '+Git' },
				{ mode = 'n',          keys = '<Leader>j',  desc = '+Jump' },
				{ mode = 'n',          keys = '<Leader>l',  desc = '+Location List' },
				{ mode = 'n',          keys = '<Leader>s',  desc = '+Spectre' },
				{ mode = 'n',          keys = '<Leader>t',  desc = '+Tabs' },
				{ mode = 'n',          keys = '<Leader>x',  desc = '+Diagnostics' },
				{ mode = 'n',          keys = '<Leader>w',  desc = '+Treewalker' },
				{ mode = 'n',          keys = 'z',          desc = '+Ufo' },

				-- Existing tab-related clues
				{ mode = 'n',          keys = '<Leader>tn', desc = 'New Tab' },
				{ mode = 'n',          keys = '<Leader>tc', desc = 'Close Tab' },
				{ mode = 'n',          keys = '<Leader>to', desc = 'Close Other Tabs' },
				{ mode = 'n',          keys = '[t',         desc = 'Previous Tab' },
				{ mode = 'n',          keys = ']t',         desc = 'Next Tab' },
				{ mode = 'n',          keys = '<A-<>',      desc = 'Move Tab Left' },
				{ mode = 'n',          keys = '<A->>',      desc = 'Move Tab Right' },

				-- Git submode clues with postkeys
				{ mode = 'n',          keys = '<Leader>gj', postkeys = '<Leader>g',   desc = 'Next Hunk' },
				{ mode = 'n',          keys = '<Leader>gk', postkeys = '<Leader>g',   desc = 'Previous Hunk' },
				{ mode = 'n',          keys = '<Leader>gs', postkeys = '<Leader>g',   desc = 'Stage Hunk' },
				{ mode = 'n',          keys = '<Leader>gr', postkeys = '<Leader>g',   desc = 'Reset Hunk' },
				{ mode = 'n',          keys = '<Leader>gS', postkeys = '<Leader>g',   desc = 'Stage Buffer' },
				{ mode = 'n',          keys = '<Leader>gu', postkeys = '<Leader>g',   desc = 'Undo Stage Hunk' },
				{ mode = 'n',          keys = '<Leader>gR', postkeys = '<Leader>g',   desc = 'Reset Buffer' },
				{ mode = 'n',          keys = '<Leader>gp', postkeys = '<Leader>g',   desc = 'Preview Hunk' },
				{ mode = 'n',          keys = '<Leader>gb', postkeys = '<Leader>g',   desc = 'Blame Line' },
				{ mode = 'n',          keys = '<Leader>gd', postkeys = '<Leader>g',   desc = 'Diff This' },
				{ mode = 'n',          keys = '<Leader>gD', postkeys = '<Leader>g',   desc = 'Toggle Deleted' },
				{ mode = 'n',          keys = '<Leader>gw', postkeys = '<Leader>g',   desc = 'Toggle Word Diff' },
				{ mode = { 'o', 'x' }, keys = 'ih',         desc = 'Select Hunk' },

				-- Treewalker navigation with postkeys to stay in submode
				{ mode = 'n',          keys = '<Leader>wj', postkeys = '<Leader>w',   desc = 'Down' },
				{ mode = 'n',          keys = '<Leader>wk', postkeys = '<Leader>w',   desc = 'Up' },
				{ mode = 'n',          keys = '<Leader>wh', postkeys = '<Leader>w',   desc = 'Left' },
				{ mode = 'n',          keys = '<Leader>wl', postkeys = '<Leader>w',   desc = 'Right' }
			},
			window = {
				config = {
					width = 'auto',
					anchor = 'SW',
					col = 0
				},
				delay = 0
			},
		})
	end,
	dependencies = {
		'echasnovski/mini.icons',
		'dlants/magenta.nvim'
	}
}

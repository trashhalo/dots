local g_clues = {
	{ mode = 'n', keys = 'gg', desc = 'Go to top' },
	{ mode = 'n', keys = 'gi', desc = 'Last insert position' },
	{ mode = 'n', keys = 'gd', desc = 'Go to definition' },
	{ mode = 'n', keys = 'gf', desc = 'Go to file under cursor' },
	{ mode = 'n', keys = 'gt', desc = 'Next tab' },
	{ mode = 'n', keys = 'gT', desc = 'Previous tab' },
	{ mode = 'n', keys = 'gJ', desc = 'Join lines without space' },
	{ mode = 'n', keys = 'gq', desc = 'Format text' },
	{ mode = 'n', keys = 'gv', desc = 'Reselect last visual' },
	{ mode = 'n', keys = "g'", desc = '+Jump to mark (no jumplist)' },
	{ mode = 'n', keys = 'g`', desc = '+Jump to mark exact position (no jumplist)' },

	-- Visual mode
	{ mode = 'x', keys = 'gq', desc = 'Format selection' },
}

-- Practical z commands focusing on folds and scrolling
local z_clues = {
	-- Folds
	{ mode = 'n', keys = 'za', desc = 'Toggle fold' },
	{ mode = 'n', keys = 'zc', desc = 'Close fold' },
	{ mode = 'n', keys = 'zo', desc = 'Open fold' },
	{ mode = 'n', keys = 'zM', desc = 'Close all folds' },
	{ mode = 'n', keys = 'zR', desc = 'Open all folds' },

	-- Scrolling/Views
	{ mode = 'n', keys = 'zt', desc = 'Current line to top' },
	{ mode = 'n', keys = 'zz', desc = 'Current line to center' },
	{ mode = 'n', keys = 'zb', desc = 'Current line to bottom' },
}

local c_clues = {
	-- Group descriptions
	{ mode = 'n', keys = 'ci',  desc = '+Change inner text object' },
	{ mode = 'n', keys = 'ca',  desc = '+Change around text object' },

	-- Treesitter objects (from mini.ai)
	{ mode = 'n', keys = 'cif', desc = 'Change inner function' },
	{ mode = 'n', keys = 'caf', desc = 'Change around function' },
	{ mode = 'n', keys = 'cic', desc = 'Change inner class' },
	{ mode = 'n', keys = 'cac', desc = 'Change around class' },
	{ mode = 'n', keys = 'cio', desc = 'Change inner block/conditional/loop' },
	{ mode = 'n', keys = 'cao', desc = 'Change around block/conditional/loop' },

	-- Common text objects
	{ mode = 'n', keys = 'ciw', desc = 'Change inner word' },
	{ mode = 'n', keys = 'ci"', desc = 'Change inside quotes' },
	{ mode = 'n', keys = "ci'", desc = 'Change inside single quotes' },
	{ mode = 'n', keys = 'ci(', desc = 'Change inside parentheses' },
	{ mode = 'n', keys = 'ci{', desc = 'Change inside braces' },
	{ mode = 'n', keys = 'ci[', desc = 'Change inside brackets' },
	{ mode = 'n', keys = 'cit', desc = 'Change inside tags' },

	{ mode = 'n', keys = 'caw', desc = 'Change around word' },
	{ mode = 'n', keys = 'ca"', desc = 'Change around quotes' },
	{ mode = 'n', keys = "ca'", desc = 'Change around single quotes' },
	{ mode = 'n', keys = 'ca(', desc = 'Change around parentheses' },
	{ mode = 'n', keys = 'ca{', desc = 'Change around braces' },
	{ mode = 'n', keys = 'ca[', desc = 'Change around brackets' },
	{ mode = 'n', keys = 'cat', desc = 'Change around tags' },

	-- Line operations
	{ mode = 'n', keys = 'cc',  desc = 'Change entire line' },
	{ mode = 'n', keys = 'C',   desc = 'Change to end of line' },

	-- Movement based
	{ mode = 'n', keys = 'cw',  desc = 'Change to next word' },
	{ mode = 'n', keys = 'ce',  desc = 'Change to end of word' },
	{ mode = 'n', keys = 'c$',  desc = 'Change to end of line' },
}

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
				{ mode = 'n', keys = 'g' }, -- goto/global commands
				{ mode = 'n', keys = 'z' }, -- fold/view commands
				{ mode = 'n', keys = 'c' }, -- change commands
				{ mode = 'n', keys = 'd' }, -- delete commands
				{ mode = 'n', keys = 'y' }, -- yank commands
				{ mode = 'n', keys = ']' }, -- next item navigation
				{ mode = 'n', keys = '[' }, -- previous item navigation
				{ mode = 'n', keys = '<C-w>' }, -- window commands
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
				{ mode = 'n',          keys = '<Leader>f',  desc = '+Format' },

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
				{ mode = 'n',          keys = '<Leader>gR', postkeys = '<Leader>g',   desc = 'Reset Buffer' },
				{ mode = 'n',          keys = '<Leader>gp', postkeys = '<Leader>g',   desc = 'Preview Hunk' },
				{ mode = 'n',          keys = '<Leader>gi', postkeys = '<Leader>g',   desc = 'Preview Hunk Inline' },
				{ mode = 'n',          keys = '<Leader>gb', postkeys = '<Leader>g',   desc = 'Blame Line' },
				{ mode = 'n',          keys = '<Leader>gd', postkeys = '<Leader>g',   desc = 'Diff This' },
				{ mode = 'n',          keys = '<Leader>gw', postkeys = '<Leader>g',   desc = 'Toggle Word Diff' },
				{ mode = { 'o', 'x' }, keys = 'ih',         desc = 'Select Hunk' },

				-- Treewalker navigation with postkeys to stay in submode
				{ mode = 'n',          keys = '<Leader>wj', postkeys = '<Leader>w',   desc = 'Down' },
				{ mode = 'n',          keys = '<Leader>wk', postkeys = '<Leader>w',   desc = 'Up' },
				{ mode = 'n',          keys = '<Leader>wh', postkeys = '<Leader>w',   desc = 'Left' },
				{ mode = 'n',          keys = '<Leader>wl', postkeys = '<Leader>w',   desc = 'Right' },
				g_clues,
				z_clues,
				c_clues,
				miniclue.gen_clues.marks(),
				miniclue.gen_clues.registers(),
				miniclue.gen_clues.windows(),
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

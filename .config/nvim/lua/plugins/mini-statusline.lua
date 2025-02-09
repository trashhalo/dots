return {
	'echasnovski/mini.statusline',
	version = false,
	config = function()
		MiniStatusline = require('mini.statusline')
		MiniStatusline.setup({
			content = {
				active = function()
					local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
					local git = MiniStatusline.section_git({ trunc_width = 90 })
					local diagnostics = MiniStatusline.section_diagnostics({
						trunc_width = 75,
						signs = { ERROR = '✘', WARN = '▲', INFO = '⚑', HINT = '⚐' }
					})
					local filename = MiniStatusline.section_filename({ trunc_width = 140 })
					local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
					local location = MiniStatusline.section_location({ trunc_width = 75 })
					local lsp = MiniStatusline.section_lsp({
						trunc_width = 75,
						icon = '󰒋'
					})
					local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

					return MiniStatusline.combine_groups({
						{ hl = mode_hl,                 strings = { mode } },
						{ hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics, lsp } },
						'%<', -- Mark general truncate point
						{ hl = 'MiniStatuslineFilename', strings = { filename } },
						'%=', -- End left alignment
						{ hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
						{ hl = mode_hl,                  strings = { search, location } },
					})
				end,
				inactive = function()
					local filename = MiniStatusline.section_filename({ trunc_width = 140 })
					return MiniStatusline.combine_groups({
						{ hl = 'MiniStatuslineInactive', strings = { filename } },
					})
				end,
			},
			use_icons = true,
			set_vim_settings = true,
		})

		-- Custom highlight colors that work well with Catppuccin
		vim.cmd([[
            highlight MiniStatuslineModeNormal guibg=#89b4fa guifg=#1e1e2e
            highlight MiniStatuslineModeInsert guibg=#a6e3a1 guifg=#1e1e2e
            highlight MiniStatuslineModeVisual guibg=#f5c2e7 guifg=#1e1e2e
            highlight MiniStatuslineModeReplace guibg=#f38ba8 guifg=#1e1e2e
            highlight MiniStatuslineModeCommand guibg=#fab387 guifg=#1e1e2e
            highlight MiniStatuslineModeOther guibg=#cba6f7 guifg=#1e1e2e

            highlight MiniStatuslineDevinfo guifg=#cdd6f4 guibg=#313244
            highlight MiniStatuslineFilename guifg=#cdd6f4 guibg=#1e1e2e
            highlight MiniStatuslineFileinfo guifg=#cdd6f4 guibg=#313244
            highlight MiniStatuslineInactive guifg=#6c7086 guibg=#1e1e2e
        ]])
	end,
	dependencies = {
		'echasnovski/mini.extra',
	}
}

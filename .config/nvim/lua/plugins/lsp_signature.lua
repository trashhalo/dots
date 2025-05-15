return {
	'ray-x/lsp_signature.nvim',
	event = { 'InsertEnter' },
	opts = {
		bind = true,
		-- doc_lines = 4,
		floating_window = true,
		-- floating_window_above_cur_line = false,
		hint_enable = true,
		fix_pos = false,
		-- floating_window_above_first = true,
		log_path = vim.fn.expand('$HOME') .. '/tmp/sig.log',
		-- hi_parameter = "Search",
		zindex = 1002,
		timer_interval = 100,
		extra_trigger_chars = {},
		handler_opts = {
			border = 'rounded', -- "shadow", --{"╭", "─" ,"╮", "│", "╯", "─", "╰", "│" },
		},
		max_height = 4,
		toggle_key = [[<M-x>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
		select_signature_key = [[<M-c>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
		move_cursor_key = [[<M-n>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
		move_signature_window_key = { '<M-Up>', '<M-Down>' },
	}
}

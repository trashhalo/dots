local function recent_files_picker(opts)
	local MiniPick = require('mini.pick')
	opts = opts or {}

	local source = {
		items = function()
			local files = vim.fn.systemlist({ 'rg', '--files', '--hidden', '--glob', '!.git', '--color',
				'never', '.' })
			local items = {}
			for _, line in ipairs(files) do
				local absolute_path = vim.fn.fnamemodify(line, ':p')
				table.insert(items, {
					text = line,
					path = absolute_path,
					mtime = vim.fn.getftime(absolute_path)
				})
			end
			table.sort(items, function(a, b) return a.mtime > b.mtime end)
			return items
		end,
		name = 'Files',
		show = function(buf_id, items_to_show, query)
			-- Always show icons
			MiniPick.default_show(buf_id, items_to_show, query, { show_icons = true })
		end,
		match = function(stritems, inds, query)
			if #query == 0 then
				return inds
			else
				return MiniPick.default_match(stritems, inds, query)
			end
		end
	}

	return MiniPick.start(vim.tbl_deep_extend('force', { source = source }, opts or {}))
end

local function changed_on_branch()
	local MiniExtra = require('mini.extra')

	local command = {
		'git',
		'diff',
		'--relative',
		'--name-only',
		'--diff-filter=ACMR',
		'origin...'
	}

	local preview = function(buf_id, item)
		-- Show git diff for the specific file
		local diff_cmd = {
			'git',
			'diff',
			'--diff-filter=ACMR',
			'origin...',
			'--',
			item
		}
		vim.bo[buf_id].filetype = 'diff'

		-- Use CLI to show diff in preview
		local lines = vim.fn.systemlist(table.concat(diff_cmd, ' '))
		vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
	end

	MiniExtra.pickers.git_files({
		path = '.',
		command = command,
	}, {
		source = {
			name = 'Changed on Branch',
			preview = preview
		}
	})
end

return {
	"echasnovski/mini.pick",
	version = false,
	dependencies = {
		"echasnovski/mini.icons",
		"echasnovski/mini.extra"
	},
	config = function()
		require('mini.pick').setup()
		require("mini.extra").setup({})
	end,
	keys = {
		{ "<D-p>", function() recent_files_picker() end, desc = "Open Files (MiniPick)" },
		{
			"<leader>jb",
			function() changed_on_branch() end,
			desc = "Changed on Branch (MiniPick)"
		},
		{
			"<leader>jk",
			function() require('mini.extra').pickers.keymaps() end,
			desc = "Keymaps (MiniPick)"
		},
		{
			"<leader>jm",
			function() require('mini.extra').pickers.lsp({ scope = 'document_symbol' }) end,
			desc = "Document Symbols (MiniPick)"
		},
		{
			"<leader>jc",
			function() require('mini.extra').pickers.commands() end,
			desc = "Commands (MiniPick)"
		},

	},
}

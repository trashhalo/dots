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
	local MiniPick = require('mini.pick')

	local git_commands = {
		-- Staged changes
		{ 'git', 'diff',     '--name-only', '--staged' },

		-- Unstaged changes
		{ 'git', 'diff',     '--name-only' },

		-- Untracked files
		{ 'git', 'ls-files', '--others',    '--exclude-standard' }
	}

	local function get_changed_files()
		for _, cmd in ipairs(git_commands) do
			local full_cmd = table.concat(cmd, ' ')
			local result = vim.fn.systemlist(full_cmd)

			-- Filter out empty lines
			result = vim.tbl_filter(function(line)
				return line ~= "" and line:match("%S")
			end, result)

			if #result > 0 then
				return result
			end
		end
		return {}
	end

	local preview = function(buf_id, item)
		local diff_cmd = {
			'git',
			'diff',
			'--',
			item
		}
		vim.bo[buf_id].filetype = 'diff'
		local lines = vim.fn.systemlist(diff_cmd)
		vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
	end

	local changed_files = get_changed_files()

	if #changed_files == 0 then
		print("No changes found.")
		return
	end

	MiniPick.start({
		source = {
			items = changed_files,
			name = 'Changed Files',
			preview = preview,
			show = MiniPick.default_show
		}
	})
end

local split_and_return = function()
	local pick = require('mini.pick')
	local item = pick.get_picker_matches().current
	if item == nil then return true end

	local picker_state = pick.get_picker_state()
	local target_window = picker_state.windows.target

	-- Store current cursor position and current buffer
	local current_buffer = vim.api.nvim_win_get_buf(target_window)

	-- Create split
	vim.api.nvim_win_call(target_window, function()
		pick.default_choose(item)
		vim.cmd('vsplit')
		-- set to original buffer
		vim.api.nvim_win_set_buf(0, current_buffer)
		-- move focus back back
		pick.set_picker_target_window(vim.api.nvim_get_current_win())
	end)

	return true
end

return {
	"echasnovski/mini.pick",
	version = false,
	dependencies = {
		"echasnovski/mini.icons",
		"echasnovski/mini.extra"
	},
	config = function()
		require('mini.pick').setup({
			mappings = {
				choose_vsplit_stay = {
					char = '<A-v>',
					func = split_and_return
				}
			},
		})
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
			"<leader>jw",
			function() require('mini.extra').pickers.lsp({ scope = 'workspace_symbol' }) end,
			desc = "Workspace Symbols (MiniPick)"
		},
		{
			"<leader>jc",
			function() require('mini.extra').pickers.commands() end,
			desc = "Commands (MiniPick)"
		},
		{
			"<leader>jg",
			function() require('mini.pick').builtin.grep_live() end,
			desc = "Grep Live (MiniPick)"
		}
	},
}

local function create_method_picker(opts)
	local cmd = "sg"
	local args = {
		"run",
		"--pattern",
		"$VISIBILITY $METHOD_NAME($$$ARGS) do $_BODY",
		"--json=stream"
	}

	-- Get current buffer's file path
	local current_file = vim.api.nvim_buf_get_name(0)
	table.insert(args, current_file)

	return require("snacks.picker.source.proc").proc({
		opts,
		{
			cmd = cmd,
			args = args,
			transform = function(item)
				local success, json_data = pcall(vim.json.decode, item.text)
				if not success then
					return false
				end

				-- Extract method information
				local method_name = json_data.metaVariables.single.METHOD_NAME.text
				local args = {}
				if json_data.metaVariables.multi.ARGS then
					for _, arg in ipairs(json_data.metaVariables.multi.ARGS) do
						if arg.text ~= "," then
							local clean_arg = arg.text:gsub("%s+", "")
							table.insert(args, clean_arg)
						end
					end
				end

				-- Calculate arity
				local arity = #args
				local params_text = table.concat(args, ",")

				-- Format item to match Treesitter format
				item.kind = "Function"
				item.name = method_name
				item.args = params_text
				item.arity = arity
				item.file = json_data.file
				item.pos = { json_data.range.start.line + 1, json_data.range.start.column }

				return item
			end,
		},
	}, opts.ctx)
end

local function format_elixir(item, picker)
	local ret = {} ---@type snacks.picker.Highlight[]

	-- Add tree indentation if needed
	if item.tree then
		vim.list_extend(ret, require("snacks.picker.format").tree(item, picker))
	end

	-- Add icon
	local kind = item.kind or "Unknown"
	local kind_hl = "SnacksPickerIcon" .. kind
	ret[#ret + 1] = { picker.opts.icons.kinds[kind], kind_hl }
	ret[#ret + 1] = { " " }

	-- Format Elixir functions
	if item.kind == "Function" and item.args then
		ret[#ret + 1] = { string.format("%s/%d", item.name, item.arity), "Function" }
		ret[#ret + 1] = { " (", "Comment" }
		ret[#ret + 1] = { item.args, "Comment" }
		ret[#ret + 1] = { ")", "Comment" }
	else
		ret[#ret + 1] = { item.name }
	end

	return ret
end

return {
	"folke/snacks.nvim",
	opts = {
		picker = {
			-- UI configuration
			layout = { preset = "default" },
			icons = {
				files = { enabled = true },
				git = { enabled = true },
			},
			-- Configure sources to modify how LSP symbols work
			sources = {},

			-- Rest of your config...
			win = {
				input = {
					keys = {
						["<A-v>"] = {
							function(picker, item)
								if item then
									local cur_win = vim.api.nvim_get_current_win()
									vim.cmd("vsplit")
									if item.file then
										vim.cmd("edit " .. item.file)
									end
									vim.api.nvim_set_current_win(cur_win)
								end
							end,
							mode = { "n", "i" },
							desc = "Vertical split and stay",
						},
					},
				},
			},
		},
	},
	keys = function()
		local snacks = require("snacks")

		return {
			-- Quick access
			{ "<D-p>",      function() snacks.picker.smart() end,      desc = "Smart Find Files" },

			-- Jump group (matching your <Leader>j group)
			{ "<leader>jf", function() snacks.picker.files() end,      desc = "Jump to File" },
			{ "<leader>jb", function() snacks.picker.git_status() end, desc = "Jump to Changed Files" },
			{ "<leader>jk", function() snacks.picker.keymaps() end,    desc = "Jump to Keymap" },

			{
				"<leader>jm",
				function()
					snacks.picker.pick({
						finder = create_method_picker,
						layout = { preset = "vertical" },
						format = format_elixir -- Using the same formatter as before
					})
				end,
				desc = "Jump to Method"
			},
			{ "<leader>jw", function() snacks.picker.lsp_workspace_symbols() end, desc = "Jump to Workspace Symbol" },
			{ "<leader>jc", function() snacks.picker.commands() end,              desc = "Jump to Command" },
			{ "<leader>jg", function() snacks.picker.grep({ live = true }) end,   desc = "Jump to Text (Grep)" },
			{ "<leader>jr", function() snacks.picker.recent() end,                desc = "Jump to Recent" },
			{ "<leader>jh", function() snacks.picker.help() end,                  desc = "Jump to Help" },

			-- Git group (matching your <Leader>g group)
			{ "<leader>gb", function() snacks.picker.git_branches() end,          desc = "Git Branches" },
			{ "<leader>gl", function() snacks.picker.git_log() end,               desc = "Git Log" },
			{ "<leader>gL", function() snacks.picker.git_log_line() end,          desc = "Git Log (Current Line)" },
			{ "<leader>gs", function() snacks.picker.git_status() end,            desc = "Git Status" },
			{ "<leader>gf", function() snacks.picker.git_files() end,             desc = "Git Files" },

			-- Search/Symbol group
			{ "<leader>sb", function() snacks.picker.buffers() end,               desc = "Search Buffers" },
			{ "<leader>sd", function() snacks.picker.diagnostics() end,           desc = "Search Diagnostics" },
			{ "<leader>sg", function() snacks.picker.grep({ live = true }) end,   desc = "Search Text (Grep)" },
			{ "<leader>sr", function() snacks.picker.resume() end,                desc = "Search Resume" },

			-- LSP related (can be triggered with standard gd, gr, etc.)
			{ "gd",         function() snacks.picker.lsp_definitions() end,       desc = "Goto Definition" },
			{ "gr",         function() snacks.picker.lsp_references() end,        desc = "Goto References" },
			{ "gI",         function() snacks.picker.lsp_implementations() end,   desc = "Goto Implementation" },
		}
	end,
}

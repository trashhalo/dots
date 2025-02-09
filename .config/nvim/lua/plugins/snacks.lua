-- Local helper functions for Elixir treesitter formatting
local function transform_elixir(item)
	print("Transform called with item:", vim.inspect(item))
	if item.kind == "Function" then
		print("  Is function")
		-- Check if we're in an Elixir file
		local bufnr = item.buf
		local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
		if ft == "elixir" then
			print("  Is Elixir file")
			-- Get the lines around the function definition
			local start_line = item.pos[1]
			local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line + 1, false)
			local def_line = lines[1] or ""
			print("  Def line:", def_line)

			-- Extract function name and arguments
			local name = item.name
			print("  Name:", name)
			local args = def_line:match("def%s+" .. name .. "%s*%((.-)%)") or
			    def_line:match("defp%s+" .. name .. "%s*%((.-)%)")
			print("  Args:", args)

			if args then
				-- Clean up args and count arity
				args = vim.trim(args)
				local arity = #(args:gsub("[^,]", "")) + 1
				item.text = string.format("%s/%d (%s)", name, arity, args)
				item.args = args
				item.arity = arity
				print("  Processed:", item.text)
			end
		end
	end
	return item
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
					snacks.picker.treesitter({
						layout = { preset = "vertical" },
						filter = {
							default = {
								"Function",
								"Method"
							}
						},
						transform = function(item)
							-- Skip nested duplicates
							if item.parent and item.parent.kind == item.kind and item.parent.name == item.name then
								return false
							end
							-- Apply Elixir-specific transforms
							return transform_elixir(item)
						end,
						format = format_elixir
					})
				end,
				desc = "Jump to Document Symbol"
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

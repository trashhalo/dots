local M = {}

M.setup = function()
	local changed_on_branch = function()
		local previewers = require("telescope.previewers")
		local pickers = require("telescope.pickers")
		local sorters = require("telescope.sorters")
		local finders = require("telescope.finders")
		pickers
			.new({}, {
				results_title = "Modified in current branch",
				finder = finders.new_oneshot_job({
					"git",
					"diff",
					"--relative",
					"--name-only",
					"--diff-filter=ACMR",
					"origin...",
				}, {}),
				sorter = sorters.get_fuzzy_file(),
				previewer = previewers.new_termopen_previewer({
					get_command = function(entry)
						return {
							"git",
							"diff",
							"--diff-filter=ACMR",
							"origin...",
							"--",
							entry.value,
						}
					end,
				}),
			})
			:find()
	end

	require("telescope").setup({
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			}
		},
		defaults = {
			mappings = {
				i = { ["<c-y>"] = require('trouble.sources.telescope').open },
				n = { ["<c-y>"] = require('trouble.sources.telescope').open },
			},
		},
	})

	require('telescope').load_extension('fzf')
	require("telescope").load_extension("ui-select")
	require("telescope").load_extension("recent_files")

	local builtin = require('telescope.builtin')
	vim.keymap.set('n', '<leader>jp', builtin.find_files, { desc = "Find Files (Telescope)" })
	vim.keymap.set('n', '<leader>jg', builtin.git_status, { desc = "Git Status (Telescope)" })
	vim.keymap.set('n', '<leader>jk', builtin.keymaps, { desc = "Keymaps (Telescope)" })
	vim.keymap.set('n', '<leader>jm', function()
		builtin.lsp_document_symbols({ symbols = { "Function", "Method", "Field", "Variable" } })
	end, { desc = "Document Symbols (Telescope)" })
	vim.keymap.set('n', '<leader>jb', changed_on_branch, { desc = "Changed on Branch (Telescope)" })
	vim.keymap.set('n', '<leader>jc', builtin.commands, { desc = "Commands (Telescope)" })
	vim.api.nvim_set_keymap("n", "<Leader><Leader>",
		[[<cmd>lua require('telescope').extensions.recent_files.pick()<CR>]],
		{ noremap = true, silent = true, desc = "Recent Files (Telescope)" })
end

return M

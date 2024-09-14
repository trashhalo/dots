vim.g.mapleader = ","         -- using tick as leader key
vim.opt.relativenumber = true -- enable relative number
vim.opt.background = "light"  -- set background to light
vim.g.notimeout = true        -- disable timeout, which means that mappings will wait for the next key
vim.g.nottimeout = true       -- disable ttimmeout, the differnce between timeout and ttimeout is that the latter is for keycodes that are part of a sequence

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

-- bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

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

require("lazy").setup({
	{ import = "plugins.format-on-save" },
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"ray-x/cmp-treesitter",
			"onsails/lspkind-nvim",
			"hrsh7th/cmp-nvim-lsp-signature-help"
		},
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			local has_words_before = function()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0 and
				    vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" ==
				    nil
			end

			cmp.setup({
				preselect = cmp.PreselectMode.None,
				window = {
					documentation = cmp.config.window.bordered(),
				},
				view = {
					entries = {
						name = "custom",
						selection_order = "near_cursor",
					},
				},
				confirm_opts = {
					behavior = cmp.ConfirmBehavior.Insert,
				},
				-- add different completion source
				sources = cmp.config.sources({
					{ name = 'nvim_lsp_signature_help' },
					{ name = "nvim_lsp" },
					{ name = "treesitter" },
				}),
				formatting = {
					expandable_indicator = true,
					fields = { "kind", "abbr", "menu" },
					format = lspkind.cmp_format {
						mode = "symbol",
						maxwidth = 60,
						menu = {
							treesitter = "󰌪",
							nvim_lsp = "󰀘",
							nvim_lsp_signature_help = "󰊕"
						}
					}
				},
				-- using default mapping preset
				mapping = cmp.mapping.preset.insert({
					['<CR>'] = cmp.mapping.confirm { select = true },
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { 'i', 's' }),
					['<S-Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { 'i', 's' }),
				}),
				snippet = {
					-- you must specify a snippet engine
					expand = function(args)
						-- using neovim v0.10 native snippet feature
						-- you can also use other snippet engines
						vim.snippet.expand(args.body)
					end,
				},
			})
		end,
	},
	{
		'nvim-telescope/telescope-fzf-native.nvim',
		build = 'make',
	},
	{ 'nvim-telescope/telescope-ui-select.nvim' },
	{
		"nvim-telescope/telescope.nvim",
		tag = '0.1.4',
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
			"smartpde/telescope-recent-files",
			"folke/trouble.nvim"
		},
		config = function()
			require("telescope").setup({
				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
						case_mode = "smart_case", -- or "ignore_case" or "respect_case"
						-- the default case_mode is "smart_case"
					}
				},
				defaults = {
					mappings = {
						i = { ["<c-y>"] = require('trouble.sources.telescope').open },
						n = { ["<c-y>"] = require('trouble.sources.telescope').open },
					},
				},
			})

			-- To get fzf loaded and working with telescope, you need to call
			-- load_extension, somewhere after setup function:
			require('telescope').load_extension('fzf')

			-- To get ui-select loaded and working with telescope, you need to call
			-- load_extension, somewhere after setup function:
			require("telescope").load_extension("ui-select")
			require("telescope").load_extension("recent_files")
		end,
	},
	{
		'hrsh7th/nvim-cmp',
		dependencies = { 'hrsh7th/cmp-nvim-lsp' },
		event = 'InsertEnter',
		config = function()
		end
	},
	{
		"zbirenbaum/copilot.lua",
		dependencies = {
			"zbirenbaum/copilot-cmp",
		},
		cmd = "Copilot",
		build = ":Copilot auth",
		event = "InsertEnter",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept_line = "<C-e>"
				}
			},
			panel = {
				enabled = true
			},
		},
		keys = {
			{
				"<leader>e",
				function()
					require("copilot.suggestion").accept()
				end,
				desc = "Accept Copilot Suggestion"
			}
		},
		server_opts_overrides = {
			trace = "verbose",
		},
		config = function()
		end
	},
	{ import = "plugins.elixir-tools" },
	{
		"nvim-treesitter/nvim-treesitter",
		enabled = true,
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "elixir", "eex", "heex", "lua", "markdown", "yaml", "javascript", "typescript" },
				highlight = { enable = true },
				indent = { enable = false },
				textobjects = {
					select = {
						enable = true,
						lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							['aa'] = { query = '@parameter.outer', desc = "Select a parameter" },
							['ia'] = { query = '@parameter.inner', desc = "Select inner parameter" },
							['af'] = { query = '@function.outer', desc = "Select a function" },
							['if'] = { query = '@function.inner', desc = "Select inner function" },
							['ac'] = { query = '@class.outer', desc = "Select a class" },
							['ic'] = { query = '@class.inner', desc = "Select inner class" },
							["iB"] = { query = "@block.inner", desc = "Select inner block" },
							["aB"] = { query = "@block.outer", desc = "Select a block" },
						},
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							[']]'] = { query = '@function.outer', desc = "Function start" },
						},
						goto_next_end = {
							[']['] = { query = '@function.outer', desc = "Function end" },
						},
						goto_previous_start = {
							['[['] = { query = '@function.outer', desc = "Function start" },
						},
						goto_previous_end = {
							['[]'] = { query = '@function.outer', desc = "Function end" },
						},
					}

				}
			})
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-refactor"
		},
	},
	{ import = "plugins.modus-themes" },
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("plugins.lspconfig").setup()
		end,
	},
	{
		"mhanberg/output-panel.nvim",
		event = "VeryLazy",
		config = function()
			require("output_panel").setup()
		end
	},
	{
		"nvim-tree/nvim-tree.lua",
		config = function()
			require("nvim-tree").setup({
				filters = {
					dotfiles = false,
				}
			})
		end,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "<leader>nn", "<cmd>NvimTreeToggle<cr>", desc = "Toggle Sidebar (NvimTree)" },
			{ "<leader>nf", "<cmd>NvimFindFile<cr>",   desc = "Find File (NvimTree)" }
		}
	},
	"nvim-tree/nvim-web-devicons",
	{
		"luckasRanarison/tailwind-tools.nvim",
		opts = {
			custom_filetypes = { "heex", "elixir", "eelixir" },
		},
	},
	{
		"nvim-pack/nvim-spectre",
		keys = {
			{ "<leader>sr", function() require("spectre").open() end,                              desc = "Search and Replace (Spectre)" },
			{ "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, "n",                                  desc = "Search current word (Spectre)" },
			{ "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, "v",                                  desc = "Search current word (Spectre)" },

		},
	},
	{
		"folke/trouble.nvim",
		enabled = true,
		opts = {
			auto_jump = true
		},
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>xs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>xl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xq",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			}
		},
		config = function()
		end
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {},
		dependencies = {
			"echasnovski/mini.icons"
		},
		config = function()
			local wk = require("which-key")
			wk.add({
				{ "<leader>",  group = "Leader" },
				{ "<leader>c", group = "Quickfix List" },
				{ "<leader>j", group = "Jump" },
				{ "<leader>l", group = "Location List" },
				{ "<leader>n", group = "NvimTree" },
				{ "<leader>s", group = "Spectre" },
				{ "<leader>t", group = "Tabs" },
				{ "<leader>x", group = "Trouble" },
				{ "<leader>1", group = "Toggleterm" }
			})
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		}
	},
	{ import = "plugins.lsp_signature" },
	{ import = "plugins.flash" },
	{
		"chrisgrieser/nvim-spider",
		lazy = true,
		keys = {
			{
				"e",
				"<cmd>lua require('spider').motion('e')<CR>",
				mode = { "n", "o", "x" },
			},
			{
				"b",
				"<cmd>lua require('spider').motion('b')<CR>",
				mode = { "n", "o", "x" },
			},
			{
				"w",
				"<cmd>lua require('spider').motion('w')<CR>",
				mode = { "n", "o", "x" },
			},
		},
		config = function()
		end
	},
	{
		'norcalli/nvim-colorizer.lua',
		config = function()
			require('colorizer').setup()
		end
	},
	{
		'stevearc/oil.nvim',
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Open Oil" },
		},
		config = function()
			require("oil").setup({
				default_file_explorer = true,
				delete_to_trash = true,
				skip_confirm_for_simple_edits = true,
				view_options = {
					show_hidden = true,
					natural_order = true,
					is_always_hidden = function(name, _)
						return name == ".." or name == ".git"
					end,
				},
				float = {
					padding = 2,
					max_width = 90,
					max_height = 0,
				},
				win_options = {
					wrap = true,
					winblend = 0,
				},
				keymaps = {
					["<C-c>"] = false,
					["q"] = "actions.close",
				},
			})
		end,

	},
	{
		"jessekelighine/vindent.vim",
		event = "VimEnter",
		init = function()
			vim.g.vindent_motion_OO_prev = '[l'
			vim.g.vindent_motion_OO_next = ']l'
			vim.g.vindent_motion_less_prev = '[-'
			vim.g.vindent_motion_less_next = ']-'
			vim.g.vindent_motion_more_prev = '[='
			vim.g.vindent_motion_more_next = ']='
			vim.g.vindent_motion_XX_ss = '[p'
			vim.g.vindent_motion_XX_se = ']p'
			vim.g.vindent_motion_OX_ss = '[P'
			vim.g.vindent_motion_OX_se = ']P'
			vim.g.vindent_object_OO_ii = 'iI'
			vim.g.vindent_object_XX_ii = 'ii'
			vim.g.vindent_object_XX_ai = 'ai'
			vim.g.vindent_object_XX_aI = 'aI'
			vim.g.vindent_jumps = 1
			vim.g.vindent_begin = 1
			vim.g.vindent_count = 0
		end,
		config = function()
		end
	},
	{
		"epwalsh/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		lazy = true,
		event = {
			"BufReadPre " .. vim.fn.expand("~") .. "/Documents/New beginnings Aug 23/*",
			"BufReadPre " .. vim.fn.expand("~") .. "/Documents/PARA/*",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"hrsh7th/nvim-cmp"
		},
		opts = {
			workspaces = {
				{
					name = "personal",
					path = "~/Documents/New beginnings Aug 23"
				},
				{
					name = "work",
					path = "~/Documents/PARA"
				},
			},
		},
		init = function()
			vim.opt.conceallevel = 1
		end,
	},
	{
		'akinsho/toggleterm.nvim',
		version = "*",
		config = function()
			require("toggleterm").setup {}
		end,
		keys = {
			{ "<leader>11", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
		},
	},
	{ import = "plugins.flatten" },
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>jp', builtin.find_files, { desc = "Find Files (Telescope)" })
vim.keymap.set('n', '<leader>jg', builtin.git_status, { desc = "Git Status (Telescope)" })
vim.keymap.set('n', '<leader>jk', builtin.keymaps, { desc = "Keymaps (Telescope)" })
vim.keymap.set('n', '<leader>jm', function()
	builtin.lsp_document_symbols({ symbols = { "Function", "Method", "Field", "Variable" } })
end, { desc = "Document Symbols (Telescope)" })
vim.keymap.set('n', '<leader>jb', changed_on_branch, { desc = "Changed on Branch (Telescope)" })
vim.keymap.set('n', '<leader>jc', builtin.commands, { desc = "Commands (Telescope)" })
local trouble = require("trouble")
vim.keymap.set("n", "gd", function() trouble.open({ mode = "lsp_definitions" }) end,
	{ desc = "🔭 Definitions" })
vim.keymap.set("n", "gi", function() trouble.open({ mode = "lsp_implementations" }) end,
	{ desc = "🔭 Implementations" })
vim.keymap.set("n", "gR", function() trouble.open({ mode = "lsp_references" }) end,
	{ desc = "🔭 References" })
vim.api.nvim_set_keymap("n", "<Leader><Leader>",
	[[<cmd>lua require('telescope').extensions.recent_files.pick()<CR>]],
	{ noremap = true, silent = true, desc = "Recent Files (Telescope)" })

-- add keymaps for tabs
vim.keymap.set("n", "<leader>tn", ":tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader>to", ":tabonly<cr>", { desc = "Close Other Tabs" })
vim.keymap.set("n", "[t", ":tabprevious<cr>", { desc = "Previous Tab" })
vim.keymap.set("n", "]t", ":tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<A-<>", ":tabmove -1<cr>", { desc = "Move Tab Left" })
vim.keymap.set("n", "<A->>", ":tabmove +1<cr>", { desc = "Move Tab Right" })
vim.api.nvim_set_keymap("t", "<esc>", "<C-\\><C-n>", { noremap = true, silent = true })

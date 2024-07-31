vim.g.mapleader = ","         -- using tick as leader key
vim.opt.relativenumber = true -- enable relative number
vim.opt.background = "light"  -- set background to light
vim.g.notimeout = true
vim.g.nottimeout = true

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

local foldIcon = ''
local hlgroup = 'NonText'
local function foldTextFormatter(virtText, lnum, endLnum, width, truncate)
	local newVirtText = {}
	local suffix = '  ' .. foldIcon .. '  ' .. tostring(endLnum - lnum)
	local sufWidth = vim.fn.strdisplaywidth(suffix)
	local targetWidth = width - sufWidth
	local curWidth = 0
	for _, chunk in ipairs(virtText) do
		local chunkText = chunk[1]
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if targetWidth > curWidth + chunkWidth then
			table.insert(newVirtText, chunk)
		else
			chunkText = truncate(chunkText, targetWidth - curWidth)
			local hlGroup = chunk[2]
			table.insert(newVirtText, { chunkText, hlGroup })
			chunkWidth = vim.fn.strdisplaywidth(chunkText)
			if curWidth + chunkWidth < targetWidth then
				suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
			end
			break
		end
		curWidth = curWidth + chunkWidth
	end
	table.insert(newVirtText, { suffix, hlgroup })
	return newVirtText
end

require("lazy").setup({
	{
		"elentok/format-on-save.nvim",
		config = function()
			local format_on_save = require("format-on-save")
			local formatters = require("format-on-save.formatters")
			format_on_save.setup({
				formatter_by_ft = {
					elixir = formatters.lsp,
					lua = formatters.lsp
				},
				experiments = {
					partial_update = 'diff'
				}
			})
		end

	},
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
	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
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
				enabled = false
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
		}
	},
	{
		"elixir-tools/elixir-tools.nvim",
		version = "0.16.0",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local elixir = require("elixir")
			local elixirls = require("elixir.elixirls")

			elixir.setup {
				nextls = { enable = false },
				credo = { enable = true },
				elixirls = {
					enable = true,
					cmd = "/home/vscode/.elixir-ls/language_server.sh",
					settings = elixirls.settings {
						dialyzerEnabled = false,
						enableTestLenses = false,
					},
					on_attach = function(client, bufnr)
						vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>",
							{ buffer = true, noremap = true })
						vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>",
							{ buffer = true, noremap = true })
						vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>",
							{ buffer = true, noremap = true })
					end,
				}
			}
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		enabled = true,
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "elixir", "eex", "heex", "lua", "markdown" },
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
	{
		"savq/melange-nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.o.termguicolors = true
			vim.cmd([[colorscheme melange]])
		end
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require('lspconfig')
			lspconfig.lua_ls.setup {
				settings = {
					Lua = {
						diagnostics = {
							globals = {
								'vim',
								'require'
							},
						}
					}
				}
			}
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
		}
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
				{ "<leader>r", group = "Rabbit" },
				{ "<leader>s", group = "Spectre" },
				{ "<leader>t", group = "Tabs" },
				{ "<leader>x", group = "Trouble" },
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
	{
		'voxelprismatic/rabbit.nvim',
		cmd = 'Rabbit',
		keys = {
			{
				'<leader>rr',
				function()
					require('rabbit').Window 'history'
				end,
				mode = 'n',
				desc = 'Open Rabbit',
			},
			{
				'<leader>rj',
				function()
					require('rabbit').Switch 'history' -- Will close current Rabbit window if necessary
					require('rabbit').func.select(1) -- Selects the first entry shown to the user
				end,
				mode = 'n',
				desc = 'Toggle Rabbit',
			},
		},
		opts = {
			colors = {
				term = { fg = '#34ab7e', italic = true },
			},
			window = {
				plugin_name_position = 'title',
			},
		},
	},

	{
		"ten3roberts/qf.nvim",
		opts = {
			-- Location list configuration
			["l"] = {
				auto_follow = "prev",
			},
			-- Quickfix list configuration
			["c"] = {
				auto_follow = "prev",
				auto_resize = false,
				wide = true,
			},
			close_other = true,
		},
		keys = {
			{
				"<leader>lo",
				function()
					require("qf").open("l")
				end,
				desc = 'Open location list',
			},
			{
				"<leader>lc",
				function()
					require("qf").open("c")
				end,
				desc = 'Close quickfix list',
			},
			{
				"<leader>ll",
				function()
					require("qf").toggle("l", true)
				end,
				desc = 'Toggle location list',
			},
			{
				"<leader>co",
				function()
					require("qf").open("c")
				end,
				desc = 'Open quickfix list',
			},
			{
				"<leader>cc",
				function()
					require("qf").close("c")
				end,
				desc = 'Close quickfix list',
			},
			{
				"<leader>cl",
				function()
					require("qf").toggle("c", true)
				end,
				desc = 'Toggle quickfix list',
			},
			{
				"<leader>j",
				function()
					require("qf").below("l")
				end,
				desc = "Go to next location list entry from cursor"
			},
			{
				"<leader>k",
				function()
					require("qf").above("l")
				end,
				desc = "Go to previous location list entry from cursor"
			},
			{
				"<leader>J",
				function()
					require("qf").below("c")
				end,
				desc = "Go to next quickfix list entry from cursor"
			},
			{
				"<leader>K",
				function()
					require("qf").above("c")
				end,
				desc = "Go to previous quickfix list entry from cursor"
			},
			{
				"<leader>]q",
				function()
					require("qf").below("visible")
				end,
				desc = "Go to next entry from cursor in visible list"
			},
			{
				"<leader>[q",
				function()
					require("qf").above("visible")
				end,
				desc = "Go to previous entry from cursor in visible list"
			},
		},
		config = function()
			require("qf").setup()
		end,
	},
	{
		"chrisgrieser/nvim-origami",
		event = "BufReadPost", -- later or on keypress would prevent saving folds
		opts = {}, -- needed even when using default config
	},
	{
		'kevinhwang91/nvim-ufo',
		dependencies = 'kevinhwang91/promise-async',
		event = 'BufReadPost', -- needed for folds to load in time
		keys = {
			{
				'zr',
				function()
					require('ufo').openFoldsExceptKinds({ 'imports', 'comment' })
				end,
				desc = ' 󱃄 Open All Folds except comments',
			},
			{
				'zm',
				function()
					require('ufo').closeAllFolds()
				end,
				desc = ' 󱃄 Close All Folds',
			},
			{
				'z1',
				function()
					require('ufo').closeFoldsWith(1)
				end,
				desc = ' 󱃄 Close L1 Folds',
			},
			{
				'z2',
				function()
					require('ufo').closeFoldsWith(2)
				end,
				desc = ' 󱃄 Close L2 Folds',
			},
			{
				'z3',
				function()
					require('ufo').closeFoldsWith(3)
				end,
				desc = ' 󱃄 Close L3 Folds',
			},
			{
				'z4',
				function()
					require('ufo').closeFoldsWith(4)
				end,
				desc = ' 󱃄 Close L4 Folds',
			},
		},
		init = function()
			-- INFO fold commands usually change the foldlevel, which fixes folds, e.g.
			-- auto-closing them after leaving insert mode, however ufo does not seem to
			-- have equivalents for zr and zm because there is no saved fold level.
			-- Consequently, the vim-internal fold levels need to be disabled by setting
			-- them to 99
			vim.opt.foldlevel = 99
			vim.opt.foldlevelstart = 99
		end,
		opts = {
			provider_selector = function(_, ft, _)
				-- INFO some filetypes only allow indent, some only LSP, some only
				-- treesitter. However, ufo only accepts two kinds as priority,
				-- therefore making this function necessary :/
				local lspWithOutFolding = { 'markdown', 'sh', 'css', 'html', 'python' }
				if vim.tbl_contains(lspWithOutFolding, ft) then
					return { 'treesitter', 'indent' }
				end
				return { 'lsp', 'indent' }
			end,
			-- open opening the buffer, close these fold kinds
			-- use `:UfoInspect` to get available fold kinds from the LSP
			close_fold_kinds_for_ft = { lsp = { 'imports', 'comment' } },
			open_fold_hl_timeout = 800,
			fold_virt_text_handler = foldTextFormatter,
		},
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts) require 'lsp_signature'.setup(opts) end
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		-- stylua: ignore
		keys = {
			{ "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
		config = function()
			vim.api.nvim_set_hl(0, "FlashLabel", { bg = "#000000", fg = "#ffffff" })
		end
	}
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
	{ desc = "LSP Definitions (Trouble)" })
vim.keymap.set("n", "gi", function() trouble.open({ mode = "lsp_implementations" }) end,
	{ desc = "LSP Implementations (Trouble)" })
vim.api.nvim_set_keymap("n", "<Leader><Leader>",
	[[<cmd>lua require('telescope').extensions.recent_files.pick()<CR>]],
	{ noremap = true, silent = true, desc = "Recent Files (Telescope)" })

-- add keymaps for tabs
vim.keymap.set("n", "<leader>tn", ":tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader>to", ":tabonly<cr>", { desc = "Close Other Tabs" })
vim.keymap.set("n", "<A-,>", ":tabprevious<cr>", { desc = "Previous Tab" })
vim.keymap.set("n", "<A-.>", ":tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<A-<>", ":tabmove -1<cr>", { desc = "Move Tab Left" })
vim.keymap.set("n", "<A->>", ":tabmove +1<cr>", { desc = "Move Tab Right" })

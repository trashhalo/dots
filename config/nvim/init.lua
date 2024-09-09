vim.g.mapleader = ","         -- using tick as leader key
vim.opt.relativenumber = true -- enable relative number
vim.opt.background = "light"  -- set background to light
vim.g.notimeout = true        -- disable timeout, which means that mappings will wait for the next key
vim.g.nottimeout = true       -- disable ttimmeout, the differnce between timeout and ttimeout is that the latter is for keycodes that are part of a sequence
vim.opt.mouse = "a"           -- enable mouse support, this helps with scrolling and resizing splits

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
					lua = formatters.lsp,
					typescript = formatters.prettierd,
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
					cmd = "/Users/stephensolka/.elixir-ls/language_server.sh",
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
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
		end
	},
	{
		"miikanissi/modus-themes.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			vim.opt.background = "light"
			require("modus-themes").setup({
				on_colors = function(colors)
					-- Light background to match the map
					colors.bg_main = "#ffffff" -- White background
					colors.bg_dim = "#f5f5f5" -- Slightly off-white for contrast
					colors.bg_alt = "#e8e8e8" -- Light gray for alternative backgrounds
					colors.fg_main = "#000000" -- Black text for readability

					-- Colors inspired directly by the Tokyo subway map
					colors.red = "#f52f2f" -- Marunouchi Line
					colors.green = "#00b261" -- Chiyoda Line
					colors.yellow = "#D9A900" -- Ginza Line
					colors.blue = "#0079c2" -- Tozai Line
					colors.magenta = "#9c5e31" -- Fukutoshin Line
					colors.cyan = "#00a7db" -- Asakusa Line

					-- Additional colors from the map
					colors.orange = "#f39700" -- Ginza Line
					colors.brown = "#8f4b2e" -- Mita Line
					colors.pink = "#e85298" -- Hibiya Line
					colors.purple = "#9b7cb6" -- Hanzomon Line
					colors.lime = "#b5b5ac" -- Namboku Line

					-- Intense colors for highlights
					colors.red_intense = "#bd0000"
					colors.green_intense = "#006e3c"
					colors.yellow_intense = "#ffa400"
					colors.blue_intense = "#0054a6"
					colors.magenta_intense = "#6a3906"
					colors.cyan_intense = "#0089b3"

					-- Subtle background colors for syntax highlighting
					colors.bg_red_subtle = "#ffe5e5"
					colors.bg_green_subtle = "#e5ffe5"
					colors.bg_yellow_subtle = "#fffde5"
					colors.bg_blue_subtle = "#e5f2ff"
					colors.bg_magenta_subtle = "#ffe5f2"
					colors.bg_cyan_subtle = "#e5fcff"

					-- Special purpose
					colors.bg_status_line_active = "#d0d0d0"
					colors.fg_status_line_active = "#000000"
					colors.bg_status_line_inactive = "#e0e0e0"
					colors.fg_status_line_inactive = "#505050"

					-- Git diff colors (adjusted for light theme)
					colors.bg_added = "#e6ffec"
					colors.bg_changed = "#fff5cc"
					colors.bg_removed = "#ffebe9"
				end,
				on_highlights = function(highlight, color)
					highlight.Function = { fg = color.red, bold = true }
					highlight.String = { fg = color.blue }
					highlight.Number = { fg = color.orange }
					highlight.Boolean = { fg = color.green, bold = true }
					highlight.Keyword = { fg = color.magenta }
					highlight.Conditional = { fg = color.purple }
					highlight.Operator = { fg = color.cyan }
					highlight.Type = { fg = color.yellow }
					highlight.Comment = { fg = color.brown, italic = true }

					-- UI elements
					highlight.Visual = { bg = color.yellow, fg = color.bg_main }

					-- Popup menu
					highlight.Pmenu = { bg = color.bg_dim, fg = color.fg_main }
					highlight.PmenuSel = { bg = color.blue, fg = color.bg_main }

					-- Miscellaneous Syntax related non-standard highlights
					highlight.qfLineNr = { fg = color.fg_dim }
					highlight.qfFileName = { fg = color.blue }

					-- HTML headers
					highlight.htmlH1 = { fg = color.red, bold = true }
					highlight.htmlH2 = { fg = color.blue, bold = true }
					highlight.htmlH3 = { fg = color.green, bold = true }
					highlight.htmlH4 = { fg = color.yellow, bold = true }
					highlight.htmlH5 = { fg = color.purple, bold = true }
					highlight.htmlH6 = { fg = color.cyan, bold = true }

					-- Markdown
					highlight.mkdCodeDelimiter = { bg = color.bg_dim, fg = color.fg_main }
					highlight.mkdCodeStart = { fg = color.cyan, bold = true }
					highlight.mkdCodeEnd = { fg = color.cyan, bold = true }

					highlight.markdownHeadingDelimiter = { fg = color.orange, bold = true }
					highlight.markdownCode = { fg = color.cyan }
					highlight.markdownCodeBlock = { fg = color.cyan }
					highlight.markdownLinkText = { fg = color.blue, underline = true }
					highlight.markdownH1 = { fg = color.red, bold = true }
					highlight.markdownH2 = { fg = color.blue, bold = true }
					highlight.markdownH3 = { fg = color.green, bold = true }
					highlight.markdownH4 = { fg = color.yellow, bold = true }
					highlight.markdownH5 = { fg = color.purple, bold = true }
					highlight.markdownH6 = { fg = color.cyan, bold = true }

					-- LSP highlights
					highlight.LspCodeLens = { fg = color.fg_dim }
					highlight.LspInlayHint = { bg = color.bg_main, fg = color.fg_dim, italic = true }
					highlight.LspReferenceText = { bg = color.bg_dim, fg = color.fg_main }
					highlight.LspReferenceRead = { bg = color.bg_dim, fg = color.fg_main }
					highlight.LspReferenceWrite = { bg = color.bg_dim, fg = color.fg_main }
					highlight.LspInfoBorder = { fg = color.blue, bg = color.bg_main }

					-- Diagnostics
					highlight.DiagnosticError = { fg = color.red, bold = true }
					highlight.DiagnosticWarn = { fg = color.yellow, bold = true }
					highlight.DiagnosticInfo = { fg = color.blue, bold = true }
					highlight.DiagnosticHint = { fg = color.green, bold = true }
					highlight.DiagnosticUnnecessary = { fg = color.fg_dim }

					highlight.DiagnosticVirtualTextError = { fg = color.red, bold = true }
					highlight.DiagnosticVirtualTextWarn = { fg = color.yellow, bold = true }
					highlight.DiagnosticVirtualTextInfo = { fg = color.blue, bold = true }
					highlight.DiagnosticVirtualTextHint = { fg = color.green, bold = true }

					highlight.DiagnosticUnderlineError = { undercurl = true, sp = color.red }
					highlight.DiagnosticUnderlineWarn = { undercurl = true, sp = color.yellow }
					highlight.DiagnosticUnderlineInfo = { undercurl = true, sp = color.blue }
					highlight.DiagnosticUnderlineHint = { undercurl = true, sp = color.green }

					highlight.ALEErrorSign = { fg = color.red, bold = true }
					highlight.ALEWarningSign = { fg = color.yellow, bold = true }

					-- Neovim tree-sitter highlights
					-- Identifiers
					highlight["@variable.parameter"] = { fg = color.cyan }
					highlight["@variable.parameter.builtin"] = { fg = color.cyan, italic = true }

					-- Literals
					highlight["@string.regex"] = { fg = color.green }
					highlight["@string.escape"] = { fg = color.yellow }
					highlight["@string.special"] = { fg = color.red }
					highlight["@string.special.path"] = { fg = color.blue }
					highlight["@string.special.url"] = { fg = color.cyan }

					-- Functions
					highlight["@constructor"] = { fg = color.yellow }

					-- Punctuation
					highlight["@punctuation.bracket"] = { fg = color.fg_main }
					highlight["@punctuation.special"] = { fg = color.fg_main }

					-- Comments
					highlight["@comment.error"] = { fg = color.red }
					highlight["@comment.warning"] = { fg = color.yellow }
					highlight["@comment.note"] = { fg = color.green }

					-- Markup
					highlight["@markup.strong"] = { bold = true }
					highlight["@markup.italic"] = { italic = true }
					highlight["@markup.strikethrough"] = { strikethrough = true }
					highlight["@markup.underline"] = { underline = true }
					highlight["@markup.heading.1"] = { fg = color.red, bold = true }
					highlight["@markup.heading.2"] = { fg = color.blue, bold = true }
					highlight["@markup.heading.3"] = { fg = color.green, bold = true }
					highlight["@markup.heading.4"] = { fg = color.yellow, bold = true }
					highlight["@markup.heading.5"] = { fg = color.purple, bold = true }
					highlight["@markup.heading.6"] = { fg = color.cyan, bold = true }
					highlight["@markup.quote"] = { italic = true }
					highlight["@markup.link"] = { fg = color.cyan }
					highlight["@markup.list"] = { fg = color.fg_main }
					highlight["@markup.list.checked"] = { fg = color.green }
					highlight["@markup.list.unchecked"] = { fg = color.yellow }

					highlight["@none"] = {}

					-- TSX specific
					highlight["@tag.tsx"] = { fg = color.red }
					highlight["@constructor.tsx"] = { fg = color.blue }
					highlight["@tag.delimiter.tsx"] = { fg = color.blue }

					-- Python specific

					-- Telescope
					highlight.TelescopeBorder = { fg = color.blue, bg = color.bg_main }
					highlight.TelescopeTitle = { fg = color.fg_dim, bg = color.bg_main }
					highlight.TelescopePromptBorder = { fg = color.red, bg = color.bg_main }
					highlight.TelescopePromptTitle = { fg = color.red, bg = color.bg_main }
					highlight.TelescopeResultsComment = { fg = color.fg_dim }

					-- NvimTree
					highlight.NvimTreeNormal = { fg = color.fg_main, bg = color.bg_dim }
					highlight.NvimTreeWinSeparator = { fg = color.blue, bg = color.blue }
					highlight.NvimTreeNormalNC = { fg = color.fg_dim, bg = color.bg_dim }
					highlight.NvimTreeRootFolder = { fg = color.red, bold = true }
					highlight.NvimTreeGitDirty = { fg = color.yellow }
					highlight.NvimTreeGitNew = { fg = color.green }
					highlight.NvimTreeGitDeleted = { fg = color.red }
					highlight.NvimTreeOpenedFile = { bg = color.bg_dim }
					highlight.NvimTreeSpecialFile = { fg = color.purple, underline = true }
					highlight.NvimTreeIndentMarker = { fg = color.fg_dim }
					highlight.NvimTreeImageFile = { fg = color.fg_main }
					highlight.NvimTreeFolderIcon = { bg = color.none, fg = color.blue }

					-- WhichKey
					highlight.WhichKey = { fg = color.cyan }
					highlight.WhichKeyGroup = { fg = color.blue }
					highlight.WhichKeyDesc = { fg = color.purple }
					highlight.WhichKeySeperator = { fg = color.fg_dim }
					highlight.WhichKeySeparator = { fg = color.fg_dim }
					highlight.WhichKeyFloat = { bg = color.bg_dim }
					highlight.WhichKeyValue = { fg = color.fg_dim }

					-- Yaml
					highlight["@property.yaml"] = { fg = color.fg_main }
					highlight["@string.yaml"] = { fg = color.blue }
					highlight["@punctuation.delimiter.yaml"] = { fg = color.pink, bold = true }
				end
			})
			vim.cmd("colorscheme modus")
		end,
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
			lspconfig.yamlls.setup {
				capabilities = capabilities,
				settings = {
					yaml = {
						schemas = {
							kubernetes = "k8s-*.yaml",
							["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
							["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
							["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/**/*.{yml,yaml}",
							["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
							["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
							["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
							["http://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}",
						},
					},
				},
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
	},
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
		}
	},
	{
		"m4xshen/hardtime.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		opts = {
			disabled_filetypes = { "spectre_panel", "oil", "qf", "help" }
		}
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
		end
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
	{
		"willothy/flatten.nvim",
		config = true,
		-- or pass configuration with
		-- opts = {  }
		-- Ensure that it runs first to minimize delay when opening file from terminal
		lazy = false,
		priority = 1001,
	},
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

vim.g.mapleader = "`"         -- using tick as leader key
vim.opt.cursorline = true     -- enable cursorline
vim.opt.relativenumber = true -- enable relative number

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
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				-- add different completion source
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				-- using default mapping preset
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
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
			"smartpde/telescope-recent-files"
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
				}
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
		cmd = "Copilot",
		build = ":Copilot auth",
		event = "InsertEnter",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = "<leader>j",
					accept_line = "<leader>l",
				}
			},
			panel = {
				enabled = true,
			},
		},
	},
	{
		"elixir-tools/elixir-tools.nvim",
		version = "*",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local elixir = require("elixir")
			local elixirls = require("elixir.elixirls")

			elixir.setup {
				nextls = { enable = true, spitfire = true },
				credo = {},
				elixirls = {
					enable = true,
					cmd = "/home/vscode/.elixir_ls/language_server.sh",
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
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "elixir", "eex", "heex" },
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.o.termguicolors = true
			vim.cmd([[colorscheme tokyonight-day]])
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
			{ "<leader>n", "<cmd>NvimTreeToggle<cr>" },
		}
	},
	"nvim-tree/nvim-web-devicons",
	{
		"luckasRanarison/tailwind-tools.nvim",
		opts = {
			custom_filetypes = { "heex", "elixir", "eelixir" },
		}
	}
})
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>p', function()
	builtin.lsp_document_symbols({ symbols = { "Function", "Method", "Field", "Variable" } })
end, {})
vim.keymap.set('n', '<C-b>', builtin.find_files, {})
vim.keymap.set('n', '<C-g>', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>td', builtin.diagnostics, {})
vim.keymap.set('n', '<leader>gs', builtin.grep_string, {})
vim.keymap.set('n', '<leader>gg', builtin.live_grep, {})
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, {})
vim.api.nvim_set_keymap("n", "<Leader><Leader>",
	[[<cmd>lua require('telescope').extensions.recent_files.pick()<CR>]],
	{ noremap = true, silent = true })

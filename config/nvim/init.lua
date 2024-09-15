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

require("lazy").setup({
	{ import = "plugins.format-on-save" },
	{ import = "plugins.nvim-cmp" },
	{ import = "plugins.telescope" },
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
	{ import = "plugins.nvim-treesitter" },
	{ import = "plugins.modus-themes" },
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("plugins.lspconfig").setup()
		end,
	},
	{ import = "plugins.output-panel" },
	{ import = "plugins.nvim-tree" },
	"nvim-tree/nvim-web-devicons",
	{ import = "plugins.tailwind-tools" },
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
	{ import = "plugins.nvim-surround" },
	{ import = "plugins.lsp_signature" },
	{ import = "plugins.flash" },
	{ import = "plugins.nvim-colorizer" },
	{ import = "plugins.nvim-spider" },
	{ import = "plugins.oil" },
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
	{ import = "plugins.obsidian" },
	{ import = "plugins.toggleterm" },
	{ import = "plugins.flatten" },
})

local trouble = require("trouble")
vim.keymap.set("n", "gd", function() trouble.open({ mode = "lsp_definitions" }) end,
	{ desc = "🔭 Definitions" })
vim.keymap.set("n", "gi", function() trouble.open({ mode = "lsp_implementations" }) end,
	{ desc = "🔭 Implementations" })
vim.keymap.set("n", "gR", function() trouble.open({ mode = "lsp_references" }) end,
	{ desc = "🔭 References" })

-- Call the setup function for Telescope
require("plugins.telescope").setup()

-- add keymaps for tabs
vim.keymap.set("n", "<leader>tn", ":tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader>to", ":tabonly<cr>", { desc = "Close Other Tabs" })
vim.keymap.set("n", "[t", ":tabprevious<cr>", { desc = "Previous Tab" })
vim.keymap.set("n", "]t", ":tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<A-<>", ":tabmove -1<cr>", { desc = "Move Tab Left" })
vim.keymap.set("n", "<A->>", ":tabmove +1<cr>", { desc = "Move Tab Right" })
vim.api.nvim_set_keymap("t", "<esc>", "<C-\\><C-n>", { noremap = true, silent = true })

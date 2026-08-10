-- Plugins safe to load inside Cursor via vscode-neovim.
-- Kept separate from lua/plugins/ so terminal nvim doesn't double-load them.

local parsers = {
	"elixir",
	"eex",
	"heex",
	"lua",
	"markdown",
	"markdown_inline",
	"yaml",
	"javascript",
	"typescript",
	"go",
	"gotmpl",
	"templ",
	"todotxt",
}

return {
	-- Treesitter parsing for mini.ai + flash treesitter (highlight off — Cursor paints)
	{
		"romus204/tree-sitter-manager.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tree-sitter-manager").setup({
				ensure_installed = parsers,
				auto_install = true,
				highlight = false,
			})

			vim.filetype.add({
				extension = {
					["md.eex"] = "markdown.eex",
					["html.heex"] = "html.heex",
					["md.tmpl"] = "markdown.gotexttmpl",
				},
			})

			vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
				pattern = "*.md.tmpl",
				callback = function(ev)
					vim.bo[ev.buf].filetype = "markdown.gotexttmpl"
				end,
				desc = "Set custom filetype for markdown template files",
			})
		end,
	},

	-- Text objects: cif, caf, cic, etc.
	{
		"echasnovski/mini.ai",
		version = false,
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
		},
		config = function()
			local miniai = require("mini.ai")
			local spec_treesitter = miniai.gen_spec.treesitter
			miniai.setup({
				n_lines = 500,
				custom_textobjects = {
					o = spec_treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}, {}),
					f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
					c = spec_treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
					s = spec_treesitter({ a = "@section.outer", i = "@section.inner" }, {}),
				},
			})
		end,
	},

	-- Jump: s, S, R, etc.
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
			{ "enter", mode = { "n" }, function() require("flash").jump() end, desc = "Flash Alt" },
			{ "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
			{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
			{ "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
		},
		config = function()
			vim.api.nvim_set_hl(0, "FlashLabel", { bg = "#000000", fg = "#ffffff", bold = true })
		end,
	},

	-- Persistent folds
	{
		"chrisgrieser/nvim-origami",
		event = "BufReadPost",
		keys = {
			{ "zm", "zM", desc = "Close all folds", remap = true },
			{ "zr", "zR", desc = "Open all folds", remap = true },
			{ "z0", ":set foldlevel=0<CR>", desc = "Close L0 Folds" },
			{ "z1", ":set foldlevel=1<CR>", desc = "Close L1 Folds" },
			{ "z2", ":set foldlevel=2<CR>", desc = "Close L2 Folds" },
			{ "z3", ":set foldlevel=3<CR>", desc = "Close L3 Folds" },
			{ "z4", ":set foldlevel=4<CR>", desc = "Close L4 Folds" },
		},
		opts = {
			foldKeymaps = { setup = true },
		},
		init = function()
			vim.opt.foldlevel = 99
			vim.opt.foldlevelstart = 99
		end,
	},

	-- Project search UI (nvim buffer — works in vscode-neovim)
	{
		"MagicDuck/grug-far.nvim",
		opts = {
			startInInsertMode = false,
			openTargetWindow = { preferredLocation = "right" },
		},
		keys = function()
			local grug_far = require("grug-far")
			return {
				{
					"<leader>sa",
					function()
						grug_far.open({ engine = "astgrep" })
					end,
					desc = "Search AST (grug-far)",
				},
				{
					"<leader>sw",
					function()
						grug_far.open({ prefills = { search = vim.fn.expand("<cword>") } })
					end,
					desc = "Search current word (grug-far)",
				},
				{
					"<leader>sf",
					function()
						grug_far.with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
					end,
					desc = "Search in file (grug-far)",
				},
				{
					"<leader>sr",
					function()
						grug_far.open()
					end,
					desc = "Search (grug-far)",
				},
			}
		end,
	},

	-- todo.txt editing
	{
		"phrmendes/todotxt.nvim",
		cmd = { "TodoTxt", "DoneTxt" },
		ft = "todotxt",
		keys = {
			{ "<leader>dt", "<cmd>TodoTxt<cr>", desc = "Toggle todo.txt" },
			{ "<leader>dd", "<cmd>DoneTxt<cr>", desc = "Toggle done.txt" },
			{ "<leader>dn", "<cmd>TodoTxt new<cr>", desc = "New todo entry" },
			{ "<leader>dg", "<cmd>TodoTxt ghost<cr>", desc = "Toggle ghost text" },
			{ "<cr>", "<Plug>(TodoTxtToggleState)", ft = "todotxt", desc = "Toggle task state" },
			{ "<localleader>p", "<Plug>(TodoTxtCyclePriority)", ft = "todotxt", desc = "Cycle priority" },
			{ "<localleader>m", "<Plug>(TodoTxtMoveDone)", ft = "todotxt", desc = "Move done tasks" },
			{ "<localleader>ss", "<Plug>(TodoTxtSortTasks)", ft = "todotxt", desc = "Sort tasks" },
			{ "<localleader>sp", "<Plug>(TodoTxtSortByPriority)", ft = "todotxt", desc = "Sort by priority" },
			{ "<localleader>sc", "<Plug>(TodoTxtSortByContext)", ft = "todotxt", desc = "Sort by context" },
			{ "<localleader>sP", "<Plug>(TodoTxtSortByProject)", ft = "todotxt", desc = "Sort by project" },
			{ "<localleader>sd", "<Plug>(TodoTxtSortByDueDate)", ft = "todotxt", desc = "Sort by due date" },
		},
		init = function()
			vim.filetype.add({
				filename = {
					["TODO.txt"] = "todotxt",
					["todo.txt"] = "todotxt",
					["done.txt"] = "todotxt",
				},
			})
		end,
		opts = {
			todotxt = vim.fn.expand("~/TODO.txt"),
			donetxt = vim.fn.expand("~/done.txt"),
			ghost_text = {
				enabled = true,
				mappings = {
					A = "now",
					B = "next",
					C = "today",
					D = "tomorrow",
					E = "this week",
					F = "later",
				},
			},
		},
	},
}

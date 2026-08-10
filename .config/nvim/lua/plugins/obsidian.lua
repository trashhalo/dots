return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	-- Also load when entering the vault, so commands like :Obsidian work
	-- without needing a markdown buffer first.
	event = {
		"BufReadPre " .. vim.fn.expand("~/dev/notes_2_0") .. "/**.md",
		"BufNewFile " .. vim.fn.expand("~/dev/notes_2_0") .. "/**.md",
		"BufReadPre " .. vim.fn.expand("~/dev/compliance") .. "/**.md",
		"BufNewFile " .. vim.fn.expand("~/dev/compliance") .. "/**.md",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/snacks.nvim",
	},
	keys = {
		{ "<leader>nn", "<cmd>Obsidian new<cr>",          desc = "Obsidian: new note" },
		{ "<leader>no", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian: quick switch" },
		{ "<leader>nd", "<cmd>Obsidian today<cr>",        desc = "Obsidian: today" },
		{ "<leader>ny", "<cmd>Obsidian yesterday<cr>",    desc = "Obsidian: yesterday" },
		{ "<leader>nt", "<cmd>Obsidian tomorrow<cr>",     desc = "Obsidian: tomorrow" },
		{ "<leader>ns", "<cmd>Obsidian search<cr>",       desc = "Obsidian: search" },
		{ "<leader>nb", "<cmd>Obsidian backlinks<cr>",    desc = "Obsidian: backlinks" },
		{ "<leader>nl", "<cmd>Obsidian links<cr>",        desc = "Obsidian: links" },
		{ "<leader>nT", "<cmd>Obsidian template<cr>",     desc = "Obsidian: insert template" },
		{ "<leader>np", "<cmd>Obsidian paste_img<cr>",    desc = "Obsidian: paste image" },
		{ "<leader>nr", "<cmd>Obsidian rename<cr>",       desc = "Obsidian: rename note" },
		{ "<leader>ng", "<cmd>Obsidian tags<cr>",         desc = "Obsidian: tags" },
		-- Follow link / go back work in any vault buffer.
		{ "gf",         function()
			if require("obsidian").util.cursor_on_markdown_link() then
				return "<cmd>Obsidian follow_link<cr>"
			end
			return "gf"
		end, expr = true, ft = "markdown", desc = "Obsidian: follow link / gf" },
	},
	opts = {
		workspaces = {
			{ name = "notes_2_0", path = "~/dev/notes_2_0" },
			{ name = "compliance", path = "~/dev/compliance" },
		},
		daily_notes = {
			folder = "Areas/Daily",
			date_format = "%Y-%m-%d",
		},
		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},
		picker = { name = "snacks.pick" },
		new_notes_location = "current_dir",
		preferred_link_style = "markdown",
		-- We already render markdown via render-markdown.nvim — disable the
		-- plugin's own concealing/UI so they don't fight.
		ui = { enable = false },
		attachments = {
			img_folder = "Resources/_attachments",
		},
	},
}

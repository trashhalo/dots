return {
	"folke/trouble.nvim",
	enabled = true,
	opts = {
		auto_jump = true,
		auto_preview = false,
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
		},
		{
			"gd",
			function()
				require("trouble").open({ mode = "lsp_definitions" })
			end,
			desc = "🔭 Definitions"
		},
		{
			"gi",
			function()
				require("trouble").open({ mode = "lsp_implementations" })
			end,
			desc = "🔭 Implementations"
		},
		{
			"gR",
			function()
				require("trouble").open({ mode = "lsp_references" })
			end,
			desc = "🔭 References"
		},
	}
}

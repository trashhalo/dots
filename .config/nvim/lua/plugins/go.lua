local function show_complete_type_info()
	-- Get the current word under cursor
	local cword = vim.fn.expand('<cword>')

	-- First get the type using LSP hover
	local current_buf = vim.api.nvim_get_current_buf()

	-- Use LSP to get the type information
	vim.lsp.buf_request(current_buf, 'textDocument/hover', vim.lsp.util.make_position_params(),
		function(err, result, ctx, config)
			if err or not result or not result.contents then
				vim.notify("Could not get type information", vim.log.levels.WARN)
				return
			end

			-- Extract the type name from hover result
			local content = result.contents.value or result.contents
			if type(content) == "table" then
				content = table.concat(content, "\n")
			end

			-- Try to extract the type name
			local type_name = content:match("([%w_%.]+)")

			if type_name then
				-- Now use GoDoc to get complete information about this type
				vim.cmd("GoDoc " .. type_name)
			else
				-- Fallback to just showing the hover info
				vim.lsp.handlers['textDocument/hover'](err, result, ctx, config)
			end
		end)
end

return {
	"ray-x/go.nvim",
	dependencies = { -- optional packages
		"ray-x/guihua.lua",
		"neovim/nvim-lspconfig",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("go").setup({
			verbose = true,
			lsp_cfg = {
				handlers = {
					['textDocument/hover'] = vim.lsp.with(
						vim.lsp.handlers.hover,
						{ border = 'double' }
					),
					['textDocument/signatureHelp'] = vim.lsp.with(
						vim.lsp.handlers.signature_help,
						{ border = 'round' }
					),
				},
			}
		})

		local format_sync_grp = vim.api.nvim_create_augroup("goimports", {})
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.go",
			callback = function()
				require('go.format').goimports()
			end,
			group = format_sync_grp,
		})
	end,
	event = { "CmdlineEnter" },
	ft = { "go", 'gomod' },
	build = ':lua require("go.install").update_all_sync()',
	keys = {
		{
			"<leader>k",
			function()
				show_complete_type_info()
			end,
			desc = "Show complete type info (Go)",
		},
	},

}

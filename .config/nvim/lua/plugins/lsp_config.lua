local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true
}

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"lukas-reineke/lsp-format.nvim"
	},
	config = function()
		local lspconfig = require('lspconfig')
		local util = require('lspconfig.util')
		local lsp_format = require('lsp-format')
		lsp_format.setup {}
		lspconfig.lua_ls.setup {
			settings = {
				Lua = {
					diagnostics = {
						globals = { 'vim', 'require' }
					}
				}
			},
			on_attach = lsp_format.on_attach
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
						["https://render.com/schema/render.yaml.json"] = "render.yaml",
					}
				}
			}
		}
		lspconfig.ts_ls.setup {}
		lspconfig.tailwindcss.setup {
			filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "templ" },
			init_options = { userLanguages = { templ = "html" } },
		}
		lspconfig.terraformls.setup {}
		lspconfig.templ.setup {}

		-- Use Neovim 0.11's built-in LSP config for ElixirLS
		vim.lsp.config('elixirls', {
			cmd = { '/opt/homebrew/bin/elixir-ls' },
			root_markers = { 'mix.exs', '.git' },
			filetypes = { 'elixir', 'eelixir', 'heex' },
			settings = {
				elixirLS = {
					autoBuild = true,
					dialyzerEnabled = false,
					suggestSpecs = false,
				}
			},
		})

		-- Hook up lsp-format for ElixirLS
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client.name == "elixirls" then
					lsp_format.on_attach(client, args.buf)
				end
			end,
		})

		vim.lsp.enable('elixirls')

		lspconfig.buf_ls.setup {
			on_attach = lsp_format.on_attach
		}

		-- Disable semantic tokens for protobuf files
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				local bufnr = args.buf
				local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
				if ft == "proto" and client and client.server_capabilities.semanticTokensProvider then
					client.server_capabilities.semanticTokensProvider = nil
				end
			end,
		})
	end
}

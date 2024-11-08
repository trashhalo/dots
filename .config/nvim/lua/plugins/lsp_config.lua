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
						["http://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}"
					}
				}
			}
		}
		lspconfig.ts_ls.setup {}
		lspconfig.tailwindcss.setup {}
		lspconfig.terraformls.setup {}
		lspconfig.lexical.setup {
			cmd = { vim.fs.joinpath(vim.fn.expand("~"), "dev", "lexical", "_build", "dev", "package", "lexical", "bin", "start_lexical.sh") },
			root_dir = function(fname)
				return util.root_pattern("mix.exs", ".git")(fname) or vim.loop.cwd()
			end,
			filetypes = { "elixir", "eelixir", "heex" },
			settings = {},
			on_attach = lsp_format.on_attach
		}
	end
}

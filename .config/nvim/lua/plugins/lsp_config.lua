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

		lspconfig.elixirls.setup {
			-- homebrew install
			cmd = { vim.fn.expand("/opt/homebrew/bin/elixir-ls") },
			root_dir = function(fname)
				return util.root_pattern("mix.exs", ".git")(fname) or vim.loop.cwd()
			end,
			settings = {
				elixirLS = {
					autoBuild = true,
					dialyzerEnabled = false,
					suggestSpecs = false,
				}
			},
			on_attach = lsp_format.on_attach,
		}

		lspconfig.buf_ls.setup {
			on_attach = lsp_format.on_attach
		}
	end
}

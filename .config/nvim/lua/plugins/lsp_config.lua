local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true
}

return {
	"neovim/nvim-lspconfig",
	config = function()
		local lspconfig = require('lspconfig')
		local util = require('lspconfig.util')
		lspconfig.lua_ls.setup {
			settings = {
				Lua = {
					diagnostics = {
						globals = { 'vim', 'require' }
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
						["http://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}"
					}
				}
			}
		}
		lspconfig.lexical.setup {
			cmd = { "/Users/stephensolka/dev/lexical/_build/dev/package/lexical/bin/start_lexical.sh" },
			root_dir = function(fname)
				return util.root_pattern("mix.exs", ".git")(fname) or vim.loop.cwd()
			end,
			filetypes = { "elixir", "eelixir", "heex" },
			-- optional settings
			settings = {}
		}
		lspconfig.ts_ls.setup {}
	end
}

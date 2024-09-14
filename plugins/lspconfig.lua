local M = {}

M.setup = function()
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
        },
      },
    },
  }
end

return M

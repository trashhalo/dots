return {
	"nvim-treesitter/nvim-treesitter",
	enabled = true,
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "elixir", "eex", "heex", "lua", "markdown", "yaml", "javascript", "typescript", "go", "gotmpl" },
			highlight = { enable = true, additional_vim_regex_highlighting = false },
			indent = { enable = true },
			inject = {
				enable = true,
				custom = {
					-- Inject gotmpl into markdown
					["gotmpl"] = {
						["markdown.gotmpl"] = {
							query = [[
            						  ((inline) @gotmpl)
            						  ((text) @gotmpl)
          						]],
							filter = function(lang, bufnr, match, metadata)
								local node_text = vim.treesitter.get_node_text(match[1],
									bufnr)
								return node_text:match("{{") ~= nil
							end
						}
					}
				}

			},
		})
		vim.filetype.add({
			extension = {
				['md.eex'] = 'markdown.eex'
			}
		})
		vim.filetype.add({
			extension = {
				['html.heex'] = 'html.heex'
			}
		})
		vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
			pattern = "*.md.tmpl",
			callback = function(ev)
				-- Set the filetype to markdown.gotexttmpl to inherit from both
				vim.bo[ev.buf].filetype = "markdown.gotexttmpl"
			end,
			desc = "Set custom filetype for markdown template files"
		})
		vim.filetype.add({
			extension = {
				["md.tmpl"] = "markdown.gotexttmpl"
			}
		})
	end,
}

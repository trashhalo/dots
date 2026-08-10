return {
	"romus204/tree-sitter-manager.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("tree-sitter-manager").setup({
			ensure_installed = {
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
			},
			auto_install = true,
			highlight = true,
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
}
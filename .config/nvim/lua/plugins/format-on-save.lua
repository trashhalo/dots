return {
	"elentok/format-on-save.nvim",
	config = function()
		local format_on_save = require("format-on-save")
		local formatters = require("format-on-save.formatters")
		format_on_save.setup({
			formatter_by_ft = {
				typescript = formatters.prettierd,
				javascript = formatters.prettierd,
				css = formatters.prettierd,
				markdown = formatters.prettierd,
				terraform = formatters.terraform_fmt,
			},
			experiments = {
				partial_update = 'diff'
			}
		})
	end
}

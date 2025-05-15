return {
	"github/copilot.vim",
	lazy = false,
	enabled = true,
	init = function()
		vim.g.copilot_no_tab_map = true
		vim.g.copilot_assume_mapped = true
		vim.g.copilot_tab_fallback = ""
		vim.cmd([[inoremap <silent><expr> <C-e> copilot#Accept("")]])
		vim.cmd([[inoremap <silent><expr> <C-l> <Plug>(copilot-accept-line)]])
	end,
}

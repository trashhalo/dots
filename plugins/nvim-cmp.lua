return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"ray-x/cmp-treesitter",
		"onsails/lspkind-nvim",
		"hrsh7th/cmp-nvim-lsp-signature-help"
	},
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")
		local has_words_before = function()
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			return col ~= 0 and
				vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" ==
				nil
		end

		cmp.setup({
			preselect = cmp.PreselectMode.None,
			window = {
				documentation = cmp.config.window.bordered(),
			},
			view = {
				entries = {
					name = "custom",
					selection_order = "near_cursor",
				},
			},
			confirm_opts = {
				behavior = cmp.ConfirmBehavior.Insert,
			},
			-- add different completion source
			sources = cmp.config.sources({
				{ name = 'nvim_lsp_signature_help' },
				{ name = "nvim_lsp" },
				{ name = "treesitter" },
			}),
			formatting = {
				expandable_indicator = true,
				fields = { "kind", "abbr", "menu" },
				format = lspkind.cmp_format {
					mode = "symbol",
					maxwidth = 60,
					menu = {
						treesitter = "󰌪",
						nvim_lsp = "󰀘",
						nvim_lsp_signature_help = "󰊕"
					}
				}
			},
			-- using default mapping preset
			mapping = cmp.mapping.preset.insert({
				['<CR>'] = cmp.mapping.confirm { select = true },
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif has_words_before() then
						cmp.complete()
					else
						fallback()
					end
				end, { 'i', 's' }),
				['<S-Tab>'] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					else
						fallback()
					end
				end, { 'i', 's' }),
			}),
			snippet = {
				-- you must specify a snippet engine
				expand = function(args)
					-- using neovim v0.10 native snippet feature
					-- you can also use other snippet engines
					vim.snippet.expand(args.body)
				end,
			},
		})
	end,
}

return {
	"miikanissi/modus-themes.nvim",
	lazy = false, -- make sure we load this during startup if it is your main colorscheme
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		vim.opt.background = "light"
		require("modus-themes").setup({
			on_colors = function(colors)
				-- Light background to match the map
				colors.bg_main = "#ffffff" -- White background
				colors.bg_dim = "#f5f5f5" -- Slightly off-white for contrast
				colors.bg_alt = "#e8e8e8" -- Light gray for alternative backgrounds
				colors.fg_main = "#000000" -- Black text for readability

				-- Colors inspired directly by the Tokyo subway map
				colors.red = "#f52f2f" -- Marunouchi Line
				colors.green = "#00b261" -- Chiyoda Line
				colors.yellow = "#D9A900" -- Ginza Line
				colors.blue = "#0079c2" -- Tozai Line
				colors.magenta = "#9c5e31" -- Fukutoshin Line
				colors.cyan = "#00a7db" -- Asakusa Line

				-- Additional colors from the map
				colors.orange = "#f39700" -- Ginza Line
				colors.brown = "#8f4b2e" -- Mita Line
				colors.pink = "#e85298" -- Hibiya Line
				colors.purple = "#9b7cb6" -- Hanzomon Line
				colors.lime = "#b5b5ac" -- Namboku Line

				-- Intense colors for highlights
				colors.red_intense = "#bd0000"
				colors.green_intense = "#006e3c"
				colors.yellow_intense = "#ffa400"
				colors.blue_intense = "#0054a6"
				colors.magenta_intense = "#6a3906"
				colors.cyan_intense = "#0089b3"

				-- Subtle background colors for syntax highlighting
				colors.bg_red_subtle = "#ffe5e5"
				colors.bg_green_subtle = "#e5ffe5"
				colors.bg_yellow_subtle = "#fffde5"
				colors.bg_blue_subtle = "#e5f2ff"
				colors.bg_magenta_subtle = "#ffe5f2"
				colors.bg_cyan_subtle = "#e5fcff"

				-- Special purpose
				colors.bg_status_line_active = "#d0d0d0"
				colors.fg_status_line_active = "#000000"
				colors.bg_status_line_inactive = "#e0e0e0"
				colors.fg_status_line_inactive = "#505050"

				-- Git diff colors (adjusted for light theme)
				colors.bg_added = "#e6ffec"
				colors.bg_changed = "#fff5cc"
				colors.bg_removed = "#ffebe9"
			end,
			on_highlights = function(highlight, color)
				highlight.Function = { fg = color.red, bold = true }
				highlight.String = { fg = color.blue }
				highlight.Number = { fg = color.orange }
				highlight.Boolean = { fg = color.green, bold = true }
				highlight.Keyword = { fg = color.magenta }
				highlight.Conditional = { fg = color.purple }
				highlight.Operator = { fg = color.cyan }
				highlight.Type = { fg = color.yellow }
				highlight.Comment = { fg = color.brown, italic = true }

				-- UI elements
				highlight.Visual = { bg = color.yellow, fg = color.bg_main }

				-- Popup menu
				highlight.Pmenu = { bg = color.bg_dim, fg = color.fg_main }
				highlight.PmenuSel = { bg = color.blue, fg = color.bg_main }

				-- Miscellaneous Syntax related non-standard highlights
				highlight.qfLineNr = { fg = color.fg_dim }
				highlight.qfFileName = { fg = color.blue }

				-- HTML headers
				highlight.htmlH1 = { fg = color.red, bold = true }
				highlight.htmlH2 = { fg = color.blue, bold = true }
				highlight.htmlH3 = { fg = color.green, bold = true }
				highlight.htmlH4 = { fg = color.yellow, bold = true }
				highlight.htmlH5 = { fg = color.purple, bold = true }
				highlight.htmlH6 = { fg = color.cyan, bold = true }

				-- Markdown
				highlight.mkdCodeDelimiter = { bg = color.bg_dim, fg = color.fg_main }
				highlight.mkdCodeStart = { fg = color.cyan, bold = true }
				highlight.mkdCodeEnd = { fg = color.cyan, bold = true }

				highlight.markdownHeadingDelimiter = { fg = color.orange, bold = true }
				highlight.markdownCode = { fg = color.cyan }
				highlight.markdownCodeBlock = { fg = color.cyan }
				highlight.markdownLinkText = { fg = color.blue, underline = true }
				highlight.markdownH1 = { fg = color.red, bold = true }
				highlight.markdownH2 = { fg = color.blue, bold = true }
				highlight.markdownH3 = { fg = color.green, bold = true }
				highlight.markdownH4 = { fg = color.yellow, bold = true }
				highlight.markdownH5 = { fg = color.purple, bold = true }
				highlight.markdownH6 = { fg = color.cyan, bold = true }

				-- LSP highlights
				highlight.LspCodeLens = { fg = color.fg_dim }
				highlight.LspInlayHint = { bg = color.bg_main, fg = color.fg_dim, italic = true }
				highlight.LspReferenceText = { bg = color.bg_dim, fg = color.fg_main }
				highlight.LspReferenceRead = { bg = color.bg_dim, fg = color.fg_main }
				highlight.LspReferenceWrite = { bg = color.bg_dim, fg = color.fg_main }
				highlight.LspInfoBorder = { fg = color.blue, bg = color.bg_main }

				-- Diagnostics
				highlight.DiagnosticError = { fg = color.red, bold = true }
				highlight.DiagnosticWarn = { fg = color.yellow, bold = true }
				highlight.DiagnosticInfo = { fg = color.blue, bold = true }
				highlight.DiagnosticHint = { fg = color.green, bold = true }
				highlight.DiagnosticUnnecessary = { fg = color.fg_dim }

				highlight.DiagnosticVirtualTextError = { fg = color.red, bold = true }
				highlight.DiagnosticVirtualTextWarn = { fg = color.yellow, bold = true }
				highlight.DiagnosticVirtualTextInfo = { fg = color.blue, bold = true }
				highlight.DiagnosticVirtualTextHint = { fg = color.green, bold = true }

				highlight.DiagnosticUnderlineError = { undercurl = true, sp = color.red }
				highlight.DiagnosticUnderlineWarn = {
					undercurl = true,
					sp = color.yellow
				}
				highlight.DiagnosticUnderlineInfo = { undercurl = true, sp = color.blue }
				highlight.DiagnosticUnderlineHint = { undercurl = true, sp = color.green }

				highlight.ALEErrorSign = { fg = color.red, bold = true }
				highlight.ALEWarningSign = { fg = color.yellow, bold = true }

				-- Neovim tree-sitter highlights
				-- Identifiers
				highlight["@variable.parameter"] = { fg = color.cyan }
				highlight["@variable.parameter.builtin"] = { fg = color.cyan, italic = true }

				-- Literals
				highlight["@string.regex"] = { fg = color.green }
				highlight["@string.escape"] = { fg = color.yellow }
				highlight["@string.special"] = { fg = color.red }
				highlight["@string.special.path"] = { fg = color.blue }
				highlight["@string.special.url"] = { fg = color.cyan }

				-- Functions
				highlight["@constructor"] = { fg = color.yellow }

				-- Punctuation
				highlight["@punctuation.bracket"] = { fg = color.fg_main }
				highlight["@punctuation.special"] = { fg = color.fg_main }

				-- Comments
				highlight["@comment.error"] = { fg = color.red }
				highlight["@comment.warning"] = { fg = color.yellow }
				highlight["@comment.note"] = { fg = color.green }

				-- Markup
				highlight["@markup.strong"] = { bold = true }
				highlight["@markup.italic"] = { italic = true }
				highlight["@markup.strikethrough"] = { strikethrough = true }
				highlight["@markup.underline"] = { underline = true }
				highlight["@markup.heading.1"] = { fg = color.red, bold = true }
				highlight["@markup.heading.2"] = { fg = color.blue, bold = true }
				highlight["@markup.heading.3"] = { fg = color.green, bold = true }
				highlight["@markup.heading.4"] = { fg = color.yellow, bold = true }
				highlight["@markup.heading.5"] = { fg = color.purple, bold = true }
				highlight["@markup.heading.6"] = { fg = color.cyan, bold = true }
				highlight["@markup.quote"] = { italic = true }
				highlight["@markup.link"] = { fg = color.cyan }
				highlight["@markup.list"] = { fg = color.fg_main }
				highlight["@markup.list.checked"] = { fg = color.green }
				highlight["@markup.list.unchecked"] = { fg = color.yellow }

				highlight["@none"] = {}

				-- TSX specific
				highlight["@tag.tsx"] = { fg = color.red }
				highlight["@constructor.tsx"] = { fg = color.blue }
				highlight["@tag.delimiter.tsx"] = { fg = color.blue }

				-- Python specific

				-- Telescope
				highlight.TelescopeBorder = { fg = color.blue, bg = color.bg_main }
				highlight.TelescopeTitle = { fg = color.fg_dim, bg = color.bg_main }
				highlight.TelescopePromptBorder = { fg = color.red, bg = color.bg_main }
				highlight.TelescopePromptTitle = { fg = color.red, bg = color.bg_main }
				highlight.TelescopeResultsComment = { fg = color.fg_dim }

				-- NvimTree
				highlight.NvimTreeNormal = { fg = color.fg_main, bg = color.bg_dim }
				highlight.NvimTreeWinSeparator = { fg = color.blue, bg = color.blue }
				highlight.NvimTreeNormalNC = { fg = color.fg_dim, bg = color.bg_dim }
				highlight.NvimTreeRootFolder = { fg = color.red, bold = true }
				highlight.NvimTreeGitDirty = { fg = color.yellow }
				highlight.NvimTreeGitNew = { fg = color.green }
				highlight.NvimTreeGitDeleted = { fg = color.red }
				highlight.NvimTreeOpenedFile = { bg = color.bg_dim }
				highlight.NvimTreeSpecialFile = { fg = color.purple, underline = true }
				highlight.NvimTreeIndentMarker = { fg = color.fg_dim }
				highlight.NvimTreeImageFile = { fg = color.fg_main }
				highlight.NvimTreeFolderIcon = { bg = color.none, fg = color.blue }

				-- WhichKey
				highlight.WhichKey = { fg = color.cyan }
				highlight.WhichKeyGroup = { fg = color.blue }
				highlight.WhichKeyDesc = { fg = color.purple }
				highlight.WhichKeySeperator = { fg = color.fg_dim }
				highlight.WhichKeySeparator = { fg = color.fg_dim }
				highlight.WhichKeyFloat = { bg = color.bg_dim }
				highlight.WhichKeyValue = { fg = color.fg_dim }

				-- Yaml
				highlight["@property.yaml"] = { fg = color.fg_main }
				highlight["@string.yaml"] = { fg = color.blue }
				highlight["@punctuation.delimiter.yaml"] = { fg = color.pink, bold = true }
			end
		})
		vim.cmd("colorscheme modus")
	end,
}

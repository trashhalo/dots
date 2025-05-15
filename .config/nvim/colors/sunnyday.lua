-- SunnyDay Neovim Color Scheme
-- A high-contrast theme optimized for readability in sunlight conditions
-- Author: Claude

local M = {}

-- Color Palette
local colors = {
	white = "#FFFFFF", -- Pure white background
	black = "#000000", -- Pure black text
	navy = "#000080", -- Deep navy for keywords
	dark_red = "#8B0000", -- Dark red for functions
	dark_green = "#006400", -- Dark green for strings
	purple = "#4B0082", -- Dark purple for types
	gray = "#CCCCCC", -- Subtle gray for cursor line
	light_blue = "#ADD8E6", -- Medium-light blue for selection
	yellow = "#FFFF00", -- Bright yellow for search
	red = "#FF0000", -- Pure red for errors
	orange = "#FF8C00", -- Dark orange for warnings
	blue = "#0000CD", -- Medium blue for info
	dark_gray = "#555555", -- Dark gray for comments
	teal = "#008080", -- Teal for special elements
	magenta = "#800080", -- Magenta for important elements
	cyan = "#008B8B", -- Cyan for UI elements

	-- Additional colors for plugins and specific cases
	light_gray = "#DDDDDD", -- Light gray for inactive elements
	medium_gray = "#999999", -- Medium gray for disabled items
	light_green = "#32CD32", -- Light green for success indicators
	light_red = "#FF6347", -- Light red for soft errors
	gold = "#FFD700", -- Gold for special highlights

	-- Git colors
	git = {
		add = "#006400", -- Dark green for git add
		change = "#0000CD", -- Medium blue for git change
		delete = "#8B0000", -- Dark red for git delete
	},

	-- Diff colors
	diff = {
		add = "#E6FFEC", -- Very light green for diff add
		change = "#E6F1FF", -- Very light blue for diff change
		delete = "#FFEEF0", -- Very light red for diff delete
		text = "#D1E5F9", -- Light blue for diff text
	},

	-- Border colors
	border = "#CCCCCC",    -- Regular border
	border_highlight = "#000080", -- Highlighted border

	-- Special indicators
	todo = "#FF8C00", -- Orange for TODO
	hint = "#008080", -- Teal for hints
	info = "#0000CD", -- Medium blue for info
	warning = "#FF8C00", -- Orange for warnings
	error = "#FF0000", -- Red for errors

	-- For treesitter rainbow parentheses
	rainbow = {
		"#8B0000", -- Dark red
		"#000080", -- Navy blue
		"#006400", -- Dark green
		"#4B0082", -- Purple
		"#800080", -- Magenta
		"#008080", -- Teal
		"#8B4513", -- Brown
	},

	-- Utility
	none = "NONE",
}

function M.setup()
	-- Clear all highlighting
	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") then
		vim.cmd("syntax reset")
	end

	-- Set colorscheme name
	vim.g.colors_name = "sunny-day"

	-- Set terminal colors
	vim.g.terminal_color_0 = colors.black
	vim.g.terminal_color_1 = colors.dark_red
	vim.g.terminal_color_2 = colors.dark_green
	vim.g.terminal_color_3 = colors.orange
	vim.g.terminal_color_4 = colors.navy
	vim.g.terminal_color_5 = colors.purple
	vim.g.terminal_color_6 = colors.teal
	vim.g.terminal_color_7 = colors.white
	vim.g.terminal_color_8 = colors.dark_gray
	vim.g.terminal_color_9 = colors.red
	vim.g.terminal_color_10 = colors.dark_green
	vim.g.terminal_color_11 = colors.yellow
	vim.g.terminal_color_12 = colors.blue
	vim.g.terminal_color_13 = colors.purple
	vim.g.terminal_color_14 = colors.teal
	vim.g.terminal_color_15 = colors.white

	-- Define highlight groups
	local highlights = {
		-- UI Elements
		Normal = { fg = colors.black, bg = colors.white },
		NormalNC = { fg = colors.black, bg = colors.white },
		NormalFloat = { fg = colors.black, bg = colors.white },
		Cursor = { fg = colors.white, bg = colors.black },
		CursorLine = { bg = colors.gray },
		CursorLineNr = { fg = colors.navy, bold = true },
		LineNr = { fg = colors.dark_gray },
		SignColumn = { bg = colors.white },
		VertSplit = { fg = colors.gray },
		StatusLine = { fg = colors.black, bg = colors.light_blue },
		StatusLineNC = { fg = colors.black, bg = colors.gray },
		Pmenu = { fg = colors.black, bg = colors.light_blue },
		PmenuSel = { fg = colors.white, bg = colors.navy },
		PmenuSbar = { bg = colors.gray },
		PmenuThumb = { bg = colors.dark_gray },
		TabLine = { fg = colors.black, bg = colors.gray },
		TabLineFill = { fg = colors.black, bg = colors.gray },
		TabLineSel = { fg = colors.white, bg = colors.navy, bold = true },
		Title = { fg = colors.dark_red, bold = true },
		Visual = { bg = colors.light_blue },
		MatchParen = { fg = colors.black, bg = colors.yellow, bold = true },

		-- Search and Selection
		Search = { fg = colors.black, bg = colors.yellow },
		IncSearch = { fg = colors.black, bg = colors.yellow, bold = true },
		CurSearch = { fg = colors.black, bg = colors.orange, bold = true },

		-- Diagnostics
		DiagnosticError = { fg = colors.error, bold = true },
		DiagnosticWarn = { fg = colors.warning },
		DiagnosticInfo = { fg = colors.info },
		DiagnosticHint = { fg = colors.hint },
		DiagnosticUnderlineError = { undercurl = true, sp = colors.error },
		DiagnosticUnderlineWarn = { undercurl = true, sp = colors.warning },
		DiagnosticUnderlineInfo = { undercurl = true, sp = colors.info },
		DiagnosticUnderlineHint = { undercurl = true, sp = colors.hint },
		DiagnosticVirtualTextError = { fg = colors.error, bg = colors.white },
		DiagnosticVirtualTextWarn = { fg = colors.warning, bg = colors.white },
		DiagnosticVirtualTextInfo = { fg = colors.info, bg = colors.white },
		DiagnosticVirtualTextHint = { fg = colors.hint, bg = colors.white },
		DiagnosticFloatingError = { fg = colors.error, bg = colors.white },
		DiagnosticFloatingWarn = { fg = colors.warning, bg = colors.white },
		DiagnosticFloatingInfo = { fg = colors.info, bg = colors.white },
		DiagnosticFloatingHint = { fg = colors.hint, bg = colors.white },
		DiagnosticSignError = { fg = colors.error },
		DiagnosticSignWarn = { fg = colors.warning },
		DiagnosticSignInfo = { fg = colors.info },
		DiagnosticSignHint = { fg = colors.hint },

		-- Basic Syntax
		Comment = { fg = colors.dark_gray, italic = true },
		String = { fg = colors.dark_green },
		Number = { fg = colors.purple },
		Boolean = { fg = colors.purple, bold = true },
		Float = { fg = colors.purple },
		Identifier = { fg = colors.black },
		Function = { fg = colors.dark_red },
		Statement = { fg = colors.navy, bold = true },
		Conditional = { fg = colors.navy, bold = true },
		Repeat = { fg = colors.navy, bold = true },
		Label = { fg = colors.navy },
		Operator = { fg = colors.black, bold = true },
		Keyword = { fg = colors.navy, bold = true },
		Exception = { fg = colors.red, bold = true },
		PreProc = { fg = colors.dark_red },
		Include = { fg = colors.dark_red, bold = true },
		Define = { fg = colors.dark_red },
		Macro = { fg = colors.dark_red },
		PreCondit = { fg = colors.dark_red },
		Type = { fg = colors.purple, bold = true },
		StorageClass = { fg = colors.purple, bold = true },
		Structure = { fg = colors.purple, bold = true },
		Typedef = { fg = colors.purple, bold = true },
		Special = { fg = colors.dark_red },
		SpecialChar = { fg = colors.dark_green },
		Tag = { fg = colors.navy },
		Delimiter = { fg = colors.black },
		SpecialComment = { fg = colors.dark_gray, bold = true },
		Debug = { fg = colors.orange },
		Underlined = { underline = true },
		Error = { fg = colors.red, bold = true },
		Todo = { fg = colors.black, bg = colors.yellow, bold = true },

		-- Language-specific
		markdownHeadingDelimiter = { fg = colors.orange, bold = true },
		markdownCode = { fg = colors.dark_green },
		markdownCodeBlock = { fg = colors.dark_green },
		markdownH1 = { fg = colors.rainbow[1], bold = true },
		markdownH2 = { fg = colors.rainbow[2], bold = true },
		markdownH3 = { fg = colors.rainbow[3], bold = true },
		markdownH4 = { fg = colors.rainbow[4], bold = true },
		markdownH5 = { fg = colors.rainbow[5], bold = true },
		markdownH6 = { fg = colors.rainbow[6], bold = true },
		markdownLinkText = { fg = colors.blue, underline = true },

		-- Floating windows
		FloatBorder = { fg = colors.border_highlight, bg = colors.white },
		FloatTitle = { fg = colors.border_highlight, bg = colors.white, bold = true },

		-- Diff viewing
		DiffAdd = { bg = colors.diff.add },
		DiffChange = { bg = colors.diff.change },
		DiffDelete = { bg = colors.diff.delete },
		DiffText = { bg = colors.diff.text },
		diffAdded = { fg = colors.git.add },
		diffRemoved = { fg = colors.git.delete },
		diffChanged = { fg = colors.git.change },
		diffOldFile = { fg = colors.dark_red },
		diffNewFile = { fg = colors.dark_green },

		-- Treesitter
		["@attribute"] = { fg = colors.purple, italic = true },
		["@boolean"] = { link = "Boolean" },
		["@character"] = { fg = colors.dark_green },
		["@comment"] = { link = "Comment" },
		["@conditional"] = { link = "Conditional" },
		["@constant"] = { fg = colors.purple },
		["@constant.builtin"] = { fg = colors.purple, bold = true },
		["@constant.macro"] = { fg = colors.purple, bold = true },
		["@constructor"] = { fg = colors.purple },
		["@error"] = { link = "Error" },
		["@exception"] = { link = "Exception" },
		["@field"] = { fg = colors.black },
		["@float"] = { link = "Float" },
		["@function"] = { link = "Function" },
		["@function.builtin"] = { fg = colors.dark_red, italic = true },
		["@function.macro"] = { fg = colors.dark_red, italic = true },
		["@include"] = { link = "Include" },
		["@keyword"] = { link = "Keyword" },
		["@keyword.function"] = { fg = colors.navy, bold = true },
		["@keyword.operator"] = { fg = colors.navy },
		["@label"] = { link = "Label" },
		["@method"] = { fg = colors.dark_red },
		["@namespace"] = { fg = colors.purple, italic = true },
		["@none"] = { fg = colors.black },
		["@number"] = { link = "Number" },
		["@operator"] = { link = "Operator" },
		["@parameter"] = { fg = colors.black },
		["@parameter.reference"] = { fg = colors.black },
		["@property"] = { fg = colors.black },
		["@punctuation.bracket"] = { fg = colors.black },
		["@punctuation.delimiter"] = { fg = colors.black },
		["@punctuation.special"] = { fg = colors.black },
		["@repeat"] = { link = "Repeat" },
		["@string"] = { link = "String" },
		["@string.escape"] = { fg = colors.dark_green, bold = true },
		["@string.regex"] = { fg = colors.dark_green, bold = true },
		["@structure"] = { link = "Structure" },
		["@tag"] = { fg = colors.navy, bold = true },
		["@tag.attribute"] = { fg = colors.purple },
		["@tag.delimiter"] = { fg = colors.black },
		["@text"] = { fg = colors.black },
		["@text.strong"] = { fg = colors.black, bold = true },
		["@text.emphasis"] = { fg = colors.black, italic = true },
		["@text.underline"] = { fg = colors.black, underline = true },
		["@text.strike"] = { fg = colors.black, strikethrough = true },
		["@text.title"] = { fg = colors.dark_red, bold = true },
		["@text.literal"] = { fg = colors.dark_green },
		["@text.uri"] = { fg = colors.blue, underline = true },
		["@text.todo"] = { link = "Todo" },
		["@text.note"] = { fg = colors.info, bold = true },
		["@text.warning"] = { fg = colors.warning, bold = true },
		["@text.danger"] = { fg = colors.error, bold = true },
		["@type"] = { link = "Type" },
		["@type.builtin"] = { fg = colors.purple, italic = true, bold = true },
		["@variable"] = { fg = colors.black },
		["@variable.builtin"] = { fg = colors.navy, italic = true },

		-- LSP
		LspReferenceText = { bg = colors.light_blue },
		LspReferenceRead = { bg = colors.light_blue },
		LspReferenceWrite = { bg = colors.light_blue },
		LspSignatureActiveParameter = { fg = colors.black, bg = colors.yellow },
		LspCodeLens = { fg = colors.dark_gray },
		LspInlayHint = { fg = colors.dark_gray, italic = true },

		-- LSP Kinds
		LspKindClass = { fg = colors.purple, bold = true },
		LspKindConstant = { fg = colors.purple },
		LspKindConstructor = { fg = colors.dark_red },
		LspKindEnum = { fg = colors.purple },
		LspKindEnumMember = { fg = colors.purple },
		LspKindEvent = { fg = colors.dark_red },
		LspKindField = { fg = colors.black },
		LspKindFile = { fg = colors.black },
		LspKindFolder = { fg = colors.dark_red },
		LspKindFunction = { fg = colors.dark_red },
		LspKindInterface = { fg = colors.purple },
		LspKindKeyword = { fg = colors.navy, bold = true },
		LspKindMethod = { fg = colors.dark_red },
		LspKindModule = { fg = colors.dark_red },
		LspKindOperator = { fg = colors.black, bold = true },
		LspKindProperty = { fg = colors.black },
		LspKindReference = { fg = colors.black },
		LspKindSnippet = { fg = colors.dark_red },
		LspKindStruct = { fg = colors.purple },
		LspKindText = { fg = colors.black },
		LspKindTypeParameter = { fg = colors.purple },
		LspKindUnit = { fg = colors.black },
		LspKindValue = { fg = colors.dark_green },
		LspKindVariable = { fg = colors.black },

		-- Git signs (from vim-gitgutter or gitsigns.nvim)
		GitSignsAdd = { fg = colors.git.add },
		GitSignsChange = { fg = colors.git.change },
		GitSignsDelete = { fg = colors.git.delete },
		GitGutterAdd = { fg = colors.git.add },
		GitGutterChange = { fg = colors.git.change },
		GitGutterDelete = { fg = colors.git.delete },

		-- Telescope
		TelescopeBorder = { fg = colors.border_highlight, bg = colors.white },
		TelescopeNormal = { fg = colors.black, bg = colors.white },
		TelescopePromptBorder = { fg = colors.orange, bg = colors.white },
		TelescopePromptTitle = { fg = colors.orange, bold = true, bg = colors.white },
		TelescopePreviewTitle = { fg = colors.navy, bold = true, bg = colors.white },
		TelescopeResultsTitle = { fg = colors.navy, bold = true, bg = colors.white },
		TelescopeMatching = { fg = colors.black, bg = colors.yellow },
		TelescopeSelection = { bg = colors.light_blue },
		TelescopeResultsLineNr = { fg = colors.dark_gray },

		-- nvim-cmp (Completion)
		CmpItemAbbrMatch = { fg = colors.black, bg = colors.yellow },
		CmpItemAbbrMatchFuzzy = { fg = colors.black, bg = colors.yellow },
		CmpItemMenu = { fg = colors.dark_gray },
		CmpItemKindDefault = { fg = colors.dark_gray },
		CmpItemKindCopilot = { fg = colors.teal },
		CmpItemKindCodeium = { fg = colors.teal },
		CmpItemKindTabNine = { fg = colors.teal },
		CmpItemKindFunction = { fg = colors.dark_red },
		CmpItemKindMethod = { fg = colors.dark_red },
		CmpItemKindVariable = { fg = colors.black },
		CmpItemKindKeyword = { fg = colors.navy },
		CmpItemKindText = { fg = colors.black },
		CmpItemKindConstant = { fg = colors.purple },
		CmpItemKindStruct = { fg = colors.purple },
		CmpItemKindClass = { fg = colors.purple },
		CmpItemKindModule = { fg = colors.dark_red },
		CmpItemKindProperty = { fg = colors.black },
		CmpItemKindUnit = { fg = colors.black },
		CmpItemKindFile = { fg = colors.dark_red },
		CmpItemKindFolder = { fg = colors.dark_red },
		CmpDocumentation = { fg = colors.black, bg = colors.white },
		CmpDocumentationBorder = { fg = colors.border_highlight, bg = colors.white },

		-- NvimTree
		NvimTreeNormal = { fg = colors.black, bg = colors.white },
		NvimTreeRootFolder = { fg = colors.navy, bold = true },
		NvimTreeFolderName = { fg = colors.navy },
		NvimTreeFolderIcon = { fg = colors.navy },
		NvimTreeOpenedFolderName = { fg = colors.navy, bold = true },
		NvimTreeEmptyFolderName = { fg = colors.dark_gray },
		NvimTreeIndentMarker = { fg = colors.gray },
		NvimTreeGitDirty = { fg = colors.orange },
		NvimTreeGitNew = { fg = colors.dark_green },
		NvimTreeGitDeleted = { fg = colors.red },
		NvimTreeSpecialFile = { fg = colors.purple, underline = true },
		NvimTreeImageFile = { fg = colors.dark_red },
		NvimTreeSymlink = { fg = colors.blue },

		-- Neogit
		NeogitBranch = { fg = colors.purple },
		NeogitRemote = { fg = colors.dark_red },
		NeogitHunkHeader = { bg = colors.gray, fg = colors.black },
		NeogitHunkHeaderHighlight = { bg = colors.light_blue, fg = colors.navy },
		NeogitDiffContextHighlight = { bg = colors.light_gray, fg = colors.black },
		NeogitDiffDeleteHighlight = { fg = colors.git.delete, bg = colors.diff.delete },
		NeogitDiffAddHighlight = { fg = colors.git.add, bg = colors.diff.add },

		-- Neotree
		NeoTreeNormal = { fg = colors.black, bg = colors.white },
		NeoTreeNormalNC = { fg = colors.black, bg = colors.white },
		NeoTreeVertSplit = { fg = colors.gray },
		NeoTreeIndentMarker = { fg = colors.gray },
		NeoTreeRootName = { fg = colors.navy, bold = true },
		NeoTreeFileName = { fg = colors.black },
		NeoTreeFileIcon = { fg = colors.dark_red },
		NeoTreeDirectoryIcon = { fg = colors.navy },
		NeoTreeDirectoryName = { fg = colors.navy },
		NeoTreeDotfile = { fg = colors.dark_gray },
		NeoTreeGitAdded = { fg = colors.git.add },
		NeoTreeGitModified = { fg = colors.orange },
		NeoTreeGitDeleted = { fg = colors.git.delete },

		-- Bufferline
		BufferLineIndicatorSelected = { fg = colors.navy },
		BufferLineFill = { bg = colors.light_gray },
		BufferLineBufferSelected = { fg = colors.black, bg = colors.light_blue, bold = true },
		BufferLineBuffer = { fg = colors.black, bg = colors.gray },
		BufferLineTab = { fg = colors.black, bg = colors.gray },
		BufferLineTabSelected = { fg = colors.white, bg = colors.navy },
		BufferLineTabClose = { fg = colors.red, bg = colors.gray },
		BufferLineCloseButton = { fg = colors.red, bg = colors.gray },
		BufferLineCloseButtonSelected = { fg = colors.red, bg = colors.light_blue },
		BufferLineModified = { fg = colors.orange, bg = colors.gray },
		BufferLineModifiedSelected = { fg = colors.orange, bg = colors.light_blue },

		-- Alpha Dashboard
		AlphaHeader = { fg = colors.navy },
		AlphaButtons = { fg = colors.dark_red },
		AlphaFooter = { fg = colors.dark_gray },
		AlphaShortcut = { fg = colors.orange, bold = true },

		-- WhichKey
		WhichKey = { fg = colors.teal },
		WhichKeyGroup = { fg = colors.blue },
		WhichKeyDesc = { fg = colors.purple },
		WhichKeySeperator = { fg = colors.dark_gray },
		WhichKeyValue = { fg = colors.dark_gray },

		-- Indent Blankline
		IndentBlanklineChar = { fg = colors.light_gray, nocombine = true },
		IndentBlanklineContextChar = { fg = colors.navy, nocombine = true },
		IblIndent = { fg = colors.light_gray, nocombine = true },
		IblScope = { fg = colors.navy, nocombine = true },

		-- Copilot and Codeium
		CopilotSuggestion = { fg = colors.dark_gray, italic = true },
		CodeiumSuggestion = { fg = colors.dark_gray, italic = true },

		-- Leap and Hop
		LeapMatch = { fg = colors.black, bg = colors.yellow, bold = true },
		LeapLabelPrimary = { fg = colors.white, bg = colors.purple, bold = true },
		LeapLabelSecondary = { fg = colors.black, bg = colors.yellow, bold = true },
		HopNextKey = { fg = colors.white, bg = colors.purple, bold = true },
		HopNextKey1 = { fg = colors.white, bg = colors.navy, bold = true },
		HopNextKey2 = { fg = colors.black, bg = colors.light_blue },
		HopUnmatched = { fg = colors.dark_gray },

		-- Notify
		NotifyERRORBorder = { fg = colors.red },
		NotifyERRORIcon = { fg = colors.red },
		NotifyERRORTitle = { fg = colors.red, bold = true },
		NotifyWARNBorder = { fg = colors.orange },
		NotifyWARNIcon = { fg = colors.orange },
		NotifyWARNTitle = { fg = colors.orange, bold = true },
		NotifyINFOBorder = { fg = colors.blue },
		NotifyINFOIcon = { fg = colors.blue },
		NotifyINFOTitle = { fg = colors.blue, bold = true },
		NotifyDEBUGBorder = { fg = colors.dark_gray },
		NotifyDEBUGIcon = { fg = colors.dark_gray },
		NotifyDEBUGTitle = { fg = colors.dark_gray, bold = true },
		NotifyTRACEBorder = { fg = colors.purple },
		NotifyTRACEIcon = { fg = colors.purple },
		NotifyTRACETitle = { fg = colors.purple, bold = true },

		-- DAP
		DapBreakpoint = { fg = colors.red },
		DapBreakpointCondition = { fg = colors.orange },
		DapLogPoint = { fg = colors.blue },
		DapStopped = { fg = colors.black, bg = colors.yellow },

		-- Rainbow Delimiters
		RainbowDelimiterRed = { fg = colors.rainbow[1] },
		RainbowDelimiterOrange = { fg = colors.orange },
		RainbowDelimiterYellow = { fg = colors.orange },
		RainbowDelimiterGreen = { fg = colors.rainbow[3] },
		RainbowDelimiterBlue = { fg = colors.rainbow[2] },
		RainbowDelimiterViolet = { fg = colors.rainbow[4] },
		RainbowDelimiterCyan = { fg = colors.teal },

		-- Mason
		MasonNormal = { fg = colors.black, bg = colors.white },
		MasonHeader = { fg = colors.white, bg = colors.navy, bold = true },
		MasonHeaderSecondary = { fg = colors.white, bg = colors.purple, bold = true },
		MasonHighlight = { fg = colors.dark_green },
		MasonHighlightBlock = { fg = colors.white, bg = colors.navy },
		MasonHighlightBlockBold = { fg = colors.white, bg = colors.navy, bold = true },
		MasonMuted = { fg = colors.dark_gray },
		MasonMutedBlock = { fg = colors.white, bg = colors.dark_gray },

		-- Lualine
		LualineMode = { fg = colors.white, bg = colors.navy, bold = true },
		LualineBranch = { fg = colors.purple, bg = colors.gray },
		LualineFileStatus = { fg = colors.black, bg = colors.light_blue },
		LualineDiagnostic = { fg = colors.black, bg = colors.light_blue },
		LualineProgressBar = { fg = colors.black, bg = colors.light_blue },

		-- Fidget
		FidgetTitle = { fg = colors.navy, bold = true },
		FidgetTask = { fg = colors.black },

		-- Navic
		NavicText = { fg = colors.black },
		NavicSeparator = { fg = colors.dark_gray },
		NavicIconsFile = { fg = colors.dark_red },
		NavicIconsModule = { fg = colors.dark_red },
		NavicIconsNamespace = { fg = colors.purple },
		NavicIconsClass = { fg = colors.purple },
		NavicIconsMethod = { fg = colors.dark_red },
		NavicIconsProperty = { fg = colors.black },
		NavicIconsField = { fg = colors.black },
		NavicIconsConstructor = { fg = colors.purple },
		NavicIconsEnum = { fg = colors.purple },
		NavicIconsInterface = { fg = colors.purple },
		NavicIconsFunction = { fg = colors.dark_red },
		NavicIconsVariable = { fg = colors.black },
		NavicIconsConstant = { fg = colors.purple },
		NavicIconsString = { fg = colors.dark_green },
		NavicIconsNumber = { fg = colors.purple },
		NavicIconsBoolean = { fg = colors.purple },
		NavicIconsArray = { fg = colors.purple },
		NavicIconsObject = { fg = colors.purple },
		NavicIconsKey = { fg = colors.navy },

		-- Noice
		NoiceCmdline = { fg = colors.black, bg = colors.light_blue },
		NoiceCmdlineIcon = { fg = colors.navy, bg = colors.light_blue },
		NoiceCmdlineIconSearch = { fg = colors.orange, bg = colors.light_blue },
		NoicePopupmenu = { fg = colors.black, bg = colors.white },
		NoicePopupmenuBorder = { fg = colors.border_highlight, bg = colors.white },
		NoicePopupmenuSelected = { fg = colors.black, bg = colors.light_blue },

		-- Mini.map
		MiniMapNormal = { fg = colors.dark_gray },
		MiniMapSymbolCount = { fg = colors.purple },
		MiniMapSymbolLine = { fg = colors.navy },

		-- Flash
		FlashBackdrop = { fg = colors.dark_gray },
		FlashLabel = { fg = colors.white, bg = colors.purple, bold = true },
		FlashMatch = { fg = colors.black, bg = colors.yellow },

		-- Headlines
		HeadlinesH1 = { fg = colors.rainbow[1], bg = colors.light_gray, bold = true },
		HeadlinesH2 = { fg = colors.rainbow[2], bg = colors.light_gray, bold = true },
		HeadlinesH3 = { fg = colors.rainbow[3], bg = colors.light_gray, bold = true },
		HeadlinesH4 = { fg = colors.rainbow[4], bg = colors.light_gray, bold = true },
		HeadlinesH5 = { fg = colors.rainbow[5], bg = colors.light_gray, bold = true },
		HeadlinesH6 = { fg = colors.rainbow[6], bg = colors.light_gray, bold = true },
		HeadlinesDashed = { fg = colors.black, bg = colors.light_gray },

		-- Illuminate
		IlluminatedWordText = { bg = colors.light_blue },
		IlluminatedWordRead = { bg = colors.light_blue },
		IlluminatedWordWrite = { bg = colors.light_blue },

		-- ALE
		ALEErrorSign = { fg = colors.error },
		ALEWarningSign = { fg = colors.warning },
		ALEInfoSign = { fg = colors.info },
		ALEHintSign = { fg = colors.hint },

		-- Lazy
		LazyNormal = { fg = colors.black, bg = colors.white },
		LazyButtonActive = { fg = colors.white, bg = colors.navy, bold = true },
		LazyButton = { fg = colors.black, bg = colors.gray },
		LazyH1 = { fg = colors.navy, bold = true },
		LazyH2 = { fg = colors.dark_red, bold = true },
		LazyReasonPlugin = { fg = colors.purple },
		LazyReasonStart = { fg = colors.dark_green },
		LazyReasonRuntime = { fg = colors.dark_red },
		LazyReasonEvent = { fg = colors.blue },
		LazyReasonKeys = { fg = colors.orange },
		LazyReasonSource = { fg = colors.dark_gray },
		LazyReasonFt = { fg = colors.purple },
		LazyReasonCmd = { fg = colors.navy },
		LazyReasonImport = { fg = colors.blue },
		LazyProgressDone = { fg = colors.purple, bold = true },
		LazyProgressTodo = { fg = colors.dark_gray },

		-- Trouble
		TroubleNormal = { fg = colors.black, bg = colors.white },
		TroubleText = { fg = colors.black },
		TroubleCount = { fg = colors.white, bg = colors.purple, bold = true },
		TroubleFile = { fg = colors.dark_red },
		TroubleLocation = { fg = colors.dark_gray },
		TroublePreview = { bg = colors.light_blue },
		TroubleSource = { fg = colors.dark_gray, italic = true },
		TroubleFoldIcon = { fg = colors.navy },
		TroubleError = { fg = colors.error },
		TroubleWarning = { fg = colors.warning },
		TroubleHint = { fg = colors.hint },
		TroubleInformation = { fg = colors.info },

		-- Folds
		Folded = { fg = colors.navy, bg = colors.light_gray },
		FoldColumn = { fg = colors.dark_gray, bg = colors.white },

		-- Misc UI elements
		WinSeparator = { fg = colors.border, bold = true },
		Directory = { fg = colors.navy },
		WildMenu = { bg = colors.light_blue },
		QuickFixLine = { bg = colors.light_blue, bold = true },
		FloatShadow = { bg = colors.black, blend = 70 },
		FloatShadowThrough = { bg = colors.black, blend = 100 },
		EndOfBuffer = { fg = colors.gray },
		SpecialKey = { fg = colors.dark_gray },
		NonText = { fg = colors.gray },
		ToolbarLine = { fg = colors.black, bg = colors.gray },
		ToolbarButton = { fg = colors.black, bg = colors.light_blue, bold = true },
		WinBar = { fg = colors.black, bg = colors.light_blue },
		WinBarNC = { fg = colors.dark_gray, bg = colors.gray },
		Question = { fg = colors.navy },
		MoreMsg = { fg = colors.navy },
		ErrorMsg = { fg = colors.error, bold = true },
		WarningMsg = { fg = colors.warning, bold = true },
		ModeMsg = { fg = colors.black, bold = true },
		MsgArea = { fg = colors.black },
		MsgSeparator = { fg = colors.border_highlight, bg = colors.gray },
		SpellBad = { undercurl = true, sp = colors.error },
		SpellCap = { undercurl = true, sp = colors.warning },
		SpellLocal = { undercurl = true, sp = colors.info },
		SpellRare = { undercurl = true, sp = colors.hint },
		Conceal = { fg = colors.dark_gray },
		Substitute = { bg = colors.red, fg = colors.white },
		Whitespace = { fg = colors.gray },

		-- Health
		healthError = { fg = colors.error },
		healthSuccess = { fg = colors.dark_green },
		healthWarning = { fg = colors.warning },

		-- Snacks Picker
		SnacksPickerInputBorder = { fg = colors.orange, bg = colors.white },
		SnacksPickerInputTitle = { fg = colors.orange, bg = colors.white, bold = true },
		SnacksPickerBoxTitle = { fg = colors.orange, bg = colors.white, bold = true },
		SnacksPickerSelected = { fg = colors.purple, bold = true },
		SnacksPickerToggle = { bg = colors.light_blue, fg = colors.navy },
		SnacksPickerPickWinCurrent = { fg = colors.white, bg = colors.purple, bold = true },
		SnacksPickerPickWin = { fg = colors.black, bg = colors.light_blue, bold = true },
	}

	-- Apply highlights
	for group, styles in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, styles)
	end
end

return M

-- Cursor / VS Code keymaps via vscode-neovim.
-- Loaded only when vim.g.vscode is set (see init.lua).
-- NOTE: must NOT be named vscode.lua — conflicts with the extension's require("vscode") module.

local vscode = require("vscode")
local opts = { noremap = true, silent = true }

local function map(mode, lhs, action, desc)
	vim.keymap.set(mode, lhs, function()
		vscode.action(action)
	end, vim.tbl_extend("force", opts, { desc = desc }))
end

local function map_vim(mode, lhs, fn, desc)
	vim.keymap.set(mode, lhs, fn, vim.tbl_extend("force", opts, { desc = desc }))
end

-- ── Navigation (Snacks picker equivalents) ────────────────────────────────────
map("n", "<D-p>", "workbench.action.quickOpen", "Smart find files")
map("n", "<leader>jf", "workbench.action.quickOpen", "Jump to file")
map("n", "<leader>jg", "workbench.action.findInFiles", "Jump to text (grep)")
map("n", "<leader>jb", "gitlens.openChangedFiles", "Jump to changed files")
map("n", "<leader>jk", "workbench.action.openGlobalKeybindings", "Jump to keymaps")
map("n", "<leader>jsb", "workbench.action.showAllEditors", "Search buffers")
map("n", "<leader>jm", "workbench.action.gotoSymbol", "Jump to symbol")
map("n", "<leader>jw", "workbench.action.showAllSymbols", "Jump to workspace symbol")
map("n", "<leader>jr", "workbench.action.openRecent", "Jump to recent")
map("n", "<leader>jh", "workbench.action.openWalkthrough", "Jump to help")
map("n", "<leader>jsd", "workbench.actions.view.problems", "Search diagnostics")
map("n", "<leader>jsr", "workbench.action.openPreviousEditorFromHistory", "Search resume")
map("n", "<leader>jsg", "workbench.action.findInFiles", "Search text (grep)")

-- Git pickers (Snacks <leader>ji* group)
map("n", "<leader>jib", "gitlens.showQuickBranchHistory", "Git branches")
map("n", "<leader>jil", "gitlens.showQuickRepoHistory", "Git log")
map("n", "<leader>jiL", "gitlens.showQuickFileHistory", "Git log (line)")
map("n", "<leader>jis", "gitlens.showQuickRepoStatus", "Git status")
map("n", "<leader>jif", "gitlens.openChangedFiles", "Git files")

-- Oil: reveal active file in sidebar explorer
map("n", "-", "workbench.files.action.showActiveFileInExplorer", "Reveal in explorer")
map("n", "gf", "editor.action.openLink", "Open link / file under cursor")

-- ── LSP navigation ──────────────────────────────────────────────────────────
map("n", "gd", "editor.action.revealDefinition", "Go to definition")
map("n", "gr", "editor.action.goToReferences", "Go to references")
map("n", "gR", "editor.action.showReferences", "References panel")
map("n", "gi", "editor.action.goToImplementation", "Go to implementation")
map("n", "gI", "editor.action.goToImplementation", "Go to implementation")

-- ── Tabs ────────────────────────────────────────────────────────────────────
map("n", "[t", "workbench.action.previousEditorInGroup", "Previous tab")
map("n", "]t", "workbench.action.nextEditorInGroup", "Next tab")
map("n", "gt", "workbench.action.nextEditorInGroup", "Next tab")
map("n", "gT", "workbench.action.previousEditorInGroup", "Previous tab")
map("n", "<leader>tn", "workbench.action.files.newUntitledFile", "New tab")
map("n", "<leader>tc", "workbench.action.closeActiveEditor", "Close tab")
map("n", "<leader>to", "workbench.action.closeOtherEditors", "Close other tabs")
map("n", "<A-<>", "workbench.action.moveEditorLeftInGroup", "Move tab left")
map("n", "<A->>", "workbench.action.moveEditorRightInGroup", "Move tab right")

-- ── Buffers & windows ───────────────────────────────────────────────────────
map("n", "[b", "workbench.action.previousEditor", "Previous buffer")
map("n", "]b", "workbench.action.nextEditor", "Next buffer")
map("n", "[w", "workbench.action.focusPreviousGroup", "Previous window")
map("n", "]w", "workbench.action.focusNextGroup", "Next window")
map("n", "<C-w>z", "workbench.action.toggleMaximizeEditorGroup", "Zoom window")

-- ── Diagnostics (Trouble / loclist equivalents) ─────────────────────────────
map("n", "[d", "editor.action.marker.prevInFiles", "Previous diagnostic")
map("n", "]d", "editor.action.marker.nextInFiles", "Next diagnostic")
map("n", "<space>xf", "editor.action.showHover", "Diagnostic float")
map("n", "<space>xl", "workbench.action.problems.focus", "Location list / problems")
map("n", "<leader>xx", "workbench.actions.view.problems", "Diagnostics panel")
map("n", "<leader>xX", "workbench.action.problems.focus", "Buffer diagnostics")
map("n", "<leader>xs", "outline.focus", "Symbols outline")
map("n", "<leader>xl", "editor.action.showReferences", "LSP locations panel")
map("n", "<leader>xL", "workbench.action.problems.focus", "Location list")
map("n", "<leader>xq", "workbench.actions.problems.quickfix", "Quickfix list")

-- ── Git hunks (gitsigns → git + GitLens) ────────────────────────────────────
map("n", "]g", "editor.action.dirtydiff.next", "Next hunk")
map("n", "[g", "editor.action.dirtydiff.previous", "Previous hunk")
map("n", "<leader>gj", "editor.action.dirtydiff.next", "Next hunk")
map("n", "<leader>gk", "editor.action.dirtydiff.previous", "Previous hunk")
map("n", "<leader>gs", "git.diff.stageHunk", "Stage hunk")
map("n", "<leader>gr", "git.revertSelectedRanges", "Reset hunk")
map("n", "<leader>gS", "git.stageAll", "Stage buffer")
map("n", "<leader>gR", "git.unstageAll", "Reset buffer")
map("n", "<leader>gp", "gitlens.showQuickCommitFileDetails", "Preview hunk")
map("n", "<leader>gi", "gitlens.diffLineWithPrevious", "Preview hunk inline")
map("n", "<leader>gb", "gitlens.toggleLineBlame", "Blame line")
map("n", "<leader>gd", "gitlens.diffWithPrevious", "Diff this")
map("n", "<leader>gw", "gitlens.toggleFileChanges", "Toggle word diff")

-- ── Format ──────────────────────────────────────────────────────────────────
map("n", "<leader>fa", "editor.action.formatDocument", "Format all")
map_vim("n", "<leader>fp", function()
	vim.cmd("normal! vip")
	vscode.action("editor.action.formatSelection")
end, "Format paragraph")
map_vim("v", "<leader>fs", function()
	vscode.action("editor.action.formatSelection")
end, "Format selection")

-- ── Toggles (Snacks / focus equivalents) ────────────────────────────────────
map_vim("n", "<leader>uh", function()
	local current = vscode.get_config("editor.inlayHints.enabled")
	if current == "on" then
		vscode.update_config("editor.inlayHints.enabled", "offUnlessPressed")
	else
		vscode.update_config("editor.inlayHints.enabled", "on")
	end
end, "Toggle inlay hints")
map("n", "<leader>ud", "workbench.action.toggleZenMode", "Toggle zen / dim")

-- ── Terminal ────────────────────────────────────────────────────────────────
map("n", "<leader>11", "workbench.action.togglePanel", "Toggle terminal")

-- ── Cursor AI (ACP / Claude Code equivalents) ───────────────────────────────
map("n", "<leader>a", "aichat.newchataction", "Open AI chat")
map("n", "<leader>aa", "composer.startComposerPrompt", "Open agent/composer")
map("n", "<leader>xc", "composer.startComposerPrompt", "Agent peek")
map("n", "<leader>xt", "composer.showComposerHistory", "Agent history")
map("n", "<leader>jcr", "composer.showComposerHistory", "Resume agent session")

-- ── SCM / lists (mini.clue leader groups) ───────────────────────────────────
map("n", "<leader>l", "workbench.action.problems.focus", "Location list")
map("n", "<leader>c", "workbench.actions.problems.quickfix", "Quickfix list")

-- Visual: disable space in visual mode (matches keymap.lua)
vim.keymap.set("x", "<Space>", "<Nop>", { silent = true })

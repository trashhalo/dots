return {
	"coder/claudecode.nvim",
	enabled = false, -- disabled: migrating to acp.nvim. Keybindings and init
	-- no longer load. Re-enable if the ACP path has issues to fall back.
	dependencies = { "folke/snacks.nvim" },
	event = "VeryLazy",
	init = function()
		-- claude-nvim-extras: personal integrations repo. Adds a Claude Code plugin
		-- (--plugin-dir below) that forwards tool-use events back into nvim, plus
		-- the lua side that turns them into a quickfix peek list.
		vim.opt.rtp:append(vim.fn.expand("~/dev/claude-nvim-extras"))
		require("claude-nvim-extras").setup()

		-- Email-style unified diff review for CC. Replaces the plugin's two-window
		-- side-by-side with a single quoted ("> ") unified diff buffer where you can
		-- interleave prose. ,a = accept clean, :w = same. ,r = reject + pipe your
		-- prose to the CC terminal as feedback for the next prompt.
		local transformed_diffs = {}

		local function send_to_cc(msg)
			local ok, tm = pcall(require, "claudecode.terminal")
			if not ok then return end
			local cc_buf = tm.get_active_terminal_bufnr and tm.get_active_terminal_bufnr()
			if not cc_buf then return end
			local chan = vim.bo[cc_buf].channel
			if not chan or chan == 0 then return end
			vim.api.nvim_chan_send(chan, msg)
			for _, w in ipairs(vim.fn.win_findbuf(cc_buf)) do
				vim.api.nvim_set_current_win(w)
				vim.cmd("startinsert")
				return
			end
		end

		local function transform_diff_to_unified(proposed_buf)
			local tab_name = vim.b[proposed_buf].claudecode_diff_tab_name
			local target_win = vim.b[proposed_buf].claudecode_diff_target_win
			local new_win = vim.b[proposed_buf].claudecode_diff_new_win
			if not tab_name or not target_win or not vim.api.nvim_win_is_valid(target_win) then return end

			local original_buf = vim.api.nvim_win_get_buf(target_win)
			local original_lines = vim.api.nvim_buf_get_lines(original_buf, 0, -1, false)
			local proposed_lines = vim.api.nvim_buf_get_lines(proposed_buf, 0, -1, false)
			local original_text = table.concat(original_lines, "\n") .. "\n"
			local proposed_text = table.concat(proposed_lines, "\n") .. "\n"
			local unified = vim.diff(original_text, proposed_text, {
				result_type = "unified",
				ctxlen = 3,
			})
			if not unified or unified == "" then unified = "(no changes)" end

			local quoted = {}
			for _, line in ipairs(vim.split(unified, "\n", { plain = true })) do
				table.insert(quoted, "> " .. line)
			end
			table.insert(quoted, "")
			table.insert(quoted, "")

			local review_buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(review_buf, 0, -1, false, quoted)
			vim.bo[review_buf].buftype = "acwrite"
			vim.bo[review_buf].bufhidden = "wipe"
			vim.bo[review_buf].swapfile = false
			vim.bo[review_buf].filetype = "ccreview"
			pcall(vim.api.nvim_buf_set_name, review_buf, "CC Review: " .. tab_name)
			vim.b[review_buf].claudecode_review = true

			pcall(vim.treesitter.stop, review_buf)

			-- For new-file diffs, original_buf is empty with no detected filetype.
			-- Fall back to the proposed buffer, then filename-based detection.
			local lang_ft = vim.bo[original_buf].filetype
			if lang_ft == "" then
				lang_ft = vim.bo[proposed_buf].filetype
			end
			if lang_ft == "" then
				local name = vim.api.nvim_buf_get_name(proposed_buf)
				if name ~= "" then
					lang_ft = vim.filetype.match({ filename = name }) or ""
				end
			end
			-- Highlighting strategy, in preference order:
			--   1. Treesitter parser available → color the prefix via syntax match,
			--      then overlay per-token extmarks from the TS `highlights` query
			--      against a code-only string assembled from the review lines.
			--   2. Legacy `syntax/<ft>.vim` file → embed via `syntax include @ccLang`
			--      + `contains=@ccLang` regions (works for python, c, etc.).
			--   3. Neither → plain diff colors on the whole line.
			local has_ts = false
			if lang_ft and lang_ft ~= "" then
				has_ts = pcall(vim.treesitter.language.add, lang_ft)
			end

			vim.api.nvim_buf_call(review_buf, function()
				vim.cmd("syntax clear")
				vim.cmd("unlet! b:current_syntax")
				local has_legacy = false
				if not has_ts and lang_ft and lang_ft ~= "" then
					has_legacy = pcall(vim.cmd, "syntax include @ccLang syntax/" .. lang_ft .. ".vim")
					vim.cmd("unlet! b:current_syntax")
				end
				-- File/hunk headers first so they win over the generic context region.
				vim.cmd([[syntax match ccReviewFile /^> \(---\|+++\) .*$/]])
				vim.cmd([[syntax match ccReviewHunk /^> @@.*$/]])
				if has_legacy then
					-- Embed the language under each diff line; matchgroup colors the prefix.
					vim.cmd(
					[[syntax region ccReviewAdd matchgroup=DiffAdd     start=/^> +/ end=/$/ keepend oneline contains=@ccLang]])
					vim.cmd(
					[[syntax region ccReviewDel matchgroup=DiffDelete  start=/^> -/ end=/$/ keepend oneline contains=@ccLang]])
					vim.cmd(
					[[syntax region ccReviewCtx matchgroup=Comment     start=/^> / end=/$/  keepend oneline contains=@ccLang]])
				elseif has_ts then
					-- Color only the prefix; code-portion coloring comes from TS extmarks.
					vim.cmd([[syntax match ccReviewAdd     /^> +/]])
					vim.cmd([[syntax match ccReviewDel     /^> -/]])
					vim.cmd([[syntax match ccReviewContext /^> /]])
					vim.cmd([[highlight default link ccReviewAdd     DiffAdd]])
					vim.cmd([[highlight default link ccReviewDel     DiffDelete]])
					vim.cmd([[highlight default link ccReviewContext Comment]])
				else
					vim.cmd([[syntax match ccReviewAdd     /^> +.*$/]])
					vim.cmd([[syntax match ccReviewDel     /^> -.*$/]])
					vim.cmd([[syntax match ccReviewContext /^> .*$/]])
					vim.cmd([[highlight default link ccReviewAdd     DiffAdd]])
					vim.cmd([[highlight default link ccReviewDel     DiffDelete]])
					vim.cmd([[highlight default link ccReviewContext Comment]])
				end
				vim.cmd([[highlight default link ccReviewFile Identifier]])
				vim.cmd([[highlight default link ccReviewHunk Special]])
			end)

			-- TS token highlights on the code portion of each diff line. We strip
			-- the "> +"/"> -"/">  " prefix (3 chars) to build a plain-code source,
			-- parse it, then translate captured ranges back to review-buf positions.
			if has_ts then
				local code_lines = {}
				local row_map = {} ---@type table<integer, integer> code row → review row (0-idx)
				for i, line in ipairs(quoted) do
					if line:match("^> [+%-%s]") then
						table.insert(code_lines, line:sub(4))
						row_map[#code_lines - 1] = i - 1
					end
				end
				local source = table.concat(code_lines, "\n")
				local ok_p, parser = pcall(vim.treesitter.get_string_parser, source, lang_ft)
				local ok_q, query = pcall(vim.treesitter.query.get, lang_ft, "highlights")
				local tree = ok_p and parser:parse()[1] or nil
				if tree and ok_q and query then
					local ns = vim.api.nvim_create_namespace("cc_review_ts")
					vim.api.nvim_buf_clear_namespace(review_buf, ns, 0, -1)
					for id, node in query:iter_captures(tree:root(), source) do
						local sr, sc, er, ec = node:range()
						local hl = "@" .. query.captures[id]
						for r = sr, er do
							local review_row = row_map[r]
							if review_row then
								local start_col = (r == sr) and sc + 3 or 3
								local opts = { hl_group = hl, priority = 110 }
								if r == er then
									opts.end_col = ec + 3
								else
									opts.hl_eol = true
									opts.end_line = review_row + 1
									opts.end_col = 0
								end
								pcall(vim.api.nvim_buf_set_extmark, review_buf, ns,
									review_row, start_col, opts)
							end
						end
					end
				end
			end

			-- Prevent BufUnload on the proposed buffer from triggering auto-reject
			-- when we close its window.
			vim.bo[proposed_buf].bufhidden = "hide"

			-- Close the original-side diff window, replace proposed window with review.
			-- Defer to next tick so the close doesn't cascade :diffupdate
			-- autocmds while still inside our BufEnter handler — that
			-- re-entrancy has segfaulted nvim (win_findbuf nil deref).
			if vim.api.nvim_win_is_valid(target_win) and target_win ~= new_win then
				local _tw = target_win
				vim.schedule(function()
					if vim.api.nvim_win_is_valid(_tw) then
						pcall(vim.api.nvim_win_close, _tw, true)
					end
				end)
			end
			if vim.api.nvim_win_is_valid(new_win) then
				vim.api.nvim_win_set_buf(new_win, review_buf)
				vim.api.nvim_set_current_win(new_win)
				-- Force normal mode whenever the review buffer is focused. A
				-- single stopinsert after set_current_win loses the race with
				-- snacks/terminal autocmds re-entering insert; this autocmd
				-- re-asserts normal mode on every BufEnter for the review buf.
				vim.api.nvim_create_autocmd("BufEnter", {
					buffer = review_buf,
					callback = function()
						if vim.fn.mode():sub(1, 1) == "i" then
							vim.cmd("stopinsert")
						end
					end,
				})
				vim.schedule(function() vim.cmd("stopinsert") end)
				vim.defer_fn(function()
					if vim.api.nvim_get_current_buf() == review_buf then
						vim.cmd("stopinsert")
					end
				end, 50)
			end

			local function accept()
				local ok, diff_mod = pcall(require, "claudecode.diff")
				if ok then diff_mod._resolve_diff_as_saved(tab_name, proposed_buf) end
				transformed_diffs[tab_name] = nil
				if vim.api.nvim_buf_is_valid(review_buf) then
					pcall(vim.api.nvim_buf_delete, review_buf, { force = true })
				end
			end

			local function reject_with_feedback()
				local lines = vim.api.nvim_buf_get_lines(review_buf, 0, -1, false)
				local has_prose = false
				for _, line in ipairs(lines) do
					if not line:match("^> ") and line:match("%S") then
						has_prose = true; break
					end
				end
				local feedback_msg = has_prose
				    and ("Reviewed your diff and rejected it. My inline comments:\n\n"
					    .. table.concat(lines, "\n") .. "\n")
				    or ""

				local ok, diff_mod = pcall(require, "claudecode.diff")
				if ok then diff_mod._resolve_diff_as_rejected(tab_name) end
				transformed_diffs[tab_name] = nil
				if vim.api.nvim_buf_is_valid(review_buf) then
					pcall(vim.api.nvim_buf_delete, review_buf, { force = true })
				end

				-- Wait for CC to process the rejection and surface its prompt, then
				-- submit the feedback as the next user turn.
				if feedback_msg ~= "" then
					vim.defer_fn(function() send_to_cc(feedback_msg .. "\r") end, 500)
				end
			end

			local function has_prose()
				for _, line in ipairs(vim.api.nvim_buf_get_lines(review_buf, 0, -1, false)) do
					if not line:match("^> ") and line:match("%S") then return true end
				end
				return false
			end

			vim.keymap.set("n", "<localleader>a", accept,
				{ buffer = review_buf, desc = "Accept CC diff (force)" })
			vim.keymap.set("n", "<localleader>r", reject_with_feedback,
				{ buffer = review_buf, desc = "Reject CC diff with feedback" })
			vim.api.nvim_create_autocmd("BufWriteCmd", {
				buffer = review_buf,
				callback = function()
					if has_prose() then reject_with_feedback() else accept() end
					return true
				end,
			})
		end

		local function try_transform(buf, attempts)
			if not vim.api.nvim_buf_is_valid(buf) then return end
			if vim.b[buf].claudecode_review then return end
			local tab_name = vim.b[buf].claudecode_diff_tab_name
			if tab_name then
				if transformed_diffs[tab_name] then return end
				transformed_diffs[tab_name] = true
				transform_diff_to_unified(buf)
			elseif attempts > 0 then
				vim.defer_fn(function() try_transform(buf, attempts - 1) end, 30)
			end
		end

		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("claudecode_diff_keys", { clear = true }),
			callback = function(ev) try_transform(ev.buf, 10) end,
		})

		-- Auto-follow terminal output in normal mode when cursor is near the bottom.
		-- Nvim only auto-scrolls in insert mode; this extends it to normal mode unless
		-- the user has scrolled up to read (>5 lines from bottom). Skip entirely while
		-- in terminal-job mode — nvim already follows there, and doing the work on
		-- every TUI repaint adds per-keystroke input lag.
		vim.api.nvim_create_autocmd("TermOpen", {
			group = vim.api.nvim_create_augroup("terminal_follow_output", { clear = true }),
			callback = function(ev)
				local buf = ev.buf
				vim.api.nvim_buf_attach(buf, false, {
					on_lines = function()
						if vim.fn.mode() == "t" then return end
						vim.schedule(function()
							if not vim.api.nvim_buf_is_valid(buf) then return end
							if vim.fn.mode() == "t" then return end
							local total = vim.api.nvim_buf_line_count(buf)
							for _, win in ipairs(vim.fn.win_findbuf(buf)) do
								local row = vim.api.nvim_win_get_cursor(win)[1]
								if total - row <= 5 then
									pcall(vim.api.nvim_win_set_cursor, win,
										{ total, 0 })
								end
							end
						end)
					end,
				})

				-- mini.clue skips unlisted buffers; snacks terminals are unlisted so
				-- enable triggers manually so <C-w>, <leader>, etc. show their popups.
				pcall(function() require("mini.clue").enable_buf_triggers(buf) end)

				-- CC-specific keymaps. Detect via snacks_terminal.cmd; set as buffer-local
				-- so they're guaranteed to register (snacks_win_opts.keys are baked in at
				-- terminal creation time and easy to miss when reloading config).
				local meta = vim.b[buf].snacks_terminal
				if meta and meta.cmd and meta.cmd:find("claude") then
					local function send(s)
						return function() vim.api.nvim_chan_send(vim.bo[buf].channel, s) end
					end
					vim.keymap.set("t", "<CR>", function()
						vim.api.nvim_chan_send(vim.bo[buf].channel, "\r")
						vim.cmd("stopinsert")
					end, { buffer = buf, desc = "Submit and exit to normal mode" })
					vim.keymap.set("n", "<localleader>y", send("1"),
						{ buffer = buf, desc = "Send 1 (yes)" })
					vim.keymap.set("n", "<localleader>a", send("2"),
						{ buffer = buf, desc = "Send 2 (accept)" })
					vim.keymap.set("n", "<localleader>n", send("3"),
						{ buffer = buf, desc = "Send 3 (no)" })
					vim.keymap.set("n", "1", send("1"), { buffer = buf, desc = "Send 1 (yes)" })
					vim.keymap.set("n", "2", send("2"), { buffer = buf, desc = "Send 2 (accept)" })
					vim.keymap.set("n", "3", send("3"), { buffer = buf, desc = "Send 3 (no)" })
					vim.keymap.set("n", "<CR>", send("\r"), { buffer = buf, desc = "Send Enter" })
					vim.keymap.set("n", "<localleader>m", send("\27[Z"),
						{ buffer = buf, desc = "Send Shift-Tab (cycle mode)" })
				end
			end,
		})

		-- Pick diff split orientation to match the CC terminal placement:
		-- narrow → stacked (diff on top, CC below); wide → side-by-side.
		-- diff.lua reads config.diff_opts.layout on every create_split(), and
		-- claudecode passes a live reference to state.config into diff.setup(),
		-- so mutating it here takes effect on the next diff.
		local function sync_diff_layout()
			local ok, cc = pcall(require, "claudecode")
			if not ok or not cc.state or not cc.state.config then return end
			cc.state.config.diff_opts = cc.state.config.diff_opts or {}
			cc.state.config.diff_opts.layout = vim.o.columns < 180 and "horizontal" or "vertical"
		end
		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyLoad",
			callback = function(ev)
				if ev.data == "claudecode.nvim" then sync_diff_layout() end
			end,
		})

		-- On resize, flip the CC terminal between vertical/horizontal split based on width.
		vim.api.nvim_create_autocmd("VimResized", {
			group = vim.api.nvim_create_augroup("cc_relayout", { clear = true }),
			callback = function()
				sync_diff_layout()

				local ok, tm = pcall(require, "claudecode.terminal")
				if not ok then return end
				local buf = tm.get_active_terminal_bufnr and tm.get_active_terminal_bufnr()
				if not buf then return end
				local wins = vim.fn.win_findbuf(buf)
				if #wins == 0 then return end
				local win = wins[1]
				if vim.api.nvim_win_get_config(win).relative ~= "" then return end -- skip floats

				local narrow = vim.o.columns < 180
				local is_vertical = vim.api.nvim_win_get_width(win) < vim.o.columns - 2
				vim.api.nvim_win_call(win, function()
					if narrow and is_vertical then
						vim.cmd("wincmd J")
						vim.cmd("resize " .. math.floor(vim.o.lines * 0.4))
					elseif not narrow and not is_vertical then
						vim.cmd("wincmd L")
						vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.3))
					end
				end)
			end,
		})
	end,
	opts = {
		terminal_cmd = "claude --mcp-config "
		    .. vim.fn.expand("~/.claude/mcp-nvim.json")
		    .. " --plugin-dir "
		    .. vim.fn.expand("~/dev/claude-nvim-extras/cc-plugin"),
		diff_opts = {
			open_in_new_tab = true,
		},
		terminal = {
			provider = "snacks",
		},
	},
	keys = {
		{
			"<leader>cc",
			function()
				-- Detect "fresh nvim" scenario: exactly one window, holding an empty
				-- unnamed buffer. If so, close that window after CC opens so we aren't
				-- left with the starter [No Name] buffer alongside Claude.
				local starter_win, starter_buf
				local wins = vim.api.nvim_tabpage_list_wins(0)
				if #wins == 1 then
					local w = wins[1]
					local b = vim.api.nvim_win_get_buf(w)
					local line_count = vim.api.nvim_buf_line_count(b)
					local first = line_count == 1 and vim.api.nvim_buf_get_lines(b, 0, 1, false)[1] or
					nil
					local is_empty = line_count == 0 or
					(line_count == 1 and (first == nil or first == ""))
					if vim.api.nvim_buf_get_name(b) == ""
					    and vim.bo[b].buftype == ""
					    and not vim.bo[b].modified
					    and is_empty
					then
						starter_win, starter_buf = w, b
					end
				end

				local narrow = vim.o.columns < 180
				local opts_override = narrow
				    and { snacks_win_opts = { position = "bottom", width = 0, height = 0.4 } }
				    or nil
				require("claudecode.terminal").simple_toggle(opts_override)
				vim.defer_fn(function() vim.cmd("stopinsert") end, 50)

				-- Also toggle the ccview mirror so it follows the CC terminal.
				-- Defer so claudecode.terminal has time to open/close first; then
				-- match mirror state to terminal state.
				vim.defer_fn(function()
					local ok_tm, tm = pcall(require, "claudecode.terminal")
					if not ok_tm then return end
					local term_buf = tm.get_active_terminal_bufnr and tm.get_active_terminal_bufnr()
					local term_open = term_buf and #vim.fn.win_findbuf(term_buf) > 0
					local ok_core, core = pcall(require, "claude-nvim-extras")
					if not (ok_core and core.mirror_toggle) then return end
					-- Peek at internal state via a helper — simpler to just call
					-- toggle and let it reconcile (it's idempotent w.r.t. state).
					local has_mirror_win = false
					for _, w in ipairs(vim.api.nvim_list_wins()) do
						if vim.api.nvim_win_is_valid(w) then
							local b = vim.api.nvim_win_get_buf(w)
							if vim.api.nvim_buf_get_name(b):match("Claude Mirror$") then
								has_mirror_win = true
								break
							end
						end
					end
					if term_open and not has_mirror_win then
						core.mirror_toggle()
						-- NOTE: we used to close the terminal window here so only
						-- the mirror was visible, but nvim's terminal emulator
						-- stops flushing pty output into the buffer when there's
						-- no window attached — which makes the mirror stale. The
						-- terminal has to stay visible for rendering to continue.
					elseif not term_open and has_mirror_win then
						core.mirror_toggle()
					end
				end, 120)

				if starter_win and starter_buf then
					vim.defer_fn(function()
						-- Bail if toggle closed CC instead of opening it, or starter is gone.
						if #vim.api.nvim_tabpage_list_wins(0) <= 1 then return end
						if not vim.api.nvim_win_is_valid(starter_win) then return end
						if not vim.api.nvim_buf_is_valid(starter_buf) then return end
						-- Re-verify nothing was typed into the starter buffer in the interim.
						if vim.bo[starter_buf].modified then return end
						if vim.api.nvim_buf_get_name(starter_buf) ~= "" then return end
						pcall(vim.api.nvim_win_close, starter_win, false)
						pcall(vim.api.nvim_buf_delete, starter_buf, {})
					end, 100)
				end
			end,
			desc = "Toggle Claude + mirror",
		},
		{
			"<leader>cs",
			"<cmd>ClaudeCodeSend<cr>",
			mode = "v",
			desc = "Send selection to Claude",
		},
		{
			"<leader>ck",
			":ClaudeEdit<cr>",
			mode = "v",
			desc = "Claude: edit selection inline",
		},
		{
			"<leader>cb",
			"<cmd>ClaudeCodeAdd %<cr>",
			desc = "Add current file",
		},
		{
			"<leader>cm",
			"<cmd>ClaudeMirror<cr>",
			desc = "Toggle ccview mirror (live scrollback)",
		},
		{
			"<localleader>g",
			"<cmd>ClaudeCompose<cr>",
			desc = "Compose Claude prompt",
		},
		{
			"<leader>cb",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			desc = "Add file from tree",
			ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
		},
	},
}

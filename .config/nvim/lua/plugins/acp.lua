	return {
	dir = vim.fn.expand("~/dev/acp.nvim"),
	name = "acp.nvim",
	lazy = false, -- small cost; loads the TS parser + commands at startup
	config = function()
		require("acp").setup({
			log_level = "info",
			adapters = {
				default = "claude_code",
			},
			permissions = {
				auto_accept = {
					-- uncomment as you trust things:
					-- "Bash(git *)",
					-- "Bash(mix *)",
					-- "Bash(npm *)",
					-- "Edit",
					-- "Write",
					-- "MultiEdit",
				},
			},
		})
	end,
	keys = {
		{
			"<leader>ac",
			function()
				-- Detect "fresh nvim" scenario: exactly one window holding an
				-- empty unnamed buffer (the starter). If so, close it after the
				-- chat opens so the chat takes the full screen instead of
				-- splitting alongside `[No Name]`.
				local starter_win, starter_buf
				local wins = vim.api.nvim_tabpage_list_wins(0)
				if #wins == 1 then
					local w = wins[1]
					local b = vim.api.nvim_win_get_buf(w)
					local line_count = vim.api.nvim_buf_line_count(b)
					local first = line_count == 1
						and vim.api.nvim_buf_get_lines(b, 0, 1, false)[1]
						or nil
					local is_empty = line_count == 0
						or (line_count == 1 and (first == nil or first == ""))
					if vim.api.nvim_buf_get_name(b) == ""
						and vim.bo[b].buftype == ""
						and not vim.bo[b].modified
						and is_empty
					then
						starter_win, starter_buf = w, b
					end
				end

				require("acp").chat()

				if starter_win and starter_buf then
					vim.defer_fn(function()
						if #vim.api.nvim_tabpage_list_wins(0) <= 1 then return end
						if not vim.api.nvim_win_is_valid(starter_win) then return end
						if not vim.api.nvim_buf_is_valid(starter_buf) then return end
						if vim.bo[starter_buf].modified then return end
						if vim.api.nvim_buf_get_name(starter_buf) ~= "" then return end
						pcall(vim.api.nvim_win_close, starter_win, false)
						pcall(vim.api.nvim_buf_delete, starter_buf, {})
					end, 50)
				end
			end,
			desc = "ACP: open chat (fullscreen on fresh nvim)",
		},
		{ "<leader>as", function() require("acp.chat").send() end,   desc = "ACP: send message" },
		{ "<leader>ax", function() require("acp.chat").cancel() end, desc = "ACP: cancel in-flight" },
		{ "<leader>aa", function() require("acp").pick_adapter() end, desc = "ACP: pick adapter" },
		-- Resume lives under `<leader>jcr` (picker namespace); see snacks.lua.
	},
}

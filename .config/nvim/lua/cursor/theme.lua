-- Apply sunnyday to nvim-owned buffers (grug-far, etc.) in light mode.
-- Main editor pixels come from the Cursor "Sunnyday" / "Everforest Dark" themes.

local M = {}

local function is_dark()
	if vim.o.background == "dark" then
		return true
	end
	if vim.o.background == "light" then
		return false
	end
	local style = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
	return style:match("Dark") ~= nil
end

function M.apply()
	if is_dark() then
		return
	end
	vim.o.background = "light"
	pcall(vim.cmd.colorscheme, "sunnyday")
end

function M.setup_autocmd()
	local group = vim.api.nvim_create_augroup("cursor.theme", { clear = true })
	vim.api.nvim_create_autocmd({ "UIEnter", "FocusGained" }, {
		group = group,
		callback = M.apply,
	})
end

return M

vim.g.mapleader = " "         -- using space as leader key
vim.g.maplocalleader = ','    -- using comma as local leader key
vim.opt.relativenumber = true -- enable relative number
vim.opt.background = "light"  -- set background to light
vim.opt.wrap = false          -- disable word wrap
vim.g.notimeout = true        -- disable timeout, which means that mappings will wait for the next key
vim.g.nottimeout = true       -- disable ttimmeout, the differnce between timeout and ttimeout is that the latter is for keycodes that are part of a sequence
vim.opt.directory = "/tmp/nvim"
vim.opt.autoread = true       -- reload files changed outside of nvim
vim.opt.mouse = "a"           -- enable mouse in all modes incl. terminal (scroll passthrough to Claude TUI)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
	pattern = "*",
	command = "checktime",
	desc = "Refresh buffers when external tools (e.g. Claude) edit files",
})
require("keymap") -- load keymap.lua

if vim.g.vscode then
	require("vscode_keymaps")
	require("cursor.lazy").setup(require("cursor.plugins"))
	require("cursor.theme").setup_autocmd()
	return
end

-- bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
		lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Suppress lspconfig deprecation warning
local original_deprecate = vim.deprecate
vim.deprecate = function(name, alternative, version, plugin, backtrace)
	if name and name:match("lspconfig") then
		return
	end
	return original_deprecate(name, alternative, version, plugin, backtrace)
end

require("lazy").setup({ {
	import = "plugins"
} }, {
	rocks = { enabled = false },
	change_detection = { notify = false },
})

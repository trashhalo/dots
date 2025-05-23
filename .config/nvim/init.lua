vim.g.mapleader = " "         -- using space as leader key
vim.g.maplocalleader = ','    -- using comma as local leader key
vim.opt.relativenumber = true -- enable relative number
vim.opt.background = "light"  -- set background to light
vim.opt.wrap = false          -- disable word wrap
vim.g.notimeout = true        -- disable timeout, which means that mappings will wait for the next key
vim.g.nottimeout = true       -- disable ttimmeout, the differnce between timeout and ttimeout is that the latter is for keycodes that are part of a sequence
vim.opt.directory = "/tmp/nvim"
require("keymap")             -- load keymap.lua

-- bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
		lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ {
	import = "plugins"
} })

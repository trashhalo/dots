vim.g.mapleader = "," -- using tick as leader key
vim.opt.relativenumber = true -- enable relative number
vim.opt.background = "light" -- set background to light
vim.g.notimeout = true -- disable timeout, which means that mappings will wait for the next key
vim.g.nottimeout = true -- disable ttimmeout, the differnce between timeout and ttimeout is that the latter is for keycodes that are part of a sequence

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

-- bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
                   lazypath})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")


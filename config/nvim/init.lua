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

local trouble = require("trouble")
vim.keymap.set("n", "gd", function()
    trouble.open({
        mode = "lsp_definitions"
    })
end, {
    desc = "🔭 Definitions"
})
vim.keymap.set("n", "gi", function()
    trouble.open({
        mode = "lsp_implementations"
    })
end, {
    desc = "🔭 Implementations"
})
vim.keymap.set("n", "gR", function()
    trouble.open({
        mode = "lsp_references"
    })
end, {
    desc = "🔭 References"
})

-- Call the setup function for Telescope
require("plugins.telescope").setup()

-- add keymaps for tabs
vim.keymap.set("n", "<leader>tn", ":tabnew<cr>", {
    desc = "New Tab"
})
vim.keymap.set("n", "<leader>tc", ":tabclose<cr>", {
    desc = "Close Tab"
})
vim.keymap.set("n", "<leader>to", ":tabonly<cr>", {
    desc = "Close Other Tabs"
})
vim.keymap.set("n", "[t", ":tabprevious<cr>", {
    desc = "Previous Tab"
})
vim.keymap.set("n", "]t", ":tabnext<cr>", {
    desc = "Next Tab"
})
vim.keymap.set("n", "<A-<>", ":tabmove -1<cr>", {
    desc = "Move Tab Left"
})
vim.keymap.set("n", "<A->>", ":tabmove +1<cr>", {
    desc = "Move Tab Right"
})
vim.api.nvim_set_keymap("t", "<esc>", "<C-\\><C-n>", {
    noremap = true,
    silent = true
})

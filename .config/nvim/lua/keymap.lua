local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>xf', vim.diagnostic.open_float,
	vim.tbl_extend('force', opts, { desc = 'Open diagnostic float' }))
vim.keymap.set('n', '<space>xl', vim.diagnostic.setloclist, vim.tbl_extend('force', opts, { desc = 'Set loclist' }))
vim.keymap.set('x', '<Space>', '<Nop>', { silent = true })

-- Format
vim.keymap.set('n', '<leader>fa', 'gg0vG$gq', { desc = 'Format all' })
vim.keymap.set('n', '<leader>fp', 'gqip', { desc = 'Format paragraph' })
vim.keymap.set('v', '<leader>fs', 'ggVGgq', { desc = 'Format selection' })

-- Previous Next
vim.keymap.set('n', '[w', '<C-w>W', vim.tbl_extend('force', opts, { desc = 'Previous window' }))
vim.keymap.set('n', ']w', '<C-w>w', vim.tbl_extend('force', opts, { desc = 'Next window' }))
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
vim.keymap.set('n', '[b', ':bprevious<CR>', vim.tbl_extend('force', opts, { desc = 'previous buffer' }))
vim.keymap.set('n', ']b', ':bnext<CR>', vim.tbl_extend('force', opts, { desc = 'Next buffer' }))

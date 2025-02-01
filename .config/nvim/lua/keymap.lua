local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>xf', vim.diagnostic.open_float,
	vim.tbl_extend('force', opts, { desc = 'open diagnostic float' }))
vim.keymap.set('n', '<space>xl', vim.diagnostic.setloclist, vim.tbl_extend('force', opts, { desc = 'set loclist' }))
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend('force', opts, { desc = 'go to previous diagnostic' }))
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend('force', opts, { desc = 'go to next diagnostic' }))

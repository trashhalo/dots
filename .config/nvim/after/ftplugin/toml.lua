vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = [[getline(v:lnum)=~'^\['?'>1':'=']]
vim.opt_local.foldlevel = 0

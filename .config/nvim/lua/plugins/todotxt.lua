return {
	"phrmendes/todotxt.nvim",
	cmd = { "TodoTxt", "DoneTxt" },
	ft = "todotxt",
	keys = {
		-- Global commands (available anywhere)
		{ "<leader>dt",      "<cmd>TodoTxt<cr>",               desc = "Toggle todo.txt" },
		{ "<leader>dd",      "<cmd>DoneTxt<cr>",               desc = "Toggle done.txt" },
		{ "<leader>dn",      "<cmd>TodoTxt new<cr>",           desc = "New todo entry" },
		{ "<leader>dg",      "<cmd>TodoTxt ghost<cr>",         desc = "Toggle ghost text" },

		-- Filetype-specific commands (only in todo.txt files)
		{ "<cr>",            "<Plug>(TodoTxtToggleState)",     ft = "todotxt",              desc = "Toggle task state" },
		{ "<localleader>p",  "<Plug>(TodoTxtCyclePriority)",   ft = "todotxt",              desc = "Cycle priority" },
		{ "<localleader>m",  "<Plug>(TodoTxtMoveDone)",        ft = "todotxt",              desc = "Move done tasks" },
		{ "<localleader>ss", "<Plug>(TodoTxtSortTasks)",       ft = "todotxt",              desc = "Sort tasks" },
		{ "<localleader>sp", "<Plug>(TodoTxtSortByPriority)",  ft = "todotxt",              desc = "Sort by priority" },
		{ "<localleader>sc", "<Plug>(TodoTxtSortByContext)",   ft = "todotxt",              desc = "Sort by context" },
		{ "<localleader>sP", "<Plug>(TodoTxtSortByProject)",   ft = "todotxt",              desc = "Sort by project" },
		{ "<localleader>sd", "<Plug>(TodoTxtSortByDueDate)",   ft = "todotxt",              desc = "Sort by due date" },
	},
	init = function()
		vim.filetype.add({
			filename = {
				["TODO.txt"] = "todotxt",
				["todo.txt"] = "todotxt",
				["done.txt"] = "todotxt",
			},
		})
	end,
	opts = {
		todotxt = vim.fn.expand("~/TODO.txt"),
		donetxt = vim.fn.expand("~/done.txt"),
		ghost_text = {
			enabled = true,
			mappings = {
				A = "now",
				B = "next",
				C = "today",
				D = "tomorrow",
				E = "this week",
				F = "later",
			},
		},
	},
}

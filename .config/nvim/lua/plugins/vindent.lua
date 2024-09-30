return {
	"jessekelighine/vindent.vim",
	event = "VimEnter",
	init = function()
		vim.g.vindent_motion_OO_prev = '[l'
		vim.g.vindent_motion_OO_next = ']l'
		vim.g.vindent_motion_less_prev = '[-'
		vim.g.vindent_motion_less_next = ']-'
		vim.g.vindent_motion_more_prev = '[='
		vim.g.vindent_motion_more_next = ']='
		vim.g.vindent_motion_XX_ss = '[p'
		vim.g.vindent_motion_XX_se = ']p'
		vim.g.vindent_motion_OX_ss = '[P'
		vim.g.vindent_motion_OX_se = ']P'
		vim.g.vindent_object_OO_ii = 'iI'
		vim.g.vindent_object_XX_ii = 'ii'
		vim.g.vindent_object_XX_ai = 'ai'
		vim.g.vindent_object_XX_aI = 'aI'
		vim.g.vindent_jumps = 1
		vim.g.vindent_begin = 1
		vim.g.vindent_count = 0
	end,
	config = function()
	end
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		lazy = false,
		config = function()
			require('nvim-treesitter.configs').setup({
				ensure_installed = { 'go', 'lua', 'python', 'typescript', 'javascript', 'html', 'css', 'java' },
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				}
			})
		end
	}
}

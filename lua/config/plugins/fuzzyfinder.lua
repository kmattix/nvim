return {
	'nvim-telescope/telescope.nvim',
	tag = '0.1.8',
	-- or                              , branch = '0.1.x',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		-- Keymaps
		local builtin = require('telescope.builtin')
		-- Function to determine if we're inside a Git repo
		local function is_git_repo()
			local handle = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null")
			local result = handle:read("*a")
			handle:close()
			return result == "true\n"
		end
		vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
		-- Fallback for git_files
		vim.keymap.set('n', '<C-p>', function()
			if is_git_repo() then
				builtin.git_files()
			else
				builtin.find_files()
			end
		end, {})
		vim.keymap.set('n', '<leader>ps', function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end)

		local telescope = require('telescope')
		local telescopeConfig = require('telescope.config')

		-- Clone the default Telescope configuration
		local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

		-- Add flags to follow symlinks and include hidden files
		table.insert(vimgrep_arguments, '-L')       -- Follow symlinks
		table.insert(vimgrep_arguments, '--hidden') -- Include hidden files
		table.insert(vimgrep_arguments, '--glob')
		table.insert(vimgrep_arguments, '!**/.git/*') -- Exclude .git directories

		telescope.setup({
			defaults = {
				vimgrep_arguments = vimgrep_arguments,
			},
			pickers = {
				find_files = {
					find_command = { 'rg', '--files', '--glob', '!**/.git/*', '-L' },
				},
			},
		})
	end,
}

return {
	'nvim-telescope/telescope.nvim',
	tag = '0.1.8',
	-- or                              , branch = '0.1.x',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		-- Keymaps
		vim.keymap.set('n', '<C-p>', function()
			local buf_dir = vim.fn.expand('%:p:h')
			local ok = os.execute('git -C ' ..
				vim.fn.shellescape(buf_dir) .. ' rev-parse --is-inside-work-tree >/dev/null 2>&1') == 0
			if ok then
				local root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(buf_dir) .. ' rev-parse --show-toplevel')[1]
				require('telescope.builtin').git_files({ cwd = root })
			else
				require('telescope.builtin').find_files({ cwd = buf_dir })
			end
		end)
		vim.keymap.set('n', '<leader>ps', function()
			require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ") })
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

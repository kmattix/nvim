return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  -- or                              , branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    -- Keymaps
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<C-p>', function()
      local function get_git_root(dir)
        local dot = vim.fn.finddir(".git", dir .. ";")
        if dot == "" then return nil end
        return vim.fn.fnamemodify(dot, ":h")
      end
      local buf_dir = vim.fn.expand('%:p:h')
      local root = get_git_root(buf_dir)
      if root then
        builtin.git_files({ cwd = root })
      else
        builtin.find_files({ cwd = buf_dir })
      end
    end)
    vim.keymap.set('n', '<leader>ps', function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end)

    local telescope = require('telescope')
    local telescopeConfig = require('telescope.config')

    -- Clone the default Telescope configuration
    local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

    -- Add flags to follow symlinks and include hidden files
    table.insert(vimgrep_arguments, '-L')         -- Follow symlinks
    table.insert(vimgrep_arguments, '--hidden')   -- Include hidden files
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

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			'saghen/blink.cmp',
			{
				"folke/lazydev.nvim",
				ft = "lua", -- only load on lua files
				opts = {
					library = {
						-- See the configuration section for more details
						-- Load luvit types when the `vim.uv` word is found
						{ path = "luvit-meta/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		config = function()
			-- Incude LSPs
			local lsp_servers = { "lua_ls", "gopls", }
			for _, lsp in ipairs(lsp_servers) do
				vim.lsp.enable(lsp)
				vim.lsp.config(lsp, {
					capabilities = require('blink.cmp').get_lsp_capabilities()
				})
			end

			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(args)
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
					if not client then return end

					-- Auto-format ("lint") on save.
					if client:supports_method('textDocument/formatting') then
						vim.api.nvim_create_autocmd('BufWritePre', {
							buffer = args.buf,
							callback = function()
								vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
							end,
						})
					end

					-- Inline diagnostics
					vim.diagnostic.enable = true
					vim.diagnostic.config({
						virtual_text = {
							prefix = '●',
							source = 'if_many'
						},
					})
				end,
			})
		end,
	}
}

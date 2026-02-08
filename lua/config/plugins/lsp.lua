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

      vim.lsp.config("gopls", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        root_dir = function(fname)
          -- Only attach gopls when we're inside a real Go module
          return vim.fs.root(fname, { "go.mod", ".git" })
        end,
        settings = {
          gopls = {
            staticcheck = false,
            analyses = {
              unusedparams = false,
            },
          },
        },
      })

      vim.o.updatetime = 500

      -- Keep manual hover as a fallback
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { silent = true })

      -- Helper: check if a floating window already exists
      local function floating_win_exists()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local cfg = vim.api.nvim_win_get_config(win)
          if cfg.relative ~= "" then
            return true
          end
        end
        return false
      end

      -- Attach hover behavior only when LSP supports it
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or not client.supports_method("textDocument/hover") then
            return
          end

          local buf = args.buf

          -- Auto-hover on idle
          vim.api.nvim_create_autocmd("CursorHold", {
            buffer = buf,
            callback = function()
              -- Don’t stack floating windows
              if floating_win_exists() then
                return
              end

              vim.lsp.buf.hover()
            end,
          })

          -- Close hover as soon as you move
          vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = buf,
            callback = function()
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                local cfg = vim.api.nvim_win_get_config(win)
                if cfg.relative ~= "" then
                  vim.api.nvim_win_close(win, true)
                end
              end
            end,
          })
        end,
      })

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

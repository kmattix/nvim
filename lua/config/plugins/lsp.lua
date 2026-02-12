return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      ------------------------------------------------------------------------
      -- Lua LSP (FULL Neovim support, fixes `undefined global 'vim'`)
      ------------------------------------------------------------------------
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      ------------------------------------------------------------------------
      -- Go LSP
      ------------------------------------------------------------------------
      vim.lsp.config("gopls", {
        capabilities = capabilities,
      })
      vim.lsp.enable("gopls")

      ------------------------------------------------------------------------
      -- General Settings
      ------------------------------------------------------------------------
      vim.o.updatetime = 500

      -- Keymaps
      vim.keymap.set("n", "<leader>br", vim.lsp.buf.rename)
      vim.keymap.set("n", "<leader>bca", vim.lsp.buf.code_action)
      vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float)
      vim.keymap.set("n", "<leader>ds", vim.diagnostic.setloclist)

      ------------------------------------------------------------------------
      -- Helper: check if floating window exists
      ------------------------------------------------------------------------
      local function floating_win_exists()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local cfg = vim.api.nvim_win_get_config(win)
          if cfg.relative ~= "" then
            return true
          end
        end
        return false
      end

      ------------------------------------------------------------------------
      -- LSP Attach Logic
      ------------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          local buf = args.buf

          -- Hover on idle
          if client.supports_method("textDocument/hover") then
            vim.api.nvim_create_autocmd("CursorHold", {
              buffer = buf,
              callback = function()
                if not floating_win_exists() then
                  vim.lsp.buf.hover()
                end
              end,
            })

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
          end

          -- Format on save
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = buf, id = client.id })
              end,
            })
          end
        end,
      })

      ------------------------------------------------------------------------
      -- Diagnostics Appearance
      ------------------------------------------------------------------------
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          source = "if_many",
        },
        underline = true,
        signs = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },
}

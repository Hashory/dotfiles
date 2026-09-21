return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = { "saghen/blink.cmp" },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
          },
        },
      })

      vim.lsp.enable({ "vtsls", "pyright", "gopls", "rust_analyzer", "lua_ls", "copilot" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
          map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("n", "gr", vim.lsp.buf.references, "References")
          map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
          map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous Diagnostic")
          map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next Diagnostic")

          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if
            client
            and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, args.buf)
          then
            vim.lsp.inline_completion.enable(true, { bufnr = args.buf })
            map("i", "<C-F>", vim.lsp.inline_completion.get, "Accept Inline Completion")
            map("i", "<C-G>", vim.lsp.inline_completion.select, "Next Inline Completion")
          end
        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = true },
        virtual_text = { spacing = 2, source = "if_many" },
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      automatic_enable = true,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "vtsls",
        "pyright",
        "gopls",
        "rust-analyzer",
        "lua-language-server",
        "copilot-language-server",
        "stylua",
        "ruff",
        "prettier",
        "goimports",
        "shfmt",
        "shellcheck",
      },
      run_on_start = true,
      start_delay = 2000,
    },
  },
}

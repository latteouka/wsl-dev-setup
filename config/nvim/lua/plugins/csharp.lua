-- C# (.cs) 開發支援
-- LSP: omnisharp (語法檢查、自動補全、跳轉定義)
-- Formatter: csharpier (程式碼格式化) - 使用 dotnet tool 全域安裝

return {
  -- 確保 Mason 安裝 omnisharp
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "omnisharp", -- C# LSP
        -- csharpier 需要用 dotnet tool install -g csharpier 安裝
      })
    end,
  },

  -- 設定 omnisharp LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = {
          enable_roslyn_analyzers = true,
          enable_import_completion = true,
          organize_imports_on_format = true,
          enable_decompilation_support = true,
          filetypes = { "cs", "vb" },
        },
      },
    },
  },

  -- 設定 conform.nvim 使用 csharpier 格式化
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
      formatters = {
        csharpier = {
          command = vim.fn.expand("~/.dotnet/tools/csharpier"),
          args = { "format", "--write-stdout" },
          stdin = true,
          env = {
            DOTNET_ROOT = "/opt/homebrew/opt/dotnet@8/libexec",
          },
        },
      },
    },
  },
}

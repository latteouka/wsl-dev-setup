-- Swift (.swift) 開發支援
-- LSP: sourcekit-lsp (Xcode 內建，不需 Mason)
-- Formatter: swiftformat (brew install swiftformat)
-- Linter: swiftlint (brew install swiftlint)
-- Build/Run/Test: xcodebuild.nvim

return {
  -- Treesitter: Swift 語法高亮
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "swift" } },
  },

  -- LSP: sourcekit-lsp (Xcode 內建，不透過 Mason 管理)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          mason = false,
          cmd = {
            "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
          },
          filetypes = { "swift", "objc", "objcpp" },
          -- LazyVim v8 使用 vim.lsp.config() API，需要 root_markers 而非 root_dir
          root_markers = { "buildServer.json", "Package.swift", ".git" },
        },
      },
    },
  },

  -- Formatter: swiftformat
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
      },
    },
  },

  -- Linter: swiftlint
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        swift = { "swiftlint" },
      },
    },
  },

  -- xcodebuild.nvim: 在 Neovim 內 Build/Run/Test iOS/macOS App
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
      "XcodebuildSetup",
      "XcodebuildBuild",
      "XcodebuildRun",
      "XcodebuildTest",
      "XcodebuildCleanBuild",
      "XcodebuildPicker",
    },
    ft = "swift",
    config = function()
      require("xcodebuild").setup({
        logs = {
          auto_open_on_success_build = false,
          auto_open_on_failed_build = true,
          auto_close_on_app_launch = true,
        },
      })
    end,
    -- 快捷鍵前綴: <leader>i (iOS)
    keys = {
      { "<leader>iS", "<cmd>XcodebuildSetup<cr>", desc = "Xcode: Setup Project" },
      { "<leader>ib", "<cmd>XcodebuildBuild<cr>", desc = "Xcode: Build" },
      { "<leader>ir", "<cmd>XcodebuildRun<cr>", desc = "Xcode: Run" },
      { "<leader>it", "<cmd>XcodebuildTest<cr>", desc = "Xcode: Test" },
      { "<leader>id", "<cmd>XcodebuildSelectDevice<cr>", desc = "Xcode: Select Device" },
      { "<leader>is", "<cmd>XcodebuildSelectScheme<cr>", desc = "Xcode: Select Scheme" },
      { "<leader>ip", "<cmd>XcodebuildPicker<cr>", desc = "Xcode: Actions Picker" },
      { "<leader>il", "<cmd>XcodebuildToggleLogs<cr>", desc = "Xcode: Toggle Logs" },
      { "<leader>ic", "<cmd>XcodebuildCleanBuild<cr>", desc = "Xcode: Clean Build" },
    },
  },
}

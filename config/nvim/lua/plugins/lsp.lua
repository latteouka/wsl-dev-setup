return {
  -- 讓diagnostics不要顯示在後面
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- 禁用 diagnostics virtual text
      opts.diagnostics = opts.diagnostics or {}
      opts.diagnostics.virtual_text = false

      -- 禁用 inlay hints
      opts.inlay_hints = opts.inlay_hints or {}
      opts.inlay_hints.enabled = false

      -- 禁用 codelens
      opts.codelens = opts.codelens or {}
      opts.codelens.enabled = false

      -- 移除 LSP keymaps 中的 <leader>cc 和 <leader>cC
      -- 使用新的 servers.keys API 來設定按鍵
      opts.servers = opts.servers or {}
      opts.servers["*"] = opts.servers["*"] or {}
      opts.servers["*"].keys = opts.servers["*"].keys or {}

      -- 禁用這兩個按鍵綁定
      table.insert(opts.servers["*"].keys, { "<leader>cc", false })
      table.insert(opts.servers["*"].keys, { "<leader>cC", false })
    end,
  },
}

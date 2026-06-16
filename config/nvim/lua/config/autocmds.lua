-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "json", "jsonc", "markdown" },
--   callback = function()
--     vim.opt_local.conceallevel = 2
--     vim.opt_local.concealcursor = "i"
--   end,
-- })

-- Disable spelling check in markdown and txt
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "txt" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- md中按下gu前往該行中的網址
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "gu", function()
      local line = vim.api.nvim_get_current_line()

      -- 嘗試擷取 markdown 的超連結格式 [label](url)
      local url = line:match("%[.-%]%((https?://[%w%-%._~:/%?#%[%]@!$&'()*+,;=]+)%)")
      -- 如果沒抓到，則 fallback 抓第一個裸網址
      if not url then
        url = line:match("(https?://[%w%-%._~:/%?#%[%]@!$&'()*+,;=]+)")
      end

      if url then
        vim.fn.jobstart({ "open", "-a", "Google Chrome", url }, { detach = true })
      else
        print("❌ 找不到網址")
      end
    end, { buffer = true, desc = "使用 Chrome 開啟當前行的網址" })
  end,
})

-- Prisma migrate 後自動重啟 TypeScript LSP
-- 當 tsconfig.tsbuildinfo 被刪除後，下次進入 TS/TSX 檔案時自動重啟 LSP
local prisma_lsp_restarted = {}
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.ts", "*.tsx" },
  callback = function()
    local cwd = vim.fn.getcwd()
    local tsbuildinfo = cwd .. "/tsconfig.tsbuildinfo"

    -- 如果 tsbuildinfo 不存在且尚未針對此目錄重啟過
    if vim.fn.filereadable(tsbuildinfo) == 0 and not prisma_lsp_restarted[cwd] then
      prisma_lsp_restarted[cwd] = true
      vim.defer_fn(function()
        vim.cmd("LspRestart")
        vim.notify("LSP 已重啟 (Prisma migrate 偵測)", vim.log.levels.INFO)
        -- 5 秒後重置狀態，允許下次偵測
        vim.defer_fn(function()
          prisma_lsp_restarted[cwd] = nil
        end, 5000)
      end, 100)
    end
  end,
  desc = "Prisma migrate 後自動重啟 TypeScript LSP",
})

-- Note System Keymaps for Neovim + Claude Code
-- 載入方式：在 init.lua 或 plugins 中加入 require("note-keymaps")

local M = {}

function M.setup()
  -- 智慧筆記：自動判斷分類
  vim.keymap.set("n", "<leader>nn", function()
    -- 切換到 note-system 目錄並啟動 Claude Code
    vim.cmd("cd ~/projects/note-system")
    vim.cmd("ClaudeCode /note ")
  end, { desc = "Claude: 智慧筆記" })

  -- 快速日記
  vim.keymap.set("n", "<leader>nj", function()
    vim.cmd("cd ~/projects/note-system")
    vim.cmd("ClaudeCode /journal ")
  end, { desc = "Claude: 快速日記" })

  -- 快速備忘
  vim.keymap.set("n", "<leader>nm", function()
    vim.cmd("cd ~/projects/note-system")
    vim.cmd("ClaudeCode /memo ")
  end, { desc = "Claude: 快速備忘" })

  -- 搜尋筆記
  vim.keymap.set("n", "<leader>ns", function()
    vim.cmd("cd ~/projects/note-system")
    vim.cmd("ClaudeCode /search ")
  end, { desc = "Claude: 搜尋筆記" })

  -- 快速開啟筆記目錄（使用 fzf-lua 或 telescope）
  vim.keymap.set("n", "<leader>nf", function()
    vim.cmd("cd ~/projects/note-system/notes")
    -- 如果有 fzf-lua
    if pcall(require, "fzf-lua") then
      require("fzf-lua").files({ cwd = "~/projects/note-system/notes" })
    -- 如果有 telescope
    elseif pcall(require, "telescope.builtin") then
      require("telescope.builtin").find_files({ cwd = "~/projects/note-system/notes" })
    else
      vim.cmd("edit ~/projects/note-system/notes/")
    end
  end, { desc = "Notes: 瀏覽筆記" })

  -- 快速開啟今日日記
  vim.keymap.set("n", "<leader>nt", function()
    local today = os.date("%Y-%m-%d")
    local journal_path = vim.fn.expand("~/projects/note-system/notes/journal/" .. today .. ".md")
    vim.cmd("edit " .. journal_path)
  end, { desc = "Notes: 開啟今日日記" })
end

return M

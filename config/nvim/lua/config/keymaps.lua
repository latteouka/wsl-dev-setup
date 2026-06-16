-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Do things without affecting the registers
keymap.set("n", "x", '"_x')
keymap.set("n", "<Leader>p", '"0p')
keymap.set("n", "<Leader>P", '"0P')
keymap.set("v", "<Leader>p", '"0p')
keymap.set("n", "<Leader>x", '"_c')
keymap.set("n", "<Leader>X", '"_C')
keymap.set("v", "<Leader>x", '"_c')
keymap.set("v", "<Leader>X", '"_C')
keymap.set("n", "<Leader>d", '"_d')
keymap.set("n", "<Leader>D", '"_D')
keymap.set("v", "<Leader>d", '"_d')
keymap.set("v", "<Leader>D", '"_D')

-- Close Buffer
keymap.set("n", "Q", ":bdelete<Return>")

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- New tab
keymap.set("n", "te", ":tabedit")
-- keymap.set("n", "<tab>", ":tabnext<Return>", opts)
-- keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)

-- keymap.set("n", "<A-Left>", ":-tabmove<cr>")
-- keymap.set("n", "<A-Right>", ":+tabmove<cr>")

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Move window
keymap.set("n", "<Space>", "<C-w>w")
-- keymap.set("n", "<leader><Space>", "<nop>")
-- keymap.set("n", "<leader><Space><Space>", "<nop>")
-- keymap.set("n", "<Space>", "<nop>")
-- keymap.set("n", "<Space><Space>", "<C-w>w", { remap = true })
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Move line
keymap.set("n", "<S-Up>", ":m-2<CR>")
keymap.set("i", "<S-Up>", ":m-2<CR>")
keymap.set("n", "<S-Down>", ":m+<CR>")
keymap.set("i", "<S-Down>", ":m+<CR>")

-- Move Block
keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv")
keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv")

-- Stay center when Ctrl-d or Ctrl-u or search
-- keymap.set("n", "<C-d>", "<C-d>zz")
-- keymap.set("n", "<C-u>", "<C-u>zz")
-- keymap.set("n", "n", "nzzzv")
-- keymap.set("n", "N", "Nzzzv")

-- Rename
keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Wrap
-- keymap.set("n", "<leader>w", ":set wrap<CR>")
-- Code Actions

-- LazyVim uses <leader>ca
keymap.set("n", "<leader>qf", ":lua vim.lsp.buf.code_action()<CR>")

-- 在diagnostic跳轉（使用 vim.diagnostic.jump，相容 0.12+）
vim.keymap.set("n", "<C-j>", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<C-k>", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Go to previous diagnostic" })

-- 複製當前 buffer 的相對路徑
keymap.set("n", "<Leader>pp", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy relative path to clipboard" })

return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },

  -- nvim-cmp
  -- {
  --   "hrsh7th/nvim-cmp",
  --   opts = function()
  --     vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
  --     local cmp = require("cmp")
  --     local defaults = require("cmp.config.default")()
  --     local auto_select = true
  --     return {
  --       -- 讓border出來
  --       window = {
  --         completion = cmp.config.window.bordered(),
  --         documentation = cmp.config.window.bordered(),
  --       },
  --       auto_brackets = {}, -- configure any filetype to auto add brackets
  --       completion = {
  --         completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
  --       },
  --       preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
  --       mapping = cmp.mapping.preset.insert({
  --         ["<C-b>"] = cmp.mapping.scroll_docs(-4),
  --         ["<C-f>"] = cmp.mapping.scroll_docs(4),
  --         ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
  --         ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
  --         ["<C-Space>"] = cmp.mapping.complete(),
  --         ["<CR>"] = LazyVim.cmp.confirm({ select = auto_select }),
  --         ["<C-y>"] = LazyVim.cmp.confirm({ select = true }),
  --         ["<S-CR>"] = LazyVim.cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  --         ["<C-CR>"] = function(fallback)
  --           cmp.abort()
  --           fallback()
  --         end,
  --         ["<tab>"] = function(fallback)
  --           return LazyVim.cmp.map({ "snippet_forward", "ai_accept" }, fallback)()
  --         end,
  --       }),
  --       sources = cmp.config.sources({
  --         { name = "lazydev" },
  --         { name = "nvim_lsp" },
  --         { name = "path" },
  --       }, {
  --         { name = "buffer" },
  --       }),
  --       formatting = {
  --         format = function(entry, item)
  --           local icons = LazyVim.config.icons.kinds
  --           if icons[item.kind] then
  --             item.kind = icons[item.kind] .. item.kind
  --           end
  --
  --           local widths = {
  --             abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
  --             menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
  --           }
  --
  --           for key, width in pairs(widths) do
  --             if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
  --               item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
  --             end
  --           end
  --
  --           return item
  --         end,
  --       },
  --       experimental = {
  --         -- only show ghost text when we show ai completions
  --         ghost_text = vim.g.ai_cmp and {
  --           hl_group = "CmpGhostText",
  --         } or false,
  --       },
  --       sorting = defaults.sorting,
  --     }
  --   end,
  -- },

  -- snack
  -- file explorer
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        -- your explorer configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      picker = {
        sources = {
          explorer = {
            hidden = true,
            auto_close = true,
            ignored = true,
          },
        },
      },
      notifier = { enabled = false },
      lazygit = {},
      scroll = {
        enabled = false,
        -- animate = {
        --   duration = { step = 3, total = 200 },
        --   easing = "linear",
        -- },
        -- faster animation when repeating scroll after delay
        -- animate_repeat = {
        --   delay = 100, -- delay in ms before using the repeat animation
        --   duration = { step = 3, total = 50 },
        --   easing = "linear",
        -- },
      },
      dashboard = {
        preset = {
          pick = function(cmd, opts)
            return LazyVim.pick(cmd, opts)()
          end,
          header = [[
                                                         ,--,                         ,----,       ,----,          
    ,----..                        ,--.               ,---.'|                       ,/   .`|     ,/   .`|          
   /   /   \                   ,--/  /|   ,---,       |   | :      ,---,          ,`   .'  :   ,`   .'  :   ,---,. 
  /   .     :          ,--, ,---,': / '  '  .' \      :   : |     '  .' \       ;    ;     / ;    ;     / ,'  .' | 
 .   /   ;.  \       ,'_ /| :   : '/ /  /  ;    '.    |   ' :    /  ;    '.   .'___,/    ,'.'___,/    ,',---.'   | 
.   ;   /  ` ;  .--. |  | : |   '   ,  :  :       \   ;   ; '   :  :       \  |    :     | |    :     | |   |   .' 
;   |  ; \ ; |,'_ /| :  . | '   |  /   :  |   /\   \  '   | |__ :  |   /\   \ ;    |.';  ; ;    |.';  ; :   :  |-, 
|   :  | ; | '|  ' | |  . . |   ;  ;   |  :  ' ;.   : |   | :.'||  :  ' ;.   :`----'  |  | `----'  |  | :   |  ;/| 
.   |  ' ' ' :|  | ' |  | | :   '   \  |  |  ;/  \   \'   :    ;|  |  ;/  \   \   '   :  ;     '   :  ; |   :   .' 
'   ;  \; /  |:  | | :  ' ; |   |    ' '  :  | \  \ ,'|   |  ./ '  :  | \  \ ,'   |   |  '     |   |  ' |   |  |-, 
 \   \  ',  / |  ; ' |  | ' '   : |.  \|  |  '  '--'  ;   : ;   |  |  '  '--'     '   :  |     '   :  | '   :  ;/| 
  ;   :    /  :  | : ;  ; | |   | '_\.'|  :  :        |   ,/    |  :  :           ;   |.'      ;   |.'  |   |    \ 
   \   \ .'   '  :  `--'   \'   : |    |  | ,'        '---'     |  | ,'           '---'        '---'    |   :   .' 
    `---`     :  ,      .-./;   |,'    `--''                    `--''                                   |   | ,'   
               `--`----'    '---'                                                                       `----'     
]],
       -- stylua: ignore
       ---@type snacks.dashboard.Item[]
       keys = {
         { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
         { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
         { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
         { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
         { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
         { icon = " ", key = "q", desc = "Quit", action = ":qa" },
       },
        },
      },
    },
    keys = {
      {
        "sf",
        function()
          Snacks.explorer()
        end,
        desc = "File Explorer",
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "File Explorer",
      },
    },
  },

  -- 新版目前偏好fzf
  {
    "ibhagwan/fzf-lua",
    opts = {
      -- 全域設定
      winopts = {
        height = 0.85,
        width = 0.80,
        preview = {
          layout = "vertical",
          vertical = "down:45%",
        },
      },
      -- grep 設定：確保尊重 .gitignore
      grep = {
        rg_opts = table.concat({
          "--column",
          "--line-number",
          "--no-heading",
          "--color=always",
          "--smart-case",
          "--max-columns=4096",
          "--hidden",
          "--glob=!.git/",
          "--glob=!node_modules/",
          "--glob=!.next/",
          "--glob=!dist/",
          "--glob=!build/",
          "-e"
        }, " "),
      },
      -- files 設定：同樣尊重 .gitignore
      files = {
        fd_opts = table.concat({
          "--color=never",
          "--type=f",
          "--hidden",
          "--follow",
          "--exclude=.git",
          "--exclude=node_modules",
          "--exclude=.next",
          "--exclude=dist",
          "--exclude=build",
        }, " "),
      },
    },
    keys = {
      { ";f", "<cmd>FzfLua files<cr>", desc = "Find Files (fzf-lua)" },
      { ";b", "<cmd>FzfLua buffers<cr>", desc = "Find Buffers (fzf-lua)" },
      { ";r", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep (fzf-lua)" },
      { ";t", "<cmd>TodoTelescope<cr>", desc = "Search TODOs" },
    },
  },

  -- {
  --   "saghen/blink.cmp",
  --   opts = {
  --     completion = {
  --       menu = {
  --         border = "single",
  --         draw = {
  --           columns = {
  --             { "label", gap = 10 },
  --             { "kind_icon", gap = 1 },
  --             { "kind" },
  --             { "label_description" },
  --           },
  --
  --           gap = 1,
  --           treesitter = { "lsp" },
  --         },
  --       },
  --     },
  --   },
  -- },

  -- emmet
  "mattn/emmet-vim",

  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    -- 確保在 LSP 載入後才配置，以覆寫預設按鍵
    event = "VeryLazy",
    config = function()
      require("claude-code").setup({
        -- Terminal window settings
        window = {
          split_ratio = 0.6,
          position = "vertical",
          enter_insert = true,
          hide_numbers = true,
          hide_signcolumn = true,
        },
        -- File refresh settings
        refresh = {
          enable = true, -- Enable file change detection
          updatetime = 100, -- updatetime when Claude Code is active (milliseconds)
          timer_interval = 1000, -- How often to check for file changes (milliseconds)
          show_notifications = true, -- Show notification when files are reloaded
        },
        -- Git project settings
        git = {
          use_git_root = true, -- Set CWD to git root when opening Claude Code (if in git project)
        },
        -- Shell-specific settings
        shell = {
          separator = "&&", -- Command separator used in shell commands
          pushd_cmd = "pushd", -- Command to push directory onto stack (e.g., 'pushd' for bash/zsh, 'enter' for nushell)
          popd_cmd = "popd", -- Command to pop directory from stack (e.g., 'popd' for bash/zsh, 'exit' for nushull)
        },
        -- Command settings
        command = "claude", -- Command used to launch Claude Code
        -- Command variants
        command_variants = {
          -- Conversation management
          continue = "--continue", -- Resume the most recent conversation
          resume = "--resume", -- Display an interactive conversation picker

          -- Output options
          verbose = "--verbose", -- Enable verbose logging with full turn-by-turn output
        },
        -- Keymaps
        keymaps = {
          toggle = {
            normal = "<C-,>", -- Normal mode keymap for toggling Claude Code, false to disable
            terminal = "<C-,>", -- Terminal mode keymap for toggling Claude Code, false to disable
            variants = {
              continue = false, -- 禁用此變體，避免與 LSP 衝突
              verbose = "<leader>cV", -- Normal mode keymap for Claude Code with verbose flag
            },
          },
          window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
          scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
        },
      })

      -- 延遲設定按鍵，確保覆寫 LSP 按鍵
      vim.schedule(function()
        vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<CR>", {
          desc = "Toggle Claude Code",
          noremap = true,
          silent = true,
        })
      end)

      -- 終端模式快捷鍵
      local terminal_maps = { "<C-]>", "<C-x>", "<Esc><Esc>" }
      for _, key in ipairs(terminal_maps) do
        vim.keymap.set("t", key, "<C-\\><C-n><cmd>ClaudeCode<CR>", {
          desc = "Toggle Claude Code from terminal",
          noremap = true,
          silent = true,
        })
      end
      -- jk 退出終端模式
      vim.keymap.set("t", "jk", "<C-\\><C-n>", {
        desc = "Exit terminal mode",
        noremap = true,
        silent = true,
      })
    end,
  },
}

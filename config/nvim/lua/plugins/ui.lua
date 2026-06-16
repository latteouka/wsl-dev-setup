return {
  -- {
  --   "folke/snacks.nvim",
  --   opts = {
  --     notifier = { enabled = false },
  --     scroll = { enabled = false },
  --   },
  -- },

  -- noice.nvim
  {
    "folke/noice.nvim",
    enabled = false,
    -- opts = {
    --   presets = {
    --     lsp_doc_border = true,
    --   },
    --   cmdline = {
    --     enabled = true,
    --     view = "cmdline",
    --   },
    --   messages = {
    --     enabled = true,
    --   },
    --   popupmenu = {
    --     enabled = false,
    --   },
    --   lsp = {
    --     signature = {
    --       enabled = true,
    --       auto_open = {
    --         enabled = false,
    --       },
    --     },
    --   },
    -- },
  },

  -- buffer line
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
      { "<A-Left>", "<Cmd>BufferLineMovePrev<CR>", desc = "Move buffer prev" },
      { "<A-Right>", "<Cmd>BufferLineMoveNext<CR>", desc = "Move buffer next" },
    },
    opts = {
      options = {
        -- mode = "tabs",
        separator_style = "slant",

        -- disable icons
        -- show_buffer_icons = false,

        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },

  -- statusline
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   opts = function(_, opts)
  --     local LazyVim = require("lazyvim.util")
  --     opts.sections.lualine_c[4] = {
  --       LazyVim.lualine.pretty_path({
  --         length = 0,
  --         relative = "cwd",
  --         modified_hl = "MatchParen",
  --         directory_hl = "",
  --         filename_hl = "Bold",
  --         modified_sign = "",
  --         readonly_icon = " 󰌾 ",
  --       }),
  --     }
  --   end,
  -- },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      -- Minimal, terminal-like markdown rendering
      heading = {
        icons = {},           -- no icons before headings
        sign = false,         -- no sign column indicator
        border = false,       -- no border lines around headings
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
        },
        -- only h1/h2 get subtle background, h3+ are plain
        foregrounds = {},
      },
      bullet = {
        icons = { "·" },     -- simple dot instead of fancy bullets
      },
      checkbox = {
        unchecked = { icon = "[ ] " },
        checked = { icon = "[x] " },
        custom = { todo = { raw = "[-]", rendered = "[-] " } },
      },
      code = {
        sign = false,         -- no sign column indicator
        style = "normal",     -- no language icon
        border = "thin",      -- thin top/bottom border
        left_pad = 1,
        right_pad = 1,
      },
      dash = {
        icon = "─",           -- simple horizontal rule
      },
      link = {
        image = "",           -- no image icon
        hyperlink = "",       -- no link icon
      },
      sign = { enabled = false },
      pipe_table = {
        style = "normal",     -- clean table, no heavy borders
      },
      anti_conceal = { enabled = true },
    },
  },
}

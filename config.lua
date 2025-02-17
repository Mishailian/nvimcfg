-- Main LunarVim configuration
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "gruvbox"

-- Determine the operating system
local os_name = vim.loop.os_uname().sysname

if os_name == "Windows_NT" then
  -- Settings for Windows
  vim.opt.shell = "powershell.exe"
  vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  vim.cmd [[
      let &shellredir = '>%s 2>&1'
      let &shellpipe = '2>&1 | tee %s'
      set shellquote= shellxquote=
  ]]
elseif os_name == "Linux" or os_name == "Darwin" then
  -- Settings for Linux and macOS
  vim.opt.shell = "/bin/zsh"
  vim.opt.shellcmdflag = "-c"
  vim.cmd [[
      let &shellredir = '> %s 2>&1'
      let &shellpipe = '2>&1 | tee %s'
      set shellquote= shellxquote=
  ]]

  if os_name == "Linux" then
    -- Clipboard settings for Docker/Wayland
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
      },
      paste = {
        ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
        ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
      },
    }
  elseif os_name == "Darwin" then
    -- Clipboard settings for macOS
    vim.g.clipboard = {
      copy = {
        ["+"] = "pbcopy",
        ["*"] = "pbcopy",
      },
      paste = {
        ["+"] = "pbpaste",
        ["*"] = "pbpaste",
      },
    }
  end
end

-- Leader key settings
lvim.leader = "space"

-- Treesitter configuration
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.treesitter.ensure_installed = {
  "javascript", -- For JavaScript
  "dockerfile", -- For Dockerfile
  "lua",        -- For Lua
  "python",     -- For Python
}

local null_ls = require("null-ls")

-- Null-ls configuration
local sources = {
  null_ls.builtins.formatting.prettier.with({
    filetypes = { "javascript", "typescript", "html", "css", "json" },
  }),
  null_ls.builtins.diagnostics.eslint.with({
    filetypes = { "javascript", "typescript" },
  }),
  null_ls.builtins.formatting.stylua,
}

null_ls.setup()

-- Auto-formatting on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Plugins
lvim.plugins = {
  { "jose-elias-alvarez/null-ls.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "ggandor/lightspeed.nvim",
    event = "BufRead",
  },
  -- {
  --   "Pocco81/auto-save.nvim",
  --   config = function()
  --     require("auto-save").setup()
  --   end,
  -- },
  {
    "lunarvim/colorschemes"
  },
  {
    "sontungexpt/witch",
    priority = 1000,
    lazy = false,
    config = function(_, opts)
      require("witch").setup(opts)
    end,
  },
  {
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup({
        input = { enabled = false },
      })
    end,
  },
  {
    "nvim-neorg/neorg",
    ft = "norg",
    config = true,
  },
  {
    "itchyny/vim-cursorword",
    event = { "BufEnter", "BufNewFile" },
    config = function()
      vim.api.nvim_command("augroup user_plugin_cursorword")
      vim.api.nvim_command("autocmd!")
      vim.api.nvim_command("autocmd FileType NvimTree,lspsagafinder,dashboard,vista let b:cursorword = 0")
      vim.api.nvim_command("autocmd WinEnter * if &diff || &pvw | let b:cursorword = 0 | endif")
      vim.api.nvim_command("autocmd InsertEnter * let b:cursorword = 0")
      vim.api.nvim_command("autocmd InsertLeave * let b:cursorword = 1")
      vim.api.nvim_command("augroup END")
    end
  },
  -- Emmet
  {
    "mattn/emmet-vim",
    ft = { "html", "css", "javascriptreact", "typescriptreact", "vue", "svelte" }, -- Автоматическая активация для этих типов файлов
    config = function()
      -- setup Emmet for Neovim
      vim.g.user_emmet_mode = 'a'
      vim.g.user_emmet_leader_key = ','
      vim.g.user_emmet_install_global = 0

      vim.cmd([[
                autocmd FileType html,css,javascriptreact,typescriptreact,vue,svelte EmmetInstall
            ]])
    end,
  },
  -- Marckdown prev
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
  },
  -- Md viewer type ":MarkdownPreview"
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
    config = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_start = 1         -- Автоматический запуск предпросмотра при открытии файла markdown
      vim.g.mkdp_auto_close = 1         -- Автоматическое закрытие предпросмотра при закрытии файла markdown
      vim.g.mkdp_refresh_slow = 0       -- Отключение медленного обновления
      vim.g.mkdp_command_for_global = 0 -- Запрещает использование глобальной команды
      vim.g.mkdp_open_to_the_world = 0  -- Не открывать предпросмотр для всех (локально)
      vim.g.mkdp_port = 8888            -- Порт для предпросмотра
    end,
  },
  -- tailwindcss
  -- tailwind-tools.lua
  {
    "luckasRanarison/tailwind-tools.nvim",
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim", -- optional
      "neovim/nvim-lspconfig",         -- optional
    },
    opts = {}                          -- your configuration
  },
  --for code edit {} "" () etc
  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },

  -- zen mode for activation :ZenMode
  {
    "folke/zen-mode.nvim",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  }
}

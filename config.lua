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

null_ls.setup({ sources = sources })

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
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require('neoscroll').setup({
        mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
        hide_cursor = true,
        stop_eof = true,
        use_local_scrolloff = false,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = nil,
        pre_hook = nil,
        post_hook = nil,
      })
    end
  },
}

-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Enable powershell as your default shell
vim.opt.shell = "pwsh.exe"
vim.opt.shellcmdflag =
"-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
vim.cmd [[
		let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		set shellquote= shellxquote=
  ]]

-- Set a compatible clipboard manager
vim.g.clipboard = {
  copy = {
    ["+"] = "win32yank.exe -i --crlf",
    ["*"] = "win32yank.exe -i --crlf",
  },
  paste = {
    ["+"] = "win32yank.exe -o --lf",
    ["*"] = "win32yank.exe -o --lf",
  },
}

-- Основной конфиг LunarVim
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "gruvbox"

-- Настройки лидера
lvim.leader = "space"

-- Treesitter конфигурация
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.treesitter.ensure_installed = {
  "javascript", -- Для JS
  "dockerfile", -- Для Dockerfile
  "lua",        -- Для Lua
  "python",     -- Для Python
}

local null_ls = require("null-ls")

-- Настройка null-ls
local sources = {
  null_ls.builtins.formatting.prettier.with({
    filetypes = { "javascript", "typescript", "html", "css", "json" },
  }), -- Prettier для форматирования JS/HTML/CSS
  null_ls.builtins.diagnostics.eslint.with({
    filetypes = { "javascript", "typescript" },
  }),                                 -- ESLint для проверки JS
  null_ls.builtins.formatting.stylua, -- Stylua для Lua
}

null_ls.setup({ sources = sources })

-- Автоформатирование при сохранении
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false }) -- форматирование перед сохранением
  end,
})

-- Плагины
lvim.plugins = {
  { "jose-elias-alvarez/null-ls.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  --lithspeed
  {
    "ggandor/lightspeed.nvim",
    event = "BufRead",
  },
  --autosave
  {
    "Pocco81/auto-save.nvim",
    config = function()
      require("auto-save").setup()
    end,
  },
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
    config = true, -- run require("neorg").setup()
  },
  -- for underlines when cursior in
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
  --smooth scroll
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require('neoscroll').setup({
        -- All these keys will be mapped to their corresponding default scrolling animation
        mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>',
          '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
        hide_cursor = true,          -- Hide cursor while scrolling
        stop_eof = true,             -- Stop at <EOF> when scrolling downwards
        use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
        respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = nil,       -- Default easing function
        pre_hook = nil,              -- Function to run before the scrolling animation starts
        post_hook = nil,             -- Function to run after the scrolling animation ends
      })
    end
  },
}

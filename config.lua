-- Основной конфиг LunarVim
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "gruvbox"

-- Shell
vim.opt.shell = "/bin/zsh"
vim.opt.shellcmdflag = "-c"
vim.cmd [[
    let &shellredir = '> %s 2>&1'
    let &shellpipe = '2>&1 | tee %s'
    set shellquote= shellxquote=
]]

-- Настройка буфера обмена для macOS
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

-- Настройки лидера
lvim.leader = "space"

-- Tfeesitter конфигурация
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
  }),
  null_ls.builtins.diagnostics.eslint.with({
    filetypes = { "javascript", "typescript" },
  }),
  null_ls.builtins.formatting.stylua,
}

null_ls.setup({ sources = sources })

-- Автоформатирование при сохранении
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Плагины
lvim.plugins = {
  { "jose-elias-alvarez/null-ls.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "ggandor/lightspeed.nvim",
    event = "BufRead",
  },
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

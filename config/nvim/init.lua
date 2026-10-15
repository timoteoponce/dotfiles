-- Small Neovim setup. Leader is a comma. No autocomplete until asked for.
vim.g.mapleader = ","
vim.g.maplocalleader = ","

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt
opt.termguicolors = true
opt.number = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.undofile = true
opt.splitright = true
opt.splitbelow = true
opt.signcolumn = "no"
opt.mouse = "a"
opt.wrap = false

-- Neovim 0.12 turns built-in completion on. Leave it off.
pcall(function()
  vim.o.autocomplete = false
end)

vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

local themes = { "default", "habamax", "retrobox", "unokai", "wildcharm" }
local theme_index = 2

local function apply_theme(name)
  return pcall(vim.cmd.colorscheme, name)
end

apply_theme(themes[theme_index])

-- Plugins need Neovim 0.12 (mise installs it). Older nvim keeps the settings above.
if not vim.pack then
  vim.notify("Neovim 0.12 or newer is required for plugins. Run: mise install", vim.log.levels.WARN)
  return
end

vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-tree/nvim-tree.lua",
  "https://github.com/MagicDuck/grug-far.nvim",
}, { confirm = false })

require("telescope").setup({})
local pick = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", function()
  pick.find_files({ hidden = true })
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>b", pick.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", pick.live_grep, { desc = "Search in files" })

require("nvim-tree").setup({
  view = { width = 30 },
  git = { enable = false },
  renderer = { icons = { show = { git = false } } },
})
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, desc = "File tree" })

require("grug-far").setup({})
vim.keymap.set("n", "<leader>r", function()
  require("grug-far").open()
end, { desc = "Replace in files" })

vim.keymap.set("n", "<leader>t", function()
  theme_index = theme_index % #themes + 1
  if apply_theme(themes[theme_index]) then
    vim.notify(themes[theme_index])
  end
end, { desc = "Next colorscheme" })

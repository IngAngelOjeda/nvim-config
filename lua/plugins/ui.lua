require("nvim-tree").setup()
require("lualine").setup({ options = { theme = "gruvbox" } })
require("nvim-treesitter.configs").setup({
  ensure_installed = { "java", "lua", "json", "xml" },
  highlight = { enable = true },
})

require("plugins.lsp")
require("plugins.ui")


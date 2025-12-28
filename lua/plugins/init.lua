return require("packer").startup(function(use)
  -- Packer se autogestiona
  use "wbthomason/packer.nvim"

  -- ===============================
  -- LSP y herramientas
  -- ===============================
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"
  use "neovim/nvim-lspconfig"
  use "mfussenegger/nvim-jdtls"  -- ← AÑADIDO: Plugin para Java LSP

  -- ===============================
  -- Autocompletado
  -- ===============================
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-nvim-lsp"
  use "L3MON4D3/LuaSnip"

  -- ===============================
  -- Árbol de archivos
  -- ===============================
  use {
    "nvim-tree/nvim-tree.lua",
    requires = { "nvim-tree/nvim-web-devicons" },
  }

  -- ===============================
  -- Colores, barra y tema
  -- ===============================
  use "nvim-lualine/lualine.nvim"
  use "folke/tokyonight.nvim"
  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }

  -- ===============================
  -- Git y utilidades
  -- ===============================
  use "lewis6991/gitsigns.nvim"
  use "numToStr/Comment.nvim"

  -- ===============================
  -- Buscador y navegación
  -- ===============================
  use { "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } }
  use "nvim-telescope/telescope-fzf-native.nvim"

  -- ===============================
  -- Terminal y formato visual
  -- ===============================
  use "akinsho/toggleterm.nvim"
  use "lukas-reineke/ibl.nvim"

  -- ===============================
  -- Sesiones (opcional)
  -- ===============================
  use "rmagatti/auto-session"

  -- ===============================
  -- Depuración (DAP)
  -- ===============================
  use "mfussenegger/nvim-dap"
  use "rcarriga/nvim-dap-ui"
  use "theHamsta/nvim-dap-virtual-text"
  use "nvim-neotest/nvim-nio"  -- ← AÑADIDO: Dependencia requerida por nvim-dap-ui
end)
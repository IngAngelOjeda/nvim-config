require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "jdtls" },
})

local lspconfig = require("lspconfig")
lspconfig.jdtls.setup({
  cmd = { "jdtls" },
  root_dir = lspconfig.util.root_pattern(".git", "mvnw", "gradlew"),
})

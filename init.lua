-- ===========================
-- CONFIGURACIÓN BASE
-- ===========================
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.mouse = "a"
vim.g.mapleader = " "

-- ===========================
-- PLUGINS
-- ===========================
vim.cmd [[packadd packer.nvim]]
require("plugins")

-- ===========================
-- MASON + LSP (sin auto-setup de jdtls)
-- ===========================
local ok_mason, mason = pcall(require, "mason")
if ok_mason then mason.setup() end

local ok_mason_lsp, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok_mason_lsp then
  mason_lspconfig.setup({
    ensure_installed = { "jdtls" },
    automatic_installation = false,  -- Evita instalaciones automáticas que puedan causar conflictos
  })

  -- ==============================================
  -- Desactivar autoconfiguración de jdtls y copilot
  -- ==============================================
  local has_handlers = type(mason_lspconfig.setup_handlers) == "function"

  -- Servidores que NO deben ser configurados automáticamente
  local excluded_servers = { "jdtls", "copilot" }

  local function should_skip_server(server_name)
    for _, excluded in ipairs(excluded_servers) do
      if server_name == excluded then
        return true
      end
    end
    return false
  end

  if has_handlers then
    -- Para versiones nuevas de mason-lspconfig
    mason_lspconfig.setup_handlers({
      function(server_name)
        if not should_skip_server(server_name) then
          local ok_lsp, lspconfig = pcall(require, "lspconfig")
          if ok_lsp and lspconfig[server_name] then
            lspconfig[server_name].setup({})
          end
        end
      end,
    })
  else
    -- Para versiones antiguas (fallback)
    local ok_lsp, lspconfig = pcall(require, "lspconfig")

    if ok_lsp then
      for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
        if not should_skip_server(server_name) then
          local server = vim.lsp.configs and vim.lsp.configs[server_name]
            or (vim.lsp and vim.lsp.config and vim.lsp.config[server_name])
            or (lspconfig and lspconfig[server_name])

          if server and server.setup then
            server.setup({})
          end
        end
      end
    end
  end
end


-- ===========================
-- AUTOCOMPLETADO
-- ===========================
local ok_cmp, cmp = pcall(require, "cmp")
local ok_snip, luasnip = pcall(require, "luasnip")

if ok_cmp and ok_snip then
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
    }, {
      { name = "buffer" },
    }),
  })
end

-- ===========================
-- PLUGINS VISUALES
-- ===========================
local ok_devicons, devicons = pcall(require, "nvim-web-devicons")
if ok_devicons then devicons.setup { default = true } end

local ok_comment, comment = pcall(require, "Comment")
if ok_comment then comment.setup() end

local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
if ok_gitsigns then gitsigns.setup() end

local ok_ibl, ibl = pcall(require, "ibl")
if ok_ibl then ibl.setup { indent = { char = "▏" } } end

local ok_ts, treesitter = pcall(require, "nvim-treesitter.configs")
if ok_ts then
  treesitter.setup {
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = { "java", "lua", "json", "html", "bash" },
  }
end

local ok_tree, nvim_tree = pcall(require, "nvim-tree")
if ok_tree then
  nvim_tree.setup {
    renderer = {
      highlight_git = true,
      highlight_opened_files = "name",
      icons = { show = { file = true, folder = true, git = true } },
    },
  }
end

local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
  lualine.setup {
    options = {
      theme = "tokyonight",
      icons_enabled = true,
      section_separators = '',
      component_separators = '',
    },
  }
end

local ok_telescope, telescope = pcall(require, "telescope")
if ok_telescope then
  telescope.setup()
  pcall(telescope.load_extension, "fzf")
end

local ok_term, toggleterm = pcall(require, "toggleterm")
if ok_term then
  toggleterm.setup{
    size = 15,
    open_mapping = [[<C-\>]],
    shade_terminals = true,
    direction = "float",
  }
end

-- ===========================
-- TEMA
-- ===========================
vim.cmd[[colorscheme tokyonight]]

-- ===========================
-- DAP (DEPURACIÓN) - Configuración global
-- ===========================
local ok_dap, dap = pcall(require, "dap")
local ok_dapui, dapui = pcall(require, "dapui")
local ok_daptext, daptext = pcall(require, "nvim-dap-virtual-text")

if ok_dap and ok_dapui and ok_daptext then
  dapui.setup()
  daptext.setup()
  
  -- Auto-abrir/cerrar DAP UI
  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
  

  
  -- CRÍTICO: Configuraciones de DAP para Java (necesario antes de F5)
  dap.configurations.java = {
    -- ========================================
    -- SPRING BOOT - Launch con Maven
    -- ========================================
    {
      type = "java",
      request = "launch",
      name = "🍃 Spring Boot (Maven)",
      mainClass = "com.example.demo.DemoApplication", -- ← CAMBIAR por tu clase principal
      projectName = function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      end,
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      args = "",
      -- Perfiles de Spring Boot (opcional)
      vmArgs = "-Dspring.profiles.active=dev",
    },
    
    -- ========================================
    -- SPRING BOOT - Launch con Gradle
    -- ========================================
    {
      type = "java",
      request = "launch",
      name = "🍃 Spring Boot (Gradle)",
      mainClass = "com.example.demo.DemoApplication", -- ← CAMBIAR por tu clase principal
      projectName = function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      end,
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      args = "",
      vmArgs = "-Dspring.profiles.active=dev",
    },
    
    -- ========================================
    -- SPRING BOOT - Attach a aplicación corriendo
    -- ========================================
    {
      type = "java",
      request = "attach",
      name = "🔗 Attach to Spring Boot (5005)",
      hostName = "127.0.0.1",
      port = 5005,
      projectName = function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      end,
    },
    
    -- ========================================
    -- Configuración genérica para archivo actual
    -- ========================================
    {
      type = "java",
      request = "launch",
      name = "Debug (Launch) - Current File",
      mainClass = "${file}",
    },
    
    -- ========================================
    -- Configuración con input de clase principal
    -- ========================================
    {
      type = "java",
      request = "launch",
      name = "Debug (Launch) - Main Class",
      mainClass = function()
        return vim.fn.input("Main class: ", "", "file")
      end,
    },
    
    -- ========================================
    -- Attach genérico con input de puerto
    -- ========================================
    {
      type = "java",
      request = "attach",
      name = "Debug (Attach) - Remote",
      hostName = "127.0.0.1",
      port = function()
        return tonumber(vim.fn.input("Port: ", "5005"))
      end,
    },
  }
end

-- ===========================
-- ATAJOS GLOBALES
-- ===========================
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>g", ":Telescope live_grep<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-//>", ":ToggleTerm<CR>", { noremap = true, silent = true })

-- Atajos de DAP (globales)
if ok_dap then
  vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "DAP: Continue" })
  vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "DAP: Step Over" })
  vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "DAP: Step Into" })
  vim.keymap.set("n", "<F12>", function() dap.step_out() end, { desc = "DAP: Step Out" })
  vim.keymap.set("n", "<leader>b", function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle Breakpoint" })
  vim.keymap.set("n", "<leader>du", function() dapui.toggle() end, { desc = "DAP: Toggle UI" })
end

-- ===========================
-- JAVA LSP + DAP (JDTLS) - Solo cuando se abre un archivo Java
-- ===========================
local function setup_jdtls()
  local ok_jdtls, jdtls = pcall(require, "jdtls")
  if not ok_jdtls then
    vim.notify("El plugin 'nvim-jdtls' no está instalado", vim.log.levels.ERROR)
    return
  end

  -- Rutas de Windows
  local home = os.getenv("USERPROFILE")
  local mason_bin = vim.fn.stdpath("data") .. "\\mason\\bin"
  local jdtls_cmd = mason_bin .. "\\jdtls.cmd"

  -- Fallback a ruta alternativa
  if vim.fn.filereadable(jdtls_cmd) == 0 then
    jdtls_cmd = home .. "\\AppData\\Local\\nvim-data\\mason\\bin\\jdtls.cmd"
  end

  if vim.fn.filereadable(jdtls_cmd) == 0 then
    vim.notify("No se encontró jdtls.cmd en Mason. Ejecuta :Mason e instala jdtls", vim.log.levels.ERROR)
    return
  end

  -- Detectar root_dir del proyecto (CRÍTICO para que funcione correctamente)
  local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
  local root_dir = vim.fs.dirname(vim.fs.find(root_markers, { upward = true })[1])
  if not root_dir then
    root_dir = vim.fn.getcwd()
  end

  -- Workspace único por proyecto
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = home .. "\\workspace\\" .. project_name
  vim.fn.mkdir(workspace_dir, "p")

  -- Bundles para depuración (java-debug)
  -- Intentar múltiples ubicaciones posibles
  local possible_paths = {
    home .. "\\java-debug\\com.microsoft.java.debug.plugin\\target\\com.microsoft.java.debug.plugin-*.jar",
    home .. "\\.vscode-java-debug\\com.microsoft.java.debug.plugin.jar",
    home .. "\\dap_adapters\\java-debug\\com.microsoft.java.debug.plugin\\target\\com.microsoft.java.debug.plugin-*.jar",
    home .. "\\.vscode\\extensions\\vscjava.vscode-java-debug-*\\server\\com.microsoft.java.debug.plugin-*.jar",
  }

  
  local bundles = {}
  local found = false
  
  for _, path in ipairs(possible_paths) do
    local jars = vim.split(vim.fn.glob(path), "\n")
    if #jars > 0 and jars[1] ~= "" then
      for _, jar in ipairs(jars) do
        if jar ~= "" and vim.fn.filereadable(jar) == 1 then
          table.insert(bundles, jar)
          vim.notify("✓ Bundle cargado: " .. vim.fn.fnamemodify(jar, ":t"), vim.log.levels.INFO)
          found = true
        end
      end
      if found then break end
    end
  end
  
  if not found then
    vim.notify([[
⚠ No se encontró java-debug. La depuración no funcionará.

Opciones:
1. Descargar pre-compilado:
   cd %USERPROFILE%
   mkdir .vscode-java-debug
   # Descargar: https://github.com/microsoft/java-debug/releases/latest
   # Guardar como: %USERPROFILE%\.vscode-java-debug\com.microsoft.java.debug.plugin.jar

2. O compilar desde código:
   cd %USERPROFILE%\dap_adapters
   git clone https://github.com/microsoft/java-debug.git
   cd java-debug
   mvnw clean install -DskipTests
]], vim.log.levels.WARN)
  end

  -- Capabilities (para autocompletado)
  local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  local capabilities = ok_cmp_lsp and cmp_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()

  -- Configuración de JDTLS
  local config = {
    cmd = { jdtls_cmd, "-data", workspace_dir },
    root_dir = root_dir,
    capabilities = capabilities,
    init_options = { bundles = bundles },
    
    settings = {
      java = {
        eclipse = {
          downloadSources = true,
        },
        configuration = {
          updateBuildConfiguration = "interactive",
        },
        maven = {
          downloadSources = true,
        },
        implementationsCodeLens = {
          enabled = true,
        },
        referencesCodeLens = {
          enabled = true,
        },
        signatureHelp = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            "org.junit.jupiter.api.Assertions.*",
            "org.junit.jupiter.api.Assumptions.*",
            "org.junit.jupiter.api.DynamicContainer.*",
            "org.junit.jupiter.api.DynamicTest.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
          useBlocks = true,
        },
      },
    },
    
    flags = {
      allow_incremental_sync = true,
    },
    
    -- on_attach para keymaps específicos de Java
    on_attach = function(client, bufnr)
      -- CRÍTICO: Configurar DAP con JDTLS ANTES de cualquier otra cosa
      if #bundles > 0 then
        jdtls.setup_dap({ 
          hotcodereplace = "auto",
          config_overrides = {}
        })
        
        -- Extensiones de JDTLS para DAP
        require('jdtls.dap').setup_dap_main_class_configs()
        
        vim.notify("✓ DAP configurado correctamente", vim.log.levels.INFO)
      else
        vim.notify("⚠ DAP no disponible (falta java-debug)", vim.log.levels.WARN)
      end
      
      -- Keymaps locales del buffer
      local opts = { buffer = bufnr, silent = true }
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      
      vim.notify("✓ JDTLS iniciado en: " .. root_dir, vim.log.levels.INFO)
    end,
  }

  -- Iniciar JDTLS
  jdtls.start_or_attach(config)
end

-- CRÍTICO: Solo ejecutar setup_jdtls cuando se abre un archivo Java
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = setup_jdtls,
  desc = "Iniciar JDTLS para archivos Java",
})

print("✓ Configuración cargada. Abre un archivo .java para iniciar JDTLS")
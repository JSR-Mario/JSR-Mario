-- Establece la tecla <Space> como el líder del teclado para atajos personalizados.
vim.g.mapleader = " "

-- Opciones básicas del editor para una mejor experiencia.
vim.opt.wrap = true             -- Habilita el ajuste de línea.
vim.opt.linebreak = true        -- Ajusta las líneas en los espacios.
vim.opt.breakindent = true      -- Mantiene la sangría al ajustar la línea.
vim.opt.number = true           -- Muestra los números de línea absolutos.
vim.opt.relativenumber = true   -- Muestra los números de línea relativos.
vim.cmd("syntax enable")        -- Habilita el resaltado de sintaxis.

-- Carga e instala lazy.nvim si no está presente.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- Define y configura los plugins usando lazy.nvim.
require("lazy").setup({
  -- Colorscheme. Puedes cambiar "catppuccin/nvim" por otro si lo deseas.
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "catppuccin"
    end,
  },

  -- Iconos para los plugins.
  "nvim-tree/nvim-web-devicons",

  -- Gestor de estado para el seguimiento del tiempo de codificación.
  "wakatime/vim-wakatime",

  -- Cierre automático de paréntesis, corchetes, etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({
        check_ts = true, -- Usa treesitter
        ts_config = {
          lua = {'string'},-- no añade pares en nodos de string de lua
          javascript = {'template_string'},
          java = false,-- no revisa treesitter en java
        }
      })

      -- Integración con cmp
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )
    end,
  },

  -- Plugin de navegación (Telescope).
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5", -- Versión estable.
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Plugin para compilar y visualizar LaTeX (VimTeX).
  {
    "lervag/vimtex",
    ft = "tex", -- Solo carga el plugin para archivos .tex.
    config = function()
      -- Configuración para un flujo de trabajo similar a Overleaf.
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-pdf",
          "-shell-escape",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }

      -- Cierre automático de entornos de LaTeX como \begin{...}.
      vim.g.vimtex_complete_close_environments = true
      
      -- Habilita el folding (plegado) de código pero no automático
      vim.g.vimtex_fold_enabled = 1
      vim.g.vimtex_fold_manual = 1
      
      -- Para Linux con Zathura:
      vim.g.vimtex_view_method = 'zathura'
      
      -- Compilación automática al guardar
      vim.g.vimtex_compiler_latexmk = {
        build_dir = '',
        callback = 1,
        continuous = 1,
        executable = 'latexmk',
        hooks = {},
        options = {
          '-verbose',
          '-file-line-error',
          '-synctex=1',
          '-interaction=nonstopmode',
        },
      }
    end,
  },

  -- Autocompletado
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets", -- Snippets adicionales
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Cargar snippets de friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

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
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Plugin para comentarios inteligentes
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("Comment").setup({
        -- Configuración básica
        padding = true,    -- Añade espacio entre el comentario y el código
        sticky = true,     -- Mantiene el cursor en su posición
        ignore = nil,      -- Líneas a ignorar durante el comentado
        
        -- Mapeos básicos (puedes cambiarlos si quieres)
        toggler = {
          line = 'gcc',    -- Comentar/descomentar línea actual
          block = 'gbc',   -- Comentar/descomentar bloque
        },
        
        -- Mapeos para modo operator-pending
        opleader = {
          line = 'gc',     -- Para comentar con movimientos: gc + movimiento
          block = 'gb',    -- Para bloques: gb + movimiento
        },
        
        -- Mapeos adicionales
        extra = {
          above = 'gcO',   -- Comentar línea arriba del cursor
          below = 'gco',   -- Comentar línea abajo del cursor
          eol = 'gcA',     -- Comentar al final de línea
        },
        
        -- Habilitar mapeos básicos
        mappings = {
          basic = true,    -- `gcc`, `gbc`, `gc[count]{motion}`, `gb[count]{motion}`
          extra = true,    -- `gco`, `gcO`, `gcA`
        },
      })
    end,
  },

  -- Sugerencias visuales para los atajos de teclado.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({})
    end,
  },

  -- Spell check para español e inglés, y resaltado de sintaxis con Treesitter.
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Idiomas para el spell check.
        ensure_installed = { "markdown", "latex", "lua", "vim" },
        autotag = { enable = true },
        context_commentstring = { enable = true },
        indent = { enable = true },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
      -- Habilita el spell check solo en los archivos Markdown y LaTeX.
      vim.api.nvim_create_autocmd({ "BufEnter", "BufRead" }, {
        group = vim.api.nvim_create_augroup("SpellCheckGroup", { clear = true }),
        pattern = { "*.md", "*.tex" },
        callback = function()
          vim.opt.spell = true
          vim.opt.spelllang = "en,es"
        end,
      })
    end,
  },
})

--
-- Funciones auxiliares para LaTeX
--

-- Función para insertar entornos LaTeX automáticamente
local function insert_latex_environment(env_name)
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  
  -- Insertar el entorno
  local begin_line = "\\begin{" .. env_name .. "}"
  local end_line = "\\end{" .. env_name .. "}"
  
  -- Obtener la línea actual hasta el cursor
  local before_cursor = line:sub(1, col)
  local after_cursor = line:sub(col + 1)
  
  -- Reemplazar la línea actual
  vim.api.nvim_set_current_line(before_cursor .. begin_line)
  
  -- Añadir línea vacía y end
  local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, current_line_num, current_line_num, false, {"", end_line .. after_cursor})
  
  -- Posicionar el cursor en la línea vacía
  vim.api.nvim_win_set_cursor(0, {current_line_num + 1, 0})
end

--
-- Configuraciones específicas para LaTeX
--

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    -- Configuraciones específicas para archivos LaTeX
    vim.opt_local.conceallevel = 2
    vim.opt_local.textwidth = 80
    vim.opt_local.foldmethod = "manual"  -- Folding manual
    vim.opt_local.foldlevel = 99         -- Inicia con todo expandido
    
    -- Mapeos específicos para LaTeX
    local opts = { buffer = true, silent = true }
    
    -- Atajo rápido para insertar align*
    vim.keymap.set("i", "<C-a>", function()
      insert_latex_environment("align*")
    end, vim.tbl_extend("force", opts, { desc = "Insert align* environment" }))
    
    -- Atajo rápido para insertar equation*
    vim.keymap.set("i", "<C-e>", function()
      insert_latex_environment("equation*")
    end, vim.tbl_extend("force", opts, { desc = "Insert equation* environment" }))
    
    -- Atajos para folding manual
    vim.keymap.set("n", "<leader>zf", "zf", vim.tbl_extend("force", opts, { desc = "Create fold" }))
    vim.keymap.set("n", "<leader>zo", "zo", vim.tbl_extend("force", opts, { desc = "Open fold" }))
    vim.keymap.set("n", "<leader>zc", "zc", vim.tbl_extend("force", opts, { desc = "Close fold" }))
    vim.keymap.set("n", "<leader>za", "za", vim.tbl_extend("force", opts, { desc = "Toggle fold" }))
    
    -- Configurar autopares para $ en archivos LaTeX
    local npairs = require("nvim-autopairs")
    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")
    
    -- Regla para cerrar $ con $ solo en archivos .tex
    npairs.add_rule(Rule("$", "$", "tex"))
    
    -- Regla más sofisticada para evitar problemas con $$
    npairs.add_rule(
      Rule("$", "$", "tex")
        :with_pair(function(opts)
          -- No añadir par si ya hay un $ después del cursor
          if opts.line:sub(opts.col, opts.col) == "$" then
            return false
          end
          -- No añadir par si estamos dentro de $$
          local before = opts.line:sub(1, opts.col - 1)
          local after = opts.line:sub(opts.col)
          if before:match("%$%$$") or after:match("^%$%$") then
            return false
          end
          return true
        end)
    )
  end,
})

--
-- Keymaps (Atajos de Teclado)
--

-- Keymaps para LaTeX (VimTeX)
vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>", { silent = true, desc = "LaTeX: Compile" })
vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>", { silent = true, desc = "LaTeX: View PDF" })
vim.keymap.set("n", "<leader>lc", "<cmd>VimtexClean<CR>", { silent = true, desc = "LaTeX: Clean aux files" })
vim.keymap.set("n", "<leader>ls", "<cmd>VimtexStop<CR>", { silent = true, desc = "LaTeX: Stop compilation" })
vim.keymap.set("n", "<leader>lt", "<cmd>VimtexTocToggle<CR>", { silent = true, desc = "LaTeX: Toggle TOC" })

-- Navegación con Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { silent = true, desc = "Find file" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { silent = true, desc = "Live grep (requires 'rg')" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { silent = true, desc = "List buffers" })

-- Redimensionar ventanas
vim.keymap.set("n", "<M-Left>",  "<cmd>vertical resize -5<CR>", { silent = true, desc = "Resize left" })
vim.keymap.set("n", "<M-Right>", "<cmd>vertical resize +5<CR>", { silent = true, desc = "Resize right" })
vim.keymap.set("n", "<M-Up>",    "<cmd>resize +5<CR>", { silent = true, desc = "Resize up" })
vim.keymap.set("n", "<M-Down>",  "<cmd>resize -5<CR>", { silent = true, desc = "Resize down" })

-- Navegación mejorada en modo inserción
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left in insert mode" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down in insert mode" })
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up in insert mode" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right in insert mode" })

-- Atajos adicionales para comentarios (más familiares)
vim.keymap.set("n", "<C-_>", "gcc", { remap = true, desc = "Toggle line comment" })  -- Ctrl + /
vim.keymap.set("v", "<C-_>", "gc", { remap = true, desc = "Toggle selection comment" })  -- Ctrl + / en visual
vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "Toggle line comment" })  -- Leader + /
vim.keymap.set("v", "<leader>/", "gc", { remap = true, desc = "Toggle selection comment" })  -- Leader + / en visual

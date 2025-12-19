-- Establece la tecla <Space> como el líder del teclado para atajos personalizados.
vim.g.mapleader = " "

-- Opciones básicas del editor para una mejor experiencia.
vim.opt.wrap = true             -- Habilita el ajuste de línea.
vim.opt.linebreak = true        -- Ajusta las líneas en los espacios.
vim.opt.breakindent = true      -- Mantiene la sangría al ajustar la línea.
vim.opt.number = true           -- Muestra los números de línea absolutos.
vim.opt.relativenumber = true   -- Muestra los números de línea relativos.
vim.cmd("syntax enable")        -- Habilita el resaltado de sintaxis.
vim.opt.colorcolumn = "100"
vim.opt.cursorline = true       -- Resalta la línea del cursor
vim.opt.cursorcolumn = false    -- No resaltar columna (puede ser distractivo)

-- para identacion
vim.opt.autoindent = true    -- Mantiene la indentación de la línea anterior
vim.opt.smartindent = true   -- Indentación inteligente para código
vim.opt.expandtab = true     -- Convierte tabs a espacios
vim.opt.tabstop = 4          -- Tamaño visual del tab
vim.opt.shiftwidth = 4       -- Espacios para auto-indentación
vim.opt.softtabstop = 4      -- Espacios al presionar tab

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

-- Función para aplicar el tema según la hora
local function set_time_based_theme()
  local current_hour = tonumber(os.date("%H"))
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  
  if current_hour >= 10 and current_hour < 17 then
    -- Horario diurno: 10am a 5pm (17:00) - Tema claro
    vim.cmd.colorscheme("catppuccin-latte")
    -- Configurar cursor para tema claro
    vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,o:hor50-Cursor/lCursor"
    vim.api.nvim_set_hl(0, "Cursor", { bg = "#dc8a78", fg = "#eff1f5" })  -- Rojo claro sobre fondo blanco
    vim.api.nvim_set_hl(0, "lCursor", { bg = "#dc8a78", fg = "#eff1f5" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#e6e9ef" })  -- Línea actual más visible
    vim.api.nvim_set_hl(0, "Visual", { bg = "#ccd0da" })  -- Selección visual más visible
  else
    -- Resto del día - TokyoNight Moon
    vim.cmd.colorscheme("tokyonight-moon")
    -- Configurar cursor para tema oscuro
    vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,o:hor50-Cursor/lCursor"
    vim.api.nvim_set_hl(0, "Cursor", { bg = "#7aa2f7", fg = "#222436" })  -- Azul sobre fondo oscuro
    vim.api.nvim_set_hl(0, "lCursor", { bg = "#7aa2f7", fg = "#222436" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2d3f76" })  -- Línea actual más visible
    vim.api.nvim_set_hl(0, "Visual", { bg = "#364a82" })  -- Selección visual más visible
  end
  
  -- Restaurar posición del cursor
  vim.api.nvim_win_set_cursor(0, cursor_pos)
end

-- Define y configura los plugins usando lazy.nvim.
require("lazy").setup({
  -- TokyoNight colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "moon", -- storm, moon, night, day
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
          functions = {},
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        on_highlights = function(highlights, colors)
          -- Mejorar visibilidad del cursor
          highlights.Cursor = { bg = colors.blue, fg = colors.bg }
          highlights.lCursor = { bg = colors.blue, fg = colors.bg }
          highlights.CursorLineNr = { fg = colors.blue, bold = true }
        end,
      })
    end,
  },

  -- Catppuccin colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "latte", -- latte, frappe, macchiato, mocha
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          cmp = true,
          nvimtree = true,
          treesitter = true,
          telescope = true,
          which_key = true,
        },
        custom_highlights = function(colors)
          return {
            -- Hacer el cursor más visible en modo normal
            Cursor = { bg = colors.red, fg = colors.base },
            lCursor = { bg = colors.red, fg = colors.base },
            -- Hacer la línea actual más visible
            CursorLine = { bg = colors.mantle },
            CursorLineNr = { fg = colors.red, style = { "bold" } },
            -- Mejorar visibilidad de selección visual
            Visual = { bg = colors.surface1 },
          }
        end,
      })
      
      -- Aplicar tema basado en la hora al inicializar
      set_time_based_theme()
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
          lua = { 'string' }, -- no añade pares en nodos de string de lua
          javascript = { 'template_string' },
          java = false, -- no revisa treesitter en java
        },
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

      -- Solo abrir quickfix si hay errores
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_quickfix_open_on_error   = 0

        vim.g.vimtex_quickfix_mode = 0
        vim.g.vimtex_quickfix_autoclose_after_keystrokes = 0

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
          '-shell-escape',
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

    -- COSAS DE MD
    -- Render Markdown estilo GitHub dentro de Neovim
    {
      "MeanderingProgrammer/render-markdown.nvim",
      dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
      ft = { "markdown" },
      config = function()
        require("render-markdown").setup({
          render_modes = { "n", "c" },
          code_style = "normal",
          heading = {
            icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
            backgrounds = { "RenderMarkdownH1Bg", "RenderMarkdownH2Bg", "RenderMarkdownH3Bg" },
          },
          link = {
            enabled = true,
            icon = "🔗 ",
          },
        })
      end,
    },

    -- Preview Markdown en navegador
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      build = "cd app && npx --yes yarn install",
      init = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
      ft = { "markdown" },
      config = function()
        vim.g.mkdp_auto_start = 0
        vim.g.mkdp_auto_close = 1
        vim.g.mkdp_refresh_slow = 0
        vim.g.mkdp_theme = 'dark'
        vim.g.mkdp_markdown_css = ''
        vim.g.mkdp_highlight_css = ''
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
    vim.opt_local.foldmethod = "manual"  -- Folding manual
    vim.opt_local.foldlevel = 99         -- Inicia con todo expandido
    vim.opt_local.textwidth = 100

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

-- Atajo manual para cambiar tema basado en hora
vim.keymap.set("n", "<leader>tt", set_time_based_theme, { desc = "Set time-based theme" })

-- Abrir todo el quickfix
vim.keymap.set("n", "<leader>la", "<cmd>copen<CR>", { desc = "LaTeX: quickfix -> todo" })

-- <leader>qc -> cerrar quickfix
vim.keymap.set("n", "<leader>ld", "<cmd>cclose<CR>", { desc = "Cerrar quickfix" })

-- Keymaps para Markdown
-- Render dentro de Neovim 
vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", { silent = true, desc = "Markdown: Toggle Render in Neovim" })

-- Preview en navegador
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { silent = true, desc = "Markdown: Preview in Browser" })
vim.keymap.set("n", "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", { silent = true, desc = "Markdown: Stop Browser Preview" })

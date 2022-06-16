local packer = prequire "config.packer"

if not packer then
  return
end

packer.startup(function(use)
  --gruvbox theme
  use { "ellisonleao/gruvbox.nvim" }

  -- Packer plugin manager
  use { "wbthomason/packer.nvim" }

  -- Interface plugins
  use {
    "nvim-lualine/lualine.nvim",
    config = function()
      require "config.lualine"
    end,
  }
  use {
    "nvim-treesitter/nvim-treesitter",
    -- event = "BufRead",
    config = function()
      require "config.treesitter"
    end,
    run = ":TSUpdate",
  }
  --use { "nathom/filetype.nvim" } -- speed up filetype detection
  use {
    "lewis6991/gitsigns.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        on_attach = function (bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          map('n', '<leader>p', gs.preview_hunk)
          map('n', '<leader>h', gs.setqflist)
        end
      })
    end,
    -- tag = 'release' -- To use the latest release
  }
  --complete engine
  use {
    "hrsh7th/nvim-cmp",
    --event = "BufRead",
    requires = {
    { "hrsh7th/cmp-buffer", after = "nvim-cmp" },
    { "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" },
    { "saadparwaiz1/cmp_luasnip", after = "LuaSnip" },
    },
    config = function()
      require "config.cmp"
    end,
  }
  -- snippets
  use {
    "L3MON4D3/LuaSnip",
    after = "nvim-cmp",
    config = function()
      require "config.snippets"
    end,
  }

  -- LSP
  -- lsp configuration
  use {
    "neovim/nvim-lspconfig",
    after = "cmp-nvim-lsp",
    config = function()
      require "config.lsp"
    end,
  }

  use {
    "SmiteshP/nvim-gps",
    requires = "nvim-treesitter/nvim-treesitter",
    wants = "nvim-treesitter",
    config = function()
      require("nvim-gps").setup { separator = " " }
    end,
    --after = "nvim-treesitter/nvim-treesitter"
  }

  use { -- Telescope fuzzy finder
    "nvim-telescope/telescope.nvim",
    requires = {
    { "nvim-lua/popup.nvim" },
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope-project.nvim" },
    { "nvim-telescope/telescope-github.nvim" },
    { "LinArcX/telescope-env.nvim" },
    { "kosayoda/nvim-lightbulb" },
    { "sbulav/telescope-terraform.nvim" },
      -- { "/Users/sab/git_priv/telescope-github.nvim" },
      -- { "/Users/sab/git_priv/OpenSource/telescope-github.nvim" },
      -- { "/Users/sab/git_priv/telescope-terraform.nvim" },
      -- {'nvim-telescope/telescope-fzy-native.nvim'}, -- fast finder
      -- {'nvim-telescope/telescope-media-files.nvim'}, -- media preview
      -- {'nvim-telescope/telescope-frecency.nvim'}, -- media preview
    },
    config = function()
      require "config.telescope"
    end,
  }

  use {
    "kyazdani42/nvim-tree.lua",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("nvim-tree").setup{
        git = {
          enable = false
        }

      }
      vim.api.nvim_set_keymap('n', '<A-m>', ':NvimTreeToggle<CR>', {noremap = true, silent = true})
    end
  }

  use {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup{
        check_ts = true
      }
    end
  }

  use {'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons', branch = 'main',
    config = function()
      require("bufferline").setup {
        tag = "v2.*",
        options = {
          -- 使用 nvim 内置lsp
          diagnostics = "nvim_lsp",
          -- 左侧让出 nvim-tree 的位置
          offsets = {{
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left"
          }},
          custom_filter = function(buf_num)
            if vim.bo[buf_num].filetype ~= 'qf' then
              return true
            end
          end
        }
      }
      vim.api.nvim_set_keymap('n', '<A-left>', ':BufferLineCyclePrev<CR>', {noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<A-right>', ':BufferLineCycleNext<CR>', {noremap = true, silent = true})

    end
  }

end)

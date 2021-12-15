local fn = vim.fn
local exec = vim.api.nvim_command
local keymap = vim.api.nvim_set_keymap
local keymap_opt = { noremap = true, silent = true }
local packer_check = {}
local servers = { 'pylsp','rust_analyzer', 'ccls' , 'sumneko_lua'}

packer_check.install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
packer_check.git_url = 'https://github.com/wbthomason/packer.nvim'
packer_check.git_command = 'git clone --depth=1 '
function packer_check:ensure_installed()
	local valid_path = fn.glob(self.install_path)
	if fn.empty(valid_path) == 1 then
		local full_cmd = 'vsp|term ' .. self.git_command .. ' ' ..  self.git_url .. ' ' .. self.install_path
		exec(full_cmd)
	end
	exec('packadd packer.nvim')
end

plugins = {}

plugins.presetup = function()
	packer_check:ensure_installed()
	require'packer'.startup(function()
		--packer
		use 'wbthomason/packer.nvim'
		--gruv 配色
		use {
			"ellisonleao/gruvbox.nvim",
			requires = {"rktjmp/lush.nvim"}
		}
		use {
			'kyazdani42/nvim-tree.lua',
			requires = 'kyazdani42/nvim-web-devicons'
		}
		use {
			'akinsho/bufferline.nvim',
			requires = 'kyazdani42/nvim-web-devicons'
		}
		use { 
			'nvim-treesitter/nvim-treesitter',
			run = ':TSUpdate' 
		}
		use {
			'neovim/nvim-lspconfig'
		}
		use {
			'nvim-lualine/lualine.nvim',
			requires = {'kyazdani42/nvim-web-devicons', opt = true}
		}
		-- nvim-cmp
		use 'hrsh7th/cmp-nvim-lsp' -- { name = nvim_lsp }
		use 'hrsh7th/cmp-buffer'   -- { name = 'buffer' },
		use 'hrsh7th/cmp-path'     -- { name = 'path' }
		use 'hrsh7th/cmp-cmdline'  -- { name = 'cmdline' }
		use 'hrsh7th/nvim-cmp'
		-- vsnip
		use 'hrsh7th/cmp-vsnip'    -- { name = 'vsnip' }
		use 'hrsh7th/vim-vsnip'
		use 'rafamadriz/friendly-snippets'
		-- lspkind
		use 'onsails/lspkind-nvim'
	end)
end


local nvim_tree_setup = function()
	require('nvim-tree').setup{
		auto_close = true,
		git = {
			enable = false
		}
	}
	keymap('n', '<A-m>', ':NvimTreeToggle<CR>', keymap_opt)
end

local theme_setup = function()
	vim.cmd('colorscheme gruvbox')
	vim.opt.termguicolors = true
end

local bufferline_setup = function()
	require("bufferline").setup {
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
	keymap('n', '<A-left>', ':BufferLineCyclePrev<CR>', keymap_opt)
	keymap('n', '<A-right>', ':BufferLineCycleNext<CR>', keymap_opt)
end

local nvim_treesitter_setup = function()
	require'nvim-treesitter.configs'.setup {
		-- 安装 language parser
		-- :TSInstallInfo 命令查看支持的语言
		ensure_installed = {"vim", "lua", "c", "cpp", "rust", "python"},
		-- 启用代码高亮功能
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false
		},
		-- 启用增量选择
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = '<CR>',
				node_incremental = '<CR>',
				node_decremental = '<BS>',
				scope_incremental = '<TAB>',
			}
		},
		-- 启用基于Treesitter的代码格式化(=) . NOTE: This is an experimental feature.
		indent = {
			enable = true
		}
	}
	-- 开启 Folding
	vim.wo.foldmethod = 'expr'
	vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
	-- 默认不要折叠
	-- https://stackoverflow.com/questions/8316139/how-to-set-the-default-to-unfolded-when-you-open-a-file
	vim.wo.foldlevel = 99
end


local lsp_setup = function()
	local nvim_lsp = require('lspconfig')
	-- Use an on_attach function to only map the following keys
	-- after the language server attaches to the current buffer
	local on_attach = function(client, bufnr)
		local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
		local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

		-- Enable completion triggered by <c-x><c-o>
		buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

		-- Mappings.
		local opts = { noremap=true, silent=true }

		-- See `:help vim.lsp.*` for documentation on any of the below functions
		buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
		buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
		buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
		buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
		buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
		buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
		buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
		buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
		buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
		buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
		buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
		buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
		buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
		buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
		buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
		buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
		buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

	end

	-- Use a loop to conveniently call 'setup' on multiple servers and
	-- map buffer local keybindings when the language server attaches
	for _, lsp in ipairs(servers) do
		nvim_lsp[lsp].setup {
			on_attach = on_attach,
			flags = {
			}
		}
	end
	keymap('n', '<A-]>', ':cn<CR>', keymap_opt)
	keymap('n', '<A-[>', ':cp<CR>', keymap_opt)

end

local nvim_cmp_setup = function()
	local cmp = require('cmp')
	local lspkind = require('lspkind')
	cmp.setup({
		snippet = {
			-- REQUIRED - you must specify a snippet engine
			expand = function(args)
				vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
				-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
				-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
				-- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
			end,
		},


		mapping = {
			['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
			['<TAB>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
			['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
			['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
			['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
			['<C-b>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<C-Space>'] = cmp.mapping.complete(),
			['<C-e>'] = cmp.mapping.close(),
			['<CR>'] = cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Replace,
				select = true,
			}),
			['<A-.>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' })
		},

		sources = cmp.config.sources({
			{ name = 'nvim_lsp' },
			{ name = 'vsnip' }, -- For vsnip users.
			-- { name = 'luasnip' }, -- For luasnip users.
			-- { name = 'ultisnips' }, -- For ultisnips users.
			-- { name = 'snippy' }, -- For snippy users.
		}, {
				{ name = 'buffer' },
				{ name = 'path' }
			})
	})
	-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
	cmp.setup.cmdline(':', {
		sources = cmp.config.sources({
			{ name = 'path' }
		}, {
				{ name = 'cmdline' }
			})
	})

	-- Use buffer source for `/`.
	cmp.setup.cmdline('/', {
		sources = {
			{ name = 'buffer' }
		}
	})


end

local lualine_setup = function ()
	require'lualine'.setup{
		theme = 'gruvbox'
	}
end


plugins.setup = function()
	nvim_tree_setup()
	theme_setup()
	bufferline_setup()
	nvim_treesitter_setup()
	lsp_setup()
	nvim_cmp_setup()
	lualine_setup()
end



return plugins

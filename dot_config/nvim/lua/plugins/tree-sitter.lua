return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
	local config = require("nvim-treesitter.config")

	config.setup({
	    highlight = { enable = true },
	    indent = { enable = true },
	    autoage = { enable = true },
	    auto_install = false,
	    ensure_installed = {
		'c',
		'c++',
		'c#',
		'lua',
		'vim',
		'vimdoc',
		'markdown',
		'markdown_inline',
		'go',
		'python',
		'tsx',
		'typescript',
		'rust',
		'zig',
		'kotlin',
	    },
	})

    end
}


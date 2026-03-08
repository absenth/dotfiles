return {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
        automatic_installation = true,
        handlers = {
            function(server_name)
                require('lspconfig')[server_name].setup({})
            end,
            ['lua_ls'] = function()
                require('lspconfig').lua_ls.setup({
                    settings = {
                        Lua = {
                            diagnostics = { globals = { 'vim' } },
                            workspace = { library = vim.api.nvim_get_runtime_file('', true), checkThirdParty = false },
                        },
                    },
                })
            end,
        },
    },
}

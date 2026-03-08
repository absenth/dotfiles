return {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
        diagnostics = { underline = true, update_in_insert = false, virtual_text = { spacing = 4, prefix = '●' }, severity_sort = true },
        capabilities = {},
        format = { formatting_options = nil, timeout_ms = nil },
        servers = {},
        setup = {},
    },
    config = function(_, opts)
        vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
        local capabilities = vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), opts.capabilities)
        local function setup(server)
            local server_opts = vim.tbl_deep_extend('force', { capabilities = capabilities }, opts.servers[server] or {})
            if opts.setup[server] then
                if opts.setup[server](server, server_opts) then return end
            elseif opts.setup['*'] then
                if opts.setup['*'](server, server_opts) then return end
            end
            require('lspconfig')[server].setup(server_opts)
        end
        local have_mason, mlsp = pcall(require, 'mason-lspconfig')
        local all_mslp_servers = {}
        if have_mason then all_mslp_servers = vim.tbl_keys(require('mason-lspconfig.mappings.server').lspconfig_to_package) end
        local ensure_installed = {}
        for server, server_opts in pairs(opts.servers) do
            if server_opts then
                server_opts = server_opts == true and {} or server_opts
                if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
                    setup(server)
                else
                    ensure_installed[server] = server_opts
                end
            end
        end
        if have_mason then
            mlsp.setup({ handlers = { setup }, ensure_installed = ensure_installed })
        end
    end,
}

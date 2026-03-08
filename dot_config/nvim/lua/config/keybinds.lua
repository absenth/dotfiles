vim.g.mapleader = ' '
vim.keymap.set('n', '<leader>cd', vim.cmd.Ex)

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP go to definition' })
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'LSP go to declaration' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'LSP references' })
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'LSP implementation' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'LSP hover' })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP code action' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'LSP rename' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'LSP diagnostics open' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'LSP diagnostics list' })

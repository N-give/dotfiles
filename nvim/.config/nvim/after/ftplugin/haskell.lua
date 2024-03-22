local ht = require('haskell-tools')

local bufnr = vim.api.nvim_get_current_buf()
local nmap = function(keys, func, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end
  local def_opts = { noremap = true, silent = true, buffer = bufnr, desc = desc, }
  vim.keymap.set('n', keys, func, def_opts)
end

-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
nmap('<space>cl', vim.lsp.codelens.run, '[C]ode [L]ens')
-- Hoogle search for the type signature of the definition under the cursor
nmap('<space>hs', ht.hoogle.hoogle_signature, '[H]oogle [S]earch')
-- Evaluate all code snippets
nmap('<space>ea', ht.lsp.buf_eval_all, '[E]valuate [A]ll code snippets')
-- Toggle a GHCi repl for the current package
nmap('<leader>rr', ht.repl.toggle, 'toggle [R]epl for current package')
-- Toggle a GHCi repl for the current buffer
nmap('<leader>rf', function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, 'toggle [R]epl for current buffer')
nmap('<leader>rq', ht.repl.quit, '[R]epl [Q]uit')

nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

-- See `:help K` for why this keymap
nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

-- Lesser used LSP functionality
nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
nmap('<leader>wl', function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, '[W]orkspace [L]ist Folders')
nmap('<leader>fa', vim.lsp.buf.format, '[F]ormat [A]ll')

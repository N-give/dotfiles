local nmap = function(keys, func, bufnr, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end

  vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      {
        "ray-x/go.nvim",
        dependencies = { -- optional packages
          "ray-x/guihua.lua",
          "neovim/nvim-lspconfig",
          "nvim-treesitter/nvim-treesitter",
        },
        config = function()
          require("go").setup()
        end,
        event = { "CmdlineEnter" },
        ft = { "go", 'gomod' },
        build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
      },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            print('No client')
            return
          end

          if client.supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
              end,
            })
          end

          if client.supports_method('textDocument/definition') then
            nmap('<leader>gd', vim.lsp.buf.definition, args.buf, '[G]oto [D]efinition')
          end
          if client.supports_method('textDocument/implementation*') then
            nmap('<leader>gI', vim.lsp.buf.implementation, args.buf, '[G]oto [I]mplementation')
          end
          if client.supports_method('textDocument/typeDefinition*') then
            nmap('<leader>D', vim.lsp.buf.type_definition, args.buf, 'Type [D]efinition')
          end
          if client.supports_method('textDocument/rename') then
            nmap('<leader>rn', vim.lsp.buf.rename, args.buf, '[R]e[n]ame')
          end
          if client.supports_method('textDocument/codeAction') then
            nmap('<leader>ca', vim.lsp.buf.code_action, args.buf, '[C]ode [A]ction')
          end
          if client.supports_method('textDocument/hover') then
            nmap('K', vim.lsp.buf.hover, args.buf, 'Hover Documentation')
          end
          if client.supports_method('textDocument/signatureHelp') then
            nmap('<C-k>', vim.lsp.buf.signature_help, args.buf, 'Signature Help')
          end
          nmap('<leader>sr', require('telescope.builtin').lsp_references, args.buf, '[S]earch [R]eferences')
          nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, args.buf, '[D]ocument [S]ymbols')
          nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, args.buf,
            '[W]orkspace [S]ymbols')
        end
      })
    end,
  }
}

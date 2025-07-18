--[[
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.

  nmap('<leader>fa', vim.lsp.buf.format, '[F]ormat [A]ll')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end
]] --

local nmap = function(keys, func, desc)
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
      -- {
      --   'mrcjkb/haskell-tools.nvim',
      --   requires = {
      --     'nvim-lua/plenary.nvim',
      --     'nvim-telescope/telescope.nvim', -- optional
      --   },
      --   branch = '2.x.x', -- recommended
      -- },
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      require('lspconfig').denols.setup { capabilities = capabilities, }
      require('lspconfig').elmls.setup { capabilities = capabilities, }
      require('lspconfig').gopls.setup { capabilities = capabilities, }
      require('lspconfig').hls.setup {
        capabilities = capabilities,
        filetypes = {
          'haskell',
          'lhaskell',
          'cabal',
        }
      }
      require('lspconfig').lua_ls.setup { capabilities = capabilities, }
      require('lspconfig').rust_analyzer.setup { capabilities = capabilities, }
      require('lspconfig').ts_ls.setup { capabilities = capabilities, }
      require('lspconfig').zls.setup { capabilities = capabilities, }

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
            nmap('<leader>gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          end
          if client.supports_method('textDocument/implementation*') then
            nmap('<leader>gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          end
          if client.supports_method('textDocument/typeDefinition*') then
            nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          end
          if client.supports_method('textDocument/rename') then
            nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          end
          if client.supports_method('textDocument/codeAction') then
            nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          end
          if client.supports_method('textDocument/hover') then
            nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
          end
          if client.supports_method('textDocument/signatureHelp') then
            nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Help')
          end
          nmap('<leader>sr', require('telescope.builtin').lsp_references, '[S]earch [R]eferences')
          nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        end
      })
    end,
  }
}

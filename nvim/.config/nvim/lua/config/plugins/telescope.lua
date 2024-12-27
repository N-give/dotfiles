return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
    },
    config = function()
      require('telescope').setup({
        defaults = require('telescope.themes').get_ivy(),
        extensions = {
          fzf = {},
        },
        -- pickers = {
        --   find_files = {
        --     theme = 'ivy',
        --   },
        -- },
      })

      require('telescope').load_extension('fzf')

      vim.keymap.set('n', '<leader>en', function()
        require('telescope.builtin').find_files({
          cwd = vim.fn.stdpath('config')
        })
      end)

      vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, {
        desc = '[S]earch [F]iles',
      })
      vim.keymap.set('n', '<leader>so', require('telescope.builtin').oldfiles, {
        desc = '[S]earch [O]ld files'
      })
      vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, {
        desc = '[S]earch existing [B]uffers'
      })
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require('telescope.builtin').current_buffer_fuzzy_find(
          require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
      end, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, {
        desc = '[S]earch [H]elp'
      })
      vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, {
        desc = '[S]earch current [W]ord'
      })
      vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, {
        desc = '[S]earch by [G]rep'
      })
      vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, {
        desc = '[S]earch [D]iagnostics'
      })
      require('config.telescope.multigrep').setup()
    end,
  }
}

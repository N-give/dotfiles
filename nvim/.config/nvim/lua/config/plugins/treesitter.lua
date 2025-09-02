return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          'c',
          'go',
          'elm',
          'fennel',
          'gleam',
          'haskell',
          'javascript',
          'lua',
          'nix',
          'python',
          'rust',
          'tsx',
          'typescript',
          'vim',
          'zig',
        },
        sync_install = false,
        highlight = {
          enable = true,
          disable = function(_lang, buf)
            local max_filesize = 100 * 1024
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end
        },
        indent = { enable = true, disable = { 'python' }, },
        auto_install = false,
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['aa'] = '@attribute.outer',
              ['ia'] = '@attribute.inner',
              ['ab'] = '@block.outer',
              ['ib'] = '@block.inner',
              ['ad'] = '@conditional.outer',
              ['id'] = '@conditional.inner',
              ['al'] = '@loop.outer',
              ['il'] = '@loop.inner',
              ['ai'] = '@parameter.outer',
              ['ii'] = '@parameter.inner',
              ['ar'] = '@regex.outer',
              ['ir'] = '@regex.inner',
              ['ax'] = '@class.outer',
              ['ix'] = '@class.inner',
              ['as'] = '@statement.outer',
              ['is'] = '@statement.inner',
              ['an'] = '@number.outer',
              ['in'] = '@number.inner',
              ['ac'] = '@comment.outer',
              ['ic'] = '@comment.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']f'] = { query = '@function.outer', desc = 'Next function start' },
              [']b'] = { query = '@block.outer', desc = 'Next block start' },
              [']d'] = { query = '@conditional.outer', desc = 'Next conditional start' },
              [']l'] = { query = '@loop.outer', desc = 'Next loop start' },
              [']i'] = { query = '@parameter.outer', desc = 'Next parameter start' },
              [']r'] = { query = '@regex.outer', desc = 'Next regex start' },
              [']x'] = { query = '@class.outer', desc = 'Next class start' },
              [']s'] = { query = '@statement.outer', desc = 'Next statement start' },
              [']n'] = { query = '@number.outer', desc = 'Next number start' },
              [']c'] = { query = '@comment.outer', desc = 'Next comment start' },
            },
            goto_next_end = {
              [']F'] = { query = '@function.outer', desc = 'Next function end' },
              [']B'] = { query = '@block.outer', desc = 'Next block end' },
              [']D'] = { query = '@conditional.outer', desc = 'Next conditional end' },
              [']L'] = { query = '@loop.outer', desc = 'Next loop end' },
              [']I'] = { query = '@parameter.outer', desc = 'Next parameter end' },
              [']R'] = { query = '@regex.outer', desc = 'Next regex end' },
              [']X'] = { query = '@class.outer', desc = 'Next class end' },
              [']S'] = { query = '@statement.outer', desc = 'Next statement end' },
              [']N'] = { query = '@number.outer', desc = 'Next number end' },
              [']C'] = { query = '@comment.outer', desc = 'Next comment end' },
            },
            goto_previous_start = {
              ['[f'] = { query = '@function.outer', desc = 'Previous function start' },
              ['[b'] = { query = '@block.outer', desc = 'Previous block start' },
              ['[d'] = { query = '@conditional.outer', desc = 'Previous conditional start' },
              ['[l'] = { query = '@loop.outer', desc = 'Previous loop start' },
              ['[i'] = { query = '@parameter.outer', desc = 'Previous parameter start' },
              ['[r'] = { query = '@regex.outer', desc = 'Previous regex start' },
              ['[x'] = { query = '@class.outer', desc = 'Previous class start' },
              ['[s'] = { query = '@statement.outer', desc = 'Previous statement start' },
              ['[n'] = { query = '@number.outer', desc = 'Previous number start' },
              ['[c'] = { query = '@comment.outer', desc = 'Previous comment start' },
            },
            goto_previous_end = {
              ['[F'] = { query = '@function.outer', desc = 'Previous function end' },
              ['[B'] = { query = '@block.outer', desc = 'Previous block end' },
              ['[D'] = { query = '@conditional.outer', desc = 'Previous conditional end' },
              ['[L'] = { query = '@loop.outer', desc = 'Previous loop end' },
              ['[I'] = { query = '@parameter.outer', desc = 'Previous parameter end' },
              ['[R'] = { query = '@regex.outer', desc = 'Previous regex end' },
              ['[X'] = { query = '@class.outer', desc = 'Previous class end' },
              ['[S'] = { query = '@statement.outer', desc = 'Previous statement end' },
              ['[N'] = { query = '@number.outer', desc = 'Previous number end' },
              ['[C'] = { query = '@comment.outer', desc = 'Previous comment end' },
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['>f'] = { query = '@function.outer', desc = 'Swap next function' },
              ['>b'] = { query = '@block.outer', desc = 'Swap next block' },
              ['>d'] = { query = '@conditional.outer', desc = 'Swap next conditional' },
              ['>l'] = { query = '@loop.outer', desc = 'Swap next loop' },
              ['>i'] = { query = '@parameter.inner', desc = 'Swap next parameter' },
              ['>r'] = { query = '@regex.outer', desc = 'Swap next regex' },
              ['>x'] = { query = '@class.outer', desc = 'Swap next statement' },
              ['>s'] = { query = '@statement.outer', desc = 'Swap next statement' },
              ['>n'] = { query = '@number.inner', desc = 'Swap next number' },
              ['>c'] = { query = '@comment.outer', desc = 'Swap next comment' },
            },
            swap_previous = {
              ['<f'] = { query = '@function.outer', desc = 'Swap previous function' },
              ['<b'] = { query = '@block.outer', desc = 'Swap previous block' },
              ['<d'] = { query = '@conditional.outer', desc = 'Swap previous conditional' },
              ['<l'] = { query = '@loop.outer', desc = 'Swap previous loop' },
              ['<i'] = { query = '@parameter.inner', desc = 'Swap previous parameter' },
              ['<r'] = { query = '@regex.outer', desc = 'Swap previous regex' },
              ['<x'] = { query = '@class.outer', desc = 'Swap previous statement' },
              ['<s'] = { query = '@statement.outer', desc = 'Swap previous statement' },
              ['<n'] = { query = '@number.inner', desc = 'Swap previous number' },
              ['<c'] = { query = '@comment.outer', desc = 'Swap previous comment' },
            },
          },
        },
      })
    end,
  },
}

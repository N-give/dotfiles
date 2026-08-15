vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.syntax = "on"
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.backspace = "indent,eol,start"
vim.opt.autoindent = true
vim.opt.confirm = true
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.showmatch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.textwidth = 80
vim.opt.mouse = "a"
vim.opt.formatprg = ""
vim.opt.colorcolumn = "80"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = true
vim.opt.formatoptions:remove({ 'o' })

vim.keymap.set('n', '<leader><leader>x', '<cmd>source %<cr>')
vim.keymap.set('n', '<leader>x', ':.lua<cr>')
vim.keymap.set('v', '<leader>x', ':lua<cr>')

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- vim pack
vim.pack.add({
  { src = 'https://github.com/catppuccin/nvim' },
  { src = 'https://github.com/echasnovski/mini.icons' },
  { src = 'https://github.com/folke/lazydev.nvim' },
  { src = 'https://github.com/kylechui/nvim-surround' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim',     name = 'ibl', },
  { src = 'https://github.com/numToStr/Comment.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/saghen/blink.cmp' },
  { src = 'https://github.com/saghen/blink.lib' },
  { src = 'https://github.com/stevearc/oil.nvim',                       name = 'oil' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/tpope/vim-rhubarb' },
  { src = 'https://github.com/tpope/vim-sleuth' },
})

-- colorscheme
vim.cmd.colorscheme "catppuccin-nvim"

-- Comment
require('Comment').setup()

-- completions
local cmp = require('blink.cmp')
cmp.build():pwait()
cmp.setup({
  -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
  -- 'super-tab' for mappings similar to vscode (tab to accept)
  -- 'enter' for enter to accept
  -- 'none' for no mappings
  --
  -- All presets have the following mappings:
  -- C-space: Open menu or open docs if already open
  -- C-n/C-p or Up/Down: Select next/previous item
  -- C-e: Hide menu
  -- C-k: Toggle signature help (if signature.enabled = true)
  --
  -- See :h blink-cmp-config-keymap for defining your own keymap
  keymap = {
    preset = 'default',
  },

  -- (Default) Only show the documentation popup when manually triggered
  completion = { documentation = { auto_show = false } },

  -- (Default) list of enabled providers defined so that you can extend it
  -- elsewhere in your config, without redefining it, due to `opts_extend`
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
    providers = {
      lazydev = {
        name = 'LazyDev',
        module = 'lazydev.integrations.blink',
        score_offset = 100,
      },
    },
  },

  -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
  -- You may use a lua implementation instead by using `implementation = "lua"`
  -- See the fuzzy documentation for more information
  fuzzy = { implementation = "rust" },

  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = 'mono',
  },
})

-- diagnostics
vim.keymap.set('n', '<leader>ep', function()
  vim.diagnostic.jump({ count = -1, wrap = true, })
end, { desc = "Go to previous diagnostic message", })
vim.keymap.set('n', '<leader>en', function()
  vim.diagnostic.jump({ count = 1, wrap = true, })
end, { desc = "Go to next diagnostic message" })
vim.keymap.set('n', '<leader>ee', vim.diagnostic.open_float, {
  desc = "Open floating diagnostic message"
})
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {
  desc = "Open diagnostics list"
})

-- gitsigns
require('gitsigns').setup()

-- indent-blankline
require('ibl').setup()

-- Oil
require('oil').setup()
vim.keymap.set('n', '<leader>-', '<cmd>Oil<cr>', {
  desc = 'Open parent directory',
})

-- quickfix
vim.keymap.set('n', '<C-j>', '<cmd>cnext<cr>', { desc = 'Move to next Quickfix entry', })
vim.keymap.set('n', '<C-k>', '<cmd>cprev<cr>', { desc = 'Move to prev Quickfix entry', })
vim.keymap.set('n', '<leader>co', '<cmd>copen<cr>', { desc = 'Open Quickfik list', })
vim.keymap.set('n', '<leader>cc', '<cmd>cclose<cr>', { desc = 'Close Quickfik list', })

-- lsp
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      print('No client')
      return
    end

    if client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
        end,
      })
    end

    if client:supports_method('textDocument/definition') then
      nmap('<leader>gd', vim.lsp.buf.definition, args.buf, '[G]oto [D]efinition')
    end
    if client:supports_method('textDocument/implementation*') then
      nmap('<leader>gI', vim.lsp.buf.implementation, args.buf, '[G]oto [I]mplementation')
    end
    if client:supports_method('textDocument/typeDefinition*') then
      nmap('<leader>D', vim.lsp.buf.type_definition, args.buf, 'Type [D]efinition')
    end
    if client:supports_method('textDocument/rename') then
      nmap('<leader>rn', vim.lsp.buf.rename, args.buf, '[R]e[n]ame')
    end
    if client:supports_method('textDocument/codeAction') then
      nmap('<leader>ca', vim.lsp.buf.code_action, args.buf, '[C]ode [A]ction')
    end
    if client:supports_method('textDocument/hover') then
      nmap('K', vim.lsp.buf.hover, args.buf, 'Hover Documentation')
    end
    if client:supports_method('textDocument/signatureHelp') then
      nmap('<C-k>', vim.lsp.buf.signature_help, args.buf, 'Signature Help')
    end
    nmap('<leader>sr', require('telescope.builtin').lsp_references, args.buf, '[S]earch [R]eferences')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, args.buf, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, args.buf,
      '[W]orkspace [S]ymbols')
  end
})

vim.lsp.enable({
  'denols',
  'elmls',
  'fennel_ls',
  'gleam',
  'hls',
  'lua_ls',
  'rust_analyzer',
  'ts_ls',
})

-- macros
vim.keymap.set('v', 'ma', function()
  local macro = vim.fn.input("macro: ")
  vim.api.nvim_feedkeys(":'<,'>norm! @" .. macro .. vim.api.nvim_replace_termcodes("<cr>", true, true, true), 't', false)
end, { desc = 'Apply macro to selected lines' })

-- surround
require('nvim-surround').setup()

-- telescope
require('telescope').setup({
  defaults = require('telescope.themes').get_dropdown(),
  extensions = {
    -- fzf = {},
  },
})
-- require('telescope').load_extension('fzf')

-- vim.api.nvim_create_autocmd('PackChanged', {
--   callback = function(ev)
--     local name, kind = ev.data.spec.name, ev.data.kind
--     if name == 'nvim-treesitter' and kind == 'update' then
--       if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
--       vim.cmd('TSUpdate')
--     end
--   end
-- })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>sf', builtin.find_files, {
  desc = '[S]earch [F]iles',
})
vim.keymap.set('n', '<leader>so', builtin.oldfiles, {
  desc = '[S]earch [O]ld files'
})
vim.keymap.set('n', '<leader>sb', builtin.buffers, {
  desc = '[S]earch existing [B]uffers'
})
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  builtin.current_buffer_fuzzy_find(
    require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, {
  desc = '[S]earch [H]elp'
})
vim.keymap.set('n', '<leader>sw', builtin.grep_string, {
  desc = '[S]earch current [W]ord'
})
vim.keymap.set('n', '<leader>sg', builtin.live_grep, {
  desc = '[S]earch by [G]rep'
})
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, {
  desc = '[S]earch [D]iagnostics'
})

-- treesitter
require('nvim-treesitter').setup({
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath('data') .. '/site'
})
require('nvim-treesitter').install({
  'c',
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
})

-- treesitter textobjects
require('nvim-treesitter-textobjects').setup({
  select = {
    enable = true,
    lookahead = true -- automatically jump forward to textobj
  },
  move = {
    set_jumps = true,
  },
})

---@class TOConfig
---@field query string Treesitter Query
---@field desc  string Description for keymap

-- treesitter textobjects: selections

---@param keys   string Keys to map
---@param config TOConfig
local set_select_keymap = function(keys, config)
  vim.keymap.set({ 'x', 'o' }, keys, function()
    require('nvim-treesitter-textobjects.select').select_textobject(config.query, 'textobjects')
  end, { desc = config.desc })
end
local select_keymaps = {
  ['af'] = { '@function.outer', desc = 'Select [O]uter [F]unction' },
  ['if'] = { '@function.inner', desc = 'Select [I]nner [F]unction' },
  ['aa'] = { '@attribute.outer', desc = 'Select [O]uter [A]ttribute' },
  ['ia'] = { '@attribute.inner', desc = 'Select [I]nner [A]ttribute' },
  ['ab'] = { '@block.outer', desc = 'Select [O]uter [B]lock' },
  ['ib'] = { '@block.inner', desc = 'Select [I]nner [B]lock' },
  ['ad'] = { '@conditional.outer', desc = 'Select [O]uter con[D]itional' },
  ['id'] = { '@conditional.inner', desc = 'Select [I]nner con[D]itional' },
  ['al'] = { '@loop.outer', desc = 'Select [O]uter [L]oop' },
  ['il'] = { '@loop.inner', desc = 'Select [I]nner [L]oop' },
  ['ai'] = { '@parameter.outer', desc = 'Select [O]uter [P]arameter' },
  ['ii'] = { '@parameter.inner', desc = 'Select [I]nner [P]arameter' },
  ['ar'] = { '@regex.outer', desc = 'Select [O]uter [R]egex' },
  ['ir'] = { '@regex.inner', desc = 'Select [I]nner [R]egex' },
  ['ax'] = { '@class.outer', desc = 'Select [O]uter [X]class' },
  ['ix'] = { '@class.inner', desc = 'Select [I]nner [X]class' },
  ['as'] = { '@statement.outer', desc = 'Select [O]uter [S]tatement' },
  ['is'] = { '@statement.inner', desc = 'Select [I]nner [S]tatement' },
  ['an'] = { '@number.outer', desc = 'Select [O]uter [N]umber' },
  ['in'] = { '@number.inner', desc = 'Select [I]nner [N]umber' },
  ['ac'] = { '@comment.outer', desc = 'Select [O]uter [C]omment' },
  ['ic'] = { '@comment.inner', desc = 'Select [I]nner [C]omment' },
}
for keys, config in pairs(select_keymaps) do
  set_select_keymap(keys, config)
end

---@param keys   string
---@param config TOConfig
local set_goto_next_start_keymap = function(keys, config)
  vim.keymap.set({ 'n', 'x', 'o', }, keys, function()
    require('nvim-treesitter-textobjects.move').goto_next_start(config.query, 'textobjects')
  end, { desc = config.desc })
end
local goto_next_start_keymaps = {
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
}
for keys, config in pairs(goto_next_start_keymaps) do
  set_goto_next_start_keymap(keys, config)
end

---@param keys   string
---@param config TOConfig
local set_goto_next_end_keymap = function(keys, config)
  vim.keymap.set({ 'n', 'x', 'o', }, keys, function()
    require('nvim-treesitter-textobjects.move').goto_next_end(config.query, 'textobjects')
  end, { desc = config.desc })
end
local goto_next_end_keymaps = {
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
}
for keys, config in pairs(goto_next_end_keymaps) do
  set_goto_next_end_keymap(keys, config)
end

---@param keys   string
---@param config TOConfig
local set_goto_previous_start_keymap = function(keys, config)
  vim.keymap.set({ 'n', 'x', 'o', }, keys, function()
    require('nvim-treesitter-textobjects.move').goto_previous_start(config.query, 'textobjects')
  end, { desc = config.desc })
end
local goto_previous_start_keymap = {
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
}
for keys, config in pairs(goto_previous_start_keymap) do
  set_goto_previous_start_keymap(keys, config)
end

---@param keys   string
---@param config TOConfig
local set_goto_previous_end_keymap = function(keys, config)
  vim.keymap.set({ 'n', 'x', 'o', }, keys, function()
    require('nvim-treesitter-textobjects.move').goto_previous_end(config.query, 'textobjects')
  end, { desc = config.desc })
end
local goto_previous_end_keymap = {
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
}
for keys, config in pairs(goto_previous_end_keymap) do
  set_goto_previous_end_keymap(keys, config)
end

---@param keys   string
---@param config TOConfig
local set_swap_next_keymap = function(keys, config)
  vim.keymap.set({ 'n' }, keys, function()
    require('nvim-treesitter-textobjects.swap').swap_next(config.query, 'textobjects')
  end, { desc = config.desc })
end
local swap_next_keymaps = {
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
}
for keys, config in pairs(swap_next_keymaps) do
  set_swap_next_keymap(keys, config)
end

---@param keys   string
---@param config TOConfig
local set_swap_previous_keymap = function(keys, config)
  vim.keymap.set({ 'n' }, keys, function()
    require('nvim-treesitter-textobjects.swap').swap_previous(config.query, 'textobjects')
  end, { desc = config.desc })
end
local swap_previous_keymaps = {
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
}
for keys, config in pairs(swap_previous_keymaps) do
  set_swap_previous_keymap(keys, config)
end

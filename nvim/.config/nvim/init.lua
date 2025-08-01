vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.lsp')
require('config.lazy')

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

-- diagnostics
vim.keymap.set('n', '<leader>ep', vim.diagnostic.goto_prev, {
  desc = "Go to previous diagnostic message"
})
vim.keymap.set('n', '<leader>en', vim.diagnostic.goto_next, {
  desc = "Go to next diagnostic message"
})
vim.keymap.set('n', '<leader>ee', vim.diagnostic.open_float, {
  desc = "Open floating diagnostic message"
})
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {
  desc = "Open diagnostics list"
})

-- Oil
vim.keymap.set('n', '<leader>-', '<cmd>Oil<cr>', {
  desc = 'Open parent directory',
})

-- quickfix
vim.keymap.set('n', '<C-j>', '<cmd>cnext<cr>', { desc = 'Move to next Quickfix entry', })
vim.keymap.set('n', '<C-k>', '<cmd>cprev<cr>', { desc = 'Move to prev Quickfix entry', })
vim.keymap.set('n', '<leader>co', '<cmd>copen<cr>', { desc = 'Open Quickfik list', })
vim.keymap.set('n', '<leader>cc', '<cmd>cclose<cr>', { desc = 'Close Quickfik list', })

vim.keymap.set('v', 'ma', function()
  local macro = vim.fn.input("macro: ")
  vim.api.nvim_feedkeys(":'<,'>norm! @" .. macro .. vim.api.nvim_replace_termcodes("<cr>", true, true, true), 't', false)
end, { desc = 'Apply macro to selected lines' })

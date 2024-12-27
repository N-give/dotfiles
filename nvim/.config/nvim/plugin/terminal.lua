vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Open terminal without line numbers',
  group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
  callback = function()
    -- vim.opt.number = false
    -- vim.opt.relativenumber = false
  end,
})

vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>')

local job_id = 0
vim.keymap.set('n', '<leader>st', function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd('J')
  vim.api.nvim_win_set_height(0, 10)
  job_id = vim.bo.channel
end, { desc = 'Open a small terminal', })

vim.keymap.set('n', '<leader>ts', function()
  vim.fn.chansend(job_id, { 'ls\r\n' })
end, { desc = 'Start terminal with command' })


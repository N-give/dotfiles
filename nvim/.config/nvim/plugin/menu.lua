vim.cmd [[
  aunmenu PopUp
  anoremenu PopUp.Inspect    <cmd>Inspect<cr>
  amenu PopUp.-1-            <nop>
  anoremenu PopUP.Definition <cmd>lua vim.lsp.buf.difintion()<cr>
  anoremenu PopUP.References <cmd>Telescope lsp_references<cr>
]]

local group = vim.api.nvim_create_augroup('nvim_popupmenu', { clear = true })
vim.api.nvim_create_autocmd('MenuPopup', {
  pattern = '*',
  group = group,
  desc = 'Custom PopUp Setup',
  callback = function()
    vim.cmd [[
      amenu disable PopUp.Definition
      amenu disable PopUp.References
    ]]

    if vim.lsp.get_clients({ bufnr = 0 })[1] then
      vim.cmd [[
        amenu enable PopUp.Definition
        amenu enable PopUp.References
      ]]
    end 
  end,
})

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = vim.api.nvim_create_augroup("xdg_open", { clear = true }),
  pattern = { "*.pdf", "*.doc", "*.docx", "*.odt", "*.ods", "*.odp", "*.xls", "*.xlsx", "*.ppt", "*.pptx" },
  callback = function(ev)
    vim.fn.jobstart({ "xdg-open", ev.file }, { detach = true })
    vim.schedule(function()
      vim.api.nvim_buf_delete(ev.buf, { force = true })
    end)
  end,
})

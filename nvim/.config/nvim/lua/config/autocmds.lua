-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Match terminal colors to Sandstone/kitty palette
local function apply_sandstone_colors()
  vim.g.terminal_color_0  = "#3d3228"
  vim.g.terminal_color_1  = "#c46a6a"
  vim.g.terminal_color_2  = "#8aab88"
  vim.g.terminal_color_3  = "#d4b483"
  vim.g.terminal_color_4  = "#8aacba"
  vim.g.terminal_color_5  = "#b08099"
  vim.g.terminal_color_6  = "#7aaa9e"
  vim.g.terminal_color_7  = "#a89880"
  vim.g.terminal_color_8  = "#6b5a49"
  vim.g.terminal_color_9  = "#c46a6a"
  vim.g.terminal_color_10 = "#8aab88"
  vim.g.terminal_color_11 = "#d4b483"
  vim.g.terminal_color_12 = "#8aacba"
  vim.g.terminal_color_13 = "#b08099"
  vim.g.terminal_color_14 = "#7aaa9e"
  vim.g.terminal_color_15 = "#e8d5bf"
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1a1512", fg = "#e8d5bf" })
  vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#1a1512", fg = "#6b5a49" })
end

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("sandstone_terminal_colors", { clear = true }),
  pattern = "LazyVimStarted",
  callback = apply_sandstone_colors,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("sandstone_terminal_colors_cs", { clear = true }),
  callback = apply_sandstone_colors,
})

vim.api.nvim_create_autocmd("SwapExists", {
  group = vim.api.nvim_create_augroup("auto_swap_edit", { clear = true }),
  callback = function()
    local info = vim.fn.swapinfo(vim.v.swapname)
    local swapname = vim.v.swapname
    local pid = info.pid
    local alive = pid and vim.fn.isdirectory("/proc/" .. tostring(pid)) == 1
    if alive then
      vim.v.swapchoice = "o"
    elseif info.dirty == 1 then
      vim.v.swapchoice = "r"
      vim.schedule(function()
        vim.fn.delete(swapname)
        vim.notify("Recovered unsaved changes from swap file.", vim.log.levels.WARN, { title = "Recovery" })
      end)
    else
      vim.v.swapchoice = "d"
    end
  end,
})

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

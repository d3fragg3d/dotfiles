-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Find any file from home directory (equivalent to C-c f in Emacs)
vim.keymap.set("n", "<leader>F", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.expand("~"),
    hidden = true,
    find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
  })
end, { desc = "Find Files (Home)" })

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Override Space-Space to include hidden dirs and follow stow symlinks
vim.keymap.set("n", "<leader><space>", function()
  require("telescope.builtin").find_files({
    cwd = LazyVim.root(),
    find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" },
  })
end, { desc = "Find Files (Root Dir)" })

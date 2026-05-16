return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  opts = {
    default_file_explorer = false, -- keep neo-tree for Space-e
    view_options = {
      show_hidden = true, -- show dotfiles
    },
    keymaps = {
      ["q"] = "actions.close",
    },
  },
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
  },
}

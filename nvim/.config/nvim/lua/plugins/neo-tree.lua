return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      follow_current_file = {
        enabled = true,
        leave_dirs_open = true, -- highlight file without shifting the tree root
      },
      bind_to_cwd = false, -- don't change tree root when cwd changes
    },
  },
  keys = {
    -- Always open neo-tree at the project root
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
      end,
      desc = "Explorer (Project Root)",
    },
  },
}

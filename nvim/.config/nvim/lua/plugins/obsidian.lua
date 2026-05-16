return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    workspaces = {
      { name = "personal", path = "~/syncthing/obsidian" },
    },
    ui = { enable = false }, -- avoid conflicts with other markdown rendering
  },
}

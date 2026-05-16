return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
    },
    opts = {
      window = {
        width = 90,
      },
      plugins = {
        twilight = { enabled = false },
        kitty = { enabled = true, font = "+2" },
      },
    },
  },
  {
    "folke/twilight.nvim",
    opts = {},
  },
}

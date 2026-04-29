return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      contrast = "hard",
      palette_overrides = {
        dark0_hard = "#1a1512",  -- matches your kitty/waybar background
        dark0      = "#1a1512",
        dark1      = "#3d3228",  -- selections / sidebars
        dark2      = "#4a3d30",
        dark3      = "#6b5a49",
        dark4      = "#a89880",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}

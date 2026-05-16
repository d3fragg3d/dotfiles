return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
    },
    pickers = {
      find_files = {
        hidden = true,
        find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" },
      },
    },
  },
}

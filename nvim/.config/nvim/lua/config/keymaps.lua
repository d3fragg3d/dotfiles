-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function find_files_or_dirs(cwd, notify_on_type)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local finders = require("telescope.finders")
  local pickers = require("telescope.pickers")
  local conf = require("telescope.config").values
  local make_entry = require("telescope.make_entry")

  pickers.new({}, {
    prompt_title = "Find Files/Dirs",
    finder = finders.new_oneshot_job(
      { "fd", "--type", "f", "--type", "d", "--hidden", "--follow", "--exclude", ".git", ".", cwd },
      { entry_maker = make_entry.gen_from_file({ cwd = cwd }) }
    ),
    sorter = conf.file_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      if notify_on_type then
        local notified = false
        vim.api.nvim_create_autocmd("TextChangedI", {
          buffer = prompt_bufnr,
          callback = function()
            if not notified then
              notified = true
              vim.notify("Scanning ~/...", vim.log.levels.INFO, { title = "Find", timeout = 2000 })
              vim.defer_fn(function() notified = false end, 2000)
            end
          end,
        })
      end
      local function open(bufnr)
        local sel = action_state.get_selected_entry()
        actions.close(bufnr)
        local path = (sel.path or sel.filename):gsub("/$", "")
        vim.schedule(function()
          if vim.fn.isdirectory(path) == 1 then
            vim.cmd("Oil " .. vim.fn.fnameescape(path))
          else
            vim.cmd("edit " .. vim.fn.fnameescape(path))
          end
        end)
      end
      map("i", "<CR>", open)
      map("n", "<CR>", open)
      return true
    end,
  }):find()
end

-- Space-Space: find files and dirs in project root; selecting a dir opens it in oil
vim.keymap.set("n", "<leader><space>", function()
  find_files_or_dirs(LazyVim.root())
end, { desc = "Find Files (Root Dir)" })

-- Space-ff: find files and dirs globally from home; selecting a dir opens it in oil
vim.keymap.set("n", "<leader>ff", function()
  find_files_or_dirs(vim.fn.expand("~"), true)
end, { desc = "Find Files (Home)" })

local vault = vim.fn.expand("~/syncthing/obsidian")

-- Space-fn: new Obsidian note — prompts for filename then title, writes frontmatter boilerplate
vim.keymap.set("n", "<leader>fn", function()
  vim.ui.input({ prompt = "Filename: " }, function(filename)
    if not filename or filename == "" then return end
    filename = filename:gsub("%s+", "-"):lower()
    if not filename:match("%.md$") then filename = filename .. ".md" end
    vim.ui.input({ prompt = "Title: " }, function(title)
      if not title or title == "" then return end
      local path = vault .. "/" .. filename
      vim.cmd("edit " .. vim.fn.fnameescape(path))
      if vim.fn.filereadable(path) == 0 then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
          "---",
          "title: " .. title,
          "date: " .. os.date("%Y-%m-%d"),
          "tags: []",
          "---",
          "",
          "# " .. title,
          "",
        })
      end
    end)
  end)
end, { desc = "New Note" })

-- Space-fs: open today's scratch note, creating it if it doesn't exist
vim.keymap.set("n", "<leader>fs", function()
  local date = os.date("%Y-%m-%d")
  local dir = vault .. "/scratch"
  local path = dir .. "/" .. date .. ".md"
  vim.fn.mkdir(dir, "p")
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  if vim.fn.filereadable(path) == 0 then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "---",
      "date: " .. date,
      "---",
      "",
      "# Scratch " .. date,
      "",
    })
  end
end, { desc = "Scratch Note" })

return {
  "leoluz/nvim-dap-go",
  config = function()
    local dap = require("dap")
    local dlv = vim.fn.stdpath("data") .. "/mason/bin/dlv"

    -- Setup dap-go for test running helpers
    require("dap-go").setup({ delve = { path = dlv } })

    -- Override the go adapter so delve starts in the module root (where go.mod lives),
    -- not the git root. Without this, go build fails when go.mod is in a subdirectory.
    dap.adapters.go = function(callback, _)
      local cwd = vim.fn.expand("%:p:h")

      -- Find a free port
      local tcp = vim.loop.new_tcp()
      tcp:bind("127.0.0.1", 0)
      local port = tcp:getsockname().port
      tcp:close()

      callback({
        type = "server",
        port = port,
        executable = {
          command = dlv,
          args = { "dap", "-l", "127.0.0.1:" .. port },
          cwd = cwd,
          detached = true,
        },
        options = { initialize_timeout_sec = 20 },
      })
    end

    dap.configurations.go = {
      {
        type = "go",
        name = "Debug Package",
        request = "launch",
        program = ".",
      },
      {
        type = "go",
        name = "Debug File",
        request = "launch",
        program = "${file}",
      },
    }
  end,
}

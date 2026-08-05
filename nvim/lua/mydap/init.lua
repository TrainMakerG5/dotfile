local dap = require("dap")
local dapui = require("dapui")

dapui.setup({
  icons = {
    expanded = "▾",
    collapsed = "▸",
    current_frame = "▸",
  },
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40,
      position = "left",
    },
    {
      elements = { "repl" },
      size = 0.25,
      position = "bottom",
    },
  },
  controls = {
    enabled = true,
    element = "repl",
  },
  floating = {
    border = "rounded",
  },
})

dap.listeners.after.event_initialized["dapui"] = function()
  dapui.open()
end

--dap.listeners.before.event_terminated["dapui"] = function()
--  dapui.close()
--end
--
--dap.listeners.before.event_exited["dapui"] = function()
--  dapui.close()
--end

require("mydap.python")
require("mydap.swift")

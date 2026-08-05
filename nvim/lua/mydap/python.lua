local dap = require("dap")
local is_windows = vim.fn.has("win32") == 1

local debugpy_python = vim.fn.stdpath("data")
    .. (is_windows
      and "/mason/packages/debugpy/venv/Scripts/python.exe"
      or "/mason/packages/debugpy/venv/bin/python")

require("dap-python").setup(debugpy_python)
dap.configurations.python = {
  {
    name = "launch file",
    type = "python",
    request = "launch",
    program = "${file}",
    --    console = "integratedTerminal",
  },
}

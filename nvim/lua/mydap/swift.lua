local dap = require("dap")

dap.adapters.lldb = {
  type = "executable",
  command = "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb-dap",
  name = "lldb",
}

-------------------------------------------------------
-- Utility
-------------------------------------------------------

local function run(cmd, cwd)
  local result = vim.system(cmd, {
    cwd = cwd,
    text = true,
  }):wait()

  if result.code ~= 0 then
    error(result.stderr ~= "" and result.stderr or result.stdout)
  end

  return vim.trim(result.stdout)
end

-------------------------------------------------------
-- Swift Package
-------------------------------------------------------

local function find_package_root()
  local file = vim.api.nvim_buf_get_name(0)

  local package = vim.fs.find("Package.swift", {
    path = file,
    upward = true,
  })[1]

  if not package then
    return nil
  end

  return vim.fs.dirname(package)
end

local function executable_name(package_root)
  local json = run({
    "swift",
    "package",
    "dump-package",
  }, package_root)

  local package = vim.json.decode(json)

  for _, target in ipairs(package.targets or {}) do
    if target.type == "executable" then
      return target.name
    end
  end

  error("No executable target found.")
end

local function build_package(package_root)
  vim.notify("󰍉 Building Swift Package...", vim.log.levels.INFO)

  run({
    "swift",
    "build",
  }, package_root)

  local bin = run({
    "swift",
    "build",
    "--show-bin-path",
  }, package_root)

  return bin .. "/" .. executable_name(package_root)
end

-------------------------------------------------------
-- Single File
-------------------------------------------------------

local function build_single_file()
  local source = vim.api.nvim_buf_get_name(0)
  local exe = vim.fn.tempname()

  vim.notify("󰍉 Compiling " .. vim.fn.fnamemodify(source, ":t"))

  run({
    "swiftc",
    "-g",
    source,
    "-o",
    exe,
  })

  return exe
end

local function build()
  local package_root = find_package_root()
  if package_root then
    return build_package(package_root)
  end

  return build_single_file()
end

-------------------------------------------------------
-- DAP
-------------------------------------------------------

dap.configurations.swift = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",

    program = function()
      return build()
    end,

    cwd = function()
      return find_package_root() or vim.fn.getcwd()
    end,

    stopOnEntry = false,
    args = {},
  },
}

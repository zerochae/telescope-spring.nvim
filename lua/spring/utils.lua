local M = {}

local enum = require "spring.enum"
local method_enum = enum.methods
local cmd_enum = enum.cmd
local args_enum = enum.args

M.switch = function(element)
  local Table = {
    ["Value"] = element,
    ["DefaultFunction"] = nil,
    ["Functions"] = {},
  }

  Table.case = function(testElement, callback)
    Table.Functions[testElement] = callback
    return Table
  end

  Table.default = function(callback)
    Table.DefaultFunction = callback
    return Table
  end

  Table.process = function()
    local Case = Table.Functions[Table.Value]
    if Case then
      Case()
    elseif Table.DefaultFunction then
      Table.DefaultFunction()
    end
  end

  return Table
end

local function trim(str)
  return str:gsub("^%s*(.-)%s*$", "%1")
end

local function remove_annotation(str)
  local _, api = str:match '@(.-)%("%s*(/.-)"%)'
  if not api then
    return ""
  end

  return api
end

local get_root_path = function()
  local cmd = cmd_enum.GET_ROOT
  local git_root = vim.fn.system(cmd)

  git_root = git_root:gsub("^%s+", ""):gsub("%s+$", "")
  return git_root
end

M.grep = function(method)
  local root_path = get_root_path()

  local grep_cmd = cmd_enum.GREP .. " " .. args_enum.EXACT
  local full_path = root_path .. args_enum.ALL_JAVA_FILE

  local cmd = grep_cmd .. " " .. method .. " " .. full_path

  local output = vim.fn.system(cmd)

  return output
end

return M

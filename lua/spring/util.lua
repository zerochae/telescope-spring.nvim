local M = {}

local E = require "spring.enum"

local get_root_path = function()
  local cmd = E.cmd.GET_ROOT
  local git_root = vim.fn.system(cmd)

  git_root = git_root:gsub("^%s+", ""):gsub("%s+$", "")
  return git_root
end

M.method_to_annotation = function(method)
  return method .. "_MAPPING"
end

M.grep = function(method)
  local root_path = get_root_path()

  local annotation = E.annotation[M.method_to_annotation(method)]

  local grep_cmd = E.cmd.GREP .. " " .. E.args.EXACT
  local full_path = root_path .. E.args.ALL_JAVA_FILE

  local cmd = grep_cmd .. " " .. annotation .. " " .. full_path

  local output = vim.fn.system(cmd)

  return output
end

M.insert_results = function(grep_results, mapping_table)
  for line in tostring(grep_results):gmatch "[^\n]+" do
    local path, mapping = line:match "([^:]*)[:](.*)"

    table.insert(mapping_table, mapping)
  end
end

return M

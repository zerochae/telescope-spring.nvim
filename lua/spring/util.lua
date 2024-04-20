local M = {}

local E = require "spring.enum"

M.get_annotation = function(method)
  local annotation = E.annotation[method .. "_MAPPING"]

  return annotation or E.annotation.REQUEST_MAPPING
end

M.grep = function(method)
  local annotation = M.get_annotation(method)

  local cmd = vim.tbl_flatten { "rg", annotation, "--type", "java", "--line-number" }

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

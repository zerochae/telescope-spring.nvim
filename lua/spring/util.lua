local M = {}

local E = require "spring.enum"

M.get_annotation = function(method)
  local annotation = E.annotation[method .. "_MAPPING"]

  return annotation or E.annotation.REQUEST_MAPPING
end

local get_grep_cmd = function(annotation)
  if annotation == E.annotation.REQUEST_MAPPING then
    return "rg '@RequestMapping(([^)]*?))' --multiline --type java --line-number"
  elseif annotation == E.annotation.GET_MAPPING then
    return "rg '@GetMapping' --multiline --type java --line-number"
  elseif annotation == E.annotation.POST_MAPPING then
    return "rg '@PostMapping' --multiline --type java --line-number"
  elseif annotation == E.annotation.PUT_MAPPING then
    return "rg '@PutMapping' --multiline --type java --line-number"
  elseif annotation == E.annotation.DELETE_MAPPING then
    return "rg '@DeleteMapping' --multiline --type java --line-number"
  else
    error "not supported annotation"
  end
end

local run_cmd = function(cmd)
  local output = vim.fn.system(cmd)
  return output
end

M.grep = function(method)
  local annotation = M.get_annotation(method)
  local cmd = get_grep_cmd(annotation)
  local output = run_cmd(cmd)

  return output
end

M.insert_results = function(grep_results, mapping_table)
  for line in tostring(grep_results):gmatch "[^\n]+" do
    local path, mapping = line:match "([^:]*)[:](.*)"

    table.insert(mapping_table, mapping)
  end
end

return M

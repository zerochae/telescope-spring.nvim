local M = {}

local E = require "spring.enum"
local H = require "spring.helper"

local PATTERNS = {
  REQUEST_MAPPING_VALUE = '@(.-)%("%s*(/.-)"%)',
  VARIABLE_VALUE = "%((.-)%)",
  VARIABLE_ASSIGNMENT = '"(%/.-)"',
  REQUEST_MAPPING_METHODS = "method%s*=%s*(%b{})",
  REQUEST_MAPPING_METHOD = "method%s*=%s*([%w%.]+)",
  MAPPING_VALUE = 'value%s*=%s*"([^"]+)"',
  REQUEST_METHOD = "RequestMethod%.(%w+)",
}

local function get_mapping_value(mapping, path)
  if not mapping then
    return ""
  end

  local _, value = mapping:match(PATTERNS.REQUEST_MAPPING_VALUE)
  if value then
    return value
  end

  local variable_value = mapping:match(PATTERNS.VARIABLE_VALUE)
  if variable_value then
    local cmd = "rg" .. " " .. variable_value .. " " .. "=" .. " " .. path
    local grep_results = H.run_cmd(cmd)
    variable_value = grep_results:match(PATTERNS.VARIABLE_ASSIGNMENT)
    return variable_value or ""
  end

  return ""
end

M.split_request_mapping = function(mapping_string)
  local path, line_number, column = H.split(mapping_string, ":")
  local mapping_methods = mapping_string:match(PATTERNS.REQUEST_MAPPING_METHODS)
  local mapping_method = mapping_string:match(PATTERNS.REQUEST_MAPPING_METHOD)
  local mapping_value = mapping_string:match(PATTERNS.MAPPING_VALUE) or ""
  local mapping_method_list = {}

  if mapping_methods then
    for method in mapping_methods:gmatch(PATTERNS.REQUEST_METHOD) do
      table.insert(mapping_method_list, method:gsub("RequestMethod%.", ""):upper())
    end
  elseif mapping_method then
    table.insert(mapping_method_list, mapping_method:gsub("RequestMethod%.", ""):upper())
  else
    mapping_method_list = nil
  end

  return path, line_number, column, mapping_value, mapping_method_list
end

M.split_object_mapping = function(mapping_string)
  local path, line_number, column = H.split(mapping_string, ":")
  local mapping_value = mapping_string:match(PATTERNS.MAPPING_VALUE) or ""
  return path, line_number, column, mapping_value
end

M.get_mapping_value = get_mapping_value

M.is_mapping_has_option = function(mapping)
  return H.find(mapping, "method =") ~= nil or H.find(mapping, "value =") ~= nil
end

M.is_request_mapping = function(mapping)
  return H.find(mapping, E.annotation.REQUEST_MAPPING) ~= nil
end

M.get_grep_cmd = function(annotation)
  local commands = {
    [E.annotation.REQUEST_MAPPING] = "rg '@RequestMapping(([^)]*?))' --multiline --type java --line-number --trim --vimgrep",
    [E.annotation.GET_MAPPING] = "rg '@GetMapping' --multiline --type java --line-number --trim --vimgrep",
    [E.annotation.POST_MAPPING] = "rg '@PostMapping' --multiline --type java --line-number --trim --vimgrep",
    [E.annotation.PUT_MAPPING] = "rg '@PutMapping' --multiline --type java --line-number --trim --vimgrep",
    [E.annotation.DELETE_MAPPING] = "rg '@DeleteMapping' --multiline --type java --line-number --trim --vimgrep",
  }
  
  local cmd = commands[annotation]
  if not cmd then
    error("not supported annotation: " .. annotation)
  end
  
  return cmd
end

return M
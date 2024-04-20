local M = {}

local E = require "spring.enum"
local H = require "spring.helper"

local spring_table = {}

local created_spring_table = {
  [E.annotation.REQUEST_MAPPING] = false,
  [E.annotation.GET_MAPPING] = false,
  [E.annotation.POST_MAPPING] = false,
  [E.annotation.PUT_MAPPING] = false,
  [E.annotation.DELETE_MAPPING] = false,
}

M.get_annotation = function(method)
  local annotation = E.annotation[method .. "_MAPPING"]
  return annotation
end

local get_method = function(annotation)
  local method = string.upper((annotation):gsub("^@", ""):gsub("Mapping$", ""))
  return method
end

local get_mapping_value = function(mapping)
  if not mapping then
    return ""
  end

  local _, value = mapping:match '@(.-)%("%s*(/.-)"%)'

  if not value then
    return ""
  end

  return value
end

local get_grep_cmd = function(annotation)
  if annotation == E.annotation.REQUEST_MAPPING then
    return "rg '@RequestMapping(([^)]*?))' --multiline --type java --line-number --trim --vimgrep"
  elseif annotation == E.annotation.GET_MAPPING then
    return "rg '@GetMapping' --multiline --type java --line-number --trim --vimgrep"
  elseif annotation == E.annotation.POST_MAPPING then
    return "rg '@PostMapping' --multiline --type java --line-number --trim --vimgrep"
  elseif annotation == E.annotation.PUT_MAPPING then
    return "rg '@PutMapping' --multiline --type java --line-number --trim --vimgrep"
  elseif annotation == E.annotation.DELETE_MAPPING then
    return "rg '@DeleteMapping' --multiline --type java --line-number --trim --vimgrep"
  else
    local message = "not supported annotation: " .. annotation
    error(message)
  end
end

local is_created_spring_table = function(annotation)
  return created_spring_table[annotation]
end

local get_request_mapping_value = function(path)
  if not spring_table[path] then
    return ""
  end

  if not spring_table[path][E.annotation.REQUEST_MAPPING] then
    return ""
  end

  return spring_table[path][E.annotation.REQUEST_MAPPING].value
end

M.get_spring_table = function()
  return spring_table
end

M.create_request_mapping_table = function()
  M.create_spring_table(E.annotation.REQUEST_MAPPING)
end

-- TODO: get All mappings
-- M.get_all_finder_results = function()
--   local finder_results = {}
--
--   for path, mapping_object in pairs(spring_table) do
--     local request_mapping_value = get_request_mapping_value(path)
--     if mapping_object[annotation] then
--       local method = get_method(annotation)
--       local method_mapping_value = mapping_object[annotation].value
--       local endpoint = method .. " " .. request_mapping_value .. method_mapping_value
--       table.insert(finder_results, endpoint)
--     end
--   end
--
--   return finder_results
-- end

M.get_finder_results = function(annotation)
  local finder_results = {}

  for path, mapping_object in pairs(spring_table) do
    local request_mapping_value = get_request_mapping_value(path)
    if mapping_object[annotation] then
      local method = get_method(annotation)
      local method_mapping_value = mapping_object[annotation].value
      local endpoint = method .. " " .. request_mapping_value .. method_mapping_value
      table.insert(finder_results, endpoint)
    end
  end

  return finder_results
end

M.create_spring_table = function(annotation)
  if is_created_spring_table(annotation) then
    return
  end

  created_spring_table[annotation] = true

  local cmd = get_grep_cmd(annotation)
  local grep_results = H.run_cmd(cmd)

  for line in tostring(grep_results):gmatch "[^\n]+" do
    local path, line_number, column, value = H.split(line, ":")

    if not spring_table[path] then
      spring_table[path] = {}
    end

    if not spring_table[path][annotation] then
      spring_table[path][annotation] = {}
    end

    spring_table[path][annotation] = {
      value = get_mapping_value(value),
      line_number = line_number,
      column = column,
    }
  end
end

return M

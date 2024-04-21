local M = {}

local E = require "spring.enum"
local H = require "spring.helper"

local spring_find_table = {}
local spring_preview_table = {}

local created_spring_find_table = {
  [E.annotation.REQUEST_MAPPING] = false,
  [E.annotation.GET_MAPPING] = false,
  [E.annotation.POST_MAPPING] = false,
  [E.annotation.PUT_MAPPING] = false,
  [E.annotation.DELETE_MAPPING] = false,
}

local created_spring_preview_table = {
  [E.annotation.GET_MAPPING] = false,
  [E.annotation.POST_MAPPING] = false,
  [E.annotation.PUT_MAPPING] = false,
  [E.annotation.DELETE_MAPPING] = false,
}

M.get_annotation = function(method)
  local annotation = E.annotation[method .. "_MAPPING"]
  return annotation
end

M.get_method = function(annotation)
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

local is_created_find_table = function(annotation)
  return created_spring_find_table[annotation]
end

local is_created_preview_table = function(annotation)
  return created_spring_preview_table[annotation]
end

M.get_request_mapping_value = function(path)
  if not spring_find_table[path] then
    return ""
  end

  if not spring_find_table[path][E.annotation.REQUEST_MAPPING] then
    return ""
  end

  return spring_find_table[path][E.annotation.REQUEST_MAPPING].value
end

M.get_spring_priview_table = function()
  return spring_preview_table
end

M.get_spring_find_table = function()
  return spring_find_table
end

M.create_spring_preview_table = function(annotation)
  if is_created_preview_table(annotation) then
    return
  end

  created_spring_preview_table[annotation] = true

  for path, mapping_object in pairs(spring_find_table) do
    local request_mapping_value = M.get_request_mapping_value(path)
    if mapping_object[annotation] then
      local method = M.get_method(annotation)
      for _, mapping_item in ipairs(mapping_object[annotation]) do
        local method_mapping_value = mapping_item.value
        local line_number = mapping_item.line_number
        local column = mapping_item.column
        local endpoint = method .. " " .. request_mapping_value .. method_mapping_value
        spring_preview_table[endpoint] = {
          path = path,
          line_number = line_number,
          column = column,
        }
      end
    end
  end
end

M.create_spring_find_table = function(annotation)
  if is_created_find_table(annotation) then
    return
  end

  created_spring_find_table[annotation] = true

  local cmd = get_grep_cmd(annotation)
  local grep_results = H.run_cmd(cmd)

  for line in tostring(grep_results):gmatch "[^\n]+" do
    local path, line_number, column, value = H.split(line, ":")

    if not spring_find_table[path] then
      spring_find_table[path] = {}
    end

    if not spring_find_table[path][annotation] then
      spring_find_table[path][annotation] = {}
    end

    if annotation == E.annotation.REQUEST_MAPPING then
      spring_find_table[path][annotation] =
        { value = get_mapping_value(value), line_number = line_number, column = column }
    else
      table.insert(
        spring_find_table[path][annotation],
        { value = get_mapping_value(value), line_number = line_number, column = column }
      )
    end
  end
end

M.set_cursor_on_entry = function(entry, bufnr, winid)
  local lnum, lnend = entry.lnum - 1, (entry.lnend or entry.lnum) - 1
  local middle_ln = math.floor(lnum + (lnend - lnum) / 2) + 1
  pcall(vim.api.nvim_win_set_cursor, winid, { middle_ln, 0 })
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd "norm! zz"
  end)
end

return M

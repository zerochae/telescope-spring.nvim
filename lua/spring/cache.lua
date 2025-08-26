local M = {}

local spring_find_table = {}
local spring_preview_table = {}
local cache_timestamp = {}
local config = require "spring.config"
local cache_ttl = config.cache_ttl or 5000 -- Default 5 seconds

M.clear_tables = function()
  spring_find_table = {}
  spring_preview_table = {}
  cache_timestamp = {}
end

M.get_find_table = function()
  return spring_find_table
end

M.get_preview_table = function()
  return spring_preview_table
end

M.is_cache_valid = function(annotation)
  local current_time = vim.fn.localtime() * 1000
  local cached_time = cache_timestamp[annotation]
  
  if not cached_time then
    return false
  end
  
  return (current_time - cached_time) < cache_ttl
end

M.update_cache_timestamp = function(annotation)
  cache_timestamp[annotation] = vim.fn.localtime() * 1000
end

M.has_cached_data = function(annotation)
  -- Check if we have any data for this annotation
  for _, mapping_object in pairs(spring_find_table) do
    if mapping_object[annotation] then
      return true
    end
  end
  return false
end

M.should_use_cache = function(annotation)
  return M.is_cache_valid(annotation) and M.has_cached_data(annotation)
end

M.create_find_table_entry = function(path, annotation)
  if not spring_find_table[path] then
    spring_find_table[path] = {}
  end

  if not spring_find_table[path][annotation] then
    spring_find_table[path][annotation] = {}
  end
end

M.insert_to_find_table = function(opts)
  table.insert(
    spring_find_table[opts.path][opts.annotation],
    { value = opts.value, line_number = opts.line_number, column = opts.column }
  )
end

M.insert_to_find_request_table = function(opts)
  spring_find_table[opts.path][opts.annotation] =
    { value = opts.value, line_number = opts.line_number, column = opts.column }
end

M.create_preview_entry = function(endpoint, path, line_number, column)
  spring_preview_table[endpoint] = {
    path = path,
    line_number = line_number,
    column = column,
  }
end

return M
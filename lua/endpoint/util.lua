local M = {}

local enums = require "endpoint.enum"
local cache = require "endpoint.cache"
local framework = require "endpoint.framework"

M.run_cmd = function(cmd)
  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    -- Don't show error for common cases like "no matches found" (exit code 1)
    if exit_code == 1 then
      return "" -- Empty result for no matches
    end
    -- Exit code 2 usually means invalid regex or command syntax
    if exit_code == 2 then
      vim.notify("Invalid search pattern or command syntax in: " .. cmd, vim.log.levels.ERROR)
      return nil
    end
    vim.notify("Command failed: " .. cmd .. " (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
    return nil
  end

  return output
end

M.get_annotation = function(method)
  local annotation = enums.annotation[method .. "_MAPPING"]
  return annotation
end

M.get_method = function(annotation)
  local method = string.upper((annotation):gsub("^@", ""):gsub("Mapping$", ""))
  return method
end

M.get_request_mapping_value = function(path)
  local find_table = cache.get_find_table()
  if not find_table[path] then
    return ""
  end

  if not find_table[path][enums.annotation.REQUEST_MAPPING] then
    return ""
  end

  if not find_table[path][enums.annotation.REQUEST_MAPPING].value then
    return ""
  end

  return find_table[path][enums.annotation.REQUEST_MAPPING].value
end

M.get_request_mapping_line_number = function(path)
  local find_table = cache.get_find_table()
  if not find_table[path] then
    return nil
  end

  if not find_table[path][enums.annotation.REQUEST_MAPPING] then
    return nil
  end

  if not find_table[path][enums.annotation.REQUEST_MAPPING].line_number then
    return nil
  end

  return find_table[path][enums.annotation.REQUEST_MAPPING].line_number
end

-- Framework-agnostic table management functions
M.clear_tables = function()
  cache.clear_tables()
end

M.get_preview_table = function()
  return cache.get_preview_table()
end

M.get_find_table = function()
  return cache.get_find_table()
end

M.get_spring_preview_table = function()
  return cache.get_preview_table()
end

M.get_spring_find_table = function()
  return cache.get_find_table()
end

M.create_spring_preview_table = function(annotation)
  local find_table = cache.get_find_table()
  for path, mapping_object in pairs(find_table) do
    local request_mapping_value = M.get_request_mapping_value(path)
    if mapping_object[annotation] then
      local method = M.get_method(annotation)
      for _, mapping_item in ipairs(mapping_object[annotation]) do
        local method_mapping_value = mapping_item.value or ""
        local line_number = mapping_item.line_number
        local column = mapping_item.column
        local endpoint = method .. " " .. request_mapping_value .. method_mapping_value
        cache.create_preview_entry(endpoint, path, line_number, column)
      end
    end
  end
end

-- Create preview table using current framework (new framework-agnostic version)
M.create_endpoint_preview_table = function(method)
  local state = require "endpoint.state"
  local config = state.get_config()

  -- Detect current framework
  local framework_name = framework.get_current_framework_name(config)

  -- For Spring, create preview table from find table (same as other frameworks)
  if framework_name == "spring" then
    -- For Spring, ensure find table exists first by creating endpoint table
    M.create_endpoint_table(method)
  end

  -- For other frameworks, create preview table from find table
  local find_table = cache.get_find_table()
  for path, mapping_object in pairs(find_table) do
    local request_mapping_value = M.get_request_mapping_value(path)

    -- Check for method-specific endpoints
    local method_key = method .. "_ENDPOINT"
    if mapping_object[method_key] then
      for _, mapping_item in ipairs(mapping_object[method_key]) do
        local method_mapping_value = mapping_item.value or ""
        local line_number = mapping_item.line_number
        local column = mapping_item.column
        local endpoint = method .. " " .. request_mapping_value .. method_mapping_value
        cache.create_preview_entry(endpoint, path, line_number, column)
      end
    end
  end
end

-- Create endpoint table using current framework (new framework-agnostic version)
M.create_endpoint_table = function(method)
  local state = require "endpoint.state"
  local config = state.get_config()

  -- Detect current framework
  local framework_name = framework.get_current_framework_name(config)

  if config and config.debug then
    print("DEBUG: Using " .. framework_name .. " framework to scan for " .. method .. " endpoints")
  end

  -- For Spring, use new framework system but scan all methods due to shared @RequestMapping
  if framework_name == "spring" then
    -- For Spring, we need to scan all methods since @RequestMapping is shared across classes
    local methods = { "GET", "POST", "PUT", "DELETE", "PATCH" }
    for _, http_method in ipairs(methods) do
      local success, cmd = pcall(framework.get_grep_cmd, http_method, config)
      if success then
        local grep_results = helper.run_cmd(cmd)
        if grep_results and grep_results ~= "" then
          for line in tostring(grep_results):gmatch "[^\n]+" do
            local parsed = framework.parse_line(line, http_method, config)
            if parsed then
              cache.create_find_table_entry(parsed.file_path, http_method .. "_ENDPOINT")
              cache.insert_to_find_table {
                path = parsed.file_path,
                annotation = http_method .. "_ENDPOINT",
                value = parsed.endpoint_path,
                line_number = parsed.line_number,
                column = parsed.column,
              }
            end
          end
        end
      end
    end
    return
  end

  -- For other frameworks, use new framework system
  local success, cmd = pcall(framework.get_grep_cmd, method, config)
  if not success then
    vim.notify("Error: " .. cmd, vim.log.levels.ERROR)
    return
  end

  local grep_results = helper.run_cmd(cmd)
  if not grep_results or grep_results == "" then
    if config and config.debug then
      print("DEBUG: No results for " .. method)
    end
    return
  end

  if config and config.debug then
    print("DEBUG: Found results for " .. method .. " - " .. string.len(grep_results) .. " chars")
  end

  -- Parse results using current framework
  for line in tostring(grep_results):gmatch "[^\n]+" do
    local parsed = framework.parse_line(line, method, config)
    if parsed then
      -- Store in cache using the parsed information
      cache.create_find_table_entry(parsed.file_path, method .. "_ENDPOINT")
      cache.insert_to_find_table {
        path = parsed.file_path,
        annotation = method .. "_ENDPOINT",
        value = parsed.endpoint_path,
        line_number = parsed.line_number,
        column = parsed.column,
      }
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

M.check_duplicate = function(find_table)
  local seen = {}
  local result = {}

  for _, value in ipairs(find_table) do
    if not seen[value] then
      table.insert(result, value)
      seen[value] = true
    end
  end

  return result
end

M.check_duplicate_entries = function(entries)
  local seen = {}
  local result = {}

  for _, entry in ipairs(entries) do
    local key = entry.value
    if not seen[key] then
      table.insert(result, entry)
      seen[key] = true
    end
  end

  return result
end

return M

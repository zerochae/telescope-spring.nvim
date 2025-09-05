local M = {}

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

M.get_method = function(annotation)
  local method = string.upper((annotation):gsub("^@", ""):gsub("Mapping$", ""))
  return method
end



M.clear_tables = function()
  cache.clear_tables()
end

M.get_preview_table = function()
  return cache.get_preview_table()
end

M.get_find_table = function()
  return cache.get_find_table()
end

M.create_endpoint_preview_table = function(method)
  M.create_endpoint_table(method)
  local find_table = cache.get_find_table()
  for path, mapping_object in pairs(find_table) do
    local method_key = method .. "_ENDPOINT"
    if mapping_object[method_key] then
      for _, mapping_item in ipairs(mapping_object[method_key]) do
        local endpoint_path = mapping_item.value or ""
        local line_number = mapping_item.line_number
        local column = mapping_item.column
        local endpoint = method .. " " .. endpoint_path
        cache.create_preview_entry(endpoint, path, line_number, column)
      end
    end
  end
end

-- Create endpoint table using current framework (new framework-agnostic version)
M.create_endpoint_table = function(method)
  local state = require "endpoint.state"
  local config = state.get_config()
  local framework_name = framework.get_current_framework_name(config)
  local cache_key = framework_name .. "_" .. method

  if cache.should_use_cache(cache_key) then
    return
  end

  local fw, _, _ = framework.get_current_framework(config)
  if not fw then
    return
  end

  local cmd = fw.get_grep_cmd(method, config)
  local grep_results = M.run_cmd(cmd)

  if grep_results and grep_results ~= "" then
    for line in vim.gsplit(grep_results, "\n") do
      if line ~= "" then
        local parsed = fw.parse_line(line, method, config)
        if parsed then
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
  end
  cache.update_cache_timestamp(cache_key)
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

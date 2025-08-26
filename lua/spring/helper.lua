local M = {}

M.get_table_length = function(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

M.trim = function(str)
  return str:gsub("^%s*(.-)%s*$", "%1")
end

M.find = function(str, substr)
  return string.find(str, substr)
end

M.split = function(str, delimiter)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find(str, delimiter, from)
  while delim_from do
    table.insert(result, string.sub(str, from, delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = string.find(str, delimiter, from)
  end
  table.insert(result, string.sub(str, from))

  return unpack(result)
end

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

return M

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

M.remove_annotation = function(str)
  local _, api = str:match '@(.-)%("%s*(/.-)"%)'
  if not api then
    return ""
  end

  return api
end

return M

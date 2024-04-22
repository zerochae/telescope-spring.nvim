local finders = require "telescope.finders"
local U = require "spring.util"
local E = require "spring.enum"

local create_find_table = function(annotation)
  U.create_spring_find_table(E.annotation.REQUEST_MAPPING)
  U.create_spring_find_table(annotation)
end

return function(annotation)
  return finders.new_table {
    results = (function()
      create_find_table(annotation)
      local spring_finder_table = U.get_spring_find_table()
      local finder_results = {}

      for path, mapping_object in pairs(spring_finder_table) do
        local request_mapping_value = U.get_request_mapping_value(path)
        -- local request_mapping_line_number = U.get_request_mapping_line_number(path)
        if mapping_object[annotation] then
          local method = U.get_method(annotation)
          for _, mapping_item in ipairs(mapping_object[annotation]) do
            local method_mapping_value = mapping_item.value or ""
            local endpoint = method .. " " .. request_mapping_value .. method_mapping_value
            table.insert(finder_results, endpoint)
          end
        end
      end

      return U.check_duplicate(finder_results)
    end)(),
  }
end

local finders = require "telescope.finders"
local U = require "spring.util"
local E = require "spring.enum"
local entry_display = require "telescope.pickers.entry_display"

local create_find_table = function(annotation)
  U.create_spring_find_table(E.annotation.REQUEST_MAPPING)
  U.create_spring_find_table(annotation)
end

local get_method_color = function(method)
  local spring = require "spring"
  local config = spring.get_config()
  local colors = config.ui.method_colors
  return colors[method] or "TelescopeResultsIdentifier"
end

local get_method_icon = function(method)
  local spring = require "spring"
  local config = spring.get_config()
  if not config.ui.show_icons then
    return ""
  end
  local icons = config.ui.method_icons
  return icons[method] or "⚪"
end

local get_method_text = function(method)
  local spring = require "spring"
  local config = spring.get_config()
  if not config.ui.show_method then
    return ""
  end
  return method
end

return function(annotation)
  return finders.new_table {
    entry_maker = function(entry)
      local method = entry.method
      local path = entry.path
      local icon = get_method_icon(method)
      local method_text = get_method_text(method)
      local method_color = get_method_color(method)
      
      -- Build display string based on settings
      local parts = {}
      if icon ~= "" then
        table.insert(parts, icon)
      end
      if method_text ~= "" then
        table.insert(parts, method_text)
      end
      table.insert(parts, path)
      
      local display_string = table.concat(parts, " ")
      
      return {
        value = entry.value,
        display = display_string,
        ordinal = entry.value,
        method = method,
        path = path,
      }
    end,
    results = (function()
      create_find_table(annotation)
      local spring_finder_table = U.get_spring_find_table()
      local finder_results = {}

      for path, mapping_object in pairs(spring_finder_table) do
        local request_mapping_value = U.get_request_mapping_value(path)
        if mapping_object[annotation] then
          local method = U.get_method(annotation)
          for _, mapping_item in ipairs(mapping_object[annotation]) do
            local method_mapping_value = mapping_item.value or ""
            local endpoint = method .. " " .. request_mapping_value .. method_mapping_value
            table.insert(finder_results, {
              value = endpoint,
              method = method,
              path = request_mapping_value .. method_mapping_value,
            })
          end
        end
      end

      return U.check_duplicate_entries(finder_results)
    end)(),
  }
end

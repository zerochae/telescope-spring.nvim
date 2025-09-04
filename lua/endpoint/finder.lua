local finders = require "telescope.finders"
local util = require "endpoint.util"
local enums = require "endpoint.enum"
local entry_display = require "telescope.pickers.entry_display"

local create_find_table = function(method)
  local state = require "endpoint.state"
  local config = state.get_config()

  if config and config.cache_mode == "persistent" then
    -- In persistent mode, scan all HTTP methods to avoid data loss
    util.create_endpoint_table("GET")
    util.create_endpoint_table("POST")
    util.create_endpoint_table("PUT")
    util.create_endpoint_table("DELETE")
    util.create_endpoint_table("PATCH")
  else
    -- In time/session mode, scan only needed method
    util.create_endpoint_table(method)
  end
end

local get_method_color = function(method)
  local endpoint = require "endpoint"
  local config = endpoint.get_config()
  local colors = config.ui.method_colors
  return colors[method] or "TelescopeResultsIdentifier"
end

local get_method_icon = function(method)
  local endpoint = require "endpoint"
  local config = endpoint.get_config()
  if not config.ui.show_icons then
    return ""
  end
  local icons = config.ui.method_icons
  return icons[method] or "⚪"
end

local get_method_text = function(method)
  local endpoint = require "endpoint"
  local config = endpoint.get_config()
  if not config.ui.show_method then
    return ""
  end
  return method
end

return function(method) -- method is HTTP method like 'GET', 'POST', etc.
  return finders.new_table {
    entry_maker = function(entry)
      local method = entry.method
      local path = entry.path
      local icon = get_method_icon(method)
      local method_text = get_method_text(method)
      local method_color = get_method_color(method)

      -- Create display configuration
      local displayer
      local display_parts = {}

      if icon ~= "" then
        table.insert(display_parts, { width = 2 })
      end
      if method_text ~= "" then
        table.insert(display_parts, { width = string.len(method_text) })
      end
      table.insert(display_parts, { remaining = true })

      displayer = entry_display.create {
        separator = " ",
        items = display_parts,
      }

      return {
        value = entry.value,
        display = function()
          local display_items = {}

          if icon ~= "" then
            table.insert(display_items, icon)
          end
          if method_text ~= "" then
            table.insert(display_items, { method_text, method_color })
          end
          table.insert(display_items, path)

          return displayer(display_items)
        end,
        ordinal = entry.value,
        method = method,
        path = path,
      }
    end,
    results = (function()
      -- Create endpoint tables using current framework
      create_find_table(method)
      
      -- Get results from cache
      local finder_table = util.get_find_table()
      local finder_results = {}

      -- TODO: Replace this Spring-specific logic with framework-agnostic version
      -- For now, try to work with existing cache structure
      for path, mapping_object in pairs(finder_table) do
        local request_mapping_value = util.get_request_mapping_value(path)
        local method_key = method .. "_ENDPOINT"
        
        -- Check for method-specific endpoints
        if mapping_object[method_key] then
          for _, mapping_item in ipairs(mapping_object[method_key]) do
            local method_mapping_value = mapping_item.value or ""
            local endpoint = method .. " " .. request_mapping_value .. method_mapping_value
            table.insert(finder_results, {
              value = endpoint,
              method = method,
              path = request_mapping_value .. method_mapping_value,
            })
          end
        end
        
        -- Also check Spring annotations for backward compatibility
        local annotation = "@" .. method:sub(1,1):upper() .. method:sub(2):lower() .. "Mapping"
        if mapping_object[annotation] then
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

      return util.check_duplicate_entries(finder_results)
    end)(),
  }
end

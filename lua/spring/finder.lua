local finders = require "telescope.finders"
local U = require "spring.util"
local H = require "spring.helper"
local E = require "spring.enum"

local spring_table = {
  [E.annotation.REQUEST_MAPPING] = {},
  [E.annotation.GET_MAPPING] = {},
  [E.annotation.POST_MAPPING] = {},
  [E.annotation.PUT_MAPPING] = {},
  [E.annotation.DELETE_MAPPING] = {},
}

local find_results_by_method = function(method)
  local grep_results = U.grep(method)
  local annotation = U.get_annotation(method)
  local mapping_table = spring_table[annotation]

  if H.get_table_length(mapping_table) == 0 then
    U.insert_results(grep_results, mapping_table)
  end

  return mapping_table
end

local spring_finder = function(method)
  return finders.new_table {
    results = find_results_by_method(method),
  }
end

return spring_finder

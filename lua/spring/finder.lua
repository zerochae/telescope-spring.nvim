local finders = require "telescope.finders"
local U = require "spring.util"
local E = require "spring.enum"

local create_all_restuls_table = function()
  U.create_request_mapping_table()
  U.create_spring_table(E.methods.GET)
  U.create_spring_table(E.methods.POST)
  U.create_spring_table(E.methods.PUT)
  U.create_spring_table(E.methods.DELETE)
end

local create_finder_results_table = function(annotation)
  U.create_request_mapping_table()
  U.create_spring_table(annotation)
end

local spring_finder = function(method)
  local finder_results = {}

  if method == E.methods.ALL then
    error "All is not support"
    -- create_all_restuls_table()
    -- finder_results = U.get_all_finder_results()
  else
    local annotation = U.get_annotation(method)
    create_finder_results_table(annotation)
    finder_results = U.get_finder_results(annotation)
  end

  return finders.new_table {
    results = finder_results,
  }
end

return spring_finder

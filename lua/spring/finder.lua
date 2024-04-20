local finders = require "telescope.finders"
local U = require "spring.util"

local spring_finder = function(annotation)
  local finder_results = U.get_finder_results(annotation)

  return finders.new_table {
    results = finder_results,
  }
end

return spring_finder

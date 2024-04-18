local finders = require "telescope.finders"

local spring_finder = finders.new_table {
  results = {
    "api/v1/foo/bar",
    "api/v1/foo/bar/{id}",
    "api/v1/foo/bar/{id}/test",
  },
}

return spring_finder

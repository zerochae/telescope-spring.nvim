local finders = require "telescope.finders"
local switch = require("spring.utils").switch
local methods = require("spring.enum").methods

local find_by_method = function(method)
  local results = {}

  switch(method)
    .case(methods.GET, function()
      results = {
        "api/get/v1/foo/bar",
        "api/v1/foo/bar/{id}",
        "api/v1/foo/bar/{id}/test",
      }
    end)
    .case(methods.POST, function()
      results = {
        "api/post/v1/foo/bar",
        "api/v1/foo/bar/{id}",
        "api/v1/foo/bar/{id}/test",
      }
    end)
    .case(methods.PUT, function()
      results = {
        "api/put/v1/foo/bar",
        "api/v1/foo/bar/{id}",
        "api/v1/foo/bar/{id}/test",
      }
    end)
    .case(methods.DELETE, function()
      results = {
        "api/delete/v1/foo/bar",
        "api/v1/foo/bar/{id}",
        "api/v1/foo/bar/{id}/test",
      }
    end)
    .process()

  return results
end

local spring_finder = function(method)
  local results = find_by_method(method)

  return finders.new_table {
    results = results,
  }
end

return spring_finder

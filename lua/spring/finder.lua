local finders = require "telescope.finders"
local utils = require "spring.utils"
local methods = require("spring.enum").methods
local switch = require "switch"

local spring_finder = function(method)
  local results = nil
  switch(method) {
    [methods.GET] = function()
      results = {
        "api/get/v1/foo/bar",
        "api/v1/foo/bar/{id}",
        "api/v1/foo/bar/{id}/test",
      }
    end,
    [methods.POST] = function()
      results = {
        "api/post/v1/foo/bar",
        "api/v1/foo/bar/{id}",
        "api/v1/foo/bar/{id}/test",
      }
    end,
    [methods.PUT] = function()
      results = {
        "api/put/v1/foo/bar",
        "api/v1/foo/bar/{id}",
        "api/v1/foo/bar/{id}/test",
      }
    end,
    [methods.DELETE] = function()
      results = {
        "api/delete/v1/foo/bar",
        "api/v1/foo/bar/{id}",
        "api/v1/foo/bar/{id}/test",
      }
    end,
  }

  finders.new_table {
    results,
  }
end

return spring_finder

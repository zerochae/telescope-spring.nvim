local finders = require "telescope.finders"
local utils = require "spring.utils"
local switch = utils.switch
local grep = utils.grep
local methods = require("spring.enum").methods

local find_get_mapping = function()
  local get_results = grep(methods.GET)

  print(vim.inspect(get_results))

  return {
    "api/get/v1/foo/bar",
    "api/v1/foo/bar/{id}",
    "api/v1/foo/bar/{id}/test",
  }
end

local find_post_mapping = function()
  return {
    "api/post/v1/foo/bar",
    "api/v1/foo/bar/{id}",
    "api/v1/foo/bar/{id}/test",
  }
end

local find_put_mapping = function()
  return {
    "api/post/v1/foo/bar",
    "api/v1/foo/bar/{id}",
    "api/v1/foo/bar/{id}/test",
  }
end

local find_delete_mapping = function()
  return {
    "api/delete/v1/foo/bar",
    "api/v1/foo/bar/{id}",
    "api/v1/foo/bar/{id}/test",
  }
end

local find_results_by_method = function(method)
  local results = {}

  switch(method)
    .case(methods.GET, function()
      results = find_get_mapping()
    end)
    .case(methods.POST, function()
      results = find_post_mapping()
    end)
    .case(methods.PUT, function()
      results = find_put_mapping()
    end)
    .case(methods.DELETE, function()
      results = find_delete_mapping()
    end)
    .process()

  return results
end

local spring_finder = function(method)
  return finders.new_table {
    results = find_results_by_method(method),
  }
end

return spring_finder

-- test/spring_spec.lua
local plenary = require "plenary.busted"
local endpoint = require "endpoint"
local util = require "endpoint.util"
local cache = require "endpoint.cache"

plenary.describe("Spring Framework Endpoint Detection", function()
  -- Configure the endpoint plugin for Spring before each test
  plenary.before_each(function()
    endpoint.setup {
      debug = false, -- Set to true for verbose logging during tests
      frameworks = {
        spring = {
          enabled = true,
        },
        nestjs = {
          enabled = false,
        },
      },
    }
    -- Clear cache and state before each test run
    cache.clear_tables()
  end)

  plenary.it("should create the find_table for GET endpoints", function()
    -- Action: Create the endpoint table for GET requests
    util.create_endpoint_table "GET"

    -- Assertion: Check if the find_table is populated
    local find_table = util.get_find_table()
    assert.is_not_nil(find_table, "find_table should not be nil")
    assert.is_true(
      next(find_table) ~= nil,
      "find_table should not be empty after scanning for GET endpoints"
    )

    -- Optional: A more specific assertion
    local found_user_controller = false
    for path, _ in pairs(find_table) do
      if path:match "UserController.java" then
        found_user_controller = true
        break
      end
    end
    assert.is_true(found_user_controller, "Should have found endpoints in UserController.java")
  end)

  plenary.it("should create the preview_table for GET endpoints", function()
    -- Action: Create the preview table for GET requests
    util.create_endpoint_preview_table "GET"

    -- Assertion: Check if the preview_table is populated
    local preview_table = util.get_preview_table()
    assert.is_not_nil(preview_table, "preview_table should not be nil")
    assert.is_true(
      next(preview_table) ~= nil,
      "preview_table should not be empty after creating the preview"
    )

    -- Optional: A more specific assertion
    local found_get_users_endpoint = false
    for endpoint_string, _ in pairs(preview_table) do
      if endpoint_string:match "GET /api/users" then
        found_get_users_endpoint = true
        break
      end
    end
    assert.is_true(found_get_users_endpoint, "The endpoint 'GET /api/users' should exist in the preview_table")
  end)
end)

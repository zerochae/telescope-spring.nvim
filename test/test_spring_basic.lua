-- Basic Spring framework test without telescope dependencies
local util = require('endpoint.util')
local cache = require('endpoint.cache')
local state = require('endpoint.state')
local config = require('endpoint.config')

-- Change to Spring test directory after requiring modules
vim.cmd("cd test/spring")

-- Setup basic config
state.set_config(vim.tbl_deep_extend("force", config, {
  debug = true,
  framework = 'spring'
}))

print("=== Testing Spring Framework (Basic) ===")
print("Working directory:", vim.fn.getcwd())

-- Clear any existing tables
util.clear_tables()

-- Test GET endpoint creation directly
print("\n=== Testing GET endpoints ===")
util.create_endpoint_table("GET")

local find_table = util.get_find_table()
print("Find table has", vim.tbl_count(find_table), "files")

-- Show sample data
local count = 0
for path, mappings in pairs(find_table) do
  print("\nFile:", path)
  for annotation, data in pairs(mappings) do
    if type(data) == "table" and #data > 0 then
      print("  " .. annotation .. " (" .. #data .. " entries):")
      for i, item in ipairs(data) do
        print("    " .. i .. ":", item.value or "no value", "at line", item.line_number or "unknown")
        if i >= 2 then break end -- Limit output
      end
    else
      print("  " .. annotation .. ":", type(data))
    end
  end
  count = count + 1
  if count >= 5 then break end
end

-- Test preview table creation
print("\n=== Testing GET preview table ===")
util.create_endpoint_preview_table("GET")

local preview_table = util.get_preview_table()
print("Preview table has", vim.tbl_count(preview_table), "endpoints")

-- Show sample preview data
count = 0
for endpoint, data in pairs(preview_table) do
  print("Endpoint:", endpoint)
  print("  File:", data.path)
  print("  Line:", data.line_number)
  count = count + 1
  if count >= 5 then break end
end

print("\n=== Test completed ===")
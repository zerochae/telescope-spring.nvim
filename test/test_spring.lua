-- Test script for Spring framework functionality
local endpoint = require('endpoint')
local util = require('endpoint.util')

-- Setup with debug mode
endpoint.setup({
  debug = true,
  framework = 'spring'
})

print("=== Testing Spring Framework ===")

-- Clear any existing tables
util.clear_tables()

-- Test GET endpoint creation
print("\n=== Testing GET endpoints ===")
util.create_endpoint_table("GET")

local find_table = util.get_find_table()
print("Find table keys:", vim.inspect(vim.tbl_keys(find_table)))

-- Show some sample data
local count = 0
for path, mappings in pairs(find_table) do
  print("File:", path)
  for annotation, data in pairs(mappings) do
    print("  " .. annotation .. ":", vim.inspect(data))
  end
  count = count + 1
  if count >= 3 then break end
end

-- Test preview table creation
print("\n=== Testing GET preview table ===")
util.create_endpoint_preview_table("GET")

local preview_table = util.get_preview_table()
print("Preview table keys:", vim.inspect(vim.tbl_keys(preview_table)))

-- Show some sample preview data
count = 0
for endpoint, data in pairs(preview_table) do
  print("Endpoint:", endpoint)
  print("  Data:", vim.inspect(data))
  count = count + 1
  if count >= 3 then break end
end

print("\n=== Test completed ===")
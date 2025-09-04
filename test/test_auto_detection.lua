-- Test framework auto-detection
local detector = require('endpoint.detector')
local state = require('endpoint.state')
local config = require('endpoint.config')

print("=== Testing Framework Auto-Detection ===")

-- Setup config
local test_config = vim.tbl_deep_extend("force", config, {
  debug = true,
  framework = 'auto'
})

-- Test Spring detection
print("\n--- Testing Spring Detection ---")
vim.cmd("cd test/spring")
print("Working directory:", vim.fn.getcwd())

local detected_framework = detector.detect_framework(test_config)
print("Detected framework:", detected_framework)

-- Test NestJS detection  
print("\n--- Testing NestJS Detection ---")
vim.cmd("cd ../nestjs")
print("Working directory:", vim.fn.getcwd())

detected_framework = detector.detect_framework(test_config)
print("Detected framework:", detected_framework)

-- Test root directory (should default to auto)
print("\n--- Testing Root Directory (No Framework Files) ---")
vim.cmd("cd ../..")
print("Working directory:", vim.fn.getcwd())

detected_framework = detector.detect_framework(test_config)
print("Detected framework:", detected_framework)

print("\n=== Auto-Detection Test Completed ===")
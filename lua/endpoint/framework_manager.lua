-- Framework adapter manager
-- Handles loading and using framework-specific adapters

local detector = require "endpoint.detector"

local M = {}

-- Cache for loaded adapters
local adapter_cache = {}

-- Load a framework adapter
local function load_adapter(framework_name)
  if adapter_cache[framework_name] then
    return adapter_cache[framework_name]
  end

  local ok, adapter = pcall(require, "endpoint.frameworks." .. framework_name)
  if not ok then
    vim.notify("Failed to load framework adapter: " .. framework_name .. " - " .. adapter, vim.log.levels.ERROR)
    return nil
  end

  adapter_cache[framework_name] = adapter
  return adapter
end

-- Get the current framework adapter based on detection
function M.get_current_adapter(config)
  local framework_name, framework_config = detector.get_current_framework_config(config)

  local adapter = load_adapter(framework_name)
  if not adapter then
    -- Fallback to spring adapter
    vim.notify("Failed to load " .. framework_name .. " adapter, falling back to spring", vim.log.levels.WARN)
    adapter = load_adapter "spring"
  end

  return adapter, framework_name, framework_config
end

-- Get grep command using current framework adapter
function M.get_grep_cmd(method, config)
  local adapter, framework_name, framework_config = M.get_current_adapter(config)
  if not adapter then
    error "No framework adapter available"
  end

  if config.debug then
    vim.notify("Using " .. framework_name .. " adapter for method: " .. method, vim.log.levels.INFO)
  end

  return adapter.get_grep_cmd(method, framework_config)
end

-- Parse line using current framework adapter
function M.parse_line(line, method, config)
  local adapter, framework_name, framework_config = M.get_current_adapter(config)
  if not adapter then
    return nil
  end

  return adapter.parse_line(line, method)
end

-- Check if current framework can handle a line
function M.can_handle_line(line, config)
  local adapter = M.get_current_adapter(config)
  if not adapter then
    return false
  end

  return adapter.can_handle(line)
end

-- Get file patterns for current framework
function M.get_file_patterns(config)
  local adapter, framework_name, framework_config = M.get_current_adapter(config)
  if not adapter then
    return { "**/*" } -- Fallback
  end

  -- First try to get from framework_config, then from adapter
  if framework_config and framework_config.file_patterns then
    return framework_config.file_patterns
  end

  return adapter.get_file_patterns()
end

-- Get exclude patterns for current framework
function M.get_exclude_patterns(config)
  local adapter, framework_name, framework_config = M.get_current_adapter(config)
  if not adapter then
    return {} -- Fallback
  end

  -- First try to get from framework_config, then from adapter
  if framework_config and framework_config.exclude_patterns then
    return framework_config.exclude_patterns
  end

  return adapter.get_exclude_patterns()
end

-- Get base path using current framework adapter
function M.get_base_path(file_path, line_number, config)
  local adapter = M.get_current_adapter(config)
  if not adapter then
    return ""
  end

  return adapter.get_base_path(file_path, line_number)
end

-- Get method patterns for current framework
function M.get_patterns(config)
  local adapter, framework_name, framework_config = M.get_current_adapter(config)
  if not adapter then
    return {}
  end

  -- First try to get from framework_config, then from adapter
  if framework_config and framework_config.patterns then
    return framework_config.patterns
  end

  return adapter.get_patterns()
end

-- Get current framework name
function M.get_current_framework_name(config)
  local framework_name = detector.detect_framework(config)
  return framework_name
end

-- Validate that a framework adapter implements required interface
function M.validate_adapter(adapter, framework_name)
  local required_methods = {
    "get_grep_cmd",
    "parse_line",
    "get_patterns",
    "can_handle",
    "get_file_patterns",
    "get_exclude_patterns",
    "get_base_path",
  }

  for _, method_name in ipairs(required_methods) do
    if not adapter[method_name] or type(adapter[method_name]) ~= "function" then
      vim.notify(
        "Framework adapter " .. framework_name .. " missing required method: " .. method_name,
        vim.log.levels.ERROR
      )
      return false
    end
  end

  return true
end

-- List all available framework adapters
function M.list_available_frameworks()
  local frameworks = {}

  -- Check for framework files in the frameworks directory
  local framework_files = vim.fn.glob(vim.fn.stdpath "config" .. "/lua/endpoint/frameworks/*.lua", false, true)

  for _, file_path in ipairs(framework_files) do
    local filename = vim.fn.fnamemodify(file_path, ":t:r")
    if filename ~= "base" then -- Skip the base interface file
      table.insert(frameworks, filename)
    end
  end

  return frameworks
end

return M


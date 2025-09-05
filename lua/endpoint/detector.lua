local M = {}

-- Get the current working directory (project root)
local function get_project_root()
  return vim.fn.getcwd()
end

-- Check if a file exists
local function file_exists(filepath)
  local stat = vim.loop.fs_stat(filepath)
  return stat ~= nil and stat.type == "file"
end

-- Check if any detection files exist in the project root
local function check_detection_files(root_path, detection_files)
  for _, file in ipairs(detection_files) do
    local full_path = root_path .. "/" .. file
    if file_exists(full_path) then
      return true
    end
  end
  return false
end

-- Special check for Node.js projects (NestJS vs Express)
local function detect_nodejs_framework(root_path)
  local package_json_path = root_path .. "/package.json"
  if not file_exists(package_json_path) then
    return nil
  end

  -- Read package.json and check dependencies
  local ok, package_content = pcall(vim.fn.readfile, package_json_path)
  if not ok then
    return nil
  end

  local content_str = table.concat(package_content, "\n")

  -- Check for NestJS dependencies
  if content_str:match "@nestjs/" then
    return "nestjs"
  end

  -- Check for Express dependencies
  if content_str:match '"express"' then
    return "express"
  end

  return nil
end

-- Auto-detect framework based on project files
local function auto_detect_framework(root_path, frameworks_config)
  -- Check each framework's detection files
  for framework_name, framework_config in pairs(frameworks_config) do
    if framework_name == "nestjs" or framework_name == "express" then
      -- Special handling for Node.js frameworks
      local detected = detect_nodejs_framework(root_path)
      if detected == framework_name then
        return framework_name
      end
    else
      -- Standard detection for other frameworks
      if check_detection_files(root_path, framework_config.detection_files) then
        return framework_name
      end
    end
  end

  -- If no framework detected, default to spring for backward compatibility
  return "spring"
end

-- Check if current path matches any framework_paths patterns
local function check_framework_paths(current_path, framework_paths)
  for path_pattern, framework in pairs(framework_paths) do
    -- Simple wildcard matching (* at the end)
    if path_pattern:sub(-1) == "*" then
      local pattern_prefix = path_pattern:sub(1, -2)
      if current_path:sub(1, #pattern_prefix) == pattern_prefix then
        return framework
      end
    else
      -- Exact path matching
      if current_path == path_pattern then
        return framework
      end
    end
  end
  return nil
end

-- Main function to detect the current framework
function M.detect_framework(config)
  local root_path = get_project_root()

  -- First check framework_paths for explicit overrides
  if config.framework_paths and next(config.framework_paths) then
    local override_framework = check_framework_paths(root_path, config.framework_paths)
    if override_framework then
      if config.debug then
        vim.notify(
          "Framework override detected: " .. override_framework .. " for path: " .. root_path,
          vim.log.levels.INFO
        )
      end
      return override_framework
    end
  end

  -- If framework is explicitly set (not "auto"), use it
  if config.framework and config.framework ~= "auto" then
    if config.debug then
      vim.notify("Using explicitly configured framework: " .. config.framework, vim.log.levels.INFO)
    end
    return config.framework
  end

  -- Auto-detect framework
  local detected_framework = auto_detect_framework(root_path, config.frameworks)

  if config.debug then
    vim.notify("Auto-detected framework: " .. detected_framework .. " for project: " .. root_path, vim.log.levels.INFO)
  end

  return detected_framework
end

-- Get framework-specific configuration
function M.get_framework_config(config, framework_name)
  local framework_config = config.frameworks[framework_name]
  if not framework_config then
    -- Fallback to spring config for unknown frameworks
    if config.debug then
      vim.notify("Unknown framework: " .. framework_name .. ", falling back to spring", vim.log.levels.WARN)
    end
    framework_config = config.frameworks.spring
  end

  return framework_config
end

-- Get current framework and its configuration
function M.get_current_framework_config(config)
  local framework_name = M.detect_framework(config)
  local framework_config = M.get_framework_config(config, framework_name)

  return framework_name, framework_config
end

return M

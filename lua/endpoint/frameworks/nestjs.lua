-- NestJS framework implementation
local base = require "endpoint.frameworks.base"
local helper = require "endpoint.helper"

local M = {}

-- HTTP method to decorator mapping
local METHOD_TO_DECORATOR = {
  GET = "@Get",
  POST = "@Post",
  PUT = "@Put",
  DELETE = "@Delete",
  PATCH = "@Patch",
}

-- Method patterns for NestJS
local PATTERNS = {
  get = { "@Get%(" },
  post = { "@Post%(" },
  put = { "@Put%(" },
  delete = { "@Delete%(" },
  patch = { "@Patch%(" },
}

-- Get grep command for NestJS endpoints
function M.get_grep_cmd(method, config)
  local decorator = METHOD_TO_DECORATOR[method:upper()]
  if not decorator then
    error("Unsupported HTTP method: " .. method)
  end

  local exclude_patterns = M.get_exclude_patterns()

  local cmd = "rg"
  cmd = cmd .. " --line-number --column --no-heading --color=never"
  cmd = cmd .. " --case-sensitive"
  cmd = cmd .. " --type typescript" -- Use built-in TypeScript type for better performance

  -- Add exclude patterns
  for _, pattern in ipairs(exclude_patterns) do
    cmd = cmd .. " --glob '!" .. pattern .. "'"
  end

  -- Add additional ripgrep args if configured
  if config.rg_additional_args and config.rg_additional_args ~= "" then
    cmd = cmd .. " " .. config.rg_additional_args
  end

  -- Search for the decorator with parentheses - simplified pattern for speed
  cmd = cmd .. " '" .. decorator .. "'"

  return cmd
end

-- Parse NestJS decorator line
function M.parse_line(line, method, config)
  -- NestJS line format: "filepath:line:column:content"
  local parts = {}
  local count = 0
  for part in line:gmatch "([^:]+)" do
    count = count + 1
    parts[count] = part
    if count >= 4 then -- Only need first 4 parts
      break
    end
  end

  if count < 4 then
    return nil
  end

  local file_path = parts[1]
  local line_number = tonumber(parts[2])
  local column = tonumber(parts[3])

  -- Extract everything after the third colon as content
  local content_start = line:find(":", line:find(":", line:find ":" + 1) + 1) + 1
  local content = line:sub(content_start)

  if not line_number or not column then
    return nil
  end

  -- Parse the method path from the decorator
  local method_path = ""

  -- Look for path inside parentheses: @Get('/api/users') or @Get('api/users') or @Get(':id')
  local path_pattern = content:match "@%w+%s*%(%s*['\"]([^'\"]*)['\"]" or ""

  if path_pattern then
    method_path = path_pattern
  end

  -- Get the controller base path
  local controller_path = M.get_base_path(file_path, line_number)
  
  -- Combine controller path and method path
  local endpoint_path = M.combine_paths(controller_path, method_path)

  if config and config.debug then
    print("DEBUG NestJS: Controller='" .. controller_path .. "', Method='" .. method_path .. "', Combined='" .. endpoint_path .. "'")
  end

  return {
    file_path = file_path,
    line_number = line_number,
    column = column,
    endpoint_path = endpoint_path,
    method = method:upper(),
    raw_line = line,
    content = content,
  }
end

-- Get method patterns
function M.get_patterns()
  return PATTERNS
end

-- Check if this adapter can handle the line
function M.can_handle(line)
  -- Check if line contains NestJS decorators
  for _, patterns in pairs(PATTERNS) do
    for _, pattern in ipairs(patterns) do
      if line:match(pattern) then
        return true
      end
    end
  end
  return false
end

-- Get file patterns for NestJS
function M.get_file_patterns()
  return { "**/*.ts" }
end

-- Get exclude patterns for NestJS
function M.get_exclude_patterns()
  return { "**/node_modules/**", "**/dist/**", "**/build/**" }
end

-- Combine controller path and method path into full endpoint path
function M.combine_paths(controller_path, method_path)
  -- Handle empty cases
  if not controller_path or controller_path == "" then
    controller_path = ""
  end
  if not method_path or method_path == "" then
    method_path = ""
  end

  -- Ensure controller path starts with / if not empty
  if controller_path ~= "" and not controller_path:match "^/" then
    controller_path = "/" .. controller_path
  end

  -- Ensure method path starts with / if not empty
  if method_path ~= "" and not method_path:match "^/" then
    method_path = "/" .. method_path
  end

  -- Combine paths
  local combined = controller_path .. method_path

  -- Clean up double slashes and ensure it starts with /
  combined = combined:gsub("//+", "/")
  if combined == "" then
    combined = "/"
  elseif not combined:match "^/" then
    combined = "/" .. combined
  end

  return combined
end

-- Extract base path from @Controller decorator
function M.get_base_path(file_path, line_number)
  -- Read the file and look for @Controller on class declaration
  local ok, lines = pcall(vim.fn.readfile, file_path)
  if not ok or not lines then
    return ""
  end

  -- Look backwards from the method line to find class-level @Controller
  local controller_path = ""
  local in_class = false

  for i = line_number, 1, -1 do
    local line = lines[i] or ""

    -- Check if we hit a class declaration
    if line:match "class%s+%w+" or line:match "export%s+class%s+%w+" then
      in_class = true
    elseif in_class and line:match "@Controller" then
      -- Extract path from @Controller
      local path = line:match "@Controller%s*%(%s*['\"]([^'\"]*)['\"]" or ""
      controller_path = path
      break
    elseif line:match "^import " then
      -- Stop if we hit imports (went too far)
      break
    end
  end

  -- Ensure controller path starts with /
  if controller_path ~= "" and not controller_path:match "^/" then
    controller_path = "/" .. controller_path
  end

  return controller_path
end

-- Additional NestJS-specific utility functions
function M.is_controller_line(line)
  return line:match "@Controller" ~= nil
end

function M.extract_route_params(endpoint_path)
  -- Extract route parameters like :id, :userId etc.
  local params = {}
  for param in endpoint_path:gmatch ":(%w+)" do
    table.insert(params, param)
  end
  return params
end

function M.parse_controller_decorator(line)
  local parsed = M.parse_line(line, "CONTROLLER")
  if not parsed then
    return nil
  end

  -- Extract controller path
  local controller_path = parsed.content:match "@Controller%s*%(%s*['\"]([^'\"]*)['\"]" or ""

  return {
    file_path = parsed.file_path,
    line_number = parsed.line_number,
    column = parsed.column,
    controller_path = controller_path,
    content = parsed.content,
  }
end

-- Check if a line contains a NestJS HTTP method decorator
function M.is_http_method_decorator(line)
  local decorators = { "@Get", "@Post", "@Put", "@Delete", "@Patch" }
  for _, decorator in ipairs(decorators) do
    if line:match(decorator .. "%s*%(") then
      return true
    end
  end
  return false
end

return M

-- Spring Boot framework adapter
local base = require "endpoint.frameworks.base"
local helper = require "endpoint.helper"

local M = {}

-- HTTP method to annotation mapping
local METHOD_TO_ANNOTATION = {
  GET = "@GetMapping",
  POST = "@PostMapping",
  PUT = "@PutMapping",
  DELETE = "@DeleteMapping",
  PATCH = "@PatchMapping",
}

-- Method patterns for Spring Boot
local PATTERNS = {
  get = { "@GetMapping", "@RequestMapping.*method.*=.*GET" },
  post = { "@PostMapping", "@RequestMapping.*method.*=.*POST" },
  put = { "@PutMapping", "@RequestMapping.*method.*=.*PUT" },
  delete = { "@DeleteMapping", "@RequestMapping.*method.*=.*DELETE" },
  patch = { "@PatchMapping", "@RequestMapping.*method.*=.*PATCH" },
}

-- Get grep command for Spring Boot endpoints
function M.get_grep_cmd(method, config)
  local annotation = METHOD_TO_ANNOTATION[method:upper()]
  if not annotation then
    error("Unsupported HTTP method: " .. method)
  end

  local file_patterns = M.get_file_patterns()
  local exclude_patterns = M.get_exclude_patterns()

  local cmd = "rg"
  cmd = cmd .. " --type-add 'custom:" .. table.concat(file_patterns, ",") .. "'"
  cmd = cmd .. " --type custom"
  cmd = cmd .. " --line-number --column --no-heading --color=never"
  cmd = cmd .. " --case-sensitive"

  -- Add exclude patterns
  for _, pattern in ipairs(exclude_patterns) do
    cmd = cmd .. " --glob '!" .. pattern .. "'"
  end

  -- Add additional ripgrep args if configured
  if config.rg_additional_args and config.rg_additional_args ~= "" then
    cmd = cmd .. " " .. config.rg_additional_args
  end

  -- Search for the annotation
  cmd = cmd .. " '" .. annotation .. "'"

  return cmd
end

-- Parse Spring Boot annotation line
function M.parse_line(line, method)
  -- Spring Boot line format: "filepath:line:column:content"
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

  -- Parse the endpoint path from the annotation
  local endpoint_path = ""

  -- Look for value inside parentheses: @GetMapping("/api/users") or @GetMapping(value = "/api/users")
  local value_pattern = content:match '%("([^"]*)"%)'
    or content:match 'value%s*=%s*"([^"]*)"'
    or content:match "value%s*=%s*'([^']*)'"

  if value_pattern then
    endpoint_path = value_pattern
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
  -- Check if line contains Spring Boot annotations
  for _, patterns in pairs(PATTERNS) do
    for _, pattern in ipairs(patterns) do
      if line:match(pattern) then
        return true
      end
    end
  end
  return false
end

-- Get file patterns for Spring Boot
function M.get_file_patterns()
  return { "**/*.java" }
end

-- Get exclude patterns for Spring Boot
function M.get_exclude_patterns()
  return { "**/target/**", "**/build/**" }
end

-- Extract base path from @RequestMapping at class level
function M.get_base_path(file_path, line_number)
  -- Read the file and look for @RequestMapping on class declaration
  local ok, lines = pcall(vim.fn.readfile, file_path)
  if not ok or not lines then
    return ""
  end

  -- Look backwards from the method line to find class-level @RequestMapping
  local class_mapping = ""
  local in_class = false

  for i = line_number, 1, -1 do
    local line = lines[i] or ""

    -- Check if we hit a class declaration
    if line:match "class%s+%w+" then
      in_class = true
    elseif in_class and line:match "@RequestMapping" then
      -- Extract value from @RequestMapping
      local value = line:match '@RequestMapping%("([^"]*)"%)'
        or line:match '@RequestMapping%s*%(.-value%s*=%s*"([^"]*)"'
        or ""
      class_mapping = value
      break
    elseif line:match "^package " then
      -- Stop if we hit package declaration (went too far)
      break
    end
  end

  return class_mapping
end

-- Additional Spring-specific utility functions
function M.is_request_mapping_line(line)
  return line:match "@RequestMapping" ~= nil
end

function M.extract_request_mapping_methods(content)
  -- Extract methods from @RequestMapping(method = {RequestMethod.GET, RequestMethod.POST})
  local methods = {}
  local method_pattern = "RequestMethod%.(%w+)"

  for method in content:gmatch(method_pattern) do
    table.insert(methods, method)
  end

  return methods
end

function M.parse_request_mapping(line)
  local parsed = M.parse_line(line, "REQUEST")
  if not parsed then
    return nil
  end

  -- Extract methods if specified
  local methods = M.extract_request_mapping_methods(parsed.content)

  return {
    file_path = parsed.file_path,
    line_number = parsed.line_number,
    column = parsed.column,
    endpoint_path = parsed.endpoint_path,
    methods = methods,
    content = parsed.content,
  }
end

return M


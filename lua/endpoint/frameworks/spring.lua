-- Spring Boot framework implementation
local base = require "endpoint.frameworks.base"

-- Method patterns for Spring Boot
local PATTERNS = {
  GET = { "@GetMapping", "@RequestMapping.*method.*=.*GET" },
  POST = { "@PostMapping", "@RequestMapping.*method.*=.*POST" },
  PUT = { "@PutMapping", "@RequestMapping.*method.*=.*PUT" },
  DELETE = { "@DeleteMapping", "@RequestMapping.*method.*=.*DELETE" },
  PATCH = { "@PatchMapping", "@RequestMapping.*method.*=.*PATCH" },
}

-- Create a new Spring framework object inheriting from base
local M = base.new {}

function M:get_patterns(method)
  return PATTERNS[method:upper()] or {}
end

function M:get_file_types()
  return { "java" }
end

function M:get_exclude_patterns()
  return { "**/target/**", "**/build/**" }
end

-- Extracts the endpoint path from the annotation content
function M:extract_endpoint_path(content, method)
  -- Look for value inside parentheses: @GetMapping("/api/users") or @GetMapping(value = "/api/users")
  local endpoint_path = content:match '%("%s*([^"]*)%s*"%)' -- e.g. ("/api/users")
    or content:match 'value%s*=%s*"([^"]*)"' -- e.g. value = "/api/users"
    or content:match 'path%s*=%s*"([^"]*)"' -- e.g. path = "/api/users"
    or ""

  return endpoint_path
end

-- Extracts base path from @RequestMapping at the class level
function M:get_base_path(file_path, line_number)
  -- This logic is specific to Spring and remains here
  local ok, lines = pcall(vim.fn.readfile, file_path)
  if not ok or not lines then
    return ""
  end

  local class_mapping = ""
  -- Look backwards from the method line to find a class-level @RequestMapping
  for i = line_number, 1, -1 do
    local line = lines[i] or ""

    if line:match "@RequestMapping" and not line:match "method%s*=" then
      local value = line:match '@RequestMapping%("%s*([^"]*)%s*"%)'
        or line:match '@RequestMapping%s*%(.-value%s*=%s*"([^"]*)"'
        or ""
      class_mapping = value
      break -- Found the class-level mapping
    end
    -- Stop if we hit the package declaration or another class definition, means we went too far
    if line:match "^package " or (line:match "class%s+%w+" and i < line_number) then
      break
    end
  end

  return class_mapping
end

-- Override the default grep command builder to be simpler for Spring,
-- as each annotation is unique per method.
function M:get_grep_cmd(method, config)
  local patterns = self:get_patterns(method)
  if not patterns or #patterns == 0 then
    error("No patterns defined for method: " .. method)
  end

  local file_types = self:get_file_types()
  local exclude_patterns = self:get_exclude_patterns()

  local cmd = "rg"
  cmd = cmd .. " --line-number --column --no-heading --color=never"
  cmd = cmd .. " --case-sensitive"

  for _, file_type in ipairs(file_types) do
    cmd = cmd .. " --type " .. file_type
  end

  for _, pattern in ipairs(exclude_patterns) do
    cmd = cmd .. " --glob '!" .. pattern .. "'"
  end

  if config and config.rg_additional_args and config.rg_additional_args ~= "" then
    cmd = cmd .. " " .. config.rg_additional_args
  end

  -- Spring annotations are distinct enough that we can search for the first pattern.
  cmd = cmd .. " '" .. patterns[1] .. "'"

  return cmd
end

return M
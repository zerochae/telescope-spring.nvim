-- NestJS framework implementation
local base = require "endpoint.frameworks.base"

-- Method patterns for NestJS
local PATTERNS = {
  GET = { "@Get%(" },
  POST = { "@Post%(" },
  PUT = { "@Put%(" },
  DELETE = { "@Delete%(" },
  PATCH = { "@Patch%(" },
}

-- Create a new NestJS framework object inheriting from base
local M = base.new {}

function M:get_patterns(method)
  return PATTERNS[method:upper()] or {}
end

function M:get_file_types()
  return { "typescript" }
end

function M:get_exclude_patterns()
  return { "**/node_modules/**", "**/dist/**", "**/build/**" }
end

-- Extracts the endpoint path from the decorator content
function M:extract_endpoint_path(content, method)
  -- Look for path inside parentheses: @Get('/api/users'), @Get('api/users'), or @Get()
  local path = content:match "@%w+%s*%(%s*['"]([^'"]*)['"]"
  if path == nil then
    path = "" -- Handle cases like @Get()
  end
  return path
end

-- Extracts base path from @Controller decorator at the class level
function M:get_base_path(file_path, line_number)
  local ok, lines = pcall(vim.fn.readfile, file_path)
  if not ok or not lines then
    return ""
  end

  local controller_path = ""
  -- Look backwards from the method line to find a class-level @Controller
  for i = line_number, 1, -1 do
    local line = lines[i] or ""

    if line:match "@Controller" then
      local path = line:match "@Controller%s*%(%s*['"]([^'"]*)['"]" or ""
      controller_path = path
      break -- Found it
    end
    -- Stop if we hit an import or another class, we've gone too far
    if line:match "^import " or (line:match "class%s+%w+" and i < line_number) then
      break
    end
  end

  return controller_path
end

-- Override the default grep command builder to be simpler for NestJS
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

  -- NestJS decorators are distinct enough that we can search for the first pattern.
  cmd = cmd .. " '" .. patterns[1] .. "'"

  return cmd
end

return M
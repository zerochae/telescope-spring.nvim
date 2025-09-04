-- Base framework interface
-- All framework implementations should implement these methods

local M = {}

-- Framework interface that all framework implementations should implement
M.FrameworkInterface = {
  -- Get grep command for finding endpoints of a specific method
  -- @param method: HTTP method (GET, POST, PUT, DELETE, PATCH)
  -- @param config: framework-specific config
  -- @return string: ripgrep command
  get_grep_cmd = function(method, config)
    error "get_grep_cmd must be implemented by framework"
  end,

  -- Parse a grep result line to extract endpoint information
  -- @param line: single line from ripgrep output
  -- @param method: HTTP method being searched for
  -- @return table: { path, line_number, column, endpoint_path, method }
  parse_line = function(line, method)
    error "parse_line must be implemented by framework"
  end,

  -- Get method-specific patterns for this framework
  -- @return table: { get = {...}, post = {...}, ... }
  get_patterns = function()
    error "get_patterns must be implemented by framework"
  end,

  -- Check if this framework can handle the given line
  -- @param line: single line from ripgrep output
  -- @return boolean: true if this framework can parse this line
  can_handle = function(line)
    error "can_handle must be implemented by framework"
  end,

  -- Get file extension patterns for this framework
  -- @return table: list of file patterns like { "**/*.java" }
  get_file_patterns = function()
    error "get_file_patterns must be implemented by framework"
  end,

  -- Get exclude patterns for this framework
  -- @return table: list of exclude patterns
  get_exclude_patterns = function()
    error "get_exclude_patterns must be implemented by framework"
  end,

  -- Extract controller/class-level base path if exists
  -- @param file_path: path to the source file
  -- @param line_number: line number of the endpoint
  -- @return string: base path or empty string
  get_base_path = function(file_path, line_number)
    return "" -- Default implementation returns empty string
  end,
}

return M

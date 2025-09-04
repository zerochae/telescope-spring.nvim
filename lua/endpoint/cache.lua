local M = {}

local spring_find_table = {}
local spring_preview_table = {}
local cache_timestamp = {}
local scanned_annotations = {} -- Track which annotations were directly scanned

-- Persistent cache configuration
local function get_project_root()
  local result = vim.fn.system "git rev-parse --show-toplevel 2>/dev/null"
  if vim.v.shell_error ~= 0 then
    return vim.fn.getcwd() -- fallback to current directory
  end
  return result:gsub("\n", "")
end

local function get_project_cache_dir()
  local project_root = get_project_root()
  local project_name = vim.fn.fnamemodify(project_root, ":t")
  return vim.fn.stdpath "data" .. "/telescope-spring/" .. project_name
end

local function get_cache_files()
  local cache_dir = get_project_cache_dir()
  return {
    cache_dir = cache_dir,
    find_cache_file = cache_dir .. "/find_cache.lua",
    metadata_file = cache_dir .. "/metadata.lua",
  }
end
local get_cache_config = function()
  local state = require "endpoint.state"
  local config = state.get_config()

  if not config then
    -- Fallback to default config if state is not initialized
    local default_config = require "endpoint.config"
    return {
      ttl = default_config.cache_ttl or 5000,
      mode = default_config.cache_mode or "time",
    }
  end

  return {
    ttl = config.cache_ttl or 5000, -- Default 5 seconds
    mode = config.cache_mode or "time", -- Default time-based cache
  }
end

M.clear_tables = function()
  spring_find_table = {}
  spring_preview_table = {}
  cache_timestamp = {}
  scanned_annotations = {}
end

M.get_find_table = function()
  return spring_find_table
end

M.get_preview_table = function()
  return spring_preview_table
end

-- Helper functions for persistent cache
local function ensure_cache_dir()
  local cache_dir = get_project_cache_dir()
  vim.fn.mkdir(cache_dir, "p")
end

local function file_exists(path)
  return vim.fn.filereadable(path) == 1
end

M.is_cache_valid = function(annotation)
  local cache_config = get_cache_config()
  local cached_time = cache_timestamp[annotation]

  if cache_config.mode == "persistent" then
    -- For persistent mode, always valid if data exists in memory or file
    return cached_time ~= nil or M.has_cached_data(annotation)
  elseif cache_config.mode == "session" then
    -- Cache is valid for the entire nvim session if it exists
    return cached_time ~= nil
  else
    -- Time-based cache validation
    if not cached_time then
      return false
    end
    local current_time = vim.fn.localtime() * 1000
    return (current_time - cached_time) < cache_config.ttl
  end
end

M.update_cache_timestamp = function(annotation)
  local cache_config = get_cache_config()

  if cache_config.mode == "persistent" then
    -- For persistent mode, mark as cached but don't auto-save (save manually when needed)
    cache_timestamp[annotation] = true
    -- Mark this annotation as directly scanned
    scanned_annotations[annotation] = os.time()
  elseif cache_config.mode == "session" then
    -- For session mode, just mark as cached (boolean)
    cache_timestamp[annotation] = true
  else
    -- For time mode, store actual timestamp
    cache_timestamp[annotation] = vim.fn.localtime() * 1000
  end
end

M.has_cached_data = function(annotation)
  -- Check if we have any data for this annotation
  for _, mapping_object in pairs(spring_find_table) do
    if mapping_object[annotation] then
      return true
    end
  end
  return false
end

M.should_use_cache = function(annotation)
  local cache_config = get_cache_config()

  -- In persistent mode, check if we have specific annotation data
  if cache_config.mode == "persistent" then
    return M.is_cache_valid(annotation) and M.has_cached_data_for_annotation(annotation)
  end

  -- In other modes, use existing logic
  return M.is_cache_valid(annotation) and M.has_cached_data(annotation)
end

M.has_cached_data_for_annotation = function(annotation)
  -- In persistent mode, check if this annotation was directly scanned
  local cache_config = get_cache_config()
  if cache_config.mode == "persistent" then
    local was_scanned = scanned_annotations[annotation] ~= nil
    
    -- Debug logging
    local state = require "endpoint.state"
    local config = state.get_config()
    if config and config.debug then
      print("DEBUG: has_cached_data_for_annotation(" .. annotation .. ") - was_scanned = " .. tostring(was_scanned))
    end
    
    return was_scanned
  end

  -- In other modes, check if we have data for this annotation
  local has_data = false
  for _, mapping_object in pairs(spring_find_table) do
    if mapping_object[annotation] then
      has_data = true
      break
    end
  end

  -- Debug logging
  local state = require "endpoint.state"
  local config = state.get_config()
  if config and config.debug then
    print("DEBUG: has_cached_data_for_annotation(" .. annotation .. ") = " .. tostring(has_data))
  end

  return has_data
end

M.create_find_table_entry = function(path, annotation)
  if not spring_find_table[path] then
    spring_find_table[path] = {}
  end

  if not spring_find_table[path][annotation] then
    spring_find_table[path][annotation] = {}
  end
end

M.insert_to_find_table = function(opts)
  table.insert(
    spring_find_table[opts.path][opts.annotation],
    { value = opts.value, line_number = opts.line_number, column = opts.column }
  )
end

M.insert_to_find_request_table = function(opts)
  spring_find_table[opts.path][opts.annotation] =
    { value = opts.value, line_number = opts.line_number, column = opts.column }
end

M.create_preview_entry = function(endpoint, path, line_number, column)
  spring_preview_table[endpoint] = {
    path = path,
    line_number = line_number,
    column = column,
  }
end

-- Persistent cache functions
M.save_to_file = function()
  local cache_config = get_cache_config()
  if cache_config.mode ~= "persistent" then
    return
  end

  ensure_cache_dir()
  local cache_files = get_cache_files()

  -- Save find table
  local find_file = io.open(cache_files.find_cache_file, "w")
  if find_file then
    find_file:write("return " .. vim.inspect(spring_find_table))
    find_file:close()
  end


  -- Save metadata
  local meta_file = io.open(cache_files.metadata_file, "w")
  if meta_file then
    local metadata = {
      project_root = get_project_root(),
      timestamp = cache_timestamp,
      scanned_annotations = scanned_annotations,
      version = "1.0",
      created_at = os.time(),
    }
    meta_file:write("return " .. vim.inspect(metadata))
    meta_file:close()
  end
end

M.load_from_file = function()
  local cache_config = get_cache_config()
  if cache_config.mode ~= "persistent" then
    return
  end

  local cache_files = get_cache_files()

  -- Load find table
  if file_exists(cache_files.find_cache_file) then
    local ok, data = pcall(dofile, cache_files.find_cache_file)
    if ok and data then
      spring_find_table = data
    end
  end


  -- Load metadata
  if file_exists(cache_files.metadata_file) then
    local ok, data = pcall(dofile, cache_files.metadata_file)
    if ok and data then
      if data.timestamp then
        cache_timestamp = data.timestamp
      end
      if data.scanned_annotations then
        scanned_annotations = data.scanned_annotations
      end
    end
  end
end

M.clear_persistent_cache = function()
  -- Clear memory cache
  M.clear_tables()

  local cache_files = get_cache_files()

  -- Remove cache files
  if file_exists(cache_files.find_cache_file) then
    vim.fn.delete(cache_files.find_cache_file)
  end
  if file_exists(cache_files.metadata_file) then
    vim.fn.delete(cache_files.metadata_file)
  end

  -- Remove cache directory if empty
  local cache_dir = cache_files.cache_dir
  if vim.fn.isdirectory(cache_dir) == 1 and vim.fn.empty(vim.fn.glob(cache_dir .. "/*")) == 1 then
    vim.fn.delete(cache_dir, "d")
  end
end

M.show_cache_status = function()
  local cache_config = get_cache_config()
  local cache_files = get_cache_files()

  local status_lines = {
    "=== Spring Cache Status ===",
    "Mode: " .. cache_config.mode,
    "Project: " .. vim.fn.fnamemodify(get_project_root(), ":t"),
    "Cache Directory: " .. cache_files.cache_dir,
    "",
    "=== Memory Cache ===",
  }

  -- Show detailed cache contents
  local find_count = 0
  local annotations = {}

  -- Show actual cache contents for debugging
  table.insert(status_lines, "=== Find Table Contents (showing all entries) ===")
  for path, path_data in pairs(spring_find_table) do
    table.insert(status_lines, "Path: " .. path)
    for annotation, entries in pairs(path_data) do
      find_count = find_count + (type(entries) == "table" and #entries or 1)
      if not vim.tbl_contains(annotations, annotation) then
        table.insert(annotations, annotation)
      end

      if type(entries) == "table" then
        for i, entry in ipairs(entries) do
          table.insert(status_lines, "  " .. annotation .. "[" .. i .. "]: " .. (entry.value or "no value"))
        end
      else
        table.insert(status_lines, "  " .. annotation .. ": " .. (entries.value or "no value"))
      end
    end
    table.insert(status_lines, "")
  end

  table.insert(status_lines, "")
  table.insert(status_lines, "Find entries: " .. find_count)
  table.insert(status_lines, "Cached annotations: " .. table.concat(annotations, ", "))

  if cache_config.mode == "persistent" then
    table.insert(status_lines, "")
    table.insert(status_lines, "=== File Cache Status ===")
    table.insert(status_lines, "Find cache: " .. (file_exists(cache_files.find_cache_file) and "✓" or "✗"))
    table.insert(status_lines, "Metadata: " .. (file_exists(cache_files.metadata_file) and "✓" or "✗"))

    if file_exists(cache_files.metadata_file) then
      local ok, metadata = pcall(dofile, cache_files.metadata_file)
      if ok and metadata then
        table.insert(status_lines, "Created: " .. os.date("%Y-%m-%d %H:%M:%S", metadata.created_at))
        if metadata.project_root then
          table.insert(status_lines, "Project root: " .. metadata.project_root)
        end
      end
    end
  end

  -- Show in floating window or print
  for _, line in ipairs(status_lines) do
    print(line)
  end
  return status_lines
end

-- Auto-load cache on module initialization
local function init()
  local cache_config = get_cache_config()
  if cache_config.mode == "persistent" then
    M.load_from_file()
  end
end

init()

return M

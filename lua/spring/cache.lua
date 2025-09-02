local M = {}

local spring_find_table = {}
local spring_preview_table = {}
local cache_timestamp = {}

-- Persistent cache configuration
local function get_project_root()
  local result = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return vim.fn.getcwd() -- fallback to current directory
  end
  return result:gsub("\n", "")
end

local function get_project_cache_dir()
  local project_root = get_project_root()
  local project_name = vim.fn.fnamemodify(project_root, ":t")
  return vim.fn.stdpath("data") .. "/telescope-spring/" .. project_name
end

local function get_cache_files()
  local cache_dir = get_project_cache_dir()
  return {
    cache_dir = cache_dir,
    find_cache_file = cache_dir .. "/find_cache.lua",
    preview_cache_file = cache_dir .. "/preview_cache.lua",
    metadata_file = cache_dir .. "/metadata.lua"
  }
end
local get_cache_config = function()
  local state = require "spring.state"
  local config = state.get_config()

  if not config then
    -- Fallback to default config if state is not initialized
    local default_config = require "spring.config"
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
    -- For persistent mode, mark as cached and auto-save
    cache_timestamp[annotation] = true
    M.save_to_file()
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
  return M.is_cache_valid(annotation) and M.has_cached_data(annotation)
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

  -- Save preview table
  local preview_file = io.open(cache_files.preview_cache_file, "w")
  if preview_file then
    preview_file:write("return " .. vim.inspect(spring_preview_table))
    preview_file:close()
  end

  -- Save metadata
  local meta_file = io.open(cache_files.metadata_file, "w")
  if meta_file then
    local metadata = {
      project_root = get_project_root(),
      timestamp = cache_timestamp,
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

  -- Load preview table
  if file_exists(cache_files.preview_cache_file) then
    local ok, data = pcall(dofile, cache_files.preview_cache_file)
    if ok and data then
      spring_preview_table = data
    end
  end

  -- Load metadata
  if file_exists(cache_files.metadata_file) then
    local ok, data = pcall(dofile, cache_files.metadata_file)
    if ok and data and data.timestamp then
      cache_timestamp = data.timestamp
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
  if file_exists(cache_files.preview_cache_file) then
    vim.fn.delete(cache_files.preview_cache_file)
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

-- Auto-load cache on module initialization
local function init()
  local cache_config = get_cache_config()
  if cache_config.mode == "persistent" then
    M.load_from_file()
  end
end

init()

return M

local M = {}

local create_user_command = vim.api.nvim_create_user_command
local default_config = require "spring.config"
local spring_picker = require "spring.picker"
local E = require "spring.enum"

-- Global config that will be used throughout the plugin
M.config = vim.deepcopy(default_config)

-- Function to get current config
M.get_config = function()
  return M.config
end

-- M.pick_all_mapping = function(opts)
--   spring_picker(opts, E.methods.ALL)
-- end

M.pick_get_mapping = function(opts)
  spring_picker(opts, E.methods.GET)
end
M.pick_post_mapping = function(opts)
  spring_picker(opts, E.methods.POST)
end
M.pick_put_mapping = function(opts)
  spring_picker(opts, E.methods.PUT)
end
M.pick_delete_mapping = function(opts)
  spring_picker(opts, E.methods.DELETE)
end

M.setup = function(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", {}, default_config, opts)
  
  -- Validate configuration
  if opts.cache_ttl and type(opts.cache_ttl) ~= "number" then
    vim.notify("Warning: cache_ttl must be a number", vim.log.levels.WARN)
  end
  
  if opts.ui and opts.ui.method_colors then
    for method, color in pairs(opts.ui.method_colors) do
      if type(color) ~= "string" then
        vim.notify("Warning: method color for " .. method .. " must be a string", vim.log.levels.WARN)
      end
    end
  end

  -- create_user_command("SpringAllMapping", function()
  --   M.pick_all_mapping(opts)
  -- end, {})

  create_user_command("SpringGetMapping", function()
    M.pick_get_mapping(opts)
  end, {})

  create_user_command("SpringPostMapping", function()
    M.pick_post_mapping(opts)
  end, {})

  create_user_command("SpringPutMapping", function()
    M.pick_put_mapping(opts)
  end, {})

  create_user_command("SpringDeleteMapping", function()
    M.pick_delete_mapping(opts)
  end, {})
end

return M

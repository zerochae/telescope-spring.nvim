local M = {}

local default_config = require "spring.config"
local spring_picker = require "spring.picker"
local enums = require "spring.enum"
local state = require "spring.state"

-- Global config that will be used throughout the plugin
M.config = vim.deepcopy(default_config)

-- Function to get current config
M.get_config = function()
  return M.config
end

-- M.pick_all_mapping = function(opts)
--   spring_picker(opts, enums.methods.ALL)
-- end

M.pick_get_mapping = function(opts)
  spring_picker(opts, enums.methods.GET)
end
M.pick_post_mapping = function(opts)
  spring_picker(opts, enums.methods.POST)
end
M.pick_put_mapping = function(opts)
  spring_picker(opts, enums.methods.PUT)
end
M.pick_delete_mapping = function(opts)
  spring_picker(opts, enums.methods.DELETE)
end
M.pick_patch_mapping = function(opts)
  spring_picker(opts, enums.methods.PATCH)
end

M.setup = function(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", {}, default_config, opts)
  -- Update state with the new config
  state.set_config(M.config)
  vim.g.spring_setup_called = true

  -- Validate configuration
  if opts.cache_ttl and type(opts.cache_ttl) ~= "number" then
    vim.notify("Warning: cache_ttl must be a number", vim.log.levels.WARN)
  end

  if opts.cache_mode and opts.cache_mode ~= "time" and opts.cache_mode ~= "session" and opts.cache_mode ~= "persistent" then
    vim.notify("Warning: cache_mode must be 'time', 'session', or 'persistent'", vim.log.levels.WARN)
  end

  if opts.ui then
    if opts.ui.method_colors then
      for method, color in pairs(opts.ui.method_colors) do
        if type(color) ~= "string" then
          vim.notify("Warning: method color for " .. method .. " must be a string", vim.log.levels.WARN)
        end
      end
    end

    if opts.ui.show_icons ~= nil and type(opts.ui.show_icons) ~= "boolean" then
      vim.notify("Warning: show_icons must be a boolean", vim.log.levels.WARN)
    end

    if opts.ui.show_method ~= nil and type(opts.ui.show_method) ~= "boolean" then
      vim.notify("Warning: show_method must be a boolean", vim.log.levels.WARN)
    end
  end
end

return M

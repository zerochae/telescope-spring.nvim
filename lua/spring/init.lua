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
M.pick_patch_mapping = function(opts)
  spring_picker(opts, E.methods.PATCH)
end

M.setup = function(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", {}, default_config, opts)
  vim.g.spring_setup_called = true
  
  -- Validate configuration
  if opts.cache_ttl and type(opts.cache_ttl) ~= "number" then
    vim.notify("Warning: cache_ttl must be a number", vim.log.levels.WARN)
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

  create_user_command("SpringPatchMapping", function()
    M.pick_patch_mapping(opts)
  end, {})
end

-- Auto-setup with lazy.nvim opts or default config  
vim.defer_fn(function()
  if not vim.g.spring_setup_called then
    -- lazy.nvim automatically calls setup when opts is specified
    -- This is a fallback for other package managers
    M.setup({})
    vim.g.spring_setup_called = true
  end
end, 100)

return M

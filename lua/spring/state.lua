local M = {}

-- Global state to hold configuration
M.config = nil

-- Set configuration
M.set_config = function(config)
  M.config = config
end

-- Get configuration
M.get_config = function()
  return M.config
end

return M
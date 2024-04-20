local M = {}

local create_user_command = vim.api.nvim_create_user_command
local config = require "spring.config"
local spring_picker = require "spring.picker"
local E = require "spring.enum"

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
  config = vim.tbl_deep_extend("force", {}, config, opts)

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

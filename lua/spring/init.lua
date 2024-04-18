local M = {}

local create_user_command = vim.api.nvim_create_user_command
local config = require "spring.config"
local spring_picker = require "spring.picker"
local methods = require("spring.enum").methods

M.find_get_mapping = function(opts)
  spring_picker(opts, methods.GET)
end
M.find_post_mapping = function(opts)
  spring_picker(opts, methods.POST)
end
M.find_put_mapping = function(opts)
  spring_picker(opts, methods.PUT)
end
M.find_delete_mapping = function(opts)
  spring_picker(opts, methods.DELETE)
end

M.setup = function(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("force", {}, config, opts)

  create_user_command("SpringFindGetMapping", function()
    M.find_get_mapping(opts)
  end, {})

  create_user_command("SpringFindPostMapping", function()
    M.find_post_mapping(opts)
  end, {})

  create_user_command("SpringFindPutMapping", function()
    M.find_put_mapping(opts)
  end, {})

  create_user_command("SpringFindDeleteMapping", function()
    M.find_delete_mapping(opts)
  end, {})
end

return M

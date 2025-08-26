local spring = require "spring"

-- Individual commands (existing)
vim.api.nvim_create_user_command("SpringGetMapping", function()
  spring.pick_get_mapping(spring.get_config().get or {})
end, {})

vim.api.nvim_create_user_command("SpringPostMapping", function()
  spring.pick_post_mapping(spring.get_config().post or {})
end, {})

vim.api.nvim_create_user_command("SpringPutMapping", function()
  spring.pick_put_mapping(spring.get_config().put or {})
end, {})

vim.api.nvim_create_user_command("SpringDeleteMapping", function()
  spring.pick_delete_mapping(spring.get_config().delete or {})
end, {})

vim.api.nvim_create_user_command("SpringPatchMapping", function()
  spring.pick_patch_mapping(spring.get_config().patch or {})
end, {})

-- Main Spring command with subcommands
vim.api.nvim_create_user_command("Spring", function(opts)
  local subcommand = opts.fargs[1]
  if not subcommand then
    vim.notify("Usage: Spring {Get|Post|Put|Delete|Patch}", vim.log.levels.WARN)
    return
  end
  
  local method = string.upper(subcommand)
  local config = spring.get_config()
  
  if method == "GET" then
    spring.pick_get_mapping(config.get or {})
  elseif method == "POST" then
    spring.pick_post_mapping(config.post or {})
  elseif method == "PUT" then
    spring.pick_put_mapping(config.put or {})
  elseif method == "DELETE" then
    spring.pick_delete_mapping(config.delete or {})
  elseif method == "PATCH" then
    spring.pick_patch_mapping(config.patch or {})
  else
    vim.notify("Unknown method: " .. subcommand .. ". Available: Get, Post, Put, Delete, Patch", vim.log.levels.ERROR)
  end
end, {
  nargs = 1,
  complete = function()
    return { "Get", "Post", "Put", "Delete", "Patch" }
  end,
})


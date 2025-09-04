-- Individual commands (existing)
vim.api.nvim_create_user_command("EndpointGetMapping", function()
  local endpoint = require "endpoint"
  endpoint.pick_get_mapping(endpoint.get_config().get or {})
end, {})

vim.api.nvim_create_user_command("EndpointPostMapping", function()
  local endpoint = require "endpoint"
  endpoint.pick_post_mapping(endpoint.get_config().post or {})
end, {})

vim.api.nvim_create_user_command("EndpointPutMapping", function()
  local endpoint = require "endpoint"
  endpoint.pick_put_mapping(endpoint.get_config().put or {})
end, {})

vim.api.nvim_create_user_command("EndpointDeleteMapping", function()
  local endpoint = require "endpoint"
  endpoint.pick_delete_mapping(endpoint.get_config().delete or {})
end, {})

vim.api.nvim_create_user_command("EndpointPatchMapping", function()
  local endpoint = require "endpoint"
  endpoint.pick_patch_mapping(endpoint.get_config().patch or {})
end, {})

-- Cache management commands
vim.api.nvim_create_user_command("EndpointClearCache", function()
  local cache = require "endpoint.cache"
  cache.clear_persistent_cache()
  vim.notify("Endpoint cache cleared", vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("EndpointCacheStatus", function()
  local cache = require "endpoint.cache"
  cache.show_cache_status()
end, {})

-- Main Spring command with subcommands
vim.api.nvim_create_user_command("Endpoint", function(opts)
  local endpoint = require "endpoint"
  local subcommand = opts.fargs[1]
  if not subcommand then
    vim.notify("Usage: Endpoint {Get|Post|Put|Delete|Patch|ClearCache|CacheStatus}", vim.log.levels.WARN)
    return
  end

  local method = string.upper(subcommand)
  local config = endpoint.get_config()

  if method == "GET" then
    endpoint.pick_get_mapping(config.get or {})
  elseif method == "POST" then
    endpoint.pick_post_mapping(config.post or {})
  elseif method == "PUT" then
    endpoint.pick_put_mapping(config.put or {})
  elseif method == "DELETE" then
    endpoint.pick_delete_mapping(config.delete or {})
  elseif method == "PATCH" then
    endpoint.pick_patch_mapping(config.patch or {})
  elseif method == "CLEARCACHE" then
    local cache = require "endpoint.cache"
    cache.clear_persistent_cache()
    vim.notify("Endpoint cache cleared", vim.log.levels.INFO)
  elseif method == "CACHESTATUS" then
    local cache = require "endpoint.cache"
    cache.show_cache_status()
  else
    vim.notify(
      "Unknown method: "
        .. subcommand
        .. ". Available: Get, Post, Put, Delete, Patch, ClearCache, CacheStatus",
      vim.log.levels.ERROR
    )
  end
end, {
  nargs = 1,
  complete = function()
    return { "Get", "Post", "Put", "Delete", "Patch", "ClearCache", "CacheStatus" }
  end,
})

-- Create user commands
local function create_commands()
  local spring = require("spring")
  
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
end

-- Create commands immediately
create_commands()

-- Auto-setup with lazy.nvim opts or default config
vim.defer_fn(function()
  if not vim.g.spring_setup_called then
    -- Check if lazy.nvim passed opts
    local lazy_opts = vim.g.lazy_spring_opts or {}
    local spring = require("spring")
    spring.setup(lazy_opts)
    vim.g.spring_setup_called = true
  end
end, 100)
local spring = require "spring"

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


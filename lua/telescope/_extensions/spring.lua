local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error "requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local spring = require "spring"

return telescope.register_extension {
  setup = function()
    -- telescope extension setup - usually not needed as main setup is handled by plugin/spring.lua
  end,
  exports = {
    -- Main spring picker (shows all endpoints)
    spring = function(opts)
      return spring.pick_get_mapping(opts) -- Default to GET or could be all mappings
    end,

    -- Individual method pickers
    get = function(opts)
      return spring.pick_get_mapping(opts)
    end,
    post = function(opts)
      return spring.pick_post_mapping(opts)
    end,
    put = function(opts)
      return spring.pick_put_mapping(opts)
    end,
    delete = function(opts)
      return spring.pick_delete_mapping(opts)
    end,
    patch = function(opts)
      return spring.pick_patch_mapping(opts)
    end,
  },
}

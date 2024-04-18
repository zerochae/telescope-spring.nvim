local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error "requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local spring_picker = require "spring.picker"

return telescope.register_extension {
  exports = {
    spring = spring_picker,
  },
}

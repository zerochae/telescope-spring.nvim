local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error "This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

-- our picker function: colors
local function spring_picker(opts) end

return telescope.register_extension {
  exports = {
    spring = spring_picker,
  },
}

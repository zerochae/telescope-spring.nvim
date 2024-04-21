local pickers = require "telescope.pickers"
local spring_finder = require "spring.finder"
local spring_previewer = require "spring.previewer"
local spring_actions = require "spring.actions"
local conf = require("telescope.config").values
local U = require "spring.util"

return function(opts, method)
  opts = opts or {}
  local annotation = U.get_annotation(method)
  local finder = spring_finder(annotation)
  local previewer = spring_previewer(annotation)
  local sorter = conf.generic_sorter()

  return pickers
    .new(opts, {
      finder = finder,
      previewer = previewer,
      sorter = sorter,
      attach_mappings = spring_actions,
    })
    :find()
end

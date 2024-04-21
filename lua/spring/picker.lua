local pickers = require "telescope.pickers"
local spring_finder = require "spring.finder"
local spring_previewer = require "spring.previewer"
local U = require "spring.util"

return function(opts, method)
  opts = opts or {}
  local annotation = U.get_annotation(method)
  local finder = spring_finder(annotation)
  local previewer = spring_previewer(annotation)

  return pickers
    .new(opts, {
      finder = finder,
      previewer = previewer,
    })
    :find()
end

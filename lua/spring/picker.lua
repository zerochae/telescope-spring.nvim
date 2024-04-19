local pickers = require "telescope.pickers"
local spring_finder = require "spring.finder"
local spring_previewer = require "spring.previewer"

local spring_picker = function(method, opts)
  local finder_by_method = spring_finder(method)
  local previewer_by_method = spring_previewer(method)

  return pickers.new(opts, {
    finder = finder_by_method,
    previewer = previewer_by_method,
  })
end

return function(opts, method)
  spring_picker(opts or {}, method):find()
end

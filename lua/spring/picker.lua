local pickers = require "telescope.pickers"
local spring_finder = require "spring.finder"

local spring_picker = function(opts, method)
  local finder_by_method = spring_finder(method)

  return pickers.new(opts, {
    finder = finder_by_method,
  })
end

return function(opts, method)
  spring_picker(opts or {}, method):find()
end

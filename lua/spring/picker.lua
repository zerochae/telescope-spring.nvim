local pickers = require "telescope.pickers"
local spring_finder = require "spring.finder"
local spring_previewer = require "spring.previewer"
local E = require "spring.enum"

local spring_picker = function(opts, method)
  local finder_by_method = spring_finder(method)
  local previewer_by_method = spring_previewer(method)

  return pickers.new(opts, {
    finder = finder_by_method,
    -- previewer = previewer_by_method,
  })
end

return function(opts, method)
  opts = opts or {}
  method = method or E.methods.ALL
  spring_picker(opts, method):find()
end

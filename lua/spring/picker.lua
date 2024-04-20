local pickers = require "telescope.pickers"
local spring_finder = require "spring.finder"
local spring_previewer = require "spring.previewer"
local U = require "spring.util"
local E = require "spring.enum"

local create_find_table = function(annotation)
  U.create_request_mapping_table()
  U.create_spring_table(annotation)
end

local spring_picker = function(opts, method)
  local annotation = U.get_annotation(method)

  create_find_table(annotation)
  local finder = spring_finder(annotation)
  local previewer = spring_previewer()

  return pickers.new(opts, {
    finder = finder,
    previewer = previewer,
  })
end

return function(opts, method)
  opts = opts or {}
  method = method or E.methods.GET
  spring_picker(opts, method):find()
end

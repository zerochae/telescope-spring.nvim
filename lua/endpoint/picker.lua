local pickers = require "telescope.pickers"
local spring_finder = require "endpoint.finder"
local spring_previewer = require "endpoint.previewer"
local spring_actions = require "endpoint.actions"
local conf = require("telescope.config").values
local util = require "endpoint.util"

return function(opts, method)
  opts = opts or {}
  -- U.set_spring_tables() -- Removed: This was clearing cache on every call
  
  -- Use method directly instead of converting to annotation
  local finder = spring_finder(method)
  local previewer = spring_previewer(method)
  local sorter = conf.generic_sorter()

  return pickers
    .new(opts, {
      prompt_title = " Endpoint",
      preview_title = "  Preview",
      finder = finder,
      previewer = previewer,
      sorter = sorter,
      attach_mappings = spring_actions,
    })
    :find()
end
